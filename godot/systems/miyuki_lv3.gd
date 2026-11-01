extends RefCounted
## Two independent performances. Only event-level completion facts persist.
const ACTOR := "nurse_yui"
const A_KARIYA := "miyuki_lv3_locker_room_kariya"
const A_SHIORI := "miyuki_lv3_locker_room_shiori"
const B := "miyuki_lv3_afternoon_good_morning"
const LV2 := "miyuki_lv2_preop_morning"

static func owns(id: String) -> bool:
	return id in [A_KARIYA, A_SHIORI, B]

static func prelude_day(g: RefCounted) -> int:
	for id in [A_KARIYA, A_SHIORI]:
		if g.character_event_done(id):
			return int(g.character_events[id].completed_day)
	return 0

static func pending_date(g: RefCounted) -> bool:
	return prelude_day(g) > 0 and not g.character_event_done(B)

static func safe(g: RefCounted) -> bool:
	return not (g.active_surgery_committed() or g.active_surgery_in_progress() or g.active_encounter_in_progress() or not g.active_preop_id.is_empty() or not g.active_special_event_id.is_empty() or not g.active_character_event_id.is_empty() or not g.active_micro_event_id.is_empty() or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty() or not g.pending_departure_context().is_empty() or g.active_adult_intimacy != null)

static func prelude_requirements(g: RefCounted) -> bool:
	return safe(g) and prelude_day(g) == 0 and not g.character_event_done(B) and g.staff_is_met(ACTOR) and g.relationship_level(ACTOR) == 2 and g.special_event_done(LV2) and g.staff_is_met("doc_serika") and g.relationship_rank_gate_met(ACTOR, 3)

static func selected_prelude(g: RefCounted) -> String:
	# This event's casting window only; the unimplemented Dec 1 review must not
	# automatically dismiss or retain Kariya in the global staff roster.
	var today: Dictionary = g.calendar_date()
	var campaign_start: Dictionary = g.calendar_date(1)
	var in_internship := int(today.year) == int(campaign_start.year) and int(today.month) >= 6 and int(today.month) < 12
	return A_KARIYA if g.staff_is_met("nurse_kariya_megumi") and in_internship else A_SHIORI

static func eligible(g: RefCounted, id: String) -> bool:
	if not safe(g) or not g.staff_is_met(ACTOR) or g.relationship_level(ACTOR) != 2 or not g.staff_is_met("doc_serika"):
		return false
	if id == B:
		return pending_date(g) and g.day_number() > prelude_day(g) and g.is_sunday() and not g.sunday_activity_done()
	return id in [A_KARIYA, A_SHIORI] and prelude_requirements(g) and id == selected_prelude(g)

static func next_prelude(g: RefCounted) -> String:
	return selected_prelude(g) if prelude_requirements(g) else ""

static func completed(g: RefCounted) -> bool:
	if not g.character_event_done(B) or g.relationship_level(ACTOR) != 3:
		return false
	# One ordinary Sunday ledger entry; no generic date reward or date counter.
	return g.complete_sunday_activity("miyuki_lv3_date", ACTOR, "plaza")
