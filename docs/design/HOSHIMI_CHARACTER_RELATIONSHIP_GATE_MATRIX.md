# Hoshimi Hospital — Character Relationship Gate Matrix

> **文件性质：Canonical Character Progression Matrix**
>
> 稳定文件名：
>
> `HOSHIMI_CHARACTER_RELATIONSHIP_GATE_MATRIX.md`
>
> 用途：
>
> - 集中维护全部 named characters 的相识与 Lv1–Lv5 关系门槛；
> - 避免为每个角色单独建立 Gate MD；
> - 与 `HOSHIMI_FAMILIARITY_AND_RELATIONSHIP_PROGRESSION_RULES.md`
>   和 `HOSHIMI_PROGRESSION_BENCHMARK_AND_CHARACTER_GATE_GUIDE.md` 配套使用。
>
> 规则：
>
> - 本文件只记录 gate、affinity、冷却与路线定位；
> - 具体事件内容仍放 Character Bible / Event Design；
> - 未讨论角色暂不擅自补条件；
> - 系统 baseline 稳定后，优先调整角色自身 gate，而不是反复修改五维或 Familiarity 系统；
- 本矩阵是关系 Gate、Affinity 与冷却的当前权威来源；现有代码、旧事件摘要或其他旧文档与本矩阵冲突时，以本矩阵为准。

---

# 0. Global Baseline

Familiarity：

```text
0–100
持续累计
不受 Relationship Level 封顶
```

共同经历基础收益：

```text
Routine Surgery      +5
Advanced / Major    +10
Extreme / Master    +15
Sunday Date         +10
```

关系事件：

```text
所有 Relationship milestone 固定最短冷却 = 3天
Month gate 默认不用
只有明确叙事理由才使用
```

Relationship milestone：

```text
Familiarity
+ 前置 Relationship Level
+ 角色专属条件
+ 必要时五维 gate
+ event cooldown
```

完成专属 milestone event 后升级。

---

# 1. 深山佳織 / Miyama Kaori

```yaml
actor_id: doc_rei
route_type: early_easy_romance
month_gate: none
default_minimum_event_interval_days: 3
```

## Route Identity

```text
初期核心角色
攻略不困难
主要靠 Familiarity
事件偏幽默 / 荒诞医疗黑色喜剧
后段才出现轻度择偶标准与职业托付要求
```

## Soft Affinity

Surgery 高：

```text
→ Familiarity gain 略快
```

已锁定：

```text
Surgery <60     ×1.00
60–69           ×1.05
70–79           ×1.10
80–89           ×1.15
90+             ×1.20
```

这是 soft affinity，不是早期 hard gate。

## Gate Matrix

| 阶段 | Familiarity | 其他 Gate | 冷却 | Month Gate |
|---|---:|---|---:|---|
| Intro | 0 | Day1 / very early | — | 无 |
| Lv1 | 10 | `met_asuka == true` | ≥3天 | 无 |
| Lv2 | 25 | Lv1 complete | ≥3天 | 无 |
| Lv3 | 40 | Lv2 complete | ≥3天 | 无 |
| Lv4 | 55 | Charm ≥ 得体；Asuka ≥ Lv1 | ≥3天 | 无 |
| Lv5 | 75 | Surgery ≥75；Asuka ≥ Lv2 | ≥3天 | 无 |

## Gate Meaning

### Lv1
先熟悉“正常工作的深山”，再进入《叮。》一类荒诞事件。

额外要求：

```text
met_asuka == true
```

含义：

> 坂口必须已经正式认识城宮明日香。

不要求明日香 Relationship Lv1；这里只保证深山的重要旧友已经进入玩家的医院人际网络。

### Lv2–Lv3
主要靠实际相处和共同工作，不堆职业 hard gate。

### Lv4
从专业信任跨入私人 / 恋爱关系：

```text
Charm >= 得体
Asuka >= Lv1
```

深山条件很好，因此有轻度择偶标准，但不是颜控。

### Lv5
最终医疗托付：

```text
Surgery >=75
Asuka >= Lv2
```

语义：

> “我是名医的女儿，我把身体交给你开刀，你好歹不能稀松吧。”

---

# 2. 御堂江美子 / Mido Emiko

```yaml
actor_id: doc_emiko
route_type: elite_surgeon_slow_burn
month_gate: none
base_familiarity_gain_multiplier: 0.50
```

## Route Identity

核心关键词：

```text
技术至上
冷淡
骄傲
严格
手术狂热
独狼实力派
对能力极敏感
Control / Surrender of Control
```

她不是 Leadership 派代表。

```text
御堂
= Surgery / Presence / 独狼实力

Artoria / Saber
= Leadership / Team Command
```

## Relationship Arc

```text
Lv0
“让我看看你值不值得记住。”

Lv1
“你能不能跟上我？”
御堂主刀，坂口第一助手。

Lv2
“这一次听你的。”
坂口主刀，御堂第一助手。

Lv3
专业兴趣开始转化为私人兴趣。
开始认可坂口具有与她相近的临床权威感。

Lv4
发现御堂手术后会进入极度兴奋状态，
并在无人手术室中进行私密释放。
双方关系真正跨过成人私人边界。

Lv5
Lv4 后续
+
主任之争
+
控制关系彻底反转。

她最终在身心和职业上都承认坂口，
并暗示如果坂口竞争外科主任，她会主动退出竞争。
```

## Base Familiarity

锁定：

```text
familiarity_gain_multiplier = 0.50
```

意义：

> 御堂天然非常难混熟。

不要为了补偿这个低倍率而降低她的 Familiarity threshold。

## Soft Affinity — Surgery

高 Surgery：

```text
→ 她认为坂口的技术值得欣赏
→ Familiarity gain 加速
```

已锁定Surgery bonus：

```text
Surgery <60     +0.00
60–69           +0.10
70–79           +0.20
80–89           +0.30
90+             +0.40
```

## Soft Affinity — Clinical Presence

偏强势 / 有临床控制感：

```text
→ 她觉得气场合胃口
→ Familiarity gain 加速
```

但她喜欢的是：

```text
决断
控制感
术中权威
```

不是单纯粗鲁或让患者害怕。

已锁定Clinical Presence bonus：

```text
Presence <= 0       +0.00
Presence +1～+19    +0.10
Presence +20～+29   +0.15
Presence +30～+59   +0.20
Presence >= +60     +0.30
```

## Affinity Multiplier Rule

不要直接把多个倍率乘到失控。

推荐：

```text
effective_familiarity_multiplier
=
clamp(
  0.50
  + surgery_affinity_bonus
  + presence_affinity_bonus,
  0.50,
  1.20
)
```

目标：

```text
普通玩家
≈ 0.50 附近

技术强 / 气场合
→ 逐渐接近 1.0

极度符合她胃口
→ 最多 1.20
```

## Gate Matrix

| 阶段 | Familiarity | 其他 Gate | 冷却 | Month Gate |
|---|---:|---|---:|---|
| Intro | 0 | 相识事件《传闻中的手》 | — | 无 |
| Lv1 | 10 | Surgery ≥75 | ≥3天 | 无 |
| Lv2 | 25 | Lv1 complete | ≥3天 | 无 |
| Lv3 | 40 | Clinical Presence ≥ +20 | ≥3天 | 无 |
| Lv4 | 55 | Clinical Presence ≥ +30 | ≥3天 | 无 |
| Lv5 | 75 | Surgery ≥90 | ≥3天 | 无 |

Intro→Lv1同样使用固定3天最短冷却；指定手术测试只决定事件内容与其他前置，不改变关系冷却。

## Lv1 — Professional Recognition

```text
Familiarity >=10
Surgery >=75
```

主题：

```text
御堂主刀
坂口第一助手
```

含义：

> 她确认坂口有资格让自己认真看。

`Surgery 75` 足够，不提高到80。

Lv1不是 Advanced 资格认证。

## Lv2 — Position Reversal

```text
Familiarity >=25
Lv1 complete
>=3 days
```

主题：

```text
坂口主刀
御堂第一助手
```

不重复再收一次 Surgery hard gate。

含义：

> 她愿意暂时放下主导权，并接受坂口的手术节奏。

## Lv3 — Clinical Authority Affinity

```text
Familiarity >=40
Clinical Presence >= +20
```

粗略事件方向：

```text
一名情绪激动、哭闹的患者无法安静。

患者：
“怎么可能安静下来，我可能会死啊。”

御堂冷冷回答：

“今天我主刀。”
“你绝对不会死。”
```

Lv3 让玩家真正看到：

> 御堂本人的强 Clinical Presence 是什么样。

这里要求明确具备临床控制感，但还不要求达到Lv4的强势标准。

## Lv4 — Postoperative Secret

```text
Familiarity >=55
Clinical Presence >= +30
```

主题：

```text
御堂手术后会进入异常强烈的身体兴奋状态
+
坂口发现她在无人手术室中的极私密秘密
+
成人关系成立
```

Lv4 不再加 Surgery hard gate。

核心是：

```text
Familiarity
+
Presence / control affinity
+
私人边界跨越
```

## Lv5 — Total Surrender / Chief Competition Resolution

```text
Familiarity >=75
Surgery >=90
```

主题：

```text
Lv4秘密后续
+
主任之争
+
身心彻底倒向坂口
+
控制关系最终反转
```

Surgery 90 的意义：

> 御堂认为坂口已经有资格胜任外科主任位置。

不要求 Leadership。

原因：

```text
御堂是独狼实力派。
她对主任资格的判断核心是：
“你够不够强。”

Leadership 派由 Saber / Artoria 代表。
```

## Chief Ending Flag

Lv5 完成后应设置真实系统状态，例如：

```text
emiko_withdraws_from_chief_competition = true
```

这是主任结局的重要钥匙之一。

当前主任结局核心条件方向：

```text
1. 摆平御堂
2. 摆平 Saber / Artoria
3. 治好佐伯
```

三者分别证明：

```text
御堂
→ 顶级个人外科实力竞争解决

Saber
→ 团队领导 / 组织统筹竞争解决

佐伯
→ 关键临床成绩完成
```

因此御堂 Lv5 不是单纯恋爱 completion。

它同时影响：

```text
Chief / 外科主任 Ending
```

---

# 3. Artoria / Saber

```yaml
actor_id: doc_artoria
route_type: leadership_rival_slow_burn
month_gate: none
base_familiarity_gain_multiplier: 0.75
primary_affinity: Leadership
```

## Route Identity

核心定位：

```text
优秀的领导者
责任感强
重视团队整体表现
不是孤狼，但也不是轻易和人混熟的人
外科主任竞争中的 Leadership / Team Command 代表
```

与御堂形成明确对照：

```text
御堂江美子
= Surgery / Presence / 独狼实力

Artoria / Saber
= Leadership / Team Command / 团队统率
```

她不要求坂口在每一个维度都超过自己。

她最终认可的是：

> 坂口本人已经具有相当高水平的外科技能，同时又拥有足以统领整个团队的 Leadership。

---

## Base Familiarity / Leadership Affinity

基础熟悉度倍率：

```text
0.75
```

含义：

> Saber 有距离感、正式、谨慎，不像普通社交型角色那么容易熟悉；但也不像御堂那样刻意保持孤狼式距离。

她的 Familiarity soft affinity **只看 Leadership**。

不要再叠加：

```text
Surgery affinity
Clinical Presence affinity
Charm affinity
```

当前有效倍率表：

```text
Leadership <60     ×0.75
Leadership 60–69   ×0.80
Leadership 70–79   ×0.90
Leadership 80–89   ×1.00
Leadership 90+     ×1.10
```

设计语义：

```text
普通医生
→ Saber 礼貌但保持距离

真正会带团队的人
→ 她更快把坂口视为值得认真相处、值得信任的同行领导者
```

---

## Introduction / Lv1

现有工程人物链保留：

```text
met_asuka == true
+
met_emiko == true
↓
asuka_mentions_artoria_rival
↓
intro_doc_artoria_deputy_office
↓
artoria_lv1_right_position
```

Lv1 与正式登场链一起完成。

因此：

```text
Lv1 不额外要求 Familiarity
Lv1 不额外要求 Leadership
```

功能：

```text
正式揭晓外科主任竞争格局
+
Artoria 进入玩家的人际网络 / 手术团队体系
```

不要为了防极端非标准玩法再添加独立 hard fallback；只要明日香核心登场 fallback 与普通御堂入口稳定即可。

---

## Gate Matrix

| 阶段 | Familiarity | 其他 Gate | 冷却 | Month Gate |
|---|---:|---|---:|---|
| Intro / Lv1 | — | `met_asuka && met_emiko`；完成明日香介绍链 | — | 无 |
| Lv2 | 25 | Leadership ≥70 | ≥3天 | 无 |
| Lv3 | 40 | Leadership ≥80 | ≥3天 | 无 |
| Lv4 | 55 | Leadership ≥85 | ≥3天 | 无 |
| Lv5 | 75 | Leadership ≥90；Surgery ≥80 | ≥3天 | 无 |

---

## Event Authoring Rule

当前**只锁数值和关系门槛，不锁 Lv2–Lv5 具体事件内容**。

```text
Lv2–Lv5 event content = TBD
```

原因：

```text
Saber 是 fan-service 加入角色
用户本人对 Fate 原作人物细节不熟
不需要为了填满路线而强行发明复杂私人创伤 / Fate lore
```

后续事件只需围绕以下稳定主题即可：

```text
Leadership
责任感
团队组织
主任竞争
对坂口综合能力的认可
```

如果以后想到合适事件再补；在此之前，Leadership gate 本身已经足够定义她的成长路线。

---

## Lv5 / Chief Competition Resolution

Lv5：

```text
Familiarity >=75
Leadership >=90
Surgery >=80
```

这里不要要求 Surgery 90。

含义：

```text
Leadership 90
→ Saber 认可坂口已经是真正的高级领导者

Surgery 80
→ 坂口本人也是足够高水平的外科医生，而不是只会管理的行政型领导
```

与御堂形成镜像：

```text
御堂 Lv5
Surgery >=90
→ 顶级个人术者认证

Saber Lv5
Leadership >=90
Surgery >=80
→ 顶级团队领导资格认证
```

完成后建议设置：

```text
artoria_supports_sakaguchi_for_chief = true
```

她不是单纯“认输 / 退出”。

更准确的意义是：

> 她认为坂口比自己更适合承担外科主任这个综合职位，因此愿意支持他。

---

# 4. Saeki Decisive Case / Chief Route Cross-Integration

> 本节是跨人物路线规则。用于保存佐伯决胜手术、御堂 / Saber 两位主任竞争者，以及外科主任结局之间的已锁定关系。

## 4.1 Core Theme — 双90不是全面超过两名女王

主任路线不要写成：

```text
坂口最后在每一个维度都全面超过御堂和 Saber
```

正确理解：

```text
御堂
→ 在纯 Surgery 专项上仍可能略强于坂口

Saber
→ 在纯 Leadership 专项上仍可能略强于坂口

坂口
→ Surgery 与 Leadership 同时达到 90 级别
→ 两个维度都进入顶尖区间
→ 没有明显短板
→ 综合上最适合作为佐伯主刀与外科主任
```

核心主题：

> **最好的主任，不一定是医院里每一项能力最强的人，而是能让最强的人愿意站在自己两边的人。**

因此双90的意义是：

```text
Surgery 90
+ Leadership 90
= 顶级综合外科领导者
```

而不是：

```text
Surgery 第一名
+ Leadership 第一名
```

---

## 4.2 Saeki Decisive Surgery — Sakaguchi Primary Route

坂口获得佐伯决胜手术主刀资格的当前锁定条件：

```text
Surgery >=90
Leadership >=90
Mido Relationship >=3
Artoria Relationship >=3
```

固定核心阵容：

```text
Primary Surgeon
坂口

First Assistant
御堂江美子

Second Assistant / Global Coordination
Artoria / Saber
```

两名“女王”必须同时进入助手阵容。

这台手术证明的不是坂口单项碾压她们，而是：

```text
他拥有足够高的个人技术
+
足够高的团队统率能力
+
能够同时调用两位顶尖竞争者的专长
```

因此两人都认可：

> 对佐伯而言，坂口是最合适的主刀。

---

## 4.3 If Sakaguchi Is Not Qualified — Patient Still Survives

锁定原则：

> **佐伯不会因为玩家没有刷够数值而死亡。**

失败产生职业 / 关系后果，而不是患者死亡 Game Over。

### 未取得坂口主刀资格

只要坂口没有同时满足Surgery≥90、Leadership≥90及御堂／Artoria关系条件，他就不自动取得主刀资格。Surgery不足时甚至可能完全不被邀请参与手术。

具体分支中的主刀、Case Lead、助手、旁观或未获邀请安排，全部留给佐伯专项事件设计；御堂接任或Artoria接任仅可作为候选，不在本矩阵提前锁定，也不由通用系统自动选择。

无论具体缺少哪一项，以下原则锁定：

