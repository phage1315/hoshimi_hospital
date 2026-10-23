extends RefCounted
const Encounter = preload("res://godot/systems/encounter_session.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const CharacterEvent = preload("res://godot/systems/character_event_session.gd")
const MicroEvent = preload("res://godot/systems/micro_event_session.gd")
const SpecialEvent = preload("res://godot/systems/special_event_session.gd")
const AdultIntimacySession = preload("res://godot/systems/adult_intimacy_session.gd")
const FreeHRegistry = preload("res://godot/systems/free_h_registry.gd")
const PresenceResolver = preload("res://godot/systems/presence_resolver.gd")
const FixedCalendar = preload("res://godot/systems/fixed_calendar.gd")
const Progression = preload("res://godot/systems/progression_config.gd")
const StaffPatient = preload("res://godot/systems/staff_patient_registry.gd")
const SAVE_VERSION := 36
const MIN_SUPPORTED_SAVE_VERSION := 35
const CONTENT_VERSION := 1
const STATE_DICTIONARY_SAVE_FORMAT := "state_dictionary_v1"
const SHIFT_START_MINUTE := 9 * 60
const SHIFT_MINUTES := 8 * 60
const OUTPATIENT_CLOSE_MINUTE := 16 * 60
const AFTER_WORK_NIGHT_MINUTE := 19 * 60
const AFTER_WORK_COOLDOWN_WORKDAYS := 2
const GAME_DURATION_DAYS := 365
const FINAL_WEEK_START_DAY := 359
const RELATIONSHIP_MAX_LEVEL := 5
const INTIMATE_ROUTE_LEVEL := 4
const PLAYER_ATTRIBUTE_BASE := Progression.PLAYER_ATTRIBUTE_BASE
const PLAYER_ATTRIBUTE_MIN := Progression.PLAYER_ATTRIBUTE_MIN
const PLAYER_ATTRIBUTE_MAX := Progression.PLAYER_ATTRIBUTE_MAX
const ADVANCED_REFERRAL_DEFAULT_DURATION_DAYS := 3
const ADVANCED_REFERRAL_DEFAULT_PRIORITY := 150
const ADVANCED_REFERRAL_UNLOCK_SURGERY := Progression.ADVANCED_REFERRAL_UNLOCK_SURGERY
const ADVANCED_REFERRAL_UNLOCK_REPUTATION := Progression.ADVANCED_REFERRAL_UNLOCK_REPUTATION
var preop_definitions: Dictionary = {}
var encounter_blueprints: Dictionary = {}
var preop_blueprints: Dictionary = {}
var case_templates: Dictionary = {}
var patient_cases: Dictionary = {}
var patient_queue: Array[String] = []
var patient_referrals: Dictionary = {}
var active_staff_patient: Dictionary = {}
var staff_patient_practice_counts: Dictionary = {}
var recent_patient_ids: Array[String] = []
var completed_surgeries_total := 0
var completed_surgeries_by_group: Dictionary = {}
var completed_surgeries_by_procedure: Dictionary = {}
var surgical_quality_records: Dictionary = {}
var character_progress_counters: Dictionary = {}
var surgery_xp := 0
var surgery_xp_history: Array[Dictionary] = []
var leadership_xp := 0.0
var leadership_xp_history: Array[Dictionary] = []
var staff_skill_levels: Dictionary = {}
var staff_training_credits: Dictionary = {}
var successful_no_anesthesia_surgeries := 0
var reported_surgeries := 0
var unlocked_procedure_ids: Array[String] = []
var archived_player_effects: Dictionary = {"charm": 0, "presence": 0, "reputation": 0}
var archived_player_effect_history: Array[Dictionary] = []
var time_event_definitions: Dictionary = {}
var surgery_definitions: Array = []
var advanced_referral_definitions: Array = []
var surgery_team_dialogue_profiles: Array = []
var patient_interaction_definitions: Array = []
var temporary_condition_definitions: Array = []
var palpation_profile_definitions: Array = []
var awake_special_bark_definitions: Array = []
var patient_definitions: Array = []
var diagnosis_shock_definitions: Dictionary = {}
var first_surgery_diagnosis_shock_state: Dictionary = {}
var relationship_definitions: Array = []
var character_event_definitions: Dictionary = {}
var staff_role_cg_definitions: Dictionary = {}
var relationships: Dictionary = {}
var character_events: Dictionary = {}
var character_event_order: Array[String] = []
var active_character_event_id := ""
var micro_event_definitions: Dictionary = {}
var examination_cg_pool_definitions: Dictionary = {}
var examination_cg_by_test: Dictionary = {}
var examination_cg_by_surgery: Dictionary = {}
var micro_events: Dictionary = {}
var micro_event_order: Array[String] = []
var active_micro_event_id := ""
var special_event_definitions: Dictionary = {}
var special_event_step_definitions: Dictionary = {}
var date_profile_definitions: Dictionary = {}
var date_location_definitions: Dictionary = {}
var special_event_completion_counts: Dictionary = {}
var special_event_completion_days: Dictionary = {}
var story_flags: Dictionary = {}
var probation_complete := false
var personal_nurse_system_unlocked := false
var personal_nurse_id := ""
var active_special_event_id := ""
var active_special_event: RefCounted
var staff: Array = []
var base_staff_skills: Dictionary = {}
var presence_resolver: RefCounted
var preops: Dictionary = {}
var active_preop_id := ""
var active_mode := "encounter"
var definitions: Dictionary = {}
var visits: Dictionary = {}
var active_id := ""
var time_log: Array[Dictionary] = []
var last_error := ""
var last_time_event_response := ""
var discarded_overtime_minutes := 0
var story_time_advance_minutes := 0
# Global elapsed time from retired cases, not a patient medical history.
var archived_clinical_minutes := 0
var pending_encounter_day_transition := false
var pending_surgery_day_transition := false
var pending_day_exit_workday := 0
var pending_day_exit_clock := 0
var active_after_work_walk: Dictionary = {}
var free_h_booking: Dictionary = {}
# Transient departure ownership, deliberately absent from save snapshots.
var active_free_h_departure: Dictionary = {}
var sayaka_lv4_callback_override_day := -1
var sayaka_lv4_callback_override_clock := -1
var campaign_seed := 1
var sunday_history: Array[Dictionary] = []
var intraoperative_crisis_enabled := true
var adult_intimacy_unlocks: Dictionary = {}
var active_adult_intimacy: RefCounted
var adult_intimacy_return_mode := "encounter"
var restore_warnings: Array[String] = []

func configure(data: Array, preop_data: Array = [], staff_data: Array = [], time_event_data: Array = [], surgery_data: Array = [], patient_data: Array = [], relationship_data: Array = [], character_event_data: Array = [], case_template_data: Array = [], micro_event_data: Array = [], examination_cg_pool_data: Array = [], surgery_team_dialogue_data: Array = [], patient_interaction_data: Array = [], temporary_condition_data: Array = [], staff_role_cg_data: Array = [], special_event_data: Array = [], special_event_step_data: Array = [], date_profile_data: Array = [], date_location_data: Array = [], advanced_referral_data: Array = [], diagnosis_shock_data: Array = [], palpation_profile_data: Array = [], awake_special_bark_data: Array = []) -> void:
	preop_definitions.clear()
	preop_blueprints.clear()
	encounter_blueprints.clear()
	case_templates.clear()
	time_event_definitions.clear()
	staff = staff_data
	active_staff_patient.clear()
	staff_patient_practice_counts.clear()
	base_staff_skills.clear()
	for person in staff:
		base_staff_skills[str(person.get("id", ""))] = person.get("skills", {}).duplicate(true)
	presence_resolver = PresenceResolver.new(staff_data)
	surgery_definitions = surgery_data
	advanced_referral_definitions = advanced_referral_data
	surgery_team_dialogue_profiles = surgery_team_dialogue_data
	patient_interaction_definitions = patient_interaction_data
	temporary_condition_definitions = temporary_condition_data
	palpation_profile_definitions = palpation_profile_data
	awake_special_bark_definitions = awake_special_bark_data
	patient_definitions = patient_data
	diagnosis_shock_definitions.clear()
	for entry in diagnosis_shock_data:
		diagnosis_shock_definitions[str(entry.get("id", ""))] = entry.duplicate(true)
	relationship_definitions = relationship_data
	character_event_definitions.clear()
	for entry in character_event_data:
		character_event_definitions[entry.id] = entry
	staff_role_cg_definitions.clear()
	for entry in staff_role_cg_data:
		staff_role_cg_definitions[entry.id] = entry
	micro_event_definitions.clear()
	for entry in micro_event_data:
		micro_event_definitions[entry.id] = entry
	special_event_definitions.clear()
	for entry in special_event_data:
		special_event_definitions[entry.id] = entry
	special_event_step_definitions.clear()
	for entry in special_event_step_data:
		special_event_step_definitions[entry.id] = entry
	date_profile_definitions.clear()
	for entry in date_profile_data:
		date_profile_definitions[entry.staff_id] = entry
	date_location_definitions.clear()
	for entry in date_location_data:
		date_location_definitions[entry.id] = entry
	examination_cg_pool_definitions.clear()
	examination_cg_by_test.clear()
	examination_cg_by_surgery.clear()
	for entry in examination_cg_pool_data:
		examination_cg_pool_definitions[entry.id] = entry
		for test_id in entry.test_ids:
			examination_cg_by_test[test_id] = entry.id
		for surgery_id in entry.surgery_ids:
			examination_cg_by_surgery[surgery_id] = entry.id
	for entry in preop_data:
		preop_blueprints[entry.id] = entry.duplicate(true)
	definitions.clear()
	for entry in data:
		encounter_blueprints[entry.id] = entry.duplicate(true)
	for entry in case_template_data:
		case_templates[entry.id] = entry.duplicate(true)
	for entry in time_event_data:
		time_event_definitions[entry.id] = entry
	reset()

func reset() -> void:
	active_staff_patient.clear()
	staff_patient_practice_counts.clear()
	campaign_seed = randi_range(1, 2147483646)
	var campaign_rng := RandomNumberGenerator.new()
	campaign_rng.seed = campaign_seed
	patient_queue = random_patient_queue(campaign_rng)
	patient_referrals.clear()
	recent_patient_ids.clear()
	completed_surgeries_total = 0
	completed_surgeries_by_group.clear()
	completed_surgeries_by_procedure.clear()
	surgical_quality_records.clear()
	character_progress_counters.clear()
	surgery_xp = 0
	surgery_xp_history.clear()
	leadership_xp = 0.0
	leadership_xp_history.clear()
	staff_skill_levels.clear()
	staff_training_credits.clear()
	restore_base_staff_skills()
	successful_no_anesthesia_surgeries = 0
	reported_surgeries = 0
	unlocked_procedure_ids = starting_procedure_ids()
	archived_player_effects = zero_player_effects()
	archived_player_effect_history.clear()
	first_surgery_diagnosis_shock_state.clear()
	visits.clear()
	preops.clear()
	active_preop_id = ""
	active_mode = "encounter"
	active_id = ""
	time_log.clear()
	relationships = fresh_relationships()
	character_events.clear()
	character_event_order.clear()
	active_character_event_id = ""
	micro_events.clear()
	micro_event_order.clear()
	active_micro_event_id = ""
	special_event_completion_counts.clear()
	special_event_completion_days.clear()
	story_flags.clear()
	patient_cases = random_patient_cases(campaign_rng) if not case_templates.is_empty() else {}
	rebuild_patient_content(patient_cases)
	probation_complete = false
	personal_nurse_system_unlocked = false
	personal_nurse_id = ""
	active_special_event_id = ""
	active_special_event = null
	discarded_overtime_minutes = 0
	story_time_advance_minutes = 0
	archived_clinical_minutes = 0
	pending_encounter_day_transition = false
	pending_surgery_day_transition = false
	pending_day_exit_workday = 0
	pending_day_exit_clock = 0
	active_after_work_walk.clear()
	free_h_booking.clear()
	active_free_h_departure.clear()
	sunday_history.clear()
	intraoperative_crisis_enabled = true
	adult_intimacy_unlocks.clear()
	active_adult_intimacy = null
	adult_intimacy_return_mode = "encounter"
	last_error = ""
	last_time_event_response = ""

func active_surgery_in_progress() -> bool:
	return not active_preop_id.is_empty() and preops.has(active_preop_id) and preops[active_preop_id].surgery_in_progress()

func active_surgery_committed() -> bool:
	return not active_preop_id.is_empty() and preops.has(active_preop_id) and preops[active_preop_id].surgery_committed()

func active_encounter_in_progress() -> bool:
	return not active_id.is_empty() and visits.has(active_id) and not visits[active_id].completed()

func active_admission_pending() -> bool:
	return not active_id.is_empty() and visits.has(active_id) and visits[active_id].admitted and not completed_patient(str(visits[active_id].definition.patient_id))

func day_transition_deferred() -> bool:
	# The admission summary stays visible until an explicit handoff. Patients
	# already handed over to the ward do not lock subsequent days by themselves.
	return active_encounter_in_progress() or active_admission_pending() or (not active_preop_id.is_empty() and preops.has(active_preop_id))

func remember_deferred_day_transition() -> void:
	if active_encounter_in_progress() or active_admission_pending():
		pending_encounter_day_transition = true
	if not active_preop_id.is_empty() and preops.has(active_preop_id):
		pending_surgery_day_transition = true

func can_end_day_after_admission(encounter_id: String) -> bool:
	if encounter_id.is_empty() or encounter_id != active_id or active_mode != "encounter":
		return false
	var visit = visits.get(encounter_id)
	if visit == null or not visit.completed() or not visit.admitted or completed_patient(str(visit.definition.patient_id)):
		return false
	if not active_preop_id.is_empty() or not active_micro_event_id.is_empty() or not active_character_event_id.is_empty() or not active_special_event_id.is_empty():
		return false
	for preparation in preops.values():
		if str(preparation.definition.encounter_id) == encounter_id:
			return false
	return pending_day_exit_workday > 0 and pending_day_exit_clock >= SHIFT_START_MINUTE + SHIFT_MINUTES

func finish_admission_for_day(encounter_id: String) -> bool:
	if not can_end_day_after_admission(encounter_id):
		return false
	# Retain the visit, notes, patient queue and admission for the next workday.
	# The UI consumes the existing overtime departure exactly once afterwards.
	active_id = ""
	pending_encounter_day_transition = false
	return true

func can_save_progress() -> bool:
	if not active_free_h_departure.is_empty():
		return false
	# Saves are boundary snapshots, never resumable UI/event positions. The
	# player can save from the hospital directory or Sunday menu only.
	if not active_id.is_empty() or not active_preop_id.is_empty() or active_mode != "encounter":
		return false
	if active_surgery_in_progress():
		return false
	if not active_preop_id.is_empty() and preops.has(active_preop_id) and preops[active_preop_id].graphic_preop_dialogue_locked():
		return false
	if not active_after_work_walk.is_empty():
		return false
	# Narrative sessions are deliberately atomic. Their scripts and state migrations
	# only need to support entry and completion boundaries, never arbitrary nodes.
	if not active_special_event_id.is_empty():
		return false
	if not active_character_event_id.is_empty():
		return false
	if not active_micro_event_id.is_empty():
		return false
	if active_adult_intimacy != null:
		return false
	return true

func special_event_in_progress() -> bool:
	return not active_special_event_id.is_empty() and active_special_event != null and not active_special_event.completed

func special_event_skips_departure() -> bool:
	return active_special_event != null and active_special_event.completed and bool(active_special_event.definition.get("skip_departure_events_on_completion", false))

func save_block_reason() -> String:
	if can_save_progress():
		return ""
	if active_surgery_in_progress():
		return "手术进行中，无法保存。请完成本次手术后再保存。"
	if not active_id.is_empty():
		return "看诊进行中，无法保存。请返回医院导览后再保存。"
	if not active_preop_id.is_empty():
		return "术前流程进行中，无法保存。请返回医院导览后再保存。"
	if not active_preop_id.is_empty() and preops.has(active_preop_id) and preops[active_preop_id].graphic_preop_dialogue_locked():
		return "术前说明进行中，无法保存。请完成本段对话后再保存。"
	if not active_after_work_walk.is_empty():
		return "下班同行事件进行中，无法保存。请完成本段剧情后再保存。"
	return "剧情事件进行中，无法保存。请完成本段剧情后再保存。"

func shuffle_with_rng(values: Array, rng: RandomNumberGenerator) -> void:
	for index in range(values.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var value: Variant = values[index]
		values[index] = values[swap_index]
		values[swap_index] = value

func random_patient_queue(rng: RandomNumberGenerator = null) -> Array[String]:
	var result: Array[String] = []
	for patient in patient_definitions:
		result.append(patient.id)
	if rng == null:
		result.shuffle()
	else:
		shuffle_with_rng(result, rng)
	return result

func valid_patient_queue(value: Variant) -> bool:
	if not value is Array or value.size() > patient_definitions.size():
		return false
	var expected := {}
	for patient in patient_definitions:
		expected[patient.id] = true
	var seen := {}
	for id in value:
		if not id is String or not expected.has(id) or seen.has(id):
			return false
		seen[id] = true
	return true

func zero_player_effects() -> Dictionary:
	var result := {}
	for metric in PLAYER_ATTRIBUTE_BASE:
		if metric not in ["skill", "leadership"]:
			result[metric] = 0
	return result

func add_player_attribute_effect(metric: String, amount: int, source_id: String = "", label: String = "") -> void:
	if metric not in archived_player_effects or amount == 0:
		return
	archived_player_effects[metric] = int(archived_player_effects.get(metric, 0)) + amount
	archived_player_effect_history.append({
		"id": source_id if not source_id.is_empty() else "%s_effect_%s" % [metric, archived_player_effect_history.size() + 1],
		"label": label if not label.is_empty() else metric,
		"effects": {metric: amount},
	})

func restore_base_staff_skills() -> void:
	for person in staff:
		var actor_id := str(person.get("id", ""))
		if base_staff_skills.has(actor_id):
			person["skills"] = base_staff_skills[actor_id].duplicate(true)

func apply_staff_skill_levels() -> void:
	restore_base_staff_skills()
	for person in staff:
		var actor_id := str(person.get("id", ""))
		if not staff_skill_levels.has(actor_id):
			continue
		for skill_id in staff_skill_levels[actor_id]:
			person.skills[skill_id] = int(staff_skill_levels[actor_id][skill_id])

func valid_recent_patients(value: Variant) -> bool:
	if not value is Array or value.size() > mini(2, patient_definitions.size()):
		return false
	var known := {}
	for patient in patient_definitions:
		known[patient.id] = true
	var seen := {}
	for id in value:
		if not id is String or not known.has(id) or seen.has(id):
			return false
		seen[id] = true
	return true

func starting_procedure_ids() -> Array[String]:
	var result: Array[String] = []
	for surgery in surgery_definitions:
		if bool(surgery.get("unlocked_at_start", false)) and str(surgery.get("status", "ready")) != "placeholder":
			result.append(str(surgery.id))
	return result

func weighted_case_pick(pool: Array, rng: RandomNumberGenerator = null) -> String:
	if pool.is_empty():
		return ""
	var total_weight := 0
	for template_id in pool:
		total_weight += maxi(1, int(case_templates[template_id].get("case_weight", 1)))
	var roll := rng.randi_range(1, total_weight) if rng != null else randi_range(1, total_weight)
	for template_id in pool:
		roll -= maxi(1, int(case_templates[template_id].get("case_weight", 1)))
		if roll <= 0:
			return str(template_id)
	return str(pool.back())

func procedure_unlock_requirement_flag(surgery_id: String) -> String:
	match surgery_id:
		"surgery_hysterectomy":
			return "aqua_hysterectomy_teaching_complete"
		"surgery_vaginal_hysterectomy":
			return "aqua_vaginal_hysterectomy_teaching_complete"
		_:
			return ""

func synchronize_story_locked_procedures() -> void:
	for surgery in surgery_definitions:
		var surgery_id := str(surgery.get("id", ""))
		var requirement_flag := procedure_unlock_requirement_flag(surgery_id)
		if requirement_flag.is_empty() or not story_flag(requirement_flag):
			continue
		if not unlocked_procedure_ids.has(surgery_id):
			unlocked_procedure_ids.append(surgery_id)
	for preparation in preops.values():
		preparation.set_procedure_unlocks(unlocked_procedure_ids, true)

func case_template_available(template_id: String, saved_story_flags: Dictionary = {}, use_saved_flags: bool = false) -> bool:
	if not case_templates.has(template_id):
		return false
	var surgery_id := str(case_templates[template_id].get("surgery_id", ""))
	var requirement_flag := procedure_unlock_requirement_flag(surgery_id)
	if not requirement_flag.is_empty():
		return bool(saved_story_flags.get(requirement_flag, false)) if use_saved_flags else story_flag(requirement_flag)
	# Ordinary cases are allowed to introduce their indicated procedure on
	# admission. Only procedures with an explicit teaching gate are filtered.
	return true

func random_patient_cases(rng: RandomNumberGenerator = null, saved_story_flags: Dictionary = {}, use_saved_flags: bool = false) -> Dictionary:
	var pool: Array = case_templates.keys().filter(func(template_id: Variant): return case_template_available(str(template_id), saved_story_flags, use_saved_flags))
	var starting_pool: Array = pool.filter(func(template_id: Variant): return starting_procedure_ids().has(str(case_templates[template_id].surgery_id)))
	var result := {}
	var assignment_order: Array[String] = patient_queue.duplicate()
	if assignment_order.is_empty():
		for patient in patient_definitions:
			assignment_order.append(str(patient.id))
	var guaranteed_starting := mini(2, mini(assignment_order.size(), starting_pool.size()))
	for i in range(assignment_order.size()):
		if pool.is_empty():
			break
		var candidates: Array = starting_pool if i < guaranteed_starting and not starting_pool.is_empty() else pool
		var selected := weighted_case_pick(candidates, rng)
		result[assignment_order[i]] = selected
		pool.erase(selected)
		starting_pool.erase(selected)
	return result

func complete_patient_queue(saved_queue: Array, rng: RandomNumberGenerator) -> Array[String]:
	var result: Array[String] = []
	var known := {}
	for patient in patient_definitions:
		known[str(patient.id)] = true
	var seen := {}
	for patient_id in saved_queue:
		if known.has(patient_id) and not seen.has(patient_id):
			result.append(patient_id)
			seen[patient_id] = true
	var additions: Array = []
	for patient in patient_definitions:
		if not seen.has(str(patient.id)):
			additions.append(str(patient.id))
	shuffle_with_rng(additions, rng)
	for patient_id in additions:
		result.append(patient_id)
	return result

func complete_patient_cases(saved_cases: Dictionary, saved_queue: Array[String], rng: RandomNumberGenerator, saved_story_flags: Dictionary) -> Dictionary:
	var result := {}
	var used_templates := {}
	for patient in patient_definitions:
		var patient_id := str(patient.id)
		var template_id: Variant = saved_cases.get(patient_id)
		if template_id is String and case_templates.has(template_id):
			result[patient_id] = template_id
			used_templates[template_id] = true
	var available_templates: Array = case_templates.keys().filter(func(template_id: Variant): return case_template_available(str(template_id), saved_story_flags, true) and not used_templates.has(template_id))
	var starting_templates: Array = available_templates.filter(func(template_id: Variant): return starting_procedure_ids().has(str(case_templates[template_id].surgery_id)))
	var assignment_order: Array[String] = []
	for patient_id in saved_queue:
		if not result.has(patient_id):
			assignment_order.append(patient_id)
	for patient in patient_definitions:
		var patient_id := str(patient.id)
		if not result.has(patient_id) and not assignment_order.has(patient_id):
			assignment_order.append(patient_id)
	var guaranteed_starting := mini(2, mini(assignment_order.size(), starting_templates.size()))
	for index in assignment_order.size():
		if available_templates.is_empty():
			available_templates = case_templates.keys().filter(func(template_id: Variant): return case_template_available(str(template_id), saved_story_flags, true))
			starting_templates = available_templates.duplicate()
		if available_templates.is_empty():
			break
		var candidates: Array = starting_templates if index < guaranteed_starting and not starting_templates.is_empty() else available_templates
		var selected := weighted_case_pick(candidates, rng)
		result[assignment_order[index]] = selected
		available_templates.erase(selected)
		starting_templates.erase(selected)
	return result

func legacy_patient_cases() -> Dictionary:
	var result := {}
	for preop in preop_blueprints.values():
		for template in case_templates.values():
			if template.surgery_id == preop.surgery_id:
				result[preop.patient_id] = template.id
				break
	return result

func valid_patient_cases(assignments: Variant) -> bool:
	if not assignments is Dictionary:
		return false
	if case_templates.is_empty():
		return assignments.is_empty()
	for patient_id in assignments:
		if not patient_id is String or not assignments[patient_id] is String or not case_templates.has(assignments[patient_id]):
			return false
	return true

func patient_case(patient_id: String) -> Dictionary:
	var template_id: String = str(patient_cases.get(patient_id, ""))
	return case_templates.get(template_id, {})

func rebuild_patient_content(assignments: Dictionary) -> void:
	definitions = encounter_definitions_for(assignments, first_surgery_diagnosis_shock_state)
	preop_definitions = preop_definitions_for(assignments)
	if not active_staff_patient.is_empty():
		preop_definitions[StaffPatient.PREOP_ID] = staff_patient_preop_definition(active_staff_patient)

func encounter_definitions_for(assignments: Dictionary, diagnosis_shock_state: Dictionary = {}, include_seen_diagnosis_shocks: bool = false) -> Dictionary:
	var result := {}
	for id in encounter_blueprints:
		var definition: Dictionary = encounter_blueprints[id].duplicate(true)
		var template_id: String = str(assignments.get(definition.patient_id, ""))
		if case_templates.has(template_id):
			definition = encounter_for_case(definition, case_templates[template_id], diagnosis_shock_state, include_seen_diagnosis_shocks)
		result[id] = definition
	return result

func preop_definitions_for(assignments: Dictionary) -> Dictionary:
	var result := {}
	for id in preop_blueprints:
		var definition: Dictionary = preop_blueprints[id].duplicate(true)
		var template_id: String = str(assignments.get(definition.patient_id, ""))
		if case_templates.has(template_id):
			definition.surgery_id = case_templates[template_id].surgery_id
			definition.difficulty_modifier = int(case_templates[template_id].get("difficulty_modifier", 0))
			definition.title = "%s · %s" % [case_templates[template_id].title, "Preoperative Preparation" if str(definition.get("_locale", "zh_CN")) == "en" else "术前准备"]
		result[id] = definition
	return result

func patient_voice_style(patient_id: String) -> String:
	for patient in patient_definitions:
		if str(patient.id) == patient_id:
			return str(patient.get("voice_style", "direct"))
	return "direct"

func patient_reaction_line(patient_id: String, reaction_id: String, fallback: String) -> String:
	for patient in patient_definitions:
		if str(patient.id) == patient_id:
			return str(patient.get("reaction_lines", {}).get(reaction_id, fallback))
	return fallback

func patient_voice_line(patient_id: String, line: String, beat: String) -> String:
	var patient := patient_definition(patient_id)
	var owned_lines: Dictionary = patient.get("outpatient_lines", {})
	if owned_lines.has(beat):
		return str(owned_lines[beat]).replace("{line}", line)
	var style := patient_voice_style(patient_id)
	var prefixes := {
		"direct": {"complaint": "", "primary": "", "secondary": "还有，"},
		"reserved": {"complaint": "那个……", "primary": "我想想……", "secondary": "还有就是……"},
		"bold": {"complaint": "其实吧，", "primary": "就是，", "secondary": "而且，"},
		"gentle": {"complaint": "不好意思，", "primary": "", "secondary": "另外，"},
		"soft": {"complaint": "嗯……", "primary": "比较明显的是，", "secondary": "另外还有，"}
	}
	var style_prefixes: Dictionary = prefixes.get(style, prefixes["direct"])
	if beat == "background":
		return "我以前没得过什么大病，也没有药物过敏。"
	return str(style_prefixes.get(beat, "")) + line

func patient_spoken_line(patient_id: String, line: String, beat: String, english: bool) -> String:
	var voiced := patient_voice_line(patient_id, line, beat)
	return "“%s”" % voiced if english else "「%s」" % voiced

func patient_definition(patient_id: String) -> Dictionary:
	for patient in patient_definitions:
		if str(patient.get("id", "")) == patient_id:
			return patient
	return StaffPatient.patient_record(staff_record(patient_id), patient_content_locale())

func patient_content_locale() -> String:
	for blueprint in preop_blueprints.values():
		return str(blueprint.get("_locale", "zh_CN"))
	return "zh_CN"

func staff_patient_preop_definition(admission: Dictionary) -> Dictionary:
	return StaffPatient.preop_definition(staff_record(str(admission.get("staff_id", ""))), surgery_definition(str(admission.get("procedure_id", ""))), patient_content_locale())

func staff_patient_unlocked(actor_id: String) -> bool:
	var config := StaffPatient.profile(actor_id)
	if config.is_empty() or not staff_is_met(actor_id):
		return false
	for flag in config.get("unlock_flags", []):
		if not bool(story_flags.get(flag, false)):
			return false
	return true

func staff_patient_available_procedures() -> Array:
	return surgery_definitions.filter(func(entry: Dictionary): return procedure_unlocked(str(entry.id)))

func can_invite_staff_patient(actor_id: String) -> bool:
	var english := patient_content_locale() == "en"
	last_error = ""
	if not staff_patient_unlocked(actor_id):
		last_error = "Staff-as-patient is not unlocked." if english else "尚未解锁医护作为患者。"
	elif unresolved_admitted_patient_exists():
		last_error = "Finish the admitted patient's case before inviting a colleague." if english else "请先完成病房患者的病例，再邀请医护进行手术练习。"
	elif is_hospital_closed_day() or outpatient_closed():
		last_error = "Invitations are available during outpatient working hours." if english else "请在门诊工作时间发出手术邀请。"
	elif active_encounter_in_progress() or not active_preop_id.is_empty() or special_event_in_progress() or not active_character_event_id.is_empty() or not active_micro_event_id.is_empty() or active_adult_intimacy != null or not active_after_work_walk.is_empty() or not active_free_h_departure.is_empty():
		last_error = "Finish the current activity first." if english else "请先完成当前活动。"
	return last_error.is_empty()

func invite_staff_patient(actor_id: String, surgery_id: String) -> bool:
	if not can_invite_staff_patient(actor_id):
		return false
	if not procedure_unlocked(surgery_id):
		last_error = "This procedure is not unlocked." if patient_content_locale() == "en" else "该术式尚未解锁。"
		return false
	var admission := {"staff_id": actor_id, "procedure_id": surgery_id}
	var definition := staff_patient_preop_definition(admission)
	if definition.is_empty():
		return false
	active_staff_patient = admission
	preop_definitions[StaffPatient.PREOP_ID] = definition
	return true

func staff_patient_invitation_line(actor_id: String, surgery_id: String) -> String:
	var lines := StaffPatient.dialogue(actor_id, patient_content_locale())
	var choices: Array = lines.get("invitation_by_procedure", {}).get(surgery_id, lines.get("invitation_lines", []))
	if choices.is_empty():
		return ""
	return str(choices[randi() % choices.size()]).replace("{procedure_name}", str(surgery_definition(surgery_id).get("name", surgery_id)))

func staff_patient_practice_count(actor_id: String, surgery_id: String) -> int:
	return int(staff_patient_practice_counts.get(actor_id, {}).get(surgery_id, 0))

func staff_patient_xp_multiplier(actor_id: String, surgery_id: String) -> float:
	return [1.0, 0.5, 0.0][mini(2, staff_patient_practice_count(actor_id, surgery_id))]

func staff_patient_agreement_fulfilled(preparation: RefCounted) -> bool:
	return preparation.is_staff_patient() and str(preparation.procedure_id) == str(preparation.definition.get("agreed_procedure_id", ""))

func retire_staff_patient(preparation: RefCounted) -> void:
	# Archive time/effects without rotating or reassigning the ordinary queue.
	archived_clinical_minutes += int(preparation.minutes)
	for metric in archived_player_effects:
		if metric != "reputation":
			archived_player_effects[metric] = int(archived_player_effects[metric]) + int(preparation.player_effects.get(metric, 0))
	for record in preparation.player_effect_history:
		archived_player_effect_history.append(record.duplicate(true))
	preops.erase(StaffPatient.PREOP_ID)
	preop_definitions.erase(StaffPatient.PREOP_ID)
	active_staff_patient.clear()

func first_surgery_diagnosis_reaction(patient_id: String, surgery_id: String, diagnosis_shock_state: Dictionary, include_seen: bool = false) -> Dictionary:
	var patient := patient_definition(patient_id)
	if patient.is_empty() or int(patient.get("age", 0)) < 18:
		return {}
	if bool(patient.get("medical_background", false)) or bool(patient.get("has_prior_surgery", false)):
		return {}
	var saved_state: Dictionary = diagnosis_shock_state.get(patient_id, {})
	if bool(saved_state.get("first_surgery_diagnosis_shock_seen", false)):
		var saved_variant_id := str(saved_state.get("first_surgery_diagnosis_shock_variant_id", ""))
		if include_seen and diagnosis_shock_definitions.has(saved_variant_id):
			return diagnosis_shock_definitions[saved_variant_id]
		return {}
	var override_id := str(patient.get("first_surgery_diagnosis_shock_override_id", ""))
	if not override_id.is_empty() and diagnosis_shock_definitions.has(override_id):
		return diagnosis_shock_definitions[override_id]
	var surgery := surgery_definition(surgery_id)
	var site_group := str(surgery.get("diagnosis_reaction_site_group", "generic"))
	var candidates: Array[Dictionary] = []
	for reaction in diagnosis_shock_definitions.values():
		if str(reaction.get("patient_id", "")) == patient_id and str(reaction.get("site_group", "generic")) == site_group:
			candidates.append(reaction)
	if candidates.is_empty():
		for reaction in diagnosis_shock_definitions.values():
			if str(reaction.get("patient_id", "")).is_empty() and str(reaction.get("site_group", "generic")) == site_group:
				candidates.append(reaction)
	if candidates.is_empty() and site_group != "generic":
		for reaction in diagnosis_shock_definitions.values():
			if str(reaction.get("patient_id", "")).is_empty() and str(reaction.get("site_group", "")) == "generic":
				candidates.append(reaction)
	if candidates.is_empty():
		return {}
	candidates.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.id) < str(b.id))
	var total_weight := 0.0
	for reaction in candidates:
		total_weight += maxf(0.0, float(reaction.get("weight", 1.0)))
	if total_weight <= 0.0:
		return candidates[0]
	var roll := float(posmod((patient_id + "|" + surgery_id).hash(), 1000000)) / 1000000.0 * total_weight
	for reaction in candidates:
		roll -= maxf(0.0, float(reaction.get("weight", 1.0)))
		if roll < 0.0:
			return reaction
	return candidates.back()

