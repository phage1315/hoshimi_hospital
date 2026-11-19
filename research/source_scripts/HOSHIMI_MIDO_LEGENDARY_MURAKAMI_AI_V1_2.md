# Hoshimi Hospital — 御堂江美子 Legendary Surgery
## 《把心脏交还给跑道》 / 村上愛 / V1.2（Runner 对齐补正稿）

**用途**：为 Codex 提供明确的三日传奇手术内容、两套第一助手对白、可选策略、数值草案和接入规则；本文不表示 Godot 已经实装。V1.2 保留已确认的人物对白，并将危机、生理压力、Day 3 结算、失败救援、美术与存档边界对齐现有 Runner。

**已预留、待注册 procedure ID**：surgery_master_aortic_root_ascending_replacement（不在当前运行数据中，非已实装 ID）  
**UI 名称**：开胸主动脉根部及升主动脉置换  
**UI 英文全称**：Valve-Sparing Aortic Root Reimplantation (David Procedure) and Ascending Aortic Graft Replacement  
**术式具体方案**：保留自体主动脉瓣的主动脉根部再植入（David reimplantation）＋升主动脉人工血管置换。  
**患者**：村上愛（成人），《淫内感染 午前3時の手術室》原作角色；《星见医院》首次病例专属患者。  
**患者 UI 英文名**：Ai Murakami  
**专家**：御堂江美子；**玩家主刀**：坂口；**麻醉**：全身麻醉。  
**内容状态**：剧情与规则合同 V1.2；整体难度及分阶段基础生理效果授权 Codex 制定初始配置并提交模拟结果，仍待真实项目 Schema／资源核验。

---

## 1. 概念锁定与原作事实边界

1. 原作事实：村上愛任私立学校体育教师；自称学生时代曾是马拉松选手，认为自己的心脏很强。原作所述就诊病因并非主动脉根部动脉瘤。
2. 星见 AU 新设：学校体检注意到血压异常后进一步检查；经超声心动图与主动脉 CTA 确认主动脉根部最大直径约 5.3 cm，近端升主动脉约 4.8 cm；主动脉瓣为三叶、瓣叶活动与质地适于保留，左室功能保留；尚未发生夹层。此为本事件的架空病例事实，不得冒称原作设定。
3. 术前经有经验的主动脉外科团队评估，可以在合适患者的 5.0 cm 以上根部／升主动脉瘤考虑手术。不要写成凡 5.3 cm 一律必须开刀。
4. 术中最终确认瓣叶与根部解剖适合保瓣重建。术前需说明若条件不允许，现实中的备选是带瓣人工血管根部置换；本次游戏首通走固定 David 方案，**不擅自新增可玩分支或另一个 procedure ID**。
5. 三日结构：Day 1 接诊、解释、编组；Day 2 全麻 Advanced Grand OR Runner；Day 3 **先执行现有原子结算、再播放首次成功专属病房对话**。Day 2 没有清醒患者反应，没有长篇关系剧情；失败 Day 3 复用统一失败模板。
6. 风格：患者先不相信自己的身体会有问题，意识到必须停搏及体外循环后才真正紧张。御堂短促、精确、自信，但她的专业判断不能变成医学上的无条件保证。轻幽默来自体育教师与术后康复的具体处境，而不是反复谈马拉松。

### 与现有 Legendary / Advanced 规则的关系

**首通解锁**（独立检查，不能以另一个角色的 Lv5 代替）：

- Advanced Referral 系统已正式开启。
- 五个**不同**的 ADVANCED_REGULAR 术式首次成功并完成 Day 3 结算；教程、薰 Quest、传奇、返场重复不计入。
- 御堂江美子实际 Relationship Lv5 已 clear。使用既有 Relationship Gate，**不增加表达「御堂愿意教」的独立旗标**。
- 术式资产与 Runner 数据 runtime_ready；不提前释放空事件。

**术式注册的硬约束（本次新增）**：当前引擎自动判定 Legendary 的规则仅识别 ID 前缀 surgery_legendary_；本 ID 是早期 canonical 预留名，使用 surgery_master_。因此 **新注册时必须在当前真实 procedure registry／分类 resolver 中显式声明为 LEGENDARY_STORY**（或该引擎的实际同义枚举）；所有 Gate、Board 展示、首通进度、返场抽样、奖励统计必须按这个显式类别工作。不能仅把 ID 加进 surgeries.json 后任它被当作普通术式，也不能为了兼容前缀而悄悄改名产生双份术式。若目前只有前缀判断，应为该 ID 增加最小显式分类映射，并添加测试；类别字段名由 Codex 查实际代码确定。

**首通编组**：坂口主刀；第一助手强制为御堂江美子（doc_emiko，Codex 以现存真实 ID 为准）；第二助手及护理、麻醉遵照既有 Grand OR 编组。御堂若暂不满足现有有效排班／14 天助手冷却，则此次手术保持待安排，不能悄悄替换她或无视冷却。具体预约时间遵从既有 Day 1 / 2 / 3 调度和冲突检查。

**首通状态**：第一次真实 Day 2 手术失败，Day 3 **原子结算时**进入 FAILED_LOCKED；成功则在 Day 3 **原子结算时**进入 CLEARED。结算包含首次事实、奖励、统计和返场资格的状态写入，只执行一次；之后才播放对应成功剧情或统一失败模板。读取既有 procedure episode/clear 状态，不叠建平行 flag；查看、取消未确认编组或意外进程中断不消耗首通机会。剧情回看、屏幕重入不得再结算奖励。

**返场**：CLEARED 后加入普通周一 Advanced 返场术式的统一抽取集合（两例独立有放回抽样、case_instance_id 不同、无 Quick、完整三日消耗、既有冷却与奖励），不使用专门传奇返场池。与旧版「LEGENDARY_STORY 不加入返场」条目冲突时，以此处作者后续确认的特例规则为准。返场不再使用具名村上愛或她的专属首通 VN，采用适配术式的成年随机患者。返场第一助手由玩家自由选，御堂也可以被再次选取。

**第一助手对白分流原则**：

- 首次传奇剧情：FIRST_STORY → MIDO_TEACHING；第一助手固定御堂。
- 任意返场：REPLAY → STANDARD_ASSISTANT；第一助手用本次玩家所选人员的姓名／头像与通用岗位台词。即使玩家返场又选了御堂，也使用 STANDARD_ASSISTANT，不重复传授剧情。
- 判断依据是当前病例实例的首通／返场属性，**不是仅看第一助手是不是御堂**。
- 两种集合对同一手术步骤、数值、成功率和奖励完全等价，只影响文本。

---

## 2. Day 1 首通剧情 — 《没有症状的风险》

以下按顺序播放；说话人姓名为正文锁定。EN 为对应英文本地化草案，中文经审定后不得因数据转换而擅改。

### A. 诊察室：自信

（村上愛带着运动风格的外套进来。坐下前，顺手把椅子向后推了半步，习惯性地给自己留出活动空间。）

**村上愛**：「我还以为体检室弄错了。心电图不是说没什么特别的吗？」  
EN: “I thought the screening clinic had made a mistake. Didn't they say my ECG looked unremarkable?”

**坂口**：「心电图和主动脉的形状，是两回事。」  
EN: “An ECG and the shape of your aorta tell us two different things.”

**村上愛**：「我以前可是跑马拉松的。现在每周还要带学生上体育课呢。」  
EN: “I used to run marathons. I still teach PE every week.”

**御堂**：「我们知道。所以我要你先看检查结果。」  
EN: “We know. That's why I want you to look at the imaging first.”

（御堂调出主动脉 CTA 的三维重建。）

**御堂**：「主动脉根部，最大五点三厘米。上面的升主动脉也扩张了。」  
EN: “The aortic root measures five point three centimeters at its widest. The ascending aorta above it is enlarged as well.”

**村上愛**：「……可是我现在一点也不觉得心脏有什么问题啊？」  
EN: “But I don't feel anything wrong with my heart at all.”

**御堂**：「所以我们才要在你出现问题之前动手术。」  
EN: “That's exactly why we need to operate before something happens.”

（村上愛看着影像，没有马上回答。）

**村上愛**：「这是说，我现在跑得动，不等于它就是安全的？」  
EN: “So being able to run right now doesn't mean it's safe?”

**坂口**：「问题主要在承受血流压力的主动脉壁。它不一定会先给你一个疼痛的警告。」  
EN: “The problem is in the aortic wall that bears the pressure of each heartbeat. It may not give you a warning in the form of pain.”

**村上愛**：「我平时还教学生，身体不舒服一定要及时说。结果我的身体连招呼都不打。」  
EN: “I tell my students to speak up when something feels wrong. Apparently my own body doesn't believe in giving notice.”

### B. 术式说明：从不理解到认真听

**御堂**：「方案是切除病变的主动脉根部和升主动脉，用人工血管重建。」  
EN: “The plan is to remove the diseased aortic root and ascending aorta and reconstruct them with a graft.”

**御堂**：「你的主动脉瓣叶条件不错。我们计划保留它。」  
EN: “Your native aortic valve leaflets look suitable. We plan to preserve them.”

**村上愛**：「换血管，却把瓣膜留下？」  
EN: “Replace the artery, but keep the valve?”

**坂口**：「是的。新的人工血管还要和两条冠状动脉的开口重新连接。」  
EN: “Yes. We'll also have to reattach the openings of both coronary arteries to the new graft.”

**村上愛**：「……听起来已经不像我以为的‘心脏修补’了。」  
EN: “That sounds a great deal bigger than the ‘heart repair’ I had imagined.”

**御堂**：「正中切开胸骨，建立体外循环。重建根部时，需要暂时让心脏停搏。」  
EN: “We'll open the sternum along the midline and establish cardiopulmonary bypass. During root reconstruction, we'll temporarily arrest the heart.”

**村上愛**：「停……停搏？是说心脏真的会停下来？」  
EN: “Arrest... You mean my heart will actually stop?”

**御堂**：「体外循环会在这段时间维持血液循环。重建完成后，再恢复心脏灌注并评估功能。」  
EN: “The bypass circuit supports your circulation during that interval. After reconstruction, we'll restore blood flow to the heart and assess its function.”

**村上愛**：「我没想到，教了这么多年人体课，最难懂的例子会是我自己。」  
EN: “After teaching anatomy for so many years, I never expected to become the example I understand the least.”

