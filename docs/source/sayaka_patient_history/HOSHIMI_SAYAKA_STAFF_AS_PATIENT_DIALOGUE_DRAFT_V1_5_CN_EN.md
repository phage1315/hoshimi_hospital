# Hoshimi Hospital / 星见医院
# 南条小夜香 Staff-as-Patient — 专属术前／术中／术后对白 V1.5（CN / EN）

> **状态：V1.5 完整 CN／EN 编剧修订候选稿；尚待用户审稿与 Codex 代码级验收。不是已实装声明。** 以 V1.4 为全文基底：继承32种术式分类、50池／106动作映射、39池专属／11池通用回退及既有全部剧情对白。V1.5 只新增**经阴道子宫全切的三节点连续术前说明替换**、明确的**“那里／这边”成人 VN 含蓄指代写作规范**、一处乳房特定池示范性微调，以及本轮 Codex 反馈揭示的**说话人、原约定术式变量、时序、拒绝入口和未绑定候选**边界。没有修改小夜香 Lv5 A/B/C 或《消失又出现的阑尾》剧情。
>
> **源文件与范围：** 用户提供的 `surgeries.json`（32 个术式）和 `patient_interactions.json`（50 个患者互动池、106 个真实 action），以及 V1.2 完整双语对白。真实 ID、按钮 label、匹配字段严格源自 JSON；新增角色对白为编剧创作，不是原始 JSON 已有台词。**互动池优先级／随机机制／角色对白覆盖 schema 尚未由 Runner 源码证实。**
>
> **覆盖口径：** 39 / 50 个互动池提供小夜香专属 `prompt` + **各真实按钮的 `response`**，11 / 50 个池沿用通用患者文本。另有六套 `v2` 整组变体尚待代码支持；只有 `v1` 为直接候选。**39/50 只代表 C2 内部覆盖率，不代表整个 Surgery Runner 的所有患者发言已经人物化。** 中英文成对。术式不一致场景需要运行时拦截部分依赖术前约定的池；静态 JSON 不能证明已实现。
>
> **系统边界：** 邀请先选已解锁术式并检查病房占用；不经过门诊。没有病房恢复事件。不能为了播放对白新增术中按钮、强迫术前动作、假设已有全麻苏醒窗口、改变 Staff-as-Patient 声望豁免或训练经验规则。全麻诱导后到确实苏醒前不显示小夜香的术中语言回应。
>
> **剧本身份锚点：** 小夜香自愿参与，但经历长时间准备、暴露与切除时仍然会害羞、烦躁、害怕，甚至喊疼求助；她是熟悉流程的综合诊疗医生，不是每一种复杂术式的专家。她和坂口有亲密关系，但团队在正式手术时仍保有职业性，台词不代替医疗流程。
>
> **重要待接线阻断项：** Codex 已观察到“约定乳房肿瘤切除，实际子宫全切”仍触发 `hysterectomy_signature_01`。**此时池中玩家按钮“与术前同意一致”本身不成立**，仅改小夜香回应不能解决；本稿继承的 `C2-MISMATCH` 规则必须由 Runner 按两种术式 ID 拦截相关池。没有拦截能力时，不得宣称错术式路径已验收。
>
> **精确文本边界：** 角色台词在审稿批准后逐字锁定；`pool_id`、`action_id`、界面按钮文本、计时／数值效果均归工程数据定义。**本文件仅提出患者 `prompt` 和 `actions[].response` 的替换候选，不替换玩家按钮、不修改选项 effects／minutes。** 当前材料只证明 JSON 结构，尚不证明任何实现钩子已经存在。
>
> **V1.5 输入证据界限：** 经阴道术式的手术阶段／入路直接对照用户提供的 `surgeries.json` 中 `surgery_vaginal_hysterectomy`；`field / bowel / bowel_answer` 的节点名称和旧文本性质来自 Codex 反馈。**当前没有取得 Codex 本地 `data/patients/templates/preop.json` 在对应位置的原始完整 JSON**，因此本文提供的是逐节点替换的 **CN／EN 编剧原文及严格条件**，并不伪称已核实模板实际字段名、speaker 存储结构或可直接覆盖的代码位置。Codex 必须对照其本机原文件落实，不得把这三段误当作三条新动作。

---
## 0. 写作硬规则：有明确指向的含蓄表达，不得自动中性化（V1.5）

**本条是本项目后续所有成年 Staff-as-Patient／亲密关系下的医疗场景的长期写作指引，而非“可选润色建议”。** 完整独立说明见 `HOSHIMI_STAFF_AS_PATIENT_INTIMATE_EUPHEMISM_WRITING_RULE_V1.md`。

1. **经阴道及其他私密生殖系统术式：** 医疗场景和情侣前史已经明确指向部位时，患者的「那里」「那个地方」「从那里进去」是**有意留白、却指向清楚**的暧昧表达。不可擅自改为「我身体里面」「腹部内部」「解剖区域」等泛泛的医学习惯语。保留「那里」与「解剖结构」同一句的反差，也保留「你」对坂口作为恋人的第二人称指向。
2. **乳房相关术式：** 同样允许「这里」「这边」「你平时总爱夸的地方」这种有亲密意味的含蓄说法，但整体可以比经阴道入路的台词**稍轻、稍克制**；不能因为是专业手术就彻底消除角色对自己身体和两人关系的联想。
3. 这种成人 VN 阅读感**来自已知的亲密历史＋准确的术式语境＋角色不敢明说的措辞**，不是通过增加露骨性行为描写、歪曲医学操作或让所有角色不停调情来实现。面对疼痛、狼狈或严肃医护判断时，她也应当能够说纯粹的恐惧和抱怨。
4. **英文必须等效保留指向：** 特定语境的「那里」可译作 *down there* / *that place*，不应翻成 *inside my body*。中文的「你」不应自动模糊成不具情侣指向的 *the surgeons*。若临床解释者不是坂口，患者仍可以在确实有坂口在场的既有发言窗口转向对他说话；不能据此替换讲解人的 speaker。
5. **精确术式限制：** 经阴道语义只在确实是经阴道入路时出现；不把妇科 `female_pelvic` 整组都视为经阴道手术。乳房用语仅在乳房术式或明确限定的池中出现。术式不一致路径仍严格遵守 `C2-MISMATCH`。

**不得中性化的示例：**

- 原意：「完了，我连**那里**的解剖结构都被**你**看得一清二楚了……」
- 禁止自动改成：「连**我身体里面**的解剖结构都要被**医生**看清楚。」
- 英文侧应保留 *the anatomy down there* 以及对恋人的 *you*，不是泛指 *anatomy inside my body*。
- 用户举出的其他高价值语境原句亦作为**写作锚点，而非自动加入游戏的节点**：「天、天哪，真的要从那里切进去开刀吗？！」「虽然知道明天就会恢复原样，也完全不会变松，但想到那里要开刀还是感觉好奇怪……」「你、你看到什么……别笑！你平时那么爽，你以为是为什么啊？！」不因语气大胆而自动改成模糊的职业语言。

---

## A. 邀约、确认与拒绝

### A1. `SAP-SAYAKA-INVITE-*`（从 3 条随机）

| ID | 中文：南条小夜香 | English: Sayaka |
|---|---|---|
| `SAP-SAYAKA-INVITE-01` | 「{procedure_name}？呵呵，你还真会挑呀。好，我答应。不过到了手术台上，我要是叫出声，可不许你事后拿来笑我哦！」 | “{procedure_name}? Hehe, you certainly know how to pick one. All right, I'm in. But if I end up screaming on the operating table, you don't get to tease me about it afterward!” |
| `SAP-SAYAKA-INVITE-02` | 「哦，这次是{procedure_name}呀。听名字就知道不会太轻松……不过难得有机会从患者这边体验一次，我还真有点好奇呢。你要认真对待我哦，坂口医生。」 | “Oh, {procedure_name} this time. Even the name tells me this won't be a walk in the park... But a chance to experience it from the patient's side? I'm genuinely curious. Take good care of me, Dr. Sakaguchi.” |
| `SAP-SAYAKA-INVITE-03` | 「{procedure_name}？行呀。不过这次我可不会像第一次那样，傻乎乎地以为进手术室就能马上开刀了。给我排好时间，别让我在台上等到怀疑人生哦！」 | “{procedure_name}? Sure! But I'm not going to make the same mistake as last time and think surgery starts the moment I enter the OR. Schedule it properly—don't leave me lying there long enough to question my entire existence!” |


### A1b. 重大／特殊术式邀约：5 条专属覆盖（沿用 V1.2 原文，V1.3 确定分类映射）

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

### A1c. 32 个真实术式 → 唯一邀约类别建议（V1.3 新增；不是工程字段）

本表逐项对应本次 `surgeries.json`，避免靠术式名的“切除”字样猜类别。特殊邀约是替换原 A1 的同一次回应，不额外播放；如未实现条件筛选，需 Codex 报告而不是偷偷新增分支。`status=ready` 与“已由玩家解锁”不是一回事。

**优先级：** `HYSTERECTOMY` / `MASTECTOMY` → `ORGAN-REMOVAL` → `MAJOR-GYN`（本版无匹配）→ `MAJOR` → A1 普通三条随机之一。

| 实际 `surgery_id` | 已注册中文术式 | 难度 | 邀约类别（仅写作建议） |
|---|---|---:|---|
| `surgery_appendix` | 开腹阑尾切除 | 32 | A1 默认 |
| `surgery_breast_tumor` | 乳房肿瘤切除 | 38 | A1 默认 |
| `surgery_hysterectomy` | 开腹子宫全切除 | 68 | HYSTERECTOMY |
| `surgery_cabg` | 开胸心脏搭桥 | 92 | MAJOR |
| `surgery_exploratory_laparotomy` | 大开腹探查 | 82 | MAJOR |
| `surgery_open_cholecystectomy` | 开腹胆囊切除 | 42 | **已确认：本版回退 A1** |
| `surgery_open_inguinal_hernia` | 腹股沟疝修补 | 35 | A1 默认 |
| `surgery_open_ventral_hernia` | 腹壁疝修补 | 45 | A1 默认 |
| `surgery_open_distal_gastrectomy` | 开腹部分胃切除 | 62 | MAJOR |
| `surgery_open_total_gastrectomy` | 开腹全胃切除 | 78 | ORGAN-REMOVAL |
| `surgery_open_right_hemicolectomy` | 开腹右半结肠切除 | 68 | MAJOR |
| `surgery_open_sigmoid_colectomy` | 开腹乙状结肠切除 | 70 | MAJOR |
| `surgery_open_abdominoperineal_resection` | 开腹直肠切除（含肛门） | 84 | MAJOR |
| `surgery_open_whipple` | 开腹胰十二指肠切除 | 95 | MAJOR |
| `surgery_open_major_liver_resection` | 开腹肝叶切除 | 90 | MAJOR |
| `surgery_open_splenectomy` | 开腹脾切除 | 58 | **已确认：本版回退 A1** |
| `surgery_open_ovarian_cystectomy` | 开腹卵巢囊肿切除 | 48 | A1 默认 |
| `surgery_open_abdominal_myomectomy` | 开腹子宫肌瘤剔除 | 55 | A1 默认 |
| `surgery_total_mastectomy` | 全乳房切除 | 58 | MASTECTOMY |
| `surgery_open_lung_lobectomy` | 开胸肺叶切除 | 78 | MAJOR |
| `surgery_open_pneumonectomy` | 开胸全肺切除 | 88 | ORGAN-REMOVAL |
| `surgery_open_esophagectomy` | 开胸食管切除 | 94 | MAJOR |
| `surgery_open_radical_cystectomy` | 开腹膀胱全切除 | 87 | ORGAN-REMOVAL |
| `surgery_open_nephrectomy` | 开腹肾切除 | 72 | ORGAN-REMOVAL |
| `surgery_open_abdominal_aortic_aneurysm` | 开腹主动脉瘤修补 | 93 | MAJOR |
| `surgery_vaginal_hysterectomy` | 经阴道子宫全切除 | 70 | HYSTERECTOMY |
| `surgery_adv_artificial_heart_exchange` | 开胸人工心脏系统置换 | 90 | MAJOR |
| `surgery_open_distal_pancreatectomy` | 开腹胰体尾切除 | 76 | MAJOR |
| `surgery_open_partial_nephrectomy` | 开腹部分肾切除 | 80 | MAJOR |
| `surgery_open_adrenalectomy` | 开腹肾上腺切除 | 74 | **已确认：本版回退 A1** |
| `surgery_open_left_hemicolectomy` | 开腹左半结肠切除 | 72 | MAJOR |
| `surgery_open_low_anterior_resection` | 开腹低位直肠前切除 | 82 | MAJOR |

- `HYSTERECTOMY`：仅开腹／经阴道两种**完整子宫切除**；不要套用到子宫肌瘤剔除。
- `MASTECTOMY`：仅 `surgery_total_mastectomy`；乳房肿瘤切除沿用普通 A1。
- `ORGAN-REMOVAL`：本版先明确全胃、全肺、膀胱全切、整肾切除四项；胆囊／脾／肾上腺切除经本轮确认：**本版固定使用 A1 普通回退，不再视为待决缺口**。
- `MAJOR` 为逐项白名单，不是 `base_difficulty >= X` 的伪规则。`MAJOR-GYN` 暂无命中，不删除候选台词。胆囊、脾、肾上腺切除本版已统一确定 A1 回退，不需再向用户追问。
- 每次只能命中一条特殊邀约，未命中或尚未分类的术式使用普通 A1 三句之一。Code review 须核验 `procedure_name` 的双语占位符展开和病房占用判断先后顺序。


### A2. 病房已有患者

| ID | 中文：南条小夜香 | English: Sayaka |
|---|---|---|
| `SAP-SAYAKA-WARD-BUSY-01` | 「等等，你病房里不是还有一位等着开刀吗？先把人家照顾好啦！我又不会跑掉，等你忙完再来邀请我嘛。」 | “Wait, don't you still have a patient waiting for surgery in the ward? Take care of them first! I'm not going anywhere. Come ask me again once you've finished.” |

> **V1.5 接线状态：备用文本，尚未有角色对白入口。** 当前病房占用只弹出系统提示；不要因为此行已写便让 Codex 擅自增加患者／员工对话节点。若未来批准新增角色提示入口，再按此稿中英接入。

---

## B. 术前准备与病房回应

### B1. 核心 `reaction_lines`

