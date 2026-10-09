# Hoshimi Hospital — 术中危机巡回护士播报层 V0.1
## Intraoperative Crisis Circulating-Nurse Callout Layer
### Codex Implementation Spec

> **文件性质：Implementation-Ready Presentation Layer Spec**
>
> **推荐稳定文件名：**
>
> `HOSHIMI_SURGERY_CRISIS_NURSE_CALLOUT_LAYER_V0_1.md`
>
> **目标：**
>
> 在不改变现有术中危机概率、严重度、成功率、处理选项和失败逻辑的前提下，为普通手术的随机术中危机增加：
>
> - 一个随机的“危机表现类型”；
> - 当前巡回护士的立绘；
> - 一句与人物性格相符的危机播报；
> - 少量 Hoshimi 式黑色幽默 / 粗线条口吻；
> - 更强的“手术室里真的有人发现患者出问题了”的现场感。
>
> **本文件只增加 Presentation / Flavor Layer。**
>
> **不要把它实现成新的生理模拟系统。**

---

# 0. 与现有系统的关系

本规格建立在现有术中危机系统之上。

现有危机系统已经负责：

```text
危机是否触发
危机严重度
当前第几次处理
玩家三个处理选择
各选择成功率 / 时间代价
后续 rescue / abort
最终 Surgery Outcome
```

本文件：

> **全部不修改。**

新增部分只回答：

> “这一次随机危机，在画面和角色对白里表现成什么？”

因此：

```text
Gameplay Crisis
+
Presentation Flavor
```

必须保持分离。

---

# 1. 当前 UI 问题

现有 Full Surgery 危机界面大致表现为：

```text
术中生理危机 · 严重 · 第1次处理

[暂停操作，全力稳定患者]
[保持当前术野，让团队处理]
[先完成当前关键动作再处理]
```

功能已经成立。

但演出问题是：

> **危机直接由系统 UI 宣布。**

玩家更容易感受到：

> “游戏随机出了一个 crisis menu。”

而不是：

> “手术室里某个医护突然发现患者状态异常。”

第一版改动应让顺序变成：

```text
随机危机发生
↓
当前巡回护士立绘出现
↓
护士在现有对话框中喊一句危机播报
↓
原有危机标题与处理选项保持可见
↓
玩家直接选择处理方式
```

---

# 2. 核心设计原则

## 2.1 不新增后台连续生理数据

不要为了本系统创建：

```text
real blood pressure
real heart rate
real SpO2 curve
ECG simulation
ventilation waveform
diagnostic disease model
```

当前系统既然本质上是：

> **随机术中生理危机**

就保持轻量。

危机触发时只新增：

```text
crisis_flavor_id
```

用于文本与画面。

---

## 2.2 Flavor 不影响现有算法

例如：

```text
crisis severity = severe
crisis attempt = 1
```

原有算法已经决定：

```text
Option A success = 90%
Option B success = 92%
Option C success = 65%
```

随机得到：

```text
crisis_flavor_id = hypotension
```

只意味着巡回护士可能说：

> 「血压在掉！」

而不是重新计算：

```text
hypotension → option B +5%
```

第一版禁止这样做。

---

## 2.3 巡回护士报告情况，不告诉玩家答案

护士可以说：

> 「血压在掉！」

不能说：

> 「血压在掉！马上暂停操作！」

因为现有 Gameplay 正在让玩家自己决定：

```text
暂停
维持术野交给团队
先完成关键动作
```

护士的职责是：

> **Situation Report**

而不是：

> **Correct Answer Hint**

---

# 3. Why Circulating Nurse

普通手术团队已有：

```text
Primary Surgeon
First Assistant
Scrub Nurse
Circulating Nurse
Anesthesia
```

巡回护士的既定职责包含：

```text
患者状态
记录
术中协调
```

因此普通手术危机由：

> **当前 Circulating Nurse**

首先喊出患者状态变化，非常自然。

不要默认让：

```text
Scrub Nurse
First Assistant
Primary Surgeon
```

抢这句。

高级 Grand OR 以后若有：

```text
Primary Circulating
Secondary Circulating
```

第一版只让：

> **Primary Circulating**

负责 crisis callout。

避免两个人同时喊。

---

# 4. Crisis Flavor Pool — V0.1 LOCKED

第一版使用以下 8 类。

```yaml
crisis_flavors:
  - hypotension
  - hypertension
  - tachycardia
  - bradycardia
  - arrhythmia
  - desaturation
  - respiratory_instability
  - generic_instability
```

