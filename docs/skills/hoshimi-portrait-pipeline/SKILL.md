---
name: hoshimi-portrait-pipeline
description: >-
  Standard workflow for generating, creating expression variants, and locally
  removing backgrounds (transparentizing) for SFW and NSFW character/patient
  portraits in Hoshimi Hospital. Use whenever creating new character or patient
  portraits, generating expression variants, or removing backgrounds from
  user-supplied non-transparent SFW/NSFW portrait art.
---

# Hoshimi Hospital Portrait Generation, Variants & Local Matting Pipeline

Always read root [AGENTS.md](../../../AGENTS.md) and [portrait_import_standard.md](../../portrait_import_standard.md) first. All transparency matting runs **100% offline** via [portrait_matting.py](../../../tools/portrait_matting.py) using the local ONNX models in `.venv/models/` (`birefnet-toonout-fp16.onnx` default, `isnetis.onnx` backup).

**Strict prohibition:** Never use naive color-threshold / flood-fill scripts to remove portrait backgrounds, and never upload user-supplied NSFW assets to cloud/third-party services.

---

## 1. Division of Labor: SFW vs. NSFW Portraits

| Asset Category | Base Image Source | Expression Variants Method | Transparency / Matting Method |
|---|---|---|---|
| **SFW Portraits** (staff, story guests, ordinary patients) | **Agent generates** non-transparent base (`neutral` / pose base) on a clean solid background and **waits for user confirmation** | **Drawing tool full-image generation** (pass confirmed base as reference; slight pixel shift between expressions is acceptable) | **Agent runs local ONNX CLI** (`tools/portrait_matting.py`) on confirmed base + all variants |
| **NSFW Portraits** (H-profile avatars, undressed/intimate states, patient `examination/*` or nude sprites) | **User supplies** non-transparent (or already transparent) source images | Drawing tool if compliant; **if the drawing tool refuses (e.g. NSFW content), use local facial modification / interior compositing** when user requests variants | **Agent runs local ONNX CLI** (`tools/portrait_matting.py`) strictly offline on non-transparent user images |

---

## 2. SFW Portrait Workflow (Two-Stage Gate)

### Stage 1: Generate Non-Transparent Base & Confirm
1. Determine required outfit/pose classes and framing:
   - Standard character / staff / outpatient / ward standing sprites: `2:3` vertical, head-to-waist/hip crop, target `1024×1536` RGBA ([portrait_import_standard.md](../../portrait_import_standard.md)).
   - Patient intraoperative head-and-shoulders sprites: `4:3`, target `1448×1086` RGBA ([portrait-matrix.md](../../../skills/generate-patient-portraits/references/portrait-matrix.md)).
   - Full-scene RGB classes (e.g. `operating_table/*`, `splash/*`) keep their full background and are **not** passed through matting.
2. Prompt the drawing tool (`image-generator` / ImageGen) for **one standalone image per base pose** (`neutral` or class base).
   - Request a **clean, flat, solid high-contrast background** (for white coats or white nurse uniforms, prefer soft cool gray `#DCE2EA` or pale slate rather than pure `#FFFFFF` so white lapels have crisp contrast). Never ask the generator to draw fake transparency checkerboards.
   - Archive raw generator outputs in `research/generated_candidates/<batch_id>/` with a `.gdignore` file.
3. **Stop and show the base image(s) to the user for approval** before generating dependent expression variants.

### Stage 2: Full-Image Expression Variants + Local Neural Matting
1. Once the user approves the base image, generate each required expression variant **directly with the drawing tool** using the approved non-transparent base image as the visual reference:
   - Instruct the drawing tool to keep identity, outfit, pose, camera crop, lighting, and solid background consistent while changing the facial expression.
   - **Do NOT use local face-mask splicing (`Way A`) for normal SFW variants.** Generating full variants via the drawing tool avoids eye/bangs/head-tilt mask mismatches; minor 1–3 px body/hair drift across expression switches is accepted.
2. Run offline neural background removal on the base and every variant inside the sandbox:
   ```bash
   .venv/bin/python tools/portrait_matting.py \
     research/generated_candidates/<batch>/<expr>_raw.jpg \
     -o assets/characters/<target_dir>/<expr>.png \
     --target-size 1024x1536 \
     --resize-mode cover \
     --qa-sheet /private/tmp/<char>_<expr>_qa.png
   ```
   *(For `1448×1086` intraoperative RGBA portraits, pass `--target-size 1448x1086`.)*
3. Inspect the generated `--qa-sheet` PNG (dark `#161A22`, hospital teal `#2B4450`, and light `#F2EFE9` composites + 2× hair/coat zoom) and verify JSON output reports `"mode": "RGBA"` and `"top_corners_transparent": true`.
   - If a tricky background leaves a tiny artifact under `--model birefnet`, test `--model isnet` for comparison.
4. Ensure Godot `.png.import` for `1024×1536` sprites enables `mipmaps/generate=true` so downscaled stage rendering stays crisp without aliasing.

---

## 3. NSFW & User-Supplied Portrait Workflow

1. **Preserve originals & respect content boundaries (`AGENTS.md`)**:
   - Archive or reference the user's supplied file without altering the original.
   - Pure matting and technical integration do **not** authorize opening images for subjective content review or sending them to any external/cloud AI service.
2. **Offline background removal**:
   - Check format/mode/alpha technically (e.g. via PIL metadata). If the user-supplied portrait already has a clean RGBA alpha channel, copy it directly without re-matting.
   - If the user-supplied portrait is non-transparent (`RGB` or opaque `RGBA`), run `tools/portrait_matting.py` **locally offline**:
     - Default to `--resize-mode keep` so user-supplied framing/dimensions are never cropped without permission:
       ```bash
       .venv/bin/python tools/portrait_matting.py \
         <user_supplied_opaque.png> \
         -o <runtime_portrait_destination.png> \
         --resize-mode keep
       ```
     - Only resize to `1024x1536` (or slot-specific dimensions) when the target UI slot requires standardized dimensions or the user explicitly asks to standardize size.
3. **Fallback for tool-refused expression variants**:
   - **Only when the drawing tool refuses to process an image** (such as deriving expression variants for NSFW / undressed / H portraits) and the user explicitly requests variants:
     - Fall back to local image modification / interior facial compositing on top of the transparentized `neutral` base, locking outer silhouette alpha (`100%`) and verifying alignment at 2× zoom before delivery.

---

## 4. Verification Checklist Before Delivery

- Every runtime PNG exists, decodes cleanly in Godot (`--headless --editor --import --quit`), and matches expected RGBA mode and dimensions.
- Top corners are transparent (`top_corners_transparent: true`) and no white halo appears on dark backgrounds (`--decontaminate 0.85` default + mipmap RGB bleed).
- Record source paths, runtime paths, SHA-256 checksums, and update `docs/HANDOFF.md`.
