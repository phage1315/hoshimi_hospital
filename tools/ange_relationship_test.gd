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

func complete_event(game, event_id: String) -> bool:
	var event = game.start_character_event(event_id)
	if event == null:
		return false
	var guard := 0
	while not event.completed and guard < 700:
		var choices: Array = event.current().get("choices", [])
		if choices.is_empty() or not game.choose_character_event(str(choices[0].id)):
			return false
		guard += 1
	return event.completed

func set_stats(game, surgery: int, leadership: int) -> void:
	game.surgery_xp = game.surgery_xp_for_level(surgery)
	game.leadership_xp = game.leadership_xp_for_level(leadership)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var game = GameState.new()
	configure_game(game)
	var ange: Dictionary = game.relation_for("nurse_ange")
	game.meet_staff("nurse_ange")
	expect(is_equal_approx(game.familiarity_gain_multiplier("nurse_ange"), 1.0), "Ange familiarity multiplier is not 1.00")
	ange.familiarity = 9
	expect(not game.character_event_available(game.character_event_definitions.ange_lv1_handover_main), "Ange Lv1 unlocked below Fam10")
	ange.familiarity = 10
	expect(game.character_event_available(game.character_event_definitions.ange_lv1_handover_main), "Ange Lv1 did not unlock at Fam10")
	var surgery_count: int = int(game.completed_surgeries_total)
	expect(complete_event(game, "ange_lv1_handover_main"), "Ange Lv1 main segment did not complete")
	expect(game.relationship_level("nurse_ange") == 0, "Ange ranked before the Lv1 epilogue")
	expect(not game.character_event_available(game.character_event_definitions.ange_lv1_handover_followup), "Ange Lv1 epilogue unlocked on the same day")

	var snapshot: Dictionary = game.snapshot()
	var clone = GameState.new()
	configure_game(clone)
	expect(clone.restore(JSON.parse_string(JSON.stringify(snapshot))), "Pending Ange epilogue save did not restore")
	clone.advance_story_to_future_day(1, 540)
	expect(clone.character_event_available(clone.character_event_definitions.ange_lv1_handover_followup), "Ange Lv1 epilogue did not unlock on the next day")
	expect(complete_event(clone, "ange_lv1_handover_followup"), "Ange Lv1 epilogue did not complete")
	expect(clone.relationship_level("nurse_ange") == 1, "Ange Lv1 epilogue did not grant Lv1")
	var lv1_day := clone.day_number()
	ange = clone.relation_for("nurse_ange")
	ange.familiarity = 100
	set_stats(clone, 100, 100)
	expect(not clone.character_event_available(clone.character_event_definitions.ange_lv2_explanation_main), "Ange Lv2 ignored the three-day milestone cooldown")
	clone.advance_story_to_day(lv1_day + 3, 540)
	expect(clone.character_event_available(clone.character_event_definitions.ange_lv2_explanation_main), "Ange Lv2 did not unlock after the three-day cooldown")

	expect(complete_event(clone, "ange_lv2_explanation_main"), "Ange Lv2 main segment did not complete")
	clone.advance_story_to_future_day(1, 540)
	expect(complete_event(clone, "ange_lv2_explanation_followup"), "Ange Lv2 epilogue did not complete")
	expect(clone.relationship_level("nurse_ange") == 2, "Ange Lv2 epilogue did not grant exactly one rank")
	clone.advance_story_to_future_day(3, 540)
	set_stats(clone, 64, 100)
	expect(not clone.character_event_available(clone.character_event_definitions.ange_lv3_check_again_main), "Ange Lv3 ignored Surgery64 boundary")
	set_stats(clone, 65, 100)
	expect(clone.character_event_available(clone.character_event_definitions.ange_lv3_check_again_main), "Ange Lv3 did not unlock at Surgery65")
	expect(complete_event(clone, "ange_lv3_check_again_main"), "Ange Lv3 main segment did not complete")
	clone.advance_story_to_future_day(1, 540)
	expect(complete_event(clone, "ange_lv3_check_again_followup"), "Ange Lv3 epilogue did not complete")
	expect(clone.relationship_level("nurse_ange") == 3, "Ange Lv3 epilogue did not grant exactly one rank")
	clone.advance_story_to_future_day(3, 540)

	# Attribute boundaries are checked independently on a fresh eligible state.
	set_stats(clone, 74, 100)
	expect(not clone.character_event_available(clone.character_event_definitions.ange_lv4_afraid), "Ange Lv4 ignored Surgery74 boundary")
	set_stats(clone, 75, 100)
	expect(clone.character_event_available(clone.character_event_definitions.ange_lv4_afraid), "Ange Lv4 did not unlock at Surgery75")
	expect(complete_event(clone, "ange_lv4_afraid"), "Ange Lv4 did not complete")
	clone.advance_story_to_future_day(3, 540)
	set_stats(clone, 79, 70)
	expect(not clone.character_event_available(clone.character_event_definitions.ange_lv5_call_me_main), "Ange Lv5 ignored Surgery79 boundary")
	set_stats(clone, 80, 69)
	expect(not clone.character_event_available(clone.character_event_definitions.ange_lv5_call_me_main), "Ange Lv5 ignored Leadership69 boundary")
	set_stats(clone, 80, 70)
	expect(clone.character_event_available(clone.character_event_definitions.ange_lv5_call_me_main), "Ange Lv5 did not unlock at Surgery80/Leadership70")
	expect(complete_event(clone, "ange_lv5_call_me_main"), "Ange Lv5 main segment did not complete")
	expect(clone.relationship_level("nurse_ange") == 4, "Ange ranked before the Lv5 epilogue")
	clone.advance_story_to_future_day(1, 540)
	expect(complete_event(clone, "ange_lv5_call_me_followup"), "Ange Lv5 epilogue did not complete")
	expect(clone.relationship_level("nurse_ange") == 5, "Ange route did not reach Lv5")
	expect(clone.relation_for("nurse_ange").flags.has("ange_professional_trust_route_complete"), "Ange professional-trust completion flag is missing")
	expect(clone.relation_for("nurse_ange").unlocked_benefits.is_empty(), "Ange route granted a forbidden generic benefit")
	expect(clone.completed_surgeries_total == surgery_count, "Ange narrative surgeries changed the completed-surgery count")

	var placeholders: Array = content.collections.relationship_activity_placeholders
	for row in placeholders:
		expect("nurse_ange" not in row.get("eligible_staff_ids", []), "Ange remains eligible for %s" % row.id)

	var hiroko = GameState.new()
	configure_game(hiroko)
	expect(not hiroko.staff_can_join_surgery_team("nurse_hiroko"), "Unmet Hiroko can join the surgical team")
	hiroko.meet_staff("nurse_hiroko")
	expect(hiroko.relationship_level("nurse_hiroko") == 0 and int(hiroko.relation_for("nurse_hiroko").familiarity) == 0, "Hiroko test did not remain at Lv0/Fam0")
	expect(hiroko.staff_can_join_surgery_team("nurse_hiroko") and "nurse_hiroko" in hiroko.known_staff_ids(), "Met Lv0/Fam0 Hiroko cannot be invited")

	print("ANGE LV1-LV5 RELATIONSHIP: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
