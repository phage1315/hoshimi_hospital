# Hoshimi Hospital — 水城アクア完整角色基础与事件接入规格
## Aqua Gynecology Director Character / Intro / Lv1 / Surgery Interaction
### Codex Implementation Design
### Version 2.0

> 项目：Hoshimi Hospital / 星见医院  
> 角色：水城アクア（Mizushiro Aqua）  
> 原型：《この素晴らしい世界に祝福を！》アクア  
> Hoshimi 版本：明确成年医疗 AU  
> 文件用途：供 Codex 接入人物基础数据、相识事件、解锁条件、Lv1 事件与手术团队互动。  
> 注意：本文只定义已确定内容；Lv2–Lv5 暂不展开。

---

# 0. 角色总定位

一句话：

> **能在几分钟内看懂复杂盆腔病例，却能把自己困在新型妇科检查椅上的天才妇科主任。**

她的核心反差必须始终成立：

```text
医学上：
非常聪明
技术极强
妇科知识异常丰富
真正面对患者时可靠

生活上：
缺根弦
容易过度自信
不爱看说明书
社交过滤器低
经常说出让旁人尴尬的话
```

最重要的写作原则：

> **她可以因为笨把自己坑进去，但绝不能因为笨把患者坑进去。**

---

# 1. 基本资料

```yaml
id: doc_aqua
name: 水城アクア
display_name_zh: 水城阿库娅
romanized_name: Mizushiro Aqua

age: 28
gender: female
profession: doctor

specialty: gynecology
rank: gynecology_director

route_type: romance_candidate
adult: true
```

- 年龄：28
- 性别：女性
- 职业：医生
- 专科：妇科／妇产科中的妇科方向
- 职称：妇科主任
- 医院定位：妇科诊疗与手术的最高专业负责人之一
- 是否可攻略：是，未来可开放
- H 内容：未来可设计；本文仅定义 Lv1 的擦边医学事件
- Staff-as-Patient：未来可考虑，本文不展开

---

# 2. 职业生态位

阿库娅不是阿尔托莉雅型管理者，也不是御堂型“纯手术压制型”天才。

她的强项是：

> **妇科医学本身。**

尤其擅长：

- 盆腔解剖
- 妇科良性疾病
- 子宫肌瘤
- 卵巢囊肿
- 子宫内膜异位症
- 宫腔镜
- 腹腔镜妇科手术
- 经阴道术式
- 盆底与阴道修补
- 妇科术前检查
- 妇科体位和术野暴露

医院内部对她的典型评价：

> “别问她为什么二十八岁就当主任。”
>
> “让她看一眼病例你就知道了。”

---

# 3. 性格

核心关键词：

```text
天才
热情
自信
缺根弦
情绪丰富
好胜
嘴快
妇科医学狂热
```

## 3.1 公开形象

年轻、漂亮、亲近感很强。

第一次见她的人容易产生：

> “这个人真的是主任？”

真正工作五分钟后：

> “……她真的懂得离谱。”

## 3.2 她的“笨”是什么

允许：

- 不看设备说明书
- 自己测试新检查椅
- 按错按钮
- 把遥控器弄掉
- 忘记钥匙
- 说话不过脑
- 在走廊里大声讨论极其尴尬的妇科术式
- 医院祭中认真得离谱
- 对患者为什么会害羞反应慢半拍

禁止：

- 患者身份核对错误
- 药物剂量乱来
- 无菌原则失误
- 术式选择乱来
- 为了搞笑忽略真正医学风险
- 因粗心造成严重患者伤害

固定原则：

> **她会把自己困在妇科椅上。**
>
> **但不会把患者困在错误的医疗决定里。**

---

# 4. 患者照护风格

阿库娅不是没有同理心。

她真正的问题是：

> **妇科医学对她已经“正常到不能再正常”，因此经常忘记普通患者第一次面对这些检查和体位时会羞耻。**

典型：

阿库娅：

> “内裤脱掉，坐上去就可以了哦。”

患者明显僵住。

护士：

> “主任。”

阿库娅：

> “嗯？”

护士看她。

阿库娅：

> “……啊。”

立刻修正：

> “抱歉。第一次的话确实会紧张。”
>
> “我们一步一步来，不舒服就告诉我。”

