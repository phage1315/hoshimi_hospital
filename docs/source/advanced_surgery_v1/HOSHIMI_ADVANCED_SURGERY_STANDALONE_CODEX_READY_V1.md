# Hoshimi Hospital — Standalone Advanced Surgery / Advanced Referral
## Codex-Ready Implementation Handoff V1（独立可玩垂直切片）

> **状态：可交给 Codex 开发的 V1 实装规格。**
>
> 日期：2026-10-30。目标是先让三台高级手术在真实 Godot 工程中完整跑通 Day 1 → Day 2 → Day 3；不是宣称已验证 Godot 现有 API，也不是把测试医生数值写成正式角色数值。
>
> **Standalone 的定义：** 具有独立的高级转诊入口、日程、队伍编组、手术会话、HP／Precision 规则、结算与存档状态，能够用占位患者独立测试；但应当**复用**工程已经具备的 Staff / Calendar / Save / 普通 Surgery 的生理指标、危机、经验与声望 resolver。绝不为此复制整套普通手术引擎，也不修改普通病例的判定语义。
>
> 本稿允许并明确标记 `PLACEHOLDER_*`。除 §14 列出的真正工程阻塞点之外，患者、对白、CG、背景和初始演示入口的缺失不得成为 Codex 停工理由。

## 0. Source precedence / 不可擅自改变的边界

1. **用户在本轮明确确认的最新规则优先**：HP=100；精细挑战概率判定；两个助手各通常一次；Surgery≥90 且专科吻合可二次；强力万能型专家例外；Grand OR 助手参与后 14 **日历天**冷却；护士提供支持但不做外科操作；首次失败永久锁定该术式；首通后随机患者返场且返场失败不撤销通关；三个首发新术式槽、每周 1–3 个可用返场；唯一首通数 5 解锁宫园薰事件条件、10 解锁 Ray 事件条件。
2. `HOSHIMI_FIVE_DIMENSION_IMPLEMENTATION_SPEC.md` 为玩家属性与奖励 authoritative：高级转诊正式资格 `Surgery >= 80 && Professional Reputation >= 250` 加已有 tutorial / 职责前置；**不另设** `major_surgeries_completed` 资格 Gate。Grand OR Leadership 的六人 relevant skills、Advanced Reputation +40、软硬上限等复用该文件。
3. `HOSHIMI_SURGERY_PROCEDURE_POOL_MASTER_LIST_V0_1.md` 为术式 ID 和 30/20/4 库存 canonical；本稿三台均取自 Advanced 的 20 个名额，不占宫园薰三台 Quest，也不占千束 Tutorial。
4. `HOSHIMI_SURGERY_UNLOCK_CASE_POOLS_AND_ADVANCED_REFERRAL_SYSTEM_V0_1.md` 为三日、Grand OR 岗位、正常全麻、与固定剧情周避让的基准；该较早文件里“首次后患者原则上不重复”的旧表述，**以最新用户的术式首通后随机患者返场规则替换**。
5. `HOSHIMI_COMMON_SURGERY_GAMEPLAY_PILOT_CODEX_READY_V2.md` 仍是 **Ordinary** 的 authoritative。普通 Surgery 的技术 option effect 仍为确定性。**仅新的 Advanced `Precision(P)` 节点允许技术概率失败**；不准把这种 RNG 扩散到 Ordinary、Quick Surgery 或原有 Surgical Quality 随机结算。
6. 本稿的 HP 数字以 `HOSHIMI_ADVANCED_SURGERY_THREE_CASE_BALANCE_POC_V1.md` 及伴随 `hoshimi_advanced_surgery_balance_sim.py` 的第二轮已校准原型为准。它们是**测试平衡参数**，由 Godot 实测后才可锁定正式参数。测试中的“御堂型 Surgery97／Saber型94”等是 fixture，**不是** canonical Staff 数值。

## 1. 交付目标、最小完成定义与不在本次范围内

**Codex 必须交付的可玩最小闭环：**

1. 有独立「高级转诊 / Advanced Referral」入口，可从开发测试菜单直接打开；正式入口是否可见遵循现行资格。可查看三个新的测试术式。
2. Day 1 查看占位患者病例、简短占位剧情、编组 Grand OR、查看标签与**有准确限定语**的团队成功率估算，确定后锁定本次排程。
3. Day 2 进入真正可交互的 Advanced Surgery Runner，完成 11–13 个阶段、5–6 个 P 节点；HP 100、委托、一次性援救、危机 HP 成本、手术失败都能实际运行。
4. Day 3 显示成功/失败总结，原子化写入首通/永久失败状态、14 天助手冷却、经验与声望（使用已有正式 resolver），返场记录。结算一次且仅一次。
5. 首通后每周可得到 1–3 个从已通关术式中抽取的返场病例；返场不重复播专属 Day 1 剧情，仍须正式编组。返场失败不回滚首通。
6. 能保存/读取完整进行中状态；能重复测试、查看 debug 日志；普通手术玩法与现有存档不受影响。

**本轮明确不做：**

- 不实装其余 17 台 Advanced 的手术节点；只保留未来可注册的模板。
- 不制作千束 Tutorial、宫园薰三连、Ray 传奇术式的剧情；只在现有系统适用时检查 tutorial gate、维护两个解锁标记。
- 不制作正式患者角色 ID、立绘、CG、专属台词、完整术前/术后 VN、美术术野差分；均使用合法占位内容。
- 不另做真实医学教学器、完整 HR/BP/SpO2 麻醉模拟、真实神经解剖小游戏、微创器械物理模拟。
- 不强迫所有 Advanced 用全新 UI；优先复用现有场景和窗口组件。
- 不修改 Ordinary option-level deterministic 技术选择、普通病人池刷新或已经锁定的 Quick Surgery 资格。

## 2. Codebase discovery — Codex 开工顺序（先查再接）

在改动项目以前使用代码检索，确认并在交付报告列出实际路径：

| 检查项 | 必须确认的工程事实 |
|---|---|
| Surgery | 真正被运行时加载的 procedure registry、普通 Surgery Runner / Stage renderer、Stage effect/complication/physiology resolver |
| Calendar | 游戏工作日、周日、接受病例、三日事件排程、固定剧情周占位检测、日期顺延与时钟前进函数 |
| Staff | 真实 canonical Staff ID、`skills.surgery`、`skills.instrument_handling`、`skills.teamwork`、外科助手/器械/巡回许可、麻醉团队存在方式 |
| Save | Save/Load schema、episode 内 RNG seed 与 `resolved_random_choices`、当前进行中的手术会话如何恢复 |
| Settlement | Surgery XP、训练上限、Team Surgery XP bonus、Leadership XP、Staff training credits、Professional Reputation 上限与失败结算 |
| Presentation | VN runner、现有术前 Team Selection UI、演员注册与姓名框/立绘绑定、普通 Surgery Grade/Patient Experience 结算视图 |

不要因为同名旧 JSON 存在，就修改多个似乎能用的资源文件。找到 authoritative runtime source 后再添加注册；不推测场景路径。推荐的模块名仅作建议：`AdvancedReferralBoard`、`AdvancedTeamBuilder`、`AdvancedRiskEstimator`、`AdvancedSurgerySession`、`AdvancedPrecisionResolver`、`AdvancedSettlementBridge`。Codex 可根据现有架构等价实现。

