# Hoshimi Hospital 主角办公室系统设计
## Codex 实现规格

> 项目：Hoshimi Hospital
> 系统类型：Player Hub / Career Progression / Records / Relationship Overview / Event Hub
> 设计阶段：建议在基础门诊、手术、关系系统稳定后实现
> 目标：为玩家提供一个“个人据点”，连接职业成长、病例记录、关系查看、非手术行动与随机角色事件。

---

# 1. 核心定位

主角办公室不是单纯的菜单界面。

它应同时承担四个功能：

```text
1. 信息中心
2. 职业成长中心
3. 关系与病例记录中心
4. 随机/条件角色事件中心
```

更重要的是，它在叙事上承担：

> **“这一年里，主角从临时停留的医生，逐渐在医院里留下自己的痕迹。”**

游戏开局时，办公室应显得：

```text
空
临时
功能性
没有私人痕迹
```

随着游戏推进，应逐渐出现：

```text
患者感谢卡
同事赠送的小物
医院祭吉祥物
学会资料
论文抽印本
手术照片 / 合影
角色专属纪念物
```

最终它应成为：

> **玩家这一年经历的视觉化记录。**

---

# 2. 世界观定位

主角是：

```text
海外研修归来的外科医生
与医院签约一年
最初只把这里当作暂时落脚之所
```

因此办公室一开始应有一种：

> “临时借给他的一间房”

的感觉。

到了年末，如果玩家选择留下：

> 同一个办公室已经明显变成“属于他的地方”。

这应与游戏总主题呼应：

> **本来只准备待一年，最后发现这里已经是自己的医院了。**

---

# 3. 办公室入口

建议加入地图地点：

```text
player_office
```

显示名：

```text
主角办公室
```

建议开放条件：

```text
day >= 1
```

不需要额外解锁。

---

# 4. 办公室主菜单

进入办公室后显示：

```text
[查看同事关系]
[查看患者病例]
[查看主角状态]
[查看职业履历]
[处理文书 / 职业行动]
[查看收藏与纪念物]
[休息 / 离开]
```

如果当天存在办公室专属事件：

```text
优先检查 event_hook
→ 若满足条件，先触发事件
→ 事件结束后进入办公室主菜单
```

---

# 5. 同事关系查看

推荐显示：

```text
Character Name
Role
Relationship Level
Trust
Respect
Affection
Familiarity
Shared Surgeries
Last Major Event
Next Level Hint（可选）
```

示例：

```text
杉村弘子
Role: Senior Nurse
Relationship: Lv1
Trust: 18
Respect: 22
Affection: 4
Familiarity: 15
Shared Surgeries: 6
Last Event: 《值得的事情》
```

未认识角色只显示：

```text
???
```

---

# 6. 共同手术记录

建议加入：

```text
operation_count_together
team_bond
```

作为轻量后台成长值。

定义：

```text
operation_count_together
→ 和该角色共同进入手术团队的次数

team_bond
→ 职业默契
```

UI 可显示：

```text
共同上台：12次
默契：熟练
```

推荐等级：

```text
0–2    陌生
3–7    熟悉
8–14   默契
15+    老搭档
```

具体阈值后续平衡。

---

# 7. 患者病例档案

办公室可以查看主角已经治疗过的患者。

推荐每个病例记录：

```text
patient_id
patient_name
first_visit_day
diagnosis
procedure
anesthesia
surgery_team
patient_experience_grade
peak_fear
peak_pain
lowest_dignity
special_events
outcome
follow_up_status
```

病例档案不是纯日志，还应支持：

```text
1. 回顾已经发生的特殊事件
2. 查看患者是否可再次出现
3. 为论文 / 学会 / 复盘提供素材来源
4. 作为特殊角色回归事件的触发依据
```

---

# 8. 主角状态查看

推荐显示：

```text
Surgery
Diagnosis
Communication
Leadership
Research
Administration
Professional Reputation
Energy
Stress
Confidence
```

如果当前版本没有全部属性：

> 只显示已经存在的属性。

不要为了办公室单独创建重复属性系统。

---

# 9. 职业履历

建议记录：

```text
total_outpatient_cases
total_surgeries
successful_surgeries
major_surgeries
emergency_cases
procedure_first_clears
assistant_takeovers
major_complications
papers_completed
conference_presentations
titles
```

目的：

> 让玩家看到这一年里自己成为了什么样的医生。

---

# 10. 非手术职业行动

办公室应提供一些：

> **花费 2–3 小时，换取职业成长或未来收益**

的行动。

这些行动不是强制每日作业。

核心原则：

> **主动投资，而不是行政惩罚。**

---

# 11. 行动：写手术报告

