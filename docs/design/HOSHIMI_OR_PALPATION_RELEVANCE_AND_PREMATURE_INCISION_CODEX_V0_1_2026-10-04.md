# Hoshimi Hospital — OR Table Palpation Procedure Relevance & Premature Incision
## 手术台触诊：术式相关反馈 + 违规提前下刀
### Codex Handoff V0.1 — 2026-10-04

> **文件性质：Implementation Addendum / 当前触诊原型的最小扩展**
>
> 本文件不是重做 `HOSHIMI_OR_TABLE_PALPATION_SYSTEM.md`。
>
> 目标是保留 Codex 已经做出的简单、直接、好玩的原型，只增加一层：
>
> 1. 当前术式决定哪些身体热点有正常医疗意义；
> 2. 有医疗意义的热点可出现少量术式专属反馈；
> 3. 没有专属反馈时继续使用当前 generic reaction；
> 4. “手术刀”保持为独立恶趣味 tool mode，不参与触诊相关性判断。
>
> 原则：
>
> **不要把触诊扩成新的复杂诊断系统。**
>
> 第一版必须保持：
>
> ```text
> 简单
> 可测试
> 数据驱动
> 不改现有点击手感
> 不制造组合爆炸
> ```

---

# 1. 现有原型必须保留

当前触诊界面已有：

```text
身体热点
+ 轻触 / 常规 / 深压
+ 患者即时对白
+ Fear / Pain / Dignity / Cooperation 变化
```

当前主要热点：

```text
abdomen          腹部
breast_left      左乳
breast_right     右乳
nipple_left      左乳头
nipple_right     右乳头
chest            胸部 / 胸壁
genital          阴部 / 外阴区域
```

如果现有实现内部 hotspot id 不同：

> **沿用现有 id，不为了本文重命名。**

---

# 2. Generic Reaction Layer

当前 Codex 已实现 / 正在实现的热点反馈继续作为最底层 fallback。

## 2.1 腹部

按照力度产生：

```text
轻触
→ 轻微不适 / 很少疼痛

常规
→ 普通疼痛反应

深压
→ 明显叫痛
```

## 2.2 乳房

generic 方向：

> 「好羞耻……」
>
> 「医生，开刀又不是开这里吧？」

## 2.3 阴部 / 外阴区域

generic 方向：

> 「医生……不要摸那里啊……」
>
> 「好羞耻……」

可保留少量轻 H / 羞耻混合 variant。

## 2.4 乳头

generic 方向：

> 「啊……！」
>
> 「那里很敏感……」

主要表现：

```text
Dignity下降
Fear少量变化
Pain / 敏感反应按当前实现
```

## 2.5 胸部 / 胸壁

保持普通胸壁触诊反应。

---

# 3. New Layer — `palpation_profile`

每个支持触诊的 surgery / case 可以提供：

```text
palpation_profile
```

第一版只允许四类：

```text
abdominal
breast
gynecology_pelvic
thoracic_cardiac
```

如果没有配置：

```text
palpation_profile = generic
```

此时所有热点继续使用现有 generic reaction。

---

# 4. Procedure Relevance

每个 profile 只需要把当前热点分类为：

```text
primary
adjacent
unrelated
```

## `primary`

当前术式真正相关的正常检查区域。

第一次以合理力度触诊时：

```text
可以出现 procedure-specific reaction / finding
```

## `adjacent`

医学上有一定相关性，但不是主要检查目标。

可以出现：

```text
有限反馈
```

但不需要提供重要收益。

## `unrelated`

和当前术式没有明显关系。

继续使用：

```text
generic reaction
```

患者可以自然质疑：

> 「开刀又不是开这里吧？」

医学收益：

```text
none
```

---

# 5. V0.1 Profile Mapping

不需要逐个术式建立复杂表。

第一版只做下面四个 profile。

## 5.1 `abdominal`

```text
abdomen          primary
breast_left      unrelated
breast_right     unrelated
nipple_left      unrelated
nipple_right     unrelated
chest            unrelated
genital          unrelated
```

典型：

### 腹部

第一次合理触诊可以出现：

> 「……这里有一点痛。」
>
> 「右边按下去更不舒服……」

实际具体文字可根据 case / surgery 稍作替换。

### 乳房 / 乳头 / 阴部