开发测试入口必须与正式资格隔离：

```yaml
advanced_referral_prod_gate:
  surgery_at_least: 80
  professional_reputation_at_least: 250
  tutorial_and_role_conditions: "consult_existing_runtime"
advanced_referral_dev_gate:
  allow_open_demo_board: true     # 只在明确的开发/测试模式
  may_use_mock_staff: true        # 不落入真实存档 Staff 数据
```

正式版本不得因测试入口而跳过资格、奖励或冷却；若工程已有千束 Tutorial，原样保留，不反向修改教程。**为了本次 vertical slice 可以不等教程内容完成，就直接打开独立测试面板。**

## 3. 三日生命周期（真实日期、不倒拨时钟）

这里的 Day 1/2/3 是**三个顺序执行的排程阶段**，绝不等同于写死某年的三天。`D1=实际接受之日`；`D2=现有 Calendar 判定的下一允许大型手术日`；`D3=其后的下一允许查房/结算日`。若当前工程允许连续三日则为 D、D+1、D+2；遇非营业日，必须通过现有日历规则推进，不猜测周日规则。

| 阶段 | 时间消耗合同 | 内容 / 重要状态 |
|---|---|---|
| Day 1 接诊/编组 | 接诊时运行约一小时事件；从**当前实际游戏时间向前**结算，绝不硬设某个过去 09:00 | 首发 VN 占位、病例风险、选人、麻醉确认；提交前可返回/改选；确认后保存 roster 与 D2、D3 |
| Day 2 手术 | 当前已排定的手术日，**占用整日手术窗口**，禁其他普通手术/冲突固定剧情 | 从持久化 roster 启动 Advanced Runner；完成或者因 HP/原有终止条件失败；参与助手立即记录 14 日历天 cooldown |
| Day 3 复盘/结算 | 下一个允许结算的排定日；默认约一小时占用，同样只前进时钟 | 成败结果占位、XP/声望/进度一次性结算、case 状态最终写入、恢复日常游戏 |

**排程验证：** 玩家接受病例前检查所有相关固定剧情锁定窗口；如果未来三个阶段无法无冲突排定，按钮不可确认，病例留在待处理列表；不应扣除首次挑战资格，也不能丢掉转诊请求。`[PLACEHOLDER_CALENDAR_NEXT_OPERATING_DAY]`：实际 helper 名称/周日处理待 Codex 核对工程；这不是允许自行重写游戏日历的授权。

**异常退出：** Day 1 仅打开 UI、未确认的病例仍 `AVAILABLE`。Day 1 已确认但 Day 2 未开始时为 `SCHEDULED`；不要因玩家返回标题或跨一次自动存档而锁成失败。Day 2 因手术结果失败才触发首发的永久失败语义。Day 2 的成功/失败先保存为 `AWAITING_DAY3`，Day 3 原子提交结算；中途读档/重新进入不得重复扣 HP 或多次领赏。

## 4. Board / 新病例、返场与进度

### 4.1 Procedure 与 case instance 是不同对象

- `procedure_id` 是术式身份；一个术式整周目只有一份首通状态。
- `case_instance_id` 是某次接诊，会变；首发固定占位患者，返场生成新的随机患者实例。不能把同一具名患者作为可无限重复的病例。
- Procedure 永久状态枚举：`UNSEEN`、`AVAILABLE`、`IN_PROGRESS`、`CLEARED`、`FAILED_LOCKED`。运行会话另外有 `SCHEDULED/DAY2_ACTIVE/AWAITING_DAY3/SETTLED`；不要把一条状态承担两种语义。

### 4.2 最新规则

1. 首发面板最多保留 **3 个尚未尝试的新术式**；当前 vertical slice 正好注册本文三台。以后加入其他 17 台时从真实未尝试术式库补充，而不是伪造未实现的病例。
2. 玩家首次挑战成功并完成 Day 3：`CLEARED`，加入该 procedure 的随机返场候选和 `unique_advanced_clears` 集合。
3. 玩家首次挑战失败并完成 Day 3：`FAILED_LOCKED`，本周目永不重新进入可挑战/返场池；读入更早的玩家存档是允许的正常游戏行为。
4. 已经 `CLEARED` 的术式，后续任意返场失败：保留 `CLEARED`、保留唯一首通数、下周仍可抽到；仍正常发生时间/人员冷却与失败结算。
5. 每个游戏周的**周一刷新**返场板：仅在 `CLEARED` 集合中抽出 1–3 个不同 `procedure_id`，不足则展示实际数量；随机患者 ID 稳定、同周不重复；周一生成一次并持久化，重开 UI/读档不重抽。
6. 默认可用 dev 刷新逻辑：从候选中均匀选本周展示数量 `1..min(3,已首通术式数)`；**正式权重 `[PLACEHOLDER_WEEKLY_REPLAY_WEIGHTS]`**，用户尚未锁定。至少保证仅 1 个已首通术式时也有返场机会。
7. Day 1 正在排程或 Day 2 正在手术的病例不能被新一周刷新删掉；同一时间只能存在一个 active Advanced Case。
8. `unique_advanced_clears >=5` 设置 `kaori_advanced_prerequisite_met=true`，`>=10` 设置 `ray_legendary_prerequisite_met=true`。这只是**前置条件标记**；正式剧情是否立即触发由未来 Quest Scheduler 决定。重复通关不计数。

### 4.3 病例样板

| ID | 首次患者 | 返场患者 | 首次 Day 1 VN |
|---|---|---|---|
| `surgery_open_whipple` | `PLACEHOLDER_ADV_PATIENT_WH01` | 从已存在随机患者工厂创建成年女性患者；若无安全接口，则 `PLACEHOLDER_ADV_REPLAY_WH` | `PLACEHOLDER_ADV_WH_DAY1` |
| `surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction` | `PLACEHOLDER_ADV_PATIENT_PV01` | 同上，独立实例 | `PLACEHOLDER_ADV_PV_DAY1` |
| `surgery_adv_sleeve_lobectomy` | `PLACEHOLDER_ADV_PATIENT_SL01` | 同上，独立实例 | `PLACEHOLDER_ADV_SL_DAY1` |

不存在的 patient ID 不得被当成真实角色资源强制加载；为占位患者提供安全的文字头像/剪影回退。Day 1 每例先用 5–10 条功能性中文对白或旁白占位，写明“非正式文学正文”，以后可无损替换，不让患者台词影响手术数值。

## 5. Day 1 Grand OR 编组合同

**真实 Grand OR：** `Primary Surgeon=坂口`，`First Assistant×1`、`Second Assistant×1`、`Primary Scrub×1`、`Secondary Scrub×1`、`Primary Circulating×1`、`Secondary Circulating×1`、`Anesthesia Team`。前六个可培养岗位均属于独立角色/位置；同一 Staff 不得重复占两个位置。麻醉是必要岗位，但暂不进入六人 Leadership 均值。

### 5.1 编组时验证

