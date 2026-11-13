#!/usr/bin/env python3
"""Unified CLI runner for Hoshimi Hospital OpenAI voice creation, auditioning, and clip-pack rendering.

Designed so AI coding agents always invoke a single prefix-matchable binary + subcommand:
    tools/voice_runner/hoshimi-voice run /private/tmp/<job_name>.json
Once the user grants "Always Allow" on `tools/voice_runner/hoshimi-voice run`, future voice jobs
do not re-prompt on every new character or clip batch.
"""
from __future__ import annotations

from concurrent.futures import ThreadPoolExecutor, as_completed
import argparse
import hashlib
import json
import math
from pathlib import Path
import shutil
import socket
import struct
import subprocess
import sys
import tempfile
import threading
import unicodedata
import wave

REPO_ROOT = Path(__file__).resolve().parents[2]
VOICE_PY = REPO_ROOT / "docs/skills/openai-character-voice/scripts/voice.py"
DEFAULT_KEY_FILE = Path.home() / ".config/hoshimi/openai-api-key"

PRINT_LOCK = threading.Lock()


def log(msg: str) -> None:
    with PRINT_LOCK:
        print(msg, flush=True)


def resolve_repo_path(raw_path: str | Path) -> Path:
    p = Path(raw_path)
    return p if p.is_absolute() else (REPO_ROOT / p)


def _normalize_transcript(text: str) -> str:
    norm = unicodedata.normalize("NFKC", text or "")
    for ch in (" ", "\t", "\r", "\n", "　"):
        norm = norm.replace(ch, "")
    norm = norm.replace("...", "…").replace("……", "…")
    return norm


def _take_passes(res: dict, expected_text: str) -> bool:
    if bool(res.get("technical_pass")):
        return True
    if (
        not bool(res.get("session_finalized"))
        or bool(res.get("errors"))
        or float(res.get("audio_seconds", 0.0)) < 0.25
        or int(res.get("peak_amplitude", 0)) < 256
    ):
        return False
    return _normalize_transcript(str(res.get("transcript", ""))) == _normalize_transcript(expected_text)


def measure_wav_metrics(wav_path: Path) -> dict:
    """Compute true HPS F0 (Hz), formant brightness bands (600-1.5k & 1.5-3.5k %), HF clarity, and peak dBFS."""
    import numpy as np

    with wave.open(str(wav_path), "rb") as wf:
        rate = wf.getframerate()
        nframes = wf.getnframes()
        raw = wf.readframes(nframes)
    if nframes == 0 or rate <= 0:
        return {
            "duration_seconds": 0.0,
            "peak_amplitude": 0,
            "peak_dbfs": -99.0,
            "f0_median_hz": 0.0,
            "f0_p25_hz": 0.0,
            "band_600_1500_pct": 0.0,
            "band_1500_3500_pct": 0.0,
            "hf_clarity": 0.0,
        }
    arr_i16 = np.frombuffer(raw, dtype=np.int16)
    peak_int = int(np.max(np.abs(arr_i16))) if arr_i16.size else 0
    dur = round(nframes / rate, 4)
    if peak_int < 10:
        return {
            "duration_seconds": dur,
            "peak_amplitude": peak_int,
            "peak_dbfs": -99.0,
            "f0_median_hz": 0.0,
            "f0_p25_hz": 0.0,
            "band_600_1500_pct": 0.0,
            "band_1500_3500_pct": 0.0,
            "hf_clarity": 0.0,
        }

    x = arr_i16.astype(np.float64) / 32768.0
    win = 1024
    win_fn = np.hanning(win)
    freqs_1k = np.fft.rfftfreq(win, 1.0 / rate)
    freqs_4k = np.fft.rfftfreq(4096, 1.0 / rate)
    f0s: list[float] = []
    b_mid: list[float] = []
    b_pres: list[float] = []
    for i in range(0, max(0, len(x) - win), 512):
        fr = x[i : i + win]
        if float(np.sqrt(np.mean(fr * fr))) < 0.018:
            continue
        p = np.abs(np.fft.rfft(fr * win_fn)) ** 2
        tot = float(np.sum(p)) + 1e-12
        b_mid.append(float(np.sum(p[(freqs_1k >= 600) & (freqs_1k < 1500)])) / tot * 100.0)
        b_pres.append(float(np.sum(p[(freqs_1k >= 1500) & (freqs_1k < 3500)])) / tot * 100.0)

        mag4 = np.abs(np.fft.rfft(fr * win_fn, 4096))
        n3 = len(mag4) // 3
        hps = mag4[:n3] * mag4[::2][:n3] * mag4[::3][:n3]
        mask = (freqs_4k[:n3] >= 150) & (freqs_4k[:n3] <= 420)
        idx = int(np.argmax(hps[mask]))
        f0s.append(float(freqs_4k[:n3][mask][idx]))

    active_mask = np.abs(arr_i16) > 200
    if np.any(active_mask) and arr_i16.size > 1:
        diffs = arr_i16[1:].astype(np.float64) - arr_i16[:-1].astype(np.float64)
        diff_sq = float(np.sum(diffs[active_mask[1:]] ** 2))
        sig_sq = float(np.sum(arr_i16[active_mask].astype(np.float64) ** 2))
        hfc = round(math.sqrt(diff_sq / sig_sq), 3) if sig_sq > 0 else 0.0
    else:
        hfc = 0.0

    peak_dbfs = round(20.0 * math.log10(peak_int / 32768.0), 1)
    return {
        "duration_seconds": dur,
        "peak_amplitude": peak_int,
        "peak_dbfs": peak_dbfs,
        "f0_median_hz": round(float(np.median(f0s)), 1) if f0s else 0.0,
        "f0_p25_hz": round(float(np.percentile(f0s, 25)), 1) if f0s else 0.0,
        "band_600_1500_pct": round(float(np.median(b_mid)), 1) if b_mid else 0.0,
        "band_1500_3500_pct": round(float(np.median(b_pres)), 1) if b_pres else 0.0,
        "hf_clarity": hfc,
    }


