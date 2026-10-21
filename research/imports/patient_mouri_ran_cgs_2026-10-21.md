# 毛利兰用户提供 CG 导入（2026-10-21）

用户给定附件1–5顺序与目标：诊室全裸查体、剃毛、灌肠、戴手术帽、上担架车。患者 `patient_mouri_ran` 已存在且在索引中注册；档案项目年龄为24。依用户提供的目标描述与 `skills/add-patient/references/patient-cg-node-map.md` 接入，不对图像内容进行额外分析或审阅。

| 附件 | 用户指定用途 | 原始附件路径 | 运行时路径 | 运行时节点 / 池 | 尺寸、alpha | SHA-256 |
|---|---|---|---|---|---|---|
| 1 | 诊室全裸查体 | `/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-85f9f884-b9b3-4eaa-96e4-e12f770dd2bd.png` | `assets/examinations/patient_mouri_ran/full_undress_basic_exam.png` | `exclusive_cg_pools.examination`; `encounter.full_undress.visual_pool_id`; completed undress choices only | 1584×1056 PNG / 无alpha | `9d104a48663229b9198f034af2eb3eb40cda391b30b4068f1dd15737dc7356f5` |
| 2 | 剃毛 | `/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-26af5bf2-634e-45c9-8602-79e73fe7e88b.png` | `assets/events/ward_preparation_v1/patient_mouri_ran/skin_prep.png` | `ward_skin_prep_patient_mouri_ran`; `ward_skin_prep`, `ward_skin_prep_unnecessary` | 1584×1056 PNG / 无alpha | `5924c74b3757dd4d64f32f511ac6fdc18fcfc919299994578189d69fe13271f9` |
| 3 | 灌肠 | `/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-4245cad3-bf0b-4964-b762-7701b1cfe5ad.png` | `assets/events/ward_preparation_v1/patient_mouri_ran/enema.png` | `ward_enema_patient_mouri_ran`; `ward_enema`, `ward_enema_unnecessary` | 1584×1056 PNG / 无alpha | `edcbadbdef6841fc725ae4b9d0a882bfa46d129c9bdb2363fea64493055fa749` |
| 4 | 戴手术帽 | `/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-46c1d13f-58fa-4169-a2ef-d065285f92d7.png` | `assets/events/ward_preparation_v1/patient_mouri_ran/surgical_cap.png` | `ward_surgical_cap_patient_mouri_ran`; `ward_surgical_cap` | 1584×1056 PNG / 无alpha | `28daf5e848e63281cc5f441b42d491d28c271d97d1d116b09b5ba8ea9bd6691c` |
| 5 | 上担架车 | `/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/codex-clipboard-56bf8e0a-508d-4c54-a4b2-c2bbb30587a7.png` | `assets/events/ward_preparation_v1/patient_mouri_ran/stretcher_transfer.png` | `stretcher_transfer_patient_mouri_ran`; `complete_manual_ward_preparation` | 1584×1056 PNG / 无alpha | `3c6d1dd5fb66d2a68cfb35fe60852b3cdb1825bb20a5a583aa67a7b23f1feb04` |

复制为原始PNG，无格式转换或图像修改。文件存在性、PNG格式、尺寸、alpha属性和哈希已核对。英文标签/说明已加到 `data/localization/en.json`。静态结构测试会验证患者池、动作ID、路径、脱衣选择池引用及英文文本；该记录不声称Godot UI触发测试已完成。
