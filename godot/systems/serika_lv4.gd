extends RefCounted
## One uninterrupted after-work story. Only its final completed fact is saved.
const ID := "serika_lv4_stay"
const ACTOR := "doc_serika"
const Radiology = preload("res://godot/systems/serika_radiology.gd")

static func entry_facts_met(g: RefCounted) -> bool:
	if not Radiology.milestone_complete(g, 3) or g.relationship_level(ACTOR) != 3:
		return false
	var previous: String = str(g.relationship_rank_slot(ACTOR, 3).get("event_id", ""))
	var completed_day: int = preload("res://godot/systems/chihaya_second_surgery.gd").completed_day(g, previous)
	if g.current_workday() - completed_day < int(g.relationship_rank_slot(ACTOR, 4).get("cooldown_days", 3)):
		return false
	# A numerical level alone is not evidence of Miyuki's authored Lv3 event.
	var slot: Dictionary = g.relationship_rank_slot("nurse_yui", 3)
	var event := str(slot.get("event_id", ""))
	return str(slot.get("content_status", "")) == "authored" and not event.is_empty() and g.relation_for("nurse_yui").get("rank_history", []).has(event) and (g.character_event_done(event) or g.special_event_done(event))

static func eligible(g: RefCounted) -> bool:
	var clock: int = int(g.world_display_schedule().absolute_clock)
	if clock < g.OUTPATIENT_CLOSE_MINUTE or clock >= 23 * 60 or g.is_hospital_closed_day(g.current_workday()): return false
	if not g.active_character_event_id.is_empty() or not g.active_micro_event_id.is_empty() or not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty(): return false
	if g.unresolved_admitted_patient_exists(): return false
	# Preserve an accepted private appointment rather than cancelling it for Lv4.
	if not g.free_h_booking.is_empty(): return false
	return true

static func timing_status(g: RefCounted, definition: Dictionary) -> Dictionary:
	var first: int = g.current_workday()
	var last := first + 3
	var result := {"status":"available", "trigger_day":first, "effective_day":first}
	if last > g.GAME_DURATION_DAYS or last >= g.FINAL_WEEK_START_DAY:
		result.status = "expired"
		return result
	# Duration here is a calendar occupancy check, not four chapter settlements.
	var occupied := definition.duplicate(true)
	occupied.duration_days = 4
	if preload("res://godot/systems/chihaya_second_surgery.gd").conflicts_with_reservation(g, occupied) or preload("res://godot/systems/mizuho_first_surgery.gd").conflicts_with_reservation(g, occupied) or preload("res://godot/systems/chihaya_mizuho_return.gd").conflicts(g, occupied):
		result.status = "postponed"
		return result
	for other in g.special_event_definitions.values():
		if str(other.id) == ID or bool(other.get("developer_only",false)) or not bool(other.get("auto_schedule",false)) or g.special_event_done(str(other.id)) or not g.special_event_base_requirements_met(other): continue
		var day: int = g.special_event_trigger_day(other)
		var duration: int = preload("res://godot/systems/chihaya_third_surgery.gd").occupied_days(str(other.id), int(other.duration_days))
		if day <= last and day + duration - 1 > first:
			result.status = "postponed"
			result.blocked_by = str(other.id)
			return result
	return result

static func settle(g: RefCounted, started_day: int) -> void:
	# Clear the old overtime departure anchor before presenting D3 morning.
	g.clear_pending_departure_context()
	g.advance_story_to_day(started_day + 3, g.SHIFT_START_MINUTE)
	g.pending_encounter_day_transition = false
	g.pending_surgery_day_transition = false
	g.relation_for(ACTOR).route = "romance"
