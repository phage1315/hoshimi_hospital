# Artoria Pendragon (`doc_artoria`) Staff-as-Patient V1.1 QA Report (2026-11-17)

## Scope
- **Character**: Artoria Pendragon (`doc_artoria`)
- **Manuscript**: `research/source_scripts/HOSHIMI_ARTORIA_STAFF_AS_PATIENT_DIALOGUES_CN_EN_V1_1.md` & `research/source_scripts/artoria_staff_patient_delivery_v1_1.json` (100% verbatim `zh_CN` & `en` V1.1 delivery)
- **Production Data Registered**:
  - `data/staff_patient_profiles.json` (`doc_artoria`: `required_completed_rank: 5`, `unlock_flags: ["staff_as_patient_program_authorized"]`, `dialogue_profile: "calm_analytical_reassurance"`, `invitation_lines` [3], `invitation_by_procedure` [all 32 surgeries], `ward_visit_opening` [4 beats], `stage_prompts.graphic_preop_question`, `reaction_lines` [28 total / 26 active], `reaction_variants` [13×2], `interaction_overrides` [50 pools / 106 actions])
  - `data/staff_patient_mischief_dialogue.json` (`doc_artoria`: `9×2` mischief reaction variants + `3×4` nurse `team_overrides` for `nurse_hiroko`, `nurse_ange`, `nurse_moe`)
  - `data/localization/zh_CN.json` & `data/localization/en.json`

## Static & Verbatim Audits
| Command | Result |
|---|---|
| `python3 tools/artoria_staff_patient_source_audit.py` | **462 checks; 0 failure(s)** |
| `python3 tools/narrative_localization_test.py` | **55,546 checks; 0 failure(s)** |
| `python3 tools/localization_audit.py` | **91,536 translations; UI 845/845; 0 hard-coded Chinese candidates** |
| `python3 tools/staff_localization_test.py` | **1,209 isolated staff dialogue lines translated** |
| `python3 tools/patient_bundle_localization_test.py` | **6,052 English entries; 0 failure(s)** |

## Godot 4.5.1 Headless Verification
| Script | Result |
|---|---|
| `tools/patient_sfw_asset_test.gd -- --kind staff --id doc_artoria` | **23 SFW required, 0 missing** |
| `tools/staff_patient_lv5_readiness_test.gd` | **1,420 checks; 0 failures; 4 registered (`doc_sayaka`, `doc_serika`, `nurse_yui`, `doc_artoria`), 24 preloaded** |
| `tools/artoria_staff_patient_test.gd` | **569 checks; 0 failure(s)** (100% -> 50% -> 0% XP ledger, mismatch/no-anesthesia 0 XP, self-exclusion, BoundarySave v37 purity) |
| `tools/advanced_staff_patient_test.gd` | **2,451 checks; 0 failures** (5 full 3-day episodes across all 4 registered heroines) |
| `tools/advanced_staff_patient_ui_test.gd` | **1,790 checks; 0 failures** |
| `tools/staff_patient_ui_test.gd` | **75 checks; 0 failure(s)** |
| `tools/artoria_lv5_test.gd` | **20,962 checks; 0 failure(s)** |
| `tools/boundary_save_test.gd` | **1,020 checks; 0 failures** |
| `tools/surgery_history_save_test.gd` | **1,064 checks; 0 failures** |
| `tools/localization_test.gd` | **33 checks; 0 failure(s)** |
| `tools/smoke_test.gd` | **0 failure(s)** |

## Native `1280×800` macOS Metal Synthetic-GUI Playtest
- **Driver**: Visible native macOS Metal window (`1280×800`, automated synthetic `root.push_input` / `viewport.push_input`, **not manual human clicking**)
- **Script**: `tools/artoria_staff_patient_preview_capture.gd`
- **Metrics**: **1,049 checks; 0 failure(s); 425 mouse clicks + 4 Space inputs; 55 screenshots** (`report.json`)
- **Routes Covered**:
  1. `zh_CN` Ordinary Staff-as-Patient (`surgery_open_major_liver_resection`, general anesthesia + manual ward preparation, 4-beat `ward_visit_opening`, OR splash, surgical steps, settlement & discharge)
  2. `zh_CN` Advanced 3-day Staff-as-Patient (`surgery_open_whipple` —《本人到场，但不允许指挥》: `consult` -> `staff_watch` -> `night` -> `dark` [`h_neutral` compact headshot] -> `after` -> Day 2 `abdominal.png` OR table + 7-member time-out -> full Whipple stages -> Day 3 `success` -> safe-boundary hospital map; plus technical `Texture2D` load checks on all 4 advanced poses `abdominal`, author-supplied `chest`, `lateral`, `prone`)
  3. `en` Ordinary Staff-as-Patient (`surgery_open_major_liver_resection`, epidural anesthesia + `anesthesia_sensory_test` + awake intraoperative V1.1 patient interaction prompt/choices, zero CJK)
  4. `en` Advanced 3-day Staff-as-Patient (`surgery_open_whipple` — `"Present in Person, Stripped of Command"`: `consult` -> `staff_skip` -> Day 2 OR table -> full Whipple stages -> Day 3 `success` -> safe-boundary hospital map, zero CJK)

## Open Optional Assets
- Standard 23 SFW patient art slots and author-supplied `advanced/chest.png` are 100% integrated and verified.
- Optional author-supplied NSFW slot `ward_preparation/shy` remains intentionally unfilled (`portrait_aliases: {"examination/shy": "ward_preparation/shy"}` stays inert until the user supplies `ward_preparation/shy`, with zero SFW placeholder substitution).
