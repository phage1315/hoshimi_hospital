extends RefCounted
## Domain helper for Asuka Shiromiya (`doc_asuka`) Relationship Lv2:
## 《合适的人，合适的手术袍》 (The Right Person, the Right Gown), and the
## cross-event deferred onboarding contract for Maki Aizawa (`doc_maki`).
##
## Contract summary:
## - Single-session three-scene VN (`asuka_lv2_right_person_right_gown`) at
##   `director_office` during open hospital afternoon hours (`12:00..16:00`,
##   `720..960`, `125` settled minutes).
## - Atomically promotes `doc_asuka` Lv1 -> Lv2 and sets `asuka_lv2_complete`
##   and `maki_aizawa_offer_accepted`.
## - Records Maki's interview day via `character_events[EVENT_ID].completed_day`
##   (persisted through v37 `BoundarySave` `character_completions` with zero
##   inner event/session fields).
## - Strictly keeps `doc_maki` out of `known_staff_ids()`, routine/advanced
##   surgical assistant pools, Sunday dates, and hospital map presence until a
##   future standalone `maki_lv0_onboarding` event (~1 month after interview)
##   is completed and `doc_maki` is formally met.

const ACTOR := "doc_asuka"
const MAKI_ACTOR := "doc_maki"
const EVENT_ID := "asuka_lv2_right_person_right_gown"
const INTRO_EVENT_ID := "intro_doc_asuka_director_office"
const LV1_PREOP_EVENT_ID := "asuka_lv1_director_surgeon_preop"
const LV1_POSTOP_EVENT_ID := "asuka_lv1_director_surgeon_postop"
const MAKI_ONBOARDING_EVENT_ID := "maki_lv0_onboarding"
const FLAG_COMPLETE := "asuka_lv2_complete"
const FLAG_MAKI_OFFER := "maki_aizawa_offer_accepted"
const ONBOARDING_DELAY_MONTHS := 1
const ONBOARDING_MIN_DAYS := 30

const ChihayaMizuhoReturn = preload("res://godot/systems/chihaya_mizuho_return.gd")

static func owns(id: String) -> bool:
	return id == EVENT_ID

static func eligible(g: RefCounted, id: String) -> bool:
	if not owns(id) or g == null:
		return false
	if g.is_hospital_closed_day():
		return false
	if g.active_surgery_in_progress() or not g.active_special_event_id.is_empty() or g.special_event_in_progress() or not g.active_preop_id.is_empty() or g.active_encounter_in_progress():
		return false
	return true

static func offer_accepted(g: RefCounted) -> bool:
	if g == null or not g.character_event_done(EVENT_ID):
		return false
	return g.story_flag(FLAG_MAKI_OFFER)

static func interview_day(g: RefCounted) -> int:
	if g == null or not g.character_event_done(EVENT_ID):
		return -1
	var completed = g.character_events.get(EVENT_ID)
	if completed == null:
		return -1
	var day := int(completed.completed_day)
	return day if day > 0 else -1

static func onboarding_earliest_day(g: RefCounted) -> int:
	var base_day := interview_day(g)
	if base_day < 1:
		return -1
	var month_day := ChihayaMizuhoReturn.add_months(base_day, ONBOARDING_DELAY_MONTHS)
	var min_day := base_day + ONBOARDING_MIN_DAYS
	var earliest := maxi(month_day, min_day) if month_day > 0 else min_day
	return earliest if earliest <= int(g.GAME_DURATION_DAYS) else -1

static func onboarding_ready_workday(g: RefCounted) -> int:
	var candidate := onboarding_earliest_day(g)
	if candidate < 1:
		return -1
	while candidate <= int(g.GAME_DURATION_DAYS) and g.is_hospital_closed_day(candidate):
		candidate += 1
	return candidate if candidate <= int(g.GAME_DURATION_DAYS) else -1

static func is_maki_onboarded(g: RefCounted) -> bool:
	if g == null:
		return false
	return g.staff_is_met(MAKI_ACTOR)

static func ready_for_onboarding_event(g: RefCounted, for_day: int = -1) -> bool:
	if not offer_accepted(g) or is_maki_onboarded(g):
		return false
	if g.character_event_done(MAKI_ONBOARDING_EVENT_ID) or g.special_event_done(MAKI_ONBOARDING_EVENT_ID):
		return false
	var earliest := onboarding_earliest_day(g)
	if earliest < 1:
		return false
	var check_day := int(g.day_number()) if for_day < 1 else for_day
	if check_day < earliest or g.is_hospital_closed_day(check_day):
		return false
	return true

static func prepare_test_save(g: RefCounted, _event_id: String, base_day: int) -> int:
	g.meet_staff(ACTOR)
	var relation: Dictionary = g.relation_for(ACTOR)
	relation.met = true
	relation.level = 1
	relation.familiarity = maxi(int(relation.get("familiarity", 0)), 25)
	g.set_test_player_attribute("charm", maxi(int(g.player_attributes().get("charm", 0)), 25))
	g._complete_character_event_for_test("asuka_scrub_sink_encounter", 1)
	g._complete_character_event_for_test("asuka_adjacent_operation_reveal", 1)
	g._complete_character_event_for_test(INTRO_EVENT_ID, 2)
	var lv1_day := 3
	g._complete_character_event_for_test(LV1_PREOP_EVENT_ID, lv1_day)
	g._complete_character_event_for_test(LV1_POSTOP_EVENT_ID, lv1_day)
	if not relation.rank_history.has(LV1_POSTOP_EVENT_ID):
		relation.rank_history.append(LV1_POSTOP_EVENT_ID)
	g.set_story_flag("asuka_lv1_complete", true)
	var target_day := maxi(base_day, lv1_day + 3)
	while target_day < g.GAME_DURATION_DAYS and g.is_hospital_closed_day(target_day):
		target_day += 1
	return target_day