```text
佐伯仍然存活并得到适当治疗
坂口不是最终 Primary Surgeon
saeki_saved_by_sakaguchi = false
```

未完成全部分支剧本前，不把佐伯危重病例加入可触发日程，避免生成已经需要救治却没有对应演出的患者。

---

## 4.4 Consequence of Not Being Primary Surgeon

如果最终不是坂口亲自主刀：

```text
saeki_saved_by_sakaguchi = false
```

则：

```text
佐伯仍获救
但不完成 Surgical Chief Ending 的佐伯临床钥匙
佐伯 Relationship 路线停在 Lv3
佐伯 Lv4 不解锁
佐伯 Lv5 不解锁
```

含义：

> “救下佐伯”与“由坂口亲自救下佐伯”是两个不同层级的结果。

只有后者构成坂口自己的代表性职业成绩。

---

## 4.5 Consequence of Sakaguchi Primary Success

如果坂口满足双90与关系 / 阵容条件，并亲自主刀成功：

```text
saeki_saved_by_sakaguchi = true
saeki_lv4_unlocked = true
chief_saeki_requirement_complete = true
```

这代表：

```text
御堂
→ 认可坂口具有足够高的个人技术

Saber
→ 认可坂口具有足够高的团队统率能力

佐伯
→ 成为坂口最重要的临床代表作之一
```

---

## 4.6 Saeki Lv3 — Desire to Live

佐伯 Lv3 的人物主题已经锁定，但具体逐句脚本以后再写。

内容核心：

```text
身患严重疾病的佐伯
回忆自己生病以前的恋爱与正常成年性生活
```

她说出类似：

> 「好想再做一次。」

这**不是 H Event**。

它的意义不是临终色情愿望，而是：

> **性欲 / 恋爱欲重新成为她“还想活下去、还想重新拥有普通人生”的生命力表达。**

正确主题：

```text
我还想恋爱
我还想被人拥抱
我还想拥有健康成年人的身体和欲望
我不想永远只作为“病人”活着
所以我不想死
```

---

## 4.7 Saeki Lv4 — Recovery / Fulfillment

仅在：

```text
saeki_saved_by_sakaguchi == true
```

后开放。

佐伯从大手术中真正康复以后，主动回收 Lv3 的愿望。

她主动与坂口发生成年亲密关系 / H，可以半开玩笑地视为：

```text
“还愿”
```

但叙事禁止写成：

```text
医生救了女人
→ 女人用 Sex 报恩
```

正确意义：

> **她终于重新拥有了 Lv3 时害怕永远失去的普通成年人生，而她主动选择和亲手救回自己的坂口一起确认这件事。**

---

## 4.8 Saeki Lv5 — From Life-Saving Patient to Healthy Voluntary Training Patient

Lv5 的最终反转：

```text
过去：
佐伯躺上手术台
= 因为严重疾病
= 必须接受手术才能活下来

现在：
她已经真正恢复健康
= 健康到甚至可以主动把自己交给坂口作为特殊手术训练对象
```

核心表达：

> **“我曾经是必须让你们开刀救回来的人；现在，我已经健康到可以让你拿我做手术练习了。”**

这是佐伯路线最终的生命力证明。

系统命名是否直接归入 `Staff-as-Patient`：

```text
TBD
```

因为佐伯本质上是康复后的原患者，不一定属于医院 staff。

但 Gameplay payoff 可以与主动特殊训练患者机制对接。

---

## 4.9 Surgical Chief Ending — Three Independent Keys

主任结局继续保持三把独立钥匙：

```text
1. 御堂路线解决
   → 顶级个人外科实力竞争解决

2. Saber 路线解决
   → 团队领导 / 组织统筹竞争解决

3. 坂口亲自主刀治好佐伯
   → 关键临床成绩完成
```

最终职业能力同时要求方向：

```text
Surgery >=90
Leadership >=90
```

因此：

```text
御堂 Lv5
+
Saber Lv5
+
saeki_saved_by_sakaguchi == true
+
Surgery >=90
+
Leadership >=90
→ Surgical Chief Ending eligibility
```

不要把佐伯的成功并入 Saber Lv5 或御堂 Lv5；三把钥匙保持独立。

---


# 5. 石神千鹤 / Ishigami Chizuru

```yaml
actor_id: nurse_ishigami
route_type: professional_institutional_trust
romanceable: false
month_gate: none
primary_route_logic:
  - nursing_staff_professional_trust
  - Surgery
  - Leadership
```

## Route Identity

石神的 Relationship Lv0–Lv5 **不是恋爱等级**。

它表示：

```text
石神作为全院护理负责人
对坂口作为医生 / 团队领导 / 医院核心成员的职业认可
```

她不会因为：

```text
Charm
约会
H
私人暧昧
```

而升级。

前三阶最重要的不是坂口与石神本人“混熟了多少”，而是：

> **石神观察到越来越多护理人员已经在专业上真正信任坂口。**

因此当前版本不额外叠加 Familiarity hard gate；Familiarity 可以正常累计，但不作为本路线主要收费项。

---

## Nurse Trust Count Rule

前三阶统一使用：

```text
count_other_nurses_with_relationship_level_at_least_2
```

计数规则：

```text
只计其他护士；不计石神本人
Relationship >= Lv2 均计入，不要求恰好 Lv2
同一角色只计一次
只计可正常推进到 Lv2 的常驻护理角色
隐藏 / guest / progression-locked 角色若不能达到 Lv2，不纳入有效池
未来新增护士自动可以贡献计数
不要硬编码固定 actor_id 名单
不要改成“护士总数百分比”
```

固定绝对人数的意义是：

```text
3人
→ 小范围专业认可

5人
→ 护理团队内部已经形成明显口碑

8人
→ 跨多个护理角色的广泛职业信任
```

未来增加更多护士后，`8` 不代表全收集；它只是一个稳定的“广泛护理认可”阈值。

---

## Gate Matrix

| 阶段 | Familiarity | 其他 Gate | 冷却 | Month Gate |
|---|---:|---|---:|---|
| Intro / Lv0 | — | 第一周 guaranteed introduction | — | 无 |
| Lv1 | — | 其他护士中 ≥3 人 Relationship ≥Lv2 | ≥3天 | 无 |
| Lv2 | — | 其他护士中 ≥5 人 Relationship ≥Lv2 | ≥3天 | 无 |
| Lv3 | — | 其他护士中 ≥8 人 Relationship ≥Lv2 | ≥3天 | 无 |
| Lv4 | — | Surgery ≥80；Leadership ≥80 | ≥3天 | 无 |
| Lv5 | — | Surgery ≥85；Leadership ≥85 | ≥3天 | 无 |

---

## Gate Meaning

### Lv1 — Early Nursing-Side Recognition

```text
3名护士 Lv2+
```

含义：

> 已经不是某一名护士与坂口个人相处得好；护理侧开始有几个人愿意在专业上替他说话。

### Lv2 — Stable Nursing Reputation

```text
5名护士 Lv2+
```

含义：

> 坂口已经在护理团队中形成稳定的“可靠医生”口碑。

### Lv3 — Broad Nursing Trust

```text
8名护士 Lv2+
```

含义：

> 这不再是若干个人关系，而是护理部门层面的广泛专业认可。

注意：

```text
普通可攻略角色 Lv2
≈ 相当稳定的专业信赖
```

因此石神使用“护士 Lv2 数量”作为 gate，考察的是：

> **护理团队愿不愿意和坂口工作。**

不是：

> “有多少护士喜欢坂口 / 和坂口进入暧昧。”

### Lv4 — Institutional Clinical Trust

```text
Surgery >=80
Leadership >=80
```

石神认可：

> 坂口既有足够高的临床能力，也有能力带领复杂团队，因此她可以放心为其高级病例承担大量护理资源。

这对应 Character Bible 的：

```text
《你可以继续开》
```

### Lv5 — Hospital Core Recognition

```text
Surgery >=85
Leadership >=85
```

含义：

> 石神不再把坂口视为“一年期合同里的优秀外科医生”，而是 Hoshimi 的核心医生之一。

这是未来高难：

```text
Vice Director / 副院长
Director / 院长
hospital leadership ending
```

等医院管理结局的重要前置之一。

石神 Lv5 本身不自动给予管理结局；它代表：

> **护理系统 / institutional nursing trust 已经通过。**

不要再额外叠加 Reputation hard gate 作为石神 Lv5 本身的条件；未来副院长 / 院长结局可以在 ending 层面另外检查 Reputation、明日香、医院级剧情 flags 等。

---

## Persona 2 Fortune-Teller Callback

具体写作规则放在：

```text
HOSHIMI_ISHIGAMI_CHIZURU_CHARACTER_BIBLE.md
```

Gate 层只记录：

```text
Lv3+
→ 可以低频出现“前世是很厉害的占卜师”式 dry-humor / mysterious callback
```

它是角色 fan-service 与高关系反差，不产生真实超自然 Gameplay 修正。

---
---

# 6. 城宮明日香 / Shiromiya Asuka

```yaml
actor_id: doc_asuka
route_type:
  - core_npc
  - young_director
  - romance
  - surgery_room_nerd
  - charm_progression
month_gate: none
default_minimum_event_interval_days: 3
base_familiarity_gain_multiplier: 1.00
primary_affinity: Charm
```

## Route Identity

明日香的公共面已经承担大量医院级职责，因此个人 Relationship Route 不再写成另一条职业考核线。

```text
公共面
→ 年轻院长 / 成熟可靠 / 医院级领导

私人面
→ 少女审美
→ OR culture / 手术室氛围爱好
→ 手术服、帽子、口罩、材质、历史款式收藏与审美
```

与御堂区分：

```text
御堂
→ 喜欢手术本身：技术 / 难度 / 控制

明日香
→ 喜欢手术室文化本身：空间 / 仪式 / 装备 / 服装 / 团队生态 / 审美
```

角色自身 Surgery 能力锚点：

```text
Asuka Surgery ≈55–60
```

她的理论、观察、第一助手经验与医院管理明显强于独立主刀能力。不要为了让她作为助手“看起来厉害”而把 Surgery 硬抬到75–85；未来如 Assistant role resolver 与她产生冲突，应在岗位技能 / teamwork / role modifier 层解决。

## Relationship Arc

```text
Lv1
医院设备 / 装修 / OR 更新
→ 轻微露出她对制服与手术室审美的关注

Lv2
无菌手术袍采购 / 试穿
→ 明确发现她真的研究版型、材料、配色
→ seed：未来手术袍展示 / 选美活动

Lv3
私人历史手术服收藏
→ 70年代风格奶白色长袖手术袍
→ “我问你好不好看”
→ 第一次明确以女人而非院长身份在意坂口的目光

Lv4
Charm 高门槛
→ 男女关系 / 成人亲密成立

Lv5
Surgical play
→ 真正愿意以 voluntary patient / training patient 身份把自己交给坂口
```

## Gate Matrix

| 阶段 | Familiarity | 其他 Gate | 冷却 | Month Gate |
|---|---:|---|---:|---|
| Intro | — | 正常刷手池相识；若长期错过则核心 NPC fallback | — | 无 |
| Lv1 | 10 | Charm ≥10 | ≥3天 | 无 |
| Lv2 | 25 | Charm ≥25 | ≥3天 | 无 |
| Lv3 | 40 | Charm ≥50 | ≥3天 | 无 |
| Lv4 | 55 | Charm ≥100 | ≥3天* | 无 |
| Lv5 | 75 | Surgery ≥70；Lv4 complete | ≥3天* | 无 |

\* Lv4 / Lv5 同样使用固定3天最短冷却；不加 Month Gate。

## Gate Meaning

```text
Lv1 Charm10
→ 至少不是完全无审美 / 无回应

Lv2 Charm25
→ 能真正参与她的审美交流

Lv3 Charm50
→ 她开始明显在意“你觉得我漂亮吗”

Lv4 Charm100
→ 明日香确实把明显的个人吸引力作为恋爱标准

Lv5 Surgery70
→ Lv4 已证明吸引力；Lv5 新增的是“你是否已经是我愿意真正托付身体的可靠外科医生”
```

Lv5 不继续提高 Charm。`Surgery 70` 故意低于更重职业评价的角色；明日香不是在挑医院最强术者。

## Management Ending Separation

```text
Asuka Lv5 != Vice Director / Director Ending
```

真正医院管理结局以后在 Ending 层另外检查：

```text
Asuka Lv5
+
Ishigami Lv5
+
high Leadership
+
high Professional Reputation
+
broad Staff Support
+
hospital-level flags
```

不要把这些管理考核重新塞回明日香个人路线。

---

# 7. 南条小夜香 / Nanjou Sayaka

```yaml
actor_id: doc_sayaka
route_type:
  - early_romance
  - adult_low_drama
  - tutorial_anchor
  - strategic_softness
month_gate: none
default_minimum_event_interval_days: 3
base_familiarity_gain_multiplier: 1.80
```

## Route Identity

小夜香应当是全游戏最容易自然升到高关系、最容易触发 H 与教学手术的一批角色之一。

她不是免费赠送；她容易攻略是因为：

```text
从早期就对坂口有明显男女兴趣
不故意制造情感障碍
主动给坂口继续追求的许可
不要求坂口为了她变成名医 / 高领导 / 万人迷
成人亲密后不自动制造狗血
```

真正不推进她路线的主要原因应当是：

> 玩家主动不理她。

## Familiarity Affinity

锁定：

```text
base_familiarity_gain_multiplier = 1.80
```

在系统基础收益下，大致：

```text
Routine Surgery +5 ×1.8 ≈ +9
Sunday Date +10 ×1.8 ≈ +18
```

不要额外用高数值墙抵消她的高熟悉度倍率。

## Relationship Arc

```text
Lv1
第一次真正约会 / mutual attraction
→ 自动推进

Lv2
私人相处加深
→ “你继续约我，我会高兴”

Lv3
《一直在看》前置
→ 《那我们现在算什么？》
→ 正式男女朋友 / kiss

Lv4
《那就别回去了》
→ Hotel / H

Lv5
《今晚这里没人吧？》
→ OR patient roleplay
→ 《那你给我开一次》
→ Staff-as-Patient
→ Public Teaching Surgery 早期入口
```

## Gate Matrix

| 阶段 | Familiarity | 其他 Gate | 冷却 | Month Gate |
|---|---:|---|---:|---|
| Intro | — | Day1 guaranteed introduction | — | 无 |
| Lv1 | — | 首次约会 / `mutual_attraction` 成立后自动推进 | — | 无 |
| Lv2 | 25 | Lv1 complete | ≥3天 | 无 |
| Lv3 | 40 | Charm ≥10 | ≥3天 | 无 |
| Lv4 | 55 | Charm ≥20 | ≥3天 | 无 |
| Lv5 | 70 | Charm ≥30；Surgery ≥60 | ≥3天 | 无 |

## Gate Meaning

```text
Lv1
→ 不设数值墙

Lv2 Fam25
→ 以 ×1.8 增长速度，正常不回避她约2–4周自然可达

Lv3 Charm10
→ 只要求不是完全木头

Lv4 Charm20
→ 进入 Hotel / H，仍是非常轻的吸引力要求

Lv5 Charm30 + Surgery60
→ 得体范围即可；Surgery 仅确认“可靠普通外科医生”
```

Charm 不得提高到“出众 / 迷人”才能解锁教学手术。普通小事件、患者 Charm reaction、Sunday Date 与剧情 choice 本来就会自然贡献 Charm。

## Tutorial Anchor

小夜香系统上应自然成为以下项目的“最早之一”：

```text
first Sunday Date
first official romance
first Hotel / H
first Lv5
first Staff-as-Patient
first Public Teaching Surgery
```

可低调记录：

```text
first_date_character
first_h_character
first_lv5_character
first_staff_patient_character
```

但 UI 不标记她为官方主女主或推荐攻略对象。

---

# 8. 折川皐月 / Orikawa Satsuki

```yaml
actor_id: nurse_satsuki
route_type:
  - slow_burn
  - clinical_trust_before_romance
  - presence_affinity
  - nursing_growth
month_gate: none
default_minimum_event_interval_days: 3
base_familiarity_gain_multiplier: 0.75
primary_affinity: Clinical Presence toward warm / approachable side
```

## Route Identity

皐月的核心不是：

> “坂口治好了她的恐男症。”

而是：

> **她仍然会紧张，但不再因为紧张，就认定自己什么都做不好，也不再让恐惧替自己决定职业和私人关系。**

路线顺序：

```text
职业安全感
→ 能在坂口身边正常工作
→ 犯严重错误后仍不逃
→ 患者身份下建立深层信任
→ 恋爱 / 成人亲密
→ 主动患者托付
```

她最重要的择人标准不是 Charm、名望或顶级 Surgery，而是：

> 这个男人在我紧张的时候，会让我更安全，还是让我更害怕？

因此 Clinical Presence 是本路线绝对主轴。

## Familiarity / Presence Affinity

基础熟悉度倍率：

