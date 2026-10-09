# 人物素材 / 本地占位测试

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

### 东川映見普通患者包（2026-10-05）

- 导入用户提供的五张角色参考及一张透明诊室全裸立绘；角色明确设定为23岁成年女性。
- 使用内置 ImageGen 制作门诊、病房、普通仰卧手术台、截石位手术台、术中反应头像与全身麻醉场景。用户提供的诊室立绘不重绘，原样接入患者专属基础查体池，只在对应检查选择后显示。
- 运行时患者数据：`data/patients/patient_emi_higashikawa/patient.json`。素材、提示摘要与 SHA-256 见 `research/imports/patient_emi_higashikawa_2026-10-05.json`。

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
