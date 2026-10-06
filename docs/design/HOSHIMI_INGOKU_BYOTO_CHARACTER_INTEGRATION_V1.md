# Hoshimi Hospital — 《淫獄病棟》角色兼容与立档
## 朝倉美幸 / 御園芹香
### Codex Character Integration Guide — V1

> **项目实施注记（2026-09-29）**：本次请求的角色修正范围只包含朝倉美幸。本文关于御園芹香的新建建议留作未来设计依据，本次没有据此自动创建新角色。

> 用途：把此前关于《淫獄病棟》角色如何进入 Hoshimi Hospital 的讨论固化为 Codex 可执行的人物档案与兼容规则。
>
> 本文件描述 **Hoshimi AU 的既定兼容方案**。它不是对《淫獄病棟》原作完整剧情的逐条复述。
>
> 核心原则：
>
> **AU divergence happens before the irreversible collapse.**
>
> 保留角色在旧医院形成的职业能力、人格负担、关系与记忆；不要要求她们在 Hoshimi 重新演一遍原作黑暗剧情。

---

# 0. Codex 执行指令

进入代码前：

1. 搜索 actor registry / character data / event data。
2. 如果角色已经存在：
   - 沿用现有 actor_id；
   - 不创建重复角色；
   - 不覆盖已有资源；
   - 新剧情以本文件为当前人物方向。
3. 如果角色尚未存在：
   - **立即建立最小可用角色记录；**
   - 使用 placeholder sprite / portrait；
   - stats 可以临时；
   - 未完成立绘和数值不应阻塞角色进入 roster。
4. 稳定 ID 一旦建立，之后只替换美术／数值，不随意改 ID。
5. 新剧情使用当前主角名 **坂口隆司**。旧文件中的“本多”等 legacy 名称，只有在触碰对应脚本时再迁移。

---

# 1. 当前项目中已知实现状态

## 朝倉美幸

现有 actor_id：

```text
nurse_yui
```

不要改 ID。

现有 intro：

```text
intro_nurse_yui
```

已经存在。

旧实现中她被写成：

- “门诊护士”
- “第一天有点紧张”
- 问题很多

这些表象可以保留。

但是必须用新的 canonical 解释：

> **她是新到 Hoshimi，不是护理行业新人。**

---

## 御園芹香

在当前已检查到的角色事件文件中，没有发现稳定的现有事件链。

因此 Codex 必须：

1. 再搜索当前最新 actor registry。
2. 若已经存在：
   - 使用现有 ID；
   - 不复制。
3. 若完全不存在：
   - 创建角色。

推荐新 ID：

```text
doc_serika
```

仅在没有现有稳定 ID 时使用。

第一阶段允许：

```yaml
sprite: placeholder
portrait: placeholder
stats: temporary
```

不要等待最终立绘。

---

# 2. 《淫獄病棟》进入 Hoshimi 的总体方法

不要采用：

```text
原医院剧情完整发生
→ 所有人带着最坏结局直接来到 Hoshimi
```

而采用：

> **在不可逆恶化之前发生 AU 分歧。**

也就是说：

- 旧医院确实发生过很多不健康、危险、伦理上有问题的事情；
- 角色已经因此发生改变；
- 但 Hoshimi 时间线不要求所有原作极端事件都已经完整发生；
- 她们仍然拥有重新选择职业身份和生活方向的空间。

核心：

```text
保留后果
不复刻毁灭
```

---

# 3. 朝倉美幸 — Character Bible

## 3.1 最重要的修正

强制 canonical：

> **朝倉美幸是正式、有经验、已经具备独立护理能力的护士。**

她绝不是：

```text
刚毕业
第一次当护士
什么都不会
需要从基础护理重新教学
```

Hoshimi 中“新人”的正确意思：

> **New to Hoshimi Hospital.**

不是：

> New to nursing.

---

# 4. 朝倉美幸为什么看起来像新人

她主动要求完整 orientation。

她会：

- 看流程；
- 记笔记；
- 问很多问题；
- 核对器械名；
- 问科室习惯；
- 确认 Hoshimi 的交接方式；
- 遇到不熟悉的东西主动承认“不知道”。

旁人因此容易误以为：

> 她经验不足。

但真正进入工作时，会发现：

> **她手上非常稳。**

---

# 5. 朝倉美幸的核心成长主题

她的重要转变不是：

> “从菜鸟成长为护士。”

而是：

