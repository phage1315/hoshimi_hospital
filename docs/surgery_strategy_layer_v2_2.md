# Hoshimi Hospital 手术策略层 V2.2
## Codex 后续实现规格（在术式复杂度扩展稳定后实施）

> 适用项目：Hoshimi Hospital  
> 本文是以下现有设计文档的后续补充层，不替代它们：
>
> - `surgery_v2_design_summary_relinked.md`
> - `HOSPITAL_SURGERY_PATIENT_INTERACTION_V2_1.md`
> - `HOSPITAL_SURGERY_PROCEDURE_SPECIFIC_PATIENT_DIALOGUE_V2_1A.md`
>
> **实施顺序：先完成术式复杂度和互动密度，再实现本文的策略层。**

---

# 1. 核心设计目标

本项目不是制作真实外科模拟器，而是制作具有“手术感”的选择枝式医疗 VN / simulation。

如果手术完全没有不确定性，它就只是：

```text
目标明确
→ 按步骤执行
→ 熟练者更快
→ 不熟练者更慢
```

真正产生策略性的内容来自：

```text
病例本身与标准模板不同
+
过程中出现非预期情况
+
玩家之前的选择改变当前局面
+
修正错误本身存在代价
+
有些异常值得处理，有些不值得打断流程
```

所以不要把“20步手术”做成20次点击“继续”。

目标体验是：

> 标准流程我知道，但这一台现在出了点状况，我应该怎么处理？

---

# 2. 这个系统除了“做手术”，还服务于什么

这一点应当在设计文档里**明确强调**。

手术系统的目标不仅是“完成术式”，还包括两个非常重要的元目标：

## 2.1 体会不同医护角色的丰富互动

玩家进入手术，不只是为了把患者从第 1 步做到第 20 步。

更重要的是：

```text
和不同助手合作时的判断差异
和不同护士搭配时的对话风格
遇到非预期时各角色的建议、吐槽、安抚与默契
不同关系阶段下的台词变化
不同术式 / 麻醉 / 病例条件下的反应差异
```

因此：

> **手术本身也是角色互动内容的主要容器。**

玩家应当期待：

- 和御堂搭台时，能感受到冷静、专业、略带压迫感的建议；
- 和城宮明日香搭台时，能感受到理论扎实、温柔友好、偶尔仍有年轻感的判断；
- 和饭村搭台时，外科上吐槽不断，但在药物、患者不适、围术期细节上会有意外可靠的发言；
- 同一角色在低关系、高关系、默契成长后，说话方式与主动提醒频率都明显不同。

## 2.2 解锁特殊事件与 CG

手术系统也是“特殊事件”和“稀有 CG”的主要触发池。

手术中可解锁的内容应包括：

```text
术中小事件
术后短事件
角色专属台词池
关系成长节点
稀有组合事件
特殊患者 × 特定团队的限定场景
特定麻醉 / 特定术式 / 特定局面下的CG
```

因此玩家在做手术时，不只是追求技术成功，也是在追求：

> **“这一台会不会看到新的互动？”**  
> **“这次搭档会不会说出以前没听过的话？”**  
> **“某个特殊局面能不能解锁新的 CG / 剧情节点？”**

---

# 3. 重玩价值：不是刷同一句话，而是分层挖掘内容

可以明确告诉 Codex：

> **重复手术不是为了机械 grind，而是为了逐步挖掘角色内容。**

确实可以存在这种体验：

> 一个玩家需要和同一个人物一起开刀很多次，才能穷尽她的全部台词、互动和特殊事件。

但要注意，设计目标不是：

```text
重复完全相同的一台手术几十次
只为了听完一大池随机台词
```

而应该是：

```text
在不同术式
不同病例 Modifier
不同麻醉方式
不同角色位置
不同关系等级
不同手术局面
下，逐步挖掘新的对白与事件
```

也就是说，“几十次”是可以接受的，但应理解为：

> **围绕同一角色，在多种手术情境里逐步挖空她的内容。**

而不是单纯重复同一模板。

---

# 4. 推荐的角色互动内容分层

为了让“多次手术同一角色”有意义，建议把术中内容拆成层次池。

## 4.1 Common Lines（常规公共台词）

任何搭档都可能在普通场景说的基础台词。

例如：

```text
术前确认
普通配合
常见提醒
标准鼓励 / 吐槽
```

这部分应大量复用，但按角色口吻区分。

## 4.2 Procedure / Context Lines（术式 / 情境台词）

按以下因素变化：

```text
procedure_group
具体 surgery_id
麻醉方式
是否清醒
是否出现 nausea / drowsiness / low oxygen / bleeding 等事件
```

目标是让：

> 同一个角色在不同手术里，说的话明显不同。

## 4.3 Relationship Lines（关系成长台词）

