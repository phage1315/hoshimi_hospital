extends RefCounted
## Katagiri Ayako 30-day hospital research residency ("Hoshimi Hospital Story").
## Pure stateless rules over settled completion days, story flags, and relation facts;
## zero inner VN state is ever persisted to BoundarySave.

const Calendar = preload("res://godot/systems/fixed_calendar.gd")

const OPENING := "ayako_return_00_opening"
const WEEK1 := "ayako_return_01_week1_nurses"
const WEEK2 := "ayako_return_02_week2_sketches"
const WEEK3 := "ayako_return_03_week3_shiori"
const WEEK4 := "ayako_return_04_week4_storyboard"
const DEPARTURE := "ayako_return_05_departure"

const MILESTONES := [
	OPENING,
	WEEK1,
	WEEK2,
	WEEK3,
	WEEK4,
	DEPARTURE,
]

const AMB_01 := "ayako_amb_01_badge_reflex"
const AMB_02 := "ayako_amb_02_gyn_danger_sense"
const AMB_03 := "ayako_amb_03_postop_vending_sketch"
const AMB_04 := "ayako_amb_04_lightning_corridor"
const AMB_05 := "ayako_amb_05_cool_drug_name"
const AMB_06 := "ayako_amb_06_two_thick_notebooks"
const AMB_07 := "ayako_amb_07_dynamic_uniform_folds"
const AMB_08 := "ayako_amb_08_observed_observer"
const AMB_09 := "ayako_amb_09_director_uniform_audit"
const AMB_10 := "ayako_amb_10_yellow_line_honor_student"

const AMBIENTS := [
	AMB_01,
	AMB_02,
	AMB_03,
	AMB_04,
	AMB_05,
	AMB_06,
	AMB_07,
	AMB_08,
	AMB_09,
	AMB_10,
]

const PREREQ_LV2 := "miyama_02_manga_artist_wrong_patient"
const CUTOFF_ISO := "2026-02-01"
const DAYS_AFTER_LV2 := 180
const AMBIENT_COOLDOWN_DAYS := 2
const AMBIENT_ROLL_PERCENT := 45

const AMBIENT_SPECS := {
	AMB_01: {
		"slots": ["daytime"],
		"locations": ["ward", "clinic", "lobby"],
		"departure": false,
		"extra_met": [],
	},
	AMB_02: {
		"slots": ["daytime"],
		"locations": ["gynecology_exam", "exam"],
		"departure": false,
		"extra_met": ["doc_aqua"],
	},
	AMB_03: {
		"slots": ["evening"],
		"locations": ["or", "lounge"],
		"departure": true,
		"extra_met": [],
	},
	AMB_04: {
		"slots": ["morning"],
		"locations": ["ward", "emiko_office", "artoria_office", "or"],
		"departure": false,
		"extra_met": ["doc_emiko", "doc_artoria"],
	},
	AMB_05: {
		"slots": ["evening"],
		"locations": ["pharmacy", "lobby"],
		"departure": true,
		"extra_met": ["pharmacist_manami"],
	},
	AMB_06: {
		"slots": ["daytime"],
		"locations": ["station", "ward", "clinic"],
		"departure": false,
		"extra_met": ["nurse_moe", "nurse_hiroko"],
	},
	AMB_07: {
		"slots": ["daytime"],
		"locations": ["ward", "station"],
		"departure": false,
		"extra_met": ["nurse_iwasaki_rumi", "nurse_yoneda_shiori"],
	},
	AMB_08: {
		"slots": ["daytime"],
		"locations": ["lounge", "shared_doctors_office", "narumi_office"],
		"departure": false,
		"extra_met": ["doc_aoi", "doc_sayaka"],
	},
	AMB_09: {
		"slots": ["morning"],
		"locations": ["lobby", "director_office"],
		"departure": false,
		"extra_met": [],
	},
	AMB_10: {
		"slots": ["morning", "evening"],
		"locations": ["or", "exam"],
		"departure": true,
		"extra_met": [],
	},
}

