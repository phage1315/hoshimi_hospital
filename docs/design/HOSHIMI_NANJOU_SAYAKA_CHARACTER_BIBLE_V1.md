# Hoshimi Hospital — 南条小夜香 Character Bible / System Test Heroine
## Nanjou Sayaka — Light Route / Adult Systems Tutorial — V1

> 用途：把南条小夜香正式纳入 Hoshimi Hospital roster，并固定她作为“轻量成人路线 + 默认系统测试角色”的设计定位。
>
> 本文件面向 Codex。若角色尚未存在，必须先创建最小可用角色记录；立绘、最终数值、CG、完整事件可后补。不要因为美术资源尚未完成而阻塞角色进入 roster。
>
> **核心一句话：**
>
> > **南条小夜香是 Hoshimi 里最容易相处、最容易攻略、最适合作为新系统第一批体验者的成年女医生。**
>
> 她不是主线女主，不背负复杂悲剧，不需要玩家“治愈”。她的价值在于：
>
> - 成人黄油气质；
> - 轻松恋爱；
> - 极高系统兼容性；
> - 初期高可见度；
> - 很可能自然成为玩家的“游戏初恋”。

---

# 0. Codex 执行指令

1. 全项目搜索：
   - 南条小夜香
   - 南条 小夜香
   - Nanjou Sayaka
   - Sayaka
2. 如果已经存在 actor：
   - 保留现有 actor_id；
   - 不创建重复角色；
   - 用本文件补齐 Character Bible 与系统标签。
3. 如果尚不存在：
   - 创建新 actor；
   - 推荐 ID：

```text
doc_sayaka
```

4. 初建时允许：

```yaml
sprite: placeholder
portrait: placeholder
stats: temporary
```

5. 创建后至少接入：
   - actor registry
   - relationship system
   - hospital encounter system
   - Sunday Date system
   - OR assistant eligibility
   - Staff-as-Patient system
   - Public Teaching Surgery eligibility
   - Hotel / adult relationship system

6. 后续有正式立绘和数值时替换资源，但不要更改稳定 actor_id。

---

# 1. 来源与 Hoshimi 改编定位

原作视觉与角色标签核心：

```text
南条小夜香
School Nurse
Mature
Popular
```

原作核心 archetype：

> **教会系女子学校的年轻保健室老师 / School Nurse。**

Hoshimi 不需要复制原作完整剧情。

保留：

- 年轻成熟女性；
- 白大褂；
- 保健室老师气质；
- 很受欢迎；
- 成年、开放、会调情；
- 轻黄油氛围。

改编：

> 她现在已经是正式医师，并进入 Hoshimi Hospital。

---

# 2. 年龄与教育经历

建议年龄：

```yaml
age: 27
```

采用 Hoshimi AU 的轻微架空医学教育路径，不要求完全对应现实日本制度。

推荐经历：

```text
18岁左右：进入医学部
约2年后：暂时离开医学部
之后补修学校健康 / 養護教諭相关资格课程
约2年：在教会系女子学校担任保健室老师
后来发现自己仍然想真正完成医学训练
重新进入 / 回到医师培养路径
27岁左右：取得医师资格并进入 Hoshimi Hospital
```

重点：

> 她不是因为悲剧离开医学部。

不要添加：

```text
家庭破产
恋人死亡
医疗事故
严重精神创伤
神秘阴谋
```

她当年只是：

> 年轻时绕了一点路。

后来发现：

> “我还是想当真正能够诊断和治疗患者的医生。”

于是把医学读完。

---

# 3. 她为什么离开女子学校

这不是职业创伤，也不是深刻人生危机。

她可以认真承认：

> **“女人太多了。”**

推荐作为 Lv2 左右第一次下班喝酒事件的重要对白。

示例：

坂口：

> “你以前不是在女子学校的保健室工作吗？”

小夜香：

> “嗯。两年。”

坂口：

> “为什么后来不做了？”

小夜香：

> “女人太多了。”

坂口：

> “……什么？”

小夜香：

> “每天从早到晚，学生是女的，老师是女的，来保健室哭恋爱烦恼的也是女的。”

坂口：

