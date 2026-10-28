# Hoshimi Hospital / 星见医院
# 南条小夜香 Staff-as-Patient — 专属术前／术中／术后对白 V1.2（CN / EN）

> **状态：编剧填词审稿稿，不是可直接接线的最终 Codex 数据表。** 按用户提供 `sayaka_staff_as_patient_dialogue_fill_list.md` 的 A–F 顺序编写；小夜香所有新增台词均为候选文本，尚未获用户逐句批准。没有修改已定稿的 Lv5 A/B/C 事件及其后日谈。
>
> **明确缺口：** 尚未取得 `data/surgeries/patient_interactions.json` 的实际 6 类主题 pool / `actions[].id` 与选项文案、`data/patients` 正式 schema、团队岗位与发言节点清单。故 C2 提供完整的 **2 组 × 每组 prompt + 3 种语义回应**，但第三项如果实际池不存在应删除；所有选项均标记为“待对应实际 action ID”，不能据此生成伪 ID。E 段是角色／岗位模板，实际登场者确定后再绑定。B1a 的医学专业说明必须插入所选术式的现有权威说明，不能拿一段通用俏皮话取代真正的术前说明。
>
> **人物语气：** 她愿意主动尝试、熟悉医疗但并非每个专科都精通；在场面没变难之前调情从容，真实准备和下刀后会惊叫、嘴硬、求助、抱怨、疲惫。不会因为想以后再来就把眼前的疼痛写成假装。只对坂口本人偶尔直呼「坂口」，团队在正式环境下更多叫「坂口医生」。
>
> **V1.1 已保留的修订范围：** 按用户反馈重点修订 **B1 术前最后确认／助手稳定、B2 术前准备变体、B3 切口标记** 的患者对白。把屈辱、无助、漫长等待、焦躁与真正下刀前的恐惧写成逐渐累积的主观体验；**不是所有术前节点都必须极度崩溃**，保留小夜香偶尔嘴硬、玩笑与职业本能。没有新增任何 runner 节点，没有改变术式、麻醉、取消、计奖或声望规则。保持全麻分支不出现术中患者发言。所有替换台词均提供逐句对应英文。修改仍属于编剧候选，尚待用户审阅确认。
>
> **V1.2 本轮唯一新增台词：** A1b 的 **5 条特殊术式邀约回应（中英对应）**。保留 A1 原三条普通随机台词，以及 V1.1 其余所有已写候选对白，未对既有台词作文学性改写。特殊邀约需按**当前选择的术式性质**择一命中；不能仅凭术式名含有“切除”就误判为器官全摘。**目前未拿到实际术式枚举、类别标签和邀约选择器实现，因此下列条件是写作语义，不是已存在的引擎字段。**
>
> **关于术后：** 当前项目**没有病房恢复事件／可交互恢复环节**。D 段 `postop_relief` / `postop_teasing` 仅为未来保留候选，不得因此扩建病房恢复系统或强行播放；实际手术完成、全麻苏醒节点及提前停止出口是否存在，需 Codex 根据 Runner 核实。
>
> **接线原则：** 术前准备的实际时长与步骤因术式和排程而异；台词中的“好久”“还要等多久”是小夜香的主观体感，**不宣称所有手术必须在台上等两小时**。仅在对应的实际 `reaction_variants` 节点触发该话，不无条件强行播放灌肠、备皮、导尿等步骤。
>
> **执行边界：** 医护界面先选择已解锁术式 `{procedure_name}`，再邀约；病房已有未完成患者则拒绝。Staff-as-Patient 不增减正反声望；错术式、不麻醉不触发普通声望惩罚。全麻下刀及全麻术中不出现患者语言回应。术式重复经验及首次／第二次／第三次收益沿用既有系统。

---

## A. 邀约、确认与拒绝

### A1. `SAP-SAYAKA-INVITE-*`（从 3 条随机）

| ID | 中文：南条小夜香 | English: Sayaka |
|---|---|---|
| `SAP-SAYAKA-INVITE-01` | 「{procedure_name}？呵呵，你还真会挑呀。好，我答应。不过到了手术台上，我要是叫出声，可不许你事后拿来笑我哦！」 | “{procedure_name}? Hehe, you certainly know how to pick one. All right, I'm in. But if I end up screaming on the operating table, you don't get to tease me about it afterward!” |
| `SAP-SAYAKA-INVITE-02` | 「哦，这次是{procedure_name}呀。听名字就知道不会太轻松……不过难得有机会从患者这边体验一次，我还真有点好奇呢。你要认真对待我哦，坂口医生。」 | “Oh, {procedure_name} this time. Even the name tells me this won't be a walk in the park... But a chance to experience it from the patient's side? I'm genuinely curious. Take good care of me, Dr. Sakaguchi.” |
| `SAP-SAYAKA-INVITE-03` | 「{procedure_name}？行呀。不过这次我可不会像第一次那样，傻乎乎地以为进手术室就能马上开刀了。给我排好时间，别让我在台上等到怀疑人生哦！」 | “{procedure_name}? Sure! But I'm not going to make the same mistake as last time and think surgery starts the moment I enter the OR. Schedule it properly—don't leave me lying there long enough to question my entire existence!” |


### A1b. 重大／特殊术式邀约：5 条专属覆盖（V1.2 新增）

**播放时机：** 与 A1 相同——玩家在医护界面选定已解锁 `{procedure_name}` 并发出邀约，确认病房没有未完成的手术患者后。此处是**A1 普通邀约池的有条件替代**，不是追加的第二段对白，也不引入额外选择或新的术前流程。

**写作意图：** 小夜香在 Lv5 已经体验过真实手术，又知道切除器官会恢复。她能够自愿接受新手术，**但对身体将真正被切除、以及漫长的准备和等待仍有不安**。她会半开玩笑地承认害怕，而不是每次都兴致勃勃地把重大器官切除当成普通体检。以下每句最终都明确接受邀约，不与现有确认逻辑冲突。不能从此推导无麻醉、低风险或任何系统奖励变化。

| 语义 ID（候选，不是已证实的 engine ID） | 精准适用范围（须由 Codex 按实际术式清单确认） | 中文：南条小夜香 | English: Sayaka |
|---|---|---|---|
| `SAP-SAYAKA-INVITE-MAJOR` | 无更精确匹配的高难度／大型手术；主要表现准备与手术规模带来的压力 | 「{procedure_name}……坂口，你这次还真没跟我客气呀。平时开术前会议，听到这种手术我还能边听边做笔记。可一想到这回是我躺上去，光是术前准备恐怕就够我受的了……呵呵，我现在笑得是不是有点勉强？……好啦，我答应。」 | “{procedure_name}... Sakaguchi, you're really not going easy on me this time. When I hear about an operation like this at a pre-op conference, I can just sit there taking notes. But imagining myself on the table this time... the preparations alone might wear me out. Hehe, does my smile look a little forced? ...All right. I accept.” |
| `SAP-SAYAKA-INVITE-HYSTERECTOMY` | **子宫完整切除**；不得用于仅切除肌瘤、附件或部分组织的术式 | 「{procedure_name}……要把我的子宫整个摘掉呀。明明知道以后会恢复原样，连子宫都会长回来……可是想到手术那天，你们真的会把它从我身体里取出来，我怎么突然有点害怕了耶……喂！我又没说不做啦！让我先害怕一下嘛。」 | “{procedure_name}... You're going to remove my whole uterus. I know everything will go back to normal afterward, that even my uterus will grow back... But imagining you actually taking it out of my body during the operation—why am I suddenly getting scared? ...Hey! I didn't say I wouldn't do it! Let me be scared for a minute, okay?” |
| `SAP-SAYAKA-INVITE-MAJOR-GYN` | 其他**大型妇科／盆腔手术**；不与子宫全切专用项重复 | 「{procedure_name}……唔，这个切除范围还真不小呀。以前我跟患者解释的时候，总觉得只要手术顺利就没什么可怕的。可今天一想到，你们要在我身上动这么大的手术……哎呀，原来光听别人讲手术计划，都能让人紧张成这样。好吧，我答应，不过你得让我好好做心理准备哦！」 | “{procedure_name}... Mm, that's a pretty extensive operation. When I used to explain procedures to patients, I always thought a successful operation meant there wasn't so much to fear. But imagining you doing something this major to me... Wow. I never knew just hearing the surgical plan could make me this nervous. All right, I accept—but let me get myself mentally ready first!” |
| `SAP-SAYAKA-INVITE-MASTECTOMY` | **整侧乳房切除／全乳切除**；不得用于部分乳腺组织切除或乳房良性肿块切除 | 「{procedure_name}……真的要把我的乳房切下来呀。明知道以后会恢复得跟原来一样，可是……光想到自己真的要在手术台上失去它，我就有点舍不得了耶。……哎呀，你别这样看我啦！我知道这只是暂时的嘛！不过，知道是一回事，真的躺上去又是另一回事呀……好，我愿意试一次。」 | “{procedure_name}... You're really going to remove my breast. I know it'll return to exactly how it was afterward, but... when I think about actually losing it on the operating table, I can't help feeling reluctant. ...Oh, don't look at me like that! I know it's only temporary! But knowing that and actually lying down for it are two different things... All right. I'm willing to try it once.” |
| `SAP-SAYAKA-INVITE-ORGAN-REMOVAL` | **完整摘除重要脏器／器官**的术式，排除已被妇科／乳房专属项覆盖者；不能套用于部分胃切除等“部分切除” | 「{procedure_name}……等、等等，这个是要把整个器官都拿出来吧？呵呵，真是的，我明明知道以后还会长回来，可想到那天你要亲手把它从我身体里摘出来……光是听名字就觉得好恐怖呀！……不过难得有这种机会，我还是想试试看。坂口，这次你可要好好照顾我哦。」 | “{procedure_name}... W-wait, this means you're going to take the entire organ out, right? Hehe, honestly... I know it'll grow back afterward, but imagining you removing it from my body with your own hands... Just hearing the name is terrifying! ...Still, it's such a rare chance that I want to try. Sakaguchi, you'd better take very good care of me this time.” |

