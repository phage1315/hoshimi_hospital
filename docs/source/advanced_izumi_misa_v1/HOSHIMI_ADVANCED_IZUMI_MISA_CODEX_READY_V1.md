# Hoshimi Hospital / 星见医院
## 伊兹米·柯蒂斯＋美纱：两台新增高级转诊手术 Codex-Ready 数据 V1

> **状态：** 可供 Codex 开始工程接入的剧情、流程和阶段数据；不是已经实装或经 Godot 实测的证明。  
> **日期：** 2026-11-01。  
> **范围：** Advanced Regular `release_order=5` / `6`，首次具名患者 Day 1、Day 2 纯 Runner、Day 3，返场及测试。  
> **姓名已确认（2026-11-01）：** 作者明确确认第六名为 **「美纱」**，与最新 canonical 解锁文档一致；此前口述「美织」为称呼偏差，**不再构成姓名阻塞**。美纱的完整姓名、原作出处和角色参考资料仍待进一步核对。

## 0. Codex 先读什么、实现什么

按优先级核对以下已有文件，任何更新后的实机代码与本稿冲突时先提出冲突，不得盲目覆盖：

1. `HOSHIMI_ADVANCED_REFERRAL_UNLOCK_REPLAY_RULES_CODEX_READY_CN_V1.md`：最新解锁与返场（优先覆盖旧稿的 Quick、1–3 随机返场和首三台固定排序）。
2. `HOSHIMI_ADVANCED_SURGERY_STANDALONE_CODEX_READY_V1.md`：F/L/S/P、HP、助手次数、危机、14 天冷却、Day 3 结算；保留与第 1 项不冲突的部分。
3. `HOSHIMI_SURGERY_PROCEDURE_POOL_MASTER_LIST_V0_1.md`：伊兹米第 22 台术式的身份与医学边界。**注意此总表暂记 22 个 Advanced，而最新解锁规则已经批准美纱新增第 23 台；后者为最新决定。** 本稿不擅自修改总表。
4. `HOSHIMI_ADVANCED_REFERRAL_TUTORIAL_CHISATO.md`、目前真实仓库的四台可运行 Advanced、实际 Grand OR / Advanced Runner / Case Registry / Save 代码。
5. `WRITING_GPT_CODEX_SCRIPT_GUIDELINES.md`：所有剧情对白逐字呈现，动作作为可见旁白实现，不得由 Codex 自行润色。

**本次交付目标**：让新术式与已有高级池复用相同入口、队伍、HP/Precision、真实生理状态、麻醉、危机、稳定病例事实的持久化、Day 3 结算；新病例不引入新引擎。先审计真实 registry 中已经使用的 stage 字段、tag、事件 ID、patient ID、图像资源名，再将下述语义字段映射到现有格式。**禁止直接把本文 YAML 当作未经审计的 Godot 原生 schema，禁止猜造人物 ID。** 同包提供可直接读取的 `procedures_additions.json`、`stories/`、`dialogue/` 和 `art_manifest.json`；以最新内容清单规范为准。

### 0.1 两台病例固定身份

| 属性 | 第五台 | 第六台 |
|---|---|---|
| `release_order` | **5** | **6** |
| `procedure_id` | `surgery_adv_complex_abdominal_reconstruction` | `surgery_adv_open_descending_thoracic_aortic_replacement` **拟注册 ID** |
| UI 名称 | 开腹复杂腹腔黏连松解及多脏器修复重建术 | 开胸降主动脉瘤切除及人工血管置换术 |
| 首次患者 | **伊兹米·柯蒂斯（Izumi Curtis）** | **美纱**；原作出处、全名、本人资料未在所核对 canonical 文档锁定，勿自行编造 |
| 分类 | `ADVANCED_REGULAR` | `ADVANCED_REGULAR` |
| Day 2 | 全麻；Grand OR；12 stages / 6 P | 全麻；Grand OR；12 stages / 6 P |
| 首通后 | 允许合适的随机成年患者返场 | 允许合适的随机成年患者返场 |
| 关系路线 | 伊兹米**不是攻略对象**；保留其丈夫、婚姻及原作关系 | 不作任何未经确认的可攻略或 Staff-as-Patient 断言 |

**两台均不占**千束 Tutorial、宫园薰三连 Quest、四种 Legendary；不覆盖已存在的 `surgery_adv_open_taaa_repair`。美纱这台局限于**胸段降主动脉**，不进行开腹、不重建肾／腹腔干／肠系膜分支。不得因为场景题材相似自动重用 `surgery_adv_cabg_valve_combined` 的心脏瓣膜路径。

### 0.2 引擎内语义（引用现有 V1，不另外发明）

