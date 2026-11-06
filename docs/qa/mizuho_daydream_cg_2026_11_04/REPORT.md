# 瑞穗白日梦 CG 接入与原生窗口验收

日期：2026-11-04。用户指定附件原样接入 `FANTASY_MIZUHO_OR_SOLO_01 / F03_006`，不修改图片或剧情文本。

## A. 原文件与静态审计

- 运行路径：`assets/events/daydream_v1/mizuho_or_laparotomy_open.png`。
- 1536×1024 RGBA PNG；源文件与运行文件逐字节一致，SHA-256 `19b19980b0948b659458fb1798687faecabdb50248ea52d092b655b78f62221a`。
- `data/daydreams/index.json` 保留 `cg_key=mizuho_or_laparotomy_open`，新增同名 `cg_path` 与 `cg_fit=contain`。
- 导入器同步登记该映射，重新导入原稿时不会丢失 CG 路径。
- 三篇原稿审计：3 个来源、138 节点；正文／说话人／顺序差异 0，Markdown 泄漏 0，错人立绘 0，未解析立绘 0，英文回退节点 0。
- `narrative_localization_test.py`：33,016 项、0 失败。
- `localization_audit.py`：50,379 条翻译，全部活动正文与 UI 键齐全。

## B. Godot headless 回归

- `tools/daydream_mode_test.gd`：687 项、0 失败。
- 新增断言覆盖：文件可由 `ResourceLoader` 加载、`F03_006` 映射正确、完整画面 fit、旁白节点实际创建 `CharacterEventCG` 且纹理路径正确。

## C. 原生窗口合成 GUI 输入

- 使用 Godot 4.5.1，不带 `--headless`，加载真实 `res://godot/scenes/main.tscn`。
- 复用 `tools/daydream_three_alignment_native_test.gd`，隔离内存前置及临时存档路径；未读取或覆盖玩家存档。
- 从办公室白日梦入口、等级选择与篇章确认进入；中英文完整播放三篇，310 页，3,210 项检查、0 失败。
- 输入覆盖：自动播放 6 次、鼠标 99 次、空格 104 次、回车 101 次；完成返回办公室及重复进入／中途退出通过。
- `F03_006` 中文 1 页、英文 2 页均实际显示 `CharacterEventCG`，纹理路径为 `res://assets/events/daydream_v1/mizuho_or_laparotomy_open.png`；说话人分别为“旁白”／“Narration”。
- 观察审计：错人立绘 0 页、缺图 0 页、未翻译 0 页。原生日志无脚本错误、资源缺失或无效字典访问。

截图：

- [中文 F03_006](local/zh_CN_FANTASY_MIZUHO_OR_SOLO_01_F03_006_0.png)
- [英文 F03_006 第 1 页](local/en_FANTASY_MIZUHO_OR_SOLO_01_F03_006_0.png)
- [英文 F03_006 第 2 页](local/en_FANTASY_MIZUHO_OR_SOLO_01_F03_006_1.png)

## D. 未覆盖范围

- 本轮未重新导出并测试发行 PCK；结论仅覆盖当前本地工程的原生窗口。
- 白日梦 BGM／SFX／转场键仍未做声音与转场专项验收，本次 CG 接入不改这些字段。
- 全项目 `tools/validate_data.py` 仍会报告工作区既有的其它 schema／事件数据问题；本轮相关 JSON、原稿、资源、本地化及 Godot 专项测试均通过。
