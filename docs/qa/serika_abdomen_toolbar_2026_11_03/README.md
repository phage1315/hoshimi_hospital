# 芹香 Whipple 腹部图与高级手术继续按钮验收（2026-11-03）

- `whipple_ready.png`：可见 Godot 渲染，患者准备页使用芹香腹部开窗图。
- `whipple_team.png`：点击“开始团队 Time-out”后，团队确认页继续使用同一腹部图。
- `t01_result_compact.png`：可见 Godot 渲染，操作结果的“继续”位于底部固定工具栏右侧。
- 芹香原腹部图（SHA-256 `083e9074a4a4b4e4b4f5ed4b2f3560f20fedd59607c7ae35251dd44d1c5696ab`）保存在 `assets/references/advanced_staff_patient_sfw_v1/doc_serika/abdominal.png`；运行图 SHA-256 为 `f6d5bb57f010cfbc0ed9cf4220ed6db172f1ffe71add4e1f61e0c46032af15cd`。
- 资源导入后，`advanced_staff_patient_ui_test.gd` 的可见原生窗口测试通过（1710 项，0 失败），并核对了已导入纹理中的腹部开窗像素，防止 Godot 继续加载旧缓存。
- `advanced_petra_ui_test.gd -- --native` 可见原生窗口测试通过（51 项，0 失败），核对操作结果继续按钮与对白继续按钮的水平、垂直位置一致。
- 自动回归：`advanced_petra_ui_test.gd` 36 项、`advanced_staff_patient_test.gd` 1240 项、`staff_patient_lv5_readiness_test.gd` 1403 项，均为 0 失败。

这些截图来自 Godot 原生渲染和现有测试驱动；测试使用隔离数据，不覆盖玩家存档。未在此轮遍历 Whipple 的全部手术阶段。
