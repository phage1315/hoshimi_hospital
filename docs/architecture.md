# 架构与决策

## 内容 → 会话 → 表现
`data/manifest.json` 是加载入口。`ContentLoader` 使用 FileAccess / JSON 读取只读定义并检查顶层结构、重复 ID 与解析错误。运行时失败会显示错误页面，而不是悄悄生成空数据。完整字段和引用校验由 `tools/validate_data.py` 在开发阶段完成；发布前必须运行它。运行时加载器不是完整 Schema 解释器，暂不支持不受信任的模组。

`DialogueSession` 是 RefCounted 状态对象：建立节点索引、记录当前节点并根据选择推进。它不持有 UI 控件，也不知道角色姓名。`@map` 是本阶段唯一的导航终点。未来新增事件效果时应由独立状态层执行，不在按钮回调里计算病例或关系。

`app.gd` 负责标题、对话、地点导航、人物档案和人物事件等页面；重复的文字和按钮封装为小函数。页面切换销毁旧控件。复杂流程的状态转换由独立会话对象解释，内容仍留在 JSON。

`data/backgrounds.json` 保存稳定背景 ID 与资源路径；地点、序章、门诊及术前节点通过 `background_id` 引用。`app.gd` 只执行通用查找和渲染，不再维护场景到文件的硬编码映射。`backdrop.gd` 的几何走廊和人物剪影仅在背景或人物资源缺失时回退使用。

## 为什么 project.godot 在仓库根
Godot 的 `res://` 以 project.godot 所在目录为根。若只把工程文件放在 godot/ 子目录，外侧 data/ 与 assets/ 的导入和发布需要额外复制。当前将入口放在根目录，引擎脚本仍集中于 godot/，内容既可打包，也可独立迁移。

## 定义与运行状态
JSON 中 relationships、teams 为初始草稿，不能直接修改文件来保存进度。未来运行状态需深拷贝初值，保存到 `user://`；存档带独立版本号，保留稳定 ID。不把关系值写入场景节点，不使用全局可变内容单例。

## 手术扩展

`surgeries.json` 保存每种术式的类别、叙事步骤和患者感受标签；`patient_interactions.json` 保存通用及术式类别患者互动。`PreopSession` 在 `surgery_flow` 阶段按顺序解释 `surgery_step`，在正确团队回应后解析一次患者事件，再解释 `patient_interaction_action`。固定确认、无结果影响的团队交流和单一正确答案判断使用同一套 option 数据。错误答案记录到 `procedure_step_history`，增加 `procedure_corrections`，由助手给出纠正对白并返回原步骤；不会触发患者事件。

界面只读取当前步骤、选项和说话岗位，不包含术式名称判断。以后增加事故时，可在错误 option 上引用稳定的突发事件 ID，再由状态层修改生命体征或转入事故阶段。二级操作未来仍可把 POINT / PATH / AREA 等输入转换为同一事件层；切层以有限状态控制，不做任意伤口几何。

## 发布
本阶段验证编辑器运行，尚未配置签名或导出模板。发布预设需纳入 data/**/*.json 与引用美术，并排除 docs、tools、research；特别要实测导出包中的 FileAccess 读取。相关依据：[Godot 官方导出文档](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html)。系统中文字体跨平台存在差异，正式发布应附带许可清晰的字体。

## 患者队列与转诊

新游戏从所有患者稳定 ID 生成一份随机排列的 `patient_queue`。随机病例与患者顺序分别抽取。手术完成或转诊后，从患者池随机抽取下一名模板，并排除最近出现的两人。已完成手术或已转诊的模板再次入选时，其旧流程被归档后重置为新病例；未完成的跨日住院病例继续原流程，不重置。

随机池模板不建立跨次患者病史。新病例按现有权重与教学解锁条件抽病，允许再次抽中上次疾病；`first_surgery_diagnosis_shock_state` 只记录本轮病例是否已播放首次诊断反应，回收旧病例时清除，新病例重新获得资格。同一病例重绘、跨日和读档保留已播放标记与台词变体；模板静态的既往手术/医学背景条件保持不变。患者、门诊和术前技术 ID 继续复用，不新增永久患者身份或病史绑定。

回收会话前，把其门诊与术前/手术的原始耗时转入全局 `archived_clinical_minutes`；总时钟包含此累计值，并沿用原有加班扣除，避免删除旧会话导致时间倒退或重复计时。这个标量不关联患者；玩家属性收益沿用原有归档，手术经验、术式进度和角色关系保留。快照保存该字段，v35/v36旧存档缺省为0，恢复时纳入时间账本校验；旧版本已经丢失的耗时不猜测补回。

