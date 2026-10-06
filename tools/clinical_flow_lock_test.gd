extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")

const CLINIC_ACTIONS := [
	"greet", "basic_history", "to_exam", "vitals", "limited_clothed_exam",
	"blood", "imaging", "to_diagnosis", "diagnose_appendix", "explain", "admit",
]

var content = Loader.new()
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func new_game() -> RefCounted:
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards)
	for person in content.collections.staff:
		game.meet_staff(person.id)
	return game

func run() -> void:
	content.load_all()
	var game = new_game()
	var visit = game.open_visit("visit_sora")
	expect(game.day_transition_deferred(), "An unfinished clinic encounter did not defer day end before a pending flag was recorded")
	game.remember_deferred_day_transition()
	expect(game.pending_encounter_day_transition, "Deferred clinic day end was not remembered")
	for action_id in CLINIC_ACTIONS:
		expect(visit.apply(action_id), "Clinic fixture failed at " + action_id)
	expect(visit.completed(), "Clinic fixture did not reach admission")
	expect(not game.day_transition_deferred(), "A completed clinic encounter still blocked day end")
	game.pending_encounter_day_transition = false

	var prep = game.open_preop("preop_sora")
	expect(prep != null, "Admitted patient did not open preop")
	expect(prep.apply({"kind": "action", "id": "brief_plan"}), "Could not reach team formation")
	expect(not prep.surgery_committed(), "Surgery committed before team confirmation")
	expect(prep.apply({"kind": "assign", "role": "assistant_surgeon", "staff_id": "doc_aoi"}), "Assistant assignment failed")
	expect(prep.apply({"kind": "assign", "role": "scrub_nurse", "staff_id": "nurse_haru"}), "Scrub nurse assignment failed")
	expect(prep.apply({"kind": "assign", "role": "circulating_nurse", "staff_id": "nurse_rin"}), "Circulating nurse assignment failed")
	expect(prep.apply({"kind": "action", "id": "confirm_team"}), "Team confirmation failed")
	expect(prep.surgery_committed(), "Confirmed team did not commit surgery")
	expect(game.active_surgery_committed(), "Game state did not expose committed surgery")
	expect(game.day_transition_deferred(), "Committed surgery did not defer day end")

	var restored = new_game()
	expect(restored.restore(JSON.parse_string(JSON.stringify(game.snapshot()))), "Committed flow save did not restore")
	expect(restored.active_surgery_committed(), "Committed surgery lock was lost after restoring")
	expect(restored.day_transition_deferred(), "Restored committed surgery did not defer day end")

	print("clinical_flow_lock_test: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
