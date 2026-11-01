extends RefCounted
## Dates, completed employment facts, and atomic settlement; no saved VN state.
const DISCHARGE := "chihaya_mizuho_joint_discharge"
const RETURN := "chihaya_mizuho_nurse_return"
const ACTORS := ["patient_chihaya", "guest_mizuho"]
const Calendar = preload("res://godot/systems/fixed_calendar.gd")
const Third = preload("res://godot/systems/chihaya_third_surgery.gd")

static func owns(id: String) -> bool:
	return id in [DISCHARGE, RETURN]

static func add_months(day: int, months: int) -> int:
	if day < 1: return -1
	var date := Calendar.date_for_day(day)
	var month: int = int(date.month) + months
	var year: int = int(date.year) + (month - 1) / 12
	month = (month - 1) % 12 + 1
	# Calendar-month arithmetic clamps the day to the target month's last day.
	var lengths := [31,29 if year % 4 == 0 and (year % 100 != 0 or year % 400 == 0) else 28,31,30,31,30,31,31,30,31,30,31]
	return Calendar.day_for_iso(Calendar.iso_date(year,month,mini(int(date.date),lengths[month-1])))

static func discharge_day(g: RefCounted) -> int:
	return int(g.special_event_completion_days.get(Third.A,0)) + 14 if g.special_event_done(Third.A) else -1

static func occupied(g: RefCounted, candidate: int) -> bool:
	for definition in g.special_event_definitions.values():
		var id := str(definition.id)
		if owns(id) or bool(definition.get("developer_only",false)) or g.special_event_done(id) or not g.special_event_base_requirements_met(definition): continue
		if not bool(definition.get("auto_schedule",false)): continue
		var start: int = g.special_event_trigger_day(definition)
		var duration: int = Third.occupied_days(id,maxi(1,int(definition.duration_days)))
		if candidate >= start and candidate < start + duration: return true
	if candidate == g.day_number() and not g.next_day_start_character_event().is_empty(): return true
	return false

static func scheduled_day(g: RefCounted, id: String) -> int:
	if g.special_event_done(id): return -1
	if id == DISCHARGE: return discharge_day(g)
	if id != RETURN or not g.special_event_done(DISCHARGE): return -1
	var earliest := add_months(int(g.special_event_completion_days.get(DISCHARGE,0)),1)
	if earliest < 1: return -1
	var candidate: int = maxi(earliest,g.day_number())
	if candidate == g.day_number() and g.current_absolute_clock() > 540: candidate += 1
	while candidate <= g.GAME_DURATION_DAYS:
		var end := add_months(candidate,3)
		if end < 1 or end > Calendar.day_for_iso("2026-03-31"): return -1
		if Calendar.is_routine_workday(candidate) and not occupied(g,candidate): return candidate
		candidate += 1
	return -1

static func timing_status(g: RefCounted, id: String) -> Dictionary:
	var target := scheduled_day(g,id)
	return {"status":"available" if target == g.day_number() else "expired" if target < 1 or target < g.day_number() else "future", "trigger_day":target,"effective_day":target}

static func eligible(g: RefCounted, id: String) -> bool:
	if g.current_absolute_clock() != 540 or scheduled_day(g,id) != g.day_number(): return false
	if not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or not g.pending_departure_context().is_empty() or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty(): return false
	return not g.day_start_character_event_consumed()

static func reserved_today(g: RefCounted) -> bool:
	return not g.special_event_done(DISCHARGE) and discharge_day(g) == g.day_number() and g.current_absolute_clock() == 540

static func conflicts(g: RefCounted, definition: Dictionary) -> bool:
	if owns(str(definition.id)) or g.special_event_done(DISCHARGE): return false
	var day := discharge_day(g)
	var first: int = g.current_workday()
	var last: int = first + Third.occupied_days(str(definition.id),int(definition.duration_days)) - 1
	return day >= first and day <= last and (day > first or reserved_today(g))

static func settle(g: RefCounted, id: String) -> void:
	if id == DISCHARGE:
		g.set_story_flag("chihaya_mizuho_discharged",true)
	if id != RETURN: return
	var start: int = int(g.special_event_completion_days[RETURN])
	for actor in ACTORS:
		if g.staff_contracts.has(actor): continue
		var relation: Dictionary = g.relation_for(actor)
		relation.met = true
		relation.level = 3
		relation.familiarity = 50
		relation.flags.erase("introduction_pending")
		if not relation.rank_history.has(RETURN): relation.rank_history.append(RETURN)
		if not relation.event_history.has(RETURN): relation.event_history.append(RETURN)
		g.staff_contracts[actor] = {"start_day":start,"end_day":add_months(start,3)}
	g.set_story_flag("chihaya_mizuho_nurses_hired",true)
	g.set_story_flag("mizuho_medical_balance_contract_pending",true)

static func chat_available(g: RefCounted, definition: Dictionary) -> bool:
	if not definition.has("dialogue_variants"): return true
	if g.active_mode != "encounter" or not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or not g.active_character_event_id.is_empty() or not g.active_micro_event_id.is_empty(): return false
	var present: Array = g.staff_present_at(str(definition.location_id))
	for actor in definition.get("required_actor_ids",[definition.actor_id]):
		if not g.staff_is_met(str(actor)) or actor not in present: return false
	return true
