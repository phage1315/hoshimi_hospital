# Hoshimi Hospital — Advanced Surgery Day 2 术中对白轻量系统

**Codex-ready implementation supplement / V1 / 2026-10-30**

> **定位：** 本文件是现有 Advanced Surgery Standalone V1 的**纯演出扩展规范**，不是新的 Surgery Runner、随机判定系统或医疗流程规范。当前 Godot 工程及角色注册表尚未提供给本对话，所有具体接线名须由 Codex 核对工程。本文不授权重写现有三台原型的 Stage、HP、Precision、危机或结算数值。

## 0. 已确认的制作决定及优先级

1. **第一次进入某个高级术式：** Day 1 有简短患者专属剧情；Day 2 是完整手术玩法；Day 3 **首次 CLEAR 成功**有简短患者专属剧情。
2. **患者在 Day 2 开始手术并进入全身麻醉后不再说话。** 若确有麻醉前台词，最多 0–2 句，使用独立的 pre-induction hook；术中 Stage/Precision/危机对白不得使用患者说话。
3. **Day 2 医护对白按 `procedure_id + stage_id + trigger` 创作**，不按具体角色、关系、专科熟练度、性格创建分支。台词使用岗位映射的实际姓名与立绘。相同术式换任何合法团队仍是 self-contained 的完整文本。
4. 每个 Stage 的常规进入提示提供 **2–3 条同义、短小的独立变体，每次只播其中 1 条**；不得连续播完 2–3 条。不是每个 Stage 都需要完整双人对话。失败／救援／危机另按下文最低限度处理。
5. Day 1 **编组确认对白先复用现有团队编组确认机制**。高级手术的一助、二助在玩法上没有不同岗位特权；V1 不新写第一助手专属版和第二助手专属版。只有实际名单、显示位置、各自剩余额度不同。
6. **Day 3 首次失败**及返场失败使用同一组短暂的坂口＋一助＋二助固定对白和结算画面；**不播放**任何患者专属失败剧情或悲剧 CG。原《首批三名患者 Day 1/Day 3 剧本 V0.1》里每人的失败分支，在本轮决定后**废弃，不可接线**。成功剧情继续保留。
7. 首通后返场的 Day 1 不重播患者专属剧情。`Quick Advanced` 仍采用原有同风险模型，但**跳过全部 Stage-by-Stage 术中对白**；不会因为跳过台词减少手术日期、风险或奖励结算。
8. **高级术式目录现决定扩充到 21 台。** 保留原有 CABG＋瓣膜联合手术及肺叶袖状切除术，另增 `surgery_adv_ebstein_cone_reconstruction`；里香是首批剧情**第三个展示病例**，不是把现有第三台可运行肺手术覆盖。21 台完整主目录及第 21 台的正式注册变更属于另外的库存/术式任务；本文件不自行覆盖该注册表。

**冲突裁定：** 此处 Day 3 失败的最新决定，覆盖旧三患者剧本中的三个独立失败小剧场。原 Standalone V1 的数值与状态机仍权威，本文件只决定演出。

## 1. 最小系统边界

建议做成 `AdvancedOperativeDialogueAdapter` 或使用工程内已有的剧情/对话事件总线；**方法名只是语义示例，不是要求创建同名类**。

### 允许添加

- 每个 `procedure_id` 独立的数据文件，按实际现有 Stage ID 挂接文本。
- Stage 进入时从 2–3 条短对白中稳定选出 1 条。
- 精细处理失败时一条技术性状态反馈；救援只用一个全局通用确认模板即可。
- 将 `speaker_role` 解析为本次已编组的真实成员的姓名、立绘或既有 speaker 资源。
- 复用当前手术对话 UI；不存在安全复用界面时，退回为当前 Stage 的信息文字，不新建复杂的 VN 子系统。

### 禁止扩散

- 不添加任何 HP、成功率、Stability、Time、Quality、Reputation、经验、关系好感的对白副作用。
- 不添加新的 P 技术 RNG、概率判定、救援机会、危机抽签或 Strategy 决策。
- 不要求为每名助手／护士写一套新的术中人格包，也不因为某人 Surgery≥90 而切不同台词。
- 不把这一套 2–3 随机变体加到 Ordinary Surgery、Staff-as-Patient 或 Quick Surgery。
- 不给麻醉后的患者写术中意识、呻吟、对医生操作的反应等对白。

