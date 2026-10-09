# Hoshimi Hospital — 遥凑 Character Bible / Relationship Route / Intro Event
## Haruka Minato / ハルカ・ミナト
### General Surgery / Forgetful Doctor / Sunday Surgery Introduction

> **文件性质：Canonical Character Bible + Relationship Route Design + Codex Event Specification**
>
> **稳定文件名：**
>
> `HOSHIMI_HARUKA_MINATO_CHARACTER_BIBLE.md`
>
> **用途：**
>
> - 正式锁定遥凑在 Hoshimi Hospital 的 AU 人设；
> - 锁定 Familiarity 曲线与 Relationship Lv0–Lv5 Gate；
> - 锁定她与坂口的相识机制；
> - 详细保存 Intro 剧情手术《十点二十分》；
> - 锁定艾莉娜·金城·王 / Erina Kinjo Won 的剧情患者身份；
> - 作为后续 Codex 实装、事件脚本细化与美术需求的共同依据。
>
> **优先级：**
>
> 本文件若与更早聊天摘要、旧 Backlog 草案或旧人物候选发生冲突，以本文件为准。
>
> Gate 数值仍需与最新版：
>
> `HOSHIMI_CHARACTER_RELATIONSHIP_GATE_MATRIX.md`
>
> 保持同步。

---

# 0. Canonical Identity

```yaml
character:
  chinese_name: 遥凑
  english_name: Haruka Minato
  japanese_name: ハルカ・ミナト
  source: 機動戦艦ナデシコ / 机动战舰抚子号

hoshimi_au:
  adult: true
  staff_role: doctor
  department: general_surgery
  specialty_style:
    - open_surgery
    - routine_general_surgery
    - patient_communication
  romanceable: true
  staff_as_patient: late_route
```

中文统一：

> **遥凑**

不要写成：

> 遥南

`ミナト = Minato`，本项目固定使用“凑”。

---

# 1. Core Character Concept

一句话：

> **遥凑是一个很会记住“人”，却极容易忘记“接下来要做什么”的成年女医。**

她的核心反差不是：

```text
笨
医术差
天然医疗事故制造机
连病例都记不住
```

而是：

```text
clinical / procedural memory
→ 强

patient memory
→ 强

social / person memory
→ 强

prospective memory
→ 很差

schedule / date / appointment memory
→ 很差

handoff confirmation memory
→ 容易掉链子
```

也就是说，她可能：

```text
记得患者三周前说过什么
记得某次影像里一条异常血管走形
记得患者怕哪一种术后不适
记得坂口随口提过的私人小事
```

却会：

```text
忘记今天星期几
忘记下午有会
忘记自己刚刚为什么走进护士站
忘记把东西放在哪里
忘记某件事到底有没有已经告诉别人
忘记约会日期
```

最高原则：

> **“健忘”不能被写成“专业不可靠”。**

真正上台以后，她应当明显可靠。

---

# 2. Hoshimi AU Professional Position

推荐锁定：

```yaml
department: 普通外科 / General Surgery
clinical_level: reliable_mid_to_high
elite_specialist: false
leadership_archetype: false
generalist_archetype: false
teaching_mad_doctor: false
```

她不是：

```text
御堂式顶级独狼术者
Saber式团队统帅
Aqua式妇科顶级专家
武見式非常规怪医
小夜香式全系统generalist
```

她的价值是：

> **普通开放外科手术做得很稳，患者沟通也很好，但行政 / 排程 / 交接方面需要可靠系统兜底。**

星见医院默认不采用：

```text
腹腔镜
腔镜
机器人
其他微创路线
```

遥凑本人也以开放术式为正常工作方式。

---

# 3. Personality

关键词：

```yaml
tags:
  - mature
  - relaxed
  - feminine
  - socially_skilled
  - warm
  - observant_about_people
  - caring
  - lightly_teasing
  - forgetful
  - clinically_reliable
  - low_drama
```

她不是百合香式：

> 理解世界本身经常跑偏。

遥凑更准确的是：

> **她非常懂人，但不懂日历。**

她通常：

```text
会察觉患者害怕
会察觉同事累
会记住别人喜欢什么
会自然安慰人
会把关系维持得舒服
```

但也会出现：

```text
“我的手机呢？”
→ 在白大褂口袋

“今天几号？”
→ 刚刚看过日历

“我是不是还有什么事？”
→ 有，而且已经迟到了
```

不要把她写成幼态天然呆。

她是：

> **成熟的成年女性 + 很真实但夸张化的 prospective-memory 弱点。**

---

# 4. Relationship Route Theme

表层：

> 健忘女医喜剧。

深层：

> **可靠不等于一个人必须永远记住一切。**

人物弧：

```text
Lv0
→ “这人到底靠谱吗？”

Lv1
→ “她只是记忆结构很奇怪，上台非常可靠。”

Lv2
→ 她的弱点第一次真的造成严重流程事故。

Lv3
→ 坂口不替她当人形闹钟，而是帮她建立不会单点失效的工作系统。

Lv4
→ 她会忘约会，却记得坂口很久以前说过的小事。

Lv5
→ 她甚至忘了自己今天是患者，却没有忘记为什么选择坂口。
```

核心感情逻辑：

> **她喜欢的是一个知道她会忘、会提醒她，却不会因此把她当笨蛋的人。**

---

# 5. Familiarity Curve — LOCKED

标准 Familiarity milestone：

```text
Lv1 10
Lv2 25
Lv3 40
Lv4 55
Lv5 75
```

阶段倍率：

| 当前阶段 | Familiarity Gain Multiplier | 设计意义 |
|---|---:|---|
| Lv0 → Lv1 | ×1.20 | 很会社交，很容易和人熟起来 |
| Lv1 → Lv2 | ×1.20 | 一起开刀以后熟得仍然很快 |
| Lv2 → Lv3 | ×0.90 | 大事故后短暂过度谨慎、拘谨 |
| Lv3 → Lv4 | ×1.10 | 流程修复后重新放松 |
| Lv4 → Lv5 | ×1.25 | 正式亲密后对坂口非常自然 |

倍率按：

> **已经完成的 Relationship Level**

切换。

不是 Familiarity 数值达到门槛就提前换倍率。

---

# 6. Shared Surgery Counter — LOCKED

字段方向：

```text
completed_surgeries_with_minato
```

计数：

```text
坂口与遥凑实际共同参加并完成同一台手术
→ +1

取消 / 中止 / 未完成
→ +0
```

Intro《十点二十分》：

> **明确算第一次共同完成的手术。**

前两级路线应主要通过：

> **一起开刀**

自然推进。

不要额外要求：

```text
反复喝咖啡
大量办公室闲聊
单独刷小事件
```

---

# 7. Relationship Gate Matrix — LOCKED

| 阶段 | Familiarity | 其他 Gate | 冷却 | Month Gate |
|---|---:|---|---:|---|
| Intro / Lv0 | — | 完成10台正式手术后，首次符合条件的周日主动前往医院，完成《十点二十分》 | — | 无 |
| Lv1 | 10 | `completed_surgeries_with_minato >= 1` | ≥3天 | 无 |
| Lv2 | 25 | Lv1 complete；`completed_surgeries_with_minato >= 2` | ≥3天 | 无 |
| Lv3 | 40 | Lv2 complete；Leadership ≥55 | **≥5天** | 无 |
| Lv4 | 55 | Lv3 complete；Charm ≥30 | ≥3天 | 无 |
| Lv5 | 75 | Lv4 complete；Surgery ≥65；**Leadership ≥60 OR Clinical Presence ≤ -20** | ≥5天 | 无 |

Milestone 触发规则：

```text
Lv2 的表内条件满足
→ 触发《下午三点的患者》
→ 完成该事件
→ Relationship 升至 Lv2
```

因此：

> **“完成《下午三点的患者》”不是 Lv2 Event 的入口 Gate，而是 Lv2 的 milestone completion / 升级结果。**

