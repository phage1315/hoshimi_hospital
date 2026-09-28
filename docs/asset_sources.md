# 人物素材 / 本地占位测试

用户明确选择 VNDB 原作图片作为本地占位。没有获得再分发授权；此记录不是授权声明，AI 重绘也不把原角色变为原创角色。正式发布前需替换或取得相应许可。

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

2026-09-25 导入用户提供的高卷杏手术室术野消毒专属CG，原样保存为 `assets/events/ward_preparation_v1/patient_ann/skin_disinfection.png`（1280×800，SHA-256 `76aefd28c1f47f122116352a9c762e8d74c4ce5e73ec3344ef52055160dcb347`）。该图在高卷杏成功执行 `skin_disinfection` 动作后以全屏形式显示；其他患者不触发该专属图。

2026-09-25 导入用户提供的高卷杏手术刀准备下刀专属CG，原样保存为 `assets/events/ward_preparation_v1/patient_ann/scalpel_ready.png`（1280×800，SHA-256 `3802c00a4f8917c7005adaafcef7ee719d34dc79ca32be3689a4918fb56dd1cb`）。该图绑定 `request_scalpel`：主刀接过器械护士递来的手术刀后全屏显示，继续后进入助手固定切入部位与正式下刀。

2026-09-25 导入用户提供的奥寺美纪留置导尿专属CG，原样保存为 `assets/events/ward_preparation_v1/patient_miki/urinary_catheterization.png`（1280×800，SHA-256 `8acae8fb5948e1c5b677b0c5187685f58d301da332c2d1231b48a54a31ac6992`）。该图在奥寺美纪成功执行 `urinary_catheterization` 动作后以全屏形式显示；继续后进入导尿后的回应和术野消毒。

2026-09-25 导入用户提供的奥寺美纪基础查体脱衣专属CG，原样保存为 `assets/examinations/patient_miki/full_undress_basic_exam.png`（1280×800，SHA-256 `a2999fbd8956ba640d8fae07180bc9e02ce7d14ae295e548d249216c0be239d7`）。该图用于奥寺美纪基础查体中“权威说服”“温柔说服”和“威胁”三条完成脱衣的分支；放弃脱衣不触发。

2026-09-25 导入用户提供的21张盆腔手术CG，保存为 `assets/surgeries/generic_v1/pelvic/progress_01.png` 至 `progress_21.png`。素材组成盆腔手术进行中通用池，覆盖子宫切除、腹会阴联合直肠切除、开腹卵巢囊肿切除和开腹子宫肌瘤剔除；本项目仅按池内命名复制文件，没有修改原图内容。

2026-09-25 使用内置 ImageGen 将饭村真奈美的药剂师服、刷手服和无菌手术服立绘统一重构为 1024×1536 透明背景的腰部／髋部构图。两套手术服同时修正手术帽戴法：长发完全收进帽内，仅保留少量额前短碎发。文件继续原位保存于 `assets/characters/portrait_pack_v10/pharmacist_manami/`；生成提示与哈希记录见 `research/vndb/pharmacist_manami.json`。

2026-09-25 使用内置 ImageGen 为饭村真奈美增加 `pharmacist/worried` 与 `sterile/worried` 两张紧张差分，保持 1024×1536 透明背景和腰部／髋部构图。白衣差分用于被临时点入手术团队时的慌乱反应；无菌服差分用于助手确认、术中操作、求助与纠正场景。提示与哈希记录继续写入 `research/vndb/pharmacist_manami.json`。

2026-09-26 导入用户提供的利根川安琪立绘表，从上方两行原样裁切六张白色护士服差分，保存于 `assets/characters/portrait_pack_v11/nurse_ange/uniform/`。使用内置 ImageGen 以该人物为身份参考生成四张透明背景无菌手术服差分：长袖圆领无菌手术袍、口罩、长发收入手术帽，仅保留少量金色刘海和贴耳短发鬓，保存于同角色目录的 `sterile/`。第 2 天护士站相识事件完成后，她会常驻手术室并开放团队邀请；完成相识前，排班信息不会令她以匿名角色提前出现。完整提示、画布和哈希见 `research/imports/nurse_ange.json`。

