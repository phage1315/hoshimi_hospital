# Hoshimi Hospital | Tae Takemi Relationship Growth Rules Revision & Lv1–Lv2 Full Script Handoff Package (English Version)

**Version:** V1.2 Codex-Ready Final Revision (2026-11-01)  
**Associated Characters:** Tae Takemi (`doc_takemi` / Age Undisclosed `??`, mature adult woman), Fujino Asagami (`patient_fujino` / Age 20, adult prestigious university student AU), Asuka Shiromiya (`doc_asuka`), Miyuki Asakura (`nurse_yui`), Moe Honjo (`nurse_moe`)  
**Package Contents:**
1. Tae Takemi's dual-tier Familiarity multiplier, rounding rules, and Lv0–Lv2 Gate / scheduling duration specifications
2. **Tae Takemi Lv1 Script: *"Who Said Vivisection Has to Be Fatal?"*** (Auto-triggers at 09:00 on the next workday, standalone scripted surgery event, 3-hour duration, 42 nodes played per single playthrough)
3. **Tae Takemi Lv2 Script: *"Since You're Already Open, Let's Take a Closer Look"*** (Auto-triggers at 09:00 on a workday, standalone full-day scripted surgery event, occupies full day until 18:00 end-of-shift, 108 nodes played per single playthrough)

---

## 0. Tae Takemi Familiarity Rules Revision & Gate Specification (System & Gate Spec)

> **Design Note (Synchronized with `HOSHIMI_TAKEMI_TAE_CHARACTER_BIBLE_V1_3.md` & `HOSHIMI_CHARACTER_RELATIONSHIP_GATE_MATRIX.md` §12H):**  
> As a hidden "underground doctor" who only reveals herself after the player meets high thresholds for unanesthetized surgeries, Clinical Presence, and Reputation, Tae Takemi finds conventional anesthetized surgeries dull and uninspiring, reserving her true enthusiasm exclusively for **unanesthetized surgeries** where the patient remains wide awake. Because the Advanced Surgery Pool (Advanced / Extreme, base Familiarity +10 / +15) enforces mandatory general anesthesia at the system level, **only the Routine Surgery Pool (base Familiarity `+5`) allows selecting "No Anesthesia."** Therefore, a dual-tier Familiarity multiplier ("Anesthetized `×0.80` / Unanesthetized `×1.50`") directly translates her character preferences into a gameplay progression driver.

### 0.1 Dual-Tier Familiarity Multiplier & Rounding Rules

* **Anesthetized Surgeries & Routine Daily Interactions Multiplier**: **`×0.80`**
  * Routine Anesthetized Surgery (Base `+5`): `5 × 0.80 = +4`
  * Advanced Surgery (Mandatory General Anesthesia, Base `+10`): `10 × 0.80 = +8`
  * Extreme Surgery (Mandatory General Anesthesia, Base `+15`): `15 × 0.80 = +12`
  * Underground Lab Daily Chat (Base `+2`): Rounds half up to `+2` in integer mode (`+1.6` in float mode)
  * *Semantic Expression*: Once a patient is put to sleep under anesthesia, Takemi feels "it's no different from cutting into a plastic model" and maintains only baseline professional cooperation.
* **Routine Unanesthetized Surgery Exclusive Co-Op Multiplier (No-Anesthesia Bonus)**: **`×1.50`**
  * Routine Unanesthetized Surgery (Base `+5`): Raw calculated value is `5 × 1.50 = 7.5`.
  * **Explicit Rounding Rule**:
    * If the underlying codebase stores `familiarity` as a **floating-point number (`float`)**, accumulate the exact **`+7.5`**;
    * If the underlying codebase stores `familiarity` as an **integer (`int`)**, uniformly apply **round half up**, settling each routine unanesthetized surgery at a fixed **`+8`** (never mix floor truncation to +7 with round half up).
  * *Progression Pacing Calculation (Distinguishing Integer vs. Float Modes)*:
    * **Reaching Lv1 (`Familiarity >= 10`)**:
      * Completing **2** routine unanesthetized surgeries together (`15.0` in float mode, `16` in integer mode) reliably clears the gate in both modes;
      * If combining "1 routine unanesthetized surgery + Underground Lab chat": in **integer mode**, `8 + 2 = 10` (1 surgery plus 1 chat is sufficient); in **float mode**, `7.5 + 1.6 = 9.1 < 10`, requiring 1 additional interaction (e.g., a 2nd chat for `9.1 + 1.6 = 10.7`) or a 2nd surgery to reach the 10-point threshold.
    * **Reaching Lv2 (`Familiarity >= 25`)**:
      * Completing **4** cumulative routine unanesthetized surgeries with Takemi (`30.0` in float mode, `32` in integer mode) clears the gate naturally;
      * Or **3 routine unanesthetized surgeries (`22.5` float / `24` int) + 1–2 Underground Lab chats**.

### 0.2 Tae Takemi Lv0–Lv2 Relationship Gate & Scheduling Duration Matrix

| Level | Event Title | Familiarity | Player Stat / Prerequisite Gate | Trigger Entry & Scheduling Duration (Locked) | Rewards & Unlocks |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **Lv0** | ***"Table Three"***<br>*(Formal acquaintance after 5 hospital ghost stories)* | — | • Cumulative successful unanesthetized surgeries `>= 20`<br>• All 5 preceding ghost story vignettes completed<br>• `Clinical Presence >= +60`<br>• `Professional Reputation >= 200` | **Triggers upon the successful settlement of the next valid unanesthetized surgery after all prerequisite conditions are met** (Fixed VN) | • `met_takemi = true`<br>• Unlocks **Underground Lab** daily access<br>• Unlocks inviting Takemi as **First Assistant** for regular surgeries |
| **Lv1** | ***"Who Said Vivisection Has to Be Fatal?"***<br>*(Live surgical anatomy teaching + middle-school frog anecdote)* | **>= 10** | • `Lv0 complete`<br>• **No additional 5-stat wall** | • **Standalone Scripted VN Surgery Event (Not embedded in regular Surgery Runner)**<br>• Auto-triggers at **`09:00` on the next workday** once conditions are met<br>• **Duration: `3 hours`** (advances clock to `12:00` upon completion)<br>• Cooldown `>= 3` days after Lv0 | • `doc_takemi.level = 1`<br>• Plants core foreshadowing of her desire to meet a patient with congenital insensitivity to pain |
| **Lv2** | ***"Since You're Already Open, Let's Take a Closer Look"***<br>*(Fujino Asagami: Painless special-approval lead surgery & pain awakening)* | **>= 25** | • `Lv1 complete`<br>• **Sakaguchi `Surgery >= 75`**<br>• **No extra co-op count hard lock** | • **Standalone Full-Day Scripted VN Surgery Event (Does not enter regular or Advanced Surgery Runner)**<br>• Auto-triggers at **`09:00` on the next workday** once conditions and `>= 3` days cooldown after Lv1 are met<br>• **Occupies Full Workday (`09:00 -> 18:00` / advances directly to evening end-of-shift settlement)** | • `doc_takemi.level = 2`<br>• Logs special story patient Fujino Asagami's cured discharge record |

