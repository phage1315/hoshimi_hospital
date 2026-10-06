# Hoshimi Hospital — Optional Palpation & Anesthesia Sensory Test System
## 可选术前触诊 + 麻醉效果确认 + 工具复用
### Codex Handoff V0.1 — 2026-10-04

> **文件性质：Implementation Addendum / 可直接交付 Codex**
>
> 本文件在现有触诊、手术失败与危机设计基础上，增加一个最小化的麻醉效果确认步骤，并统一两种身体互动 HUD 的工具逻辑。
>
> 核心目标：
>
> 1. 术前触诊改为**可选步骤**；
> 2. 局麻 / 硬膜外后增加一个**可选麻醉效果确认步骤**；
> 3. 两个 HUD 尽量复用同一身体图、热点和工具框架；
> 4. 两个 HUD 都提供 `手 / 针 / 手术刀 / 跳过`；
> 5. 同一个工具在两个 HUD 中承担不同作用；
> 6. V0.1 不做麻醉深度调整、药量调整、随机麻醉失败或精确皮节模拟；
> 7. 麻醉测试主要用于玩家反馈、患者反应、福利 / XP flavor，以及明确展示不同麻醉方案的覆盖差异。

---

# 1. Revised Preoperative Flow

```text
患者上手术台
↓
[Optional] OR Table Palpation
↓
Anesthesia Selection
↓
实施麻醉
↓
Local / Epidural:
    [Optional] Anesthesia Sensory Test
↓
General / None:
    不进入麻醉测试 HUD
↓
正式手术
```

---

# 2. 两个互动步骤都可以跳过

## 2.1 OR Table Palpation

新增：

```text
[跳过触诊]
```

选择后：

```text
不增加 Fear
不增加 Pain
不降低 Dignity
不改变 Cooperation
不获得触诊 finding
不受处罚
↓
直接进入 Anesthesia Selection
```

原则：

> **触诊是额外互动，不是强制 chores。**

## 2.2 Anesthesia Sensory Test

Local / Epidural 后新增：

```text
[跳过麻醉确认]
```

选择后：

```text
不改变麻醉效果
不改变患者状态
不受处罚
↓
直接进入正式手术
```

原则：

> **麻醉是否有效由当前麻醉种类 + 手术部位决定，不由玩家是否进行了测试决定。**

---

# 3. V0.1 不模拟麻醉深度

明确不做：

```text
anesthesia depth
drug dose
waiting for onset
top-up dose
random block failure
partial pharmacologic success roll
motor blockade meter
exact dermatome map
```

麻醉效果为确定性：

```text
麻醉种类
+
当前术式 / 身体区域
=
该区域是否具有有效止痛
```

麻醉测试只是让玩家**看到 / 听到这个结果**。

---

# 4. Shared HUD Philosophy

术前触诊 HUD 与麻醉效果确认 HUD 视觉结构应高度相似。

尽量复用：

```text
same patient body image
same hotspot mapping
same tool selection UI
same cursor framework
same short reaction display
same patient-state display
```

区别只在：

```text
screen_mode = palpation
screen_mode = anesthesia_test
```

---

# 5. Shared Tools

两个 HUD 都提供：

```text
Hand / 手
Needle / 针
Scalpel / 手术刀
Skip / 跳过
```

| 工具 | 术前触诊 HUD | 麻醉效果确认 HUD |
|---|---|---|
| 手 | **正常主工具** | 可用，但反馈较模糊 |
| 针 | 非标准 / 恶趣味工具，患者反应较大 | **标准测试工具** |
| 手术刀 | 错误 / 黑色幽默终结选项 | 错误 / 黑色幽默终结选项 |
| 跳过 | 无惩罚结束触诊 | 无惩罚结束麻醉确认 |

---

# 6. Palpation HUD — Hand

术前触诊中：

```text
tool_mode = hand
```

继续沿用：

```text
light
normal
deep
```

作用：

```text
procedure relevance
patient reaction
Fear
Pain
Dignity
Cooperation
procedure-specific finding
```

这仍然是正常医疗玩法。

---

# 7. Palpation HUD — Needle

术前触诊中新增：

```text
tool_mode = needle
```

V0.1 中它不是标准触诊方法。

点击任意热点：

```text
不获得新的 palpation medical finding
Pain ↑
Fear ↑
Dignity 可按部位下降
Cooperation 可少量下降
```

