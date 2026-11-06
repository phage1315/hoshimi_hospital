# 惠惠万圣节限定装扮实装

已接入 `npc_megumin` 的年度限定服装和 `megumin_halloween_original_mage_reveal` 短初见，包含完整中英文、阿库娅在场／不在场两个自动分支。新增 31 个原稿可见节点，制作说明和分支标题不显示给玩家；现有 100 条互动保持原 ID、随机权重和年度组。

## 玩家行为

- 当前固定游戏年为 2025：10 月 31 日是周五、第 214 天。正常在岗 09:00–17:00 穿魔法师服；目标日不能上班时，在 10 月 25–31 日范围内向前找最近工作日，没有工作日则跳过。
- 相识未完成或相识发生在当天，保持原相识排程及白色前台服，不启用当年限定换装。
- 第一次主动点击前台的惠惠优先播放新短初见；完成后记录 `annual_groups["2025:halloween_costume_reveal"]`。不占每日 Micro、不改变原 `halloween` 年度组，不发放数值、金钱或耗时奖励。
- 当天普通前台 Micro／Bark 也应用魔法师服覆盖；第二次交谈仍可抽原正常 Micro，已用额度则走 Bark。17:00 离岗使用原校服，不在晚上或十一月补播新事件。
- S07 和 M26 原样保留在 10 月 25–31 日的同一 `halloween` 年度互斥组。

唯一获授权的旧正文修订是 M26 的“今天是一年一度的万圣节前夕”改为“万圣节期间”，其余句子、说话人、顺序与标点保留。英文对应改为 “During Halloween, …”。原始 V2 和补充文档不改写，导入器显式记录该定向修订。

## 素材与接入

使用内置 imagegen，现有星见版接待立绘校准人物身份和画风，两张用户提供的原作图校准帽子、披风与服装。未新增法杖演出或魔法效果。四张透明 1024×1536 PNG 保持同一姿势与构图：

- `assets/characters/npc_megumin/halloween_original_mage_neutral.png`
- `assets/characters/npc_megumin/halloween_original_mage_proud.png`
- `assets/characters/npc_megumin/halloween_original_mage_flustered.png`
- `assets/characters/npc_megumin/halloween_original_mage_happy.png`

保留约 307×460 的显示框，帽顶有安全留白；鉴赏列表调整为 19 行均在画布内。新增前台职务文字标识。原始参考图、补充正文、完整生成提示词及输出来源记录在 `research/character_references/npc_megumin/halloween_v1/`，其中 `generation.json` 为最终提示词集。

主要接入文件：

- `godot/systems/megumin.gd`：既有日历／工作日派生限定日、服装覆盖、首聊优先与独立年度结算。
- `godot/ui/megumin_view.gd`：职务标识和鉴赏列表布局。
- `tools/import_megumin.py`、`data/npcs/megumin/catalog.json`、`research/translations/megumin_en.json`：原文导入、翻译与表情映射。
- `data/npcs/megumin/profile.json`：四张新素材路径。
- `tools/megumin_source_audit.py`、`tools/megumin_test.gd`、`tools/megumin_halloween_test.gd`、`tools/megumin_halloween_native_test.gd`：原文审计和回归。

没有新增平行日历、医护／患者／关系路线，也未扩大存档边界。换装状态实时派生，不保存服装开关；持久记录仅为年度已见与事件完成日，未存储节点或播放进度。

## 验证结果

| 验证 | 结果 |
| --- | --- |
| 原文逐句与双语审计 | 2,645 项，0 失败 |
| 惠惠原系统回归 | 2,013 项，0 失败 |
| 万圣节专项 headless | 42 项，0 失败 |
| 叙事本地化 | 35,661 项，0 失败 |
| 本地化审计 | 所有活跃正文与 UI 键有英文覆盖 |
| 最终原生窗口 native2 | 616 项，0 失败，进程退出 0 |

原生测试使用隔离内存前置及合成鼠标输入，覆盖两种语言×两个阿库娅分支、真实前台按钮、新初见→旧 Micro→Bark、10 月 31 日安全存档读回、实际日结链 17:00 校服出场及四张服装鉴赏。另通过预览模式分别播放 S07/M26，核对限定服装覆盖，不结算预览奖励。PNG 尺寸、透明边角、帽顶留白、实际显示框均有断言，截图抽查确认透明背景与比例。

专项逻辑测试覆盖：目标日不可上班时前移、全窗口无工作日、相识日冲突、已有普通万圣节记录、当日额度已消耗、忙碌不打断、跨日不补播、年度键隔离、存档不依赖原事件节点、重复读存不重复奖励。

工程当前只运行固定一年，不为验证而扩展可游玩年份；后一年的年度键隔离及目标日不可上班使用隔离日历／工作日夹具验证，不声称已在另一真实游戏年自然通关。未进行发行包或 Windows EXE 验收。

日志与截图在 `docs/qa/megumin_halloween_2026_11_05/`。早期测试夹具曾用超过既有上限的剧情耗时跳至十月，已改为隔离的已结算时钟前置；没有因此修改生产存档校验。headless 日志的 macOS 证书读取提示未造成测试失败；编辑器导入完成，编辑器偏好文件写入受沙箱限制，不影响本地游戏资源加载。