## 2. 触发设计：少而准

| Hook | 触发时机 | 每次播出 | 变体数 | V1 是否必需 |
|---|---|---:|---:|---|
| `pre_induction` | Day 2 手术开始／全麻前 | 0–2 句 | 专属可选 | 可占位 |
| `stage_entry` | **每个固定 Stage 初次进入**，在玩家实际执行节点前 | 1 句 | **2–3** | 是，内容不足可降级 |
| `precision_failed` | 此 P 的首次技术判定失败、进入纠正／救援决策前 | 1 句 | 2（推荐） | P 有内容时必需；否则系统状态提示 |
| `precision_success` | P 成功后 | 默认仅 UI 状态 `操作完成` | 0 | 否 |
| `rescue_confirm` | 玩家选择合法助手执行一次救援前 | 0–1 句，全局模板 | 1–2 全局共用 | 可复用既有选择确认 |
| `rescue_result` | 一次性救援判定完成 | 默认仅显示成功／未成功的系统状态 | 0 | 否 |
| `crisis` | **已有**生理/危机 resolver 真正触发危机后 | 若原危机已有对白则不额外播放 | 0–2（可选） | 否 |
| `day2_end` | Day 2 真实结果终止 | 原 Runner 结果画面 | 0 | 不另加剧情 |

**基本节奏：** 一台 11–13 Stage 手术，正常流程约有 11–13 句短技术对白，此外仅在真实失败或危机时补充一两句。没有必要在 5–6 个 P 全部顺利完成后再让每位医生说“成功了”。

### 精确结算顺序（避免演出导致重抽和扣费）

1. `stage_entry` 只在首次进入当前 Stage 时播放一次；完成显示后恢复原有 F/L/S/P 操作。
2. P 节点先按现有 Runner 执行玩家所选 actor 的一次技术 RNG 和 HP 基础扣费；**成功则进入原有后续流程**。
3. 仅失败时播 `precision_failed`，再显示已规定的 `自行纠正／请求一助救援／请求二助救援` 合法选项；不能因为对白暂停而提前执行救援或增加一次失败成本。
4. 选择救援后调用**原有一次性**救援 resolver；不写新的救援 RNG；角色或系统呈现结果。
5. 既有危机事件已带具体对白／提示时，**不要再叠加一段同义「危机发生」对白**。
6. HP<=0 或已有生理终止条件到达时立刻结束剩余 Stage；不因为排队中的对白继续推进手术，不显示与失败结果矛盾的「操作圆满完成」。

## 3. Speaker 岗位映射：完全不个性化

允许的 `speaker_role`：

| 值 | 运行时绑定 |
|---|---|
| `lead_surgeon` | 玩家坂口 |
| `assistant_1` | Day 1 确认的一助，使用真实姓名和立绘 |
| `assistant_2` | Day 1 确认的二助，使用真实姓名和立绘 |
| `scrub_primary` / `scrub_secondary` | 当次主／副器械护士 |
| `circulating_primary` / `circulating_secondary` | 当次主／副巡回护士 |
| `acting_surgeon` | 当前 P 的真实操作人（坂口或实际被委托助手），**只能用于 P 判定之后** |
| `rescue_assistant` | 本次救援实际选择的助手，**只能用于救援已经选定之后** |
| `system` | 不显示人物立绘的手术过程旁白／状态文字 |

V1 不强求增加 `anesthesia` 说话角色，除非现有真实麻醉位已能稳定映射。非医护人员不能因被选为 speaker 而取得 P 操作资格。台词不可用硬编码人名代替岗位绑定。

一助与二助作为技术岗位**完全对等**，既有的每人一次、符合 90+ 专科或特殊专家时至多两次介入，以及 14 日历天冷却仍严格按原 Runner 计算；本文件不触碰这些逻辑。

语义原则：每条 `stage_entry` 只表达对当前阶段的观察、准备或指令。它必须适用于所有合法编组，不能暗示某位具体医生已经接手，也不能提前宣布一个尚未发生的成功／危机结果。

## 4. 可投喂 Codex 的内容数据格式

以下 JSON 展示**完整的数据字段结构**，但只给出 Whipple 的三个 Stage 作为**内容样例**。绝不能把未列出的其他 Stage 当作已经写完或从手术中删除。实际 Godot 文件格式请 Codex 检查当前工程后选择现有可加载资源方案；不应仅为读取 JSON 再引入第三方解析器。

