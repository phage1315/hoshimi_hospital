# 人物素材 / 本地占位测试

### 人物立绘Lossy 0.90试玩（2026-10-13）

- 用户反馈重新导出约1.64G，授权继续尝试立绘有损导入。范围为真实加载的医护／患者 `visuals.portraits`（排除已处理的麻醉splash）及剧情 `portrait_path`，去重830张，含人物状态图；其中2张与CG池共用、已是Lossy 0.90，本轮实际新增修改828张。不按目录处理未引用旧图或研究参考图。
- 仅改 `.import` 的 `compress/mode=1`、`compress/lossy_quality=0.9` 并重新导入。全部原PNG、路径、尺寸、节点绑定及其他导入参数不变；830张源图SHA-256和压缩前设置／纹理大小存于 `research/imports/portrait_lossy_trial_2026-10-13.json`。回退按各条目的原始设置恢复，2张原有Lossy共用图不回退成无损；不要使用Git重置。
- 本组830张导入纹理886,614,000→140,749,162字节（845.54→134.23MiB）；单算新增828张为845.33→134.02MiB，减少84.15%、约711.31MiB。未重新导出ZIP，不能将此数字直接视为新安装包体积；导出排除规则及全局默认设置未改。
- 逐张原图哈希、尺寸、解码及每个像素的alpha字节比较通过，透明轮廓／半透明度未改变。此检查不等于RGB颜色、线条细节无损，也不代替用户实际窗口画质验收。重新启动工程即可试玩；旧ZIP必须另行导出。
- 同期立绘UI回归发现芳美原图尺寸不一致：截石位tense／afraid为1448×1080，对比awake的1448×1086；术中pain为1222×1287，对比tense的1448×1086。源PNG与压缩前记录一致，压缩未改变尺寸；保留原图并另记问题，不擅自裁切／拉伸来通过测试。

### 背景／剧情／岗位／麻醉CG扩展Lossy（2026-10-13）

- 用户试玩ASSET-033后反馈非立绘CG有损效果看不出差异，并明确授权背景、独立剧情CG、岗位CG及麻醉CG全部沿用Lossy 0.90。该反馈属于上一批试玩结果，不代替本批画质验收。
- 按真实加载内容定位151张新增PNG：背景注册51张、剧情节点 `cg_path`／画廊 `path` 43张、岗位奖励31张、患者全麻／诱导前／硬膜外splash 26张。工具 `tools/fullscreen_lossy_inventory.gd` 检查中英文集合并排除立绘引用；不按目录整批压缩，未接入的旧版本、参考图及无关素材不纳入。
- 151个 `.import` 只改 `compress/mode=1` 和 `compress/lossy_quality=0.9`，已经重新导入。原图SHA-256、尺寸、原设置与原纹理体积保存在 `research/imports/fullscreen_lossy_2026-10-13.json`；PNG原图、路径、剧情节点、背景ID、岗位／麻醉触发和语言数据不改。其他导入文件与本轮前快照比较不变，包含上一批256张的Lossy设置。
- 新增纹理215,432,444→34,631,044字节（205.45→33.03MiB），减少83.92%；与上一批合计407张，499.80→73.59MiB，减少约426.21MiB。只是纹理文件实测，未重新导出ZIP，默认导入及导出排除规则不改。
- 回退方式同上批：仅按本批清单恢复两项原始导入设置并重新导入，不能用Git重置覆盖用户的其他修改。停止当前游戏后重新运行工程可测试新纹理；旧ZIP不自动更新。

### CG池有损导入试玩（2026-10-13）

- 用户授权先测试现有CG的Lossy导入。范围由当前ContentLoader实际加载的三个集合确定：`examination_cg_pools` 46张、`surgery_cg_pools` 114张、`ward_preparation_cg_pools` 96张，共256张，包括患者包注册的专属池。
- 仅修改这些PNG的 `.import`：`compress/mode=1`、`compress/lossy_quality=0.9`，并执行Godot重新导入。原始PNG逐字节保留，路径、尺寸、池ID、触发条件及中英文映射不变。没有转成JPG、缩图或修改画面；人物立绘、背景、非池剧情CG、麻醉splash及其余导入设置不纳入。
- 256张源图共436.39MiB；导入纹理从294.35MiB降至40.56MiB，减少86.22%。这是当前纹理文件实测，不是重新导出ZIP后的整包测量。默认导入规则、导出排除规则与既有ZIP均未修改。
- 来源与原图SHA-256、原始压缩设置、尺寸、原纹理大小记录于 `research/imports/cg_lossy_trial_2026-10-13.json`。恢复时只将清单内 `.import` 的 `compress/mode` 和 `compress/lossy_quality` 恢复为清单的 `original_compress_mode`／`original_lossy_quality`，再重新导入；不要用Git重置，以免覆盖用户其他修改。
- 试玩应停止当前运行实例后重新启动项目；已经导出的旧ZIP仍为旧纹理，需另行导出才能测试新压缩。画质是否接受由用户实际窗口试玩确认；自动检查只验证源图未改、纹理可解码、尺寸及透明分类、两种语言池路径一致，不把这些当作“肉眼无损”结论。

### 四季街景夜间差分（2026-10-11，接续四季差分）

- 触发边界已按用户要求收紧：八张四季昼夜街景仅在同行会话 `phase=result` 且 `outcome=completed`（邀请且同事接受）后显示。邀请页面、同事婉拒、选择各自回家均保留医院大厅/医院夜景；不修改接受率、奖励或剧情原文。
- 经用户授权，用内置imagegen分别编辑四季原图，新增星空、原有街灯及少量窗灯亮起的四张夜景，保留街道构图与各季节特征。成品均1672×941，已目视检查并原样复制至 `assets/backgrounds/after_work_v1/street_{spring,summer,autumn,winter}_night.png`。
- 注册 `after_work_street_{season}_night`；沿用既有月份及夜间触发规则，中英共用。白天的四张图原样保留。夜景实图仅保留0.12 UI遮罩，不再叠加旧版模拟夜色的0.24遮罩。
- 来源文件、完整提示词和目标路径见 `research/imports/after_work_street_nights_2026-10-11.json`。这项更新替代下文历史记录中的“夜间暂无专图”状态。

### 下班街景四季差分（2026-10-11，接续占位图）

- 用户调整确认：原始绿荫街景作为夏季图；新增同一构图的樱花春季、秋叶秋季、薄雪冬季。使用内置imagegen编辑原图，仅改变季节植被与环境细节；三张成品原样复制，均为1672×941。建筑、道路、车站和视角经目视核对保持一致。
- `after_work_street_spring` → `assets/backgrounds/after_work_v1/street_spring.png`；`after_work_street_summer` → 原图 `street_placeholder.png`；`after_work_street_autumn` → `street_autumn.png`；`after_work_street_winter` → `street_winter.png`（均在同目录）。额外生成的夏季候选未接入。
- 月份严格采用春3/4/5、夏6/7/8、秋9/10/11、冬12/1/2，以同行会话离院日期选图，不读取预留次日日期。中英共用同一映射。
- 查找顺序：季节+昼夜专图 → 季节基础图 → 通用昼夜图 → 原占位图。当前没有独立夜景，深夜使用对应季节图及既有遮罩；未来注册 `after_work_street_{season}_night` 即可覆盖。
- 完整提示词、来源及文件清单：`research/imports/after_work_street_seasons_2026-10-11.json`。专项测试：`tools/after_work_seasons_test.gd`，遍历全年365天、中英及普通/深夜分支，并检查每月实际背景纹理。

### 下班同行街景占位（2026-10-11）

- 用户授权使用内置 imagegen 生成一张室外街景，替换下班同行页面误用的医院大厅。成品 `assets/backgrounds/after_work_v1/street_placeholder.png`，1672×941，无人物、无界面文字，原样复制；ID 为 `after_work_street_placeholder`。
- 构图与成品已目视检查；中英运行时测试确认实际加载街景纹理。当前昼夜共用一张傍晚占位图，夜间沿用遮罩，不将其标为完整夜景素材。
- 季节/时段选图约定、来源和完整提示词见 `research/imports/after_work_street_2026-10-11.txt`。后续只需按约定在 `data/backgrounds.json` 注册素材；不需要重写同行事件对白。

### 蒂法·洛克哈特（patient_tifa，病房服装修复，2026-10-10）

- 全量检查当前 14 名患者的 6 个 `ward/*` 表情资源；蒂法是唯一仍引用常服的角色。新增浅蓝病号服六态至 `assets/characters/patient_tifa_v1/patient_tifa/ward_gown/`，并仅切换 `ward/*` 映射，原常服资源保留。

### 槇村香（patient_makimura_kaori，2026-10-10）

- 用户患者包原样存档于 `research/character_references/patient_makimura_kaori/user_bundle_v1.json`；4 张种子图在同目录，用户提供的裸体诊察立绘逐字节复制至 `assets/examinations/patient_makimura_kaori/full_undress.png`，作为 `examination/shy`，未纳入 CG 池。

### 野上冴子 CG（patient_nogami_saeko，2026-10-10）

- 按用户指定节点导入六张附件：诊室全裸查体 `assets/examinations/patient_nogami_saeko/full_undress_basic_exam.png`；病房备皮/剃毛、术野消毒、留置导尿、铺设无菌单、下刀分别保存至 `assets/events/ward_preparation_v1/patient_nogami_saeko/{skin_prep,skin_disinfection,urinary_catheterization,sterile_draping,incision}.png`。
- 六张均为 1584×1056，按附件原样复制；池与节点映射见 `data/patients/patient_nogami_saeko/patient.json`。诊室 CG 由 `encounter.full_undress.visual_pool_id` 指向；术前图均为患者专属全屏池。
- SHA-256：查体 `f0a7636241b12eb4a7f682c400273a81094a6a1ea2cf3e0a1eb8154dd56edd26`；剃毛 `11dacd77e5c6915234428dfc0cdd4b1a61cd9686530ba41470f425d753895b5b`；消毒 `55ac00339f09e37435cece215e53f1dbae7d02ab6d9f29133f3aaa32b63f7e1f`；导尿 `f3212fd3692c1b7470efb4b58dd0c75c06aea71cd1b107bf0008773a0382cce3`；铺巾 `530c693ff54daa6550003c429591f0cdc94b14e9580703df593531a457474368`；下刀 `099b5a8899956aa076571849d6259c3a30bee4db8724480f053f0f9cb342a683`。
- 导入 21 个立绘键：20 张标准 SFW（门诊 1、病房 6、仰卧手术台 4、截石位手术台 4、术中头像 4、全麻 splash 1）和用户提供的诊察立绘 1 张。病房穿浅蓝病号服；手术台铺不透明青绿色手术巾；术中头像透明、限头肩；麻醉头像闭眼。术中图统一为 1448×1086 RGBA，边界通过透明留白适配，不裁掉角色内容。

### 槇村香 CG（patient_makimura_kaori，2026-10-10）

- 后续补入 6 张用户指定 CG，分别接入诊室全裸查体、灌肠、戴手术帽、下刀、留置导尿和妇科截石位；“上推车”附件未指定导入，因此未登记。原图均为 1584×1056 RGB，原样复制；妇科截石位池限定 `female_pelvic`，下刀池连接清醒麻醉分支。来源、哈希、池 ID 与节点映射见 `research/imports/patient_makimura_kaori_cg_2026-10-10.json`。

用户明确选择 VNDB 原作图片作为本地占位。没有获得再分发授权；此记录不是授权声明，AI 重绘也不把原角色变为原创角色。正式发布前需替换或取得相应许可。

2026-09-30 导入用户提供的成年伊吹摩耶设定图与访问研究医设计文档。使用内置 ImageGen 制作三张 1024×1536 RGBA 半身透明立绘：白大褂研究装、刷手服设备支持装和系带口罩的完整无菌装，保存于 `assets/characters/portrait_pack_v20/visiting_maya/`。角色以中期访问研究医身份接入，关系仅限 Lv3 专业友谊，不加入恋爱、成人活动或常驻核心医护计数；来源和哈希见 `research/imports/visiting_maya_2026-09-30.json`。

2026-09-30 根据用户后续确认，伊吹摩耶的关系状态调整为与佐仓双叶一致：当前只建立相识与专业合作，保持 Lv0，不触发任何 Lv1 以上关系增进；未来若追加路线再显式解除锁定。

2026-09-30 导入用户提供的成年佐仓双叶设定图与访问医师科学家设计文档。使用内置 ImageGen 制作三张 1024×1536 RGBA 半身透明立绘：白大褂研究装、刷手服和系带口罩的完整无菌装，保存于 `assets/characters/portrait_pack_v21/visiting_futaba/`。她在摩耶《波形不对》事件后登场，负责心身相互作用、创伤、恐惧与疼痛预期研究；当前只开放相识、日常研究对白与助手协作，不设置Lv1以上关系、恋爱或成人路线。来源和哈希见 `research/imports/visiting_futaba_2026-09-30.json`。

| 游戏显示名（游戏年龄） | VNDB 原角色（来源年龄） | 来源 | 当前用途 |
|---|---|---|---|
| 神宮寺成美（27） | 神宮寺成美（32） | https://vndb.org/c1058 | 外科医生 |
| 深山佳織（28） | 深山佳織（未公布） | https://vndb.org/c28680 | 急诊医生 |
| 七瀬恋（26） | 七瀬恋（22） | https://vndb.org/c1053 | 护士 |
| 中井美佳（26） | 中井美佳（25） | https://vndb.org/c34368 | 护士 |
| 朝倉美幸（24） | 朝倉美幸（24） | https://vndb.org/c53130 | 护士 |
| 飯村真奈美（25） | 飯村真奈美（未公布） | https://vndb.org/c28679 | 药剂师 |
| 音羽響子（22） | 音羽響子（22） | https://vndb.org/c34369 | 患者 |
| 二ノ宮紗智子（25） | 二ノ宮紗智子（20） | https://vndb.org/c34366 | 患者 |
| 高卷杏（21） | 高卷杏（用户指定成年版本） | 用户提供图一、图二 | 患者 |
| 奥寺美纪（24） | 奥寺美纪（用户指定成年版本） | 用户提供图一至图四 | 患者 |

游戏显示名现与素材来源角色同名，内部 ID 维持不变。职业、游戏年龄、性格和剧情仍是本项目的改编设定，不代表原作人物设定。高卷杏采用用户明确指定的 21 岁成年版本，奥寺美纪采用用户明确指定的 24 岁成年版本；素材细节分别见 `docs/patient_ann_asset_record.md` 与 `docs/patient_miki_asset_record.md`。

