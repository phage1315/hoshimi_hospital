# 星见医院 · Whipple 高级手术内容包 V1

**交付性质：内容资产齐备，待 Codex 对接现有 Godot 工程。**

本 ZIP 含正式采用的单张动画风格术野、Whipple 13 个 Stage 的全部演出对白（包括六个 P 的失败反馈），以及山内樱良首次病例 Day 1、Day 2 麻醉前可选单句、Day 3 首次 CLEAR 成功剧情。现有术式数值和 Runner 无须重做。

## 1. 文件与运行身份

| 文件 | 职责 |
|---|---|
| `data/whipple_day2_dialogue.json` | 按 `stage_id` 挂接 2–3 条进入变体；六个 P 各两条技术失败反馈 |
| `scripts/whipple_first_patient_day1_day3.md` | 首次专属患者 Day 1／首次 CLEAR 成功 Day 3 的可读剧本及接线条件 |
| `assets/surgery_open_whipple_field.png` | 用户最终认可的动画化 Whipple 术野；未经再次生成或修改 |
| `content_manifest.json` | 供 Codex 识别内容与运行时任务的清单；**不是**新引擎强制要求的真实 schema |

固定身份：

- `procedure_id = surgery_open_whipple`（已存在；绝对不要新建第二个同名手术或复制 Stage）。
- 首次剧情病例 `ADV-FIRST-01`，患者**山内樱良**，复用当前 `PLACEHOLDER_ADV_PATIENT_WH01`，由 Codex 核实已有项目真实 patient ID 后映射；绝不可凭空猜测资源路径。
- 13 Stages `W01..W13`（固定顺序）；`W03/W05/W06/W08/W09/W10` 是 6 个 P。
- 原 HP 基础总额 41、crisis checkpoints（W05、W10）、所有难度、HP 损耗、变量和不同性格 Staff 的真实能力都**不在本次变更范围**。
- Whipple 首次患者医疗 AU 是**胰头部局限性可切除病变**，不能擅自写成原作明确的胰腺癌诊断。

## 2. 三日内容触发合同

| 当前时机 | 应执行的内容 | 禁止事项 |
|---|---|---|
| Day 1：该具名患者首次接诊 | `DAY1_FIRST_PATIENT` 剧本 → 现有 Grand OR 编组 UI／人物原有编组确认文本 | 不增加新声望/技能 Gate，不播放返场剧情 |
| Day 2：Full Runner 全麻前 | 最多播放一次 `PRE_INDUCTION_ONE_LINE`（可选；缺少原接线则跳过） | 不在全麻后让患者说话 |
| Day 2：每个固定 Stage 第一次进入 | `stage_entry` 2–3 候选中稳定选 **1 句**，speaker 按当次 roster 解析 | 不在同一 Stage 连播所有变体；不修改 HP/判定/时间 |
| Day 2：某个 P 首次技术判定失败 | 对应 `precision_failed` 两句中选 **1 句**，`acting_surgeon` 是真实执行者 | 不提前宣称出血、危机、死亡或失败终局；不绕过原有救援规则 |
| Day 2：成功或一次救援 | 复用原 Runner 的 UI 与全局反馈，无新增 Whipple 专属长对白 | 不新增一次技术判定或无限救援 |
| Day 3：首次病例 SUCCESS 并第一次 CLEAR | `DAY3_FIRST_CLEAR_SUCCESS` 剧本 → 正常结算展示 | 非首次返场不重复樱良感谢／第四面墙对白 |
| Day 3：首次病例 FAILED | 全局统一坂口＋一助＋二助四句对白 → `FAILED_LOCKED` 结算 | **不**接入旧樱良失败小剧场 |
| Day 1/2/3：首通后 Full 返场 | 随机患者，Day 1 无具名剧情；Day 2 本文件的同一套术式/对白/图片；Day 3 普通结算 | 不复用樱良的 Day1/Day3 专属剧情 |
| `Quick Advanced` 返场 | **现有规划中的后续功能**；应跳过 Day2 阶段对白，但保持同样的真实 HP、危机、日期与奖励模型 | **本 ZIP 不实现 Quick、不承诺 Quick 已完成** |

**结算时序：** 继续遵循 Standalone V1 的 Day 3 原子结算和 `settlement_applied` 保护。进入 Day 3 只结算一次，之后播放该结果对应的剧本和结果画面；跳过剧本不撤销或重复结算。

## 3. 术中对白注册

`data/whipple_day2_dialogue.json` 遵循 `advanced_day2_dialogue_v1` 的内容格式：

```text
stage_entry              13/13 Stages，每个 2–3 个变体
precision_failed          6/6 P，每个恰好 2 个变体
precision_success         0 个专属台词（复用 Runner 操作成功反馈）
rescue_confirm / result   0 个术式专属台词（复用原系统）
```

speaker 角色只引用 `lead_surgeon`、`assistant_1`、`assistant_2`、`scrub_primary`、`scrub_secondary`、`circulating_primary`、`circulating_secondary`、`acting_surgeon`，使用现有真实 Grand OR 编组名单绑定显示。Stage 只允许一位角色说一句短技术台词；**没有任何人物个性化分支**。

三组既有对白 W03、W05、W08 按前一份 V1 示例原文保留，其余是本内容包新补齐。对话与 Stage 的数值效果**完全解耦**。

