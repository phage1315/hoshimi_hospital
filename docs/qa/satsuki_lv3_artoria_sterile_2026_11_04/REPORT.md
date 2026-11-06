# 《我送错了人》阿斯托莉雅手术服修复验收（2026-11-04）

## 修复

阿斯托莉雅在手术室发言的 6 个节点 `s08_008 / 011 / 013 / 015 / 017 / 019`，服装从 `white_coat` 改为 `sterile`。中英文加载使用同一结构，不再回退白大褂。

## 自动回归

- `satsuki_lv3_event_test.gd`：完整事件与双语结构 3560 项，0 失败；包含 6 个节点的角色、服装与资源存在性断言。
- `narrative_localization_test.py`：33016 项，0 失败。
- `localization_audit.py`：全部活动正文与 UI 键有英文版本。

## 可见窗口验证

使用 Godot 4.5.1 非 headless 窗口，对 6 个节点执行中英文可见渲染检查：101 项、0 失败。12 张截图均实际加载 `res://assets/characters/portrait_pack_v16/doc_artoria/sterile/neutral.png`，未加载 `white_coat`；事件内存档仍被禁止。

这部分是针对已定位节点的显示检查，不冒充从事件入口完整播放；完整节点遍历由上面的自动回归覆盖。

- [中文 s08_008](local/zh_CN_s08_008_artoria_sterile.png)
- [英文 s08_008](local/en_s08_008_artoria_sterile.png)
- [可见渲染记录](local/native.json)

原生重跑日志未发现脚本错误或缺失资源。
