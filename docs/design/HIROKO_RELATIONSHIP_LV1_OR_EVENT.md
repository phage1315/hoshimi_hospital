# 杉村弘子 Relationship Lv1 Event Chain
## 《别让她看见》→《值得的事情》
### Codex 实现规格

> 项目：Hoshimi Hospital  
> 角色：杉村弘子 / 本庄萌恵 / 主角 / 成年女患者  
> 类型：Relationship Milestone / OR Event / Mentor Event  
> 目标关系等级：Hiroko Lv1  
> 说明：杉村弘子的“相识事件”已经存在，本文件只负责 Lv1 关系推进，不重复介绍角色。

---

# 1. 事件定位

本事件链用于完成以下人物塑造：

1. 让玩家第一次真正看到杉村弘子作为资深护士的临场能力。
2. 强化她“先照顾患者，再教育新人”的职业原则。
3. 展示她对后辈耐心、负责、不会公开羞辱新人的一面。
4. 展示她总是在照顾别人，却容易忽视自己疲劳的长期人物主题。
5. 让本庄萌恵的“缺根筋但没有恶意”得到具体表现。
6. 给本庄后续手术室行为留下永久 callback。
7. 关系提升主要体现 Trust / Respect / Familiarity，Affection 只少量增加。
8. 本事件不是恋爱高潮，不要写成明显调情事件。

核心主题：

> **“我们每天会进很多次手术室，但对躺在台上的患者来说，也许一辈子只有这一次。”**

---

# 2. 事件链结构

```text
Lv0 已认识弘子
↓
Event A：《别让她看见》
↓
flag: hiroko_lv1_part1_complete
↓
第二天访问护士站
↓
Event B：《值得的事情》
↓
Hiroko Relationship Lv1
↓
解锁：
- hiroko_or_interactions_tier1
- hiroko_mentor_micro_events
- moe_training_callbacks
- hiroko_team_invite
```

> 当前实装修正（2026-10-04）：弘子完成正式相识后，Lv0／Fam0 即可进入手术团队候选。`hiroko_team_invite` 仅作为旧存档兼容的幂等历史标记，不再是首次邀请资格的前置条件。

---

# 3. Event A：《别让她看见》

## 3.1 推荐 ID

```text
hiroko_lv1_or_instrument_panic
```

## 3.2 触发条件

```text
met_hiroko = true
met_moe = true
hiroko_relationship_level = 0
location = operating_room
time >= 13:00
event_not_seen = hiroko_lv1_or_instrument_panic
```

可选附加条件：

```text
completed_surgeries >= 1
```

避免主角完全没有 OR 经验时过早触发。

## 3.3 患者设定

本事件患者必须明确为成年人。

推荐：

```text
age = 22
adult = true
conscious = true
general_anesthesia_not_started = true
catheter_not_inserted = true
patient_mobile = true
```

患者已在手术台上，但还处于全麻前准备阶段。

## 3.4 场景角色

```text
player
hiroko
moe
adult_female_patient
```

杉村弘子定位：

```text
senior_or_nurse
```

本庄萌恵定位：

```text
junior_scrub_nurse
```

---

# 4. Event A 完整脚本

## A001
**narrator**

下午的手术室已经准备得差不多了。无影灯亮着，二十二岁的年轻女患者躺在手术台上，手术帽完全包住头发，身上盖着手术单。她还没有进入全身麻醉，目光紧张地在房间里四处游移。

## A002
**narrator**

另一边，本庄萌恵正兴致勃勃地整理器械台。金属器械一件接一件排开，在手术灯下反着冷光。

## A003
**moe**

「好……手术刀、剪刀、止血钳、牵开器……这一组也放这里比较顺手。」

## A004
**patient**

「……护士小姐。」

## A005
**moe**

「嗯？」

## A006
**patient**

「那些……都是等一下要用的吗？」

## A007
**narrator**

本庄低头看看摆得满满的器械台，很认真地点头。

## A008
**moe**

「是啊。你今天这个术式比较大，所以会准备得多一点。」

## A009
**patient**

「多……一点？」

## A010
**moe**

「嗯。刀子会换几把，剪刀也有好几种，这边这些钳子——」

