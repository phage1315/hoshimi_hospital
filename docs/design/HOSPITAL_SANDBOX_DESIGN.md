# 医院沙箱 VN —— 正式设计规格

## 0. 文档定位

本文件是“医院沙箱版”项目的正式设计规格，用于约束后续 Codex 开发、内容扩展、系统重构与美术资产管理。

**工作语言：中文。**  
建议所有设计说明、剧情说明、人物设定、开发任务均使用中文；但以下内容继续使用英文技术标识：

- 文件名
- 目录名
- 变量名
- 函数名
- JSON / YAML key
- 内部 ID
- Ren'Py label
- 事件标识
- 资源标识

例如：

```text
角色名：高桥美绪
角色 ID：nurse_021
事件 ID：nurse_021_rel_03
资源目录：characters/nurse_021/
```

---

# 1. 项目定位

**类型：** 日式医院生活模拟 × Visual Novel × 成人向角色关系沙箱  
**核心幻想：** “在这一年的医院生活里，我最终会成为一个怎样的医生？”  
**核心卖点：**

- 高自由度医院生活
- 多女性医护角色
- 大量可攻略对象
- 患者与病例收集
- 手术模拟
- 手术团队搭配
- 医生养成
- 职业晋升
- 关系培养
- 多结局
- 成人向与荒诞事件
- 高重复游玩价值

本项目**不需要强主线**。

医院生活本身就是主线。

---

# 2. 最高设计原则

沙箱版优先保证：

> **自由、情色、欢乐、荒诞、收集、养成、重复游玩。**

不应为了追求沉重主题而压缩玩家自由度。

玩家的乐趣不是：

> “我要完成作者唯一安排好的故事。”

而是：

> “这一周目，我想把自己的医院人生玩成什么样？”

---

# 3. 核心 Gameplay Loop

```text
医院探索 Hospital Explore
        ↓
门诊 / 病房 / 训练 / 社交 / 休息
        ↓
发现患者或角色事件
        ↓
问诊 / 检查 / 诊断
        ↓
治疗 / 入院 / 手术
        ↓
手术准备
        ↓
组建手术团队
        ↓
手术模拟
        ↓
结果 / 并发症 / 奖励
        ↓
人物关系变化
        ↓
属性变化
        ↓
进入下一个时间段
```

这一循环贯穿整个游戏年度。

---

# 4. 时间结构

时间本身是资源。

建议采用：

```text
一年
12个月
↓
每天：
Morning
Afternoon
Evening
```

不要求每天三个时间段都必须可操作，但玩家应该经常面对机会成本。

例如：

- 下午门诊 → 增加 Diagnosis，发现新患者
- 下午手术训练 → 增加 Surgery
- 晚上和护士约会 → 提升关系
- 晚上休息 → 降低 Stress
- 跟随资深女医手术 → 解锁新术式
- 参加行政会议 → 提升 Administration Favor
- 去研究室 → 解锁罕见病例或特殊路线

原则：

> **单周目不应该能够把全部角色、全部技能、全部患者、全部病例、全部结局同时完成。**

---

# 5. 主角属性

## 5.1 职业能力

推荐核心属性：

- `Diagnosis`
- `Surgery`
- `Emergency`
- `Communication`
- `Leadership`

可选扩展：

- `Research`
- `Administration`
- `Composure`
- `Dexterity`

---

## 5.2 个人状态

- `Energy`
- `Stress`
- `Confidence`

---

## 5.3 医院评价

- `PatientTrust`
- `StaffTrust`
- `ProfessionalReputation`
- `AdministrationFavor`
- `RomanceReputation`
- `Scandal`
- `Rumor`

---

# 6. 不使用单一善恶值

沙箱版不建议只做：

```text
Good / Evil
```

玩家应该通过行为自然形成“医生人格”。

例如：

### 圣人医生
- Communication 高
- PatientTrust 高
- 风险偏保守
- 患者非常喜欢

### 外科王牌
- Surgery 极高
- 高难手术能力强
- 社交时间不足

### 医院政治家
- AdministrationFavor 高
- Leadership 高
- 临床能力普通
- 晋升速度快

### 手术室暴君
- 技术极强
- StaffTrust 低
- 医护害怕但依赖其能力

### 社交明星
- 多角色高关系
- StaffTrust 高
- 医术未必顶尖