func diagnosis_shock_text(reaction: Dictionary) -> String:
	var lines: Array[String] = []
	for line in reaction.get("lines", []):
		var fragments: Array[String] = []
		for fragment in str(line).replace("\r", "").split("\n", false):
			var trimmed := str(fragment).strip_edges()
			if not trimmed.is_empty():
				fragments.append(trimmed)
		if not fragments.is_empty():
			lines.append(" ".join(fragments))
	return " ".join(lines)

func encounter_for_case(blueprint: Dictionary, template: Dictionary, diagnosis_shock_state: Dictionary = {}, include_seen_diagnosis_shocks: bool = false) -> Dictionary:
	var result: Dictionary = blueprint.duplicate(true)
	result.title = template.title
	var stages := {}
	for stage in result.stages:
		stages[stage.id] = stage
	var actions := {}
	for stage_id in stages:
		actions[stage_id] = {}
		for action in stages[stage_id].actions:
			actions[stage_id][action.id] = action
	var english: bool = str(blueprint.get("_locale", "zh_CN")) == "en"
	var symptoms: Array = ["Primary symptom", "Associated symptoms"] if english else template.symptoms
	var history: Array = ["The symptoms began recently and have gradually become more noticeable.", "They are affecting daily life enough to seek specialist care."] if english else template.history
	var findings: Array = ["The examination findings are consistent with the working diagnosis."] if english else template.examination_findings
	var tests: Array = template.tests
	var differentials: Array = ["Alternative diagnosis", "Observation only"] if english else template.differential_diagnoses
	var patient_id: String = str(result.patient_id)
	stages.reception.prompt = patient_spoken_line(patient_id, str(template.presenting_complaint), "complaint", english)
	actions.reception.greet.response = patient_spoken_line(patient_id, str(history[0]), "primary", english)
	actions.reception.comfort.response = patient_spoken_line(patient_id, str(history[1]), "secondary", english)
	actions.reception.comfort.notes[0].text = "The patient is worried about the symptoms and what will happen next." if english else "患者对本次症状和后续安排感到担心。"
	stages.history.prompt = "“Please describe the course of these symptoms in detail.”" if english else "「把这次不舒服的经过详细说说吧。」"
	actions.history.pain.label = str(symptoms[0])
	actions.history.pain.response = patient_spoken_line(patient_id, str(history[0]), "primary", english)
	actions.history.pain.notes[0].text = ("Primary symptom: %s." if english else "主要症状：%s。") % symptoms[0]
	actions.history.associated.label = "Other symptoms" if english else "其他症状"
	actions.history.associated.response = patient_spoken_line(patient_id, str(history[1]), "secondary", english)
	actions.history.associated.notes[0].text = ("Associated symptoms: %s." % ", ".join(symptoms.slice(1))) if english else ("伴随症状：%s。" % "、".join(symptoms.slice(1)))
	actions.history.background.response = patient_spoken_line(patient_id, "", "background", english)
	actions.history.background.notes[0].text = "Past history and allergies recorded." if english else "既往情况与过敏史已记录。"
	var voiced_history: Array[String] = []
	var owned_history_lines: Dictionary = patient_definition(patient_id).get("outpatient_lines", {})
	var used_literal_beats := {}
	for index in range(history.size()):
		var beat := "primary" if index == 0 else "secondary"
		# A fixed patient response is one utterance, not a template for each
		# case-history item. Placeholder/fallback responses still keep every item.
		if owned_history_lines.has(beat) and not str(owned_history_lines[beat]).contains("{line}"):
			if used_literal_beats.has(beat):
				continue
			used_literal_beats[beat] = true
		voiced_history.append(patient_voice_line(patient_id, str(history[index]), beat))
	stages.history.bundles[0].response = "“%s”" % " ".join(voiced_history) if english else "「%s」" % "".join(voiced_history)
	stages.history.bundles[0].summary = ("History organized · %s symptoms" if english else "病史已整理 · %s 种症状") % symptoms.size()
	actions.exam.vitals.response = "“Vital signs recorded.”" if english else "「生命体征已经记录。」"
	actions.exam.vitals.notes[0].text = "Baseline vital signs recorded; examination may continue." if english else "基础生命体征已记录，当前可继续检查。"
	for resolution_id in ["authoritative_full_undress", "gentle_full_undress", "threaten_full_undress"]:
		actions.exam_undress_decision[resolution_id].notes[0].text = "；".join(findings)
	actions.tests.blood.label = tests[0].label
	actions.tests.blood.response = "“The result supports the current working diagnosis.”" if english else "「%s」" % tests[0].result
	actions.tests.blood.notes[0].text = "%s: result reviewed" % tests[0].label if english else "%s：%s" % [tests[0].label, tests[0].result]
	actions.tests.blood.summary = tests[0].label
	actions.tests.blood["visual_pool_id"] = str(examination_cg_by_test.get(tests[0].id, ""))
	actions.tests.imaging.label = tests[1].label
	actions.tests.imaging.response = "“The result further supports the current working diagnosis.”" if english else "「%s」" % tests[1].result
	actions.tests.imaging.notes[0].text = "%s: result reviewed" % tests[1].label if english else "%s：%s" % [tests[1].label, tests[1].result]
	actions.tests.imaging.summary = tests[1].label
	actions.tests.imaging["visual_pool_id"] = str(examination_cg_by_test.get(tests[1].id, ""))
	var additional_tests: Array = tests.slice(2)
	actions.tests.extra.label = "Additional testing" if english else "追加检查"
	actions.tests.extra.response = "“The additional study does not change the current assessment.”" if english else ("「%s」" % (additional_tests[0].result if not additional_tests.is_empty() else "没有发现新的决定性线索。"))
	actions.tests.extra.notes[0].text = "Additional testing provided no decisive new finding." if english else ("；".join(additional_tests.map(func(test: Dictionary): return "%s：%s" % [test.label, test.result])) if not additional_tests.is_empty() else "追加检查未提供新线索。")
	var additional_visual_pool := ""
	for test in additional_tests:
		if examination_cg_by_test.has(test.id):
			additional_visual_pool = examination_cg_by_test[test.id]
			break
	actions.tests.extra["visual_pool_id"] = additional_visual_pool
	actions.diagnosis.diagnose_gastro.label = str(differentials[0])
	actions.diagnosis.diagnose_gastro.response = "“The current evidence does not support that conclusion. Review the key results.”" if english else "「现有检查还不能支持这个判断，再看一遍关键结果。」"
	actions.diagnosis.diagnose_appendix.label = template.title if english else template.diagnosis
	actions.diagnosis.diagnose_appendix.response = "“That fits the available evidence. Explain the admission and surgical plan to the patient.”" if english else "「与现有线索吻合。和患者说明住院及手术安排吧。」"
	actions.diagnosis.diagnose_appendix.diagnosis = template.id
	var diagnosis_label: String = str(template.title if english else template.diagnosis)
	actions.diagnosis.diagnose_appendix.notes[0].text = ("Diagnosis: %s. Admit for the corresponding surgical treatment." if english else "诊断：%s。拟收住院接受相应手术治疗。") % diagnosis_label
	actions.diagnosis.diagnose_appendix.summary = ("Diagnosis: %s" if english else "诊断：%s") % diagnosis_label
	actions.diagnosis.diagnose_observe.label = str(differentials[1]) if differentials.size() > 1 else ("No further treatment" if english else "无需进一步处理")
	actions.diagnosis.diagnose_observe.response = "“That conclusion does not explain all of the test results.”" if english else "「这个判断无法解释全部检查结果。」"
	stages.plan.prompt = patient_reaction_line(patient_id, "hospitalization_question", "“So I need to be admitted for surgery?”" if english else "「所以，我需要住院接受手术吗？」")
	actions.plan.explain.response = patient_reaction_line(patient_id, "hospitalization_response", "“I understand. Please tell me what I need to prepare next.”" if english else "「明白了，请告诉我接下来要准备什么。」")
	var shock_reaction := first_surgery_diagnosis_reaction(patient_id, str(template.get("surgery_id", "")), diagnosis_shock_state, include_seen_diagnosis_shocks)
	if not shock_reaction.is_empty():
		actions.plan.explain.response = diagnosis_shock_text(shock_reaction)
		result["first_surgery_diagnosis_shock_variant_id"] = str(shock_reaction.id)
	actions.plan.explain.notes[0].text = ("Explained %s and the corresponding surgical plan." if english else "已向患者解释%s及相应手术安排。") % diagnosis_label
	actions.plan.admit.notes[0].text = ("Admitted for surgical treatment of %s." if english else "已收住院，准备进行与%s相应的手术治疗。") % diagnosis_label
	return result

func apply_clinic_action(id: String) -> bool:
	if not visits.has(active_id):
		return false
	var visit = visits[active_id]
	if not visit.apply(id):
		return false
	if id in ["diagnose_gastro", "diagnose_observe"] and visit.stage_id == "diagnosis":
		visit.diagnosis_feedback_actor_id = resolve_outpatient_support_actor()
	elif id == "diagnose_appendix":
		var support_id := resolve_outpatient_support_actor()
		if not staff_record(support_id).get("personal_nurse", {}).get("dialogue", {}).get("diagnosis_correct_reply", []).is_empty():
			visit.diagnosis_feedback_actor_id = support_id
	if id == "explain":
		var variant_id := str(visit.definition.get("first_surgery_diagnosis_shock_variant_id", ""))
		if not variant_id.is_empty():
			first_surgery_diagnosis_shock_state[str(visit.definition.patient_id)] = {
				"first_surgery_diagnosis_shock_seen": true,
				"first_surgery_diagnosis_shock_variant_id": variant_id,
			}
	if id in ["authoritative_full_undress", "threaten_full_undress"]:
		var support_actor := resolve_outpatient_support_actor()
		if support_actor == "nurse_yui":
			increment_character_progress_counter(support_actor, "outpatient_forced_undress")
	return true

func open_visit(id: String) -> RefCounted:
	if not active_staff_patient.is_empty():
		last_error = "Finish the staff patient's case first." if patient_content_locale() == "en" else "请先完成医护患者的手术流程。"
		return null
	if special_event_in_progress():
		last_error = "特殊活动进行中，不能开始普通诊疗。"
		return null
	if not definitions.has(id):
		return null
	if not visits.has(id) and outpatient_closed():
		last_error = "今天的会诊已经结束了。"
		return null
	if not visits.has(id) and is_hospital_closed_day():
		last_error = "%s，普通门诊休诊；病房与急诊仍照常运行。" % calendar_day_label()
		return null
	if patient_referrals.has(definitions[id].patient_id):
		last_error = "这名患者已经转诊给其他医生。"
		return null
	active_id = id
	active_mode = "encounter"
	if not visits.has(id):
		visits[id] = Encounter.new(definitions[id])
	return visits[id]

func elapsed() -> int:
	var total := archived_clinical_minutes
	for visit in visits.values():
		total += visit.minutes
	for preparation in preops.values():
		total += preparation.minutes
	for event in time_log:
		var definition: Dictionary = time_event_definitions.get(event.id, {})
		total += int(definition.get("minutes", 0))
	for event in character_events.values():
		if event.completed:
			total += int(event.definition.minutes)
	return maxi(0, total + story_time_advance_minutes - discarded_overtime_minutes)

func current_absolute_clock() -> int:
	return int(schedule_at(elapsed()).absolute_clock)

func outpatient_closed() -> bool:
	return not is_hospital_closed_day() and current_absolute_clock() >= OUTPATIENT_CLOSE_MINUTE

func unresolved_admitted_patient_exists() -> bool:
	if not active_staff_patient.is_empty():
		return true
	for visit in visits.values():
		var patient_id := str(visit.definition.patient_id)
		if visit.admitted and not completed_patient(patient_id):
			return true
	return false

func can_end_workday() -> bool:
	last_error = ""
	if not active_free_h_departure.is_empty() or not active_after_work_walk.is_empty():
		return false
	if is_hospital_closed_day():
		last_error = "休息日请使用星期日安排结束当天。"
		return false
	if current_absolute_clock() < OUTPATIENT_CLOSE_MINUTE:
		last_error = "16:00以后才能提前结束今天的工作。"
		return false
	if active_encounter_in_progress():
		last_error = "正在接诊患者，不能离开。"
		return false
	if not active_preop_id.is_empty() and preops.has(active_preop_id):
		last_error = "患者仍在连续的术前与手术流程中，不能离开。"
		return false
	if special_event_in_progress() or not active_character_event_id.is_empty() or not active_micro_event_id.is_empty():
		last_error = "当前剧情尚未结束，不能离开。"
		return false
	if unresolved_admitted_patient_exists():
		last_error = "还有已接诊的患者需要处理。"
		return false
	return true

func advance_story_to_future_day(day_offset: int, absolute_clock: int) -> void:
	advance_story_to_day(day_number() + maxi(1, day_offset), absolute_clock)

func advance_story_to_day(target_day: int, absolute_clock: int) -> void:
	var current_total := elapsed()
	var target_day_index := maxi(0, target_day - 1)
	var target_shift_minute := clampi(absolute_clock - SHIFT_START_MINUTE, 0, SHIFT_MINUTES - 1)
	var target_total := target_day_index * SHIFT_MINUTES + target_shift_minute
	story_time_advance_minutes += maxi(0, target_total - current_total)
	expire_free_h_booking()

func current_workday() -> int:
	if not active_free_h_departure.is_empty():
		return int(active_free_h_departure.workday)
	return pending_day_exit_workday if pending_day_exit_workday > 0 else day_number()

func expire_free_h_booking() -> void:
	if active_free_h_departure.is_empty() and not free_h_booking.is_empty() and int(free_h_booking.get("workday", 0)) != current_workday():
		free_h_booking.clear()

func free_h_unlocked(actor_id: String) -> bool:
	var config := FreeHRegistry.definition(actor_id)
	if config.is_empty() or not staff_is_met(actor_id):
		return false
	var person: Dictionary = {}
	for candidate in staff:
		if str(candidate.id) == actor_id:
			person = candidate
	var flags: Array = person.get("flags", [])
	if int(person.get("age", 0)) < 18 or "professional_friendship_only" in flags or "relationship_progression_locked" in flags:
		return false
	return character_event_done(str(config.completion_event)) and story_flag(str(config.completion_flag)) and relation_for(actor_id).get("unlocked_benefits", []).has("unlock_intimacy_events")

func free_h_known_conflict() -> bool:
	for definition in character_event_definitions.values():
		if character_event_trigger_mode(definition) == "after_work" and character_event_available(definition):
			return true
	return false

func can_book_free_h(actor_id: String, location_id: String) -> bool:
	if is_hospital_closed_day() or pending_day_exit_workday > 0 or not can_save_progress() or not free_h_unlocked(actor_id):
		return false
	if actor_id not in staff_present_at(location_id) or free_h_known_conflict():
		return false
	return not FreeHRegistry.load_bundle(actor_id).has("error")

func book_free_h(actor_id: String, location_id: String, replace_actor_id: String = "") -> bool:
	expire_free_h_booking()
	if not can_book_free_h(actor_id, location_id):
		return false
	var previous_actor := str(free_h_booking.get("actor_id", ""))
	# Compare-and-replace protects confirmations made before another selection.
	if not previous_actor.is_empty() and previous_actor != actor_id and previous_actor != replace_actor_id:
		return false
	free_h_booking = {"workday": current_workday(), "actor_id": actor_id}
	return true

func cancel_free_h_booking() -> bool:
	if not active_free_h_departure.is_empty() or free_h_booking.is_empty():
		return false
	free_h_booking.clear()
	return true

func claim_free_h_departure(workday: int, departure_clock: int, advance_day_on_finish: bool) -> bool:
	if not active_free_h_departure.is_empty() or not active_after_work_walk.is_empty() or free_h_booking.is_empty():
		return false
	if int(free_h_booking.workday) != workday or is_hospital_closed_day(workday):
		return false
	if active_encounter_in_progress() or not active_preop_id.is_empty() or unresolved_admitted_patient_exists() or special_event_in_progress() or not active_character_event_id.is_empty() or not active_micro_event_id.is_empty():
		return false
	if departure_clock < OUTPATIENT_CLOSE_MINUTE or not free_h_unlocked(str(free_h_booking.actor_id)):
		return false
	if sayaka_lv4_callback_due(workday, departure_clock) or not next_after_work_character_event().is_empty():
		return false
	if FreeHRegistry.load_bundle(str(free_h_booking.actor_id)).has("error"):
		return false
	active_free_h_departure = {"actor_id": str(free_h_booking.actor_id), "workday": workday, "clock": departure_clock, "advance_day_on_finish": advance_day_on_finish}
	active_mode = "free_h"
	return true

func finish_free_h_departure() -> Dictionary:
	if active_free_h_departure.is_empty():
		return {}
	var completed := active_free_h_departure.duplicate(true)
	active_free_h_departure.clear()
	free_h_booking.clear()
	active_mode = "encounter"
	clear_pending_departure_context()
	# Target-day advancement is idempotent even if overtime reserved tomorrow.
	advance_story_to_day(int(completed.workday) + 1, SHIFT_START_MINUTE)
	return completed

func fresh_relationships() -> Dictionary:
	var result := {}
	for relation in relationship_definitions:
		var state: Dictionary = relation.duplicate(true)
		state["met"] = bool(state.get("met", false))
		state["level"] = clampi(int(state.get("level", 0)), 0, relationship_max_level(str(relation.target_id)))
		state["route"] = str(state.get("route", "colleague"))
		state["rank_history"] = state.get("rank_history", []).duplicate()
		state["unlocked_benefits"] = state.get("unlocked_benefits", []).duplicate()
		result[relation.target_id] = state
	return result

func relation_for(actor_id: String) -> Dictionary:
	return relationships.get(actor_id, {})

func staff_role_cg_reward_for(staff_id: String, role_id: String) -> Dictionary:
	for reward in staff_role_cg_definitions.values():
		if str(reward.staff_id) == staff_id and str(reward.role_id) == role_id:
			return reward
	return {}

func staff_role_cg_unlocked(reward_id: String) -> bool:
	if not staff_role_cg_definitions.has(reward_id):
		return false
	var reward: Dictionary = staff_role_cg_definitions[reward_id]
	return relation_for(str(reward.staff_id)).get("unlocked_benefits", []).has(reward_id)

func unlock_staff_role_cg(staff_id: String, role_id: String) -> Dictionary:
	var reward := staff_role_cg_reward_for(staff_id, role_id)
	if reward.is_empty():
		return {}
	var relation := relation_for(staff_id)
	if relation.is_empty() or relation.unlocked_benefits.has(reward.id):
		return {}
	relation.unlocked_benefits.append(reward.id)
	return reward

func meet_staff(actor_id: String) -> bool:
	var relation := relation_for(actor_id)
	if relation.is_empty():
		return false
	relation.met = true
	if actor_id == "nurse_hiroko":
		rumi_shiori_introduction_day()
	return true

# A durable fallback for saves that knew Hiroko before introduction dates existed.
func rumi_shiori_introduction_day() -> int:
	if not staff_is_met("nurse_hiroko"):
		return 0
	var anchor_day := 0
	var intro = character_events.get("intro_nurse_hiroko")
	if intro != null and intro.completed and int(intro.completed_day) > 0:
		anchor_day = int(intro.completed_day)
	if anchor_day == 0:
		anchor_day = character_progress_counter("nurse_hiroko", "joint_intro_anchor_day")
		if anchor_day == 0:
			anchor_day = day_number()
			increment_character_progress_counter("nurse_hiroko", "joint_intro_anchor_day", anchor_day)
	var next_day := anchor_day + 1
	while str(calendar_date(next_day).weekday_id) != "mon":
		next_day += 1
	return next_day

func rumi_shiori_introduction_due(for_day: int, clock: int) -> bool:
	var due_day := rumi_shiori_introduction_day()
	return due_day > 0 and for_day >= due_day and clock >= 540

func complete_introduction_cast(definition: Dictionary) -> void:
	for actor_id in definition.get("introduction_actor_ids", [definition.actor_id]):
		meet_staff(str(actor_id))
		var relation := relation_for(str(actor_id))
		if relation.is_empty():
			continue
		relation.flags.erase("introduction_pending")
		if not relation.event_history.has(definition.id):
			relation.event_history.append(definition.id)

func staff_is_met(actor_id: String) -> bool:
	return bool(relation_for(actor_id).get("met", false))

func known_staff_ids() -> Array[String]:
	var result: Array[String] = []
	for actor_id in relationships:
		if staff_can_join_surgery_team(actor_id):
			result.append(actor_id)
	return result

func staff_can_join_surgery_team(actor_id: String) -> bool:
	if actor_id == str(active_staff_patient.get("staff_id", "")):
		return false
	if not staff_is_met(actor_id):
		return false
	for person in staff:
		if str(person.id) != actor_id:
			continue
		if "team_unlock_requires_lv1" not in person.get("flags", []):
			return true
		var relation := relation_for(actor_id)
		return int(relation.get("level", 0)) >= 1 or relation.get("unlocked_benefits", []).has("unlock_%s_surgical_team" % actor_id.trim_prefix("doc_"))
	return false

func relationship_level(actor_id: String) -> int:
	return int(relation_for(actor_id).get("level", 0))

func character_progress_counter(actor_id: String, counter_id: String) -> int:
	var scope_id := actor_id if not actor_id.is_empty() else "global"
	return int(character_progress_counters.get(scope_id, {}).get(counter_id, 0))

func increment_character_progress_counter(actor_id: String, counter_id: String, amount: int = 1) -> int:
	if counter_id.is_empty() or amount <= 0:
		return character_progress_counter(actor_id, counter_id)
	var scope_id := actor_id if not actor_id.is_empty() else "global"
	if not character_progress_counters.has(scope_id):
		character_progress_counters[scope_id] = {}
	var counters: Dictionary = character_progress_counters[scope_id]
	counters[counter_id] = int(counters.get(counter_id, 0)) + amount
	return int(counters[counter_id])

func set_test_character_progress_counter(actor_id: String, counter_id: String, value: int) -> bool:
	if not OS.is_debug_build() or counter_id.is_empty() or value < 0:
		return false
	var scope_id := actor_id if not actor_id.is_empty() else "global"
	if not character_progress_counters.has(scope_id):
		character_progress_counters[scope_id] = {}
	character_progress_counters[scope_id][counter_id] = value
	return true

func relationship_max_level(actor_id: String) -> int:
	for person in staff:
		if str(person.get("id", "")) == actor_id:
			if "relationship_progression_locked" in person.get("flags", []):
				return 0
			return 3 if "professional_friendship_only" in person.get("flags", []) else RELATIONSHIP_MAX_LEVEL
	return RELATIONSHIP_MAX_LEVEL

func staff_record(actor_id: String) -> Dictionary:
	for person in staff:
		if str(person.get("id", "")) == actor_id:
			return person
	return {}

func adult_intimacy_profile(actor_id: String) -> Dictionary:
	var person := staff_record(actor_id)
	var profile: Variant = person.get("h_profile", {})
	return profile if profile is Dictionary and bool(profile.get("enabled", false)) else {}

func adult_intimacy_state(actor_id: String) -> Dictionary:
	if not adult_intimacy_unlocks.has(actor_id):
		adult_intimacy_unlocks[actor_id] = {
			"repeatable_h_unlocked": false,
			"unlocked_locations": [],
			"unlocked_outfits": [],
			"unlocked_special_cgs": [],
		}
	return adult_intimacy_unlocks[actor_id]

func unlock_repeatable_adult_intimacy(actor_id: String) -> bool:
	var profile := adult_intimacy_profile(actor_id)
	if profile.is_empty():
		return false
	var state := adult_intimacy_state(actor_id)
	state.repeatable_h_unlocked = true
	for location_id in profile.get("base_locations", []):
		if not state.unlocked_locations.has(str(location_id)):
			state.unlocked_locations.append(str(location_id))
	for outfit_id in profile.get("base_outfits", []):
		if not state.unlocked_outfits.has(str(outfit_id)):
			state.unlocked_outfits.append(str(outfit_id))
	return true

func unlock_adult_intimacy_location(actor_id: String, location_id: String) -> bool:
	var profile := adult_intimacy_profile(actor_id)
	if profile.is_empty() or not profile.get("opening_lines", {}).has(location_id):
		return false
	var locations: Array = adult_intimacy_state(actor_id).unlocked_locations
	if not locations.has(location_id):
		locations.append(location_id)
	return true

func unlock_adult_intimacy_outfit(actor_id: String, outfit_id: String) -> bool:
	var profile := adult_intimacy_profile(actor_id)
	if profile.is_empty() or not profile.get("outfit_portraits", {}).has(outfit_id):
		return false
	var outfits: Array = adult_intimacy_state(actor_id).unlocked_outfits
	if not outfits.has(outfit_id):
		outfits.append(outfit_id)
	return true

func unlock_adult_intimacy_cg(actor_id: String, cg_id: String) -> bool:
	var profile := adult_intimacy_profile(actor_id)
	if profile.is_empty() or not profile.get("special_cgs", []).any(func(entry: Variant): return entry is Dictionary and str(entry.get("id", "")) == cg_id):
		return false
	var unlocked: Array = adult_intimacy_state(actor_id).unlocked_special_cgs
	if not unlocked.has(cg_id):
		unlocked.append(cg_id)
	return true

func repeatable_adult_intimacy_available(actor_id: String) -> bool:
	if is_hospital_closed_day() or adult_intimacy_profile(actor_id).is_empty() or not staff_is_met(actor_id):
		return false
	if active_surgery_in_progress() or active_encounter_in_progress() or special_event_in_progress() or not active_character_event_id.is_empty() or not active_micro_event_id.is_empty() or active_adult_intimacy != null:
		return false
	return bool(adult_intimacy_state(actor_id).get("repeatable_h_unlocked", false))

func adult_intimacy_location_options(actor_id: String) -> Array[String]:
	var result: Array[String] = []
	var profile := adult_intimacy_profile(actor_id)
	for location_id in adult_intimacy_state(actor_id).get("unlocked_locations", []):
		if profile.get("opening_lines", {}).has(str(location_id)):
			result.append(str(location_id))
	return result

func adult_intimacy_outfit_options(actor_id: String) -> Array[String]:
	var result: Array[String] = []
	var profile := adult_intimacy_profile(actor_id)
	for outfit_id in adult_intimacy_state(actor_id).get("unlocked_outfits", []):
		if profile.get("outfit_portraits", {}).has(str(outfit_id)):
			result.append(str(outfit_id))
	return result

func start_repeatable_adult_intimacy(actor_id: String, location_id: String, outfit_id: String) -> RefCounted:
	last_error = "下班后的亲密互动当前无法开始。"
	if not repeatable_adult_intimacy_available(actor_id) or location_id not in adult_intimacy_location_options(actor_id) or outfit_id not in adult_intimacy_outfit_options(actor_id):
		return null
	var state := adult_intimacy_state(actor_id)
	active_adult_intimacy = AdultIntimacySession.new(actor_id, adult_intimacy_profile(actor_id), location_id, outfit_id, false, {}, state.unlocked_special_cgs)
	if active_adult_intimacy.phase == "invalid":
		active_adult_intimacy = null
		return null
	adult_intimacy_return_mode = "encounter"
	active_mode = "adult_intimacy"
	last_error = ""
	return active_adult_intimacy

func start_milestone_adult_intimacy(actor_id: String, location_id: String, outfit_id: String, cg_override: Dictionary = {}) -> RefCounted:
	last_error = "首次亲密事件当前无法开始。"
	if active_adult_intimacy != null or adult_intimacy_profile(actor_id).is_empty():
		return null
	var return_mode := active_mode
	var state := adult_intimacy_state(actor_id)
	active_adult_intimacy = AdultIntimacySession.new(actor_id, adult_intimacy_profile(actor_id), location_id, outfit_id, true, cg_override, state.unlocked_special_cgs)
	if active_adult_intimacy.phase == "invalid":
		active_adult_intimacy = null
		return null
	adult_intimacy_return_mode = return_mode
	active_mode = "adult_intimacy"
	last_error = ""
	return active_adult_intimacy

func finish_adult_intimacy(consumes_day: bool = true) -> bool:
	if active_adult_intimacy == null or not active_adult_intimacy.completed():
		return false
	active_adult_intimacy = null
	active_mode = adult_intimacy_return_mode
	adult_intimacy_return_mode = "encounter"
	if consumes_day:
		advance_story_to_future_day(1, SHIFT_START_MINUTE)
	return true

func next_rank_threshold(actor_id: String) -> int:
	var slot := next_rank_slot(actor_id)
	return 100 if slot.is_empty() else int(slot.get("min_familiarity", 100))

func rank_ready(actor_id: String) -> bool:
	if not staff_is_met(actor_id) or relationship_level(actor_id) >= relationship_max_level(actor_id):
		return false
	for definition in character_event_definitions.values():
		if str(definition.get("actor_id", "")) == actor_id and str(definition.get("category", "")) in ["bond", "rank_up"] and character_event_available(definition):
			return true
	return false

func next_rank_slot(actor_id: String) -> Dictionary:
	var relation := relation_for(actor_id)
	var target := int(relation.get("level", 0)) + 1
	if target > relationship_max_level(actor_id):
		return {}
	for slot in relation.get("rank_slots", []):
		if int(slot.get("target_level", 0)) == target:
			return slot
	return {}

func relationship_rank_slot(actor_id: String, target_level: int) -> Dictionary:
	for slot in relation_for(actor_id).get("rank_slots", []):
		if int(slot.get("target_level", 0)) == target_level:
			return slot
	return {}

func relationship_rank_gate_evaluation(actor_id: String, target_level: int) -> Dictionary:
	var relation := relation_for(actor_id)
	var slot := relationship_rank_slot(actor_id, target_level)
	var result := {
		"met": false,
		"familiarity_current": int(relation.get("familiarity", 0)),
		"familiarity_required": int(slot.get("min_familiarity", 0)),
		"familiarity_met": false,
		"cooldown_current": 0,
		"cooldown_required": int(slot.get("cooldown_days", Progression.RELATIONSHIP_DEFAULT_COOLDOWN_DAYS)),
		"cooldown_remaining": 0,
		"cooldown_met": false,
		"requirements": {"met": false, "results": [], "unmet": []},
	}
	if relation.is_empty() or slot.is_empty() or target_level != int(relation.get("level", 0)) + 1:
		return result
	result.familiarity_met = int(result.familiarity_current) >= int(result.familiarity_required)
	var latest_milestone_day := 0
	for event_id in relation.get("rank_history", []):
		var completed_event = character_events.get(str(event_id))
		if completed_event != null:
			latest_milestone_day = maxi(latest_milestone_day, int(completed_event.completed_day))
		else:
			latest_milestone_day = maxi(latest_milestone_day, int(special_event_completion_days.get(str(event_id), 0)))
	var cooldown_days := int(result.cooldown_required)
	if latest_milestone_day <= 0 and target_level > 1:
		var previous_slot := relationship_rank_slot(actor_id, target_level - 1)
		var previous_event_id := str(previous_slot.get("event_id", ""))
		var previous_event = character_events.get(previous_event_id)
		if previous_event != null:
			latest_milestone_day = int(previous_event.completed_day)
		else:
			latest_milestone_day = int(special_event_completion_days.get(previous_event_id, 0))
	result.cooldown_current = maxi(0, day_number() - latest_milestone_day) if latest_milestone_day > 0 else cooldown_days
	result.cooldown_remaining = maxi(0, cooldown_days - int(result.cooldown_current))
	result.cooldown_met = latest_milestone_day <= 0 or int(result.cooldown_remaining) == 0
	var rank_requirements: Array = slot.get("special_requirements", []).duplicate(true)
	var person := staff_record(actor_id)
	if target_level >= 5 and actor_id != "doc_sayaka" and int(person.get("age", 0)) >= 18:
		rank_requirements.append({"type": "story_flag", "flag": "staff_as_patient_program_authorized"})
	result.requirements = requirements_evaluation(rank_requirements, {"actor_id": actor_id})
	result.met = result.familiarity_met and result.cooldown_met and bool(result.requirements.met)
	return result

func relationship_progress(actor_id: String) -> Dictionary:
	var relation := relation_for(actor_id)
	var current_level := int(relation.get("level", 0))
	var maximum_level := relationship_max_level(actor_id)
	var progress := {
		"known": bool(relation.get("met", false)),
		"current_level": current_level,
		"maximum_level": maximum_level,
		"complete": current_level >= maximum_level,
		"target_level": mini(current_level + 1, maximum_level),
		"has_slot": false,
		"content_status": "unavailable",
		"event_authored": false,
		"slot": {},
		"gate": {},
	}
	if not bool(progress.known) or bool(progress.complete):
		return progress
	var slot := relationship_rank_slot(actor_id, int(progress.target_level))
	if slot.is_empty():
		return progress
	var event_id := str(slot.get("event_id", ""))
	progress.has_slot = true
	progress.content_status = str(slot.get("content_status", "unavailable"))
	progress.event_authored = progress.content_status == "authored" and not event_id.is_empty() and (character_event_definitions.has(event_id) or special_event_definitions.has(event_id))
	progress.slot = slot
	progress.gate = relationship_rank_gate_evaluation(actor_id, int(progress.target_level))
	return progress

func relationship_rank_gate_met(actor_id: String, target_level: int) -> bool:
	return bool(relationship_rank_gate_evaluation(actor_id, target_level).met)

func relationship_rank_gate_applies_to_event(actor_id: String, target_level: int, event_id: String) -> bool:
	var slot := relationship_rank_slot(actor_id, target_level)
	if slot.is_empty():
		return false
	var gate_event_id := str(slot.get("gate_event_id", slot.get("event_id", "")))
	return not gate_event_id.is_empty() and gate_event_id == event_id

func add_familiarity(actor_id: String, amount: int) -> void:
	var relation := relation_for(actor_id)
	if relation.is_empty():
		return
	add_familiarity_to(relation, amount)

func add_familiarity_to(relation: Dictionary, amount: int) -> void:
	relation.familiarity = clampi(int(relation.get("familiarity", 0)) + amount, 0, 100)