转诊仅适用于当前尚未住院的患者。玩家在门诊选择一名职业为 doctor 的员工后，GameState 将 `患者 ID → 医生 ID` 写入 `patient_referrals`，清除当前病例焦点，并让门诊显示队列中的下一人。已完成的部分问诊记录在本次转诊期间保留作交接记录；该角色以后重新被抽中时，转诊状态与旧病例流程会被清除并生成新病例。住院及术前患者不能通过这个入口跳过。

存档 v11 在患者队列与转诊表之外保存最近两名患者，以及重复病例归档的玩家属性效果。读取时验证队列必须恰好包含全部患者且不得重复，接诊人必须是有效医生，已住院或已完成手术的患者不能同时标记为转诊。旧存档若已经耗尽候诊名单，会自动进入循环抽取。

## M1 实现 / 0.3

- `data/patients/templates/encounter.json` 定义共用阶段、选项、前置线索、回应、耗时和新增记录；`data/patients/<patient_id>/patient.json` 提供人物资料与专属覆盖；病例答案不在 UI 中。
- `EncounterSession` 只解释通用规则：检查前置线索和重复操作、累加时间、添加记录、切换阶段、写入诊断及住院状态。
- 2026-10-13：每次新门诊会话用独立RNG对 `diagnosis` 阶段选项作一次Fisher–Yates排列，仅在 `ui_actions()` 改显示顺序，不改数据定义、技术ID、对白或正确性。完整ID排列保存于会话状态 `diagnosis_action_order`；选错后按原相对顺序过滤已选项，刷新／重返／读档／切换语言不重抽。旧v36状态缺省该字段及v35动作日志按原模板顺序恢复，后续新接诊才随机；读档验证排列无重复／未知／缺失ID。病例回收后新建会话重新抽样，不在患者模板上留历史标记。存档外层版本与安全入口策略保持。
- `GameState` 管理按 encounter ID 索引的会话，以及当前病例和汇总时钟。原始患者 JSON 保持只读；病房按运行状态展示住院信息。
- `ClinicView` 负责左侧对话 / 行动、右侧滚动病历，通过主界面调用会话。原有 VN 页面保持独立。
- 2026-10-13：七名专属护士的诊断纠错对白位于各自 `profile.json` 的 `personal_nurse.diagnosis_corrections`，按 `diagnose_gastro`（不符合证据）／`diagnose_observe`（无法解释全部结果）读取；英文使用同路径本地化键，技术ID不翻译。`GameState.clinic_presentation()` 仅覆盖这两个错误动作的展示，不修改共用病例定义、临床结果或耗时；成美保留原回应，缺少护士覆盖时回退原文。门诊状态可选保存 `diagnosis_feedback_actor_id`，记录当次纠错者，后续换护士不改变已说出口的台词归属；正文仍从当前语言内容读取。下一次有效行动清空该展示上下文。旧存档缺字段时按现有岗位解析说话人，不猜测历史；无效类型／未知员工ID拒绝恢复，外层存档版本和安全入口策略不变。
- `SaveStore` 将 GameState 快照写入 `user://clinic_slot_1.json` 至 `user://clinic_slot_8.json`，先写同目录临时文件、检查错误，再原子替换。位置 1 沿用旧文件名，因此旧版单槽存档无需转换；测试仅写入调用者提供的独立临时路径。

存档 v1 包含 `version`、`content_version`、`active_id` 与各病例的有序 action ID 日志。读取时在临时会话中逐步重放；未知 ID、越阶段操作、重复操作和不满足前置条件的日志会被拒绝，失败不会替换当前状态。记录文本、分钟、诊断与住院状态由定义重建。

这是一种适合小型确定性原型的保存方式。修改已发布动作的语义或耗时会影响重放，因此应同步提升 `CONTENT_VERSION` 或实现迁移。当前手术流程改版为旧版术中日志提供一项确定性迁移：识别已经移除的 `setup_*` 节点（以及全麻分支旧有的 `contact_*` 节点），补入开台、递刀、助手固定和下刀事件，再继续重放仍有效的清醒互动。其他未知 ID、越阶段操作或不兼容内容仍会被拒绝。未来随机数、关系效果等状态引入时需要保存种子或显式事件结果。

## 0.4 / 精简展示与兼容性

