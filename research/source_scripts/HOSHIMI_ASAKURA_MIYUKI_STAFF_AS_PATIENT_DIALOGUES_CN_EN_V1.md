# Hoshimi Hospital／星见医院
## 朝仓美幸 Staff-as-Patient 患者专属对白（CN / EN）V1.2 — 编剧审阅稿

**角色：** 朝倉美幸／朝仓美幸／Asakura Miyuki；`actor_id = nurse_yui`；星见 AU 23 岁，成年护士。  
**稿件边界：** 本文只制作 **Lv5《换我躺一次》结算之后、玩家另行主动邀请美幸作为患者**时使用的患者发言；不重写、不衔接、不替代已完成的 Lv5 Part A／B／C 剧本。普通 Staff-as-Patient 的邀约、术前、准备、清醒手术互动为新创作；**高级 Staff-as-Patient V2.3 已有的 42 条美幸专属双语 `consult/night/dark/after/success/failure` 台词绝不覆盖或复制**。  
**交付性质：** 中文与英文配对的**编剧候选文案**，供人类审阅和 Codex 对真实工程入口逐句接线；不是已写入 `staff_patient_profiles.json` 的运行时 JSON。`A/B/C` 等章节、`CUSTOM/FALLBACK/RESERVE` 是作者标注而非新增引擎枚举。

**V1.1 小幅修订（2026-11-03）：** 仅微调部分邀约、术前准备、清醒手术前中段与术后候选对白，强化美幸主动逗弄对方、装乖后反将一军的“小恶魔”气质。真实切皮后的害怕、疼痛与收尾疲惫保留；所有作者槽位、患者反应键、互动池、原动作 ID、CN/EN 配对、接线限制均不变。Lv5 已完成剧本与高级 Staff-as-Patient V2.3 的 42 条对白仍不在本稿修改范围。

**V1.2 人物一致性修订（2026-11-03）：** 修复四处容易误写美幸职业经历、患者同理心或前后连续性的发言；减少“过去不理解患者、今天才懂”的重复反省，并精修少量仍有余力时的术中回复。**人物锚点：她早就懂得照顾患者，今天只是亲自体验被照顾者的位置。** 不调整剧情流程、触发条件、任何键与动作 ID；不触及真正疼痛、疲惫失态及已有 Lv5／高级 V2.3 文本。

### 0. 人物语言锚点与使用限制

- 美幸是**有护理资格的前带班护士／培训负责人**，现在主动享受不当管理者的日子。她机敏、爱笑、嘴毒，略带 S 倾向，**常主动装乖、引人接话，再笑眯眯地反将一军**；她喜欢看坂口或同事一瞬间慌神，却不会真的破坏医疗流程。被护理时会本能地监督流程，开始还能把窘迫化作玩笑，越接近真正动刀越难维持笑容。
- **她不是不懂医学的傻白甜，也不是二十四小时都在训人的恶毒前辈。** 她对护士同事的专业能力有信任，会接受配合与帮助；真正疼痛时也会短促地叫出声、请求喘息，不用每句都讲医学术语。
- 术前谈到岗位可以调侃“现世报”“前辈”“培训”，但**避免这些梗每句重复**。重点是掌控他人流程的人终于要把自己交给团队，经验能帮她理解，却挡不住真实恐惧。
- 与坂口已建立成年恋人关系，但工作场景公开称**“坂口医生”**，私人邀约可叫“隆司”；极度慌张偶尔脱口而出“隆司”应视为戏剧性失态，不能遍布所有公共台词。过去医院的严重经历与芹香的隐私不在患者手术中揭露或治疗。
- 适用全部**已解锁**且允许的普通术式，不固定某一种；不得因台词提前解锁术式。根据实际术式／麻醉／体位选择已有节点。全麻诱导后至真实苏醒前**一律不播放患者发声**。本游戏无永久不可逆损害是世界观规则，不需要人物每句背书。
- 基础 `dialogue_profile` 建议复用**已注册的 `strong_front_expressive_irritable`**（逞强／情绪外露／压力下容易急躁），不是说她日常暴躁；独特的坏心眼和专业思维都通过本角色独立台词表达。实际资料字段、次级人格和优先级请 Codex 按真实 schema 核对，本文不发明新枚举。
- 本文 A1b `MAJOR` 等名称只是既有**作者分类**，须沿用真实 32 术式白名单，不能依据术式名称猜切除范围。`{procedure_name}` 是原样运行时占位符。新增高级术式若另有分类，沿用 V2.3 Runner；不拿本表覆盖它。

### A. 邀约与确认（本人作为患者的回答）

下表的 A1／A1b 都是**明确接受**本次已解锁术式的邀约；一次只播一条，不叠加。轮换台词并不暗示每次都是第一次。

| 作者槽位 | 中文：美幸 | English: Miyuki | 状态 |
|---|---|---|---|
| `A1-01` 普通邀约 | 「`{procedure_name}`？行呀。只是我今天要躺在台上，不能顺手帮你检查器械清单了哦。」 | “`{procedure_name}`? All right. But I'll be on the table today, so I can't casually double-check your instrument list for you.” | CUSTOM |
| `A1-02` 普通邀约 | 「哎呀，终于轮到你开口请我上手术台了？呵呵，好呀，我答应。先说好，今天谁先脸红，可不一定是患者哦。」 | “Oh, so you're finally the one asking me onto the operating table? Hehe, all right, I accept. Just so you know, the patient might not be the first one to blush today.” | CUSTOM |
| `A1-03` 普通邀约 | 「`{procedure_name}`？当然可以。就是不知道等我换上病号服，坂口医生还能不能一本正经地看着我说明流程呢。」 | “`{procedure_name}`? Of course. I wonder if Dr. Sakaguchi will still manage to explain everything with that perfectly serious face once I'm in a patient gown.” | CUSTOM |
| `A1b-MAJOR` 重大手术 | 「这么大的手术也敢拿来问我？……好啊，隆司。方案让我看明白，我就把这一天交给你们。」 | “You're asking me about a surgery this big? ...All right, Ryuji. Let me understand the plan, and I'll put the day in your team's hands.” | CUSTOM／须匹配白名单 |
| `A1b-HYSTERECTOMY` 完整子宫切除 | 「`{procedure_name}`……我知道这和处理一颗肌瘤不是一回事。你把范围讲清楚，我会认真签字。玩笑留到术后再开。」 | “`{procedure_name}`... I know that's not the same as removing a single fibroid. Explain the full scope, and I'll sign with a clear head. We can joke afterward.” | CUSTOM／仅完整子宫切除 |
| `A1b-MAJOR-GYN` 重大妇科 | 「妇科的大手术啊。平时我最会提醒别人别逞强……今天就换你提醒我吧。我答应。」 | “Major gynecological surgery, then. I'm usually the one reminding people not to put on a brave face... Today you can remind me. I accept.” | RESERVE／原白名单可能无命中 |
| `A1b-MASTECTOMY` 全乳房切除 | 「我知道这是完整切除，不是普通的肿块处理。……好，我愿意。确认范围的时候，请给我一点认真听完的时间。」 | “I understand this means a complete removal, not just treating a lump. ...All right. I'm willing. Give me a little time to listen when we confirm the extent.” | CUSTOM／只限全切 |
| `A1b-ORGAN-REMOVAL` 特定器官整体切除 | 「整个器官？……听上去果然比我平时给患者解释时吓人。好，我先把方案从头看一遍，再配合你们。」 | “The entire organ? ...That does sound more intimidating when I'm the patient. All right. Let me go through the plan from the beginning, then I'll cooperate.” | CUSTOM／只限核实术式 |
| `A2-WARD-BUSY` 病房已有患者 | 「等等，我们病房还有一位患者在等手术。先把人家照顾好，再来问我，好不好？今天我还算你的同事呢。」 | “Wait, we've still got a patient awaiting surgery in the ward. Take care of her first, then ask me again, all right? I'm still your coworker today.” | RESERVE：目前仅系统拒绝，无个人发话 hook |

### B1. 核心患者反应 `reaction_lines`（28／28）

`hospitalization_*` 属于普通患者新版 28 键，但当前 Staff 邀约流程不经门诊住院；**稿件保留，不声称已可播**。`incision_ready` 是**刀未落下**的反应；三个 `incise_*` 是**已切开之后**的独立反应。此表均为患者本人发话，不能改成旁白。

