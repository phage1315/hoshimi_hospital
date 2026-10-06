extends SceneTree

const GameState = preload("res://godot/systems/game_state.gd")

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func configure_clone(clone, app) -> void:
	clone.configure(app.content.collections.encounters, app.content.collections.preops, app.content.collections.staff, app.content.collections.time_events, app.content.collections.surgeries, app.content.collections.patients, app.content.collections.relationships, app.content.collections.character_events, app.content.collections.case_templates, app.content.collections.micro_events, app.content.collections.examination_cg_pools, app.content.collections.surgery_team_dialogue_profiles, app.content.collections.patient_interactions, app.content.collections.temporary_conditions, app.content.collections.staff_role_cg_rewards, app.content.collections.special_events, app.content.collections.special_event_steps, app.content.collections.date_profiles, app.content.collections.date_locations)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.game.advance_story_to_day(6, 540)
	app.game.meet_staff("doc_sayaka")
	app.game.relation_for("doc_sayaka").flags.append_array(["sayaka_phone_exchanged", "sayaka_sunday_invite_available"])
	app.show_map()
	expect(app.game.calendar_iso() == "2025-04-06" and app.game.is_sunday(), "First Sunday date is wrong")
	expect(app.screen == "sunday_menu" and app.page.get_node_or_null("SundayInvite") != null, "Sunday menu did not replace the normal map")
	expect(app.game.sunday_date_candidates() == ["doc_sayaka"], "Sayaka's authored Lv0 Sunday exception did not enter the invitation list")
	expect(app.game.date_profile_definitions.has("doc_sayaka") and bool(app.game.date_profile_definitions["doc_sayaka"].get("can_date", false)), "Sayaka date profile should be enabled once her first-date event exists")
	app.show_sunday_invites()
	expect(app.screen == "sunday_invites", "Empty invitation screen did not open")
	app.show_sunday_hospital_map()
	expect(app.screen == "map" and app.page.get_node_or_null("Location_ward") != null, "Sunday hospital map did not open")
	expect(app.page.get_node_or_null("Location_clinic") == null, "Closed outpatient clinic appeared on the Sunday map")
	expect(app.page.get_node_or_null("Location_or") != null, "Sunday operating-room corridor should remain visitable")
	expect(app.page.get_node_or_null("SundayHospitalEnd") != null, "Sunday hospital visit has no end-day action")

	app.game.date_profile_definitions["doc_sayaka"].can_date = false
	app.game.date_profile_definitions["doc_aoi"] = {"staff_id": "doc_aoi", "can_date": true, "minimum_level": 0}
	app.game.meet_staff("doc_aoi")
	var candidates: Array[String] = app.game.sunday_date_candidates()
	expect(candidates == ["doc_aoi"], "Known enabled character did not enter the deterministic Sunday list")
	var original_roll: int = app.game.stable_sunday_roll("doc_aoi", "invitation")
	var before_activity: Dictionary = app.game.snapshot()
	var clone = GameState.new()
	configure_clone(clone, app)
	clone.date_profile_definitions["doc_aoi"] = {"staff_id": "doc_aoi", "can_date": true, "minimum_level": 0}
	expect(clone.restore(JSON.parse_string(JSON.stringify(before_activity))), "Sunday save state did not restore")
	expect(clone.stable_sunday_roll("doc_aoi", "invitation") == original_roll, "Loading changed the invitation result")
	expect(clone.sunday_date_candidates() == candidates, "Loading changed the Sunday candidate list")

	app.show_sunday_office_menu()
	expect(app.screen == "sunday_office" and app.page.get_node_or_null("SundayOfficeAction_0") != null, "Sunday office choices are missing")
	app.finish_sunday_activity("office_0", "test")
	expect(app.game.day_number() == 7 and app.game.sunday_activity_done(6), "Sunday activity did not consume exactly one day")
	expect(app.screen == "sunday_complete", "Sunday completion screen was not shown")
	expect(not app.game.complete_sunday_activity("rest_home"), "A second Sunday activity was allowed after the day ended")

	print("SUNDAY SYSTEM: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
