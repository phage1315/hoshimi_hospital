extends SceneTree
const Model = preload("res://godot/systems/advanced_surgery_model.gd")
var app
var checks := 0
var failures := 0
var native := false
var captures: Array = []
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run")
func view(): return app.page.get_node("AdvancedReferralView")
func click(id: String) -> void:
	var b = view().body.find_child(id, true, false)
	expect(b is Button and not b.disabled, "Visible usable button: " + id)
	if b is Button and not b.disabled: b.pressed.emit()
	if not app.advanced_controller.day_transition.is_empty():
		expect(view().get_node_or_null("AdvancedDayTransition") != null, "Production cross-day card visible")
		view().finish_day_transition()
	while not app.advanced_controller.story_phase.is_empty():
		app.advanced_controller.advance_story();view().render()
func capture(name: String) -> void:
	if not native: return
	await RenderingServer.frame_post_draw
	var path := "/tmp/hoshimi_advanced_%s.png" % name
	root.get_texture().get_image().save_png(path)
	captures.append(path)
func run() -> void:
	native = "--native" in OS.get_cmdline_user_args()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/tmp/advanced_ui_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Localized content loaded")
		app.configure_game_content()
		var before: Dictionary = app.game.snapshot()
		app.show_event_test_hub()
		await process_frame
		var hub_button = app.page.find_child("AdvancedSurgeryTestEntry", true, false)
		expect(hub_button is Button, "Test hub entry exists")
		hub_button.pressed.emit()
		app.advanced_controller.fixture_mode = true
		await process_frame
		await capture(locale + "_board")
		for definition in Model.catalog():
			if not preload("res://godot/systems/advanced_referral_rules.gd").procedure_ready(str(definition.id)): continue
			app.advanced_controller.fixture_mode = not Model.fixtures(str(definition.id)).is_empty()
			click("case_advanced_first_" + str(definition.id))
			await process_frame
			var v = view()
			if app.advanced_controller.fixture_mode:
				v.body.get_node("FixturePicker").select(2)
				v.body.get_node("FixturePicker").item_selected.emit(2)
			await process_frame
			expect(not v.risk_label.text.is_empty(), "Localized risk preview populated")
			await capture(locale + "_team_" + str(definition.id))
			click("accept"); await process_frame
			click("jump"); await process_frame
			click("start"); await process_frame
			var s = app.advanced_controller.session
			expect(s != null, "UI starts operation")
			if s == null: break
			if s.splash_pending:
				app.page.get_node("GeneralAnesthesiaSplash").find_child("AnesthesiaSplashContinue", true, false).pressed.emit()
				await process_frame
			if s.patient_ready_pending: click("begin_timeout")
			while s.team_intro_index >= 0:
				click("confirm_member"); await process_frame
			var choices: Array = Model.plan(s.definition, s.team)
			var p := 0
			for guard in range(120):
				if s.finished: break
				if s.in_crisis(): click("pause_and_stabilize")
				elif s.pending_rescue: click("correct")
				elif s.awaiting_ack: click("continue")
				elif s.current().kind == "P":
					await capture(locale + "_precision_" + str(definition.id)) if p == 0 else process_frame
					var who := int(choices[p]); p += 1
					click("operate" if who == 0 else "delegate_%s" % who)
				else: click("strategy_standard" if not s.strategy_options().is_empty() else "standard" if s.current().kind == "S" else "continue")
				await process_frame
				expect(view().body.size.x <= 1180, "No horizontal overflow")
			expect(s.finished, "All stages reach result through UI controls")
			click("finish"); await process_frame
			click("settle"); await process_frame
			while app.advanced_controller.failure_dialogue_index >= 0:
				click("failure_next"); await process_frame
			await capture(locale + "_settled_" + str(definition.id))
			expect(app.game.snapshot() == before, "Dev flow leaves campaign values and saves unchanged")
			click("new"); await process_frame
		app.exit_advanced_referral(); await process_frame
		expect(app.screen == "event_test_hub", "Exit returns to event test hub")
	# Exercise formal map entry and real physiology UI, including a guaranteed crisis.
	app.content.load_all("zh_CN"); app.configure_game_content()
	app.game.surgery_xp = app.game.surgery_xp_for_level(88)
	app.game.archived_player_effects.reputation = 300
	app.game.set_story_flag("advanced_referral_random_cases_enabled", true)
	app.game.special_event_completion_counts["advanced_referral_tutorial_chisato"] = 1
	app.game.special_event_completion_days["advanced_referral_tutorial_chisato"] = 3
	for person in app.game.staff: app.game.relation_for(person.id).met = true
	app.game.special_event_definitions.clear()
	app.game.set_test_time(15, 540)
	app.show_advanced_referral(false); await process_frame
	click("case_advanced_first_surgery_open_whipple"); await process_frame
	expect(not app.game.can_save_progress(), "Day 1 story returns to non-saveable team formation")
	var used: Array = []
	for role in app.advanced_controller.ROLES:
		var picker: OptionButton = view().body.find_child("Team_" + str(role), true, false)
		for i in range(1, picker.item_count):
			var id: String = picker.get_item_metadata(i)
			if id not in used:
				used.append(id); picker.select(i); picker.item_selected.emit(i); break
	await process_frame
	click("accept"); await process_frame
	expect(not app.game.can_save_progress(), "Board is not a save screen")
	app.exit_advanced_referral(); await process_frame
	# Use explicit map without unrelated automatic story prompts in this fixture.
	app.game.active_mode = "encounter"
	var dates: Dictionary = app.game.advanced_referral_facts.appointment
	expect(not app.game.snapshot().is_empty(), "Booked campaign is saveable at boundary")
	app.game.advance_story_to_day(dates.operation_day, 540)
	app.show_map(false); await process_frame
	expect(app.screen == "advanced_referral", "Due appointment intercepts map")
	click("start"); await process_frame
	var overlay = app.page.get_node_or_null("GeneralAnesthesiaSplash")
	if overlay != null:
		overlay.find_child("AnesthesiaSplashContinue", true, false).pressed.emit(); await process_frame
		click("begin_timeout")
	for i in range(7): click("confirm_member"); await process_frame
	var s = app.advanced_controller.session
	var crisis_seen := false
	for guard in range(130):
		if s.finished: break
		if s.in_crisis():
			crisis_seen = true
			await capture("production_crisis")
			# Deterministic test-only rescue roll; production RNG untouched elsewhere.
			s.rng.seed = 1
			click("pause_and_stabilize")
		elif s.pending_rescue: click("correct")
		elif s.awaiting_ack: click("continue")
		else:
			# Ensure one real crisis is presented via its actual trigger/rescue functions.
			if not crisis_seen and s.index == 0:
				s.physiology.maybe_start_physiologic_crisis(0, {"id":"fixture_crisis", "physio_stress":"high"})
				view().render()
			else: click("operate" if s.current().kind == "P" else "strategy_standard" if not s.strategy_options().is_empty() else "standard" if s.current().kind == "S" else "continue")
		await process_frame
	expect(crisis_seen and s.finished, "Live crisis UI and terminal result")
	click("finish"); await process_frame
	app.game.advance_story_to_day(dates.review_day, 540)
	view().render(); await process_frame
	click("settle"); await process_frame
	expect(not app.page.get_node("ExitAdvancedReferral").disabled, "Return button unlocks after Day 3 settlement")
	var report := {"checks":checks,"failures":failures,"native":native,"captures":captures}
	var f := FileAccess.open("/tmp/hoshimi_advanced_ui_%s.json" % ("native" if native else "headless"), FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "  ")); f.close()
	print("ADVANCED UI: ", JSON.stringify(report))
	quit(1 if failures else 0)
