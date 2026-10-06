# Hoshimi Hospital — 手术技术成长、术式解锁与训练系统设计 V0.1

> **状态：设计汇总稿 / 可进入后续实现讨论**
>
> **用途：** 汇总目前关于 `Surgery` 数值、手术经验成长、术式限制与解锁、助手邀约、Staff-as-Patient 训练等讨论中，已经明确认为应该进入游戏设计的要点。
>
> 本稿重点记录“原则与系统关系”，具体 XP 数值、公式、阈值、UI 文案可在实现阶段继续平衡。
>
> 当前术式数量约 25 种；未来计划扩展到约 45–50 种。

---

# 0. 核心设计一句话

> **关系决定谁愿意给你练。**
>
> **病例与临床经历决定你会练什么。**
>
> **Surgery Level 决定你练得怎么样。**

并进一步：

> **普通患者：病例决定你今天能做什么。**
>
> **Staff-as-Patient：你决定今天想练什么，但只能练你已经真正接触并解锁的术式。**

---

# 1. `Surgery` 数值的意义

## 1.1 Surgery 是 0–100 的“手术技术等级”

`Surgery = 100` 不是累计 100 点经验。

它表示：

> **玩家当前整体外科技术水平。**

建议参考标尺继续沿用：

```text
50  = 合格年轻医生
65  = 可独立承担常规任务
75  = 成熟骨干
85  = 专科强手
90+ = 医院顶尖
100 = 极高水平 / 游戏内近乎顶点
```

因此：

> **90 → 100 不应只是最后 10% 的成长。**

90 以后每一点都应该越来越困难。

---

## 1.2 Surgery Level 背后应有隐藏累计 XP

玩家界面主要看到：

```text
Surgery Lv. 73
```

后台则保存：

```text
surgery_xp
```

达到阈值后：

```text
73 → 74
```

所以：

```text
99 → 100
```

需要大量经验。

不建议：

```text
每级固定 100 XP
```

而应采用明显非线性的经验曲线。

---

## 1.3 后期经验曲线必须非常陡

推荐原则：

```text
0–50
普通手术就能持续成长

50–70
常规中型手术仍有较好收益

70–85
越来越需要大型手术 / 较复杂病例

85–90
普通大型手术仍能涨，但速度明显下降

90–95
主要依靠高难术式、复杂病例、特殊训练

95–99
需要真正高难、罕见、复杂的机会

99 → 100
需要极大量经验
```

重点不是具体倍率，而是：

> **Surgery 90 已经是顶尖医生。**
>
> **90 以后不应该靠普通病例慢慢磨到 100。**

---

# 2. 手术经验成长与术式限制

## 2.1 简单术式必须存在“训练上限”

不能出现：

> **割一千个阑尾 → Surgery 100。**

每个术式应该有一个：

```text
training_ceiling
```

或类似概念。

例如：

```text
阑尾切除
低等级时有明显收益
达到一定 Surgery 后收益逐渐降低
再往上 Global Surgery XP = 0
```

但即使 Global Surgery XP 已经为 0，仍然可以获得：

```text
procedure familiarity
team bond
operation_count
relationship / familiarity
角色对白
病例记录
```

即：

> **“这台手术仍然有内容价值，但已经不能把你训练成更强的外科医生。”**

---

## 2.2 手术难度应同时看“术式本身”与“病例实际复杂度”

同一个术式可以因患者不同而难度完全不同。

例如：

```text
普通胆囊切除
```

和：

```text
严重粘连
解剖变异
高血管性
组织脆弱
既往多次手术
```

不应提供相同学习价值。

建议：

```text
effective_difficulty
=
procedure_base_difficulty
+ case_modifier_bonus
+ complication_bonus
```

这样：

> **同一个低中级术式，在极复杂病例上仍可能对高等级玩家有学习价值。**

---

## 2.3 低等级做高难术式：不建议硬锁 Surgery 等级

