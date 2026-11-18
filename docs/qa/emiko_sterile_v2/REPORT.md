# 江美子无菌手术服 V2 — 2026-11-14

用户确认基础图后，内置 image_gen 以完整基础图为参考生成 focused、worried、warm 三张独立整图。提示词与原始输出位于 `research/generated_candidates/emiko_sterile_v2/`。按 hoshimi-portrait-pipeline 使用本地 BiRefNet ONNX 去背景，未采用脸部拼贴或颜色阈值抠图。

正式替换 `assets/characters/portrait_pack_v14/doc_emiko/sterile/{neutral,focused,worried,warm}.png`，对应四个 `.png.import` 开启 mipmaps。四张成品另存 `assets/characters/emiko_sterile_v2/`。旧运行图片完整归档于 `research/generated_candidates/emiko_sterile_v2/previous_runtime/`。原图、运行图 SHA 与本地抠图报告见同目录 `integration.json`。

保留稳定路径，使 profile 与 Lv1/Lv2 显式引用同步使用新版；没有改 JSON、剧本、HUD 独立头像或事件逻辑。

## 验证

- 四张 PNG 均 1024×1536 RGBA、四角 alpha=0；三色底 QA 与帽沿／颈部放大检查通过，截图在本目录。
- Godot `--headless --editor --import --quit` 完成图片导入。自包含安装的 editor_settings 写入遇沙箱权限错误，非图片加载失败。
- 原生窗口用本目录 `preview_driver.gd`（运行时原址 `/private/tmp/emiko_sterile_preview.gd`）加载真实 main 场景，以隔离临时配置调用 add_portrait，核对四张实际路径、1024×1536 尺寸、截图。4/4 检查点通过，退出 0；日志 `native.log`。这是立绘渲染检查，不是完整剧情游玩或人工点击。未测试导出包。
- `.venv/bin/python tools/emiko_lv1_source_audit.py`：31274 checks / 0 failures。
- `.venv/bin/python tools/emiko_lv2_source_audit.py`：37641 checks / 0 failures。
- Git 二进制 diff 尝试触发 LFS clean 写 `.git/lfs/tmp` 被沙箱拒绝，未以此声称 diff 检查通过；源文件 SHA 与实际原生加载已独立验证。

未 commit/push；保留既有其他修改。