---

## 4.1 hypotension

UI 语义：

> **血压突然下降**

允许台词：

```text
血压在掉！
血压下降了。
血压还在往下。
血压掉得很快。
循环压力在往下。
```

不要给具体数值：

```text
72 / 41
```

除非未来另做真实 monitor system。

---

## 4.2 hypertension

UI 语义：

> **血压异常升高**

允许台词：

```text
血压突然上去了。
血压在升。
血压比刚才高很多。
血压压不下来。
```

不要自动解释原因：

```text
疼痛
麻醉不足
焦虑
药物
```

第一版不做诊断。

---

## 4.3 tachycardia

UI 语义：

> **心率过快**

允许：

```text
心率上来了！
心率还在升。
心跳太快了。
心率明显过快。
```

允许少数角色说：

> 「她心跳得也太快了。」

但不要自动诊断：

> ventricular tachycardia

除非未来做独立系统。

---

## 4.4 bradycardia

UI 语义：

> **心率过慢**

允许：

```text
心率在往下。
心跳越来越慢。
心率太低了。
心率继续下降。
```

---

## 4.5 arrhythmia

UI 语义：

> **心律异常**

允许：

```text
心律乱了。
心律不规则。
节律不对。
监护上的节律变了。
```

不要写成具体诊断：

```text
房颤
室颤
传导阻滞
```

因为后台没有这些数据。

---

## 4.6 desaturation

UI 语义：

> **血氧下降**

允许：

```text
血氧在下降！
血氧还在往下。
氧饱和度掉了。
血氧不稳。
```

---

## 4.7 respiratory_instability

UI 语义：

> **呼吸状态异常**

允许：

```text
呼吸状态不对。
呼吸变浅了。
呼吸越来越不稳定。
通气状态在变。
```

不要自动诊断：

```text
肺栓塞
支气管痉挛
气道梗阻
```

---

## 4.8 generic_instability

UI 语义：

> **监护 / 循环出现综合异常**

用于：

- fallback；
- 找不到特定台词；
- 避免连续出现完全一样的 flavor。

允许：

```text
监护不稳！
患者状态在变。
循环状态不对。
坂口医生，看一下监护。
状态突然掉下来了。
```

---

# 5. Explicit Exclusion — Blood Loss

第一版危机 flavor **禁止包含大出血**：

```text
massive_bleeding
hemorrhage
major_blood_loss
```

原因：

> **Blood Loss 已经是独立 Gameplay 数值。**

不要出现：

```text
后台 Blood Loss 很低
+
随机 crisis flavor 却喊“大出血”
```

也不要让：

> random crisis presentation

与：

> Blood Loss system

重复表达同一件事。

未来若需要：

> Blood Loss 达到阈值 → 专属护士播报

应另建：

```text
blood_loss_callout
```

不属于本 V0.1。

---

# 6. 不加入明确诊断型灾难

第一版不要加入：

```text
anaphylaxis
pulmonary_embolism
cardiac_arrest
malignant_hyperthermia
airway_obstruction
myocardial_infarction
stroke
```

理由：

一旦护士明确说：

> 「肺栓塞！」

玩家自然会期待：

```text
专门诊断
专门选项
专门治疗
专门后果
```

而当前危机系统没有这些 Gameplay。

第一版只报告：

> **监护上的异常表现。**

---

# 7. Flavor Selection

当现有系统确认：

```text
crisis_triggered = true
```

新增：

```pseudo
crisis_flavor_id = choose_random_crisis_flavor()
```

V0.1 可以等权随机：

```text
1 / 8
```

如果工程上已有 deterministic RNG / seeded RNG：

> 复用现有 RNG。

不要新建第二套随机系统。

---

## 7.1 Optional Anti-Repetition

推荐但不是硬阻塞：

```text
if last_crisis_flavor_id exists:
    reduce weight of same flavor
```

目标：

> 同一台手术连续三次危机时，不要三次都“血压下降”。

最简单可以：

```pseudo
pool = all_flavors
if pool.size > 1:
    remove(last_crisis_flavor_id)
choose_random(pool)
```

如果实现麻烦：

> V0.1 可以暂时不做。

---

# 8. Nurse Resolver

普通手术：

```pseudo
speaker = current_team.circulating_nurse
```

Grand OR：

```pseudo
speaker = current_team.primary_circulating_nurse
```

如果角色：

```text
不存在
未加载
使用 generic nurse slot
```

则 fallback：