当前建议：

> **锁知识，不锁胆量。**

即：

```text
procedure_unlocked == false
→ 不能做

procedure_unlocked == true
→ 即使 Surgery 很低，也允许尝试
```

不建议普遍设计：

```text
minimum_surgery_required = 85
Surgery 84
→ 按钮完全不可点
```

更适合：

```text
推荐 Surgery：85
当前 Surgery：58
严重超出当前能力
```

玩家仍可选择：

```text
[仍然主刀]
[换资深医生主刀]
[取消]
```

---

## 2.4 低等级越级手术不应成为 Power Leveling

如果：

```text
Surgery 40
```

直接挑战：

```text
Difficulty 95
```

不应因为“越级越多”而获得巨量经验。

更合理的是：

> **稍微高于自己能力的挑战最有学习价值。**
>
> **远远超过能力以后，反而无法有效吸收经验。**

推荐使用“倒 U 型”学习效率：

```text
难度远低于当前水平
→ XP 很低 / 0

略低于当前水平
→ 有收益

接近当前水平
→ 正常高收益

稍高于当前水平
→ 最高学习效率

远高于当前水平
→ XP 效率重新下降
```

具体区间以后平衡。

---

## 2.5 越级手术的惩罚主要来自“手术本身更难”

不建议只做：

```text
成功率 17%
→ RNG
```

更适合让低 Surgery 直接影响手术状态：

```text
风险判断更差
术野更难维持
出血更容易累积
Correction 成本更高
更容易触发并发症
更需要助手介入
```

即：

> **玩家应该在 Gameplay 中感受到“为什么现在还不会做”。**

---

# 3. 无视患者疾患、乱选术式的经验与后果

## 3.1 普通患者上做明显无关术式，只获得 20% XP

已确定原则：

```text
wrong_indication_xp_multiplier = 0.20
```

例：

> 患者心脏健康，玩家却强行拿她练 CABG。

玩家仍可能练到：

```text
切开
暴露
缝合
器械操作
团队流程
```

所以不是 0 XP。

但学不到真正的：

```text
病理解剖识别
病变处理
异常血管判断
真实病变操作
```

因此：

> **20% 是合理的低收益。**

---

## 3.2 乱开刀必须伴随职业与患者后果

除了低 XP，还应发生：

```text
Patient Fear ↑↑
Patient Trust ↓
Professional Reputation ↓
Staff Trust ↓
Scandal Risk ↑
```

如果玩家术前发现选错并主动纠正：

```text
Fear 小幅上升
时间损失
职业惩罚很小或没有
```

因为：

> **系统不应惩罚玩家“发现错误并纠正”。**

真正重罚的是：

> **明知不匹配仍然继续。**

---

## 3.3 经验惩罚可以和越级惩罚相乘

例如：

```text
Surgery 40
给健康患者做 Difficulty 95 的 CABG
```

可能：

```text
基础 XP
× 0.20（无适应证）
× 0.20（严重超出能力）
```

最终只剩：

```text
4%
```

即：

> 又不道德，又危险，而且还不是高效刷经验方式。

---

# 4. 术式解锁系统

## 4.1 未来约 50 种术式时，主角初始会 8–10 种最合理

当前建议：

```text
初始解锁：8–10 种
推荐基准：9 种
```

原因：

- 坂口不是 RPG Lv1 新手；
- 他已经是完成正规训练并有海外经历的医生；
- 开局应该具备正常工作能力；
- 但仍要给一年中的职业成长保留大量内容。

---

## 4.2 初始术式组成建议

可以包括：

```text
4–5 个常见基础外科术式
2–3 个中等复杂度术式
1 个体现海外研修背景的稍高阶术式
可选 1 个跨领域基础术式
```

目的：

> **开局就让玩家感觉“我是医生”，而不是“我只会割阑尾”。**

---

## 4.3 未解锁术式应该在 UI 中可见，但灰掉