> “所以你想换工作？”

小夜香：

> “所以我想去男人多一点的地方。”

坂口：

> “男人多一点？”

小夜香：

> “怎么，喜欢男人多一点的地方有罪吗？”

然后她喝一口酒，叹气：

> “结果好不容易当了医生……”

> “这个医院怎么又几乎全是女的啊。”

坂口：

> “现在辞职还来得及。”

她笑：

> “那倒不用。”

停一下：

> “至少还有你。”

这场事件的重要功能：

```text
School Nurse background
+
她喜欢男人
+
她会主动调情
+
她知道自己在调情
+
明确攻略信号
```

---

# 4. 她不是“厌女角色”

必须明确：

> 她喜欢男人，不等于她讨厌女人。

她和女性同事可以相处得非常好：

- 会参加团建；
- 会参加温泉；
- 会聊天；
- 会帮忙；
- 会和护士、医生一起吃饭；
- 很容易混进任何小团体。

Running gag：

恋：

> “南条医生，你不是说不想待在女人太多的地方吗？”

小夜香：

> “我又没说我讨厌女人。”

恋：

> “那你到底有什么意见？”

小夜香：

> “男人太少。”

---

# 5. 核心人格

关键词：

```yaml
tags:
  - mature
  - popular
  - playful
  - flirtatious
  - sexually_confident
  - easygoing
  - sociable
  - generalist
  - adaptable
  - low_drama
  - self_aware
```

她最重要的特点：

> **毫不扭捏。**

她可以：

- 喜欢男人；
- 主动约人；
- 主动进入成年亲密关系；
- 主动参加 Staff-as-Patient；
- 主动报名教学手术；
- 主动进入新系统。

但：

> **所有这些都是因为她自己想。**

她不是“什么都答应”。

她有边界，也会拒绝：

> “好说话和随便不是一回事。”

---

# 6. DO NOT ADD TRAGIC BACKSTORY

这是本角色最高优先写作限制之一。

```yaml
hidden_trauma: false
family_tragedy: false
hospital_conspiracy: false
ex_boyfriend_drama: false
moral_injury: false
career_crisis: false
secret_crime: false
dark_past_reveal: false
```

不要为了“增加深度”给她追加悲剧。

她的深度来自：

> **一个成年人可以很轻松地喜欢别人、享受工作、享受亲密关系，也仍然是完整人物。**

---

# 7. 当前职业定位

推荐：

```text
综合诊疗 / 健康管理 / 一般内外科支援型医生
```

不需要锁死非常狭窄的专科。

她擅长：

- 常见病；
- 健康咨询；
- 轻症；
- 青年女性常见问题；
- 术前基础评价；
- 门诊；
- 一般病房；
- 健康管理；
- 各科边缘支援。

她不是：

```text
顶级外科专家
影像专家
妇科天才
医院领导核心
复杂诊断第一人
```

---

# 8. “医院里她什么都不行，但什么都能掺一脚”

内部设计定义：

> **什么都不是最强，但什么都能帮一点。**

建议：

```yaml
clinical_archetype: generalist
specialty_power: medium_low
adaptability: high
teamwork: high
availability: very_high
```

未来 stats 可参考：

```yaml
surgery: 68
diagnostics: 72
teamwork: 84
patient_care: 82
instrument_handling: 67
calmness: 78
leadership: 60
```

这些只是方向，不是最终锁定数值。

关键原则：

> **System-generalist ≠ Medical-genius.**

高难病例她应该坦率地说：

> “这个不行，换专业的。”

---

# 9. OR / 手术助手角色

她可以很容易被拉上刀。

这应该成为 running gag。

普通手术：

> “这个我会一点。”

坂口：

> “你昨天妇科手术也这么说。”

小夜香：

> “昨天不是做完了吗？”

高难病例：

坂口：

> “这个你熟吗？”

小夜香：

> “不熟。”

坂口：

> “那你为什么站这里？”

小夜香：

> “因为你点了我啊。”

骨科：

小夜香：

> “骨头我认识。”

坂口：

> “这是最低标准。”

复杂大血管：

小夜香：

> “这个我建议你换个人。”

