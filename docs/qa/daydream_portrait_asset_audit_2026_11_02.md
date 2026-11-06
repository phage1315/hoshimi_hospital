# 白日梦剧本立绘与 CG 技术鉴定

核对范围：三个已导入的白日梦剧本、脚本中的 `[SPRITE]`／`[CG]` 标记、现行角色 Profile 的 `visuals.portraits`、实际 PNG 路径、画布尺寸和 Alpha 通道。本文只记录资源映射，不评价剧本内容。

## 结论

用户的判断基本准确，但需要补充两点：弘子已有普通护士装，也有一张通用 `operating_patient/nervous` 立绘；千早和瑞穗都有可用的完整角色包，包含病房／术中／手术台资源。此次已把用户提供的千早惊讶病房图注册为白日梦节点的直接资源；其余未确认的专用键仍保持 `pending_assets`，不擅自借用其他差分。

## 剧本实际引用键

| 剧本 | 说话角色 | `[SPRITE]` 键 | `[CG]` 键 | 背景键 |
| --- | --- | --- | --- | --- |
| 弘子×江美子 | 弘子、江美子、真奈美、中井美佳 | `hiroko_normal`、`hiroko_smile_clipboard`、`manami_awkward_blush`、`mika_nervous` | 无 | 办公室、护士站、手术室 |
| 千早 | 千早、石神千鹤 | `chihaya_pajamas_surprised`、`chizuru_serious_clipboard` | 无 | 办公室、病房 |
| 瑞穗 | 瑞穗、南条小夜香 | `sayaka_smile_tease`、`sayaka_laugh` | `mizuho_or_laparotomy_open` | 办公室、手术室 |

脚本中还有大量 `[EXPR]` 标记。这些是表情／状态请求，不等于已经存在同名文件；现有 Profile 只登记了部分标准表情键。

## 弘子篇

已有资源：

- `assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/uniform/`：中性、严肃、微笑、惊讶、疲倦、担心，均为 1024×1536 PNG，含 Alpha。
- 同一角色已有 `scrubs/`、`sterile/` 和 `intraoperative_avatar/neutral`。
- `assets/characters/relationship_patient_v1/nurse_hiroko/operating_patient/nervous.png` 已登记为 1024×1536、含 Alpha 的手术患者半身图。
- 江美子、真奈美和中井美佳的常服／刷手服／无菌服及术中头像也已有角色包。

需要补齐或映射的项目：

- `hiroko_normal` 可以映射到 `nurse_hiroko` 的 `uniform/neutral`，但这是运行时映射，不是脚本专用文件。
- `hiroko_smile_clipboard` 没有同名资源；可映射到 `uniform/smile`，但“手持文件夹／办公室”差分仍缺专用图。
- 弘子目前只有 `operating_patient/nervous` 一张手术台对话立绘。剧本在术中使用多种羞惧、疼痛和哭泣状态，需补齐同构图差分，或由作者确认把已有术中头像／单张 nervous 作为指定复用源。
- 剧本没有 `[CG]` 键，但如果要表现手术台全景，需要独立的患者手术台场景图；现有 `operating_patient/nervous` 是透明对话立绘，不能替代全屏场景 CG。

## 千早篇

已有资源：

- `assets/characters/chihaya_mizuho_nurses_v1/patient_chihaya/` 已有常服、制服、刷手服和多张表情，Profile 已登记。
- `assets/characters/patient_chihaya_second_surgery_v1/ward/` 已有病房状态差分。
- `assets/characters/patient_chihaya_second_surgery_v1/intraoperative/` 已有中性、哭泣、惊讶、紧张、害羞、缓解、愤怒、疲倦、疼痛等状态。
- `assets/characters/patient_chihaya_second_surgery_v1/operating_table/` 已有 `awake`、`tense`、`afraid` 三张 1536×1024 手术台场景图；这些文件没有 Alpha，属于全场景图格式，不是 1024×1536 透明普通立绘。
- 石神千鹤的现有角色 ID 是 `nurse_ishigami`，已有制服、刷手服和术中头像。导入器已修正该映射。

需要补齐或映射的项目：

- `chihaya_pajamas_surprised` 已按用户提供的 PNG 接入：`assets/characters/patient_chihaya_second_surgery_v1/ward/surprised.png`，并写入 Profile 的 `ward/surprised` 运行时键及该白日梦节点的 `portrait_path`。
- 剧本中的 13 个 `[EXPR]` 名称不是现有文件名；本轮已建立显式映射表，全部指向千早现有 `ward` 状态文件（害怕、害羞、惊讶、哭泣、愤怒、疲倦），不再回退到 `uniform/neutral`。这属于运行时复用映射，不声称这些文件是同名专用差分。
- 千早已有手术台全景图，因此不需要从零制作手术台基础图；仍需确认三张现有图是否对应本篇所需构图，并补齐脚本要求的状态差分。
- `chizuru_serious_clipboard` 已按用户指定复用石神千鹤的普通制服立绘：`assets/characters/portrait_pack_v22/nurse_ishigami/uniform/neutral.png`。仍没有“办公室文件夹／严肃”专用差分，但不会再回退到未绑定状态。

## 瑞穗篇

已有资源：

- `assets/characters/mizuho_story_v1/casual/` 已有 10 张常服表情。
- `assets/characters/mizuho_story_v1/intraoperative/` 已有中性、愤怒、哭泣、疼痛、缓解、害羞、惊讶、紧张、疲倦等状态。
- `assets/characters/mizuho_story_v1/operating_table/` 已有 `awake`、`tense`、`afraid` 三张 1536×1024 手术台场景图；无 Alpha，属于全场景图。
- 瑞穗的 `intraoperative_avatar/neutral` 已存在并登记。
- 南条小夜香 Profile 已有白大褂、常服、刷手服、无菌服以及多套术中差分；`sayaka_smile_tease` 可按角色确认映射到 `white_coat/teasing`，`sayaka_laugh` 可按角色确认映射到 `white_coat/smile`。
- 项目已有 `assets/surgeries/palpation/or_table_torso_mizuho_v1.png` 和多张瑞穗既有手术／术前 CG，但它们不是脚本标记 `mizuho_or_laparotomy_open` 的同名资源。

需要补齐或映射的项目：

- `mizuho_or_laparotomy_open` 是本篇明确的 CG 键。2026-11-04 用户已提供并指定图片，现已原样接入 `assets/events/daydream_v1/mizuho_or_laparotomy_open.png`，绑定 `F03_006`；原审计缺口已关闭。
- 瑞穗已有术中状态和手术台场景图，所以基础包比弘子完整；主要缺口是本篇专用 CG、脚本表情键映射和手术台状态的逐节点绑定。

## 按项目标准检查

普通透明立绘候选按 `docs/portrait_import_standard.md` 检查：常服／制服／刷手服候选多数为 1024×1536 PNG，并带 Alpha。千早和瑞穗的 `operating_table/*.png` 是 1536×1024 横向场景图，符合手术台场景图类别，不能当作普通透明立绘使用。弘子的 `operating_patient/nervous.png` 是 1024×1536 透明半身图，能用于对话框，但不能代替手术台全景图。

本轮没有打开图片做视觉评价，只检查文件存在、Profile 引用、PNG 格式、尺寸和 Alpha 信息。下一步接入应先建立三个剧本的键映射表，再把已经确认的复用资源写入白日梦节点；没有作者指定的专用差分或 CG 保持 `pending_assets`，不借用其他角色图片。