随着关系提升，角色在手术中的表现变化：

```text
更主动提醒
更敢质疑主角
更自然地调情 / 吐槽 / 关心
更了解主角习惯
```

这层最能体现“和同一角色多上几次手术”的价值。

## 4.4 Signature Lines / Signature Events（标志性内容）

每个主要角色都应拥有：

```text
少量高辨识度台词
少量只有特定条件下触发的专属事件
少量高价值 CG
```

这些内容不应过早耗尽，而应作为中后期持续奖励。

## 4.5 Rare Combination Events（稀有组合事件）

例如：

```text
特定助手 + 特定巡回护士
特定助手 + 特定患者类别
特定时间段 / 夜间手术
特定术式 + 特定角色组合
```

这类内容很适合拉高重玩价值。

---

# 5. 因此，手术系统的目标可以明确写成三条

建议在 MD 中明确写出：

## 5.1 手术技术目标

```text
完成手术
处理非预期情况
在风险与时间之间取舍
```

## 5.2 角色互动目标

```text
体会不同角色在不同手术中的个性化互动
积累关系与团队默契
解锁更多台词层级
```

## 5.3 内容收集目标

```text
解锁特殊术中/术后事件
解锁专属 CG
解锁稀有组合内容
```

这样 Codex 在做系统时就不会误以为：

> 手术只是一个答题器。

而会理解：

> 手术本身就是这个游戏里最重要的“角色内容生成器”之一。

---

# 6. 关于“要不要几十次才能挖空一个角色”

答案是：**可以，但要有结构。**

推荐不要把一个角色的全部内容做成单一随机池。

更好的结构是：

## 6.1 低频重复内容

普通基础台词，前几次就能听到很多。

## 6.2 中频成长内容

随着关系和合作次数逐步解锁。

## 6.3 高门槛稀有内容

只有在特殊条件下出现，例如：

```text
某个 procedure_group
清醒患者
出现特定非预期
角色关系达到某级
主角某属性达到门槛
特定时间段
特定搭档组合
```

这就意味着：

> 玩家可能确实需要和某个角色一起做 15 次、20 次、甚至更多手术，才能看到她的大部分内容。

但这会被体验成：

> **“我在不断解锁她的新层次。”**

而不是：

> **“我在刷同一句话。”**

---

# 7. 推荐把“合作次数”也当成轻量成长轴

除了 Relationship Level，还可以有：

```text
team_bond
operation_count_together
procedure_experience_with_character
```

不一定需要独立暴露给玩家，但后台可以作为解锁条件。

意义：

- 同一个角色和主角一起上台越多，术中口吻越自然；
- 某些高级互动不一定非要靠恋爱关系，而是靠“我们已经一起上过很多次手术”的职业默契；
- 有些内容是“亲密”，有些内容是“搭档感”，两者可以并存。

例如：

```text
御堂在关系不高时也可能因为共同做了很多复杂手术，而出现高度默契型台词。
```

这会非常好。

---

# 8. 实施时机

本系统应放在“术式复杂度提升”之后。

在加入 Timer / Vitals / Complications 之前，每个术式首先应有足够的真正决策点。

建议：

```text
简单术式 6–8 steps：至少 3–4 个 meaningful decisions
中型术式 9–12 steps：至少 4–6 个 meaningful decisions
大型术式 13–16 steps：至少 6–8 个 meaningful decisions
极大型 17–20 steps：至少 8 个以上 meaningful decisions
```

“meaningful decision”不是单纯正确/错误题，而是至少在以下方面形成取舍：

```text
Time
Progress
Visibility
Bleeding
Patient state
Assistant Support
Risk
```

如果一个术式仍然只是：

```text
确认 → 正确答案 → 确认 → 正确答案 → 完成
```

则不要先加入复杂计时与生命体征。

---

# 9. 策略层主要状态

尽量复用现有变量，不无限增加新属性。

推荐主要使用：

```text
progress
visibility
bleeding
blood_loss
elapsed_time
assistant_support
```

以及已有患者状态：

```text
fear
pain
dignity
cooperation
```

以后表层监护增加：

```text
HR
BP
SpO2
```

## 9.1 Progress

表示手术推进度。

安全动作不一定明显推进，例如：

```text
扩大暴露
处理小出血
重新确认结构
```

这些操作可以 Progress 很少，但改善后续局面。

## 9.2 Visibility

表示当前术野是否清楚。

低 Visibility 应增加：

- 技术操作风险；
- 判断错误机会；
- 激进操作的危险性；
- 优秀助手主动提醒的价值。

不要频繁直接显示 `Visibility = 43`。优先通过助手对白表现：

```text
“这里开始看不清了。”
“暴露不够，再往下做会越来越困难。”
```

## 9.3 Bleeding