### 医学怪人
- 喜欢奇怪病例
- 解锁大量特殊事件
- 擅长非主流玩法

### 恋爱灾难
- 多线关系重叠
- Rumor 高
- Scandal 高

### 庸医传奇
- 医术普通
- 靠运气、人际关系或荒诞事件混到年底

这些不是职业类，而是玩家行为产生的结果。

---

# 7. 医护角色规模

长期目标：

- 约 **20 名成年护士**
- 约 **10 名成年女医生**

所有可攻略、成人向角色必须明确为成年人。

不要求所有角色同等深度。

---

## 7.1 核心可攻略角色

建议：

- 6–8 名护士
- 4–5 名女医生

这些人物拥有：

- 完整关系线
- 多套服装
- 手术互动
- 私人事件
- 成人向事件
- 个人结局
- 专属 CG
- 专属团队技能

---

## 7.2 次级角色

可拥有：

- 简化社交
- 少量个人事件
- 手术团队功能
- 若干特殊对白

---

## 7.3 背景角色

只需要：

- 头像或基础立绘
- 简短对白池
- 医院氛围功能

---

# 8. 医护角色数据结构

建议采用数据驱动。

```yaml
id:
name:
age:
adult: true

role:
department:
seniority:

personality:
  primary:
  secondary:

skills:
  surgery:
  instruments:
  emergency:
  teamwork:
  patient_care:
  leadership:

relationship:
  affection:
  trust:
  respect:
  familiarity:

hospital_role:
  available_for_surgery:
  preferred_position:
  schedule:

outfits:
  - regular_medical_uniform
  - scrubs
  - surgical
  - casual

dialogue_style:
surgery_traits:
special_team_synergies:
personal_event_flags:
ending_flags:
```

---

# 9. 关系系统

推荐不要只用一个 `affection`。

至少包含：

- `Affection`
- `Trust`
- `Respect`
- `Familiarity`

关系可以通过以下内容变化：

- 一起工作
- 手术表现
- 处理困难患者
- 私人事件
- 下班社交
- 礼物 / 邀请
- 是否守约
- 医院风评
- 是否利用关系谋取利益

---

# 10. Persona 式人物关系结构

不必机械模仿 Rank 1–10，但应保留“条件式关系推进”。

例如：

```text
Stage 1
普通同事

Stage 2
建立信任

Stage 3
透露私人问题

Stage 4
共同解决职业冲突

Stage 5
私人关系明显加深

Stage 6+
恋爱 / 深度亲密 / 成人事件
```

部分角色要求：

- 某项属性达到阈值
- 完成指定手术
- 某种 Reputation
- 特定日期
- 特定患者事件
- 前置角色关系

---

# 11. 手术团队系统

重大手术前可选择：

- 主刀
- 助手医生
- 器械护士
- 巡回护士
- 可选麻醉角色
- 可选专科医生

每名角色应提供：

- 技术加成
- 性格影响
- 团队化学反应
- 压力行为
- 特殊对白
- 配对 synergy

最强的四个人不一定组成最强的团队。

建议有：

`TeamChemistry`

例如：

```text
资深器械护士 + 新人助手
→ 器械效率高
→ 新人压力增加

温柔巡回护士 + 高焦虑患者
→ PatientStress 下降

两个互相竞争的医生
→ 技术输出高
→ 高压时 teamwork 下降
```

---

# 12. 手术系统

手术是沙箱版最重要的重复玩法之一。

不要只做固定分支：

```text
A → B → C → 成功
```

应采用状态驱动。

---

## 12.1 患者状态

```text
Patient
- stability
- blood_loss
- oxygenation
- stress
- pain
```

---

## 12.2 术野状态

```text
Surgical Field
- visibility
- bleeding
- contamination
- progress
```

---

## 12.3 团队状态

```text
Team
- focus
- fatigue
- stress
- chemistry
```

---

## 12.4 手术状态

```text
Operation
- elapsed_time
- risk
- complication_state
```

---

# 13. 手术决策原则

任何重要动作都应产生取舍。

例如：

```text
改善术野
→ visibility +
→ time +

激进推进
→ progress ++
→ complication_risk +

让助手处理
→ 结果取决于 assistant skill / relationship / stress

暂停重新评估
→ time +
→ risk 可能下降
```

不允许存在一种永远最优的打法。

---

# 14. 手术难度

可提供：

