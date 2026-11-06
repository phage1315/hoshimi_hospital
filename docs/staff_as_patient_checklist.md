# Staff-as-Patient / Lv5 交付清单

现行核验：2026-11-04。新增可作为患者的医护、开放其 Lv5 患者资格时，须逐项检查；不能仅凭剧情或普通患者素材齐全就宣称全部完成。朝仓美幸的本次逐项交付状态见 [朝仓 Lv5 专用清单](miyuki_lv5_staff_patient_checklist_2026_11_03.md)。

## 作者与数据交付

- 明确角色 ID、患者资格前置、关系／称呼上下文、允许术式和首次术后 callback。沿用当前患者注册接口，不复制普通诊疗流程。
- 提供患者专属正文与反应覆盖，标清说话人、顺序、首次／重复条件；提供英文或授权忠实翻译。不得自行补写缺失正文。
- 病房、手术台、术中头像、全麻过场等 SFW 资源按下方固定矩阵逐项检查。`ward_preparation/shy` 等病房准备／检查全裸立绘由作者作为 NSFW 素材提供，不计入 SFW 必交清单；实际剧情引用时另行登记与验证。
- 用户指定的 NSFW CG 按明确映射导入；可选 CG 与必需资源分开登记，不用占位图冒充已完成。

## 普通患者 SFW 立绘矩阵

参照 `docs/qa/patient_kyrie_canaan/sfw_portrait_checklist_2026-10-25.md` 与 `docs/patient_dialogue_portrait_framing.md`，开放新医护患者前逐键核对：

| 场景 | 必需表情键 | 构图 |
|---|---|---|
| 病房 `ward` | `neutral`、`smile`、`brave`、`worried`、`afraid`、`crying` | 同一病号服、站姿、画布与锚点的差分。 |
| 普通手术台 `operating_table` | `awake`、`tense`、`afraid`、`anesthetized` | 全台俯视，铺巾/覆盖单与完整脚部；这是体位图，不是说话人头像。 |
| 截石位手术台 `operating_table_lithotomy` | `awake`、`tense`、`afraid`、`anesthetized` | 截石位全台俯视；当前患者可进入该体位术式。 |
| 术中患者 `intraoperative` | `tense`、`pain`、`near_collapse`、`anesthetized` | 透明背景头肩对话像，手术帽、裸肩和锁骨，无菌巾不入镜；同组表情锁定头部尺寸与肩线。 |
| 全麻过场 `splash` | `general_anesthesia` | 独立横向场景图，不能用全麻头像代替。 |

医护患者 SFW 基础矩阵为 **19 键**；再加四张高级手术体位图，共 **23 项**。普通随机患者额外需要 `outpatient/neutral`，共 **20 个 SFW 键**。当前医护患者可以安排到含截石位的普通术式，因此四张截石位图纳入固定矩阵。两类患者的检查／病房准备全裸立绘均由作者提供，独立于 SFW 检查；Staff-as-Patient 不进入普通门诊检查流程，不强制 `examination/shy`。`h_neutral` 也属作者提供的私密资源，不计入 SFW 项数。

新增或修改患者时运行统一检查（绝对 Godot 路径可替换命令中的 `godot`）：

```sh
godot --headless --path . --script res://tools/patient_sfw_asset_test.gd -- --kind ordinary --id patient_sora
godot --headless --path . --script res://tools/patient_sfw_asset_test.gd -- --kind staff --id nurse_yui
godot --headless --path . --script res://tools/patient_sfw_asset_test.gd -- --all --inventory
```

按 ID 检查会因缺少任一 SFW 键、无效路径或 Godot 无法加载的运行纹理而失败；`--all --inventory` 用于列出现存角色欠账，退出码固定为 0，不应被当作通过门槛。高级手术若运行图为作者替换版，测试直接解码保留的 `sfw_reference`，不要求将参考图导入 Godot。检查不读取或写入玩家存档，也不把 NSFW 项计为 SFW 缺口。图片的构图、身份与遮挡仍需可见窗口验收。

