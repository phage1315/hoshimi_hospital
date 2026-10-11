# 通用检查 CG 包 v1

本批为门诊检查流程提供六张 16:9、SFW、成年女性通用 CG。CG 在对应检查选择完成后、文字结果出现前显示；数据层允许每个检查池继续加入多张图片并随机抽取。角色专属 CG 可在后续作为高优先级覆盖素材加入。

## 普通检查 splash（2026-10-11）

仅本文件下表的六个通用池显式设置 `presentation: "splash"`：保留原诊室页面，图片显示在非全屏浮层内；至少显示0.5秒后启用右下角“查看结果”，不再自动消失。可点击按钮，或半秒后按Enter/Space继续；鼠标移入不会自动关闭。浮层屏蔽下层鼠标和键盘操作，关闭后只执行一次既有结果/微事件/跨日回调，不额外消耗游戏时间。

未指定 `presentation` 的患者专属检查CG仍走原全屏与 `display_seconds` 流程，剧情CG、麻醉与病房准备CG不受本次修改影响。回归入口：`tools/examination_splash_test.gd`（中英文）及 `tools/clinic_test.gd`。

| CG 池 | 画面 | 当前覆盖 |
|---|---|---|
| 采血检查 | `assets/examinations/generic_v1/blood_draw.png` | 血常规、肝肾功能、乳酸、肿瘤标志物等采血项目 |
| 腹部超声 | `assets/examinations/generic_v1/abdominal_ultrasound.png` | 腹部超声 |
| CT 检查 | `assets/examinations/generic_v1/ct_scan.png` | 腹部、胸部、CTA、分期等 CT 项目 |
| MRI 检查 | `assets/examinations/generic_v1/mri_scan.png` | 乳腺、肝脏、盆腔 MRI |
| 内镜准备 | `assets/examinations/generic_v1/endoscopy_preparation.png` | 胃肠镜、支气管镜、膀胱镜、直肠镜、超声内镜 |
| 妇科检查准备 | `assets/examinations/generic_v1/gynecology_preparation.png` | 妇科相关术前检查占位 |

前五张的护士服装已统一为浅粉色纯色短袖连衣护士裙与同色护士帽。不得在非手术检查 CG 中使用刷手服、V 领上衣或裤装。内镜图中的医生保留白大褂，以便区分职责。妇科检查图按现有构图保留。

映射配置位于 `data/examination_cg_pools.json`。每个池的 `paths` 可直接增加同类 CG，运行时会随机选择一张；`test_ids` 与 `surgery_ids` 决定触发来源。

## 完全脱衣基础查体

门诊基础查体的“权威说服”“温柔说服”和“威胁”三条继续分支均支持脱衣 CG；“放弃”分支不触发。奥寺美纪当前使用专属池 `full_undress_basic_exam_patient_miki`，图片位于 `assets/examinations/patient_miki/full_undress_basic_exam.png`。其他患者仍保留 `full_undress_basic_exam` 预留标识，待有对应通用或专属素材后再启用。CG 表现患者在同意或被迫配合后脱去全部衣物、准备接受基础查体的阶段，不直接描绘触诊或听诊。
