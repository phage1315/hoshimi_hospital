# Saber Lv4 SFW CG integration — 2026-11-16

Five approved images copied byte-for-byte to assets/events/artoria_lv4_cg_v1/. Riverside and living-room use v2; kitchen, breakfast and croquette use v1. 22 nodes mapped with contain fit and 2-second initial reveal. Living-room v2 is the gallery cover. All non-CG node fields compared equal before/after; no dialogue or choices edited.

Validation actually executed:
- python3 tools/artoria_lv4_source_audit.py: 24929 checks, zero failures.
- python3 tools/narrative_localization_test.py: 54962 checks, zero failures.
- python3 tools/localization_audit.py: 90366 translations; all active authored/UI keys covered.
- .venv/bin/python tools/validate_data.py: FAIL, full report attached; includes schema/time-window/hidden-portrait errors outside this target. No artoria/ar4-labelled errors. Not claimed globally clean.
- Godot 4.5.1 headless editor import: exit 0, five .import files created; environment certificate/editor-settings-write errors logged.
- Godot --headless --script res://tools/artoria_lv4_test.gd: 6048 checks, zero failures after updating test to traverse the newly enabled gallery reward page. Certificate/ObjectDB warnings remain.
- Static five-resource / 22-node / cover check passed; git diff --check passed for touched tracked files.

No native-window visual QA performed this round. Existing player saves untouched. No commit/push.