```text
speaker = generic_or_nurse
```

不要因此阻塞 crisis。

---

# 9. Dialogue Resolution Priority

推荐：

```text
1. actor_id + crisis_flavor_id + severity
2. actor_id + crisis_flavor_id
3. actor_id + generic_instability
4. generic_nurse + crisis_flavor_id
5. generic_nurse + generic_instability
```

这样不要求第一版就为所有护士写：

> 8 × N

完整矩阵。

未来新增护士时，只需逐步补角色专属行。

---

# 10. Severity

继续使用现有 crisis severity。

不要增加第二套 severity。

如果现有系统已有：

```text
mild
moderate
severe
```

或其他枚举，则文本层可以读取。

如果当前实际上只有：

```text
危机
严重危机
```

则按现有字段映射。

---

## 10.1 Severity 只影响说法强度

例如：

### hypotension / normal

> 「血压在下降。」

### hypotension / severe

> 「血压掉得很快！」

Gameplay 成功率：

> **仍由原系统决定。**

不要因为用了更激烈台词，再额外降低 Stability。

---

# 11. Dialogue Tone System

每条台词可以带一个 tone：

```yaml
tone:
  - professional
  - character
  - hoshimi
```

含义：

### professional

纯工作报告：

> 「血压在下降。」

### character

仍然专业，但明显有角色自己的说法：

> 「坂口医生，血压还在往下。」

### hoshimi

仍然报告正确情况，但带一点星见式粗线条 / 黑色幽默：

> 「她心跳得像准备从手术台上跑掉一样。」

---

# 12. Weight Rule

建议单个角色单个 flavor 的 pool 采用：

```text
professional    weight 4
character       weight 4
hoshimi         weight 1
```

也就是：

> **Hoshimi 明显玩笑属于低概率特殊播报。**

不要每次 crisis 都讲段子。

目标：

```text
多数时候像专业 OR
偶尔突然非常 Hoshimi
```

---

# 13. Hoshimi Flavor Boundary

Hoshimi 式播报允许：

```text
毒舌
轻微身体反应吐槽
对患者喊叫 / 心率的粗线条评价
工作熟练产生的黑色幽默
```

但危机播报必须继续满足：

> **医学状态报告仍然清楚。**

坏例子：

> 「她今天真倒霉啊。」

问题：

> 没告诉玩家出什么事。

好例子：

> 「心率还在升。她这是要连监护仪一起吓坏吗。」

前半句：

> 提供状态。

后半句：

> 角色 flavor。

---

# 14. V0.1 Starter Character Pools

以下只作为第一版内容。

实际 actor_id 必须读取现有 registry。

不要因为本文件示例名字擅自创建重复角色。

---

## 14.1 杉村弘子 / Hiroko

风格：

```text
资深
稳定
简洁
患者照护意识强
很少慌
```

### hypotension

professional:

> 「坂口先生，血压在下降。」

character:

> 「血压还在往下。先看患者。」

hoshimi / rare:

> 「她刚才还有力气抱怨，现在血压倒先没力气了。」

### tachycardia

> 「心率上来了。」

> 「心率还在升，坂口先生。」

rare:

> 「心跳这么快，她比我们还着急。」

### bradycardia

> 「心率在往下。」

> 「越来越慢了。」

### arrhythmia

> 「节律不对。」

> 「心律开始乱了。」

### desaturation

> 「血氧在下降。」

> 「血氧还在往下。」

### respiratory_instability

> 「呼吸状态不稳。」

> 「通气在变，注意一下。」

### hypertension

> 「血压上来了。」

> 「比刚才高很多。」

### generic

> 「患者状态在变。」

> 「坂口先生，看一下监护。」

---

## 14.2 七瀬恋 / Nanase Ren

风格：

```text
温和
清楚
可靠
会自然叫坂口医生
不软弱
```

### hypotension

> 「坂口医生，血压在掉。」

> 「血压还在下降。」

### tachycardia

> 「心率有点太快了。」

> 「还在往上。」

rare:

> 「她心跳得这么快……真的很紧张吧。」

### bradycardia

> 「心率在往下。」

> 「坂口医生，越来越慢了。」

### arrhythmia

> 「心律不规则。」

> 「监护上的节律变了。」

### desaturation

> 「血氧在下降。」

> 「血氧不太稳。」

### respiratory_instability

> 「呼吸状态不对。」

> 「通气开始不稳定了。」

### hypertension

> 「血压突然上去了。」

> 「血压还在升。」

### generic