这句很重要：

> 她知道什么时候自己不该硬上。

---

# 10. OR 中的成人调情

她可以在工作中说暧昧话，但不能影响专业判断。

例如：

坂口：

> “吸引。”

小夜香递过去：

> “你这么命令人的时候还挺帅的。”

坂口：

> “现在是手术。”

小夜香：

> “所以我只是说话，又没停手。”

又例如：

坂口：

> “再靠近一点。”

她靠近：

> “这样？”

坂口：

> “我是说拉钩。”

小夜香：

> “我知道啊。”

这种对话应该：

```text
flirty
+
professionally functional
```

不要让她因为黄油气质变成不可靠医生。

---

# 11. 半强制 Day 1 初见

她应该是：

> **玩家 Day 1 必定认识的角色。**

不是强制攻略，只是强制认识。

推荐初见地点：

```text
员工区域
走廊转角
自动贩卖机
食堂关门前
医局外
```

可以采用轻微黄油 comedy：

- 两人撞到；
- 资料 / 咖啡掉地；
- 白大褂本来就穿得随意；
- 坂口一时间不知道视线放哪里；
- 她直接看穿。

示例：

小夜香：

> “你看够了吗？”

坂口：

> “我是在看掉在地上的东西。”

她看看自己的衣服，再看看他：

> “哦——。”

> “那就当我相信你。”

然后：

> “南条小夜香。今天好像还没正式认识。”

坂口：

> “你哪个科的？”

她：

> “哪里缺人往哪里塞。”

坂口：

> “这算科室？”

小夜香：

> “星见特色。”

---

# 12. 高权重 Ambient Encounter

她应该是 roster 中随机遭遇权重最高的人之一。

推荐：

```yaml
ambient_encounter_weight: very_high
minimum_gap: 1_day
```

可出现地点：

- 门诊走廊；
- 病房；
- 护士站附近；
- 食堂；
- 自动贩卖机；
- 医局；
- 天台；
- 手术部外；
- 放射科门口；
- 坂口办公室附近。

理由可以非常普通：

```text
送会诊单
找人
帮忙
刚吃完饭
躲患者家属
顺路
闲逛
```

不要求每次触发完整事件。

允许 3–6 行 mini encounter。

---

# 13. Ambient Encounter 例子

电梯：

小夜香：

> “几楼？”

坂口：

> “手术部。”

小夜香：

> “又去开刀？”

坂口：

> “嗯。”

小夜香：

> “你真的没有别的爱好吗？”

坂口：

> “你呢？”

小夜香：

> “有啊。”

她看他一眼：

> “但是上班时间不方便说。”

电梯到了。

结束。

---

# 14. 关系路线定位

内部标签：

```yaml
route_difficulty: easiest
relationship_growth_modifier: high
emotional_baggage: minimal
adult_content_weight: high
hospital_plot_weight: low
```

她应该成为全游戏：

> **最容易自然升到 Lv5 的角色之一。**

不是“免费赠送”。

而是：

> 她没有人为设置的情感门槛。

---

# 15. 推荐 Lv0–Lv5 路线

## Lv0 — 《白大褂下面》

Day 1 初见。

功能：

- 解锁角色；
- 建立黄油喜剧气质；
- 建立“哪里缺人去哪里”的 generalist 印象。

## Lv1 — 《以前的保健室》

聊她在女子学校当保健室老师的经历。

内容：

- 学生装病；
- 体育课受伤；
- 经期不适；
- 恋爱烦恼；
- 她很受欢迎；
- 她其实很喜欢那份工作。

但她后来还是决定把医学读完。

## Lv2 — 《女人太多了》

第一次正式下班喝酒。

使用本文件第 3 节对白。

这是玩家明确意识到：

> **她可以攻略。**

的转折点。

## Lv3 — 《你到底是不是在约我》

第一次正式 Sunday Date。

她不需要复杂铺垫。

可以直接问：

> “所以这算约会吗？”

坂口：

> “你觉得呢？”

小夜香：

> “如果不是，我就亏了。”

## Lv4 — 《那就别回去了》

Hotel / H 系统解锁。

她可以成为最自然的 Hotel Tutorial。

