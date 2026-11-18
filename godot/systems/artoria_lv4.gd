extends RefCounted
## Domain helper for Artoria Pendragon (`doc_artoria`) Relationship Lv4:
## 《只是阿尔托莉雅》 (Just Artoria / V1.1).
##
## Contract summary:
## - Sunday invitation milestone (`artoria_lv4_just_artoria`, `trigger_mode = "sunday"`,
##   `consumes_sunday = true`, `locks_saving = true`), blocked on non-Sundays,
##   when Sunday's activity is already spent, during the final two campaign days
##   (`Day 364–365`, `max_day = 363`), or when another active clinical/narrative
##   session is in progress.
## - Requires `artoria_lv3_not_a_solo_operation`, `level == 3`, `familiarity >= 55`,
##   `leadership >= 85`, and 3-day milestone cooldown (`relationship_rank_gate_met("doc_artoria", 4)`),
##   with zero month gate and zero `Surgery`, `Charm`, `Reputation`, or date-count gate.
## - Scene 5.1 ends at `ar4_s5_1_26` (`action = "launch_artoria_lv4_h"`), invoking
##   `FreeHRegistry.load_bundle("doc_artoria", locale)` at `"home"` when ready or
##   falling back to the save-locked H Runner placeholder (`screen = "artoria_lv4_h_placeholder"`),
##   and resuming Scene 5.2 exclusive night aftercare -> Scene 6 next-morning breakfast
##   WITHOUT settling Lv4 early.
## - Atomic settlement ONLY after Scene 6.2 (`ar4_s6_2m_13` -> `@end`):
##   - Promotes `doc_artoria` `Lv3 -> Lv4` (`benefit_id = "unlock_intimacy_events"`),
##     sets `artoria_lv4_complete = true`, and advances clock once to Monday `09:00`
##     (`completion_day_offset = 1`, `completion_absolute_clock = 540`).
##   - Leaves guest patients (`藤村大河`, `爱丽丝菲尔`) out of random pools/queues and
##     never alters Chief-of-Surgery competition or Maiya post-Lv5 flags.

const ACTOR := "doc_artoria"
const EMIKO := "doc_emiko"
const EVENT_ID := "artoria_lv4_just_artoria"
const ASUKA_INTRO_EVENT_ID := "intro_doc_asuka_director_office"
const EMIKO_INTRO_EVENT_ID := "emiko_intro_rumored_hands"
const RIVAL_REFERRAL_EVENT_ID := "asuka_mentions_artoria_rival"
const INTRO_EVENT_ID := "intro_doc_artoria_deputy_office"
const LV1_EVENT_ID := "artoria_lv1_right_position"
const LV2_EVENT_ID := "artoria_lv2_what_remains"
const LV3_EVENT_ID := "artoria_lv3_not_a_solo_operation"
const FLAG_COMPLETE := "artoria_lv4_complete"
const ACTION_H_PLACEHOLDER := "launch_artoria_lv4_h"
const H_HANDOFF_NODE_ID := "ar4_s5_1_26"
const HOME_LOCATION_ID := "home"

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

static func calendar_safe_for_sunday(g: RefCounted, day: int) -> bool:
	if g == null or day < 1 or day > int(g.GAME_DURATION_DAYS) - 2:
		return false
	return int(g.calendar_date(day).weekday_index) == 6

static func eligible(g: RefCounted, id: String) -> bool:
	if not owns(id) or not safe(g):
		return false
	var day := int(g.day_number())
	if not g.is_sunday() or g.sunday_activity_done() or not calendar_safe_for_sunday(g, day):
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
	g.meet_staff(EMIKO)
	g._complete_character_event_for_test(ASUKA_INTRO_EVENT_ID, 1)
	g._complete_character_event_for_test(EMIKO_INTRO_EVENT_ID, 1)
	g._complete_character_event_for_test(RIVAL_REFERRAL_EVENT_ID, 2)
	g.meet_staff(ACTOR)
	var relation: Dictionary = g.relation_for(ACTOR)
	relation.met = true
	relation.level = 3
	relation.familiarity = maxi(int(relation.get("familiarity", 0)), 55)
	if not relation.unlocked_benefits.has("unlock_artoria_surgical_team"):
		relation.unlocked_benefits.append("unlock_artoria_surgical_team")
	g.set_test_player_attribute("leadership", maxi(int(g.player_attributes().get("leadership", 0)), 85))
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
	var target_day := maxi(base_day, lv3_day + 3)
	while target_day <= int(g.GAME_DURATION_DAYS) - 2 and not calendar_safe_for_sunday(g, target_day):
		target_day += 1
	return target_day
