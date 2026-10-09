extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const Store = preload("res://godot/systems/save_store.gd")
const PreopView = preload("res://godot/ui/preop_view.gd")
const OperativeBackgrounds = preload("res://godot/systems/operative_backgrounds.gd")
const CLINIC = ["greet", "basic_history", "to_exam", "vitals", "limited_clothed_exam", "blood", "imaging", "to_diagnosis", "diagnose_appendix", "explain", "admit"]
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
	# This suite verifies authored pre-op routes. Pin each patient to the legacy
	# fixture that owns that route so unrelated randomized case assignment cannot
	# make the assertions flaky.
	game.patient_cases = game.legacy_patient_cases()
	game.rebuild_patient_content(game.patient_cases)
	for surgery in content.collections.surgeries:
		if str(surgery.get("status", "ready")) != "placeholder":
			game.unlock_procedure(str(surgery.id))
	for person in content.collections.staff:
		game.meet_staff(person.id)
	return game

func admitted_game() -> RefCounted:
	var game = new_game()
	var visit = game.open_visit("visit_sora")
	for action in CLINIC:
		visit.apply(action)
	return game

func act(prep: RefCounted, id: String) -> bool:
	return prep.apply({"kind": "action", "id": id})

func left_click() -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	return event

func finish_operative_preparation(prep: RefCounted, branch: String) -> bool:
	if prep.current().kind == "anesthesia_sensory_test":
		if not prep.apply({"kind": "anesthesia_sensory_test_complete"}):
			return false
	for action_id in [
		"operative_positioning", "ack_positioning",
		"urinary_catheterization", "ack_catheterization",
		"skin_disinfection", "ack_disinfection",
		"incision_marking", "ack_marking_" + branch,
	]:
		if not act(prep, action_id):
			return false
	var expected_stage := "surgery_start_none_confirmed" if branch == "none" else "surgery_start_" + branch
	return prep.stage_id == expected_stage

func finish_manual_ward_preparation(prep: RefCounted) -> bool:
	for action_id in [
		"ward_enema", "ack_ward_enema",
		"ward_skin_prep", "ack_ward_skin_prep",
		"ward_surgical_cap", "complete_manual_ward_preparation",
	]:
		if not act(prep, action_id):
			return false
	return prep.stage_id == "prepared" and prep.flags.has("patient_prepared") and prep.flags.has("manual_ward_preparation_complete")

func assign(prep: RefCounted, role: String, person: String) -> bool:
	return prep.apply({"kind": "assign", "role": role, "staff_id": person})

func procedure(prep: RefCounted, id: String) -> bool:
	return prep.apply({"kind": "procedure", "id": id})

func surgery_step(prep: RefCounted, id: String) -> bool:
	return prep.apply({"kind": "surgery_step", "id": id})

func acknowledge_flow(prep: RefCounted) -> bool:
	return prep.apply({"kind": "flow_acknowledge"})

func acknowledge_patient(prep: RefCounted) -> bool:
	return prep.apply({"kind": "patient_acknowledge"})

func finish_surgery_flow(prep: RefCounted, choose_one_wrong: bool = false) -> bool:
	var used_wrong := false
	while prep.current().kind != "surgery_execute":
		if prep.current().kind == "surgery_flow":
			if prep.awaiting_patient_choice:
				var interaction_actions: Array = prep.active_patient_interaction.get("actions", [])
				if interaction_actions.is_empty() or not prep.apply({"kind": "patient_interaction_action", "id": interaction_actions[0].id}):
					return false
				continue
			if prep.awaiting_patient_acknowledgement:
				if not acknowledge_patient(prep):
					return false
				continue
			var step: Dictionary = prep.surgery_flow_step()
			if step.is_empty():
				return false
			var selected: Dictionary = step.options[0]
			if step.kind == "decision":
				for option in step.options:
					if choose_one_wrong and not used_wrong and not option.correct:
						selected = option
						used_wrong = true
						break
					if not choose_one_wrong and option.correct:
						selected = option
			if not surgery_step(prep, selected.id):
				return false
			if not acknowledge_flow(prep):
				return false
	return true

func preop_id_for_patient(game: RefCounted, patient_id: String) -> String:
	for id in game.preop_definitions:
		if game.preop_definitions[id].patient_id == patient_id:
			return id
	return ""

func check_roundtrip(game: RefCounted) -> void:
	var clone = new_game()
	var source_snapshot: Dictionary = game.snapshot()
	var json_data: Variant = JSON.parse_string(JSON.stringify(source_snapshot))
	expect(clone.restore(json_data), "Roundtrip failed")
	var clone_snapshot: Dictionary = clone.snapshot()
	var normalized_clone: Variant = JSON.parse_string(JSON.stringify(clone_snapshot))
	expect(normalized_clone == json_data, "Roundtrip event log differs")
	if game.active_mode == "preop":
		var a = game.preops[game.active_preop_id]
		var b = clone.preops[clone.active_preop_id]
		expect(a.stage_id == b.stage_id and a.team == b.team and a.selected_preparations == b.selected_preparations and a.anxiety == b.anxiety and a.minutes == b.minutes and a.feedback == b.feedback and a.staff_outfit() == b.staff_outfit(), "Roundtrip state differs")
		expect(a.fear == b.fear and a.pain == b.pain and a.dignity == b.dignity and a.cooperation_base == b.cooperation_base and a.cooperation_value() == b.cooperation_value() and a.anesthesia == b.anesthesia, "Roundtrip interaction state differs")
		expect(a.procedure_id == b.procedure_id and a.procedure_minutes == b.procedure_minutes and a.procedure_extra_minutes == b.procedure_extra_minutes and a.procedure_state == b.procedure_state and a.surgery_success == b.surgery_success, "Roundtrip procedure state differs")
		expect(a.procedure_step_index == b.procedure_step_index and a.procedure_step_history == b.procedure_step_history and a.procedure_corrections == b.procedure_corrections and a.patient_event_count == b.patient_event_count, "Roundtrip surgery-flow state differs")
		expect(a.awaiting_flow_acknowledgement == b.awaiting_flow_acknowledgement and a.awaiting_patient_acknowledgement == b.awaiting_patient_acknowledgement and a.pending_flow_stage_id == b.pending_flow_stage_id and a.pending_flow_retry == b.pending_flow_retry, "Roundtrip surgery-flow acknowledgement differs")
		expect(a.operative_background_id == b.operative_background_id, "Roundtrip operative background differs")
		expect(a.procedure_mismatch == b.procedure_mismatch, "Roundtrip procedure mismatch differs")
		expect(a.last_staff_id == b.last_staff_id and a.last_staff_role == b.last_staff_role and a.feedback_speaker == b.feedback_speaker, "Roundtrip dialogue attribution differs")
		expect(a.active_temporary_conditions == b.active_temporary_conditions and a.active_condition_id == b.active_condition_id and a.temporary_conditions_enabled == b.temporary_conditions_enabled, "Roundtrip temporary-condition state differs")
		expect(a.or_table_palpation_counts == b.or_table_palpation_counts, "Roundtrip palpation counts differ")
		expect(a.or_table_needle_counts == b.or_table_needle_counts and a.anesthesia_test_counts == b.anesthesia_test_counts, "Roundtrip needle or anesthesia-test counts differ")
		expect(a.or_table_palpation_cg_id == b.or_table_palpation_cg_id, "Roundtrip palpation CG selection differs")