吃完饭以后：

小夜香：

> “接下来呢？”

坂口：

> “送你回去？”

她看他：

> “你是认真的？”

选项：

```text
[送她回家]
[再喝一杯]
[找个地方休息]
```

第二天仍然正常工作。

## Lv5 — 《轻松一点不行吗？》

不要突然加入悲惨过去。

坂口：

> “我们现在到底算什么？”

小夜香：

> “你想听正式版本还是简单版本？”

坂口：

> “简单的。”

小夜香：

> “我喜欢你。以后也想和你睡。周末有空就一起出去。”

坂口：

> “就这样？”

小夜香：

> “还不够？”

她可以补：

> “以后真要谈更远的，也可以谈。”

> “但今天先把饭吃完。”

Lv5 主题：

> **稳定关系不需要靠创伤爆发确认。**

---

# 16. “玩家初恋”设计目标

她不是官方正宫。

UI 不要写：

```text
Recommended Heroine
Main Romance
```

但系统上要让她自然成为：

- 第一个认识；
- 第一个可以频繁碰见；
- 第一个可约会；
- 第一个可能进入 Hotel；
- 第一个成年亲密事件；
- 第一个 Staff-as-Patient；
- 第一个 Public Teaching Surgery；
- 第一个 Lv5。

因此建议悄悄记录：

```text
first_date_character
first_h_character
first_lv5_character
first_staff_patient_character
```

如果这些 flag 指向小夜香，可触发少量专属 callback。

---

# 17. 第一个 Sunday 的保险机制

目标：

> 第一个星期天至少有一个可约角色。

如果玩家到星期六还没有任何其他角色达到 Sunday invite 条件：

触发小夜香主动消息：

```text
南条小夜香：
“明天休息？”
```

玩家：

```text
[是]
[有事]
```

选择“是”：

> “那陪我吃个饭。我刚来这附近，还没找到好吃的。”

然后正式进入 Sunday Date Tutorial。

拒绝：

> 不扣关系。

重要：

> 这是系统保险，不是强制攻略。

---

# 18. Hotel / Adult Relationship Tutorial

她最适合作为：

```text
first_hotel_tutorial_candidate
```

理由：

- 成年；
- 性格开放；
- 主动；
- 不需要剧情创伤铺垫；
- 第二天不会产生关系灾难。

首次 Hotel 后：

坂口：

> “昨天……”

小夜香：

> “嗯？”

坂口：

> “没什么。”

小夜香：

> “那今晚呢？”

她的路线应该明确表达：

> **成年人发生亲密关系不自动制造悲剧或尴尬。**

---

# 19. Staff-as-Patient Tutorial

她应该是最早愿意主动体验 Staff-as-Patient 的角色之一。

动机非常简单：

> “我以后总要给患者解释流程吧？自己躺一次不是更清楚？”

再加一点：

> “而且我还真没认真躺过手术台。”

她可以成为玩家第一次完整体验：

```text
staff patient selection
→ pre-op
→ transfer
→ positioning
→ interaction
→ procedure
→ postoperative callback
```

的教学角色。

---

# 20. Public Teaching Surgery Tutorial

她非常适合做第一个 Public Teaching Surgery 患者。

当明日香说：

> “需要一名教学患者。”

其他人还没反应：

小夜香已经举手。

明日香：

> “南条医生，我还没有说是什么。”

小夜香：

> “那你先说。”

这就是她。

---

# 21. 教学手术的喜剧 / 黄油方向

教学手术可以明显比其他人的 Staff-as-Patient 更轻、更有黄油喜剧感。

核心桥段：

她一开始很镇定。

躺上手术台后：

- 摆体位；
- 安全固定；
- 手臂安置；
- 团队围上来；
- 她开始发出明显反应。

最初大家以为：

> 她害怕。

例如：

小夜香：

> “呀——”

坂口：

> “疼？”

小夜香：

> “没有。”

继续调整。

> “啊……等一下……”

成美：

> “不舒服？”

小夜香：

> “也不是。”

再继续。

> “嗯……这个有点……”

大家慢慢意识到：

> **她的反应似乎不完全是害怕。**

