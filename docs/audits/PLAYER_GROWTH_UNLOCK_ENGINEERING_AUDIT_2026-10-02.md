# 星见医院玩家成长、手术奖励、角色解锁与团队系统现状审计

> 审计日期：2026-10-02  
> 审计对象：当前工作区实际 GDScript、JSON、schema 与 UI 代码  
> 性质：只读工程现状报告；未修改玩法、数值、角色 gate 或存档结构  
> 口径：下文的“已实现”只表示当前代码路径确实存在；设计文档中的设想若没有运行时代码支撑，均列为“仅设计稿存在”或“当前未发现”。

## 0. 结论索引

- 当前玩家面板实际是 `skill / ethics / charisma / intimidation / reputation` 五项。`Leadership` 不存在；规划稿中的双向 `Clinical Presence` 也不存在，现有 `intimidation` 是单向 0–100 数值。
- `skill` 已迁移为独立 `surgery_xp` 推导出的 50–100 等级；其余四项由基础值加累计效果计算。
- Surgery XP 已使用指数等级需求、难度差倍率、纠错质量倍率、错误适应证倍率和术式 training ceiling；没有首通奖励、重复次数惩罚、助手学习 XP 或通用 Staff-as-Patient XP。
- Quick Surgery 与完整手术走同一个最终结算入口，因此当前会获得相同规则的 Surgery XP、Reputation、团队 Familiarity 和完成次数。
- 普通成功手术的 Reputation 已按简单/普通/高级/极难分层，并有软上限和硬上限。无麻醉本身目前不扣 Reputation；当前 `-10` 来自“明知术式不匹配仍继续”。
- 普通手术队伍只有助手、器械护士、巡回护士三个岗位；麻醉是方案选择而非人员岗位。Grand OR 的扩展岗位仅存在于高级转诊病例数据/剧情中，未接入普通 `PreopSession` 选人器。
- 团队成员能力目前不影响手术结果或 Surgery XP。共同上台会给已相识成员 Familiarity；没有 Team Surgery XP Bonus 或 Leadership XP。
- 御堂江美子的首次正式相识与 Lv1 手术均有 `Surgery >= 56`；Lv2 还有 `Surgery >= 70`。这也通过明日香事件链间接延后了阿尔托莉雅。
- 深山 Lv2 要求诗织 Lv1，但诗织当前只有 introduction；代码完成 introduction 只设为已相识，不会升到 Lv1。因此该事件链存在正常流程阻断。
- Advanced Referral 教学要求 `Surgery >= 85`、`Reputation >= 60`、御堂 Lv1，以及九名指定角色均已相识。其中石神千鹤目前没有普通介绍事件，因此正常流程存在另一处前置阻断风险。
- 当前日程不是固定“行动点”，而是 09:00–17:00 的 480 分钟连续计时。手术结算包含术式时间、术中追加时间与固定 30 分钟术后整理。

---

## 1. 玩家当前所有成长数值

主要实现位置：

- `godot/systems/game_state.gd`
  - `PLAYER_ATTRIBUTE_BASE`
  - `PLAYER_ATTRIBUTE_MIN`
  - `PLAYER_ATTRIBUTE_MAX`
  - `player_attributes()`
  - `snapshot()` / `restore()`
- `godot/systems/encounter_session.gd`
- `godot/systems/preop_session.gd`
- `godot/ui/app.gd::show_player_profile()`
- `godot/ui/player_office_view.gd`
- `data/schemas/content.schema.json`

### 1.1 玩家职业/性格数值表

| 策划概念 | 实际字段 | 起始值 | 实际范围 | 运行时来源 | 持久化 | 当前 UI |
|---|---|---:|---:|---|---|---|
| Surgery | `surgery_xp` → `surgery_level()`；面板键为 `skill` | XP 0 / Lv50 | XP 0–120,010；等级 50–100 | 成功手术与少数特殊事件 | 是：`surgery_xp`、`surgery_xp_history` | “医生属性”显示手术技术等级、当前级 XP/下一级 XP；办公室也显示 |
| Ethics | `ethics` | 0 | -100–100 | 问诊与术前选择的 `player_effects` | 是：累计到 `archived_player_effects`，活动中的 visit/preop 也随行动日志重建 | “医生属性”与办公室显示精确值/进度条 |
| Charm | `charisma` | 50 | 0–100 | 当前只有少量问诊选项 | 同上 | 当前名称“魅力”，显示精确值/进度条；尚无五档表达 |
| 旧式威压 | `intimidation` | 0 | 0–100 | 当前只有威胁/错误术式等选择 | 同上 | 当前名称“威压”，显示精确值/进度条 |
| Professional Reputation | `reputation` | 0 | -100–999 | 手术、办公室时间行动、特殊事件、错误术式选择 | 同上 | 当前名称“声望”，显示精确值/进度条 |
| Leadership | 当前未发现 | — | — | — | — | — |
| 双向 Clinical Presence | 当前未发现 | — | — | — | — | — |

`PLAYER_ATTRIBUTE_BASE` 仍含 `skill: 50`，但 `player_attributes()` 对 `skill` 特判并直接采用 `surgery_level()`；旧存档中的 `archived_player_effects.skill` 会在迁移时转换成 Surgery XP，之后归零。