> 「坂口医生，患者状态在变。」

> 「监护不稳。」

---

## 14.3 朝倉美幸 / Asakura Miyuki

风格：

```text
动作快
说话利落
略强势
毒舌
低频黑色幽默
```

### hypotension

> 「血压往下掉。看监护。」

> 「掉得很快。」

rare:

> 「血压掉得比她刚才的气势还快。」

### tachycardia

> 「心率一路往上。」

> 「太快了。」

rare:

> 「她这是想靠心跳自己跑下手术台吗。」

### bradycardia

> 「心率往下。」

> 「越来越慢，别只看术野。」

### arrhythmia

> 「心律乱了。」

> 「节律不对。」

rare:

> 「这个节奏可不是给你配手术 BGM 的。」

### desaturation

> 「血氧在掉。」

> 「还在往下。」

### respiratory_instability

> 「呼吸不对。」

> 「通气状态变了。」

### hypertension

> 「血压上去了。」

> 「升得有点过头。」

rare:

> 「这么激动，她可还躺着呢。」

### generic

> 「监护不稳。」

> 「坂口医生，别只看里面。」

---

## 14.4 本庄萌恵 / Honjo Moe

风格：

```text
年轻
会紧张
但报告必须准确
成长型护士
```

禁止写成：

> 慌到说不清发生了什么。

### hypotension

> 「血、血压下降了……！」

> 「还在下降。」

### tachycardia

> 「心率上来了！」

> 「还、还在升。」

### bradycardia

> 「心率越来越慢了。」

> 「坂口医生，心率在往下。」

### arrhythmia

> 「心律……不规则。」

> 「监护上的节律变了！」

### desaturation

> 「血氧下降了！」

> 「还没停……还在往下。」

### respiratory_instability

> 「呼吸状态变了。」

> 「通气好像不对。」

### hypertension

> 「血压突然升高了！」

> 「比刚才高很多。」

### generic

> 「患者状态不稳定！」

> 「坂口医生，看监护！」

rare：

> 「今天的监护仪怎么突然这么有精神……！」

---

## 14.5 折川皐月 / Orikawa Satsuki

仅当她当前确实具备：

> Circulating Nurse eligibility

时使用。

风格：

```text
认真
略紧张
非常在意确认
不会胡乱下结论
```

### hypotension

> 「血压在下降。」

> 「坂口先生，确认一下，血压还在往下。」

### tachycardia

> 「心率过快了。」

> 「还在继续上升。」

### bradycardia

> 「心率下降。」

> 「越来越慢了。」

### arrhythmia

> 「节律发生变化。」

> 「心律不规则。」

### desaturation

> 「血氧下降。」

> 「血氧还没有稳定。」

### respiratory_instability

> 「呼吸状态有变化。」

> 「通气不稳定。」

### hypertension

> 「血压升高。」

> 「还在上升。」

### generic

> 「患者状态变化了。」

> 「坂口先生，请看监护。」

---

## 14.6 中井美佳 / Nakai Mika

风格：

```text
有经验
友好
很稳
私人感觉难读
危机时几乎不慌
```

### hypotension

> 「血压在往下。」

> 「下降得有点快。」

### tachycardia

> 「心率上升。」

> 「还没停下来。」

### bradycardia

> 「心率下降。」

> 「越来越慢。」

### arrhythmia

> 「心律乱了。」

> 「节律已经不是刚才那个样子。」

### desaturation

> 「血氧下降。」

> 「还在掉。」

### respiratory_instability

> 「呼吸状态变了。」

> 「通气不稳定。」

### hypertension

> 「血压升高。」

> 「升得很明显。」

### generic

> 「患者状态不稳。」

> 「看一下监护。」

rare:

> 「今天这台，好像开始不想让我们顺利结束了。」

---

## 14.7 利根川安琪 / Tonegawa Ange

仅在其实际担任 Circulating 时使用。

风格：

```text
认真
反应快
略有紧绷感
希望表现好
报告简洁
```

### hypotension

> 「血压下降。」

> 「还在下降。」

### tachycardia

> 「心率上升。」

> 「现在太快了。」

### bradycardia

> 「心率下降。」

> 「越来越慢。」

### arrhythmia

> 「心律异常。」

> 「节律不规则。」

### desaturation

> 「血氧下降。」

> 「还在往下。」

### respiratory_instability

> 「呼吸状态异常。」

> 「通气不稳定。」

### hypertension

> 「血压升高。」

> 「还在升。」

### generic

