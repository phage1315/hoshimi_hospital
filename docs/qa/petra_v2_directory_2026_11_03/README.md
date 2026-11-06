# 佩特拉 V2 对白目录统一（2026-11-03）

- 将佩特拉的 `advanced_day2_dialogue_v2` JSON 从 `data/advanced_surgery/dialogue/` 移到 `data/advanced_surgery/dialogue_v2/`，与其余六个高级术式一致。文件内容未改，迁移前后 SHA-256 均为 `e43d4e680579de6e3f4169922047deff1d6ded6506a73f195afe5eb9519a138d`。
- 更新 `advanced_operative_dialogue.gd`：存在合法 V2 文件时可直接加载，不再要求同名 V1 文件。保留六个旧术式的 V1 基础文件与 V2 覆盖逻辑。
- 同步更新佩特拉导入脚本、原文审计、Godot 测试和叙事本地化扫描范围。

验证：佩特拉原文审计通过（47 条剧情、48 条阶段、12 条失败、6 条危机对白）；叙事本地化 31048 项、0 失败；Godot headless 佩特拉 572 项、佩特拉 UI 36 项、旧六术式 V2 回归 1447 项，均为 0 失败。可见 Godot 窗口佩特拉 UI 51 项、0 失败；`t01_dialogue_toolbar.png` 和 `t02_english.png` 记录迁移后的中英文显示。原生窗口日志 `native_engine.log` 未出现脚本错误或缺失资源。

测试使用隔离数据，没有读写玩家存档；本次只迁移文件位置和读取路径，不改台词、手术数值或正式开放规则。
