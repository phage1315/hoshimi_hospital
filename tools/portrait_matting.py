#!/usr/bin/env python3
"""Local neural anime portrait matting CLI for Hoshimi Hospital.

Uses local ONNX segmentation weights stored in `.venv/models/`:
  - `birefnet` (default): `birefnet-toonout-fp16.onnx` (BiRefNet fine-tuned on 2D anime art & hair)
  - `isnet`: `isnetis.onnx` (SkyTNT anime-seg IS-Net)

Features:
  1. High-precision alpha matting for cel-shaded / anime portraits (preserving wispy hair & white coats).
  2. Spatially adaptive semi-transparent edge color decontamination (removes white/gray background halos on dark scenes).
  3. Isotropic resizing to project standard `1024x1536` RGBA PNG without stretching or bottom-edge floating gaps.
  4. Optional QA preview sheet (`--qa-sheet`) compositing over dark/hospital/light backgrounds + 2x edge zoom.

Usage:
  .venv/bin/python tools/portrait_matting.py input_raw.jpg -o output_neutral.png --qa-sheet /tmp/qa.png
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
import time
from pathlib import Path

import numpy as np
import onnxruntime as ort
from PIL import Image, ImageDraw, ImageFilter

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_MODELS = {
    "birefnet": REPO_ROOT / ".venv" / "models" / "birefnet-toonout-fp16.onnx",
    "isnet": REPO_ROOT / ".venv" / "models" / "isnetis.onnx",
}

IMAGENET_MEAN = np.array([0.485, 0.456, 0.406], dtype=np.float32).reshape(1, 3, 1, 1)
IMAGENET_STD = np.array([0.229, 0.224, 0.225], dtype=np.float32).reshape(1, 3, 1, 1)


def create_session(model_path: Path) -> ort.InferenceSession:
    if not model_path.is_file():
        raise FileNotFoundError(
            f"ONNX model not found at {model_path}. "
            "Ensure `.venv/models/` contains the downloaded weights."
        )
    opts = ort.SessionOptions()
    opts.log_severity_level = 3
    return ort.InferenceSession(
        str(model_path),
        sess_options=opts,
        providers=["CPUExecutionProvider"],
    )


def predict_alpha(session: ort.InferenceSession, img_rgb: Image.Image, model_kind: str) -> np.ndarray:
    """Return float32 alpha matte in [0.0, 1.0] at `img_rgb` native resolution (H, W)."""
    w, h = img_rgb.size
    if model_kind == "birefnet":
        # BiRefNet-ToonOut is trained with direct 1024x1024 resize + ImageNet normalization
        inp = img_rgb.resize((1024, 1024), Image.Resampling.BILINEAR)
        tensor = np.asarray(inp, dtype=np.float32).transpose(2, 0, 1)[None] / 255.0
        tensor = (tensor - IMAGENET_MEAN) / IMAGENET_STD
        inp_name = session.get_inputs()[0].name
        raw_mask = session.run(None, {inp_name: tensor})[0][0, 0]
        raw_mask = np.clip(raw_mask, 0.0, 1.0)
        mask_img = Image.fromarray((raw_mask * 255.0).round().astype(np.uint8), mode="L").resize(
            (w, h), Image.Resampling.LANCZOS
        )
        alpha = np.asarray(mask_img, dtype=np.float32) / 255.0
    elif model_kind == "isnet":
        # SkyTNT anime-seg IS-Net uses aspect-preserving letterbox to 1024x1024 in [0, 1]
        scale = 1024.0 / max(w, h)
        nw, nh = int(round(w * scale)), int(round(h * scale))
        resized = img_rgb.resize((nw, nh), Image.Resampling.BILINEAR)
        border_px = np.asarray(img_rgb)[:8, :8].reshape(-1, 3)
        bg_color = tuple(int(v) for v in np.median(border_px, axis=0))
        canvas = Image.new("RGB", (1024, 1024), bg_color)
        ox, oy = (1024 - nw) // 2, (1024 - nh) // 2
        canvas.paste(resized, (ox, oy))
        tensor = np.asarray(canvas, dtype=np.float32).transpose(2, 0, 1)[None] / 255.0
        inp_name = session.get_inputs()[0].name
        raw_mask = session.run(None, {inp_name: tensor})[0][0, 0]
        raw_mask = np.clip(raw_mask[oy : oy + nh, ox : ox + nw], 0.0, 1.0)
        mask_img = Image.fromarray((raw_mask * 255.0).round().astype(np.uint8), mode="L").resize(
            (w, h), Image.Resampling.LANCZOS
        )
        alpha = np.asarray(mask_img, dtype=np.float32) / 255.0
    else:
        raise ValueError(f"Unsupported model_kind: {model_kind}")

    # Clean sub-1/255 residual dust in background & snap solid interior (>= 0.992 -> 1.0)
    alpha = np.where(alpha < 0.008, 0.0, alpha)
    alpha = np.where(alpha > 0.992, 1.0, alpha)
    return alpha


def decontaminate_edges(
    rgb_arr: np.ndarray,
    alpha: np.ndarray,
    strength: float = 0.85,
) -> np.ndarray:
    """Unmix local background color from semi-transparent hair/contour pixels."""
    if strength <= 0.0:
        return rgb_arr

    rgb_f = rgb_arr.astype(np.float32)
    bg_mask = (alpha < 0.01).astype(np.float32)

    # Fallback global background color from pure-background pixels (or top corners)
    if bg_mask.sum() > 64:
        global_bg = np.median(rgb_f[alpha < 0.01], axis=0)
    else:
        corners = np.concatenate([rgb_f[:8, :8].reshape(-1, 3), rgb_f[:8, -8:].reshape(-1, 3)], axis=0)
        global_bg = np.median(corners, axis=0)

    # Spatially smooth local background estimate propagated into semi-transparent edges
    w_img = Image.fromarray((bg_mask * 255.0).astype(np.uint8), mode="L").filter(
        ImageFilter.GaussianBlur(radius=20)
    )
    w_blur = (np.asarray(w_img, dtype=np.float32) / 255.0)[..., None]

    local_bg = np.empty_like(rgb_f)
    for c in range(3):
        prod_img = Image.fromarray((rgb_f[..., c] * bg_mask).clip(0, 255).astype(np.uint8), mode="L").filter(
            ImageFilter.GaussianBlur(radius=20)
        )
        local_bg[..., c] = np.asarray(prod_img, dtype=np.float32)

    bg_est = np.where(w_blur > 0.02, local_bg / np.maximum(w_blur, 1e-4), global_bg.reshape(1, 1, 3))

    edge = (alpha > 0.0) & (alpha < 0.98)
    if not np.any(edge):
        return rgb_arr

    a_exp = alpha[..., None]
    a_safe = np.maximum(a_exp, 0.20)
    unmixed = (rgb_f - (1.0 - a_exp) * bg_est) / a_safe
    unmixed = np.clip(unmixed, 0.0, 255.0)

    blended = rgb_f * (1.0 - strength) + unmixed * strength
    out = np.where(edge[..., None], blended, rgb_f)
    # Zero RGB in fully transparent pixels for clean PNG compression & mipmap filtering
    # Wait: for Godot mipmap filtering, keeping nearest edge RGB or zero? Actually premultiplied/bleed-free:
    # keeping unmixed RGB on >0 alpha and local foreground bleed on alpha==0 prevents dark fringes in mipmaps!
    return np.round(out).clip(0, 255).astype(np.uint8)


def bleed_transparent_rgb_for_mipmaps(rgb_u8: np.ndarray, alpha_u8: np.ndarray) -> np.ndarray:
    """Fill alpha==0 pixels near edges with blurred foreground RGB so Godot mipmaps never show black/white halos."""
    fg_mask = (alpha_u8 >= 32).astype(np.float32)
    if fg_mask.sum() < 16:
        return rgb_u8
    rgb_f = rgb_u8.astype(np.float32)
    w_img = Image.fromarray((fg_mask * 255.0).astype(np.uint8), mode="L").filter(
        ImageFilter.GaussianBlur(radius=6)
    )
    w_blur = (np.asarray(w_img, dtype=np.float32) / 255.0)[..., None]
    bleed = np.zeros_like(rgb_f)
    for c in range(3):
        c_img = Image.fromarray((rgb_f[..., c] * fg_mask).clip(0, 255).astype(np.uint8), mode="L").filter(
            ImageFilter.GaussianBlur(radius=6)
        )
        bleed[..., c] = np.asarray(c_img, dtype=np.float32)
    filled = np.where(w_blur > 0.01, bleed / np.maximum(w_blur, 1e-4), 0.0)
    zero_a = (alpha_u8 == 0)[..., None]
    return np.where(zero_a, np.round(filled).clip(0, 255).astype(np.uint8), rgb_u8)


def standardize_canvas(
    img_rgba: Image.Image,
    target_w: int,
    target_h: int,
    resize_mode: str,
) -> Image.Image:
    if resize_mode == "keep":
        return img_rgba
    w, h = img_rgba.size
    if (w, h) == (target_w, target_h):
        return img_rgba

    if resize_mode == "cover":
        scale = max(target_w / w, target_h / h)
        nw, nh = int(round(w * scale)), int(round(h * scale))
        resized = img_rgba.resize((nw, nh), Image.Resampling.LANCZOS)
        ox = (nw - target_w) // 2
        oy = nh - target_h  # Anchor bottom edge so waist/hip stays flush with bottom of canvas
        return resized.crop((ox, oy, ox + target_w, oy + target_h))
    elif resize_mode == "fit-bottom":
        scale = min(target_w / w, target_h / h)
        nw, nh = int(round(w * scale)), int(round(h * scale))
        resized = img_rgba.resize((nw, nh), Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
        ox = (target_w - nw) // 2
        oy = target_h - nh
        canvas.paste(resized, (ox, oy))
        return canvas
    else:
        raise ValueError(f"Unknown resize_mode: {resize_mode}")


def render_qa_sheet(img_rgba: Image.Image, out_path: Path) -> None:
    """Render dark / hospital-teal / light full previews + 2x hair & coat edge zoom crops."""
    w, h = img_rgba.size
    thumb_h = 640
    thumb_w = int(round(w * (thumb_h / h)))
    thumb = img_rgba.resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)

    bgs = [
        ("Dark (#161A22)", (22, 26, 34)),
        ("Hospital (#2B4450)", (43, 68, 80)),
        ("Light (#F2EFE9)", (242, 239, 233)),
    ]

    pad = 16
    top_h = thumb_h + pad * 2
    zoom_w, zoom_h = (thumb_w * 3 + pad * 2) // 2 - pad // 2, 360
    sheet_w = thumb_w * 3 + pad * 4
    sheet_h = top_h + zoom_h + pad * 2

    sheet = Image.new("RGB", (sheet_w, sheet_h), (30, 34, 42))
    draw = ImageDraw.Draw(sheet)

    for idx, (label, color) in enumerate(bgs):
        panel = Image.new("RGBA", (thumb_w, thumb_h), (*color, 255))
        panel.alpha_composite(thumb)
        x0 = pad + idx * (thumb_w + pad)
        sheet.paste(panel.convert("RGB"), (x0, pad))
        draw.rectangle([x0, pad, x0 + 150, pad + 24], fill=(0, 0, 0))
        draw.text((x0 + 8, pad + 6), label, fill=(235, 240, 245))

    # Auto-locate foreground bounding box for 2x zoom crops (hair crown/strands & shoulder/coat edge)
    a_np = np.asarray(img_rgba)[:, :, 3]
    ys, xs = np.where(a_np > 16)
    if len(ys) > 0:
        y_top = max(0, int(ys.min()) - 15)
        x_mid = int(round((xs.min() + xs.max()) / 2))
    else:
        y_top, x_mid = 40, w // 2

    cw, ch = zoom_w // 2, zoom_h // 2
    crops = [
        ("2x Hair & Crown on Dark", (max(0, x_mid - cw // 2), y_top), (20, 24, 32)),
        ("2x Coat & Hair on Hospital Teal", (max(0, x_mid - cw // 2), min(h - ch, y_top + 420)), (43, 68, 80)),
    ]
    for idx, (title, (cx, cy), bg_c) in enumerate(crops):
        sub = img_rgba.crop((cx, cy, min(w, cx + cw), min(h, cy + ch)))
        panel = Image.new("RGBA", sub.size, (*bg_c, 255))
        panel.alpha_composite(sub)
        zoomed = panel.convert("RGB").resize((zoom_w, zoom_h), Image.Resampling.NEAREST)
        x0 = pad + idx * (zoom_w + pad)
        y0 = top_h + pad // 2
        sheet.paste(zoomed, (x0, y0))
        draw.rectangle([x0, y0, x0 + 230, y0 + 24], fill=(0, 0, 0))
        draw.text((x0 + 8, y0 + 6), title, fill=(235, 240, 245))

    out_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out_path, format="PNG")


def parse_size(spec: str) -> tuple[int, int]:
    parts = spec.lower().split("x")
    if len(parts) != 2:
        raise argparse.ArgumentTypeError(f"Invalid size '{spec}', expected WIDTHxHEIGHT (e.g. 1024x1536)")
    return int(parts[0]), int(parts[1])


def main() -> int:
    parser = argparse.ArgumentParser(description="Local ONNX anime portrait background removal.")
    parser.add_argument("input", type=Path, help="Input opaque portrait image (.jpg / .png)")
    parser.add_argument("-o", "--output", type=Path, required=True, help="Output transparent RGBA .png path")
    parser.add_argument(
        "--model",
        choices=["birefnet", "isnet"],
        default="birefnet",
        help="Matting model to run (default: birefnet = BiRefNet-ToonOut FP16)",
    )
    parser.add_argument("--model-path", type=Path, default=None, help="Override explicit .onnx path")
    parser.add_argument(
        "--target-size",
        type=parse_size,
        default=(1024, 1536),
        help="Target WxH canvas size (default: 1024x1536 per portrait_import_standard.md)",
    )
    parser.add_argument(
        "--resize-mode",
        choices=["cover", "fit-bottom", "keep"],
        default="cover",
        help="Canvas resize mode: 'cover' (default, bottom-anchored isotropic), 'fit-bottom', or 'keep'",
    )
    parser.add_argument(
        "--decontaminate",
        type=float,
        default=0.85,
        help="Semi-transparent edge background unmixing strength in [0, 1] (default: 0.85)",
    )
    parser.add_argument("--qa-sheet", type=Path, default=None, help="Optional output path for QA contact sheet PNG")
    args = parser.parse_args()

    model_path = args.model_path or DEFAULT_MODELS[args.model]
    t0 = time.perf_counter()
    session = create_session(model_path)

    src_rgb = Image.open(args.input).convert("RGB")
    alpha = predict_alpha(session, src_rgb, args.model)

    rgb_np = np.asarray(src_rgb, dtype=np.uint8)
    clean_rgb = decontaminate_edges(rgb_np, alpha, strength=args.decontaminate)
    alpha_u8 = np.round(alpha * 255.0).clip(0, 255).astype(np.uint8)
    clean_rgb = bleed_transparent_rgb_for_mipmaps(clean_rgb, alpha_u8)

    rgba_img = Image.fromarray(np.dstack([clean_rgb, alpha_u8]), mode="RGBA")
    target_w, target_h = args.target_size
    final_img = standardize_canvas(rgba_img, target_w, target_h, args.resize_mode)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    final_img.save(args.output, format="PNG")
    elapsed = time.perf_counter() - t0

    if args.qa_sheet is not None:
        render_qa_sheet(final_img, args.qa_sheet)

    final_a = np.asarray(final_img)[:, :, 3]
    top_left_max = int(final_a[:8, :8].max())
    top_right_max = int(final_a[:8, -8:].max())
    fg_ratio = float((final_a > 16).mean())
    sha256 = hashlib.sha256(args.output.read_bytes()).hexdigest()

    report = {
        "input": str(args.input),
        "output": str(args.output),
        "model": args.model,
        "size": list(final_img.size),
        "mode": final_img.mode,
        "top_corners_transparent": (top_left_max == 0 and top_right_max == 0),
        "foreground_ratio": round(fg_ratio, 4),
        "elapsed_sec": round(elapsed, 2),
        "sha256": sha256,
    }
    print(json.dumps(report, ensure_ascii=False))
    if not report["top_corners_transparent"]:
        print(
            f"WARNING: Top corners have non-zero alpha (TL={top_left_max}, TR={top_right_max})",
            file=sys.stderr,
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