候选素材通过官方 Kana API 按 Medical Doctor / Nurse 与女性、年龄 ≥20 查询。神宮寺成美、七瀬恋的完整来源 URL、作品 ID、原图哈希、派生文件和尺寸见 research/vndb/portrait_sources.json；其余五人的候选记录见 research/vndb/candidates_v1.json 与 research/vndb/portrait_pack_v2.json。

本次使用内置 image_gen 编辑，未使用 API Key 或 CLI。提示词见 art_prompts.md。生成图是 AI 补绘，不是原作官方高清版；已检查人物、着装与表情。透明边缘仍有少量白边和噪点，适合先看效果，后续需要精修。

2026-09-22 使用同一内置 imagegen 工作流生成两张16:9事件CG：`assets/events/cg/cg_aoi_cold_tea.png` 与 `assets/events/cg/cg_haru_half_sandwich.png`。两图分别使用神宮寺成美和七瀬恋现有本地占位立绘作为身份与服装参考，不改变其来源和授权状态。

2026-09-22 生成 `assets/characters/sterile_pack_v1` 无菌服立绘包。每张图使用对应角色已有刷手服差分作为人物参考，并使用用户提供的无菌袍修改图作为服装参考；来源与授权状态继续沿用上表，没有产生新的第三方来源。详情见 `docs/sterile_portrait_pack_v1.md`。

2026-09-24 使用内置 imagegen 生成6张通用术中团队背景：`assets/backgrounds/v6/operating_team_01.png` 至 `operating_team_06.png`。素材没有引用第三方图片；画面均为年轻成年女性手术团队、完全铺单的患者与无可读文字的通用手术室，不对应项目中的特定角色。

2026-09-24 使用内置 imagegen 为四名成年患者制作 `assets/characters/intraoperative_portraits_v1` 术中头肩立绘。每名患者各有 `tense`、`pain`、`anesthetized` 三种状态，使用其现有俯视手术台素材作为身份参考；最终版本移除无菌单，画面在锁骨下方结束并保留透明背景。人物来源与授权状态继续沿用上表。

2026-09-24 导入用户提供的24张心脏手术CG，保存为 `assets/surgeries/generic_v1/cardiac/progress_02.png` 至 `progress_25.png`。这些本地素材与原有 `progress_01.png` 共同组成心脏搭桥术的25张进行中CG池；本项目未对用户提供的原图做内容修改。

2026-09-24 导入用户提供的31张开腹手术 CG，保存为 `assets/surgeries/generic_v1/abdominal/progress_01.png` 至 `progress_31.png`。这些本地素材组成腹部手术进行中通用池，覆盖消化系统、腹壁、肾脏、腹膜后、膀胱和腹主动脉的开放术式；本项目仅按池内命名复制文件，没有修改原图内容。

2026-09-24 使用内置 imagegen 为四名成年患者制作全身麻醉诱导 splash CG，保存于 `assets/events/anesthesia_v1/<patient_id>/general.png`。每张图使用对应患者的病房立绘作为身份参考、手术台麻醉后素材作为构图参考；画面为闭眼、面罩覆盖口鼻、裸露肩膀和锁骨、胸部由无菌单完整遮盖的非色情临床场景。详情见 `docs/anesthesia_splash_pack_v1.md`。

## 查看方式
重新运行游戏，开始游戏后的第二段显示医生微笑、第三段显示护士。医院导览 → 门诊诊室 → 神宮寺成美，可切换平静 / 微笑；护士站 → 七瀬恋查看护士。

## 渲染约定
visuals.portraits 使用服装/表情作为键，对话节点可指定 expression，默认 neutral。加载路径为工程根相对路径；没有图时回退到几何剪影。当前图片在固定矩形内等比缩放；下一步精修可加每套素材的对齐锚点。

2026-09-24 基础查体羞涩立绘由用户提供四张灰底人物图；仅在本地移除与画布边缘连通的灰色背景并保留原人物像素，输出至 `assets/characters/examination_portraits_v1/`。对应患者为 `patient_sora`、`patient_emi`、`patient_ann`、`patient_miki`。

2026-09-25 导入用户提供的病房术前准备通用CG，保存于 `assets/events/ward_preparation_v1/`。当前使用灌肠、下腹及会阴备皮、戴手术帽各两张；原有两张换手术袍 CG 随该流程步骤一并移除。本项目仅按随机池命名复制文件，没有修改仍在使用的原图内容。

2026-09-25 导入用户提供的高卷杏病房灌肠专属CG，原样保存为 `assets/events/ward_preparation_v1/patient_ann/enema.png`（1280×800，SHA-256 `836441d3945d21ea43146f7df12842897e0f7343724a35845f02c2e26fdb6566`）。该图以患者专属全屏池覆盖高卷杏的灌肠动作，其他患者继续使用通用随机池。

2026-09-25 导入用户提供的奥寺美纪病房灌肠专属CG，原样保存为 `assets/events/ward_preparation_v1/patient_miki/enema.png`（1280×800，SHA-256 `5f7bfe0f9967c41f8988f969c1e036e42efd659bd604534762118ff51f3202b1`）。该图以患者专属全屏池覆盖奥寺美纪的灌肠动作，其他未配置专属图的患者继续使用通用随机池。

2026-09-27 导入用户提供的琪琪·安达露西亚病房灌肠专属CG，原样保存为 `assets/events/ward_preparation_v1/patient_gigi/enema.png`（1536×1024，SHA-256 `a153a07704980372a81d28b6eda76a77975bf954a67cf30c75153ea532df9e56`）。该图以患者专属全屏池覆盖琪琪的必要及多余灌肠动作，其他未配置专属图的患者继续使用通用随机池。

2026-09-27 导入用户提供的琪琪·安达露西亚透明背景全裸立绘，原样保存为 `assets/characters/patient_gigi_v1/patient_gigi/examination/shy.png`（458×688 RGBA，SHA-256 `922daf2ee8740fa38f8c5a6d363cde089a98d35ecc9587caf6aa9a5477611adb`）。该图替换原有占位图，并通过共用的 `examination/shy` 状态用于门诊完整脱衣检查及病房亲手术前准备期间。

2026-09-27 将柳原理惠的 `examination/shy.png` 从 917×688 横向透明画布裁去两侧留白，重采样为 1024×1536 RGBA 纵向立绘（SHA-256 `aa8ae26e26af05737cb21b04db08172b4f803b921e4dc10714390464a8405666`）。人物内容未重绘；调整后从头顶显示至大腿上部，并与琪琪的检查立绘采用接近的主体占画面比例。原始附件保留于 `research/character_references/patient_rie/05_examination_reference.png`。

2026-09-27 使用用户提供的三张 1024×1536 RGBA 透明纵向图更新琪琪·安达露西亚、音羽响子与二ノ宫纱智子的门诊／病房完全脱衣立绘。运行时分别接入三人的 `examination/shy`，原图未重绘或重采样；SHA-256 依次为 `2d7e5297bb3e2284a7264909f8aa58eca475a578080add2406e4510c3c31373d`、`4723f50f490a0dd67ba08fc32fa16e9a2613345826681ffe86468db97e003946`、`3c8e70b4e15136cf2012a58756d26bf5685c04709bcb607fb1ecb3ac952ddbdd`。来源副本及目标路径记录于 `research/imports/patient_examination_portraits_2026-09-27.json`。

2026-09-27 导入用户提供的二ノ宫纱智子诊查脱衣专属 CG，原样保存为 `assets/examinations/patient_emi/full_undress_basic_exam.png`（1536×1024 RGB，SHA-256 `f7d37fbdaedded478df1cc2a628fcadd41c49836ec8282992ecce7b38d8870d1`）。该图通过患者专属池 `full_undress_basic_exam_patient_emi` 用于基础查体中完成完全脱衣的三条分支；放弃脱衣不会触发。透明 `examination/shy` 仍用于病房准备及需要人物立绘的场景。来源记录见 `research/imports/patient_emi_examination_cg.json`。

2026-09-27 导入用户提供的二ノ宫纱智子术前备皮专属 CG，原样保存为 `assets/events/ward_preparation_v1/patient_emi/skin_prep.png`（1536×1024 RGB，SHA-256 `9207a53f31b4a9bdfd6b17506ddf85c4602bd6506e15cf84814da7b01c0f6abd`）。该图通过患者专属池 `ward_skin_prep_patient_emi` 覆盖纱智子的必要备皮和玩家额外选择的非必要备皮行动，均以全屏方式显示；其他患者继续使用其专属池或通用池。来源记录见 `research/imports/patient_emi_ward_skin_prep_cg.json`。

2026-09-27 导入用户提供的二ノ宫纱智子术前灌肠专属 CG，原样保存为 `assets/events/ward_preparation_v1/patient_emi/enema.png`（1536×1024 RGB，SHA-256 `2d99fb3985281cd13f6094fd4a0b1677b5fceedb6ea441045062dd6f0a35152f`）。该图通过患者专属池 `ward_enema_patient_emi` 覆盖纱智子的必要灌肠和玩家额外选择的非必要灌肠行动，均以全屏方式显示；其他患者继续使用各自专属池或通用池。来源记录见 `research/imports/patient_emi_ward_enema_cg.json`。

2026-09-27 导入用户提供的二ノ宫纱智子硬膜外麻醉专属 CG，原样保存为 `assets/events/anesthesia_v1/patient_emi/epidural.png`（1536×1024 RGB，SHA-256 `d78828cb5ed78764caf9bb2410a7f6374d81696fba2624beff2fe62476013f9b`）。素材登记为 `splash/epidural_anesthesia`，仅在纱智子选择硬膜外麻醉后全屏显示；关闭后继续体位摆放。来源记录见 `research/imports/patient_emi_epidural_anesthesia_cg.json`。

2026-09-27 导入用户提供的二ノ宫纱智子手术刀准备下刀专属 CG，原样保存为 `assets/events/ward_preparation_v1/patient_emi/scalpel_ready.png`（1920×1080 RGB，SHA-256 `b6ee7dc33cde7beaea7faf8a5e9215c431dc4aba67120f9292b3dedb50c7ed41`）。处理方式与高卷杏相同，绑定 `request_scalpel`：主刀接过器械护士递来的手术刀后全屏显示，继续后进入助手固定切入部位和正式下刀；全身麻醉状态下继续隐藏清醒患者专属画面。来源记录见 `research/imports/patient_emi_scalpel_ready_cg.json`。

2026-09-27 导入用户提供的音羽響子手术刀准备下刀专属 CG，原样保存为 `assets/events/ward_preparation_v1/patient_sora/scalpel_ready.png`（1920×1080 RGB，SHA-256 `0b7c82a3939d5009964eea1a4598882684c2430d2d70e9f71a92d8431057c9a7`）。该图同样绑定 `request_scalpel`，在响子保持清醒的硬膜外、局麻或无麻醉路线中于接刀后全屏显示，继续后进入助手固定切入部位和正式下刀；全麻路线不显示。来源记录见 `research/imports/patient_sora_scalpel_ready_cg.json`。

2026-09-27 导入用户提供的奥寺美纪手术刀准备下刀专属 CG，原样保存为 `assets/events/ward_preparation_v1/patient_miki/scalpel_ready.png`（1920×1080 RGB，SHA-256 `b142e55c2eeb1d73a2f4bde4394242a235c8ddc884fb63188b24548356752ed5`）。该图绑定 `request_scalpel`，在美纪保持清醒的硬膜外、局麻或无麻醉路线中于接刀后全屏显示，继续后进入助手固定切入部位和正式下刀；全麻路线不显示。来源记录见 `research/imports/patient_miki_scalpel_ready_cg.json`。

2026-09-27 导入用户提供的二ノ宮紗智子铺设无菌单专属 CG，原样保存为 `assets/events/ward_preparation_v1/patient_emi/sterile_draping.png`（1536×1024 RGB，SHA-256 `145e4daefc2d80d6a4bce755cc6e8ca7f234ca1b59f55a2dc5e8789e27b6182d`）。该图绑定消毒回应后的 `ack_disinfection`，仅用于 `general_abdominal`、`female_pelvic` 与 `vascular` 三类腹部开放术式，并且只在患者保持清醒的硬膜外、局麻或无麻醉路线显示；继续后直接进入切口划线。来源记录见 `research/imports/patient_emi_sterile_draping_cg.json`。

2026-09-25 导入用户提供的高卷杏手术室术野消毒专属CG，原样保存为 `assets/events/ward_preparation_v1/patient_ann/skin_disinfection.png`（1280×800，SHA-256 `76aefd28c1f47f122116352a9c762e8d74c4ce5e73ec3344ef52055160dcb347`）。该图在高卷杏成功执行 `skin_disinfection` 动作后以全屏形式显示；其他患者不触发该专属图。

2026-09-25 导入用户提供的高卷杏手术刀准备下刀专属CG，原样保存为 `assets/events/ward_preparation_v1/patient_ann/scalpel_ready.png`（1280×800，SHA-256 `3802c00a4f8917c7005adaafcef7ee719d34dc79ca32be3689a4918fb56dd1cb`）。该图绑定 `request_scalpel`：主刀接过器械护士递来的手术刀后全屏显示，继续后进入助手固定切入部位与正式下刀。

2026-09-25 导入用户提供的奥寺美纪留置导尿专属CG，原样保存为 `assets/events/ward_preparation_v1/patient_miki/urinary_catheterization.png`（1280×800，SHA-256 `8acae8fb5948e1c5b677b0c5187685f58d301da332c2d1231b48a54a31ac6992`）。该图在奥寺美纪成功执行 `urinary_catheterization` 动作后以全屏形式显示；继续后进入导尿后的回应和术野消毒。

2026-09-25 导入用户提供的奥寺美纪基础查体脱衣专属CG，原样保存为 `assets/examinations/patient_miki/full_undress_basic_exam.png`（1280×800，SHA-256 `a2999fbd8956ba640d8fae07180bc9e02ce7d14ae295e548d249216c0be239d7`）。该图用于奥寺美纪基础查体中“权威说服”“温柔说服”和“威胁”三条完成脱衣的分支；放弃脱衣不触发。

2026-09-25 导入用户提供的21张盆腔手术CG，保存为 `assets/surgeries/generic_v1/pelvic/progress_01.png` 至 `progress_21.png`。素材组成盆腔手术进行中通用池，覆盖子宫切除、腹会阴联合直肠切除、开腹卵巢囊肿切除和开腹子宫肌瘤剔除；本项目仅按池内命名复制文件，没有修改原图内容。

