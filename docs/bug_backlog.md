# Bug Backlog

记录日期：2026-10-11

截图中的文字是用户提供的复现证据，不视为对剧情原文的改写授权。用户已授权统一修复，当前状态以本节为准；后面的初始记录保留为排查历史。

## 2026-10-11 修复与复核结果

### FEATURE-018 — 病房准备完成后的担架车转运 CG

- 状态：已接入；中英文资源注册、数据校验与术前准备 CG 无头回归通过，未进行原生窗口视觉复验。
- 内容：新增通用 stock CG，表现病房护士推着担架车将戴手术帽、盖毯并连接输液管的患者送往手术室。
- 触发：绑定 `complete_manual_ward_preparation`，在护士接手担架车后、`prepared` 页面显示前以全屏 CG 播放；不绑定特定患者，后续可由患者专属 CG 池覆盖。
- 资源：`assets/events/ward_preparation_v1/transport_to_or/01.png`；中英文标题和说明已登记。
- 验证：`preparation_asset_regression_test.gd` 6,771项通过；`validate_data.py` 628条通过；`narrative_localization_test.py` 6,901项通过；`localization_audit.py` 14,896项通过；`git diff --check`通过。

### BUG-017 — 音羽响子术中患者互动未切换英文

- 状态：已修复；静态本地化审计与专项 Godot 无头回归通过，未进行原生窗口视觉复验。
- 原因：术中患者突发互动由 `preop_session.gd` 运行时直接生成；该组 prompt、选项和患者回应没有经过既有 `runtime_english()` 解析，因此英文界面仍显示中文。
- 修复：为合作度中断互动及相邻尊严互动补充英文运行时映射，并让三组互动对象统一经过 `runtime_english()`；保留中文原文、互动 ID、效果、顺序和触发条件不变。
- 范围：仅涉及术中患者互动的显示文本，不修改音羽响子患者数据、手术流程或数值逻辑。
- 验证：`patient_intrusion_localization_test.gd` 6项通过；`surgery_english_runtime_test.gd` 21,725项通过；`narrative_localization_test.py` 6,901项通过；`localization_audit.py` 14,894项通过；`validate_data.py` 627条通过；`git diff --check`通过。

### BUG-016 — 术中步骤卡片边界与泌尿系术野 HUD

- 状态：已实施；无头专项渲染断言通过，原生窗口视觉复验尚未完成。
- 原因：`surgery_open_radical_cystectomy` 使用技术分组 `urologic`，但术野池没有该分组映射，因此 `operative_field_overlay_visible()` 直接判定不可显示；步骤提示也没有固定在卡片内部的高度约束。
- 修复：泌尿系开放术式复用现有妇科盆腔术野池；术野 HUD 默认开启；手术步骤提示固定在卡片内容区内，英文选项继续按既有按钮矩形缩放/换行，不改手术原文。
- 验证：`operative_field_hud_test.gd` 术野池、HUD节点、右上位置及闭合阶段隐藏断言通过；该测试另有既存的20张头像数量断言失败。`preop_test.gd` 因当前工作区已有的 `entrance_background` 类型推断解析错误未启动。`validate_data.py` 与 `git diff --check` 另行通过。

### BUG-015 — “手术室出逃”两句患者对白显示为 OR Nurse

- 状态：FIXED；仅修改说话人标签，不修改对白正文、说话人顺序、选项或事件流程。
- 原因：`patient_plea` 和 `patient_resists` 的 `speaker` 都是 `narrator`，且缺少节点级 `speaker_label`，运行时因此回退到事件角色 `OR Nurse`。
- 修复：两个节点统一使用中文 `不知名的女患者`；英文本地化分别使用 `Unnamed Young Patient`。技术 ID、资源路径和事件逻辑保持不变。
- 验证：`narrative_localization_test.py` 6,901 项通过；`localization_audit.py` 14,894 项通过；`validate_data.py` 627 条通过；`character_event_test.gd` 177 项通过。未进行原生窗口视觉复验。

### 普通检查 CG — 半秒保护的非全屏 splash

