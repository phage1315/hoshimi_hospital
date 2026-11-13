# Hoshimi Hospital — 雀丘利·潘兰杞（雀雀）Patient Bundle V1 / QA

## 1. 交付和人物定位

- 文件：`patient_chuatury_panlunch_complete_bundle_v1.json`
- `patient.id`: `patient_chuatury_panlunch`
- `patient.name`: `雀丘利·潘兰杞（雀雀）`
- 星见世界观成年年龄：`20`，仅记录这一项年龄信息。
- `dialogue_profile`: `strong_front_expressive_irritable`（既有基础人格，不新增）。
- `personality`: `primary=strong_front`, `secondary=impulsive_defiant`, `stress_response=becomes_irritable`（Codex 已确认合法值）。
- 角色定位：地球寮的驾驶员，性格尖锐但重情义、护短，在医护提出模糊指令时会大声质问；真正恐惧时会短暂失去平时吵架的气势，转为明确提出需要帮助。
- 医学边界：驾驶经验≠临床经验或高耐痛性；`medical_background=false`；`has_prior_surgery=false` 为这份星见 AU 起始状态，不冒充原作事实。

## 2. 原作资料／星见 AU 的区分

官方可证实的素材：
- Chuatury Panlunch（チュアチュリー・パンランチ）昵称 Chuchu，属于地球寮，是驾驶员，驾驶改修后的旧式 Demi Trainer。
- 她厌恶歧视地球人的行为，经常与人争执。
- 声优富田美忧在官方访谈中特别指出，她虽然举止粗鲁、外表难接近，但内心关怀同伴。

官方参考：
- <https://en.gundam-official.com/witch-from-mercury/character/7/>
- <https://en.gundam-official.com/witch-from-mercury/staff/>

**星见 AU 推演**：本次采用成年患者身份；将“强势护短—不肯被当作麻烦—手术刀前真实恐惧”用于医疗流程。具体患病与就诊过程由游戏随机病例提供，不视为影视正史。

## 3. 内容完整性

| 检查项 | 结果 |
|---|---|
| 根对象7个字段 | 7/7，且无多余键 |
| `patient.reaction_lines` | 28/28，包含独立 `incision_ready` |
| `patient.reaction_variants` | 13/13组，共35条，每组2–3条 |
| `patient.outpatient_lines` | 4/4 |
| `encounter.full_undress` | 1条 prompt + 4条 responses（完整后缀） |
| 标准术前节点 | 25/25 |
| `graphic_preop` 可选节点 | 2/2（共27个 stage prompts） |
| `preop.incision_responses` | 3/3，与对应 `reaction_lines.incise_*` 一致 |
| 专属CG | 空数组，等待实际资源，不编造路径 |
| 诊断反应 | 空数组，保持随机病例独立 |

特别复核：
- `ward_enema_unnecessary` 和 `ward_skin_prep_unnecessary` 各包含2条原创新对白，未遗漏。
- 门诊 complaint / primary / secondary 各恰含一次字面 `{line}`；四条门诊文案均无整个字符串的外层 `「」`。
- `graphic_preop_question` 是患者对白；`graphic_preop_dialogue` 和 `preop.stage_prompts.incision_ready` 是符合已知模板的叙述节点；`patient.reaction_lines.incision_ready` 才是**下刀前的患者直接对白**，不与 `incise_*` 合并。
- `surgery_start_general`、`general_operation` 不出现清醒患者发言；`_awake` 与 `_none` 差分区分麻醉与疼痛语境。
- `incision_ready` 一句描写刀已迫近但**尚未切开**，不含切开后的感受。
- `case_id=case_abdomen` / `surgery_id=surgery_appendix` 是技术 fallback，不是固定诊断或术式；引擎需维持 Patient × Case 的独立抽取。
- 数值为角色候选值；复用已知模板初始 `preop.initial_anxiety=3`、初始交互 `fear=40/pain=0/dignity=100/cooperation=75`，无新机制。

## 4. 验证边界及 Codex 导入要求

- **本地已通过**：JSON 编码与解析；28 reaction keys / 13 variant groups / 27 preop stage prompts；全部七个根键；`patient_bundle.schema.json` 能够独立校验的自足字段；已知6种 `stress_response` 枚举核对、空素材结构等文本 QA。
- **本地无法完整验证**：引用 `content.schema.json#/$defs/patient` 等外部定义的全量 Schema，及游戏里 `personality.primary/secondary` 精确枚举、所有 stage id 的实时路由、基础 Profile 注册与 art fallback。Codex 必须用工程当前文件再次验证。
- 若已有注册的患者ID冲突，以工程为准；不要擅自修改全局手术、麻醉、Fear/Pain/Dignity/Cooperation、音效或 CG 触发器。
- 如无 `incision_ready` 专属 CG，仍应接入患者专属文字；不得虚构 CG 路径或新建独立 trigger。

**状态：Content Complete / Codex Validation Pending。**
