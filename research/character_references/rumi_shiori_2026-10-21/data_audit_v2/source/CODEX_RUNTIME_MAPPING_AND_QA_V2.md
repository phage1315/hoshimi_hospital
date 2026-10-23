# Codex｜岩崎留美＋米田栞 V2 接线与验收

## 必须实现／映射

1. **人物身份**：检索最新 roster、staff bundle loader、schema，解决候选 actor ID；两人 age 20/18, familiarity_gain_multiplier 1.0。技能数值按审核建议稿读取，除非另经用户改动。
2. **地点**：两人已正式相识后均能访问护士站／病房工作，以及休息室 `lounge`、天台 `rooftop`；真实 ID 从引擎读取。休息室和天台各 3 条 `responses`，不采用由多个角色轮换 speaker 的 VN 对话 schema。所有医护普遍具有休息室和天台资格，不仅这两人。
3. **下班同行**：所有医护可参与普通下班同行，依照已有系统条件与冷却处理；不添加 Sunday Date、Charm 或 Romance gate。两人的台词在 `after_work_companion_dialogue` 与 `after_work_short_chat`。
4. **专属护士**：所有护士（除石神） `personal_nurse.eligible=true`，留美栞均可选；遵守已实现的 probation / personal nurse 系统和 `met` 检查；不要求 Relationship Lv1，亦不绑 OR 工作岗位。`personal_nurse_dialogue` 的 next_test_hint/insufficient_evidence/sufficient_evidence/chatter 使用当前助言机制，护士不说最终病名，助言必须 100% 正确。`diagnosis_correct_reply` 与 `diagnosis_incorrect_reply` **是玩家提交诊断后**的反馈；找到真实调用位置后再绑。若无该位置，不伪装成接口已实现，要在报告里说明。
5. **手术队员**：两人被手动编成任何普通护士岗位时可以正常执行、显示角色与所需服装，栞的手术室自然出场状态 `false` 只是场景出场，不得视为禁用。普通手术危机始终由当前巡回护士播报。
6. **危机播报**：绑定 `(actor_id,crisis_flavor_id,severity,attempt_index)` 到 `dialogue_authoring.json#crisis_attempt_callout`。8 flavors ×2 severity ×3 attempts；attempt 1初发，2第一次处理失败后再试，3第二次处理失败后再试；成功即结束，三次失败按原流程中止，无第四次；severity来自现有系统，不能用 attempt 推断。播报本身不改变数据、成功率、治疗选项，不能为她们新增生理数据。旧 `crisis_circulating_nurse_callout_legacy_2normal_1severe` 不再直接接入。
7. **相识与关系**：弘子正式相识后的下一个严格周一 9:00 起进入护士站触发双人 Lv0，正文此前已约定后补，**不能虚构已写完／跳过事件自动 met**。两人各自正常成长与未来共同关系线未写。固定事件播放中禁止存档。
8. **美术**：与真实立绘和岗位 CG 验证器对接，现有文件可能仍缺；不要把美术欠缺报告成对白缺失。

## 最低 QA

- [ ] 中文英文 ID、条数、格式全部可查；脚本数组中每条有完整正文，无占位符。
- [ ] 手工测试留美和栞：专属护士切换、诊断正确／错误反馈、下一步检查助言、门诊工作回应。
- [ ] 手工测试两人：休息室 3 段、天台 3 段，可重复抽取独立完整句；普通下班同行中不强制浪漫约会。
- [ ] 手工测试各自担任器械护士、巡回护士、病房准备护士；即使栞不在 OR 自然刷新，手动编组也合法。
- [ ] 巡回岗位逐一测试 8 flavors×普通／严重×第1／2／3次尝试，只有被选中的巡回护士发言；不用同一套泛用报告覆盖所有阶段。
- [ ] 不改变危机触发概率、处置次数、成功率、第三次失败结局、Blood Loss、Surgery XP、队员熟悉度等既有机制。
- [ ] 如后置诊断结果没有个人护士发言接口，须单独标为需要映射／小规模接线；不得声称已实装。
- [ ] 核对真实 `data/schemas/content.schema.json` 和 staff/time event 对象结构、中文／英文加载器、Godot 显示与素材路径，跑现有数据与本地化 QA。

## 文件来源
`HOSHIMI_INNAI_NURSE_ENSEMBLE_CHARACTER_BIBLE.md`，`HOSHIMI_PERSONAL_NURSE_SYSTEM_V1.md`，`HOSHIMI_SURGERY_CRISIS_NURSE_CALLOUT_LAYER_V0_1.md`，既有 `staff_minimal_requirements.md`。