阶段可定义 bundles（合并操作）和 auto_record（进入时展开病历），行动可定义 summary（简短结果卡）。EncounterSession.ui_actions 生成当前可见操作、隐藏已完成项目，apply_bundle 先验证整组再执行剩余子行动。日志仍存原子行动 ID；presentation 按日志重建合并后的短反馈，因此保存后加载也保持相同文案。未改变既有动作的耗时、前置条件或结果，CONTENT_VERSION 保持 1。

病历开合、当前显示阶段和已查看记录数是 app 的临时展示状态，读档和新游戏时重置，不影响患者状态。诊断阶段自动展开一次，玩家随后可以收起。内容校验要求合并成员是同阶段、无前置条件、非跳转行动，防止组合产生不可见的死锁。

## 0.5 / 术前会话

共用 `data/patients/templates/preop.json` 与病例内容分离；loader 为索引中的每名患者生成 preop，并通过 encounter_id 指向必须已收住院的病例。PreopSession 解释三类事件：assign（岗位指派）、toggle（准备项目选择）、action（状态推进）。团队资格从原始员工定义读取；患者专属提示来自各自数据包。UI 不计算准备结果。

PreopView 负责短对白、选人控件与项目勾选；PreopStageArt 绘制可替换的原生占位场景。GameState 管理术前会话并汇总时间，按 active_mode 恢复门诊或术前画面。

存档 v2 增加 preops 事件日志、active_mode 和 active_preop_id，保留 v1 读取。新对象重放所有记录、住院条件和团队资格后才替换游戏状态。内容版本仍为 1，因为此前门诊规则与记录 ID 不变；v2 数据结构与 v1 通过明确分支解析。

## 0.6 / 工作日与自由时间日志

GameState 将门诊分钟、术前／手术室分钟和自由时间事件统一汇总为 480 分钟工作日。顶部时间由累计分钟纯计算得到，跨过八小时后进入下一天 09:00。`time_events.json` 提供自由行动与随机对白；休息室把交谈入口放在人物行旁。普通偶遇规则已于2026-10-13更新，见下段，不再按进入次数重新抽人。

2026-10-14 普通偶遇：`GameState.staff_present_at()` 先筛已相识角色及既有周日值班名单，`PresenceResolver` 按每人／日期／小时抽签，80%选一个固定岗位，20%选一个随机地点；所选池为空即不出现。普通随机池排除固定岗位重复项及天台；每人同小时只有一个普通位置。12:00–13:00先照常分配，休息室若无人，再从允许来休息室的合格人物中调入一人，不复制、不再限两人。其他时段不额外抽休息室概率。天台独立每半小时50%出现一名，不占用普通位置；默认所有合格人物可去，仅 `presence.rooftop_enabled: false` 排除，当前只有千鹤关闭。日期／时段与技术ID决定本地随机种子，候选排序；相同世界状态下往返、读档、中英切换不重抽，也不消耗全局随机流。新相识／值班资格改变可影响候选，不增加存档字段。进入不加时间；专属护士看诊及手术团队不受地图位置约束，剧情优先入口保持。普通地点超过四人复用可滚动在场医护抽屉，闲聊仍须本人在场及有对应台词。

2026-10-14 闲谈内容扩充：医护包 `time_events.json` 共21名角色、57个地点入口、160段随机回应。在2026-10-13的51段基础上，本轮追加8名角色的10个入口／30段，原稿为 `docs/source/HOSHIMI_LOCATION_IDLE_CHAT_30_CN_DRAFT_2026-10-14.md`。每段保持一个 `responses` 元素，英文通过 `collections.time_events.<id>.responses.<index>` 同序映射。均30分钟、可重复且无关系／熟悉度效果；不代替微事件。闲谈使用保留整段原文的显式分页及英文单词换行，不根据段内主角回应自动切换姓名栏；成功开始新闲谈时重置页码，重绘不重抽回应。

行动可以超过 17:00，但越过班次终点的部分记为当日加班并在结算时丢弃，不会占用次日工作时间。例如 17:00 开始的八小时手术于凌晨结束，结算后仍进入次日 09:00。日期变化先显示医院夜景转场，玩家确认后才进入下一画面。

