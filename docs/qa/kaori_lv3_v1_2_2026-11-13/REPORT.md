# 深山佳織 Lv3《手术室之神》V1.2（含客串急诊患者麻生华澄）运行截图验收报告

- **验收日期**：2026-11-13
- **关联角色与事件**：深山 佳織（`doc_rei`）Relationship Lv3 特别事件 `miyama_03_or_god`（《手术室之神》 / *The God of the Operating Room*，V1.2 全卷重构版）
- **客串急诊患者**：麻生 华澄（`guest_kasumi_asou` / `Kasumi Asou`，23 岁，急性坏疽性胆囊炎急诊患者）
- **原稿与译稿依据**：
  - 中文原稿：`research/source_scripts/HOSHIMI_MIYAMA_KAORI_LV3_OR_GOD_REVISED_V1_2.md`
  - 英文译稿：`research/translations/miyama_lv3_en.json`
  - 导入清单：`research/imports/miyama_lv3_v1_2_2026-11-13.json`
- **运行数据与驱动脚本**：
  - 事件定义与节点：`data/staff/doc_rei/special_events.json`、`data/staff/doc_rei/special_event_steps.json`
  - 客串患者档案：`data/patients/cameo_patients.json`
  - 原生窗口验收脚本：`tools/kaori_lv3_preview_capture.gd`

---

## 1. 机制与资源概览

1. **双日连贯 12 幕结构（共 353 节点 + 4 处共 10 个选项）**：
   - **Day 1（`miyama_03_or_god_day1`，28 节点）**：Scene 1（三楼外科走廊查房后偶遇）→ Scene 2（旧住院楼天台长椅黑咖啡交谈，日终不提前升 Lv3）。
   - **Day 2（`miyama_03_or_god_main`，325 节点）**：Scene 3（外科护士站弘子交班）→ Scene 4（院长室飞鸟调阅夜间监控）→ Scene 5（三号手术室发现熟睡的深山）→ Scene 6（飞鸟“行为艺术”解围）→ Scene 7（23 岁麻生华澄急诊过床、全屏指挥 CG、诱导面罩全麻）→ Scene 8（刷手池戴口罩 + Choice 1）→ Scene 9（本庄萌惠与安洁穿无菌袍 + 全屏系带背影 CG）→ Scene 10-1~10-6（六段硬核开腹胆囊切除术，含 Choice 2 Calot 三角解剖与 Choice 3 右结肠旁沟脓袋探查）→ Scene 11（术后麻醉恢复室 `pacu_recovery` 华澄道谢 + 手术部走廊“有效样本数变成三”复盘）→ Scene 12（季节自适应街道并肩夜归 + Choice 4 + 站前广场道别）。
2. **排程门禁与终局原子结算**：
   - `miyama_02_manga_artist_wrong_patient` 完成后 `>= 5` 天、`min_familiarity: 40`、`cooldown_days: 3`、`avoid_sunday_span: true`（周六自动顺延至周一，保证连续两日开院日触发）。
   - Scene 12 结束时一次性原子结算：`doc_rei` 升至 `Relationship Lv3`、写入 `completed_surgery_id: "surgery_open_cholecystectomy"`、`surgery_xp_bonus: 12`、`reputation: 2` 及 4 个稳定全局完成 flags；`BoundarySave` v37 边界存档零内部节点泄漏。
