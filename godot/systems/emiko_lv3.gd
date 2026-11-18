extends RefCounted
## Domain helper for Mido Emiko (`doc_emiko`) Relationship Lv3:
## 《今天我主刀》 (Today, I Lead the Table / V1.1).
##
## Contract summary:
## - Weekday Mon–Fri `after_work` milestone (`emiko_lv3_today_i_lead`), never
##   Saturday (so "tomorrow morning 09:00 elective CABG" never lands on Sunday)
##   and never when an unresolved inpatient or next-day Advanced Referral
##   operation/review booking exists.
## - Requires `emiko_lv2_follow_my_lead`, `level == 2`, `familiarity >= 40`,
##   `presence >= 20`, 3-day milestone cooldown, and Artoria formally met
##   (`staff_is_met("doc_artoria")`).
## - Resolves Scene 1 `S / O / G` assistant probe strictly read-only from
##   existing v37 boundary facts (`character_progress_counters`,
##   `recent_patient_ids`, `preops`), adding zero persisted fields and zero
##   inner performance state.
## - Two-stage settlement:
##   1) End of Scene 3 (`CABG_TEACHING_CHOICE_ID`) unlocks ordinary-pool
##      procedure `surgery_cabg` (`emiko_cabg_teaching_complete = true`).
##   2) End of Scene 6 (`@end`) promotes `doc_emiko` `Lv2 -> Lv3`, sets
##      `emiko_lv3_complete`, and advances to next day `14:00` (`840`).

const ACTOR := "doc_emiko"
const ARTORIA := "doc_artoria"
const EVENT_ID := "emiko_lv3_today_i_lead"
const INTRO_EVENT_ID := "emiko_intro_rumored_hands"
const LV1_EVENT_ID := "emiko_lv1_first_operation"
const LV2_EVENT_ID := "emiko_lv2_follow_my_lead"
const ARTORIA_INTRO_EVENT_ID := "intro_doc_artoria_deputy_office"
const FLAG_CABG_TEACHING := "emiko_cabg_teaching_complete"
const FLAG_COMPLETE := "emiko_lv3_complete"
const CABG_PROCEDURE_ID := "surgery_cabg"
const CABG_TEACHING_CHOICE_ID := "em3_cabg_teaching_complete"

const PROBE_GATE_NODE_ID := "em3_s1_52"
const CHOICE1_A_GATE_NODE_ID := "em3_c1a_04"
const PROBE_S_START := "em3_s_01"
const PROBE_O_START := "em3_o_01"
const PROBE_O_NAME_NODE_ID := "em3_o_02"
const PROBE_G_START := "em3_g_01"
const CHOICE1_A_S_NODE_ID := "em3_c1a_s_01"
const CHOICE1_A_OG_NODE_ID := "em3_c1a_og_01"
const PLACEHOLDER_RECENT_DOCTOR := "{recent_assistant_doctor}"

static func owns(id: String) -> bool:
	return id == EVENT_ID

static func safe(g: RefCounted) -> bool:
	if g == null:
		return false
	return not (
		g.active_surgery_committed()
		or g.active_surgery_in_progress()
		or g.active_encounter_in_progress()
		or not g.active_preop_id.is_empty()
		or not g.active_special_event_id.is_empty()
		or g.special_event_in_progress()
		or not g.active_character_event_id.is_empty()
		or not g.active_micro_event_id.is_empty()
		or not g.active_after_work_walk.is_empty()
		or not g.active_free_h_departure.is_empty()
		or g.active_adult_intimacy != null
		or g.unresolved_admitted_patient_exists()
	)

static func calendar_safe_for_workday(g: RefCounted, workday: int) -> bool:
	if g == null or workday < 1 or workday >= int(g.GAME_DURATION_DAYS):
		return false
	# Scene 1 takes place on `workday` night (Mon-Fri routine workday) and
	# schedules elective CABG for `workday + 1` at 09:00. Block Saturday,
	# Sunday, and any workday whose next day is a closed holiday/Sunday.
	if not g.is_routine_workday(workday) or g.is_hospital_closed_day(workday + 1):
		return false
	if g.advanced_referral_facts is Dictionary:
		var appointment: Variant = g.advanced_referral_facts.get("appointment", {})
		if appointment is Dictionary and not appointment.is_empty():
			var next_day := workday + 1
			if int(appointment.get("operation_day", 0)) == next_day or int(appointment.get("review_day", 0)) == next_day:
				return false
	return true