| Key | 中文：南条小夜香 | English: Sayaka |
|---|---|---|
| `procedure_mismatch` | 「等一下！我记得我们约好的不是这个术式吧？喂，坂口，别光顾着看手术单，先跟我把变化讲明白呀。我是肯让你开刀，又不是连自己要做什么都不问！」 | “Hold on! That's not the procedure we agreed on, is it? Hey, Sakaguchi, stop staring at the chart and explain what's changed. I'm willing to let you operate, but that doesn't mean I won't ask what you're doing to me!” |
| `explain_plan` | 「我也当过给患者说明的人嘛，流程我大致懂。不过今天换我躺上去……从哪儿开始、关键步骤怎么做、我清醒的时候会感觉到什么，你还是认真讲给我听一次吧。」 | “I've been the doctor explaining procedures, so I know the general routine. But today I'm the one on the table... Tell me where you start, what the crucial steps are, and what I might feel if I'm awake. Properly, please.” |
| `brief_plan` | 「嗯，术式我记住了。你讲得这么简短，是怕我反过来考你吗？呵呵……不过该核对的部分可别省哦。接下来才轮到选麻醉，对吧？」 | “Mm, I've got the procedure. Such a short explanation—worried I'll start quizzing you? Hehe... Just don't skip the checks that matter. We choose the anesthesia next, right?” |
| `last_reassure` | 「……我知道你们会认真核对今天实际要做的步骤。可一想到接下来要接受一项项准备，最后躺在手术台上让大家围着我忙……我就有点笑不出来了耶。坂口，等会儿别丢下我一个人胡思乱想哦。」 | “...I know you’ll carefully check every step of the procedure you’re actually doing today. But thinking about all the preparations still ahead, and then lying on that table with everyone working around me... I’m not finding it so easy to smile anymore. Sakaguchi, don’t leave me alone with my imagination, okay?” |
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

**重要技术说明：** 现有 Runner 的术前说明分为**腹部、乳房、妇科盆腔、胸心**四种类别，**不是 32 个术式各自完整的权威讲解**。首版沿用真实适用的类别说明文本，不把泛用说明谎称为每种手术都完全适配。若当前术式关键步骤超出现有类别说明，应向 Codex 报告专项缺口。流程是 **病房说明最初邀约术式 → 患者问答 → 麻醉选项 → 手术室团队检查 → 手术室实际选择术式（可能不一致）**。说明阶段的 `{procedure_name}` 指向**最初邀约术式**，不是后来实际手术的 ID；只有手术室选术式之后才可能判定 mismatch。说明阶段不能宣称麻醉已经选定，也不能提前插入错术式事件。讲解人沿用 Runner 实际选择的医护，**不自动改成坂口**。下表带讲解人说话的内容都是候选覆盖，仅在真实窗口允许替换时播放；无法覆盖应继续沿用适用的现有讲解，不能把小夜香对白写进旁白 speaker。

**B1a 中间节点接入决定（V1.5）：**

- **首版保留其他适用类别模板中穿插的通用患者原文**，不把这些语句视为“小夜香专属”。**唯一明确的局部例外**是下方 `B1a-VH`：最初邀约术式为 `surgery_vaginal_hysterectomy` 时，`field`、`bowel`、`bowel_answer` 三节点须整组使用经阴道入路的替换文案，不得混用开腹旧句；其他中间患者句仍沿用通用原文。小夜香专属入口问题、结尾回应仅在工程有独立覆盖窗口时替换；不能用一句概括回应覆盖整个多轮模板、造成重复提问。若通用文本含与她 Lv5 历史不符的个人事实，由 Codex 列出原节点与原文后再单独修订。
- 四类模板是**内容分组，不是术式路径完全吻合的证据**。`surgery_vaginal_hysterectomy`（经阴道子宫全切）**已在 V1.5 下方补齐 `field / bowel / bowel_answer` 连续三节点替换原文**；Codex 对照其实际 `data/patients/templates/preop.json` 找到对应节点后，只在该术式对应的**病房说明**中一起替换。不得只删“开腹”两字却继续播放“肠子被推走”的旧问答，也不得改变开腹子宫全切的现有模板。这不代表其它全部术式已获得专项说明。
- **时序修正（P0）：** 术前讲解发生于手术室实际选术式**之前**，当时只能以**最初邀约的术式**为信息对象。若后续手术室选中另一个术式，再播放 `procedure_mismatch`（既有节点）；**当前没有“错术式后重新讲解”的分支，V1.5 不伪造或要求新增该分支**。此后仍不得出现“与最初约定完全一致”的按钮／台词，继续沿用 `C2-MISMATCH` 的匹配限制。也不得把病房说明的 `{procedure_name}` 当成实际手术术式使用。
- 麻醉仍严格在说明之后选择；本节不得提前宣称某一麻醉方案已定。讲解者是**现有 Runner 指定的实际医护**，并非固定坂口。

| 节点 / Key | 中文原文（说话人明确） | English |
|---|---|---|
| `graphic_preop_question` | 南条小夜香：「我知道这台叫{procedure_name}。不过说实话，这一科的细节我未必比患者懂得多。你们准备从哪里进去、关键一步怎么完成？如果之后选清醒麻醉，哪些感觉可能出现，什么情况要立刻告诉你们？」 | Sayaka: “I know the procedure is called {procedure_name}. But honestly, I don't necessarily know this specialty any better than a patient. Where will you approach it, and what's the critical step? If I choose to stay awake later, what might I feel, and what should I tell you about right away?” |
| `appropriate_answer`（条件候选；不强行覆盖现有讲解人） | **当班讲解医护（由 Runner 决定）**：「你问得对。先把目前手术单上实际要做的术式和主要步骤讲清楚，再讨论不同麻醉方式下可能的感受与安排。哪里没明白，你就继续问。」**〔随后播放工程确实存在的对应类别说明；如果缺少该术式所需的专项细节，报告缺口，不宣称已经补齐。〕** | **Actual explaining clinician (selected by the Runner):** “Good questions. We’ll go through the procedure actually listed for this operation and its major steps first, then discuss what you might experience with different anesthesia options. If anything isn’t clear, keep asking.” **[Use only the actual explanation currently supported for this category; report missing procedure-specific details.]** |
| `appropriate_answer` 后的小夜香回应 | 南条小夜香：「嗯，这下我心里有数了。谢谢你认真讲给我听。呵呵，以前总是我解释到口干舌燥，今天轮到你啦。好，接下来让我认真想想麻醉怎么选。」 | Sayaka: “Mm, now I know what to expect. Thanks for taking the time to explain. Hehe, I'm usually the one talking myself hoarse. Today it's your turn. All right, now let me give the anesthesia choice some proper thought.” |
| `graphic_answer`（条件候选；不强行覆盖现有讲解人） | **当班讲解医护（由 Runner 决定）**：「你不是说想知道细一点吗？那就把这一类手术已经确定的步骤，以及不同麻醉选择下可能经历的感受认真讲给你听。听着害怕的话，可以告诉我。」**〔播放现有类别详细说明，专项不足时明确报缺口。〕** | **Actual explaining clinician (selected by the Runner):** “You asked for more detail, so let's go carefully through the steps covered by this surgical plan, and what you might experience under different anesthesia choices. Tell me if the explanation frightens you.” **[Use the existing category-level explanation; report missing procedure-specific material.]** |
| `graphic_preop_dialogue`（可选分支） | 南条小夜香：「哎呀，你讲得也太有画面感了吧！刚刚我还觉得自己像在听手术讨论会，现在突然发现，待会儿躺在那儿的人就是我耶……别看我笑，心跳真的快起来啦。」 | Sayaka: “Wow, you certainly know how to paint a picture! A moment ago this felt like an ordinary surgical conference. Now I've suddenly remembered that *I'm* the one who'll be lying there... Don't let the smile fool you. My heart really is racing.” |
| 麻醉选择前的最终确认（只有既有窗口支持时播） | **当班确认医护（由 Runner 决定）**：「术式和关键步骤都确认清楚了。接下来再核对麻醉选择。」／南条小夜香：「嗯。我知道今天要做{procedure_name}，需要经历哪些准备，也明白麻醉会改变我能感受到什么。来吧，这次我会认真选，不会光顾着逞强。」 | **Actual confirming clinician (selected by the Runner):** “We've confirmed the procedure and the essential steps. Now let's verify the anesthesia choice.” / Sayaka: “Mm. I know we're doing {procedure_name}, what the preparation involves, and how anesthesia changes what I'll experience. All right. I'll make a proper choice this time instead of just trying to act tough.” |

### B1a-VH. 经阴道子宫全切：`field → bowel → bowel_answer` 三节点连续替换（V1.5 新写 CN／EN）

**只在病房详细说明阶段，且该阶段最初邀约术式为 `surgery_vaginal_hysterectomy` 时使用。** 这是既有妇科说明里的**三条原节点文案的条件替换**，不是增加三个新选项、三轮独立问答或新的医疗操作。若该模板使用数组、嵌套 ID 而非直接 Key，请 Codex 根据其本机 `data/patients/templates/preop.json` 的真实结构**逐一定位**，不能凭这里的语义键猜 JSON 路径。`surgeries.json` 的该术式阶段明确包含宫颈周围入路、后穹隆／前方暴露、血管与支持结构处理、经阴道取出子宫、残端关闭；下面文字按这条真实手术路径撰写。

| 原节点（Codex 报告语义名） | 谁说／触发 | 中文原文（整条替换） | English（完整等义翻译） |
|---|---|---|---|
| `field` | **当前负责解释的医护**；病房，术式说明中段 | 「这次是经阴道子宫全切，不像开腹手术那样先在肚子上开切口。我们会从阴道这一侧暴露宫颈，沿宫颈周围的层次逐步分离、处理支持结构和子宫血管，再经阴道把子宫取出，最后检查止血并关闭阴道残端。膀胱和直肠都靠得很近，整个过程中会仔细辨认和保护。至于你清醒时可能会有什么感觉，等麻醉方式选定后我们再确认。」 | “This is a vaginal hysterectomy. Unlike an open abdominal procedure, we won't begin with an incision in your abdomen. We'll expose the cervix through the vaginal approach, work through the tissue planes around it, address the supporting structures and uterine blood vessels, and remove the uterus vaginally. After that we'll check for bleeding and close the vaginal cuff. The bladder and rectum are close to the operative field, so we'll identify and protect them carefully throughout. Once you've chosen an anesthesia method, we'll go over what you might feel if you're awake.” |
| `bowel` | **南条小夜香（患者）**；承接 `field`，不更换为旁白 | 「天、天哪……真的要从那里切进去开刀呀？！明明我也知道什么叫经阴道手术，可轮到自己……坂口，完了，我连那里的解剖结构都要被你看得一清二楚了……别、别笑！我是在认真问啦！……还有，旁边不是膀胱和直肠吗？是不是也要把肠子推到一边去？」 | “G-good heavens... you're really going to make the incision down there?! I know perfectly well what a vaginal procedure is, but now that it's *me*... Sakaguchi, oh no, you're going to see the anatomy down there in every little detail... D-don't laugh! I'm asking a serious question! ...And aren't the bladder and rectum right next to it? Will you have to push my intestines aside too?” |
| `bowel_answer` | **当前负责解释的医护**；必须接上上一句问题 | 「不需要像开腹手术那样，先把肠管大范围移开来建立腹部术野。这次主要经阴道、沿宫颈周围的层次操作；仍然要注意深部与腹腔的关系，尤其要保护膀胱和直肠。具体到牵拉、压迫会感觉多少，要看你接下来选的麻醉方式。我们会在开始前再和你确认。」 | “We won't need to move the intestines extensively to establish an abdominal operative field the way we would in an open procedure. This operation is approached vaginally, following the tissue planes around the cervix. We'll still watch the deeper anatomy and its relation to the abdominal cavity, especially protecting the bladder and rectum. How much traction or pressure you might feel depends on the anesthesia you choose next. We'll confirm that with you before we begin.” |

**不能丢掉的戏剧性：** 小夜香说的「**那里**」和「**你**」是刻意的。医疗人员说的是专业术语，她却在向坂口这个已经与她亲密相处过的男人求证“**连那里的解剖结构都要被你看得一清二楚**”，随后慌忙用医学问题掩饰脸红。**不准把此句改成“身体里面的器官结构会被医生看见”**，也不能在英文里把 *down there* 弱化成 *inside my body*。

**不可误接／不可虚称已完成的部分：**

- `field / bowel / bowel_answer` 三句**整体替换**，单句改写一律不够；旧 `bowel`“肠子被推走”的问题及旧回答应和开腹说明一同排除。若模板里还有其他明确写“开腹／腹壁入路／移动肠管”的节点，本组三句**不自动解决那些节点**，Codex 仍须列出路径与原句。
- 替换条件使用**病房说明时的最初邀约术式**，不是后续手术室实际选择术式。错术式之后目前**没有再解释阶段**；不能假设这段讲解会在术式被改成经阴道切除时补播。
- `field` 和 `bowel_answer` 的说话人始终是**Runner 实际指定的讲解医护**，`bowel` 是**小夜香**；不得因小夜香叫“坂口”就把医护讲解人强行改成坂口。若实际发言窗口无法向坂口说话，Codex 报告舞台映射疑问，而不是擅自删去「你」。
- **本条不提前选择麻醉**、不自动允许特定手术在任意麻醉条件下实施，不修改医疗步骤、手术时间、玩家选项、声望或训练收益。
- **本轮只拿到 `surgeries.json` 与 Codex 对这三个节点的反馈，没有取得真实模板相邻的完整 JSON**；本段是可供 Codex 逐节点替换的编剧文本，仍需它在实际文件里核验 speaker、键与邻接顺序后才算接线成功。

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

### C2. 真实患者互动池逐项覆盖：`pool_id + actions[].id`（V1.3 重写）

本节以用户提供的 **`patient_interactions.json` 的 50 个真实池、106 个真实 action** 为唯一接口参照。**点击按钮文本沿用原 JSON，本文只覆盖小夜香的 `prompt` 和对应 `response` 的中英文文案。**

**39 池专属、11 池回退**。每个专属池的 `v1` 都完整对应它的全部真实按钮（没有“实际两按钮却写了三条回应”的问题）。六个重点池另有 `v2` 完整候选：它们并不是第二轮额外对白，也不自动成为同池随机机制；在 Codex 验证确实支持随机整组文本之前，仅 `v1` 为接入候选，`v2` 暂存。

**继承／限制：** Pool 原本的 `theme`、`states`、`cues`、`procedure_groups`、`surgery_ids`、`required_flags`、`excluded_flags`、`once_per_surgery`、`actions[].label`、`minutes`、`effects`、`condition_effect` 一律**原样继承**，不在人物对白文件里复制出第二套数值。实际调度优先级必须由 Runner 代码验证，不能根据 JSON 静态推断。清醒状态才播放患者台词；不匹配术式或未命中专属覆盖时回退原池完整文本。

#### C2-MISMATCH. 约定术式与实际术式不一致时的硬性演出限制（V1.4 新增）

**触发条件（语义定义，非新建标记名）：** 实际执行手术的 `surgery_id` 与医护界面最初邀请确认的 `surgery_id` 不相同。Codex 应追查**真实的两份术式 ID 如何在当前 episode 保留／读取**，不得在写作稿里猜一个新的 engine flag。

