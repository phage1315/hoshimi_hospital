# Hoshimi Hospital — 伊吹摩耶访问研究医设定 V1.2
## Maya Ibuki — Visiting Research Physician / Biomedical Instrumentation Researcher

> **用途**
>
> 本文件用于把此前已经讨论过的 Hoshimi 版伊吹摩耶设定重新整理成可直接交给 Codex 的角色资料。
>
> 本稿分成两层：
>
> 1. **已恢复 / 已确认的既有设定**：来自此前 Hoshimi 对话与已经生成的角色设定图；
> 2. **Codex 接入建议**：为了让程序能够落地，对此前没有锁死的字段给出明确但可替换的实现建议。
>
> 如以后找回更早的原始 MD，与本稿冲突时，以用户确认后的新版为准。

---

# 0. 角色定位

伊吹摩耶不是 Hoshimi 的常驻主治医生，也不是普通攻略医生。

她的定位是：

> **中期解锁的访问研究医 / 生命科学与医疗仪器研究者。**

核心来源仍然保留《新世纪福音战士》中伊吹摩耶的原作精神：

- 原 NERV 技术官 / 操作员；
- 强项不是临床主刀，而是生理监测、医疗设备、数据、系统操作、仪器校准与实验医学；
- 对赤木律子有非常强的敬意与精神影响；
- 离开 NERV 之后，转向基础医学与生命科学研究。

在 Hoshimi 中，她的价值是：

> **把“EVA 系统工程 / 监控员”的能力，自然转换成“生物医学 + 生理监测 + 医疗仪器”的医院生态位。**

---

# 1. 基本资料

```yaml
name_ja: 伊吹 摩耶
name_en: Maya Ibuki
gender: female
adult: true
source: Evangelion crossover AU

role_type: visiting_research_physician
employment: temporary_visiting
core_roster: false
romance_route: false
adult_route: false
```

## 年龄

旧设定可确认：

```text
原作 / 早期 AU 锚点：约 24 岁
```

Hoshimi 成年研究者视觉稿已经明确表现为：

```text
late 20s – early 30s
```

因此本稿不伪造一个“此前已经锁死”的具体年龄。

### 推荐程序值

```yaml
age: 29
```

> 这是为了程序接入给出的**实现建议值**，不是声称旧对话已经把年龄锁死为 29。

---

# 2. Hoshimi 职业身份

## 正式定位

```text
访问研究医 / Visiting Research Physician
基础医学 / Biomedical Research
医疗仪器与生理监测 / Medical Instrumentation & Physiological Monitoring
```

推荐院内称呼：

```text
伊吹医生
伊吹研究员
```

正式文件可写：

> **星见综合医院・访问研究医 / 生物医学研究协力**

她不是：

- 常规门诊主治；
- 普通外科医生；
- 主要手术主刀；
- 长期病房责任医。

---

# 3. 研究领域

既有设定方向：

```yaml
research_fields:
  - biomedical_physiology
  - medical_instrumentation
  - vital_sign_modeling
  - monitoring_systems
  - experimental_medicine
```

中文解释：

- 生物医学 / 人体生理学；
- 生理信号建模；
- 生命体征监测；
- ICU / OR 监护系统；
- 医疗设备与传感器；
- 仪器校准；
- 实验医学；
- 医疗数据质量与异常检测。

---

# 4. 与双叶的生态位差异

伊吹摩耶与双叶不能写成两个“都会电脑的研究员”。

## 伊吹摩耶

```text
身体 / 生理 / 设备 / 监护
```

关键词：

- physiology
- sensor
- monitor
- signal
- instrumentation
- calibration
- bedside systems
- OR / ICU equipment

## 双叶

```text
认知 / 心理生理 / 数据 / 软件 / 模型
```

关键词：

- cognition
- psychophysiology
- behavior
- data analysis
- software
- algorithm
- pattern recognition

一句话：

> **双叶更像“从数据里看人”；摩耶更像“从机器和生理信号里看身体”。**

