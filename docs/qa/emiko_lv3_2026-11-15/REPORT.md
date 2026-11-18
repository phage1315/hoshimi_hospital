# Emiko Mido (`doc_emiko`) Lv3 V1.1 Native Window QA Report (2026-11-15)

- **Event ID**: `emiko_lv3_today_i_lead` (`《今天我主刀》` / `"Today, I Lead the Table"`)
- **Manuscript Source**: `research/source_scripts/HOSHIMI_MIDO_EMIKO_LV3_TODAY_I_LEAD_V1_1.md` (with user-authorized 27-year-old CABG patient revision)
- **Driver**: `tools/emiko_lv3_preview_capture.gd` (executed in real macOS Metal `1280×800` window, `DisplayServer.get_name() != "headless"`, isolated `/private/tmp/` save & preferences paths)
- **Result**: `EMIKO LV3 NATIVE PREVIEW: 129 checks; 0 failure(s)` (exit code `0`)
- **Log**: `/private/tmp/hoshimi-emiko-lv3-vermouth-native2.log`

## Captured Native Screenshots

| File | Node / Screen | Verification Target |
|---|---|---|
| `01_zh_progress_ui_artoria_unmet.png` | `office_relationship_detail` (`zh_CN`) | Non-spoiler cross-character hint (`推进相关院内经历`) before meeting `doc_artoria` |
| `02_zh_progress_ui_artoria_met.png` | `office_relationship_detail` (`zh_CN`) | Explicit Artoria acquaintance requirement once `doc_artoria` is met |
| `03_zh_scene1_sushi_bar_opening.png` | `em3_s1_05` (`zh_CN`) | New `emiko_lv3_sushi_bar_night` counter background + `casual/neutral` + hidden cross-night calendar header |
| `04_zh_scene1_yanagiba_clean.png` | `em3_s1_17` (`zh_CN`) | `casual/neutral` `"……漂亮。"` |
| `05_zh_scene1_surgeons_chef.png` | `em3_s1_34` (`zh_CN`) | Banter with Sushi Chef |
| `06_zh_scene1_director_ambition.png` | `em3_s1_44` (`zh_CN`) | Surgery director stance |
| `07_zh_scene1_probe_g_roster.png` | `em3_g_06` (`zh_CN`) | Default `G` assistant probe branch |
| `08_zh_scene1_choice1_wide.png` | `em3_choice_c1` (`zh_CN`) | Choice 1 full-width 3-option layout |
| `09_zh_scene1_cabg_invitation.png` | `em3_s1r_10` (`zh_CN`) | Next-morning 09:00 elective CABG first-assistant invitation |
| `10a_zh_scene2_patient_27yo_intro.png` | `em3_s2_03` (`zh_CN`) | 27-year-old Vermouth CABG patient (`or_cap/panicked`) solo introduction (`二十七岁的女患者躺在手术床中央……`) |
| `10_zh_scene2_moe_preinduction.png` | `em3_s2_06` (`zh_CN`) | `operating_room` duo: `or_cap/panicked` patient + `nurse_moe` (`scrubs/neutral`) |
| `10b_zh_scene2_patient_panicked_plea.png` | `em3_s2_08` (`zh_CN`) | `or_cap/panicked` patient + Emiko `scrubs_masked/neutral` preoperative fear |
| `11_zh_scene2_today_i_lead.png` | `em3_s2_16` (`zh_CN`) | `or_cap/panicked` patient + Emiko `scrubs_masked/focused` `"今天我主刀。你绝对不会死。"` |
| `11b_zh_scene2_patient_relieved_trust.png` | `em3_s2_25` (`zh_CN`) | `or_cap/relieved` patient + Emiko `scrubs_masked/neutral` tearful relief & trust |
| `11c_zh_scene2_moe_27yo_timeout.png` | `em3_s2_28` (`zh_CN`) | `or_cap/relieved` patient + `nurse_moe` timeout (`患者身份、二十七岁女性……`) |
| `12_zh_scene2_hiroko_timeout.png` | `em3_s2_30` (`zh_CN`) | `operating_room` duo: `nurse_hiroko` (`sterile/focused`) + Emiko `scrubs_masked/focused` |
| `12b_zh_scene2_patient_mask_induction.png` | `em3_s2_32` (`zh_CN`) | `or_cap/mask_drowsy` general anesthesia clear mask induction |
| `13_zh_scene3_lima_harvest.png` | `em3_s3_05` (`zh_CN`) | `sterile/focused` V2 sterile gown during LIMA harvest |
| `14_zh_scene3_choice2_wide.png` | `em3_choice_c2` (`zh_CN`) | Choice 2 full-width 3-option layout (LIMA-to-LAD anastomosis) |
| `15_zh_scene3_unspoken_sync.png` | `em3_c2a_04` (`zh_CN`) | `sterile/warm` `"……很好。"` |
| `16_zh_scene4_postop_dismissal.png` | `em3_s4_11` (`zh_CN`) | Unmasked `scrubs/focused` post-op dismissal (Lv4 foreshadowing) |
| `17_zh_scene4_closed_or_door.png` | `em3_s4_19` (`zh_CN`) | `or_entrance` with `hide_portrait: true` (sealed frosted-glass OR doors) |
| `18_zh_scene5_rv_geometry.png` | `em3_s5_18` (`zh_CN`) | `shared_doctors_office` `white_coat/serious` 3D RV expansion geometry |
| `19_zh_scene6_no_score_today.png` | `em3_s6_06` (`zh_CN`) | `white_coat/neutral` `"今天不打分。"` |
| `20_zh_scene6_blue_cabg_notebook.png` | `em3_s6_11` (`zh_CN`) | `white_coat/warm` `"你已经不是来参加考试的了。"` (private blue CABG binder) |
| `21_zh_scene6_choice3_wide.png` | `em3_choice_c3` (`zh_CN`) | Choice 3 full-width 3-option layout |
| `22_zh_scene6_dont_expect_me_to_yield.png` | `em3_s6r_02` (`zh_CN`) | `white_coat/smile` `"当然。别指望我让你。"` |
| `23_zh_complete_screen_1400.png` | `character_event_complete` (`zh_CN`) | Next-day `14:00` completion screen in `shared_doctors_office` with `white_coat/warm` & `Lv.3` |
| `24_zh_scene1_probe_o_sayaka_winter.png` | `em3_o_02` (`zh_CN`) | December `casual_winter` trench coat + `O` branch `"南条小夜香"` runtime substitution |
| `25_en_scene1_probe_s_artoria.png` | `em3_s_06` (`en`) | December `casual_winter` + English `S` branch (`Artoria` assistant probe), zero CJK |
| `26_en_scene2_today_i_lead.png` | `em3_s2_16` (`en`) | English `or_cap/panicked` + `scrubs_masked/focused` `"Today, I lead the table. You will not die."` |
| `26b_en_scene2_27yo_timeout.png` | `em3_s2_28` (`en`) | English `or_cap/relieved` + `nurse_moe` `"twenty-seven-year-old female"` timeout |
| `26c_en_scene2_mask_induction.png` | `em3_s2_32` (`en`) | English `or_cap/mask_drowsy` general anesthesia mask induction |
| `27_en_scene3_choice2_wide.png` | `em3_choice_c2` (`en`) | English Choice 2 full-width 3-option wrapping |
| `28_en_scene6_blue_cabg_notebook.png` | `em3_s6_11` (`en`) | English `"You aren't here taking an exam anymore."` |
| `29_en_complete_screen_1400.png` | `character_event_complete` (`en`) | English `14:00` completion screen (`DAY 249 / 2025.12.05 Friday 14:00`) |

## Boundary Note
This run verifies real `1280×800` Metal window rendering, portrait alpha/mipmaps, layout wrapping, zero `继续 ▷` button overlap, and UI transitions via automated scene driving; manual human mouse playthrough was not performed.