- 从项目已有 Staff registry 选择真实 canonical 实体；检查职位类型、可出勤、是否有角色剧情锁定/正在其他手术、当前真实技能。护士只能放在本人支持的护理白名单岗位。
- 两名助手必须是具备外科助手权限的医生，并且在 **预定 Day 2** 没有 advanced-assistant cooldown；`cooldown_until = 上次真实 Day2 + 14 日历天`，比较日期而不是纯事件完成次数。
- 两名器械护士提供概率加成，两名巡回护士提供危机 HP 成本减免；**护士不能被委托 P 操作**，无菌护士/巡回护士职责边界不得混淆。
- 麻醉使用正常全身麻醉的项目既有流程；不提供不合理无麻醉大型手术选项。麻醉医生的真实角色 / 资源仍为 `[PLACEHOLDER_ANESTHESIA_BINDING]`；缺少正式角色时仅允许开发测试使用无效果的占位麻醉位。
- 首次病例 Day 1 必须显示 `第一次失败将永久失去本周目该术式` 的醒目提醒；返场没有这条警告。

### 5.2 助手精细介入次数

```text
每名助手每台 Advanced 默认：1 次 P 介入
第二次介入前置：该助手 Surgery >= 90 且当前 P 节点 specialty_tag 匹配其 canonical 专科
特殊 universal_expert（御堂型）：Surgery >= 90 时可对任意 P tag 第二次介入
失败的委托同样消耗 1 次；Day 2 终止时不退还
第一名/第二名助手额度彼此独立；不能转让
```

专科如 `adhesion`、`neural`、`vascular`、`microdissection`、`reconstruction`、`pelvic`、`thoracic`、`airway`。正式人物映射 `[PLACEHOLDER_SURGEON_SPECIALTY_REGISTRY]`：Codex 先查真实技能/设定；不根据名字暗中假定某位医生就是 Surgery 97，不能偷偷改人物属性。无专科标记者仍可第一次数值介入，但不能第二次。

**冷却从参与 Day 2 的实际日期开始**，即使没真正接手 P 或手术失败也开始。冷却不禁止普通 Surgery / 剧情出场，只限制再次担任 Advanced Grand OR Assistant。

### 5.3 Day 1 团队风险展示

玩家应看到：主要高难 tag、两名助手能否在相应 tag 二次介入、冷却到期日、护理支持概览，以及：

> `HP 层预计完成率（采用标准计划委托策略）：约 75%`  
> `尚未包含全部术中生理指标；实际结果取决于临场决策。`

**只有在成功率预估复用全部真实 Runner 判定后**，才允许去掉 `HP 层` 限定并显示为总体 `预计手术成功率`。不能把离线 HP-only 模拟的数字冒充含 Stability / Blood Loss 的真实游戏胜率。

预估算法：使用当前真实队伍、完整 P 节点、当前 HP/crisis 测试规则，采用标准 `planned` 策略进行 512–2,000 次独立模拟（建议默认 1,024）；结果四舍五入到最近的 5%。预览使用**与真实手术 episode 完全隔离的随机流**，不泄漏 Day 2 的真实病例变体和判定随机数；队伍或术式改变才重算，缓存到 UI。若计算较慢，显示加载状态而不阻塞画面。

## 6. Day 2 Advanced Runner — 独立的新增玩法

### 6.1 可见状态与基本行为

手术开始创建 `operative_reserve_hp=100`。界面至少显示：

```text
手术进度：当前阶段 / 总阶段
患者手术储备 HP：0–100（单独进度条）
已有的 Stability / Visibility / Bleeding / Blood Loss / Time（根据项目原有 UI）
第一助手：剩余可介入次数、专科/当前是否可接手
第二助手：剩余可介入次数、专科/当前是否可接手
```

HP 是 Advanced 专属 `operative reserve`，不是普通患者的 Health，也不是已有 Stability 的别名。HP 不能借止血、复位、护理临时提高到 100 以上；V1 **没有 HP 治疗/回复操作**。`HP<=0` 立即停止后续 stages，判定 Day 2 失败；原有严重 Stability / physiological fail condition 也可以独立导致失败。不要用 HP 把已有体征、意外、血损替换掉。

四类 stage：

- `F`（Flow）：连续手术操作/自然叙述，玩家点击继续，扣一次该 stage 的基础 HP。
- `L`（Low-risk）：步骤确认与信息展示，扣一次基础 HP；本轮不暗藏新概率。
- `S`（Strategy）：**保留原 Surgery 的手术决策功能**；其 choice 的 Vitals / Time / Flags 经现有 resolver 处理一次，同时扣本稿 stage 的基础 HP。本文未给旧 S 选择编造新医学后果：如工程没有可复用的现成选项/效果，可先用 `PLACEHOLDER_S_STRATEGY_STANDARD_ONLY` 做垂直切片（标准单选/确认），但必须在交付清单标出这是待补的设计内容，**不得谎称已经具有全部原普通手术策略密度**。
- `P`（Precision Challenge）：这是 Advanced **唯一新增**的技术概率节点，出现“坂口亲自处理 / 第一助手接手 / 第二助手接手”选项，未满足剩余次数/专科条件的按钮灰掉并显示原因。

每个固定 stage 只结算一次 HP；从 UI 返回、切换肖像、回看台词、读档再次进入已完成 stage，均不能重复扣除。F/L/S/P 可以使用现有 OR 背景与姓名立绘，缺失 CG 回退普通术野背景 + 纯文本节点标题。

### 6.2 P 的可运行数学合同（测试数值）

下面公式逐项对齐现有 Python 原型；Codex 可以以这些值实现第一版，禁止把它们解释为医学统计概率。概率以 `0..1` 计算。

```python
effective_difficulty = stage.difficulty + (
    3 if anatomy_variant_is_difficult and stage.difficulty >= 95 else 0
)

scrub_main = min(0.035, max(0, primary_scrub.instrument_handling - 65) * 0.0013)
scrub_secondary = min(0.015, max(0, secondary_scrub.instrument_handling - 70) * 0.0007)
if stage.tag in ('adhesion', 'pelvic', 'neural'):
    scrub_secondary *= 0.6
scrub_bonus = min(0.05, scrub_main + scrub_secondary)

p_success = clamp(
    0.78 + 0.028 * (acting_surgeon_surgery - effective_difficulty) + scrub_bonus,
    0.08, 0.985
)

precision_base_cost = stage.hp_base + min(
    3, ceil(max(0, stage.difficulty - acting_surgeon_surgery) / 12)
)

# 每次 P 执行先扣 precision_base_cost，成功则完成该节点；失败再扣：
if failed_and_no_rescue:
    extra_hp = stage.hp_failed_extra
```

- Scrub Nurse 的加成绝不超过总计 **+5 percentage points**，也不提供额外代打或第二个手术成功判定。
- 玩家与医生助手共用同一公式；但两名助手每台剩余次数分别计数。
- `acting_surgeon_surgery` 取坂口当前 Surgery 值或助手真实 `skills.surgery`；不得用 Leadership / Charm / Reputation / 关系等级当技术替代品。
- 患者 anatomy variant 在整个 episode 创建时抽取一次并持久化：`standard=75%`、`difficult_anatomy=25%`；后者在**Stage 02 完成时额外扣 4 HP**，且使原始 `difficulty>=95` 的 P 节点有效难度 `+3`。这只是三台原型的共同测试变体；将来具名患者可由专属 case override 固定，不可自动给所有 Advanced 共用。
- 每个 `P` 仅抽一次技术 RNG；缓存具体 `actor_id`、成功/失败 roll、损失与援救，避免重播或加载重新抽签。

