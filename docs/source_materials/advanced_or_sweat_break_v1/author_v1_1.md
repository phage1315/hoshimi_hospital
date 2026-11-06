# Hoshimi Hospital — Advanced OR Sweat Break / 擦汗微互动 — Codex-Ready V1.1

> **状态：Codex 实装交接规格（内容完成，代码尚未实施）。** 本版本覆盖同文件 V1 的「75 分钟冷却／总量上限／优先尚未擦过的岗位」旧提案，三者均**已废弃**。  
> **范围：**高级手术 Day 2 的阶段间隙氛围事件，独立于 Advanced OR Team Dialogue V2 正常节点对白。首试点可用佩特拉，验证后适用于既有全部 Advanced；不修改现有各术式的 stage、HP、精密操作、Strategy 或既有 VN。  
> **目标：**长时间手术中自然呈现团队成员互相照顾；不增加 HP、Surgery、Leadership、疲劳、物资、角色成长、奖励或存档字段。  
> **日期：**2026-11-03。中文原文 20 组逐句锁定；本版本新增完整英语对照、事件模型、调度算法与验收条件。

## 0. 权限、来源与实施前置

- **用户已确定：**16 个候选阈值；每个候选独立 30% 概率；无全局冷却、无每台手术演出总量上限；仅安全节点间演出；同一间隙至多一组，其他成功候选直接丢弃，不排队。
- **策划层决定：**下文规定一次性阈值消费、无菌边界、角色有效性、演出位置与选择算法；这些是 Codex 的行为合同，并非已存在的 Godot API。
- **实施前必须审计真实代码：**Advanced Runner 的累计模拟耗时、阶段生命期及结算顺序、V2 队伍对白播放器、Grand OR roster 的合法岗位、自动播放/快进/跳过/记录、多语言与演出专用随机源。不得猜测 API 或假设 `sweat_break` 已被解析。
- 原 `HOSHIMI_ADVANCED_OR_TEAM_DIALOGUE_V2_SPEC.md` 的每阶段 3–5 句专业交流保持不变。这个事件只在阶段之间增补 2–3 句。

## 1. 时间阈值与概率合同

**每个候选阈值独立进行一次 30% 判定，绝非到点必播。** 下表时间均为**本次手术的累计模拟经过时间**，不使用现实秒表，亦不直接用术式 `duration_minutes` 代替已经执行的实际耗时。

| 被擦汗的岗位 | 累计手术时间达到时（分钟） | 换算小时 | 提供变体 |
|---|---|---|---:|
| 主刀 `lead_surgeon` | 120、300、480、600 | 2、5、8、10 | 4 |
| 第一助手 `assistant_1` | 150、360、510、660 | 2.5、6、8.5、11 | 4 |
| 第二助手 `assistant_2` | 180、420、540、630 | 3、7、9、10.5 | 4 |
| 第一器械 `scrub_primary` | 210、450 | 3.5、7.5 | 4 |
| 第二器械 `scrub_secondary` | 270、570 | 4.5、9.5 | 4 |

### 1.1 强制执行规则

1. **阈值跨越：**读取 Runner 已确认的旧/新累计模拟分钟 `old_elapsed`, `new_elapsed`。两者分别是**上一安全阶段边界**与**当前阶段全部操作、危机和救援耗时结算完**的累计时间；满足 `old_elapsed < threshold <= new_elapsed` 时才形成候选。若 Runner 在阶段中分批增加耗时，必须累积到同一次转场统一处理，不能只看最后一个微小的时间增量。小于 0、倒退、重复刷新或重进屏幕均不得反复形成候选。浮点时间按实际比较，不以四舍五入后的 UI 分钟判断。
2. **逐个抽签：**所有本次跨越的合法候选阈值各判定一次 `< 0.30`；同角色在不同时间点也重新独立判定。不存在「本台手术已被擦过就降权／跳过」的规则。
3. **只在安全阶段缝隙播：**本阶段业务逻辑及 P/S 结果、助手救援、危机处理、`after_resolution` 全部结束，且确实存在下一正常操作阶段时，才能开始事件。不得在用户选择中、计时中、术野操作中、失败/成功结算中或另一组队伍对白尚在播放时插入。
4. **单间隙最多一组：**若一次时间推进跨越数个阈值，逐个独立抽签后，从所有中签且实际编组/接台允许的候选中**均匀选一组**演出；未被选中的阈值消费后立即丢弃。不进入下一阶段的待播队列。
5. **不设全局冷却、不设总上限：**两次擦汗可能发生在相邻两个阶段间隙；只能通过自然时间阈值、30% 概率和每间隙一组的条件约束。不能增加隐式 75 分钟、每人限次、`ceil(duration/120)` 等限制。
6. **终局与不安全区间直接丢弃：**阶段已结束整台手术、失败锁定、团队岗位缺席、关键牵拉/清点没有可行安全交接、转场不可用时，相关候选仍消费但不播放；不要延迟到 Day 3、下一台手术或下一次返场。
7. **会话内恰好一次：**每个 `threshold_event_id` 每场手术最多参与一次抽签；窗口重绘、重入、语言切换、P 失败后恢复、播放跳过都不可重抽。只在已存在的本次 Runner 运行态登记一次性标记；高级转诊长期存档不得增加这类状态。
8. **既有游戏随机结果不变：**事件抽签、候选选一与对白变体都使用现有 UI/氛围专用随机机制，或用本次手术稳定身份与事件 ID 派生的确定性表现散列；**不能消费决定 P、危机、生理或奖励的 RNG 流**。若没有独立表现随机机制，Codex 应本地建立非持久化演出采样器，并用对比测试验证原游戏结果不漂移。

