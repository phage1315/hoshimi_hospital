# 数据契约 v1

机器可读规范：`data/schemas/content.schema.json`，采用 JSON Schema Draft 2020-12 的 `$defs`。`manifest.schema_version = 1`。医生与护士共享 staff 字段，并通过 doctor / nurse 定义约束 profession。

| 定义 | 关键字段 | 规则 |
|---|---|---|
| doctor / nurse | id, age, profession, specialty, skills, surgical_roles, visuals | 员工年龄 ≥18，技能 0–100，稳定 ID |
| adult_intimacy_profile | initiative, fallback_h_cg, base_locations, base_outfits, outfit_portraits, opening_lines, foreplay_preferences, action_reactions, initiative_event, position_lines, after_lines | staff 上的可选成人亲密资料；未填写不会生成入口；与患者触诊和临床状态完全独立 |
| patient | case_id, admission_status, visuals, personality, traits, fear_profile, reaction_lines, medical_background, has_prior_surgery | 稳定人格与反应文案属于患者身份；病例仍可轮换；医疗背景和既往手术史控制首次手术诊断反应 |
| first_surgery_diagnosis_reaction | site_group, tags, weight, lines | 医生首次明确宣布手术后播放的短患者反应；按部位抽取并保存稳定 variant ID |
| relationship | source_id, target_id, affection, familiarity | 有向关系；好感为隐藏的 0–100 值，熟悉度驱动关系事件，另带 flags / event_history |
| case | symptoms, examination_findings, tests, diagnosis, treatment, surgery_id, outcome | 未知值用 null，空内容用空数组 |
| case_template | surgery_id, history, symptoms, examination_findings, tests, diagnosis, differential_diagnoses, rare_variants | 为随机患者和后续 encounter 生成准备的问诊模板；每个术式一条，症状 1–5 项；可选罕见变体包含揭示节点和知情同意后的分支 |

术前 action 可选 `player_effects`，只用于 `charm`、`presence` 与 `reputation` 的明确剧情变化；`skill` 与 `leadership` 分别由手术及团队结算成长。门诊、术前与术中选择可另写 `presence_delta`，运行时按阶段限制本次气场变化并生成医生属性历史记录。

术式记录额外包含 `base_difficulty`、`recommended_surgery`、`training_ceiling`、`unlocked_at_start` 与 `diagnosis_reaction_site_group`。后者把术式映射到乳房、腹部、妇科／盆腔、胸腔／心脏或通用诊断冲击池。`status: placeholder` 的术式允许没有步骤，只能在术式列表灰显，不能被选择或解锁。病例模板使用 `difficulty_modifier` 修正同一术式在具体患者身上的有效难度，并用 `case_weight` 控制刷新频率。主角的手术技术由隐藏 `surgery_xp` 换算，办公室行动不再直接写入 `skill`。

人物事件的 `conditions.special_requirements` 支持 `player_attribute` 条件，例如 `{"type":"player_attribute","attribute":"skill","minimum":56}`；也支持 `career_progress_any`，用于“完成手术数或声誉任一达标”的职业进度门槛，以及 `completed_surgeries`，用于必须完成指定数量手术的严格门槛。阶段触发事件可用 `preop_required_flags` 要求刷手等实际动作已经完成。人物事件 choice 可用 `clear_flags` 清理身份揭晓前的临时旗标，也可用 `related_effects` 同时改变同场配角的关系数值与旗标。节点可用 `speaker_label` 显示配角或临时患者的姓名。人物事件还可选 `auto_follow_up`，指定后续事件、跨越天数与目标时刻，用于不可中断的跨日约定。
| surgery | procedure_group, positioning, duration_minutes, stages, required_roles, success_condition, failure_condition | procedure_group 区分腹部、盆腔、乳房、泌尿、胸腔、心脏和血管；positioning 保存临床主位、当前美术展示组、具体变体与所需入路；stages 按顺序执行 |
| surgery_flow_stage / surgery_flow_option | kind, prompt, awake_interlude, patient_cues, options; response_role, correct, correction | kind 分为 confirm、flavor、decision；awake_interlude 与 patient_cues 共同指定清醒患者互动；decision 必须且只能有一个正确选项 |
| patient_interaction | theme, states, cues, procedure_groups, surgery_ids, once_per_surgery, prompt, actions | 按具体术式、术式类别、通用池依次回退；每层再按状态和身体感受精确度匹配 |
| temporary_condition | trigger_cue, initial_severity, remaining_steps, priority, prompts, actions | 由术式 cue 触发；严重度优先，同级按固定 priority；四个 action 覆盖主刀、助手、巡回护士和忽略 |
| team | surgery_id, members | 一人一岗位，资格与手术要求交叉校验 |
| background | id, label, path | 稳定背景 ID 与 `assets/backgrounds` 下的 PNG 文件 |
| time_event | location_id, label, actor_id, responses, minutes, repeatable, effects? | 地点交谈、休息与职业行动；responses 随机抽取，effects 可写入现有主角属性 |
| character_event | actor_id, chapter, conditions, nodes, minutes | 医护个人事件链；选择带稳定 ID、关系效果与事件旗标 |
| staff_role_cg_reward | staff_id, role_id, title, caption, path | 医护首次担任指定手术／术前岗位时播放一次，并永久收入事件鉴赏 |
| location | name, subtitle, description, background_id, staff_ids | 地点通过 ID 引用背景和出场人员 |
| cameo_patient | canonical_name, public_name, debut_event_id, identity_reveal_flag, visuals | 不进入普通门诊队列的剧情患者；正式姓名可保持隐藏 |
| relationship_activity_placeholder | unlock_level, eligible_staff_ids, portrait_ready_staff_ids, implemented | 关系后期活动的机器可读设计占位；恋爱与肉体关系由人物事件独立记录，`implemented: false` 时不生成游戏入口 |
| dialogue | start, nodes | 每节点 next 与 choices 二选一；@map 返回导览 |