### Casual
- 提示多
- 失败惩罚轻
- 适合以 VN 为主的玩家

### Normal
- 正常状态管理
- 有信息不完全
- 有并发症

### Expert
- 资源严格
- 风险更高
- 更强调 Team Selection

---

# 15. 患者系统

患者既是故事内容，也是收集内容。

病例类型：

- 普通病例
- 稀有病例
- 急诊病例
- 隐藏病例
- 高难手术
- 角色专属病例
- 季节病例
- 荒诞病例
- 成人向特殊病例

---

# 16. 患者性格系统

建议参数：

- `Anxiety`
- `PainSensitivity`
- `Embarrassment`
- `Trust`
- `NeedForControl`
- `Expressiveness`
- `HealthLiteracy`
- `Compliance`

同一病例，不同性格患者应出现不同：

- 对话
- 检查反应
- 手术反应
- CG触发
- 医患关系变化

---

# 17. 患者视觉状态

重要患者建议至少支持：

```text
outpatient
hospital
surgical
recovery
```

即：

- 门诊便服
- 住院患者服
- 手术状态
- 术后恢复状态

普通患者可采用模块化资产减少工作量。

---

# 18. 成人向 / 荒诞沙箱逻辑

沙箱版允许出现现实中不合理、但符合成人 VN 与荒诞游戏逻辑的内容。

前提：

- 明确虚构
- 不作为现实医疗教学
- 所有参与成人向内容的人物均为成年人
- 自愿事件应明确建立在游戏世界的关系条件上

可以存在：

- 夸张医疗挑战
- 特殊“风险模式”
- 荒诞患者反应
- 成人角色扮演
- 关系 MAX 特殊训练
- 医护自愿扮演患者
- 黑色幽默
- 成人 CG
- 高关系特殊手术事件

不需要为所有荒诞内容写三章现实合理化。

---

# 19. 特殊关系奖励示例

例如：

```text
Trust MAX
Affection MAX
Surgery >= threshold
special_event_flag = true
```

则解锁：

```text
Volunteer Patient Training Event
```

即某名女医或护士自愿作为特殊“训练患者”参与一个明显带有游戏化、幻想化性质的事件。

该事件的价值包括：

- 身份反差
- 换装
- 专属 CG
- 特殊对白
- 关系奖励
- 手术挑战
- 喜剧 / 成人内容

---

# 20. 年终结算

游戏在一年结束时进行多轴结算。

不要只给单一 ending。

---

## 20.1 职业结局

可能包括：

- 普通主治医
- 外科专家
- 科室主任
- 外科主任
- 副院长
- 院长
- 研究型医生
- 被降职
- 主动离职
- 被医院逐出

---

## 20.2 关系结局

- 单角色恋爱结局
- 多角色关系
- 医院万人迷
- 医院后宫式搞笑结局
- 工作狂单身
- 多线崩盘
- 女性公敌

---

## 20.3 风评结局

- 患者最信赖医生
- 手术室暴君
- 行政攀升者
- 绯闻制造机
- 医学怪人
- 女性公敌
- 天才但讨人厌
- 众人敬爱的前辈

---

# 21. 结局展示建议

```text
CAREER
外科主任

RELATIONSHIP
高桥美绪 — 长期伴侣

REPUTATION
技术顶尖，但医院风评危险

SPECIAL TITLE
“手术室皇帝”
```

多轴结算比单一路线结局更符合沙箱玩法。

---

# 22. 不需要强主线

本游戏没有必要设置：

- 巨大医院阴谋
- 世界级危机
- 必须完成的悬疑主线

可以有轻事件作为节奏点：

- 新人入职
- 医院活动
- 流感季
- 人手不足
- 科室调整
- 年度评定
- 手术竞赛
- 晋升面谈

这些只是让一年更有节奏。

---

# 23. 高重复游玩目标

玩家应该自然产生：

> “上一周目我练外科。”

> “这一周目我要追某位护士。”

> “下一周目我要升副院长。”

> “再下一周目我要把全部稀有患者找出来。”

而不依赖传统剧情 True End。

---

# 24. 美术方向

沙箱版建议：

- 色彩明快
- 角色有吸引力
- 表情丰富
- 换装数量多
- CG数量多
- 喜剧反应明显
- 可适度带2000年代成人AVG的俗艳感
- 医疗制服审美占重要位置

---

# 25. 医护服装标准状态