```yaml
advanced_regular_additions:
  - release_order: 5
    procedure_id: surgery_adv_complex_abdominal_reconstruction
    first_patient_display_name: 伊兹米·柯蒂斯
    case_kind: ADVANCED_REGULAR
    day2_anesthesia: general
    stage_count: 12
    precision_count: 6
  - release_order: 6
    procedure_id: surgery_adv_open_descending_thoracic_aortic_replacement
    procedure_id_status: PROPOSED_CONFIRM_REGISTRY
    first_patient_display_name: 美纱
    first_patient_identity_status: DISPLAY_NAME_CONFIRMED_SOURCE_PENDING
    case_kind: ADVANCED_REGULAR
    day2_anesthesia: general
    stage_count: 12
    precision_count: 6
```

- Day 1 挂起／编组 → **次日** Day 2 实际动刀 → **第三日** Day 3 唯一结算；避让固定剧情日和不可操作日期。
- Day 1 只在真正接受病例时占位；取消／退出不消耗首发机会。第一次 Day 2 真正失败则这台术式本周目 `FAILED_LOCKED`；成功则 `CLEARED`。
- 返场：每周一从已首通的普通 Advanced 术式池 **有放回抽两例**，随机成年患者且各有不同 `case_instance_id`；**不得 Quick Advanced**。成功或失败不改变已经完成的首通。
- `HP=100` 与已有 Stability / Blood Loss / Bleeding 等同时存在；`F/L/S` 每阶段扣一次 authored `hp_base`；`P` 用已实现的成功率/委托/救援规则；危机复用原有危机 resolver，不重复抽一个独立随机危机。**患者全麻，没有术中清醒患者对白。**
- 这里的 `difficulty` 与 `hp_failed_extra` 是建议初版**游戏平衡占位**，不是医学成功率，也未经蒙特卡洛／Godot 实测。验证后可调，不改节点顺序及术式身份。
- `P` 节点的 `tag` 先核对实际 `specialty_tags` 与已有术式 tag；必要时通过现有映射兼容。护士可以提供器械与巡回支持，不参与外科 P 代打。
- 每台首次挑战开始前仍显示永久失败风险警告。临床质量、Surgery XP、Leadership、Reputation、助手冷却使用既有 resolver，不为这两位患者创建特殊额外奖励。
- **Day 3 失败演出统一复用现有 `dialogue/day3_failed.json`：坂口 → 第一助手 → 第二助手 → 坂口共四句团队对白。不为任何首发角色新增独立失败病房对白；Day 3 角色专属剧情只在成功时播放。**
- 在长期存档的高级转诊事实中，只保留病例、预约、结果等**稳定事实**；不得新增 stage、HP、随机种子、助手使用次数、剧情游标或选项路径等字段。术中步骤与抽样结果按实际 Runner 会话管理，不能以“避免重抽”为由扩写持久化协议。

---

## 1. 伊兹米·柯蒂斯／复杂腹腔修复

### 1.1 患者事实与医学边界

**人物身份**：成年伊兹米，《钢之炼金术师》；自称家庭主妇，强悍、直爽、受不了被当成玻璃人，但并非没有疼痛与恐惧。与丈夫席格的关系保留；坂口与她不存在恋爱或成人支线。

**星见 AU 影像要点**：既往人体炼成留下**真实缺失的部分内脏**；幸存消化道和周围组织陈旧损伤严重，局部狭窄/牵拉、反复腹痛、可能的消化道出血和依赖残存侧支的血供异常。常见普通返场病史则是旧腹伤、多次开腹手术或炎症后黏连，**绝不能给所有随机患者套用人体炼成**。

**术式目标**：解除导致症状的黏连与梗阻性牵拉；保留脆弱但能用的肠管及侧支；局部修补有临床问题的消化道组织、改善/确认血供和吻合张力。不是肿瘤根治性切除，也不让已经缺失的器官再长回来；不设定为“任何黏连都要割干净”。

**本次首发病例变体锁定**：确有一处需要目标性肠壁修补/短段重建的旧损伤；不在 Day 2 临时随机决定完全不同的切除范围。`complex_abdomen_izumi_first` 作为**叙述性 case variant 名称**，Codex 应映射/注册到实际变体系统，不用该字符串猜造病理脚本。对于正常随机返场，可逐步提供 `adhesive_obstruction`, `post_traumatic_repair` 等医学合理变体；V1 可先让返场共享普通安全病例数据、不重复人体炼成独白。

### 1.2 Day 1 首次专属剧情：《比病历还难解释》

**地点：星见医院，高级转诊诊察室；随后转入术前讨论与 Grand OR 编组。**

