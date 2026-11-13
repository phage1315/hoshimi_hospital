# Hoshimi Hospital — T006 西川なつき Patient Bundle QA V1

## 交付状态

- Bundle：`patient_nishikawa_natsuki_complete_bundle_v1.json`
- 来源编号：**T006**；角色显示名：**西川なつき**；ID：`patient_nishikawa_natsuki`
- **星见世界观成年年龄：19岁**；身份：升学竞争激烈的预备学校里的成年备考生，周末仍大量学习。
- 状态：**Content Complete / Codex Validation Pending**，未声称游戏已导入。

## 角色依据：用户提供的原作分析

已知人物底稿：认真、敏感、常把情况想到最坏，略有逞强与职业／学业自尊；会对医生的无关闲谈直接反驳，故**不能写成始终唯唯诺诺**。

原作就诊线索（仅作背景资料，不是本随机患者的固定病名或症状配置）：

- 心窝部／上腹阵发性疼痛，进食后明显；长期烧心。
- 恶心和呕吐，可伴背部疼痛；呕吐物呈深色、咖啡色。
- 因进食疼痛、备考压力而食欲下降，气色差。
- 担心严重疾病，尤其癌症；在求学压力下产生灾难化联想。

**严格区分：** 这些是用户提供的原作症状和心理记录，不证明最终诊断。咖啡渣样呕吐物可能提示上消化道出血，如未来制作专属医学事件必须认真评估，不能简单归因为考试压力。本 Bundle 的门诊前三项通过 `{line}` 载入游戏随机病例的实际症状；没有填入固定的腹痛、癌症或最终术式。原作医学诊断没有被虚构补全。

## 性格架构

- 共享基础 `dialogue_profile`：**`anxious_analytical_detail`**。
- `personality.primary`: `anxious`; `secondary`: `analytical`; `stress_response`: **`asks_for_details`**（现有合法枚举）。
- 原则：完整专属 28/13 与既有基础 Profile 并存。未来增加对白时，可根据本 Profile 默认生成：紧张、追问病情证据、需明确说明；并保留她的逞强和偶尔反驳。
- 与同一 Profile 的天崎拉美区分：拉美主要焦虑是否遗漏流程；なつき最担心检查发现严重疾病，且对敷衍、跑题和轻率归因更不客气。
- `traits`、`fear_profile` 为星见写作候选数值，不发明新的机制或手术效果。`diagnosis_fear=96` 强调诊断焦虑；**不是**已确认恶性肿瘤。

## 完整性检查

| 检查项 | 结果 |
|---|---|
| Bundle 根级 | 7个必需键，无额外键 |
| 28个 `reaction_lines` | **28 / 28**，均为角色本人对白 |
| `incision_ready` | **1条**；刀还未落下，仅表达预期恐惧 |
| 13组 `reaction_variants` | **13 / 13，共 34 条**；每组2–3条 |
| `ward_enema_unnecessary` | 2条；检查存在 |
| `ward_skin_prep_unnecessary` | 2条；检查存在 |
| `outpatient_lines` | 4项；前三项恰含一次 `{line}`，四项均无外层引号 |
| `full_undress.prompt` | 1项；患者对白 |
| `full_undress.responses` | 4项；完整键名 `*_full_undress` |
| `preop.stage_prompts` | 25个标准 + 2个可选 = **27项** |
| `graphic_preop_question` | 患者本人提问 |
| `graphic_preop_dialogue` | 第三人称叙述，适配当前已知旁白节点 |
| `preop.incision_responses` | 3项，对应三种清醒切口反应 |
| 美术和诊断反应 | 三个空资源池 + 空诊断反应，不编造路径或确诊信息 |
| 年龄 | 仅星见世界观的成年设定 |

## 关键内容抽检

- 门诊背景：参加高强度升学备考、周末很少休息；因为害怕严重疾病而追问医生，不喜欢被归因于考试压力。
- 检查与准备：会害羞、会提出具体问题，但不是不懂事地拒绝所有检查。
- 术式确认错误：坚定反驳，维护自己的知情权，不因害怕就放弃判断。
- `reaction_lines.incision_ready`：`「我都说了会配合……等、等等！刀就在那儿……不行！求您先别落下来，我真的好怕……！」`
- `preop.stage_prompts.incision_ready`：独立旁白，不可替代上述患者对白。
- `incise_*`：刀已下后，硬膜外、局麻、无麻醉反应分离，绝不把三种情况写成同一种疼痛。
- 全身麻醉后仅有团队监护及流程旁白，无清醒回应。

## 给 Codex 的导入要求

1. 使用工程内实际 `content.schema.json` 对 `patient` 的 `$ref`、人格字段枚举及 `voice_style` 进行**完整 Schema 校验**；此轮只有独立可验证的 Bundle 部分通过检查。
2. 核对 `patient_nishikawa_natsuki` 是否与既有 T006 导入 ID 或同名资源冲突，必要时建立 ID 映射，不要自动覆盖既有对象。
3. `patient.case_id=case_abdomen` 以及顶层 `fallback={case_id:case_abdomen,surgery_id:surgery_appendix}` 是模板的**技术回退示例**，绝非固定病情或术式。游戏应继续独立分配患者与随机病例。
4. 核对全部25个标准 `stage_prompts` 及2个可选 `graphic_preop` 节点与现行运行时匹配。`graphic_preop_dialogue` 遵循实际 speaker/节点路由，不能仅因为文本存在就认为已经显示。
5. 不要把 `reaction_lines.incision_ready` 误写到 `preop.stage_prompts.incision_ready` 中，亦不新增下刀触发器；如果未来补 CG，再按已存在的资源接口同步 caption。
6. 不改变本患者或其他患者的手术成功率、Fear/Pain/Dignity/Cooperation 数值公式、麻醉模式、诊断及病例池，不凭原作症状推断恶性诊断。
7. 美术素材缺席时保持空资源路径，由正式工程美术映射补充。

## 验证范围

- **PASS**：JSON 加载，根键集合，28/13 键集与内容格式，`{line}`、检查回应键名、年龄下限、`stress_response` 已知合法值、下刀前与刀后区分、各阶段角色/旁白格式，以及可独立校验的 Draft 2020-12 子 Schema。
- **PENDING**：`content.schema.json#/$defs/patient` 及 CG 类 `$ref` 的完整验证、engine 实际字段枚举、全部运行时路由和资源注册；Codex 必须最终确认。

