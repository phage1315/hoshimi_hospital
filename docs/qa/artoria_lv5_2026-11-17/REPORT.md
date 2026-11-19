# QA Report — Artoria Pendragon (`doc_artoria`) Relationship Lv5《我的位置》 (`artoria_lv5_my_position`, V1.1)

- **Date**: 2026-11-17
- **Renderer / Display**: Godot `4.5.1.stable`, `OpenGL API 4.1 Metal - 88.1 - Compatibility` (`Apple M2`, `display=macOS`, visible `1280×800` native window, no `--headless`)
- **Driver**: `tools/artoria_lv5_preview_capture.gd` (synthetic GUI mouse clicks via `root.push_input`, entering formally through Hospital Map button `Location_artoria_office` at `09:00`)

## Execution Summary

- **Native Window Playtest (`artoria_lv5_preview_capture.gd`)**:
  - `5435 checks; 0 failure(s); 1082 GUI clicks; 28 screenshots`
  - Traversed 3 full Chinese playthroughs (`a-a-a` Monday `Day 21 -> Wed Day 23 09:00`, `b-b-b` Thursday `Day 17 -> Sat Day 19 09:00`, `c-a-c` Monday `Day 21 -> Wed Day 23 09:00`) and 2 full English playthroughs (`a-a-a`, `b-b-c`).
  - Verified `locks_saving == true` throughout every node, zero portrait-face overlap on full-width `1100×54` choice menus, zero CJK leaks in English text/speakers, RGBA transparency on all 4 Aoi Tohsaka portraits (`ward/{neutral,smile}`, `or_cap/{calm,smile}`), bespoke `1376×768` evening 4F surgical observation-window corridor background (`artoria_lv5_or_corridor_evening`), and atomic settlement to `Lv5` (`artoria_lv5_complete = true`) at `Day T+2 09:00`.
- **Verbatim Source & Static Localization Audits**:
  - `tools/artoria_lv5_source_audit.py`: `17359 checks; 0 failure(s)` (all `3 × 2 × 3 = 18` choice paths verified verbatim against `HOSHIMI_ARTORIA_LV5_MY_POSITION_V1_1.md`).
  - `tools/narrative_localization_test.py`: `55546 checks; 0 failure(s)`.
  - `tools/localization_audit.py`: `91536 translations; UI 845/845; 0 hard-coded Chinese candidates`.
  - `tools/staff_localization_test.py`: `1209` isolated staff lines verified.

## Captured Screenshots (28 PNGs)

- `01_zh_map_artoria_office_badge.png` — Hospital Map (`Day 21 09:00`) with story-event badge on `13 副部长办公室`
- `02_zh_s1_shared_office_moe_ange_notes.png` — Act 1 surgical doctors' office: Moe & Anji submitting mentorship notebooks
- `03_zh_s1_hiroko_one_slot_rule.png` — Act 1 Hiroko explaining the single one-on-one scrub mentorship slot
- `04_zh_s2_deputy_office_sakaguchi_kun.png` — Act 2.1 private discussion in Artoria's office
- `05_zh_s2_co_signing_moe_selection.png` — Act 2.1 co-signing Moe Honjo's mentorship selection
- `06_zh_s2_choice1_menu.png` — Choice 1 (`ar5_choice_c1`) full-width 3-option menu
- `07_zh_s2_2_nurses_station_moe_selected.png` — Act 2.2 consultation room announcement
- `08_zh_s2_2_ange_composure.png` — Act 2.2 Anji Tonegawa maintaining professional composure
- `09_zh_s3_1_ward_aoi_tohsaka_neutral.png` — Act 3.1 surgical ward pre-op check with Aoi Tohsaka (`ward/neutral`)
- `10_zh_s3_1_ward_aoi_tohsaka_smile.png` — Act 3.1 Aoi Tohsaka (`ward/smile`) entrusting herself to Artoria's team
- `11_zh_s3_2_or_epidural_aoi_calm.png` — Act 3.2 OR 1 high thoracic epidural placement (`aoi_tohsaka/or_cap/calm` + `doc_artoria/scrubs_masked/focused`)
- `12_zh_s3_2_or_timeout_priorities.png` — Act 3.2 pre-incision surgical timeout priorities
- `13_zh_s4_or_aoi_awake_reassured.png` — Act 4 awake intraoperative reassurance under T4 epidural block
- `14_zh_s4_choice2_menu.png` — Choice 2 (`ar5_choice_c2`) intraoperative first-assistant exposure menu
- `15_zh_s4_hepp_couinaud_6_0_anastomosis.png` — Act 4 Hepp-Couinaud left hepatic duct spatulation & 6-0 hepaticojejunostomy
- `16_zh_s4_aoi_post_anastomosis_gratitude.png` — Act 4 Aoi Tohsaka (`or_cap/smile`) expressing gratitude behind the sterile drape
- `17_zh_s5_1_holding_ange_honest_question.png` — Act 5.1 outer OR supply room: Anji's candid question
- `18_zh_s5_1_ange_coordinator_resolve.png` — Act 5.1 Anji receiving the handwritten perioperative coordinator plan
- `19_zh_s5_2_office_tea_my_position.png` — Act 5.2 private black tea reflection on `"我的位置"`
- `20_zh_s6_evening_corridor_observation_window.png` — Act 6 bespoke evening 4F surgical observation-window corridor
- `21_zh_s6_lying_on_the_table_next_time.png` — Act 6 Artoria imagining lying on the operating table next time
- `22_zh_s6_choice3_menu.png` — Choice 3 (`ar5_choice_c3`) epilogue response menu
- `23_zh_event_complete_day_plus_2_0900.png` — Chinese completion screen (`Day 23 09:00`, `Lv.5`)
- `24_en_map_artoria_office_badge.png` — English Hospital Directory (`Day 21 09:00`) with badge on `13 Deputy Director's Office`
- `25_en_s3_1_ward_aoi_tohsaka_smile.png` — English Act 3.1 ward pre-op check (`My Place`)
- `26_en_s4_choice2_menu.png` — English Choice 2 intraoperative menu
- `27_en_s6_evening_corridor_epilogue.png` — English Act 6 evening corridor epilogue
- `28_en_event_complete_day_plus_2_0900.png` — English completion screen (`Day 23 Wednesday 09:00`, `Lv.5`)

## Uncovered Scope

- Automated synthetic GUI mouse clicks (`root.push_input`) do not substitute for manual physical keyboard/mouse playtesting by the user.
- Three CG intervals (`ar5_s6_05..08`, `ar5_s4m_06..11`, `ar5_s5_1_15..22`) are intentionally left as documented placeholders in `data/staff/doc_artoria/cg_mapping.json` for Codex illustration per user instruction.