2026-09-25 使用内置 ImageGen 将饭村真奈美的药剂师服、刷手服和无菌手术服立绘统一重构为 1024×1536 透明背景的腰部／髋部构图。两套手术服同时修正手术帽戴法：长发完全收进帽内，仅保留少量额前短碎发。文件继续原位保存于 `assets/characters/portrait_pack_v10/pharmacist_manami/`；生成提示与哈希记录见 `research/vndb/pharmacist_manami.json`。

2026-09-25 使用内置 ImageGen 为饭村真奈美增加 `pharmacist/worried` 与 `sterile/worried` 两张紧张差分，保持 1024×1536 透明背景和腰部／髋部构图。白衣差分用于被临时点入手术团队时的慌乱反应；无菌服差分用于助手确认、术中操作、求助与纠正场景。提示与哈希记录继续写入 `research/vndb/pharmacist_manami.json`。

2026-09-26 导入用户提供的利根川安琪立绘表，从上方两行原样裁切六张白色护士服差分，保存于 `assets/characters/portrait_pack_v11/nurse_ange/uniform/`。使用内置 ImageGen 以该人物为身份参考生成四张透明背景无菌手术服差分：长袖圆领无菌手术袍、口罩、长发收入手术帽，仅保留少量金色刘海和贴耳短发鬓，保存于同角色目录的 `sterile/`。第 2 天护士站相识事件完成后，她会常驻手术室并开放团队邀请；完成相识前，排班信息不会令她以匿名角色提前出现。完整提示、画布和哈希见 `research/imports/nurse_ange.json`。

2026-09-26 导入用户提供的杉村弘子六张原作立绘：五张护士服表情与一张粉色便服。素材以边缘连通黑底移除、主体裁切和统一构图方式转为 1024×1536 透明 PNG，保存于 `assets/characters/portrait_pack_v12/nurse_hiroko/`。使用内置 ImageGen 以原作中性护士服图为身份参考，生成 neutral、focused、warm、worried 四张长袖圆领无菌手术服差分；长蓝发完整收入手术帽，仅保留短刘海和少量鬓发。第 2 天手术室前置事件及后续护士站相识完成后，她会在病房与门诊活动并可加入手术团队。完整提示、来源哈希和输出哈希见 `research/imports/nurse_hiroko.json`。

2026-09-26 导入用户提供的仓本千早登场事件素材。`chihaya_escape_corridor.png`（1280×720）作为全屏走廊追逃 CG；后来补充的 `chihaya_shy.png` 与 `chihaya_restrained_portrait.png`（均为 1024×1536 RGBA）作为透明人物立绘，分别用于撞上坂口后的羞涩状态和被两名护士抓住的状态。先前两张不透明近景已移入同目录 `sources/`，仅保留来源历史，不再被运行时引用。她在 `data/patients/cameo_patients.json` 登记为仓本千早，但事件中只显示“女患者”，姓名留待未来专属事件解锁。哈希与用途记录见 `research/imports/hiroko_debut_event.json`。

2026-09-26 导入用户提供的六张透明背景手术室患者状态立绘，按附件顺序对应杉村弘子、朝倉美幸、深山佳織、飯村真奈美、神宮寺成美与七瀬恋。原图均为 1024×1536 RGBA，原样保存于 `assets/characters/relationship_patient_v1/<staff_id>/operating_patient/nervous.png`，并登记为人物的 `operating_patient/nervous` 差分。素材暂不进入当前界面；未来用于 Lv4 恋人关系的手术室患者扮演成人事件，并可在 Lv5 临床手术练习流程复用。来源文件、透明度和哈希见 `research/imports/relationship_patient_portraits_v1.json`。

2026-09-26 导入用户提供的本庄萌惠立绘与相识脚本。十张 320×480 护士服 JPEG 表情差分经边缘连通黑底移除后，统一转为 1024×1536 RGBA；换衣室与刷手服立绘保留用户提供的透明图。换衣室裸体立绘同时登记为未来 Lv4 手术室患者 play 的 `operating_patient/nervous`，当前仍只是占位，不开放玩法入口。相识事件不再由普通进入手术室触发，而是开始一次真实术前流程、在“前往更衣区”后进入 `changing` 阶段时自动触发；结束后返回原术前流程继续换衣。事件专用副本位于 `assets/events/character_events/moe/`，保证运行时按立绘而非 splash CG 显示。来源与用途见 `research/imports/nurse_moe.json`。

2026-09-26 导入用户提供的御堂江美子原作参考图，并据此制作 `portrait_pack_v14/doc_emiko` 高清透明立绘。白大褂包含冷静、自信微笑、严厉、惊讶、动摇与温柔六种表情；另制作刷手服及长袖无菌手术袍／口罩版本，供普通场景和手术团队显示。原始参考图保存在该角色的 `sources/` 目录，映射与设计说明见 `research/imports/doc_emiko.json`。

2026-09-26 追加用户提供的御堂江美子透明背景手术患者 play 立绘，原图为 1024×1536 RGBA，登记为 `operating_patient/nervous`。该素材已加入未来 Lv4 手术室患者扮演与 Lv5 临床手术练习的立绘就绪名单；两项玩法仍为未开放占位。

2026-09-27 新增“御堂外科医长办公室”地点，当前复用既有 `assets/backgrounds/v3/surgery_director_office.png` 办公室背景。地点与空置的“外科主任办公室”分别登记，以便御堂个人事件和未来科室管理内容独立触发。

2026-09-27 使用内置 ImageGen 生成首批四张 SFW 助手医岗位确认奖励 CG：神宮寺成美、深山佳織、御堂江美子与飯村真奈美。图片统一为 1672×941 RGB 横构图，保存于 `assets/events/staff_surgery_v1/<staff_id>/assistant_confirmation.png`。前三张分别突出温和教学、果断行动和外科医长的权威感；飯村采用保持美型的紧张慌乱轻喜剧构图。现已接入首次助手任职解锁、一次性展示和事件鉴赏。完整参考图、提示方向、哈希和运行时约定见 `research/imports/assistant_surgeon_confirmation_cgs_2026-09-27.json`。

2026-09-27 使用内置 ImageGen 为七瀬恋、中井美佳、朝倉美幸、利根川安琪、杉村弘子与本庄萌惠生成 18 张 SFW 护士岗位确认奖励 CG。每人各有器械护士、巡回护士和病房术前介护三张，统一保存于 `assets/events/staff_surgery_v1/<staff_id>/`；术前介护构图全部使用空病床与准备物品，患者不入镜。所有图片已接入首次任职解锁、一次性展示和事件鉴赏。完整提示摘要、生成引用、尺寸与哈希见 `research/imports/nurse_role_confirmation_cgs_2026-09-27.json`。

2026-09-27 确立后续事件 CG 分工：SFW 角色 CG、岗位确认与医疗流程 splash 优先使用内置 ImageGen，以统一角色美型、色彩和手术室视觉语言；NSFW 图片由用户提供，项目负责裁切规格、命名、来源记录、条件触发与事件鉴赏接入。

2026-09-28 导入用户提供的城宮明日香五张原作服装／表情差分与一张 1024×1536 RGBA 手术患者装扮立绘。使用内置 ImageGen 将白大褂、深红院长套装与粉色便服差分统一为 1024×1536 透明 VN 立绘，并按同一身份补绘刷手服和无菌手术服版本，保存于 `assets/characters/portrait_pack_v15/doc_asuka/`；无菌手术服版本随后按外科着装规则修正，将长发、鬓发与后颈头发全部收入手术帽内，仅保留少量短碎刘海用于辨识。用户提供的透明患者装扮原样保存为 `assets/characters/relationship_patient_v1/doc_asuka/operating_patient/nervous.png`，仅登记供未来 Lv4/Lv5 内容使用。原始差分、生成方法与用途见 `research/imports/doc_asuka_2026-09-28.json`。

2026-09-28 导入用户提供的四张柳原理惠专属 CG，均以原始 1536×1024 RGB 保存：术前备皮 `assets/events/ward_preparation_v1/patient_rie/skin_prep.png`、清醒下刀前 `scalpel_ready.png`、腹部／盆腔／血管术式消毒后的铺巾 `sterile_draping.png`，以及诊室完整脱衣查体 `assets/examinations/patient_rie/full_undress_basic_exam.png`。下刀与铺巾图沿用现有术前系统的清醒患者显示规则，全麻后不显示；铺巾图只匹配 `general_abdominal`、`female_pelvic` 与 `vascular`。来源、哈希和触发点见 `research/imports/patient_rie_cg_pack_2026-09-28.json`。

2026-10-10 导入岩井善美完整患者数据并登记于患者索引。源 bundle 原文保存在 `research/character_references/patient_iwai_yoshimi/patient_bundle_v1.json`，运行时副本为 `data/patients/patient_iwai_yoshimi/patient.json`；保留用户提供的全裸查体立绘原始像素并映射至 `examination/shy`，三个种子图及用户补充的三张原画参考均归档于角色参考目录。依原画重新生成并注册 20 个标准立绘键，英文对白映射完整。源字段 `stress_response: embarrassed_apologetic` 原先不在项目枚举内；为保留源值，已增加对应 schema 枚举和中英显示映射，没有将它改写成其他性格值。收到画风反馈后，手术台与术中头像各状态均按蝴蝶忍对应资产作画风／构图参考重新生成并更新映射；全麻图按要求露出双肩。截石位四态现均为带腿托的实际姿势，胸腹及骨盆由铺巾覆盖；awake 基图为生成图，tense、afraid、anesthetized 三张差分由用户于 2026-10-11 补充并原样导入，原件归档在 `research/character_references/patient_iwai_yoshimi/`。源 bundle 的 exclusive CG pools、diagnosis reactions 和全裸事件 visual_pool_id 为空，按原样保留，未自行补写 CG／事件数据。校验结果及全部来源信息见该导入记录。

2026-10-11 用户补充岩井善美五张专属 CG：诊室全裸检查、术前剃毛、术前体位固定、术前导尿和清醒下刀。图片原样归档至 `research/character_references/patient_iwai_yoshimi/cgs/`，分别绑定检查 `visual_pool_id` 及术前动作池；所有 CG 池的标签和说明均加入英文映射。下刀图绑定硬膜外、局麻及无麻醉下刀动作（图中患者清醒）；运行时触发使用语言无关的动作 ID。导入审计与哈希见 `research/imports/patient_iwai_yoshimi_cg_2026-10-11.json`。

2026-09-28 追加用户提供的柳原理惠留置导尿专属 CG，原样保存为 `assets/events/ward_preparation_v1/patient_rie/urinary_catheterization.png`（1536×960 RGB，16:10，SHA-256 `57f2937e9f3a4fd752c222cb197bd8ca7cdffd14c81f811012ed9e1a8d7d6cce`）。该图绑定手术室准备中的 `urinary_catheterization`，以全屏形式显示；其比例与游戏1280×800逻辑画布完全一致，无需裁切。来源记录合并于 `research/imports/patient_rie_cg_pack_2026-09-28.json`。

2026-09-28 追加用户提供的柳原理惠术野消毒专属 CG，原样保存为 `assets/events/ward_preparation_v1/patient_rie/skin_disinfection.png`（1536×960 RGB，16:10，SHA-256 `b0fe68ae44fdc40e8951026bf14f4e2be578122606bc072db8108fb5519e9f4a`）。该图绑定实际执行 `skin_disinfection` 的清醒患者路线并以全屏方式显示；全身麻醉路线继续隐藏导尿、消毒和下刀患者 CG。原始附件副本与触发记录已合并至 `research/imports/patient_rie_cg_pack_2026-09-28.json`。

2026-09-28 使用内置 ImageGen 生成独立的手术室刷手区背景，保存为 `assets/backgrounds/v7/scrub_area.png`（1536×960 RGB，16:10，SHA-256 `97c594e7f14b4fd5f102a0175799b8120f7eed6686f0dc2ad29d6f0e62047a48`）。画面采用明亮现代手术部环境，包含三组自动感应水龙头、长条不锈钢刷手槽、消毒液、计时钟及手术间入口，不包含更衣柜或更衣长椅。该背景登记为 `scrub_area`，现用于城宮明日香的 `asuka_scrub_sink_encounter`；本庄萌惠的更衣室事件仍使用 `changing`。完整提示、源图和处理记录见 `research/backgrounds/scrub_area_v1.json`。

2026-09-28 使用内置 ImageGen 为城宮明日香第二天的院长室身份揭晓事件制作全屏 CG，保存为 `assets/events/character_events/asuka/director_office_reveal.png`（1536×960 RGB，16:10，SHA-256 `0b3bdd1e6a0ded5aed4263e9aac352b3139f941a06ccf254e5176a5c48713bfa`）。画面以宽大的深色办公桌、高背座椅和对称的行政空间突出院长权力感，并以明日香年轻娇小的体型形成反差。该图用于 `intro_doc_asuka_director_office` 开场、首次完成后的全屏奖励及事件鉴赏。角色与办公室参考、生成摘要和源图记录见 `research/imports/asuka_director_office_reveal_cg_2026-09-28.json`。

2026-09-28 按角色既有服装设定修正城宮明日香院长室 CG：移除深红院长套装，改为与 `white_coat/neutral` 一致的白大褂、粉色衬衫、黑色领结和绿色胸针。事件 `intro_doc_asuka_director_office` 的普通对白立绘与开场文字也同步改为白大褂，院长身份继续由宽大办公桌、高背座椅与行政空间体现。最终运行时文件哈希更新为 `ade2fdeaea018fe9c216d88e4e48595673f237994a74abbff5f2410b43c28dc0`。

2026-09-28 导入用户提供的“手术室更衣室拿起刷手服”视频。原始 6.04 秒 MP4 保存于 `research/videos/preop/change_scrubs_take_gown_v1_source.mp4`；按用户指定截取第 2.000–4.000 秒，移除音轨后编码为 752×416、24 fps、Theora/yuv420p 的 `assets/animations/preop/change_scrubs_take_gown_v1.ogv`。该视频绑定 `change_scrubs`，以2倍速在小屏播放，实际约1秒后自动继续。来源哈希、裁切与编码参数见 `research/imports/preop_change_scrubs_video_2026-09-28.json`。

2026-09-28 用户随后提供自行裁好的2.25秒版本，现已替换“更换手术服”正式来源；不再对6秒原片二次截取。新MP4哈希为 `50d9e994a0ae3e9f91e42d08a538c52cd457259a2b440faf32f3f5d8f3ad8738`，静音OGV哈希为 `52881081882da9e5c8310d0563120ab597d3fd386be653d84a9f2cce9fdb985b`；2倍速实际播放约1.125秒。