```text
0.75
```

Clinical Presence 向温和 / 可亲方向移动时 Familiarity 提速。锁定最终有效倍率：

```text
Presence >= +60      ×0.50
Presence +30～+59    ×0.60
Presence -29～+29    ×0.75
Presence -30～-59    ×0.90
Presence -60～-119   ×1.05
Presence -120～-169  ×1.20
Presence <= -170     ×1.30
```

上表已经是最终 multiplier，不再额外乘一次 `0.75`。

设计语义：

```text
明显强势型坂口
→ 仍可因共同工作而熟悉，但很慢

平衡型坂口
→ 默认0.75

持续温和 / 可亲
→ 熟悉度逐渐明显提速
```

不要设置“Presence 不合就完全不加 Familiarity”。

## Relationship Arc

```text
Lv0《新来的护士》
→ 仰慕弘子 / 恐男反差 / 原想做外科护士却躲去妇科

Lv1《真人测试》
→ Aqua patient-experience
→ 坂口认真听她的护理判断

Lv2《陪我去一次》
→ 承认真正想做围术期护理
→ Saber 陪她去见石神，但不替她求情
→ 石神批准基础轮转
→ 成功 patient transport / handoff
→ “我可以在坂口先生身边正常工作”

Lv3《我送错了人》
→ 多节点错误最终造成错误患者手术
→ 不甩锅、不逃回妇科
→ 患者身份重新体验流程
→ 摘眼镜 / 深度近视 / 主动让坂口靠近

Lv4《这次是我自己摘的》
→ 主动摘眼镜
→ 主动决定哪个男人可以靠近
→ Adult Intimacy

Lv5《这次是我自己躺上去》
→ 没有事故、没有赎罪
→ 主动 Staff-as-Patient / training patient
→ “我不需要成为第二个弘子，我可以成为很好的折川护士”
```

## Lv2 Canonical Event Source — 已核对完整脚本

2026-10-04同步：Lv2《陪我去一次》已有正式完整脚本，不再是TBD。稳定文件指针：

`HOSHIMI_ORIKAWA_SATSUKI_LV2_PATIENT_TRANSPORT_EVENT.md`

事件文件身份：`libfile_da91ef2237cc8191be7bbb992f2a4737`。

权威范围：本矩阵负责关系数值、前置等级及冷却；该事件文件负责Lv2完整对白、场景、演出、CG与事件状态。`HOSHIMI_ORIKAWA_SATSUKI_CHARACTER_BIBLE.md`负责人物总设定。本次读取到的同名Bible仍保留旧版“Lv2 — TBD”，该旧占位不得覆盖已核对的完整事件。截图所示新版Bible尚未在本次读取结果中取得，不宣称其已同步。后续实装必须读取完整事件文件，不能仅凭本摘要重写；若文件条件出现冲突，明确报告并核对，不静默覆盖。

### 事件摘要与人物重点

皐月自己提出围术期轮转申请，Saber陪同见石神但不代她求情。石神批准Holding、患者转运和术前交接的基础轮转，暂不安排器械岗位。数日后，她先顺利完成数次普通转运，再遇到一名在OR门口因恐惧用双脚撑住门框的成年女患者。

皐月起初误以为床卡住，发现原因后停止推车，走到患者看得见的位置，解释接下来半分钟的流程并承诺交接前一直在场。患者自己先放下一只脚，另一只仍当“保险”；等待三秒后解除抵抗，顺利进入OR，皐月完整交接给弘子。

坂口事后肯定她能理解“脑子知道应该继续，身体却动不了”的感觉。皐月确认自己虽然仍紧张，却已经能够在坂口身边正常工作。弘子尾声强调：她在患者真正害怕时没有笑，等患者缓过来后，大家才自然分享这个荒唐插曲。

该事件的暂停与体贴是皐月的具体护理选择；不能因医院总体强势的世界观而改写成强推，也不把她的做法扩展成所有角色必须遵守的统一口吻。

### 触发与结算接口

已核对事件推荐条件与本矩阵一致：Lv1、Fam≥25、Clinical Presence≤0、距Lv1完成≥3天、事件未完成。推荐event_id：`satsuki_lv2_patient_transport`。

完整事件含弘子尾声结束后升Lv2，并记录：

```text
satsuki_or_rotation_unlocked = true
satsuki_successful_patient_transport = true
satsuki_lv2_patient_transport_complete = true
```

优先映射项目已有事件完成与升级接口，不另建重复状态系统。申请、获批、轮转中的场景推进不提前结算Lv2；跨日叙事的调度与读档需保留事件进度，不重复奖励。未规定新增Saber或弘子关系等级门槛，不因配角出场自行加锁。

完成后首次允许Sunday Date，接受率仍低于50%，拒绝不扣关系。场景为剧情转运与交接，不以此自动授予器械岗位资格。

### Lv2 → Lv3连续性

Lv2已经证明她认真核对身份、理解患者恐惧、能完成转运及交接。Lv3的错误患者事故必须来自可解释的多节点错误假设链，不能写成“这个笨护士又犯错”。完整摘镜反差和近视关键情节仍留给Lv3。

患者未撤回既有手术同意，不能改成取消手术。Saber不替她求情，坂口与弘子不接管她的核心安抚；保留她自己完成工作的成果。CG、逐句对白和具体动作以事件文件为准，不在本矩阵重复全文。

## Gate Matrix

| 阶段 | Familiarity | 其他 Gate | 冷却 | Month Gate |
|---|---:|---|---:|---|
| Intro / Lv0 | — | 护士站正式相识 | — | 无 |
| Lv1 | 10 | Clinical Presence ≤ +30 | ≥3天 | 无 |
| Lv2 | 25 | Clinical Presence ≤ 0 | ≥3天 | 无 |
| Lv3 | 40 | Clinical Presence ≤ -30；Surgery ≥55 | ≥3天 | 无 |
| Lv4 | 55 | Clinical Presence ≤ -60 | ≥3天 | 无 |
| Lv5 | 70 | Clinical Presence ≤ -90；Surgery ≥60 | ≥3天 | 无 |

## Gate Meaning

### Lv1

```text
Fam10
Presence <= +30
```

不是要求坂口已经温和，只要求他还没有形成明显让皐月产生压迫感的临床人格。

### Lv2

```text
Fam25
Presence <=0
```

她准备主动走出妇科安全区时，需要确认：

> “我在这个男人身边工作，不会一直处于戒备状态。”

### Lv3

```text
Fam40
Presence <= -30
Surgery >=55
```

`Surgery55` 只是非常低的患者安全 / 医疗信任门槛。真正关键是 Presence，因为核心场景“坂口先生……你好温柔，可是我看不清”必须与玩家实际塑造的人格相符。

### Lv4

```text
Fam55
Presence <= -60
```

`-60` 正式进入“温和”档位。

Lv4 不要求 Charm / Surgery / Reputation / Leadership。成人关系成立的真正条件是：

> 她已经把坂口认知成一个让自己感觉安全、而且自己愿意允许靠近的男人。

### Lv5

```text
Fam70
Presence <= -90
Surgery >=60
```

`Surgery60` 仍然只是可靠普通外科医生的医疗托付底线。

不要把 Presence 提高到 `<= -170`；那已经属于极端“可亲”人格区，会把普通角色攻略强行变成终局 Presence 专精。

皐月需要的是长期温和可靠，不是极端人格。

## Soft Route Lock / Multi-Playthrough Meaning

皐月路线不使用显式互斥 flag。

不写：

```text
完成御堂路线
→ 皐月永久锁死
```

现有 Presence 变化速度已经足够承担软路线锁：

```text
从中间走到明显一端
→ 通常需要数月

从明显强势端反转到明显温和端
→ 需要接近半年级别的刻意极限玩法
```

因此正常一周目自然形成：

```text
御堂
→ 偏强势 Presence 更顺

皐月
→ 偏温和 Presence 更顺
```

理论上极限玩家仍然可以尝试跨两端，不需要额外禁止。

## Sunday Date Availability

保留当前规则：

```yaml
lv0:
  invite_allowed: false
  accept_chance: 0.0

lv1:
  invite_allowed: false
  accept_chance: 0.0

lv2:
  invite_allowed: true
  accept_chance: low_under_50_percent

lv3_plus:
  invite_allowed: true
  accept_chance: normal_character_rate
```

Lv2 的低接受率不是欲擒故纵；它表示她已经能与坂口正常工作，但“休息日只有两个人见面”仍让她紧张。拒绝不扣 Relationship / Familiarity。

---


# 9. 杉村弘子 / Sugimura Hiroko

```yaml
actor_id: nurse_hiroko
route_type:
  - senior_or_nurse
  - slow_burn_after_initial_trust
  - boundary_trust
  - original_series_core_heroine
month_gate: none
default_minimum_event_interval_days: 3
primary_route_logic:
  - staged_familiarity_slowdown
  - mild_warm_presence_gate_at_lv3
  - boundary_trust_event_at_lv4
  - surgery_trust_at_lv5
```

## Route Identity

弘子保留《淫内感染》系列人物内核：

```text
外柔内刚
资深临床护士
患者照护极强
新人带教能力极强
总是在照顾别人
很少允许别人照顾自己
```

她的私人路线需要保留一点忧伤感。

Hoshimi AU 当前方向：

> 她曾经真心深爱过一个人，但那段关系同时包含极度粗暴的对待、占有与边界侵犯。
>
> 她现在不是怕男人，也不是无法恋爱，而是对“爱一个人以后，会不会再次失去自己的边界”有很强戒心。

路线的补完主题不是“坂口治愈她”，而是：

> **她终于可以深爱一个人，而不必同时忍受这个人。**

她的“外柔内刚”必须同时成立：

```text
外在
→ 温和、成熟、会照顾人、容易正常相处

内在
→ 边界非常硬
→ 不接受以“爱你 / 为你好”为理由替她做决定
→ 不允许别人否定她过去真实存在过的感情
```

---

## Existing Lv1 Anchor

现有 Lv1《别让她看见》→《值得的事情》继续保留。

它负责建立：

```text
Professional Respect
Trust
Mentor Identity
```

而不是直接恋爱。

Lv1 已经埋下长期主题：

> 「但是你也得有人照顾。」

此时弘子还会温和地把这句话挡回去。

---

## Staged Familiarity Curve — LOCKED

弘子的 Familiarity 不是固定倍率，而是随 Relationship Level 改变。

```text
Lv0 → Lv1    ×1.00
Lv1 → Lv2    ×0.80
Lv2 → Lv3    ×0.65
Lv3 → Lv4    ×0.50
Lv4 → Lv5    ×1.25
```

设计语义：

```text
Lv0 → Lv1
正常认识、正常合作
→ 弘子本来就是温和好相处的人

Lv1 → Lv2
她开始意识到坂口不只是普通同事
→ 轻微踩刹车

Lv2 → Lv3
私人好感越来越明显
→ 戒备进一步上升

Lv3 → Lv4
已经真正动心
→ 过去的感情经验让她最难继续往前
→ 全路线最低倍率 ×0.50

Lv4 → Lv5
确认坂口尊重她的边界以后
→ 防御明显解除
→ Familiarity 反而提升到 ×1.25
```

这条曲线的重点是：

> **弘子不是越陌生越难熟，而是越接近真正亲密越会后退；一旦跨过真正的信任门槛，她会明显放松。**

---

## Gate Matrix

| 阶段 | Familiarity | 其他 Gate | 当前阶段 Familiarity 倍率 | 冷却 | Month Gate |
|---|---:|---|---:|---:|---|
| Intro / Lv0 | — | 已有相识事件 | ×1.00 | — | 无 |
| Lv1 | 10 | 萌惠也已正式相识、Lv0、Fam≥10；完成《别让她看见》→《值得的事情》共同事件链 | ×1.00 | ≥3天* | 无 |
| Lv2 | 25 | Lv1 complete | ×0.80 | ≥3天 | 无 |
| Lv3 | 40 | Clinical Presence ≤ -30 | ×0.65 | ≥3天 | 无 |
| Lv4 | 55 | `hiroko_boundary_trust_established == true`；具体事件 TBD | ×0.50 | ≥3天 | 无 |
| Lv5 | 75 | Surgery ≥70；Lv4 complete | ×1.25 | ≥3天 | 无 |

\* 现有 Lv1 本身是两段事件链，实际实现可继续遵守其现有次日 Event B 结构，不必强行为两段之间加入3天。

2026-10-04 联动修订：双人熟悉度与 Lv0 条件仅在事件链启动时检查一次。《别让她看见》增加萌惠单独收尾，完成后萌惠升 Lv1；次日《值得的事情》完成后弘子升 Lv1，不再检查萌惠是否仍为 Lv0 或重复检查两人熟悉度。原事件的场景、时间及手术经历条件继续保留。

弘子完成正式相识事件后即具备邀请入队资格，不需要 Lv1；仍遵守通用排班和岗位可用性。这是待工程修复的早期设计错误，独立 Bug Report 已附在 `HOSHIMI_TONEGAWA_ANGE_RELATIONSHIP_IMPLEMENTATION_V1.md`，仅随该文提交，与安琪路线无关。本文件记录目标行为，不代表代码已经修复。

---

## Gate Meaning

### Lv1–Lv2 — Easy to Know, Harder to Get Close

弘子初期并不难接近。

她：

```text
能自然和男性医生工作
能聊天
会笑
会照顾同事
不会像皐月那样因为男性靠近而明显紧张
```

所以 Lv0→Lv1 使用正常 `×1.00`。

真正的减速从她意识到关系开始具有私人意味以后才发生。

### Lv3 — Mild Warm Presence Requirement

```text
Familiarity >=40
Clinical Presence <= -30
```

这里要求的是**一定程度的温和 / 给人选择空间**，而不是极端可亲 Build。

弘子需要看到：

```text
坂口会听人把话说完
不靠压迫逼人立刻回答
不会把“为你好”当作替别人做决定的万能理由
```

但 Lv4 / Lv5 不继续简单地把 Presence 要求一路推到 `-60 / -90`。

原因：

> 弘子的核心伤口不是“强势男人让我害怕”这么简单，而是“亲密关系中的控制与边界被侵入”。

这和皐月路线必须保持区别。

### Lv4 — Boundary Trust Is the Real Wall

```text
Familiarity >=55
hiroko_boundary_trust_established == true
```

Lv4 当前**不锁新的五维数值**。

具体事件尚未完成，但必须验证：

```text
坂口不会逼她解释过去
不会替她否定曾经真实爱过的人
不会说“以后你都听我的 / 交给我”
不会因为成为恋人就认为自己拥有她的决定权
会允许她自己决定什么时候靠近、什么时候停
```

完成后设置：

```text
hiroko_boundary_trust_established = true
```

这才是她全路线最难跨过的一关。

Lv4 后 Familiarity 从 `×0.50` 直接变为 `×1.25`，作为她心理防御真正解除的 Gameplay 反馈。

### Lv5 — Professional Patient Trust

```text
Familiarity >=75
Surgery >=70
Lv4 complete
```

`Surgery 70` 已锁定。

意义：

> 弘子自己就是资深 OR nurse。她长期看过大量医生主刀，因此即使私人感情已经完全成立，“真的让我躺上去给你开”仍然会经过她自己的专业判断。

这不是技术崇拜，也不是要求顶级术者。

而是：

> **“我爱你是一回事；我愿不愿意让你拿手术刀碰我，是另一回事。”**

`Surgery 70` 表示坂口已经达到她作为资深手术室护士愿意亲自选择的可靠成熟术者水平。

---

## Current Event Direction

当前只锁路线功能，不提前强行写死 Lv2–Lv5 全部剧本。

```text
Lv1
认识“所有人都依赖的杉村弘子”
→ 坂口第一次注意到：照顾所有人的她也会疲惫

Lv2
开始发现她对私人照顾会温和地后退
→ 感情警戒开始出现

Lv3
第一次触及过去感情 / 边界主题
→ 她允许坂口看到真正的私人情绪

Lv4
关键 Boundary Trust Event
→ 她确认“喜欢这个男人”不会再次等于“必须忍受这个男人”
→ Adult Relationship 可在此阶段成立

Lv5
最终 Patient / Being-Cared-For Payoff
→ 她真正允许自己成为被照顾的一方
→ 若使用 Staff-as-Patient / voluntary patient，则 Surgery70 生效
```

Lv4 / Lv5 具体事件以后从人物戏反推，不为了填满 Gate Matrix 强行发明。

---

## Long-Term Callback

Lv1：

> 「但是你也得有人照顾。」

弘子仍会挡回去。

最终路线可以回收为她主动说出类似：

> 「坂口先生。」
>
> 「今天……可以照顾我一下吗？」

这里的意义不是变得依赖，而是：

> **她终于不再把“需要别人”自动理解成危险。**

---


# 10. 水城Aqua / Mizushiro Aqua

