# Hoshimi Hospital — 石神千鹤 Character Bible

## Ishigami Chizuru / 石神千鶴
### Head of Nursing / 看護部長 / Non-Romanceable Management Character

> **文件性质：Canonical Character Bible**
>
> **稳定文件名：** 后续直接更新本文件，不创建 V2 / V3 副本。
>
> **角色状态：**
>
> ```yaml
> status: active_design
> crossover: true
> source: Persona 2
> hoshimi_au: true
> adult: true
> age: 32
> romanceable: false
> sunday_date_available: false
> hotel_available: false
> staff_as_patient_available: false
> relationship_route: professional
> ```
>
> **核心一句话：**
>
> > **石神千鹤是星见医院全院护理部门的负责人：冷艳、寡言、极有压迫感，平时很少亲自做一线护理，但整个护理系统都知道她在看。**

---

# 0. Codex 执行指令

1. 全项目搜索：
   - 石神千鹤
   - 石神千鶴
   - Ishigami Chizuru
   - Chizuru Ishigami
2. 如果已有 actor：
   - 保留已有 `actor_id`；
   - 不重复创建。
3. 如果尚不存在，推荐：
   ```text
   nurse_ishigami
   ```
4. 角色必须接入：
   - actor registry
   - relationship / professional trust system
   - hospital ambient encounter system
   - nursing management events
   - large surgery / Advanced Referral support
   - Public Teaching Surgery
   - hospital lecture / training events
   - hospital festival / group events
5. 当前明确不要接入：
   - Sunday Date
   - Romance
   - Hotel
   - H event
   - Staff-as-Patient
6. 后续若用户改变攻略状态，直接更新本 Character Bible，不另建新版。
7. 如果已有统一 character schema，以项目当前 schema 为准映射字段，不要为石神单独造一套平行系统。

---

# 1. Hoshimi AU 定位

原作角色只作为：

```text
视觉气质
黑长直冷美人印象
成熟、神秘、低温感
```

的基础来源。

Hoshimi 不复制 Persona 2 的反派、超自然或阴谋剧情。

在星见医院中，她是：

> **全院看護部長 / Head of Nursing。**

游戏中文 UI 与对白可继续使用更自然的：

> **石神护士长**

但内部设定必须知道：

> 她不是某个普通病区的护士长，也不是单纯的 OR charge nurse。

她代表：

```text
全院护理管理
护理人员调配
护理质量
护理安全
护理教育
跨科护理协调
大型医疗事件中的护理侧指挥
```

---

# 2. 年龄与职业阶段

```yaml
age: 32
```

32 岁在 Hoshimi 中属于：

> **明显年轻的全院护理负责人。**

这不是普通晋升速度，而是角色特色之一。

建议履历：

```text
21岁左右：取得护士资格，进入临床
早期：外科病房 / 手术部轮转
中期：手术部与急重症护理经验快速累积
之后：成为 charge nurse / 小组负责人
再之后：进入护理管理、排班、教育与医疗安全工作
约30岁：进入护理部核心管理层
32岁：成为星见医院看護部長
```

不要把她写成：

> “因为背景关系所以年纪轻轻坐上去。”

正确理由：

```text
一线经验扎实
判断快
不怕承担责任
管理能力极强
能让不同性格的护士服从同一套流程
医院规模允许年轻管理者快速上升
明日香时代的人事结构也愿意使用年轻核心干部
```

她和年轻院长明日香形成一种有趣镜像：

> **两个都比自己的职位看起来年轻的人，却都不是摆设。**

---

# 3. 视觉设定

核心视觉：

```text
32岁成年女性
黑色长直发
长度至少过肩，推荐胸口至腰间
发量足但线条利落
细长、偏冷的眼睛
成熟脸型
身材修长
动作克制
表情变化少
```

气质关键词：