## 护士

- `nurse_uniform`
- `scrubs`
- `surgical`
- `casual`

## 女医生

- `white_coat`
- `scrubs`
- `surgical`
- `casual`

## 患者

- `outpatient`
- `hospital`
- `surgical`
- `recovery`

---

# 26. 最重要的软件架构原则：内容必须可插拔

这是沙箱版的最高优先级技术原则之一：

> **新增角色、患者、病例、手术、CG，原则上不修改核心游戏逻辑。**

新增内容应尽量只是：

> 增加一个内容包。

而不是：

> 修改多个核心 `.rpy` 文件。

---

# 27. 推荐内容目录

```text
content/
├── characters/
├── patients/
├── surgeries/
├── cases/
├── cg/
└── packs/
```

---

# 28. 医护角色内容包

例如新增护士：

```text
content/
└── characters/
    └── nurse_021/
        ├── character.yaml
        ├── events.yaml
        ├── dialogue/
        ├── portraits/
        ├── outfits/
        ├── cg/
        └── ending.yaml
```

---

# 29. 医护角色示例

```yaml
id: nurse_021
name: 高桥美绪
age: 26
adult: true

role: nurse
department: surgery

personality:
  primary: cheerful
  secondary: competitive

skills:
  instruments: 82
  teamwork: 74
  patient_care: 66

romanceable: true

outfits:
  - nurse_uniform
  - scrubs
  - surgical
  - casual

events:
  intro: nurse_021_intro
  relationship_1: nurse_021_rel_01
  relationship_2: nurse_021_rel_02
  max_event: nurse_021_max

ending:
  id: nurse_021_romance_end
```

核心程序应自动发现并注册。

---

# 30. CG Manifest

不要把 CG 硬编码到多个剧情脚本。

推荐：

```yaml
cg:
  introduction:
    file: cg_intro.webp
    unlock: event_intro_complete

  surgery:
    file: cg_surgery.webp
    unlock: surgery_together >= 3

  relationship_max:
    file: cg_relationship_max.webp
    unlock: relationship_rank >= 4
```

Gallery 应根据 manifest 自动注册。

新增 CG：

> 添加图片 + 修改 manifest

不修改 Gallery 核心代码。

---

# 31. 患者内容包

```text
content/
└── patients/
    └── patient_043/
        ├── patient.yaml
        ├── case.yaml
        ├── dialogue.yaml
        ├── sprites/
        │   ├── outpatient/
        │   ├── hospital/
        │   └── surgical/
        └── cg/
```

---

# 32. 患者数据示例

```yaml
id: patient_043
name: 水野遥
age: 24
adult: true

personality:
  primary: anxious
  secondary: polite

traits:
  anxiety: 78
  pain_sensitivity: 65
  embarrassment: 72
  trust_initial: 35
```

---

# 33. 病例数据示例

```yaml
chief_complaint:
  - abdominal_pain
  - nausea

possible_diagnoses:
  - appendicitis
  - ovarian_cyst

available_tests:
  - physical_exam
  - blood_test
  - ultrasound
  - ct

treatment:
  conservative: false
  surgery:
    procedure: appendectomy
```

---

# 34. 手术模块化

建议：

```text
surgeries/
├── appendectomy/
├── cholecystectomy/
├── thyroid_surgery/
├── breast_surgery/
└── ...
```

每种手术定义：

- 阶段
- 可用动作
- 状态变化
- complications
- team skill 要求
- CG 触发
- patient reaction
- difficulty

患者只需要：

```yaml
procedure: appendectomy
```

系统自动加载对应术式。

---

# 35. Content Pack 体系

推荐最终支持：

```text
content/
├── base/
│
├── staff_pack_01/
│   ├── doctors/
│   └── nurses/
│
├── patient_pack_01/
│   └── patients/
│
└── surgery_pack_01/
    └── surgeries/
```

这样后续可以轻易扩展：

- 新护士包
- 新女医包
- 新患者包
- 新手术包
- 新CG包
- 节日活动包
- 成人事件包

---

# 36. 新增角色理想工作流

未来给 Codex 的任务可以是：

> “新增一名32岁的成熟型女外科医生，可攻略。技术极高、态度严格、对患者非常温柔。加入白大褂、scrub、手术装和便服四套状态，设计6级关系事件和一个个人结局。”

理想结果：