func familiarity_rule_input(actor_id: String, operation: Dictionary) -> int:
	match str(operation.get("input", "player_attribute")):
		"player_attribute":
			return int(player_attributes().get(str(operation.get("attribute", "")), 0))
		"relationship_level":
			return relationship_level(actor_id)
		"progress_counter":
			return character_progress_counter(str(operation.get("actor_id", actor_id)), str(operation.get("counter_id", "")))
	return 0

func familiarity_gain_multiplier(actor_id: String, source: String = "standard") -> float:
	var person := staff_record(actor_id)
	if person.is_empty():
		return 1.0
	var rules: Dictionary = person.get("familiarity_rules", {})
	if rules.is_empty():
		# Compatibility for profiles authored before familiarity_rules existed.
		var legacy_multiplier := maxf(0.0, float(person.get("familiarity_gain_multiplier", 1.0)))
		var attributes := player_attributes()
		for affinity in person.get("familiarity_affinities", []):
			var attribute := str(affinity.get("attribute", ""))
			var value := int(attributes.get(attribute, 0))
			if value >= int(affinity.get("minimum", -2147483648)) and value <= int(affinity.get("maximum", 2147483647)):
				legacy_multiplier *= maxf(0.0, float(affinity.get("multiplier", 1.0)))
		return legacy_multiplier
	var multiplier := float(rules.get("base", 1.0))
	for raw_operation in rules.get("operations", []):
		var operation: Dictionary = raw_operation
		var input_value := familiarity_rule_input(actor_id, operation)
		var band_found := false
		var band_value := 0.0
		for raw_band in operation.get("bands", []):
			var band: Dictionary = raw_band
			if input_value < int(band.get("minimum", -2147483648)) or input_value > int(band.get("maximum", 2147483647)):
				continue
			band_found = true
			band_value = float(band.get("value", 0.0))
			break
		if not band_found:
			continue
		match str(operation.get("mode", "replace")):
			"add":
				multiplier += band_value
			"multiply":
				multiplier *= band_value
			_:
				multiplier = band_value
	var limits: Dictionary = rules.get("clamp", {})
	if limits.has("minimum"):
		multiplier = maxf(multiplier, float(limits.minimum))
	if limits.has("maximum"):
		multiplier = minf(multiplier, float(limits.maximum))
	return maxf(0.0, multiplier)

func familiarity_reward(actor_id: String, base_amount: int, source: String = "standard") -> int:
	var person := staff_record(actor_id)
	var rules: Dictionary = person.get("familiarity_rules", {})
	var overrides: Dictionary = rules.get("source_overrides", {})
	var source_override: Dictionary = overrides.get(source, {})
	if source_override.has("fixed_reward"):
		return maxi(0, int(source_override.fixed_reward))
	var reward := maxi(0, roundi(float(base_amount) * familiarity_gain_multiplier(actor_id, source)))
	if source_override.has("minimum_reward"):
		reward = maxi(reward, int(source_override.minimum_reward))
	if source_override.has("maximum_reward"):
		reward = mini(reward, int(source_override.maximum_reward))
	return reward

func surgery_familiarity_reward(actor_id: String, case_tier: String = "routine") -> int:
	var base := int(Progression.FAMILIARITY_CASE_BASE.get(case_tier, Progression.FAMILIARITY_CASE_BASE.routine))
	return familiarity_reward(actor_id, base, "surgery")

func date_location_familiarity_multiplier(actor_id: String, location_id: String) -> float:
	var location: Dictionary = date_location_definitions.get(location_id, {})
	if location.is_empty() or location_id == "hotel" or bool(location.get("story_only", false)):
		return 1.0
	var profile: Dictionary = date_profile_definitions.get(actor_id, {})
	# Dislikes are reserved for future design and never reduce rewards.
	return 1.2 if location_id in profile.get("preferred_locations", []) else 1.0

func date_familiarity_reward(actor_id: String, location_id: String = "") -> int:
	var normal_reward := familiarity_reward(actor_id, Progression.DATE_FAMILIARITY_BASE, "date")
	return roundi(float(normal_reward) * date_location_familiarity_multiplier(actor_id, location_id))

func relationship_event_familiarity_reward(actor_id: String, target_level: int) -> int:
	var base := int(Progression.RELATIONSHIP_EVENT_FAMILIARITY_BASE.get(target_level, 0))
	return familiarity_reward(actor_id, base, "relationship_event")

func award_case_familiarity(participants: Dictionary, case_tier: String = "routine") -> void:
	var awarded: Dictionary = {}
	for value in participants.values():
		var actor_id := str(value)
		if actor_id.is_empty() or awarded.has(actor_id) or not staff_is_met(actor_id):
			continue
		awarded[actor_id] = true
		add_familiarity(actor_id, surgery_familiarity_reward(actor_id, case_tier))

func award_surgery_team_familiarity(team: Dictionary, case_tier: String = "routine") -> void:
	award_case_familiarity(team, case_tier)

func complete_rank_up(actor_id: String, event_id: String, target_level: int, benefit_id: String = "") -> void:
	var relation := relation_for(actor_id)
	if relation.is_empty() or target_level != int(relation.level) + 1 or target_level > relationship_max_level(actor_id):
		return
	relation.level = clampi(target_level, 0, relationship_max_level(actor_id))
	if not relation.rank_history.has(event_id):
		relation.rank_history.append(event_id)
	if not benefit_id.is_empty() and not relation.unlocked_benefits.has(benefit_id):
		relation.unlocked_benefits.append(benefit_id)

func staff_present_at(location_id: String) -> Array[String]:
	if is_hospital_closed_day() and location_id in ["clinic", "or"]:
		return []
	var result: Array[String] = []
	# Fixed and random schedules describe where known colleagues can be found.
	# Unmet staff stay hidden until an available introduction places them at its
	# authored location, preventing future colleagues from appearing as anonymous
	# roster entries before their first scene.
	var eligible_actor_ids: Array[String] = []
	var sunday_duty: Array[String] = []
	if is_sunday():
		sunday_duty = sunday_on_duty_staff()
	for person in staff:
		var actor_id := str(person.id)
		if actor_id == str(active_staff_patient.get("staff_id", "")):
			continue
		if staff_is_met(actor_id) and (not is_sunday() or actor_id in sunday_duty):
			eligible_actor_ids.append(actor_id)
	if presence_resolver != null:
		result = presence_resolver.staff_at(location_id, day_number(), int(schedule_at(elapsed()).absolute_clock), eligible_actor_ids)
	# A currently available personal event also places its actor at the event site.
	for event in character_events_at(location_id):
		if event.actor_id not in result and str(event.actor_id) != str(active_staff_patient.get("staff_id", "")):
			result.append(event.actor_id)
	return result

func micro_event_done(id: String) -> bool:
	return micro_events.has(id) and micro_events[id].completed

func micro_events_triggered_on_day(day: int) -> int:
	var total := 0
	for event in micro_events.values():
		if int(event.trigger_day) == day:
			total += 1
	return total

func actor_had_micro_event_on_day(actor_id: String, day: int) -> bool:
	for event in micro_events.values():
		if event.definition.actor_id == actor_id and int(event.trigger_day) == day:
			return true
	return false

func micro_event_available(definition: Dictionary, context: String, location_id: String) -> bool:
	if micro_events.has(definition.id) or definition.context != context or definition.location_id != location_id:
		return false
	if not staff_is_met(str(definition.actor_id)):
		return false
	# Location storylets must use the same roster as the visible location UI.
	# The selector reuses this check, so a stale button cannot summon an absent actor.
	if context == "location_visit" and str(definition.actor_id) not in staff_present_at(location_id):
		return false
	var today := day_number()
	if micro_events_triggered_on_day(today) >= 2 or actor_had_micro_event_on_day(definition.actor_id, today):
		return false
	var clock: int = int(schedule_at(elapsed()).absolute_clock)
	if clock < int(definition.time_start) or clock > int(definition.time_end):
		return false
	var relation: Dictionary = relation_for(definition.actor_id)
	if relation.is_empty() or int(relation.get("familiarity", 0)) < int(definition.min_familiarity):
		return false
	if context == "after_surgery":
		if active_preop_id.is_empty() or not preops.has(active_preop_id):
			return false
		var team: Dictionary = preops[active_preop_id].team
		if definition.actor_id not in team.values():
			return false
	return true

func select_micro_event(context: String, location_id: String) -> RefCounted:
	if special_event_in_progress():
		return null
	if not active_micro_event_id.is_empty() and micro_events.has(active_micro_event_id):
		var active_event = micro_events[active_micro_event_id]
		if active_event.definition.context == context and active_event.definition.location_id == location_id:
			return active_event
		return null
	var candidates: Array = []
	var total_weight := 0
	for definition in micro_event_definitions.values():
		if micro_event_available(definition, context, location_id):
			candidates.append(definition)
			total_weight += maxi(1, int(definition.weight))
	if candidates.is_empty():
		return null
	var roll := randi_range(1, total_weight)
	var selected: Dictionary = candidates[0]
	for candidate in candidates:
		roll -= maxi(1, int(candidate.weight))
		if roll <= 0:
			selected = candidate
			break
	var event = MicroEvent.new(selected, day_number())
	micro_events[selected.id] = event
	micro_event_order.append(selected.id)
	active_micro_event_id = selected.id
	active_mode = "micro_event"
	return event

func has_micro_event(context: String, location_id: String) -> bool:
	for definition in micro_event_definitions.values():
		if micro_event_available(definition, context, location_id):
			return true
	return false

func apply_micro_event_choice(relation: Dictionary, choice: Dictionary) -> void:
	relation.affection = clampi(int(relation.get("affection", 0)) + int(choice.effects.get("affection", 0)), 0, 100)
	add_familiarity_to(relation, int(choice.effects.get("familiarity", 0)))
	var memory_tag: Variant = choice.get("memory_tag")
	if memory_tag is String and not memory_tag.is_empty() and not relation.flags.has(memory_tag):
		relation.flags.append(memory_tag)

func choose_micro_event(choice_id: String) -> bool:
	if active_micro_event_id.is_empty() or not micro_events.has(active_micro_event_id):
		return false
	var event = micro_events[active_micro_event_id]
	if not event.apply(choice_id):
		return false
	apply_micro_event_choice(relationships[event.definition.actor_id], event.last_choice)
	return true

func finish_micro_event() -> void:
	active_micro_event_id = ""
	if not active_preop_id.is_empty():
		active_mode = "preop"
	else:
		active_mode = "encounter"

func character_event_rank_up_allowed(definition: Dictionary, relation: Dictionary) -> bool:
	var required_flags: Array = definition.get("rank_up_required_flags", [])
	return required_flags.all(func(flag: Variant): return relation.get("flags", []).has(str(flag)))

func character_event_done(id: String) -> bool:
	if not character_events.has(id) or not character_events[id].completed:
		return false
	return true

func character_event_trigger_mode(definition: Dictionary) -> String:
	var authored := str(definition.get("trigger_mode", ""))
	if authored in ["day_start", "location", "preop_stage", "sunday", "after_work"]:
		return authored
	# Compatibility for authored content predating explicit trigger modes.
	if bool(definition.get("consumes_sunday", false)):
		return "sunday"
	if not str(definition.get("preop_stage_id", "")).is_empty():
		return "preop_stage"
	if bool(definition.get("mandatory", false)):
		return "day_start"
	return "location"

func day_start_character_event_consumed(for_day: int = -1) -> bool:
	var selected_day := day_number() if for_day < 1 else for_day
	return story_flag("__day_start_character_event__%s" % selected_day)

func consume_day_start_character_event() -> void:
	set_story_flag("__day_start_character_event__%s" % day_number(), true)

func character_event_available(definition: Dictionary) -> bool:
	if not active_staff_patient.is_empty() and str(definition.get("actor_id", "")) == str(active_staff_patient.staff_id):
		return false
	var event_id := str(definition.get("id", ""))
	if event_id == "intro_ishigami_nurse_manager":
		if not staff_is_met("doc_asuka") or staff_is_met("nurse_ishigami"):
			return false
		var met_nurses := 0
		for person in staff:
			var actor_id := str(person.get("id", ""))
			# Count registered nursing staff at Lv0, including ordinary interns.
			# Visiting researchers and non-nursing NPCs are not nursing staff.
			if actor_id != "nurse_ishigami" and str(person.get("profession", "")) == "nurse" and str(person.get("team_category", "")) == "nurse" and staff_is_met(actor_id):
				met_nurses += 1
		if met_nurses < 6:
			return false
		if active_surgery_in_progress() or not active_special_event_id.is_empty() or not active_character_event_id.is_empty() or not active_micro_event_id.is_empty() or not active_preop_id.is_empty() or active_encounter_in_progress():
			return false
	# Megumi's internship waits indefinitely for the chief nurse's introduction.
	# The calendar minimum and day-start queue are authored on the event itself.
	if event_id == "intro_kariya_megumi_june":
		if not staff_is_met("nurse_ishigami") or current_absolute_clock() < 540:
			return false
		if active_surgery_in_progress() or not active_special_event_id.is_empty() or not active_character_event_id.is_empty() or not active_micro_event_id.is_empty() or not active_preop_id.is_empty() or active_encounter_in_progress():
			return false
	# Persist the operation boundary so an overdue chain cannot play several
	# corridor encounters after the same operation, including after a reload.
	if event_id in ["itsumi_lv0_c_corridor", "itsumi_lv0_d_instrument_tray", "itsumi_lv0_e_hiroko_invitation"]:
		if story_flag("itsumi_lv0_postop_seen:%s" % completed_surgeries_total):
			return false
	var event_day := current_workday() if character_event_trigger_mode(definition) == "after_work" else day_number()
	if event_id == "intro_rumi_shiori_hiroko_monday_0900":
		if not rumi_shiori_introduction_due(event_day, current_absolute_clock()):
			return false
	if event_id == "sayaka_lv4_hospital_callback":
		var callback_day := day_number() if sayaka_lv4_callback_override_day < 1 else sayaka_lv4_callback_override_day
		var callback_clock := current_absolute_clock() if sayaka_lv4_callback_override_clock < 0 else sayaka_lv4_callback_override_clock
		return sayaka_lv4_callback_due(callback_day, callback_clock) and not character_event_done(event_id)
	var special_target := test_save_target_event_id()
	var character_target := test_save_target_character_event_id()
	if not special_target.is_empty() or (not character_target.is_empty() and character_target != str(definition.get("id", ""))):
		return false
	# Sunday dates are entered through the Sunday invitation flow.  Without this
	# guard they also appear as ordinary location events on weekdays whenever
	# their relationship requirements happen to be satisfied.
	if character_event_trigger_mode(definition) == "sunday" and (not is_sunday() or sunday_activity_done()):
		return false
	if test_save_event_waits_for_surgery(str(definition.get("id", ""))):
		return false
	if character_event_done(definition.id):
		return false
	var relation: Dictionary = relation_for(definition.actor_id)
	if relation.is_empty() or event_day < int(definition.conditions.min_day):
		return false
	if definition.conditions.has("max_day") and event_day > int(definition.conditions.max_day):
		return false
	if definition.category == "introduction" and bool(relation.get("met", false)) and not definition.has("introduction_actor_ids"):
		return false
	if definition.category != "introduction" and not bool(relation.get("met", false)) and not bool(definition.get("allow_unmet_actor", false)):
		return false
	if definition.category == "bond" and (int(relation.get("level", 0)) != 0 or int(definition.get("target_level", 1)) != 1):
		return false
	if definition.category == "rank_up" and int(definition.get("target_level", 1)) != int(relation.level) + 1:
		return false
	if relationship_rank_gate_applies_to_event(str(definition.actor_id), int(definition.get("target_level", 1)), str(definition.id)) and not relationship_rank_gate_met(str(definition.actor_id), int(definition.get("target_level", 1))):
		return false
	if definition.category in ["bond", "rank_up"] and not bool(definition.get("chain_followup", false)) and not relation.get("rank_history", []).is_empty():
		var milestone_gap := maxi(int(Progression.RELATIONSHIP_DEFAULT_COOLDOWN_DAYS), int(definition.conditions.get("days_after_required_events", 0)))
		var latest_milestone_day := 0
		for rank_event_id in relation.rank_history:
			var completed_event = character_events.get(str(rank_event_id))
			if completed_event != null:
				latest_milestone_day = maxi(latest_milestone_day, int(completed_event.completed_day))
		if latest_milestone_day > 0 and event_day < latest_milestone_day + milestone_gap:
			return false
	for metric in ["affection", "familiarity"]:
		if int(relation.get(metric, 0)) < int(definition.conditions.get("min_" + metric, 0)):
			return false
	for required in definition.conditions.required_events:
		if not character_event_done(required):
			return false
		# Required-event delays are authored explicitly. The default three-day
		# relationship cooldown applies only between completed rank milestones
		# through rank_history above; introductions and contextual prerequisites
		# are not rank milestones and must not silently add another delay.
		var required_gap_days := int(definition.conditions.get("days_after_required_events", 0))
		if required_gap_days > 0:
			var required_event = character_events.get(required)
			if required_event == null or int(required_event.completed_day) <= 0 or event_day < int(required_event.completed_day) + required_gap_days:
				return false
	if not requirements_met(definition.conditions.get("special_requirements", []), {"actor_id": str(definition.get("actor_id", ""))}):
		return false
	return true

func character_events_for(actor_id: String) -> Array:
	var result: Array = []
	for definition in character_event_definitions.values():
		if definition.actor_id == actor_id and character_event_available(definition):
			result.append(definition)
	result.sort_custom(func(a: Dictionary, b: Dictionary): return int(a.chapter) < int(b.chapter))
	return result

func character_events_at(location_id: String) -> Array:
	var result: Array = []
	if active_surgery_in_progress() or special_event_in_progress():
		return result
	if is_hospital_closed_day() and location_id in ["clinic", "or"]:
		return result
	var clock: int = int(schedule_at(elapsed()).absolute_clock)
	for definition in character_event_definitions.values():
		# Only location events belong to map entry. Day-start, Sunday and staged
		# events are owned by their dedicated schedulers.
		if character_event_trigger_mode(definition) != "location":
			continue
		if definition.location_id != location_id or not character_event_available(definition):
			continue
		if clock < int(definition.time_start) or clock > int(definition.time_end):
			continue
		result.append(definition)
	result.sort_custom(func(a: Dictionary, b: Dictionary):
		if int(a.priority) != int(b.priority):
			return int(a.priority) > int(b.priority)
		return a.id < b.id)
	return result

func next_character_event_at(location_id: String) -> Dictionary:
	var candidates := character_events_at(location_id)
	return {} if candidates.is_empty() else candidates[0]

func next_day_start_character_event() -> Dictionary:
	if active_surgery_in_progress() or special_event_in_progress() or is_sunday() or day_start_character_event_consumed():
		return {}
	var clock: int = int(schedule_at(elapsed()).absolute_clock)
	var result: Array = []
	for definition in character_event_definitions.values():
		if character_event_trigger_mode(definition) != "day_start" or not character_event_available(definition):
			continue
		if clock < int(definition.time_start) or clock > int(definition.time_end):
			continue
		result.append(definition)
	result.sort_custom(func(a: Dictionary, b: Dictionary):
		if int(a.priority) != int(b.priority):
			return int(a.priority) > int(b.priority)
		return str(a.id) < str(b.id))
	return {} if result.is_empty() else result[0]

func next_mandatory_character_event() -> Dictionary:
	# Compatibility for existing tests and callers while authored content moves
	# to explicit trigger_mode values.
	return next_day_start_character_event()

func next_character_event_for_preop_stage(stage_id: String) -> Dictionary:
	if active_surgery_in_progress():
		return {}
	var result: Array = []
	var clock: int = int(schedule_at(elapsed()).absolute_clock)
	for definition in character_event_definitions.values():
		if character_event_trigger_mode(definition) != "preop_stage" or str(definition.get("preop_stage_id", "")) != stage_id:
			continue
		if not character_event_available(definition):
			continue
		var required_flags: Array = definition.get("preop_required_flags", [])
		if not required_flags.is_empty():
			if active_preop_id.is_empty() or not preops.has(active_preop_id):
				continue
			var preparation = preops[active_preop_id]
			if required_flags.any(func(flag: Variant): return str(flag) not in preparation.flags):
				continue
		# A postoperative continuation follows its completed operation even if
		# that operation ran past the normal location-event time window.
		if stage_id != "post_surgery_return" and (clock < int(definition.time_start) or clock > int(definition.time_end)):
			continue
		result.append(definition)
	result.sort_custom(func(a: Dictionary, b: Dictionary):
		if int(a.priority) != int(b.priority):
			return int(a.priority) > int(b.priority)
		return a.id < b.id)
	return {} if result.is_empty() else result[0]

func next_character_event_for_active_preop() -> Dictionary:
	if active_preop_id.is_empty() or not preops.has(active_preop_id):
		return {}
	var preparation = preops[active_preop_id]
	return next_character_event_for_preop_stage(str(preparation.stage_id))

func next_sunday_character_event() -> Dictionary:
	if not is_sunday() or sunday_activity_done():
		return {}
	var candidate_ids := sunday_date_candidates()
	var result: Array = []
	for definition in character_event_definitions.values():
		if character_event_trigger_mode(definition) != "sunday":
			continue
		if not candidate_ids.has(str(definition.get("actor_id", ""))):
			continue
		if not character_event_available(definition):
			continue
		result.append(definition)
	result.sort_custom(func(a: Dictionary, b: Dictionary):
		if int(a.priority) != int(b.priority):
			return int(a.priority) > int(b.priority)
		return str(a.id) < str(b.id))
	return {} if result.is_empty() else result[0]

func next_after_work_character_event() -> Dictionary:
	if is_hospital_closed_day(current_workday()) or active_surgery_in_progress() or special_event_in_progress() or not active_character_event_id.is_empty() or not active_micro_event_id.is_empty():
		return {}
	var clock: int = int(display_schedule().absolute_clock)
	var result: Array = []
	for definition in character_event_definitions.values():
		if character_event_trigger_mode(definition) != "after_work" or not character_event_available(definition):
			continue
		if clock < int(definition.time_start) or clock > int(definition.time_end):
			continue
		result.append(definition)
	result.sort_custom(func(a: Dictionary, b: Dictionary):
		if int(a.priority) != int(b.priority):
			return int(a.priority) > int(b.priority)
		return str(a.id) < str(b.id))
	return {} if result.is_empty() else result[0]

func character_event_opening_node(definition: Dictionary) -> String:
	if str(definition.id) == "intro_rumi_shiori_hiroko_monday_0900":
		if current_absolute_clock() >= 720:
			return "rs0_0001_later"
		return "rs0_0001" if day_number() == rumi_shiori_introduction_day() else "rs0_0001_morning"
	var variants: Dictionary = definition.get("opening_variants", {})
	if variants.is_empty():
		return str(definition.get("start", ""))
	var present := staff_present_at(str(definition.get("location_id", "")))
	for actor_id in ["nurse_haru", "nurse_hiroko"]:

		if actor_id in present and variants.has(actor_id):
			return str(variants[actor_id])
	return str(variants.get("fallback", definition.get("start", "")))

func start_character_event(id: String) -> RefCounted:
	# Once the start command has been given, the operation is an uninterrupted
	# flow. Location introductions and other character events must never replace
	# the active surgical screen during a redraw or navigation callback.
	if active_surgery_in_progress() or special_event_in_progress():
		return null
	if not character_event_definitions.has(id):
		return null
	if character_event_done(id):
		return null
	if not character_events.has(id):
		var definition: Dictionary = character_event_definitions[id]
		if not character_event_available(definition):
			return null
		character_events[id] = CharacterEvent.new(definition)
		character_events[id].node_id = character_event_opening_node(definition)
		character_event_order.append(id)
	active_character_event_id = id
	active_mode = "character_event"
	if character_event_trigger_mode(character_event_definitions[id]) == "day_start":
		consume_day_start_character_event()
	return character_events[id]

func reserve_sunday_character_event(event_id: String) -> bool:
	if not is_sunday() or sunday_activity_done() or not character_event_definitions.has(event_id):
		return false
	var definition: Dictionary = character_event_definitions[event_id]
	if character_event_trigger_mode(definition) != "sunday" or not character_event_available(definition):
		return false
	sunday_history.append({"day": day_number(), "activity_id": "sayaka_lv4_date", "actor_id": "doc_sayaka", "location_id": "hotel"})
	return true

func settle_sayaka_lv4_hotel_event() -> bool:
	var relation := relation_for("doc_sayaka")
	if relation.is_empty() or int(relation.get("level", 0)) not in [3, 4]:
		return false
	if story_flag("sayaka_lv4_complete"):
		return false
	if int(relation.get("level", 0)) == 3:
		complete_rank_up("doc_sayaka", "sayaka_lv4_hotel_date", 4, "unlock_intimacy_events")
	elif not relation.get("rank_history", []).has("sayaka_lv4_hotel_date"):
		return false
	set_story_flag("sayaka_lv4_complete")
	set_story_flag("sayaka_first_h_complete")
	set_story_flag("sayaka_lv4_patient_joke_seed")
	set_story_flag("sayaka_lv4_next_morning_callback_pending")
	set_story_flag("sayaka_lv4_callback_target_day:%s" % (day_number() + 1))
	return true

func sayaka_lv4_callback_target_day() -> int:
	for flag in story_flags:
		var flag_name := str(flag)
		if flag_name.begins_with("sayaka_lv4_callback_target_day:") and story_flag(flag_name):
			return int(flag_name.trim_prefix("sayaka_lv4_callback_target_day:"))
	return -1

func sayaka_lv4_callback_due(for_day: int, absolute_clock: int) -> bool:
	var target_day := sayaka_lv4_callback_target_day()
	if not story_flag("sayaka_lv4_next_morning_callback_pending") or story_flag("sayaka_lv4_next_morning_callback_complete"):
		return false
	# The callback is a Monday-only epilogue. If a forced multi-day sequence
	# consumes that Monday, expire it instead of replaying it on a later date.
	if target_day < 1 or for_day != target_day or str(calendar_date(for_day).weekday_id) != "mon":
		return false
	return absolute_clock >= 12 * 60

func start_sayaka_lv4_callback(for_day: int, absolute_clock: int) -> RefCounted:
	if not sayaka_lv4_callback_due(for_day, absolute_clock):
		return null
	sayaka_lv4_callback_override_day = for_day
	sayaka_lv4_callback_override_clock = absolute_clock
	var event := start_character_event("sayaka_lv4_hospital_callback")
	sayaka_lv4_callback_override_day = -1
	sayaka_lv4_callback_override_clock = -1
	return event

func expire_sayaka_lv4_callback_if_missed(for_day: int) -> bool:
	var target_day := sayaka_lv4_callback_target_day()
	if target_day > 0 and for_day > target_day and story_flag("sayaka_lv4_next_morning_callback_pending"):
		settle_sayaka_lv4_callback(true)
		return true
	return false

func settle_sayaka_lv4_callback(skipped: bool = false) -> void:
	set_story_flag("sayaka_lv4_next_morning_callback_pending", false)
	set_story_flag("sayaka_lv4_next_morning_callback_complete")
	var target_day := sayaka_lv4_callback_target_day()
	if target_day > 0:
		set_story_flag("sayaka_lv4_callback_target_day:%s" % target_day, false)
	if skipped:
		set_story_flag("sayaka_lv4_next_morning_callback_skipped")

func prepare_sayaka_lv4_event_test() -> bool:
	if not OS.is_debug_build() or not character_event_definitions.has("sayaka_lv4_hotel_date"):
		return false
	reset()
	var relation := relation_for("doc_sayaka")
	relation.met = true
	relation.level = 3
	relation.familiarity = 55
	relation.affection = maxi(int(relation.get("affection", 0)), 20)
	relation.flags.append_array(["sayaka_phone_exchanged", "sayaka_sunday_invite_available"])
	relation.rank_history.append("sayaka_lv3_relationship")
	set_test_player_attribute("charm", 20)
	set_test_time(6, SHIFT_START_MINUTE)
	if not _complete_character_event_for_test("sayaka_lv3_relationship", 3):
		return false
	return is_sunday() and character_event_available(character_event_definitions["sayaka_lv4_hotel_date"])

func apply_relationship_choice(relation: Dictionary, choice: Dictionary) -> void:
	relation.affection = clampi(int(relation.get("affection", 0)) + int(choice.effects.get("affection", 0)), 0, 100)
	add_familiarity_to(relation, int(choice.effects.get("familiarity", 0)))
	for flag in choice.flags:
		if not relation.flags.has(flag):
			relation.flags.append(flag)
	for flag in choice.get("clear_flags", []):
		relation.flags.erase(flag)
	var effects: Dictionary = choice.get("effects", {})
	add_player_attribute_effect("charm", int(effects.get("charm", choice.get("charm_delta", 0))), "character_choice_charm", "角色事件选择 · 魅力")
	add_player_attribute_effect("presence", int(effects.get("presence", choice.get("presence_delta", 0))), "character_choice_presence", "角色事件选择 · 临床气场")

func apply_related_relationship_effects(choice: Dictionary) -> void:
	for related in choice.get("related_effects", []):
		var relation := relation_for(str(related.get("actor_id", "")))
		if relation.is_empty():
			continue
		var effects: Dictionary = related.get("effects", {})
		relation.affection = clampi(int(relation.get("affection", 0)) + int(effects.get("affection", 0)), 0, 100)
		add_familiarity_to(relation, int(effects.get("familiarity", 0)))
		for flag in related.get("flags", []):
			if not relation.flags.has(flag):
				relation.flags.append(flag)

func choose_character_event(choice_id: String) -> bool:
	if active_character_event_id.is_empty() or not character_events.has(active_character_event_id):
		return false
	var event = character_events[active_character_event_id]
	var event_day := int(display_schedule().day)
	if not event.apply(choice_id):
		return false
	var relation: Dictionary = relationships[event.definition.actor_id]
	apply_relationship_choice(relation, event.last_choice)
	apply_related_relationship_effects(event.last_choice)
	var chosen_route := str(event.last_choice.get("route", ""))
	if chosen_route in ["colleague", "romance"] and (chosen_route != "romance" or int(event.definition.get("target_level", 1)) >= INTIMATE_ROUTE_LEVEL):
		relation.route = chosen_route
	if event.completed and not relation.event_history.has(event.definition.id):
		event.completed_day = event_day
		relation.event_history.append(event.definition.id)
		if str(event.definition.id) in ["itsumi_lv0_c_corridor", "itsumi_lv0_d_instrument_tray", "itsumi_lv0_e_hiroko_invitation"]:
			set_story_flag("itsumi_lv0_postop_seen:%s" % completed_surgeries_total)
		if event.definition.category == "introduction":
			complete_introduction_cast(event.definition)
		elif event.definition.category in ["bond", "rank_up"] and character_event_rank_up_allowed(event.definition, relation):
			complete_rank_up(str(event.definition.actor_id), str(event.definition.id), int(event.definition.target_level), str(event.definition.get("benefit_id", "")))
	elif event.completed:
		event.completed_day = event_day
	if event.completed and test_save_target_character_event_id() == str(event.definition.id):
		clear_test_save_target()
	return true

func character_event_in_progress() -> bool:
	if active_character_event_id.is_empty() or not character_events.has(active_character_event_id):
		return false
	return not character_events[active_character_event_id].completed

func finish_character_event() -> void:
	# Completing a character event and leaving its result screen are separate
	# operations. Clear the active session at that boundary so the hospital map
	# is a saveable world-state boundary rather than a stale event scene.
	if active_character_event_id.is_empty():
		return
	if character_events.has(active_character_event_id) and not character_events[active_character_event_id].completed:
		return
	active_character_event_id = ""
	active_mode = "preop" if not active_preop_id.is_empty() else "encounter"

func set_story_flag(flag: String, value: bool = true) -> void:
	if flag.is_empty():
		return
	story_flags[flag] = value
	if flag == "probation_complete":
		probation_complete = value
	elif flag == "personal_nurse_system_unlocked":
		personal_nurse_system_unlocked = value
	if value:
		synchronize_story_locked_procedures()

func story_flag(flag: String) -> bool:
	return bool(story_flags.get(flag, false))

func month_number() -> int:
	return int(calendar_date().month)

func contract_month_number() -> int:
	return ((day_number() - 1) / 30) + 1

func calendar_date(for_day: int = -1) -> Dictionary:
	return FixedCalendar.date_for_day(day_number() if for_day < 1 else for_day)

func calendar_iso(for_day: int = -1) -> String:
	return str(calendar_date(for_day).iso)

func calendar_text(for_day: int = -1) -> String:
	var value := calendar_date(for_day)
	return "%d年%d月%d日 · %s" % [value.year, value.month, value.date, value.weekday_name]

func calendar_compact_text(for_day: int = -1) -> String:
	var value := calendar_date(for_day)
	return "%04d.%02d.%02d %s" % [value.year, value.month, value.date, value.weekday_name]

func calendar_day_label(for_day: int = -1) -> String:
	var value := calendar_date(for_day)
	var holiday := str(value.holiday_name)
	return holiday if not holiday.is_empty() else str(value.weekday_name)

func day_type(for_day: int = -1) -> String:
	return FixedCalendar.day_type_for(day_number() if for_day < 1 else for_day)

func is_routine_workday(for_day: int = -1) -> bool:
	return FixedCalendar.is_routine_workday(day_number() if for_day < 1 else for_day)

func is_limited_workday(for_day: int = -1) -> bool:
	return FixedCalendar.is_limited_workday(day_number() if for_day < 1 else for_day)

func is_hospital_closed_day(for_day: int = -1) -> bool:
	return FixedCalendar.is_closed_day(day_number() if for_day < 1 else for_day)

func day_number_for_date(value: String) -> int:
	return FixedCalendar.day_for_iso(value)

func is_sunday() -> bool:
	return str(calendar_date().weekday_id) == "sun"

func stable_sunday_roll(actor_id: String, purpose: String, for_day: int = -1) -> int:
	var selected_day := day_number() if for_day < 1 else for_day
	var value := posmod(campaign_seed + selected_day * 104729, 2147483647)
	for byte in (purpose + ":" + actor_id).to_utf8_buffer():
		value = posmod(value * 48271 + int(byte) + 1, 2147483647)
	return value % 100

