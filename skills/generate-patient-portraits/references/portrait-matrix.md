# Ordinary patient SFW portrait inventory

Use 高卷杏 (`data/patients/patient_ann/patient.json`) as the concrete reference inventory and inspect the actual images named below. Its 20 generated keys are a **reference set**, not a rule that every patient must have identical keys. Before each patient batch, derive that patient's checklist from the live runtime consumers, enabled surgery/anesthesia branches, patient type, and already-accepted assets. Keep a key when a real current consumer or an explicitly planned reachable branch needs it; do not generate unrelated keys just to match a count. Conversely, the user's preference is to avoid omissions where a real consumer exists, so do not omit a needed expression merely because it is not reached in the initial happy path.

Every listed key maps to `bundle.patient.visuals.portraits[<runtime key>]`. For every checklist row record: runtime key, purpose and consumer, class-specific framing/pose, state/difference rule, final file format/dimensions, acceptance evidence, and omission decision. The inventory below supplies these fields via its consumer/decision columns plus the referenced class specification; copy the concrete target values into the per-patient review record. If the runtime schema or caller differs from this inventory, trust the current implementation and update the checklist before generation.

## Runtime keys and expressions

Each row is one distinct standalone image. Use the corresponding reference path for framing and state; expression wording distinguishes states but does not authorize changing pose or camera.

| Runtime key | Consumer / purpose | State and difference from sibling keys | Include / omit decision |
|---|---|---|
| `outpatient/neutral` | `app.gd:add_portrait()`; outpatient/clinic presentation and any consumer requesting outpatient neutral. Reference: `outpatient/neutral.png`. | Single natural neutral-friendly daily-clothes pose; it is the base, not a state-difference set. | Include when the patient can appear in outpatient UI (ordinary patients: yes). Omit only if the patient type has no such runtime presentation. |
| `ward/neutral` | `app.gd:add_portrait()` fallback when a requested ward state is missing; patient portrait preview/default. Ref: `ward/neutral.png`. | Calm/natural base of the six-state ward set; not the anxiety-zero expression (that consumer requests `ward/smile`). | Include when ward portraits or patient preview are reachable; ordinarily yes. |
| `ward/smile` | Same ward consumer; selected at anxiety 0. Ref: `ward/smile.png`. | Gentle smile; keep pose/clothes/crop identical to neutral. | Include when ward flow is reachable; don't drop merely because another state is the common seed. |
| `ward/brave` | Same ward consumer; selected at anxiety 1. Ref: `ward/brave.png`. | Determined, trying to stay calm; visibly distinct from smile. | Include when ward flow is reachable. |
| `ward/worried` | Same ward consumer; selected at anxiety 2. Ref: `ward/worried.png`. | Worried, brows/eyes tense; distinct from afraid. | Include when ward flow is reachable. |
| `ward/afraid` | `app.gd:add_portrait()` and patient portrait preview; preserve for any authored/runtime caller requesting `ward/afraid`. Ref: `ward/afraid.png`. | Clear fear; stronger than worried, no pose change. The current generic ward anxiety mapper selects `crying` at anxiety ≥3, so do not claim `afraid` is that automatic state. | Default: retain as part of the 高卷杏 reference set and preview. Omit only if the user explicitly requests a reduced set after checking all callers; omission is not recommended while preview or authored callers use it. |
| `ward/crying` | Same ward consumer; selected at anxiety ≥3. Ref: `ward/crying.png`. | Visible tears/crying; retain all shared ward geometry and attire. | Include when ward flow is reachable. |
| `operating_table/awake` | `preop_view.gd:operating_table_outfit()` + `expression_for_patient()`; fallback/default OR positioning portrait. Ref: `operating_table/awake.png`. | Awake, eyes open; supine overhead table composition. | Include for any patient entering OR. Required fallback even if surgeries often use lithotomy. |
| `operating_table/tense` | Same OR consumer; selected for awake/tense response. Ref: `operating_table/tense.png`. | Awake with tense expression; preserve supine pose and camera. | Include for any patient entering OR. |
| `operating_table/afraid` | Same OR consumer; selected when fear/pain/cooperation crosses runtime threshold or procedure mismatch. Ref: `operating_table/afraid.png`. | Awake and afraid; distinguish from tense. | Include for any patient entering OR. |
| `operating_table/anesthetized` | Same OR consumer; selected when `prep.flags` has `anesthetized`. Ref: `operating_table/anesthetized.png`. | Eyes closed, relaxed, no mask; supine pose unchanged. | Include if general anesthesia can reach the OR (normally yes). |
| `operating_table_lithotomy/awake` | `preop_view.gd:operating_table_outfit()` when surgery `positioning.primary_position == lithotomy`; also patient preview selector. Ref: `operating_table_lithotomy/awake.png`. | Awake in overhead lithotomy setup with supported flexed/separated legs. | Include if any reachable assigned surgery uses lithotomy; otherwise omit only after checking actual surgery data and runtime preview needs. |
| `operating_table_lithotomy/tense` | Same lithotomy consumer, tense state. Ref: `operating_table_lithotomy/tense.png`. | Awake and tense; geometry identical to lithotomy awake. | Same gate as lithotomy awake; do not omit only this expression when lithotomy is supported. |
| `operating_table_lithotomy/afraid` | Same lithotomy consumer, afraid/mismatch state. Ref: `operating_table_lithotomy/afraid.png`. | Awake and afraid; geometry identical to other lithotomy states. | Same gate as lithotomy awake; retain if any lithotomy branch can reach fear/mismatch. |
| `operating_table_lithotomy/anesthetized` | Same lithotomy consumer, anesthetized state. Ref: `operating_table_lithotomy/anesthetized.png`. | Eyes closed, relaxed, no mask; geometry identical to other lithotomy states. | Same gate as lithotomy awake; retain if lithotomy can combine with general anesthesia. |
| `intraoperative/tense` | `preop_view.gd:intraoperative_patient_expression()` → intraoperative head-and-shoulders UI. Ref: `assets/characters/intraoperative_portraits_v1/patient_ann/tense.png`. | Awake under anesthesia/operative branch; tense face. | Include if intraoperative patient portrait UI is enabled/reachable; check current setting. |
| `intraoperative/pain` | Same consumer; awake/no-anesthesia branch before near-collapse threshold. Ref: `assets/characters/intraoperative_portraits_v1/patient_ann/pain.png`. | Clear pain expression, no wound or blood; distinct from tense. | Include if the no-anesthesia branch is reachable and portrait UI is enabled; don't omit if that route is in scope. |
| `intraoperative/near_collapse` | Same consumer; later no-anesthesia flow steps. Ref: `assets/characters/intraoperative_portraits_v1/patient_ann/near_collapse.png`. | Exhausted, near limit; visibly distinct from pain but no injury depiction. | Include if the no-anesthesia flow can reach its late steps and portrait UI is enabled. |
| `intraoperative/anesthetized` | Same consumer when the patient is anesthetized. Ref: `assets/characters/intraoperative_portraits_v1/patient_ann/anesthetized.png`. | Eyes closed, relaxed; no mask/tube. | Include if anesthetized intraoperative UI is reachable; normally yes when surgery is supported. |
| `splash/general_anesthesia` | `app.gd:show_anesthesia_splash()` after `induction_reassure` / `induction_brief`. Ref: `assets/events/anesthesia_v1/patient_ann/general.png`. | Post-induction scene: eyes closed, mask/tube visible. | Include if general anesthesia induction is reachable. Do not use it as the pre-induction key. |