示例方向：

### 腹部

> 「痛！医生，你拿针干什么……！」

### 乳房

> 「啊！等一下……为什么要用针啊？」

### 乳头

> 「啊——！那里很敏感！」

### 阴部

> 「不要……那里为什么也要用针……！」

具体台词保持短句，不打开大型 VN scene。

---

# 8. Palpation Needle 不使用力度档

V0.1：

```text
Needle = one standardized pinprick action
```

选择 Needle 时：

```text
隐藏 / 禁用 light-normal-deep pressure selector
```

避免制造无意义复杂度。

---

# 9. Palpation HUD — Scalpel

保留已有设计。

```text
tool_mode = scalpel
```

点击任意身体区域：

```text
trigger premature_incision
```

患者：

> 「呀啊啊啊——！！」

护士：

> 「医生！你怎么能不消毒、不麻醉就下刀呢？！」

状态：

```text
Pain = MAX
Fear ↑↑
premature_incision = true
```

然后：

```text
结束触诊 HUD
↓
强制进入 Anesthesia Selection
```

V0.1 不允许在该 HUD 无限连续下刀。

---

# 10. Anesthesia Sensory Test — Eligibility

麻醉效果确认 HUD 只在：

```text
Local Anesthesia
Epidural Anesthesia
```

之后出现。

以下路线不出现：

```text
General Anesthesia
No Anesthesia
```

原因：

- General：患者已经失去正常主观反馈。
- None：不存在需要确认的止痛区域。

---

# 11. Anesthesia Test — Needle 是标准工具

麻醉确认 HUD：

```text
tool_mode = needle
```

是推荐 / 标准测试工具。

游戏抽象：

> **Needle = pinprick sensory testing tool**

不是新的注射 / 给药系统，只用于测试锐痛感觉。

---

# 12. Covered Region + Needle

如果当前区域：

```text
anesthesia_covered == true
```

患者可以：

> 「感觉得到碰了一下……但是不痛。」
>
> 「有一点感觉，可是不尖。」
>
> 「那里麻麻的……」

状态变化：

```text
Pain +0
Fear 可 -1 / 0
Dignity 通常 0
```

不要设计成：

> “完全没有任何触觉才叫麻醉成功。”

V0.1 允许：

```text
touch / pressure sensation remains
sharp pain blocked
```

---

# 13. Uncovered Region + Needle

如果：

```text
anesthesia_covered == false
```

患者正常感觉针刺。

例如：

> 「痛！那里没有麻掉！」
>
> 「等一下，那里我完全有感觉！」

状态：

```text
Pain ↑
Fear ↑
```

敏感区域：

```text
breast
nipple
genital
```

还可以：

```text
Dignity ↓
```

这不是麻醉失败，如果该区域本来就不属于麻醉覆盖范围。

---

# 14. Anesthesia Test — Hand

麻醉确认 HUD 也允许：

```text
tool_mode = hand
```

但信息故意较模糊。

## Covered

> 「能感觉到你在碰……但是很钝。」
>
> 「有压力，可是不疼。」

## Uncovered

> 「嗯……这里感觉很正常。」
>
> 「能感觉到你按我。」

原则：

> **Hand 可以测试，但 Needle 更容易让玩家理解痛觉是否被阻断。**

麻醉测试中的 Hand 不触发 procedure-specific palpation finding，也不增加 palpation medical confirmation。

---

# 15. Anesthesia Coverage — General

```text
General Anesthesia
```

V0.1：

```text
patient_awake = false
operative_analgesia = effective
```

不进入麻醉测试 HUD。

正式手术：

```text
skip awake patient interaction
```

并走 GA-specific physiologic crisis flavor。

---

# 16. Anesthesia Coverage — Local

V0.1 定义：

> **Local Anesthesia 自动正确施加在当前手术目标区域。**

不是玩家自己选择 Local 打在哪。

第一版没有：

```text
mis-targeted local anesthesia
```

## Local Coverage

由 procedure profile / surgical target mask 决定。

例如：

### Abdominal

```text
abdomen = covered
breast = uncovered
nipple = uncovered
chest = uncovered
genital = uncovered
```

### Breast

```text
affected breast / relevant breast surgical region = covered
unrelated body regions = uncovered
```

### Gynecology / Pelvic

```text
current surgical target region = covered
other unrelated regions = uncovered
```