这是当前新增并推荐锁定的 UI 原则。

例如术式列表：

```text
✓ Appendectomy
✓ Cholecystectomy
✓ Hernia Repair

🔒 CABG
🔒 Complex Thoracic Surgery
🔒 Major Vascular Reconstruction
🔒 Radical Pelvic Surgery
...
```

灰色术式：

```text
显示名称
显示类别
不可点击
```

目的：

> **让玩家一开始就知道：“原来这个游戏以后可以开这么多种刀，只是我现在还不会。”**

这会增强：

```text
术式收集欲
职业成长感
对罕见病例的期待
```

---

## 4.4 不需要额外 `OBSERVED` 状态

目前只保留：

```text
LOCKED
UNLOCKED
```

原因：

- 当前还没有完整的“玩家担任助手”深度系统；
- 再做一个 OBSERVED 会增加复杂度；
- 真实临床参与本身就可以同时承担：
  - 第一次接触；
  - 术式解锁；
  - First Exposure XP。

以后如果助手系统扩展，再根据需要细化。

---

# 5. 怎样解锁新术式

## 5.1 核心原则：必须经过真实临床接触

术式不能因为：

```text
读论文
看教材
听 Lecture
```

就直接变成：

```text
procedure_unlocked = true
```

必须有：

> **真实临床参与。**

---

## 5.2 典型解锁方式

### A. 游戏开始自带

坂口过去已经实际学过：

```text
→ UNLOCKED
```

---

### B. 真实病例中首次参与

例如：

```text
第一次遇到复杂心脏病例
↓
御堂主刀
坂口参与
↓
完成手术
↓
CABG UNLOCKED
```

同时获得：

```text
First Exposure Surgery XP
procedure familiarity 初始值
```

---

### C. 资深医生 / 同事邀请坂口当助手

例如：

> 「明天有台你没做过的。」
>
> 「跟我来。」

完成整日手术后：

```text
procedure_unlocked = true
First Exposure XP +
team bond +
relationship / familiarity +
```

这应该成为未来主要的新术式获取渠道之一。

---

### D. 特殊教学 / 角色事件

只要本质仍然是：

> **坂口真正参加了一台手术**

也可以：

```text
→ 解锁术式
```

---

## 5.3 阅读论文不能直接解锁术式

必须明确禁止这一漏洞：

```text
坐办公室读论文
↓
解锁 CABG
↓
第一次实际碰心脏
↓
直接拿 Lv5 小夜香练
```

虽然很好笑，但不适合作为正式成长路径。

因此：

```text
study_medical_material
→ can_unlock_procedure = false
```

阅读仍可以提供：

```text
Research XP
Diagnosis XP
理论知识
风险识别 bonus
病例预判
未来 First Exposure 的学习 bonus（可选）
```

但：

> **不能替代真正上台。**

---

# 6. 助手系统（当前留位置，后续正式设计）

> 当前只锁核心方向，不在 V0.1 设计完整 Assistant Gameplay。

---

## 6.1 助手事件的基本定位

玩家不是主刀，因此：

```text
选择较少
基本不容易因为玩家一个选择导致整台手术失败
风险明显低于主刀
```

但代价：

```text
占用整整一天
```

所以关键决策是：

> **今天值不值得为了这台手术投入一天？**

---

## 6.2 助手手术仍然吃 Surgery XP 限制

即：

```text
简单术式
玩家已经远超 training ceiling
→ Surgery XP = 0
```

不会因为“今天是助手”就绕过经验衰减。

---

## 6.3 新术式助手邀约

这是最有价值的一类。

例如：

> 御堂：
> 「下午有一台，你跟我来。」
>
> 术式：
> 大开腹探查【未解锁】
>
> [参加]
> [拒绝]

如果参加：

```text
整天消耗
↓
少量助手选择
↓
完成
↓
术式解锁
+ First Exposure Surgery XP
+ Team Bond
```

---

