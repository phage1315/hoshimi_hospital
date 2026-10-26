# Patient Lust — SFW expression set review (2026-10-26)

## Scope and acceptance

- Patient: `patient_lust_actress` (拉丝特), project data age 29.
- Identity anchor: `user_seeds/seed_01.png`; class/composition references are the matching `patient_ann_v1` portrait references. Those references establish framing and pose only.
- User-approved base images remain the existing four mapped keys: outpatient neutral, ward neutral, supine operating-table awake, and intraoperative tense.
- This pass adds the full required SFW set for reachable portrait states: five additional ward expressions, three additional supine operating-table states, three additional intraoperative states, and the post-induction general-anesthesia splash CG. With the four bases, all 16 required keys are mapped.
- The patient is assigned `case_abdomen` / `surgery_appendix`, whose primary position is supine. Lithotomy portraits are therefore not part of this patient's reachable set. Pre-induction and epidural splash CGs are optional matrix entries and were not requested; the reachable post-induction general-anesthesia splash is included.
- Every generated expression is an independently generated full image from the matching class reference and the patient identity seed; no expression was composited by repainting the accepted base.

## Review checklist

For each state: identity/hair/face consistency; correct class framing; expression is distinct from neutral and neighboring states; no unintended clothing, cap, drape, background, or prop drift relative to its class; exact target dimensions; alpha channel and light/dark edge check where transparency is required; runtime mapping resolves to an existing file.

| Runtime key | New state / review note | Candidate evidence | Runtime file | Technical result | SHA-256 |
|---|---|---|---|---|---|
| `ward/smile` | Soft, controlled smile; distinct from neutral | `expression_batch_01/ward_smile.png` | `assets/characters/patient_lust_actress/ward/smile.png` | 1024×1536 RGBA; alpha bounds nonempty; transparent corners; light/dark composite pass | `2db70c50be49aa8cb6bdd21bf0eb6540b04942168fb2d0f1292e345773ed76f3` |
| `ward/brave` | Firm, composed resolve; straight mouth, not a smirk | `expression_batch_01/ward_brave.png` | `assets/characters/patient_lust_actress/ward/brave.png` | 1024×1536 RGBA; alpha bounds nonempty; transparent corners; light/dark composite pass | `0ea45fe1c220d62ee8d6675e39b4cf6f8fa5903f88769ff05ab64f221f8e8cfb` |
| `ward/worried` | Concerned brows and uncertain mouth | `expression_batch_01/ward_worried.png` | `assets/characters/patient_lust_actress/ward/worried.png` | 1024×1536 RGBA; alpha bounds nonempty; transparent corners; light/dark composite pass | `5cbfef0baded4dde1a956e04df0c67836c3fd28536340fd368e89ed6f071f6c7` |
| `ward/afraid` | Clear fear response, separate from worry | `expression_batch_01/ward_afraid.png` | `assets/characters/patient_lust_actress/ward/afraid.png` | 1024×1536 RGBA; alpha bounds nonempty; transparent corners; light/dark composite pass | `292e9a66ce1c0ab0e1dbe3617728544a9bc77eb37a903a196d571af3b1e7b7e4` |
| `ward/crying` | Tears and distressed expression | `expression_batch_01/ward_crying.png` | `assets/characters/patient_lust_actress/ward/crying.png` | 1024×1536 RGBA; alpha bounds nonempty; transparent corners; light/dark composite pass | `d34a4f4d70886bbe3b4c25ce5443900b2c70ef21a98d4da4be9a87bab2946d26` |
| `operating_table/tense` | Awake tension while preserving the approved overhead supine table composition | `expression_batch_01/operating_table_tense.png` | `assets/characters/patient_lust_actress/operating_table/tense.png` | 1448×1086 RGB | `101ca909c67cbff007645c58b48acf916c06449194c68bee34e0c5611417f124` |
| `operating_table/afraid` | Awake fear; same full-table camera, pose, cap, and draping | `expression_batch_01/operating_table_afraid.png` | `assets/characters/patient_lust_actress/operating_table/afraid.png` | 1448×1086 RGB | `b310f386161987d6531c2202a93eaa5740bd7dafa8633244e860b97823abb0d6` |
| `operating_table/anesthetized` | Eyes closed and relaxed; same full-table camera and covering | `expression_batch_01/operating_table_anesthetized.png` | `assets/characters/patient_lust_actress/operating_table/anesthetized.png` | 1448×1086 RGB | `da4fd144b7614c45cd214fdc5787dd88fe209399d8057b1613a07a2d2f43f5bc` |
| `intraoperative/pain` | Frontal head-and-shoulders pain expression; transparent cutout | `expression_batch_01/intraoperative_pain.png` | `assets/characters/patient_lust_actress/intraoperative/pain.png` | 1448×1086 RGBA; alpha bounds nonempty; transparent corners; light/dark composite pass | `42ca6f767e1099fbf3b52cc14521a3b149e5f80ec1e91d570632158b926ca15c` |
| `intraoperative/near_collapse` | Faint/near-collapse expression; transparent cutout | `expression_batch_01/intraoperative_near_collapse.png` | `assets/characters/patient_lust_actress/intraoperative/near_collapse.png` | 1448×1086 RGBA; alpha bounds nonempty; transparent corners; light/dark composite pass | `82f7247dad694c8c7468db857088ef62f9b02210a7b470c830cf2f7114a41c84` |
| `intraoperative/anesthetized` | Unconscious, eyes closed; transparent cutout | `expression_batch_01/intraoperative_anesthetized.png` | `assets/characters/patient_lust_actress/intraoperative/anesthetized.png` | 1448×1086 RGBA; alpha bounds nonempty; transparent corners; light/dark composite pass | `2821ee343e341127bd4fc1fbb03956e55c77f5f13b8e29526c81f894eaed9936` |
| `splash/general_anesthesia` | Post-induction full-color event CG; anesthetic mask/tube and draping align with the project reference | `expression_batch_01/splash_general_anesthesia.png` | `assets/characters/patient_lust_actress/splash/general_anesthesia.png` | 1672×941 RGB | `9fe1b22e8018c50ab9d94dc3516ab749c7fcedc7c46c64e20c3f7344edc3564f` |

## Corrections and verification limits

- The first `intraoperative/near_collapse` candidate had the wrong dimensions. It is preserved as `expression_batch_01/intraoperative_near_collapse_offsize.png` for audit and is not mapped. The correctly sized 1448×1086 candidate above is the integrated version.
- JSON parsing, `tools/validate_data.py`, and `tools/patient_data_import_test.py patient_lust_actress` pass. All 16 portrait paths resolve to readable images with expected dimensions and color modes.
- Transparent portrait edges were composited against light and dark backgrounds and visually checked. The operating-table and splash images are intentionally opaque.
- Godot CLI is not installed/available in this environment; `tools/portrait_test.gd` and in-engine texture loading were not run. This is the remaining runtime verification limitation.
