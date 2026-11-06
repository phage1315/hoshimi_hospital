extends RefCounted
const Model = preload("res://godot/systems/advanced_surgery_model.gd")
const Rules = preload("res://godot/systems/advanced_referral_rules.gd")
const Facts = preload("res://godot/systems/advanced_referral_facts.gd")
const Session = preload("res://godot/systems/advanced_surgery_session.gd")
const Settlement = preload("res://godot/systems/advanced_settlement.gd")
const FirstStory = preload("res://godot/systems/advanced_first_story.gd")
const ROLES := ["first_assistant", "second_assistant", "primary_scrub", "secondary_scrub", "primary_circulating", "secondary_circulating", "anesthesia"]
const ROLE_MAP := {"first_assistant": "assistant_surgeon", "second_assistant": "assistant_surgeon", "primary_scrub": "scrub_nurse", "secondary_scrub": "scrub_nurse", "primary_circulating": "circulating_nurse", "secondary_circulating": "circulating_nurse"}
var game: RefCounted
var dev := false
var demo_day := 1
var local_facts := Facts.fresh()
var session: RefCounted
var error := ""
var last_summary: Dictionary = {}
var fixture_index := 0
var fixture_mode := false # Explicit numerical-fixture QA only; manual testing uses real staff.
var demo_player_skill := 88
var failure_dialogue_index := -1 # Runtime-only review presentation, after settlement.
var review_roster: Dictionary = {}
var story_phase := "" # Presentation cursors are memory-only, never facts.
var story_index := 0
var story_record: Dictionary = {}
var story_content: Dictionary = {}
var day_transition: Dictionary = {} # Presentation only; never persisted or replayed from facts.

func queue_day_transition(target_day: int, intake_day: int) -> void:
	if dev and fixture_mode: return
	day_transition = {"day": target_day, "ordinal": target_day - intake_day + 1}

func dismiss_day_transition() -> void:
	day_transition.clear()


func begin_story(phase: String, record: Dictionary) -> void:
	if dev and fixture_mode: return
	var authored := FirstStory.content(record)
	if authored.is_empty() or not authored.has(phase): return
	story_phase = phase
	story_index = 0
	story_record = record.duplicate(true)
	story_content = authored
	if not dev: game.active_mode = "advanced_story"

func finish_story() -> void:
	story_phase = ""
	# Finishing a chapter returns to the referral UI, not a save boundary.
	if not dev and game.active_mode == "advanced_story": game.active_mode = "advanced_board"

func advance_story() -> void:
	if story_phase.is_empty(): return
	story_index += 1
	if story_index >= story_content[story_phase].lines.size(): finish_story()

func _init(g: RefCounted, testing: bool = false) -> void:
	game = g
	dev = testing
	if not dev and game.advanced_referral_facts.is_empty(): game.advanced_referral_facts = Facts.fresh()
	if not dev: session = game.advanced_runtime

func state() -> Dictionary:
	return local_facts if dev else game.advanced_referral_facts
func day() -> int:
	return demo_day if dev else game.day_number()
func eligible() -> bool:
	return dev or not state().appointment.is_empty() or (game.advanced_referral_eligible() and game.advanced_referral_system_unlocked())

func refresh() -> void:
	if not dev:
		game.sync_advanced_referral_calendar()
		return
	# DEV previews ready content only; art/content holds also apply to manual tests.
	local_facts.activated_day = 1
	Rules.update_pool(local_facts, day(), 20261030, preload("res://godot/systems/advanced_presentation.gd").random_patient_ids(game))

func completed(id: String) -> bool:
	for result in state().completed:
		if result.case_id == id: return true
	return false

func board() -> Array:
	refresh()
	var result: Array = []
	var ids: Array = Rules.manifest().filter(Rules.ready).map(func(row): return row.procedure_id) if dev else state().get("new_board", [])
	for id in ids:
		if not Rules.procedure_ready(str(id)): continue
		var procedure := Model.procedure(str(id))
		if not procedure.is_empty() and not state().procedures.has(id):
			var record := {"id": "advanced_first_" + str(procedure.id), "procedure_id": procedure.id, "patient_id": "placeholder_first_" + str(procedure.id), "replay": false}
			var patient := FirstStory.patient(record, false)
			if not patient.is_empty(): record.patient_id = patient.id
			result.append(record)
	for record in state().replays:
		if Rules.procedure_ready(str(record.get("procedure_id", ""))) and Rules.replay_compatible(record) and not completed(str(record.get("id", ""))): result.append(record.duplicate(true))
	return result

func date_blocked(target: int) -> bool:
	if dev: return false
	if target >= game.FINAL_WEEK_START_DAY or target > game.GAME_DURATION_DAYS: return true
	var timing: Dictionary = game.advanced_referral_timing_status({"duration_days": 1, "priority": 0}, target)
	if timing.status != "available": return true
	if not game.free_h_booking.is_empty() and int(game.free_h_booking.get("workday", 0)) == target: return true
	if preload("res://godot/systems/miyuki_lv2.gd").booked_day(game) == target: return true
	return false