2026-11-04 全项目盘点（32 名普通随机患者、3 名已注册医护患者）共检出 **14 个 SFW 映射缺口**，均为 `operating_table_lithotomy`：`patient_comoli_harcourt` 缺 `afraid`、`anesthetized`；`patient_yuffie_kisaragi` 与 `patient_lust_actress` 各缺四态；`doc_sayaka` 缺四态。朝仓按 ID 检查为 **23 项、0 缺失**。这里仅报告键和文件的技术状态；画面构图还需逐路径窗口验收。

## 必交的四种全麻手术台图

| 映射键 | 用途与构图 | 小夜香／芹香当前运行图来源 | 朝仓当前运行图来源 |
|---|---|---|---|
| `abdominal` | 仰卧腹部手术；铺巾后露出腹部窗口 | SFW：Codex 生成 | SFW：Codex 已生成，按用户红圈缩小开窗 |
| `chest` | 仰卧胸部手术；术区与覆盖范围按用户指定的最终运行图 | NSFW：用户人工提供；SFW 生成参考另存 | NSFW：用户人工提供；SFW 生成参考另存 |
| `lateral` | 侧卧位胸部手术；露侧胸术区，其余身体覆盖 | SFW：Codex 生成 | SFW：Codex 已生成 |
| `prone` | 俯卧位露背；头部有支撑，术区可延伸至尾骨和臀部 | NSFW：用户人工提供；SFW 生成参考另存 | SFW：Codex 已生成，参考佩特拉已完成的俯卧构图 |

来源按 `assets.json` 的 `source` 与 `sfw_reference` 记录，不根据画面推断。朝仓四张 SFW 图均已入库，胸部运行图现为用户提供的版本，原 SFW 图保留。旧角色俯卧图的交付方式不要求朝仓沿用。朝仓 Lv5 与患者邀请入口已开放；正式患者手术的体位图仍须逐项做可见窗口验收。

统一要求：独立 PNG 横图、人物辨识度与既有立绘一致、闭眼全麻表现、手术帽与呼吸设备、铺巾及明确体位。保持原比例显示，不裁切；建议沿用本批约 **1672×941** 或更高的近 16:9 分辨率。运行图使用用户最终指定版本；已留存的 SFW 图仅作独立参考，不覆盖运行图。

当前目录：`assets/characters/advanced_staff_patient_v1/<actor_id>/<pose>.png`。
登记表：`data/advanced_surgery/staff_patient/assets.json`（路径、来源、SHA-256）；术式映射：`procedure_poses.json`。新增术式必须显式指定体位，不能拿另一角色或错误体位图片兜底。

## 接入与验收

### SFW生成参考与作者编辑版本（2026-11-01确认）

小夜香现有四张体位图已独立保留于 `assets/references/advanced_staff_patient_sfw_v1/doc_sayaka/`，对应 `abdominal.png`、`chest.png`、`lateral.png`、`prone.png`。目录内 `manifest.json` 记录来源与 SHA-256；该目录仅作生成参考，不参与 Godot 运行资源导入。

未来制作同类素材，可用 SFW 原图作为体位、构图和覆盖的参考，并结合目标角色本人的外观参考。小夜香、芹香现有的开胸与俯卧运行图是作者手动编辑提供；后续接收作者替换图时，按指定映射更新运行素材与登记表，保留原 SFW 图。朝仓先生成四张 SFW 运行图，俯卧图另参考佩特拉已完成的露臀俯卧构图；只有胸部图预留作者后续替换。

2026-11-01后续交付：小夜香、芹香的运行 `chest.png` 已替换为作者提供的1664×960开胸版本；小夜香四张SFW参考保持不变，芹香原SFW开胸图另存于同级 `doc_serika/chest.png`。登记表中的 `sfw_reference` 指向保留原图；未来生成继续使用SFW参考。

- 核对文件、尺寸、路径、Godot 导入及四种体位实际加载；全麻头部头像与台面图是不同资源，两项都检查。
- `splash/general_anesthesia` 已列入统一 SFW 素材测试；原生窗口仍须验证显示时机。
- 核对 `procedure_poses.json` 覆盖所有会被病例板提供的 `runtime_ready` 术式。2026-11-04 当前 7 个 `runtime_ready` 高级术式均已有显式体位映射；新增术式时继续逐项检查。
- 从医护患者入口邀请；患者不能同时进入本台医护团队。核对预约冲突、助手冷却、合法手术日和复盘日。
- 高级练习仅开放已 CLEAR 且可运行的常规高级术式；经验按角色 × 术式成功次数依次为 100%、50%、0%。失败不增加成功计数。
- 从接受安排到三天演出及最终结算结束，全程禁止保存；仅最终事件级事实进入存档，不保存节点、选择、演出进度、HP 或危机状态。
- 原文逐句核对；中英文标题、正文、说话人、选项、提示齐全。运行原文审计、`narrative_localization_test.py`、`localization_audit.py`。
- 实机检查输入推进、对白可见、说话人与立绘对应、四体位图片、成功／失败返回、重复结算防护及安全边界回存。

