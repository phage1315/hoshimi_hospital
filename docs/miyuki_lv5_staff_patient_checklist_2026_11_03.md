# 朝仓美幸 Lv5 → Staff-as-Patient 交付清单

核对时间：2026-11-03。角色 ID 为 `nurse_yui`。本清单第 1–4 节记录实装前的需求基线；2026-11-03 实装后的准确状态见第 5 节。素材状态区分“已有可复用文件”与“已经接入患者显示键”；来源分类依据导入登记，不凭文件名或画面观感推断。

## 1. 已有基础

| 项目 | 当前状态 |
| --- | --- |
| 角色资料 | `data/staff/nurse_yui/profile.json` 已有；Lv1–Lv4 已实装，Lv4 `miyuki_lv4_inspection` 与 Free H 已接通。 |
| Lv5 关系槽 | `data/staff/nurse_yui/relationship.json` 的目标 Lv5 仍为 `planned`、`event_id` 为空；现有要求为熟悉度 75、玩家 skill 70、本人参与完成至少 1 次无麻醉手术、3 天冷却。 |
| 高级医护患者 V2.3 台词 | `data/advanced_surgery/staff_patient/stories.json` 已有美幸的 `consult/night/dark/after/success/failure` 六段，共 42 条角色专属双语行；共享 `common/repeat` 另行复用。剧本预置不等于正式解锁。 |
| Free H 私密头像 | `assets/h/nurse_yui/portrait_neutral.png` 已存在并可作为 `h_neutral` 来源；六态及 Free H CG 属于已有 Free H 资源，不要求重复制作。 |
| 既有患者候选图 | 原 `operating_patient/nervous` 文件保留，未被本轮 SFW 成图覆盖。术中医护岗位头像 `intraoperative_avatar/neutral` 也仍保留；它与新接入的全麻患者头像用途不同。 |
| Lv5 bonus CG | `assets/events/character_events/yui/lv5_staff_as_patient_bonus_v1.png` 文件已登记，`runtime_connected=false` 且 `trigger=null`。只有新 Lv5 剧本明确指定出现节点时才连接；它不代替手术所需图。 |

## 2. Lv5 剧本与患者数据

- [ ] 提供 Lv5 原稿及英文版本，明确事件标题、完整节点／选项／说话人／顺序、开始与完成条件、分支结算及美术调用；导入时逐句核对，不从 V2.3 预置台词反推 Lv5 剧情。
- [ ] 将 `relationship.json` 的 Lv5 槽绑定真实事件 ID 并标为 `authored`，保留或按新剧本明确要求调整现有数值前置；完成后由真实事件结算 rank history 和 `unlock_clinical_practice_patient`，不能靠把关系数值设成 5。
- [ ] 在 `data/staff_patient_profiles.json` 注册 `nurse_yui`，设定 `required_completed_rank: 5`、授权 flag、性格／称呼上下文、邀请与术前回应（可复用既有性格对白组并作角色专属覆盖）；中文、英文都要有对应数据。只在原稿提供或用户授权的范围内补写专属句子。
- [ ] 核对 `staff_patient_unlocked`、`free_h_unlocked`、小夜香 Part C 全局批准与本人 Lv5 完成事实同时满足；首次／重复手术、取消预约、患者不得进入本人手术团队及 100%→50%→0% 经验结算沿用共享 Runner。
- [ ] 将新剧本引用的 bonus CG、背景、表情键逐项映射；没有引用的 CG 保持独立登记。核对英文标题、提示、选项、画廊／完成文本。

## 3. 患者美术交付与映射

下表的 SFW／NSFW 是**制作与交付路线**。朝仓四张患者专属手术台图先全部制作 SFW 运行版；之后只有胸部图预留用户提供的 NSFW 替换位。俯卧图按佩特拉的俯卧构图，露出背部、尾骨及臀部手术区域，仍走 Codex 生成的 SFW 路线。现有小夜香／芹香的运行图来源只作范例，不强制朝仓照搬。