1. 旁白：坂口把超声、CT 影像和一份折痕很多的转诊资料摊在桌面上。伊兹米坐在对面，一只手按着腹部，表情很不耐烦。
2. 坂口：「这些部位都受过很严重的损伤。……以前出过车祸？」
3. 伊兹米：「没有。」
4. 坂口：「也不像一次普通的开腹手术留下的。」
5. 伊兹米：「人体炼成。」
6. 坂口：「……什么？」
7. 伊兹米：「我知道这话很难相信。别追问了，反正已经过去很多年。」
8. 旁白：坂口看了她一眼，又把目光转回影像。
9. 坂口：「好。我不追问。但要确认现在哪些器官还在、哪些位置有血流，以及为什么反复疼痛。」
10. 伊兹米：「这才像医生该问的。」
11. 坂口：「我们不会把你整个腹腔里的黏连都拆开。很多地方现在的血供，可能反而靠着这些旧关系维持。」
12. 伊兹米：「所以你准备把我打开，仔仔细细地挑出那些能碰的地方？」
13. 坂口：「对。会是一台很长的手术。」
14. 伊兹米：「……啧。我以前总嫌学生们一遇上点事就哆嗦。现在轮到我了。」
15. 坂口：「会全身麻醉。手术中你不必自己撑着。」
16. 伊兹米：「我当然知道全麻是什么。可我明天睁开眼睛时，肚子已经被你们折腾过十几个小时了吧？」
17. 坂口：「是。所以今天把问题问清楚。」
18. 伊兹米：「那就最后一个问题。你会把我的身体修好到哪一步？」
19. 坂口：「把能保留的组织修好，让你少疼、少出血、能重新正常过日子。失去的部分，我没办法变出来。」
20. 旁白：伊兹米低头看着腹部，过了片刻才抬起头。
21. 伊兹米：「……行。那就把我剩下的这些东西，给我好好照顾着。」
22. 旁白：坂口合上影像报告，手术计划及需要重点保护的结构显示在病历卡上。镜头切至高级手术团队编组界面。

**Grand OR 推荐界面提示**（非剧情对白）：复杂黏连分离、残存肠壁修复、肠系膜侧支血供、修复张力与灌注复查。重点匹配 `adhesion`, `microdissection`, `vascular`, `reconstruction`。

**人物演出约束**：如未来增设御堂参与此案的戏份，应放入 Day 1 术前会诊，或 Day 3 查房；**不能插到 Day 2 互动手术中**。本版不要求御堂固定出场，避免依赖未知角色可用性。

### 1.3 Day 2 术式固定阶段数据

下表及 YAML 共同构成完整阶段顺序；所有 `stage_id` 在此术式内稳定且唯一，禁止在后续美术更新时重排已记录存档中的 stage IDs。