- 状态：已实施；中英文 Godot 无头专项测试通过，未做原生窗口视觉验收。
- 仅六个通用检查池显式启用 `presentation: splash`，保留诊室页面；至少显示0.5秒后可点击右下角“查看结果”或按Enter/Space继续，不自动消失。屏蔽下层操作，防止连击重复推进。患者专属/剧情CG维持原呈现方式，中文正文、英文文案及检查数值不变。
- 旧全屏CG的自动继续计时器改为随图片节点销毁，避免它在后续splash页面触发失效回调；全屏显示时长与按钮行为不变。
- `examination_splash_test.gd`：215项、0失败，覆盖中英六池、半秒禁用、长时间停留、键盘/连击、页面取消、专属全屏隔离、旧计时器隔离和真实诊室检查至入院流程；`backlog_boundary_test.gd`：30项、0失败。叙事本地化6,899项通过、本地化审计通过、数据627条通过、diff空白检查通过。
- 完整 `clinic_test.gd` 未通过：既有第48行存档effect history相等性断言失败，随后第266行对Dictionary调用append而中断，未到UI测试段。本次仅适配其CG查找/等待方式，没有修改存档策略或掩盖上述失败；用独立专项覆盖本次真实诊室UI路径。无头日志另有已知macOS系统CA提示。

### BUG-011～014 — 术后明日香事件、同行布局/街景、实时日历

- 状态：本轮四项已实施；专项中英 Godot 无头回归通过，原生窗口视觉复验尚未完成。
- BUG-011：将明日香术后身份提示从进入 `surgery_result` 改到 `post_surgery_return`：结算页退出和既有术后微事件结束后，结算手术再播对话，之后才回导览/跨日。不修改节点正文、说话人、选择或奖励；加班场景不因时段关闭而漏播，完成日仍属原工作日。
- BUG-012：同行邀请选项使用标准VN选项行，完成按钮使用标准单行动行；按钮底部低于对话框顶边至少6px，不再遮挡说话人或正文。
- BUG-013：经用户确认，使用内置imagegen新生成街景占位并接入普通及深夜同行。季节/昼夜专用素材尚未提供，按命名约定查找后回退到这张占位图，深夜保留遮罩。素材记录见 `research/imports/after_work_street_2026-10-11.txt`。
- BUG-014：旧日历只在页面重建时刷新，并误读已预留的次日上午工作槽。现使用实际场景/离院时间，每帧按需刷新标签；覆盖同行、跨日页、普通页面不重建、手术加班、随后剧情、手动早退、无同行、周日前夕、过午夜。加班后的剧情分钟不再泄漏成次日09:02。
- 审计：明日香JSON相对修改前仅变更 `preop_stage_id`，所有剧情原文保留；英文同用相同流程。`narrative_localization_test.py` 6,899项通过，`localization_audit.py`通过，`validate_data.py` 616条通过。
- 专项测试 `postoperative_departure_ui_test.gd`：166项通过；角色事件175项、下班同行101项、跨日边界30项、日历30项、个人护士29项、手术扫荡101项均通过。角色测试中另校正了过期的事件总数/惠美子75技能前置及动态返回值类型，仅改测试夹具，不改游戏门槛。
- 扩大测试发现 `special_event_framework_test.gd` 仍有5项失败：测试要求恢复未完成多日事件，但当前 `restore()` 明确把存档当作世界检查点并清除活动会话，两者约定冲突。本轮未改该存档策略，也未删改失败断言，需另行确认多日活动是否允许中途存取。
- 环境限制：无头Godot仍输出系统CA读取提示；原生窗口测试启动退出134，未获得窗口截图，不能宣称原生视觉回归已通过。街景原图已检查，运行时纹理路径及按钮矩形不相交已由专项测试验证。

### BUG-010 — 英文版医护首次岗位 CG 不显示

- 状态：FIXED / Godot 4.5.1 无头运行时回归通过。
- 原因：`english_runtime_fallback()` 对 `collections.staff_role_cg_rewards.*` 的所有缺译字符串一律返回 `Role Memory`，误改了 `id`、`staff_id`、`role_id`、`path`，造成奖励ID冲突和岗位查找失败。不是素材缺失。
- 修复：移除这条通用兜底；该集合仅允许 `title`、`caption` 参与本地化，技术字段即使出现误写翻译键也保留原值。补齐遥凑助手CG的两条英文文本，未改中文原文、岗位条件或存档格式。
- 验证：扩展 `tools/role_cg_asset_test.gd`，中英各检查全部26个已注册岗位CG，覆盖ID/路径一致性、首次编入实际显示、返回术前流程、再次编入不重复弹出、鉴赏纹理，以及中英双向存档恢复解锁。1,099项检查，0失败；原英文助手/器械护士选择器测试也通过。
- `narrative_localization_test.py`：6,899项，0失败；`localization_audit.py`通过；`validate_data.py`：615条记录通过；`git diff --check`通过。无头环境仍有独立的macOS系统CA读取提示，不是CG加载错误。
- 使用已有存档即可，不清空既有解锁记录。重启运行中的游戏以重新加载修复；未解锁岗位在下一次实际编入时正常触发，已解锁岗位仍只在鉴赏中查看，不重复播放首次演出。

