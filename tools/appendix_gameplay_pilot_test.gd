extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
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

func new_prep(procedure_id: String = "surgery_appendix") -> RefCounted:
	var prep = Preop.new(
		content.collections.preops[0].duplicate(true),
		content.collections.staff,
		content.collections.surgeries,
		content.collections.patients,
		[], false,
		content.collections.surgery_team_dialogue_profiles,
		content.collections.patient_interactions,
		content.collections.temporary_conditions
	)
	prep.procedure_id = procedure_id
	var surgery: Dictionary = prep.current_surgery()
	prep.procedure_name = str(surgery.name)
	prep.procedure_minutes = int(surgery.duration_minutes)
	prep.initialize_procedure_state(procedure_id)
	prep.stage_id = "procedure_flow"
	prep.team = {
		"assistant_surgeon": "doc_aoi",
		"scrub_nurse": "nurse_yui",
		"circulating_nurse": "nurse_haru",
	}
	return prep

func choose_at(prep: RefCounted, step_index: int, option_id: String) -> bool:
	prep.procedure_step_index = step_index
	prep.stage_id = "procedure_flow"
	prep.awaiting_flow_acknowledgement = false
	prep.awaiting_patient_choice = false
	prep.awaiting_patient_acknowledgement = false
	return prep.apply({"kind": "surgery_step", "id": option_id})

func finish_route(option_ids: Array[String]) -> RefCounted:
	var prep = new_prep()
	prep.flags.append("anesthetized")
	for option_id in option_ids:
		if not prep.apply({"kind": "surgery_step", "id": option_id}):
			return prep
		if not prep.apply({"kind": "flow_acknowledge"}):
			return prep
	return prep

