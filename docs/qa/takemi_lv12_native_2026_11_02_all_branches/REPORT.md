# 武见妙 Lv1／Lv2 原生窗口验收

## A. 静态／原文／双语

- `tools/miyuki_takemi_source_audit.py`：2088 项、0 失败；按既有已记录勘误核对作者归档、中文原文、英文、说话人及顺序。本轮未改剧情正文。
- `tools/narrative_localization_test.py`：30631 项、0 失败。`tools/localization_audit.py`：47313 条翻译，UI 硬编码中文候选 0。
- 两篇数据含 Lv1 44 个、Lv2 112 个节点；术中两张通用患者头像与藤乃门诊／术中／术后差分均有资源路径。

## B. Godot headless 自动回归

- `tools/miyuki_takemi_current_events_test.gd`：8742 项、0 失败；包括中英文、选项组合、门槛、结算与测试入口起始时间。此项不是可见窗口验收。

## C. 可见原生窗口路径

- macOS Godot 4.5.1，真实 `res://godot/scenes/main.tscn`；标题 → 开发者工具 → 事件测试中心 → 武见 Lv1／Lv2。每篇每种语言分别选择第一组选项与第二组选项，逐页使用 `Window.push_input` 的鼠标、空格和回车推进，完成后返回安全医院导览，再从测试中心重复进入。
- 8 条路径、10383 项检查、0 失败；中英文各覆盖 Lv1 全部 44 个及 Lv2 全部 112 个节点。中文各路径 Lv1 42 页、Lv2 108 页；英文 Lv1 55 页、Lv2 157 页。共 272 次鼠标、240 次空格、244 次回车操作；66 张可见渲染截图。
- 逐页核对归档原文（含既有勘误）、显示说话人、背景、患者图片路径、文本溢出和事件中禁存档。Lv1 从 09:00 到 12:00；Lv2 从 09:00 到跨日画面 18:00，确认后进入次日医院导览。未读取或写入玩家存档。`engine.log` 无脚本错误或缺失资源。
- 代表画面：[Lv1 通用患者羞耻咬牙](zh_CN_ev_doc_takemi_lv1_vivisection_frog_primary_l1_006.png)、[Lv1 剧痛哭喊](zh_CN_ev_doc_takemi_lv1_vivisection_frog_primary_l1_013.png)、[藤乃门诊](zh_CN_ev_doc_takemi_lv2_fujino_laparotomy_primary_l2_013.png)、[藤乃术中](zh_CN_ev_doc_takemi_lv2_fujino_laparotomy_primary_l2_077.png)、[藤乃术后](zh_CN_ev_doc_takemi_lv2_fujino_laparotomy_primary_l2_095.png)、[英文术中](en_ev_doc_takemi_lv2_fujino_laparotomy_primary_l2_077.png)、[Lv2 跨日](zh_CN_ev_doc_takemi_lv2_fujino_laparotomy_primary_day_transition.png)。完整观察数据见 `results.json`。

## D. 仍需注意

- 两篇当前没有 `cg_path` 节点，因此本轮 CG 检查不适用；没有发现已映射的立绘缺失。
- 本轮使用隔离内存前置的开发者测试中心，未验证从新游戏自然达到 Lv1／Lv2 的整个养成过程，也未测试导出包。
- Lv2 剧情播放期间 HUD 一直显示起始时刻 09:00，直到结束后的跨日画面显示 18:00。剧情时间随场景推进的显示尚未配置。
- 测试中发现并修正开发者测试入口两处问题：前置事件耗时让 Lv2 错从 12:00 显示，以及连续测试后完成页因返回地点为空报错。失败的调试轮次保留在相邻 QA 目录；本报告只采用最终 8 路径、0 失败的运行结果。
