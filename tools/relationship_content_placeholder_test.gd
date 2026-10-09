extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func configured_game(content):
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps)
	return game

func run() -> void:
	var content = Loader.new()
	expect(content.load_all(), "Content load failed")
	var game = configured_game(content)
	var staff_by_id := {}
	for profile in game.staff:
		staff_by_id[str(profile.id)] = profile
	var status_counts := {"authored": 0, "planned": 0, "unavailable": 0}
	for relation in game.relationships.values():
		var actor_id := str(relation.target_id)
		var locked := (staff_by_id.get(actor_id, {}).get("flags", []) as Array).has("relationship_progression_locked")
		for slot in relation.rank_slots:
			var status := str(slot.get("content_status", ""))
			expect(status_counts.has(status), actor_id + ": invalid or missing content status")
			if status_counts.has(status):
				status_counts[status] += 1
			var event_id := str(slot.get("event_id", ""))
			if status == "authored":
				expect(not event_id.is_empty(), actor_id + ": authored milestone has no event ID")
				expect(game.character_event_definitions.has(event_id) or game.special_event_definitions.has(event_id), actor_id + ": authored milestone event is not loaded: " + event_id)
			else:
				expect(event_id.is_empty(), actor_id + ": non-authored milestone named an event")
			if status == "unavailable":
				expect(locked, actor_id + ": active relationship route contains an unavailable milestone")
				expect(str(slot.get("benefit_id", "")).is_empty() and slot.get("special_requirements", []).is_empty(), actor_id + ": unavailable milestone retained rewards or gates")
			else:
				expect(not locked, actor_id + ": progression-locked route contains active content")
	expect(int(status_counts.authored) > 0, "No authored relationship milestones were discovered")
	expect(int(status_counts.planned) > 0, "No planned relationship placeholders were discovered")
	expect(int(status_counts.unavailable) > 0, "No deliberately unavailable relationship routes were discovered")

	game.meet_staff("doc_aoi")
	var aoi_relation: Dictionary = game.relation_for("doc_aoi")
	aoi_relation.familiarity = 100
	var aoi_progress: Dictionary = game.relationship_progress("doc_aoi")
	expect(aoi_progress.content_status == "planned" and not aoi_progress.event_authored, "Planned milestone was not exposed as gate-only future content")
	expect(not game.rank_ready("doc_aoi"), "Gate-only placeholder entered the playable event schedule")

	game.meet_staff("doc_emiko")
	var emiko_progress: Dictionary = game.relationship_progress("doc_emiko")
	expect(emiko_progress.content_status == "authored" and emiko_progress.event_authored, "Authored milestone was not exposed as playable content")
	expect(game.relationship_max_level("visiting_maya") == 0 and game.relationship_max_level("visiting_futaba") == 0 and game.relationship_max_level("doc_sakura_anesthesiology") == 0, "Unavailable professional guests escaped the Lv0 relationship lock")

	print("RELATIONSHIP CONTENT PLACEHOLDERS: %s checks; %s failure(s); authored=%s planned=%s unavailable=%s" % [checks, failures, status_counts.authored, status_counts.planned, status_counts.unavailable])
	quit(1 if failures else 0)
