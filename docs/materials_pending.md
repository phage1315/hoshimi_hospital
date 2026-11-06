# 素材待补清单

## 七瀬恋／神宮寺成美 Lv1 固定事件（2026-11-04）

两篇 V1.1 原稿均已接入并完成中英文原生窗口播放。主角立绘、手术室、病房夜景、共用办公室背景均可加载。尚可补充下列场景素材；当前使用不显示匿名角色立绘的演出，不借用其他角色图片：

| 事件 | 可补素材 | 当前处理 |
| --- | --- | --- |
| 七瀬恋《夜勤病栋（1）》 | 护士站专用夜景背景 | 现有护士站背景在事件中加夜间色调；原始背景文件未改动 |
| 七瀬恋《夜勤病栋（1）》 | 该篇成年匿名女患者的病房立绘 | 18 个患者发言节点显示姓名和对白，暂不显示人物立绘 |
| 神宮寺成美《履历之外》 | 匿名巡回护士立绘 | 1 个发言节点显示姓名和对白，暂不显示人物立绘 |

这三项不影响固定 VN、Lv1 结算或双语正文。若后续要求每个发言节点都有对应角色立绘，须先补上匿名角色素材并重新跑窗口画面验收。证据见 `docs/qa/ren_narumi_lv1_2026_11_04/REPORT.md`。

## 佩特拉高级手术（发行顺序 7，已开放项目内试玩）

三张用户提供的种子图已原样复制到 `assets/characters/advanced_petra_v1/seeds/`，分别为半身、全身和场景参考。种子图只作身份参考；病房、麻醉、俯卧手术台和术后 Day 3 表情差分已接入。用户提供的切皮、开放术野、缝线图已原样复制并映射。用户于 2026-11-02 确定采用三阶段静态术野：切皮、贯穿中段的一张开放术野图、缝合；原设计稿列出的截骨／融合笼／连接棒等独立术野差分不再是本版本的素材缺口或开放门槛。`release_manifest.json` 的 `runtime_ready` 已设为 `true`，项目内正式病例板依既有前置规则开放。

| 素材 | 当前状态 |
| --- | --- |
| 佩特拉病房术前立绘 | 已制作并映射 `assets/characters/advanced_petra_v1/ward.png`；待完整病例播放验收 |
| 佩特拉术后病房立绘 | 复用术前病房立绘制作疲惫、放松表情差分，已映射 `assets/characters/advanced_petra_v1/postop.png`；可见窗口 Day 3 检查点通过 |
| 俯卧全麻团队确认图 | 已按用户要求将铺巾开口扩大至骶尾部与臀部上缘，映射 `assets/characters/advanced_petra_v1/team_confirmation.png`；可见窗口检查点通过 |
| 全麻过场图 | 已对照既有患者麻醉画法重做并映射 `assets/characters/advanced_petra_v1/anesthesia.png`；可见窗口检查点通过 |
| 后正中切口术野 | 用户原图已映射 `assets/surgeries/advanced_fields_v1/petra_posterior_incision.png`，从 T02 显示 |
| 中段静态术野 | 用户提供的开放术野图 `assets/surgeries/advanced_fields_v1/petra_spinal_field.png`，从 T02 切皮结算后贯穿至 T11 |
| 缝合术野 | 用户提供的缝线图 `assets/surgeries/advanced_fields_v1/petra_spinal_closure.png`，在 T12 显示 |

当前三阶段美术方案没有已知待制作素材。`runtime_ready` 是正式病例板准入开关，已开放项目内试玩；可见窗口病例板、术后、麻醉、团队及 T02 切皮检查点通过，尚未执行完整病例逐步播放。截图见 `docs/qa/petra_art_visible_2026_11_02/`。设计稿中的医学顾问复核神经监测、Day 1／Day 3 文本确认和数值平衡仍作为内容验收记录，不再把额外术野差分列作必需美术。

核对日期：2026-11-02。范围：当前朝仓 Lv3／Lv4／Free H、医护高级手术 V2.3、武见妙 Lv1／Lv2 的已知素材问题；不是全项目素材普查。文件存在、资源接入、运行验收与作者美术认可应分别记录。

## 已完成：朝仓 Free H