| 条目 | 当前状态 | 实施与边界 |
| --- | --- | --- |
| BUG-001 手术英文通用占位 | FIXED | 补齐 30 个术式的 3,038 个英文键，包含步骤、选项、响应、过渡、手术记录及提示；移除将不同选项压成同一句的手术兜底。中文源文本不变。 |
| BUG-002 等待住院患者仍离院 | FIXED | 在共同的 `begin_after_work_departure()` 入口检查诊疗中、已提交/进行中的手术、待处理住院患者，覆盖手动及自动路径。 |
| BUG-003 次日回到昨日完成页 | FIXED | 清除完成页回调、返回地点及结束会话，普通次日进入医院导览，周日进入周日菜单；首次落地不立即拉起另一自动事件。未完成的既有跨日剧情链仍继续，避免截断原剧本。 |
| BUG-004 专属护士门槛/前置/时长 | FIXED | 用户确认保留“第30天或声望50”；另外要求完成明日香院长室相识后半场。改为不消耗游戏时间，列表、副标题、确认与完成页不再误报占用一天。 |
| BUG-005 普通池声望过高 | FIXED | 普通池按难度 +2～+15，阑尾 +2，质量加成后单台仍封顶15；保留累计上限、惩罚、高级教学奖励，不回退旧存档。数台高难手术仍可能达到50，符合用户选择的门槛。 |
| BUG-006 小森全屏准备CG | WAITING FOR ASSET LOCATION | 当前工程未接入；详见下方纠正说明。其他已注册准备CG通过中英文实际派发测试。 |
| BUG-007 小森术中中文 | FIXED | 截图台词来自共享 `awake_special_barks`，已补28组共84条；说明文字来自术式 `player_hint` 等字段，随 BUG-001 补齐。 |
| BUG-008 医生档案英文及重叠 | CODE FIXED | 按稳定ID在当前语言解析层级、经验及已知历史，不修改存档原标签；标签/数值/条形图分行，历史面板限宽滚动。控件边界测试通过，原生窗口目测待验收。 |
| BUG-009 macOS imgrep null | CODE FIXED / NATIVE QA PENDING | 移除 app 所有原生自定义鼠标调用，只保留游戏内工具指针，退出恢复系统指针；阻止延迟回调复活旧指针。无头测试通过，原生窗口切焦点的报错是否消失仍待实测。 |

### BUG-006：小森 CG 的复核与纠正

- 用户明确指全屏特殊CG，而不是右侧手术台立绘。准备CG注册在 `exclusive_cg_pools.ward_preparation`，不能从术后 `surgery` 池为空推断准备CG不可用；下方旧排查方向已被纠正。
- 小森当前患者包三类专属池均为空；导入清单有手术台立绘和全麻 splash，没有下刀前等全屏准备CG映射。`stage_prompts.incision_ready` 只是阶段文字，不是图片。
- 按用户提示搜索 `incision_ready_patient_*`，当前工程仅有东川杏子、香田映见、塞菲、岩井芳美四个池ID；没有 `incision_ready_patient_comoli_harcourt`。这仅说明本工程未接入，不代表用户未在别处准备素材。等待原文件位置与目标节点，不自行生成或挪用其他患者素材。
- 准备资源回归中，中英各检查42个准备池、26个手术室池，134次清醒派发及56次全麻抑制路径；保留现有全麻后不显示清醒隐私准备CG的规则。
- 初次测试发现岩井芳美新增图片未生成Godot导入缓存；完成资源导入后同一测试全部通过。小森六个手术台立绘及全麻splash加载正常。

### 防止复发的改动