重点：

> **她被提醒后能立即进入优秀医生状态。**

---

# 5. 六项能力

```yaml
skills:
  surgery: 95
  diagnostics: 96
  teamwork: 82
  patient_care: 87
  instrument_handling: 94
  calmness: 90
```

扩展建议：

```yaml
extended_skills:
  gynecology: 99
  pelvic_anatomy: 99
  hysteroscopy: 97
  laparoscopic_gynecology: 96
  vaginal_surgery: 97
```

仅作设定梗、不必正式程序化：

```yaml
flavor_stats:
  social_filter: 35
  manual_reading_willingness: 12
```

---

# 6. 手术熟练度与岗位

```yaml
surgery_proficiency: expert

surgical_roles:
  - primary_surgeon
  - assistant_surgeon
```

角色特色：

> **妇科类手术 = 顶级表现**

> **非妇科手术 = 仍然是合格医生，但没有明显兴趣和专属加成**

---

# 7. 偏好术式

```yaml
preferred_procedures:
  - hysterectomy
  - laparoscopic_gynecologic_surgery
  - myomectomy
  - ovarian_cystectomy
  - hysteroscopy
  - vaginal_surgery
  - pelvic_floor_repair
```

她尤其喜欢：

```text
截石位相关手术
经阴道术式
宫腔镜
复杂盆腔解剖
```

---

# 8. 初始地图与活动地点

建议：

```yaml
fixed_locations:
  - gynecology_exam
  - clinic

random_locations:
  - or
  - lounge
  - staff_office
```

她不需要单独办公室。

如果未来存在：

```text
gynecology_office
```

可作为她的科室工作地点。

---

# 9. 初始人物可见性

游戏开局：

```text
met_aqua = false
aqua_visible = false
aqua_surgery_team_unlocked = false
```

玩家不能主动找她。

也不能邀请她加入手术团队。

---

# 10. 相识事件解锁条件

玩家必须先成功完成：

```text
至少 1 台妇科类手术
```

程序条件：

```yaml
requires:
  gyne_surgery_success_count: ">= 1"
```

满足后：

```text
aqua_intro_available = true
```

玩家下一次访问：

```text
gynecology_exam
```

触发相识事件。

---

# 11. 为什么需要先完成 1 台妇科手术

叙事理由：

> 玩家先真正接触妇科病例，才有自然理由进入妇科检查室、与妇科主任建立正式工作接点。

玩法理由：

> 阿库娅不是开局免费获得的高级医生。

角色理由：

> 她第一次对坂口产生兴趣，是因为：

> **“哦，你已经开始做妇科手术了？”**

这也为后续累计 5 台的 Lv1 Gate 做自然铺垫。

---

# 12. 相识事件：《新设备测试》

### Event ID

```text
aqua_intro_exam_chair
```

### Location

```text
gynecology_exam
```

### Relationship

```text
Lv0
```

妇科刚换了一台新型电动妇科检查椅。

阿库娅决定自己测试。

不是患者，不涉及裸露，她穿正常工作服／白大褂。

逻辑：

```text
自己坐上去
↓
觉得按钮很直观
↓
不看说明书
↓
按错模式
↓
腿托升起
↓
椅背放倒
↓
遥控器滑到够不到的位置
↓
被困
```

---

# 13. 主角发现她

坂口进入检查室。

听到：

> “……有人吗？”

以为是患者。

看到阿库娅卡在检查椅上。

阿库娅非常认真：

> “麻烦你帮我一个忙。”

坂口：

> “你是患者？”

阿库娅：

> “不是。”

坂口：

> “护士？”

阿库娅：

> “医生。”

坂口：

> “那为什么……”

阿库娅：

> **“设备测试出现了一点意料之外的结果。”**

坂口：

> “你卡住了？”

停顿。

阿库娅：

> **“这个描述没有错。”**

---

# 14. 主角把她放下来

坂口找到控制器／复位按钮。

检查椅恢复正常。

坂口：

> “说明书呢？”

阿库娅：

> “在那里。”

坂口：

> “你看了吗？”

阿库娅：

> “按钮看起来很直观。”

坂口：

> “然后？”

阿库娅：

> **“我验证了这个假设是错误的。”**