**御堂**：「你不需要背下术式名称。但我会把你要面对的过程完整告诉你。」  
EN: “You don't need to memorize the operation's name. But I will explain the procedure you're consenting to.”

**坂口**：「保瓣方案还要在术中再次确认。如果瓣叶条件不合适，团队会按术前说明的备选方案处理。」  
EN: “We will assess the leaflets again during surgery. If preservation isn't appropriate, we'll use the alternative approach explained during consent.”

**村上愛**：「我知道了。那我先安排好学校的代课。还有……我需要多久不能跑？」  
EN: “All right. I'll arrange someone to cover my classes. And... how long will I be unable to run?”

**御堂**：「先把手术和康复做好。关于重返跑道，我们会认真谈，但不会拿猜测给你排训练表。」  
EN: “First, surgery and rehabilitation. We will take your return to running seriously, but we won't write a training plan based on guesses.”

### C. 术前会议：主刀位置的交接

（村上愛离开后。手术计划与 CTA 留在屏幕上。）

**御堂**：「这台由你主刀。我做第一助手。」  
EN: “You'll be the lead surgeon. I'll take first assist.”

**坂口**：「主动脉根部再植入。这一次，你打算从哪一处开始教？」  
EN: “An aortic root reimplantation. Where do you plan to begin teaching this time?”

**御堂**：「从你自己说出计划开始。」  
EN: “With you explaining the plan yourself.”

**坂口**：「先建立体外循环和心肌保护。确认瓣叶后，准备根部和冠状动脉开口，固定人工血管，完成瓣膜与血管重建，最后复跳和脱机。」  
EN: “Establish bypass and myocardial protection. Inspect the leaflets, prepare the root and coronary buttons, secure the graft, complete the valve and vascular reconstruction, then reperfuse and wean from bypass.”

**御堂**：「顺序没问题。到了术野里，你得知道什么时候该停下来重看一眼。」  
EN: “The sequence is sound. In the field, you need to know when to stop and look again.”

**坂口**：「你会提醒我的。」  
EN: “You'll remind me.”

**御堂**：「我会问你问题。答案要你自己给。」  
EN: “I'll ask questions. You'll have to provide the answers.”

**坂口**：「听上去比亲自主刀还严格。」  
EN: “That sounds stricter than operating yourself.”

**御堂**：「当然。这次握刀的人是你。」  
EN: “Of course. This time, you're the one holding the scalpel.”

---

## 2.5 Day 2 全麻前短过场 — 《手术室门口》

这一段从旧 Day 1 的 D 段原位迁入 **实际 Day 2、麻醉诱导／Time-out 之前**。说话顺序和中英逐句文字不变。它不是一个额外可预约的事件，不消耗独立手术日。其后启动既有全麻过场和 MR01 Runner。**同一运行会话内不得重复播放；玩家从术前安全存档重新开始时正常重播，不持久化过场播放游标。**

（患者卧于转运床，已完成必要核对，术前准备人员确认身份与手术计划。村上愛没再问跑步的事。）

**村上愛**：「坂口医生，等我醒过来……它还是我的心脏吧？」  
EN: “Dr. Sakaguchi, when I wake up... it'll still be my heart, won't it?”

**坂口**：「是你的心脏。我们要修好的，是保护它的大血管。」  
EN: “It will still be your heart. We're repairing the major vessel that carries blood from it.”

**御堂**：「醒来以后，第一项训练不是跑步。是好好呼吸，按计划恢复。」  
EN: “When you wake up, your first training session won't be running. It will be breathing well and following your recovery plan.”

**村上愛**：「……遵命，御堂教练。」  
EN: “...Yes, Coach Mido.”

**御堂**：「手术结束以后，你可以再决定要不要这么叫我。」  
EN: “After the operation, you can decide whether you still want to call me that.”

（患者露出一点笑容。正式进入 Day 2 全麻准备。）

---

## 3. Day 2 Surgery Runner 关口

**全麻、仰卧、胸骨正中切开、体外循环、主动脉阻断＋心肌保护、David 保瓣再植入、两侧冠状动脉钮吻合、远端升主动脉吻合、排气与复灌、超声评估、脱离体外循环、止血与关胸。**

下表为**内容层建议**。Stage kinds、HP 基础值、P difficulty、专业标签、physio_stress、所需耗时应以实际 Advanced Resolver 的已注册枚举与数值标度映射；未经工程审查，不能把此表机械复制成已可运行的 production JSON。

| ID | kind 候选 | 术式关口 | 基线时间（分钟） | 主要叙事／操作风险 |
|---|---|---|---:|---|
| MR01 | F | Time-out／体位／范围复核 | 15 | 首通教学说明只在术中技术节点出现，不在 Time-out 加长 VN |
| MR02 | F | 胸骨正中切开与初步止血 | 35 | 区分胸骨切开与左右侧开胸 |
| MR03 | L | 心包打开；根部与正常升主动脉暴露 | 30 | 保持正常远端区域与冠脉走向可见 |
| MR04 | P | 抗凝确认、动静脉插管、体外循环建立 | 40 | 关键灌注安全与插管判断 |
| MR05 | S | 主动脉阻断、心肌保护与停搏 | 30 | 心肌保护与停搏时间的整体管理 |
| MR06 | L | 切开病变根部；最终瓣叶适应证复核 | 30 | 保瓣不是预设结果替代检查 |
| MR07 | L | 冠脉钮游离、根部组织清理 | 45 | 避免冠脉扭曲与组织损伤 |
| MR08 | P | 根部外侧充分游离与人工血管尺寸判断 | 45 | 瓣环、瓣交界的空间几何 |
| MR09 | P | 基底环缝线与人工血管近端固定 | 45 | 一圈缝线的顺序与组织保护 |
| MR10 | P | 瓣交界重悬、瓣叶在人工血管内再植入 | 50 | 核心精密术式关口 |
| MR11 | S | 瓣叶对合检查及加压灌水／漏隙测试 | 40 | 发现问题应调整，不准空口声称完美；此时尚未恢复冠脉灌注 |
| MR12 | P | 左冠状动脉钮精细吻合 | 45 | 吻合完整、低张力、血流走向 |
| MR13 | P | 右冠状动脉钮精细吻合 | 45 | 预防扭曲、张力与角度误判 |
| MR14 | P | 人工血管与远端升主动脉吻合 | 40 | 近远端血管几何整体衔接 |
| MR15 | S | 排气、恢复灌注／复跳、经食道超声评估 | 35 | 不提前许诺生理参数正常 |
| MR16 | P | 评估心室功能与节律、逐步脱离体外循环 | 45 | 主刀与麻醉／灌注团队共同决策 |
| MR17 | F | 彻底止血、引流、胸骨固定与关闭 | 30 | 关闭前再次复核吻合与清点 |

**基线总时长：645 分钟（约 10 小时 45 分）**；17 节点，F×3 / L×3 / S×3 / P×8。阶段预计时长作为初始平衡值，运行时继续以玩家操作、Precision、危机和现有修正机制结算；不要把 645 分钟硬编码为实际完成时间。

### 3.1 V1.2 阶段数值与生理压力映射（内容层）

现行 Advanced POC 的 HP 上限为 100；本台初始阶段固定消耗合计 **54 HP**，难于普通 Advanced（原 Whipple 示例为 12 阶段、固定 HP 约 41）。MR04 等八个 P 节点的精密失败单独扣额外 HP；**不触发「失败满三次」结算**。下表给出完整的内容数值，不留「以后再填」占位：

| Stage | kind | hp_base | difficulty | hp_failed_extra | specialty_tag | physio_stress（实际枚举） | 设计压力索引（仅参考） |
|---|---|---:|---:|---:|---|---|---:|
| MR01 | F | 1 | — | — | cardiac | low | 0 |
| MR02 | F | 2 | — | — | cardiac | medium | 2 |
| MR03 | L | 2 | — | — | cardiac | low | 1 |
| MR04 | P | 4 | 88 | 12 | cardiac | medium | 3 |
| MR05 | S | 2 | — | — | cardiac | high | 4 |
| MR06 | L | 2 | — | — | cardiac | medium | 2 |
| MR07 | L | 2 | — | — | cardiac | medium | 3 |
| MR08 | P | 4 | 91 | 13 | cardiac | medium | 3 |
| MR09 | P | 4 | 93 | 14 | cardiac | high | 4 |
| MR10 | P | 5 | 96 | 16 | cardiac | high | 5 |
| MR11 | S | 2 | — | — | cardiac | medium | 3 |
| MR12 | P | 5 | 97 | 16 | cardiac | high | 5 |
| MR13 | P | 5 | 96 | 15 | cardiac | high | 5 |
| MR14 | P | 4 | 94 | 14 | cardiac | high | 4 |
| MR15 | S | 3 | — | — | cardiac | high | 5 |
| MR16 | P | 5 | 97 | 16 | cardiac | high | 5 |
| MR17 | F | 2 | — | — | cardiac | medium | 2 |
| **合计** | **17** | **54** | **8 P** | **仅 P 失败时** |  | **low／medium／high** | **仅设计参考** |

约束：

1. specialty_tag 在内容层统一使用 cardiac，含义为心脏／主动脉外科。**Codex 先核对实际已注册的 specialty enum**；若真实字段不是 cardiac，必须用已有心脏外科标签一次性映射并记录在实施说明中，绝不能静默建立无技能支持的全新专科。明确的内容语义由本稿锁定，实际运行字符串由真实 registry 决定。
2. **正式映射已确认：压力索引 0–1 → `low`，2–3 → `medium`，4–5 → `high`。**现行解析器只接受这三个枚举；直接写入实际 stage 数据的必须是左侧运行枚举，0–5 仅供策划与平衡报告阅读。索引 0 **不等于禁止危机**，枚举也不直接扣 Stability。不得把生理压力与策略、危机或阶段基础生理效果重复扣除。
3. 每个节点 hp_base 原样扣一次；P 未通过仅按现有 Precision 规则附加一次 hp_failed_extra，不因为 Precision 失败额外编造 bleeding、blood_loss 或 stability 惩罚。Precision 救援按现有逻辑运行，重复 UI 或**术中内存快照测试**不能重复结算同一次失败；事件期禁止玩家持久存档阶段进度。
4. 难度 88–97 是高端传奇手术的初始平衡值；不会通过本稿修改 Surgery 能力值、两助手 Support 修正、概率公式或 HP 最大值。Codex 应在模拟中报告以 Surgery 80／90／100 为输入时的实际 P 成功率、可预计的 HP 消耗及终止比例，不得擅自把此台改成必胜剧情。

