# 《本人就在这里》实装记录

来源设计稿：`docs/design/HOSHIMI_ADVANCED_REFERRAL_TUTORIAL_CHISATO_V1.md`。

## 运行结构

事件由 `data/events/special_events/index.json` 的主记录和 `data/events/special_event_steps/index.json` 的三日步骤组成。Day 1 有 28 个节点，Day 2 有 29 个节点，Day 3 有 24 个节点，总计 81 个节点。

Day 1 明确外科、麻醉、器械、巡回和护理监督的边界，并以无侵入操作的真人 Dry Run 结束。Day 2 先完成肌注、身份核对、诱导与 Time Out，再进入八阶段高级手术 Runner；每次安全选择之后都有团队回应。Day 3 先收集患者体验，再分别复盘外科、麻醉、双器械位、双巡回位与组织配置，最后开放高级转诊系统。

## 关键实现文件

- `godot/systems/special_event_session.gd`：保存选择、局部教学语气与教学风格。
- `godot/systems/game_state.gd`：测试入口、即时相识/旗标效果、完成奖励与存档恢复。
- `godot/ui/app.gd`：高级转诊摘要、八阶段手术页面和 DEBUG 入口。
- `data/cases/advanced_referral_cases.json`：首次高级病例。
- `data/surgeries/surgeries.json`：开胸人工心脏系统置换。
- `data/patients/cameo_patients.json`：成年 AU 千束与事件素材引用。
- `data/staff/doc_sakura_anesthesiology/profile.json`：独立麻醉科角色樱花。

## 美术使用

- 千束会议：`assets/events/advanced_referral_tutorial_chisato/chisato_conference_v1.png`
- 千束患者服：`assets/events/advanced_referral_tutorial_chisato/chisato_patient_gown_v1.png`
- 千束诱导：`assets/events/advanced_referral_tutorial_chisato/chisato_induction_v1.png`
- 千束术后：`assets/events/advanced_referral_tutorial_chisato/chisato_postop_v1.png`
- 樱花白大褂：`assets/characters/portrait_pack_v23/doc_sakura_anesthesiology/white_coat/neutral_v1.png`
- 樱花 Grand OR：`assets/characters/portrait_pack_v23/doc_sakura_anesthesiology/scrubs/neutral_v2.png`
- 用户提供的肌注 CG：`assets/events/advanced_referral_tutorial_chisato/injection.png`

生成素材的参考来源、工具、用途和 SHA-256 记录在 `research/imports/advanced_referral_tutorial_chisato_sources_2026-10-01.json`。