| Key | 中文：美幸 | English: Miyuki |
|---|---|---|
| `hospitalization_question` | 「入院手续也要我自己签？当然啦。我就是看着自己的名字落在‘患者’那栏，有点想笑。」 | “I have to sign my own admission papers? Of course I do. It's just funny seeing my name in the ‘patient’ column.” |
| `hospitalization_response` | 「好，今天起暂时不是值班护士。……怎么，不信我会乖乖待在病房？呵呵，你猜得也不算错。不过今天我会配合的。」 | “All right, I'm officially off nursing duty for now. ...What, you don't believe I'll stay put like a good patient? Hehe, you're not entirely wrong. But I'll cooperate today.” |
| `procedure_mismatch` | 「慢着。刚才说的可不是这台手术。你以为给我换个名字，我就会像新来的护士一样点头？……说明白，我在听。」 | “Hold on. That's not the operation we agreed on. Did you think I'd nod along like a brand-new nurse if you changed the name? ...Explain it. I'm listening.” |
| `explain_plan` | 「流程我大概能背出来。不过今天请你认真讲一遍。以前我站着说这些话，从来不用想自己接下来要躺在哪里。」 | “I could probably recite the routine. But please explain it properly today. When I used to give that explanation, I never had to imagine where I'd be lying afterward.” |
| `brief_plan` | 「‘照计划做’啊……这句话真耳熟。给我两句具体的，好吗？不然我会忍不住替你补充说明。」 | “‘We'll proceed as planned,’ huh... That sounds awfully familiar. Give me a couple of specifics, will you? Otherwise I'll start filling in the explanation for you.” |
| `last_reassure` | 「我都检查过了，没什么可挑的。……呵呵，别松口气呀，我只是暂时不提问了。接下来就真的交给你们啦。」 | “I've checked everything I needed to. Nothing to complain about. ...Hehe, don't look so relieved. I'm only taking a break from asking questions. Now I'm really putting myself in your hands.” |
| `choose_general` | 「全麻？好。等药起效，我连一句‘那边的记录填错了’都说不了。……拜托你们别让我醒来还得查护理记录。」 | “General anesthesia? Fine. Once it takes effect, I won't even be able to say, ‘That chart entry is wrong.’ ...Please don't make me audit the nursing records when I wake up.” |
| `choose_epidural` | 「硬膜外……明白。人还醒着，身体却不能按自己的意思动。……原来光是想象，就比我当护士时觉得的难多了。」 | “An epidural... Understood. I'll be awake, but my body won't move the way I want. ...Just imagining it is harder than it ever seemed from the nurse's side.” |
| `choose_local` | 「局麻我清楚。该说不舒服的时候我会说，可别指望我为了面子一直笑着。」 | “I know how local anesthesia works. If something feels wrong, I'll tell you. Don't expect me to keep smiling just to save face.” |
| `choose_none` | 「不用麻醉……我知道会怎样。我以前让患者别逞强，现在可没资格装作自己不怕。……决定是我做的，我会尽力配合。」 | “No anesthesia... I know what that means. I used to tell patients not to act tough, so I have no right to pretend I'm fearless. ...It's my decision, and I'll do my best to cooperate.” |
| `induction_reassure` | 「坂口医生，等一下。……不，没事。我只是第一次发现，‘放心，交给我们’这句话从枕头这边听起来这么远。」 | “Dr. Sakaguchi, wait a second. ...No, it's all right. I never realized how distant ‘Relax, leave it to us’ sounds from this side of the pillow.” |
| `insist_without_anesthesia` | 「别又问我是不是知道自己选了什么。我知道。……只是接下来如果叫出声，你不许笑，也不许当成我改变主意了。」 | “Don't ask me again whether I know what I chose. I do. ...But if I cry out, you don't get to laugh, or assume it means I've changed my mind.” |
| `assistant_stabilize_none` | 「啊……！我知道不能乱动！……麻烦扶住我的肩膀。我嘴上很会指挥，身体现在不太听话。」 | “Ah...! I know I mustn't move! ...Please steady my shoulders. My mouth is good at giving orders, but my body isn't listening right now.” |
| `assistant_stabilize_local` | 「抱歉，刚才是我自己绷紧了。支撑的位置没错……嗯，扶着就好，谢谢。」 | “Sorry, I tensed up on my own. The support is in the right place... Yes, just steady me. Thank you.” |
| `assistant_stabilize_epidural` | 「腿真的不太受控制了呢。……别笑，我知道这很正常。请替我确认一下支撑点，好吗？」 | “My legs really aren't responding properly now. ...Don't laugh, I know that's expected. Would you check the support points for me?” |
| **`incision_ready`** | **「……喂，真、真的要下刀了？我知道流程，真的知道……可是等一下，让我把这口气喘完。坂口医生，你先看我一眼……」** | **“...Hey, y-you're really about to make the incision? I know the procedure, I do... Just wait a moment. Let me get one full breath in. Dr. Sakaguchi, look at me first...”** |
| `incise_epidural` | 「……切开了？啊……我知道没痛到想象中那样，可是我感觉到你们真的开始了。……我刚才还想开玩笑的。」 | “...You've made the incision? Ah... It doesn't hurt the way I imagined, but I can feel that you've really started. ...I was going to make a joke just now.” |
| `incise_local` | 「嘶……！里面那一下……不是尖锐的痛，可真不好受。你们继续，我会把感觉说清楚。」 | “Ngh...! That feeling deeper inside... Not a sharp pain, but it isn't pleasant. Keep going. I'll tell you exactly what I feel.” |
| `incise_none` | 「啊——！疼、疼死了……！我、我知道刀已经下去了……别让我看！……对不起，我会忍住，先让我叫这一声……！」 | “Ah—! It h-hurts...! I-I know the incision's been made... Don't make me look! ...Sorry, I'll try to hold still. Just let me cry out once...!” |
| `contact_pause` | 「……呼。谢谢。我平时总告诉患者，害怕不用道歉。可轮到自己，‘对不起’这三个字竟然也会不由自主地冒到嘴边……让我缓口气。」 | “...Phew. Thank you. I always tell patients they never need to apologize for being scared. But now that it's my turn, the words ‘I'm sorry’ come to my lips before I can help it... Let me catch my breath.” |
| `contact_command` | 「收到。我不动。……你用这种语气跟我说话，居然还挺管用的。」 | “Understood. I won't move. ...You know, that tone actually works surprisingly well on me.” |
| `contact_continue` | 「好，继续。……我今天终于明白，‘继续吧’这三个字要鼓起多大勇气才能说。」 | “All right, continue. ...Today I'm finally learning how much courage it takes to say those two words.” |
| `ongoing_narrate` | 「原来到这里了。嗯……知道进度就没那么容易胡思乱想。接下来也告诉我，好吗？」 | “So that's where we are. Mm... Knowing the progress keeps my mind from wandering. Keep me informed, all right?” |
| `ongoing_eye_contact` | 「……你看过来了啊。我还好。……好吧，不算太好。不过看见你还稳得住，我也就没那么想发脾气了。」 | “...There you are. I'm fine. ...Well, not exactly fine. But seeing how steady you are makes me a little less tempted to snap at everyone.” |
| `ongoing_silent` | 「……怎么突然这么安静。你们忙就忙，可谁有空说句话吗？平时我也没发现，光听器械声会这么难熬。」 | “...Why has it gone so quiet? I know you're busy, but can someone say something? I never noticed how hard it is to hear nothing but instruments.” |
| `closure_reassure` | 「真到收尾了？……那我暂时不骂你。等我能好好坐起来，再一条条算账。」 | “We're really closing now? ...Then I won't scold you. I'll save my complaints until I can sit up properly.” |
| `closure_coach` | 「好……吸气，呼气。我会跟上。……不过坂口医生，你说的‘最后一点点’，怎么这么长啊……」 | “All right... In, out. I'll follow your pace. ...But Dr. Sakaguchi, how can your ‘just a little more’ last this long...?” |
| `closure_silent` | 「……还没完吗……我知道你们在做最后检查……可是我真的……连骂人的力气都快没了……坂口医生，拜托，快一点点……」 | “...Is it still not over...? I know you're doing the final checks... But I honestly... don't even have the strength left to complain... Dr. Sakaguchi, please, just a little sooner...” |

### B2. 术前准备 `reaction_variants`（13 组 × 2，CN / EN）

每组两句互为**随机替代**，同一触发只播一条。术式不需要的准备不得为了台词强制出现；`*_none` 对应**无麻醉状态**，并不自动代表患者拒绝该准备。