1. **先保留** B1 的 `procedure_mismatch` 专属反应；它只会在手术室**实际选择术式之后**出现；病房术前说明仍针对之前确认的**邀约术式**。**没有错术式后的补充专业说明节点，不能为接这句对白擅自新建。** 这项反应不改变 Staff-as-Patient 的声望及手术结果规则。
2. **禁止**在不一致的情况下播放任何声称“仍与最初邀约／术前同意完全一致”“没有改变术式”“切除范围还是说好的那一块”的玩家按钮或患者回应。这一条对通用原文和小夜香覆盖均生效。
3. 以下**11 个池必须加“实际术式与邀约术式一致才允许命中”的播放限制**：

   - 术式专属 6 池：`hysterectomy_signature_01`、`ovarian_cystectomy_signature_01`、`myomectomy_signature_01`、`breast_tumor_signature_01`、`mastectomy_signature_01`、`cabg_signature_01`；
   - 手术分组 5 池：`pelvic_dignity_exposure_01`、`pelvic_dignity_default_01`、`breast_dignity_exposure_01`、`breast_dignity_default_01`、`breast_closure_fear_01`。

   其中部分池是**通用回退池**；过滤必须发生在 Runner 选池之前，不能只过滤我们 V1.4 的个性化文字。尤其 `hysterectomy_signature_01` 的 `confirm_hysterectomy_scope` 按钮本身会承诺“与术前同意一致”，在术式不匹配时绝不能出现。
4. 不一致场景仍可以调用**实际可用、且不会声称原约定未变的其他通用／专属互动池**。选不到安全的池，就**跳过这一次额外术中问答**，让原手术阶段继续；**不新建玩家按钮、不复用别的部位的专属台词**。
5. 一般按钮里的“当前阶段仍按计划进行”只可指**手术室此时正在执行的实际步骤**，不得用来断言原邀约与实际操作相同；任何更多的“与术前同意相同”承诺须依据两份术式 ID 检查。
6. **本节是实装的 P0 阻断项。** 单凭现有两个 JSON 无法证明过滤能力已经存在。Codex 必须提供匹配代码位置和模拟测试：邀约 `surgery_breast_tumor`，实际 `surgery_hysterectomy` 时，上述不合法池及选项不再出现，但 `procedure_mismatch` 仍能显示。

#### C2-ANATOMY. 通用池不要写死术野部位（V1.4 新增）

- `strain_default_01`：新稿提示改为“不指定腹部的牵拉感”，保留全分组通用资格。
- `urologic_strain_pressure_01`：新稿提示改为“深部压力和牵拉”，可适用于肾脏／肾上腺侧与膀胱相关术式，不把每次泌尿手术写成侧腹操作。
- `strain_pain_traction_02`：小夜香的对应回应已去掉“松开腹部”。**但原 Runner 的按钮 label 仍写着“提示她放松腹部并缓慢呼气”**，这是原数据的问题，本文件改 patient response 不足以修复。建议 Codex 在不改 `action_id`、`minutes`、`effects` 的前提下，将该按钮中文改为「引导她缓慢呼气并放松紧绷的部位」（英文若有相应 UI 一并对应）。若不允许改按钮文案，则必须将该 pool 限定在确实适用的腹部术式。**在二者择一落实前，不能算这一池跨术式验收通过。**
- 医学部位特写仍允许出现在**已有 `procedure_groups`／`surgery_ids` 明确限定**的专属池中，例如 `abdominal_strain_pain_01`。

#### 覆盖总表（全部 50 个）

**`operative_contact`**

| 真实 `pool_id` | 覆盖状态 | 实际 `action_id`（数量） |
|---|---|---|
| `contact_pain_incision_01` | **专属 CN+EN** | `explain_contact`, `brief_contact`, `continue_contact` (3) |
| `contact_no_anesthesia_incision_01` | **专属 CN+EN**；备选 `v2` 暂存 | `steady_unanesthetized_contact_01`, `continue_unanesthetized_contact_01` (2) |
| `contact_no_anesthesia_incision_02` | **专属 CN+EN** | `steady_unanesthetized_contact_02`, `continue_unanesthetized_contact_02` (2) |
| `contact_no_anesthesia_incision_03` | **专属 CN+EN**；备选 `v2` 暂存 | `steady_unanesthetized_contact_03`, `continue_unanesthetized_contact_03` (2) |
| `contact_default_01` | **专属 CN+EN** | `reassure_start`, `brief_start`, `silent_start` (3) |
| `contact_pain_incision_02` | **专属 CN+EN** | `acknowledge_second_contact`, `brief_second_contact` (2) |
| `contact_fear_incision_01` | **专属 CN+EN** | `orient_fearful_contact`, `steady_fearful_contact`, `dismiss_fearful_contact` (3) |

**`progress_check`**

| 真实 `pool_id` | 覆盖状态 | 实际 `action_id`（数量） |
|---|---|---|
| `progress_fear_default_01` | **专属 CN+EN** | `explain_progress`, `brief_progress`, `dismiss_progress` (3) |
| `progress_default_01` | **专属 CN+EN** | `answer_progress`, `brief_answer_progress` (2) |
| `cardiac_progress_fear_01` | **专属 CN+EN** | `explain_cardiac_progress`, `brief_cardiac_progress` (2) |
| `cardiac_progress_default_01` | **通用池回退（不覆盖）** | `answer_cardiac_progress`, `brief_cardiac_answer` (2) |
| `progress_fear_fatigue_01` | **专属 CN+EN** | `explain_fatigue_progress`, `brief_fatigue_progress` (2) |
| `progress_fear_fatigue_02` | **通用池回退（不覆盖）** | `mark_fatigue_milestone`, `encourage_fatigue_progress` (2) |
| `thoracic_progress_fatigue_01` | **通用池回退（不覆盖）** | `explain_thoracic_progress`, `brief_thoracic_progress` (2) |
| `vascular_progress_deep_01` | **通用池回退（不覆盖）** | `explain_vascular_milestone`, `brief_vascular_milestone` (2) |
| `cabg_signature_01` | **专属 CN+EN** | `explain_cabg_milestone`, `brief_cabg_milestone` (2) |

**`strain_interaction`**

| 真实 `pool_id` | 覆盖状态 | 实际 `action_id`（数量） |
|---|---|---|
| `strain_pain_default_01` | **专属 CN+EN**；备选 `v2` 暂存 | `pause_strain`, `coach_strain`, `push_through_strain` (3) |
| `strain_default_01` | **专属 CN+EN** | `explain_strain`, `brief_strain` (2) |
| `abdominal_strain_pain_01` | **专属 CN+EN** | `explain_abdominal_strain`, `coach_abdominal_strain` (2) |
| `strain_pain_traction_02` | **专属 CN+EN** | `pause_second_traction`, `coach_second_traction` (2) |
| `strain_pain_pressure_01` | **专属 CN+EN** | `relieve_pressure`, `explain_pressure` (2) |
| `urologic_strain_pressure_01` | **专属 CN+EN** | `pause_urologic_strain`, `explain_urologic_strain` (2) |

**`dignity_interaction`**

| 真实 `pool_id` | 覆盖状态 | 实际 `action_id`（数量） |
|---|---|---|
| `dignity_low_exposure_01` | **专属 CN+EN**；备选 `v2` 暂存 | `restore_cover`, `explain_exposure`, `ignore_exposure` (3) |
| `dignity_default_01` | **专属 CN+EN** | `protect_dignity`, `brief_dignity` (2) |
| `pelvic_dignity_exposure_01` | **专属 CN+EN** | `explain_pelvic_stage`, `brief_pelvic_stage` (2) |
| `pelvic_dignity_default_01` | **通用池回退（不覆盖）** | `answer_pelvic_progress`, `brief_pelvic_progress` (2) |
| `breast_dignity_exposure_01` | **专属 CN+EN** | `confirm_breast_scope`, `brief_breast_scope` (2) |
| `breast_dignity_default_01` | **通用池回退（不覆盖）** | `answer_breast_stage`, `brief_breast_stage` (2) |
| `dignity_low_exposure_02` | **通用池回退（不覆盖）** | `reduce_exposure_again`, `acknowledge_exposure_again` (2) |
| `dignity_cooperation_exposure_01` | **专属 CN+EN** | `limit_observers`, `brief_privacy_confirmation` (2) |
| `hysterectomy_signature_01` | **专属 CN+EN**；备选 `v2` 暂存 | `confirm_hysterectomy_scope`, `brief_hysterectomy_scope` (2) |
| `ovarian_cystectomy_signature_01` | **专属 CN+EN** | `confirm_ovarian_preservation`, `brief_ovarian_preservation` (2) |
| `myomectomy_signature_01` | **专属 CN+EN** | `confirm_myomectomy_scope`, `brief_myomectomy_scope` (2) |
| `breast_tumor_signature_01` | **专属 CN+EN** | `confirm_breast_tumor_scope`, `brief_breast_tumor_scope` (2) |
| `mastectomy_signature_01` | **专属 CN+EN**；备选 `v2` 暂存 | `acknowledge_mastectomy_loss`, `confirm_mastectomy_plan` (2) |

**`ongoing_interaction`**

| 真实 `pool_id` | 覆盖状态 | 实际 `action_id`（数量） |
|---|---|---|
| `ongoing_fear_default_01` | **专属 CN+EN** | `reassure_ongoing`, `brief_ongoing` (2) |
| `ongoing_default_01` | **专属 CN+EN** | `coach_ongoing`, `reassure_ongoing_default` (2) |
| `ongoing_fear_fatigue_01` | **专属 CN+EN** | `maintain_running_update`, `brief_running_update` (2) |
| `ongoing_fear_fatigue_02` | **通用池回退（不覆盖）** | `preview_next_milestone`, `encourage_next_milestone` (2) |
| `ongoing_pain_position_01` | **专属 CN+EN** | `adjust_pressure_points`, `coach_position_stillness` (2) |
| `abdominal_ongoing_pressure_01` | **专属 CN+EN** | `explain_abdominal_pressure`, `brief_abdominal_pressure` (2) |
| `pelvic_ongoing_position_01` | **专属 CN+EN** | `support_pelvic_position`, `coach_pelvic_position` (2) |
| `thoracic_ongoing_position_01` | **通用池回退（不覆盖）** | `check_thoracic_support`, `coach_thoracic_stillness` (2) |
| `cardiac_ongoing_fatigue_01` | **专属 CN+EN** | `reassure_cardiac_ongoing`, `brief_cardiac_ongoing` (2) |
| `vascular_ongoing_pressure_01` | **通用池回退（不覆盖）** | `separate_vascular_sensations`, `brief_vascular_pressure` (2) |

**`closure_interaction`**

| 真实 `pool_id` | 覆盖状态 | 实际 `action_id`（数量） |
|---|---|---|
| `closure_default_01` | **专属 CN+EN** | `confirm_closure`, `brief_closure` (2) |
| `closure_fear_closure_01` | **专属 CN+EN** | `confirm_closure_phase`, `brief_closure_phase` (2) |
| `closure_fear_closure_02` | **通用池回退（不覆盖）** | `explain_final_checks`, `confirm_final_checks` (2) |
| `closure_pain_closure_01` | **专属 CN+EN** | `pause_closure_discomfort`, `pace_closure_breathing` (2) |
| `breast_closure_fear_01` | **专属 CN+EN** | `answer_breast_closure`, `brief_breast_closure` (2) |

#### C2 正文：逐池问答与按钮映射

##### Theme: `operative_contact`

**`contact_pain_incision_01`** — 专属覆盖；原数据主题 `operative_contact`；`states`: `pain`；`cues`: `incision`；`excluded_flags`: `no_anesthesia_confirmed`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……嘶，刀口那一下我还是感觉到了。坂口，真的已经开始了呀？我明明知道流程，怎么心跳得这么快……
- **Prompt EN / Sayaka:** ...Ah, I felt that at the incision. Sakaguchi, we've really started, haven't we? I know the procedure, so why is my heart racing like this...?

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `explain_contact` | 说明手术已经开始并提醒她保持呼吸 | 嗯，我听着。照你说的慢慢呼吸就好，对吧？……今天换我被医生叮嘱了呢。 | Mm, I'm listening. Slow breaths, just like you said, right? ...So today I'm the one being coached by the doctor. |
| `brief_contact` | 简短告诉她一切按计划进行 | 知道啦，按计划进行……我会不乱动的。只是这一下，比我想象中真实多了。 | I know, we're following the plan... I'll stay still. It's just much more real than I imagined. |
| `continue_contact` | 要求她继续配合 | ……好，我配合。可是你别把我当成平时那个能若无其事看手术的南条医生呀。 | ...All right, I'll cooperate. Just don't expect me to act like the Dr. Nanjou who can watch an operation without batting an eye. |

**`contact_no_anesthesia_incision_01`** — 专属覆盖；原数据主题 `operative_contact`；`cues`: `incision`；`required_flags`: `no_anesthesia_confirmed`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 啊——！等、等一下，坂口！我知道第一刀会疼，可它怎么能疼得这么明明白白呀……！
- **Prompt EN / Sayaka:** Aah! W-wait, Sakaguchi! I knew the first incision would hurt, but why does it have to feel so horribly sharp and real...?!

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `steady_unanesthetized_contact_01` | 回应她，放慢动作并引导呼吸 | 呼……我在听，你慢一点就好。我现在可没本事装勇敢，先让我把这口气喘回来…… | Hah... I'm listening. Just go a little slower. I can't pretend to be brave right now; let me catch my breath... |
| `continue_unanesthetized_contact_01` | 要求她忍耐并继续手术 | 你说忍就忍呀……呜！好，我知道还要继续，可你别嫌我叫得难听！ | You make it sound so easy to endure... Ngh! I know we have to keep going, but don't complain about how loudly I scream! |

**v2 （完整第二套候选，仅后备；待 Codex 确认整池变体支持）**

- **Prompt CN / 南条小夜香：** 呀啊！……我、我刚才是不是叫得整个手术室都听见了？别回答！现在先让我喘气……
- **Prompt EN / Sayaka:** Aaah! ...D-did everyone in the OR hear me scream? Don't answer! Just let me breathe first...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `steady_unanesthetized_contact_01` | 回应她，放慢动作并引导呼吸 | 谢谢……你说慢一点，我就努力跟上。可你要知道，我现在真的很怕下一刀哦。 | Thank you... If you go slower, I'll try to keep up. But I really am frightened of the next cut. |
| `continue_unanesthetized_contact_01` | 要求她忍耐并继续手术 | 啊……你真是一点也不打算哄我呀！知道啦，我尽量不乱动……呜！ | Ah... You're really not going to sweet-talk me through this, are you? Fine, I'll try not to move... Ngh! |