2026-09-28 导入用户提供的刷手动画。原始6.04秒MP4保存于 `research/videos/preop/scrub_hands_v1_source.mp4`；选取自动水龙头持续出水、刷子清洗手背与前臂最清楚的第2.000–4.000秒，移除音轨后编码为752×416、24fps、Theora/yuv420p的 `assets/animations/preop/scrub_hands_v1.ogv`。该视频绑定 `scrub_hands`，2倍速小屏播放，实际约1秒后自动继续；随后出现的刷手池人物事件仍按原顺序触发。完整参数见 `research/imports/preop_scrub_hands_video_2026-09-28.json`。

2026-09-28 导入用户提供的手术室入室准备动画。原始2.38秒MP4保存于 `research/videos/preop/enter_operating_room_v1_source.mp4`；移除音轨后编码为752×416、24fps、Theora/yuv420p的 `assets/animations/preop/enter_operating_room_v1.ogv`。该视频绑定术前流程最后一步 `enter_room`，以2倍速无边框小屏播放，实际约1.19秒后自动进入手术室确认阶段。完整参数见 `research/imports/preop_enter_operating_room_video_2026-09-28.json`。

2026-09-28 使用内置 ImageGen 为杉村弘子 Lv1 关系事件生成两张 1536×1024 SFW 解锁 CG。`assets/events/character_events/hiroko/lv1_instrument_lesson.png` 用于“别让她看见”结尾，表现弘子在患者稳定后指导本庄萌惠将器械台移出患者视线；`assets/events/character_events/hiroko/lv1_worth_it.png` 用于“值得的事情”结尾，以护士站、交班记录、凉咖啡和玩家递来的热饮呈现 Lv1 升级。两张图均在对应事件首次完成后展示，并永久进入事件鉴赏。参考图、提示摘要与哈希见 `research/imports/hiroko_lv1_event_cgs_2026-09-28.json`。

2026-09-28 使用内置 ImageGen 生成主角办公室开局背景，中央裁切为 `assets/backgrounds/v8/player_office.png`（1536×960 RGB，16:10，SHA-256 `dd40988bb10b1737fd8983c7e17a442aadca877e549a4538826f33eb18f36c1a`）。画面包含医院配发电脑、普通杯子、空白文件架、访客椅和医院窗景，并在桌面、书架与墙面保留未来感谢卡、纪念物、合影和证书的位置；当前不含私人装饰，用于表现一年合同初期的临时感。生成源图与提示摘要见 `research/backgrounds/player_office_v1.json`。

2026-09-28 导入用户提供的阿尔托莉雅·潘德拉贡角色设计文档与八张原作外观参考。使用内置 ImageGen 统一制作白大褂、经典私服、刷手服和无菌手术服版本；依用户确认，正式运行时文件全部裁为 1024×1536 透明头顶至髋部／大腿上缘半身立绘，全身生成图只保留为来源记录。刷手服与无菌服将辫子、侧发和呆毛完整收入手术帽。另生成 1536×960 的 SFW 初见奖励 CG `assets/events/character_events/artoria/right_position.png`，用于外科主任办公室的三台手术人员重排场景。人物数据、初始关系与独立的外科副部长办公室已经接入；办公室初见只建立 Lv0，相识后《谁站在哪个位置》作为 Lv1 事件，完成后解锁常规手术团队资格及排程板 CG。Lv2—Lv5、佐伯大型手术、助手岗位奖励和患者路线保留为后续内容。完整来源、哈希与范围见 `research/imports/doc_artoria_2026-09-28.json`。

2026-09-28 按用户反馈调整阿尔托莉雅的关系节奏：新增 `artoria_office` 独立外科副部长办公室，暂复用现有外科办公室背景；新建《外科副部长的办公室》作为无技能门槛的 Lv0 正式相识。《谁站在哪个位置》保留完整的御堂冲突、三台手术人员重排、关键选择及奖励 CG，改为相识后可触发的 Lv1 关系事件；完成 Lv1 后才开放阿尔托莉雅的常规手术团队资格。空置的 `surgery_director_office` 继续留给未来主任竞选内容。

2026-09-28 根据实机截图缩短阿尔托莉雅地点显示名：地图与事件副标题统一使用“副部长办公室 / PENDRAGON OFFICE”，避免按钮溢出；完整职务仍保留在角色资料和办公室描述中。她的登场链改为严格前置：玩家必须先完成城宮明日香与御堂江美子的正式相识，随后在院长室触发明日香的《另一位主任候选》，由明日香明确说明阿尔托莉雅与御堂的主任竞争关系；完成这段介绍后，副部长办公室才开放阿尔托莉雅的 Lv0 相识事件。

2026-09-29 导入用户提供的藤崎詩織角色设定图，并使用内置 ImageGen 制作白大褂、日常服、刷手服和无菌手术服四套运行时半身立绘，保存于 `assets/characters/portrait_pack_v17/doc_shiori/`。四张图均为 1024×1536 RGBA 透明画布；无菌服版本将长发和发带完全收入手术帽。人物以综合内科专攻医身份加入，开局未认识；玩家完成至少 3 例手术后，才可在门诊触发《完整的患者》或在病房触发其替代相识入口；任一入口完成后另一个自动关闭；相识后开放 `limited` 助手位，不开放常规主刀。未定义的佐仓双叶与伊吹摩耶目前只保留在设计文档中，不建立运行时引用。完整设定、提示摘要、文件哈希和接入范围见 `docs/design/HOSHIMI_FUJISAKI_SHIORI_CHARACTER_V1.md` 与 `research/imports/doc_shiori_2026-09-29.json`。

2026-09-29 追加用户提供的柳原理惠全身麻醉诱导开始 CG，原样保存为 `assets/events/anesthesia_v1/patient_rie/general_pre_induction.png`（1536×1024 RGB，3:2）。该图通过 `splash/general_anesthesia_pre_induction` 仅绑定柳原理惠的 `choose_general`：选择全麻后先显示她睁眼接受面罩的诱导开始画面，关闭后进入安抚回应，随后继续显示既有闭眼的诱导完成 CG。其他患者与硬膜外、局麻、无麻醉路线不受影响。来源副本、哈希与播放顺序合并记录于 `research/imports/patient_rie_cg_pack_2026-09-28.json`。

2026-09-29 导入用户提供的南条小夜香角色圣经与六张设定参考，并使用内置 ImageGen 制作白大褂（平静／微笑）、常服、刷手服、完整无菌服（专注／温和）共六张 1024×1536 半身透明立绘，保存于 `assets/characters/portrait_pack_v19/doc_sayaka/`。她以综合诊疗／健康管理医师加入：序章第一天保证相识，相识后可担任普通助手，进入门诊、休息室和天台的日常互动，并完成周日约会档案与常服素材预接入；由于地点背景与基础地点对白尚未完成，`can_date` 暂时关闭；同时作为核心成员补入《新手术室启用日》，保留“主动志愿但必须先说明内容”的安全边界笑点。Lv1–Lv5、酒店教学、职员患者与公开教学手术目前只保留接口和标记，尚未写成事件。完整提示摘要、哈希和接入范围见 `research/imports/doc_sayaka_2026-09-29.json`。

2026-10-01 追加用户提供的南条小夜香手术患者紧张状态透明立绘。原始 960×1536 RGBA PNG 未经重绘或重采样，保存为 `assets/characters/relationship_patient_v1/doc_sayaka/operating_patient/nervous.png`，并加入未来 Lv4 手术室患者扮演与 Lv5 临床手术练习的立绘就绪名单。随后使用内置 ImageGen 按现有患者手术台画面制作 1536×1024 的近距离俯视铺巾差分；画面裁至下半身以外，避免全身俯视造成比例缩短，并提供镇定、紧张、羞涩、调笑、惊讶、开心和镇静生效七种状态。另按通用患者规范制作四张 1448×1086 RGBA 透明术中状态头像，保存于 `assets/characters/intraoperative_portraits_v1/doc_sayaka/`，包括紧张、疼痛、濒临崩溃和麻醉四种状态；画面仅含正面头肩、手术帽与锁骨，和手术台场景包相互独立。此外补齐三张透明术前患者服立绘、两帧全身麻醉诱导 CG、三张透明术后恢复立绘，并追加尴尬、调笑、开心三张个性化术中透明头像。麻醉画面保持面罩正确覆盖口鼻，胸部以下由不透明手术单遮盖。两项后期玩法仍未开放。来源副本、透明度、尺寸和哈希见 `research/imports/doc_sayaka_operating_patient_2026-10-01.json`。

2026-09-29 保存用户提供的片桐彩子成年角色设定稿，并使用内置 ImageGen 制作十二张 RGBA 透明差分，保存于 `assets/events/character_events/rei/ayako/`：常服平静／受惊、患者袍加手术帽的正常／疑惑／开心、仰卧手术台紧张／昏沉／镇定／开心／轻微嫌弃五种头像、术后病房患者服，以及第二次以后参观使用的护士服纪念版。患者袍状态明确属于患者而非医护刷手服；手术台头像只露肩部，胸部以下由手术单完整遮盖。彩子以 25 岁医院外部漫画家／插画家登记为剧情型长期 NPC，不可攻略、不可加入手术团队；作为深山佳織 Lv2《取材过头了》的核心当事人，事件保持“切开后发现健康器官并确认乌龙”的既定情节，并预留医院漫画、护士服纪念和庆祝返场。V8 完整对白现已接入单日特殊事件；测试阶段暂以深山、藤崎、明日香均已相识作为门槛。完整设定、提示摘要与哈希见 `docs/design/HOSHIMI_CHARACTER_PROFILE_KATAGIRI_AYAKO_V1.md` 和 `research/imports/guest_ayako_2026-09-29.json`。

2026-09-29 根据用户补充的深山佳織 Lv2 误认机制，使用片桐彩子患者袍参考制作真正预定手术患者的逃跑立绘 `assets/events/character_events/rei/ayako/lookalike_patient_fleeing.png`。该患者与彩子具有相近脸型和银紫发，但使用灰绿瞳、较窄眼形、不同鼻梁与下颌；她在术前情绪激昂逃出手术室并从彩子身边跑过，使不熟悉双方的医护把随后出现的彩子误认成追回的患者。素材为 1024×1536 RGBA 透明立绘；姓名和长期设定保持待定。记录见 `research/imports/ayako_lookalike_patient_2026-09-29.json`。

2026-09-30 导入 `HOSHIMI_MIYAMA_LV2_AYAKO_EVENT_DIALOGUE_DRAFT_V8.md`，将深山佳織 Lv2《取材过头了》接入整日特殊事件系统。运行时保留 34 个叙事阶段和 520 个顺序对白节点，09:00 自动触发且不可拒绝；当前测试门槛暂为深山佳織、藤崎詩織、城宮明日香均已相识，正式条件将在测试后恢复为深山 Lv1、藤崎 Lv1、明日香已相识。使用内置 ImageGen 制作五张 SFW 场景图：`cg_01_lucky.png`、`cg_02_patient_disguise.png`、`cg_03_or_table.png`、`cg_04_lesion_missing.png`、`cg_05_firsthand_notes.png`，并制作《真的下刀了》术前与浅表切开两帧医学近景差分 `cg_03a_first_incision_pre.png`、`cg_03b_first_incision_after.png`。CG 04 使用坂口第一助手的低机位视角，以无菌单完全遮挡患者和术野，只表现深山与七瀬恋发现病历不符时的焦急反应；七瀬恋的口罩按用户修正为与深山相同的后脑系带式。完整导入记录见 `research/imports/miyama_ayako_event_v8_2026-09-30.json`。
2026-10-01 导入深山佳織 canonical character bible、七张原作参考图及用户模型身份母版。后续 SFW、事件 CG 与成人素材均以模型母版的饱和兰紫／葡萄紫头发、酒红大眼、成年偏长鹅蛋脸、高位偏侧长马尾、尖锐分束刘海和红色细发带为最高优先级身份标准；原作粉发图降为服装、姿态和早期造型参考，不在剧情中解释为染发或形象变更。运行时白大褂素材已在随后更新中统一；用户确认既有 `operating_patient/nervous` 来自同一模型并可保留。完整记录见 `docs/design/HOSHIMI_MIYAMA_KAORI_CHARACTER_BIBLE.md` 与 `research/imports/miyama_kaori_character_bible_2026-10-01.json`。

2026-10-01 完成深山佳織紫发身份落地与 Lv1–Lv3 关系链。六张白大褂表情已改用 `portrait_pack_v20`；首次助手岗位 CG 以 `assistant_confirmation_v2.png` 修正帽缘发丝为深紫；用户提供的成年裸体立绘原样登记为 `adult_nude/guarded`，并复制事件专用版本。用户同时确认既有 `operating_patient/nervous` 来自同一模型，因此保留原图。Lv3 `or_god_surgery_rear.png` 只是可替换占位，正式“手术袍下不穿刷手服”CG等待用户提供。事件资料、生成资产、哈希及运行时路径见 `research/imports/miyama_lv1_lv3_and_identity_assets_2026-10-01.json`。

2026-10-03 导入用户提供的两张盆腔开放术野 CG，原样保存为 `assets/surgeries/overlays/pelvic/open_pelvic_field.png`（1528×936 PNG，SHA-256 `3b0fd44c9ec1c32de36f768695add754a112ce2174767b35f10d325a12abf984`）和 `open_pelvic_field_02.png`（1504×1136 PNG，SHA-256 `ee39c27659bf2c7f9928623b0385d8a190ab4f381a0db90e858db14afd41ce02`）。两图组成 `female_pelvic` 术野池：每台手术利用已经随机且可随存档重放的手术团队背景编号稳定选择一张，完成切皮后叠加在团队 CG 上，互动 UI 与人物立绘继续显示在其上；进入带 `closure` 标记的缝合步骤时移除。来源与触发记录见 `research/imports/pelvic_operative_field_overlay_2026-10-03.json`。

2026-10-03 导入用户提供的两张阑尾切除术术野 CG，原样保存为 `assets/surgeries/overlays/appendix/open_appendix_field_01.png`（1760×920 PNG，SHA-256 `2eba76a5804781e1255865f6933072c57011c196233bd7ce36e17d789866990e`）和 `open_appendix_field_02.png`（1504×1136 RGBA PNG，SHA-256 `572b0e098690fd9ec51dcdc3642c4480abace7002d0bd1e08c9541127da8acae`）。两图组成 `surgery_appendix` 专属术野池，沿用盆腔术野规则：每台手术稳定随机一张，切皮后显示，缝合阶段移除，界面与人物立绘位于其上。来源与触发记录见 `research/imports/appendix_operative_field_overlays_2026-10-03.json`。

