extends "res://tools/miyuki_lv3_retest.gd"

const Catalog = preload("res://godot/systems/daydream_catalog.gd")

var output := ""
var problems: Array = []
var launched: Array = []

func check(ok: bool, message: String) -> void:
	expect(ok, message)
	if not ok: problems.append(message)

func find_button(name: String) -> Button:
	return app.page.find_child(name, true, false) as Button

func click(button: Button) -> void:
	await super.click(button)
	input_counts.mouse += 1

func reveal(button: Button) -> void:
	var ancestor = button.get_parent() if button != null else null
	while ancestor != null and not ancestor is ScrollContainer:
		ancestor = ancestor.get_parent()
	if ancestor != null:
		ancestor.ensure_control_visible(button)
	await process_frame
	await process_frame

func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(output + "/" + name + ".png") == OK, "Screenshot " + name)

func activate_modal(button: Button) -> void:
	check(button != null and button.is_visible_in_tree() and not button.disabled, "Modal action available")
	if button == null: return
	button.grab_focus()
	await process_frame
	var viewport := button.get_viewport()
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_ENTER
		event.pressed = pressed
		viewport.push_input(event, true)
	input_counts.enter += 1
	await process_frame
	await process_frame

func open_test_catalog() -> void:
	var entry := find_button("DaydreamEventTestEntry")
	check(entry != null, "Event Test Hub exposes the Daydream entry")
	if entry == null: return
	await reveal(entry)
	await click(entry)
	check(app.screen == "daydream_catalog" and app.daydream_view.testing, "Daydream test catalog opens")

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output = arg.trim_prefix("--out=")
	assert(not output.is_empty())
	DirAccess.make_dir_recursive_absolute(output)
	native = DisplayServer.get_name() != "headless"
	check(native, "Native renderer required")
	if not native: quit(1); return
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.title_notice_enabled = false
	app.saves.path = "/private/tmp/daydream_hub_native_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	app.dialogue_auto_enabled = false
	var entries := Catalog.entries()
	check(entries.size() == 3, "Exactly three Daydream events are registered")
	for locale in ["zh_CN", "en"]:
		check(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		app.game.reset()
		app.title_screen()
		await click(find_button("TitleDeveloper"))
		var dialog = app.get_node_or_null("TitleDeveloperDialog")
		var event_hub := dialog.find_child("EventTestHubEntry", true, false) as Button if dialog != null else null
		check(event_hub != null, "Developer tools expose Event Test Hub")
		if event_hub == null: break
		await activate_modal(event_hub)
		check(app.screen == "event_test_hub", "Title developer tools open Event Test Hub")
		if app.screen != "event_test_hub": break
		var before_time: int = app.game.elapsed()
		await reveal(find_button("DaydreamEventTestEntry"))
		await shot(locale + "_event_test_hub")
		await open_test_catalog()
		check(not app.game.can_save_progress() and app.game.snapshot().is_empty(), "Test catalog blocks persistent saves")
		for entry in entries:
			var event_id := str(entry.id)
			var event_button := find_button("DaydreamEntry_" + event_id)
			check(event_button != null and not event_button.disabled, "Test button enabled " + event_id)
		check(find_button("DaydreamLevel_0") == null and find_button("DaydreamAcceptDark") == null, "Test catalog bypasses production level and warning controls")
		await shot(locale + "_daydream_test_catalog")
		for index in range(entries.size()):
			var entry: Dictionary = entries[index]
			var event_id := str(entry.id)
			if app.screen == "event_test_hub": await open_test_catalog()
			var event_button := find_button("DaydreamEntry_" + event_id)
			await reveal(event_button)
			await click(event_button)
			check(app.screen == "daydream_confirm", "Confirmation opens " + event_id)
			await click(find_button("DaydreamBegin"))
			check(app.screen == "daydream_playback" and app.daydream_view.session != null and str(app.daydream_view.session.definition.id) == event_id, "Real VN session starts " + event_id)
			if app.daydream_view.session == null: break
			check(str(app.daydream_view.session.current().id) == str(entry.start), "Authored start node shown " + event_id)
			check(not app.game.can_save_progress() and app.game.snapshot().is_empty(), "Playback blocks persistent saves " + event_id)
			launched.append({"locale": locale, "event": event_id, "node": str(app.daydream_view.session.current().id)})
			await shot(locale + "_" + event_id + "_start")
			await click(find_button("DaydreamExit"))
			check(app.screen == "event_test_hub" and not app.game.daydream_active and not app.daydream_view.testing, "Exit returns to Event Test Hub " + event_id)
			check(app.game.elapsed() == before_time and app.game.daydream_read_ids.is_empty(), "Early test exit changes no time or read facts " + event_id)
	var report := {"native": native, "checks": checks, "failures": failures, "problems": problems, "launched": launched, "inputs": input_counts, "scope": "Title developer tools -> Event Test Hub -> one Daydream test entry -> three real VN starts; isolated save path; early exit return"}
	var file := FileAccess.open(output + "/native.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t")); file.close()
	print("DAYDREAM TEST HUB NATIVE checks=", checks, " failures=", failures, " launches=", launched.size())
	quit(1 if failures else 0)
