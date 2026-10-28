# Hoshimi Hospital — Personal Nurse / 专属护士系统
## V1 设计规格
### 2026-10-05

> **状态：可交 Codex 实现**
>
> **目标：** 在坂口结束试用期后，将门诊从“神宫寺医生固定带教”自然过渡到“坂口独立看诊 + 一名固定专属护士陪诊”的状态。
>
> 本系统主要服务于职业成长感、门诊沉浸感、护士角色长期陪伴感与日常 Familiarity 成长；不增加新的门诊失败系统，也不改变现有手术自由组队逻辑。

---

# 1. 核心概念

游戏前期：

```text
坂口 = 试用期 / 新入职外科医生
神宮寺成美 = 固定 mentor
七瀬恋 = 初期经常合作的护士
```

试用期结束后：

```text
坂口 = 独立看诊
神宮寺成美 = 不再固定陪诊
专属护士 = 新的固定门诊搭档
```

核心原则：

> **专属护士只接替神宫寺目前在门诊阶段的固定陪诊 / 助言 / 可互动角色功能。**

她不是：

```text
强制手术护士
固定巡回护士
固定器械护士
固定病房队员
第二名医生助手
```

---

# 2. 试用期结束触发

触发条件：

```text
Game Day >= 30
OR
Professional Reputation >= 50
```

满足任一条件即可，只触发一次。

建议 flags：

```yaml
probation_complete: false
personal_nurse_system_unlocked: false
```

触发后：

```yaml
probation_complete: true
personal_nurse_system_unlocked: true
```

设计意义：

- 正常游玩约一个月后自然“转正”；
- 职业成长快的玩家可通过 Reputation 50 提前转正；
- 不让低 Rep / 慢节奏玩家永远停留在导师陪诊状态。

---

# 3. 试用期结束事件

## 3.1 出场角色

固定：

```text
城宮明日香
神宮寺成美
七瀬恋
坂口隆司
```

## 3.2 事件性质

这不是：

```text
Relationship Event
Romance Event
神宫寺路线升级
七濑恋路线升级
```

而是：

> **职业成长 / 医院制度事件。**

可以有角色味，但默认不改变 Relationship Level。

## 3.3 核心信息

明日香宣布：

```text
坂口已经通过试用期
以后普通门诊可以独立负责
医院希望他开始形成自己的固定工作搭档
```

神宫寺说明：

```text
以后不再每个患者都由她陪着
坂口已经不需要她始终在旁边确认
真正遇到特殊 / 困难病例时，仍然可以找她
```

七瀬恋正式成为第一任专属护士。

---

# 4. 事件对白方向

以下是 tone reference，不要求逐字实现。

### 明日香

> 「一个月了。」
>
> 「你也差不多该从『新人』这一栏里毕业了。」

若因 Reputation 50 提前触发：

> 「看来不用等满一个月了。」
>
> 「既然已经有人开始记得你的名字，就别再一直让成美替你看着。」

### 神宮寺成美

> 「以后普通门诊你自己看。」
>
> 「我不会每个患者都站在旁边替你确认。」

坂口：

> 「毕业了？」

成美：

> 「可以这么理解。」
>
> 「真碰到看不懂的，再来找我。」

### 七瀬恋

> 「那从今天开始，我就是坂口医生的专属护士了。」
>
> 「虽然第一天就认识，也一起工作过很多次……」
>
> 「正式这样说，还是有点不一样呢。」

她可以继续说明：

> 「门诊我会一起。」
>
> 「手术或者病房里需要护士的时候，也可以叫我。」

注意：这句话只表达工作搭档关系，不自动建立手术强制占位，也不要求 V1 新增病房任务系统。

最后保留轻微福利感：

> 「至于其他的事情——」
>
> 「现在暂时不可以哦。」

坂口：

> 「我什么都还没问。」

七瀬恋：

> 「所以我才提前说。」

---

# 5. 默认专属护士

系统解锁时：

```yaml
personal_nurse_id: nanase_ren
```

七瀬恋是第一任固定专属护士。

理由：

```text
Day 1 即与坂口认识
前期已经多次合作
角色定位适合日常护理 / 固定搭档
护士身份灵活
可以自然承担门诊陪诊
```

---

# 6. 专属护士更换

解锁系统后，坂口可以在自己的办公室更换专属护士。

建议 UI：