### 3.2 三个 S 节点的完整双策略（正式作者数值）

三个 S 各有**恰好两个可选项**。文中「额外时间」均是相对于 §3 基线阶段分钟数的增量，**只由 Strategy resolver 应用一次**；「额外 HP 消耗」为非负代价而非生命值恢复；Stability／Visibility／Bleeding／Blood Loss 为对既有生理状态的增量，均只应用一次、按现有上下限裁切。任何未列的效果为 0。以下为**内容效果合同**，Codex 应翻译到项目现存 strategic_effects／conditional_effects 结构，不能把表头误当未经审计的 JSON 键名。

| Stage／Option ID | 中文显示选项名称 | 英文显示名称 | 玩家说明（中文 / English） | 额外分钟 | 额外 HP 消耗 | Stability Δ | Visibility Δ | Bleeding Δ | Blood Loss Δ |
|---|---|---|---|---:|---:|---:|---:|---:|---:|
| MR05_A | 联合心肌保护，分段复核 | Combined Protection with Staged Checks | 采用顺行及必要时逆行的联合保护，并分段确认心肌保护效果；耗时较长、循环储备更稳。 / Use antegrade and, when indicated, retrograde cardioplegia with staged checks; slower, with a larger physiologic margin. | +15 | +1 | +3 | 0 | 0 | 0 |
| MR05_B | 标准顺行保护，计划复给 | Standard Antegrade Protection | 按冠脉解剖采用标准顺行心肌保护和计划性复给；耗时较短，但早期循环储备较紧。 / Use anatomy-guided antegrade cardioplegia with scheduled redosing; quicker, with a narrower initial margin. | +0 | +0 | -2 | 0 | 0 | 0 |
| MR11_A | 补充测量与加压对合复核 | Extended Coaptation Assessment | 在标准瓣叶测试外，加测对合高度与加压状态下的对称性；耗时较长、术野判断更清楚。 / Add coaptation-height measurements and pressurized symmetry checks to the standard valve test; slower, with a clearer field assessment. | +14 | +1 | 0 | +6 | 0 | 0 |
| MR11_B | 标准瓣叶对合测试 | Standard Leaflet Coaptation Test | 完成标准的瓣叶对合及漏隙测试，符合预设条件后继续；省时，但额外校验较少。 / Complete standard leaflet coaptation and leak testing, then proceed only if criteria are met; faster, with fewer supplemental checks. | +0 | +0 | 0 | +1 | 0 | 0 |
| MR15_A | 分级复灌与多切面超声复核 | Staged Reperfusion and Multiview TEE | 完整排气后分级恢复灌注，同时多切面评估瓣膜及心室；更慢但血流动力学缓冲较大。 / After full de-airing, reperfuse in stages with multiview valve and ventricular TEE; slower, with more hemodynamic reserve. | +15 | +1 | +6 | 0 | 0 | 0 |
| MR15_B | 标准复灌并同步超声评估 | Standard Reperfusion with TEE | 同样完成排气，按常规节奏复灌并同步完成必要超声；耗时短，但短时循环压力较高。 / Fully de-air, restore flow at the standard pace, and perform the required TEE assessment; faster, with more short-term physiologic strain. | +0 | +0 | -3 | 0 | 0 | 0 |

**医疗语义锁定**：B 选项只是更简练的合格标准流程，**绝非跳过心肌保护、保瓣检查、排气或 TEE**。手术准备、血管适应证、关键安全阈值不因玩家点 B 被取消；选择 A 也不是医学上必然优于 B，而是为游戏构造的确定性 Time/HP/生理权衡。可通过现有术前病历事实和事件标签进行情境化文字展示，但 V1.2 不新增条件分支。

### 3.3 危机检查点与终止约定

本台采用**现有 Advanced 生理驱动危机 resolver**，保留 MR05、MR13、MR16 三个危机检查点。是否触发、实际概率、危机类型及最终 HP 代价均由当前生理状态、团队影响与原有随机规则动态计算。**下表旧 V1.1 的概率／HP 数值仅作为平衡目标参考，不是生效配置，不允许工程直接兑现固定值**；每个 episode 的每个检查点仍至多执行一次原生检查。

| checkpoint ID | after_stage | 旧稿触发率参考（不执行） | 建议危机主题（须匹配当前危机池） | 旧稿 HP 参考（不执行） |
|---|---|---:|---|---:|
| MR_C1 | MR05 | 0.18 | 体外循环／心肌保护相关监测变化 | 9 |
| MR_C2 | MR13 | 0.27 | 冠脉钮吻合区域出血或灌注疑点 | 12 |
| MR_C3 | MR16 | 0.20 | 脱机后血流动力学需进一步调整 | 10 |

建议主题是创作标签，不是强制覆盖现有随机危机类型；`0.18 / 0.27 / 0.20` 与 `9 / 12 / 10` **不是引擎字段**。若 Runner 已在相应阶段发起危机判断，应复用它原本的生理驱动检查，不得再额外掷骰；也不得设置本台特例概率或 HP 覆盖。不新增「术式级危机概率／基础 HP 配置」接口。危机解决、救援及 HP 实际扣费完全由现有 resolver 决定；未解决时暂停阶段 POST，真正终止时跳过所有成功型 POST。医疗类型与 §5.3 不匹配时使用通用危机对白。

医学与演出约束：

- 不要添加缺乏本台指征的深低温停循环／全弓置换；这里是选择性根部加升段修复，不是夹层弓部手术。
- 体外循环由灌注专业人员管理；Grand OR 若未注册独立灌注师 speaker_role，可由麻醉岗位汇报与灌注组的协调，**不要令第一助手独自操作体外循环机**。
- 阶段 MR05–MR15 保持主动脉阻断／心肌保护的大体先后。MR15 才进入复灌与复跳，不得在此前报告自主心跳恢复。
- MR11 只记录瓣叶对合评估，不固定写「零反流」之类需要检查值支持的事实；正式效果依真实 Stage Resolver。
- 关口按现有 P、S、Advanced HP、Precision、双助手救援、Strategy 与危机规则实现。**Precision 失败次数只记统计；终止条件是 HP 耗尽或既有生理失败判断，不存在「Precision 失败三次自动退出」。** 不自行开一个传奇专属第二套手术游戏。

### 3.4 术式整体参数与各阶段基础生理效果：工程授权

以下内容**不是空字段默认为零，也不是授权修改全局公式**。作者授权 Codex 参照实际已实装的高级术式，为本台制定初始配置、进行模拟验证，并交付明确的数值表。只修改本台 procedure／stage 数据，不改其他术式或公用概率、HP、生理、奖励计算公式。

| 必须明确的字段／指标 | 定案方式 | Codex 交付要求 |
|---|---|---|
| `base_difficulty` | 授权根据现有 Advanced 难度标度制定本台初值 | 提供最终值、同类术式对照及依据 |
| `training_ceiling` | 授权遵循现有训练收益上限机制制定本台初值 | 提供最终值与不会改变公共成长公式的证明 |
| `reward_tier` | 授权沿用现有奖励档位挑选本台初值 | 提供实际枚举、奖励预期及与其他传奇／普通高级术式对照 |
| MR01–MR17 阶段基础 `stability`／`visibility`／`bleeding`／`blood_loss` 效果 | 授权 Codex 按现有 stage resolver 与该术式负荷确定，**不得视作未经定义就一律为零** | 另附 17 行、四项指标的基础效果表；值可以是零，但每项须明确；若实际效果依状态动态计算，注明来源并提供标准初始状态的模拟值 |

**语义隔离**：§3.1 的 `physio_stress` 仅为 `low / medium / high` 负荷标签，**不是阶段基础生理扣减**；§3.2 的六项策略效果为额外增量；§3.3 的危机由动态 resolver 自行结算。三者与工程定案的基础阶段效果不能重叠扣费。

**验收门槛**：Codex 必须交付 `base_difficulty`、`training_ceiling`、`reward_tier` 的最终值、17 行基础生理效果表，以及 Surgery 80／90／100 情境下的 Precision 成功率、预期 HP、危机／终止统计；报告实际 schema 字段和枚举映射。确认后方可将本台标记 `runtime_ready`，不得把未提交的数值当成已经实装。

---

## 4. Day 2 团队对白共用底盘（不包括第一助手）

每个阶段固定三句共用角色台词：两句阶段开始（PRE），一句该阶段成功解决后（POST）。在两句 PRE 之间插入**一条第一助手 PRE**（见 §5）；六个技术关键节点还可追加一条第一助手 POST（见 §5），使普通阶段共 4 句、重点阶段共 5 句。严禁把所有台词塞进旧 V1 的「随机互斥 entry variants」里，导致只显示其中一句。

每行形式：行 ID｜speaker_role｜中文｜英文。speaker_role 始终使用实际 Grand OR 已注册岗位，按当前编组映射真实姓名与头像。

### 4.0 Precision／助手救援后的 POST 播放规则（V1.2 定案）

本稿的 `MRxx_POST` 指**该阶段完成／解决后才合理的正常 POST**；是否播放由现有 Runner 的真实阶段结果决定，不凭是否触发过一次失败动画判断。三个必须区别的分支如下：

| 阶段结果 | 本台专属 `precision_failed` | 正常 `MRxx_POST`／对应第一助手 POST | 后续 |
|---|---|---|---|
| Precision **直接成功** | 不播放 | **播放一次** | 按现有顺序进入下一阶段 |
| Precision **失败但助手救援成功** | 播放一次失败回应 | **播放一次**，因为该阶段已由救援成功解决 | 保留真实失败代价及救援结果，继续 |
| Precision **失败、助手救援失败，但手术尚未终止** | 播放一次失败回应 | **跳过成功型 POST** | 严格按现有 Runner 的失败后续／阶段推进规则继续，不凭对白擅自结算成功 |

