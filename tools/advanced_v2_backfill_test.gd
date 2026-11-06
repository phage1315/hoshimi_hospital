extends SceneTree
const D = preload("res://godot/systems/advanced_operative_dialogue.gd")
const M = preload("res://godot/systems/advanced_surgery_model.gd")
const S = preload("res://godot/systems/advanced_surgery_session.gd")
const P = preload("res://godot/systems/advanced_presentation.gd")
const IDS := [
	"surgery_open_whipple",
	"surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction",
	"surgery_adv_sleeve_lobectomy",
	"surgery_adv_ebstein_cone_reconstruction",
	"surgery_adv_complex_abdominal_reconstruction",
	"surgery_adv_open_descending_thoracic_aortic_replacement",
]
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("run")
func check(ok: bool, reason: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(reason)

func run() -> void:
	var stages := 0
	var lines := 0
	for procedure_id in IDS:
		var definition: Dictionary = M.procedure(procedure_id)
		var overlay_path := "res://data/advanced_surgery/dialogue_v2/%s.json" % procedure_id
		var overlay: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(overlay_path))
		var legacy := D.new(procedure_id, 0, false)
		var adapter := D.new(procedure_id)
		check(legacy.data.get("schema_version") == "advanced_day2_dialogue_v1", "V1 remains readable: " + procedure_id)
		check(D.valid(overlay, definition), "V2 overlay validates: " + procedure_id)
		check(D.valid(adapter.data, definition) and adapter.data.schema_version == "advanced_day2_dialogue_v2", "V2 selected: " + procedure_id)
		check(not adapter.data.stages[definition.steps[0].id].has("stage_entry"), "V1 stage entry not duplicated")
		var fixtures: Array = M.fixtures(procedure_id)
		var values: Dictionary = fixtures[0] if not fixtures.is_empty() else M.fixtures("surgery_open_whipple")[0]
		stages += definition.steps.size()
		for index in range(definition.steps.size()):
			var stage_id := str(definition.steps[index].id)
			var source: Dictionary = overlay.stages[stage_id]
			var active: Dictionary = adapter.data.stages[stage_id]
			var probe := S.new(definition, values, 17, [], {}, true)
			probe.index = index
			probe.operative_dialogue = D.new(procedure_id)
			var before: Array = source.before_action
			var after: Array = source.after_resolution
			lines += before.size() + after.size()
			check(before.size() + after.size() >= 3 and before.size() + after.size() <= 5, "3–5 lines: " + stage_id)
			if definition.steps[index].kind == "P":
				check(active.precision_failed == legacy.data.stages[stage_id].precision_failed, "V1 Precision feedback preserved: " + stage_id)
			for offset in range(before.size()):
				var row: Dictionary = probe.operative_dialogue.current(probe)
				check(row == before[offset] and row == probe.operative_dialogue.current(probe), "Stable pre-action line: " + stage_id)
				check(not D.bind_role(str(row.speaker_role), P.DEFAULT_TEAM).is_empty(), "Pre-action speaker bound: " + stage_id)
				check(probe.operative_dialogue.advance_sequence(probe), "Advance pre-action line: " + stage_id)
			check(probe.operative_dialogue.current(probe).is_empty(), "Pre-action sequence exhausted: " + stage_id)
			probe.awaiting_ack = true
			probe.last_result = {"failed": false}
			for offset in range(after.size()):
				var row: Dictionary = probe.operative_dialogue.current(probe)
				check(row == after[offset], "Stable after-action line: " + stage_id)
				check(not D.bind_role(str(row.speaker_role), P.DEFAULT_TEAM).is_empty(), "After-action speaker bound: " + stage_id)
				check(probe.operative_dialogue.advance_sequence(probe), "Advance after-action line: " + stage_id)
			check(probe.operative_dialogue.current(probe).is_empty(), "After-action sequence exhausted: " + stage_id)
			check(probe.operative_dialogue.history.size() == before.size() + after.size(), "All displayed lines logged once: " + stage_id)
			var skip_probe := S.new(definition, values, 17, [], {}, true)
			skip_probe.index = index
			skip_probe.operative_dialogue = D.new(procedure_id)
			check(skip_probe.operative_dialogue.skip_sequence(skip_probe) == before.size(), "Skip only current pre-action phase: " + stage_id)
			check(skip_probe.operative_dialogue.current(skip_probe).is_empty(), "Skip does not execute stage: " + stage_id)
			check(skip_probe.index == index and not skip_probe.awaiting_ack, "Skip preserves action state: " + stage_id)
	check(stages == 73 and lines == 292, "Author package totals")
	print("ADVANCED V2 BACKFILL: ", checks, " checks / ", failures, " failures; ", stages, " stages, ", lines, " bilingual lines")
	quit(1 if failures else 0)