## 6.4 已知术式助手邀约

也可以很常见。

例如：

> 小夜香：
> 「明天有台阑尾，来帮我？」

如果：

```text
坂口 Surgery 88
阑尾 training ceiling 已远低于 88
```

那么：

```text
Surgery XP = 0
```

但仍然可以：

```text
Familiarity Sayaka +9
Team Bond +
operation_count_together +1
角色对白 / callback
```

即：

> **有些工作日不是为了效率，而是为了和某个同事一起工作。**

---

## 6.5 助手邀约本身可以成为关系培养方式

已经确定：

```text
共同手术
→ Familiarity +
```

因此：

> 小夜香邀请坂口去割一台对他毫无技术价值的阑尾，
> 仍然可能是非常有价值的关系事件。

这比：

```text
送礼物 +10 好感
```

更符合 Hoshimi 的医院生活感。

---

## 6.6 邀请者本人必须对该术式达到一定熟练度

不能出现：

```text
邀请者自己完全不会
↓
却作为主刀邀请坂口给她当助手
```

推荐：

```text
inviter procedure familiarity
>= independent_primary_threshold
```

才可以生成正常“我主刀，你来当助手”的邀约。

---

## 6.7 邀约概率应是条件加权，不是完全随机

未来可考虑：

```text
基础邀约概率
+ Team Bond
+ Professional Reputation
+ Relationship 小幅修正
+ 玩家尚未解锁该术式的 bonus
+ 特定角色专科权重
```

重要：

> **不应该把职业邀约完全绑死在恋爱关系上。**

---

## 6.8 助手事件失败应非常少

因为玩家不是主刀。

即使出现：

```text
判断错误
提醒晚了
操作不理想
```

更合理的结果是：

```text
主刀纠正
时间增加
小范围损失
关系 /评价变化
```

而不是轻易整台失败。

---

# 7. Staff-as-Patient / 同事手术练习系统

## 7.1 Staff-as-Patient 的核心系统价值

Lv5 解锁的不是：

> **“她的一台专属手术。”**

而是：

> **“她本人作为特殊训练患者开放给你。”**

核心价值：

> **你不需要等待对应疾病患者刷新，就可以主动练习已经解锁的高难术式。**

---

## 7.2 不按角色锁术式

当前推荐：

```text
character_specific_procedure_whitelist = false
```

即：

> **任何解锁 Staff-as-Patient 的同事，都可以用于任何玩家已经解锁的术式。**

角色的专业方向只影响：

```text
对白
术后复盘
Signature Bonus
角色特色
```

不限制：

```text
“她只能做妇科”
“她只能做腹部”
```

---

## 7.3 Staff-as-Patient 不能替玩家解锁术式

例如：

```text
小夜香 Lv5
CABG LOCKED
```

那么：

> **不能拿小夜香做 CABG。**

必须先：

```text
真实心脏病例
↓
坂口实际参加
↓
CABG UNLOCKED
```

以后：

```text
Staff-as-Patient → CABG
```

才出现。

因此：

> **小夜香是万能练习对象，不是万能术式解锁器。**

---

## 7.4 Staff-as-Patient 可以直接选择最难的“已解锁”术式

一旦：

```text
procedure_unlocked = true
```

那么即使它是：

```text
Difficulty 95
```

只要：

```text
Staff-as-Patient 已解锁
手术室 / 团队 / 设备条件满足
```

就可以主动选择。

这正是 Staff Training 对后期成长的重要价值。

---

# 8. Staff-as-Patient 的经验递减规则

## 8.1 同一角色 × 同一术式

已明确：

```text
第一次：100% XP
第二次：50% XP
第三次以后：0% Global Surgery XP
```

推荐键：

```text
character_id + procedure_id
```

例：

```text
sayaka + CABG
1st = 100%
2nd = 50%
3rd+ = 0
```

但：

```text
sayaka + Gastrectomy
```

仍然可以从第一次 100% 开始。