---

## 1. Tae Takemi Lv1 Script: *"Who Said Vivisection Has to Be Fatal?"*

### 1.0 Event Metadata (Codex Spec)
* **Event ID (Candidate)**: `ev_doc_takemi_lv1_vivisection_frog`
* **Title (EN)**: `Who Said Vivisection Has to Be Fatal?`
* **Title (CN)**: `谁说生体解剖一定会死的？`
* **Primary Character**: Tae Takemi (`doc_takemi`)
* **Supporting Characters**: Moe Honjo (`nurse_moe`), Awake Female Surgery Patient (`patient_generic_f`)
* **Unlock Gate**: `doc_takemi.level == 0` && `doc_takemi.familiarity >= 10` && `cooldown >= 3 days`
* **Trigger & Time Cost (Locked)**:
  * **Trigger Method**: **Auto-triggers at `09:00` on the next workday** after meeting the gate.
  * **Event Nature**: **Standalone Fixed VN Scripted Surgery + Underground Lab Conversation**; does not embed into player-scheduled regular Surgery Runner sessions.
  * **Time Consumption**: Fixed duration of **3 hours** (`09:00 -> 12:00`; advances the in-game clock to `12:00` noon upon completion).
* **Node Count (Verified)**: ID range `L1_001`–`L1_042`, defining **44** total text blocks (including 1 four-node dialogue branch), playing **42** individual nodes on a single playthrough.

---

### [Act 1: Live Surgical Anatomy at the Unanesthetized Operating Table (09:00 - 11:00)]

**【SCENE START】**
* **BGM (Candidate)**: `bgm_or_routine_tense`
* **BG (Candidate)**: `bg_operating_room_std`

**[L1_001]**  
Narrator: Nine o'clock in the morning, Operating Room 2. Since Tae Takemi was officially cleared to join our surgical roster, this is a routine awake laparotomy with me as lead surgeon and her assisting across the table.

**[L1_002]**  
Narrator: Beneath the shadowless lamp, the young female patient on the table has been given no general anesthesia. As my scalpel steadily incises the right anterior rectus sheath and peritoneum, the warm, living structures inside her abdominal cavity come into view.

**[L1_003]**  
* **Sprite (Candidate)**: `nurse_moe_scrub_nervous` (Left)  
Moe Honjo: "D-Dr. Sakaguchi, the retractors and warm saline laparotomy pads are ready..."

**[L1_004]**  
* **Sprite (Candidate)**: `doc_takemi_scrub_mask_default` (Right)  
Tae Takemi: "No need to pack the gauze in so quickly, Sakaguchi. Just look at this girl's mesenteric vascular arcades—without anesthetic hypotension dulling them, they're pulsing like a work of art."

**[L1_005]**  
* **SFX (Candidate)**: `sfx_retractor_metal_slide`  
Narrator: Across the table, Takemi's eyes gleam above her mask. Gripping the abdominal wall retractor with her sterile-gloved hands, she sinks her wrists outward with practiced ease—widening an incision that was originally standard length by a full margin.

**[L1_006]**  
Female Patient: "Mmph...! W-Wait a second, Doctor... My stomach is being pulled so tight to both sides... I-I held still when you cut me open just now, but spreading it this wide makes my insides feel so strange...!"

**[L1_007]**  
Takashi Sakaguchi: "Takemi, the exposure is already plenty wide for me to work. You don't need to crank the retractor to the maximum."

**[L1_008]**  
* **Sprite (Candidate)**: `doc_takemi_scrub_mask_smile`  
Tae Takemi: "It's a rare opportunity. Hey, little scrub nurse holding the tray over there—Honjo, was it? Lean in a bit closer."

**[L1_009]**  
* **Sprite (Candidate)**: `nurse_moe_scrub_surprise`  
Moe Honjo: "Eh? M-Me? Yes, ma'am!"

**[L1_010]**  
Narrator: Moe inches forward half a step timidly. Using atraumatic tissue forceps, Takemi gently lifts the patient's faintly蠕动ing terminal ileum and mesenteric root, pointing them out as if giving a demonstration in a university lecture hall:

**[L1_011]**  
Tae Takemi: "All you ever see in nursing textbooks are lifeless illustrations, right? Look closely right here—while the patient is awake, the moment my forceps lightly graze the serosa, the bowel contracts and pulls away on its own, and you can watch every tiny vasa recta beating one pulse after another."

**[L1_012]**  
Moe Honjo: "Whoa... It's really moving on its own...! So this is what living internal organs actually look like... It's so much clearer than the diagrams in our textbook..."

**[L1_013]**  
Female Patient: "Uu...! Um, Doctors, Nurse... Please don't discuss the quality of the teaching material right in front of the teaching material herself while rummaging around inside my belly...!"

**[L1_014]**  
Takashi Sakaguchi: "Alright, Professor Takemi's live anatomy lecture is adjourned. Moe, hand me the curved hemostat; Takemi, hold the retractor steady for me so we can address the lesion."

**[L1_015]**  
* **Sprite (Candidate)**: `doc_takemi_scrub_mask_tease`  
Tae Takemi: "Tch, how strict. Still, your incision is remarkably clean, without a single drop of wasted bleeding—assisting a lead surgeon like you isn't half bad."

---

### [Act 2: The Underground Lab & the Middle-School Frog (11:00 - 12:00)]

* **BGM (Candidate)**: `bgm_underground_lab_lazy`
* **BG (Candidate)**: `bg_takemi_underground_lab`

**[L1_016]**  
Narrator: By the time the operation wraps up smoothly and the patient is wheeled back to the ward for observation, it is just past eleven. Following the stairs down to the Underground Research Lab on the lowest level of the hospital, I push open the door to find Tae Takemi lounging in her swivel chair with her long legs crossed, sipping an iced coffee.

**[L1_017]**  
* **Sprite (Candidate)**: `doc_takemi_coat_default` (Center)  
Tae Takemi: "Yo, Lead Surgeon. What brings you down here—delivering a lecture on behalf of that little Director Shiromiya, or settling the score with me for widening the retractor at the table?"

**[L1_018]**  
Takashi Sakaguchi: "If I wanted to lecture you, I would've done it at the scrub sink. Though after Moe blurted out that your explanation was clearer than a textbook, the girls at the nurses' station have fresh material for their hospital ghost stories about you."

**[L1_019]**  
* **Sprite (Candidate)**: `doc_takemi_coat_smile`  
Tae Takemi: "Ghost stories? Let me guess—are they whispering again that 'that woman named Takemi in the basement is actually a madwoman whose ultimate hobby is performing vivisections on living people'?"