### 1.2 其他与成长、职业评价、社交有关的状态

| 字段/状态 | 量纲与作用 | 是否持久化 | 是否 UI 可见 |
|---|---|---|---|
| `completed_surgeries_total` | 全局成功手术总数；用于角色 gate | 是 | 不作为玩家五维显示 |
| `completed_surgeries_by_group` | 按 `procedure_group` 的完成次数；用于角色 gate | 是 | 当前未发现通用数值页 |
| `completed_surgeries_by_procedure` | 按术式完成次数；用于 Quick Surgery 解锁 | 是 | 术式/扫荡流程间接显示 |
| `unlocked_procedure_ids` | 已解锁术式集合 | 是 | 术式选择 UI 使用 |
| `affection` | 每角色 0–100 的关系倾向容器；初始通常 0 | 是，位于 `relationship_state` | UI 只显示“倾向”文字，不显示精确值 |
| `familiarity` | 每角色熟悉度；关系升级准备条件 | 是 | 关系页显示精确值 |
| `relationship.level` | 每角色 Lv0–Lv5；部分角色锁为 0 或最多 3 | 是 | 显示 |
| `relationship.route` | 当前为 `colleague`，可进入 romance 路线 | 是 | 关系流程使用 |
| `story_flags` / 事件完成记录 | 职业、人物与剧情解锁状态 | 是 | 仅在相关内容中体现 |
| 患者 `fear/pain/dignity/cooperation` | 单次患者/术前状态，不是玩家属性 | 由 visit/preop 日志重建 | 病例流程显示 |
| 患者 `trust` 等病例字段 | 病例/患者状态或模板字段，不是玩家全局 Trust | 依具体病例日志 | 不属于玩家五维 |

当前活跃关系状态中没有玩家全局 `trust` 或 `respect`，也没有每角色 `trust/respect` 数值；关系数值是 `affection` 与 `familiarity`。

### 1.3 当前已接入的玩家属性变化来源

#### 问诊模板 `data/patients/templates/encounter.json`

| 行动 | 效果 |
|---|---|
| 放弃完全脱衣查体 | `ethics +1` |
| 权威说服 | `charisma +1` |
| 温柔说服 | `ethics +1, charisma +2` |
| 威胁 | `ethics -2, intimidation +2` |

#### 术前模板 `data/patients/templates/preop.json`

| 行动 | 效果 |
|---|---|
| 明知术式不匹配仍继续 | `ethics -35, intimidation +25, reputation -10` |
| 坚持不麻醉 | 只改变患者 `fear/pain/dignity/cooperation`；当前没有玩家属性或 Reputation 效果 |

#### 时间行动 `data/time_events.json`

| 行动 | 时间 | 效果 | 可重复 |
|---|---:|---:|---|
| 整理并撰写手术报告 | 120 分钟 | `reputation +1` | 是 |
| 整理病例资料 | 60 分钟 | `reputation +1` | 是 |

`data/cases/surgery_case_templates.json` 的 rare variant 中存在名为 `ethics/intimidation` 的 `effects` 键，但当前会话代码只有 `player_effects` 会写入玩家属性；这些 `effects` 由患者状态路径读取，不能视为已实现的玩家成长来源。

---

## 2. Surgery XP 经济

### 2.1 等级公式

实现：`godot/systems/game_state.gd`

```text
Lv50 起步，Lv100 封顶。

升到下一级所需 XP：
max(5, round_to_nearest_5(50 × 1.12^(level - 50)))
```

`surgery_xp` 存储累计总 XP；`surgery_level()` 从 Lv50 开始逐级扣除门槛得出等级。Lv100 的累计需求为 **120,010 XP**。

| 当前等级 | 升下一级所需 XP | 到达本级的累计 XP |
|---:|---:|---:|
| 50 | 50 | 0 |
| 51 | 55 | 50 |
| 52 | 65 | 105 |
| 53 | 70 | 170 |
| 54 | 80 | 240 |
| 55 | 90 | 320 |
| 60 | 155 | 885 |
| 65 | 275 | 1,875 |
| 70 | 480 | 3,615 |
| 75 | 850 | 6,680 |
| 80 | 1,500 | 12,075 |
| 85 | 2,640 | 21,595 |
| 90 | 4,655 | 38,365 |
| 95 | 8,200 | 67,920 |
| 99 | 12,900 | 107,110 |
| 100 | — | 120,010 |

### 2.2 普通成功手术的 XP 公式

入口：

- `finish_active_surgery()`
- `award_surgery_xp(preparation)`
- `surgery_xp_award_for(preparation)`
- `surgery_learning_efficiency(difficulty_gap)`

当前公式：

```text
effective_difficulty = clamp(base_difficulty + 病例 difficulty_modifier, 0, 100)
difficulty_gap = effective_difficulty - 当前 Surgery Lv

raw XP = round(
    术式 duration_minutes
    × 难度差学习效率
    × 纠错质量倍率
    × 适应证倍率
)

最终 XP = min(raw XP, 到该术式 training_ceiling 尚需的 XP)
```

难度差效率：

| `effective difficulty - Surgery Lv` | 倍率 |
|---:|---:|
| `< -20` | 0.10 |
| `-20 … -6` | 0.50 |
| `-5 … +10` | 1.00 |
| `+11 … +20` | 1.25 |
| `+21 … +30` | 0.75 |
| `> +30` | 0.20 |

