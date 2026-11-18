extends RefCounted
## Domain helper for Asuka Shiromiya (`doc_asuka`) Relationship Lv1:
## 《院长也是外科医生》 (The Director Is Also a Surgeon).
##
## Three-stage routine-surgery-coupled structure:
## - Scene 1 (`asuka_lv1_director_surgeon_preop`): Pre-op VN at `scrub_area` after
##   changing scrubs and scrubbing hands when `doc_asuka` is selected as `assistant_surgeon`
##   on a routine surgery. Marks the live `PreopSession` with `asuka_lv1_active`.
## - Scene 2 (Routine Surgery Runner): Suppresses intraoperative physiologic crises
##   (`disable_intraop_crisis = true`) and supplies 3 light first-assistant lines.
## - Scene 3 (`asuka_lv1_director_surgeon_postop`): Post-op VN at `or_entrance`
##   after routine surgery settlement, atomically promoting `doc_asuka` Lv0 -> Lv1.
##
## Save-boundary contract:
## - Only event-level completion facts and relationship rank-up settle at safe boundaries.
## - `asuka_lv1_active` and `asuka_lv1_postop_opportunity` are strictly in-memory
##   session state and are never persisted to `BoundarySave`.
## - If the routine surgery is aborted before Scene 3 completes, Scene 1 completion
##   is rolled back so the player can re-trigger the full Lv1 event on a future
##   routine surgery with `doc_asuka` as first assistant.

const ACTOR := "doc_asuka"
const INTRO_EVENT_ID := "intro_doc_asuka_director_office"
const PREOP_EVENT_ID := "asuka_lv1_director_surgeon_preop"
const POSTOP_EVENT_ID := "asuka_lv1_director_surgeon_postop"
const ACTIVE_FLAG := "asuka_lv1_active"
const PREOP_FLAG := "asuka_lv1_preop_seen"
const DONE_FLAG := "asuka_lv1_complete"

const INTRAOP_LINES := {
	"01_exposure": {
		"zh_CN": "「拉钩角度我帮你稳在这里，深面的解剖间隙很清楚，放心往下走吧。」",
		"en": "“I'll hold the retractor angle steady right here for you—the deep anatomical plane is nice and clear, so go ahead with confidence.”",
	},
	"02_hemostasis": {
		"zh_CN": "「这边的渗血点我先用纱布帮你压住了。需要电凝还是结扎，随时开口。」",
		"en": "“I've pressed this oozing point with gauze for you first. Just say the word whenever you want electrocautery or a tie.”",
	},
	"03_closure": {
		"zh_CN": "「切口对合得很漂亮呢。收尾剪线交给我，今天配合得很顺手哦。」",
		"en": "“The incision edges are coming together beautifully. Leave cutting the closing sutures to me—our teamwork felt really smooth today.”",
	},
}

const SWEEP_BLOCK_TOOLTIP := {
	"zh_CN": "本台手术将触发与城宮明日香的搭档剧情，请亲自执刀完成。",
	"en": "This operation will trigger a partner event with Asuka Shiromiya—please perform the surgery in person.",
}

static func owns(id: String) -> bool:
	return id in [PREOP_EVENT_ID, POSTOP_EVENT_ID]

static func is_active_on_preop(prep: RefCounted) -> bool:
	return prep != null and prep.flags.has(ACTIVE_FLAG)

static func crisis_disabled(prep: RefCounted) -> bool:
	return is_active_on_preop(prep)

static func sweep_block_tooltip(english: bool = false) -> String:
	return str(SWEEP_BLOCK_TOOLTIP["en" if english else "zh_CN"])

static func base_relationship_eligible(g: RefCounted) -> bool:
	if g == null:
		return false
	if not g.staff_is_met(ACTOR) or not g.character_event_done(INTRO_EVENT_ID):
		return false
	if g.relationship_level(ACTOR) != 0 or g.character_event_done(POSTOP_EVENT_ID):
		return false
	if not g.relationship_rank_gate_met(ACTOR, 1):
		return false
	if not g.active_special_event_id.is_empty() or g.special_event_in_progress():
		return false
	return true

static func rank_ready(g: RefCounted) -> bool:
	return base_relationship_eligible(g) and not g.is_hospital_closed_day()

static func is_routine_asuka_assistant_preop(prep: RefCounted) -> bool:
	if prep == null:
		return false
	if prep.is_staff_patient():
		return false
	if preload("res://godot/systems/shiori_lv3.gd").is_story_surgery(prep):
		return false
	if prep.flags.has("story_direct_surgery"):
		return false
	var indicated_id := str(prep.definition.get("surgery_id", ""))
	if indicated_id.is_empty() or preload("res://godot/systems/advanced_referral_rules.gd").is_advanced(indicated_id):
		return false
	return str(prep.team.get("assistant_surgeon", "")) == ACTOR

