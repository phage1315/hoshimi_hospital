extends "res://tools/advanced_staff_patient_test.gd"
## Manual, in-memory fixture. Player saves are never loaded or overwritten.
func run() -> void:
	var actor := "doc_serika" if "--serika" in OS.get_cmdline_user_args() else "doc_sayaka"
	var app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/tmp/hoshimi_staff_manual_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	if "--en" in OS.get_cmdline_user_args():
		app.content.load_all("en")
		app.configure_game_content()
	fixture(app.game, actor)
	app.game.advanced_staff_patient_facts = Staff.StaffFacts.fresh()
	app.game.advanced_referral_facts = Facts.fresh()
	app.game.advanced_referral_facts.procedures["surgery_open_whipple"] = "CLEARED"
	app.show_advanced_staff_patient(actor)
	var controller = app.advanced_controller
	expect(controller.accept(controller.board()[0], team(controller)), "Manual entry accepts staff episode")
	app.page.get_node("AdvancedReferralView").render()
	DisplayServer.window_set_title("星见医院 · " + ("芹香" if actor == "doc_serika" else "小夜香") + " · 高级手术患者事件测试")
	if "--smoke" in OS.get_cmdline_user_args():
		await process_frame
		expect(controller.story_phase == "consult", "Manual entry starts consultation")
		expect(not app.game.can_save_progress(), "Event save boundary locked")
		print("STAFF MANUAL ENTRY: ", actor, " / ", checks, " checks; ", failures, " failures")
		quit(1 if failures else 0)
