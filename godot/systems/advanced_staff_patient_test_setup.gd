extends RefCounted
## Debug-only, in-memory prerequisites; never writes a save.
const Referral = preload("res://godot/systems/advanced_referral.gd")
const FreeRegistry = preload("res://godot/systems/free_h_registry.gd")

static func milestone(g, id: String) -> void:
	if g.character_event_definitions.has(id):
		var event = load("res://godot/systems/character_event_session.gd").new(g.character_event_definitions[id])
		event.completed = true; event.completed_day = 1; event.settled_minutes = 60
		g.character_events[id] = event
		if id not in g.character_event_order: g.character_event_order.append(id)
	else:
		g.special_event_completion_counts[id] = 1
		g.special_event_completion_days[id] = 1

static func fixture(g, actor: String) -> void:
	g.special_event_definitions = g.special_event_definitions.duplicate(true)
	g.character_event_definitions = g.character_event_definitions.duplicate(true)
	for p in g.staff: g.meet_staff(p.id)
	for d in g.special_event_definitions.values(): d.developer_only = true; d.auto_schedule = false
	for d in g.character_event_definitions.values(): d.trigger_mode = "after_work"
	g.set_story_flag("staff_as_patient_program_authorized")
	g.set_story_flag("sayaka_lv5_part_c_complete")
	var relation: Dictionary = g.relation_for(actor)
	relation.level = 5
	var event: String = g.relationship_rank_slot(actor, 5).event_id
	milestone(g, event)
	relation.rank_history.append(event); relation.event_history.append(event)
	for flag in g.StaffPatient.profile(actor).get("unlock_flags", []): g.set_story_flag(flag)
	var free: Dictionary = FreeRegistry.definition(actor)
	milestone(g, free.completion_event)
	if not str(free.get("completion_flag", "")).is_empty(): g.set_story_flag(free.completion_flag)
	relation.unlocked_benefits.append("unlock_intimacy_events")
	g.surgery_xp = g.surgery_xp_for_level(88)
	g.set_test_time(g.day_number_for_date("2025-06-09"), 540)
	g.active_mode = "encounter"

static func team(c) -> Dictionary:
	var selected := {}
	for role in Referral.ROLES:
		for person in c.candidates(role, c.day()+1):
			if person.id not in selected.values(): selected[role] = person.id; break
	return selected