> 「监护异常。」

> 「患者状态在变。」

---

# 15. Generic OR Nurse Fallback

如果当前巡回：

```text
无 named actor
actor 未加载
line pool 缺失
```

使用：

### hypotension

> 「血压下降！」

### hypertension

> 「血压在升！」

### tachycardia

> 「心率太快了！」

### bradycardia

> 「心率在往下！」

### arrhythmia

> 「心律不规则！」

### desaturation

> 「血氧下降！」

### respiratory_instability

> 「呼吸状态不对！」

### generic

> 「监护不稳！」

---

# 16. UI / Presentation — LOCKED

用户侧目标：

> **护士只需要出现立绘，并在现有界面对话框里出现危机描述。**

不要新增复杂 UI。

---

## 16.1 Crisis Presentation Sequence

推荐：

```text
1. random crisis triggers
2. choose crisis_flavor_id
3. resolve circulating nurse
4. show nurse standing sprite
5. show name + crisis line in existing dialogue box
6. existing crisis title / severity remains visible
7. existing crisis response buttons appear / remain interactable
```

---

## 16.2 No Extra Confirmation Click

优先：

> **不要要求玩家先点一次“下一句”，再看到三个危机选项。**

推荐：

```text
立绘出现
+
textbox 显示一句播报
+
处理选项同时可操作
```

如果 UI 架构无法做到完全同时：

> 可以让选项在文本打字动画结束时自动解锁。

但不要新增：

```text
[继续]
```

页面。

---

## 16.3 Portrait

使用：

> 当前 Circulating Nurse 的正常 OR / scrub 立绘。

不需要为每种危机制作：

```text
专属 CG
专属危机表情
```

如果已有：

```text
worried
serious
shocked
```

表情差分，可以低成本复用。

没有就用标准工作立绘。

---

## 16.4 Existing Crisis Panel

保留：

```text
术中生理危机
严重度
第N次处理
三个原有选择
成功率
时间代价
```

不重新设计整张 crisis UI。

第一版目标是：

> **在原 UI 上增加“人”。**

---

# 17. Suggested Data Shape

不要强制照抄字段名。

优先匹配现有数据架构。

概念结构：

```yaml
crisis_callout:
  flavor_id: hypotension
  speaker_actor_id: nurse_ren
  severity: severe
  line_id: ren_hypotension_02
  tone: character
```

台词数据：

```yaml
nurse_ren:
  hypotension:
    - text: "坂口医生，血压在掉。"
      tone: professional
      weight: 4

    - text: "血压还在下降。"
      tone: character
      weight: 4

    - text: "她刚才还挺有精神的……现在血压掉得有点快。"
      tone: hoshimi
      weight: 1
```

---

# 18. Suggested Runtime Pseudocode

```pseudo
func trigger_intraoperative_crisis(existing_crisis):
    # Existing gameplay logic remains unchanged.
    crisis = existing_crisis

    flavor_id = choose_crisis_flavor(
        exclude = ["major_bleeding"]
    )

    speaker = resolve_primary_circulating_nurse()

    line = resolve_crisis_callout_line(
        actor_id = speaker.actor_id,
        flavor_id = flavor_id,
        severity = crisis.severity
    )

    show_actor_sprite(speaker)
    show_dialogue_box(
        speaker_name = speaker.display_name,
        text = line.text
    )

    show_existing_crisis_choices(crisis)
```

注意：

> `choose_crisis_flavor()` 不改变 `crisis` 本身。

---

# 19. Save / Load

如果玩家能在危机选择界面保存：

需要保存：

```text
active crisis state
crisis_flavor_id
selected crisis callout line_id
speaker actor_id
```

读档后：

> 不重新随机一句。

避免：

```text
Save
→ Load
→ nurse suddenly reports another physiological problem
```

如果当前系统：

> crisis UI 不允许保存

则无需单独处理。

Codex 应先检查现有 save architecture。

---

# 20. Quick Surgery

Quick Surgery：

> 不需要播报。

因为 Quick 本身跳过：

```text
完整 OR interaction
```

本功能属于：

> **Full Surgery Presentation**

---

# 21. Advanced Referral

V0.1 不要求改写 Advanced Referral。

高级手术已有更多：

```text
麻醉科
Primary / Secondary Circulating
scripted team dialogue
```

如果以后统一接入：

> Primary Circulating 可继续使用本系统。

但如果 Advanced Event 本身已经 scripted：

> scripted dialogue 优先。

不要让 random callout 打断固定高级事件。