static func owns(id: String) -> bool:
	return id in MILESTONES or id in AMBIENTS

static func is_milestone(id: String) -> bool:
	return id in MILESTONES

static func is_ambient(id: String) -> bool:
	return id in AMBIENTS

static func cutoff_day() -> int:
	return Calendar.day_for_iso(CUTOFF_ISO)

static func opening_unlocked_facts(g: RefCounted, workday: int) -> bool:
	if g.special_event_done(OPENING):
		return false
	if not g.special_event_done(PREREQ_LV2) and not g.story_flag("miyama_02_manga_artist_wrong_patient_completed"):
		return false
	if not g.story_flag("ayako_shiori_reconnected"):
		return false
	if g.relationship_level("doc_rei") < 3 or g.relationship_level("doc_shiori") < 3:
		return false
	var lv2_day := int(g.special_event_completion_days.get(PREREQ_LV2, 0))
	if lv2_day <= 0 or workday - lv2_day < DAYS_AFTER_LV2:
		return false
	if workday > cutoff_day() or workday > g.GAME_DURATION_DAYS:
		return false
	return true

static func residency_active(g: RefCounted) -> bool:
	if not g.special_event_done(OPENING) or g.special_event_done(DEPARTURE):
		return false
	return g.story_flag("ayako_research_residency_active")

static func opening_day(g: RefCounted) -> int:
	return int(g.special_event_completion_days.get(OPENING, 0))

static func residency_day(g: RefCounted, workday: int) -> int:
	if not g.special_event_done(OPENING):
		return 0
	var start := opening_day(g)
	if start <= 0:
		return 0
	return maxi(1, workday - start + 1)

static func milestone_completed_on_day(g: RefCounted, workday: int) -> bool:
	for id in MILESTONES:
		if g.special_event_done(id) and int(g.special_event_completion_days.get(id, -1)) == workday:
			return true
	return false

static func ambient_completed_on_day(g: RefCounted, workday: int) -> bool:
	for id in AMBIENTS:
		if g.special_event_done(id) and int(g.special_event_completion_days.get(id, -1)) == workday:
			return true
	return false

static func last_ambient_day(g: RefCounted) -> int:
	var latest := 0
	for id in AMBIENTS:
		if g.special_event_done(id):
			latest = maxi(latest, int(g.special_event_completion_days.get(id, 0)))
	return latest

static func armed_milestone(g: RefCounted, workday: int) -> String:
	if milestone_completed_on_day(g, workday):
		return ""
	if not g.special_event_done(OPENING):
		return OPENING if opening_unlocked_facts(g, workday) else ""
	if g.special_event_done(DEPARTURE) or not residency_active(g):
		return ""
	var rday := residency_day(g, workday)
	if not g.special_event_done(WEEK1):
		return WEEK1 if rday >= 6 else ""
	if not g.special_event_done(WEEK2):
		return WEEK2 if rday >= 13 else ""
	if not g.special_event_done(WEEK3):
		return WEEK3 if rday >= 20 else ""
	if not g.special_event_done(WEEK4):
		return WEEK4 if rday >= 27 else ""
	if not g.special_event_done(DEPARTURE):
		return DEPARTURE if rday >= 30 else ""
	return ""

static func base_requirements_met(g: RefCounted, id: String, override_workday: int = -1) -> bool:
	if g.special_event_done(id):
		return false
	var workday: int = override_workday if override_workday > 0 else g.current_workday()
	if id == OPENING:
		return opening_unlocked_facts(g, workday)
	if not residency_active(g):
		return false
	match id:
		WEEK1:
			return true
		WEEK2:
			return g.special_event_done(WEEK1)
		WEEK3:
			return g.special_event_done(WEEK2)
		WEEK4:
			return g.special_event_done(WEEK3)
		DEPARTURE:
			return g.special_event_done(WEEK4)
	if is_ambient(id):
		return g.story_flag("ayako_ambient_pool_enabled") and _ambient_extra_met(g, id)
	return false

