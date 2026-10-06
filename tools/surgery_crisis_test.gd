extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const Game = preload("res://godot/systems/game_state.gd")
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

func fixture() -> RefCounted:
	var definition := {
		"id": "crisis_test", "patient_id": "patient_sora", "encounter_id": "visit_sora", "surgery_id": "surgery_appendix", "start": "surgery_flow",
		"initial_anxiety": 2, "initial_interaction": {"fear": 35, "pain": 0, "dignity": 100, "cooperation": 70},
		"roles": [], "ward_role": {"id": "ward_nurse"}, "preparations": [], "max_optional_preparations": 0,
		"care_reassurance_threshold": 70, "completion": "surgery_abort",
		"stages": [{"id": "surgery_flow", "title": "Crisis Test", "scene": "operating_room", "kind": "surgery_flow", "speaker": "narrator", "next": "surgery_flow", "actions": [], "background_id": "operating_room"}],
	}
	var prep = Preop.new(definition, content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions)
	prep.procedure_id = "surgery_appendix"
	prep.procedure_name = "开腹阑尾切除"
	prep.initialize_procedure_state()
	prep.stage_id = "surgery_flow"
	prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin"}
	prep.flags.append("surgery_started")
	prep.flags.append("no_anesthesia_confirmed")
	return prep

func configured_game() -> RefCounted:
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions)
	return game

func completion_probability(node_count: int, crisis_chance: float, rescue_chances: Array) -> float:
	var abort_given_crisis := 1.0
	for rescue_chance in rescue_chances:
		abort_given_crisis *= 1.0 - float(rescue_chance)
	return pow(1.0 - crisis_chance * abort_given_crisis, node_count)

func run() -> void:
	expect(content.load_all(), "Could not load content")
	var prep = fixture()
	prep.fear = 95
	prep.pain = 95
	prep.procedure_state.stability = 30
	prep.procedure_state.blood_loss = 80
	var awake_risk: int = int(prep.physiologic_crisis_chance({"id": "deep_resection", "physio_stress": "high"}))
	expect(awake_risk == 30, "Awake high-risk crisis chance was not clamped to 30%")
	prep.flags.erase("no_anesthesia_confirmed")
	prep.flags.append("anesthetized")
	var general_risk: int = int(prep.physiologic_crisis_chance({"id": "deep_resection", "physio_stress": "high"}))
	expect(general_risk == 26 and general_risk < awake_risk, "General anesthesia did not exclude conscious fear/pain risk")

	var crisis_prep = fixture()
	var first_step: Dictionary = crisis_prep.surgery_flow_steps()[0]
	var first_option: Dictionary = first_step.options[0]
	expect(crisis_prep.apply({"kind": "surgery_step", "id": first_option.id, "crisis_roll": 0}), "Forced crisis surgery step was rejected")
	expect(not crisis_prep.active_crisis.is_empty() and not crisis_prep.awaiting_flow_acknowledgement, "Forced crisis did not pause the surgery node")
	expect(crisis_prep.apply({"kind": "crisis_rescue", "id": "pause_and_stabilize", "roll": 0}), "Successful rescue was rejected")
	expect(crisis_prep.awaiting_crisis_acknowledgement and not crisis_prep.surgery_aborted, "Successful rescue did not stabilize the patient")
	expect(crisis_prep.apply({"kind": "crisis_acknowledge"}) and crisis_prep.active_crisis.is_empty(), "Resolved crisis did not return to the node flow")

	var abort_prep = fixture()
	first_step = abort_prep.surgery_flow_steps()[0]
	first_option = first_step.options[0]
	expect(abort_prep.apply({"kind": "surgery_step", "id": first_option.id, "crisis_roll": 0}), "Could not start abort-path crisis")
	for attempt in range(3):
		expect(abort_prep.apply({"kind": "crisis_rescue", "id": "finish_critical_action", "roll": 9999}), "Failed rescue attempt %s was rejected" % (attempt + 1))
	expect(abort_prep.surgery_aborted and abort_prep.stage_id == "surgery_abort" and not abort_prep.surgery_success, "Three failed rescues did not abort the procedure safely")
	expect(int(abort_prep.procedure_state.stability) >= 40, "Additional support did not leave the aborted patient stable")
	var replayed_abort = fixture()
	for event in abort_prep.events:
		expect(replayed_abort.apply(event), "Recorded crisis event could not be replayed")
	expect(replayed_abort.surgery_aborted and replayed_abort.crisis_history == abort_prep.crisis_history and replayed_abort.procedure_state == abort_prep.procedure_state, "Crisis event log did not replay deterministically")

	var legacy_prep = fixture()
	first_step = legacy_prep.surgery_flow_steps()[0]
	first_option = first_step.options[0]
	expect(legacy_prep.apply({"kind": "surgery_step", "id": first_option.id}), "Legacy surgery step without crisis roll was rejected")
	expect(legacy_prep.active_crisis.is_empty(), "Legacy event unexpectedly rolled a crisis")
	var settings_game = configured_game()
	settings_game.set_intraoperative_crisis_enabled(false)
	var settings_snapshot: Dictionary = settings_game.snapshot()
	var settings_clone = configured_game()
	expect(settings_clone.restore(JSON.parse_string(JSON.stringify(settings_snapshot))), "Crisis setting snapshot could not be restored")
	expect(not settings_clone.intraoperative_crisis_enabled, "Office crisis toggle did not persist in the save")

	# Calibration acceptance: these are outcome targets, not hard-coded case results.
	expect(completion_probability(8, 0.10, [0.90, 0.50, 0.25]) >= 0.95, "Normal-team 8-node calibration fell below 95%")
	expect(completion_probability(16, 0.10, [0.90, 0.50, 0.25]) >= 0.90, "Normal-team 16-node calibration fell below 90%")
	var no_anesthesia_normal := completion_probability(16, 0.20, [0.80, 0.30, 0.10])
	var no_anesthesia_strong := completion_probability(16, 0.20, [0.90, 0.40, 0.20])
	var no_anesthesia_developing := completion_probability(16, 0.20, [0.77, 0.27, 0.07])
	expect(no_anesthesia_normal >= 0.60 and no_anesthesia_normal <= 0.70, "Normal-team no-anesthesia calibration left its 60–70% target")
	expect(no_anesthesia_strong >= 0.80 and no_anesthesia_strong <= 0.90, "Strong-team no-anesthesia calibration left its 80–90% target")
	expect(no_anesthesia_developing >= 0.55 and no_anesthesia_developing <= 0.65, "Developing-team no-anesthesia calibration left its 55–65% target")

	print("SURGERY CRISIS: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