### 1.2 碰撞概率与试玩预期

- 在独立 16 次抽签且无阶段碰撞的理想上界下，数学期望为 `16 × 0.30 = 4.8` 组；同一间隙多项中签会只显示一项，因此**实际演出均值只会更低**。
- 8 小时手术如恰好在 480 分钟结束，最后的 480 分钟阈值没有后续阶段可演，通常至多前 9 个阈值可参加；其理想期望为 2.7 组。
- 10 小时手术恰好在 600 分钟结束，600 分钟不播，之前 13 个阈值理想期望 3.9 组。11.5 小时手术若持续到 690 分钟且时序允许，则可覆盖全部 16 个，理想期望 4.8 组。
- 以上只是**按理想化用时计算的观感估计**；真实事件由 Runner 实际耗时与是否存在安全间隙决定。不要把预测组数写成保底目标。

### 1.3 稳定事件标识与目标人选

按 `SWB_{role}_{threshold_minutes}` 唯一标识，例如 `SWB_lead_surgeon_120`、`SWB_assistant_1_150`。同一阈值从 `unseen` 一次性转为 `consumed`，无论是否中签、无论最后是否实际显示。角色按本台手术**实际编组**绑定，不写死人名。`lead_surgeon` 是坂口。`scrub_secondary` 若无此岗位，跳过其候选；助手若未编组则跳过对应阈值（正常 Grand OR 应由既有编组规则控制）。

## 2. 无菌边界与演出动作

- 由实际编组的**巡回护士**协助擦汗；演出层可把 `circulating_primary` 设为默认擦汗者，若其忙碌且 `circulating_secondary` 在场，可选择后者。不能让未编组的岗位突然发声。
- 被擦汗者先暂停手上任务，向**术野外侧**转头或退半步。接触额头的擦拭用品从此视作非无菌，不能放回手术器械台。巡回护士不能碰无菌手套、手术袍前胸、无菌台和开放术野。
- 助手若正在牵拉、吸引或保持固定，应先由**另一位已刷手的团队成员承接**，或者等该动作已安全结束；巡回护士绝不跨进无菌区替她扶器械。
- 器械护士若正在递器械或清点，应先由另一名器械护士接手无菌台。没有安全接手条件，就**跳过本次候选**，不要停下重要操作硬演出。
- 可以做一个小型非关键的「转脸→巡回轻拭额头→回到术野」动画；没有新 CG 时纯对白即可。不能把这种生活化小动作表现成消毒术野或有医学治疗意义的操作。
- 现实分工依据：美国陆军 OR 教材和手术室护理手册均指出，非刷手的巡回人员负责协助无菌团队，擦汗时刷手人员须转离无菌术野。此处属于游戏化概括，不用于实际临床指令。

**内容演出约定：**对白中的「转头」「接手牵拉」「副器械接台」均假设已在一个安全的非关键间隙完成，不得临时中断正在进行的真实 Runner 操作。内容里的巡回护士是擦汗执行者，其他人仍可以提醒或请求。第一/第二器械护士本人也能接受巡回擦汗，但不会用戴手套的无菌手替同伴擦脸。