2026-10-03 导入用户提供的两张通用开腹术野 CG，原样保存为 `assets/surgeries/overlays/abdominal/open_abdominal_field_01.png`（1760×920 RGB PNG，SHA-256 `db65fbf4c0e66ba4cc3ecb13fabe144f3bd816f27303f32c591ede3e55c15bff`）和 `open_abdominal_field_02.png`（1528×880 RGB PNG，SHA-256 `d9667f9a3736e72ed18710d8e32f502b36525907855263cc17ee63631d864b79`）。两图组成 `general_abdominal` 术野 overlay 池：切皮完成后叠在手术团队 CG 上，每台手术按可随存档重放的手术团队背景稳定随机一张，进入缝合步骤时移除，互动 UI 与人物立绘继续位于其上。阑尾切除保留优先级更高的专属术野池。来源与触发记录见 `research/imports/abdominal_operative_field_overlays_2026-10-03.json`。

2026-10-03 导入用户提供的两张心脏／开胸术野 CG，原样保存为 `assets/surgeries/overlays/thoracic/open_thoracic_field_01.png`（1088×960 RGB PNG，SHA-256 `aaa246114597def1aa96b5a7aff4671b81bff18ccd2e50ed68d6873a41790e8a`）和 `open_thoracic_field_02.png`（960×1216 RGB PNG，SHA-256 `655799e7fd0c70187d9d699afcd81d7a5f399f3923995a4a3ec8bb4a39a66a3b`）。两图共同组成 `cardiac` 与 `thoracic` 术野 overlay 池：完成切开后叠在手术团队 CG 上，每台手术稳定随机一张，进入关闭／缝合步骤时移除，互动 UI 与人物立绘位于其上。来源与触发记录见 `research/imports/thoracic_operative_field_overlays_2026-10-03.json`。

2026-10-03 使用内置 ImageGen 为锦木千束高级转诊教学第二天制作麻醉前手术台透明立绘 `assets/events/advanced_referral_tutorial_chisato/chisato_operating_table_preanesthesia_v1.png`（1428×1101 RGBA，SHA-256 `ae8feaf7f7f02134bed3978aebf0ac6cc99cccc930e400f4056ca57ac9c05167`）。画面仅保留手术帽、头肩和少量锁骨范围，用于注射前千束—弘子—千束对话的逐句立绘切换；完整来源与运行时映射见 `research/imports/chisato_operating_table_preanesthesia_portrait_2026-10-03.json`。

### Operating-table palpation prototype (2026-10-04)

- User-provided source: `/var/folders/t6/9dg502qd74vdq35hjs973jf40000gn/T/TemporaryItems/NSIRD_screencaptureui_psVZoY/Screenshot 2026-10-04 at 1.33.01 AM.png`
- Runtime asset: `assets/surgeries/palpation/or_table_torso_prototype_v1.png`
- Import record: `research/imports/or_table_palpation_prototype_2026-10-04.json`
- Current test routing: every surgery enters the palpation stage immediately after procedure selection and before anesthesia selection. The planned Miyama-event unlock is intentionally disabled during prototype testing.

### Operating-table palpation body-type expansion (2026-10-04)

- User-provided sources: the three images attached on 2026-10-04 at 10:12–10:13 AM.
- Runtime assets: `assets/surgeries/palpation/or_table_torso_body_type_02.png`, `or_table_torso_body_type_03.png`, and `or_table_torso_body_type_04.png`.
- Import record: `research/imports/or_table_palpation_body_types_2026-10-04.json`.
- Runtime behavior: the three additions and the original prototype form a four-image body-type pool. Procedure selection records one pool ID in the event log, so the image stays fixed across pressure changes, redraws, save, and replay. The images are copied at their original dimensions without redraw or resampling.
- Interaction update: `chest` is a separate narrow midline hotspot from the clavicular region through the lower sternum/xiphoid. Procedure relevance is now supplied by `data/surgeries/palpation_profiles.json`: thoracic/cardiac operations treat it as a primary region, breast operations as adjacent, and unrelated procedures retain the generic response.

### Operating-table palpation procedure relevance (2026-10-04)

- Design source: `docs/design/HOSHIMI_OR_PALPATION_RELEVANCE_AND_PREMATURE_INCISION_CODEX_V0_1_2026-10-04.md`.
- Runtime data: `data/surgeries/palpation_profiles.json` defines `generic`, `abdominal`, `breast`, `gynecology_pelvic`, and `thoracic_cardiac` mappings with localized primary and adjacent reactions.
- Runtime behavior: the first light or standard palpation of a primary region records one finding and briefly shows `术区反应已确认`; repeated palpation keeps its normal patient-state effects without granting another finding. Unrelated regions retain the original generic responses.
- Premature incision remains independent of procedure relevance. It records `premature_incision`, sets pain to maximum, raises fear, shows the patient and circulating-nurse beats, and then forces anesthesia selection.

### Operating-table scalpel cursor (2026-10-04)

- Runtime asset: `assets/surgeries/palpation/scalpel_cursor_v1.png`
- Import record: `research/imports/or_table_scalpel_cursor_2026-10-04.json`
- Creation: OpenAI built-in ImageGen, using the user-provided scalpel image only as a silhouette and orientation reference. The runtime asset has a transparent background and no source watermark.

### Palpation and anesthesia-test cursors (2026-10-04)

- User-provided sources: the transparent needle and surgical-glove PNGs attached on 2026-10-04.
- Runtime assets: `assets/surgeries/palpation/needle_cursor_v1.png` and `assets/surgeries/palpation/gloved_hand_cursor_v1.png`.
- Import record: `research/imports/or_table_sensory_test_tools_2026-10-04.json`.
- Runtime behavior: the glove is the hand-tool cursor in both body-interaction HUDs. The needle is an optional provocative tool during palpation and the standard pinprick tool during local/epidural sensory testing.

### Intraoperative staff HUD avatars (2026-10-04)

- Runtime assets: `assets/characters/intraoperative_staff_avatars_v1/<staff_id>/neutral.png`
- Import record: `research/imports/intraoperative_staff_avatars_v1_2026-10-04.json`
- Coverage: all 20 current staff records, each registered as `intraoperative_avatar/neutral` for the operative-field HUD.
- Creation: 19 portraits are identity-preserving head-and-shoulders crops from the characters' existing transparent sterile/scrubs artwork, normalized to a `1200 × 900` RGBA canvas by visible-pixel bounds. `nurse_satsuki` lacked operating-room artwork, so OpenAI built-in ImageGen used her existing focused uniform portrait as an identity reference and supplied the surgical cap, mask, and sterile gown. Full source paths and output hashes are recorded in the import record.

### 东川杏子普通患者包（2026-10-05）

- 导入用户提供的五张角色参考及一张透明诊室全裸立绘；角色明确设定为23岁成年女性。
- 使用内置 ImageGen 制作门诊、病房、普通仰卧手术台、截石位手术台、术中反应头像与全身麻醉场景。用户提供的诊室立绘不重绘，原样接入患者专属基础查体池，只在对应检查选择后显示。
- 运行时患者数据：`data/patients/patient_emi_higashikawa/patient.json`。素材、提示摘要与 SHA-256 见 `research/imports/patient_emi_higashikawa_2026-10-05.json`。

### 东川杏子患者流程 CG 补充（2026-10-09）

- 导入用户提供的四张成年患者流程 CG：诊室脱衣 `assets/examinations/patient_emi_higashikawa/full_undress_v2.png`、术前备皮 `assets/events/ward_preparation_v1/patient_emi_higashikawa/skin_prep_v1.png`、手术铺巾 `assets/events/ward_preparation_v1/patient_emi_higashikawa/operative_draping_v1.png`、下刀前 `assets/events/ward_preparation_v1/patient_emi_higashikawa/incision_ready_v1.png`。
- 运行时均通过 `patient_emi_higashikawa` 的专属 CG 池接入：脱衣绑定基础查体，备皮绑定 `ward_skin_prep` / `ward_skin_prep_unnecessary`，铺巾绑定 `operative_positioning`，下刀前绑定 `request_scalpel`。这些池优先于通用池；全麻路线继续遵守现有规则，隐藏清醒患者的术前准备 CG。
- 原图未修改；尺寸均为 `1584×1056` RGB PNG。文件哈希与来源补充记录见 `research/imports/patient_emi_higashikawa_2026-10-05.json`。

### 折川皐月 Lv1–Lv3 立绘补完（2026-10-05）

- 使用内置 ImageGen，以现有折川皐月身份母版为严格参考，制作 6 张刷手服、4 张护士服事故后表情，以及 22 张患者状态差分。
- 运行时目录：`assets/characters/portrait_pack_v25/nurse_satsuki/` 与 `assets/characters/relationship_patient_v1/nurse_satsuki/`。
- 担架、病床和手术台患者对话立绘采用 `docs/patient_dialogue_portrait_framing.md` 的紧构图；手术台组只显示手术帽、头、颈和裸肩，无菌单不入镜。
- Lv2 手术部段已切换刷手服；Lv3 Scene 9–13 使用事故后护士服差分，Scene 14–22 使用病房、担架、清醒手术台和术后病床差分。
- 完整文件哈希与范围见 `research/imports/nurse_satsuki_lv1_lv3_portraits_2026-10-05.json`。

### 折川皐月 Lv1 核心 CG（2026-10-05）

- 使用内置 ImageGen 将既有检查椅与患者视角概念图升格为正式素材，并补齐阿库娅离开后的收束图。
- 运行时素材：`assets/events/character_events/satsuki/cg/cg_satsuki_lv1_test_chair_v1.png`、`cg_satsuki_lv1_patient_pov_v1.png`、`cg_satsuki_lv1_alone_with_sakaguchi_v1.png`，分别绑定 `s03_frame`、`s04_pov`、`s09_alone`。
- 三张图统一执行主角镜头准则：坂口本人不入画，不出现身体、发型、服装、影子、倒影或身高暗示；可由坂口观察的构图使用第一人称视角。
- 提示摘要、运行节点与 SHA-256 见 `research/imports/nurse_satsuki_lv1_core_cg_2026-10-05.json`。

### 折川皐月 Lv3 备皮 CG（2026-10-05）

- 导入用户提供的成年角色医疗裸体 CG `assets/events/character_events/satsuki/cg/cg_satsuki_lv3_hiroko_satsuki_skin_prep_v1.png`，表现杉村弘子为折川皐月完成术前下腹及会阴备皮。
- 运行时绑定 `satsuki_lv3_wrong_patient_appendectomy_main / s15_009`；同步将 Scene 15 调整为星见院内流程：患者先更衣并全裸完成备皮，随后戴手术帽、盖覆盖单并上担架。
- 原图为 `1584 × 1056` PNG；来源、哈希和节点见 `research/imports/nurse_satsuki_lv3_skin_prep_cg_2026-10-05.json`。

### 折川皐月 Lv3 百合香错误交接 CG（2026-10-05）

- 导入用户提供的成年角色手术室交接 CG `assets/events/character_events/satsuki/cg/lv3/cg_satsuki_lv3_yurika_wrong_handoff_v1.png`。
- 运行时绑定 `satsuki_lv3_wrong_patient_appendectomy_main / s07_008`：腕带、床号和病历均能对应，但团队没有重新询问出生日期与术式，画面以半清醒的百合香为中心呈现该身份核对失误。
- 原图为 `1584 × 992` RGB PNG；来源、哈希和节点见 `research/imports/nurse_satsuki_lv3_yurika_wrong_handoff_cg_2026-10-05.json`。

### 折川皐月 Lv3 百合香灌肠差分 CG（2026-10-05）

- 导入用户提供的一张病号服 SFW 准备图和两张成年角色医疗裸体差分：`cg_satsuki_lv3_yurika_enema_setup_sfw_v1.png`、`cg_satsuki_lv3_yurika_enema_insertion_v1.png` 与 `cg_satsuki_lv3_yurika_enema_cramping_v1.png`。
- 三张分别绑定 `s02_024` 看到导管后的僵硬笑容、`s02_035` 的导管送入反应与 `s02_043` 的灌入后腹胀反应，形成准备、送入和不适加重的连续演出。
- 准备图为 `1536 × 1024`，两张裸体差分均为 `1584 × 992` RGB PNG；来源、哈希和节点见 `research/imports/nurse_satsuki_lv3_yurika_enema_cg_2026-10-05.json`。

### 折川皐月 Lv3 百合香麻醉诱导 CG（2026-10-05）

- 使用内置 ImageGen 制作百合香麻醉面罩扣脸的近景 CG，保留其深蓝紫长发、经典动画画风和麻醉前轻微失焦内聚的眼神。
- 运行时素材 `assets/events/character_events/satsuki/cg/lv3/cg_satsuki_lv3_17_yurika_mask_induction_v1.png` 绑定 `satsuki_lv3_wrong_patient_appendectomy_main / s08_003`。
- 图片为 `1672 × 941` RGB PNG；来源、哈希和节点见 `research/imports/nurse_satsuki_lv3_yurika_mask_induction_cg_2026-10-05.json`。

### 折川皐月 Lv3 百合香备皮 CG（2026-10-05）

- 导入用户提供的成年角色医疗裸体 CG `assets/events/character_events/satsuki/cg/lv3/cg_satsuki_lv3_yurika_skin_prep_v1.png`，表现折川皐月为百合香完成术前下腹及会阴完整备皮。
- 运行时绑定 `satsuki_lv3_wrong_patient_appendectomy_main / s03_019`，在一次性剃刀开始操作时显示；同步将本段文字调整为星见流程中的全裸准备和完整阴毛处理，随后衔接戴手术帽、覆盖并转运。
- 原图为 `1584 × 1056` RGB PNG，SHA-256 与来源见 `research/imports/nurse_satsuki_lv3_yurika_skin_prep_cg_2026-10-05.json`。

### 遥凑 Intro / 惠事件专用立绘（2026-10-07）