func sunday_date_eligible(actor_id: String) -> bool:
	var profile: Dictionary = date_profile_definitions.get(actor_id, {})
	var relation := relation_for(actor_id)
	if not bool(profile.get("can_date", false)) or relation.is_empty() or not bool(relation.get("met", false)):
		return false
	if int(relation.get("familiarity", 0)) < int(profile.get("minimum_familiarity", 0)):
		return false
	if int(relation.get("level", 0)) < int(profile.get("minimum_level", 1)):
		return false
	for flag in profile.get("required_flags", []):
		if not relation.get("flags", []).has(str(flag)) and not story_flag(str(flag)):
			return false
	return true

func sunday_other_known_staff() -> Array[String]:
	var result: Array[String] = []
	if not is_sunday() or sunday_activity_done():
		return result
	for actor_id in date_profile_definitions:
		# Eligible people outside this week's five do not become refusal-only entries.
		if staff_is_met(str(actor_id)) and not sunday_date_eligible(str(actor_id)):
			result.append(str(actor_id))
	result.sort()
	return result

func sunday_date_candidates(maximum: int = 5) -> Array[String]:
	if not is_sunday() or sunday_activity_done():
		return []
	var scored: Array = []
	for actor_id in date_profile_definitions:
		if not sunday_date_eligible(str(actor_id)):
			continue
		scored.append({"id": str(actor_id), "score": stable_sunday_roll(str(actor_id), "candidate"), "milestone": not sunday_character_event_for(str(actor_id)).is_empty()})
	scored.sort_custom(func(a: Dictionary, b: Dictionary):
		if bool(a.milestone) != bool(b.milestone):
			return bool(a.milestone)
		if int(a.score) != int(b.score):
			return int(a.score) < int(b.score)
		return str(a.id) < str(b.id))
	var result: Array[String] = []
	for entry in scored.slice(0, mini(maximum, scored.size())):
		result.append(str(entry.id))
	return result

func sunday_on_duty_staff(maximum: int = 4) -> Array[String]:
	if not is_sunday():
		return []
	var scored: Array = []
	for actor_id in relationships:
		if staff_is_met(str(actor_id)):
			scored.append({"id": str(actor_id), "score": stable_sunday_roll(str(actor_id), "on_duty")})
	scored.sort_custom(func(a: Dictionary, b: Dictionary):
		if int(a.score) != int(b.score):
			return int(a.score) < int(b.score)
		return str(a.id) < str(b.id))
	var result: Array[String] = []
	for entry in scored.slice(0, mini(maximum, scored.size())):
		result.append(str(entry.id))
	return result

func sunday_invitation_rejection_rate(actor_id: String) -> int:
	if not sunday_date_eligible(actor_id):
		return 100
	var profile: Dictionary = date_profile_definitions.get(actor_id, {})
	if bool(profile.get("always_accept", false)):
		return 0
	var level := relationship_level(actor_id)
	var acceptance := 0
	var threshold := -1
	for key in profile.get("acceptance_chance_by_level", {}):
		if int(key) <= level and int(key) > threshold:
			threshold = int(key)
			acceptance = int(profile.acceptance_chance_by_level[key])
	var familiarity := int(relation_for(actor_id).get("familiarity", 0))
	if threshold < 0:
		# Compatibility for profiles without a character-specific probability table.
		acceptance = 100 if familiarity >= 70 else (95 if familiarity >= 45 else (85 if familiarity >= 25 else (75 if familiarity >= 10 else 65)))
	if bool(profile.get("familiarity_acceptance_bonus", false)):
		acceptance += (5 if familiarity >= 25 else 0) + (5 if familiarity >= 55 else 0)
	var caps: Dictionary = profile.get("acceptance_cap_by_level", {})
	if caps.has(str(level)):
		acceptance = mini(acceptance, int(caps[str(level)]))
	return 100 - clampi(acceptance, 0, 100)

func sunday_invitation_will_accept(actor_id: String) -> bool:
	return sunday_date_eligible(actor_id) and stable_sunday_roll(actor_id, "invitation") >= sunday_invitation_rejection_rate(actor_id)

func sunday_character_event_for(actor_id: String) -> Dictionary:
	if not is_sunday() or sunday_activity_done() or not sunday_date_eligible(actor_id):
		return {}
	var ready: Array = []
	for definition in character_event_definitions.values():
		if str(definition.get("actor_id", "")) == actor_id and character_event_trigger_mode(definition) == "sunday" and character_event_available(definition):
			ready.append(definition)
	ready.sort_custom(func(a: Dictionary, b: Dictionary):
		return int(a.priority) > int(b.priority) if int(a.priority) != int(b.priority) else str(a.id) < str(b.id))
	return {} if ready.is_empty() else ready[0]

func can_start_regular_sunday_date(actor_id: String) -> bool:
	if completed_sunday_date_event(actor_id) or not sunday_date_candidates().has(actor_id) or not sunday_invitation_will_accept(actor_id) or not sunday_character_event_for(actor_id).is_empty():
		return false
	var profile: Dictionary = date_profile_definitions.get(actor_id, {})
	if relationship_level(actor_id) == 0 and not str(profile.get("first_date_event_id", "")).is_empty():
		return false
	return not profile.get("dialogue", {}).is_empty()

func sunday_date_response(actor_id: String, location_id: String) -> String:
	var dialogue: Dictionary = date_profile_definitions.get(actor_id, {}).get("dialogue", {})
	for favorite in dialogue.get("favorites", []):
		if str(favorite.id) == location_id:
			return str(favorite.text)
	return str(dialogue.get("satisfied", {}).get("text", ""))

func date_location_available(location_id: String, for_day: int = -1) -> bool:
	var location: Dictionary = date_location_definitions.get(location_id, {})
	if location.is_empty() or location_id == "hotel" or bool(location.get("story_only", false)):
		return false
	if str(location.get("asset_status", "pending")) != "ready":
		return false
	var months: Array = location.get("available_months", [])
	if months.is_empty():
		return true
	# JSON numbers are floats; normalize before comparing with calendar integers.
	var month := int(calendar_date(for_day).month)
	for allowed_month in months:
		if int(allowed_month) == month:
			return true
	return false

func sunday_date_locations(for_day: int = -1) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in date_location_definitions:
		if date_location_available(str(id), for_day):
			result.append(date_location_definitions[id])
	return result

func sunday_activity_done(for_day: int = -1) -> bool:
	var selected_day := day_number() if for_day < 1 else for_day
	for record in sunday_history:
		if int(record.get("day", 0)) == selected_day:
			return true
	return false

func completed_sunday_date_event(actor_id: String, location_id: String = "") -> bool:
	for event in character_events.values():
		if event.completed and int(event.completed_day) == day_number() and bool(event.definition.get("consumes_sunday", false)) and str(event.definition.actor_id) == actor_id:
			if location_id.is_empty() or str(event.definition.get("date_location_id", "")) == location_id:
				return true
	return false

func complete_sunday_activity(activity_id: String, actor_id: String = "", location_id: String = "") -> bool:
	if not is_sunday() or sunday_activity_done():
		return false
	if activity_id == "date" and not completed_sunday_date_event(actor_id, location_id) and (not can_start_regular_sunday_date(actor_id) or not date_location_available(location_id)):
		return false
	sunday_history.append({
		"day": day_number(),
		"activity_id": activity_id,
		"actor_id": actor_id,
		"location_id": location_id,
	})
	if activity_id == "date" and not actor_id.is_empty() and staff_is_met(actor_id):
		add_familiarity(actor_id, date_familiarity_reward(actor_id, location_id))
		increment_character_progress_counter(actor_id, "completed_sunday_dates")
		add_player_attribute_effect("charm", 1, "sunday_date_%s_%s" % [actor_id, day_number()], "星期日约会 · 魅力 +1")
	advance_story_to_future_day(1, SHIFT_START_MINUTE)
	return true

func requirement_evaluation(raw_requirement: Variant, context: Dictionary = {}) -> Dictionary:
	var result := {
		"type": "",
		"met": false,
		"valid": false,
		"visible": true,
		"current": null,
		"minimum": null,
		"maximum": null,
		"reason": "",
	}
	if not raw_requirement is Dictionary:
		result.reason = "invalid_requirement"
		return result
	var requirement: Dictionary = raw_requirement
	var kind := str(requirement.get("type", ""))
	result.type = kind
	result.visible = bool(requirement.get("visible", true))
	result.reason = str(requirement.get("hint", kind))
	result.requirement = requirement.duplicate(true)
	match kind:
		"any_of":
			var alternatives: Array = requirement.get("requirements", [])
			var alternative_results: Array[Dictionary] = []
			var any_met := false
			for alternative in alternatives:
				var evaluation := requirement_evaluation(alternative, context)
				alternative_results.append(evaluation)
				any_met = any_met or bool(evaluation.get("met", false))
			result.merge({"valid": not alternatives.is_empty(), "met": not alternatives.is_empty() and any_met, "results": alternative_results}, true)
		"player_attribute":
			var value := int(player_attributes().get(str(requirement.get("attribute", "")), -1000))
			var minimum := int(requirement.get("minimum", -999))
			var maximum := int(requirement.get("maximum", 999))
			result.merge({"valid": true, "current": value, "minimum": minimum, "maximum": maximum, "met": value >= minimum and value <= maximum}, true)
		"staff_skill":
			var actor_id := str(requirement.get("actor_id", ""))
			var skill_id := str(requirement.get("skill", ""))
			var person := staff_record(actor_id)
			var current := int(person.get("skills", {}).get(skill_id, -1))
			var minimum := int(requirement.get("minimum", 0))
			result.merge({"valid": not person.is_empty() and not skill_id.is_empty(), "actor_id": actor_id, "current": current, "minimum": minimum, "met": not person.is_empty() and current >= minimum}, true)
		"staff_relationship_count":
			var category := str(requirement.get("team_category", ""))
			var minimum_level := int(requirement.get("minimum_level", 0))
			var excluded := str(requirement.get("exclude_actor_id", ""))
			var current := 0
			for person in staff:
				var candidate_id := str(person.get("id", ""))
				if candidate_id == excluded or str(person.get("team_category", person.get("profession", ""))) != category:
					continue
				if relationship_level(candidate_id) >= minimum_level:
					current += 1
			var minimum_count := int(requirement.get("minimum_count", 1))
			result.merge({"valid": not category.is_empty(), "current": current, "minimum": minimum_count, "met": not category.is_empty() and current >= minimum_count}, true)
		"career_progress_any":
			var gates: Array[bool] = []
			var values := {}
			if requirement.has("minimum_completed_surgeries"):
				values.completed_surgeries = completed_surgeries_total
				gates.append(completed_surgeries_total >= int(requirement.minimum_completed_surgeries))
			if requirement.has("minimum_reputation"):
				values.reputation = int(player_attributes().get("reputation", -1000))
				gates.append(int(values.reputation) >= int(requirement.minimum_reputation))
			if requirement.has("minimum_day"):
				values.day = day_number()
				gates.append(day_number() >= int(requirement.minimum_day))
			result.merge({"valid": not gates.is_empty(), "current": values, "met": not gates.is_empty() and gates.has(true)}, true)
		"completed_surgeries":
			var minimum := int(requirement.get("minimum", 0))
			result.merge({"valid": true, "current": completed_surgeries_total, "minimum": minimum, "met": completed_surgeries_total >= minimum}, true)
		"completed_surgeries_in_group":
			var current := int(completed_surgeries_by_group.get(str(requirement.get("procedure_group", "")), 0))
			var minimum := int(requirement.get("minimum", 0))
			result.merge({"valid": true, "current": current, "minimum": minimum, "met": current >= minimum}, true)
		"progress_counter":
			var actor_id := str(requirement.get("actor_id", context.get("actor_id", "")))
			var counter_id := str(requirement.get("counter_id", ""))
			var current := character_progress_counter(actor_id, counter_id)
			var minimum := int(requirement.get("minimum", 0))
			var maximum := int(requirement.get("maximum", 2147483647))
			result.merge({"valid": not counter_id.is_empty(), "actor_id": actor_id, "counter_id": counter_id, "current": current, "minimum": minimum, "maximum": maximum, "met": not counter_id.is_empty() and current >= minimum and current <= maximum}, true)
		"relationship_level":
			var actor_id := str(requirement.get("actor_id", context.get("actor_id", "")))
			var exact_legacy := requirement.has("level")
			var minimum := int(requirement.get("level", requirement.get("minimum", 0)))
			var maximum := int(requirement.get("level", requirement.get("maximum", RELATIONSHIP_MAX_LEVEL)))
			var current := relationship_level(actor_id) if not actor_id.is_empty() else -1
			result.merge({"valid": not actor_id.is_empty() and (exact_legacy or requirement.has("minimum")), "actor_id": actor_id, "current": current, "minimum": minimum, "maximum": maximum, "met": not actor_id.is_empty() and current >= minimum and current <= maximum}, true)
		"relationship_familiarity":
			var actor_id := str(requirement.get("actor_id", context.get("actor_id", "")))
			var relation := relation_for(actor_id)
			var current := int(relation.get("familiarity", -1))
			var minimum := int(requirement.get("minimum", 0))
			var maximum := int(requirement.get("maximum", 100))
			result.merge({"valid": not actor_id.is_empty(), "actor_id": actor_id, "current": current, "minimum": minimum, "maximum": maximum, "met": not relation.is_empty() and current >= minimum and current <= maximum}, true)
		"staff_unlocked":
			var actor_id := str(requirement.get("actor_id", context.get("actor_id", "")))
			var met := not actor_id.is_empty() and staff_is_met(actor_id)
			result.merge({"valid": not actor_id.is_empty(), "actor_id": actor_id, "current": met, "met": met}, true)
		"flag", "story_flag":
			var expected := bool(requirement.get("value", true))
			var current := story_flag(str(requirement.get("flag", "")))
			result.merge({"valid": not str(requirement.get("flag", "")).is_empty(), "current": current, "expected": expected, "met": current == expected}, true)
		"character_event_completed":
			var current := character_event_done(str(requirement.get("event_id", "")))
			result.merge({"valid": not str(requirement.get("event_id", "")).is_empty(), "current": current, "met": current}, true)
		"special_event_completed":
			var current := special_event_done(str(requirement.get("event_id", "")))
			result.merge({"valid": not str(requirement.get("event_id", "")).is_empty(), "current": current, "met": current}, true)
		"days_after_character_event":
			var required_event = character_events.get(str(requirement.get("event_id", "")))
			var completed_day := int(required_event.completed_day) if required_event != null and required_event.completed else 0
			var current := day_number() - completed_day if completed_day > 0 else -1
			var minimum := int(requirement.get("days", 0))
			result.merge({"valid": not str(requirement.get("event_id", "")).is_empty(), "current": current, "minimum": minimum, "met": completed_day > 0 and current >= minimum}, true)
		"days_after_special_event":
			var completed_day := int(special_event_completion_days.get(str(requirement.get("event_id", "")), 0))
			var current := day_number() - completed_day if completed_day > 0 else -1
			var minimum := int(requirement.get("days", 0))
			result.merge({"valid": not str(requirement.get("event_id", "")).is_empty(), "current": current, "minimum": minimum, "met": completed_day > 0 and current >= minimum}, true)
		"day_number":
			var current := day_number()
			var minimum := int(requirement.get("minimum", 1))
			var maximum := int(requirement.get("maximum", 2147483647))
			result.merge({"valid": true, "current": current, "minimum": minimum, "maximum": maximum, "met": current >= minimum and current <= maximum}, true)
		"month_number":
			var current := month_number()
			var minimum := int(requirement.get("minimum", 1))
			var maximum := int(requirement.get("maximum", 2147483647))
			result.merge({"valid": true, "current": current, "minimum": minimum, "maximum": maximum, "met": current >= minimum and current <= maximum}, true)
		"calendar_date":
			var expected := str(requirement.get("date", ""))
			var current := calendar_iso()
			result.merge({"valid": not expected.is_empty(), "current": current, "expected": expected, "met": current == expected}, true)
		"calendar_range":
			var first := day_number_for_date(str(requirement.get("start_date", "")))
			var last := day_number_for_date(str(requirement.get("end_date", "")))
			var current := day_number()
			result.merge({"valid": first > 0 and last >= first, "current": current, "minimum": first, "maximum": last, "met": first > 0 and last >= first and current >= first and current <= last}, true)
		"weekday":
			var current := str(calendar_date().weekday_id)
			var allowed: Array = requirement.get("days", [])
			result.merge({"valid": not allowed.is_empty(), "current": current, "expected": allowed, "met": allowed.has(current)}, true)
		"day_type":
			var current := day_type()
			var allowed: Array = requirement.get("values", [])
			result.merge({"valid": not allowed.is_empty(), "current": current, "expected": allowed, "met": allowed.has(current)}, true)
		_:
			result.reason = "unknown_requirement_type"
	return result

func requirements_evaluation(requirements: Array, context: Dictionary = {}) -> Dictionary:
	var results: Array[Dictionary] = []
	var unmet: Array[Dictionary] = []
	for requirement in requirements:
		var evaluation := requirement_evaluation(requirement, context)
		results.append(evaluation)
		if not bool(evaluation.get("met", false)):
			unmet.append(evaluation)
	return {"met": unmet.is_empty(), "results": results, "unmet": unmet}

func requirements_met(requirements: Array, context: Dictionary = {}) -> bool:
	return bool(requirements_evaluation(requirements, context).met)

func special_requirements_met(requirements: Array) -> bool:
	return requirements_met(requirements)

func special_event_done(id: String) -> bool:
	return int(special_event_completion_counts.get(id, 0)) > 0

func special_event_gallery_unlocked(id: String) -> bool:
	if not special_event_definitions.has(id):
		return false
	return bool(special_event_definitions[id].get("gallery_unlock", false)) and special_event_done(id)

func special_event_base_requirements_met(definition: Dictionary) -> bool:
	if definition.is_empty():
		return false
	if not bool(definition.get("repeatable", false)) and special_event_done(str(definition.get("id", ""))):
		return false
	for actor_id in definition.get("required_characters", []):
		if str(actor_id) != "PLAYER" and not staff_is_met(str(actor_id)):
			return false
	for event_id in definition.get("prerequisite_events", []):
		var prerequisite := str(event_id)
		if not character_event_done(prerequisite) and not special_event_done(prerequisite):
			return false
	for reward in definition.get("relationship_rewards", []):
		var actor_id := str(reward.get("actor_id", ""))
		var target_level := int(reward.get("target_level", 0))
		if relationship_rank_gate_applies_to_event(actor_id, target_level, str(definition.get("id", ""))) and not relationship_rank_gate_met(actor_id, target_level):
			return false
	return special_requirements_met(definition.get("unlock_requirements", []))

func special_event_timing_status(definition: Dictionary) -> Dictionary:
	var timing: Dictionary = definition.get("timing", {})
	var trigger_day := special_event_trigger_day(definition)
	var priority := int(timing.get("priority", 0))
	var duration := maxi(1, int(definition.get("duration_days", 1)))
	var today := day_number()
	if today < trigger_day:
		return {"status": "future", "trigger_day": trigger_day, "effective_day": trigger_day}
	if is_sunday() and not bool(timing.get("sunday_start_allowed", false)):
		return {"status": "sunday_deferred", "trigger_day": trigger_day, "effective_day": today + 1}
	var planned_start := today
	var planned_end := planned_start + duration - 1
	if planned_start > GAME_DURATION_DAYS or planned_end > GAME_DURATION_DAYS:
		return {"status": "expired", "trigger_day": trigger_day, "effective_day": planned_start}
	if not bool(timing.get("final_week_allowed", false)) and planned_end >= FINAL_WEEK_START_DAY:
		return {"status": "final_week_reserved", "trigger_day": trigger_day, "effective_day": planned_start}
	if test_save_target_event_id() == str(definition.get("id", "")):
		return {"status": "available", "trigger_day": trigger_day, "effective_day": planned_start}
	for higher in special_event_definitions.values():
		if str(higher.get("id", "")) == str(definition.get("id", "")):
			continue
		if bool(higher.get("developer_only", false)) and not bool(definition.get("developer_only", false)):
			continue
		var higher_timing: Dictionary = higher.get("timing", {})
		if int(higher_timing.get("priority", 0)) <= priority:
			continue
		if special_event_done(str(higher.get("id", ""))) or not special_event_base_requirements_met(higher):
			continue
		var higher_start := maxi(today, special_event_trigger_day(higher))
		if str(calendar_date(higher_start).weekday_id) == "sun" and not bool(higher_timing.get("sunday_start_allowed", false)):
			higher_start += 1
		var higher_end := higher_start + maxi(1, int(higher.get("duration_days", 1))) - 1
		if higher_end > GAME_DURATION_DAYS:
			continue
		if not bool(higher_timing.get("final_week_allowed", false)) and higher_end >= FINAL_WEEK_START_DAY:
			continue
		if planned_start <= higher_end and higher_start <= planned_end:
			return {
				"status": "postponed",
				"trigger_day": trigger_day,
				"effective_day": higher_end + 1,
				"blocked_by": str(higher.get("id", "")),
			}
	return {"status": "available", "trigger_day": trigger_day, "effective_day": planned_start}

func special_event_trigger_day(definition: Dictionary) -> int:
	var timing: Dictionary = definition.get("timing", {})
	if not str(timing.get("trigger_date", "")).is_empty():
		return maxi(1, day_number_for_date(str(timing.trigger_date)))
	return int(timing.get("trigger_day", 1))

func special_event_available(definition: Dictionary) -> bool:
	if not active_special_event_id.is_empty() or active_surgery_in_progress():
		return false
	var timing: Dictionary = definition.get("timing", {})
	if bool(timing.get("exact_day_start_only", false)):
		if current_absolute_clock() != SHIFT_START_MINUTE or day_start_character_event_consumed():
			return false
		var competing_character_event := next_day_start_character_event()
		if not competing_character_event.is_empty() and int(competing_character_event.get("priority", 0)) > int(timing.get("priority", 0)):
			return false
	if not test_save_target_character_event_id().is_empty():
		return false
	var test_target := test_save_target_event_id()
	if not test_target.is_empty() and test_target != str(definition.get("id", "")):
		return false
	if test_save_event_waits_for_surgery(str(definition.get("id", ""))):
		return false
	if not special_event_base_requirements_met(definition):
		return false
	if special_event_trigger_mode(definition) == "after_work":
		var schedule := display_schedule()
		var after_work_timing: Dictionary = definition.get("timing", {})
		var current_clock := int(schedule.get("absolute_clock", current_absolute_clock()))
		if current_clock < int(after_work_timing.get("time_start", OUTPATIENT_CLOSE_MINUTE)) or current_clock > int(after_work_timing.get("time_end", SHIFT_START_MINUTE + SHIFT_MINUTES + 240)):
			return false
	return str(special_event_timing_status(definition).status) == "available"

func next_after_work_special_event() -> Dictionary:
	if is_hospital_closed_day(current_workday()) or active_surgery_in_progress() or special_event_in_progress() or not active_character_event_id.is_empty() or not active_micro_event_id.is_empty():
		return {}
	var schedule := display_schedule()
	var current_clock := int(schedule.get("absolute_clock", current_absolute_clock()))
	var candidates: Array = []
	for definition in special_event_definitions.values():
		if special_event_trigger_mode(definition) != "after_work" or not special_event_available(definition):
			continue
		var timing: Dictionary = definition.get("timing", {})
		if current_clock < int(timing.get("time_start", OUTPATIENT_CLOSE_MINUTE)) or current_clock > int(timing.get("time_end", SHIFT_START_MINUTE + SHIFT_MINUTES + 240)):
			continue
		candidates.append(definition)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary):
		var a_priority := int(a.get("timing", {}).get("priority", 0))
		var b_priority := int(b.get("timing", {}).get("priority", 0))
		if a_priority != b_priority:
			return a_priority > b_priority
		return str(a.id) < str(b.id))
	return {} if candidates.is_empty() else candidates[0]

func test_save_target_event_id() -> String:
	if not OS.is_debug_build():
		return ""
	var prefix := "__test_save_target_event__"
	for flag in story_flags:
		if str(flag).begins_with(prefix) and bool(story_flags[flag]):
			return str(flag).trim_prefix(prefix)
	return ""

func test_save_target_character_event_id() -> String:
	if not OS.is_debug_build():
		return ""
	var prefix := "__test_save_target_character_event__"
	for flag in story_flags:
		if str(flag).begins_with(prefix) and bool(story_flags[flag]):
			return str(flag).trim_prefix(prefix)
	return ""

func clear_test_save_target() -> void:
	var prefixes := ["__test_save_target_event__", "__test_save_target_character_event__", "__test_save_wait_one_surgery__", "__test_save_surgery_baseline__"]
	var stale_flags: Array[String] = []
	for flag in story_flags:
		if prefixes.any(func(prefix: String): return str(flag).begins_with(prefix)):
			stale_flags.append(str(flag))
	for flag in stale_flags:
		story_flags.erase(flag)

func test_save_event_waits_for_surgery(event_id: String) -> bool:
	if not OS.is_debug_build() or not story_flag("__test_save_wait_one_surgery__" + event_id):
		return false
	var prefix := "__test_save_surgery_baseline__"
	var baseline := -1
	for flag in story_flags:
		var flag_id := str(flag)
		if flag_id.begins_with(prefix) and bool(story_flags[flag_id]):
			baseline = maxi(baseline, int(flag_id.trim_prefix(prefix)))
	return baseline >= 0 and completed_surgeries_total <= baseline

func arm_test_save_one_surgery(event_id: String) -> void:
	if not OS.is_debug_build() or event_id.is_empty():
		return
	var prefix := "__test_save_surgery_baseline__"
	var stale_flags: Array[String] = []
	for flag in story_flags:
		if str(flag).begins_with(prefix):
			stale_flags.append(str(flag))
	for flag in stale_flags:
		story_flags.erase(flag)
	set_story_flag("__test_save_wait_one_surgery__" + event_id, true)
	set_story_flag(prefix + str(completed_surgeries_total), true)

func set_test_time(day: int, absolute_clock: int) -> void:
	if not OS.is_debug_build():
		return
	var target_day := clampi(day, 1, GAME_DURATION_DAYS)
	var target_clock := clampi(absolute_clock, SHIFT_START_MINUTE, SHIFT_START_MINUTE + SHIFT_MINUTES - 1)
	story_time_advance_minutes = (target_day - 1) * SHIFT_MINUTES + target_clock - SHIFT_START_MINUTE
	discarded_overtime_minutes = 0

func set_test_player_attribute(attribute: String, value: int) -> bool:
	if not OS.is_debug_build() or not PLAYER_ATTRIBUTE_BASE.has(attribute):
		return false
	var selected := clampi(value, int(PLAYER_ATTRIBUTE_MIN.get(attribute, -999)), int(PLAYER_ATTRIBUTE_MAX.get(attribute, 999)))
	if attribute == "skill":
		surgery_xp = surgery_xp_for_level(selected)
	elif attribute == "leadership":
		leadership_xp = leadership_xp_for_level(selected)
	else:
		archived_player_effects[attribute] = selected - int(PLAYER_ATTRIBUTE_BASE.get(attribute, 0))
	return true

func _complete_character_event_for_test(event_id: String, completed_day: int) -> bool:
	if character_event_done(event_id):
		return true
	if not character_event_definitions.has(event_id):
		return false
	var session := CharacterEvent.new(character_event_definitions[event_id])
	var guard := 0
	while not session.completed and guard < 200:
		var node: Dictionary = session.current()
		if node.is_empty() or node.get("choices", []).is_empty():
			return false
		if not session.apply(str(node.choices[0].id)):
			return false
		guard += 1
	if not session.completed:
		return false
	session.completed_day = maxi(1, completed_day)
	character_events[event_id] = session
	if not character_event_order.has(event_id):
		character_event_order.append(event_id)
	return true

func _test_event_earliest_day(definition: Dictionary) -> int:
	var result := maxi(1, special_event_trigger_day(definition))
	for requirement in definition.get("unlock_requirements", []):
		if not requirement is Dictionary:
			continue
		match str(requirement.get("type", "")):
			"day_number":
				result = maxi(result, int(requirement.get("minimum", 1)))
			"career_progress_any":
				if requirement.has("minimum_day"):
					result = maxi(result, int(requirement.minimum_day))
			"days_after_special_event":
				var dependency: Dictionary = special_event_definitions.get(str(requirement.get("event_id", "")), {})
				if not dependency.is_empty():
					result = maxi(result, _test_event_earliest_day(dependency) + int(requirement.get("days", 0)))
			"days_after_character_event":
				var dependency: Dictionary = character_event_definitions.get(str(requirement.get("event_id", "")), {})
				result = maxi(result, int(dependency.get("conditions", {}).get("min_day", 1)) + int(requirement.get("days", 0)))
	return clampi(result, 1, GAME_DURATION_DAYS)

func _apply_test_event_requirement(requirement: Dictionary, target_day: int, context_actor_id: String = "") -> void:
	match str(requirement.get("type", "")):
		"player_attribute":
			var attribute := str(requirement.get("attribute", ""))
			var current := int(player_attributes().get(attribute, 0))
			var selected := clampi(current, int(requirement.get("minimum", -999)), int(requirement.get("maximum", 999)))
			set_test_player_attribute(attribute, selected)
		"staff_skill":
			var actor_id := str(requirement.get("actor_id", ""))
			var skill_id := str(requirement.get("skill", ""))
			var minimum := int(requirement.get("minimum", 0))
			if base_staff_skills.has(actor_id) and base_staff_skills[actor_id].has(skill_id):
				if not staff_skill_levels.has(actor_id):
					staff_skill_levels[actor_id] = {}
				staff_skill_levels[actor_id][skill_id] = maxi(staff_skill_value(actor_id, skill_id), minimum)
				apply_staff_skill_levels()
		"staff_relationship_count":
			var category := str(requirement.get("team_category", ""))
			var excluded := str(requirement.get("exclude_actor_id", ""))
			var minimum_level := int(requirement.get("minimum_level", 0))
			var remaining := int(requirement.get("minimum_count", 0))
			for person in staff:
				var candidate_id := str(person.get("id", ""))
				if remaining <= 0:
					break
				if candidate_id == excluded or str(person.get("team_category", person.get("profession", ""))) != category:
					continue
				var relation := relation_for(candidate_id)
				if relation.is_empty():
					continue
				relation.met = true
				relation.level = maxi(int(relation.level), minimum_level)
				remaining -= 1
		"career_progress_any":
			if requirement.has("minimum_day"):
				advance_story_to_day(maxi(day_number(), int(requirement.minimum_day)), SHIFT_START_MINUTE)
			elif requirement.has("minimum_completed_surgeries"):
				completed_surgeries_total = maxi(completed_surgeries_total, int(requirement.minimum_completed_surgeries))
			elif requirement.has("minimum_reputation"):
				set_test_player_attribute("reputation", int(requirement.minimum_reputation))
		"completed_surgeries":
			completed_surgeries_total = maxi(completed_surgeries_total, int(requirement.get("minimum", 0)))
		"completed_surgeries_in_group":
			var group := str(requirement.get("procedure_group", ""))
			completed_surgeries_by_group[group] = maxi(int(completed_surgeries_by_group.get(group, 0)), int(requirement.get("minimum", 0)))
		"progress_counter":
			var counter_actor_id := str(requirement.get("actor_id", context_actor_id))
			set_test_character_progress_counter(counter_actor_id, str(requirement.get("counter_id", "")), int(requirement.get("minimum", 0)))
		"relationship_level":
			var actor_id := str(requirement.get("actor_id", context_actor_id))
			var relation := relation_for(actor_id)
			if not relation.is_empty():
				relation.met = true
				relation.level = clampi(int(requirement.get("level", requirement.get("minimum", 0))), 0, relationship_max_level(actor_id))
		"relationship_familiarity":
			var actor_id := str(requirement.get("actor_id", context_actor_id))
			var relation := relation_for(actor_id)
			if not relation.is_empty():
				relation.met = true
				relation.familiarity = clampi(int(requirement.get("minimum", 0)), 0, int(requirement.get("maximum", 100)))
		"staff_unlocked":
			meet_staff(str(requirement.get("actor_id", "")))
		"flag", "story_flag":
			set_story_flag(str(requirement.get("flag", "")), bool(requirement.get("value", true)))
		"character_event_completed":
			_complete_character_event_for_test(str(requirement.get("event_id", "")), target_day - 1)
		"days_after_character_event":
			_complete_character_event_for_test(str(requirement.get("event_id", "")), target_day - int(requirement.get("days", 0)))
		"special_event_completed":
			var event_id := str(requirement.get("event_id", ""))
			special_event_completion_counts[event_id] = maxi(1, int(special_event_completion_counts.get(event_id, 0)))
			special_event_completion_days[event_id] = maxi(1, target_day - 1)
		"days_after_special_event":
			var event_id := str(requirement.get("event_id", ""))
			special_event_completion_counts[event_id] = maxi(1, int(special_event_completion_counts.get(event_id, 0)))
			special_event_completion_days[event_id] = maxi(1, target_day - int(requirement.get("days", 0)))

func prepare_special_event_test_save(event_id: String, wait_for_one_surgery: bool = false) -> bool:
	last_error = "无法生成测试存档。"
	if not OS.is_debug_build() or not special_event_definitions.has(event_id):
		return false
	reset()
	var definition: Dictionary = special_event_definitions[event_id]
	set_story_flag("__test_save_target_event__" + event_id, true)
	var target_day := _test_event_earliest_day(definition)
	var milestone_gap := 1
	for reward in definition.get("relationship_rewards", []):
		var actor_id := str(reward.get("actor_id", ""))
		var target_level := int(reward.get("target_level", 0))
		var slot := relationship_rank_slot(actor_id, target_level)
		if not slot.is_empty():
			milestone_gap = maxi(milestone_gap, int(slot.get("cooldown_days", Progression.RELATIONSHIP_DEFAULT_COOLDOWN_DAYS)))
			if target_level > 1:
				target_day = maxi(target_day, 1 + milestone_gap)
	for actor_id in definition.get("required_characters", []):
		if str(actor_id) != "PLAYER":
			meet_staff(str(actor_id))
	for prerequisite_id in definition.get("prerequisite_events", []):
		var prerequisite := str(prerequisite_id)
		if special_event_definitions.has(prerequisite):
			special_event_completion_counts[prerequisite] = 1
			special_event_completion_days[prerequisite] = maxi(1, target_day - milestone_gap)
		else:
			_complete_character_event_for_test(prerequisite, maxi(1, target_day - milestone_gap))
	for reward in definition.get("relationship_rewards", []):
		var actor_id := str(reward.get("actor_id", ""))
		var target_level := int(reward.get("target_level", 0))
		var relation := relation_for(actor_id)
		var slot := relationship_rank_slot(actor_id, target_level)
		if relation.is_empty() or slot.is_empty():
			continue
		relation.met = true
		relation.level = maxi(0, target_level - 1)
		relation.familiarity = maxi(int(relation.get("familiarity", 0)), int(slot.get("min_familiarity", 0)))
		for requirement in slot.get("special_requirements", []):
			if requirement is Dictionary:
				_apply_test_event_requirement(requirement, target_day, actor_id)
	for requirement in definition.get("unlock_requirements", []):
		if requirement is Dictionary:
			_apply_test_event_requirement(requirement, target_day)
	set_test_time(target_day, SHIFT_START_MINUTE)
	if wait_for_one_surgery:
		arm_test_save_one_surgery(event_id)
	active_mode = "encounter"
	active_id = ""
	last_error = ""
	return true