### 2.1 Codex 的安全筛选规则

- 主刀、两名助手以及第一/第二器械岗位必须由现有 Grand OR 编组解析为真实在场成员；禁止因为内容文本中的 `[第一助手]` 等称呼自动生造角色。
- 擦汗执行者优先 `circulating_primary`，若该岗位不可用但 `circulating_secondary` 实际在场则后者接替；二者都不存在则该事件不播放。**两名巡回同时在场也只选其中一人**，一组内保持同一执行者。
- 一组文本中出现 `assistant_2`、`scrub_secondary` 等辅助发言岗位时，必须确保全组所有岗位都存在。缺失时可以换同一目标岗位的另一组**不引用缺失岗位**的变体，找不到就跳过该候选，不准临时改说话人身份。
- 对器械护士进行擦汗时，若内容要求另一名器械护士「接台」，该被引用岗位必须在场；如果真实 Runner 有显式关键操作/交接不可暂停标记，应以其为准，安全条件不满足则整组略过。不要求引擎模拟真实无菌器械交接。
- 医护相对位置、头部动作与非无菌擦拭均只属于对白或可选小动画，不建立新的手术阶段，不改变患者体征、时间、成败或库存。

医学流程参考：
- 美国陆军手术室无菌技术原则：<https://brooksidepress.org/Introduction_to_the_Operating_Room/lessons/lesson-1-orientation/section-4-aseptic-technique-and-infection-control/>
- 手术室护理手册「During Operation」：<https://www.operatingroomissues.org/wp-content/uploads/2023/07/Manual-in-Operating-Room-Nursing-2011.pdf>

## 3. 中文对白变体（每岗位四组，共20组）

约定：每组 2–3 条，`[巡回]` 表示运行时选用**实际在场**的 `circulating_primary` 或 `circulating_secondary`；其余角色均绑定当前 Grand OR roster。若该角色不在场，整组不合格，需换组或不播放。

### A. 主刀坂口 / `lead_surgeon`

**LEAD_01｜巡回主动察觉｜3句**

1. [巡回]「坂口医生，额头已经有汗了。先向外侧转一下脸。」
2. [主刀]「嗯，麻烦你。手套现在可没法碰脸。」
3. [巡回]「好了。术野这边我没有碰到，可以继续。」

**LEAD_02｜主刀主动请求｜2句**

1. [主刀]「巡回，给我擦一下汗。刚才一直没空抬头。」
2. [巡回]「请稍微退开、把头转过来。……好了。」

**LEAD_03｜助手先发现｜3句**

1. [第二助手]「坂口，额角那滴汗快掉下来了。先停一下，我看着这里。」
2. [主刀]「你倒是比我先发现。巡回，拜托。」
3. [巡回]「头向右转一点。……擦好了。」

**LEAD_04｜轻微幽默｜3句**

1. [主刀]「我一直以为是灯太亮，现在看来是我真的在出汗。」
2. [巡回]「先别研究原因，脸转过来，我处理一下。」
3. [主刀]「……看来这件事还是得听你的。」

### B. 第一助手 / `assistant_1`

**ASSIST1_01｜交接牵拉｜3句**

1. [第一助手]「这边牵开先请第二助手接一下，我要擦个汗。」
2. [第二助手]「接住了，术野位置不变。」
3. [巡回]「请转向外侧。……好了，辛苦。」

**ASSIST1_02｜巡回注意到｜3句**

1. [巡回]「第一助手，额头的汗快流到眉毛了，需要帮忙吗？」
2. [第一助手]「需要，不过等我先把手里的吸引交给第二助手。」
3. [巡回]「好。现在可以了，转过来一点。……擦好了。」

**ASSIST1_03｜短暂停顿｜2句**

1. [第一助手]「下一段开始前，巡回，帮我擦一下额头。」
2. [巡回]「好的，先远离术野半步。……擦好了。」

**ASSIST1_04｜主刀体贴｜3句**

1. [主刀]「第一助手，你先把脸上的汗处理一下。这一段我等你。」
2. [第一助手]「好，我正想说。巡回，麻烦了。」
3. [巡回]「不用急，先转过来。……好了。」

### C. 第二助手 / `assistant_2`

**ASSIST2_01｜牵开器交接｜3句**

1. [第二助手]「第一助手，帮我接一下这支牵开器，我眼前有汗了。」
2. [第一助手]「接好了，放心转过去。」
3. [巡回]「擦好了。你回来时先看清牵开器的位置。」