- 使用用户提供的惠 / Megumi Reinard 原作参考图，通过内置 ImageGen 生成事件专用半身透明立绘。
- 病房组保存于 `assets/events/character_events/minato_intro/megumi/ward/`：短袖纯白日式护士裙制服与纯白护士帽，包含 `professional`、`focused`、`dry_admonishing`、`reassuring`、`knowing` 五种差分。
- 手术室组保存于 `assets/events/character_events/minato_intro/megumi/or/`：长袖手术袍、系带口罩与完全遮发手术帽，包含同名五种差分。
- 小夜香初见事件 CG 保存于 `assets/events/character_events/minato_intro/cg/`：`megumi_wakes_her.png`（惠叫醒艾莉娜）、`minato_names_player.png`（艾莉娜已坐上转运车并与遥凑争辩手术日期）、`baseball_small_talk.png`（坂口助手侧主观视角的术中棒球对话）、`erina_postop_baseball.png`（术后艾莉娜观看棒球直播）。
- 遥凑事件术后散步素材：`assets/backgrounds/v12/minato_riverside_walk.png` 为城市河边散步道背景；`assets/events/character_events/minato_intro/cg/minato_riverside_coffee.png` 为遥凑在自动贩卖机前拿罐装咖啡并向坂口眨眼的结尾 CG。两者绑定在 `minato_riverside_walk` 与 `minato_riverside_coffee` 节点。
- 惠保持 story-only，不建立正式 staff profile；素材由 `minato_intro_sunday_cholecystectomy_main` 直接引用。

### 艾莉娜术前、术中与术后事件立绘（2026-10-07）

- 术前无帽病号服差分位于 `assets/characters/portrait_pack_v21/patient_erin/ward_preparation/`，包含 `dazed`、`surprised`、`irritated`。
- 术中肩部以上清醒患者差分位于 `assets/characters/portrait_pack_v21/patient_erin/intraoperative/`，采用平躺俯视暗示构图，包含 `tense_amused`、`skeptical`、`resigned`；不包含手臂、托脸或手术器械。
- 术后病号服差分位于 `assets/characters/portrait_pack_v21/patient_erin/postoperative/`，包含 `exhausted`、`relieved`、`baseball`。
- 术前准备完成后至手术结束使用的带手术帽患者差分，来自用户提供的透明 PNG，位于 `assets/characters/portrait_pack_v21/patient_erin/intraoperative_nude/`，包含 `prepared_arms_crossed`、`prepared_hand_head`、`exhausted`、`skeptical`、`amused`；事件中保持半身构图，并与病房病号服差分分开使用。
- 相关素材由 `minato_intro_sunday_cholecystectomy_main` 直接引用；病房争论使用 `minato_names_player` CG，术中与术后 CG 保持原有节点绑定。
- 遥凑补齐术中 HUD 头像 `assets/characters/intraoperative_staff_avatars_v1/doc_minato/neutral.png`，以及助手医生角色奖励 CG `assets/events/staff_surgery_v1/doc_minato/assistant_confirmation.png`；两项均登记在 `doc_minato` 数据包中。
- 遥凑通用约会资料登记为 `date_doc_minato`，偏好咖啡店、河边公园、大型书店和意大利小餐馆；星期日初见事件的河边散步仍保持为专用事件段落，不改用通用约会系统。

### 香田映见普通患者包（2026-10-09）

- 患者以 `patient_emi_koda` 接入普通患者池，显示年龄固定为 22 岁；运行时病例仍由普通患者轮换和病例分配系统决定，不绑定固定诊断、术式、麻醉或关系事件。
- 复用 `socially_anxious_formal_quiet` 性格台词 Profile，仅在患者包中覆盖香田映见专属的术前、麻醉、切口、互动、闭合对白，以及灌肠、备皮、戴帽、体位、导尿和切口标记差分。
- 用户提供的透明脱衣立绘原样接入 `assets/examinations/patient_emi_koda/full_undress.png`，只绑定基础查体的患者专属 CG 池。
- 使用内置 ImageGen 补齐 `assets/characters/patient_emi_koda_v1/patient_emi_koda/` 的门诊、病房六态、仰卧手术台四态与截石位手术台四态；手术台构图和裸肩／锁骨裁切以高卷杏 `patient_ann` 的既有目录为参考，患者不穿病号服或手术衣。
- 使用内置 ImageGen 补齐 `assets/characters/intraoperative_portraits_v1/patient_emi_koda/` 的紧张、疼痛、濒临崩溃、麻醉四态透明头像；同样采用高卷杏的裸肩、手术帽和头肩构图作为规范。全麻 splash 保存于 `assets/events/anesthesia_v1/patient_emi_koda/general.png`。
- 2026-10-09 导入用户提供的香田映见四张专属 CG：基础查体脱衣 `assets/examinations/patient_emi_koda/full_undress_basic_exam.png`、术前灌肠 `assets/events/ward_preparation_v1/patient_emi_koda/enema.png`、术前戴手术帽 `assets/events/ward_preparation_v1/patient_emi_koda/surgical_cap.png`、手术下刀前 `assets/events/ward_preparation_v1/patient_emi_koda/incision_ready.png`。四张均原样保存，并分别绑定既有患者专属检查／术前准备 CG 池；来源与哈希见 `research/imports/patient_emi_koda_2026-10-09.json`。
- `reference_sheet.png` 保留为研究参考副本，不再被运行时状态键引用；之后用户提供的特殊 CG 会另行登记到 `exclusive_cg_pools.surgery` / `ward_preparation`，不替换这套通用状态素材。
- 原始参考图、文件哈希与接入范围见 `research/imports/patient_emi_koda_2026-10-09.json`。
### 蒂法·洛克哈特（patient_tifa，2026-10-09）

- 附件 1、2 用作五官、发型、体型与 2D 画风参考；标准门诊、病房、手术台、术中头像和全麻图由图像生成流程按项目规格生成。
- 附件 3 为用户提供的透明诊察立绘，原样导入 `assets/examinations/patient_tifa/full_undress.png`，并通过 `exclusive_cg_pools.examination` 绑定；未将其冒充为普通 `examination/shy` 以外的资源。
- 生成的手术台与术中资源保持手术帽、裸肩和露锁骨构图；没有加入衣领或病号服遮挡。
- 当前未加入蒂法专属灌肠、戴帽、备皮或下刀前 CG；患者 bundle 的 `ward_preparation` 与 `surgery` 池保持为空。
- 完整资源哈希与尺寸记录见 `research/imports/patient_tifa_2026-10-09.json`。

### 爱丽丝·盖恩斯巴勒（patient_aerith，v2 已注册）

- 按修订后的 `skills/add-patient/SKILL.md`，使用内置 ImageGen 逐张生成 20 张独立 SFW 标准图；每次实际输入用户的 2D 五官参考及对应高卷杏构图/表情参考。同类差分使用已验收的新患者基图，没有切分拼图或复制改名凑数。
- 门诊和病房六态：`assets/characters/patient_aerith_v1/patient_aerith/`，1024×1536 RGBA；病房为浅蓝交领宽袖病号服，双肩被衣服覆盖。门诊保留红裙与单辫，去掉生成草稿擅加的高开衩。
- 仰卧与截石位各四态：同目录下的 `operating_table/`、`operating_table_lithotomy/`，1448×1086 RGB，完整俯视台面、手术帽、裸肩/锁骨和不透明铺巾；胸腹、骨盆及大腿完整覆盖。闭眼麻醉态不加面罩。
- 术中四态：`assets/characters/intraoperative_portraits_v1/patient_aerith/`，1448×1086 RGBA，正面头颈肩锁骨头像，无面罩、床、铺巾或衣领。全麻特写：`assets/events/anesthesia_v1/patient_aerith/general.png`，1672×941 RGB，闭眼、口鼻面罩及右侧管路；修正了草稿误生双辫的问题。
- 用户附件 4 原样保存为 `assets/examinations/patient_aerith/full_undress.png`，1056×1584 RGBA，作为 `examination/shy` 候选立绘；哈希与附件完全相同。该透明立绘与后续全屏 CG 分开保存。
- 2026-10-10 原样导入用户补充的 5 张 1584×1056 RGB 全屏 CG：`assets/examinations/patient_aerith/full_undress_basic_exam.png`，以及 `assets/events/ward_preparation_v1/patient_aerith/` 下的 `enema.png`、`skin_prep.png`、`sterile_draping.png`、`incision.png`。铺巾绑定 `ack_disinfection`；下刀图最初被错误绑定到 `incise_*`，已于 2026-10-12 修正为接过手术刀后的 `request_scalpel`。铺巾和下刀画面仅匹配腹部/盆腔术式组，不改变随机病例分配。
- CG 来源、哈希、触发规则和待注册英文标签见 `research/imports/patient_aerith_cg_2026-10-10.json`。原图未裁切；现有全屏等比覆盖在 1280×800 下会裁去上下各约 33 个源像素，尚未进行 Godot UI 实测。
- 21 个键、尺寸、模式、Alpha、唯一哈希和浅/深底并排检查通过。8 张台面图及 1 张头像由 1447×1087 按比例微调并居中裁去缩放后的 2 行像素，规范为 1448×1086；原始生成文件保留。提示词及真实输入路径见 `research/imports/patient_aerith_portraits.json`，验收与哈希见 `research/imports/patient_aerith_portrait_audit.json`，并排图见 `research/imports/patient_aerith_qa/`。
- 新增共享人格 `playful_defiant_detail`，保留用户提供的 27 条通用台词、13 组差分；爱丽丝草稿只保存 7 条个人台词、4 组个人差分覆盖，中文原文逐句核对，英文译文分别保存。未修改病例分配、麻醉、术式、关系或数值机制。
- 用户补全并验收的 v2 已原样保存到 `data/patients/patient_aerith/patient.json`，并在普通患者索引注册一次。原文存档为 `research/character_references/patient_aerith/user_bundle_v2.json`；与附件逐字节一致。新增 62 个患者英文键，现有性格英文、21 张立绘与 5 张 CG 原件未改动。
- 正式入库及验证记录见 `research/imports/patient_aerith_registered_v2.json`、`research/imports/patient_aerith_STATUS.md`；旧 `patient_aerith_2026-10-09.json` 仅保留为历史草稿。完整 bundle schema、原文/资源哈希、中英文 Python 加载和患者英文覆盖检查通过；尚未执行 Godot 运行时或 UI 测试。

### 天手让叶（玛秋，patient_amate_yuzuriha，2026-10-10）

- 用户提供的成年 AU 诊察室裸体半身立绘原样保存为 `assets/examinations/patient_amate_yuzuriha/full_undress.png`，不与生成的标准 SFW 立绘混用。五张用户种子图保存在 `research/character_references/patient_amate_yuzuriha/`，仅作为人物身份与画风参考。
- 使用内置 ImageGen 按高卷杏 `patient_ann` 的既有目录规格逐张制作 20 张标准 SFW 资源：门诊 1 张、病房 6 张、仰卧手术台 4 张、截石位手术台 4 张、术中头肩头像 4 张、全麻 splash 1 张。手术台画面均露肩露锁骨；铺巾从上胸／腋下附近开始，胸腹骨盆与大腿由不透明青绿色手术单遮盖；截石位只露出手术单以下的裸小腿和脚，不含裤子、袜子或鞋。
- 术中头像保存于 `assets/characters/intraoperative_portraits_v1/patient_amate_yuzuriha/`，为 `1448×1086 RGBA` 透明头颈肩锁骨构图，不带手术单、病床、器械或背景。此前不符合要求的穿衣／穿袜候选没有进入运行时目录。
- 患者包 `data/patients/patient_amate_yuzuriha/patient.json` 已注册到 `data/patients/index.json`，继承 `strong_front_expressive_irritable`；不绑定固定诊断、术式、麻醉、关系或剧情。6 张用户提供的流程 CG 已通过 1 个 `examination` 池和 5 个 `ward_preparation` 池登记，`surgery` 池保持为空。
- 2026-10-10 导入用户提供的六张成年患者流程 CG：诊察室脱衣 `assets/examinations/patient_amate_yuzuriha/full_undress_basic_exam.png`、术前灌肠 `assets/events/ward_preparation_v1/patient_amate_yuzuriha/enema.png`、术前剃毛 `skin_prep.png`、普通手术固定 `operative_positioning.png`、妇科手术体位 `operative_positioning_female_pelvic.png`、下刀瞬间 `incision.png`。其中妇科体位池只匹配 `female_pelvic`，普通手术固定池排除该组；下刀池匹配既有清醒下刀动作并限制于腹部／盆腔术式组。
- 上述六张 CG 均为用户原图，统一为 `1584×1056 RGB`，通过 `exclusive_cg_pools` 绑定；来源文件、SHA-256 与池 ID 见 `research/imports/patient_amate_yuzuriha_2026-10-10.json`。
- Bundle schema、运行时患者加载、患者英文覆盖、20 张标准 SFW 及 6 张专属 CG 的尺寸／模式／哈希检查均通过。完整来源、生成候选、哈希和审计记录见 `research/imports/patient_amate_yuzuriha_2026-10-10.json`。

### 妮安（patient_nyaan，2026-10-10）

- 用户提供的 5 张 SFW 种子图用于身份、五官、发色和 2D 画风参考；附件 6 的成年患者诊察室全裸半身立绘原样保存为 `assets/examinations/patient_nyaan/full_undress.png`，只接入 `examination/shy`，不与 20 张标准 SFW 图混用。
- 按高卷杏 `patient_ann` 实际目录逐类生成 20 张标准图：门诊 1 张、病房 6 张、仰卧手术台 4 张、截石位手术台 4 张、术中头肩头像 4 张、全麻 splash 1 张。病房使用浅蓝交领病号服；两类手术台均保持裸肩、露锁骨和不透明青绿色铺巾；截石位只露铺巾以下的小腿和脚；术中头像只到锁骨下方且真实透明。
- 生成图全部逐键独立制作，没有使用拼图、切片或复制改名凑数；6 张 `1447×1087` 草稿按比例规范为 `1448×1086`，未改变构图内容。已在浅色底并排检查透明图边缘，并逐组检查表情差异、帽子、铺巾覆盖和人物尺度。
- 患者 bundle 使用 `shy_reassurance_quiet`，不绑定固定诊断、术式、麻醉、关系或剧情；将来源中的 `soft`／`quiet_then_outburst` 归一化为现有 schema 的 `reserved`／`becomes_quiet`，原始语义由患者专属对白保留。
- Bundle schema、运行时加载、21 个立绘键、27/13 对白合并、英文覆盖、尺寸／模式／Alpha 和哈希检查均通过。来源与完整审计记录见 `research/imports/patient_nyaan_2026-10-10.json`。
- 2026-10-10 原样导入用户提供的 5 张成人患者流程 CG：诊察室脱衣 `assets/examinations/patient_nyaan/full_undress_basic_exam.png`、术前剃毛 `assets/events/ward_preparation_v1/patient_nyaan/skin_prep.png`、戴手术帽 `surgical_cap.png`、妇科手术体位 `operative_positioning_female_pelvic.png`、下刀瞬间 `incision.png`。5 张均为 `1584×1056 RGB`，分别绑定 1 个 examination 池和 4 个 ward-preparation 池；妇科体位与下刀仅匹配 `female_pelvic` 术式组，未改动病例分配。
- 上述 CG 未经裁切、缩放或像素编辑，来源文件与目标文件逐字节校验；完整来源、SHA-256、池 ID 与触发动作见 `research/imports/patient_nyaan_cg_2026-10-10.json`。