恋：

> “南条医生……请尽量不要发出容易让人误会的声音。”

小夜香：

> “我已经很努力了。”

坂口：

> “你到底把教学手术当什么了？”

小夜香：

> “患者体验啊。”

明日香：

> “继续。”

重点：

> 她享受的是“自己成为被整个专业团队关注、照顾、摆位、进入医疗流程中心”的感觉。

不要把她写成：

```text
疼痛成瘾
喜欢真正受伤
想被危险对待
```

保持：

```text
nervousness
embarrassment
attention
excitement
professional curiosity
```

的混合即可。

---

# 22. 教学手术专业底线

即使事件黄油味很强，也必须：

```text
成年
自愿
安全
正式 consent
专业团队
正常医疗流程
```

事件笑点来自：

> 她的反应和她本人性格。

不是来自：

> 医护故意伤害她。

---

# 23. Default System Test Heroine

内部开发定位：

```yaml
default_system_test_character: true
```

凡是以后新增一个：

> **适用于普通成年角色的通用系统**

如果不知道先让谁支持：

> **优先让南条小夜香接入。**

包括但不限于：

- Sunday 新地点；
- Hotel 新互动；
- 酒吧；
- 办公室访问；
- 节日；
- Staff-as-Patient；
- Public Teaching Surgery；
- 新 OR 支援对白；
- 新术前互动；
- 新 relationship callback；
- 新成人事件结构；
- 新医院随机遭遇；
- 新休闲设施；
- 新换装；
- 新社交活动。

---

# 24. “新系统她都能去测试”的角色梗

这不只是开发便利。

可以直接成为游戏内 running gag。

坂口：

> “为什么每次试新东西都是你？”

小夜香：

> “因为我好说话啊。”

坂口：

> “这理由听起来很危险。”

小夜香：

> “那你下次别叫我。”

坂口沉默。

她笑：

> “你看。”

甚至：

明日香：

> “新系统需要一名志愿者。”

小夜香举手。

明日香：

> “我还没说是什么。”

小夜香：

> “那你先说。”

原则：

> 她不是“什么都答应”。

而是：

> **什么都愿意先听听。**

---

# 25. Sunday / Date 偏好

她的约会适应性也应该很高。

```yaml
preferred:
  - restaurant
  - bar
  - café
  - shopping_street
  - aquarium

acceptable:
  - bookstore
  - park
  - museum
```

她不是特别挑地点。

真正重要的是：

> 和谁去。

---

# 26. 她和 Aqua 的区别

必须避免重叠。

## Aqua

```text
医学热爱极高
社会过滤器低
会无意间说出很色情的话
```

## 小夜香

```text
知道自己在调情
知道对方听懂了
故意继续
```

一句话：

> **Aqua = unintentionally outrageous**
>
> **Sayaka = deliberately provocative**

---

# 27. 她和其他核心角色的生态位

```text
御堂
= 高难外科技术

Artoria
= 团队领导

Aqua
= 妇科天才 + 无过滤器

藤崎
= 综合诊断

成美
= patient voice

芹香
= imaging + dormant surgeon

中井
= mysterious experienced nurse

南条小夜香
= generalist + flirt + adult tutorial + system test
```

她不是抢专业第一。

她的价值是：

> **哪里都能放。**

---

# 28. 她的可爱为什么可能超出预期

开发目标不是：

> “把她写成最受欢迎女主。”

但她很可能自然变成玩家非常喜欢的角色。

因为她：

- 不吊胃口；
- 不要求玩家解决她的人生；
- 不用复杂条件证明爱；
- 成年亲密关系以后不会突然翻脸；
- 工作时照样正常；
- 很容易见到；
- 很容易一起玩；
- 会主动表达喜欢；
- 会直接说自己想要什么。

所以玩家可能：

> 原本只是拿她做 Tutorial。

最后却发现：

> 自己最习惯她在身边。

这就是“游戏初恋”感。

---

# 29. Firsts Callback

如果她拿到多个 first flag：

```text
first_date
first_h
first_lv5
first_staff_patient
```

可以有专属对白。

例如：

小夜香：

