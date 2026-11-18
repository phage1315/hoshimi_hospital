# 阿尔托莉雅·潘德拉贡（`doc_artoria`）Relationship Lv3《不是一个人的手术》实装与验收报告（2026-11-16）

## 1. 交付概览
- **事件 ID**：`artoria_lv3_not_a_solo_operation`（`target_level: 3`，`category: "rank_up"`，`trigger_mode: "after_work"`）
- **作者原稿**：`research/source_scripts/HOSHIMI_ARTORIA_LV3_NOT_A_SOLO_OPERATION_V1_1.md`（V1.1 跨路线连续性定点修订版）
- **英文译稿**：`research/translations/artoria_lv3_en.json`（标题 `"Not a One-Person Operation"`，294 处节点正文 + 9 处选项全覆盖，0 CJK 残留，零 `Saber`／`Maiya` 代号或后期保留角色泄露）
- **门禁、连续性与结算契约**：
  - 要求已完成 `artoria_lv2_what_remains`、`level == 2`、`Familiarity >= 40`、`Leadership >= 80`、距 Lv2 完成冷却 `>= 3` 天；**不新增** `Surgery` 门槛、不要求御堂 Lv1 已完成、不要求高级转诊已解锁、不在 Lv3 重复解锁普通术式或提前解锁 Lv5 传奇术式，也不改动任何外科主任竞选胜负／让位旗标；
  - 仅限普通周一至周五工作日 `16:00–22:00` 下班离院（`OfficeEndWorkday`）触发，阻断周六／周日、次日休诊节假日、未完成住院患者、次日高级转诊 `operation_day`/`review_day` 冲突及最后两天（`max_day: 363`、`workday <= GAME_DURATION_DAYS - 2`）；
  - **第一幕双层御堂跨路线只读连续性判定**（`godot/systems/artoria_lv3.gd:cast_definition`）：
    1. 前半段休息室讨论：仅当御堂 Lv3（`emiko_lv3_today_i_lead`）已完成时走〈条件分支 A〉（追忆 CABG 台上表现），否则走默认〈条件分支 B〉（日常普外手术印象）；
    2. 【选择 1】点选选项 A 时：仅当御堂 Lv1（`emiko_lv1_first_operation`）已完成时走〈子分支 A-1〉（亲自同台感受），否则走默认〈子分支 A-2〉（尚未给御堂做过助手、基于院内观察回答）；
  - 第五幕 `@end` 原子结算：`doc_artoria` `Lv2 -> Lv3`、写入 `artoria_lv3_complete`、推进至次日 `15:00`（`completion_day_offset = 1`、`completion_absolute_clock = 900`）；公务登场护士 `nurse_hiroko`、`nurse_moe`、`nurse_ange` 的 `met`／`level`／`familiarity`／`event_history` 零改动。

## 2. 原文逐句审计报告
- `.venv/bin/python tools/artoria_lv3_source_audit.py` → **`62679 checks; 0 failure(s)`**（穷举 `2 × 2 × 3 × 3 × 3 = 108` 条跨路线＋选项组合路径，校验每句说话人归属、正文、标点、顺序及 9 个选项零数值／零旗标偏移）。
- 为适配单说话人对话框结构而执行的不可避免节点处理（保留全部原文字符与标点）：
  1. **46 处「动作描写前缀 + 冒号 + 引号角色台词」节点拆分**：在 `：` 处原字拆分为相邻的 `旁白` 节点与对应说话人节点（其中 `ar3_s4_08..09` 萌恵与安琪双人鞠躬回应标注为 `本庄萌恵・利根川安琪` / `Moe Honjo & Anji Tonegawa`）；
  2. **3 处纯文本 `Label` Markdown 单星号剥离**：`ar3_s3_2r_07`、`ar3_s3_2r_08`、`ar3_s5r_21` 去除外层 `*...*` 语法星号，避免界面直出星号，文字与标点原样保留；
  3. **跳过非玩家可见工程条件注释**：跳过第一幕条件说明行 `*(【跨路线连续性条件段落】...)*` 与 `*(【分支 A 内部跨路线条件呈现】...)*`。

## 3. 新增角色与患者立绘（6 张 RGBA 透明 PNG，`mipmaps/generate=true`）
- **爱丽丝菲尔·冯·爱因兹贝伦（成年女性患者，仅本事件剧情出场，不入随机池）**：
  - 病房病号服（`1024×1536` RGBA）：`assets/characters/artoria_lv3_v1/irisviel/ward/{smile,relieved}.png`
  - 手术帽头肩（`1448×1086` RGBA，置于 `x=440, bottom=480, width=400, height=300` 避开底部对话框与按钮）：`assets/characters/artoria_lv3_v1/irisviel/or_cap/{calm,smile,drowsy}.png`
- **阿尔托莉雅·潘德拉贡补充表情**：
  - `assets/characters/artoria_lv3_v1/doc_artoria/white_coat/shy.png`（`1024×1536` RGBA，第五幕被年轻护士拦门按在沙发上时罕见无措微赧表情）

## 4. 验证执行记录
- **A. 静态／原文／双语审计**：
  - `.venv/bin/python tools/artoria_lv3_source_audit.py` → `62679 checks; 0 failure(s)`
  - `python3 tools/narrative_localization_test.py` → `54224 checks; 0 failure(s)`
  - `python3 tools/localization_audit.py` → `88850 translations; UI 841/841; 0 hard-coded Chinese candidates`
  - `python3 tools/staff_localization_test.py` → `1209 isolated staff dialogue lines translated`
  - `.venv/bin/python tools/validate_data.py`（过滤 `artoria` / `taiga` / `irisviel` / `ar2_` / `ar3_`）→ `0` 条报错
- **B. Headless 专项与回归**：
  - `tools/artoria_lv3_test.gd` → `8236 checks; 0 failure(s)`
  - 回归：`artoria_lv2_test.gd`、`relationship_gate_matrix_test.gd`、`boundary_save_test.gd`、`narrative_save_lock_test.gd`、`localization_test.gd`、`voice_integration_test.gd` 全部 0 失败
- **C. 原生 `1280×800` Metal 窗口合成 GUI 输入实机验收**：
  - `tools/artoria_lv3_preview_capture.gd`（不带 `--headless`，隔离 `/private/tmp/` 路径，通过 `root.push_input()` 点击 `OfficeEndWorkday`、逐页推进、覆盖御堂未完成／已完成两种跨路线状态与三处选项 A/B/C 及完成页返回导览，共 7 轮完整通关）：
  - 结果：**`12914 checks; 0 failure(s); 2074 GUI clicks; 31 screenshots`**。
- **D. 未测范围**：
  - 本事件暂未生成角色语音 WAV 及可选第五幕投喂 CG；未做人工 OS 级键鼠手点、自动播放计时实测与 Windows 导出包重打包；未读写任何真实玩家存档槽位。
