# Hoshimi Hospital — 折川皐月 Relationship Lv2 Event
## 《陪我去一次》
### OR Rotation / Patient Transport / Doorway Bracing Event
### Canonical Event Script

> **文件性质：Canonical Relationship Event Script**
>
> **稳定文件名：**
>
> ```text
> HOSHIMI_ORIKAWA_SATSUKI_LV2_PATIENT_TRANSPORT_EVENT.md
> ```
>
> 后续直接更新本文件，不创建 V2 / V3 副本。
>
> **角色：**
>
> - 折川皐月 / Orikawa Satsuki
> - Saber / Artoria
> - 石神千鹤 / Ishigami Chizuru
> - 坂口 / Player
> - 杉村弘子 / Sugimura Hiroko
> - event-only adult female patient
>
> **事件目的：**
>
> > 皐月不是因为“不再紧张”才适合围术期护理。
> >
> > 她恰恰因为知道“明明脑子知道应该继续，身体却突然动不了”是什么感觉，所以能够在患者最难堪、最害怕的时候停下来。
>
> **Lv2 核心关系意义：**
>
> > **“我可以在坂口先生身边正常工作。”**

---

# 0. Codex / Implementation Summary

推荐事件 ID：

```text
satsuki_lv2_patient_transport
```

推荐 gate：

```text
satsuki_relationship_level == 1
satsuki_familiarity >= 25
clinical_presence <= 0
days_since_satsuki_lv1 >= 3
event_not_seen == satsuki_lv2_patient_transport
```

完成后：

```text
satsuki_relationship_level = 2
satsuki_or_rotation_unlocked = true
satsuki_successful_patient_transport = true
satsuki_lv2_patient_transport_complete = true
```

如果项目已有统一 relationship promotion / event-complete API：

> 使用现有接口，不另外造字段系统。

---

# 1. Continuity Requirements

本事件必须承接皐月既有路线。

## Lv0 已建立

```text
仰慕杉村弘子
原本向往外科 / 手术室护理
因为面对男性容易紧张，最后申请妇科
```

## Lv1 已建立

Aqua 的妇科设备 patient-experience 让皐月明确意识到：

```text
患者看不到医生会更紧张
体位变化前不解释会增加失控感
患者不舒服时未必敢主动开口
多人围绕会形成压迫感
“放松”不是有效安抚
```

并得到：

> 「折川，你很适合做这个。」

> 「做患者？」

> 「做护士。」

本 Lv2 必须把这些观察真正用于临床。

---

# 2. Event Structure

```text
Scene 1
皐月承认自己仍然想做围术期护理
↓
Scene 2
Saber 陪她见石神；不替她求情
↓
Scene 3
石神批准从 Holding / Transport / Handoff 基础轮转开始
↓
Scene 4
皐月完成数次普通转运
↓
Scene 5
成年女患者在 OR 门口突然双脚死死撑住门框
↓
Scene 6
皐月停止推车，不强行处理患者肢体
↓
Scene 7
解释流程、等待患者自己解除抵抗
↓
Scene 8
成功进入 OR 并完成正式 handoff
↓
Scene 9
坂口确认她处理得很好
↓
Scene 10
弘子点出真正值得肯定的地方
↓
Relationship Lv2
```

---

# 3. Tone

整体必须同时成立：

```text
physical comedy
+
patient fear
+
professional nursing
+
character growth
```

不能写成：

```text
患者被当成笑料
护士集体嘲笑患者
医护强行掰开患者双腿
众人合力把床硬推过去
```

核心喜剧画面可以很好笑。

但：

> **皐月在患者仍然害怕的时候，不笑。**

笑点主要来自：

```text
“床为什么推不动？”
↓
“不是床卡住了。”
↓
“是患者卡住了。”
```

以及患者恢复以后自己也能意识到场面荒谬。

---

# 4. Patient Setup

患者必须明确为：

```yaml
adult: true
sex: female
medical_staff: false
first_or_entry_or_low_or_familiarity: true
conscious: true
not_fixed: true
anesthesia_not_started: true
```

