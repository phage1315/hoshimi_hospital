extends SceneTree
## End-to-end logic test for Sayaka's authored Lv5 A/B/C events.
## Run with: godot --headless --path . --script res://tools/sayaka_lv5_event_test.gd
## Uses an isolated in-memory GameState and debug-only test setup; never touches a save slot.

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const SpecialEvent = preload("res://godot/systems/special_event_session.gd")

const EVENT_A := "sayaka_lv5_part_a"
const EVENT_B := "sayaka_lv5_part_b"
const EVENT_C := "sayaka_lv5_part_c"
const A_STEP := "sayaka_lv5_part_a_main"
const B_STEP := "sayaka_lv5_part_b_main"
const C_STEP := "sayaka_lv5_part_c_main"

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

func choose_first_available(game: GameState, expected_choice_id: String = "") -> Dictionary:
	if game.active_special_event == null:
		return {"accepted": false}
	var node: Dictionary = game.active_special_event.current()
	for choice in node.get("choices", []):
		var choice_id := str(choice.get("id", ""))
		if not expected_choice_id.is_empty() and choice_id != expected_choice_id:
			continue
		if not game.special_requirements_met(choice.get("requirements", [])):
			continue
		return game.choose_special_event(choice_id)
	return {"accepted": false}

func play_to_completion(game: GameState, event_id: String, decision_node: String = "") -> Array[String]:
	var visited: Array[String] = []
	var safety := 0
	while game.special_event_in_progress() and game.active_special_event != null and safety < 700:
		var node: Dictionary = game.active_special_event.current()
		if node.is_empty():
			expect(false, "%s reached a missing node" % event_id)
			break
		var node_id := str(node.get("id", ""))
		visited.append(node_id)
		var wanted := "accept" if node_id == decision_node else ""
		var result := choose_first_available(game, wanted)
		expect(bool(result.get("accepted", false)), "%s could not advance at node %s" % [event_id, node_id])
		if not bool(result.get("accepted", false)):
			break
		safety += 1
	expect(safety < 700, "%s exceeded the event traversal safety limit" % event_id)
	expect(game.active_special_event != null and game.active_special_event.completed, "%s did not reach its authored ending" % event_id)
	return visited

func advance_to_non_sunday(game: GameState, days_after: int, clock: int) -> void:
	var target_day := game.day_number() + days_after
	while str(game.calendar_date(target_day).get("weekday_id", "")) == "sun":
		target_day += 1
	game.advance_story_to_day(target_day, clock)