```yaml
procedure_id: surgery_adv_complex_abdominal_reconstruction
stage_count: 12
precision_count: 6
operative_reserve_hp_start: 100
anesthesia: general
initial_patient_position: supine
baseline_hp_total: 40
crisis_checkpoints:
  - {after_stage: I06, poc_chance: 0.26, theme: delicate_mesenteric_bleeding}
  - {after_stage: I09, poc_chance: 0.20, theme: bowel_perfusion_concern}
stages:
  - id: I01
    kind: F
    name: 旧瘢痕评估与谨慎开腹
    hp_base: 2
    prompt: "既往腹部组织形态异常。沿计划入路逐层进入，不盲目向深部推进。"
    transition_text: "器械护士递上精细分离器械；助手维持切口边缘的浅层暴露。"
  - id: I02
    kind: L
    name: 幸存器官与黏连区地图
    hp_base: 2
    prompt: "清点可识别的残存肠段、固定点与可见侧支，标记症状相关区域。"
    transition_text: "团队确认：部分结构已经缺失，现存器官的位置与通常解剖并不一致。"
  - id: I03
    kind: P
    name: 腹壁与肠袢致密黏连的安全分离
    hp_base: 4
    difficulty: 91
    tag: adhesion
    hp_failed_extra: 13
    prompt: "几层旧瘢痕与肠浆膜贴在一起；必须先找到真实的可分离平面。"
    transition_text: "助手保护脆弱肠壁，器械护士及时更换精细分离器械。"
  - id: I04
    kind: S
    name: 目标性松解范围判断
    hp_base: 2
    prompt: "有些黏连造成牵拉；另一些却承载着重要侧支。你要怎样界定处理范围？"
    preferred_strategy: "只处理有症状且已辨清血供的牵拉点，其余黏连保留"
    risky_strategy: "为求视野宽阔，将能看到的黏连一概分开"
    transition_text: "团队重新确认了必须保留的侧支组织，避免为了漂亮的术野付出血供代价。"
  - id: I05
    kind: P
    name: 脆弱肠壁周围的精细松解
    hp_base: 5
    difficulty: 94
    tag: microdissection
    hp_failed_extra: 15
    prompt: "一段陈旧伤肠壁与邻近组织无法直接牵开，要沿可辨认平面逐步释放。"
    transition_text: "巡回护士记录已确认的器官结构；主器械护士维持吸引与剪切器械供应。"
  - id: I06
    kind: P
    name: 肠系膜侧支血管辨认与保护
    hp_base: 5
    difficulty: 97
    tag: vascular
    hp_failed_extra: 17
    prompt: "几条细小而关键的侧支穿过瘢痕，必须先辨清血流方向再继续松解。"
    transition_text: "助手在局部维持稳定的暴露，避免牵拉改变尚未确认的灌注。"
  - id: I07
    kind: F
    name: 暴露症状相关旧伤段
    hp_base: 2
    prompt: "完成限定范围松解，显露确实需要修复的薄弱肠段；其他幸存组织保持原位。"
    transition_text: "需要修复的局部区域终于清晰，团队没有扩大不必要的切除范围。"
  - id: I08
    kind: P
    name: 残存消化道局部修补与重建
    hp_base: 5
    difficulty: 96
    tag: reconstruction
    hp_failed_extra: 16
    prompt: "旧损伤处组织薄、张力不均，需以能保留器官功能的方式完成局部修补。"
    transition_text: "器械护士备齐精细缝合材料；助手只负责保持边缘对合条件。"
  - id: I09
    kind: P
    name: 局部供血路径松解与稳定化
    hp_base: 5
    difficulty: 98
    tag: vascular
    hp_failed_extra: 18
    prompt: "修补后的组织仍依赖侧支。必须在解除牵拉的同时保持稳定灌注。"
    transition_text: "团队确认没有牺牲其他存活器官的血供来换取这一处修复。"
  - id: I10
    kind: P
    name: 修补部位张力与连续性复核
    hp_base: 4
    difficulty: 95
    tag: reconstruction
    hp_failed_extra: 15
    prompt: "对合处没有明显出血，但还须排除牵拉、狭窄或潜在渗漏。"
    transition_text: "助手调整暴露角度，主刀复核修补线和肠段自然走向。"
  - id: I11
    kind: S
    name: 血供、渗漏与止血总复核
    hp_base: 2
    prompt: "关闭前还有哪些项目必须逐一确认？"
    preferred_strategy: "完成血流及局部修补完整性检查，再复核止血与器械清点"
    risky_strategy: "只确认术野没有活动出血就结束"
    transition_text: "巡回护士与器械护士复核计数，手术记录标注幸存器官的保留与修复情况。"
  - id: I12
    kind: F
    name: 分层关闭与术后交接
    hp_base: 2
    prompt: "确认无需继续扩大手术范围，按现有关闭流程完成分层关闭。"
    transition_text: "团队向麻醉与恢复室交接复杂腹部修复后的观察重点。"
```

**玩法检查**：`I03/I05/I06/I08/I09/I10` 恰好六个 P；两处 S 保留已有的可见选择流程，**`preferred_strategy/risky_strategy` 是编剧语义提示，不是现成 effects 字段**。Codex 查实际 S resolver 后，将合理/风险选项映射到真实稳定性、失血、时间或质量效应；不能随意编一个 `quality+5` 伪效果。

**失败提示句**（技术反馈，只有对应节点失败时出现，不是新的长剧情）：

- `I03/I05`：助手：「这层组织比预计更脆，先稳住暴露，别急着往下拉。」
- `I06/I09`：助手：「局部灌注正在变化。先确认这些侧支究竟供应哪一段。」
- `I08/I10`：器械护士：「修补材料已经备好。需要重新整理对合边缘吗？」

### 1.4 Day 3 首次成功：《还是自己的身体》

**地点：星见医院，术后病房。伊兹米已清醒，仍在恢复。**

1. 旁白：伊兹米醒着，正对着床边的水杯发呆。看见坂口进来，她立刻坐直了一点。
2. 伊兹米：「好了？那台听起来没完没了的手术。」
3. 坂口：「完成了。主要牵拉点处理了，薄弱的消化道组织也修复了。血供检查结果稳定。」
4. 伊兹米：「那我缺的东西呢？」
5. 坂口：「缺的还是缺的。我不会拿这个骗你。」
6. 旁白：伊兹米沉默片刻，突然笑了一声。
7. 伊兹米：「哼。我就知道。要是你能凭空给我长出几个器官，我倒要问问你是不是炼金术师了。」
8. 坂口：「接下来还要循序恢复饮食，别逞强。」
9. 伊兹米：「知道了。我丈夫还等着我回去呢。」
10. 坂口：「那就先把这段恢复期过好。」
11. 伊兹米：「……谢了，医生。以后再有人问我怎么弄伤的，我还是会说人体炼成。」
12. 坂口：「……我会在病历里用比较容易让同事理解的写法。」
13. 旁白：她笑着摆摆手，重新靠回枕头。进入现有 Day 3 成功结算画面。

