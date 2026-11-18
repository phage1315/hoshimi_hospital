# 阿尔托莉雅·潘德拉贡（`doc_artoria`）Relationship Lv2《留下来的部分》实装与验收报告（2026-11-16）

## 1. 交付概览
- **事件 ID**：`artoria_lv2_what_remains`（`target_level: 2`，`category: "rank_up"`，`trigger_mode: "after_work"`）
- **作者原稿**：`research/source_scripts/HOSHIMI_ARTORIA_LV2_THE_PART_THAT_REMAINS_V1_0.md`（SHA-256: `c3a5a8022a17be26e24774f5cd441fa021748cd67f3eba2660d085e7a92c6813`）
- **英文译稿**：`research/translations/artoria_lv2_en.json`（标题 `"The Part That Remains"`，224 处节点正文 + 9 处选项全量翻译，0 CJK 残留）
- **解锁术式**：普通手术池高难术式《开腹肝叶切除》（`surgery_open_major_liver_resection` / `template_liver_resection`），在第五幕 `@end` 随 `artoria_lv2_complete` 与 `artoria_major_liver_resection_teaching_complete` 原子解锁，并推进至次日 `14:00`（`completion_day_offset = 1`、`completion_absolute_clock = 840`）。
- **日历与安全门禁**：
  - 仅限普通周一至周五工作日 `16:00–22:00` 下班离院（`OfficeEndWorkday`）触发；
  - 阻断周六、周日、次日为休诊节假日、存在未完成住院患者、次日存在高级转诊 `operation_day`/`review_day` 预约冲突；
  - 排除最后两天（`conditions.max_day: 363`、`workday <= GAME_DURATION_DAYS - 2`），确保次日手术不落入安琪离院窗口，无需额外回退分支；
  - 公务配台护士 `nurse_yui`（器械）与 `nurse_ange`（巡回）关系状态、熟悉度、`event_history` 及主任竞选旗标保持零改动。

## 2. 原文逐句审计报告
- `.venv/bin/python tools/artoria_lv2_source_audit.py` → **`19182 checks; 0 failure(s)`**（穷举 `3 × 3 × 3 = 27` 条完整路径，校验每句说话人归属、正文、标点、顺序及 9 个选项零数值／零旗标偏移，并校验界面无 `Saber` 内部代号泄露）。
- 为适配单说话人对话框结构而执行的不可避免节点拆分（保留全部原文字符与标点）：
  1. **28 处「动作旁白前缀 + 冒号 + 引号对白」拆分**：在 `：` 处拆分为相邻的 `旁白` 节点与对应说话人节点（含 `ar2_s3_27..28` 头架布帘后转述归属 `藤村大河`、`ar2_s4r_12..13` 苏醒提问归属 `藤村大河`）；
  2. **1 处纯文本 `Label` Markdown 星号剥离**：`ar2_s5_12` 去除外层 `**...**` 语法符号，保留正文全字不变；
  3. **1 处非玩家可见设计锚点注释跳过**：跳过第五幕 `*(【设计锚点提示】：...)*`。

## 3. 新增角色与患者立绘（10 张 RGBA 透明 PNG，`mipmaps/generate=true`）
- **藤村大河（25 岁成年患者，仅剧情出场，不入随机患者池）**：
  - 病房病号服（`1024×1536` RGBA）：`assets/characters/artoria_lv2_v1/taiga_fujimura/ward/{smile,laugh,worried}.png`
  - 手术帽头肩（`1448×1086` RGBA，放置于 `x=440/640, bottom=480, width=400, height=300`，避开底部对话框与继续按钮）：`assets/characters/artoria_lv2_v1/taiga_fujimura/or_cap/{tense,drowsy,relieved}.png`
- **阿尔托莉雅·潘德拉贡（`doc_artoria` 立绘补充）**：
  - 白大褂差分（`1024×1536` RGBA）：`assets/characters/artoria_lv2_v1/doc_artoria/white_coat/{smile,embarrassed}.png`
  - 术前硬膜外麻醉操作装（`1024×1536` RGBA，海军蓝短袖刷手服、空口袋、蓝色手术帽、系带外科口罩、无菌乳胶手套）：`assets/characters/artoria_lv2_v1/doc_artoria/scrubs_masked/{neutral,focused}.png`

## 4. 验证执行记录
- **A. 静态／原文／双语审计**：
  - `.venv/bin/python tools/artoria_lv2_source_audit.py` → `19182 checks; 0 failure(s)`
  - `python3 tools/narrative_localization_test.py` → `53328 checks; 0 failure(s)`
  - `python3 tools/localization_audit.py` → `87056 translations; UI 841/841; 0 hard-coded Chinese candidates`
  - `python3 tools/staff_localization_test.py` → `1209 isolated staff dialogue lines translated`
  - `.venv/bin/python tools/validate_data.py`（过滤 `artoria` / `taiga` / `ar2_` / `liver_resection`）→ `0` 条告警或错误
- **B. Headless 专项与回归**：
  - `tools/artoria_lv2_test.gd` → `5086 checks; 0 failure(s)`
  - `tools/emiko_lv3_test.gd` → `2453 checks, 0 failure(s)`
  - `tools/relationship_gate_matrix_test.gd` → `66 checks; 0 failure(s)`
  - `tools/boundary_save_test.gd` → `1020 checks; 0 failures`
  - `tools/narrative_save_lock_test.gd` → `6 checks; 0 failure(s)`
  - `tools/localization_test.gd` → `33 checks; 0 failure(s)`
  - `tools/voice_integration_test.gd` → `651 checks, 0 failures`
  - `tools/advanced_calendar_regression_test.gd` → `64 checks; 0 failures`
- **C. 原生 `1280×800` Metal 窗口合成 GUI 输入实机验收**：
  - `tools/artoria_lv2_preview_capture.gd`（不带 `--headless`，隔离 `/private/tmp/` 存档与偏好，通过 `root.push_input()` 点击 `OfficeEndWorkday`、逐页推进、三处选项 A/B/C 及完成页 `返回医院导览`）：
  - 结果：**`8556 checks; 0 failure(s); 1439 GUI clicks; 27 screenshots`**（`zh_CN` A/B/C + `en` A/B/C 全部通过，顺手修复 `godot/ui/app.gd` `rank_up` 副标题 `Lv.2.0` 浮点尾巴为 `Lv.2`）。
- **D. 未测范围**：
  - 未进行人工手点 OS 级键鼠通关、自动播放计时实测、语音生成（本事件暂未配音）及 Windows 导出包重打包；未读写任何真实玩家存档槽位。
