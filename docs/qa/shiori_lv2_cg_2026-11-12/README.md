# 诗织 Lv2 CG 制作与验收（2026-11-12）

用户授权两张 SFW CG；后续明确要求与现有立绘对齐，取代先前的 90 年代赛璐璐方向。最终使用内置 image_gen，以现有休闲装立绘为人物、服装与画风基准，保留经原生窗口检查的安全构图。没有更改原稿、对白、选项、翻译、结算或存档契约。

## 最终资产与映射

- [分享唱片](../../../assets/events/shiori_lv2_v1/record_sharing.png)：slv2_162–171，同时作为事件鉴赏封面；172 放回唱片后恢复立绘。
- [扶发箍的迟疑](../../../assets/events/shiori_lv2_v1/headband_pensive.png)：slv2_188–206。
- [安心微笑差分](../../../assets/events/shiori_lv2_v1/headband_relieved.png)：slv2_207–208，右手按原稿放回纸袋，209 恢复立绘。
- [最终生成提示词](../../../research/generated_candidates/shiori_lv2_cg_v1/aligned_prompts.json)、[文件尺寸与 SHA256](../../../research/generated_candidates/shiori_lv2_cg_v1/assets.json)。使用 built-in image_gen，无 CLI/API fallback。
- 初始近景与用户淘汰的赛璐璐版本保存在 research/generated_candidates/shiori_lv2_cg_v1/initial_composition 和 cel_rejected；没有运行引用。第一轮原生截图在 initial_render，第二轮旧画风截图在 cel_render，当前目录为最终立绘对齐版本。

## 接入

修改 data/staff/doc_shiori/lv2_events.json 与 tools/import_shiori_lv2.py：仅添加 31 个节点的 cg_path / cg_fit / cg_portrait_overlay 以及 gallery.path。保留原 event_portraits 作为无 CG 时的原有呈现；有 CG 时既有渲染器直接返回，不叠加立绘。show_on_complete 保持 false。

没有全量重跑导入器；只调用其 CG 映射函数定点修改当前事件。对照修改前事件去除新增 CG 字段后 JSON 完全相等；parse_beats() 与当前 nodes 完全相等。

godot/ui/app.gd 的 show_gallery_entry 调整说明区、提示与按钮间距并采用单词换行，修复原生检查发现的英文说明重叠。该共享布局影响事件鉴赏页；本轮原生验收目标为诗织的中英页面，未逐个检查其他事件。

## 实际执行

- python3 tools/shiori_lv2_source_audit.py：231 节点逐句、说话人、顺序、标点和三处分支通过，零原文差异。
- python3 tools/narrative_localization_test.py：45086 checks，0 failures。
- python3 tools/localization_audit.py：69910 translations；全部活动叙事与 UI 英文覆盖通过。
- .venv/bin/python tools/validate_data.py：全库仍失败；存在既有结构问题，包含目标事件原有 hide_calendar_header 未被 schema 接受。通过 Path.read_text 的只读内存替换注入修改前目标事件，再跑同一校验器；最终诊断集合与基线完全一致，新增诊断为零。未修复无关全库问题。初次将 CG 放 assets/cg 时产生的 31 项路径诊断已通过采用规范 assets/events 路径解决。
- Godot --headless --path . --log-file /private/tmp/shiori-cg-regression-final.log --script res://tools/shiori_lv2_test.gd：6818 checks，0 failures，退出 0。日志含 macOS 系统 CA 读取环境错误；测试无失败。最终仅重画 PNG 后未再次重复逻辑测试。
- Godot --headless --path . --log-file /private/tmp/shiori-cg-aligned-import.log --editor --import --quit：退出 0，无 ERROR。早期沙箱导入曾无法保存沙箱外编辑器设置；后续获工具执行授权正常导入。
- Godot --path . --log-file /private/tmp/shiori-cg-aligned-native.log --script res://tools/shiori_lv2_cg_preview.gd：最终原生显示检查 543 checks，0 failures，退出 0，无 ERROR。30 张截图：中英各 11 个切入/切出检查点、3 个回想检查点、1 张鉴赏页（合计 30 张）。
- git diff --check（本轮修改文件）：通过。

原生驱动使用独立 /private/tmp/shiori_cg_unused_<pid>.json 路径，内存前置与直接会话遍历，未写玩家槽位或事件内部状态。此为实际主场景的渲染检查点，非人工点击或完整 GUI 通关；未测试自动播放、导出 PCK 或平台发行包。已人工查看最终工具截图中的分享唱片、扶发箍、安心差分、中英文与鉴赏排版，关键手部动作处于对话框之上。
