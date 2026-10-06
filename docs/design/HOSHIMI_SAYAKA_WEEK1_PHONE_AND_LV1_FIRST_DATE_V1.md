# Hoshimi Hospital — 南条小夜香 Week 1 前置事件 + Lv1
## 《号码给我》 / 《所以这算约会吗？》
### Relationship Lv0 → Lv1 Detailed Event Design V1

> **用途**
>
> 本文件用于直接交给 Codex 拆分为：
>
> - Week 1 强制短事件；
> - 手机联系方式解锁；
> - First Sunday 小夜香约会入口；
> - Sunday Date 特例；
> - Lv0 → Lv1 正式关系升级；
> - 对白、立绘差分、场景、Flag 与后续 Lv2 接口。
>
> 本稿以 `HOSHIMI_NANJOU_SAYAKA_CHARACTER_BIBLE_V1.md` 为人物基准。
>
> 小夜香路线的核心不是“系统送女友”，而是：
>
> > **她很容易喜欢一个人，也很容易承认自己喜欢；但她有完整的自主性、原则和边界。**
>
> Lv1 只表示：
>
> > **双方已经明确感到男女之间的好感。**
>
> 不代表：
>
> - 已正式交往；
> - 已接吻；
> - 已发生 H；
> - 已承诺排他关系。

---

# 0. 总体节奏

```text
Day 1
↓
《白大褂下面》
正式认识南条小夜香
relationship = Lv0
↓
Day 2–5
强制短事件《号码给我》
交换手机号码
↓
Week 1
1–3 次普通 ambient encounter
↓
First Sunday
Sunday UI 中南条小夜香已经出现在“可邀请角色”列表
↓
玩家主动选择邀请她
↓
Lv1《所以这算约会吗？》
↓
饭后 AA + 明确暧昧
↓
Relationship Lv1
```

设计重点：

> **主动选择来自玩家。**

小夜香不会在第一个星期六强制打电话把玩家拖出去。

她的主动性表现于：

- 交换号码时毫不扭捏；
- 被邀请后直接接受；
- 约会中主动确认“这是不是约会”；
- 明确表达自己的好感；
- 主动澄清 AA 并非划清界限。

---

# 1. Sunday 系统特例

现有 Sunday V1 默认：

```yaml
date_invite_unlock:
  relationship_level_min: 1
```

但小夜香承担：

> **First Sunday / Easy Route / Tutorial Heroine**

功能。

因此为她增加角色特例：

```yaml
sayaka_sunday_exception:
  relationship_level_min: 0
  requires:
    met_sayaka: true
    sayaka_phone_exchanged: true
    character_available: true
```

效果：

> **小夜香可以在 Lv0 状态下出现在 Sunday Invite 列表。**

这不是全局修改。

不要让其他 Lv0 角色自动获得相同权限。

---

# 2. Week 1 强制前置事件
## 《号码给我》

```yaml
event_id: sayaka_week1_phone_exchange
category: mandatory_short_character_event

relationship:
  start: lv0
  end: lv0

duration: short
repeatable: false

required:
  met_sayaka: true
  sayaka_phone_exchanged: false
  day_min: 2
  day_max: 5
  special_event_in_progress: false

sets:
  sayaka_phone_exchanged: true
  sayaka_sunday_invite_available: true
```

不直接提升 Relationship。

这个事件的功能只是：

> **把“医院里认识的同事”变成“下班后也可以联系的人”。**

---

# 3. 《号码给我》场景

### Location

推荐优先：

```text
player_office corridor
doctor_work_area
clinic corridor
```

不要专门预约。

最好发生在：

> 两个人刚刚完成一件非常普通的工作以后。

例如：

- 小夜香送来会诊资料；
- 帮忙找到了某份检查结果；
- 替病房带来一句交接；
- 顺手提醒坂口某患者等他签字。

---

## Scene 01 — 公事结束

小夜香把病历夹递过去。

**南条小夜香** — `neutral`

> 「这个。」

坂口接过来。

> 「谢了。」

> 「不用谢，我只是顺路。」

坂口翻了一页。

> 「你到底哪边都顺路。」

她耸肩。

> 「所以才叫 generalist 啊。」

坂口：

> 「这词是这么用的吗？」

小夜香：

> 「在星见可以。」

---

## Scene 02 — 她忽然不走

她转身走了两步。

停下。

回头。

**南条小夜香**

> 「对了。」

她从白大褂口袋里拿出手机。