当前正式事件患者为 **二阶堂赖子 / Yoriko Nikaido，24 岁成年女性**。她平时戴圆框眼镜，但进入手术部前已经取下并存入个人物品盒；Holding、转运、手术室门口和交接阶段均不得显示眼镜。她的女警身份只用于增强自我壮胆、风险防线和事后挽回体面的说话方式，不改变事件的医疗结构，事件主角仍为折川皐月。

患者并未撤回既有手术 consent。

她的问题是：

> **到了 OR 门槛，恐惧突然变成身体性的抵抗。**

不是重新设计 refusal / consent withdrawal system。

推荐患者状态：

```text
Fear: high
Pain: low
Dignity: normal-to-moderately-low
Cooperation: normally adequate
```

她不是敌意、不合作型患者。

---

# 5. Visual / CG Direction

## Key CG — `cg_satsuki_lv2_or_door_brace`

横向三分之四正面构图。摄影机位于手术室内，向外看走廊，确保观众明确理解患者是在拒绝**进入**手术室。

画面应清楚表现：

```text
近景 / 摄影机侧
→ 手术室器械台、麻醉设备或无影灯边缘

门外 / 画面后方
→ 普通医院走廊
→ 皐月仍在走廊一侧、位于床头或床侧
→ 她不戴口罩，已解开的口罩挂在颈前 / 胸前

中央
→ 成年女患者躺在转运床上
→ 手术帽已戴好
→ 眼镜已经收进个人物品盒
→ 锁骨与双肩裸露，覆盖单上缘固定在上胸，乳房与腋下完全遮盖
→ 因惊慌半坐起或抬起上身

关键动作
→ 患者两腿突然向左右撑开
→ 赤脚；两只脚分别死死顶住手术室入口两侧
→ 转运床已经进入一部分，但就是推不进去
```

重点：

> 一眼能理解“不是车坏了，是患者自己把自己卡在门口”。

患者可以因为术前状态裸露锁骨、双肩和赤脚，但：

```text
不要把构图做成色情特写
不要让门框压迫脚踝
不要画成暴力拖拽
```

喜剧来自身体语言与流程反差。

---

# 6. Scene 1 — 妇科护士站 / 轮转申请

### S001 — Narration

下班前，皐月站在护士站边缘。

手里那张申请表已经被她翻过很多次。

Saber 从旁边经过，又走回来。

### S002 — Saber

> 「你已经看那张纸很久了。」

### S003 — Satsuki

> 「……有这么明显吗？」

### S004 — Saber

> 「明显。」

皐月推了一下黑框眼镜。

### S005 — Satsuki

> 「我只是在考虑……要不要真的交出去。」

### S006 — Saber

> 「围术期护理轮转？」

皐月没有立刻回答。

### S007 — Satsuki

> 「我以前其实很想做手术室护士。」

### S008 — Saber

> 「我知道。」

### S009 — Satsuki

> 「……你知道？」

### S010 — Saber

> 「你提到杉村的时候，眼睛和提到其他护士的时候不一样。」

皐月脸红。

### S011 — Satsuki

> 「弘子前辈真的很厉害。」
>
> 「患者害怕的时候，她知道什么时候要说话。」
>
> 「医生忙的时候，她又知道什么时候不能打断。」
>
> 「出了问题也不会慌。」

### S012 — Satsuki

> 「我以前想……我也想成为那种护士。」

### S013 — Saber

> 「然后你去了妇科。」

皐月的肩膀缩了一点。

### S014 — Satsuki

> 「因为……手术部男性医生太多了。」

### S015 — Saber

> 「嗯。」

### S016 — Satsuki

> 「不要这么平静地接受啊！听起来更丢脸了！」

### S017 — Saber

> 「这是你自己的理由。」
>
> 「我没有资格替你觉得丢脸。」

皐月安静下来。

### S018 — Satsuki

> 「可是最近我在想……」
>
> 「如果我每一次紧张，都选择躲开那个地方。」
>
> 「那我永远也不会知道，我到底能不能做好。」

她看看申请表。

### S019 — Satsuki

> 「……陪我去一次。」

### S020 — Saber

> 「哪里？」

