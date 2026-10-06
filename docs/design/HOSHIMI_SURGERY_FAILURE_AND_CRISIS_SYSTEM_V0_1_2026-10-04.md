# Hoshimi Hospital — Surgery Failure & Intraoperative Crisis System
## 手术失败与术中危机系统
### Design / Codex Handoff V0.1 — 2026-10-04

> **文件性质：Canonical Design Draft / 普通患者池手术成败核心**
>
> 本文件只定义：
>
> - 普通手术如何发生术中生理危机；
> - 危机如何被团队处理；
> - 什么时候一台手术判定为失败 / 中止；
> - Fear / Pain / Stability / Blood Loss / Anesthesia / Team 如何进入成败系统；
> - 玩家如何在办公室关闭术中危机。
>
> 本文件暂不完整设计：
>
> - 开刀前逃跑；
> - 固定后恐慌崩溃；
> - Dignity / 羞耻 Breakdown；
> - Cooperation 极低导致乱抓、乱踢、无法保持体位；
> - 术前 / 手术台边界事件；
> - 高级手术特有技术失败；
> - Visibility 作为通用失败条件。
>
> 这些只预留接口，后续单独设计。

---

# 0. Core Principle

普通患者池不是严肃死亡模拟。

Hoshimi 的普通手术失败应该表示：

> **本次手术无法安全继续，必须呼叫更多支援、稳定患者并终止原定手术。**

而不是：

```text
patient died
GAME OVER
```

普通池默认：

```text
Patient survives
↓
Procedure aborted
↓
No successful completion record
```

失败应制造：

```text
紧张感
团队表现
黑色医疗喜剧 / 术中事件
后续内容
```

而不是频繁惩罚玩家。

---

# 1. System Boundary

普通手术中：

## 1.1 Outcome System

决定：

```text
这台手术是否发生生理危机
↓
危机是否被团队解决
↓
手术能否继续
```

主要读取：

```text
Fear
Pain
Stability
Blood Loss
Anesthesia Route
Current Node Physiologic Stress
Team Ability
Crisis Response Choice
```

## 1.2 Patient Interaction System

另一个独立系统，主要负责：

```text
Fear
Pain
Dignity
Cooperation
Personality
Patient Cues
Dialogue / CG / Reaction
```

当前原则：

> **Dignity 与 Cooperation 暂不直接进入普通手术成功 / 失败公式。**

---

# 2. Surgery Node Loop

现有多节点术式继续作为主循环。

例如：

```text
Stage 1 / 9
Stage 2 / 9
...
Stage 9 / 9
```

每个节点：

```text
玩家选择技术动作
↓
应用 Progress / Visibility / Blood Loss / Stability / Time 等技术效果
↓
应用 Fear / Pain 等患者状态变化
↓
如果启用术中危机：
    执行 Physiologic Crisis Roll
↓
若发生 Crisis：
    进入 Crisis Resolution
↓
若危机解除：
    继续 Patient Interaction / 下一节点
↓
若危机连续补救失败：
    Procedure Abort
```

---

# 3. Physiologic Crisis

## 3.1 Crisis 是唯一的普通手术生理失败入口

第一版不要建立：

```text
Shock Failure System
Cardiac Arrest Failure System
Respiratory Failure System
Bleeding Failure System
Anesthesia Failure System
```

多个独立成败系统。

底层统一：

```text
physiologic_crisis
```

具体演出根据风险来源和麻醉方式变化。

---

# 4. Crisis Flavor by Route

## 4.1 清醒 / 无麻醉

可能表现：

```text
血压骤降
心率明显下降
迷走样反应
患者脸色发白
明显循环不稳
极端疼痛后的异常生理反应
```

## 4.2 局麻 / 硬膜外

仍然可能：

```text
血压下降
心率异常
患者清醒状态下的 Fear / Pain 诱发事件
阻滞 / 镇痛效果相关异常
```

## 4.3 全麻

Fear / Pain 在术中几乎不贡献风险。

但可以发生：

```text
麻醉深度异常
呼吸 / 通气异常
血压下降
心律异常
麻醉维持不稳
```

因此：

> **全麻不是“无危机模式”。**

它只是把患者清醒相关风险替换为麻醉相关风险。

---

# 5. Crisis Chance — V0.1 Structure

每个 surgery node 最多进行一次 Crisis Roll。

概念公式：

```text
Crisis Chance
=
Anesthesia Base Risk
+ Node Physiologic Stress
+ Fear Risk
+ Pain Risk
+ Low Stability Risk
+ High Blood Loss Risk
```

最终：

```text
clamp to a safe minimum / maximum
```

第一版建议：

```text
min ≈ 2%
max ≈ 30%
```

具体细值以后根据真实术式数据 dry run 微调。

---

