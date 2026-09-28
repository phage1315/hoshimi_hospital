# 柳原理惠素材记录

- 角色：柳原理惠（`patient_rie`）
- 年龄：26 岁
- 定位：随机来院患者；疾病由患者轮换时随机分配，术式继续由疾病绑定产生。
- 背景：一名长期忙于工作的医生之妻；熟悉一些医疗用语，却很少真正成为被照顾的一方。
- 性格：温柔娴雅，习惯先照顾他人的感受；独处时显露长期被忽视的孤单，以及希望被认真看见和照顾的隐秘渴求。

## 原始参考

原始参考图保存在 `research/character_references/patient_rie/`。四张日常服装图用于身份、服装和表情参考；用户提供的透明裸体图仅接入成人检查相关的 `examination/shy` 状态，不用于普通门诊、病房或常规手术画面。

## 游戏素材

- 门诊立绘：`assets/characters/patient_rie_v1/patient_rie/outpatient/`
- 病房立绘及差分：`assets/characters/patient_rie_v1/patient_rie/ward/`
- 手术台全景及差分：`assets/characters/patient_rie_v1/patient_rie/operating_table/`
- 全身麻醉 splash：`assets/characters/patient_rie_v1/patient_rie/splash/general_anesthesia.png`
- 术中反应头像：`assets/characters/intraoperative_portraits_v1/patient_rie/`
- 检查相关立绘：`assets/characters/patient_rie_v1/patient_rie/examination/`

`examination/shy.png` 已从原始 917×688 横向透明画布裁去两侧留白，并等比重构为 1024×1536 纵向画布。人物从头顶显示至大腿上部，主体占画面比例与琪琪的检查立绘接近；原始用户附件仍保存在 `research/character_references/patient_rie/05_examination_reference.png`。

手术台素材沿用现有患者的统一俯视全身构图。术中头像包含 `tense`、`pain`、`near_collapse`、`anesthetized`；其中疼痛与濒临崩溃差分按柳原理惠本人的五官、克制性格和情绪方式单独制作。

## ImageGen 提示词摘要

生成模式包括 `identity-preserve` 与 `compositing`。核心约束是保留深靛色长发、棕色眼睛、温柔成熟的椭圆脸和克制姿态；进入手术画面后侧发与长发收进手术帽，前额保留整齐的标志性刘海。手术台全景严格参考既有患者的俯视构图，术中头像严格参考既有透明头像的肩颈范围。
