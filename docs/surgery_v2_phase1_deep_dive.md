# 手术系统 V2 第一阶段深度设计

> 实施状态：里程碑 **1A 已通过实机验收，1B 已完成实现但按用户决定暂缓剩余实机验收，1C 已于 2026-09-28 完成实现并等待实机验收**。当前版本包含 47 条普通清醒患者互动，覆盖六种有效互动主题、七个术式类别和六台代表性术式的 signature interaction；11 台较长手术在现有四步结构中增加中段持续互动标记。恶心、嗜睡临时状态的自然到期继续由自动测试覆盖，待第二阶段多步骤术式一并实测。现有 25 种术式仍使用四个技术步骤，详细术式扩展留给第二阶段。

## 1. 实施结论

第一阶段不建议一次性交付。它同时涉及内容 schema、内容加载、手术状态机、患者事件 UI、团队委托、临时状态和存档入口。一次实现虽然可行，但实机测试发现问题时，很难判断问题来自数据匹配、流程转换、临时状态还是显示层。

第一阶段拆成三个连续里程碑：

1. **1A：普通患者互动引擎与术中存档锁**
2. **1B：临时状态与团队委托**
3. **1C：通用对白覆盖、全术式标记与稳定化**

每个里程碑都必须保持游戏可运行、数据可验证，并有独立的实机测试清单。1A 和 1B 之间不保留临时兼容层；后续里程碑直接扩展前一里程碑的数据契约。

## 2. 第一阶段完成后的玩家流程

```text
选择当前手术步骤
  ↓
显示助手、器械护士或巡回护士的团队回应
  ↓
玩家确认团队回应
  ↓
全麻？
  ├─ 是 → 直接进入下一手术步骤
  └─ 否
       ↓
     当前是否有应触发的临时状态？
       ├─ 是 → 显示 nausea / drowsiness 事件
       └─ 否 → 按 theme + dominant state + cues 匹配普通患者互动
                    ↓
                  玩家选择亲自回应、要求配合、忽略或委托团队
                    ↓
                  显示患者或团队成员的回应
                    ↓
                  结算时间与患者四项状态
                    ↓
                  进入下一手术步骤
```

每个手术步骤最多触发一个患者事件。错误的技术选择只显示助手纠正并返回当前技术步骤，不触发患者事件，不消耗患者互动，不更新临时状态。

## 3. 手术流程内部状态机

现有多个布尔值可以继续保留作为外部兼容字段，但 V2 内部建议使用一个明确模式，避免互相矛盾的组合。

建议模式：

```text
STEP_CHOICE
STAFF_RESPONSE
PATIENT_CHOICE
PATIENT_RESPONSE
```

### 3.1 STEP_CHOICE

- 显示当前 `surgery_flow_stage.prompt`。
- 显示当前阶段的技术或团队选项。
- 接受 `surgery_step` 事件。

错误选项：

```text
记录错误历史
→ procedure_corrections +1
→ STAFF_RESPONSE
→ 确认后回到同一个 STEP_CHOICE
```

正确选项：

```text
记录正确历史
→ STAFF_RESPONSE
→ 确认后尝试解析患者事件
```

### 3.2 STAFF_RESPONSE

- 显示当前回应岗位对应的团队成员立绘和台词。
- 错误纠正确认后返回原步骤。
- 正确回应确认后调用一次 `resolve_patient_event_for_stage()`。
- 患者事件只在这里解析一次，不能在 UI 重绘时重新解析。

### 3.3 PATIENT_CHOICE

- 显示患者台词、患者立绘、四项指数和可选行动。
- 接受 `patient_interaction_action` 事件。
- 选择后立即应用时间、患者指数和临时状态效果。
- 如果行动委托给团队成员，`PATIENT_RESPONSE` 使用该成员立绘和回应。
- 否则使用 action 指定的患者、主角或旁白回应。

### 3.4 PATIENT_RESPONSE

- 显示行动结果。
- 确认后清理当前患者事件。
- 完成当前手术阶段并增加 `procedure_step_index`。
- 进入下一个 `STEP_CHOICE`，或在最后一步后进入手术执行/结果流程。

### 3.5 无患者事件

正确的团队回应得到确认后，如果没有患者事件：

```text
直接完成当前 stage
→ procedure_step_index +1
→ 下一 STEP_CHOICE
```

## 4. 普通患者互动匹配

### 4.1 Dominant state

参与计算的状态和阈值：