#### [Branch Point L1-A: Responding to Her Remark]
* **Choice A1**: `"Then I'll ask the woman herself—is your ultimate hobby really vivisection?"` -> Jump to **[L1_020A]**
* **Choice A2**: `"Watching the patient's awake reactions at the table earlier, you looked even more thrilled than I was as lead surgeon."` -> Jump to **[L1_020B]**

**[L1_020A]**  
* **Sprite (Candidate)**: `doc_takemi_coat_tease`  
Tae Takemi: "Haha, aside from that girl Shiromiya, you're the first person in this hospital with the nerve to ask me that to my face."

**[L1_021A]**  
Takashi Sakaguchi: "After standing across the table from you through a whole operation, pretending not to notice would be harder."  
(Converge to **[L1_022]**)

**[L1_020B]**  
* **Sprite (Candidate)**: `doc_takemi_coat_tease`  
Tae Takemi: "Look who's talking, Dr. Sakaguchi. A man who cuts that steadily without a drop of anesthesia has no business calling me a freak."

**[L1_021B]**  
Takashi Sakaguchi: "I do it for clinical training and special indications. Meanwhile, the nurses are whispering that your ultimate hobby is 'vivisection.'"  
(Converge to **[L1_022]**)

**[L1_022]**  
* **Sprite (Candidate)**: `doc_takemi_coat_default`  
Tae Takemi: "Laypeople have given the word 'vivisection' such an ugly ring. As if the mere mention of dissecting a living body means you have to torture the subject to death on the table."

**[L1_023]**  
Narrator: Setting down her coffee cup, she leans forward slightly, her dark-painted lips curving into a matter-of-fact smile:

**[L1_024]**  
Tae Takemi: "Back when I was in middle school, we had a frog dissection lab in biology class. The whole class was making a huge fuss, snipping their frogs' bellies into a mangled mess."

**[L1_025]**  
Tae Takemi: "I found it baffling—if our goal was simply to observe the beating heart, the expanding lungs, and the course of the intestines in a living state, why did everyone assume the frog had to die?"

**[L1_026]**  
Takashi Sakaguchi: "...So what did you do?"

**[L1_027]**  
* **Sprite (Candidate)**: `doc_takemi_coat_smile`  
Tae Takemi: "I opened the abdominal cavity while avoiding every major vessel, observed every single beating organ inside from top to bottom, and finished my anatomical drawings; then I used the finest suture needle and thread I'd brought from home to close it back up layer by layer, and flipped it back over on the wax tray."

**[L1_028]**  
Takashi Sakaguchi: "And then? Did it survive?"

**[L1_029]**  
Tae Takemi: "It kicked its hind legs and hopped right off the lab table on its own."

**[L1_030]**  
Narrator: She delivers the line with utter calm, as though recounting nothing more remarkable than a home-economics sewing assignment.

**[L1_031]**  
Takashi Sakaguchi: "...Your biology teacher's face must have been a sight to behold."

**[L1_032]**  
* **Sprite (Candidate)**: `doc_takemi_coat_tease`  
Tae Takemi: "The teacher nearly dropped his lesson plan. And doesn't the exact same logic apply here at Hoshimi Hospital? Since our medical safeguards guarantee that no matter how wide we open an incision or how thoroughly we examine the organs inside, the patient will heal without a scratch once sutured back up—what's wrong with taking a closer look while she's wide awake and her organs are pulsing right in front of us?"

**[L1_033]**  
Takashi Sakaguchi: "So Director Shiromiya banned you from routine lead surgery because you wanted to treat patients like that middle-school frog?"

**[L1_034]**  
* **Sprite (Candidate)**: `doc_takemi_coat_lazy`  
Tae Takemi: "I only opened that last case a little deeper than usual—who knew the hydraulic bracket on the old operating table in OR 3 was so flimsy it would jam halfway through? That girl Shiromiya made a mountain out of a molehill, claiming if I kept cutting I'd dismantle the patient and the table together."

**[L1_035]**  
Narrator: Leaning lazily back against her chair, she looks me up and down with the amused glint of someone who has found a kindred spirit:

**[L1_036]**  
Tae Takemi: "Still, standing across from you as first assistant is surprisingly pleasant. At least when I widened the retractor earlier, your hands didn't waver a millimeter—in fact, your eyes looked even more focused than mine."

**[L1_037]**  
Takashi Sakaguchi: "As long as it doesn't get in the way of the actual procedure, I don't mind letting you slip in a two-minute anatomy lesson for the rookies."

**[L1_038]**  
* **Sprite (Candidate)**: `doc_takemi_coat_default`  
Tae Takemi: "The only downside is that ordinary patients are still too squeamish. Even without anesthesia, the second you pull the retractor two centimeters wider or reach inside to turn over a loop of bowel, they start hollering in pain and ruin the quiet."

**[L1_039]**  
Narrator: Resting her index finger lightly against her chin, Takemi lets out a wistful sigh as if making a casual wish:

**[L1_040]**  
* **Sprite (Candidate)**: `doc_takemi_coat_smile`  
Tae Takemi: "If only a **patient who naturally feels no pain at all** would walk into our clinic one day. No anesthesia needed, and no screaming when we open her up... If a case like that ever shows up, I'll go straight to Shiromiya for a special-approval lead surgery permit, draft you as my first assistant, and inspect a living abdominal cavity from top to bottom to my heart's content."

**[L1_041]**  
Takashi Sakaguchi: "What are the odds of that? If someone actually had congenital insensitivity to pain, she wouldn't even notice when she fell ill—by the time she walked into a hospital, who knows how badly her insides would have festered."

**[L1_042]**  
Tae Takemi: "Wouldn't that make it even more fascinating? We'd get to admire healthy living anatomy *and* clean up a complex mess in one go. ...Alright, it's hampir twelve noon—go grab your lunch, partner. And if you have any more unanesthetized cases this afternoon, be sure to call me."

**【SCENE END — Clock Advances to 12:00 Noon】**

---

## 2. Tae Takemi Lv2 Script: *"Since You're Already Open, Let's Take a Closer Look"* (Fujino Asagami Arc)

### 2.0 Event Metadata (Codex Spec)
* **Event ID (Candidate)**: `ev_doc_takemi_lv2_fujino_laparotomy`
* **Title (EN)**: `Since You're Already Open, Let's Take a Closer Look`
* **Title (CN)**: `开都开了，多看两眼`
* **Primary Character**: Tae Takemi (`doc_takemi` / Special-Approval Lead Surgeon)
* **Special Story Patient**: Fujino Asagami (`patient_fujino` / Age 20, prestigious university student AU, long black-haired Yamato Nadeshiko suffering from intertwined congenital/acquired insensitivity to pain and a neglected, repeatedly perforated chronic appendicitis inflammatory mass)
* **Supporting Characters**: Asuka Shiromiya (`doc_asuka`), Miyuki Asakura (`nurse_yui` / Scrub Nurse), Takashi Sakaguchi (`player` / First Assistant)
* **Unlock Gate**:
  * `doc_takemi.level == 1`
  * `doc_takemi.familiarity >= 25` (naturally reached via 3–4 routine unanesthetized surgeries at `×1.50` multiplier)
  * `player.surgery >= 75`
  * Cooldown `>= 3` days after Lv1 completion
