# Patient Lust — SFW base review

## Rejected first attempt

The first four images were rejected by the user. They were moved out of runtime asset paths and their portrait mappings were cleared; no files were deleted. Reasons confirmed against the project portrait matrix: outpatient and ward framing did not match the thigh/knee portrait class; the ward gown/pose drifted; the operating-table image was a head-and-shoulders scene instead of a full overhead table; the intraoperative portrait was a scene with an opaque background instead of a transparent head-and-shoulders cutout.

## Candidate base batch 02 — approved and runtime-integrated

Identity reference for every key: `research/character_references/patient_lust_actress/user_seeds/seed_01.png`.
Composition references: corresponding `patient_ann_v1` outpatient, ward, supine-table, and `intraoperative_portraits_v1/patient_ann/tense.png` images. Identity/style comes from the user's seed; the patient-ann files were used only for class framing and pose.

| Key | Candidate | Visual review | Technical review | SHA-256 |
|---|---|---|---|---|
| `outpatient/neutral` | `candidate_base_02/outpatient_neutral.png` | Pass for identity, black off-shoulder outfit, and head-to-thigh portrait crop; generated pose follows the project portrait reference. | 1024×1536 RGBA; actual alpha channel present; all four corners alpha 0. Light/dark composite inspection passed. | `096f86fa748ee744ee1c97226ca5905379c3587dc5b11433470c6e57c7693a72` |
| `ward/neutral` | `candidate_base_02/ward_neutral.png` | Pass for identity, relaxed arms, light-blue wrap gown, side ties, covered shoulders, and head-to-thigh crop. | 1024×1536 RGBA; actual alpha channel present; all four corners alpha 0. Light/dark composite inspection passed. | `7a25f65b83d0021cc69e7b404c6e0b13c38bbeba717d039c18b6b4c6596fefce` |
| `operating_table/awake` | `candidate_base_02/operating_table_awake_v2.png` | User approved the revised smaller head/cap proportion; preserves overhead 4:3 full-table orientation, head at top/feet at bottom, visible limbs, teal cap, and opaque drape covering chest through thighs; no gown or mask. | 1448×1086 RGB. | `ffca37cfc52620c6d28d55610d82b951bc905858acc47b8164e847995e7a071c` |
| `intraoperative/tense` | `candidate_base_02/intraoperative_tense_v2.png` | Pass for centered frontal head/shoulders, cap, collarbone crop, tense expression, and no scene objects. | 1448×1086 RGBA; actual alpha channel present. Light/dark composite inspection not completed. | `a0378487f01ab447210dcfd435a07294cdf73807b5e530d47dd0da0a5f0c4089` |

The earlier off-size intraoperative render remains preserved as `candidate_base_02/intraoperative_tense.png` for audit; v2 is the correctly sized review candidate.

The original full-table candidate remains preserved as `candidate_base_02/operating_table_awake.png` for comparison; v2 is integrated at `assets/characters/patient_lust_actress/operating_table/awake.png`.

Prompts were separately tailored to each key and supplied both the user's identity seed and its matching patient-ann class reference. All four user-approved bases and all required SFW expression variants are integrated at matching runtime paths under `assets/characters/patient_lust_actress/` and mapped in `patient.visuals.portraits`; the complete mapped set contains 16 keys. Transparent outpatient, ward, and intraoperative assets passed light/dark composite inspection. Expression-by-expression visual and technical evidence is recorded in `sfw_expression_review_2026-10-26.md`. The assigned appendix surgery uses the supine position, so no lithotomy variants are applicable. Godot CLI is unavailable here, so `tools/portrait_test.gd` could not be run; static data validation and patient import validation passed.