表示当前持续的出血压力，不等于累计失血。

它会影响：

```text
Visibility
后续 Blood Loss
意外升级概率
```

## 9.4 Blood Loss

表示累计失血。

明显失血以后可以逐渐影响：

```text
HR ↑
BP ↓
```

## 9.5 Elapsed Time

时间是资源，不是硬倒计时。

不要设计成：

```text
超过120分钟 → 自动失败
```

而应让拖延逐渐改变患者和团队状态。

---

# 10. 决策应是 Trade-off，而不是考试题

每个战略 decision 只需要影响 2–4 个维度。

## 10.1 Conservative

典型倾向：

```text
Progress      低
Time          高
Visibility    ↑
Bleeding      ↓
Risk          ↓
```

## 10.2 Standard

```text
Progress      中
Time          中
Risk          中
```

## 10.3 Aggressive

```text
Progress      高
Time          低
Visibility    可能下降
Bleeding      可能增加
Risk          ↑
```

Aggressive 不等于错误。

如果：

```text
Visibility 很好
Bleeding 很低
玩家 Surgery 很高
助手可靠
```

则快速推进可能是合理甚至优秀的选择。

## 10.4 Delegate

某些问题可以交给助手：

```text
Time              低
Risk              ↓
Assistant Support -1
```

---

# 11. 不要让“永远保守”成为最优解

如果保守路线没有代价，玩家会永远选择最安全方案。

过度保守可以导致：

```text
Elapsed Time ↑
清醒患者 fatigue ↑
Fear / Pain burden ↑
Cooperation ↓
Team fatigue ↑
后续 minor event 权重 ↑
```

大型清醒手术中尤其可以出现：

```text
“医生……还要多久？”
```

---

# 12. 不要让“永远猛冲”成为最优解

激进策略的危险不应总是立即失败，而是坏状态累积。

例如：

```text
第一次强推：Bleeding 5 → 12，Visibility 90 → 82
第二次强推：Bleeding 12 → 25，Visibility 82 → 68
第三次强推：Bleeding 25 → 45，Visibility 68 → 42
```

前两次可能没出事，第三次才可能触发：

```text
明显出血
术野恶化
判断困难
助手介入
```

玩家应该感觉：

> 我把局面推坏了。

而不是：

> 系统随机阴我。

---

# 13. 推荐核心节奏：准备 → 抓机会推进

最佳策略不应是全程保守或全程猛攻。

推荐：

```text
先改善条件
→ 等待窗口
→ 好局面下快速推进
→ 状态恶化后重新稳住
```

示例：

```text
Visibility 60
→ 扩大暴露
→ Visibility 85

Bleeding 15
→ 先处理
→ Bleeding 3

此时：
“趁术野良好，快速完成关键步骤。”
```

前面的准备使后面的 Aggressive choice 风险变低。

---

# 14. 病例 Modifier：同一术式每次不应完全一样

术式决定“说明书”，患者身体状况决定“这一台模型到底难不难拼”。

第一版推荐病例 Modifier：

```text
exposure_difficulty
adhesion
tissue_quality
vascularity
anatomy_variation
lesion_complexity
bleeding_tendency
physiologic_reserve
```

普通病例不要全部叠加。

建议：

```text
普通病例：0–1 个显著 modifier
困难病例：2 个
Boss：3–4 个
```

---

# 15. Exposure Difficulty

表示到达目标和保持术野有多困难。

主要影响：

```text
Visibility 初值
暴露步骤耗时
Assistant 价值
Aggressive 风险
```

表现优先用对白：

```text
“位置比较深，暴露会比平时麻烦。”
“牵开以后视野还是不够。”
```

---

# 16. Adhesion

建议作为第一批重点 Modifier。

```text
none
mild
moderate
severe
```

主要作用于：

```text
exposure
separation
deep manipulation
```

严重粘连可以动态加入选择：

### 逐层处理

```text
Time +++
Visibility +
Bleeding Risk 低
```

### 换方向寻找平面

```text
Time ++
结果存在不确定性
```

### 强行推进

```text
Time +
Progress +++
Bleeding Risk 高
```

不要做成：

```text
severe adhesion → 全手术所有 stage difficulty +20%
```

---

# 17. Tissue Quality

推荐：

```text
normal
fragile
inflamed
edematous
```

它主要改变某些技术动作的风险。

不要显示后台标签，而让助手说：

```text
“组织很脆，别拉那么重。”
“炎症比预想严重，层次不太清楚。”
```

同一个 Aggressive choice 在正常组织可能安全，在脆弱组织就可能危险。

---

# 18. Vascularity 与 Bleeding Tendency

两者不要合并。

## Vascularity

局部区域本身血供丰富。

主要影响：

```text
局部 technical step 的 Bleeding gain
```