### 6.3 失败后的有限救援

如果**坂口亲自执行** P 且首次技术判定失败，先显示短暂失败提示，接着让玩家选择：

1. `自行纠正`：扣 `hp_failed_extra`，完成该节点但留下已发生的 HP 损失。
2. `请求第一助手救援`：仅助手尚有合法介入次数时开放。
3. `请求第二助手救援`：同上。

救援消耗所选助手的一次介入。救援仍使用同一个 P 技术成功率公式，但绝不退还初次已经扣掉的 `precision_base_cost`：

```python
if rescue_success:
    extra_hp = ceil(stage.hp_failed_extra * 0.42) + 2
else:
    extra_hp = stage.hp_failed_extra + 3
```

如果一开始就是助手代为操作且失败，V1 不允许同一节点无限串联第二位医生救援：只结算该助手的失败追加 HP。**救援最多一次；无穷重试绝不允许。** 本项目中的 `reactive` 自动测试策略可能只在预估合适时才主动救援，但真实 UI 可以让玩家自行承担较低成功率的救援风险，不把模拟器的 `p>=0.55` 优化阈值做成硬 Gate。

### 6.4 危机和护士的分工

每台测试术式保留两个 crisis checkpoint（具体见 §7），原型中的机会概率与顺序由稳定 episode seed 决定。

**正确接线顺序：** 优先调用工程已有危机/患者体征 resolver，在危机实际处理时对 Advanced HP **只额外记一次**成本；原有 Stability / Blood Loss / Bleeding / Quality 仍照旧。不能因为普通 resolver 已经计入失血，又把它当新的第二次独立随机危机再触发。

如果工程现有 crisis resolver 暂时不能由 Advanced 调用，允许仅在 Dev Vertical Slice 中启用隔离的 `PLACEHOLDER_ADV_CRISIS_ADAPTER`，其测试规则为：

```python
on_checkpoint_roll: rng.random() < authored_crisis_chance
raw_crisis_hp_cost = rng.randint(8, 13)  # inclusive
circulating_reduction = min(4,
    floor(max(0, primary_circulating.teamwork - 65) / 12) +
    floor(max(0, secondary_circulating.teamwork - 70) / 25))
hp_cost = max(3, raw_crisis_hp_cost - circulating_reduction)
```

此 adapter 只做预留节点、HP 处罚和一小段提示，不代表真实八类危机的最终映射。**在接入现有真实危机 resolver 后禁用这一独立抽取路径**，以免同一危机被算两次。护士只能降低危机损耗，不可从危机菜单选成主刀。

### 6.5 Day 2 结束

- 完成最后一个固定 stage 且没有触发 HP/生理失败 → `day2_result=SUCCESS`。
- HP 到 0，或现有生理系统触发不可继续的失败条件 → `day2_result=FAILED`，立即停止剩余阶段，进入术中结束/术后处理占位画面；**不会出现玩家实际还在开刀，后台却已宣告失败的状态**。
- 失败不会倒退到 Day 1，不自动重开 Day 2，也不立刻再抽一个新患者。Day 3 仍需执行结算（可用失败版占位剧情）。
- 两名实际参与 Grand OR 的助手在 Day 2 按日期获得冷却；患者状态和真正结算标记写入持久化 episode；Surgical Quality Grade、Patient Experience Grade 均通过现有规则计算或明确标记 `PLACEHOLDER_GRADE_ADAPTER`，不能凭最终 HP 随机给 Grade。

## 7. 三台完整测试术式数据（全 stages，可直接录入配置）

这一段是 **V1 输入数据**，而非示意局部片段。`kind` 分类 `F/L/S/P`，`hp_base` 表示所有阶段基础 HP 成本；P 独有 `difficulty/tag/hp_failed_extra`。`crisis_after_stage` 是执行完该阶段后检查一次的 checkpoint。各术式解剖顺序在正式内容生产前还需要按 Procedure Admission Gate 进行医学文献审核；**本次先实现玩法，不把原型表宣称为最终医学稿。**