---

# 5. 临床权限与手术室生态位

既有方向：

```yaml
clinical_role:
  routine_clinician: false
  primary_surgeon: false
  assistant_surgeon: true
  OR_observer_or_technical_support: true
  equipment_support: true
  monitoring_support: true
```

她进入 OR 的理由主要是：

- 新监护设备试运行；
- 生理信号采集；
- 设备校准；
- 手术室仪器验收；
- 特殊病例监测；
- 教学手术的数据支持；
- 系统异常排查。

她可以理解手术流程，也能看懂大量术中数据，

但：

> **不要因为她来自 NERV，就把她直接写成外科高手。**

---

# 6. 专业能力建议

以下是为了 Codex 接入而建议的 Hoshimi 数值。

> 这些数值并非此前旧稿可确认的历史 canon，而是根据已经确定的角色生态位进行的程序化落地。

```yaml
skills:
  surgery: 42
  diagnostics: 62
  teamwork: 82
  patient_care: 58
  instrument_handling: 91
  calmness: 76
```

| 能力 | 建议值 | 理由 |
|---|---:|---|
| `surgery` | 42 | 受过足够 OR 训练，可在明确指令下承担有限第二助手工作，但不是外科专科医生 |
| `diagnostics` | 62 | 对生理数据和设备相关异常判断很强 |
| `teamwork` | 82 | 原作就是高可靠协作型技术人员 |
| `patient_care` | 58 | 温柔认真，但不是以床旁照护见长 |
| `instrument_handling` | 91 | 核心强项 |
| `calmness` | 76 | 平时稳定；极端道德/情绪冲击下会明显动摇 |

---

# 7. 视觉 Canon

## 7.1 主要 Hoshimi 成年视觉

当前最接近 Hoshimi 正式版本的设定图：

```text
Maya Ibuki Character Design Sheet.png
```

视觉特征：

- 成年后的及肩深棕 / 红棕发；
- 轻薄层次；
- 眼镜；
- 比 24 岁 NERV 时期更成熟；
- 仍保留伊吹摩耶清秀、偏中性的气质；
- 白大褂；
- 蓝紫色高领上衣；
- 黑色短裙；
- 深色丝袜；
- 黑色低跟 / 中跟鞋；
- 手持研究文件夹 / 平板。

这套服装具有非常明确的：

> **“她长大以后开始有意无意模仿赤木律子的职业形象。”**

的感觉。

---

# 7.2 备用视觉

另一张：

```text
Maya Ibuki Adult Character Design Sheet.png
```

可作为：

- NERV Medical & Life Sciences Division 研究制服；
- 外部研究机构工作服；
- 非 Hoshimi 白大褂场景

的参考。

---

# 7.3 原作视觉锚点

原始伊吹摩耶：

- 深棕近黑短发；
- 发尾轻微外翘；
- 清秀偏中性；
- 柔和棕灰 / 灰紫系眼睛；
- 认真、紧张、温柔；
- 标准 NERV 制服；
- 24 岁左右；
- 163 cm；
- 技术士官 / 操作员气质。

Hoshimi 成年版允许头发变长、戴眼镜、职业装成熟化，

但必须仍然：

> **一眼看得出是伊吹摩耶长大以后，而不是另一个泛用女研究员。**

---

# 8. 视觉关键词

```yaml
visual_keywords:
  - intelligent
  - restrained
  - slightly_androgynous
  - mature_maya
  - research_physician
  - ritsuko_influence
  - glasses
  - shoulder_length_brown_hair
```

禁止画错：

- 不要变成高冷成熟御姐；
- 不要画成泛用“性感女博士”；
- 不要过分妩媚；
- 不要把头发变成很长的波浪卷；
- 不要把眼镜画成厚重宅系镜框；
- 不要失去摩耶原本的清秀、认真、后辈感；
- 不要把律子的模仿写成“完全复制律子”。

核心：

