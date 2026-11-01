extends RefCounted
## A first completed operation is a business fact, not a training XP count.
## The shared event system owns completion/date/minutes; no pending VN cursor.
const ID := "serika_first_staff_surgery_callback"
const ACTOR := "doc_serika"

static func eligible(g: RefCounted) -> bool:
	if not g.staff_patient_unlocked(ACTOR) or g.character_event_done(ID):
		return false
	var completed_day := int(g.staff_patient_first_completion_days.get(ACTOR, 0))
	if completed_day < 1 or g.day_number() <= completed_day or not g.is_routine_workday():
		return false
	if str(g.active_staff_patient.get("staff_id", "")) == ACTOR:
		return false
	if not g.active_character_event_id.is_empty() or not g.active_special_event_id.is_empty() or not g.active_micro_event_id.is_empty() or not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or g.active_adult_intimacy != null or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty():
		return false
	if not g.next_mandatory_character_event().is_empty():
		return false
	return g.shift_remaining() >= 15 and g.current_absolute_clock() >= 540 and g.current_absolute_clock() + 15 <= 1020