func prepare_character_event_test_save(event_id: String, wait_for_one_surgery: bool = false) -> bool:
	last_error = "无法生成角色事件测试存档。"
	if not OS.is_debug_build() or not character_event_definitions.has(event_id):
		return false
	reset()
	var definition: Dictionary = character_event_definitions[event_id]
	var conditions: Dictionary = definition.get("conditions", {})
	var target_day := clampi(int(conditions.get("min_day", 1)), 1, GAME_DURATION_DAYS)
	var required_gap := int(conditions.get("days_after_required_events", 0))
	for required_id in conditions.get("required_events", []):
		var required_definition: Dictionary = character_event_definitions.get(str(required_id), {})
		target_day = maxi(target_day, int(required_definition.get("conditions", {}).get("min_day", 1)) + required_gap)
	for required_id in conditions.get("required_events", []):
		_complete_character_event_for_test(str(required_id), maxi(1, target_day - required_gap))
	var actor_id := str(definition.get("actor_id", ""))
	var relation := relation_for(actor_id)
	if relation.is_empty():
		return false
	var category := str(definition.get("category", "contextual"))
	relation.met = category != "introduction"
	if category == "bond":
		relation.level = 0
	elif category == "rank_up":
		relation.level = maxi(0, int(definition.get("target_level", 1)) - 1)
	relation.affection = maxi(int(relation.get("affection", 0)), int(conditions.get("min_affection", 0)))
	relation.familiarity = maxi(int(relation.get("familiarity", 0)), int(conditions.get("min_familiarity", 0)))
	var target_level := int(definition.get("target_level", 0))
	if relationship_rank_gate_applies_to_event(actor_id, target_level, event_id):
		var slot := relationship_rank_slot(actor_id, target_level)
		relation.familiarity = maxi(int(relation.familiarity), int(slot.get("min_familiarity", 0)))
		for requirement in slot.get("special_requirements", []):
			if requirement is Dictionary:
				_apply_test_event_requirement(requirement, target_day, actor_id)
	for requirement in conditions.get("special_requirements", []):
		if requirement is Dictionary:
			_apply_test_event_requirement(requirement, target_day, actor_id)
	set_story_flag("__test_save_target_character_event__" + event_id, true)
	set_test_time(target_day, clampi(int(definition.get("time_start", SHIFT_START_MINUTE)), SHIFT_START_MINUTE, SHIFT_START_MINUTE + SHIFT_MINUTES - 1))
	if wait_for_one_surgery:
		arm_test_save_one_surgery(event_id)
	active_mode = "encounter"
	active_id = ""
	last_error = ""
	return true

func prepare_relationship_gate_test_save(actor_id: String, target_level: int, boundary: String = "exact") -> bool:
	last_error = "relationship_gate_invalid"
	if not OS.is_debug_build() or boundary not in ["before", "exact", "above"]:
		return false
	var slot := relationship_rank_slot(actor_id, target_level)
	if slot.is_empty() or str(slot.get("content_status", "unavailable")) == "unavailable":
		return false
	reset()
	var relation := relation_for(actor_id)
	if relation.is_empty() or target_level < 1 or target_level > relationship_max_level(actor_id):
		return false
	relation.met = true
	relation.level = target_level - 1
	var required_familiarity := int(slot.get("min_familiarity", 0))
	match boundary:
		"before":
			relation.familiarity = maxi(0, required_familiarity - 1)
		"above":
			relation.familiarity = mini(100, required_familiarity + 1)
		_:
			relation.familiarity = required_familiarity
	for requirement in slot.get("special_requirements", []):
		if requirement is Dictionary:
			_apply_test_event_requirement(requirement, 1, actor_id)
	set_test_time(1, SHIFT_START_MINUTE)
	active_mode = "encounter"
	active_id = ""
	if boundary != "before" and not relationship_rank_gate_met(actor_id, target_level):
		last_error = "relationship_gate_roster_blocked"
		return false
	last_error = ""
	return true

func apply_test_save_overrides(overrides: Dictionary) -> bool:
	last_error = "测试存档覆盖值格式不正确。"
	if not OS.is_debug_build():
		return false
	var attributes: Variant = overrides.get("player_attributes", {})
	if not attributes is Dictionary:
		return false
	for attribute in attributes:
		if not (attributes[attribute] is int or attributes[attribute] is float) or not set_test_player_attribute(str(attribute), int(attributes[attribute])):
			return false
	var relation_overrides: Variant = overrides.get("relationships", {})
	if not relation_overrides is Dictionary:
		return false
	for actor_id in relation_overrides:
		var relation := relation_for(str(actor_id))
		var values: Variant = relation_overrides[actor_id]
		if relation.is_empty() or not values is Dictionary:
			return false
		for key in values:
			match str(key):
				"met":
					if not values[key] is bool:
						return false
					relation.met = bool(values[key])
				"level":
					if not (values[key] is int or values[key] is float):
						return false
					relation.level = clampi(int(values[key]), 0, relationship_max_level(str(actor_id)))
				"affection", "familiarity":
					if not (values[key] is int or values[key] is float):
						return false
					relation[key] = clampi(int(values[key]), 0, 100)
				"route":
					if str(values[key]) not in ["colleague", "romance"]:
						return false
					relation.route = str(values[key])
				"flags":
					if not values[key] is Array:
						return false
					if values[key].any(func(flag: Variant): return not flag is String):
						return false
					relation.flags = values[key].duplicate()
				_:
					return false
	var flags: Variant = overrides.get("story_flags", {})
	if not flags is Dictionary:
		return false
	for flag in flags:
		if not flags[flag] is bool:
			return false
		set_story_flag(str(flag), bool(flags[flag]))
	var progress: Variant = overrides.get("progress", {})
	if not progress is Dictionary:
		return false
	if progress.has("completed_surgeries_total"):
		completed_surgeries_total = maxi(0, int(progress.completed_surgeries_total))
	if progress.has("completed_surgeries_by_group"):
		if not progress.completed_surgeries_by_group is Dictionary:
			return false
		completed_surgeries_by_group = progress.completed_surgeries_by_group.duplicate(true)
	if progress.has("completed_surgeries_by_procedure"):
		if not progress.completed_surgeries_by_procedure is Dictionary:
			return false
		completed_surgeries_by_procedure = progress.completed_surgeries_by_procedure.duplicate(true)
	if progress.has("character_counters"):
		if not progress.character_counters is Dictionary:
			return false
		for actor_id in progress.character_counters:
			var counters: Variant = progress.character_counters[actor_id]
			if not counters is Dictionary or (str(actor_id) != "global" and relation_for(str(actor_id)).is_empty()):
				return false
			for counter_id in counters:
				var value: Variant = counters[counter_id]
				if str(counter_id).is_empty() or not (value is int or value is float) or float(value) != floorf(float(value)) or int(value) < 0:
					return false
				set_test_character_progress_counter(str(actor_id), str(counter_id), int(value))
	if progress.has("staff_skills"):
		if not progress.staff_skills is Dictionary:
			return false
		for actor_id in progress.staff_skills:
			var skills: Variant = progress.staff_skills[actor_id]
			if not skills is Dictionary or not base_staff_skills.has(str(actor_id)):
				return false
			for skill_id in skills:
				var value: Variant = skills[skill_id]
				if not base_staff_skills[str(actor_id)].has(str(skill_id)) or not (value is int or value is float):
					return false
				if not staff_skill_levels.has(str(actor_id)):
					staff_skill_levels[str(actor_id)] = {}
				staff_skill_levels[str(actor_id)][str(skill_id)] = clampi(int(value), int(base_staff_skills[str(actor_id)][str(skill_id)]), 90)
		apply_staff_skill_levels()
	var completions: Variant = overrides.get("special_events", {})
	if not completions is Dictionary:
		return false
	for event_id in completions:
		var values: Variant = completions[event_id]
		if not special_event_definitions.has(str(event_id)) or not values is Dictionary:
			return false
		special_event_completion_counts[event_id] = maxi(0, int(values.get("count", 1)))
		special_event_completion_days[event_id] = clampi(int(values.get("day", day_number())), 1, GAME_DURATION_DAYS)
	last_error = ""
	return true

func postponed_special_event_count() -> int:
	var total := 0
	for definition in special_event_definitions.values():
		if bool(definition.get("developer_only", false)) or not special_event_base_requirements_met(definition):
			continue
		if str(special_event_timing_status(definition).status) == "postponed":
			total += 1
	return total

func available_special_events(include_developer: bool = false) -> Array:
	var result: Array = []
	for definition in special_event_definitions.values():
		if bool(definition.get("developer_only", false)) and not include_developer:
			continue
		if special_event_available(definition):
			result.append(definition)
	result.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.id) < str(b.id))
	return result

func special_event_trigger_mode(definition: Dictionary) -> String:
	return str(definition.get("trigger_mode", "day_start"))

func next_auto_special_event() -> Dictionary:
	if not active_character_event_id.is_empty() or not active_micro_event_id.is_empty():
		return {}
	var candidates: Array = available_special_events()
	candidates = candidates.filter(func(definition: Dictionary): return bool(definition.get("auto_schedule", false)) and special_event_trigger_mode(definition) == "day_start")
	candidates.sort_custom(func(a: Dictionary, b: Dictionary):
		var a_priority := int(a.get("timing", {}).get("priority", 0))
		var b_priority := int(b.get("timing", {}).get("priority", 0))
		if a_priority != b_priority:
			return a_priority > b_priority
		return str(a.id) < str(b.id))
	return {} if candidates.is_empty() else candidates[0]

func next_special_event_at(location_id: String) -> Dictionary:
	if location_id.is_empty() or not active_character_event_id.is_empty() or not active_micro_event_id.is_empty():
		return {}
	var candidates: Array = available_special_events()
	candidates = candidates.filter(func(definition: Dictionary): return special_event_trigger_mode(definition) == "location" and str(definition.get("location_id", "")) == location_id)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary):
		var a_priority := int(a.get("timing", {}).get("priority", 0))
		var b_priority := int(b.get("timing", {}).get("priority", 0))
		if a_priority != b_priority:
			return a_priority > b_priority
		return str(a.id) < str(b.id))
	return {} if candidates.is_empty() else candidates[0]

func normalize_special_event_position() -> bool:
	if active_special_event == null or active_special_event.completed:
		return false
	var changed := false
	var guard := 0
	while guard < 100:
		var node: Dictionary = active_special_event.current()
		if node.is_empty() or special_requirements_met(node.get("requirements", [])):
			break
		var fallback := str(node.get("fallback_next", ""))
		if not active_special_event.jump_to(fallback):
			break
		changed = true
		guard += 1
	return changed

func start_special_event(id: String) -> RefCounted:
	last_error = "这个特殊活动当前无法开始。"
	if not active_special_event_id.is_empty() or not active_character_event_id.is_empty() or not active_micro_event_id.is_empty():
		return null
	if not special_event_definitions.has(id):
		return null
	var definition: Dictionary = special_event_definitions[id]
	if not special_event_available(definition):
		return null
	var steps := {}
	for step_id in definition.get("event_chain", []):
		if not special_event_step_definitions.has(str(step_id)):
			return null
		steps[str(step_id)] = special_event_step_definitions[str(step_id)]
	var event_day := current_workday() if special_event_trigger_mode(definition) == "after_work" else day_number()
	active_special_event = SpecialEvent.new(definition, steps, event_day)
	active_special_event_id = id
	active_mode = "special_event"
	normalize_special_event_position()
	last_error = ""
	return active_special_event

func start_special_event_for_testing(id: String) -> RefCounted:
	last_error = "测试活动当前无法开始。"
	if not OS.is_debug_build() or not active_special_event_id.is_empty() or not active_character_event_id.is_empty() or not active_micro_event_id.is_empty() or active_surgery_in_progress():
		return null
	if not special_event_definitions.has(id):
		return null
	var definition: Dictionary = special_event_definitions[id]
	var steps := {}
	for step_id in definition.get("event_chain", []):
		if not special_event_step_definitions.has(str(step_id)):
			return null
		steps[str(step_id)] = special_event_step_definitions[str(step_id)]
	for actor_id in definition.get("required_characters", []):
		if str(actor_id) != "PLAYER":
			meet_staff(str(actor_id))
	var event_day := current_workday() if special_event_trigger_mode(definition) == "after_work" else day_number()
	active_special_event = SpecialEvent.new(definition, steps, event_day)
	active_special_event_id = id
	active_mode = "special_event"
	last_error = ""
	return active_special_event

func apply_special_event_choice_effects(choice: Dictionary) -> void:
	var effects: Variant = choice.get("effects", {})
	if not effects is Dictionary:
		return
	for flag in effects.get("story_flags", []):
		set_story_flag(str(flag), true)
	for actor_id in effects.get("meet_characters", []):
		meet_staff(str(actor_id))
	for reward in effects.get("familiarity", []):
		if reward is Dictionary:
			add_familiarity(str(reward.get("actor_id", "")), int(reward.get("amount", 0)))

func apply_special_event_completion_effects(definition: Dictionary) -> void:
	var effects: Variant = definition.get("completion_effects", {})
	if not effects is Dictionary:
		return
	var assigned_personal_nurse := str(effects.get("personal_nurse_id", ""))
	if not assigned_personal_nurse.is_empty():
		probation_complete = true
		personal_nurse_system_unlocked = true
		meet_staff(assigned_personal_nurse)
		set_personal_nurse(assigned_personal_nurse)
	for surgery_id in effects.get("unlock_procedures", []):
		unlock_procedure(str(surgery_id))
	var referral_id := str(effects.get("advanced_referral_case_id", ""))
	if not referral_id.is_empty():
		complete_advanced_referral_case(referral_id)
	var completed_surgery_id := str(effects.get("completed_surgery_id", ""))
	if not completed_surgery_id.is_empty():
		completed_surgeries_total += 1
		completed_surgeries_by_procedure[completed_surgery_id] = int(completed_surgeries_by_procedure.get(completed_surgery_id, 0)) + 1
		var surgery := surgery_definition(completed_surgery_id)
		var group := str(surgery.get("procedure_group", ""))
		if not group.is_empty():
			completed_surgeries_by_group[group] = int(completed_surgeries_by_group.get(group, 0)) + 1
	var xp_bonus := int(effects.get("surgery_xp_bonus", 0))
	if xp_bonus > 0:
		var before_level := surgery_level()
		surgery_xp += xp_bonus
		surgery_xp_history.append({
			"id": "special_event_%s" % str(definition.get("id", "")),
			"label": "%s · 手术经验 +%s" % [str(definition.get("title", "特殊活动")), xp_bonus],
			"effects": {"skill": surgery_level() - before_level},
			"surgery_id": completed_surgery_id,
			"xp": xp_bonus,
			"level_before": before_level,
			"level_after": surgery_level(),
		})
	var reputation := int(effects.get("reputation", 0))
	if reputation > 0:
		archived_player_effects.reputation = int(archived_player_effects.get("reputation", 0)) + reputation
		archived_player_effect_history.append({
			"id": "special_event_%s_reputation" % str(definition.get("id", "")),
			"label": "%s · 专业声望 +%s" % [str(definition.get("title", "特殊活动")), reputation],
			"effects": {"reputation": reputation},
		})

func choose_special_event(choice_id: String) -> Dictionary:
	var result := {"accepted": false, "day_finished": false, "event_finished": false}
	if not special_event_in_progress():
		return result
	var selected: Dictionary = {}
	for choice in active_special_event.current().get("choices", []):
		if str(choice.get("id", "")) == choice_id:
			selected = choice
			break
	if selected.is_empty() or not special_requirements_met(selected.get("requirements", [])):
		return result
	if not active_special_event.apply(choice_id):
		return result
	if active_special_event.cancelled:
		active_special_event_id = ""
		active_special_event = null
		active_mode = "encounter"
		result.accepted = true
		result.cancelled = true
		return result
	apply_special_event_choice_effects(selected)
	if not active_special_event.last_day_finished and not active_special_event.completed:
		normalize_special_event_position()
	result.accepted = true
	var consumes_full_day := bool(active_special_event.definition.get("consumes_full_day", true))
	result.day_finished = active_special_event.last_day_finished and consumes_full_day
	result.event_finished = active_special_event.completed
	if active_special_event.last_day_finished and consumes_full_day:
		if special_event_trigger_mode(active_special_event.definition) == "after_work":
			# The workday ledger may already have rolled over to tomorrow at 17:00,
			# while the evening event still belongs to the prior workday. Settle to
			# the morning after the authored event day instead of adding a second day.
			advance_story_to_day(active_special_event.started_day + active_special_event.step_index + 1, SHIFT_START_MINUTE)
		else:
			advance_story_to_future_day(1, SHIFT_START_MINUTE)
	if active_special_event.completed:
		var id := active_special_event_id
		special_event_completion_counts[id] = int(special_event_completion_counts.get(id, 0)) + 1
		var completion_day: int = int(active_special_event.started_day) + int(active_special_event.step_index) if special_event_trigger_mode(active_special_event.definition) == "after_work" else int(day_number())
		special_event_completion_days[id] = completion_day
		for flag in active_special_event.definition.get("completion_flags", []):
			set_story_flag(str(flag), true)
		apply_special_event_completion_effects(active_special_event.definition)
		for reward in active_special_event.definition.get("relationship_rewards", []):
			var actor_id := str(reward.get("actor_id", ""))
			var target_level := int(reward.get("target_level", 0))
			var relation := relation_for(actor_id)
			if relation.is_empty():
				continue
			if bool(reward.get("allow_level_skip", false)) and int(relation.get("level", 0)) < target_level:
				relation.level = target_level
				if not relation.rank_history.has(id):
					relation.rank_history.append(id)
				var benefit_id := str(reward.get("benefit_id", ""))
				if not benefit_id.is_empty() and not relation.unlocked_benefits.has(benefit_id):
					relation.unlocked_benefits.append(benefit_id)
			else:
				complete_rank_up(actor_id, id, target_level, str(reward.get("benefit_id", "")))
			if int(relation.get("level", 0)) >= target_level and not relation.event_history.has(id):
				relation.event_history.append(id)
			if bool(reward.get("award_event_familiarity", false)):
				add_familiarity(actor_id, relationship_event_familiarity_reward(actor_id, target_level))
		if test_save_target_event_id() == id:
			clear_test_save_target()
	return result

func finish_special_event() -> void:
	if active_special_event == null or not active_special_event.completed:
		return
	active_special_event_id = ""
	active_special_event = null
	active_mode = "encounter"

func settle_overtime(start_elapsed: int, action_minutes: int) -> bool:
	var start_schedule := schedule_at(start_elapsed)
	if pending_day_exit_workday > 0:
		pending_day_exit_clock += action_minutes
		# Subsequent clinical/epilogue actions belong to the same overtime
		# evening, not to the already reserved next-morning schedule slot.
		var excess := elapsed() - pending_day_exit_workday * SHIFT_MINUTES
		if excess > 0:
			discarded_overtime_minutes += excess
		return true
	if int(start_schedule.shift_minute) + action_minutes < SHIFT_MINUTES:
		return false
	pending_day_exit_workday = int(start_schedule.day)
	pending_day_exit_clock = SHIFT_START_MINUTE + int(start_schedule.shift_minute) + action_minutes
	var next_day_start := (start_elapsed / SHIFT_MINUTES + 1) * SHIFT_MINUTES
	var excess := elapsed() - next_day_start
	if excess > 0:
		discarded_overtime_minutes += excess
	return true

func pending_departure_context() -> Dictionary:
	if pending_day_exit_workday <= 0 or pending_day_exit_clock <= 0:
		return {}
	return {"workday": pending_day_exit_workday, "clock": pending_day_exit_clock}

func clear_pending_departure_context() -> void:
	pending_day_exit_workday = 0
	pending_day_exit_clock = 0

func after_work_last_offer_day(actor_id: String) -> int:
	var relation := relation_for(actor_id)
	if relation.is_empty():
		return -1000000
	for raw_flag in relation.get("flags", []):
		var flag := str(raw_flag)
		if flag.begins_with("after_work_offer_day:"):
			return int(flag.trim_prefix("after_work_offer_day:"))
	return -1000000

func set_after_work_last_offer_day(actor_id: String, workday: int) -> void:
	var relation := relation_for(actor_id)
	if relation.is_empty():
		return
	var flags: Array = relation.get("flags", []).duplicate()
	for index in range(flags.size() - 1, -1, -1):
		if str(flags[index]).begins_with("after_work_offer_day:"):
			flags.remove_at(index)
	flags.append("after_work_offer_day:%s" % workday)
	relation.flags = flags

func shared_surgery_count(actor_id: String) -> int:
	var relation := relation_for(actor_id)
	if relation.is_empty():
		return 0
	for raw_flag in relation.get("flags", []):
		var flag := str(raw_flag)
		if flag.begins_with("shared_surgeries:"):
			return maxi(0, int(flag.trim_prefix("shared_surgeries:")))
	# Compatibility for saves created before the persistent counter: retain every
	# successful operation still represented by a live case record.
	var legacy_count := 0
	for preparation in preops.values():
		if preparation.surgery_success and preparation.team.values().has(actor_id):
			legacy_count += 1
	return legacy_count

func persist_shared_surgery_counts(team: Dictionary) -> void:
	var recorded: Dictionary = {}
	for raw_actor_id in team.values():
		var actor_id := str(raw_actor_id)
		if actor_id.is_empty() or recorded.has(actor_id) or not staff_is_met(actor_id):
			continue
		recorded[actor_id] = true
		var relation := relation_for(actor_id)
		var flags: Array = relation.get("flags", []).duplicate()
		var had_persistent_count := flags.any(func(flag: Variant): return str(flag).begins_with("shared_surgeries:"))
		var count := shared_surgery_count(actor_id) + (1 if had_persistent_count else 0)
		for index in range(flags.size() - 1, -1, -1):
			if str(flags[index]).begins_with("shared_surgeries:"):
				flags.remove_at(index)
		flags.append("shared_surgeries:%s" % count)
		relation.flags = flags

func after_work_candidates(workday: int) -> Array[String]:
	var result: Array[String] = []
	for person in staff:
		var actor_id := str(person.get("id", ""))
		if actor_id.is_empty() or not staff_is_met(actor_id):
			continue
		if workday - after_work_last_offer_day(actor_id) < AFTER_WORK_COOLDOWN_WORKDAYS:
			continue
		result.append(actor_id)
	result.sort()
	return result

func after_work_roll(workday: int, variant: String, salt: String) -> int:
	return absi(hash("%s:after_work:%s:%s:%s" % [campaign_seed, workday, variant, salt])) % 100

func begin_after_work_departure(workday: int, departure_clock: int, advance_day_on_finish: bool) -> bool:
	if special_event_skips_departure():
		return false
	if not active_free_h_departure.is_empty():
		return false
	if not free_h_booking.is_empty() and int(free_h_booking.get("workday", 0)) == workday:
		return false
	# Both manual departure and deferred/automatic day-end enter here. Never
	# offer a walk while a patient is still waiting for clinical care.
	if active_encounter_in_progress() or active_surgery_committed() or active_surgery_in_progress() or unresolved_admitted_patient_exists():
		return false
	if not active_after_work_walk.is_empty() or special_event_in_progress() or not active_character_event_id.is_empty() or not active_micro_event_id.is_empty():
		return false
	var variant := "night" if departure_clock >= AFTER_WORK_NIGHT_MINUTE else "normal"
	var candidates := after_work_candidates(workday)
	if candidates.is_empty():
		return false
	var no_offer_chance := 40 if variant == "night" else 20
	if after_work_roll(workday, variant, "trigger") < no_offer_chance:
		return false
	var actor_id: String = candidates[after_work_roll(workday, variant, "actor") % candidates.size()]
	set_after_work_last_offer_day(actor_id, workday)
	active_after_work_walk = {
		"actor_id": actor_id,
		"variant": variant,
		"workday": workday,
		"departure_clock": departure_clock,
		"phase": "offer",
		"outcome": "",
		"reward": 0,
		"advance_day_on_finish": advance_day_on_finish,
		"return_mode": active_mode,
	}
	active_mode = "after_work_walk"
	return true

func choose_after_work_walk(invite: bool) -> Dictionary:
	if active_after_work_walk.is_empty() or str(active_after_work_walk.get("phase", "")) != "offer":
		return {}
	var actor_id := str(active_after_work_walk.actor_id)
	var variant := str(active_after_work_walk.variant)
	if not invite:
		active_after_work_walk.outcome = "skipped"
		active_after_work_walk.phase = "result"
		return active_after_work_walk
	var level := relationship_level(actor_id)
	var accept_chance := mini(95, 65 + level * 7)
	if variant == "night":
		accept_chance = mini(99, 90 + level * 2)
	var accepted := after_work_roll(int(active_after_work_walk.workday), variant, "accept:%s" % actor_id) < accept_chance
	if accepted:
		var requested_reward := 4 if variant == "night" else 2
		var before := int(relation_for(actor_id).get("familiarity", 0))
		add_familiarity(actor_id, requested_reward)
		active_after_work_walk.reward = int(relation_for(actor_id).get("familiarity", 0)) - before
		active_after_work_walk.outcome = "completed"
	else:
		active_after_work_walk.outcome = "declined"
	active_after_work_walk.phase = "result"
	return active_after_work_walk

func finish_after_work_walk() -> Dictionary:
	if active_after_work_walk.is_empty() or str(active_after_work_walk.get("phase", "")) != "result":
		return {}
	var completed := active_after_work_walk.duplicate(true)
	active_mode = str(active_after_work_walk.get("return_mode", "encounter"))
	active_after_work_walk.clear()
	return completed

func time_events_at(location_id: String) -> Array:
	var result: Array = []
	if special_event_in_progress():
		return result
	if is_hospital_closed_day() and location_id in ["clinic", "or"]:
		return result
	for definition in time_event_definitions.values():
		if definition.location_id == location_id and (definition.actor_id == null or staff_is_met(str(definition.actor_id))) and (definition.repeatable or not time_event_done(definition.id)):
			result.append(definition)
	result.sort_custom(func(a: Dictionary, b: Dictionary): return a.id < b.id)
	return result

func time_event_done(id: String) -> bool:
	for event in time_log:
		if event.id == id:
			return true
	return false

func spend_time(id: String) -> bool:
	last_error = "这个时间行动当前不可用。"
	if special_event_in_progress():
		last_error = "特殊活动进行中，不能安排其他行动。"
		return false
	if not time_event_definitions.has(id):
		return false
	var definition: Dictionary = time_event_definitions[id]
	if definition.actor_id != null and (not staff_is_met(str(definition.actor_id)) or str(definition.actor_id) not in staff_present_at(str(definition.location_id))):
		last_error = "这名职员现在不在这里，或者你们还没有认识。"
		return false
	if not definition.repeatable and time_event_done(id):
		last_error = "已经完成过这件事。"
		return false
	if id == "office_write_surgery_report" and reported_surgeries >= completed_surgeries_total:
		last_error = "目前没有尚未撰写报告的已完成手术。"
		return false
	var responses: Array = definition.responses
	var variant := randi_range(0, responses.size() - 1)
	last_time_event_response = responses[variant]
	var start_time := elapsed()
	time_log.append({"id": id, "start": start_time, "variant": variant})
	var effects: Dictionary = definition.get("effects", {})
	if not effects.is_empty():
		for metric in archived_player_effects:
			archived_player_effects[metric] = int(archived_player_effects[metric]) + int(effects.get(metric, 0))
		archived_player_effect_history.append({
			"id": "%s_%s" % [id, time_log.size()],
			"label": str(definition.label),
			"effects": effects.duplicate(true),
		})
	if id == "office_write_surgery_report":
		reported_surgeries += 1
	last_error = ""
	return true

func time_history() -> Array:
	var result: Array = []
	for event in time_log:
		var definition: Dictionary = time_event_definitions[event.id]
		var timing := schedule_at(int(event.start))
		var responses: Array = definition.responses
		var variant := int(event.get("variant", 0))
		result.append({
			"id": event.id,
			"label": definition.label,
			"minutes": definition.minutes,
			"day": timing.day,
			"date": calendar_iso(int(timing.day)),
			"calendar": calendar_compact_text(int(timing.day)),
			"clock": "%02d:%02d" % [timing.absolute_clock / 60, timing.absolute_clock % 60],
			"response": responses[variant]
		})
	return result

func schedule_at(total_minutes: int) -> Dictionary:
	var safe_total := maxi(0, total_minutes)
	var day_index := safe_total / SHIFT_MINUTES
	var shift_minute := safe_total % SHIFT_MINUTES
	return {
		"day": day_index + 1,
		"shift_minute": shift_minute,
		"remaining": SHIFT_MINUTES - shift_minute,
		"absolute_clock": SHIFT_START_MINUTE + shift_minute
	}

func day_number() -> int:
	return int(schedule_at(elapsed()).day)

func display_schedule() -> Dictionary:
	var schedule := world_display_schedule()
	if active_special_event != null:
		return active_special_event.presentation_schedule(schedule)
	return schedule

func world_display_schedule() -> Dictionary:
	if not active_free_h_departure.is_empty():
		return {"day": int(active_free_h_departure.workday), "absolute_clock": int(active_free_h_departure.clock)}
	# The workday ledger reserves tomorrow as soon as a shift overflows. The
	# visible scene still takes place at the actual departure/overtime time.
	if not active_after_work_walk.is_empty():
		return {"day": int(active_after_work_walk.workday), "absolute_clock": int(active_after_work_walk.departure_clock)}
	if pending_day_exit_workday > 0:
		return {"day": pending_day_exit_workday, "absolute_clock": pending_day_exit_clock}
	# Sunday dates are atomic full-day activities. Their scene clock can reach
	# evening without making the 480-minute work ledger advance to Monday early.
	# The existing Sunday completion command consumes the rest of the day once.
	if character_events.has(active_character_event_id):
		var event = character_events[active_character_event_id]
		if bool(event.definition.get("consumes_sunday", false)) and event.current().has("sunday_clock"):
			var schedule := schedule_at(elapsed())
			return {"day": int(schedule.day), "absolute_clock": maxi(int(schedule.absolute_clock), int(event.current().sunday_clock))}
	return schedule_at(elapsed())

func day_text() -> String:
	return "DAY %02d" % day_number()

func shift_remaining() -> int:
	return int(schedule_at(elapsed()).remaining)

func clock_text() -> String:
	var time: int = schedule_at(elapsed()).absolute_clock
	return "%02d:%02d" % [time / 60, time % 60]

func admitted_patient(patient_id: String) -> bool:
	if patient_id == str(active_staff_patient.get("staff_id", "")) and not active_staff_patient.is_empty():
		return true
	if completed_patient(patient_id):
		return false
	for visit in visits.values():
		if visit.definition.patient_id == patient_id and visit.admitted:
			return true
	return false

func completed_patient(patient_id: String) -> bool:
	for preparation in preops.values():
		if preparation.definition.patient_id == patient_id and (preparation.surgery_success or preparation.surgery_aborted):
			return true
	return false

func current_patient_id() -> String:
	if not active_staff_patient.is_empty():
		return ""
	for patient_id in patient_queue:
		if not completed_patient(patient_id) and not patient_referrals.has(patient_id):
			return patient_id
	return ""

func record_recent_patient(patient_id: String) -> void:
	if recent_patient_ids.has(patient_id):
		recent_patient_ids.erase(patient_id)
	recent_patient_ids.append(patient_id)
	while recent_patient_ids.size() > 2:
		recent_patient_ids.pop_front()

func archive_and_reset_patient(patient_id: String) -> void:
	for id in preops.keys():
		var preparation = preops[id]
		if preparation.definition.patient_id != patient_id:
			continue
		for metric in archived_player_effects:
			archived_player_effects[metric] = int(archived_player_effects[metric]) + int(preparation.player_effects.get(metric, 0))
		for record in preparation.player_effect_history:
			archived_player_effect_history.append(record.duplicate(true))
		archived_clinical_minutes += preparation.minutes
		preops.erase(id)
	for id in visits.keys():
		var visit = visits[id]
		if visit.definition.patient_id != patient_id:
			continue
		for metric in archived_player_effects:
			archived_player_effects[metric] = int(archived_player_effects[metric]) + int(visit.player_effects.get(metric, 0))
		for record in visit.player_effect_history:
			archived_player_effect_history.append(record.duplicate(true))
		archived_clinical_minutes += visit.minutes
		visits.erase(id)
	patient_referrals.erase(patient_id)
	# Reusing a template starts a new case; only the current case remembers this beat.
	first_surgery_diagnosis_shock_state.erase(patient_id)
	if not case_templates.is_empty():
		var choices: Array = case_templates.keys().filter(func(template_id: Variant): return case_template_available(str(template_id)))
		patient_cases[patient_id] = weighted_case_pick(choices)
		rebuild_patient_content(patient_cases)

func select_next_patient() -> void:
	if patient_definitions.is_empty():
		return
	var candidates: Array[String] = []
	for patient in patient_definitions:
		if not recent_patient_ids.has(patient.id):
			candidates.append(patient.id)
	if candidates.is_empty():
		for patient in patient_definitions:
			if recent_patient_ids.is_empty() or patient.id != recent_patient_ids.back():
				candidates.append(patient.id)
	if candidates.is_empty():
		candidates.append(patient_definitions[0].id)
	var selected: String = candidates[randi_range(0, candidates.size() - 1)]
	if completed_patient(selected) or patient_referrals.has(selected):
		archive_and_reset_patient(selected)
	patient_queue.erase(selected)
	patient_queue.push_front(selected)

