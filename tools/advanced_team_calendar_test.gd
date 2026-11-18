extends SceneTree
const Referral = preload("res://godot/systems/advanced_referral.gd")
const PROCEDURE = "surgery_adv_posttraumatic_thoracolumbar_kyphosis_correction"
const TEAM = {"first_assistant":"doc_aqua", "second_assistant":"doc_emiko", "primary_scrub":"nurse_ange", "secondary_scrub":"nurse_yui", "primary_circulating":"nurse_hiroko", "secondary_circulating":"nurse_haru", "anesthesia":"doc_sakura_anesthesiology"}
var checks := 0
var failures := 0
var app
var native := false
const QA = "res://docs/qa/advanced_intake_2026-11-13"

func expect(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(note)

func _initialize() -> void: call_deferred("run")

func show_team(record: Dictionary) -> Control:
	app.advanced_controller = null
	app.show_advanced_referral(false)
	var view = app.page.get_node("AdvancedReferralView")
	view.record = record
	view.selected = TEAM.duplicate()
	view.render_team()
	return view

func check_panel(view, blocked: bool) -> void:
	var panel = view.team_panel
	expect(panel.confirm.disabled == blocked, "Schedule confirmation follows calendar and team validity")
	if blocked:
		expect(panel.assessment.text == view.tr_key("team_calendar_blocked"), "Calendar conflict is not called incomplete team")
		expect(panel.coverage.text == view.tr_key("team_calendar_hint"), "Bilingual intake rules shown")
	else:
		expect(panel.assessment.text != view.tr_key("team_incomplete") and not panel.root.get_meta("estimate_key").is_empty(), "Available valid team gets HP estimate")
	for label in [panel.assessment, panel.coverage]:
		expect(label.get_line_count() <= label.get_visible_line_count(), "Assessment text fits: " + label.text)

func intake_ui_checks(g) -> void:
	g.surgery_xp = g.surgery_xp_for_level(88)
	g.archived_player_effects.reputation = 500
	g.special_event_completion_counts["advanced_referral_tutorial_chisato"] = 1
	g.special_event_completion_days["advanced_referral_tutorial_chisato"] = 1
	g.set_story_flag("advanced_referral_random_cases_enabled", true)
	for day in range(154,161): # Monday to Sunday
		for minute in [599,600,601]:
			g.set_test_time(day,minute)
			app.advanced_controller = null
			app.show_advanced_referral(false)
			var view = app.page.get_node("AdvancedReferralView")
			await process_frame
			if (day == 154 and minute in [600,601]) or (day == 158 and minute == 599):
				await capture("%s_%d_%d" % [app.content.localizer.locale,day,minute])
			var expected: String = "intake_weekend" if day >= 158 else "intake_too_late" if minute > 600 else ""
			expect(view.controller.intake_time_block_reason() == expected, "Shared time gate %d:%d" % [day,minute])
			var notice = view.body.get_node_or_null("IntakeTimeNotice")
			var choices: Array = view.body.get_children().filter(func(n): return n is Button and str(n.name).begins_with("case_"))
			if expected.is_empty():
				expect(not choices.is_empty() and notice == null, "Allowed intake shows procedure picker")
			else:
				expect(choices.is_empty() and notice != null and notice.text == view.tr_key(expected), "Blocked intake shows localized explanation without picker")
				expect(view.controller.schedule().is_empty(), "Backend rejects blocked intake too")
				var offer: Dictionary = view.controller.board()[0]
				var before: Dictionary = g.snapshot()
				expect(not view.controller.accept(offer,TEAM) and view.controller.error == "calendar" and before == g.snapshot(), "Bypassing UI cannot book or spend time")
	# Booking made at the cutoff must remain accessible after the 60-minute intake.
	g.set_test_time(154,600)
	var c = Referral.new(g)
	var offer: Dictionary = c.board()[0]
	expect(c.accept(offer,TEAM), "A complete team can book at 10:00")
	c.finish_story()
	app.advanced_controller = c
	app.show_advanced_referral(false)
	var view = app.page.get_node("AdvancedReferralView")
	expect(g.current_absolute_clock() == 660 and view.body.get_node_or_null("IntakeTimeNotice") == null and not c.state().appointment.is_empty(), "Existing appointment remains accessible after cutoff")
	g.reset()

func capture(name: String) -> void:
	if not native: return
	await process_frame
	await RenderingServer.frame_post_draw
	expect(root.get_texture().get_image().save_png(QA + "/" + name + ".png") == OK, "Save native screenshot " + name)

func run() -> void:
	native = "--native" in OS.get_cmdline_user_args()
	if native: expect(DisplayServer.get_name() != "headless", "Native display active")
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.title_notice_enabled = false # Isolated layout fixture; startup notice is tested separately.
	app.saves.path = "/private/tmp/petra_unused_%s.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/petra_prefs_%s.cfg" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	var args := Array(OS.get_cmdline_user_args()).filter(func(a): return a != "--native")
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		var g = app.game
		g.reset()
		g.special_event_definitions.clear()
		for person in g.staff:
			g.relation_for(person.id).met = true
			g.relation_for(person.id).level = 1
		var record := {"id":"calendar_fixture", "procedure_id":PROCEDURE, "patient_id":"patient_petra_itta_adult", "replay":false}
		g.set_test_time(152, 540)
		var view = show_team(record)
		expect(view.controller.valid_team(TEAM,153) and view.controller.schedule().is_empty(), "Saturday blocks a valid seven-person team")
		await process_frame
		check_panel(view, true)
		g.advance_story_to_day(154, 540)
		view = show_team(record)
		await process_frame
		check_panel(view, false)
		view.selected.erase("anesthesia")
		view.team_panel.refresh()
		expect(view.team_panel.confirm.disabled and view.team_panel.assessment.text == view.tr_key("team_incomplete"), "Actual missing role retains team error")
		view.selected = TEAM.duplicate()
		view.selected.second_assistant = view.selected.first_assistant
		view.team_panel.refresh()
		expect(view.team_panel.confirm.disabled and view.team_panel.coverage.text == view.tr_key("team_pick_hint"), "Duplicate staff retains team error")
		await intake_ui_checks(g)
		if args.is_empty(): continue
		# Restore actual content before loading the unmodified user attachment.
		app.configure_game_content()
		var store = load("res://godot/systems/save_store.gd").new()
		store.path = args[0]
		expect(store.read_slot(g), "Read attachment without writing: " + store.last_error)
		var c = Referral.new(g)
		expect(g.day_number() == 156 and c.valid_team(TEAM,157), "Attachment Wednesday and screenshot roster eligible")
		var timing: Dictionary = g.advanced_referral_timing_status({"duration_days":1,"priority":0},157)
		expect("chihaya_mizuho_nurse_return" in timing.blocked_by, "Thursday return event blocks operation")
		var offers: Array = c.board().filter(func(r): return r.procedure_id == PROCEDURE)
		expect(offers.size() == 1, "Petra first case remains available")
		if offers.is_empty(): continue
		var before: Dictionary = g.snapshot()
		expect(not c.accept(offers[0],TEAM) and c.error == "calendar", "Acceptance rejected specifically for calendar")
		expect(g.snapshot() == before, "Rejected booking spends no time and changes no facts")
		view = show_team(offers[0])
		await process_frame
		check_panel(view,true)
		await capture(locale + "_petra_conflict")
		# Advancing the date alone does not complete the pending return event.
		g.advance_story_to_day(161,540)
		view = show_team(offers[0])
		await process_frame
		check_panel(view,true)
		var pending: Dictionary = g.advanced_referral_timing_status({"duration_days":1,"priority":0},161)
		expect("chihaya_mizuho_nurse_return" in pending.blocked_by, "Unplayed return event still blocks future intake")
		print("PETRA ",locale," source day156 conflict=chihaya_mizuho_nurse_return; roster valid; pending event remains on day161")

	app.queue_free()
	await process_frame
	print("ADVANCED TEAM CALENDAR: %d checks; %d failures" % [checks,failures])
	quit(1 if failures else 0)