---

## 8.2 第三次以后仍然有内容价值

即使：

```text
Global Surgery XP = 0
```

仍然可以继续：

```text
procedure familiarity
patient history
relationship callback
Fear / Pain / Dignity 变化
CG
特殊对白
Team Bond
Staff-as-Patient history
```

因此：

> **系统只是阻止无限刷 Surgery，不是阻止玩家继续玩角色内容。**

---

## 8.3 不需要额外“全 roster 同术式总次数”限制

目前不建议设计：

> “同一个术式只能从前两名女职工获得经验。”

原因：

1. 单周目本来就很难把大量角色刷到 Lv5；
2. 关系升级有 Familiarity 门槛；
3. 数值不能跨 Relationship Level 溢出；
4. 每个角色同术式本身已经有：
   ```text
   100% → 50% → 0%
   ```
5. `99 → 100` 本身需要巨量 XP。

因此：

> **不用额外惩罚玩家把多个角色都培养到 Lv5。**

如果玩家真的做到了，那本身就是这一周目的巨大投入。

---

# 9. Staff-as-Patient 与真实病例的区别

## 9.1 Staff Training 的优势

```text
可主动选择
不需要等疾病刷新
可以直接选最难的已解锁术式
适合填补 90+ 后期经验来源不足
```

---

## 9.2 Staff Training 不应吃真实罕见病理 Modifier

例如：

```text
CABG 标准难度 92
```

Staff Training：

```text
按标准 Difficulty 92 计算
```

真实患者可能：

```text
重度粘连
异常血管
组织脆弱
既往多次手术
```

导致：

```text
effective difficulty > 92
```

这种额外病理复杂度：

> **只由真实疑难病例提供。**

因此：

```text
Staff-as-Patient
= 可控的高难训练

Rare Clinical Case
= 不可控但最高价值的真实挑战
```

两者不会互相替代。

---

# 10. 每个医护的 Signature Training Procedure

## 10.1 不限制术式，但提供一个角色专属经验奖励

每个可进入 Staff-as-Patient 的医护可以拥有：

```text
Signature Training Procedure
```

不是：

> “她只能做这台。”

而是：

> **“第一次拿她练这一台，会特别有价值。”**

---

## 10.2 推荐做成一次性额外 Bonus

例如：

```text
第一次同角色 + Signature Procedure
→ 正常第一次训练 XP
+ Signature Bonus
```

第二次：

```text
50% 正常重复训练
无 Signature Bonus
```

第三次：

```text
0 Global Surgery XP
```

---

## 10.3 Signature Bonus 的叙事解释

不要解释成：

> “她的身体比较适合这台。”

更适合：

```text
她本人专业背景与术式相关
术前能提供特殊医学讨论
术后能进行更高质量复盘
她对此类手术特别熟悉
```

例如：

```text
Aqua
→ 妇科高难术式

御堂
→ 顶级大型外科

小夜香
→ 泛用但很实用的高难术式
```

---

# 11. 后期职业成长循环

整个系统最终应该形成：

```text
早期
普通病例
↓
快速提升 Surgery
↓
中期
大型术式 + 新术式解锁
↓
80–90
普通病例收益越来越小
↓
90+
开始真正期待 Rare Case
↓
两条主要高价值来源：

A. 真实疑难病例
B. Lv5 Staff-as-Patient 主动训练
```

其中：

```text
Rare Case
= 随机出现
= 最高病理复杂度
= 高 Reputation
= 高 Surgery XP

Staff Training
= 关系经营后主动获得
= 可自由选择已解锁术式
= 标准高难训练
= 无罕见病理 bonus
```

---

# 12. 玩家行为路线应该自然分化

## 正常职业路线

```text
按适应证手术
接真实疑难病例
接受资深医生助手邀约
解锁新术式
培养 Staff-as-Patient
```

---

## 黑色沙箱路线

```text
在普通患者身上故意选错术式
```