| 状态 | 进入比较的条件 | 严重度 |
|---|---|---|
| fear | `fear >= 70` | `fear / 100.0` |
| pain | `pain >= 60` | `pain / 100.0` |
| dignity | `dignity <= 40` | `(100 - dignity) / 100.0` |
| cooperation | `cooperation <= 40` | `(100 - cooperation) / 100.0` |

取严重度最高者。没有达到阈值的状态时返回 `default`。

完全相同的严重度需要固定规则以保证确定性。建议只在完全相同时采用：

```text
pain → fear → dignity → cooperation
```

这不是日常优先级；只有浮点严重度完全相等时才用于打破平局。

### 4.2 术式上下文

每个 surgery 增加必填字段：

```text
procedure_group
```

第一版允许：

```text
general_abdominal
female_pelvic
breast
urologic
thoracic
cardiac
vascular
```

每个普通互动 variant 增加：

```text
procedure_groups: string[]
surgery_ids: string[]
once_per_surgery: boolean
```

一个 variant 只能属于一种上下文范围：

```text
surgery_ids 非空、procedure_groups 为空
  → 具体术式专属

surgery_ids 为空、procedure_groups 非空
  → 术式类别专属

两者都为空
  → 通用对白
```

不允许两者同时非空。否则带有具体器官含义的对白可能通过 group 条件泄漏给同类别的其他术式。

这套上下文属于第一阶段。它描述“正在做什么手术”，不描述“患者是谁”。命名患者、人物性格和关系覆盖仍属于第五阶段。

### 4.3 Variant 匹配顺序

给定当前：

```text
theme = stage.awake_interlude
cues = stage.patient_cues
dominant_state
```

先决定上下文层级：

1. `surgery_ids` 包含当前 surgery id。
2. `procedure_groups` 包含当前 procedure group。
3. `surgery_ids` 和 `procedure_groups` 都为空。

只要较高层级存在可用匹配，就不进入下一层级。每个上下文层级内部再按以下顺序匹配：

1. theme 相同、states 包含 dominant state、cues 有交集。
2. theme 相同、states 包含 dominant state、variant cues 为空。
3. theme 相同、variant states 为空、cues 有交集。
4. theme 相同、variant states 为空、variant cues 为空。
5. 当前上下文层没有匹配时，进入下一上下文层。
6. 三层都无匹配时跳过患者事件并继续手术。

`default` 不需要加入 states enum。稳定患者使用 `states: []` 的通用 variant。

这种“上下文层级 → 状态/cue 精度”的字典序匹配，允许术式专属对白拥有自己的稳定患者 fallback，也允许缺少专属内容时自然回退到类别或通用池。

### 4.4 防重复

运行时维护：

```text
patient_interaction_history: string[]
```

在当前最高匹配优先级的候选中：

1. 按数据文件顺序选择第一条未使用记录。
2. 候选全部使用过以后，重新选择第一条。
3. 记录在事件进入 `PATIENT_CHOICE` 时写入，UI 重绘不重复写入。

`once_per_surgery == true` 的记录在使用过以后永久排除，不参与循环重用。它适合器官切除认知、器官保留确认等 signature interaction。普通记录仍按候选池循环。

## 5. 临时状态生命周期

第一版仅支持：

```text
nausea
drowsiness
```

运行结构：

```json
{
  "nausea": {
    "severity": 1,
    "remaining_steps": 2
  }
}
```

### 5.1 创建和持续

每个正确完成的清醒手术步骤按以下顺序处理：

1. 对进入本步骤以前已经存在的状态执行 `remaining_steps -= 1`。
2. 删除 `remaining_steps <= 0` 或 `severity <= 0` 的状态。
3. 根据本步骤的 `nausea` / `drowsiness` cue 创建尚不存在的新状态。
4. 新状态在创建步骤不扣除 remaining steps。
5. 从活动状态中选择本步骤要显示的临时状态事件。

`initial remaining_steps = 2` 表示：

```text
创建步骤显示一次
→ 下一步骤递减为1，仍可再显示一次
→ 再下一步骤递减为0并移除
```

### 5.2 多状态优先级

- severity 较高者优先。
- severity 相同：`nausea` 优先于 `drowsiness`。
- 未被选中的状态仍正常递减持续时间。
- 临时状态占用本步骤的唯一患者事件名额，不再显示普通互动。

### 5.3 处理效果

临时状态 action 使用：

