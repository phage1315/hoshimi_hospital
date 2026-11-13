extends "res://tools/advanced_surgery_test.gd"
const StaffReferral = preload("res://godot/systems/advanced_staff_patient.gd")
const View = preload("res://godot/ui/advanced_referral_view.gd")

func calendar_checks(g) -> void:
	g.special_event_definitions.clear()
	var c = Referral.new(g)
	var staff_c = StaffReferral.new(g, "doc_serika")
	for date in ["2025-10-27", "2025-10-28", "2025-10-29", "2025-10-30"]:
		g.set_test_time(g.day_number_for_date(date), 540)
		for controller in [c, staff_c]:
			var dates: Dictionary = controller.schedule()
			expect(dates.get("intake_day", 0) == g.day_number() and dates.get("operation_day", 0) == g.day_number()+1 and dates.get("review_day", 0) == g.day_number()+2, "Consecutive three days starting " + date)
	for date in ["2025-10-31", "2025-11-01", "2025-11-02", "2025-11-03", "2025-04-28", "2025-05-01", "2025-12-29"]:
		g.set_test_time(g.day_number_for_date(date), 540)
		for controller in [c, staff_c]:
			expect(controller.schedule().is_empty(), "Reject Friday/weekend or holiday within episode: " + date)
	g.set_test_time(213, 540)
	g.free_h_booking = {"workday": 215}
	expect(c.schedule().is_empty() and staff_c.schedule().is_empty(), "Saturday review respects existing reservation")
	g.free_h_booking.clear()
	g.set_test_time(213, 961)
	expect(c.schedule().is_empty() and staff_c.schedule().is_empty(), "Insufficient intake time remains blocked")

func legacy_checks(g) -> void:
	g.reset()
	# Model past clinical time, rather than placing >100000 minutes in the
	# debug set_test_time story-time counter (outside its legacy import bound).
	g.archived_clinical_minutes = 213 * g.SHIFT_MINUTES
	var c = Referral.new(g)
	var procedure: Dictionary = Model.procedure("surgery_adv_sleeve_lobectomy")
	var case := {"id":"legacy_calendar_probe", "procedure_id":procedure.id,"patient_id":"patient_sora","replay":true}
	c.state().appointment = {"case":case,"team":View.Presentation.DEFAULT_TEAM.duplicate(),"intake_day":213,"operation_day":214,"review_day":218,"intake_minutes":60}
	# Finished operation fixture; only finalized business facts enter snapshots.
	c.session = Session.new(procedure, Model.fixtures(procedure.id)[0], 123)
	c.session.finished = true
	c.session.success = false
	c.session.physiology.procedure_state.elapsed_time = 500
	var before: int = g.elapsed()
	expect(c.finish_operation(), "Legacy operation finalizes")
	expect(g.day_number() == 218 and g.elapsed() >= before, "Finish advances forward to booked review, not intermediate closed day")
	expect(c.state().appointment.review_day == 218, "Legacy booked date is not rewritten")
	var saved: Dictionary = g.snapshot()
	expect(not saved.is_empty() and g.restore(saved), "Finalized outcome boundary roundtrip: " + g.last_restore_error_key + " / " + g.last_error)
	c = Referral.new(g)
	expect(c.settle(), "Review can settle immediately after operation return")
	var settled: Dictionary = g.snapshot()
	expect(not c.settle() and g.snapshot() == settled, "No double settlement or time charge")

