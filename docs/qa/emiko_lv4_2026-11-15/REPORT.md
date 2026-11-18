# Emiko Mido (`doc_emiko`) Lv4 V1.1 Native Window QA Report (2026-11-15)

- **Event ID**: `emiko_lv4_emikos_secret` (`《御堂江美子的秘密》` / `"Emiko Mido's Secret"`)
- **Manuscript Source**: `research/source_scripts/HOSHIMI_MIDO_EMIKO_LV4_EMIKOS_SECRET_V1_1.md` (`SHA-256: e8080bb45477d56bea8bdde4f3842ffb483b82810c4847848d9efab69f8ddca9` — verified by `tools/emiko_lv4_source_audit.py`, including user-authorized 4 appearance/weekday revisions)
- **Driver**: `tools/emiko_lv4_preview_capture.gd` (executed in real macOS Metal `1280×800` window, `DisplayServer.get_name() != "headless"`, isolated `/private/tmp/` save & preferences paths)
- **Result**: `EMIKO LV4 NATIVE PREVIEW: 118 checks; 0 failure(s)` (exit code `0`)
- **Log**: `/private/tmp/hoshimi-emiko-lv4-rev-native.log`

## Captured Native Screenshots (`1280×800`)

| File | Node / Screen | Verification Target |
|---|---|---|
| `01_zh_progress_ui_lv4_ready.png` | `office_relationship_detail` (`zh_CN`) | Lv4 gate ready (`Familiarity >= 55`, `Clinical Presence >= +30`, 3-day cooldown after Lv3) |
| `02_zh_scene1_or_door_outside.png` | `em4_s1_05` (`zh_CN`) | Scene 1 `or_entrance` evening return with unsigned pathology slip, calendar header hidden |
| `03_zh_scene1_or_secret_cg_slot.png` | `em4_s1_11` (`zh_CN`) | Scene 1 `operating_room` with `hide_portrait: true` (reserved for user NSFW CG mount, stripped `**` markers cleanly) |
| `04_zh_scene1_get_out.png` | `em4_s1_20` (`zh_CN`) | Scene 1 `"……出去！！"` |
| `05_zh_scene2_hallway_distance.png` | `em4_s2_05` (`zh_CN`) | Scene 2 2F `hallway` brief polite distance (`white_coat/serious`) |
| `06_zh_scene2_whiteboard_excuse.png` | `em4_s2_13` (`zh_CN`) | Scene 2 4F `or_entrance` scheduling whiteboard excuse |
| `07_zh_scene3_confrontation_v11.png` | `em4_s3_17` (`zh_CN`) | Scene 3 `shared_doctors_office` V1.1 P1 chief-rivalry confrontation wording |
| `08_zh_scene3_choice1_wide.png` | `em4_choice_c1` (`zh_CN`) | Choice 1 full-width 3-option layout, save locked |
| `09_zh_scene3_are_you_an_idiot.png` | `em4_s3r_06` (`zh_CN`) | `white_coat/surprised` `"……你这个人是傻子吗？"` |
| `10_zh_scene3_whispered_thanks.png` | `em4_s3r_15` (`zh_CN`) | `white_coat/worried` `"……谢谢。"` |
| `11_zh_scene4_candid_question.png` | `em4_s4_15` (`zh_CN`) | Scene 4 candid confession (`"知道我是这种女人以后，你心里真的没有看不起我？"`) |
| `12_zh_scene4_choice2_wide.png` | `em4_choice_c2` (`zh_CN`) | Choice 2 full-width 3-option layout |
| `13_zh_scene4_cholecystectomy_invite.png` | `em4_s4r_11` (`zh_CN`) | `white_coat/smile` next open cholecystectomy first-assistant invitation |
| `14_zh_scene5_sakurai_mayumi_27yo.png` | `em4_s5_07` (`zh_CN`) | Scene 5 `duo_with_patient`: 27yo officer Mayumi Sakurai (`intraoperative/tense.png` RGBA) + Emiko (`sterile/focused`), zero `继续 ▷` overlap |
| `15_zh_scene5_ange_circulating.png` | `em4_s5_13` (`zh_CN`) | Scene 5 `duo_with_patient`: Mayumi Sakurai + Anji Tonegawa (`nurse_ange` `scrubs/warm`) |
| `16_zh_scene5_dont_leave_first.png` | `em4_s5_30` (`zh_CN`) | Unmasked `scrubs/warm` `"今天不用你先走。"` |
| `17_zh_scene5_ange_doorway_debrief.png` | `em4_s5_48` (`zh_CN`) | `or_entrance` Anji Tonegawa accepting the `"单独复盘解剖细节"` excuse |
| `18_zh_scene6_1_table_is_narrow.png` | `em4_s6_1_12` (`zh_CN`) | Scene 6.1 `"手术台确实也是床，就是窄了点。"` |
| `19_zh_scene6_1_care_to_try.png` | `em4_s6_1_22` (`zh_CN`) | Scene 6.1 `"门外的时间都是你借来的了，坂口医生。……你要不要过来试试？"` |
| `20_zh_scene6_h_runner_placeholder.png` | `emiko_lv4_h_placeholder` (`zh_CN`) | Dedicated H Runner Placeholder screen on `operating_room`, save locked (`Load` only), advancing cleanly to Scene 6.2 |
| `21_zh_scene6_2_sharing_secret.png` | `em4_s6_2_14` (`zh_CN`) | Scene 6.2 exclusive aftercare (`scrubs/warm`) |
| `22_zh_scene6_2_never_yield_chief.png` | `em4_s6_2_26` (`zh_CN`) | Scene 6.2 `scrubs/focused` unyielding Chief-of-Surgery rivalry declaration |
| `23_zh_scene6_2_breathtaking_smile.png` | `em4_s6_2_32` (`zh_CN`) | Scene 6.2 `scrubs/warm` final smile before stepping out |
| `24_zh_complete_screen_0900.png` | `character_event_complete` (`zh_CN`) | Next-day `09:00` completion screen (`Lv.4` + `unlock_intimacy_events`) |
| `25_zh_staff_free_h_pending_assets.png` | `staff` (`zh_CN`) | Emiko Staff View showing `关系 Lv.4 · 亲密关系` and disabled `亲密事件已解锁 · 素材待补` (`FreeHBookingPendingAssets`) |
| `26_en_scene3_confrontation_v11.png` | `em4_s3_17` (`en`) | English Scene 3 confrontation, zero CJK |
| `27_en_scene3_choice1_wide.png` | `em4_choice_c1` (`en`) | English Choice 1 full-width 3-option layout |
| `28_en_scene5_sakurai_mayumi_27yo.png` | `em4_s5_07` (`en`) | English Scene 5 Mayumi Sakurai + Emiko OR duo |
| `29_en_scene5_ange_doorway_debrief.png` | `em4_s5_48` (`en`) | English Scene 5 Anji Tonegawa doorway debrief excuse |
| `30_en_scene6_1_table_is_narrow.png` | `em4_s6_1_12` (`en`) | English Scene 6.1 `"An operating table really is a bed—just a little narrow."` |
| `31_en_scene6_h_runner_placeholder.png` | `emiko_lv4_h_placeholder` (`en`) | English H Runner Placeholder screen on `operating_room`, zero CJK |
| `32_en_scene6_2_never_yield_chief.png` | `em4_s6_2_26` (`en`) | English Scene 6.2 unyielding Chief-of-Surgery rivalry declaration |
| `33_en_complete_screen_0900.png` | `character_event_complete` (`en`) | English next-day `09:00` completion screen (`DAY 16 / 2025.04.16 Wednesday 09:00`) |
| `34_en_staff_free_h_pending_assets.png` | `staff` (`en`) | English Emiko Staff View showing `Relationship Lv.4 · Intimate Relationship` and `Intimacy unlocked · Art pending` |

## Boundary Note
This run verifies real `1280×800` Metal window rendering, RGBA portrait alpha/mipmaps, layout wrapping, H Runner placeholder transition, Free H pending-assets UI, and zero button overlap via automated scene driving; manual human mouse playthrough was not performed.