### S021 — Satsuki

> 「石神护士长那里。」

---

# 7. Scene 2 — 护理部 / 石神批准轮转

石神坐在办公桌后。

Saber 只是陪同，不替皐月说话。

### S022 — Ishigami

> 「你想申请围术期轮转。」

### S023 — Satsuki

> 「是、是的。」

### S024 — Ishigami

> 「为什么？」

皐月准备好的答案卡了一下。

### S025 — Satsuki

> 「因为我想成为更好的护士。」

### S026 — Ishigami

> 「那是答案。」
>
> 「不是理由。」

皐月下意识推眼镜。

### S027 — Satsuki

> 「……我以前想去外科。」
>
> 「后来因为自己的问题，去了妇科。」

### S028 — Satsuki

> 「我喜欢现在的工作。」
>
> 「可是我发现，我一直没有真正放下那个想法。」

石神看向 Saber。

### S029 — Ishigami

> 「你带她来，是替她担保？」

### S030 — Saber

> 「不是。」

皐月下意识转头。

### S031 — Satsuki

> 「诶？」

### S032 — Saber

> 「她让我陪她来。」
>
> 「申请是她自己的。」

石神重新看向皐月。

停顿。

### S033 — Ishigami

> 「可以。」

### S034 — Satsuki

> 「……诶？」

### S035 — Ishigami

> 「从基础轮转开始。」
>
> 「Holding。」
>
> 「患者转运。」
>
> 「术前交接。」
>
> 「暂时不进入器械岗位。」

### S036 — Satsuki

> 「是！」

### S037 — Ishigami

> 「折川。」

### S038 — Satsuki

> 「是！」

### S039 — Ishigami

> 「不要因为紧张，就假装自己听懂了。」

### S040 — Ishigami

> 「不知道就问。」
>
> 「做不到就说。」

### S041 — Ishigami

> 「患者出了问题，比你觉得丢脸严重得多。」

皐月慢慢点头。

### S042 — Satsuki

> 「……我明白。」

### S043 — Ishigami

> 「那就去做。」

---

# 8. Scene 3 — 轮转开始

### S044 — Narration

几天后。

皐月第一次穿着手术部 scrub，以轮转护士身份站在 Holding。

黑框眼镜还在。

她比平时更频繁地推镜框。

但她做事没有乱。

### S045 — Narration

第一名患者。

身份核对。

转运。

交接。

完成。

### S046 — Narration

第二名患者。

同样顺利。

没有事故。

没有特别事件。

只有一条条真正完成的工作。

### S047 — Narration

第三名是一名成年女患者。

她已经完成术前准备，头发完全收进手术帽，躺在转运床上，患者袍与手术单覆盖身体。

她一直努力表现得比实际更镇定。

---

# 9. Scene 4 — Holding 核对

### S048 — Satsuki

> 「我再确认一次。」
>
> 「姓名？」

### S049 — Patient

> 「{patient_name}。」

### S050 — Satsuki

> 「今天接受的是{procedure_display_name}。」

### S051 — Patient

> 「嗯。」

### S052 — Satsuki

> 「药物过敏？」

### S053 — Patient

> 「没有。」

皐月完成核对。

### S054 — Patient

> 「护士小姐。」

### S055 — Satsuki

> 「嗯？」

### S056 — Patient

> 「我是不是看起来特别紧张？」

皐月愣了一下。

她没有条件反射地说“不紧张”。

### S057 — Satsuki

> 「……有一点。」

患者看着她。

### S058 — Patient

> 「你还真说啊。」
>
> 「我平时都是安慰别人别紧张的……今天好像不太管用。」

### S059 — Satsuki

> 「对、对不起！」

患者忍不住笑了一下。

### S060 — Patient

> 「没关系。」
>
> 「至少比骗我说‘一点都看不出来’好。」

皐月也放松一点。

### S061 — Satsuki

> 「我会送你到里面。」
>
> 「交接完成以前，我都在。」

### S062 — Patient

> 「嗯。」

---

# 10. Scene 5 — OR Doorway

转运床沿走廊向 OR 前进。

