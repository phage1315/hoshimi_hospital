---
name: add-patient
description: Add or migrate an ordinary Hoshimi Hospital patient; generate and audit standard SFW portraits against actual patient_ann assets, import supplied examination art and exclusive CGs, and validate bundle and dialogue-profile integration.
metadata:
  short-description: Add a self-contained ordinary patient bundle
---

# Add a patient

Use this skill when adding a new ordinary/random-pool patient or importing a replacement patient into the Hoshimi Hospital project. The goal is a self-contained patient bundle: adding a patient should normally require data and assets, not new runtime code.

## Project invariants

- Work in the actual game repository, not a wrapper or generated Codex working directory. Confirm the root with `git rev-parse --show-toplevel` and inspect `git status` before editing.
- A patient bundle is `data/patients/<patient_id>/patient.json` and is indexed by `data/patients/index.json`.
- The bundle has two different levels:
  - `bundle.patient.visuals.portraits`: runtime portrait mapping.
  - `bundle.exclusive_cg_pools`: patient-owned examination, ward-preparation, and surgery CG pools.
- Do not hand-edit generated encounter/preop collections. The content loader combines the patient bundle with `data/patients/templates/encounter.json`, `data/patients/templates/preop.json`, and the dialogue profile.
- Preserve an existing internal ID when only the display name changes. Rename the display name in the bundle and related labels; do not silently create a second patient.
- Random ordinary patients must not acquire fixed diagnosis, surgery, anesthesia, relationship, or story-event gates unless the design explicitly requests it. `fallback` is only a safe case fallback, not a fixed identity lock.

## CG integration gate and phased import workflow

**A requested full-screen CG import is not complete when its image is copied, indexed as a portrait, or listed in an import report. It is complete only when the runtime can select and display it from the intended player action/stage. Never report CG import complete based on file presence alone.**

Patient import is phased. First import and test the complete set of supplied/generated baseline assets and the patient bundle. Full-screen CGs are an optional later addition unless the user explicitly includes them in the current batch. An empty full-screen CG category, or an empty `encounter.full_undress.visual_pool_id`, is **not** a baseline-import failure when no full-screen CG was requested/provided for this phase. Record it as “deferred optional full-screen CG; portrait/baseline import is independent.” Do not generate a CG, invent a trigger, substitute a portrait, or hold the baseline import open merely to fill an optional CG slot. If full-screen CGs are in the current scope, their full runtime chain remains mandatory and any missing requested link blocks only the CG-completion claim, not independently valid baseline portrait/bundle import.

Before editing, create an explicit per-patient CG inventory from the user's request and supplied files. Keep these asset classes distinct:

1. `patient.visuals.portraits`: character portraits / state art.
2. `encounter.full_undress.visual_pool_id` + `exclusive_cg_pools.examination`: full-screen examination CGs.
3. `exclusive_cg_pools.ward_preparation`: ward and operating-room preparation CGs, each bound to real runtime `action_ids`.
4. `exclusive_cg_pools.surgery`: surgery-stage CGs, bound to the actual surgery/stage selection contract.

For **every** user-requested or user-supplied full-screen CG in the current phase, record the source, runtime path, SHA-256, pool ID, trigger ID(s), patient scope, and English label/caption. Then verify the complete chain:

`source image → runtime asset path → patient-owned pool → real runtime action/stage ID → English localization → UI resolver`

The following are hard failures that block claiming the requested full-screen CG complete and must be fixed or explicitly reported as blocked; they may not be silently treated as optional when that CG is in scope:

- A requested CG is present only in `visuals.portraits` but its full-screen pool/trigger is missing.
- A requested CG file exists but no runtime pool points to it, the relevant patient ID is absent, or the pool has no valid trigger IDs.
- A pool points to a nonexistent action/stage ID, or the correct trigger resolves to a generic/other-patient image instead of the intended patient CG.
- English mode cannot reach the same CG through the same locale-invariant action/stage ID, or its label/caption is missing/untranslated when the UI localizes those fields.
- The importer says `complete` while any requested CG link is missing or unverified.

