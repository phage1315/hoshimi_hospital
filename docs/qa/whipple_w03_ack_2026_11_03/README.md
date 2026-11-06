# 芹香 Whipple W03「继续」停滞修复验收

日期：2026-11-03。

## 原因与修改

W03 Precision 助手处置失败后，运行会话进入 `awaiting_ack`，同时仍显示作者提供的 `precision_failed` 提示。底部工具栏把按钮显示为「继续」，但回调只在当前对白为空时调用 `acknowledge()`；这条提示不会在该状态被消费，因此点击一直停留在 W03。现统一以 `acknowledgement_ready()` 判断失败结果、正常结果和危机边界，允许失败结果确认并推进到下一阶段。

## 验证

- 使用原生可见 Godot 窗口，真实主场景、隔离测试数据和合成鼠标输入。经芹香医护患者入口、麻醉及团队确认进入 Whipple，完成 W01、W02；在 W03 内存中指定一次助手失败结果，点击底部「继续」，确认进入 W04。
- 中文截图：`advanced_staff_doc_serika_zh_CN_whipple_w03_failure_ack.png`、`advanced_staff_doc_serika_zh_CN_whipple_w04_after_ack.png`。
- 英文截图：`advanced_staff_doc_serika_en_whipple_w03_failure_ack.png`、`advanced_staff_doc_serika_en_whipple_w04_after_ack.png`。
- `advanced_staff_patient_ui_test.gd`：headless 1778 项、原生窗口 1778 项，均为 0 失败。原生窗口日志为 `native_engine.log`，无脚本错误或缺失资源记录。
- `advanced_v2_backfill_test.gd`：1447 项、0 失败，覆盖 73 阶段、292 条双语台词。`advanced_petra_ui_test.gd`：36 项、0 失败，覆盖底部工具栏其他结果状态。
- `narrative_localization_test.py`：30756 项、0 失败；`localization_audit.py`：通过。剧情正文未改动，英文 W03 与 W04 显示已在原生窗口截图核对。

本轮未改剧情文本，也未修改正式解锁和玩家存档。验收到 W04 为止；W04 之后的整台手术未在本次原生窗口中逐阶段播放。