> **她是摩耶自己，只是长大以后终于开始穿得有一点像她憧憬的人。**

---

# 9. 人格结构

## 公开形象

> 认真、礼貌、可靠、稍微有点拘谨。

第一次接触容易给人：

> **“很能干，但是不太会主动抢话的研究医生。”**

的感觉。

## 核心性格

```yaml
traits:
  - earnest
  - intelligent
  - dependable
  - modest
  - slightly_old_fashioned
  - shy
  - emotionally_transparent_under_pressure
```

伊吹摩耶的重点不是大表情。

而是：

> **努力保持专业，但情绪会从眼神里漏出来。**

已经确定的重要表情：

- 轻微困惑；
- 被夸后害羞；
- 紧张但克制；
- 低落；
- 惊讶；
- 犹豫；
- 专注；
- 松一口气。

---

# 10. 私下一面

保留原作反差：

- 喜欢吃零食；
- 工作区容易出现小包装零食；
- 对猫咪用品 / 猫造型物件有明显好感；
- 过去座位有猫形坐枕；
- 在正式场合很规矩；
- 私下比第一印象更柔软、更可爱。

她不是“冷面研究员”。

---

# 11. 赤木律子的影响

这是她成年版最重要的人格背景之一。

摩耶对赤木律子的感情至少包括：

- 崇敬；
- 憧憬；
- 后辈对前辈的依赖；
- 职业理想投射；
- 很深的私人感情。

Hoshimi 不需要对原作中她的性向作确定性宣判。

可保留：

> **她对律子的感情明显超出普通同事意义，但游戏不必急着给它贴标签。**

成年后的摩耶：

- 戴眼镜；
- 穿白大褂；
- 蓝色高领上衣；
- 黑裙；
- 丝袜；

这些都可以被其他角色看出：

> **“你是不是越来越像赤木博士了？”**

摩耶会明显害羞 / 否认：

> 「没、没有吧……只是这样比较方便。」

---

# 12. 压力反应

平时：

- 语气克制；
- 逻辑清楚；
- 对设备和数据非常有把握；
- 不抢领导权。

压力升高时：

- 语速加快；
- 会反复确认数据；
- 表情先变化，嘴上仍坚持专业；
- 道德上无法接受的情况会明显失去平静；
- 不擅长把强烈情绪藏得很深。

---

# 13. Voice Profile

```yaml
voice_profile:
  formality: high
  directness: medium
  playfulness: low
  sarcasm: low
  flirtiness: very_low
  emotional_openness: low_to_medium
  professional_distance: high
  sentence_length: medium
  technical_language: high_when_working
```

示例：

> 「这个波形不是患者的问题，是传感器本身的漂移。」

> 「先不要换设备。让我再看一次原始信号。」

> 「我、我没有紧张……只是想再确认一下。」

> 「这种时候相信感觉没有意义。看数据。」

---

# 14. 医院活动范围

推荐：

```yaml
presence:
  fixed_locations:
    - imaging
    - or
  random_locations:
    - lounge
    - exam
```

### `imaging`

可兼作：

> 检验 / 生理监测 / 设备研究区域

的现有地图接口。

### `or`

只在：

- 设备测试；
- 监护系统支持；
- 教学手术；
- 特殊研究病例

出现。

### `lounge`

可以看到：

- 零食；
- 猫咪小物；
- 她少见的放松状态。

---

# 15. 解锁阶段

既有设定：

> **中期解锁。**

推荐：

```yaml
unlock_phase: midgame
```

不应 Day 1 就出现。

---

# 16. 推荐初次登场方式

> 本节属于 **Codex 接入建议**，不是声称旧版已经锁死的事件。

事件标题建议：

> **《波形不对》**

场景：

```text
OR / imaging
```

某台手术或监护测试中出现：

> 患者状态稳定，但监护系统持续显示异常。

摩耶检查以后判断：

> **不是人出问题，是设备数据链路出了问题。**

她通过：