## Bleeding Tendency

患者全局更容易持续渗血。

主要影响：

```text
所有相关操作产生 Bleeding 的幅度
```

因此平常可以观察的小渗血，在某些患者身上值得更早处理。

---

# 19. Anatomy Variation

推荐：

```text
standard
minor_variant
major_variant
```

目标不是做高级解剖考试，而是让标准流程产生变化。

高技能助手可能早期发现：

```text
“停一下，这里的结构关系和标准情况不一样。”
```

普通助手：

```text
“这里……是不是和平时不太一样？”
```

低技能助手可能晚几个 stage 才发现。

---

# 20. Lesion Complexity

表示病灶：

```text
大小
位置
范围
与周围结构关系
```

主要影响：

```text
关键 stage difficulty
Expected Time
Progress gain
```

---

# 21. Physiologic Reserve

第一版不要模拟十几种慢性病。

使用：

```text
high
normal
low
```

含义：同样的意外，不同患者能承受的程度不同。

低 Reserve 患者更容易从：

```text
Warning → Critical → Emergency
```

---

# 22. Modifier 只影响相关 stage

例如：

```text
Adhesion
→ exposure / separation

Vascularity
→ dissection / resection

Anatomy Variation
→ identification / key decision

Low Reserve
→ complication tolerance
```

每个 Modifier 要有自己的“戏份”。

---

# 23. 意外应主要来自局面，而不是纯随机

不要：

```text
每个 stage 固定 5% 大出血
```

建议概念：

```text
Complication Risk
=
Base Step Risk
+ Case Modifier Risk
+ Bad Visibility
+ Bleeding Pressure
+ Aggressive Choice
- Player Surgery
- Assistant Intervention
+ 少量随机波动
```

不要求第一版精确照公式实现。

重点是：

> 风险主要来自当前局面。

---

# 24. 三层“非预期”

## 24.1 Friction

正常阻力：

```text
暴露困难
步骤耗时增加
患者紧张
层次不好
```

不算并发症。

## 24.2 Error / 可修正错误

例如：

```text
过早推进
忽略持续渗血
方向判断不理想
需要退回重新处理
```

推荐流程：

```text
犯错
→ 发现
→ Correction
→ 付出代价
→ 手术继续
```

代价：

```text
Time +
Bleeding +
Visibility -
Support -
```

不要轻易 Game Over。

## 24.3 Complication

真正意外：

```text
明显出血
突发低血压
明显低氧
患者无法继续配合
助手必须接管
```

重度意外不应每台手术反复出现。

---

# 25. Assistant 的新定位

Assistant 不只是：

```text
Surgery +10
```

而应该是：

> **第二双眼睛 + 第二个判断者 + 紧急资源。**

主要作用：

```text
发现问题
解释非预期情况
提供意见
协助执行
紧急兜底
```

---

# 26. Assistant 四项后台能力

推荐：

```text
observation
technical_judgment
procedure_familiarity
intervention_skill
```

## Observation

决定能否及时发现：

```text
持续渗血
解剖异常
组织异常
术野恶化
患者状态变化
```

## Technical Judgment

决定发现问题后，建议质量如何。

后台可以区分：

```text
good
neutral
bad
uncertain
```

UI 不显示标签。

## Procedure Familiarity

表示是否熟悉当前术式/领域。

例如：

- 御堂：大型外科可靠；
- 城宮明日香：理论和辅助经验强，但复杂独立主刀经验较少；
- 飯村：外科技能弱，但药物相关事件非常可靠。

## Intervention Skill

决定把问题真正交给她处理时的成功程度。

允许出现：

```text
很会看，但不一定很会做
```

或反过来。

---

# 27. Skill 与 Relationship 分工

不要让高 Relationship 把低技能角色变成外科天才。

```text
Skill
→ 决定她看得准不准、做得好不好

Relationship / Teamwork
→ 决定她多早开口、是否主动提出不同意见
```

低关系：

```text
明显危险才提醒
```

高关系 / 高默契：

```text
早期就会说：
“我觉得这里不太对。”
```

---

# 28. Assistant Advice 应通过角色对白呈现

不要让系统旁白写：

```text
患者腹壁粘连严重。
清理耗时 ×1.5。
```

应该让助手说：

```text
“粘连比影像上重得多。”
“这里别急，想清干净会比预计花时间。”
```

后台再执行：

```text
adhesion = severe
step_time_multiplier = 1.5
```

玩家不直接看公式。

---

# 29. 同一个隐藏状态，不同助手应给出不同质量的信息

假设：

```text
severe_adhesion
```

御堂：

```text
“这里不只是腹壁粘连。继续往深部以前先把这一层处理干净。”
```

明日香：

```text
“比预想粘得厉害……我觉得慢一点会比较稳，要不要从旁边找更清楚的层次？”
```