```json
"condition_effect": {
  "severity_delta": -2,
  "remaining_steps_delta": 0,
  "clear": false
}
```

结算顺序：

1. 应用 severity delta。
2. 应用 remaining steps delta。
3. `clear == true` 时立即移除。
4. severity 或 remaining steps 小于等于0时移除。

忽略行动不改变 severity，只让状态按照正常生命周期继续。

## 6. 时间结算

患者互动 action 的 `minutes` 同时计入：

- 整个术前与手术 session 的 `minutes`。
- 新字段 `procedure_extra_minutes`。

结果页显示：

```text
procedure_total_minutes = procedure_minutes + procedure_extra_minutes
```

其中 `procedure_minutes` 仍为术式基础时长。这样患者互动产生的暂停会反映在最终手术用时中，又不会影响术前准备时间的既有结算。

错误技术选项和单纯确认团队回应不增加额外时间，除非以后另行设计。

## 7. 数据文件设计

### 7.1 `patient_interactions.json`

顶层必须是数组，以适配现有 content loader：

```json
[
  {
    "id": "strain_pain_traction_01",
    "theme": "strain_interaction",
    "states": ["pain"],
    "cues": ["traction", "deep_manipulation"],
    "procedure_groups": ["general_abdominal"],
    "surgery_ids": [],
    "once_per_surgery": false,
    "prompt": "「等等……刚才里面那一下好痛。」",
    "speaker": "patient",
    "actions": [
      {
        "id": "pause_and_explain",
        "label": "暂停片刻并说明当前进度",
        "response": "「好……让我缓一下，我还能继续。」",
        "response_speaker": "patient",
        "delegate_role": "",
        "minutes": 2,
        "effects": {
          "fear": -5,
          "pain": -8,
          "dignity": 4,
          "cooperation": 4
        },
        "condition_effect": null
      }
    ]
  }
]
```

普通互动的 `condition_effect` 固定为 `null`。临时状态 action 才能使用对象。

### 7.2 `temporary_conditions.json`

```json
[
  {
    "id": "nausea",
    "trigger_cue": "nausea",
    "initial_severity": 1,
    "remaining_steps": 2,
    "prompts": {
      "1": "「医生……我有点恶心。」",
      "2": "「医生……越来越恶心了。」",
      "3": "「等等……我真的快吐了……」"
    },
    "actions": []
  }
]
```

每个状态定义自己的 actions。运行时不硬编码处理按钮和效果。

### 7.3 `surgeries.json`

所有 surgery 增加必填：

```json
"procedure_group": "general_abdominal"
```

所有 stage 增加必填：

```json
"patient_cues": []
```

第一阶段暂不扩充手术步骤数量。先在现有四步流程上验证互动引擎，步骤扩充属于第二、第三阶段。

## 8. 团队委托

第一版允许：

```text
""                    主刀亲自处理
assistant_surgeon     助手医生
circulating_nurse     巡回护士
```

不允许委托器械护士处理患者状态。

选择委托 action 后：

- 从当前手术团队读取对应岗位的实际人物。
- 显示该人物的无菌服/手术服立绘。
- 记录 `last_staff_role` 和 `last_staff_id`。
- 使用 action 的 staff response。
- 结算 action 自身定义的效果。
- 第一阶段不检查或消耗支援点。

如果数据要求委托的岗位不存在，验证器应阻止该内容进入游戏；运行时仍需安全拒绝事件而不能崩溃。

## 9. 手术中存档规则

### 9.1 判定

在 `PreopSession` 提供单一判定函数：

```text
surgery_in_progress = flags contains surgery_started AND surgery_success == false
```

在 `GameState` 提供：

```text
can_save_progress()
save_block_reason()
```

只要当前 active preop 的 `surgery_in_progress` 为 true，保存就被拒绝。

### 9.2 双层限制

- `preop_view.gd` 禁用保存按钮并显示 tooltip。
- `app.gd` 的 `save_progress()` 再次检查并显示提示。
- `save_store.gd` 在写文件前调用状态对象的保存许可函数，作为后端保护。

任何一层遗漏都不能导致手术中实际写入存档。

### 9.3 读取存档

手术中允许读取已有的术前存档。读取会放弃当前未保存手术并回到最后一次合法保存点，沿用现有确认弹窗。

## 10. 分里程碑实施

### 10.1 里程碑 1A：普通互动与存档锁

### 实现内容

