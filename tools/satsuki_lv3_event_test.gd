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
	var expected_scene_outfits := {
		"s14_": "patient_gown",
		"s15_": "patient_gown",
		"s16_": "preop_patient",
		"s17_": "preop_patient",
		"s18_": "or_table_awake",
		"s19_": "or_table_awake",
		"s20_": "or_table_awake",
		"s21_": "postop_patient",
		"s22_": "postop_patient"
	}
	for node in step.get("nodes", []):
		if str(node.get("actor_id", "")) != "nurse_satsuki":
			continue
		var outfit := str(node.get("outfit", ""))
		var expression := str(node.get("expression", ""))
		if outfit.is_empty() or expression.is_empty():
			continue
		var node_id := str(node.get("id", ""))
		var portrait_key := outfit + "/" + expression
		expect(portraits.has(portrait_key), "Satsuki Lv3 references unmapped portrait " + portrait_key + " at " + node_id)
		if portraits.has(portrait_key):
			expect(FileAccess.file_exists("res://" + str(portraits[portrait_key])), "Satsuki Lv3 portrait file is missing for " + portrait_key)
		for scene_prefix in expected_scene_outfits:
			if node_id.begins_with(scene_prefix):
				expect(outfit == expected_scene_outfits[scene_prefix], "Satsuki Lv3 used " + outfit + " instead of " + expected_scene_outfits[scene_prefix] + " at " + node_id)
				expect(not bool(node.get("hide_portrait", false)), "Satsuki Lv3 hid the authored patient portrait at " + node_id)
				break

func validate_yurika_portraits(step: Dictionary) -> void:
	var expected_count := 0
	for node in step.get("nodes", []):
		if str(node.get("speaker_label", "")) != "百合香":
			continue
		expected_count += 1
		var portrait_path := str(node.get("portrait_path", ""))
		expect(not portrait_path.is_empty(), "Satsuki Lv3 Yurika dialogue has no portrait at " + str(node.get("id", "")))
		expect(not bool(node.get("hide_portrait", false)), "Satsuki Lv3 hides Yurika at " + str(node.get("id", "")))
		if not portrait_path.is_empty():
			expect(FileAccess.file_exists("res://" + portrait_path), "Satsuki Lv3 Yurika portrait file is missing at " + str(node.get("id", "")))
	expect(expected_count == 171, "Satsuki Lv3 Yurika dialogue portrait coverage changed")

func configure_game(game) -> void:
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions, content.collections.palpation_profiles)