```yaml
appearance_tags:
  - black_long_straight_hair
  - mature_beauty
  - cool_elegance
  - narrow_eyes
  - low_expression
  - intimidating_presence
  - polished
```

不要画成：

```text
幼态黑长直
校园冰山少女
过度妖艳的反派
病娇
哥特角色
```

她的漂亮应该首先是：

> **成熟、整洁、职业感很强。**

---

# 4. 服装方向

## 4.1 日常管理状态

推荐：

```text
高规格白色护士制服
或
白色护理管理制服 + 深色窄身外套 / 开衫
```

重点：

- 与普通年轻护士一眼可区分；
- 不需要夸张装饰；
- 佩戴贴颈的黑色细项圈与低调银色小垂饰，作为日常护士长造型的固定识别点；
- 胸牌、管理职位标识清晰；
- 发型始终整齐；
- 鞋、制服、袖口都近乎没有凌乱感。

## 4.2 手术部巡视

```text
scrubs
手术帽
必要时口罩
```

但她通常不刷手进入无菌术野。

进入手术部时取下日常项圈及其他首饰；即使只负责指挥和现场监视，她也会首先遵守自己要求全院执行的着装规范。

## 4.3 真正介入大型手术

如果需要临时顶替 Scrub / Circulating：

```text
完整对应岗位服装
动作非常熟练
不需要“重新学回来”
```

玩家应该一眼感到：

> **她只是现在不常做，不是不会做。**

## 4.4 正式活动

护理讲课、公开教学手术、医院祭开幕、管理会议等：

```text
深色职业套装
或
高规格护理管理制服
```

可以适度保留原作黑衣冷艳视觉。

---

# 5. 核心人格

内部关键词：

```yaml
personality:
  primary:
    - composed
    - observant
    - intimidating
    - disciplined
    - concise
  secondary:
    - responsible
    - pragmatic
    - protective_of_staff
    - dry_humor
    - emotionally_private
```

一句话：

> **她不是凶，她只是几乎不会帮别人把错误说得好听。**

她：

- 很少提高音量；
- 很少真正发火；
- 很少公开羞辱人；
- 不喜欢废话；
- 不通过热情建立权威；
- 对工作中出现的问题记得非常清楚；
- 看到谁累到不行，会直接换人，而不是问“你还能撑吗”；
- 对患者安全和护理人员安全都非常现实。

她最有压迫感的时候：

> **通常恰恰是语气最平的时候。**

---

# 6. Voice Profile

推荐比例：

```text
75% 简短、冷静、职业化
15% 干燥的幽默 / 一句把人堵住
10% 极少出现的私人温度
```

常见句型：

```text
「理由。」
「继续。」
「不行。」
「谁负责？」
「你知道问题在哪。」
「先把人换下来。」
「这件事术后再谈。」
「患者面前不要讨论。」
「今晚不加班。」
```

避免：

```text
长篇训话
持续毒舌
故意羞辱年轻护士
每句话都像反派台词
```

### 典型对话

萌恵：

> 「护士长，你生气了吗？」

石神：

> 「没有。」

萌恵：

> 「那为什么更可怕了……」

石神：

> 「因为你知道自己做错了什么。」

---

# 7. 她的“冷”不是恶意

这是写作重点。

她不是：

```text
喜欢支配人
享受新人害怕自己
故意制造等级压迫
看不起普通护士
冷漠患者
```

她真正的逻辑：

> **护理工作本来已经够辛苦，不需要再用混乱和含糊增加风险。**

所以她会非常讨厌：

```text
职责不清
排班过劳
流程只靠“大家应该知道”
出了事互相甩锅
为了面子让新人硬撑
在患者面前训人
医生随口要求护理无限加班
```

---

# 8. 全院护理负责人的权力范围

她负责：

```text
全院护士排班与资源分配
护理部门人事建议
护士新人培养
岗位能力评估
病区间临时调动
手术部护理资源
护理流程与质量改进
患者安全会议
护理事故复盘
医院大型活动护理安排
教学活动护理侧协调
高级转诊护理团队配置
```