若有独立危机尚未解决，先暂停 POST；只在**危机已解决且阶段最终有效完成**后依据上表播放。HP 耗尽或生理终止时，任何成功型 POST 均不得播放。无论何种分支，同一阶段的同一 POST 不能因 UI 重绘、临时内存快照或救援回调被重复播放。

### MR01 — 手术核对

- MR01_PRE01｜circulating_primary｜「清点记录和体外循环准备单已经备齐。」｜“The count record and bypass preparation checklist are ready.”
- MR01_PRE02｜lead_surgeon｜「先核对影像，确认今天重建的上下界。」｜“Let's check the imaging and confirm the proximal and distal extent of the repair.”
- MR01_POST01｜scrub_primary｜「胸骨切开所需器械在主台。」｜“The sternotomy instruments are on the main table.”

### MR02 — 胸骨正中切开

- MR02_PRE01｜lead_surgeon｜「正中入路。先把胸骨后方安全地暴露出来。」｜“Midline approach. First, expose the space behind the sternum safely.”
- MR02_PRE02｜scrub_primary｜「胸骨锯和止血材料在手边。」｜“The sternal saw and hemostatic supplies are at hand.”
- MR02_POST01｜anesthesia｜「通气和循环监测继续。」｜“Ventilation and circulatory monitoring continue.”

### MR03 — 心包及主动脉暴露

- MR03_PRE01｜assistant_2｜「我来维持心包牵引，给升主动脉留足空间。」｜“I'll maintain pericardial traction and keep the ascending aorta in view.”
- MR03_PRE02｜lead_surgeon｜「正常的远端段也要看清，别只盯着瘤体。」｜“We need a clear view of the healthy distal segment, not just the aneurysm.”
- MR03_POST01｜scrub_secondary｜「下一阶段的插管和阻断器械已经分类放好。」｜“The cannulation and clamping instruments for the next stage are arranged.”

### MR04 — 建立体外循环

- MR04_PRE01｜anesthesia｜「体外循环师在位，抗凝检查正在最后核对。」｜“The perfusionist is standing by. The anticoagulation check is in its final review.”
- MR04_PRE02｜lead_surgeon｜「动静脉插管位置再确认一次。」｜“One more check of the arterial and venous cannulation sites.”
- MR04_POST01｜anesthesia｜「体外循环已经建立，继续监测灌注和体温。」｜“Bypass is established. We'll keep monitoring perfusion and temperature.”

### MR05 — 主动脉阻断与停搏

- MR05_PRE01｜anesthesia｜「阻断前再核对心肌保护方案。」｜“Let's verify myocardial protection before cross-clamping.”
- MR05_PRE02｜lead_surgeon｜「确认后阻断，按计划给予心肌保护。」｜“Once confirmed, cross-clamp and administer cardioplegia as planned.”
- MR05_POST01｜assistant_2｜「根部术野已充分暴露。」｜“The root is adequately exposed.”

### MR06 — 瓣叶与根部检查

- MR06_PRE01｜lead_surgeon｜「打开病变根部，先看瓣叶。」｜“Open the diseased root and examine the leaflets first.”
- MR06_PRE02｜scrub_primary｜「测量器械与细钳。」｜“Measuring instruments and fine forceps.”
- MR06_POST01｜anesthesia｜「心肌保护依既定节奏继续维护。」｜“Myocardial protection is being maintained on schedule.”

### MR07 — 冠状动脉钮与根部准备

- MR07_PRE01｜assistant_2｜「我牵开窦壁，避免压迫冠状动脉开口。」｜“I'll retract the sinus wall without compressing the coronary ostia.”
- MR07_PRE02｜lead_surgeon｜「给冠脉钮留足组织边缘和活动余量。」｜“Preserve sufficient tissue margins and mobility for the coronary buttons.”
- MR07_POST01｜scrub_primary｜「冠脉吻合的细线和器械已备妥。」｜“The fine sutures and instruments for coronary reimplantation are ready.”

### MR08 — 根部几何与人工血管测量

- MR08_PRE01｜lead_surgeon｜「测量瓣环和瓣交界高度，先确定几何关系。」｜“Measure the annulus and commissural heights before deciding the geometry.”
- MR08_PRE02｜assistant_2｜「根部外侧牵引由我保持。」｜“I'll maintain the external root exposure.”
- MR08_POST01｜scrub_secondary｜「人工血管尺寸记录已交给主台核对。」｜“The graft sizing notes have been passed to the main table for confirmation.”

### MR09 — 基底环缝线与近端固定

- MR09_PRE01｜scrub_primary｜「基底环缝线与人工血管已经在台。」｜“The basal ring sutures and graft are on the field.”
- MR09_PRE02｜lead_surgeon｜「这一圈按顺序走，注意不要伤到附近结构。」｜“Work around the ring in sequence, protecting the adjacent structures.”
- MR09_POST01｜assistant_2｜「近端牵引角度保持，准备下一步。」｜“I'll maintain the proximal exposure for the next step.”

### MR10 — 瓣交界重悬

- MR10_PRE01｜assistant_2｜「三个瓣交界的参照位置都能看清。」｜“All three commissural reference points are visible.”
- MR10_PRE02｜lead_surgeon｜「先校准高度，再固定瓣叶的空间位置。」｜“Set the heights first, then secure the geometry of the leaflets.”
- MR10_POST01｜scrub_primary｜「下一组细缝线已准备好。」｜“The next set of fine sutures is ready.”

### MR11 — 瓣叶对合测试

- MR11_PRE01｜lead_surgeon｜「检查对合高度，按计划做瓣膜测试。」｜“Check the coaptation height and perform the planned valve test.”
- MR11_PRE02｜assistant_2｜「我从另一侧看瓣缘位置。」｜“I'll check the leaflet edges from the opposite side.”
- MR11_POST01｜anesthesia｜「结果先记录，复灌以后还要用超声复核。」｜“We'll document this test, then reassess with ultrasound after reperfusion.”

### MR12 — 左冠状动脉吻合

- MR12_PRE01｜assistant_2｜「左冠脉钮由我托住，不施加额外牵拉。」｜“I'll support the left coronary button without additional traction.”
- MR12_PRE02｜lead_surgeon｜「先看血管走向，再下第一针。」｜“Check the vessel's course before placing the first stitch.”
- MR12_POST01｜scrub_primary｜「吻合线与备用细线保持在主台。」｜“The anastomotic and spare fine sutures remain on the main table.”

### MR13 — 右冠状动脉吻合

- MR13_PRE01｜scrub_secondary｜「右冠脉吻合所需细针线已经换上。」｜“The fine needles and sutures for the right coronary anastomosis are ready.”
- MR13_PRE02｜lead_surgeon｜「注意开口方向，不能留下扭曲和张力。」｜“Mind the ostial orientation. We must not leave twisting or tension.”
- MR13_POST01｜assistant_2｜「牵拉暂时解除，方便检查血管走向。」｜“I'll release traction so we can inspect the vessel's course.”

### MR14 — 远端升主动脉吻合

- MR14_PRE01｜lead_surgeon｜「把人工血管和正常的远端升主动脉接起来。」｜“Anastomose the graft to the healthy distal ascending aorta.”
- MR14_PRE02｜scrub_primary｜「血管缝线和止血材料已备妥。」｜“Vascular sutures and hemostatic supplies are ready.”
- MR14_POST01｜assistant_2｜「吻合口外观开始逐段复核。」｜“We'll inspect the completed anastomosis segment by segment.”

### MR15 — 排气、复灌及超声

- MR15_PRE01｜anesthesia｜「排气与复灌的步骤已经和团队核对，经食道超声准备观察。」｜“The de-airing and reperfusion sequence is agreed. TEE is ready for assessment.”
- MR15_PRE02｜lead_surgeon｜「按顺序恢复灌注。不要为了赶时间跳过排气。」｜“Restore flow in sequence. We won't rush past de-airing.”
- MR15_POST01｜anesthesia｜「冠状动脉灌注恢复，瓣膜与心室功能继续复核。」｜“Coronary perfusion has resumed. We continue evaluating the valve and ventricular function.”

### MR16 — 脱离体外循环

- MR16_PRE01｜anesthesia｜「节律、收缩功能与血流动力学一起评估，准备逐步降低支持。」｜“We'll assess rhythm, contractility, and hemodynamics together before reducing support.”
- MR16_PRE02｜lead_surgeon｜「先复核瓣膜和各吻合部位，再考虑脱机。」｜“Recheck the valve and all anastomotic sites before deciding to wean.”
- MR16_POST01｜circulating_primary｜「后续止血与转出所需物资在台外待命。」｜“Supplies for further hemostasis and transfer are standing by outside the sterile field.”

### MR17 — 止血与关胸

- MR17_PRE01｜scrub_secondary｜「最终器械清点与巡回共同核对中。」｜“The final instrument count is being verified with the circulating nurse.”
- MR17_PRE02｜lead_surgeon｜「确认止血、引流和关胸范围，再关闭。」｜“Verify hemostasis, drains, and the closure field before closing.”
- MR17_POST01｜anesthesia｜「转出前的监测与支持交接开始。」｜“We're beginning the monitoring and support handoff for transfer.”

---

## 5. 两套第一助手对白（完整节点覆盖）

**Codex 选择契约**：对每个 MRxx，插入且仅插入下面表中的一个 FIRST_ASSIST_PRE 变体。首通强制御堂、使用「教学」；全部返场使用「普通」。以下所有行的 speaker_role 均为 assistant_1，显示的姓名与立绘由编组 resolver 决定，不要硬编码「御堂」进通用台词。

