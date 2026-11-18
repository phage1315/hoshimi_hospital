extends RefCounted
## Domain helper for Mido Emiko (`doc_emiko`) Relationship Lv4:
## 《御堂江美子的秘密》 (Emiko Mido's Secret / V1.1).
##
## Contract summary:
## - Weekday Mon–Fri `after_work` milestone (`emiko_lv4_emikos_secret`), blocked
##   on the final two campaign days (`Day 364–365`, when non-ending events do not
##   trigger and Anji Tonegawa departs), when the next calendar day is closed
##   (Sunday/holiday), when reserved by an Advanced Referral review/operation,
##   or when an inpatient awaits surgery.
## - Requires `emiko_lv3_today_i_lead`, `level == 3`, `familiarity >= 55`,
##   `presence >= 30`, and 3-day milestone cooldown (`Surgery >= 90` belongs
##   exclusively to Lv5 and is never required here).
## - Scene 2 montage ("brief two-to-three-day distance") is strictly internal
##   to the atomic event session: never freezes Emiko's regular surgical team
##   eligibility and never skips multi-day global calendar schedules.
## - Scene 6.1 ends at `em4_s6_1_24` (`action = "launch_emiko_lv4_h"`), opening
##   the save-locked H Runner placeholder (`screen = "emiko_lv4_h_placeholder"`)
##   in `operating_room` before resuming Scene 6.2 exclusive aftercare.
## - Settlement (`Lv3 -> Lv4`, `unlock_intimacy_events`, `emiko_lv4_complete`)
##   happens atomically ONLY after Scene 6.2 (`em4_s6_2_34` -> `@end`), without
##   setting any Chief-of-Surgery yield flag.

const ACTOR := "doc_emiko"
const ARTORIA := "doc_artoria"
const EVENT_ID := "emiko_lv4_emikos_secret"
const INTRO_EVENT_ID := "emiko_intro_rumored_hands"
const LV1_EVENT_ID := "emiko_lv1_first_operation"
const LV2_EVENT_ID := "emiko_lv2_follow_my_lead"
const LV3_EVENT_ID := "emiko_lv3_today_i_lead"
const ARTORIA_INTRO_EVENT_ID := "intro_doc_artoria_deputy_office"
const FLAG_CABG_TEACHING := "emiko_cabg_teaching_complete"
const FLAG_COMPLETE := "emiko_lv4_complete"
const ACTION_H_PLACEHOLDER := "launch_emiko_lv4_h"
const H_HANDOFF_NODE_ID := "em4_s6_1_24"

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
	if g == null or workday < 1 or workday > int(g.GAME_DURATION_DAYS) - 2:
		return false
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
	if not g.staff_is_met(ACTOR) or g.relationship_level(ACTOR) != 3:
		return false
	if not g.character_event_done(LV3_EVENT_ID):
		return false
	return g.relationship_rank_gate_met(ACTOR, 4)

static func completed(g: RefCounted) -> bool:
	if g == null or not g.character_event_done(EVENT_ID) or g.relationship_level(ACTOR) != 4:
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
	relation.level = 3
	relation.familiarity = maxi(int(relation.get("familiarity", 0)), 55)
	if not relation.unlocked_benefits.has("unlock_emiko_surgical_team"):
		relation.unlocked_benefits.append("unlock_emiko_surgical_team")
	g.set_test_player_attribute("skill", maxi(int(g.player_attributes().get("skill", 0)), 80))
	g.set_test_player_attribute("presence", maxi(int(g.player_attributes().get("presence", 0)), 30))
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
	var lv3_day := 11
	g._complete_character_event_for_test(LV3_EVENT_ID, lv3_day)
	if not relation.rank_history.has(LV3_EVENT_ID):
		relation.rank_history.append(LV3_EVENT_ID)
	g.set_story_flag("emiko_lv3_complete", true)
	g.set_story_flag(FLAG_CABG_TEACHING, true)
	g.unlock_procedure("surgery_cabg")
	var target_day := maxi(base_day, lv3_day + 3)
	while target_day <= int(g.GAME_DURATION_DAYS) - 2 and not calendar_safe_for_workday(g, target_day):
		target_day += 1
	return target_day