系统允许，但：

```text
XP × 0.20
Fear ↑
Reputation ↓
Staff Trust ↓
Scandal Risk ↑
```

即：

> **不是硬禁止，而是世界会记住玩家这么做。**

---

# 13. 推荐的数据结构方向

以下只表示概念，不代表最终代码。

```yaml
player:
  surgery_level: 73
  surgery_xp: 4820

procedures:
  cabg:
    unlocked: false
    base_difficulty: 92
    recommended_surgery: 88
    training_ceiling: 99

  appendectomy:
    unlocked: true
    base_difficulty: 35
    recommended_surgery: 30
    training_ceiling: 65
```

Staff Training：

```yaml
staff_training_history:
  sayaka:
    cabg:
      completions: 1
    gastrectomy:
      completions: 2
```

经验倍率：

```text
Staff same character + same procedure:
1st = 1.00
2nd = 0.50
3rd+ = 0.00

Wrong indication:
× 0.20
```

---

# 14. UI 建议

## 14.1 术式列表始终展示完整术式库

例如：

```text
[可用] 阑尾切除
[可用] 胆囊切除
[可用] 胃切除

[灰色] 冠状动脉搭桥
[灰色] 复杂主动脉手术
[灰色] 大型盆腔肿瘤切除
```

灰色状态：

```text
当前未解锁
```

可显示简短提示：

> **需要通过实际临床参与学习该术式。**

---

## 14.2 Staff-as-Patient 菜单只开放已解锁术式

未解锁术式仍然灰色。

可以额外标：

```text
★ Signature Training Bonus Available
```

或：

```text
First Training XP Available
Second Training: 50%
Training XP Exhausted
```

这样玩家能清楚理解：

> 自由选择 ≠ 无限刷经验。

---

# 15. 当前明确不做 / 暂缓的内容

## 暂不做完整 `OBSERVED` 状态

当前保持：

```text
LOCKED / UNLOCKED
```

足够。

---

## 暂不做完整 Assistant Gameplay

目前先保留：

```text
少量选择
低失败率
整天时间成本
术式解锁
经验
关系成长
```

以后再单独设计：

```text
Assistant 操作
助手判断
主刀指令
主动提醒
接管机制
角色间专业默契
```

---

## 不允许阅读直接解锁术式

这是明确原则。

---

## 不按 Staff 角色锁术式

Lv5 Staff-as-Patient 的价值就是：

> **任何已解锁术式都可以拿她练。**

---

# 16. 最终设计原则汇总

可以把整套系统压缩成以下十条：

```text
1. Surgery 是 0–100 的等级，不是累计经验。
2. 90 以后成长极慢，99→100 需要巨量 XP。
3. 简单术式达到一定等级后不再提供 Global Surgery XP。
4. 高难真实病例是后期最优经验来源。
5. 未解锁术式在菜单中可见但灰色不可点。
6. 新术式必须通过真实临床参与解锁，阅读不能直接解锁。
7. 已解锁术式不设普遍硬 Surgery 等级门槛，可以越级尝试，但风险高、学习效率可能反而下降。
8. 普通患者上做明显无关术式只获得 20% XP，并降低声望、增加患者恐惧。
9. 助手邀约占整天、风险低，可用于解锁新术式、获得经验和培养关系。
10. Lv5 Staff-as-Patient 可以练任何“已解锁”术式；同角色同术式 XP 为 100% → 50% → 0%，另可有一次性 Signature Bonus。
```

---

# 17. 设计目标

这套系统最终应该让玩家产生以下感觉：

> **“我不是靠刷一个按钮把 Surgery 练到 100。”**

而是：

> **“这一年里，我真的遇到过这些患者、跟这些医生上过这些刀、学会了这些术式、在稀有病例上成长，也因为和某些同事建立了极高信任，获得了别人没有的训练机会。”**

这才是 Hoshimi Hospital 的职业成长感。