重要：

```text
Lv5:
Leadership >=60
OR
Clinical Presence <= -20
```

必须是 **OR**。

禁止错误实现成：

```text
Leadership >=60
AND
Clinical Presence <= -20
```

`Clinical Presence <= -20` 仍属于全局“平衡型”范围，只代表轻微向可亲 / 温和方向倾斜。

不要提高到折川皐月那种明显温和端 Gate。

---

# 8. Introduction Unlock — LOCKED

## 8.1 Arming Condition

当坂口累计完成：

```text
completed_surgeries_total >= 10
```

且：

```text
minato_intro_complete == false
```

则设置：

```text
minato_intro_armed = true
```

达到条件当天：

> 不立即强制触发。

---

## 8.2 Sunday Trigger

Intro 利用星见既有节奏：

> **正常情况下，周日医院没有普通门诊，也没有玩家排定的普通手术。**

因此：

```text
minato_intro_armed == true
+
Sunday
+
玩家主动选择“去医院”
↓
触发《十点二十分》
```

如果玩家周日：

```text
约会
外出
休息
不去医院
```

则：

```text
minato_intro_armed 保留
```

等待下一个玩家主动去医院的周日。

不要：

```text
抢走玩家已经安排的 Sunday Date
强制取消玩家周日计划
完成第10台以后第二天无条件触发
```

遥凑不是结构核心 NPC，不需要 guaranteed immediate appearance。

---

## 8.3 Full-Day Sunday Scope — LOCKED

《十点二十分》现在定义为：

> **全天 Sunday Story Event。**

它不是：

```text
3小时 gameplay cost
+
2小时 Epilogue cost
```

也不要再把剧情内钟点与 UI 小时数强行换算。

系统语义统一为：

```text
time_scope = full_sunday
consumes_entire_sunday = true
return_to_sunday_free_action = false
```

事件内部仍保留真实感较强的剧情钟点：

```text
周日早晨
→ 艾莉娜被突然叫醒并完成术前准备

10:20左右
→ 开始开腹胆囊切除

中午至下午
→ 清醒手术继续
→ 约14:40已回病房并赶上棒球转播

下午至傍晚
→ 坂口与遥凑换回常服
→ 吃东西 / 散步 / 松弛地消磨剩余周日
```

这些钟点属于：

> **剧情内部 chronology。**

它们不再要求与一个“consume_time(3h)”的 UI 数值逐小时对应。

事件一旦开始：

```text
进入 Story Episode Lock
当天不再开放普通 Sunday Date / 自由行动 / 新病例
剧情连续完成到遥凑与坂口傍晚分别
然后按现有整日剧情事件 / 日终流程结束周日
```

设计理由：

- 从艾莉娜周日早晨被突然准备，到下午手术结束，本来就已经横跨大半天；
- 手术后坂口又和遥凑一起度过剩余下午 / 傍晚；
- 玩家实际上已经把整个周日给了这场 Intro；
- 把它写成“3h + 2h”反而会制造 UI 时间与剧情钟点冲突；
- 全天事件更符合“这一天就是遥凑登场日”的体验。

不调用 Sunday Date System。

Relationship 仍停留在 Lv0。

Epilogue 也不额外奖励 Familiarity。


# 9. Intro Event
# 《十点二十分》

```yaml
event_id: minato_intro_1020
event_type:
  - introduction
  - scripted_surgery
  - sunday_event
  - medical_dark_comedy
  - crossover_patient

time_scope: full_sunday
consumes_entire_sunday: true
return_to_sunday_free_action: false
internal_clock_is_narrative: true
uses_standard_surgery_runner: false
random_case_pool: false
fixed_success: true
relationship_result: unlock_lv0
```

核心一句话：

> **遥凑把艾莉娜原定周一的择期手术记成了周日，结果患者真的被一大早拉起来准备；等准备到一半，遥凑才发现星期日根本找不到正常助手，于是把恰好来医院的坂口直接抓进手术团队。**

---

# 10. Story Patient — 艾莉娜·金城·王

```yaml
patient:
  chinese_name: 艾莉娜·金城·王
  english_name: Erina Kinjo Won
  japanese_name: エリナ・キンジョウ・ウォン
  source: 機動戦艦ナデシコ / 机动战舰抚子号
  adult: true
  role: scripted_patient
  romanceable: false
  staff: false
```

她不是：

```text
遥凑亲属
遥凑恋人
遥凑多年挚友
特殊主线人物
```

她只是：

> **遥凑以前看过、彼此已经认识的一名普通成年患者。**

但她的性格适合当遥凑 Intro 的“反应器”：

```text
计划性强
头脑清楚
不喜欢别人浪费时间
会直接指出流程矛盾
即使成为患者也不会突然软掉
```

本事件中她已经住院，因此“周日下午要看棒球”统一指：

> **在病房电视上看预定的棒球转播。**

不是：

> 去球场现场观赛。

这个细节应在对白和旁白中保持一致。

因此她能最大程度放大遥凑的排程问题。

---

# 11. Erina Medical Setup — LOCKED

诊断：

```text
symptomatic cholelithiasis
胆囊结石 / 胆石症
```

患者口语：

> **胆结石手术**

正式术式：

```text
open cholecystectomy
开腹胆囊切除术
```

原计划：

```text
Monday 10:20
择期手术
```

遥凑错误记录：

```text
Sunday 10:20
```

麻醉：

```text
scripted thoracic epidural
剧情指定胸段硬膜外麻醉
patient_awake = true
```

这是一场：

> **剧情指定的清醒开放手术。**

不要自动改变普通 Surgery Runner 的 Epidural coverage 规则。

---

# 12. Consent Rule — LOCKED

艾莉娜此前已经：

```text
完成门诊评估
完成术前检查
正式住院
签署该手术的既有手术同意
进入等待择期开刀阶段
```

因此：

> **日期从周一错误提前到周日，不需要重新举行一次 consent 流程。**

本事件不要插入：

```text
“是否重新同意今天做”
“是否重新签字”
“医生重新征求一次完整手术许可”
```

她可以：

```text
非常意外
不情愿
惊恐
抱怨
质问
强调今天有自己的安排
```

但这些默认表达的是：

> **“为什么日期突然变了？”**

不是：

> **稳定、清醒、持续撤回对这台手术本身的既有同意。**

若未来脚本真的让患者明确、持续、理解地撤回手术，则才属于项目层面的真正 withdrawal。

本事件不走该分支。

---

# 13. Intro Script — Scene 1
## Sunday Early Morning / Ward

### 场景目标

先从艾莉娜视角制造：

> **“我今天根本没准备开刀！”**

而不是直接从坂口认识遥凑开始。

---

### Scene Start

周日早晨。

医院比工作日安静。

艾莉娜还在病房睡觉。

房门打开。

周末值班护士推着术前用品进来。

护士：

> 「金城小姐，早上好。」
>
> 「醒一下，开始准备了。」

艾莉娜半睡半醒：

> 「……什么准备？」

护士：

> 「手术准备。」

艾莉娜睁开眼。

停一拍。

> 「什么？」

护士：

> 「十点二十分手术。」

艾莉娜猛地坐起来。

> 「今天？！」

护士：

> 「是。」

艾莉娜：

> 「我的手术是明天！」

护士看手里的排程。

> 「这里写的是今天。」

艾莉娜：

> 「那是排程错了！」

护士再次确认。

> 「Sunday，10:20。」

艾莉娜：

> 「十点二十分是时间！」
>
> 「重点是日期！」

---

# 14. Scene 2
## “今天有我要看的棒球转播！”

护士一边联系手术部确认，一边已经非常熟练地按星见既有术前流程继续推进准备。

重要：

> **护士并没有因为“患者觉得日期不对”就停在门口等待遥凑回来解释。**

在她们看来：

```text
患者已经正式住院
手术已经有既有同意
OR排程上写着今天10:20
主刀本人也已经到院
```