Empty `exclusive_cg_pools` arrays are acceptable when the category has no requested/provided/required patient-specific CG in the current phase. Put the reason in the import record (for example, “optional full-screen CG deferred; no patient-specific full-screen art in this baseline batch”). Never infer this from empty arrays. A generic fallback counts only if the request accepts it; it does not satisfy a request for a patient-specific CG.

Before handoff, run the focused trigger audit for every requested CG and at least one end-to-end resolver/runtime test per distinct pool category. If Godot is unavailable, exhaust static resolver tests and clearly state runtime display was not tested; do not claim the runtime trigger was verified.

## 1. Establish the patient contract

Before importing art, resolve:

1. A unique internal ID, normally `patient_<short_id>`.
2. Display name, adult age, and whether the patient is random-pool or a story patient.
3. Existing dialogue profile ID. Reuse a profile and override only patient-specific lines; do not duplicate an entire profile without a reason.
4. Baseline traits and fear profile, keeping the existing numeric model unchanged unless balance work is explicitly requested.
5. `case_id` and `fallback` values. For an ordinary patient, keep the case assignment random at runtime; do not turn a character biography into a fixed diagnosis.
6. Whether the patient needs diagnosis reactions or exclusive CGs. Empty arrays are valid when no special content exists yet.

For an age range supplied as “19–25”, choose one integer once and record it in the bundle. Do not regenerate it on every validation or load.

## 2. Prepare the portrait matrix

本节是新增患者的 ImageGen 制作与验收规范。生成前必须完整阅读，并实际打开对应参考图；仅在提示词写“参考高卷杏”不构成使用参考。用户已授权的生成工作直接执行，不重复索要授权。

### 2.1 制作范围：20 张 SFW 标准图 + 1 张用户提供的诊察立绘

普通患者基线是 **21 个运行时键**：门诊 1、病房 6、仰卧手术台 4、截石位手术台 4、术中头像 4、全麻 splash 1、诊察立绘 1。通常由 ImageGen 制作前 20 张 SFW 图，`examination/shy` 使用用户提供的图片。

- `examination/shy` 位于 `bundle.patient.visuals.portraits`，是透明角色立绘。它不自动成为 `exclusive_cg_pools.examination` 的全屏 CG；有独立全屏诊察 CG 时，分别导入、分别绑定。
- 脱衣后裸露立绘及患者专属 CG 默认由用户提供。不得为了凑齐 21 键而自行生成裸露诊察图、替换为其他患者或通用 CG。保留用户原图、尺寸和 Alpha，除非用户另行要求处理。
- 20 张标准图全部是 SFW：门诊/病房穿衣；手术台和全麻图用不透明铺巾完整遮盖胸部、腹部、骨盆及大腿；术中头像只取头、颈、肩和锁骨，画面不包含乳房。无裸露私密部位、无手术创口、无血腥。
- **裸肩/露锁骨要求适用于手术台、术中头像、全麻 splash；不得套用为病房服装要求。** 病房按既有患者穿浅蓝交领病号服。
- `splash/general_anesthesia_pre_induction` 是可选的额外第 22 键，不属于这 21 键。`choose_general` 请求的是诱导前图；`induction_reassure` / `induction_brief` 使用完成诱导的 `splash/general_anesthesia`。闭眼面罩图不能同时冒充诱导前图。

### 2.2 必须实读的参考及实际规格

从 `data/patients/patient_ann/patient.json` 的 `patient.visuals.portraits` 读取参考路径；不要只列目录或读 PNG 文件头。生成每类图片之前，使用图像查看工具打开该类基准及对应表情参考，并检查实际尺寸、模式、透明通道。

以下缩写均为仓库根目录下的真实路径，传给 ImageGen 前展开为绝对路径：

- **A** = `assets/characters/patient_ann_v1/patient_ann/`
- **I** = `assets/characters/intraoperative_portraits_v1/patient_ann/`
- **G** = `assets/events/anesthesia_v1/patient_ann/general.png`

2026-10-09 实查高卷杏，并交叉核对 `patient_miki`、`patient_gigi`、`patient_rie` 的文件后，新图交付规格如下。每张均为独立 PNG，尺寸是最终文件要求，不能凭生成提示词认定已满足。