**唯一命中与回退规则（建议，非已核实引擎行为）：**

1. 先核对**具体切除类型**：`HYSTERECTOMY` / `MASTECTOMY` 各自对应明确术式，命中则只播本条；不再叠加 `MAJOR`。
2. 其余大型妇科／盆腔操作命中 `MAJOR-GYN`；其他**完整重要脏器摘除**命中 `ORGAN-REMOVAL`。交叉分类必须在术式表中逐一确认；若仍重合，优先更具体、不会误述切除范围的台词。
3. 剩余高难度或大型手术命中 `MAJOR`；普通术式继续使用 A1 原三条随机之一。**不得用 `MAJOR` 代替所有带“切除”的术式。**
4. 当前五条均为**每类别一条候选**，不是要求新增五个永久硬编码类别或五组随机池。如果 Runner 不支持条件邀约覆盖，Codex 应先报告现有可用机制与最小接线选项，待用户确定，不得自行创造接口或修改人物对白。
5. `{procedure_name}` 的实际本地化与模板展开必须和 A1 完全共用已有机制。若当前 Runner 不支持替换，在接线前报告，而不是直接显示大括号变量。

### A2. 病房已有患者

| ID | 中文：南条小夜香 | English: Sayaka |
|---|---|---|
| `SAP-SAYAKA-WARD-BUSY-01` | 「等等，你病房里不是还有一位等着开刀吗？先把人家照顾好啦！我又不会跑掉，等你忙完再来邀请我嘛。」 | “Wait, don't you still have a patient waiting for surgery in the ward? Take care of them first! I'm not going anywhere. Come ask me again once you've finished.” |

---

## B. 术前准备与病房回应

### B1. 核心 `reaction_lines`

| Key | 中文：南条小夜香 | English: Sayaka |
|---|---|---|
| `procedure_mismatch` | 「等一下！我记得我们约好的不是这个术式吧？喂，坂口，别光顾着看手术单，先跟我把变化讲明白呀。我是肯让你开刀，又不是连自己要做什么都不问！」 | “Hold on! That's not the procedure we agreed on, is it? Hey, Sakaguchi, stop staring at the chart and explain what's changed. I'm willing to let you operate, but that doesn't mean I won't ask what you're doing to me!” |
| `explain_plan` | 「我也当过给患者说明的人嘛，流程我大致懂。不过今天换我躺上去……从哪儿开始、关键步骤怎么做、我清醒的时候会感觉到什么，你还是认真讲给我听一次吧。」 | “I've been the doctor explaining procedures, so I know the general routine. But today I'm the one on the table... Tell me where you start, what the crucial steps are, and what I might feel if I'm awake. Properly, please.” |
| `brief_plan` | 「嗯，术式我记住了，麻醉方式也听清楚了。你讲得这么简短，是怕我反过来考你吗？呵呵……不过该核对的部分可别省哦。」 | “Mm, I've got the procedure, and I heard the anesthesia plan. Such a short explanation—worried I'll start quizzing you? Hehe... Just don't skip the checks that matter.” |
| `last_reassure` | 「……我知道你们会按计划来。可一想到接下来要接受一项项准备，最后躺在手术台上让大家围着我忙……我就有点笑不出来了耶。坂口，等会儿别丢下我一个人胡思乱想哦。」 | “...I know you’ll follow the plan. But thinking about all the preparations still ahead, and then lying on that table with everyone working around me... I’m not finding it so easy to smile anymore. Sakaguchi, don’t leave me alone with my imagination, okay?” |
| `choose_general` | 「全麻呀……那我就是闭上眼，再睁开眼就结束了？虽然有点可惜，什么都看不到……不过这次我听你的，醒过来可要好好告诉我经过哦。」 | “General anesthesia, huh... So I close my eyes, and when I open them, it'll all be over? Shame I'll miss the whole thing... But I'll go with that this time. You'll have to tell me all about it when I wake up.” |
| `choose_epidural` | 「硬膜外呀。也就是说我还能清醒着听你们说话？呵呵，好像挺适合我。不过如果麻醉范围不够，你可得老老实实告诉我怎么办哦。」 | “An epidural, then. So I'll still be awake to hear you all talking? Hehe, that sounds rather like my kind of thing. But if the block doesn't cover enough, tell me plainly what the plan is, okay?” |
| `choose_local` | 「局麻？嗯……至少我不用一觉睡过去。可是只麻切口附近，对吧？深一点的时候会有什么感觉，你先跟我讲清楚，别等我吓一跳才说呀。」 | “Local anesthesia? Mm... At least I won't sleep through it. But that only numbs the area around the incision, right? Tell me what I might feel deeper in, before I get a nasty surprise.” |
| `choose_none` | 「……这次又不麻醉？你还真敢选呀，坂口。好吧，既然说好了我就试试看……不过我先声明，等会儿我要是叫得很难听，你可不能嫌弃我！」 | “...No anesthesia again? You really did choose the bold option, Sakaguchi. All right, we agreed, so I'll try... But let me make one thing clear: if I scream my head off, you're not allowed to complain!” |
| `induction_reassure` | 「嗯……我知道，慢慢呼吸就好。喂，坂口……等我醒了，你要在……」 | “Mm... I know. Just breathe slowly. Hey, Sakaguchi... when I wake up, you'd better be...” |
| `insist_without_anesthesia` | 「别再问我是不是逞强了啦！我知道会疼，上次又不是做梦……只是知道归知道，真正等着你下刀时，我还是会害怕的嘛。」 | “Stop asking whether I'm just trying to act tough! I know it hurts—last time wasn't a dream... Knowing that doesn't stop me from being scared when I'm actually waiting for you to cut.” |
| `assistant_stabilize_none` | 「啊，等一下……我知道要保持不动！可我现在整个人都绷着，麻烦你扶稳一点……别让坂口看见我抖成这样啦。」 | “Ah, wait... I know I have to stay still! But I'm tense all over. Please hold me steady... And don't let Sakaguchi see how badly I'm shaking.” |
| `assistant_stabilize_local` | 「好、好，我配合。局麻是有用啦，可人家知道你们手里拿着什么，哪能完全不紧张呀？」 | “O-okay, I'll cooperate. The local anesthetic helps, but I know exactly what's in your hands. How am I supposed to be completely relaxed?” |
| `assistant_stabilize_epidural` | 「我知道腿现在不太听使唤，是麻醉的关系……可明明懂道理，真要靠别人扶着才能保持体位，还是会心慌呀。以前都是我跟患者说‘我扶着您’，今天轮到我抓着你不放了……」 | “I know my legs aren’t responding properly because of the anesthesia... But understanding it doesn’t stop me from panicking when I need someone else to hold me in position. I’m usually the one telling patients, ‘I’ve got you.’ Today I’m the one hanging on to you...” |
| `contact_pause` | 「呼……谢谢，先让我喘这一口气。刚才那一下比我想的厉害多了……好，别催，我在听。」 | “Hah... thank you. Let me catch my breath. That last bit was a lot more intense than I expected... All right, don't rush me. I'm listening.” |
| `contact_command` | 「知道啦，不动、放松、慢慢呼吸……你说得倒轻巧。我正在努力啦，坂口医生！」 | “I know—stay still, relax, breathe slowly... Easy for you to say. I'm trying, Dr. Sakaguchi!” |
| `contact_continue` | 「……嗯，继续吧。我只是想抱怨两句，可没说你可以在这儿一直等我把话说完呀。」 | “...Mm. Go on. I just needed to complain for a moment. I didn't say you had to stand here waiting until I ran out of things to say.” |
| `ongoing_narrate` | 「原来已经到这一步了呀……你一说清楚，我脑子里就能把流程接起来。就是……身体可没有脑子那么镇定耶。」 | “So that's where we are... Once you explain it, I can follow the procedure in my head. It's just... my body isn't nearly as calm as my brain.” |
| `ongoing_eye_contact` | 「我没事……好啦，别用那种担心的眼神看我！你这样盯着，我反而更想哭了嘛。」 | “I'm okay... Oh, don't look at me like that! When you watch me with those worried eyes, it makes me want to cry even more.” |
| `ongoing_silent` | 「……坂口？怎么突然都不说话了？我知道你们在专心……可我这样躺着，只听见器械碰来碰去，心里会发毛耶。」 | “...Sakaguchi? Why did everyone go quiet? I know you're concentrating... but lying here listening to instruments clink without hearing a word is making my skin crawl.” |
| `closure_reassure` | 「真的快结束了？别哄我哦……我现在听到‘最后几针’都快要感动得哭出来了。」 | “It's really almost over? Don't just say that to cheer me up... At this point, ‘just a few more stitches’ sounds beautiful enough to make me cry.” |
| `closure_coach` | 「好，我不乱动……呼，慢慢来。你看，我明明是医生，怎么连缝合都得靠人哄着熬过去呀。」 | “Okay, I'll keep still... Hah, take your time. Look at me—I'm a doctor, and I still need someone to talk me through getting stitched up.” |
| `closure_silent` | 「……都到缝合了，还不肯跟我说句话呀？哼，等我下了台，非要让你把今天的手术从头讲一遍不可。」 | “...We're already at the suturing stage, and you still won't say a word to me? Hmph. Once I'm off this table, I'm making you tell me about the whole operation from the beginning.” |

