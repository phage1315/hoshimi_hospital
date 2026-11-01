extends SceneTree
const P = preload("res://godot/systems/advanced_presentation.gd")
const C = preload("res://godot/systems/advanced_referral.gd")
const F = preload("res://godot/systems/advanced_referral_facts.gd")
var app
var checks := 0
var failures := 0
var captures: Array = []
func _initialize() -> void: call_deferred("run")
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
func view(): return app.page.get_node("AdvancedReferralView")
func click(id: String) -> void:
	var node = view().body.find_child(id, true, false)
	expect(node is Button and not node.disabled, "Usable " + id)
	if node is Button and not node.disabled: node.pressed.emit()
func capture(id: String) -> void:
	if "--native" not in OS.get_cmdline_user_args(): return
	await RenderingServer.frame_post_draw
	var path := "/tmp/advanced_random_%s.png" % id
	root.get_texture().get_image().save_png(path)
	captures.append(path)
func pool_checks() -> void:
	var ids := P.random_patient_ids(app.game)
	expect(ids.size() == app.game.patient_definitions.size(), "All registered random patients eligible")
	expect(ids == P.random_patient_ids(), "Offline registry equals game registry")
	var a = C.new(app.game, true)
	var b = C.new(app.game, true)
	a.state().procedures["surgery_open_whipple"] = "CLEARED"
	b.state().procedures["surgery_open_whipple"] = "CLEARED"
	var seen := {}
	for week in range(512):
		a.demo_day = week * 7 + 1; b.demo_day = a.demo_day
		a.refresh(); b.refresh()
		expect(a.state().replays == b.state().replays, "Seeded board deterministic")
		for record in a.state().replays:
			expect(record.patient_id in ids, "Replay stores actual registered patient")
			seen[record.patient_id] = true
		expect(F.valid(a.state()), "Persistent facts whitelist unchanged")
		var restored: Dictionary = JSON.parse_string(JSON.stringify(a.state()))
		expect(restored.replays == a.state().replays, "Roundtrip preserves assigned patient")
	expect(seen.size() == ids.size(), "Seeded sample reaches every patient")
	var old := {"id":"advanced_replay_4_surgery_open_whipple", "procedure_id":"surgery_open_whipple", "patient_id":"placeholder_patient_4_0", "replay":true}
	expect(P.patient_id(old, app.game) == P.LEGACY_PATIENTS[posmod(hash(str(old.id)), 3)], "Legacy placeholder identity retained")
	app.game.patient_definitions.append({"id":"future_registry_fixture"})
	expect("future_registry_fixture" in P.random_patient_ids(app.game), "New registry entries automatically join pool")
	for id in ids:
		expect(P.patient_id({"id":"stable", "patient_id":id, "replay":true}, app.game) == id, "Pool growth preserves stored patient")
	app.game.patient_definitions.pop_back()
func prepare(id: String) -> void:
	app.advanced_controller = null
	app.show_advanced_referral(true)
	var c = app.advanced_controller
	var record := {"id":"qa_replay_" + id, "procedure_id":"surgery_open_whipple", "patient_id":id, "replay":true}
	c.state().week = 0
	c.state().replays = [record]
	view().record = record
	expect(c.accept(record, P.DEFAULT_TEAM), "Replay accepted " + id)
	c.demo_day = 2
	expect(c.start_operation(), "Replay starts " + id)
	view().render()
func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/tmp/advanced_random_unused_%s.json" % OS.get_process_id()
	root.add_child(app); await process_frame
	pool_checks()
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		var before: Dictionary = app.game.snapshot()
		for id in P.random_patient_ids(app.game):
			prepare(id); await process_frame
			var c = app.advanced_controller
			var patient: Dictionary = P.patient(c.state().appointment.case, app.game, locale == "en")
			var overlay = app.page.get_node_or_null("GeneralAnesthesiaSplash")
			expect(overlay != null, "Required splash appears " + id)
			if overlay == null: continue
			var cg = overlay.find_child("GeneralAnesthesiaSplashCG", true, false)
			expect(cg.texture != null and cg.texture.resource_path == "res://" + patient.visuals.portraits["splash/general_anesthesia"], "Own splash loaded " + id)
			if locale == "zh_CN" and id in ["patient_yuffie_kisaragi", "patient_doa_kasumi"]: await capture(id + "_splash")
			overlay.find_child("AnesthesiaSplashContinue", true, false).pressed.emit(); await process_frame
			var card = app.page.get_node_or_null("AdvancedCast")
			expect(card != null and card.get_meta("actor_id") == id, "Ready actor matches patient " + id)
			if card != null:
				expect(card.get_meta("portrait_path") == patient.visuals.portraits["intraoperative/anesthetized"], "Own anesthesia portrait " + id)
				expect(card.get_node("AdvancedActorPortrait").texture != null, "Portrait loaded " + id)
				expect(str(patient.name) in str(card.get_meta("source_text")), "Ready line names correct patient")
			expect(view().body.find_child("AdvancedTeamPatientTable", true, false) == null, "Replay does not borrow first patient's table")
			if locale == "zh_CN" and id == "patient_yuffie_kisaragi": await capture(id + "_ready")
			click("begin_timeout")
			for i in range(7): click("confirm_member")
			expect(c.session.team_intro_index == -1 and not c.session.splash_pending and not c.session.patient_ready_pending, "Reaches surgery without presentation deadlock")
			await process_frame
		expect(app.game.snapshot() == before, "Dev tests leave campaign unchanged")
	# Broken external/mod data must not deadlock; registry contract separately rejects it.
	for broken in ["", "assets/nonexistent_anesthesia_qa.png"]:
		prepare("patient_yuffie_kisaragi"); await process_frame
		var c = app.advanced_controller
		var overlay = app.page.get_node_or_null("GeneralAnesthesiaSplash")
		if overlay != null: app.page.remove_child(overlay); overlay.queue_free()
		var portraits: Dictionary = app.game.patient_definition("patient_yuffie_kisaragi").visuals.portraits
		var original: String = portraits["splash/general_anesthesia"]
		portraits["splash/general_anesthesia"] = broken
		view().render()
		expect(not c.session.splash_pending and view().body.find_child("begin_timeout", true, false) != null, "Missing splash safely reaches patient ready")
		portraits["splash/general_anesthesia"] = original
	var report := {"checks":checks, "failures":failures, "captures":captures}
	var f := FileAccess.open("/tmp/advanced_random_report.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "  ")); f.close()
	print("ADVANCED RANDOM PATIENTS: ", JSON.stringify(report))
	quit(1 if failures else 0)