年轻助手：

```text
“这里……好像有点不好分开。”
```

飯村：

```text
“等等，这跟我大学里看的图完全不是一回事吧……你确定要我在这里帮？”
```

这让角色能力直接进入 Gameplay。

---

# 30. Assistant Advice 不保证正确

建议质量不应纯随机，而应主要取决于：

```text
Technical Judgment
+ Procedure Familiarity
+ Observation
- Case Complexity
- Fatigue / Stress
```

允许：

### Good Advice

```text
“先处理这里，否则后面越来越看不清。”
```

### Neutral Advice

```text
“现在处理比较稳，不过继续做也不是不行。”
```

### Bad Advice

例如经验不足的助手过度紧张，建议浪费大量时间处理一个其实可以观察的小问题。

### Uncertain

```text
“……我不确定。我没有独立遇到过这种情况。”
```

`uncertain` 应保留，它比随机说错更自然。

---

# 31. Advice 不等于接管

建议区分：

## 被动发现

```text
自动发生
通常不消耗 Assistant Support
```

## 主动询问

玩家：

```text
“你怎么看？”
```

第一版可不消耗 Support。

## 真正介入

玩家：

```text
“你来处理。”
```

消耗 Assistant Support。

## 自动救场

玩家明显失误时，高级助手可以自动介入，消耗更多 Support。

---

# 32. 信息来源原则

## 机器直接告诉玩家

```text
HR
BP
SpO2
Elapsed Time
```

## 患者告诉玩家

```text
疼痛
害怕
恶心
疲劳
呼吸不适
尊严压力
```

## Assistant 告诉玩家

```text
粘连
术野
组织状态
解剖异常
持续渗血
技术风险
预计额外耗时
```

## 玩家负责

```text
信不信
要不要处理
什么时候处理
要不要交给助手
```

核心体验：

> **机器提供数据；患者提供主观感受；助手提供判断；玩家负责决策。**

---

# 33. 生命体征只做临场感 + 事件触发器

第一版只需要：

```text
HR
BP
SpO2
```

## HR

主要反映：

```text
Fear
Pain
循环压力 / Blood Loss
```

## BP

主要反映：

```text
循环稳定性
明显失血
特殊事件
```

大出血可以表现为：

```text
HR 先上升
随后 BP 下降
```

## SpO2

主要反映：

```text
呼吸 / 氧合事件
镇静 / drowsiness
胸部术式特殊事件
气道问题
```

普通疼痛和喊叫不应自动导致 SpO2 下降。

低氧可以触发：

```text
补氧处理
鼻导管 / 氧气面罩 CG
```

---

# 34. 不是每个体征异常都要处理

例如：

```text
HR 118
BP 142/86
SpO2 98
```

可能只是患者紧张。

护士可以说：

```text
“心率有点快。”
```

玩家可以继续。

真正需要注意的例子：

```text
HR 132
BP 82/46
SpO2 97
```

提示循环问题。

或者：

```text
HR 108
BP 116/70
SpO2 88
```

提示呼吸/氧合问题。

---

# 35. 时间系统在决策层成熟后加入

现有：

```text
duration_minutes
```

以后用作：

```text
Expected Time
```

新增：

```text
Elapsed Time
```

建议阶段：

```text
<=100% Expected：正常
100–125%：轻度延长
125–150%：明显延长
>150%：高风险延长
```

具体阈值以后平衡。

时间延长可以逐步增加：

```text
清醒患者 fatigue
Fear
Pain burden
Cooperation loss
Team fatigue
Minor event weight
```

---

# 36. 处理异常本身也消耗时间

这是核心取舍之一。

轻微异常：

### 观察

```text
Time +0
可能自行稳定
```

### 处理

```text
Time +3
风险下降
```

如果每个小异常都处理，手术会被拖长。

如果全部忽略，小问题可能累积成大问题。

---

# 37. Risk Preview

以后可以给选择显示模糊预览：

```text
直接推进
推进  +++
耗时  +
风险  High
```

或：

```text
先改善暴露
推进  +
耗时  +++
风险  Low
```

不要显示：

```text
Complication Chance = 17.3%
```

高 Surgery 玩家可以获得更准确的文字提示，让 Surgery 同时成为“信息优势”。

---

# 38. 未来 Schema 草案（不要现在立即实现）

病例级：

```json
{
  "case_modifiers": {
    "exposure_difficulty": "normal",
    "adhesion": "severe",
    "tissue_quality": "inflamed",
    "vascularity": "high",
    "anatomy_variation": "standard",
    "lesion_complexity": "moderate",
    "bleeding_tendency": "normal",
    "physiologic_reserve": "normal"
  }
}
```

stage 级以后可增加：

