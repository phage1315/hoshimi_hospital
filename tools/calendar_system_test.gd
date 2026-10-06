extends SceneTree

const GameState = preload("res://godot/systems/game_state.gd")
const FixedCalendar = preload("res://godot/systems/fixed_calendar.gd")

class DummyVisit extends RefCounted:
	var minutes := 0

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var game = GameState.new()
	expect(game.calendar_iso() == "2025-04-01", "Day 1 is not 2025-04-01")
	expect(game.calendar_date().weekday_id == "tue", "Day 1 is not Tuesday")
	expect(game.calendar_iso(30) == "2025-04-30", "April month boundary is wrong")
	expect(game.calendar_iso(31) == "2025-05-01", "May month boundary is wrong")
	expect(game.calendar_iso(275) == "2025-12-31", "December month boundary is wrong")
	expect(game.calendar_iso(276) == "2026-01-01", "January month boundary is wrong")
	expect(game.calendar_iso(365) == "2026-03-31", "Day 365 is not 2026-03-31")
	expect(game.calendar_date(365).weekday_id == "tue", "Day 365 is not Tuesday")
	expect(game.calendar_iso(366) == "2026-04-01", "Epilogue date is not 2026-04-01")
	expect(game.day_number_for_date("2025-12-24") == 268, "Christmas Eve day number is wrong")
	expect(game.day_number_for_date("2026-02-14") == 320, "Valentine day number is wrong")
	expect(game.day_number_for_date("2026-03-14") == 348, "White Day day number is wrong")
	expect(FixedCalendar.day_type_for(game.day_number_for_date("2025-04-05")) == "saturday", "Saturday classification is wrong")
	expect(FixedCalendar.day_type_for(game.day_number_for_date("2025-04-06")) == "sunday", "Sunday classification is wrong")
	expect(FixedCalendar.day_type_for(game.day_number_for_date("2025-04-29")) == "public_holiday", "Public holiday classification is wrong")
	expect(FixedCalendar.day_type_for(game.day_number_for_date("2025-12-30")) == "hospital_holiday", "Year-end closure classification is wrong")

	game.advance_story_to_day(6, 540)
	expect(game.calendar_iso() == "2025-04-06" and game.is_hospital_closed_day(), "Sunday did not close routine services")
	expect(game.special_requirements_met([{"type": "calendar_date", "date": "2025-04-06"}]), "Exact calendar condition failed")
	expect(game.special_requirements_met([{"type": "calendar_range", "start_date": "2025-04-05", "end_date": "2025-04-07"}]), "Calendar range condition failed")
	expect(game.special_requirements_met([{"type": "weekday", "days": ["sun"]}]), "Weekday condition failed")
	expect(game.special_requirements_met([{"type": "day_type", "values": ["sunday", "public_holiday"]}]), "Day type condition failed")
	var ordinary_sunday := {
		"id": "ordinary_sunday", "duration_days": 1, "repeatable": false, "developer_only": false,
		"required_characters": [], "prerequisite_events": [], "unlock_requirements": [],
		"timing": {"trigger_day": 6, "priority": 10, "final_week_allowed": false},
	}
	var allowed_sunday := ordinary_sunday.duplicate(true)
	allowed_sunday.id = "allowed_sunday"
	allowed_sunday.timing = {"trigger_day": 6, "priority": 20, "final_week_allowed": false, "sunday_start_allowed": true}
	expect(game.special_event_timing_status(ordinary_sunday).status == "sunday_deferred", "Ordinary event was allowed to begin on Sunday")
	expect(game.special_event_timing_status(ordinary_sunday).effective_day == 7, "Sunday event was not deferred to Monday")
	expect(game.special_event_timing_status(allowed_sunday).status == "available", "Explicit Sunday event was not allowed to begin")
	var saturday_multi := ordinary_sunday.duplicate(true)
	saturday_multi.id = "saturday_multi"
	saturday_multi.duration_days = 2
	saturday_multi.timing = {"trigger_day": 5, "priority": 10, "final_week_allowed": false}
	var saturday_game = GameState.new()
	saturday_game.advance_story_to_day(5, 540)
	expect(saturday_game.special_event_timing_status(saturday_multi).status == "available", "Multi-day event could not begin Saturday and span Sunday")

	game.definitions["weekend_visit"] = {"patient_id": "patient_test"}
	expect(game.open_visit("weekend_visit") == null and "普通门诊休诊" in game.last_error, "New Sunday outpatient visit was not blocked")
	var existing_visit := DummyVisit.new()
	game.visits["weekend_visit"] = existing_visit
	expect(game.open_visit("weekend_visit") == existing_visit, "Existing Sunday case could not be reopened")

	var christmas := {
		"id": "christmas_test", "duration_days": 1, "repeatable": false, "developer_only": false,
		"required_characters": [], "prerequisite_events": [], "unlock_requirements": [],
		"timing": {"trigger_date": "2025-12-24", "priority": 100, "final_week_allowed": false},
	}
	expect(game.special_event_trigger_day(christmas) == 268, "Fixed-date special event did not map to Day 268")
	expect(game.special_event_timing_status(christmas).status == "future", "Fixed-date event became available early")
	game.advance_story_to_day(268, 540)
	expect(game.special_event_timing_status(christmas).status == "available", "Fixed-date event did not become available on its date")

	print("CALENDAR: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
