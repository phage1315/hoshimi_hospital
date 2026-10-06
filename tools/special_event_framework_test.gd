extends SceneTree
const GameState = preload("res://godot/systems/game_state.gd")
const SpecialEvent = preload("res://godot/systems/special_event_session.gd")
const CharacterEvent = preload("res://godot/systems/character_event_session.gd")

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func configure_clone(clone, app) -> void:
	clone.configure(app.content.collections.encounters, app.content.collections.preops, app.content.collections.staff, app.content.collections.time_events, app.content.collections.surgeries, app.content.collections.patients, app.content.collections.relationships, app.content.collections.character_events, app.content.collections.case_templates, app.content.collections.micro_events, app.content.collections.examination_cg_pools, app.content.collections.surgery_team_dialogue_profiles, app.content.collections.patient_interactions, app.content.collections.temporary_conditions, app.content.collections.staff_role_cg_rewards, app.content.collections.special_events, app.content.collections.special_event_steps)

func replay_for(game, event_id: String):
	var definition: Dictionary = game.special_event_definitions[event_id]
	var steps := {}
	for step_id in definition.event_chain:
		steps[str(step_id)] = game.special_event_step_definitions[str(step_id)]
	return SpecialEvent.new(definition, steps, 1)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var hub_app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(hub_app)
	await process_frame
	hub_app.title_screen()
	expect(hub_app.page.get_node_or_null("EventTestHubEntry") != null, "Debug title screen is missing the event-test hub entry")
	hub_app.show_event_test_hub()
	expect(hub_app.screen == "event_test_hub" and hub_app.page.get_node_or_null("EventTestScroll") != null, "Event-test hub did not open")
	expect(hub_app.page.find_child("EventTest_advanced_referral_tutorial_chisato", true, false) != null, "Event-test hub omitted the Chisato tutorial")
	for event_id in hub_app.game.special_event_definitions:
		if str(event_id) != "advanced_referral_tutorial_chisato":
			expect(hub_app.page.find_child("EventTest_" + str(event_id), true, false) == null, "Backlog event %s is still visible in the event-test hub" % str(event_id))
	hub_app.begin_special_event_test_from_title("advanced_referral_tutorial_chisato")
	expect(hub_app.screen == "special_event" and hub_app.game.active_special_event_id == "advanced_referral_tutorial_chisato", "Event-test hub could not launch the Chisato tutorial from a clean state")
	hub_app.queue_free()
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.show_map()
	expect(app.screen == "map" and app.page.get_node_or_null("SpecialEventsButton") != null, "Map special-event entry is missing")
	var single: Dictionary = app.game.special_event_definitions["framework_single_day_test"]
	expect(not app.game.special_event_available(single), "Locked single-day event became available")
	app.game.set_story_flag("special_event_test_unlocked")
	expect(app.game.special_event_available(single), "Single-day event did not unlock from its flag")
	single.developer_only = false
	app.show_special_events()
	expect(app.page.find_child("SpecialEvent_framework_single_day_test", true, false) != null, "Unlocked event did not appear in the activity list")
	app.confirm_special_event(single.id)
	expect(app.screen == "special_event_confirm", "Full-day confirmation was not shown")
	var first_day: int = app.game.day_number()
	app.begin_special_event()
	expect(app.screen == "special_event", "Single-day event did not start from the confirmation")
	expect(app.game.active_mode == "special_event" and app.game.special_event_in_progress(), "Special event did not lock the active mode")
	expect(app.game.time_events_at("lounge").is_empty(), "Ordinary time actions remained available during a special event")
	var patient_id: String = app.game.current_patient_id()
	expect(app.game.open_visit(app.game.encounter_id_for_patient(patient_id)) == null, "Ordinary clinical work started during a special event")
	app.show_location("lounge")
	expect(app.screen == "special_event", "Location navigation escaped the special-event lock")
	var first_choice: Dictionary = app.game.choose_special_event("continue")
	expect(first_choice.accepted and not first_choice.day_finished, "In-day special-event node did not advance")
	var finish_choice: Dictionary = app.game.choose_special_event("finish")
	expect(finish_choice.day_finished and finish_choice.event_finished, "Single-day event did not finish its full day")
	expect(app.game.day_number() == first_day + 1, "Single-day event did not advance exactly one day")
	expect(app.game.story_flag("framework_single_day_completed") and app.game.special_event_done(single.id), "Single-day completion flag/history missing")
	expect(app.game.special_event_gallery_unlocked(single.id), "Completed event did not unlock gallery replay")
	app.game.finish_special_event()
	app.show_event_gallery()
	expect(app.page.find_child("GallerySpecial_framework_single_day_test", true, false) != null, "Completed special event was not listed in the gallery")
	expect(not app.game.special_event_available(single) and app.game.start_special_event(single.id) == null, "One-time event could start twice")

	var zero_time := single.duplicate(true)
	zero_time.id = "framework_zero_time_test"
	zero_time.consumes_full_day = false
	zero_time.unlock_requirements = []
	zero_time.completion_flags = []
	zero_time.gallery_unlock = false
	app.game.special_event_definitions[zero_time.id] = zero_time
	var zero_start_day := app.game.day_number()
	var zero_start_elapsed := app.game.elapsed()
	expect(app.game.start_special_event(zero_time.id) != null, "Zero-time special event did not start")
	expect(app.game.choose_special_event("continue").accepted, "Zero-time event did not advance")
	var zero_finish: Dictionary = app.game.choose_special_event("finish")
	expect(zero_finish.event_finished and not zero_finish.day_finished, "Zero-time event incorrectly requested a day transition")
	expect(app.game.day_number() == zero_start_day and app.game.elapsed() == zero_start_elapsed, "Zero-time event advanced the calendar or clock")
	app.game.finish_special_event()

	var before_replay: Dictionary = app.game.snapshot()
	var replay = replay_for(app.game, single.id)
	expect(replay.apply("continue") and replay.apply("finish") and replay.completed, "Gallery replay could not play the completed event")
	expect(app.game.snapshot() == before_replay, "Gallery replay changed normal-world state")

	var multi: Dictionary = app.game.special_event_definitions["framework_three_day_test"]
	expect(app.game.special_event_available(multi), "Three-day prerequisite did not unlock")
	var multi_start: int = app.game.day_number()
	expect(app.game.start_special_event(multi.id) != null, "Three-day event did not start")
	var day_one: Dictionary = app.game.choose_special_event("day_1_done")
	expect(day_one.day_finished and not day_one.event_finished and app.game.active_special_event.step_index == 1, "Day 1 did not chain automatically to Day 2")
	var mid_save: Dictionary = app.game.snapshot()
	var clone = GameState.new()
	configure_clone(clone, app)
	expect(clone.restore(JSON.parse_string(JSON.stringify(mid_save))), "In-progress multi-day event save did not restore")
	expect(clone.active_mode == "special_event" and clone.active_special_event.step_index == 1, "Restored event lost its day/step lock")
	var day_two: Dictionary = clone.choose_special_event("day_2_done")
	expect(day_two.day_finished and not day_two.event_finished and clone.active_special_event.step_index == 2, "Day 2 did not chain automatically to Day 3")
	var day_three: Dictionary = clone.choose_special_event("day_3_done")
	expect(day_three.day_finished and day_three.event_finished, "Day 3 did not complete the event")
	expect(clone.day_number() == multi_start + 3, "Three-day event did not consume three complete days")
	expect(clone.story_flag("framework_three_day_completed") and clone.special_event_gallery_unlocked(multi.id), "Three-day completion rewards/gallery missing")
	clone.finish_special_event()
	expect(clone.active_special_event_id.is_empty() and clone.active_mode == "encounter", "Event lock was not released after completion")

	var auto_app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(auto_app)
	await process_frame
	auto_app.game.meet_staff("doc_asuka")
	auto_app.game.meet_staff("doc_sayaka")
	var app_asuka_intro = CharacterEvent.new(auto_app.game.character_event_definitions["intro_doc_asuka_director_office"])
	app_asuka_intro.completed = true
	app_asuka_intro.completed_day = 1
	auto_app.game.character_events["intro_doc_asuka_director_office"] = app_asuka_intro
	auto_app.game.advance_story_to_day(7, 540)
	auto_app.show_map()
	expect(auto_app.screen == "special_event" and auto_app.game.active_special_event_id == "or_acceptance_training_01", "Due automatic event did not start immediately at 09:00")
	expect(auto_app.screen != "special_event_confirm", "Automatic event exposed a confirmation/refusal screen")
	while auto_app.game.special_event_in_progress():
		var current_auto_node: Dictionary = auto_app.game.active_special_event.current()
		var current_auto_choice: Dictionary = current_auto_node.get("choices", [])[0]
		auto_app.game.choose_special_event(str(current_auto_choice.id))
	auto_app.game.finish_special_event()
	auto_app.queue_free()

	var scheduled = GameState.new()
	configure_clone(scheduled, app)
	scheduled.meet_staff("doc_asuka")
	scheduled.meet_staff("doc_sayaka")
	var asuka_intro = CharacterEvent.new(scheduled.character_event_definitions["intro_doc_asuka_director_office"])
	asuka_intro.completed = true
	asuka_intro.completed_day = 1
	scheduled.character_events["intro_doc_asuka_director_office"] = asuka_intro
	var acceptance: Dictionary = scheduled.special_event_definitions["or_acceptance_training_01"]
	scheduled.advance_story_to_day(5, 540)
	expect(not scheduled.special_event_base_requirements_met(acceptance), "OR acceptance unlocked before the five-day delay")
	scheduled.advance_story_to_day(6, 540)
	expect(scheduled.special_event_base_requirements_met(acceptance), "OR acceptance did not unlock after the five-day delay")
	expect(scheduled.special_event_timing_status(acceptance).status == "sunday_deferred", "Sunday did not defer the automatically scheduled OR acceptance")
	scheduled.advance_story_to_day(7, 540)
	expect(scheduled.next_auto_special_event().get("id", "") == acceptance.id, "OR acceptance was not automatically selected on the next workday")
	expect(scheduled.start_special_event(acceptance.id) != null, "OR acceptance could not start on its scheduled workday")
	var acceptance_steps := 0
	while scheduled.special_event_in_progress() and acceptance_steps < 100:
		var available_choice: Dictionary = {}
		for candidate in scheduled.active_special_event.current().get("choices", []):
			if scheduled.special_requirements_met(candidate.get("requirements", [])):
				available_choice = candidate
				break
		expect(not available_choice.is_empty(), "OR acceptance reached a node without an available choice")
		if available_choice.is_empty():
			break
		scheduled.choose_special_event(str(available_choice.id))
		acceptance_steps += 1
	expect(scheduled.active_special_event.completed and acceptance_steps < 100, "OR acceptance main route did not reach its ending")
	expect(scheduled.story_flag("or_acceptance_training_01_completed") and scheduled.story_flag("new_or_accepted") and scheduled.story_flag("positioning_tutorial_seen") and scheduled.story_flag("sayaka_first_volunteer_gag"), "OR acceptance completion flags were not written")
	expect(scheduled.special_event_gallery_unlocked(acceptance.id), "OR acceptance did not unlock its gallery replay")

	var optional_cast = GameState.new()
	configure_clone(optional_cast, app)
	for actor_id in ["doc_asuka", "doc_sayaka", "pharmacist_manami", "doc_aqua", "nurse_hiroko", "doc_shiori", "doc_rei", "nurse_ange", "nurse_moe"]:
		optional_cast.meet_staff(actor_id)
	var optional_intro = CharacterEvent.new(optional_cast.character_event_definitions["intro_doc_asuka_director_office"])
	optional_intro.completed = true
	optional_intro.completed_day = 1
	optional_cast.character_events["intro_doc_asuka_director_office"] = optional_intro
	optional_cast.advance_story_to_day(7, 540)
	expect(optional_cast.start_special_event(acceptance.id) != null, "OR acceptance with optional cast could not start")
	var visited_optional_nodes: Array[String] = []
	var optional_steps := 0
	while optional_cast.special_event_in_progress() and optional_steps < 100:
		var current_node: Dictionary = optional_cast.active_special_event.current()
		visited_optional_nodes.append(str(current_node.get("id", "")))
		var next_choice: Dictionary = current_node.get("choices", [])[0]
		optional_cast.choose_special_event(str(next_choice.id))
		optional_steps += 1
	for optional_node_id in ["manami_line", "aqua_line", "hiroko_line", "shiori_line", "kaori_line", "ange_line", "moe_line"]:
		expect(optional_node_id in visited_optional_nodes, "Known optional participant was skipped: " + optional_node_id)
	expect(optional_cast.active_special_event.completed, "OR acceptance optional-cast route did not reach its ending")

	var low_priority := {
		"id": "timing_low", "duration_days": 3, "repeatable": false, "developer_only": false,
		"required_characters": [], "prerequisite_events": [], "unlock_requirements": [],
		"timing": {"trigger_day": 9, "priority": 10, "final_week_allowed": false},
	}
	var high_priority := {
		"id": "timing_high", "duration_days": 1, "repeatable": false, "developer_only": false,
		"required_characters": [], "prerequisite_events": [], "unlock_requirements": [],
		"timing": {"trigger_day": 10, "priority": 100, "final_week_allowed": false},
	}
	clone.special_event_definitions[low_priority.id] = low_priority
	clone.special_event_definitions[high_priority.id] = high_priority
	clone.advance_story_to_day(9, 540)
	var delayed: Dictionary = clone.special_event_timing_status(low_priority)
	expect(delayed.status == "postponed" and delayed.blocked_by == high_priority.id and delayed.effective_day == 11, "Lower-priority multi-day event was not postponed around a future high-priority trigger")
	expect(clone.special_event_timing_status(high_priority).status == "future", "High-priority event triggered before its authored day")
	clone.advance_story_to_day(10, 540)
	expect(clone.special_event_available(high_priority) and clone.special_event_timing_status(low_priority).status == "postponed", "Due high-priority event did not keep the conflicting event delayed")
	clone.special_event_completion_counts[high_priority.id] = 1
	expect(clone.special_event_available(low_priority), "Delayed event did not return after the higher-priority event completed")

	var last_normal_day := low_priority.duplicate(true)
	last_normal_day.id = "timing_last_normal_day"
	last_normal_day.duration_days = 1
	last_normal_day.timing = {"trigger_day": 358, "priority": 200, "final_week_allowed": false}
	var crosses_final_week := last_normal_day.duplicate(true)
	crosses_final_week.id = "timing_crosses_final_week"
	crosses_final_week.duration_days = 2
	var ending_event := last_normal_day.duplicate(true)
	ending_event.id = "timing_ending_event"
	ending_event.duration_days = 7
	ending_event.timing = {"trigger_day": 359, "priority": 500, "final_week_allowed": true}
	var overflow_event := ending_event.duplicate(true)
	overflow_event.id = "timing_overflow_event"
	overflow_event.duration_days = 8
	for definition in [last_normal_day, crosses_final_week, ending_event, overflow_event]:
		clone.special_event_definitions[definition.id] = definition
	clone.advance_story_to_day(358, 540)
	expect(clone.special_event_timing_status(last_normal_day).status == "available", "Day 358 should remain available to a one-day ordinary event")
	expect(clone.special_event_timing_status(crosses_final_week).status == "final_week_reserved", "Ordinary event was allowed to cross into the final week")
	clone.advance_story_to_day(359, 540)
	expect(clone.special_event_timing_status(ending_event).status == "available", "Explicit ending event was blocked from the final week")
	expect(clone.special_event_timing_status(overflow_event).status == "expired", "Event extending past Day 365 was not rejected")
	print("SPECIAL EVENTS: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
