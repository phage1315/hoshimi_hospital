# 阿尔托莉雅患者准备 CG 接入报告（2026-11-17）

## 范围

- 用户提供的八张 PNG 按指定顺序接入：消毒、铺巾、下刀、戴手术帽、担架车、导尿、剃毛、灌肠。
- 原图未裁切、重绘、遮挡、透明化或上传；附件、归档副本和运行文件逐字节一致。
- 未修改患者对白、剧情文本、资格、解锁、术式、存档或共享动作逻辑。

## 运行映射

| 用户标签 | 池 ID | 真实动作 ID |
|---|---|---|
| 消毒 | `skin_disinfection_doc_artoria` | `skin_disinfection` |
| 铺巾 | `sterile_draping_doc_artoria` | `ack_disinfection` |
| 下刀 | `scalpel_ready_doc_artoria` | `request_scalpel` |
| 戴手术帽 | `ward_surgical_cap_doc_artoria` | `ward_surgical_cap` |
| 担架车 | `stretcher_transfer_doc_artoria` | `complete_manual_ward_preparation` |
| 导尿 | `urinary_catheterization_doc_artoria` | `urinary_catheterization` |
| 剃毛 | `ward_skin_prep_doc_artoria` | `ward_skin_prep`, `ward_skin_prep_unnecessary` |
| 灌肠 | `ward_enema_doc_artoria` | `ward_enema`, `ward_enema_unnecessary` |

八个池均限制 `patient_ids: ["doc_artoria"]`，以 `fullscreen` + `contain` 显示。消毒、铺巾、下刀与导尿沿用现有规则：全麻已生效后不显示清醒准备 CG。

## 文件和来源

- 运行资源：`assets/events/ward_preparation_v1/doc_artoria/`
- 来源归档与 SHA-256：`research/imports/artoria_staff_patient_procedure_cg_2026-11-17/manifest.json`
- 运行池：`data/ward_preparation_cg_pools.json`
- 角色素材清单：`data/staff/doc_artoria/assets_manifest.json`
- 中英标签：`data/localization/zh_CN.json`, `data/localization/en.json`
- 专项运行测试：`tools/artoria_preparation_asset_test.gd`

## 实际验证

- 技术验收：8/8 为 1536×1024、RGBA8 PNG；附件 = 归档 = 运行文件，SHA-256 与清单一致。
- Godot 编辑器导入：退出码 0；8/8 运行 PNG 生成可加载 `.import`。macOS 系统 CA 与编辑器设置保存提示为环境噪声，不影响项目资源导入。
- `tools/artoria_preparation_asset_test.gd`：378 checks / 0 failures；中英映射一致，20 次清醒动作经真实 `preop_event` 分发并渲染正确纹理，其他患者隔离通过，8 次全麻后抑制通过。
- `tools/patient_sfw_asset_test.gd -- --kind staff --id doc_artoria`：23/23，0 缺失；另列作者素材 `ward_preparation/shy` 与 `h_neutral`。
- `tools/staff_patient_lv5_readiness_test.gd`：1420 checks / 0 failures；`doc_artoria` 为 `ready: true`, `missing: []`。
- `tools/advanced_staff_patient_test.gd`：2459 checks / 0 failures。
- `tools/patient_bundle_localization_test.py`：6052 / 0。
- `tools/narrative_localization_test.py`：55546 / 0。
- `tools/localization_audit.py`：91568 translations；全部通过。
- `.venv/bin/python tools/validate_data.py`：仍退出 1，输出为工作区既有剧情 schema／重复 choice／时间窗口等错误；本批新增的八个池没有相关诊断。

## 未验收边界

- 本批已用真实 UI resolver 在 headless Godot 中渲染全屏节点；没有另跑可见原生窗口人工视觉验收。
- 用户此前确认的唯一未提供作者图仍是全裸透明立绘 `ward_preparation/shy`（`examination/shy` 通过别名共用）；本批八张 CG 不替代该立绘。
