extends RefCounted
## Domain helper for Artoria Pendragon (`doc_artoria`) Relationship Lv3:
## 《不是一个人的手术》 (Not a One-Person Operation / V1.1).
##
## Contract summary:
## - Routine Mon–Fri workday `after_work` milestone (`artoria_lv3_not_a_solo_operation`),
##   blocked on Saturday/Sunday, when `workday + 1` is a closed hospital day,
##   during the final two campaign days (`Day 364–365`, Anji departure window),
##   or when an unresolved inpatient or next-day Advanced Referral booking exists.
## - Requires `artoria_lv2_what_remains`, `level == 2`, `familiarity >= 40`,
##   `leadership >= 80`, and 3-day milestone cooldown (`relationship_rank_gate_met("doc_artoria", 3)`).
##   Never requires `Surgery`, Emiko Lv1, or Advanced Referral unlock.
## - Resolves two read-only cross-route continuity checks in Scene 1 without adding
##   any persisted state:
##   1) `ar3_s1_03` -> `ar3_s1_em3a_01` when Emiko Lv3 (`emiko_lv3_today_i_lead`) is done,
##      otherwise default `ar3_s1_em3b_01`.
##   2) `ar3_choice_c1` (`choice_ar3_c1_a`) -> `ar3_c1a_1_01` when Emiko Lv1 (`emiko_lv1_first_operation`)
##      is done, otherwise default `ar3_c1a_2_01`.
## - Atomic completion at `@end`:
##   - Promotes `doc_artoria` `Lv2 -> Lv3`, sets `artoria_lv3_complete = true`,
##     and advances story clock to next day `15:00` (`completion_day_offset = 1`, `completion_absolute_clock = 900`).
##   - Does NOT touch `nurse_hiroko` / `nurse_moe` / `nurse_ange` relationship/familiarity,
##     does NOT unlock any new procedure, and does NOT alter Chief-of-Surgery competition flags.

const ACTOR := "doc_artoria"
const EMIKO := "doc_emiko"
const EVENT_ID := "artoria_lv3_not_a_solo_operation"
const ASUKA_INTRO_EVENT_ID := "intro_doc_asuka_director_office"
const EMIKO_INTRO_EVENT_ID := "emiko_intro_rumored_hands"
const EMIKO_LV1_EVENT_ID := "emiko_lv1_first_operation"
const EMIKO_LV3_EVENT_ID := "emiko_lv3_today_i_lead"
const RIVAL_REFERRAL_EVENT_ID := "asuka_mentions_artoria_rival"
const INTRO_EVENT_ID := "intro_doc_artoria_deputy_office"
const LV1_EVENT_ID := "artoria_lv1_right_position"
const LV2_EVENT_ID := "artoria_lv2_what_remains"
const FLAG_COMPLETE := "artoria_lv3_complete"

const S1_LOUNGE_GATE_NODE_ID := "ar3_s1_03"
const S1_EM3A_START := "ar3_s1_em3a_01"
const S1_EM3B_START := "ar3_s1_em3b_01"
const CHOICE1_NODE_ID := "ar3_choice_c1"
const CHOICE1_OPT_A_ID := "choice_ar3_c1_a"
const C1A_1_START := "ar3_c1a_1_01"
const C1A_2_START := "ar3_c1a_2_01"

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
	if not g.staff_is_met(ACTOR) or g.relationship_level(ACTOR) != 2:
		return false
	if not g.character_event_done(LV2_EVENT_ID):
		return false
	return g.relationship_rank_gate_met(ACTOR, 3)

static func emiko_lv3_done(g: RefCounted) -> bool:
	if g == null:
		return false
	return g.character_event_done(EMIKO_LV3_EVENT_ID) or int(g.relationship_level(EMIKO)) >= 3 or bool(g.story_flag("emiko_lv3_complete"))

static func emiko_lv1_done(g: RefCounted) -> bool:
	if g == null:
		return false
	return g.character_event_done(EMIKO_LV1_EVENT_ID) or int(g.relationship_level(EMIKO)) >= 1 or bool(g.story_flag("emiko_lv1_complete"))

static func cast_definition(g: RefCounted, source: Dictionary) -> Dictionary:
	var definition: Dictionary = source.duplicate(true)
	var has_emiko_lv3 := emiko_lv3_done(g)
	var has_emiko_lv1 := emiko_lv1_done(g)
	for node in definition.get("nodes", []):
		if not node is Dictionary:
			continue
		var nid := str(node.get("id", ""))
		if nid == S1_LOUNGE_GATE_NODE_ID and node.get("choices", []) is Array and not node.choices.is_empty():
			node.choices[0]["next"] = S1_EM3A_START if has_emiko_lv3 else S1_EM3B_START
		elif nid == CHOICE1_NODE_ID and node.get("choices", []) is Array:
			for ch in node.choices:
				if ch is Dictionary and str(ch.get("id", "")) == CHOICE1_OPT_A_ID:
					ch["next"] = C1A_1_START if has_emiko_lv1 else C1A_2_START
	return definition

static func completed(g: RefCounted) -> bool:
	if g == null or not g.character_event_done(EVENT_ID) or g.relationship_level(ACTOR) != 3:
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
	relation.level = 2
	relation.familiarity = maxi(int(relation.get("familiarity", 0)), 40)
	if not relation.unlocked_benefits.has("unlock_artoria_surgical_team"):
		relation.unlocked_benefits.append("unlock_artoria_surgical_team")
	g.set_test_player_attribute("leadership", maxi(int(g.player_attributes().get("leadership", 0)), 80))
	g._complete_character_event_for_test(INTRO_EVENT_ID, 2)
	var lv1_day := 5
	g._complete_character_event_for_test(LV1_EVENT_ID, lv1_day)
	if not relation.rank_history.has(LV1_EVENT_ID):
		relation.rank_history.append(LV1_EVENT_ID)
	var lv2_day := 8
	g._complete_character_event_for_test(LV2_EVENT_ID, lv2_day)
	if not relation.rank_history.has(LV2_EVENT_ID):
		relation.rank_history.append(LV2_EVENT_ID)
	g.set_story_flag("artoria_lv2_complete", true)
	g.set_story_flag("artoria_major_liver_resection_teaching_complete", true)
	g.unlock_procedure("surgery_open_major_liver_resection")
	var target_day := maxi(base_day, lv2_day + 3)
	while target_day <= int(g.GAME_DURATION_DAYS) - 2 and not calendar_safe_for_workday(g, target_day):
		target_day += 1
	return target_day
