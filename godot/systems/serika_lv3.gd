extends RefCounted
## Lv3 entry is enabled; the real Lv2 milestone and full Mizuho chain remain required.
## This deployment switch is code configuration, never a player-save field.
const ID := "serika_lv3_half_beat"
const ACTOR := "doc_serika"
const PREREQUISITES_CONNECTED := true
const MIZUHO_CHAIN_FACT := "mizuho_first_surgery_chain_complete"
const Radiology = preload("res://godot/systems/serika_radiology.gd")

static func prerequisite_facts_met(g: RefCounted) -> bool:
	return Radiology.milestone_complete(g, 2) and g.story_flag(MIZUHO_CHAIN_FACT)

static func eligible(g: RefCounted, connected: bool = PREREQUISITES_CONNECTED) -> bool:
	if not connected or not prerequisite_facts_met(g) or not g.is_sunday() or g.sunday_activity_done():
		return false
	if not g.staff_is_met(ACTOR) or g.relationship_level(ACTOR) != 2 or not g.relationship_rank_gate_met(ACTOR, 3):
		return false
	if g.active_surgery_in_progress() or not g.active_character_event_id.is_empty() or not g.active_special_event_id.is_empty() or not g.active_micro_event_id.is_empty() or not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty() or not g.pending_departure_context().is_empty():
		return false
	return true

static func completed(g: RefCounted) -> bool:
	# The shared rank callback has already recorded the completed event fact.
	# Consume one Sunday through the ordinary ledger, using a non-date activity
	# so there is no date reward, Charm, or successful-date counter.
	if not Radiology.milestone_complete(g, 3):
		return false
	return g.complete_sunday_activity("serika_lv3_outing", ACTOR, "ochanomizu")