- 新增 `tools/surgery_localization_test.py` 与 `tools/surgery_english_runtime_test.gd`，检查漏译、中文残留、占位符、选项区分以及中英非文本数据一致。通用审计纳入 `transition_text`、`operative_record`、`player_hint`、`variants`。
- 新增 `godot/ui/button_text.gd`，英文按钮按原矩形缩字/换行，不扩大点击区域；源标题保存在metadata及tooltip，不修改剧情数据。
- 新增 `godot/ui/player_profile_text.gd`，通过记录ID及数值解析显示文本；不盲目替换存档中文。无法识别的自定义旧标签保留原文。
- 新增 `tools/backlog_boundary_test.gd` 与 `tools/preparation_asset_regression_test.gd`，覆盖次日落地、退出指针竞态、档案显示、CG注册到实际加载和派发。

### 本轮验证结果

| 检查 | 结果 |
| --- | --- |
| narrative_localization_test.py | 6,899项，0失败 |
| surgery_localization_test.py | 3,247项，0失败 |
| localization_audit.py | UI英文682/682；全局authored覆盖13820/13895 |
| validate_data.py | 614条记录与schema/引用/图校验通过 |
| surgery_english_runtime_test.gd | 21,725项，0失败 |
| preparation_asset_regression_test.gd | 6,585项，0失败 |
| backlog_boundary_test.gd | 30项，0失败 |
| after_work_walk_test.gd | 101项，0失败 |
| personal_nurse_system_test.gd | 29项，0失败 |
| ordinary_reputation_test.gd | 1,049项，0失败 |
| surgery_progression_test.gd | 37项，0失败 |
| surgery_sweep_test.gd | 101项，0失败 |
| or_table_palpation_test.gd | 142项，0失败 |

Godot使用4.5.1 headless执行；这不是完整图形交互验收，也不代表全部历史测试均通过。全局还有75个authored字段使用原文兜底，不声称整个游戏100%英文化。测试环境另报macOS系统CA证书读取错误，与截图中的DisplayServer图像错误不同。

旧存档相关测试仍有以“恢复场景中途”为前提的过时断言，与当前世界状态检查点契约冲突，应另行统一清理，不能为迎合旧测试改回运行时行为。本轮修正了成长测试对教学门槛与高级池目录的预期，以及扫荡测试未设置战略完成状态的夹具，保留相应阻断断言。

剧情原文审计：专属护士事件JSON仅修改 `consumes_full_day` 和 `prerequisite_events`，没有变更对白、说话人、标题、选项、标点或顺序。英文补译及显示换行不写回中文剧情源。

## 初始报告（历史快照；状态及推断已由上方复核更新）

### BUG-001 — 英文手术步骤选项仍使用重复的通用文本

- 状态：OPEN / DEFERRED
- 现象：英文版部分术式的多个步骤都显示 `Proceed with the selected approach`，导致不同选项看起来完全相同。
- 范围：当前静态核对显示 32 个术式中仍有 29 个术式缺少步骤选项英文条目；乳房肿瘤术式已补过，其余多数术式仍待补齐。`Open Whipple` 与高级人工心脏置换已有对应覆盖。
- 相关链路：`data/surgeries/surgeries.json`、`data/localization/en.json`、`godot/systems/localization.gd`。
- 处理方向：补齐每个术式的步骤标题、提示、选项、响应与过渡文本，并保留术式原文语义。

### BUG-002 — 未完成住院患者时仍可能进入下班事件

- 状态：OPEN / DEFERRED
- 现象：患者已收住院、仍等待病房准备或后续手术时，某些下班/离院路径仍可启动。
- 证据：`can_end_workday()` 有未处理住院患者检查，但自动日转换中的 `pending_departure_context() -> begin_after_work_departure()` 绕过了同一防线。
- 处理方向：统一所有人工与自动离院入口的阻断条件；不要只修单一按钮。

### BUG-003 — 角色事件结束后的次日入口错误

- 状态：OPEN / DEFERRED
- 现象：临近下班时在御堂办公室触发事件，或触发深山/饭村相识事件后，事件结束并进入下班画面本身正常；但次日 09:00 会回到前一天事件结束的地点/页面，而不是医院导览。
- 期望：工作日次日一律先进入医院导览；周日一律进入周日选择界面。
- 相关链路：角色事件完成、下班/离院、`show_day_transition()`、次日入口分发。

### BUG-004 — 专属护士事件的门槛、前置与时长不符合预期