# 6. Current Calibration Baseline

以下只是 V0.1 校准参考，不要求 Codex 把每个数字硬编码为永远不变。

## 6.1 Anesthesia Base Risk

```text
General Anesthesia   ~8%
Epidural             ~8%
Local                ~8%
No Anesthesia        ~2%
```

注意：

> 无麻醉的 base risk 较低，不代表总风险较低。

无麻醉真正的风险来自：

```text
Fear
Pain
```

尤其切皮后 Pain 会进入高区间。

---

## 6.2 Node Physiologic Stress

建议简单三档：

```text
low      +0%
medium   +2%
high     +4%
```

不是每个步骤都一样危险。

例如：

```text
铺巾 / 关闭
→ low

一般操作
→ medium

深部牵拉 / 关键侵入性步骤
→ high
```

---

## 6.3 Fear Risk

当前参考：

```text
Fear <60      +0%
60–74         +2%
75–89         +5%
90+           +8%
```

---

## 6.4 Pain Risk

当前参考：

```text
Pain <40      +0%
40–59         +2%
60–79         +5%
80–89         +9%
90+           +13%
```

无麻醉切皮后可以进入：

```text
Pain ~85–95
```

但不要设计成：

```text
Pain 100
→ guaranteed crisis
```

无麻醉必须保持可玩。

---

## 6.5 Stability Risk

Stability 表示：

> **患者当前生理余量 / 当前有多稳定。**

参考：

```text
80–100        +0%
60–79         +2%
40–59         +5%
<40           +8%
```

Stability 低：

```text
不会直接失败
```

而是：

```text
下一节点更容易发生 Crisis
```

---

## 6.6 Blood Loss Risk

Blood Loss 表示：

> **手术过程中已经积累的失血负担。**

参考：

```text
0–24          +0%
25–49         +1%
50–74         +3%
75+           +6%
```

Blood Loss 高：

```text
不会直接触发 FAILURE
```

而是提高后续 Crisis Chance。

---

# 7. Important Anti-Snowball Rule

第一版不要做：

```text
Blood Loss 高
→ 每节点自动大量降低 Stability
→ 两项同时提高 Crisis
→ Crisis 再降低 Stability
→ 无限制死亡螺旋
```

推荐关系：

```text
技术选择
→ Blood Loss ↑

Blood Loss
→ Crisis Chance ↑

Crisis 真正发生
→ Stability ↓

Rescue 成功
→ Stability 部分恢复
```

这样风险会累积，但不会过度雪崩。

---

# 8. Visibility — Explicitly Excluded from Generic Failure Formula

Visibility 继续保留为：

> **术式内部的技术 / 战术状态。**

它可以决定：

```text
当前步骤有哪些选项
是否需要扩大暴露
是否要重新牵开
是否需要清理术野
是否值得多花时间改善
```

但 V0.1：

```text
Visibility 不进入通用 Crisis Chance
Visibility 不设通用自动 Procedure Failure
```

未来某个 Advanced / Master Procedure 如果作者需要：

> “术野完全无法建立，因此安全中止手术”

则做成该术式的 authored special condition。

不要让所有普通手术统一套：

```text
Visibility < X
→ FAIL
```

---

# 9. Crisis Resolution

危机发生后：

```text
手术节点暂停
↓
进入 Crisis Resolution
```

玩家得到少量明确处理选项。

第一版每个 Crisis：

```text
2–3 个选项
```

即可。

例如：

### Option A — 暂停操作，全力稳定患者

```text
最高或较高 Rescue Success
时间增加较多
```

### Option B — 保持当前术野，让团队处理

```text
较依赖 Team Ability
时间增加较少
```

### Option C — 先完成当前关键动作再处理

```text
时间代价低
Rescue Success 明显较差
```

注意：

> **第一版不提供“清醒 / 无麻醉中途改全麻”作为 Crisis 处理选项。**

玩家选定的麻醉路线应有实际 Gameplay 意义。

---

# 10. Rescue Attempts

危机发生不等于手术失败。

第一次处理失败以后：

```text
Crisis Escalated
```

给第二次补救机会。

必要时再给一次最终补救。

推荐：

```text
Rescue Attempt #1
↓ fail
Rescue Attempt #2
↓ fail
Rescue Attempt #3
↓ fail
Additional Support Called
Procedure Abort
```

---

# 11. Rescue Probability — Design Target

核心体验：

> **危机出现可以频繁一些，但危机真正做崩整台手术应该比较少。**

## 11.1 Normal Team Baseline

Routine Crisis：

```text
Attempt 1   ~90%
Attempt 2   ~50%
Attempt 3   ~25%
```

Severe Crisis：

```text
Attempt 1   ~80%
Attempt 2   ~30%
Attempt 3   ~10%
```