继续 generic：

> 「医生……开刀又不是开这里吧？」

---

## 5.2 `breast`

```text
abdomen          unrelated
breast_left      primary / case-side dependent
breast_right     primary / comparative
nipple_left      primary_or_adjacent
nipple_right     primary_or_adjacent
chest            adjacent
genital          unrelated
```

V0.1 不要求复杂左右侧病灶逻辑。

如果病例已有：

```text
affected_side
```

则：

```text
患侧乳房 = primary
对侧乳房 = adjacent / comparative
```

如果没有：

```text
双乳都允许 primary-style medical reaction
```

### 乳房专属反馈

例如：

> 「嗯……就是这里，按下去会不舒服。」
>
> 「那里碰到的时候有一点痛……」

### 乳头

乳房手术中不再使用：

> 「开刀又不是开这里吧？」

而改成：

> 「啊……那里也要确认吗……？」
>
> 「那里很敏感……」

仍然可以羞耻，但患者理解它属于乳房检查范围。

---

## 5.3 `gynecology_pelvic`

```text
abdomen          primary
breast_left      unrelated
breast_right     unrelated
nipple_left      unrelated
nipple_right     unrelated
chest            unrelated
genital          primary_or_adjacent
```

### 腹部

> 「下面这里按下去有一点胀……」
>
> 「这里会不舒服。」

### 阴部 / 外阴区域

不再只使用：

> 「医生不要摸那里！」

改为允许：

> 「……这里也需要检查吗？」
>
> 「我知道是检查，可还是好羞耻……」

仍然允许轻 H / 羞耻反应。

核心区别：

```text
unrelated:
“为什么要碰这里？”

relevant:
“我知道为什么，但还是很羞耻。”
```

---

## 5.4 `thoracic_cardiac`

```text
abdomen          unrelated
breast_left      adjacent
breast_right     adjacent
nipple_left      unrelated
nipple_right     unrelated
chest            primary
genital          unrelated
```

### 胸部

正常医疗反馈：

> 「这里按着有一点闷……」
>
> 「胸口这里有些不舒服。」

### 乳房

允许 adjacent：

> 「这里也和开胸有关系吗……？」

不要把胸部 / 心脏术前检查写成乳房手术。

### 乳头

继续 generic / unrelated。

---

# 6. Reaction Resolution Order

触诊点击后的对白选择顺序：

```text
1. scalpel mode?
   YES → premature_incision event
   NO  → palpation resolver

2. 当前 palpation_profile 是否有该 hotspot 专属 relevant reaction?
   YES → procedure-specific reaction

3. 是否有 adjacent reaction?
   YES → adjacent reaction

4. 否则
   → 现有 generic hotspot reaction
```

不要为了 procedure relevance 删除现有 generic reaction。

---

# 7. Medical Feedback Reward — Keep It Minimal

正常触诊需要有一点“我做对了检查”的反馈。

但 V0.1 不要接入：

```text
Surgery XP
Visibility buff
Crisis reduction
automatic success bonus
new diagnosis tree
```

第一版只做：

```text
第一次对 primary hotspot 使用合理力度
→ 显示一次术区相关反馈
→ 标记该 relevant region 已经有效触诊
```

建议状态：

```text
palpation_findings_confirmed: string[]
```

例如：

```text
"abdomen"
"left_breast"
"genital"
"chest"
```

---

# 8. UI Feedback

第一次有效检查 primary 区域时可以短暂显示：

```text
术区反应已确认
```

或者：

```text
术前触诊：有效
```

不要弹大型奖励窗口。

---

# 9. Repeated Palpation

这是本系统的重要设计点。

第一次合理触诊：

```text
有医疗反馈
+
患者状态变化
```

同一 primary region 之后继续反复按：

```text
不再获得新的医疗收益
但
Fear / Pain / Dignity / Cooperation
仍然正常变化
```

因此：

```text
第一次
→ 正常临床检查

第二次
→ 可能是进一步确认

之后继续
→ 系统不阻止
→ 但已经没有新增医疗价值
```

玩家为什么继续：

> 不由系统解释。

---

# 10. Pressure / 力度

继续沿用当前：

```text
light
normal
deep
```

不要建立连续压力模拟。

## 10.1 Light