| Key | 变体 | 中文：美幸 | English: Miyuki |
|---|---:|---|---|
| `ward_enema` | 1 | 「好，灌肠这项我知道。……以前教新人操作时我可神气了，轮到我就别叫我前辈，好吗？」 | “All right, I know about the enema. ...I was so confident teaching it to new nurses. Just don't call me ‘senior’ when it's my turn, okay?” |
| `ward_enema` | 2 | 「麻烦把帘子拉好。……哎呀，你的表情怎么这么严肃？我现在可是普通患者哦。呵呵，别摆出一副要接受考核的脸嘛。」 | “Please close the curtain properly. ...Oh my, why the serious face? I'm just an ordinary patient right now. Hehe, don't look as though you're about to sit an exam.” |
| `ward_enema_unnecessary` | 1 | 「这项不是必需？那先把理由给我说清楚。今天我可以不当护士，可脑子还在上班。」 | “This isn't required? Then explain the reason first. I may be off nursing duty, but my brain hasn't clocked out.” |
| `ward_enema_unnecessary` | 2 | 「确认不需要就好。……哎呀，怎么松了这么大一口气？呵呵，我还没打算考你呢。」 | “Good, as long as you've confirmed it's unnecessary. ...Oh, what a huge sigh of relief! Hehe, I wasn't even planning to quiz you.” |
| `ward_skin_prep` | 1 | 「备皮范围确认好了？好。……怎么，我一抬眼你就紧张？放心，今天我只负责当个乖乖的患者……大概吧。呵呵。」 | “The skin-preparation area is confirmed? Good. ...What, does one glance from me make you nervous? Relax, today I'm just going to be a perfectly good patient... probably. Hehe.” |
| `ward_skin_prep` | 2 | 「剪刀声从这里听着还真近……哎呀，别突然看我，我不是在考你的手法。慢慢来就好。」 | “The scissors sound awfully close from down here... Oh, don't look at me like that. I'm not testing your technique. Just take your time.” |
| `ward_skin_prep_unnecessary` | 1 | 「这里不在术野内吧？如果不是必要步骤，让我保留一点体面，拜托啦。」 | “That area isn't part of the surgical field, is it? If it's not necessary, let me keep a little dignity, please.” |
| `ward_skin_prep_unnecessary` | 2 | 「可以省略就说一声。……我现在才知道，多听见一句‘不用做’，能让人这么高兴。」 | “If we can skip it, tell me. ...I never knew hearing ‘we don't need to do that’ could be such a relief.” |
| `ward_surgical_cap` | 1 | 「头发都藏好啦？呵呵，现在是不是看起来特别乖？……可别信，手术帽没把我的坏心眼一起收进去哦。」 | “Is all my hair tucked away? Hehe, don't I look wonderfully well-behaved now? ...Don't be fooled. That cap hasn't tucked away my mischievous streak.” |
| `ward_surgical_cap` | 2 | 「别给我留一绺头发当装饰。我还要回来上班的……啊不，先把今天过完。」 | “Don't leave a strand out for decoration. I do intend to come back to work... Ah, no, let's get through today first.” |
| `operative_positioning_awake` | 1 | 「哎呀，今天轮到你指挥我的手脚了。呵呵，手别抖呀，我会好好配合的……只要你说得够温柔。」 | “Oh my, today you're the one telling me where to put my arms and legs. Hehe, don't let your hands shake. I'll cooperate nicely... provided you ask sweetly enough.” |
| `operative_positioning_awake` | 2 | 「等一下，肩膀有一点绷……嗯，现在好多了。今天总算轮到我说‘这个姿势不舒服’了。」 | “A moment, my shoulder's a little tense... Mm, that's better. For once, I get to say, ‘This position is uncomfortable.’” |
| `operative_positioning_none` | 1 | 「没麻醉就摆位啊……知道了。请把支撑做稳一点，我可不想在刀下来前就被自己的紧张打败。」 | “Positioning me without anesthesia... Understood. Make sure the supports are secure. I don't want my nerves to defeat me before the incision.” |
| `operative_positioning_none` | 2 | 「你们固定得很认真，我知道。……可是越不能自己动，我越忍不住想挪一下。讨厌。」 | “I know you're securing me carefully. ...But the less I'm allowed to move, the more I want to fidget. How annoying.” |
| `urinary_catheterization_awake` | 1 | 「要导尿啊。嗯，适应证我明白。……不过请先给我一点准备时间，不要因为我懂就省掉那句话。」 | “A catheter, then. Yes, I understand why it's needed. ...But give me a moment to prepare, and don't skip the explanation just because I know.” |
| `urinary_catheterization_awake` | 2 | 「轻一点，好吗。……哎呀，别紧张，我只是忍不住提醒一句。呵呵，今天换我当个有点难伺候的患者啦。」 | “Gently, please. ...Oh, don't be nervous. I just couldn't help reminding you. Hehe, looks like it's my turn to be a slightly fussy patient today.” |
| `urinary_catheterization_none` | 1 | 「连这项准备也要清醒着来啊……没事，我知道流程。……你让我先抓住床沿一下。」 | “I'm staying fully awake for this preparation too... It's all right, I know the procedure. ...Just let me grip the edge of the bed for a moment.” |
| `urinary_catheterization_none` | 2 | 「今天连说句‘照常操作’都这么费劲。……好，我不乱动，你们开始吧。」 | “Even saying ‘proceed as usual’ feels difficult today. ...All right, I'll hold still. Go ahead.” |
| `skin_disinfection_awake` | 1 | 「嘶，好凉！……呵呵，别憋笑嘛。今天换你看我出丑，也算难得的机会呢。……不过真的好凉。」 | “Ah, that's cold! ...Hehe, don't hold back that laugh. You don't often get to see me make a fool of myself. ...But it really is cold.” |
| `skin_disinfection_awake` | 2 | 「消毒液要等干，我知道。……说真的，这几分钟以前在我这边过得可快了。」 | “The antiseptic has to dry, I know. ...Honestly, those few minutes used to fly by on my side of the table.” |
| `skin_disinfection_none` | 1 | 「刚才只是消毒，我就差点绷不住了。……等到真正动刀，我可能会很吵。先说声抱歉。」 | “That was only the antiseptic, and I nearly lost my composure. ...When the incision comes, I might be noisy. Sorry in advance.” |
| `skin_disinfection_none` | 2 | 「好冷……明明还没开刀，我心跳就这么快。……坂口医生，别让我自己猜什么时候开始。」 | “It's cold... We haven't even begun, and my heart's racing. ...Dr. Sakaguchi, please don't make me guess when you're starting.” |
| `incision_marking_awake` | 1 | 「线画得挺准嘛。……哎呀，别露出被我监督的表情，我今天可是乖患者。呵呵……接下来真的拜托你了。」 | “Those marks look pretty accurate. ...Oh, don't make that face like I'm inspecting your work. I'm a good patient today. Hehe... But seriously, I'm counting on you.” |
| `incision_marking_awake` | 2 | 「原来从这里看自己的切口线，会这么不真实。……等会儿真要开始时，提醒我一声。」 | “Seeing the incision marks on myself from this angle feels unreal. ...Tell me when you're really about to begin.” |
| `incision_marking_none` | 1 | 「等、等一下！这还是记号笔，对吧？我知道……我知道啊。可我的眼睛已经在找刀了。」 | “W-wait! That's still the marker, right? I know... I know it is. But my eyes are already looking for the scalpel.” |
| `incision_marking_none` | 2 | 「标记好了？……那我是不是该把最后一句玩笑说完？……算了，我突然想不出来了。」 | “Finished marking? ...Is this where I make my last joke? ...Forget it. I suddenly can't think of one.” |

### B1a. 详细术前问答的患者专属桥接（不取代医学说明）

术前完整解释仍由**真实负责说明的医护**和既有 `preop.json` 提供。以下只在相应患者发话入口存在、speaker 正确时覆盖，不能用一句角色俏皮话跳过原来的腹部／乳房／妇科／胸心医学说明；`appropriate_answer` 与 `graphic_answer` 的真实顺序和对应医护发言由 Codex 检验。

| 作者槽位 | 中文：美幸 | English: Miyuki | 接线条件 |
|---|---|---|---|
| 患者主动提出详细说明 | 「再详细讲一遍吧。我平时站在医护团队那边核对方案、配合手术，今天换成躺在这里听。……我想从患者的角度，把接下来每一步都听清楚。」 | “Please go through the details once more. I'm used to checking the plan and supporting the operation from the clinical team's side. Today I'm listening from the table instead. ...I'd like to hear every step from the patient's point of view.” | `graphic_preop_question` 如允许患者发话 |
| 收到专业且完整答复 | 「嗯，这样就清楚了。……奇怪，知道每一步以后，我反而更想抓紧被单了。」 | “Mm, that makes it clear. ...Funny, now that I know every step, I feel even more like clutching the sheet.” | `appropriate_answer` **之后**的患者合法回合 |
| 收到详细但带轻松语气的说明 | 「你讲得倒是很生动。……可别以为我会被两句漂亮话哄上台。我是真的听懂了，才答应的。」 | “You certainly make it sound vivid. ...But don't think two charming sentences would talk me onto the table. I'm agreeing because I actually understand.” | `graphic_answer` 分支后患者回合，VERIFY |
| 最终确认（邀约术式未变时） | 「听清楚了。今天把患者那一栏交给你们，护理那一栏就暂时别来找我。……开始吧。」 | “I understand. Today I'll leave the patient side to you. For once, don't ask me to handle the nursing side. ...Let's begin.” | 仅在现有最终确认窗口，VERIFY |

**术式专属问答：** 经阴道入路等五节点医学说明，由游戏既有专科文本解释；本稿不为所有手术伪造统一解剖步骤。遇到无有效患者覆盖 hook 的问答，保持通用发话，不替换既有严谨说明。

---

### C2. 术中互动池（50 个原池／106 个原动作，患者 CN/EN）

**本章节规则：** 以下每个 `CUSTOM` 池均写齐**一条患者 `prompt` + 全部真实 action 的患者 `response`**（动作 ID 与标签沿用既有 `patient_interactions.json`／写作模板；不修改原按钮、条件、分钟、数值效果或团队 speaker）。`GENERIC_FALLBACK` 池整组回退；不得将部分台词硬塞进 fallback 池。带 `*_signature_*` 的池必须实际命中对应手术，且**实际术式与邀约术式一致**；发生 mismatch 的 11 个高风险池需由 Runner 过滤。全麻没有任何 C2 患者话语。本稿先使用每池完整的 `v1`；文末可供日后增添整组 `v2`，但**未确认 Runner 支持时不随机散拆 prompt/response**。

每条格式：`P` 为患者主动提示；`R` 后的 ID 是**玩家已存在的动作 ID**，台词均由朝仓美幸说。保留双方语言的每个完整回合，不由 Codex 临时润色翻译。

#### `operative_contact`／切口与首次接触（7／7）

**`contact_pain_incision_01` — CUSTOM**
- `P` CN：「嘶……！刚才那一下不太对劲……真、真的已经切开了？我居然在自己该熟悉的步骤上吓了一跳。」 EN: “Ngh...! That felt wrong for a moment... H-have you really started cutting? I can't believe this familiar step startled me.”
- `R:explain_contact` CN：「好，已经开始了……我听见了。呼吸，嗯，我会照做。」 EN: “All right, you've started... I heard you. Breathe, yes, I'll do that.”
- `R:brief_contact` CN：「就这么一句啊？……算啦，知道还在按计划就够了。」 EN: “That's all you're giving me? ...Fine. Knowing it's going as planned is enough.”
- `R:continue_contact` CN：「知、知道了。我不乱动……你们可别把我平时的话原样还回来。」 EN: “I-I know. I won't move... Please don't throw my own old instructions back at me.”