| 类别 | 张数 | 新图最终尺寸/模式 | 实际构图参考 |
| --- | ---: | --- | --- |
| 门诊 | 1 | `1024×1536 RGBA`，真实透明 | `A/outpatient/neutral.png` |
| 病房 | 6 | `1024×1536 RGBA`，真实透明 | `A/ward/{state}.png` |
| 仰卧手术台 | 4 | `1448×1086 RGB`，完整背景 | `A/operating_table/{state}.png` |
| 截石位手术台 | 4 | `1448×1086 RGB`，完整背景 | `A/operating_table_lithotomy/{state}.png` |
| 术中头肩头像 | 4 | `1448×1086 RGBA`，真实透明 | `I/{state}.png` |
| 全麻 splash | 1 | `1672×941 RGB`，完整背景 | `G` |

实际历史例外：高卷杏 `I/anesthetized.png` 是 `1343×1171 RGBA`；美纪、Gigi、理惠同类四态均为 `1448×1086 RGBA`。新患者统一使用后者画布，参考高卷杏的表情及头肩构图，不能称高卷杏所有术中图都是同尺寸。不要借机修改已有患者的历史文件。

Alpha 实查：高卷杏门诊/病房是 RGBA，Alpha 范围 `0–254`，有约 42–45% 全透明像素；术中头像范围 `0–255`，也有真实透明区域。查看器显示黑底、渐变或隐藏 RGB 色块，不足以证明背景不透明；RGBA 文件头也不足以证明背景透明。必须检查 Alpha，并在浅色/深色底上观察合成结果。新图不必复制旧图的 Alpha 最大值 254、杂边或精确透明面积比例。

### 2.3 各类镜头、服装、覆盖和人物尺度

**门诊 `outpatient/neutral`**

- 单人竖向站姿，从完整头顶到大腿/膝上裁切；不是大头照，也不是从头到鞋的全身远景。人物居中，头顶留白、脸的大小、肩腰位置及下缘按高卷杏门诊图对齐。
- 采用用户确认的角色日常服装、五官及 2D 画风；高卷杏只提供构图尺度，不把她的金发、双马尾、蓝眼、衣服或包复制给新角色。
- 真透明背景，无场景、地板、渐变光晕、文字、边框。角色服装正常遮盖身体。

**病房 `ward/*`**

- 六张独立竖图，完整头顶至大腿/膝上、双臂自然垂放，统一站姿、头位、体型和裁切，参考 `A/ward/neutral.png`。
- 浅蓝色交领、侧腰系带、宽袖病号服，肩部被衣服覆盖，领口形状参考原图。不得生成露肩吊带睡衣、低胸白上衣，也不得用门诊常服充当病房服。
- 头发保持角色辨识度，此阶段不戴手术帽。六态只改变面部表情、视线及合理的泪水/紧张细节，不改变服装、姿势或背景。

**仰卧 `operating_table/*`**

- 横向 4:3 完整手术台场景，从上方俯视；手术台沿画面中央纵向伸展，头在上方、足端在下方。可见枕头、双臂/手、铺巾覆盖的躯干与腿、小腿/足端及两侧手术室环境。不能缩成脸到胸口的近景。
- 青绿色手术帽，头发按台面参考收好；不把日常蝴蝶结、长辫或头发任意铺到胸前。角色用五官、眼色及可见发际线辨识。
- 不透明青绿色铺巾上缘位于腋下附近的上胸位置，胸部及下身完整覆盖。双肩和两侧锁骨清楚可见；无病号服领口、吊带或衣袖，也不能把铺巾拉至颈部遮掉锁骨。
- 四态保持相同俯视角度、身体尺度、手臂位置、台面、铺巾和设备布局。
- **高卷杏的 `anesthetized` 是闭眼、无面罩。此类默认不加麻醉面罩或呼吸管。**

**截石位 `operating_table_lithotomy/*`**