其他倍率：

- 每次 `procedure_corrections`：质量倍率减少 0.10，最低 0.50。
- `procedure_mismatch == true`：适应证倍率 0.20。
- 当前等级达到 `training_ceiling`：该术式 XP 为 0。
- XP 会截断在 training ceiling 所需的准确累计 XP，不会越过 ceiling。
- placeholder 术式不给 XP。

### 2.3 全部术式 XP 参数

来源：`data/surgeries/surgeries.json`

| 术式 | 时长 | 难度 | Training ceiling |
|---|---:|---:|---:|
| 开腹阑尾切除 | 60 | 32 | 60 |
| 乳房肿瘤切除 | 120 | 38 | 65 |
| 开腹子宫全切除 | 240 | 68 | 82 |
| 开胸心脏搭桥 | 360 | 92 | 99 |
| 大开腹探查 | 480 | 82 | 92 |
| 开腹胆囊切除 | 120 | 42 | 68 |
| 腹股沟疝修补 | 90 | 35 | 62 |
| 腹壁疝修补 | 150 | 45 | 68 |
| 开腹部分胃切除 | 180 | 62 | 78 |
| 开腹全胃切除 | 240 | 78 | 90 |
| 开腹右半结肠切除 | 180 | 68 | 84 |
| 开腹乙状结肠切除 | 180 | 70 | 85 |
| 开腹直肠切除（含肛门） | 300 | 84 | 93 |
| 开腹胰十二指肠切除 | 360 | 95 | 100 |
| 开腹肝叶切除 | 300 | 90 | 98 |
| 开腹脾切除 | 120 | 58 | 75 |
| 开腹卵巢囊肿切除 | 120 | 48 | 70 |
| 开腹子宫肌瘤切除 | 150 | 55 | 74 |
| 全乳房切除 | 120 | 58 | 76 |
| 开胸肺叶切除 | 180 | 78 | 90 |
| 开胸全肺切除 | 240 | 88 | 96 |
| 开胸食管切除 | 360 | 94 | 99 |
| 开腹膀胱全切除 | 300 | 87 | 96 |
| 开腹肾切除 | 120 | 72 | 86 |
| 开腹主动脉瘤修补 | 240 | 93 | 99 |
| 经阴道子宫全切除 | 180 | 70 | 84 |
| 开胸人工心脏系统置换 | 360 | 90 | 100 |

### 2.4 已实现/未实现清单

| 项目 | 当前状态 | 工程事实 |
|---|---|---|
| 普通成功手术 XP | 已实现 | 上述公式 |
| First completion / first exposure bonus | 当前未发现 | 首通只负责解锁 Quick Surgery，没有额外 XP |
| 重复手术次数惩罚 | 当前未发现 | 只有难度差和 training ceiling 会使重复低难手术收益下降 |
| Training ceiling | 已实现 | 每术式数据字段 + 结算截断 |
| 作为助手学习 XP | 当前未发现 | 玩家始终按主刀 Surgery XP 路径结算 |
| Staff-as-Patient 通用 XP | 当前未发现 | 没有按“医护作为患者”分类的通用 XP 公式；特定事件可另给固定 XP |
| Quick Surgery XP | 已实现 | 与完整手术共用 `finish_active_surgery()`，没有扫荡折扣 |
| 失败 XP | 当前为 0 | `finish_active_surgery()` 要求 `surgery_success`；没有失败后部分 XP 路径 |
| 极端越级抑制 | 已实现 | 难度差 >30 时仅 0.20 倍 |
| 错误适应证抑制 | 已实现 | 0.20 倍；另有错误术式玩家属性惩罚 |
| 纠错惩罚 | 已实现 | 每次 -10%，最低 50% |
| Team Surgery XP Bonus | 当前未发现 | 队员技能、熟悉度和组成均未进入 XP 公式 |
| Leadership XP | 当前未发现 | 无字段、公式或结算记录 |

### 2.5 特殊事件固定 XP

来源：`data/events/special_events.json`，由 `apply_special_event_completion_effects()` 直接加入累计 XP；不走普通难度/ceiling 公式。

| 特殊事件 | 固定 XP | 同时登记完成术式 |
|---|---:|---|
| 深山 Lv1《叮。》 | +8 | 大开腹探查 |
| 深山 Lv3《手术室之神》 | +12 | 开腹胆囊切除 |
| 千束 Advanced Referral 教学 | +360 | 人工心脏系统置换 |

`data/cases/advanced_referral_cases.json` 也包含病例奖励数据，但当前完成教学的实际通用入口是特殊事件 `completion_effects`；当前未发现可重复高级转诊统一调用该病例奖励并结算 Surgery XP 的完整运行时路径。

---

## 3. Professional Reputation 经济

### 3.1 基础与范围

- 起始值：0。
- clamp：-100–999。
- 存储：非手术/手术/事件变化最终写入 `archived_player_effects.reputation`；活动中的 visit/preop 效果在归档前也会被 `player_attributes()` 即时计入。
- 存档：`archived_player_effects` 与历史记录持久化。
- UI：医生属性页与办公室显示精确值，范围 -100–999。

### 3.2 普通成功手术奖励