**`contact_no_anesthesia_incision_01` — CUSTOM**
- `P` CN：「啊……！这么疼……我刚才居然还想给你们打分……！」 EN: “Ah...! That hurts... And I was actually thinking of grading your technique a moment ago...!”
- `R:steady_unanesthetized_contact_01` CN：「好……慢一点……我跟着呼吸。谢谢你先让我把肩膀放松。」 EN: “Okay... Slower... I'll breathe with you. Thank you for letting me relax my shoulders first.”
- `R:continue_unanesthetized_contact_01` CN：「呜……知道了……我会忍，先别跟我讲大道理。」 EN: “Ngh... I understand... I'll try to bear it. Just don't give me a lecture right now.”

**`contact_no_anesthesia_incision_02` — CUSTOM**
- `P` CN：「等、等……！我看不见你们的手，光感觉到动作……比想象中可怕多了！」 EN: “W-wait...! I can't see your hands. I can only feel what's happening... It's much scarier than I imagined!”
- `R:steady_unanesthetized_contact_02` CN：「……好，停一下就好。我还能配合，给我一口气。」 EN: “...Yes, just a moment's pause. I can still cooperate. Give me one breath.”
- `R:continue_unanesthetized_contact_02` CN：「啊……！好，我不躲……继续吧……！」 EN: “Ah...! All right, I won't pull away... Keep going...!”

**`contact_no_anesthesia_incision_03` — CUSTOM**
- `P` CN：「不行，我刚才差点反射性地缩起来……！不过别误会，我没有叫你们加麻醉！」 EN: “No, I nearly flinched without thinking...! But don't misunderstand me—I haven't asked you to add anesthesia!”
- `R:steady_unanesthetized_contact_03` CN：「对，我还是不要追加麻醉。……谢谢，放慢一点就好。我会重新稳住。」 EN: “Yes, I still decline additional anesthesia. ...Thank you. Just slow down a little. I'll steady myself again.”
- `R:continue_unanesthetized_contact_03` CN：「我说了不追加……啊，疼！……你们继续，我会尽量控制住。」 EN: “I said no additional anesthesia... Ah, that hurts! ...Keep going. I'll do my best to stay still.”

**`contact_default_01` — CUSTOM**
- `P` CN：「哎呀，已经开始了？我还准备听听你第一步会不会紧张呢……等等，怎么紧张的反而是我？」 EN: “Oh my, we've started? I was all ready to hear whether you'd sound nervous during the first step... Wait, why am I the nervous one?”
- `R:reassure_start` CN：「嗯，情况稳定我就放心了。……好吧，放心一半。」 EN: “Mm, if things are stable, that helps. ...All right, it helps halfway.”
- `R:brief_start` CN：「哎呀，就这么一句？你是不是怕多说两句就被我抓到紧张？……呵呵，好啦，我知道按计划就行。」 EN: “Oh, that's all I get? Afraid I'll catch you sounding nervous if you say any more? ...Hehe, all right. I know we're on plan.”
- `R:silent_start` CN：「……好，我安静。你要是听到我哼歌，就当没听见。」 EN: “...All right, I'll be quiet. If you hear me humming, pretend you didn't.”

**`contact_pain_incision_02` — CUSTOM**
- `P` CN：「嘶……又来了。……好奇怪，明知道你们会动到这里，真感觉到时还是吓人。」 EN: “Ngh... There it is again. ...Strange. Even knowing this part was coming doesn't make feeling it any less frightening.”
- `R:acknowledge_second_contact` CN：「你确认过就好。……我不再擅自替你们猜下一步了。」 EN: “As long as you've confirmed it. ...I'll stop trying to predict your next move.”
- `R:brief_second_contact` CN：「……好，继续。我这次先咬住嘴唇。」 EN: “...All right, continue. I'll bite my lip this time.”

**`contact_fear_incision_01` — CUSTOM**
- `P` CN：「等等，刚才那是什么？我不是要指挥……我只是突然很想知道你们做到哪儿了。」 EN: “Wait, what was that just now? I'm not trying to take over... I suddenly really need to know where we are.”
- `R:orient_fearful_contact` CN：「……喔，原来已经过了那一步。我还以为才刚开始。」 EN: “...Oh, we're past that part already. I thought we were only just starting.”
- `R:steady_fearful_contact` CN：「你继续说，我听着。……对，听着你的声音比较好。」 EN: “Keep talking. I'm listening. ...Yes, it's better when I can hear your voice.”
- `R:dismiss_fearful_contact` CN：「哎呀，这么凶。……平时都是我用这种口气压住场面的呢。好啦，我不问了……可我真的有点怕。」 EN: “Oh my, that's stern. ...Usually I'm the one who uses that tone to take charge. All right, I'll stop asking... But I really am a little scared.”

#### `progress_check`／进度确认（9／9）

**`progress_fear_default_01` — CUSTOM**
- `P` CN：「坂口医生……我是不是又问过了？对不起，我现在对时间一点概念都没有。」 EN: “Dr. Sakaguchi... Have I asked already? Sorry. I've completely lost track of time.”
- `R:explain_progress` CN：「嗯，和计划一致。我记住了。……这次我尽量别每隔两分钟问一次。」 EN: “Mm, still on schedule. I'll remember that. ...I'll try not to ask every two minutes.”
- `R:brief_progress` CN：「……还在做啊。好，我等。」 EN: “...Still working on it. All right, I'll wait.”
- `R:dismiss_progress` CN：「你是叫我别分心？……我倒想，可现在每个声音都听得清清楚楚。」 EN: “You're telling me not to get distracted? ...I'd love to, but right now I can hear every little sound.”

**`progress_default_01` — CUSTOM**
- `P` CN：「坂口医生，今天工作表现怎么样呀？……呵呵，别紧张，我现在可拿不到评分表。说正经的，进度还顺利吗？」 EN: “Dr. Sakaguchi, how would you rate your performance today? ...Hehe, relax, I can't reach a scorecard from here. Seriously, though, are we making good progress?”
- `R:answer_progress` CN：「哦，已经到这个阶段啦。呵呵，汇报得这么详细，是怕我事后给你补一份手术记录吗？……放心，我都听清楚了。」 EN: “Oh, we're at that stage already. Hehe, is that such a detailed report because you're afraid I'll add notes to the operative record afterward? ...Relax, I've got it all.”
- `R:brief_answer_progress` CN：「好，明白。我再忍住不抢你的工作一会儿。」 EN: “All right, understood. I'll keep myself from doing your job for another while.”

**`cardiac_progress_fear_01` — CUSTOM**
- `P` CN：「心脏那边……现在是什么情况？别嫌我啰嗦，这次我真的不敢自己想象。」 EN: “My heart... What's happening now? Don't call me a nag. This time I really don't dare picture it on my own.”
- `R:explain_cardiac_progress` CN：「关键步骤还按计划，嗯……知道你们一直盯着监测，我安心一点了。」 EN: “The critical steps are still on schedule, yes... Knowing you're watching the monitors helps a little.”
- `R:brief_cardiac_progress` CN：「……按计划就好。我不会再假装一点都不紧张了。」 EN: “...As long as it's on schedule. I won't pretend I'm not nervous anymore.”

**`cardiac_progress_default_01` — CUSTOM**
- `P` CN：「这里是不是该进入下一阶段了？……我知道自己看不见，你就给我一个简短答案吧。」 EN: “Should we be moving to the next stage about now? ...I know I can't see. Just give me a short answer.”
- `R:answer_cardiac_progress` CN：「嗯，跟上了。你们讲得比我想象中清楚。」 EN: “Mm, I follow. Your explanations are clearer than I expected.”
- `R:brief_cardiac_answer` CN：「好，我听懂了。剩下的交给你们。」 EN: “All right, I understand. I'll leave the rest to you.”

**`progress_fear_fatigue_01` — CUSTOM**
- `P` CN：「……我怎么觉得过了好久。还要多久？不用给我一个好听的数字。」 EN: “...It feels like it's been ages. How much longer? Don't give me a pretty number just to make me feel better.”
- `R:explain_fatigue_progress` CN：「这样啊……知道还剩什么，比光等着强多了。谢谢。」 EN: “I see... Knowing what's left is much better than just waiting. Thank you.”
- `R:brief_fatigue_progress` CN：「还是按计划……好。我再试着撑一下。」 EN: “Still on schedule... All right. I'll try to hang in there.”

**`progress_fear_fatigue_02` — CUSTOM**
- `P` CN：「我有点累了……连想句挖苦你的话都要想半天。能告诉我一个明确的进度吗？」 EN: “I'm getting tired... It takes me forever to come up with a decent insult for you now. Can you give me a clear milestone?”
- `R:mark_fatigue_milestone` CN：「哦，已经到这一步了。……好，那我把这个当成下一个小目标。」 EN: “Oh, we've reached that point. ...All right, I'll make that my next little milestone.”
- `R:encourage_fatigue_progress` CN：「重要部分做完了？……那我就先相信你的好消息。」 EN: “The important part's done? ...Then I'll believe your good news for now.”

**`thoracic_progress_fatigue_01` — CUSTOM**
- `P` CN：「胸口这一边……到底做到哪了？我听见你们换了器械，心就跟着一跳。」 EN: “This side of my chest... How far along are we? Every time I hear you change instruments, my heart jumps.”
- `R:explain_thoracic_progress` CN：「嗯，胸腔这一步我明白了。……我不看器械了，专心听你讲。」 EN: “Mm, I understand this thoracic stage now. ...I'll stop watching the instruments and focus on listening to you.”
- `R:brief_thoracic_progress` CN：「关键部分还在照计划推进。好……我记住了。」 EN: “The critical portion is still proceeding as planned. Good... I'll remember that.”