* **Trigger & Time Cost (Locked)**:
  * **Trigger Method**: **Auto-triggers at `09:00` on the next workday** after meeting the gate.
  * **Event Nature**: **Standalone Full-Day Fixed VN Scripted Surgery Event** (does not enter the regular or Advanced Surgery Runner, bypassing mandatory general anesthesia restrictions to stage the unanesthetized laparotomy and intraoperative pain awakening directly).
  * **Time Consumption**: **Occupies the entire workday (`09:00 -> 18:00`)**—covering morning Director approval and outpatient deep palpation, midday pre-op prep, an afternoon multi-hour awake laparotomy with live organ inspection and pain-awakening closure, and evening post-op rounds and basement drinks, advancing directly to `18:00` end-of-shift settlement.
* **Node Count (Verified)**: ID range `L2_001`–`L2_108`, defining **112** total text blocks (including 2 four-node lightweight branches), playing **108** individual nodes on a single playthrough.

---

### [Act 1: The Director's Three Warnings & the Painless Heiress (09:00 - 11:00)]

**【SCENE START】**
* **BGM (Candidate)**: `bgm_director_office_light`
* **BG (Candidate)**: `bg_director_office_day`

**[L2_001]**  
Narrator: Nine o'clock in the morning. Barely after clocking in for the day, a phone call from Tae Takemi summons me to the Director's Office. Behind her desk, young Director Asuka Shiromiya holds a referral chart, eyeing Takemi across from her with high alert.

**[L2_002]**  
* **Sprite (Candidate)**: `doc_asuka_coat_serious` (Left)  
* **Sprite (Candidate)**: `doc_takemi_coat_smile` (Right)  
Asuka Shiromiya: "I'm confirming this one last time, Dr. Takemi. This twenty-year-old university student, Ms. Fujino Asagami, had repeated perforations from chronic appendicitis masked by long-term insensitivity to pain, forming an extensive inflammatory mass in her right lower quadrant involving the ileocecal region, greater omentum, and right adnexa—and that is the *only* reason I'm granting special approval for you to lead the surgery with Dr. Sakaguchi as First Assistant."

**[L2_003]**  
Tae Takemi: "I know, I'm the one who screened her chart from outpatient yesterday. Sakaguchi's blade work is rock-solid now; with him across the table holding retractors and managing hemostasis, what could you possibly be worried about?"

**[L2_004]**  
Asuka Shiromiya: "The person I'm worried about is you! Listen carefully—First, perform the surgery normally."

**[L2_005]**  
Tae Takemi: "Naturally."

**[L2_006]**  
Asuka Shiromiya: "Second, no pulling junior nurses over for impromptu live anatomy lectures at the operating table."

**[L2_007]**  
Tae Takemi: "Asakura is assigned as scrub nurse today; she knows the anatomy as well as I do, so there's nothing to teach her."

**[L2_008]**  
* **Sprite (Candidate)**: `doc_asuka_coat_angry_blush`  
Asuka Shiromiya: "And third—**you are strictly forbidden from taking advantage of the patient's lack of pain to widen the surgical field and rummage around healthy organs!**"

**[L2_009]**  
* **Sprite (Candidate)**: `doc_takemi_coat_default`  
Tae Takemi: "..."

**[L2_010]**  
Asuka Shiromiya: "Why did you suddenly go silent?! Answer me! Dr. Sakaguchi, besides serving as First Assistant at the table today, your job is to keep a close eye on her hands for me!"

**[L2_011]**  
Takashi Sakaguchi: "Rest assured, Director. I'll make sure the operation is completed safely along standard anatomical planes."

* **BGM (Candidate)**: `bgm_clinic_calm`
* **BG (Candidate)**: `bg_examination_room_day`

**[L2_012]**  
Narrator: Leaving the Director's Office, Takemi and I head to Examination Room 1. Seated beside the exam table is a young woman with waist-length jet-black hair and a poised, gentle demeanor—Fujino Asagami.

**[L2_013]**  
* **Sprite (Candidate)**: `patient_fujino_casual_polite` (Center)  
Fujino Asagami: "Good morning, Dr. Takemi, Dr. Sakaguchi. I am deeply grateful to have two specialists scrubbing in together for my sake today."

**[L2_014]**  
Narrator: She inclines her head with a graceful smile, every gesture carrying the refined upbringing of an old-family heiress—giving zero hint that deep inside her right lower abdomen lies a suppurating, adherent mass severe enough to send an ordinary person into shock from pain.

**[L2_015]**  
* **Sprite (Candidate)**: `doc_takemi_coat_default` (Right)  
Tae Takemi: "Save the formalities, Ms. Asagami. We'll do one final pre-op abdominal palpation to confirm the margins—lie down on the exam table, unfasten your skirt waistband, and pull your sweater up above your chest."

**[L2_016]**  
* **Sprite (Candidate)**: `patient_fujino_casual_blush`  
Fujino Asagami: "Very well. Excuse me."

**[L2_017]**  
* **SFX (Candidate)**: `sfx_cloth_rustle`  
Narrator: Obediently lying flat on the examination table, Asagami rolls the hem of her knit sweater upward with slender fingers, baring a flat, toned waist and abdomen without an ounce of excess flesh.

**[L2_018]**  
Tae Takemi: "Put on a pair of gloves and feel this for yourself, Sakaguchi. With a right lower quadrant inflammatory mass of this size, an ordinary girl would scream and arch off the bed the instant your fingertips touched her skin."

**[L2_019]**  
Narrator: Snapping on exam gloves, I step up to the bedside, lay my palm gently over the cool skin of Asagami's right lower abdomen, and press all four fingers slowly and firmly deep into her abdominal cavity.

**[L2_020]**  
Narrator: Through the supple muscle layer of her abdominal wall, the pads of my fingers clearly meet a hard, unyielding mass tightly adherent to the surrounding bowel loops and pelvic wall. Yet the young woman lying beneath my hand doesn't even furrow her brow—only a faint blush creeps up the tips of her ears at the sensation of a man's hand pressing deep into her lower belly.

**[L2_021]**  
* **Sprite (Candidate)**: `patient_fujino_lying_blush`  
Fujino Asagami: "Mmn... Your hand is stronger than I imagined, Dr. Sakaguchi... I can feel your fingers sinking all the way into the deepest part of my stomach, pressing against that hard lump... It's just that I truly don't feel any pain at all."

**[L2_022]**  
Takashi Sakaguchi: "Precisely because your sensory pathways have been blocked for years, repeated bouts of appendicitis and perforation were registered by your body as mere mild bloating—allowing the inflammation to weld your ileocecal region, greater omentum, and the area around your right ovary and fallopian tube into a single mass."

