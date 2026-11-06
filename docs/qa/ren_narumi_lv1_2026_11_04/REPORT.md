# 七瀬恋／神宮寺成美 Lv1 V1.1 接入与验收

日期：2026-11-04。所有测试使用隔离内存前置和独立临时存档路径；没有写入玩家槽位。

## A. 原稿／双语／资源审计

- 用户原稿逐字节复制到 `research/source_scripts/`，源文件 SHA-256 比对通过。
- 七瀬恋《夜勤病栋（1）》243 段、神宮寺成美《履历之外》202 段。`python3 tools/ren_narumi_lv1_source_audit.py` 核对每段中文、说话人、节点顺序、单一路径、场景资源和逐段英文键，均通过。原文只去除事件结束标识外层的 Markdown 加粗语法，不改显示文字。
- `python3 tools/narrative_localization_test.py`：33016 checks，0 failure。
- `python3 tools/localization_audit.py`：UI 英文键 796/796；全项目 authored 英文覆盖 40819/41152，剩余为其他既有内容。本轮两篇各段与姓名均有英文，无中文回退。
- `tools/validate_data.py` 仍报告既有项目级数据错误（如 backgrounds[77] 缺 label、旧事件时间窗口）；新事件 ID 无报错。该脚本已避免对缺少 `gallery` 的旧事件直接崩溃。

## B. Godot headless 回归

`res://tools/ren_narumi_lv1_test.gd`：6361 checks、0 failure。中英文各跑两篇，检查真实下班／办公室入口、Lv1 门槛、节点顺序、资源加载、无提前结算、无 Surgery Runner 影响、存档边界、完成后读档与不可重复触发。日志：`/private/tmp/ren_narumi_lv1_tint_headless.log`。

## C. 可见 Godot 原生窗口

`res://tools/ren_narumi_lv1_native_test.gd` 使用真实主场景及 `root.push_input()` 合成 GUI 鼠标、空格和回车；不是 OS 级人工点击。最终轮次 8293 checks、0 failure，中英文各完整播放两篇，共 890 个节点、891 个显示页；鼠标 297 次、空格 297 次、回车 297 次。逐页检查说话人、正文、服装文件、背景、溢出或滚动及单次输入推进；结尾返回安全界面。未测自动播放。

日志与结果：[engine.log](native_final/engine.log)、[native.json](native_final/native.json)。实际截图抽查：[恋·护士站](native_final/zh_CN_actor_ren1_006.png)、[恋·夜间病房](native_final/zh_CN_actor_ren1_082.png)、[成美·办公室](native_final/zh_CN_actor_nar1_005.png)、[成美·手术室](native_final/zh_CN_actor_nar1_088.png)、[英文手术室](native_final/en_actor_nar1_088.png)。

## D. 仍缺的画面／未测范围

- 护士站没有独立夜景底图，现由同一背景加夜间色调；原始图片未修改。
- 恋篇成年匿名患者 18 个发言节点、成美篇匿名巡回护士 1 个发言节点没有专属立绘，现显示姓名和对白，不借用其他角色图片。
- 本轮未做导出 PCK 包内测试，也未测自动播放；这些结果不计入已通过的窗口路径。
