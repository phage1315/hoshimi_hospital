# 相泽麻纪 Lv0《排班表上的名字》实装与验收报告（2026-11-13）

## 1. 实装范围概览

- **原稿依据**：`research/source_scripts/HOSHIMI_AIZAWA_MAKI_LV0_NAME_ON_ROSTER_V1_1.md`（中文 VN 完整审阅稿 V1.1 定点修订版，正文 158 拍 + Choice D1 双选共 2 个选项，100% 原字原句、原说话人、原顺序与原标点保留，零改写、零剧透字样）。
- **事件注册与 Codex 数据兼容**：
  - 事件 ID：`maki_lv0_onboarding`（独立写入 `data/staff/doc_maki/lv0_events.json`，通过 `data/staff/doc_maki/bundle.json` 的 `additional_character_event_files` 加载）。
  - 严格保持 `data/staff/doc_maki/{events,profile,relationship,date_profiles,time_events,role_rewards}.json` 原样未改（保留 `events.json == []`，确保 `tools/maki_source_audit.py` 与 `tools/maki_v1_3_source_audit.py` 100% 原样通过）。
- **触发契约与日程边界（`MK0-L01`..`MK0-L09` + `godot/systems/maki_lv0.gd`）**：
  - 前置条件：完成城宮明日香 Lv2 `asuka_lv2_right_person_right_gown`（`maki_aizawa_offer_accepted == true`），且到达面试日后约一个月门槛 `onboarding_earliest_day()`（`maxi(add_months(interview_day, 1), interview_day + 30)`）。
  - 零额外属性门槛：不要求额外魅力／手术／声望／好感／熟悉度数值，亦不要求配角 `nurse_hiroko` 提前相识（且不修改配角 `met` 状态）。
  - 触发时机：在此后首个非休院开放工作日（周一至周六，自动跳过周日与法定节假日如 `2025-05-06` 振替休日）清晨 `09:00`（`trigger_mode: "day_start"`, `time_start: 540, time_end: 719`）于进入医院导览时自动启动（含前一日下班结算 `continue_after_day_transition() -> show_map(false)` 后的次日清晨直连启动）；若存在未完结门诊／术前准备／进行中手术／特殊事件则自动顺延至下一空闲开放工作日。
- **五幕纯 VN 舞台与零新增美术复用**：
  - **Scene A（`shared_doctors_office`）**：清晨报到、明日香与隆司排班白板交接（复用 `doc_asuka/white_coat/neutral` 与 `doc_maki/white_coat/{worried,neutral,focused}`）。
  - **Scene B（`or_entrance` → `scrub_area`）**：术前拉钩习惯确认与杉村弘子 6.5 号无菌手套迎新（复用 `nurse_hiroko/scrubs/warm` 与 `doc_maki/white_coat/{focused,smile}`）。
  - **Scene C（`operating_room`）**：右侧腹股沟斜疝择期开放修补术 **100% 纯固定 VN 演出**（复用 `nurse_hiroko/sterile/{neutral,focused,warm}` 与 `doc_maki/sterile/{neutral,focused,worried}`），绝不调用 Surgery Runner、术中危机 RNG 或累加 `completed_surgeries_total`。
  - **Scene D（`staff_lounge`）**：午间手绘方格术野复盘笔记与 Choice D1（`mk0_choice_d1`，`presentation: "choice"` 宽幅双按钮，零数值差 RP 分支）。
  - **Scene E（`hallway`）**：黄昏走廊偶遇、学妹往事边界与次日第一助手排班预告（复用 `doc_maki/casual/{neutral,focused,worried}`）。
- **原子解锁与全天跨日结算（v37 存档边界）**：
  - 播放期间全程锁定存档（`locks_saving: true`）、隐藏顶部固定时钟栏（`hide_calendar_header: true`），且在未抵达 `@end` 前严格保持 `staff_is_met("doc_maki") == false`。
  - 抵达 `@end` 时原子标记 `maki_lv0_onboarding` 完成、写入 `maki_lv0_complete` 与 `maki_aizawa_onboarded`、并将 `doc_maki` 设为 `met = true`（`level = 0, familiarity = 0, affection = 0, route = "colleague"`），同步解锁：
    - 常规手术 `assistant_surgeon` 候选池（`primary_surgeon` 保持锁定）；
    - 高级转诊手术 `first_assistant`／`second_assistant` 候选池；
    - `lounge`（职员休息室）常驻交流、`rooftop` 随机偶遇池、以及满足 `familiarity >= 10` 后的周日约会邀约资格。
  - 通过 `completion_day_offset: 1, completion_absolute_clock: 540, completion_display_clock: 1070` 结算至次日 `09:00` 安全边界（若周六入职跨入周日清晨则安全进入 `sunday_menu`）；`BoundarySave` v37 存读档零演出内部节点泄漏，读档不重放。

---

## 2. 实际执行的静态审计与引擎测试