**[L2_023]**  
Tae Takemi: "Moreover, based on the imaging review I did with Dr. Misono in Radiology, the dense scar tissue deep in your right lower quadrant is directly compressing the retroperitoneal nerve plexus—in other words, a large part of your current insensitivity to pain is actually being locked in place by this chronic lesion itself."

**[L2_024]**  
Fujino Asagami: "I see... No wonder I barely felt anything even when I sprained my ankle these past two years. Then regarding the method for this afternoon's surgery..."

**[L2_025]**  
* **Sprite (Candidate)**: `doc_takemi_coat_smile`  
Tae Takemi: "Just as we explained earlier, operating under general anesthesia would mask the critical threshold response of your nerve function; and since you feel no pain right now anyway, we'll perform an **unanesthetized laparotomy with zero anesthesia**. Do you have the nerve to sign?"

**[L2_026]**  
Fujino Asagami: "Since I don't feel pain to begin with, skipping anesthesia should be gentler on my body, shouldn't it? Only... I heard that once you sign Hoshimi Hospital's surgical consent form, you cannot cancel halfway through once you're on the operating table, even if you get scared?"

**[L2_027]**  
Takashi Sakaguchi: "That's right. Once you sign and enter the pre-op workflow, the operation will not stop until we've resected the lesion cleanly and sutured your abdomen back up."

**[L2_028]**  
* **Sprite (Candidate)**: `patient_fujino_casual_polite`  
Fujino Asagami: "I understand. Since I won't cry or make a fuss from pain anyway, I place myself in your hands, Dr. Takemi, Dr. Sakaguchi."

---

### [Act 2: "Is the Surgery Fee the Same?" & Painless Live Organ Inspection (12:00 - 14:30)]

* **BGM (Candidate)**: `bgm_or_heartbeat_slow`
* **BG (Candidate)**: `bg_operating_room_std`

**[L2_029]**  
Narrator: Twelve-thirty p.m. After Miyuki Asakura completes full skin prep, bowel cleansing, and indwelling urinary catheterization for Asagami in the ward, the stark-naked black-haired girl is wheeled into the operating room and positioned flat on the table directly beneath the shadowless lamp.

**[L2_030]**  
* **Sprite (Candidate)**: `nurse_yui_scrub_mask_smile` (Left)  
Miyuki Asakura: "Both arm restraints are secured, the Foley catheter is draining smoothly, and povidone-iodine prep across the abdomen and perineum is complete. From undressing and catheterization in the ward up till now, Ms. Asagami's heart rate has barely ticked up—such a sweet, obedient patient it almost makes my heart ache."

**[L2_031]**  
* **Sprite (Candidate)**: `patient_fujino_or_naked_blush` (Center)  
Fujino Asagami: "Because... even though I can't feel pain, lying here completely undressed while wide awake, with a tube between my legs and three medical staff looking down at me... is still deeply embarrassing..."

**[L2_032]**  
* **Sprite (Candidate)**: `doc_takemi_scrub_mask_smile` (Right)  
Tae Takemi: "Blushing proves your tactile and emotional responses are in great shape. Come on, Asakura, hand me a #20 scalpel; Sakaguchi, have dry gauze ready to brace both sides of the incision."

**[L2_033]**  
* **SFX (Candidate)**: `sfx_scalpel_incision_wet`  
Narrator: Once the sterile fenestrated drape is laid, Takemi doesn't hesitate for a split second, bringing the sharp blade steadily down just right of the midline across Asagami's flat, snow-white abdomen. Skin and pale-yellow subcutaneous fat part cleanly, and the bright red beads of blood that well up are immediately blotted away by my gauze.

**[L2_034]**  
Narrator: Next comes the electrocautery dividing the anterior rectus sheath, blunt separation of the deep-red rectus abdominis muscle belly, and lifting the translucent peritoneum to snip it open—the entire abdominal entry is executed with surgical perfection. Astonishingly, apart from a faint flutter of her eyelashes as the blade parted her skin, Asagami's breathing on the table remains completely steady.

**[L2_035]**  
Fujino Asagami: "Mmn... Just now I felt a cool blade gliding across my stomach, followed by the sensation of it parting to both sides... So this is what it feels like to have one's abdomen cut open? It really... doesn't hurt a bit."

**[L2_036]**  
* **Sprite (Candidate)**: `doc_takemi_scrub_mask_tease`  
Narrator: Above her surgical mask, Tae Takemi's eyes light up with startling intensity. Setting a Balfour self-retaining abdominal retractor into the wound, she ratchets the metal blades wide open with several clicks, laying Asagami's abdominal cavity generously bare beneath the shadowless lamp—then suddenly pauses her hands and looks down with a purring smile at the wide-awake girl:

**[L2_037]**  
Tae Takemi: "Say, Ms. Asagami. As you can see, your belly is now wide open, and you genuinely don't feel an ounce of pain."

**[L2_038]**  
Fujino Asagami: "Yes... Is something the matter, Dr. Takemi?"

**[L2_039]**  
Tae Takemi: "Since we've already opened you up and an opportunity like this comes once in a blue moon... before we resect that inflamed, adherent mess in your lower right side, how about we take a thorough, detailed look through all the other healthy organs inside your belly from top to bottom?"

**[L2_040]**  
Takashi Sakaguchi: "Hey, Takemi, did you already forget Item Three from Director Shiromiya this morning?"

**[L2_041]**  
* **Sprite (Candidate)**: `nurse_yui_scrub_mask_tease`  
Miyuki Asakura: "Hehe, I knew there was no way Dr. Takemi could resist going straight to business when presented with a patient this obedient who doesn't cry out in pain."

**[L2_042]**  
Narrator: Yet lying on the operating table, Fujino Asagami blinks her clear dark eyes and asks a question in dead earnest that freezes all three of us in our tracks:

**[L2_043]**  
* **Sprite (Candidate)**: `patient_fujino_or_polite_blush`  
Fujino Asagami: "Excuse me... if you inspect the rest of my insides along the way, will the surgery fee remain the same?"

**[L2_044]**  
* **Sprite (Candidate)**: `doc_takemi_scrub_mask_smile`  
Tae Takemi: "Pfft... Haha! Exactly the same—not a single yen extra. Consider it a complimentary full-course internal organ checkup courtesy of your lead surgeon."

**[L2_045]**  
Fujino Asagami: "If the fee is the same and I don't feel any pain anyway... then please do as you both see fit. Feel free to inspect as thoroughly as you like."

#### [Branch Point L2-A: Reacting to the Absurd Bargain]
* **Choice A1**: `"...With the patient herself giving her blessing that readily, I can hardly stop you on the Director's behalf."` -> Jump to **[L2_046A]**
* **Choice A2**: `"Let's be clear first: atraumatic manual inspection only, and don't drag out the operative time."` -> Jump to **[L2_046B]**

