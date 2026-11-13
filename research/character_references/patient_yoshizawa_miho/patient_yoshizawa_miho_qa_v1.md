# Hoshimi Hospital — 吉沢美帆（Yoshizawa Miho）普通患者 Bundle V1 / QA

## 1. 交付信息与身份

- 数据文件：`patient_yoshizawa_miho_complete_bundle_v1.json`，`schema_version: 1`。
- 患者 ID：`patient_yoshizawa_miho`；显示名：`吉沢美帆`。
- **星见设定年龄：26岁。** 患者文件仅记录星见世界观中的成年年龄。
- 来源：用户提供的《淫内感染 午前3時の手術室》角色分析。此前相关原作脚本并未在本轮提供，公开检索也未提供可核实人物经历的专属页面。因此**仅将用户提供的四项设定视为原作依据**，其他性格/医疗台词均为星见 AU 创作。
- 状态：**Content Complete / Codex Validation Pending**，非宣称已注册进游戏。

## 2. 人物依据与 AU 创作边界

### 用户确认的原作人物设定

1. 从小被一位年长画家收留。
2. 成年后一直作为这位画家的女仆工作。
3. 生活封闭，朋友极少，与外界接触少。
4. 安静、忠诚、服从性较强。

### 星见 AU 创作推演（非已考据的原作事实）

- 第一次独自进入大型医院，不擅长描述自己的需求，习惯压低声音、使用礼貌请求，担心给医护人员添麻烦。
- 医疗人员认真说明时，她会配合，但并**不**因为服从倾向而丧失决定能力或隐私需求；术式与检查不一致时仍主动确认，疼痛超出限度会明确求助。
- 特别强调：**安静不是不痛，忠诚不是盲从，礼貌不是没有恐惧。** 不把她写成幼态、机械服从的道具，也不假设主人有虐待、强迫、性关系或其他未知背景。
- 不为她预设特定症状、病因、固定术式或特殊剧情线。门诊具体症状继续由随机病例 `{line}` 注入。

## 3. 基础人格与数值

- `dialogue_profile`: **`socially_anxious_formal_quiet`**（现有可复用 Profile）。
- `personality.primary`: `shy`；`secondary`: `caring`（均沿用已出现过的描述标签；实际字段允许值须由 Codex 验证）。
- `personality.stress_response`: **`becomes_quiet`**（已知合法枚举）。
- `voice_style`: `soft`。尽量简短、礼貌、迟疑但不每句都机械道歉。
- `traits`: baseline_anxiety=68, pain_sensitivity=72, privacy_sensitivity=88, trust_baseline=48, control_need=43, expressiveness=30, health_literacy=23, compliance_tendency=91。
- `fear_profile`: pain_fear=77, procedure_fear=76, diagnosis_fear=62, loss_control_fear=83。
- 这些数值是**本次人物创作候选值**，不能擅自引入新的数值作用机制。她的高配合倾向不意味着无限耐痛或放弃表达不适。

## 4. 完整性检查（本地通过）

| 项目 | 结果 |
|---|---:|
| Bundle 必需顶层字段 | 7 / 7 |
| `patient.reaction_lines` | **28 / 28**（含独立 `incision_ready`） |
| `patient.reaction_variants` | **13 / 13**组，共 **35** 条，各2–3条 |
| `patient.outpatient_lines` | 4 / 4 |
| `encounter.full_undress.prompt` 与 `responses` | 1 + 4 完整后缀键 |
| 标准 `preop.stage_prompts` | 25 / 25（患者8、旁白17） |
| 可选 `graphic_preop_question` / `graphic_preop_dialogue` | 2 / 2（患者对白／旁白） |
| `preop.incision_responses` | 3 / 3，与对应 `reaction_lines.incise_*` 一致 |
| 三类专属 CG 池、诊断差分 | 保留空数组，不编造素材 |

### Codex 高频格式规则

1. 门诊 `complaint` / `primary` / `secondary` 每项恰好出现一次原样 `{line}`；全部四项 `outpatient_lines` 字符串**不带最外层日文引号**，运行时自行添加。
2. `encounter.full_undress.responses` 精确使用 `abandon_full_undress`、`authoritative_full_undress`、`gentle_full_undress`、`threaten_full_undress`。
3. `reaction_lines.incision_ready` 是**下刀前**患者看见刀的即时恐惧对白；`preop.stage_prompts.incision_ready` 是**旁白**，不是同一字段。实际切开后仍使用 `incise_epidural`、`incise_local`、`incise_none`。
4. `graphic_preop_question` 是患者自己的提问；`graphic_preop_dialogue` 按已知模板默认 `narrator` 写第三人称旁白。须由 Codex 核对真实节点是否读取该字段。
5. 全麻 `surgery_start_general` / `general_operation` 仅旁白、无清醒对话；`_awake` 与 `_none` 分别写明麻醉状态差异。
6. 两组易漏的 `ward_enema_unnecessary` 与 `ward_skin_prep_unnecessary` 均有 **2条**独立文案。

### 代表性下刀前对白

> 「我会配合……啊、等一下！那把刀……已经到我身上方了……求您，先不要落下……！」

她的恐惧不来自既成疼痛，而来自手术刀已逼近、平时克制的语言突然失控。此字段没有引入额外事件效果、改麻醉、逃跑或修改术式。

## 5. 技术边界与待验事项

- `fallback={case_id:case_abdomen,surgery_id:surgery_appendix}` 与 `patient.case_id=case_abdomen` **只是现有 Bundle 模板的技术回退值**，不是固定病种或开腹术式。运行时实际病例必须独立于患者身份随机生成。
- `preop.initial_anxiety=3`，`initial_interaction={fear:40,pain:0,dignity:100,cooperation:75}` 沿用现行基线。
- `visuals.portraits={}`，三种 `exclusive_cg_pools` 均为空，`visual_pool_id=""`。没有编造美术素材路径或 CG 触发器。
- `has_prior_surgery=false` 是本次星见 AU 起始数据默认，**不代表有证据证明原作中她从未手术**。
- 已通过：JSON 解析、精确键集合和数量、局部 `patient_bundle.schema.json` 中可独立验证的字段（schema_version/fallback/encounter/preop）、患者说话人与旁白格式、合法 `stress_response`、切口前后区分、占位符、年龄与资产空值检查。
- **尚未通过/未能验证：** 外部 `$ref` 指向的工程 `content.schema.json#/$defs/patient`，包括 `primary` / `secondary` 枚举或注册、患者引用和美术要求，以及实际 `graphic_preop` 节点读取。Codex 必须在工程内完成全量校验与运行时测试。
- 导入属于**实装而非创作**。如字段或枚举不匹配，Codex 应报告精确路径与允许值，不擅自重写美帆对白，不修改手术玩法/状态结算。