**`vascular_progress_deep_01` — CUSTOM**
- `P` CN：「你们刚才好像突然都紧张起来了。……血管那一步还在掌握中，对吧？」 EN: “You all sounded suddenly more focused just now. ...The vascular step is still under control, right?”
- `R:explain_vascular_milestone` CN：「原来到了这个关键点。嗯……我相信你们会盯住所有变化。」 EN: “So we've reached that crucial point. Mm... I trust you to keep a close watch on every change.”
- `R:brief_vascular_milestone` CN：「变化在预期内。……好，听到这句我就够了。」 EN: “Within expectations. ...Good. That's all I needed to hear.”

**`cabg_signature_01` — CUSTOM；仅 `surgery_cabg` 且邀约术式一致**
- `P` CN：「……这是开始重建的阶段了吗？明明以前看过手术记录，现在我连想它都觉得心跳加快。」 EN: “...Are we at the reconstruction stage? I've read operative reports before, yet just thinking about this makes my heart race.”
- `R:explain_cabg_milestone` CN：「好，已经进入计划中的重建步骤……我明白。谢谢你们还愿意跟我解释。」 EN: “All right, we're at the planned reconstruction step... I understand. Thank you for still explaining it to me.”
- `R:brief_cabg_milestone` CN：「预定的关键步骤，嗯。……那我就不再追问细节了。」 EN: “The planned critical step, yes. ...Then I won't press you for every detail.”

#### `strain_interaction`／牵拉与压力感（6／6）

**`strain_pain_default_01` — CUSTOM**
- `P` CN：「呜……！这个不是我刚才想象的痛法……别、别让我突然动起来……！」 EN: “Ngh...! This isn't the kind of pain I was expecting... D-don't let me move suddenly...!”
- `R:pause_strain` CN：「……谢谢，停一下真的有用。我慢慢把肩膀松开。」 EN: “...Thank you. That little pause really helps. I'll slowly relax my shoulders.”
- `R:coach_strain` CN：「好，跟呼吸走……呼……我会试着不绷得那么紧。」 EN: “All right, breathe with you... Hah... I'll try not to tense up so much.”
- `R:push_through_strain` CN：「要我坚持啊……行。可是我现在只能一小段一小段地撑。」 EN: “You want me to push through... Fine. But right now I can only manage it bit by bit.”

**`strain_default_01` — CUSTOM；跨部位中性措辞**
- `P` CN：「……这种牵拉感啊。我知道你们为什么要做，可从这里感觉完全不是一回事。」 EN: “...That pulling sensation. I know why you're doing it, but feeling it from here is completely different.”
- `R:explain_strain` CN：「原来是这个步骤引起的……好，我不再乱猜。」 EN: “So this step is causing it... All right, I'll stop guessing.”
- `R:brief_strain` CN：「很快会过去？……我记下了。以后不准笑我拿秒数算账。」 EN: “It'll pass soon? ...I'll hold you to that. Don't laugh when I start counting the seconds.”

**`abdominal_strain_pain_01` — CUSTOM；仅 `general_abdominal`**
- `P` CN：「啊……腹部里面被牵了一下……！我说过我懂，可懂和挨这一遭真是两码事……！」 EN: “Ah... Something pulled deep in my abdomen...! I said I understood, but knowing and feeling it are two entirely different things...!”
- `R:explain_abdominal_strain` CN：「嗯，你们在做腹腔里的这个阶段。我听懂了……请让我把呼吸稳住。」 EN: “Mm, you're working through this stage inside the abdomen. I understand... Let me steady my breathing.”
- `R:coach_abdominal_strain` CN：「呼……吸……好……就这一会儿，我再坚持。」 EN: “In... out... Okay... I'll hang on a little longer.”

**`strain_pain_traction_02` — 完整文案已写；`RESERVE/VERIFY`，须先修原按钮跨部位问题**
- `P` CN：「啊……刚才那阵牵拉又来了！……我知道不能随便躲，可身体就是会发抖。」 EN: “Ah... That pulling sensation is back! ...I know I can't pull away, but my body keeps trembling.”
- `R:pause_second_traction` CN：「……谢谢，先缓一下。呼……我会再把姿势稳住。」 EN: “...Thank you for pausing. Hah... I'll steady my position again.”
- `R:coach_second_traction` CN：「好，慢慢呼气……我尽量让自己别绷得那么紧。」 EN: “All right, breathe out slowly... I'll try not to tense up so much.”
- **接线 P0：** 原 `coach_second_traction` 玩家按钮“放松腹部”可能在非腹部手术出现。**这属于原池按钮的适用条件问题，仅凭上述中性患者 response 不构成修复。** Codex 必须先把原池限定到合法部位，或经用户确认把原按钮改成跨部位正确的指令，才可启用这套文案；否则该池暂不被选取。

**`strain_pain_pressure_01` — CUSTOM**
- `P` CN：「……这股压力一直没退。你们不是忘了我还有感觉吧？」 EN: “...That pressure hasn't let up. You haven't forgotten that I can still feel it, have you?”
- `R:relieve_pressure` CN：「啊……好一些了。谢谢你肯停下来调整。」 EN: “Ah... That's better. Thank you for stopping to adjust it.”
- `R:explain_pressure` CN：「还会持续一会儿……明白。那麻烦你继续告诉我进度。」 EN: “It'll last a little longer... Understood. Then please keep me updated.”

**`urologic_strain_pressure_01` — CUSTOM；泌尿系跨器官中性措辞**
- `P` CN：「……里面这种钝钝的感觉怎么还在？我知道这一步很细，可是真的不好忍。」 EN: “...Why is that dull feeling still there? I know this is delicate work, but it really is hard to endure.”
- `R:pause_urologic_strain` CN：「……嗯，这一下让我重新喘过气来了。谢谢。」 EN: “...Mm, that let me catch my breath again. Thank you.”
- `R:explain_urologic_strain` CN：「原来是这一步的深部操作……好，我明白了。」 EN: “So it's the deep work at this stage... All right, I understand.”

#### `dignity_interaction`／暴露、边界与隐私（13／13）

**`dignity_low_exposure_01` — CUSTOM**
- `P` CN：「……喂，这个角度连我自己都觉得不像话。等一下，其他地方能不能再盖好一点？」 EN: “...Hey, even I think this is an embarrassing angle. Wait—could you cover the other areas a little better?”
- `R:restore_cover` CN：「谢谢。只留必要的地方就好……我知道这样做不影响手术。」 EN: “Thank you. Just leave what's necessary exposed... I know that won't interfere with the operation.”
- `R:explain_exposure` CN：「……嗯，我明白这范围是必须的。让我先把脸转过去一会儿。」 EN: “...Mm, I understand that this area needs to stay exposed. Let me turn my face away for a moment.”
- `R:ignore_exposure` CN：「叫我别在意？……你这话我可记住了，下次培训拿来当反面例子。」 EN: “Just don't think about it? ...I'll remember that one. Next time I'm teaching, it's going on the list of things not to say.”

**`dignity_default_01` — CUSTOM**
- `P` CN：「呵呵，怎么突然都不敢往我这边看啦？刚才帮我摆位的时候可果断得很呢。……好吧，别笑，其实我也有点难为情。」 EN: “Hehe, why has everyone suddenly gone shy about looking this way? You were all so decisive when positioning me. ...All right, don't laugh. I'm a little embarrassed myself, actually.”
- `R:protect_dignity` CN：「嗯，盖好就好。……你们做得对，不用那么紧张地看我。」 EN: “Mm, that's better covered. ...You're doing the right thing. You don't have to look so nervous around me.”
- `R:brief_dignity` CN：「很快就结束这个步骤？……那就让我先装作看不见你们。」 EN: “This part will be over soon? ...Then I'll pretend I can't see any of you for a moment.”

**`pelvic_dignity_exposure_01` — CUSTOM；只限原妇科盆腔组且术式一致**
- `P` CN：「……妇科这边要摆成这样，我当然知道。只是以前负责调支腿架的人是我……现在请别让我看见太多人。」 EN: “...Of course I know this is how you position someone for pelvic surgery. I used to be the one adjusting the leg supports... Just please don't let too many people watch.”
- `R:explain_pelvic_stage` CN：「嗯，这个阶段我听懂了。你们把无关区域遮好，我就安心些。」 EN: “Mm, I understand this stage. Keep the unnecessary areas covered, and I'll feel a little better.”
- `R:brief_pelvic_stage` CN：「照术前计划……好。我相信你们。」 EN: “According to the preoperative plan... All right. I trust you.”

**`pelvic_dignity_default_01` — CUSTOM；只限原妇科盆腔组且术式一致**
- `P` CN：「……我能问一句进度吗？……不，别笑，我是真的不太敢想现在做到哪里了。」 EN: “...Can I ask about the progress? ...No, don't laugh. I'm honestly afraid to imagine how far along you are.”
- `R:answer_pelvic_progress` CN：「嗯，还是原来那一步。……好，这个答案就够了。」 EN: “Mm, still at the planned step. ...Good. That's enough of an answer.”
- `R:brief_pelvic_progress` CN：「明白。……我先专心呼吸。」 EN: “Understood. ...I'll focus on breathing for now.”

**`breast_dignity_exposure_01` — CUSTOM；只限乳房组且术式一致**
- `P` CN：「这里要露出来，我签字时就知道。……可跟认识的同事四目相对，还是有点……哎呀，别盯着我看啦。」 EN: “I knew this area would have to be exposed when I signed. ...But making eye contact with coworkers I know still feels... Oh, stop staring at me.”
- `R:confirm_breast_scope` CN：「好，范围跟我们讲好的一样。我就当自己正在接受一堂特别的隐私保护示范。」 EN: “Good, the scope matches what we discussed. I'll treat this as a very personal demonstration of patient privacy.”
- `R:brief_breast_scope` CN：「在约定范围内……嗯。那我不再自己吓自己了。」 EN: “Within the agreed scope... Mm. I'll stop scaring myself with guesses.”