static func _ambient_extra_met(g: RefCounted, id: String) -> bool:
	var spec: Dictionary = AMBIENT_SPECS.get(id, {})
	for actor_id in spec.get("extra_met", []):
		if not g.staff_is_met(str(actor_id)):
			return false
	return true

static func target_day(g: RefCounted, id: String) -> int:
	if g.special_event_done(id):
		return -1
	var workday: int = g.current_workday()
	if id == OPENING:
		if not g.special_event_done(PREREQ_LV2) and not g.story_flag("miyama_02_manga_artist_wrong_patient_completed"):
			return -1
		var lv2_day := int(g.special_event_completion_days.get(PREREQ_LV2, 0))
		if lv2_day <= 0:
			return -1
		var earliest := maxi(workday, lv2_day + DAYS_AFTER_LV2)
		if earliest > cutoff_day():
			return -1
		return earliest
	if not residency_active(g):
		return -1
	var open_d := opening_day(g)
	match id:
		WEEK1:
			return maxi(workday, open_d + 5)
		WEEK2:
			return maxi(workday, open_d + 12) if g.special_event_done(WEEK1) else -1
		WEEK3:
			return maxi(workday, open_d + 19) if g.special_event_done(WEEK2) else -1
		WEEK4:
			return maxi(workday, open_d + 26) if g.special_event_done(WEEK3) else -1
		DEPARTURE:
			return maxi(workday, open_d + 29) if g.special_event_done(WEEK4) else -1
	if is_ambient(id):
		return maxi(workday, open_d + 1)
	return -1

static func timing_status(g: RefCounted, id: String) -> Dictionary:
	var workday: int = g.current_workday()
	var target := target_day(g, id)
	if target < 1:
		return {"status": "expired", "trigger_day": -1, "effective_day": -1}
	if str(Calendar.date_for_day(workday).weekday_id) == "sun":
		return {"status": "sunday_deferred", "trigger_day": target, "effective_day": workday + 1}
	if is_milestone(id):
		if armed_milestone(g, workday) == id:
			return {"status": "available", "trigger_day": target, "effective_day": workday}
		return {"status": "future", "trigger_day": target, "effective_day": maxi(target, workday)}
	if ambient_pool_ready(g, workday) and _ambient_extra_met(g, id):
		return {"status": "available", "trigger_day": target, "effective_day": workday}
	return {"status": "future", "trigger_day": target, "effective_day": maxi(target, workday)}

static func _busy_clinical_or_story(g: RefCounted) -> bool:
	if not g.active_special_event_id.is_empty() or not g.active_character_event_id.is_empty() or not g.active_micro_event_id.is_empty():
		return true
	if g.active_surgery_in_progress() or g.active_encounter_in_progress() or not g.active_preop_id.is_empty():
		return true
	if not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty():
		return true
	return false

static func eligible_day_start(g: RefCounted, id: String) -> bool:
	if id not in [OPENING, DEPARTURE]:
		return false
	if _busy_clinical_or_story(g) or not g.pending_departure_context().is_empty():
		return false
	if g.is_sunday() or g.is_hospital_closed_day(g.day_number()):
		return false
	if g.current_absolute_clock() != g.SHIFT_START_MINUTE or g.day_start_character_event_consumed():
		return false
	# Yield to any pending character day-start event or surgical reservation today.
	if not g.next_day_start_character_event().is_empty():
		return false
	if preload("res://godot/systems/miyuki_lv2.gd").reserved_today(g) or preload("res://godot/systems/chihaya_mizuho_return.gd").reserved_today(g):
		return false
	return armed_milestone(g, g.day_number()) == id