`data/characters/protagonist.json` 另集中保存主角不随存档变化的身份设定。`career_background` 记录海外研修、履历、一年合同及初到星见的意图；`office_flags` 与 `office_items` 保存开局已存在的办公室收藏。本轮使用 `mentor_recommendation_letter` / `office_has_mentor_letter` 预留导师推荐信的后续回忆事件。

角色 `visuals.portraits` 使用 `outfit/expression` 键，值为资源根相对文件路径。默认衣着必须在 outfits 中。医护另有 `visuals.intraoperative_avatar` 机器可读素材清单：统一使用 `intraoperative_avatar/neutral`，记录 `needed`／`ready` 状态、目标路径与用途；完整制作规格和全员进度见 `docs/intraoperative_staff_avatar_checklist.md`。

新增员工：向 staff.json 添加对象（也可以未来通过 manifest 扩展集合拆分），分配唯一 ID，添加初始关系；地点通过 staff_ids 引用。人数不写死在界面中。

新增内容后运行 `tools/validate_data.py`。目前标准校验器校验字段、枚举、范围，额外逻辑校验引用、重复 ID、团队兼容性、对话可达性。Schema 不执行游戏规则。

普通随机患者从资料、美术到门诊／术前蓝图的完整接入步骤见 `docs/adding_random_patient.md`。

普通患者采用索引式数据包：`data/patients/index.json` 列出启用的 `patient_<id>/patient.json`。每个数据包保存患者记录、完全脱衣查体对白、术前阶段提示、回退病例／术式和专属 CG 池。`ContentLoader` 使用 `data/patients/templates/encounter.json` 与 `preop.json` 为每名患者生成运行时 `encounters` 和 `preops` 集合，再将专属 CG 池合并到全局通用池。游戏系统仍只读取原有集合接口。

现有 25 种手术均包含四个广义叙事步骤：术野确认、团队配合、关键判断和完成复核。内容用于 VN 对话与选择，不是医疗教学流程。`confirm` 固定推进；`flavor` 的三个团队选项均不影响结果；`decision` 的错误选项必须提供助手纠正文案。运行时按事件记录所选 option ID、是否正确及累计纠正次数。清醒患者事件在 `surgery_flow` 内作为子状态呈现，不再跳往一次性的 preop 互动节点；全麻直接跳过。

每项术式的 `positioning.primary_position` 使用游戏化的两类体位：仰卧位与截石位。`presentation_group` 对应当前两套美术：截石位使用 `lithotomy`，其他术式统一使用 `standard_torso`。开胸、肾切除和需要现实中换位的复杂术式也归入仰卧表现，以控制 CG 与流程复杂度。`access_tags` 描述腹部、会阴、阴道辅助等术野需求；以后体位 CG、清醒患者反应和阿库娅专属对白都应读取这些字段，而不是仅按科室或 `procedure_group` 猜测。