### B1a. 详细术前说明与问答（与现有术式说明串联）

**重要技术说明：** 本段不能只靠下面的角色对白完成手术说明。Codex 须在对话节点中调用／呈现**现有 `{procedure_name}` 对应的准确术式解释**（入路／关键步骤／所选麻醉／清醒可能感受／术后安排）；该专业说明文字不由本稿臆造，无法找到时请停止接入这个“详细说明”分支并报告。下列内容是 *围绕说明的增色对白*，保留源清单相同 keys，不引入新医疗节点。

| 节点 / Key | 中文原文（说话人明确） | English |
|---|---|---|
| `graphic_preop_question` | 南条小夜香：「我知道这台叫{procedure_name}。不过说实话，这一科的细节我未必比患者懂得多。你从哪里进去、关键一步是怎么完成的？要是我选清醒麻醉，什么感觉算正常、什么情况要立刻告诉你？」 | Sayaka: “I know the procedure is called {procedure_name}. But honestly, I don't necessarily know this specialty any better than a patient. Where do you go in, and how does the critical part work? If I stay awake, what sensations are expected, and what should I tell you about immediately?” |
| `appropriate_answer` | 坂口隆司：「你问得对。我按今天确定的术式和麻醉方案，从入路、主要步骤、清醒时的感受，一直到术后安排，依次跟你讲清楚。哪里没明白，你就问。」**〔紧接工程现有的、符合该术式的完整术前说明；非本文新编剧情〕** | Sakaguchi: “Good questions. I'll take you through today's procedure and anesthesia plan, from the approach and key steps to what you may feel while awake and what happens afterward. Stop me wherever something isn't clear.” **[Then play the existing procedure-specific clinical explanation, not newly invented dialogue.]** |
| `appropriate_answer` 后的小夜香回应 | 南条小夜香：「嗯，这下我心里有数了。谢谢你认真讲给我听。呵呵，以前总是我解释到口干舌燥，今天轮到你啦。好，接下来让我认真想想麻醉怎么选。」 | Sayaka: “Mm, now I know what to expect. Thanks for taking the time to explain. Hehe, I'm usually the one talking myself hoarse. Today it's your turn. All right, now let me give the anesthesia choice some proper thought.” |
| `graphic_answer`（可选分支） | 坂口隆司：「你不是说想知道细一点吗？好，那我就把每一步为什么这样安排、你可能听到什么、感觉到什么，都讲清楚。要是听着害怕，现在就告诉我。」**〔按此分支显示同等完整的术式说明〕** | Sakaguchi: “Didn't you ask for the detailed version? All right, I'll explain why each step is planned this way, what you may hear, and what you may feel. If it starts to frighten you, tell me.” **[Display an equally complete procedure-specific explanation in this branch.]** |
| `graphic_preop_dialogue`（可选分支） | 南条小夜香：「哎呀，你讲得也太有画面感了吧！刚刚我还觉得自己像在听手术讨论会，现在突然发现，待会儿躺在那儿的人就是我耶……喂，坂口，别看我笑，心跳真的快起来啦。」 | Sayaka: “Wow, you certainly know how to paint a picture! A moment ago this felt like an ordinary surgical conference. Now I've suddenly remembered that *I'm* the one who'll be lying there... Hey, Sakaguchi, don't let the smile fool you. My heart really is racing.” |
| 麻醉选择前的最终确认 | 坂口隆司：「术式和关键步骤都确认清楚了。接下来再核对麻醉选择。」／南条小夜香：「嗯。我知道今天要做{procedure_name}，需要经历哪些准备，也明白麻醉会改变我能感受到什么。来吧，这次我会认真选，不会光顾着逞强。」 | Sakaguchi: “We've confirmed the procedure and the essential steps. Now let's verify the anesthesia choice.” / Sayaka: “Mm. I know we're doing {procedure_name}, what the preparation involves, and how anesthesia changes what I'll experience. All right. I'll make a proper choice this time instead of just trying to act tough.” |

### B2. 术前准备 `reaction_variants`（每组恰好 2 条）

| Key | 变体 | 中文：南条小夜香 | English: Sayaka |
|---|---:|---|---|
| `ward_enema` | 1 | 「等、等一下……你们平时可都是跟我一起工作的呀！我知道这是正常准备，可轮到同事替我做这些，我真的连抬头看你们都不好意思了……让我先缓一口气，好不好？」 | “W-wait a moment... You’re the people I work with every day! I know this is routine preparation, but having my own coworkers do all this for me... I can barely look you in the eye. Could you give me a moment to breathe?” |
| `ward_enema` | 2 | 「……我以前在病历上写‘术前准备完成’，几秒钟就过去了。怎么轮到我，才刚开始就觉得折腾了半天呀？呼……后面还有多少项啊？」 | “...I used to write ‘pre-op preparation complete’ in a chart in a matter of seconds. How can it feel like I’ve been put through half a day of this when we’ve barely started? Hah... how many more things are there?” |
| `ward_enema_unnecessary` | 1 | 「咦，这一步不是必须的吗？那就把理由告诉我呀。平时轮到我做决定也会多问一句，今天我更想问清楚呢。」 | “Huh, this step isn't mandatory? Then tell me why we're considering it. I'd ask another question if I were making the decision as a doctor, and I definitely want an answer as the patient.” |
| `ward_enema_unnecessary` | 2 | 「呵呵，我可没有说想把每一项术前准备都体验一遍哦！如果不是必须做的，你们总该先说明白嘛。」 | “Hehe, I never said I wanted to try every single pre-op preparation! If something isn't required, you ought to explain the reason first.” |
| `ward_skin_prep` | 1 | 「呀……等一下，真的要准备得这么仔细吗？我知道是术野要求啦，可大家平时都跟我一起上班……现在让我这么躺着给你们检查，太丢脸了耶！」 | “Ah... wait, does it really have to be this thorough? I know it’s for the operative field, but we all work together every day... Lying here while you check everything is so embarrassing!” |
| `ward_skin_prep` | 2 | 「……以前看护士备皮，我总觉得三两下就结束了。今天被你们一处一处地核对，明明知道是必要的，还是又窘又烦……到底还要多久呀？」 | “...When I watched nurses do skin prep, it always seemed to take no time at all. Today you’re checking one area after another. I know it’s necessary, but I’m embarrassed and getting irritated... How much longer?” |
| `ward_skin_prep_unnecessary` | 1 | 「等等，那一块不在这次手术范围内吧？要是只是顺手扩大范围，可不可以放过我一点呀？」 | “Hold on, that area isn't part of this surgical field, is it? If you're only extending it out of habit, could you spare me a little?” |
| `ward_skin_prep_unnecessary` | 2 | 「嗯？这项也可以省？那我要认真考虑一下耶。我今天是来开刀的，可不是报名参加术前准备全套体验呀。」 | “Hm? That part can be skipped too? Then I want to think about it. I'm here for surgery, not to sign up for the deluxe pre-op preparation package.” |
| `ward_surgical_cap` | 1 | 「头发帮我全部收进去哦……唉，帽子一戴好，就真的像要把我送上手术台了。明明答应你的时候还那么痛快，怎么现在光看这顶帽子就紧张起来了呀？」 | “Please tuck all my hair in... Sigh. Once the cap is on, it really feels like I’m being sent off to the operating table. I was so confident when I agreed, so why is just looking at this cap making me nervous?” |
| `ward_surgical_cap` | 2 | 「我以前帮患者检查手术帽，总会笑着说‘别紧张，很快就好了’……现在轮到我，才发现自己最想问的就是——你们说的‘很快’，到底是多久呀？」 | “When I checked patients’ caps, I’d smile and say, ‘Don’t worry, it’ll be over soon’... Now it’s my turn, and all I want to ask is—when you say ‘soon,’ how long is that, exactly?” |
| `operative_positioning_awake` | 1 | 「……手臂这样放，身体再挪一点……我知道，我知道！可你们平时都叫我南条医生，今天却轮流把我摆好，连自己翻个身都得先问……真的好丢脸呀。」 | “...Arm here, move my body a little more... I know, I know! You all usually call me Dr. Nanjou, but today you’re arranging me one by one, and I have to ask before I can even turn over... This is so humiliating.” |
| `operative_positioning_awake` | 2 | 「别、别催！我是在配合呀……可躺好了就不能随便动，接下来还得等你们忙完。你们有事做，时间过得快，我可是每一分钟都在数耶！」 | “D-don’t rush me! I am cooperating... But once I’m in position I can’t just move, and then I have to wait for you to finish. You have work to keep you busy; I’m counting every single minute!” |
| `operative_positioning_none` | 1 | 「等、等等……你们别一下子都围过来呀！我知道没用麻药的时候更得好好配合，可你们越认真地说‘准备’，我心里就越慌……先让我缓一下啦。」 | “W-wait... Please don’t all crowd around at once! I know I need to cooperate especially carefully without anesthesia, but the more seriously you say ‘preparation,’ the more I panic... Give me a moment.” |
| `operative_positioning_none` | 2 | 「固定带也要上啊……嗯，我知道是为了安全。可是这么一躺好，真的会突然想到——等会儿我就是想躲，也没地方躲了呢。」 | “The straps too, huh... Mm, I know they're for safety. But once I'm settled like this, it really hits me—even if I wanted to shrink away, there's nowhere to go.” |
| `urinary_catheterization_awake` | 1 | 「……连这一步也轮到我呀。明明都是天天见面的同事，今天却得这样躺着让你们照顾……啊，别看我的脸啦，我真的要羞死了！」 | “...So it’s my turn for this part, too. You’re all coworkers I see every day, and now I’m lying here needing this kind of help... Ah, don’t look at my face! I’m mortified!” |
| `urinary_catheterization_awake` | 2 | 「呼……我以前还一本正经地跟患者说‘放松就好’。你们今天要是再跟我说一遍，我真的会生气哦……我已经很努力了嘛！」 | “Hah... I used to tell patients, with a perfectly straight face, ‘Just relax.’ If you say that to me one more time today, I really might get mad... I’m trying my best!” |
| `urinary_catheterization_none` | 1 | 「喂喂，先等一下！我知道这一步是怎么回事，可从刚才开始，你们让我怎么躺我就怎么躺……现在连这种准备也得清醒着做完，我真的快没脸见人了啦！」 | “H-hey, wait a second! I know what this step involves, but all this time I’ve been lying however you tell me to lie... And now I have to go through this part wide awake, too. I’m so embarrassed I can hardly face anyone!” |
| `urinary_catheterization_none` | 2 | 「呀……等一下……我已经在努力配合了，真的。可你们越是若无其事，我越觉得自己像个被安排得明明白白的患者……讨厌，太丢脸了啦。」 | “Ah... wait... I really am trying to cooperate. But the more matter-of-fact you all are, the more I feel like a patient whose every move has been decided for her... Ugh, this is mortifying.” |
| `skin_disinfection_awake` | 1 | 「好凉！……啊，消毒液呀。我知道，我知道。可平时站在台边听患者这么叫，和自己被擦一下就跳起来，果然是两回事耶。」 | “Cold! ...Oh, it's the antiseptic. I know, I know. But hearing patients react from beside the table and jumping at the touch yourself are two completely different things.” |
| `skin_disinfection_awake` | 2 | 「……还没完呀？我知道消毒不能急，可从病房一路折腾到这儿，上了台又觉得等了好久……你们一个个忙得很，只有我盯着无影灯胡思乱想，都快把自己吓死了啦。」 | “...We’re not finished yet? I know skin disinfection can’t be rushed, but after all that preparation in the ward, it feels like I’ve been waiting here on the table forever... You’re all busy doing things, while I just stare at the surgical lights and scare myself half to death.” |
| `skin_disinfection_none` | 1 | 「……只是消毒而已，我的心怎么已经跳这么快啦？坂口，你等会儿真下刀的时候，可不许笑我呀。」 | “...It's only skin prep. Why is my heart pounding already? Sakaguchi, when you really make the cut, you're not allowed to laugh at me.” |
| `skin_disinfection_none` | 2 | 「等消毒液干、铺巾、核对……我知道，一个都不能少。可我干躺在这里，居然开始盼着你快点下刀了……等一下！上次被你开刀疼成那样，我怎么还会说出这种话呀？！」 | “Wait for the antiseptic to dry, drape the field, do the checks... I know, none of it can be skipped. But lying here doing nothing, I’m actually starting to wish you’d hurry up and make the cut... Wait, what?! Last time it hurt terribly when you cut into me! Why am I even saying that?!” |

