extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")

var checks := 0
var failures := 0
var content = Loader.new()

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func configure_game(game: GameState) -> void:
	game.configure(
		content.collections.encounters,
		content.collections.preops,
		content.collections.staff,
		content.collections.time_events,
		content.collections.surgeries,
		content.collections.patients,
		content.collections.relationships,
		content.collections.character_events,
		content.collections.case_templates,
		content.collections.micro_events,
		content.collections.examination_cg_pools,
		content.collections.surgery_team_dialogue_profiles,
		content.collections.patient_interactions,
		content.collections.temporary_conditions,
		content.collections.staff_role_cg_rewards,
		content.collections.special_events,
		content.collections.special_event_steps,
		content.collections.date_profiles,
		content.collections.date_locations,
		content.collections.advanced_referral_cases,
		content.collections.first_surgery_diagnosis_reactions,
		content.collections.palpation_profiles
	)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var definition: Dictionary = content.find_record("special_events", "minato_intro_sunday_cholecystectomy")
	var step: Dictionary = content.find_record("special_event_steps", "minato_intro_sunday_cholecystectomy_main")
	expect(not definition.is_empty() and not step.is_empty(), "Minato intro event data is missing")
	expect(bool(definition.get("timing", {}).get("sunday_start_allowed", false)), "Minato intro is not allowed to start on Sunday")
	expect(definition.get("trigger_mode", "") == "day_start", "Minato intro must be a day-start event")
	expect(step.get("nodes", []).size() >= 35, "Minato intro lost the authored surgery beats")
	var minato_draft_node: Dictionary = {}
	for candidate in step.get("nodes", []):
		if str(candidate.get("id", "")) == "player_drafted":
			minato_draft_node = candidate
	expect(minato_draft_node.get("choices", []).size() == 3, "Minato drafting beat must expose three player responses")
	var draft_next_ids := []
	for choice in minato_draft_node.get("choices", []):
		draft_next_ids.append(str(choice.get("next", "")))
	for response_id in ["minato_response_offer", "minato_response_sunday", "minato_response_identity"]:
		expect(response_id in draft_next_ids, "Minato drafting response is missing: " + response_id)

	var game := GameState.new()
	configure_game(game)
	game.advance_story_to_day(6, 540)
	expect(game.is_sunday(), "Day 6 is not Sunday in the fixed calendar")
	expect(game.special_event_base_requirements_met(definition), "Minato intro did not unlock on Sunday")
	expect(game.start_special_event(definition.id) != null, "Minato intro could not start")

	var visited: Array[String] = []
	var safety := 0
	while game.special_event_in_progress() and game.active_special_event != null and not game.active_special_event.completed and safety < 100:
		var node: Dictionary = game.active_special_event.current()
		visited.append(str(node.get("id", "")))
		var choices: Array = node.get("choices", [])
		expect(choices.size() == 1 or (str(node.get("id", "")) == "player_drafted" and choices.size() == 3), "Minato intro reached an unexpected choice count: " + str(node.get("id", "")))
		if choices.is_empty():
			break
		expect(game.choose_special_event(str(choices[0].get("id", ""))).accepted, "Minato intro continuation failed at " + str(node.get("id", "")))
		safety += 1

	expect(game.active_special_event != null and game.active_special_event.completed, "Minato intro did not reach its ending")
	expect(safety < 100, "Minato intro exceeded traversal safety limit")
	expect(game.story_flag("minato_intro_complete"), "Minato intro completion flag is missing")
	expect(game.story_flag("met_minato"), "Minato intro did not mark Minato as met")
	expect(game.staff_is_met("doc_minato"), "Minato relationship was not opened by the intro")
	expect(game.relation_for("doc_minato").familiarity == 10, "Minato introduction did not award its one-time Familiarity +10")
	for required_node in ["erina_dazed", "erina_surprised", "erina_irritated", "erina_defeated", "erina_baseball_plan", "minato_to_holding", "megumi_to_holding", "erina_held_against_will", "holding_transfer", "minato_grabs_sakaguchi", "player_assistant_joke", "minato_reassures_team", "erina_unimpressed", "minato_response_offer", "minato_response_sunday", "minato_response_identity", "epidural_fixed", "baseball_small_talk", "megumi_focus", "erina_deadline", "erina_postop_baseball", "minato_change_clothes", "minato_riverside_walk", "minato_riverside_coffee", "minato_walk_end"]:
		expect(required_node in visited, "Minato intro skipped authored beat " + required_node)
	var intraoperative_erina_nodes := ["erina_awake_start", "erina_asks_time", "erina_no_plan", "erina_open_abdomen", "erina_thanks_megumi", "erina_duration", "erina_thanks_time", "erina_deadline", "erina_distrusts"]
	for candidate in step.get("nodes", []):
		if str(candidate.get("id", "")) in intraoperative_erina_nodes:
			expect(str(candidate.get("portrait_path", "")).begins_with("assets/characters/portrait_pack_v21/patient_erin/intraoperative/"), "Intraoperative Erina node uses a non-table portrait: " + str(candidate.get("id", "")))
	for path in [
		"assets/events/character_events/minato_intro/megumi/ward/professional.png",
		"assets/events/character_events/minato_intro/megumi/or/dry_admonishing.png",
		"assets/events/character_events/minato_intro/cg/megumi_wakes_her.png",
		"assets/events/character_events/minato_intro/cg/minato_names_player.png",
		"assets/events/character_events/minato_intro/cg/baseball_small_talk.png",
		"assets/events/character_events/minato_intro/cg/erina_postop_baseball.png",
		"assets/events/character_events/minato_intro/cg/minato_riverside_coffee.png",
		"assets/backgrounds/v12/minato_riverside_walk.png",
		"assets/characters/portrait_pack_v21/patient_erin/intraoperative_nude/prepared_arms_crossed.png",
		"assets/characters/portrait_pack_v21/patient_erin/intraoperative_nude/skeptical.png",
		"assets/characters/portrait_pack_v21/patient_erin/intraoperative_nude/amused.png",
		"assets/characters/portrait_pack_v21/patient_erin/intraoperative_nude/exhausted.png",
		"assets/characters/portrait_pack_v21/patient_erin/intraoperative/skeptical.png",
		"assets/characters/portrait_pack_v21/patient_erin/intraoperative/tense_amused.png",
		"assets/characters/portrait_pack_v21/patient_erin/intraoperative/resigned.png",
		"assets/characters/portrait_pack_v21/patient_erin/postoperative/baseball.png"
	]:
		expect(FileAccess.file_exists("res://" + path), "Minato intro asset is missing: " + path)

	print("MINATO INTRO EVENT: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