**ASSIST2_02｜被同事提醒｜3句**

1. [第一助手]「你额头那滴汗已经挂了半天了，先处理一下。」
2. [第二助手]「我还以为能坚持到下一阶段。巡回，麻烦你。」
3. [巡回]「往外侧转头。……好，回去吧。」

**ASSIST2_03｜安静的互相照顾｜3句**

1. [巡回]「第二助手，需要擦汗吗？你可以等这段牵拉结束再过来。」
2. [第二助手]「正好结束了。谢谢，麻烦帮我一下。」
3. [巡回]「往外侧转一点。……好了。」

**ASSIST2_04｜有点不服气｜3句**

1. [第二助手]「我没有累，就是额头这点汗有些碍事。」
2. [巡回]「我没有问你累不累。把脸转过来就行。」
3. [第二助手]「……明白。谢谢。」

### D. 第一器械护士 / `scrub_primary`

**SCRUB1_01｜副器械接台｜3句**

1. [第一器械]「副器械，帮我盯一下无菌台。我需要擦汗。」
2. [第二器械]「台面和针数我接着，你可以转过去。」
3. [巡回]「这边。……擦好了，可以接回。」

**SCRUB1_02｜刚递完关键器械｜3句**

1. [第一器械]「下一组器械已经交接完，巡回，能帮我擦一下额头吗？」
2. [巡回]「可以。先离开无菌台一点，头往我这边转。」
3. [第二器械]「我继续盯着台面，不会漏下一件。」

**SCRUB1_03｜巡回预先注意到｜3句**

1. [巡回]「第一器械，你帽沿下面开始出汗了。等这组针数核对完，我帮你擦。」
2. [第一器械]「好，这组已经核对完，可以了。」
3. [巡回]「先离开台面一点。……擦好了。」

**SCRUB1_04｜简短而熟练｜3句**

1. [第一器械]「副器械先接台。巡回，我需要十秒钟。」
2. [巡回]「过来，脸向外。……好了。」
3. [第一器械]「谢谢。下一组缝线我来准备。」

### E. 第二器械护士 / `scrub_secondary`

**SCRUB2_01｜补充器械之后｜3句**

1. [第二器械]「这批备用器械已经排好，第一器械，台面先交还给你。」
2. [第一器械]「收到，你去擦一下汗吧。」
3. [巡回]「头转过来一点。……好了。」

**SCRUB2_02｜等手头任务完成｜3句**

1. [巡回]「第二器械，你额头出汗了，我等你做完这组清点。」
2. [第二器械]「还有最后两件……好了。第一器械帮我接台。」
3. [巡回]「请转向外侧，我帮你擦一下。……好了。」

**SCRUB2_03｜藏不住的疲惫｜3句**

1. [第二器械]「我还以为戴着手术帽，就不容易出汗了。」
2. [第一器械]「那是手术帽，不是吸汗毛巾。台面我接着。」
3. [巡回]「你先过来。……好了，下次别等到汗流下来。」

**SCRUB2_04｜主动短暂停顿｜2句**

1. [第二器械]「巡回，等我把备用线放好，帮我擦一下汗。」
2. [巡回]「可以。第一器械已经接手了，你往外转一点。……好了。」

## 4. 不应出现的失真台词与演出

- 禁止 `[scrub_primary]` 拿无菌纱布替主刀直接擦脸，随后不换无菌手套继续递器械。
- 禁止巡回护士伸手越过开放胸腔或腹腔去擦对面助手的额头。
- 禁止第一助手在仍单独承担关键血管牵拉时突然松手转脸；必须等安全暂停、由另一无菌成员接手或整个事件略过。
- 禁止“擦汗提高稳定度／奖励 Leadership”或因为未擦汗减少 HP。这是一段医护关系的**氛围**，不是额外微管理。
- 禁止在所有 16 个时间点强制播出，或者在 `after_resolution` 已有 3–5 句后又连续弹三组擦汗对白。
- 不得向这段对白加入患者在全麻中的反应，不应固定提患者名字、职业和某名医护的私事。

## 5. Codex 数据与播放器合同（建议结构，最终字段以项目代码审计为准）

### 5.1 内容注册