### Thoracic / Cardiac

```text
chest / current surgical region = covered
other unrelated regions = uncovered
```

核心：

> **Local 只麻当前手术区域，不是全身麻醉。**

---

# 17. Local — Intraoperative Reaction

患者：

```text
awake = true
```

当前术区：

```text
sharp / incision pain
→ strongly suppressed / zero

pressure
traction
movement
position discomfort
exposure
fatigue
→ 仍可正常感受到
```

患者仍可说：

> 「感觉得到你们在动……但是不疼。」
>
> 「里面有被拉着的感觉……」

不要把 Local 写成完全无感觉。

---

# 18. Anesthesia Coverage — Epidural

V0.1 对 `epidural` 做明确 Gameplay Simplification：

> **当前 Hoshimi V0.1 的 Epidural = 下腹 / 腹部 / 盆腔型区域阻滞。**

不是完整模拟现实中所有置管高度。

麻醉测试 body-map：

```text
abdomen = covered
genital = covered

breast = uncovered
nipple = uncovered
chest = uncovered
```

未来热点增加后可以细化；V0.1 不需要。

---

# 19. Epidural — Procedure Effectiveness

## Effective procedure families

```text
abdominal
gynecology_pelvic
```

在这些术式中：

```text
epidural_effective_for_procedure = true
```

患者清醒，但止痛有效。

## Ineffective procedure families

```text
breast
thoracic_cardiac
```

在这些术式中：

```text
epidural_effective_for_procedure = false
```

对当前手术区域：

> **术中止痛效果按 No Anesthesia 处理。**

注意：硬膜外本身不是“完全没作用”。

例如乳房手术选择 Epidural：

```text
abdomen / genital
→ 仍然可以 numb

breast / chest
→ normal pain sensation
```

只是它没有覆盖真正要开刀的地方。

---

# 20. Epidural — Intraoperative Reaction

## Effective: abdominal / pelvic

```text
awake = true
operative_analgesia = effective
```

表现类似有效 Local：

```text
incision sharp pain ↓↓↓ / 0
pressure / traction remains
Fear remains
Dignity / Cooperation remain
awake interaction remains
```

## Ineffective: breast / thoracic

```text
awake = true
operative_analgesia = ineffective
```

正式手术中的：

```text
pain reaction
Pain gain
Crisis Fear/Pain contribution
```

直接复用：

```text
No Anesthesia
```

即：

> **Epidural + Breast/Thoracic = 对术区相当于无麻醉。**

---

# 21. Anesthesia Coverage — None

```text
No Anesthesia
```

V0.1：

```text
patient_awake = true
all surgical regions = uncovered
operative_analgesia = ineffective
```

不出现麻醉确认 HUD。

正式手术使用 full pain reactions。

---

# 22. Anesthesia Selection Warning

选择 Epidural 时，系统根据当前 procedure profile 判断：

```text
epidural_effective_for_procedure
```

如果是：

```text
false
```

巡回护士必须给出一次明确提醒。

例如：

> 「医生，这个硬膜外范围覆盖不到计划手术部位。」
>
> 「胸部还是会有正常痛觉。确定继续吗？」

乳房：

> 「乳房区域没有被这次硬膜外覆盖。继续的话，术区相当于没有止痛。」

提供：

```text
[更换麻醉方案]
[仍然使用硬膜外]
```

玩家可以无视提醒继续。

---

# 23. 不隐藏无效硬膜外

V0.1 不建议：

```text
Breast Surgery
Epidural button disabled
```

也不建议隐藏选项。

原因：

> **允许玩家作出无效麻醉选择，本身可以产生反馈、挑战与黑色幽默。**

护士只负责：

```text
warn
```

不负责：

```text
forbid
```

---

# 24. 麻醉测试让覆盖差异变得可见

例如：

```text
Breast Surgery
+
Epidural
```

玩家无视护士。

进入麻醉测试：

### Needle → abdomen

> 「……这里不太痛。」

### Needle → breast

> 「痛！那里根本没有麻掉！」

### Needle → nipple

> 「啊——！那里当然有感觉啊！」

玩家得到明确反馈：

> **麻醉起效了，只是没有覆盖手术区域。**

---

# 25. Anesthesia Test — Scalpel

麻醉确认 HUD 继续保留：

```text
tool_mode = scalpel
```

它仍然是明显错误 / 黑色幽默的终结测试方式。