### B3. 划线与真正下刀（两拍严格分开）

| Key | 中文：南条小夜香 | English: Sayaka |
|---|---|---|
| `incision_marking_awake` | 「……已经画到这儿了？前面准备了那么久，现在终于快下刀了，我却一点也没松口气……坂口，真的要切的时候先跟我说一声，好不好？」 | “...You’re marking it already? After all that preparation, we’re finally almost at the incision, and I don’t feel relieved at all... Sakaguchi, tell me just before you make the cut, okay?” |
| `incision_marking_none` | 「等、等等，这个只是做记号吧？我刚才还嫌你们准备太慢……真到要下刀了，怎么又觉得太快了呀！让我先喘匀这口气……拜托。」 | “W-wait, that’s just a marking, right? A minute ago I was complaining the preparation was taking too long... Now that you’re about to cut, why does it suddenly feel too fast? Let me catch my breath... Please.” |
| `incise_epidural` | 「……啊，已经下刀了？我能感觉到你们在碰我，可和刚才想象的完全不一样……呼，看来真的是开始了呀。」 | “...Ah, you've already made the incision? I can feel that you're working on me, but it's nothing like what I'd been imagining... Hah. So it's really started.” |
| `incise_local` | 「嘶……！刚刚那一下我还是吓到了！局麻是起作用了，可知道刀真的落下来，和站在旁边看可差太远了呀。」 | “Ah—! That still startled me! The local anesthetic is doing something, but knowing the blade has actually touched me is worlds apart from watching beside the table.” |
| `incise_none` | 「啊——！！呀、好疼！等、等一下……呼……你、你真的下刀了呀！我知道自己答应了，可这一下也太……呜，坂口，手轻点啦！」 | “Aah—!! Ow, that hurts! W-wait... Hah... Y-you really made the cut! I know I agreed to this, but that was just... Ngh, Sakaguchi, please be gentle!” |
| `incise_general` | **本流程不触发患者对白。** | **No patient dialogue in this branch.** |

---
## C. 术中互动回应

### C1. 术式四阶段患者反应（按实际 runner cue 映射，并非新建 stage）

| 时点 | 变体 | 中文：南条小夜香 | English: Sayaka |
|---|---:|---|---|
| 开始／术野确认 | 1 | 「……呵呵，这回我终于能听懂自己手术里每个人在忙什么了。可我现在一点也不想给大家出主意，只想知道你们都准备好了没有呀。」 | “...Hehe, for once I can understand what everyone's doing during my own operation. But I don't feel like making suggestions at all. I just want to know whether you're ready.” |
| 开始／术野确认 | 2 | 「坂口，你专心做就好……我只是有点怕。以前总叫患者别看器械，今天换我躺这里，我才知道为什么要这么说呢。」 | “Sakaguchi, just concentrate on your work... I'm only a little scared. I always told patients not to watch the instruments. Now that I'm lying here, I finally understand why.” |
| 团队配合（对助手） | 1 | 「……助手医生，麻烦你刚才要我配合的动作再说一次。我平时指挥别人习惯了，今天听自己被指挥，脑袋反倒有点卡壳啦。」 | “...Doctor, could you repeat what you need me to do? I'm so used to giving instructions that having to follow them myself is making my brain seize up.” |
| 团队配合（对护士） | 2 | 「护士小姐，那个器械声我听见啦……呵呵，平时我觉得挺熟悉的，今天居然听得心里发毛。你们继续忙，不用理我抱怨。」 | “Nurse, I heard that instrument... Hehe, it's usually such a familiar sound, but today it gives me chills. Keep doing your work. You can ignore my grumbling.” |
| 关键判断 | 1 | 「……你们是在核对下一步吧？好，你们慢慢确认。我听着有点紧张，不过比起赶时间，我更想让你们看仔细一点。」 | “...You're checking the next step, right? Okay, take the time you need. It makes me nervous to listen, but I'd much rather have you check carefully than rush.” |
| 关键判断 | 2 | 「喂，坂口，这次你可别拿‘差不多’来糊弄我哦！我在病房里说这话的时候，你不是还点头吗？」 | “Hey, Sakaguchi, don't you dare fob me off with ‘close enough’ today! You agreed with me when I said that in the ward, remember?” |
| 收尾／完成复核 | 1 | 「……真的已经在缝合了呀？呼……我刚才还觉得过了一个世纪。你们再检查一遍就好，我乖乖等着。」 | “...You're really closing already? Hah... I thought that last part lasted a century. Go ahead and double-check everything. I'll be good and wait.” |
| 收尾／完成复核 | 2 | 「等一下，结束前让我先说一句……谢谢你们。好了，可以继续缝了……我现在实在没力气讲漂亮话啦。」 | “Wait, let me say one thing before we're finished... Thank you, all of you. All right, you can keep stitching... I don't have the energy for a prettier speech.” |

> C1 的团队称呼使用岗位，不预设具体助手／护士身份。待 Codex 提供实际上场人员后可另写姓名专属变体；本稿不让小夜香错误认人。所有 C1 台词只在清醒分支、对应 runner 确实允许患者发话时播放。

### C2. 六类 `patient_interactions` × 两个候选变体（待实际 action ID 绑定）

**接线警告：** 以下 `action` 名称是本稿的**中文语义说明**，不是工程内真实 `actions[].id`。如果实际池的选项少于三项或意图不同，Codex 不能只靠近义词将其硬接上；需要返回原 JSON 让编剧重新映射。变体标签 `V1`／`V2` 仅为写作对照，不是注册 ID。下面每条 response 都由 **小夜香** 说，prompt 亦同。所有内容同时提供英文。

