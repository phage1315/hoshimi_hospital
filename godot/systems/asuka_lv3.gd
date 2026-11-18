extends RefCounted
## Domain helper for Asuka Shiromiya (`doc_asuka`) Relationship Lv3:
## 《本院长不接受反驳哦》 (No Objections Allowed from This Director).
##
## Contract summary:
## - Sunday-only milestone (`asuka_lv3_no_objections`), triggered when the
##   player invites `doc_asuka` on Sunday (`trigger_mode == "sunday"`,
##   `consumes_sunday == true`), never via weekday `director_office`.
## - Requires `asuka_lv2_right_person_right_gown`, `level == 2`,
##   `familiarity >= 40`, `charm >= 50`, and the default 3-day milestone
##   cooldown. No month lock and no dependency on `maki_lv0_onboarding`.
## - Automatically branches Scene A opening between `al3_a1_001` (first-ever
##   Sunday date with Asuka) and `al3_a2_001` (at least one prior ordinary
##   Sunday date with Asuka) using persisted v37 boundary facts
##   (`completed_sunday_dates` / `sunday_history`), with zero new save fields
##   and zero inner performance state persisted.
## - On `@end`, atomically advances `doc_asuka` `Lv2 -> Lv3`, sets
##   `asuka_lv3_complete`, and consumes the Sunday via non-generic activity ID
##   `"asuka_lv3_date"` so ordinary date Familiarity/Charm/+1-date-counter
##   rewards are not double-granted, advancing cleanly to Monday `09:00`.

const ACTOR := "doc_asuka"
const EVENT_ID := "asuka_lv3_no_objections"
const INTRO_EVENT_ID := "intro_doc_asuka_director_office"
const LV1_PREOP_EVENT_ID := "asuka_lv1_director_surgeon_preop"
const LV1_POSTOP_EVENT_ID := "asuka_lv1_director_surgeon_postop"
const LV2_EVENT_ID := "asuka_lv2_right_person_right_gown"
const FLAG_COMPLETE := "asuka_lv3_complete"
const SUNDAY_ACTIVITY_ID := "asuka_lv3_date"
const SUNDAY_LOCATION_ID := "cafe"
const OPENING_FIRST_DATE := "al3_a1_001"
const OPENING_PRIOR_DATE := "al3_a2_001"

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
		or not g.pending_departure_context().is_empty()
		or g.active_adult_intimacy != null
	)

static func eligible(g: RefCounted, id: String) -> bool:
	if not owns(id) or not safe(g):
		return false
	if not g.is_sunday() or g.sunday_activity_done():
		return false
	if not g.staff_is_met(ACTOR) or g.relationship_level(ACTOR) != 2:
		return false
	if not g.character_event_done(LV2_EVENT_ID):
		return false
	return g.relationship_rank_gate_met(ACTOR, 3)

static func has_prior_regular_sunday_date(g: RefCounted) -> bool:
	if g == null:
		return false
	if int(g.character_progress_counter(ACTOR, "completed_sunday_dates")) > 0:
		return true
	for record in g.sunday_history:
		if record is Dictionary and str(record.get("activity_id", "")) == "date" and str(record.get("actor_id", "")) == ACTOR:
			return true
	return false

static func opening_node(g: RefCounted, definition: Dictionary) -> String:
	var variants: Dictionary = definition.get("opening_variants", {})
	if has_prior_regular_sunday_date(g):
		return str(variants.get("prior_sunday_date", OPENING_PRIOR_DATE))
	return str(variants.get("first_sunday_date", definition.get("start", OPENING_FIRST_DATE)))

static func completed(g: RefCounted) -> bool:
	if g == null or not g.character_event_done(EVENT_ID) or g.relationship_level(ACTOR) != 3:
		return false
	g.set_story_flag(FLAG_COMPLETE, true)
	# Record a single Sunday milestone ledger entry (`activity_id != "date"`) so
	# generic ordinary-date Familiarity, Charm +1, and `completed_sunday_dates`
	# are not double-awarded, and advance cleanly to Monday 09:00.
	return g.complete_sunday_activity(SUNDAY_ACTIVITY_ID, ACTOR, SUNDAY_LOCATION_ID)

static func prepare_test_save(g: RefCounted, _event_id: String, base_day: int) -> int:
	g.meet_staff(ACTOR)
	var relation: Dictionary = g.relation_for(ACTOR)
	relation.met = true
	relation.level = 2
	relation.familiarity = maxi(int(relation.get("familiarity", 0)), 40)
	g.set_test_player_attribute("charm", maxi(int(g.player_attributes().get("charm", 0)), 50))
	g._complete_character_event_for_test("asuka_scrub_sink_encounter", 1)
	g._complete_character_event_for_test("asuka_adjacent_operation_reveal", 1)
	g._complete_character_event_for_test(INTRO_EVENT_ID, 2)
	var lv1_day := 3
	g._complete_character_event_for_test(LV1_PREOP_EVENT_ID, lv1_day)
	g._complete_character_event_for_test(LV1_POSTOP_EVENT_ID, lv1_day)
	if not relation.rank_history.has(LV1_POSTOP_EVENT_ID):
		relation.rank_history.append(LV1_POSTOP_EVENT_ID)
	g.set_story_flag("asuka_lv1_complete", true)
	var lv2_day := 8
	g._complete_character_event_for_test(LV2_EVENT_ID, lv2_day)
	if not relation.rank_history.has(LV2_EVENT_ID):
		relation.rank_history.append(LV2_EVENT_ID)
	g.set_story_flag("asuka_lv2_complete", true)
	g.set_story_flag("maki_aizawa_offer_accepted", true)
	var target_day := maxi(base_day, lv2_day + 3)
	while target_day < int(g.GAME_DURATION_DAYS) and str(g.calendar_date(target_day).weekday_id) != "sun":
		target_day += 1
	return target_day