```yaml
advanced_cases:
  - procedure_id: surgery_open_whipple
    ui_name: 开腹胰十二指肠切除术（Whipple）
    first_patient_id: PLACEHOLDER_ADV_PATIENT_WH01
    stage_count: 13
    precision_count: 6
    baseline_hp_total: 41
    crisis_checkpoints:
      - {after_stage: W05, poc_chance: 0.27}
      - {after_stage: W10, poc_chance: 0.18}
    stages:
      - {id: W01, kind: F, name: 切口与进入, hp_base: 2}
      - {id: W02, kind: L, name: 腹腔探查、建立暴露, hp_base: 2}
      - {id: W03, kind: P, name: 复杂粘连分离, hp_base: 4, difficulty: 88, tag: adhesion, hp_failed_extra: 12}
      - {id: W04, kind: S, name: 主要血管关系与切除路径评估, hp_base: 2}
      - {id: W05, kind: P, name: 门静脉周围组织分离, hp_base: 5, difficulty: 94, tag: vascular, hp_failed_extra: 15}
      - {id: W06, kind: P, name: 胰头深部精细分离, hp_base: 5, difficulty: 96, tag: microdissection, hp_failed_extra: 16}
      - {id: W07, kind: F, name: 标本取出、整理术野, hp_base: 2}
      - {id: W08, kind: P, name: 胰肠重建, hp_base: 6, difficulty: 97, tag: reconstruction, hp_failed_extra: 16}
      - {id: W09, kind: P, name: 胆肠重建, hp_base: 4, difficulty: 92, tag: reconstruction, hp_failed_extra: 13}
      - {id: W10, kind: P, name: 胃肠重建, hp_base: 4, difficulty: 90, tag: reconstruction, hp_failed_extra: 12}
      - {id: W11, kind: S, name: 重建区复核及止血, hp_base: 2}
      - {id: W12, kind: L, name: 最终清点与评估, hp_base: 1}
      - {id: W13, kind: F, name: 关闭, hp_base: 2}

  - procedure_id: surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction
    ui_name: 开腹盆壁肿瘤切除（髂血管重建）
    first_patient_id: PLACEHOLDER_ADV_PATIENT_PV01
    stage_count: 12
    precision_count: 6
    baseline_hp_total: 41
    crisis_checkpoints:
      - {after_stage: P06, poc_chance: 0.29}
      - {after_stage: P09, poc_chance: 0.20}
    stages:
      - {id: P01, kind: F, name: 切口与进入, hp_base: 2}
      - {id: P02, kind: L, name: 盆壁暴露, hp_base: 2}
      - {id: P03, kind: P, name: 广泛盆腔粘连分离, hp_base: 4, difficulty: 90, tag: adhesion, hp_failed_extra: 13}
      - {id: P04, kind: P, name: 神经与输尿管邻近关系辨认, hp_base: 5, difficulty: 95, tag: neural, hp_failed_extra: 15}
      - {id: P05, kind: S, name: 血管处理策略确认, hp_base: 2}
      - {id: P06, kind: P, name: 髂血管周围精细分离, hp_base: 5, difficulty: 96, tag: vascular, hp_failed_extra: 16}
      - {id: P07, kind: P, name: 肿瘤深部边界分离, hp_base: 5, difficulty: 94, tag: microdissection, hp_failed_extra: 15}
      - {id: P08, kind: F, name: 完整切除、整理术野, hp_base: 2}
      - {id: P09, kind: P, name: 髂血管重建, hp_base: 6, difficulty: 98, tag: reconstruction, hp_failed_extra: 18}
      - {id: P10, kind: P, name: 盆壁神经与固定点复核, hp_base: 4, difficulty: 92, tag: pelvic, hp_failed_extra: 13}
      - {id: P11, kind: S, name: 灌注与最终止血评估, hp_base: 2}
      - {id: P12, kind: F, name: 关闭, hp_base: 2}

  - procedure_id: surgery_adv_sleeve_lobectomy
    ui_name: 开胸袖式肺叶切除
    first_patient_id: PLACEHOLDER_ADV_PATIENT_SL01
    stage_count: 11
    precision_count: 5
    baseline_hp_total: 36
    crisis_checkpoints:
      - {after_stage: T07, poc_chance: 0.25}
      - {after_stage: T09, poc_chance: 0.23}
    stages:
      - {id: T01, kind: F, name: 开胸与进入, hp_base: 2}
      - {id: T02, kind: L, name: 肺门区域暴露, hp_base: 2}
      - {id: T03, kind: P, name: 肺动脉分支解剖, hp_base: 5, difficulty: 94, tag: vascular, hp_failed_extra: 15}
      - {id: T04, kind: P, name: 支气管周围精细分离, hp_base: 4, difficulty: 91, tag: thoracic, hp_failed_extra: 12}
      - {id: T05, kind: S, name: 病变切除范围确认, hp_base: 2}
      - {id: T06, kind: P, name: 保留结构与切缘处理, hp_base: 4, difficulty: 93, tag: microdissection, hp_failed_extra: 13}
      - {id: T07, kind: F, name: 完成肺叶切除, hp_base: 2}
      - {id: T08, kind: P, name: 支气管重建吻合, hp_base: 6, difficulty: 97, tag: airway, hp_failed_extra: 17}
      - {id: T09, kind: P, name: 血管重建及复核, hp_base: 5, difficulty: 96, tag: reconstruction, hp_failed_extra: 16}
      - {id: T10, kind: S, name: 通气与灌注复查, hp_base: 2}
      - {id: T11, kind: F, name: 关闭, hp_base: 2}
```

**明确的医学占位：** `surgery_adv_sleeve_lobectomy` 的 canonical 术式描述为“**必要时**肺动脉重建”，而测试数据 T09 当前强制出现“血管重建”；V1 请把这台**测试患者**固定为需要血管重建的 sleeve variant，或者在正式医学稿中改为普通血管复核节点并重新跑平衡。不要把“所有袖式肺叶切除必须血管重建”传播到整个返场池。`[PLACEHOLDER_SLEEVE_VASCULAR_VARIANT]`。

## 8. 返场 Quick Advanced（不能绕开高难风险）

最新设计明确允许首通术式供玩家重复体验，或快速刷取经验和声望。因此：

- `procedure_status == CLEARED` 的随机返场病例提供 `完整手术` 和 `Quick Advanced` 两个按钮；未首通/首次尝试**没有** Quick Advanced。
- Quick Advanced 不再播放 Stage-by-Stage 手动互动；用**同一 Advanced HP/Precision/危机模型**、当前真实团队与标准 `planned` 委托策略实际结算一次。绝不能“Quick=自动成功”。系统仍能在 Quick 中失败，返场失败仍不撤销首通。
- Quick 和 Full **都维持 Day 1 编组（返场无专属剧情）→ Day 2 占用整日 → Day 3 结算**。Quick 只减少玩家阅读/点击，不缩短日期成本、助手冷却，也不跳过患者/Staff 结算。
- Quick Advanced 的奖励使用 `HOSHIMI_FIVE_DIMENSION_IMPLEMENTATION_SPEC.md` 既有 Quick Advanced 规则；不得为 Quick 额外复制一套 Reputation/Leadership 算法，也不得使用普通术式的 `quick_surgery_unlocked` 字段覆盖 Advanced 的“已首通返场”身份。
- **正式 live physiology adapter 接入之前**，Quick 的概率依旧是 HP-only 预览，不可用它覆盖真实 Surgery Runner 全量病理结算；如果两者不能做到同规则，允许在 Dev V1 暂时灰掉 Quick，明确标记 `PLACEHOLDER_QUICK_ADVANCED_FULL_PHYSIOLOGY_BRIDGE`，但必须在最终交付报告列为未完成项，不能宣称快速模式已就绪。

## 9. Day 3 结算与奖励复用合同

只有 Day 3 到达 `settlement_applied=false` 的 episode 才能进行结算，结算成功后立刻写 `settlement_applied=true`，再做可视化结果展示。Day 3 可以失败剧情占位，但不可跳过状态提交。

### 9.1 状态更新优先级

| Day 2 结果 | 本次是否首发 | Procedure 永久状态 | unique clear | 未来返场 |
|---|---|---|---|---|
| SUCCESS | 是 | `CLEARED` | 加 1（Set/去重） | 开启 |
| FAILED | 是 | `FAILED_LOCKED` | 不变 | 永不进入 |
| SUCCESS | 否（已首通返场） | 仍 `CLEARED` | 不变 | 保留 |
| FAILED | 否（已首通返场） | 仍 `CLEARED` | 不变 | 保留 |

成功是“做完本台且通过现有必需生理检查”，不以 `final_hp>0` 一项代替原 Surgery 成功条件。第一次失败锁定指**真正开始 Day 2 后得到手术失败结果**，不是打开病例/准备编组/窗口取消，也不是引擎崩溃。

### 9.2 正式数值结算