#### C2-1. `operative_contact`（接触／切开；cue `incision` 或类似初期术野操作；清醒分支）

**变体 V1：术野接触，想知道下一步**

- **Prompt CN：**「呀……等一下，我知道手术已经开始了，可每次感觉到你们碰到我，还是会忍不住猜下一步要做什么耶。」
- **Prompt EN:** “Ah... wait. I know the operation has started, but every time I feel you touch me, I can't help guessing what comes next.”

| 玩家动作语义（非 action ID） | 小夜香回应 CN | Sayaka response EN |
|---|---|---|
| 解释接下来接触／操作的目的 | 「哦，原来现在是在处理这一步呀。好，我听明白了……就是听明白以后，好像更紧张了嘛。」 | “Oh, so that's what you're doing at this step. All right, I understand... Though somehow understanding it makes me even more nervous.” |
| 稍作暂停，让她缓一下 | 「呼……谢谢。你看，我平时总觉得几秒钟没什么，今天这几秒简直像救命一样耶。」 | “Hah... thank you. Funny, I never used to think a few seconds mattered. Today those few seconds feel like a lifesaver.” |
| 告知并继续当前操作 | 「……嗯，我知道你要继续。拜托，动手的时候先叫我一声，别让我自己猜呀。」 | “...Mm, I know you're going on. Just give me a word before you move, please. Don't make me guess.” |

**变体 V2：强撑医生的镇定，尤其适合高紧张／无麻醉**

- **Prompt CN：**「喂、喂，坂口……我知道你现在要做什么。就是因为太清楚了，才觉得自己心脏都快跳出来啦！」
- **Prompt EN:** “H-hey, Sakaguchi... I know exactly what you're about to do. That's *why* my heart feels like it's about to leap out of my chest!”

| 玩家动作语义（非 action ID） | 小夜香回应 CN | Sayaka response EN |
|---|---|---|
| 解释当前步骤和感觉 | 「嗯……这些我在书上都读过呀。可真正要自己挨这一下，课本上怎么没写会这么吓人呢？」 | “Mm... I've read all this in textbooks. Funny how none of them mentioned how frightening it would be when it's happening to me.” |
| 稍作暂停，让她缓一下 | 「啊……谢谢你。等我把眼泪憋回去再看你，好不好？我今天真的有点丢脸啦。」 | “Ah... thank you. Can I get my tears under control before I look at you? I'm feeling terribly undignified today.” |
| 继续当前操作 | 「啊、好！继续吧……呜，我说得这么响亮，可不代表我真的一点都不怕呀！」 | “Ah, o-okay! Go ahead... Ngh. Just because I said it loudly doesn't mean I'm not frightened!” |

#### C2-2. `progress_check`（进度与疲劳；深部操作／阶段交接；清醒分支）

**变体 V1：一直躺着不知道进度**

- **Prompt CN：**「坂口……这台做到哪里啦？我一直盯着无影灯，感觉你们忙了半天，又好像什么都没过去呀。」
- **Prompt EN:** “Sakaguchi... how far along are we? I've been staring at the surgical lights for ages. It feels like you've been busy forever and no time has passed at all.”

| 玩家动作语义（非 action ID） | 小夜香回应 CN | Sayaka response EN |
|---|---|---|
| 具体告知已经完成与下一步 | 「原来都做到这里了呀……呼，有个进度听起来，突然觉得还能再熬一阵呢。」 | “So you've already reached that point... Hah. Hearing an actual update makes me feel like I can hold on a little longer.” |
| 简短说明仍在按计划推进 | 「嗯，我相信你啦。不过下次换你躺着试试看，只听一句‘很顺利’是不是会觉得时间变得更长。」 | “Mm, I trust you. But next time *you* lie here and see how much longer time feels when all you get is ‘It's going well.’” |
| 以安抚／目光确认替代详细说明 | 「……好啦，你那副表情我看懂了。只是等会儿到下一个阶段，还是跟我说一声哦。」 | “...All right, I understand that look. Just tell me when we reach the next stage, okay?” |

**变体 V2：带着专业知识去追踪团队话语**

- **Prompt CN：**「我刚才好像听见你们说要进入下一步了？你们声音一低，我反倒越想知道发生什么……讨厌，做医生养出来的坏习惯啦。」
- **Prompt EN:** “Did I just hear you say we're moving to the next step? The quieter you speak, the more I want to know what's happening... Ugh, an occupational hazard of being a doctor.”

| 玩家动作语义（非 action ID） | 小夜香回应 CN | Sayaka response EN |
|---|---|---|
| 具体告知阶段和关键判断 | 「嗯，这么说我就听懂了。好了，不用把我当学生考，我现在可是动不了的患者呀。」 | “Mm, now I follow. All right, don't turn this into an exam. I'm the patient who can't move, remember?” |
| 给出简短进度说明 | 「知道了……那我先把好奇心收起来。不过我真没想到，躺着等结果比站着做决定还难呀。」 | “Understood... I'll put my curiosity away for now. I never imagined that waiting for a decision while lying down could be harder than making one while standing up.” |
| 用语气和眼神安抚 | 「呵呵，你这样看我，是怕我听不懂，还是怕我听得太懂呀？……没事，我等你说。」 | “Hehe, are you giving me that look because you're afraid I won't understand, or because I understand too well? ...It's okay. I'll wait for you to tell me.” |

#### C2-3. `strain_interaction`（深部压力／牵拉；疼痛或强烈不适；清醒分支）

**变体 V1：身体反应终于压过专业知识**

- **Prompt CN：**「呜……等、等一下！刚才里面那种被拉住的感觉……怎么和切口那一下完全不一样呀？我知道你们在做什么，可是真的很难受耶！」
- **Prompt EN:** “Ngh... w-wait! That pulling feeling inside... why does it feel nothing like the incision? I know what you're doing, but it's really hard to bear!”

| 玩家动作语义（非 action ID） | 小夜香回应 CN | Sayaka response EN |
|---|---|---|
| 安抚并解释这种感觉 | 「我知道，听你讲完我脑袋是懂了……可是你能不能让我的身体也跟着听话呀？呜，疼死我啦……」 | “I know. My brain understood every word... But could you convince my body to cooperate too? Ngh, it really hurts...” |
| 调整操作／改变牵拉力度 | 「啊……这样好一点！谢谢……我本来还想摆出很懂行的样子，现在只想老老实实承认自己受不了啦。」 | “Ah... that's better! Thank you... I wanted to look as though I knew exactly what I was doing, and now I just want to admit I can't take much more.” |
| 简短告知仍须继续 | 「……知道了，你继续。我再咬牙忍一下……不过你待会儿可得记住，我今天为了你遭了多少罪！」 | “...I know. Keep going. I'll grit my teeth a little longer... But you'd better remember how much trouble I've gone through for you today!” |

**变体 V2：比术前想象更难承受，声音带颤**

- **Prompt CN：**「啊……坂口！里面那一下……呼……你先告诉我，还会不会再来一次？我现在真的有点怕啦……」
- **Prompt EN:** “Ah... Sakaguchi! That feeling inside... Hah... just tell me whether that's going to happen again. I'm honestly getting scared...”

| 玩家动作语义（非 action ID） | 小夜香回应 CN | Sayaka response EN |
|---|---|---|
| 安抚并说明接下来的操作 | 「……好。你肯告诉我，我心里至少有个底……我听见了，别担心我会装作没事。」 | “...Okay. It helps to know what to expect... I heard you. And don't worry, I'm not going to pretend it doesn't hurt.” |
| 尝试调整操作／改善不适 | 「呼……好多了。等我下台以后，我要把‘患者感觉’这一栏写得比你们的手术记录还长。」 | “Hah... much better. Once I'm off this table, my notes under ‘patient experience’ are going to be longer than your operative report.” |
| 继续而不额外停顿 | 「……呜，好。你专心吧……我、我还撑得住。别让我今天白白逞强了就好……」 | “...Ngh, all right. Just concentrate... I-I can hold on. Let me at least have something to show for all that bravado today...” |

#### C2-4. `dignity_interaction`（暴露／铺巾／受关注感；清醒分支）

**变体 V1：熟悉的同事围着自己的手术台**

- **Prompt CN：**「我知道这是正常手术啦……可是平时一起上班的人全站在我旁边，一起盯着我的术野，我还是会有点不好意思耶。」
- **Prompt EN:** “I know this is an ordinary surgical setup... But having people I work with every day standing around *my* operating field still makes me feel a little self-conscious.”

| 玩家动作语义（非 action ID） | 小夜香回应 CN | Sayaka response EN |
|---|---|---|
| 解释目前暴露的范围与必要性 | 「嗯，我知道你们看的是术野，不是在看我啦。呵呵，可这两件事对躺在这里的人来说，一下子很难分清嘛。」 | “Mm, I know you're looking at the operative field, not gawking at me. Hehe, it's just harder to feel the difference when you're the one lying here.” |
| 整理铺巾／维护她的隐私 | 「啊，谢谢……这样好多了。原来只是一点点遮盖，就能让人安心这么多呀。」 | “Ah, thank you... that's much better. I never realized how much even a little extra covering could put someone at ease.” |
| 维持现有铺巾、继续手术 | 「好啦，我知道这是手术需要……我又不是第一天当医生。你们继续做吧，我只是嘴上抱怨一下嘛。」 | “All right, I know it's necessary for the operation... I'm not new to medicine. Keep working. I only needed to complain about it for a moment.” |