所以流程自然继续。

不要把护士写得粗暴或混乱。

正确感觉是：

> **她们非常专业、非常麻利，而且正因为太麻利，艾莉娜才越来越绝望。**

---

## 14.1 Preparation Montage — LOCKED

这部分建议做成短促的剧情蒙太奇，不进入额外 Gameplay。

按照星见既有住院术前文化完成：

```text
晨间确认
↓
灌肠
↓
术野备皮
↓
换成手术患者状态
↓
完全遮发的患者手术帽
↓
等待转送
```

不要把每一步写成长篇检查教程。

演出重点是：

> **护士侧：今天就是正常术前准备。**
>
> **艾莉娜侧：我为什么星期日早上突然正在经历这一整套？**

可以用数个短 beat：

护士：

> 「侧一点。」

艾莉娜：

> 「等一下，我还是要说，我的手术——」

护士：

> 「明白，金城小姐。」
>
> 「遥医生那边正在确认。」

下一步依然继续。

稍后。

艾莉娜明显已经没有刚醒来时那种气势。

> 「……所以真的连这个也要今天做？」

护士：

> 「要上台就要准备好。」

艾莉娜：

> 「我本来今天只是想看电视……」

护士：

> 「头抬一点。」

手术帽戴好。

---

## 14.2 Minato Arrives After Prep

遥凑进入病房时：

> **艾莉娜的术前准备已经基本完成。**

她此刻应该有一点“被整个医院流程碾过去以后”的虚脱感：

```text
已经被灌肠
已经完成术野备皮
已经换成患者状态
头发完全收入手术帽
已经知道自己真的快被送去OR
```

她不是哭得很惨，也不是失去行动能力。

更准确的是：

> **人还清醒、嘴也还很硬，但精神上已经从“你们搞错了”进入“我为什么今天真的要经历这些”。**

遥凑推门进来。

> 「早啊，Erina。」

艾莉娜慢慢把视线转过去。

> 「……遥医生。」

这里的语气应该比前面护士刚进门时更危险。

遥凑：

> 「睡得好吗？」

艾莉娜看了她几秒。

> 「本来可以。」

遥凑：

> 「？」

艾莉娜：

> 「我今天一早已经做完灌肠、备皮、换好衣服。」
>
> 「现在还戴着这个。」

她碰一下自己的手术帽。

> 「而我的手术，本来是明天。」

停顿。

> 「你觉得我睡得好吗？」

遥凑这才第一次认真看墙上的日期。

> 「……啊。」

艾莉娜：

> 「不要‘啊’！」

她此时已经完全确认：

> **这一切真的是遥凑把日期记错以后发生的。**

---

### Baseball Beat — LOCKED

艾莉娜被折腾成已经准备上台的样子以后，越想越不甘心。

她：

> 「而且我今天有安排！」

遥凑：

> 「什么安排？」

艾莉娜：

> 「我今天下午还有棒球转播要看！」
>
> 「我本来就打算在病房安安静静看电视。」

遥凑：

> 「几点？」

艾莉娜：

> 「下午三点。」

遥凑马上计算。

> 「那没关系啊。」

艾莉娜：

> 「什么叫没关系？」

遥凑：

> 「十点二十分开始。」
>
> 「三点以前早就结束了。」

艾莉娜：

> 「不是这样啦！」

遥凑想了一下，以为自己找到了真正的问题。

> 「而且你又不是全麻。」

艾莉娜：

> 「……？」

遥凑：

> 「硬膜外的话一直醒着。」
>
> 「完全不耽误看棒球。」

艾莉娜：

> 「我担心的根本不是会不会睡着！」

遥凑：

> 「那是什么？」

艾莉娜：

> 「我今天本来就没打算被开胆囊！」

遥凑：

> 「但是明天本来也要开。」

艾莉娜：

> 「差一天差很多好吗！」

遥凑继续非常认真地解决实际问题：

> 「就是开完以后肚子上会有伤口。」
>
> 「看到逆转全垒打的时候别太兴奋就好。」

艾莉娜：

> 「为什么你已经开始替我规划看球姿势了？！」

---

# 15. Scene 3
## Sunday OR Problem

艾莉娜的术前流程继续推进。

遥凑离开病房，来到手术部。

值班护士检查当天临时被激活的 OR。

护士：

> 「遥医生。」

遥凑：

> 「嗯？」

护士：

> 「第一助手呢？」

遥凑：

> 「……」

她看排班。

再看一次。

> 「今天谁在？」

护士：

> 「普通外科正常排班？」
>
> 「没人。」

遥凑：

> 「为什么？」

护士看她。

> 「因为今天星期日。」

遥凑：

> 「……哦。」

---

# 16. Scene 4
## Sakaguchi Arrives at Hospital

与此同时：

> 坂口在周日主动选择“去医院”。

医院明显比平时安静。

没有普通门诊队列。

走廊里却出现：

```text
手术部人员
准备中的推床
周末值班护士
```

坂口：

> 「……今天有急诊？」

值班护士：

> 「不是。」

坂口：

> 「那为什么有人准备手术？」

护士：

> 「……这件事有点复杂。」

这时遥凑从手术部出来。

她看到坂口。

停住。

像突然找到救生艇。

> 「坂口医生！」

坂口：

> 「……我们认识吗？」

遥凑走过来。

> 「会当第一助手吧？」

坂口：

> 「会。」

遥凑：

> 「太好了。」
>
> 「救命。」

坂口：

> 「等一下。」
>
> 「你是谁？」

遥凑：

> 「遥凑。」

她已经开始往更衣区方向走。

> 「今天我主刀。」

坂口：

> 「今天不是星期日吗？」

值班护士从旁边经过：

> 「她刚知道。」

---

# 17. Scene 5
## Forced Story Team

本事件不进入普通 Team Builder 自由选择。

固定：

```yaml
primary_surgeon: Haruka Minato
first_assistant: Sakaguchi
scrub_nurse: Megumi Reinard
patient: Erina Kinjo Won

anesthesia:
  route: scripted_thoracic_epidural
  onscreen_character_required: false
```

本事件为纯剧情手术，不模拟完整标准 OR 编制。

明确：

```text
不显示 / 不建模巡回护士（本事件不出场）
不打开 Team Builder
不要求凑齐普通手术的全部岗位
不因为缺少巡回角色阻塞剧情
```

镜头与对白中心只保留：

```text
遥凑
坂口
惠
艾莉娜
```

麻醉功能作为剧情既定背景存在即可；不需要额外引入有名麻醉角色。

重要：

> **不要在这里提前使用樱花。**

樱花的首次正式出场仍属于 Advanced Referral 千束教学病例。

---

# 17A. 惠 / Megumi Reinard — Story-Only Nurse

```yaml
character:
  chinese_name: 惠
  english_name: Megumi Reinard
  japanese_name: メグミ・レイナード
  source: 機動戦艦ナデシコ / 机动战舰抚子号

hoshimi_au:
  adult: true
  role: nurse
  status: story_only
  relationship_enabled: false
  roster_visible: false
  free_surgery_inviteable: false
```

本事件中，惠是：

> **遥凑长期固定配合的围术期护士。**

她不是坂口的 Personal Nurse，也不要接入现有 Personal Nurse System。

作者侧可以理解为：

> **遥负责记患者，惠负责记遥。**

但不要把惠写成遥凑的保姆或单纯日历插件。

她本身必须是：

```text
专业
动作麻利
熟悉遥凑的手术节奏
会主动推进事情
知道什么时候补位
```

本事件职责：

```text
周日早晨执行艾莉娜病房术前准备
↓
完成灌肠 / 备皮 / 患者状态转换 / 手术帽等既定流程
↓
随后进入 OR 作为 Scrub Nurse
↓
与遥凑表现出长期合作形成的默契
```

她不正式“相识解锁”。

即使坂口在剧情里与她说过话：

```text
met_megumi = false
relationship_megumi = unavailable
```

