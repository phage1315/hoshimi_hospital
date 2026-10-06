extends SceneTree

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func first_available_day(game, definition: Dictionary, start_day: int, end_day: int) -> int:
	for day in range(start_day, end_day + 1):
		game.set_test_time(day, 540)
		if game.special_event_available(definition):
			return day
	return -1

func finish_event(game) -> void:
	while game.special_event_in_progress():
		var node: Dictionary = game.active_special_event.current()
		var choices: Array = node.get("choices", [])
		expect(not choices.is_empty(), "Personal-nurse event reached a node without a choice")
		if choices.is_empty():
			return
		game.choose_special_event(str(choices[0].id))

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var game = app.game
	var definition: Dictionary = game.special_event_definitions["probation_completion_personal_nurse"]

	expect(not game.probation_complete and not game.personal_nurse_system_unlocked, "New game started past probation")
	expect(game.resolve_outpatient_support_actor() == "doc_aoi", "Jinguji is not the pre-probation outpatient support actor")
	game.set_test_time(29, 540)
	game.set_test_player_attribute("reputation", 49)
	expect(not game.special_event_base_requirements_met(definition), "Probation event unlocked below both thresholds")

	var trigger_day := first_available_day(game, definition, 30, 36)
	expect(trigger_day >= 30, "Day-30 probation event did not become available during the next workweek")
	if trigger_day >= 30:
		expect(game.start_special_event(definition.id) != null, "Could not start probation event")
		finish_event(game)
	expect(game.probation_complete and game.personal_nurse_system_unlocked, "Completing probation did not unlock the personal-nurse system")
	expect(game.personal_nurse_id == "nurse_haru" and game.resolve_outpatient_support_actor() == "nurse_haru", "Nanase Ren was not assigned as the first personal nurse")
	expect(game.story_flag("probation_complete") and game.story_flag("personal_nurse_system_unlocked"), "Probation completion flags were not recorded")

	var before_chat := int(game.relation_for("nurse_haru").familiarity)
	game.personal_nurse_dialogue("chatter")
	expect(int(game.relation_for("nurse_haru").familiarity) == before_chat, "Clinic chatter incorrectly awarded familiarity")
	game.award_personal_nurse_outpatient_familiarity()
	expect(int(game.relation_for("nurse_haru").familiarity) == before_chat + 1, "Completed outpatient lifecycle did not award +1 familiarity")

	game.meet_staff("nurse_rin")
	expect(game.set_personal_nurse("nurse_rin"), "Known eligible nurse could not be assigned")
	expect(game.resolve_outpatient_support_actor() == "nurse_rin", "Outpatient support did not switch to the newly assigned nurse")
	expect(not game.set_personal_nurse("nurse_ishigami"), "Ineligible management nurse could be assigned")

	var semantic_speaker_found := false
	for encounter in game.definitions.values():
		for stage in encounter.get("stages", []):
			if str(stage.get("speaker", "")) == "outpatient_support":
				semantic_speaker_found = true
	expect(semantic_speaker_found, "Generated encounters did not retain the semantic outpatient-support speaker")

	game.reset()
	game.set_test_time(10, 540)
	game.set_test_player_attribute("reputation", 50)
	expect(game.special_event_base_requirements_met(definition), "Reputation 50 did not unlock early probation completion")
	expect(game.resolve_outpatient_support_actor() == "doc_aoi", "The nurse replaced Jinguji before the event was completed")

	print("PERSONAL NURSE SYSTEM: %s checks; %s failure(s)" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