| Stage | 首通：御堂教学 FIRST_ASSIST_PRE（CN / EN） | 返场：普通第一助手 FIRST_ASSIST_PRE（CN / EN） |
|---|---|---|
| MR01 | 「先想清楚，今天究竟要保留什么。」 / “First, be clear about what we're preserving today.” | 「术前影像与目标重建范围已经核对。」 / “We've reviewed the imaging and the intended extent of repair.” |
| MR02 | 「入路要干净。别在真正的手术开始前浪费视野。」 / “Keep the approach clean. Don't waste exposure before the real work begins.” | 「胸骨切开后，我会协助控制骨缘出血。」 / “After the sternotomy, I'll help control bleeding at the bone edges.” |
| MR03 | 「你的目标在根部，眼睛也得留给正常的升主动脉。」 / “Your target is the root, but keep the healthy ascending aorta in view.” | 「正常远端和病变根部的界限已经明确。」 / “The boundary between the healthy distal segment and the diseased root is clear.” |
| MR04 | 「要上体外循环了。你判断什么条件满足以后才能转机？」 / “We're approaching bypass. What conditions must be met before going on pump?” | 「插管位置清楚，抗凝确认后我们配合灌注团队转机。」 / “Cannulation sites are clear. Once anticoagulation is verified, we'll coordinate with perfusion.” |
| MR05 | 「停搏是争取来的时间，不是可以随便浪费的时间。」 / “Cardiac arrest gives us a window of time, not time to waste.” | 「阻断位置和心肌保护路径已经复核。」 / “We've reviewed the clamp site and cardioplegia route.” |
| MR06 | 「看瓣叶。别让五点三厘米这个数字替你做保瓣决定。」 / “Look at the leaflets. Don't let that five-point-three-centimeter number make the valve decision for you.” | 「我协助观察瓣叶活动度与组织情况，确认是否适合保留。」 / “I'll help assess leaflet mobility and tissue quality before confirming preservation.” |
| MR07 | 「冠状动脉开口不能靠力气拉出来。留够活动度。」 / “You can't free a coronary ostium by force. Leave it enough mobility.” | 「我维持根部暴露，注意两侧冠脉钮的组织边缘。」 / “I'll maintain root exposure and protect both coronary button margins.” |
| MR08 | 「别先选人工血管再去迎合它。尺寸要服从解剖。」 / “Don't pick a graft and force the anatomy to fit. Let the anatomy determine the size.” | 「瓣环尺寸与交界高度我会再交叉核对。」 / “I'll cross-check the annular measurements and commissural heights.” |
| MR09 | 「这一圈缝线决定整个根部稳不稳。别赶。」 / “This ring of sutures determines whether the root is secure. Don't rush.” | 「我保持根部张力，你专注基底环的每一针。」 / “I'll maintain root tension while you focus on each basal suture.” |
| MR10 | 「先看三个交界的相对高度，别只盯着某一片瓣叶。」 / “Compare all three commissural heights. Don't fixate on one leaflet.” | 「三处交界的位置我会逐个帮你确认。」 / “I'll help verify the position of each commissure.” |
| MR11 | 「对合不够好，就调整。‘差不多’不是一个检查结果。」 / “If coaptation isn't good enough, adjust it. ‘Close enough’ isn't a test result.” | 「我从另一角度检查瓣叶对合和可能的偏移。」 / “I'll inspect coaptation and any displacement from another angle.” |
| MR12 | 「左冠状动脉最怕你忽略它的方向，不怕你慢。」 / “The left coronary artery doesn't mind you taking time. It minds you ignoring its course.” | 「左冠脉钮的活动余量由我维持。」 / “I'll maintain adequate mobility of the left coronary button.” |
| MR13 | 「别只盯着针尖。退一步，看整条血管有没有扭。」 / “Don't stare only at the needle. Step back and see whether the whole vessel is twisted.” | 「右冠开口方向和吻合张力一起复核。」 / “We'll check right coronary orientation and anastomotic tension together.” |
| MR14 | 「远端这一接，重建的几何就定下来了。想清楚再落针。」 / “This distal anastomosis sets the final geometry. Think before placing the stitch.” | 「远端的口径与人工血管走向再核一次。」 / “One more check of the distal diameter and graft course.” |
| MR15 | 「放开阻断钳之前，先说清楚排气为什么不能省。」 / “Before releasing the cross-clamp, tell me why de-airing cannot be skipped.” | 「排气路径和恢复灌注顺序已跟麻醉团队复核。」 / “We've reviewed the de-airing path and reperfusion sequence with anesthesia.” |
| MR16 | 「我不替你说可以脱机。坂口，你自己把证据凑齐。」 / “I won't tell you it's safe to wean. Sakaguchi, assemble the evidence yourself.” | 「心室功能、节律和吻合部位出血都纳入脱机前评估。」 / “Ventricular function, rhythm, and anastomotic bleeding are all part of the pre-weaning assessment.” |
| MR17 | 「最后的整齐，不能靠把问题缝在里面。」 / “A tidy finish doesn't mean sewing a problem out of sight.” | 「关胸前我再协助检查一次止血和引流位置。」 / “I'll help with a final check of hemostasis and drain placement before closure.” |

**高价值节点的可选第二条第一助手台词**：只在该阶段已正常解决、且没有终止性失败或危机抢占时，于共用 POST 之前或之后播放以下 FIRST_ASSIST_POST；一台手术共六条。每条有互斥的首通／返场版本。

| Stage | 首通：御堂教学 FIRST_ASSIST_POST（CN / EN） | 返场：普通第一助手 FIRST_ASSIST_POST（CN / EN） |
|---|---|---|
| MR04 | 「看到了吗？交给机器的是循环，不是我们的责任。」 / “See? We hand circulation to the machine, not our responsibility.” | 「灌注与体温仍由团队持续交叉观察。」 / “The team continues cross-checking perfusion and temperature.” |
| MR06 | 「好。保瓣有条件，你没有忘。」 / “Good. You remembered that valve preservation has conditions.” | 「瓣叶条件已经复核，继续既定保瓣方案。」 / “Leaflet suitability has been confirmed. We'll proceed with the planned valve-sparing repair.” |
| MR10 | 「高度可以调整，盲目的自信可调整不了。」 / “Commissural heights can be adjusted. Blind confidence can't.” | 「交界定位后，我再检查整体对称性。」 / “Now that the commissures are positioned, I'll check overall symmetry.” |
| MR11 | 「现在你应该明白，为什么刚才那针不能省。」 / “Now you should understand why that earlier stitch couldn't be omitted.” | 「对合检查完成，准备冠状动脉吻合。」 / “The coaptation check is complete. Ready for coronary reimplantation.” |
| MR15 | 「别急着庆祝心脏跳起来。先看它跳得有没有效。」 / “Don't celebrate the heart beating yet. First check whether it is pumping effectively.” | 「复灌后的瓣膜与心室功能需要继续动态观察。」 / “Valve and ventricular function after reperfusion still need ongoing assessment.” |
| MR16 | 「很好。你开始像真正的主刀那样，看完整台手术了。」 / “Good. You're beginning to see the whole operation the way a lead surgeon should.” | 「逐步脱机已经完成，后续监测不能放松。」 / “We have completed the gradual wean. Monitoring must continue.” |

**句数控制**：每阶段共用三条＋第一助手 PRE 一条＝4 条；MR04、MR06、MR10、MR11、MR15、MR16 额外 POST 一条＝5 条。首通／返场均满足 Advanced OR V2 每阶段 3–5 条的密度要求。

### 5.1 教学提问的即时回应（不增加台词句数）

为了让御堂的教学不是「问完就没有人回答」，以下三处把 §4 对应的 **lead_surgeon PRE02 原位替换**为首通回答。返场则保留 §4 的普通 PRE02。其他共享台词无须分叉，替换后依旧是每阶段 4–5 句，不增加额外点击。

| Stage | 首通坂口回答（中文／English） | 返场坂口台词 |
|---|---|---|
| MR04 | 「抗凝达到要求、插管位置和回流路径都确认，才能安全转机。」 / “Only after anticoagulation, cannulation sites, and venous return are verified can we safely go on bypass.” | 使用 MR04_PRE02：「动静脉插管位置再确认一次。」 |
| MR15 | 「残留气体可能进入冠状动脉或体循环。排气完成，才能按步骤恢复灌注。」 / “Residual air could enter the coronaries or systemic circulation. We complete de-airing before restoring flow in sequence.” | 使用 MR15_PRE02：「按顺序恢复灌注。不要为了赶时间跳过排气。」 |
| MR16 | 「看超声、心室收缩和节律，也看每个吻合部位有没有出血。缺一项都不能急。」 / “I need the echo, ventricular function, rhythm, and bleeding checks at every anastomosis. We don't rush if one is missing.” | 使用 MR16_PRE02：「先复核瓣膜和各吻合部位，再考虑脱机。」 |

实现时保留这三条首通回答的唯一内容 ID（例如 MR04_PRE02_TEACHING），替代而非插在原台词后面。MR04 仍由玩家完成原有 Precision，坂口回答「安全条件」不自动判定该阶段成功。

**角色弧度**：御堂不再像 Relationship Lv1 那样测试坂口能否「跟上」，也不是 Lv3 CABG 那样由御堂主刀示范；这里是坂口主刀，御堂在第一助手的位置上逼他自己承担整台手术的判断。MR16 最终肯定他的不是「手法比我好」，而是「你终于看得见整个团队和整台手术」。

### 5.2 八个 P 节点专属 Precision Failed 文本

这组是 **Precision 判定失败的即时回应**，不同于阶段成功后的 POST 和危机中插话。每一次失败只使用与该病例模式对应的一句；speaker_role 均为 assistant_1，中文及英文逐项锁定。保留已有失败 HP 代价、助手救援与重试流程，不靠台词判定是否永久失败。

| P stage | 首通：御堂教学失败回应（CN / EN） | 返场：普通第一助手失败回应（CN / EN） |
|---|---|---|
| MR04 | 「别硬顶。插管的角度不对，先停下来重新确认。」 / “Don't force it. The cannulation angle is wrong. Stop and reassess.” | 「插管位置需要重新核对，暂时不要继续推进。」 / “We need to recheck cannula placement before proceeding.” |
| MR08 | 「尺寸不是猜出来的。把瓣环和交界的测量重做一遍。」 / “You don't guess the size. Repeat the annular and commissural measurements.” | 「这一组测量还不一致，先复核人工血管尺寸。」 / “These measurements don't agree yet. Let's recheck the graft size.” |
| MR09 | 「针脚层次偏了。不能为了赶进度牺牲根部支撑。」 / “That stitch is in the wrong plane. Don't sacrifice root support to save time.” | 「基底环的这一针需要重新定位。」 / “This basal ring stitch needs repositioning.” |
| MR10 | 「交界高度没对齐。停，重新找准基准。」 / “The commissural heights aren't aligned. Stop and reset the reference.” | 「瓣交界位置存在偏差，建议重新校准。」 / “There's an offset in the commissural position. I recommend recalibration.” |
| MR12 | 「左冠开口承受不了这种张力。退回来。」 / “The left coronary button can't tolerate that tension. Back up.” | 「左冠吻合区张力偏高，先放松牵引再检查。」 / “Tension is high at the left coronary anastomosis. Release traction and reassess.” |
| MR13 | 「这次不是针线的问题。你忽略了整条血管的走向。」 / “The problem isn't the suture this time. You lost sight of the vessel's course.” | 「右冠开口有扭曲风险，先停止这一段吻合。」 / “There's a risk of twisting at the right coronary button. Pause this anastomosis.” |
| MR14 | 「远端口径没接顺。再看一眼整体几何。」 / “The distal diameters aren't matched smoothly. Recheck the overall geometry.” | 「远端吻合的口径与张力需要调整。」 / “The distal anastomosis needs an adjustment in diameter matching and tension.” |
| MR16 | 「还不能脱机。先说哪一项证据不够。」 / “We're not ready to wean. Tell me which piece of evidence is missing.” | 「当前指标需要复核，先维持体外循环支持。」 / “These parameters need reassessment. Maintain bypass support for now.” |