- **Surgery XP：** 通过项目现有 Surgery XP resolver、术式 difficulty/training ceiling、已确认的队伍平均分段 bonus 处理；不要新加一条简单“高级手术 +固定 Surgery Level”。如果当前缺 Advanced training ceiling，在 case registry 填 `PLACEHOLDER_SURGERY_TRAINING_CEILING`，交付时标为平衡待核，开发版本可沿用既有 Advanced difficulty 分类安全默认。
- **Leadership XP：** canonical Advanced case base `8`，再通过 Grand OR 六名可培养岗位的技能平均判断 Strong≥86 `×0.5`、Normal70–<86 `×1.0`、Developing<70 `×1.5`；不要额外添加 Grand OR ×1.5 规模奖励。
- **Grand OR 六人平均分：** `average(FirstAssistant.surgery, SecondAssistant.surgery, PrimaryScrub.instrument_handling, SecondaryScrub.instrument_handling, PrimaryCirculating.teamwork, SecondaryCirculating.teamwork)`；麻醉不计入，角色不可重复占位。
- **Staff 训练：** Advanced Grand OR 的岗位训练 credit 为 `×2`，使用 canonical 分段的实际技能成长与 90+ 上限；不会因为辅助医生在某个 P 节点被叫过一次便额外刷第二次 credit。
- **Professional Reputation：** 适用既有 Advanced 成功奖励 `+40`，以及 Advanced tier soft 480/hard 600 的折扣/上限逻辑；普通临床失败默认 `+0`，不能凭一次 HP 耗尽自动发明重大失职负声望。Quick Advanced 采用同样结算。
- **Quality / Patient Experience：** 复用现有双评价；不将它们合并进 HP，也不能凭最后 HP 或随机数发明 S 评价。
- **失败时 Surgery XP / Leadership XP：** 使用现有失败结算 resolver；若没有安全对应接口，V1 demo 可以明确显示“失败，训练经验待正式规则接线”，暂不给新系统另行发奖。不可猜测固定负值或反复累计。
- 奖励只有 Day 3 一次性完成；重开 Day 3、读档继续、Quick 回放、同一周再次打开板，都不能重复发放。

### 9.3 Quest flag

`unique_advanced_clears` 必须从完整 `CLEARED` 的 procedure ID 集合计算或由 Set 同步维护。达到 5 和 10 时分别设置前置 flag；**不能**把“当前三台 POC 全通=解锁宫园熏”做成测试捷径，也不能用同一术式 Quick 十次打开 Ray。

## 10. 推荐持久化结构（字段为语义合同，工程中须映射真实名称）

下面可以作为独立 `AdvancedReferralSave` / `AdvancedSurgerySession` 的草案；不得把同名字段复制进项目已经存在的另一套存档管理器。真实路径/类型先按 §2 侦测。

```yaml
advanced_referral_save_version: 1
advanced_procedure_status:
  surgery_open_whipple: AVAILABLE
  surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction: AVAILABLE
  surgery_adv_sleeve_lobectomy: AVAILABLE
unique_advanced_cleared_ids: []
first_time_pending_ids: [surgery_open_whipple, surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction, surgery_adv_sleeve_lobectomy]
week_key_last_generated: null
weekly_replay_instance_ids: []
case_instances: {}                    # 每例 stable ID、procedure、patient、first/replay、week、状态
advanced_assistant_cooldowns: {}      # staff canonical ID -> next eligible calendar date
kaori_advanced_prerequisite_met: false
ray_legendary_prerequisite_met: false
active_advanced_episode_id: null

advanced_episode_example:
  episode_id: ADV_EPISODE_001
  case_instance_id: ADV_CASE_001
  procedure_id: surgery_open_whipple
  patient_id: PLACEHOLDER_ADV_PATIENT_WH01
  is_first_attempt: true
  run_mode: FULL                      # FULL / QUICK_ADVANCED
  phase: DAY2_ACTIVE                 # SCHEDULED / DAY2_ACTIVE / AWAITING_DAY3 / SETTLED
  actual_day1_date: null
  actual_day2_date: null
  actual_day3_date: null
  roster:
    primary_surgeon_id: PLAYER_SAKAGUCHI  # 映射工程现有 canonical ID
    first_assistant_id: STAFF_CANONICAL_ID_A
    second_assistant_id: STAFF_CANONICAL_ID_B
    primary_scrub_id: STAFF_CANONICAL_ID_C
    secondary_scrub_id: STAFF_CANONICAL_ID_D
    primary_circulating_id: STAFF_CANONICAL_ID_E
    secondary_circulating_id: STAFF_CANONICAL_ID_F
    anesthesia_id: PLACEHOLDER_ANESTHESIA_BINDING
  staff_skill_snapshot: {}            # 进入 Day2 时的角色数值，防止中途变化
  surgery_rng_seed: 123456            # 演示值；每 episode 真正生成一次
  case_variant_id: standard
  resolved_random_choices: {}        # 键例如 advanced:W08:precision；已抽结果缓存
  operative_reserve_hp: 100
  current_stage_id: W01
  completed_stage_ids: []
  stage_hp_applied_ids: []            # 防止阶段重复扣 HP
  crisis_resolved_checkpoint_ids: [] # 防止危机重复触发/结算
  assistant_uses_by_staff_id: {}      # 不用角色显示名做 key
  day2_result: null                  # SUCCESS / FAILED，未结束为 null
  cooldown_committed: false
  settlement_applied: false
  settlement_transaction_id: null
```

保存契约：

1. 首发 `AVAILABLE→IN_PROGRESS` 发生在 Day 1 **确认接受**时；Day 1 关闭窗口不改变状态。
2. 真实 `surgery_rng_seed/case_variant_id` 在本次 episode 建立时初始化并持久化；`resolved_random_choices` 记录每一已发生的 P 成功判定、救援、变体和 checkpoint 决定。不得仅靠 seed 在加载后“按当前数组顺序再抽一次”。
3. 进入/提交某 stage 时，以稳定 `(episode_id, stage_id, action_index)` 防重复处理；已扣 HP 的 stage 不能因为屏幕重入再次扣。
4. Day 2 的失败或成功结果在场景退出前保存；冷却只提交一次。中途关闭 app 不算“手术失败”，恢复已完成节点，若既有引擎无法恢复中途手术则至少提供**恢复到 Day 2 开始时的相同 seed/roster 的安全 checkpoint**，不能自动标记 `FAILED_LOCKED`。
5. Day 3 的奖励使用 idempotency transaction，避免半途中断后 HP/状态/XP/声望不一致；对旧存档缺失 Advanced 字段作非破坏性初始化，不更改 Ordinary 历史记录。
6. 正常玩家允许加载 Day 1 以前的旧存档重新尝试。这与“本周目首次失败锁定”不矛盾；但**同一个已经存下失败结果的存档**不可刷新病例清单绕过锁定。

## 11. UI、人物与占位 VN 演出合同

### 11.1 独立四个屏幕

1. `Advanced Referral Board`：三个首发槽 + 最多三个本周返场槽（有多少显示多少），病例类型与状态、选择病例。
2. `Advanced Day1`：左侧/上方病例卡，专业难点 tags、Grand OR 编组、风险估算；确认按钮前展示第一次失败警告。
3. `Advanced OR`：沿用既有 Surgery 的场景能力，新增 HP 条、当前 P 演员选择、救援分支、第一/第二助手剩余次数；全麻患者无需在手术中反复清醒对白。
4. `Advanced Day3`：患者占位查房/失败后处理、最终 HP、P 成功/失败、团队贡献、职业奖励、该术式首通/返场/永久锁定、返回正常游戏。

### 11.2 占位脚本和说话人

示例 Day 1 文案仅起流程验证作用，可被正式文学稿直接替换：

```text
【高级转诊中心。外院病例资料送达。】
坂口：「是一台很复杂的手术。先把所有需要的医生和护士安排好。」
【显示病例的主要精细难点与推荐专科。】
【进入 Grand OR 编组。】
【编组完成后显示 HP 层预计完成率。】
坂口：「每一步都得有人负责。准备好了，就按这个计划来。」
【第一次挑战时显示永久锁定风险警告并请求确认。】
```

