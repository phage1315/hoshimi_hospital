# Hoshimi Hospital — 通用特殊事件框架
## Special Event Framework
### Codex Implementation Spec — v0.1

> 目的：先实现一个通用的“特殊事件”底层框架。  
> 后续的月度医学讲课、公开教学手术、医院祭、外出研修、重大病例等，都尽量复用这一框架，而不是各自制作独立系统。

---

# 1. 核心定义

特殊事件（Special Event）与普通关系事件不同。

统一规则：

```text
普通关系事件：
- 可以只是一个短场景
- 不一定占用整天

特殊事件：
- 至少占用 1 个完整游戏日
- 可以连续占用多天
- 可以要求特定角色、关系等级、前置事件或 Flag
- 可以设为一次性
- 完成后可以解锁 Event Gallery 回放
```

---

# 2. 最小数据结构

建议每个特殊事件使用类似结构：

```yaml
special_event:
  id: string
  title: string
  category: string

  duration_days: 1
  consumes_full_day: true
  repeatable: false

  unlock_requirements: []
  required_characters: []
  prerequisite_events: []

  event_chain:
    - day_1

  completion_flags: []

  gallery_unlock: true
```

---

# 3. 字段说明

## `id`

事件唯一 ID。

例如：

```text
monthly_lecture_aqua
teaching_surgery_shiori
hospital_festival_01
```

---

## `title`

玩家看到的事件名称。

---

## `category`

只用于分类，不决定底层逻辑。

例如：

```text
lecture
teaching_surgery
festival
training
major_case
character_ex
```

---

## `duration_days`

事件连续占用多少个完整游戏日。

最低：

```text
1
```

例如：

```text
月度讲课 = 1
公开教学手术 = 3
医院祭 = 1
外出研修 = 2 或 3
```

---

## `consumes_full_day`

特殊事件默认：

```yaml
consumes_full_day: true
```

当天不能再进行：

- 普通探索
- 普通关系事件
- 额外手术
- 约会
- 其他消耗时间的活动

---

## `repeatable`

一次性事件：

```yaml
repeatable: false
```

完成后不可在正常游戏世界再次触发。

月度讲课、公开教学手术等原则上都建议一次性。

---

# 4. 解锁条件

框架必须支持以下几类条件：

```text
角色是否已解锁
关系等级
普通 Flag
前置事件是否完成
数值统计
日期／月份
其他已有游戏状态
```

示例：

```yaml
unlock_requirements:
  - relationship_shiori >= 5
  - asuka_unlocked == true
  - gyne_surgery_success_count >= 5
  - event_x_complete == true
```

要求：

> 不需要为 Special Event 单独发明一套条件语言。  
> 尽量直接复用当前事件系统已有的条件检查机制。

---

# 5. `required_characters`

用于表示：

> 这场事件必须有哪些角色已经解锁。

例如公开教学手术：

```yaml
required_characters:
  - asuka
  - shiori
  - emiko
  - hiroko
```

任何一个未解锁：

```text
事件不开放
```

注意：

> `required_characters` 只是硬性成员。

其他观众、插话角色等可以使用普通条件分支：

```text
if aqua_unlocked:
    播放 Aqua 专属插话
```

---

# 6. `prerequisite_events`

用于必须先完成的特定人物事件。

例如：

```yaml
prerequisite_events:
  - shiori_lv5_complete
  - shiori_staff_patient_unlock
  - shiori_emiko_special_interaction
```

如果缺少：

```text
该特殊事件不开放
```

---

# 7. 多日事件链

Special Event 必须支持：

```yaml
event_chain:
  - day_1
  - day_2
  - day_3
```

开始后按顺序自动进入下一阶段。

例如：

```yaml
event_chain:
  - teaching_shiori_preop
  - teaching_shiori_surgery
  - teaching_shiori_postop
```

运行逻辑：

```text
Day 1 完成
↓
推进 1 天
↓
Day 2 自动继续
↓
推进 1 天
↓
Day 3 自动继续
↓
事件完成
```

玩家不需要每天重新寻找事件入口。

---

# 8. 事件进行中状态

建议增加通用状态：

```text
special_event_in_progress
special_event_id
special_event_step
```

示例：

```yaml
special_event_in_progress: true
special_event_id: teaching_surgery_shiori
special_event_step: 2
```

事件完成后清除。

用途：

- 防止普通活动菜单出现
- 防止同时启动第二个 Special Event
- 存档／读档后能继续正确阶段
- 多日事件不会断链

---

# 9. 日历锁定

当 Special Event 开始：

```text
锁定当前日程
```

