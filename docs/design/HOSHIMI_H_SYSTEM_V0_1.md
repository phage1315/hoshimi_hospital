# Hoshimi Hospital — Adult Intimacy / H System
## 轻量成人互动系统 V0.1
### Codex Prototype Design — 2026-10-04

> **文件性质：Prototype System Design / 可交 Codex 试做**
>
> 本文件只定义 H System 的通用底层。
>
> **不在本文件设计任何具体角色的首次 H 解锁剧情。**
>
> 小夜香 / 折川等角色的首次解锁事件、固定地点、固定服装、专属对白与 CG，后续单独设计并接入本系统。

---

# 0. Core Goal

Hoshimi 的 H System 不做复杂色情模拟。

目标是：

> **用少量 Gameplay 给 VN 成人场景增加“这是玩家亲手推进的”感觉。**

V0.1 核心：

```text
Character
↓
Location
↓
Outfit / Presentation
↓
Foreplay Interaction
↓
Excitement
↓
Character Initiative
↓
Position Choice
↓
CG
↓
Short After Scene
```

表现主要依赖：

```text
角色立绘
短对白
音效文字
CG
fade
```

不要求露骨正文。

---

# 1. Adult / Relationship Requirement

所有可进入 H System 的角色必须：

```text
adult == true
```

并且已经完成：

```text
authored adult-intimacy milestone
```

完成首次成人亲密 milestone 后：

```text
repeatable_h_unlocked = true
```

---

# 2. Relationship Abstraction

V0.1 使用明确的游戏抽象：

> **首次 Adult Intimacy milestone 完成以后，代表两个人已经建立稳定、持续、自愿的成人亲密关系。**

因此 Repeatable H：

```text
不做每次随机“今晚愿不愿意”
不做重复 consent roll
不做 Relationship 成功率判定
```

但是：

> **基础 H 解锁，不代表所有地点 / 服装 / 特殊 presentation 自动解锁。**

特殊内容仍然必须通过：

```text
角色事件
Relationship progression
special unlock flag
```

开放。

---

# 3. Two Entry Types

H System 有两种入口。

## 3.1 Authored Milestone H

用于：

```text
Relationship Lv4 等首次成人亲密事件
```

作者固定：

```text
location
outfit
opening dialogue
fallback / milestone CG
after-scene dialogue
```

但中间仍进入同一套 Gameplay：

```text
Foreplay
Excitement
Initiative
Position
CG
```

即：

> **剧情外壳固定，互动过程可玩。**

## 3.2 Repeatable H

首次 milestone 完成后开放。

玩家可以选择：

```text
已解锁地点
已解锁服装
```

然后进入同一套 Gameplay。

---

# 4. Minimal Gameplay Loop

```text
Choose Location
↓
Choose Outfit
↓
Enter H Interaction HUD
↓
Choose Foreplay Action
↓
Choose Body Target
↓
Character Reaction
↓
Excitement increases
↓
Possible Initiative Event
↓
Excitement reaches MAX
↓
Choose Position
↓
Resolve CG
↓
Short dialogue / SFX
↓
Fade
↓
After Scene
```

---

# 5. Excitement

只做一个数值：

```text
Excitement = 0 .. 100
```

不要做：

```text
player arousal
partner arousal
stamina
orgasm count
pleasure combo
```

每次有效 Foreplay Action：

```text
Excitement += gain
```

达到 100 后进入 Position Choice。

建议第一版：

```text
normal action        +15
preferred action     +20
strong preference    +25
weak / awkward       +10
```

数值必须 data-driven。

---

# 6. Foreplay Actions

V0.1 只做三种：

```text
touch
kiss
lick
```

中文 UI：

```text
摸
吻
舔
```

不要一开始扩展大量动作。

---

# 7. Body Targets

V0.1 使用 broad target：

```text
face
neck
chest
waist
thigh
intimate
```

如果项目已有身体 hotspot schema，优先复用现有 region id。

一次操作：

```text
action + target
```

系统读取：

```text
character preference
current outfit
current location
```

然后输出：

```text
Excitement gain
character reaction line
expression change
optional SFX text
```

---

# 8. Character Preferences