实现：`surgery_reputation_profile()`、`surgery_reputation_award_for()`、`award_surgery_reputation()`。

| base difficulty | 档位 | 基础奖励 | 软上限 | 硬上限 |
|---:|---|---:|---:|---:|
| `< 50` | 简单 | +5 | 80 | 100 |
| `50–74` | 普通 | +10 | 240 | 300 |
| `75–89` | 高级 | +20 | 480 | 600 |
| `>= 90` | 极难 | +50 | 800 | 999 |

- 当前 Reputation 达到该档软上限后，本档奖励减半并向上取整。
- 达到该档硬上限后，该档手术奖励为 0。
- 最后一次奖励会裁剪到硬上限。
- 完整手术与 Quick Surgery 共用该规则。
- 手术时长、纠错次数、适应证错误和队伍组成当前不改变 Reputation 奖励；档位只看术式 `base_difficulty`。

### 3.3 其他 gain/loss

| 来源 | Reputation |
|---|---:|
| 办公室“整理并撰写手术报告” | +1；120 分钟；可重复 |
| 办公室“整理病例资料” | +1；60 分钟；可重复 |
| 千束 Advanced Referral 教学完成 | +30 |
| 深山 Lv3《手术室之神》完成 | +2 |
| 明知术式不匹配仍继续 | -10 |
| 坚持无麻醉 | 当前无 Reputation 变化 |
| 普通手术失败 | 当前未发现扣除路径 |
| 错误适应证但仍完成 | 没有额外通用 Reputation 扣除；只有上述明确错误选择的 -10 与 XP 0.20 倍 |

当前没有 `successful_no_anesthesia_surgeries` 计数器，也没有“无麻醉成功仍扣声望”的统一结算。规划稿中的这两项属于**仅设计稿存在**。

### 3.4 当前 Reputation gate

| 内容 | Gate |
|---|---|
| 城宮明日香首次刷手池事件 | 完成手术 ≥2 **或** Reputation ≥5 |
| 伊吹摩耶首次正式相识 | Day ≥60，且完成手术 ≥8 **或** Reputation ≥20 |
| Advanced Referral 系统 | Surgery ≥85 且 Reputation ≥60 |
| 千束 Advanced Referral 教学 | Surgery ≥85、Reputation ≥60、御堂 Lv1，另有角色相识前置 |

当前角色事件中未发现其他 Reputation 数值 gate。

---

## 4. 当前手术团队实现

### 4.1 普通手术岗位

定义：`data/patients/templates/preop.json`  
运行时：`godot/systems/preop_session.gd`  
UI：`godot/ui/preop_view.gd`

| 岗位 | `role_id` | 职业过滤 | UI 展示技能 |
|---|---|---|---|
| 助手医师 | `assistant_surgeon` | doctor | `skills.surgery` |
| 器械护士 | `scrub_nurse` | nurse | `skills.instrument_handling` |
| 巡回护士 | `circulating_nurse` | nurse | `skills.teamwork` |
| 病房准备护士 | ward role | nurse | `skills.patient_care` |
| 麻醉 | 无人员岗位 | — | 通过全麻/硬膜外/局麻/不麻醉方案选择 |

`team_ready()` 要求三个手术岗位均选人，且三人不能重复。

`qualified()` 当前只检查：

1. 是已知/允许出现的职员；
2. `team_category` 或 `profession` 与岗位职业相同。

它**不检查**：

- `surgical_roles` 是否包含该岗位；
- `surgery_proficiency` 是否达到门槛；
- 对应技能是否达到门槛；
- 角色是否真正适任某专科。

### 4.2 医护技能字段

来源：`data/characters/staff.json`、`data/schemas/content.schema.json`。

```text
skills.surgery
skills.diagnostics
skills.teamwork
skills.patient_care
skills.instrument_handling
skills.calmness
surgery_proficiency
surgical_roles
team_category
```

这些字段会显示在职员/选人 UI 或用于职业过滤与对白，但当前没有进入手术成功、Surgery XP 或 Reputation 公式。

### 4.3 Familiarity、共同手术数与 Team Bond

- 成功手术后，`award_surgery_team_familiarity(team)` 给每位已相识且不重复的队员 Familiarity。
- 基础为 +5；乘职员 `familiarity_gain_multiplier` 后四舍五入。当前小夜香为 1.8，即每台约 +9；其他多数为 +5。
- Sunday Date 基础 Familiarity +10，同样乘角色倍率。
- 关系阈值为 `[0, 10, 25, 45, 70]`；Lv1 必须由事件建立，之后 Familiarity 才能使 rank ready。
- 没有团队整体 Familiarity、六人组合 chemistry 或队员彼此间 Familiarity。
- 没有专门持久化的“某角色共同手术次数”字段。办公室关系页的 `shared_operations()` 临时扫描当前 `preops` 中成功且含该成员的记录；患者轮换会归档并删除 preop，因此它不是可靠的全年累计统计。
- UI 根据这个临时计数显示“陌生/熟悉/默契/老搭档”，但该标签当前不参与结算。

### 4.4 高级转诊与 Grand OR

`data/cases/advanced_referral_cases.json` 的教学病例数据声明：

- Primary Surgeon ×1
- Assistant Surgeons ×2
- Scrub Nurses ×2
- Circulating Nurses ×2
- Anesthesia Team ×1