**`contact_no_anesthesia_incision_02`** — 专属覆盖；原数据主题 `operative_contact`；`cues`: `incision`；`required_flags`: `no_anesthesia_confirmed`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 不、不是……怎么又往里面去了？！刚才那一下我都还没缓过来呀！
- **Prompt EN / Sayaka:** N-no... Are you going deeper already?! I haven't even recovered from that last part!

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `steady_unanesthetized_contact_02` | 短暂停手，确认她仍能配合 | 呼……先停一下就好。等我不再发抖了，你再告诉我下一步，好不好？ | Hah... Just a moment's pause helps. Once I've stopped shaking, tell me what comes next, okay? |
| `continue_unanesthetized_contact_02` | 继续当前操作 | 呀啊——！喂，坂口！你们说继续倒是轻松，我可是躺在这里挨着呢！ | Aaah! Hey, Sakaguchi! It's easy for you to say 'keep going' when I'm the one lying here feeling every bit of it! |

**`contact_no_anesthesia_incision_03`** — 专属覆盖；原数据主题 `operative_contact`；`cues`: `incision`；`required_flags`: `no_anesthesia_confirmed`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 坂口……呜，我知道当初自己说不用麻药，可现在真的疼得受不了啦。就一点点也不行吗……？
- **Prompt EN / Sayaka:** Sakaguchi... Ngh, I know I was the one who said no anesthesia, but it hurts so much now. Not even a little...?

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `steady_unanesthetized_contact_03` | 明确拒绝追加麻醉，让团队放慢动作 | ……不给呀。好，我听明白了……那你至少慢一点，让我知道你下一下要做什么，好不好？ | ...No? All right, I understand... Then at least go slowly and tell me what you're about to do next, okay? |
| `continue_unanesthetized_contact_03` | 明确拒绝追加麻醉并继续手术 | 呜……连缓一下都不行吗……！我知道你们要做完，可是我真的疼得想哭呀！ | Ngh... Not even a moment to recover...?! I know you have to finish, but it hurts so much I could cry! |

**v2 （完整第二套候选，仅后备；待 Codex 确认整池变体支持）**

- **Prompt CN / 南条小夜香：** 呜……坂口，拜托啦，我知道手术计划没变，可我现在真的有点后悔当初逞强了……
- **Prompt EN / Sayaka:** Ngh... Sakaguchi, please. I know the surgical plan hasn't changed, but right now I'm really regretting how tough I tried to act...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `steady_unanesthetized_contact_03` | 明确拒绝追加麻醉，让团队放慢动作 | ……明白。那你就照你说的慢一点吧。我只求你别突然又来一下…… | ...I understand. Then please slow down like you said. I'm just begging you not to spring the next part on me... |
| `continue_unanesthetized_contact_03` | 明确拒绝追加麻醉并继续手术 | 等……啊！……我今天真是把自己害惨了。坂口，你回头得让我骂个够！ | Wai—ah! ...I've really gotten myself into a mess today. Sakaguchi, you'd better let me complain as much as I want afterward! |

**`contact_default_01`** — 专属覆盖；原数据主题 `operative_contact`；`excluded_flags`: `no_anesthesia_confirmed`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……欸？已经开始了？你们动作那么熟练，我差点没察觉呢。可别因为我也是医生，就省了告诉我的那一句呀。
- **Prompt EN / Sayaka:** ...Huh? We've started already? You're all so practiced I almost missed it. Just because I'm a doctor too doesn't mean you can skip telling me.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `reassure_start` | 确认已经开始并说明情况稳定 | 嗯，那我就放心一点了。今天的患者可是我，你记得随时说一声哦。 | Mm, that's reassuring. I'm your patient today, so remember to keep me informed. |
| `brief_start` | 简短确认已经开始 | 好，知道了……唉，明明已经经历过，自己躺在台上听见“已经开始”，还是会紧张呀。 | All right, got it... Sigh. Even though I’ve been through this before, hearing “we’ve started” while I’m on the table still makes me nervous. |
| `silent_start` | 让她安静配合 | ……好啦，我安静。我可是很会配合的……至少我会努力。 | ...All right, I'll be quiet. I'm very good at cooperating... Or at least I'll try. |

**`contact_pain_incision_02`** — 专属覆盖；原数据主题 `operative_contact`；`states`: `pain`；`cues`: `incision`；`excluded_flags`: `no_anesthesia_confirmed`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 嘶……我现在能很清楚地感觉到刀口。坂口，你有听见我说话吧？今天我可没力气一直装镇定哦。
- **Prompt EN / Sayaka:** Ah... I can feel the incision so clearly now. Sakaguchi, you can hear me, right? I haven't got the energy to keep pretending I'm calm today.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `acknowledge_second_contact` | 回应她并确认目前仍按计划进行 | 嗯，听见你回答我就安心一点。你继续说话好不好？不用很多，偶尔一句就行。 | Mm, hearing you answer helps. Can you keep talking to me? It doesn't have to be much. Just a word now and then. |
| `brief_second_contact` | 简短确认后继续 | 好，你还在……呼，那我就再坚持一下。 | Okay, you're still there... Hah. Then I'll hang on a little longer. |

**`contact_fear_incision_01`** — 专属覆盖；原数据主题 `operative_contact`；`states`: `fear`；`cues`: `incision`；`excluded_flags`: `no_anesthesia_confirmed`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……已经真的切开了吗？我看不见你们的手，反而更容易乱想。坂口，别笑我，明明平时开刀我一点都不怕呀。
- **Prompt EN / Sayaka:** ...Have you really made the incision? Not being able to see your hands makes me imagine all kinds of things. Don't laugh, Sakaguchi. I'm never frightened when I'm the one operating.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `orient_fearful_contact` | 告诉她刚刚完成了哪一步 | 啊，才做到那里呀……明白了。下一步也跟我说一声，好不好？ | Oh, so that's as far as you've gone... I understand. Tell me when you're about to do the next step too, okay? |
| `steady_fearful_contact` | 让她听着你的声音保持呼吸 | 嗯……我听你的声音。慢慢吸气……好，至少现在我知道你没有丢下我。 | Mm... I'm listening to your voice. Breathe in slowly... Okay, at least I know you haven't left me alone. |
| `dismiss_fearful_contact` | 要求她不要继续追问 | ……好啦，我不再问。可我就是害怕嘛，等会儿不小心叫出来也别骂我。 | ...All right, I won't ask again. But I am scared, and don't scold me if I end up crying out. |


##### Theme: `progress_check`

**`progress_fear_default_01`** — 专属覆盖；原数据主题 `progress_check`；`states`: `fear`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 坂口，你们突然说得那么小声……是有什么地方不对吗？我知道自己不该胡思乱想，可现在只能躺着等你们呀。
- **Prompt EN / Sayaka:** Sakaguchi, your voices just got so quiet... Is something wrong? I know I shouldn't jump to conclusions, but all I can do is lie here and wait.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `explain_progress` | 说明当前进度仍符合计划 | 哦……原来还是计划中的步骤。谢谢你认真解释，不然我这脑袋早就把最坏的结果想完一遍了。 | Oh... so it's still a planned step. Thanks for explaining. Otherwise I'd have imagined every worst-case scenario by now. |
| `brief_progress` | 告诉她手术仍在继续 | 嗯，至少还在按计划走……我知道了。下次别突然都不说话嘛。 | Mm, so we're still on track... I understand. Just don't all go silent on me like that next time. |
| `dismiss_progress` | 要求她不要分心 | ……好，我不打扰你。可是我现在真的害怕，别把我这句话当成废话呀。 | ...All right, I won't distract you. But I really am frightened. Please don't treat that as a pointless complaint. |

**`progress_default_01`** — 专属覆盖；原数据主题 `progress_check`；无指定附加过滤字段。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 坂口，现在到底进行到哪里啦？我越想用医生的脑袋推断，越发现躺在这里根本没有时间概念呀。
- **Prompt EN / Sayaka:** Sakaguchi, how far along are we? The harder I try to work it out like a doctor, the more I realize I have no sense of time down here.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `answer_progress` | 向她说明当前阶段 | 哦，原来这一段已经完成了呀。呼……听见具体进度，我突然觉得有盼头了。 | Oh, so that part's finished. Hah... Hearing an actual update suddenly gives me something to look forward to. |
| `brief_answer_progress` | 告诉她仍按计划进行 | 好，按计划来。我相信你啦……不过可别让我盯着无影灯一直猜下去哦。 | Okay, stay with the plan. I trust you... Just don't leave me staring at the surgical lights and guessing forever. |

**`cardiac_progress_fear_01`** — 专属覆盖；原数据主题 `progress_check`；`states`: `fear`；`cues`: `fatigue`；`procedure_groups`: `cardiac`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……你们是不是已经做到心脏了？大家越安静我越紧张，明明平时我最喜欢手术室安安静静的呀。
- **Prompt EN / Sayaka:** ...Are you working on my heart already? The quieter everyone gets, the more nervous I feel—and I usually love a quiet OR.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `explain_cardiac_progress` | 说明当前进度并确认团队仍按计划操作 | 嗯，还是预定的阶段……好。拜托你偶尔跟我说一句，别让我自己猜每一个器械声。 | Mm, still the planned stage... Good. Just say something now and then, please, so I don't have to interpret every sound myself. |
| `brief_cardiac_progress` | 确认仍按计划进行 | ……知道了。我尽量不打扰，你们也不要突然都不理我嘛。 | ...Understood. I'll try not to distract anyone. Just don't all forget I'm here, okay? |

**`cardiac_progress_default_01`** — 通用池回退；原数据主题 `progress_check`；`procedure_groups`: `cardiac`。

**本版不覆盖本池提示及回应。** 保留原始 `patient_interactions.json` 中的全部默认患者 `prompt` 和 `actions[].response`，不增删按钮，也不将其他池的小夜香对白误套进来。

真实按钮：`answer_cardiac_progress`（说明当前手术阶段）；`brief_cardiac_answer`（确认手术仍按计划进行）。

**`progress_fear_fatigue_01`** — 专属覆盖；原数据主题 `progress_check`；`states`: `fear`；`cues`: `fatigue`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……怎么还没结束呀？我现在连你们什么时候换器械都懒得猜了……是不是比计划难了很多？
- **Prompt EN / Sayaka:** ...Why isn't it over yet? I'm too tired even to guess when you change instruments... Has it become much harder than planned?

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `explain_fatigue_progress` | 说明目前阶段和剩余进度 | 哦，原来是这个阶段……不是出了事就好。呼，我现在特别希望你们别为了赶时间省步骤。 | Oh, so that's the stage... As long as nothing went wrong. Hah, I really don't want you skipping steps just to save time. |
| `brief_fatigue_progress` | 确认手术仍按计划进行 | 还在计划里呀……好，我信你。可是等我下来，你可得让我抱怨今天到底躺了多久。 | Still on plan... okay, I trust you. But once I'm off the table, you have to let me complain about how long I've been lying here. |

**`progress_fear_fatigue_02`** — 通用池回退；原数据主题 `progress_check`；`states`: `fear`；`cues`: `fatigue`。

**本版不覆盖本池提示及回应。** 保留原始 `patient_interactions.json` 中的全部默认患者 `prompt` 和 `actions[].response`，不增删按钮，也不将其他池的小夜香对白误套进来。

真实按钮：`mark_fatigue_milestone`（给她一个清楚的阶段标记）；`encourage_fatigue_progress`（告诉她已经完成了重要部分）。

**`thoracic_progress_fatigue_01`** — 通用池回退；原数据主题 `progress_check`；`cues`: `fatigue`；`procedure_groups`: `thoracic`。

**本版不覆盖本池提示及回应。** 保留原始 `patient_interactions.json` 中的全部默认患者 `prompt` 和 `actions[].response`，不增删按钮，也不将其他池的小夜香对白误套进来。

真实按钮：`explain_thoracic_progress`（说明胸腔手术目前所处阶段）；`brief_thoracic_progress`（确认关键阶段正按计划推进）。

**`vascular_progress_deep_01`** — 通用池回退；原数据主题 `progress_check`；`cues`: `deep_manipulation`, `fatigue`；`procedure_groups`: `vascular`。

**本版不覆盖本池提示及回应。** 保留原始 `patient_interactions.json` 中的全部默认患者 `prompt` 和 `actions[].response`，不增删按钮，也不将其他池的小夜香对白误套进来。

真实按钮：`explain_vascular_milestone`（说明已进入计划中的关键阶段）；`brief_vascular_milestone`（确认当前变化符合预期）。

**`cabg_signature_01`** — 专属覆盖；原数据主题 `progress_check`；`cues`: `fatigue`；`surgery_ids`: `surgery_cabg`；`once_per_surgery=true`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……刚才我听见“吻合”了。坂口，你们真的是在替我的心脏建立新的血流通路呀……听起来还是好不可思议。
- **Prompt EN / Sayaka:** ...I just heard 'anastomosis.' Sakaguchi, you're really making a new route for blood to reach my heart... It still sounds unbelievable.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `explain_cabg_milestone` | 用简短语言说明已进入计划中的重建阶段 | 嗯，是术前说的那一步……好。你讲得越清楚，我就越能忍住不胡思乱想。 | Mm, that's the step you described before surgery... okay. The clearer you explain it, the easier it is not to imagine the worst. |
| `brief_cabg_milestone` | 确认正在完成预定的关键步骤 | ……明白了。我信你们……只是这次真的比我想象中吓人耶。 | ...Understood. I trust you all... This is just far more frightening than I imagined. |


##### Theme: `strain_interaction`

**`strain_pain_default_01`** — 专属覆盖；原数据主题 `strain_interaction`；`states`: `pain`；`cues`: `traction`, `deep_manipulation`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 呜……等一下！里面刚才像被狠狠拽住了一下……我明明知道牵拉会难受，可轮到自己怎么完全不是一回事呀！
- **Prompt EN / Sayaka:** Ngh... wait! Something inside felt like it was pulled hard just now... I know traction can feel awful, but experiencing it myself is another matter entirely!

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `pause_strain` | 暂停片刻并说明刚才的感觉 | 呼……谢谢，先让我缓这一下。以前觉得停两分钟会拖慢进度，现在我终于懂患者为什么会求这两分钟了…… | Hah... thank you, let me recover from that. I used to think a two-minute pause would slow us down. Now I understand why patients beg for those two minutes... |
| `coach_strain` | 引导她呼吸并继续 | 好……吸气，慢慢呼气……我在努力啦，可身体不肯像脑袋那么听话呀。 | Okay... in, then breathe out slowly... I'm trying, but my body isn't nearly as obedient as my brain. |
| `push_through_strain` | 要求她坚持 | ……知道了，我会尽量不动……可是等我下台以后，你得听我抱怨这一段有多难受！ | ...I know. I'll try not to move... But when I'm off this table, you're going to hear exactly how miserable that was! |

**v2 （完整第二套候选，仅后备；待 Codex 确认整池变体支持）**