```text
[专属护士]
当前：七瀬恋

[更换]
```

## 6.1 候选条件

V1 推荐：

```text
met == true
role == nurse
personal_nurse_eligible == true
currently_available == true
```

不要求：

```text
Relationship >= X
Romance
Charm
Surgery
Leadership
```

因为这是：

> **工作搭档选择，不是恋爱对象选择。**

## 6.2 不合适的角色

通过：

```text
personal_nurse_eligible = false
```

排除：

```text
纯管理岗
剧情暂时不可调度
访客
特殊 guest
不承担普通临床护理的角色
```

---

# 7. 专属护士的 V1 核心作用

只锁四项：

```text
1. 固定陪同普通门诊
2. 接替神宫寺的门诊助言功能
3. 门诊中固定可找到并闲聊
4. 每完成一次门诊 Familiarity +1
```

不要把系统扩展成全面护理调度器。

---

# 8. 门诊固定出场

试用期结束前：

```text
current_outpatient_support = Jinguji Narumi
```

试用期结束后：

```text
current_outpatient_support = personal_nurse
```

普通门诊 UI / 场景中：

> **专属护士固定在场。**

如果当前门诊需要护理角色发言：

```text
优先使用 personal_nurse
```

---

# 9. 门诊助言

专属护士接替神宫寺当前已有的：

```text
助言 / hint
```

功能。

重要：

> **护士不会直接告诉玩家病名。**

她只回答：

```text
下一步应该做什么检查
```

或者：

```text
现在已有检查是否已经足够得出正确病名
```

最终病名仍由玩家自己判断并选择。

---

# 10. 助言类型

底层建议只需要两类。

## 10.1 `next_test_hint`

当前资料不足时：

```text
告诉玩家下一步应检查什么
```

示例：

> 「坂口医生，我觉得还需要再确认一下影像。」

> 「现在下结论好像还早，要不要再做一项检查？」

## 10.2 `evidence_sufficiency_hint`

判断当前资料是否已经足够：

```text
YES
→ 现在可以正确诊断

NO
→ 仍需要继续检查
```

示例：

> 「我觉得目前这些结果已经够了。」

或者：

> 「还差一点。现在就下结论的话，我会有点不放心。」

---

# 11. 助言永远正确

V1 明确：

```text
Jinguji advice = 100% correct
Personal Nurse advice = 100% correct
```

原因：

```text
当前门诊没有独立失败系统
助言是 Gameplay support
不是独立诊断模拟
```

因此：

> **不要给不同护士加入误判概率。**

---

# 12. 护士不直接诊断

即使助言永远正确，也不要让护士直接说：

> 「这是急性阑尾炎。」

正确表达应该是：

```text
检查流程判断
+
证据是否充分
```

例如：

> 「这个结果和目前表现是对得上的。」

> 「我觉得再做一下腹部影像会更稳妥。」

> 「现在的资料已经足够支持坂口医生做判断了。」

最终病名仍由：

```text
玩家
```

选择。

---

# 13. 助言语气与个性化

不同护士可以有自己的语气，例如：

```text
温柔
干练
冷淡
活泼
成熟
紧张
认真
毒舌
```

但 V1：

> **不要求所有护士立刻拥有完整个性化助言。**

## 13.1 Fallback 优先

必须先做可靠 fallback。

资料不足：

> 「现在的信息还不够，我建议再检查一下。」

建议下一项检查：

> 「如果要继续确认，我觉得下一步做这个检查比较合适。」

资料已经足够：

> 「我觉得目前的结果已经足够了。」

## 13.2 Character Override

有余力时再增加：

```yaml
personal_nurse_dialogue:
  next_test_hint:
    - ...
  insufficient_evidence:
    - ...
  sufficient_evidence:
    - ...
```

缺失时：

```text
generic fallback
```

绝不能因为某角色还没有专属文本而导致系统不可用。

---

# 14. 七瀬恋的初期语气参考

七瀬恋可稍微柔和。

资料不足：

> 「坂口医生，我觉得再确认一项会比较安心。」

建议检查：

> 「如果是我的话，会想再看看这个结果。」

已足够：

> 「嗯……我觉得现在已经可以判断了。」

这里只是 tone reference，V1 不要求一次写满。

---

# 15. 门诊闲聊

专属护士的另一个核心价值：

> **玩家在门诊中永远知道去哪里可以找到她。**