### 小森·哈珂特（patient_comoli_harcourt，2026-10-10）

- 用户提供的患者包原文存档于 `research/character_references/patient_comoli_harcourt/user_bundle_v1.json`；五张SFW种子图存档于同目录。用户提供的成年诊室裸体立绘已原样注册为 `examination/shy`，并复用为诊室全裸查体 CG 显示资源，路径为 `assets/examinations/patient_comoli_harcourt/full_undress.png`；尺寸1056×1584 RGBA，SHA-256为 `f9f0c03d17d2edce863484f56588ff815135196be17c9b70e42351e0b0ca3119`。检查动作池 `full_undress_basic_exam_patient_comoli_harcourt` 已连接 authoritative/gentle/threaten 三个完成脱衣选项，英文标签与说明已补齐。原始 bundle 没有独立诊室背景 CG，故当前复用该立绘显示；没有患者专属术前准备或手术阶段 CG 文件，通用池仍按项目既有规则回退。
- 按 `patient_ann` 资源布局导入6张首批SFW立绘，并在用户确认后生成并导入8张表情变体；经同规格重试后，当前已登记20张标准SFW图中的18张（门诊1、病房6、仰卧手术台4、截石位手术台2、术中头像4、全麻splash 1）。术中头像为1448×1086 RGBA；截石位图为1448×1086 RGB；病房/门诊透明图为1024×1536；splash为1672×941。仍缺截石位 afraid/anesthetized：同规格重试后仍遭输入审核拒绝，未用重复图替代。
- 患者数据年龄22岁，沿用既有性格对白组；病例仍采用随机分配及既有 fallback。患者专属“术前追问”覆盖提问节点，用户确认的第二句作为详细说明节点末尾的患者对白，英文也已登记。未引入固定关系、剧情或CG池。
- 图像来源路径、生成提示规格、SHA-256、尺寸/Alpha、完成和阻塞清单见 `research/imports/patient_comoli_harcourt_2026-10-10.json`。当前资源集仍为部分完成，只有截石位 afraid/anesthetized 两张SFW图未登记。

### 瑟法（patient_sepha，2026-10-10）

- 用户提供的患者包原文存档于 `research/character_references/patient_sepha/user_bundle_v1.json`；4张SFW种子图存档于同目录。用户提供的成年诊室裸体立绘已逐字节复制并注册为 `examination/shy`：`assets/examinations/patient_sepha/full_undress.png`，1056×1584 RGBA；未纳入SFW生成输入。
- 患者年龄24岁，沿用 `calm_analytical_reassurance` 对白组；来源 `voice_style=soft` 映射至schema允许的 `gentle`。病例与fallback保持来源包值；三个专属CG池为空，不新增池。
- 用户确认六类基图方向并选定截石位awake候选2；现已完整登记20/20张标准SFW图。用户补充的 `operating_table_lithotomy/afraid` 原图为1448×1080 RGB，按比例与原图内容不变原则在上下各扩展3 px画布，注册尺寸1448×1086 RGB；原件存于 `research/character_references/patient_sepha/user_lithotomy_afraid_original.png`。另有用户提供的4张CG已分别接入诊室脱衣、术前灌肠、术前导尿和清醒下刀前节点，原图保存在 `research/character_references/patient_sepha/user_cgs/`；图像为1584×1056 RGB，原样导入。门诊穿用户种子图中的军装，病房使用浅蓝交领病号服；手术台/截石位露肩锁骨且以不透明青绿色铺巾覆盖胸腹及下身；术中头像为横向头肩透明图；全麻splash闭眼并带面罩，其他麻醉图闭眼且无面罩。用户提供的新 `graphic_preop_dialogue` 旁白按原文导入并加入英文映射。路径、哈希、Alpha/尺寸记录见 `research/imports/patient_sepha_2026-10-10.json`。
### 蝴蝶忍（patient_kocho_shinobu，2026-10-10）

- 用户提供的数据包原件归档于 `research/character_references/patient_kocho_shinobu/patient_bundle_v1.json`，六张种子图归档为同目录 `seed_01.png` 至 `seed_06.png`；诊室立绘原件归档为 `full_undress_original.png`，并逐字节复制到 `assets/examinations/patient_kocho_shinobu/full_undress.png`，注册为 `examination/shy`。
- 已导入完整患者数据 `data/patients/patient_kocho_shinobu/patient.json` 并登记至患者索引。标准立绘齐全：门诊1、病房6、普通手术台4、截石位手术台4、术中头像4、全麻splash 1；加上用户提供的诊室立绘共21个portrait状态键。标准立绘以用户种子图为角色外观参考。
- 来源包的 `voice_style=soft` 保留原值；同步扩展患者数据schema和对白风格映射以原生支持该值，未改写患者包对白或字段。用户随后提供的6张CG依次接入诊室全裸、灌肠、戴手术帽、铺巾、导尿和下刀节点；原件保存在 `research/character_references/patient_kocho_shinobu/user_cgs/`。未提供的其他CG池及诊断反应仍为空。
- 来源原件哈希、CG节点/路径映射和静态验证结果见 `research/imports/patient_kocho_shinobu_2026-10-10.json`。数据schema、患者包本地化、全局本地化和剧情本地化检查均通过；当前环境未检测到Godot可执行文件，因此未进行Godot运行时加载测试。

### 宫水三叶（patient_miyamizu_mitsuha，2026-10-11）

- 用户提供的 6 张种子图和透明全裸诊察立绘已归档于 `research/character_references/patient_miyamizu_mitsuha/`；立绘原样导入 `assets/examinations/patient_miyamizu_mitsuha/full_undress.png`，只绑定 `patient.visuals.portraits["examination/shy"]`，未冒充全屏诊察 CG。
- 已导入来源 bundle 至 `data/patients/patient_miyamizu_mitsuha/patient.json` 并登记患者索引。21 个基础 portrait 键现已全部映射：门诊 1、病房 6、仰卧台 4、截石位 4、术中头像 4、全麻 splash 1、用户提供的诊察立绘 1。截石位麻醉态仅做 1px 画布尺寸规范，不拉伸；新补的透明术中头像有轻微青色边缘杂色，已在记录中注明。
- 用户原始中文剧情与对白保持未改；为 bundle 中全部 95 个中文叶字段加入英文映射。随后按用户明确的可选 CG 阶段，追加导入并连接 7 张专属全屏 CG：诊室全裸检查、术前剃毛、术前转运、导尿、体位固定、术野消毒、下刀前。转运节点确认复用既有 `complete_manual_ward_preparation` 动作 ID；其余分别接入 `ward_skin_prep`/`ward_skin_prep_unnecessary`、`urinary_catheterization`、`operative_positioning`、`skin_disinfection`、`request_scalpel`。全部池限定 `patient_miyamizu_mitsuha`，并添加英文 label/caption。来源 CG 原件归档于 `research/character_references/patient_miyamizu_mitsuha/user_cgs/`；路径、哈希及映射见 `research/imports/patient_miyamizu_mitsuha_2026-10-11.json`。静态链路已核验；因当前环境无 Godot，尚未进行运行时画面测试。


### 七瀬恋制服修订与常服（nurse_haru，2026-10-11）

- 用户提供5张人物/护士服参考及1张常服参考，批准正面、无围裙粉色护士服样张与深灰半裙常服方案。原件存于 `research/character_references/nurse_haru/refresh_2026-10-11/`。
- 内置 ImageGen 输出6张制服表情和1张常服neutral，均1024×1536 RGBA，存于 `assets/characters/nurse_haru_refresh_v1/`。只更新对应profile映射，保留全部旧文件和其他服装；不改剧情、岗位CG、奖励或触发条件。
- 来源路径、SHA-256、旧映射和提示词见 `research/imports/nurse_haru_refresh_2026-10-11.json` 与 `research/imports/nurse_haru_refresh_prompts_2026-10-11.json`；详细验证记录见 `docs/after_work_casual_portraits_todo.md`。中英文真实渲染、236项专项、101项同行、1900项季节检查及数据/叙事本地化审计通过。


### 七瀬恋秋冬风衣（2026-10-11）

- 用户批准B风衣样图及9–2月规则，原样注册为 `casual_winter/neutral`：`assets/characters/nurse_haru_refresh_v1/casual_winter/neutral.png`。生成提示词在 `research/character_references/nurse_haru/winter_concepts_2026-10-11/prompts.json`；来源哈希与验证见 `research/imports/nurse_haru_winter_2026-10-11.json`。
- 保留原制服与春夏常服；按离院工作日选择，邀请阶段即穿冬装，中英文运行时与实际渲染通过。冬装原图头部比春夏略高约20屏幕像素，未改动已选定B设计。


### 明日香、阿尔托莉雅、皐月一次性岗位CG（2026-10-11）

- 内置ImageGen基于各角色既有制服/无菌服立绘生成5张1672×941 RGB场景，注册于三个角色的role_rewards.json：明日香和阿尔托莉雅助手医各1张，皐月器械/巡回/病房各1张。
- 来源路径、SHA-256、提示词及验证记录在 `research/imports/staff_role_cgs_2026-10-11.json` 与 `research/imports/staff_role_cgs_prompts_2026-10-11.json`。中英文31张岗位CG总回归1299项通过，五张新增内容均经实际渲染检查。
- 不改剧情及团队资格。按用户指定排除千鹤、樱花、摩耶、双叶的本批岗位CG制作。


### 明日香、阿尔托莉雅秋冬常服定稿（2026-10-11）

- 用户批准两张ImageGen样图，原样注册至 `assets/characters/winter_casual_v1/` 下各角色的neutral.png；1024×1536 RGBA，9–2月使用，原casual保持。未新建差分或更改剧情。
- 来源、哈希、完整生成提示词与验证在 `research/character_references/winter_casual_samples_2026-10-11/` 的manifest.json和prompts.json。季节43928项、全员服装1184项均通过，中英文原生窗口截图已验证。


### 岩户环（patient_iwato_tamaki，2026-10-11）

- 用户提供的 complete bundle、5 张种子图和透明诊察立绘归档于 `research/character_references/patient_iwato_tamaki/`。透明立绘由用户确认“完全正常，没有任何问题，可以直接使用”，原样注册为 `examination/shy`；文件哈希与归档源一致，尺寸 1056×1584 RGBA，含透明像素。
- 患者 bundle 已导入 `data/patients/patient_iwato_tamaki/patient.json` 并在 `data/patients/index.json` 登记一次。21 个标准立绘键均映射到存在的文件：门诊1、病房6、仰卧手术台4、截石位手术台4、术中头像4、全麻splash 1、用户透明诊察立绘1。原始中文台词保持不变，英文映射已补齐。
- 来源包的 `stress_response=overexplains_then_seeks_reassurance` 不属于当前 schema 枚举；患者运行时值使用最贴近的既有 `seeks_reassurance`，不改动对白及性格主/副标签。
- 基础立绘导入时没有提前创建全屏 CG 池。随后按用户补充请求原样导入8张全屏 CG：诊室全裸检查1张，以及灌肠、剃毛、戴手术帽、上担架车转运、导尿、术野铺巾、下刀各1张。图像保存在 `assets/examinations/patient_iwato_tamaki/` 和 `assets/events/ward_preparation_v1/patient_iwato_tamaki/`，各自绑定患者专属池；“下刀”图最初错误绑定到 `incise_*`，已于 2026-10-12 修正为接过手术刀后的 `request_scalpel`。详见 `research/imports/patient_incision_cg_binding_repair_2026-10-12.json`。
- CG 来源 SHA-256、池 ID、动作 ID、英文标签/说明和验证状态见 `research/imports/patient_iwato_tamaki_2026-10-11.json`。患者 bundle 本地化、池与文件静态链路及全量数据 schema 检查通过；当前环境无 Godot 可执行文件，未执行游戏内运行时画面检查。
# 明日香春夏常服补充来源（2026-10-11）

- 内置ImageGen根据已批准秋冬立绘生成春夏装，并按用户反馈修正头身比；用户批准`neutral_v2.png`接入。
- 正式资源：`assets/characters/spring_summer_casual_v1/doc_asuka/neutral.png`，1024×1536 RGBA；源图、提示词、哈希与替换前映射见`research/imports/doc_asuka_spring_summer_2026-10-11.json`及其引用。旧素材保留。

## 成美两季常服（2026-10-11）

用户批准内置ImageGen生成的春夏、秋冬neutral原样接入，均1024×1536 RGBA。以现有c1058-neutral-ai.png为身份参考；正式资源位于`assets/characters/spring_summer_casual_v1/doc_aoi/`及`assets/characters/winter_casual_v1/doc_aoi/`。来源、哈希及提示词见`research/imports/doc_aoi_casual_2026-10-11.json`。原工作服保留。

## 弘子、詩織秋冬常服（2026-10-11）

内置ImageGen根据各自现有常服生成秋冬neutral，用户确认后原样接入`assets/characters/winter_casual_v1/{nurse_hiroko,doc_shiori}/neutral.png`，均1024×1536 RGBA。源图、提示词、哈希与验收记录见`research/imports/hiroko_shiori_winter_2026-10-11.json`。原春夏常服及工作服保留。

## 小夜香、遥凑秋冬常服（2026-10-11）

内置ImageGen以各自casual/neutral为参考生成秋冬neutral，用户批准后原样接入`assets/characters/winter_casual_v1/{doc_sayaka,doc_minato}/neutral.png`，均1024×1536 RGBA。源图、提示词及哈希见`research/imports/sayaka_minato_winter_2026-10-11.json`。保留原春夏图和工作服。

## 深山佳織两季常服（2026-10-11）

内置ImageGen使用紫发身份母版、原作粉色套装服装参考与v20白大褂姿势参考生成两季neutral，用户确认后原样接入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/doc_rei/neutral.png`，均1024×1536 RGBA。原作参考未直接接入。来源、哈希及提示词见`research/imports/doc_rei_casual_2026-10-11.json`。

## 御堂江美子两季常服（2026-10-12）

内置ImageGen以v14白大褂neutral为参考制作，用户批准后原样接入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/doc_emiko/neutral.png`，均1024×1536 RGBA。来源、哈希及提示词见`research/imports/doc_emiko_casual_2026-10-12.json`。

## 阿库娅两季常服（2026-10-12）