**[L2_046A]**  
Tae Takemi: "Hear that, Asakura? Even our First Assistant voted in favor. Bring over the warm sterile saline so we can wet our gloves first."

**[L2_047A]**  
Takashi Sakaguchi: "I just know that unless you get this out of your system first, you won't focus on dissecting the actual lesion."  
(Converge to **[L2_048]**)

**[L2_046B]**  
Tae Takemi: "Relax, don't you know my touch by now? I'll be ten times gentler than I was with that middle-school frog."

**[L2_047B]**  
Takashi Sakaguchi: "Don't bring up your middle-school frog in front of the patient—Ms. Asagami will take you seriously."  
(Converge to **[L2_048]**)

**[L2_048]**  
* **SFX (Candidate)**: `sfx_wet_glove_organ_touch`  
Narrator: With Asagami's express permission secured, Takemi drops all restraint. Dipping both gloved hands in warm saline, she reaches straight into the depths of Asagami's wide-open abdominal cavity—starting from the greater curvature of the stomach and transverse colon in the upper abdomen, lifting and turning over the rosy, living organs rising and falling with her breath inch by inch.

**[L2_049]**  
* **Sprite (Candidate)**: `patient_fujino_or_blush_gasp`  
Fujino Asagami: "Mmph...! Haah... W-Wait a moment, Dr. Takemi..."

**[L2_050]**  
Tae Takemi: "What is it? Does it hurt?"

**[L2_051]**  
Fujino Asagami: "N-No, it isn't pain... It truly doesn't hurt at all... Only, when your hands reach deep inside my stomach and lift my intestines up... there's an indescribable sinking, tugging sensation inside... as if my organs are about to be lifted right out of me... Nnh, haah..."

**[L2_052]**  
Narrator: Insensitivity to pain blocks sharp nociception, but leaves deep visceral proprioception and vagal traction reflexes intact. As Takemi's slick latex-gloved fingers run loop by loop along the small bowel mesentery toward the pelvis, fine beads of sweat break out across Asagami's pale forehead, her breathing growing rapid and shallow.

**[L2_053]**  
* **Sprite (Candidate)**: `doc_takemi_scrub_mask_tease`  
Tae Takemi: "Don't just stand there watching, Sakaguchi—put your hands in and help me cradle these loops of jejunum and ileum gently toward the upper left. Look at her left ovary and fallopian tube down here in the pelvis—completely untouched by the inflammation on the right, and such a lovely color."

**[L2_054]**  
Narrator: Following Takemi's lead, I slide both sterile-gloved hands into Asagami's warm, slick abdominal cavity, gently cradling her soft,蠕动ing loops of small intestine in my palms to sweep them aside—while Takemi's fingers glide down along the uterine fundus to the left adnexa, lightly rolling the healthy ovary and fimbriae between her fingertips.

**[L2_055]**  
* **Sprite (Candidate)**: `patient_fujino_or_moan_blush`  
Fujino Asagami: "Kyaa...! Mmn, nnh...! Dr. Sakaguchi... Dr. Takemi... Having four hands moving around inside my belly at the same time... f-feels way too strange...!"

**[L2_056]**  
Takashi Sakaguchi: "Bear with it a moment, Ms. Asagami. Right now my palms are supporting your small intestine while Dr. Takemi verifies your healthy left uterine adnexa."

**[L2_057]**  
Fujino Asagami: "Haah... I-I know you're examining me... Yet even though it doesn't hurt, why does having Dr. Sakaguchi's palms cradling my intestines while Dr. Takemi touches the deepest part of my lower belly... make my insides feel so heavy and achy that even my toes are going weak... Uu, it feels so weird... Every inch inside my stomach is being touched..."

**[L2_058]**  
Miyuki Asakura: "Hehe, your face is flushed as red as if you had a fever, Ms. Asagami. Even without pain, having the most private depths of a girl's belly felt over inch by inch by the lead surgeon and assistant carries a shame even stronger than pain."

**[L2_059]**  
Fujino Asagami: "Mmn... P-Please don't say it out loud, Nurse Asakura... I can even feel my intestines squirming against your palms inside my head... Are you not finished inspecting yet...?"

---

### [Act 3: Resection of the Mass, Sudden Pain Awakening & "Too Late for Anesthesia Now" (14:30 - 16:30)]

**[L2_060]**  
* **BGM (Candidate)**: `bgm_surgery_climax_intense`  
* **Sprite (Candidate)**: `doc_takemi_scrub_mask_serious`  
Tae Takemi: "Alright, I've had my fill of admiring the healthy parts—truly a gorgeous specimen of a body. —Time to get down to business. Sakaguchi, shift the retractors toward the right iliac fossa."

**[L2_061]**  
Narrator: Having satisfied her curiosity, Takemi's eyes turn hawk-sharp in an instant. Every trace of her languid playfulness vanishes, replaced by top-tier surgical dominance on par with Emiko Mido herself.

**[L2_062]**  
Narrator: Deep within Asagami's right lower quadrant, thick脓 cavities and granulation scars formed by years of silently perforating chronic appendicitis have encased the lower cecum, part of the greater omentum, and the ampulla of the right fallopian tube into a rock-hard inflammatory mass, with dense fibrous bands at its base pressing directly against the retroperitoneal nerve plexus.

**[L2_063]**  
Takashi Sakaguchi: "The right fallopian tube and ovary are only encased by inflammatory fibrous adhesions—the parenchyma itself isn't necrotic. With meticulous dissection, we can preserve her right adnexa completely and only resect the necrotic appendiceal base, the inflamed ileocecal tissue, and the involved omentum."

**[L2_064]**  
Tae Takemi: "Right in line with my thinking. I have no taste for lopping off a young girl's useful parts unnecessarily. Asakura, switch to fine dissecting forceps and bipolar cautery; Sakaguchi, hold traction on the right ovarian ligament for me and don't let it budge a millimeter."

**[L2_065]**  
* **SFX (Candidate)**: `sfx_cautery_bipolar_buzz`  
Narrator: Under the shadowless lamp, only the crisp slap of instruments and the soft sizzle of bipolar cautery remain. Takemi's blade moves with breathtaking speed and precision, navigating effortlessly through vascularized adhesion bands until Asagami's intact right ovary and fallopian tube are freed completely unscathed from the outer wall of the mass.

**[L2_066]**  
Fujino Asagami: "Mmn... The tugging deep in the right side of my stomach is getting heavier... Like a stone is being peeled off my flesh bit by bit... Haah, it still doesn't hurt, so please continue..."

**[L2_067]**  
Tae Takemi: "We're right at the deepest scar root compressing the nerve plexus. Sakaguchi, clamp the ileocecal mesenteric vessels and prepare to ligate and divide—"

**[L2_068]**  
Narrator: The moment I secure the double ligatures, Takemi's Metzenbaum scissors reach deep into the retroperitoneum, aligning squarely with the dense inflammatory root strangling the sensory nerve pathway, and snip cleanly all the way through—