## A011
**hiroko**

「萌恵。」

## A012
**narrator**

弘子的声音从她身后响起。

## A013
**moe**

「嗯？杉村前辈？」

## A014
**narrator**

患者却已经完全移不开视线。她看着器械台上一排又一排金属器械，脸色一点点发白。

## A015
**patient**

「等、等等……这些刀子、剪子、钳子……」

## A016
**patient**

「等一下……全部都会用在我身上吗？」

## A017
**narrator**

本庄毫无恶意地露出笑容。

## A018
**moe**

「大部分都会吧。毕竟是开腹手术嘛。」

## A019
**hiroko**

「萌恵！」

## A020
**patient**

「开、开腹……」

## A021
**narrator**

患者猛地想坐起来。

## A022
**patient**

「不要！我不要了！我不要做了！」

## A023
**narrator**

监护仪上的心率骤然往上跳。她慌乱地挣动了一下，手术单随之滑动，弘子立刻上前替她重新盖好。

## A024
**patient**

「等一下、我要下去……让我回病房……！」

## A025
**moe**

「哎？可是都已经准备好了——」

## A026
**hiroko**

「萌恵，先别说话。」

## A027
**narrator**

弘子没有提高声音，却让本庄立刻闭上了嘴。

## A028
**narrator**

下一秒，患者身体突然僵住。她像是意识到了什么，惊恐的表情瞬间又变成羞耻。

## A029
**patient**

「……啊。」

## A030
**patient**

「不、不要看……」

## A031
**narrator**

手术单下传来一阵窘迫的动静。她因为过度惊恐，在尚未导尿的情况下失禁了。

## A032
**patient**

「对不起……对不起……我不是故意的……」

## A033
**moe**

「啊……！」

## A034
**hiroko**

「没关系。」

## A035
**narrator**

弘子几乎没有停顿。她先把患者露出的部分重新遮严，又示意拿来干净的垫单。

## A036
**hiroko**

「你没有做错任何事。只是太紧张了。」

## A037
**patient**

「可是……大家都……」

## A038
**hiroko**

「大家都是医护人员。」

## A039
**hiroko**

「这种情况不是第一次，也绝不会是最后一次。」

## A040
**narrator**

她说得很平静，像是在陈述最普通不过的事实。

## A041
**hiroko**

「先把这边收拾好。你不用动。」

## A042
**patient**

「……嗯。」

## A043
**hiroko**

「医生，她现在已经没办法靠自己平静下来了。」

## A044
**player**

「按术前医嘱给镇静吧。」

## A045
**hiroko**

「明白。」

## A046
**narrator**

弘子确认药物与患者信息后，经静脉通路给入术前镇静药。

> 实现要求：这里只作为剧情描述，不建立真实剂量或药理计算。

## A047
**hiroko**

「会稍微有点困。什么都不用想，慢慢呼吸就好。」

## A048
**patient**

「……那些刀子……」

## A049
**hiroko**

「不要看那边。」

## A050
**hiroko**

「看着我。」

## A051
**narrator**

患者紧紧盯着弘子的眼睛。几次急促呼吸以后，肩膀终于慢慢松了下来。

## A052
**patient**

「……杉村护士。」

## A053
**hiroko**

「我在。」

## A054
**patient**

「等我睡着以后……才会开始，对吧？」

## A055
**hiroko**

「对。」

## A056
**hiroko**

「你睡着以前，没有人会动刀。」

## A057
**narrator**

患者轻轻点头。她的眼皮开始变沉。

## A058
**patient**

「那……不要再让我看到那些了……」

## A059
**hiroko**

「好。」

## A060
**narrator**

直到患者终于安静下来，弘子才转过身。

## A061
**narrator**

本庄已经把器械台默默往旁边推了半步，脸上的兴奋早就消失得无影无踪。

## A062
**moe**

「杉村前辈……对不起。」

## A063
**hiroko**

「你为什么道歉？」

## A064
**moe**

「因为……是我把她吓成这样的。」

## A065
**hiroko**

「你没有说错。」

## A066
**narrator**

本庄抬起头。

## A067
**hiroko**