建议门诊界面增加：

```text
[和专属护士聊两句]
```

或者把她直接作为场景内可点击角色。

---

# 16. 闲聊功能

V1 可以非常轻量。

来源优先级：

```text
1. 特殊剧情 callback
2. Relationship level variant
3. 当前门诊 / 当前工作状态短句
4. generic chatter fallback
```

不要求每次都出现全新内容。

Generic Chatter 示例：

> 「今天好像比昨天忙一点。」

> 「下一位患者已经到了。」

> 「坂口医生，休息一下也可以哦。」

> 「这个门诊室我已经越来越熟了。」

---

# 17. 门诊 Familiarity

每完成一次普通门诊患者周期：

```text
personal_nurse Familiarity +1
```

## 17.1 为什么按“每次门诊”加

当前游戏流程：

```text
一个门诊患者
→ 诊断
→ 必要时进入手术
→ 完成该病例
→ 才刷新下一名患者
```

因此不存在通过反复点击同一门诊来无限刷 Familiarity 的问题。

所以不需要：

```text
daily cap
weekly cap
diminishing return
```

---

# 18. Familiarity 结算时机

推荐在：

```text
该门诊患者 lifecycle 完成
```

时结算。

以当前项目已有 patient lifecycle 的“完成”节点为准。

不要在：

```text
每次点击助言
每次闲聊
每做一个检查
```

时增加 Familiarity。

---

# 19. 手术阶段 — 明确不绑定

这是硬规则：

> **专属护士不会自动占据任何手术岗位。**

进入手术组队后：

```text
玩家正常自由选择团队
```

例如：

```text
Scrub Nurse
Circulating Nurse
Assistant Surgeon
Anesthesiologist
```

完全按照现有系统处理。

---

# 20. 专属护士身份不影响手术组队

即使：

```text
personal_nurse = Nanase Ren
```

玩家仍然可以：

```text
不选择 Nanase
选择其他 Circulating Nurse
选择其他 Scrub Nurse
```

不要：

```text
自动锁定
强制加入
自动占用 slot
给专属护士免费组队权限
```

---

# 21. “手术也可以叫我”的含义

七瀬恋在试用期结束事件里可以说：

> 「手术需要护士的时候，也可以叫我。」

这句话表达的是：

```text
角色关系
固定搭档感
职业亲近感
```

不是新增手术规则。

手术阶段仍完全遵守现有 Team Builder。

---

# 22. 病房事务

事件对白可以保留：

> 「病房里的事情，需要护士的时候也可以交给我。」

但 V1：

> **不要求因此新增一套 Personal Nurse Ward Delegation System。**

如果未来已有病房场景自然支持：

```text
current personal nurse
```

作为发言人，可以接入；但不是本轮实现阻塞项。

---

# 23. 神宮寺成美在毕业后的状态

试用期结束后：

```text
不再固定陪普通门诊
```

但她仍然是：

```text
坂口的前 mentor
医院女医
可攻略角色
特殊病例可咨询对象
剧情角色
```

不要写成：

```text
毕业后神宫寺从职业生活消失
```

未来可允许：

```text
Ask Jinguji for Consultation
```

用于特殊剧情、困难病例、教学事件或角色事件；V1 不需要实现常驻按钮。

---

# 24. 系统沉浸感目标

这个系统的核心不是数值奖励，而是让玩家感觉：

```text
开局：
我跟着神宫寺学

一个月后：
我可以自己看了

再往后：
我有一个每天坐在旁边、
门诊时能找到、
会给我递话、
会和我闲聊的固定护士
```

因此：

> **专属护士应该是坂口“自己的工作搭档”，而不是一项 buff。**

---

# 25. 与 Relationship 的关系

专属护士：

```text
不等于恋爱对象
不等于女朋友
不等于 H 解锁
```

任何符合职业条件的护士都可以成为专属护士。

但：

```text
长期固定合作
→ Familiarity 自然增长
→ 角色关系更容易进入后续事件
```

这是系统的自然结果。

---

# 26. Relationship Callback 预留

例如七瀬恋最初说：

> 「至于其他的事情——现在暂时不可以哦。」

未来如果 Relationship 足够高，可以做 callback。

例如：

坂口：

> 「你以前说过，其他事情暂时不可以。」

恋：

> 「……你居然还记得。」

这属于角色事件，不是专属护士 V1 的系统要求。

