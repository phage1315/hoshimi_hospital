# 《星见医院物语》CG 节点检查与赛璐璐重绘

检查范围：片桐彩子返场 V1.1 两张 CG，当前运行数据、导入器及作者原稿。用户已确认两张候选，现已替换运行图片；节点不变。下方“重绘”与首次“验证”为接入前记录，最新结果见末节。

## 节点判断

| CG | 当前显示区间 | 判断 |
| --- | --- | --- |
| 胸牌揭晓 | `ayako_return_00_opening_main` 的 `ayr00_140`–`ayr00_154` | 合理。138 扣好胸牌、139 宣告完成，140 众人看向胸牌时入图；155 诗织走近整理护士帽时返回立绘，避免静态图与新动作冲突。 |
| 阅读分镜 | `ayako_return_04_week4_storyboard_main` 的 `ayr04_012`–`ayr04_024` | 合理。011 翻开第一页，012 开始揭晓实际内容；024 读完最后一页，025 安静，026 主角合上稿件。保留现有退出点可以避免开着稿件的 CG 与“合上”动作冲突。 |

最初考虑把第二张延长到 033 的创作宣言，但进一步核对 026 的合稿动作后，不建议直接延长同一张开稿 CG。现有退出点不是技术错误，也不缺少必要 CG 节点。若以后希望加强宣言段落，可另做与合稿状态相符的变体。

## 重绘

- `research/generated_candidates/ayako_return_cel_v2/cg_01_nurse_badge_cel_v2.png`
- `research/generated_candidates/ayako_return_cel_v2/cg_02_storyboard_cel_v2.png`
- 生成工具：内置 `image_gen.imagegen`，一图一次调用；完整提示词、参考路径与生成源路径见 `research/imports/ayako_return_cg_redraw_2026-11-11.json`。
- 风格：用户指定的《心跳回忆》明快赛璐璐方向，清晰线稿、硬边阴影、干净色块；使用当前彩子／佳織／詩織／明日香立绘作人物及服装参考。
- 新图校对：第一张突出彩子与大胸牌的反应；第二张改为三人围站桌边阅读。两张均无坂口入镜。成图各为 1672×941 PNG，接近 16:9。
- 候选尚未进行窗口排版验收；第一张胸牌靠近画面下部，正式接入时需检查对白框遮挡。第二张胸牌小字的可读性有限，若要求逐字准确，应进一步修图。没有用程序改绘或覆盖原图。

## 验证

`python3 tools/ayako_return_source_audit.py`：10213 checks passed，逐句原稿和本地化核对通过。

本次未改剧本、翻译、运行数据、导入器或玩家存档；未运行 Godot headless／原生窗口验收，不以图片预览代替实机结果。


## 用户确认后接入与验证（2026-11-11）

- 两张用户确认的候选原样替换 `assets/events/character_events/rei/ayako_return/cg_01_nurse_badge.png` 与 `cg_02_storyboard.png`。旧图保存在 `research/generated_candidates/ayako_return_cel_v2/previous_runtime/`；新旧校验和见 `research/imports/ayako_return_cg_install_2026-11-11.json`。
- 原节点、对白、翻译、出现／退出时机、`cover` 显示方式均未改变。
- `python3 tools/ayako_return_source_audit.py` → 10213 checks passed。
- Godot 4.5.1 `--headless --path . --editor --import --quit` → exit 0，两个纹理重新导入；有系统 CA 提示及沙箱不能写引擎外部 editor_settings 的错误，纹理导入本身成功。
- Godot `--headless --path . --script res://tools/ayako_return_test.gd` → 7099 checks，0 failures，exit 0；有相同系统 CA 提示。
- 可见原生窗口分别运行 `--path . --script /private/tmp/ayako_cel_v2_zh_CN.gd` 和英文副本；每次 9/9 截图、992 checks、0 failures、exit 0。最终两次日志无脚本或资源错误。每次使用独立 `--log-file /private/tmp/hoshimi-ayako-cel-v2-<name>-1111.log`，日志和驱动副本保存在 `docs/qa/ayako_return_cel_v2_2026-11-11/`。
- 驱动复用现有 `tools/ayako_return_preview_capture.gd`；仅设置语言、输出目录、非 headless 断言，并等待正常 1 秒 CG 显示延迟后截图，没有手动强制显示控件。首次沿用旧驱动只等待帧，捕获时对白尚未出现；这批截图已由最终等待 1.2 秒的结果覆盖，不能用首次结果证明遮挡检查通过。
- 中英文 CG 核心截图分别位于 `zh_CN/`、`en/` 的 `preview_03_opening_cg01_badge_reveal.png`、`preview_08_week4_cg02_storyboard.png`。
- 目视结果：人物脸部与表情可见，无图像拉伸；中英文对白可读、未溢出。**对白框会遮挡胸牌大部分内容和分镜页上半部**，按钮也覆盖部分画面；原演出在新 CG 出现时保留 1 秒无对白展示。没有擅自裁图、重绘或修改通用 UI，此排版限制仍存在。图片内中文胸牌属于烘焙图像，英文版未做独立英语图。
- 本轮是自动驱动真实原生窗口的渲染检查，不是人工点击全流程验收；未验证真实 GUI 输入、全分支或导出 PCK。测试使用独立临时存档路径，未访问玩家槽位。