```json
{
  "affected_by": ["adhesion", "tissue_quality"],
  "base_minutes": 8
}
```

option 级以后可增加：

```json
{
  "strategy": "conservative",
  "strategic_effects": {
    "progress": 5,
    "minutes": 8,
    "visibility": 15,
    "bleeding": -5,
    "assistant_support": 0,
    "risk": -10
  }
}
```

现阶段不要为了这些字段破坏 V2.1。

---

# 39. 与 V2.1 Patient Interaction 的关系

继续保留：

```text
fear
pain
dignity
cooperation
awake_interlude
patient_cues
temporary_conditions
```

Strategy Layer 加入后：

```text
技术决策
→ 主要改变 Time / Bleeding / Visibility / Progress

Patient Interaction
→ 主要改变 Fear / Pain / Dignity / Cooperation / Time
```

两层不要硬混成一个系统。

---

# 40. 与 V2.1A Procedure-Specific Dialogue 的关系

继续保留：

```text
procedure_group
surgery_ids
signature interaction
```

病例 Modifier 可以改变哪些对白更合理，但不要为每个身体状况再增加新的永久心理数值。

---

# 41. 推荐开发顺序

## Phase 1 — 当前优先

完成：

```text
术式 6–20 步扩展
更多真正有取舍的 decision
患者互动密度
术式特异对白
```

## Phase 2 — Case Variation

优先增加 3–5 个最有价值的 Modifier：

```text
adhesion
tissue_quality
anatomy_variation
vascularity
physiologic_reserve
```

## Phase 3 — Strategic State

启用：

```text
Visibility
Bleeding
Blood Loss
Elapsed Time
```

让 decision 真正改变局面。

## Phase 4 — Assistant Intelligence

启用：

```text
Observation
Technical Judgment
Procedure Familiarity
Intervention Skill
Assistant Support
```

加入：

```text
主动发现
建议
询问意见
介入
自动救场
```

## Phase 5 — Vitals / Complications

增加：

```text
HR
BP
SpO2
```

建立：

```text
Warning
→ Complication
→ Emergency
```

不要一开始制作复杂医学模拟。

---

# 42. 最终原则

> **术式决定说明书。**  
> **患者身体状况决定这一台实际有多难。**  
> **玩家的决策决定局面变好还是变坏。**  
> **助手决定玩家能看到多少问题、得到什么建议，以及出错后还有多少余地。**  
> **体征和计时负责把这些变化可视化，而不是反过来主导游戏。**  
> **而手术系统本身，则是角色互动、特殊事件与 CG 解锁的最主要内容容器之一。**

最终希望玩家完成一台手术以后感觉：

> **“这台手术是我根据当时的情况做完的。”**  
> **“而且这一次，我还看到了这名角色新的反应、新的关系变化，甚至新的 CG。”**

而不是：

> **“我按顺序点完了20个按钮。”**

---

# 43. 团队角色互动必须成为核心 Gameplay，而不是装饰对白

手术系统的游戏性不只来自技术选择、病例 Modifier 与意外。

另一条同样重要的主线是：

> **不同医护角色在同一台手术里，提供不同类型的信息、判断、情绪反馈和关系变化。**

因此，团队互动必须被视为手术系统的一部分，而不是单纯插入几句 flavor text。

推荐把三类核心团队角色分工明确：

```text
Assistant Surgeon
→ 技术判断 / 术野观察 / 风险建议 / 介入 / 兜底

Scrub Nurse
→ 器械节奏 / 术者默契 / 无菌台流程 / 清点 / 器械与标本管理

Circulating Nurse
→ 患者状态 / 监护 / 环境 / 设备 / 补给 / 联络 / 非无菌事务
```

三者都应拥有独立的互动价值。

---

# 44. Assistant Surgeon：最深的技术互动

现实和游戏中，主刀与助手应保持最密集的技术交流。

Assistant 的主要互动方向：

```text
发现异常
判断术野
识别病例 Modifier
提供建议
提出不同意见
执行局部处理
接管某一步
自动救场
```

Assistant 适合承载：

- 高信息量对白；
- 非预期情况判断；
- 风险提示；
- 对玩家策略的评价；
- 高关系下的专业默契；
- 角色差异最明显的技术互动。

Assistant 的台词数量不必最多，但应当是：

> **信息最密、影响决策最直接的一类互动。**

---

# 45. Scrub Nurse：最频繁的“微互动”与节奏感

器械护士不应沦为：

```text
“递刀的人”
```

她应承担：

> **Efficiency / Rhythm / Anticipation**

即：

```text
手术节奏
器械准备
主刀习惯记忆
术者默契
清点与流程安全
```

## 45.1 推荐互动类型

### 预判主刀需求

例如：

```text
你还没有完全伸手，她已经把下一件器械递了过来。
```