### 1.5 Day 3 失败：复用现有团队结算

按最新 `advanced_surgery_content_checklist_v1.md`，不制作伊兹米专属失败病房戏。运行时调用 `dialogue/day3_failed.json` 中的四句通用团队对白，然后按现有失败锁定规则结算；**此处没有额外可录入的患者台词**。

---

## 2. 美纱／开胸降主动脉瘤切除及人工血管置换

### 2.1 患者与术式边界

**角色资料状态**：「美纱」已获作者明确确认，术式与人物名称一致；尚未找到其正式原作标题、全名与 Character Bible。**下列人物对白是可实装的临时首发版本，不带未经确认的童年、职业或家庭设定**；作者之后给出原作锚点时须优先核对。

**星见 AU 本次病案**：成人患者，局限于胸段降主动脉的复杂动脉瘤，适合开放左开胸置换；属于需保护远端灌注与胸段脊髓供血的手术病例。不累及主动脉弓重建或腹部内脏分支；本例选用左心旁路／远端灌注和需要处理重要肋间动脉的变体。人工血管替代病变段，**不**冒充处理胸腹主动脉瘤的 `surgery_adv_open_taaa_repair`。

**Gameplay identity**：与伊兹米的“留下多少、修多少”相反，这台真正必须**切除/置换指定病变血管段**；决定性压力在建立近远端控制、维持下半身灌注、人工血管吻合、判断重要肋间动脉保护与分阶段恢复血流。

### 2.2 Day 1 首次专属剧情：《明天要换掉一段大动脉》

**地点：星见医院，高级转诊诊察室。桌上是胸部 CTA 和一张显示主动脉走行的示意图。**

1. 旁白：美纱先看示意图，再看坂口，像是想确认图里那段隆起的血管真的在自己身体里。
2. 美纱：「你们准备……把这一段切掉？」
3. 坂口：「切除病变段，用人工血管完成重建。」
4. 美纱：「我知道。转诊医生也说过。可是你指着图说出来的时候，怎么听着比诊断书还吓人。」
5. 坂口：「最难的部分不仅是缝上人工血管，还要保护置换过程中下半身和脊髓的血流。」
6. 美纱：「所以它不只是‘把旧的换成新的’。」
7. 坂口：「对。要建立远端灌注，确认需要保留的分支，再逐段完成重建。」
8. 美纱：「我一直以为病人听不懂手术细节会害怕。现在听懂一点，好像更害怕了。」
9. 坂口：「这是全麻手术。手术中你不会需要自己承受这些操作。」
10. 美纱：「那我睡一觉醒来，这么重要的一根血管就有一段不是原装的了？」
11. 坂口：「可以这样理解。我们会检查置换后的通畅情况，确认状态稳定再结束。」
12. 美纱：「……真了不起。也真荒唐。我还没决定明天早餐想吃什么，你们已经排好了要在我胸口里做的全部事情。」
13. 坂口：「明天术前会按麻醉要求禁食。今天还有什么担心的，尽管说。」
14. 美纱：「……能不能至少让我见见明天要在手术台旁站一整天的那些人？」
15. 坂口：「可以。马上就要开术前会议。」
16. 美纱：「那我可得记住你们每个人的脸。等我醒了，好知道该向谁抱怨。」
17. 旁白：美纱努力笑了笑，把影像报告转正推回给坂口。镜头切到专科难点提示及 Grand OR 编组界面。

**推荐界面提示**：胸主动脉近远端控制、左心旁路与远端灌注、人工血管吻合、肋间动脉/脊髓供血保护、复灌时血流动力学变化；重视 `thoracic` / `vascular` / `reconstruction` 标签及护士危机应对能力。

### 2.3 Day 2 术式固定阶段数据