> 「手机。」

坂口：

> 「什么？」

> 「号码给我。」

---

## Scene 03 — “这么直接？”

坂口：

> 「这么直接？」

她低头点开联系人页面。

> 「工作需要。」

> 「你又不是永远待在一个房间里。」

> 「临时找你还得让护士站满医院广播——」

她模仿护士站语气：

> 「‘坂口隆司医生，请速回电。南条医生找您。’」

抬头。

> 「听起来很像我在追债。」

坂口：

> 「你现在不像？」

她笑。

> 「少废话。号码。」

---

# 4. 交换号码

坂口把号码报给她。

几秒以后。

手机震动。

屏幕：

```text
南条小夜香
我是南条。
```

坂口：

> 「我知道。」

小夜香：

> 「通讯录不知道。」

坂口低头保存。

她往前凑一点，看他屏幕。

> 「等等。」

坂口：

> 「怎么？」

> 「你不会准备存成‘南条医生’吧？」

坂口：

> 「不然呢？」

她想都没怎么想：

> 「小夜香。」

坂口抬眼。

她和他对视两秒。

然后笑出来。

> 「开玩笑。」

停一下。

> 「……至少现在是。」

---

# 5. 更放得开一点的可选尾句

可以随机抽一个，不要全部连续使用。

### Variant A

坂口：

> 「那以后什么时候能存？」

小夜香：

> 「看你表现。」

---

### Variant B

坂口：

> 「所以这个号码只能工作联系？」

她眨一下眼。

> 「我可没这么说。」

---

### Variant C

她把手机塞回白大褂口袋。

> 「半夜两点别发无聊消息。」

坂口：

> 「什么算无聊？」

她看他。

> 「你先发。」

> 「我收到以后再判断。」

---

# 6. 《号码给我》结束状态

```yaml
sayaka_phone_exchanged: true
sayaka_sunday_invite_available: true
sayaka_private_contact_open: true

relationship_sayaka: 0
dating_officially: false
```

不显示 Relationship Level-Up。

可以只出现小提示：

```text
已获得：南条小夜香的联系方式
```

---

# 7. Week 1 手机 / ambient 小回调

在 Lv1 前只需要 1–2 次，非常短。

不要让她像刚交换号码就开始狂发消息。

例如：

### 工作消息

```text
南条小夜香：
刚才那个患者的检查结果出来了。

坂口：
看到了。

南条小夜香：
回得这么快。
你是不是其实很闲？

坂口：
你希望我晚点回？

南条小夜香：
那倒不用。
```

### 午饭消息

```text
南条小夜香：
你吃饭了吗？

坂口：
还没有。

南条小夜香：
猜到了。
医生因为忙把自己饿出胃病是不是很丢脸？

坂口：
你这是医疗建议还是私人关心？

南条小夜香：
你自己选一个喜欢的解释。
```

---

# 8. Lv1 事件
## 《所以这算约会吗？》

```yaml
event_id: sayaka_lv1_first_date
category: relationship_event
day_type: sunday_off

relationship:
  start: lv0
  end: lv1

repeatable: false
consumes_day: true

required:
  met_sayaka: true
  sayaka_phone_exchanged: true
  relationship_sayaka: 0
  sunday_free_menu_available: true
  sayaka_available: true
  special_event_in_progress: false
```

---

# 9. First Sunday UI

第一个星期天进入：

```text
今天是星期日。
没有安排普通门诊和择期手术。

今天要怎么过？
```

玩家选择：

```text
[邀请某人外出]
```

小夜香从 First Sunday 起即可出现：

```text
南条小夜香
```

她很可能：

> **是唯一一个已经可邀请的角色。**

但：

> **不强制玩家选择。**

玩家也可以：

- 去医院；
- 去办公室；
- 在家休息。

如果玩家没有约她：

> Lv1 不发生。

以后任意满足条件的 Sunday 仍然可触发。

---

# 10. 邀请

玩家选择南条小夜香。

手机界面。

坂口：

```text
今天有空？
一起吃饭？
```

她很快回复：

```text
有啊。
```

几秒以后又来一条：

```text
你第一个星期天就约我？
```

坂口：

```text
只是吃饭。
```

她：

```text
你们男人为什么这么喜欢先加“只是”？
```

紧接着：

```text
行。
地方你选。
```

---

# 11. 约会地点

默认推荐：

> **中档意大利餐厅 / Trattoria**

不是高级 Fine Dining。