**[L2_069]**  
* **SFX (Candidate)**: `sfx_cut_tissue_heavy`  
Narrator: *Snip.* The dark-red inflammatory mass that had tormented and locked away Fujino Asagami's bodily sensations for years is completely excised, dropping into the kidney dish in Asakura's hands.

**[L2_070]**  
Narrator: And in the exact same split second that the lesion separates from the retroperitoneal nerve plexus—

**[L2_071]**  
* **Sprite (Candidate)**: `patient_fujino_or_shock_wide`  
Fujino Asagami: "—Eh?"

**[L2_072]**  
Narrator: Asagami's brow, which had only been lightly knitted from traction, freezes abruptly as her pupils contract to pinpricks. The next instant, nociceptive signals dammed up for years surge like a bursting levee straight from her wide-open, oozing right lower abdominal cavity into her cerebral cortex!

**[L2_073]**  
* **BGM (Candidate)**: `bgm_crisis_alarm_fast`  
* **SFX (Candidate)**: `sfx_heart_monitor_rapid_beep`  
* **Sprite (Candidate)**: `patient_fujino_or_scream_tears`  
Fujino Asagami: "—KYAAAAAAAAAAAAAHHH—!!!"

**[L2_074]**  
Narrator: A piercing, pitch-shattered scream rips through the operating room! The poised heiress who had lain calmly while we turned her organs over in our hands a moment ago arches violently off the table, her wrists yanking the leather restraints with loud snaps as fat tears burst from her eyes!

**[L2_075]**  
Fujino Asagami: "IT HURTS!! IT HURTS SO MUCH—!! My stomach—why does my stomach suddenly feel like it's being burned with fire and sliced with knives?!! Uwaaaahhh—!!"

**[L2_076]**  
Takashi Sakaguchi: "Her heart rate just spiked to 130! Asakura, hold her shoulders down so her thrashing doesn't eviscerate the bowel loops through the incision! Excising that retroperitoneal mass just released the compression block on her nerve plexus—her sense of pain woke up right on the table!"

**[L2_077]**  
Fujino Asagami: "Dr. Takemi!! Dr. Sakaguchi!! I don't want to do this without anesthesia anymore!! It hurts—my belly is really cut wide open and it hurts so much!! Give me anesthesia... I'm begging you, please put me under general anesthesia right now!! Uwaaaahhh—!!"

**[L2_078]**  
* **Sprite (Candidate)**: `doc_takemi_scrub_mask_smile`  
Narrator: Faced with Asagami sobbing and screaming for anesthesia on the table, Tae Takemi doesn't show a trace of panic; instead, she straightens her back unhurriedly, her eyes crinkling into a smile above her mask:

**[L2_079]**  
Tae Takemi: "Congratulations, Ms. Asagami. It looks like the operation is a resounding success—not only did we clean out the rotten mass, we cured your insensitivity to pain along the way."

**[L2_080]**  
Fujino Asagami: "Uwaaaahhh I don't want congratulations right now!! It hurts to death... Even taking a single breath makes my insides cramp in agony!! Anesthesia... I'll pay extra right now if I have to, just please give me anesthesia and put me to sleep!!"

**[L2_081]**  
* **Sprite (Candidate)**: `doc_takemi_scrub_mask_tease`  
Tae Takemi: "Asking for anesthesia now? Too late for that, Ms. Asagami."

**[L2_082]**  
Tae Takemi: "The hardest resection steps are already finished. All that's left is irrigating the abdominal cavity clean with warm saline, checking for bleeders, and suturing your belly closed layer by layer. Even if we paged Chief Sakura to come intubate you for general anesthesia right now, by the time the drugs kicked in, Sakaguchi and I would already have tied off the final skin suture."

**[L2_083]**  
Fujino Asagami: "H-How could that be...?! Doesn't that mean I have to lie here wide awake enduring the pain of having my insides washed out and my stomach sewed up stitch by stitch until the very end?!"

#### [Branch Point L2-B: First Assistant Sakaguchi's Reassurance & Support]
* **Choice B1**: `Brace the edge of her abdominal wall to steady the incision: "We can't add general anesthesia now, but I'll work with Dr. Takemi to close your abdomen as quickly and smoothly as possible."` -> Jump to **[L2_084A]**
* **Choice B2**: `Say to Takemi: "Stop teasing her—she just got her sense of pain back with a full laparotomy wide open. Let's irrigate with warm saline right away."` -> Jump to **[L2_084B]**

**[L2_084A]**  
Fujino Asagami: "Uu... Dr. Sakaguchi... Even when your hand presses beside the incision, the sting of your glove brushing against the raw flesh is so vivid... Please hurry...!"

**[L2_085A]**  
Tae Takemi: "Hear that, Lead Surgeon? The young lady is rushing us—though we can't cut corners on debridement and irrigation; we have to wash her out nice and thoroughly so she doesn't get a post-op infection."  
(Converge to **[L2_086]**)

**[L2_084B]**  
Tae Takemi: "Feeling sorry for her already? Witnessing a painless patient regain her sense of pain right under your blade is a once-in-a-lifetime clinical moment."

**[L2_085B]**  
Takashi Sakaguchi: "A miracle for the surgeons, maybe, but pure torture for Ms. Asagami on the table. Asakura, hand me the warm saline and suction."  
(Converge to **[L2_086]**)

**[L2_086]**  
* **SFX (Candidate)**: `sfx_saline_irrigation_suction`  
Narrator: The next forty minutes become the young heiress's first true baptism of pain in her twenty years of life. As copious warm saline pours into her open abdominopelvic cavity to thoroughly irrigate the raw bed where the mass was dissected free, Asagami bites down hard on her lower lip, tears streaming endlessly down her temples into the edge of her surgical cap.

**[L2_087]**  
Fujino Asagami: "Mmn—!! Haah, ah... Th-The water is washing right over the raw wound inside my belly... It stings so much... Even when the suction tube draws the bloody water out, my insides are throbbing and cramping... uuu..."

**[L2_088]**  
Miyuki Asakura: "Good girl, hang in there just a little longer, Ms. Asagami. You didn't make a peep when we turned your whole belly inside out earlier, so being able to cry out in pain this loudly means your body is completely back to normal."

**[L2_089]**  
Narrator: Once irrigation is complete and we verify that her right adnexa and bowel loops are returned to their proper anatomical positions, Takemi and I begin closing the abdomen stitch by stitch, layer by layer. Every time the curved needle draws suture thread through the sensitive peritoneum, approximates the rectus sheath, and cinches a knot tight, Asagami's body tenses from the sharp piercing and pulling pain, letting out tearful gasps.

**[L2_090]**  
Fujino Asagami: "Ah...! Ow, that stitch pulled so tight... My stomach is being sewed shut one stitch at a time... Uu, I'm never believing 'skipping anesthesia is fine' ever again...!"

