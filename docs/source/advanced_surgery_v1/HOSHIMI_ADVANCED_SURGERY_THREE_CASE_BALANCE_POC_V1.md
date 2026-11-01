# Hoshimi Hospital — Advanced Surgery Three-Case Gameplay + Monte Carlo POC V1

> **Status: DESIGN + SIMULATION PROTOTYPE, NOT CODEX-READY / NOT CANONICAL BALANCE.**
>
> Created 2026-10-30. This is a *test model* for the proposed Advanced Referral extension, **not** an assertion that the existing Godot Surgery Runner already implements HP, skill checks, intervention charges, or cooldown.
>
> Reproducible executable companion: `hoshimi_advanced_surgery_balance_sim.py`.
>
> Canonical procedure IDs come from `HOSHIMI_SURGERY_PROCEDURE_POOL_MASTER_LIST_V0_1.md` (20 Advanced slots). Existing F/L/S, Visibility, Bleeding, Blood Loss, Stability, Time, Conditional Correction, RNG persistence, and Surgical Quality rules remain under `HOSHIMI_COMMON_SURGERY_GAMEPLAY_PILOT_CODEX_READY_V2.md`. All three below are **not** the Kaori three-operation Quest and are **not** the Chisato tutorial.

## 0. What this POC is testing

1. Patient **operative reserve** `HP=100`. HP reaches zero → this attempt fails; Stability remains a separate existing variable.
2. Every stage has modest baseline HP consumption; 5–6 `Precision Challenge (P)` stages additionally check technical success, with larger irreversible HP cost on failure.
3. Two doctor assistants: **one** intervention normally per advanced operation. `skills.surgery >= 90` plus matching `specialty_tags` enables a **second matching** intervention; a `universal_expert` such as Mido can qualify on any precision tag. Failed delegation still spends a charge. The attending can act unlimited times.
4. A *planned* delegation and an *emergency rescue* after the attending's failed precision check are distinct strategic policies. Rescue does not erase the initial mistake.
5. Scrub nurses provide a **small probability bonus**, capped at +5 percentage points. Circulating nurses mitigate the HP cost of resolving an existing crisis. Nurses **never** perform precision surgery.
6. Grand OR assistant assignment has a **14-calendar-day cooldown** from the actual surgery day, regardless of whether a charge is spent. Ordinary surgery duty is not disabled.
7. First-time failure → the procedure's `FAILED_LOCKED` state this playthrough. Cleared random return failures have no permanent unlock consequences. Simulations assume one first attempt per procedure, with no save reload.

## 1. Boundary of the simulation

This **only** tests the new HP/precision/assistant/resource layer. It does **not** reproduce the live Godot Runner's exact:

- Stability failure threshold, current Blood Loss and Bleeding effects, actual complication engine, choice scripts, or grading.
- Surgical Quality / Patient Experience calculations, Staff XP, player Surgery XP, or Reputation settlement.
- Three-day calendar event scripts, 3-slot first-time pending board, 1–3 weekly return slots, named patients, event VN, or first-clear progression counter.
- Medical operative validity beyond the broad canonical gameplay identity of each reserved procedure. **Before full Codex authoring, each stage sequence must still pass the existing Procedure Admission Gate using operative sources.**

Thus reported probabilities are **HP-only POC success rates** under a *reasonable existing-system choice* assumption. They are not promises of live game success rates. Adding real Stability failures can only make a case harder unless balanced.

## 2. Proposed POC numerical contract

```python
max_hp = 100

# Skill check uses a fresh seeded roll at a P stage; Godot must cache the
# resolved result per episode/stage/action to prevent in-episode re-rolls.
p_success = clamp(
    0.78 + 0.028 * (actor_surgery - effective_difficulty)
    + scrub_nurse_support, 0.08, 0.985
)

# Skill affects chance primarily; HP base surcharge is intentionally small.
precision_on_success_hp = authored_node_hp + min(3, ceil(max(0, difficulty - actor_surgery) / 12))
precision_on_failure_hp = precision_on_success_hp + authored_failure_extra_hp

# Anatomy variant: 25% of cases, +4 HP early, +3 difficulty on nodes originally >=95.
# Crisis handling: two explicitly placed opportunities per surgery, each with
# authored probability; resolution costs 8–13 HP, reduced by 0–4 through
# circulating nurse skills. These do not replace existing crisis choice logic.

# Emergency rescue: when player (not delegated assistant) fails, an eligible
# unused assistant can consume a charge and attempt to reduce the correction
# portion: successful rescue cost ceil(failure_extra * 0.42)+2; failed rescue
# costs failure_extra+3. The initial attempt's base HP is always lost.
```