**变体 V2：羞涩外壳下仍忍不住调情**

- **Prompt CN：**「坂口，我现在这副样子……是不是一点医生的威严都没有了？喂，你不要认真打量我啦！我会脸红的耶。」
- **Prompt EN:** “Sakaguchi, do I have any dignity left as a doctor looking like this? Hey, don't actually start studying me! You're going to make me blush.”

| 玩家动作语义（非 action ID） | 小夜香回应 CN | Sayaka response EN |
|---|---|---|
| 解释当前必须保持的术野 | 「知道啦，职业眼光，职业眼光……呵呵，那等我下台以后，你再用男朋友的眼光看我，好不好？」 | “I know, professional eyes, professional eyes... Hehe, then when I'm off this table, will you look at me as my boyfriend instead?” |
| 适当遮盖、调整无菌单 | 「哎呀，谢谢！你这样突然认真照顾我一下，我都不知道该先害羞还是先道谢了。」 | “Oh, thank you! When you suddenly look after me so thoughtfully, I can't decide whether to blush or thank you first.” |
| 保持现有状态、告知会继续 | 「好啦，不闹你了。你先开你的刀……不过等下千万别告诉全医院我刚才脸红了哦！」 | “All right, I'll stop teasing. You concentrate on surgery... But don't go telling the whole hospital that I blushed just now!” |

#### C2-5. `ongoing_interaction`（术中持续等待／体位疲劳／紧张；清醒分支）

**变体 V1：疲劳战胜好奇**

- **Prompt CN：**「……坂口，还要很久吗？我现在觉得连手臂都不是自己的了。以前站着一忙就是几个小时，没想到躺着不动也能这么累呀。」
- **Prompt EN:** “...Sakaguchi, will it take much longer? My arms hardly feel like they belong to me. I used to stand and work for hours. I never dreamed lying still could be so exhausting.”

| 玩家动作语义（非 action ID） | 小夜香回应 CN | Sayaka response EN |
|---|---|---|
| 暂停／允许短暂调整和休息 | 「呼……得救了。你可别小看这点休息，我现在觉得比喝一整杯热茶还舒服呢。」 | “Hah... what a relief. Don't underestimate a little break like that. Right now it feels better than a whole cup of hot tea.” |
| 指导呼吸／配合体位 | 「好，我照你说的来……吸气，呼气……哎呀，平时教患者做这些，怎么从没发现这么费力呀。」 | “All right, I'll do what you say... In, out... Goodness. I've coached patients through this so often. I never realized how much effort it takes.” |
| 简短回应并继续操作 | 「嗯……继续吧。不过等我下了台，你得听我抱怨完，不能偷偷溜走哦。」 | “Mm... keep going. But once I'm off this table, you're listening to every complaint I have. No sneaking off.” |

**变体 V2：轻快的职业吐槽夹着真实困倦**

- **Prompt CN：**「呵呵……我现在终于明白了，为什么有些患者明明醒着，最后却连说话的力气都没有……我快要把无影灯看出重影啦。」
- **Prompt EN:** “Hehe... now I understand why some patients are fully awake and still end up too tired to talk... I'm starting to see two sets of surgical lights.”

| 玩家动作语义（非 action ID） | 小夜香回应 CN | Sayaka response EN |
|---|---|---|
| 暂停一拍、让她缓口气 | 「……啊，谢谢。放心，我还醒着呢。只是我的嘴，好像终于没有平时那么厉害了。」 | “...Ah, thank you. Don't worry, I'm still awake. My mouth just isn't nearly as formidable as usual.” |
| 简短指导、让她保持配合 | 「知道啦。你放心，我再累也听得懂指令……不过如果我不小心睡着，那可不是我偷偷选了全麻哦。」 | “I know. Even when I'm exhausted, I can still follow directions... But if I accidentally doze off, don't accuse me of secretly opting for general anesthesia.” |
| 不停顿，继续手术进程 | 「好吧……你快把这台漂亮地做完。等我回病房，我绝对要好好睡上一觉。」 | “All right... make sure you finish this operation beautifully. Once I'm back in the ward, I'm going to have the best nap of my life.” |

#### C2-6. `closure_interaction`（缝合／接近完成；清醒分支）

**变体 V1：疲惫后的希望与一点点不放心**

- **Prompt CN：**「真的只剩缝合啦？你确定哦……我刚刚听你们说‘快好了’，感觉都过了好久了耶。」
- **Prompt EN:** “Is it really just suturing now? You're sure, right? ...I feel like it's been ages since I heard you say, ‘Nearly done.’”

| 玩家动作语义（非 action ID） | 小夜香回应 CN | Sayaka response EN |
|---|---|---|
| 安抚并说明剩余步骤 | 「呼……好。你慢慢做，把伤口缝漂亮一点。人家明天可是还要见人的嘛。」 | “Hah... okay. Take your time, and make the closure neat. I do have people to see tomorrow, you know.” |
| 指导她配合最后收尾 | 「好，我再忍一下……不动，不抢话。哎呀，今天我可真是模范患者了，至少最后这几分钟是吧？」 | “All right, I'll hold on a little longer... Stay still, stop interrupting. I'm being a model patient today—at least for these last few minutes, right?” |
| 沉默继续缝合 | 「……哼。看来你一认真缝针就不理女朋友啦。好吧，我等你缝完再算账。」 | “...Hmph. The moment you get serious about suturing, you forget your girlfriend exists. Fine. I'll settle accounts once you've finished.” |

**变体 V2：术后放松前最后一阵狼狈**

- **Prompt CN：**「呜……怎么到最后还是这么久呀。我都想好等会儿怎么跟你道谢了，结果现在只想先回病房躺平啦。」
- **Prompt EN:** “Ngh... why is the last part taking so long? I'd already planned a lovely way to thank you, and now all I want is to get back to the ward and lie down.”

| 玩家动作语义（非 action ID） | 小夜香回应 CN | Sayaka response EN |
|---|---|---|
| 说明临近完成，给予安抚 | 「……真的吗？好吧，再信你一次。呵呵，等我有力气了，你这句话我要反复拿出来说哦。」 | “...Really? All right, I'll believe you one more time. Hehe, once I've got my energy back, I'm going to quote you on that.” |
| 指导呼吸／不动／最后配合 | 「好、好，我听你的……呼……今天被你指挥了这么久，我可得记下来，以后让你还回来。」 | “O-okay, I'll listen... Hah... You've been ordering me around for so long today. I'm keeping score, you know.” |
| 沉默完成最后步骤 | 「……坂口。你现在不说话，我可就把你的表情当成‘快结束了’啦。拜托，千万别让我猜错呀。」 | “...Sakaguchi. If you're not going to say anything, I'm taking your expression to mean ‘almost finished.’ Please don't let me be wrong.” |

#### C2 变体抽取建议（仅写作筛选语义，不是工程条件字段）

| Theme | V1 更适合 | V2 更适合 |
|---|---|---|
| `operative_contact` | 清醒初期、紧张但还能完整说话 | 无麻醉或高度紧张、术野接触刺激强时 |
| `progress_check` | 长时间等待、疲劳；任何仍能交流的清醒麻醉 | 仍有认知精力、持续追踪团队进度的清醒状态 |
| `strain_interaction` | 深部牵拉／压力造成明显不适 | 深部操作后强烈不适、希望预知是否还会重复 |
| `dignity_interaction` | 被团队围绕、羞窘但相对稳定 | 疼痛较轻、尚能开玩笑、与坂口关系的调情窗口 |
| `ongoing_interaction` | 长时间固定、体位疲劳 | 疲劳但意识清楚，仍能轻声自嘲时 |
| `closure_interaction` | 已听到收尾消息，焦急等待 | 后段疲惫，半是抱怨半是期待完成 |

> 这张表不能擅自升级成引擎中的新 `status` 或 cue。若真实池没有相应筛选条件，先由 Codex 列出实际可用条件，再决定是否全部随机或缩减变体，不能让严重疼痛台词在完全无不适的状态播出。

### C3. 麻醉与触发界限

- 全麻：诱导后到苏醒前，**所有 B3 切皮时的患者语音与 C1／C2 的清醒患者语音均不触发**。术后首句使用 D 段全麻专属。
- 硬膜外／局部／无麻醉：仅在 runner 原本有患者发言窗口时抽取。疼痛强度必须由实际麻醉条件、患者状态与步骤 cue 决定，不应把 `strain_interaction` 里强烈疼痛变体无差别播放在充分麻醉、无刺激的节点。
- 该处以**现有 runner 匹配条件为真**作为播放前提；任何上表的「待对应实际 action ID」都必须映射后才可交付 Codex 实装，不增加临时 action 或按钮。

---
## D. 手术结束与病房恢复（候选台词；只接入真实存在的结束窗口）

**V1.2 接线限定：** 目前没有病房恢复演出阶段。下表的 `postop_relief`、`postop_teasing` **不要接入当前版本，也不要为了这两句新增病房场景**；未来真的增加恢复节点再复用。`surgery_success_awake`、`surgery_success_anesthetized` 与 `surgery_abort_or_stop` 是否有真实、可达的运行时出口，请 Codex 对照代码确认后再接。**原候选台词逐字保留。**

