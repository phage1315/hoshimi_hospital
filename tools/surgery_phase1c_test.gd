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

func new_prep(procedure_id: String) -> RefCounted:
	var prep = Preop.new(
		content.collections.preops[0].duplicate(true),
		content.collections.staff,
		content.collections.surgeries,
		content.collections.patients,
		[],
		false,
		content.collections.surgery_team_dialogue_profiles,
		content.collections.patient_interactions,
		content.collections.temporary_conditions
	)
	prep.procedure_id = procedure_id
	prep.stage_id = "procedure_flow"
	prep.team = {
		"assistant_surgeon": "doc_aoi",
		"scrub_nurse": "nurse_yui",
		"circulating_nurse": "nurse_haru",
	}
	return prep

func finish_flow(prep: RefCounted) -> bool:
	var guard := 0
	while prep.stage_id == "procedure_flow" and guard < 100:
		guard += 1
		if prep.awaiting_patient_choice:
			var actions: Array = prep.active_patient_interaction.get("actions", [])
			if actions.is_empty() or not prep.apply({"kind": "patient_interaction_action", "id": actions[0].id}):
				return false
			continue
		if prep.awaiting_patient_acknowledgement:
			if not prep.apply({"kind": "patient_acknowledge"}):
				return false
			continue
		var stage: Dictionary = prep.surgery_flow_step()
		if stage.is_empty():
			return false
		var selected: Dictionary = {}
		for option in stage.options:
			if option.correct:
				selected = option
				break
		if selected.is_empty() or not prep.apply({"kind": "surgery_step", "id": selected.id}):
			return false
		if not prep.apply({"kind": "flow_acknowledge"}):
			return false
	return prep.stage_id == "procedure_execute" and guard < 100

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Could not load content")
	expect(content.collections.surgeries.size() >= 25, "Phase 1C must retain the existing surgery catalog")
	expect(content.collections.patient_interactions.size() >= 47, "Phase 1C interaction pool lost required entries")

	var themes := {}
	var groups := {}
	var signature_surgeries := {}
	for interaction in content.collections.patient_interactions:
		if interaction.procedure_groups.is_empty() and interaction.surgery_ids.is_empty() and interaction.states.is_empty() and interaction.cues.is_empty():
			themes[interaction.theme] = true
		for group in interaction.procedure_groups:
			groups[group] = true
		for surgery_id in interaction.surgery_ids:
			signature_surgeries[surgery_id] = true
	expect(themes.size() == 6, "Generic fallback pool does not cover all six active awake themes")
	expect(groups.size() == 7, "Procedure-group interaction pools do not cover all seven surgery groups")
	expect(signature_surgeries.size() >= 6, "Representative surgery-specific signature interactions are missing")

	var ongoing_surgeries := 0
	for surgery in content.collections.surgeries:
		var prep = new_prep(surgery.id)
		var interaction_count := 0
		for index in surgery.stages.size():
			var stage: Dictionary = surgery.stages[index]
			if stage.awake_interlude.is_empty():
				continue
			interaction_count += 1
			var matched: Dictionary = prep.match_patient_interaction(stage.awake_interlude, stage.patient_cues, "default")
			expect(not matched.is_empty(), surgery.id + ": no default interaction fallback for " + stage.awake_interlude)
		for stage in surgery.stages:
			if stage.awake_interlude != "ongoing_interaction":
				continue
			ongoing_surgeries += 1
			expect(not stage.patient_cues.is_empty(), surgery.id + ": ongoing marker lacks patient context")
		if interaction_count == 0:
			continue
		expect(interaction_count >= 3, surgery.id + ": too few awake-patient interaction markers")
		var awake_flow = new_prep(surgery.id)
		awake_flow.procedure_name = surgery.name
		awake_flow.procedure_minutes = surgery.duration_minutes
		expect(finish_flow(awake_flow), surgery.id + ": awake Phase 1C flow did not complete")
		var general_flow = new_prep(surgery.id)
		general_flow.flags.append("anesthetized")
		expect(finish_flow(general_flow), surgery.id + ": general-anesthesia Phase 1C flow did not complete")
		expect(general_flow.patient_event_count == 0, surgery.id + ": general anesthesia generated a patient event")
	expect(ongoing_surgeries >= 10, "Long-surgery ongoing interaction coverage changed unexpectedly")

	var hysterectomy = new_prep("surgery_hysterectomy")
	var signature: Dictionary = hysterectomy.match_patient_interaction("dignity_interaction", ["exposure", "deep_manipulation"], "default")
	expect(signature.get("id") == "hysterectomy_signature_01", "Surgery-specific scope did not outrank the pelvic group")
	hysterectomy.patient_interaction_history.append("hysterectomy_signature_01")
	expect(hysterectomy.match_patient_interaction("dignity_interaction", ["exposure", "deep_manipulation"], "default").get("id") == "pelvic_dignity_default_01", "Used signature did not fall back to procedure-group content")

	var appendix = new_prep("surgery_appendix")
	var first: Dictionary = appendix.match_patient_interaction("operative_contact", ["incision"], "pain")
	appendix.patient_interaction_history.append(str(first.get("id", "")))
	var second: Dictionary = appendix.match_patient_interaction("operative_contact", ["incision"], "pain")
	expect(first.get("id") == "contact_pain_incision_01" and second.get("id") == "contact_pain_incision_02", "Repeatable variants did not rotate in authored order")
	appendix.patient_interaction_history.append(str(second.get("id", "")))
	expect(appendix.match_patient_interaction("operative_contact", ["incision"], "pain").get("id") == "contact_pain_incision_01", "Exhausted repeatable pool did not restart deterministically")

	var urologic = new_prep("surgery_open_nephrectomy")
	expect(urologic.match_patient_interaction("strain_interaction", ["pressure", "deep_manipulation"], "default").get("id") == "urologic_strain_pressure_01", "Urologic procedure-group pool did not match")

	var cabg = new_prep("surgery_cabg")
	cabg.procedure_step_index = 2
	cabg.pending_flow_stage_id = "procedure_flow"
	expect(cabg.resolve_patient_event_for_stage(), "CABG signature event did not resolve")
	expect(cabg.active_patient_interaction.get("id") == "cabg_signature_01", "CABG did not select its signature interaction")
	expect(cabg.patient_event_count == 1 and cabg.interaction_summary().contains("术中共处理1次清醒患者互动"), "Patient-event count was not added to the result summary")

	var invalid = {
		"id": "invalid_runtime_fixture",
		"theme": "operative_contact",
		"states": ["pain"],
		"cues": ["incision"],
		"procedure_groups": [],
		"surgery_ids": ["surgery_appendix"],
		"once_per_surgery": false,
		"prompt": "",
		"speaker": "patient",
		"actions": [],
	}
	appendix.patient_interactions.push_front(invalid)
	appendix.patient_interaction_history.clear()
	expect(appendix.match_patient_interaction("operative_contact", ["incision"], "pain").get("id") == "contact_pain_incision_01", "Malformed runtime interaction blocked a safe fallback")

	print("SURGERY PHASE 1C: %s checks; %s failure(s)" % [checks, failures])
	quit(failures)