每个角色只需要少量差异。

建议：

```yaml
foreplay_preferences:
  touch: normal
  kiss: preferred
  lick: normal
```

也可有少量 target bias：

```yaml
target_preferences:
  neck: preferred
  chest: normal
```

不要做完整：

```text
action × target × outfit × location
```

数值矩阵。

---

# 9. Initiative / 主动性

推荐三类：

```text
proactive
responsive
switch
```

## proactive

角色会比较主动推进。

Excitement 达到某阈值，例如：

```text
>= 60
```

可触发一次 Initiative Event。

例如：

> 「等一下。」
>
> 「这次让我来。」

UI：

```text
[顺着她]
[继续由我来]
```

## responsive

角色主要回应玩家，不频繁抢流程。

高 Excitement 时仍可提出一句愿望 / 请求。

## switch

根据：

```text
location
outfit
relationship state
special flag
```

改变主动程度。

V0.1 每场最多 1 次主要 Initiative Event。

---

# 10. Initiative Is Flavor, Not Control Theft

角色主动不能强制覆盖玩家选择。

推荐：

```text
character suggests
↓
player may follow or choose differently
```

不要让角色随机锁死玩家操作。

---

# 11. Position Choice

Excitement MAX 后：

```text
Position Choice
```

V0.1 候选：

```text
top
bottom
rear
69
```

中文 UI 可按剧情自然翻译。

---

# 12. Position Is Narrative Only

这是硬规则：

> **Position Choice 不要求 Position-specific CG。**

Position 只影响：

```text
短对白
音效文字
session record
角色 callback
```

不要建立：

```text
character × location × outfit × position
```

美术矩阵。

---

# 13. Locations

V0.1 通用地点候选：

```text
hotel
office
on_call_room
operating_room
ward
gynecology_room
```

没有角色必须全部支持。

每个角色只显示：

```text
unlocked_h_locations
```

---

# 14. Location Role

地点主要改变：

```text
opening text
ambient SFX
available outfits
special interaction flavor
special CG eligibility
```

不要大幅改变 Excitement 数值。

### Hotel

```text
baseline
private
ordinary adult intimacy
```

### Office / On-call Room

```text
after-hours
work identity still present
white coat / uniform flavor
```

### Operating Room

```text
medical roleplay
mask / gloves / scrubs
OR table flavor
```

只给符合角色 / 路线的角色开放。

### Ward / Gynecology Room

V0.1 主要作为 location flavor，不单独造小游戏。

---

# 15. Outfit / Presentation

V0.1 不做复杂实时换装。

只做 Outfit Preset。

候选：

```text
nude
mask_gloves
nurse_uniform
white_coat_only
partial_scrubs
character_signature
```

不是每个人都拥有所有 Outfit。

每个角色：

```text
基础 1–2 个
+
以后 1–3 个 signature unlock
```

即可。

---

# 16. Outfit Selection

Repeatable H：

```text
选择当前已解锁 outfit
```

Milestone H：

```text
outfit 由作者固定
```

未解锁 Outfit：

```text
不显示
```

不要显示后再随机拒绝。

---

# 17. Character Suggested Outfit

某些 proactive / switch 角色可以主动建议喜欢的 outfit。

例如：

```text
character_suggested_outfit = outfit_id
```

UI：

```text
[就这样]
[换一种]
```

玩家仍保留选择权。

---

# 18. Sprite Asset Strategy

H Gameplay 过程中，最重要的美术资源是：

> **角色立绘，而不是大量 CG。**

## Minimum Per Character

V0.1：

```text
1 nude / undressed sprite set
```

建议支持：

```text
neutral
embarrassed
excited
character-specific expression
```

如果现有角色系统支持面部差分，不要求每个表情重新画完整身体。

## Special Outfit Sprites

以后每个角色按需要增加：

```text
1–2 special outfit sprite sets
```

不阻塞原型。

---

# 19. Reuse Existing Medical Assets

尽量复用：

```text
surgical patient sprites
pre-op body assets
medical uniform sprites
scrubs
mask
gloves
white coat
patient body proportions
```

不要为 H System 再建立一套独立身体 pipeline。

---

# 20. CG Asset Strategy

