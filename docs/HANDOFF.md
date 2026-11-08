# 跨工具交接记录

本文件供 Codex 与 Antigravity／Gemini 在同一工作区内交接。每次开工必须先读本文件并核对当前 `git status`／`git diff`；每完成一个独立功能、Bug 修复或一批剧本，必须将新记录放在“最新交接记录”最顶部，并把原记录完整移入“历史交接记录”。

交接文字只用于快速定位。当前代码、用户原稿、Git 差异和实际测试结果始终是事实来源。未经用户明确要求，不得自动 commit、push、reset、checkout、clean 或删除他人的未提交内容。

## 最新交接记录

### 2026-11-07 — Antigravity — 修复普通流程 UI 重叠 Bug 与滚动／状态显示优化

#### 刚刚完成

- 修复序章对话界面（`show_dialogue`）在分支选项节点（如 `aoi_question`）下，第二个选项按钮与底部 `DialogueAutoToggle`（`自动播放`）／`DialogueAutoSpeed`（`速度`）互相遮挡及压在 `PrologueDialogueBox` 底边上的问题：将 `PrologueDialogueBox` 调整至 `Vector2(55, 480)`、尺寸 `Vector2(1170, 222)`（底边 `y=702`），内部继续／选项按钮统一置于 `y=646`（高 `44`），使底部 `y=713` 的播放控制栏完整位于对话框外下方且无任何重叠。
- 修复医院导览（`show_map`）18 个地点 5 行网格首行（`y=155`）紧贴／压住副标题 `PageSubtitle`（`y=139`）的问题：将地点网格起始纵坐标下移至 `y=168`，行高间距收敛为 `minf(126.0, 515.0 / maxf(1.0, map_row_count))`（5 行时底边 `y=668 < 700`），兼顾顶部副标题与底部功能栏留白。
- 修复门诊接诊界面（`godot/ui/clinic_view.gd`）打开右侧病历面板（`MedicalRecord`）时，病历面板尺寸小于底层患者立绘（`CharacterPortrait`），导致患者头顶与裙摆从病历框上下边缘露出的穿帮问题；同时为门诊“✓ 已收住院”结算摘要补充深色底板，显著提升浅色诊室背景下的可读性。
- 统一非存档安全边界界面的“保存”按钮禁用态与悬停提示：在门诊接诊（`clinic_view.gd`）、病房／术前／手术台触诊（`preop_view.gd`）、日常微事件（`show_micro_event`）及特殊活动演出（`show_special_event`）中，当不处于安全边界或不可存档时将“保存”按钮设为 `disabled = true` 并附带明确原因 `tooltip_text`，避免误导玩家点击后才弹窗报错。
- 优化主角办公室及相关滚动列表的裁切与扩展性：
  - 将 `OfficeRelationshipScroll`（同事关系）、`EventGalleryScroll`（事件鉴赏）、`SpecialEventScroll`（特殊活动）与 `EventTestScroll` 的高度调整为各自卡片行高的整数倍加内边距，消除底部边缘把第 5 行卡片标题（如 `？？？`）横向切出一半的视觉瑕疵。
  - 为主角办公室“患者病例”（`render_cases`）补充大于 6 条记录时的 `OfficeCaseScroll` 滚动容器支持（`<= 6` 条时保持原直接子节点结构以兼容既有测试），防止中后期归档病例超过 6 名患者时溢出面板。

#### 具体新增／修改文件

- UI 视图与主控制器：`godot/ui/app.gd`、`godot/ui/clinic_view.gd`、`godot/ui/preop_view.gd`、`godot/ui/player_office_view.gd`
- 交接记录：`docs/HANDOFF.md`

说明：`godot/ui/app.gd` 保留了此前工作区未提交的成美／朝仓等全部改动，本次仅修改上述 UI 布局与按钮状态段落。

#### 已执行验证

- `python3 tools/narrative_localization_test.py`：38,377 项，0 失败。
- `python3 tools/localization_audit.py`：53,102 项，0 失败。
- `godot --headless --path . --log-file /private/tmp/hoshimi-ui-office-20261107.log --script res://tools/player_office_test.gd`：18 项，0 失败。
- `godot --headless --path . --log-file /private/tmp/hoshimi-ui-shared-office-20261107.log --script res://tools/shared_doctors_office_test.gd`：418 项，0 失败。
- `godot --headless --path . --log-file /private/tmp/hoshimi-ui-overflow-20261107.log --script res://tools/text_overflow_test.gd`：29,661 项，0 失败。
- `godot --headless --path . --log-file /private/tmp/hoshimi-ui-render-reg-20261107.log --script res://tools/event_rendering_regression_test.gd`：28 项，0 失败。
- 原生窗口化试玩与截图验证（`DisplayServer: macOS / OpenGL API 4.1 Metal`）：通过独立临时脚本走完标题（中／英）、序章旁白与成美分支选项、门诊接诊与病历展开、18 地点医院导览、主角办公室、同事关系、医生属性、白日梦目录、事件鉴赏及周日菜单，逐张核对截图确认无重叠与裁切。

