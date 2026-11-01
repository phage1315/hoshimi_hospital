extends RefCounted
## Shared rank-up settlement owns Lv5 and the existing patient benefit.
## This event only checks entry facts; it never creates an admission or operation.
const ID := "serika_lv5_lay_down_burden"
const ACTOR := "doc_serika"
const Radiology = preload("res://godot/systems/serika_radiology.gd")

static func eligible(g: RefCounted) -> bool:
	if g.relationship_level(ACTOR) != 4 or not Radiology.milestone_complete(g, 4) or not g.story_flag("staff_as_patient_program_authorized"):
		return false
	if g.character_event_done(ID) or not g.is_routine_workday():
		return false
	if g.active_surgery_in_progress() or not g.active_character_event_id.is_empty() or not g.active_special_event_id.is_empty() or not g.active_micro_event_id.is_empty() or not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or g.active_adult_intimacy != null or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty() or not g.pending_departure_context().is_empty():
		return false
	if not g.next_mandatory_character_event().is_empty():
		return false
	return g.shift_remaining() >= 60 and g.current_absolute_clock() >= 540 and g.current_absolute_clock() + 60 <= 1020