- 原始波形；
- 传感器；
- 不同监测来源；
- 时间同步

快速定位到设备漂移 / 校准异常。

第一次就明确告诉玩家：

> **她的强项不是拿刀，而是告诉你机器什么时候在撒谎。**

---

# 17. 与坂口隆司

她不是恋爱路线。

关系定位：

> **专业合作伙伴 / 外部研究同事。**

坂口对她的初印象：

> “像是把每件事都确认三遍才肯放心的人。”

摩耶对坂口：

> “临床医生的直觉很好，但有时候太相信自己看到的东西。”

两人互补：

```text
坂口：
临床经验 / 术野 / 决策

摩耶：
数据 / 设备 / 系统异常
```

她可以在某些事件里提醒坂口：

> 「你看到的是患者。」

> 「我看到的是机器怎么看患者。」

---

# 18. 与现有角色的关系

## 城宮明日香

正式合作、制度化接待。

明日香会喜欢她：

> 文档完整、流程规范、设备报告好读。

但偶尔会觉得：

> 摩耶把一份简单报告写得太详细。

## Aqua

Aqua 对新设备非常有兴趣，

但容易：

> “先拿来用再说。”

摩耶则：

> “请先完成校准。”

可以形成轻喜剧。

## 深山佳織

深山尊重：

> 能够提供可靠客观数据的人。

## 御堂江美子

美子最初可能认为：

> “机器只是辅助。”

摩耶则不会正面争辩，

而是在一次真正设备异常 / 生理监测事件中证明：

> **机器不代替外科医生，但错误的机器可以骗过外科医生。**

---

# 19. 关系系统

既有设定明确：

```yaml
romance_route: false
adult_route: false
```

因此不要给她套用常规：

```text
Lv4 恋爱
Lv5 Staff-as-Patient H
```

如果程序必须拥有 relationship 值，

推荐：

```yaml
relationship_route: professional_friendship
relationship_max_level: 3
```

或者：

```yaml
relationship_route: none
```

只用：

- met
- trust
- professional_respect

三个变量。

此项此前没有完全锁死，Codex 可以按现有角色系统最小改动实现。

---

# 20. Ambient / 小事件种子

## 20.1 自动贩卖机

坂口第一次发现：

> 一直很认真吃健康午餐的摩耶，抽屉里塞满零食。

摩耶：

> 「这是……实验期间需要的快速糖分。」

坂口：

> 「猫形饼干也是？」

摩耶：

> 「……那个和研究没关系。」

## 20.2 猫坐枕

她临时工位不知道什么时候多了一个猫形坐垫。

有人问：

> 「这是你从 NERV 带来的？」

摩耶：

> 「不是。」

停一下。

> 「新的。」

## 20.3 “像律子”

南条 / Aqua / 其他观察力强的角色可以问：

> 「伊吹医生，你这身是不是故意学某个人？」

摩耶明显僵住：

> 「……没有。」

然后立刻低头整理文件。

---

# 21. 手术室特殊功能

摩耶可以参与的 Special Event：

### 监护设备异常

- 生理数据和临床表现冲突；
- 摩耶协助判断设备 vs 患者。

### 新 OR 验收

- 参与设备测试；
- 负责监护 / 数据记录部分。

### Public Teaching Surgery

- 不作为主刀；
- 可负责生理数据展示；
- 解释实时监护变化；
- 对观察者展示：
  > “手术中的身体如何被转译成波形和数字。”

### 医院祭

可以负责：

> “你看到的生命体征是真的吗？”

小型监护体验摊位。

---


# 21.1 可被临时拉上台：特殊 Assistant

当前 Hoshimi 手术 gameplay 并没有进一步区分：

```text
第一助手
第二助手
技术助手
```

游戏层面使用的是一个统一的：

> **Assistant**

角色槽。

因此摩耶的处理必须遵循现有系统，而不是为她单独新增第二套岗位架构。

她可以在解锁后：