The file format/dimensions, composition/pose, cross-state difference locks, and per-image acceptance for each row are defined by its class below. The per-patient checklist must cite that class and record the actual check result for each key; a class-level pass does not automatically pass every individual image.

Separate supplied portrait, not part of these generated keys: `examination/shy`.

Runtime-consumed conditional additions, not part of 高卷杏's 20-key generated reference set:

- `splash/general_anesthesia_pre_induction` is an **optional** patient-specific full-screen CG that can display at `choose_general` before induction if explicitly configured. Reference: `assets/events/anesthesia_v1/patient_rie/general_pre_induction.png` (actual `1536×960 PNG`, RGB/full scene). Its consumer being reachable does not make it required; omit by default and never count it as a missing SFW portrait.
- `splash/epidural_anesthesia` is an **optional** patient-specific full-screen CG that can display at `choose_epidural` if explicitly configured. Reference: `assets/events/anesthesia_v1/patient_emi/epidural.png` (actual `1536×1024 PNG`, RGB/full scene). Its consumer being reachable does not make it required; omit by default and never count it as a missing SFW portrait.
- `examination/shy` is a separately supplied transparent examination portrait, not an ImageGen deliverable in this workflow and not a full-screen examination CG.

These keys are not automatically required for every patient. If their consumer is reachable and they are not included, record the reason (for example, branch disabled by the patient's actual contract); do not silently classify an existing runtime consumer as nonexistent.

## Output specifications

| Class | Count | Final target | Reference framing and clothing/coverage |
|---|---:|---|---|
| Outpatient | 1 | `1024×1536 RGBA`, actual transparency | Single standing portrait, head through thigh/knee crop; no scene/background. User-approved daily clothes. |
| Ward | 6 | `1024×1536 RGBA`, actual transparency | Same standing pose, head through thigh/knee crop, arms relaxed. Light-blue wrap hospital gown with side ties, wide sleeves, shoulders covered; no surgical cap. Change expression only. |
| Supine operating table | 4 | `1448×1086 RGB`, full background | Overhead 4:3 full-table view; pillow/head at top, feet at bottom, arms/hands and legs visible. Teal surgical cap; opaque teal drape covers chest, abdomen, pelvis, thighs, while shoulders/collarbones remain visible. No gown or mask. |
| Lithotomy operating table | 4 | `1448×1086 RGB`, full background | Overhead 4:3 complete table; flexed, separated legs supported by black padded leg rests; lower legs/feet toward bottom. Opaque drape covers chest through pelvis and inner thighs; only reference-consistent lower legs/feet exposed. No perineal view or exam action. |
| Intraoperative portrait | 4 | `1448×1086 RGBA`, actual transparency | Frontal head-and-shoulders, cap, face, neck, shoulders and collarbones visible; crop below collarbones before breasts. No bed, tools, background, drape or gown neckline. |
| General-anesthesia splash | 1 | `1672×941 RGB`, full background | Near-16:9 operating-room head/upper-torso view, patient centered on pillow, cap, mask over nose/mouth and tube extending right; opaque drape covers chest/lower frame, shoulders/collarbones remain visible. |

Known historical exception: `patient_ann` `intraoperative/anesthetized` is `1343×1171 RGBA`; newer comparison patients use `1448×1086 RGBA`. New outputs use the table's standardized target; do not alter historical files as part of a new patient's generation.

## Class-specific visual constraints

- **Outpatient:** vertical medium portrait, not a headshot and not full-body distant framing; full head with headroom and crop around thigh/knee. No floor, scene, halo, lettering, border, or UI.
- **Ward:** six images share identity, scale, stance, crop, clothing, and background. Only face/gaze and appropriate tears/tension vary.
- **Supine table:** table runs vertically through the frame, viewed from above. Keep pillow, both arms/hands, draped torso/legs, lower legs/feet, and operating-room context visible. Draping begins around upper chest/near armpits, not up at the neck. Hair is contained under the cap; do not carry daily bows/braids over the chest.
- **Lithotomy table:** use its own real lithotomy reference, not an imagined adaptation of the supine image. Match leg supports, feet, body scale and perspective. No low camera from between the legs.
- **Intraoperative portrait:** head centered and dominant, cap fully shown, shoulders extend to lower sides. Keep silhouette/scale consistent across four states. Anesthetized portrait has no mask/tube.
- **Splash:** the mask and breathing tube belong here; it is a complete scene, not a transparent portrait or distant full-body shot. Hair outside the cap in the reference is a splash-specific exception.

## Required review record

For each key, record purpose and actual runtime consumer, include/omit decision and reason, actual reference path(s), prompt/input roles, output path, dimensions, color mode, alpha findings for RGBA, SHA-256, and a visual pass/fail. Open the generated image and compare it with its same-class reference. For RGBA, inspect actual alpha and composite on light and dark backgrounds; a black preview alone proves neither transparency nor opacity. Check distinctions between neighboring expressions and inspect required body framing/coverage on table scenes. Only accepted assets may be added to runtime mappings. A missing needed key is a documented incomplete item, not a completed substitute or a reason to invent a different asset.

### Per-item acceptance gates

- **Every listed key:** confirm the target bundle contains the exact key/path; the path exists, decodes to a texture, and is reached by the named consumer. Open the final image and check identity, class framing and content. Verify the mapping is locale-independent. Record a key-specific pass/fail rather than inheriting a class-level pass.
- **Outpatient and ward:** render with the target patient's UI consumer. Compare crop, scale, pose and attire across ward states; verify expression separation (neutral/smile/brave/worried/afraid/crying) without geometry or clothing drift. Exercise dynamic ward expressions with `expression_for_patient()` for their reachable anxiety states and check fallback behavior if any key is deliberately absent.
- **Supine and lithotomy tables:** render the selected key for the relevant surgery positioning and state. Confirm all state variants preserve camera, anatomy-safe coverage, limbs, supports, table and equipment; check the lithotomy fallback does not hide a required supported lithotomy set.
- **Intraoperative portraits:** exercise tense, pain, near-collapse and anesthetized mappings from `intraoperative_patient_expression()` only for reachable branches. Compare all four head/shoulder crops and confirm no state adds a mask, injury, blood or scene background.
- **Anesthesia splashes:** invoke the exact action (`choose_general`, `induction_reassure`/`induction_brief`, or `choose_epidural`) and inspect the actual overlay texture. Confirm pre-/post-induction distinction and patient identity; a valid texture that never dispatches at the action is not accepted.
- Run focused patient bundle / portrait / preop tests that cover the changed consumer. Do not run unrelated CG-pool tests for a portrait-only batch. If Godot or the relevant test harness is unavailable, complete static path/key/texture checks and say runtime rendering remains unverified.
