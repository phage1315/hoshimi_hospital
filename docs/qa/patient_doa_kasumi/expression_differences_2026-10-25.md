# Kasumi SFW expression-difference pass

Date: 2026-10-25

## Scope

Generated 11 requested portrait differences using the accepted Kasumi base images as identity/composition references and the built-in ImageGen tool. Existing base files were not overwritten.

| Runtime key | Project asset | Canvas / alpha | SHA-256 |
|---|---|---|---|
| `ward/smile` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/ward/smile.png` | 1024×1536 RGBA | `bfc9326111f254ed21fcbdf8b4f31f79920a198b8e61f2622123efaa7a2db83b` |
| `ward/brave` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/ward/brave.png` | 1024×1536 RGBA | `0d86e328cd96961d9773c5d50f18e2323f2f94e173a28e05af9f25dc922f6da4` |
| `ward/worried` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/ward/worried.png` | 1024×1536 RGBA | `85bbc30e175bdf29bbffc58dd3f0279d7161cddb542446950e6bb43ddf7af855` |
| `ward/afraid` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/ward/afraid.png` | 1024×1536 RGBA | `ba63cc12f55e5eb6bb342dab8915824ab33541cb18a724bf2749a221c0c61440` |
| `ward/crying` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/ward/crying.png` | 1024×1536 RGBA | `b9fc7a2bde7245d6c65735e1ccd053c6b557d3dd690911a1463e7c1492f90d2c` |
| `operating_table/tense` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/operating_table/tense.png` | 941×1672 RGB | `7707951f77aa5a06c7b5fb4b3911de44e7e202286212034ffc7c9c7495bf9fae` |
| `operating_table/afraid` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/operating_table/afraid.png` | 941×1672 RGB | `573aa1579a1d0aa748366a9c903e7f41d9782e8e67ea0e16ed6ce1e2e4ea7928` |
| `operating_table/anesthetized` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/operating_table/anesthetized.png` | 941×1672 RGB | `07f209382aedf19192ff5e6f0c90a52dd7c3487748b9882fccce6e9cef856f1a` |
| `intraoperative/pain` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/intraoperative/pain.png` | 1672×941 RGBA | `7f0390bea2b8e7be959ff4be9034817f22f2722ff8ff4b1fc88294b89da7c14e` |
| `intraoperative/near_collapse` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/intraoperative/near_collapse.png` | 1672×941 RGBA | `45ab2f32fba240665072fd62fbb5faea0c92d8a98b71db381bf56bec3ee5235d` |
| `intraoperative/anesthetized` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/intraoperative/anesthetized.png` | 1672×941 RGBA | `b51c8b744d6e1219d05e8c58afb955f7f9e36e06824a96b6f24ffdfa9e0206a9` |

## Visual checks

- Ward differences keep the accepted standing pose, gown, hair, scale and transparent cutout; the five expressions are visually distinguishable. Ward images were composited on white for edge/halo inspection.
- Supine table differences keep the corrected vertical composition (head at top, feet at bottom), elastic surgical cap, table layout and opaque teal drape; only the expression/state changes.
- Intraoperative avatars keep the same cap, face framing and bare-shoulder crop. Transparent edges were checked over both white and dark backgrounds; no visible halo or stray background remains.

## Unfilled slots

- `operating_table_lithotomy/{awake,tense,afraid,anesthetized}` remain unfilled. The initial generation request for a fully draped SFW lithotomy base was rejected by the built-in image-generation safety system. No alternate prompt was used to bypass that rejection and no unrelated image was mapped into these slots.
- `examination/shy` remains outside this pass because the user said optional NSFW material would be supplied later.
- Optional `splash/general_anesthesia` was not requested.

## Verification

- `python3 tools/patient_data_import_test.py patient_doa_kasumi`: passed.
- `python3 tools/validate_data.py`: passed, 925 records/schema/reference/graph checks.
- All 15 currently mapped patient portraits resolve to readable image files. The four images created in the earlier base pass plus these 11 differences are registered in `data/patients/patient_doa_kasumi/patient.json`.
- Godot runtime/import validation was not run because no Godot executable is available in this environment.
- The previously reported English localization gap is unchanged; this art-only pass did not translate or edit authored text.


## Follow-up: lithotomy set completed (2026-10-26)

The user accepted the four supplied lithotomy images as the usable base set and requested the second image be edited into a tense expression. The first image maps to `awake`; the generated tense image maps to `tense`; supplied image 3 maps to `afraid`; supplied image 4 maps to `anesthetized`. Only the facial expression was requested to change for `tense`; body, pose, drape, supports, camera, lighting, and room remain matched to the base.

| Runtime key | Final asset | Canvas / color | SHA-256 | Source / check |
|---|---|---|---|---|
| `operating_table_lithotomy/awake` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/operating_table_lithotomy/awake.png` | 1448×1086 RGB | `24492c4e3f7ed2f7081e3a6f16d8b6160a0676ad609b77dec8a7d96279fd4004` | User-supplied image 1; accepted by user. |
| `operating_table_lithotomy/tense` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/operating_table_lithotomy/tense.png` | 1448×1086 RGB | `d9b231764f28ec18d989daab8e3496f980a92ea1a969be90dd587dff10064a3d` | ImageGen edit of user-supplied image 2; expression-only tense change; reviewed. |
| `operating_table_lithotomy/afraid` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/operating_table_lithotomy/afraid.png` | 1448×1086 RGB | `4862a371b1c3b7ebe987c24e0877cf552455d9d0b50c774e4f8eb2546af835c6` | User-supplied image 3; accepted by user. |
| `operating_table_lithotomy/anesthetized` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/operating_table_lithotomy/anesthetized.png` | 1448×1086 RGB | `965719c4ad112a9c85b6978db630f76411609ac2c43150a2dc2fb3c64c603d27` | User-supplied image 4; accepted by user. |

All four mapped assets are RGB, opaque PNGs at the class target size. The set is now complete. Earlier unfilled-slot notes above describe the state before this follow-up.
