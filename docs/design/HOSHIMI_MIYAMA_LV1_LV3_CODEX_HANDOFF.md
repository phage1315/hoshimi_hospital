# Hoshimi Hospital — 深山佳織 Lv1–Lv3 Codex Handoff
## Implementation Package

> **用途：** 把深山佳織当前 Lv1–Lv3 更新一次性交给 Codex。
>
> **原则：** 先补现有拼图，不扩张地图。

---

# 1. Files in This Package

## 必须读取

```text
HOSHIMI_MIYAMA_KAORI_CHARACTER_BIBLE.md
HOSHIMI_MIYAMA_LV1_SAFETY_PIN_EVENT.md
HOSHIMI_MIYAMA_LV2_AYAKO_EVENT.md
HOSHIMI_MIYAMA_LV3_OR_GOD_EVENT.md
HOSHIMI_OR_TABLE_PALPATION_SYSTEM.md
```

---

# 2. Implementation Order

```text
Phase A
深山 Lv1《叮。》
+
OR Table Palpation MVP

Phase B
深山 Lv2《取材过头了》连续性修订

Phase C
深山 Lv3《手术室之神》
```

Do not implement all future OR palpation features before Lv1 works.

---

# 3. Relationship Arc

```text
Lv0 → Lv1
《叮。》
“我做判断的时候，你会认真听。”

Lv1 → Lv2
《取材过头了》
“出了事，你不会把我一个人留下收拾。”

Lv2 → Lv3
《手术室之神》
“我自己都开始不相信自己的时候，你仍然敢把主刀位交给我。”
```

---

# 4. Lv1 Core

```text
ordinary adult woman with abdominal pain
X-ray appears to show safety pin in abdomen
urgent surgery planned
patient reaches OR
final clothing removal / patientization at table side
clothing is moved
“叮。”
safety pin falls to floor
patient panics and cannot reliably answer whether pain remains
Miyama performs OR-table abdominal palpation
Fear / guarding contaminates exam reliability
Miyama still cannot declare patient safe
exploratory laparotomy proceeds
negative exploration
Miyama sincerely:
“太好了。她完全健康。”
Relationship Lv1
unlock surgery_exploratory_laparotomy
unlock OR palpation system entry
```

---

# 5. OR Palpation MVP for Lv1

Only implement:

```text
abdominal image
4 rough hotspots
pressure:
  light
  standard
  deep
short patient reactions
Fear / Pain / Guarding
Exam Reliability concept
fixed narrative result:
  reliability insufficient
  proceed to exploratory laparotomy
```

Do not build the entire future full-torso system now.

---

# 6. Lv2 Core

Preserve the wrong-patient Ayako event.

Update with:

```text
explicit Lv1 callback
Miyama now has two absurd OR memories
Asuka formal review remains strict
after formal review:
  private Asuka–Miyama old-friend scene
Lv3 “OR god” seed
```

Relationship Lv2 payoff remains:

> 「因为你没跑。」

> 「那以后手术室真出事——我至少知道该叫谁了。」

---

# 7. Lv3 Core

```text
Miyama starts joking that two impossible OR events form a pattern
Asuka tells her not to be superstitious
off-duty Miyama privately performs absurd “empirical exclusion”
voluntarily nude + surgical cap on empty OR table
falls asleep
Sakaguchi / Asuka discover her
real emergency arrives
Miyama immediately switches to professional mode
she initially refuses Primary Surgeon role
Asuka:
“前两次都没有证明你不会做手术。”
Sakaguchi:
“你主刀。我做第一助手。我支持你。”
Miyama urgently gowns without scrubs underneath
this is explicitly not hospital SOP
dedicated rear-3/4 surgery CG
Miyama successfully leads the real emergency surgery
confidence restored
Relationship Lv3
```

---

# 8. Asuka / Miyama Rule

Never write:

> Miyama is isolated until Sakaguchi understands her.

Canonical:

```text
Miyama and Asuka have been close since medical school.
Asuka already trusts Miyama deeply.
Asuka is Director and will still perform formal accountability.
After the formal role is complete, she checks Kaori as an old friend.
Sakaguchi becomes a new entrant into an already-existing small trust circle.
```

---

# 9. Surgical Safety / Tone Rule

Hoshimi tone:

> **high drama, low lethality**

The three events are absurd, but Miyama is not a joke doctor.

Her early weakness:

> under pressure, “I cannot prove safety” can become “continue intervention.”

Her growth:

> stopping, verifying, and accepting uncertainty are also competence.

Lv3 must end with:

> she succeeds because she is genuinely capable, not because Sakaguchi takes over.

---

# 10. Existing Advanced Referral Work

Important:

```yaml
advanced_referral_tutorial_chisato:
  delivered_to_codex: true
  implementation_in_progress: true
```

Do not re-implement or overwrite the Chisato Advanced Referral tutorial as part of this package.

# END