建议新增一个与 `dialogue/<procedure_id>.json` 解耦的**可选全局高级手术氛围内容资源**，例如 `advanced_or_ambient/sweat_break_v1.json`；实际文件目录和注册入口以真实 repo 为准。必须保证尚未接入此内容的旧手术照旧运行。内容格式建议：

```json
{
  "schema_version": "advanced_or_ambient_sweat_v1",
  "event_probability": 0.30,
  "max_groups_per_stage_transition": 1,
  "thresholds_minutes": {
    "lead_surgeon": [120, 300, 480, 600],
    "assistant_1": [150, 360, 510, 660],
    "assistant_2": [180, 420, 540, 630],
    "scrub_primary": [210, 450],
    "scrub_secondary": [270, 570]
  },
  "variants": {
    "lead_surgeon": [
      {"id": "LEAD_01", "lines": [
        {"id": "LEAD_01_01", "speaker_role": "circulating_wiper", "text": "坂口医生，额头已经有汗了。先向外侧转一下脸。", "text_en": "Doctor Sakaguchi, there's sweat on your forehead. Please turn your face away from the field."}
      ]}
    ]
  }
}
```

**注意：示例只展示字段形态，并非完整可加载 JSON。**Codex 应按第 3 节原文与第 6 节逐行对照，填入完整 20 组；不允许只把一行示例上线或把半组当成完整变体。

- `circulating_wiper` 是**内容源占位符**，不是新的 roster speaker_role：内容载入/播放前解析为实际存在的 `circulating_primary` 或 `circulating_secondary`，再交给既有合法 speaker 校验和姓名/头像映射。
- `speaker_role` 唯一合法来源是既有角色绑定规范。本文的 `[主刀]`→`lead_surgeon`、`[第一助手]`→`assistant_1`、`[第二助手]`→`assistant_2`、`[第一器械]`→`scrub_primary`、`[第二器械]`→`scrub_secondary`、`[巡回]`→`circulating_wiper`。
- 每组必须有 2–3 行、在组内按数组顺序连续播放；`variant_id` 全局唯一，行 `id` 在整个资源中唯一；`text` 与 `text_en` 均非空。角色与原文标点不能被随意改写。
- 系统应允许未声明擦汗资源时安静忽略（feature absent）；当高级手术完成 Runner 初始化、现有 roster 成功绑定后才启用，不影响普通手术。

### 5.2 调度算法 / 参考伪代码

以下是**行为伪代码**，不是可直接粘贴的 GDScript。Codex 应把它接在真实 Runner 的**阶段时间结算和安全转场**上，避免在渲染函数里抽签。

```text
on_advanced_stage_time_committed(previous_safe_boundary_time, current_settled_time, stage_transition):
    if not stage_transition.is_one_time_committed: return
    crossed = every scheduled threshold with previous_safe_boundary_time < t <= current_settled_time
    for candidate in crossed, ascending by threshold_time and id:
        if candidate.id already consumed in this operation session: continue
        mark candidate.id consumed BEFORE any RNG call
        if candidate.recipient_role not present: continue
        if presentation_random(candidate.id, "roll") < 0.30:
            winners.add(candidate)

    if winners empty: return
    if transition ends operation or terminal outcome: return
    if not after_resolution_completed_or_skipped: schedule at this transition's safe gate
    at safe gate (after all crisis/rescue resolution, before next before_action):
        if operation ended / gate not safe / roster invalid: discard all winners; return
        eligible = [w for w in winners if a safe full variant is available]
        if eligible empty: return
        chosen = uniform_pick(eligible, presentation_random("collision"))
        variant = pick_variant_for(chosen.recipient_role, session_local_history)
        resolve circulating_wiper to a valid circulating roster member
        play 2–3 lines as one group; append to existing Day2 dialogue log
        discard all other winners; no queue into later stages
```

**排序只用于可复现的枚举，不赋予较早阈值优先权。** `presentation_random` 应在候选 ID/案例的表现性上下文中产生相互独立的抽样；如复用通用 PRNG，需与手术结果 RNG 完全隔离。`session_local_history` 仅负责同一操作中的「不连续复用同一变体」及防重复播放，不持久化到高级转诊记录。

**关键实现区别：**先记录本阶段一次性时间结算的所有候选，再在当前转场的安全门执行播出。危机/救援期间可延迟到**同一次转场**恢复安全后播放，若转场最终失败或取消则直接丢弃，不能跨下一个操作节点积压。多人同中签时每个阈值抽签仍为 30%，但**可见演出概率**因单间隙限制而低于 30%。