---

# 15. 身份揭露

此时护士敲门：

> “主任，下一位患者到了。”

坂口：

> “主任？”

阿库娅整理白大褂：

> “嗯。”

正式介绍：

> **“水城アクア。妇科主任。”**

---

# 16. 相识事件必须立刻展示专业能力

真正患者进入。

建议患者：

```text
成年女性
第一次妇科检查
明显紧张
```

刚刚还被椅子困住的阿库娅瞬间切换。

她：

- 先确认患者身份
- 询问症状
- 解释检查目的
- 说明过程
- 告诉患者可以随时表达不适
- 快速发现真正值得关注的问题
- 用非常清楚的语言解释下一步

重点：

> **这个缺根弦的人确实配得上“妇科主任”。**

---

# 17. 相识事件结尾

阿库娅知道坂口已经完成过妇科手术。

她可以随口问：

> “你就是最近开始做妇科病例的坂口医生？”

坂口：

> “你知道？”

阿库娅：

> “当然知道。”

然后观察他一下：

> “嗯……”

> “再多做几台。”

坂口：

> “什么意思？”

阿库娅：

> “以后再告诉你。”

作为 Lv1 Gate 的提示。

---

# 18. 相识事件结果

```yaml
sets:
  met_aqua: true
  aqua_intro_complete: true
  aqua_visible: true

relationship:
  level: 0

team_unlock:
  aqua_surgery_team_unlocked: false
```

玩家此时仍然不能主动把她拉进手术团队。

---

# 19. Lv1 事件解锁条件

累计成功完成 5 台妇科手术：

```yaml
requires:
  aqua_intro_complete: true
  gyne_surgery_success_count: ">= 5"
```

注意：

> 这里是总累计 5 台，因此相识前的第一台也计算在内。

满足后：

```text
aqua_lv1_available = true
```

---

# 20. Lv1 事件：《你不觉得很漂亮吗？》

### Event ID

```text
aqua_lv1_gyne_obsession
```

### Event Type

```text
relationship
medical_flirt
adult_suggestive
```

### Relationship

```text
Lv0 → Lv1
```

### 核心目的

1. 展示阿库娅妇科知识极其丰富
2. 展示她真的喜欢妇科手术到有一点“不太正常”
3. 产生轻微 Hoshimi 黄油感
4. 解锁她作为手术团队成员

---

# 21. Lv1 开场

阿库娅得知：

> 坂口已经成功完成 5 台妇科类手术。

她主动拉住他。

> “坂口医生！”

> “我听说了！”

坂口：

> “什么？”

阿库娅：

> “五台！”

坂口：

> “什么五台？”

阿库娅：

> **“妇科手术啊！”**

她明显两眼放光。

---

# 22. 她开始讨论妇科体位

阿库娅：

> “你现在应该终于懂了吧？”

坂口：

> “懂什么？”

阿库娅：

> **“截石位真的很漂亮啊！”**

坂口：

> “……”

阿库娅继续：

> “骨盆角度一调整，双腿固定好，整个术野关系一下就展开了。”

> “那个几何感、那个暴露……”

> **“你不觉得特别优美吗？”**

路过护士开始明显脸红。

---

# 23. 妇科术式狂热

她完全进入医学兴奋状态。

推荐使用真实、听起来就让普通人不适或羞耻的术式名称，例如：

- 经阴道子宫切除术
- 阴道前后壁修补术
- 宫腔镜宫腔粘连分离术
- 腹腔镜子宫肌瘤剔除术

阿库娅：

> **“我超喜欢经阴道子宫切除术！”**

坂口：

> “你能不能小声一点？”

阿库娅继续：

> “还有阴道前后壁修补术！”

> “尤其是层次分得特别漂亮的时候——”

旁边护士已经明显脸红。

阿库娅：

> “宫腔镜粘连分离也很好啊！”

> “明明入口那么小，里面能做的事情却那么多！”

坂口：

> “水城医生。”

阿库娅：

> “嗯？”

坂口：

> “护士们都在看你。”

她回头。

护士们迅速移开视线。

阿库娅：

> “为什么？”

坂口：

> “……算了。”

---

# 24. 事件的擦边感原则

不要让她直接性挑逗坂口。

真正的黄油感来自：