未来若需要把惠转为常驻角色：

> 另做正式 Introduction Event。

可以回收：

> 「星期日那台胆囊，我记得。」

---

# 18. Scene 6
## Erina Meets the “New Assistant”

艾莉娜已经完成完整的病房术前准备，被送到 Holding。

她看到坂口换好 scrub 出现。

艾莉娜：

> 「他是谁？」

遥凑：

> 「第一助手。」

坂口：

> 「刚刚才是。」

艾莉娜：

> 「……什么意思？」

坂口：

> 「我今天本来只是来医院。」

艾莉娜看遥凑。

> 「你的原助手呢？」

遥凑：

> 「今天休息。」

艾莉娜：

> 「为什么？」

坂口：

> 「因为今天星期日。」

沉默。

艾莉娜：

> 「…………」

她终于完整理解：

```text
自己原定周一开刀
↓
遥凑记成周日
↓
医院周日真的把自己叫起来准备
↓
遥凑到了以后才发现没有正常助手
↓
这个男人是刚刚从医院里抓来的
```

艾莉娜：

> 「我现在非常想知道，你们还有什么事情没告诉我。」

遥凑：

> 「没有了吧？」

坂口：

> 「你不要用疑问句。」

---

# 19. Scene 7
## Pre-OR Character Contrast

进入正式手术准备。

艾莉娜仍然明显：

```text
意外
不情愿
焦虑
不爽
```

但不是稳定撤回手术。

她：

> 「现在几点？」

坂口：

> 「十点零五。」

> 「离十点二十分还有十五分钟。」

遥凑：

> 「很准时吧。」

艾莉娜：

> 「这个时间是你自己写错日期以后留下的唯一正确东西。」

---

# 20. Scene 8
## Scripted Epidural

这部分是剧情演出。

不进入：

```text
Optional Palpation HUD
Anesthesia Sensory Test HUD
Surgery Runner
```

直接按剧情完成胸段硬膜外。

艾莉娜保持清醒。

她可以继续说话。

遥凑：

> 「很快就开始。」

艾莉娜：

> 「你今天说的‘很快’，我已经不相信了。」

不要把麻醉本身写成随机失败系统。

本事件：

```text
anesthesia_success = fixed
```

---

# 21. Scene 9
## Scripted Open Cholecystectomy

术式：

> **开腹胆囊切除术**

明确：

```text
open procedure
not laparoscopic
not minimally invasive
```

不进入玩家标准手术操作。

可以用：

```text
背景切换
简短术野 CG / 固定演出
角色对白
SFX
少量镜头变化
```

完成。

---

# 22. The Critical Character Reveal

前面遥凑已经表现得像一个排程灾难。

真正开始手术以后：

> **她必须立即变得可靠。**

坂口第一次亲眼看到这个反差。

遥凑：

> 「这里别拉太大。」

坂口调整。

> 「这样？」

> 「嗯。」

她继续：

> 「她上次影像上胆囊颈这里的位置有一点偏。」
>
> 「你注意这个方向。」

坂口：

> 「你还记得？」

遥凑：

> 「当然。」

稍后：

> 「她上次说过术后特别怕恶心。」
>
> 「结束以前跟麻醉那边再确认一下。」

坂口看她。

遥凑：

> 「怎么？」

坂口：

> 「这些你倒全记得。」

她反而觉得奇怪：

> 「这是患者的事啊。」

这句话是 Intro 最重要的人设锚点之一。

---

# 23. Awake Erina Intraoperative Beats

艾莉娜因为硬膜外保持清醒。

她的作用不是医学教学。

她负责：

> **持续提醒所有人，这台手术本来根本不应该今天发生。**

---

### Beat A

艾莉娜：

> 「现在几点？」

坂口：

> 「十一点零五。」

艾莉娜：

> 「很好。」

遥凑：

> 「你看，肯定赶得上。」

艾莉娜：

> 「不要一副这是你计划好的样子！」

---

### Beat B

稍后。

艾莉娜：

> 「还要多久？」

遥凑：

> 「很顺利。」

艾莉娜：

> 「我问的是多久。」

遥凑：

> 「……」

护士：

> 「一点十分。」

艾莉娜：

> 「谢谢。」
>
> 「至少这里还有一个人记得时间。」

遥凑：

> 「我也记得。」

坂口：

> 「你刚刚明明看了钟。」

---

### Beat C

艾莉娜：

> 「你们最好两点半以前结束。」

遥凑：

> 「为什么两点半？」

艾莉娜：

> 「我要回病房。」
>
> 「我要把电视打开。」
>
> 「我要确保三点开赛的时候我不是还在这里。」

遥凑：

> 「放心。」

艾莉娜：

> 「我今天最不放心的就是你。」

---

# 24. Fixed Outcome

本事件固定：

```text
surgery_success = true
crisis = false
abort = false
permanent_harm = false
```

不调用普通 Surgery Failure / Crisis 随机系统。

原因：

> 本事件目的不是考玩家技术，而是介绍遥凑。

---

# 25. Scene 10
## Post-Op / The Baseball Payoff

手术结束。

艾莉娜回病房。

因为不是全麻，她主要是术后疲惫和腹部切口带来的现实不适，不需要写成长时间全麻苏醒。

她第一件事：

> 「几点？」

护士：

> 「两点四十。」

艾莉娜：

> 「电视。」

护士：

> 「先休息一下吧。」

艾莉娜：

> 「棒球转播。」

护士把电视打开。

棒球转播还没正式开始。

遥凑随后进来。

> 「你看。」
>
> 「赶上了吧。」

艾莉娜慢慢转头看她。

> 「今天发生的任何事情。」
>
> 「都不能算你的时间管理成功。」

遥凑：

> 「可是结果一样。」

艾莉娜：

> 「完全不一样。」

---

# 26. Scene 11
## Sakaguchi / Minato Formal Introduction

离开病房后。

遥凑：

> 「今天谢谢。」

坂口：

> 「我是来医院以后才知道自己今天有手术的。」

遥凑：

> 「那不是很巧吗。」

坂口：

> 「完全不是。」

她笑。

> 「不过你配合得不错。」

坂口：

> 「你也是。」

遥凑：

> 「以后可以再一起开。」

她走出几步。

停下来。

回来。

> 「对了。」

坂口：

> 「什么？」

遥凑：

> 「你叫什么来着？」

坂口：

> 「……」

她低头看他胸牌。

> 「坂口。」

坂口：

> 「你刚刚看了。」

遥凑：

> 「我本来就记得。」

旁边护士：

> 「没有。」

这里**不要立刻结束 Intro**。

上午的“手术室里的遥凑”到这里已经建立完成，接下来进入本事件的正式 Sunday Epilogue。

---

# 26A. Sunday Epilogue
# 《今天这个不算约会》

```yaml
event_segment: minato_intro_sunday_epilogue
relationship_level_change: false
extra_familiarity: 0
uses_sunday_date_system: false
time_scope: afternoon_to_early_evening_within_full_sunday_event
independent_gameplay_time_cost: false
fixed_callback_flag: minato_intro_sunday_walk_complete
```

## 26A.1 Purpose

这一段的目标不是让遥凑第一次见面就进入恋爱。

它负责建立一种更细的感觉：

> **两个其实还不太熟、但刚刚发现彼此合作起来很舒服的成年男女医生，在一个意外空出来的周日下午，没有特别目的地一起消磨了两三个小时。**

同时第一次让玩家看到：

> **星见的女医离开病房和手术室以后，也会是很松弛、很迷人的普通成年女人。**

上午的遥凑是：

```text
scrub
手术帽
口罩
手套
开腹手术
清醒患者
临床判断
```

下午的遥凑则是：

```text
常服
头发放下来
没有白大褂
没有排程板
没有下一台手术
没有谁在等她决定
```

这个转换本身就是人物魅力的一部分。

不要把她写成突然“换上约会人格”。

她只是：

> **下班了。**

---