用户批准设计并授权直接接入。内置ImageGen以v18白大褂neutral为参考绘制春夏，再以其生成秋冬，原样接入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/doc_aqua/neutral.png`，均1024×1536 RGBA。来源、哈希、提示词和验证结果见`research/imports/doc_aqua_casual_2026-10-12.json`。

## 樱花两季常服（2026-10-12）

内置ImageGen以v23白大褂neutral_v1为参考制作，用户确认春夏领带修正版及秋冬装后原样接入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/doc_sakura_anesthesiology/neutral.png`，均1024×1536 RGBA。来源、哈希及参考清单见`research/imports/doc_sakura_casual_2026-10-12.json`；提示词存于其引用的样图目录。

## 清水伊莱莎患者专属立绘与术前 CG（2026-10-12）

按用户提供顺序原样导入全裸立绘、诊室脱衣查体、剃毛、灌肠、导尿、铺巾、下刀前及担架车转运素材。立绘接入 `examination/shy`；诊室 CG 仅绑定完成脱衣的三条查体分支；术前 CG 分别绑定 `ward_skin_prep`、`ward_enema`、`urinary_catheterization`、`ack_disinfection`、`request_scalpel` 和人工病房准备结束的 `complete_manual_ward_preparation`。CG 标签与说明均提供英文版本；未改动原图。来源路径与 SHA-256 见 `research/imports/patient_shimizu_iraiza_cgs_2026-10-12.json`。

## 朝倉美幸两季常服（2026-10-12）

内置ImageGen以原制服身份参考绘制两季常服，按用户反馈补足颅顶及发量，用户确认后原样导入修正版至`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/nurse_yui/neutral.png`。来源、哈希、提示词与验证记录见`research/imports/nurse_yui_casual_2026-10-12.json`。

## 中井美佳两季常服（2026-10-12）

内置ImageGen以v2制服neutral为身份参考生成春夏，再以其生成秋冬，保留深棕长辫及蓝灰眼睛。用户确认后原样导入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/nurse_rin/neutral.png`，均1024×1536 RGBA。来源、SHA-256、提示词和验证结果见`research/imports/nurse_rin_casual_2026-10-12.json`。

## 利根川安琪原作两季常服高清重绘（2026-10-12）

以用户两张原作服装附件为参考，内置ImageGen按星见高清画风重绘；春夏按反馈移除胸牌、挂绳、文件夹及钢笔，两季眼睛放大靠拢原作。用户批准v2后原样导入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/nurse_ange/neutral.png`，均1024×1536 RGBA。秋冬参考缺少下半身，外套下摆与裤装为补绘。附件、来源哈希、提示词和验证结果见`research/imports/nurse_ange_casual_2026-10-12.json`及其引用。

## 本庄萌惠两季常服（2026-10-12）

内置ImageGen以v13制服neutral为身份参考、美佳春夏为画风与尺度参考制作春夏，再生成同姿势秋冬。用户批准后原样导入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/nurse_moe/neutral.png`，均1024×1536 RGBA。保留绿发、蓝眼和银色眼镜。来源、SHA-256、提示词及验证结果见`research/imports/nurse_moe_casual_2026-10-12.json`。

## 折川皐月两季常服（2026-10-12）

内置ImageGen以v24制服neutral为身份、姿势及画风参考制作春夏，再生成同姿势秋冬。用户批准后原样导入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/nurse_satsuki/neutral.png`，均1024×1536 RGBA。保留深绿长发、浅蓝灰眼和黑色矩形眼镜。来源、SHA-256、提示词及验证结果见`research/imports/nurse_satsuki_casual_2026-10-12.json`。

## 真奈美、千鹤两季常服（2026-10-12）

用户批准四张定稿原样接入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/{pharmacist_manami,nurse_ishigami}/neutral.png`，均1024×1536 RGBA。真奈美以v10药剂师立绘为身份参考，由内置ImageGen绘制成熟知性两季服装；千鹤以用户原作肖像和v22制服为参考，保留深色立领及银饰，补绘下装与冬装。来源、哈希、提示词和验收记录分别见`research/imports/pharmacist_manami_casual_2026-10-12.json`、`research/imports/nurse_ishigami_casual_2026-10-12.json`。

## 成年双叶两季常服（2026-10-12）

内置ImageGen以v21成年双叶白大褂neutral为身份及画风参考，按用户批准的成年医学专家常服设计绘制春夏与秋冬。用户确认后原样导入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/visiting_futaba/neutral.png`，均1024×1536 RGBA。来源、SHA-256、提示词和验证记录见`research/imports/visiting_futaba_casual_2026-10-12.json`。

## 摩耶两季常服（2026-10-12）

内置ImageGen以v20成年摩耶白大褂neutral为身份及画风参考，按用户指定的赤木律子着装影响设计紫色、黑灰配色与银色圆环元素。用户批准后原样导入`assets/characters/{spring_summer_casual_v1,winter_casual_v1}/visiting_maya/neutral.png`，均1024×1536 RGBA。来源、SHA-256、提示词及验证记录见`research/imports/visiting_maya_casual_2026-10-12.json`。

## 约会地点背景第一批（2026-10-12）

规划12处普通约会地点，其中意大利小餐馆与河边公园复用既有背景，其余10处由内置ImageGen参考既有小餐馆画风生成，原样保存于`assets/backgrounds/date_locations_v1/`。全部为不透明横向PNG。来源、完整提示词、尺寸与SHA-256见`research/imports/date_locations_v1_2026-10-12.json`，规划与待办见`docs/date_locations_plan.md`，预览见`docs/date_locations_gallery.html`。本批仅制作素材，新图尚未注册为游戏可选地点；酒店为独立剧情特殊地点，未纳入本批。

## 酒店剧情约会背景（2026-10-12）

用户要求补绘酒店背景。内置ImageGen以本批咖啡店为画风参考生成无人物夜间客房，原样保存于`assets/backgrounds/date_locations_v1/hotel_room_night.png`。来源、尺寸、SHA-256与完整提示词见`research/imports/hotel_date_background_2026-10-12.json`。该图仅供剧情特殊约会使用，尚未注册或开放普通约会入口。

## 酒店背景修改稿 v2（2026-10-12）

内置ImageGen依据用户反馈，以旧酒店背景为修改对象，调整为玫瑰暖光、纱帘与弧形软包的精品love hotel客房。保存于`assets/backgrounds/date_locations_v1/hotel_room_night_v2.png`，旧版保留；完整提示词、来源及哈希见`research/imports/hotel_date_background_v2_2026-10-12.json`。待审阅，未修改游戏逻辑。

## 四季限定约会背景（2026-10-12）

内置ImageGen参考既有海滨步道画风绘制赏樱日式庭院、夏日沙滩、红叶古寺和滑雪场四张无人物CG，原样保存于`assets/backgrounds/date_locations_v1/`。PNG可读、不透明，复制哈希一致。完整提示词、来源和尺寸见`research/imports/seasonal_date_backgrounds_2026-10-12.json`。待审阅，未接入游戏季节筛选逻辑。

## 约会场景统一接入（2026-10-12）

12处常驻、4处季节限定和酒店v2均已注册到`data/backgrounds.json`与`data/events/date_locations.json`；旧酒店v1仅保留历史稿。普通地点按月份开放，酒店标记`story_only`。中英文UI及四季常服显示已验证，5510项季节约会测试、17项周日测试、689条数据校验通过；详情和截图见`docs/date_locations_plan.md`及`docs/qa/date_locations_2026-10-12/`。

## 麻生优子用户提供 CG 导入（2026-10-12）

按用户给定顺序导入全裸立绘、诊室全裸查体、剃毛、灌肠、戴手术帽、担架车、导尿、术野消毒、铺巾和下刀前共10项。立绘映射到`examination/shy`；诊室图仅绑定完成脱衣分支；担架车绑定手动病房准备的`complete_manual_ward_preparation`；下刀前图绑定`request_scalpel`，不绑定`incise_*`。术前准备池未限定手术组，以支持随机病例；详细来源、运行路径、尺寸与哈希见`research/imports/patient_yuko_asou_cgs_2026-10-12.json`。

## 通用采血 CG 五图随机池（2026-10-13）

按用户批准接入 `assets/examinations/blood_draw_v2/` 的五张图：01第一版重画、02白制服双人构图、03眼镜患者、04操作近景、05采血后按压棉片。内置 ImageGen 来源、尺寸与 SHA-256 见 `research/imports/blood_draw_variants_2026-10-13_assets.json`，本批提示词见同目录 `blood_draw_variants_2026-10-13_prompts.json`。五张均为1672×941 PNG，复制哈希复核通过；02、04使用修正多余手指后的版本。

`data/examination_cg_pools.json` 的 `blood_draw.paths` 替换为上述五图，复用现有随机单图 splash 逻辑，每次检查等概率抽取一张（各20%），不会串播采血与按棉片两个画面。既有检查映射、中文说明、英文说明和继续按钮保持原样；旧图保留在磁盘，不再进入采血池。Godot已导入五张纹理，716条数据及引用校验通过。

验证：`tools/examination_splash_test.gd` 中英文流程215项、0失败；确认每次只显示一个检查弹窗，点击后只继续一次，真实诊察流程可继续至住院。`git diff --check`通过。

## 通用腹部超声五图随机池（2026-10-13）

沿用用户确认的星见采血CG画风，使用内置ImageGen生成五张1672×941 PNG，保存于 `assets/examinations/abdominal_ultrasound_v2/`：01床边仰卧、02反向构图、03探头近景、04侧卧检查、05护士肩后观察。护士统一纯白制服，覆盖人物形象、取景和检查体位的变化。生成提示词、参考图和原始输出路径分别记录在 `research/imports/abdominal_ultrasound_variants_2026-10-13_prompts.json` 与 `research/imports/abdominal_ultrasound_variants_2026-10-13_assets.json`；保存后SHA-256复核通过，五张均已完成Godot纹理导入。

`abdominal_ultrasound.paths`改为上述五图，沿用单图随机弹窗：各20%，每次检查仅显示一张，点击后继续，不增加串播环节。原图保留但退出池；检查映射、中英文说明和业务逻辑均未修改。716条记录及资源引用校验通过。

验证：中英文 `tools/examination_splash_test.gd` 215项、0失败；单弹窗、单次继续与真实诊察至住院流程通过。`git diff --check`通过。

## 通用 CT 检查五图随机池（2026-10-13）

使用内置ImageGen，参考已批准的白制服采血CG画风制作五张1672×941 PNG：床边准备、正面进机、控制室观察、患者近景、扫描架侧面。保存于 `assets/examinations/ct_scan_v2/`，提示词与来源哈希见 `research/imports/ct_scan_variants_2026-10-13_prompts.json` 和 `research/imports/ct_scan_variants_2026-10-13_assets.json`。五图复制哈希核对通过，Godot导入完成。

`ct_scan.paths`替换为五图，复用每次检查单张随机弹窗，各20%；无连续播放环节。原图保留但退出池，CT检查ID映射及中英文说明保持不变。716条数据和引用校验通过。

验证：中英文 `tools/examination_splash_test.gd` 本轮214项、0失败，检查弹窗及诊察继续流程通过；`git diff --check`通过。

## 通用 MRI 检查五图随机池（2026-10-13）

使用内置ImageGen，参考已批准的白制服采血CG画风制作五张1672×941 PNG：佩戴听力防护、正面进机、控制室观察、患者近景、侧面准备。保存于 `assets/examinations/mri_scan_v2/`，提示词与来源哈希见 `research/imports/mri_scan_variants_2026-10-13_prompts.json` 和 `research/imports/mri_scan_variants_2026-10-13_assets.json`。五张原样复制，尺寸和SHA-256复核通过，Godot纹理导入完成。

`mri_scan.paths`替换为五图，沿用每次检查随机单张弹窗，各20%，不串播。保留原图但退出随机池；既有乳腺、肝脏、盆腔MRI映射及中英文说明未修改。716条数据及引用校验通过。

验证：中英文 `tools/examination_splash_test.gd` 214项、0失败，单弹窗、单次继续及真实诊察至住院流程通过；`git diff --check`通过。headless环境仍有既存macOS证书提示和外部编辑器设置保存权限提示，不影响本次导入及测试完成。

## 通用内镜检查准备五图随机池（2026-10-13）

使用内置ImageGen，以已批准的白制服采血CG为画风参考，制作五张1672×941 PNG：床边说明、调整枕头、指夹监测、患者视角安抚、团队准备。原样保存于 `assets/examinations/endoscopy_preparation_v2/`。提示词、参考图、原始输出路径与SHA-256分别见 `research/imports/endoscopy_preparation_variants_2026-10-13_prompts.json` 和 `research/imports/endoscopy_preparation_variants_2026-10-13_assets.json`。复制哈希与尺寸复核通过，五张Godot纹理导入完成。

`endoscopy_preparation.paths`替换为五图，各20%，每次检查仅显示一张，点击后继续。沿用胃镜、肠镜、支气管镜活检、膀胱镜、直肠镜和超声内镜的既有映射；画面采用通用检查前准备，不描绘特定插镜操作。原图保留但退出池，中英文说明与业务逻辑未修改。

验证：716条数据及引用校验通过；中英文 `tools/examination_splash_test.gd` 215项、0失败，单弹窗、单次继续和真实诊察至住院流程通过；`git diff --check`通过。headless环境仍有既存macOS证书提示及外部编辑器设置保存权限提示，不影响导入和测试完成。

## 岩井善美立绘修正（2026-10-13）

试玩反馈指出门诊常服需要半身构图、术中肖像不应带无菌单。内置ImageGen据原立绘和各术中表情图编辑；门诊neutral改为半身构图，术中tense、pain、near_collapse、anesthetized四态均去除下缘无菌单并保留原状态表情。运行路径原位替换，`patient.json` 映射未改；替换前五张原文件留存在 `research/character_references/patient_iwai_yoshimi/portrait_corrections_2026-10-13/`。原始生成文件、尺寸、SHA-256及静态验证结果见 `research/imports/patient_iwai_yoshimi_portrait_correction_2026-10-13.json`。
# 小夜香V2既有素材复用（2026-10-13）

本轮没有新增／生成美术。换号沿用 `assets/events/character_events/sayaka/phone_contact_closeup.png`；账单与成功鉴赏沿用 `assets/events/character_events/sayaka/lv1_split_bill.png`。办公室、意大利餐馆、公共走廊沿用已注册背景；共同回程按日期月份复用现有四季夜间街景。电话及工作回调为white_coat，约会为casual，保留既有服装解析。技术ID与资源路径不翻译。