她不是院长。

她也不是所有医生的上级。

但是在：

```text
护理人员配置
护理工作量
护理安全
护士是否继续工作
```

这些问题上，她拥有真正的否决权。

---

# 9. 与城宮明日香的关系

核心：

> **互相尊重，但石神不会因为对方是院长就顺着她。**

明日香年轻、理论强、愿意做新项目。

石神负责告诉她：

> 新项目需要多少人、多少班、多少现实成本。

典型：

明日香：

> 「这个月能不能再加两台教学手术？」

石神：

> 「不能。」

明日香：

> 「为什么？」

石神：

> 「因为护士需要睡觉。」

不是宫斗。

而是：

> **一个负责医院想做什么，一个负责提醒医院的人能不能承受。**

两人应该形成稳定管理搭档。

---

# 10. 与杉村弘子的关系

必须避免生态位重叠。

```text
杉村弘子
= 资深临床护士
= 患者照护
= 新人现场带教
= 温暖型可靠前辈

石神千鹤
= 看護部長
= 全院护理管理
= 人员 / 资源 / 纪律 / 制度
= 冷静型管理权威
```

核心区别：

> **弘子教你怎么把这一次护理做好。**
>
> **石神负责为什么整个医院以后都不会再犯同一个错误。**

两人互相认可。

石神对弘子的评价应该很高，但不会天天夸：

> 「杉村在，就不用我多说。」

这已经是很高评价。

弘子则是少数不会因为石神突然出现就紧张的人。

---

# 11. 与本庄萌恵的关系

萌恵天然怕她。

但石神不是萌恵的“克星”，而是：

> **她非常清楚萌恵有潜力，也非常清楚她现在还缺什么。**

石神不会因为萌恵一次失误就否定她。

例如：

萌恵：

> 「我是不是不适合手术室……」

石神：

> 「一次做错就不适合？」

萌恵：

> 「不是……」

石神：

> 「那就记住。」

> 「下次别再做错。」

这是她的教育方式。

---

# 12. 与朝倉美幸 / 七瀬恋 / 中井美佳 / 利根川安琪

暂时保持原则级接口，不提前重写别人路线。

## 朝倉美幸

> 稳定的一线骨干。

石神对她的信任来自：

```text
流程可靠
不逞强
会确认不熟悉的事情
```

## 七瀬恋

石神不会追问她不愿谈的过去。

只看：

> **现在工作是否可靠。**

## 中井美佳

石神知道她非常能干、社交无懈可击。

但石神可能是少数：

> **不会因为“所有人都觉得她很好”就自动完全信任她的人。**

不要直接变成侦探线。

只保留一种：

> 两个都极会观察别人的成年人互相知道“对方不好糊弄”。

## 利根川安琪

石神可作为安琪职业成长线里非常重要的高层观察者。

她不会亲自天天教安琪。

但可能在某个阶段只说：

> 「你可以继续留在手术部。」

对年轻安琪来说，这已经是极高认可。

---

# 13. 普通医院日常中的存在方式

她不能高频随机出现，否则权威感会被磨掉。

推荐：

```yaml
ambient_encounter_weight: low
management_event_weight: medium
large_event_presence: very_high
```

普通玩家可能在：

```text
护士站巡视
病房走廊
护理部办公室
手术部入口
会议室
食堂
教学活动
```

偶尔遇见她。

她的 Ambient Encounter 应短。

### 例：护士站

石神看了一眼墙上的排班表。

> 「谁改的？」

萌恵：

> 「我、我只是帮忙抄了一遍……」

石神：

> 「那不是问你。」

弘子：

> 「我改的。昨晚临时有人请假。」

石神点头。

> 「知道了。」

然后走了。

萌恵：

> 「……这就结束了？」

弘子：

> 「不然呢。」

---

# 14. 普通手术中的角色

