# 星见医院 — 薗田愛実医护数据包 V2（年龄修订）（2026-10-21）

> **交付状态：人物数据与全部启用功能的中文／英文工作对白已编写；尚未取得工程实际 `content.schema.json`，未通过 Godot runtime；新角色 Lv0 的触发时间、六项技能及熟悉度倍率尚待用户确认；年龄 20 岁已获用户确认。**

## 一、角色定位

- 姓名：**薗田愛実**／Itsumi Sonoda；作品来源：《淫内感染2》。本项目采用成年医疗 AU。
- 确认星见年龄：**20 岁**（用户于 2026-10-21 明确指定；V1 的 22 岁提议已废弃，不作为原作官方年龄）。
- 专业：外科与病房护理；原作已有常规护理经验，在星见不是毫无经验的新实习生。日常开朗、主动、对患者有具体关怀。
- 已知原作关系：弘子是护理学校前辈；皐月为熟悉的同事；妹妹薗田夏実；原作曾有男友正弘；曾照顾佐伯ほづみ。**原作被胁迫经历不自动沿用到星见，正弘在星见的感情现状也不定。**
- **硬边界：** 一次器械托盘事故不能演成经常掉东西；不能把患者热心关怀写成所有人都可以随意接近她；不让她只做传话人。

## 二、建议能力（审核前提议）

| skills | 建议值 | 解释 |
|---|---:|---|
| surgery | 12 | 医生型手术技术非本职，不代表护士技术差 |
| diagnostics | 48 | 能观察并报告，不直接确诊 |
| teamwork | 67 | 熟悉常规工作协作 |
| patient_care | **78** | 核心强项：耐心面对患者问题、长期护理 |
| instrument_handling | 61 | 普通器械护士胜任，不是顶级老手 |
| calmness | 65 | 工作能稳定报告；性格仍明快 |

建议熟悉度增益倍率：**1.0**（待确认）。初始 `met=false, level=0, familiarity=0`；暂不开放 Lv1–Lv5、周日恋爱约会、自由 H、Staff-as-Patient，均由后续正式路线决定。

## 三、已确认的项目通用规则（不是建议）

- **普通护士均可被玩家编入手术团队**，含 `scrub_nurse`／`circulating_nurse`／病房准备护士；例外石神等由专门设定限制。日常工作分工与自然刷新的地点**不是硬性入队资格**。
- **普通护士均有专属护士资格，只有石神例外。** 专属护士选择仍由全局试用期／正式相识条件控制；不同于浪漫攻略。
- **所有医护开放休息室、天台和普通下班同行。** 与周日约会、恋爱 H 相互独立。
- 危机播报由实际编入的**巡回护士**发言，现有 8 种 `crisis_flavor_id` × 普通／严重 × 第1、2、3次处置，合计**48条实际双语报告**；播报只解释监护表现，绝不提供正确选项。
- 术前说明 `open / insert_a / insert_b / close` 每项实际中文与英文一条，不能替代项目现有医疗说明。

## 四、本包交付文件

```text
data/staff/nurse_sonoda_itsumi/
  profile.json
  relationship.json
  bundle.json
  dialogue_authoring.json
  time_events_authoring.json
event_design/itsumi_lv0_candidate_cn_en.json
README_薗田愛実医护数据包.md
RUNTIME_MAPPING_AND_QA.md
SONODA_ITSUMI_DIALOGUES_CN_EN_REVIEW.md
```

`dialogue_authoring.json` 负责具体语音、岗位、术前、危机、诊断、同行等**实际**文本。`time_events_authoring.json` 为护士站／病房／休息室／天台各 3 段独立备选；如真实代码没有护士站／病房重复闲谈入口，仅注册已有入口，不新增机制。

**首见事件**：附赠一份完整但尚未由用户确认的 Lv0 中文／英文候选稿。没有规定首次见面的确切游戏日、星期或时间；不得偷用岩崎留美＋米田栞已经确认的周一 9:00 规则。玩家未读完事件不能将愛実提前标记 `met=true`。

**美术资源**：本轮未生成立绘或 CG，也未核实原始视觉锚点。所有艺术路径保持 `NOT_SUPPLIED`，禁止假称已有可用素材。

## 五、参考来源

- `HOSHIMI_INNAI_NURSE_ENSEMBLE_CHARACTER_BIBLE.md` §6；
- `IN2_Sonoda_Itsumi_profile.md` 与 `IN2_Sonoda_Itsumi_source_notes.md`；
- `HOSHIMI_NURSE_ENSEMBLE_SOURCE_NOTES.md` O-A；
- `staff_minimal_requirements(2).md` §§1–7；
- `HOSHIMI_PERSONAL_NURSE_SYSTEM_V1.md`；
- `HOSHIMI_SURGERY_CRISIS_NURSE_CALLOUT_LAYER_V0_1.md`；
- 参照先前 `HOSHIMI_RUMI_SHIORI_FULL_DIALOGUES_V3_PREOP_WRAPPERS_2026-10-21.zip` 文件布局。

**这不是 schema 验证通过或 Godot 实装完成声明。**

## 六、年龄修订记录（2026-10-21）

- 用户指定：**薗田愛実 20 岁、杉村弘子 22 岁**。保留爱实是弘子后辈的既有关系。
- V1 提议的“爱实 22 岁、弘子 26 岁”均已废弃；此包没有修改弘子的生产数据，需由 Codex 对照年龄总表核对。
- 六项技能及 Familiarity ×1.00 仍为提议，年龄确认不等于能力数值确认。
- 本包附带 `HOSHIMI_CHARACTER_AGES_USER_CONFIRMED_2026-10-21.md`，用于统一其他人物。