但当前千束教学由固定特殊事件节点表现；普通 `PreopSession` 仍只有三岗位选择器。特殊事件会设置 `grand_or_team_builder_enabled` flag，当前未发现该 flag 已接入一个可复用的 Grand OR 选人/结算系统。因此：

- 高级病例岗位数据：**数据层存在**。
- 教学剧情中的大型团队：**剧情层存在**。
- 可复用 Grand OR 团队构建器：**当前未发现完整实现**。
- 独立麻醉医师选人：**当前未在普通手术实现**。

### 4.5 Quick Surgery / auto-resolution

入口：`procedure_sweep_unlocked()`、`sweep_active_surgery()`。

解锁条件：

1. 术式已解锁；
2. `completed_surgeries_by_procedure[surgery_id] > 0`。

使用限制：

- 只能在当前患者的术式选择阶段使用；
- 只能扫荡该患者的适应术式；
- 使用已在 preparation 中选择的团队。

结算：

- 术式标准时长 + 固定 30 分钟术后整理；
- 同普通手术的 Surgery XP 公式；
- 同普通手术的 Reputation 公式；
- 同普通手术的团队 Familiarity；
- 增加总完成数、术式完成数、术式组完成数；
- 无扫荡专属失败、品质或收益折扣。

---

## 5. Named Character 解锁与关系 gate

### 5.1 通用关系实现

数据：`data/relationships/relationships.json`  
事件：`data/events/character_events.json`、`data/events/special_events.json`  
运行时：`GameState.character_event_available()`、`special_event_available()` 及相关函数。

- 关系 JSON 中所有 20 名职员初始 `met=false, level=0, familiarity=0, route=colleague`。强制序章在角色成为 speaker 时调用 `meet_staff()`，因此神宫寺、七濑、中井、朝仓和小夜香会在 Day1 序章中实际变为已相识。
- 初始 Affection：明日香 2、诗织 2、小夜香 4；其他 0。
- 通常最高 Lv5；带 `professional_friendship_only` 时最高 Lv3；带 `relationship_progression_locked` 时最高 Lv0。
- 通用关系事件可检查：日期、Affection、Familiarity、前置事件、事件间隔、玩家属性、总手术数、术式组手术数、story flag、特殊事件完成。
- 当前没有统一的 `earliest / typical / late + primary_stat + secondary_stat` schema；各事件直接在 `conditions.special_requirements` 中写条件。
- 当前玩家性格相关 gate 只支持通用 `player_attribute`，但现有角色事件只使用 `skill`。没有角色事件使用 `charisma`、`intimidation`、`ethics` 或双向 Presence 作 gate。

### 5.2 全角色现状表

| actor_id | 显示名 | 首次正式相识 / unlock | 最早日期与职业 gate | 已实现关系进度 | 关键限制/风险 |
|---|---|---|---|---|---|
| `doc_aoi` | 神宮寺成美 | Day1 强制序章正式介绍 | Day 1 | 无关系升级事件 | 序章会设为已相识；退休的 Lv1 事件槽为空 |
| `doc_rei` | 深山佳織 | 检查室自动介绍 | Day 1 | 特殊事件 Lv1 Day3；Lv2 Day5 + 佳织Lv1 + 诗织Lv1；Lv3 Day8 + 佳织Lv2 | Lv4/Lv5 未实现；Lv2 依赖诗织先完成介绍 |
| `nurse_haru` | 七瀬恋 | Day1 强制序章正式介绍 | Day 1 | 无关系升级事件 | 会自然满足 Advanced Referral 的“已相识”前置；退休的 Lv1 事件槽为空 |
| `nurse_rin` | 中井美佳 | Day1 强制序章护士站介绍 | Day 1 | 无关系升级事件 | JSON 另有手动 introduction，但序章已设为 met 后该 introduction 不再可用 |
| `nurse_yui` | 朝仓美幸 | Day1 强制序章护士站介绍 | Day 1 | 无关系升级事件 | JSON 另有手动 introduction，但序章已设为 met 后该 introduction 不再可用；会自然满足 Advanced Referral 已相识前置 |
| `pharmacist_manami` | 饭村真奈美 | 药房自动介绍 | Day 1 | 仅介绍 | Lv1–Lv5 未实现 |
| `nurse_ange` | 利根川安琪 | 护士站自动介绍 | Day 2 | 仅介绍 | Advanced Referral 与深山 Lv3 要求已相识/登场 |
| `nurse_hiroko` | 杉村弘子 | Day2 OR 患者逃跑 → 次日护士站正式介绍 | Day 2 | 再需萌惠介绍 + 总手术≥1触发器械恐慌；次日 Lv1，解锁 team invite | Advanced Referral 教学要求已相识 |
| `nurse_moe` | 本庄萌惠 | Day2 术前更衣阶段走错更衣室 → 次日护士站介绍 | Day 2 | 仅介绍 | 深山 Lv3 required character |
| `doc_emiko` | 御堂江美子 | 办公室先被拒；正式介绍要求 Surgery≥56 | Day 1 + Surgery 56 | Lv1：介绍后隔1天、Surgery≥56、90分钟手术；Lv2：隔7天、Familiarity≥10、Surgery≥70 | 确有额外高 Surgery gate；间接卡 Artoria 与 Advanced Referral |
| `doc_asuka` | 城宮明日香 | 术前更衣阶段刷手池事件 | Day 1 + 总手术≥2 **或** Rep≥5 | 相邻手术揭示 → 次日院长室正式介绍；暂无关系 Lv | Artoria 链还依赖御堂正式介绍 |
| `doc_artoria` | 阿尔托莉雅·潘德拉贡 | 明日香正式介绍 + 御堂正式介绍 → 明日香提及竞争者 → 副部长办公室介绍 | Day 1，但受御堂 Surgery56 间接 gate | 手动 Lv1 事件解锁手术团队 | `team_unlock_requires_lv1`；当前最早时点主要由御堂 gate 决定 |
| `doc_shiori` | 藤崎诗织 | 门诊或病房二选一介绍 | 总手术≥3 | 仅介绍，只会设为 `met=true` | 深山 Lv2 要求诗织关系 Lv1，但当前没有诗织 bond/Lv1 事件；正常流程无法满足 |
| `doc_aqua` | 水城阿库娅 | 妇科检查室自动介绍 | 女性盆腔组手术≥1 | Lv1：同组手术≥5，解锁手术团队 | `team_unlock_requires_lv1` |
| `doc_sayaka` | 南条小夜香 | Day1 强制序章走廊相识 | Day 1 | Day2–5 强制电话交换；首次约会需玩家选择产生 `sayaka_mutual_attraction` 才升 Lv1；次日回调；Lv2 需 Familiarity≥10 | Familiarity 倍率 1.8；Lv3–Lv5 未实现 |
| `visiting_maya` | 伊吹摩耶 | 影像科自动介绍 | Day≥60 且总手术≥8 **或** Rep≥20 | 无 | `relationship_progression_locked`，只可相识 |
| `visiting_futaba` | 佐仓双叶 | 摩耶介绍后，影像科自动介绍 | Day≥60（由摩耶链保证） | 无 | `relationship_progression_locked` |
| `nurse_ishigami` | 石神千鹤 | 当前未发现普通介绍事件 | — | 无 | `introduction_pending`、关系锁定；却是 Advanced Referral 教学 required character，构成正常流程阻断风险 |
| `doc_sakura_anesthesiology` | 樱花 | Advanced Referral 教学内 choice `meet_characters` | 教学 gate 之后 | 无 | `relationship_progression_locked`；不是教学前置本人 |
| `nurse_satsuki` | 折川皐月 | 当前未发现角色事件 | — | 无 | `introduction_pending`；现阶段无法正式解锁 |

