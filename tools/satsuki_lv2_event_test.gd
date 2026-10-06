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

func validate_satsuki_portraits(step: Dictionary) -> void:
	var staff: Dictionary = content.find_record("staff", "nurse_satsuki")
	var portraits: Dictionary = staff.get("visuals", {}).get("portraits", {})
	for node in step.get("nodes", []):
		if str(node.get("actor_id", "")) != "nurse_satsuki":
			continue
		var outfit := str(node.get("outfit", ""))
		var expression := str(node.get("expression", ""))
		if outfit.is_empty() or expression.is_empty():
			continue
		var portrait_key := outfit + "/" + expression
		expect(portraits.has(portrait_key), "Satsuki Lv2 references unmapped portrait " + portrait_key + " at " + str(node.get("id", "")))
		if portraits.has(portrait_key):
			expect(FileAccess.file_exists("res://" + str(portraits[portrait_key])), "Satsuki Lv2 portrait file is missing for " + portrait_key)

func validate_yoriko_assets(step: Dictionary) -> void:
	var expected_portraits := {
		"composed": "assets/events/character_events/satsuki/yoriko/preop/composed.png",
		"panic": "assets/events/character_events/satsuki/yoriko/preop/panic.png",
		"stubborn": "assets/events/character_events/satsuki/yoriko/preop/stubborn.png",
		"relieved": "assets/events/character_events/satsuki/yoriko/preop/relieved.png",
	}
	for path in expected_portraits.values():
		expect(FileAccess.file_exists("res://" + str(path)), "Yoriko Lv2 portrait is missing: " + str(path))
	var nodes_by_id := {}
	for node in step.get("nodes", []):
		nodes_by_id[str(node.get("id", ""))] = node
	expect(str(nodes_by_id.get("s079", {}).get("cg_path", "")) == "assets/events/character_events/satsuki/cg/cg_satsuki_lv2_or_door_brace_yoriko_v3.png", "Satsuki Lv2 doorway CG is not the corrected Yoriko v3 composition")
	expect(str(nodes_by_id.get("s101", {}).get("cg_path", "")) == "assets/events/character_events/satsuki/cg/cg_satsuki_lv2_next_thirty_seconds_yoriko_v3.png", "Satsuki Lv2 de-escalation CG is not the corrected Yoriko v3 composition")
	for node_id in ["s079", "s101"]:
		var cg_path := str(nodes_by_id.get(node_id, {}).get("cg_path", ""))
		expect(FileAccess.file_exists("res://" + cg_path), "Satsuki Lv2 CG file is missing at " + node_id)
	expect(str(nodes_by_id.get("s059", {}).get("text", "")).contains("我平时都是安慰别人别紧张的"), "Yoriko Holding self-reassurance line is missing")
	expect(str(nodes_by_id.get("s074", {}).get("text", "")).contains("患者想说话都找不到空隙"), "Yoriko OR-rumor line is missing")
	expect(str(nodes_by_id.get("s114", {}).get("text", "")).contains("留一道防线"), "Yoriko defensive insurance line is missing")

func validate_practice_coda(step: Dictionary) -> void:
	var nodes_by_id := {}
	for node in step.get("nodes", []):
		nodes_by_id[str(node.get("id", ""))] = node
	var cg_path := "assets/events/character_events/satsuki/cg/cg_satsuki_lv2_instrument_practice_playful_v1.png"
	expect(FileAccess.file_exists("res://" + cg_path), "Satsuki Lv2 instrument-practice CG is missing")
	expect(str(nodes_by_id.get("s176_practice_cg", {}).get("cg_path", "")) == cg_path, "Satsuki Lv2 practice coda does not show its CG")
	expect(nodes_by_id.get("s176_practice_cg", {}).get("choices", []).size() == 3, "Satsuki Lv2 practice coda lost its three player responses")
	for node_id in ["s177_like", "s177_expression", "s177_again"]:
		expect(str(nodes_by_id.get(node_id, {}).get("choices", [{}])[0].get("next", "")) == "s178_lv2_complete", "Satsuki Lv2 practice response does not converge at " + node_id)
	expect(str(nodes_by_id.get("s178_lv2_complete", {}).get("choices", [{}])[0].get("next", "")) == "@day_end", "Satsuki Lv2 practice coda does not end the day")

func configure_game(game) -> void:
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions, content.collections.palpation_profiles)