3. **本轮接入美术资源（共 19 张新增 RGBA 透明立绘 + 1 张新增 16:9 PACU 恢复室背景 + 3 张既有 Lv3 资产）**：
   - **深山佳織（`doc_rei`）新增 12 张**：
     - `assets/characters/miyama_lv3_v1/doc_rei/or_cap/{asleep,drowsy,masked_hesitant,masked_focused}.png`（`1448×1086` RGBA，4 张）
     - `assets/characters/intraoperative_portraits_v1/doc_rei/{tense,pain,near_collapse,anesthetized,embarrassed,relieved}.png`（`1448×1086` RGBA，6 张，兼供未来真实医护患者术中演出复用）
     - `assets/characters/spring_summer_casual_v1/doc_rei/small_smile.png`、`assets/characters/winter_casual_v1/doc_rei/small_smile.png`（`1024×1536` RGBA，2 张）
   - **麻生华澄（`guest_kasumi_asou`）新增 7 张**：
     - `assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/or_cap/{tense,shocked_feverish,mask_drowsy,anesthetized}.png`（`1448×1086` RGBA，4 张）
     - `assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/ward/{neutral,drowsy_relieved,confused}.png`（`1024×1536` RGBA，3 张）
   - **公共手术区新增背景 1 张**：
     - `assets/backgrounds/pacu_recovery_v1/pacu_recovery.png`（`1376×768` RGB，注册为 `pacu_recovery`「术后麻醉恢复室」/ `"Post-Anesthesia Care Unit (PACU)"`，冷白日光灯无机感洁净区＋不锈钢自动移门直通手术室走廊＋隔帘复苏推床与多参数监护仪）
   - **既有 Lv3 全屏 CG 与无菌立绘复用（3 张）**：
     - `assets/events/miyama_lv3_v1/emergency_command_nude.png`（`1536×1024` 全屏 CG，含首帧 `1.0s` 纯享延迟）
     - `assets/events/miyama_lv3_v1/or_god_surgery_rear.png`（`1536×1024` 全屏 CG，含首帧 `1.0s` 纯享延迟）
     - `assets/characters/miyama_lv3_v1/doc_rei/sterile/focused.png`（`1024×1536` RGBA）

---

## 2. 原生窗口 25 张实机截图清单（`1280×800`）

同目录内 25 张 PNG 均由非无头原生 Godot 窗口实际渲染截取：