**[L2_091]**  
Tae Takemi: "Final subcuticular stitch—cut the thread. There, the wound edges are approximated beautifully. It won't even leave a scar."

---

### [Act 4: The Joy of Feeling Pain & the Underground Doctor's Approval (16:30 - 18:00)]

* **BGM (Candidate)**: `bgm_sunset_ward_warm`
* **BG (Candidate)**: `bg_ward_private_sunset`

**[L2_092]**  
Narrator: Five o'clock in the evening, post-operative observation ward. Thanks to Hoshimi Hospital's recovery guarantee, Fujino Asagami—who underwent a major laparotomy just hours ago—is already changed into a fresh hospital gown and propped up against the headboard, only a faint flush from her earlier crying bout lingering on her cheeks.

**[L2_093]**  
* **Sprite (Candidate)**: `patient_fujino_gown_blush` (Center)  
* **Sprite (Candidate)**: `doc_takemi_coat_default` (Right)  
Narrator: When Takemi and I push open the door for our final end-of-shift rounds, Asagami is looking down and gingerly prodding her right lower abdomen through the thin gauze dressing with her fingertip—immediately sucking in a sharp *hiss* of breath.

**[L2_094]**  
Takashi Sakaguchi: "Stop poking at your incision—it was just sutured closed, so of course it still hurts."

**[L2_095]**  
* **Sprite (Candidate)**: `patient_fujino_gown_smile_tears`  
Fujino Asagami: "I am so sorry, Dr. Sakaguchi, Dr. Takemi... Screaming and crying so ungracefully on the operating table at the end, and begging you relentlessly for anesthesia... I made a complete spectacle of myself in front of you both."

**[L2_096]**  
Tae Takemi: "No need to apologize. If you hadn't made a sound right after I freed the compression on your retroperitoneal nerve plexus with your belly still wide open, that would've meant my surgery failed."

**[L2_097]**  
Narrator: Lowering her eyelashes, Asagami rests both hands gently over her lower abdomen. Crystal tears well up at the corners of her eyes once more, yet her lips curve into a smile of unmistakable warmth:

**[L2_098]**  
Fujino Asagami: "Truthfully... after returning to the ward and calming down, feeling this steady, throbbing ache beneath my fingers feels almost miraculous to me."

**[L2_099]**  
Fujino Asagami: "Before today, no matter how badly my insides were festering, it felt like I was living behind a pane of frosted glass, unable to feel a thing. On the operating table earlier it hurt terribly, and the two of you inspected every inch inside my stomach... yet being able to feel pain like an ordinary girl, and having Dr. Sakaguchi scold me gently not to poke my incision, makes me feel from the bottom of my heart that I am truly alive."

**[L2_100]**  
Takashi Sakaguchi: "Your right ovary and fallopian tube were preserved completely intact, and the inflammatory mass is gone for good. Get a good night's sleep tonight, and you'll be free to walk around normally tomorrow."

**[L2_101]**  
Fujino Asagami: "Yes. Thank you both from the bottom of my heart."

* **BGM (Candidate)**: `bgm_underground_lab_lazy`
* **BG (Candidate)**: `bg_hospital_corridor_evening`

**[L2_102]**  
Narrator: By the time we step out of the ward, six-o'clock twilight has settled outside the windows. Hands tucked into the pockets of her white coat, Tae Takemi strolls unhurriedly beside me down the corridor leading to the basement stairs.

**[L2_103]**  
* **Sprite (Candidate)**: `doc_takemi_coat_smile` (Center)  
Tae Takemi: "Phew... Now that was a fulfilling full day's work. We got to inspect a living abdominopelvic cavity in peace during the first half, and heard such a lively scream in the second."

**[L2_104]**  
Takashi Sakaguchi: "It's a good thing Ms. Asagami is good-natured. Any other patient who found out you threw in a 'complimentary full-abdominal manual inspection' while she couldn't feel pain would march straight into the Director's Office to report you before discharge."

**[L2_105]**  
* **Sprite (Candidate)**: `doc_takemi_coat_tease`  
Tae Takemi: "If she reports me, the First Assistant who had both hands inside her belly cradling her small intestine for me is an accomplice—there's no escaping for you either."

**[L2_106]**  
Narrator: Stopping at the top of the basement stairs, she turns to look at me, a rare glint of genuine approval shining in her usually languid, teasing eyes:

**[L2_107]**  
Tae Takemi: "Seriously though, Sakaguchi... when her pain suddenly came back and she started thrashing on the table, an ordinary assistant would have lost his head—yet you braced the incision to protect her bowel loops with one hand while matching my pace through irrigation and closure without missing a beat."

**[L2_108]**  
Tae Takemi: "In all my time at Hoshimi Hospital, you're the first man I've met who can keep up with my rhythm this comfortably. ...Come on, after a full day on our feet, come down to my lab for a drink—consider it a treat from your lead surgeon."

**【SCENE END — Full-Day Event Complete, Advances to 18:00 End-of-Shift Settlement】**

---

## 3. QA & Engineering Verification Checklist (V1.2 Final Revision)

| Verification Item | V1.2 Locked Specification |
| :--- | :--- |
| **P1-1 Branch Jump Fix** | Removed premature convergence markers after `L1_020A/B`, `L2_046A/B`, and `L2_084A/B`; each branch plays its paired `L1_021A/B`, `L2_047A/B`, and `L2_085A/B` node before converging to the main line. |
| **P1-2 Float vs. Integer Pacing Calculation** | Explicitly distinguished: in integer mode, `8 + 2 = 10` (1 unanesthetized surgery + 1 basement chat reaches Lv1); in float mode, `7.5 + 1.6 = 9.1 < 10`, requiring an extra interaction or a 2nd surgery to reach Lv1. |
| **P1-3 Lv0 Trigger Timing Alignment** | Updated to "triggers upon the successful settlement of the next valid unanesthetized surgery after all prerequisite conditions (≥20 unanesthetized surgeries, 5 ghost stories, `Clinical Presence ≥ +60`, `Professional Reputation ≥ 200`) are met." |
| **Lv1 / Lv2 Trigger Entry & Duration** | • **Lv1**: Auto-triggers at `09:00` on the next workday once `Familiarity >= 10` is met; standalone scripted surgery, **3-hour duration** (`09:00 -> 12:00`).<br>• **Lv2**: Auto-triggers at `09:00` on the next workday once `Familiarity >= 25`, `Surgery >= 75`, and `>= 3` days cooldown after Lv1 are met; standalone full-day scripted surgery, **occupies full workday (`09:00 -> 18:00`)**. |
| **Node Count** | • **Lv1**: Range `L1_001`–`L1_042`, **44** total text blocks defined, **42** nodes played per single playthrough.<br>• **Lv2**: Range `L2_001`–`L2_108`, **112** total text blocks defined, **108** nodes played per single playthrough. |