```text
患者负担低
Fear / Pain 增量低
信息反馈偏浅
```

## 10.2 Normal

```text
默认主力
信息 / 患者负担平衡
```

推荐作为：

> **第一次 primary hotspot 有效触诊的最常见力度。**

## 10.3 Deep

```text
Pain ↑
Fear ↑
可能 Dignity ↓
```

但：

> **不要设计成“深压必然获得更多医学信息”。**

如果该 region 已经确认：

```text
深压不再产生新 finding
```

---

# 11. Personality — Explicitly Deferred

未来可以加入：

```text
shy
anxious
stoic
self_deprecating
```

使同一 finding 用不同说法表达。

例如：

```text
finding = abdominal tenderness
```

未来：

```text
shy
→ 「……这里有一点痛。」

anxious
→ 「痛！是不是这里真的有问题？」

stoic
→ 「这里比较痛。还能忍。」

self_deprecating
→ 「对，就是这里……至少终于按对地方了。」
```

但 V0.1：

```text
不实现 personality-specific palpation matrix
```

先保留 schema / future hook 即可。

---

# 12. Scalpel Mode — Independent Tool

左侧新增：

```text
手术刀
```

选择后：

```text
tool_mode = scalpel
```

鼠标：

```text
切换为手术刀 cursor / icon
```

---

# 13. Scalpel Does NOT Use Procedure Relevance

一旦：

```text
tool_mode == scalpel
```

点击任何身体热点：

```text
不要进入 palpation resolver
不要判断 primary / adjacent / unrelated
```

直接：

```text
trigger premature_incision
```

原因：

> 这是故意越过正常术前流程的恶趣味 scripted action，不是正常触诊。

---

# 14. `premature_incision` V0.1

触发后：

患者：

> 「呀啊啊啊——！！」

护士立即插入：

> 「医生！你怎么能不消毒、不麻醉就下刀呢？！」

状态：

```text
Pain = MAX
```

Fear：

```text
明显增加
```

Dignity / Cooperation：

```text
允许按当前实现有少量 / 中度变化
```

Blood Loss：

```text
V0.1 可保持 0 或极少量
```

不要因为这个小恶趣味功能扩展真实切伤模拟。

---

# 15. Premature Incision Flow

触发后：

```text
premature_incision = true
↓
显示患者尖叫
↓
显示护士惊恐对白
↓
写入患者状态
↓
结束 palpation screen
↓
强制进入 anesthesia selection
```

不要：

```text
留在当前界面无限连续下刀
```

第一版一次触发即可。

---

# 16. Interaction with Surgery Crisis System

不需要写：

```text
premature_incision
→ surgery failure chance + X%
```

患者状态已经会自然产生后果。

例如：

```text
Pain = MAX
Fear high
```

如果随后玩家选择：

```text
No Anesthesia
```

则正式手术开始以后：

```text
Fear / Pain
→ 自动提高 Physiologic Crisis Chance
```

如果选择全麻：

```text
全麻建立以后 Fear / Pain 不再显著贡献术中 Crisis
```

因此：

> **恶趣味行为与手术成败系统通过已有患者状态自然连接。**

不要再增加特殊惩罚公式。

---

# 17. Dignity / Cooperation

继续遵守当前普通手术设计：

```text
Dignity
→ 羞耻 / 暴露 / “认命感” / fan-service / dialogue

Cooperation
→ 配合感 / 顶嘴 / 犹豫 / interaction flavor
```

V0.1：

```text
都不直接触发普通手术 Failure
```

触诊可以改变它们，但不需要在本文扩展失败条件。

---

# 18. Fear / Pain

触诊可以：

```text
Fear ↑
Pain ↑
```

这些状态会带入：

```text
anesthesia selection
↓
surgery session
```

并在清醒 / 无麻醉等路线中影响：

```text
Physiologic Crisis Chance
```

因此触诊不是完全孤立小游戏。

---

# 19. V0.1 Data Shape

可采用类似：

```json
{
  "palpation_profiles": {
    "abdominal": {
      "abdomen": "primary",
      "breast_left": "unrelated",
      "breast_right": "unrelated",
      "nipple_left": "unrelated",
      "nipple_right": "unrelated",
      "chest": "unrelated",
      "genital": "unrelated"
    }
  }
}
```

