extends RefCounted
## Four atomic appointments derived from the actual Monday completion fact.
## No cursor, departure callback, or per-line choice is persisted here.
const PREFIX := "mizuho_first_surgery_"
const A := PREFIX + "a"
const S := PREFIX + "s"
const B := PREFIX + "b"
const C := PREFIX + "c"
const OFFSETS := {A:4, S:5, B:7, C:8}
const Third = preload("res://godot/systems/chihaya_third_surgery.gd")

static func owns(id: String) -> bool:
	return OFFSETS.has(id)

static func anchor(g: RefCounted) -> int:
	return int(g.special_event_completion_days.get(Third.A, 0)) if g.special_event_done(Third.A) else 0

static func scheduled_day(g: RefCounted, id: String) -> int:
	var day := anchor(g)
	return day + int(OFFSETS[id]) if day > 0 and owns(id) and not g.special_event_done(id) else -1

static func prerequisites(g: RefCounted, id: String) -> bool:
	for previous in [Third.A, Third.B, Third.C]:
		if not g.special_event_done(previous): return false
	for previous in {A:[], S:[A], B:[A,S], C:[B]}.get(id, []):
		if not g.special_event_done(previous): return false
	return owns(id) and anchor(g) > 0

static func timing_status(g: RefCounted, id: String) -> Dictionary:
	var target := scheduled_day(g, id)
	var today: int = g.current_workday() if id == S else g.day_number()
	return {"status":"available" if target == today else "expired" if target > 0 and target < today else "future", "trigger_day":target, "effective_day":target}

static func eligible(g: RefCounted, id: String) -> bool:
	if not prerequisites(g,id) or str(timing_status(g,id).status) != "available": return false
	if not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty(): return false
	if id == S:
		# Includes an overtime departure whose ledger already reserves Sunday.
		return int(g.display_schedule().absolute_clock) >= g.OUTPATIENT_CLOSE_MINUTE
	return g.current_absolute_clock() == g.SHIFT_START_MINUTE and g.pending_departure_context().is_empty() and not g.day_start_character_event_consumed()

static func reserved_today(g: RefCounted) -> bool:
	if g.current_absolute_clock() != g.SHIFT_START_MINUTE or not g.pending_departure_context().is_empty(): return false
	for id in [A,B,C]:
		if scheduled_day(g,id) == g.day_number(): return true
	return false

static func conflicts_with_reservation(g: RefCounted, definition: Dictionary) -> bool:
	if owns(str(definition.get("id",""))): return false
	var first: int = g.current_workday()
	var duration: int = Third.occupied_days(str(definition.get("id","")),maxi(1,int(definition.get("duration_days",1))))
	var last := first + duration - 1
	for id in [A,S,B,C]:
		var booked := scheduled_day(g,id)
		if booked < first or booked > last: continue
		if booked > first or (id != S and reserved_today(g)): return true
		# A full-day event on Saturday would jump over the private visit.
		if id == S and bool(definition.get("consumes_full_day",true)) and g.special_event_trigger_mode(definition) != "after_work": return true
	return false

static func blocking_reservation(g: RefCounted, first: int, last: int) -> Dictionary:
	for id in [A,S,B,C]:
		var booked := scheduled_day(g,id)
		if booked >= first and booked <= last: return {"id":id,"day":booked}
	return {}

static func settle_operation_day(g: RefCounted) -> void:
	var before: int = g.elapsed()
	var minutes: int = g.shift_remaining()
	g.story_time_advance_minutes += minutes
	# Existing workday accounting keeps the visible Monday departure while
	# reserving Tuesday's ledger. It neither skips departure nor hardcodes a clock.
	g.settle_overtime(before,minutes)