- 使用该类实际参考，不能从仰卧图靠文字猜姿势。横向 4:3，从高处向下看完整台面，头和枕头在上方，双腿屈曲分开，膝/小腿由两侧黑色软垫腿托支撑，小腿和双脚朝画面下方延伸。
- 头、肩、手、腿托、双小腿和双脚的相对位置及透视按 `A/operating_table_lithotomy/awake.png`。不是从两腿之间低机位仰拍，也不是只见两座布包和一个头的远景。
- 青绿色不透明铺巾从上胸连续覆盖胸、腹、骨盆及大腿中间，腿部开口只露出参考图中的小腿/脚；无会阴可见、无检查动作。保持裸肩/锁骨和手术帽。
- 四态仅改变表情；`anesthetized` 闭眼、无面罩，与该类既有参考一致。

**术中 `intraoperative/*`**

- 单个人物正面头肩头像，横向透明画布。完整手术帽、正面脸、颈部、双肩及锁骨可见，下缘截止于锁骨以下的上胸，乳房不入镜。
- 头部居中且占主要画面，肩线延伸到左右下侧，按 `I/tense.png` 对齐帽顶、眼线、下巴、肩线。无床、枕头、器械、室内背景；不添加横跨下缘的铺巾或病号服领口。
- 四态统一头像轮廓、角度和尺度，发型收在帽内。`anesthetized` 是闭眼放松头像，**无面罩、无呼吸管**，不是缩小的全麻 splash。

**全麻 `splash/general_anesthesia`**

- 横向近 16:9 完整手术室画面，俯视头肩/上躯干近景；患者闭眼居中，白枕头、青绿色手术帽、覆盖口鼻的透明麻醉面罩及向画面右侧延伸的管路可读，构图按 `G`。
- 双肩和锁骨在铺巾上方可见，不透明铺巾覆盖胸部及画面下方。不是全身手术台远景，也不是透明头像。
- 该参考中帽外有部分头发；可按角色外貌适配，但不要把此特例套到其他台面/术中头像类。无 UI、文字或额外医护人物。

### 2.4 逐键清单：每次只制作一张独立图片

下表中的表情含义以对应真实参考图为准；描述用于区分状态，不能授权改变机位或动作。

| 运行时键 | 必须查看并作为构图/表情输入的文件 | 表情要求 |
| --- | --- | --- |
| `outpatient/neutral` | `A/outpatient/neutral.png` | 自然、中性友善 |
| `ward/neutral` | `A/ward/neutral.png` | 平静自然 |
| `ward/smile` | `A/ward/smile.png` | 温和笑容 |
| `ward/brave` | `A/ward/brave.png` | 坚定、努力镇定，与 smile 有可见区别 |
| `ward/worried` | `A/ward/worried.png` | 忧虑、眉眼收紧 |
| `ward/afraid` | `A/ward/afraid.png` | 明显害怕，与 worried 有可见区别 |
| `ward/crying` | `A/ward/crying.png` | 可见泪水及哭泣表情 |
| `operating_table/awake` | `A/operating_table/awake.png` | 清醒、睁眼 |
| `operating_table/tense` | `A/operating_table/tense.png` | 清醒紧张 |
| `operating_table/afraid` | `A/operating_table/afraid.png` | 清醒害怕 |
| `operating_table/anesthetized` | `A/operating_table/anesthetized.png` | 闭眼放松，无面罩 |
| `operating_table_lithotomy/awake` | `A/operating_table_lithotomy/awake.png` | 清醒、睁眼 |
| `operating_table_lithotomy/tense` | `A/operating_table_lithotomy/tense.png` | 清醒紧张 |
| `operating_table_lithotomy/afraid` | `A/operating_table_lithotomy/afraid.png` | 清醒害怕 |
| `operating_table_lithotomy/anesthetized` | `A/operating_table_lithotomy/anesthetized.png` | 闭眼放松，无面罩 |
| `intraoperative/tense` | `I/tense.png` | 正面紧张头像 |
| `intraoperative/pain` | `I/pain.png` | 明显疼痛表情，无创口/血液 |
| `intraoperative/near_collapse` | `I/near_collapse.png` | 疲惫、几乎撑不住，与 pain 区分 |
| `intraoperative/anesthetized` | `I/anesthetized.png` | 闭眼放松，无面罩；新图统一 1448×1086 |
| `splash/general_anesthesia` | `G` | 闭眼，面罩和管路可见 |
| `examination/shy` | 用户提供的诊察立绘 | 原样导入，不属于 SFW 生成清单 |