Day 3 成功/失败均用简单、非露骨的文本提示和正常病房画面即可。角色发言时若使用真实演员，姓名框、canonical 角色和当前立绘必须一致；不要让 `第一助手`、`巡回护士` 等泛称直接取代真实人物姓名。尚无立绘或真人物的 placeholder 患者可以只显示无名旁白，绝不能错用其他具名人物立绘。

**视觉资源不存在不是 blocker。** 最低使用既有手术室背景 + 文字状态面板；无需为测试版本新生成患者 CG、器官层或术野美术。

## 12. 可实现的集成接口与失败保护

Codex 应根据工程真实接口映射下列**语义方法**，名称不是强制脚本 API：

```text
AdvancedReferralBoard.list_available_cases(game_date)
AdvancedReferralBoard.generate_weekly_replays_if_needed(week_key)
AdvancedReferralBoard.can_accept(case_id, current_date)
AdvancedReferralBoard.accept_case(case_id, selected_team)

AdvancedTeamBuilder.get_eligible_staff(role, scheduled_day2)
AdvancedTeamBuilder.validate_unique_and_qualified_roster(team)
AdvancedTeamBuilder.check_assistant_cooldown(staff_id, day2)
AdvancedRiskEstimator.estimate_hp_clear_probability(case, roster, standard_policy)

AdvancedSurgerySession.start_from_committed_case(case_instance_id)
AdvancedSurgerySession.advance_stage_once(stage_id, player_choice)
AdvancedPrecisionResolver.available_actors_for_stage(stage, uses, roster)
AdvancedPrecisionResolver.resolve_first_attempt_once(actor_id, stage_id)
AdvancedPrecisionResolver.resolve_one_rescue_once(actor_id, stage_id)
AdvancedSurgerySession.finish_day2_once(result)

AdvancedSettlementBridge.apply_day3_once(episode_id)
AdvancedSaveBridge.serialize_and_resume(session_state)
```

关键工程边界：

- **只在 `mode == ADVANCED_REFERRAL` 启动 HP/Precision/assistant charges。** 不把 HP 插到所有普通 Surgery 患者对象，也不允许普通手术突然发生新的技术判定随机失败。
- 尽可能使用一个共享的底层生理、危机、评级、XP/声望 resolver；Advanced Controller 的独立性指编排和新玩法状态，不是重复造第二份所有普通 Surgery 规则。
- 若复用旧 Stage renderer 存在数据格式限制，可建 Advanced 专用 UI adapter，把 `F/L/S/P` 映射到旧 UI；不要为了 P 节点改写所有 Ordinary stage 数据。
- 一次性的异常或事件变体必须通过现有 episode `resolved_random_choices` 或等价可持久化表，且每次手术的 preview RNG 与 true RNG 必须完全隔离。
- 若发现真实 Staff 没有 `specialty_tags` 字段，可以加一张**可配置的 Advanced 专科映射表**，以 canonical Staff ID 为 key；禁止对所有名字硬编码条件判断，禁止悄悄修改原角色 `skills.surgery`。
- 如果发现原有生理/危机 resolver 无法安全调用，应先在隔离的 Dev Advanced Slice 使用明确标记的测试 adapter，写清“live integration pending”；不可因此改写普通危机实现。
- 本稿的规范不授权擅自改变普通手术的历时、资源、Patient Experience 等已锁定机制。

## 13. 必须执行的 QA / 最低可接受证据

### 13.1 数据与概率校验

1. 注册恰好三个测试 Advanced ID；与 master inventory 一致，不复制旧 `surgery_open_whipple` 为新 ID，不意外归入 Ordinary pool。
2. Whipple/Pelvic/Sleeve 的固定节点依次为 `13/12/11`，P 节点为 `6/6/5`；各个 `stage_id` 在 case 内唯一，HP baseline `41/41/36`。
3. P 成功率在 0.08–0.985 之间；Scrub 加成总量不超过 5pp，护士不能选为 P 执行者。
4. 一名普通助手仅一次；Surgery 90 但专科不匹配时，第二次按钮不可用；Surgery 90 且标签匹配时最多第二次；万能专家可任选 P tag 第二次；失败扣介入次数。
5. 自己 P 失败时，测试“自己纠正、第一助手救援成功、第一助手救援失败、助手额度耗尽”四条分支；没有无限救援，初次 HP 消耗不能退还。
6. HP=1 时受到 2 点扣费立刻失败且 stage 不继续；HP 不能为负显示，不得从 HP 0 继续关腹。
7. 变体 25% 只掷一次，在 Stage02 后扣额外4HP，高难节点按约定只加3 difficulty；读档不会重抽。
8. 两个 crisis checkpoint 各最多触发一次，已有真实危机 + 测试 adapter 不能同时抽取同一危机；`circulating_reduction <=4`。

### 13.2 时间、人员与持久化

9. Day 1 从玩家**真实时间向前**结算，不管玩家晚于标准 09:00 接受，都不能倒拨时钟。
10. 未来三阶段与固定剧情冲突时不能接受案件，已刷出的候选仍保留；既有日历/星期规则不被改写。
11. 两名助手不能是同一 Staff；同一护士不能同时占器械/巡回或两个相同位置；不满足权限的医护不能编入。
12. Day2 实际参与的助手（不管有没有被委托 P）进入 14 **calendar day** cooldown：Day2+13 不可再次上台，Day2+14 可；普通手术岗位不受限。
13. Day1 取消不记首败；Day2 结果失败才形成首发 `FAILED_LOCKED`，且通过 Day3 一次性提交。失败后周一不会重新抽到该未通关术式。
14. 首发通关后返场，新随机患者与首发具名患者不同；首通数只加一次；返场失败仍 `CLEARED`，可以再返场。
15. 对同一 `episode` 在 P 判定前/后、援救前/后、危机前/后和 Day2 结果后分别进行 Save/Load，HP、演员、次数、危机和状态完全相同，不额外 roll。
16. Day3 结算中断再读取，同一 episode 的 XP、Reputation、cooldown、unique clear 不重复更新。
17. 当清零 HP 与既有 Stability 失败同时发生时只结算**一个**失败事件，不出现双倍失败惩罚。
18. 日历每周一刷新仅生成一次本周返场，UI 反复打开及读档不刷新；活跃三日病例不被刷新删除。
19. 以 stub state 模拟第5与第10个**不同** Advanced procedure 首通分别设置 Kaori/Ray flag；同术式重复10次绝不触发。
20. 完整/Quick 返场均花费三日、计算冷却及真实成功/失败；Quick 未首通不可见，也不能自动判成功。

### 13.3 演出与 Ordinary 回归测试

21. Day1 首发与返场都能编组；只有首次患者播放首发占位 VN；返场不显示先前具名患者画面。
22. 多名医护轮流说话时姓名框与真实 canonical 立绘一致；手术室护士/巡回护士身份不会相互串图。
23. 连续测试一台普通手术，确认 option-level deterministic 规则、已有血损/Visibility/Stability、Quick 资格、Patient Experience / Quality、普通患者随机池完全不变。
24. 在没有患者 CG/正式麻醉医生立绘/完整 Filler 的环境下仍能完整 Day1→Day3，且开发占位内容显式可识别，不产生找不到资源异常。