**All constants above are prototype knobs.** `effective_difficulty` is a gameplay difficulty score, not a real-world medical grade. Specialty tags influence *the second-use eligibility*, not by themselves an additional invisible success-rate boost. In this POC the two scrubs' skill bonus reaches 0–5pp combined and the two circulators provide crisis-cost relief; no role violates scope.

## 3. Procedure A — `surgery_open_whipple` (13 stages, 6 precision)

Gameplay identity: difficult tissue dissection followed by **multiple distinct reconstructions**. Prototype baseline HP if every operation were performed without skill surcharge or failure: **41**.

| Stage | Function | Kind | Base HP | P difficulty / tag | Extra HP on failed P |
|---|---|:---:|---:|---|---:|
| W01 | 切口与进入 | F | 2 | — | — |
| W02 | 腹腔探查、建立暴露 | L | 2 | — | — |
| W03 | 复杂粘连分离 | P | 4 | 88 / `adhesion` | 12 |
| W04 | 主要血管关系与切除路径评估 | S | 2 | — | — |
| W05 | 门静脉周围组织分离 | P | 5 | 94 / `vascular` | 15 |
| W06 | 胰头深部精细分离 | P | 5 | 96 / `microdissection` | 16 |
| W07 | 标本取出、整理术野 | F | 2 | — | — |
| W08 | 胰肠重建 | P | 6 | 97 / `reconstruction` | 16 |
| W09 | 胆肠重建 | P | 4 | 92 / `reconstruction` | 13 |
| W10 | 胃肠重建 | P | 4 | 90 / `reconstruction` | 12 |
| W11 | 重建区复核及止血 | S | 2 | — | — |
| W12 | 最终清点与评估 | L | 1 | — | — |
| W13 | 关闭 | F | 2 | — | — |

Prototype crisis windows: after W05, W10. Existing procedural strategic choices at W04/W11 must remain independent of the P rolls.

## 4. Procedure B — `surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction` (12 stages, 6 precision)

Gameplay identity: pelvic adhesion/nerve preservation plus a **vascular reconstruction**. This is deliberately the most unforgiving of the three test cases. Baseline HP: **41**.

| Stage | Function | Kind | Base HP | P difficulty / tag | Extra HP on failed P |
|---|---|:---:|---:|---|---:|
| P01 | 切口与进入 | F | 2 | — | — |
| P02 | 盆壁暴露 | L | 2 | — | — |
| P03 | 广泛盆腔粘连分离 | P | 4 | 90 / `adhesion` | 13 |
| P04 | 神经与输尿管邻近关系辨认 | P | 5 | 95 / `neural` | 15 |
| P05 | 血管处理策略确认 | S | 2 | — | — |
| P06 | 髂血管周围精细分离 | P | 5 | 96 / `vascular` | 16 |
| P07 | 肿瘤深部边界分离 | P | 5 | 94 / `microdissection` | 15 |
| P08 | 完整切除、整理术野 | F | 2 | — | — |
| P09 | 髂血管重建 | P | 6 | 98 / `reconstruction` | 18 |
| P10 | 盆壁神经与固定点复核 | P | 4 | 92 / `pelvic` | 13 |
| P11 | 灌注与最终止血评估 | S | 2 | — | — |
| P12 | 关闭 | F | 2 | — | — |

Prototype crisis windows: after P06, P09. This is where an Aqua-type pelvic specialist and a vascular/reconstruction specialist should be **complementary**, not interchangeable.

## 5. Procedure C — `surgery_adv_sleeve_lobectomy` (11 stages, 5 precision)

Gameplay identity: preserving the airway and pulmonary vascular continuity, distinct from abdominal and pelvic dissection. Baseline HP: **36**.