> **从一个认为自己必须什么都知道、不能暴露不确定的人，重新学习‘不知道的时候可以问’。**

一句话：

> **“我是这里的新人啊。”**

她说这句话时可以很轻松。

其中真正的意思是：

> 我不需要为了证明自己有经验，就假装熟悉这里的一切。

---

# 6. 朝倉美幸的专业反差

可重复使用的经典桥段：

恋：

> “朝倉，你不是第一次碰这种台子吗？”

美幸：

> “这个型号是第一次。”

恋：

> “……型号？”

美幸：

> “嗯？”

这就是她。

她可以：

- 对设备型号认真确认；
- 对 Hoshimi SOP 不熟；
- 对科室习惯提问；

但：

- 患者转移；
- 基础无菌意识；
- 器械处理；
- 护理观察；
- 紧急情况反应

都不是菜鸟水平。

---

# 7. 朝倉美幸的当前工作定位

现有 intro 使用“门诊护士”。

这可以保留为她当前主要排班之一。

但不要限制她只能做门诊。

她可以逐渐进入：

```text
outpatient
ward support
OR support
circulating nurse
scrub / instrument support when qualified
```

尤其在 New OR Acceptance Event 中：

> 她表面像最认真记笔记的新人，但真正开始患者转移／手术台操作时动作非常熟练。

---

# 8. 朝倉美幸的写作语气

关键词：

```yaml
tags:
  - experienced_nurse
  - new_to_hoshimi
  - asks_questions
  - careful
  - diligent
  - note_taker
  - professionally_humble
  - quietly_capable
```

不要写成：

- 天然呆；
- 什么都不知道；
- 每件事都惊讶；
- 需要年轻护士教她基础技能。

她可以紧张。

但紧张的原因是：

> **新环境。**

不是：

> **没有能力。**

---

# 9. 朝倉美幸与中井美佳的镜像

这一对非常适合长期并置。

### 朝倉美幸

> **我可以不知道，所以我会问。**

她越来越愿意公开：

> “这个我没做过。”

### 中井美佳

> **我知道怎样在任何环境里活下来，所以别人没必要知道我。**

美幸：

```text
uncertainty
→ disclosure
→ asking
```

中井：

```text
knowledge
→ control
→ withholding
```

两个人都不是“弱”。

只是保护自己的方式不同。

---

# 10. 朝倉的关系路线

不要把关系线写成：

> 坂口教一个新人护士成长。

更合适：

> **坂口逐渐发现，她真正需要的不是“教护理”，而是一个允许她不必永远证明自己的新环境。**

Lv 事件应逐渐揭示：

- 她为什么如此认真确认流程；
- 她为什么问题很多；
- 她为什么会对“我不知道”这句话有特别意义；
- 她什么时候开始不再为提问道歉。

---

# 11. 御園芹香 — Character Bible

## 11.1 核心定位

> **曾经非常优秀的外科医生，如今选择成为阴沉寡言的放射科医生。**

她不是因为：

> “不会做手术。”

而离开手术。

她的问题是：

> **她不再信任“作为外科医生的自己”。**

关键词：

```yaml
tags:
  - radiologist
  - former_surgeon
  - highly_skilled
  - taciturn
  - gloomy
  - low_social_initiative
  - moral_injury
  - avoids_or_identity
```

---

# 12. 芹香的 AU 分歧

Hoshimi 不采用“所有最坏原作事件已经不可逆发生”的路线。

更合适的是：

```text
旧医院
↓
芹香已经受到职业与伦理上的严重污染 / moral injury
↓
她意识到继续留在那里会让自己变成不想成为的人
↓
在真正无法挽回之前离开
↓
不再以外科医生身份生活
↓
进入影像诊断 / 放射科
↓
最终来到 Hoshimi
```

这意味着：

> 她确实背着过去。

但 Hoshimi 不需要判她已经完成原作最极端的所有行为。

---

# 13. 芹香的核心心理
## Occupational identity contamination

她的问题不是普通的：

```text
手术 PTSD
```

而更接近：

> **“外科医生御園芹香”这个身份本身已经被过去污染。**

她仍然：

- 看得懂术式；
- 看得懂解剖；
- 能迅速判断手术风险；
- 知道术者下一步会做什么；
- 手仍然记得怎样操作。

但这些能力越明显：

> 她越不舒服。

因为它会提醒她：

> 她曾经是谁。

---

