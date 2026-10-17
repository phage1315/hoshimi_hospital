extends SceneTree

const App = preload("res://godot/scenes/main.tscn")
const Event = preload("res://godot/systems/character_event_session.gd")
const Registry = preload("res://godot/systems/free_h_registry.gd")
const Store = preload("res://godot/systems/save_store.gd")
var checks := 0
var failures := 0
var app: Control

func expect(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func fixture(day: int = 8) -> void:
	dismiss_notices()
	app.game.reset()
	app.screen = "map"
	app.h_profile_run_kind = "test"
	app.h_profile_event_mode = false
	app.h_profile_test_session = null
	app.game.meet_staff("doc_sayaka")
	var relation: Dictionary = app.game.relation_for("doc_sayaka")
	relation.level = 4
	relation.route = "romance"
	relation.rank_history = ["sayaka_lv4_hotel_date"]
	relation.unlocked_benefits = ["unlock_intimacy_events"]
	var definition: Dictionary = app.game.character_event_definitions["sayaka_lv4_hotel_date"]
	var event := Event.new(definition)
	event.node_id = str(definition.nodes[-1].id)
	event.completed = true
	event.completed_day = 6
	app.game.character_events["sayaka_lv4_hotel_date"] = event
	app.game.character_event_order.append("sayaka_lv4_hotel_date")
	app.game.set_story_flag("sayaka_lv4_complete")
	app.game.advance_story_to_day(day, 9 * 60)

func dismiss_notices() -> void:
	for child in app.get_children():
		if child is AcceptDialog:
			child.hide()
			child.queue_free()

func persisted_values() -> Dictionary:
	var result: Dictionary = {}
	for key in ["relationships", "story_flags", "surgery_xp", "leadership_xp", "archived_player_effects", "sunday_history", "completed_surgeries_total", "completed_surgeries_by_procedure"]:
		var value: Variant = app.game.get(key)
		result[key] = value.duplicate(true) if value is Dictionary or value is Array else value
	return result

func departure_story_fixture() -> void:
	var definition: Dictionary = app.game.character_event_definitions["sayaka_lv4_hospital_callback"].duplicate(true)
	definition.id = "fixture_exclusive_departure"
	definition.trigger_mode = "after_work"
	definition.category = "side"
	definition.conditions = {"min_day": 8, "max_day": 8, "required_events": []}
	definition.time_start = 16 * 60
	definition.time_end = 26 * 60
	definition.target_level = 0
	app.game.character_event_definitions[definition.id] = definition

func finish_ui_session() -> void:
	await create_timer(1.0).timeout
	expect(app.h_profile_test_session != null, "Production session failed to start")
	if app.h_profile_test_session == null:
		return
	expect(app.h_profile_run_kind == "free" and not app.h_profile_event_mode, "Wrong run kind")
	expect(app.h_profile_test_session.event_id.is_empty(), "Milestone context leaked into ordinary session")
	expect(app.h_profile_test_session.profile.context_overrides.events.is_empty(), "Milestone overlays remained registered")
	expect(app.game.active_adult_intimacy == null, "Legacy runner was used")
	expect(not app.game.can_save_progress(), "Entry allowed saves")
	var entry_count: int = app.h_profile_test_entry_lines.size()
	expect(entry_count > 0, "Missing location entry")
	for index in range(entry_count):
		app._advance_sayaka_h_entry()
	expect(app.h_profile_test_entry_lines.is_empty(), "Entry sequence not consumed")
	# Exercise the unchanged runner at its stage boundary; its individual
	# interactions have a dedicated existing system/UI regression suite.
	app.h_profile_test_session.excitement = 100
	app._choose_sayaka_h_entry_style("gentle")
	expect(app.h_profile_test_session.selected_h_scene_lines.size() == 6, "First-event one-shot lines leaked into repeatable flow")
	for index in range(6):
		app._advance_sayaka_h_stage()
	expect(app.h_profile_test_session.phase == "h_finish_wait", "Missing manual completion boundary")
	app._choose_sayaka_h_finish()
	expect(not app.game.can_save_progress(), "Completion response allowed saves")
	app._advance_sayaka_h_stage()
	await create_timer(4.8).timeout
	expect(app.h_profile_test_session != null and app.h_profile_test_session.phase == "after_cg", "Ordinary completion did not retain its runner")
	if app.h_profile_test_session == null:
		return
	expect(not app.game.free_h_booking.is_empty() and not app.game.can_save_progress(), "Booking cleared before completion text ended")
	app._advance_sayaka_h_aftercare()
	expect(not app.game.active_free_h_departure.is_empty(), "Departure ended before last line")
	app._advance_sayaka_h_aftercare()
	app._advance_sayaka_h_aftercare()
	expect(app.screen == "day_transition" and app.h_profile_test_session == null, "Session returned to debug hub instead of day end")
	expect(app.game.free_h_booking.is_empty() and app.game.active_free_h_departure.is_empty(), "Departure cleanup failed")

func verify_milestone_roundtrip() -> void:
	dismiss_notices()
	app.begin_sayaka_lv4_event_test()
	app.start_sunday_character_event("sayaka_lv4_hotel_date")
	var reached_session := false
	for step in range(140):
		if app.game.story_flag("sayaka_lv4_complete"):
			break
		var event: RefCounted = app.game.character_events.get(app.game.active_character_event_id)
		if event == null or event.current().get("choices", []).is_empty():
			expect(false, "Milestone lost its continuation")
			break
		app.choose_character_event(str(event.current().choices[0].id))
		if app.h_profile_test_session != null:
			reached_session = true
			expect(app.h_profile_event_mode and app.h_profile_run_kind == "milestone", "Milestone launch used ordinary completion handling")
			app.h_profile_test_session.excitement = 100
			app._choose_sayaka_h_entry_style("gentle")
			expect(app.h_profile_test_session.selected_h_scene_lines.size() == 9, "Milestone-specific overlay missing")
			for line in range(9):
				app._advance_sayaka_h_stage()
			app._choose_sayaka_h_finish()
			app._advance_sayaka_h_stage()
			await create_timer(4.8).timeout
			expect(app.h_profile_test_session == null and app.game.active_character_event_id == "sayaka_lv4_hotel_date", "Milestone did not return to its authored continuation")
	expect(reached_session and app.game.story_flag("sayaka_lv4_complete"), "Full milestone route failed to complete")
	expect(app.game.day_number() == 7 and app.game.relationship_level("doc_sayaka") == 4, "Milestone failed its original rank/calendar settlement")
	expect(app.game.free_h_unlocked("doc_sayaka") and app.game.free_h_booking.is_empty(), "Natural completion did not unlock future booking independently")

func run() -> void:
	app = App.instantiate() as Control
	root.add_child(app)
	await process_frame
	fixture()
	expect(Registry.definition("doc_emiko").is_empty(), "Future route was prematurely opened")
	var bundle := Registry.load_bundle("doc_sayaka")
	expect(not bundle.has("error"), "Production resource validation: " + str(bundle.get("error", "")))
	expect(str(bundle.get("location_id", "")) == "hotel", "Single registered location missing")
	var broken_profile: Dictionary = bundle.profile.duplicate(true)
	broken_profile.context_overrides.base.assets.h_stage.path = "res://missing_fixture_image.png"
	expect(Registry.validate_bundle("doc_sayaka", "hotel", broken_profile, bundle.bodymap, "zh_CN").has("error"), "Missing image silently fell back")
	broken_profile = bundle.profile.duplicate(true)
	broken_profile.location_entry.erase("hotel")
	expect(Registry.validate_bundle("doc_sayaka", "hotel", broken_profile, bundle.bodymap, "zh_CN").has("error"), "Missing location pool used another location")
	var broken_map: Dictionary = bundle.bodymap.duplicate(true)
	broken_map.image_width = 17
	expect(Registry.validate_bundle("doc_sayaka", "hotel", bundle.profile, broken_map, "zh_CN").has("error"), "Mismatched hit map was accepted")
	app.game.relationships.doc_sayaka.level = 3
	app.game.story_flags.erase("sayaka_lv4_complete")
	expect(not app.game.can_book_free_h("doc_sayaka", "clinic"), "Uncompleted milestone unlocked booking")
	app.game.relationships.doc_sayaka.level = 4
	expect(not app.game.can_book_free_h("doc_sayaka", "clinic"), "Level alone unlocked booking")
	app.game.set_story_flag("sayaka_lv4_complete")
	app.game.relationships.doc_sayaka.familiarity = 0
	expect(app.game.can_book_free_h("doc_sayaka", "clinic"), "A second familiarity threshold was introduced")
	expect(not app.game.can_book_free_h("doc_sayaka", "missing_location"), "Remote invitation allowed")
	expect(not app.game.can_book_free_h("doc_ange", "clinic"), "Nonparticipating route unlocked")
	app.game.relationships.doc_sayaka.met = false
	expect(not app.game.can_book_free_h("doc_sayaka", "clinic"), "Unmet actor unlocked")
	app.game.relationships.doc_sayaka.met = true
	app.game.active_micro_event_id = "fixture"
	expect(not app.game.can_book_free_h("doc_sayaka", "clinic"), "Active story allowed invitation")
	app.game.active_micro_event_id = ""
	var before := persisted_values()
	var elapsed_before: int = app.game.elapsed()
	expect(app.game.book_free_h("doc_sayaka", "clinic"), "Eligible invitation failed")
	expect(app.game.book_free_h("doc_sayaka", "clinic"), "Same actor booking was not idempotent")
	expect(app.game.free_h_booking.size() == 2 and not app.game.free_h_booking.has("location_id"), "Booking stores more than day and actor")
	expect(app.game.elapsed() == elapsed_before and persisted_values() == before, "Booking charged time or permanent values")
	app.game.free_h_booking.actor_id = "fixture_previous_actor"
	expect(not app.game.book_free_h("doc_sayaka", "clinic"), "Replacement skipped confirmation")
	expect(app.game.free_h_booking.actor_id == "fixture_previous_actor", "Unconfirmed replacement mutated booking")
	expect(app.game.book_free_h("doc_sayaka", "clinic", "fixture_previous_actor"), "Confirmed replacement failed")
	var saved: Dictionary = app.game.snapshot()
	var store := Store.new()
	store.path = "/tmp/hoshimi-free-h-booking-%d.json" % OS.get_process_id()
	expect(store.write_slot(app.game, 1), "Booked save could not be written")
	app.game.cancel_free_h_booking()
	expect(store.read_slot(app.game, 1) and app.game.free_h_booking == saved.free_h_booking, "Disk save did not restore appointment")
	DirAccess.remove_absolute(store.path)
	expect(app.game.restore(saved), "Booked save failed to restore: " + str(app.game.last_error))
	expect(app.game.free_h_booking == saved.free_h_booking, "Booking did not survive restore")
	saved.erase("free_h_booking")
	expect(app.game.restore(saved) and app.game.free_h_booking.is_empty(), "Old save did not default to no booking")
	expect(app.game.book_free_h("doc_sayaka", "clinic"), "Rebooking failed")
	expect(app.game.cancel_free_h_booking() and app.game.free_h_booking.is_empty(), "Cancellation failed")
	app.show_staff("doc_sayaka", "clinic")
	expect(app.page.get_node_or_null("FreeHBooking") != null, "Normal character menu has no invitation")
	app._confirm_free_h_booking("doc_sayaka", "clinic", "")
	dismiss_notices()
	app.show_player_office()
	expect(app.page.get_node_or_null("FreeHBookingSummary") != null, "Office is missing schedule hint")
	app.game.advance_story_to_day(8, 16 * 60)
	app.game.active_preop_id = "fixture_active_patient"
	expect(not app.game.claim_free_h_departure(8, 16 * 60, true), "Medical lock was bypassed")
	app.game.active_preop_id = ""
	before = persisted_values()
	app.request_end_workday()
	app.request_end_workday()
	app.show_day_transition(app.show_map)
	expect(not app.game.active_free_h_departure.is_empty(), "Manual exit failed to claim departure")
	expect(not app.game.begin_after_work_departure(8, 16 * 60, true), "Random walk ran after appointment claimed departure")
	await finish_ui_session()
	expect(app.game.day_number() == 9, "Manual departure advanced date more than once")
	expect(app.game.finish_free_h_departure().is_empty() and app.game.day_number() == 9, "Second completion advanced date")
	expect(persisted_values() == before, "Repeatable event changed permanent values or walk cooldown")
	app.continue_after_day_transition()
	app.game.active_character_event_id = ""
	expect(app.game.can_book_free_h("doc_sayaka", "clinic"), "Adjacent workday received an extra cooldown")
	fixture(5)
	expect(app.game.book_free_h("doc_sayaka", "clinic"), "Saturday booking failed")
	var start: int = app.game.elapsed()
	app.game.story_time_advance_minutes += 15 * 60 + 30
	expect(app.game.settle_overtime(start, 15 * 60 + 30), "Overtime fixture failed")
	expect(app.game.pending_day_exit_workday == 5 and app.game.pending_day_exit_clock == 24 * 60 + 30, "Midnight workday anchor incorrect")
	before = persisted_values()
	app.show_day_transition(app.show_map)
	app.request_end_workday()
	await finish_ui_session()
	expect(app.game.day_number() == 6, "Overtime advanced the already-reserved day twice")
	expect(persisted_values() == before, "Overtime repeatable event awarded permanent values")
	app.continue_after_day_transition()
	expect(app.screen == "sunday_menu", "Saturday departure did not route into Sunday menu")
	fixture()
	app.game.book_free_h("doc_sayaka", "clinic")
	app.game.advance_story_to_day(10, 9 * 60)
	expect(app.game.free_h_booking.is_empty(), "Multi-day forced story retained stale appointment")
	fixture()
	departure_story_fixture()
	expect(not app.game.can_book_free_h("doc_sayaka", "clinic"), "Known exclusive departure story allowed booking")
	app.game.character_event_definitions.erase("fixture_exclusive_departure")
	app.game.book_free_h("doc_sayaka", "clinic")
	departure_story_fixture()
	app.game.advance_story_to_day(8, 16 * 60)
	app.request_end_workday()
	expect(app.game.active_character_event_id == "fixture_exclusive_departure" and app.game.free_h_booking.is_empty(), "Late exclusive story did not cancel manual booking")
	app.game.character_event_definitions.erase("fixture_exclusive_departure")
	fixture()
	app.game.book_free_h("doc_sayaka", "clinic")
	departure_story_fixture()
	start = app.game.elapsed()
	app.game.story_time_advance_minutes += 15 * 60 + 30
	app.game.settle_overtime(start, 15 * 60 + 30)
	app.show_day_transition(app.show_map)
	expect(app.game.active_character_event_id == "fixture_exclusive_departure" and app.game.free_h_booking.is_empty(), "Overtime exclusive story lost its workday priority")
	app.game.character_event_definitions.erase("fixture_exclusive_departure")
	fixture()
	app.game.book_free_h("doc_sayaka", "clinic")
	app.game.set_story_flag("sayaka_lv4_complete", false)
	app.game.advance_story_to_day(8, 16 * 60)
	app.request_end_workday()
	expect(app.game.free_h_booking.is_empty() and app.game.active_free_h_departure.is_empty(), "Invalidated unlock left a dangling booking")
	fixture(7)
	app.game.book_free_h("doc_sayaka", "clinic")
	app.game.set_story_flag("sayaka_lv4_next_morning_callback_pending")
	app.game.set_story_flag("sayaka_lv4_callback_target_day:7")
	app.game.advance_story_to_day(7, 16 * 60)
	app.request_end_workday()
	expect(app.game.active_character_event_id == "sayaka_lv4_hospital_callback" and app.game.free_h_booking.is_empty(), "Monday callback did not take priority and cancel conflicting booking")
	app.game.reset()
	app.h_profile_run_kind = "test"
	app.begin_sayaka_h_profile_test("hotel", "sayaka_lv4_first_h")
	expect(app.h_profile_event_mode and app.h_profile_run_kind == "milestone", "Original milestone entry lost its dedicated context")
	expect(app.h_profile_test_entry_lines.is_empty(), "Milestone replayed ordinary location entry")
	expect(app.content.load_all("en"), "English content failed to load")
	app.configure_game_content()
	fixture()
	app.show_staff("doc_sayaka", "clinic")
	var invitation := app.page.get_node_or_null("FreeHBooking") as Button
	expect(invitation != null and invitation.text == "Arrange to spend tonight together", "English invitation is missing")
	app.game.book_free_h("doc_sayaka", "clinic")
	expect(app.free_h_booking_label().begins_with("Tonight:") and app.free_h_booking_label().ends_with("Hotel"), "English schedule hint missing")
	app.game.advance_story_to_day(8, 16 * 60)
	app.request_end_workday()
	await finish_ui_session()
	expect(app.game.day_number() == 9, "English production path failed to finalize once")
	await verify_milestone_roundtrip()
	print("FREE H SCHEDULING: %d checks; %d failures" % [checks, failures])
	app.queue_free()
	await process_frame
	quit(1 if failures else 0)