> **她纯医学地、毫无羞耻地谈论极私密妇科内容，而且本人完全不觉得哪里不对。**

固定角色逻辑：

```text
medical_interest = 100%
sexual_intent = very_low / none
social_embarrassment_caused = very_high
```

---

# 25. Lv1 中段：把角色拉回真正医生

坂口：

> “你就这么喜欢妇科手术？”

阿库娅：

> “当然。”

稍微认真：

> “很多患者来的时候都会觉得难为情。”

> “但对我来说，那就是人体。”

> “而且很多人被这些问题困扰很久。”

然后：

> **“能把它解决掉，不是很棒吗？”**

这句必须保留。

它说明：

> 她不是色情 fetish caricature，而是真正喜欢妇科医学本身。

---

# 26. Lv1 结尾：手术团队解锁

阿库娅：

> “对了。”

坂口：

> “什么？”

她明显期待：

> **“下次你开妇科手术，拉上我呀！”**

坂口：

> “你是主任。”

阿库娅：

> “所以呢？”

> “我又没说一定要主刀。”

然后：

> **“助手也很好玩啊。”**

---

# 27. Lv1 结果

```yaml
sets:
  relationship_aqua: 1
  aqua_surgery_team_unlocked: true
  aqua_gyne_assist_unlocked: true
```

从此玩家可以主动邀请阿库娅加入手术团队。

---

# 28. 手术邀请逻辑

## 28.1 妇科手术

条件：

```text
procedure.category == gynecology
```

她的反应明显兴奋。

示例：

> “妇科？哪一台？”

或者：

> “什么术式？”

知道以后：

> **“好！我去！”**

高 Familiarity 后：

> “截石位吗？”

> “腹腔镜还是经阴道？”

> “等等，我先去换衣服！”

---

## 28.2 非妇科手术

她仍然有基本医生能力，但明显兴趣较低。

低 Familiarity：

> “普通外科？”

> “我不是不能帮，不过应该有人比我更适合吧？”

高 Familiarity：

> **“什么呀，这个没意思。”**

坂口：

> “你是医生吧？”

阿库娅：

> “所以我才知道什么有意思啊！”

注意：

> **这类吐槽只能发生在患者听不到的场合。**

---

# 29. 妇科手术团队加成

建议：

```yaml
aqua_gyne_bonus:
  pelvic_exposure_quality: high
  positioning_quality: high
  diagnostic_support: high
  complication_detection: high
  gyne_procedure_efficiency: high
```

尤其对：

```text
lithotomy
vaginal_approach
hysteroscopy
pelvic_surgery
```

加成明显。

---

# 30. 非妇科手术状态

```yaml
non_gyne:
  usable: true
  special_bonus: false
  enthusiasm: low
```

不要扣基础能力。

她仍然是妇科主任级医生。

只是这不是她真正热爱的领域。

---

# 31. 术前团队确认对白

## 妇科手术

> “助手位确认！”

然后明显兴奋：

> “今天这个术式我喜欢。”

较正式版本：

> “助手位确认。盆腔暴露和体位我来盯着。”

## 非妇科手术

> “助手位确认。”

停顿。

> “虽然不是妇科……好吧，我会认真做。”

---

# 32. 术中顺利配合

## 妇科

> “对，就是这里。”

> “角度很好，继续。”

或者：

> “这个术野很漂亮啊……”

旁边护士：

> “主任。”

阿库娅：

> “我是在说医学意义上的漂亮！”

---

# 33. 术中提醒

> “等等，这里的解剖关系不对。”

然后瞬间完全进入专业状态：

> “先停。重新确认输尿管位置。”

表现：

> **她的搞笑人格不会干扰真正医学判断。**

---

# 34. 术中突发状况

妇科病例出现异常：

> “别急。”

> “先保持术野。”

> “这里我见过。”

然后快速提出明确处理方案。

此时：

```text
语气稳定
判断快速
没有废话
```

这是人物可信度的重要来源。

---

# 35. 截石位专属反应

如果手术采用：

```text
position = lithotomy
```

她可能明显更兴奋。

术前、患者听不到时：

> “腿架调得不错。”

坂口：

> “你为什么看起来这么高兴？”

阿库娅：