V0.1 每个 H-enabled 角色：

```text
只要求 1 张 fallback H CG
```

即可上线。

推荐字段：

```text
fallback_h_cg
```

要求：

```text
不要过度依赖某一种姿势
不要过度依赖某一个地点
角色必须明显可识别
构图适合重复使用
```

---

# 21. Special CG Unlock

以后每个角色可增加：

```text
2–3 张 special unlock CG
```

绑定：

```text
特定地点
特定 Outfit
特定 Relationship milestone
特定角色 fantasy
```

不要做全组合覆盖。

---

# 22. CG Resolver

V0.1 推荐：

```text
if authored milestone CG exists:
    use milestone CG
elif matching unlocked location+outfit special CG exists:
    use special CG
elif matching unlocked outfit special CG exists:
    use special CG
elif matching unlocked location special CG exists:
    use special CG
else:
    use character.fallback_h_cg
```

明确：

```text
position NOT part of CG key
```

---

# 23. Short Dialogue / SFX

V0.1 不需要大量正文。

一次互动：

```text
1 short reaction line
+
optional SFX text
```

保持简短。

Excitement MAX + Position chosen 后：

```text
short position-specific line
↓
optional SFX
↓
fade
↓
CG
↓
short closing line
```

不需要描述完整过程。

---

# 24. After Scene

After Scene 只需要：

```text
1–5 句
```

用于：

```text
角色性格
地点 callback
第二天工作 callback
relationship flavor
```

不要每次 H 都变成完整剧情事件。

---

# 25. No Default Stat Farming

默认：

```text
Charm +0
Relationship +0
Familiarity +0
Professional Reputation +0
```

内容本身就是奖励。

只有 authored milestone 可以明确给予一次性 flag / 数值。

---

# 26. Time Cost

Repeatable H：

```text
consumes appropriate existing time slot
```

例如：

```text
evening action
Sunday action
special after-hours slot
```

复用现有 Calendar / Action Economy。

不要创造 H 专属时间货币。

---

# 27. Save Data — Character Unlock

推荐：

```yaml
adult_intimacy:
  repeatable_h_unlocked: true
  unlocked_locations:
    - hotel
  unlocked_outfits:
    - nude
  unlocked_special_cgs:
    - ...
```

---

# 28. Save Data — Session

```yaml
h_session:
  actor_id:
  location:
  outfit:
  excitement:
  initiative_triggered:
  position:
```

结束后清空 session。

---

# 29. Character Data — Minimum

```yaml
h_profile:
  enabled: true
  initiative: proactive | responsive | switch
  fallback_h_cg: cg_id
  base_locations:
    - hotel
  base_outfits:
    - nude
  foreplay_preferences:
    touch: normal
    kiss: preferred
    lick: normal
```

以后可选增加：

```yaml
target_preferences:
  neck: preferred
initiative_overrides:
  operating_room: proactive
special_outfits:
  - outfit_id
special_cgs:
  - ...
```

---

# 30. UI — Location / Outfit

Location Select：

```text
只显示已解锁地点
```

如果只有一个：

```text
直接进入
```

Outfit Select：

```text
只显示当前地点可用 + 已解锁 outfit
```

如果只有一个：

```text
直接使用默认 outfit
```

---

# 31. H Interaction HUD

V0.1 最小：

```text
Character Sprite

Excitement Bar

Action:
[摸]
[吻]
[舔]

Target:
[脸]
[颈]
[胸]
[腰]
[大腿]
[私密]
```

不需要复杂动画。

---

# 32. Initiative Pop-up

触发时：

```text
Character short line
[顺着她]
[继续由我来]
```

V0.1 每场最多一次主要 Initiative Event。

---

# 33. Position HUD

Excitement MAX：

```text
[她在上面]
[我在上面]
[后面]
[69]
```

具体中文后续可润色。

Position 只影响：

```text
短对白
session record
optional callback
```

不影响 CG selection。

---

# 34. Milestone H Integration

未来角色 Relationship Lv4 等事件：

```text
Scripted Opening
↓
call H System with:
    fixed_location
    fixed_outfit
    milestone_mode = true
    milestone_cg_override optional
↓
Gameplay
↓
Position
↓
CG
↓
Scripted After Scene
↓
repeatable_h_unlocked = true
```