static func eligible(g: RefCounted, id: String) -> bool:
	if not owns(id) or not safe(g):
		return false
	var workday: int = int(g.current_workday())
	if not calendar_safe_for_workday(g, workday):
		return false
	if not g.staff_is_met(ACTOR) or g.relationship_level(ACTOR) != 2:
		return false
	if not g.character_event_done(LV2_EVENT_ID):
		return false
	if not g.staff_is_met(ARTORIA):
		return false
	return g.relationship_rank_gate_met(ACTOR, 3)

static func format_doctor_name(g: RefCounted, person: Dictionary) -> String:
	var raw_name := str(person.get("name", "")).strip_edges()
	if raw_name.is_empty():
		return ""
	if g != null and g.patient_content_locale() == "en":
		return raw_name if raw_name.begins_with("Dr.") else "Dr. " + raw_name
	return raw_name.replace(" ", "").replace("　", "")

static func _completed_preop_for_patient(g: RefCounted, patient_id: String):
	for prep in g.preops.values():
		if bool(prep.surgery_success) and not prep.is_staff_patient() and str(prep.definition.get("patient_id", "")) == patient_id:
			return prep
	return null

static func resolve_assistant_branch(g: RefCounted) -> Dictionary:
	if g == null:
		return {"branch": "G", "doctor_id": "", "doctor_name": ""}
	# 1. Branch S: Reliable record of Artoria serving as Sakaguchi's first assistant.
	if int(g.character_progress_counter(ARTORIA, "completed_surgeries_as_assistant_surgeon")) > 0:
		return {"branch": "S", "doctor_id": ARTORIA, "doctor_name": format_doctor_name(g, g.staff_record(ARTORIA))}
	for prep in g.preops.values():
		if bool(prep.surgery_success) and str(prep.team.get("assistant_surgeon", "")) == ARTORIA:
			return {"branch": "S", "doctor_id": ARTORIA, "doctor_name": format_doctor_name(g, g.staff_record(ARTORIA))}
	# 2. Branch O vs G: Check the most recent retained player-led completed surgery.
	var found_recent_completed := false
	for idx in range(g.recent_patient_ids.size() - 1, -1, -1):
		var patient_id := str(g.recent_patient_ids[idx])
		var prep = _completed_preop_for_patient(g, patient_id)
		if prep == null:
			continue
		found_recent_completed = true
		var assistant_id := str(prep.team.get("assistant_surgeon", ""))
		if assistant_id.is_empty() or assistant_id == ACTOR or assistant_id == ARTORIA:
			return {"branch": "G", "doctor_id": "", "doctor_name": ""}
		var person: Dictionary = g.staff_record(assistant_id)
		if person.is_empty() or str(person.get("profession", "")) != "doctor":
			return {"branch": "G", "doctor_id": "", "doctor_name": ""}
		var doctor_name := format_doctor_name(g, person)
		if doctor_name.is_empty():
			return {"branch": "G", "doctor_id": "", "doctor_name": ""}
		return {"branch": "O", "doctor_id": assistant_id, "doctor_name": doctor_name}
	# Fallback when recent_patient_ids holds no retained completed preop (e.g.
	# followed by referrals): only use O when Emiko has 0 assistant runs and
	# exactly one non-Emiko, non-Artoria doctor has assistant runs > 0.
	if not found_recent_completed and int(g.character_progress_counter(ACTOR, "completed_surgeries_as_assistant_surgeon")) == 0:
		var candidate_doctors: Array[Dictionary] = []
		for person in g.staff:
			var doc_id := str(person.get("id", ""))
			if doc_id in ["", ACTOR, ARTORIA] or str(person.get("profession", "")) != "doctor":
				continue
			if int(g.character_progress_counter(doc_id, "completed_surgeries_as_assistant_surgeon")) > 0:
				candidate_doctors.append(person)
		if candidate_doctors.size() == 1:
			var only_doc: Dictionary = candidate_doctors[0]
			var only_name := format_doctor_name(g, only_doc)
			if not only_name.is_empty():
				return {"branch": "O", "doctor_id": str(only_doc.get("id", "")), "doctor_name": only_name}
	return {"branch": "G", "doctor_id": "", "doctor_name": ""}

static func seasonal_casual_outfit(g: RefCounted) -> String:
	if g == null:
		return "casual"
	var workday := int(g.current_workday())
	var month := int(g.calendar_date(maxi(1, workday)).get("month", 4))
	var portraits: Dictionary = g.staff_record(ACTOR).get("visuals", {}).get("portraits", {})
	if month in [9, 10, 11, 12, 1, 2] and portraits.has("casual_winter/neutral"):
		return "casual_winter"
	return "casual"