## 26A.2 Transition — 从 OR 到常服

艾莉娜已经被推回病房，电视打开，棒球转播即将开始。

坂口完成最后一点术后工作，准备离开医院。

走廊已经恢复周日的安静。

他刚走到员工区附近，后面有人叫：

> 「坂口医生。」

坂口回头。

停一下。

遥凑已经换掉 scrub。

她穿普通周日常服，头发也恢复平时状态，手里只拿着自己的包。

坂口：

> 「……遥医生？」

她低头看看自己。

> 「为什么是疑问句？」

坂口：

> 「第一次看到你穿正常衣服。」

遥凑：

> 「我平时也穿正常衣服。」

坂口：

> 「我今天第一次见你的时候，你已经在准备开刀了。」

她想了一下。

> 「……好像也是。」

不要让旁白长篇评价她“很漂亮”。

视觉演出本身完成这件事。

最多只允许坂口短暂意识到：

> **和刚才站在术野另一边的人，看起来突然不太一样。**

---

## 26A.3 “你的周日被我占掉一半了”

两人一起往医院出口走。

遥凑：

> 「你今天原本来医院干什么？」

坂口：

> 「没什么。」
>
> 「周日过来看看。」

遥凑：

> 「然后被我抓去开刀。」

坂口：

> 「嗯。」

她有一点不好意思，但并不沉重道歉。

> 「那你的周日算是被我占掉一半了。」

坂口：

> 「差不多。」

她看了一眼外面的天色。

> 「另外一半还在。」

坂口：

> 「所以？」

遥凑：

> 「不知道。」

她很自然地把这个问题扔回来。

> 「你本来打算干什么？」

坂口：

> 「没想好。」

遥凑：

> 「那正好。」

坂口：

> 「什么正好？」

> 「我也没想好。」

停一下。

> 「一起浪费掉？」

这是她这一阶段最合适的邀请方式。

不是：

```text
“我们约会吧”
“我喜欢你”
“陪我”
```

而是：

> **两个人都没有安排，所以顺路一起杀时间。**

坂口：

> 「这算邀请？」

遥凑：

> 「算吧。」

想了一下。

> 「不过今天这个不算约会。」

坂口：

> 「我还没说是约会。」

她看他一眼。

> 「那就好。」

这里留下非常轻的男女化学反应即可。

---

# 26A.4 First Stop — Late Lunch / Coffee

两个人首先去医院附近找吃的。

理由很实际：

> **因为上午那台临时手术，两个人都错过了正常午饭。**

遥凑走了一会儿，突然问：

> 「你吃午饭了吗？」

坂口：

> 「跟你一起开的那台手术什么时候给我吃？」

她停住。

> 「……对哦。」

坂口：

> 「你也没吃？」

她摸了一下自己的肚子。

> 「好像没有。」

坂口：

> 「‘好像’？」

> 「忙的时候不太记这个。」

这不是新的重大健忘笑话，只是把她的工作状态自然延续到生活里。

她想起附近有一家店。

> 「这边有家咖啡店。」

走到街口。

店门上挂着：

> `CLOSED ON SUNDAY`

两个人停下。

坂口看她。

她看招牌。

> 「……以前周日开的。」

坂口：

> 「多久以前？」

她想了想。

> 「不知道。」

坂口：

> 「很像你。」

她笑起来。

> 「今天第一次认识就开始这么说我？」

然后两个人随便换一家。

重点：

> **她并不因为计划落空而烦躁。**

这是遥凑日常生活里很有魅力的一面：

> 排程容易忘；
>
> 但计划变了，她也很容易接受。

---

# 26A.5 At the Table — 她其实很会记人

坐下来以后不要立刻进入沉重人物谈话。

前几分钟就是普通成年同事聊天：

```text
医院
今天荒谬的手术
艾莉娜要看的棒球转播
周日街上比医院热闹
谁推荐了什么难喝的咖啡
```

遥凑：

> 「Erina 现在应该已经在看了吧。」

坂口：

> 「你还挺在意她有没有赶上。」

> 「当然。」

坂口：

> 「日期倒是不在意。」

她笑：

> 「那个已经知道错了。」

不要让她因为 Intro 的日期错误持续自我谴责。

它现在还是：

> **很荒唐、但没有真正造成患者损害的一次排程事故。**

稍后，遥凑可以突然提到：

> 「你手术的时候很少说废话。」

坂口：

> 「这是夸奖？」

> 「算啊。」

她慢慢搅着饮料。

> 「而且你被临时抓进去也没乱。」
>
> 「一般人多少会烦。」

坂口：

> 「我有烦。」

> 「看得出来。」

坂口：

> 「那你还说我没乱。」

遥凑：

> 「烦和乱又不是一回事。」

这一句能表现：

> **她很会看人。**

上午她记患者；下午她开始记坂口。

---

# 26A.6 “你上台以后完全不一样”

这段作为很轻的人物互相评价。

坂口：

> 「你也和我刚见到的时候不太一样。」

遥凑：

> 「什么意思？」

> 「刚见面的时候，我以为你连今天星期几都不知道。」

她：

> 「我的确不知道。」

坂口：

> 「……」

她笑。

坂口：

> 「但是上台以后完全不像一个人。」

遥凑这次没有立刻开玩笑。

> 「那当然。」

她说得很自然。

> 「患者都已经躺在那里了。」
>
> 「总不能连她也一起忘吧。」

这句话在 Intro 此时只是轻松对白。

但必须保留，因为到了 Lv2《下午三点的患者》以后：

> **它会变成非常苦涩的反讽。**

不要在 Intro 提前强调这种未来意义。

玩家第一次听，只会觉得：

> 这女人其实很可靠。

---

# 26A.7 Walking With No Destination

吃完以后，两个人并不急着回去。

遥凑：

> 「现在回去？」

坂口：

> 「你有事？」

她下意识准备想。

停了一会儿。

> 「应该没有。」

坂口：

> 「‘应该’？」

> 「今天不要检查我的日程。」

于是两个人沿着商店街 / 河边 / 城市步道随便走。

不要安排大型景点。

这一段的魅力来自：

> **没有目的。**

他们可以：

- 停下来看看小店；
- 买第二杯饮料；
- 在长椅坐一会儿；
- 随口评价路人；
- 谈医院里一点无关紧要的事。

遥凑不是一直主动讲话的人。

允许出现几段：

> **两个人安静走着也不尴尬。**

这是“相处舒服”的核心。

---

# 26A.8 遥凑的成人魅力写法

这一段不要靠强烈挑逗。

遥凑的魅力来自：

```text
说话松弛
知道什么时候不继续追问
偶尔带一点成熟女性式玩笑
和陌生人迅速建立舒服距离
不需要不断证明自己有趣
```

示例：

坂口：

> 「你跟第一次见面的人都会这样出来走？」

遥凑：

> 「不会啊。」

坂口看她。

她像是意识到这句话听起来有点暧昧。

但没有急着圆回来。

只说：

> 「今天比较特别。」

坂口：

> 「因为周日开了一台本来不存在的手术？」

> 「嗯。」

停一下。

> 「也因为你还不错。」

这里不要接夸张脸红。

她可以很自然地继续往前走。

真正稍微不自然的反而可以是坂口。

---

# 26A.9 Personal Memory Seed

两个人经过自动贩卖机或店铺时，坂口随手选了某种饮料。

遥凑看一眼。

> 「你喝这个啊。」

坂口：

> 「怎么？」

> 「没什么。」

不要当场强调。

只保存一个很小的作者侧 callback：

```text
minato_remembers_sakaguchi_first_drink = true
```

具体饮料可由现有物品 / 场景资源决定。

以后 Lv4 可以回收：

> 她忘了正式约会日期，
>
> 却还记得第一次见面那个周日下午坂口随手买了什么。

这比让她现在直接说“我会记住”更有效。

---

# 26A.10 “今天这个不算约会” — Closing

天色开始变晚。

