extends RefCounted
## Three authored episodes played as one uninterrupted Monday–Wednesday VN.
## Only completed episode facts and semantic booking facts survive the boundary.
const A := "chihaya_third_surgery_a"
const B := "chihaya_third_surgery_b"
const C := "chihaya_third_surgery_c"
const ACTOR := "doc_serika"
const Second = preload("res://godot/systems/chihaya_second_surgery.gd")
const Radiology = preload("res://godot/systems/serika_radiology.gd")
const Session = preload("res://godot/systems/special_event_session.gd")

static func owns(id: String) -> bool:
	return id in [A, B, C]

static func entry_facts_met(g: RefCounted) -> bool:
	for id in [Second.A, Second.B, Second.C]:
		if not g.special_event_done(id):
			return false
	return Radiology.milestone_complete(g, 1) and g.relationship_rank_gate_met(ACTOR, 2)

static func target_day(g: RefCounted) -> int:
	if g.special_event_done(A) or not entry_facts_met(g):
		return -1
	var second_day := int(g.special_event_completion_days.get(Second.B, 0))
	var lv1_day := Second.completed_day(g, Radiology.LV1)
	if second_day <= 0 or lv1_day <= 0:
		return -1
	# The interval compares actual operation days: candidate Monday + 1.
	var candidate := maxi(g.day_number(), maxi(g.day_number_for_date("2025-07-07"), second_day + 41))
	candidate = maxi(candidate, lv1_day + 1)
	if candidate == g.day_number() and g.current_absolute_clock() > 540:
		candidate += 1
	while candidate <= g.GAME_DURATION_DAYS and str(g.calendar_date(candidate).weekday_id) != "mon":
		candidate += 1
	return candidate if candidate + 2 <= g.GAME_DURATION_DAYS else -1

static func occupied_days(id: String, fallback: int) -> int:
	return 3 if id == A else fallback

static func eligible(g: RefCounted, id: String) -> bool:
	# B/C have no independent public entry; settlement starts them in memory.
	if id != A or g.day_number() != target_day(g) or g.current_absolute_clock() != 540:
		return false
	if not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty() or not g.pending_departure_context().is_empty():
		return false
	if g.day_start_character_event_consumed() or not g.next_day_start_character_event().is_empty():
		return false
	return true

static func booking(g: RefCounted) -> Dictionary:
	if not g.special_event_done(A):
		return {}
	var admission_day := int(g.special_event_completion_days.get(A, 0))
	return {"admission_day": admission_day + 4, "surgery_day": admission_day + 7,
		"rounds_day": admission_day + 8, "joint_discharge_day": admission_day + 14,
		"anesthesia_plan": "none", "deposit_percent_of_revised_quote": 50}

static func continue_chain(g: RefCounted, completed_id: String) -> bool:
	if completed_id not in [A, B]:
		return false
	var next_id := B if completed_id == A else C
	var definition: Dictionary = g.special_event_definitions[next_id]
	var steps := {}
	for step_id in definition.event_chain:
		steps[str(step_id)] = g.special_event_step_definitions[str(step_id)]
	var anchor := int(g.special_event_completion_days[A])
	g.advance_story_to_day(anchor + (1 if next_id == B else 2), 540)
	# Replace the completed runtime session without ever entering map/save mode.
	g.active_special_event = Session.new(definition, steps, g.day_number())
	g.active_special_event_id = next_id
	g.active_mode = "special_event"
	return true