- 状态：OPEN / DEFERRED
- 复现：第 4 天、声望约 56 时触发“独立看诊”事件；事件固定指定明日香/明日香相关角色参与，但玩家尚未完成明日香相识后半段；事件显示持续 1.0 天。
- 当前配置：`data/events/special_events/personal_nurse.json` 使用 `career_progress_any`，`minimum_day: 30` 与 `minimum_reputation: 50` 实际按“任一条件满足”处理；没有明日香相识事件前置；`duration_days: 1` 且 `consumes_full_day: true`。
- 处理方向：确认设计意图后，决定门槛是 AND 还是 OR、是否加入明日香相识前置、事件是否应消耗整天，以及专属护士候选人的解锁顺序。

### BUG-005 — 声望门槛过低/增长节奏需要重新平衡

- 状态：PARTIAL — 普通池单台奖励已调整；事件门槛与整体节奏仍待处理
- 现象：玩家完成约 5–6 次手术即可达到声望 50 左右，从而触发专属护士相关系统。
- 原因：奖励档由技术难度直接决定，普通池内高难术式也会得到 +40/+75。设计稿允许高难术式留在普通池；不能据此断言它们应被搬进高级转诊池。
- 2026-10-11：按用户要求，普通池基础奖励改为随难度从 +2 到 +15 递增，阑尾保持 +2，质量加成后单台也不得超过 +15。保留现有累计软/硬上限、处置惩罚与高级教学事件奖励。旧存档已有声望不回退。
- 个人护士事件门槛仍为 50，OR 前置及时长问题仍见 BUG-004；做数台高难普通手术仍可能达到 50，不把这次奖励调整视为全部节奏问题已解决。

### BUG-006 — 新患者专属手术室 CG 不触发

- 状态：OPEN / DEFERRED
- 现象：新加入患者（用户以小森为例）有手术室 CG 素材，但英文版手术流程每一步都没有出现；病房准备 CG 可以正常出现。
- 当前静态证据：`data/surgery_cg_pools.json` 目前只有全局 `progress` 池；现有患者包的 `exclusive_cg_pools.surgery` 均为空。手术结束 CG 的选择入口存在，但患者专属手术 CG 的注册/映射/触发链路尚未闭合。
- 处理方向：核对患者包是否包含手术池、loader 是否合并到运行时集合、术式/患者 ID 是否匹配，以及英文版是否走同一池选择路径。

### BUG-007 — Comoli 英文手术流程仍有中文残留

- 状态：OPEN / DEFERRED
- 现象：附件 2 的患者术中对白仍显示中文；附件 3 的术中记录/过渡说明仍显示中文。
- 当前静态核对：Comoli 患者包的 `reaction_lines`、门诊/诊室、术前提示已有英文条目，但仍有 31 个患者包字符串路径没有 `en.json` 条目；需要继续定位截图中具体运行字段，不能只补患者反应台词。
- 处理方向：补齐患者包专属英文文本，并检查 surgery flow 的 `transition_text`、助手互动和运行时动态文本。

### BUG-008 — 英文 Doctor Profile 翻译缺失与界面重叠

- 状态：OPEN / DEFERRED
- 现象：Doctor Profile 的属性层级、手术/领导经验历史中混入中文；左侧 Clinical Presence 的中文层级标签与英文标签重叠；右侧记录面板存在文字布局重叠/溢出。
- 处理方向：补齐动态属性层级、经验历史的本地化出口，并按英文长度重新处理标签与历史记录的宽度、换行和字号。

### BUG-009 — macOS Godot 调试器反复报告 `imgrep` 为 null

- 状态：OPEN / DEFERRED
- 现象：游玩过程中 Godot 大量重复报告：`platform/macos/display_server_macos.mm:3092 - Parameter "imgrep" is null.`，随后调试进程停止。
- 当前静态证据：项目在 `godot/ui/app.gd` 中多次调用 `Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)`；该调用与截图中的 macOS DisplayServer 报错高度相关，需在运行时确认是否为直接触发点。
- 处理方向：统一清除自定义鼠标指针的实现，避免向 macOS DisplayServer 传入 null 图像；同时保留手术台虚拟指针的行为，并做进入/退出页面、窗口重新获得焦点的回归测试。

## 已核对但暂不并入新修复

- 病房准备 CG 入口与专属患者病房池的选择逻辑目前存在，和手术 CG 入口不是同一条路径；因此“病房正常、手术室不触发”应按独立映射问题处理。
- 专属护士事件的第 4 天触发不是声望数值单独绕过了第 30 天，而是 `career_progress_any` 的 OR 语义使声望条件单独满足即可解锁。