### 2.5 ImageGen 调用与提示词规则

1. 先检查用户授权及现有素材，按上述清单列出“已有可用/待生成/用户提供/缺失”。有完整 21 键不等于有 21 张合格图片。
2. 使用可用的 `imagegen` skill 和内置生成工具。每次调用只生成一个运行时键的一张图，禁止 2×2、四宫格、sprite sheet、contact sheet 或表情拼图作为生产输出。批量任务也应逐张调用。审计展示可用联系表，但不得作为运行时资产。
3. 每次调用前建立并核验该图的参考清单：运行时键、用户人物参考的绝对路径及用途、同类构图参考的绝对路径及用途、局部编辑时该患者已验收基图的绝对路径及用途。实际打开每张输入，确认内容和画幅；**全场景键必须使用同类完整场景作构图参考，头像键必须使用同类头像作参考**。不得仅凭文件名猜类型，亦不得把头像误作完整场景、把全身图误作头像。人物身份参考和构图参考要分开说明；未核实输入前不得调用生成工具。
4. 将门诊、病房 neutral、仰卧 awake、截石位 awake、术中 tense、全麻 splash 作为第一波六张独立基图。六类互不依赖：准备好各自独立的提示词和实际参考后，尽量在同一轮并发提交六次 ImageGen 调用；**每次调用仍只生成一张图**，不得把多个运行时键合并到一个提示词或拼图。若工具的并发限制不允许六路同时运行，按可用并发数分组提交，不要人为等一个类别完成后才开始另一个独立类别。
5. 第一波返回后，对六张基图做机器规格检查和并排视觉检查，并整理成一张仅供审核的联系表（每格标出运行时键；不得把联系表作为生产图）。一次性向用户展示六类基图、逐类通过/待修状态及需要决定的问题，等待用户确认基图方向后再开始第二波。任一基图未通过时，只修对应类别；不得基于未验收基图扩散生成该类差分。该审核关口是批量基图的单次确认，不要拆成逐图确认。
6. 用户确认后，将余下 14 张作为第二波：在已验收的本类基图上分别编辑表情，锁定衣服、帽子、头肩位置、躯干、背景、铺巾和镜头。各图调用相互独立时尽量并发提交，但每次调用仍只产出一个运行时键的一张独立图片。禁止用 smile 文件复制出 brave、用 worried 文件复制出 afraid，或通过改名/轻微色调变化凑状态。
7. 透明类设置 `transparent_background: true`；RGB 场景类设为 `false`。不得写“transparent OR plain neutral background”；前者要求实际 Alpha，纯色底不合格。
8. 在提示词中写明最终画幅比例、目标尺寸、裁切和覆盖边界。生成器的尺寸/模式不保证符合提示词，返回后必检。需要规范尺寸时只做保比例缩放及不损坏构图的画布调整，保留原件并记录处理；禁止拉伸、裁掉关键身体部位、从小拼图切片放大充当成品。背景移除/图像内容修复依照 imagegen 工具规则，不自行用抠色破坏边缘。
9. 被工具拒绝的图片不能记为完成。拒绝仅说明该次请求未获准，不足以单独证明整项内容永远不可生成；不得据此武断地向用户宣称“一律不能重试”，也不得把用户要求重试直接定性为规避。若用户明确要求重试，先检查并修正提示词或输入中的具体问题；在平台规则允许的范围内，最多进行三次有实质调整的重试，并如实记录每次结果。禁止原样连续刷请求、通过拆分或改写来规避平台规则。若无法在规则内保留用户要求的关键内容，停止并说明具体受限点；不得擅自改成实质不同的场景、把替代图说成原请求已完成，或将其导入为合格资产。继续其他彼此独立且可完成的键。也不得擅自改变铺巾高度或机位制作不符合规范的替代品。
10. 每次生成返回后先确认工具确实返回了图像，并以图像形式查看实际结果；不同工具可能以 `image_url`、图像内容块或保存路径返回。不得把 base64/图像数据用文本打印代替展示。将结果与该键的参考清单及用户要求逐项核对身份、镜头、姿势、服装/铺巾、场景和状态。任何关键项不符即标为未通过，不得展示成“完成”、复制到运行时目录或写入 bundle；修正后再生成。用户要求停止时立即停止图像生成。