func run() -> void:
	expect(content.load_all(), "Could not load content")
	var appendix: Dictionary = content.find_record("surgeries", "surgery_appendix")
	expect(appendix.stages.size() == 9, "Appendix pilot does not have nine stages")
	expect(int(appendix.initial_state.visibility) == 60, "Appendix pilot visibility must start at 60")

	# A: an untouched legacy operation keeps its old state and behavior.
	var legacy = new_prep("surgery_open_cholecystectomy")
	var legacy_before: Dictionary = legacy.procedure_state.duplicate(true)
	var legacy_option: Dictionary = legacy.surgery_flow_step().options[0]
	expect(not legacy_option.has("strategic_effects") and not legacy_option.has("conditional_effects"), "Legacy fixture unexpectedly uses pilot effects")
	expect(legacy.apply({"kind": "surgery_step", "id": legacy_option.id}), "Legacy surgery step stopped working")
	expect(legacy.procedure_state == legacy_before and legacy.procedure_step_history[-1] == {"stage_id": legacy.surgery_flow_steps()[0].id, "option_id": legacy_option.id, "correct": true}, "Legacy surgery state or history changed")

	# B: base strategic effects apply exactly once.
	var strategic = new_prep()
	var strategic_before: Dictionary = strategic.procedure_state.duplicate(true)
	expect(choose_at(strategic, 1, "standard_exposure"), "Standard exposure could not be selected")
	expect(int(strategic.procedure_state.progress) == int(strategic_before.progress) + 12, "Strategic progress delta is wrong")
	expect(int(strategic.procedure_state.elapsed_time) == int(strategic_before.elapsed_time) + 8, "Strategic elapsed-time delta is wrong")
	expect(int(strategic.procedure_state.visibility) == int(strategic_before.visibility) + 15, "Strategic visibility delta is wrong")

	# C/D: the same fast option is safe in a good field and costly in a poor one.
	var good = new_prep()
	good.procedure_state.visibility = 80
	expect(choose_at(good, 2, "direct_identification"), "Good-field direct identification failed")
	expect(int(good.procedure_state.visibility) == 80 and int(good.procedure_state.blood_loss) == 0 and not good.feedback.contains("术野弄乱了"), "Good-field conditional fired unexpectedly")
	var poor = new_prep()
	poor.procedure_state.visibility = 70
	expect(choose_at(poor, 2, "direct_identification"), "Poor-field direct identification failed")
	expect(int(poor.procedure_state.visibility) == 60 and int(poor.procedure_state.blood_loss) == 4, "Poor-field conditional effects are wrong")
	expect(poor.feedback.contains("术野弄乱了"), "Poor-field assistant warning was not shown")

	# E: all matching conditional entries apply in authored order.
	var multiple = new_prep()
	multiple.procedure_state.visibility = 70
	multiple.procedure_state.blood_loss = 20
	expect(choose_at(multiple, 5, "commit_now"), "Commit-now option failed")
	expect(int(multiple.procedure_state.visibility) == 62 and int(multiple.procedure_state.blood_loss) == 25 and int(multiple.procedure_state.stability) == 95, "Multiple conditional effects did not accumulate")
	expect(multiple.feedback.contains("并不漂亮") and multiple.feedback.contains("代价在变大"), "Multiple conditional responses were not shown")

	# F: every bounded state is clamped after an effect bundle.
	var bounded = new_prep()
	bounded.procedure_state.visibility = 95
	bounded.procedure_state.stability = 3
	bounded.procedure_state.progress = 98
	bounded.apply_surgery_strategic_effects({"visibility": 25, "stability": -10, "progress": 12, "blood_loss": -5, "elapsed_time": -8})
	expect(int(bounded.procedure_state.visibility) == 100 and int(bounded.procedure_state.stability) == 0 and int(bounded.procedure_state.progress) == 100, "Upper/lower bounded metrics were not clamped")
	expect(int(bounded.procedure_state.blood_loss) == 0 and int(bounded.procedure_state.elapsed_time) == 0, "Non-negative metrics were not clamped")

	var balanced_ids: Array[String] = ["confirm_entry", "standard_exposure", "systematic_identification", "continue_mobilization", "standard_control", "commit_now", "continue_after_specimen", "quick_final_review", "complete_surgery"]
	var conservative_ids: Array[String] = ["confirm_entry", "wide_exposure", "assistant_retraction", "continue_mobilization", "careful_control", "reestablish_field", "continue_after_specimen", "full_final_review", "complete_surgery"]
	var aggressive_ids: Array[String] = ["confirm_entry", "minimal_exposure", "direct_identification", "continue_mobilization", "fast_control", "commit_now", "continue_after_specimen", "quick_final_review", "complete_surgery"]
	var balanced = finish_route(balanced_ids)
	var conservative = finish_route(conservative_ids)
	var aggressive = finish_route(aggressive_ids)
	expect(balanced.stage_id == "procedure_execute" and int(balanced.procedure_state.progress) == 100 and balanced.surgery_condition_met(appendix.success_condition), "Balanced route did not reach 100 progress")
	expect(int(balanced.procedure_state.elapsed_time) == 59 and int(balanced.procedure_state.stability) == 100, "Balanced route outcome changed")
	expect(int(conservative.procedure_state.elapsed_time) == 73 and int(conservative.procedure_state.visibility) > int(balanced.procedure_state.visibility), "Conservative route did not trade time for visibility")
	expect(int(aggressive.procedure_state.elapsed_time) == 55 and int(aggressive.procedure_state.blood_loss) > int(balanced.procedure_state.blood_loss) and int(aggressive.procedure_state.stability) == 85, "Aggressive route did not accumulate consequences")
	expect(balanced.apply({"kind": "action", "id": "execute_confirmed_procedure"}) and balanced.surgery_success, "Completed strategic flow did not use the existing success action")
	expect(balanced.minutes == int(appendix.duration_minutes) + balanced.POSTOPERATIVE_WRAP_UP_MINUTES, "Pilot changed the existing calendar settlement time")
	var replayed = new_prep()
	replayed.flags.append("anesthetized")
	for event in balanced.events:
		expect(replayed.apply(event), "Strategic event log could not be replayed: " + JSON.stringify(event))
	expect(replayed.procedure_state == balanced.procedure_state and replayed.stage_id == balanced.stage_id and replayed.minutes == balanced.minutes, "Strategic state was not reconstructed by event replay")

	# H: awake patients still enter the authored interaction system; general
	# anesthesia suppresses it and advances normally.
	var awake = new_prep()
	expect(awake.apply({"kind": "surgery_step", "id": "confirm_entry"}) and awake.apply({"kind": "flow_acknowledge"}), "Awake first stage failed")
	expect(awake.awaiting_patient_choice and str(awake.active_patient_interaction.get("theme", "operative_contact")) == "operative_contact", "Awake route did not produce the existing patient interaction")
	var general = new_prep()
	general.flags.append("anesthetized")
	expect(general.apply({"kind": "surgery_step", "id": "confirm_entry"}) and general.apply({"kind": "flow_acknowledge"}), "General-anesthesia first stage failed")
	expect(not general.awaiting_patient_choice and general.procedure_step_index == 1, "General anesthesia did not suppress awake dialogue")

	print("APPENDIX GAMEPLAY PILOT: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