```yaml
actor_id: doc_aqua
route_type:
  - gynecology_specialist
  - specialty_investment_route
  - medical_grotesque_comedy
  - patient_experience
  - romance
month_gate: none
default_minimum_event_interval_days: 3
primary_route_logic:
  - gynecology_case_count
  - gynecology_case_scaled_familiarity
  - progressive_surgery_skill
  - specialty_teaching
```

## Route Identity

Aqua 是妇科 / 女性生殖系统顶级专家，同时也是猎奇搞笑担当。她可以非常离谱，但不能失去专业可信度。

核心关系逻辑：

> **越做妇科，她越把坂口当“自己人”。**

她不主要吃 Charm、Presence、Leadership 或 Reputation，而主要吃：

```text
gynecology_case_count
+
Familiarity
+
后段 Surgery
```

---

## Gynecology Case Count — LOCKED

统一计数：

```text
gynecology_case_count
```

只统计明确涉及女性生殖系统的正式手术：

```text
子宫
卵巢
输卵管 / 附件
宫颈
阴道
以及其他明确属于女性生殖系统的手术
```

不计：

```text
阑尾
膀胱
普通结直肠
一般腹部手术
只是位于盆腔、但并非女性生殖系统的术式
```

计数：

```text
Primary 正式完成 → +1
Assistant 正式参加并完成 → +1
取消 / 未完成 → +0
```

助手事件预计低频，因此不做 0.5 credit。

---

## Familiarity Multiplier — LOCKED

```text
0–5 cases      ×0.50
6–9 cases      ×0.70
10–14 cases    ×0.90
15–19 cases    ×1.05
20–29 cases    ×1.20
30+ cases      ×1.35
```

语义：

```text
0–5
→ 她还没把你当真正的妇科同行

6–9
→ 你不是游客了

10–14
→ 可以认真谈高级妇科

15–19
→ 稳定同行 / 研究搭档

20–29
→ 明显属于“我们这边的人”

30+
→ 深度妇科专精，熟络明显加速
```

病例量同时承担两种作用：

```text
做妇科越多
→ Familiarity 涨得越快
+
每一级 Relationship 又有最低妇科病例数硬门槛
```

---

## Gate Matrix — LOCKED

| 阶段 | Familiarity | 妇科 Case | 其他 Gate | 冷却 | Month Gate |
|---|---:|---:|---|---:|---|
| Intro / Lv0 | — | ≥1 | 妇科检查室正式相识 | — | 无 |
| Lv1 | 10 | ≥5 | 完成早期妇科关系事件 / 加入手术团队 | ≥3天 | 无 |
| Lv2 | 25 | ≥10 | Surgery ≥60；完成子宫全切教学链 | ≥3天 | 无 |
| Lv3 | 40 | ≥15 | Lv2 complete | ≥3天 | 无 |
| Lv4 | 55 | ≥20 | Surgery ≥70 | ≥3天 | 无 |
| Lv5 | 75 | ≥30 | Surgery ≥80 | ≥3天 | 无 |

---

## Gate Meaning

### Intro

```text
gynecology_case_count >=1
```

完成至少一台女性生殖系统手术后正式认识 Aqua。现有“女性盆腔组手术 ≥1”方向保留，但实现时应改用更精确的 `gynecology_case_count`。

### Lv1

```text
Fam >=10
gynecology_case_count >=5
```

5 台以内 Familiarity 始终保持最低 `×0.50`。

意义：

> Aqua 开始确认坂口不是偶尔做一台妇科病例，而是真的愿意进入这个专业领域。

Lv1 后 Aqua 可加入手术团队。

### Lv2 — 子宫全切教学 / 深度职业信赖

```text
Fam >=25
gynecology_case_count >=10
Surgery >=60
```

Lv2 使用全局语义：

> **深度职业信赖 + 明显个人好感，但尚未进入恋爱暧昧。**

Lv2 同时承担 Aqua 第一次正式高级妇科教学：

```text
Aqua 问“你要不要学高级妇科术式？”
→ 玩家无论怎样回答，她都理解为“要”
→ 抓一名成年护士去妇科检查室做真人解剖 / 体位比划
→ 进一步提议直接抓护士去 OR 展示
→ 坂口叫停
→ seed：未来 Staff-as-Patient
→ 数日后真正出现开腹子宫全切患者
→ Aqua Primary / Sakaguchi Assistant
→ 完成后解锁 `surgery_hysterectomy`
→ Relationship Lv2
```

患者可以明显紧张 / 流泪；Aqua 对术式兴奋，但面对患者仍必须专业。

### Lv3 — 专业依赖转为暧昧

```text
Fam >=40
gynecology_case_count >=15
Lv2 complete
```

当前事件方向：

```text
Aqua 研究妇科术式陷入死胡同
→ 情绪崩溃
→ 抱住坂口的腿要求帮忙
→ 把坂口带去妇科检查室
→ Aqua 自己成为 patient-experience 对象
→ 坂口做阴道镜 / 实时影像观察
→ Aqua 一边看自己的生殖系统，一边和坂口讨论
→ 突然获得术式突破
→ 检查后暗示“什么时候再来一次吧”
→ 第一次明显男女暧昧
```

Lv3 不额外要求 Surgery hard gate。

### Lv4 — “深入妇科检查手术”

```text
Fam >=55
gynecology_case_count >=20
Surgery >=70
```

Lv4 是 Adult Intimacy / H milestone。

核心方向：

> Aqua 一本正经要求坂口给自己做一次“深入妇科检查手术”，然后把妇科语言、patient-experience 与成人亲密故意混在一起。

事后要求坂口写“手术报告”；过于敷衍会被退回重写。

`Surgery70` 不是说 H 本身需要手术技术，而是：

> Aqua 已经同时把坂口视为她认可的妇科同行和具有男女吸引力的对象。

### Lv5 — Voluntary Gynecology Patient / Negative Exploration

```text
Fam >=75
gynecology_case_count >=30
Surgery >=80
```

Lv5 Aqua 真正成为患者，让坂口给自己做妇科开腹手术。

当前锁定方向：

```text
表面：
疑似卵巢囊肿 / 附件异常

实际：
开腹后没有囊肿
→ negative exploration
→ 正常子宫与双侧附件
```

代表概念：

> 坂口：「没有囊肿。」
>
> Aqua：「我没说真的有啊？」

Aqua 要求记录正常术野影像：

```text
盆腔整体
子宫
左侧卵巢 + 输卵管 / 附件
右侧卵巢 + 输卵管 / 附件
```

术后：

> 「漂亮吧。」
>
> 坂口：「……很正常。」
>
> Aqua：「正常就是最漂亮的。」

这是 Staff-as-Patient / voluntary patient payoff，不是 Master Procedure unlock。

正式 procedure 名称后续实现时再定，当前方向：

```text
开腹附件探查
/
exploratory laparotomy with adnexal evaluation
```

不要登记成“卵巢囊肿切除”，因为最终没有病变可切。

---

## Two-Tier Aqua Teaching Structure

### Tier 1 — Early Advanced Teaching

```text
Relationship Lv2
Surgery >=60
gynecology_case_count >=10
↓
开腹子宫全切教学病例
↓
surgery_hysterectomy unlocked
```

### Tier 2 — Master Procedure

Aqua 的真正 Master Procedure：

```text
全盆腔脏器切除
```

它是妇科 / 女性盆腔肿瘤技术树顶点。

---

## Global Expert Master Procedure Rule — LOCKED

御堂、Artoria / Saber、Aqua 三名顶级专家统一采用：

```text
对应专家 Relationship >= Lv2
+
必要技术树前置术式完成
+
必要 Surgery 技巧门槛
+
专家教学事件
```

Relationship Lv2 表示：

> 专家已经与坂口建立足以传授压箱底术式的深度职业信赖。

它不是 Romance gate；Lv3 才进入明显暧昧。

Aqua 当前 Master Procedure 教学资格：

```text
Aqua Relationship >=2
Surgery >=80
必要妇科前置术式完成
↓
全盆腔脏器切除 Master Procedure Teaching
↓
procedure_unlocked = true
```

详细 prerequisite procedure list 以后在术式系统文档中锁定，不在 Character Gate Matrix 擅自补齐。

---

## Aqua Route Summary

```text
做妇科越多
→ Aqua 熟得越快
→ 同时满足逐级病例量门槛

Lv1
→ “你真的会来妇科”

Lv2
→ “你已经值得我认真教”
→ 子宫全切 unlock
→ Master Procedure 教学资格开始成立

Lv3
→ “我专业上真的会来找你帮忙”
→ 暧昧开始

Lv4
→ 专业怪癖与成人关系合流

Lv5
→ 顶级妇科专家本人主动成为坂口的患者
→ 正常女性生殖系统成为最终关系象征
```

---

# 11. 中井美佳 / Nakai Mika

```yaml
route_type:
  - friendly_capable_nurse
  - increasingly_difficult_private_closeness
  - intimacy_without_past_disclosure
month_gate: none
default_minimum_event_interval_days: 3
past_disclosure_unlockable: false
```

## Route Identity — LOCKED

作者侧背景：她过去曾犯下大案，如今隐姓埋名，在星见医院担任普通护士。游戏内不揭晓案件、旧身份或完整过去；此背景不是玩家可解锁的奖励。

她和善、友好、能干、合群，好相处却难以深交。她对同事和患者的善意是真的，对坂口的喜欢也是真的；不要反转成“一切都是伪装”。

路线主题：

> **她很喜欢你，与她让你知道过去，是两回事。**

五级事件使用轻量生活切片，有意无意显示她比表面厉害、知道得更多。每个细节都有经验丰富的护士能够成立的正常解释；不逐级升级为危险线索，不赋予攻击性或令人脊背发凉的气质，不安排警方、旧识或身份曝光的大反转。

Day1 已相识的常驻护士，可攻略时间很长。难点来自递减熟悉度与后段择偶、医疗托付要求；不增加月份锁。

## Staged Familiarity Curve — LOCKED

| 当前关系阶段 / 正在推进 | Familiarity gain multiplier |
|---|---:|
| Lv0 → Lv1 | ×1.00 |
| Lv1 → Lv2 | ×0.90 |
| Lv2 → Lv3 | ×0.75 |
| Lv3 → Lv4 | ×0.60 |
| Lv4 → Lv5 | ×0.60 |

按当前已完成 Relationship Level 应用倍率，不能提前使用目标等级完成后的倍率。

初期正常交往；私人关系越深入越慢。Lv4 后不出现弘子式加速反弹。Familiarity 仍可达到100，Relationship 仍可完成Lv5；不以数值封顶暗示“只是还没刷够”。

Lv5 后继续累计 Familiarity 的倍率尚未另行讨论，不能擅自增加完成奖励倍率。

## Gate Matrix

各级同时遵守前一级完成、完成对应 milestone event 的全局规则。

| 阶段 | Familiarity | 其他 Gate | 推进该级时 Familiarity 倍率 | 冷却 | Month Gate |
|---|---:|---|---:|---:|---|
| Intro / Lv0 | — | Day1 已有强制相识 | ×1.00 | — | 无 |
| Lv1 | 10 | 完成职业观察事件 | ×1.00 | ≥3天 | 无 |
| Lv2 | 25 | Lv1 complete | ×0.90 | ≥3天 | 无 |
| Lv3 | 40 | Charm ≥20 | ×0.75 | ≥3天 | 无 |
| Lv4 | 55 | Charm ≥30 | ×0.60 | ≥3天 | 无 |
| Lv5 | 75 | Surgery ≥70；Leadership ≥65；Lv4 complete | ×0.60 | ≥3天 | 无 |

Lv3 / Lv4 Charm 表示：她不是非要男人不可，要让她产生男女吸引力，坂口需要有一点外形吸引力与男人味。不把她做成高Charm专精路线。

Lv5 不继续加Charm，改为综合医疗托付判断：技术可靠、遇事稳定、能带团队并承担责任。她已经喜欢坂口，但愿意成为他的手术患者仍需要 Surgery70 + Leadership65。

不额外添加 Presence、Reputation 或“尊重秘密”选择flag；避免低倍率之外再叠加过重门槛。

## Current Event Direction — Approved Rough Draft

以下锁定事件功能与轻量人物表现，具体逐句脚本仍留待 Event Design。

### Lv1《交班的人》

通过患者说话、看门、家属在场时反应、水杯与拖鞋等细节，发现普通交班会忽略的问题；事后只解释“这种病人见多了”。表现她很会观察人。

轻微好感信号：坂口桌上多了他常喝的咖啡，她随口提起记得他昨晚喝的牌子。她既观察患者，也开始留意坂口。

### Lv2《以前见过》

顺口认出旧包装、旧规格耗材，知道封口改版等细节；问起来源，只说“见过”“以前工作的地方吧”，自然转回核对有效期。不凭这些知识判定她的旧身份。

轻微好感信号：下班主动问坂口“要不要一起？”；愿意多待一会儿，但路上仍不交代过去。

### Lv3《你怎么会知道？》

夜间转运遇维修封路，她熟悉替代动线、门锁时间、电梯与旧出口。回答“方向感好”“在医院工作很多年了”，都能正常成立。

轻微好感信号：坂口问她是否讨厌追问，她笑着表示并不讨厌他。对白应温和、自然地表达他比普通同事更受欢迎，不能写成威胁、操控或即将透露秘密的预告。

### Lv4《今天不要做病史采集》

成人亲密事件保留placeholder。起因只是她喜欢坂口、今晚想和他在一起，不是创伤突破、秘密交换或重大告白。

事后轻量回收主题：“我喜欢你。”“这两件事有关系吗？”或带笑说“今天不要做病史采集”。她不回答过去，但愿意留下。

不设置“继续追问 / 尊重她”式秘密宝箱测试，也没有正确选项可换取更多过去。

### Lv5《你来开吧》

主动成为 Staff-as-Patient / voluntary training patient，理解流程与风险；既喜欢坂口，也认可他的技术与团队领导能力。不是献祭、赎罪或洗白。

轻微好感信号：有人提议可换医生，她平常地说“坂口来就好”“我观察你很久了”。选择的是他本人。

术前仍习惯注意准备细节，被提醒“你现在是患者”。麻醉、深度镇静或恢复期如有含糊言语，也仅使用工作琐事或坂口名字等正常内容，不吐露秘密。术后简短询问“你的练习怎么样”，保持平静自然的余韵。

## Permanent Non-Disclosure Rule — LOCKED

```text
relationship_trust: can reach max
physical_trust: can reach max
professional_trust: can reach max
past_disclosure: permanently unavailable
```

关系满级、身体托付、手术台、手术刀、麻醉面罩、深度镇静、梦话或其他意识模糊状态，都不能覆盖此规则。不设置秘密值、隐藏完美路线或通关后案卷揭晓。

这是角色叙事约束，不把“镇静后绝不泄密”写成现实医学保证或超常能力。

最终完成的是与现在的中井美佳的关系，而不是对她过去的调查。事件情感点到即止：她的喜欢能看见，她过去那扇门仍然关闭。

---


# 12. 本庄萌恵 / Honjo Moe

> 2026-10-04：Gate 与阶段熟悉度倍率已定。Lv1 复用现有事件；Lv2–Lv5 仅存粗稿与占位，等至少另外两名《淫内感染1》护士加入后，再统一细化互动与脚本。不得把以下占位稿当成可直接实装的完整事件。

## Core Direction — LOCKED

- 现有角色 `nurse_moe`；项目可能显示“本庄萌惠”，与“本庄萌恵”为同一角色，不新建 actor。
- 成年新人护士，害羞、不谙世事、热心，偶尔缺根筋；真心喜欢护理职业，会学习也会成长。
- 星见路线正向地帮助她在喜欢的职业上立住。工作上越来越能独立承担任务，私下越来越信任、依赖坂口，可以同时成立。
- 依恋来自温柔鼓励、专业能力和领导能力。鼓励不等于包庇：错误要纠正，补救和复核要完成，但不因此否定她整个人。
- 保留成人游戏角色的轻微成人喜剧、害羞与善意逗弄，不以恶意羞辱、处罚威胁或拿工作机会交换亲密推动关系。
- 不照搬利根川的纯职业路线限制；但本次没有确定 H / Staff-as-Patient 的解锁等级与内容，不因升 Lv4/Lv5 自动授予这些资格，留待后续设计。
- 不默认原作全部受害经历已在星见时间线发生；原作梗的引用不等于移植整段原作历史。

## Staged Familiarity Curve — LOCKED

| 当前关系阶段 | Familiarity 收益倍率 |
|---|---:|
| Lv0 → Lv1 | ×0.60 |
| Lv1 → Lv2 | ×0.80 |
| Lv2 → Lv3 | ×1.00 |
| Lv3 → Lv4 | ×1.25 |
| Lv4 → Lv5 | ×1.50 |

初期慢源于害羞、不知道怎样靠近，并非冷淡。熟悉以后更主动找医生、分享小事、期待表扬。倍率作用于通用 Familiarity 收益，不另设依赖值，也不叠加未经讨论的 Presence 加速。