- 扩展 `surgery_flow_stage` schema。
- 给全部现有术式增加 `procedure_group`。
- 给当前全部 stage 增加 `patient_cues`。
- 新增数组型 `patient_interactions` collection 和 schema。
- 把普通患者互动从 `preop` 跳转改成 `surgery_flow` 子状态。
- 实现 dominant state、术式上下文、variant 匹配和防重复。
- 提供最小通用、general abdominal、female pelvic 和 breast 测试对白，用于验证上下文选择；完整内容池留到 1C。
- 实现患者互动 action 对四项状态和时间的影响。
- UI 显示患者 prompt、action、回应和四项状态。
- 禁止手术中保存，保留读取术前存档。
- 保持现有四步术式，暂不加入 nausea、drowsiness 和团队委托。

### 我方验证

- JSON 和 schema 验证。
- 自定义 validator 验证。
- 静态检查所有 collection 引用和 action ID。
- 检查所有当前术式均有 `patient_cues`。
- 不启动实机 UI。

### 用户实机测试

1. 全麻完成一台手术，应完全没有患者事件。
2. 局麻或硬膜外完成一台手术，应在指定步骤出现患者互动。
3. 无麻醉完成一台手术，观察 pain/fear 对台词选择的影响。
4. 使用相近患者状态分别测试阑尾、子宫和乳房手术，确认类别对白不同。
5. 故意选择错误技术答案，应返回原步骤且不弹患者事件。
6. 手术开始前应能保存；开始后保存按钮应禁用。
7. 手术中尝试触发保存，不应覆盖已有存档。
8. 手术中读档，应能回到术前保存点。

### 反馈重点

- 患者互动出现时机是否自然。
- 团队回应和患者回应之间是否点击过多。
- 状态条是否容易理解。
- 存档锁边界是否符合预期。

### 实机验收结果（2026-09-26）

- 全麻：患者保持无反应，且不显示导尿、消毒、下刀三类患者 CG；麻醉 CG 正常。
- 硬膜外与无麻醉：患者互动能够出现，回应后返回原手术步骤。
- 术式上下文：乳房、妇科盆腔、心脏及普通腹部反应均与术式一致。
- 通用回退：非心脏开胸和泌尿手术未串入其他类别台词；泌尿手术的牵拉感反应符合预期。
- 流程边界：手术进行中不能离开手术室进入医院导览，人物事件不会打断手术。
- 本轮测试发现的流程跳转、字典访问、全麻 CG 和角色服装问题均已修复并复测通过。

### 10.2 里程碑 1B：临时状态与团队委托

> 当前状态：代码、数据 schema、验证规则与自动测试已完成；恶心四种处理路线及忽略后的跨步骤持续已通过实机测试。现有四步术式在二级恶心到达自然到期以前已经结束，因此自然消失的实机观察推迟到第二阶段多步骤术式；到期删除逻辑由自动回归测试覆盖。其余项目继续等待下列实机测试确认节奏与显示。

### 实现内容

- 新增 `temporary_conditions` collection 和 schema。
- 实现 nausea / drowsiness 创建、优先级、持续和清除。
- 实现 `condition_effect`。
- 实现助手医生和巡回护士委托。
- 实现团队成员立绘和回应。
- 增加 `procedure_extra_minutes` 和结果页总用时。
- 为测试术式设置少量 nausea / drowsiness cue。

### 我方验证

- 临时状态定义和 action 验证。
- 检查委托岗位合法。
- 检查每个状态 severity 1–3 均有 prompt。
- 检查状态不会与普通互动在同一步重复出现。

### 用户实机测试

1. ~~触发 nausea，分别测试主刀、助手、巡回护士和忽略。~~（已通过）
2. 触发 drowsiness，分别测试主刀、助手、巡回护士和忽略。
3. 忽略状态后确认它只持续规定步骤数。（跨步骤持续已通过；自然到期留待多步骤术式实测，自动测试已覆盖）
4. 同时存在两个状态时确认严重度和固定平局规则。
5. 委托后确认显示的是实际上场成员而非固定角色。
6. 确认患者事件增加的分钟数进入最终手术用时。
7. 全麻时确认临时状态完全不生成。

测试入口：

- 开腹胆囊切除术：关键判断后触发 `nausea`。
- 开腹子宫肌瘤剔除术：关键判断后触发 `drowsiness`。
- 开放式胰十二指肠切除术：关键判断同时生成两种状态，用于验证优先级；同为 1 级时先显示恶心。

### 反馈重点