每次调用使用以下结构，并填入本类的具体要求；不要把六类要求混在一次调用中：

```text
Deliverable: ONE standalone PNG for [runtime key], [target WxH], [RGB scene / RGBA true transparency]. No sheet, panels, text, borders, watermark or UI.
Input roles: [user reference paths] define the new adult character's face, eye/hair colour and 2D art style; [actual patient_ann reference path] defines camera, framing, subject scale, pose, attire/drape and expression; [accepted new-patient base path, if editing] locks identity and geometry.
Composition: [class-specific camera and crop from 2.3, including headroom and visible body parts].
Attire/coverage: [outpatient clothing / light-blue wrap hospital gown / opaque teal surgical drape and cap / cap and head-shoulder-only crop].
State: [one expression]; [no mask, except general-anesthesia splash].
Preserve: camera, subject scale, silhouette, positioning, clothing/drape, background and lighting of the accepted base; change only the requested expression when editing.
SFW boundary: ordinary clothed or draped medical presentation; no intimate anatomy, no wound, no blood. In surgical scenes show shoulders and collarbones while the chest and lower body remain covered or outside the frame.
Background: [true alpha transparency with clean edges / complete operating-room setting matching reference].
```

### 2.6 入库验收：逐张检查，不能以“已生成”代替“已通过”

- **机器检查**：文件能解码、最终尺寸/模式正确；RGBA 检查 Alpha 极值、透明像素及前景包围盒，不能只有不透明 Alpha。用 SHA-256 检查差分是否误复制；不同哈希仍需目视确认真实表情区别。无需在不存在的 `python` 环境反复失败，使用有图像库的项目/可用运行环境。
- **构图检查**：逐张与对应高卷杏文件并排查看，核对帽顶/头顶、眼线、下巴、肩线、人物占比、下缘裁切；台面图加查手、腿托、脚和铺巾覆盖。尺寸正确但镜头错误仍为失败。基图审计和全部差分审计都必须完成。
- **Alpha 检查**：在浅色与深色底合成查看发丝、帽沿及肩线；区分查看器底色、全透明像素下的 RGB 数据和实际可见背景。不得只凭预览黑底/渐变断言“没有透明”。旧素材的杂边不属于需要模仿的构图。
- **身份/状态检查**：保持用户指定五官和画风，帽内收发后仍能识别角色；病房六态、每组台面四态、术中四态分别保持一致尺度。麻醉态闭眼，不误加面罩；splash 才使用面罩。
- **记录**：每个键记录来源/实际参考路径、最终文件、尺寸、模式、Alpha 结果、哈希、实际使用的提示词和目视结果。原始生成图和未通过草稿不进入 bundle 引用。
- **运行时检查**：最终合格资产复制入项目，再绑定 `patient.visuals.portraits`；检查键、文件、解码及实际 UI 缩放/裁切。工具返回一张拼图或一张未验收图只能记为草稿，不能计为四张，也不能报告“21 张完成”。

用户专属全屏 CG 不适用以上 SFW 生成清单：优先保留用户原始文件。已有池常见 `1280×800 RGB`，用户提供其他比例时检查 `KEEP_ASPECT_COVERED` 的实际裁切，不自动替换透明诊察立绘或修改原图。

## 3. Use the correct asset paths

Use project-relative paths in JSON, for example:

```text
assets/characters/patient_<id>_v1/patient_<id>/outpatient/neutral.png
assets/characters/intraoperative_portraits_v1/patient_<id>/tense.png
assets/events/anesthesia_v1/patient_<id>/general.png
assets/examinations/patient_<id>/full_undress.png
```

For full-screen patient-owned CGs, use a patient-specific directory under the existing category:

```text
assets/examinations/patient_<id>/full_undress_basic_exam.png
assets/events/ward_preparation_v1/patient_<id>/enema.png
assets/events/ward_preparation_v1/patient_<id>/surgical_cap.png
assets/events/ward_preparation_v1/patient_<id>/incision_ready.png
```