目标目录：`assets/h/nurse_yui/`。`body_map.png`、`scene_cg.png`、`aftercare_cg.png` 与六种正式头像均已接入；Profile、Flow、Context、九区热区、关系资格和正式预约现已完整接通。

| 状态 | 素材 | 目标文件 | 后续处理 |
| --- | --- | --- | --- |
| 已提供并接入 | 第一阶段触摸底图 | `body_map.png` | 用户指定原图已原样导入，实际尺寸 1024×1520；九区 14 个多边形已按最终图标定并通过命中／背景漏点／优先级验证 |
| 已提供并接入 | 第二阶段 CG | `scene_cg.png` | 用户指定原图已原样导入，1520×1024；中英文正式 Runner 显示通过 |
| 已提供并接入 | 事后 CG | `aftercare_cg.png` | 用户指定原图已原样导入，1520×1024；中英文两句收尾显示及次日返回通过 |
| 已提供并接入 | neutral：默认状态 | `portrait_neutral.png` | 用户指定 V2 原图原样复制，1408×1152 |
| 已制作并接入 | annoyed：不悦、皱眉 | `portrait_annoyed.png` | 以 V2 neutral／peak 为固定端点生成；对应 low 档 |
| 已制作并接入 | pleased：轻微愉悦、放松 | `portrait_pleased.png` | 以 V2 neutral／peak 为固定端点生成；对应 mild 档 |
| 已制作并接入 | flustered：害羞、慌乱、不知所措 | `portrait_flustered.png` | 以 V2 neutral／peak 为固定端点生成；对应 strong 档，低于 MAX |
| 已制作并接入 | delighted：明显愉悦、喜悦 | `portrait_delighted.png` | 以 V2 neutral／peak 为固定端点生成；对应 favorite 档，低于 MAX |
| 已提供并接入 | peak：最高强度反应 | `portrait_peak.png` | 用户指定 V2 MAX 原图原样复制，1408×1152 |

朝仓 Free H 当前 **没有已知待补图片或数据**。`data/h/nurse_yui/h_bodymap.json` 已标为 `final`，Registry／Context 已标为 `ready`。2026-11-02 使用可见 macOS Godot 窗口，从正式人员页预约跑完中文温柔分支及英文强烈分支；九区、六种头像、MAX、二阶段、手动结束、事后两句及次日安全边界均通过。证据见 `docs/qa/miyuki_free_h_native_2026_11_02/`。

## 武见妙事件患者立绘

| 事件 | 人物 | 当前实现 | 待补内容 |
| --- | --- | --- | --- |
| Lv1 | 通用女患者 `patient_generic` | 已接入 2 个患者发言节点 | 术中横向裸肩头像 `embarrassed_strain/pain_crying` 共 2 张；使用用户指定的棕发棕眼种子图，待运行时中英文显示复核 |
| Lv2 | 浅上藤乃 `patient_fujino` | 已接入 30 个患者发言节点 | 门诊 `neutral/worried`、术中横向裸肩头像 `shy/tense/surprised/pain/crying`、术后病房 `apologetic/relieved` 共 9 张；待运行时中英文显示复核 |

Lv1 通用女患者与 Lv2 浅上藤乃均已由用户提供的种子图制作并映射专属差分，不再列为待制作素材；后续只保留运行时显示与作者美术验收状态。

依据：`data/staff/doc_takemi/lv1_events.json`、`data/staff/doc_takemi/lv2_events.json`。

## 已核对：朝仓 Lv3

**当前未发现必需立绘／背景缺口。**

- 更衣室两种年轻护士分支及约会段的实际立绘引用均存在；包含朝仓无帽刷手服修订发型、戴帽差分、常服表情和对应年轻护士差分。
- 使用午后广场、更衣区、走廊、咖啡小餐厅、傍晚河边步道背景。
- 电话段 B001–B033 不显示朝仓立绘是既定画外演出，不是缺图。
- 之前反馈的无帽发型与立绘大小问题已有修正记录，不再列为待制作素材。
- **尚无独立 CG**：牵手目前以原文旁白和伸手姿态立绘呈现。独立约会／牵手 CG 可作为后续可选增强，但尚未确定制作任务，不算阻塞事件的缺图。