reaction 数据可单独：

```json
{
  "profile": "breast",
  "region": "breast_left",
  "relevance": "primary",
  "pressure": "normal",
  "lines": [
    "「嗯……就是这里，按下去会不舒服。」",
    "「这里碰到的时候有一点痛……」"
  ]
}
```

具体文件拆分方式由 Codex 根据当前数据组织决定。

---

# 20. Minimum Implementation

本轮只要求：

```text
A. 保留当前触诊原型
B. 保留所有 generic hotspot reaction
C. 增加 4 个 palpation_profile
D. relevant hotspot 可以覆盖 generic reaction
E. 第一次 primary 合理触诊有一次小型“术区反应已确认”
F. 重复触诊不再增加医学收益
G. 重复触诊仍继续改变患者四项状态
H. 手术刀作为独立 tool mode
I. 手术刀点击任意位置触发一次 premature_incision
J. premature_incision 后强制进入麻醉选择
```

---

# 21. Explicitly NOT in This Pass

不要顺手增加：

```text
自由画切口线
触诊直接改变 Visibility
触诊直接增加 Surgery XP
触诊直接降低 Crisis Chance
复杂 Exam Reliability
完整诊断树
多疾病鉴别
每个术式独立 hotspot map
Personality × Region × Pressure 全组合对白
触诊动画系统重做
手术刀真实切伤模拟
术前逃跑
Dignity Breakdown Failure
Cooperation Breakdown Failure
```

以上以后需要再做。

---

# 22. Acceptance Examples

## Test A — Appendectomy / Abdominal Profile

点击：

```text
abdomen + normal
```

预期：

```text
procedure-specific abdominal reaction
术区反应已确认
Fear / Pain / Dignity / Cooperation 正常改变
```

再次：

```text
abdomen + normal
```

预期：

```text
仍有 patient reaction
不再获得新的 medical confirmation
```

点击：

```text
breast
```

预期：

```text
generic embarrassed / unrelated line
例如：
“医生……开刀又不是开这里吧？”
```

---

## Test B — Breast Surgery

点击：

```text
breast + normal
```

预期：

```text
breast-procedure-specific reaction
不是“开刀又不是开这里”
```

点击：

```text
nipple
```

预期：

```text
乳房术式相关 + 敏感 / 羞耻反应
```

点击：

```text
genital
```

预期：

```text
generic unrelated reaction
```

---

## Test C — Gynecology / Pelvic

点击：

```text
abdomen
```

预期：

```text
relevant
```

点击：

```text
genital
```

预期：

```text
relevant / adjacent embarrassment line
患者知道是检查，但仍羞耻
```

点击：

```text
breast
```

预期：

```text
generic unrelated
```

---

## Test D — Thoracic / Cardiac

点击：

```text
chest
```

预期：

```text
primary reaction
```

点击：

```text
breast
```

预期：

```text
adjacent reaction
```

点击：

```text
nipple
```

预期：

```text
generic unrelated reaction
```

---

## Test E — Scalpel

任何 profile：

```text
选择“手术刀”
↓
cursor changes
↓
点击任意身体区域
```

预期：

```text
患者尖叫
护士：
“医生！你怎么能不消毒、不麻醉就下刀呢？！”

Pain = MAX
Fear ↑
premature_incision = true
↓
强制进入麻醉选择
```

不应：

```text
继续留在触诊界面重复下刀
```

---

# 23. Final Design Principle

触诊系统第一版的正常玩法价值：

> **让玩家通过当前术式理解“哪里是正常应该检查的地方”，并获得一次简单的术前身体反馈。**

恶趣味价值：

> **系统不会因为医学收益已经结束就阻止玩家继续触诊；患者四项状态仍然会继续变化。**

手术刀：

> **作为独立、明显越过正常流程的黑色幽默按钮存在。**

最终结构：

```text
身体点击
↓
当前 tool
├─ Palpation
│   ↓
│   procedure relevance
│   ↓
│   procedure-specific reaction
│   or generic fallback
│
└─ Scalpel
    ↓
    premature_incision
    ↓
    forced anesthesia selection
```

核心目标：

> **正常玩家能看懂临床逻辑；XP / 恶趣味玩家仍然有空间自己玩；Codex 不需要为此新造一个大型系统。**

# END
