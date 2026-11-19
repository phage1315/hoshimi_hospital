# Saber 传奇术式 V1.1《这一次，交给你》实装与验收报告（2026-11-18）

## 1. 定稿依据与范围

- **三日 VN 原稿**：`research/source_scripts/HOSHIMI_SABER_LEGENDARY_MAIYA_THREE_DAY_VN_V1_1.md`（SHA-256 `cecfcc04f600650a67de20b2e834952bd2213ac5a2af7225bf26815cea32f367`）
  - Day 1（`A01–D16`）：139 句 + 2 处即时 RP 选择（`A-C1`、`C-C2`）
  - Day 2（`E01–F13`）：25 句（`E` 手术室双门外平车核对、`F` 诱导前 `scrubs_masked/neutral` 与麻醉面罩过场）
  - Day 3（`G01–I18`）：102 句 + 2 处即时 RP 选择（`G-C3`、`H-C4`）
  - 合计 **266 句正文 + 4 处即时选择（共 10 个选项与即时回应）**，0 持久状态／关系／数值副作用。
- **18 阶段手术设计原稿**：`research/source_scripts/HOSHIMI_SABER_LEGENDARY_MAIYA_SURGICAL_DESIGN_V1_1.md`（SHA-256 `2b22238d15db05bee23755797b276b8436075ebecd7c0b148abca74f3b924e2f`）
  - 术式 ID：`surgery_master_whipple_vascular_reconstruction`（`LEGENDARY_STORY`，`base_difficulty = 99`，`training_ceiling = 100`，`reward_tier = "advanced"`）
  - 专属首通患者：久宇舞弥（`patient_maiya_hisau`）
  - 18 阶段：`F4 / L3 / S3 / P8`，总基础消耗 **54 HP / 729 min**
  - V1.1 策略节点：`WH05`、`WH10`、`WH17`
  - 18 阶段生理表与 7 条 `conditional_effects`
  - 生理危机检查点：`crisis_checkpoints = [8, 12, 17]`（对应 `WH09`、`WH13`、`WH18` 之后）
  - 术中对白顺序：`WH01`／`WH18` 为 `[PRE01, PRE02, ASxx]`，`WH02–WH17` 为 `[PRE01, ASxx, PRE02]`；`dialogue_after_rescue = true`；6 处 `ASxx_S_POST_A/B` 差分；8 处 `WHxx_P_FAIL` 专属失误台词。

## 2. 资源与数据接入清单

- **运行素材**：
  - `assets/surgery/fields/saber_whipple_vascular.jpg`（用户提供主术野原样字节复制，`1024×791 RGB`，SHA-256 `f35618d8d7a47db4c81d95ef538172701dd335f9a682e77d6a`）；`WH01` 与 `WH18` 复用既有 `whipple_incision.png`／`whipple_closure.png`。
  - `assets/characters/maiya_hisau_legendary_v1/`：8 张本地 BiRefNet-ToonOut 透明化 `RGBA` 立绘（`ward/{neutral,serious,relieved}.png`、`casual/neutral.png`、`postop/{neutral,tired,relieved}.png`、`or_cap/calm.png`，全部开启 `mipmaps/generate=true` 且顶角 `alpha == 0`）+ 2 张 `RGB` 场景图（`transfer.png`、`anesthesia.png`）+ `manifest.json`。
- **数据文件**：
  - `data/advanced_surgery/legendary_procedures.json`（保留御堂在 `[0]`，新增 Saber 在 `[1]`）
  - `data/advanced_surgery/legendary_registry.json`（`runtime_ready: true`，含 Saber 专属 `ui_text` 覆盖，不改动御堂全局 `legendary_*` 原文键）
  - `data/advanced_surgery/stories/surgery_master_whipple_vascular_reconstruction.json`
  - `data/advanced_surgery/dialogue_teaching/surgery_master_whipple_vascular_reconstruction.json`
  - `data/advanced_surgery/dialogue_v2/surgery_master_whipple_vascular_reconstruction.json`
  - `data/advanced_surgery/field_windows.json`、`data/advanced_surgery/replay_case_profiles.json`、`data/advanced_surgery/ui_text.json`
  - `research/imports/saber_legendary_v1_1.json`