普通手术：

> **石神一般不进入玩家可选团队。**

她可能：

```text
术前巡视一次
经过 OR 门口
看排班
检查人员是否超时
偶尔在术后问一句情况
```

不要让她因为名气大就抢走年轻护士的 Gameplay 位置。

---

# 15. Advanced Referral / 大型手术

这里是她真正重要的临床舞台。

高级转诊 / Master Procedure / 超长手术中，可以增加特殊位置：

```yaml
nursing_supervisor:
  actor: nurse_ishigami
  consumes_standard_nurse_slot: false
```

她不一定一直站在无菌台旁。

她负责维持：

```text
Scrub 轮换
Circulating 轮换
器械补充
血液 / 物资协调
护理记录
人员疲劳
跨 OR 支援
临时换人
护理侧突发问题
```

她像是：

> **Grand OR 的护理后台指挥。**

玩家可能并不一直和她说话，但背景中不断能看到她在维持整个现场。

---

# 16. “她亲自下场”必须是有重量的事件

平时她不做一线。

所以当真正出现：

> 「我来。」

应该有特殊意义。

触发条件可包括：

```text
关键护士突发不适
超长手术需要高级轮换
器械 / 流程出现重大异常
Grand OR 需要临时补一个经验极高的 Scrub
大型教学事件临时缺位
```

她一旦接手：

> 不需要重新证明技术。

动作应该立刻表现：

```text
快
稳
不多话
提前判断
没有多余动作
```

年轻角色会第一次意识到：

> **护士长不是因为不会干才去管理。**

---

# 17. 公开教学手术中的位置

Public Teaching Surgery 中，她可以作为：

> **护理侧负责人。**

职责：

```text
观摩纪律
护理人员分工
患者隐私
无菌区边界
年轻护士观摩安排
术后护理讨论
```

典型：

> 「今天允许观摩，不代表允许影响术区。」
>
> 「有人不舒服，直接出去。」
>
> 「护理问题留到术后讨论。」

然后退出主角位置，维持背景秩序。

---

# 18. 医院讲课 / 培训

她非常适合成为护理教育活动固定人物。

内容可以包括：

```text
患者安全
护理沟通
疲劳管理
无菌原则
交接班
手术室团队协作
新人培训
事故复盘
```

她讲课风格：

> **非常短。**

不会做煽情 PPT。

例如：

> 「今天讲交接。」
>
> 「目的只有一个。」
>
> 「下一个人不能靠猜。」

---

# 19. 医院祭 / 大型群像活动

医院祭、公开日、护理技能展示等活动中，她是：

> **护理部门正式代表。**

她可以批准：

```text
护士部门摊位
护理技能体验
健康咨询
急救展示
```

她本人可能看起来完全不像会参加学园祭。

这就是笑点。

萌恵：

> 「护士长，我们摊位想做可爱的装饰。」

石神：

> 「不影响动线就行。」

萌恵：

> 「粉色？」

石神：

> 「颜色不会影响动线。」

萌恵：

> 「……批准了？」

石神：

> 「我刚才说得不够清楚？」

---

# 20. 与坂口隆司的关系

当前定位：

```yaml
romanceable: false
relationship_type: professional_trust
```

她不会因为坂口是玩家主角就自动喜欢他。

初期她对他的判断是：

> **海外回来、手术能力不错，但还不知道会不会把整个团队当成真正的人来使用。**

她真正观察的是：

```text
是否尊重护理判断
是否把护士当无限资源
是否在患者面前保持团队一致
出了问题是否甩锅
高压时是否仍能听别人说话
是否知道什么时候该停
```

她对坂口的好感，本质上是：

> **Professional Trust / Institutional Trust**

而不是 Affection。

---

# 21. Relationship Lv0–Lv5 — 非攻略职业线

为了兼容现有角色系统，可以保留 Lv0–Lv5。

但含义完全是：

