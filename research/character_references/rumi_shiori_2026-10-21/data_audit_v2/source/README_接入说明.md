# 星见医院｜岩崎留美＋米田栞｜医护数据＋实际对白完整补订 V2

**状态：可供 Codex 对照真实 schema 接入的作者数据包；不是已通过 Godot 校验的运行时资源。**

本包继承此前「已写实际工作对白」的资料，补上截图指出的危机递进和用户新确认的通用功能：

- **自然出场 vs 手术编队**：两位都可被手动编作普通护士的器械／巡回；栞不会在 OR 自然刷新，但可以由玩家选入。
- **年龄／能力**：留美 20，栞 18，Familiarity ×1.0；六项能力仍是此前审核建议值，未在本次擅改。
- **专属护士**：所有护士除石神外都可开放；留美栞 `eligible=true`，与角色 Lv 无关，但遵守系统全局试用期解锁和正式相识；包括 2 条正确诊断后回应、2 条错误诊断后回应，每人还有 2 条下一项检查提示、2 条资料不足、2 条证据充足、3 条门诊闲聊、3 条诊室工作、2 条术前说明。**助言仍 100% 正确，不直接讲病名**。
- **休息室与天台**：所有医护开放；每人各 3 段，CN/EN，见 time_events_authoring.json。天台此前已做的多角色节点脚本仍留作历史来源，本轮改成符合当前单 speaker 的独立响应文本。
- **下班同行**：所有医护开放，不视为浪漫周日约会；两人各有邀请、接受、暂时无法同行、分路告别、3 段途中闲谈的 CN/EN。
- **术中危机**：八个既有 flavor × 2 severity × 3 attempt = **每人 48 句** CN/EN，明确每个状态的原始台词；不使用过时的 normal 两条 severe 一条直接接 runtime；新版主数据 `crisis_attempt_callout`，旧数据保存为 `_legacy` 仅供审计。
- **原工作对白保留**：护士站、病房、器械、巡回、选人、收尾，仍可使用此前已写中文／英文，不再标“需补文本”。
- **Lv0 共同初见**：根据用户之前决定，仅有触发语义（弘子正式相识之后下一个周一 09:00 护士站），**正文仍待后补**，不得由 Codex 从本包推断已可播放。
- **Lv1–Lv5 及浪漫周日约会**：未定义，不擅自开放；工作日下班同行是另外的功能。

## 路径
- `data/staff/nurse_iwasaki_rumi/` 和 `data/staff/nurse_yoneda_shiori/`： `profile.json`, `relationship.json`, `bundle.json`, `dialogue_authoring.json`, `time_events_authoring.json`。
- `event_design/joint_introduction_semantics.json`：两人共享的 Lv0 事件开关语义。
- `RUMI_SHIORI_DIALOGUES_COMPLETE_V2_CN_EN_REVIEW.md`：全部新对白的中文审阅及英译，以及各 flavor 三次播报表。
- `CODEX_RUNTIME_MAPPING_AND_QA_V2.md`：工程接线与验收清单。

## 保证范围和欠缺
不宣称已经核查工程实际 `content.schema.json`、`time_events.json` 真实结构或诊断完成后专属护士的事件 key。专属数据为语义明确的 authoring fields，需由 Codex 对照实际项目映射，不能忽略没有一一对应接口的字段后却报告“无缺口”。
所有实际写出的文字已在 JSON 中，而不只是需求说明。