| 运行键／文件 | 类别与来源 | 当前状态 | 开放前处理 |
| --- | --- | --- | --- |
| `ward/neutral`、`smile`、`brave`、`worried`、`afraid`、`crying` | SFW：Codex 生成 | **六态已入库并映射，待 Lv5 原生显示验收** | 病房患者服全身立绘；差分保持同构图。 |
| `operating_table/awake`、`tense`、`afraid`、`anesthetized` | SFW：Codex 生成 | **四态已入库并映射，待 Lv5 原生显示验收** | 普通手术全台俯视图：手术帽、覆盖单、完整台面和双脚；与对话头像分开。 |
| `operating_table_lithotomy/awake`、`tense`、`afraid`、`anesthetized` | SFW：Codex 生成 | **四态已入库并映射，待 Lv5 原生显示验收** | 截石位全台俯视；覆盖单与支腿架保持同构图，四态仅改变面部。 |
| `h_neutral` | 既有 H 资源：用户提供的 neutral 原图 | **已有可加载来源** | 复用 Free H neutral；在患者夜间段落检查比例、裁切和遮挡，不重复制作。 |
| `splash/general_anesthesia` | SFW：Codex 生成 | **已入库并映射，待 Lv5 原生显示验收** | 全麻过场横图；独立于右侧头像，须在实际流程中确认显示时机。 |
| `intraoperative/tense`、`pain`、`near_collapse`、`anesthetized` | SFW：Codex 生成 | **四态已入库并映射，待 Lv5 原生显示验收** | 右侧患者对话头像：手术帽、头颈、裸肩和锁骨；无菌巾不入镜。与台面图和医护岗位头像区分。 |
| `abdominal.png` | SFW：Codex 生成 | **已入库，待 Lv5 原生显示验收** | 腹部手术台横图；用户标注后将开窗缩至脐周范围。用于 Whipple、盆腔术式，及体位映射完成后的复杂腹部重建。 |
| `chest.png` | SFW：Codex 生成；以后可替换为用户提供的 NSFW 图 | **已入库，待 Lv5 原生显示验收** | 仰卧胸部手术台横图；当前 Ebstein 术式使用此体位。替换时保留 SFW 原图和来源登记。 |
| `lateral.png` | SFW：Codex 生成 | **已入库，待 Lv5 原生显示验收** | 侧卧胸部手术台横图；当前肺叶切除使用，降胸主动脉术式尚待显式映射。 |
| `prone.png` | SFW：Codex 生成 | **已入库，待 Lv5 原生显示验收** | 俯卧手术台横图，按佩特拉已完成图的范围露出背部至尾骨、臀部；佩特拉胸腰椎术式尚待显式映射。 |

现有小夜香、芹香两人的 `chest.png` 和 `prone.png` 运行文件均登记为用户提供，SFW 参考图保留在 `assets/references/advanced_staff_patient_sfw_v1/`；两人的 `abdominal.png`、`lateral.png` 运行文件登记为 Codex 生成。这是旧角色的实际来源，**不是**朝仓的必交规则。朝仓 Free H 的 `body_map.png`、`scene_cg.png`、`aftercare_cg.png` 是用户已提供的 H 资源，属于其他功能，**不在**本次 Staff-as-Patient 新增手术美术缺口内。Lv5 bonus CG 已有文件，但来源未在现行 manifest 中登记，且仍未接入；不要把它计作已完成的手术图。

**作者另行提供的 NSFW 素材：** `ward_preparation/shy` 为病房准备全裸立绘，当前未接入。它不在上表的 SFW 制作清单或 23 项 SFW 自动测试中；收到用户图片后再按指定映射接入。

四张高级术式 SFW 台面图已放入 `assets/characters/advanced_staff_patient_v1/nurse_yui/`，并在 `data/advanced_surgery/staff_patient/assets.json` 记录路径、来源和 SHA-256。病房六态、普通手术全台俯视四态、术中露肩头像四态位于 `assets/characters/relationship_patient_v2/nurse_yui/`，映射于 `data/staff/nurse_yui/profile.json`；来源和 SHA-256 见 `research/imports/nurse_yui_staff_patient_sfw_v2_2026-11-03.json`。全麻过场继续使用 v1 `splash/general_anesthesia`。先前带无菌巾的两张头像留在 v1，并复制到 `assets/references/miyuki_staff_patient_v1/`，不再作为这两种运行键使用。这些资源不改变正式开放状态。所有图还须在实际手术窗口确认正确体位、比例与不遮挡对白。共享术野图按术式复用，未要求为朝仓另造切皮／缝合图；新 Lv5 剧本若明确指定角色专属 CG，则按节点另列。用户之后提供的 NSFW 系列按明确节点另行接入，不覆盖本批 SFW 原件。

## 4. 当前代码层缺口与验收

