# 樱井沙雾素材记录

- 患者：樱井沙雾 / Sagiri Sakurai，`patient_sagiri_sakurai`，27 岁。
- 数据及三张用户种子图原件：`research/character_references/patient_sagiri_sakurai/`；文件来源和 SHA-256 见 `research/imports/patient_sagiri_sakurai_registration_v1.json`。
- 用户已确认六张基础图，并授权制作全部表情差分。中文原文未改动。
- 使用内置 ImageGen，以上一轮已确认的沙雾同组基础图作为编辑目标，高卷杏对应图仅作为表情参考。保持沙雾发色、绿眼、脸型、服装、姿势与镜头。
- 新增差分：病房 5 张；仰卧手术台 3 张；截石位手术台 3 张；术中头像 3 张。连同基础图共 20 张独立图片。
- 运行时目录：`assets/characters/patient_sagiri_sakurai_v1/patient_sagiri_sakurai/`。
- 提示词、原始生成路径、SHA-256、尺寸、Alpha 检查和映射：`research/patient_candidates/patient_sagiri_sakurai/expressions_v1/` 下的 JSON 记录。
- 透明素材已进行浅底、深底合成核查。术中头像保留生成器原生尺寸：基础图 1447×1087、差分 1446×1087；同组相差 1 像素，符合现有 `portrait_test.gd` 容差，无裁切或拉伸。
- 检查立绘和可选麻醉前／硬膜外 CG 不属于本次请求，未生成。
- 用户种子原图与 AI 派生素材分目录保存，所有导入均为逐字节复制。

运行时测试结果见 `research/patient_candidates/patient_sagiri_sakurai/expressions_v1/validation.json`。

## 2026-10-27 用户提供资源导入

本批按用户附件顺序映射，十张原图逐字节复制，未裁切、改图、生图或上传。只检查格式、尺寸、Alpha、校验和及运行时引用；未进行额外视觉审查。原剧情与对白未改动。

| 用户用途 | 运行时入口 |
|---|---|
| 全裸立绘 | `examination/shy` |
| 灌肠 | `ward_enema`, `ward_enema_unnecessary` |
| 剃毛 | `ward_skin_prep`, `ward_skin_prep_unnecessary` |
| 戴手术帽 | `ward_surgical_cap` |
| 固定 | `operative_positioning` |
| 消毒 | `skin_disinfection` |
| 导尿 | `urinary_catheterization` |
| 担架车 | `complete_manual_ward_preparation` |
| 下刀前 | `request_scalpel` |
| 铺巾 | `ack_disinfection` |

新 CG 标签及说明仅使用“樱井沙雾 · 用户提供用途”的索引文字，并补齐对应英文；未新增剧情旁白。未额外限定术式组，沿用动作自身资格与全麻抑制规则。全裸立绘独立于全屏检查 CG，未创建全屏检查池。

来源绝对路径、运行时路径、SHA-256、原生尺寸及映射详见 `research/imports/patient_sagiri_sakurai_supplied_2026-10-27/manifest.json`。验证结果见同目录 `validation.json`。