```yaml
surgical_roles:
  - assistant_surgeon
```

也就是说：

> **玩家可以把伊吹摩耶直接放进现有 Assistant 槽。**

在剧情表现上，她就是：

> **被临时拉来上台的访问研究医 / 特殊助手。**

---

## 她为什么能当 Assistant

摩耶不是纯工程师。

她是：

> **访问研究医 + 原 NERV 高强度技术系统操作人员。**

因此她可以合理具备：

- OR 无菌环境基础训练；
- 手术团队协作经验；
- 基础器械识别；
- 在主刀明确指令下保持术野；
- 基础牵开；
- 简单辅助操作；
- 监护设备与传感器处理；
- 生理数据判断。

但：

> **她不是隐藏的外科高手。**

她不应该：

- 主动抢主刀判断；
- 对复杂术式提出像御堂 / 深山那样的高级外科建议；
- 在纯外科技术场景中压过真正外科医生。

---

## Gameplay 生态位

摩耶作为 Assistant 的特点：

```text
普通外科支持：中等
主动外科判断：偏弱
团队协作：高
设备处理：极高
监护判断：极高
数据异常识别：极高
```

所以玩家会逐渐发现：

> **她不是“万能助手”。**

但在：

- 新设备；
- 高监护依赖病例；
- 生理信号异常；
- 实验性监测；
- OR 系统故障；

这类手术里，

> **她可能比普通临床助手更有价值。**

这与飯村真奈美的特殊助手逻辑一致：

> **角色本职并不是外科，但可以通过特殊资格进入 Assistant 槽，并以自己的专业能力改变手术体验。**

---

# 21.2 首次被拉去当助手

这不需要单独做一台剧情式大手术。

完全可以做成：

> **第一次玩家在手术编队里选择摩耶作为特殊助手时，触发一次性 OR 对白。**

示例：

**坂口**

> 「伊吹医生，会不会基本助手操作？」

**摩耶**

> 「……会一点。」

**坂口**

> 「一点是多少？」

摩耶明显认真起来。

> 「不会给你添麻烦的程度。」

换好 scrub / 手术帽 / 口罩以后，她站到台旁。

第一次真正站进 Assistant 位时会有一点紧张。

但一旦主刀开始给明确指令：

> 「这里保持住。」

> 「好。」

> 「再往外一点。」

> 「明白。」

她会迅速进入非常稳定的工作节奏。

这个第一次事件的功能：

> **告诉玩家，她不是外科医生，但她确实是一个可以信赖的 OR 技术型同伴。**

---

# 21.3 摩耶专属 Voice Anchors

后续所有日常和 OR 对白，都应尽量围绕四个声音锚点展开。

## A. 技术状态

最像 NERV 操作员时期的摩耶。

说话特点：

- 准确；
- 克制；
- 先确认数据；
- 不喜欢凭感觉乱猜。

示例：

> 「先不要判断患者，先确认这个波形是不是可信。」

> 「临床表现没有同步变化。传感器先查一遍。」

> 「这个数值不对，但我更怀疑机器。」

---

## B. 害羞状态

她不会大喊大叫。

而是：

> **先否认，然后眼神和停顿把情绪漏出来。**

示例：

> 「我没有紧张……只是想再确认一下。」

> 「没有特别在意。真的。」

> 「……请不要一直看我。」

---

## C. “不洁”吐槽

保留原作著名的：

> **「不潔……」**

但必须低频使用。

触发条件：

- 成年同事明显打情骂俏；
- 南条故意调戏坂口；
- Aqua / 其他角色说出过度直白的成人玩笑；
- 医护休息时秀恩爱或暧昧。

典型演出：

南条：

> 「坂口医生，今天下班以后有空吗？」

坂口：

> 「你又想干什么？」

南条：

> 「我还什么都没说呢。」

摩耶低头看平板。

> 「……不洁。」

南条：

> 「伊吹医生，你刚才是不是说了什么？」

摩耶：