### 13.4 HP-only 模拟基准（只校验模型，不是最终玩家胜率）

可用随附 `hoshimi_advanced_surgery_balance_sim.py` 复现数学行为；若移植到 GDScript 测试器，采用固定团队 fixtures、`planned`、25,000 次/配置，期望约值：

| 测试团队，不写入真实 Staff | Whipple | Pelvic | Sleeve |
|---|---:|---:|---:|
| 坂口 Surgery82 + 一般助手 | 47% | 35% | 65% |
| 坂口 Surgery82 + 97 万能强援 | 86% | 72% | 95% |
| 坂口 Surgery88 + 均衡团队 | 88% | 78% | 93% |
| 坂口 Surgery93 + 顶级团队 | 99% | 98% | 100% |

统计允许 Monte Carlo 误差，并必须和 Python 口径一致：该基准只测 **HP+P+测试危机**，不包含真实既有 physiology fail。因此生产游戏加入原有危机/体征后，不要求最终全系统胜率强行等于这张表。若纯 HP-only 结果差异超过约 2–3pp，请检查整形取整、救援扣费、护士技能和随机变体。

## 14. Placeholder Registry / 允许未知而不擅自脑补的项目

### 14.1 不阻止 vertical slice 的内容占位

| 标记 | 含义 | Dev Slice 安全行为 |
|---|---|---|
| `PLACEHOLDER_ADV_PATIENT_*` | 三台首次正式患者的人设、名字、年龄细节 | 使用固定成年女性测试患者对象及文字/剪影，不创建错误正式角色 ID |
| `PLACEHOLDER_ADV_*_DAY1` | 首次入院短 VN、术前会议、术后感谢 | 少量功能对白/旁白，明确为占位；后续可逐项替换 |
| `PLACEHOLDER_OR_ART` | 高级术野差分、CG、专用背景 | 复用既有 OR 背景和文本卡，不强依赖新图片 |
| `PLACEHOLDER_ANESTHESIA_BINDING` | 麻醉科 canonical ID / outfit / Portrait | 开发模式非数值占位；正式版本仍需要合法全麻配置 |
| `PLACEHOLDER_WEEKLY_REPLAY_WEIGHTS` | 一周 1/2/3 次返场的分布 | Dev 用等权抽，周一固定 seed/记录结果；未来平衡可换权重 |
| `PLACEHOLDER_SURGEON_SPECIALTY_REGISTRY` | 哪些现有外科医生擅长哪些 P tag / 万能专家标记 | 在不篡改原 Staff 数值的独立表里配置，缺项时只给普通一次介入 |
| `PLACEHOLDER_SURGERY_TRAINING_CEILING` | 三台术式正式的 XP ceiling 与额外教学差分 | 以现有 Advanced resolver/训练上限安全回退；需平衡前签字 |
| `PLACEHOLDER_SLEEVE_VASCULAR_VARIANT` | sleeve T09 是否需要肺动脉重建 | POC 首发患者固定“必要重建”变体，正式返场按医学审核扩展 |
| `PLACEHOLDER_S_STRATEGY_STANDARD_ONLY` | 本文尚未逐条编写三个术式的专属旧式策略选项 | 允许开发 POC 只有 standard 确认；交付需报告缺失，不等同于完整正式手术内容 |
| `PLACEHOLDER_GRADE_ADAPTER` | Advanced 的 Quality / Patient Experience grade 衔接 | 复用现有 Grade；否则 Dev 只展示未结算占位，不随机发 Grade |

### 14.2 必须由 Codex 查工程并明确报告的接线事实

| 标记 | 必须核对；不可凭空捏造 |
|---|---|
| `PLACEHOLDER_CALENDAR_NEXT_OPERATING_DAY` | 真实星期规则、非工作日、三日事件全程避让、时钟结算函数 |
| `PLACEHOLDER_RUNTIME_PROCEDURE_REGISTRY` | 实际被加载的术式数据源；尤其 `surgery_open_whipple` 不得注册两次 |
| `PLACEHOLDER_EXISTING_VITALS_CRISIS_BRIDGE` | 现有 Stability/Blood Loss/Visibility/意外引擎如何注入新 P/HP 结果并防止重复危机 |
| `PLACEHOLDER_SAVE_RESUME_BRIDGE` | episode RNG、进行中手术、Day3 事务如何持久化；不能创建与旧 Save 并行而不保存的假结构 |
| `PLACEHOLDER_SETTLEMENT_BRIDGE` | 当前 Surgery XP、Leadership、Staff XP、Reputation、Grade 实际入口 |
| `PLACEHOLDER_CANONICAL_STAFF_IDS_AND_SKILLS` | 真实医护人物、角色映射、岗位权限、技能值、可出勤性；禁止使用模拟 fixture 当正式值 |
| `PLACEHOLDER_QUICK_ADVANCED_FULL_PHYSIOLOGY_BRIDGE` | Quick 是否和 Full 完全复用同一真实结算概率/体征，而非 HP-only 模拟替身 |

以上“查工程”任务**不等于必须向作者追问才能开始**。若实际代码显示某接口不存在或存在与本文矛盾的签字级行为，Codex 应优先完成隔离 Dev Slice，清楚列出该阻塞和最小可行建议；绝不擅自扩大为普通 Surgery 重构。

## 15. Codex 交付报告必须包含

请按以下顺序交付：

1. **实现与未实现清单**：Dev 完整可玩、生产可用、placeholder、真正阻塞四类分别列出，不把演示模式说成正式全功能。
2. 实际修改的 Godot 脚本、场景、数据与 Save 文件路径，说明为什么这些是 authoritative runtime source。
3. 三台 procedure IDs / Stage 数 / P 数 / HP 数据注册成功的自动校验。
4. Day1 team/risk preview、Day2 Full/P/rescue/crisis/HP失败、Day3 settlement 的逐步试玩步骤；包含一台首次成功、一台首次失败锁定、一台返场失败案例。
5. 一张真实医护岗位/技能映射表；哪些角色具备第二次介入的哪些 tag，以及 Day2+14 的日历测试结果。
6. Save/Load 防重复结算、危机不重复、普通 Surgery 不回归、固定剧情不冲突的测试结果。
7. 数值偏差报告：实际 HP-only 与 Python 对照，整合现有生理之后的真实胜率另列，不混为一谈。
8. 所有残余 placeholder、与当前工程结构冲突之处、建议下一轮需要作者确认的最多 5 个 P0/P1 问题。

### 最终验收标准

**以能够在 Godot 中不依赖正式患者/剧情 CG，真实地选择 Grand OR 团队、完成一台高级手术、看到 HP 与精细操作的结果、在 Day3 正确结算，并在下一周见到符合首通/失败规则的返场板为准。**

这一步完成以后，再审核正式患者、文献核对过的 Stage medical wording、每台手术的 S 策略三档、Filler 和美术，扩展余下 Advanced 术式。不要在 V1 开工时一并生产全部 20 台或 Kaori/Ray 长剧情。