func prepare_game(level: int = 2, familiarity: int = 45, completed_day: int = 5, current_day: int = 8, include_flags: bool = true):
	var game = GameState.new()
	configure_game(game)
	for actor_id in ["nurse_satsuki", "doc_artoria", "nurse_ishigami", "nurse_hiroko", "nurse_haru"]:
		game.meet_staff(actor_id)
	var relation: Dictionary = game.relation_for("nurse_satsuki")
	relation.level = level
	relation.familiarity = familiarity
	if include_flags:
		game.set_story_flag("satsuki_lv2_patient_transport_complete", true)
		game.set_story_flag("satsuki_or_rotation_unlocked", true)
	game.special_event_completion_counts["satsuki_lv2_patient_transport"] = 1
	game.special_event_completion_days["satsuki_lv2_patient_transport"] = completed_day
	game.advance_story_to_day(current_day, 540)
	return game

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var definition: Dictionary = content.find_record("special_events", "satsuki_lv3_wrong_patient_appendectomy")
	var step: Dictionary = content.find_record("special_event_steps", "satsuki_lv3_wrong_patient_appendectomy_main")
	expect(not definition.is_empty() and not step.is_empty(), "Satsuki Lv3 event data is missing")
	expect(step.get("nodes", []).size() == 785, "Satsuki Lv3 lost canonical storyboard beats")
	var nodes_by_id: Dictionary = {}
	for node in step.get("nodes", []):
		nodes_by_id[str(node.get("id", ""))] = node
	var skin_prep_cg_path := str(nodes_by_id.get("s15_009", {}).get("cg_path", ""))
	expect(skin_prep_cg_path == "assets/events/character_events/satsuki/cg/cg_satsuki_lv3_hiroko_satsuki_skin_prep_v1.png", "Satsuki Lv3 skin-preparation CG is not bound to the shaving beat")
	expect(FileAccess.file_exists("res://" + skin_prep_cg_path), "Satsuki Lv3 skin-preparation CG file is missing")
	var wrong_handoff_cg_path := str(nodes_by_id.get("s07_008", {}).get("cg_path", ""))
	expect(wrong_handoff_cg_path == "assets/events/character_events/satsuki/cg/lv3/cg_satsuki_lv3_yurika_wrong_handoff_v1.png", "Satsuki Lv3 wrong-handoff CG is not bound to the identity-failure beat")
	expect(FileAccess.file_exists("res://" + wrong_handoff_cg_path), "Satsuki Lv3 wrong-handoff CG file is missing")
	var enema_insertion_cg_path := str(nodes_by_id.get("s02_035", {}).get("cg_path", ""))
	expect(enema_insertion_cg_path == "assets/events/character_events/satsuki/cg/lv3/cg_satsuki_lv3_yurika_enema_insertion_v1.png", "Satsuki Lv3 enema insertion CG is not bound to the insertion beat")
	expect(FileAccess.file_exists("res://" + enema_insertion_cg_path), "Satsuki Lv3 enema insertion CG file is missing")
	var enema_setup_cg_path := str(nodes_by_id.get("s02_024", {}).get("cg_path", ""))
	expect(enema_setup_cg_path == "assets/events/character_events/satsuki/cg/lv3/cg_satsuki_lv3_yurika_enema_setup_sfw_v1.png", "Satsuki Lv3 enema setup CG is not bound to the catheter-realization beat")
	expect(FileAccess.file_exists("res://" + enema_setup_cg_path), "Satsuki Lv3 enema setup CG file is missing")
	var enema_cramping_cg_path := str(nodes_by_id.get("s02_043", {}).get("cg_path", ""))
	expect(enema_cramping_cg_path == "assets/events/character_events/satsuki/cg/lv3/cg_satsuki_lv3_yurika_enema_cramping_v1.png", "Satsuki Lv3 enema cramping CG is not bound to the infusion beat")
	expect(FileAccess.file_exists("res://" + enema_cramping_cg_path), "Satsuki Lv3 enema cramping CG file is missing")
	var mask_induction_cg_path := str(nodes_by_id.get("s08_003", {}).get("cg_path", ""))
	expect(mask_induction_cg_path == "assets/events/character_events/satsuki/cg/lv3/cg_satsuki_lv3_17_yurika_mask_induction_v1.png", "Satsuki Lv3 Yurika mask-induction CG is not bound to the induction beat")
	expect(FileAccess.file_exists("res://" + mask_induction_cg_path), "Satsuki Lv3 Yurika mask-induction CG file is missing")
	validate_satsuki_portraits(step)
	validate_yurika_portraits(step)

	expect(not prepare_game(1).special_event_base_requirements_met(definition), "Satsuki Lv3 bypassed relationship level 2")
	expect(not prepare_game(3).special_event_base_requirements_met(definition), "Satsuki Lv3 remained available after relationship level 2")
	expect(not prepare_game(2, 44).special_event_base_requirements_met(definition), "Satsuki Lv3 bypassed familiarity 45")
	expect(not prepare_game(2, 45, 5, 7).special_event_base_requirements_met(definition), "Satsuki Lv3 bypassed the three-day cooldown")
	expect(not prepare_game(2, 45, 5, 8, false).special_event_base_requirements_met(definition), "Satsuki Lv3 bypassed its Lv2 completion flags")

	var game = prepare_game()
	expect(game.special_event_base_requirements_met(definition), "Satsuki Lv3 did not unlock at the authored thresholds")
	expect(game.start_special_event(definition.id) != null, "Satsuki Lv3 could not start")
	expect(not game.can_save_progress(), "Satsuki Lv3 allowed a save during its narrative")
	var visited: Array[String] = []
	var safety := 0
	while game.special_event_in_progress() and not game.active_special_event.completed and safety < 820:
		var node: Dictionary = game.active_special_event.current()
		visited.append(str(node.get("id", "")))
		var choices: Array = node.get("choices", [])
		expect(choices.size() == 1, "Satsuki Lv3 reached a node without its canonical continuation")
		if choices.is_empty():
			break
		expect(game.choose_special_event(str(choices[0].id)).accepted, "Satsuki Lv3 continuation failed at " + str(node.get("id", "")))
		safety += 1
	expect(game.active_special_event.completed and safety == 785, "Satsuki Lv3 did not traverse all 785 beats")
	for required_node in ["s02_023", "s03_001", "s07_001", "s08_001", "s09_001", "s12_001", "s14_001", "s18_001", "s19_001", "s20_001", "s20_100", "s21_001", "s22_019", "s23_009"]:
		expect(required_node in visited, "Satsuki Lv3 skipped canonical beat " + required_node)
	for flag in ["satsuki_lv3_complete", "satsuki_romantic_awareness", "satsuki_accepts_close_proximity_sakaguchi", "satsuki_full_identity_verification_trait", "satsuki_normal_sunday_date", "satsuki_lv4_gate_check"]:
		expect(game.story_flag(flag), "Satsuki Lv3 did not set " + flag)
	expect(game.relationship_level("nurse_satsuki") == 3, "Satsuki Lv3 did not award relationship level 3")
	expect(int(game.relation_for("nurse_satsuki").familiarity) == 57, "Satsuki Lv3 did not award the shared Lv3 familiarity gain")
	expect(game.relation_for("nurse_satsuki").unlocked_benefits.has("unlock_satsuki_normal_sunday_date"), "Satsuki Lv3 did not unlock normal Sunday dates")
	expect(game.special_event_gallery_unlocked(definition.id), "Satsuki Lv3 did not unlock gallery replay")
	expect(not game.can_save_progress(), "Completed Satsuki Lv3 allowed a save before leaving the event scene")
	game.finish_special_event()
	expect(game.can_save_progress(), "Saving remained locked after Satsuki Lv3 finished")

	var english = Loader.new()
	expect(english.load_all("en"), "English content load failed")
	var english_step: Dictionary = english.find_record("special_event_steps", "satsuki_lv3_wrong_patient_appendectomy_main")
	for node in english_step.get("nodes", []):
		var text_value := str(node.get("text", ""))
		expect(not text_value.contains("皐月") and not text_value.contains("百合香") and not text_value.contains("患者"), "Satsuki Lv3 retained Chinese prose in English at " + str(node.get("id", "")))

	print("SATSUKI LV3 EVENT: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