坂口从更衣区方向过来，正准备进入同一间手术室。

### S063 — Sakaguchi

> 「折川。」

皐月肩膀明显僵了一下。

### S064 — Satsuki

> 「坂、坂口先生！」

患者抬眼看他。

### S065 — Patient

> 「主刀医生？」

### S066 — Sakaguchi

> 「嗯。」

患者盯着他看了两秒。

然后重新躺平。

### S067 — Patient

> 「……突然更紧张了。」

### S068 — Satsuki

> 「为什么看到医生反而更紧张啊……」

OR 自动门打开。

门内的光比走廊亮。

能看到：

```text
无影灯
手术台
麻醉机
准备中的工作人员
```

皐月继续缓慢推床。

患者看见里面。

表情瞬间发生变化。

### S069 — Patient

> 「……等一下。」

皐月没有听清。

### S070 — Satsuki

> 「什么？」

床继续往前一点。

### S071 — Patient

> 「等一下、等一下——我听人说进去以后，大家就只管准备，患者想说话都找不到空隙——是真的？！」

**咚。**

整张床突然停住。

---

# 11. Scene 6 — “床卡住了？”

皐月下意识低头看轮子。

### S072 — Satsuki

> 「……？」

她试着再推一点。

完全不动。

### S073 — Patient

> 「不要推了——！！」

皐月立刻松力。

坂口从侧面往前看。

镜头切至 Key CG。

患者已经半坐起。

两条腿向左右张开。

两只脚分别死死顶住手术室入口两边。

整个患者像一根人体门闩一样，把自己和转运床卡在门口。

皐月：

> 「…………」

### S074 — Sakaguchi

> 「床没卡住。」

皐月看看轮子。

再看看患者。

### S075 — Satsuki

> 「……是患者卡住了。」

### S076 — Patient

> 「我听得见！！」

这里允许一个很短的喜剧停顿。

**不要让旁边医护笑出声。**

---

# 12. Scene 7 — 皐月停下来

皐月本能地想把床往回拉一点。

她的手已经碰到床栏。

然后停住。

她没有去碰患者的腿。

也没有说：

> 「请配合。」

她绕到患者能够直接看见的位置。

### S077 — Satsuki

> 「好。」
>
> 「我们先不进去。」

患者仍然死死撑着门。

### S078 — Patient

> 「……真的？」

### S079 — Satsuki

> 「真的。」

后面的工作人员全部停下来。

没有人继续推床。

患者喘了几口气。

### S080 — Patient

> 「我知道已经同意了。」
>
> 「我也知道今天要做。」

### S081 — Patient

> 「刚才在病房的时候，我还觉得自己没问题。」

她看向手术室里面。

### S082 — Patient

> 「可是门一开……」
>
> 「看到那个灯……」
>
> 「突然就觉得——」

她的脚又更用力顶了一下门框。

### S083 — Patient

> 「我真的要被推进去了。」

皐月安静几秒。

### S084 — Satsuki

> 「嗯。」

### S085 — Patient

> 「……‘嗯’是什么意思？」

### S086 — Satsuki

> 「就是……我觉得这很正常。」

患者狐疑地看她。

### S087 — Satsuki

> 「我们每天看这个门。」
>
> 「所以会忘记它看起来是什么样子。」

### S088 — Satsuki

> 「可是你今天第一次从这里进去。」

---

# 13. Scene 8 — Explain the Next Thirty Seconds

### S089 — Satsuki

> 「不用现在马上把脚放下来。」

患者明显愣住。

### S090 — Satsuki

> 「我先告诉你进去以后会发生什么。」

### S091 — Patient

> 「……好。」

皐月指向门内，但不催她看。

### S092 — Satsuki

> 「进去以后，床会先停在手术台旁边。」

### S093 — Satsuki

> 「我们会再核对一次姓名、术式和腕带。」

### S094 — Satsuki

> 「然后才帮你移动到手术台。」

### S095 — Satsuki

> 「不会一进去就突然开始麻醉。」
>
> 「也不会有人什么都不说就动你。」

患者慢慢听着。

### S096 — Patient

> 「你呢？」