> “因为体位很漂亮啊。”

患者听得到时必须切换成：

> “体位已经调好了，不舒服的话马上告诉我们。”

---

# 36. 与器械护士的互动

护士如果因为她的用词脸红：

阿库娅：

> “怎么了？”

护士：

> “没什么……”

阿库娅：

> “那就好。”

她完全没意识到问题。

---

# 37. 与神宮寺成美的互动规则

成美经常负责：

> **医学正确 → 患者体验翻译。**

阿库娅：

> “我都解释了。”

成美：

> “你说的是‘腿放这里’。”

阿库娅：

> “这不是解释吗？”

成美：

> “不是。”

---

# 38. 与御堂江美子的互动规则

御堂：

> 技术狂热隐藏得深。

阿库娅：

> 技术狂热完全不隐藏。

阿库娅：

> “你明明也超喜欢开刀的。”

御堂：

> “闭嘴。”

---

# 39. 与阿尔托莉雅的互动规则

阿尔托莉雅习惯：

```text
Plan A
Plan B
Plan C
```

阿库娅：

> “为什么要 Plan B？”

阿尔托莉雅：

> “因为 Plan A 可能失败。”

阿库娅：

> “不会啊。”

阿尔托莉雅：

> “……”

用于表现：

> **天才直觉型 vs 系统管理型。**

---

# 40. 角色核心禁区

禁止：

- 为了搞笑降低医疗专业能力
- 把她写成真正无能的主任
- 让她每句话都是黄色笑话
- 把她的妇科热爱简化成“喜欢私密部位”
- 让她在患者面前贬低非妇科手术
- 因兴趣不足而敷衍患者
- 让她成为御堂的复制品

---

# 41. 角色公式

```text
Aqua =
妇科天才
+
专业热爱异常强烈
+
社会过滤器很低
+
生活常识偶尔掉线
+
真正面对患者时极可靠
```

---

# 42. Codex 最终接入摘要

```yaml
id: doc_aqua
name: 水城アクア
display_name_zh: 水城阿库娅

age: 28
gender: female
profession: doctor
specialty: gynecology
rank: gynecology_director

route_type: romance_candidate

skills:
  surgery: 95
  diagnostics: 96
  teamwork: 82
  patient_care: 87
  instrument_handling: 94
  calmness: 90

extended_skills:
  gynecology: 99
  pelvic_anatomy: 99
  hysteroscopy: 97
  laparoscopic_gynecology: 96
  vaginal_surgery: 97

initial_state:
  met: false
  visible: false
  relationship_level: 0
  surgery_team_unlocked: false

intro_unlock:
  gyne_surgery_success_count: ">= 1"

intro_event:
  id: aqua_intro_exam_chair
  title: 新设备测试
  location: gynecology_exam

intro_result:
  met_aqua: true
  aqua_visible: true
  aqua_intro_complete: true
  surgery_team_unlocked: false

lv1_unlock:
  aqua_intro_complete: true
  gyne_surgery_success_count: ">= 5"

lv1_event:
  id: aqua_lv1_gyne_obsession
  title: 你不觉得很漂亮吗？
  type:
    - relationship
    - medical_flirt
    - adult_suggestive

lv1_result:
  relationship_level: 1
  aqua_surgery_team_unlocked: true
  aqua_gyne_assist_unlocked: true

team_behavior:
  gynecology:
    availability: true
    enthusiasm: very_high
    special_bonus: true

  non_gynecology:
    availability: true
    enthusiasm: low
    special_bonus: false

gyne_bonus:
  pelvic_exposure_quality: high
  positioning_quality: high
  diagnostic_support: high
  complication_detection: high
  procedure_efficiency: high

writing_rules:
  comedy_may_affect_self: true
  comedy_may_affect_patient_safety: false
  medical_competence_must_remain_high: true
  sexual_intent_in_lv1: low
  embarrassment_caused_to_bystanders: high
```


# 43. Future Route Direction — Lv4 / Lv5 成人路线核心
## 本节只锁定方向，不展开完整事件脚本

> Hoshimi 版阿库娅明确为 28 岁成年女性。  
> 以下内容仅用于后续 Lv4 / Lv5 设计方向和系统解锁，不在当前版本中展开完整 H 场景。