「问题就是你说得太对了。」

## A068
**moe**

「……咦？」

## A069
**narrator**

弘子走到器械台旁，把它彻底推离患者醒着时能够看到的位置。

## A070
**hiroko**

「对我们来说，这些只是每天都会碰到的器械。」

## A071
**hiroko**

「对躺在那里的人来说，每一把都代表『等一下可能会发生在自己身上的事情』。」

## A072
**narrator**

本庄低头看了一眼手术刀。

## A073
**hiroko**

「患者还清醒的时候，不要把整个器械台摆进她视线里。」

## A074
**hiroko**

「尤其是大手术。」

## A075
**moe**

「……明白了。」

## A076
**hiroko**

「还有。」

## A077
**moe**

「是。」

## A078
**hiroko**

「患者问『这些是不是都会用在我身上』的时候——」

## A079
**narrator**

弘子忍不住轻轻叹气。

## A080
**hiroko**

「不要一脸开心地回答『是啊』。」

## A081
**moe**

「……是。」

---

# 5. Event A 玩家选择

## Choice A — 打趣本庄

```text
id = tease_moe
```

**label**

「这个可能比器械清点还难教。」

**response**

本庄：「医生！」

弘子终于笑了一下。

**effects**

```text
hiroko_trust +1
hiroko_familiarity +2
moe_familiarity +1
```

## Choice B — 称赞弘子的处理

```text
id = praise_hiroko
```

**label**

「刚才你处理得很稳。」

**response**

弘子微微一怔，随后摇了摇头。

「先把患者照顾好，本来就是我们的工作。」

**effects**

```text
hiroko_respect +3
hiroko_trust +2
```

## Choice C — 鼓励本庄

```text
id = encourage_moe
```

**label**

「记住这次就好。下次你会处理得更好。」

**response**

本庄认真地点头。

「……嗯。下次我一定先想想患者看到的是什么。」

弘子看了主角一眼，没有说话，但神情明显缓和。

**effects**

```text
hiroko_respect +2
hiroko_trust +1
moe_trust +2
```

---

# 6. Event A 固定结尾

**hiroko**

「慢慢来吧。」

**narrator**

她重新检查了一遍患者的被单与体位。

**hiroko**

「先把患者照顾好，再把手术做漂亮。」

**hiroko**

「手术室护士，两件事都不能忘。」

设置：

```text
hiroko_lv1_part1_complete = true
hiroko_lv1_part1_day = current_day
moe_or_training_incident = true
hiroko_mentor_side_seen = true
```

不要在这里直接升到 Lv1。

建议基础效果：

```text
hiroko_trust += 2
hiroko_respect += 3
hiroko_familiarity += 1
```

再叠加玩家选择效果。

---

# 7. Event B：《值得的事情》

## 7.1 推荐 ID

```text
hiroko_lv1_worth_it
```

## 7.2 触发条件

```text
hiroko_lv1_part1_complete = true
current_day >= hiroko_lv1_part1_day + 1
location = nurses_station
event_not_seen = hiroko_lv1_worth_it
```

推荐时间：

```text
09:00–17:00
```

---

# 8. Event B 完整脚本

## B001
**narrator**

第二天经过护士站时，主角看见弘子一个人坐在交班记录前。

## B002
**narrator**

她手边放着一杯已经凉掉的咖啡，眼下有一点浅浅的疲色。

## B003
**player**

「昨天那台患者怎么样了？」

## B004
**hiroko**

「醒得很顺利。今天早上还特地跟我道歉。」

## B005
**player**

「她为什么要道歉？」

## B006
**hiroko**

「因为昨天的事。」

## B007
**player**

「那又不是她的错。」

## B008
**hiroko**

「我也这么告诉她了。」

## B009
**player**

「昨天你处理得很好。」

## B010
**hiroko**

「……突然这么说什么？」

## B011
**player**

「患者失控的时候，你一下就把场面稳住了。」

## B012
**player**

「本庄也没被你骂到抬不起头。」

## B013
**hiroko**

「她又不是故意的。」

## B014
**hiroko**

「萌恵只是……有时候会忘记，自己知道的东西，患者并不知道。」

## B015
**player**