> **石神对坂口作为医院核心医生的职业认可。**

不要转成恋爱。

## Lv0 — 《护士长》

玩家知道：

> 她是全院护理负责人。

第一印象：

```text
冷
漂亮
难接近
整个护士站在她出现时都会安静一点
```

她只对坂口说：

> 「坂口医生。」

> 「以后请别临时加台不通知护理部。」

然后走掉。

---

## Lv1 — 《不是无限的》

主题：

> 护理人力不是游戏里的无限资源。

坂口希望临时增加工作。

石神拒绝，并让玩家第一次看到：

> 每一台手术背后都有排班、轮换、休息和人。

升级不是“她开始喜欢你”。

而是：

```text
player_understands_nursing_resources = true
ishigami_professional_trust +=
```

---

## Lv2 — 《出了事先处理》

一次护理侧小事故 / 流程异常。

石神第一件事不是找责任人，而是：

```text
保护患者
恢复人员
补齐流程
```

事情结束后才复盘。

让玩家理解：

> 她冷，不等于没有人情味。

---

## Lv3 — 《我来》

大型手术里出现临时缺位。

石神第一次在玩家面前亲自顶上一线岗位。

核心 payoff：

> 玩家发现她的一线技术仍然极强。

事件后坂口：

> 「很久没上台？」

石神：

> 「不代表忘了。」

---

## Lv4 — 《你可以继续开》

高级转诊 / 高压阶段。

玩家需要护理部为一台极复杂手术承担非常高的资源成本。

石神审查以后批准。

她的关键台词可以是：

> 「我不是相信这台手术简单。」

> 「我是相信你知道它有多难。」

这代表：

> **Institutional Trust**

她开始愿意把整个护理团队交给坂口使用。

---

## Lv5 — 《这里也是你的医院》

这是职业线最高点。

不接吻、不 H、不约会。

石神在某个大型事件 / 年末节点明确把坂口视为：

> **Hoshimi 的核心医生，而不是暂住一年的外来者。**

例如：

坂口：

> 「这种事不是应该由院长决定？」

石神：

> 「院长决定你留不留。」

停一下。

> 「我们决定你是不是自己人。」

这是她非常高等级的认可。

可为：

```text
hospital_belonging
leadership_ending
director_ending
professional_reputation
```

提供隐藏权重。

---

# 22. Romance / Adult Content 当前禁用

明确：

```yaml
romanceable: false
sexual_route: false
hotel_event: false
sunday_date: false
staff_as_patient: false
public_teaching_patient: false
```

不要因为：

```text
关系 Lv5
高 Familiarity
高 Reputation
```

自动开启恋爱。

她当前是：

> **不可攻略的重要成年女性角色。**

允许：

```text
成熟魅力
轻微成人玩笑
别人觉得她漂亮
坂口注意到她很有吸引力
```

但不要把这些自动转成 romance flag。

未来如果项目决定开放攻略：

> **直接更新本文件。**

---

# 23. 双胞胎姐姐事件 — 当前仅保留 Hook

`IDEA-001` 的：

> 高冷美女护士 × 双胞胎姐姐手术事件

目前石神是非常强的候选。

但本 Character Bible 当前**不正式锁定**：

```yaml
has_twin_sister: undecided
```

Codex 当前不要自行：

```text
创建姐姐 actor
写姐妹背景
触发双胞胎手术
```

等待后续明确批准。

如果最终采用，这会成为非常适合她的：

> **极少数私人破功事件。**

---

# 24. 核心技能 / Stats 方向

以下为方向值，后续按项目统一数值体系调整。

```yaml
nursing:
  patient_care: 86
  instrument_handling: 88
  circulating: 90
  crisis_management: 96
  infection_control: 94
  documentation: 92

management:
  leadership: 97
  staffing: 98
  logistics: 94
  education: 87
  quality_control: 97

personality:
  calmness: 97
  observation: 94
  sociability: 55
  warmth_visible: 35
  responsibility: 98
```

