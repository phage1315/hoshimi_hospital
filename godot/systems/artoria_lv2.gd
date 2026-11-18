extends RefCounted
## Domain helper for Artoria Pendragon (`doc_artoria`) Relationship Lv2:
## 《留下来的部分》 (What Remains / V1.0).
##
## Contract summary:
## - Routine Mon–Fri workday `after_work` milestone (`artoria_lv2_what_remains`),
##   never Saturday/Sunday, never when `workday + 1` is a closed hospital day,
##   never during the final two campaign days (`Day 364–365`, Anji departure
##   window), and never when an unresolved inpatient or next-day Advanced
##   Referral `operation_day`/`review_day` booking exists.
## - Requires `artoria_lv1_right_position`, `level == 1`, `familiarity >= 25`,
##   `leadership >= 70`, and 3-day milestone cooldown (`relationship_rank_gate_met("doc_artoria", 2)`).
## - Atomic completion at `@end`:
##   - Promotes `doc_artoria` `Lv1 -> Lv2`
##   - Sets `artoria_lv2_complete = true` and `artoria_major_liver_resection_teaching_complete = true`
##   - Unlocks ordinary-pool procedure `surgery_open_major_liver_resection` (`template_liver_resection`)
##   - Advances story clock to next day `14:00` (`completion_day_offset = 1`, `completion_absolute_clock = 840`)
##   - Does NOT modify `nurse_yui` / `nurse_ange` relationship/familiarity or Chief-of-Surgery yield flags.

const ACTOR := "doc_artoria"
const EVENT_ID := "artoria_lv2_what_remains"
const ASUKA_INTRO_EVENT_ID := "intro_doc_asuka_director_office"
const EMIKO_INTRO_EVENT_ID := "emiko_intro_rumored_hands"
const RIVAL_REFERRAL_EVENT_ID := "asuka_mentions_artoria_rival"
const INTRO_EVENT_ID := "intro_doc_artoria_deputy_office"
const LV1_EVENT_ID := "artoria_lv1_right_position"
const FLAG_COMPLETE := "artoria_lv2_complete"
const FLAG_LIVER_TEACHING := "artoria_major_liver_resection_teaching_complete"
const LIVER_PROCEDURE_ID := "surgery_open_major_liver_resection"

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
	# Exclude the final two campaign days (Day 364–365) so `workday <= 363`
	# and next-day surgery (`workday + 1 <= 364`) never enters Anji's departure window.
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
	if not g.staff_is_met(ACTOR) or g.relationship_level(ACTOR) != 1:
		return false
	if not g.character_event_done(LV1_EVENT_ID):
		return false
	return g.relationship_rank_gate_met(ACTOR, 2)

static func unlock_liver_resection(g: RefCounted) -> void:
	if g == null:
		return
	g.set_story_flag(FLAG_LIVER_TEACHING, true)
	g.unlock_procedure(LIVER_PROCEDURE_ID)

static func completed(g: RefCounted) -> bool:
	if g == null or not g.character_event_done(EVENT_ID) or g.relationship_level(ACTOR) != 2:
		return false
	unlock_liver_resection(g)
	g.set_story_flag(FLAG_COMPLETE, true)
	return true

static func prepare_test_save(g: RefCounted, _event_id: String, base_day: int) -> int:
	g.meet_staff("doc_asuka")
	g.meet_staff("doc_emiko")
	g._complete_character_event_for_test(ASUKA_INTRO_EVENT_ID, 1)
	g._complete_character_event_for_test(EMIKO_INTRO_EVENT_ID, 1)
	g._complete_character_event_for_test(RIVAL_REFERRAL_EVENT_ID, 2)
	g.meet_staff(ACTOR)
	var relation: Dictionary = g.relation_for(ACTOR)
	relation.met = true
	relation.level = 1
	relation.familiarity = maxi(int(relation.get("familiarity", 0)), 25)
	if not relation.unlocked_benefits.has("unlock_artoria_surgical_team"):
		relation.unlocked_benefits.append("unlock_artoria_surgical_team")
	g.set_test_player_attribute("leadership", maxi(int(g.player_attributes().get("leadership", 0)), 70))
	g._complete_character_event_for_test(INTRO_EVENT_ID, 2)
	var lv1_day := 5
	g._complete_character_event_for_test(LV1_EVENT_ID, lv1_day)
	if not relation.rank_history.has(LV1_EVENT_ID):
		relation.rank_history.append(LV1_EVENT_ID)
	var target_day := maxi(base_day, lv1_day + 3)
	while target_day <= int(g.GAME_DURATION_DAYS) - 2 and not calendar_safe_for_workday(g, target_day):
		target_day += 1
	return target_day