func ensure_waiting_patient() -> void:
	if current_patient_id().is_empty():
		select_next_patient()

func advance_patient_rotation(patient_id: String) -> void:
	record_recent_patient(patient_id)
	select_next_patient()

func personal_nurse_candidates() -> Array[String]:
	var result: Array[String] = []
	for person in staff:
		var profile: Variant = person.get("personal_nurse", {})
		if str(person.get("profession", "")) != "nurse" or not profile is Dictionary or not bool(profile.get("eligible", false)):
			continue
		if staff_is_met(str(person.id)):
			result.append(str(person.id))
	return result

func set_personal_nurse(actor_id: String) -> bool:
	if not personal_nurse_system_unlocked:
		return false
	if not personal_nurse_candidates().has(actor_id):
		return false
	personal_nurse_id = actor_id
	return true

func resolve_outpatient_support_actor() -> String:
	if not probation_complete or not personal_nurse_system_unlocked:
		return "doc_aoi"
	if personal_nurse_candidates().has(personal_nurse_id):
		return personal_nurse_id
	return "nurse_haru" if personal_nurse_candidates().has("nurse_haru") else "doc_aoi"

func clinic_presentation(visit: RefCounted) -> Dictionary:
	var line: Dictionary = visit.presentation()
	if visit.action_log.is_empty() or str(line.speaker) != "outpatient_support":
		return line
	var action_id := str(visit.action_log.back())
	if action_id not in ["diagnose_appendix", "diagnose_gastro", "diagnose_observe"]:
		return line
	if action_id == "diagnose_appendix" and str(visit.diagnosis_feedback_actor_id).is_empty():
		return line
	# Keep the speaker who actually corrected this choice, but resolve prose
	# from the currently loaded language. Legacy visits keep the usual context.
	var actor_id := str(visit.diagnosis_feedback_actor_id)
	if actor_id.is_empty():
		actor_id = resolve_outpatient_support_actor()
	line.speaker = actor_id
	var person := staff_record(actor_id)
	var profile: Dictionary = person.get("personal_nurse", {})
	if actor_id == "doc_aoi" or str(person.get("profession", "")) != "nurse" or not bool(profile.get("eligible", false)):
		return line
	if action_id == "diagnose_appendix":
		var replies: Array = profile.get("dialogue", {}).get("diagnosis_correct_reply", [])
		if not replies.is_empty():
			line.text = replies[posmod(visit.action_log.size(), replies.size())]
		return line
	var corrections: Dictionary = profile.get("diagnosis_corrections", {})
	var correction := str(corrections.get(action_id, ""))
	if not correction.is_empty():
		line.text = correction
	return line

func resolve_preop_explainer() -> String:
	if personal_nurse_system_unlocked and personal_nurse_candidates().has(personal_nurse_id):
		return personal_nurse_id
	# Before Sakaguchi receives a formally assigned personal nurse, Nanase already
	# handles the ward-side preoperative explanations as part of her regular work.
	return "nurse_haru"

func personal_nurse_dialogue(kind: String) -> String:
	var actor_id := resolve_outpatient_support_actor()
	var person := staff_record(actor_id)
	var profile: Dictionary = person.get("personal_nurse", {})
	var dialogue: Dictionary = profile.get("dialogue", {})
	var lines: Array = dialogue.get(kind, [])
	if not lines.is_empty():
		return str(lines[randi_range(0, lines.size() - 1)])
	var fallback := {
		"next_test_hint": "如果要继续确认，我觉得下一步做这个检查比较合适。",
		"insufficient_evidence": "现在的信息还不够，我建议再检查一下。",
		"sufficient_evidence": "我觉得目前的结果已经足够了。",
		"chatter": "下一位患者已经到了。坂口医生，准备好后我们就继续吧。",
	}
	return str(fallback.get(kind, fallback.chatter))

func after_work_dialogue(kind: String) -> String:
	if active_after_work_walk.is_empty():
		return ""
	var actor_id := str(active_after_work_walk.get("actor_id", ""))
	var person := staff_record(actor_id)
	var lines: Array = person.get("after_work_short_chat", []) if kind == "chat" else person.get("after_work_companion_dialogue", {}).get(kind, [])
	if lines.is_empty():
		return ""
	var seed_text := "%s:%s:%s" % [actor_id, active_after_work_walk.get("workday", 1), kind]
	return str(lines[posmod(seed_text.hash(), lines.size())])

func award_personal_nurse_outpatient_familiarity() -> void:
	if not personal_nurse_system_unlocked:
		return
	var actor_id := resolve_outpatient_support_actor()
	if actor_id != "doc_aoi":
		add_familiarity(actor_id, 1)

func referral_doctor(patient_id: String) -> String:
	return str(patient_referrals.get(patient_id, ""))

func refer_current_patient(doctor_id: String) -> bool:
	last_error = "无法完成转诊。"
	var patient_id := current_patient_id()
	if patient_id.is_empty() or admitted_patient(patient_id) or completed_patient(patient_id):
		last_error = "只有当前尚未住院的候诊患者可以转诊。"
		return false
	var doctor_exists := false
	for person in staff:
		if person.id == doctor_id and person.profession == "doctor":
			doctor_exists = true
			break
	if not doctor_exists:
		last_error = "请选择一名医生接收转诊。"
		return false
	if not staff_is_met(doctor_id):
		last_error = "只能将患者转诊给已经认识的医生。"
		return false
	patient_referrals[patient_id] = doctor_id
	if not active_id.is_empty() and definitions.has(active_id) and definitions[active_id].patient_id == patient_id:
		active_id = ""
	active_mode = "encounter"
	advance_patient_rotation(patient_id)
	last_error = ""
	return true

func encounter_id_for_patient(patient_id: String) -> String:
	for id in definitions:
		if definitions[id].patient_id == patient_id:
			return id
	return ""

func record_completed_surgery_progress(preparation: RefCounted, surgery_id: String) -> void:
	var procedure_group := surgery_procedure_group(surgery_id)
	if procedure_group == "female_pelvic":
		increment_character_progress_counter("", "gynecology_case_count")
	var no_anesthesia: bool = preparation.flags.has("no_anesthesia_confirmed")
	var recorded: Dictionary = {}
	for role_id in preparation.team:
		var actor_id := str(preparation.team[role_id])
		if actor_id.is_empty():
			continue
		increment_character_progress_counter(actor_id, "completed_surgeries_as_%s" % str(role_id))
		if no_anesthesia:
			increment_character_progress_counter(actor_id, "completed_no_anesthesia_surgeries_as_%s" % str(role_id))
		if recorded.has(actor_id):
			continue
		recorded[actor_id] = true
		increment_character_progress_counter(actor_id, "completed_surgeries")
		if not procedure_group.is_empty():
			increment_character_progress_counter(actor_id, "completed_surgeries_in_group_%s" % procedure_group)
		if no_anesthesia:
			increment_character_progress_counter(actor_id, "completed_no_anesthesia_surgeries")
	if preparation.flags.has("manual_ward_preparation_complete"):
		var ward_role_id := str(preparation.definition.get("ward_role", {}).get("id", ""))
		var ward_nurse_id := str(preparation.team.get(ward_role_id, ""))
		if not ward_nurse_id.is_empty():
			increment_character_progress_counter(ward_nurse_id, "assisted_player_ward_preparation")

func surgery_quality_record(surgery_id: String) -> Dictionary:
	return surgical_quality_records.get(surgery_id, {}).duplicate(true)

func update_surgical_quality_record(preparation: RefCounted) -> Dictionary:
	var surgery_id := str(preparation.procedure_id)
	if not preparation.pilot_surgery() or preparation.flags.has("quick_surgery"):
		return surgery_quality_record(surgery_id)
	var summary: Dictionary = preparation.pilot_technical_summary()
	var grade := str(summary.get("surgical_quality_grade", "F"))
	var score := int(summary.get("surgical_quality_score", 0))
	var record := surgery_quality_record(surgery_id)
	var best_score := maxi(int(record.get("best_score", 0)), score)
	var completions := int(record.get("manual_completions", 0)) + 1
	var quick_unlocked := bool(record.get("quick_surgery_unlocked", false)) or grade == "A" or grade == "S"
	record = {
		"best_grade": grade if score >= int(record.get("best_score", -1)) else str(record.get("best_grade", "F")),
		"best_score": best_score,
		"manual_completions": completions,
		"quick_surgery_unlocked": quick_unlocked,
		"last_grade": grade,
		"last_score": score,
		"last_summary": summary,
	}
	surgical_quality_records[surgery_id] = record
	return record

func finish_active_surgery() -> bool:
	if active_preop_id.is_empty() or not preops.has(active_preop_id):
		return false
	var preparation = preops[active_preop_id]
	if not preparation.surgery_success:
		return false
	var completed_patient_id: String = preparation.definition.patient_id
	var surgery_id := str(preparation.procedure_id)
	update_surgical_quality_record(preparation)
	record_completed_surgery_progress(preparation, surgery_id)
	persist_shared_surgery_counts(preparation.team)
	award_surgery_team_familiarity(preparation.team, familiarity_case_tier(surgery_id))
	unlock_procedure(str(preparation.procedure_id))
	award_surgery_xp(preparation)
	award_leadership_xp(preparation)
	train_surgery_team(preparation.team, surgery_id)
	award_surgery_reputation(surgery_id, str(preparation.procedure_name), preparation)
	if staff_patient_agreement_fulfilled(preparation):
		var actor_id := str(preparation.definition.staff_patient_id)
		var counts: Dictionary = staff_patient_practice_counts.get(actor_id, {})
		counts[surgery_id] = staff_patient_practice_count(actor_id, surgery_id) + 1
		staff_patient_practice_counts[actor_id] = counts
	completed_surgeries_total += 1
	completed_surgeries_by_procedure[preparation.procedure_id] = int(completed_surgeries_by_procedure.get(preparation.procedure_id, 0)) + 1
	var completed_group := surgery_procedure_group(str(preparation.procedure_id))
	if not completed_group.is_empty():
		completed_surgeries_by_group[completed_group] = int(completed_surgeries_by_group.get(completed_group, 0)) + 1
	pending_surgery_day_transition = false
	active_preop_id = ""
	active_mode = "encounter"
	active_id = ""
	pending_encounter_day_transition = false
	if preparation.is_staff_patient():
		retire_staff_patient(preparation)
	else:
		award_personal_nurse_outpatient_familiarity()
		advance_patient_rotation(completed_patient_id)
	# Rotate the waiting queue without starting the next encounter. Settlement
	# returns to a saveable directory boundary; only explicit admission opens it.
	return true

func finish_active_surgery_abort() -> bool:
	if active_preop_id.is_empty() or not preops.has(active_preop_id):
		return false
	var preparation = preops[active_preop_id]
	if not preparation.surgery_aborted:
		return false
	var patient_id := str(preparation.definition.patient_id)
	pending_surgery_day_transition = false
	active_preop_id = ""
	active_mode = "encounter"
	active_id = ""
	pending_encounter_day_transition = false
	if preparation.is_staff_patient():
		retire_staff_patient(preparation)
	else:
		advance_patient_rotation(patient_id)
	return true

func set_intraoperative_crisis_enabled(enabled: bool) -> void:
	intraoperative_crisis_enabled = enabled

func procedure_sweep_unlocked(surgery_id: String) -> bool:
	if not procedure_unlocked(surgery_id) or int(completed_surgeries_by_procedure.get(surgery_id, 0)) <= 0:
		return false
	if surgery_id not in ["surgery_appendix", "surgery_open_cholecystectomy", "surgery_open_inguinal_hernia"]:
		return true
	var record := surgery_quality_record(surgery_id)
	# Saves created before Surgical Quality existed are grandfathered. Fresh
	# completions always create a record and therefore use the A/S gate.
	if record.is_empty():
		record = {"quick_surgery_unlocked": true, "legacy_grandfathered": true}
		surgical_quality_records[surgery_id] = record
	return bool(record.get("quick_surgery_unlocked", false))

func sweep_active_surgery(surgery_id: String) -> Dictionary:
	last_error = "这项术式尚未完成过，不能扫荡。"
	if active_preop_id.is_empty() or not preops.has(active_preop_id) or not procedure_sweep_unlocked(surgery_id):
		return {}
	var preparation = preops[active_preop_id]
	var sweep_stage := str(preparation.current().get("kind", ""))
	if sweep_stage not in ["preparation", "surgery_select"] or not str(preparation.procedure_id).is_empty():
		last_error = "请在病房准备或选择术式时使用扫荡。"
		return {}
	if sweep_stage == "preparation" and not preparation.sweep_team_ready():
		last_error = "请先选齐手术团队与病房准备护士。"
		return {}
	if surgery_id != str(preparation.definition.get("surgery_id", "")):
		last_error = "扫荡只能用于当前患者的适应术式。"
		return {}
	var before_elapsed := elapsed()
	var before_minutes: int = preparation.minutes
	var level_before := surgery_level()
	var xp_before := surgery_xp
	var leadership_before := leadership_level()
	var leadership_xp_before := leadership_xp
	var reputation_before := int(player_attributes().get("reputation", 0))
	var team_before: Dictionary = preparation.team.duplicate(true)
	var familiarity_before := {}
	for actor_id in team_before.values():
		var id := str(actor_id)
		if not id.is_empty() and staff_is_met(id) and not familiarity_before.has(id):
			familiarity_before[id] = int(relation_for(id).get("familiarity", 0))
	if not preparation.apply({"kind": "sweep", "id": surgery_id}):
		last_error = preparation.last_error
		return {}
	var crossed_day := settle_overtime(before_elapsed, preparation.minutes - before_minutes)
	var procedure_name := str(preparation.procedure_name)
	var duration_minutes: int = int(preparation.minutes) - before_minutes
	var procedure_duration_minutes: int = int(preparation.procedure_total_minutes())
	var postoperative_wrap_up_minutes: int = int(preparation.POSTOPERATIVE_WRAP_UP_MINUTES)
	if not finish_active_surgery():
		return {}
	var team_rewards: Array[Dictionary] = []
	for actor_id in familiarity_before:
		var relation := relation_for(actor_id)
		var gained := int(relation.get("familiarity", 0)) - int(familiarity_before[actor_id])
		if gained > 0:
			var person_name: String = actor_id
			for person in staff:
				if str(person.get("id", "")) == actor_id:
					person_name = str(person.get("name", actor_id))
					break
			team_rewards.append({"actor_id": actor_id, "name": person_name, "familiarity": gained})
	last_error = ""
	return {
		"procedure_id": surgery_id,
		"procedure_name": procedure_name,
		"duration_minutes": duration_minutes,
		"procedure_duration_minutes": procedure_duration_minutes,
		"postoperative_wrap_up_minutes": postoperative_wrap_up_minutes,
		"xp": surgery_xp - xp_before,
		"level_before": level_before,
		"level_after": surgery_level(),
		"leadership_xp": leadership_xp - leadership_xp_before,
		"leadership_before": leadership_before,
		"leadership_after": leadership_level(),
		"reputation": int(player_attributes().get("reputation", 0)) - reputation_before,
		"team_rewards": team_rewards,
		"crossed_day": crossed_day,
	}

func surgery_procedure_group(surgery_id: String) -> String:
	for surgery in surgery_definitions:
		if str(surgery.get("id", "")) == surgery_id:
			return str(surgery.get("procedure_group", ""))
	return ""

func surgery_definition(surgery_id: String) -> Dictionary:
	for surgery in surgery_definitions:
		if str(surgery.get("id", "")) == surgery_id:
			return surgery
	return {}

func surgery_reputation_profile(surgery_id: String) -> Dictionary:
	var surgery := surgery_definition(surgery_id)
	if surgery.is_empty() or str(surgery.get("status", "ready")) == "placeholder":
		return {}
	var tier := Progression.reputation_tier(int(surgery.get("base_difficulty", 50)))
	var profile: Dictionary = Progression.REPUTATION_PROFILES[tier].duplicate(true)
	profile["tier"] = tier
	var advanced_referral := str(surgery.get("case_pool", "")) == "advanced_referral" or str(surgery.get("catalog_visibility", "standard")) == "advanced_referral"
	if not advanced_referral:
		profile["award"] = Progression.ordinary_surgery_reputation(int(surgery.get("base_difficulty", 50)))
		profile["per_case_cap"] = Progression.ORDINARY_REPUTATION_MAX
	profile["base"] = int(profile.award)
	return profile

func surgery_reputation_award_for(surgery_id: String, current_reputation: int = -10000) -> int:
	var profile := surgery_reputation_profile(surgery_id)
	if profile.is_empty():
		return 0
	var current := int(player_attributes().get("reputation", 0)) if current_reputation == -10000 else current_reputation
	var cap := int(profile.cap)
	if current >= cap:
		return 0
	var award := int(profile.base)
	if current >= int(profile.soft_cap):
		award = ceili(float(award) * 0.5)
	return mini(award, cap - current)

func award_surgery_reputation(surgery_id: String, procedure_name: String = "", preparation: RefCounted = null) -> int:
	if preparation != null and preparation.is_staff_patient():
		return 0
	var deliberately_wrong: bool = preparation != null and bool(preparation.procedure_mismatch)
	var award := 0 if deliberately_wrong else surgery_reputation_award_for(surgery_id)
	if preparation != null and preparation.pilot_surgery() and preparation.surgery_success and not preparation.flags.has("quick_surgery") and award > 0:
		var quality_multiplier: float = float({"S": 1.20, "A": 1.10, "B": 1.00, "C": 0.75, "F": 0.00}.get(preparation.surgical_quality_grade(), 1.0))
		award = floori(float(award) * quality_multiplier)
	var profile := surgery_reputation_profile(surgery_id)
	if not profile.is_empty():
		# Apply caps after quality bonuses as well, including the last point below
		# the cumulative reputation ceiling for this difficulty tier.
		award = mini(award, int(profile.get("per_case_cap", award)))
		award = mini(award, maxi(0, int(profile.cap) - int(player_attributes().get("reputation", 0))))
	if award > 0:
		add_player_attribute_effect("reputation", award, "surgery_reputation_%s_%s" % [surgery_id, completed_surgeries_total + 1], "%s · %s术式声望 +%s" % [procedure_name if not procedure_name.is_empty() else surgery_id, profile.label, award])
	var penalty := 0
	if deliberately_wrong:
		penalty += Progression.WRONG_PROCEDURE_REPUTATION_PENALTY
	if preparation != null and preparation.flags.has("no_anesthesia_confirmed"):
		successful_no_anesthesia_surgeries += 1
		penalty += Progression.NO_ANESTHESIA_REPUTATION_PENALTY
	if penalty != 0:
		add_player_attribute_effect("reputation", penalty, "surgery_penalty_%s_%s" % [surgery_id, completed_surgeries_total + 1], "%s · 手术处置影响 %s" % [procedure_name if not procedure_name.is_empty() else surgery_id, penalty])
	return award + penalty

func procedure_unlocked(surgery_id: String) -> bool:
	var definition := surgery_definition(surgery_id)
	if definition.is_empty() or str(definition.get("status", "ready")) == "placeholder":
		return false
	var requirement_flag := procedure_unlock_requirement_flag(surgery_id)
	if not requirement_flag.is_empty():
		return story_flag(requirement_flag)
	return unlocked_procedure_ids.has(surgery_id)

func unlock_procedure(surgery_id: String) -> bool:
	var definition := surgery_definition(surgery_id)
	if definition.is_empty() or str(definition.get("status", "ready")) == "placeholder":
		return false
	if not unlocked_procedure_ids.has(surgery_id):
		unlocked_procedure_ids.append(surgery_id)
	for preparation in preops.values():
		preparation.set_procedure_unlocks(unlocked_procedure_ids, true)
	return true

func procedure_catalog() -> Array:
	var result: Array = []
	for surgery in surgery_definitions:
		if str(surgery.get("catalog_visibility", "standard")) == "advanced_referral" and not advanced_referral_system_unlocked():
			continue
		var entry: Dictionary = surgery.duplicate(true)
		entry.unlocked = procedure_unlocked(str(surgery.id))
		result.append(entry)
	return result

func advanced_referral_eligible() -> bool:
	var attributes: Dictionary = player_attributes()
	return surgery_level() >= ADVANCED_REFERRAL_UNLOCK_SURGERY and int(attributes.get("reputation", 0)) >= ADVANCED_REFERRAL_UNLOCK_REPUTATION

func advanced_referral_system_unlocked() -> bool:
	return story_flag("advanced_referral_random_cases_enabled")

func advanced_referral_case_available(definition: Dictionary) -> bool:
	if definition.is_empty():
		return false
	var referral_id: String = str(definition.get("id", ""))
	var tutorial_case := referral_id == "advanced_referral_tutorial_chisato_case"
	if tutorial_case and not advanced_referral_eligible():
		return false
	if not tutorial_case and not advanced_referral_system_unlocked():
		return false
	if bool(definition.get("unique_per_campaign", true)) and story_flag("advanced_referral_completed_" + referral_id):
		return false
	return special_requirements_met(definition.get("unlock_requirements", []))

func advanced_referral_timing_status(definition: Dictionary, requested_start_day: int = -1) -> Dictionary:
	var requested_day: int = day_number() if requested_start_day < 1 else requested_start_day
	var start_day: int = requested_day
	var duration: int = maxi(1, int(definition.get("duration_days", ADVANCED_REFERRAL_DEFAULT_DURATION_DAYS)))
	var referral_priority: int = int(definition.get("priority", ADVANCED_REFERRAL_DEFAULT_PRIORITY))
	var blocked_by: Array[String] = []
	# A referral is not discarded when a fixed, higher-priority story event owns
	# its proposed days. Move it after that event and resolve again in case several
	# protected events are adjacent.
	for _attempt in range(special_event_definitions.size() + 2):
		var end_day: int = start_day + duration - 1
		if start_day > GAME_DURATION_DAYS or end_day > GAME_DURATION_DAYS:
			return {"status": "expired", "requested_start_day": requested_day, "start_day": start_day, "end_day": end_day, "blocked_by": blocked_by}
		if end_day >= FINAL_WEEK_START_DAY:
			return {"status": "final_week_reserved", "requested_start_day": requested_day, "start_day": start_day, "end_day": end_day, "blocked_by": blocked_by}
		var blocking_end := 0
		var blocking_id := ""
		for scheduled in special_event_definitions.values():
			if bool(scheduled.get("developer_only", false)) or special_event_done(str(scheduled.get("id", ""))) or not special_event_base_requirements_met(scheduled):
				continue
			var timing: Dictionary = scheduled.get("timing", {})
			if int(timing.get("priority", 0)) <= referral_priority:
				continue
			var scheduled_start: int = special_event_trigger_day(scheduled)
			var scheduled_end: int = scheduled_start + maxi(1, int(scheduled.get("duration_days", 1))) - 1
			if start_day <= scheduled_end and scheduled_start <= end_day and scheduled_end > blocking_end:
				blocking_end = scheduled_end
				blocking_id = str(scheduled.get("id", ""))
		if blocking_end <= 0:
			return {"status": "postponed" if start_day != requested_day else "available", "requested_start_day": requested_day, "start_day": start_day, "end_day": end_day, "blocked_by": blocked_by}
		blocked_by.append(blocking_id)
		start_day = blocking_end + 1
	return {"status": "unresolvable", "requested_start_day": requested_day, "start_day": start_day, "end_day": start_day + duration - 1, "blocked_by": blocked_by}

func advanced_referral_can_start(definition: Dictionary, requested_start_day: int = -1) -> bool:
	if special_event_in_progress() or active_surgery_in_progress() or not advanced_referral_case_available(definition):
		return false
	return str(advanced_referral_timing_status(definition, requested_start_day).get("status", "")) == "available"

func complete_advanced_referral_case(referral_id: String) -> void:
	if not referral_id.is_empty():
		set_story_flag("advanced_referral_completed_" + referral_id, true)

func career_ending_metrics() -> Dictionary:
	var attributes: Dictionary = player_attributes()
	return {
		"surgery": surgery_level(),
		"reputation": int(attributes.get("reputation", 0)),
		"advanced_referral_unlocked": advanced_referral_system_unlocked(),
		"completed_surgeries": completed_surgeries_total,
	}

func surgery_case_tier(surgery_id: String) -> String:
	var definition := surgery_definition(surgery_id)
	if definition.is_empty():
		return "standard"
	if str(definition.get("catalog_visibility", "standard")) == "advanced_referral" and int(definition.get("base_difficulty", 0)) >= 95:
		return "legendary"
	return Progression.reputation_tier(int(definition.get("base_difficulty", 50)))

func familiarity_case_tier(surgery_id: String) -> String:
	var tier := surgery_case_tier(surgery_id)
	if tier in ["extreme", "legendary"]:
		return "extreme"
	if tier == "advanced":
		return "advanced"
	return "routine"

func staff_skill_value(actor_id: String, skill_id: String) -> int:
	for person in staff:
		if str(person.get("id", "")) == actor_id:
			return int(person.get("skills", {}).get(skill_id, 0))
	return 0

func role_training_skill(role_id: String) -> String:
	if role_id in ["assistant_surgeon", "first_assistant", "second_assistant"]:
		return "surgery"
	if role_id == "ward_nurse":
		return "patient_care"
	if role_id in ["scrub_nurse", "primary_scrub", "secondary_scrub"]:
		return "instrument_handling"
	if role_id in ["circulating_nurse", "primary_circulating", "secondary_circulating"]:
		return "teamwork"
	return ""

func team_relevant_skill_average(team: Dictionary) -> float:
	var values: Array[float] = []
	for role_id in team:
		var skill_id := role_training_skill(str(role_id))
		var actor_id := str(team[role_id])
		if not skill_id.is_empty() and not actor_id.is_empty():
			values.append(float(staff_skill_value(actor_id, skill_id)))
	if values.is_empty():
		return -1.0
	var total := 0.0
	for value in values:
		total += value
	return total / float(values.size())

func leadership_xp_to_next_level(level: int) -> float:
	if level < Progression.LEADERSHIP_START_LEVEL or level >= Progression.LEADERSHIP_MAX_LEVEL:
		return 0.0
	return Progression.LEADERSHIP_XP_BASE * pow(Progression.LEADERSHIP_XP_GROWTH, level - Progression.LEADERSHIP_START_LEVEL)

func leadership_xp_for_level(target_level: int) -> float:
	var total := 0.0
	for level in range(Progression.LEADERSHIP_START_LEVEL, clampi(target_level, Progression.LEADERSHIP_START_LEVEL, Progression.LEADERSHIP_MAX_LEVEL)):
		total += leadership_xp_to_next_level(level)
	return total

func leadership_level() -> int:
	var level := Progression.LEADERSHIP_START_LEVEL
	var remaining := maxf(0.0, leadership_xp)
	while level < Progression.LEADERSHIP_MAX_LEVEL:
		var required := leadership_xp_to_next_level(level)
		if remaining + 0.00001 < required:
			break
		remaining -= required
		level += 1
	return level

func leadership_level_progress() -> Dictionary:
	var level := leadership_level()
	if level >= Progression.LEADERSHIP_MAX_LEVEL:
		return {"level": level, "current_xp": 0.0, "required_xp": 0.0, "total_xp": leadership_xp}
	return {"level": level, "current_xp": leadership_xp - leadership_xp_for_level(level), "required_xp": leadership_xp_to_next_level(level), "total_xp": leadership_xp}

func award_leadership_xp(preparation: RefCounted) -> float:
	if leadership_level() >= Progression.LEADERSHIP_MAX_LEVEL:
		return 0.0
	var tier := surgery_case_tier(str(preparation.procedure_id))
	var team_average := team_relevant_skill_average(preparation.team)
	var team_class: Dictionary = Progression.leadership_team_class(team_average if team_average >= 0.0 else 70.0)
	var award := float(Progression.LEADERSHIP_CASE_BASE.get(tier, 2.0)) * float(team_class.multiplier)
	var cap := leadership_xp_for_level(Progression.LEADERSHIP_MAX_LEVEL)
	award = minf(award, maxf(0.0, cap - leadership_xp))
	if award <= 0.0:
		return 0.0
	var before := leadership_level()
	leadership_xp += award
	leadership_xp_history.append({
		"id": "leadership_%s_%s" % [preparation.procedure_id, completed_surgeries_total + 1],
		"label": "%s · 领导经验 +%.1f" % [preparation.procedure_name, award],
		"surgery_id": str(preparation.procedure_id), "xp": award,
		"team_average": team_average, "team_class": str(team_class.id),
		"level_before": before, "level_after": leadership_level(),
		"effects": {"leadership": leadership_level() - before},
	})
	return award

func staff_training_credit_cost(skill_level: int) -> int:
	if skill_level < 60:
		return 1
	if skill_level < 80:
		return 2
	if skill_level < 90:
		return 4
	return 0

func train_surgery_team(team: Dictionary, surgery_id: String) -> Array[Dictionary]:
	var tier := surgery_case_tier(surgery_id)
	var credits := 1
	if tier == "advanced":
		credits = 2
	elif tier in ["extreme", "legendary"]:
		credits = 3
	var result: Array[Dictionary] = []
	var trained := {}
	for role_id in team:
		var actor_id := str(team[role_id])
		var skill_id := role_training_skill(str(role_id))
		var key := actor_id + ":" + skill_id
		if actor_id.is_empty() or skill_id.is_empty() or trained.has(key):
			continue
		trained[key] = true
		var current := staff_skill_value(actor_id, skill_id)
		if current >= 90:
			continue
		if not staff_training_credits.has(actor_id):
			staff_training_credits[actor_id] = {}
		var stored := int(staff_training_credits[actor_id].get(skill_id, 0)) + credits
		var gained := 0
		var cost := staff_training_credit_cost(current)
		while cost > 0 and stored >= cost and current < 90:
			stored -= cost
			current += 1
			gained += 1
			cost = staff_training_credit_cost(current)
		staff_training_credits[actor_id][skill_id] = stored
		if gained > 0:
			if not staff_skill_levels.has(actor_id):
				staff_skill_levels[actor_id] = {}
			staff_skill_levels[actor_id][skill_id] = current
			for person in staff:
				if str(person.get("id", "")) == actor_id:
					person.skills[skill_id] = current
					break
			result.append({"actor_id": actor_id, "skill_id": skill_id, "gained": gained, "level": current})
	return result

func surgery_xp_to_next_level(level: int) -> int:
	if level < 50:
		return 0
	if level >= 100:
		return 0
	# Early operations should produce visible growth, while mastery takes
	# progressively more practice. Round to five so the UI stays readable.
	return maxi(5, roundi((50.0 * pow(1.12, level - 50)) / 5.0) * 5)

func surgery_xp_for_level(target_level: int) -> int:
	var total := 0
	for level in range(50, clampi(target_level, 50, 100)):
		total += surgery_xp_to_next_level(level)
	return total

func surgery_level() -> int:
	var level := 50
	var remaining := maxi(0, surgery_xp)
	while level < 100:
		var required := surgery_xp_to_next_level(level)
		if remaining < required:
			break
		remaining -= required
		level += 1
	return level

func surgery_level_progress() -> Dictionary:
	var level := surgery_level()
	if level >= 100:
		return {"level": 100, "current_xp": 0, "required_xp": 0, "total_xp": surgery_xp}
	var current_floor := surgery_xp_for_level(level)
	return {"level": level, "current_xp": surgery_xp - current_floor, "required_xp": surgery_xp_to_next_level(level), "total_xp": surgery_xp}

func surgery_learning_efficiency(difficulty_gap: int) -> float:
	if difficulty_gap < -20:
		return 0.10
	if difficulty_gap < -5:
		return 0.50
	if difficulty_gap <= 10:
		return 1.00
	if difficulty_gap <= 20:
		return 1.25
	if difficulty_gap <= 30:
		return 0.75
	return 0.20

func surgery_xp_award_for(preparation: RefCounted) -> int:
	var practice_multiplier := 1.0
	if preparation.is_staff_patient():
		if not staff_patient_agreement_fulfilled(preparation):
			return 0
		practice_multiplier = staff_patient_xp_multiplier(str(preparation.definition.staff_patient_id), str(preparation.procedure_id))
		if practice_multiplier <= 0.0:
			return 0
	var surgery := surgery_definition(str(preparation.procedure_id))
	if surgery.is_empty() or str(surgery.get("status", "ready")) == "placeholder":
		return 0
	var current_level := surgery_level()
	var ceiling := int(surgery.get("training_ceiling", 100))
	if current_level >= ceiling:
		return 0
	var effective_difficulty := clampi(int(surgery.get("base_difficulty", 50)) + int(preparation.definition.get("difficulty_modifier", 0)), 0, 100)
	var efficiency := surgery_learning_efficiency(effective_difficulty - current_level)
	var quality := maxf(0.50, 1.0 - float(preparation.procedure_corrections) * 0.10)
	var indication := 0.20 if preparation.procedure_mismatch else 1.0
	var team_average := team_relevant_skill_average(preparation.team)
	var team_multiplier := Progression.team_surgery_xp_multiplier(team_average) if team_average >= 0.0 else 1.0
	var interaction_bonus := maxi(0, int(preparation.get("sensory_interaction_xp_bonus")))
	var quality_multiplier := 1.0
	if preparation.pilot_surgery() and preparation.surgery_success and not preparation.flags.has("quick_surgery"):
		quality_multiplier = float({"S": 1.15, "A": 1.08, "B": 1.00, "C": 0.85, "F": 0.50}.get(preparation.surgical_quality_grade(), 1.0))
	var raw_award := maxi(0, roundi(float(surgery.duration_minutes) * efficiency * quality * indication * team_multiplier * quality_multiplier) + interaction_bonus)
	var remaining_to_ceiling := maxi(0, surgery_xp_for_level(ceiling) - surgery_xp)
	if remaining_to_ceiling <= 0:
		return 0
	return roundi(float(maxi(1, mini(raw_award, remaining_to_ceiling))) * practice_multiplier)

func award_surgery_xp(preparation: RefCounted) -> int:
	var before_level := surgery_level()
	var award := surgery_xp_award_for(preparation)
	if award <= 0:
		return 0
	surgery_xp += award
	var after_level := surgery_level()
	surgery_xp_history.append({
		"id": "surgery_training_%s_%s" % [preparation.procedure_id, completed_surgeries_total + 1],
		"label": "%s · 手术经验 +%s" % [preparation.procedure_name, award],
		"effects": {"skill": after_level - before_level},
		"surgery_id": str(preparation.procedure_id),
		"xp": award,
		"level_before": before_level,
		"level_after": after_level,
		"team_average": team_relevant_skill_average(preparation.team),
	})
	return award