因此即使发生危机：

> 大多数最后仍然属于“有惊无险”。

---

# 12. Team Ability

团队能力主要影响：

```text
Rescue Success
```

而不是大幅影响 Crisis 是否发生。

推荐：

```text
Strong Team
→ Rescue Success 明显提高

Normal Team
→ baseline

Developing Team
→ Rescue Success 小幅降低
```

V0.1 参考：

```text
Strong       +10%
Normal        +0%
Developing    -3%
```

Developing 不要处罚过重。

原因：

> Leadership build 需要鼓励玩家带新人 / 较弱队伍。

不能把：

```text
培养新人
```

变成：

```text
主动自杀
```

---

# 13. Outcome Target / Dry Run Acceptance

这些是系统校准目标，不是硬编码公式。

## 13.1 普通麻醉路线 + Normal Team

目标：

```text
8-node simple surgery      >=95% completion
16-node complex surgery    >=90% completion
```

也就是说：

> 普通 dry run 很稳。

但仍然允许平均出现一定数量的“有惊无险” Crisis。

---

## 13.2 No Anesthesia + Normal Team

目标：

```text
8-node simple surgery
≈ 80% completion

12-node medium surgery
≈ 70–75%

16-node complex surgery
≈ 60–70%
```

---

## 13.3 No Anesthesia + Strong Team

目标：

```text
8-node simple
≈ 90%+

16-node complex
≈ 80–90%
```

重点：

> **无麻醉不是几乎不能成功的挑战模式。**

它应该：

```text
更危险
更刺激
更多患者互动
更多 CG / reaction content
```

但优秀团队完全可以把它稳定下来。

---

## 13.4 No Anesthesia + Developing Team

目标：

```text
明显比 Normal 更危险
但仍然可玩
```

复杂术式可以落到：

```text
~55–65%
```

左右。

---

# 14. Crisis Density Target

相比“很少发生危机，但一发生就失败”，Hoshimi 更偏好：

> **一台手术出现几次有惊无险的 Crisis，但真正终止较少。**

大致目标：

```text
普通麻醉 8节点
≈ 0–1 次 Crisis / case

普通麻醉 16节点
≈ 1–2 次 Crisis / case

无麻醉 8节点
≈ 1–2 次 Crisis / case

无麻醉 16节点
≈ 2–3 次 Crisis / case
```

这会制造：

> “这台刀一路险象环生，但还是被团队救回来了。”

的感觉。

---

# 15. Crisis Failure

只有：

```text
同一次 Crisis 的所有 Rescue Attempts 都失败
```

才判定：

```text
Procedure Aborted — Additional Support Required
```

演出：

```text
当前团队无法继续稳定患者
↓
呼叫更多支援 / 上级 / 麻醉 / 其他医护
↓
患者最终稳定
↓
原定手术终止
```

普通池：

```text
Patient death = false
```

---

# 16. Failure Settlement

普通 Crisis Failure 推荐：

```text
Procedure Completed       false
Surgery Completion Count  +0
Surgery XP                0
Procedure Unlock Credit   0
Time                      normally consumed / may increase
Patient                   stable after support
```

Reputation：

```text
默认 0
```

危机本身不是职业污点。

只有未来明确设计：

```text
系统反复警告
+
玩家明知不安全仍选择继续
```

才考虑：

```text
small Reputation penalty
```

本版不需要立即实现该惩罚。

---

# 17. Fear / Pain Preparation Carry-In

Fear / Pain 可以在进入 OR 前累积。

例如：

```text
ward preparation
enema
shaving
catheterization
skin preparation
OR table palpation
```

都可以修改：

```text
Fear
Pain
Dignity
Cooperation
```

因此患者可能：

```text
还没进手术室
Fear 已经很高
```

这会自然提高后续清醒手术 Crisis Chance。

但不要把病房准备做成：

```text
前面一个选择错
→ 后面手术必败
```

只做风险累积。

---

# 18. Anesthesia / Preparation Direction

本文件只锁方向，不锁所有细值。

### No Anesthesia

```text
catheterization / painful prep
→ Pain / Fear 上升

incision
→ Pain 大幅进入高区间
```

### Local

```text
incision
→ Pain 小幅增加
```

### Epidural

```text
incision
→ 通常不增加明显 Pain
```

### General

```text
after anesthesia established:
Fear / Pain no longer meaningfully contribute to intraoperative crisis
```

但全麻仍有：

```text
anesthesia / respiratory / hemodynamic base risk
```

---

# 19. Dignity & Cooperation — Explicitly Not Failure Stats in V0.1

## Dignity

用途：

```text
羞涩
暴露反应
身体边界
低尊严“认命 / 羞耻饱和”演出
fan-service
Patient Experience
CG / dialogue flavor
```

Dignity 低：

