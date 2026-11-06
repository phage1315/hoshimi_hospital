# Advanced OR Team Dialogue V2 — UI Polish P1 / backfill verification

## Scope

- Six older procedures load authored V2 sidecars from `data/advanced_surgery/dialogue_v2/`; their V1 JSON files remain unchanged and are available as fallback. The original ZIP is preserved in `docs/source_materials/advanced_team_dialogue_v2_backfill_v1/author_package.zip`.
- The surgery view owns one persistent compact dialogue toolbar. Dialogue Continue is 120×42; Autoplay, Skip, and Dialogue log are secondary controls. Skip is disabled when the current dialogue phase is exhausted. The toolbar is outside the operation card container.
- Result acknowledgement is a compact single line plus Continue. F/L/S/P action handlers, probabilities, timings, roles, and crisis choices were not changed.

## A. Source and bilingual audit

- `python3 tools/import_advanced_team_dialogue_v2_backfill.py --check`: 6 procedures, 73 stages, 292 bilingual lines; PSV rows match imported JSON in order, role, Chinese and English text. V1 files unchanged.
- `python3 tools/narrative_localization_test.py`: 30,756 checks, 0 failures.
- `python3 tools/localization_audit.py`: 47,313 translations audited; 796/796 referenced English UI keys translated, no hard-coded Chinese candidates.

## B. Godot headless regression

- `advanced_v2_backfill_test.gd`: 1,447 checks, 0 failures. Covers all stages, dialogue order, role binding, V1 P failure feedback, phase skip, and no action state change.
- `advanced_petra_test.gd`: 570 checks, 0 failures.
- `advanced_petra_ui_test.gd`: 33 checks, 0 failures. Includes toolbar persistence, compact result, English rendering, and Autoplay stopping before the next operation.
- `advanced_izumi_misa_test.gd`: 1,022 checks, 0 failures.

## C. Visible Godot rendering

Ran Godot 4.5.1 with an OpenGL/Metal window and `advanced_petra_ui_test.gd -- --native`: 48 checks, 0 failures. This driver uses in-memory appointments and programmatic button signals; it is a visible rendering and scene-path check, not a manual mouse-input playthrough. Screenshots were visually reviewed:

- `t01_dialogue_toolbar.png`: Chinese dialogue and compact toolbar.
- `t01_action_after_skip.png`: action remains available after Skip; Skip is disabled.
- `t01_result_compact.png`: result line and one compact Continue.
- `t02_incision.png`: operative field and team line.
- `t02_english.png`: English line and English toolbar labels.

## D. Remaining coverage and assets

- The visible-window driver covers Petra T01/T02 in Chinese and T02 in English. It does not play all six backfilled procedures from booking through discharge, or exercise their possible crisis branches with physical OS input.
- This change imports dialogue only; it adds no patient art. Existing asset readiness and formal release flags for each procedure remain governed by their own data.
- Older broad UI test scripts for the original Whipple and three-case content assume an anesthesia splash that the current presentation may omit when its asset is unavailable; they are not counted as passing regression evidence here.

No player save was written. The driver points save handling at an unused `/tmp` path and prepares the appointment only in memory.