### 5.3 演出、日志与多语言

1. 照常演出 Stage V2 `before_action` → 玩家操作 F/L/S/P → 原有 `precision_failed`/救援/危机 → `after_resolution`。
2. 若存在本次安全转场中签组，单独演出 `sweat_break` 2–3 句；下一阶段才开始。**不计入该阶段 3–5 句常规队伍对白。**
3. 复用现有 Day 2 对话面板、自动播放、快进、整组跳过、对白历史与语言显示。不能弹出额外 F/L/S/P 选择卡片或“擦汗”按钮。整组快进/跳过只跳演出，不影响既有阶段流程。
4. 不增加手术耗时：演出播放实际阅读时间不计入 Runner 的既有累计手术分钟字段；不产生额外自动麻醉状态更新、危机抽签或 HP 变化。
5. 保持本次实际编组人员姓名/头像一致；如游戏的对话记录采用角色 ID 而非岗位 ID，先使用现有 roster 解析。语种切换后显示批准的另一语言，不重复判定触发。

## 6. 英文逐句对照（对应第 3 节中文原稿；行序锁定）

格式：`variant_id` 后的数字为第 1/2/3 句；英文无需保留中文书名号，但不可添加原文没有的情节。角色与中文第 3 节逐行一一对应。第 3 节中文是权威文本，转换进 JSON 时**禁止修改任何一个字或原有说话人**。

| 变体 | English line 1 | English line 2 | English line 3（如有） |
|---|---|---|---|
| `LEAD_01` | Dr. Sakaguchi, you're sweating on your forehead. Please turn your face away from the field for a moment. | Mm, thank you. I can't exactly touch my face with these gloves. | All done. I haven't touched the sterile field. You can continue. |
| `LEAD_02` | Circulator, could you wipe my forehead? I haven't had a moment to look up. | Step back a little and turn toward me. ... All done. | — |
| `LEAD_03` | Sakaguchi, that drop by your temple is about to fall. Pause a second; I've got this area. | You spotted it before I did. Circulator, please. | Turn a little to your right. ... There, all done. |
| `LEAD_04` | I thought the lights were just too bright. Apparently I'm actually sweating. | Let's not investigate why. Turn your face this way and I'll take care of it. | ...Looks like I should listen to you on this one. |
| `ASSIST1_01` | Second assistant, could you take over the retraction here? I need my forehead wiped. | I've got it. The exposure won't change. | Turn away from the field, please. ... There. Thanks for your hard work. |
| `ASSIST1_02` | First assistant, that sweat is about to reach your eyebrows. Need a hand? | Yes, but let me pass the suction to the second assistant first. | Of course. You're clear now—turn this way a little. ... All done. |
| `ASSIST1_03` | Before we start the next part, circulator, please wipe my forehead. | Of course. Step half a pace away from the field first. ... All done. | — |
| `ASSIST1_04` | First assistant, take a moment to get that sweat off your face. I'll wait. | All right. I was just about to ask. Circulator, please. | No rush. Turn this way first. ... Done. |
| `ASSIST2_01` | First assistant, please take this retractor for a moment. Sweat is getting in my eyes. | I've got it. Go ahead and turn away. | All done. Check the retractor's position before you resume. |
| `ASSIST2_02` | That drop's been hanging on your forehead for ages. Better deal with it. | I thought I could make it to the next stage. Circulator, could you help? | Turn away from the field. ... There, you can go back. |
| `ASSIST2_03` | Second assistant, need your forehead wiped? We can wait until you've finished retracting. | I've just finished, actually. Thanks—I'd appreciate it. | Turn outward a little. ... All done. |
| `ASSIST2_04` | I'm not tired. It's just that the sweat on my forehead is distracting. | I didn't ask if you were tired. Just turn your face this way. | ...Understood. Thanks. |
| `SCRUB1_01` | Second scrub, watch the sterile table for me. I need my forehead wiped. | I've got the table and the needle count. You can turn away. | Over here. ... Done. You can take over again. |
| `SCRUB1_02` | The next instrument set is handed over. Circulator, could you wipe my forehead? | Certainly. Step away from the sterile table and turn toward me. | I'll keep an eye on the table. We won't miss the next instrument. |
| `SCRUB1_03` | First scrub, you're starting to sweat under the edge of your cap. I'll help once you've finished this needle count. | All right, the count's complete. I'm ready. | Step away from the table a little. ... Done. |
| `SCRUB1_04` | Second scrub, take the table. Circulator, I need ten seconds. | Over here. Face away from the field. ... All done. | Thank you. I'll prepare the next sutures. |
| `SCRUB2_01` | The spare instruments are arranged. First scrub, the table's back in your hands. | Got it. Go get your forehead wiped. | Turn your head this way a little. ... All done. |
| `SCRUB2_02` | Second scrub, you're sweating. I'll wait until you've finished that count. | Two items left... Done. First scrub, take the table for me. | Turn away from the field, please. Let me wipe that. ... All done. |
| `SCRUB2_03` | I thought wearing a surgical cap would keep me from sweating so much. | It's a surgical cap, not a sweat towel. I've got the table. | Come over here. ... Done. Next time don't wait until it's running down your face. |
| `SCRUB2_04` | Circulator, once I've set down the spare sutures, could you wipe my forehead? | Sure. The first scrub has taken over; turn outward a little. ... All done. | — |