`temporary_conditions` 当前定义恶心与嗜睡。状态 action 复用患者互动的效果字段，并通过 `condition_effect` 清除、提高严重度或延长持续步数；`delegate_role` 只能引用助手医生或巡回护士，运行时读取本次实际上场成员。患者互动所增加的分钟进入 `procedure_extra_minutes`，结算页同时显示基础手术时间、额外时间与总时间，结果摘要记录实际出现的清醒患者事件次数。全身麻醉不会创建临时状态。普通互动运行时按“具体术式 → 术式类别 → 通用池”回退，同优先级候选会先轮换未使用内容；`once_per_surgery` 内容使用后不再进入本台手术的循环。

## encounter / 门诊会话定义

新增 `encounters` 集合及 `encounter / visit_stage / visit_action / visit_note` Schema。

阶段有 id、title、prompt、speaker、background_id、actions。行动有 id、label、response、speaker、minutes、requires（线索 ID）、notes、next、diagnosis、admit 和 mistake。next 为 null 表示留在当前阶段；同一个 action ID 每次接诊只能执行一次。completion 指定终点阶段，终点没有行动。

发布前校验器检查病例 / 患者关联、说话者、唯一动作与线索 ID、引用和阶段可达性，并枚举可达状态组合以发现无法解锁的步骤。当前界面每阶段最多四个选项；此内容限制由校验器检查。病历仅展示会话已取得的 notes，而非整个定义，避免提前泄露检查报告。

## 0.4 展示字段

visit_stage 可选 bundles：id / label / actions（同阶段原子 ID）/ response / speaker / summary。合并项不改变存档格式；只执行未做过的成员。auto_record 为可选布尔值，控制进入该阶段时是否展开病历。visit_action 可选 summary 用于简短结果卡；完整详细记录仍在 notes。以上字段不改变病例结算。

## preop / 术前内容

preops 集合定义 encounter_id、patient_id、surgery_id、roles、ward_role、preparations、stages、情绪初值与额外准备数量限制。阶段 kind 控制界面布局，scene 表示人物体位／服装等场景语义，background_id 独立指定背景。`surgery_flow` 是连接患者互动与缝合结算的动态阶段，其实际标题、提示和选项来自已选术式。行动使用 requires / flags 表达准备顺序，requires_team 验证团队完整性，execute_preparation 统一执行基础和已勾选的额外准备。`response_speaker` 明确标记结果文字属于患者、主角、医护或旁白；患者台词会在互动记录中显示姓名。response_role 指定由哪个岗位回应，response_by_staff 提供少量人物口吻覆盖。

`ward_preparation_cg_pools` 按术前行动 ID 映射准备 CG，目前覆盖病房灌肠、备皮、戴帽，以及患者专属的手术室留置导尿、术野消毒、无菌单覆盖和递刀后准备下刀。通用池的 `patient_ids` 为空并使用 `presentation: splash`；患者专属池填写患者 ID、提高 priority，并可使用 `presentation: fullscreen`。可选 `procedure_groups` 会把 CG 限制在指定术式类别。运行时优先选择同时匹配患者及术式类别的专属池，否则回退到通用池；同一池随机取图并避免连续重复。跳过准备的行动不进入任何 CG 池。

患者 `personality` 保存主性格、副性格和压力反应的稳定规则 ID；`traits` 保存焦虑基线、疼痛敏感、隐私敏感、初始信任、控制需求、情绪外露、医疗理解和配合倾向八项 0–100 资料；`fear_profile` 区分怕疼、怕操作、怕诊断和怕失控。当前版本不把这些数值用于手术成败或选项效果。`reaction_lines` 按稳定 action ID 覆盖共用反应，覆盖宣布住院手术、病房说明、麻醉选择、下刀、三段术中互动和术式不符。`reaction_variants` 另为病房亲手准备的必要／多余灌肠、必要／多余下腹及会阴备皮、戴手术帽，以及手术室固定、导尿、消毒、划线提供每名患者 2–3 条独立反应。未配置的动作仍回退至 preop 共用文案。

当前立绘表达只读取 `expressiveness`：情绪外露高的患者会更早显示害怕，克制者会较久保持紧张表情。恐惧、痛苦、尊严和配合的实际数值仍完全由共用 action effects 决定，因此同一个玩家选项对各患者的流程结果相同。

## background / 场景背景

`data/backgrounds.json` 是背景资源目录。地点、序章节点、门诊阶段和术前阶段只保存 `background_id`；UI 通过 ContentLoader 查询实际文件路径。新增普通场景无需修改 `app.gd`：先登记背景，再从内容节点引用即可。校验器会拒绝未知背景 ID 和不存在的图片文件。

## time_event / 自由时间事件