> 「没有。」

### 禁止误用

她**绝不能**因为以下情况说“不洁”：

- 患者裸露；
- 备皮；
- 导尿；
- 妇科检查；
- 乳房检查；
- 手术体位；
- 医疗上必要的身体接触。

对摩耶来说：

> **医疗就是医疗。**

“不洁”只针对：

> **成年人明明可以好好工作，却偏偏在她面前调情。**

---

## D. NERV 式生物学阴影

这是她进入开放手术以后最有辨识度的反应。

摩耶不是怕血，也不是看到内脏就无法工作。

真正触发她的是：

> **湿润、活动、有机、仍在蠕动的组织让她想起 EVA / 使徒相关经历。**

她会有一瞬间的：

- 脸色变白；
- 咽一下；
- 把视线移开；
- 很轻的反胃；
- 不愿解释自己想起了什么。

但不会长时间失能。

---

# 21.4 术中互动：开放腹腔第一次触发

推荐：

```yaml
maya_or_interaction_open_abdomen_first:
  once_per_save: true
  requires:
    - maya_role == assistant_surgeon
    - surgery_field == abdominal_open
```

腹膜打开。

大网膜和腹腔脏器进入视野。

摩耶原本一直在看监护屏。

她下意识往术野里看了一眼。

停住。

**坂口**

> 「怎么了？」

摩耶脸色有一点白。

> 「没什么。」

又看了一眼。

> 「……就是突然想起了非常不好的东西。」

坂口：

> 「NERV？」

摩耶：

> 「请不要继续问。」

然后她重新盯回监护。

> 「生命体征稳定。继续。」

重点：

> **她不是因为普通外科场面害怕，而是被旧记忆精准击中。**

---

# 21.5 术中互动：肠管蠕动

当开放腹腔 / 盆腔手术出现明显肠蠕动时，可低概率触发。

摩耶：

> 「……它还在动。」

坂口：

> 「肠子当然会动。」

摩耶：

> 「我知道。」

坂口看她。

> 「那你为什么这个表情？」

摩耶停两秒。

> 「因为我以前看过另一种‘会动的东西’。」

坂口：

> 「……别告诉我。」

摩耶：

> 「我也不想告诉你。」

触发以后继续正常工作。

---

# 21.6 术中互动：短暂作呕

借鉴她看到暴走初号机吞吃使徒时的反应。

只允许发生在：

```text
非危急阶段
+
患者稳定
+
摩耶并非当前唯一关键操作者
```

绝不能在：

- 大出血；
- 心跳骤停；
- 严重并发症；
- 主刀正在等待她完成关键动作

时拿来做喜剧。

演出：

某个有机组织的运动 / 牵拉让她突然想起过去。

摩耶猛地把脸转开。

坂口：

> 「伊吹？」

> 「没事……让我两秒。」

她闭眼，压住一阵恶心。

深呼吸一次。

再转回来。

> 「好了。」

看一眼监护。

> 「数据正常。继续。」

长期 callback：

别人：

> 「你不是在 NERV 看过更夸张的吗？」

摩耶：

> 「所以我才知道有些东西不应该看第二次。」

---

# 21.7 术中互动：说漏嘴的 EVA 比喻

极低概率。

不能每台手术都出现。

某次看到异常的组织收缩 / 生理反应：

摩耶：

> 「这个反应……有点像 EVA 的——」

她突然停住。

坂口：

> 「什么？」

摩耶：

> 「没有。」

坂口：

> 「你刚才明明说了 EVA。」

摩耶低头确认屏幕：

> 「请专心手术。」

---

# 21.8 设备异常：摩耶真正的高光

与上面的吐槽不同，

只要监护数据出现矛盾，她立刻完全进入技术状态。

例如：

监护数据突然下降。

其他人第一反应：

> 患者状态恶化。

摩耶：

> 「等一下。」

她比较另一组信号。

> 「这个下降不是出血。」

坂口：

> 「确定？」

