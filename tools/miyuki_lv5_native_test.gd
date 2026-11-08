extends "res://tools/miyuki_lv5_test.gd"
var app
var qa := ""
var rendered := 0
var input_counts := {"mouse": 0, "space": 0, "enter": 0}
const SCREENSHOT_NODES := [
	"n003", "n025_s2", "n037", "n081", "n082",
	"n091", "n093", "n100", "n102", "n105", "n112", "n127_s2",
	"n129", "n131", "n137", "n146", "n149",
	"n150", "n165_s2",
]
const PART_B_NO_CG_NODES := ["n098", "n099", "n136"]
const PAGINATION_SCREENSHOT_NODES := ["n100", "n129"]

func click_native(button: Button) -> void:
	expect(button != null and is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled, "Native button available")
	if button == null or not is_instance_valid(button): return
	var point: Vector2 = button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, true)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		event.global_position = point
		root.push_input(event, true)
	await process_frame
	await process_frame
	input_counts.mouse += 1

func press_native(key: Key, button: Button) -> void:
	button.grab_focus()
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = key
		event.pressed = pressed
		root.push_input(event, true)
	await process_frame
	await process_frame
	input_counts["space" if key == KEY_SPACE else "enter"] += 1

func screenshot(locale: String, event_id: String, node_id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(qa + "/" + locale + "_" + event_id + "_" + node_id + ".png")

func native_play(event_id: String, locale: String) -> void:
	var visited := 0
	while visited < 220:
		var event = app.game.character_events.get(app.game.active_character_event_id)
		if event == null or event.completed or str(event.definition.id) != event_id: break
		var node: Dictionary = event.current()
		expect(app.screen == "character_event", "Visible character event screen " + str(node.id))
		expect(not app.game.can_save_progress() and app.game.snapshot().is_empty(), "No event save " + str(node.id))
		var speaker = app.page.get_node_or_null("CharacterEventDialogueSpeaker")
		if speaker != null:
			expect(str(speaker.text) == str(node.speaker_label), "Rendered speaker " + str(node.id))
		if bool(node.get("hide_portrait", false)):
			expect(app.page.get_node_or_null("CharacterPortrait") == null and app.page.get_node_or_null("CharacterEventPortrait") == null, "Narration has no portrait " + str(node.id))
		elif node.has("portrait_path"):
			var portrait = app.page.get_node_or_null("CharacterEventPortrait")
			expect(portrait != null and portrait.texture != null and str(portrait.texture.resource_path) == "res://" + str(node.portrait_path), "Chie portrait exact " + str(node.id))
		var cg_path := str(node.get("cg_path", ""))
		var cg := app.page.get_node_or_null("CharacterEventCG") as TextureRect
		if cg_path.is_empty():
			if str(node.id) in PART_B_NO_CG_NODES:
				expect(cg == null, "%s %s V5.2 transition remains CG-free" % [locale, node.id])
		else:
			expect(cg != null, "%s %s CG widget exists" % [locale, node.id])
			if cg != null:
				expect(cg.is_visible_in_tree(), "%s %s CG is visible" % [locale, node.id])
				expect(cg.texture != null, "%s %s CG texture is loaded" % [locale, node.id])
			if cg.texture != null:
				expect(cg.texture.resource_path == "res://" + cg_path, "%s %s CG path matches data" % [locale, node.id])
		if node.id in SCREENSHOT_NODES:
			await screenshot(locale, event_id, str(node.id))
		var source_id := str(node.id)
		var pages := 0
		while not event.completed and str(event.current().id) == source_id and pages < 16:
			var button: Button = app.page.get_node_or_null("EventDialogueContinue")
			if button == null:
				button = app.page.get_node_or_null("EventChoice_" + str(node.choices[0].id))
			expect(button != null, "Visible continuation " + source_id)
			if button == null: break
			if node.choices.size() == 1 and pages % 3 == 1:
				await press_native(KEY_SPACE, button)
			elif node.choices.size() == 1 and pages % 3 == 2:
				await press_native(KEY_ENTER, button)
			else:
				await click_native(button)
			pages += 1
			if source_id in PAGINATION_SCREENSHOT_NODES and not event.completed and str(event.current().id) == source_id:
				await screenshot(locale, event_id, source_id + "_page_%02d" % [pages + 1])
		expect(pages < 16, "Node advances " + source_id)
		visited += 1
		rendered += 1
		if visited % 25 == 0: print("NATIVE PROGRESS ", locale, " ", event_id, " ", visited)
	expect(visited > 0 and visited < 220, "Whole visible event traversed " + event_id)
	expect(app.game.character_event_done(event_id), "Event completed through native controls " + event_id)
	await process_frame
	if app.screen == "character_event_complete":
		var buttons: Array = app.page.find_children("*", "Button", true, false)
		var back: Button = null
		for candidate in buttons:
			if "医院导览" in str(candidate.text) or "Hospital" in str(candidate.text):
				back = candidate
				break
		if back != null:
			await click_native(back)
			expect(app.screen == "map" or app.screen == "location", "Return from completion screen")
	if app.game.active_character_event_id == event_id:
		app.game.finish_character_event()

func setup_native(locale: String) -> void:
	expect(app.content.load_all(locale), "Load " + locale + " content")
	app.configure_game_content()
	prepare(app.game)
	for d in app.game.special_event_definitions.values():
		d.developer_only = true
		d.auto_schedule = false
	for d in app.game.character_event_definitions.values():
		if not Flow.owns(str(d.id)):
			d.trigger_mode = "interaction"
	app.screen = "map"
	app.dialogue_auto_enabled = false

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			qa = arg.trim_prefix("--out=")
	assert(not qa.is_empty())
	DirAccess.make_dir_recursive_absolute(qa)
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/miyuki_lv5_native_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		setup_native(locale)
		app.show_map()
		expect(app.game.active_character_event_id == Flow.A, "Real day-start map entry")
		await native_play(Flow.A, locale)
		if failures: break
		app.game.set_test_time(72, 720)
		app.game.pending_day_exit_workday = 72
		app.game.pending_day_exit_clock = 1020
		expect(app._start_exclusive_departure_event(), "Real after-work scheduler enters B")
		await native_play(Flow.B, locale)
		if failures: break
		app.game.set_test_time(73, 540)
		app.game.pending_day_exit_workday = 0
		app.game.pending_day_exit_clock = 0
		app.show_location("station")
		expect(app.game.active_character_event_id == Flow.C, "Real station entry starts C")
		await native_play(Flow.C, locale)
		if failures: break
		app.show_staff("nurse_yui", "station")
		var invitation: Button = app.page.get_node_or_null("StaffPatientInvite")
		expect(invitation != null and invitation.is_visible_in_tree(), "Visible Miyuki Staff-as-Patient entry " + locale)
		await screenshot(locale, "staff_patient", "entry")
		if invitation != null:
			await click_native(invitation)
			var dialog = app.get_node_or_null("StaffPatientInvitation")
			expect(dialog != null and dialog.visible, "Invitation dialog opens from real UI " + locale)
			await screenshot(locale, "staff_patient", "dialog")
			if dialog != null:
				dialog.queue_free()
				await process_frame
	var report := {"checks": checks, "failures": failures, "rendered_pages": rendered,
		"native": DisplayServer.get_name() != "headless", "input_counts": input_counts,
		"languages": ["zh_CN", "en"],
		"part_b_version": "V5.2",
		"part_b_cg_anchors": ["n093", "n100", "n105", "n129", "n137"]}
	var f := FileAccess.open(qa + "/report.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "\t"))
	f.close()
	print("MIYUKI LV5 NATIVE: ", JSON.stringify(report))
	quit(1 if failures else 0)