```text
不会单独造成 Surgery Failure
```

## Cooperation

V0.1 主要影响：

```text
患者说话方式
愿不愿意顺从
抱怨 / 顶嘴 / 迟疑 / 配合感
互动 flavor
```

暂不作为普通手术成败公式输入。

---

# 20. Future Boundary Failure Hooks

以下后续单独设计：

## 20.1 Pre-Fixation Runaway

例如：

```text
Fear 极高
+
患者尚未被固定
→ 患者直接从手术台逃跑
```

可作为 Hoshimi 黑色喜剧代表性 Failure。

---

## 20.2 Post-Fixation Panic

固定后：

```text
不能逃跑
但可能：
剧烈发抖
挣扎
过度换气
恐慌
无法执行指令
```

后续再决定如何进入失败体系。

---

## 20.3 Dignity Breakdown

Dignity 极低时：

```text
羞耻饱和
认命
“坏掉感”
自嘲
麻木
```

当前：

> **只作为互动演出，不作为失败原因。**

未来如果某些特殊剧情需要影响 Cooperation，可事件级实现。

---

## 20.4 Cooperation Breakdown

未来可能：

```text
乱抓
乱踢
突然坐起
抓手术巾
无法维持体位
```

是否影响手术成败：

```text
TBD
```

不要在本 V0.1 顺手实现。

---

# 21. Player Office Option — Disable Intraoperative Crisis

主角办公室新增一个玩家可切换选项：

```text
Intraoperative Crisis Events
ON / OFF
```

建议中文 UI：

```text
术中危机事件：开启 / 关闭
```

或：

```text
手术危机：开启 / 关闭
```

---

## 21.1 Default

```text
ON
```

正常游戏默认启用。

---

## 21.2 OFF Behavior

关闭以后：

```text
不执行随机 / 通用 Physiologic Crisis Roll
不进入 Crisis Resolution
不因通用生理危机导致 Procedure Abort
```

但仍然保留：

```text
Fear
Pain
Dignity
Cooperation

患者互动
患者对白
CG
麻醉路线
技术选择
Visibility
Blood Loss
Stability
Progress
Time
```

也就是说：

> **这是关闭“失败压力”，不是关闭患者内容。**

---

## 21.3 Intended Users

用于：

### Testing

```text
测试术式节点
验证 UI
检查对白
检查 CG
验证技术选项
不希望随机 Crisis 打断测试
```

### Low-Pressure Players

```text
喜欢手术 / 患者互动内容
但不喜欢随机失败压力
```

---

## 21.4 Story / Authored Exception

该选项只关闭：

```text
generic intraoperative physiologic crisis system
```

未来明确剧情事件如果作者指定：

```text
scripted_crisis = true
```

是否仍然强制发生，由该剧情单独定义。

默认原则：

> 普通随机手术尊重玩家 OFF 选项；  
> 明确剧情高潮可以另行决定，但必须由 authored event 明确声明。

---

# 22. Save / Persistence

办公室选项应持久化：

```text
intraoperative_crisis_enabled: bool
```

默认：

```text
true
```

改动后立即保存到玩家设置 / 存档。

不要每台手术重新询问。

---

# 23. V0.1 Implementation Priority

第一阶段只实现：

```text
1. Crisis Chance resolver
2. Anesthesia base risk
3. Fear / Pain / Stability / Blood Loss modifiers
4. Node physio_stress
5. Crisis Resolution
6. Team rescue modifier
7. 1–3 rescue attempts
8. Procedure Abort
9. Office ON/OFF toggle
10. Dry run / automated simulation tests
```

暂不实现：

```text
Runaway
Dignity Breakdown Failure
Cooperation Breakdown Failure
Visibility Failure
Complex anesthesia conversion
Death
Permanent injury
Complication tree
Advanced technical failure graph
```

---

# 24. Final Design Summary

普通 Hoshimi Surgery V0.1：

```text
技术节点
↓
Fear / Pain / Stability / Blood Loss / Anesthesia
↓
Physiologic Crisis Chance
↓
Crisis
↓
Team + Choice
↓
Rescue Attempt 1
↓ fail
Attempt 2
↓ fail
Attempt 3
↓ fail
More Support Called
↓
Patient Stabilized
Procedure Aborted
```

核心体验：

> **危机可以比较常见。**
>
> **真正失败应该比较少。**
>
> **多数危机应当是“有惊无险”。**
>
> **优秀团队明显提高把患者救回来的能力。**
>
> **无麻醉更危险，但绝不是不可玩的路线。**
>
> **普通失败不死人，只结束这台手术。**

同时：

```text
Visibility
→ 技术 / 节点设计

Dignity / Cooperation / Personality
→ Patient Interaction
```

三套职责不要混在一起。

# END