> 「确定。」

> 「另一组信号没有同步变化。」

她迅速确认设备。

> 「传感器基线漂移。」

> 「患者本身稳定。」

这里禁止加入 EVA 玩笑。

这是她真正的专业高光。

---

# 21.9 手术中“调情 → 不洁”彩蛋

只有在：

```text
患者稳定
非关键步骤
医护之间真的在成人调情
```

时才允许触发。

例如南条作为助手 / 旁观：

南条：

> 「坂口医生，你手这么稳，平时是不是也——」

摩耶：

> 「……不洁。」

全场安静半秒。

坂口：

> 「你一直在听？」

摩耶：

> 「手术室这么安静，当然听得到。」

然后马上：

> 「监护正常。」

这种对白的重点：

> **摩耶可以吐槽同事，但不会拿患者的身体当成人笑话。**

---

# 21.10 术后助手评价

第一次作为助手完成手术以后：

坂口：

> 「比你自己说的‘会一点’强。」

摩耶：

> 「因为都是很基础的操作。」

> 「而且你一直在给指令。」

坂口：

> 「下次还来？」

摩耶看了一眼刚刚关闭的术野。

停顿。

> 「……如果能让我主要看屏幕的话。」

坂口：

> 「那就是愿意。」

摩耶：

> 「我没有这么说。」

但没有否认第二次。

---

# 21.11 系统化，而不是强制剧情手术

当前不必为了摩耶专门制作一台完整“摩耶剧情手术”。

更合适的第一阶段实现是：

```text
摩耶解锁
↓
Assistant 资格解锁
↓
玩家在允许的手术中可把她放入 Assistant 槽
↓
第一次上台触发专属 intro
↓
她作为 Assistant 时，根据当前术野触发专属器官吐槽 / NERV 反应
↓
设备异常时有特殊能力
↓
开放腹腔 / 胸腔 / 特殊组织时有低频 NERV callback
```

这样：

> **即使没有单独写一台摩耶专属剧情手术，她仍然会在 gameplay 里非常像伊吹摩耶。**

如果以后某次觉得她值得一台完整剧情式手术，

再从这些已经建立的反应里升级即可。

---

# 21.11A 器官吐槽 / NERV 反应只在她担任 Assistant 时触发

这一点固定下来。

摩耶关于：

- 腹腔脏器；
- 肠管蠕动；
- 胸腔内结构；
- 湿润、活动的活体组织；
- “像 EVA / 使徒”的联想；
- 短暂反胃；
- 说漏嘴的 EVA 比喻；

这些互动：

> **默认只在她实际被玩家编入 Assistant 槽时触发。**

不要在她只是：

- 站在观察区；
- 做设备维护；
- 路过 OR；
- 普通 ambient；

时频繁触发。

原因：

> **只有真正站到手术台边、被迫持续面对开放术野时，这些反应才有角色价值。**

---

## 触发层级

### Level A — 第一次开放腹腔

高优先，一次性。

> 「……就是突然想起了非常不好的东西。」

### Level B — 肠管 / 组织明显活动

低概率。

> 「……它还在动。」

### Level C — 特殊生物学画面

极低概率。

> 「这个反应……有点像 EVA 的——」

然后自己停住。

### Level D — 生理性反胃

只在非危急阶段触发。

> 「没事……让我两秒。」

随后恢复。

---

## 不要变成梗机器

摩耶每台手术都提 EVA 会迅速失去效果。

因此：

```yaml
maya_visceral_callbacks:
  require_assistant_role: true
  first_open_abdomen_once: true
  eva_reference_cooldown_cases: 3
  nausea_reaction_rare: true
```

目标是：

> **玩家偶尔才会突然意识到：这个正在帮自己牵开术野的研究医，曾经见过一些远比普通外科更糟糕的东西。**

---


# 21.12 推荐程序 Tags