func assert_cg(step: Dictionary, node_id: String, expected_path: String) -> void:
	var found := false
	for node in step.get("nodes", []):
		if str(node.get("id", "")) != node_id:
			continue
		found = true
		expect(str(node.get("cg_path", "")) == expected_path, "%s has the wrong CG path" % node_id)
		expect(ResourceLoader.exists("res://" + expected_path), "%s CG resource cannot be loaded: %s" % [node_id, expected_path])
		break
	expect(found, "CG node is missing: " + node_id)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content loader failed: " + str(content.errors))
	if failures > 0:
		finish()
		return

	var game := GameState.new()
	configure_game(game)
	var a_definition: Dictionary = game.special_event_definitions.get(EVENT_A, {})
	var b_definition: Dictionary = game.special_event_definitions.get(EVENT_B, {})
	var c_definition: Dictionary = game.special_event_definitions.get(EVENT_C, {})
	var a_step: Dictionary = game.special_event_step_definitions.get(A_STEP, {})
	var b_step: Dictionary = game.special_event_step_definitions.get(B_STEP, {})
	var c_step: Dictionary = game.special_event_step_definitions.get(C_STEP, {})
	expect(not a_definition.is_empty() and not b_definition.is_empty() and not c_definition.is_empty(), "One or more Lv5 event definitions are missing")
	expect(int(a_step.get("nodes", []).size()) == 161, "A segment node count changed from V3.2")
	expect(int(b_step.get("nodes", []).size()) == 304, "B segment node count changed from V3")
	expect(int(c_step.get("nodes", []).size()) == 137, "C segment node count changed from the authored script")
	assert_cg(a_step, "a04_0001", "assets/events/character_events/sayaka/lv5_story/CG_SAYAKA_PART_A.png")
	assert_cg(b_step, "b04_0001", "assets/events/character_events/sayaka/lv5_story/CG_A_SAYAKA_SURGERY_POV_SFW.png")
	assert_cg(c_step, "c03_0038", "assets/events/character_events/sayaka/lv5_story/CG_C_ASUKA_OFFICE_MEETING_SFW.png")
	for expression in ["base", "smile", "mischief", "blush", "roleplay_fear", "real_fear", "exhausted", "pain_shout", "pain_endure", "soft", "relieved"]:
		var portrait_path := "assets/characters/relationship_patient_v1/doc_sayaka/lv5_operating_table/%s.png" % expression
		expect(ResourceLoader.exists("res://" + portrait_path), "Operating-table portrait is missing: " + expression)

	# Generate the ordinary A prerequisites, then route through the real after-work scheduler.
	expect(game.prepare_special_event_test_save(EVENT_A, false), "Could not prepare isolated A-segment test state")
	game.set_test_time(game.day_number(), 16 * 60)
	expect(str(game.next_after_work_special_event().get("id", "")) == EVENT_A, "A segment did not enter the after-work queue when its gates were met")
	var test_day := game.day_number()
	expect(game.start_special_event(EVENT_A) != null, "A segment could not start from its scheduled state")
	var safety := 0
	while game.special_event_in_progress() and game.active_special_event != null and str(game.active_special_event.current().get("id", "")) != "a01_0014" and safety < 50:
		var result := choose_first_available(game)
		expect(bool(result.get("accepted", false)), "A segment could not reach the invitation choice")
		safety += 1
	expect(str(game.active_special_event.current().get("id", "")) == "a01_0014", "A segment invitation choice was not reached")
	var declined := game.choose_special_event("decline")
	expect(bool(declined.get("accepted", false)), "A segment decline branch was not selectable")
	var decline_reply := game.choose_special_event("a01_decline_sakaguchi_next")
	expect(bool(decline_reply.get("accepted", false)), "A decline did not advance from Sakaguchi to Sayaka")
	var cancelled := game.choose_special_event("a01_decline_sayaka_next")
	expect(bool(cancelled.get("accepted", false)) and bool(cancelled.get("cancelled", false)), "Declining A did not cancel cleanly")
	expect(not game.special_event_done(EVENT_A) and game.day_number() == test_day, "Declining A incorrectly completed the event or consumed time")
	expect(str(game.next_after_work_special_event().get("id", "")) == EVENT_A, "Declining A incorrectly removed it from the after-work queue")
	expect(game.start_special_event(EVENT_A) != null, "A segment could not be retried after a zero-cost decline")
	var a_visited := play_to_completion(game, EVENT_A, "a01_0014")
	expect("a01_accept_sakaguchi" in a_visited and "a01_decline_sakaguchi" not in a_visited, "A acceptance route took the wrong branch")
	expect(game.special_event_gallery_unlocked(EVENT_A), "A completion did not unlock its gallery entry")
	game.finish_special_event()

	# B must wait three days after A and be selected at end of work.
	advance_to_non_sunday(game, 3, 16 * 60)
	expect(str(game.next_after_work_special_event().get("id", "")) == EVENT_B, "B did not unlock after the authored three-day delay")
	expect(game.start_special_event(EVENT_B) != null, "B segment could not start from the after-work scheduler")
	play_to_completion(game, EVENT_B)
	expect(game.special_event_gallery_unlocked(EVENT_B), "B completion did not unlock its gallery entry")
	expect(game.relationship_level("doc_sayaka") == 5, "B completion did not award Sayaka Lv5")
	expect(game.relation_for("doc_sayaka").get("unlocked_benefits", []).has("unlock_clinical_practice_patient"), "B completion did not unlock the Lv5 benefit")
	game.finish_special_event()

	# C is the automatic day-start follow-up and grants the hospital-wide authorization.
	advance_to_non_sunday(game, 3, 9 * 60)
	expect(str(game.next_auto_special_event().get("id", "")) == EVENT_C, "C did not auto-schedule after the authored three-day delay")
	expect(game.start_special_event(EVENT_C) != null, "C segment could not start automatically")
	play_to_completion(game, EVENT_C)
	expect(game.special_event_gallery_unlocked(EVENT_C), "C completion did not unlock its gallery entry")
	expect(game.story_flag("staff_as_patient_program_authorized"), "C completion did not authorize staff-as-patient training")
	expect(game.story_flag("sayaka_repeatable_staff_training_unlocked"), "C completion did not unlock repeatable training")
	expect(game.can_save_progress() == false, "Active completed event should remain save-locked until dismissed")
	var before_replay: Dictionary = game.snapshot()
	var replay_steps := {A_STEP: a_step, B_STEP: b_step, C_STEP: c_step}
	var replay := SpecialEvent.new(c_definition, replay_steps, game.day_number())
	var replay_guard := 0
	while not replay.completed and replay_guard < 200:
		var replay_node: Dictionary = replay.current()
		var replay_choices: Array = replay_node.get("choices", [])
		if replay_choices.is_empty():
			break
		var replay_choice: Dictionary = replay_choices[0]
		if str(replay_choice.get("next", "")) == "@cancel":
			break
		replay.apply(str(replay_choice.get("id", "")))
		replay_guard += 1
	expect(replay.completed and replay_guard < 200, "C gallery replay did not reach its ending")
	expect(game.snapshot() == before_replay, "C gallery replay changed the live game state")
	game.finish_special_event()
	expect(game.can_save_progress(), "Save lock was not released after dismissing the completed event")
	expect(game.staff_patient_unlocked("doc_sayaka"), "Part C did not unlock Sayaka's patient invitation")

	finish()

func finish() -> void:
	print("SAYAKA LV5 EVENT TEST: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