---

# 27. 数据建议

## 27.1 Global / Player

```yaml
probation_complete: false
personal_nurse_system_unlocked: false
personal_nurse_id: ""
```

解锁后：

```yaml
probation_complete: true
personal_nurse_system_unlocked: true
personal_nurse_id: nanase_ren
```

## 27.2 Nurse Profile

```yaml
personal_nurse:
  eligible: true

  dialogue:
    next_test_hint: []
    insufficient_evidence: []
    sufficient_evidence: []
    chatter: []
```

所有 dialogue array 允许为空，为空则使用 fallback。

---

# 28. 门诊助言接口建议

不要为专属护士重新造一套独立诊断系统。

尽量复用现有神宫寺 hint resolver。

建议：

```text
resolve_outpatient_support_actor()
```

返回：

```text
if probation_complete == false:
    Jinguji
else:
    personal_nurse
```

现有：

```text
hint availability
next test
evidence sufficient?
```

逻辑不变。

只替换：

```text
speaker
portrait
expression
dialogue variant
```

---

# 29. Fallback 规则

必须保证：

```text
没有角色专属对白
!=
没有助言
```

解析优先级：

```text
character-specific line
↓
personality / tone line（未来可选）
↓
generic personal nurse fallback
```

---

# 30. Office UI

解锁前：

```text
专属护士
[未解锁]
```

或者完全不显示。

解锁后：

```text
专属护士：七瀬恋
[更换]
```

选择界面至少显示：

```text
姓名
立绘 / portrait
当前 Relationship / Familiarity（若现有 UI 已支持）
```

不要新增复杂能力比较，因为 V1 所有护士助言准确率相同。

---

# 31. 更换时的短反应

第一次指定某名护士时，可以有一条非常短的确认：

> 「以后门诊跟坂口医生一起？明白。」

或者 fallback：

> 「好的，请多关照。」

不要求每名护士立即拥有完整专属场景。

---

# 32. V1 明确不实现

```text
护士误诊
护士助言准确率
专属护士能力值
固定搭档 chemistry meter
门诊失败系统
专属护士专属手术 slot
自动锁定 Circulating Nurse
自动锁定 Scrub Nurse
强制专属护士进入每台手术
专属护士专属病房任务树
每日 Familiarity cap
每次检查 Familiarity +
每次闲聊 Familiarity +
```

---

# 33. Prototype Acceptance Tests

## Test A — 试用期未结束

条件：

```text
Day < 30
Rep < 50
```

预期：

```text
门诊支持角色 = 神宮寺成美
专属护士功能未开放
```

## Test B — Day 30

条件：

```text
Day >= 30
probation_complete == false
```

预期：

```text
触发四人事件
probation_complete = true
personal_nurse_system_unlocked = true
personal_nurse_id = nanase_ren
```

## Test C — Reputation 提前毕业

条件：

```text
Day < 30
Rep >= 50
```

预期：

```text
提前触发同一事件
之后 Day 30 不重复触发
```

## Test D — 门诊助言

毕业后：

```text
personal_nurse = Nanase Ren
```

预期：

```text
原神宫寺助言位置
→ 由七瀬恋发言

七瀬不会直接说病名
只说：
- 下一项建议检查
- 当前资料是否足够
```

结果：

```text
100% 正确
```

## Test E — Familiarity

完成一次完整门诊患者周期：

```text
Nanase Familiarity +1
```

点击助言、闲聊、检查均不额外增加。

## Test F — 更换专属护士

办公室：

```text
七瀬恋
→ 另一名 eligible nurse
```

下一次门诊：

```text
新护士固定出场
新护士提供助言
新护士可闲聊
新护士获得 +1 Familiarity
```

## Test G — 手术不绑定

当前：

```text
personal_nurse = Nanase Ren
```

进入 Team Builder。

预期：

```text
Nanase 不自动锁定任何岗位
玩家可以完全不选她
```

---

# 34. V1 最终原则

> **神宫寺负责把坂口带到“可以独立看诊”。**

> **专属护士负责让独立后的门诊不变成一个孤零零的菜单。**

> **她是固定陪诊搭档，不是手术强制队员。**

> **助言永远正确，但不直接报病名。**

> **不同护士的差异首先来自语气，而不是数值。**

> **专属护士真正的奖励，是长期共事带来的存在感与熟悉感。**

# END