---

## 43.1 成人路线总原则

阿库娅的成人路线不能突然从：

```text
缺根弦的妇科主任
```

变成：

```text
普通恋爱角色
```

她整条路线都应围绕同一个核心：

> **她真的觉得妇科医学本身就很有魅力。**

因此成人关系中的“色色感”仍然来自：

```text
妇科器械
妇科检查椅
妇科体位
医学术语
她本人完全不觉得这些东西需要害羞
```

而不是让她突然变得轻浮或单纯色情化。

---

# 44. Lv4 成人事件方向
## 关键词：妇科检查椅

阿库娅进入明确亲密关系以后，如果双方准备发生第一次正式成人亲密事件，她会非常自然地提出：

> **“要做当然是在妇科检查椅上做啊。”**

主角会以为她在开玩笑。

阿库娅：

> **“床上有什么意思？”**

然后非常理所当然地指着妇科检查椅：

> **“来，把我的腿放好。”**

如果使用腿架，她甚至可能继续：

> **“固定好一点，不然角度不标准。”**

重要：

> 她本人并不把这理解成 BDSM 或角色扮演。

她只是以一种极其 Aqua 的逻辑认为：

> **妇科检查椅既能调角度、又有腿架、还是她最熟悉的专业设备，那么为什么不用？**

这正是该事件的喜剧和成人感来源。

---

## 44.1 主角吐槽方向

主角：

> “你到底把妇科检查椅当什么了？”

阿库娅：

> **“很好用的椅子啊？”**

停顿。

> “你不觉得很方便吗？”

这种回答必须保持她：

```text
医学思维 100%
社交过滤 30%
```

的特点。

---

## 44.2 Lv4 的医学 callback

Lv1：

> **“截石位真的很漂亮啊！”**

Lv4：

> 她第一次主动让自己处于类似妇科检查／体位的情境。

这个 callback 很重要。

Lv4 不是“突然有一个 H 场景”，而是：

> **Lv1 她在讨论别人时毫无羞耻感；Lv4 她自己第一次真正成为那个处于体位中的人。**

---

## 44.3 Lv4 反差

阿库娅嘴上会非常积极。

但真正自己坐上检查椅／进入体位以后，可以短暂停顿：

主角：

> “怎么了？”

阿库娅：

> “没什么。”

停一下。

> **“就是……从这边看，确实和站在旁边的时候不太一样。”**

然后马上嘴硬：

> **“但还是很漂亮！”**

这种轻微反差可以保留：

```text
medical_confidence = very_high
personal_embarrassment = unexpectedly_nonzero
```

但不能把她突然写成胆怯型角色。

---

# 45. Lv5 Staff-as-Patient / Surgery Practice 解锁方向

Lv5 完成后可以解锁：

```text
aqua_voluntary_patient_unlocked = true
```

但她和其他 Staff-as-Patient 最大区别是：

> **她对术式有非常强烈的偏好。**

她不是：

> “喜欢被开刀。”

而是：

> **“她异常向往自己亲身成为妇科手术患者。”**

因此术式类别必须影响她的反应。

---

# 46. 妇科手术练习反应
## `procedure.category == gynecology`

如果玩家选择妇科类训练术式：

阿库娅的反应应明显兴奋。

例如：

> “真的？”

> “妇科？”

> **“哪一种？”**

知道术式以后：

> **“这个我喜欢！”**

如果涉及截石位：

> **“要用截石位？”**

然后：

> “好。”

> “什么时候开始？”

甚至主角还没有说完，她已经开始问：

- 什么时候换患者服；
- 用哪一种体位；
- 是腹腔镜、宫腔镜还是经阴道；
- 自己能不能看到术前安排。

情绪方向：

```text
anticipation = extreme
cooperation = very_high
fear = low_to_medium
```

---

# 47. 真正成为妇科患者后的反差

尽管她非常期待，真正躺上去以后仍然可以第一次理解：

> **“医生视角”和“患者视角”不是同一个东西。**

例如：

无影灯／体位／腿架调整以后。

阿库娅：

> “……”

主角：

> “怎么了？”

阿库娅：

> “没什么。”

停顿。

> **“就是从这个角度看，腿架好像比我平时觉得的高一点。”**

