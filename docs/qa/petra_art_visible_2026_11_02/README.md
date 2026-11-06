# 佩特拉三阶段术野与术后立绘检查（2026-11-02）

## A. 原文与双语

- `python3 tools/advanced_petra_content_audit.py`：通过；Day 1／Day 3 原文说话人、顺序及 V2 术中对白一致，七个场景用途有正式资源映射。
- `python3 tools/narrative_localization_test.py`：30,756 项检查，0 失败。
- `python3 tools/localization_audit.py`：完成；相关英文文本覆盖检查通过。

## B. Godot headless

- `tools/advanced_petra_test.gd`：570 项检查，0 失败；包括七个图片用途真实纹理加载与 T02 切皮、T02 结算后至 T11 单张静态术野、T12 缝合切换。
- `tools/advanced_petra_ui_test.gd`：20 项检查，0 失败；DEV 病例板出现佩特拉。
- `tools/advanced_referral_board_v2_test.gd`：14 项检查，0 失败；`tools/advanced_referral_rules_v2_test.gd`：419 项检查，0 失败。新增发行顺序 7 后，旧测试中固定六台的预期已同步为七台，并核对第七台按下一日期边界进入等候队列。

## C. 可见原生窗口检查点

使用 Godot 4.5.1 可见窗口运行 `tools/advanced_petra_ui_test.gd -- --native`，结果 31 项检查、0 失败。该驱动实例化真实 `main.tscn` 并抓取实际渲染帧；测试通过内存设置分别显示 Day 3 和手术检查点，按钮使用 `pressed.emit`。这是可见窗口素材检查，**不是完整剧情 GUI 输入通关**。

截图：`board.png`（病例板）、`day3_postop.png`（术后立绘）、`anesthesia.png`（全麻过场）、`team_confirmation.png`（扩大至骶尾部的俯卧图）、`t02_incision.png`（切皮术野）。测试将存档路径重定向至未使用的 `/tmp` 文件，未读取或修改玩家存档。

曾尝试复用 `tools/advanced_presentation_test.gd -- --native` 作全局展示检查；它在 Whipple 的中英文路径各出现角色卡和全麻 overlay 断言失败，共 97 项／4 失败，尚未到佩特拉。该旧测试结果不计入佩特拉通过项，也未借此修改其他术式。

## D. 剩余验收

- 佩特拉中英文完整病例逐步播放、成功／失败后返回与手术平衡尚未做可见窗口验收。
- 医学顾问的神经监测复核及作者对 Day 1／Day 3 的最终文本确认尚未记录。
- 按用户确定的三阶段静态术野方案，当前没有额外必需图片缺口。