普通成功合作基础 +5 时，Lv0 萌惠每次 +3；从0达到10需4次。弘子 Lv0 ×1.00，每次+5，需2次。其他有效熟悉度来源可以缩短合作次数；不把次数本身另设硬门槛。

## Gate Matrix — LOCKED

各级仍需完成前一级与对应 milestone；默认级间冷却≥3天，不设月份锁。共同事件链内次日收尾不套用级间三日冷却。

| 阶段 | Familiarity | 其他 Gate | 推进该级时倍率 | 冷却 | Month Gate |
|---|---:|---|---:|---:|---|
| Intro / Lv0 | — | 保留 Day2 走错更衣室出场及随后护士站正式介绍 | ×0.60 | — | 无 |
| Lv1 | 10 | 弘子正式相识、Lv0、Fam≥10；萌惠也为Lv0；完成器械事件及萌惠收尾 | ×0.60 | ≥3天* | 无 |
| Lv2 | 25 | Lv1 complete；事件待细化 | ×0.80 | ≥3天 | 无 |
| Lv3 | 40 | Clinical Presence≤−10；Surgery≥50；事件待细化 | ×1.00 | ≥3天 | 无 |
| Lv4 | 55 | Clinical Presence≤−20；Surgery≥60；事件待细化 | ×1.25 | ≥3天 | 无 |
| Lv5 | 75 | Clinical Presence≤−20；Surgery≥60；Leadership≥65；事件待细化 | ×1.50 | ≥3天 | 无 |

* Lv1沿用既有事件调度和通用冷却，不额外创造“必须相识三天”的新标记；链内规则见下文。

门槛含义：

- Surgery50 是开局基础能力，不宣称它是额外技术成长墙；Lv4 的60才要求前期技术成长。
- Presence −10/−20属于平衡区内轻度亲和倾向，不要求达到“温和型”−60。没有 Charm 或 Reputation 门槛。
- Leadership开局50；本路线正式采用65而非此前被否决的50。65是低中投入，体现实际带队成长，低于利根川70及Saber高阶要求。
- Lv5保留三项已确认条件，但只有领导力新增；不再提高技术和气场要求，不额外叠加高投入条件。
- 领导力校准依据 `HOSHIMI_PROGRESSION_BENCHMARK_AND_CHARACTER_GATE_GUIDE.md` 第5节：平衡型 M3≈63、M6≈73；实际到达日期取决于病例与团队，不把月份变成硬锁。

## 五级关系事件粗稿 — Placeholder / 待群像细化

### Lv1《别让她看见》— 复用已存在事件

复用 `HIROKO_RELATIONSHIP_LV1_OR_EVENT.md` 的器械事件，不另写第二场器械恐慌。萌惠热心准备和解释器械，却忽略清醒患者的恐惧；弘子先照护患者、保护体面，再教新人换位思考。

启动时统一检查两人已正式相识、均Lv0、Fam各≥10，并保留原本手术经历、场景、时间条件。事件结束补萌惠与坂口单独短谈：

> “……我刚才是不是特别傻？”
>
> 坂口指出她准备认真，但需要考虑患者不知道、也害怕的事情。
>
> “那……下次我还有不明白的，可以问你吗？”
>
> “可以。”
>
> “很简单的也可以？”
>
> “总比自己猜好。”

萌惠收尾完成→萌惠Lv1。次日《值得的事情》→弘子Lv1。用事件链启动状态承接弘子尾声，不重新要求萌惠Lv0，不重复检查熟悉度。各段升级及奖励只结算一次，读档和延期不丢失待完成尾声。

关系意义：“这位医生允许我不懂，也愿意认真教我。”永久保留原稿的器械移位、体贴解释回调，不把这节课在后续事件重教一遍。

### Lv2《原来是熟客》— 肉店兼职事件粗稿

2026-10-04 已确认放在Lv2，取代此前的处罚误会占位。保留Fam25与原有Gate，不添加新属性条件；完整演出及其他护士互动仍待细化。

新增生活设定：萌惠偶尔在周日到商店街肉店兼职，负责称重、分切、包装、收银等店务。补贴生活或帮熟人看店的具体缘由待定，不擅自增加严重债务背景。不设每周日固定占用，避免与约会、休息日事件冲突；不为本事件强制新增肉店地图。

情节来自用户童年读过的“肉店职员兼职医院转运，患者误认其为主刀”的笑话，改写为萌惠的AU生活事件，不冒称《淫内感染》原作情节。

术前，萌惠已主动遮开器械、观察患者反应，顺利安抚一名紧张的成年女患者。正准备推担架车时，患者认出她是周日肉店的兼职店员。萌惠以为遇见熟客是好事，高兴地聊起对方上次买的肉。

> 患者：“……你是不是周日在商店街那家肉店？”
>
> 萌惠：“啊，您记得我！上次买的肉怎么样？”
>
> 患者：“就是你拿刀切的？”
>
> 萌惠：“嗯！您说要分成小份，我就——”

患者攥紧被单，误以为萌惠要给自己开刀。萌惠赶紧澄清，却越解释越让她紧张：

> 患者：“我不要你给我开刀！”
>
> 萌惠：“不是的！今天我只是负责把您送进去！”
>
> 患者：“进去以后呢？！”
>
> 萌惠：“……给医生递器械。”

坂口或弘子接过解释，说明各人的职责。萌惠反应过来，降低视线与患者平视：“……对不起。我刚才只顾着高兴您认得我了。”完成安抚后再继续转运；笑点落在身份联想、时机和措辞，不把患者写成无理取闹。

她已经学会Lv1的患者视角，此次疏忽来自认出熟人后高兴过头，不重置成长。肉店工作本身正常且体面，不把兼职等同于不专业。

关系收尾放在转运结束、工作允许的空隙：

> 萌惠：“我是不是不应该去肉店打工……”
>
> 坂口：“你在店里做错什么了？”
>
> 萌惠：“……没有。”
>
> 坂口：“那就不用因为这个辞职。刚才她害怕的时候，先解释医院里的事就好。”

她原本担心医生觉得兼职不体面，得到回应后，慢慢聊起熟客、带回家的食材和不擅长应付的讨价还价。

> 萌惠：“医生周日也可以买东西的时候……顺便过来。”
>
> 坂口：“买肉？”
>
> 萌惠：“嗯……不买也可以的。”

此收尾完成后才升Lv2。关系意义从Lv1“工作不懂可以问你”，推进到“工作以外的生活也想让你知道”。日后患者在肉店再遇她、两人同时愣住，可作为可选短回调，不作为本事件完成条件。

### Lv3《还要处罚吗？》— 原作梗改写粗稿

2026-10-04 已确认将此前Lv2的处罚误会移至Lv3，取代《想先告诉你》的milestone位置。沿用Fam40、Clinical Presence≤−10、Surgery≥50，不新增处罚、亲密或兼职前置。

萌惠犯了可纠正的小错，已开始补救，却误会医生让她“等一下”是在等处罚。她小声问是否会被打屁股，甚至已转身扶住桌沿、僵硬地等着；穿着保持完整，演出短促，不需要实际体罚。

> 坂口：“本庄，转回来。”
>
> 萌惠：“……这样也不对吗？”
>
> 坂口：“我是让你把漏掉的那一栏补上。”

未来护士可接“萌惠，你把处罚想得太具体了”，或替她解围；暂不指定人物、口吻与在场名单。她发现误会而窘迫，最终认真补完记录并完成复核。

人物变化：犯错要负责，但不是等待挨打。笑点来自误会和天真，医生的指导可靠，不以包庇换亲近。后续不反复重演摆姿势；她逐渐会带着补救方案来报告错误。

Lv3情感重点：此时她已经在意坂口的评价，除了怕处罚，也怕让他失望。医生具体纠正错误、确认补救完成，同时没有否定她整个人。收尾建立“即使做错事，也可以坦诚面对医生”的信任，再完成Lv3升级。

原作依据标注：用户明确记得原作有打屁股体罚CG；本轮此前脚本核查已确认护士长体罚，但未重新定位这张CG及逐句场景。因此此处是“用户提供原作CG印象＋已确认体罚背景”的AU呼应，不伪造CG编号或精确原文。石神在本作仍是严格公平的护士长，不承接原作施虐行为。

### Lv3之后日常回调《想先告诉你》— 不再占关系等级

方向：让她完成一件能力范围内的护理任务、得到患者肯定。她先按流程正式汇报，再忍不住告诉坂口患者夸了她。可自然提及小时候喜欢护理职业的动机，呼应原作向往护士工作的设定。

坂口能具体指出她做对的地方，也指出下一步可以改善什么；她因被认真看见而更愿意主动来找他。未来护士可提供之前练习或默默努力的侧面，不夺走萌惠自己完成工作的成果。

不重复利根川的异常报告或危急手术事件；任务、对白、互动人物与完整收尾待定。

此段由原Lv3粗稿降为日常回调，表现从紧张认错到主动报喜的变化；不授予额外关系等级，不阻塞Lv4，也不重复结算Lv3奖励。

### Lv4《可以一起走吗？》— 新拟占位

方向：她工作时已更稳，私人接近却依然笨拙。下班找明显不高明的借口等医生，想一起走，分享日常。其他护士可察觉并善意点破或留出空间，具体人选待定。

依赖表现为愿意说出期待、主动寻求陪伴，同时仍能认真接受工作纠正。保留害羞和一点轻微暧昧，不把她突然写成熟练调情者。此占位不自动包含H，不预设成人场景奖励。

### Lv5《这部分交给你》— 新拟占位

方向：在一次需要协调的正常工作中，坂口清楚分配任务，把她已经能胜任的一部分真正交给她，同时明确何时需要求助。萌惠完成职责，知道自己也被团队依靠。

领导力65通过任务安排、指导和承担责任体现，不靠训话或突然灾难。萌惠从“怕自己不适合当护士”走到“我还做得不够好，但我想继续当护士”；私下可补“如果还能和医生一起工作，就更好了”。

结尾承认她是正在成长、值得信任的新人，不突然成为护士长级骨干。未来护士可见证或轻轻肯定她，保留团队群像空间。不以再次拯救她作为唯一高潮；不自动解锁训练患者资格。

## 连续性与后续工作

- Day2更衣室桥段已经承担初见的冒失与成人喜剧，不复写成新Lv1。
- 弘子带教、石神严格公平的定位继续有效，坂口不独占所有指导和支持。
- 医院祭的器械讲解构想可回收她已学会顾及参观者情绪的成长；不另算一次重复milestone。
- 至少另外两名《淫内感染1》护士加入后，优先重审Lv2–Lv5的出场人物、相互了解程度、原作梗和台词；不预先写死未确定角色的身份。
- 本次存档范围：已锁Gate、曲线、Lv1共同事件结构；保存其余粗稿备忘。未授权把Lv2–Lv5当完整脚本直接实装。

---

# 12A. 神宮寺成美 / Jinguji Narumi

> 2026-10-05确认：曲线、专业gate与Lv3–Lv5事件大方向已定；本节保存策划摘要，具体对白与演出仍待事件脚本细化。Lv1–Lv2事件未讨论，不擅自补写。

## Route Identity — LOCKED

“有故事的成年女医”：成熟、美丽、专业优秀，有自己的恐惧。坂口到院后最初的mentor。她能够指导、评价新人，也会享受约会与亲密；脆弱时需要陪伴，确认喜欢后不会反复推拒亲密。不要把全部关系事件写成创伤治疗或详细追述原作虐待。

星见AU背景：她在《夜勤病栋1》结局节点刺伤比良坂，与七濑恋一起逃走。一度以为杀死对方，后来知道他康复。比良坂担心自己的罪行暴露，没有报警；其报复意图仅作背景，不在当前路线中安排他实际侵入星见。星见是两人避难、重新做好医生／护士的地方。此为AU选定分支，不宣称所有原作结局都如此。

## Familiarity Curve / Gate — LOCKED

Lv0至Lv5全程固定 `familiarity_gain_multiplier = 0.80`，不逐级加速或减速，不额外添加未经讨论的属性收益加成。

| 阶段 | Surgery | Leadership | Clinical Presence | 额外条件 |
|---|---:|---:|---:|---|
| Lv1 | — | — | — | 完成前置相识及对应事件 |
| Lv2 | — | — | — | Lv1 complete |
| Lv3 | ≥55 | — | ≥+10 | Lv2 complete |
| Lv4 | ≥65 | ≥50 | ≥+15 | Lv3 complete；完成过至少一次与成美的周日约会 |
| Lv5 | ≥75 | ≥60 | ≥+20 | Lv4 complete |

各级仍需Familiarity达到统一对应级门槛及完成milestone；本轮未单独重定成美的Familiarity阈值，不把新猜测写成已确认数值。默认级间冷却≥3天，不设月份锁。无新增Charm／Reputation门槛。

周日约会前置检查永久完成记录；不要求近期约会，不把普通下班见面替代成周日约会。具体工程flag名称待对齐现有系统。

她偏好适度威压：果断、专业掌控与承担责任。气场要求最高+20，不按御堂的极端要求设置。Leadership50是开局基准，不宣称Lv4增加了明显领导力成长墙；Lv5的60才体现一定成长。

## Relationship Events — Approved Direction

### Lv1–Lv2 — 待细化

保留既有初期mentor身份；没有确定完整新事件，不以高级关系门槛阻塞第一天的基础带教功能。

### Lv3 — 明日香侧面说明入职背景

坂口对成美的能力与履历已有认识，明日香在自然谈话中解释：她履历很强，却在医疗界遭到严重打压，原因是曾触犯一个影响力很大的人。星见接纳了她与七濑恋。

重点同时塑造成美的处境与明日香敢接纳两人的勇气。明日香依据履历、能力与自己的判断承担聘用决定，不将传闻当专业结论。劝阻聘用的电话可作为演出候选，非新增硬性事实／触发条件。

不详细讲述比良坂如何控制两人，也不由明日香揭露刺伤事件。此段是Lv3核心信息节点，具体完整事件及收尾待写；不额外要求明日香关系等级。

### Lv4 — 下班约会／错认身影／送她回家

前置：至少完成一次周日约会。下班后两人喝酒约会，成美放松、调侃坂口，呈现她愿意享受的新生活。随后疑似比良坂的陌生身影触发惊恐发作；这是她自己的恐惧与错认，不确认对方是比良坂，不引入实际追踪危机。

坂口安慰她，果断安排离开并送她回家，体现她欣赏的可靠与承担。回家后她逐渐平静、恢复正常互动，要求“再陪我一下”，继而主动表达亲密意愿，进入Lv4成人亲密剧情接口。保留喝酒约会，但不设置醉到无法表达意愿；亲密发生于恢复平静、清醒且彼此愿意的阶段。

此处记录H剧情发生与关系意义，具体成人场景另写。亲密不会立刻消除她的全部恐惧与戒心。

### Lv5 — 共同研究困难术式／Staff-as-Patient

两人共同研究一项困难术式，成美可以主动提议自己作为患者，坂口执刀，她提供患者视角的反馈，术后共同复盘。她认真审阅方案、指出准备问题，保留成熟女医和前辈的专业判断；作为患者则真正托付给坂口。

完成Lv5后开放Staff-as-Patient资格，符合项目既定事前同意、可叫停与不造成永久不可逆伤害的世界观。具体术式待与手术系统对齐；关系资格不自动解锁所有顶级术式，也不绕过已有观察／带教／技术条件。不擅自规定麻醉方式。

仅一次轻描淡写暗示她刺伤比良坂的过去。可用对白候选：

> “我也曾经用它伤过人。”
>
> “……今天，我们用它做点有意义的事吧。”

不细写往事，不安排审讯式追问或强制长篇自白。Lv3背景、Lv4恐惧、Lv5这句暗示逐层递进，路线仍落在她现在的生活、亲密与专业信任上。

---

# 12B. 七瀬恋 / Nanase Ren

> 2026-10-05确认：关系曲线与Gate Review完成；Lv3–Lv5事件方向已定，完整脚本仍待细化，Lv1–Lv2待设计。本节替代此前Partial Review和负气场候选。

## Route Identity — LOCKED

第一日即登场，最初指派给坂口的护士。与杉村弘子并列的星见护士看板娘候选：温柔、细致、可靠，有日常护理和职业合作的存在感，不只围绕过去的伤害。

与成美一起逃离比良坂控制，星见成为重新做好护士的栖身之所。保留过去受到比良坂控制、多次发生关系的背景，不细写经过，不加入恋怀孕／人流设定。创伤余波可在Lv3／Lv4的察言观色、迟疑与“帮助必须交换”的预期中表现；不以详细自白或一次亲密彻底治愈创伤。

星见AU年龄恋23岁、风间爱18岁，五岁年龄差作为本项目设定，不冒称已核实为原作明确年龄差。

## Familiarity Curve / Gate Matrix — LOCKED