Check that every source attachment exists before copying. Do not use a guessed temporary filename, and do not leave a failed copy looking like a completed import. Compute SHA-256 hashes after copying.

## 4. Author the bundle

Start from a nearby valid patient bundle, but edit its identity and content deliberately. The important top-level shape is:

```json
{
  "schema_version": 1,
  "patient": {
    "id": "patient_example",
    "name": "...",
    "age": 22,
    "visuals": { "portraits": {} },
    "dialogue_profile": "existing_profile_id",
    "reaction_lines": {},
    "reaction_variants": {}
  },
  "fallback": { "case_id": "case_abdomen", "surgery_id": "surgery_appendix" },
  "encounter": { "full_undress": { "...": "..." } },
  "preop": { "...": "..." },
  "exclusive_cg_pools": {
    "examination": [],
    "surgery": [],
    "ward_preparation": []
  },
  "diagnosis_reactions": []
}
```

When a full-screen examination CG is in the current import phase, use `encounter.full_undress.visual_pool_id` to connect the three completed full-undress response branches to an examination pool. The “abandon” branch should not show the completed undressing CG. If full-screen CGs are deferred, leave the pool ID empty and keep the baseline portrait import independently testable.

Examination pools use examination fields such as `test_ids`, `surgery_ids`, and `paths`; they do not use ward `action_ids`. Ward-preparation pools use:

- unique `id`
- `priority: 100` for a patient-specific override
- `presentation: "fullscreen"` when the CG should replace the normal preparation view
- `action_ids` matching real runtime action IDs
- `patient_ids: ["patient_<id>"]`
- one or more valid `paths`
- a concise patient-specific `caption`

Common action IDs are `ward_enema`, `ward_enema_unnecessary`, `ward_surgical_cap`, and `request_scalpel`. Verify them in `godot/systems/preop_session.gd`; never invent an action ID from the Chinese label. The preop UI already resolves the highest-scoring patient-specific pool, so do not add a second code path or a duplicate global pool.

The existing `ward_preparation` pool also serves operating-room preparation actions, including `urinary_catheterization`, `skin_disinfection`, and `request_scalpel`. Its name is not a room restriction. The separate `surgery` pool is selected by surgery/stage, not these action IDs; do not relocate preparation CGs there merely because the scene is the operating room.

## 5. Register and document

1. Add the bundle path exactly once to `data/patients/index.json`.
2. Keep dialogue profile inheritance in the bundle; do not copy all default profile lines merely to override a few.
3. Add an import record under `research/imports/` with source references, runtime assets, SHA-256 hashes, and an explicit integration summary.
4. Update `docs/asset_sources.md` when assets were supplied or generated, including whether surgery art is bare-shoulder and which patient CG pools were added.
5. Do not add localization entries just for data fields unless the project’s localization loader requires them. Patient pool labels/captions may follow the existing bundle convention.

## 6. Validate in this order

Run checks in layers so a global legacy warning is not confused with a new patient failure:

1. Parse both the bundle and import record with the project Python environment. Do not assume `python` exists; use the configured venv when available.
2. Load all bundles through `tools/patient_bundles.py` and confirm:
   - the patient appears exactly once;
   - generated encounter and preop IDs are linked to the patient;
   - the dialogue profile expands to the expected core reaction/variant counts;
   - every portrait and every exclusive-pool path exists.
3. Compare the portrait key set against `patient_ann` or the chosen complete reference. Report missing and extra keys explicitly.
   Complete the per-image acceptance in §2.6 as well: a matching key set alone does not establish correct art, expressions, dimensions, transparency, or composition.
4. For every full-screen CG requested in the current phase, resolve its patient-specific pool through the same action resolver used by the UI and verify no other patient selects it. In particular test necessary and unnecessary enema, surgical cap, and scalpel-ready actions when those CGs are in scope.
   - Build a trigger matrix from the user's requested CG list, not merely from pools already present in the bundle. Every requested image must have an expected trigger and exactly one valid patient-scoped destination (or an explicitly documented shared-pool reason).
   - Assert every requested runtime image path is referenced by the expected pool and every expected action ID resolves to that pool. Also assert the English locale produces the same pool/image selection.
   - Treat a requested full-screen image with no trigger, or its in-scope category pool silently empty, as a CG-release-blocking failure. Do not apply this CG gate to baseline portrait/bundle completion when full-screen CGs are deferred.