2026-09-26 导入用户提供的杉村弘子六张原作立绘：五张护士服表情与一张粉色便服。素材以边缘连通黑底移除、主体裁切和统一构图方式转为 1024×1536 透明 PNG，保存于 `assets/characters/portrait_pack_v12/nurse_hiroko/`。使用内置 ImageGen 以原作中性护士服图为身份参考，生成 neutral、focused、warm、worried 四张长袖圆领无菌手术服差分；长蓝发完整收入手术帽，仅保留短刘海和少量鬓发。第 2 天手术室前置事件及后续护士站相识完成后，她会在病房与门诊活动并可加入手术团队。完整提示、来源哈希和输出哈希见 `research/imports/nurse_hiroko.json`。

2026-09-26 导入用户提供的仓本千早登场事件素材。`chihaya_escape_corridor.png`（1280×720）作为全屏走廊追逃 CG；后来补充的 `chihaya_shy.png` 与 `chihaya_restrained_portrait.png`（均为 1024×1536 RGBA）作为透明人物立绘，分别用于撞上本多后的羞涩状态和被两名护士抓住的状态。先前两张不透明近景已移入同目录 `sources/`，仅保留来源历史，不再被运行时引用。她在 `data/patients/cameo_patients.json` 登记为仓本千早，但事件中只显示“女患者”，姓名留待未来专属事件解锁。哈希与用途记录见 `research/imports/hiroko_debut_event.json`。

2026-09-26 导入用户提供的六张透明背景手术室患者状态立绘，按附件顺序对应杉村弘子、朝倉美幸、深山佳織、飯村真奈美、神宮寺成美与七瀬恋。原图均为 1024×1536 RGBA，原样保存于 `assets/characters/relationship_patient_v1/<staff_id>/operating_patient/nervous.png`，并登记为人物的 `operating_patient/nervous` 差分。素材暂不进入当前界面；未来用于 Lv4 恋人关系的手术室患者扮演成人事件，并可在 Lv5 临床手术练习流程复用。来源文件、透明度和哈希见 `research/imports/relationship_patient_portraits_v1.json`。

2026-09-26 导入用户提供的本庄萌惠立绘与相识脚本。十张 320×480 护士服 JPEG 表情差分经边缘连通黑底移除后，统一转为 1024×1536 RGBA；换衣室与刷手服立绘保留用户提供的透明图。换衣室裸体立绘同时登记为未来 Lv4 手术室患者 play 的 `operating_patient/nervous`，当前仍只是占位，不开放玩法入口。相识事件不再由普通进入手术室触发，而是开始一次真实术前流程、在“前往更衣区”后进入 `changing` 阶段时自动触发；结束后返回原术前流程继续换衣。事件专用副本位于 `assets/events/character_events/moe/`，保证运行时按立绘而非 splash CG 显示。来源与用途见 `research/imports/nurse_moe.json`。

2026-09-26 导入用户提供的御堂江美子原作参考图，并据此制作 `portrait_pack_v14/doc_emiko` 高清透明立绘。白大褂包含冷静、自信微笑、严厉、惊讶、动摇与温柔六种表情；另制作刷手服及长袖无菌手术袍／口罩版本，供普通场景和手术团队显示。原始参考图保存在该角色的 `sources/` 目录，映射与设计说明见 `research/imports/doc_emiko.json`。

2026-09-26 追加用户提供的御堂江美子透明背景手术患者 play 立绘，原图为 1024×1536 RGBA，登记为 `operating_patient/nervous`。该素材已加入未来 Lv4 手术室患者扮演与 Lv5 临床手术练习的立绘就绪名单；两项玩法仍为未开放占位。

2026-09-27 新增“御堂外科医长办公室”地点，当前复用既有 `assets/backgrounds/v3/surgery_director_office.png` 办公室背景。地点与空置的“外科主任办公室”分别登记，以便御堂个人事件和未来科室管理内容独立触发。
