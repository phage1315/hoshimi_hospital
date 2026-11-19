extends RefCounted
## Domain helper for Mido Emiko (`doc_emiko`) Relationship Lv5:
## 《神的双手》 (Hands of God / V1.0).
##
## Contract summary:
## - Weekday Mon–Fri `after_work` milestone (`emiko_lv5_hands_of_god`) at
##   `emiko_office` (`time_start = 960`, `time_end = 1320`, `locks_saving = true`),
##   blocked on `Day 364–365`, when `workday + 1` is closed (Sunday/holiday),
##   when reserved by an Advanced Referral review/operation, or when an
##   unresolved inpatient awaits surgery.
## - Requires `emiko_lv4_emikos_secret`, `level == 4`, `familiarity >= 75`,
##   `skill >= 90`, `staff_as_patient_program_authorized`, and 3-day milestone
##   cooldown (`relationship_rank_gate_met("doc_emiko", 5)`).
## - Internal narrative time transitions (next-night conscious epidural training
##   in OR 1, six-day gap to synchronized dual-room living-donor right-lobe
##   liver transplant, and post-ICU bedside joint ward round) stay strictly
##   internal to the atomic save-locked VN session without skipping global
##   multi-day schedules.
## - Atomic settlement ONLY after Act 6 corridor epilogue (`em5_s6m_04` -> `@end`):
##   - Promotes `doc_emiko` `Lv4 -> Lv5` (`benefit_id = "unlock_clinical_practice_patient"`),
##     sets `emiko_lv5_complete = true`, and advances clock once to `Day T+1 09:00`
##     (`completion_day_offset = 1`, `completion_absolute_clock = 540`).
##   - Strictly writes ZERO separate Chief-of-Surgery competition boolean flags
##     (downstream Chief-of-Surgery arc checks existing Emiko Lv5 / Gate clear
##     state only); keeps story guests `高瀬晴子` (`haruko_takase`) and
##     `宮原奈緒美` (`naomi_miyahara`) out of random outpatient pools and surgery
##     queues; and leaves `staff_patient_unlocked("doc_emiko")` governed strictly
##     by existing `staff_patient_profiles.json` registration & hospital-wide
##     authorization rules.

const ACTOR := "doc_emiko"
const ARTORIA := "doc_artoria"
const EVENT_ID := "emiko_lv5_hands_of_god"
const INTRO_EVENT_ID := "emiko_intro_rumored_hands"
const LV1_EVENT_ID := "emiko_lv1_first_operation"
const LV2_EVENT_ID := "emiko_lv2_follow_my_lead"
const LV3_EVENT_ID := "emiko_lv3_today_i_lead"
const LV4_EVENT_ID := "emiko_lv4_emikos_secret"
const ARTORIA_INTRO_EVENT_ID := "intro_doc_artoria_deputy_office"
const FLAG_CABG_TEACHING := "emiko_cabg_teaching_complete"
const FLAG_COMPLETE := "emiko_lv5_complete"

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
		or (not g.active_character_event_id.is_empty() and g.active_character_event_id != EVENT_ID)
		or not g.active_micro_event_id.is_empty()
		or not g.active_after_work_walk.is_empty()
		or not g.active_free_h_departure.is_empty()
		or g.active_adult_intimacy != null
		or g.unresolved_admitted_patient_exists()
	)

static func calendar_safe_for_workday(g: RefCounted, workday: int) -> bool:
	if g == null or workday < 1 or workday > int(g.GAME_DURATION_DAYS) - 2:
		return false
	if not g.is_routine_workday(workday) or g.is_hospital_closed_day(workday + 1):
		return false
	if g.advanced_referral_facts is Dictionary:
		var appointment: Variant = g.advanced_referral_facts.get("appointment", {})
		if appointment is Dictionary and not appointment.is_empty():
			var op_day := int(appointment.get("operation_day", 0))
			var rev_day := int(appointment.get("review_day", 0))
			if op_day == workday or op_day == workday + 1 or rev_day == workday or rev_day == workday + 1:
				return false
	return true

static func eligible(g: RefCounted, id: String) -> bool:
	if not owns(id) or not safe(g):
		return false
	var workday: int = int(g.current_workday())
	if not calendar_safe_for_workday(g, workday):
		return false
	if not g.staff_is_met(ACTOR) or int(g.relationship_level(ACTOR)) != 4:
		return false
	if not g.character_event_done(LV4_EVENT_ID):
		return false
	return g.relationship_rank_gate_met(ACTOR, 5)

static func completed(g: RefCounted) -> bool:
	if g == null or not g.character_event_done(EVENT_ID) or int(g.relationship_level(ACTOR)) != 5:
		return false
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
	relation.level = 4
	relation.familiarity = maxi(int(relation.get("familiarity", 0)), 75)
	for benefit in ["unlock_emiko_surgical_team", "unlock_intimacy_events"]:
		if not relation.unlocked_benefits.has(benefit):
			relation.unlocked_benefits.append(benefit)
	g.set_test_player_attribute("skill", maxi(int(g.player_attributes().get("skill", 0)), 90))
	g.set_test_player_attribute("presence", maxi(int(g.player_attributes().get("presence", 0)), 30))
	g._complete_character_event_for_test(INTRO_EVENT_ID, 2)
	var lv1_day := 4
	g._complete_character_event_for_test(LV1_EVENT_ID, lv1_day)
	if not relation.rank_history.has(LV1_EVENT_ID):
		relation.rank_history.append(LV1_EVENT_ID)
	g.set_story_flag("emiko_lv1_complete", true)
	g.set_story_flag("emiko_postop_excitement_hint", true)
	var lv2_day := 7
	g._complete_character_event_for_test(LV2_EVENT_ID, lv2_day)
	if not relation.rank_history.has(LV2_EVENT_ID):
		relation.rank_history.append(LV2_EVENT_ID)
	g.set_story_flag("emiko_lv2_complete", true)
	g.set_story_flag("emiko_reliable_surgical_partner", true)
	var lv3_day := 10
	g._complete_character_event_for_test(LV3_EVENT_ID, lv3_day)
	if not relation.rank_history.has(LV3_EVENT_ID):
		relation.rank_history.append(LV3_EVENT_ID)
	g.set_story_flag("emiko_lv3_complete", true)
	g.set_story_flag(FLAG_CABG_TEACHING, true)
	g.unlock_procedure("surgery_cabg")
	var lv4_day := 13
	g._complete_character_event_for_test(LV4_EVENT_ID, lv4_day)
	if not relation.rank_history.has(LV4_EVENT_ID):
		relation.rank_history.append(LV4_EVENT_ID)
	g.set_story_flag("emiko_lv4_complete", true)
	g.set_story_flag("staff_as_patient_program_authorized", true)
	var target_day := maxi(base_day, lv4_day + 3)
	while target_day <= int(g.GAME_DURATION_DAYS) - 2 and not calendar_safe_for_workday(g, target_day):
		target_day += 1
	return target_day