| 序号 | 截图文件 | 语言／季节 | 节点 / 视图 | 场景与验收要点 |
|---|---|---|---|---|
| 1 | `01_zh_day1_rooftop_coffee.png` | `zh_CN` 春季 | `s02_020` | Day 1 Scene 2 旧住院楼天台长椅黑咖啡交谈（白大褂立绘、顶栏日期 `2025.04.14 周一 16:40`、事件中存档锁灰显） |
| 2 | `01b_zh_day2_nurses_station_hiroko.png` | `zh_CN` 春季 | `s03_006` | Day 2 Scene 3 外科护士站与一文字弘子晨间交班（确认弘子参与演出但不设排程硬锁） |
| 3 | `01c_zh_director_office_asuka.png` | `zh_CN` 春季 | `s04_012` | Day 2 Scene 4 院长室北条飞鸟调阅夜间走廊监控 |
| 4 | `02_zh_or3_cap_asleep.png` | `zh_CN` 春季 | `s05_014` | Day 2 Scene 5 三号手术室发现深山戴手术帽沉睡（`or_cap/asleep.png`，右侧 `x=955` 避开左侧“继续”按钮） |
| 5 | `03_zh_or3_cap_embarrassed.png` | `zh_CN` 春季 | `s05_017` | Day 2 Scene 5 深山惊醒涨红脸（`intraoperative/embarrassed.png`） |
| 6 | `03b_zh_or3_asuka_exorcism_gag.png` | `zh_CN` 春季 | `s06_012` | Day 2 Scene 6 飞鸟推门撞见后的“通宵值班后的行为艺术”冷幽默解围 |
| 7 | `04a_zh_kasumi_or_cap_tense.png` | `zh_CN` 春季 | `s07_013` | Day 2 Scene 7 23 岁麻生华澄急诊推入二号手术室（水濑小夜香同框 + 华澄 `or_cap/tense.png`） |
| 8 | `04_zh_cg_emergency_command.png` | `zh_CN` 春季 | `s07_014` | Day 2 Scene 7 全屏事件 CG 1 `emergency_command_nude.png`（验证 `1.0s` 首帧纯享延迟后对话框浮现） |
| 9 | `04c_zh_kasumi_shocked_feverish.png` | `zh_CN` 春季 | `s07_021` | Day 2 Scene 7 全屏 CG 切回立绘后主角在头侧握住华澄手腕安抚（`or_cap/shocked_feverish.png`） |
| 10 | `04b_zh_kasumi_mask_drowsy.png` | `zh_CN` 春季 | `s07_023` | Day 2 Scene 7 透明麻醉面罩扣上后全麻诱导迷糊呢喃（`or_cap/mask_drowsy.png`） |
| 11 | `05_zh_scrub_masked_choice1.png` | `zh_CN` 春季 | `s08_013` | Day 2 Scene 8 刷手间戴外科口罩 `or_cap/masked_hesitant.png` + Choice 1 三选项布局 |
| 12 | `05b_zh_or2_gowning_moe_ange.png` | `zh_CN` 春季 | `s09_006` | Day 2 Scene 9 本庄萌惠与安洁协助穿无菌手术袍（三人同框：“无菌手术袍不是日常穿的衣服”） |
| 13 | `06_zh_cg_sterile_gown_rear.png` | `zh_CN` 春季 | `s09_017` | Day 2 Scene 9 全屏事件 CG 2 `or_god_surgery_rear.png`（背后打结系带） |
| 14 | `06b_zh_stage10c_calot_choice2.png` | `zh_CN` 春季 | `s10c_002` | Day 2 Scene 10-3 Calot 三角解剖判断 + Choice 2 两选项（深山 `sterile/focused` + 萌惠 + 安洁） |
| 15 | `07_zh_stage10e_paracolic_pocket.png` | `zh_CN` 春季 | `s10e_018` | Day 2 Scene 10-5 吸引排空右结肠旁沟隐匿脓袋（飞鸟 + 深山 + 萌惠三人同框） |
| 16 | `07b_zh_kasumi_ward_confused.png` | `zh_CN` 春季 | `s11_012` | Day 2 Scene 11 术后麻醉恢复室 `pacu_recovery`（`19:10`）：华澄病号服 `ward/confused.png` 迷糊回忆“没穿衣服的神明” + 深山无菌袍扑克脸 |
| 17 | `07c_zh_hallway_sample_size_three.png` | `zh_CN` 春季 | `s11_030` | Day 2 Scene 11 手术室走廊术后复盘（飞鸟 + 深山：“现在有效样本量变成三了”） |
| 18 | `08_zh_spring_street_small_smile.png` | `zh_CN` 春季 | `s12_016` | Day 2 Scene 12 春季樱花夜街（`seasonal_street`）+ 春夏私服浅笑 `casual/small_smile.png` + Choice 4 三选项 |
| 19 | `09_zh_station_farewell_small_smile.png` | `zh_CN` 春季 | `s12_043` | Day 2 Scene 12 站前广场夜景道别（春夏私服 `small_smile.png`） |
| 20 | `09b_zh_gallery_two_chapters.png` | `zh_CN` 春季 | 鉴赏回想页 | 终局结算后解锁鉴赏页双章节入口（`1. 第一天：天台的罐装黑咖啡` / `2. 第二天：手术室之神`） |
| 21 | `10_en_winter_street_small_smile.png` | `en` 冬季 | `s12_016` | 英文版 12 月冬夜积雪街道 + 秋冬高领大衣私服 `casual_winter/small_smile.png` + 英文三选项无溢出 |
| 22 | `11_en_scrub_masked_choice1.png` | `en` 冬季 | `s08_013` | 英文版 Scene 8 刷手池口罩差分 + Choice 1 英文三选项 |
| 23 | `12_en_winter_station_farewell.png` | `en` 冬季 | `s12_043` | 英文版 Scene 12 冬季站前广场道别（`casual_winter/small_smile.png`） |
| 24 | `13_en_kasumi_mask_drowsy.png` | `en` 冬季 | `s07_023` | 英文版 Scene 7 `Kasumi Asou` 氧气面罩诱导呢喃（长英文标题零遮挡） |
| 25 | `14_en_kasumi_ward_confused.png` | `en` 冬季 | `s11_012` | 英文版 Scene 11 术后麻醉恢复室 `pacu_recovery` 中 `Kasumi Asou` 与 `Kaori Miyama` 同框（立绘顶边 `y=145` 避开英文标题） |

---

## 3. 原稿逐句审计与授权对齐记录

