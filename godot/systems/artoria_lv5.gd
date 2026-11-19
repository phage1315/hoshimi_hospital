extends RefCounted
## Domain helper for Artoria Pendragon (`doc_artoria`) Relationship Lv5:
## 《我的位置》 (My Place / V1.1).
##
## Contract summary:
## - Routine Monday–Thursday morning (`09:00–12:00`, `time_start = 540`, `time_end = 720`)
##   location milestone at `artoria_office` (`trigger_mode = "location"`, `auto_start = false`,
##   `locks_saving = true`), spanning `workday` (mentorship selection & announcement) and
##   `workday + 1` (Aoi Tohsaka's open Hepp-Couinaud biliary reconstruction, Anji debrief,
##   and evening 4F surgical observation-window epilogue).
## - Blocked on Friday (`workday + 1` would be Saturday), Saturday, Sunday, after `12:00`,
##   when `workday > 362` (protecting Anji Tonegawa's `Day 364–365` departure window across
##   both `workday` and `workday + 1`), when an unresolved admitted inpatient exists, or
##   when an `AdvancedReferral` appointment (`operation_day` or `review_day`) occupies
##   `workday` or `workday + 1`.
## - Requires `artoria_lv4_just_artoria`, `level == 4`, `familiarity >= 75`,
##   `leadership >= 90`, `skill >= 80`, `staff_as_patient_program_authorized`,
##   and 3-day milestone cooldown (`relationship_rank_gate_met("doc_artoria", 5)`).
## - Atomic settlement ONLY after Act 6 corridor epilogue (`ar5_s6m_02` -> `@end`):
##   - Promotes `doc_artoria` `Lv4 -> Lv5` (`benefit_id = "unlock_clinical_practice_patient"`),
##     sets `artoria_lv5_complete = true`, and advances clock once to `Day T+2 09:00`
##     (`completion_day_offset = 2`, `completion_absolute_clock = 540`).
##   - Keeps guest patient `远坂葵` (`aoi_tohsaka`) strictly out of random outpatient pools
##     and surgery queues, leaves `nurse_hiroko` / `nurse_moe` / `nurse_ange` relationship
##     and familiarity untouched, never writes any Chief-of-Surgery yield/withdraw flags,
##     and unlocks `staff_patient_unlocked("doc_artoria")` via her registered
##     Staff-as-Patient clinical profile (`data/staff_patient_profiles.json`).

const ACTOR := "doc_artoria"
const EMIKO := "doc_emiko"
const EVENT_ID := "artoria_lv5_my_position"
const ASUKA_INTRO_EVENT_ID := "intro_doc_asuka_director_office"
const EMIKO_INTRO_EVENT_ID := "emiko_intro_rumored_hands"
const RIVAL_REFERRAL_EVENT_ID := "asuka_mentions_artoria_rival"
const INTRO_EVENT_ID := "intro_doc_artoria_deputy_office"
const LV1_EVENT_ID := "artoria_lv1_right_position"
const LV2_EVENT_ID := "artoria_lv2_what_remains"
const LV3_EVENT_ID := "artoria_lv3_not_a_solo_operation"
const LV4_EVENT_ID := "artoria_lv4_just_artoria"
const FLAG_COMPLETE := "artoria_lv5_complete"
const TIME_START := 540
const TIME_END := 720

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
	if g == null or workday < 1 or workday > int(g.GAME_DURATION_DAYS) - 3:
		return false
	if not g.is_routine_workday(workday) or not g.is_routine_workday(workday + 1):
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
	if g.outpatient_closed():
		return false
	var clock := int(g.current_absolute_clock())
	if clock < TIME_START or clock > TIME_END:
		return false
	var day := int(g.day_number())
	if not calendar_safe_for_workday(g, day):
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
	g.meet_staff(EMIKO)
	g._complete_character_event_for_test(ASUKA_INTRO_EVENT_ID, 1)
	g._complete_character_event_for_test(EMIKO_INTRO_EVENT_ID, 1)
	g._complete_character_event_for_test(RIVAL_REFERRAL_EVENT_ID, 2)
	g.meet_staff(ACTOR)
	var relation: Dictionary = g.relation_for(ACTOR)
	relation.met = true
	relation.level = 4
	relation.familiarity = maxi(int(relation.get("familiarity", 0)), 75)
	for benefit in ["unlock_artoria_surgical_team", "unlock_intimacy_events"]:
		if not relation.unlocked_benefits.has(benefit):
			relation.unlocked_benefits.append(benefit)
	g.set_test_player_attribute("leadership", maxi(int(g.player_attributes().get("leadership", 0)), 90))
	g.set_test_player_attribute("skill", maxi(int(g.player_attributes().get("skill", 0)), 80))
	g._complete_character_event_for_test(INTRO_EVENT_ID, 2)
	var lv1_day := 4
	g._complete_character_event_for_test(LV1_EVENT_ID, lv1_day)
	if not relation.rank_history.has(LV1_EVENT_ID):
		relation.rank_history.append(LV1_EVENT_ID)
	var lv2_day := 7
	g._complete_character_event_for_test(LV2_EVENT_ID, lv2_day)
	if not relation.rank_history.has(LV2_EVENT_ID):
		relation.rank_history.append(LV2_EVENT_ID)
	g.set_story_flag("artoria_lv2_complete", true)
	g.set_story_flag("artoria_major_liver_resection_teaching_complete", true)
	g.unlock_procedure("surgery_open_major_liver_resection")
	var lv3_day := 10
	g._complete_character_event_for_test(LV3_EVENT_ID, lv3_day)
	if not relation.rank_history.has(LV3_EVENT_ID):
		relation.rank_history.append(LV3_EVENT_ID)
	g.set_story_flag("artoria_lv3_complete", true)
	var lv4_day := 13
	g._complete_character_event_for_test(LV4_EVENT_ID, lv4_day)
	if not relation.rank_history.has(LV4_EVENT_ID):
		relation.rank_history.append(LV4_EVENT_ID)
	g.set_story_flag("artoria_lv4_complete", true)
	g.set_story_flag("staff_as_patient_program_authorized", true)
	var target_day := maxi(base_day, lv4_day + 3)
	while target_day <= int(g.GAME_DURATION_DAYS) - 3 and not calendar_safe_for_workday(g, target_day):
		target_day += 1
	return target_day
