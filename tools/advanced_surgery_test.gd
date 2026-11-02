extends SceneTree
const Model = preload("res://godot/systems/advanced_surgery_model.gd")
const Session = preload("res://godot/systems/advanced_surgery_session.gd")
const Referral = preload("res://godot/systems/advanced_referral.gd")
const Facts = preload("res://godot/systems/advanced_referral_facts.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Content = preload("res://godot/scripts/content_loader.gd")
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run")

func new_game() -> RefCounted:
	var content := Content.new()
	expect(content.load_all(), "Content loads")
	var c: Dictionary = content.collections
	var g := Game.new()
	g.configure(c.encounters, c.preops, c.staff, c.time_events, c.surgeries, c.patients, c.relationships, c.character_events, c.case_templates, c.micro_events, c.examination_cg_pools, c.surgery_team_dialogue_profiles, c.patient_interactions, c.temporary_conditions, c.staff_role_cg_rewards, c.special_events, c.special_event_steps, c.date_profiles, c.date_locations, c.advanced_referral_cases, c.first_surgery_diagnosis_reactions, c.palpation_profiles, c.awake_special_barks)
	return g

func no_inner(value: Variant) -> void:
	if value is Dictionary:
		for key in value:
			expect(key not in ["current_stage_id", "stage_id", "index", "hp", "operative_reserve_hp", "journal", "rng_seed", "resolved_random_choices", "staff_skill_snapshot", "used", "pending_rescue", "choices", "phase"], "No runner state in facts: " + str(key))
			no_inner(value[key])
	elif value is Array:
		for item in value: no_inner(item)

func drive(s: RefCounted, planned: bool = true) -> void:
	s.splash_pending = false; s.patient_ready_pending = false; s.team_intro_index = -1
	var plan := Model.plan(s.definition, s.team)
	var p := 0
	for _guard in range(150):
		if s.finished: break
		if s.in_crisis():
			expect(s.resolve_crisis("pause_and_stabilize"), "Crisis resolves through existing resolver")
		elif s.pending_rescue:
			expect(s.rescue(0), "Self-correction resolves failure once")
		elif s.awaiting_ack:
			expect(s.acknowledge(), "Acknowledgement advances")
		else:
			var step: Dictionary = s.current()
			var who := int(plan[p]) if planned and step.kind == "P" else 0
			if step.kind == "P": p += 1
			expect(s.act(who, "standard" if not s.strategy_options().is_empty() else ""), "Stage action accepted")
			var hp: int = s.hp
			expect(not s.act(who) and s.hp == hp, "Duplicate action cannot charge or reroll")
	expect(s.finished, "Session reaches a terminal outcome")
	expect(s.used[0] <= 2 and s.used[1] <= 2, "Independent intervention caps")

func formulas() -> void:
	var sums := [41, 41, 36]
	var lengths := [13, 12, 11]
	for ci in range(3):
		var d: Dictionary = Model.catalog()[ci]
		var total := 0
		for step in d.steps: total += int(step.hp_base)
		expect(total == sums[ci] and d.steps.size() == lengths[ci], "Authored stage counts and baseline HP")
		for t in Model.fixtures(d.id):
			var choices := Model.plan(d, t)
			var used := [0, 0]
			var p := 0
			for step in d.steps:
				if step.kind != "P": continue
				var who := int(choices[p]); p += 1
				if who > 0:
					expect(Model.can_use(t.assistants[who - 1], used[who - 1], step), "DP plan respects specialty / second use")
					used[who - 1] += 1
				for skill in [0, 50, 80, 90, 100, 999]:
					var chance := Model.probability(skill, step, t, true)
					expect(chance >= .08 and chance <= .985, "Probability clamps")
					expect(Model.nurse_bonus(t, step.specialty_tag) <= .05, "Scrub bonus cap")
			for seed_value in range(12): drive(Session.new(d, t, seed_value, [], {}, true))
	var step: Dictionary = Model.catalog()[0].steps[4]
	var specialist := {"skill": 90, "specialties": ["vascular"]}
	expect(Model.can_use(specialist, 1, step), "Matching expert second action")
	specialist.skill = 89
	expect(not Model.can_use(specialist, 1, step), "Surgery 89 cannot act twice")
	specialist.skill = 90; specialist.specialties = ["pelvic"]
	expect(not Model.can_use(specialist, 1, step), "Mismatched expert cannot act twice")
	var d: Dictionary = Model.catalog()[0]
	var t: Dictionary = Model.fixtures(d.id)[0]
	# Force a reproducible failed attending attempt and verify the rescue branch.
	for seed_value in range(50):
		var s := Session.new(d, t, seed_value, [], {}, true)
		s.index = 2
		s.act(0)
		if not s.pending_rescue: continue
		var hp: int = s.hp
		expect(s.rescue(1), "Low-success assistant rescue is still selectable")
		var delta: int = hp - s.hp
		expect(delta in [ceili(12.0 * .42) + 2, 15], "Rescue only charges correction cost")
		expect(s.used[0] == 1 and not s.rescue(2), "No chained rescues")
		break

func integration() -> void:
	var g := new_game()
	var c := Referral.new(g)
	expect(not c.eligible(), "Production gate remains closed")
	g.surgery_xp = g.surgery_xp_for_level(88)
	g.archived_player_effects.reputation = 300
	g.special_event_completion_counts["advanced_referral_tutorial_chisato"] = 1
	g.special_event_completion_days["advanced_referral_tutorial_chisato"] = 3
	g.set_story_flag("advanced_referral_random_cases_enabled", true)
	for person in g.staff: g.relation_for(person.id).met = true
	# No unrelated authored events in this independent scheduling fixture.
	g.special_event_definitions.clear()
	g.set_test_time(15, 540)
	expect(c.eligible(), "Production gate accepts tutorial + stats")
	var dates: Dictionary = c.schedule()
	expect(not dates.is_empty(), "Three free dates can be scheduled")
	if dates.is_empty(): return
	var selected := {}
	for role in Referral.ROLES:
		for person in c.candidates(role, dates.operation_day):
			if person.id not in selected.values():
				selected[role] = person.id
				break
	expect(c.valid_team(selected, dates.operation_day), "Seven canonical eligible staff")
	if selected.size() != 7: return
	var original: Dictionary = selected.duplicate()
	selected.second_assistant = selected.first_assistant
	expect(not c.valid_team(selected, dates.operation_day), "Duplicate staff rejected")
	selected = original
	var record: Dictionary = c.board()[0]
	var before: int = g.elapsed()
	expect(c.accept(record, selected), "Day 1 accepts canonical team")
	expect(g.elapsed() == before + 60 and not c.accept(record, selected), "Intake paid once, one active case")
	var saved: Dictionary = g.snapshot()
	expect(not saved.is_empty() and Facts.valid(saved.advanced_referral_facts), "Scheduled safe-boundary save")
	no_inner(saved.advanced_referral_facts)
	var clock: int = g.elapsed()
	expect(g.restore(saved) and g.elapsed() == clock, "Booking roundtrip preserves time")
	c = Referral.new(g)
	g.advance_story_to_day(dates.operation_day, 540)
	expect(Referral.due(g), "Appointment due at actual date")
	expect(c.start_operation(), "Day 2 creates actual physiology session")
	expect(g.snapshot().is_empty(), "No saving active Advanced surgery")
	var cool: Dictionary = c.state().cooldowns
	expect(cool[selected.first_assistant] == dates.operation_day + 14 and cool[selected.second_assistant] == dates.operation_day + 14, "Participation starts both 14-calendar-day cooldowns")
	expect(not c.valid_team(selected, dates.operation_day + 13) and c.valid_team(selected, dates.operation_day + 14), "Cooldown expires exactly on day +14")
	expect(g.staff_can_join_surgery_team(selected.first_assistant), "Advanced cooldown does not block ordinary surgery")
	drive(c.session)
	expect(c.finish_operation() and not c.finish_operation(), "Day 2 result commits once")
	g.active_mode = "encounter"
	saved = g.snapshot(); clock = g.elapsed()
	expect(not saved.is_empty(), "Settled operation outcome saves at map boundary")
	no_inner(saved.advanced_referral_facts)
	var attrs: Dictionary = g.player_attributes()
	expect(g.restore(saved) and g.elapsed() == clock and g.player_attributes() == attrs, "Outcome roundtrip does not rerun surgery")
	c = Referral.new(g)
	g.advance_story_to_day(dates.review_day, 540)
	expect(c.settle() and not c.settle(), "Day 3 settles exactly once")
	c.finish_story()
	g.active_mode = "encounter" # Explicit return to hospital directory in this logic fixture.
	saved = g.snapshot(); clock = g.elapsed(); attrs = g.player_attributes()
	expect(g.restore(saved) and g.elapsed() == clock and g.player_attributes() == attrs, "Reward and time roundtrip")
	var changed: Dictionary = saved.duplicate(true)
	changed.advanced_referral_facts["current_stage_id"] = "W08"
	expect(not g.restore(changed) and g.elapsed() == clock, "Reject persisted inner state atomically")
	# Success reward adapter through existing formulas, including explicit tier caps.
	var rewards := preload("res://godot/systems/advanced_settlement.gd").new()
	g.archived_player_effects.reputation = 590
	var r: Dictionary = rewards.settle(g, Model.catalog()[0], selected)
	expect(r.reputation == 10 and g.player_attributes().reputation == 600, "Advanced hard cap, no Legendary award")
	expect(r.leadership_xp in [4.0, 8.0, 12.0], "Advanced leadership base and six-person multiplier")
	# Replay drawing is weekly, stable and never counts repeated clears as new ones.
	c = Referral.new(g)
	c.state().procedures = {record.procedure_id: "CLEARED"}
	c.state().clear_days[record.procedure_id] = 17
	g.set_test_time(28, 540); c.refresh()
	var replay: Array = c.state().replays.duplicate(true)
	c.refresh(); expect(c.state().replays == replay and replay.size() == 2, "Weekly repeat draw stable")
	g.set_test_time(34, 540); c.refresh(); expect(c.state().replays == replay, "Sunday does not refresh Monday board")
	g.set_test_time(35, 540); c.refresh(); expect(c.state().replays != replay, "Monday refresh")
	expect(not g.story_flag("kaori_advanced_prerequisite_met") and not g.story_flag("ray_legendary_prerequisite_met"), "Three-case prototype does not unlock five/ten-clear quests")

func balance() -> void:
	var results := []
	var target := [[.474, .862, .877, .995], [.350, .721, .777, .978], [.651, .953, .933, .997]]
	for ci in range(3):
		var d: Dictionary = Model.catalog()[ci]
		for ti in range(4):
			var est := Model.estimate(d, Model.fixtures(d.id)[ti], 25000, 20261030 + ci * 1000000 + ti * 10000 + 200)
			expect(absf(float(est.rate) - float(target[ci][ti])) <= .03, "25k HP-only baseline within 3pp: %s / %s" % [ci, ti])
			results.append({"procedure_id": d.id, "fixture": ti, "rate": est.rate, "plan": est.plan})
	var f := FileAccess.open("/tmp/hoshimi_advanced_godot_baseline.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(results, "  ")); f.close()

func edge_cases() -> void:
	var g := new_game()
	var c := Referral.new(g, true)
	c.fixture_mode = true
	var roster := {}
	for role in Referral.ROLES: roster[role] = "fixture_" + role
	var record: Dictionary = c.board()[0]
	expect(c.accept(record, roster) and c.error.is_empty(), "Accept clears stale error")
	var booking: Dictionary = c.state().appointment.duplicate(true)
	c.demo_day = 7; c.refresh()
	expect(c.state().appointment == booking, "Weekly refresh preserves active appointment")
	c.demo_day = int(booking.operation_day)
	expect(c.start_operation(), "Failure fixture starts")
	c.session.hp = 1
	expect(c.session.act() and c.session.finished and c.session.hp == 0, "HP depletion clamps and ends immediately")
	expect(not c.session.acknowledge() and not c.session.act(), "Cannot continue after HP failure")
	c.finish_operation(); c.settle()
	expect(c.state().procedures[record.procedure_id] == "FAILED_LOCKED", "First failure locks procedure")
	c.demo_day = 35; c.refresh()
	for offer in c.board(): expect(offer.procedure_id != record.procedure_id, "Locked procedure never returns")
	c.state().procedures[record.procedure_id] = "CLEARED"
	c.state().clear_days[record.procedure_id] = 35
	c.demo_day = 42; c.refresh()
	var replay: Dictionary = c.state().replays[0]
	expect(replay.patient_id != record.patient_id and replay.replay, "Replay uses distinct placeholder patient")
	expect(c.accept(replay, roster), "Replay remains playable")
	c.demo_day += 1; c.start_operation(); c.session.hp = 1; c.session.act()
	c.finish_operation(); c.settle()
	expect(c.state().procedures[record.procedure_id] == "CLEARED", "Replay failure preserves clearance")
	c.demo_day = 49; c.refresh()
	expect(c.state().replays.size() == 2, "Failed replay remains in next week's pool")
	var d: Dictionary = Model.catalog()[0]
	var t: Dictionary = Model.fixtures(d.id)[2]
	var session := Session.new(d, t, 123, [], {}, true)
	var rng_before: int = session.rng.state
	Model.estimate(d, t)
	expect(session.rng.state == rng_before and session.index == 0, "Preview does not consume live RNG")
	var rescue_results := [false, false]
	for seed_value in range(100):
		var s := Session.new(d, t, seed_value, [], {}, true)
		s.index = 2; s.act()
		if not s.pending_rescue: continue
		var before: int = s.hp
		s.rescue(1)
		var won: bool = s.last_result.rescue_success
		rescue_results[1 if won else 0] = true
		expect(before - s.hp == (8 if won else 15), "Both rescue outcomes match formula, without recharging base")
		expect(s.used[0] == 1 and not s.rescue(2), "Successful or failed rescue consumes one use")
		if rescue_results[0] and rescue_results[1]: break
	expect(rescue_results[0] and rescue_results[1], "Both rescue branches exercised")
	# Unknown IDs must not inflate category-specific quest gates.
	g = new_game(); c = Referral.new(g)
	for i in range(10): c.state().procedures["future_fixture_%s" % i] = "CLEARED"
	preload("res://godot/systems/advanced_referral_rules.gd").update_gates(g, c.state())
	expect(not g.story_flag("kaori_advanced_prerequisite_met") and not g.story_flag("ray_legendary_prerequisite_met"), "Unregistered clears do not unlock quests")
	# Calendar collision keeps candidate and clock; late booking can be rescheduled.
	g = new_game(); c = Referral.new(g)
	g.surgery_xp = g.surgery_xp_for_level(88); g.archived_player_effects.reputation = 300
	g.special_event_completion_counts["advanced_referral_tutorial_chisato"] = 1
	g.special_event_completion_days["advanced_referral_tutorial_chisato"] = 3
	g.set_story_flag("advanced_referral_random_cases_enabled", true)
	for person in g.staff: g.relation_for(person.id).met = true
	g.special_event_definitions.clear(); g.set_test_time(15, 780)
	var dates: Dictionary = c.schedule()
	var selected := {}
	for role in Referral.ROLES:
		for person in c.candidates(role, dates.operation_day):
			if person.id not in selected.values(): selected[role] = person.id; break
	g.free_h_booking = {"workday": dates.operation_day}
	var before: int = g.elapsed()
	var offer: Dictionary = c.board()[0]
	expect(not c.accept(offer, selected) and c.board().has(offer) and g.elapsed() == before, "Calendar conflict does not consume time or case")
	g.free_h_booking.clear()
	expect(c.accept(offer, selected) and g.elapsed() == before + 60, "Afternoon intake advances exactly one hour")
	g.advance_story_to_day(dates.operation_day, 600)
	expect(not c.start_operation(), "Late start cannot exceed full-day operating window")
	before = g.elapsed()
	expect(c.rebook(selected) and g.elapsed() == before, "Rescheduling preserves paid intake time")
	expect(c.state().appointment.operation_day > dates.operation_day, "Late booking moves forward only")

func run() -> void:
	formulas()
	integration()
	edge_cases()
	if "--balance" in OS.get_cmdline_user_args(): balance()
	print("ADVANCED SURGERY: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