`data/time_events.json` 定义地点、参与医护、按钮文字、随机结果池、分钟消耗及是否可重复。可选 `effects` 使用 `charm / presence / reputation`；执行时写入属性历史。GameState 的 `time_log` 保存事件 ID、触发前累计分钟和抽中的文本序号，保证读档后对白不变；耗时继续从内容定义重建。非重复事件只能执行一次，重复事件可多次写入。手术报告的 `reputation +1` 每台已完成手术只能领取一次，整理病例资料不增加声望。

人物事件节点可选填 `cg_path` 与 `cg_fit`，或填写 `portrait_path`，两类不能同时存在。`cg_path` 以全屏 CG 显示，同时保留底部 VN 对话框；`contain` 保留整张图，`cover` 填满画布。`portrait_path` 保留场景背景并按右侧人物立绘显示，必须是具有 Alpha 通道的透明 PNG；校验器会拒绝把不透明图片登记成节点立绘。`allow_unmet_actor` 只允许用于 `contextual` 事件，用于正式相识前发生、但不把角色标记为已认识的剧情。

## character_event / 医护人物事件

`data/events/character_events/index.json` 是长期医护角色章节事件的索引。每名角色使用 `data/events/character_events/<actor_id>.json` 独立保存自己的全部事件；索引顺序决定合并顺序，运行时仍得到统一的 `character_events` 集合。新增角色事件时应编辑对应角色分片并把新文件加入索引，禁止重新建立单体总文件。conditions 可按工作日、隐藏好感、熟悉度及前置事件解锁；time_start / time_end 使用当天绝对分钟（09:00 = 540），priority 决定同类候选事件的先后。category 区分工作、里程碑、情境与日常事件。nodes 提供角色、玩家与旁白文本，choice 的 effects 修改好感和熟悉度，flags 记录可供后续事件引用的选择语义。事件时间只在抵达 `@end` 后结算。

`trigger_mode` 明确事件入口：`day_start` 在上班第一刻统一判定，每天最多启动一个，剩余候选留到后续工作日；`location` 在条件满足后于玩家进入 `location_id` 时自动启动；`preop_stage` 在 `preop_stage_id` 对应的术前阶段自动启动；`sunday` 只从星期日邀请与安排界面进入。普通地点和办公室不再显示剧情按钮。日程事件当天一经启动就写入持久化日程槽标记，读档或反复返回地图都不会在同一天启动第二个日程事件。

普通 VN 节点的 `text` 必须完整容纳在默认对话框内。一次发言、一个动作或一段短旁白各自占一个节点；说话人改变时必须拆节点，不能把多轮对白写进同一个文本框，也不能把滚动条当作常规阅读方式。运行时会为旧脚本和不同语言字宽自动分页，但新增内容仍应在数据层完成分镜。只有通讯记录、完整病历、制作人员名单或系统汇总等明确长文演出可设置 `allow_dialogue_scroll: true`。提交前运行 `python3 tools/dialogue_layout_audit.py` 和 `godot --headless --path . --script res://tools/text_overflow_test.gd`。

每个节点必须指定人物当前服装下真实存在的 expression 立绘；校验器拒绝缺失差分，防止运行时悄悄回退为 neutral。gallery 保存稳定 cg_id、鉴赏说明和可为空的图片路径；事件完成记录同时充当鉴赏解锁记录。

`staff_role_cg_rewards` 为岗位首次担当奖励表。当前岗位包括助手医、器械护士、巡回护士与病房术前介护；校验器检查员工存在、岗位资格、员工／岗位组合唯一以及 CG 文件存在。第一次成功任职后，奖励 ID 写入该员工关系状态的 `unlocked_benefits`，播放一次并在“事件鉴赏”中永久开放，重复任职不再弹出。

存档只写事件 ID 与有序 choice ID。读取时重新验证每一步的可用选项并重放关系效果，未知、越节点或重复的选择会拒绝整个存档，不会部分修改当前状态。已完成事件进入对应关系的 event_history，不能重复触发。

资格字段沿用员工的 surgical_roles；病房准备护士要求 nurse 职业且不能和团队重复。主刀玩家是固定会话角色，不伪造员工记录。现有 data/teams/teams.json 仍为旧数据契约样例，实际术前阵容由 PreopSession.team 保存。
### Special-event sharding

Large special events use the same owner-based layout as character events. `data/events/special_events/index.json` and `data/events/special_event_steps/index.json` enumerate shard files; character-specific chains belong in the matching owner file (for example `nurse_satsuki.json`). Do not recreate the former monolithic JSON files. The content loader and collection tooling resolve either arrays or indexed shard collections.

All narrative sessions are atomic save units. Character events, micro events, special events, and adult relationship events lock user saves until the runtime session is finished and dismissed.