「你昨天还在手术结束以后教她？」

## B016
**hiroko**

「嗯。」

## B017
**player**

「所以才这么困？」

## B018
**hiroko**

「一点点而已。」

## B019
**player**

「你的『一点点』通常不太可信。」

## B020
**narrator**

弘子轻轻笑了一下。

## B021
**hiroko**

「昨天她留下来，把整套术前流程重新走了一遍。」

## B022
**hiroko**

「包括器械车应该停在哪里、患者醒着的时候什么东西不要进入她的视野，还有怎么回答患者的问题。」

## B023
**player**

「到几点？」

## B024
**hiroko**

「……没多晚。」

## B025
**player**

「杉村。」

## B026
**narrator**

弘子移开视线。

## B027
**hiroko**

「十一点多。」

## B028
**player**

「果然。」

## B029
**hiroko**

「可是她学会了。」

## B030
**narrator**

弘子的声音虽然带着疲惫，却明显有一点满足。

## B031
**hiroko**

「新人犯错不可怕。」

## B032
**hiroko**

「最怕的是没人告诉她为什么错。」

## B033
**player**

「你很喜欢照顾后辈。」

## B034
**hiroko**

「……是吗？」

## B035
**player**

「患者也是。」

## B036
**player**

「昨天那种场面，换个人可能先想着怎么把手术按时做下去。」

## B037
**player**

「你先想到的是她有多害怕。」

## B038
**narrator**

弘子沉默了几秒。

## B039
**hiroko**

「因为躺在台上的人，只有那一个。」

## B040
**hiroko**

「我们一天可能进很多次手术室。」

## B041
**hiroko**

「可是对她来说，也许一辈子就只有这一次。」

## B042
**narrator**

她揉了揉有些发酸的眼角。

## B043
**hiroko**

「所以……累一点也没关系。」

## B044
**hiroko**

「这些女孩子能慢慢变成可靠的护士，患者也能平平安安回家……」

## B045
**narrator**

弘子露出一个有些疲倦，却很温柔的笑容。

## B046
**hiroko**

「我觉得都是值得的。」

---

# 9. Event B 玩家选择

## Choice A — 职业敬重路线

```text
id = everyone_relies_on_you
```

**label**

「所以大家才会依赖你。」

**response**

弘子怔了一下。

「被依赖可不一定全是好事。」

她嘴上这样说，表情却明显柔和了一点。

**effects**

```text
hiroko_respect +3
hiroko_trust +2
hiroko_familiarity +1
```

## Choice B — 私人关心路线

```text
id = someone_should_care_for_you
```

**label**

「但是你也得有人照顾。」

**response**

弘子像是没想到主角会这样回答，短暂地沉默了一下。

「……你最近是不是越来越会说这种话了？」

**effects**

```text
hiroko_trust +2
hiroko_affection +2
hiroko_familiarity +2
```

说明：这是 Lv1 中允许出现的少量私人情感，不要写成明显告白或暧昧高潮。

## Choice C — 前辈认可路线

```text
id = moe_is_lucky
```

**label**

「本庄碰到你这种前辈算她走运。」

**response**

弘子轻轻摇头。

「她愿意听、愿意改，才最重要。」

**effects**

```text
hiroko_respect +2
hiroko_trust +1
hiroko_familiarity +2
moe_trust +1
```

---

# 10. Event B 固定结尾

**player**

「那至少把咖啡换成热的。」

**narrator**

弘子低头看了一眼杯子。

**hiroko**

「……什么时候凉的？」

**player**

「这就是我说的问题。」

**hiroko**

「又来了。」

**narrator**

她嘴上抱怨着，却没有拒绝主角从她手里拿走那杯冷咖啡。

---

# 11. Lv1 升级

Event B 结束时：

```text
hiroko_relationship_level = 1
hiroko_lv1_complete = true
```

解锁：

```text
hiroko_or_interactions_tier1 = true
hiroko_mentor_micro_events = true
moe_training_callbacks = true
hiroko_team_invite = true
```

`hiroko_team_invite` 不再负责解锁首次组队；执行层以正式相识状态为准。保留该 flag 只为兼容已完成 Lv1 的旧存档。