相关：[高级术式交付清单](advanced_surgery_content_checklist_v1.md)、[医护术中头像清单](intraoperative_staff_avatar_checklist.md)、[本批实装与验收](advanced_staff_patient_integration_2026-11-01.md)。

同日俯卧版本交付：两人的运行 `prone.png` 已更新为作者提供的1664×960版本，原SFW俯卧图保留于各自参考目录并记录哈希。开胸、俯卧运行版本均不得用作后续生成的基础参考。

## Lv5 开放前的强制回归（2026-11-02）

V2.3 的 24 人剧本已预置。预置正文与开放患者资格是独立状态：2026-11-04 当前小夜香、芹香、朝仓已注册为正式患者。新增 Lv5 患者必须先补齐档案和素材，再运行以下检查；不得以数值关系等级设为 5 代替真实事件前置。

```sh
python3 tools/advanced_staff_patient_source_audit.py
godot --headless --path . --script tools/staff_patient_lv5_readiness_test.gd
godot --headless --path . --script res://tools/patient_sfw_asset_test.gd -- --kind staff --id <new_staff_id>
godot --headless --path . --script tools/advanced_staff_patient_test.gd
python3 tools/narrative_localization_test.py
python3 tools/localization_audit.py
```

- Readiness 测试通过真实章节适配器遍历全部 24 人六个段落，检查非空双语、说话人和场景头像键；未开放角色仅预置，不要求提前制作全部素材。
- 对患者注册表中的**每个人**，强制检查病房立绘、私密 neutral 头像、全麻头像、全部实际 portrait 引用以及腹部／胸部／侧卧／俯卧四种台面图；资源必须能由 Godot 加载为有尺寸的纹理，不能只验证路径字符串。已注册角色缺任何一项即失败。
- 新增的统一 SFW 测试另查 19 个基础键和四张高级体位图，包括截石位四态与全麻 splash；即使角色尚未注册患者资格，也可按 staff ID 单独检查。它不会把作者提供的病房准备／检查全裸图列为 SFW 缺口。
- 中英文患者展示映射均检查；已注册患者的普通手术对白逐字段核对中英结构、非空、中文残留和占位符，缺邀请台词也会失败。真实 Lv5 事件完成事实与必要前置在内存中构造后，验证正式资格。缺章节、缺英文、缺占位符、缺各类头像和体位图均有负向测试。
- 完整流程测试同样从患者注册表动态取人，覆盖首次、重复、跳过、成功、失败、100%／50%／0% 结算及全程禁存档。新增角色不应再只跑小夜香／芹香的硬编码名单。
- 以上是自动化发布验收，不额外改变运行时解锁规则。通过后仍需图形模式逐段检查大小、裁切、对白遮挡及说话人与立绘对应，不能把无头资源加载当成全部视觉验收。

原文映射工具：`tools/advanced_staff_patient_v23_source.py`，只更新 V2.3 的 actors，保留 common／repeat。不要运行旧 V1 导入器覆盖当前数据。原作者英文成美句中的 `揉` 已获用户授权仅补译为 `rub`；原始归档不变。其余正文按原文核对，夜间段落仅为切换头像分为 night／dark，顺序不变。

### 本轮复核记录（2026-11-02）

已验证 24 人共享章节与双语文本（1403 项、0 失败），以及正式注册两人的完整流程（1240 项、0 失败）。缺失资源逐角色结果归档于 [readiness 报告](qa/daydream_and_staff_review_2026_11_02/staff_patient_readiness.json)。新增任何一人的 Lv5 时，须先清空该角色报告中的档案／素材缺口并通过本节回归，才能将其患者开放任务标为完成；仍不可凭数值等级直接解锁。
