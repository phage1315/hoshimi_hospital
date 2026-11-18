extends RefCounted
## Domain helper for Maki Aizawa (`doc_maki`) Relationship Lv0 standalone
## onboarding / formal acquaintance event:
## 《排班表上的名字》 (A Name on the OR Roster, ID: `maki_lv0_onboarding`).
##
## Contract summary (`MK0-L01`..`MK0-L09`):
## - Triggers automatically at `day_start` (`09:00`, `540`) on the first open
##   workday at least ~1 month (`maxi(add_months(interview_day, 1), interview_day + 30)`)
##   after completing Asuka Lv2 (`asuka_lv2_right_person_right_gown` +
##   `maki_aizawa_offer_accepted`), with zero extra Charm/Surgery/Reputation gates.
## - Never interrupts an active clinical visit, inpatient surgery/preop,
##   special event, or departure sequence; waits cleanly for the next free open
##   workday morning.
## - Scene C is 100% pure fixed VN (`operating_room`), never invoking Surgery
##   Runner, intraoperative crisis RNG, or routine surgery counters.
## - ONLY upon reaching `@end` does `maki_lv0_onboarding` mark itself completed
##   and formally meet `doc_maki` (`staff_is_met("doc_maki") == true`),
##   unlocking her Lounge fixed presence, Rooftop random presence, Sunday date
##   eligibility (`familiarity >= 10`), and routine/advanced surgical assistant
##   pools (`assistant_surgeon` / `first_assistant` / `second_assistant`, never
##   `primary_surgeon`).

const ACTOR := "doc_maki"
const EVENT_ID := "maki_lv0_onboarding"
const FLAG_COMPLETE := "maki_lv0_complete"
const FLAG_ONBOARDED := "maki_aizawa_onboarded"

const AsukaLv2 = preload("res://godot/systems/asuka_lv2.gd")

static func owns(id: String) -> bool:
	return id == EVENT_ID

static func eligible(g: RefCounted, id: String) -> bool:
	if not owns(id) or g == null:
		return false
	if not AsukaLv2.ready_for_onboarding_event(g):
		return false
	if g.active_surgery_in_progress() or not g.active_special_event_id.is_empty() or g.special_event_in_progress() or not g.active_preop_id.is_empty() or g.active_encounter_in_progress():
		return false
	if not g.active_id.is_empty() or not g.pending_departure_context().is_empty() or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty() or not g.active_micro_event_id.is_empty():
		return false
	if not g.active_character_event_id.is_empty() and g.active_character_event_id != EVENT_ID:
		return false
	return true

static func prepare_test_save(g: RefCounted, _event_id: String, base_day: int) -> int:
	var interview_day := AsukaLv2.prepare_test_save(g, AsukaLv2.EVENT_ID, 6)
	g._complete_character_event_for_test(AsukaLv2.EVENT_ID, interview_day)
	var asuka_relation: Dictionary = g.relation_for(AsukaLv2.ACTOR)
	asuka_relation.met = true
	asuka_relation.level = maxi(int(asuka_relation.get("level", 0)), 2)
	if not asuka_relation.rank_history.has(AsukaLv2.EVENT_ID):
		asuka_relation.rank_history.append(AsukaLv2.EVENT_ID)
	g.set_story_flag(AsukaLv2.FLAG_COMPLETE, true)
	g.set_story_flag(AsukaLv2.FLAG_MAKI_OFFER, true)
	var maki_relation: Dictionary = g.relation_for(ACTOR)
	maki_relation.met = false
	maki_relation.level = 0
	var ready_day := AsukaLv2.onboarding_ready_workday(g)
	var target_day := maxi(base_day, ready_day if ready_day > 0 else interview_day + AsukaLv2.ONBOARDING_MIN_DAYS)
	while target_day < g.GAME_DURATION_DAYS and g.is_hospital_closed_day(target_day):
		target_day += 1
	return target_day