推荐最低数值变化：

```text
hiroko_trust += 2
hiroko_respect += 2
hiroko_familiarity += 1
```

再叠加 Choice A / B / C 的 effects。

---

# 12. Gameplay 解锁含义

Lv1 以后，弘子不再只是“医院中认识的资深护士”。

她进入：

> **可以稳定合作、可以主动邀请进入手术团队的职业伙伴状态。**

推荐允许：

```text
invite_hiroko_as_scrub_nurse
invite_hiroko_as_circulating_nurse
```

具体资格按现有角色系统决定。

---

# 13. 本庄永久 Callback

本事件必须留下至少一条未来回收。

条件示例：

```text
moe_training_callbacks = true
moe is scrub_nurse
patient_conscious = true
instrument_table_visible_to_patient = true
```

## Callback A

**narrator**

本庄推着器械台走了两步，忽然像想起了什么。

她停下来，绕了个方向，把器械台移到患者视线之外。

**hiroko（若在场）**

「记得了？」

**moe**

「……当然记得。」

弘子没有再说什么，只轻轻笑了一下。

若弘子不在场：

**moe**

「这个位置应该看不到了……嗯，这样比较好。」

不要弹出教学说明。玩家应自行意识到她记住了之前发生的事情。

---

# 14. 可选第二 Callback：患者再次询问器械

条件：

```text
moe_training_callbacks = true
patient asks about instruments
```

过去的本庄会详细说明器械。

现在改为：

**moe**

「这些是我们需要准备的东西。」

她停了一下。

「不过你现在不用一个个想它们会怎么用。等下睡着以前，我们会一直陪着你。」

目的：

> 体现人物行为发生了永久变化。

---

# 15. 与弘子长期角色线的关系

本 Lv1 只负责建立：

```text
Professional Respect
Trust
Mentor Identity
```

不要提前完成：

```text
明显恋爱关系
私人脆弱完全暴露
高强度依赖
成人关系
```

推荐长期递进：

```text
Lv0
认识“可靠的杉村护士”

Lv1
理解她为什么值得信赖

Lv2
发现她总是照顾别人，却很少照顾自己

Lv3
她开始允许主角看见疲惫和私人情绪

Lv4
私人关系明确深化

Lv5
她真正允许自己成为被照顾的一方
```

---

# 16. Codex 实现要求

1. 患者明确为成年人。
2. 失禁事件以恐惧、混乱、羞耻与护理表现，不做 fetish 化特写。
3. 弘子第一反应是遮盖患者、稳定患者情绪、恢复秩序。
4. 不要让弘子当着患者的面长时间训斥本庄。
5. 本庄不是坏人，也不是故意吓患者；她是真诚、兴奋、经验不足、缺少患者视角。
6. 弘子的教育核心不是“不能说实话”，而是：
   > 医护知道的事实，不应该毫无过滤地变成患者的恐惧。
7. 第二天事件必须表现弘子疲劳，但她本人不抱怨。
8. Lv1 的情感主色是 Respect / Trust / Professional Admiration。
9. 不要把 Event B 写成约会。
10. Event A 结束后不直接升级，必须完成 Event B。
11. Event B 三个玩家选项都允许正常升级，不存在唯一正确答案。
12. 至少实现一条本庄行为改变的 callback。
13. 如果已有 relationship / event schema，优先映射到现有字段，不要为本事件单独造一套重复系统。
14. 所有 event id / flag id 使用稳定英文 snake_case。
15. 如现有项目角色 ID 与本文不同，以项目现有 ID 为准，不重复创建角色。

---

# 17. 事件主题总结

### 对患者

> 手术室对工作人员是日常，对患者可能是一生只有一次的恐惧经历。

### 对本庄萌恵

> 她不是恶意，而是需要有人教她如何从患者的角度看手术室。

### 对杉村弘子

> 她真正可靠的地方，不只是“技术熟练”，而是她同时在照顾患者和培养下一代护士。

Relationship Lv1 的核心不是：

> “主角开始追求弘子。”

而是：

> **“主角开始真正敬重弘子，而弘子也开始把主角视为能理解自己工作方式的人。”**
