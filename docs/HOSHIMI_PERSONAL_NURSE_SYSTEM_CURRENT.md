# 专属护士：当前实现与原稿差异

核验日期：2026-10-26。代码基线：`f95636a22b16c7d2dfd99e9956e32c90b3dba21e`。

本文记录实际实现及尚未接通的部分，不将“存在数据字段／辅助函数”视为完整功能已经上线。本次只更新文档，不更改事件、对白或游戏规则。

2026-10-05 原始设计已逐字归档为 [HOSHIMI_PERSONAL_NURSE_SYSTEM_V1.md](source/HOSHIMI_PERSONAL_NURSE_SYSTEM_V1.md)。历史设想与当前实现有冲突时，先参考本文的差异说明；持久化统一遵循 [v37 安全边界存档契约](save_boundary_v37.md)。

## 1. 解锁事件

正式入口是 `probation_completion_personal_nurse`（“从今天起，独立看诊”），定义位于 `data/events/special_events/personal_nurse.json`，对白链为 `probation_completion_personal_nurse_main`。

解锁要求是：

1. 游戏日达到 30，**或**职业声望达到 50；二者满足其一即可。
2. 已完成 `intro_doc_asuka_director_office`。
3. 满足特殊事件调度条件：非周日开始、非最终周，且由当前优先级及其他事件状态决定是否可安排。

这是职业成长事件，不是关系等级事件。`auto_schedule` 为真，优先级 175；不应把阈值解释为无论其他状态如何都在第 30 天强制播放。

事件 `duration_days` 为 1，但 `consumes_full_day` 为假，目前实际结算为 0 分钟，不消耗整天。它不重复、不作为开发者专用事件、不解锁画廊。

完成后设置 `probation_complete`、`personal_nurse_system_unlocked`，默认指派七瀬恋，必要时完成其相识登记；不直接提升角色关系等级。

| 语义角色 | 项目实际 ID |
| --- | --- |
| 坂口／玩家 | `PLAYER` |
| 城宮明日香 | `doc_asuka` |
| 神宮寺成美 | `doc_aoi` |
| 七瀬恋／默认专属护士 | `nurse_haru` |

原稿中的示意 ID（如 `nanase_ren`）不是当前代码引用，不应据此创建重复角色。

## 2. 选择、替换及候选范围

玩家办公室的专属护士管理界面显示当前专属护士，并提供包含姓名、关系等级和熟悉度的候选列表。选择通过 `set_personal_nurse()` 执行，不另行消耗时间。

`personal_nurse_candidates()` 只要求：`profession == nurse`、`personal_nurse.eligible == true`、已经相识。没有关系等级、魅力、手术能力门槛；目前也没有原稿提出的 `currently_available`／排班检查。

当前档案允许的 12 名候选如下；尚未相识者不会出现在实际列表中：

| ID | 姓名 |
| --- | --- |
| `nurse_haru` | 七瀬恋 |
| `nurse_rin` | 中井美佳 |
| `nurse_yui` | 朝仓美幸 |
| `nurse_ange` | 利根川安琪 |
| `nurse_hiroko` | 杉村弘子 |
| `nurse_moe` | 本庄萌惠 |
| `nurse_satsuki` | 折川皐月 |
| `nurse_iwasaki_rumi` | 岩崎留美 |
| `nurse_yoneda_shiori` | 米田栞 |
| `nurse_sonoda_itsumi` | 薗田爱实 |
| `nurse_kariya_megumi` | 狩谷惠 |
| `nurse_hikami_saeko` | 氷上冴子 |

`nurse_ishigami` 不属于上述 eligible 名单。

`resolve_outpatient_support_actor()` 的回退顺序：系统未正式解锁时为成美；正式解锁后优先当前有效指派，再尝试已符合候选条件的七瀬恋，最后回退成美。不能把失效角色 ID 当作可显示的护士。

## 3. 门诊表现与对白

门诊通过 `outpatient_support` 语义说话人解析当前辅助角色。轮到辅助角色说话时使用对应名字及立绘，患者说话时仍显示患者；当前不是所有页面始终并排常驻一张护士立绘。

界面已有“和专属护士聊两句”；档案提供 `clinic_support` 时可显示“确认护理准备”。`personal_nurse_dialogue(kind)` 随机选取该护士对应数组中的台词；缺少配置时使用通用回退。它没有实现原稿完整的 callback → 关系等级 → 情境 → 通用池优先级链。

诊断反馈由 `clinic_presentation()` 处理：

- `diagnose_gastro`、`diagnose_observe` 可从角色 `personal_nurse.diagnosis_corrections` 读取专属纠错。
- `diagnose_appendix` 可读取 `personal_nurse.dialogue.diagnosis_correct_reply`。
- 成美或缺少专属覆盖时保留共用反馈；角色覆盖不改病例答案、临床结果或操作耗时。
- 当次诊断反馈的说话人保留在运行会话内，换护士不会让同一句已发生反馈换人；正文仍从当前语言内容读取。

### 提示功能的实际边界

`next_test_hint`、`insufficient_evidence`、`sufficient_evidence` 已有通用回退文本，但 `personal_nurse_dialogue()` 不接收病例证据，也不判断哪个检查是下一步、证据是否充分。当前没有找到把这三类查询接到玩家操作的完整调用链。

共用门诊仍有检查前置线索、选项可用性和诊断反馈；这不等于原稿中两个专属护士提示入口已经完成。现有实现没有新增护士误诊率或护理能力判定，但也不能据此宣称“所有提示均由证据计算并必定正确”已通过验收。