> “这么想的话，我好像拿走了你不少第一次呢。”

坂口：

> “你听起来挺得意。”

小夜香：

> “为什么不能得意？”

这类 callback 不需要大奖励。

它的作用是：

> 让玩家意识到一路走来，她确实一直都在。

---

# 30. 长期关系也保持轻松

Lv5 后不要突然变成：

```text
占有欲极强
强制结婚线
极端吃醋
复杂修罗场主线
```

她可以认真喜欢坂口。

但她仍然是：

> 知道成年人关系可以轻松相处的人。

后期聚餐：

小夜香：

> “你看，我当初就说吧，这里男人太少了。”

坂口：

> “那你怎么还没走？”

小夜香：

> “因为够用了。”

---

# 31. 绝对禁止写坏的方向

```text
DO NOT:
- add tragic hidden past
- make her secretly traumatized
- turn her into a medical genius
- make her incompetent comic relief
- make her sexually open because of pathology
- make adult content replace professional competence
- make her agree to everything
- make her jealous/possessive by default
- turn Lv5 into sudden melodrama
- make her official canon main heroine
- lock general systems behind her route only
```

---

# 32. 最终设计定义

## 人物

> **27岁的年轻女医生。曾在教会女子学校做过两年保健室老师，后来回去完成医学教育。成熟、受欢迎、会调情、喜欢男人、没有沉重秘密。**

## 医疗

> **什么都懂一点，什么都不是最强；缺人的地方经常能塞进去。**

## 恋爱

> **全游戏最好攻略的人之一。她喜欢你，就会让你知道。**

## 成人内容

> **成人、主动、轻松，不把亲密关系自动等同于人生危机。**

## 系统

> **Default System Test Heroine。任何新的普通成人系统，都优先考虑让她第一批支持。**

## 玩家体验

> **她本来只是 Tutorial Heroine。**
>
> **但很可能最后变成玩家在 Hoshimi 的初恋。**

---


# 33. 视觉设计补充：早期高魅力成年女医生

南条小夜香可以参考一种“早期就让玩家非常容易留下印象的成年白大褂女性角色”在游戏体验中的位置，但不要照抄其他作品角色的性格、剧情或造型。

需要借鉴的是：

```text
极早登场
+
成年人魅力明确
+
白大褂视觉辨识度高
+
很早让玩家意识到“她可以攻略”
+
低门槛建立熟悉感
+
后期即使出现更多角色，玩家仍容易对她保留“最早喜欢上的人”的感情
```

这与本文件的“玩家初恋 / Tutorial Heroine”定位完全一致。

## 33.1 身材比例

建议：

```yaml
height: 158-160cm
body_type: petite_mature
leg_ratio: long
waistline: high
torso: relatively_short
```

核心不是幼态。

她应该是：

> **身材不高，但腿明显很长。**

视觉上：

- 头身比仍是成年女性；
- 腰线较高；
- 腿部比例漂亮；
- 整体纤细；
- 不需要夸张胸围；
- 性感重点更多来自腿、腰线、衣着与成年人的自信。

禁止：

```text
chibi
幼态脸
短粗腿
学生妹体型
```

---

# 34. 白大褂造型原则

白大褂是她最重要的职业视觉符号之一。

但和医院里其他医生不同：

> **她看起来像下班以后马上就可以去约会，只是现在外面临时套了一件医生白大褂。**

建议：

```text
白大褂经常敞开
里面穿成熟、时尚、略大胆的私服
高腰短裙 / 修身裙装
贴身上衣
深色丝袜 / 长袜
女性化鞋履
```

整体应：

```text
adult
fashionable
flirty
professionally_plausible
```

而不是：

```text
裸露到无法正常工作
纯 cosplay
未成年制服感
```

她本人并不会觉得这种穿法需要特别解释。

可用于早期对白：

坂口：

> “你真的是这里的医生？”

小夜香低头看看自己：

> “哪里不像？”

坂口：

> “白大褂里面。”

她也低头看一眼：

> “……这里有着装规定？”

坂口：

> “好像没有。”

小夜香：

> “那不就好了。”

---

# 35. 白大褂与手术服的视觉反差