- **Prompt CN / 南条小夜香：** 啊……坂口！你先告诉我，这样被扯住的感觉还要持续多久？我有点撑不住啦……
- **Prompt EN / Sayaka:** Ah... Sakaguchi! Tell me how long that pulling feeling is going to last. I'm having trouble holding on...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `pause_strain` | 暂停片刻并说明刚才的感觉 | ……好些了。你别笑，我刚才连自己是不是在发抖都控制不住了。 | ...That's better. Don't laugh—I couldn't even control how much I was shaking just now. |
| `coach_strain` | 引导她呼吸并继续 | 我听着，我跟着你的声音呼吸……求你，这一段再慢一点嘛。 | I'm listening. I'll breathe with your voice... Please, just a little more slowly through this part. |
| `push_through_strain` | 要求她坚持 | 呜……你还真严格呀。好啦，我继续忍，可你别问我现在还漂不漂亮…… | Ngh... you're really strict. Fine, I'll keep enduring it, but don't ask me whether I still look pretty right now... |

**`strain_default_01`** — 专属覆盖；原数据主题 `strain_interaction`；`once_per_surgery=true`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……刚才有个地方被往旁边牵了一下，对吧？明明知道你们在调整术野，自己感受起来却陌生得吓人耶。
- **Prompt EN / Sayaka:** ...Something just tugged to the side, didn’t it? I know you’re adjusting the surgical field, but feeling it myself is frighteningly unfamiliar.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `explain_strain` | 解释这是当前步骤带来的牵拉感 | 啊，是这个步骤呀。懂了……我现在终于知道，为什么患者总想问一句“这正常吗”。 | Ah, so that's the step. Got it... Now I understand why patients always want to ask whether this is normal. |
| `brief_strain` | 告诉她感觉会很快过去 | 嗯……一会儿就过去？那我先信你一次，坂口医生。 | Mm... It'll pass soon? I'll take your word for it this time, Dr. Sakaguchi. |

**`abdominal_strain_pain_01`** — 专属覆盖；原数据主题 `strain_interaction`；`states`: `pain`；`cues`: `traction`, `deep_manipulation`；`procedure_groups`: `general_abdominal`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 呀……我的肚子里面又被牵住了。你现在是在处理哪一层呀？我以前听患者这么说，还真不懂她们怎么会这么难受。
- **Prompt EN / Sayaka:** Ah... there's that pulling inside my abdomen again. Which layer are you working on? I used to hear patients say this and never quite understand how awful it felt.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `explain_abdominal_strain` | 说明正在完成腹腔内的当前步骤 | 哦，是那一步……知道原因是会安心一点，可你得让我的身体也配合才行呀，坂口。 | Oh, that step... Knowing why does help, but you've still got to get my body to cooperate too, Sakaguchi. |
| `coach_abdominal_strain` | 让她慢慢呼吸并坚持片刻 | 呼……慢慢呼气，对吧？好，我忍一下……哎呀，肚子可一点也不听话。 | Hah... breathe out slowly, right? Okay, I'll hold on... My abdomen really isn't listening to me. |

**`strain_pain_traction_02`** — 专属覆盖；原数据主题 `strain_interaction`；`states`: `pain`；`cues`: `traction`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 呜……里面又拉了一下！这次更深……坂口，我现在光听你们说“牵开”都要发抖了啦。
- **Prompt EN / Sayaka:** Ngh... that pulling again! Deeper this time... Sakaguchi, now even hearing someone say 'retractor' makes me shiver.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `pause_second_traction` | 暂缓牵拉，让她重新放松 | 呼……好多了。等我缓一口气再继续好吗？我保证不会赖太久。 | Hah... much better. Can we continue once I've caught my breath? I promise I won't keep you waiting long. |
| `coach_second_traction` | 提示她放松腹部并缓慢呼气 | 嗯……慢慢呼气，尽量别绷得那么紧……我在试。讨厌，身体怎么就不能听我一次话呢？ | Mm... breathe out slowly, try not to tense up so much... I’m trying. Ugh, why can’t my body listen to me for once? |

**`strain_pain_pressure_01`** — 专属覆盖；原数据主题 `strain_interaction`；`states`: `pain`；`cues`: `pressure`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……这里一直被压着，越来越难受。不是一下疼完就算了……坂口，你们平时都觉得这点压力不算什么吗？
- **Prompt EN / Sayaka:** ...There's constant pressure here, and it's getting worse. It isn't one quick sting and then done... Sakaguchi, do you all usually think this kind of pressure is nothing?

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `relieve_pressure` | 暂停并重新调整持续压力 | 啊……轻一点了！谢谢……我刚才差点以为要一直这么压到最后呢。 | Ah... that's lighter! Thank you... I was starting to think I'd be pressed like that until the very end. |
| `explain_pressure` | 说明这段压力感还会持续片刻 | 嗯，要持续一会儿呀……知道原因倒是安心点，可也真是磨人耶。 | Mm, so it'll last a little longer... Knowing why helps, but it really wears you down. |

**`urologic_strain_pressure_01`** — 专属覆盖；原数据主题 `strain_interaction`；`cues`: `pressure`, `deep_manipulation`；`procedure_groups`: `urologic`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……里面又胀又被牵着。坂口，你们在做哪一步呀？我知道这是泌尿系统的手术，可这种感觉还真难描述……
- **Prompt EN / Sayaka:** ...There’s this deep pressure and pulling sensation. Sakaguchi, which step are you on? I know this is a urologic procedure, but it’s hard to describe what it feels like...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `pause_urologic_strain` | 暂停片刻并让她调整呼吸 | 呼……谢谢。先让我喘一下，回头我再好好研究这台手术，现在脑袋完全想不动呀。 | Hah... thank you. Let me breathe a moment. I'll study this operation properly afterward; right now I can't think straight at all. |
| `explain_urologic_strain` | 说明深部牵拉感来自当前阶段 | 哦，是预定的深部操作呀……好。下次要牵的时候，先告诉我一声，好不好？ | Oh, it's the planned deep work... okay. Next time you need to pull, tell me first, all right? |


##### Theme: `dignity_interaction`

**`dignity_low_exposure_01`** — 专属覆盖；原数据主题 `dignity_interaction`；`states`: `dignity`；`cues`: `exposure`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……我知道这是必要的术野啦。可是天天见面的同事都围在这里，我连抬眼看你们都觉得害羞……
- **Prompt EN / Sayaka:** ...I know this is the necessary surgical field. But with colleagues I see every day gathered around, I'm too embarrassed even to look up at you...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `restore_cover` | 确认只保留必要术野并重新遮盖 | 啊，谢谢……只留必须露出来的地方就好。这样我才敢好好喘一口气呀。 | Ah, thank you... Just leave what actually needs to be exposed. Now I can finally take a proper breath. |
| `explain_exposure` | 解释当前暴露范围的必要性 | 嗯，道理我都懂。可每次真轮到我躺在这里，还是觉得这样一直暴露着很难熬嘛。 | Mm, I understand why it’s necessary. But every time I’m the one lying here, being exposed for so long still feels terribly uncomfortable. |
| `ignore_exposure` | 要求她不要在意 | ……你说不要在意？喂，我可不是在给你们找麻烦呀！我今天真的很难为情嘛。 | ...You say not to mind? Hey, I'm not trying to make trouble for anyone! I'm genuinely embarrassed today. |

**v2 （完整第二套候选，仅后备；待 Codex 确认整池变体支持）**

- **Prompt CN / 南条小夜香：** ……讨厌，我以前最会笑着安慰患者“大家都是专业人员”。轮到我，怎么突然一句都说不出口了……
- **Prompt EN / Sayaka:** ...Ugh. I used to be so good at smiling and telling patients, 'We're all professionals.' Now it's my turn and I can't even get the words out...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `restore_cover` | 确认只保留必要术野并重新遮盖 | 呼，舒服多了……不是身体上的，是心里。谢谢你没笑我小题大做。 | Hah, that's so much better... Not physically, but in my head. Thanks for not laughing at me for making a fuss. |
| `explain_exposure` | 解释当前暴露范围的必要性 | 知道啦，我听见了。可你也让我小小抱怨一下嘛，不然憋着更难受。 | I know, I heard you. But let me complain a little, okay? Holding it all in feels worse. |
| `ignore_exposure` | 要求她不要在意 | ……好吧，我安静。只是你们回头谁也不准拿今天这副样子笑我哦。 | ...All right, I'll be quiet. But none of you are allowed to tease me about how I looked today afterward. |

**`dignity_default_01`** — 专属覆盖；原数据主题 `dignity_interaction`；无指定附加过滤字段。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……这块是不是还得一直露着呀？我知道你们只看手术部位，可被大家盯着的感觉还是好别扭。
- **Prompt EN / Sayaka:** ...Does this area still have to stay exposed? I know you're only looking at the operative site, but being watched like this feels so awkward.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `protect_dignity` | 确认遮盖并说明只暴露必要区域 | 哦，谢谢！呵呵，明明只是替我盖好一点，我居然会这么感动。 | Oh, thank you! Hehe, I can't believe I'm this touched by someone covering me properly. |
| `brief_dignity` | 说明当前步骤很快结束 | 嗯，很快就好呀？那我再忍一会儿，不过真希望你们说的“很快”别跟术前准备一样长…… | Mm, it'll be over soon? I'll bear it a little longer, but I hope 'soon' doesn't mean as long as pre-op preparation did... |

**`pelvic_dignity_exposure_01`** — 专属覆盖；原数据主题 `dignity_interaction`；`states`: `dignity`；`cues`: `exposure`, `deep_manipulation`；`procedure_groups`: `female_pelvic`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……已经在盆腔里操作了呀？我知道体位和铺巾都按规定，可被熟悉的同事这样围着，还是好丢脸……
- **Prompt EN / Sayaka:** ...You're working in my pelvis now? I know the positioning and draping are according to protocol, but being surrounded like this by people I know is mortifying...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `explain_pelvic_stage` | 说明当前阶段并确认保护非必要暴露 | 嗯，范围没变就好。你们只留必须看的地方，好不好？我现在真的比想象中害羞多了。 | Mm, as long as the scope hasn't changed. Please expose only what's necessary, okay? I'm much more self-conscious than I expected. |
| `brief_pelvic_stage` | 确认正在按术前计划进行 | 知道了……按计划来。只要别让我自己猜下一步在做什么，我就能多忍一会儿。 | Understood... Keep to the plan. As long as I don't have to guess what happens next, I can hold on a little longer. |

**`pelvic_dignity_default_01`** — 通用池回退；原数据主题 `dignity_interaction`；`procedure_groups`: `female_pelvic`。

**本版不覆盖本池提示及回应。** 保留原始 `patient_interactions.json` 中的全部默认患者 `prompt` 和 `actions[].response`，不增删按钮，也不将其他池的小夜香对白误套进来。

真实按钮：`answer_pelvic_progress`（说明当前步骤和术前计划一致）；`brief_pelvic_progress`（确认手术仍按计划进行）。

**`breast_dignity_exposure_01`** — 专属覆盖；原数据主题 `dignity_interaction`；`cues`: `exposure`；`procedure_groups`: `breast`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……坂口，现在你们看的还是原定的那块范围吧？平时只有我们两个人的时候，你还总夸这边呢……啊，别笑！我知道会长回来，可今天真的要在这里动刀耶……
- **Prompt EN / Sayaka:** ...Sakaguchi, you're still working within the planned area, right? When it's just the two of us, you're always complimenting this part of me... Ah, don't laugh! I know it'll grow back, but you're actually operating here today...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `confirm_breast_scope` | 确认范围仍与术前计划一致并保护遮盖 | 嗯……和说好的一样就行。谢谢你还记得替我把其他地方遮好。 | Mm... As long as it's what we agreed. Thank you for remembering to keep the rest of me covered. |
| `brief_breast_scope` | 确认仍在预定范围内 | 好……范围没变。呼，我明明知道答案，还是非要听你亲口说一次才安心。 | Okay... the scope hasn't changed. Hah, I knew the answer, but I needed to hear you say it yourself. |

**`breast_dignity_default_01`** — 通用池回退；原数据主题 `dignity_interaction`；`procedure_groups`: `breast`。

**本版不覆盖本池提示及回应。** 保留原始 `patient_interactions.json` 中的全部默认患者 `prompt` 和 `actions[].response`，不增删按钮，也不将其他池的小夜香对白误套进来。

真实按钮：`answer_breast_stage`（说明当前阶段仍符合术前计划）；`brief_breast_stage`（确认仍按原计划进行）。

**`dignity_low_exposure_02`** — 通用池回退；原数据主题 `dignity_interaction`；`states`: `dignity`；`cues`: `exposure`。

**本版不覆盖本池提示及回应。** 保留原始 `patient_interactions.json` 中的全部默认患者 `prompt` 和 `actions[].response`，不增删按钮，也不将其他池的小夜香对白误套进来。

真实按钮：`reduce_exposure_again`（让团队收拢无关区域的覆盖）；`acknowledge_exposure_again`（承认她的不适并说明当前必要范围）。

**`dignity_cooperation_exposure_01`** — 专属覆盖；原数据主题 `dignity_interaction`；`states`: `cooperation`；`cues`: `exposure`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……我会配合呀。只是能不能不要大家一起盯着这边？我平时知道你们看的是术野，可今天真的好想把脸藏起来……
- **Prompt EN / Sayaka:** ...I will cooperate. It's just... could you not all stare over here at once? I know you're looking at the operative field, but today I want to hide my face...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `limit_observers` | 确认只保留必要人员与术野 | 谢谢……不用多说，我知道谁必须在场。只是这样我就能稍微自在一点了。 | Thank you... You don't need to explain. I know who needs to be here. This just makes it a little easier to bear. |
| `brief_privacy_confirmation` | 确认团队只关注必要区域 | 嗯，知道啦……专业的眼光，对吧？唉，轮到自己时真难说服自己呢。 | Mm, I know... professional eyes, right? Sigh, it's hard to convince myself when I'm the one being looked at. |

**`hysterectomy_signature_01`** — 专属覆盖；原数据主题 `dignity_interaction`；`cues`: `exposure`, `deep_manipulation`；`surgery_ids`: `surgery_hysterectomy`；`once_per_surgery=true`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……已经做到子宫那一步了呀？坂口，明明知道它以后会长回来，可我还是想再问一次……真的要整个取出来了，对吧？
- **Prompt EN / Sayaka:** ...You've reached my uterus now? Sakaguchi, I know it'll grow back, but I still want to ask one more time... You're really going to remove the whole thing, aren't you?

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `confirm_hysterectomy_scope` | 逐项确认当前范围与术前同意一致 | 嗯……你说得这么清楚，我就放心一点了。只是知道和亲自躺着等，真的是两回事呀…… | Mm... hearing you explain it clearly does help. It's just so different knowing about it and lying here waiting for it to happen... |
| `brief_hysterectomy_scope` | 确认没有超出既定范围 | ……好，还是原定范围。你继续吧……我先闭一下眼睛，好不好？ | ...Okay, still the agreed scope. Go on... I just want to close my eyes for a moment, all right? |