## 4. 熟悉度、术前与手术团队

原稿的目标是每完成一名患者的门诊周期固定 +1，避免按点击奖励。当前奖励辅助函数为 `award_personal_nurse_outpatient_familiarity()`，实际调用位置是 `finish_active_surgery()` 中普通患者手术成功结算路径。

- 系统必须已解锁，解析到的辅助角色不是成美，才加熟悉度 +1；仍受熟悉度上限约束。
- 当前不会因聊天、护理准备、检查点击、仅完成诊断、住院、转诊或中断而发这笔奖励。
- 医护作为患者的特殊结算路径不调用这笔普通患者奖励。
- 领取人是结算当时的有效专属护士，不是门诊开始时冻结的角色。
- 手术团队自己的关系结算是另一套逻辑；同一角色同时参与团队时，两种来源可能同时发生。

因此不能把当前实现描述为“所有门诊结束路径都会 +1”。若要覆盖转诊等结局，需要先明确哪些业务结果属于该奖励范围，再修改调用位置与验证。

术前说明通过 `resolve_preop_explainer()` 优先使用当前有效专属护士，否则为七瀬恋。这个演出职责不强制她进入手术团队，也不增加配队豁免、岗位特权或护理数值。

没有为了本系统新增病房委派、护士能力成长、护理失误概率或每日熟悉度配额。原稿中后续回忆／亲密互动池属于扩展设想，不能因存在通用聊天入口就标作完成。

## 5. 存档与恢复

持久数据包含 `probation_complete`、`personal_nurse_system_unlocked`、`personal_nurse_id`，以及已经结算的关系结果、稳定事件完成事实和时间。

保存仅在医院导览／周日安全边界进行。解锁事件进度、门诊页码、选择路径、待确认提示和 `diagnosis_feedback_actor_id` 等演出上下文不写玩家存档。当前内存会话与持久格式明确分开，禁止为了兼容旧测试恢复门诊中途存档。

恢复时对指派资格进行检查：无效选择按候选条件回退到七瀬恋，不能选她时不保留无效指派；显示支持角色时最终可回退成美。读档不重播职业事件或重新发关系奖励。

## 6. 原稿与当前实现差异

| 原稿要求／示意 | 当前实现 | 状态 |
| --- | --- | --- |
| Day ≥ 30 或声望 ≥ 50 | 同一 OR 条件，另有院长室相识前置与事件调度门槛 | 已接入，需保留额外条件说明 |
| 默认 `nanase_ren` | 实际 ID 为 `nurse_haru` | 采用项目稳定 ID |
| 相识、护士、eligible、currently_available | 前三项；无在岗检查 | 部分实现 |
| 固定门诊陪同 | 统一辅助说话人解析，按说话阶段显示 | 不等于每页常驻第二立绘 |
| 下一步检查／证据充分性提示 | 文本接口存在，缺证据解析和完整 UI 调用链 | 未完整接入 |
| 按回忆／关系／情境分层短聊 | 当前按 kind 随机角色数组及通用回退 | 分层机制未完整实现 |
| 每完成一名患者的门诊周期 +1 | 普通患者手术成功结算时给当前有效专属护士 +1 | 结算范围与原稿表述不同 |
| 不自动绑定手术岗位 | 术前说明角色独立于团队选择 | 已保持 |
| 历史门诊中途状态保存描述 | v37 只保存安全边界业务事实 | 旧描述与测试需以现行契约为准 |

本次记录差异，不自行扩展护士系统或改写剧情填补缺口。

## 7. 核验结果与限制

2026-10-26 实际执行：

| 测试 | 结果 |
| --- | --- |
| Godot headless：`tools/personal_nurse_system_test.gd` | 29 checks，0 failures |
| Python：`tools/nurse_diagnosis_schema_test.py` | 332 checks，12 名 eligible 护士，0 failures |
| Godot headless：`tools/nurse_diagnosis_corrections_test.gd` | 未通过；旧存档测试夹具与 v37 不兼容 |

第三项测试在活动门诊中调用持久化 `game.snapshot()`，而 v37 不允许在此处保存；随后还访问旧结构 `checkpoint.progress.visit_sora`。运行产生恢复断言失败和 `progress` 字段访问错误，脚本未正常退出，本次已终止测试进程。

因此没有宣称全部护士回归测试通过。该结果说明测试夹具需要迁移，不能仅凭这些失败断定生产纠错对白逻辑错误。后续应使用明确的内存快照接口或重新驱动门诊建立测试状态，不得放宽玩家存档边界。本次未修改测试或业务代码。

29 项系统测试中直接调用奖励辅助函数的检查，只证明该函数的数值行为，不证明每种门诊退出路径都已接入。静态 schema 测试也不能替代运行时说话人、回退及切换语言的完整验证。

主要维护入口：

- `data/events/special_events/personal_nurse.json`：解锁定义及完成效果。
- `godot/systems/game_state.gd`：`personal_nurse_candidates()`、`set_personal_nurse()`、`resolve_outpatient_support_actor()`、`clinic_presentation()`、`personal_nurse_dialogue()`、`award_personal_nurse_outpatient_familiarity()`、`finish_active_surgery()`、`resolve_preop_explainer()`。
- `data/staff/*/profile.json`：候选资格、护理准备、聊天及诊断反馈覆盖。
- 门诊与管理界面：`godot/ui/clinic_view.gd`、`godot/ui/player_office_view.gd`、`godot/ui/app.gd`。
- [架构文档](architecture.md)、[v37 存档文档](save_boundary_v37.md)：现行数据与恢复边界。