func prepare_game(level: int = 1, familiarity: int = 25, presence: int = 0, completed_day: int = 2, current_day: int = 5):
	var game = GameState.new()
	configure_game(game)
	for actor_id in ["nurse_satsuki", "doc_artoria", "nurse_ishigami", "nurse_hiroko"]:
		game.meet_staff(actor_id)
	var relation: Dictionary = game.relation_for("nurse_satsuki")
	relation.level = level
	relation.familiarity = familiarity
	game.set_story_flag("satsuki_lv1_complete", true)
	game.special_event_completion_counts["satsuki_lv1_real_patient_test"] = 1
	game.special_event_completion_days["satsuki_lv1_real_patient_test"] = completed_day
	if presence != 0:
		game.add_player_attribute_effect("presence", presence, "satsuki_lv2_gate_test", "Satsuki Lv2 gate test")
	game.advance_story_to_day(current_day, 540)
	return game

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var definition: Dictionary = content.find_record("special_events", "satsuki_lv2_patient_transport")
	var step: Dictionary = content.find_record("special_event_steps", "satsuki_lv2_patient_transport_main")
	expect(not definition.is_empty() and not step.is_empty(), "Satsuki Lv2 event data is missing")
	expect(step.get("nodes", []).size() == 180, "Satsuki Lv2 script lost authored storyboard beats or its practice coda")
	validate_satsuki_portraits(step)
	validate_yoriko_assets(step)
	validate_practice_coda(step)
	for node in step.get("nodes", []):
		var node_id := str(node.get("id", ""))
		if str(node.get("actor_id", "")) == "nurse_satsuki" and node_id in ["s049", "s086", "s125", "s161"]:
			expect(str(node.get("outfit", "")) == "scrubs", "Satsuki Lv2 OR beat did not use the scrub portrait at " + node_id)

	var level_zero = prepare_game(0)
	expect(not level_zero.special_event_base_requirements_met(definition), "Satsuki Lv2 bypassed relationship level 1")
	var level_two = prepare_game(2)
	expect(not level_two.special_event_base_requirements_met(definition), "Satsuki Lv2 remained available after relationship level 1")
	var low_familiarity = prepare_game(1, 24)
	expect(not low_familiarity.special_event_base_requirements_met(definition), "Satsuki Lv2 bypassed familiarity 25")
	var high_presence = prepare_game(1, 25, 1)
	expect(not high_presence.special_event_base_requirements_met(definition), "Satsuki Lv2 bypassed the clinical-presence maximum")
	var too_early = prepare_game(1, 25, 0, 2, 4)
	expect(not too_early.special_event_base_requirements_met(definition), "Satsuki Lv2 bypassed the three-day cooldown")

	var game = prepare_game()
	var event_start_day := game.day_number()
	var event_start_clock := game.elapsed()
	expect(game.special_event_base_requirements_met(definition), "Satsuki Lv2 did not unlock at its exact authored thresholds")
	expect(game.start_special_event(definition.id) != null, "Satsuki Lv2 could not start")
	var visited: Array[String] = []
	var safety := 0
	while game.special_event_in_progress() and not game.active_special_event.completed and safety < 220:
		var node: Dictionary = game.active_special_event.current()
		visited.append(str(node.get("id", "")))
		var choices: Array = node.get("choices", [])
		var expected_choice_count := 3 if str(node.get("id", "")) == "s176_practice_cg" else 1
		expect(choices.size() == expected_choice_count, "Satsuki Lv2 reached a node without its authored continuation")
		if choices.is_empty():
			break
		expect(game.choose_special_event(str(choices[0].id)).accepted, "Satsuki Lv2 continuation failed at " + str(node.get("id", "")))
		safety += 1
	expect(game.active_special_event.completed and safety < 220, "Satsuki Lv2 did not reach its ending")
	expect(game.day_number() == event_start_day and game.elapsed() == event_start_clock, "Satsuki Lv2 consumed game time")
	for required_node in ["s021", "s036", "s079", "s086", "s099", "s110", "s123", "s125", "s141", "s161", "s173", "s175_practice_transition", "s176_practice_cg", "s177_like", "s178_lv2_complete"]:
		expect(required_node in visited, "Satsuki Lv2 skipped storyboard beat " + required_node)
	for flag in ["satsuki_or_rotation_unlocked", "satsuki_successful_patient_transport", "satsuki_lv2_patient_transport_complete"]:
		expect(game.story_flag(flag), "Satsuki Lv2 did not set " + flag)
	expect(game.relationship_level("nurse_satsuki") == 2, "Satsuki Lv2 did not award relationship level 2")
	expect(int(game.relation_for("nurse_satsuki").familiarity) == 35, "Satsuki Lv2 did not use the shared Lv2 event familiarity reward")
	expect(game.relation_for("nurse_satsuki").unlocked_benefits.has("unlock_satsuki_or_rotation"), "Satsuki Lv2 did not unlock the OR-rotation benefit")
	expect(game.special_event_gallery_unlocked(definition.id), "Satsuki Lv2 did not unlock gallery replay")

	game.finish_special_event()
	game.date_profile_definitions = {"nurse_satsuki": game.date_profile_definitions["nurse_satsuki"]}
	game.advance_story_to_future_day(1, 540)
	expect(game.is_sunday(), "Satsuki Lv2 test did not finish on its expected Sunday")
	expect(game.sunday_date_candidates().has("nurse_satsuki"), "Satsuki did not become a Sunday invitation candidate after Lv2")
	expect(game.sunday_invitation_rejection_rate("nurse_satsuki") == 65, "Satsuki Lv2 invitation chance is not the authored 35 percent")

	var english = Loader.new()
	expect(english.load_all("en"), "English content load failed")
	var english_step: Dictionary = english.find_record("special_event_steps", "satsuki_lv2_patient_transport_main")
	for node in english_step.get("nodes", []):
		var text_value := str(node.get("text", ""))
		expect(not text_value.contains("皐月") and not text_value.contains("坂口") and not text_value.contains("患者"), "Satsuki Lv2 retained Chinese prose in English at " + str(node.get("id", "")))

	print("SATSUKI LV2 EVENT: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