### S097 — Satsuki

> 「我？」

### S098 — Patient

> 「你会走吗？」

皐月愣了一下。

### S099 — Satsuki

> 「交接结束以前，我不会走。」

患者盯着她看。

几秒以后。

左脚慢慢从门框放下来。

皐月仍然没有动床。

### S100 — Patient

> 「……你怎么不推？」

### S101 — Satsuki

> 「还有一只。」

患者看向自己仍然死死顶在另一侧的右脚。

停顿。

### S102 — Patient

> 「……这只脚是保险。总要留一道防线吧。」

坂口稍微偏开脸。

不是嘲笑，只是在忍住笑意。

### S103 — Satsuki

> 「那……防线什么时候解除？」

### S104 — Patient

> 「再给我三秒。」

### S105 — Satsuki

> 「好。」

Narration：

> 一秒。
>
> 两秒。
>
> 三秒。

右脚终于慢慢收回来。

### S106 — Patient

> 「你不能突然猛推哦。」

### S107 — Satsuki

> 「不会。」

皐月重新回到床尾。

这一次，她真的只推了一点点。

床越过门槛。

患者没有再伸脚。

---

# 14. Scene 9 — OR Handoff

转运床在手术台旁停稳。

弘子过来接应。

皐月开始正式交接。

她的声音开头还有一点紧。

但信息完整。

### S108 — Satsuki

> 「成年女性，{patient_name}。」
>
> 「腕带已核对。」
>
> 「今日予定：{procedure_display_name}。」
>
> 「无已知药物过敏。」
>
> 「术前准备已完成。」

### S109 — Hiroko

> 「刚才在门口停了一会儿？」

患者抢先：

### S110 — Patient

> 「是床卡住了。」

坂口：

### S111 — Sakaguchi

> 「不是。」

### S112 — Patient

> 「医生！」

皐月低头。

这一次她终于忍不住露出一点笑。

弘子看向皐月。

### S113 — Hiroko

> 「哪里卡住了？」

皐月看了一眼患者。

患者已经主动把双脚往单子里缩了一点。

### S114 — Satsuki

> 「……患者。」

### S115 — Patient

> 「我已经进来了嘛……」

弘子没有追问。

只笑了一下。

### S116 — Hiroko

> 「嗯。」
>
> 「进来了就好。」

然后她重新看向皐月。

### S117 — Hiroko

> 「交接完整。」
>
> 「辛苦了。」

皐月明显松了一口气。

---

# 15. Scene 10 — OR Corridor / 坂口确认

患者进入下一阶段准备后。

皐月站在 OR 外走廊。

整个人看起来像刚自己做完了一台手术。

坂口出来。

### S118 — Sakaguchi

> 「折川。」

皐月马上站直。

### S119 — Satsuki

> 「是！」

### S120 — Sakaguchi

> 「处理得很好。」

皐月怔住。

### S121 — Satsuki

> 「……我？」

### S122 — Sakaguchi

> 「嗯。」

### S123 — Satsuki

> 「可是我一开始还以为轮子坏了。」

### S124 — Sakaguchi

> 「后来发现不是。」

### S125 — Satsuki

> 「然后患者还卡在门上。」

### S126 — Sakaguchi

> 「你也没跟床较劲。」

皐月脑中显然出现了“自己在后面拼命推、患者在前面拼命撑”的画面。

脸色一变。

### S127 — Satsuki

> 「……那会很糟糕。」

### S128 — Sakaguchi

> 「所以你停了。」

皐月安静下来。

### S129 — Satsuki

> 「我其实……知道那是什么感觉。」

### S130 — Sakaguchi

> 「什么？」

### S131 — Satsuki

> 「脑子已经知道自己应该做。」
>
> 「别人也都在等。」
>
> 「可是身体就是动不了。」

她推了一下眼镜。

### S132 — Satsuki

> 「以前我遇到这种时候，只会觉得自己没用。」

### S133 — Satsuki

> 「所以刚才看到她那个样子……」
>
> 「我突然觉得，如果有人还在推，她大概只会越来越害怕。」

坂口：

### S134 — Sakaguchi