**v2 （完整第二套候选，仅后备；待 Codex 确认整池变体支持）**

- **Prompt CN / 南条小夜香：** ……喂，坂口，你可别因为我平时爱开玩笑，就以为现在听见“子宫已经游离好了”我也能笑出来呀。
- **Prompt EN / Sayaka:** ...Hey, Sakaguchi, don't assume that because I usually joke around, I can smile when I hear you say my uterus has been freed and is ready to come out.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `confirm_hysterectomy_scope` | 逐项确认当前范围与术前同意一致 | 嗯，我明白……已经确认过了。谢谢你耐心再说一遍，我现在需要的就是这句。 | Mm, I understand... you've checked it. Thank you for saying it again patiently. That's what I needed to hear. |
| `brief_hysterectomy_scope` | 确认没有超出既定范围 | ……知道了。呵呵，我现在这张脸一定很难看吧？没事，你们按原计划来就好。 | ...Got it. Hehe, I bet I look a mess right now, don't I? It's okay. Just follow the original plan. |

**`ovarian_cystectomy_signature_01`** — 专属覆盖；原数据主题 `dignity_interaction`；`cues`: `deep_manipulation`；`surgery_ids`: `surgery_open_ovarian_cystectomy`；`once_per_surgery=true`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……现在还只是处理卵巢囊肿吧？我知道我们事先说好了，可真正到了这一步，还是会担心正常的部分呀。
- **Prompt EN / Sayaka:** ...You're still only treating the ovarian cyst, right? I know we agreed on the plan, but now that we've reached this step, I can't help worrying about the healthy tissue.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `confirm_ovarian_preservation` | 说明当前仍按术前器官保留计划进行 | 好……谢谢你把范围说清楚。呵呵，医生当患者就是这样，知道越多反倒问得越细呀。 | Okay... thank you for making the scope clear. Hehe, a doctor as a patient asks even more questions because she knows what they mean. |
| `brief_ovarian_preservation` | 确认仍以保留正常组织为目标 | 嗯……明白，我相信你。回头可得让我看看记录哦。 | Mm... understood. I trust you. You'll have to show me the report afterward, though. |

**`myomectomy_signature_01`** — 专属覆盖；原数据主题 `dignity_interaction`；`cues`: `exposure`, `deep_manipulation`；`surgery_ids`: `surgery_open_abdominal_myomectomy`；`once_per_surgery=true`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 坂口，今天是肌瘤剔除，不是子宫全切，对吧？……知道是一回事，躺上来以后我还是想听你再确认一次呀。
- **Prompt EN / Sayaka:** Sakaguchi, we're removing the fibroid, not my whole uterus, right? ...Knowing that is one thing. Lying here makes me want to hear you confirm it again.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `confirm_myomectomy_scope` | 明确确认当前没有改变术式 | 呼……好，范围没变。谢谢你。我只是突然发现，医生交代的每一句话，患者真的会抓得很紧呀。 | Hah... okay, the scope hasn't changed. Thank you. I've suddenly realized how tightly a patient holds on to every word a doctor says. |
| `brief_myomectomy_scope` | 确认仍按原计划处理 | 嗯，知道啦……那我继续配合。你一定要按说好的来哦。 | Mm, got it... I'll keep cooperating. Just make sure we stick to what we agreed. |

**`breast_tumor_signature_01`** — 专属覆盖；原数据主题 `dignity_interaction`；`cues`: `exposure`；`surgery_ids`: `surgery_breast_tumor`；`once_per_surgery=true`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……现在还是按术前画的那块区域切除吧？坂口，你要知道，我今天真的会一直惦记这个范围耶。
- **Prompt EN / Sayaka:** ...You're still removing just the area we marked before surgery, right? Sakaguchi, you should know I'll be thinking about that margin the whole time.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `confirm_breast_tumor_scope` | 重新确认切除范围与术前标记一致 | 嗯，和画好的范围一致……好。你别嫌我啰嗦，我平时也是这样跟患者一项项核对的嘛。 | Mm, it matches the marked area... good. Don't call me fussy. I go through these checks with patients myself. |
| `brief_breast_tumor_scope` | 确认仍在既定边界内 | 知道了。……呼，等会儿回去你可要让我确认一下记录哦。 | Understood. ...Hah, you'll have to let me check the record later, okay? |

**`mastectomy_signature_01`** — 专属覆盖；原数据主题 `dignity_interaction`；`cues`: `exposure`；`surgery_ids`: `surgery_total_mastectomy`；`once_per_surgery=true`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……坂口，这次真的是整侧乳房切除呀。明知道以后会恢复，可想到你们现在真的要把它从我身体上取下来……我还是有点舍不得。
- **Prompt EN / Sayaka:** ...Sakaguchi, this really is a full mastectomy. I know I'll recover afterward, but thinking of you actually removing my breast from my body now... I can't help feeling reluctant.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `acknowledge_mastectomy_loss` | 承认她的失落并确认手术范围 | ……谢谢你没有说“反正会长回来就别怕了”。我知道会恢复，可现在这种难过也是真的嘛。 | ...Thank you for not saying, 'It'll grow back, so don't be scared.' I know I'll recover, but what I'm feeling right now is real too. |
| `confirm_mastectomy_plan` | 确认团队将严格按同意范围完成 | 好……只按确定的范围来。我相信你。至少今天请把每一步都做得漂亮一点，好不好？ | Okay... only within the agreed scope. I trust you. At least do each step neatly today, all right? |

**v2 （完整第二套候选，仅后备；待 Codex 确认整池变体支持）**

- **Prompt CN / 南条小夜香：** ……讨厌，我还以为自己能很帅气地答应这台手术。现在你们真的在准备切除，我却忍不住想把身体缩起来……
- **Prompt EN / Sayaka:** ...Ugh, I thought I'd be so composed about agreeing to this. Now that you're preparing to remove it, all I want is to curl up and hide...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `acknowledge_mastectomy_loss` | 承认她的失落并确认手术范围 | ……嗯。我知道你明白。谢谢你让我难过这一小会儿……好了，你按计划做吧。 | ...Mm. I know you understand. Thank you for letting me feel sad for a moment... All right, follow the plan. |
| `confirm_mastectomy_plan` | 确认团队将严格按同意范围完成 | 我知道了……你说话算数哦。等我缓过来，再让你告诉我手术里都发生了什么。 | I understand... keep your word, okay? Once I've recovered a little, you'll tell me what happened during the operation. |


##### Theme: `ongoing_interaction`

**`ongoing_fear_default_01`** — 专属覆盖；原数据主题 `ongoing_interaction`；`states`: `fear`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……你们怎么突然都不讲话了？每次听见手术室里安静下来，我就忍不住猜是不是又碰到难题了。
- **Prompt EN / Sayaka:** ...Why has everyone suddenly stopped talking? Whenever the OR goes quiet, I can't help wondering whether you've run into a problem.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `reassure_ongoing` | 说明手术仍按计划进行 | 哦，还在按计划进行……好。我知道你们需要专心，偶尔给我一句话就够了。 | Oh, still going to plan... Good. I know you need to focus. Just a word now and then is enough. |
| `brief_ongoing` | 简短回答一切正常 | 嗯，好……那我继续等。唉，躺着等别人做决定，真的比自己在台边做决定难多了。 | Mm, okay... I'll keep waiting. Sigh, lying here while other people make decisions is much harder than making them beside the table. |

**`ongoing_default_01`** — 专属覆盖；原数据主题 `ongoing_interaction`；无指定附加过滤字段。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……现在需要我做什么吗？我知道自己只是患者，可你们忙得那么认真，我总觉得光躺着有点不甘心呀。
- **Prompt EN / Sayaka:** ...Is there anything I should do? I know I'm just the patient, but you're all working so hard that lying here doing nothing feels strangely frustrating.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `coach_ongoing` | 给出简短而明确的配合指示 | 好，明白。我按你说的配合……呵呵，没想到有一天会这么认真听你给我下指令。 | Okay, understood. I'll do what you say... Hehe, who knew I'd be taking your instructions this seriously one day? |
| `reassure_ongoing_default` | 告诉她保持现在这样即可 | 只要保持这样就行？……好吧，今天终于轮到我练习什么都不做了。 | Just stay as I am? ...All right. Apparently today I'm practicing the art of doing nothing. |

**`ongoing_fear_fatigue_01`** — 专属覆盖；原数据主题 `ongoing_interaction`；`states`: `fear`；`cues`: `fatigue`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 坂口……大家为什么都不说话了？我都躺累了，反倒有力气胡思乱想……不会是出了什么事吧？
- **Prompt EN / Sayaka:** Sakaguchi... why has everyone gone quiet? I'm exhausted from lying here, yet somehow I still have energy to imagine disasters... Nothing's wrong, is it?

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `maintain_running_update` | 在操作间隙给出简短进度 | 哦，还是按计划……呼，听你说句话我就安心多了。别看我平时能说会道，今天我真的怕这份安静。 | Oh, still on plan... Hah, just hearing your voice helps. I may usually talk a lot, but today this silence honestly frightens me. |
| `brief_running_update` | 告诉她情况稳定 | 嗯……好，那我再等一会儿。下一个阶段到了就告诉我，好不好？ | Mm... okay, I'll wait a little longer. Tell me when you reach the next stage, all right? |

**`ongoing_fear_fatigue_02`** — 通用池回退；原数据主题 `ongoing_interaction`；`states`: `fear`；`cues`: `fatigue`。

**本版不覆盖本池提示及回应。** 保留原始 `patient_interactions.json` 中的全部默认患者 `prompt` 和 `actions[].response`，不增删按钮，也不将其他池的小夜香对白误套进来。

真实按钮：`preview_next_milestone`（说明下一个阶段性目标）；`encourage_next_milestone`（告诉她正在接近下一个节点）。

**`ongoing_pain_position_01`** — 专属覆盖；原数据主题 `ongoing_interaction`；`states`: `pain`；`cues`: `position_discomfort`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……肩背越来越酸，我连手指都想活动一下。可你们固定得这么认真，我哪里敢自己乱动呀……
- **Prompt EN / Sayaka:** ...My shoulders and back are aching worse and worse. I even want to wiggle my fingers. But after all the care you took positioning me, I'm afraid to move a muscle...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `adjust_pressure_points` | 让巡回护士检查支撑和受压点 | 啊……这样垫一下舒服多了。谢谢，没想到今天最让我感激的竟然是有人帮我调整个垫子…… | Ah... that padding makes a huge difference. Thank you. I never thought I'd be this grateful for someone adjusting a cushion... |
| `coach_position_stillness` | 说明不能自行移动并指导小幅放松 | 嗯，我不会乱动。我就照你说的放松……不过等会儿可别再让我躺到天黑哦。 | Mm, I won't move. I'll relax just as you said... Just don't leave me here until nightfall, okay? |

**`abdominal_ongoing_pressure_01`** — 专属覆盖；原数据主题 `ongoing_interaction`；`cues`: `pressure`, `fatigue`；`procedure_groups`: `general_abdominal`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 坂口……肚子里面一直这么沉沉的，你们是在做比较深的步骤吗？我现在真没办法只凭器械声判断呀。
- **Prompt EN / Sayaka:** Sakaguchi... there's this heavy pressure in my abdomen. Are you working deep inside? I really can't tell from the instrument sounds anymore.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `explain_abdominal_pressure` | 说明正在完成腹腔内的重要阶段 | 嗯，明白。是计划中的步骤就好……呼，原来知道“为什么难受”真的会好一点呀。 | Mm, I understand. As long as it's part of the plan... Hah, it really does help to know why something feels awful. |
| `brief_abdominal_pressure` | 确认压力感与当前步骤相符 | 好，我尽量放松腹部。只是今天这份“放松”可真不是嘴上说说就能做到的呀。 | Okay, I'll try to relax my abdomen. It's much easier said than done today. |

**`pelvic_ongoing_position_01`** — 专属覆盖；原数据主题 `ongoing_interaction`；`cues`: `position_discomfort`, `fatigue`；`procedure_groups`: `female_pelvic`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……腰和腿都快僵掉了。早知道这台要保持这个姿势这么久，我刚才就不该笑你们摆位太认真了……
- **Prompt EN / Sayaka:** ...My back and legs are almost frozen stiff. If I'd known I'd have to stay like this so long, I wouldn't have teased you all about how carefully you positioned me...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `support_pelvic_position` | 让巡回护士重新检查支撑点 | 啊……好多了！谢谢。你们别笑我，今天我是真的体会到一个垫子有多重要啦。 | Ah... that's so much better! Thank you. Don't laugh at me; today I've learned how much a single cushion matters. |
| `coach_pelvic_position` | 指导她分段放松腰腿 | 好……我按你说的放松腰腿。唉，我现在倒真希望能立刻换回医生那一边去。 | Okay... I'll relax my back and legs the way you said. Sigh, right now I really wish I could trade places and be the doctor again. |

**`thoracic_ongoing_position_01`** — 通用池回退；原数据主题 `ongoing_interaction`；`cues`: `position_discomfort`, `fatigue`；`procedure_groups`: `thoracic`。

**本版不覆盖本池提示及回应。** 保留原始 `patient_interactions.json` 中的全部默认患者 `prompt` 和 `actions[].response`，不增删按钮，也不将其他池的小夜香对白误套进来。

真实按钮：`check_thoracic_support`（让巡回护士复核肩背支撑）；`coach_thoracic_stillness`（说明固定必要性并指导局部放松）。

**`cardiac_ongoing_fatigue_01`** — 专属覆盖；原数据主题 `ongoing_interaction`；`cues`: `fatigue`；`procedure_groups`: `cardiac`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……这么久了呀。明明是我自己想体验的，可听着你们处理心脏时一句话都不说，我真的越来越害怕了……
- **Prompt EN / Sayaka:** ...It's been so long. I was the one who wanted to experience this, but hearing you work on my heart without saying a word is honestly getting scarier and scarier...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `reassure_cardiac_ongoing` | 持续用简短信息维持她的方向感 | 呼……原来还在按计划。谢谢你。只要能偶尔听到你的声音，我就不会一直往坏处想。 | Hah... so we're still on plan. Thank you. As long as I can hear your voice now and then, I won't keep imagining the worst. |
| `brief_cardiac_ongoing` | 确认团队仍按计划推进 | 嗯……好，我信你们。我只是现在连开玩笑都没什么力气了…… | Mm... okay, I trust you all. I just don't have much energy left for jokes right now... |

**`vascular_ongoing_pressure_01`** — 通用池回退；原数据主题 `ongoing_interaction`；`cues`: `pressure`, `fatigue`；`procedure_groups`: `vascular`。

**本版不覆盖本池提示及回应。** 保留原始 `patient_interactions.json` 中的全部默认患者 `prompt` 和 `actions[].response`，不增删按钮，也不将其他池的小夜香对白误套进来。

