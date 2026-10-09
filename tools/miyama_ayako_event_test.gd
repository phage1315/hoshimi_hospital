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
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases)

func complete_character_event(game, id: String) -> bool:
	var event = game.start_character_event(id)
	if event == null:
		return false
	var guard := 0
	while not event.completed and guard < 100:
		var choices: Array = event.current().get("choices", [])
		if choices.is_empty() or not game.choose_character_event(str(choices[0].id)):
			return false
		guard += 1
	if event.completed:
		game.active_character_event_id = ""
		game.active_mode = "encounter"
	return event.completed

func complete_special_event(game, id: String, visited: Dictionary, limit: int = 900) -> bool:
	var event = game.start_special_event(id)
	if event == null:
		return false
	var guard := 0
	while not event.completed and guard < limit:
		var node: Dictionary = event.current()
		visited[str(node.get("id", ""))] = true
		var choices: Array = node.get("choices", [])
		if choices.is_empty():
			return false
		var result: Dictionary = game.choose_special_event(str(choices[0].id))
		if not bool(result.get("accepted", false)):
			return false
		guard += 1
	if not event.completed:
		return false
	game.finish_special_event()
	return true

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var game = GameState.new()
	configure_game(game)

	expect(complete_character_event(game, "intro_doc_rei"), "Kaori introduction could not complete")
	game.meet_staff("doc_asuka")
	game.add_familiarity("doc_rei", 10)
	game.advance_story_to_day(4, 540)
	var lv1: Dictionary = game.special_event_definitions["miyama_01_safety_pin"]
	game.set_story_flag("__test_save_target_event__" + str(lv1.id), true)
	expect(game.special_event_available(lv1), "Kaori Lv1 did not unlock after her introduction")
	var lv1_nodes := {}
	expect(complete_special_event(game, lv1.id, lv1_nodes), "Kaori Lv1 did not traverse to completion")
	expect(lv1_nodes.has("palpation_placeholder") and lv1_nodes.has("negative") and lv1_nodes.has("rank"), "Kaori Lv1 missed the one-click palpation placeholder or its operative outcome")
	expect(game.relationship_level("doc_rei") == 1, "Kaori Lv1 did not raise her relationship to Lv1")
	expect(game.procedure_unlocked("surgery_exploratory_laparotomy"), "Kaori Lv1 did not unlock exploratory laparotomy")
	for flag in ["miyama_01_safety_pin_completed", "safety_pin_patient_safe", "miyama_negative_exploration_memory"]:
		expect(game.story_flag(flag), "Kaori Lv1 completion flag missing: " + flag)

	game.meet_staff("doc_shiori")
	game.add_familiarity("doc_rei", 15)
	# Full-day special events record completion after advancing to the following
	# workday, so a three-day milestone cooldown reaches day 8 here.
	game.advance_story_to_day(8, 540)
	var lv2: Dictionary = game.special_event_definitions["miyama_02_manga_artist_wrong_patient"]
	game.set_story_flag("__test_save_target_event__" + str(lv2.id), true)
	expect(game.special_event_available(lv2), "Kaori Lv2 did not honor the formal Lv1/Lv2 prerequisites")
	var lv2_nodes := {}
	expect(complete_special_event(game, lv2.id, lv2_nodes), "Kaori Lv2 did not traverse its complete script")
	expect(lv2_nodes.has("lv1_callback") and lv2_nodes.has("s34_001") and lv2_nodes.has("lv2_asuka_private"), "Kaori Lv2 missed the new Lv1 callback or private Asuka epilogue")
	expect(game.relationship_level("doc_rei") == 2, "Kaori Lv2 did not raise her relationship to Lv2")

	game.meet_staff("nurse_moe")
	game.meet_staff("nurse_ange")
	game.add_familiarity("doc_rei", 15)
	game.advance_story_to_day(12, 540)
	var lv3: Dictionary = game.special_event_definitions["miyama_03_or_god"]
	game.set_story_flag("__test_save_target_event__" + str(lv3.id), true)
	expect(game.special_event_available(lv3), "Kaori Lv3 did not unlock after Lv2")
	var lv3_nodes := {}
	expect(complete_special_event(game, lv3.id, lv3_nodes), "Kaori Lv3 did not traverse to completion")
	for node_id in ["moe", "consent", "ange", "release", "gown", "cg", "rank3"]:
		expect(lv3_nodes.has(node_id), "Kaori Lv3 missed required node: " + node_id)
	expect(game.relationship_level("doc_rei") == 3, "Kaori Lv3 did not raise her relationship to Lv3")
	for flag in ["miyama_03_or_god_completed", "miyama_primary_surgeon_confidence_restored", "miyama_or_god_gag_known_by_inner_circle"]:
		expect(game.story_flag(flag), "Kaori Lv3 completion flag missing: " + flag)
	expect(game.special_event_gallery_unlocked(lv1.id) and game.special_event_gallery_unlocked(lv2.id) and game.special_event_gallery_unlocked(lv3.id), "Kaori arc did not unlock all gallery replays")

	var snapshot: Dictionary = game.snapshot()
	var clone = GameState.new()
	configure_game(clone)
	expect(clone.restore(JSON.parse_string(JSON.stringify(snapshot))), "Kaori arc save did not restore")
	expect(clone.relationship_level("doc_rei") == 3 and clone.special_event_done(lv1.id) and clone.special_event_done(lv2.id) and clone.special_event_done(lv3.id), "Restoring the Kaori arc lost its rank or event history")

	print("MIYAMA LV1-LV3 ARC: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
