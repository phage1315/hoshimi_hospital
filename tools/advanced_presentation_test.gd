extends SceneTree
const Presentation = preload("res://godot/systems/advanced_presentation.gd")
const Dialogue = preload("res://godot/systems/advanced_operative_dialogue.gd")
const Model = preload("res://godot/systems/advanced_surgery_model.gd")
var app
var checks := 0
var failures := 0
var native := false
var captures: Array = []
func _initialize() -> void: call_deferred("run")
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
func view(): return app.page.get_node("AdvancedReferralView")
func click(id: String) -> void:
	var b = view().body.find_child(id, true, false)
	expect(b is Button and not b.disabled, "Usable button " + id)
	if b is Button and not b.disabled: b.pressed.emit()
	while not app.advanced_controller.story_phase.is_empty():
		app.advanced_controller.advance_story();view().render()
func capture(id: String) -> void:
	if not native: return
	await RenderingServer.frame_post_draw
	var path := "/tmp/advanced_cast_%s.png" % id
	root.get_texture().get_image().save_png(path); captures.append(path)
func audit_card(allowed: Array, english: bool) -> void:
	var card = app.page.get_node_or_null("AdvancedCast")
	expect(card != null, "Actor card present")
	if card == null: return
	var id: String = card.get_meta("actor_id")
	if id == "PLAYER" and card.has_meta("dialogue_id"):
		expect(card.get_node("AdvancedActorPortrait").texture == null, "Player dialogue does not borrow a staff portrait")
		return
	expect(id in allowed, "Card is bound to the actual actor")
	var p: Dictionary = Presentation.patient(view().record, app.game, english) if id == "patient_yamauchi_sakura" else app.game.staff_record(id) if id not in Presentation.random_patient_ids(app.game) else app.game.patient_definition(id)
	var path: String = card.get_meta("portrait_path")
	expect(path in p.visuals.portraits.values(), "Portrait belongs to same actor")
	expect(card.get_node("AdvancedActorPortrait").texture != null, "Texture loaded")
	var name_label: Label = card.find_child("AdvancedSpeakerName", true, false)
	expect(str(p.name) in name_label.text, "Displayed name matches actual portrait actor")
	if english:
		var re := RegEx.new(); re.compile("[一-鿿]")
		expect(re.search(str(card.get_meta("source_text"))) == null, "English card has no Chinese fallback")
func run() -> void:
	native = "--native" in OS.get_cmdline_user_args()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/tmp/advanced_cast_unused_%s.json" % OS.get_process_id()
	root.add_child(app); await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Bilingual content")
		app.configure_game_content()
		var before: Dictionary = app.game.snapshot()
		for d in Model.catalog():
			# Each asset/role pass starts fresh so cooldown does not replace the default team.
			app.advanced_controller = null
			app.show_advanced_referral(true); await process_frame
			click("case_advanced_first_" + str(d.id)); await process_frame
			expect(view().body.get_node_or_null("FixturePicker") == null, "Default UI uses real staff, not fixtures")
			audit_card(Presentation.random_patient_ids(app.game) + ["patient_yamauchi_sakura"], locale == "en")
			var selected: Dictionary = view().selected.duplicate()
			var values: Dictionary = app.advanced_controller.values(selected, d.id)
			expect(values.assistants[0].skill == app.game.staff_skill_value(selected.first_assistant, "surgery"), "Real assistant skill")
			for role in Presentation.ROLES:
				view().show_assignment(role)
				audit_card([selected[role]], locale == "en")
			await capture(locale + "_team")
			click("accept"); await process_frame
			click("jump"); await process_frame
			click("start"); await process_frame
			var s = app.advanced_controller.session
			expect(s != null and s.splash_pending and not s.act(), "Splash blocks surgery input")
			var overlay = app.page.get_node_or_null("GeneralAnesthesiaSplash")
			expect(overlay != null, "One induction splash")
			if overlay != null:
				var patient: Dictionary = Presentation.patient(app.advanced_controller.state().appointment.case, app.game, locale == "en")
				var cg: TextureRect = overlay.find_child("GeneralAnesthesiaSplashCG", true, false)
				expect(cg.texture != null and cg.texture.resource_path == "res://" + str(patient.visuals.portraits["splash/general_anesthesia"]), "Correct patient's existing induction splash")
			await capture(locale + "_splash_" + str(d.id))
			if overlay == null: break
			overlay.find_child("AnesthesiaSplashContinue", true, false).pressed.emit(); await process_frame
			click("begin_timeout")
			for i in range(7):
				audit_card([selected[Presentation.ROLES[i]]], locale == "en")
				expect(not str(app.page.get_node("AdvancedCast").get_meta("source_text")).is_empty(), "Every team member has an existing confirmation line")
				if i in [0,2,4]: await capture(locale + "_role_" + str(i))
				click("confirm_member"); await process_frame
			var plan: Array = Model.plan(s.definition, s.team)
			var precision := 0
			for guard in range(150):
				if s.finished: break
				expect(app.page.get_node_or_null("GeneralAnesthesiaSplash") == null, "Induction splash is not repeated")
				audit_card(selected.values(), locale == "en")
				if s.awaiting_ack and not s.in_crisis() and int(s.last_result.get("actor", 0)) > 0:
					var role := "first_assistant" if int(s.last_result.actor) == 1 else "second_assistant"
					var line: Dictionary = s.operative_dialogue.current(s)
					var expected_actor: String = selected[role] if line.is_empty() else str(Dialogue.bind_role(line.speaker_role, selected, s.last_result).id)
					expect(app.page.get_node("AdvancedCast").get_meta("actor_id") == expected_actor, "Result portrait follows retained dialogue speaker; fallback uses actual operator")
				if s.in_crisis(): click("pause_and_stabilize")
				elif s.pending_rescue: click("correct")
				elif s.awaiting_ack: click("continue")
				elif s.current().kind == "P":
					if precision == 0: await capture(locale + "_precision")
					var who := int(plan[precision]); precision += 1
					click("operate" if who == 0 else "delegate_%s" % who)
				else: click("strategy_standard" if not s.strategy_options().is_empty() else "standard" if s.current().kind == "S" else "continue")
				await process_frame
			expect(s.finished, "Real-staff demonstration reaches outcome")
			click("finish"); await process_frame
			click("settle"); await process_frame
			expect(app.game.snapshot() == before, "Presentation test never changes campaign state")
	var report := {"checks":checks,"failures":failures,"captures":captures}
	var f := FileAccess.open("/tmp/advanced_cast_report.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report,"  ")); f.close()
	print("ADVANCED PRESENTATION: ",JSON.stringify(report))
	quit(1 if failures else 0)