```json
{
  "schema_version": "advanced_day2_dialogue_v1",
  "procedure_id": "surgery_open_whipple",
  "stages": {
    "W03": {
      "stage_entry": [
        {"id": "W03_E1", "speaker_role": "assistant_1", "text": "粘连范围比较广，先确认分离层次。"},
        {"id": "W03_E2", "speaker_role": "lead_surgeon", "text": "这里的组织层次不清楚，分离要仔细。"},
        {"id": "W03_E3", "speaker_role": "assistant_2", "text": "先把术野暴露稳定，再继续分离。"}
      ],
      "precision_failed": [
        {"id": "W03_F1", "speaker_role": "acting_surgeon", "text": "……这个分离层次需要重新调整。"},
        {"id": "W03_F2", "speaker_role": "acting_surgeon", "text": "先停一下，这一处还需要修正。"}
      ]
    },
    "W05": {
      "stage_entry": [
        {"id": "W05_E1", "speaker_role": "lead_surgeon", "text": "门静脉就在附近，控制好牵拉。"},
        {"id": "W05_E2", "speaker_role": "assistant_1", "text": "血管边界已经看到了，接下来要细一点。"}
      ],
      "precision_failed": [
        {"id": "W05_F1", "speaker_role": "acting_surgeon", "text": "这里的处理不够稳妥，需要调整。"},
        {"id": "W05_F2", "speaker_role": "acting_surgeon", "text": "暂缓继续，这一步还没有处理到位。"}
      ]
    },
    "W08": {
      "stage_entry": [
        {"id": "W08_E1", "speaker_role": "scrub_primary", "text": "胰肠吻合需要的缝线已经准备好了。"},
        {"id": "W08_E2", "speaker_role": "lead_surgeon", "text": "接下来是胰肠重建，先确认吻合位置。"}
      ],
      "precision_failed": [
        {"id": "W08_F1", "speaker_role": "acting_surgeon", "text": "吻合还没有达到要求，需要重新处理。"},
        {"id": "W08_F2", "speaker_role": "acting_surgeon", "text": "先不要继续下一步，这里必须修正。"}
      ]
    }
  }
}
```

**注意：** `precision_failed` 只表示本次技术挑战失败；不能自动写成「门静脉破裂／患者大出血／心律失常」，因为 HP 技术失败并没有自动设定那些具体生理 flags。只有现有危机系统实际触发对应事件，台词才可陈述该结果。

### 数据校验

- `procedure_id` 必须对应已注册的真实 Advanced procedure，`stage_id` 必须对应其当前 Stage 表且不可重名。
- 每个**已正式制作完成**的 Stage 都有 2–3 个 `stage_entry` 变体，单个变体只含一名 speaker 的一条短句，推荐约 10–35 个汉字；不写多行剧场或角色私事。
- `precision_failed` 仅可用于 `kind=P` 的阶段，制作时推荐 2 条；`kind=F/L/S` 不允许添加失误台词。
- 同一 Stage 下变体是**同一时刻、同一事实、同一操作前提**的不同表述；不得有的版本说已成功，有的版本说正在失败。
- `stage_entry` 不得包含具体患者姓名；首通具名患者与返场随机患者共用该术式文本。
- 对医学前置条件不同的 repeat variant，必须由术式数据保证适用，或以后扩展 `case_variant_id` 分支；**V1 不悄悄把需要 ASD 的 Cone 病例变成所有患者都有 ASD 的医学常识**。
- 禁止任何内容字段携带 `hp_delta`、`surgery_bonus`、`relationship_delta` 等数值效果。

## 5. 低成本防重复：确定性的轮换，而不是新 RNG

不新增随机数系统。推荐把某个术式**完整 Day 2 Full 进入次数**记为 `full_play_ordinal`（从 0 起，仅实际开始一台新 Full Session 时增加一次；返回标题、加载或重复打开 Stage 不增加）。

单个可播放的文案组使用：

```text
variant_index = (full_play_ordinal + stage_ordinal + trigger_offset) % variant_count
```