func thursday_episode() -> void:
	var g = new_game()
	g.special_event_definitions.clear()
	g.archived_clinical_minutes = 212 * g.SHIFT_MINUTES
	g.surgery_xp = g.surgery_xp_for_level(88)
	g.archived_player_effects.reputation = 300
	g.special_event_completion_counts["advanced_referral_tutorial_chisato"] = 1
	g.special_event_completion_days["advanced_referral_tutorial_chisato"] = 3
	g.set_story_flag("advanced_referral_random_cases_enabled", true)
	for person in g.staff: g.relation_for(person.id).met = true
	var c = Referral.new(g)
	var team := {}
	for role in Referral.ROLES:
		for person in c.candidates(role, 214):
			if person.id not in team.values():
				team[role] = person.id
				break
	expect(c.accept(c.board()[0], team), "Thursday production intake accepted")
	expect(int(c.state().appointment.review_day) == 215, "Thursday intake books Saturday review")
	g.advance_story_to_day(214, 540)
	expect(c.start_operation(), "Friday production operation starts")
	if c.session == null: return
	c.session.rng.seed = 123
	finish_session(c.session)
	var before: int = g.elapsed()
	expect(c.finish_operation() and g.day_number() == 215 and g.elapsed() >= before, "Actual operation ends on Saturday review, clock forward")
	var saved: Dictionary = g.snapshot()
	expect(not saved.is_empty() and g.restore(saved), "Saturday review facts restore")
	c = Referral.new(g)
	before = g.elapsed()
	expect(c.settle() and g.elapsed() == before + 60, "Saturday settlement costs exactly 60 minutes")
	var xp: int = g.surgery_xp
	var count: int = g.completed_surgeries_total
	expect(not c.settle() and g.elapsed() == before + 60 and g.surgery_xp == xp and g.completed_surgeries_total == count, "Saturday settlement cannot charge or reward twice")

func finish_session(s) -> void:
	s.splash_pending = false
	s.patient_ready_pending = false
	s.team_intro_index = -1
	for _step in range(200):
		if s.finished: break
		if s.operative_dialogue != null:
			for _line in range(100):
				if s.operative_dialogue.current(s).is_empty() or not s.operative_dialogue.advance_sequence(s): break
		var accepted: bool
		if s.in_crisis(): accepted = s.resolve_crisis("pause_and_stabilize")
		elif s.pending_rescue: accepted = s.rescue(0)
		elif s.awaiting_ack: accepted = s.acknowledge()
		else:
			var options: Array = s.strategy_options()
			accepted = s.act(0, str(options[0].id) if not options.is_empty() else "")
		expect(accepted, "Production operation action accepted")
		if not accepted: return
	expect(s.finished, "Production operation reaches finalized outcome")

func waiting_ui(g) -> void:
	# Exact screen state from screenshot, kept only in memory.
	g.reset()
	g.set_test_time(217, 540)
	var c = Referral.new(g)
	c.state().appointment = {"case":{"id":"screen_probe","procedure_id":"surgery_adv_sleeve_lobectomy","patient_id":"patient_sora","replay":true},"team":{},"intake_day":213,"operation_day":214,"review_day":218,"intake_minutes":60}
	c.state().outcome = {"case_id":"screen_probe","success":true,"operation_day":214,"minutes":500}
	for en in [false, true]:
		var v = View.new()
		v.controller = c
		v.english = en
		v.strings = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/ui_text.json"))
		v.body = VBoxContainer.new()
		v.add_child(v.body)
		v.render_booking()
		expect(v.body.get_node("settle").disabled, "Future review is not granted early")
		expect(not v.body.get_children().any(func(n): return n is Label and n.text == v.tr_key("review")), "Waiting screen does not falsely announce Day 3")
		v.free()

func run() -> void:
	var g = new_game()
	calendar_checks(g)
	legacy_checks(g)
	waiting_ui(g)
	thursday_episode()
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		var store = preload("res://godot/systems/save_store.gd").new()
		store.path = args[0]
		expect(store.read_slot(g), "Read supplied source without writes: " + store.last_error)
		expect(g.day_number()==227 and g.advanced_referral_facts.appointment.is_empty(), "Supplied file is later than screenshot, no pending appointment")
		var records: Array = g.advanced_referral_facts.completed.filter(func(r): return r.case_id == "advanced_replay_30_surgery_adv_sleeve_lobectomy")
		expect(records.size()==1 and int(records[0].day)==218, "Screenshot case already settled exactly once on day 218")
		var saved: Dictionary = g.snapshot()
		var restored = new_game()
		expect(restored.restore(saved) and restored.elapsed()==g.elapsed() and restored.advanced_referral_facts.completed==g.advanced_referral_facts.completed and restored.surgery_xp==g.surgery_xp, "History and time survive restore unchanged")
	print("ADVANCED CALENDAR: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