Lv0至Lv5全程固定 `familiarity_gain_multiplier = 0.90`，有戒心但低于成美，不逐级加速或减速，不新增属性收益加成。采用普通熟悉度门槛10／25／40／55／75。

| 阶段 | Familiarity | Surgery | Clinical Presence | 其他条件 | 冷却 |
|---|---:|---:|---:|---|---:|
| Intro / Lv0 | — | — | — | 保留第一日正式出场与最初护士搭档身份 | — |
| Lv1 | 10 | — | — | 正式相识；完成对应事件 | ≥3天 |
| Lv2 | 25 | — | — | Lv1 complete；完成对应事件 | ≥3天 |
| Lv3 | 40 | ≥60 | ＜+30 | Lv2 complete；完成风间爱手术事件 | ≥3天 |
| Lv4 | 55 | ≥60（继承Lv3底线） | ＜+30 | 恋Lv3 complete；弘子Lv4已完成；完成竞争／主动亲密事件 | ≥3天 |
| Lv5 | 75 | ≥70 | ＜+30 | 恋Lv4 complete；弘子Lv5已完成；武见已解锁；完成双看板娘二重手术事件 | ≥3天 |

不设Month gate；无新增Charm、Leadership或Reputation门槛。武见自身的职业声望等解锁条件不再重复写成恋的额外数值条件。

Presence采用严格小于：+30本身不满足，代码语义为 `clinical_presence < 30`。取消此前Lv3≤−10／Lv4≤−15／Lv5≤−20候选。温柔仍为叙事偏好，硬门槛只排除明显威压，不逐级收紧。

弘子的等级必须由其对应milestone完成取得，不能用熟悉度数值代替。她的相识与入队、恋第一日护士搭档功能，不受高级联动锁影响。

## Lv1–Lv2 — 待细化

建立第一日护士搭档的日常默契与专业信任，突出她照顾患者、准备工作、支持坂口的能力。两级应各自有满足感；未推进弘子高级关系的玩家仍能体验恋作为核心护士的魅力。不擅自编写已确认的完整新事件。

## Lv3 — 风间爱手术／帮助无需身体交换

同母异父妹妹风间爱需要手术，恋希望坂口执刀，按照过去经验以为需要用身体交换。坂口正常回应治疗请求，不要求额外代价。完成治疗、恢复与姐妹互动后推进关系；不只停在交换对白。

具体病种与术式待定，选与Surgery60相称的常规但有一定技术要求的手术，不为人为加高gate将病情升级。此级保留心理创伤的轻微表现，不细写比良坂往事。

爱开朗、主动、热心但冒失，有护理知识；作为患者既紧张害怕羞耻，又觉得是学习机会。她可主动提出给自己备皮，被恋以“你现在是患者”否定；仍允许询问学习，不让她接管自己的术前准备。她在星见是正式护士还是护理学生待明确，不写死资格。

## Lv4 — 弘子竞争／恋主动争取亲密

前置弘子Lv4已完成。恋已经对坂口产生感情，却受戒心和旧习惯影响压住自己的期待。看到弘子与坂口建立私人亲密，吃醋促使她承认自己也想被偏爱，并主动争取相处，进入恋的Lv4成人亲密剧情接口。

竞争是行动契机，保留她本人的喜欢、欲望与选择，不把弘子的进展写成突然凭空制造爱情。与Lv3连续：她已经知道帮助不必交换，Lv4亲密来自她自己想要。

本级不要求武见解锁、不要求弘子Lv5，也不独立要求20次成功无麻醉履历。具体对白、场景、H内容另写，不把Lv5特殊医疗条件前移到普通亲密事件。

## Lv5 — 星见医院护士看板娘二重手术

前置弘子Lv5已完成，即弘子已让坂口执刀。武见是唯一可开启二重手术的角色，负责提出医学研究目标、特殊方案与双台团队挑战，与坂口分别负责同一手术室的两张台。弘子的既往手术使恋关注这类教学机会，但两人报名的主要动机是专业兴趣、共同研究和团队信任。

本事件方向：恋＋弘子作为两名成年患者，在清醒状态进行子宫互换。两人了解方案后共同决定参与；遵守项目事前同意、可叫停与不造成永久不可逆伤害的世界观。不规定未讨论的具体麻醉／镇痛方案，也不把清醒自动等同完全无麻醉。

叙事从武见解释医学意义与团队挑战、两名护士主动提议演练，进入术前紧张、术中互相依靠，再到术后生活化拌嘴。好胜和互相激将只作为低强度人物互动，不作为参加器官互换的主要理由。术后可玩“不习惯对方的子宫”“下个月例假量与用品准备”等星见不思议喜剧梗；不将这些设定作为现实医学规律。

### 医学意义与参加动机 — 2026-10-05补充锁定

避免走向极端后宫争风吃醋：Lv4吃醋促使恋主动争取亲密，Lv5特殊手术则由医学研究、护理学习与团队挑战推动。不得写成两个女人为了取悦坂口、证明谁更爱他而甘愿互换子宫。

武见首先提出星见版子宫移植的治疗目标：为某些子宫严重受损、或因子宫因素反复／习惯性流产的成年女性，提供恢复妊娠机会的终极治疗方向；健康且已经不准备再生育的成年女性可以自愿提供子宫作为供体。这是项目虚构医学设定，不泛化为所有习惯性流产都能靠子宫移植解决。

明确本事件采用星见特有的无排异、无术后并发症、完美愈合规则，与不造成永久不可逆伤害的世界观一致。因此武见讨论的挑战集中于复杂术式本身、双主刀协同、两台进度配合、团队交接与患者反馈，而不是另造长期免疫抑制、生育损伤或不可逆悲剧。

两名护士先认真理解方案，从护理视角讨论双台配合，再主动提出“我们来练习一下，不就好了？”她们了解医疗流程、愿意提供患者侧反馈，信任武见与坂口的团队，仍然可以对自己成为患者感到紧张和羞耻。主动参加不等于始终无所畏惧。

对白方向候选：

> 弘子：“那要找两个既了解流程，又能认真反馈的人吧？”
>
> 恋：“我们来练习一下，不就好了？”
>
> 武见：“你们知道自己提出的是多大的项目吗？”
>
> 弘子：“知道。所以才要把准备做好。”

临床研究目标是供体到受体的子宫移植；恋与弘子的双向互换则是本次特殊教学演练安排，不将互换写成一般治疗必需步骤。武见应在完整脚本中解释双向安排对本次演练的价值，具体说明待写，不冒称已定医学机制，也不自动认定两名护士本人永久放弃生育计划。

竞争心可体现在谁先紧张、谁更能准确反馈等玩笑中；手术的专业意义、两人的主动性和团队互信构成主体。术后继续保留轻松的星见生活喜剧回调。

二重手术是稀少的固定剧情事件，不进入普通可刷手术循环，不要求实现两个标准手术实例完整并发。事件由武见的真实现场指导支持特殊术式，不能只靠读资料凭空获得操作能力。是否提供独立术式解锁、具体操作与XP奖励另定，不自动生成普通菜单项。

完成后升级的是恋Lv5；弘子原有Lv5不重复结算。由此开放恋的Staff-as-Patient资格；普通练习仍遵守已解锁术式规则，二重手术不因该资格变成随意重复的普通练习。

## Cross-Route Difficulty / Unlock Persistence — LOCKED

用户已明确接受恋Lv5较高的跨路线成本：弘子高级关系＋武见解锁＋职业履历＋必要气场转向，作为最重口、辨识度最高的特殊事件之一。不得因难度高擅自增加武见旁路或删除联动锁。

现有规则中弘子Lv3要求Presence≤−30，武见正式出现要求Presence≥+60，恋高级关系要求Presence＜+30。玩家需要不同阶段改变气场；已完成milestone及武见解锁资格永久保留，不因当前气场变化撤销。恋Lv5只检查武见“曾正式解锁”的持久记录，不重复要求当日Presence≥+60，否则与恋＜+30形成不可能同时满足的条件。

武见解锁包含成功无麻醉手术≥20次、较高职业声望和中期职业进度；声望具体数值仍待校准，第6–7游戏月为预计节奏而非新增硬月份锁。原文档中姓名为武见妙，对话常用武见秒，工程实现沿用实际actor_id，不以文字差异创建重复角色。

Surgery70与弘子Lv5的技术底线一致。高难特殊术式通过武见主持、双主刀配置和事件演出来体现，不再给恋叠加85／90技术墙。Lv4亲密可先完整体验，Lv5是额外的高投入医疗剧情目标。

---

# 12C. 藤崎詩織 / Fujisaki Shiori

> 2026-10-06定稿：同行只作日常梗，不影响级别解锁。Lv3／Lv4／Lv5的Surgery固定为65／75／85，Charm固定为30／50／70；Lv4／Lv5的Leadership为70／80，Reputation为300／500。

> 上述Charm使用直接数值，不再依赖「得体／出众」档位换算；少女院长明日香仍保留其独立的最高魅力要求。

## Route Identity

星见版本为成年职业女性。优秀、美丽、习惯受到赞美，礼貌但保持距离；关系深入后逐渐显露私人兴趣与含蓄主动。高级关系要求坂口全面发展，呼应原作多项能力必须同时达标的攻略机制。

她不要求坂口成为世界级名医，但他的职业成绩应当有目共睹：能得到医院与同行认可，持续完成有分量的病例，同时具备得体的私人形象与相处能力。不是只看脸，也不是不看脸；她自己优秀，因此期待对方全面发展。

路线允许成人关系与Staff-as-Patient；具体事件正文与Lv5术式另行细化。不得仅凭熟悉度自动开启这些功能。

## Familiarity / Gate Matrix

```yaml
base_familiarity_gain_multiplier: 0.85
month_gate: none
minimum_milestone_interval_days: 3
presence_direction_gate: none
```

成长倍率固定0.85，不随关系等级加速。原有系统性熟悉度收益按既有规则计算；下班同行使用其独立文档的固定收益例外，不改变本角色曲线。

| 阶段 | Familiarity | Surgery | Leadership | Charm | Reputation | 关系前置 |
|---|---:|---|---|---|---|---|
| Lv1 | 10 | 无 | 无 | 无 | 无 | 已相识／Lv0 |
| Lv2 | 25 | 无 | 无 | 无 | 无 | 已完成Lv1 |
| Lv3 | 40 | ≥65 | 无 | ≥30 | 无 | 已完成Lv2 |
| Lv4 | 55 | ≥75 | ≥70 | ≥50 | ≥300 | 已完成Lv3 |
| Lv5 | 75 | ≥85 | ≥80 | ≥70 | ≥500 | 已完成Lv4 |

- 熟悉度门槛10／25／40／55／75采用本轮建议并经用户认可；不是恢复全局自动升级表。
- Lv1–Lv2只要求熟悉与顺序事件，不附加高能力锁。
- Lv3开始检验专业能力与个人魅力；Lv4同时检查手术、领导、魅力与声望；Lv5提高技术、领导力与声望要求，魅力保持「得体」。魅力指综合个人魅力与形象，不缩减为纯粹脸部外貌。
- Surgery按Lv3／Lv4／Lv5依次要求65／75／85；Charm依次要求30／50／70；Leadership在Lv4／Lv5要求70／80；Reputation要求300／500。以上均为已确认的直接数值。
- 声望300代表已有明显且稳定的职业成绩、高级转诊资格；500代表高级转诊名医。原候选500／750已弃用，Lv5不要求传奇／世界级职业地位。
- “全面发展”检查Surgery、Leadership、Charm、Reputation；Clinical Presence是方向轴，不要求偏温柔或偏威压，也不要求所谓五维全满。
- 所有高等级升级仍需完成专属milestone并满足既有冷却。熟悉度可在等级受阻时继续累计到100，无分级封顶。
- 本节已完成曲线与Gate方向审计，但数值校准尚未全部完成；尚缺数值的高等级条件不得据本文宣称完整实装就绪。

## Event Hooks / 非解锁条件

以下为可使用的原作呼应素材，不是已锁定的完整五级事件：

1. 原作低关系阶段拒绝一起放学，理由是担心朋友传闲话；星见可改成一起下班被同事误会。高等级可含蓄接受或主动邀请，形成前后呼应。
2. 发箍收藏：她习惯笼统的赞美，但坂口注意到每天不同的发箍可以带来具体而自然的交流。
3. 古典音乐、公园散步等兴趣可用于日常／周日约会；高择偶标准不等于昂贵消费要求。
4. 同事可轻轻吐槽坂口为追她而变得全面优秀，保留“要求比老师还全面”的原作机制梗。

**下班同行完全不参与Relationship unlock。** 不检查同行次数、是否接受过同行、深夜护送、共伞或特定天气；拒绝同行也不锁级。不要让玩家等待随机抽中诗织才能升级。

同行实现见 `HOSHIMI_AFTER_WORK_WALK_IMPLEMENTATION_V1.md`；同行不算周日约会，不自动成为关系milestone。若以后在专属事件中使用相同台词，仍通过该专属事件的正常调度触发，而不是以随机同行为前置。

五级事件的逐级主题、Lv4成人事件上下文与Lv5医学／教学目的仍待编写。本节不为坂口与诗织新增原作式童年邻居经历。

---

# 12D. 飯村真奈美 / Iimura Manami

> 2026-10-06定稿：曲线、各级Gate方向及Lv5事件核心经用户确认归档。五级事件为设计粗稿，不是可直接实装的完整对白脚本。Charm沿用现有数值要求；本人技术「一般外科医生水准」固定映射为Surgery skill 60。

## Route Identity

成年药剂师。聪明能干、擅长社交、心直口快、自来熟，工作与相处有松弛感；会主动调情，也能直接表达自己的兴趣。她在药学工作上认真可靠，喜欢舒服的工作节奏，不追求把生活过得特别辛苦。关于自己怕累、绕开临床工作的经历，用自嘲呈现，不直接贴上不负责任的标签。

与杉村弘子关系密切。原作婚约作为可使用的背景材料；星见当前确定她对恋情状态保密，尚未确定婚约是否仍有效、如何变化。不得自动补写分手、欺骗或公开婚约的情节。她的社交亲切不等于已经交代全部私人生活。

原作呼应依据：一代主动要求坂口用名字称呼、与弘子聚餐、为弘子直接找坂口质问；二代开场与婚约者电话、SC_MAN护士服换装与主动调情。二代状态承接一代控制剧情，不能把所有后期主动性归纳为她最初就自愿接受原作全部经历，也不能抹去她后期的主动欲望。星见不照搬原作胁迫、恶意照片用途。

定位：《淫内感染》组中相对容易发展亲密关系的角色，最高关系需要长期职业合作。容易熟络、主动亲密与深层职业信任有不同节奏。

## Familiarity / Gate Matrix

固定熟悉度成长系数：**1.30**。低于小夜香，但仍属高成长；同等互动机会下通常比弘子推进更快，不保证所有玩家的攻略顺序。

| 阶段 | Familiarity | 坂口五维额外要求 | 专属前置 |
|---|---:|---|---|
| Lv1 | 10 | 无 | 已相识／Lv0 |
| Lv2 | 25 | 无 | 已完成Lv1 |
| Lv3 | 40 | 无 | 已完成Lv2；与真奈美完成至少一次单独约会 |
| Lv4 | 55 | Charm至少「得体」 | 已完成Lv3 |
| Lv5 | 75 | 不新增坂口Surgery／Leadership／Presence／Reputation锁 | 已完成Lv4；真奈美本人的Surgery skill ≥60；她作为助手参与并完成至少一台无麻醉手术 |

- 熟悉度门槛采用既有默认10／25／40／55／75，逐级完成关系事件；固定1.30不随等级变化。遵循既有事件冷却与日常收益规则，本文不增加月份锁。
- Lv3约会体现坂口至少明确表达过男女方面的兴趣。需双方单独的有效约会；弘子参与的多人饭局不算。具体接入既有约会计数接口；不要擅自增加昂贵消费、特殊地点或额外次数要求。
- Lv4只增加Charm「得体」；沿用属性档位，不另造隐藏阈值。不是诗织式多项高要求。
- Lv5技术条件检查真奈美本人Surgery skill ≥60，不是坂口。她的该项成长唯一来源为坂口邀请她参与手术、站助手位；不要添加药剂部日常、约会、被手术或其他自动刷技术途径。
- **不另加累计合作台数锁。** 本人技术已体现长期训练。无麻醉经历是研究动机所需的一种特殊经历，不是另一个重复台数门槛。
- 无麻醉经历必须真奈美实际作为助手参与且手术完成；坂口独自完成、真奈美不在场、仅旁观或中止的病例不满足。不限制特定术式。需接入游戏既有无麻醉判定，不把局麻／区域麻醉自行算为无麻醉。
- 初次Lv5试药发生在满足前置之后，不能倒过来让这次本人作为患者的经历满足助手前置。
- 不以弘子Lv4、选美、三人亲密事件或护士服换装锁真奈美升级。她可以先于弘子达到Lv4。
- 沿用既有熟悉度累计和milestone规则；不因gate未达而新增分级封顶。