# 14. 芹香现在为什么做放射科

放射科非常适合她。

她可以：

- 看见病变；
- 给出关键判断；
- 帮助制定手术计划；
- 保持与患者／手术台一定距离；
- 不必重新成为那个她不想再成为的“外科医生”。

因此她现在的职业身份不是逃避式 joke。

而是：

> **她认真选择的一条仍然属于医学、但能让自己继续活下去的道路。**

---

# 15. 芹香的当前气质

近期 canonical 强化：

> **阴沉、寡言、社会主动性低。**

具体：

- 不主动参加热闹活动；
- 不喜欢无目的社交；
- 下班后大多消失；
- 在会议上只说必要内容；
- 如果片子已经能回答问题，她不会多说十句；
- 很少自己跑到外科办公室闲聊。

她不是：

```text
毒舌女王
傲娇
故意冷酷
神秘犯罪女人
```

而是：

> **单纯不想把自己重新卷回太多关系与旧职业身份。**

---

# 16. 芹香与手术室

这是她最重要的长期系统关系。

默认：

```yaml
serika_or_attendance:
  casual: false
  social_training: false
  professionally_required: possible
```

所以像：

> “新手术室启用日”

这种热闹、社交性质较强的 OR Training，她通常不会参加。

这不是：

> 没资格。

而是：

> **她会选择不去。**

---

# 17. 芹香什么时候会回 OR

必须有专业理由。

例如：

- 术前影像发现异常；
- 术中需要影像判断；
- 某个病例只有她最熟悉；
- 人手不足；
- 紧急情况；
- 奈々美／旧同事相关事件；
- 高关系下角色主动面对过去。

原则：

> **necessity before catharsis**

不是为了：

> “关系升级了，所以来陪坂口做台手术。”

---

# 18. 芹香的手术能力

虽然暂时不要求最终数值，但方向必须锁定：

```text
former_surgery_skill = high
current_surgery_identity = rejected / dormant
diagnostics_imaging_skill = very_high
```

如果未来 stats 建立：

- diagnostics / imaging 应非常高；
- surgery 不应该被写成低值；
- 只是实际 availability 与心理 willingness 受限。

也就是说：

> 数值上她会做。

> 剧情上她不愿做。

这是两件不同的事。

---

# 19. 芹香回到手术台旁时的表现

不要写成：

> 手抖得什么都不会了。

更有力的是：

```text
她仍然做得非常好。
```

而这正是最刺痛她的部分。

例如：

坂口：

> “你动作根本没生。”

芹香：

> “我知道。”

这句就够。

---

# 20. 芹香与坂口的关系

坂口不能：

```text
强行鼓励她重新做外科
把回手术室当治愈目标
告诉她“你这么有天赋不做可惜”
```

因为这会忽视：

> 她主动离开外科本身也是一种选择。

更好的关系路线：

> **坂口首先认可她现在就是一个放射科医生。**

只有在这种前提下：

> 她未来偶尔重新站到 OR 边，才真正有意义。

---

# 21. 芹香路线的核心问题

不是：

> “她什么时候重新成为外科医生？”

而是：

> **“她能不能接受：过去会做手术的那个自己，也是自己的一部分，但不必再支配她现在的人生？”**

最终也不要求她：

```text
辞掉放射科
回归外科
```

完全可以：

> 继续做优秀放射科医生，只在少数必要时刻重新使用过去的能力。

---

# 22. 堀内奈々美 — 关联角色备注

奈々美不是本文件必须立刻完成的主角之一，但她与芹香的旧院关系非常重要，应留接口。

当前讨论方向：

```text
原作：准看護婦
性格：善良、细致、愉快、直接
Hoshimi：可设为已经进阶为正式护士
OR / scrub 能力较强
```

她可以比芹香更晚离开旧医院。

因此她知道：

- 芹香以前作为外科医生是什么样；
- 芹香离开以后旧院发生过什么；
- 一些坂口不知道的旧 OR 记忆。

推荐解锁：

```text
serika_relationship_level >= 2
```

再把奈々美引入。

重要：

> 不要为了芹香立即自动创建奈々美，除非当前 roster 已经计划启用她。

但要为未来留角色接口。

---

# 23. 朝倉与芹香的共同兼容原则

两个人都来自有问题的旧环境。

但她们的“离开方式”不同：

### 朝倉美幸

> **重新学习可以问、可以不知道。**

### 御園芹香

