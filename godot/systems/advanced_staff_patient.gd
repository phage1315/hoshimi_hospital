extends "res://godot/systems/advanced_referral.gd"
## Entire episode is volatile; only Day 3 writes final facts. Shared OR runner.
const StaffFacts = preload("res://godot/systems/advanced_staff_patient_facts.gd")
const Registry = preload("res://godot/systems/staff_patient_registry.gd")
var actor_id := ""
var episode_active := false
var night_choice := false
var first_night := true
var replacement_actor := ""
var night_started := 0
var transition_pending := false
var texts: Dictionary = {}

func _init(g: RefCounted, actor: String, testing: bool = false) -> void:
	super(g, testing)
	actor_id = actor
	texts = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/staff_patient/stories.json"))
	local_facts.cooldowns = g.advanced_referral_facts.get("cooldowns", {}).duplicate(true)

func state() -> Dictionary: return local_facts
func refresh() -> void: pass
func eligible() -> bool:
	if episode_active: return true
	return actor_id in texts.actors and game.staff_patient_unlocked(actor_id) and game.free_h_unlocked(actor_id) and game.story_flag("staff_as_patient_program_authorized") and game.story_flag("sayaka_lv5_part_c_complete")

func board() -> Array:
	var offers: Array = []
	if not eligible(): return offers
	var manifest: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/release_manifest.json"))
	for row in manifest:
		var id := str(row.procedure_id)
		if row.category != "ADVANCED_REGULAR" or not row.runtime_ready: continue
		if game.advanced_referral_facts.get("procedures", {}).get(id, "") != "CLEARED": continue
		offers.append({"id": "advanced_staff_" + actor_id + "_" + id, "procedure_id": id, "patient_id": actor_id, "staff_patient_id": actor_id, "replay": true})
	return offers

func date_blocked(target: int) -> bool:
	if target >= game.FINAL_WEEK_START_DAY or target > game.GAME_DURATION_DAYS: return true
	var timing: Dictionary = game.advanced_referral_timing_status({"duration_days": 1, "priority": 0}, target)
	if timing.status != "available": return true
	if target != day() and int(game.free_h_booking.get("workday", -1)) == target: return true
	return preload("res://godot/systems/miyuki_lv2.gd").booked_day(game) == target

func schedule() -> Dictionary:
	if episode_active: return local_facts.appointment.duplicate(true)
	if not game.is_routine_workday(day()) or game.current_absolute_clock() > 960 or date_blocked(day()): return {}
	if not game.is_routine_workday(day() + 1) or date_blocked(day() + 1): return {}
	for target in range(day() + 2, mini(game.FINAL_WEEK_START_DAY, day() + 15)):
		if date_blocked(target): return {}
		if game.is_routine_workday(target): return {"intake_day": day(), "operation_day": day()+1, "review_day": target}
	return {}

func candidates(role: String, operation_day: int) -> Array:
	return super.candidates(role, operation_day).filter(func(p): return str(p.id) != actor_id)

func booking_conflict() -> String:
	var b: Dictionary = game.free_h_booking
	if int(b.get("workday", -1)) == day() and str(b.get("actor_id", "")) != actor_id: return str(b.get("actor_id", ""))
	return ""

func accept(record: Dictionary, selected: Dictionary) -> bool:
	if episode_active or not game.active_advanced_staff_patient.is_empty() or not game.advanced_referral_facts.get("appointment", {}).is_empty() or not game.can_invite_staff_patient(actor_id):
		error = "unavailable"
		return false
	var conflict := booking_conflict()
	if not conflict.is_empty() and conflict != replacement_actor:
		error = "staff_booking_conflict"
		return false
	if not super.accept(record, selected): return false
	if int(game.free_h_booking.get("workday", -1)) == day(): game.cancel_free_h_booking()
	episode_active = true
	game.active_advanced_staff_patient = actor_id
	game.active_mode = "advanced_story"
	first_night = not bool(game.advanced_staff_patient_facts.get("actors", {}).get(actor_id, {}).get("night_seen", false))
	story_record = record.duplicate(true)
	chapter("consult")
	return true

func begin_story(_phase: String, _record: Dictionary) -> void:
	pass # Selecting a procedure never starts or consumes the episode.

