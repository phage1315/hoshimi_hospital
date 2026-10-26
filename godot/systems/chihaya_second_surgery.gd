extends RefCounted
## Atomic VN episodes; reservations use stable completion dates, never cursors.
const PREFIX := "chihaya_second_surgery_"
const A := PREFIX + "a"
const B := PREFIX + "b"
const C := PREFIX + "c"
const FIRST := "hiroko_patient_escape"
const AQUA := "aqua_lv1_gyne_obsession"

static func owns(id: String) -> bool:
	return id in [A, B, C]

static func completed_day(g: RefCounted, id: String) -> int:
	var event: Variant = g.character_events.get(id)
	return int(event.completed_day) if event != null and event.completed else 0

static func next_id(g: RefCounted) -> String:
	for id in [A, B, C]:
		if not g.special_event_done(id):
			return id
	return ""

static func target_day(g: RefCounted, id: String) -> int:
	if id != next_id(g):
		return -1
	if id in [B, C]:
		return int(g.special_event_completion_days.get(A, 0)) + (1 if id == B else 2)
	var first := completed_day(g, FIRST)
	var aqua := completed_day(g, AQUA)
	if first <= 0 or aqua <= 0:
		return -1
	# Hiroko's introduction establishes the successful first operation.
	var candidate := maxi(g.day_number(), maxi(g.day_number_for_date("2025-05-19"), maxi(first, aqua) + 1))
	if candidate == g.day_number() and g.current_absolute_clock() > 540:
		candidate += 1
	while candidate <= g.GAME_DURATION_DAYS and str(g.calendar_date(candidate).weekday_id) != "mon":
		candidate += 1
	return candidate

static func scheduled_day(g: RefCounted, id: String) -> int:
	# Both remaining mornings are reserved as soon as A is settled.
	if id in [B, C] and g.special_event_done(A) and not g.special_event_done(id):
		return int(g.special_event_completion_days.get(A, 0)) + (1 if id == B else 2)
	return target_day(g, id)

static func conflicts_with_reservation(g: RefCounted, definition: Dictionary) -> bool:
	if owns(str(definition.get("id", ""))):
		return false
	var last_day: int = g.day_number() + maxi(1, int(definition.get("duration_days", 1))) - 1
	for id in [B, C]:
		var booked := scheduled_day(g, id)
		if booked > g.day_number() and booked <= last_day:
			return true
	return false

static func reserved_today(g: RefCounted) -> bool:
	var id := next_id(g)
	return id in [B, C] and g.day_number() == target_day(g, id) and g.current_absolute_clock() == 540

static func eligible(g: RefCounted, id: String) -> bool:
	if g.day_number() != target_day(g, id) or g.current_absolute_clock() != 540:
		return false
	if not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty() or not g.pending_departure_context().is_empty():
		return false
	if id == A and (g.day_start_character_event_consumed() or not g.next_day_start_character_event().is_empty()):
		return false
	return true

static func third_surgery_earliest_day(g: RefCounted) -> int:
	var surgery_day := int(g.special_event_completion_days.get(B, 0))
	return surgery_day + 42 if surgery_day > 0 else -1