#### 未完成事项与边界风险

- `tools/smoke_test.gd` 中序章文本框边界与分支推进全部通过，但该脚本第 77 行仍写死 `locations.size() == 15`（当前地点数为 18）且第 86 行遍历地点时会触发地点事件导致背景断言失败；本次未擅自改动 `tools/smoke_test.gd` 历史断言。
- 工作区内既有未提交改动（成美 Lv4／H、恋 Lv1–Lv3、朝仓 Lv5 V5.2、弥生素材等）均原样保留，未执行任何 git 写操作。

## 历史交接记录

### 2026-11-07 — Codex — 建立跨工具交接机制；成美 Lv4／H 数据第一阶段完成

#### 刚刚完成

- 在根 `AGENTS.md` 固化 Codex 与 Antigravity／Gemini 的“开工必读、完工必写”流程，并创建本交接文件。
- 已完成神宫寺成美 Lv4 固定剧情 `narumi_lv4_after_work` 的中英文数据与运行注册：共 148 个双语节点、2 个选项，并含七濑恋 Lv4 条件分支。
- 已接通该事件的跨日结算：周日 19:00 开始、周一 13:00 结束；按一次原子会话结算，事件内部不开放存档，返回流程不会重复消耗周日。
- 已导入成美双语 H Profile／Flow／Context：72 个对白池、163 条英文文本；注册结构已建立。
- 成美 Free H 当前只完成注册骨架，地点为酒店，状态保持 `pending_assets`；在身体热区和正式素材完成前不会生产开放。

#### 具体新增／修改文件

- 交接规则：`AGENTS.md`、`docs/HANDOFF.md`
- 导入与审计：`tools/import_narumi_lv4.py`、`tools/import_narumi_h_profile.py`、`tools/narumi_lv4_source_audit.py`、`tools/narumi_lv4_test.gd`
- 原稿与译稿：`research/source_scripts/HOSHIMI_JINGUJI_NARUMI_LV4_AFTER_WORK_V1_3.md`、`research/source_scripts/HOSHIMI_JINGUJI_NARUMI_H_PROFILE_AND_FLOW_V1_3_5_V3.md`、`research/translations/narumi_lv4_en.json`、`research/translations/narumi_h_en.json`
- 成美数据：`data/staff/doc_aoi/lv4_events.json`、`data/staff/doc_aoi/h_profile_v1_3_5.json`、`data/staff/doc_aoi/h_flow_v1_3_4.json`、`data/staff/doc_aoi/h_context_v1.json`、`data/staff/doc_aoi/bundle.json`、`data/staff/doc_aoi/relationship.json`
- 共享注册与运行：`godot/systems/character_event_session.gd`、`godot/systems/game_state.gd`、`godot/systems/free_h_registry.gd`、`godot/ui/app.gd`
- 结构与本地化：`data/schemas/content.schema.json`、`tools/validate_data.py`、`data/localization/en.json`、`data/localization/zh_CN.json`

说明：上述共享文件同时包含工作区内更早的朝仓、成美／恋等未提交改动；后续维护者必须查看文件级 diff，不能假定整个文件差异只属于本条记录。

#### 已执行验证

- 成美 Lv4 原稿审计：148 个节点、72 个 H 对白池，0 失败。
- `python3 tools/narrative_localization_test.py`：38,377 项，0 失败。
- `python3 tools/localization_audit.py`：53,102 项，全通过。
- Godot 成美 Lv4 专项：9,226 项，0 失败。
- 成美／恋 Lv1–Lv3 回归：66,230 项，0 失败。
- 周日跨日流程专项：3,328 项，0 失败。

#### 未完成事项与边界风险

- 成美 Free H 不得开放：`data/h/doc_aoi/h_bodymap.json` 尚不存在，正式身体热区与相关美术素材仍缺；当前阻断是有意的生产门槛。
- Lv4 酒馆段目前复用 `date_jazz_bar` 作为居酒屋近似背景；酒红色便服立绘缺失，因此相应段落暂时隐藏角色立绘。
- 成美 Lv4 与 Free H 尚未完成可见原生窗口实机验收；headless 与静态测试不能替代该项。
- 全量 `tools/validate_data.py` 仍会被工作区中既有、与本批无关的全局数据错误拖成非零；成美任务范围过滤未发现错误。不得为“清零”擅自修改无关数据。
- 宽泛的 `tools/sayaka_v2_test.gd` 仍有既存失败，涉及已删除／缺失 CG 与旧存档测试字典访问；直接周日流程专项已通过。继续修复前应先确认这些差异的当前所有者和预期。
- 当前工作区有大量未提交、删除及新增文件，包括朝仓 V5.2 CG、成美／恋 Lv1–Lv3、弥生素材等。未执行 commit、reset、checkout、clean 或自动删除；下一位维护者必须先读本文件并重新核对 Git 状态。