运行 `.venv/bin/python tools/kaori_lv3_source_audit.py` 对照原稿与运行数据，除以下 **15 处已获用户明确授权的设定／季节泛化／客串患者对齐**外，其余全部对白、旁白、标点、说话人归属与节点顺序 **0 差异**：

1. **医护姓名与医院名对齐（9 处）**：原稿暂名 `星野护士` → 一文字弘子（`s03_003`、`s03_006`、`s03_009`）；急诊推床护士 → 水濑小夜香（`s07_002`、`s07_012`）；二号手术室器械／巡回护士 `高桥护士`／`相泽护士` → 本庄萌惠／安洁（`s07_006`、`s09_002`、`s10a_003`）；医院名统一为 `星见医院`（`s06_016`）。
2. **季节泛化（1 处）**：因事件随玩家关系进度可在任意季节触发，`s12_011` 夜归街道描写按用户授权由固定深秋银杏泛化为全季节通用的夜风与行道树光影，配和 `seasonal_street` / `seasonal_casual` 动态切换春夏秋冬街景与私服。
3. **客串急诊患者麻生华澄替换（5 处 + 说话人标签）**：按用户授权将通用 42 岁急诊女患者替换为 23 岁麻生华澄（`s07_003`、`s07_013`、`s07_015`、`s10a_004`、`s11_011` 及说话人 `麻生华澄` / `Kasumi Asou`）。

---

## 4. 实际执行验证命令与通过结果

| 检查项 | 执行命令 | 结果 |
|---|---|---|
| 原稿逐句与立绘覆盖审计 | `.venv/bin/python tools/kaori_lv3_source_audit.py` | **PASS**（`4052 checks; 0 failure(s)`） |
| 数据结构与跨文件引用 | `.venv/bin/python tools/validate_data.py` | `doc_rei` / `miyama_03_or_god` / `guest_kasumi_asou` / `pacu_recovery` **0 errors** |
| 叙事中英双语完整性 | `python3 tools/narrative_localization_test.py` | **PASS**（`47206 checks; 0 failure(s)`） |
| 全局本地化覆盖审计 | `python3 tools/localization_audit.py` | 叙事字段 **`55556/55556`**、UI 英文键 **`801/801`**（仅既有未改动 `voice_director.gd` 5 行硬编码退出 1） |
| Godot 资源导入 | `Godot --headless --path . --log-file /private/tmp/hoshimi-pacu-import.log --editor --import --quit` | **PASS**（exit `0`） |
| Lv3 专项全链路无头测试 | `Godot --headless --path . --log-file /private/tmp/hoshimi-pacu-test.log --script res://tools/kaori_lv3_test.gd` | **PASS**（`3738 checks; 0 failure(s)`） |
| 事件渲染与存档边界测试 | `Godot --headless --path . --log-file /private/tmp/hoshimi-event-save-kasumi.log --script res://tools/event_rendering_save_boundary_test.gd` | **PASS**（`8203 checks; 0 failures; no files written`） |
| v37 边界存档契约与锁测试 | `tools/boundary_save_test.gd`、`tools/narrative_save_lock_test.gd` | **PASS**（`998/0`、`6/0`） |
| 运行时中英切换测试 | `Godot --headless --path . --log-file /private/tmp/hoshimi-loc-kasumi.log --script res://tools/localization_test.gd` | **PASS**（`33 checks; 0 failure(s)`） |
| **原生窗口 25 图渲染验收** | `Godot --path . --log-file /private/tmp/hoshimi-kaori-lv3-preview-full25.log --script res://tools/kaori_lv3_preview_capture.gd` | **PASS**（`718 checks; 0 failure(s)`，输出本目录 25 张 `1280×800` PNG） |

---

## 5. 验收边界声明

- 本目录 25 张截图均为 macOS 原生 Godot 窗口（Metal Compatibility 渲染器，`1280×800` 逻辑画布）真实渲染输出，由 `tools/kaori_lv3_preview_capture.gd` 自动驱动推进并校验 UI 控件坐标与可见性；**尚未进行真人手动逐句点击全流程游玩**。
- 全部测试仅使用内存会话，未读取、创建或覆盖任何玩家存档槽位。