> 「那你很适合做这份工作。」

皐月抬头。

### S135 — Satsuki

> 「……诶？」

### S136 — Sakaguchi

> 「因为你知道什么时候该继续。」
>
> 「也知道什么时候该先停。」

皐月看着他。

仍然会紧张。

仍然会脸红。

但这一次没有马上避开视线。

### S137 — Satsuki

> 「坂口先生。」

### S138 — Sakaguchi

> 「嗯？」

### S139 — Satsuki

> 「以后……如果我真的去手术部工作……」

停顿。

### S140 — Satsuki

> 「我觉得我可以在你旁边正常工作。」

### S141 — Sakaguchi

> 「今天不是已经做到了吗？」

皐月怔了几秒。

低下头笑了一下。

### S142 — Satsuki

> 「……好像是。」

---

# 16. Scene 11 — Hiroko Tag

皐月离开以后。

弘子从 OR 门里出来。

### S143 — Hiroko

> 「第一次正式轮转就碰到这种患者。」

### S144 — Sakaguchi

> 「运气不错。」

弘子看他。

### S145 — Hiroko

> 「你这个‘不错’，是从谁的角度说的？」

### S146 — Sakaguchi

> 「从折川的。」

弘子笑了一下。

### S147 — Hiroko

> 「嗯。」

她看向手术室门。

### S148 — Hiroko

> 「刚才她做对了一件很重要的事。」

### S149 — Sakaguchi

> 「停下来？」

### S150 — Hiroko

> 「不是。」

停顿。

### S151 — Hiroko

> 「她没觉得那个患者很好笑。」

坂口回头看她。

### S152 — Hiroko

> 「我们当然会觉得好笑。」
>
> 「两只脚顶着门，谁看都会想笑。」

弘子自己也轻轻笑了一下。

### S153 — Hiroko

> 「可是在患者把脚放下来以前，她没有笑。」

弘子重新走进 OR。

---

# 17. Relationship Settlement

完成：

```text
satsuki_relationship_level = 2
satsuki_or_rotation_unlocked = true
satsuki_successful_patient_transport = true
satsuki_lv2_patient_transport_complete = true
```

推荐 UI：

```text
折川皐月 Relationship Lv2
```

关系意义：

> **“我可以在坂口先生身边正常工作。”**

---

# 18. Sunday Date Continuity

本事件完成后：

```text
Sunday Date invite = allowed
accept chance = low / under 50%
```

原因不是：

```text
欲擒故纵
恋爱游戏难度
```

而是：

> 她已经能在坂口身边正常工作，但“工作以外、只有两个人”依然是另一回事。

拒绝不扣关系。

---

# 19. Lv3 Foreshadowing / Contrast

这个事件必须成为 Lv3《我送错了人》的前置反差。

Lv2 玩家已经亲眼看见：

```text
皐月认真核对
皐月能完成 transport
皐月知道什么时候暂停流程
皐月理解患者情绪
皐月能够完整 handoff
```

因此 Lv3 的 wrong-patient chain 才不能读成：

> “这个护士就是粗心。”

而应该读成：

> **认真、谨慎、已经证明自己能够做好这份工作的皐月，仍然可能在多节点错误假设链中犯下严重错误。**

这也是 Lv3 对她打击如此严重的原因。

---

# 20. Do Not Change

本事件不要改成：

```text
患者撤回 consent
患者取消手术
坂口出面“说服患者”
Saber 替皐月向石神求情
石神亲自推床
弘子替皐月完成主要安抚
强行掰开患者双腿
多人合力把患者推进 OR
患者因被嘲笑而服从
皐月突然完全不怕坂口
```

皐月的成长不是：

> “从此不紧张。”

而是：

> **“我紧张，但我仍然能把工作做好。”**

---

# 21. Core Image

这个事件最后应该留给玩家的记忆不是一句大道理。

而是：

> **一名已经被推进手术室一半的成年女患者，突然用两只脚死死顶住门框；年轻护士一开始以为床坏了，随后发现真正需要处理的不是床，而是患者的恐惧。**

这就是皐月 Lv2。

# END