- `stage_ordinal` 来自术式 Stage 列表中的稳定顺序，0 起；`trigger_offset` 固定：`stage_entry=0`、`precision_failed=1`。不使用跨语言不稳定的内置 `hash()`。
- 在同一术式下一次 Full 返场时，同一个 Stage 会轮换到另一条变体；2 个变体交替，3 个变体依序轮换。不同 Stage 内容本身不同，不需要把全术式的句子随机打乱。
- 对本次 Session 已选择的 `variant_id` 写入 episode 的已解决展示记录／存档字段。重新进入当前 Stage、恢复存档后不能改变此前已经展示的文案，也不能重播到造成玩家多点击的程度。
- `full_play_ordinal` 和 `variant_id` 仅属于演出层；**绝不消费 Precision／解剖变体／危机／Day 1 成功率预测的 RNG**。
- 最低限度允许 POC 先使用 `case_instance_id` 派生的稳定序号；如果现有 Save 结构不适合存一个全新计数器，Codex 应说明复用方案，而不是重建存档框架。

**重要边界：** 如果玩家读取同一时点的旧存档重新尝试同一次病例，看到相同文案并不是 bug——玩家也回到了相同的故事状态；轮换的目标是**真实下一次返场**避免逐字重复。

## 6. Day 1 编组确认：直接复用

1. 选择一助、二助仍调用已有 Staff 编组／确认对白；如果现有实现没有某人的该类型对白，用目前普通 Surgery 的通用确认文本或者「了解。」作为单句 fallback。
2. **不新增** `role=assistant_1` 专属版、`role=assistant_2` 专属版；同一医生任一位置可复用同一句编组确认。不同位置的技术次数／冷却逻辑由原有团队数据决定，绝不从对白推导。
3. 其他护士岗位也先使用现有 confirmation 或静态 UI；不为高级手术制作整套角色编组对白。
4. 编组取消、切换人选不触发时间消耗／14 天冷却；以原 Day 1 提交确认和 Day 2 参加手术规则为准。

## 7. Day 3 失败只保留统一的四句短对话

这部分是**最新正式决定**，并覆盖旧《首批三患者 Day1/Day3》中的三个失败分支：

```text
坂口：「……这次没能成功啊。」
第一助手：「是的。我们已经尽力了。」
第二助手：「……辛苦了，坂口医生。」
坂口：「嗯。大家也辛苦了。」
```

- 显示时 `第一助手`／`第二助手` 应分别替换为 Day 1 编组的**真实姓名＋可用立绘**，没有立绘时使用正确姓名的文本展示。
- 首次失败结算仍形成 `FAILED_LOCKED`；首通之后返场失败仍保留 `CLEARED`。不改变 HP、Reputation、XP 或助手冷却结算。
- 可以快速跳过对白，但不能跳过 **Day 3 原子结算**。失败没有患者立绘、患者台词、患者病情悲剧或新 CG。
- Day 3 首次 CLEAR 成功仍播放具体患者短剧情（樱良／濑津美／里香），返场成功仅普通结算。

## 8. 与既有 Runner 的最小接线示意

下列为**语义接口**，由 Codex 按工程当前真实 signal / state machine / Dialogue UI 适配；不强制新增独立 GDScript singleton。

```text
on_advanced_full_day2_started(episode):
    load dialogue_data[episode.procedure_id] if present
    bind speaker_role -> episode.locked_grand_or_roster

on_stage_enter_once(stage_id):
    display exactly one stage_entry variant if available
    otherwise display existing stage title (no missing-data crash)
    then return control to existing F/L/S/P Runner

on_precision_first_roll_resolved(stage_id, actor_id, outcome):
    if outcome == FAILED:
        display one precision_failed variant (acting_surgeon=actor_id) if available
        otherwise use existing failed-status UI
    proceed to unchanged existing rescue/self-correction resolver

on_quick_advanced():
    do NOT play stage text
    execute unchanged standard planned HP + Precision + crisis/physiology resolution

on_day3_failed(episode):
    apply existing atomic Day3 settlement exactly once BEFORE rendering
    show fixed four-line team conversation once / skippable
    then show existing result screen
```

如果已有 VN／手术 UI 会因为新一句台词阻塞下一 Stage，Codex 可以将单条技术对白合入当前 Stage 标题下方的 speaker 气泡或对话日志，让玩家按原按钮继续；不另造一套「点一次读文本、再点一次执行 Stage」的复杂交互。关键目标是**能看见真实姓名说术式相关的一句话，且绝不影响技术判定顺序**。