2026-11-03 晚间收到 Lv5 中文 V4 原稿与相模大野千惠的五张参考图。用户确认千惠在本项目中为 **22 岁**，并授权用参考图生成 SFW 立绘及由 Codex 翻译英文。原稿已原样保存于 `research/source_scripts/HOSHIMI_ASAKURA_MIYUKI_LV5_MY_TURN_ON_THE_TABLE_CN_CODEX_READY_V4.md`。逐节点英文工作稿见 `research/translations/miyuki_lv5_en_working.md`，覆盖原稿 177 个节点、标题、说话人及三组选项；尚未接入运行时或完成英文实机审计。千惠病房半身短袖患者袍（保留腰侧系带）和无枕头、裸肩的术中紧张／羞耻／剧痛头像已作为**待验收草稿**保存于 `assets/characters/patient_sagamiono_chie_lv5_v1/`；来源与校验和见 `research/imports/patient_sagamiono_chie_lv5_2026-11-03.json`。四张图尚未绑定事件节点，不代表千惠其余手术画面已齐全。原稿 Part A 的全裸转运与手术场景不能用病房患者袍图静默代替；对应用户素材仍待指定。

2026-11-03 先前四张图入库并由 Godot 导入后，`tools/staff_patient_lv5_readiness_test.gd` 为 **1403 项、0 失败**，朝仓仍为 `ready=false`，缺 `staff_patient_profile`。之后根据患者矩阵补齐本轮 14 张 v2 图，并把 `operating_table/*` 与 `intraoperative/*` 分开。Godot 4.5.1 headless 编辑器导入成功；独立 Godot 纹理加载检查中，14/14 张均返回预期尺寸；10 张透明立绘角点 alpha 均为 0。现在另补齐截石位手术台四态，来源和 SHA-256 见 `research/imports/nurse_yui_staff_patient_lithotomy_sfw_2026-11-03.json`；Godot 导入成功，统一测试 `tools/patient_sfw_asset_test.gd -- --kind staff --id nurse_yui` 检查 **23 项、0 缺失**。这些 headless 检查不等于患者开放或可见窗口验收。病房准备全裸图仍由用户提供，另列 NSFW 缺口。`tools/staff_patient_lv5_readiness.gd` 已增加麻醉 splash 强制检查。全项目 `tools/validate_data.py` 仍因现有背景、事件 schema 等其他错误退出，详见 `/private/tmp/miyuki_patient_v2_validate_data.log`。

另有共享映射缺口：`procedure_poses.json` 只覆盖 4 个术式，而 `release_manifest.json` 当前有 7 个 `runtime_ready` 高级术式。复杂腹部重建、降胸主动脉置换和佩特拉胸腰椎矫正若可在患者病例板出现，须先补相应体位映射并做原生窗口验收；不要让 `team_confirmation` 静默为空图。

交付后依次运行原文逐句 audit、`advanced_staff_patient_source_audit.py`、`staff_patient_lv5_readiness_test.gd`、`advanced_staff_patient_test.gd`、`narrative_localization_test.py`、`localization_audit.py`，再以可见 Godot 窗口走完朝仓首次成功、失败、重复预约及中英文路径。测试前置只用内存或隔离环境；事件中仍禁止保存，最终只在医院导览／周日安全界面存必要事实。

## 5. 2026-11-03 实装后状态与剩余素材

- **Lv5 已开放：** `miyuki_lv5_chie_operation`、`miyuki_lv5_my_turn_on_the_table`、`miyuki_lv5_capable_do_more` 三段已接入。原稿 177 个编号节点按原顺序对应 189 个运行页；12 个同时含旁白和角色发言的编号拆成相邻显示页，原文字句未改。Part B 完成才结算 Lv5 和患者资格；Part C 不重复结算。
- **患者入口已开放：** `data/staff_patient_profiles.json` 已注册 `nurse_yui`，由真实 Lv5 完成事实与全局批准 flag 控制。共享 `staff_patient_view.gd` 显示邀请按钮，`can_invite_staff_patient()` 和 `invite_staff_patient()` 在测试中实际通过；沿用共享术前、手术与重复练习逻辑。
- **患者双语台词已安装：** 用户原件保存在 `research/source_scripts/HOSHIMI_ASAKURA_MIYUKI_STAFF_AS_PATIENT_DIALOGUES_CN_EN_V1.md`；3 条普通邀请、已核实术式 ID 的专属邀请、28 条反应、13 组双变体、50 个交互池的 106 条动作回应及术前详细说明提问均按原文映射。两个住院台词仅保存在档案中，未强行挂到错误阶段。
- **第 50 池已核实接通：** 原稿把 `strain_pain_traction_02` 暂缓，是因为当时无部位限制的原按钮写了“放松腹部”；当前共享按钮已经是跨部位的“放松紧绷的部位”，故可安全接入原稿完整患者文案。导入器检查该按钮不会退回腹部限定措辞。
- **待确认的文字钩子：** 原稿 D 段 5 条术后专属台词尚无已核实的共享患者发言窗口，未用错位替代。其中清醒成功和全麻苏醒两句需要区分实际麻醉状态及真实苏醒时间；安全中止句只应在真实中止路径播出；术后病房两句目前无通用恢复段落。其他未明确指定术式 ID 的邀请分类保持普通邀请回退。以上原文保留，待对应技术钩子确定后接通。
- **SFW 资源：** 朝仓病房六态、普通手术台四态、截石位四态、全麻 splash、术中露肩四态及四张高级术式台面图已入库映射。千惠短袖患者袍病房立绘和术中三态已入库，术中三态在 Part A 说话节点使用；Part A 的入室、控制器展示与交接、首刀、开腹坚持和术毕回收 CG 已于 2026-11-04 接入，待原生窗口视觉验收。