高默契时可以完全无对白，用动作体现关系成长。

### 器械确认

```text
“你要的是这把，还是长柄的？”
```

适合低默契、新器械、复杂步骤。

### 器械准备不足 / 提前准备

例如：

```text
“备用器械我已经放到右侧了。”
```

或：

```text
“这一套没有开，需要我现在准备吗？”
```

### 主刀节奏观察

```text
“医生，你今天换器械的速度比平时快。”
“术野不满意吗？”
```

### 清点

关闭前可以出现：

```text
器械数量不一致
纱布清点不一致
需要暂停复核
```

这是非常适合 Scrub Nurse 的轻度 / 中度意外。

### 标本处理

例如：

```text
“这个标本需要单独标记吗？”
“这一份要送病理，我先分开放。”
```

### 记住主刀习惯

高关系 / 高 teamwork 时：

```text
她已经知道玩家喜欢的器械顺序
缝线偏好
递法
节奏
```

这类互动应当成为长期合作的奖励。

---

# 46. Scrub Nurse 的数值意义

未来可以让 Scrub Nurse 主要影响：

```text
step_time
instrument_delay
mistake_recovery
closure/checklist reliability
team rhythm
```

不要让她主要承担：

```text
patient comfort
non-sterile logistics
external communication
```

这些属于 Circulating Nurse。

推荐未来概念：

```text
OR Support
```

其作用可以包括：

- 器械准备速度；
- 减少某些操作的额外时间；
- 降低器械 / 清点类错误；
- 高默契下触发“预判递械”事件；
- 在复杂手术中维持操作节奏。

---

# 47. Circulating Nurse：患者、环境与外围问题

巡回护士的核心定位：

> **Patient / Logistics / Environment**

她不是术野内的第二技术判断者，而是：

> **连接患者与整个手术室环境的人。**

## 47.1 推荐互动类型

### 患者安抚

当：

```text
Fear ↑
Pain ↑
Cooperation ↓
```

巡回护士可以主动与患者说话。

### 患者状态观察

例如：

```text
“她刚才开始发抖了。”
“她一直说冷。”
“她回答问题的速度比刚才慢。”
```

### 监护提醒

例如：

```text
“心率一直在一百二十以上。”
“血压比刚才低。”
“血氧九十二，还在往下。”
```

### 补氧事件

低氧时可以触发：

```text
鼻导管
氧气面罩
手扶面罩
```

这类事件很适合和 CG 绑定。

### 舒适与体位问题

清醒患者可出现：

```text
觉得冷
背部不舒服
手臂麻
体位难以维持
```

### 设备问题

例如：

```text
监护设备
灯光
吸引器
输液
备用设备
```

### 补充物资

例如：

```text
额外纱布
耗材
备用缝线
药物
```

### 外部联络

例如：

```text
通知病房
联系其他医生
叫血
通知院长
寻找额外人员
```

### 时间提醒

例如：

```text
“已经两个半小时了。”
```

### 患者主动提出中止 / 拒绝 / 强烈抗议

这种情况应优先由 Circulating Nurse 做第一反应。

---

# 48. Circulating Nurse 的数值意义

未来可定义：

```text
Patient Support
```

主要影响：

```text
Fear
Dignity
Cooperation
临时状态处理
低氧/恶心/疲劳等外围事件
```

与 Assistant Support、OR Support 区分：

```text
Assistant Support
→ 技术判断 / 介入

OR Support (Scrub Nurse)
→ 器械 / 节奏 / 清点 / 无菌台流程

Patient Support (Circulating Nurse)
→ 患者 / 监护 / 环境 / 外围事务
```

三者不要做成同一种“万能支援点”。

---

# 49. 团队互动不应永远是一对一

必须支持：

> **多角色共同参与的团队事件。**

例如：

```text
助手：
“这里粘连很重，先别往下做。”

器械护士：
“要换更细的器械吗？”

巡回护士：
“患者刚刚问是不是出了问题。”
```

此时玩家可以选择：

```text
听助手，先慢下来
让器械护士换器械
让巡回护士安抚患者
继续当前步骤
```

这种事件比：

```text
主角 → 单一 NPC → 结束
```

更能体现“团队手术”。

---

# 50. 角色互动内容必须 Data-Driven

未来希望特殊互动内容能够大量由内容生成，而不是修改核心代码。

因此核心程序应提供通用的：

```text
interaction_hook
context
condition
priority
cooldown
once_per_surgery
once_per_character
relationship_requirement
procedure_requirement
```

角色内容包只负责：

```text
personality
professional_skill
speech_style
relationship_style
specialties
interaction_tags
interaction_entries
```

这样以后可以单独生成大量角色内容，而不修改 Surgery Runtime。

---

# 51. 推荐 interaction hooks