func schedule() -> Dictionary:
	if dev: return {"intake_day": day(), "operation_day": day() + 1, "review_day": day() + 2}
	if not game.is_routine_workday(day()) or game.current_absolute_clock() > 960 or date_blocked(day()): return {}
	# Stop rather than skipping a protected story window in the three-day episode.
	var dates: Array = [day()]
	for candidate in range(day() + 1, mini(game.FINAL_WEEK_START_DAY, day() + 15)):
		if date_blocked(candidate): return {}
		if game.is_routine_workday(candidate): dates.append(candidate)
		if dates.size() == 3: return {"intake_day": dates[0], "operation_day": dates[1], "review_day": dates[2]}
	return {}

func candidates(role: String, operation_day: int) -> Array:
	var result: Array = []
	for person in game.staff:
		var id := str(person.id)
		if not dev and not game.staff_can_join_surgery_team(id): continue
		var anesthetist: bool = "anesthesiologist" in person.get("flags", [])
		if role == "anesthesia":
			if anesthetist: result.append(person)
			continue
		if anesthetist: continue
		var basic := str(ROLE_MAP.get(role, ""))
		if basic not in person.get("surgical_roles", []): continue
		if person.has("allowed_team_roles") and basic not in person.allowed_team_roles: continue
		if role in ["first_assistant", "second_assistant"] and int(state().cooldowns.get(id, 0)) > operation_day: continue
		result.append(person)
	return result

func valid_team(selected: Dictionary, operation_day: int) -> bool:
	var used: Array = []
	for role in ROLES:
		var id := str(selected.get(role, ""))
		if id.is_empty() or id in used: return false
		if not (dev and fixture_mode):
			var ids: Array = candidates(role, operation_day).map(func(person): return str(person.id))
			if id not in ids: return false
		used.append(id)
	return true

func values(selected: Dictionary, procedure_id: String) -> Dictionary:
	if dev and fixture_mode: return Model.fixtures(procedure_id)[fixture_index].duplicate(true)
	var specialties: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/specialties.json"))
	var assistants: Array = []
	for role in ["first_assistant", "second_assistant"]:
		var id := str(selected[role])
		assistants.append({"id": id, "name": game.staff_record(id).name, "skill": game.staff_skill_value(id, "surgery"), "specialties": specialties.get(id, {}).get("tags", []), "universal_expert": specialties.get(id, {}).get("universal_expert", false)})
	return {"player": demo_player_skill if dev else game.surgery_level(), "assistants": assistants,
		"primary_scrub": game.staff_skill_value(selected.primary_scrub, "instrument_handling"),
		"secondary_scrub": game.staff_skill_value(selected.secondary_scrub, "instrument_handling"),
		"primary_circ": game.staff_skill_value(selected.primary_circulating, "teamwork"),
		"secondary_circ": game.staff_skill_value(selected.secondary_circulating, "teamwork")}

func accept(record: Dictionary, selected: Dictionary) -> bool:
	error = "unavailable"
	if not eligible() or not state().appointment.is_empty(): return false
	if not dev and (game.active_surgery_in_progress() or game.special_event_in_progress() or not game.active_preop_id.is_empty() or not game.active_id.is_empty() or not game.active_character_event_id.is_empty() or not game.active_micro_event_id.is_empty()): return false
	if record not in board(): return false
	var dates := schedule()
	if dates.is_empty():
		error = "calendar"
		return false
	if not valid_team(selected, int(dates.operation_day)):
		error = "team"
		return false
	dates.case = record.duplicate(true)
	dates.team = selected.duplicate(true)
	dates.intake_minutes = 60
	state().appointment = dates
	if not dev:
		game.time_log.append({"id": "advanced_intake_" + str(record.id), "start": game.elapsed(), "minutes": 60})
	error = ""
	return true

func rebook(selected: Dictionary) -> bool:
	var a: Dictionary = state().appointment
	if a.is_empty() or not state().outcome.is_empty() or session != null: return false
	var dates := schedule()
	if dates.is_empty() or not valid_team(selected, int(dates.get("operation_day", 0))):
		error = "calendar" if dates.is_empty() else "team"
		return false
	a.operation_day = dates.operation_day
	a.review_day = dates.review_day
	a.team = selected.duplicate(true)
	error = ""
	return true