对于：

```yaml
duration_days: 3
```

应连续占用 3 个游戏日。

玩家不能在中间插入普通行动。

开始前建议统一弹出确认：

```text
该特殊事件将连续占用 3 天。
期间无法进行普通活动。
是否开始？
```

单日事件可写：

```text
该事件将占用今天剩余时间。
是否参加？
```

---

# 10. 事件完成

完成最后一个 `event_chain` step 后：

```text
special_event_in_progress = false
```

然后执行：

```yaml
completion_flags:
  - teaching_surgery_shiori_completed = true
```

若：

```yaml
repeatable: false
```

以后正常游戏中不得再次出现。

---

# 11. Event Gallery

若：

```yaml
gallery_unlock: true
```

首次完成后：

```text
解锁该事件的 Gallery Replay
```

建议：

```yaml
gallery_entry:
  id: teaching_surgery_shiori
  title: 藤崎詩織公开教学手术
  chapters:
    - 术前
    - 手术当天
    - 术后
```

单日事件可以只有：

```text
完整回放
```

---

# 12. Replay Mode

Gallery 回放必须和正常世界状态隔离。

建议已有或新增：

```text
replay_mode = true
```

Replay Mode 下禁止：

```text
推进日期
修改关系值
修改角色解锁状态
增加手术次数
发放金钱／资源
重复设置故事 Flag
重复解锁成就
改变医院世界状态
```

Event Gallery 只负责：

> **播放已经完成过的事件内容。**

---

# 13. 条件分支与可选角色

Special Event 内部仍然允许普通事件条件分支。

例如：

```text
if aqua_unlocked:
    Aqua 插话

if emiko_relationship >= 3:
    播放御堂特殊互动
```

重要：

> 不需要为可选人物创建复杂动态事件系统。  
> 继续使用现有的 `if condition → dialogue` 即可。

固定主干必须在没有可选插话时依然成立。

---

# 14. 月度医学讲课如何使用框架

单日事件：

```yaml
special_event:
  id: monthly_lecture_aqua
  title: 水城アクア的院内医学讲课
  category: lecture

  duration_days: 1
  consumes_full_day: true
  repeatable: false

  required_characters:
    - aqua

  event_chain:
    - monthly_lecture_aqua_main

  gallery_unlock: true
```

如果当月讲师未解锁：

```text
该月讲课不发生
```

---

# 15. 公开教学手术如何使用框架

三日事件：

```yaml
special_event:
  id: teaching_surgery_shiori
  title: 藤崎詩織公开教学手术
  category: teaching_surgery

  duration_days: 3
  consumes_full_day: true
  repeatable: false

  unlock_requirements:
    - relationship_shiori >= 5
    - shiori_staff_patient_unlocked == true

  required_characters:
    - asuka
    - shiori
    - PLAYER
    - fixed_assistant
    - fixed_scrub_nurse
    - fixed_circulating_nurse

  prerequisite_events:
    - shiori_required_event_x

  event_chain:
    - teaching_shiori_preop
    - teaching_shiori_surgery
    - teaching_shiori_postop

  completion_flags:
    - teaching_surgery_shiori_completed

  gallery_unlock: true
```

---

# 16. 不要过度工程化

第一版只需要做到：

```text
1. 条件判断
2. 一次性事件
3. 占满一天
4. 多日事件链
5. 日历锁定
6. 完成 Flag
7. Gallery Replay
8. Replay 不改变游戏状态
```

暂时不要制作：

- 复杂事件调度器
- 动态观众模拟
- 自动对白生成
- 自动团队 AI
- 独立教学手术玩法系统
- 独立讲课玩法系统

这些内容都继续由事件脚本负责。

---

# 17. 实现原则

底层应该是：

> **一个通用 Special Event Framework。**

而不是：

```text
Lecture System
Teaching Surgery System
Festival System
Training System
```

分别实现。

未来内容只需要：

```text
写事件
+
配置条件
+
配置持续天数
```

即可接入。

---

# 18. 第一版验收标准

Codex 完成底层后，应能用一个非常简单的测试事件验证：

```text
- 满足条件前不可触发
- 满足条件后出现
- 开始时占用完整一天
- 事件执行完推进到下一天
- 设置 completion flag
- 正常世界中不能再次触发
- Event Gallery 中可以回放
- Gallery 回放不推进日期、不重复设置 flag
```

再增加一个 3 日测试事件验证：

```text
Day 1
→ 自动 Day 2
→ 自动 Day 3
→ 正常完成
```

如果以上全部通过：

> Special Event Framework 第一版即可视为完成。

---

# END