```yaml
procedure_id: surgery_adv_open_descending_thoracic_aortic_replacement
procedure_id_status: PROPOSED_CONFIRM_REGISTRY
stage_count: 12
precision_count: 6
operative_reserve_hp_start: 100
anesthesia: general
initial_patient_position: right_lateral_decubitus
approach: left_thoracotomy
baseline_hp_total: 44
crisis_checkpoints:
  - {after_stage: M05, poc_chance: 0.29, theme: hemodynamic_instability_during_clamp}
  - {after_stage: M09, poc_chance: 0.23, theme: perfusion_or_bleeding_check}
stages:
  - id: M01
    kind: F
    name: 左开胸与进入
    hp_base: 2
    prompt: "患者在全麻与已确认体位下，沿既定左胸入路进入。"
    transition_text: "器械护士准备开胸器械；麻醉团队维持必要监测与通气。"
  - id: M02
    kind: L
    name: 胸段降主动脉与邻近结构辨认
    hp_base: 2
    prompt: "显露病变主动脉段，确认与肺、食管及重要分支的关系。"
    transition_text: "助手保护周围组织并维持视野，避免将病变血管本身作为粗暴牵拉点。"
  - id: M03
    kind: P
    name: 近远端安全控制区精细分离
    hp_base: 5
    difficulty: 93
    tag: thoracic
    hp_failed_extra: 15
    prompt: "瘤体两端需要安全控制；解剖时还要避开邻近神经和食管。"
    transition_text: "助手稳定暴露，器械护士准备血管控制与替代器械。"
  - id: M04
    kind: S
    name: 远端灌注与脊髓保护方案确认
    hp_base: 2
    prompt: "即将夹闭胸段主动脉：远端灌注、脊髓保护和监测是否已经就绪？"
    preferred_strategy: "确认左心旁路／远端灌注、分支保护与监测后再进入血管控制"
    risky_strategy: "为缩短时间，不复核远端灌注方案便直接推进夹闭"
    transition_text: "麻醉及灌注团队报告监测与远端血流支持已按计划就位。"
  - id: M05
    kind: P
    name: 主动脉控制与分阶段夹闭
    hp_base: 5
    difficulty: 97
    tag: vascular
    hp_failed_extra: 17
    prompt: "在已建立远端灌注的条件下完成计划中的血管控制与夹闭。"
    transition_text: "灌注团队持续报告近远端血压，巡回护士记录关键控制时点。"
  - id: M06
    kind: F
    name: 病变血管段处理与人工血管准备
    hp_base: 2
    prompt: "在安全控制范围内打开并处理病变段，选择与现存两端相适应的人工血管。"
    transition_text: "器械护士整理血管缝合与补片材料；此例只处理胸段降主动脉。"
  - id: M07
    kind: P
    name: 人工血管近端精细吻合
    hp_base: 6
    difficulty: 96
    tag: reconstruction
    hp_failed_extra: 16
    prompt: "完成移植物近端的整圈对合，兼顾张力、缝线连续性和吻合口止血。"
    transition_text: "助手维护吻合区的稳定视野，主器械护士连续供应血管缝合材料。"
  - id: M08
    kind: P
    name: 重要肋间动脉血供保护与重接
    hp_base: 5
    difficulty: 98
    tag: vascular
    hp_failed_extra: 18
    prompt: "本病例的关键下胸段肋间分支需要妥善处理，以降低脊髓供血中断风险。"
    transition_text: "团队同步观察脊髓灌注相关监测；本节点为首发病例的必要重接变体，不强制所有返场病例相同。"
  - id: M09
    kind: P
    name: 人工血管远端精细吻合
    hp_base: 6
    difficulty: 97
    tag: reconstruction
    hp_failed_extra: 17
    prompt: "完成远端吻合并检查血管连续性和吻合口张力。"
    transition_text: "助手保持远端暴露，灌注团队等待计划中的阶段性恢复血流指令。"
  - id: M10
    kind: P
    name: 分阶段复灌与吻合区止血处理
    hp_base: 5
    difficulty: 95
    tag: vascular
    hp_failed_extra: 15
    prompt: "逐步恢复人工血管通路的血流，避免骤然血流动力学波动，并复核两端吻合口。"
    transition_text: "麻醉团队通报循环变化，巡回护士协调备血与术后移交。"
  - id: M11
    kind: S
    name: 远端脉搏、脊髓保护与最终复核
    hp_base: 2
    prompt: "关闭之前，除了吻合口外观，还必须核对什么？"
    preferred_strategy: "复核近远端灌注、重要分支与相关神经监测、出血及器械清点"
    risky_strategy: "只凭吻合口没有可见出血就结束"
    transition_text: "团队确认移植物通畅与远端灌注监测，完成器械和纱布清点。"
  - id: M12
    kind: F
    name: 胸腔引流与分层关胸
    hp_base: 2
    prompt: "安置必要引流、完成胸腔关闭并向重症／恢复团队交接。"
    transition_text: "术后交接特别注明远端循环、神经功能及血流动力学观察项目。"
```