- 临时状态出现频率是否打断流程。
- 委托选项是否有明确区别。
- 团队回应和患者回应是否需要两段显示。
- 额外用时是否合理。

### 10.3 里程碑 1C：内容覆盖与稳定化

> 当前状态：代码、内容、验证规则和独立自动验收测试均已完成；等待玩家按下方矩阵进行实机节奏与文本验收。这里的“全部主题”指六种非空 `awake_interlude`；空字符串是明确跳过患者事件的节奏标记，不属于对白主题。

### 实现内容

- 为全部六种有效 theme 建立通用 fallback，并保留空字符串作为无患者事件标记。
- 为重要 theme + state + cue 组合制作至少两条 variant。
- 建立第一批 procedure-group 对白池。
- 为子宫切除、卵巢囊肿切除、子宫肌瘤剔除、乳腺肿瘤切除、全乳房切除和 CABG 制作少量 surgery-specific / signature interaction。
- 给现有 25 种四步术式分配合理的 theme 和 cues。
- 完成防重复循环和确定性顺序。
- 清理不再使用的旧术中互动桥接逻辑。
- 完善结果摘要和运行时错误保护。
- 完成第一阶段验收矩阵。

已实现内容（2026-09-28）：

- `patient_interactions.json` 从 18 条扩充为 47 条。
- 七种 `procedure_group` 均有类别对白池。
- 子宫切除、卵巢囊肿切除、子宫肌瘤剔除、乳腺肿瘤切除、全乳房切除和 CABG 均有一次性 signature interaction。
- 11 台较长手术在第二个现有步骤加入 `ongoing_interaction`，使用 `fatigue`、`pressure` 或 `position_discomfort` cue；较短手术继续保留一个无患者事件的团队步骤。
- 运行时会跳过空 prompt、空 action 或结构异常的互动，安全回退到下一候选。
- 结果摘要记录本台手术实际出现的清醒患者事件次数。
- 新增 `tools/surgery_phase1c_test.gd`，覆盖全部 25 种术式、三层作用域、一次性回退、防重复轮换和异常内容保护。

### 我方验证

- 所有 theme 有 fallback。
- 所有 25 种术式都有合法 procedure group。
- 具体术式、类别和通用 variant 的范围互斥。
- 所有 surgery_ids 引用真实术式。
- 所有 cue 至少被术式或条件定义实际使用一次，未使用项明确保留原因。
- 所有互动 action 数量为 1–3。
- 所有 25 种术式通过验证。
- 全麻和清醒数据路径均不存在死锁。

### 用户实机测试

至少选择：

- 一台腹部手术。
- 一台乳房手术。
- 一台妇科/盆腔手术。
- 一台胸腔或大型手术。

分别用全麻和一种清醒路线完成，检查：

- 对白是否重复。
- 身体感受是否符合当前阶段。
- dignity 互动是否出现在适合的术式。
- 长手术是否明显比短手术有更多患者存在感。
- 完整流程是否出现卡死、空白按钮或错误立绘。

### 反馈重点

- 哪些台词显得机械或重复。
- 哪些 cue 与手术阶段不匹配。
- 哪些互动应该删除、前移或后移。
- 哪些选项效果过强或过弱。
- 哪些术式专属对白仍显得只是替换了器官名称。

## 11. 预计修改范围

第一阶段预计涉及：

```text
data/manifest.json
data/schemas/content.schema.json
data/surgeries/surgeries.json
data/surgeries/patient_interactions.json
data/surgeries/temporary_conditions.json
data/patients/templates/preop.json
godot/scripts/content_loader.gd（如需要错误提示增强）
godot/systems/game_state.gd
godot/systems/preop_session.gd
godot/systems/save_store.gd
godot/ui/app.gd
godot/ui/preop_view.gd
tools/validate_data.py
tools/preop_test.gd
docs/surgery_interaction_skeleton.md
docs/data_schema.md
```

由于不保留术中存档，旧存档迁移函数不属于第一阶段交付。现有旧存档测试可以删除或改写为“手术开始前可保存、开始后拒绝保存”的测试。

## 12. 第一阶段明确不包含

- 扩展 25 种术式的步骤数量。
- 新增术式。
- 任意手术步骤跳转。
- 技术数值和并发症。
- 随机患者事件。
- 人物专属术中对白。
- 性格修正。
- 团队支援值消耗。
- 医护患者 play 的专属分支。

这些内容分别留给第二至第五阶段。
