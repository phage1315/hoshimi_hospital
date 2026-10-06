extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")

var content = Loader.new()
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func configure_game(game) -> void:
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions, content.collections.palpation_profiles)

func prepare_game(presence: int = 30, familiarity: int = 10, lv0_complete: bool = true):
	var game = GameState.new()
	configure_game(game)
	game.meet_staff("nurse_satsuki")
	game.meet_staff("doc_aqua")
	game.relation_for("nurse_satsuki")["familiarity"] = familiarity
	if lv0_complete:
		game.set_story_flag("satsuki_lv0_complete", true)
	if presence != 0:
		game.add_player_attribute_effect("presence", presence, "satsuki_lv1_test_presence", "Satsuki Lv1 gate test")
	game.advance_story_to_day(2, 540)
	return game

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var definition: Dictionary = content.find_record("special_events", "satsuki_lv1_real_patient_test")
	var step: Dictionary = content.find_record("special_event_steps", "satsuki_lv1_real_patient_test_main")
	expect(not definition.is_empty() and not step.is_empty(), "Satsuki Lv1 event data is missing")
	expect(step.get("nodes", []).size() >= 100, "Satsuki Lv1 script lost authored storyboard beats")

	var missing_lv0 = prepare_game(30, 10, false)
	expect(not missing_lv0.special_event_base_requirements_met(definition), "Satsuki Lv1 bypassed the Lv0 completion gate")
	var low_familiarity = prepare_game(30, 9, true)
	expect(not low_familiarity.special_event_base_requirements_met(definition), "Satsuki Lv1 bypassed familiarity 10")
	var high_presence = prepare_game(31, 10, true)
	expect(not high_presence.special_event_base_requirements_met(definition), "Satsuki Lv1 bypassed the clinical-presence maximum")
	var game = prepare_game()
	expect(game.special_event_base_requirements_met(definition), "Satsuki Lv1 did not unlock at its exact authored thresholds")
	expect(game.start_special_event(definition.id) != null, "Satsuki Lv1 could not start")

	var visited: Array[String] = []
	var safety := 0
	while game.special_event_in_progress() and not game.active_special_event.completed and safety < 200:
		var node: Dictionary = game.active_special_event.current()
		visited.append(str(node.get("id", "")))
		var choices: Array = node.get("choices", [])
		expect(choices.size() == 1, "Satsuki Lv1 reached a node without its authored continuation")
		if choices.is_empty():
			break
		expect(game.choose_special_event(str(choices[0].id)).accepted, "Satsuki Lv1 continuation failed at " + str(node.get("id", "")))
		safety += 1
	expect(game.active_special_event.completed and safety < 200, "Satsuki Lv1 did not reach its ending")
	for required_node in ["s02_angle", "s03_whirr", "s04_pov", "s05_almost_fine", "s06_stop_anytime", "s07_standing_view", "s08_nurse", "s09_thank_listen", "s10_listens"]:
		expect(required_node in visited, "Satsuki Lv1 skipped storyboard beat " + required_node)
	for flag in ["satsuki_lv1_complete", "satsuki_clinical_trust_sakaguchi", "satsuki_patient_perspective_trait", "satsuki_lv2_gate_check"]:
		expect(game.story_flag(flag), "Satsuki Lv1 did not set " + flag)
	expect(game.relationship_level("nurse_satsuki") == 1, "Satsuki Lv1 did not award relationship level 1")
	expect(int(game.relation_for("nurse_satsuki").familiarity) == 20, "Satsuki Lv1 did not use the shared Lv1 event familiarity reward")
	expect(game.special_event_gallery_unlocked(definition.id), "Satsuki Lv1 did not unlock gallery replay")
	expect(game.date_profile_definitions.has("nurse_satsuki"), "Satsuki Lv2 date profile is missing")
	game.advance_story_to_day(6, 540)
	expect(not game.sunday_date_candidates().has("nurse_satsuki"), "Satsuki incorrectly became available for Sunday dates at Lv1")

	var english = Loader.new()
	expect(english.load_all("en"), "English content load failed")
	var english_step: Dictionary = english.find_record("special_event_steps", "satsuki_lv1_real_patient_test_main")
	for node in english_step.get("nodes", []):
		expect(not str(node.get("text", "")).contains("皐月") and not str(node.get("text", "")).contains("坂口"), "Satsuki Lv1 retained Chinese prose in English at " + str(node.get("id", "")))

	print("SATSUKI LV1 EVENT: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