| Stage | Function | Kind | Base HP | P difficulty / tag | Extra HP on failed P |
|---|---|:---:|---:|---|---:|
| T01 | 开胸与进入 | F | 2 | — | — |
| T02 | 肺门区域暴露 | L | 2 | — | — |
| T03 | 肺动脉分支解剖 | P | 5 | 94 / `vascular` | 15 |
| T04 | 支气管周围精细分离 | P | 4 | 91 / `thoracic` | 12 |
| T05 | 病变切除范围确认 | S | 2 | — | — |
| T06 | 保留结构与切缘处理 | P | 4 | 93 / `microdissection` | 13 |
| T07 | 完成肺叶切除 | F | 2 | — | — |
| T08 | 支气管重建吻合 | P | 6 | 97 / `airway` | 17 |
| T09 | 血管重建及复核 | P | 5 | 96 / `reconstruction` | 16 |
| T10 | 通气与灌注复查 | S | 2 | — | — |
| T11 | 关闭 | F | 2 | — | — |

Prototype crisis windows: after T07, T09. The airway challenge requires a matching specialty to unlock a *second* intervention, rather than a generically high physician being automatically specialized.

## 6. Monte Carlo experiment

Simulation command:

```bash
python3 hoshimi_advanced_surgery_balance_sim.py --runs 25000 --seed 20261030
```

3 cases × 4 illustrative team tiers × 4 policies × **25,000 trials** = **1,200,000 independently sampled case attempts**, plus independent calendar-rotation and nurse-only sensitivity runs. Each attempt starts at HP 100; HP reaches zero → failure, no first-clear reroll.

### 6.1 Test-fixture teams (NOT actual Staff data)

| Fixture | Player Surgery | First assistant | Second assistant | Nurse skills |
|---|---:|---|---|---|
| 入门阵容 | 82 | Surgery 82, no second use | Surgery 76 | ~60–65 |
| 入门主刀＋强援 | 82 | Mido-type general expert Surgery 97, max 2 | Surgery 80 | ~72–80 |
| 均衡阵容 | 88 | Surgery 90, vascular/reconstruction specialty | Surgery 84 | ~75–80 |
| 顶级专家阵容 | 93 | Mido-type general expert Surgery 97 | matching field expert Surgery 94 | ~85–92 |

`Mido-type` / `Aqua-type` / `Takemi-type` / `Saber-type` are **illustrative skill fixtures only**. Do not write these numeric Surgery values into canonical named Staff records without validating their actual data.

### 6.2 Policies

- `solo`: player handles every precision challenge. Other team positions remain in the OR, but do not actively intervene.
- `greedy`: use an available assistant immediately when the expected cost is lower.
- `planned`: allocate each assistant's 1–2 actions across the known baseline nodes to minimize expected total HP cost. The 25% anatomy variant remains unknown at planning time.
- `reactive`: player starts every challenge, calls an eligible unused assistant **only after a failure** if expected correction cost is lower; the initial lost HP is not restored.

### 6.3 First-clear rate — `planned` policy

| Fixture | Whipple | Pelvic sidewall | Sleeve lobectomy |
|---|---:|---:|---:|
| 入门阵容 | **47.4%** | **35.0%** | **65.1%** |
| 入门主刀＋强援 | **86.2%** | **72.1%** | **95.3%** |
| 均衡阵容 | **87.7%** | **77.7%** | **93.3%** |
| 顶级专家阵容 | **99.5%** | **97.8%** | **99.7%** |

### 6.4 Mean HP among successful first attempts — `planned`

| Fixture | Whipple | Pelvic sidewall | Sleeve lobectomy |
|---|---:|---:|---:|
| 入门阵容 | 15.3 | 12.3 | 18.7 |
| 入门主刀＋强援 | 24.4 | 20.3 | 30.6 |
| 均衡阵容 | 26.1 | 22.5 | 29.4 |
| 顶级专家阵容 | 42.2 | 37.1 | 46.5 |

Because the first attempt is permanently locked on failure, these low-tier clear rates **must not be mistaken for recommended default accessibility**. Before production, risk should be signposted at Day 1, and players should be able to prepare stronger assistants or decline to start. At the moment pelvic sidewall is deliberately high-risk for a weak initial team. Full Surgery Runner Stability/quality integration may further reduce these percentages.

### 6.5 Delegation strategy actually matters

Selected comparison for **Surgery 82 player + one top expert**:

| Case | `solo` | `greedy` | `planned` | `reactive` |
|---|---:|---:|---:|---:|
| Whipple | 52.9% | 79.9% | **86.2%** | 72.6% |
| Pelvic sidewall | 40.0% | 68.0% | **72.1%** | 57.2% |
| Sleeve lobectomy | 70.2% | 94.2% | **95.3%** | 85.7% |