func run() -> void:
	expect(content.load_all(), "Could not load content")
	var condition_definition: Dictionary = content.collections.preops[0].duplicate(true)
	var nausea_prep = Preop.new(condition_definition, content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions)
	nausea_prep.procedure_id = "surgery_open_cholecystectomy"
	nausea_prep.procedure_name = "开腹胆囊切除术"
	nausea_prep.procedure_minutes = 120
	nausea_prep.procedure_step_index = 2
	nausea_prep.stage_id = "procedure_flow"
	nausea_prep.pending_flow_stage_id = "procedure_flow"
	nausea_prep.team = {"assistant_surgeon": "doc_aoi", "circulating_nurse": "nurse_haru", "scrub_nurse": "nurse_yui"}
	expect(nausea_prep.resolve_patient_event_for_stage() and nausea_prep.active_condition_id == "nausea" and nausea_prep.awaiting_patient_choice, "Nausea cue did not create a temporary condition")
	expect(nausea_prep.feedback.begins_with("「医生") and not nausea_prep.feedback.begins_with("患者"), "Nausea prompt was not written as the patient's own emotional speech")
	expect(nausea_prep.active_patient_interaction.actions.size() == 4 and nausea_prep.temporary_condition_status_text().contains("恶心 · 1级"), "Nausea condition did not expose four handling routes and severity")
	expect(nausea_prep.apply({"kind": "patient_interaction_action", "id": "delegate_nausea_assistant"}), "Assistant nausea delegation failed")
	expect(nausea_prep.last_staff_id == "doc_aoi" and nausea_prep.last_staff_role == "assistant_surgeon" and nausea_prep.feedback_speaker == "staff" and nausea_prep.feedback.begins_with(str(nausea_prep.roster.doc_aoi.name) + "："), "Assistant delegation did not use the assigned staff member")
	expect(nausea_prep.procedure_extra_minutes == 2 and not nausea_prep.active_temporary_conditions.has("nausea"), "Assistant delegation did not add time and clear nausea")
	expect(acknowledge_patient(nausea_prep) and nausea_prep.procedure_step_index == 3, "Handled nausea did not advance the surgery flow")

	var persistence_prep = Preop.new(condition_definition, content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions)
	persistence_prep.procedure_id = "surgery_open_cholecystectomy"
	persistence_prep.procedure_name = "开腹胆囊切除术"
	persistence_prep.procedure_step_index = 2
	persistence_prep.stage_id = "procedure_flow"
	persistence_prep.pending_flow_stage_id = "procedure_flow"
	persistence_prep.team = nausea_prep.team.duplicate(true)
	expect(persistence_prep.resolve_patient_event_for_stage() and persistence_prep.apply({"kind": "patient_interaction_action", "id": "ignore_nausea"}), "Ignoring nausea failed")
	expect(persistence_prep.active_temporary_conditions.nausea.severity == 2 and persistence_prep.active_temporary_conditions.nausea.remaining_steps == 3, "Ignoring nausea did not intensify and extend it")
	expect(acknowledge_patient(persistence_prep) and persistence_prep.active_temporary_conditions.nausea.remaining_steps == 2, "Persistent nausea did not tick after the completed stage")
	persistence_prep.pending_flow_stage_id = "procedure_execute"
	expect(persistence_prep.resolve_patient_event_for_stage() and persistence_prep.active_condition_id == "nausea" and persistence_prep.temporary_condition_status_text().contains("2级"), "Persistent nausea did not return on the following stage")
	var expiring_nausea: Dictionary = persistence_prep.active_temporary_conditions.nausea
	expiring_nausea.remaining_steps = 1
	persistence_prep.active_temporary_conditions.nausea = expiring_nausea
	persistence_prep.tick_temporary_conditions()
	expect(not persistence_prep.active_temporary_conditions.has("nausea"), "Temporary nausea did not expire when its remaining step count reached zero")

	var drowsiness_prep = Preop.new(condition_definition, content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions)
	drowsiness_prep.procedure_id = "surgery_open_abdominal_myomectomy"
	drowsiness_prep.procedure_name = "开腹子宫肌瘤剔除术"
	drowsiness_prep.procedure_step_index = 2
	drowsiness_prep.stage_id = "procedure_flow"
	drowsiness_prep.pending_flow_stage_id = "procedure_flow"
	drowsiness_prep.team = nausea_prep.team.duplicate(true)
	expect(drowsiness_prep.resolve_patient_event_for_stage() and drowsiness_prep.active_condition_id == "drowsiness", "Drowsiness cue did not create its temporary condition")
	expect(drowsiness_prep.feedback.begins_with("「医生") and not drowsiness_prep.feedback.begins_with("患者"), "Drowsiness prompt was not written as the patient's own emotional speech")
	expect(drowsiness_prep.apply({"kind": "patient_interaction_action", "id": "delegate_drowsiness_circulating"}), "Circulating-nurse drowsiness delegation failed")
	expect(drowsiness_prep.last_staff_id == "nurse_haru" and drowsiness_prep.last_staff_role == "circulating_nurse" and drowsiness_prep.feedback.begins_with(str(drowsiness_prep.roster.nurse_haru.name) + "：") and drowsiness_prep.procedure_extra_minutes == 2, "Circulating-nurse delegation did not use the assigned staff member or add time")

	var priority_prep = Preop.new(condition_definition, content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions)
	priority_prep.procedure_id = "surgery_open_whipple"
	priority_prep.procedure_name = "开腹胰十二指肠切除"
	priority_prep.procedure_step_index = 2
	priority_prep.stage_id = "procedure_flow"
	priority_prep.pending_flow_stage_id = "procedure_flow"
	priority_prep.team = nausea_prep.team.duplicate(true)
	expect(priority_prep.resolve_patient_event_for_stage() and priority_prep.active_temporary_conditions.has("nausea") and priority_prep.active_temporary_conditions.has("drowsiness"), "Combined cues did not create both temporary conditions")
	expect(priority_prep.active_condition_id == "nausea", "Equal-severity temporary conditions did not use the fixed priority")
	priority_prep.flags.append("anesthetized")
	priority_prep.active_temporary_conditions.clear()
	priority_prep.active_patient_interaction.clear()
	expect(not priority_prep.resolve_patient_event_for_stage() and priority_prep.active_temporary_conditions.is_empty(), "General anesthesia did not suppress temporary conditions")

	# Phase 1C content selection: exact surgery scope outranks procedure group,
	# once-only signature content falls back safely, and equal candidates rotate
	# deterministically before restarting the pool.
	var selection_prep = Preop.new(condition_definition, content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions)
	selection_prep.procedure_id = "surgery_hysterectomy"
	selection_prep.refresh_operative_positioning_stage()
	expect(selection_prep.operative_position() == "lithotomy", "Hysterectomy did not select lithotomy positioning")
	expect(selection_prep.stages.operative_positioning.prompt.contains("截石位") and selection_prep.stages.operative_positioning.actions[0].label.contains("腿架"), "Lithotomy positioning copy was not applied")
	var position_portrait_patient := {
		"visuals": {"portraits": {
			"operating_table/awake": "supine.png",
			"operating_table_lithotomy/awake": "lithotomy.png",
		}}
	}
	expect(PreopView.operating_table_outfit(selection_prep, position_portrait_patient, "awake") == "operating_table_lithotomy", "Lithotomy surgery did not select its position-specific interface portrait")
	expect(PreopView.operating_table_outfit(selection_prep, position_portrait_patient, "afraid") == "operating_table", "Missing lithotomy expression did not fall back to the supine set")
	var signature: Dictionary = selection_prep.match_patient_interaction("dignity_interaction", ["exposure", "deep_manipulation"], "default")
	expect(signature.get("id") == "hysterectomy_signature_01", "Surgery-specific signature interaction did not outrank the pelvic group pool")
	selection_prep.patient_interaction_history.append("hysterectomy_signature_01")
	var signature_fallback: Dictionary = selection_prep.match_patient_interaction("dignity_interaction", ["exposure", "deep_manipulation"], "default")
	expect(signature_fallback.get("id") == "pelvic_dignity_default_01", "Used once-per-surgery interaction did not fall back to its procedure group")
	selection_prep.procedure_id = "surgery_appendix"
	selection_prep.refresh_operative_positioning_stage()
	expect(selection_prep.operative_position() == "supine" and selection_prep.stages.operative_positioning.prompt.contains("仰卧体位"), "Appendectomy did not retain supine positioning")
	expect(PreopView.operating_table_outfit(selection_prep, position_portrait_patient, "awake") == "operating_table", "Supine surgery selected a lithotomy interface portrait")
	selection_prep.patient_interaction_history.clear()
	var first_contact: Dictionary = selection_prep.match_patient_interaction("operative_contact", ["incision"], "pain")
	selection_prep.patient_interaction_history.append(str(first_contact.get("id", "")))
	var second_contact: Dictionary = selection_prep.match_patient_interaction("operative_contact", ["incision"], "pain")
	expect(first_contact.get("id") == "contact_pain_incision_01" and second_contact.get("id") == "contact_pain_incision_02", "Equal-priority interaction variants did not rotate in authored order")
	selection_prep.patient_interaction_history.append(str(second_contact.get("id", "")))
	expect(selection_prep.match_patient_interaction("operative_contact", ["incision"], "pain").get("id") == "contact_pain_incision_01", "Exhausted repeatable interaction pool did not restart deterministically")
	selection_prep.flags.append("no_anesthesia_confirmed")
	selection_prep.patient_interaction_history.clear()
	var first_unanesthetized_contact: Dictionary = selection_prep.match_patient_interaction("operative_contact", ["incision"], "pain")
	selection_prep.patient_interaction_history.append(str(first_unanesthetized_contact.get("id", "")))
	var second_unanesthetized_contact: Dictionary = selection_prep.match_patient_interaction("operative_contact", ["incision"], "fear")
	expect(first_unanesthetized_contact.get("id") == "contact_no_anesthesia_incision_01" and second_unanesthetized_contact.get("id") == "contact_no_anesthesia_incision_02", "No-anesthesia incision reactions did not use their dedicated pain pool")
	expect(not str(first_unanesthetized_contact.get("prompt", "")).contains("已经开始了吗"), "No-anesthesia incision reaction still asked whether surgery had started")
	var anesthesia_request: Dictionary = {}
	for interaction in content.collections.patient_interactions:
		if interaction.get("id") == "contact_no_anesthesia_incision_03":
			anesthesia_request = interaction
			break
	expect(not anesthesia_request.is_empty() and anesthesia_request.actions.size() == 2, "No-anesthesia request interaction is missing")
	for response_action in anesthesia_request.get("actions", []):
		expect(str(response_action.get("label", "")).contains("拒绝追加麻醉") and not response_action.has("anesthesia") and not response_action.has("flags"), "An anesthesia-request response did not explicitly refuse additional anesthesia")
	selection_prep.flags.erase("no_anesthesia_confirmed")
	selection_prep.procedure_id = "surgery_open_nephrectomy"
	expect(selection_prep.match_patient_interaction("strain_interaction", ["pressure", "deep_manipulation"], "default").get("id") == "urologic_strain_pressure_01", "Urologic procedure-group interaction pool did not match")
	selection_prep.procedure_id = "surgery_cabg"
	selection_prep.procedure_step_index = 2
	selection_prep.stage_id = "procedure_flow"
	selection_prep.pending_flow_stage_id = "procedure_flow"
	selection_prep.patient_interaction_history.clear()
	expect(selection_prep.resolve_patient_event_for_stage() and selection_prep.active_patient_interaction.get("id") == "cabg_signature_01" and selection_prep.patient_event_count == 1, "Signature patient event was not counted when opened")
	expect(selection_prep.interaction_summary().contains("术中共处理1次清醒患者互动"), "Interaction summary did not report the patient-event count")
	var dialogue_profile: Dictionary = content.find_record("surgery_team_dialogue_profiles", "inexperienced_nurse")
	expect(not dialogue_profile.is_empty(), "Inexperienced nurse dialogue profile did not load")
	if not dialogue_profile.is_empty():
		var dialogue_prep = Preop.new(content.collections.preops[0], content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles)
		for response_id in dialogue_profile.responses:
			var line := dialogue_prep.inexperienced_nurse_response("nurse_satsuki", response_id, "fallback")
			expect(line in dialogue_profile.responses[response_id], "Limited nurse did not use generic dialogue at " + response_id)
		expect(dialogue_prep.inexperienced_nurse_response("nurse_haru", "request_scalpel", "trained fallback") == "trained fallback", "Expert nurse incorrectly used inexperienced dialogue")
	for background_id in OperativeBackgrounds.IDS:
		expect(not content.find_record("backgrounds", background_id).is_empty(), "Operative background is not registered: " + background_id)
	var personality_lines := {}
	var personality_outcomes := {}
	for patient in content.collections.patients:
		var patient_definition: Dictionary = {}
		for candidate in content.collections.preops:
			if candidate.patient_id == patient.id:
				patient_definition = candidate
				break
		expect(not patient_definition.is_empty(), "Missing preop personality fixture for " + patient.id)
		if patient_definition.is_empty():
			continue
		var personality_prep = Preop.new(patient_definition, content.collections.staff, content.collections.surgeries, content.collections.patients)
		expect(personality_prep.patient_personality == patient.personality and personality_prep.patient_traits == patient.traits, "Patient personality was not loaded for " + patient.id)
		# Normalize pre-existing per-patient starting values so this assertion isolates
		# the effects of the same three actions from personality presentation.
		personality_prep.fear = 50
		personality_prep.pain = 20
		personality_prep.dignity = 70
		personality_prep.cooperation_base = 50
		personality_prep.stage_id = "ready"
		expect(act(personality_prep, "choose_local"), "Could not trigger personality anesthesia line for " + patient.id)
		expect(personality_prep.feedback == patient.reaction_lines.choose_local, "Wrong personality anesthesia line for " + patient.id)
		expect(personality_prep.stage_id == "anesthesia_sensory_test" and personality_prep.apply({"kind": "anesthesia_sensory_test_complete"}), "Awake anesthesia did not enter or leave optional sensory testing for " + patient.id)
		expect(personality_prep.stage_id == "operative_positioning", "Awake anesthesia did not enter operative preparation for " + patient.id)
		expect(act(personality_prep, "operative_positioning"), "Could not perform operative positioning for " + patient.id)
		expect(personality_prep.feedback in patient.reaction_variants.operative_positioning_awake, "Positioning did not use an awake personality variant for " + patient.id)
		expect(act(personality_prep, "ack_positioning") and act(personality_prep, "urinary_catheterization"), "Could not perform awake catheterization for " + patient.id)
		expect(personality_prep.feedback in patient.reaction_variants.urinary_catheterization_awake, "Catheterization did not use an awake personality variant for " + patient.id)
		expect(act(personality_prep, "ack_catheterization") and act(personality_prep, "skin_disinfection"), "Could not perform awake disinfection for " + patient.id)
		expect(personality_prep.feedback in patient.reaction_variants.skin_disinfection_awake, "Disinfection did not use an awake personality variant for " + patient.id)
		expect(act(personality_prep, "ack_disinfection") and act(personality_prep, "incision_marking"), "Could not perform awake marking for " + patient.id)
		expect(personality_prep.feedback in patient.reaction_variants.incision_marking_awake, "Marking did not use an awake personality variant for " + patient.id)
		personality_prep.stage_id = "operative_contact"
		expect(act(personality_prep, "contact_pause"), "Could not trigger personality intraoperative line for " + patient.id)
		expect(personality_prep.feedback == patient.reaction_lines.contact_pause, "Wrong personality intraoperative line for " + patient.id)
		personality_prep.stage_id = "ongoing_interaction"
		expect(act(personality_prep, "ongoing_silent"), "Could not trigger personality narration for " + patient.id)
		expect(personality_prep.feedback == patient.reaction_lines.ongoing_silent, "Wrong personality narration for " + patient.id)
		personality_lines[patient.reaction_lines.contact_pause] = true
		personality_outcomes[JSON.stringify({"fear": personality_prep.fear, "pain": personality_prep.pain, "dignity": personality_prep.dignity, "cooperation_base": personality_prep.cooperation_base})] = true
	expect(personality_lines.size() == content.collections.patients.size(), "Patients reused the same intraoperative personality line")
	expect(personality_outcomes.size() == 1, "Patient personality changed shared action outcomes")
	var game = new_game()
	expect(game.open_preop("preop_sora") == null, "Preop opened before admission")
	game = admitted_game()
	# Actual v1 representation: no preop or routing fields.
	var old_save := {"version": 1, "content_version": 1, "active_id": "visit_sora", "progress": game.snapshot().progress}
	var migrated = new_game()
	expect(not migrated.restore(JSON.parse_string(JSON.stringify(old_save))), "Retired v1 save was accepted")
	var prep = game.open_preop("preop_sora")
	expect(prep.surgery_options().size() >= 25, "Expanded surgery catalog did not load")
	for surgery in prep.surgery_options():
		if surgery.stages.is_empty():
			continue
		var flow_game = admitted_game()
		var flow_prep = flow_game.open_preop("preop_sora")
		flow_prep.procedure_id = surgery.id
		flow_prep.procedure_name = surgery.name
		flow_prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin"}
		flow_prep.flags.append_array(["incision_made", "anesthesia_chosen"])
		flow_prep.stage_id = "procedure_flow"
		expect(flow_prep.surgery_flow_steps().size() >= 4 and finish_surgery_flow(flow_prep) and flow_prep.stage_id == "procedure_execute", "Surgery flow could not complete: " + surgery.id)
	expect(prep.duration_text(90) == "1小时30分钟", "Half-hour surgery duration formatting wrong")
	expect(PreopView.expression_for_patient(prep, prep.current()) == "worried", "Initial patient expression wrong")
	expect(not act(prep, "enter_room"), "Skipped directly to room")
	expect(not assign(prep, "assistant_surgeon", "doc_aoi"), "Assigned outside team stage")
	expect(act(prep, "brief_plan"), "Ward visit failed")
	expect(not act(prep, "confirm_team"), "Incomplete team accepted")
	expect(not assign(prep, "assistant_surgeon", "nurse_haru"), "Nurse accepted as assistant")
	expect(assign(prep, "assistant_surgeon", "doc_aoi"), "Assistant assignment failed")
	expect(assign(prep, "scrub_nurse", "nurse_haru"), "Scrub assignment failed")
	expect(not assign(prep, "circulating_nurse", "nurse_haru"), "Duplicate staff allowed")
	expect(assign(prep, "circulating_nurse", "nurse_rin"), "Circulating assignment failed")
	check_roundtrip(game)
	expect(act(prep, "confirm_team"), "Team confirmation failed")
	expect(not assign(prep, "assistant_surgeon", "doc_rei"), "Confirmed team changed later")
	expect(not act(prep, "perform_preparation"), "Executed without ward nurse")
	expect(not assign(prep, "ward_nurse", "nurse_rin"), "OR nurse also assigned to ward")
	expect(assign(prep, "ward_nurse", "nurse_yui"), "Ward nurse assignment failed")
	for id in ["explain_again", "family_call"]:
		expect(prep.apply({"kind": "toggle", "id": id}), "Optional preparation failed")
	expect(not prep.apply({"kind": "toggle", "id": "company"}), "Selected more than two optional tasks")
	expect(prep.minutes == 1 and prep.anxiety == 2, "Unexecuted task affected patient")
	check_roundtrip(game)
	expect(act(prep, "perform_preparation"), "Preparation execution failed")
	expect(prep.minutes == 13 and prep.anxiety == 0 and prep.patient_visual_state() == "preoperative", "Preparation effects incorrect")
	expect(PreopView.expression_for_patient(prep, prep.current()) == "smile", "Calm ward expression wrong")
	expect(not act(prep, "perform_preparation"), "Prepared twice")
	check_roundtrip(game)
	var manual_game = admitted_game()
	var manual_prep = manual_game.open_preop("preop_sora")
	expect(act(manual_prep, "brief_plan"), "Manual preparation visit failed")
	expect(assign(manual_prep, "assistant_surgeon", "doc_aoi") and assign(manual_prep, "scrub_nurse", "nurse_haru") and assign(manual_prep, "circulating_nurse", "nurse_rin"), "Manual preparation team assignment failed")
	expect(act(manual_prep, "confirm_team"), "Manual preparation team confirmation failed")
	expect(not act(manual_prep, "begin_manual_ward_preparation"), "Manual preparation started without ward nurse")
	expect(assign(manual_prep, "ward_nurse", "nurse_yui"), "Manual preparation ward nurse assignment failed")
	expect(act(manual_prep, "begin_manual_ward_preparation") and manual_prep.stage_id == "ward_enema" and manual_prep.feedback_speaker == "staff", "Manual preparation branch did not start with nurse response")
	expect(PreopView.manual_ward_examination_portrait(manual_prep, manual_prep.current()), "Manual ward preparation did not select the examination portrait")
	expect(finish_manual_ward_preparation(manual_prep), "Manual ward preparation did not complete all three steps")
	expect(not PreopView.manual_ward_examination_portrait(manual_prep, manual_prep.current()), "Manual ward preparation kept the nude portrait after the preparation flow completed")
	expect(manual_prep.flags.has("ward_enema_complete") and manual_prep.flags.has("ward_skin_prep_complete") and manual_prep.flags.has("ward_cap_fitted"), "Manual ward preparation flags incomplete")
	expect(manual_prep.feedback_speaker == "staff" and manual_prep.last_staff_role == "ward_nurse", "Manual preparation did not end with ward nurse handoff")
	check_roundtrip(manual_game)
	var required_definition: Dictionary = {}
	var breast_definition: Dictionary = {}
	for definition in content.collections.preops:
		if definition.id == "preop_sora":
			required_definition = definition
		elif definition.id == "preop_emi":
			breast_definition = definition
	var skipped_required_prep = Preop.new(required_definition, content.collections.staff, content.collections.surgeries, content.collections.patients)
	skipped_required_prep.stage_id = "preparation"
	skipped_required_prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin", "ward_nurse": "nurse_yui"}
	expect(skipped_required_prep.lower_abdominal_preparation_required(), "Appendix surgery did not require abdominal preparation")
	expect(act(skipped_required_prep, "begin_manual_ward_preparation") and act(skipped_required_prep, "skip_required_ward_enema"), "Required enema could not be skipped")
	expect(skipped_required_prep.flags.has("required_enema_omitted") and skipped_required_prep.feedback_speaker == "staff", "Skipping required enema did not trigger nurse objection")
	expect(act(skipped_required_prep, "ack_ward_enema") and act(skipped_required_prep, "skip_required_ward_skin_prep"), "Required skin preparation could not be skipped")
	expect(skipped_required_prep.flags.has("required_skin_prep_omitted") and skipped_required_prep.feedback_speaker == "staff", "Skipping required skin preparation did not trigger nurse objection")
	var breast_prep = Preop.new(breast_definition, content.collections.staff, content.collections.surgeries, content.collections.patients)
	breast_prep.stage_id = "preparation"
	breast_prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin", "ward_nurse": "nurse_yui"}
	expect(not breast_prep.lower_abdominal_preparation_required(), "Breast surgery incorrectly required abdominal preparation")
	expect(act(breast_prep, "begin_manual_ward_preparation") and breast_prep.current().actions[0].id == "skip_ward_enema", "Breast preparation did not recommend skipping enema")
	expect(act(breast_prep, "ward_enema_unnecessary") and breast_prep.flags.has("unnecessary_enema_performed") and breast_prep.feedback_speaker == "patient", "Unnecessary breast-surgery enema did not trigger patient reaction")
	expect(act(breast_prep, "ack_ward_enema") and breast_prep.current().actions[0].id == "skip_ward_skin_prep", "Breast preparation did not recommend skipping lower preparation")
	expect(act(breast_prep, "ward_skin_prep_unnecessary") and breast_prep.flags.has("unnecessary_skin_prep_performed") and breast_prep.feedback_speaker == "patient", "Unnecessary breast-surgery skin preparation did not trigger patient reaction")
	expect(act(prep, "to_changing"), "Could not reach changing area")
	expect(not act(prep, "scrub_hands"), "Scrub before changing accepted")
	expect(not act(prep, "enter_room"), "Entered room before changing")
	expect(act(prep, "change_scrubs"), "Change failed")
	expect(not act(prep, "enter_room"), "Entered room before scrubbing")
	expect(not act(prep, "change_scrubs"), "Changed twice")
	check_roundtrip(game)
	expect(act(prep, "scrub_hands") and act(prep, "enter_room"), "Could not enter room")
	expect(prep.patient_visual_state() == "operating_room" and prep.staff_outfit() == "scrubs", "Visual states wrong")
	expect(PreopView.expression_for_patient(prep, prep.current()) == "awake", "Operating-room expression wrong")
	expect(act(prep, "last_reassure") and not act(prep, "last_reassure"), "Reassurance repeated")
	expect(act(prep, "team_check") and prep.stage_id == "team_confirmations", "Team confirmations did not open before procedure selection")
	expect(act(prep, "confirm_assistant_role") and prep.last_staff_id == "doc_aoi" and prep.last_staff_role == "assistant_surgeon", "Assistant confirmation did not select its speaker")
	expect(act(prep, "confirm_scrub_role") and prep.last_staff_id == "nurse_haru" and prep.last_staff_role == "scrub_nurse", "Scrub confirmation did not select its speaker")
	expect(act(prep, "confirm_circulating_role") and prep.last_staff_id == "nurse_rin" and prep.last_staff_role == "circulating_nurse" and prep.stage_id == "procedure_select", "Circulating confirmation did not reach procedure selection")
	var before_selection_minutes: int = prep.minutes
	expect(procedure(prep, "surgery_cabg") and prep.stage_id == "procedure_mismatch", "Wrong procedure did not open standalone reaction")
	expect(prep.minutes == before_selection_minutes and not prep.surgery_success, "Procedure ran during confirmation")
	expect(prep.procedure_mismatch and prep.flags.has("wrong_procedure_selected") and prep.fear == 75, "Wrong-procedure fear response missing")
	expect(prep.feedback == content.find_record("patients", "patient_sora").reaction_lines.procedure_mismatch and not prep.feedback.contains("过去了"), "Wrong-procedure personality dialogue was not used")
	expect(PreopView.expression_for_patient(prep, prep.current()) == "afraid", "Wrong-procedure expression missing")
	expect(not procedure(prep, "surgery_appendix"), "Second procedure selection accepted")
	check_roundtrip(game)
	var correction_game = new_game()
	expect(correction_game.restore(JSON.parse_string(JSON.stringify(game.snapshot()))), "Mismatch branch could not be cloned")
	var correction_prep = correction_game.preops.preop_sora
	expect(act(correction_prep, "correct_procedure_selection") and correction_prep.stage_id == "procedure_select", "Could not return to procedure selection")
	expect(correction_prep.procedure_id.is_empty() and not correction_prep.procedure_mismatch and correction_prep.flags.has("wrong_procedure_corrected"), "Corrected procedure retained mismatch state")
	expect(correction_game.player_attributes() == {"skill": 50, "leadership": 50, "charm": 0, "reputation": 0, "presence": 0}, "Correcting selection changed player attributes")
	expect(act(prep, "acknowledge_procedure_mismatch") and prep.stage_id == "or_table_palpation", "Wrong-procedure branch did not enter mandatory palpation before anesthesia")
	expect(game.player_attributes() == {"skill": 50, "leadership": 50, "charm": 0, "reputation": 0, "presence": 1}, "Deliberate wrong procedure did not change player attributes")
	expect(game.player_attribute_history().size() == 1 and game.player_attribute_history()[0].id == "acknowledge_procedure_mismatch", "Player attribute history missing deliberate wrong procedure")
	var palpation_game = new_game()
	expect(palpation_game.restore(JSON.parse_string(JSON.stringify(game.snapshot()))), "Palpation branch could not be cloned")
	var palpation_prep = palpation_game.preops.preop_sora
	var palpation_before := {"fear": palpation_prep.fear, "pain": palpation_prep.pain, "dignity": palpation_prep.dignity, "cooperation": palpation_prep.cooperation_base, "minutes": palpation_prep.minutes}
	expect(palpation_prep.apply({"kind": "or_table_palpation", "region": "chest", "intensity": "standard"}) and palpation_prep.feedback.contains("胸骨"), "Generic chest palpation response failed")
	var pain_after_chest: int = palpation_prep.pain
	expect(palpation_prep.apply({"kind": "or_table_palpation", "region": "abdomen", "intensity": "deep"}), "Deep abdominal palpation failed")
	expect(palpation_prep.pain == pain_after_chest + 8 and palpation_prep.fear == palpation_before.fear + 3 and palpation_prep.feedback.contains("请轻一点"), "Deep abdominal palpation did not apply its pressure-specific response")
	expect(palpation_prep.apply({"kind": "or_table_palpation", "region": "breast", "intensity": "standard"}) and palpation_prep.feedback.contains("开刀的地方不是这里"), "Breast palpation response failed")
	expect(palpation_prep.apply({"kind": "or_table_palpation", "region": "nipple", "intensity": "light"}) and palpation_prep.feedback.contains("太敏感"), "Nipple palpation response failed")
	expect(palpation_prep.apply({"kind": "or_table_palpation", "region": "genital", "intensity": "standard"}) and palpation_prep.feedback.contains("不要摸"), "First genital palpation response failed")
	expect(palpation_prep.apply({"kind": "or_table_palpation", "region": "genital", "intensity": "standard"}) and palpation_prep.feedback.contains("好舒服"), "Alternating genital palpation response failed")
	expect(palpation_prep.minutes == palpation_before.minutes + 6 and palpation_prep.dignity < palpation_before.dignity and palpation_prep.cooperation_base < palpation_before.cooperation, "Palpation did not update time, dignity, and cooperation")
	expect(not palpation_prep.apply({"kind": "or_table_palpation", "region": "invalid", "intensity": "standard"}), "Invalid palpation region was accepted")
	expect(palpation_prep.apply({"kind": "or_table_palpation_complete"}) and palpation_prep.stage_id == "ready", "Palpation completion did not reach anesthesia selection")
	expect(not palpation_prep.apply({"kind": "or_table_palpation", "region": "abdomen", "intensity": "light"}), "Palpation remained available after completion")
	var scalpel_game = new_game()
	expect(scalpel_game.restore(JSON.parse_string(JSON.stringify(game.snapshot()))), "Scalpel branch could not be cloned")
	var scalpel_prep = scalpel_game.preops.preop_sora
	expect(scalpel_prep.apply({"kind": "or_table_scalpel", "region": "body"}), "Operating-table scalpel click failed")
	expect(scalpel_prep.pain == 100 and scalpel_prep.stage_id == "or_table_scalpel_incident" and scalpel_prep.feedback_speaker == "patient", "Scalpel click did not max pain and isolate the patient's scream")
	expect(scalpel_prep.flags.has("or_table_scalpel_incident") and scalpel_prep.flags.has("or_table_palpation_complete"), "Scalpel incident flags were not recorded")
	expect(act(scalpel_prep, "acknowledge_or_table_scalpel_incident") and scalpel_prep.stage_id == "ready", "Nurse warning did not force the anesthesia-selection stage")
	expect(scalpel_prep.feedback_speaker == "staff" and scalpel_prep.feedback.contains("怎么能不消毒、不麻醉就下刀"), "Nurse warning dialogue was not presented separately")
	var pre_palpation_save: Dictionary = game.snapshot()
	pre_palpation_save.preops.preop_sora.append({"kind": "action", "id": "choose_general"})
	var legacy_direct_anesthesia_game = new_game()
	expect(legacy_direct_anesthesia_game.restore(JSON.parse_string(JSON.stringify(pre_palpation_save))), "Pre-palpation save could not replay its direct anesthesia action")
	expect(legacy_direct_anesthesia_game.preops.preop_sora.flags.has("or_table_palpation_complete") and legacy_direct_anesthesia_game.preops.preop_sora.stage_id == "general_induction", "Legacy direct anesthesia replay did not bridge the inserted palpation stage")
	expect(prep.apply({"kind": "or_table_palpation_complete"}) and prep.stage_id == "ready", "Mandatory palpation could not be completed without extra touches")
	var anesthesia_seed: Dictionary = game.snapshot()
	var legacy_awake_save: Dictionary = anesthesia_seed.duplicate(true)
	legacy_awake_save.version = 11
	legacy_awake_save.preops.preop_sora.append_array([
		{"kind": "action", "id": "choose_none"},
		{"kind": "action", "id": "setup_brief"},
		{"kind": "action", "id": "contact_continue"},
		{"kind": "action", "id": "ongoing_silent"},
		{"kind": "action", "id": "closure_silent"},
	])
	var legacy_awake_game = new_game()
	expect(not legacy_awake_game.restore(legacy_awake_save), "Retired awake-surgery save was accepted")
	var legacy_completed_save: Dictionary = legacy_awake_save.duplicate(true)
	legacy_completed_save.preops.preop_sora.append({"kind": "action", "id": "execute_confirmed_procedure"})
	var legacy_completed_game = new_game()
	expect(not legacy_completed_game.restore(legacy_completed_save), "Retired completed-surgery save was accepted")
	var legacy_general_save: Dictionary = anesthesia_seed.duplicate(true)
	legacy_general_save.version = 11
	legacy_general_save.preops.preop_sora.append_array([
		{"kind": "action", "id": "choose_general"},
		{"kind": "action", "id": "induction_reassure"},
		{"kind": "action", "id": "contact_pause"},
		{"kind": "action", "id": "ongoing_narrate"},
		{"kind": "action", "id": "closure_reassure"},
	])
	var legacy_general_game = new_game()
	expect(not legacy_general_game.restore(legacy_general_save), "Retired general-anesthesia save was accepted")
	for branch_data in [
		{"choice": "choose_epidural", "start": "start_epidural_surgery", "incise": "incise_epidural", "flag": "epidural_anesthesia"},
		{"choice": "choose_local", "start": "start_local_surgery", "incise": "incise_local", "flag": "local_anesthesia"},
	]:
		var branch_game = new_game()
		expect(branch_game.restore(JSON.parse_string(JSON.stringify(anesthesia_seed))), "Awake anesthesia branch could not be cloned")
		var branch_prep = branch_game.preops.preop_sora
		expect(act(branch_prep, branch_data.choice) and finish_operative_preparation(branch_prep, str(branch_data.flag).trim_suffix("_anesthesia")) and act(branch_prep, branch_data.start), "Awake anesthesia start failed: " + branch_data.choice)
		expect(act(branch_prep, "request_scalpel") and branch_prep.last_staff_role == "scrub_nurse", "Scrub nurse did not hand over the scalpel")
		expect(act(branch_prep, "assistant_stabilize") and branch_prep.last_staff_role == "assistant_surgeon", "Assistant did not stabilize the incision site")
		expect(act(branch_prep, branch_data.incise) and branch_prep.stage_id == "procedure_flow" and branch_prep.flags.has(branch_data.flag) and branch_prep.flags.has("incision_made"), "Awake incision branch failed: " + branch_data.incise)
		expect(PreopView.intraoperative_patient_expression(branch_prep) == "tense", "Awake anesthesia did not select the tense intraoperative portrait")
	expect(act(prep, "choose_none") and prep.stage_id == "surgery_start_none", "No-anesthesia branch did not reach the start command")
	expect(prep.anesthesia == "未麻醉" and prep.fear == 100 and prep.pain == 0 and prep.dignity == 85 and prep.cooperation_value() == 45, "Initial no-anesthesia effects wrong")
	expect(game.can_save_progress(), "Saving was blocked before surgery started")
	var reconsider_game = new_game()
	expect(reconsider_game.restore(JSON.parse_string(JSON.stringify(game.snapshot()))), "No-anesthesia reconsider branch could not be cloned")
	var reconsider_prep = reconsider_game.preops.preop_sora
	expect(act(reconsider_prep, "reconsider_anesthesia") and reconsider_prep.stage_id == "ready" and reconsider_prep.anesthesia == "未选择", "One-time anesthesia reconsideration failed")
	expect(reconsider_prep.flags.has("anesthesia_reconsidered") and not reconsider_prep.flags.has("anesthesia_chosen") and not reconsider_prep.flags.has("no_anesthesia_selected"), "Reconsideration flags are wrong")
	var used_reconsider_game = new_game()
	expect(used_reconsider_game.restore(JSON.parse_string(JSON.stringify(reconsider_game.snapshot()))), "Used reconsideration state could not be cloned")
	var used_reconsider_prep = used_reconsider_game.preops.preop_sora
	expect(not act(used_reconsider_prep, "choose_none"), "The same no-anesthesia choice could be repeated after using reconsideration")
	expect(act(reconsider_prep, "choose_local") and reconsider_prep.stage_id == "anesthesia_sensory_test" and reconsider_prep.apply({"kind": "anesthesia_sensory_test_complete"}) and reconsider_prep.stage_id == "operative_positioning", "Reconsideration could not choose anesthesia")
	expect(act(prep, "insist_without_anesthesia"), "Could not insist on operating without anesthesia")
	expect(prep.fear == 100 and prep.pain == 0 and prep.dignity == 55 and prep.cooperation_value() == 15, "No-anesthesia breakdown effects wrong")
	expect(prep.stage_id == "operative_positioning", "No-anesthesia branch did not enter operative preparation")
	expect(act(prep, "operative_positioning") and prep.feedback in prep.patient_reaction_variants.operative_positioning_none, "No-anesthesia positioning did not use a refusal variant")
	expect(act(prep, "ack_positioning") and act(prep, "urinary_catheterization"), "No-anesthesia catheterization failed")
	expect(prep.feedback in prep.patient_reaction_variants.urinary_catheterization_none, "No-anesthesia catheterization did not use a refusal variant")
	expect(act(prep, "ack_catheterization") and act(prep, "skin_disinfection"), "No-anesthesia disinfection failed")
	expect(prep.feedback in prep.patient_reaction_variants.skin_disinfection_none, "No-anesthesia disinfection did not use a refusal variant")
	expect(act(prep, "ack_disinfection") and act(prep, "incision_marking"), "No-anesthesia marking failed")
	expect(prep.feedback in prep.patient_reaction_variants.incision_marking_none, "No-anesthesia marking did not use a refusal variant")
	expect(act(prep, "ack_marking_none") and prep.stage_id == "surgery_start_none_confirmed", "No-anesthesia preparation did not reach the final start command")
	expect(act(prep, "start_none_surgery"), "No-anesthesia final start command failed")
	expect(game.active_surgery_in_progress() and not game.can_save_progress() and not game.save_block_reason().is_empty(), "Surgery lock did not activate after surgery started")
	expect(game.next_character_event_at("lounge").is_empty() and game.next_character_event_for_preop_stage("changing").is_empty(), "Character event discovery leaked into an active surgery")
	expect(game.start_character_event("intro_pharmacist_manami") == null and game.active_mode == "preop", "A character event interrupted an active surgery")
	expect(act(prep, "request_scalpel") and prep.last_staff_role == "scrub_nurse", "Scrub nurse handoff failed")
	expect(act(prep, "assistant_stabilize") and prep.last_staff_role == "assistant_surgeon", "Assistant preparation failed")
	expect(prep.feedback.contains(prep.patient_name + "：") and prep.feedback.contains(prep.patient_reactions.assistant_stabilize_none) and not prep.feedback.contains("接近无法继续配合"), "Assistant stabilization did not use the no-anesthesia patient response")
	expect(act(prep, "incise_none") and prep.stage_id == "procedure_flow", "No-anesthesia incision failed")
	expect(PreopView.intraoperative_patient_expression(prep) == "pain", "No-anesthesia surgery did not select the pain portrait")
	expect(prep.fear == 100 and prep.pain == 80 and prep.dignity == 30 and prep.cooperation_value() == 0, "Incision response did not collapse at thresholds")
	expect(PreopView.expression_for_patient(prep, prep.current()) == "afraid", "Critical interaction expression wrong")
	expect(prep.stage_id == "procedure_flow" and prep.surgery_flow_steps().size() == 4, "Procedure-specific team flow did not start")
	expect(prep.awaiting_patient_acknowledgement and acknowledge_patient(prep) and prep.feedback.is_empty(), "Incision response was not cleared before the first procedure choice")
	expect(prep.stage_id == "procedure_flow" and prep.procedure_step_index == 0 and prep.pending_flow_stage_id.is_empty(), "Incision acknowledgement incorrectly consumed the first surgery-flow stage")
	expect(surgery_step(prep, "confirm_exposure") and prep.awaiting_flow_acknowledgement and prep.stage_id == "procedure_flow", "First procedure step did not pause on its team response")
	expect(not surgery_step(prep, "ask_assistant"), "Next procedure option was accepted before acknowledging the team response")
	expect(acknowledge_flow(prep) and prep.stage_id == "procedure_flow" and prep.awaiting_patient_choice and prep.active_patient_interaction.id == "contact_no_anesthesia_incision_01", "First team response did not open the no-anesthesia incision reaction")
	expect(prep.feedback.contains("这么痛真的是正常的吗") and not prep.feedback.contains("已经开始了吗"), "No-anesthesia incision used an anesthetized confirmation line")
	expect(prep.apply({"kind": "patient_interaction_action", "id": "continue_unanesthetized_contact_01"}) and prep.stage_id == "procedure_flow" and prep.procedure_step_index == 0 and prep.awaiting_patient_acknowledgement, "First no-anesthesia patient response did not open its acknowledgement page")
	expect(acknowledge_patient(prep) and prep.feedback.is_empty(), "First patient response was not cleared before the next choice")
	expect(surgery_step(prep, "ask_assistant") and prep.awaiting_flow_acknowledgement, "Team exchange did not pause on its response")
	var assistant_acknowledged := acknowledge_flow(prep)
	expect(assistant_acknowledged and prep.stage_id == "procedure_flow" and prep.procedure_step_index == 1 and prep.awaiting_patient_choice and prep.active_patient_interaction.get("id") == "cardiac_ongoing_fatigue_01", "Cardiac ongoing interaction did not open after the team exchange")
	expect(prep.apply({"kind": "patient_interaction_action", "id": "brief_cardiac_ongoing"}) and prep.awaiting_patient_acknowledgement, "Cardiac ongoing response did not open its acknowledgement page")
	expect(acknowledge_patient(prep) and prep.procedure_step_index == 2 and not prep.awaiting_patient_choice, "Cardiac ongoing response did not advance to the key decision")
	expect(PreopView.intraoperative_patient_expression(prep) == "near_collapse", "Late no-anesthesia surgery did not switch to the near-collapse portrait")
	var wrong_decision: Dictionary = {}
	for option in prep.surgery_flow_step().options:
		if not option.correct:
			wrong_decision = option
			break
	expect(not wrong_decision.is_empty() and surgery_step(prep, wrong_decision.id) and prep.awaiting_flow_acknowledgement, "Wrong key decision did not pause on the assistant correction")
	var corrected_step_index: int = int(prep.procedure_step_index)
	expect(prep.pending_flow_retry and acknowledge_flow(prep) and prep.stage_id == "procedure_flow" and prep.procedure_step_index == corrected_step_index, "Assistant correction did not return to the same decision")
	var correct_decision: Dictionary = {}
	for option in prep.surgery_flow_step().options:
		if option.correct:
			correct_decision = option
			break
	expect(not correct_decision.is_empty() and surgery_step(prep, correct_decision.id) and not prep.pending_flow_retry, "Corrected decision could not be selected")
	expect(acknowledge_flow(prep) and prep.stage_id == "procedure_flow" and prep.awaiting_patient_choice and prep.active_patient_interaction.id == "cabg_signature_01", "Corrected decision did not open the CABG signature interaction")
	expect(prep.apply({"kind": "patient_interaction_action", "id": "brief_cabg_milestone"}) and prep.awaiting_patient_acknowledgement, "CABG signature response did not open its acknowledgement page")
	expect(acknowledge_patient(prep) and prep.procedure_step_index == 3 and prep.feedback.is_empty(), "Cardiac patient response was not cleared before the last choice")
	expect(surgery_step(prep, "confirm_completion") and prep.awaiting_flow_acknowledgement, "Final procedure confirmation did not show its team response")
	expect(prep.procedure_step_history.size() == 5 and prep.procedure_corrections == 1 and prep.last_staff_role == "assistant_surgeon", "Wrong procedure choice was not retried after the assistant correction")
	expect(acknowledge_flow(prep) and prep.awaiting_patient_choice and prep.active_patient_interaction.id == "closure_default_01", "Final procedure confirmation did not open the closure interaction")
	expect(prep.apply({"kind": "patient_interaction_action", "id": "brief_closure"}) and prep.awaiting_patient_acknowledgement, "Closure response did not open its acknowledgement page")
	expect(acknowledge_patient(prep) and prep.stage_id == "procedure_execute" and prep.flags.has("interaction_complete"), "Confirmed procedure did not reach execution")
	var before_surgery_minutes: int = prep.minutes
	expect(act(prep, "execute_confirmed_procedure") and prep.stage_id == "surgery_result", "Confirmed procedure execution failed")
	expect(not game.active_surgery_in_progress() and game.can_save_progress(), "Navigation and saving did not return after the surgery result")
	expect(prep.minutes == before_surgery_minutes + 390 and prep.surgery_success and prep.procedure_name == "开胸心脏搭桥" and not prep.interaction_summary().is_empty(), "Procedure result or duration wrong")
	expect(game.player_attributes().skill == 50 and game.surgery_xp == 0, "Surgery XP was awarded before the completed case was settled")
	expect(prep.procedure_extra_minutes == 3 and prep.feedback.contains("额外3分钟") and prep.feedback.contains("总计6小时3分钟") and prep.feedback.contains("患者音羽 響子的状态暂时平稳"), "Surgery completion description or extra duration wrong")
	expect(prep.postoperative_state_text() == "暂时平稳", "Postoperative placeholder state wrong")
	var legacy_wrong_save: Dictionary = game.snapshot().duplicate(true)
	legacy_wrong_save.version = 15
	var legacy_wrong_events: Array = legacy_wrong_save.preops.preop_sora
	var legacy_wrong_index := -1
	for index in legacy_wrong_events.size():
		var legacy_event: Variant = legacy_wrong_events[index]
		if legacy_event is Dictionary and legacy_event.get("kind") == "surgery_step" and legacy_event.get("id") == wrong_decision.id:
			legacy_wrong_index = index
			break
	expect(legacy_wrong_index >= 0 and legacy_wrong_index + 3 < legacy_wrong_events.size(), "Could not construct v15 wrong-choice migration fixture")
	if legacy_wrong_index >= 0 and legacy_wrong_index + 3 < legacy_wrong_events.size():
		# v15 advanced after the wrong choice, so remove the explicit retry recorded
		# by the current behavior before asking restore to migrate it back in.
		legacy_wrong_events.remove_at(legacy_wrong_index + 2)
		legacy_wrong_events.remove_at(legacy_wrong_index + 2)
	var migrated_wrong_game = new_game()
	expect(not migrated_wrong_game.restore(legacy_wrong_save), "Retired v15 wrong-choice save was accepted")
	var authored_patient_queue: Array[String] = ["patient_sora"]
	for patient in content.collections.patients:
		if str(patient.id) != "patient_sora":
			authored_patient_queue.append(str(patient.id))
	game.patient_queue.assign(authored_patient_queue)
	check_roundtrip(game)
	var before: Dictionary = game.snapshot()
	var bad: Dictionary = before.duplicate(true)
	bad.preops.preop_sora.append({"kind": "action", "id": "enter_room"})
	expect(not game.restore(bad) and game.snapshot() == before, "Invalid preop replay mutated live progress")
	bad = before.duplicate(true)
	bad.progress.visit_sora = []
	expect(not game.restore(bad) and game.snapshot() == before, "Preop without admission accepted")
	var rotation = new_game()
	expect(rotation.restore(JSON.parse_string(JSON.stringify(game.snapshot()))), "Completed surgery could not seed rotation test")
	expect(rotation.completed_patient("patient_sora") and not rotation.admitted_patient("patient_sora"), "Completed patient remained admitted")
	expect(rotation.current_patient_id() == "patient_emi", "Patient queue did not advance to second patient")
	expect(rotation.finish_active_surgery(), "Completed surgery could not be settled")
	expect(rotation.surgery_xp > 0 and rotation.surgery_xp_history.size() == 1, "Settled surgery did not award duration- and difficulty-based XP")
	var second_patient: String = rotation.current_patient_id()
	var second_visit_id: String = rotation.encounter_id_for_patient(second_patient)
	expect(second_patient != "patient_sora" and rotation.recent_patient_ids == ["patient_sora"], "Settling surgery repeated the most recent patient")
	expect(rotation.active_preop_id.is_empty() and rotation.active_mode == "encounter" and rotation.active_id == second_visit_id, "Settling surgery did not activate the selected encounter")
	expect(rotation.visits.has(second_visit_id) and rotation.visits[second_visit_id].action_log.is_empty(), "Next encounter was not initialized cleanly")
	var emi_visit = rotation.visits[second_visit_id]
	for action in CLINIC:
		expect(emi_visit.apply(action), "Second patient route failed at " + action)
	expect(emi_visit.admitted and rotation.admitted_patient(second_patient), "Second patient could not be admitted")
	var emi_prep = rotation.open_preop(preop_id_for_patient(rotation, second_patient))
	expect(emi_prep != null, "Second patient preop route missing")
	check_roundtrip(rotation)
	emi_prep.surgery_success = true
	expect(rotation.finish_active_surgery(), "Second completed surgery could not be settled")
	var third_patient: String = rotation.current_patient_id()
	var third_visit_id: String = rotation.encounter_id_for_patient(third_patient)
	expect(third_patient != "patient_sora" and third_patient != second_patient and rotation.active_id == third_visit_id, "Patient queue repeated one of the previous two patients")
	expect(rotation.visits.has(third_visit_id) and rotation.visits[third_visit_id].action_log.is_empty(), "Third encounter did not initialize cleanly")
	var ann_visit = rotation.visits[third_visit_id]
	for action in CLINIC:
		expect(ann_visit.apply(action), "Third patient route failed at " + action)
	var ann_prep = rotation.open_preop(preop_id_for_patient(rotation, third_patient))
	expect(ann_prep != null, "Third patient preop route missing")
	ann_prep.surgery_success = true
	expect(rotation.finish_active_surgery(), "Third completed surgery could not be settled")
	expect(rotation.current_patient_id() != second_patient and rotation.current_patient_id() != third_patient, "Fourth selection repeated one of the previous two patients")
	# All 12 unique teams can complete required preparation without optional tasks.
	for doctor in ["doc_aoi", "doc_rei"]:
		for scrub in ["nurse_haru", "nurse_rin", "nurse_yui"]:
			for circulating in ["nurse_haru", "nurse_rin", "nurse_yui"]:
				if circulating == scrub:
					continue
				var branch = admitted_game()
				var scenario = branch.open_preop("preop_sora")
				act(scenario, "brief_plan")
				assign(scenario, "assistant_surgeon", doctor)
				assign(scenario, "scrub_nurse", scrub)
				assign(scenario, "circulating_nurse", circulating)
				act(scenario, "confirm_team")
				var ward := ""
				for nurse in ["nurse_haru", "nurse_rin", "nurse_yui"]:
					if nurse != scrub and nurse != circulating:
						ward = nurse
				assign(scenario, "ward_nurse", ward)
				expect(act(scenario, "perform_preparation"), "Valid team cannot prepare patient")
				var ward_profile: Dictionary = content.find_record("staff", ward)
				var expected_anxiety := 1 if int(ward_profile.get("skills", {}).get("patient_care", 0)) >= int(scenario.definition.care_reassurance_threshold) else 2
				expect(scenario.anxiety == expected_anxiety, "Nurse care threshold was not applied")
				for action in ["to_changing", "change_scrubs", "scrub_hands", "enter_room", "team_check", "confirm_assistant_role", "confirm_scrub_role", "confirm_circulating_role"]:
					expect(act(scenario, action), "Valid branch deadlocked at " + action)
				check_roundtrip(branch)
	var args := OS.get_cmdline_user_args()
	if args.size() == 1:
		var store = Store.new()
		store.path = args[0]
		expect(store.write_slot(game), "Preop save file write failed")
		var loaded = new_game()
		expect(store.read_slot(loaded) and loaded.active_mode == "preop" and loaded.preops.preop_sora.stage_id == "surgery_result", "Preop file load failed")
		expect(loaded.preops.preop_sora.operative_background_id == game.preops.preop_sora.operative_background_id, "Operative background changed after file load")
	else:
		expect(false, "Pass scratch save path after --")
	# UI controls: assignments, choices and all stage art are instantiated in sequence.
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var pelvic_overlay_prep = Preop.new(condition_definition, content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions)
	pelvic_overlay_prep.procedure_id = "surgery_hysterectomy"
	pelvic_overlay_prep.procedure_name = "开腹子宫全切除"
	pelvic_overlay_prep.procedure_step_index = 0
	pelvic_overlay_prep.stage_id = "procedure_flow"
	pelvic_overlay_prep.operative_background_id = "operating_team_01"
	pelvic_overlay_prep.flags.append("incision_made")
	expect(PreopView.operative_field_overlay_visible(pelvic_overlay_prep, pelvic_overlay_prep.current(), pelvic_overlay_prep.surgery_flow_step()), "Pelvic operative-field overlay condition did not activate after incision")
	PreopView.render(app, pelvic_overlay_prep)
	var pelvic_overlay := app.page.get_node_or_null("OperativeFieldOverlay") as TextureRect
	var pelvic_team_background := app.page.get_node_or_null("SceneBackground") as TextureRect
	var pelvic_patient_portrait := app.page.get_node_or_null("IntraoperativePatientPortrait") as TextureRect
	var pelvic_overlay_paths := [
		"res://assets/surgeries/overlays/pelvic/open_pelvic_field.png",
		"res://assets/surgeries/overlays/pelvic/open_pelvic_field_02.png",
	]
	expect(pelvic_overlay != null and pelvic_overlay.texture.resource_path in pelvic_overlay_paths, "Pelvic operative-field overlay did not select an image from the configured pool")
	var first_overlay_path := pelvic_overlay.texture.resource_path if pelvic_overlay != null else ""
	PreopView.render(app, pelvic_overlay_prep)
	pelvic_overlay = app.page.get_node_or_null("OperativeFieldOverlay") as TextureRect
	pelvic_team_background = app.page.get_node_or_null("SceneBackground") as TextureRect
	pelvic_patient_portrait = app.page.get_node_or_null("IntraoperativePatientPortrait") as TextureRect
	expect(pelvic_overlay != null and pelvic_overlay.texture.resource_path == first_overlay_path, "Pelvic operative-field overlay changed during the same operation")
	app.operative_field_hud_enabled = true
	PreopView.render(app, pelvic_overlay_prep)
	var pelvic_hud := app.page.get_node_or_null("OperativeFieldHUD") as TextureRect
	var pelvic_hud_frame := app.page.get_node_or_null("OperativeFieldHUDFrame") as Control
	expect(app.page.get_node_or_null("OperativeFieldOverlay") == null, "HUD mode retained the full-screen operative-field overlay")
	expect(pelvic_hud != null and pelvic_hud.texture.resource_path == first_overlay_path, "HUD mode did not reuse the operation's stable field image")
	expect(pelvic_hud_frame != null and pelvic_hud_frame.position.x >= 850 and pelvic_hud_frame.position.y < 200, "Operative-field HUD is not anchored in the upper-right rail")
	app.operative_field_hud_enabled = false
	PreopView.render(app, pelvic_overlay_prep)
	pelvic_overlay = app.page.get_node_or_null("OperativeFieldOverlay") as TextureRect
	pelvic_team_background = app.page.get_node_or_null("SceneBackground") as TextureRect
	pelvic_patient_portrait = app.page.get_node_or_null("IntraoperativePatientPortrait") as TextureRect
	var selected_pelvic_paths: Array[String] = []
	for background_id in OperativeBackgrounds.IDS:
		pelvic_overlay_prep.operative_background_id = background_id
		var selected_path := PreopView.operative_field_overlay_path(pelvic_overlay_prep)
		if not selected_pelvic_paths.has(selected_path):
			selected_pelvic_paths.append(selected_path)
	expect(selected_pelvic_paths.size() == pelvic_overlay_paths.size(), "Random operative backgrounds do not reach every pelvic operative-field image")
	expect(pelvic_team_background != null and pelvic_overlay != null and pelvic_team_background.get_index() < pelvic_overlay.get_index(), "Pelvic operative-field overlay is not above the operative-team CG")
	expect(pelvic_patient_portrait == null or (pelvic_overlay != null and pelvic_overlay.get_index() < pelvic_patient_portrait.get_index()), "Pelvic operative-field overlay covered the patient portrait")
	pelvic_overlay_prep.procedure_step_index = pelvic_overlay_prep.surgery_flow_steps().size() - 1
	app.operative_field_hud_enabled = true
	PreopView.render(app, pelvic_overlay_prep)
	expect(app.page.get_node_or_null("OperativeFieldOverlay") == null, "Pelvic operative-field overlay remained during closure")
	expect(app.page.get_node_or_null("OperativeFieldHUD") == null, "Pelvic operative-field HUD remained during closure")
	app.operative_field_hud_enabled = false
	pelvic_overlay_prep.procedure_id = "surgery_appendix"
	pelvic_overlay_prep.procedure_step_index = 0
	var appendix_overlay_paths := [
		"res://assets/surgeries/overlays/appendix/open_appendix_field_01.png",
		"res://assets/surgeries/overlays/appendix/open_appendix_field_02.png",
	]
	expect(PreopView.operative_field_overlay_visible(pelvic_overlay_prep, pelvic_overlay_prep.current(), pelvic_overlay_prep.surgery_flow_step()), "Appendix operative-field overlay condition did not activate after incision")
	var selected_appendix_paths: Array[String] = []
	for background_id in OperativeBackgrounds.IDS:
		pelvic_overlay_prep.operative_background_id = background_id
		var selected_path := PreopView.operative_field_overlay_path(pelvic_overlay_prep)
		if not selected_appendix_paths.has(selected_path):
			selected_appendix_paths.append(selected_path)
	expect(selected_appendix_paths.size() == appendix_overlay_paths.size() and selected_appendix_paths.all(func(path: String): return path in appendix_overlay_paths), "Appendix operative backgrounds do not reach both configured field images")
	PreopView.render(app, pelvic_overlay_prep)
	var appendix_overlay := app.page.get_node_or_null("OperativeFieldOverlay") as TextureRect
	expect(appendix_overlay != null and appendix_overlay.texture.resource_path in appendix_overlay_paths, "Appendix operative-field overlay did not appear after incision")
	pelvic_overlay_prep.procedure_step_index = pelvic_overlay_prep.surgery_flow_steps().size() - 1
	PreopView.render(app, pelvic_overlay_prep)
	expect(app.page.get_node_or_null("OperativeFieldOverlay") == null, "Appendix operative-field overlay remained during closure")
	pelvic_overlay_prep.procedure_id = "surgery_open_cholecystectomy"
	pelvic_overlay_prep.procedure_step_index = 0
	var abdominal_overlay_paths := [
		"res://assets/surgeries/overlays/abdominal/open_abdominal_field_01.png",
		"res://assets/surgeries/overlays/abdominal/open_abdominal_field_02.png",
	]
	expect(PreopView.operative_field_overlay_visible(pelvic_overlay_prep, pelvic_overlay_prep.current(), pelvic_overlay_prep.surgery_flow_step()), "General abdominal operative-field overlay did not activate after incision")
	var selected_abdominal_paths: Array[String] = []
	for background_id in OperativeBackgrounds.IDS:
		pelvic_overlay_prep.operative_background_id = background_id
		var selected_path := PreopView.operative_field_overlay_path(pelvic_overlay_prep)
		if not selected_abdominal_paths.has(selected_path):
			selected_abdominal_paths.append(selected_path)
	expect(selected_abdominal_paths.size() == abdominal_overlay_paths.size() and selected_abdominal_paths.all(func(path: String): return path in abdominal_overlay_paths), "General abdominal operative backgrounds do not reach both configured field images")
	PreopView.render(app, pelvic_overlay_prep)
	var abdominal_overlay := app.page.get_node_or_null("OperativeFieldOverlay") as TextureRect
	expect(abdominal_overlay != null and abdominal_overlay.texture.resource_path in abdominal_overlay_paths, "General abdominal operative-field overlay did not appear after incision")
	pelvic_overlay_prep.procedure_step_index = pelvic_overlay_prep.surgery_flow_steps().size() - 1
	PreopView.render(app, pelvic_overlay_prep)
	expect(app.page.get_node_or_null("OperativeFieldOverlay") == null, "General abdominal operative-field overlay remained during closure")
	var breast_overlay_paths := [
		"res://assets/surgeries/overlays/breast/open_breast_field_01.png",
		"res://assets/surgeries/overlays/breast/open_breast_field_02.png",
		"res://assets/surgeries/overlays/breast/open_breast_field_03.png",
	]
	pelvic_overlay_prep.procedure_id = "surgery_total_mastectomy"
	pelvic_overlay_prep.procedure_step_index = 0
	expect(PreopView.operative_field_overlay_visible(pelvic_overlay_prep, pelvic_overlay_prep.current(), pelvic_overlay_prep.surgery_flow_step()), "Breast operative-field overlay did not activate after incision")
	var selected_breast_paths: Array[String] = []
	for background_id in OperativeBackgrounds.IDS:
		pelvic_overlay_prep.operative_background_id = background_id
		var selected_path := PreopView.operative_field_overlay_path(pelvic_overlay_prep)
		if not selected_breast_paths.has(selected_path):
			selected_breast_paths.append(selected_path)
	expect(selected_breast_paths.size() == breast_overlay_paths.size() and selected_breast_paths.all(func(path: String): return path in breast_overlay_paths), "Breast operative backgrounds do not reach all three configured field images")
	PreopView.render(app, pelvic_overlay_prep)
	var breast_overlay := app.page.get_node_or_null("OperativeFieldOverlay") as TextureRect
	expect(breast_overlay != null and breast_overlay.texture.resource_path in breast_overlay_paths, "Breast operative-field overlay did not appear after incision")
	pelvic_overlay_prep.procedure_step_index = pelvic_overlay_prep.surgery_flow_steps().size() - 1
	PreopView.render(app, pelvic_overlay_prep)
	expect(app.page.get_node_or_null("OperativeFieldOverlay") == null, "Breast operative-field overlay remained during closure")
	var thoracic_overlay_paths := [
		"res://assets/surgeries/overlays/thoracic/open_thoracic_field_01.png",
		"res://assets/surgeries/overlays/thoracic/open_thoracic_field_02.png",
	]
	pelvic_overlay_prep.procedure_id = "surgery_cabg"
	pelvic_overlay_prep.procedure_step_index = 0
	expect(PreopView.operative_field_overlay_visible(pelvic_overlay_prep, pelvic_overlay_prep.current(), pelvic_overlay_prep.surgery_flow_step()), "Cardiac operative-field overlay did not activate after incision")
	var selected_cardiac_paths: Array[String] = []
	for background_id in OperativeBackgrounds.IDS:
		pelvic_overlay_prep.operative_background_id = background_id
		var selected_path := PreopView.operative_field_overlay_path(pelvic_overlay_prep)
		if not selected_cardiac_paths.has(selected_path):
			selected_cardiac_paths.append(selected_path)
	expect(selected_cardiac_paths.size() == thoracic_overlay_paths.size() and selected_cardiac_paths.all(func(path: String): return path in thoracic_overlay_paths), "Cardiac operative backgrounds do not reach both configured thoracic-field images")
	PreopView.render(app, pelvic_overlay_prep)
	var cardiac_overlay := app.page.get_node_or_null("OperativeFieldOverlay") as TextureRect
	expect(cardiac_overlay != null and cardiac_overlay.texture.resource_path in thoracic_overlay_paths, "Cardiac operative-field overlay did not appear after incision")
	pelvic_overlay_prep.procedure_step_index = pelvic_overlay_prep.surgery_flow_steps().size() - 1
	PreopView.render(app, pelvic_overlay_prep)
	expect(app.page.get_node_or_null("OperativeFieldOverlay") == null, "Cardiac operative-field overlay remained during closure")
	pelvic_overlay_prep.procedure_id = "surgery_open_lung_lobectomy"
	pelvic_overlay_prep.procedure_step_index = 0
	expect(PreopView.operative_field_overlay_visible(pelvic_overlay_prep, pelvic_overlay_prep.current(), pelvic_overlay_prep.surgery_flow_step()), "Thoracic operative-field overlay did not activate after incision")
	var selected_thoracic_paths: Array[String] = []
	for background_id in OperativeBackgrounds.IDS:
		pelvic_overlay_prep.operative_background_id = background_id
		var selected_path := PreopView.operative_field_overlay_path(pelvic_overlay_prep)
		if not selected_thoracic_paths.has(selected_path):
			selected_thoracic_paths.append(selected_path)
	expect(selected_thoracic_paths.size() == thoracic_overlay_paths.size() and selected_thoracic_paths.all(func(path: String): return path in thoracic_overlay_paths), "Thoracic operative backgrounds do not reach both configured field images")
	# A timed patient-condition response may cross the end of the shift while
	# the operation is still active. It must keep the patient in the operating
	# room and defer the day transition until the surgery result is settled.
	var overtime_app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(overtime_app)
	await process_frame
	var overtime_visit = overtime_app.game.open_visit("visit_sora")
	for action in CLINIC:
		overtime_visit.apply(action)
	var overtime_prep = overtime_app.game.open_preop("preop_sora")
	overtime_prep.procedure_id = "surgery_open_abdominal_myomectomy"
	overtime_prep.procedure_name = "开腹子宫肌瘤剔除术"
	overtime_prep.procedure_step_index = 2
	overtime_prep.stage_id = "procedure_flow"
	overtime_prep.pending_flow_stage_id = "procedure_flow"
	overtime_prep.team = {"assistant_surgeon": "doc_aoi", "circulating_nurse": "nurse_haru", "scrub_nurse": "nurse_yui"}
	overtime_prep.flags.append("surgery_started")
	expect(overtime_prep.resolve_patient_event_for_stage() and overtime_prep.active_condition_id == "drowsiness", "Overtime regression fixture did not create drowsiness")
	overtime_app.game.story_time_advance_minutes += 479 - overtime_app.game.elapsed()
	overtime_app.show_preop("preop_sora")
	overtime_app.preop_event({"kind": "patient_interaction_action", "id": "delegate_drowsiness_circulating"})
	await process_frame
	expect(overtime_app.screen == "preop", "Timed intraoperative event ended the day before surgery completion")
	expect(overtime_app.game.active_surgery_in_progress() and overtime_app.game.pending_surgery_day_transition, "Timed intraoperative event did not preserve surgery and defer the crossed-day transition")
	var saw_overtime_day_transition := false
	for node in overtime_app.page.get_children():
		if node is Button and node.text.contains("进入下一天"):
			saw_overtime_day_transition = true
	expect(not saw_overtime_day_transition, "Day-transition control appeared while the patient was still on the operating table")
	overtime_app.queue_free()
	await process_frame
	var epidural_app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(epidural_app)
	await process_frame
	epidural_app.game.patient_cases = epidural_app.game.legacy_patient_cases()
	epidural_app.game.rebuild_patient_content(epidural_app.game.patient_cases)
	var epidural_visit = epidural_app.game.open_visit("visit_emi")
	epidural_visit.admitted = true
	var epidural_prep = epidural_app.game.open_preop("preop_emi")
	epidural_prep.procedure_id = "surgery_open_abdominal_myomectomy"
	epidural_prep.stage_id = "ready"
	epidural_app.show_preop("preop_emi")
	epidural_app.preop_event({"kind": "action", "id": "choose_epidural"})
	await process_frame
	var epidural_overlay = epidural_app.page.get_node_or_null("EpiduralAnesthesiaSplash")
	var epidural_cg = epidural_app.page.find_child("EpiduralAnesthesiaSplashCG", true, false)
	expect(epidural_prep.stage_id == "anesthesia_sensory_test" and epidural_overlay != null, "Emi's epidural choice did not show its dedicated splash before sensory testing")
	expect(epidural_cg != null and epidural_cg.texture.resource_path.ends_with("/anesthesia_v1/patient_emi/epidural.png"), "Emi's epidural splash used the wrong patient art")
	var epidural_continue: Button = epidural_app.page.find_child("AnesthesiaSplashContinue", true, false)
	expect(epidural_continue != null and epidural_continue.text.contains("继续准备"), "Epidural splash omitted its continuation control")
	if epidural_continue != null:
		epidural_continue.pressed.emit()
	await process_frame
	expect(epidural_app.page.get_node_or_null("EpiduralAnesthesiaSplash") == null, "Epidural splash did not close")
	expect(epidural_app.page.get_node_or_null("AnesthesiaTestComplete") != null, "Epidural splash did not reveal the optional sensory-test HUD")
	epidural_prep.procedure_id = "surgery_open_abdominal_myomectomy"
	epidural_prep.stage_id = "skin_disinfection_response"
	if not epidural_prep.flags.has("skin_disinfected"):
		epidural_prep.flags.append("skin_disinfected")
	epidural_app.show_preop("preop_emi")
	epidural_app.preop_event({"kind": "action", "id": "ack_disinfection"})
	await process_frame
	var draping_cg: TextureRect = epidural_app.page.get_node_or_null("WardPreparationCG")
	expect(epidural_app.screen == "ward_preparation_cg" and draping_cg != null and draping_cg.texture.resource_path.ends_with("/patient_emi/sterile_draping.png"), "Emi's awake abdominal route did not show the sterile-draping CG after disinfection")
	var draping_continue: Button = epidural_app.page.get_node_or_null("WardPreparationCGContinue")
	expect(draping_continue != null, "Sterile-draping CG omitted its continue control")
	if draping_continue != null:
		draping_continue.pressed.emit()
	await process_frame
	expect(epidural_prep.stage_id == "incision_marking" and epidural_app.screen == "preop", "Sterile-draping CG did not continue directly to incision marking")
	epidural_app.queue_free()
	await process_frame
	var breast_pool: Dictionary = app.surgery_cg_pool_for("surgery_breast_tumor", "patient_emi")
	expect(breast_pool.get("id", "") == "breast_progress_generic" and breast_pool.paths.size() == 13, "Breast surgery CG pool did not resolve")
	var thoracic_pool: Dictionary = app.surgery_cg_pool_for("surgery_open_lung_lobectomy", "patient_emi")
	expect(thoracic_pool.get("id", "") == "thoracic_progress_generic" and thoracic_pool.paths.size() == 24, "Thoracic surgery CG pool did not resolve")
	expect(app.surgery_cg_pool_for("surgery_open_pneumonectomy", "patient_emi").get("id", "") == "thoracic_progress_generic", "Pneumonectomy did not resolve the thoracic CG pool")
	expect(app.surgery_cg_pool_for("surgery_open_esophagectomy", "patient_emi").get("id", "") == "thoracic_progress_generic", "Esophagectomy did not resolve the thoracic CG pool")
	var cardiac_pool: Dictionary = app.surgery_cg_pool_for("surgery_cabg", "patient_emi")
	expect(cardiac_pool.get("id", "") == "cardiac_progress_generic" and cardiac_pool.paths.size() == 25, "CABG surgery CG pool did not resolve")
	var abdominal_pool: Dictionary = app.surgery_cg_pool_for("surgery_appendix", "patient_sora")
	expect(abdominal_pool.get("id", "") == "abdominal_progress_generic" and abdominal_pool.paths.size() == 31, "Abdominal surgery CG pool did not resolve")
	expect(app.surgery_cg_pool_for("surgery_open_radical_cystectomy", "patient_miki").get("id", "") == "abdominal_progress_generic", "Cystectomy did not resolve the abdominal CG pool")
	expect(app.surgery_cg_pool_for("surgery_open_nephrectomy", "patient_ann").get("id", "") == "abdominal_progress_generic", "Nephrectomy did not resolve the abdominal CG pool")
	expect(app.surgery_cg_pool_for("surgery_open_abdominal_aortic_aneurysm", "patient_emi").get("id", "") == "abdominal_progress_generic", "AAA repair did not resolve the abdominal CG pool")
	var pelvic_pool: Dictionary = app.surgery_cg_pool_for("surgery_hysterectomy", "patient_sora")
	expect(pelvic_pool.get("id", "") == "pelvic_progress_generic" and pelvic_pool.paths.size() == 21, "Pelvic surgery CG pool did not resolve")
	expect(app.surgery_cg_pool_for("surgery_open_abdominoperineal_resection", "patient_emi").get("id", "") == "pelvic_progress_generic", "Abdominoperineal resection did not resolve the pelvic CG pool")
	expect(app.surgery_cg_pool_for("surgery_open_ovarian_cystectomy", "patient_ann").get("id", "") == "pelvic_progress_generic", "Ovarian cystectomy did not resolve the pelvic CG pool")
	expect(app.surgery_cg_pool_for("surgery_open_abdominal_myomectomy", "patient_miki").get("id", "") == "pelvic_progress_generic", "Myomectomy did not resolve the pelvic CG pool")
	var enema_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("ward_enema", "patient_sora")
	expect(enema_cg_pool.get("id", "") == "ward_enema_generic" and enema_cg_pool.paths.size() == 2 and enema_cg_pool.presentation == "splash", "Enema splash CG pool did not resolve")
	var ann_enema_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("ward_enema", "patient_ann")
	expect(ann_enema_cg_pool.get("id", "") == "ward_enema_patient_ann" and ann_enema_cg_pool.paths.size() == 1 and ann_enema_cg_pool.presentation == "fullscreen", "Ann-specific enema fullscreen CG pool did not override the generic pool")
	expect(app.ward_preparation_cg_pool_for("ward_enema_unnecessary", "patient_ann").get("id", "") == "ward_enema_patient_ann", "Ann's unnecessary enema did not resolve the patient-specific CG pool")
	var ann_disinfection_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("skin_disinfection", "patient_ann")
	expect(ann_disinfection_cg_pool.get("id", "") == "skin_disinfection_patient_ann" and ann_disinfection_cg_pool.paths.size() == 1 and ann_disinfection_cg_pool.presentation == "fullscreen", "Ann-specific skin-disinfection fullscreen CG pool did not resolve")
	expect(app.ward_preparation_cg_pool_for("skin_disinfection", "patient_miki").is_empty(), "Ann-specific skin-disinfection CG leaked to another patient")
	for procedure_group in ["general_abdominal", "female_pelvic", "vascular"]:
		expect(app.ward_preparation_cg_pool_for("ack_disinfection", "patient_emi", procedure_group).get("id", "") == "sterile_draping_patient_emi", "Emi's sterile-draping CG did not resolve for " + procedure_group)
	for procedure_group in ["breast", "urologic", "thoracic", "cardiac"]:
		expect(app.ward_preparation_cg_pool_for("ack_disinfection", "patient_emi", procedure_group).is_empty(), "Emi's abdominal sterile-draping CG leaked to " + procedure_group)
	expect(app.ward_preparation_cg_pool_for("ack_disinfection", "patient_sora", "general_abdominal").is_empty(), "Emi's sterile-draping CG leaked to another patient")
	var ann_scalpel_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("request_scalpel", "patient_ann")
	expect(ann_scalpel_cg_pool.get("id", "") == "scalpel_ready_patient_ann" and ann_scalpel_cg_pool.paths.size() == 1 and ann_scalpel_cg_pool.presentation == "fullscreen", "Ann-specific scalpel-ready fullscreen CG pool did not resolve")
	expect(app.ward_preparation_cg_pool_for("request_scalpel", "patient_gigi").is_empty(), "Ann-specific scalpel-ready CG leaked to an unconfigured patient")
	var emi_scalpel_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("request_scalpel", "patient_emi")
	expect(emi_scalpel_cg_pool.get("id", "") == "scalpel_ready_patient_emi" and emi_scalpel_cg_pool.paths.size() == 1 and emi_scalpel_cg_pool.presentation == "fullscreen", "Emi-specific scalpel-ready fullscreen CG pool did not resolve")
	var sora_scalpel_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("request_scalpel", "patient_sora")
	expect(sora_scalpel_cg_pool.get("id", "") == "scalpel_ready_patient_sora" and sora_scalpel_cg_pool.paths.size() == 1 and sora_scalpel_cg_pool.presentation == "fullscreen", "Sora-specific scalpel-ready fullscreen CG pool did not resolve")
	var miki_scalpel_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("request_scalpel", "patient_miki")
	expect(miki_scalpel_cg_pool.get("id", "") == "scalpel_ready_patient_miki" and miki_scalpel_cg_pool.paths.size() == 1 and miki_scalpel_cg_pool.presentation == "fullscreen", "Miki-specific scalpel-ready fullscreen CG pool did not resolve")
	var rie_scalpel_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("request_scalpel", "patient_rie")
	expect(rie_scalpel_cg_pool.get("id", "") == "scalpel_ready_patient_rie" and rie_scalpel_cg_pool.paths.size() == 1 and rie_scalpel_cg_pool.presentation == "fullscreen", "Rie-specific scalpel-ready fullscreen CG pool did not resolve")
	var rie_skin_prep_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("ward_skin_prep", "patient_rie")
	expect(rie_skin_prep_cg_pool.get("id", "") == "ward_skin_prep_patient_rie" and rie_skin_prep_cg_pool.paths.size() == 1 and rie_skin_prep_cg_pool.presentation == "fullscreen", "Rie-specific skin-prep fullscreen CG pool did not override the generic pool")
	expect(app.ward_preparation_cg_pool_for("ward_skin_prep_unnecessary", "patient_rie").get("id", "") == "ward_skin_prep_patient_rie", "Rie's unnecessary skin prep did not resolve the patient-specific CG pool")
	for procedure_group in ["general_abdominal", "female_pelvic", "vascular"]:
		expect(app.ward_preparation_cg_pool_for("ack_disinfection", "patient_rie", procedure_group).get("id", "") == "sterile_draping_patient_rie", "Rie's sterile-draping CG did not resolve for " + procedure_group)
	for procedure_group in ["breast", "urologic", "thoracic", "cardiac"]:
		expect(app.ward_preparation_cg_pool_for("ack_disinfection", "patient_rie", procedure_group).is_empty(), "Rie's abdominal sterile-draping CG leaked to " + procedure_group)
	var miki_enema_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("ward_enema", "patient_miki")
	expect(miki_enema_cg_pool.get("id", "") == "ward_enema_patient_miki" and miki_enema_cg_pool.paths.size() == 1 and miki_enema_cg_pool.presentation == "fullscreen", "Miki-specific enema fullscreen CG pool did not override the generic pool")
	expect(app.ward_preparation_cg_pool_for("ward_enema_unnecessary", "patient_miki").get("id", "") == "ward_enema_patient_miki", "Miki's unnecessary enema did not resolve the patient-specific CG pool")
	var gigi_enema_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("ward_enema", "patient_gigi")
	expect(gigi_enema_cg_pool.get("id", "") == "ward_enema_patient_gigi" and gigi_enema_cg_pool.paths.size() == 1 and gigi_enema_cg_pool.presentation == "fullscreen", "Gigi-specific enema fullscreen CG pool did not override the generic pool")
	expect(app.ward_preparation_cg_pool_for("ward_enema_unnecessary", "patient_gigi").get("id", "") == "ward_enema_patient_gigi", "Gigi's unnecessary enema did not resolve the patient-specific CG pool")
	var emi_enema_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("ward_enema", "patient_emi")
	expect(emi_enema_cg_pool.get("id", "") == "ward_enema_patient_emi" and emi_enema_cg_pool.paths.size() == 1 and emi_enema_cg_pool.presentation == "fullscreen", "Emi-specific enema fullscreen CG pool did not override the generic pool")
	expect(app.ward_preparation_cg_pool_for("ward_enema_unnecessary", "patient_emi").get("id", "") == "ward_enema_patient_emi", "Emi's unnecessary enema did not resolve the patient-specific CG pool")
	var miki_catheter_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("urinary_catheterization", "patient_miki")
	expect(miki_catheter_cg_pool.get("id", "") == "urinary_catheterization_patient_miki" and miki_catheter_cg_pool.paths.size() == 1 and miki_catheter_cg_pool.presentation == "fullscreen", "Miki-specific catheterization fullscreen CG pool did not resolve")
	expect(app.ward_preparation_cg_pool_for("urinary_catheterization", "patient_ann").is_empty(), "Miki-specific catheterization CG leaked to another patient")
	var rie_catheter_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("urinary_catheterization", "patient_rie")
	expect(rie_catheter_cg_pool.get("id", "") == "urinary_catheterization_patient_rie" and rie_catheter_cg_pool.paths.size() == 1 and rie_catheter_cg_pool.presentation == "fullscreen", "Rie-specific catheterization fullscreen CG pool did not resolve")
	var rie_disinfection_cg_pool: Dictionary = app.ward_preparation_cg_pool_for("skin_disinfection", "patient_rie")
	expect(rie_disinfection_cg_pool.get("id", "") == "skin_disinfection_patient_rie" and rie_disinfection_cg_pool.paths.size() == 1 and rie_disinfection_cg_pool.presentation == "fullscreen", "Rie-specific skin-disinfection fullscreen CG pool did not resolve")
	expect(app.ward_preparation_cg_pool_for("skin_disinfection", "patient_miki").is_empty(), "Rie's skin-disinfection CG leaked to another patient")
	expect(app.ward_preparation_cg_pool_for("ward_skin_prep", "patient_sora").get("id", "") == "ward_skin_prep_generic", "Skin-prep splash CG pool did not resolve")
	expect(app.ward_preparation_cg_pool_for("ward_skin_prep_unnecessary", "patient_emi").get("id", "") == "ward_skin_prep_patient_emi", "Emi's unnecessary skin prep did not use her dedicated skin-prep CG")
	expect(app.ward_preparation_cg_pool_for("ward_change_gown", "patient_sora").is_empty(), "Removed gown-change action still resolved a CG pool")
	expect(app.ward_preparation_cg_pool_for("ward_surgical_cap", "patient_sora").get("id", "") == "ward_surgical_cap_generic", "Surgical-cap splash CG pool did not resolve")
	expect(app.ward_preparation_cg_pool_for("skip_required_ward_enema", "patient_sora").is_empty(), "Skipped enema incorrectly triggered a splash CG")
	var first_ward_path: String = app.ward_preparation_cg_path(enema_cg_pool)
	var second_ward_path: String = app.ward_preparation_cg_path(enema_cg_pool)
	expect(not first_ward_path.is_empty() and not second_ward_path.is_empty() and first_ward_path != second_ward_path, "Ward preparation CG repeated immediately")
	app.show_map()
	app.show_ward_preparation_splash(enema_cg_pool)
	var ward_splash = app.page.get_node_or_null("WardPreparationSplash")
	var ward_splash_cg = app.page.find_child("WardPreparationSplashCG", true, false)
	expect(ward_splash != null and ward_splash_cg != null and ward_splash_cg.texture != null, "Ward preparation splash did not open or load")
	var ward_splash_continue: Button = app.page.find_child("WardPreparationSplashContinue", true, false)
	expect(ward_splash_continue != null, "Ward preparation splash omitted its continue button")
	if ward_splash_continue != null:
		ward_splash_continue.pressed.emit()
	await process_frame
	expect(app.page.get_node_or_null("WardPreparationSplash") == null, "Ward preparation splash did not close")
	app.show_ward_preparation_fullscreen(ann_enema_cg_pool, app.show_map)
	var ann_enema_cg: TextureRect = app.page.get_node_or_null("WardPreparationCG")
	expect(app.screen == "ward_preparation_cg" and ann_enema_cg != null and ann_enema_cg.texture != null, "Ann-specific enema fullscreen CG did not open or load")
	var ann_enema_continue: Button = app.page.get_node_or_null("WardPreparationCGContinue")
	expect(ann_enema_continue != null, "Ann-specific enema fullscreen CG omitted its continue button")
	if ann_enema_continue != null:
		ann_enema_continue.pressed.emit()
	await process_frame
	expect(app.screen == "map", "Ann-specific enema fullscreen CG did not continue to the requested view")
	app.show_surgery_cg(breast_pool, app.show_map)
	var first_cg: TextureRect = app.page.get_node_or_null("SurgeryCG")
	expect(app.screen == "surgery_cg" and first_cg != null and first_cg.texture != null, "Surgery CG did not open or load")
	var first_path := first_cg.texture.resource_path if first_cg != null and first_cg.texture != null else ""
	var first_continue: Button = app.page.get_node_or_null("SurgeryCGContinue")
	expect(first_continue != null, "Surgery CG continue button missing")
	if first_continue != null:
		first_continue.pressed.emit()
	app.show_surgery_cg(breast_pool, app.show_map)
	var second_cg: TextureRect = app.page.get_node_or_null("SurgeryCG")
	var second_path := second_cg.texture.resource_path if second_cg != null and second_cg.texture != null else ""
	expect(not first_path.is_empty() and not second_path.is_empty() and first_path != second_path, "Surgery CG repeated immediately")
	var second_continue: Button = app.page.get_node_or_null("SurgeryCGContinue")
	if second_continue != null:
		second_continue.pressed.emit()
	app.game.reset()
	app.game.patient_cases = app.game.legacy_patient_cases()
	app.game.rebuild_patient_content(app.game.patient_cases)
	app.game.intraoperative_crisis_enabled = false
	for staff_member in content.collections.staff:
		app.game.meet_staff(str(staff_member.id))
	var ui_visit = app.game.open_visit("visit_sora")
	for clinic_action in CLINIC:
		expect(ui_visit.apply(clinic_action), "UI pre-op fixture failed at " + clinic_action)
	expect(app.game.open_preop("preop_sora") != null, "UI pre-op fixture could not open")
	expect(ResourceLoader.exists(app.ABDOMINAL_INCISION_VIDEO), "Abdominal incision OGV is missing")
	expect(load(app.ABDOMINAL_INCISION_VIDEO) is VideoStream, "Abdominal incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.ABDOMINAL_INCISION_VIDEO_V2), "Second abdominal incision OGV is missing")
	expect(load(app.ABDOMINAL_INCISION_VIDEO_V2) is VideoStream, "Second abdominal incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.ABDOMINAL_INCISION_VIDEO_V3), "Third abdominal incision OGV is missing")
	expect(load(app.ABDOMINAL_INCISION_VIDEO_V3) is VideoStream, "Third abdominal incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.ABDOMINAL_INCISION_VIDEO_V4), "Fourth abdominal incision OGV is missing")
	expect(load(app.ABDOMINAL_INCISION_VIDEO_V4) is VideoStream, "Fourth abdominal incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.ABDOMINAL_INCISION_VIDEO_V5), "Fifth abdominal incision OGV is missing")
	expect(load(app.ABDOMINAL_INCISION_VIDEO_V5) is VideoStream, "Fifth abdominal incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.ABDOMINAL_INCISION_VIDEO_V6), "Sixth abdominal incision OGV is missing")
	expect(load(app.ABDOMINAL_INCISION_VIDEO_V6) is VideoStream, "Sixth abdominal incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.ABDOMINAL_INCISION_VIDEO_V7), "Seventh abdominal incision OGV is missing")
	expect(load(app.ABDOMINAL_INCISION_VIDEO_V7) is VideoStream, "Seventh abdominal incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.BREAST_INCISION_VIDEO), "Breast incision OGV is missing")
	expect(load(app.BREAST_INCISION_VIDEO) is VideoStream, "Breast incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.BREAST_INCISION_VIDEO_V2), "Second breast incision OGV is missing")
	expect(load(app.BREAST_INCISION_VIDEO_V2) is VideoStream, "Second breast incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.BREAST_INCISION_VIDEO_V3), "Third breast incision OGV is missing")
	expect(load(app.BREAST_INCISION_VIDEO_V3) is VideoStream, "Third breast incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.BREAST_INCISION_VIDEO_V4), "Fourth breast incision OGV is missing")
	expect(load(app.BREAST_INCISION_VIDEO_V4) is VideoStream, "Fourth breast incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.BREAST_INCISION_VIDEO_V5), "Fifth breast incision OGV is missing")
	expect(load(app.BREAST_INCISION_VIDEO_V5) is VideoStream, "Fifth breast incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.BREAST_INCISION_VIDEO_V6), "Sixth breast incision OGV is missing")
	expect(load(app.BREAST_INCISION_VIDEO_V6) is VideoStream, "Sixth breast incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.BREAST_INCISION_VIDEO_V7), "Seventh breast incision OGV is missing")
	expect(load(app.BREAST_INCISION_VIDEO_V7) is VideoStream, "Seventh breast incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.BREAST_INCISION_VIDEO_V8), "Eighth breast incision OGV is missing")
	expect(load(app.BREAST_INCISION_VIDEO_V8) is VideoStream, "Eighth breast incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.PELVIC_INCISION_VIDEO), "Pelvic incision OGV is missing")
	expect(load(app.PELVIC_INCISION_VIDEO) is VideoStream, "Pelvic incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.PELVIC_INCISION_VIDEO_V2), "Second pelvic incision OGV is missing")
	expect(load(app.PELVIC_INCISION_VIDEO_V2) is VideoStream, "Second pelvic incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.PELVIC_INCISION_VIDEO_V3), "Third pelvic incision OGV is missing")
	expect(load(app.PELVIC_INCISION_VIDEO_V3) is VideoStream, "Third pelvic incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.PELVIC_INCISION_VIDEO_V4), "Fourth pelvic incision OGV is missing")
	expect(load(app.PELVIC_INCISION_VIDEO_V4) is VideoStream, "Fourth pelvic incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.THORACIC_INCISION_VIDEO), "Thoracic incision OGV is missing")
	expect(load(app.THORACIC_INCISION_VIDEO) is VideoStream, "Thoracic incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.THORACIC_INCISION_VIDEO_V2), "Second thoracic incision OGV is missing")
	expect(load(app.THORACIC_INCISION_VIDEO_V2) is VideoStream, "Second thoracic incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.THORACIC_INCISION_VIDEO_V3), "Third thoracic incision OGV is missing")
	expect(load(app.THORACIC_INCISION_VIDEO_V3) is VideoStream, "Third thoracic incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.THORACIC_INCISION_VIDEO_V4), "Fourth thoracic incision OGV is missing")
	expect(load(app.THORACIC_INCISION_VIDEO_V4) is VideoStream, "Fourth thoracic incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.THORACIC_INCISION_VIDEO_V5), "Fifth thoracic incision OGV is missing")
	expect(load(app.THORACIC_INCISION_VIDEO_V5) is VideoStream, "Fifth thoracic incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.THORACIC_INCISION_VIDEO_V6), "Sixth thoracic incision OGV is missing")
	expect(load(app.THORACIC_INCISION_VIDEO_V6) is VideoStream, "Sixth thoracic incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.THORACIC_INCISION_VIDEO_V7), "Seventh thoracic incision OGV is missing")
	expect(load(app.THORACIC_INCISION_VIDEO_V7) is VideoStream, "Seventh thoracic incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.THORACIC_INCISION_VIDEO_V8), "Eighth thoracic incision OGV is missing")
	expect(load(app.THORACIC_INCISION_VIDEO_V8) is VideoStream, "Eighth thoracic incision OGV did not load as a Godot video stream")
	expect(ResourceLoader.exists(app.THORACIC_INCISION_VIDEO_V9), "Ninth thoracic incision OGV is missing")
	expect(load(app.THORACIC_INCISION_VIDEO_V9) is VideoStream, "Ninth thoracic incision OGV did not load as a Godot video stream")
	var abdominal_video_pool: Array = app.INCISION_VIDEO_POOLS.abdominal
	expect(abdominal_video_pool.size() == 7, "Abdominal incision pool does not contain seven unique videos")
	var first_incision_video: String = app.incision_video_path("incise_none", "general_abdominal", false)
	var second_incision_video: String = app.incision_video_path("incise_none", "vascular", false)
	expect(first_incision_video in abdominal_video_pool and second_incision_video in abdominal_video_pool and first_incision_video != second_incision_video, "Abdominal incision pool did not avoid an immediate repeat")
	var pelvic_video_pool: Array = app.INCISION_VIDEO_POOLS.pelvic
	expect(pelvic_video_pool.size() == 4, "Pelvic incision pool does not contain four unique videos")
	var first_pelvic_video: String = app.incision_video_path("incise_epidural", "female_pelvic", false)
	var second_pelvic_video: String = app.incision_video_path("incise_epidural", "female_pelvic", false)
	expect(first_pelvic_video in pelvic_video_pool and second_pelvic_video in pelvic_video_pool and first_pelvic_video != second_pelvic_video and first_pelvic_video not in abdominal_video_pool and second_pelvic_video not in abdominal_video_pool, "Pelvic incision pool did not avoid an immediate repeat or remained mixed with abdominal videos")
	expect(app.incision_video_path("incise_local", "urologic", false) in abdominal_video_pool, "Awake urologic incision did not select its video")
	expect(app.incision_video_path("incise_general", "general_abdominal", true) in abdominal_video_pool, "General anesthesia did not select a silent incision video")
	var breast_video_pool: Array = app.INCISION_VIDEO_POOLS.breast
	expect(breast_video_pool.size() == 8, "Breast incision pool does not contain eight unique videos")
	var first_breast_video: String = app.incision_video_path("incise_none", "breast", false)
	var second_breast_video: String = app.incision_video_path("incise_none", "breast", false)
	expect(first_breast_video in breast_video_pool and second_breast_video in breast_video_pool and first_breast_video != second_breast_video, "Breast incision pool did not avoid an immediate repeat")
	var thoracic_video_pool: Array = app.INCISION_VIDEO_POOLS.thoracic
	var first_thoracic_video: String = app.incision_video_path("incise_none", "thoracic", false)
	var second_thoracic_video: String = app.incision_video_path("incise_general", "cardiac", true)
	expect(thoracic_video_pool.size() == 9 and first_thoracic_video in thoracic_video_pool and second_thoracic_video in thoracic_video_pool and first_thoracic_video != second_thoracic_video, "Shared thoracic/cardiac pool did not contain nine videos or avoid an immediate repeat")
	expect(app.incision_video_path("incise_none", "unknown", false).is_empty(), "Unknown surgery group incorrectly selected an incision video")
	app.show_preop("preop_sora")
	expect(app.page.get_node_or_null("OperatingTableFrame") == null, "Ward portrait still has the operating-table backdrop")
	press(app, "explain_plan")
	press(app, "appropriate_answer")
	for role in ["assistant_surgeon", "scrub_nurse", "circulating_nurse"]:
		expect(app.page.get_node("Role_" + role).selected == 0, "Unassigned team role displays a staff member")
	pick(app, "assistant_surgeon", 1)
	expect(app.screen == "staff_role_reward" and app.game.staff_role_cg_unlocked("role_cg_doc_aoi_assistant_surgeon"), "First assistant assignment did not unlock its role CG")
	press_named(app, "StaffRoleRewardContinue")
	await process_frame
	expect(app.game.preops.preop_sora.last_staff_id == "doc_aoi" and app.page.get_node_or_null("StaffInteractionPortrait") != null, "Assistant assignment did not show her portrait")
	pick(app, "scrub_nurse", 1)
	expect(app.screen == "staff_role_reward" and app.game.staff_role_cg_unlocked("role_cg_nurse_haru_scrub_nurse"), "First scrub-nurse assignment did not unlock its role CG")
	press_named(app, "StaffRoleRewardContinue")
	await process_frame
	expect(app.game.preops.preop_sora.last_staff_id == "nurse_haru" and app.page.get_node_or_null("StaffInteractionPortrait") != null, "Scrub assignment did not show her portrait")
	pick(app, "circulating_nurse", 2)
	expect(app.screen == "staff_role_reward" and app.game.staff_role_cg_unlocked("role_cg_nurse_rin_circulating_nurse"), "First circulating-nurse assignment did not unlock its role CG")
	press_named(app, "StaffRoleRewardContinue")
	await process_frame
	expect(app.game.preops.preop_sora.last_staff_id == "nurse_rin" and app.page.get_node_or_null("StaffInteractionPortrait") != null, "Circulating assignment did not show her portrait")
	press(app, "confirm_team")
	expect(not app.game.preops.preop_sora.team.has("ward_nurse"), "Ward nurse unexpectedly assigned")
	expect(app.page.get_node("Role_ward_nurse").selected == 0, "Unassigned nurse visually auto-selected")
	expect(app.page.get_node("PreopAction_perform_preparation").disabled, "Preparation unlocked without actual assignment")
	expect(app.page.get_node("PreopAction_begin_manual_ward_preparation").disabled, "Manual preparation unlocked without actual assignment")
	app.page.get_node("Preparation_family_call").toggled.emit(true)
	expect(app.page.get_node("Role_ward_nurse").selected == 0, "Rerender visually assigned a nurse")
	pick(app, "ward_nurse", 3)
	expect(app.screen == "staff_role_reward", "First ward-care assignment did not show its role CG")
	var ward_reward_id := "role_cg_%s_ward_nurse" % str(app.game.preops.preop_sora.team.ward_nurse)
	expect(app.game.staff_role_cg_unlocked(ward_reward_id), "Ward-care role CG was not persisted as unlocked")
	press_named(app, "StaffRoleRewardContinue")
	await process_frame
	expect(app.page.get_node("Role_ward_nurse").selected == 3, "Selected nurse not restored in picker")
	expect(not app.page.get_node("PreopAction_perform_preparation").disabled, "Preparation stayed disabled after assignment")
	expect(not app.page.get_node("PreopAction_begin_manual_ward_preparation").disabled, "Manual preparation stayed disabled after assignment")
	app.show_staff_role_gallery_entry(ward_reward_id)
	expect(app.screen == "staff_role_gallery_entry" and app.page.get_node_or_null("StaffRoleGalleryCG") != null, "Unlocked role CG could not be viewed from the gallery")
	app.show_preop("preop_sora")
	expect(app.game.unlock_staff_role_cg(str(app.game.preops.preop_sora.team.ward_nurse), "ward_nurse").is_empty(), "A previously unlocked role CG tried to unlock twice")
	app.page.get_node("Preparation_company").toggled.emit(true)
	press(app, "perform_preparation")
	for action in ["to_changing", "change_scrubs", "scrub_hands", "enter_room", "last_reassure", "team_check"]:
		press(app, action)
		await process_frame
		if action in ["change_scrubs", "scrub_hands", "enter_room"]:
			expect(app.screen == "preop_transition_video", "Preop action did not open its inline animation: " + action)
			if action == "enter_room":
				var entrance_background := app.page.get_node_or_null("SceneBackground")
				expect(entrance_background != null and entrance_background.texture.resource_path == "res://assets/backgrounds/v11/or_entrance.png", "Entering the operating room did not use the dedicated entrance background")
			expect(app.page.get_node_or_null("PreopTransitionVideoOverlay") != null, "Preop transition video did not create its input overlay: " + action)
			app.handle_preop_transition_video_input(left_click())
			await process_frame
			expect(app.screen != "preop_transition_video", "Mouse click did not skip preop transition video: " + action)
		if action == "change_scrubs":
			var scrub_background = app.page.get_node_or_null("SceneBackground")
			expect(scrub_background != null and scrub_background.texture.resource_path == "res://assets/backgrounds/v7/scrub_area.png", "Changing completion did not move the preop flow to the scrub-area background")
		expect(app.page.get_node_or_null("PreopStageArt") != null, "Stage image missing")
	for confirmation in [
		{"action": "confirm_assistant_role", "staff": "doc_aoi"},
		{"action": "confirm_scrub_role", "staff": "nurse_haru"},
		{"action": "confirm_circulating_role", "staff": "nurse_rin"},
	]:
		press(app, confirmation.action)
		await process_frame
		expect(app.game.preops.preop_sora.last_staff_id == confirmation.staff, "OR confirmation showed the wrong staff member")
		var staff_portrait = app.page.get_node_or_null("StaffInteractionPortrait")
		expect(staff_portrait != null, "OR confirmation omitted sterile portrait")
		if staff_portrait != null:
			expect(staff_portrait.texture.resource_path.contains("/sterile_pack_v1/"), "OR confirmation did not use sterile gown art")
	expect(app.game.preops.preop_sora.stage_id == "procedure_select", "UI did not reach pre-anesthesia procedure selection")
	expect(app.page.get_node_or_null("ProcedureList") != null, "Scrollable procedure list missing")
	var procedure_button = app.page.find_child("Procedure_surgery_appendix", true, false)
	expect(procedure_button != null, "Procedure button missing")
	if procedure_button != null:
		procedure_button.pressed.emit()
	expect(app.game.preops.preop_sora.stage_id == "or_table_palpation" and not app.game.preops.preop_sora.surgery_success, "UI procedure confirmation did not enter mandatory palpation")
	var selected_palpation_cg: String = str(app.game.preops.preop_sora.or_table_palpation_cg_id)
	expect(selected_palpation_cg in app.PreopView.OR_TABLE_PALPATION_IMAGES, "UI procedure selection did not record a valid palpation CG")
	var palpation_body_image: TextureRect = app.page.get_node_or_null("PalpationBodyImage")
	expect(palpation_body_image != null and palpation_body_image.texture.resource_path == str(app.PreopView.OR_TABLE_PALPATION_IMAGES[selected_palpation_cg]), "Palpation UI did not display its recorded body-type CG")
	expect(app.page.find_child("PalpationHotspot_abdomen_*", true, false) != null and app.page.find_child("PalpationHotspot_chest_*", true, false) != null, "Palpation abdominal or chest hotspot missing")
	app.set_or_table_palpation_intensity("deep")
	await process_frame
	var abdominal_hotspot: Button = app.page.find_child("PalpationHotspot_abdomen_*", true, false)
	expect(abdominal_hotspot != null, "Abdominal hotspot disappeared after changing pressure")
	if abdominal_hotspot != null:
		abdominal_hotspot.pressed.emit()
		await process_frame
	expect(app.game.preops.preop_sora.pain == 8 and app.game.preops.preop_sora.feedback.contains("请轻一点"), "UI deep abdominal palpation did not update the session")
	var palpation_complete: Button = app.page.get_node_or_null("PalpationComplete")
	expect(palpation_complete != null, "Palpation completion button missing")
	if palpation_complete != null:
		palpation_complete.pressed.emit()
		await process_frame
	expect(app.game.preops.preop_sora.stage_id == "ready", "UI palpation completion did not reach anesthesia selection")
	for action in ["choose_general", "induction_reassure", "operative_positioning", "ack_positioning", "urinary_catheterization", "ack_catheterization", "skin_disinfection", "ack_disinfection", "incision_marking", "ack_marking_general", "start_general_surgery", "request_scalpel", "assistant_stabilize", "incise_general", "complete_general_operation"]:
		press(app, action)
		await process_frame
		if action == "incise_general":
			var incision_player: VideoStreamPlayer = app.page.get_node_or_null("SurgeryVideoPlayer")
			expect(app.screen == "surgery_video" and incision_player != null and incision_player.is_playing(), "Incision choice did not start its video immediately")
			expect(app.page.get_node_or_null("IncisionVideoPromptContinue") == null, "Redundant incision confirmation remained between the choice and video")
			app.complete_surgery_video()
			await process_frame
		if app.game.preops.preop_sora.flags.has("incision_made"):
			expect(app.page.get_node_or_null("SceneBackground") != null, "Operative background missing after incision")
		else:
			expect(app.page.get_node_or_null("PreopStageArt") != null or app.page.get_node_or_null("StaffInteractionPortrait") != null, "Interaction stage image missing")
		if action == "choose_general":
			var record_text = app.page.get_node_or_null("PreopRecordText")
			var record_speaker = app.page.get_node_or_null("PreopRecordSpeaker")
			expect(record_speaker != null and record_speaker.text == "音羽 響子", "Patient dialogue speaker was not shown in the record header")
			expect(record_text != null and record_text.text.begins_with("「") and not record_text.text.begins_with("音羽 響子："), "Patient dialogue repeated the speaker name in its body")
		elif action == "induction_reassure":
			var anesthesia_splash = app.page.get_node_or_null("GeneralAnesthesiaSplash")
			expect(anesthesia_splash != null, "General anesthesia did not show the patient splash CG")
			var anesthesia_cg = app.page.find_child("GeneralAnesthesiaSplashCG", true, false)
			expect(anesthesia_cg != null and anesthesia_cg.texture.resource_path.ends_with("/anesthesia_v1/patient_sora/general.png"), "General anesthesia splash used the wrong patient art")
			var anesthesia_continue: Button = app.page.find_child("AnesthesiaSplashContinue", true, false)
			expect(anesthesia_continue != null, "General anesthesia splash omitted its continue button")
			if anesthesia_continue != null:
				anesthesia_continue.pressed.emit()
			await process_frame
			expect(app.page.get_node_or_null("GeneralAnesthesiaSplash") == null, "General anesthesia splash did not close")
		elif action in ["urinary_catheterization", "skin_disinfection", "request_scalpel"]:
			expect(app.page.get_node_or_null("WardPreparationCG") == null and app.page.get_node_or_null("WardPreparationSplash") == null, "An intimate preparation CG appeared after general anesthesia")
			if action == "request_scalpel":
				expect(app.game.preops.preop_sora.last_staff_role == "scrub_nurse" and app.page.get_node_or_null("StaffInteractionPortrait") != null, "Scalpel handoff did not show the scrub nurse")
		elif action == "assistant_stabilize":
			expect(app.game.preops.preop_sora.last_staff_role == "assistant_surgeon" and app.page.get_node_or_null("StaffInteractionPortrait") != null, "Incision preparation did not show the assistant")
			var assistant_record: RichTextLabel = app.page.get_node_or_null("PreopRecordText")
			expect(assistant_record != null and assistant_record.position.y == 600 and assistant_record.size.y == 90 and assistant_record.scroll_active, "Assistant and patient response is not constrained to the scrollable record panel")
		elif action == "incise_general":
			expect(app.game.preops.preop_sora.stage_id == "general_operation" and app.game.preops.preop_sora.flags.has("incision_made"), "General-anesthesia incision did not enter the silent operation stage")
			expect(app.game.preops.preop_sora.operative_background_id.begins_with("operating_team_") and app.page.get_node_or_null("PreopStageArt") == null and app.page.get_node_or_null("StaffInteractionPortrait") == null, "Incision did not switch to the operative CG background")
			var operative_scene = app.page.get_node_or_null("SceneBackground")
			expect(operative_scene != null and operative_scene.texture.resource_path.ends_with(app.game.preops.preop_sora.operative_background_id + ".png") and operative_scene.material != null, "Rendered operative CG is not the persisted blurred selection")
			var anesthetized_portrait = app.page.get_node_or_null("IntraoperativePatientPortrait")
			expect(anesthetized_portrait != null and anesthetized_portrait.texture.resource_path.ends_with("/patient_sora/anesthetized.png"), "General anesthesia did not show the patient's anesthetized portrait")
	var ui_used_wrong := false
	var ui_flow_guard := 0
	while app.game.preops.preop_sora.current().kind == "surgery_flow" and ui_flow_guard < 50:
		ui_flow_guard += 1
		var ui_prep = app.game.preops.preop_sora
		if ui_prep.awaiting_patient_acknowledgement:
			var patient_continue: Button = app.page.get_node_or_null("SurgeryPatientContinue")
			expect(patient_continue != null, "Patient response omitted its separate continue button")
			expect(app.page.get_node_or_null("IntraoperativePatientPortrait") != null, "Patient response omitted the intraoperative patient portrait")
			if patient_continue != null:
				patient_continue.pressed.emit()
			await process_frame
			expect(app.page.get_node_or_null("IntraoperativePatientPortrait") == null, "Patient portrait remained over the next surgical choice")
			expect(app.page.get_node_or_null("PreopRecordText") != null and app.page.get_node("PreopRecordText").text.is_empty(), "Previous patient response remained beside the next surgery choices")
			expect(app.page.get_node_or_null("SurgeryChoicePanel") != null, "Surgery choices have no contrast panel over the operative CG")
			continue
		var ui_step: Dictionary = ui_prep.surgery_flow_step()
		var ui_step_index: int = int(ui_prep.procedure_step_index)
		var ui_option: Dictionary = ui_step.options[0]
		if ui_step.kind == "decision" and not ui_used_wrong:
			for option in ui_step.options:
				if not option.correct:
					ui_option = option
					ui_used_wrong = true
					break
		var flow_button: Button = app.page.get_node_or_null("SurgeryStep_" + str(ui_option.id))
		expect(flow_button != null, "Surgery-flow option button missing")
		if flow_button == null:
			break
		flow_button.pressed.emit()
		await process_frame
		var selected_was_correct: bool = bool(ui_option.correct)
		expect(app.page.get_node_or_null("StaffInteractionPortrait") != null and app.page.get_node_or_null("PreopStageArt") == null, "Surgery-flow team response did not show the responding staff portrait")
		expect(app.page.get_node_or_null("SurgeryStep_" + str(ui_option.id)) == null, "Surgery-flow choices remained visible during the team response")
		var flow_continue: Button = app.page.get_node_or_null("SurgeryFlowContinue")
		expect(flow_continue != null, "Surgery-flow team response omitted its continue button")
		if not selected_was_correct:
			expect(ui_prep.pending_flow_retry and flow_continue != null and flow_continue.text == "返回本步骤重新选择", "Wrong surgery choice did not offer a retry")
		if flow_continue != null:
			flow_continue.pressed.emit()
		await process_frame
		if not selected_was_correct:
			expect(app.game.preops.preop_sora.procedure_step_index == ui_step_index and app.page.get_node_or_null("SurgeryChoicePanel") != null, "Wrong surgery choice advanced instead of returning to the same step")
	expect(ui_flow_guard < 50, "UI surgery flow exceeded its safety bound")
	var expected_ui_corrections := 1 if ui_used_wrong else 0
	expect(app.game.preops.preop_sora.procedure_step_history.size() == app.game.preops.preop_sora.surgery_flow_steps().size() + expected_ui_corrections and app.game.preops.preop_sora.procedure_corrections == expected_ui_corrections, "UI surgery flow did not record the expected choices and retries")
	expect(app.game.preops.preop_sora.stage_id == "procedure_execute", "UI interaction did not reach procedure execution")
	app.game.story_time_advance_minutes += maxi(0, 450 - app.game.elapsed())
	press(app, "execute_confirmed_procedure")
	expect(app.game.preops.preop_sora.stage_id == "surgery_result" and app.game.preops.preop_sora.surgery_success, "UI procedure execution failed")
	if app.screen == "surgery_cg":
		var surgery_cg_continue: Button = app.page.get_node_or_null("SurgeryCGContinue")
		expect(surgery_cg_continue != null, "Completed surgery CG omitted its continue button")
		if surgery_cg_continue != null:
			surgery_cg_continue.pressed.emit()
			await process_frame
	expect(app.screen == "preop" and app.game.pending_surgery_day_transition, "Late surgery showed day transition before its result")
	expect(app.game.preops.preop_sora.feedback.contains("患者音羽 響子的状态暂时平稳"), "UI omitted postoperative patient description")
	expect(not app.game.preops.preop_sora.procedure_mismatch, "Correct procedure triggered mismatch reaction")
	expect(app.game.preops.preop_sora.anesthesia == "全身麻醉" and app.game.preops.preop_sora.cooperation_value() == 100, "General anesthesia UI branch state wrong")
	var result_summary = app.page.get_node_or_null("SurgeryResultSummary")
	var result_metrics = app.page.get_node_or_null("SurgeryResultMetrics")
	var result_return = app.page.get_node_or_null("SurgeryResultReturn")
	var result_record = app.page.get_node_or_null("PreopRecordText")
	expect(result_summary != null and result_metrics != null and result_return != null, "Surgery result layout controls missing")
	if result_summary != null and result_metrics != null and result_return != null:
		expect(result_summary.position.y + result_summary.size.y <= result_metrics.position.y, "Surgery summary overlaps metrics")
		expect(result_metrics.position.y + 30 <= result_return.position.y, "Surgery metrics overlap return button")
		expect(result_record == null or result_return.position.y + result_return.size.y <= result_record.position.y, "Surgery result controls overlap interaction record")
	app.game.micro_event_definitions.clear()
	var pending_departure: Dictionary = app.game.pending_departure_context()
	for staff_member in content.collections.staff:
		app.game.set_after_work_last_offer_day(str(staff_member.id), int(pending_departure.get("workday", 1)))
	if result_return != null:
		result_return.pressed.emit()
	expect(app.screen == "day_transition" and not app.game.active_preop_id.is_empty(), "Late surgery did not defer day transition until after result")
	var pending_snapshot: Dictionary = app.game.snapshot()
	var pending_clone = Game.new()
	pending_clone.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions, content.collections.palpation_profiles)
	var pending_restored := pending_clone.restore(JSON.parse_string(JSON.stringify(pending_snapshot)))
	if not pending_restored:
		print("PENDING RESTORE ERROR: ", pending_clone.last_error)
	expect(pending_restored and pending_clone.pending_surgery_day_transition, "Deferred day transition did not survive save/load")
	if pending_restored:
		expect(pending_clone.staff_role_cg_unlocked("role_cg_doc_aoi_assistant_surgeon") and pending_clone.staff_role_cg_unlocked(ward_reward_id), "Role CG unlocks did not survive save/load")
		expect(pending_clone.preops.preop_sora.operative_background_id == app.game.preops.preop_sora.operative_background_id, "Random operative background changed after save replay")
	var next_day_button: Button = null
	for node in app.page.get_children():
		if node is Button and node.text.contains("进入下一天"):
			next_day_button = node
	expect(next_day_button != null, "Deferred day transition omitted continue button")
	app.game.character_event_definitions.clear()
	if next_day_button != null:
		next_day_button.pressed.emit()
	if app.screen != "map" or not app.game.active_preop_id.is_empty() or app.game.pending_surgery_day_transition:
		print("DAY TRANSITION RESULT: screen=", app.screen, " active_preop=", app.game.active_preop_id, " pending=", app.game.pending_surgery_day_transition, " mode=", app.game.active_mode)
	expect(app.screen == "map" and app.game.active_preop_id.is_empty() and not app.game.pending_surgery_day_transition, "Day transition did not settle surgery and return to map")
	var ui_next_patient: String = app.game.current_patient_id()
	var ui_next_visit: String = app.game.encounter_id_for_patient(ui_next_patient)
	expect(ui_next_patient != "patient_sora" and app.game.active_id == ui_next_visit, "UI did not rotate to an eligible next patient")
	app.show_location("clinic")
	var saw_next := false
	var saw_sora := false
	var ui_next_name: String = content.find_record("patients", ui_next_patient).name
	for node in app.page.get_children():
		if node is Button:
			saw_next = saw_next or node.text.contains(ui_next_name)
			saw_sora = saw_sora or node.text.contains(content.find_record("patients", "patient_sora").name)
	expect(saw_next and not saw_sora, "Clinic queue did not show only the selected next patient")
	app.show_map()
	expect(app.page.get_node_or_null("PlayerProfileButton") != null, "Player profile entry missing from map")
	app.show_player_profile()
	expect(app.page.get_node_or_null("PlayerMetric_leadership") != null and int(app.page.get_node("PlayerMetric_leadership").value) == 50, "Player profile did not render leadership")
	app.show_map()
	app.resume_progress()
	expect(app.screen == "encounter" and app.game.active_id == ui_next_visit, "Map resume did not open the rotated patient")
	print("PREOP: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

func press(app: Control, id: String) -> void:
	var button = app.page.get_node_or_null("PreopAction_" + id)
	expect(button != null, "Missing action button " + id)
	if button != null:
		expect(not button.disabled, "Action unexpectedly disabled " + id)
		button.pressed.emit()

func press_named(app: Control, node_name: String) -> void:
	var button: Button = app.page.get_node_or_null(node_name)
	expect(button != null, "Missing button " + node_name)
	if button != null:
		button.pressed.emit()

func pick(app: Control, role: String, index: int) -> void:
	var picker = app.page.get_node_or_null("Role_" + role)
	expect(picker != null, "Missing role picker " + role)
	if picker != null:
		expect(not picker.is_item_disabled(index), "Candidate wrongly disabled")
		picker.item_selected.emit(index)