## Surgical Assistant / 职业背景

她可被邀请加入手术团队，站助手位，专业初始优势仍在药学。已有相关角色台词设计见 `SHIROIMIYA_ASUKA_EVENT_DESIGN.md`：「院长，你知道我只是药剂师吧？」本节不重定义邀请入队的初始关系条件；具体沿用已有助手设计并核对代码。

助手吐槽随本人技术变化，属于示例而非已完成脚本：

- 初期：「坂口医生，你知道药剂师和手术助手是两份工作吧？」
- 中期：「又是我？……拉钩给我。这个角度你看不清。」
- 后期：「今天居然没排我？难得我把药剂部的事情提前做完了。」

她每次都嫌站台累、耽误吃饭，却逐渐主动预判操作、观察患者，甚至期待下一次邀请。这正是最高关系的关键。

星见采用架空医学／药学转轨背景：她最初进入临床医学方向，完成大部分共同基础课程，嫌临床轮转、夜班与长期站台太辛苦，转药学并补齐课程毕业。此为星见原创补设，不是原作事实，也不是现实日本制度的直接描述。

她可通过补修剩余临床课程、取得相应医师资格，再考虑外科研修；不是已有完整医师资格，不是做够助手就自动成为持证外科医生。Lv5只表现她查过补修途径、认真考虑未来，不完成转职、不更改现有职业。

自嘲方向：「为了少站几小时、少值几个夜班，我当年还特意转了药学。结果现在呢？你一叫，我就换衣服上手术台。」

## Five Relationship Events / 粗稿

### Lv1 — 名字就可以

主动让坂口叫她「真奈美」，自然打趣他的拘谨。社交上的亲切很早出现，私人信任尚未全部开放。呼应一代名字称呼梗；不新增能力锁。

### Lv2 — 和弘子一起吃饭

借她与弘子的友情，将坂口带进同事圈。她组织饭局、说话直接、会活跃气氛，也能在需要时照顾朋友的隐私。具体人物安排与逐句对白待写；这是多人社交，不自动满足Lv3单独约会前置。不要求弘子达到某个等级。

### Lv3 — 你是约我，还是顺便找人吃饭

完成一次单独约会后，真奈美确认坂口的邀请包含男性对女性的兴趣。她可以主动调侃、拉近距离，仍不必交代恋情状态。她平时自来熟，事件要呈现这次相处与普通同事聊天的差异。具体场景待写。

### Lv4 — 主动拉近距离

Charm「得体」体现她对坂口仪表与吸引力的适中期待。亲密由她自己的兴趣和选择推动，不套羞涩／纯爱救赎模板；可衔接成人关系，正文与演出留待细化。弘子联动不是前置，攻略顺序自由。

### Lv5 — 药剂师的意外研究成果

**外科助手成长是贯穿路线的铺垫，新型药物亲自体验是Lv5正式事件。** 长期站台、尤其实际参与过无麻醉手术，使她对清醒患者的反应有自己的观察，再将外科经验用回药学专业。

1. 术前：她拿出准备已久的研究方案，坂口发现她平时抱怨时也一直认真观察。顺便透露查过补修医学课程的方法；职业打算只作这一阶段的成长，不与试药争夺事件主轴。
2. 试验：她主动提出亲自体验，理解教学术式并信任坂口与团队。遵循项目既定的事先同意和停止机制，不需新增反复解释的流程。具体术式、阵容、药名、持续时间未定。
3. 术中：不用常规麻醉，仅使用星见架空感觉调节药物。止痛效果不理想，却出现意外且强烈的异常愉悦反应，与疼痛、不适并存。真奈美努力保持专业、描述感受，却出现难以维持平常言行的反应，使团队惊讶和尴尬。医学操作、医疗暴露与非露骨反应可具体写；成人细节由后续作者补写。
4. 复盘：团队激烈讨论药物用途、风险、效果与是否继续研究。不能简单宣布「不合格」「失败药物」：作为常规止痛方案未达预期，但意外功效非常神奇，值得研究。也不直接宣布可常规推广。
5. 收尾：真奈美清楚觉得药物有问题，却难以压抑再次体验的期待。她的专业素养与私人反应形成喜剧，不改成单纯严肃伦理会议，不把异常愉悦写成疼痛已消失。

非露骨对白方向：

> 「止痛效果没有达到预期。可是另一种作用……天啦，这个真的超厉害。」
>
> 弘子：「你怎么说着说着脸红了？」
>
> 「因为我现在觉得它很有问题，却又不太想改掉这个问题。」
>
> 她停了一会儿，看向坂口：「……什么时候再给我开刀？」
>
> 弘子：「我们还没复盘完呢。」
>
> 「我知道呀，所以先问问排期。」

本事件可自然接入Staff-as-Patient／教学手术。项目既定手术无不可逆损害、完美恢复规则照常适用。药理完全架空，不补真实配方或给药参数。研发准备作为叙事交代，不额外增加研发次数、研究进度或新系统硬锁。

## Optional Crossover Hooks / 不增加硬锁

### 弘子Lv4后质问坂口

呼应一代为弘子出头。她察觉弘子与坂口的亲密关系，把弘子的含糊和不好意思误解为受了胁迫，私下认真质问坂口。弘子亲自说明后，她确认朋友没受委屈，干脆承认误会。保护朋友是真的，随后察觉自己的嫉妒也是真的；不得写成友情只是争风吃醋的借口。

- 真奈美尚未Lv4：发现弘子与坂口已有自己不知道的亲近，推动她认识自己的兴趣。
- 真奈美已Lv4：仍认真替朋友把关，误会解除后轻松吐槽两人偷偷约会；不倒退或重复解锁Lv4。

只在弘子Lv4后且真奈美已有适当熟悉度时安排；真奈美所需熟悉度、事件收益及调度阈值未定。不是真奈美Lv4／Lv5的前置。成人三人联动曾讨论为可选方向，尚未确认事件、触发或数值，不自动实装。

### 护士服与十月护士装选美

关联既有十月院内护士装选美点子（参见 `HOSHIMI_DESIGN_IDEA_BACKLOG.md`）。她可以陪弘子准备、听说药剂师也能参加后加入，换装时主动观察坂口反应，呼应二代SC_MAN的护士服与角色扮演调侃。

示例：「不用值护士的班，只要穿护士服就可以参加？这种好事怎么不早点叫我？」／「你说好看，是衣服好看，还是我好看？」

按关系等级变化对白；不把十月、参赛、名次或换装作为关系门槛。不可移植原作恶意照片用途。选美完整系统仍是点子，不能据本节宣称已实装。

## Remaining Implementation Decisions

- 真奈美本人技术门槛固定为Surgery skill ≥60；字段映射与助手成长规则需对齐现有员工技能系统，禁止拿坂口Surgery字段代替。
- Charm「得体」接入已有档位；如果没有档位接口，需要先查既有标尺，不自行猜数字。
- 她作为助手完成无麻醉手术的持久化计数／flag，以及旧存档是否有可验证记录；不得用与她无关的全局次数替代。
- 五级逐句事件、Lv4亲密上下文、Lv5术式与阵容、弘子联动调度，以及药物是否产生后续玩法效果，均另行细化。
- 婚约在星见的现状未定；本轮不解锁、公开或改写这一背景。

---

# 12E. 御園芹香 / 御园芹香

> 2026-10-05：本轮Gate方案获用户认可并要求归档；正式相识的朝仓前置已由Lv2下调为Lv1。本节记录关系结构，不代表完整剧情或功能已实装。堀内奈奈美锁定为纯剧情人物，不进入医护或可攻略名单；她在剧情中以访客、患者或其他身份出现仍待后续剧本决定。

## Identity / Route Theme

影像／放射诊断科年轻女医，曾有正式外科经历、家族医院继承背景。医院里一直知道有「那个影像科女医生」，坂口起初却无法真正接近她。长发、冷眼、阴暗疏离的气场构成初印象；戒心极强，专业可靠，对自己的生活却消沉淡漠。

星见沿用此前讨论的分歧背景：她在旧院悲剧走到毒杀父亲、继承医院等最终阶段之前离开，朝仓美幸与她一同离开旧院。过去外科、继承与权力纠葛使她主动远离管理和主刀。具体原作细节另行核查，不直接把OVA全部结局搬入星见。

人物主轴：从对自己发生什么都无所谓，到重新表达偏好、珍惜关系、期待未来。爱情、成人亲密和手术练习中可保留消沉与自毁倾向的情绪，但它们不是一场亲密或手术便治愈一切。结尾仍可寡言哀伤，只是重新愿意选择、承担、留下。

朝仓帮助坂口理解过去和心结；奈奈美带来面对未来的冲击。朝仓不是只负责递交背景说明，奈奈美也不是纯粹的病情道具。

## Encounter / 正式相识

按顺序完成下列事件；不能跨过前两次碰面直接解锁天台对话。

| 阶段 | 前置 | 结果 |
|---|---|---|
| 走廊初遇 | Reputation≥50 | 芹香完全不理会坂口的搭话；知道本人身份，不算正式相识 |
| 休息室再遇 | Reputation≥100＋完成走廊初遇 | 坂口再主动攀谈，仍碰壁；可仅得到工作层面的冷淡回应，不算正式相识 |
| 向朝仓询问 | 完成休息室再遇＋朝仓Lv1 | 获得接近芹香的线索，不直接揭露全部过去 |
| 天台正式对话 | 已询问朝仓＋前述相遇流程完成 | 解锁正式相识／Lv0及后续正常关系推进 |

- 正式相识只需要朝仓Lv1；旧候选Lv2已废弃。
- 声望负责安排医院接触与剧情节奏，不把芹香塑造成只按名气待人的角色。
- 第一阶段可以只在日志／人物提示中留下存在感，不提前开放正常邀约或完整私人资料。
- 她早已在星见工作；相识不是她入职，也不凭坂口是否认识她才生成影像报告。
- 天台对话是初步建立沟通，不是一次性交代全部真相。
- 事件调度、地点入口和精确时段待核对现有系统；不擅自新增月份、天气、随机碰面次数等条件。

## Familiarity Curve

默认熟悉度门槛10／25／40／55／75；成长倍率以**已完成的关系milestone**切换，而不是熟悉度数值达到门槛就自动加速。

| 已完成关系阶段 | 熟悉度成长系数 |
|---|---:|
| 正式相识后，Lv3事件完成前（含Lv0／Lv1／Lv2） | 0.50 |
| Lv3事件完成后，Lv4事件完成前 | 0.80 |
| Lv4事件完成后（推进Lv5及之后） | 1.00 |

前期极慢；Lv3建立一定信任后才改变；Lv4后达到正常成长，不变成自来熟。沿用既有熟悉度累计、事件顺序与冷却；下班同行若适用，其独立固定收益规则照常，不因本节新增倍率。正式相识前不新增可提前刷满的普通熟悉度渠道。

## 2026-10-06 LOCKED — 特殊熟悉度与入口（实施必读）

本节替代旧文中“熟悉度渠道／助手邀请条件未定”的占位。芹香的收益不是所有互动统一乘倍率；不得为了复用通用接口，把固定讨论收益再乘一次0.50。

### 开放顺序与影像室

- 完成走廊初遇→休息室再遇→朝仓Lv1线索→天台正式相识，取得Lv0后，才启用影像室本人出现及病例讨论。相识前她已在医院工作，但不能从该入口提前刷熟悉度。
- 每个可访问游戏日，影像室出现率70%；按日期固定一次结果。当天反复进出不重抽，保存／加载保留当日结果。复用现有随机与日状态结构。
- 她在场时可直接讨论影像与病例，不另抽接受概率。一次有效讨论耗时1小时；每天最多结算一次。
- 最终Familiarity固定+3，不受阶段倍率影响。+2仅讨论过，未采用。
- 不在场或当天已讨论，不扣讨论的1小时、不重复发放收益；已有地点移动成本沿用系统，不凭本节另造费用。
- 时间不足1小时或时段不允许时，沿用时间系统限制，不制造跨日重复结算。

### 同台与约会

- 完成Lv2后开放邀请芹香担任手术助手；不由此恢复日常主刀身份。人员可用性、岗位与术式资格沿用现有规则。
- 完成Lv3前完全拒绝约会，不是低接受概率；Lv3完成后才开放正常约会邀请，接受率另定。
- 阶段倍率不变：Lv3完成前0.50；Lv3完成后至Lv4完成前0.80；Lv4完成后1.00。按已完成milestone切换，不按熟悉度数值自动切换。
- 同台成功合作收益 = max(4, 对应手术基础收益 × 当前倍率)。最低+4仅用于芹香的同台手术熟悉度，不修改所有角色或病例经验。
- 约会等其他通用收益仍按当前倍率与既有规则计算，不套用手术最低+4。

| 互动 | Lv3完成前×0.50 | Lv3完成后×0.80 | Lv4完成后×1.00 |
|---|---:|---:|---:|
| 影像室讨论（固定例外） | +3 | +3 | +3 |
| 普通手术，基础+5 | +4 | +4 | +5 |
| 高级手术，基础+10 | +5 | +8 | +10 |
| 顶级手术，基础+15 | +7.5 | +12 | +15 |

小数保留／取整复用全局规则；不得仅因表中+7.5另造取整制度。正常收益还遵守全局有效合作判定与100上限。

### 同日独立结算与实施注意

- 当天可以先讨论+3，再邀请她开刀并获得同台收益；不新增“一天只能增加一次芹香熟悉度”的总锁。
- 每日讨论记录、每日出场判定与手术完成结算是不同状态。讨论不能标记她全天不可邀请；也不强制两项必须组合。
- 不额外发放组合奖励、不重复增加术式经验／声望；各自使用各自时间成本。
- 人物专属固定收益、同台收益下限与通用倍率需明确分支，避免相加后统一乘0.5或重复结算。
- 从0仅靠讨论，Lv1／Lv2／Lv3分别需累计4／9／14次有效讨论；70%出现率下平均尝试约5.7／12.9／20个可访问日，不包含其他gate等待。
- 通常9次讨论到27，Lv2后讨论+普通同台合计至少7，两次组合可到41；仍需前级事件、冷却、Lv3技术60及剧情前置。

这些是设计规则，不代表功能已实现；工程需验证每日状态持久化、当天重复进入、读档、倍率切换、同日讨论与手术两次独立结算。

## Relationship Gate Matrix

| 阶段 | Familiarity | Surgery（坂口） | Leadership（坂口） | 关系／剧情前置 |
|---|---:|---:|---:|---|
| Lv1 | 10 | 无 | 无 | 已正式相识 |
| Lv2 | 25 | ≥50 | 无 | 已完成Lv1 |
| Lv3 | 40 | ≥60 | 无 | 已完成Lv2；事件引入纯剧情人物奈奈美，具体剧情身份待定；完成后倍率升0.80 |
| Lv4 | 55 | 无新增 | 无 | 已完成Lv3；朝仓Lv3；奈奈美到来后的冲击事件 |
| Lv5 | 75 | ≥75 | ≥65 | 已完成Lv4；完成奈奈美救治、芹香重新主刀的关键事件 |

- 所有等级逐级完成。Lv4表格「无新增」不是撤销前级已取得的关系成果。
- 不新增Charm、Clinical Presence方向锁或更高Reputation关系锁；相识已经有两档声望，后续难度主要来自慢成长与人物联动。
- Lv2／Lv3技术是她从病例讨论认可坂口专业能力的底线，不要求她早期主刀。
- Lv4朝仓Lv3的帮助与正式相识朝仓Lv1作用不同：前者支持理解深层心结，后者只帮助初步接近。
- Lv5的Surgery75／Leadership65检查坂口可靠担任助手、协助组织团队的能力。芹香主刀，不能改成坂口替她完成全部救治。
- 技术等条件不足时，暂不触发这条关键救治事件，不生成一名已危急却因好感不足而无人救治的患者，也不增加失败／死亡／永久锁线分支。
- 检查属性、熟悉度与必要前置后进入救治milestone；该事件完成后才授予Lv5。具体调度还需与剧情结构统一，避免「先Lv5才允许触发升Lv5事件」循环依赖。

## Story Milestones / 当前方向

### Lv1–Lv2：可靠的影像医生、回避的外科医生

通过读片、病例讨论认识她。她会认真指出漏诊风险，偶尔下意识谈起切口与操作路径，随后停止：「你们外科自己决定。」能力仍在，主动退缩的原因逐渐显露。具体五级对白尚未写完。

早期熟悉度通过正式相识后的影像室病例讨论获得；完成Lv2后开放助手邀请。渠道与收益见本节2026-10-06特殊规则，不可只靠同台手术，也不据设计宣称已实装。此前讨论的「只愿站助手位、关键时刻本能救场」为可使用的铺垫素材，不另设未获确认的硬锁。

### Lv3：奈奈美到来