def trim_wav_silence(raw_path: Path, out_path: Path, threshold: int = 30) -> dict:
    """Conservatively trim leading/trailing silence without clipping soft consonants."""
    with wave.open(str(raw_path), "rb") as wf:
        rate = wf.getframerate()
        nframes = wf.getnframes()
        raw_bytes = wf.readframes(nframes)
    samples = [abs(x[0]) for x in struct.iter_unpack("<h", raw_bytes)]
    active = [i for i, v in enumerate(samples) if v > threshold]
    if active:
        first_idx = active[0]
        last_idx = active[-1]
        start_frame = 0 if first_idx <= int(0.35 * rate) else max(0, first_idx - int(0.15 * rate))
        end_frame = min(nframes, last_idx + int(0.38 * rate))
    else:
        start_frame, end_frame = 0, nframes
    trimmed_bytes = raw_bytes[start_frame * 2 : end_frame * 2]
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(out_path), "wb") as out_w:
        out_w.setnchannels(1)
        out_w.setsampwidth(2)
        out_w.setframerate(rate)
        out_w.writeframes(trimmed_bytes)
    sha = hashlib.sha256(out_path.read_bytes()).hexdigest()
    return {
        "trim_start_seconds": round(start_frame / rate, 6),
        "trim_end_seconds": round(end_frame / rate, 6),
        "trimmed_duration_seconds": round((end_frame - start_frame) / rate, 6),
        "sha256": sha,
    }


def check_network() -> bool:
    try:
        socket.getaddrinfo("api.openai.com", 443)
        return True
    except OSError as exc:
        log(f"[NETWORK BLOCKED] {type(exc).__name__}: {exc}")
        return False