**医学与玩法边界**：本例预设重要肋间分支需要处理，因此 `M08` 是 P；随机返场中不能不经条件判断就声称每个患者都必须重接同样分支。是否使用特定脑脊液引流或神经监测资源，由现有麻醉/灌注团队与病例策略统一处理；**不在 Grand OR 增加可被玩家当成外科助手指挥的“护士接血管”选项**。

**失败提示句**：

- `M03/M05`：助手：「控制区还不够稳定。别让夹闭位置落到不可靠的血管壁上。」
- `M07/M09`：器械护士：「吻合线的张力不均。备用缝合材料在这边。」
- `M08`：助手：「分支血供还没确认完。先看监测，别急着结扎。」
- `M10`：麻醉团队：「循环状态出现波动。请按计划逐步恢复血流。」

### 2.4 Day 3 首次成功：《不是原装的，也要好好用》

**地点：星见医院术后病房；美纱清醒，仍在接受心血管及神经功能观察。**

1. 旁白：美纱醒来后第一件事，是低头看看盖着病号服的胸口。
2. 美纱：「所以……换好了？」
3. 坂口：「病变的降主动脉段已经置换，血流复核结果稳定。还要继续观察和恢复。」
4. 美纱：「明明是自己身体里最重要的东西之一，动完手术却只能听你向我汇报。」
5. 坂口：「这是全麻的好处。」
6. 美纱：「……也是。真让我全程看着，你们大概会嫌我话太多。」
7. 坂口：「恢复期也别太勉强。」
8. 美纱：「好吧。从今天起，我至少得学会对自己那段新血管客气一点。」
9. 旁白：她笑了一下，随后有些疲惫地闭上眼。进入现有 Day 3 成功结算画面。

### 2.5 Day 3 失败：复用现有团队结算

按最新 `advanced_surgery_content_checklist_v1.md`，不制作美纱专属失败病房戏。运行时调用 `dialogue/day3_failed.json` 中的四句通用团队对白，然后按现有失败锁定规则结算；**此处没有额外可录入的患者台词**。

---

## 3. Codex 转换要求（实装路径、非新 schema）

### 3.1 病例与剧情绑定

1. 先审计已有四台高级手术真实的 `procedure_id` / `case_instance_id` / `patient_id` / VN 资源绑定方式。`first_patient_display_name` 是本稿给人的可读姓名，**不是内部 ID**。伊兹米和美纱真实患者 ID 由 Codex 在仓库按注册规则建立或映射，命名回报给作者。
2. 第五台、六台分别加入独立注册项和已有高级新病例 release manifest；**不可把首发患者添加到随机普通病人池来达到解锁**。
3. 不在 Day 2 插入伊兹米或美纱的长篇人物剧情、回忆、旁白独白。允许的只有术野技术说明、原有 Time-out、需要的医疗专业对白与危机反馈。
4. Day 1 首次剧情 → Grand OR 编组 → 日历锁；Day 3 根据首次真正结果播放患者专属成功脚本，或通用四句团队失败对白 `dialogue/day3_failed.json`。随机返场无需重复首发 Day 1/3，应使用目前已有高级池通用剧情和随机成年患者 Bundle。
5. 两台均固定全麻；Day 2 不显示患者清醒反应，不开放麻醉方案菜单或 Quick Advanced。女性患者手术肖像缺失时采用已有安全占位，不得自动生成未经作者确认的原作肖像。

### 3.2 数据与结算不变量

- 优先使用既有 `F/L/S/P` 类型和全套高级算法；各节点 `hp_base` 与 P `difficulty/hp_failed_extra` 单次扣算，不能存档重载后重复扣。
- `crisis_checkpoints` 中的 `poc_chance` 只供旧测试危机 adapter 演示；如实际 Advanced 已经使用真实危机系统，**只保留 checkpoint 主题，删除第二次独立随机掷骰**，避免双重惩罚。
- P 的首次成功、失败、助手代打、一次救援、剩余介入次数都由现有 Runner **当次会话**去重和管理，不新增持久化 stage/HP/RNG 字段。两助手实际参加 Day 2 后各 14 日历天冷却；不要借这两台新增独立冷却表。
- 首次成功 `CLEARED` 并按规则增加唯一普通高级首通计数；首次 Day 2 失败 `FAILED_LOCKED` 且释放当前新病例槽；返场的成功/失败不倒退首通。以上都在 **Day 3 一次性、幂等**完成，只持久化病例、预约、结局等稳定事实。
- 返场必须从已首通普通高级术式抽取，每周固定两次独立有放回。若只有一种已首通术式，允许同术式的两个不同病例；不要重播首发伊兹米的“人体炼成”或美纱的专属剧情。
- Surgery XP、Grand OR Leadership 和岗位成长、Professional Reputation、Quality/Experience 均由现有 resolver 结算；本稿**不直接硬编码 +40 等为额外 Case Bonus**。
- 美纱姓名已获作者确认；若第六台术式 ID、真实患者注册 ID、原作身份或所需视觉资源尚无法核定，先完成独立医学 stage 数据与测试，保持 `runtime_ready=false`，**不可自行猜造未知资料**。