## Covered Region

患者可以：

> 「……咦？」
>
> 「已经切了吗……？」
>
> 「我感觉到了，可是……不疼？」

护士：

> 「医生？！我是让你确认麻醉效果，不是让你直接开始切啊！」

状态：

```text
Pain +0 or very small
Fear ↑
anesthesia_test_terminated_by_scalpel = true
```

## Uncovered Region

患者：

> 「呀啊啊啊——！！痛！！」

护士：

> 「医生？！我是让你测试麻醉，不是让你直接下刀啊！」

状态：

```text
Pain ↑↑ / MAX depending current implementation
Fear ↑↑
anesthesia_test_terminated_by_scalpel = true
```

V0.1 不做真实额外伤口模拟。

无论 covered / uncovered：

```text
Scalpel click
↓
patient reaction
↓
nurse reaction
↓
end anesthesia_test
↓
enter formal surgery
```

不要留在 HUD 无限试刀。

---

# 26. 两个 Scalpel Joke 的区别

## Palpation HUD

护士重点：

> **“还没消毒、还没麻醉。”**

流程：

```text
Palpation
→ Scalpel
→ Premature Incision
→ Anesthesia Selection
```

## Anesthesia Test HUD

此时麻醉方案已经实施。

护士重点：

> **“这是麻醉测试，不是正式下刀。”**

流程：

```text
Anesthesia Test
→ Scalpel
→ Test Ends
→ Formal Surgery
```

两个场景不要共用完全相同的护士吐槽。

---

# 27. Patient State Carry-Over

两个 HUD 对：

```text
Fear
Pain
Dignity
Cooperation
```

的变化都必须带入正式手术。

因此：

```text
术前触诊刷高 Fear
Needle misuse 增加 Pain
Scalpel misuse 增加 Pain/Fear
```

都可以自然影响后面的：

```text
awake interaction
Physiologic Crisis Chance
future boundary events
```

不需要额外重复写失败倍率。

---

# 28. Surgical Reaction Resolver

正式手术开始时建议推导：

```text
patient_awake
operative_analgesia_effective
```

## General

```text
patient_awake = false
operative_analgesia_effective = true
```

## Local

```text
patient_awake = true
operative_analgesia_effective = true
```

## Epidural + abdominal / gynecology_pelvic

```text
patient_awake = true
operative_analgesia_effective = true
```

## Epidural + breast / thoracic_cardiac

```text
patient_awake = true
operative_analgesia_effective = false
```

## None

```text
patient_awake = true
operative_analgesia_effective = false
```

---

# 29. Awake Reaction Rules

如果：

```text
patient_awake == true
```

Patient Interaction 继续运行。

如果：

```text
operative_analgesia_effective == true
```

### Pain-dominant cues

例如：

```text
incision
sharp_contact
painful_manipulation
```

应：

```text
Pain increase strongly reduced / zero
```

### Non-pain sensory cues

例如：

```text
pressure
traction
movement
deep manipulation sensation
position discomfort
exposure
fatigue
```

仍然可以正常触发患者 reaction。

有效止痛不等于 Fear = 0，也不移除 Dignity / Cooperation。

---

# 30. Ineffective Epidural 必须复用 No-Anesthesia Behavior

不要新建：

```text
bad_epidural_reaction_system
```

如果：

```text
Epidural
+
procedure not covered
```

则对正式术区：

```text
reuse no-anesthesia pain reaction
```

保持代码简单。

---

# 31. Recommended Minimal Data

procedure / case 只需要已有或新增：

```text
palpation_profile
surgical_target_regions
anesthesia_type
```

由 resolver 推导：

```text
covered_regions
epidural_effective_for_procedure
patient_awake
operative_analgesia_effective
```

不要把可推导结果重复硬存。

---

# 32. V0.1 Coverage Table

| Procedure profile | Local | Epidural | GA | None |
|---|---|---|---|---|
| abdominal | 当前手术区 covered | **effective** | effective | ineffective |
| gynecology_pelvic | 当前手术区 covered | **effective** | effective | ineffective |
| breast | 当前手术区 covered | **对术区 ineffective** | effective | ineffective |
| thoracic_cardiac | 当前手术区 covered | **对术区 ineffective** | effective | ineffective |

---

# 33. Terminology Note

Hoshimi V0.1 的：

```text
Epidural
```

是 Gameplay Simplification，代表：