本次重跑 `python3 tools/miyuki_lv3_source_audit.py` 通过：410 个节点，覆盖双语、原文、说话人、顺序、服装与电话演出，并检查引用立绘文件存在。本次为静态复核，未重跑 Godot 实机；既有实机记录见 [Lv3 接入验收](miyuki_lv3_integration_2026-10-30.md)。

## 不应重复列为缺失的项目

- 朝仓 Lv4：粉红护士服已补 `neutral/mischievous/focused/surprised/shy/affectionate` 六态并按节点映射；私密段落 neutral 头像和私密诊室背景已有接入记录。Free H Runner 的底图、二阶段 CG、事后 CG 与六种头像均已接入；仅九区热区标定及完整运行验收仍未完成。
- 音乐与音效：用户已允许本轮忽略，不作为开放阻塞项。
- 医护高级手术 V2.3：小夜香、芹香的当前必需资源检查通过；其余 22 人已预置双语剧本，素材与患者档案缺口见下节，不能当作已开放。

当前功能与测试记录见 [朝仓／武见妙接入状态](implementation_status_2026_11_02_miyuki_takemi.md)。收到新素材后，应更新本清单中的提供、接入与验证状态，保留尚未验证的限制。

## 医护高级手术 V2.3：其余 22 人开放前待补

24 人双语正文均已接入共享 Runner 数据，覆盖邀请、术前夜、私密段落、事后、成功和失败六段。仅小夜香、芹香具有现行正式患者资格；本次不新增其他人的资格或提前开放 Lv5。

以下为 Godot 实际资源映射检查结果，**“待接入”表示该显示接口未就绪，不代表仓库中绝对没有可复用图片**。普通医护制服不能代替患者病房立绘。所有 22 人均待登记 Staff-as-Patient profile 与对应 Lv5 正式前置；鹰野另缺医护角色档案。

| 人物（原稿标签） | ID | 病房立绘 | 私密 neutral 头像 | 全麻头像 | 四种体位图 |
|---|---|---|---|---|---|
| 御堂 | `doc_emiko` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 佳織 | `doc_rei` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 明日香 | `doc_asuka` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 阿尔托莉雅 | `doc_artoria` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 弘子 | `nurse_hiroko` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 皐月 | `nurse_satsuki` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 阿库娅 | `doc_aqua` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 美佳 | `nurse_rin` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 成美 | `doc_aoi` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 恋 | `nurse_haru` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 詩織 | `doc_shiori` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 美幸 | `nurse_yui` | SFW 已接入，原生待验收 | 已加载 | SFW 已接入，原生待验收 | 四张 SFW 已入库且 Godot 可加载，Lv5 可见窗口待验收；胸部可由用户后续替换 NSFW 图 |
| 遥凑 | `doc_minato` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 萌恵 | `nurse_moe` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 真奈美 | `pharmacist_manami` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 留美 | `nurse_iwasaki_rumi` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 栞 | `nurse_yoneda_shiori` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 愛実 | `nurse_sonoda_itsumi` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 狩谷 | `nurse_kariya_megumi` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 冴子 | `nurse_hikami_saeko` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 武見 | `doc_takemi` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |
| 鹰野护士 | `nurse_takano_miyo` | 待接入 | 待接入 | 待接入 | 腹部／胸部／侧卧／俯卧均待接入 |

逐角色验收命令及覆盖范围见 [Staff-as-Patient / Lv5 交付清单](staff_as_patient_checklist.md)。QA 明细由 `tools/staff_patient_lv5_readiness_test.gd` 输出至 `/tmp/hoshimi_staff_patient_lv5_readiness.json`；此文件仅为缺口报告，不是玩家存档。

## 本轮实测复核（2026-11-02）

已重新运行真实章节适配器与资源加载检查：24 人、六段双语正文全部可由共享 Runner 读取；仅小夜香、芹香通过正式患者档案与素材就绪检查，其余 22 人继续按上表补齐，未提前开放。

逐角色机器核验结果：[staff_patient_readiness.json](qa/daydream_and_staff_review_2026_11_02/staff_patient_readiness.json)。Readiness 共 1403 项、0 失败；正式两人的完整流程回归共 1240 项、0 失败。未开放角色存在缺口是预期结果，不等于其素材已通过验收。每次开放相应 Lv5 时必须重新运行交付清单中的检查，缺图或缺档案不得标记为开放完成。