```text
创建 doctor_011/
↓
创建 YAML
↓
创建事件脚本
↓
注册资源
↓
创建缺失美术清单
↓
自动加入关系系统
↓
自动加入 Team Selection
↓
自动加入 Ending Evaluator
↓
运行内容验证
```

**原则上不修改核心系统。**

---

# 37. 内容验证器

强烈建议建立：

```text
tools/validate_content.py
```

每次新增内容后自动检查：

- ID 是否重复
- 年龄是否存在
- `adult: true` 是否存在
- 必要服装是否齐全
- CG 路径是否存在
- 事件 label 是否存在
- 关系事件是否断链
- ending 是否配置
- 患者是否缺少必要状态
- 病例引用术式是否存在
- 角色 skill 是否引用错误
- manifest 是否合法

输出例如：

```text
doctor_011
✓ character.yaml
✓ 4 outfits
✓ 6 relationship events
✗ Missing CG: doctor_011_max.webp
✓ ending configured

patient_043
✓ patient data
✓ outpatient sprite
✓ hospital sprite
✗ missing surgical sprite
✓ surgery procedure found
```

---

# 38. Codex 开发约束

Codex 后续开发时应遵守：

1. 优先数据驱动，不硬编码角色。
2. 新增角色原则上不修改核心系统。
3. 新增患者原则上不修改核心系统。
4. 新增 CG 通过 manifest 注册。
5. 新增术式通过 surgery module 注册。
6. 角色、患者、病例、手术 ID 必须稳定。
7. 为内容包建立自动验证。
8. 不为了“剧情完整”强行加入沉重主线。
9. 沙箱自由度优先于主题表达。
10. 保持长期可扩展性。

---



# 38A. 对白必须成为沙箱版的主要奖励之一

沙箱版对白不得只承担“传达信息”的功能。

目标是：

> **玩家只看一句话，不看名字，也大致能猜出是谁在说。**

同一个医学事件，不同角色必须有明显不同的：

- 用词
- 句长
- 节奏
- 情绪表达
- 玩笑方式
- 距离感
- 称呼习惯
- 对主角的态度
- 对患者的态度
- 对手术风险的态度
- 调情方式

禁止所有角色都使用同一种“礼貌、职业、说明书式”语气。

---

# 38B. 角色 Voice Profile

每个核心角色应增加独立语气配置：

```yaml
voice:
  formality: 40
  directness: 75
  playfulness: 80
  sarcasm: 55
  flirtiness: 65
  emotional_openness: 70
  professional_distance: 35

speech_traits:
  sentence_length: short
  uses_teasing: true
  uses_nicknames: true
  uses_medical_jargon: low
  gets_blunt_under_stress: true

relationship_shift:
  early: professional
  mid: teasing
  high: intimate_playful
  max: openly_affectionate
```

Codex 写对白前必须读取角色 Voice Profile。

---

# 38C. 对白风格目标

沙箱版允许并鼓励：

- 轻佻玩笑
- 双关
- 擦边暗示
- 成人间调情
- 黑色幽默
- 手术室吐槽
- 角色之间互损
- 吃醋
- 暧昧称呼
- 关系升级后的明显口吻变化
- 非正式、甚至有些不正经的成年人对白

但必须始终保持：

> **“角色在说话”，而不是“作者在写黄色段子”。**

成人感应该来自：

- 人物关系
- 情境
- 身份反差
- 语气
- 称呼
- 角色之间积累的默契

而不是所有人都突然说同一种露骨台词。

---

# 38D. 对白强度分层

推荐建立：

```text
Tone 0 — Professional
Tone 1 — Casual
Tone 2 — Flirty / Suggestive
Tone 3 — Adult Event
```

## Tone 0
正式工作状态。

## Tone 1
熟人式聊天、吐槽、玩笑。

## Tone 2
成年人之间明确暧昧、双关、挑逗、身份反差。

## Tone 3
仅在已解锁的成人事件中出现。
核心系统只负责事件触发、角色状态和内容注册，不应把成人事件硬编码进公共对白池。

---

# 38E. 同一事件必须体现角色差异

例如主角在手术前说：

> “今天这台手术时间可能很长。”

不同角色：

### 冷静资深器械护士
> “那你最好别在第三个小时才想起来要喝水。我可不会替你拿吸管。”

### 活泼年轻护士
> “很长？那我先声明，超过饭点你欠我一顿。”