真实按钮：`separate_vascular_sensations`（帮助她辨认感觉并说明当前进度）；`brief_vascular_pressure`（确认团队正在密切观察）。


##### Theme: `closure_interaction`

**`closure_default_01`** — 专属覆盖；原数据主题 `closure_interaction`；无指定附加过滤字段。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……真的快结束了？先说好，我可不会因为听见“收尾”两个字就立刻精神起来哦……
- **Prompt EN / Sayaka:** ...Are we really almost finished? Just so you know, hearing 'closure' isn't going to make me lively again all of a sudden...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `confirm_closure` | 告诉她主要步骤已经完成 | 呼……主要步骤都完成了呀。谢谢，你慢慢把最后这点做好，我等着。 | Hah... so the main part's done. Thank you. Take your time finishing the last bit properly. I'll wait. |
| `brief_closure` | 告诉她正在完成最后检查 | 还在做最后检查？……好，我撑得住。只是这回你可别把“最后”说得太轻松啦。 | Still doing the final checks? ...Okay, I can manage. Just don't make 'final' sound quite so easy this time. |

**`closure_fear_closure_01`** — 专属覆盖；原数据主题 `closure_interaction`；`states`: `fear`；`cues`: `closure`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 已经在缝了呀？……坂口，你说的“快结束”这次是真的吗？我可不想高兴得太早呀。
- **Prompt EN / Sayaka:** You're suturing already? ...Sakaguchi, is 'almost finished' actually true this time? I don't want to celebrate too soon.

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `confirm_closure_phase` | 确认已进入关闭阶段 | 呼……真的到收尾了。好，我再乖乖躺一会儿，你们可别急着省复核哦。 | Hah... it really is the final stage. Okay, I'll lie still a little longer. Just don't rush the checks for my sake. |
| `brief_closure_phase` | 告诉她正在完成最后处理 | 嗯，最后处理……好吧，我再忍这一小段。可你别把“一小段”说成半小时呀。 | Mm, the final steps... All right, I'll bear a little longer. Just don't let 'a little longer' turn into half an hour. |

**`closure_fear_closure_02`** — 通用池回退；原数据主题 `closure_interaction`；`states`: `fear`；`cues`: `closure`。

**本版不覆盖本池提示及回应。** 保留原始 `patient_interactions.json` 中的全部默认患者 `prompt` 和 `actions[].response`，不增删按钮，也不将其他池的小夜香对白误套进来。

真实按钮：`explain_final_checks`（说明主要步骤完成，正在逐项复核）；`confirm_final_checks`（确认正在收尾）。

**`closure_pain_closure_01`** — 专属覆盖；原数据主题 `closure_interaction`；`states`: `pain`；`cues`: `closure`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** 呜……都在缝合了怎么还能这么难受呀！我知道你们要慢慢关好，可我真的快没力气忍了啦……
- **Prompt EN / Sayaka:** Ngh... how can closing still feel this awful?! I know you have to do it properly, but I barely have the strength left to endure it...

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `pause_closure_discomfort` | 短暂停顿并处理她的疼痛 | ……谢谢。呼，终于能缓一下。我现在连说俏皮话的力气都要用光了。 | ...Thank you. Hah, I can finally catch my breath. I'm almost out of energy for witty remarks. |
| `pace_closure_breathing` | 配合呼吸节奏继续关闭 | 嗯……跟着你的节奏，慢慢呼气……好，我再把这一段熬过去。 | Mm... follow your pace, breathe out slowly... Okay, I'll get through this last part. |

**`breast_closure_fear_01`** — 专属覆盖；原数据主题 `closure_interaction`；`states`: `fear`；`cues`: `closure`；`procedure_groups`: `breast`。

**v1 （本轮首选接入稿）**

- **Prompt CN / 南条小夜香：** ……已经在缝合了呀？坂口，我知道以后会恢复，可是今天被你们真的切掉了那一部分……等会儿我还能像平时一样看镜子吗？
- **Prompt EN / Sayaka:** ...You're closing already? Sakaguchi, I know it'll grow back, but having that part of me genuinely removed today... Am I going to be able to face the mirror afterward?

| 真实 `actions[].id` | 玩家原有按钮（保持不变） | Response CN：南条小夜香 | Response EN：Sayaka |
|---|---|---|---|
| `answer_breast_closure` | 说明手术范围已按术前计划完成 | 嗯，完全按说好的范围来……谢谢。现在别急着安慰我漂亮不漂亮，先把最后这一步做好就行。 | Mm, exactly the area we agreed on... Thank you. Don't worry about telling me whether I'm pretty right now. Just do the last part properly. |
| `brief_breast_closure` | 确认正在按计划收尾 | ……好，按计划收尾。等我下了台，你可得慢慢把每一步讲给我听。 | ...Okay, finish according to plan. Once I'm off the table, you'll have to tell me about every step. |


#### C2 编剧备用资源与特殊注意

1. **没有被采用的 V1.2 主题级三选一稿并未删除**：它完整保存在独立的 `HOSHIMI_SAYAKA_STAFF_AS_PATIENT_DIALOGUE_DRAFT_V1_2_CN_EN.md` 的 C2 中，仅作 **unbound reserve**，不得直接连到这些真实 action；本 V1.5 C2（继承 V1.3 实际 action 映射）为新的权威候选。
2. `contact_no_anesthesia_incision_03` 的两个真实按钮均明确**拒绝追加麻醉**，不能把 `steady_unanesthetized_contact_03` 误实现为补麻醉，亦不能把患者的求药台词误判为创建新取消按钮。
3. `hysterectomy_signature_01` 仅命中 `surgery_hysterectomy`（开腹子宫全切）；**经阴道子宫全切**目前无同名术式专属池，不能仅因为 A1b 同属 `HYSTERECTOMY` 就冒充命中该 C2 池。
4. `breast_closure_fear_01` 属于整个 `breast` 分组，**不只在全乳房切除触发**，因此台词刻意不写“整侧已经切掉”，保证乳房肿瘤切除时也成立。
5. C1 是原 V1.2 的术式阶段／岗位候选，**不是本 JSON 池的一部分**。助手与护士两条分别面对不同岗位，不得合并为同一池随机句；仅在 Runner 另有患者发言窗口时接。
6. 全麻期间一律不调用这里的患者对白。若某 `pool` 在真实运行时可能因 state / cue 组合错配而播出不合适情绪，应先修复数据筛选或沿用原池，不能静默重写角色原文以掩盖接口缺陷。


### C2b. C2 以外实际患者文本的首版覆盖／回退矩阵（V1.4 新增）

> **这张表只声明写作与接线策略，不擅自假设这些节点的真实 JSON Key。** 实际调用点必须让 Codex 导出。**“通用回退”不等于已完成人物专属对白。**

| 现有演出类别（语义） | V1.4 决定 | 接线与核验要求 |
|---|---|---|
| 医护界面邀请／病房占用拒绝 | **A1／A1b 可接入候选；A2 仅暂存** | 邀约确认当前可覆盖；病房占用时现有机制只有**系统提示**，没有小夜香角色发言入口。不得将 A2 直接作为已接入对白，也不得为了 A2 擅自新增分支。错术式后仍应可识别最初邀约 ID |
| 病房首次接收／准备完成通知 | **首版通用原文回退**；E4b 为未绑定候选 | 列出真实节点／是否由护士而非患者发言，不能把护士台词塞进患者响应 |
| 术前说明入口、简短说明、麻醉选择 | **B1、B1a 小夜香专属候选；B1a-VH 三节点替换待模板核验** | `explain_plan` 当前 `response_speaker=narrator`，必须通过经核验的最小**Staff 专属 speaker 覆写**让小夜香发话，不能当旁白播放。病房说明对照邀约术式，麻醉选择在后，手术室实际术式选择更晚；详细问答除 B1a-VH 外仍沿用适用的通用中间对白 |
| 灌肠、备皮、手术帽、摆位、导尿、消毒 | **B2 逐动作双变体专属候选** | 仅在原流程确实触发时播放；不要为了台词增加不必要准备 |
| 手术台触诊、针刺检查 | **首版通用患者原文回退** | 需 Codex 提供真实入口，未写专属触诊／针刺连续对白 |
| 麻醉作用／感觉测试 | **首版通用患者原文回退** | 若已全麻失去意识则无清醒语言回应 |
| 第一刀标记与实际切皮 | **B3 小夜香专属候选** | 两拍分开，按实际麻醉类型筛选 |
| C2 的 50 个术中患者互动池 | **39 专属、11 通用回退** | 必须服从 C2-MISMATCH 的 11 池排除与 C2-ANATOMY 的按钮文案问题 |
| 恶心、嗜睡、临时疼痛／恐惧状态插话 | **首版通用原文回退** | 这些不一定属于 C2 50 池；需提供实际发言节点与麻醉过滤 |
| 低配合、低尊严触发插话 | **首版通用原文回退** | 和 C2 中部分 `dignity` 主题不同；若存在独立触发不能错算专属覆盖 |
| C2 以外的术式特殊插话 | **首版通用原文回退** | 记录实际 `surgery_id`／节点位置；不从 39 池总数中漏算 |
| 手术成功、全麻苏醒、提前终止 | **D 段候选待核对** | 没有现成完成对白钩子就不播放；全麻患者不得在尚未醒来时发言 |
| 病房恢复日常 | **目前不存在；不接入** | 保留 `postop_relief`／`postop_teasing`，不新建病房恢复场景 |
| 手术团队角色／病房准备护士 | **E 段岗位候选；未做到人物逐个专属** | 默认保持现有团队对白；核对实际发话窗口后再选择性接入 |

本表各行不是新增事件节点或 JSON Key；**Codex 不得为满足本表自动创建新医疗步骤、对话选择、团队岗位、病房恢复环节。**

### C3. 麻醉与触发界限

- 全麻：诱导后到苏醒前，**所有 B3 切皮时的患者语音与 C1／C2 的清醒患者语音均不触发**。术后首句使用 D 段全麻专属。
- 硬膜外／局部／无麻醉：仅在 runner 原本有患者发言窗口时抽取。疼痛强度必须由实际麻醉条件、患者状态与步骤 cue 决定，不应把 `strain_interaction` 里强烈疼痛变体无差别播放在充分麻醉、无刺激的节点。
- 本次 C2 已逐条使用真实 `pool_id + action_id`，但“这些 pool 何时优先命中、如何覆写患者文本”仍须由 Codex 审查调用代码；不能擅自增加临时 action 或按钮。

---
## D. 手术结束与病房恢复（候选台词；只接入真实存在的结束窗口）

**V1.3 接线限定：** 目前没有病房恢复演出阶段。下表的 `postop_relief`、`postop_teasing` **不要接入当前版本，也不要为了这两句新增病房场景**；未来真的增加恢复节点再复用。`surgery_success_awake`、`surgery_success_anesthetized` 与 `surgery_abort_or_stop` 是否有真实、可达的运行时出口，请 Codex 对照代码确认后再接。**原候选台词逐字保留。**

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

**E1 团队确认台词的时间条件（V1.4 修复）：** 上表原文中的「术式、麻醉和团队都确认好了」**只能用于麻醉选择完成后、且已有真实发言窗口的场景**；不能挂到麻醉选择之前的 `confirm_team`。如果实际 `confirm_team` 在麻醉选择前调用，则仅在该真实窗口适用下列**替代候选**，不会重复播放 E1 原句：

| 适用时间 | 中文：坂口隆司 | English: Sakaguchi |
|---|---|---|
| 麻醉选择**之前**的团队确认 | 「南条医生，今天要做的是{procedure_name}。我们先核对术式和上场团队，麻醉方案等会儿再确认。今天你是患者，有什么不舒服直接说。」 | “Dr. Nanjou, today’s procedure is {procedure_name}. We’ll check the procedure and the team first, then confirm the anesthesia choice afterward. You’re the patient today, so tell us directly if anything feels wrong.” |

- 若现有节点没有坂口发言窗口，上述两句都只是候选，不得擅自让原讲解人改成坂口。
- 本版首发**不要求按每名具名同事独立创作 E 段**。实际同事继续用现有通用岗位对白；这里的模板只有明确确认人物／发话窗口时才允许候选覆盖。病房准备护士 E4b 同理，E5 麻醉岗位仍暂存。

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

### E4b. 病房准备护士（V1.3 补充：**候选岗位文本，待确认真实发话节点**）

**定位：** Codex 已确认 Staff-as-Patient 流程中另有病房准备护士岗位；但提交的两个 JSON 没有病房准备护士名单／发话窗口。以下**只提供中英双语岗位候选**，不等于已经能在 Runner 中播放，也不能把通用口吻直接覆盖某位具名护士的既有人物台词。

| 节点语义 | 中文：病房准备护士 | English: Ward Preparation Nurse |
|---|---|---|
| 病房接收／术式核对 | 「南条医生，今天轮到您当患者啦。姓名、术式和计划我们会逐项核对；您今天可以放心把病房这边交给我们。」 | “Dr. Nanjou, it's your turn to be the patient today. We'll check your identity, procedure, and plan step by step. You can leave the ward preparations to us.” |
| 开始术前准备 | 「南条医生，准备要花些时间。每完成一项我们都会告诉您，您不用跟着操心记录。」 | “Dr. Nanjou, preparation will take a while. We'll tell you as each step is completed. You don't need to worry about the paperwork.” |
| 她抱怨时间漫长 | 「呵呵，南条医生，您平时站着做准备，不会觉得这么久。今天得辛苦您躺着等，我们这边会按顺序做完的。」 | “Hehe, Dr. Nanjou, you don't notice the time when you're the one doing the work. Today you'll have to put up with waiting while we go through everything in order.” |
| 准备完成／转运交接 | 「病房准备已经核对完成。南条医生，接下来我们会把记录交给手术室团队，您按指示配合就好。」 | “The ward preparation checks are complete. Dr. Nanjou, we'll hand your records over to the OR team. Just follow their instructions from here.” |

> **使用限制：** 每句只有当实际准备流程有对应窗口、岗位已配置且人物在场时才可用；若某一步对本次术式不必要，绝不能为了这四句强制触发该医疗操作。成员不同可沿用通用原文回退；未来若要给弘子等各自写性格台词，须单独审稿。

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

## V1.5 追加接线边界：按 Codex 最新反馈作出的决定

以下是**实装指令及候选使用条件**，不是玩家可见对白。V1.4 各章节原文和 50 池静态数据映射除本版列明的局部修订外均保留。