不是昂贵纪念日晚餐。

而是：

- 暖黄色灯光；
- 木桌；
- 小双人桌；
- 下午至傍晚；
- 有红酒 / 气泡水；
- 面包；
- 意面；
- 海鲜 / 肉类主菜；
- 价格足以有一点约会感，但两名医生不会觉得有负担。

```yaml
date_location:
  type: italian_trattoria
  price: moderate
  mood:
    - warm
    - intimate
    - casual_romantic
```

备选：

> casual French bistro

但本事件默认以意大利餐厅书写。

---

# 12. 私服

小夜香不要穿得像盛装晚宴。

她应该：

> **明显比上班打扮私人化，但完全不是“为男人特意变成另一个人”。**

例如：

- 修身上衣；
- 短裙 / 合身长裤；
- 高跟鞋或短靴；
- 简单首饰；
- 红发自然放下。

要让坂口第一次明显感觉：

> **平时那件白大褂不见以后，她依然非常像她自己。**

---

# 13. Scene 01 — “比我想象中更像约会”

坂口提前几分钟到。

小夜香已经站在餐厅门口。

**坂口**

> 「你来得比我早。」

**小夜香**

> 「两分钟而已。」

> 「别说得像我提前半小时站在这里等男人。」

坂口看一眼店面。

她顺着他的视线看过去。

**小夜香**

> 「哦——。」

坂口：

> 「怎么？」

> 「选这种地方啊。」

> 「有什么问题？」

她看了看暖灯、双人桌，又看他。

> 「没有。」

嘴角微微一扬。

> 「就是比我想象中像约会一点。」

坂口：

> 「你不是说只是吃饭？」

她：

> 「那句话是你说的。」

---

# 14. Scene 02 — 私下的小夜香

坐下。

服务员离开。

小夜香翻菜单。

> 「医院外面看你还挺新鲜的。」

坂口：

> 「我有什么不同？」

她认真看他几秒。

> 「没有白大褂。」

坂口：

> 「你也没有。」

她低头看看自己。

> 「失望？」

### 选择

```text
[有一点]
[这样也很好看]
[没区别]
```

## [有一点]

她扬眉。

> 「哦？」

坂口：

> 「白大褂挺适合你。」

她很自然：

> 「我知道。」

## [这样也很好看]

她停半秒。

> 「第一顿饭就这么会说？」

坂口：

> 「实话。」

她笑。

> 「可以。」

## [没区别]

她故意皱眉。

> 「没区别？」

> 「你这个回答很危险。」

坂口：

> 「我的意思是都认得出来。」

> 「补救得还行。」

---

# 15. Scene 03 — 她确实喜欢男人

不要把整场约会变成人物资料朗读。

聊天自然绕到医院。

坂口：

> 「你在星见适应得倒挺快。」

小夜香：

> 「因为大家都挺好相处啊。」

停一下。

> 「就是有一个问题。」

> 「什么？」

她托着下巴。

> 「女人太多。」

坂口：

> 「……」

她看他的表情，笑了。

> 「别这个脸。」

> 「我又没说我讨厌女人。」

坂口：

> 「那你有什么意见？」

她喝一口饮料。

> 「男人太少。」

坂口：

> 「你这么喜欢男人？」

她回答得完全不扭捏：

> 「喜欢啊。」

> 「正常成年女性，喜欢男人有什么不能承认的？」

然后看他。

> 「还是说你希望我不喜欢？」

坂口：

> 「那倒没有。」

她笑：

> 「那就好。」

---

# 16. Scene 04 — 好感第一次非常明显

坂口：

> 「所以你进医院是为了找男人？」

她马上纠正：

> 「为了医学。」

停一秒。

> 「男人是附加价值。」

坂口：

> 「那星见的附加价值怎么样？」

她看着他。

没有马上回答。

然后：

> 「本来觉得不怎么样。」

> 「最近稍微有点改善。」

坂口：

> 「为什么？」

她故意装作思考。

> 「医院新来了一个还算能看的男医生？」

坂口：

> 「还算？」

> 「夸太多容易膨胀。」

---

# 17. Scene 05 — “所以今天这个算什么？”

饭吃到差不多。

两个人已经比刚坐下时放松很多。

小夜香忽然看着坂口。

> 「我问你一个。」

坂口：

> 「什么？」

> 「今天这个算什么？」

坂口：

> 「吃饭。」

她立刻：

> 「我知道我们在吃饭。」

身体稍微前倾。