### 严格女外科医生
> “时间长不是问题。拖沓才是。别让我看到你犹豫。”

### 成熟调侃型女医
> “这么早就开始给自己找借口？医生，你今天最好让我刮目相看。”

四句话必须明显属于不同的人。

---

# 38F. 关系等级必须改变说话方式

同一角色在不同关系阶段，应有明显变化。

例如同一句：

> “手术结束以后来找我。”

### Early
> “术后请到办公室一趟，我要看记录。”

### Mid
> “结束以后来找我。别装没听见。”

### High
> “做完来找我，我给你留点吃的。你敢先跑，我就去手术室抓人。”

### Max
> “结束以后你归我。工作已经够久了，今晚别再拿医院当借口。”

这类变化比单纯 `Affection +5` 更有价值。

---

# 38G. 手术室对白必须有“活人感”

手术过程中不要只有：

```text
“血压下降。”
“收到。”
“请给器械。”
```

应增加：

- 角色互相提醒
- 紧张时的口气变化
- 熟人之间的默契
- 失误后的吐槽
- 成功后的放松
- 患者情况好转后的情绪
- 对主角技术的评价

例如：

> “吸引。快一点——对，就是那里。……很好，终于像个能让我放心的医生了。”

或者：

> “你要是再把术野弄成这样，我下次真的只给你安排门诊。”

信息和人物塑造应同时存在。

---

# 38H. 患者对白也必须有明显性格

患者不能只分：

```text
害怕 / 不害怕
```

需要体现：

- 高焦虑
- 强装镇定
- 羞怯
- 话痨
- 理性
- 控制欲
- 怕痛
- 喜欢开玩笑
- 对医生有好感
- 不信任医生

例如检查前：

### 焦虑型
> “医生，你先告诉我最坏可能是什么……不，我还是先别听。等等，还是告诉我吧。”

### 强装镇定型
> “没关系，我不怕。……你刚才拿的那个东西是做什么的？”

### 活泼型
> “我配合检查可以，不过检查完你得告诉我到底是不是我昨晚那顿拉面害的。”

---

# 38I. 不要让所有角色都“高情商”

角色可以：

- 说错话
- 过度直接
- 爱吐槽
- 爱嫉妒
- 嘴硬
- 对某些人明显偏心
- 在压力下脾气变差
- 拿主角开玩笑
- 因关系过近而越界

这些缺点会让角色更有生命力。

---

# 38J. 成人向内容的设计原则

沙箱版可以包含明确成年人之间的成人向关系、成人幽默和高关系特殊事件。

但系统设计层面应将成人内容做成：

```text
optional_content_pack
```

并支持：

```yaml
adult_content:
  enabled: true
  event_pack: adult_pack_01
```

成人内容不应破坏：

- 普通模式
- 主线功能
- 手术系统
- 非成人玩家的基本游戏循环

角色关系可以在没有成人内容时依然完整。

---

# 38K. Codex 对白生成规则

Codex 生成或改写对白时必须：

1. 先读取该角色 `Voice Profile`。
2. 根据当前关系阶段改变距离感。
3. 根据场景决定 `Tone`。
4. 同一功能性信息至少允许 3 种角色化表达。
5. 禁止大批角色共用模板句。
6. 禁止过多说明式台词。
7. 尽量用短句、反问、停顿、吐槽、称呼变化制造节奏。
8. 手术对白要同时承担“信息 + 人物塑造”。
9. 患者对白要同时承担“症状 + 性格”。
10. 关系越深，语言越私人化。
11. 高关系事件允许明显暧昧与成人化语气，但必须保持人物身份一致。
12. 如果一段对白只是在“解释系统”，应优先重写成自然人物交流。


# 39. 开发优先级

推荐顺序：

1. 稳定 Hospital Explore
2. 日历 / 时间资源系统
3. Character Database
4. Relationship System
5. Patient / Case Database
6. Team Selection
7. State-driven Surgery
8. Career Progression
9. Ending Evaluator
10. Content Pack Loader
11. Content Validator
12. 扩展大量角色、患者、病例、CG
13. 成人向 / 荒诞特殊内容

---

# 40. 一句话设计法则

> **沙箱版的目的，是让玩家自由创造一个成功、荒诞、浪漫、情色、灾难性或令人难忘的医院人生。自由与重复游玩优先于沉重主题。**
