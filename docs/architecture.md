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

新游戏从所有患者稳定 ID 生成一份随机排列的 `patient_queue`。随机病例与患者顺序分别抽取。手术完成或转诊后，系统沿队列寻找下一名尚未处理的患者；全部人选处理完毕后，会从患者池继续随机抽取，并排除最近出现的两人。回归患者会获得新的随机病例，其旧流程被归档后重置。

转诊仅适用于当前尚未住院的患者。玩家在门诊选择一名职业为 doctor 的员工后，GameState 将 `患者 ID → 医生 ID` 写入 `patient_referrals`，清除当前病例焦点，并让门诊显示队列中的下一人。已完成的部分问诊记录在本次转诊期间保留作交接记录；该角色以后重新被抽中时，转诊状态与旧病例流程会被清除并生成新病例。住院及术前患者不能通过这个入口跳过。

存档 v11 在患者队列与转诊表之外保存最近两名患者，以及重复病例归档的玩家属性效果。读取时验证队列必须恰好包含全部患者且不得重复，接诊人必须是有效医生，已住院或已完成手术的患者不能同时标记为转诊。旧存档若已经耗尽候诊名单，会自动进入循环抽取。

## M1 实现 / 0.3

- `data/patients/templates/encounter.json` 定义共用阶段、选项、前置线索、回应、耗时和新增记录；`data/patients/<patient_id>/patient.json` 提供人物资料与专属覆盖；病例答案不在 UI 中。
- `EncounterSession` 只解释通用规则：检查前置线索和重复操作、累加时间、添加记录、切换阶段、写入诊断及住院状态。
- `GameState` 管理按 encounter ID 索引的会话，以及当前病例和汇总时钟。原始患者 JSON 保持只读；病房按运行状态展示住院信息。
- `ClinicView` 负责左侧对话 / 行动、右侧滚动病历，通过主界面调用会话。原有 VN 页面保持独立。
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

GameState 将门诊分钟、术前／手术室分钟和自由时间事件统一汇总为 480 分钟工作日。顶部时间由累计分钟纯计算得到，跨过八小时后进入下一天 09:00。`time_events.json` 提供自由行动与随机对白；休息室把交谈入口放在人物行旁，天台进入时随机选择一位医护或无人。

行动可以超过 17:00，但越过班次终点的部分记为当日加班并在结算时丢弃，不会占用次日工作时间。例如 17:00 开始的八小时手术于凌晨结束，结算后仍进入次日 09:00。日期变化先显示医院夜景转场，玩家确认后才进入下一画面。

存档 v5 的 `time_log` 每项记录稳定事件 ID、触发前累计分钟和随机对白序号，并保存已经丢弃的加班分钟。读取时验证事件存在、时间顺序、非重复限制和最终总时间；旧日志默认使用第一句对白。医院导览的“时间记录”页显示最近七次自由行动。医疗行动继续保存在病例与术前日志中，三者共同推进时钟。

## 患者性格驱动的对白与反应

患者定义现包含主性格、副性格、压力反应、八项稳定特质、四类恐惧倾向和按 action ID 编写的反应文案。PreopSession 在共用动作结算之后只替换展示文本：找得到人物专属反应就使用它，否则回退到 preop 共用文案。玩家选择的数值效果、阶段跳转和手术结果不读取性格资料。

门诊病例仍使用 `voice_style` 对随机病例模板做轻量口吻改写；宣布住院手术、术前与术中使用更具体的 `reaction_lines`。两者都属于患者身份，患者再次出现并抽取新病例后仍保持相同说话习惯。`expressiveness` 仅调整手术台立绘由紧张转为害怕的显示阈值，压力反应只补充状态说明。

存档 v12 在每次 `surgery_step` 后记录 `flow_acknowledge`。术式选项提交后先单独展示本步团队回应或助手纠正，只保留“继续手术”按钮；确认后才进入患者反应或下一流程步骤。读取 v1–v11 时会在旧的术式步骤后自动补入确认事件，避免团队对白与下一轮选择同时出现。

当前采用每个 action 一句确定文案，事件重放和旧存档无需记录额外随机结果。未来若为同一反应加入多个随机变体，必须把选中的反应 ID 写入事件日志，否则重绘和读档可能改变句子。医护性格、长期患者信任、性格影响选项效果及极端意外仍为后续范围。

## 0.7 / 医护人物事件

CharacterEventSession 是通用的短篇选择树运行器，只认识节点、选项和稳定 ID。GameState 负责解锁条件、关系效果、完成历史、耗时与存档重放；界面只显示当前文本和选择。早期曾为神宮寺成美与七瀬恋各制作四章 Lv1 事件；这八个事件已在人物世界观重构时整体退役，稳定角色 ID 与关系槽位保留，等待新事件写入。

存档 v6 增加 character_events 和 active_character_event_id。进行中的事件、已走分支、关系数值与完成历史均由选择日志重建；v1–v5 存档以初始关系和空事件记录迁移。人物事件跨过 17:00 时沿用工作日结算规则。

存档 v21 增加 `story_time_advance_minutes`，记录人物事件造成的跨日预约跳转。御堂江美子的 Lv0 结束后会据此推进至次日 13:00，并立即进入约定的 Lv1 手术室事件。

正式入口由 GameState.character_events_at 按地点、医院时钟、关系与前置事件筛选，再按 priority 和稳定 ID 排序；地点页只展示第一项候选，以情境句而非章节名邀请玩家进入。时段每天重新开放，未完成事件不会因为某天错过而永久消失。

人物档案的「事件测试」使用独立 CharacterEventSession，不写入 GameState，因此不计时、不改变关系、不解锁鉴赏。事件鉴赏从正式完成记录推导解锁状态；回想同样使用独立会话。gallery.path 为空时显示当前立绘差分构图和 CG 槽位，填入合法图片路径后自动显示专属CG。

### Debug test-save generator

Debug builds expose **Test Save Generator** on the title screen. It writes only to an empty one of the eight normal save slots and uses the same `GameState.snapshot()` / `SaveStore.write_slot()` format as player saves. Special-event and character-event presets can satisfy their authored character, relationship, attribute, flag, prerequisite, cooldown, location-time, and timing gates either immediately or after exactly one additional completed surgery. Optional JSON overrides support `player_attributes`, per-character `relationships`, boolean `story_flags`, surgery `progress`, and prior `special_events`. Generated states remain idle and saveable; the generator never starts an event in progress and never overwrites an occupied slot.

Field reference and override examples: [`docs/test_save_generator.md`](test_save_generator.md).