static func blocks_sweep(g: RefCounted, prep: RefCounted) -> bool:
	if is_active_on_preop(prep):
		return true
	return base_relationship_eligible(g) and not g.is_hospital_closed_day() and is_routine_asuka_assistant_preop(prep)

static func eligible(g: RefCounted, id: String) -> bool:
	if not owns(id) or not base_relationship_eligible(g):
		return false
	var test_target := str(g.test_save_target_character_event_id())
	if id == PREOP_EVENT_ID:
		if g.character_event_done(PREOP_EVENT_ID) or g.is_hospital_closed_day():
			return false
		if test_target == PREOP_EVENT_ID and g.active_preop_id.is_empty():
			return true
		if g.active_preop_id.is_empty() or not g.preops.has(g.active_preop_id):
			return false
		return is_routine_asuka_assistant_preop(g.preops[g.active_preop_id])
	if id == POSTOP_EVENT_ID:
		if not g.character_event_done(PREOP_EVENT_ID):
			return false
		if test_target == POSTOP_EVENT_ID:
			return true
		return bool(g.asuka_lv1_postop_opportunity)
	return false

static func mark_preop_active(g: RefCounted) -> void:
	if g == null or g.active_preop_id.is_empty() or not g.preops.has(g.active_preop_id):
		return
	var prep = g.preops[g.active_preop_id]
	if is_routine_asuka_assistant_preop(prep) and not prep.flags.has(ACTIVE_FLAG):
		prep.flags.append(ACTIVE_FLAG)

static func on_surgery_settled(g: RefCounted, prep: RefCounted) -> void:
	if g == null:
		return
	g.asuka_lv1_postop_opportunity = is_active_on_preop(prep) and g.character_event_done(PREOP_EVENT_ID) and not g.character_event_done(POSTOP_EVENT_ID)

static func rollback_unfinished_preop_event(g: RefCounted) -> void:
	if g == null:
		return
	g.asuka_lv1_postop_opportunity = false
	if g.character_event_done(POSTOP_EVENT_ID) or g.relationship_level(ACTOR) >= 1:
		return
	g.character_events.erase(PREOP_EVENT_ID)
	g.character_event_order.erase(PREOP_EVENT_ID)
	var relation: Dictionary = g.relation_for(ACTOR)
	if not relation.is_empty():
		relation.event_history.erase(PREOP_EVENT_ID)
		relation.flags.erase(PREOP_FLAG)

static func on_surgery_aborted(g: RefCounted, prep: RefCounted) -> void:
	if g == null:
		return
	if is_active_on_preop(prep) or g.character_event_done(PREOP_EVENT_ID):
		rollback_unfinished_preop_event(g)
	else:
		g.asuka_lv1_postop_opportunity = false

static func sanitize_after_restore(g: RefCounted) -> void:
	if g == null:
		return
	g.asuka_lv1_postop_opportunity = false
	if g.story_flag("__test_save_target_character_event__" + POSTOP_EVENT_ID):
		return
	if g.character_event_done(PREOP_EVENT_ID) and not g.character_event_done(POSTOP_EVENT_ID) and g.relationship_level(ACTOR) == 0:
		rollback_unfinished_preop_event(g)

static func prepare_test_save(g: RefCounted, event_id: String, base_day: int) -> int:
	g.meet_staff(ACTOR)
	var relation: Dictionary = g.relation_for(ACTOR)
	relation.met = true
	relation.level = 0
	relation.familiarity = maxi(int(relation.get("familiarity", 0)), 10)
	g.set_test_player_attribute("charm", maxi(int(g.player_attributes().get("charm", 0)), 10))
	g._complete_character_event_for_test("asuka_scrub_sink_encounter", 1)
	g._complete_character_event_for_test("asuka_adjacent_operation_reveal", 1)
	g._complete_character_event_for_test(INTRO_EVENT_ID, 2)
	var target_day := maxi(base_day, 3)
	while target_day < g.GAME_DURATION_DAYS and g.is_hospital_closed_day(target_day):
		target_day += 1
	if event_id == POSTOP_EVENT_ID:
		g._complete_character_event_for_test(PREOP_EVENT_ID, target_day)
		g.asuka_lv1_postop_opportunity = true
	return target_day

static func option_response_override(prep: RefCounted, _flow_step: Dictionary) -> Dictionary:
	if not is_active_on_preop(prep) or str(prep.team.get("assistant_surgeon", "")) != ACTOR:
		return {}
	var steps: Array = prep.surgery_flow_steps()
	var total := steps.size()
	var idx := int(prep.procedure_step_index)
	if total <= 0:
		return {}
	var key := ""
	if idx == 0:
		key = "01_exposure"
	elif total >= 3 and idx == 1:
		key = "02_hemostasis"
	elif total >= 2 and idx == total - 1:
		key = "03_closure"
	if key.is_empty():
		return {}
	var locale := "en" if prep.english_mode() else "zh_CN"
	return {
		"role": "assistant_surgeon",
		"staff_id": ACTOR,
		"line": str(INTRAOP_LINES[key][locale]),
	}