主角：

> “怕了？”

阿库娅：

> “才没有！”

然后：

> **“而且还是很漂亮！”**

这样可以延续她的性格，同时给患者写实度增加一层。

---

# 48. 非妇科手术练习反应
## `procedure.category != gynecology`

如果玩家选择其他类别：

她的态度完全相反。

例如：

> “诶？”

> “为什么是那里？”

或者：

> **“不要啊，为什么偏偏是这个？”**

主角：

> “你不是说愿意让我练手术？”

阿库娅：

> **“我是说妇科手术！”**

> “妇科！”

> “重点完全不一样好不好！”

这里应表现为：

```text
enthusiasm = low
complaint = high
cooperation = still_present
```

她可以嘴上抱怨。

但如果已经明确同意并进入训练流程：

> **不能因为“不喜欢术式”就故意降低配合或影响安全。**

---

# 49. Lv5 手术偏好建议

```yaml
voluntary_patient_profile:
  preferred_category: gynecology
  gynecology_interest: extreme
  lithotomy_preference: very_high
  vaginal_procedure_interest: very_high
  hysteroscopy_interest: very_high
  general_surgery_interest: low
  non_gyne_complaint_rate: high
```

注意：

这些是：

> **角色偏好**

不是：

> 医学安全规则。

真正可执行的训练术式仍应由 Staff-as-Patient 系统统一决定。

---

# 50. 情绪参数建议

## 妇科训练

```yaml
gynecology_patient_response:
  fear: 20
  enthusiasm: 100
  dignity: 90
  cooperation: 100
```

解释：

- Fear 不是 0，因为真正成为患者仍然和站在医生位置不同。
- Dignity 很高不是“不害羞”，而是她本人对妇科暴露的医学羞耻感极低。
- Enthusiasm 极高是她的核心人物特色。

---

## 非妇科训练

```yaml
non_gyne_patient_response:
  fear: 55
  enthusiasm: 10
  dignity: 75
  cooperation: 75
```

重点：

> 同一个角色对不同术式产生非常不同的心理反应。

这可以成为未来 Patient Response Profile 系统的范例。

---

# 51. Aqua 的 Staff-as-Patient 和其他角色的区别

## 御堂

```text
技术强者
→ 控制与失去控制
```

## 阿尔托莉雅

```text
领导者
→ 允许别人承担责任
```

## 佐伯ほづみ

```text
曾经不得不接受手术
→ 康复后主动再次信任
```

## 阿库娅

```text
极端热爱妇科医学的医生
→ 主动想从患者角度体验自己最喜欢的专业
```

因此她的 Lv5 不是：

> “又一个可以拿来练手术的人。”

而是：

> **“一个一直站在妇科手术台旁边、甚至觉得那一切很优美的人，终于自己躺到了另一边。”**

---

# 52. Future Route 写作禁区

不要：

- 把阿库娅写成普遍的 surgery fetish 角色；
- 让她对所有手术都异常兴奋；
- 让她因为喜欢妇科就无视医学风险；
- 把妇科职业热爱简化为纯性癖；
- 让她真正成为患者后完全没有任何视角反差；
- 让非妇科术式抱怨影响实际患者安全；
- 让 Lv4/Lv5 脱离 Lv1 已经建立的“妇科医学狂热”主题。

---

# 53. Future Route 核心 callback

整条路线建议形成：

```text
Lv1
“截石位真的很漂亮啊！”

↓

Lv4
“要做当然是在妇科检查椅上做啊。”
“床上有什么意思？”
“来，把我的腿放好。”

↓

Lv5
“妇科手术？真的？”
“哪一种？”
“这个我喜欢！”
```

而非妇科则：

> **“不要啊，为什么是那里？”**

这样从 Lv1 到 Lv5 始终是同一个阿库娅。

---

# 54. Future Route Flags

```yaml
future_route:
  lv4:
    theme: gynecology_exam_chair_intimacy
    adult_only: true
    consent_required: true

  lv5:
    unlocks:
      aqua_voluntary_patient_unlocked: true
    preferred_training_category: gynecology
    procedure_preference_affects_dialogue: true
    procedure_preference_affects_patient_response: true
```

---

# END FUTURE ROUTE ADDENDUM

# END
