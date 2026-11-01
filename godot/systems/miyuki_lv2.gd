extends RefCounted
## Two independently completed story events, scheduled by event-level facts.
## No node/cursor/choice state is persisted, and no surgical session is created.
const A := "miyuki_lv2_preop_evening"
const B := "miyuki_lv2_preop_morning"
const LV1 := "miyuki_lv1_not_that_kind_of_inexperienced"
const ACTOR := "nurse_yui"

static func owns(id: String) -> bool:
	return id in [A, B]

static func booked_day(g: RefCounted) -> int:
	return int(g.special_event_completion_days.get(A, 0)) + 1 if g.special_event_done(A) and not g.special_event_done(B) else 0

static func reserved_today(g: RefCounted) -> bool:
	return booked_day(g) == g.day_number()

static func tomorrow_conflict(g: RefCounted, workday: int) -> bool:
	# In-memory projection using the existing schedulers; never serialized. Copy
	# containers so expiry/daily-presence caches cannot alter the live game.
	var preview: RefCounted = g.get_script().new()
	for property in g.get_property_list():
		if int(property.usage) & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var value: Variant = g.get(property.name)
			preview.set(property.name, value.duplicate(true) if value is Dictionary or value is Array else value)
	# Do not recursively consider this optional evening while checking tomorrow.
	preview.special_event_definitions.erase(A)
	preview.special_event_definitions.erase(B)
	preview.clear_pending_departure_context()
	preview.advance_story_to_day(workday + 1, g.SHIFT_START_MINUTE)
	var next_event: Dictionary = preview.next_auto_special_event()
	if not next_event.is_empty() and bool(next_event.get("mandatory_auto_start", false)): return true
	return not preview.next_day_start_character_event().is_empty()

static func evening_ready(g: RefCounted, workday: int) -> bool:
	if g.special_event_done(A) or g.special_event_done(B) or not g.staff_is_met(ACTOR) or g.relationship_level(ACTOR) != 1: return false
	if not g.character_event_done(LV1) or not g.relation_for(ACTOR).get("rank_history", []).has(LV1): return false
	var gate: Dictionary = g.relationship_rank_gate_evaluation(ACTOR, 2)
	if not bool(gate.met) or int(gate.cooldown_current) - (g.day_number() - workday) < int(gate.cooldown_required): return false
	if str(g.calendar_date(workday).weekday_id) == "sat" or workday >= g.GAME_DURATION_DAYS: return false
	if not g.active_staff_patient.is_empty() and str(g.active_staff_patient.get("staff_id", "")) == ACTOR: return false
	return not tomorrow_conflict(g, workday)

static func eligible(g: RefCounted, id: String) -> bool:
	if not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or not g.active_character_event_id.is_empty() or not g.active_micro_event_id.is_empty() or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty(): return false
	if id == B:
		return reserved_today(g) and g.current_absolute_clock() == g.SHIFT_START_MINUTE and g.pending_departure_context().is_empty()
	return evening_ready(g, g.current_workday())

static func timing_status(g: RefCounted, id: String) -> Dictionary:
	var target: int = booked_day(g) if id == B else g.current_workday()
	return {"status":"available" if target > 0 and (id == A or target == g.day_number()) else "future", "trigger_day":target, "effective_day":target}

static func exclude_walk(g: RefCounted, workday: int) -> bool:
	return int(g.special_event_completion_days.get(A, -1)) == workday or evening_ready(g, workday)

static func conflicts(g: RefCounted, definition: Dictionary) -> bool:
	if owns(str(definition.get("id", ""))): return false
	var booked := booked_day(g)
	if booked <= 0: return false
	var last: int = g.current_workday() + maxi(1, int(definition.get("duration_days", 1))) - 1
	# A multi-day departure must not swallow the reserved next morning.
	if g.special_event_trigger_mode(definition) == "after_work": last += 1
	return booked >= g.current_workday() and booked <= last