2026-10-13 连续诊疗边界（按用户后续确认调整）：问诊/检查不能被一天结束打断；收住院后必须完整显示“已收住院·交接完成”页。未到17:00保持“前往病房”，达到17:00且尚未进入术前时改为“交接患者休息，结束今日工作 →”；只有玩家点击才解除当前接诊焦点并处理离院，住院、病历、队列原样保留，下一工作日从病房继续。不能从进行中的检查、术前、手术或待确认结算页调用此交接出口；开始术前后仍等手术结算与既有术后延续内容结束，显式转诊/手术中止出口保持。加班期间账本虽预留次日09:00，显示与入口仍按待离院工作日处理，不提前弹星期日菜单或次日自动事件。周六交接不承诺周日手术，原休诊规则保持。此调整不改变存档格式或恢复策略、动作耗时及护士交接对白。

存档 v5 的 `time_log` 每项记录稳定事件 ID、触发前累计分钟和随机对白序号，并保存已经丢弃的加班分钟。读取时验证事件存在、时间顺序、非重复限制和最终总时间；旧日志默认使用第一句对白。医院导览的“时间记录”页显示最近七次自由行动。医疗行动继续保存在病例与术前日志中，三者共同推进时钟。

## 患者性格驱动的对白与反应

患者定义现包含主性格、副性格、压力反应、八项稳定特质、四类恐惧倾向和按 action ID 编写的反应文案。PreopSession 在共用动作结算之后只替换展示文本：找得到人物专属反应就使用它，否则回退到 preop 共用文案。玩家选择的数值效果、阶段跳转和手术结果不读取性格资料。

门诊病例使用患者包内的 `outpatient_lines` 对随机病例模板做口吻改写；`diagnosis_reactions` 保存五类术区的首次手术反应；宣布住院、术前与术中使用更具体的 `reaction_lines` 和 `reaction_variants`。患者专属对白因此全部位于同一份 `patient.json`，病例模板只提供疾病、症状与检查结果。患者再次出现并抽取新病例后仍保持相同说话习惯。`expressiveness` 仅调整手术台立绘由紧张转为害怕的显示阈值，压力反应只补充状态说明。

存档 v12 在每次 `surgery_step` 后记录 `flow_acknowledge`。术式选项提交后先单独展示本步团队回应或助手纠正，只保留“继续手术”按钮；确认后才进入患者反应或下一流程步骤。读取 v1–v11 时会在旧的术式步骤后自动补入确认事件，避免团队对白与下一轮选择同时出现。

当前采用每个 action 一句确定文案，事件重放和旧存档无需记录额外随机结果。未来若为同一反应加入多个随机变体，必须把选中的反应 ID 写入事件日志，否则重绘和读档可能改变句子。医护性格、长期患者信任、性格影响选项效果及极端意外仍为后续范围。

## 0.7 / 医护人物事件

2026-10-14 小夜香Lv2节奏稿：沿用 `presentation: authored`、普通继续／自动播放与唯一服装三选一。`character_event_choice` 可选 `next_if_choice: {choice_id, next}` 只查询当前事件已有选择日志，命中覆盖默认 `next`；不读取关系flags，不新增会话状态。选择目标在写入历史前验证，非法目标不改变会话。Lv2门口根据 `lv2_scrubs` 进入10A，否则进入10B，再汇合唯一结尾；schema及数据图校验覆盖两条边。保留 `white_coat` 选择节点与 `ending` 完成节点、原奖励ID／效果、35分钟和原调度条件；扩展既有已完成终点兼容表，让v35/v36旧完成记录保留时间／关系／完成状态，不支持中途恢复、不重发奖励。逐句授权例外和验收见 `docs/qa/sayaka_lv2_pacing_2026-10-14.md`。

2026-10-13 小夜香V2：在现有单说话人节点运行器上增加可选 `presentation: authored|sms`。显式归属的对白不再通过引号猜测说话人，短信使用独立发件人卡片；其他旧事件保持旧渲染路径。整日周日事件可用节点级 `sunday_clock` 显示下午／傍晚演出，账本仍由原Sunday完成命令一次性消耗整天。停止人物事件失败重试；小夜香旧C失败存档只在满足旧终点+Lv0+重试标记时恢复为未触发，旧120分钟转入全局故事时间，已完成成功存档映射终点而不重发效果。具体授权正文调整及兼容范围见 `docs/qa/sayaka_v2_2026-10-13.md`。

CharacterEventSession 是通用的短篇选择树运行器，只认识节点、选项和稳定 ID。GameState 负责解锁条件、关系效果、完成历史、耗时与存档重放；界面只显示当前文本和选择。早期曾为神宮寺成美与七瀬恋各制作四章 Lv1 事件；这八个事件已在人物世界观重构时整体退役，稳定角色 ID 与关系槽位保留，等待新事件写入。