func player_attributes() -> Dictionary:
	var result: Dictionary = PLAYER_ATTRIBUTE_BASE.duplicate(true)
	for metric in result:
		if metric == "skill":
			result[metric] = surgery_level()
			continue
		if metric == "leadership":
			result[metric] = leadership_level()
			continue
		result[metric] = clampi(int(result[metric]) + int(archived_player_effects.get(metric, 0)), int(PLAYER_ATTRIBUTE_MIN.get(metric, 0)), int(PLAYER_ATTRIBUTE_MAX.get(metric, 100)))
	for preparation in preops.values():
		for metric in result:
			if metric in ["skill", "leadership"]:
				continue
			result[metric] = clampi(int(result[metric]) + int(preparation.player_effects.get(metric, 0)), int(PLAYER_ATTRIBUTE_MIN.get(metric, 0)), int(PLAYER_ATTRIBUTE_MAX.get(metric, 100)))
	for visit in visits.values():
		for metric in result:
			if metric in ["skill", "leadership"]:
				continue
			result[metric] = clampi(int(result[metric]) + int(visit.player_effects.get(metric, 0)), int(PLAYER_ATTRIBUTE_MIN.get(metric, 0)), int(PLAYER_ATTRIBUTE_MAX.get(metric, 100)))
	return result

func charm_tier() -> String:
	return Progression.charm_tier(int(player_attributes().get("charm", 0)))

func presence_tier() -> String:
	return Progression.presence_tier(int(player_attributes().get("presence", 0)))

func patient_reaction_context() -> Dictionary:
	# Narrative content decides whether these tendencies matter. The generic
	# system only exposes tiers and enforces the authored maximum of one step.
	return {
		"charm_tier": charm_tier(),
		"presence_tier": presence_tier(),
		"maximum_case_modifier": 1,
	}

func player_attribute_history() -> Array[Dictionary]:
	var result: Array[Dictionary] = archived_player_effect_history.duplicate(true)
	result.append_array(surgery_xp_history.duplicate(true))
	result.append_array(leadership_xp_history.duplicate(true))
	for preparation in preops.values():
		for record in preparation.player_effect_history:
			result.append(record.duplicate(true))
	for visit in visits.values():
		for record in visit.player_effect_history:
			result.append(record.duplicate(true))
	return result

func snapshot() -> Dictionary:
	var progress := {}
	var diagnosis_shock_visit_variants := {}
	for id in visits:
		progress[id] = visits[id].snapshot_state()
		var variant_id := str(visits[id].definition.get("first_surgery_diagnosis_shock_variant_id", ""))
		if not variant_id.is_empty():
			diagnosis_shock_visit_variants[id] = variant_id
	var preparation_logs := {}
	for id in preops:
		preparation_logs[id] = preops[id].snapshot_state()
	var active_special_event_snapshot: Variant = null
	if active_special_event != null:
		active_special_event_snapshot = {
			"id": active_special_event_id,
			"choices": active_special_event.choices.duplicate(),
			"started_day": active_special_event.started_day,
		}
	var active_adult_intimacy_snapshot: Variant = null
	if active_adult_intimacy != null:
		active_adult_intimacy_snapshot = active_adult_intimacy.snapshot()
		active_adult_intimacy_snapshot["return_mode"] = adult_intimacy_return_mode
	return {"version": SAVE_VERSION, "content_version": CONTENT_VERSION,
		"save_format": STATE_DICTIONARY_SAVE_FORMAT,
		"active_id": "", "progress": progress, "preops": preparation_logs,
		"active_preop_id": "", "active_mode": "encounter",
		"patient_cases": patient_cases.duplicate(true),
		"patient_queue": patient_queue.duplicate(),
		"patient_referrals": patient_referrals.duplicate(true),
		"active_staff_patient": active_staff_patient.duplicate(true),
		"staff_patient_practice_counts": staff_patient_practice_counts.duplicate(true),
		"first_surgery_diagnosis_shock_state": first_surgery_diagnosis_shock_state.duplicate(true),
		"diagnosis_shock_visit_variants": diagnosis_shock_visit_variants,
		"recent_patient_ids": recent_patient_ids.duplicate(),
		"completed_surgeries_total": completed_surgeries_total,
		"completed_surgeries_by_group": completed_surgeries_by_group.duplicate(true),
		"completed_surgeries_by_procedure": completed_surgeries_by_procedure.duplicate(true),
		"surgical_quality_records": surgical_quality_records.duplicate(true),
		"character_progress_counters": character_progress_counters.duplicate(true),
		"surgery_xp": surgery_xp,
		"surgery_xp_history": surgery_xp_history.duplicate(true),
		"leadership_xp": leadership_xp,
		"leadership_xp_history": leadership_xp_history.duplicate(true),
		"staff_skill_levels": staff_skill_levels.duplicate(true),
		"staff_training_credits": staff_training_credits.duplicate(true),
		"successful_no_anesthesia_surgeries": successful_no_anesthesia_surgeries,
		"reported_surgeries": reported_surgeries,
		"unlocked_procedure_ids": unlocked_procedure_ids.duplicate(),
		"archived_player_effects": archived_player_effects.duplicate(true),
		"archived_player_effect_history": archived_player_effect_history.duplicate(true),
		"pending_encounter_day_transition": pending_encounter_day_transition,
		"pending_surgery_day_transition": pending_surgery_day_transition,
		"campaign_seed": campaign_seed,
		"intraoperative_crisis_enabled": intraoperative_crisis_enabled,
		"sunday_history": sunday_history.duplicate(true),
		"time_log": time_log.duplicate(true),
		"discarded_overtime_minutes": discarded_overtime_minutes,
		"story_time_advance_minutes": story_time_advance_minutes,
		"archived_clinical_minutes": archived_clinical_minutes,
		"relationship_state": relationships.duplicate(true),
		"character_events": character_event_order.map(func(id: String): return {"id": id, "state": character_events[id].snapshot_state()}),
		"active_character_event_id": active_character_event_id,
		"micro_events": micro_event_order.map(func(id: String): return {"id": id, "state": micro_events[id].snapshot_state()}),
		"active_micro_event_id": active_micro_event_id,
		"story_flags": story_flags.duplicate(true),
		"probation_complete": probation_complete,
		"personal_nurse_system_unlocked": personal_nurse_system_unlocked,
		"personal_nurse_id": personal_nurse_id,
		"special_event_completion_counts": special_event_completion_counts.duplicate(true),
		"special_event_completion_days": special_event_completion_days.duplicate(true),
		"active_special_event": active_special_event_snapshot,
		"adult_intimacy_unlocks": adult_intimacy_unlocks.duplicate(true),
		"free_h_booking": free_h_booking.duplicate(true),
		"active_adult_intimacy": active_adult_intimacy_snapshot}

func migrate_legacy_surgery_events(source: Array) -> Array:
	# The first surgery interaction prototype placed the awake-patient choices before
	# the incision. Preserve those saves by translating only logs that contain the
	# retired setup actions; new logs never contain these IDs.
	var setup_ids := ["setup_explain", "setup_coach", "setup_brief"]
	var choice_id := ""
	var selected_surgery_id := ""
	var setup_index := -1
	for index in source.size():
		var event: Variant = source[index]
		if not event is Dictionary or event.get("kind") != "action":
			if event is Dictionary and event.get("kind") == "procedure":
				selected_surgery_id = str(event.get("id", ""))
			continue
		var action_id: String = event.get("id", "")
		if action_id in ["choose_general", "choose_epidural", "choose_local", "choose_none"]:
			choice_id = action_id
		if action_id in setup_ids:
			setup_index = index
			break
	if setup_index < 0:
		# General anesthesia had no setup node. A contact action immediately after
		# induction identifies its retired interaction path.
		if choice_id == "choose_general":
			for index in source.size():
				var event: Variant = source[index]
				if event is Dictionary and String(event.get("id", "")).begins_with("contact_"):
					setup_index = index
					break
		if setup_index < 0:
			return source.duplicate(true)
	var migrated: Array = []
	for index in setup_index:
		migrated.append(source[index].duplicate(true))
	var start_id: String = {
		"choose_general": "start_general_surgery",
		"choose_epidural": "start_epidural_surgery",
		"choose_local": "start_local_surgery",
		"choose_none": "insist_without_anesthesia",
	}.get(choice_id, "")
	var incision_id: String = {
		"choose_general": "incise_general",
		"choose_epidural": "incise_epidural",
		"choose_local": "incise_local",
		"choose_none": "incise_none",
	}.get(choice_id, "")
	if start_id.is_empty() or incision_id.is_empty():
		return source.duplicate(true)
	for action_id in [start_id, "request_scalpel", "assistant_stabilize", incision_id]:
		migrated.append({"kind": "action", "id": action_id})
	var had_execute := false
	if choice_id == "choose_general":
		migrated.append({"kind": "action", "id": "complete_general_operation"})
		for index in range(setup_index, source.size()):
			var event: Variant = source[index]
			if event is Dictionary and event.get("id") == "execute_confirmed_procedure":
				had_execute = true
	else:
		for index in range(setup_index + 1, source.size()):
			var event: Variant = source[index]
			if event is Dictionary and event.get("id") == "execute_confirmed_procedure":
				had_execute = true
	migrated.append({"kind": "legacy_surgery_bridge"})
	if had_execute:
		for surgery in surgery_definitions:
			if surgery.id != selected_surgery_id:
				continue
			for flow_step in surgery.get("stages", []):
				var selected_option: Dictionary = flow_step.options[0]
				if flow_step.kind == "decision":
					for option in flow_step.options:
						if option.correct:
							selected_option = option
							break
				migrated.append({"kind": "surgery_step", "id": selected_option.id})
			break
		migrated.append({"kind": "action", "id": "execute_confirmed_procedure"})
	return migrated

func migrate_surgery_flow_acknowledgements(source: Array) -> Array:
	# v11 advanced directly from a team choice into the next options or patient
	# interlude. Insert the new response acknowledgement during replay.
	var migrated: Array = []
	for event in source:
		migrated.append(event.duplicate(true) if event is Dictionary else event)
		if event is Dictionary and event.get("kind") == "surgery_step":
			migrated.append({"kind": "flow_acknowledge"})
	return migrated

func migrate_surgery_patient_acknowledgements(source: Array) -> Array:
	# v13 displayed patient or narrative responses on top of the following surgery
	# choices. Insert a separate continue event so old saves replay through the new
	# response page before the next set of options is shown.
	var migrated: Array = []
	for event in source:
		migrated.append(event.duplicate(true) if event is Dictionary else event)
		if not event is Dictionary or event.get("kind") != "action":
			continue
		var action_id: String = str(event.get("id", ""))
		if action_id in ["incise_epidural", "incise_local", "incise_none", "complete_general_operation"] or action_id.begins_with("contact_") or action_id.begins_with("ongoing_") or action_id.begins_with("closure_"):
			migrated.append({"kind": "patient_acknowledge"})
	return migrated

func migrate_wrong_surgery_decision_retries(source: Array) -> Array:
	# Before v16, acknowledging an assistant correction advanced the operation as
	# if the wrong answer had completed the step. Preserve later progress by
	# replaying the correct option immediately after that historical acknowledgement.
	var selected_surgery_id := ""
	for event in source:
		if event is Dictionary and event.get("kind") == "procedure":
			selected_surgery_id = str(event.get("id", ""))
	var wrong_to_correct := {}
	for surgery in surgery_definitions:
		if surgery.id != selected_surgery_id:
			continue
		for flow_step in surgery.get("stages", []):
			if flow_step.kind != "decision":
				continue
			var correct_id := ""
			for option in flow_step.options:
				if option.correct:
					correct_id = str(option.id)
			for option in flow_step.options:
				if not option.correct and not correct_id.is_empty():
					wrong_to_correct[str(option.id)] = correct_id
		break
	var migrated: Array = []
	for index in source.size():
		var event: Variant = source[index]
		migrated.append(event.duplicate(true) if event is Dictionary else event)
		if not event is Dictionary or event.get("kind") != "flow_acknowledge" or index == 0:
			continue
		var previous: Variant = source[index - 1]
		if previous is Dictionary and previous.get("kind") == "surgery_step":
			var wrong_id := str(previous.get("id", ""))
			if wrong_to_correct.has(wrong_id):
				migrated.append({"kind": "surgery_step", "id": wrong_to_correct[wrong_id]})
				migrated.append({"kind": "flow_acknowledge"})
	return migrated

func migrate_full_undress_exam(source: Array) -> Array:
	# v16 stored the old direct targeted-exam action. Recreate that completed exam
	# through the new request and authoritative-consent branch, then omit the
	# retired transition action because the branch now enters testing directly.
	if not source.has("abdomen"):
		return source.duplicate(true)
	var migrated: Array = []
	for event in source:
		if event in ["vitals", "abdomen", "to_tests"]:
			continue
		migrated.append(event)
		if event == "to_exam":
			if source.has("vitals"):
				migrated.append("vitals")
			migrated.append("request_full_undress")
			migrated.append("authoritative_full_undress")
	return migrated

func operative_preparation_events(branch: String) -> Array:
	var preparation_events: Array = [
		{"kind": "action", "id": "operative_positioning"},
		{"kind": "action", "id": "ack_positioning"},
		{"kind": "action", "id": "urinary_catheterization"},
		{"kind": "action", "id": "ack_catheterization"},
		{"kind": "action", "id": "skin_disinfection"},
		{"kind": "action", "id": "ack_disinfection"},
		{"kind": "action", "id": "incision_marking"},
		{"kind": "action", "id": "ack_marking_" + branch},
	]
	# Before v15, insisting without anesthesia also issued the start command. The
	# split action preserves that already-made decision after the new preparations.
	if branch == "none":
		preparation_events.append({"kind": "action", "id": "start_none_surgery"})
	return preparation_events

func migrate_operative_preparation_events(source: Array) -> Array:
	# v14 moved directly from anesthesia selection to the start command. Insert the
	# new preparation chain only when an older log had already advanced beyond it;
	# a save made immediately after anesthesia selection resumes at the first step.
	var migrated: Array = []
	var branch := ""
	var inserted := false
	for index in source.size():
		var event: Variant = source[index]
		var action_id: String = str(event.get("id", "")) if event is Dictionary and event.get("kind") == "action" else ""
		if action_id == "choose_general":
			branch = "general"
		elif action_id == "choose_epidural":
			branch = "epidural"
		elif action_id == "choose_local":
			branch = "local"
		elif action_id == "choose_none":
			branch = "none"
		var old_start_id: String = {
			"general": "start_general_surgery",
			"epidural": "start_epidural_surgery",
			"local": "start_local_surgery",
		}.get(branch, "")
		if not inserted and not old_start_id.is_empty() and action_id == old_start_id:
			migrated.append_array(operative_preparation_events(branch))
			inserted = true
		migrated.append(event.duplicate(true) if event is Dictionary else event)
		if not inserted and branch == "none" and action_id == "insist_without_anesthesia" and index + 1 < source.size():
			migrated.append_array(operative_preparation_events(branch))
			inserted = true
	return migrated

