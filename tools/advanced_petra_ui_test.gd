extends SceneTree
const M = preload("res://godot/systems/advanced_surgery_model.gd")
const S = preload("res://godot/systems/advanced_surgery_session.gd")
const D = preload("res://godot/systems/advanced_operative_dialogue.gd")
const P = preload("res://godot/systems/advanced_presentation.gd")
const Sweat = preload("res://godot/systems/advanced_or_sweat_break.gd")
const ID := "surgery_adv_posttraumatic_thoracolumbar_kyphosis_correction"
const ART_OUT := "res://docs/qa/serika_abdomen_toolbar_2026_11_03"
var art_out := ART_OUT
var checks := 0
var failures := 0
var native := false

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, why: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(why)

func click(page: Control, id: String) -> void:
	var button: Button = page.find_child(id, true, false)
	check(button != null and not button.disabled, "Button available: " + id)
	if button != null and not button.disabled: button.pressed.emit()

func capture(name: String) -> void:
	if not native: return
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path(art_out + "/" + name + ".png")
	check(root.get_texture().get_image().save_png(path) == OK, "Visible capture: " + name)

func run() -> void:
	native = "--native" in OS.get_cmdline_user_args()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): art_out = arg.trim_prefix("--out=")
	if native:
		check(DisplayServer.get_name() != "headless", "Visible Godot renderer")
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(art_out))
	var app: Control = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/tmp/hoshimi_petra_ui_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	app.show_advanced_referral(true)
	var controller: RefCounted = app.advanced_controller
	var view: Control = app.page.get_node("AdvancedReferralView")
	var case_button: Button = app.page.find_child("case_advanced_first_" + ID, true, false)
	check(case_button != null and not case_button.disabled, "Petra appears on the DEV advanced case board")
	if native:
		await capture("board")
		var record := {"id": "advanced_first_" + ID, "procedure_id": ID, "patient_id": "patient_petra_itta_adult", "replay": false}
		controller.begin_story("day3", record)
		controller.story_index = 15 # Patient speaks after the tired-but-relieved narration.
		view.render()
		var postop_card: Control = app.page.get_node("AdvancedCast")
		check(str(postop_card.get_meta("portrait_path")) == "assets/characters/advanced_petra_v1/postop.png", "Day 3 uses postoperative variant")
		check(postop_card.get_node("AdvancedActorPortrait").texture != null, "Day 3 portrait rendered")
		await capture("day3_postop")
		controller.finish_story()
		view.render()
	var roster: Dictionary = P.DEFAULT_TEAM.duplicate(true)
	controller.local_facts.appointment = {"case": {"id": "isolated_petra_ui", "procedure_id": ID, "patient_id": "patient_petra_itta_adult", "replay": false},
		"team": roster, "intake_day": 1, "operation_day": 1, "review_day": 2}
	var definition: Dictionary = M.procedure(ID)
	var values: Dictionary = controller.values(roster, ID)
	var session := S.new(definition, values, 37, app.game.staff, roster, true)
	session.operative_dialogue = D.new(ID)
	controller.session = session
	if native:
		session.splash_pending = true
		view.render()
		var splash: Control = app.page.get_node_or_null("GeneralAnesthesiaSplash")
		check(splash != null, "Petra anesthesia splash rendered")
		if splash != null:
			await capture("anesthesia")
			splash.find_child("AnesthesiaSplashContinue", true, false).pressed.emit()
		session.splash_pending = false
		session.team_intro_index = 0
		view.render()
		var table: TextureRect = view.body.find_child("AdvancedTeamPatientTable", true, false)
		check(table != null and table.texture != null, "Prone team confirmation rendered")
		if table != null: await capture("team_confirmation")
		session.team_intro_index = -1
	view.render()
	var toolbar: Control = app.page.find_child("AdvancedDialogueToolbar", true, false)
	check(toolbar != null and toolbar.get_parent() == view, "Dialogue tools live outside surgery action cards")
	var toolbar_id := toolbar.get_instance_id() if toolbar != null else 0
	var first_next: Button = app.page.find_child("dialogue_next", true, false)
	check(first_next != null and first_next.custom_minimum_size.x <= 120 and first_next.custom_minimum_size.y <= 42, "Primary dialogue continue is compact")
	await process_frame
	var log_button: Button = app.page.find_child("dialogue_log", true, false)
	check(first_next.get_global_rect().position.x > log_button.get_global_rect().end.x, "Dialogue continue stays to the right of auxiliary controls")
	var dialogue_continue_right := first_next.get_global_rect().end.x
	var dialogue_continue_top := first_next.get_global_rect().position.y
	check(view.body.find_child("AdvancedActionCards", true, false) == null, "No duplicate operation cards during dialogue")
	check(app.page.get_node("AdvancedCast").get_meta("dialogue_id") == "T01_B1", "First V2 line visible")
	if native: await capture("t01_dialogue_toolbar")
	click(app.page, "dialogue_next")
	check(toolbar.get_instance_id() == toolbar_id, "Toolbar persists across dialogue redraw")
	check(app.page.get_node("AdvancedCast").get_meta("dialogue_id") == "T01_B2", "Second V2 line visible")
	click(app.page, "dialogue_log")
	var dialogs: Array = app.page.find_children("*", "AcceptDialog", true, false)
	check(dialogs.size() == 1 and dialogs[0].visible, "Memory dialogue log opens")
	check(session.operative_dialogue.history.size() == 1, "Log records consumed line")
	if not dialogs.is_empty(): dialogs[0].hide()
	click(app.page, "dialogue_skip")
	check(session.operative_dialogue.current(session).is_empty(), "Fast-forward leaves action intact")
	var next_after_skip: Button = app.page.find_child("dialogue_next", true, false)
	check(next_after_skip != null and (not next_after_skip.visible or next_after_skip.disabled), "Dialogue continue hides after fast-forward")
	var skip_after_skip: Button = app.page.find_child("dialogue_skip", true, false)
	check(skip_after_skip != null and skip_after_skip.disabled, "Fast-forward disables with no pending line")
	check(toolbar.get_instance_id() == toolbar_id, "Toolbar persists after phase skip")
	if native: await capture("t01_action_after_skip")
	click(app.page, "continue")
	check(view.body.find_child("AdvancedActionCards", true, false) == null, "After-action dialogue has no operation cards")
	check(session.awaiting_ack, "Actual F stage action runs")
	check(app.page.get_node("AdvancedCast").get_meta("dialogue_id") == "T01_A1", "First after-action line visible")
	click(app.page, "dialogue_next")
	check(app.page.get_node("AdvancedCast").get_meta("dialogue_id") == "T01_A2", "Second after-action line visible")
	click(app.page, "dialogue_next")
	var result_continue: Button = app.page.find_child("continue", true, false)
	check(result_continue != null and result_continue == first_next and result_continue.custom_minimum_size.y <= 42, "Result acknowledgement reuses the fixed compact toolbar")
	await process_frame
	check(absf(result_continue.get_global_rect().end.x - dialogue_continue_right) <= 24.0, "Result continue aligns with dialogue continue on the right: %s vs %s" % [result_continue.get_global_rect().end.x, dialogue_continue_right])
	check(absf(result_continue.get_global_rect().position.y - dialogue_continue_top) <= 2.0, "Result continue stays on the same toolbar row")
	var result_label: Label = view.body.find_child("AdvancedActionResult", true, false)
	check(result_label != null and result_label.autowrap_mode == TextServer.AUTOWRAP_OFF and view.body.find_child("AdvancedActionCards", true, false) == null, "Result status is one compact line without duplicate action cards")
	if native: await capture("t01_result_compact")
	click(app.page, "continue")
	check(session.index == 1, "Next stage begins after two after-action lines")
	if "--sweat" in OS.get_cmdline_user_args():
		for seed_value in range(100):
			var ambient := Sweat.new(seed_value, roster)
			ambient.on_transition(121.0, true) # Isolated display fixture for the 120-minute boundary.
			if not ambient.current().is_empty():
				session.sweat_break = ambient
				break
		check(session.sweat_break != null, "Deterministic Petra sweat-break fixture exists")
		view.render()
		var ambient_line: Dictionary = session.operative_dialogue.current(session)
		check(app.page.get_node("AdvancedCast").get_meta("dialogue_id") == ambient_line.id, "Sweat-break line rendered in native operation scene")
		if native: await capture("sweat_break_zh")
		view.english = true
		view.render()
		check(app.page.get_node("AdvancedCast").get_meta("source_text") == ambient_line.text_en, "English sweat-break line rendered")
		if native: await capture("sweat_break_en")
		click(app.page, "dialogue_skip")
		check(str(session.operative_dialogue.current(session).id) == "T02_B1", "Sweat-break skip preserves next stage V2")
		view.english = false
		view.render()
	view.operative_auto = true
	view.render()
	check(app.page.get_node("AdvancedCast").get_meta("dialogue_id") == "T02_B1", "Autoplay starts on current line")
	await create_timer(1.6).timeout
	check(app.page.get_node("AdvancedCast").get_meta("dialogue_id") == "T02_B2", "Autoplay advances exactly one line")
	view.operative_auto = false
	if native:
		var field_panel: PanelContainer = view.body.find_child("AdvancedOperativeField", true, false)
		check(field_panel != null and str(field_panel.get_meta("asset_path")) == "assets/surgeries/advanced_fields_v1/petra_posterior_incision.png", "Incision field rendered at T02")
		await capture("t02_incision")
	view.english = true
	view.render()
	var english_line: Dictionary = session.operative_dialogue.current(session)
	check(app.page.get_node("AdvancedCast").get_meta("source_text") == english_line.text_en, "English V2 line loads in the visible scene")
	check(app.page.find_child("dialogue_auto", true, false).text == "Autoplay: Off", "Compact tools localize to English")
	if native: await capture("t02_english")
	view.operative_auto = true
	view.render()
	await create_timer(3.5).timeout
	check(session.index == 1 and not session.awaiting_ack, "Autoplay never executes the teamwork action")
	check(session.operative_dialogue.current(session).is_empty(), "Autoplay stops after current dialogue phase")
	print("PETRA UI: ", checks, " checks / ", failures, " failures")
	quit(1 if failures else 0)