> **当前游戏中的下腹 / 盆腔型硬膜外覆盖。**

不要在代码 / 剧情中表述成：

> “现实中所有硬膜外都无法用于胸部。”

未来如果需要：

```text
thoracic_epidural
```

可另行扩展。

V0.1 不做。

---

# 34. Explicitly NOT in This Pass

不要顺手加入：

```text
自由选择局麻注射位置
开腹却故意把 Local 打在乳房
局麻剂量
局麻注射动画
硬膜外穿刺小游戏
精确皮节
麻醉深度条
麻醉药追加
随机局麻失败
随机硬膜外失败
麻醉效果百分比
全麻麻醉测试 HUD
No Anesthesia 测试 HUD
motor blockade
针的多档力度
真实切伤 / 伤口持久模拟
```

其中：

> **“故意把局麻打错身体部位”可以作为未来恶趣味扩展，但不是 V0.1。**

---

# 35. Acceptance Tests

## Test A — Skip Palpation

```text
Enter OR Table
↓
Skip Palpation
```

Expected：

```text
no stat change
no penalty
go to anesthesia selection
```

## Test B — Palpation Tools

### Hand

```text
normal palpation behavior
```

### Needle

```text
patient stronger reaction
no medical finding
stats change
```

### Scalpel

```text
patient scream
nurse:
“怎么能不消毒、不麻醉就下刀”
Pain = MAX
end palpation
go anesthesia selection
```

## Test C — Local Anesthesia

```text
Abdominal Surgery
Local
```

Anesthesia Test：

```text
Needle abdomen → covered / sharp pain blocked
Needle breast → uncovered / painful reaction
```

Formal Surgery：

```text
awake
incision pain suppressed
pressure / traction reactions remain
```

## Test D — Effective Epidural

```text
Pelvic Surgery
Epidural
```

Anesthesia Test：

```text
abdomen → covered
genital → covered
breast → uncovered
chest → uncovered
```

Formal Surgery：

```text
awake
operative analgesia effective
```

## Test E — Ineffective Epidural

```text
Breast Surgery
Epidural
```

At anesthesia selection：

巡回护士提醒：

> 「乳房区域没有被这次硬膜外覆盖。继续的话，术区相当于没有止痛。」

玩家仍选择硬膜外。

Anesthesia Test：

```text
abdomen needle → numb / little pain
breast needle → normal sharp pain
nipple needle → strong normal sensation
```

Formal Surgery：

```text
patient awake
breast surgical pain behaves like No Anesthesia
```

## Test F — Anesthesia Test Hand

Covered：

> 「知道你在碰……但感觉很钝。」

Uncovered：

> 「这里感觉很正常。」

不改变麻醉状态。

## Test G — Anesthesia Test Scalpel

### Covered

```text
little/no sharp pain
Fear rises
nurse test-specific complaint
end test
go surgery
```

### Uncovered

```text
strong pain / scream
Fear rises strongly
nurse test-specific complaint
end test
go surgery
```

---

# 36. Final Design Summary

```text
OR Table
↓
Optional Palpation HUD
    Hand = normal medical tool
    Needle = unnecessary / provocative tool
    Scalpel = premature incision joke
    Skip
↓
Anesthesia Selection
    GA
    Local
    Epidural
    None

    if Epidural does not cover surgical profile:
        Circulating Nurse warns
        Player may ignore
↓
Local / Epidural
    Optional Anesthesia Sensory Test HUD
        Needle = standard tool
        Hand = ambiguous sensory feedback
        Scalpel = wrong but decisive test
        Skip
↓
Formal Surgery
```

麻醉效果：

```text
GA
= unconscious + analgesia

Local
= awake + surgical field analgesia only

Epidural + abdominal/pelvic
= awake + effective analgesia

Epidural + breast/thoracic
= awake + surgical field behaves like No Anesthesia

None
= awake + no analgesia
```

设计原则：

> **触诊与麻醉测试复用同一套身体互动语言，但不是同一个玩法。**
>
> **触诊问“这里有什么？”**
>
> **麻醉测试问“这里你还能感觉到什么？”**
>
> **两者都可以跳过。**
>
> **愿意互动的玩家获得更多患者反馈和福利内容；不想重复点击的玩家不会受罚。**
>
> **V0.1 只展示麻醉覆盖，不要求玩家管理麻醉深度。**

# END