> **重新定义自己是不是必须继续当外科医生。**

因此不要写成同一种创伤。

---

# 24. 当前 Hoshimi 不继续旧院犯罪主线

强制：

```yaml
old_hospital_current_plot:
  active_villain: false
  criminal_network: false
  chase_plot: false
  revenge_plot: false
```

旧医院主要以：

```text
memory
professional habit
relationship history
moral injury
callback
```

存在。

Hoshimi 的主线仍然是 Hoshimi。

---

# 25. 她们可以过正常成人生活

两人都可以：

- 参加医院活动；
- 约会；
- 恋爱；
- 成人 H 内容；
- Staff-as-Patient；
- Sunday Event；
- 节日；
- 温泉旅行。

但角色差异要保留。

### 美幸

更愿意参与集体活动。

### 芹香

可以参加，但概率低得多；尤其不会为了“热闹”主动出现。

---

# 26. Sunday Date 兼容

## 朝倉美幸

适合：

```text
shopping street
café
bookstore
aquarium
casual restaurant
```

她容易出门前做一点过头的准备，但真正出去以后会逐渐放松。

## 御園芹香

适合：

```text
quiet café
bookstore
museum
night walk
small restaurant
```

避免默认把她拉去：

```text
热闹 amusement-style date
大型团体活动
```

除非剧情故意表现她被别人拖去。

---

# 27. Staff-as-Patient

未来两人都可以支持。

### 朝倉美幸

作为患者的反差：

> 她习惯认真确认流程，但今天所有东西都确认到了自己身上。

### 御園芹香

作为患者更有角色意义：

> 曾经站在手术台旁的人，主动决定躺上去。

但不要把它写成惩罚／赎罪手术。

必须是：

```text
成人
自愿
安全
高关系
```

---

# 28. Codex 创建规则

## 朝倉美幸

必须优先查：

```text
nurse_yui
```

若存在：继续使用。

不要创建：

```text
nurse_miyuki_new
```

之类重复 ID。

## 御園芹香

优先全项目搜索：

```text
御園芹香
御园芹香
serika
doc_serika
radiology
```

如果不存在稳定 actor：

```yaml
actor_id: doc_serika
display_name: 御園芹香
profession: physician
department: radiology
adult: true
relationship_level: 0

sprite: placeholder
portrait: placeholder

stats:
  status: temporary
```

并加入：

- actor registry；
- unlock system；
- hospital location presence；
- relationship system。

数值后补。

---

# 29. 如果立绘未完成

不要因此不创角色。

统一：

```yaml
asset_state:
  sprite_ready: false
  portrait_ready: false
  use_placeholder: true
```

以后替换：

```text
placeholder
→ final character sprite
```

不要改变角色逻辑与 ID。

---

# 30. 建议最低实现内容

## 朝倉美幸

已经有 intro。

下一步至少补：

```text
Lv1: 新环境 orientation
Lv2: 第一次证明她其实非常熟练
Lv3: “不知道可以问”
Lv4: 私人关系 / adult intimacy
Lv5: 她不再需要证明自己
```

## 御園芹香

如果新建，至少补：

```text
Intro: 放射科第一次正式合作
Lv1: 影像判断救下一个病例
Lv2: 坂口发现她过去懂外科得过头
Lv3: 奈々美 / 旧院关联入口
Lv4: 必要情况下第一次重回 OR
Lv5: 接受过去的技术属于自己，但不等于回归外科
```

这些只是 route spine，具体对白后续再写。

---

# 31. Codex 禁止事项

```text
不要把美幸写成护理菜鸟
不要因为她问问题就降低专业能力
不要让坂口“教会她当护士”

不要把芹香写成不会手术
不要把她的放射科工作写成失败者退路
不要强迫她回外科作为 Happy Ending
不要把她写成普通冷艳傲娇

不要把旧医院黑幕搬成 Hoshimi 当前主线
不要复刻原作不可逆最坏结局
不要让成人内容破坏职业能力
```

---

# 32. 最终兼容定义

朝倉美幸：

> **一个已经会做护士的人，在新的医院里重新学习“我可以不知道，我可以问”。**

御園芹香：

> **一个仍然拥有优秀外科技术的人，选择不再让“外科医生”这个身份定义自己。**

共同主题：

> **Hoshimi 不是让她们忘记过去。**
>
> **Hoshimi 是让过去不再决定她们以后只能成为什么。**

---

# END
