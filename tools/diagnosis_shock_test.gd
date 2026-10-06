extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")

var failures := 0
var checks := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func configure_complete(game: RefCounted, content: RefCounted) -> void:
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions)

func apply_all(visit: RefCounted, action_ids: Array) -> void:
	for action_id in action_ids:
		expect(visit.apply(action_id), "Could not apply clinic action: " + action_id)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var content = Loader.new()
	expect(content.load_all(), "Content load failed")
	expect(content.collections.first_surgery_diagnosis_reactions.size() == 22, "Diagnosis shock pool did not load all 22 variants")
	var game = GameState.new()
	configure_complete(game, content)
	game.patient_cases.patient_sora = "template_breast_tumor"
	game.rebuild_patient_content(game.patient_cases)
	var definition: Dictionary = game.definitions.visit_sora
	var variant_id := str(definition.get("first_surgery_diagnosis_shock_variant_id", ""))
	expect(variant_id.begins_with("diagnosis_breast_"), "First breast operation did not select a breast reaction")
	var visit = game.open_visit("visit_sora")
	apply_all(visit, ["greet", "pain", "associated", "background", "to_exam", "vitals", "request_full_undress", "authoritative_full_undress", "blood", "imaging", "to_diagnosis", "diagnose_appendix"])
	expect(game.apply_clinic_action("explain"), "Diagnosis shock response could not be applied")
	expect(game.first_surgery_diagnosis_shock_state.patient_sora.first_surgery_diagnosis_shock_variant_id == variant_id, "Selected reaction ID was not saved")
	var shown_text := str(visit.presentation().text)
	expect(shown_text == game.diagnosis_shock_text(game.diagnosis_shock_definitions[variant_id]), "Clinic showed a different reaction from the saved variant")
	var snapshot: Dictionary = game.snapshot()
	var clone = GameState.new()
	configure_complete(clone, content)
	expect(clone.restore(JSON.parse_string(JSON.stringify(snapshot))), "Diagnosis shock save could not be restored")
	expect(clone.first_surgery_diagnosis_shock_state.patient_sora.first_surgery_diagnosis_shock_variant_id == variant_id, "Reload changed the saved reaction variant")
	expect(clone.visits.visit_sora.presentation().text == shown_text, "Reload changed the visible reaction text")
	var later_definition: Dictionary = game.encounter_definitions_for(game.patient_cases, game.first_surgery_diagnosis_shock_state).visit_sora
	expect(not later_definition.has("first_surgery_diagnosis_shock_variant_id"), "A returning patient received the first-surgery reaction again")
	var patient: Dictionary = game.patient_definition("patient_sora")
	patient.has_prior_surgery = true
	expect(game.first_surgery_diagnosis_reaction("patient_sora", "surgery_breast_tumor", {}).is_empty(), "Prior-surgery patient triggered the generic pool")
	patient.has_prior_surgery = false
	patient.medical_background = true
	expect(game.first_surgery_diagnosis_reaction("patient_sora", "surgery_breast_tumor", {}).is_empty(), "Medical-background patient triggered the generic pool")
	patient.medical_background = false
	patient.first_surgery_diagnosis_shock_override_id = "diagnosis_generic_real_01"
	expect(game.first_surgery_diagnosis_reaction("patient_sora", "surgery_breast_tumor", {}).id == "diagnosis_generic_real_01", "Named override did not beat the site pool")
	patient.erase("first_surgery_diagnosis_shock_override_id")
	expect(game.first_surgery_diagnosis_reaction("patient_sora", "missing_surgery", {}).site_group == "generic", "Missing site mapping did not use the generic fallback")
	print("DIAGNOSIS SHOCK TEST: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