func start_operation() -> bool:
	var a: Dictionary = state().appointment
	if a.is_empty() or not state().outcome.is_empty() or session != null or day() != int(a.operation_day): return false
	if not Rules.procedure_ready(str(a.case.procedure_id)) or not Rules.replay_compatible(a.case): return false
	if not dev and game.current_absolute_clock() != game.SHIFT_START_MINUTE:
		error = "calendar"
		return false
	if not valid_team(a.team, int(a.operation_day)):
		error = "team"
		return false
	var def := Model.procedure(str(a.case.procedure_id))
	if def.is_empty(): return false
	var seed_value := randi() # Operation random state exists only in this running process.
	session = Session.new(def, values(a.team, def.id), seed_value, game.staff, a.team, dev and fixture_mode)
	session.suppress_operative_dialogue = dev and fixture_mode
	var completed_count := 0
	for result in state().completed:
		if result.procedure_id == def.id: completed_count += 1
	session.operative_dialogue = preload("res://godot/systems/advanced_operative_dialogue.gd").new(str(def.id), completed_count)
	if not (dev and fixture_mode):
		if session.operative_dialogue.data.get("schema_version") == "advanced_day2_dialogue_v2":
			session.sweat_break = preload("res://godot/systems/advanced_or_sweat_break.gd").new(seed_value, a.team)
		session.splash_pending = true
		session.patient_ready_pending = true
		session.team_intro_index = 0
	if not dev:
		game.advanced_runtime = session
		game.active_mode = "advanced_surgery"
	queue_day_transition(int(a.operation_day), int(a.intake_day))
	for role in ["first_assistant", "second_assistant"]: state().cooldowns[str(a.team[role])] = int(a.operation_day) + 14
	return true

func finish_operation() -> bool:
	if session == null or not session.finished or not state().outcome.is_empty(): return false
	var a: Dictionary = state().appointment
	state().outcome = {"case_id": a.case.id, "success": session.success, "operation_day": a.operation_day, "minutes": int(session.physiology.procedure_state.elapsed_time) if session.physiology != null else 480}
	last_summary = {"hp": session.hp, "precision_failures": session.precision_failures, "rescue_attempts": session.rescue_attempts, "crises": session.crisis_count}
	if dev: demo_day = int(a.review_day)
	else:
		game.advance_story_to_day(int(a.operation_day) + 1, game.SHIFT_START_MINUTE)
		game.advanced_runtime = null
		game.active_mode = "encounter"
	session = null
	return true

func settle() -> bool:
	refresh() # Freeze this week before recording a new clearance.
	var s := state()
	if s.appointment.is_empty() or s.outcome.is_empty(): return false
	var a: Dictionary = s.appointment
	if day() < int(a.review_day) or completed(str(a.case.id)): return false
	var first_clear: bool = bool(s.outcome.success) and not bool(a.case.replay) and s.procedures.get(str(a.case.procedure_id),"") != "CLEARED"
	var result := {"case_id": a.case.id, "procedure_id": a.case.procedure_id, "success": s.outcome.success,
		"day": day(), "minutes": int(a.intake_minutes) + int(s.outcome.minutes) + 60,
		"surgery_xp": 0, "leadership_xp": 0.0, "reputation": 0}
	if bool(s.outcome.success):
		s.procedures[str(a.case.procedure_id)] = "CLEARED"
		if not s.clear_days.has(a.case.procedure_id): s.clear_days[a.case.procedure_id] = day()
		if not s.successful_operation_days.has(a.case.procedure_id): s.successful_operation_days[a.case.procedure_id] = int(a.operation_day)
		if not dev: result.merge(Settlement.new().settle(game, Model.procedure(str(a.case.procedure_id)), a.team), true)
	elif not bool(a.case.replay): s.procedures[str(a.case.procedure_id)] = "FAILED_LOCKED"
	if not dev:
		game.time_log.append({"id": "advanced_review_" + str(a.case.id), "start": game.elapsed(), "minutes": 60})
		Rules.update_gates(game, s)
	s.completed.append(result)
	review_roster = a.team.duplicate(true)
	failure_dialogue_index = 0 if not bool(result.success) and not (dev and fixture_mode) else -1
	s.appointment = {}
	s.outcome = {}
	refresh()
	last_summary.merge(result, true)
	if first_clear: begin_story("day3", a.case)
	queue_day_transition(day(), int(a.intake_day))
	return true

static func due(g: RefCounted) -> bool:
	var a: Dictionary = g.advanced_referral_facts.get("appointment", {})
	if a.is_empty(): return false
	var outcome: Dictionary = g.advanced_referral_facts.get("outcome", {})
	return g.day_number() >= int(a.review_day if not outcome.is_empty() else a.operation_day)

static func reserved(g: RefCounted, first: int, last: int) -> bool:
	var a: Dictionary = g.advanced_referral_facts.get("appointment", {})
	if a.is_empty(): return false
	for target in [a.operation_day, a.review_day]:
		if int(target) >= first and int(target) <= last: return true
	return false

static func conflicts_event(g: RefCounted, definition: Dictionary) -> bool:
	var length := maxi(1, int(definition.get("duration_days", 1)))
	length = preload("res://godot/systems/chihaya_third_surgery.gd").occupied_days(str(definition.get("id", "")), length)
	if str(definition.get("id", "")) == preload("res://godot/systems/serika_lv4.gd").ID: length = 4
	if str(definition.get("id", "")) == preload("res://godot/systems/miyuki_lv2.gd").A: length = 2
	return reserved(g, g.day_number(), g.day_number() + length - 1)