## 9. 目标内容量、后续批量生成规则

每台 11–13 Stage 手术，完成版建议：

| 文本类型 | 每台推荐 |
|---|---:|
| `stage_entry` | 约 22–39 条（每阶段 2–3 个变体） |
| `precision_failed` | 约 10–12 条（5–6 个 P × 2） |
| 成功／救援反馈 | 复用系统通用，不单独逐术式制作 |
| 医护人物专属 Day 2 句子 | **0 条** |
| Day 1 编组确认 | 复用已有内容 |

这意味着新增一名可以作为高级助手的角色，**无须回头为 21 台手术增写台词**。将来逐台制作术式文本即可，主系统 V1 可以先让已有三台（Whipple／Pelvic／Sleeve）和新加入 Cone 病例用少量演示文本跑通，再针对完整 21 台补齐。

### 给文本生成对话的可复用 Prompt 模板

> 你在为《星见医院》高级手术 `PROCEDURE_ID` 编写 Day 2 术中单句对白。只能使用我提供的真实 `stage_id/kind/name` 清单，不修改 Stage 顺序、手术医学步骤及 HP/难度。每个 Stage 写 2–3 条 `stage_entry` 变体，每个 `kind=P` 的 Stage 再写 2 条 `precision_failed` 变体。每条只含一名医护角色的一句简短专业台词（约 10–35 个汉字），speaker 只能使用 `lead_surgeon, assistant_1, assistant_2, scrub_primary, scrub_secondary, circulating_primary, circulating_secondary`；P 失败可使用 `acting_surgeon`。台词必须与该术式当前阶段相关，语义等价且不暗示尚未发生的成功、出血、危机或器官损坏，不提具体患者姓名、不写医护性格、私人关系或术中闲聊。麻醉后的患者禁止出声。每台手术输出与 `advanced_day2_dialogue_v1` 兼容的 JSON，Stage ID 全覆盖、每条 ID 唯一。

## 10. Codex 验收清单

1. [ ] 原三台测试术式不改任何既有 HP、P、S、危机、时间、奖励规则；新增对话数据可以不存在而不阻塞手术。
2. [ ] 打开任意真实 Grand OR roster，`assistant_1/assistant_2/scrub_*` 的姓名和立绘对应正确人物；更换成员后无需改术式对白数据。
3. [ ] 单个 Stage 只显示一条 `stage_entry` 变体；最多 2–3 候选不是连播。
4. [ ] 不同新 Full 返场病例在同一个 Stage 避免紧邻两次同一台词；存档中恢复相同 Session 不变体、不多显示、不多扣 HP。
5. [ ] P 成功无额外冗长台词；首次失败只播一条结果反馈，然后出现既有合法救援／纠正选项；不提前宣布失败造成的具体生理并发症。
6. [ ] 护士只讲话和提供已有护理加成，永远不能代替医生承担 Precision Challenge。
7. [ ] `Quick Advanced` 完全跳过 Stage-by-Stage 对话，但仍由原 Runner 结算风险和日期。
8. [ ] Day 1 成功确认使用已有角色确认对白；一助／二助不需两套专属文本。
9. [ ] 首次失败／返场失败仅固定四句短台词加原结算；不出现旧三患者失败小剧场。Day 3 无法因跳过台词而重复或漏掉结算。
10. [ ] 麻醉后没有患者术中对白；首次 CLEAR 成功保留三人各自的 Day 3 专属成功剧情，返场不重复首次剧情。
11. [ ] 若 Godot 当前已有手术日志、台词自动播出、speaker ID 等接口，复用它们；说明确切修改文件及保留的 fallback，避免臆造 API。
12. [ ] 不将 `surgery_adv_ebstein_cone_reconstruction` 误用来覆盖已有肺叶袖状切除；21 台库存正式接入另行核对 ID/清单。

---

**完成定义：** 选择任意合法团队执行一台 Full Advanced 手术，玩家能够在每个 Stage 看到该术式相关的一句技术性台词，并在失败时得到简短的专业反馈；换另一套医护名单仍可直接播放；再次返场能轮换台词；快速模式和 Day3 正确跳过/结算。全程无需新增角色专属术中剧本，也不会改变原有手术成功率。
