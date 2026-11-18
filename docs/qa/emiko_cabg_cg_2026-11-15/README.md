# 御堂江美子 Lv3 CABG 全景接入验收（2026-11-15）

- 用户批准的 V3 原图原样复制到 `assets/events/emiko_lv1_3_cg_v1/lv3_cabg_overview.png`；1536×1024，SHA256 `4ea4453908b168682494eba471f3663b1920d1b30aa9c2cf542381f692ee3f1b`。
- `data/staff/doc_emiko/lv3_events.json` 的 `em3_s3_17` 至 `em3_s3_22`，建立体外循环至阻断／停搏液段落，新增 CG 路径、contain 与 2 秒对白延迟；六个节点仅改这三个视觉字段。
- `research/imports/emiko_lv1_3_cg_mapping.json` 增加映射。复用现有画廊自动收集机制，封面仍为私人手札。对白、说话人、岗位与剧情逻辑均不改。

## 实际验证

- `.venv/bin/python tools/emiko_lv3_source_audit.py`：24231 checks，0 failures。
- `python3 tools/narrative_localization_test.py`：51427 checks，0 failures。
- `python3 tools/localization_audit.py`：退出 1；既有 `voice_director.gd` 5 处中文硬编码；叙事 59791/59791、UI 英文键 803/803 覆盖。
- Godot 4.5.1 `--headless --path . --log-file /private/tmp/cabg-cg-import.log --editor --import --quit`：资源导入完成；沙箱外 editor_settings 保存权限报错，不影响随后资源加载。
- Godot 4.5.1 `--path . --log-file /private/tmp/cabg-cg-native.log --script res://docs/qa/emiko_cabg_cg_2026-11-15/preview.gd`：23 checks，0 failures。中英 CG 加载、无叠加立绘、画廊收录与 GUI 输入翻页／回环均通过；保存四张截图，人工查看英文对白截图。
- 逐节点比较接入前数据，确认仅六个节点的三个视觉字段发生变化；运行图与 V3 源图逐字节一致。

这是原生渲染检查点验证，不是完整事件自然流程通关；使用独立临时配置，不写玩家存档。未 commit/push。