她平时：

```text
白大褂
+
短裙 / 长腿
+
成熟时尚
```

进入 OR 换成宽松 scrub 后：

> 她会突然显得比平时想象中小一号。

这是一个可重复使用的轻喜剧点。

第一次与坂口一起进入 OR 时可以有：

坂口：

> “你原来这么矮？”

小夜香：

> “……你以前到底在看哪里？”

停一下。

小夜香：

> “腿长不就够了吗？”

这类对白非常适合她，因为她：

> **知道坂口在说什么，也知道自己在回什么。**

---

# 36. 与“早期成年白大褂高魅力角色”范式的区别

内部开发可以把她视为：

> **Early Adult Romance Anchor**

但她自己的性格必须保持独立。

不要写成：

```text
疏离
地下诊疗
故意危险
冷酷反叛
病态试验
```

南条的方向是：

```text
bright
socially_easy
adult
openly_flirtatious
low_drama
approachable
```

一句话：

> **不是“这个危险的大姐姐好有魅力”。**
>
> **而是“这个大姐姐怎么这么快就和我混熟了，而且越来越可爱”。**

---

# 37. 新手术室接收 / Acceptance Training：必须参加

由于南条是：

```text
Day 1 guaranteed acquaintance
+
high ambient encounter weight
+
Default System Test Heroine
```

所以如果 Hoshimi 有“新手术室接收 / 新 OR 验收 / Acceptance Training”事件：

> **南条小夜香应默认加入核心参与名单。**

这不是 cameo。

这是她人物功能的正式体现。

---

# 38. 新 OR 接收事件中的团队功能

推荐核心阵容：

```text
城宮明日香
→ 正式负责人 / 验收 gatekeeper

神宮寺成美
→ 医生视角、真实临床使用、患者声音

七瀬恋
→ OR 护士 / 患者情绪与围术期流程

朝倉美幸
→ 有经验护士面对新设备、新 SOP

中井美佳
→ 病房 → OR 的患者转运与交接视角

南条小夜香
→ 泛用测试员 / “什么新东西都想先碰一下的人”
```

南条不能取代其他人的专业功能。

她的功能是：

> **把“新系统测试”这个开发属性，变成角色本人的性格。**

---

# 39. 新 OR 接收事件 Beat 1：先动手再问

明日香正在进行正式说明：

> “今天主要确认各岗位动线、设备位置和紧急情况下的——”

南条已经伸手去碰手术台控制器。

明日香：

> “南条医生。”

小夜香：

> “我只是在确认。”

明日香：

> “我还没有说可以碰。”

小夜香：

> “那现在可以吗？”

这一段用于建立：

```text
curious
hands_on
system_tester
knows_she_is_being_cheeky
```

但不要让她：

- 随意启动危险设备；
- 破坏无菌区；
- 违反真正的安全底线。

---

# 40. 新 OR 接收事件 Beat 2：主动躺上手术台

当团队开始测试：

```text
table height
tilt
arm board
safety strap
positioning
transfer workflow
```

南条主动说：

> “要不要躺个人比较好？”

坂口：

> “你为什么说这句话的时候看着我？”

小夜香：

> “因为你是外科医生啊。”

坂口：

> “这跟我有什么关系？”

小夜香：

> “那我躺。”

然后她自己成为真人测试对象。

这不是 Staff-as-Patient 正式事件。

此时：

```text
fully_clothed_or_scrubbed: true
no_procedure: true
equipment_acceptance_only: true
```

它的作用是：

> **提前埋下她以后愿意做 Staff-as-Patient / Public Teaching Surgery 的性格伏笔。**

---

# 41. 新 OR 接收事件 Beat 3：安全带 callback 伏笔

她躺上去后：

小夜香：

> “哇，这个还挺窄的。”

恋：

> “手术台本来就不是床。”

小夜香：

> “那这个固定带呢？”

恋：

> “防止患者意外移动。”

小夜香自己试着拉了一下：

> “哦……”

停一下。

> “这个感觉……”

坂口：

> “南条。”

小夜香：

> “我什么都没说。”

这段应保持：

```text
suggestive
comic
non-explicit
safe
```