static func eligible(g: RefCounted, id: String, allow_departure_window: bool = false, override_workday: int = -1) -> bool:
	if not base_requirements_met(g, id, override_workday) or _busy_clinical_or_story(g):
		return false
	var workday: int = override_workday if override_workday > 0 else g.current_workday()
	if str(Calendar.date_for_day(workday).weekday_id) == "sun" or g.is_hospital_closed_day(workday):
		return false
	if g.test_save_target_event_id() == id:
		return true
	if allow_departure_window:
		if is_milestone(id):
			return id in [OPENING, WEEK2, WEEK3, WEEK4, DEPARTURE] and armed_milestone(g, workday) == id
		var dep_spec: Dictionary = AMBIENT_SPECS.get(id, {})
		return bool(dep_spec.get("departure", false)) and ambient_pool_ready(g, workday) and _ambient_extra_met(g, id)
	if not g.pending_departure_context().is_empty():
		return false
	var clock: int = g.current_absolute_clock()
	if id in [OPENING, DEPARTURE]:
		return eligible_day_start(g, id)
	if id == WEEK1:
		return armed_milestone(g, workday) == WEEK1 and clock >= 12 * 60 and clock <= 16 * 60
	if id in [WEEK2, WEEK3, WEEK4]:
		return false
	if is_ambient(id):
		if not ambient_pool_ready(g, workday) or not _ambient_extra_met(g, id):
			return false
		var slot := _clock_slot(clock)
		return slot in AMBIENT_SPECS.get(id, {}).get("slots", [])
	return false

static func _clock_slot(clock: int) -> String:
	if clock >= 9 * 60 and clock <= 10 * 60 + 30:
		return "morning"
	if clock >= 12 * 60 and clock <= 16 * 60:
		return "daytime"
	if clock >= 17 * 60 and clock <= 18 * 60:
		return "evening"
	return ""

static func ambient_pool_ready(g: RefCounted, workday: int) -> bool:
	if not residency_active(g) or not g.story_flag("ayako_ambient_pool_enabled"):
		return false
	if residency_day(g, workday) < 2:
		return false
	if not armed_milestone(g, workday).is_empty() or milestone_completed_on_day(g, workday):
		return false
	if ambient_completed_on_day(g, workday):
		return false
	var last_day := last_ambient_day(g)
	if last_day > 0 and workday - last_day < AMBIENT_COOLDOWN_DAYS:
		return false
	return true

static func _deterministic_roll_passes(g: RefCounted, workday: int, salt: String) -> bool:
	var h: int = abs(hash("%s:%s:%s" % [int(g.campaign_seed), workday, salt]))
	return (h % 100) < AMBIENT_ROLL_PERCENT

static func _deterministic_pick(g: RefCounted, workday: int, salt: String, candidates: Array[String]) -> String:
	if candidates.is_empty():
		return ""
	var h: int = abs(hash("pick:%s:%s:%s" % [int(g.campaign_seed), workday, salt]))
	return candidates[h % candidates.size()]

static func has_pending_location_milestone(g: RefCounted, location_id: String) -> bool:
	if _busy_clinical_or_story(g) or not g.pending_departure_context().is_empty():
		return false
	if g.is_sunday() or g.is_hospital_closed_day(g.day_number()):
		return false
	var clock: int = g.current_absolute_clock()
	if armed_milestone(g, g.day_number()) == WEEK1 and clock >= 12 * 60 and clock <= 16 * 60:
		return location_id in ["station", "ward"]
	return false