5. Run `tools/validate_data.py`. Record whether failures are new and patient-specific or pre-existing project warnings. Do not report “validation passed” when the command still contains unrelated errors.
6. If a Godot executable is available, run the relevant bundle/preop tests and inspect the actual CG trigger at least once. If it is unavailable, report that limitation rather than implying a live UI test was performed.

## 7. Lessons from the 香田映見 import

These were concrete mistakes and must not recur:

- A first audit read `bundle.visuals` instead of `bundle.patient.visuals`, falsely reporting zero portrait keys. Always respect the bundle nesting before judging missing art.
- The generated standard anesthesia image was mapped only to `splash/general_anesthesia`. The runtime asks for `splash/general_anesthesia_pre_induction` at `choose_general`, so no image appears at that earlier action. Treat the two phases as separate assets and keys.
- A user-provided full-screen examination image must not replace the transparent `examination/shy` runtime portrait. Keep the portrait for character UI and put the full-screen image in the examination CG pool.
- A copied image is not integrated until its pool is present and its action IDs are real. Copying files alone does not make a CG trigger.
- The project had an actual repository path different from the Codex wrapper cwd. Editing or validating the wrong checkout can produce a convincing but irrelevant result; always confirm the repository root first.
- The global validator already reports unrelated historical content issues. New-patient acceptance must use focused bundle/pool checks in addition to the global validator, not hide or misattribute those warnings.
- Keep research-only reference files if useful, but ensure they are not referenced by runtime JSON. Do not delete them merely because they are not part of the final portrait matrix.

## Completion checklist

- [ ] Unique patient ID and display name are confirmed.
- [ ] Bundle is indexed exactly once.
- [ ] `patient.visuals.portraits` contains the complete expected key set.
- [ ] The 20 standard SFW images and the user-provided examination portrait are accounted for separately; optional extra splashes are not counted toward the baseline 21.
- [ ] The six independent base images were generated in the first parallel wave, reviewed together at the single user confirmation gate, and approved before any dependent expression variants were generated.
- [ ] Each generated key used the actual corresponding composition reference; all base images and individual expression variants passed §2.6.
- [ ] 每次生成调用的输入清单记录了绝对路径和参考用途；全场景没有误用头像参考，头像没有误用全场景参考；工具返回的实际图像已被查看并与目标逐项核验。
- [ ] Ward gown, surgical drape coverage, shoulders/collarbones, cap/hair, and mask presence match the asset class; no production sprite sheets or duplicated expressions were counted as complete.
- [ ] Final dimensions, RGB/RGBA mode, actual Alpha, and light/dark-background edge checks are recorded, including any supplied-image or historical exceptions.
- [ ] All portrait paths load as textures.
- [ ] `general_anesthesia` and optional `general_anesthesia_pre_induction` semantics are checked separately.
- [ ] Full-undress response mapping and examination pool are connected if a full-screen examination CG is in the current phase; otherwise the optional CG is explicitly recorded as deferred and does not block baseline completion.
- [ ] Patient CG pools use correct action IDs, patient scope, priority, presentation, and existing runtime resolver for each full-screen CG in the current phase.
- [ ] Every in-scope user-requested/user-supplied full-screen CG appears in the written inventory and passes the complete source→asset→pool→trigger→English→resolver chain; no CG is counted merely because it exists as a portrait or file.
- [ ] Any empty CG category has an explicit, user-scope-consistent reason in the import record; requested/in-scope CGs are never excused by an empty pool or generic fallback.
- [ ] No fixed diagnosis/procedure/relationship was introduced accidentally.
- [ ] Import record and asset-source documentation include hashes and integration scope.
- [ ] Focused loader and pool checks pass; global validator results are classified accurately.
- [ ] 每次工具拒绝均按 §2.5 如实记录；用户要求重试时，只在平台规则允许范围内进行最多三次有实质调整的重试，未将不同场景的替代图冒充为目标资产。