---

# 35. Repeatable H Integration

普通入口：

```text
character interaction
↓
if repeatable_h_unlocked:
    show adult intimacy option
↓
location select
↓
outfit select
↓
H System
```

---

# 36. Special Unlock Philosophy

高 Relationship / 专属事件以后可以解锁：

```text
new location
new outfit
new special CG
new initiative behavior
```

特殊内容本身就是 Relationship progression 的 Gameplay payoff。

---

# 37. Availability Simplification

V0.1：

```text
repeatable_h_unlocked == true
```

则基础成人互动默认可用。

不做：

```text
今天心情不好随机拒绝
每次掷同意概率
隐藏 consent meter
```

特殊地点 / 服装未解锁：

```text
不显示
```

---

# 38. Authoring Boundary

本系统只用于：

```text
成年人之间
已建立的自愿成人亲密关系
```

不要把：

```text
真实患者脆弱状态
镇静
全麻
失去意识
```

作为 H System 的可操作入口。

医院 roleplay / 医疗地点必须属于角色主动参与的成人场景，与真实患者流程分开。

---

# 39. Explicitly NOT in V0.1

不要实现：

```text
实时物理互动
鼠标拖拽身体
连续动画模拟
stamina meter
双人 pleasure meter
高潮次数
失败状态
怀孕系统
嫉妒系统
随机拒绝
姿势专属 CG requirement
地点 × 衣服 × 姿势全排列
复杂换装
完整声音系统
实时 3D
```

---

# 40. V0.1 Asset Minimum

每个测试角色：

```text
1 nude / undressed sprite set
1 fallback H CG
```

如果已有：

```text
1 special outfit sprite
```

可以顺手接入，但不阻塞原型。

---

# 41. Prototype Acceptance Test

用任一成年、手动解锁 H 的测试角色：

```text
repeatable_h_unlocked = true
```

进入：

```text
Hotel + Nude
```

应能：

```text
1. 显示角色立绘
2. 使用 touch / kiss / lick
3. 选择 target
4. Excitement 增长
5. 显示不同短反应
6. 高 Excitement 时按 initiative 类型出现一次主动事件
7. Excitement 100 后出现四个 position choice
8. Position 不改变 CG key
9. 播放 fallback H CG
10. 显示简短 After Scene
11. 返回正常游戏
```

---

# 42. Special CG Acceptance Test

给测试角色临时增加：

```text
location = operating_room
outfit = mask_gloves
special CG = cg_test_special
```

如果：

```text
location + outfit match
+
CG unlocked
```

使用：

```text
cg_test_special
```

否则：

```text
fallback_h_cg
```

---

# 43. Milestone Acceptance Test

测试一个假 milestone：

```text
fixed_location = hotel
fixed_outfit = nude
```

流程：

```text
scripted opening
↓
H Gameplay
↓
position
↓
milestone / fallback CG
↓
scripted ending
↓
repeatable_h_unlocked = true
```

证明：

> **首次剧情 H 和自由 H 共用同一 Gameplay Core。**

---

# 44. Initial Prototype Characters

本文件不锁具体角色内容。

下一步单独设计：

```text
南条小夜香
折川皐月
```

作为两个性格明显不同的测试角色。

目标：

```text
同一个 H System
↓
通过 Initiative / Dialogue / Outfit / Location
↓
呈现不同人物感觉
```

具体 Lv4 解锁剧情不在本文件内。

---

# 45. Final V0.1 Principle

不要追求：

> **模拟性行为。**

而要追求：

> **让玩家觉得这是这个角色、这个地点、这个关系阶段发生的一次成人互动。**

V0.1 只要做到：

```text
地点有区别
服装有区别
前戏可以点
Excitement 会涨
角色有主动性
玩家可以选姿势
CG 有奖励感
```

就已经足够。

最重要的制作原则：

> **立绘负责互动过程。**
>
> **CG 负责奖励瞬间。**
>
> **姿势负责玩家脑补。**
>
> **特殊地点 / 特殊服装负责角色差异。**

# END