```text
id = write_surgery_report
time_cost = 120 min
```

效果建议：

```text
Professional Reputation + small
Research + small
```

如果最近完成高难度 / 特殊手术：

```text
bonus reputation
bonus research
```

可触发角色互动：

```text
御堂来复核
弘子补充护理记录
明日香要求院内总结
```

---

# 12. 行动：复盘手术录像

```text
id = review_surgery_recording
time_cost = 120 min
```

效果：

```text
Surgery XP +
Procedure Familiarity +
```

高 Relationship 角色可以解锁：

```text
邀请助手共同复盘
```

例如御堂：

> 「停在这里。」
>
> 「你当时为什么急着往下做？」

可额外产生：

```text
team_bond +
respect +
```

---

# 13. 行动：阅读病例 / 医学资料

```text
id = study_medical_material
time_cost = 120 min
```

效果：

```text
Diagnosis XP +
```

可选择类别：

```text
general_abdominal
female_pelvic
breast
thoracic
cardiac
vascular
urologic
```

未来可用于：

```text
procedure_group familiarity
risk preview accuracy
```

当前版本如果没有这些系统，可以先只加属性成长。

---

# 14. 行动：构思论文

```text
id = work_on_paper
time_cost = 180 min
```

使用长期进度：

```text
paper_progress
0 / 100
```

每次：

```text
+10 ~ +20
```

完成后：

```text
Research +
Professional Reputation +
unlock conference event
```

论文题目尽量来自玩家真实经历，例如：

```text
复杂粘连病例回顾
清醒患者体验
围术期团队协作
某类术式病例总结
```

---

# 15. 行动：准备学会报告

```text
id = prepare_conference
time_cost = 180 min
```

效果：

```text
conference_progress +
Research +
```

完成后可触发：

```text
conference_event
```

某些角色关系高时可以：

```text
coauthor
joint presentation
```

---

# 16. 行动：术式训练 / 模拟练习

```text
id = simulation_training
time_cost = 120 min
```

效果：

```text
Surgery XP +
specific procedure familiarity +
```

必须有收益递减。

不要允许玩家完全不进手术室，只靠办公室训练把 Surgery 刷满。

---

# 17. 行动：整理病例资料

```text
id = organize_case_notes
time_cost = 60~120 min
```

效果：

```text
Diagnosis small +
Research small +
```

有概率解锁：

```text
old_patient_followup
special case callback
```

---

# 18. 办公室随机事件

办公室应作为高频角色事件地点。

统一 hook：

```text
office_visit
```

角色可以根据：

```text
relationship level
time
recent surgery
recent event
professional reputation
shared surgery count
```

主动来访。

推荐类型：

## 工作型

```text
御堂讨论下一台手术
弘子送护理记录
饭村来确认用药问题
明日香交代院内事务
```

## 轻松型

```text
同事送饮料
角色来躲清静
医院祭准备
吉祥物讨论
```

## 关系型

```text
高关系角色无明确工作理由来办公室
一起加班
夜间谈话
私人关心
```

## 成人型

仅在：

```text
adult character
relationship threshold
consensual adult content enabled
```

时触发。

不要让办公室天然变成 H room。

---

# 19. 办公室视觉成长系统

办公室背景可以随进度逐渐变化。

建议使用：

```text
office_decoration_flags
```

例如：

```text
office_has_hospital_mascot
office_has_patient_thank_you_card
office_has_conference_certificate
office_has_hiroko_gift
office_has_mido_photo
office_has_asuka_hospital_item
office_has_manami_pharmacy_trinket
```

装饰来源：

```text
角色事件
患者结局
医院祭
论文完成
学会发表
重大手术
年终评价
```

不建议做复杂家具购买系统。

重点是：

> **办公室记录人物关系和职业经历。**

---

# 20. 开局 / 中期 / 年末状态

## 开局

```text
空桌
医院配电脑
标准文件柜
一只普通杯子
没有照片
没有私人物品
```

描述：

> 看起来像随时可以换给下一位医生使用。

## 中期

```text
文件越来越多
出现患者卡片
出现医院吉祥物
出现同事留下的小东西
桌边出现学会资料
```

## 年末

如果玩家已经形成大量关系和职业积累：

> 房间里应该已经明显带有“主角本人”的痕迹。

如果选择离开：

> 玩家收拾办公室。

如果选择留下：

> 有些东西根本不需要收。

这是主线情感的重要视觉表现。

---

# 21. 时间系统

办公室行动使用现有游戏时间。

推荐：

```text
查看菜单 / 关系 / 病例
→ 0 min

写报告
→ 120 min

复盘手术
→ 120 min

阅读资料
→ 120 min

论文
→ 180 min

学会准备
→ 180 min

模拟训练
→ 120 min
```