未来 Public Teaching Surgery 可以 callback：

小夜香：

> “……我是不是以前就说过这个固定带有点不得了？”

坂口：

> “你当时还没躺成这样。”

小夜香：

> “所以这次是完整体验。”

---

# 42. 新 OR 接收事件 Beat 4：什么岗位都想掺一脚

验收器械台时：

小夜香：

> “这个我也会。”

美幸：

> “南条医生，你是医生。”

小夜香：

> “医学院又不是没学过无菌操作。”

美幸：

> “我不是这个意思。”

到麻醉设备：

小夜香：

> “这个呢？”

坂口：

> “这个你别碰。”

小夜香：

> “好嘛。”

这非常重要。

它说明：

> **她什么都想试，但知道专业边界。**

她不是不懂危险，也不是 comic incompetence。

---

# 43. 新 OR 接收事件 Beat 5：志愿者固定梗诞生

结尾，明日香：

> “正式启用前，还有几项需要真人流程验证。”

小夜香：

> “我可以。”

明日香：

> “南条医生，我还没有说是什么。”

小夜香：

> “那你先说。”

这一句以后可以成为她的固定 running gag。

建议设 flag：

```text
sayaka_first_volunteer_gag = true
```

后续新系统事件可引用。

---

# 44. 新 OR 接收事件戏份控制

她必须参加，但不能把事件变成：

> “南条小夜香个人搞笑大会。”

建议明显 beat 只占：

```text
3–5 个
```

其余时间：

- 听专业说明；
- 正常参与；
- 必要时给 generalist 视角；
- 让其他角色完成自己的专业功能。

她的存在是：

> **调味 + 系统伏笔。**

不是抢主角。

---

# 45. Day 1 / Week 1 推荐节奏更新

正式建议：

```text
Day 1
↓
必定撞见 / 认识南条
↓
同日或早期参与新 OR 接收事件
↓
玩家发现“她怎么哪里都有”
↓
Day 2–6
高权重 ambient encounters
↓
至少一个 Lv1 / Lv2 轻事件
↓
First Sunday
南条已经自然成为可约对象
```

这样可以保证：

> 第一个 Sunday 打开时，玩家至少已经认识一个很自然可以约出去的人。

---

# 46. “怎么又是南条” → “怎么没有南条”

这是她长期体验目标。

早期：

> “怎么又是南条？”

中期：

> “哦，南条也在。”

后期：

> “这次怎么没有南条？”

这代表她的高出现率已经从系统便利变成了玩家熟悉感。

她的角色黏性不是靠主线戏份，而是靠：

> **持续、轻松、无负担的存在感。**

---

# 47. 更新后的开发定位

```yaml
sayaka_design_role:
  actor_role: doctor
  route_type: light_adult_route
  route_difficulty: easiest

  early_game:
    guaranteed_day1_meeting: true
    new_or_acceptance_required: true
    ambient_encounter_weight: very_high
    first_sunday_safety_candidate: true

  visual:
    height_cm: 159
    body_type: petite_mature
    long_legs: true
    high_waistline: true
    white_coat_signature: true
    bold_under_coat_style: true

  system:
    default_system_test_character: true
    staff_as_patient_tutorial: true
    public_teaching_surgery_tutorial: true
    hotel_tutorial_candidate: true

  writing:
    consciously_flirtatious: true
    emotionally_low_drama: true
    do_not_add_tragic_backstory: true
```

---

# 48. 最终补充定义

南条小夜香的特殊价值不是：

> 她拥有最复杂的故事。

而是：

> **她拥有最容易让玩家开始“生活在 Hoshimi”里的路线。**

她会是最早让玩家感觉：

```text
我认识这里的人了
我下班以后也有地方去
我星期天有人可以约
我第一次体验了成人关系
我第一次让熟悉的医护变成患者
我第一次参加了教学手术
```

的人。

因此：

> **她既是 Tutorial Heroine，也是 Hoshimi 日常生活感的入口。**

如果玩家最后把她当成自己的“初恋”：

> 那不是因为 UI 指定了她。

而是因为：

> **她从第一天开始，就一直在。**


# END