第一版可以预留：

```text
preop
changing
scrub
room_entry
team_check
exposure
instrument_request
unexpected_finding
assistant_advice
patient_distress
bleeding
low_bp
low_oxygen
nausea
drowsiness
fatigue
instrument_problem
count_mismatch
specimen_handling
closure
postop
```

不同角色只需要订阅相关 hook。

例如：

```text
飯村
→ medication / nausea / drug / unexpected anatomy / comic assistant hooks

御堂
→ unexpected_finding / bleeding / assistant_advice / difficult dissection

弘子
→ patient_distress / circulating care / postop / fatigue
```

---

# 52. 推荐 Runtime Context

事件生成 / 匹配时，Runtime 至少能够提供：

```text
current_surgery_id
procedure_group
current_stage_id
stage_kind
case_modifiers
progress
visibility
bleeding
blood_loss
elapsed_time
HR
BP
SpO2
anesthesia_type
patient_state
assistant_id
scrub_nurse_id
circulating_nurse_id
relationship_levels
teamwork / operation_count_together
current_flags
recent_interaction_history
```

这样同一个角色可以在完全不同的上下文中产生不同事件。

---

# 53. 互动内容生成要求

未来允许通过外部内容生成流程（例如由设计者或语言模型批量生成）扩充互动。

核心要求：

1. **生成内容不能要求修改核心代码。**
2. 新对白 / 新事件应当主要通过 JSON / content pack 加入。
3. 所有互动必须绑定明确的：
   - hook；
   - role；
   - context；
   - conditions；
   - priority / rarity。
4. 必须支持 Validator，避免：
   - 引用不存在的角色；
   - 引用不存在的术式；
   - 非法 hook；
   - 无限重复；
   - 多事件冲突。
5. 生成器应能够根据角色：
   - 性格；
   - 职业背景；
   - 技能；
   - 关系等级；
   - 当前术式；
   - 当前病例状态；
   - 当前团队构成；
   生成对应互动。

目标是：

> **设计者只需要提供角色 Bible + 数值 + 当前手术上下文，就可以快速生成大量可直接导入游戏的互动内容。**

---

# 54. 不同职位的互动密度建议

为了形成明显区别：

## Assistant Surgeon

```text
数量：中等
单条长度：中等～较长
决策影响：高
技术信息密度：最高
```

## Scrub Nurse

```text
数量：最多
单条长度：短
决策影响：低～中
默契/节奏感：最高
```

## Circulating Nurse

```text
数量：较多
单条长度：短～中
决策影响：中
患者与环境事件：最高
```

因此：

> **助手最深，器械护士最频繁，巡回护士最丰富。**

---

# 55. 同一人物多次上台必须逐渐产生“熟悉感”

随着：

```text
operation_count_together
team_bond
relationship_level
```

增长，应逐步解锁：

```text
更自然的称呼
更短的指令
更少的确认
更早的主动提醒
更明显的个人吐槽
默契型无对白动作
只有长期搭档才会出现的台词
```

例如：

```text
初期：
“医生，需要这把吗？”

高默契：
你刚伸手，她已经把器械送进掌心。
```

这种变化本身就是角色成长。

---

# 56. 特殊事件与 CG 也可以由团队角色触发

特殊 CG 不应只属于患者。

例如：

```text
器械护士高默契递械 CG
巡回护士给清醒患者吸氧 CG
助手接管关键步骤 CG
困难病例全员配合 CG
夜间手术特殊团队 CG
关系高时的术后休息室事件
```

因此：

> **手术系统是角色事件与 CG 解锁的主要舞台之一。**

---

# 57. 对后续内容制作的要求

未来扩充角色时，应优先为每个主要医护建立：

```text
职业定位
技能强项
技能弱项
讲话风格
遇到风险时的反应方式
患者互动风格
团队互动风格
关系成长后的变化
```

然后再按：

```text
Assistant
Scrub Nurse
Circulating Nurse
```

不同岗位生成专属互动。

不要把同一角色在三个岗位上的对白简单换名复用。

例如飯村若被临时拉去当助手：

```text
外科操作不熟
解剖知识有基础
药物知识极强
会吐槽“我只是药剂师”
```

如果将来她出现在其他非标准岗位，也应继续保持这个角色逻辑。

---

# 58. 最终补充原则

手术系统未来应同时满足四种乐趣：

```text
1. 技术决策
2. 风险取舍
3. 团队角色互动
4. 特殊事件 / CG 收集
```

不要让“提高游戏性”只等于：

```text
更多数值
更多失败概率
更难的手术
```

同样重要的是：

> **让玩家因为“想和这个角色再上一台手术，看看她还会说什么、还会发生什么”，而主动继续玩手术系统。**

这应当被视为与策略深度同级的重要设计目标。