**`breast_dignity_default_01` — CUSTOM；只限乳房组且术式一致**
- `P` CN：「……请问现在到哪一层了？我本来准备说句俏皮话，结果全忘了。」 EN: “...Can I ask which stage you're at now? I had a witty remark ready, but I've forgotten every word.”
- `R:answer_breast_stage` CN：「嗯，跟术前讲的一样。……光是确认这一点就舒服多了。」 EN: “Mm, just as you explained beforehand. ...Knowing that makes me feel much better.”
- `R:brief_breast_stage` CN：「按原计划做就好。……其他的，等你们做完再说。」 EN: “Just follow the original plan. ...We can talk about everything else when you're finished.”

**`dignity_low_exposure_02` — CUSTOM**
- `P` CN：「……刚才我是不是问过遮盖？抱歉，可每次被单一动，我都觉得周围的人在看我。」 EN: “...Did I already ask about the drapes? Sorry, but every time a sheet moves, I feel as if everyone is looking at me.”
- `R:reduce_exposure_again` CN：「啊，谢谢。其实这一下就足够让我放心了。」 EN: “Ah, thank you. That small adjustment is enough to put me at ease.”
- `R:acknowledge_exposure_again` CN：「你说得对，我知道必要范围。……谢谢你至少认真听我抱怨。」 EN: “You're right. I know what's necessary. ...Thank you for at least taking my complaint seriously.”

**`dignity_cooperation_exposure_01` — CUSTOM**
- `P` CN：「不是不配合！……我就是想知道，现在这里有多少人是必须留下的。」 EN: “I'm not refusing to cooperate! ...I just want to know how many people actually need to be here.”
- `R:limit_observers` CN：「嗯，这样我就安心了。谢谢，不用把我当成难缠的前辈。」 EN: “Mm, that makes me feel better. Thank you. You don't have to treat me like some impossible senior nurse.”
- `R:brief_privacy_confirmation` CN：「好，大家都在做必要的工作……我知道了。」 EN: “All right, everyone is here for a necessary reason... I understand.”

**`hysterectomy_signature_01` — CUSTOM；仅 `surgery_hysterectomy`，术式一致**
- `P` CN：「……是按当时签下的完整子宫切除方案做的吧？我知道自己问得多，可那份同意书是我亲手签的。」 EN: “...You're following the full hysterectomy plan I signed, right? I know I'm asking a lot, but I signed that consent form myself.”
- `R:confirm_hysterectomy_scope` CN：「嗯，范围都确认过。……谢谢你们还愿意这样逐项解释。」 EN: “Mm, every part of the scope has been confirmed. ...Thank you for taking the time to explain it item by item.”
- `R:brief_hysterectomy_scope` CN：「没有超出同意范围，明白。……我不会再替自己想别的了。」 EN: “Nothing beyond the consented scope. Understood. ...I'll try not to imagine anything else.”

**`ovarian_cystectomy_signature_01` — CUSTOM；仅 `surgery_open_ovarian_cystectomy`，术式一致**
- `P` CN：「……卵巢保留的计划没有变吧？你知道的，我是患者，问清楚也很合理。」 EN: “...The plan to preserve the ovary hasn't changed, has it? You know, I'm the patient. It's reasonable for me to ask.”
- `R:confirm_ovarian_preservation` CN：「嗯，还是以保留正常组织为目标。……好，我相信你的判断。」 EN: “Mm, the goal is still to preserve healthy tissue. ...All right, I trust your judgment.”
- `R:brief_ovarian_preservation` CN：「明白。……我知道你们一直记着这项计划。」 EN: “Understood. ...I know you've kept that plan in mind.”

**`myomectomy_signature_01` — CUSTOM；仅 `surgery_open_abdominal_myomectomy`，术式一致**
- `P` CN：「……我知道这台是肌瘤剔除，不是全切。你们没有临时改计划，对吧？」 EN: “...I know this is a myomectomy, not a hysterectomy. The plan hasn't changed, right?”
- `R:confirm_myomectomy_scope` CN：「好，术式没变。……嗯，今天我真的需要听你亲口确认。」 EN: “Good, the procedure hasn't changed. ...Mm, today I really needed to hear you confirm that yourself.”
- `R:brief_myomectomy_scope` CN：「跟原计划一致就好。……我不抢你们的工作。」 EN: “As long as it's still the original plan. ...I won't interfere with your work.”

**`breast_tumor_signature_01` — CUSTOM；仅 `surgery_breast_tumor`，术式一致**
- `P` CN：「切除范围还是先前划定的那一块？……别嫌我婆婆妈妈，今天我就是想听你再确认一次。」 EN: “Is the removal area still the one we marked beforehand? ...Don't call me fussy. Today I just need to hear you confirm it again.”
- `R:confirm_breast_tumor_scope` CN：「嗯，跟标记相符。谢谢，听见这个我就安心多了。」 EN: “Mm, it matches the markings. Thank you. I feel better hearing that.”
- `R:brief_breast_tumor_scope` CN：「还在原定边界……好。那我继续乖乖躺着。」 EN: “Still within the original boundaries... Good. I'll keep lying still, then.”

**`mastectomy_signature_01` — CUSTOM；仅 `surgery_total_mastectomy`，术式一致**
- `P` CN：「……我知道自己答应了完整切除。可真到了这一步，还是会难过一下。……让我确认，你们记得说好的范围吧？」 EN: “...I know I agreed to the complete removal. But being at this point still hurts emotionally. ...Please confirm that you remember the scope we agreed on.”
- `R:acknowledge_mastectomy_loss` CN：「……谢谢你没拿玩笑搪塞我。范围我听清楚了，继续吧。」 EN: “...Thank you for not brushing it aside with a joke. I've heard the scope clearly. Please continue.”
- `R:confirm_mastectomy_plan` CN：「嗯，严格按同意范围。……我相信你们。别让我自己再吓自己了。」 EN: “Mm, strictly within the consented scope. ...I trust you. Don't let me frighten myself with guesses.”

#### `ongoing_interaction`／持续手术与体位疲劳（10／10）

**`ongoing_fear_default_01` — CUSTOM**
- `P` CN：「……怎么又这么安静。坂口医生，至少让我知道你们没有遇到麻烦，好吗？」 EN: “...It's gone so quiet again. Dr. Sakaguchi, could you at least let me know nothing's gone wrong?”
- `R:reassure_ongoing` CN：「嗯，还按计划……好，听到你说话就放心些。」 EN: “Mm, still on plan... Good. Hearing you say it helps.”
- `R:brief_ongoing` CN：「一切正常。……这四个字今天真好听。」 EN: “Everything's normal. ...Those words sound wonderful today.”

**`ongoing_default_01` — CUSTOM**
- `P` CN：「我这个患者表现得还乖吗？呵呵，平时都是我让别人保持不动，今天轮到你们盯着我啦。……说真的，这样躺着也不容易呢。」 EN: “Am I being a good patient? Hehe, usually I'm the one telling people to hold still. Today you get to keep an eye on me. ...Honestly, lying here isn't easy either.”
- `R:coach_ongoing` CN：「知道啦。别看我现在乖乖躺着，就以为我听不懂指令。……呵呵，好，我不乱动。」 EN: “I know. Just because I'm lying here so obediently doesn't mean I've forgotten how to follow instructions. ...Hehe, all right, I'll hold still.”
- `R:reassure_ongoing_default` CN：「这样就可以？……呵呵，今天被你表扬一句，我居然还有点得意。好，我保持不动。」 EN: “I'm doing fine like this? ...Hehe, I can't believe I'm a little pleased to get praise from you today. All right, I'll stay still.”

**`ongoing_fear_fatigue_01` — CUSTOM**
- `P` CN：「……好像又过了很长一段。以前我在旁边忙起来就忘了钟，现在只剩钟在脑子里走。」 EN: “...Feels like another long stretch has passed. When I was working beside the table, I'd forget the clock. Now I can't think of anything but time.”
- `R:maintain_running_update` CN：「这样好……哪怕只告诉我一个节点，我也不会一直乱想。」 EN: “That's better... Even one small update keeps my mind from running away with me.”
- `R:brief_running_update` CN：「稳定就好。……我现在已经不奢望每一分钟都被报告了。」 EN: “Stable is good. ...I no longer expect a report every minute.”

**`ongoing_fear_fatigue_02` — CUSTOM**
- `P` CN：「我有点撑不住这种等法了……能不能告诉我接下来至少要完成哪一步？」 EN: “This waiting is getting to me... Can you tell me at least what the next milestone is?”
- `R:preview_next_milestone` CN：「好，下一个目标我听见了。……等做到那里，我要给自己记一分。」 EN: “All right, I've heard the next goal. ...When we reach it, I'm awarding myself a point.”
- `R:encourage_next_milestone` CN：「快到下一阶段了？……你可真会鼓励人。今天轮到我信这套了。」 EN: “Almost at the next stage? ...You really do know how to encourage someone. Today it's my turn to believe it.”