| 编号 | 现有事实（来自 Codex 反馈或已提供 JSON） | V1.5 确定的处理方式 | 不能声称已完成的事项 |
|---|---|---|---|
| `V15-SPK` | `explain_plan` 当前 `response_speaker=narrator` | **仅 Staff 小夜香**分支经最小覆写，才能播 B1 `explain_plan` 的患者对白，展示 speaker=南条小夜香；不能把文本塞到 narrator 字段后照播 | 未取得对应 Runner 覆写代码，角色 speaker 仍待核实 |
| `V15-ORDER` | 病房说明／麻醉选择发生在前，手术室实际选术式在后 | B1a 解释**最初邀约术式**，`{procedure_name}` 也指该术式；发生 mismatch 后只触发既有 `procedure_mismatch`，不伪造重讲术式分支；C2-MISMATCH 的池过滤仍必须执行 | 当前没有错术式后的说明／重新同意机制，也不在此新增 |
| `V15-BUSY` | 病房占用拒绝由系统提示显示 | A2 保留写作候选；**不显示成小夜香说话**，除非以后确有经用户批准的最小角色提示窗口 | A2 尚未接入 |
| `V15-VH` | 妇科术前类别模板的三个旧节点包含开腹入路及肠管移动问答 | 对最初邀约 `surgery_vaginal_hysterectomy` 的 `field / bowel / bowel_answer` 使用上节**整组三句**，按真实原模板 ID 和 speaker 接入，其他妇科术式不改变 | 缺本机 `preop.json` 相邻原文，无法从本轮资料证明所有节点和入路分支均已修复 |
| `V15-RESERVE` | 无完整的全麻苏醒、病房恢复、C1 自由阶段发言、所有团队个人专属文本窗口 | 保留 D／C1／E 为候选或现有通用回退；不自动建系统或挤占现有其他说话人的窗口 | 不可把候选数量当作已实装覆盖率 |
| `V15-TONE` | 成年情侣在经阴道／乳房手术时可有明确亲密指向的含蓄措辞 | 按本稿第0节和独立写作规则：**保留「那里」「你」**；乳房相关可更轻柔；不能因“医疗场景”自动中性化 | 不因此向所有妇科术式硬塞经阴道暗示；不跨越每个人的个性设定 |

**V1.5 验收用例建议：**

1. 邀约 `surgery_vaginal_hysterectomy` → 病房详解：按顺序播放本稿 `field`（医护）、`bowel`（小夜香）、`bowel_answer`（医护）；没有开腹后推开肠管的旧三句；后续才出现麻醉选择。**若后续实际选择另一术式，也不能倒改当天已经播放过的说明内容。**
2. 邀约 `surgery_hysterectomy`（开腹子宫全切）→ 保留对应开腹说明；**不播放经阴道版**。
3. 邀约 `surgery_breast_tumor` → 实际选 `surgery_hysterectomy` → `procedure_mismatch` 播放、含“原术式同意范围不变”的 C2 池不出现；手术室不凭空补播病房的经阴道／子宫说明。
4. 邀约普通已解锁术式 → B1 `explain_plan` 若展示小夜香对白，speaker 必须是小夜香，不是旁白；病房占用时只能显示现有系统提示，除非另有已批准入口。
5. 乳房手术且术式一致 → `breast_dignity_exposure_01` 微调版可以触发，其 CN／EN 均保留“这边 / this part of me”的隐含亲密感；不得误触发于腹部或妇科。
6. 术后无恢复窗口及全麻未苏醒时 → 不显示任何暂存 D 段小夜香发话，严格保留既有完成出口。

---

## V1.5 实装前 Code Audit：仍需 Codex 从代码确认的缺口（不是请它创作对白）

本轮**已解决**：32 个术式的真实 ID／难度／名称、50 个互动池的真实 `pool_id`／`action_id`／按钮 `label`／静态限制条件。**静态 JSON 无法证明调用逻辑和界面实际播出时间。** 下一步请 Codex 只审计代码并提交具体证据；写作稿不要求它顺便添加新系统。

| 优先级 | 仍需核实 | 精确交付要求与默认保守处理 |
|---|---|---|
| P0-1 | **患者互动池的选择算法** | 给出真正的代码函数／调用链，说明 `surgery_ids`、`procedure_groups`、`states`、`cues`、`required_flags`、`excluded_flags` 如何一起参与过滤和优先级；特别确认无麻醉三池和六个术式专属池是否会被默认池覆盖。未证实前不得声称专属池一定播放 |
| P0-2 | **Staff 患者专属 prompt/response 覆写接口** | 查明角色专属的实际 bundle/schema；能否以 `pool_id`、`action_id` 为 key 仅覆写文字并继承原按钮 `label`／`minutes`／`effects`／`condition_effect`；若不支持，给出最小可行的代码变更选项供用户批准，**不要先改** |
| P0-3 | **中英双语与随机整组变体** | 核实一次触发如何选取同池 `v1/v2` 并确保 `prompt` 与所选 `response` 是同一套；若暂不支持，必须只用 `v1`，把 `v2` 原样保留为候选。核实中文与英文同样按角色覆盖，不把 English 留作中文占位 |
| P0-4 | **邀请术式覆盖的接线位置** | 医护界面选择术式、确认病房是否已有患者、调用邀请对白的源代码位置；确认 `{procedure_name}` 在中英两版的插值机制，A1b 32 项白名单如何以**最小变更**接入；不自动为无法分类的三术式创建标签 |
| P0-5 | **术前说明顺序与 B1 speaker 覆写** | 已知 `explain_plan` 原 `response_speaker=narrator`。需核对最小角色专属 speaker 覆写调用点、确保患者回应不显示为旁白；列出详细说明的实际讲解人、中间患者句和麻醉选择时间。病房阶段 `{procedure_name}` 固定为**最初邀约术式**，不可宣称是后来选择的实际术式 |
| P1-1 | **实际准备与发话窗口** | 提供 `reaction_lines/reaction_variants` 可注入的字段及例子；验证 B2 每个动作是否真会触发、病房准备护士岗位是否有发话窗口；E1–E5 均为候选，不能据此替现有具名护士改人设 |
| P1-2 | **完成、终止和苏醒出口** | 确认有没有清醒成功对白钩子、真正苏醒时点、危机失败终止时患者能否发话；若不存在，D 的对应项保持“暂存”，**绝不新增病房恢复事件**；全麻期间不许播患者清醒台词 |
| P1-3 | **未覆盖回退及状态特效** | 检查 C2 11 个通用池回退和恶心、嗜睡、体位等临时互动能否正常触发；确认没有把 C1 助手／护士两个岗位回复随机混用；验证 Staff 的声望豁免、错术式／无麻醉规则和训练经验递减没有改变 |
| **P0-6** | **错术式时选池过滤（V1.4 新增；必须验收）** | 核对“最初邀约 surgery_id”和“实际执行 surgery_id”的来源，证明 11 个依赖原约定一致的池不会在 mismatch 分支被选中（包含通用池），且不额外生成新按钮；回归用例：乳房肿瘤切除 → 子宫全切 |
| **P0-7** | **经阴道术式 `field/bowel/bowel_answer` 的完整连续替换（V1.5 已补写）** | 从本机 `data/patients/templates/preop.json` 导出原三节点及相邻节点（真实 Key、speaker、条件、CN/EN 资源），对最初邀约 `surgery_vaginal_hysterectomy` **整组**接入 B1a-VH 的 CN／EN，不污染开腹妇科模板；全文检索是否还有与该术式矛盾的“开腹／推肠管”残句，并报告，不要假称全模板已修复 |
| **P0-8** | **通用牵拉按钮的部位限制（V1.4 新增）** | `strain_pain_traction_02 / coach_second_traction` 的原按钮写“放松腹部”，却是全分组可用；选择“跨术式中性化原按钮 label（ID/effects 不变）”或“限定该池腹部适用范围”；未修前本池不算完全验收 |
| P1-4 | **C2 以外患者发言／团队发话窗口、A2 拒绝入口** | 对照 C2b 回退矩阵导出入口和原文；E1 初始团队确认在麻醉选择前只能用前置候选，E2–E4b 首发允许沿用原岗位对白。A2 目前仅系统提示，无小夜香发言入口；若需要接入须单独报告最小变更方案，不得假装已经显示 |

### 三种器官切除的邀约分类：本版已决定（不再是待定项）

- `surgery_open_cholecystectomy`（开腹胆囊切除）
- `surgery_open_splenectomy`（开腹脾切除）
- `surgery_open_adrenalectomy`（开腹肾上腺切除）

**用户本轮接受 Codex 所列的既有默认方案：三项全部固定 A1 普通邀约回退。** 这不是对医学重要性的判断，也不是需要再次追问的阻塞项。其他特殊类别按 A1c 表匹配。

### 已存在但没有直接接入资格的对白

- D：`postop_relief`、`postop_teasing` **仅候选**，现有版本没有病房恢复环节；`surgery_success_anesthetized` 必须先证明有真正苏醒节点。
- D：`surgery_success_awake` 仅在存在／获批准新增一个最小成功出口钩子后接入；不可私自为它增加新剧情。
- D：`surgery_abort_or_stop` 只对应确实存在且角色可以清醒说话的终止出口，不代表新增临时取消按钮。
- E：通用团队和病房准备护士都是**岗位候选**，不是已制作的“每位同事个人对白”。
- C1：四阶段自由患者插话本身不是 `patient_interactions.json` 数据池，未确认独立发言窗口前保持候选。
- V1.2 C2：旧 6 主题“语义三选一”全文保存在独立 V1.2 版本，仅作 **unbound reserve**；不可误接。

---

## V1.5 变更摘要与当前交付边界

**V1.4 继承内容（完整保留）：**

1. V1.3 正文完整保留；修正 `last_reassure`、B1a 讲解人的“约定术式”措辞，使其不凭空断言邀约与实际手术一致。
2. 修正 `contact_default_01 / brief_start` 和 `dignity_low_exposure_01 / explain_exposure` 的两处“第一次”台词，并同步修正中英文；不新增“首次训练”游戏条件。
3. 修正 `strain_default_01`、`urologic_strain_pressure_01` 及 `strain_pain_traction_02` 的部位硬编码；仅文案层完成，原 runner 按钮仍需代码修正／限制。
4. 引入 `C2-MISMATCH` 的 11 池过滤方案：实际不同术式不得播放声称原约定未改变的按钮、回答。**需要 Codex 在实际选池逻辑内实施／确认，文档本身不是运行时修复。**
5. B1a 明确四类详细说明内的通用患者中间对白在首版**照原文回退**；经阴道子宫全切等入路不适配需要 Codex 给出确切模板节点后修复，暂不臆造 32 套专业说明。
6. C2b 记录该 50 池之外的语义阶段并说明“人物化／通用回退／暂存”，不虚称整条手术流程已完成专属替换。
7. E1 区分麻醉选择前后，其他同事的专属团队台词**非本次首发门槛**；三项胆囊／脾／肾上腺切除按已确认默认 A1 邀约。

**V1.5 具体新增／修订（仅以下部分）：**

1. 新增**第0节长期写作规则**及独立项目级文件：私密手术中明确指向的「那里」与「你」不可被中性化；乳房同理但语气可以较轻。
2. 新增 **B1a-VH** 三节点中英替换：只有最初邀约 `surgery_vaginal_hysterectomy` 时整体替换 `field → bowel → bowel_answer`，医学说明与私人羞赧台词连续相扣。
3. 仅微调 `breast_dignity_exposure_01` 的 **v1 prompt** 及对应英文，以较低强度回收既有情侣关系；不改该池任何 action、effects 或其它对白。
4. 修复 B1a 逻辑顺序：**病房说明最初邀约术式，在前；手术室实际选术式，在后；mismatch 后没有重讲分支**，不能把 `{procedure_name}` 错当作实际术式。
5. 强调 B1 `explain_plan` 不能把小夜香写进 `narrator` speaker；A2 病房占用拒绝**目前只作为未绑定候选**；C1、D、E 仍按原回退／暂存边界。
6. 增补逐例测试清单与 `P0-7` 精确源文件核验任务；**不要求新术式、新按钮、病房恢复系统或新的麻醉岗位**。

**仍阻塞“可直接实装”的核心问题：** `P0-6` 的 mismatch 选池过滤；`P0-7` 的**真实 preop 模板节点定位与三句整体替换验收**（文案现已写齐）；`P0-8` 的无手术组限制“放松腹部”按钮；以及 `P0-5` 的 narrator→小夜香 speaker 覆写和 `P0-1`～`P0-4` 的运行时验证。**V1.5 已补全文本，不等于上述代码入口已经存在／通过测试。**

## 作为未来其他 Staff-as-Patient 角色的参考（待 Codex 核验后才能定为共用标准）

本稿将来可以作为**写作案例与接口规格**，但**不能**把小夜香的话复制给其他人物当“专属对白”。以后每位成年 Staff 患者的编剧稿应沿用如下原则：

1. **先读取真实术式及互动池**：不能根据 `theme` 想象玩家按钮；每条专属池用 `pool_id` 指向，`prompt` 和 `actions[].response` 必须覆盖该池全部已有 `action_id`。保留原按钮 label、effects 和时间成本。
2. **先确定人物自己的术前态度、术中底线与事后评价**：小夜香的调情、主动探索、屈辱后嘴硬不等于其他女医生／护士都同样反应。
3. **保留有限而明确的专属覆盖**：每个池明确 `专属` 或 `通用回退`，不能在交付时宣称所有节点都有专属台词；可为重点池写多个完整变体，但不可只随机替换 prompt 而不保持 responses 同步。
4. **每条 CN／EN 对应**：用实际相同的变量和人物称谓；翻译忠实，不软化剧本情绪，也不改变中文原意。
5. **医疗体验与剧情系统分离**：她知道流程不等于不会害怕；角色对白表达的恐惧或不满不自动产生声望惩罚，不改变手术流程既定成功、取消、经验规则。
6. **未知运行时能力必须明示**：无钩子的团队台词、全麻苏醒、病房恢复和备用池都不得被暗中接线。写作端负责文字和精确语义，Codex 负责检查真实引擎接口。
7. **经 Codex 实测后再提炼正式模板**：得到 `通过/不通过 + 源码位置 + 实测截图或记录` 的审计结果后，另行制作不含小夜香专属台词的通用《Staff-as-Patient 角色对白写作模板》，供未来人物复用。本 V1.5 在那之前只是**模板候选参考**。

## 编剧交付复核表

- 32/32 实际术式都具有唯一类别建议或明确的“待用户判定 → 默认回退”；不按难度自动猜新规则。
- 50/50 患者互动池已列；39 池有小夜香专属问答、11 池保留原 JSON 默认问答。
- 所有专属问答使用真实 `pool_id`、`action_id`，每一个现有按钮有对应中英 response；无多出或遗漏按钮。
- 所有原始按钮 label、`minutes`、`effects`、实际触发标签不属于写作改动范围。
- 术前说明在麻醉选择之前；当前仅有四类说明，不声称有32套完整专业讲解。
- 全麻期间没有患者口头互动，病房恢复不被偷偷新建，团队对白说话人不得乱套。
- 已批准的 Lv5 正篇与后日谈文本不修改；本文件仍需用户审稿与 Codex 运行时验收。

**END — V1.5 CN/EN dialogue draft, implementation pending.**