### 5.3 御堂与 Saber 的实际依赖链

```text
Surgery ≥56
→ emiko_intro_rumored_hands
→ emiko_lv1_first_operation（仍要求 Surgery ≥56）

emiko_intro_rumored_hands
+ intro_doc_asuka_director_office
→ asuka_mentions_artoria_rival
→ intro_doc_artoria_deputy_office
→ artoria_lv1_right_position
→ Artoria 可加入手术团队
```

因此，御堂的 Surgery 56 gate 不只延后御堂，也会间接延后 Artoria 的正式介绍与入队。

### 5.4 Advanced Referral / 樱花 / 千束教学实际 gate

系统级 gate：

```text
Surgery ≥85
Reputation ≥60
```

千束教学特殊事件还要求：

```text
前置事件：emiko_lv1_first_operation
御堂关系 Lv ≥1

以下角色全部已相识：
PLAYER
doc_asuka
doc_emiko
nurse_hiroko
nurse_ishigami
doc_sayaka
nurse_yui
nurse_haru
nurse_ange
```

事件完成后：

- 解锁人工心脏系统置换；
- 登记该术式完成 1 次；
- Surgery XP +360；
- Reputation +30；
- 设置 Advanced Referral、Grand OR、樱花相识等相关 flags；
- 教学内通过 `meet_characters` 将樱花设为已相识。

当前阻断点：`nurse_ishigami` 没有普通介绍事件，却要求在教学开始前已相识。`nurse_haru` 虽无独立角色事件，但会在强制序章中相识，因此不是阻断点。除非另有调试/迁移路径将石神设为 met，正常流程无法自然满足全部 required characters。

### 5.5 可能造成“过早或过晚”的现有条件

只列工程事实：

- 过晚/阻断：御堂 Surgery56；Artoria 被御堂间接 gate；深山 Lv2 要求当前无法获得的诗织 Lv1；Advanced Referral 要求 Surgery85 + Rep60 + 多名已相识角色，其中石神缺正式入口。
- 过早：明日香理论上可在 Day1 通过 Reputation5 或两台成功手术触发；诗织无日期窗口，只需三台手术；阿库娅无日期窗口，只按女性盆腔手术次数。
- 高密度：多数介绍事件只设 `min_day`，没有统一 pending intro queue 或全局介绍 cooldown；满足多个条件时可在相邻地点/日期密集出现。
- 深山 Lv1–Lv3 在 Day3/5/8 的硬日期很早，且 Lv1、Lv3 自带固定手术完成与 XP。

---

## 6. 日历与行动经济

### 6.1 日历与工作日

实现：`godot/systems/fixed_calendar.gd`、`godot/systems/game_state.gd`。