func restore(data: Variant) -> bool:
	# Restore into temporary objects; live progress is replaced only after all
	# required global state has been validated. New saves restore state directly;
	# only pre-state-dictionary saves use the legacy event-log compatibility path.
	last_error = "存档格式不正确，当前进度未改变。"
	restore_warnings.clear()
	if not data is Dictionary:
		return false
	var version := int(data.get("version", -1))
	if version < MIN_SUPPORTED_SAVE_VERSION or version > SAVE_VERSION or data.get("content_version") != CONTENT_VERSION:
		last_error = "存档版本不兼容，当前进度未改变。"
		return false
	var save_format := str(data.get("save_format", "legacy_event_log_v1"))
	var state_dictionary_save := save_format == STATE_DICTIONARY_SAVE_FORMAT
	if save_format not in ["legacy_event_log_v1", STATE_DICTIONARY_SAVE_FORMAT]:
		last_error = "存档格式不兼容，当前进度未改变。"
		return false
	if state_dictionary_save and version < SAVE_VERSION:
		last_error = "存档状态字典版本不兼容，当前进度未改变。"
		return false
	var migration_seed := 1
	var raw_migration_seed: Variant = data.get("campaign_seed", 1)
	if (raw_migration_seed is int or raw_migration_seed is float) and int(raw_migration_seed) > 0:
		migration_seed = int(raw_migration_seed)
	var migration_rng := RandomNumberGenerator.new()
	migration_rng.seed = migration_seed
	var saved_story_flags_for_cases: Dictionary = data.get("story_flags", {}) if data.get("story_flags", {}) is Dictionary else {}
	if not data.get("progress") is Dictionary or not data.get("active_id") is String:
		return false
	var restored_patient_queue: Array[String] = []
	if version >= 9:
		if not valid_patient_queue(data.get("patient_queue")) or not data.get("patient_referrals") is Dictionary:
			last_error = "存档中的患者队列或转诊记录无效，当前进度未改变。"
			return false
		restored_patient_queue = complete_patient_queue(data.patient_queue, migration_rng)
		if restored_patient_queue.size() != data.patient_queue.size():
			restore_warnings.append("已按当前患者名单补齐队列与新增患者的病例分配。")
	else:
		for patient in patient_definitions:
			restored_patient_queue.append(str(patient.id))
	var restored_patient_cases: Dictionary = {}
	if not case_templates.is_empty():
		restored_patient_cases = data.get("patient_cases", {}) if version >= 7 else legacy_patient_cases()
		if not valid_patient_cases(restored_patient_cases):
			last_error = "存档中的患者病例分配无效，当前进度未改变。"
			return false
		if restored_patient_cases.size() < patient_definitions.size():
			restore_warnings.append("已按当前患者名单补齐队列与新增患者的病例分配。")
		restored_patient_cases = complete_patient_cases(restored_patient_cases, restored_patient_queue, migration_rng, saved_story_flags_for_cases)
	elif version >= 7 and (not data.get("patient_cases") is Dictionary or not data.patient_cases.is_empty()):
		return false
	var restored_patient_referrals: Dictionary = {}
	var restored_diagnosis_shock_state: Dictionary = {}
	var restored_diagnosis_shock_visit_variants: Dictionary = {}
	var restored_recent_patient_ids: Array[String] = []
	var restored_completed_surgeries_total := 0
	var restored_completed_surgeries_by_group: Dictionary = {}
	var restored_completed_surgeries_by_procedure: Dictionary = {}
	var restored_surgical_quality_records: Dictionary = {}
	var restored_character_progress_counters: Dictionary = {}
	var restored_surgery_xp := 0
	var restored_surgery_xp_history: Array[Dictionary] = []
	var restored_leadership_xp := 0.0
	var restored_leadership_xp_history: Array[Dictionary] = []
	var restored_staff_skill_levels: Dictionary = {}
	var restored_staff_training_credits: Dictionary = {}
	var restored_successful_no_anesthesia_surgeries := 0
	var restored_reported_surgeries := 0
	var restored_unlocked_procedure_ids: Array[String] = starting_procedure_ids()
	var restored_archived_player_effects := zero_player_effects()
	var restored_archived_player_effect_history: Array[Dictionary] = []
	# Optional for existing v35/v36 saves; time already lost by older builds is unknowable.
	var raw_archived_minutes: Variant = data.get("archived_clinical_minutes", 0)
	if not (raw_archived_minutes is int or raw_archived_minutes is float) or not is_finite(float(raw_archived_minutes)) or float(raw_archived_minutes) != floorf(float(raw_archived_minutes)) or float(raw_archived_minutes) < 0 or float(raw_archived_minutes) > 2147483647:
		return false
	var restored_archived_clinical_minutes := int(raw_archived_minutes)
	var restored_campaign_seed := migration_seed
	var restored_crisis_enabled := true
	var restored_sunday_history: Array[Dictionary] = []
	var raw_character_progress_counters: Variant = data.get("character_progress_counters", {})
	if not raw_character_progress_counters is Dictionary:
		return false
	for actor_id in raw_character_progress_counters:
		var raw_counters: Variant = raw_character_progress_counters[actor_id]
		if not actor_id is String or not raw_counters is Dictionary:
			return false
		if actor_id != "global" and staff_record(actor_id).is_empty():
			restore_warnings.append("忽略已不在当前医护名单中的角色进度：%s" % str(actor_id))
			continue
		var counters: Dictionary = {}
		for counter_id in raw_counters:
			var raw_count: Variant = raw_counters[counter_id]
			if not counter_id is String or str(counter_id).is_empty() or not (raw_count is int or raw_count is float) or float(raw_count) != floorf(float(raw_count)) or int(raw_count) < 0:
				return false
			counters[counter_id] = int(raw_count)
		restored_character_progress_counters[actor_id] = counters
	var raw_crisis_enabled: Variant = data.get("intraoperative_crisis_enabled", true)
	if not raw_crisis_enabled is bool:
		return false
	restored_crisis_enabled = bool(raw_crisis_enabled)
	var raw_diagnosis_shock_state: Variant = data.get("first_surgery_diagnosis_shock_state")
	if not raw_diagnosis_shock_state is Dictionary:
		return false
	for patient_id in raw_diagnosis_shock_state:
		var record: Variant = raw_diagnosis_shock_state[patient_id]
		if not patient_id is String or patient_definition(patient_id).is_empty() or not record is Dictionary:
			return false
		var variant_id: Variant = record.get("first_surgery_diagnosis_shock_variant_id")
		if record.get("first_surgery_diagnosis_shock_seen") != true or not variant_id is String or not diagnosis_shock_definitions.has(variant_id):
			return false
		restored_diagnosis_shock_state[patient_id] = {
			"first_surgery_diagnosis_shock_seen": true,
			"first_surgery_diagnosis_shock_variant_id": variant_id,
		}
	var raw_diagnosis_shock_visit_variants: Variant = data.get("diagnosis_shock_visit_variants")
	if not raw_diagnosis_shock_visit_variants is Dictionary:
		return false
	for visit_id in raw_diagnosis_shock_visit_variants:
		var variant_id: Variant = raw_diagnosis_shock_visit_variants[visit_id]
		if not visit_id is String or not data.progress.has(visit_id) or not variant_id is String or not diagnosis_shock_definitions.has(variant_id):
			return false
		restored_diagnosis_shock_visit_variants[visit_id] = variant_id
	if version >= 27:
		var raw_seed: Variant = data.get("campaign_seed")
		if not (raw_seed is int or raw_seed is float) or int(raw_seed) < 1 or not data.get("sunday_history") is Array:
			return false
		restored_campaign_seed = int(raw_seed)
		for record in data.sunday_history:
			if not record is Dictionary or int(record.get("day", 0)) < 1 or str(record.get("activity_id", "")).is_empty():
				return false
			restored_sunday_history.append(record.duplicate(true))
	if version >= 28:
		var raw_surgery_xp: Variant = data.get("surgery_xp")
		if not (raw_surgery_xp is int or raw_surgery_xp is float) or float(raw_surgery_xp) != floorf(float(raw_surgery_xp)) or int(raw_surgery_xp) < 0 or int(raw_surgery_xp) > surgery_xp_for_level(100):
			return false
		if not data.get("surgery_xp_history") is Array or not data.get("unlocked_procedure_ids") is Array:
			return false
		restored_surgery_xp = int(raw_surgery_xp)
		restored_surgery_xp_history.clear()
		for record in data.surgery_xp_history:
			var raw_record_xp: Variant = record.get("xp") if record is Dictionary else null
			if not record is Dictionary or not record.get("id") is String or not record.get("label") is String or not record.get("effects") is Dictionary or not record.get("surgery_id") is String or surgery_definition(str(record.get("surgery_id", ""))).is_empty() or not (raw_record_xp is int or raw_record_xp is float) or float(raw_record_xp) != floorf(float(raw_record_xp)) or int(raw_record_xp) < 0:
				return false
			restored_surgery_xp_history.append(record.duplicate(true))
		restored_unlocked_procedure_ids.clear()
		for surgery_id in data.unlocked_procedure_ids:
			if not surgery_id is String or restored_unlocked_procedure_ids.has(surgery_id):
				return false
			var procedure := surgery_definition(surgery_id)
			if procedure.is_empty() or str(procedure.get("status", "ready")) == "placeholder":
				return false
			restored_unlocked_procedure_ids.append(surgery_id)
		var raw_leadership_xp: Variant = data.get("leadership_xp")
		if not (raw_leadership_xp is int or raw_leadership_xp is float) or float(raw_leadership_xp) < 0.0 or float(raw_leadership_xp) > leadership_xp_for_level(100):
			return false
		restored_leadership_xp = float(raw_leadership_xp)
		if not data.get("leadership_xp_history") is Array or not data.get("staff_skill_levels") is Dictionary or not data.get("staff_training_credits") is Dictionary:
			return false
		for record in data.leadership_xp_history:
			if not record is Dictionary or not record.get("id") is String or not record.get("surgery_id") is String:
				return false
			restored_leadership_xp_history.append(record.duplicate(true))
		for actor_id in data.staff_skill_levels:
			if not actor_id is String or not data.staff_skill_levels[actor_id] is Dictionary:
				return false
			if not base_staff_skills.has(actor_id):
				restore_warnings.append("忽略已不在当前医护名单中的技能记录：%s" % str(actor_id))
				continue
			for skill_id in data.staff_skill_levels[actor_id]:
				var raw_level: Variant = data.staff_skill_levels[actor_id][skill_id]
				if not base_staff_skills[actor_id].has(skill_id) or not (raw_level is int or raw_level is float) or float(raw_level) != floorf(float(raw_level)) or int(raw_level) < int(base_staff_skills[actor_id][skill_id]) or int(raw_level) > 90:
					return false
			restored_staff_skill_levels[actor_id] = data.staff_skill_levels[actor_id].duplicate(true)
		for actor_id in data.staff_training_credits:
			if not actor_id is String or not data.staff_training_credits[actor_id] is Dictionary:
				return false
			if not base_staff_skills.has(actor_id):
				restore_warnings.append("忽略已不在当前医护名单中的培训记录：%s" % str(actor_id))
				continue
			for skill_id in data.staff_training_credits[actor_id]:
				var raw_credits: Variant = data.staff_training_credits[actor_id][skill_id]
				if not base_staff_skills[actor_id].has(skill_id) or not (raw_credits is int or raw_credits is float) or float(raw_credits) != floorf(float(raw_credits)) or int(raw_credits) < 0:
					return false
			restored_staff_training_credits[actor_id] = data.staff_training_credits[actor_id].duplicate(true)
		for field in ["successful_no_anesthesia_surgeries", "reported_surgeries"]:
			var raw_count: Variant = data.get(field)
			if not (raw_count is int or raw_count is float) or float(raw_count) != floorf(float(raw_count)) or int(raw_count) < 0:
				return false
		restored_successful_no_anesthesia_surgeries = int(data.successful_no_anesthesia_surgeries)
		restored_reported_surgeries = int(data.reported_surgeries)
	if version >= 29:
		var raw_procedure_counts: Variant = data.get("completed_surgeries_by_procedure")
		if not raw_procedure_counts is Dictionary:
			return false
		for surgery_id in raw_procedure_counts:
			var raw_count: Variant = raw_procedure_counts[surgery_id]
			if not surgery_id is String or surgery_definition(surgery_id).is_empty() or not (raw_count is int or raw_count is float) or float(raw_count) != floorf(float(raw_count)) or int(raw_count) < 0:
				return false
			restored_completed_surgeries_by_procedure[surgery_id] = int(raw_count)
		var raw_quality_records: Variant = data.get("surgical_quality_records", {})
		if not raw_quality_records is Dictionary:
			return false
		for surgery_id in raw_quality_records:
			if not surgery_id is String or surgery_definition(surgery_id).is_empty() or not raw_quality_records[surgery_id] is Dictionary:
				return false
			var quality_record: Dictionary = raw_quality_records[surgery_id]
			if quality_record.has("best_score") and not (quality_record.best_score is int or quality_record.best_score is float):
				return false
			if quality_record.has("quick_surgery_unlocked") and not quality_record.quick_surgery_unlocked is bool:
				return false
			var sanitized_quality_record := quality_record.duplicate(true)
			# Patient experience is settlement-only flavor. Strip it from old
			# summaries during migration so a later save cannot preserve it.
			var last_summary: Variant = sanitized_quality_record.get("last_summary")
			if last_summary is Dictionary:
				last_summary.erase("patient_experience_grade")
				last_summary.erase("patient_experience_score")
				sanitized_quality_record["last_summary"] = last_summary
			restored_surgical_quality_records[surgery_id] = sanitized_quality_record
	elif version >= 28:
		# Version 28 recorded the procedure ID with each positive training award.
		# One record is enough to prove that the operation was completed before.
		for record in restored_surgery_xp_history:
			var surgery_id := str(record.get("surgery_id", ""))
			if not surgery_id.is_empty():
				restored_completed_surgeries_by_procedure[surgery_id] = maxi(1, int(restored_completed_surgeries_by_procedure.get(surgery_id, 0)))
	if version >= 9:
		for patient_id in data.patient_referrals:
			if not patient_id is String or not data.patient_referrals[patient_id] is String or patient_id not in restored_patient_queue:
				return false
			var doctor_id: String = data.patient_referrals[patient_id]
			var doctor_exists := false
			for person in staff:
				if person.id == doctor_id and person.profession == "doctor":
					doctor_exists = true
					break
			if not doctor_exists:
				return false
			restored_patient_referrals[patient_id] = doctor_id
	if version >= 11:
		if not valid_recent_patients(data.get("recent_patient_ids")) or not data.get("archived_player_effects") is Dictionary or not data.get("archived_player_effect_history") is Array:
			return false
		for patient_id in data.recent_patient_ids:
			restored_recent_patient_ids.append(patient_id)
		if version >= 23:
			var raw_completed_surgeries: Variant = data.get("completed_surgeries_total")
			if not (raw_completed_surgeries is int or raw_completed_surgeries is float) or float(raw_completed_surgeries) != floorf(float(raw_completed_surgeries)) or int(raw_completed_surgeries) < 0:
				return false
			restored_completed_surgeries_total = int(raw_completed_surgeries)
		else:
			# Legacy saves retained at most the two most recent completed/referral
			# patients. This conservative migration is sufficient for the first
			# Asuka encounter's two-operation threshold without inventing progress.
			restored_completed_surgeries_total = restored_recent_patient_ids.size()
		if version >= 24:
			var raw_group_counts: Variant = data.get("completed_surgeries_by_group")
			if not raw_group_counts is Dictionary:
				return false
			var known_groups := {}
			for surgery in surgery_definitions:
				known_groups[str(surgery.get("procedure_group", ""))] = true
			for group_id in raw_group_counts:
				var raw_group_count: Variant = raw_group_counts[group_id]
				if not group_id is String or not known_groups.has(group_id) or not (raw_group_count is int or raw_group_count is float) or float(raw_group_count) != floorf(float(raw_group_count)) or int(raw_group_count) < 0:
					return false
				restored_completed_surgeries_by_group[group_id] = int(raw_group_count)
		for metric in restored_archived_player_effects:
			var raw_effect: Variant = data.archived_player_effects.get(metric)
			if not (raw_effect is int or raw_effect is float) or float(raw_effect) != floorf(float(raw_effect)):
				return false
			restored_archived_player_effects[metric] = int(raw_effect)
		if version < 28:
			restored_surgery_xp = surgery_xp_for_level(clampi(50 + int(restored_archived_player_effects.skill), 50, 100))
			restored_archived_player_effects.skill = 0
		if data.archived_player_effect_history.size() > 5000:
			return false
		for record in data.archived_player_effect_history:
			if not record is Dictionary or not record.get("id") is String or not record.get("label") is String or not record.get("effects") is Dictionary:
				return false
			restored_archived_player_effect_history.append(record.duplicate(true))
	var restored_definitions := encounter_definitions_for(restored_patient_cases, restored_diagnosis_shock_state)
	var restored_seen_shock_definitions := encounter_definitions_for(restored_patient_cases, restored_diagnosis_shock_state, true)
	var restored_preop_definitions := preop_definitions_for(restored_patient_cases)
	# Optional fields keep existing version-36 saves compatible. Validate in
	# temporary objects so a malformed admission never mutates the running game.
	var restored_staff_patient: Variant = data.get("active_staff_patient", {})
	var restored_practice_counts: Variant = data.get("staff_patient_practice_counts", {})
	if not restored_staff_patient is Dictionary or not restored_practice_counts is Dictionary:
		return false
	for actor_id in restored_practice_counts:
		if StaffPatient.profile(str(actor_id)).is_empty() or not restored_practice_counts[actor_id] is Dictionary:
			return false
		for procedure in restored_practice_counts[actor_id]:
			var count: Variant = restored_practice_counts[actor_id][procedure]
			if surgery_definition(str(procedure)).is_empty() or not (count is int or count is float) or float(count) != floorf(float(count)) or count < 0 or count > 1000000:
				return false
	if not restored_staff_patient.is_empty():
		if restored_staff_patient.size() != 2 or not restored_staff_patient.get("staff_id") is String or not restored_staff_patient.get("procedure_id") is String:
			return false
		var config := StaffPatient.profile(str(restored_staff_patient.staff_id))
		if config.is_empty() or str(restored_staff_patient.procedure_id) not in restored_unlocked_procedure_ids:
			return false
		if not data.get("story_flags") is Dictionary:
			return false
		for flag in config.get("unlock_flags", []):
			if not bool(data.story_flags.get(flag, false)):
				return false
		var staff_definition := staff_patient_preop_definition(restored_staff_patient)
		if staff_definition.is_empty():
			return false
		restored_preop_definitions[StaffPatient.PREOP_ID] = staff_definition
	var rebuilt := {}
	for id in data.progress:
		if not restored_definitions.has(id):
			if state_dictionary_save:
				return false
			restore_warnings.append("跳过无法识别的病例状态：%s" % str(id))
			continue
		var restored_visit_definition: Dictionary = restored_definitions[id]
		if restored_diagnosis_shock_visit_variants.has(id):
			restored_visit_definition = restored_seen_shock_definitions[id]
			if str(restored_visit_definition.get("first_surgery_diagnosis_shock_variant_id", "")) != str(restored_diagnosis_shock_visit_variants[id]):
				return false
			restored_definitions[id] = restored_visit_definition
		var visit = Encounter.new(restored_visit_definition, false)
		if state_dictionary_save:
			if not data.progress[id] is Dictionary or not visit.restore_state(data.progress[id]):
				last_error = "存档中的病例状态无效，当前进度未改变。"
				return false
			if not visit.diagnosis_feedback_actor_id.is_empty() and staff_record(visit.diagnosis_feedback_actor_id).is_empty():
				return false
		else:
			if not data.progress[id] is Array or data.progress[id].size() > 500:
				restore_warnings.append("跳过无法解析的病例日志：%s" % str(id))
				continue
			var events: Array = data.progress[id]
			if version < 17:
				events = migrate_full_undress_exam(events)
			for event_index in events.size():
				var event: Variant = events[event_index]
				if not event is String or not visit.apply(event):
					restore_warnings.append("跳过病例 %s 的第 %d 个旧节点" % [str(id), event_index + 1])
		rebuilt[id] = visit
	if not state_dictionary_save and data.active_id != "" and not rebuilt.has(data.active_id):
		restore_warnings.append("旧存档的当前病例无法恢复，已返回医院导览。")
	if state_dictionary_save and data.active_id != "" and not rebuilt.has(data.active_id):
		return false
	var rebuilt_preops := {}
	var mode := "encounter"
	var current_preop := ""
	if version >= 2:
		var valid_modes := ["encounter", "preop", "character_event"]
		if version >= 10:
			valid_modes.append("micro_event")
		if version >= 25:
			valid_modes.append("special_event")
		if version >= 35:
			valid_modes.append("adult_intimacy")
		if not data.get("preops") is Dictionary or not data.get("active_preop_id") is String or data.get("active_mode") not in valid_modes:
			return false
		for id in data.preops:
			if not restored_preop_definitions.has(id):
				if state_dictionary_save:
					return false
				restore_warnings.append("跳过无法识别的术前状态：%s" % str(id))
				continue
			var definition: Dictionary = restored_preop_definitions[id]
			if not definition.has("staff_patient_id") and (not rebuilt.has(definition.encounter_id) or not rebuilt[definition.encounter_id].admitted):
				if state_dictionary_save:
					last_error = "存档中的术前准备缺少住院记录。"
					return false
				restore_warnings.append("跳过缺少住院记录的术前状态：%s" % str(id))
				continue
			var prep_patients := patient_definitions.duplicate()
			if definition.has("staff_patient_id"):
				prep_patients.append(patient_definition(str(definition.staff_patient_id)))
			var prep = Preop.new(definition, staff, surgery_definitions, prep_patients, [], false, surgery_team_dialogue_profiles, patient_interaction_definitions, temporary_condition_definitions, [], false, palpation_profile_definitions, awake_special_bark_definitions)
			var preop_events: Array = []
			if state_dictionary_save:
				if not data.preops[id] is Dictionary or not prep.restore_state(data.preops[id]):
					last_error = "存档中的术前状态无效，当前进度未改变。"
					return false
			else:
				if not data.preops[id] is Array or data.preops[id].size() > 500:
					restore_warnings.append("跳过无法解析的术前日志：%s" % str(id))
					continue
				prep.set_historical_replay_mode(true)
				preop_events = migrate_legacy_surgery_events(data.preops[id])
				if version < 12:
					preop_events = migrate_surgery_flow_acknowledgements(preop_events)
				if version < 14:
					preop_events = migrate_surgery_patient_acknowledgements(preop_events)
				if version < 15:
					preop_events = migrate_operative_preparation_events(preop_events)
				if version < 16:
					preop_events = migrate_wrong_surgery_decision_retries(preop_events)
				if version < 22 and preop_events.any(func(event: Variant): return event is Dictionary and event.get("kind") == "surgery_step"):
					preop_events.push_front({"kind": "legacy_disable_temporary_conditions"})
				var legacy_completion_marker := false
				for event in preop_events:
					if event is Dictionary and event.get("kind") == "action" and event.get("id") == "execute_confirmed_procedure":
						legacy_completion_marker = true
						break
				for event_index in preop_events.size():
					var event: Variant = preop_events[event_index]
					if not prep.apply(event):
						var event_label := "未知事件"
						if event is Dictionary:
							event_label = str(event.get("kind", "未知事件"))
							var event_id := str(event.get("id", ""))
							if not event_id.is_empty():
								event_label += " / " + event_id
						var replay_stage := str(prep.stage_id)
						restore_warnings.append("跳过术前 %s 的第 %d 个旧节点（%s；阶段：%s）" % [str(id), event_index + 1, event_label, replay_stage])
				if legacy_completion_marker and not prep.surgery_success:
					prep.restore_legacy_completed_surgery()
					restore_warnings.append("按旧存档的手术完成标记恢复术前状态：%s" % str(id))
				prep.set_historical_replay_mode(false)
			rebuilt_preops[id] = prep
			if not state_dictionary_save and version < 28:
				for event in preop_events:
					if event is Dictionary and event.get("kind") == "procedure":
						var historical_procedure_id := str(event.get("id", ""))
						if not restored_unlocked_procedure_ids.has(historical_procedure_id):
							restored_unlocked_procedure_ids.append(historical_procedure_id)
		mode = data.active_mode
		current_preop = data.active_preop_id
		if current_preop != "" and not rebuilt_preops.has(current_preop):
			if state_dictionary_save:
				return false
			restore_warnings.append("旧存档的当前术前流程无法恢复，已返回医院导览。")
			current_preop = ""
		if mode == "preop" and current_preop.is_empty():
			if state_dictionary_save:
				return false
			mode = "encounter"
	var rebuilt_time_log: Array[Dictionary] = []
	var rebuilt_discarded_overtime := 0
	var rebuilt_story_time_advance := 0
	var rebuilt_pending_encounter_transition := false
	var rebuilt_pending_surgery_transition := false
	var rebuilt_relationships := fresh_relationships()
	var rebuilt_character_events := {}
	var rebuilt_character_event_order: Array[String] = []
	var rebuilt_active_character_event := ""
	var rebuilt_micro_events := {}
	var rebuilt_micro_event_order: Array[String] = []
	var rebuilt_active_micro_event := ""
	var rebuilt_story_flags := {}
	var saved_story_flags: Dictionary = data.get("story_flags", {}) if data.get("story_flags", {}) is Dictionary else {}
	var rebuilt_probation_complete := bool(data.get("probation_complete", saved_story_flags.get("probation_complete", false)))
	var rebuilt_personal_nurse_system_unlocked := bool(data.get("personal_nurse_system_unlocked", saved_story_flags.get("personal_nurse_system_unlocked", false)))
	var rebuilt_personal_nurse_id := str(data.get("personal_nurse_id", "nurse_haru" if rebuilt_personal_nurse_system_unlocked else ""))
	var rebuilt_special_completion_counts := {}
	var rebuilt_special_completion_days := {}
	var rebuilt_active_special_event_id := ""
	var rebuilt_active_special_event: RefCounted
	var rebuilt_adult_intimacy_unlocks := {}
	var rebuilt_active_adult_intimacy: RefCounted
	var rebuilt_adult_intimacy_return_mode := "encounter"
	var restored_relationship_state: Dictionary = {}
	if version >= 19:
		if not data.get("relationship_state") is Dictionary:
			return false
		for actor_id in rebuilt_relationships:
			var saved: Variant = data.relationship_state.get(actor_id)
			# Content updates may add a colleague after an older save was written.
			# Keep that new relationship at its authored defaults instead of rejecting
			# the whole save because it has no historical state for the new actor.
			if saved == null:
				restore_warnings.append("为新增医护初始化默认关系与技能：%s" % str(actor_id))
				continue
			if not saved is Dictionary:
				return false
			for key in ["met", "level", "route", "affection", "familiarity", "flags", "event_history", "rank_history", "unlocked_benefits"]:
				if not saved.has(key):
					return false
			restored_relationship_state[actor_id] = saved.duplicate(true)
	var retired_sayaka_minutes := 0
	var retired_sayaka_event := false
	if version >= 6:
		if not data.get("character_events") is Array or not data.get("active_character_event_id") is String:
			return false
		for record in data.character_events:
			if not record is Dictionary or not record.get("id") is String or not character_event_definitions.has(record.id) or rebuilt_character_events.has(record.id):
				if state_dictionary_save:
					return false
				restore_warnings.append("跳过无法解析的旧人物事件节点。")
				continue
			var event = CharacterEvent.new(character_event_definitions[record.id])
			# The approved V2 retires exactly the old completed C failure, not
			# arbitrary Lv0 relationships. Preserve its paid time and all numeric
			# rewards; do not replay choices or silently grant a rank.
			var legacy_state := sayaka_v2_completed_state(record)
			var saved_sayaka: Dictionary = restored_relationship_state.get("doc_sayaka", {})
			if str(record.id) == "sayaka_lv1_first_date" and bool(legacy_state.get("failed_date", false)) and int(saved_sayaka.get("level", -1)) == 0 and saved_sayaka.get("flags", []).has("sayaka_first_date_retry_pending"):
				retired_sayaka_minutes += 120
				retired_sayaka_event = true
				saved_sayaka.flags.erase("sayaka_first_date_retry_pending")
				saved_sayaka.event_history.erase("sayaka_lv1_first_date")
				restore_warnings.append("旧版小夜香未成功约会已恢复为未触发；此前耗时与数值保留。")
				continue
			if state_dictionary_save:
				if not record.get("state") is Dictionary or not event.restore_state(legacy_state.get("state", record.state)):
					return false
			elif version >= 19 and legacy_state.has("state"):
				# v19-v35 already persist authoritative relationships. Translate
				# completed old endpoints without replaying obsolete choice IDs.
				if not event.restore_state(legacy_state.state):
					return false
			else:
				var expected_character_event_record_size := 3 if version >= 20 else 2
				if record.size() != expected_character_event_record_size or not record.get("choices") is Array:
					restore_warnings.append("跳过无法解析的旧人物事件：%s" % str(record.id))
					continue
				for choice_id in record.choices:
					if not choice_id is String or not event.apply(choice_id):
						if state_dictionary_save:
							return false
						restore_warnings.append("跳过人物事件 %s 的一个旧选项" % str(record.id))
						break
					apply_relationship_choice(rebuilt_relationships[event.definition.actor_id], event.last_choice)
					var restored_route := str(event.last_choice.get("route", ""))
					if restored_route in ["colleague", "romance"] and (restored_route != "romance" or int(event.definition.get("target_level", 1)) >= INTIMATE_ROUTE_LEVEL):
						rebuilt_relationships[event.definition.actor_id].route = restored_route
				if event.completed:
					event.completed_day = int(record.get("completed_day", 1))
					var restored_relation: Dictionary = rebuilt_relationships[event.definition.actor_id]
					restored_relation.event_history.append(event.definition.id)
					if event.definition.category == "introduction":
						restored_relation.met = true
					elif event.definition.category in ["bond", "rank_up"] and character_event_rank_up_allowed(event.definition, restored_relation):
						var target_level := int(event.definition.target_level)
						if target_level == int(restored_relation.level) + 1:
							restored_relation.level = target_level
							restored_relation.rank_history.append(event.definition.id)
							var benefit_id := str(event.definition.get("benefit_id", ""))
							if not benefit_id.is_empty():
								restored_relation.unlocked_benefits.append(benefit_id)
			rebuilt_character_events[record.id] = event
			rebuilt_character_event_order.append(record.id)
		rebuilt_active_character_event = data.active_character_event_id
		if retired_sayaka_event and rebuilt_active_character_event == "sayaka_lv1_first_date":
			rebuilt_active_character_event = ""
		if not rebuilt_active_character_event.is_empty() and not rebuilt_character_events.has(rebuilt_active_character_event):
			if state_dictionary_save:
				return false
			restore_warnings.append("旧存档的当前人物事件无法恢复，已返回医院导览。")
			rebuilt_active_character_event = ""
	if version >= 10:
		if not data.get("micro_events") is Array or not data.get("active_micro_event_id") is String or data.micro_events.size() > micro_event_definitions.size():
			return false
		for record in data.micro_events:
			if not record is Dictionary or not record.get("id") is String or not micro_event_definitions.has(record.id) or rebuilt_micro_events.has(record.id):
				if state_dictionary_save:
					return false
				restore_warnings.append("跳过无法解析的旧微事件节点。")
				continue
			var event = MicroEvent.new(micro_event_definitions[record.id], 1)
			if state_dictionary_save:
				if not record.get("state") is Dictionary or not event.restore_state(record.state):
					return false
			else:
				var expected_record_size := 5 if version >= 18 else 3
				if record.size() != expected_record_size or not record.get("choice_id") is String:
					restore_warnings.append("跳过无法解析的旧微事件：%s" % str(record.id))
					continue
				var raw_opening_index: Variant = record.get("opening_index", 0)
				var raw_response_index: Variant = record.get("response_index", 0)
				var raw_day: Variant = record.get("trigger_day")
				if not (raw_day is int or raw_day is float) or int(raw_day) < 1 or not (raw_opening_index is int or raw_opening_index is float) or int(raw_opening_index) < 0 or not (raw_response_index is int or raw_response_index is float) or int(raw_response_index) < 0:
					restore_warnings.append("跳过微事件 %s 的无效旧状态" % str(record.id))
					continue
				event = MicroEvent.new(micro_event_definitions[record.id], int(raw_day))
				event.opening_index = clampi(int(raw_opening_index), 0, maxi(0, event.opening_lines().size() - 1))
				if not record.choice_id.is_empty():
					if not event.apply(record.choice_id):
						if state_dictionary_save:
							return false
						restore_warnings.append("跳过微事件 %s 的一个旧选项" % str(record.id))
					else:
						event.response_index = clampi(int(raw_response_index), 0, maxi(0, event.response_lines().size() - 1))
						apply_micro_event_choice(rebuilt_relationships[event.definition.actor_id], event.last_choice)
			rebuilt_micro_events[record.id] = event
			rebuilt_micro_event_order.append(record.id)
		rebuilt_active_micro_event = data.active_micro_event_id
		if not rebuilt_active_micro_event.is_empty() and not rebuilt_micro_events.has(rebuilt_active_micro_event):
			if state_dictionary_save:
				return false
			restore_warnings.append("旧存档的当前微事件无法恢复，已返回医院导览。")
			rebuilt_active_micro_event = ""
		if mode == "micro_event" and rebuilt_active_micro_event.is_empty():
			if state_dictionary_save:
				return false
			mode = "encounter"
	if version >= 25:
		if not data.get("story_flags") is Dictionary or not data.get("special_event_completion_counts") is Dictionary or not data.get("special_event_completion_days") is Dictionary:
			return false
		for flag in data.story_flags:
			if not flag is String or not data.story_flags[flag] is bool:
				return false
			rebuilt_story_flags[flag] = data.story_flags[flag]
		for event_id in data.special_event_completion_counts:
			var raw_count: Variant = data.special_event_completion_counts[event_id]
			if not event_id is String or not special_event_definitions.has(event_id) or not (raw_count is int or raw_count is float) or float(raw_count) != floorf(float(raw_count)) or int(raw_count) < 1:
				return false
			rebuilt_special_completion_counts[event_id] = int(raw_count)
			var raw_day: Variant = data.special_event_completion_days.get(event_id)
			if not (raw_day is int or raw_day is float) or float(raw_day) != floorf(float(raw_day)) or int(raw_day) < 1:
				return false
			rebuilt_special_completion_days[event_id] = int(raw_day)
		var active_record: Variant = data.get("active_special_event")
		if active_record != null:
			if not active_record is Dictionary or not active_record.get("id") is String or not active_record.get("choices") is Array:
				return false
			rebuilt_active_special_event_id = str(active_record.id)
			if not special_event_definitions.has(rebuilt_active_special_event_id):
				return false
			var definition: Dictionary = special_event_definitions[rebuilt_active_special_event_id]
			var steps := {}
			for step_id in definition.event_chain:
				if not special_event_step_definitions.has(str(step_id)):
					return false
				steps[str(step_id)] = special_event_step_definitions[str(step_id)]
			var started_day := int(active_record.get("started_day", 1))
			if started_day < 1:
				return false
			rebuilt_active_special_event = SpecialEvent.new(definition, steps, started_day)
			for choice_id in active_record.choices:
				if not choice_id is String or not rebuilt_active_special_event.apply(choice_id):
					return false
			if rebuilt_active_special_event.completed:
				return false
		if mode == "special_event" and rebuilt_active_special_event == null:
			return false
	if version >= 35:
		var raw_unlocks: Variant = data.get("adult_intimacy_unlocks")
		if not raw_unlocks is Dictionary:
			return false
		for actor_id in raw_unlocks:
			if not actor_id is String or not raw_unlocks[actor_id] is Dictionary:
				return false
			var profile := adult_intimacy_profile(actor_id)
			var state: Dictionary = raw_unlocks[actor_id]
			if profile.is_empty() or not state.get("repeatable_h_unlocked") is bool:
				return false
			for key in ["unlocked_locations", "unlocked_outfits", "unlocked_special_cgs"]:
				if not state.get(key) is Array:
					return false
			var clean_state := {
				"repeatable_h_unlocked": bool(state.repeatable_h_unlocked),
				"unlocked_locations": [],
				"unlocked_outfits": [],
				"unlocked_special_cgs": [],
			}
			for location_id in state.unlocked_locations:
				if not location_id is String or not profile.get("opening_lines", {}).has(location_id) or clean_state.unlocked_locations.has(location_id):
					return false
				clean_state.unlocked_locations.append(location_id)
			for outfit_id in state.unlocked_outfits:
				if not outfit_id is String or not profile.get("outfit_portraits", {}).has(outfit_id) or clean_state.unlocked_outfits.has(outfit_id):
					return false
				clean_state.unlocked_outfits.append(outfit_id)
			var known_special_cgs: Array = profile.get("special_cgs", []).map(func(entry: Variant): return str(entry.get("id", "")) if entry is Dictionary else "")
			for cg_id in state.unlocked_special_cgs:
				if not cg_id is String or not known_special_cgs.has(cg_id) or clean_state.unlocked_special_cgs.has(cg_id):
					return false
				clean_state.unlocked_special_cgs.append(cg_id)
			rebuilt_adult_intimacy_unlocks[actor_id] = clean_state
		var active_intimacy_record: Variant = data.get("active_adult_intimacy")
		if active_intimacy_record != null:
			if not active_intimacy_record is Dictionary:
				return false
			var intimacy_actor_id := str(active_intimacy_record.get("actor_id", ""))
			var intimacy_profile := adult_intimacy_profile(intimacy_actor_id)
			if intimacy_profile.is_empty():
				return false
			var unlocked_cgs: Array[String] = []
			for cg_id in active_intimacy_record.get("unlocked_special_cgs", []):
				if not cg_id is String:
					return false
				unlocked_cgs.append(cg_id)
			rebuilt_active_adult_intimacy = AdultIntimacySession.new(
				intimacy_actor_id,
				intimacy_profile,
				str(active_intimacy_record.get("location_id", "")),
				str(active_intimacy_record.get("outfit_id", "")),
				bool(active_intimacy_record.get("milestone_mode", false)),
				active_intimacy_record.get("milestone_cg_override", {}),
				unlocked_cgs
			)
			if rebuilt_active_adult_intimacy.phase == "invalid" or not rebuilt_active_adult_intimacy.restore(active_intimacy_record):
				return false
			rebuilt_adult_intimacy_return_mode = str(active_intimacy_record.get("return_mode", "encounter"))
			if rebuilt_adult_intimacy_return_mode not in ["encounter", "preop", "character_event", "micro_event", "special_event"]:
				return false
		if (mode == "adult_intimacy") != (rebuilt_active_adult_intimacy != null):
			return false
	if version >= 19:
		for actor_id in rebuilt_relationships:
			if not restored_relationship_state.has(actor_id):
				continue
			var saved: Dictionary = restored_relationship_state[actor_id]
			var raw_level: Variant = saved.get("level")
			var raw_affection: Variant = saved.get("affection")
			var raw_familiarity: Variant = saved.get("familiarity")
			if not saved.met is bool or not (raw_level is int or raw_level is float) or float(raw_level) != floorf(float(raw_level)) or int(raw_level) < 0 or int(raw_level) > relationship_max_level(str(actor_id)) or not (raw_affection is int or raw_affection is float) or int(raw_affection) < 0 or int(raw_affection) > 100 or not (raw_familiarity is int or raw_familiarity is float) or int(raw_familiarity) < 0 or int(raw_familiarity) > 100 or str(saved.route) not in ["colleague", "romance"] or not saved.flags is Array or not saved.event_history is Array or not saved.rank_history is Array or not saved.unlocked_benefits is Array:
				return false
			for key in ["met", "level", "route", "affection", "familiarity", "flags", "event_history", "rank_history", "unlocked_benefits"]:
				if key in ["level", "affection", "familiarity"]:
					rebuilt_relationships[actor_id][key] = int(saved[key])
				else:
					rebuilt_relationships[actor_id][key] = saved[key].duplicate(true) if saved[key] is Array else saved[key]
	else:
		# Earlier builds exposed every staff member and had no acquaintance state.
		# Treat them as already known when migrating an old save.
		for actor_id in rebuilt_relationships:
			rebuilt_relationships[actor_id].met = true
	if version >= 3:
		if not data.get("time_log") is Array or data.time_log.size() > 1000:
			return false
		var previous_end := 0
		var used_nonrepeatable := {}
		for event in data.time_log:
			if not event is Dictionary or event.size() not in [2, 3] or not event.get("id") is String:
				return false
			var raw_start: Variant = event.get("start")
			if not (raw_start is int or raw_start is float) or float(raw_start) != floorf(float(raw_start)):
				return false
			var event_start := int(raw_start)
			if not time_event_definitions.has(event.id) or event_start < previous_end:
				return false
			var definition: Dictionary = time_event_definitions[event.id]
			var variant := int(event.get("variant", 0))
			if variant < 0 or variant >= definition.responses.size():
				return false
			if not definition.repeatable and used_nonrepeatable.has(event.id):
				return false
			used_nonrepeatable[event.id] = true
			rebuilt_time_log.append({"id": event.id, "start": event_start, "variant": variant})
			previous_end = event_start + int(definition.minutes)
		var reconstructed_total := restored_archived_clinical_minutes
		for visit in rebuilt.values():
			reconstructed_total += visit.minutes
		for preparation in rebuilt_preops.values():
			reconstructed_total += preparation.minutes
		for event in rebuilt_time_log:
			reconstructed_total += int(time_event_definitions[event.id].minutes)
		for event in rebuilt_character_events.values():
			if event.completed:
				reconstructed_total += int(event.definition.minutes)
		if version >= 21:
			var raw_story_advance: Variant = data.get("story_time_advance_minutes")
			if not (raw_story_advance is int or raw_story_advance is float) or float(raw_story_advance) != floorf(float(raw_story_advance)) or int(raw_story_advance) < 0 or int(raw_story_advance) > 100000:
				return false
			rebuilt_story_time_advance = int(raw_story_advance) + retired_sayaka_minutes
			reconstructed_total += rebuilt_story_time_advance
		if previous_end > reconstructed_total:
			return false
		if version >= 5:
			var raw_discarded: Variant = data.get("discarded_overtime_minutes")
			if not (raw_discarded is int or raw_discarded is float) or float(raw_discarded) != floorf(float(raw_discarded)) or int(raw_discarded) < 0 or int(raw_discarded) > reconstructed_total:
				return false
			rebuilt_discarded_overtime = int(raw_discarded)
	if version >= 8:
		if not data.get("pending_encounter_day_transition") is bool or not data.get("pending_surgery_day_transition") is bool:
			return false
		rebuilt_pending_encounter_transition = data.pending_encounter_day_transition
		rebuilt_pending_surgery_transition = data.pending_surgery_day_transition
		if rebuilt_pending_encounter_transition:
			if str(data.active_id).is_empty() or not rebuilt.has(str(data.active_id)) or rebuilt[str(data.active_id)].completed():
				return false
		if rebuilt_pending_surgery_transition:
			if current_preop.is_empty() or not rebuilt_preops.has(current_preop):
				return false
	for patient_id in restored_patient_referrals:
		for visit in rebuilt.values():
			if visit.definition.patient_id == patient_id and visit.admitted:
				return false
		for preparation in rebuilt_preops.values():
			if preparation.definition.patient_id == patient_id and preparation.surgery_success:
				return false
	if version < 24:
		# Older saves did not persist per-specialty totals. Rebuild every retained
		# successful operation without inventing category progress that is no longer
		# represented in the save.
		for preparation in rebuilt_preops.values():
			if not preparation.surgery_success:
				continue
			var legacy_group := surgery_procedure_group(str(preparation.procedure_id))
			if not legacy_group.is_empty():
				restored_completed_surgeries_by_group[legacy_group] = int(restored_completed_surgeries_by_group.get(legacy_group, 0)) + 1
	if version < 29:
		for preparation in rebuilt_preops.values():
			if preparation.surgery_success and not str(preparation.procedure_id).is_empty():
				restored_completed_surgeries_by_procedure[preparation.procedure_id] = maxi(1, int(restored_completed_surgeries_by_procedure.get(preparation.procedure_id, 0)))
	for pilot_id in ["surgery_appendix", "surgery_open_cholecystectomy", "surgery_open_inguinal_hernia"]:
		if int(restored_completed_surgeries_by_procedure.get(pilot_id, 0)) > 0 and not restored_surgical_quality_records.has(pilot_id):
			restored_surgical_quality_records[pilot_id] = {"quick_surgery_unlocked": true, "legacy_grandfathered": true}
	if restored_reported_surgeries > restored_completed_surgeries_total:
		return false
	if not restored_staff_patient.is_empty():
		for visit in rebuilt.values():
			if visit.admitted:
				var finished := false
				for prep in rebuilt_preops.values():
					if prep.definition.patient_id == visit.definition.patient_id and (prep.surgery_success or prep.surgery_aborted):
						finished = true
				if not finished:
					return false
	active_staff_patient = restored_staff_patient.duplicate(true)
	staff_patient_practice_counts = restored_practice_counts.duplicate(true)
	visits = rebuilt
	preops = rebuilt_preops
	patient_cases = restored_patient_cases
	patient_queue = restored_patient_queue
	patient_referrals = restored_patient_referrals
	first_surgery_diagnosis_shock_state = restored_diagnosis_shock_state
	recent_patient_ids = restored_recent_patient_ids
	completed_surgeries_total = restored_completed_surgeries_total
	completed_surgeries_by_group = restored_completed_surgeries_by_group
	completed_surgeries_by_procedure = restored_completed_surgeries_by_procedure
	surgical_quality_records = restored_surgical_quality_records
	character_progress_counters = restored_character_progress_counters
	surgery_xp = restored_surgery_xp
	surgery_xp_history = restored_surgery_xp_history
	leadership_xp = restored_leadership_xp
	leadership_xp_history = restored_leadership_xp_history
	staff_skill_levels = restored_staff_skill_levels
	staff_training_credits = restored_staff_training_credits
	successful_no_anesthesia_surgeries = restored_successful_no_anesthesia_surgeries
	reported_surgeries = restored_reported_surgeries
	apply_staff_skill_levels()
	unlocked_procedure_ids = restored_unlocked_procedure_ids
	archived_player_effects = restored_archived_player_effects
	archived_player_effect_history = restored_archived_player_effect_history
	definitions = restored_definitions
	preop_definitions = restored_preop_definitions
	time_log = rebuilt_time_log
	relationships = rebuilt_relationships
	for preparation in rebuilt_preops.values():
		preparation.set_known_staff(known_staff_ids(), true)
		preparation.set_procedure_unlocks(unlocked_procedure_ids, true)
	character_events = rebuilt_character_events
	for restored_event in character_events.values():
		if restored_event.completed and restored_event.definition.has("introduction_actor_ids"):
			complete_introduction_cast(restored_event.definition)
	character_event_order = rebuilt_character_event_order
	active_character_event_id = rebuilt_active_character_event
	micro_events = rebuilt_micro_events
	micro_event_order = rebuilt_micro_event_order
	active_micro_event_id = rebuilt_active_micro_event
	story_flags = rebuilt_story_flags
	synchronize_story_locked_procedures()
	probation_complete = rebuilt_probation_complete
	personal_nurse_system_unlocked = rebuilt_personal_nurse_system_unlocked
	personal_nurse_id = rebuilt_personal_nurse_id
	special_event_completion_counts = rebuilt_special_completion_counts
	special_event_completion_days = rebuilt_special_completion_days
	active_special_event_id = rebuilt_active_special_event_id
	active_special_event = rebuilt_active_special_event
	if active_special_event != null:
		normalize_special_event_position()
	adult_intimacy_unlocks = rebuilt_adult_intimacy_unlocks
	active_adult_intimacy = rebuilt_active_adult_intimacy
	adult_intimacy_return_mode = rebuilt_adult_intimacy_return_mode
	discarded_overtime_minutes = rebuilt_discarded_overtime
	story_time_advance_minutes = rebuilt_story_time_advance
	archived_clinical_minutes = restored_archived_clinical_minutes
	rumi_shiori_introduction_day()
	pending_encounter_day_transition = rebuilt_pending_encounter_transition
	pending_surgery_day_transition = rebuilt_pending_surgery_transition
	campaign_seed = restored_campaign_seed
	intraoperative_crisis_enabled = restored_crisis_enabled
	sunday_history = restored_sunday_history
	# A save is a world-state checkpoint, not a resumable scene. Always return
	# to the hospital directory (the UI will route Sunday to its Sunday menu).
	active_preop_id = ""
	active_mode = "encounter"
	active_id = ""
	active_character_event_id = ""
	active_micro_event_id = ""
	active_special_event_id = ""
	active_special_event = null
	active_adult_intimacy = null
	adult_intimacy_return_mode = "encounter"
	pending_encounter_day_transition = false
	pending_surgery_day_transition = false
	active_free_h_departure.clear()
	active_after_work_walk.clear()
	clear_pending_departure_context()
	free_h_booking.clear()
	var saved_booking: Variant = data.get("free_h_booking", {})
	if saved_booking is Dictionary and (saved_booking.get("workday") is int or saved_booking.get("workday") is float) and saved_booking.get("actor_id") is String:
		if int(saved_booking.workday) == day_number() and free_h_unlocked(str(saved_booking.actor_id)):
			free_h_booking = {"workday": int(saved_booking.workday), "actor_id": str(saved_booking.actor_id)}
	if personal_nurse_system_unlocked and not personal_nurse_candidates().has(personal_nurse_id):
		personal_nurse_id = "nurse_haru" if personal_nurse_candidates().has("nurse_haru") else ""
	for preparation in preops.values():
		preparation.set_graphic_preop_explainer(resolve_preop_explainer())
	ensure_waiting_patient()
	last_error = ""
	return true

func sayaka_v2_completed_state(record: Dictionary) -> Dictionary:
	# Narrow content-version bridge for completed endpoints only. Active-scene
	# restoration is intentionally not introduced by this narrative update.
	var endpoints := {
		"sayaka_week1_phone_exchange": {"nodes": ["tail_a", "tail_b", "tail_c"], "choices": ["phone_end_a", "phone_end_b", "phone_end_c"], "target": "v2_192"},
		"sayaka_lv1_first_date": {"nodes": ["walk_home", "only_meal_reply"], "choices": ["date_success_end", "only_meal_end"], "target": "v2_655"},
		"sayaka_lv1_monday_callback": {"nodes": ["callback_reply"], "choices": ["callback_end"], "target": "v2_696"},
		"sayaka_lv2_working_hours": {"nodes": ["ending"], "choices": ["lv2_complete"], "target": "ending"},
		"sayaka_lv3_relationship": {"nodes": ["scene_12"], "choices": ["finish_lv3"], "target": "scene_12"},
	}
	var mapping: Dictionary = endpoints.get(str(record.get("id", "")), {})
	if mapping.is_empty():
		return {}
	var state: Dictionary = record.get("state", {}).duplicate(true) if record.get("state") is Dictionary else {}
	var choices: Variant = state.get("choices", record.get("choices", []))
	if not choices is Array or choices.is_empty():
		return {}
	var ending := str(choices.back())
	if not mapping.choices.has(ending):
		return {}
	if not state.is_empty():
		if not bool(state.get("completed", false)) or not mapping.nodes.has(str(state.get("node_id", ""))):
			return {}
	else:
		state = {"choices": choices.duplicate(), "completed": true, "completed_day": int(record.get("completed_day", 1)), "last_choice": {}}
	state.node_id = mapping.target
	return {"state": state, "failed_date": ending == "only_meal_end"}

func open_preop(id: String) -> RefCounted:
	if special_event_in_progress():
		last_error = "特殊活动进行中，不能进入术前流程。"
		return null
	if not preop_definitions.has(id):
		return null
	# Overtime reserves the next morning in the ledger before clinical care
	# ends. Saturday's admitted patient must not become a new Sunday booking.
	if is_hospital_closed_day(pending_day_exit_workday if pending_day_exit_workday > 0 else -1):
		last_error = "%s不安排择期手术准备；已住院患者仍可探视。" % calendar_day_label()
		return null
	var definition: Dictionary = preop_definitions[id]
	if completed_patient(definition.patient_id) and id != active_preop_id:
		return null
	if not definition.has("staff_patient_id") and (not visits.has(definition.encounter_id) or not visits[definition.encounter_id].admitted):
		return null
	# Ordinary cases are themselves a procedure-unlock source. Teaching-gated
	# Aqua procedures are the exception: entering a case must not bypass their
	# relationship milestone. They are also filtered out of the ordinary pool
	# until the corresponding story flag is complete.
	var indicated_procedure_id := str(definition.get("surgery_id", ""))
	if not definition.has("staff_patient_id") and not indicated_procedure_id.is_empty() and procedure_unlock_requirement_flag(indicated_procedure_id).is_empty():
		unlock_procedure(indicated_procedure_id)
	if not preops.has(id):
		var prep_patients := patient_definitions.duplicate()
		if definition.has("staff_patient_id"):
			prep_patients.append(patient_definition(str(definition.staff_patient_id)))
		preops[id] = Preop.new(definition, staff, surgery_definitions, prep_patients, known_staff_ids(), true, surgery_team_dialogue_profiles, patient_interaction_definitions, temporary_condition_definitions, unlocked_procedure_ids, true, palpation_profile_definitions, awake_special_bark_definitions)
	else:
		preops[id].set_known_staff(known_staff_ids(), true)
		preops[id].set_procedure_unlocks(unlocked_procedure_ids, true)
	preops[id].set_graphic_preop_explainer(resolve_preop_explainer())
	active_id = definition.encounter_id
	active_preop_id = id
	active_mode = "preop"
	return preops[id]