**播放优先级**：P 未通过 → precision_failed 文本 → 既有 HP／助手救援或重试；若同一节点随后出现独立危机，继续调用危机处理。**完整 POST 判断见 §4.0：直接成功与失败后救援成功均播放一次正常 POST；失败且救援失败而未终止则跳过成功型 POST；危机未解决暂停，终止不播放。**角色分流与 §5 一致，绝不按 doc_emiko 姓名推断教学模式。不得在一次失败上同时播放旧 generic failed 与本表专属 failed，除非旧句是系统固定结算反馈而非角色对白。

### 5.3 专属危机对白（仅在对应危机类型可绑定时）

现有通用危机系统始终是安全回退。以下额外提供三组短专业对白，供 Codex 在**已经匹配到对应医学危机类型的条件下**替换其普通叙述，不改变危机概率、消耗或救援流程。若当前 Runner 仅支持通用危机文案，**保留通用版即可，本次不为三句对白扩张新的 Crisis Schema**。

**MR_C1 — 心肌保护／灌注监测异常**

- MR_C1_01｜anesthesia｜「灌注相关监测出现变化，暂停下一步，先复核。」｜“We have a change in perfusion monitoring. Pause the next step and reassess.”
- MR_C1_02｜assistant_1｜「先检查心肌保护路径和灌注反馈。」｜“Check the cardioplegia route and the perfusion response first.”
- MR_C1_03｜lead_surgeon｜「暂停操作。确认原因后再继续。」｜“Pause the procedure. We'll resume once the cause is clear.”

**MR_C2 — 冠脉钮吻合区疑似出血**

- MR_C2_01｜assistant_2｜「吻合区出现新的渗血，牵拉先保持。」｜“There's new oozing at the anastomosis. I'll hold the exposure.”
- MR_C2_02｜assistant_1｜「先定位渗血点，不要盲目追加缝线。」｜“Locate the bleeding point before adding any stitches blindly.”
- MR_C2_03｜lead_surgeon｜「维持视野，逐段检查吻合口。」｜“Keep the field clear. We'll inspect the anastomosis segment by segment.”

**MR_C3 — 脱机后循环指标异常**

- MR_C3_01｜anesthesia｜「降低支持后，循环指标需要重新评估。」｜“Circulatory parameters need reassessment after reducing support.”
- MR_C3_02｜assistant_1｜「先不要急着结束，复核心室功能和瓣膜表现。」｜“Don't rush to finish. Reassess ventricular function and valve performance.”
- MR_C3_03｜lead_surgeon｜「必要时维持支持，先把原因查清楚。」｜“Maintain support if needed. We'll identify the cause first.”

上述危机说话人不含固定人名，首通御堂与返场任意第一助手都可成立。若实际随机出的危机并非表中主题，**不允许错配这些台词**；应退回现有通用危机文本。

---

## 6. Day 3 原子结算后的首次成功剧情 — 《比教练更严格》

**不可交换的执行顺序**：进入 Day 3 → 调用现有 Advanced **一次性原子结算**（手术事实、首通状态、奖励、统计和 CLEARED／FAILED_LOCKED、返场资格）→ 根据已结算结果播放首次成功专属剧情或统一失败模板 → 退出事件。剧情展示**不得再次写入奖励或清除状态**；如果 UI 被重建，读取已结算记录后只处理显示，禁止二次结算，也不新增「御堂支持坂口」之类语义旗标。

场景：术后翌日，村上愛已脱离呼吸机、意识清楚，仍然疲惫，胸前有术后敷料与监护设备；不得写成当天就能起床跑步。若工程世界观的 Day 3 时间不足以确保清醒，须安排为医学状态允许后的首次短查房，但保留现有三日结算接口。

（监护仪规律作响。村上愛的声音还有些沙哑，看见御堂和坂口进来，先小心地挪了挪枕边的手。）

**村上愛**：「早上好……我猜这回不能下床给你们示范热身了。」  
EN: “Good morning... I suppose I can't get up and demonstrate a warm-up today.”

**坂口**：「今天的训练计划里，没有下床示范这一项。」  
EN: “Getting up to demonstrate isn't on today's training plan.”

**村上愛**：「那就是还有训练计划了。」  
EN: “So there is a training plan.”

**御堂**：「当然有。呼吸训练、止痛、逐步活动。一步都不能跳。」  
EN: “Of course. Breathing exercises, pain control, gradual mobilization. You don't skip steps.”

（村上愛看着胸前的敷料，终于问出了手术前一直没说出口的那句话。）

**村上愛**：「御堂医生，我以后还能跑步吗？」  
EN: “Dr. Mido, will I ever be able to run again?”

**御堂**：「我们做这台手术，最终不是为了让你一辈子躲着运动。」  
EN: “We didn't do this operation so you would spend the rest of your life avoiding exercise.”

**御堂**：「我们的目标，是让你的心脏今后还能像从前一样可靠地工作。」  
EN: “Our goal is for your heart to keep working as reliably as it did before.”

**御堂**：「等胸骨愈合、康复和复查都合格，我希望有一天能让你重新站上马拉松跑道。」  
EN: “Once your sternum has healed and your rehabilitation and follow-up results are good, I hope we can get you back onto a marathon course one day.”

**御堂**：「只是那时候，配速和心率要按我们商量好的计划来。不能再只靠自己的感觉。」  
EN: “But then your pace and heart rate will have to follow the plan we agree on. You can't rely on how you feel alone.”

（村上愛慢慢呼出一口气，嘴角扬起来。）

**村上愛**：「这可比以前教练给我的训练计划严格多了。」  
EN: “That's even stricter than the training plans my old coach used to give me.”

**御堂**：「你的教练不用替你重新接上冠状动脉。」  
EN: “Your old coach never had to reattach your coronary arteries.”

**村上愛**：「……说得也是。那我就从呼吸训练开始吧，御堂教练。」  
EN: “...Fair enough. I'll start with the breathing exercises, then, Coach Mido.”

**坂口**：「第一项：听见医生说『今天到这里』，就真的停下来。」  
EN: “Lesson one: when the doctor says ‘that's enough for today,’ you actually stop.”

**村上愛**：「这种项目，我可能比马拉松还不擅长。」  
EN: “I may be worse at that than I ever was at marathons.”

（御堂没有继续训话，低头确认监护与记录。她的语气仍旧平稳，先前那种绝不退让的锋利却稍稍缓了一点。）

**御堂**：「那就练。你最不缺的，不就是耐力吗？」  
EN: “Then practice. Endurance is the one thing you've never lacked, isn't it?”

（以村上愛简短的笑声收尾；不追加流泪致谢、不追加御堂私生活独白。**Day 3 原子结算已在本段剧情开始前完成**，此处仅结束显示，不再次给予奖励或重写 CLEARED／返场资格。）

### Day 3 失败与返场

- 首次失败：Day 3 **先按现有机制原子结算并记为 FAILED_LOCKED**，随后播放 Advanced 统一失败模板；不播放上述康复／重返跑道对白，也不在模板结束后再次结算。
- 返场：使用标准 Advanced 随机成年患者 Day 1/3 文字与同一术式手术关口，绝不让陌生随机患者声称自己是体育教师或认识御堂。
- 返场如选择御堂担任第一助手，仍按 §5 普通版发言，不重播 Day 1 教学与 Day 3 村上专属剧情。

---

## 6.5 可显示文本／演出指示与本地化契约（V1.2）

本稿原有以括号标出的场景描述**全部是导演提示 DIRECTOR_ONLY，不是屏幕字幕或 system narration**。它们指导背景、立绘、转运床、目光、停顿和术后呼吸音，不会被 Godot 原样显示，也不需要逐句英文版。若实现者准备把其中任意一句改成玩家可读的旁白，必须先交回编剧补齐正式 CN/EN 行并获得批准，**不得让 Codex 自行把导演提示塞进对白数组**。

只有下列类别进入 UI 文本：

1. Day 1、Day 2 全麻前短过场、Day 3 中带有说话人的 **中文对白及紧邻 EN 行**，严格按剧本顺序显示。
2. §4 团队共享 PRE/POST、§5 两套第一助手、§5.2 Precision 失败、§5.3 类型匹配危机中的中英台词（按条件加载，不全部同时显示）。
3. §3、§3.2 的**阶段显示标题、策略选项名称及玩家说明**；下表提供全部中英配对。表格说明文字、章节 A/B/C、Stage ID、数值测试条目和「Codex 约束」均为开发编辑信息。
4. §6.6 的**术式／患者／诊断及功能性 UI 提示**；首通与返场按病例实例类型使用不同患者显示名。

**可显示剧情标题**：

| UI 标题用途 | 中文 | English |
|---|---|---|
| 首次传奇病例标题 | 把心脏交还给跑道 | Back to the Starting Line |
| Day 1 章节标题（如 UI 支持章节名） | 没有症状的风险 | A Risk Without Symptoms |
| Day 2 麻醉前短场景标题（如 UI 支持章节名） | 手术室门口 | At the Operating Room Door |
| Day 3 成功章节标题（如 UI 支持章节名） | 比教练更严格 | Stricter Than a Coach |

**17 个阶段 UI 标题**：