- 游戏日期：2025-04-01 至 2026-03-31，共 365 天。
- 每日班次：09:00–17:00，480 分钟。
- 周一至周五：普通工作日。
- 周六：limited workday。
- 周日、法定假日、2025-12-29 至 2026-01-03：closed day。
- 系统不是“早/中/晚几个固定行动槽”，而是所有问诊、准备、事件和手术累计分钟。

### 6.2 时间构成

总 elapsed 由以下内容共同组成：

- 问诊行动分钟；
- 病房/术前行动分钟；
- 普通 time event 分钟；
- 角色事件分钟；
- 特殊事件/剧情推进分钟；
- Surgery `duration_minutes`；
- 术中选择造成的 `procedure_extra_minutes`；
- 每台成功手术固定 `POSTOPERATIVE_WRAP_UP_MINUTES = 30`。

手术结算实际耗时：

```text
procedure duration
+ intraoperative extra minutes
+ 30 分钟术后整理
```

### 6.3 Day End / overtime

`settle_overtime(start_elapsed, action_minutes)` 在行动完成后检查：

- 若开始时当日已用分钟 + 本次行动分钟 `< 480`，仍在当天。
- 若 `>= 480`，本次行动仍先完成，再进入次日 09:00。
- 超过 17:00 的部分计入 `discarded_overtime_minutes` 并被丢弃，不挤占次日班次。

这意味着理论日手术量应按“最后一台允许跨过 17:00 后结算”理解，而不是严格要求每台在 17:00 前结束。

### 6.4 仅按手术时间计算的理论上限

以下完全忽略问诊、住院、病房准备、选人、角色事件等前置，只用于说明当前时间结算的机械上限：

| 示例术式时间 | 加术后整理后的单台占用 | 在一次 Day End 前可完成的理论台数 |
|---:|---:|---:|
| 60 分钟（最短，如阑尾） | 90 | 6 |
| 90 分钟 | 120 | 4 |
| 120 分钟（常见中小手术） | 150 | 4 |
| 150 分钟 | 180 | 3 |
| 180 分钟（中型） | 210 | 3 |
| 240 分钟（大型） | 270 | 2 |
| 300 分钟 | 330 | 2 |
| 360 分钟（高难大型） | 390 | 2 |
| 480 分钟（大开腹探查） | 510 | 1 |

这里的 6/4/3/2 包含“最后一台开在当天、做完后触发跨日”的情况。真实完整病例流程明显更低，因为门诊和病房阶段也使用同一 480 分钟预算。

### 6.5 Sunday / Date

- 周日医院门诊与 OR 不提供普通流程。
- `complete_sunday_activity()` 每个周日只完成一个活动，然后推进到次日 09:00。
- Date 是 Sunday activity；给予基础 Familiarity +10 × 角色倍率，并记录 Sunday history。
- 普通休闲/办公室 Sunday 活动同样消耗该周日机会。

### 6.6 强制整天事件

当前 `data/events/special_events.json` 的 7 个特殊事件均标记 `consumes_full_day=true`：

- 两个开发者框架测试事件；
- 新手术室启用日；
- 深山 Lv1；
- 深山 Lv2；
- 深山 Lv3；
- 千束 Advanced Referral 三日教学。

特殊事件每个 event day 结束会直接推进到下一天。千束教学 `duration_days=3`，因此占三个完整日历日。

### 6.7 影响 3/6/9/12 月手术量估算的现有假设

- 真实资源是分钟，不是固定行动点。
- 最后一项行动可跨越 17:00；超时部分被丢弃，因此大手术不会侵占次日时间。
- 每台手术固定增加 30 分钟整理。
- Full Surgery 与 Quick Surgery 消耗相同标准术式时间；Quick Surgery 只节省玩家现实操作时间。
- 所有患者仍需要当前病例/术前结构，Quick Surgery 只能在术式选择阶段启动，并非从医院地图直接批量结算。
- 周日、法定假日与年末休诊会减少普通门诊/OR 天数。
- 角色事件与特殊事件会占分钟或整天。
- 随机病例分配、术式解锁、training ceiling 会影响玩家愿意/能够刷的术式。
- 当前没有排班容量、床位、疲劳、并发症失败或每日硬手术台数上限；主要约束是时间、病例流与解锁。

---

## 7. 未来实装影响范围地图（只列当前接入点）

### 7.1 Leadership

当前不存在该字段。若未来加入，会涉及现有接入点：

- `godot/systems/game_state.gd`
  - 玩家属性基础/范围或独立 XP 状态；
  - `snapshot()` / `restore()` 与存档版本迁移；
  - 手术最终结算入口 `finish_active_surgery()` / `sweep_active_surgery()`。
- `godot/systems/save_store.gd`：存档封装与验证链。
- `data/schemas/content.schema.json`：玩家效果、gate、特殊事件效果 schema。
- `data/events/character_events.json`、`data/events/special_events.json`：如未来作为 gate/奖励。
- `godot/ui/app.gd::show_player_profile()` 与 `godot/ui/player_office_view.gd`：玩家属性显示。
- 本地化 `data/localization/*.json`。

### 7.2 Charm

当前已有 `charisma`，接入点为：