| ID / Key | 中文：南条小夜香 | English: Sayaka |
|---|---|---|
| `surgery_success_awake` | 「……结束了？真的？呼……我现在连跟你吵架的力气都没了。坂口……这台辛苦你了。等我歇过来再跟你算账，好不好？」 | “...It's over? Really? Hah... I don't even have the energy to argue with you. Sakaguchi... thank you for all your work. Can we settle our scores after I've had a rest?” |
| `surgery_success_anesthetized` | 「……嗯？坂口？……已经做完啦？我怎么感觉才刚闭上眼睛……啊啊，太可惜了！本来还想知道手术中大家都说了什么呢。」 | “...Mm? Sakaguchi? ...It's finished already? It feels as if I only just closed my eyes... Oh, what a shame! I wanted to know what everyone said during the operation.” |
| `postop_relief` | 「呼……总算能好好躺着了。先让我休息一会儿啦……今天我算是学到了，‘术后恢复良好’和‘患者现在一点都不累’可是两回事耶。」 | “Hah... I can finally lie down and rest. Give me a little while... Today I've learned that ‘recovering well after surgery’ and ‘not feeling exhausted right now’ are very different things.” |
| `postop_teasing` | 「呵呵，今天的手术记录你可要写漂亮点哦。不过‘患者一直叫坂口轻一点’那一项，你敢写进去，我就把你手术时紧张的表情也写进我的心得里！」 | “Hehe, make sure you write a nice operative note for today. But if you include ‘Patient kept telling Sakaguchi to be gentle,’ I'll put your nervous operating face into *my* report!” |
| `surgery_abort_or_stop` | 「……今天就先到这里？好，我听见了。你先把眼前的事情处理好，等我能好好说话了，再把为什么停下来原原本本告诉我。我可没忘记今天准备了多久呀。」 | “...We're stopping here for today? All right, I heard you. Deal with whatever needs attention first, and when I can talk properly, tell me exactly why we had to stop. I haven't forgotten how long I spent getting ready.” |

> `surgery_abort_or_stop` **仅在既有 runner 确有不可继续／安全性终止等实际出口时**使用，不能被解释为玩家或角色在既有星见规则之外获得了新增的随时取消按钮；如无该出口，正式表中该 key 标记“不适用”，不强行播出。

---

## E. 团队对白候选（待确认实际上场人员与 runner 发话节点）

**定位：** 这是为与小夜香同台工作过的同事准备的**岗位级对白候选**。它们不是“所有同事共享同一人格”的定稿；实际助手、护士、麻醉岗位人员未知时，Codex 不得未经核对直接把这些台词套给具体角色。若实装能让深山佳織、杉村弘子、本庄萌恵等已知成员上场，可按人物身份进一步专门润色。所有发言仅在该岗位**确实存在、对应节点允许发言**时播放。

### E1. 主刀：坂口隆司（玩家角色台词；不新增可选按钮）

| 节点 | 中文：坂口隆司 | English: Sakaguchi |
|---|---|---|
| 团队确认／术前 | 「南条医生，今天是{procedure_name}。术式、麻醉和团队都确认好了。你别光想着跟我斗嘴，身体有什么不舒服要告诉我们。」 | “Dr. Nanjou, today's procedure is {procedure_name}. We've confirmed the procedure, anesthesia, and team. Don't get so caught up in arguing with me that you forget to tell us if something feels wrong.” |
| 开始／术野确认 | 「小夜香，准备开始了。你要是紧张可以说出来，不用因为自己也是医生就硬撑着装镇定。」 | “Sayaka, we're about to begin. If you're nervous, say so. You don't have to pretend you're calm just because you're a doctor too.” |
| 团队配合 | 「好，下一步照计划来。小夜香，你先听我的声音，不要一直猜我们手里的器械是什么。」 | “All right, we'll proceed with the next planned step. Sayaka, listen to my voice. Stop trying to guess which instrument we're holding.” |
| 关键判断 | 「先把这一步确认清楚再继续。小夜香，我听见你了，别急，我会告诉你进度。」 | “We'll verify this step before moving on. Sayaka, I hear you. Don't worry, I'll keep you informed.” |
| 收尾／复核 | 「已经到最后阶段了。别急着起身，也别急着想下一台手术；今天先把这一台好好结束。」 | “We're at the final stage. Don't rush to get up, and don't start planning your next operation just yet. Let's finish this one properly.” |
| 纠正／复核 | 「先停在确认步骤。记录和现场再核对一次……好，这样才对。小夜香，刚才那几秒不是故意让你久等。」 | “Pause here for verification. Check the chart against the operative field once more... Good, that's correct. Sayaka, we weren't keeping you waiting just for fun.” |

### E2. 助手医生（通用岗位模板；人物确定后须匹配语气）

| 节点 | 中文：助手医生 | English: Assistant Surgeon |
|---|---|---|
| 团队确认／术前 | 「南条医生，今天我在主刀对侧协助。需要您配合时我会直接说，您不用一边当患者一边还替我们操心。」 | “Dr. Nanjou, I'll be assisting from the opposite side of the table today. If we need your cooperation, I'll say so. You don't have to be the patient and supervise us at the same time.” |
| 开始／术野确认 | 「术野已经确认。南条医生，先保持现在的体位就好，剩下的交给我们。」 | “The operative field is confirmed. Dr. Nanjou, just maintain your current position. We'll handle the rest.” |
| 团队配合 | 「主刀医生，这一步我来配合。南条医生，刚才那点牵动您可能感觉到了，我们正在调整。」 | “Doctor, I'll assist with this step. Dr. Nanjou, you may have felt that movement just now. We're adjusting.” |
| 关键判断 | 「先确认方向与步骤。南条医生，您不用急着猜结果，我们核对完马上说明。」 | “Let's confirm the orientation and the next step. Dr. Nanjou, you don't need to guess the outcome. We'll explain as soon as we've checked.” |
| 收尾／复核 | 「收尾阶段了，南条医生。您今天已经配合得很好，接下来继续保持就好。」 | “We're in the closing stage, Dr. Nanjou. You've cooperated very well today. Just keep doing what you've been doing.” |
| 纠正／复核 | 「等一下，这一项先复核……好，确认无误。南条医生，您刚才听到的只是团队核对，不需要跟着紧张。」 | “One moment, let's double-check this... Good, confirmed. Dr. Nanjou, what you just heard was a team verification. No need to get anxious along with us.” |

### E3. 器械护士（通用岗位模板）

| 节点 | 中文：器械护士 | English: Scrub Nurse |
|---|---|---|
| 团队确认／术前 | 「南条医生，器械和敷料已经清点核对。您平时最爱提醒别人别漏流程，今天这件事就交给我们吧。」 | “Dr. Nanjou, the instruments and dressings have been counted and checked. You're usually the one reminding everyone not to skip steps. Today, you can leave that to us.” |
| 开始／术野确认 | 「开台器械已经准备好了。南条医生，您听到声音不用担心，只是我们在正常传递器械。」 | “The opening instruments are ready. Dr. Nanjou, don't worry if you hear them. We're just passing instruments as usual.” |
| 团队配合 | 「下一项器械已备好。南条医生，您不用跟着器械声猜步骤，主刀医生会告诉您的。」 | “The next instrument is ready. Dr. Nanjou, you don't need to work out every step from the sounds. The surgeon will tell you.” |
| 关键判断 | 「先按主刀要求完成核对。南条医生，我们没有赶时间，请您安心。」 | “We'll complete the check requested by the surgeon. Dr. Nanjou, we're not rushing. Please try to relax.” |
| 收尾／复核 | 「缝合材料已备妥。南条医生，再辛苦您一会儿，已经到最后了。」 | “The suture materials are ready. Dr. Nanjou, just a little longer. We're nearing the end.” |
| 纠正／复核 | 「器械、敷料数量重新核对完成。南条医生，一项都没少，您可以放心了。」 | “The instruments and dressings have been recounted. Everything is accounted for, Dr. Nanjou. You can stop worrying.” |

### E4. 巡回护士（非无菌岗位；通用模板）

| 节点 | 中文：巡回护士 | English: Circulating Nurse |
|---|---|---|
| 团队确认／术前 | 「南条医生，患者身份、术式和准备记录已经核对好了。今天请安心当患者，别替我检查单子啦。」 | “Dr. Nanjou, we've checked your identity, procedure, and preparation records. Please just be the patient today. You don't need to check my paperwork for me.” |
| 开始／术野确认 | 「监护和术中记录已经开始。南条医生，您要是想说什么，直接叫我就好。」 | “Monitoring and intraoperative documentation have started. Dr. Nanjou, if you need anything, just call me.” |
| 团队配合 | 「本阶段记录完成，所需物品已送到。南条医生，您不用管台外这些事。」 | “The record for this stage is complete, and the requested supplies are here. Dr. Nanjou, you don't have to worry about anything happening away from the table.” |
| 关键判断 | 「已按团队要求复核记录。南条医生，您的情况我们一直在留意。」 | “I've rechecked the documentation as requested. Dr. Nanjou, we're keeping an eye on your condition throughout.” |
| 收尾／复核 | 「接下来的病房交接我会准备好。南条医生，您下台后就不用惦记这些了。」 | “I'll prepare the handover for the ward. Dr. Nanjou, once you're off the table, you don't need to think about any of this.” |
| 纠正／复核 | 「记录我再核实一次……好了。南条医生，您听见我们重新确认，不代表出了问题哦。」 | “I'll verify the record once more... Done. Dr. Nanjou, hearing us check again doesn't mean there's been a problem.” |