| Stage | 中文 | English |
|---|---|---|
| MR01 | 手术核对 | Surgical Time-out |
| MR02 | 胸骨正中切开 | Median Sternotomy |
| MR03 | 心包及主动脉暴露 | Pericardial and Aortic Exposure |
| MR04 | 建立体外循环 | Initiate Cardiopulmonary Bypass |
| MR05 | 主动脉阻断与心肌保护 | Cross-Clamping and Myocardial Protection |
| MR06 | 主动脉瓣叶检查 | Aortic Valve Leaflet Assessment |
| MR07 | 冠脉钮与根部准备 | Coronary Buttons and Root Preparation |
| MR08 | 根部测量与人工血管选型 | Root Measurement and Graft Sizing |
| MR09 | 基底环缝线及近端固定 | Basal Sutures and Proximal Graft Fixation |
| MR10 | 瓣交界重悬与再植入 | Commissural Resuspension and Reimplantation |
| MR11 | 瓣叶对合测试 | Leaflet Coaptation Testing |
| MR12 | 左冠状动脉再植入 | Left Coronary Button Reimplantation |
| MR13 | 右冠状动脉再植入 | Right Coronary Button Reimplantation |
| MR14 | 远端升主动脉吻合 | Distal Ascending Aortic Anastomosis |
| MR15 | 排气、复灌与超声评估 | De-airing, Reperfusion, and TEE |
| MR16 | 脱离体外循环 | Weaning from Cardiopulmonary Bypass |
| MR17 | 止血与关胸 | Hemostasis and Sternal Closure |

**演出时序定案**：

- Day 1：A→B→C，到此结束 Day 1；当日不出现转运床、手术室入口或麻醉过场。
- Day 2：转运床前短场景（原 D，台词文字与顺序原样保留）→现有术前核对／全麻过场→MR01–MR17 Runner；**同一运行会话内不重复**，但从术前安全存档重新开始时正常重播，不保留持久化播放游标。
- Day 3：**先原子结算且只结算一次**→按结算结果播放首次成功剧情或统一失败模板；返场只走通用患者内容。

本地化验收：上述所有真正玩家可见文本都有中文／英文；没有悬空的章节标题、无说话人的括号字幕或只存在中文的 Strategy 说明。日志也只记录真正播放的对话，不把 DIRECTOR_ONLY 当成角色发言。

## 6.6 术式元数据与非剧情 UI 文本（V1.2 新增）

下列是玩家可见文本的双语内容合同，首次病例使用专属患者信息；返场继续采用既有随机成年患者资料，不能把村上愛的信息套用到其他患者。若现有 UI 已有同义的通用提示，Codex 可复用已注册组件并保持中英语义，不需同时弹出两套提示。

| 用途 | 中文 | English |
|---|---|---|
| 术式完整名称 | 保留主动脉瓣的主动脉根部再植入（David 术式）＋升主动脉人工血管置换 | Valve-Sparing Aortic Root Reimplantation (David Procedure) and Ascending Aortic Graft Replacement |
| 首通患者显示名 | 村上愛 | Ai Murakami |
| 首通病例诊断 | 主动脉根部及近端升主动脉瘤（未破裂、未夹层）；三叶式主动脉瓣，瓣叶适合保留 | Aortic root and proximal ascending aortic aneurysms (unruptured, without dissection); tricuspid native aortic valve with suitable leaflets for preservation |
| 首通病例说明 | 体育教师村上愛没有明显心脏症状，但影像显示主动脉根部扩张至约 5.3 厘米，升主动脉亦扩张。评估后计划实施保瓣根部重建及升主动脉置换。 | PE teacher Ai Murakami has no obvious cardiac symptoms, yet imaging shows a dilated aortic root measuring about 5.3 cm, along with ascending aortic enlargement. The team plans valve-sparing root reconstruction and ascending aortic replacement after evaluation. |
| 解锁／入口开放 | 御堂江美子的传奇术式已开放。 | Dr. Emiko Mido's legendary procedure is now available. |
| 锁定：高级转诊未开放 | 需要先解锁高级手术转诊。 | Unlock Advanced Surgery Referrals first. |
| 锁定：普通高级术式不足 | 还需要首次成功完成 {remaining} 种不同的普通高级术式。 | Complete {remaining} more distinct first-clear Advanced Regular procedures. |
| 锁定：关系不足 | 需要先完成御堂江美子的 Lv5 事件。 | Complete Emiko Mido's Lv5 relationship event first. |
| 锁定：资源未准备好 | 本例手术资源尚未准备完成。 | The assets and procedure data for this case are not ready yet. |
| 锁定：第一助手无法排班 | 御堂医生目前无法担任第一助手，请调整排程后再试。 | Dr. Mido is unavailable as first assistant. Adjust the schedule and try again. |
| 首通确认 | 安排村上愛的传奇手术？首次挑战结束后，无论成败均不能重新领取此首通事件。 | Schedule Ai Murakami's legendary surgery? Once this first challenge ends, the story case cannot be accepted again, regardless of the outcome. |
| 首通成功提示 | 传奇术式首次成功。本术式已加入普通高级手术返场池。 | Legendary procedure cleared for the first time. This procedure is now eligible for the regular Advanced Surgery replay pool. |
| 首通失败提示 | 传奇术式首次挑战已经结束，本例无法再次接诊。 | The first legendary challenge has ended. This story case cannot be accepted again. |
| 返场入口说明 | 再次执行本术式；第一助手与其他岗位可以自由编组。 | Perform this procedure again; first assistant and other team roles may be assigned freely. |

`{remaining}` 是非剧情 UI 的动态参数占位，Codex 必须映射为项目真实的本地化插值语法，不能原样显示花括号或把数字写死。所有提示遵从已有权限、可用状态和重入逻辑，不为提示新增一套独立旗标。

**补充翻译／UI 文案授权**：授权 Codex 对尚缺英译的 UI 元数据进行**忠实翻译**，并按现有工程接口编写必要的非剧情入口、错误、锁定、完成、冷却和资源状态提示。**不得补写、删改或擅自润色人物对白**；若涉及剧情人物说话、隐含关系语义或新叙事场景，必须退回编剧审定。所有新增玩家可见提示必须中英齐备。

---

## 7. 工程接入边界与验收

### 7.1 Codex 应审计的实际文件

1. Advanced procedures registry 的真实 schema：**新注册** procedure ID、明确的 Legendary 显式分类、stages、kind、hp_base、difficulty、specialty_tag、physio_stress、options／Strategy；复用当前字段，避免未经审查杜撰。
2. Advanced Referral 三日 Episode／Day 3 结算和首通失败锁定逻辑：五个不同 ADVANCED_REGULAR 首通的既有聚合函数与御堂 Relationship Lv5 clear Gate。**Day 3 必须先执行原子结算再展示剧情；反复打开剧情不能重复写奖励和首通状态**。
3. First-story forced assistant 的**排班与 14 天助手冷却**检查，以及返场的完整自由编组；若首次绑定首助的同伴不合格，正确处理可见原因，不偷偷选别人。
4. Advanced OR Team Dialogue V2 的真实 parser／播放时序：共用连续 BEFORE/AFTER＋根据当前 episode 类型切换第一助手对白；八个 P 的 precision_failed 支持两套互斥内容；如目前只支持旧 stage_entry 随机候选，先完成兼容性的 V2 适配。**POST 必须遵守 §4.0 三分支契约**，不得把「发生过 Precision 失败」等同于「最终阶段未完成」。
5. 体外循环期间生理显示／对话与危机覆盖：核对 §3.1 的 hp_base／difficulty／hp_failed_extra／specialty_tag、已明确的 `low / medium / high` 压力映射与 §3.4 工程定案基础生理效果，以及 §3.2 六项 Strategy 的一次性数值。§3.3 只保留三个检查点，**危机概率与实际 HP 代价必须经现有生理、随机值、团队修正计算**，不能执行旧稿固定百分比／HP；**终止条件是 HP 耗尽或生理失败，不是 Precision 失败次数达到 3**。
6. 已 CLEARED 传奇加入每周一 ordinary Advanced 返场候选**仅改变抽取资格**；不改两例独立有放回抽样、三格普通首次病例 FIFO、月度 1/15 解锁、薰 Quest、Quick 禁止、奖励与旧术式。
7. Art manifest：以 §7.1.1 的「用户提供／新制作／指定复用」清单作为首通资源范围。所有实际资源路径必须从项目已注册映射取得；开发期缺图可登记 TODO 或使用**已注册**安全回退，但正式开放 `runtime_ready` 前必须逐项通过资源验收，不能虚构可加载路径。系列生图必须实际输入用户提供的原作种子图，不以 AI 生成图取代身份锚点。
8. 保存与恢复：手术事件期间**禁止玩家持久存档**；针对 Runner 幂等性的术中测试只用内存快照。玩家持久存档测试仅在术前／术后安全边界进行，确认时间、数值、奖励稳定；Day 2 转运床过场不持久化播放游标。

### 7.1.1 美术交付清单与开放 Gate（V1.2 定案）

此处确定**制作责任与最低画面覆盖**，不是声称图片已经存在或已能由 Godot 加载。村上愛的原作种子图由用户在素材研究对话中提供，但本稿不推定该附件已被转存到当前游戏目录；Codex 应先验证实际锚点和资源文件，再登记具体资源 ID。

