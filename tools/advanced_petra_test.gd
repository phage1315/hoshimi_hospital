extends SceneTree
const M = preload("res://godot/systems/advanced_surgery_model.gd")
const S = preload("res://godot/systems/advanced_surgery_session.gd")
const D = preload("res://godot/systems/advanced_operative_dialogue.gd")
const Physiology = preload("res://godot/systems/advanced_physiology.gd")
const R = preload("res://godot/systems/advanced_referral_rules.gd")
const ID := "surgery_adv_posttraumatic_thoracolumbar_kyphosis_correction"
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func run() -> void:
	var definition := M.procedure(ID)
	check(not definition.is_empty(), "Petra procedure registered")
	check(R.procedure_ready(ID), "Completed three-stage artwork admits Petra procedure")
	var story: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/stories/%s.json" % ID))
	var portraits: Dictionary = story.patient.visuals.portraits
	for key in ["ward", "postop", "team_confirmation", "intraoperative/anesthetized", "splash/general_anesthesia"]:
		var texture: Variant = load("res://" + str(portraits[key]))
		check(texture is Texture2D and texture.get_width() > 0 and texture.get_height() > 0, "Petra portrait loads: " + key)
	var field: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/field_windows.json"))[ID]
	for key in ["incision_path", "path", "closure_path"]:
		var field_texture: Variant = load("res://" + str(field[key]))
		check(field_texture is Texture2D and field_texture.get_width() > 0 and field_texture.get_height() > 0, "Petra field texture loads: " + key)
	var rows: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/dialogue_v2/%s.json" % ID))
	check(D.valid(rows, definition), "V2 content accepted")
	check(not FileAccess.file_exists("res://data/advanced_surgery/dialogue/%s.json" % ID), "Petra has no legacy V1 file")
	check(D.new(ID).data == rows, "V2-only Petra dialogue loads from the shared V2 directory")
	var old_id := "surgery_adv_open_descending_thoracic_aortic_replacement"
	var old := D.new(old_id, 0, false)
	check(not old.data.is_empty() and old.data.schema_version == "advanced_day2_dialogue_v1", "Old V1 remains valid")
	var team: Dictionary = M.fixtures("surgery_open_whipple")[0].duplicate(true)
	team.player = 100
	var field_probe := S.new(definition, team, 11, [], {}, true)
	field_probe.index = 1 # T02, incision stage.
	check(D.field_path(field_probe) == str(field.incision_path), "T02 shows incision before action")
	field_probe.awaiting_ack = true
	check(D.field_path(field_probe) == str(field.path), "T02 settles into the static open field")
	field_probe.awaiting_ack = false
	for index in range(2, 11): # T03-T11 share one unchanging image.
		field_probe.index = index
		check(D.field_path(field_probe) == str(field.path), "Middle stage keeps static open field")
	field_probe.index = 11 # T12, closure stage.
	check(D.field_path(field_probe) == str(field.closure_path), "T12 shows closure field")
	var numeric_fixture := S.new(definition, team, 41, [], {}, true)
	numeric_fixture.operative_dialogue = D.new(ID)
	numeric_fixture.suppress_operative_dialogue = true
	check(numeric_fixture.act(), "Numerical fixture bypasses presentation only")
	var session := S.new(definition, team, 37, [], {}, true)
	var dialogue := D.new(ID)
	session.operative_dialogue = dialogue
	var seen_before := 0
	var seen_after := 0
	var seen_failed := 0
	for guard in range(160):
		if session.finished: break
		var stage: Dictionary = session.current()
		if session.pending_rescue:
			check(dialogue.current(session).id.begins_with(str(stage.id) + "_F"), "Failure feedback precedes rescue")
			seen_failed += 1
			check(session.rescue(0), "Existing correction path")
			continue
		if session.awaiting_ack:
			if not bool(session.last_result.get("failed", false)):
				check(not session.acknowledge(), "After-action lines gate acknowledgement")
				for i in range(2):
					var line: Dictionary = dialogue.current(session)
					check(line.id == "%s_A%d" % [stage.id, i + 1], "After-action order")
					check(D.bind_role(str(line.speaker_role), {"first_assistant":"a", "second_assistant":"b", "primary_scrub":"c", "secondary_scrub":"d", "primary_circulating":"e", "secondary_circulating":"f", "anesthesia":"g"}).has("id"), "After-action role binds")
					check(dialogue.advance_sequence(session), "Advance after-action line")
					seen_after += 1
			else:
				check(dialogue.current(session).id.begins_with(str(stage.id) + "_F"), "Failure suppresses success lines")
			check(dialogue.current(session).is_empty() or bool(session.last_result.get("failed", false)), "After-action sequence exhausted")
			check(session.acknowledge(), "Existing stage acknowledgement")
			continue
		check(not session.act(), "Before-action lines gate surgery")
		for i in range(2):
			var line: Dictionary = dialogue.current(session)
			check(line.id == "%s_B%d" % [stage.id, i + 1], "Before-action order")
			check(dialogue.advance_sequence(session), "Advance before-action line")
			seen_before += 1
		check(dialogue.current(session).is_empty(), "Before-action sequence exhausted")
		check(session.act(0), "Stage action accepted")
	check(session.finished, "Complete all 12 stages")
	check(seen_before == 24, "All 24 before-action lines shown")
	check(seen_after + (12 if seen_failed > 0 else 0) >= 20, "After-action lines shown on resolved stages")
	check(dialogue.sequence_cursor.size() > 0, "V2 cursor exists only in presentation adapter")
	check(dialogue.history.size() == seen_before + seen_after, "Memory-only dialogue log contains seen lines")
	var skip_probe := S.new(definition, team, 53, [], {}, true)
	skip_probe.operative_dialogue = D.new(ID)
	check(skip_probe.operative_dialogue.skip_sequence(skip_probe) == 2, "Fast-forward skips only current dialogue phase")
	check(skip_probe.operative_dialogue.history.size() == 2 and skip_probe.operative_dialogue.current(skip_probe).is_empty(), "Skipped lines remain in memory log")
	check(skip_probe.act(), "Fast-forward preserves real stage action")
	var forced_failure := false
	for seed_value in range(1, 16):
		var low_team := team.duplicate(true)
		low_team.player = 1
		var probe := S.new(definition, low_team, seed_value, [], {}, true)
		probe.index = 2 # Isolated in-memory fixture for the first Precision stage.
		probe.operative_dialogue = D.new(ID)
		for _line in range(2): probe.operative_dialogue.advance_sequence(probe)
		check(probe.act(0), "Precision fixture starts")
		if not probe.pending_rescue: continue
		forced_failure = true
		check(str(probe.operative_dialogue.current(probe).id).begins_with("T03_F"), "Failure cue before rescue")
		check(probe.rescue(0), "Correction consumes existing rescue path")
		check(probe.awaiting_ack and bool(probe.last_result.failed), "Resolved failure reaches acknowledgement")
		check(str(probe.operative_dialogue.current(probe).id).begins_with("T03_F"), "Failure never displays successful after lines")
		check(probe.acknowledge(), "Failed stage can advance after correction")
		break
	check(forced_failure, "Deterministic failure fixture found")
	for checkpoint in [6, 9]:
		var crisis_probe := S.new(definition, team, 19, [], {}, true)
		crisis_probe.index = checkpoint
		crisis_probe.operative_dialogue = D.new(ID)
		crisis_probe.physiology = Physiology.new(definition, [], {})
		crisis_probe.physiology.active_crisis = {"id": "isolated_test_alert"}
		check(crisis_probe.in_crisis(), "Existing physiology crisis active")
		for i in range(3):
			var crisis_line: Dictionary = crisis_probe.operative_dialogue.current(crisis_probe)
			check(crisis_line.id == "%s_C%d" % [definition.steps[checkpoint].id, i + 1], "Crisis line order")
			check(crisis_probe.operative_dialogue.advance_sequence(crisis_probe), "Advance crisis line")
		check(crisis_probe.operative_dialogue.current(crisis_probe).is_empty(), "Crisis dialogue exhausts without a new crisis roll")
	var successes := 0
	var natural_crises := 0
	for seed_value in range(1, 13):
		var clinical := S.new(definition, team, seed_value, [], {}, false)
		for guard in range(80):
			if clinical.finished: break
			if clinical.in_crisis():
				natural_crises += 1
				check(clinical.resolve_crisis("pause_and_stabilize"), "Existing physiologic crisis resolver")
			elif clinical.pending_rescue: check(clinical.rescue(0), "Existing Precision correction")
			elif clinical.awaiting_ack: check(clinical.acknowledge(), "Stage acknowledgement after physiology")
			else:
				var options: Array = clinical.strategy_options()
				check(clinical.act(0, str(options[0].id) if not options.is_empty() else ""), "Clinical stage runs")
		check(clinical.finished, "Clinical run terminates")
		if clinical.success:
			successes += 1
			check(int(clinical.physiology.procedure_state.elapsed_time) >= 480, "Base time accounted once")
	check(successes > 0, "At least one clinical success is reachable")
	print("PETRA GODOT: ", checks, " checks / ", failures, " failures; before=", seen_before, " after=", seen_after, " failure=", seen_failed)
	print("PETRA CLINICAL SMOKE: ", successes, "/12 successes, ", natural_crises, " existing-resolver crises; not a balance estimate")
	quit(1 if failures else 0)
