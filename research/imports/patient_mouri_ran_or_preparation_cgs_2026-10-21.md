# 毛利兰手术室准备 CG 导入（2026-10-21）

目标患者：`patient_mouri_ran`（已注册）。用户附件1–5与用途依次为导尿、固定、铺巾、消毒、下刀。按 `skills/add-patient/references/patient-cg-node-map.md` 接入 `exclusive_cg_pools.ward_preparation`；项目节点表将“下刀”定义为 `request_scalpel`：器械护士递交手术刀后、切开前显示，`incise_*` 仍为切开动作/视频路径。图像不做额外内容审阅，仅作技术属性核对。

| 附件 | 用户指定用途 | 来源路径 | 运行时路径 | Pool / action | 尺寸、alpha | SHA-256 |
|---|---|---|---|---|---|---|
| 1 | 导尿 | `/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-e7cb9bab-a10f-4753-a4a6-f2b7b454d179.png` | `assets/events/ward_preparation_v1/patient_mouri_ran/urinary_catheterization.png` | `urinary_catheterization_patient_mouri_ran` / `urinary_catheterization` | 1584×1056 PNG / 无alpha | `cd534590c1ac601523551beab74fb78a0d953c69711193d749fdf6fd7ebbf4b0` |
| 2 | 固定 | `/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-b2286b09-761d-44c9-952b-8e09cde5b976.png` | `assets/events/ward_preparation_v1/patient_mouri_ran/operative_positioning.png` | `operative_positioning_patient_mouri_ran` / `operative_positioning` | 1584×1056 PNG / 无alpha | `004db9d03c57ff06e18e76d41e190d140b127e5b91b2a16e7e14200715b3aa49` |
| 3 | 铺巾 | `/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-4a3357a3-800b-4c60-a74b-70ca8c3b0da7.png` | `assets/events/ward_preparation_v1/patient_mouri_ran/sterile_draping.png` | `sterile_draping_patient_mouri_ran` / `ack_disinfection` | 1584×1056 PNG / 无alpha | `5fcd16f1357104492d9468fcc9c47e9519c860d6562df513ed048cead90faac3` |
| 4 | 消毒 | `/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-5f77d5ab-80b0-4bc4-81be-2332f0de24ec.png` | `assets/events/ward_preparation_v1/patient_mouri_ran/skin_disinfection.png` | `skin_disinfection_patient_mouri_ran` / `skin_disinfection` | 1584×1056 PNG / 无alpha | `4477fccd67622ed65c7ac61ddf212064f927cdfdaddc6c4c96aacc3f6f2d8ad5` |
| 5 | 下刀 | `/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-00e1ca43-8738-4cc5-ba56-f5a732be5c6d.png` | `assets/events/ward_preparation_v1/patient_mouri_ran/scalpel_ready.png` | `incision_ready_patient_mouri_ran` / `request_scalpel` | 1584×1056 PNG / 无alpha | `6c1b05826d97c0872537152bdae71a7d2e5215609dc161caa22b220e7b817383` |

五张图均以原PNG复制；尺寸、alpha属性及运行时路径已核对。池均为 `fullscreen`、`priority: 100` 且限定 `patient_ids: ["patient_mouri_ran"]`。标签/说明的英文键已补齐。静态 resolver/隔离检查和患者数据测试记录在本轮任务验证中；Godot UI 实际触发测试仍需在可用的Godot环境中执行。
