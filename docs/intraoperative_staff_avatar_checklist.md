# 术野 HUD 医护头像素材清单

术野 HUD 在右上角持续显示术野，患者或医护的回应头像位于其下方。现有医护无菌服素材多为纵向半身立绘；缩入该区域后脸部过小，因此每名医护需要一张独立的紧凑型术中头像。

## 统一素材规格

- 数据键：`intraoperative_avatar/neutral`
- 目标目录：`assets/characters/intraoperative_staff_avatars_v1/<staff_id>/neutral.png`
- 文件格式：带真实透明通道的 RGBA PNG
- 推荐画布：`1200 × 900`，4:3 横向构图；可接受同等比例的更高分辨率
- 构图：正面或轻微三分之二侧面的头肩像，从手术帽顶部到胸口／锁骨下方；画布紧贴人物，不保留大块透明边缘
- 服装：手术帽、口罩、无菌手术衣；头发完整收入帽内，角色身份特征仍需清晰
- 表情：一张平静、专注的通用表情即可，不制作表情差分
- 禁止内容：背景、文字、边框、器械遮脸、完整站姿、大面积透明留白

建议让脸部与手术帽合计占画面高度约 55%–70%，双肩占画面宽度约 60%–90%。成品需要在 HUD 实际显示尺寸下检查眼睛、发色和轮廓是否仍能辨认。

## 运行时与回退规则

HUD 模式优先读取 `visuals.portraits["intraoperative_avatar/neutral"]`。素材尚未完成时继续回退至现有 `sterile/focused` 或 `sterile/neutral` 半身立绘；全屏术野模式继续使用原有半身立绘。素材完成后，将文件放到数据中登记的 `target_path`，把同一路径写入 portraits 键，并将 `status` 从 `needed` 改为 `ready`。

## 当前清单

| 医护 | staff_id | 当前状态 |
| --- | --- | --- |
| 神宮寺成美 | `doc_aoi` | ready |
| 深山佳織 | `doc_rei` | ready |
| 七瀬恋 | `nurse_haru` | ready |
| 中井美佳 | `nurse_rin` | ready |
| 朝倉美幸 | `nurse_yui` | ready |
| 飯村真奈美 | `pharmacist_manami` | ready |
| 利根川安琪 | `nurse_ange` | ready |
| 杉村弘子 | `nurse_hiroko` | ready |
| 本庄萌惠 | `nurse_moe` | ready |
| 御堂江美子 | `doc_emiko` | ready |
| 城宮明日香 | `doc_asuka` | ready |
| 阿尔托莉雅·潘德拉贡 | `doc_artoria` | ready |
| 藤崎詩織 | `doc_shiori` | ready |
| 水城阿库娅 | `doc_aqua` | ready |
| 南条小夜香 | `doc_sayaka` | ready |
| 伊吹摩耶 | `visiting_maya` | ready |
| 佐仓双叶 | `visiting_futaba` | ready |
| 石神千鹤 | `nurse_ishigami` | ready |
| 樱花 | `doc_sakura_anesthesiology` | ready |
| 折川皐月 | `nurse_satsuki` | ready |

清单覆盖全部现有医护，而不只覆盖当前普通手术选择器中的角色。这样事件医护、麻醉医、护理管理者以及未来轮转角色进入术中 HUD 时不会再次出现素材缺口。

2026-10-04：已完成全部 20 名现有医护的统一 `1200 × 900` 头肩头像。19 张由现有无菌服／手术服透明立绘裁切并按实际非透明边界消除大块留白；折川皐月因缺少手术室服装源图，以既有身份立绘为参照补制手术帽、口罩及无菌衣版本。所有条目均已接入 `intraoperative_avatar/neutral`。