def run_candidate_item(spec: dict, key_file: Path, dry_run: bool, work_dir: Path) -> dict:
    actor_id = spec["actor_id"]
    ver = spec["version"]
    tag = spec.get("tag") or f"{actor_id}_{ver}"
    actor_dir = resolve_repo_path(spec.get("out_dir") or f"research/voice_candidates/{tag}")

    prompt_file = work_dir / f"{tag}_prompt.txt"
    text_file = work_dir / f"{tag}_sample.txt"
    prompt_file.write_text(spec["prompt"].strip() + "\n", encoding="utf-8")
    text_file.write_text(spec["sample_text"].strip() + "\n", encoding="utf-8")

    if dry_run:
        dry_out = work_dir / f"dry_{tag}"
        if dry_out.exists():
            shutil.rmtree(dry_out)
        proc = subprocess.run(
            [
                sys.executable,
                str(VOICE_PY),
                "create",
                "--name",
                spec["voice_name"],
                "--prompt-file",
                str(prompt_file),
                "--out",
                str(dry_out),
                "--dry-run",
            ],
            capture_output=True,
            text=True,
        )
        ok = proc.returncode == 0 and (dry_out / "request.json").exists()
        log(f"[DRY CANDIDATE {tag}] ok={ok}")
        return {"kind": "candidate", "tag": tag, "ok": ok, "dry_run": True}

    actor_dir.mkdir(parents=True, exist_ok=True)
    (actor_dir / ".gdignore").write_text("", encoding="utf-8")
    top_voice_json = actor_dir / "voice.json"

    # 1. Create Voice ID once (no automatic retry on failure/timeout)
    if not top_voice_json.exists():
        create_dir_name = spec.get("create_dir_name", "create_run")
        create_dir = actor_dir / create_dir_name
        if create_dir.exists():
            if (create_dir / "voice.json").exists():
                shutil.copy2(create_dir / "voice.json", top_voice_json)
                shutil.copy2(create_dir / "request.json", actor_dir / "request.json")
            else:
                log(f"[HALT {tag}] {create_dir_name} exists without voice.json; reconcile server state before retrying.")
                return {"kind": "candidate", "tag": tag, "ok": False, "stage": "create_incomplete"}
        else:
            proc = subprocess.run(
                [
                    sys.executable,
                    str(VOICE_PY),
                    "create",
                    "--name",
                    spec["voice_name"],
                    "--prompt-file",
                    str(prompt_file),
                    "--out",
                    str(create_dir),
                    "--key-file",
                    str(key_file),
                ],
                capture_output=True,
                text=True,
            )
            if proc.returncode != 0 or not (create_dir / "voice.json").exists():
                log(f"[FAIL CREATE {tag}] exit={proc.returncode} out={proc.stdout.strip()}")
                return {"kind": "candidate", "tag": tag, "ok": False, "stage": "create_failed", "stdout": proc.stdout.strip()}
            shutil.copy2(create_dir / "voice.json", top_voice_json)
            shutil.copy2(create_dir / "request.json", actor_dir / "request.json")
            vid = json.loads(top_voice_json.read_text(encoding="utf-8"))["id"]
            log(f"[CREATED {tag}] -> {vid}")

    # Skip if already passed unless force_render=true
    if (
        not spec.get("force_render", False)
        and (actor_dir / "sample_result.json").exists()
        and (actor_dir / "audition.wav").exists()
    ):
        prev = json.loads((actor_dir / "sample_result.json").read_text(encoding="utf-8"))
        if prev.get("technical_pass"):
            log(f"[SKIP {tag}] already technical_pass=True")
            return {"kind": "candidate", "tag": tag, "ok": True, "skipped": True, "summary": prev}

    # 2. Render GPT-Live audition (bounded take retries reusing same voice.json)
    max_takes = max(1, min(int(spec.get("max_takes", 2)), 3))
    base_seconds = float(spec.get("seconds", 14))
    language = spec.get("language", "Japanese")
    take_prefix = spec.get("take_prefix", "sample_take")
    chosen_take: Path | None = None

    for take_idx in range(1, max_takes + 1):
        take_dir = actor_dir / f"{take_prefix}{take_idx}"
        if take_dir.exists():
            res_p = take_dir / "result.json"
            if res_p.exists():
                res = json.loads(res_p.read_text(encoding="utf-8"))
                chosen_take = take_dir
                if res.get("technical_pass"):
                    break
            continue

        direction = spec["sample_direction"]
        secs = base_seconds
        if take_idx > 1:
            direction = direction + " Enunciate every syllable clearly and remain silent immediately after finishing."
            secs = min(60.0, base_seconds + 2.0)

        proc = subprocess.run(
            [
                sys.executable,
                str(VOICE_PY),
                "render",
                "--voice-json",
                str(top_voice_json),
                "--text-file",
                str(text_file),
                "--language",
                language,
                "--direction",
                direction,
                "--seconds",
                str(secs),
                "--out",
                str(take_dir),
                "--key-file",
                str(key_file),
            ],
            capture_output=True,
            text=True,
        )
        res_p = take_dir / "result.json"
        if not res_p.exists():
            log(f"[FAIL RENDER {tag} take{take_idx}] exit={proc.returncode} out={proc.stdout.strip()}")
            break
        res = json.loads(res_p.read_text(encoding="utf-8"))
        chosen_take = take_dir
        if res.get("technical_pass"):
            break
        if any(e.get("type") == "APIError" for e in res.get("errors", [])):
            break

    if chosen_take is None or not (chosen_take / "raw.wav").exists():
        return {"kind": "candidate", "tag": tag, "ok": False, "stage": "render_missing_wav"}

    audition_wav = actor_dir / "audition.wav"
    raw_top_wav = actor_dir / "audition_raw.wav"
    trim_info = trim_wav_silence(chosen_take / "raw.wav", audition_wav)
    shutil.copy2(chosen_take / "raw.wav", raw_top_wav)
    shutil.copy2(chosen_take / "request.json", actor_dir / "sample_request.json")
    shutil.copy2(chosen_take / "events.json", actor_dir / "sample_events.json")

    metrics = measure_wav_metrics(audition_wav)
    voice_doc = json.loads(top_voice_json.read_text(encoding="utf-8"))
    res = json.loads((chosen_take / "result.json").read_text(encoding="utf-8"))
    sample_res = dict(res)
    sample_res.update(
        {
            "sample_file": "audition.wav",
            "raw_file": "audition_raw.wav",
            "source_take": chosen_take.name,
            "trim_start_seconds": trim_info["trim_start_seconds"],
            "trim_end_seconds": trim_info["trim_end_seconds"],
            "sample_duration_seconds": trim_info["trimmed_duration_seconds"],
            "sample_sha256": trim_info["sha256"],
            "acoustic_metrics": metrics,
        }
    )
    (actor_dir / "sample_result.json").write_text(
        json.dumps(sample_res, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    display_name = spec.get("display_name", actor_id)
    zh_desc = spec.get("zh_desc", "原创角色声线")
    tx_note = (
        "API 返回转写与请求逐字一致"
        if res.get("transcript_exact_match")
        else f"API 返回转写「{res.get('transcript', '')}」（与请求存在标点／假名细微差异）"
    )
    readme = "\n".join(
        [
            f"# {display_name}（`{actor_id}`）日语声线候选 {ver}",
            "",
            f"- 角色：{display_name}（`{actor_id}`）。声线设计方向：{zh_desc}。",
            f"- OpenAI 原创 prompt voice：`{voice_doc['id']}`，真实 API 返回值见 `voice.json`。创建一次，确认通过后复用，不重复创建。",
            f"- AI 生成试听：`audition.wav`（时长 {trim_info['trimmed_duration_seconds']:.2f}s，中位基频 `F0={metrics['f0_median_hz']}Hz`，高频清晰度 `{metrics['hf_clarity']}`，峰值 `{metrics['peak_dbfs']} dBFS`），台词「{res['text_requested']}」；{tx_note}。原始 24kHz 单声道 16-bit PCM 流封装见 `audition_raw.wav`（及 `{chosen_take.name}/`）。试听仅修剪首尾静音，未调音高、变速或加滤波。",
            "- `request.json` 保存声线创建请求；`sample_request.json` 保存 GPT-Live 会话配置；`sample_events.json` 保存非音频事件与最终用量；`sample_result.json` 保存校验和及状态。",
            "- 状态：技术检查记录见 `sample_result.json`，**主观音色待用户试听确认；尚未接入游戏运行目录**。密钥仅从本机仓库外私有文件读取，未写入仓库。",
            "",
        ]
    )
    (actor_dir / "README.md").write_text(readme, encoding="utf-8")
    log(
        f"[DONE CANDIDATE {tag}] id={voice_doc['id']} pass={res.get('technical_pass')} "
        f"F0={metrics['f0_median_hz']}Hz hf={metrics['hf_clarity']} peak={metrics['peak_dbfs']}dBFS"
    )
    return {
        "kind": "candidate",
        "tag": tag,
        "ok": bool(res.get("technical_pass")),
        "voice_id": voice_doc["id"],
        "audition_wav": str(audition_wav.relative_to(REPO_ROOT)) if audition_wav.is_relative_to(REPO_ROOT) else str(audition_wav),
        "metrics": metrics,
        "sha256": trim_info["sha256"],
    }


def run_clip_item(clip: dict, key_file: Path, dry_run: bool, work_dir: Path) -> dict:
    clip_id = clip["clip_id"]
    voice_json = resolve_repo_path(clip["voice_json"])
    if not voice_json.exists():
        return {"kind": "clip", "clip_id": clip_id, "ok": False, "stage": "missing_voice_json", "voice_json": str(voice_json)}

    out_dir = resolve_repo_path(clip["out_dir"])
    final_name = clip.get("final_wav_name", f"{clip_id}.wav")
    text_file = work_dir / f"clip_{clip_id}.txt"
    text_file.write_text(clip["text"].rstrip("\r\n") + "\n", encoding="utf-8")
    language = clip.get("language", "Japanese")
    base_direction = clip.get("direction", "Natural, clear and composed. No music or background noise.")
    base_seconds = float(clip.get("seconds", 12))

    if dry_run:
        dry_out = work_dir / f"dry_clip_{clip_id}"
        if dry_out.exists():
            shutil.rmtree(dry_out)
        proc = subprocess.run(
            [
                sys.executable,
                str(VOICE_PY),
                "render",
                "--voice-json",
                str(voice_json),
                "--text-file",
                str(text_file),
                "--language",
                language,
                "--direction",
                base_direction,
                "--seconds",
                str(base_seconds),
                "--out",
                str(dry_out),
                "--dry-run",
            ],
            capture_output=True,
            text=True,
        )
        ok = proc.returncode == 0 and (dry_out / "request.json").exists()
        log(f"[DRY CLIP {clip_id}] ok={ok}")
        return {"kind": "clip", "clip_id": clip_id, "ok": ok, "dry_run": True}

    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / ".gdignore").write_text("", encoding="utf-8")
    final_wav = out_dir / final_name
    summary_json = out_dir / "clip_result.json"

    if not clip.get("force_render", False) and final_wav.exists() and summary_json.exists():
        prev = json.loads(summary_json.read_text(encoding="utf-8"))
        if _take_passes(prev, clip["text"]):
            log(f"[SKIP CLIP {clip_id}] already passed")
            return {"kind": "clip", "clip_id": clip_id, "ok": True, "skipped": True, "summary": prev}

    max_takes = max(1, min(int(clip.get("max_takes", 2)), 5))
    chosen_take: Path | None = None
    for take_idx in range(1, max_takes + 1):
        take_dir = out_dir / f"take{take_idx}"
        if take_dir.exists():
            res_p = take_dir / "result.json"
            if res_p.exists():
                res = json.loads(res_p.read_text(encoding="utf-8"))
                chosen_take = take_dir
                if _take_passes(res, clip["text"]):
                    break
            continue

        direction = base_direction
        secs = base_seconds
        if take_idx > 1:
            direction = direction + " Enunciate every syllable clearly and remain silent immediately after finishing."
            secs = min(60.0, base_seconds + 2.0)

        proc = subprocess.run(
            [
                sys.executable,
                str(VOICE_PY),
                "render",
                "--voice-json",
                str(voice_json),
                "--text-file",
                str(text_file),
                "--language",
                language,
                "--direction",
                direction,
                "--seconds",
                str(secs),
                "--out",
                str(take_dir),
                "--key-file",
                str(key_file),
            ],
            capture_output=True,
            text=True,
        )
        res_p = take_dir / "result.json"
        if not res_p.exists():
            log(f"[FAIL CLIP {clip_id} take{take_idx}] exit={proc.returncode} out={proc.stdout.strip()}")
            break
        res = json.loads(res_p.read_text(encoding="utf-8"))
        chosen_take = take_dir
        if _take_passes(res, clip["text"]):
            break
        if any(e.get("type") == "APIError" for e in res.get("errors", [])):
            break

    if chosen_take is None or not (chosen_take / "raw.wav").exists():
        return {"kind": "clip", "clip_id": clip_id, "ok": False, "stage": "render_missing_wav"}

    trim_info = trim_wav_silence(chosen_take / "raw.wav", final_wav)
    shutil.copy2(chosen_take / "raw.wav", out_dir / "raw.wav")
    shutil.copy2(chosen_take / "request.json", out_dir / "request.json")
    shutil.copy2(chosen_take / "events.json", out_dir / "events.json")

    metrics = measure_wav_metrics(final_wav)
    res = json.loads((chosen_take / "result.json").read_text(encoding="utf-8"))
    passed = _take_passes(res, clip["text"])
    clip_res = dict(res)
    clip_res.update(
        {
            "clip_id": clip_id,
            "final_file": final_name,
            "source_take": chosen_take.name,
            "transcript_normalized_match": passed,
            "trim_start_seconds": trim_info["trim_start_seconds"],
            "trim_end_seconds": trim_info["trim_end_seconds"],
            "trimmed_duration_seconds": trim_info["trimmed_duration_seconds"],
            "final_sha256": trim_info["sha256"],
            "acoustic_metrics": metrics,
        }
    )
    summary_json.write_text(json.dumps(clip_res, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    log(
        f"[DONE CLIP {clip_id}] pass={passed} dur={trim_info['trimmed_duration_seconds']:.2f}s "
        f"F0={metrics['f0_median_hz']}Hz peak={metrics['peak_dbfs']}dBFS"
    )
    return {
        "kind": "clip",
        "clip_id": clip_id,
        "ok": passed,
        "final_wav": str(final_wav.relative_to(REPO_ROOT)) if final_wav.is_relative_to(REPO_ROOT) else str(final_wav),
        "metrics": metrics,
        "sha256": trim_info["sha256"],
    }


def cmd_run(args: argparse.Namespace) -> int:
    job_path = Path(args.job_file).resolve()
    job = json.loads(job_path.read_text(encoding="utf-8"))
    dry_run = bool(args.dry_run or job.get("dry_run", False))
    workers = max(1, min(int(job.get("workers", 2)), 3))
    key_file = Path(job.get("key_file") or DEFAULT_KEY_FILE).expanduser()

    if not dry_run:
        if not key_file.exists():
            log(f"[MISSING KEY FILE] {key_file}")
            return 2
        if not check_network():
            return 3

    candidates = job.get("candidates", [])
    clips = job.get("clips", [])
    total = len(candidates) + len(clips)
    if total == 0:
        log("[EMPTY JOB] Neither 'candidates' nor 'clips' found in job JSON.")
        return 2

    log(f"Running voice job {job_path.name}: {len(candidates)} candidate(s), {len(clips)} clip(s), dry_run={dry_run}, workers={workers}")
    results: list[dict] = []
    with tempfile.TemporaryDirectory(prefix="hoshimi-voice-work-") as tmp:
        work_dir = Path(tmp)
        tasks = [("candidate", item) for item in candidates] + [("clip", item) for item in clips]
        if dry_run or workers <= 1 or len(tasks) == 1:
            for kind, item in tasks:
                if kind == "candidate":
                    results.append(run_candidate_item(item, key_file, dry_run, work_dir))
                else:
                    results.append(run_clip_item(item, key_file, dry_run, work_dir))
        else:
            with ThreadPoolExecutor(max_workers=workers) as pool:
                futs = [
                    pool.submit(
                        run_candidate_item if kind == "candidate" else run_clip_item,
                        item,
                        key_file,
                        dry_run,
                        work_dir,
                    )
                    for kind, item in tasks
                ]
                for fut in as_completed(futs):
                    results.append(fut.result())

    report_out = job.get("report_out")
    ok_count = sum(1 for r in results if r.get("ok"))
    report = {
        "job_file": str(job_path),
        "dry_run": dry_run,
        "total": total,
        "ok_count": ok_count,
        "all_ok": ok_count == total,
        "results": results,
    }
    if report_out:
        rp = resolve_repo_path(report_out)
        rp.parent.mkdir(parents=True, exist_ok=True)
        rp.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    log(f"SUMMARY: {ok_count}/{total} succeeded.")
    return 0 if ok_count == total else 2


def cmd_metrics(args: argparse.Namespace) -> int:
    rows = []
    for raw in args.wav_files:
        p = resolve_repo_path(raw)
        m = measure_wav_metrics(p)
        m["file"] = str(raw)
        rows.append(m)
    print(json.dumps(rows if len(rows) > 1 else rows[0], ensure_ascii=False, indent=2))
    return 0


def cmd_passthrough(mode: str, extra_args: list[str]) -> int:
    cmd = [sys.executable, str(VOICE_PY), mode] + extra_args
    if "--dry-run" not in extra_args and "--key-file" not in extra_args and "--help" not in extra_args and "-h" not in extra_args:
        cmd.extend(["--key-file", str(DEFAULT_KEY_FILE)])
    proc = subprocess.run(cmd)
    return proc.returncode


def main() -> int:
    if len(sys.argv) >= 2 and sys.argv[1] in ("create", "render"):
        return cmd_passthrough(sys.argv[1], sys.argv[2:])

    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="subcommand", required=True)

    p_run = sub.add_parser("run", help="Execute a JSON voice job (candidates and/or clips).")
    p_run.add_argument("job_file", help="Literal path to job JSON file prepared in sandbox.")
    p_run.add_argument("--dry-run", action="store_true", help="Validate job & write requests offline without reading key or calling network.")

    p_met = sub.add_parser("metrics", help="Measure offline acoustic metrics (F0, HF clarity, peak dBFS) for WAV files.")
    p_met.add_argument("wav_files", nargs="+", help="One or more 16-bit PCM WAV files.")

    args = parser.parse_args()
    if args.subcommand == "run":
        return cmd_run(args)
    if args.subcommand == "metrics":
        return cmd_metrics(args)
    return 2


if __name__ == "__main__":
    sys.exit(main())