```yaml
maya_or_tags:
  assistant_surgeon: true
  special_assistant: true
  equipment_specialist: true
  strong_monitoring: true
  visceral_memory_trigger: true
  low_frequency_eva_callback: true
  flirtation_disapproval: true
  snack_habit: true
  cat_cushion_habit: true
```

建议互动冷却：

```yaml
maya_or_callbacks:
  eva_reference_cooldown_cases: 3
  impure_comment_cooldown_days: 7
  visceral_reaction_first_open_surgery_only: true
```

避免把角色梗刷成口头禅机器。

---


---

# 22. 美术素材状态

目前已确认存在：

```text
Maya Ibuki Adult Character Design Sheet.png
Maya Ibuki Character Design Sheet.png
```

另有较早时期的：

- 原作锚点；
- 表情四宫格；
- NERV 制服；
- 医疗 AU 白大褂；
- 手术服；
- 护士服；
- 患者检查服；
- OR 半身资源。

但 Hoshimi 正式人物视觉建议优先使用：

> **`Maya Ibuki Character Design Sheet.png`**

作为成年访问研究医的主要锚点。

---

# 23. Codex 最终摘要

```yaml
id: visiting_maya
name: 伊吹 摩耶
romanized_name: Maya Ibuki
age: 29  # 推荐实现值；旧设定未锁死具体 Hoshimi 年龄
gender: female
adult: true

profession: visiting_research_physician
specialty:
  - biomedical_physiology
  - medical_instrumentation
  - physiological_monitoring

employment: temporary_visiting
team_category: research_medical

personality: >
  认真、谦逊、可靠、略拘谨的成年研究医；
  工作时极重视数据和设备可靠性，
  强烈情绪往往先从眼神里泄露。

clinical_role:
  routine_clinician: false
  primary_surgeon: false
  assistant_surgeon: false
  OR_observer_or_technical_support: true
  equipment_support: true
  monitoring_support: true

skills:
  surgery: 28
  diagnostics: 62
  teamwork: 82
  patient_care: 58
  instrument_handling: 91
  calmness: 76

presence:
  fixed_locations:
    - imaging
    - or
  random_locations:
    - lounge
    - exam

unlock_phase: midgame

visuals:
  canonical_reference: "Maya Ibuki Character Design Sheet.png"
  hair: shoulder_length_dark_brown
  glasses: true
  default_outfit:
    - white_lab_coat
    - blue_high_neck_top
    - black_skirt
    - dark_stockings
  design_note: "adult Maya with visible Ritsuko influence"

romance_route: false
adult_route: false
relationship_route: professional_friendship

surgical_roles:
  - assistant_surgeon

character_tags:
  - technical_precision
  - shy_professional
  - impure_comment
  - snack_habit
  - cat_cushion_habit
  - nerv_visceral_memory
```

---

# 24. Codex 不要做的事

```text
DO NOT:
- 把摩耶变成常驻外科主刀医生；她可以进入现有 Assistant 槽，但不能因此被写成外科专科高手
- 给她自动添加 H / romance 路线
- 把她和双叶写成同一类型研究员
- 把“像律子”写成完全复制律子人格
- 把她改成高冷御姐
- 忽略她原本的害羞、认真、温柔和后辈感
- 让她因为不是临床主刀就显得没用
```

---

# 25. 仍未从旧设定中完全锁死的字段

以下内容本稿已经给出推荐实现值，但不声称它们是旧 MD 的逐字恢复：

1. Hoshimi 精确年龄：推荐 29；
2. 程序内部 ID：推荐 `visiting_maya`；
3. relationship 是否采用 0–3 专业友谊等级，还是只用 trust/respect；
4. 访问期限是固定若干周 / 若干月，还是中期解锁后持续存在；
5. 初次登场是否直接采用《波形不对》。

其余核心方向：

> **访问研究医 / 生理监测与医疗仪器 / 中期解锁 / 不走 H 与 romance / 成年长发眼镜白大褂、模仿律子风格**

视为本稿主要 canon。

---

# END