static func cast_definition(g: RefCounted, source: Dictionary) -> Dictionary:
	var definition: Dictionary = source.duplicate(true)
	var resolved: Dictionary = resolve_assistant_branch(g)
	var branch := str(resolved.get("branch", "G"))
	var doctor_name := str(resolved.get("doctor_name", ""))
	if doctor_name.is_empty():
		var english: bool = g != null and str(g.patient_content_locale()) == "en"
		doctor_name = "another surgeon" if english else "别的医生"
	var casual_outfit: String = seasonal_casual_outfit(g)
	for node in definition.get("nodes", []):
		if not node is Dictionary:
			continue
		var node_id := str(node.get("id", ""))
		if str(node.get("outfit", "")) == "casual" and str(node.get("actor_id", ACTOR)) == ACTOR:
			node["outfit"] = casual_outfit
		if node.has("event_portraits") and node.event_portraits is Array:
			for slot in node.event_portraits:
				if slot is Dictionary:
					if str(slot.get("actor_id", "")) == ACTOR and str(slot.get("outfit", "")) == "casual":
						slot["outfit"] = casual_outfit
					if casual_outfit == "casual_winter" and str(slot.get("id", "")) == ACTOR and str(slot.get("path", "")).find("spring_summer_casual_v1/doc_emiko/neutral.png") != -1:
						slot["path"] = "assets/characters/winter_casual_v1/doc_emiko/neutral.png"
		if node_id == PROBE_GATE_NODE_ID and node.get("choices", []) is Array and not node.choices.is_empty():
			match branch:
				"S":
					node.choices[0]["next"] = PROBE_S_START
				"O":
					node.choices[0]["next"] = PROBE_O_START
				_:
					node.choices[0]["next"] = PROBE_G_START
		elif node_id == PROBE_O_NAME_NODE_ID:
			node["text"] = str(node.get("text", "")).replace(PLACEHOLDER_RECENT_DOCTOR, doctor_name)
		elif node_id == CHOICE1_A_GATE_NODE_ID and node.get("choices", []) is Array and not node.choices.is_empty():
			node.choices[0]["next"] = CHOICE1_A_S_NODE_ID if branch == "S" else CHOICE1_A_OG_NODE_ID
	return definition

static func on_choice_applied(g: RefCounted, choice_id: String) -> void:
	if g == null:
		return
	if choice_id == CABG_TEACHING_CHOICE_ID:
		unlock_cabg(g)

static func unlock_cabg(g: RefCounted) -> void:
	if g == null:
		return
	g.set_story_flag(FLAG_CABG_TEACHING, true)
	g.unlock_procedure(CABG_PROCEDURE_ID)

static func completed(g: RefCounted) -> bool:
	if g == null or not g.character_event_done(EVENT_ID) or g.relationship_level(ACTOR) != 3:
		return false
	unlock_cabg(g)
	g.set_story_flag(FLAG_COMPLETE, true)
	return true

static func prepare_test_save(g: RefCounted, _event_id: String, base_day: int) -> int:
	g.meet_staff("doc_asuka")
	g._complete_character_event_for_test("intro_doc_asuka_director_office", 1)
	g._complete_character_event_for_test("asuka_mentions_artoria_rival", 1)
	g.meet_staff(ARTORIA)
	g._complete_character_event_for_test(ARTORIA_INTRO_EVENT_ID, 2)
	g.meet_staff(ACTOR)
	var relation: Dictionary = g.relation_for(ACTOR)
	relation.met = true
	relation.level = 2
	relation.familiarity = maxi(int(relation.get("familiarity", 0)), 40)
	if not relation.unlocked_benefits.has("unlock_emiko_surgical_team"):
		relation.unlocked_benefits.append("unlock_emiko_surgical_team")
	g.set_test_player_attribute("skill", maxi(int(g.player_attributes().get("skill", 0)), 80))
	g.set_test_player_attribute("presence", maxi(int(g.player_attributes().get("presence", 0)), 20))
	g._complete_character_event_for_test(INTRO_EVENT_ID, 2)
	var lv1_day := 5
	g._complete_character_event_for_test(LV1_EVENT_ID, lv1_day)
	if not relation.rank_history.has(LV1_EVENT_ID):
		relation.rank_history.append(LV1_EVENT_ID)
	g.set_story_flag("emiko_lv1_complete", true)
	g.set_story_flag("emiko_postop_excitement_hint", true)
	var lv2_day := 8
	g._complete_character_event_for_test(LV2_EVENT_ID, lv2_day)
	if not relation.rank_history.has(LV2_EVENT_ID):
		relation.rank_history.append(LV2_EVENT_ID)
	g.set_story_flag("emiko_lv2_complete", true)
	g.set_story_flag("emiko_reliable_surgical_partner", true)
	var target_day := maxi(base_day, lv2_day + 3)
	while target_day < int(g.GAME_DURATION_DAYS) and not calendar_safe_for_workday(g, target_day):
		target_day += 1
	return target_day