**变体轮换：** 可使用既有 Day2 Dialogue V1 文档规定的 `full_play_ordinal + stage_ordinal + trigger_offset` 取模，或 Codex 已实现的等价确定性策略；反复查看同一次 Session 不变体、不重复扣费；下一个 Full 返场轮换变体。必须与真实技术/危机 RNG 分离。

若 Godot 当前还没有本 JSON 格式的加载器，Codex 需要检查真实手术对话数据源并将这些内容**映射**过去，不能为了一个内容包另造大型 VN 系统。Stage 演出 UI 不支持时，安全 fallback 仍为原 Stage 标题与手术操作。

## 4. 术野图片接入

`assets/surgery_open_whipple_field.png` 来自用户上传并亲自确认可用的最终动画化术野。原照片对应**胰头及钩突从门静脉／肠系膜上静脉附近分离**的关键操作，图片不带任何视频字幕。

**运行表现：**

- 一张静态图片绑定到**procedure ID**，而不是樱良 patient ID；该 Whipple 手术的后续随机患者继续使用同图。
- Full Day2 显示为手术主题的核心术野；不要求随着 W01–W13 更换解剖阶段。它是代表性术野而不是动态切除进度图。
- 保持完整画面比例，适应现有术野窗口，可使用 `contain` / 等价的保比例 fit；不要强制裁掉中央深部操作区或手套。
- 没有图片时原 Runner 背景安全回退，不能因为 asset path 缺失而阻止操作。
- 不给图片增加热点、可点器官、随机手术选择或基于画面的新检测逻辑。

**注意：** 原图细节属于被接受的游戏美术，不代表已经做过逐像素医学解剖审校；本轮不重绘、不替换用户批准的视觉资源。

## 5. 本轮唯一新增的患者短句

`PRE_INDUCTION_ONE_LINE`（仅首诊具名患者、实际正式全麻之前，**可选**）：

> 樱良：「那我先睡一会儿。剩下的，就拜托你们了。」

如果已有 Runner 麻醉开始时不支持这一个钩子，直接不显示，仍可认为 Whipple 内容包完整；不能为这一句改变手术流程或对普通患者引入额外弹窗。全麻开始之后樱良无对白。

## 6. 优先级、与旧文件的冲突处理

1. 以 `HOSHIMI_ADVANCED_SURGERY_STANDALONE_CODEX_READY_V1.md` 为所有 Stage 与 HP/精细/危机规则权威，**本文不修改它们**。
2. 以 `HOSHIMI_ADVANCED_DAY2_OPERATIVE_DIALOGUE_CODEX_READY_V1.md` 为通用术中对白接口与角色绑定权威；本 JSON 是该 schema 的**第一份完整 Whipple 内容**。
3. 以 `HOSHIMI_ADVANCED_FIRST_THREE_PATIENTS_DAY1_DAY3_V0_1.md` 中**樱良的 Day1 和首次成功 Day3 原文**为文学稿来源。本包逐句保留它们；那个较早文件的「首次失败《暂时合上的笔记》」**已经被后续明确决定废弃**，绝对不能被接入。
4. Day 3 失败只使用统一四句：坂口「……这次没能成功啊。」；一助「是的。我们已经尽力了。」；二助「……辛苦了，坂口医生。」；坂口「嗯。大家也辛苦了。」；显示时一助、二助的姓名/立绘取实际编组。
5. 已确定高级池将从 20 增至**21 台**，另外新增里香 Cone 重建，不替换 CABG 或袖状肺叶切除；**本包仅负责已存在的 Whipple**，不擅自修改 master list 或新建其他 procedure。

## 7. Codex 交付与验收

- [ ] 复用现有 `surgery_open_whipple`，Stage 序列 W01–W13、6 P、41 基础 HP 和两个 checkpoint 数值完全不变。
- [ ] `13/13 stage_entry` 均能显示，且每次仅 1 句；`6/6 precision_failed` 各两句并只在真实首次操作失败后出现。
- [ ] 角色任意合法编组，姓名与立绘对应实际 roster；一助、二助没有新专属人格文本。
- [ ] 全麻后的患者没有对白；首诊 Day1/Day3 文本准确，Day3 首次成功玩梗不重复出现。
- [ ] 固定术野全程可见但不会覆盖手术操作按钮，正确回退缺图状态；图片路径由实际 Godot 资源目录决定。
- [ ] 首次手术失败正确 `FAILED_LOCKED`，只播放统一四句，不出现樱良旧失败剧本；返场失败保留 `CLEARED`。
- [ ] Day3 结算 exactly-once，保存/读取不会重放 Stage 或变更文案选择，不影响原 HP/Precision RNG。
- [ ] 如果 Quick 尚未实现，报告 `NOT_IMPLEMENTED`。不因 Whipple 内容包完整而把 Quick 误记为已完成。
- [ ] 提交具体修改的 Godot 资源／脚本路径、加载路径、测试步骤及剩余有效 placeholder，不要把新文案样本当成修改原 Stage 的授权。

**完成定义：** 在现有 Full Whipple Day1→Day2→Day3 原型上真正看到樱良首诊与首次成功剧情、所有 Stage 的术式相关单句对白、六个 P 的失败反馈及用户批准的术野图；所有判定与存档语义保持原状。**这表示 Whipple V1 内容包齐全，不表示 Quick Advanced、其余 20 台高级手术或正式 Godot 集成自动完成。**