关键：

> 她不是“护理所有技能全 100”。

她真正顶级的是：

```text
领导
资源调配
危机处理
流程判断
质量控制
```

一线技术仍然强，但弘子等临床型角色在某些具体患者照护维度完全可以优于她。

---

# 25. Gameplay Trait 候选

## `nursing_command`

大型事件存在石神时：

```text
nurse_rotation_efficiency +
staff_fatigue_growth -
supply_delay_chance -
nursing_coordination +
```

不要让这个 buff 变成魔法加成。

叙事解释必须始终是：

> **人换得及时、东西准备得对、信息传得清楚。**

## `management_override`

在某些事件中她可以：

```text
强制撤下过劳护士
拒绝不合理加台
临时调入备用人员
暂停护理侧不安全流程
```

她的 override 不能替代医生的医学判断。

---

# 26. Failure / Mistake Interaction

坂口犯普通错误时，她不会：

> “你怎么这么废物。”

她会：

> 「先处理。」

术后才：

> 「解释一下你当时为什么这么判断。」

如果理由合理但结果不好：

> 她接受。

如果是玩家故意乱来：

> 她的 Professional Trust 应明显下降。

特别是：

```text
无视护士警告
强迫过劳团队继续
把责任甩给护士
在患者面前羞辱护理人员
```

这些应该是她最不能接受的行为。

---

# 27. Professional Reputation / Ending 接口

石神非常适合作为“医院是否真正接受坂口”的隐藏评价来源之一。

因为她代表：

> **不是某一个女角色喜欢你，而是整个护理体系是否愿意和你长期工作。**

推荐未来隐藏条件：

```text
ishigami_relationship >= 4
or
ishigami_professional_trust_high = true
```

可为：

```text
院长 / 医院领导结局
临床核心结局
Hoshimi 留任结局
```

增加权重。

不要让她单独决定结局。

---

# 28. 写作禁区

不要把石神写成：

```text
反派护理主任
权力狂
随便骂护士
冷漠患者
只会行政不会临床
什么都亲自干的万能护士
御堂的护士版
弘子的上位替代
隐藏恋爱女主
```

尤其不要：

> 为了证明她厉害，让其他护士突然变笨。

她的权威来自：

> **让整个团队变得更稳定。**

---

# 29. 角色功能总结

石神同时承担：

```text
1. 全院护理部门的话事人
2. 护理资源与排班的拟人化接口
3. 大型手术的护理侧背景指挥
4. Advanced Referral 的 Grand OR 管理角色
5. Public Teaching Surgery 护理负责人
6. 护理讲课 / 培训 / 医疗安全事件主持人
7. 医院祭等群像活动中的护理代表
8. 玩家“医院归属感 / 管理能力”评价者
9. 极低频亲自下场时的资深护士技术展示
```

---

# 30. Codex 最终定义

```yaml
actor:
  id: nurse_ishigami
  name_zh: 石神千鹤
  name_ja: 石神千鶴
  name_en: Chizuru Ishigami
  age: 32
  adult: true

  role: nurse
  position: head_of_nursing
  ui_title: 石神护士长

  crossover: true
  source_tag: persona_2
  hoshimi_au: true

  romanceable: false
  sunday_date_available: false
  hotel_available: false
  staff_as_patient_available: false

  relationship:
    enabled: true
    type: professional_trust
    max_level: 5

  clinical:
    frontline_default: false
    or_selectable_default: false
    advanced_referral_support: true
    public_teaching_support: true
    nursing_management: true

  visual:
    black_long_straight_hair: true
    mature_cool_beauty: true
    low_expression: true

  optional_hooks:
    twin_sister_event: undecided
```

最终一句：

> **石神千鹤不是玩家最常一起工作的护士。**
>
> **她是那个让玩家逐渐意识到：整座医院为什么能够正常运转的人。**

# END