With a clearly superior specialist, **pre-planned delegation** is better than waiting for personal failure. But with a Surgery 88 player and similarly skilled assistants, emergency rescue can outperform planning by preserving charges for actual mistakes: for Whipple 91.3% `reactive` vs 87.7% `planned`. That is a useful *emergent strategic trade-off*, not necessarily a bug. Both modes consume the same assistant charge pool.

### 6.6 14-day assistant cooldown — three consecutive first attempts

The following is a **separate synthetic scheduling scenario**, not the live 3-day calendar UI. Same Surgery 88 attending, strong nurses, matching second specialists; Mido-type first assistant is available on Day 2, then under a 14-day cooldown. If a case is started 7 days later, a weaker first assistant must rotate in. Cooldown begins upon actual Day 2 participation **even if the team loses or she is never actively delegated**.

| Schedule | Day 2 surgery days | Last Day 3 | Mean first clears out of 3 | All 3 first clears |
|---|---|---:|---:|---:|
| 连续接诊，轮换助手 | 2, 9, 16 | Day 17 | 2.837 | **83.92%** |
| 等待强援，每两周开一台 | 2, 16, 30 | Day 31 | 2.930 | **93.13%** |

Waiting costs **14 extra calendar days** for these three cases but gains ~9.2 percentage points of perfect three-case first-clear likelihood. This is the intended calendar-vs-reliability trade-off, and it becomes even sharper under the permanent first-failure lock.

### 6.7 Nurse-only skill sensitivity

Holding Whipple, Surgery 88 player and both assistants **fixed**, change only the four nurse test-fixture skills:

| Nurses | Whipple planned first-clear | Mean HP if clear | Scrub support on vascular node |
|---|---:|---:|---:|
| 新护士 (~60) | **83.75%** | 24.87 | +0.0pp |
| 熟练护士 (~75–80) | **87.52%** | 26.22 | +2.37pp |
| 优秀护士 (~88–94) | **90.78%** | 27.53 | +4.90pp |

The nurse contribution is meaningful without making them interchangeable with doctor assistants. The high-nurse scenario also reduces crisis HP loss via the circulating team.

## 7. Design conclusions — recommendations, not locked values

1. **HP=100 and 1–2 assistant interventions are workable.** The first overly expensive test gave weak teams ~11–35% first-clear; reducing unavoidable baseline costs while keeping meaningful failure penalties produced much healthier separation between weak, well-composed and expert teams.
2. **Team composition is not cosmetic.** The same Surgery 82 attending can jump from roughly 35–65% first-clear with low-skill assistants to 72–95% with a strong generalist and appropriate nurses.
3. **Node and specialty placement matter.** Matching specialists can spend two actions, but only on matching second-use tags; Grand OR does not become six free surgeon actions.
4. **The 14-day cooldown has measurable campaign value.** Rushing yields more calendar throughput; waiting for the best expert preserves one-time first-clear probability.
5. **Permanent first-failure is harsh.** Each new case should reveal at least a risk tier and relevant specialties during Day 1. Consider assigning the more approachable sleeve lobectomy before the notably harder pelvic sidewall case, though the exact first-story patient lineup is still unchosen.
6. **Real surgery state integration remains the main P0.** Connect HP cost to existing choices/crises once, without double-counting the same event's Blood Loss/Stability penalty as additional arbitrary HP punishment. Preserve grading/XP/reputation rules.
7. **Before Codex:** verify real staff skill values, specialty tags, live role permission and cooldown semantics, state+save RNG persistence, failure-after-Day2 handling, first-clear permanent state, and source-grounded operative sequences.

## 8. Suggested integration contract (non-authoritative field names)

```yaml
advanced_episode:
  patient_operating_reserve_hp: 100
  precision_results_by_stage: {}     # persist seeded dice + chosen performer
  precision_interventions_used:
    first_assistant: 0
    second_assistant: 0
  first_attempt_procedure_status: IN_PROGRESS

advanced_staff:
  specialty_tags: []
  universal_expert: false
  advanced_assistant_next_available_day: null

precision_stage:
  stage_id: W08
  tag: reconstruction
  difficulty: 97
  hp_base_cost: 6
  hp_failed_extra: 16

procedure_status:
  value: NOT_SEEN | AVAILABLE | IN_PROGRESS | CLEARED | FAILED_LOCKED
```

The names here describe desired behavior; **Codex must inspect and reuse actual Godot schema/registries before implementing**. The three-procedure proof-of-concept is ready for another numerical tuning/review pass, not direct wholesale copy into runtime.