具体数值后续平衡。

---

# 22. 不要强制手术后写报告

重要原则：

不要设计：

```text
做完手术
→ 必须写报告
→ 不写就扣 Reputation
```

否则办公室会变成行政劳动。

应该是：

```text
写报告
→ 主动获得额外成长
```

玩家可以选择：

> 每天只想开刀。

也可以选择：

> 走学术 / 管理 / 综合路线。

---

# 23. 一日节奏示例

## 手术型一天

```text
上午门诊
↓
下午中型手术
↓
晚上办公室写报告
↓
结束一天
```

## 大型手术日

```text
上午大型手术
↓
下午才离开手术区
↓
办公室只剩轻量事件 / 休息
```

## 学术型一天

```text
门诊
↓
读文献
↓
写论文
↓
角色事件
```

---

# 24. 与主线的关系

办公室系统应强化：

> **一年合同 → 临时医生 → 医院成员 → 归属感**

不要直接用系统文字告诉玩家：

> “你开始把这里当家。”

而应该通过：

```text
越来越多的物品
越来越多角色来访
越来越丰富的病例记录
越来越多共同手术回忆
```

让玩家自己感受到。

---

# 25. 年末事件建议

合同到期前：

```text
office_contract_notice = true
```

办公室可以出现：

> “一年期聘用合同将在本月底结束。”

这一句应非常普通。

不要立刻煽情。

玩家回看办公室里留下的东西，本身就是情绪来源。

---

# 26. 与医院祭系统的连接

医院祭结束后可以解锁：

```text
hospital_mascot_item
festival_photo
department_souvenir
```

这些物品可以永久留在办公室。

办公室是医院祭内容的长期记忆点。

---

# 27. 与病例系统的连接

办公室病例档案允许：

```text
select patient
→ review history
```

未来 recurring patient 再登场时：

```text
history flags
```

可用于生成 callback。

---

# 28. 与关系系统的连接

角色事件可以使用：

```text
location = player_office
```

推荐办公室特别适合：

```text
Lv2+
工作后的私人谈话
复盘
加班
疲劳
送东西
```

不要把所有关系事件都塞办公室。

---

# 29. 数据结构建议

可新增：

```text
player_office_state
```

概念结构：

```json
{
  "decorations": [],
  "career_actions": {},
  "papers": [],
  "conference_projects": [],
  "case_archive_unlocked": true,
  "relationship_archive_unlocked": true
}
```

---

# 30. Character Visit Event 建议结构

```json
{
  "id": "hiroko_office_visit_01",
  "hook": "office_visit",
  "actor_id": "hiroko",
  "conditions": {
    "relationship_level_min": 1,
    "time_start": 960,
    "time_end": 1200,
    "required_flags": []
  }
}
```

不要把角色逻辑硬编码到办公室运行时。

继续保持 Data-Driven。

---

# 31. Career Action 建议结构

```json
{
  "id": "review_surgery_video",
  "label": "复盘手术录像",
  "minutes": 120,
  "effects": {
    "surgery_xp": 2,
    "research_xp": 1
  },
  "optional_context": {
    "select_recent_surgery": true
  }
}
```

---

# 32. 特殊角色共同办公事件

部分行动允许角色加入。

例如：

```text
复盘手术
→ 可邀请助手

写论文
→ 可邀请共同作者

准备学会
→ 可邀请相关医生
```

角色加入后：

```text
time_cost 可能减少
额外关系变化
特殊对白
```

这也是互动内容生成的重要 hook。

---

# 33. 推荐 Hook

办公室统一支持：

```text
office_enter
office_visit
office_work_start
office_work_complete
case_review
relationship_review
paper_work
conference_work
surgery_review
late_night_office
contract_notice
```

未来可以根据角色 Bible 自动生成事件内容。

---

# 34. 设计底线

1. 办公室不是查房替代物。
2. 当前版本不需要实现病区多患者管理。
3. 不要把办公室做成复杂经营游戏。
4. 不要强迫玩家每天处理行政工作。
5. 所有职业行动都应该是：
   > 时间换成长 / 解锁机会。
6. 信息查看不消耗时间。
7. 办公室必须支持角色随机/条件来访。
8. 办公室视觉应随一年进程变化。
9. 不要让办公室只是一张静态菜单背景。
10. 它最终必须承担“归属感”的叙事作用。

---

# 35. 最终体验目标

开局：

> **“这是医院借给我的办公室。”**

中期：

> **“这里开始堆满这一年的工作。”**

年末：

> **“这里已经有太多东西属于我了。”**

如果玩家最终选择续约：

> **办公室不再是临时落脚点，而是真正成为主角在医院里的家。**