## 2026-11-04 Part A CG 接入

千惠 Part A 已按原稿节点接入六组 CG：入室转运 `n002-n005`、控制器展示 `n034-n045`、交接特写 `n046`、首刀 `n055-n056`、开腹坚持 `n058-n067`、术毕回收 `n070-n072`。运行映射、来源、尺寸和 SHA-256 见 `research/imports/miyuki_lv5_part_a_cg_2026-11-04.json`。本次只增加 `cg_path`／`cg_fit`，未修改剧情正文、说话人、选项或顺序；Godot 自动回归通过后仍需原生窗口视觉验收。
- **用户指定 NSFW 已接入：** 朝仓 `ward_preparation/shy` 病房准备图和高级手术 `chest.png` 胸部台面图已按附件原样导入并映射；旧 SFW 胸部图保留为 `sfw_reference`。来源、尺寸与 SHA-256 见 `research/imports/miyuki_staff_patient_nsfw_2026-11-03.json`。其他可选 NSFW 画面仍由用户按需指定，不计入当前患者素材必需矩阵。
- **体位映射补齐：** 7 个当前 `runtime_ready` 的高级术式现均有显式台面体位：复杂腹部重建用 `abdominal`、降胸主动脉置换用 `lateral`、佩特拉胸腰椎矫正用 `prone`；这些只复用既有图，不另造角色素材。朝仓必需的 23 项 SFW 基础资源和本次两张指定图均已能由 Godot 加载；实际全程构图仍以可见窗口验收为准。
- **原生显示验证：** 可见 Godot 窗口依次通过中文版、英文版 A→B→C 共 356 个显示页及 2,117 次断言，并实际点击朝仓档案的患者邀请按钮、检查邀请弹窗；走廊、手术室和护士制服映射已在实际截图核对。证据为 `reports/native/miyuki_lv5_2026_11_03/`。本次实际选择了每处分支的首选项；其他选项已在 1,475 次 headless 断言中走通，尚未逐一作可见窗口验收。患者正式手术的成功、失败和重复预约分支亦待单独原生验收。

### 2026-11-04 患者路径补充验收

使用可见 Godot 窗口及隔离内存前置，分别以中文、英文走通朝仓的患者邀请→病房→普通阑尾手术→成功结果→返回，以及高级病例板→团队确认→术前咨询→夜间段落→全麻过场→胸部运行图→Ebstein 全 13 阶段→术后返回。驱动脚本为 `tools/miyuki_patient_native_routes_test.gd`；[截图和报告](qa/miyuki_patient_native_2026_11_03/report.json)记录 871 项检查、0 失败、366 次合成鼠标输入。两种语言的胸部台面均断言加载 `advanced_staff_patient_v1/nurse_yui/chest.png`。测试采用可见窗口的合成 GUI 输入，团队角色选择由隔离夹具准备；不写入玩家存档。普通手术失败、患者再次预约及高级手术失败尚未在本轮可见窗口逐条验收，自动回归另有覆盖。

## 2026-11-05 Part B SFW CG 接入

经用户明确授权，Part B 已生成并接入五组 SFW CG：手术室门口邀请 `n091-n095`、完整护士服躺台演示 `n102-n108`、无影灯下的患者视角谈话 `n109A-n126`、整理衣着后的正式手术请求 `n131-n145B`、挽臂离开 `n146-n149`。因分支和混合旁白拆页，共覆盖 59 个运行页。B4 `n127-n130` 不在本次 SFW 生成授权内，继续使用原稿指定的淡黑演出，未生成或接入替代 CG。

五张成图统一为 1672×941 PNG；生成提示摘要、引用素材、节点范围、文件大小及 SHA-256 见 `research/imports/miyuki_lv5_part_b_cg_2026-11-05.json`。本轮只新增 CG 路径、显示适配和自动测试，不改正文、选项、说话人、顺序或结算。
