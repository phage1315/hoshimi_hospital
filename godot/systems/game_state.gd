extends RefCounted
const Encounter = preload("res://godot/systems/encounter_session.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const CharacterEvent = preload("res://godot/systems/character_event_session.gd")
const MicroEvent = preload("res://godot/systems/micro_event_session.gd")
const PresenceResolver = preload("res://godot/systems/presence_resolver.gd")
const SAVE_VERSION := 21
const CONTENT_VERSION := 1
const SHIFT_START_MINUTE := 9 * 60
const SHIFT_MINUTES := 8 * 60
const RELATIONSHIP_MAX_LEVEL := 5
const RELATIONSHIP_THRESHOLDS := [0, 10, 25, 45, 70]
const INTIMATE_ROUTE_LEVEL := 4
const PLAYER_ATTRIBUTE_BASE := {"skill": 50, "ethics": 0, "charisma": 50, "intimidation": 0, "reputation": 0}
var preop_definitions: Dictionary = {}
var encounter_blueprints: Dictionary = {}
var preop_blueprints: Dictionary = {}
var case_templates: Dictionary = {}
var patient_cases: Dictionary = {}
var patient_queue: Array[String] = []
var patient_referrals: Dictionary = {}
var recent_patient_ids: Array[String] = []
var archived_player_effects: Dictionary = {"skill": 0, "ethics": 0, "charisma": 0, "intimidation": 0, "reputation": 0}
var archived_player_effect_history: Array[Dictionary] = []
var time_event_definitions: Dictionary = {}
var surgery_definitions: Array = []
var surgery_team_dialogue_profiles: Array = []
var patient_interaction_definitions: Array = []
var patient_definitions: Array = []
var relationship_definitions: Array = []
var character_event_definitions: Dictionary = {}
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
var staff: Array = []
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
var pending_surgery_day_transition := false

func configure(data: Array, preop_data: Array = [], staff_data: Array = [], time_event_data: Array = [], surgery_data: Array = [], patient_data: Array = [], relationship_data: Array = [], character_event_data: Array = [], case_template_data: Array = [], micro_event_data: Array = [], examination_cg_pool_data: Array = [], surgery_team_dialogue_data: Array = [], patient_interaction_data: Array = []) -> void:
	preop_definitions.clear()
	preop_blueprints.clear()
	encounter_blueprints.clear()
	case_templates.clear()
	time_event_definitions.clear()
	staff = staff_data
	presence_resolver = PresenceResolver.new(staff_data)
	surgery_definitions = surgery_data
	surgery_team_dialogue_profiles = surgery_team_dialogue_data
	patient_interaction_definitions = patient_interaction_data
	patient_definitions = patient_data
	relationship_definitions = relationship_data
	character_event_definitions.clear()
	for entry in character_event_data:
		character_event_definitions[entry.id] = entry
	micro_event_definitions.clear()
	for entry in micro_event_data:
		micro_event_definitions[entry.id] = entry
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
	patient_cases = random_patient_cases() if not case_templates.is_empty() else {}
	patient_queue = random_patient_queue()
	patient_referrals.clear()
	recent_patient_ids.clear()
	archived_player_effects = zero_player_effects()
	archived_player_effect_history.clear()
	rebuild_patient_content(patient_cases)
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
	discarded_overtime_minutes = 0
	story_time_advance_minutes = 0
	pending_surgery_day_transition = false
	last_error = ""
	last_time_event_response = ""

func active_surgery_in_progress() -> bool:
	return not active_preop_id.is_empty() and preops.has(active_preop_id) and preops[active_preop_id].surgery_in_progress()

func can_save_progress() -> bool:
	if active_surgery_in_progress():
		return false
	if not active_character_event_id.is_empty() and character_events.has(active_character_event_id):
		var event = character_events[active_character_event_id]
		if not event.completed and bool(event.definition.get("locks_saving", false)):
			return false
	return true

func save_block_reason() -> String:
	return "" if can_save_progress() else "手术进行中，无法保存。请完成本次手术后再保存。"

func random_patient_queue() -> Array[String]:
	var result: Array[String] = []
	for patient in patient_definitions:
		result.append(patient.id)
	result.shuffle()
	return result

func valid_patient_queue(value: Variant) -> bool:
	if not value is Array or value.size() != patient_definitions.size():
		return false
	var expected := {}
	for patient in patient_definitions:
		expected[patient.id] = true
	var seen := {}
	for id in value:
		if not id is String or not expected.has(id) or seen.has(id):
			return false
		seen[id] = true
	return seen.size() == expected.size()

func zero_player_effects() -> Dictionary:
	var result := {}
	for metric in PLAYER_ATTRIBUTE_BASE:
		result[metric] = 0
	return result

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

func random_patient_cases() -> Dictionary:
	var pool: Array = case_templates.keys()
	pool.shuffle()
	var result := {}
	for i in range(patient_definitions.size()):
		if pool.is_empty():
			break
		result[patient_definitions[i].id] = pool[i % pool.size()]
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
	if assignments.size() != patient_definitions.size():
		return false
	for patient in patient_definitions:
		if not assignments.get(patient.id) is String or not case_templates.has(assignments.get(patient.id)):
			return false
	return true

func patient_case(patient_id: String) -> Dictionary:
	var template_id: String = str(patient_cases.get(patient_id, ""))
	return case_templates.get(template_id, {})

func rebuild_patient_content(assignments: Dictionary) -> void:
	definitions = encounter_definitions_for(assignments)
	preop_definitions = preop_definitions_for(assignments)

func encounter_definitions_for(assignments: Dictionary) -> Dictionary:
	var result := {}
	for id in encounter_blueprints:
		var definition: Dictionary = encounter_blueprints[id].duplicate(true)
		var template_id: String = str(assignments.get(definition.patient_id, ""))
		if case_templates.has(template_id):
			definition = encounter_for_case(definition, case_templates[template_id])
		result[id] = definition
	return result

func preop_definitions_for(assignments: Dictionary) -> Dictionary:
	var result := {}
	for id in preop_blueprints:
		var definition: Dictionary = preop_blueprints[id].duplicate(true)
		var template_id: String = str(assignments.get(definition.patient_id, ""))
		if case_templates.has(template_id):
			definition.surgery_id = case_templates[template_id].surgery_id
			definition.title = "%s · 术前准备" % case_templates[template_id].title
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
	var style := patient_voice_style(patient_id)
	if beat == "background":
		match style:
			"reserved":
				return "应该没有别的了……药物过敏我也没听说过。"
			"bold":
				return "其他应该没什么，我也没有药物过敏。"
			"gentle":
				return "其他病史我想不起来了，也没有已知的药物过敏。"
			_:
				return "我以前没得过什么大病，也没有药物过敏。"
	var prefixes := {
		"direct": {"complaint": "", "primary": "", "secondary": "还有，"},
		"reserved": {"complaint": "那个……", "primary": "我想想……", "secondary": "还有就是……"},
		"bold": {"complaint": "其实吧，", "primary": "就是，", "secondary": "而且，"},
		"gentle": {"complaint": "不好意思，", "primary": "", "secondary": "另外，"}
	}
	var style_prefixes: Dictionary = prefixes.get(style, prefixes["direct"])
	return str(style_prefixes.get(beat, "")) + line

func encounter_for_case(blueprint: Dictionary, template: Dictionary) -> Dictionary:
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
	var symptoms: Array = template.symptoms
	var history: Array = template.history
	var findings: Array = template.examination_findings
	var tests: Array = template.tests
	var differentials: Array = template.differential_diagnoses
	var patient_id: String = str(result.patient_id)
	stages.reception.prompt = "「%s」" % patient_voice_line(patient_id, str(template.presenting_complaint), "complaint")
	actions.reception.greet.response = "「%s」" % patient_voice_line(patient_id, str(history[0]), "primary")
	actions.reception.comfort.response = "「%s」" % patient_voice_line(patient_id, str(history[1]), "secondary")
	actions.reception.comfort.notes[0].text = "患者对本次症状和后续安排感到担心。"
	stages.history.prompt = "「把这次不舒服的经过详细说说吧。」"
	actions.history.pain.label = str(symptoms[0])
	actions.history.pain.response = "「%s」" % patient_voice_line(patient_id, str(history[0]), "primary")
	actions.history.pain.notes[0].text = "主要症状：%s。" % symptoms[0]
	actions.history.associated.label = "其他症状"
	actions.history.associated.response = "「%s」" % patient_voice_line(patient_id, str(history[1]), "secondary")
	actions.history.associated.notes[0].text = "伴随症状：%s。" % "、".join(symptoms.slice(1))
	actions.history.background.response = "「%s」" % patient_voice_line(patient_id, "", "background")
	actions.history.background.notes[0].text = "既往情况与过敏史已记录。"
	var voiced_history: Array[String] = []
	for index in range(history.size()):
		voiced_history.append(patient_voice_line(patient_id, str(history[index]), "primary" if index == 0 else "secondary"))
	stages.history.bundles[0].response = "「%s」" % "".join(voiced_history)
	stages.history.bundles[0].summary = "病史已整理 · %s 种症状" % symptoms.size()
	actions.exam.vitals.response = "「生命体征已经记录。」"
	actions.exam.vitals.notes[0].text = "基础生命体征已记录，当前可继续检查。"
	for resolution_id in ["authoritative_full_undress", "gentle_full_undress", "threaten_full_undress"]:
		actions.exam_undress_decision[resolution_id].notes[0].text = "；".join(findings)
	actions.tests.blood.label = tests[0].label
	actions.tests.blood.response = "「%s」" % tests[0].result
	actions.tests.blood.notes[0].text = "%s：%s" % [tests[0].label, tests[0].result]
	actions.tests.blood.summary = tests[0].label
	actions.tests.blood["visual_pool_id"] = str(examination_cg_by_test.get(tests[0].id, ""))
	actions.tests.imaging.label = tests[1].label
	actions.tests.imaging.response = "「%s」" % tests[1].result
	actions.tests.imaging.notes[0].text = "%s：%s" % [tests[1].label, tests[1].result]
	actions.tests.imaging.summary = tests[1].label
	actions.tests.imaging["visual_pool_id"] = str(examination_cg_by_test.get(tests[1].id, ""))
	var additional_tests: Array = tests.slice(2)
	actions.tests.extra.label = "追加检查"
	actions.tests.extra.response = "「%s」" % (additional_tests[0].result if not additional_tests.is_empty() else "没有发现新的决定性线索。")
	actions.tests.extra.notes[0].text = "；".join(additional_tests.map(func(test: Dictionary): return "%s：%s" % [test.label, test.result])) if not additional_tests.is_empty() else "追加检查未提供新线索。"
	var additional_visual_pool := ""
	for test in additional_tests:
		if examination_cg_by_test.has(test.id):
			additional_visual_pool = examination_cg_by_test[test.id]
			break
	actions.tests.extra["visual_pool_id"] = additional_visual_pool
	actions.diagnosis.diagnose_gastro.label = str(differentials[0])
	actions.diagnosis.diagnose_gastro.response = "「现有检查还不能支持这个判断，再看一遍关键结果。」"
	actions.diagnosis.diagnose_appendix.label = template.diagnosis
	actions.diagnosis.diagnose_appendix.response = "「与现有线索吻合。和患者说明住院及手术安排吧。」"
	actions.diagnosis.diagnose_appendix.diagnosis = template.id
	actions.diagnosis.diagnose_appendix.notes[0].text = "诊断：%s。拟收住院接受相应手术治疗。" % template.diagnosis
	actions.diagnosis.diagnose_appendix.summary = "诊断：%s" % template.diagnosis
	actions.diagnosis.diagnose_observe.label = str(differentials[1]) if differentials.size() > 1 else "无需进一步处理"
	actions.diagnosis.diagnose_observe.response = "「这个判断无法解释全部检查结果。」"
	stages.plan.prompt = patient_reaction_line(patient_id, "hospitalization_question", "「所以，我需要住院接受手术吗？」")
	actions.plan.explain.response = patient_reaction_line(patient_id, "hospitalization_response", "「明白了，请告诉我接下来要准备什么。」")
	actions.plan.explain.notes[0].text = "已向患者解释%s及相应手术安排。" % template.diagnosis
	actions.plan.admit.notes[0].text = "已收住院，准备进行与%s相应的手术治疗。" % template.diagnosis
	return result

func open_visit(id: String) -> RefCounted:
	if not definitions.has(id):
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
	var total := 0
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

func advance_story_to_future_day(day_offset: int, absolute_clock: int) -> void:
	advance_story_to_day(day_number() + maxi(1, day_offset), absolute_clock)

func advance_story_to_day(target_day: int, absolute_clock: int) -> void:
	var current_total := elapsed()
	var target_day_index := maxi(0, target_day - 1)
	var target_shift_minute := clampi(absolute_clock - SHIFT_START_MINUTE, 0, SHIFT_MINUTES - 1)
	var target_total := target_day_index * SHIFT_MINUTES + target_shift_minute
	story_time_advance_minutes += maxi(0, target_total - current_total)

func fresh_relationships() -> Dictionary:
	var result := {}
	for relation in relationship_definitions:
		var state: Dictionary = relation.duplicate(true)
		state["met"] = bool(state.get("met", false))
		state["level"] = clampi(int(state.get("level", 0)), 0, RELATIONSHIP_MAX_LEVEL)
		state["route"] = str(state.get("route", "colleague"))
		state["rank_history"] = state.get("rank_history", []).duplicate()
		state["unlocked_benefits"] = state.get("unlocked_benefits", []).duplicate()
		result[relation.target_id] = state
	return result

func relation_for(actor_id: String) -> Dictionary:
	return relationships.get(actor_id, {})

func meet_staff(actor_id: String) -> bool:
	var relation := relation_for(actor_id)
	if relation.is_empty():
		return false
	relation.met = true
	return true

func staff_is_met(actor_id: String) -> bool:
	return bool(relation_for(actor_id).get("met", false))

func known_staff_ids() -> Array[String]:
	var result: Array[String] = []
	for actor_id in relationships:
		if staff_is_met(actor_id):
			result.append(actor_id)
	return result

func relationship_level(actor_id: String) -> int:
	return int(relation_for(actor_id).get("level", 0))

func next_rank_threshold(actor_id: String) -> int:
	var level := relationship_level(actor_id)
	return RELATIONSHIP_THRESHOLDS[mini(level, RELATIONSHIP_MAX_LEVEL - 1)]

func rank_ready(actor_id: String) -> bool:
	var relation := relation_for(actor_id)
	var level := int(relation.get("level", 0))
	return staff_is_met(actor_id) and level >= 1 and level < RELATIONSHIP_MAX_LEVEL and int(relation.get("familiarity", 0)) >= next_rank_threshold(actor_id)

func next_rank_slot(actor_id: String) -> Dictionary:
	var relation := relation_for(actor_id)
	var target := int(relation.get("level", 0)) + 1
	for slot in relation.get("rank_slots", []):
		if int(slot.get("target_level", 0)) == target:
			return slot
	return {}

func add_familiarity(actor_id: String, amount: int) -> void:
	var relation := relation_for(actor_id)
	if relation.is_empty():
		return
	add_familiarity_to(relation, amount)

func add_familiarity_to(relation: Dictionary, amount: int) -> void:
	var level := clampi(int(relation.get("level", 0)), 0, RELATIONSHIP_MAX_LEVEL)
	# Before Lv1, familiarity may accumulate toward Lv2, but it cannot unlock a
	# rank-up until the authored bond event establishes the relationship.
	var cap: int = 100 if level >= RELATIONSHIP_MAX_LEVEL else int(RELATIONSHIP_THRESHOLDS[maxi(level, 1)])
	relation.familiarity = clampi(int(relation.get("familiarity", 0)) + amount, 0, cap)

func complete_rank_up(actor_id: String, event_id: String, target_level: int, benefit_id: String = "") -> void:
	var relation := relation_for(actor_id)
	if relation.is_empty() or target_level != int(relation.level) + 1:
		return
	relation.level = clampi(target_level, 0, RELATIONSHIP_MAX_LEVEL)
	if not relation.rank_history.has(event_id):
		relation.rank_history.append(event_id)
	if not benefit_id.is_empty() and not relation.unlocked_benefits.has(benefit_id):
		relation.unlocked_benefits.append(benefit_id)

func staff_present_at(location_id: String) -> Array[String]:
	var result: Array[String] = []
	if presence_resolver != null:
		result = presence_resolver.staff_at(location_id, day_number(), int(schedule_at(elapsed()).absolute_clock))
	# Fixed and random schedules describe where known colleagues can be found.
	# Unmet staff stay hidden until an available introduction places them at its
	# authored location, preventing future colleagues from appearing as anonymous
	# roster entries before their first scene.
	var known_result: Array[String] = []
	for actor_id in result:
		if staff_is_met(actor_id):
			known_result.append(actor_id)
	result = known_result
	# A currently available personal event also places its actor at the event site.
	for event in character_events_at(location_id):
		if event.actor_id not in result:
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
	var today := day_number()
	if micro_events_triggered_on_day(today) >= 2 or actor_had_micro_event_on_day(definition.actor_id, today):
		return false
	var clock: int = int(schedule_at(elapsed()).absolute_clock)
	if clock < int(definition.time_start) or clock > int(definition.time_end):
		return false
	var relation: Dictionary = relation_for(definition.actor_id)
	if relation.is_empty() or int(relation.get("trust", 0)) < int(definition.min_trust) or int(relation.get("familiarity", 0)) < int(definition.min_familiarity):
		return false
	if context == "after_surgery":
		if active_preop_id.is_empty() or not preops.has(active_preop_id):
			return false
		var team: Dictionary = preops[active_preop_id].team
		if definition.actor_id not in team.values():
			return false
	return true

func select_micro_event(context: String, location_id: String) -> RefCounted:
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
	for metric in ["trust", "affection", "respect"]:
		relation[metric] = clampi(int(relation.get(metric, 0)) + int(choice.effects.get(metric, 0)), 0, 100)
	# Every shared fragment makes the two characters slightly more familiar,
	# while the authored choice effects remain deliberately small.
	add_familiarity_to(relation, int(choice.effects.get("familiarity", 0)) + 1)
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

func character_event_done(id: String) -> bool:
	return character_events.has(id) and character_events[id].completed

func character_event_available(definition: Dictionary) -> bool:
	if character_event_done(definition.id):
		return false
	var relation: Dictionary = relation_for(definition.actor_id)
	if relation.is_empty() or day_number() < int(definition.conditions.min_day):
		return false
	if definition.category == "introduction" and bool(relation.get("met", false)):
		return false
	if definition.category != "introduction" and not bool(relation.get("met", false)) and not bool(definition.get("allow_unmet_actor", false)):
		return false
	if definition.category == "bond" and (int(relation.get("level", 0)) != 0 or int(definition.get("target_level", 1)) != 1):
		return false
	if definition.category == "rank_up" and (not rank_ready(definition.actor_id) or int(definition.get("target_level", 1)) != int(relation.level) + 1):
		return false
	for metric in ["trust", "affection", "respect", "familiarity"]:
		if int(relation.get(metric, 0)) < int(definition.conditions.get("min_" + metric, 0)):
			return false
	for required in definition.conditions.required_events:
		if not character_event_done(required):
			return false
		var required_gap_days := int(definition.conditions.get("days_after_required_events", 0))
		if required_gap_days > 0:
			var required_event = character_events.get(required)
			if required_event == null or int(required_event.completed_day) <= 0 or day_number() < int(required_event.completed_day) + required_gap_days:
				return false
	for requirement in definition.conditions.get("special_requirements", []):
		if str(requirement.get("type", "")) == "player_attribute":
			var attribute_id := str(requirement.get("attribute", ""))
			if int(player_attributes().get(attribute_id, -1000)) < int(requirement.get("minimum", 0)):
				return false
		else:
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
	if active_surgery_in_progress():
		return result
	var clock: int = int(schedule_at(elapsed()).absolute_clock)
	for definition in character_event_definitions.values():
		# Stage-triggered events belong to an active preoperative flow. They must
		# never fire merely because the player visits the same map location.
		if not str(definition.get("preop_stage_id", "")).is_empty():
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

func next_character_event_for_preop_stage(stage_id: String) -> Dictionary:
	if active_surgery_in_progress():
		return {}
	var result: Array = []
	var clock: int = int(schedule_at(elapsed()).absolute_clock)
	for definition in character_event_definitions.values():
		if str(definition.get("preop_stage_id", "")) != stage_id or not bool(definition.get("auto_start", false)):
			continue
		if not character_event_available(definition):
			continue
		if clock < int(definition.time_start) or clock > int(definition.time_end):
			continue
		result.append(definition)
	result.sort_custom(func(a: Dictionary, b: Dictionary):
		if int(a.priority) != int(b.priority):
			return int(a.priority) > int(b.priority)
		return a.id < b.id)
	return {} if result.is_empty() else result[0]

func start_character_event(id: String) -> RefCounted:
	# Once the start command has been given, the operation is an uninterrupted
	# flow. Location introductions and other character events must never replace
	# the active surgical screen during a redraw or navigation callback.
	if active_surgery_in_progress():
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
		character_event_order.append(id)
	active_character_event_id = id
	active_mode = "character_event"
	return character_events[id]

func apply_relationship_choice(relation: Dictionary, choice: Dictionary) -> void:
	for metric in ["trust", "affection", "respect"]:
		relation[metric] = clampi(int(relation.get(metric, 0)) + int(choice.effects.get(metric, 0)), 0, 100)
	add_familiarity_to(relation, int(choice.effects.get("familiarity", 0)))
	for flag in choice.flags:
		if not relation.flags.has(flag):
			relation.flags.append(flag)

func choose_character_event(choice_id: String) -> bool:
	if active_character_event_id.is_empty() or not character_events.has(active_character_event_id):
		return false
	var event = character_events[active_character_event_id]
	if not event.apply(choice_id):
		return false
	var relation: Dictionary = relationships[event.definition.actor_id]
	apply_relationship_choice(relation, event.last_choice)
	var chosen_route := str(event.last_choice.get("route", ""))
	if chosen_route in ["colleague", "romance"] and (chosen_route != "romance" or int(event.definition.get("target_level", 1)) >= INTIMATE_ROUTE_LEVEL):
		relation.route = chosen_route
	if event.completed and not relation.event_history.has(event.definition.id):
		event.completed_day = day_number()
		relation.event_history.append(event.definition.id)
		if event.definition.category == "introduction":
			meet_staff(str(event.definition.actor_id))
		elif event.definition.category in ["bond", "rank_up"]:
			complete_rank_up(str(event.definition.actor_id), str(event.definition.id), int(event.definition.target_level), str(event.definition.get("benefit_id", "")))
	return true

func settle_overtime(start_elapsed: int, action_minutes: int) -> bool:
	var start_schedule := schedule_at(start_elapsed)
	if int(start_schedule.shift_minute) + action_minutes < SHIFT_MINUTES:
		return false
	var next_day_start := (start_elapsed / SHIFT_MINUTES + 1) * SHIFT_MINUTES
	var excess := elapsed() - next_day_start
	if excess > 0:
		discarded_overtime_minutes += excess
	return true

func time_events_at(location_id: String) -> Array:
	var result: Array = []
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
	if not time_event_definitions.has(id):
		return false
	var definition: Dictionary = time_event_definitions[id]
	if definition.actor_id != null and (not staff_is_met(str(definition.actor_id)) or str(definition.actor_id) not in staff_present_at(str(definition.location_id))):
		last_error = "这名职员现在不在这里，或者你们还没有认识。"
		return false
	if not definition.repeatable and time_event_done(id):
		last_error = "已经完成过这件事。"
		return false
	var responses: Array = definition.responses
	var variant := randi_range(0, responses.size() - 1)
	last_time_event_response = responses[variant]
	time_log.append({"id": id, "start": elapsed(), "variant": variant})
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

func day_text() -> String:
	return "DAY %02d" % day_number()

func shift_remaining() -> int:
	return int(schedule_at(elapsed()).remaining)

func clock_text() -> String:
	var time: int = schedule_at(elapsed()).absolute_clock
	return "%02d:%02d" % [time / 60, time % 60]

func admitted_patient(patient_id: String) -> bool:
	if completed_patient(patient_id):
		return false
	for visit in visits.values():
		if visit.definition.patient_id == patient_id and visit.admitted:
			return true
	return false

func completed_patient(patient_id: String) -> bool:
	for preparation in preops.values():
		if preparation.definition.patient_id == patient_id and preparation.surgery_success:
			return true
	return false

func current_patient_id() -> String:
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
		preops.erase(id)
	for id in visits.keys():
		var visit = visits[id]
		if visit.definition.patient_id != patient_id:
			continue
		for metric in archived_player_effects:
			archived_player_effects[metric] = int(archived_player_effects[metric]) + int(visit.player_effects.get(metric, 0))
		for record in visit.player_effect_history:
			archived_player_effect_history.append(record.duplicate(true))
		visits.erase(id)
	patient_referrals.erase(patient_id)
	if not case_templates.is_empty():
		var choices: Array = case_templates.keys()
		var previous_case: String = str(patient_cases.get(patient_id, ""))
		if choices.size() > 1:
			choices.erase(previous_case)
		choices.shuffle()
		patient_cases[patient_id] = choices[0]
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

func finish_active_surgery() -> bool:
	if active_preop_id.is_empty() or not preops.has(active_preop_id):
		return false
	var preparation = preops[active_preop_id]
	if not preparation.surgery_success:
		return false
	var completed_patient_id: String = preparation.definition.patient_id
	pending_surgery_day_transition = false
	active_preop_id = ""
	active_mode = "encounter"
	active_id = ""
	advance_patient_rotation(completed_patient_id)
	var next_patient_id := current_patient_id()
	if not next_patient_id.is_empty():
		var next_encounter_id := encounter_id_for_patient(next_patient_id)
		if not next_encounter_id.is_empty():
			open_visit(next_encounter_id)
	return true

func player_attributes() -> Dictionary:
	var result: Dictionary = PLAYER_ATTRIBUTE_BASE.duplicate(true)
	for metric in result:
		var minimum := -100 if metric in ["ethics", "reputation"] else 0
		result[metric] = clampi(int(result[metric]) + int(archived_player_effects.get(metric, 0)), minimum, 100)
	for preparation in preops.values():
		for metric in result:
			var minimum := -100 if metric in ["ethics", "reputation"] else 0
			result[metric] = clampi(int(result[metric]) + int(preparation.player_effects.get(metric, 0)), minimum, 100)
	for visit in visits.values():
		for metric in result:
			var minimum := -100 if metric in ["ethics", "reputation"] else 0
			result[metric] = clampi(int(result[metric]) + int(visit.player_effects.get(metric, 0)), minimum, 100)
	return result

func player_attribute_history() -> Array[Dictionary]:
	var result: Array[Dictionary] = archived_player_effect_history.duplicate(true)
	for preparation in preops.values():
		for record in preparation.player_effect_history:
			result.append(record.duplicate(true))
	for visit in visits.values():
		for record in visit.player_effect_history:
			result.append(record.duplicate(true))
	return result

func snapshot() -> Dictionary:
	var progress := {}
	for id in visits:
		progress[id] = visits[id].action_log.duplicate()
	var preparation_logs := {}
	for id in preops:
		preparation_logs[id] = preops[id].events.duplicate(true)
	return {"version": SAVE_VERSION, "content_version": CONTENT_VERSION,
		"active_id": active_id, "progress": progress, "preops": preparation_logs,
		"active_preop_id": active_preop_id, "active_mode": active_mode,
		"patient_cases": patient_cases.duplicate(true),
		"patient_queue": patient_queue.duplicate(),
		"patient_referrals": patient_referrals.duplicate(true),
		"recent_patient_ids": recent_patient_ids.duplicate(),
		"archived_player_effects": archived_player_effects.duplicate(true),
		"archived_player_effect_history": archived_player_effect_history.duplicate(true),
		"pending_surgery_day_transition": pending_surgery_day_transition,
		"time_log": time_log.duplicate(true),
		"discarded_overtime_minutes": discarded_overtime_minutes,
		"story_time_advance_minutes": story_time_advance_minutes,
		"relationship_state": relationships.duplicate(true),
		"character_events": character_event_order.map(func(id: String): return {"id": id, "choices": character_events[id].choices.duplicate(), "completed_day": character_events[id].completed_day}),
		"active_character_event_id": active_character_event_id,
		"micro_events": micro_event_order.map(func(id: String): return {"id": id, "choice_id": micro_events[id].choice_id, "trigger_day": micro_events[id].trigger_day, "opening_index": micro_events[id].opening_index, "response_index": micro_events[id].response_index}),
		"active_micro_event_id": active_micro_event_id}

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
	# Validate and replay in temporary objects; never partially mutate live progress.
	last_error = "存档格式不正确，当前进度未改变。"
	if not data is Dictionary:
		return false
	var version := int(data.get("version", -1))
	if version < 1 or version > SAVE_VERSION or data.get("content_version") != CONTENT_VERSION:
		last_error = "存档版本不兼容，当前进度未改变。"
		return false
	if not data.get("progress") is Dictionary or not data.get("active_id") is String:
		return false
	var restored_patient_cases: Dictionary = {}
	if not case_templates.is_empty():
		restored_patient_cases = data.get("patient_cases", {}) if version >= 7 else legacy_patient_cases()
		if not valid_patient_cases(restored_patient_cases):
			return false
	elif version >= 7 and (not data.get("patient_cases") is Dictionary or not data.patient_cases.is_empty()):
		return false
	var restored_patient_queue: Array[String] = []
	var restored_patient_referrals: Dictionary = {}
	var restored_recent_patient_ids: Array[String] = []
	var restored_archived_player_effects := zero_player_effects()
	var restored_archived_player_effect_history: Array[Dictionary] = []
	if version >= 9:
		if not valid_patient_queue(data.get("patient_queue")) or not data.get("patient_referrals") is Dictionary:
			return false
		for patient_id in data.patient_queue:
			restored_patient_queue.append(patient_id)
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
	else:
		for patient in patient_definitions:
			restored_patient_queue.append(patient.id)
	if version >= 11:
		if not valid_recent_patients(data.get("recent_patient_ids")) or not data.get("archived_player_effects") is Dictionary or not data.get("archived_player_effect_history") is Array:
			return false
		for patient_id in data.recent_patient_ids:
			restored_recent_patient_ids.append(patient_id)
		for metric in PLAYER_ATTRIBUTE_BASE:
			var raw_effect: Variant = data.archived_player_effects.get(metric)
			if not (raw_effect is int or raw_effect is float) or float(raw_effect) != floorf(float(raw_effect)):
				return false
			restored_archived_player_effects[metric] = int(raw_effect)
		if data.archived_player_effect_history.size() > 5000:
			return false
		for record in data.archived_player_effect_history:
			if not record is Dictionary or not record.get("id") is String or not record.get("label") is String or not record.get("effects") is Dictionary:
				return false
			restored_archived_player_effect_history.append(record.duplicate(true))
	var restored_definitions := encounter_definitions_for(restored_patient_cases)
	var restored_preop_definitions := preop_definitions_for(restored_patient_cases)
	var rebuilt := {}
	for id in data.progress:
		if not restored_definitions.has(id) or not data.progress[id] is Array:
			return false
		var events: Array = data.progress[id]
		if events.size() > 500:
			return false
		if version < 17:
			events = migrate_full_undress_exam(events)
		var visit = Encounter.new(restored_definitions[id])
		for event in events:
			if not event is String or not visit.apply(event):
				last_error = "存档中的病例进度无效，当前进度未改变。"
				return false
		rebuilt[id] = visit
	if data.active_id != "" and not rebuilt.has(data.active_id):
		return false
	var rebuilt_preops := {}
	var mode := "encounter"
	var current_preop := ""
	if version >= 2:
		var valid_modes := ["encounter", "preop", "character_event"]
		if version >= 10:
			valid_modes.append("micro_event")
		if not data.get("preops") is Dictionary or not data.get("active_preop_id") is String or data.get("active_mode") not in valid_modes:
			return false
		for id in data.preops:
			if not restored_preop_definitions.has(id) or not data.preops[id] is Array or data.preops[id].size() > 500:
				return false
			var definition: Dictionary = restored_preop_definitions[id]
			if not rebuilt.has(definition.encounter_id) or not rebuilt[definition.encounter_id].admitted:
				last_error = "存档中的术前准备缺少住院记录。"
				return false
			var prep = Preop.new(definition, staff, surgery_definitions, patient_definitions, [], false, surgery_team_dialogue_profiles, patient_interaction_definitions)
			var preop_events: Array = migrate_legacy_surgery_events(data.preops[id])
			if version < 12:
				preop_events = migrate_surgery_flow_acknowledgements(preop_events)
			if version < 14:
				preop_events = migrate_surgery_patient_acknowledgements(preop_events)
			if version < 15:
				preop_events = migrate_operative_preparation_events(preop_events)
			if version < 16:
				preop_events = migrate_wrong_surgery_decision_retries(preop_events)
			for event in preop_events:
				if not prep.apply(event):
					last_error = "存档中的术前选择无效，当前进度未改变。"
					return false
			rebuilt_preops[id] = prep
		mode = data.active_mode
		current_preop = data.active_preop_id
		if current_preop != "" and not rebuilt_preops.has(current_preop):
			return false
		if mode == "preop" and current_preop.is_empty():
			return false
	var rebuilt_time_log: Array[Dictionary] = []
	var rebuilt_discarded_overtime := 0
	var rebuilt_story_time_advance := 0
	var rebuilt_pending_surgery_transition := false
	var rebuilt_relationships := fresh_relationships()
	var rebuilt_character_events := {}
	var rebuilt_character_event_order: Array[String] = []
	var rebuilt_active_character_event := ""
	var rebuilt_micro_events := {}
	var rebuilt_micro_event_order: Array[String] = []
	var rebuilt_active_micro_event := ""
	var restored_relationship_state: Dictionary = {}
	if version >= 19:
		if not data.get("relationship_state") is Dictionary:
			return false
		for actor_id in rebuilt_relationships:
			var saved: Variant = data.relationship_state.get(actor_id)
			if not saved is Dictionary:
				return false
			for key in ["met", "level", "route", "rank_history", "unlocked_benefits"]:
				if not saved.has(key):
					return false
			restored_relationship_state[actor_id] = saved.duplicate(true)
	if version >= 6:
		if not data.get("character_events") is Array or not data.get("active_character_event_id") is String:
			return false
		for record in data.character_events:
			var expected_character_event_record_size := 3 if version >= 20 else 2
			if not record is Dictionary or record.size() != expected_character_event_record_size or not record.get("id") is String or not record.get("choices") is Array:
				return false
			if not character_event_definitions.has(record.id) or rebuilt_character_events.has(record.id):
				return false
			var event = CharacterEvent.new(character_event_definitions[record.id])
			for choice_id in record.choices:
				if not choice_id is String or not event.apply(choice_id):
					return false
				apply_relationship_choice(rebuilt_relationships[event.definition.actor_id], event.last_choice)
				var restored_route := str(event.last_choice.get("route", ""))
				if restored_route in ["colleague", "romance"] and (restored_route != "romance" or int(event.definition.get("target_level", 1)) >= INTIMATE_ROUTE_LEVEL):
					rebuilt_relationships[event.definition.actor_id].route = restored_route
			if event.completed:
				event.completed_day = int(record.get("completed_day", 1))
				rebuilt_relationships[event.definition.actor_id].event_history.append(event.definition.id)
				if event.definition.category == "introduction":
					rebuilt_relationships[event.definition.actor_id].met = true
				elif event.definition.category in ["bond", "rank_up"]:
					var restored_relation: Dictionary = rebuilt_relationships[event.definition.actor_id]
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
		if not rebuilt_active_character_event.is_empty() and not rebuilt_character_events.has(rebuilt_active_character_event):
			return false
	if version >= 10:
		if not data.get("micro_events") is Array or not data.get("active_micro_event_id") is String or data.micro_events.size() > micro_event_definitions.size():
			return false
		for record in data.micro_events:
			var expected_record_size := 5 if version >= 18 else 3
			if not record is Dictionary or record.size() != expected_record_size or not record.get("id") is String or not record.get("choice_id") is String:
				return false
			if version >= 18:
				var raw_opening_index: Variant = record.get("opening_index")
				var raw_response_index: Variant = record.get("response_index")
				if not (raw_opening_index is int or raw_opening_index is float) or float(raw_opening_index) != floorf(float(raw_opening_index)) or int(raw_opening_index) < 0:
					return false
				if not (raw_response_index is int or raw_response_index is float) or float(raw_response_index) != floorf(float(raw_response_index)) or int(raw_response_index) < 0:
					return false
			var raw_day: Variant = record.get("trigger_day")
			if not (raw_day is int or raw_day is float) or float(raw_day) != floorf(float(raw_day)) or int(raw_day) < 1:
				return false
			if not micro_event_definitions.has(record.id) or rebuilt_micro_events.has(record.id):
				return false
			var event = MicroEvent.new(micro_event_definitions[record.id], int(raw_day))
			event.opening_index = clampi(int(record.get("opening_index", 0)), 0, maxi(0, event.opening_lines().size() - 1))
			if not record.choice_id.is_empty():
				if not event.apply(record.choice_id):
					return false
				event.response_index = clampi(int(record.get("response_index", 0)), 0, maxi(0, event.response_lines().size() - 1))
				apply_micro_event_choice(rebuilt_relationships[event.definition.actor_id], event.last_choice)
			rebuilt_micro_events[record.id] = event
			rebuilt_micro_event_order.append(record.id)
		rebuilt_active_micro_event = data.active_micro_event_id
		if not rebuilt_active_micro_event.is_empty() and not rebuilt_micro_events.has(rebuilt_active_micro_event):
			return false
		if mode == "micro_event" and rebuilt_active_micro_event.is_empty():
			return false
	if version >= 19:
		for actor_id in rebuilt_relationships:
			var saved: Dictionary = restored_relationship_state[actor_id]
			if not saved.met is bool or not saved.level is int or int(saved.level) < 0 or int(saved.level) > RELATIONSHIP_MAX_LEVEL or str(saved.route) not in ["colleague", "romance"] or not saved.rank_history is Array or not saved.unlocked_benefits is Array:
				return false
			for key in ["met", "level", "route", "rank_history", "unlocked_benefits"]:
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
		var reconstructed_total := 0
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
			rebuilt_story_time_advance = int(raw_story_advance)
			reconstructed_total += rebuilt_story_time_advance
		if previous_end > reconstructed_total:
			return false
		if version >= 5:
			var raw_discarded: Variant = data.get("discarded_overtime_minutes")
			if not (raw_discarded is int or raw_discarded is float) or float(raw_discarded) != floorf(float(raw_discarded)) or int(raw_discarded) < 0 or int(raw_discarded) > reconstructed_total:
				return false
			rebuilt_discarded_overtime = int(raw_discarded)
	if version >= 8:
		if not data.get("pending_surgery_day_transition") is bool:
			return false
		rebuilt_pending_surgery_transition = data.pending_surgery_day_transition
		if rebuilt_pending_surgery_transition:
			if current_preop.is_empty() or not rebuilt_preops.has(current_preop) or not rebuilt_preops[current_preop].surgery_success:
				return false
	for patient_id in restored_patient_referrals:
		for visit in rebuilt.values():
			if visit.definition.patient_id == patient_id and visit.admitted:
				return false
		for preparation in rebuilt_preops.values():
			if preparation.definition.patient_id == patient_id and preparation.surgery_success:
				return false
	visits = rebuilt
	preops = rebuilt_preops
	patient_cases = restored_patient_cases
	patient_queue = restored_patient_queue
	patient_referrals = restored_patient_referrals
	recent_patient_ids = restored_recent_patient_ids
	archived_player_effects = restored_archived_player_effects
	archived_player_effect_history = restored_archived_player_effect_history
	definitions = restored_definitions
	preop_definitions = restored_preop_definitions
	time_log = rebuilt_time_log
	relationships = rebuilt_relationships
	for preparation in rebuilt_preops.values():
		preparation.set_known_staff(known_staff_ids(), true)
	character_events = rebuilt_character_events
	character_event_order = rebuilt_character_event_order
	active_character_event_id = rebuilt_active_character_event
	micro_events = rebuilt_micro_events
	micro_event_order = rebuilt_micro_event_order
	active_micro_event_id = rebuilt_active_micro_event
	discarded_overtime_minutes = rebuilt_discarded_overtime
	story_time_advance_minutes = rebuilt_story_time_advance
	pending_surgery_day_transition = rebuilt_pending_surgery_transition
	active_preop_id = current_preop
	active_mode = mode
	active_id = data.active_id
	ensure_waiting_patient()
	last_error = ""
	return true

func open_preop(id: String) -> RefCounted:
	if not preop_definitions.has(id):
		return null
	var definition: Dictionary = preop_definitions[id]
	if completed_patient(definition.patient_id) and id != active_preop_id:
		return null
	if not visits.has(definition.encounter_id) or not visits[definition.encounter_id].admitted:
		return null
	if not preops.has(id):
		preops[id] = Preop.new(definition, staff, surgery_definitions, patient_definitions, known_staff_ids(), true, surgery_team_dialogue_profiles, patient_interaction_definitions)
	else:
		preops[id].set_known_staff(known_staff_ids(), true)
	active_id = definition.encounter_id
	active_preop_id = id
	active_mode = "preop"
	return preops[id]