### 3.3 检验清单（新两台）

| ID | 验收项 | 预期 |
|---|---|---|
| C01 | 内容结构 | 两台均 12 stages、6 P、2 S，HP 基线分别 40/44；阶段名、ID 无重复 |
| C02 | 日期解锁 | 已知 1–4 排序不变；第五伊兹米、第六美纱；月度新资格在下月 1/15 生效，不提前出现 |
| C03 | 未完成数据阻塞 | 当 `runtime_ready=false`，只保留解锁资格与队列，不展示可点击空白病例，也不跨过阻塞项发第七台 |
| C04 | 全麻 | 两台 Day 2 无患者清醒对白；全麻状态不可被低麻醉方案覆盖 |
| C05 | 术式差异 | 伊兹米禁止补回缺失内脏；美纱不借用 TAAA 的腹部器官分支重建 |
| C06 | P 执行与救援 | 六个技术节点都可由坂口／合法助手执行；次数用完不可再按；失败仅能救援一次 |
| C07 | 危机 | 两个 checkpoint；既有危机 resolver 不被双重随机危机叠加 |
| C08 | 存档 | 稳定转诊事实不含 stage／HP／随机种子／助手使用次数／剧情游标；退出和恢复沿用现有 Runner 会话策略，不重复结算 |
| C09 | 首次结果 | Day 3 成功播放患者专属台词；失败只播放通用四句团队对白；首通／锁定／奖励仅一次写入 |
| C10 | 周一返场 | 每周两例、有放回、需完整手术、不能 Quick；随机患者不会声称自己经历人体炼成 |
| C11 | 临床计量 | 不重复累加 Reputation、Surgery/Leadership、双评价、助手岗位成长 |
| C12 | 病人身份 | 第六位姓名「美纱」已经作者确认；全名、出处及角色锚点等剩余资料在正式首发前另行核验 |

### 3.4 工程交付回报模板

Codex 交付时列出：

- 正式登记的两台 `procedure_id`、Registry / Runner / VN / Save 文件路径；新增的患者真实 ID；实际使用的 stage 数据结构（如是否转 JSON/TRES）。
- 是否真正跑通 `Day 1 → Day 2 12 阶段 → Day 3`，两名患者成功/失败分支是否全部试过；排程和读档测试的实际结果。
- Stage 平衡是否仍为占位数值；S strategy effects 是否已经映射原生 resolver；危机是否已经复用真实危机系统。
- `release_order` 1–4 从工程核定为何种 ID，是否保留既有存档排序；第五和第六真实 `runtime_ready` 状态。
- 美纱姓名确认已消除原先疑义，但原作全名、形象、年龄、人物性格尚有哪些需作者确认；**不把内容写作完成与工程上线混为一谈**。

## 4. 医学资料与创作边界（供 Codex 程序核查）

本稿是**星见游戏抽象**，不是现实临床手术教程；阶段、HP、概率、事件均不作为真实世界医学操作建议。

**伊兹米**：复杂再开腹应预先界定目标、审阅影像与残存肠段，谨慎从较安全的区域进入，保护薄弱肠管与血供，并允许在不安全时及时停止。参见 Lundy & Ashburn, *Management of the Hostile Abdomen*（2022，https://pmc.ncbi.nlm.nih.gov/articles/PMC9374530/）；WSES, *Bologna Guidelines*（2017 update，https://pmc.ncbi.nlm.nih.gov/articles/6006983/）。伊兹米“人体炼成”与实际受损器官数量属于**奇幻 AU 特设**，不得宣称上述文献支持魔法病因。

**美纱**：胸降主动脉开放置换可经左开胸，视病变范围选择远端灌注和重要肋间动脉保护；在人工血管吻合后需复核循环、远端灌注及脊髓供血相关状态。参见 *Open repair of descending thoracic aneurysms*（https://pmc.ncbi.nlm.nih.gov/articles/PMC3484579/）；*Midterm outcomes of open repair versus endovascular descending thoracic aortic aneurysm repair*（2023，https://pmc.ncbi.nlm.nih.gov/articles/PMC10775111/）；*Routine intercostal artery reattachment strategy...*（2024，https://pmc.ncbi.nlm.nih.gov/articles/PMC11518943/）。各中心细节与患者解剖可不同，**不把这一首发病例的肋间重接强行泛化到所有变体**。