func chapter(phase: String) -> void:
	var authored: Dictionary = texts.actors[actor_id]
	var source: Dictionary = authored if first_night else texts.repeat
	var rows: Array = source.get(phase, []).duplicate(true)
	if phase == "consult" and first_night: rows = texts.common.duplicate(true) + rows
	if phase in ["success", "failure"] and not texts.get("ending", {}).is_empty():
		rows.append(texts.ending.duplicate(true))
	story_content = {phase: {"title": authored.title, "title_en": authored.title_en, "background": "player_office" if phase == "consult" else "ward", "portrait": "ward", "lines": rows, "dark": phase == "dark", "private": phase in ["night", "dark", "after"]}}
	# Undressing ends the first night chapter; later dialogue uses the existing
	# shoulder portrait. The separate timed blackout renders no portrait.
	if phase in ["dark", "after"]: story_content[phase].portrait = "h_neutral"
	if phase in ["night", "dark", "after"]: story_content[phase].background = "ward_night"
	story_phase = phase
	story_index = 0
	game.active_mode = "advanced_story"

func finish_story() -> void:
	var phase := story_phase
	story_phase = ""
	match phase:
		"consult":
			game.advance_story_to_day(int(local_facts.appointment.intake_day), maxi(game.current_absolute_clock(), 1080))
			night_choice = true
		"night":
			if first_night: chapter("dark")
			else: transition_pending = true
		"dark": transition_pending = true
		"after": launch_day2()
		"success", "failure": settle()

func complete_night_transition() -> void:
	if not transition_pending: return
	transition_pending = false
	finish_night_time()
	chapter("after")

func choose_night(watch: bool) -> void:
	if not night_choice: return
	night_choice = false
	night_started = game.current_absolute_clock()
	if watch: chapter("night")
	else:
		finish_night_time()
		launch_day2()

func finish_night_time() -> void:
	# The dark dialogue precedes this time jump; skipping uses the same timeline.
	game.advance_story_to_day(int(local_facts.appointment.intake_day), maxi(game.current_absolute_clock(), night_started + 60))

func launch_day2() -> void:
	game.advance_story_to_day(int(local_facts.appointment.operation_day), game.SHIFT_START_MINUTE)
	if dev: demo_day = int(local_facts.appointment.operation_day)
	start_operation()

func start_operation() -> bool:
	if not super.start_operation(): return false
	for role in ["first_assistant", "second_assistant"]:
		game.advanced_referral_facts.cooldowns[str(local_facts.appointment.team[role])] = int(local_facts.appointment.operation_day)+14
	return true

func finish_operation() -> bool:
	if not super.finish_operation(): return false
	game.advance_story_to_day(int(local_facts.appointment.review_day), game.SHIFT_START_MINUTE)
	chapter("success" if local_facts.outcome.success else "failure")
	queue_day_transition(int(local_facts.appointment.review_day), int(local_facts.appointment.intake_day))
	return true

func multiplier() -> float:
	var successes := int(game.advanced_staff_patient_facts.get("actors", {}).get(actor_id, {}).get("procedures", {}).get(str(local_facts.appointment.case.procedure_id), {}).get("successes", 0))
	return 1.0 if successes == 0 else 0.5 if successes == 1 else 0.0

func settle() -> bool:
	if not episode_active or not story_phase.is_empty() or local_facts.outcome.is_empty(): return false
	var a: Dictionary = local_facts.appointment
	var outcome: Dictionary = local_facts.outcome
	var result := {"case_id": a.case.id, "procedure_id": a.case.procedure_id, "success": outcome.success, "surgery_xp": 0, "leadership_xp": 0.0, "reputation": 0, "day": day(), "minutes": int(a.intake_minutes)+60+int(outcome.minutes)+60}
	if outcome.success: result.merge(Settlement.new().settle(game, Model.procedure(str(a.case.procedure_id)), a.team, multiplier(), true), true)
	game.time_log.append({"id": "advanced_staff_review_" + actor_id, "start": game.elapsed(), "minutes": 60})
	var persistent := StaffFacts.clean(game.advanced_staff_patient_facts)
	if not persistent.actors.has(actor_id): persistent.actors[actor_id] = {"night_seen": true, "procedures": {}}
	var actor: Dictionary = persistent.actors[actor_id]
	actor.night_seen = true
	var previous: Dictionary = actor.procedures.get(str(a.case.procedure_id), {})
	actor.procedures[str(a.case.procedure_id)] = {"successes": int(previous.get("successes",0)) + (1 if outcome.success else 0), "attempts": int(previous.get("attempts",0))+1, "last_day": day(), "last_success": outcome.success, "last_minutes": result.minutes}
	game.advanced_staff_patient_facts = persistent
	last_summary.merge(result, true)
	local_facts.appointment = {}; local_facts.outcome = {}
	episode_active = false
	game.active_advanced_staff_patient = ""
	game.active_mode = "advanced_board"
	return true