static func next_location_event(g: RefCounted, location_id: String, allow_ambient_roll: bool = true) -> String:
	if _busy_clinical_or_story(g) or not g.pending_departure_context().is_empty():
		return ""
	var workday: int = g.day_number()
	if g.is_sunday() or g.is_hospital_closed_day(workday):
		return ""
	var clock: int = g.current_absolute_clock()
	if armed_milestone(g, workday) == WEEK1 and clock >= 12 * 60 and clock <= 16 * 60 and location_id in ["station", "ward"]:
		return WEEK1
	if not allow_ambient_roll or not ambient_pool_ready(g, workday):
		return ""
	var slot := _clock_slot(clock)
	if slot.is_empty():
		return ""
	var candidates: Array[String] = []
	for id in AMBIENTS:
		if g.special_event_done(id) or not _ambient_extra_met(g, id):
			continue
		var spec: Dictionary = AMBIENT_SPECS.get(id, {})
		if slot in spec.get("slots", []) and location_id in spec.get("locations", []):
			candidates.append(id)
	if candidates.is_empty():
		return ""
	if not _deterministic_roll_passes(g, workday, "loc:" + slot + ":" + location_id):
		return ""
	return _deterministic_pick(g, workday, "loc:" + slot + ":" + location_id, candidates)

static func next_departure_event(g: RefCounted, workday: int, departure_clock: int, force_ambient: bool = false) -> String:
	if _busy_clinical_or_story(g):
		return ""
	if str(Calendar.date_for_day(workday).weekday_id) == "sun" or g.is_hospital_closed_day(workday):
		return ""
	# Evening departure window is 17:00-18:00 (also allow player-initiated end-of-day slightly before 17:00).
	if departure_clock > 18 * 60:
		return ""
	var armed := armed_milestone(g, workday)
	if armed in [OPENING, WEEK2, WEEK3, WEEK4, DEPARTURE]:
		return armed
	if not ambient_pool_ready(g, workday):
		return ""
	var candidates: Array[String] = []
	for id in AMBIENTS:
		if g.special_event_done(id) or not _ambient_extra_met(g, id):
			continue
		var spec: Dictionary = AMBIENT_SPECS.get(id, {})
		if bool(spec.get("departure", false)):
			candidates.append(id)
	if candidates.is_empty():
		return ""
	if not force_ambient and not _deterministic_roll_passes(g, workday, "dep"):
		return ""
	return _deterministic_pick(g, workday, "dep", candidates)

static func settle(g: RefCounted, id: String, started_day: int, charge_shift_minutes: bool) -> void:
	if not owns(id):
		return
	var definition: Dictionary = g.special_event_definitions.get(id, {})
	if charge_shift_minutes and g.pending_departure_context().is_empty():
		var minutes := maxi(0, int(definition.get("settled_minutes", 0)))
		var max_safe: int = maxi(0, (g.SHIFT_START_MINUTE + g.SHIFT_MINUTES - 5) - g.current_absolute_clock())
		g.story_time_advance_minutes += mini(minutes, max_safe)
	g.special_event_completion_days[id] = started_day
	match id:
		OPENING:
			g.set_story_flag("ayako_return_opening_completed", true)
			g.set_story_flag("ayako_research_residency_active", true)
			g.set_story_flag("ayako_ambient_pool_enabled", true)
		WEEK1:
			g.set_story_flag("ayako_return_week1_completed", true)
		WEEK2:
			g.set_story_flag("ayako_return_week2_completed", true)
		WEEK3:
			g.set_story_flag("ayako_return_week3_completed", true)
		WEEK4:
			g.set_story_flag("ayako_return_week4_completed", true)
		DEPARTURE:
			g.set_story_flag("ayako_return_departure_completed", true)
			g.set_story_flag("ayako_research_residency_active", false)
			g.set_story_flag("ayako_ambient_pool_enabled", false)
			g.set_story_flag("ayako_return_hoshimi_manga_completed", true)
			g.set_story_flag("ayako_research_residency_completed", true)
			g.set_story_flag("ayako_hospital_manga_project_started", true)
			g.set_story_flag("ayako_nurse_uniform_gifted", true)
			g.set_story_flag("ayako_research_badge_gifted", true)
			g.set_story_flag("ayako_finale_party_eligible", true)