**`ongoing_pain_position_01` — CUSTOM**
- `P` CN：「……我是不是不能挪肩膀？这里压得好难受。支撑好像偏了一点……你们能帮我确认吗？我不自己动。」 EN: “...I'm not supposed to move my shoulder, right? The pressure here is awful. I think the support's shifted a little... Could you check it for me? I won't move on my own.”
- `R:adjust_pressure_points` CN：「谢谢……那个受压点调整以后好多了。巡回那边辛苦啦。」 EN: “Thank you... That pressure point feels much better after the adjustment. Much appreciated, circulating nurse.”
- `R:coach_position_stillness` CN：「好，我不自己动……慢慢松一点。嗯，这样可以。」 EN: “All right, I won't move on my own... I'll relax a little at a time. Mm, this works.”

**`abdominal_ongoing_pressure_01` — CUSTOM；仅 `general_abdominal`**
- `P` CN：「呼……腹部深处一直闷沉沉的。坂口医生，按计划还剩多久？……别让我光听着器械声自己乱猜啦。」 EN: “Hah... There's a constant heavy feeling deep in my abdomen. Dr. Sakaguchi, how much longer according to the plan? ...Don't leave me guessing from the instrument sounds alone.”
- `R:explain_abdominal_pressure` CN：「关键阶段啊……难怪感觉这么明显。好啦，指挥权暂时交给你们，我只负责好好呼吸。」 EN: “A critical stage, then... No wonder I can feel it so clearly. All right, I'll leave the team in charge for now and focus on breathing.”
- `R:brief_abdominal_pressure` CN：「这种压力在预期内……嗯，知道就好。」 EN: “That pressure is expected... Mm, good to know.”

**`pelvic_ongoing_position_01` — CUSTOM；仅 `female_pelvic`**
- `P` CN：「……腰腿这样固定着，时间一长真的很累。你们能再看看支撑吗？我知道不能自己挪，可这个姿势真的好难熬……」 EN: “...Being positioned like this for so long is exhausting my lower back and legs. Could you check the supports again? I know I shouldn't shift by myself, but this position is so hard to bear...”
- `R:support_pelvic_position` CN：「啊，支撑重新调过了？好舒服一点……谢谢。」 EN: “Ah, you've adjusted the supports? That does feel a little better... Thank you.”
- `R:coach_pelvic_position` CN：「嗯，腰先松，腿不要乱使劲……我跟着做。」 EN: “Mm, relax my lower back first, don't tense my legs... I'll follow your directions.”

**`thoracic_ongoing_position_01` — CUSTOM；仅 `thoracic`**
- `P` CN：「肩背好麻……不是在说伤口，是这个姿势。……我知道不能自己翻过去，可我真的很想动。」 EN: “My shoulder and back feel so stiff... Not the incision, the position. ...I know I can't turn myself over, but I really want to.”
- `R:check_thoracic_support` CN：「嗯，背后舒服多了。还好你问得及时……不然我都快把被单抓出洞了。」 EN: “Mm, my back feels much better. Good thing you asked when you did... I was about to grip a hole right through the sheet.”
- `R:coach_thoracic_stillness` CN：「好，我只放松能放松的地方。……这种时候别让我证明我有多能忍。」 EN: “All right, I'll relax only what I safely can. ...This isn't the time to make me prove how tough I am.”

**`cardiac_ongoing_fatigue_01` — CUSTOM；仅 `cardiac`**
- `P` CN：「……你们是不是还在继续？我现在连器械的声音都分不太清了，怕自己胡思乱想。」 EN: “...You're still working, aren't you? I can barely tell the instrument sounds apart anymore. I'm afraid I'll start imagining things.”
- `R:reassure_cardiac_ongoing` CN：「嗯，知道现在的进度了……我会跟上，不再自己乱猜。」 EN: “Mm, now I know where we are... I'll keep up and stop guessing.”
- `R:brief_cardiac_ongoing` CN：「还在照计划推进……好。谢谢你说这句。」 EN: “Still proceeding as planned... Good. Thank you for saying so.”

**`vascular_ongoing_pressure_01` — CUSTOM；仅 `vascular`**
- `P` CN：「……刚才那种压力又来了。我知道你们盯着监测，可我自己也忍不住想问一句。」 EN: “...That pressure has come back. I know you're watching the monitors, but I can't stop myself from asking.”
- `R:separate_vascular_sensations` CN：「哦，这部分感觉和你们看的指标不是一回事……我明白了。谢谢解释。」 EN: “Oh, what I'm feeling isn't the same thing as the measurements you're watching... I understand. Thanks for explaining.”
- `R:brief_vascular_pressure` CN：「还在严密监测……嗯，行。我就尽量听你们的。」 EN: “You're still monitoring everything closely... Mm, all right. I'll try to follow your lead.”

#### `closure_interaction`／收尾与最后复核（5／5）

**`closure_default_01` — CUSTOM**
- `P` CN：「……你们是不是准备收了？……我这个患者已经没有精力再猜器械声了。」 EN: “...Are you about to close? ...This patient of yours is out of energy for guessing instrument sounds.”
- `R:confirm_closure` CN：「主要步骤完成了？……天啊，这句我从没觉得这么好听。」 EN: “The main steps are finished? ...Goodness, I've never heard anything so lovely.”
- `R:brief_closure` CN：「最后检查……嗯，我等。……别让我睡着了又把我叫醒做问答。」 EN: “Final checks... Mm, I'll wait. ...Just don't wake me up for a quiz if I drift off.”

**`closure_fear_closure_01` — CUSTOM**
- `P` CN：「你们说‘收尾’了是不是……？别骗我，我现在连开玩笑都没力气了。」 EN: “You said ‘closing,’ didn't you...? Don't tease me. I don't even have the energy to joke anymore.”
- `R:confirm_closure_phase` CN：「嗯，真的进入关闭阶段了。……好……呼……我再等等。」 EN: “Mm, we're really in the closure phase. ...Good... Hah... I'll wait a bit longer.”
- `R:brief_closure_phase` CN：「最后处理……好。我现在只想听见你说‘完成’。」 EN: “The final work... All right. All I want to hear now is ‘finished.’”

**`closure_fear_closure_02` — CUSTOM**
- `P` CN：「……怎么还要检查啊……我知道检查很重要，可我真快撑不住了。」 EN: “...Why are there more checks...? I know they're important, but I'm almost at my limit.”
- `R:explain_final_checks` CN：「一项项复核……好，我听清楚了。每完成一项就告诉我一声，好吗？……我真的快没力气了。」 EN: “Checking each item... All right, I understand. Could you tell me whenever one is finished? ...I'm really running out of strength.”
- `R:confirm_final_checks` CN：「正在收尾……嗯。拜托，这次真的快结束吧。」 EN: “You're closing... Mm. Please, let this really be the end soon.”

**`closure_pain_closure_01` — CUSTOM**
- `P` CN：「呜……最后这里怎么又难受起来了……我真不想在快结束时乱动……！」 EN: “Ngh... Why does this last part hurt again...? I really don't want to move when we're so close to finishing...!”
- `R:pause_closure_discomfort` CN：「啊……缓了一点。谢谢你没因为快结束就催我。」 EN: “Ah... A little better. Thank you for not rushing me just because we're nearly done.”
- `R:pace_closure_breathing` CN：「好……我跟着……吸、呼……嗯，继续。」 EN: “All right... I'll follow... In, out... Mm, continue.”

**`breast_closure_fear_01` — CUSTOM；仅 `breast`，且邀约术式一致；不默认全切**
- `P` CN：「……胸前这边是不是已经完成了？我怕自己问得太早……可我真的想知道。」 EN: “...Is the work on my breast finished now? I'm afraid I'm asking too soon... But I really want to know.”
- `R:answer_breast_closure` CN：「嗯，做完的范围跟术前说的一样……好，我安心了。」 EN: “Mm, the completed work matches the scope we discussed... Good. That puts me at ease.”
- `R:brief_breast_closure` CN：「正在照计划收尾。……我等你们说最后那一句。」 EN: “Closing as planned... I'll wait to hear you say that final word.”

### C2-v2. 高频通用池的第二完整版本（`RESERVE`，暂不自动随机）

以下是**整套**第二版本；仅在 Runner 证实支持“同一池的一整组 `P + 所有 R` 同步切换”时才启用。未确认时，只用上述 `v1`，不可单独随机换一个 prompt 而保留不相干的 response。

**`contact_default_01 / v2`**
- `P` CN：「已经开始啦？呵呵，我刚才还想装成最镇定的患者，让你们猜我在想什么呢。……结果心跳好像先把我出卖了。」 EN: “We've started? Hehe, I was going to play the calmest patient in the room and leave you all guessing what I was thinking. ...But I think my racing heart gave me away first.”
- `R:reassure_start` CN：「嗯，稳定就好。……看来该相信自己的同事。」 EN: “Mm, stable is good. ...Time to trust my own coworkers.”
- `R:brief_start` CN：「按计划进行？好，那我就暂时不追问。」 EN: “Going as planned? All right, I'll stop asking for now.”
- `R:silent_start` CN：「……知道啦，我闭嘴。你们快忙正事。」 EN: “...All right, I'll shut up. You get on with your work.”

**`progress_default_01 / v2`**
- `P` CN：「哎呀，今天怎么还没人主动向我汇报进度？……呵呵，开玩笑的。我知道自己现在是患者，可还是想听你说一声顺不顺利。」 EN: “Oh my, how come nobody's volunteered a progress report to me yet? ...Hehe, I'm kidding. I know I'm the patient now, but I'd still like to hear whether everything's going smoothly.”
- `R:answer_progress` CN：「嗯，听清楚了。谢谢你把我当正常患者说明。」 EN: “Mm, I've got it. Thank you for explaining it to me like any other patient.”
- `R:brief_answer_progress` CN：「好，按计划。……我不再偷听你们交接了。」 EN: “Good, on plan. ...I'll stop eavesdropping on your handoffs.”