两个人走到一个自然分开的地方：

```text
车站
岔路口
停车场
医院附近路口
```

遥凑：

> 「差不多该回去了。」

坂口：

> 「你确定今天没有别的安排？」

她认真想了一会儿。

> 「……确定。」

坂口：

> 「想这么久就不太让人放心。」

她笑。

然后：

> 「今天谢谢你。」

坂口：

> 「医生谢助手？」

她看他。

> 「那个上午已经谢过了。」

停一下。

> 「这个是我谢你。」

坂口：

> 「谢什么？」

她没有给一个很重的答案。

> 「陪我浪费下午啊。」

然后像突然想起什么：

> 「还有。」

坂口：

> 「嗯？」

> 「今天这个真的不算约会。」

坂口：

> 「为什么一直强调这个？」

她稍微笑一下。

> 「第一次见面就算约会，不是太快了吗？」

坂口：

> 「那下次呢？」

这里不要让遥凑直接答“可以约会”。

她可以停半拍。

> 「下次先看我记不记得你名字。」

坂口：

> 「要求这么低？」

> 「对我来说很合理。」

她转身走了。

走出几步，又回头：

> 「坂口医生。」

坂口：

> 「这次记得？」

她笑：

> 「现在记得。」

结束。

---

# 26A.11 Relationship Meaning

这个 Epilogue 完成后：

```text
Relationship = Lv0
extra Familiarity = 0
official_date = false
mutual_attraction_flag = false
H unlock = false
```

只设置：

```text
minato_intro_sunday_walk_complete = true
```

玩家应该得到的感觉：

> **“我们还不熟。”**
>
> **“但她挺有意思。”**
>
> **“她好像也觉得我这个人不错。”**

这已经足够。

不要把第一次相识写成：

> 命中注定 / 一见钟情 / 正式追求。

---

# 26A.12 Lv4 Callback — LOCKED

Lv4《今天是今天》必须回收这一下午。

当遥凑把真正的约会忘掉，坂口可以提起：

> 「第一次见面那天，你倒没忘记跟我出去。」

遥凑：

> 「那天不是约会。」

坂口：

> 「你还记得？」

她停住。

> 「……记得啊。」

坂口：

> 「都多久以前了。」

她这时才意识到：

> 自己确实一直记得那个普通到几乎没发生什么的下午。

后续再自然接入 Lv4 已锁定的：

> 「可能我比较会记人吧。」
>
> 「你的事情，好像比较不容易忘。」

如果 Intro 时记录了坂口第一次买的饮料，可以进一步回收：

遥凑：

> 「你那天还喝了那个很甜的。」

坂口：

> 「……这个你也记得？」

她：

> 「嗯。」

然后她自己也觉得有一点奇怪。

这个 callback 是 Lv4 感情转折的重要组成部分。

---

# 26A.13 Tone Rule

这段必须保持：

> **轻。**

不要加入：

```text
悲惨过去
家庭创伤
职业危机自白
突然告白
第一次见面就明确性暗示
过量 flirting
```

它的最大魅力就是：

> **上午一起开腹。**
>
> **下午换回常服，一起喝东西、走路、什么也不赶。**

从高度制度化、身体性的手术空间：

> OR

直接落到：

> 一个普通周日下午。

这会非常有效地建立 Hoshimi 的整体气质：

> **这些女医在手术台旁是专业的医生；走出医院以后，她们也是松弛、漂亮、有自己生活节奏的成年女人。**

这正是遥凑 Intro 应该留下的第二层印象。

---

# 27. Intro Completion / State Changes — LOCKED

事件完成后：

```yaml
met_minato: true
minato_intro_complete: true
minato_intro_armed: false

relationship_level_minato: 0

completed_surgeries_with_minato:
  delta: +1

minato_surgery_invite_unlocked: true
minato_intro_sunday_walk_complete: true
```

Familiarity：

```text
按一次 Routine shared surgery
base +5
× Lv0→Lv1 multiplier 1.20
≈ +6
```

具体小数 / 取整继续沿用全局规则。

---

## 27.1 Global Numeric Rule

按照项目“剧情事件默认数值惰性”的规则：

本事件只明确结算：

```text
Minato Familiarity
completed_surgeries_with_minato
相识 / invite flags
本次周日整日行动已消耗
```

默认不额外发：

```text
Surgery XP
Leadership XP
Charm
Clinical Presence
Professional Reputation
procedure unlock
Advanced Referral credit
```

如后续希望该剧情手术也进入全局病例统计，应单独确认，不由 Codex 擅自增加。

---

# 28. Lv1
# 《你叫什么来着？》

```yaml
requirements:
  familiarity: 10
  completed_surgeries_with_minato: ">=1"
  intro_complete: true
  cooldown_days: ">=3"
```

功能：

> 在 Intro 已经证明她“排程乱、手术稳”以后，进一步建立她和坂口的个人互动。

建议结构：

```text
再一次共同工作 / 手术
↓
遥凑这次很自然叫出“坂口医生”
↓
坂口明显意外
↓
她不理解他为什么意外
↓
护士在旁边补刀
```

对白锚点：

遥凑：

> 「坂口医生。」

坂口停一下。

> 「怎么？」

遥凑：

> 「你什么表情？」

坂口：

> 「你记住了。」

她：

> 「……我有那么夸张吗？」

护士从旁边：

> 「有。」

Lv1 进一步展示：

> 她对病例和患者依然记得异常清楚。

关系意义：

> **坂口开始把她的健忘当成一个具体特征，而不是“不靠谱医生”的证据。**

---

# 29. Lv2
# 《下午三点的患者》

```yaml
requirements:
  familiarity: 25
  relationship_lv1_complete: true
  completed_surgeries_with_minato: ">=2"
  cooldown_days: ">=3"
```

这是原：

> IDEA-012 — 被忘在手术室的患者

正式归入遥凑路线。

---

## 29.1 Core

某工作日下午，一名明确成年女性患者：

```text
完成术前评估
完成病房准备
进入手术区
已经做好上台准备
等待主刀
```

因为：

```text
遥凑的交接记忆弱点
+
护士基于错误前提
+
巡回人员基于另一个错误前提
+
晚班默认另一组接手
```

最终：

> **整台手术从流程里“消失”。**

患者：

```text
下午紧张等待
↓
傍晚疑惑
↓
晚上太累在手术台睡着
↓
醒来发现 OR 空了
```

她裹着手术单：

> 赤脚走到夜班护士站。

---

## 29.2 Night Nurse Beat

患者：

> 「……那个。」
>
> 「我下午三点应该做手术。」

护士看钟：

```text
21:xx / 22:xx
```

护士：

> 「你、你怎么还在这里？！」

患者：

> 「这句话应该我问吧！！」

---

## 29.3 Sakaguchi Call-In

夜间电话：

护士：

> 「坂口医生……现在方便回来一下吗？」

坂口：

> 「急诊？」

护士：

> 「……严格来说，不是刚发生的急诊。」

坂口：

> 「那是什么？」

护士：

> 「是下午的。」

坂口：

> 「……什么？」

---

## 29.4 Minato Returns

遥凑也突然意识到：

> 「……等一下。」
>
> 「我今天下午是不是还有一台？」

她赶回医院。

患者看到她：

> 「就是你！！」

患者：

> 「你把我忘在这里七个小时！」

遥凑下意识看钟：

> 「……六小时四十七——」

坂口：

> 「现在不要订正。」

她停住。

第一次真正收掉平时轻松态度：

> **「……对不起。」**
>
> **「这是我的患者。」**

这一句必须保留。

---

## 29.5 Responsibility Rule

不能写成：

```text
坂口替她承担责任
遥凑甩锅给护士
她笑着糊弄过去
医院把事故完全当笑话
```

正确：

> **她承担这是自己的病例与自己的交接责任。**

坂口夜间救场的意义是：

> **他和她一起处理残局，而不是替她逃避残局。**

最终手术成功。