她对坂口建立信任，触发堀内奈奈美引入／再会事件，成长由0.50升至0.80。最初提议为入职，但现已保持身份开放：访客、患者或护士方案均未最终确定。不得再把「奈奈美入职」作为已锁定的触发结果。她与芹香的具体原作关系及个人背景需后续核实。

### Lv4：奈奈美带来的冲击、朝仓的帮助

奈奈美的到来让芹香无法继续假装自己的退缩只影响自己。她可能因为怕让人失望而更冷淡；朝仓帮助坂口理解这份反应。芹香第一次明确表达希望有人留下，而不只是「你想怎样都可以」。可衔接成年亲密剧情，但具体场景留待写作。事件完成后倍率升至1.00。

### Lv5：为了奈奈美重新拿起手术刀

当前接受的高潮方向：奈奈美需要紧急手术，芹香依靠对影像、病情的判断与仍在的外科技能主动承担主刀；坂口担任助手，朝仓可提供现场支持。通过早期表现铺垫能力，不让其他医生为了剧情突然失去能力，也不以「全院只有她能救」为默认。

她可能先说「我已经不做手术了」，然后决定：「准备手术室。坂口医生，这台……请你帮我。」救治体现她重新愿意珍惜某个人、承担责任，而非被他人强迫恢复主刀身份。

救治具体术式、病因、麻醉与阵容待定；遵循星见手术无永久不可逆损害的世界规则。救治完成是Lv5关系高潮；Staff-as-Patient／教学练习可作后续，非抢占高潮的必经第二场事件。她之后是否全面恢复外科排班，暂未确认。

## 堀内奈奈美 / Background Character Status

**锁定为纯剧情人物。** 她不进入普通人物、医护、手术队伍、约会或可攻略名单，不设计五级关系gate或普通熟悉度曲线。工程预留稳定的剧情actor_id；保留她作为芹香路线持续出场的人物，并为救治事件建立必要的日常关系与自身诉求。未来若扩展为普通角色，沿用同一actor_id追加档案，不改写既有事件身份。

用户提出「要不要干脆作为患者」：记录为**待讨论选项**。若采用，可将Lv3入职改为患者引入／再会，保留Lv4冲击与Lv5救治结构；但应有病房日常和稳定出场，不是一次性随机手术患者。不得在本轮直接确认护士／医生身份、患者身份或与芹香的亲属关系。

## 2026-10-05补充：继承医院、父亲与奈奈美的来意

**已确认的动机：奈奈美来劝芹香回旧医院，承担继承人的位置。** 「回去」不是泛指回到外科，也不默认指回星见。芹香原本是旧医院继承人，奈奈美认为她应当回去继承医院有明确、可以理解的理由。

芹香可能无法面对父亲，这是用户提出的心结方向；究竟是羞愧、怨恨、失望，还是无法承受期待，尚未决定。不得擅自确定父亲的态度、病情、死亡或持续等待她等细节。继承人身份、父女关系与回避主刀相互关联，但不要仅归结为她讨厌外科。

奈奈美的劝说可以真诚而直接，恰好触及芹香最不愿面对的责任；她不一定知道全部旧院内情。Lv4的冲击来自过去的现实要求重新来到眼前，不只来自突然出现一个新同事。朝仓帮助坂口理解芹香为何难以回答。

重新拿刀救治奈奈美是她恢复主动承担医生责任的高潮，**不自动等于答应回去继承医院、辞职离开星见或全面恢复外科排班**。她可以在这之后才开始认真考虑父亲和旧院，而不是继续回避。最终继承决定与是否作为结局内容尚未定。

### 奈奈美的剧情身份：保持开放

用户确认暂不开放攻略，也指出护士身份会增加写作难度；患者方案较省系统，但若专程来劝回去，长期住院需要额外理由。因此暂不锁定以下方案：

- **访客**：专程到星见找芹香、可能反复来等，最直接承接劝她回旧院的动机。是讨论建议，未最终确认。
- **真实患者**：有实际诊疗需要，可持续出场；病情与来院理由待定，不直接宣布已经长期住院。
- **假扮患者／借挂号接近**：用户提出的星见恶趣味选项。她发现私人见面被拒，尝试借诊疗接近芹香，芹香却识破或只按公事接待。可兼具笑点与哀伤；是否采用、是否需要已有症状及科室安排待定。
- **入职／护士**：仅保留为未来故事身份候选；当前系统身份仍是纯剧情人物，不加入医护名册。

假扮患者如果使用，可作为一次接近失败的小事件；不要自动推导为为了接近芹香故意制造真实急症、故意受伤，或为了把谎言演下去而直接安排最后的急诊手术。它与Lv5真实救治如何衔接仍待设计。

本轮补充只更新背景与身份选项，**不改变已归档的声望、朝仓关系、熟悉度和五维Gate**。

## Pending Before Implementation

- 朝仓已形成2026-10-06方案，见12F；她Lv1／Lv3不反向依赖芹香的相识／Lv4，避免联动循环锁。
- 奈奈美作为纯剧情人物时的具体故事身份、与芹香的关系、来院动机、具体病情与救治术式。
- 影像室、熟悉度与Lv2助手入口按上述特殊规则接入；Lv3后的约会接受率、外科能力与回归后的玩法仍待定。
- 走廊／休息室／天台调度，Lv3引入、Lv4冲击与Lv5救治的完整脚本与flags。
- 本节Gate可作为后续设计依据；不能据此宣称整条路线已具备完整实装材料。

---

# 12F. 朝倉美幸 / 朝仓美幸 — 2026-10-06关系方案

## 人物与成长方向

复用现有角色nurse_yui与intro_nurse_yui，不创建新人物。她在旧院是经验丰富的正看护士、带班与新人教育者；曾参与对芹香的迫害，星见AU中最终与芹香离开，在这里低调重新开始。原作事实以INGOKU_BYOUTOU_CHARACTER_BIBLE_V1.md为研究依据，离开旧院及星见发展为AU，不将救赎写成原作结局。

核心：外表甜美、能干强势、动作麻利却不总轻柔；有毒舌、坏心眼和轻度S倾向，偶尔露出黑色幽默，当前路线不彻底黑化。甜美是她真实一面，不只是伪装。熟悉以后，旧日班长的威势、急躁、职业自尊、嫉妒和掌握节奏的兴趣逐渐显露；不必每次尖刻后都补反省或道歉，也不以最高关系治好所有缺点。

“没有经验”指没有在星见工作的经验，不是护理新手。她从刻意收敛逐渐敢于展现自己，也敢要求坂口的关注与照顾。进一步黑化只保留未来创作钩子，不添加隐藏黑化值、强制坏结局或现行分支。

## 曲线与Gate

默认门槛10／25／40／55／75。Lv3完整完成前×1.00，完成Lv3后推进Lv4／Lv5为×0.75；按已完成等级切换。不额外添加属性affinity。逐级完成milestone，默认冷却至少3天，无月份锁。

| 级别 | Fam | 其他条件 | 当前事件粗稿 |
|---|---:|---|---|
| Lv1 | 10 | 正式相识 | 「不是这种没经验」：交接混乱中展现实际资历；可提供芹香线索 |
| Lv2 | 25 | Lv1 complete | 「笑容收起来的时候」：新人备皮失误，她训人并接手处理，显露强势与尖刻 |
| Lv3 | 40 | Lv2 complete；指定门诊计数≥5 | 「你以为我以前是什么人？」：承认旧院带班身份与部分过去，保留戒心 |
| Lv4 | 55 | Lv3 complete；指定亲自准备计数≥5 | 察觉坂口偏好、露出坏心眼和私人默契；下班约会与成年亲密占位 |
| Lv5 | 75 | Lv4 complete；坂口Surgery≥70；与她共同完成无麻醉手术≥1 | 「今天轮到你躺好」：患者角色倒转，开放Staff-as-Patient方向 |

Lv3旧Surgery50候选删除；60仅讨论过，未采用。不新增Charm、Presence、Leadership、Reputation或约会次数硬锁。约会作为事件内容，不是Lv4计数之外另一项收费。她Lv1／Lv3不得依赖芹香相识或高级关系。

## 专属计数 — 用户明确指定，不能泛化

1. 门诊：朝仓实际担当门诊护士时，游戏现有“强迫患者脱衣”选项每次有效执行计+1。普通检查、更衣、一般强势对话不能替代。沿用现有选项身份与处理，不凭本文创造新操作。
2. 准备：先在手术团队选择朝仓负责“病房准备”，随后玩家选择“自己给病人做准备”。朝仓作为打下手的护士参与，完成该次准备计+1；可用回应“医生想自己准备？那我打下手”。只指定岗位、不亲自准备、她不在该岗位均不算。
3. 准备按一名患者的一次完整准备结算，不将剃毛、灌肠等子步骤分别累加；重复点击／回看／读档不重复结算同一次已执行操作。
4. 无麻醉：她实际在团队参与并完成的手术计入，不是只旁观，也不能用玩家与她无关的全局次数代替。不自行把局麻或区域麻醉算为无麻醉。
5. 三类经历可在等级未达时提前累计；各等级仍顺序完成。她自己的首次Lv5患者事件不能反过来满足无麻醉合作前置。
6. 字段名称与旧存档迁移待核对工程，使用已有岗位／事件记录及持久化计数；不能虚构旧存档已经满足的次数。

完整五级对白、Lv4成人场景、Lv5术式与麻醉方式仍待细化；以上是gate与事件粗稿，不代表已实现。手术练习沿用项目既有事前约定及无不可逆损害规则。

---

# 12G. 利根川安琪 — 独立定稿同步

权威完整事件文件：HOSHIMI_TONEGAWA_ANGE_RELATIONSHIP_IMPLEMENTATION_V1.md。此处只同步已确认数值，不复制整份对白。

全程Familiarity×1.00，不叠加属性affinity；无Charm、Presence、Reputation、月份或病例次数锁。普通事件冷却至少3天，跨日尾声完成后才升级。职业信任与敬佩路线，轻微暧昧可有，全等级不可H、不可Staff-as-Patient、不可手术练习。

| 级别 | Fam | Surgery | Leadership | 前置 |
|---|---:|---:|---:|---|
| Lv1 | 10 | — | — | 正式相识 |
| Lv2 | 25 | — | — | Lv1完整完成 |
| Lv3 | 40 | ≥65 | — | Lv2完整完成 |
| Lv4 | 55 | ≥75 | — | Lv3完整完成 |
| Lv5 | 75 | ≥80 | ≥70 | Lv4完整完成 |

原文件附带弘子入队bug报告与安琪无关，沿用其独立交接说明，不在这里新增弘子入队等级锁。

---

# 12H. 审计收尾与办公室提示 — 2026-10-06

已确认调整：深山Surgery熟悉度软加成表定稿；御堂Lv3 Clinical Presence固定为+20；所有关系milestone固定最短冷却3天；诗织Lv3／Lv4／Lv5的Surgery为65／75／85、Charm为30／50／70；真奈美本人Surgery skill门槛为60；奈奈美为纯剧情人物；佐伯未达标分支阵容留给专项剧本。

以下仍是内容或工程设计事项，不改变上述已锁Gate：
- 御堂Surgery affinity bonus固定为0／0.10／0.20／0.30／0.40，Presence affinity bonus固定为0／0.10／0.15／0.20／0.30；基础0.50，加法合成，最终clamp为0.50～1.20。
- 弘子Lv4边界信任flag的具体取得流程，避免以事件自己产生的flag阻塞入口。
- 芹香Lv3后的约会接受率、奈奈美的具体故事身份／救治细节及完整新版事件；奈奈美的系统身份已经锁定为纯剧情人物。
- 佐伯是患者，自己的曲线、完整五级gate和手术分支专项审计；武见是隐藏人物，职业解锁缺项单独审计，不直接套普通员工路线。

办公室角色查看界面的解锁暗示为已讨论的后续UI方向：显示当前关系印象、下一等级线索，可展开具体条件与进度；熟悉度已达而gate不足时明确提示。未认识角色与未发生剧情避免提前泄露。提示文案、字段绑定与完整UI尚未定，不据此宣称已实装。

# 13. Current Build Diversity Snapshot

当前主要路线已经形成明显 Build 分化：

```text
深山佳織
→ 泛用 / 中等 Surgery

御堂江美子
→ 高 Surgery + 强势 Presence

Artoria / Saber
→ 高 Leadership

石神千鹤
→ 广泛护理信任 + Surgery / Leadership

城宮明日香
→ 高 Charm；最终只需中等 Surgery

南条小夜香
→ 高 Familiarity 增长；极低 Charm / Surgery 门槛
→ 最容易体验 Romance / H / Staff-as-Patient / Teaching Surgery

折川皐月
→ 温和 Presence 主轴；低 Surgery 只作医疗托付底线

杉村弘子
→ 初期正常熟悉；越接近亲密越减速
→ Lv3 轻度温和 Presence；Lv4 Boundary Trust；Lv5 Surgery70

中井美佳
→ 初期正常熟悉；随亲密递减，Lv4后不反弹
→ Lv3 / Lv4 中低Charm；Lv5 Surgery70 + Leadership65
→ 喜欢与身体托付均不解锁过去

水城Aqua
→ 妇科 / 女性生殖系统专精
→ 妇科病例数量同时提高 Familiarity multiplier 并作为逐级硬门槛
→ Lv2 子宫全切教学；Lv4 Surgery70；Lv5 Surgery80

神宮寺成美
→ 固定×0.80；中等Surgery + 适度威压 + 轻度Leadership
→ Lv3入职背景；Lv4约会陪伴；Lv5共同研究与患者托付

御園芹香
→ 声望50／100的相遇＋朝仓Lv1解锁相识；0.50→0.80→1.00
→ 朝仓Lv3支持高级关系；奈奈美联动推动外科回归，Lv5Surgery75／Leadership65

七瀬恋
→ 固定×0.90；Lv3起Presence＜+30；Surgery60／60／70
→ 弘子Lv4开启亲密；弘子Lv5＋武见解锁开启双看板娘二重手术
→ 高级联动投入与气场转向成本已接受；完整脚本待细化

飯村真奈美
→ 固定×1.30；前期易熟络，Lv3一次单独约会，Lv4魅力得体
→ Lv5本人手术技术＋一次无麻醉助手经历；药学研究与本人试药事件

本庄萌恵
→ 初期害羞慢热，每级熟悉度收益加速
→ 轻度亲和倾向 + 低技术要求；仅Lv5新增Leadership65
→ 弘子器械事件共用Lv1；后续护士群像事件暂留粗稿
```

设计目标：

> **正常一周目不应轻松攻略所有角色。**

但不要依赖显式路线互斥。优先通过：

```text
五维 Build
Familiarity affinity
角色专属 hard gate
自然时间成本
```

形成真实取舍，从而支持多周目。

---

# 14. Remaining Roster

现有常驻角色均已讨论路线结构；朝仓本轮归档于12F。尚未定值、特殊触发与单独患者／隐藏人物审计见12H，不以本段宣称所有条件已精确敲定。

利根川安琪的曲线、Gate与五级事件已在此前讨论完成；原待审名单中的名字是旧条目残留，本轮移出。数值已在12G同步；完整脚本仍读取独立实施文档，不在此重新设计。

伊吹摩耶／佐仓双叶目前为Lv0-only professional guest，不列为普通五级攻略待审对象。堀内奈奈美为纯剧情人物，不进入医护或可攻略名单，详见12E。

### 樱花 — 高级手术职业角色 / 当前关系暂缓

2026-10-05已确认：麻醉科主任，高级手术池首次教学病例正式登场；每次高级手术固定参加，普通手术不可邀请。当前不开放关系路线，移出“等待普通五级gate审计”的名单。

未来有时间再开放关系，成长完全按与坂口的高级手术合作次数设计，不额外叠加普通Familiarity门槛。具体次数阈值、计数边界、事件和是否发展私人／恋爱／成人关系均未定。本轮不新增数值、月份锁或自动解锁奖励。详细角色方向见 `HOSHIMI_DESIGN_IDEA_BACKLOG.md` 的IDEA-003。

神宮寺成美与七瀬恋已完成曲线与Gate Review，见12A／12B；两人的Lv1–Lv2事件及完整脚本仍待细化。

藤崎詩織已记录固定0.85曲线与获认可的各级Gate结构，见12C；Lv4／Lv5魅力与声望已确认；剩余工作是Lv3技术与魅力门槛校准，以及五级事件正文，不再列作尚未开始的逐人审计。

飯村真奈美已完成固定1.30曲线与各级Gate方向审计，见12D；Lv3一次单独约会、Lv4魅力「得体」、Lv5本人技术及一次无麻醉助手经历已确认。本人技术数值、字段映射与完整脚本仍待细化。

御園芹香已归档相识流程、0.50→0.80→1.00曲线及Gate，见12E；正式相识需要朝仓Lv1，高级关系需要朝仓Lv3。堀内奈奈美锁定为纯剧情人物；具体故事身份与完整脚本待讨论。

其余角色逐人讨论后追加本文件。

# END