**`dignity_default_01 / v2`**
- `P` CN：「……你们不会把今天的我拿去当护士站笑话吧？我平时已经够欠揍了。」 EN: “...You're not going to turn me into a nurses' station joke, are you? I know I ask for it often enough.”
- `R:protect_dignity` CN：「盖好就行。……谢谢，玩笑是玩笑，我真挺感激的。」 EN: “Just keep me covered. ...Thank you. Jokes aside, I really appreciate it.”
- `R:brief_dignity` CN：「快结束这一步了？……那我就再厚着脸皮忍一下。」 EN: “This part will be over soon? ...Then I'll swallow my embarrassment for a little longer.”

**`ongoing_default_01 / v2`**
- `P` CN：「我现在做得怎么样？……你别笑，‘保持不动’这件事我真的在努力。」 EN: “How am I doing? ...Don't laugh. I'm honestly working hard at this ‘holding still’ business.”
- `R:coach_ongoing` CN：「好，姿势保持住……明白，我听你的。」 EN: “All right, hold this position... Understood. I'll follow your lead.”
- `R:reassure_ongoing_default` CN：「这样就很好啊……那我继续当个省事的患者。」 EN: “I'm doing fine like this? ...Then I'll keep being an easy patient.”

**`closure_default_01 / v2`**
- `P` CN：「……我是不是终于快可以从这张台子上下来了？现在想想，能自己走路真幸福。」 EN: “...Am I finally close to getting off this table? Funny how wonderful walking on your own sounds now.”
- `R:confirm_closure` CN：「主要部分都结束了。……谢谢你，隆——坂口医生。」 EN: “The main part is finished. ...Thank you, Ryu—Dr. Sakaguchi.”
- `R:brief_closure` CN：「最后复核，嗯。……我等，别漏了任何一步。」 EN: “Final verification, yes. ...I'll wait. Don't skip a single step.”

### D. 普通手术出口患者台词（是否存在可播放入口须核实）

这不是新建术后病房恢复系统。仅当现有 Runner 有患者合法发言窗口时使用。**高级手术成功／失败结果一律优先使用已经存在的 V2.3 美幸台词，不能用这里的普通候选覆盖。**

| 作者键 | 中文：美幸 | English: Miyuki | 状态 |
|---|---|---|---|
| `surgery_success_awake` | 「……真的完成了？哈……我刚才还想着出院以后要训你们一顿。……算了，先让我谢谢你们。」 | “...It's really finished? Hah... A moment ago I was planning to scold all of you when I got out. ...Forget it. Let me thank you first.” | VERIFY：仅清醒成功出口 |
| `surgery_success_anesthetized` | 「嗯……我醒了？……哦，已经做完了。……别急着让我当护士，我现在得先学会当个病人。」 | “Mm... Am I awake? ...Oh, it's finished. ...Don't rush me back into nursing. I need to learn how to be a patient first.” | VERIFY：必须真实苏醒后 |
| `surgery_abort_or_stop` | 「先停了？……好，把情况讲给我听。我不会因为自己是同事，就假装什么都没发生。」 | “We've stopped? ...All right. Tell me what happened. I won't pretend nothing occurred just because I'm a coworker.” | RESERVE：只限真实安全中止出口 |
| `postop_relief` | 「终于可以自己调整枕头了……明明是我每天替患者做的小事，刚才有人帮我把枕头垫好时，我竟然一下子安心了。……呵呵，换个位置，感觉真的不同呢。」 | “I can finally adjust my own pillow... It's something I do for patients every day, yet when someone tucked mine into place earlier, I felt instantly reassured. ...Hehe, it really does feel different from this side.” | RESERVE：当前无通用术后病房 hook |
| `postop_teasing` | 「哎呀，现在总算能坐起来看着你们说话啦。刚才谁偷偷笑了？……呵呵，放心，我都记得。不过今天先给你们满分吧。」 | “Oh my, I can finally sit up and look you all in the eye again. Who was trying not to laugh earlier? ...Hehe, don't worry, I remember. But I'll give you all full marks today.” | RESERVE：当前无通用术后病房 hook |

### E. 不归本患者台词包所有的内容

- **高级 V2.3：** `data/advanced_surgery/staff_patient/stories.json` 中 `nurse_yui` 的 42 条角色专属中英对白，以及 `common/repeat` 公用对白，保持原文与原触发。这里的普通术中清醒 C2 不应该出现在固定全麻 Advanced Day2。
- **Lv5：** Part A 千惠特别手术、Part B《换我躺一次》、Part C《能者多劳》已另有正式剧本，**一字不改**。本文的患者手术是玩家后来另行预约的训练；不会在 Lv5 播放本稿，也不自行设置关系等级。
- **团队对白：** 别人的助手／器械／巡回／麻醉/主刀台词不属于美幸“患者台词”，本稿不新造团队说话人；美幸本人不可在自己手术中兼任护士岗位。
- **患者准备图：** 原有 SFW 患者衣、手术台普通与截石位、右侧头像、全麻 splash、四张高级台面图等均已登记，本稿不发明新贴图、裸露差分或 Bonus CG 触发；`ward_preparation/shy` 留待用户另行提供。
- **权限与数值：** `required_completed_rank: 5`、全院授权、独立邀约、预约取消、重复同角色同术式 XP 100%→50%→0%、手术不改正反声望均沿用现行 Runner；人物对白不得修改效果。

### QA / 给 Codex 的最小接入协议

1. **先验真实接口。** 对照 `data/staff_patient_profiles.json` 已有 Staff 角色、`data/patients/*` 28 键／13 组、`data/surgeries/patient_interactions.json` 的 50 个池／106 action，以及实际选择动作后谁负责 `response_speaker`，确定可覆写的结构。`staff_patient_profiles.json` 未必直接承载全部 C2；按真实 Loader 放置，而非把 Markdown 作者槽位当 JSON 字段。
2. **严格姓名与年龄。** 保留 `actor_id=nurse_yui`、`朝倉美幸/朝仓美幸/Asakura Miyuki`、星见 23 岁；不能改成名为 Yui 的新患者，不能因“前辈”写成三十多岁老护士。
3. **28/13 逐键对照。** 检查普通患者新增的 `hospitalization_*` 是否在 Staff 流程有 hook；没有就保留 RESERVE。`incision_ready` 必须是刀尚未落下的反应；`incise_*` 必须在真的切开之后。`incision_marking_*` 是另一个时间点。
4. **C2 全池与动作不可漂移。** 50 池均有完整 `P + R` 对应文本（49 CUSTOM、1 `RESERVE/VERIFY`）；每池的 v1 均须覆盖原池全部 action，且原始状态／cues／group／`once_per_surgery`／分钟／数值完全不变。`strain_pain_traction_02` 的原按钮跨部位隐患先解决，不能宣称已可安全播放。
5. **错术式路径。** 当实际术式与邀约不一致，原先列出的 11 个 signature/部位承诺风险池（`hysterectomy_signature_01`, `ovarian_cystectomy_signature_01`, `myomectomy_signature_01`, `breast_tumor_signature_01`, `mastectomy_signature_01`, `cabg_signature_01`, `pelvic_dignity_exposure_01`, `pelvic_dignity_default_01`, `breast_dignity_exposure_01`, `breast_dignity_default_01`, `breast_closure_fear_01`）需要在选择池以前过滤**原通用与专属覆盖**；不修改按钮承诺来掩盖错术式。
6. **麻醉与人物真实性。** 全麻诱导后不播清醒患者台词；清醒、局麻、硬膜外、无麻醉的实际可达状态分别测。不要让已经第二次做相同手术的美幸在每条台词都说“第一次”。工作公开称呼为“坂口医生”，私下可称“隆司”。
7. **英文与声线逐条验收。** 中英文每行对位，同一动作 ID 不能交叉绑定；检查断句、角色口气、紧张程度从前期玩笑到切皮恐惧再到缝合疲劳的渐变。若游戏中文台词要求去除全角引号，作为导入格式转换而非文本改写。
8. **验收但不假报已实现。** 核对 Lv5 完成事实及全局许可后，实机试普通手术邀请、必要／可选准备、清醒下刀、不同 C2 池、术式不一致、取消、同组合重复，分别测试 CN/EN；高级 V2.3 42 条独立回归。运行现有 `staff_patient_lv5_readiness_test.gd`、`advanced_staff_patient_test.gd`、`narrative_localization_test.py`、`localization_audit.py` 和真实窗口显示测试。本文不把文本创作等同测试通过。

### 编剧交付统计

| 内容 | 当前草稿覆盖 |
|---|---|
| 邀约与拒绝 | 普通 A1 3 条，特殊 A1b 5 条，病房占用 A2 1 条（RESERVE）|
| 核心反应 | `reaction_lines` **28 / 28**，含备用住院键与 `incision_ready` |
| 术前准备 | `reaction_variants` **13 组 × 2 条 = 26 条** |
| 术前补充问答 | 4 条患者回合（需实际 speaker hook）|
| 术中互动 | **50 个池／106 个原动作均有完整双语文案**；其中 49 个 CUSTOM v1、`strain_pain_traction_02` 1 个完整待接 `RESERVE/VERIFY`；另 5 组完整 v2 备用 |
| 术后与中止 | 5 条备用／待核实实际出口 |
| 高级手术 V2.3 | **原有 42 条，未修改，非本文新增** |

**编辑结论：** 这份稿可以进入美幸患者身份的**剧情语音审阅**；在 Codex 完成源码接口核实、术式覆盖过滤和实机显示／分支测试前，不应宣称“患者包已实装”。