---

## 29.6 System Callback

事件后 seed：

> **Surgery Episode Lock**

院内以后可以有 running gag：

> 「你知道为什么现在正式术前流程开始以后，主刀就不能乱跑了吗？」

正常 gameplay：

```text
一旦正式术前准备开始
→ Surgery Episode Lock
→ 不能离开病例去做其他自由行动
→ 手术连续完成
```

玩家不能主动复刻“把患者忘在 OR”。

---

# 30. Lv2 → Lv3 Familiarity Slowdown

Lv2 完成后：

```text
Familiarity multiplier = 0.90
```

遥凑不是精神崩溃。

她是：

> **过度矫正。**

例如：

```text
三个闹钟
七张便签
手机提醒
病历贴标签
手腕写字
护士站白板
```

甚至：

遥凑：

> 「我下午四点十五分还有交接。」

坂口：

> 「你已经说第四次了。」

她：

> 「……那应该不会忘了。」

---

# 31. Lv3
# 《写下来就不会忘了吧？》

```yaml
requirements:
  familiarity: 40
  relationship_lv2_complete: true
  leadership: ">=55"
  days_since_lv2: ">=5"
```

Leadership55 的意义：

> 不是她迷恋领导型男人。

而是：

> **坂口是否有能力把个人弱点转化成可靠团队流程。**

事件核心：

两人和护理侧一起建立：

```text
明确 handoff owner
read-back
OR status board
未完成病例保持 active 状态
正式术前后 Surgery Episode Lock
```

禁止：

> 坂口成为“每天替她记所有事情”的私人闹钟。

---

## 31.1 Key Dialogue

遥凑：

> 「所以以后只要我不忘记看这个——」

坂口：

> 「不是为了你。」

她看他。

坂口：

> 「任何人都会忘。」
>
> 「不能让一台手术靠某一个人永远不犯错。」

这是 Lv3 最重要的关系 beat。

她第一次真正意识到：

> 坂口没有因为事故把她定义成“笨医生”。

Lv3 完成后：

```text
Familiarity multiplier = 1.10
```

---

# 32. Lv4
# 《今天是今天》

```yaml
requirements:
  familiarity: 55
  relationship_lv3_complete: true
  charm: ">=30"
  cooldown_days: ">=3"
```

Charm30：

> 表示坂口已经不只是舒服的同事，而是她会认真视为男人的对象。

她不是小夜香那种：

> 从 Day1 就强烈给出恋爱信号。

---

## 32.1 Core Event

两人约好下班约会。

坂口等了约四十分钟。

遥凑赶来：

> 「对不起！」

坂口：

> 「你忘了？」

她：

> 「我真的忘记今天是今天。」

坂口：

> 「这句话听起来很严重。」

---

## 32.2 Intro Sunday Callback / Memory Reversal

Lv4 必须先回收 Intro《十点二十分》结束后的那个周日下午。

遥凑把真正的约会忘掉以后：

坂口：

> 「第一次见面那天，你倒没忘记跟我出去。」

遥凑：

> 「那天不是约会。」

坂口：

> 「你还记得？」

她停一下。

> 「……记得啊。」

坂口：

> 「都多久以前了。」

这句话让她第一次意识到：

> **那个几乎没有特别安排、只是一起喝东西和散步的下午，她一直记得。**

如果 Intro 保存了第一次饮料 callback：

遥凑：

> 「你那天还喝了那个很甜的。」

坂口：

> 「……这个你也记得？」

> 「嗯。」

然后约会过程中继续发现她记得：

```text
坂口几个月以前提过想吃什么
他不喜欢哪种酒
第一次共同手术的一句闲话
某个他自己早就忘了的小动作
第一次见面那个周日下午的细节
```

坂口：

> 「为什么这些你全记得？」

遥凑：

> 「不知道啊。」

停一下。

> 「可能我比较会记人吧。」

进一步：

> 「你的事情，好像比较不容易忘。」

关系意义：

> Romance 正式成立。

成人亲密可在这一阶段接入 H System。

不要追加悲剧背景。

---

# 33. Lv5
# 《今天……是我？》

```yaml
requirements:
  familiarity: 75
  relationship_lv4_complete: true
  surgery: ">=65"
  route_gate:
    any_of:
      - leadership: ">=60"
      - clinical_presence: "<=-20"
  cooldown_days: ">=5"
```

---

## 33.1 Gate Meaning

### Surgery65

她自己是医生。

她愿意选择坂口做自己的主刀，至少要求：

> **可靠中等以上外科技能。**

不要求御堂式名医水平。

---

### Leadership60 Path

含义：

> **“这个男人能把整个流程管住。”**

她相信：

> 即使自己忘了什么，病例也不会从系统缝隙里掉下去。

---

### Clinical Presence <= -20 Path

仍属于平衡区，只是轻微温和 / 可亲倾向。

含义：

> **“他知道我会忘，却从没因为这件事轻视我。”**

不是：

```text
软弱
无权威
无限迁就
```

---

# 34. Lv5 Event Core

遥凑早已主动提出：

> 「哪天你给我开一次吧。」

她：

```text
看过方案
完成必要准备
完成既定 consent
自己选择坂口
```

但到了手术当天：

> 她正常穿着白大褂来上班。

护士：

> 「遥医生。」

遥凑：

> 「嗯？」

> 「你怎么还穿成这样？」

> 「上班不穿白大褂穿什么？」

沉默。

坂口出现。

她看看坂口。

看看护士。

再看看日期。

> 「…………」

> 「啊。」

今天：

> **她自己是患者。**

---

## 34.1 Core Payoff

坂口：

> 「要改天吗？」

她：

> 「为什么？」

> 「我只是忘了日期。」

停一下。

> **「又没忘记为什么选你。」**

这是 Lv5 核心关系 payoff。

完成后：

```text
Minato Relationship → Lv5
Staff-as-Patient eligibility → unlocked
```

具体首次患者术式：

```text
TBD
```

不要在本文件擅自锁死。

---

# 35. Long-Term Ambient / Running Gags

允许低频：

### 35.1 手机

> 「我的手机呢？」

坂口：

> 「你手里。」

> 「哦。」

---

### 35.2 护士站

遥凑走进来。

停住。

> 「我来干什么来着？」

护士：

> 「你问我们？」

> 「嗯。」

---

### 35.3 手术排程

护士：

> 「遥医生的排程有一个规律。」

坂口：

> 「什么？」

> 「有时候多一台，有时候少一台。」

坂口：

> 「这不叫规律。」

---

### 35.4 After Lv4

她可能忘记：

```text
纪念日
约会时间
买东西
```

但记得坂口：

```text
喜欢的饮料
不喜欢的食物
工作习惯
累的时候会做什么动作
```

不要把同一个“忘东西”笑话每次都写成完全相同结构。

---

# 36. Character Boundaries / DO NOT WRITE

禁止把遥凑写成：

```text
笨蛋医生
手术步骤都忘
经常切错地方
经常认错患者
无法独立生活
离开坂口就不能工作
每次事故都靠坂口擦屁股
以撒娇逃避医疗责任
```

Lv2 是：

> **一次足以成为医院传说的重大交接事故。**

它之所以有效，是因为：

> 平时她不是这样。

---

# 37. Distinction from Existing Characters

### vs 水城Aqua

```text
Aqua
→ 妇科顶级专家
→ medical grotesque
→ 教学狂热
→ patient-experience
→ 医学兴趣过剩导致离谱

遥凑
→ 普通开放外科
→ 人际感知强
→ prospective memory 灾难
→ 排程 / 交接喜剧
→ 医术本身正常可靠
```

---

### vs 南条小夜香

```text
Sayaka
→ generalist
→ Day1高可见度
→ 主动恋爱 / Tutorial Heroine
→ 系统兼容性

遥凑
→ 外科定位更明确
→ 中期通过10台手术后才出现
→ 关系首先从共同手术建立
→ 健忘 / 流程修复是人物核心
```

