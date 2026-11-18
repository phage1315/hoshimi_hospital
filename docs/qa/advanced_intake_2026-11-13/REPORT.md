# 高级手术接诊时段与佩特拉编组诊断 — 2026-11-13

## 结果与范围

- 用户截图DAY152 / 2025-08-30周六09:00，七岗位成员均合法且无重复，不能接受预约的原因是日期。
- 附件 `clinic_slot_1 (4).json` 实际DAY156 / 2025-09-03周三09:00；次日DAY157被未完成的 `chihaya_mizuho_nurse_return`（《怎么又在医院？》）占用。真实SaveStore只读导入后，七人名单全部合法，`accept()` 返回calendar且时间／持久事实不变，病例仍在池内。仅在内存推进到DAY161不会完成返场事件，仍有阻挡，不能承诺单纯等待下周即可预约。
- 用户随后明确修改规则：新接诊限周一至周四10:00及以前；10:01起显示“今天已经没有足够时间安排高级手术的准备工作，请明天再尝试。”；周五至周日显示周末不宜排期并提示周一至周四10:00前返回。两种情况均不显示术式列表。普通高级手术与医护患者共用状态层判定；已预约／手术／结算优先显示，不被新接诊入口拦截。
- 编组页中日程冲突显示“当前无法排期”及连续三日规则；缺人／重复岗位仍显示原编组提示。英文同步；提示区高度42→54，保证两行英文完整。
- 未改作者剧情、技术ID、存档格式、用户档、排期冲突优先级或已预约日期。

## 文件

- `godot/systems/advanced_referral.gd`：共享接诊时段原因与10:00截止。
- `godot/ui/advanced_referral_view.gd`：新接诊picker之前的时段说明。
- `godot/ui/advanced_team_panel.gd`、`data/advanced_surgery/ui_text.json`：区分编组／日程错误、双语提示与高度。
- `tools/advanced_team_calendar_test.gd`：专项双语回归、可选只读附件和原生截图。
- `tools/advanced_calendar_regression_test.gd`：普通／医护患者10:00允许、10:01拒绝。
- `tools/advanced_surgery_test.gd`：原13:00接诊fixture改为09:00以符合本次规则，保留冲突拒绝、60分钟接诊、迟到手术改期断言。
- `docs/advanced_surgery_content_checklist_v1.md`、`docs/bug_backlog.md`、`docs/HANDOFF.md` 与本报告。

## 实际验证

引擎为Godot4.5.1，绝对路径 `/Users/ningye/Documents/Codex/2026-09-20/wo/work/godot-runtime/Godot.app/Contents/MacOS/Godot`。以下从项目根执行，`$GODOT` 表示该绝对路径。

| 检查 | 命令 | 结果／日志 |
|---|---|---|
| 双语专项headless | `$GODOT --headless --path . --log-file /private/tmp/petra_intake_20261113.log --script res://tools/advanced_team_calendar_test.gd -- '/Users/ningye/Downloads/clinic_slot_1 (4).json'` | 200检查、0失败、退出0；同名txt |
| 高级手术主回归 | `$GODOT --headless --path . --log-file /private/tmp/petra_surgery_after_20261113.log --script res://tools/advanced_surgery_test.gd` | 6455检查、0失败、退出0；同名txt |
| 排期／旧预约／结算 | `$GODOT --headless --path . --log-file /private/tmp/petra_advanced_calendar_regression_test_20261113.log --script res://tools/advanced_calendar_regression_test.gd` | 68检查、0失败、退出0；未传上轮附件 |
| 原生显示 | `$GODOT --path . --log-file /private/tmp/petra_native_display_20261113.log --script res://tools/advanced_team_calendar_test.gd -- '/Users/ningye/Downloads/clinic_slot_1 (4).json' --native` | 209检查、0失败、退出0；8张真实渲染截图，已抽查两种语言的周末／超时提示及英文佩特拉编组提示 |
| 叙事本地化 | `python3 tools/narrative_localization_test.py` | 47206检查、0失败、退出0 |
| 全量本地化 | `python3 tools/localization_audit.py` | 退出1：55556/55556叙事字段、801/801 UI键覆盖，但现有 `voice_director.gd` 5行未包装中文；本次文件无新增报错 |
| 全量数据 | `python3 tools/validate_data.py` | 退出1：背景schema、特殊事件priority、image_fit、角色数据／隐藏立绘冲突、时间窗等当前其他数据问题；本次排期／提示文件无报错 |
| 现有团队UI | `$GODOT --headless --path . --log-file /private/tmp/petra_ui_20261113.log --script /private/tmp/advanced_team_ui_isolated_20261113.gd` | 388检查、12失败，全部为未修改的助手卡片第二行裁切；临时副本仅隔离title_preferences_path，断言未改 |
| 现有转诊门槛 | `$GODOT --headless --path . --log-file /private/tmp/petra_advanced_referral_test_20261113.log --script res://tools/advanced_referral_test.gd` | 16检查、2失败：旧fixture只设置教程flag，缺 `tutorial_settled` 要求的完成计数；不属于本轮时段判定，未修改该测试或放宽生产门槛 |

静态日志：`/private/tmp/petra_final_{narrative_localization_test,localization_audit,validate_data}_20261113.txt`。相关diff空白检查通过。headless日志有macOS系统CA环境提示，最终原生显示日志无脚本错误。

## 测试边界与调试记录

- 使用隔离内存fixture、独立 `/private/tmp` 存档及偏好路径，在add_child前设置；原生布局fixture关闭首次使用声明。没有打开真实玩家槽位或写入可恢复中途档。
- 原生测试调用正式UI渲染与状态接口并截图；不是人工点击，也不是完整三日剧情通关或合成GUI输入流程。未重新导出、未验证Windows EXE／发行包。
- 初始fixture漏设Lv1导致部分团队不可选；曾错误假设未完成返场事件会在下周自然消失，已改成保留事件阻挡的断言；首次英文提示42px不够两行，已增加高度。
- 首次原生启动沙箱退出134；获准启动后截图参数对PackedStringArray误用filter导致解析失败，改为Array后重跑。随后截图被启动声明遮挡，保存在 `startup_notice_round/`，不算视觉通过；最终夹具禁用该启动弹窗后再次截图通过。
- 主回归最初在13:00的旧接诊fixture遇到空排期并抛脚本错误；即使末尾称0失败也未计为通过。更新到新规则允许的09:00后完整6455项通过。
- 用户附件SHA256前后一致：`c1738e4ce282697a31c8fc5ce1a3c35a07ade79fb8bcbb97bfe975cb4ca9a25f`。

## 剩余问题

- 助手卡片第二行裁切、现有转诊测试fixture及全量数据／本地化失败另行处理，本轮不扩大修改。
- 未完成返场事件仍需正常处理后再排期；本轮没有强制完成剧情或删除冲突保护。
- 新规则需要运行更新后的源码或重新导出包才生效；未commit/push。
