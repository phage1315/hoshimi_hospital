# 麻纪医生数据／台词 V1 接入审阅

2026-11-13。仅审阅并原样归档，不导入生产数据、不改作者台词。来源为同目录 `HOSHIMI_AIZAWA_MAKI_DOCTOR_DATA_AND_DIALOGUE_SCHEMA_V1.md`，校验摘要见dialogue_v1_review.json。

## 结论

作者交付结构合格，基础台词与中英元信息可转换接入；不是可直接加载的staff包。实际提取2段JSON，台词包对现有作者schema校验0错误。2条工作回应、2组共6条闲谈、首次助手CG文案和Lv0外围元信息均有中英文本。Lv0正文留空符合draft约定，不是缺失误报。

## 必须明确的内容／接口问题

1. **术中回应不是任意步骤通用句。** 现稿包含牵开、筋膜、渗血、继续分离等具体情境；若塞入通用intraoperative槽，可能在不匹配的动作后播放。保留原文时应给适用术式／阶段限定；如要覆盖任意步骤，需要作者另给真正通用的回应，不能由工程静默改写。当前`preop_session.gd`优先读`surgical_assistant_dialogue.routine_assist`等池和procedure-group覆盖；profile.team_dialogue仅在novice/limited等分支读取。
2. **闲谈时点。** 休息室1“刚才／明天查房”、休息室2“下午这个时候”、天台1“刚从手术室出来／下午”、天台3“晚风”均隐含情境。现有`spend_time()`在responses里随机抽取，无逐条时间／近期手术条件。应保留原文增加对应情境调度，或由作者提供不限时版本；不能当作全部已兼容。天台实际为独立半小时随机在场机制，不是把rooftop写进random_locations即可实现午休排班。
3. **普通助手与高级助手必须分开。** 本稿rank_slots_semantics只是作者说明，不是运行字段。现有advanced_referral.candidates复用staff_can_join_surgery_team及assistant_surgeon，初期只授权普通助手时需要明确阻止高级一助／二助。仅禁止“高级主刀”无法做到这一点。此属工程资格接线，不需要写作LLM补flag。
4. **熟练度仍null。** 可选novice/limited/trained/advanced/expert，建议limited，但需按定位定案；会影响通用反馈而不只是标签。不以48分直接推算自动权限。
5. **关系初值不齐。** 提案给了met/level/familiarity，尚缺affection；建议0及route=colleague作为技术初始状态，不代表开放恋爱。met在当前系统同时参与互动门槛，面试已相识不等于已入职；需保留故事事实与可用资格的区别。
6. **档案显示文字英文仍缺。** 已交付的是对话包双语；specialty、rank、personality、appearance、dialogue_style等中文profile显示文本仍需按staff本地化要求翻译。作者包“本地化填齐”不等于整个运行角色已完成英文。
7. **姓名／数值来源。** 中文显示名还列为待定，可统一沿用现有草案相澤 麻紀；不擅改正文中简体写法。附件把六维写为用户已确认，本次仅记录为作者交付值，不凭文档内部声明补造外部确认。本稿说明中的“明日香55–60线”与当前doc_asuka.surgery=66不一致；不影响麻纪48本身，不改原稿。

## Lv0–Lv5以外的缺口

- 工程：profile、relationship、bundle、index登记，14张立绘键和首次助手CG奖励注册，time_events、双语键、入职前隐藏／普通助手资格／高级助手排除、正式schema与资源/运行验证。当前data/staff/doc_maki不存在。
- 基础数据：surgery_proficiency、affection、最终presence与中文显示名；其余可按现有医护接口映射，不必另造字段。
- 文本：上列通用术中回应及闲谈时点处理；profile英文。当前闲谈中文112–144字，英文361–464字符；现有UI有分页，无需因此删减，仍需中英原生排版验收。
- 美术：已具备14张常服／面试服／白大褂／无菌服透明立绘及首次助手CG。独立医护术中HUD头像尚缺，现有UI可回退普通立绘，建议补齐以统一展示；独立scrubs刷手服仅在需要该场景时补，不是当前lounge/rooftop/sterile路径的硬依赖。
- 可选：Q版编组头像、语音、季节常服、下班同行／周日约会配套对白。生日、身高、恋爱／患者路线不是普通医生首批可用所必需。

## 验证范围

实际执行JSON解析、Draft202012Validator作者schema校验、源文件字节一致性及SHA-256记录；只读核对GameState、PresenceResolver、PreopSession、AdvancedReferral和UI回退／分页。未修改运行数据，未跑Godot或全仓本地化审计；不宣称生产接入完成。