> 「我是问——」

> **「算约会吗？」**

---

# 18. Lv1 核心选择

```text
[当然算]
[你希望它算吗？]
[只是出来吃顿饭]
```

## A. [当然算]

她停了一下。

不是惊讶。

更像：

> **终于听到一个不绕弯的答案。**

她笑。

> 「哦。」

坂口：

> 「就这样？」

> 「不然呢？」

> 「要我站起来鼓掌？」

她拿起杯子。

> 「不过——」

看他一眼。

> 「这个答案我喜欢。」

设置：

```yaml
sayaka_mutual_attraction: true
sayaka_lv1_path: direct
```

## B. [你希望它算吗？]

她完全没有躲。

> 「希望啊。」

坂口没想到她答得这么快。

她：

> 「怎么？」

> 「是你问我的。」

停一下。

> 「所以你呢？」

坂口：

> 「那就算。」

她笑：

> 「成交。」

设置：

```yaml
sayaka_mutual_attraction: true
sayaka_lv1_path: teasing
```

## C. [只是出来吃顿饭]

她不会受伤，也不会突然冷脸。

> 「行。」

她若无其事地吃掉最后一口。

几秒后：

> 「那下次我再努力一点。」

坂口：

> 「努力什么？」

她抬眼：

> 「让它比较像约会。」

这一选择：

```yaml
sayaka_romantic_interest_visible: true
sayaka_mutual_attraction: false
relationship_level_up: false
```

事件正常结束。

下一个 Sunday 仍然可以再次触发确认版。

> **玩家明确拒绝暧昧时，不强行升 Lv1。**

---

# 19. Scene 06 — 账单

如果选择 A / B，进入 Lv1 真正的人格落点。

服务员把账单放下。

坂口伸手。

小夜香已经拿出钱包。

> 「AA。」

坂口：

> 「我来吧。」

> 「不用。」

> 「第一次约会还算这么清楚？」

她的动作停了一下。

然后抬头认真看他。

> 「先说好啊。」

> 「别误会。」

语气不是防御。

更像她知道这件事容易让人误读，所以干脆说清楚。

> 「不是要跟你划清界限。」

> 「也不是在暗示‘我们只是普通朋友’。」

她把自己的那一份放在桌上。

> 「我只是有些事情有自己的原则。」

---

# 20. AA 对白

坂口：

> 「比如约会必须 AA？」

她：

> 「至少现在是。」

坂口：

> 「以后呢？」

她冲他抛个很明显的媚眼。

> 「以后关系再好一点——」

> 「你想请我，也不是完全没机会。」

坂口：

> 「听起来我还得努力升级。」

她笑：

> 「那你加油。」

---

## 更粗放一点的追加

她收起钱包。

看着坂口：

> 「钱先各付各的。」

停一下。

眼睛弯起来。

> **「别的以后再说。」**

坂口：

> 「你故意的吧。」

她：

> 「当然。」

---

# 21. 这段必须表达的人格

这不是：

> 小夜香害怕欠男人钱。

也不是：

> 小夜香刻意保持距离。

更不是：

> “新时代独立女性宣言”式说教。

而是很简单：

> **她有自己的生活方式。**

她喜欢男人。

她喜欢约会。

她很容易承认好感。

未来也会很容易进入 H。

但：

> **喜欢一个男人，不意味着自动把金钱、职业、身体和人生决定一起交给他。**

内部人物规则：

```yaml
sayaka_autonomy:
  likes_men: true
  sexually_open: true
  proactive: true
  financially_independent: true
  professional_independence: true
  personal_boundaries: clear
  low_drama: true
```

一句话：

> **她的低攻略门槛来自诚实和主动，不来自依附。**

---

# 22. Scene 07 — 回程

饭后不立刻分开。

两个人沿街走一小段。

不需要吻。

不需要告白。

两个人都已经知道答案。

小夜香：

> 「今天挺开心的。」

坂口：

> 「我也是。」

> 「那就好。」

走了两步。

她回头。

> 「对了。」

坂口：

> 「嗯？」

> 「下次你约我。」

坂口：

> 「这次不也是我约的？」

她想一下。

> 「那下次还是你。」

坂口：

> 「为什么？」

她笑：

> 「因为我也会想确认自己有没有行情啊。」

坂口：

> 「你还需要确认？」

她明显被这句取悦到了。

> 「不错。」

> 「保持。」

---

# 23. Lv1 升级

```text
南条小夜香 Relationship Lv1
```

