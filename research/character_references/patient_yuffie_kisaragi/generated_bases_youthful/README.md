# Yuffie Kisaragi — youthful SFW base portrait candidates

This set is mapped into the patient bundle following the user's approval of the outpatient, ward, operating-table, and anesthetized portraits. The intraoperative tense portrait was regenerated to follow the user's bare-shoulder instruction and is mapped as well.

## Style direction

Use the three user-provided Yuffie seed images as identity and style references: youthful, bright, playful anime look; soft youthful facial proportions; large expressive brown eyes; athletic slim-average build; avoid mature/glamorous styling. Keep the white-and-green headband for outpatient; remove it for ward and all OR states. OR states use a teal surgical cap.

## Candidate set

| Runtime key | Candidate | Target class |
|---|---|---|
| `outpatient/neutral` | `outpatient_neutral_candidate.png` | 1024×1536 PNG, transparent cutout, headband retained |
| `ward/neutral` | `ward_neutral_candidate.png` | 1024×1536 PNG, transparent cutout, light-blue gown, no headband |
| `operating_table/awake` | `operating_table_awake_candidate.png` | 1448×1086 PNG, overhead supine OR, cap, opaque drape |
| `intraoperative/tense` | `intraoperative_tense_candidate.png` | 1448×1086 PNG, transparent head-and-shoulders, cap |
| `intraoperative/anesthetized` | `intraoperative_anesthetized_candidate.png` | 1448×1086 PNG, transparent head-and-shoulders, cap, eyes closed |

The corrected tense portrait is `intraoperative_tense_bare_shoulders_candidate.png`; it has bare shoulders and no clothing visible in frame.

Full-screen anesthesia CGs and dependent expression variants are outside this base-candidate batch.

## Review and verification status

The first pass was visually too mature and is retained separately in `../generated_bases/` for provenance. The youthful pass addresses the user's style feedback. Dimensions and PNG alpha-channel presence were checked. Runtime texture loading was not tested because Godot is unavailable in this environment. `intraoperative/pain` and `intraoperative/near_collapse` remain unmapped; these dependent expression variants were outside this base-portrait request.
