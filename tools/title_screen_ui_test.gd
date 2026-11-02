extends SceneTree
const Title = preload("res://godot/ui/title_view.gd")
var app
var checks := 0
var failures := 0
var native := DisplayServer.get_name() != "headless"
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func capture(id: String) -> void:
	await process_frame
	if native:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/hoshimi_title_"+id+".png")
func key(code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code; event.pressed = true
	root.push_input(event, true)
	event = event.duplicate(); event.pressed = false
	root.push_input(event, true)
	await process_frame
func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.title_notice_enabled = false
	var prefix := "/tmp/title_ui_" + str(OS.get_process_id())
	app.title_preferences_path = prefix + ".cfg"
	app.saves.path = prefix + ".json"
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load localized content")
		app.configure_game_content(); app.title_screen()
		await process_frame
		expect(app.screen == "title", "Title screen")
		expect(app.page.get_node_or_null("CalendarHeader") == null, "No gameplay clock on title")
		expect(app.page.get_node_or_null("PageTitle") == null, "No obsolete chapter heading")
		expect(app.background.texture.resource_path == Title.BACKGROUND, "Authored corridor background")
		expect(app.page.get_node("TitleContinue").disabled, "Continue disabled without saves")
		expect(root.gui_get_focus_owner() == app.page.get_node("TitleNewGame"), "New Game default focus without saves")
		expect(app.page.get_node("TitleTrilingualNotice").text == Title.SHORT_NOTICE, "Three languages always simultaneous")
		expect(app.page.get_node("TitleName").text == ("星见医院" if locale == "zh_CN" else "Hoshimi Hospital"), "Localized main title")
		await capture(locale)
		app.page.get_node("TitleSettings").pressed.emit()
		await process_frame
		var settings = app.get_node("TitleSettingsDialog")
		expect(settings.find_children("*", "OptionButton", true, false).size() == 1, "Working auto-play settings control")
		await capture(locale + "_settings")
		settings.hide(); settings.queue_free(); await process_frame
		await key(KEY_F10)
		var dev = app.get_node_or_null("TitleDeveloperDialog")
		expect(dev != null, "F10 opens developer tools")
		if dev:
			expect(dev.find_child("TestSaveGeneratorEntry", true, false) != null, "Generator remains accessible")
			dev.find_child("EventTestHubEntry", true, false).pressed.emit()
		await process_frame
		expect(app.screen == "event_test_hub", "Event hub action routed correctly")
		app.title_screen()
		await key(KEY_F10)
		app.get_node("TitleDeveloperDialog").find_child("TestSaveGeneratorEntry", true, false).pressed.emit()
		await process_frame
		expect(app.screen == "test_save_generator", "Test save generator action routed correctly")
		app.title_screen()
		app.game.visits.clear()
		app.page.get_node("TitleNewGame").pressed.emit()
		expect(app.screen == "opening_chapter", "New game shows Spring Prologue card first")
		await capture(locale + "_chapter")
		await key(KEY_ENTER)
		expect(app.screen == "dialogue", "Chapter proceeds into original opening story")
		app.game.reset(); app.title_screen()
	# First-launch acceptance is a UI preference, never a gameplay snapshot.
	app.title_notice_enabled = true
	Title.startup(app)
	await process_frame
	var notice = app.get_node("TitleUsageNotice")
	expect(notice.visible, "First launch shows full declaration")
	await capture("full_notice")
	notice.confirmed.emit(); notice.hide()
	await process_frame
	var config := ConfigFile.new()
	expect(config.load(app.title_preferences_path) == OK, "Notice preference persisted independently")
	expect(config.get_value("notice", "acknowledged_version", 0) == Title.NOTICE_VERSION, "Notice version recorded")
	Title.startup(app)
	expect(app.get_node_or_null("TitleUsageNotice") == null, "Acknowledged notice not repeated")
	# Build genuine safe-boundary saves only in the unique temporary directory.
	app.game.reset(); app.game.active_mode = "encounter"
	expect(app.saves.write_slot(app.game, 1), "Safe-boundary test save")
	expect(app.saves.write_slot(app.game, 3), "Second safe-boundary test save")
	for slot in [1,3]:
		var path: String = app.saves.slot_path(slot)
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		data._slot_metadata.saved_at = "2026-11-01 10:00:00" if slot == 1 else "2026-11-01 11:00:00"
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_string(JSON.stringify(data)); file.close()
	var corrupt := FileAccess.open(app.saves.slot_path(8), FileAccess.WRITE)
	corrupt.store_string("{broken"); corrupt.close()
	expect(Title.latest_slot(app) == 3, "Newest valid JSON slot selected; malformed slot ignored")
	app.title_screen()
	expect(not app.page.get_node("TitleContinue").disabled, "Continue enabled with saves")
	app.page.get_node("TitleContinue").pressed.emit()
	expect(app.active_save_slot == 3, "Continue loads actual newest slot")
	expect(app.screen != "title" and app.screen != "save_slots", "Continue directly enters restored game")
	for slot in [1,3,8]: DirAccess.remove_absolute(app.saves.slot_path(slot))
	DirAccess.remove_absolute(app.title_preferences_path)
	app.queue_free(); await process_frame
	print("TITLE UI: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