### E5. 麻醉岗位（只有 runner 实际配置此角色／并允许发话时）

| 节点 | 中文：麻醉医生／麻醉岗位 | English: Anesthesia Clinician |
|---|---|---|
| 团队确认／术前 | 「南条医生，今天的麻醉方案与监测项目已经核对。哪种感觉需要及时告诉我们，我会再向您说明一遍。」 | “Dr. Nanjou, we've confirmed today's anesthesia plan and monitoring. I'll go over which sensations you should tell us about right away.” |
| 开始／术野确认 | 「目前监测状态稳定，麻醉方案按计划执行。南条医生，您先按我们说的呼吸就好。」 | “The monitoring is stable, and we're following the anesthesia plan. Dr. Nanjou, just breathe as we've instructed for now.” |
| 团队配合 | 「监测继续进行。南条医生，如果有不舒服，请直接说，不用忍着不告诉我们。」 | “Monitoring is continuing. Dr. Nanjou, if anything feels wrong, tell us directly. There's no need to keep it to yourself.” |
| 关键判断 | 「先核对当前监测与麻醉情况，再继续下一步。南条医生，我们正在确认，您不需要猜测。」 | “We'll verify the monitoring and anesthesia status before the next step. Dr. Nanjou, we're checking it now. You don't need to guess.” |
| 收尾／复核 | 「手术接近结束了，术后观察安排也已确认。南条医生，您接下来只需要好好休息。」 | “The operation is nearly over, and postoperative monitoring arrangements are confirmed. Dr. Nanjou, all you need to do afterward is rest.” |
| 纠正／复核 | 「监测和给药记录已重新核对。南条医生，如果您的感觉有变化，还是第一时间告诉我们。」 | “Monitoring and medication records have been rechecked. Dr. Nanjou, if what you're feeling changes, please tell us immediately.” |

> **麻醉条件限制：** 以上 E5 不应在“没有实际麻醉岗位、也不发生该岗位发言”的分支凭空出现；不意味着无麻醉时必须由麻醉医生说任何新台词。角色选用及出场需由真实配置确认。

---

## F. 奖励提示文案（UI，不是对白）

| 状态 | 中文 UI | English UI | 实装规则 |
|---|---|---|---|
| 首次组合 | 首次手术练习：获得完整技术经验 | First practice: full surgical XP | 同一医护 × 同一术式首次；数值采用已有计算规则 |
| 再次练习 | 第二次练习：技术经验减半 | Second practice: 50% surgical XP | 同组合第二次 |
| 已熟练 | 重复练习：不再获得技术经验 | Repeated practice: no further surgical XP | 同组合第三次及以后 |

---

## 技术接线前必须从 Codex 补回的资料（V1.2 明确缺口清单）

**目标：** 请 Codex **只查工程并提交接口报告**，不要在这一阶段代写小夜香对白、修改已批准的 Lv5 剧本、重构 Runner 或新增没有确认过的系统。每项尽量提供实际**文件路径、字段、示例数据和调用处**；若某接口不存在，明确写“当前不存在”。这些是接线阻塞信息，不是请 Codex 临场编剧。

### P0 — 不解决就无法准确接线

1. **A1b 特殊邀约到底怎么筛选：** 现有医护邀请界面→已解锁术式选择→确认→播放 `SAP-SAYAKA-INVITE` 的实际代码与数据位置；是否支持 `procedure_name` 条件分派、覆盖默认随机池、以及区分术式属性。给出所需调整的最小实现入口，**不自动改代码**。尤其要确认病房有患者时的 `WARD-BUSY` 判定发生在专属邀约之前还是之后。
2. **当前所有可选术式的实际清单：** 从现有术式 registry（如 `surgeries.json` 或真实来源）导出 **canonical ID、中文／英文显示名、难度、入路／切除范围、分类标签（若有）**。逐一指出哪些准确命中 `HYSTERECTOMY`、`MASTECTOMY`、`MAJOR-GYN`、`ORGAN-REMOVAL`、`MAJOR`，哪些数据不足以判断。特别核对“子宫全切”与其他妇科手术、“全乳切除”与乳房部分切除、“整个器官摘除”与“部分胃切除”等，不能凭字符串含“切除”判断。
3. **`{procedure_name}` 的运行时替换：** 哪个 UI／剧情路径展开该变量；中英文显示名与语序怎么处理、是否用已有模板占位规则，若不支持该变量请标明准确缺口。不允许给玩家展示原样 `{procedure_name}`。
4. **`data/surgeries/patient_interactions.json` 的六主题实际池：** `operative_contact`、`progress_check`、`strain_interaction`、`dignity_interaction`、`ongoing_interaction`、`closure_interaction` 的**可命中 pool IDs**、`theme`、`cues`、术式／麻醉／状态过滤条件，以及每项 `actions[].id`、玩家按钮文案、默认回应；说明优先级和选择算法。C2 现在只使用动作语义，**禁止根据此稿伪造 Action ID**。
5. **`data/patients` 实际对白结构和 Staff 覆盖链：** 提供一份真实 Bundle 与相关 schema，逐一确认 `reaction_lines`、`reaction_variants`、随机权重、每个 key 是否支持多句依次播放、患者发话人如何确认、是否有长度／占位变量限制；并指出 Staff-as-Patient 角色专属覆盖优先于普通患者默认台词的真实接入点。
6. **B1a 术前详细说明分支：** 核查 `graphic_preop_question` → `appropriate_answer` / `graphic_answer` / `graphic_preop_dialogue` 的实际分支／节点，现有按术式变化的专业说明来自哪份数据／函数；如果不存在完整说明，请报告，不要凭空编一个通用“都说明过了”的占位，不能以本稿的调情对白替代临床流程。

### P1 — 必须先明确是否存在／能否播放

7. **真实的 B2/B3/C1/D 触发窗口：** 逐个列出 `ward_enema`、`ward_skin_prep`、`ward_surgical_cap`、清醒摆位／导尿／消毒、切口标记、三个麻醉分支的第一刀、四阶段手术 cue、手术成功／全麻苏醒等 keys 是否实际由 Runner 发出。对不存在或此 Staff 流程永远跳过的 key 标“不接入”。各术前步骤是否视术式为可选项，不得为了播放台词强制加入动作。
8. **团队成员与岗位发言：** 助手医生、器械护士、巡回护士、麻醉岗位的实际阵容、是否由玩家指派、团队发言窗口 ID、是否允许角色专属覆盖与缺席回退。E 段是通用岗位候选，未确认角色与对应窗口前不得实装成统一的角色台词。
9. **没有病房恢复环节：** 请 Codex 明确现有手术成功后如何回到正常医院日程、有没有清醒患者 `surgery_success_awake` 与全麻患者 `surgery_success_anesthetized` 的台词窗口。**`postop_relief`、`postop_teasing` 目前暂存、不接入，不新增病房恢复场景。** `surgery_abort_or_stop` 是否真实可达；如无该出口应标“不适用”，不能新增任意取消手术按钮。
10. **重复训练收益与流程收尾：** 核对同一医护 × 同一术式首次全额、第二次减半、第三次及之后零经验的现有实现；实际按哪种 key 统计、在哪里显示 UI 文案、是否有固定结算窗口。Staff-as-Patient 不改正反声望，错术式／无麻醉不能触发普通患者声望处罚；请指出沿用／豁免路径并报告仍未完成的部分。

### 请 Codex 的交付形式

- 最好提交单独 Markdown **审计报告**，每项提供 `存在／不存在／不明确`、源码位置与真实示例，不要以猜测代替代码证据。
- **新增要求：**附一份**术式→唯一邀约台词语义类别**的候选映射表，标记“由现有 metadata 明确支持”或“需用户判定”，不要静默决定重叠分类。
- 当前 V1.2 **仍是编剧候选稿**，接口审计完成后由写作端回填最终 ID、对应英文、适用范围与真正的 runtime 节点；Codex 不自行增删或改写任何小夜香正文。

## 编剧审稿关注点

- A1 每次邀请选择术式，但不能每次都像初次做手术一样雀跃；三条分别体现调皮、好奇、吸取上次候台教训。
- B2 是工作人员变成患者的身份落差，不让她在每一步都说“我好享受”。清醒／无麻醉有明显不同的体感与心理压力。
- B3 必须先“划线”，真正切入时才出现痛叫。硬膜外／局麻的反应不夸大成每人都剧痛，无麻醉则允许真实尖叫。
- C2 必须 **patient prompt + action-specific responses** 成对接入，且麻醉分支匹配。有些回应包含“无麻醉”的痛觉语义，不能无条件加入硬膜外充分麻醉的普通 cue。
- D 段要表现疲惫、真实情绪和事后嘴硬；`surgery_success_anesthetized` 只能在苏醒后说。不得用她事后愿意再试一次来抹去当下的不安。
- 任何上文的医院工作人员台词，只有在对应实际角色确实在场／岗位正确且 runner 有发言节点时才接入。Part A/B/C 定稿剧本不做任何修改。

**END — Draft V1.2, awaiting character-dialogue review and Codex interface mapping.**