| 素材 | 来源／制作决策 | 最低交付及验收要点 |
|---|---|---|
| 村上愛原作种子立绘 | **用户已提供，身份参考输入** | 查证实际附件与可访问路径；所有后续人物绘图必须把这张原图真实传给生图工具，以其五官、年龄感、体型与画风为最高优先级 |
| Day 1 常服立绘与表情 | **新制作** | 一套常服基础立绘，覆盖自信、不解、认真、略紧张等状态；不得复用不合语境的手术患者表情 |
| Day 1／Day 3 病房及术后立绘 | **新制作** | 病房／术后装束、疲惫清醒、苦笑、放松微笑；胸前敷料与监护器械保持相应时点的状态，不必新增无剧情用途的服装 |
| Day 2 转运床画面 | **新制作** | 专属过场画面：术前清醒、转运床与医护核对情境，身份一致；只在 Day 2 麻醉前出现 |
| 全身麻醉过场 | **指定复用现有 Advanced 通用过场** | 验证该过场真实注册、能衔接转运床场景且不会显示其他具名患者；不合用时列为新制作阻塞 |
| 胸部手术台基础图 | **拟复用已注册胸外科通用台面／铺巾资源** | 验证仰卧、正中胸骨切开位置、手术铺巾与导管/设备构图一致；没有兼容资源则转为新制作，不能错用腹部或妇科图 |
| 胸骨切开／切皮阶段术野 | **新制作** | 至少一张与胸部台面兼容的起始切开图或差分 |
| 主要术野 | **新制作** | 至少一张体外循环下的主动脉根部术野基底图，尺寸和视角适配 Runner |
| 关胸／关闭阶段术野 | **新制作** | 至少一张与前述同视角、层次可连续对应的术后关闭图或差分 |
| 主动脉根部重建专用差分 | **新制作，纳入本传奇首通交付** | 至少一张展示人工血管与保瓣再植入关键关系的术野差分，用于 MR09–MR11；不得把它等同于普通胸部切口贴图 |
| 冠状动脉钮吻合专用差分 | **新制作，纳入本传奇首通交付** | 至少一张展示冠脉钮与人工血管再吻合的术野差分，用于 MR12–MR13；具体左右视角和张力表达由美术解剖核验 |

**验收顺序**：先确认种子图 → 完成或核对立绘／通用过场 → 建立相容的胸部台面和三张基础术野 → 完成两张关键专属术野差分 → 在 Godot 实际加载、阶段切换、语言、比例和视觉连续性测试中逐项验收。开发期可以使用合法占位资源，但**正式可接诊前必须完成上述资源验收**；不得因为剧情和数值已经写完就提前设为 `runtime_ready`。

### 7.2 短自动验收测试

| ID | 测试 | 期望 |
|---|---|---|
| LEG-M01 | Advanced 未开启、或仅四种不同普通 Advanced 首通 | 御堂传奇不可接诊 |
| LEG-M02 | 五种不同 ADVANCED_REGULAR 已首通，但御堂 Lv5 未 clear | 御堂传奇不可接诊 |
| LEG-M03 | 五种不同 Advanced 首通＋御堂 Lv5 clear | 专属传奇可接诊，不占普通三格、不走 1/15 release_order |
| LEG-M04 | 首通 Day 1 编组 | 第一助手固定御堂，其他岗位正常选择；无法满足冷却时提示不可排程 |
| LEG-M05 | 首通 Day 2 MR01–MR17 | 17 关口都能进入，御堂教学 A1 台词按次序出现，每阶段 4–5 句 |
| LEG-M06 | 首通在 MR12 冠脉吻合发生 Precision 失败或危机 | 按 §4.0 区分救援结果；危机未解决暂停 POST；不重复播同一教学段 |
| LEG-M07 | 首次 Day 2 成功并进入 Day 3 | **先原子结算一次为 CLEARED／发奖／开放返场**，再播放村上愛专属结尾且仅在此首通事件播放；满足现有冷却后可在普通周一返场池出现 |
| LEG-M08 | 首次 Day 2 失败并进入 Day 3 | **先原子结算一次为 FAILED_LOCKED**，再播放统一失败模板，不入返场池且不补发成功奖励 |
| LEG-M09 | 传奇 CLEARED 后周一刷新 | 仍固定抽两例、允许两例同术式；传奇与普通 Advanced 使用同一个池，随机患者各有不同 case ID |
| LEG-M10 | 返场第一助手随机选择任意合格角色（含御堂） | 普通 FIRST_ASSIST 台词映射当前真实头像／姓名，不触发教学版、不播放村上愛个人剧情 |
| LEG-M11 | 返场失败 | 不撤销原 CLEARED，不影响该术式后续返场资格 |
| LEG-M12 | 旧 Advanced / Ordinary / Artoria Legendary Gate | 数据解析、周计划、剧情条件、Quick 与既有规则未被误改 |
| LEG-M13 | 以 `surgery_master_` 前缀注册本台并检查类别 | 显式识别为 `LEGENDARY_STORY`（或代码中的真实同义枚举）；不得按 `ADVANCED_REGULAR` 计算五例门槛，不得无故丢失返场资格 |
| LEG-M14 | 同一台手术累计三次 Precision 失败，但 HP 尚未耗尽且生理指标未触发终止 | 继续现有 Runner；失败次数只累计统计，绝不触发新的「三次失败退出」 |
| LEG-M15 | MR05／MR11／MR15 分别选择 A、B；**术中仅使用内存快照测试**重复回调；术前／术后安全边界再做持久存档测试 | 每个 S 节点只显示两项中英齐全的策略；选定效果应用一次，额外时间、HP 与生理增量符合 §3.2；玩家持久存档**不包含术中策略／阶段进度** |
| LEG-M16 | 分别在首通、返场触发八个 P 的 Precision 失败 | 对应 §5.2 专属失败回应，仅播放一套第一助手文本；按现有 HP／救援／重试机制推进，失败时不误播成功 POST |
| LEG-M17 | Day 1 收尾、Day 2 麻醉诱导及从术前安全存档重开的事件序列 | 原 D 过场**同一运行会话内只播一次**，从术前安全存档重新开始则正常重播，**不持久化播放游标**；Day 1 无转运床；DIRECTOR_ONLY 不进入字幕 |
| LEG-M18 | MR_C1／MR_C2／MR_C3 分别触发及未触发，或危机类型不符 | 只调用原生**生理驱动**危机检查点与动态 HP 代价一次，不强制 18%／27%／20% 或 9／12／10 HP；医学主题匹配才用 §5.3，否则使用通用对白 |
| LEG-M19 | 输入旧设计索引 0、1、2、3、4、5，验证 17 行实际 stage 配置 | 分别落到 low、low、medium、medium、high、high；运行配置无 0–5 数字标签；索引 0 不关闭原生危机判定，压力标签不直接重复扣 Stability |
| LEG-M20 | 在代表性 P 阶段测试直接成功、失败后救援成功、失败且救援失败但 HP／生理尚未终止 | 前两者均恰好播放一次正常 POST，第三者跳过成功型 POST 并按既有失败规则继续；危机未解决暂停，实际终止不播放 |
| LEG-M21 | 新术式整体参数、基础生理效果及 Surgery 80／90／100 模拟 | Codex 提交三个整体字段最终值、17×4 基础生理效果表及模型统计；无其他术式／公共公式修改，不能未核验就标记 runtime_ready |
| LEG-M22 | 首通、锁定、资源不足、排班冲突、成功、失败及返场的所有可见 UI | 术式全名、患者名、诊断、病例说明与提示中英齐全；{remaining} 正确插值；不擅自新增人物对白 |
| LEG-M23 | 使用已登记通用图、美术 TODO、缺少专用术野差分三种资源情况 | 开发态允许合法占位，缺资源时仍锁定正式接诊；完成 §7.1.1 所有资源验收之后才允许 runtime_ready |
| LEG-M24 | Day 3 原子结算后重复进入显示界面／重新构造剧情 UI | CLEARED／FAILED_LOCKED、奖励、统计及返场资格只写一次；剧情可按现有界面规则显示，不触发第二次原子结算 |
| LEG-M25 | 术中尝试玩家持久存档，与术前／术后安全边界持久存档分别测试 | 术中玩家保存不可用；安全边界保存恢复后时间、数值与奖励一致，不出现术中阶段或策略进度存档 |

### 7.3 配套医学资料（创作与 Codex 医学核对）

- 2022 ACC/AHA Aortic Disease Guideline，主动脉根部术式适应证和瓣膜适合时的保瓣建议： https://pmc.ncbi.nlm.nih.gov/articles/PMC9876736/
- 2024 手术论文 Valve-Sparing Root Replacement: Reimplantation Technique，保瓣根部重建与冠脉再植入步骤： https://pmc.ncbi.nlm.nih.gov/articles/PMC10980923/
- 2025 AHA/ACC 运动员心血管疾病科学声明，胸主动脉瘤修复后竞技运动恢复需胸骨愈合、共同决策及持续随访： https://pmc.ncbi.nlm.nih.gov/articles/PMC12145891/
- 原作村上愛资料以游戏脚本 OPE3AM_dialogue_legacy_ja.md 的体育教师／学生时代马拉松运动员两处信息为依据；主动脉病情和本台手术完全属于 Hoshimi AU 新创。

---

## 8. 交付状态

- **V1.2 已完成的内容合同**：三日首通故事、David 保瓣 17 关口／645 分钟基线、每阶段 HP 与 P 难度／失败额外 HP、压力索引到 `low / medium / high` 的确定映射、三个沿用动态 resolver 的危机检查点、三个 S 关口共六项中英策略；17×2 套第一助手 PRE、6×2 套重点 POST、八个 P 各两套失败回应、三组可选类型匹配危机对白、17 关口团队共用对白；三种 Precision／救援结果的 POST 行为、Day 3 **先结算再播剧情**、双语功能 UI 文本和 25 项验收测试。
- **V1.2 已确定美术范围**：原作种子图作为身份锚点；常服、病房／术后、转运床及三张基础术野为新制作；全麻过场指定复用；胸部台面资源优先核实复用；主动脉根部重建与冠脉钮吻合差分均纳入新制作。开发期可缺图，正式开放前必须逐项验收。
- **明确授权 Codex 定案后报告**：`base_difficulty`、`training_ceiling`、`reward_tier` 及 17 阶段四项基础生理效果，完成 Surgery 80／90／100 的模拟与数据表；只修改本台配置，不改变其他术式或通用公式。不得在表格完成前声称本台 `runtime_ready`。
- **工程对接事项（无需编剧再补人物对白）**：`LEGENDARY_STORY` 的显式注册、`cardiac` 专科枚举核对、P 失败解析器支持、教学／返场分流、首通固定御堂第一助手、三人剧情显示、策略额外 HP 扣费、原生危机与传奇返场资格，都由工程根据现有接口处理。非剧情 UI 的缺漏授权忠实翻译或补写；人物对白仍受锁定规则保护。
- **未实装**：Godot procedure 注册、真实 schema 及数值模拟确认、Runner 接入、正式美术资源、自动测试、术中禁止持久存档与安全边界存档验证。工程集成后以实际运行结果为准。