存档 v6 增加 character_events 和 active_character_event_id。进行中的事件、已走分支、关系数值与完成历史均由选择日志重建；v1–v5 存档以初始关系和空事件记录迁移。人物事件跨过 17:00 时沿用工作日结算规则。

存档 v21 增加 `story_time_advance_minutes`，记录人物事件造成的跨日预约跳转。御堂江美子的 Lv0 结束后会据此推进至次日 13:00，并立即进入约定的 Lv1 手术室事件。

正式入口由 GameState.character_events_at 按地点、医院时钟、关系与前置事件筛选，再按 priority 和稳定 ID 排序；地点页只展示第一项候选，以情境句而非章节名邀请玩家进入。时段每天重新开放，未完成事件不会因为某天错过而永久消失。

人物档案的「事件测试」使用独立 CharacterEventSession，不写入 GameState，因此不计时、不改变关系、不解锁鉴赏。事件鉴赏从正式完成记录推导解锁状态；回想同样使用独立会话。gallery.path 为空时显示当前立绘差分构图和 CG 槽位，填入合法图片路径后自动显示专属CG。

### Debug test-save generator

Debug builds expose **Test Save Generator** on the title screen. It writes only to an empty one of the eight normal save slots and uses the same `GameState.snapshot()` / `SaveStore.write_slot()` format as player saves. Special-event and character-event presets can satisfy their authored character, relationship, attribute, flag, prerequisite, cooldown, location-time, and timing gates either immediately or after exactly one additional completed surgery. Optional JSON overrides support `player_attributes`, per-character `relationships`, boolean `story_flags`, surgery `progress`, and prior `special_events`. Generated states remain idle and saveable; the generator never starts an event in progress and never overwrites an occupied slot.

Field reference and override examples: [`docs/test_save_generator.md`](test_save_generator.md).

## 2026-10-11 缺陷复盘与渐进重构建议

本轮问题不只是文本录入遗漏，也暴露了跨模块契约缺失。不建议立即推倒重写；先固定回归门槛，再逐步拆分，保持现有中文剧本与存档格式不变。

1. **导航和时间推进应有单一负责人。** `app.gd` 保存页面回调，`GameState` 与各会话又分别推进时间，导致完成页回调跨日后仍有效。下一步抽出 DayFlow/Navigation 协调器，统一“能否离院、何时结算、次日去哪里”。本轮已统一离院防线和普通次日落地，但未重写整个时间模型。
2. **本地化缺失必须可检测，不能由通用句子伪装完成。** 之前手术通用兜底令不同选项不可区分，且审计没有纳入过渡、记录和特殊对白字段。本轮补齐字段及严格专项测试；下一步把所有玩家可见字段与技术ID在schema中显式区分，并将严格覆盖测试设为CI门槛。
3. **存档保存语义，不保存最终显示句。** 经验历史存中文标签会在切换语言后残留。本轮按稳定ID重建已知记录的显示；后续逐步统一为 `message_key + args`，保留未知旧记录兜底，不盲目替换原文。
4. **资源校验要覆盖加载与触发，而不仅是文件存在。** 新图片存在但未import、准备CG与术后CG池概念混淆，都会造成误诊。本轮增加中英实际加载/派发测试；后续在患者导入验收中统一输出“素材—池ID—动作ID—麻醉条件”清单。
5. **UI与主状态脚本职责过多。** `app.gd`、`game_state.gd`、`preop_session.gd` 合计约1.2万行，页面、存档、成长、流程和资源策略高度集中。已先抽出按钮排版和档案显示模块；下一步按页面、成长、存档与流程边界逐步拆分，复用容器布局，避免继续堆绝对坐标补丁。
6. **测试契约必须同步演进。** 旧测试仍假定读档恢复剧情中途，当前设计却只恢复世界状态。先整理测试矩阵与存档边界，保证CI失败有明确含义；不要以“跑了若干专项”代替全流程验收，也不要为了旧断言改变已确认设计。

本轮逐项结果、待素材与原生窗口验收项见 [`docs/bug_backlog.md`](bug_backlog.md)。

### Save boundary and format migration

Player saves are state-dictionary checkpoints created only from the hospital directory or the Sunday menu. Loading never resumes a surgery, consultation, or narrative node; it rebuilds world state and returns to the appropriate hospital entry screen. The current format is `state_dictionary_v1` (save version 36). Version 35 event-log saves remain readable temporarily through a best-effort compatibility path: unrecognized records are skipped and warnings are reported, rather than blocking the entire load. Once the old-save migration window is closed, that replay path can be removed.
