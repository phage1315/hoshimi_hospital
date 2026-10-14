extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const Encounter = preload("res://godot/systems/encounter_session.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func quoted(lines: Array[String], locale: String) -> String:
	return "“%s”" % " ".join(lines) if locale == "en" else "「%s」" % "".join(lines)

func run() -> void:
	for locale in ["zh_CN", "en"]:
		var content = Loader.new()
		expect(content.load_all(locale), locale + ": content loads")
		var game = GameState.new()
		game.patient_definitions = content.collections.patients.duplicate(true)
		var blueprint: Dictionary = content.find_record("encounters", "visit_tifa")
		var source_blueprint := blueprint.duplicate(true)
		var source_patients: Array = game.patient_definitions.duplicate(true)
		var lines: Dictionary = game.patient_definition("patient_tifa").outpatient_lines
		var expected := quoted([str(lines.primary), str(lines.secondary)], locale)
		var long_history_cases := 0
		for template in content.collections.case_templates:
			if template.history.size() > 2:
				long_history_cases += 1
			var label: String = locale + "/" + str(template.id)
			var definition: Dictionary = game.encounter_for_case(blueprint, template)
			var visit = Encounter.new(definition)
			visit.stage_id = "history"
			expect(visit.apply("basic_history"), label + ": history bundle succeeds")
			expect(visit.presentation().text == expected, label + ": fixed primary and secondary appear exactly once")
			expect(visit.presentation().speaker == "patient_tifa", label + ": speaker retained")
			var state: Dictionary = visit.snapshot_state()
			for refresh in range(3):
				expect(visit.presentation().text == expected, label + ": refresh does not duplicate dialogue")
			expect(not visit.apply("basic_history"), label + ": repeated bundle is rejected")
			expect(visit.snapshot_state() == state, label + ": refresh/repeated click preserves state")
			var individual = Encounter.new(definition)
			individual.stage_id = "history"
			for action_id in ["pain", "associated", "background"]:
				expect(individual.apply(action_id), label + ": individual history action succeeds")
			expect(individual.snapshot_state() == state, label + ": bundle preserves notes, time and effects")
			var restored = Encounter.new(game.encounter_for_case(blueprint, template))
			expect(restored.restore_state(JSON.parse_string(JSON.stringify(state))), label + ": saved history restores")
			expect(restored.presentation().text == expected, label + ": restored display remains nonrepeating")
			expect(game.encounter_for_case(blueprint, template) == definition, label + ": rebuilding is deterministic")
		expect(long_history_cases > 0, locale + ": includes actual cases with more than two history entries")
		expect(blueprint == source_blueprint and game.patient_definitions == source_patients, locale + ": source text is not mutated")
		# Placeholder and fallback lines must retain every history entry, even
		# identical source entries: this must not become global text deduplication.
		var fixture: Dictionary = content.collections.case_templates[0].duplicate(true)
		fixture.history.append(fixture.history[1])
		var history: Array = ["The symptoms began recently and have gradually become more noticeable.", "They are affecting daily life enough to seek specialist care."] if locale == "en" else fixture.history
		for use_override in [true, false]:
			var patient: Dictionary = game.patient_definition("patient_sora")
			if not use_override:
				patient.erase("outpatient_lines")
			var voiced: Array[String] = []
			for index in range(history.size()):
				voiced.append(game.patient_voice_line("patient_sora", str(history[index]), "primary" if index == 0 else "secondary"))
			var sora = Encounter.new(game.encounter_for_case(content.find_record("encounters", "visit_sora"), fixture))
			sora.stage_id = "history"
			expect(sora.apply("basic_history"), locale + ": template/fallback history succeeds")
			expect(sora.presentation().text == quoted(voiced, locale), locale + ": template/fallback preserves all source history")
	print("Outpatient history dialogue: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
