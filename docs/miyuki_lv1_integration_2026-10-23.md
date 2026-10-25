# 朝倉美幸 Lv1 接入记录

2026-10-23：按用户提供的 `HOSHIMI_ASAKURA_MIYUKI_LV1_V2_COMPACT_CN_CODEX_READY.md` 接入正式 Lv1。原工程未实现此事件；复用角色 `nurse_yui`，事件 ID 为 `miyuki_lv1_not_that_kind_of_inexperienced`。

## 触发与结算

- 已相识、当前 Lv0、熟悉度至少 10，在护士站 09:00–17:00 触发。
- 用户确认耗时 20 分钟，沿用全局关系升级三日冷却；Lv0 相识不计入升级冷却，因此首次 Lv1 不额外等待三日。
- 手术或其他占用流程中不插入事件。
- 完成仅升级至 Lv1，不增加好感、熟悉度、属性或手术次数；返回护士站。
- 已完成或旧存档已达到 Lv1 时不重播。Lv2 及后续规划不变。

## 文本与演出

44 个中文节点逐句保留原文、标点、说话人与顺序，并配齐英文标题、预告、画廊说明、正文、标签与继续按钮。原稿及中英对照归档于 `research/character_references/asakura_miyuki_2026-10-23/lv1/`。

技术编号 `A1-001` 至 `A1-044` 映射为工程要求的 `a1_001` 至 `a1_044`；没有剧情文本增删改写。年轻护士使用独立说话人标签，不借用其他正式角色身份或立绘。

全程白色护士制服。语义表情映射为已有资源：friendly_smile / dry_amused → smile，attentive → neutral，commanding → serious。舞台说明通过静态立绘与正常阅读停顿呈现，不添加电话另一端对白或额外旁白。

## 验证

- 原文 audit：44 节点通过。
- Godot 双语运行测试：614 项，0 失败；涵盖触发、冷却、说话人、表情、英文长句按钮翻页、逐字拼接完整性、结算与读档防重播。
- 图形运行与截图核对：中英节点 004、010、019、033、038、044；位于 `docs/qa/miyuki_lv1/`。
- `validate_data.py`：851 条记录通过。
- `narrative_localization_test.py`：11805 项，0 失败。
- `localization_audit.py`：英文剧情字段 19770/19770，UI 732/732，无硬编码中文候选。