- `GameState.PLAYER_ATTRIBUTE_*`、`player_attributes()`、属性历史与存档迁移；
- `EncounterSession.player_effects` / `PreopSession.player_effects`；
- `content.schema.json` 中的 `player_effects` 与 `player_attribute` gate；
- `app.gd`、`player_office_view.gd` 的精确值 UI；
- 角色事件和 Sunday/Date 内容数据。

当前没有五档显示、重复收益衰减或通用 Date Charm 结算。

### 7.3 Clinical Presence

当前最近似字段是 `intimidation`，但它是 0–100 单向成长值。若未来改为双向人格轴，现有接入点包括：

- `PLAYER_ATTRIBUTE_BASE/MIN/MAX` 与 `player_attributes()`；
- 旧存档中的 `archived_player_effects.intimidation` 迁移；
- 问诊/术前数据的 `player_effects.intimidation`；
- `content.schema.json`；
- `app.gd` 与办公室当前“威压”精确值进度条；
- `EncounterSession` / `PreopSession` 的患者状态计算与对白分支；
- 角色/特殊事件 `player_attribute` gate；
- 本地化键。

当前 `fear/cooperation` 已存在，可作为未来行为效果接入点；当前没有 Presence 自动影响它们的全局解析器。

### 7.4 Reputation 曲线重平衡

直接接入点：

- `godot/systems/game_state.gd`
  - `PLAYER_ATTRIBUTE_MIN/MAX`
  - `surgery_reputation_profile()`
  - `surgery_reputation_award_for()`
  - `award_surgery_reputation()`
  - `advanced_referral_system_unlocked()`
- `data/time_events.json` 的办公室 +1 行动；
- `data/patients/templates/preop.json` 的错误术式 -10；
- `data/events/special_events.json` 的 +30/+2；
- `data/events/character_events.json` 与特殊事件的 Reputation gate；
- `data/cases/advanced_referral_cases.json` 的奖励数据；
- `data/schemas/content.schema.json`；
- `godot/ui/app.gd`、扫荡结算 UI、办公室属性 UI；
- 相关测试：`tools/surgery_progression_test.gd`、`tools/surgery_sweep_test.gd`、`tools/advanced_referral_test.gd`。

### 7.5 Character unlock gate 统一结构

当前 gate 分散在：

- `data/events/character_events.json::conditions`
- `data/events/special_events.json::unlock_requirements / required_characters / prerequisite_events`
- `data/relationships/relationships.json::rank_slots`
- `data/characters/staff.json::flags`
- `godot/systems/game_state.gd::character_event_available()`
- `godot/systems/game_state.gd` 的 special event availability 函数
- `godot/systems/character_event_session.gd`
- `godot/systems/special_event_session.gd`
- `godot/systems/presence_resolver.gd`（地点/出勤）
- `data/schemas/content.schema.json`
- 角色/地点/关系 UI 与事件测试工具。

当前没有单独的角色 unlock matrix 数据文件，也没有统一 `earliest/typical/late` 运行时字段。

### 7.6 Team Surgery XP Bonus / Leadership XP

当前最直接的结算接入点：

- `godot/systems/preop_session.gd`
  - `team`
  - `role_definition()` / `qualified()` / `team_ready()`
  - `surgery_success`、纠错与术式结算状态
- `godot/systems/game_state.gd`
  - `award_surgery_team_familiarity()`
  - `surgery_xp_award_for()` / `award_surgery_xp()`
  - `finish_active_surgery()`
  - `sweep_active_surgery()`
  - `snapshot()` / `restore()`
- `data/characters/staff.json`
  - 现有技能、`surgery_proficiency`、`surgical_roles`、`familiarity_gain_multiplier`
- `data/patients/templates/preop.json`
  - 普通岗位定义
- `data/cases/advanced_referral_cases.json`
  - Grand OR 岗位数据
- `data/schemas/content.schema.json`
- `godot/ui/preop_view.gd`、`godot/ui/app.gd` 的团队选择与手术/扫荡结算显示
- `godot/ui/player_office_view.gd` 的关系/共同上台显示
- `tools/preop_test.gd`、`tools/surgery_progression_test.gd`、`tools/surgery_sweep_test.gd`、高级转诊测试。

当前团队数据可供读取，但没有 Team Bonus、Leadership XP、队伍难度或“合格新人/强班底”分类的运行时计算。

---

## 8. 代码、数据与设计稿状态对照

| 能力 | 状态 |
|---|---|
| Surgery Lv/XP 指数成长 | 代码已实现 |
| 术式 training ceiling | 代码已实现 |
| Quick Surgery | 代码已实现 |
| 难度分层 Reputation | 代码已实现 |
| 团队 Familiarity | 代码已实现 |
| 可靠的全年共同手术次数 | 当前未实现为持久化数据 |
| Leadership | 完全不存在于运行时 |
| Team Surgery XP Bonus | 完全不存在于运行时 |
| Charm 五档与主动生活成长循环 | `charisma` 基础值存在；规划中的完整系统尚未实现 |
| 双向 Clinical Presence | 规划稿存在；运行时只有单向 `intimidation` |
| 无麻醉手术计数/声望代价 | 规划稿存在；当前未实现 |
| 统一角色解锁结构 | 规划稿存在；当前 gate 分散在多类事件数据中 |
| Grand OR 可复用团队构建器 | 数据和剧情 flag 存在；普通运行时未发现完整实现 |