## 7. 测试矩阵（必须可自动验证）

| 测试 | 输入/场景 | 必须结果 |
|---|---|---|
| 边界跨越 | 模拟分钟 `119→121`；`120→120`；`145→165` | 分别触发一次主刀120候选、无新候选、一次第一助手150候选 |
| 大步耗时 | `119→240`，同时跨越 120/150/180/210 | 各候选只被抽签一次；至多演一组；没被选中的不留队列 |
| 均匀选中 | 多候选均中签 | 不按最早阈值或固定岗位优先；仅一个演出，其他被消费 |
| 30% 分布 | 大量不同病例/运行会话 + 固定候选 | 每个候选抽签频率接近 30%；无额外冷却和总上限；演出量因碰撞可低于抽签量 |
| 终局过滤 | 结束步骤刚跨过阈值；HP 终止；首次失败 | 不擦汗、不挂起、不插入 Day 3；原结算流程不变 |
| P/S/危机保护 | 正在操作 P、等待 S 决策、助手救援/危机中 | 没有中途插话；仅当前次转场在完成结算后可演；失败即丢弃 |
| 时间重入 | UI 重绘，重新进当前 stage，自动播放/跳过 | 同一阈值不重抽；同一组不重复追加历史 |
| 队伍缺席 | 缺 `scrub_secondary` 或巡回岗位 | 未编组岗位绝不出现；合法变体筛选/跳过；没有虚构头像 |
| 语言与内容 | 中英各 20 组；每组 2–3 行 | 所有 speaker 有绑定；全部逐行匹配第 3、6 节；无缺译和乱序 |
| 结果 RNG 隔离 | 同一初始游戏状态，功能开/关、演出跳过/正常 | P、危机、HP、奖励、助手冷却及最终结果一致 |
| 与 V2 共存 | Petra、Izumi、Misa、旧四术式；首发和 CLEARED 返场 | 原专业对白仍 3–5 行/阶段；擦汗仅独立安全间隙发生；旧存档可用 |

## 8. 交付、非目标与合并指令

**本文件给 Codex 的工作：**审计真实 Godot 调度/加载器 → 增加向后兼容的可选高级手术氛围事件资源 → 根据第 3、6 节做全量双语 20 组数据 → 复用 V2 播放器及当前编组映射 → 加入上述测试 → 首先在佩特拉 Runner 试玩验证。若实现支持所有高级手术，再为既有高级术式启用，不重写任何原有节点对白。

**不得擅自改动：**F/L/S/P、HP、Precision、战略选择、危机概率、双助手机制、14 天助手冷却、首次失败 FAILED_LOCKED、CLEARED、逐月 FIFO、随机返场、Day1/Day3 剧情、常规 Advanced OR Team Dialogue V2 台词、普通手术系统、长期存档 schema。

**不要求新美术。** 有可用动画则后续单独授权，第一版直接复用现有手术界面和对话面板即可。

**验证报告必须说明：**实际修改的代码/资源路径，16 个阈值+20 组变体的验证数，关键安全转场与多候选行为的测试结果，旧存档和旧手术回归状态；列出任何真实 Runner API 与本语义合同的差异，不能悄悄改变已确认的概率和频率。

**状态声明：**本文件是 Codex-Ready 的文本与语义合同；**尚未修改 Godot 工程，未实装、未做运行时平衡测试**。V1 中的冷却、上限和「优先尚未擦过」机制都不再适用。