## 3. 执行的验证与结果

| 类别 | 命令 | 结果 |
|---|---|---|
| 原稿逐字一致性审计（Saber） | `.venv/bin/python tools/saber_legendary_source_audit.py` | **2098 checks; 0 failures** |
| 原稿逐字一致性回归（御堂） | `.venv/bin/python tools/mido_legendary_source_audit.py` | **642 checks; 0 failures** |
| 叙事中英本地化审计 | `python3 tools/narrative_localization_test.py` | **57229 checks; 0 failure(s)** |
| 全量 UI／文本本地化审计 | `python3 tools/localization_audit.py` | **93500 translations; 0 hard-coded Chinese** |
| Godot 4.5.1 资源导入（两轮） | `Godot --headless --path . --editor --import --quit` | **Exit 0**（全部 8 张 RGBA 立绘 `mipmaps/generate=true`） |
| Saber 传奇专项测试 | `tools/saber_legendary_test.gd` | **223 checks; 0 failures** |
| 御堂传奇专项回归 | `tools/mido_legendary_test.gd` | **179 checks; 0 failures** |
| 高级手术模型与会话回归 | `tools/advanced_surgery_test.gd` | **6451 checks; 0 failures** |
| 高级转诊队列与 V2 返场池回归 | `tools/advanced_referral_test.gd` | **17 checks; 0 failure(s)** |
| 高级术中对白回归 | `tools/advanced_operative_dialogue_test.gd` | **4902 checks; 0 failures** |
| 医护患者 UI 回归 | `tools/advanced_staff_patient_ui_test.gd` | **1790 checks; 0 failures** |
| 安全边界存档契约回归 | `tools/boundary_save_test.gd`、`narrative_save_lock_test.gd`、`surgery_history_save_test.gd`、`save_store_test.gd` | **1020 / 6 / 1100 / 19 checks; 0 failures** |
| 运行时语言与冒烟测试 | `tools/localization_test.gd`、`tools/smoke_test.gd` | **33 checks / 0 failure(s)** |
| **原生 Metal 1280×800 双语全链路实机测试** | `Godot --path . --log-file docs/qa/saber_legendary_2026-11-18/engine.log --script res://tools/saber_legendary_native_test.gd` | **1989 checks; 0 failures; 782 GUI clicks; 64 screenshots; 0 engine errors** |

## 4. 原生窗口截图证据目录（`native_prod/`）

共保存中英文各 28 张（合计 56 张 `1280×800` Metal 窗口帧）：

- 入口与排程：`{zh_CN,en}_terminal.png`、`{zh_CN,en}_board.png`、`{zh_CN,en}_team.png`
- Day 1（4 幕 + 2 处即时选项）：`{zh_CN,en}_day1_{A02,A25,B08,C26,D12}.png`
- Day 2（转运、手术帽口罩洗手衣、麻醉面罩过场、全麻准备页）：`{zh_CN,en}_day2_{E03,F05,F11,F13}.png`、`{zh_CN,en}_patient_ready.png`、`{zh_CN,en}_anesthesia_splash.png`
- 术中 18 阶段关键帧：`{zh_CN,en}_{WH01_saber_pre,WH01,WH02,WH05,WH11_saber_pre,WH12,WH17,WH18}.png`
- Day 3（病房查房、复盘室、走廊尾声与结算页）：`{zh_CN,en}_day3_{G03,G29,G33,H30,I14}.png`、`{zh_CN,en}_settled.png`

## 5. 边界与已知事项说明

- 原稿 `CL-MAI-16`（脾静脉汇合部袖口保留个体解剖假定）按设计定稿保留 `NEEDS_MEDICAL_QA` 标注记录，未擅自改动正文或医学措辞。
- 本次测试全部使用内存 fixture 与 `/private/tmp` 独立日志，未触碰任何玩家存档槽位。
- 原生测试通过可见 Metal 窗口合成 GUI 点击驱动完成，尚未进行真人物理鼠标／键盘手点与独立打包导出测试。