---

### vs 深山佳織

```text
Kaori
→ 压力下判断推进过快
→ 不确定信息处理过度积极

遥凑
→ 判断本身通常可靠
→ 未来事项 / 排程 / 交接记忆薄弱
```

不要互换两人的错误类型。

---

# 38. Erina Future Callback

艾莉娜不是遥凑路线常驻角色。

但允许低频复诊 callback。

例如 Lv2《下午三点的患者》已经发生并成为院内传闻后：

艾莉娜复诊遇见遥凑。

> 「听说你这次真的把患者忘在手术室里了？」

遥凑：

> 「……消息传这么快吗。」

艾莉娜：

> 「我就知道迟早会出事。」

坂口：

> 「为什么你一副早有预料的样子？」

艾莉娜：

> 「因为她上次连我哪天开刀都忘了。」

不要高频使用。

---

# 39. Art / CG Suggestions

Intro 最少可用：

```text
1. 艾莉娜周日早晨被突然叫醒准备手术
2. 遥凑第一次正式站在病房 / Holding
3. 遥凑手术服 + 坂口作为临时第一助手的 OR CG
4. 艾莉娜术后躺病房看棒球
```

如果只做一张专属 CG：

> 优先 **“艾莉娜已经完成术前准备，明显不爽；遥凑一脸自然；坂口刚被抓来当助手”**。

这张最能同时说明整个 Intro。

---

# 40. Engineering Notes for Codex

## 40.1 Suggested Flags

```text
minato_intro_armed
minato_intro_complete
met_minato
minato_surgery_invite_unlocked
minato_intro_sunday_walk_complete

completed_surgeries_with_minato

minato_lv1_complete
minato_lv2_complete
minato_lv3_complete
minato_lv4_complete
minato_lv5_complete

minato_forgotten_or_patient_incident_complete
```

实际字段名优先复用现有项目 naming convention。

不要因为本文示例字段而创建重复系统。

---

## 40.2 Trigger Pseudocode

```text
ON_SURGERY_COMPLETED:
    if completed_surgeries_total >= 10
       and not minato_intro_complete:
        minato_intro_armed = true
```

Sunday：

```text
ON_SUNDAY_HOSPITAL_VISIT:
    if minato_intro_armed
       and not minato_intro_complete:
        start_event("minato_intro_1020")
```

玩家如果周日不去医院：

```text
do nothing
keep minato_intro_armed = true
```

---

## 40.3 Intro Event Lock

开始：

```text
enter_story_episode_lock()
mark_current_sunday_as_consumed_by_story_event()
```

说明：

> 上述为语义伪代码。实现时必须复用项目现有“整日剧情事件 / 日终”基础设施，不要为了本事件另造一个独立时间系统。

期间：

```text
no free action
no Sunday Date
no random patient generation
no normal Surgery Runner
no Team Builder replacement
no return_to_sunday_action_menu
```

剧情内部可以正常显示：

```text
10:20
11:05
13:10
14:40
傍晚
```

这些是叙事钟点，不要求映射成逐小时 UI 消耗。

结束：

```text
set minato_intro_sunday_walk_complete = true
exit_story_episode_lock()
finish_current_sunday_via_existing_day_end_flow()
```

禁止：

```text
consume_time(3h)
术后重新开放普通 Sunday 行动
为了对齐 UI 而压缩剧情钟点
```


---

## 40.4 Surgery Accounting

Intro completion：

```text
completed_surgeries_with_minato += 1
award_minato_familiarity(routine_shared_case)
```

不要默认添加其他奖励。

---

# 41. Acceptance Criteria

Codex 实装后必须满足：

1. 玩家前10台正式手术期间不会提前正式认识遥凑。
2. 第10台完成后只设置 `minato_intro_armed = true`，不立即强制事件。
3. 此后玩家第一次在周日主动选择去医院时触发《十点二十分》。
4. 不抢玩家已经选择的 Sunday Date；未去医院则 armed 状态保留到以后周日。
5. 《十点二十分》是**全天 Sunday Story Event**，不是3小时或5小时的普通时间扣除。
6. 事件开始后当天不再返回普通 Sunday 行动界面；结束后按现有日终流程结束周日。
7. 剧情内部允许使用10:20、11:05、13:10、14:40等真实钟点，它们是叙事 chronology，不与 UI 小时成本强行换算。
8. 术后必须继续进入遥凑常服 Sunday Epilogue；该段不调用 Sunday Date System。
9. Epilogue 不额外增加 Familiarity，Relationship 仍为 Lv0。
10. 必须设置 `minato_intro_sunday_walk_complete = true`，供 Lv4 固定回收。
11. 必须展示遥凑从 OR 专业状态切换到常服私人状态后的松弛感。
12. 艾莉娜·金城·王固定为剧情患者，不从随机患者池抽取。
13. 艾莉娜诊断固定为胆囊结石 / symptomatic cholelithiasis。
14. 术式固定为开腹胆囊切除术；不使用腹腔镜或其他微创。
15. 麻醉固定为剧情指定胸段硬膜外，艾莉娜保持清醒。
16. 艾莉娜在遥凑进入病房前已经由惠麻利完成灌肠、术野备皮、患者更衣与完全遮发手术帽等病房术前准备。
17. 护士侧必须显得专业高效；艾莉娜侧必须体现“为什么星期日突然要经历这一整套”的意外、虚脱、不情愿和强烈吐槽。
18. 不因为日期错误额外建立“重新 consent”流程。
19. 惠 / Megumi Reinard 是本事件 story-only 成年护士，负责病房准备与 Scrub Nurse；不正式解锁、不进 roster、不开放 Relationship。
20. 本剧情手术不显示或建模巡回护士；不要求标准 OR 全编制。
21. 麻醉功能只作为剧情背景，不提前使用樱花正式登场。
22. 遥凑因周日没有正常助手临时抓坂口加入。
23. 遥凑为 Primary Surgeon，坂口为 First Assistant。
24. 不进入标准 Surgery Runner，不打开普通 Team Builder。
25. 手术固定成功，不调用普通 crisis / abort 随机系统。
26. 上台后必须明显展示遥凑临床记忆、患者记忆和开放手术能力都很可靠。
27. Intro 完成后 `completed_surgeries_with_minato += 1`。
28. Intro 完成后遥凑进入可邀请手术团队名单。
29. Familiarity 使用 Lv0→Lv1 的 ×1.20 阶段倍率。
30. Lv2 Gate 只检查：Fam25 + Lv1 complete + `completed_surgeries_with_minato >=2` + 冷却；满足后触发《下午三点的患者》，**事件完成后才升 Lv2**。
31. 不得把“完成《下午三点的患者》”写回 Lv2 事件的入口 Gate。
32. Lv2 完成后 Familiarity 倍率暂降为 ×0.90。
33. Lv3 Gate 为 Fam40 + Leadership55 + Lv2后至少5天。
34. Lv4 Gate 为 Fam55 + Charm30。
35. Lv5 Gate 为 Fam75 + Surgery65 +（Leadership60 **OR** Clinical Presence≤-20）。
36. Lv5 的 OR 条件绝不能误实现成 AND。


# 42. Final Design Summary

遥凑路线的核心不是：

> **“一个健忘的女人终于学会不健忘。”**

而是：

> **“一个很会记住人的医生，终于不再要求自己一个人记住整个医院。”**

Intro《十点二十分》：

> 她把本来不存在的星期日手术“记”出来了。

Lv2《下午三点的患者》：

> 她又把本来存在的一台手术从流程里“忘”掉了。

Lv3：

> 坂口和她一起把人的记忆弱点变成系统设计问题。

Lv4：

> 她会忘约会日期，却记得坂口很久以前说过的一句话。

Lv5：

> 她甚至忘了自己今天是患者，却没有忘记为什么选择坂口。

这就是遥凑在 Hoshimi Hospital 的完整人物路线。

# END