| 检查项 | 执行命令 | 结果 |
|---|---|---|
| 原稿逐句、零剧透、双分支图、立绘与双语键审计 | `.venv/bin/python tools/maki_lv0_source_audit.py` | **PASS（`4221 checks; 0 failure(s)`）** |
| 相泽麻纪 V1.1 / V1.3 与明日香 Lv2 既有审计 | `python3 tools/maki_source_audit.py && python3 tools/maki_v1_3_source_audit.py && .venv/bin/python tools/asuka_lv2_source_audit.py` | **全部 PASS** |
| 全量叙事双语本地化测试 | `python3 tools/narrative_localization_test.py` | **PASS（`48474 checks; 0 failure(s)`）** |
| 医护独立台词双语测试 | `python3 tools/staff_localization_test.py` | **PASS（`1209/1209`）** |
| 本地化覆盖率审计 | `python3 tools/localization_audit.py` | 叙事 **`56835/56835`**、UI **`802/802`**（全仓仍因既有 `voice_director.gd` 5 行中文退出 1） |
| 数据结构与引用校验 | `.venv/bin/python tools/validate_data.py` | `doc_maki` / `doc_asuka` / `lv0_events` **0 错误**（全仓因既有其他积压项退出 1） |
| Godot 资源导入检查 | `.../Godot --headless --path . --log-file /private/tmp/hoshimi-maki-lv0-import-20261113.log --editor --import --quit` | **PASS（退出 0）** |
| 麻纪 Lv0 专项回归（延期／节假日顺延、零额外属性门槛、播放期未解锁不变量、纯 VN 不动手术计数、Choice D1 双支等价、助手池与约会门槛、v37 存读档、中英 UI 及周六→周日路由、画廊回放） | `.../Godot --headless --path . --log-file /private/tmp/hoshimi-maki-lv0-test3-20261113.log --script res://tools/maki_lv0_test.gd` | **PASS（`3840 checks, 0 failure(s)`）** |
| 并行兼容与存档边界回归 | `maki_staff_test.gd` / `asuka_lv2_test.gd` / `boundary_save_test.gd` / `event_rendering_save_boundary_test.gd` / `narrative_save_lock_test.gd` / `surgery_history_save_test.gd` / `localization_test.gd` | **全部 PASS（`84/0`、`3697/0`、`1020/0`、`8223/0`、`6/0`、`1064/0`、`33/0`）** |
| 原生非 Headless `16:10` 窗口实机抓帧验收 | `.../Godot --path . --log-file /private/tmp/hoshimi-maki-lv0-preview2-20261113.log --script res://tools/maki_lv0_preview_capture.gd` | **PASS（`71 checks, 0 failure(s)`，生成 `01`–`20` 共 18 张中英文实机截图并逐项核验）** |

---

## 3. 原生窗口截图索引（同目录）

- **中文实机流程（`01`–`14`）**：
  - `01_zh_scene_a_maki_arrival.png`：Scene A 医生共同办公室，相泽麻纪 `white_coat/worried` 敲门报到。
  - `02_zh_scene_a_asuka_and_maki_roster.png`：Scene A 城宮明日香与相泽麻纪双人立绘同台，宣布二号手术间第一助手排班（顶部时钟栏已按契约隐藏）。
  - `03_zh_scene_b_preop_focused.png`：Scene B 手术室走廊前厅，麻纪 `white_coat/focused` 询问主刀拉钩力度习惯。
  - `04_zh_scene_b_hiroko_gloves_welcome.png`：Scene B 杉村弘子 `scrubs/warm` 与麻纪 `white_coat/smile`，备妥六号半无菌手套。
  - `05_zh_scene_c_or_sterile_timeout.png`：Scene C 二号手术间纯 VN 术中演出，弘子与麻纪 `sterile/focused` 核对切皮。
  - `06_zh_scene_c_maki_oblique_view.png`：Scene C 麻纪从一助斜侧视角指出深环内下缘筋膜反折背面细小血管。
  - `07_zh_scene_d_grid_notebook.png`：Scene D 职员休息室，麻纪手绘方格纸术野截面示意图复盘。
  - `08_zh_scene_d_choice_d1.png`：Scene D 双选按钮 `mk0_choice_d1`（单行完整显示无裁切）。
  - `09_zh_scene_d_option_a_feedback.png`：Scene D 选项 A 沉稳严格路线回应。
  - `10_zh_scene_e_alumna_focused.png`：Scene E 公共走廊，麻纪 `casual/focused` 说明未在面试提及校友关系的原因。
  - `11_zh_scene_e_tomorrow_roster.png`：Scene E 走廊道别与明日九点半二号间第一助手排班预告。
  - `12_zh_day_end_transition.png`：全天剧情结束跨日黑场过渡页。
  - `13_zh_lv0_completion_card.png`：相识事件完成结算页（`已经认识 · 普通同事 · 尚未建立羁绊 / 这段剧情持续至当日结束。现在是 09:00`）。
  - `14_zh_post_onboarding_lounge.png`：次日清晨进入职员休息室，`相澤 麻紀 / 普通外科 · 21.0岁` 与 `闲谈 · 30.0 分钟` 已正式开放。
- **英文实机流程（`15`–`20`）**：
  - `15_en_scene_a_asuka_and_maki_roster.png`、`16_en_scene_c_maki_oblique_view.png`、`17_en_scene_d_choice_d1.png`、`18_en_scene_d_option_b_smile.png`、`19_en_scene_e_alumna_focused.png`、`20_en_lv0_completion_card.png`（全部零中文残留、按钮自动换行贴合无溢出）。

---

## 4. 未测范围与后续边界说明

1. 本轮原生窗口截图由 `tools/maki_lv0_preview_capture.gd` 在真实 macOS Metal 非 Headless 窗口渲染管线自动推进抓帧，尚未进行人工鼠标逐拍手动点击游玩。
2. 职员休息室列表中 `doc_maki` 的像素小头像槽位当前显示通用 `?` 占位（该像素小人系列属独立美术包，不影响立绘、闲谈、手术编组、HUD 术中头像及约会功能）。
3. `doc_maki` 的 Lv1–Lv5 羁绊／升阶剧本仍为后续待创作内容；全程仅使用内存与 `/private/tmp/` 临时路径，未读写任何真实玩家存档槽位。