---

# 22. Interaction with Awake Patient

本 V0.1 不要求患者对 crisis callout 追加反应。

即使患者：

```text
Local
Epidural
None
```

保持清醒：

第一版仍只需要：

```text
nurse callout
→ player crisis choice
```

以后若需要可加：

> “患者听见‘血压在掉’以后 Fear 上升 / 吐槽”

但：

> **不属于本轮。**

避免 scope creep。

---

# 23. Interaction with Anesthesia

普通手术的危机播报：

> 第一版仍由 Circulating Nurse 负责。

不要因此删除：

> 麻醉角色未来对危机的其他台词。

如果已有 scripted anesthesia line：

```text
护士报告
→ 麻醉侧可按原逻辑回应
```

但本文件不要求新增。

---

# 24. No New Gameplay Rewards / Penalties

Callout：

```text
Familiarity +0
Relationship +0
Leadership +0
Charm +0
Clinical Presence +0
Reputation +0
```

这只是演出。

不要把：

> “某护士成功报告危机”

做成可刷 Familiarity 的来源。

---

# 25. Do Not Overbuild V0.1

第一版不需要：

```text
真实监护仪
动态 ECG
数值血压
连续 SpO2
病因诊断
护士技能检定
护士报告延迟
护士误报
巡回护士 panic meter
危机独立动画
语音配音
新的危机治疗按钮
```

只需要：

```text
8种危机 flavor
+
巡回护士 resolver
+
角色台词 pool
+
护士立绘
+
现有对话框
+
现有 crisis options
```

---

# 26. Engineering Search / Reuse Rule

Codex 实装前先全项目搜索：

```text
术中生理危机
crisis
surgery crisis
第1次处理
stabilize
circulating
circulating nurse
Blood Loss
```

目的：

1. 找到当前 crisis trigger；
2. 找到当前 crisis UI；
3. 找到 Team Builder / circulating nurse actor 引用；
4. 找到 standing sprite / dialogue box 的通用显示方法；
5. 找到 save/load 是否允许停在 crisis UI；
6. 复用现有 RNG。

不要平行新建：

```text
第二套 crisis system
第二套 actor registry
第二套 dialogue renderer
```

---

# 27. Acceptance Criteria — LOCKED

第一版完成后必须满足：

1. 原有 crisis 触发概率完全不变。
2. 原有 severity 完全不变。
3. 原有三个处理选项完全不变。
4. 原有成功率 / 时间代价完全不变。
5. 原有 failure / rescue / abort 逻辑完全不变。
6. 每次 Full Surgery 随机危机触发时，额外得到一个 `crisis_flavor_id`。
7. V0.1 flavor 只来自锁定的 8 类。
8. 大出血不进入 random crisis flavor pool。
9. Flavor 不创建真实 BP / HR / SpO2 后台数据。
10. 当前 Circulating Nurse 作为默认播报者。
11. Grand OR 若未来接入，只使用 Primary Circulating。
12. 找不到 named nurse 时必须有 generic fallback。
13. 当前巡回护士立绘必须出现。
14. 对话框必须显示角色名与一句危机播报。
15. 原有 crisis 标题和处理按钮继续显示。
16. 最好无需额外“继续”点击。
17. 护士只能报告状态，不能直接告诉玩家哪个 crisis option 正确。
18. 角色台词必须允许明显人物差异。
19. Hoshimi 黑色幽默必须低频出现。
20. 即使是 Hoshimi line，也必须先清楚报告生理异常。
21. Quick Surgery 不调用该层。
22. scripted Advanced Event 不应被 random callout 覆盖。
23. Callout 本身不产生任何五维 / Familiarity / Relationship 数值。
24. 如果 crisis UI 可存档，读档后必须保留原 flavor / speaker / line，不重新随机。
25. 不新增真实生理模拟或具体疾病诊断。

---

# 28. Visual Target

当前危机界面不需要推倒重做。

目标从：

```text
[系统]
术中生理危机 · 严重
↓
三个按钮
```

变成：

```text
[当前巡回护士立绘]

七瀬恋：
「坂口医生，血压在掉。」

术中生理危机 · 严重 · 第1次处理

[暂停操作，全力稳定患者]
[保持当前术野，让团队处理]
[先完成当前关键动作再处理]
```

玩家应当自然感觉：

> **不是 UI 告诉我患者出事了。**
>
> **是我的巡回护士突然叫我：患者出事了。**

这就是本系统 V0.1 的全部目标。

# END