设置：

```yaml
relationship_sayaka: 1

sayaka_first_date_completed: true
sayaka_mutual_attraction: true
sayaka_romantic_interest_confirmed: true
sayaka_phone_exchanged: true

dating_officially: false
kissed: false
had_sex: false
hotel_unlocked: false
```

---

# 24. Lv1 的准确关系状态

Lv1 以后，两个人是：

> **“已经约过一次，而且都知道对方对自己有男女好感的同事。”**

不是：

> “男女朋友。”

因此回到医院以后：

- 可以明显调情；
- 可以互相评价外表；
- 可以出现轻微吃醋玩笑；
- 可以在白大褂 / 手术服上互相调侃；

但还没有：

- 正式恋爱称呼；
- 排他要求；
- H；
- 同居感；
- 过度亲密动作。

---

# 25. Monday Callback

约会后的第一个工作日。

医院走廊。

坂口：

> 「早。」

小夜香：

> 「早。」

两人擦肩。

她忽然退回来半步。

> 「怎么？」

坂口：

> 「什么怎么？」

她观察他的脸。

> 「没什么。」

笑了一下。

> 「我还以为你睡一觉就不敢看我了。」

坂口：

> 「为什么？」

> 「有些男人私下说得挺好。」

> 「第二天穿上白大褂就开始装不认识。」

坂口：

> 「那你失望了？」

她看他。

> 「目前没有。」

然后正常去工作。

---

# 26. Lv2 接口

Lv1 完成以后：

```yaml
sayaka_lv2_eligible_base: true
```

Lv2 应该转回医院。

核心：

> **职场暧昧。**

建议未来 Lv2 包含：

- 她拿公事来坂口办公室；
- 工作处理完以后才开始私事；
- 坂口夸她白大褂性感；
- 坂口补一句：
  > 「你穿手术服也很好看。」
- 小夜香抛媚眼：
  > 「那当然。」
- 更深入谈她过去女子学校保健室经历；
- “女人太多了”；
- “男人是附加价值”；
- 进一步建立：
  > **性感、自主、会调情，但工作时绝对是医生。**

---

# 27. 推荐所需素材

## 前置事件《号码给我》

无需新 CG。

需要：

```text
Sayaka white_coat:
  neutral
  smile
  teasing
  eyebrow_raise

hospital corridor / player office corridor BG
phone UI
```

## Lv1

建议：

```text
Sayaka casual:
  neutral
  smile
  amused
  teasing
  soft_smile
  wink
```

背景：

```text
Italian trattoria day
Italian trattoria warm evening
shopping street / station street dusk
```

CG 不是必须。

如果要做一张：

> **CG：小夜香坐在暖色意大利餐厅双人桌对面，托着脸问“所以这算约会吗？”**

---

# 28. Codex Implementation Summary

```yaml
sayaka_week1_phone_exchange:
  event_id: sayaka_week1_phone_exchange
  mandatory: true
  repeatable: false
  level_change: false
  day_range: [2, 5]
  set_flags:
    - sayaka_phone_exchanged
    - sayaka_sunday_invite_available
    - sayaka_private_contact_open

sayaka_first_sunday:
  allow_invite_at_relationship_level: 0
  requires_phone_exchange: true
  player_initiated: true
  auto_invite: false

sayaka_lv1_first_date:
  event_id: sayaka_lv1_first_date
  location: italian_trattoria
  consumes_day: true
  start_level: 0
  success_level: 1

  core_choice:
    accept_date_framing:
      level_up: true
    ask_her_preference_then_accept:
      level_up: true
    insist_just_friends:
      level_up: false

  success_flags:
    sayaka_first_date_completed: true
    sayaka_mutual_attraction: true
    sayaka_romantic_interest_confirmed: true

  relationship_state_after:
    dating_officially: false
    kissed: false
    had_sex: false
```

---

# 29. 核心写作检查

这个事件成功时，玩家应该明确知道五件事：

1. **小夜香喜欢男人，而且完全不觉得需要遮掩。**
2. **她明显对坂口有好感。**
3. **她很容易进入暧昧，但不会因为喜欢一个人就失去原则。**
4. **她坚持 AA 不是疏远，而是自主。**
5. **Lv1 只是“我们彼此有意思”，还不是正式男女朋友。**

最终人物印象：

> **她很好追。**
>
> 但绝不是：
>
> **“她很好拿捏。”**

这两句话必须同时成立。

---

# END
