extends SceneTree
## Isolated V3.2 presentation test. Never reads or writes player save slots.
const Session = preload("res://godot/systems/special_event_session.gd")
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func start_part(app, part: String) -> void:
	app.game.reset()
	var id := "sayaka_lv5_part_" + part
	expect(app.game.prepare_special_event_test_save(id, false), "Prepare " + id)
	app.game.set_test_time(app.game.day_number(), 9 * 60 if part == "c" else 16 * 60)
	expect(app.game.start_special_event(id) != null, "Start " + id)
	app.reset_dialogue_page()
	app.show_special_event()

func show_node(app, id: String) -> void:
	expect(app.game.active_special_event.jump_to(id), "Jump to " + id)
	app.show_special_event()

func test_blackout(app, gallery: bool) -> void:
	var event = app.special_event_gallery_replay if gallery else app.game.active_special_event
	expect(event.jump_to("a03_h_0001_ins06"), "Final authored line before blackout exists")
	if gallery:
		app.show_special_gallery_replay()
	else:
		app.show_special_event()
	var before: Dictionary = app.game.snapshot()
	var ledger: int = app.game.elapsed()
	var start := Time.get_ticks_msec()
	if gallery:
		app.choose_special_gallery_replay("a03_h_0001_ins06_next")
	else:
		app.choose_special_event("a03_h_0001_ins06_next")
	expect(app.screen == "special_event_blackout", "Blackout starts before Afterglow")
	expect(not app.page.visible and app.dialogue_default_button == null, "No text/calendar/controls/autoplay during blackout")
	var black: ColorRect = app.get_node_or_null("SpecialEventBlackout")
	expect(black != null and black.color == Color.BLACK, "Pure black overlay")
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var frame := root.get_texture().get_image()
		for x in [0.1, 0.5, 0.9]:
			for y in [0.1, 0.5, 0.9]:
				var pixel := frame.get_pixel(int(frame.get_width() * x), int(frame.get_height() * y))
				expect(pixel.r < 0.01 and pixel.g < 0.01 and pixel.b < 0.01, "Rendered blackout pixel")
	# Neither keyboard activation nor a duplicate button callback can skip it.
	var key := InputEventKey.new()
	key.keycode = KEY_SPACE
	key.pressed = true
	root.push_input(key, true)
	expect(not app.activate_dialogue_default(), "Keyboard cannot advance blackout")
	app.choose_special_event("a04_0001_next")
	app.choose_special_gallery_replay("a04_0001_next")
	await create_timer(0.35).timeout
	expect(app.screen == "special_event_blackout", "Blackout did not end early")
	while app.screen == "special_event_blackout" and Time.get_ticks_msec() - start < 3000:
		await process_frame
	var duration := Time.get_ticks_msec() - start
	expect(duration >= 980 and duration < 1800, "One-second real-time transition: " + str(duration))
	expect(event.node_id == "a04_0001", "Exactly one advance into Afterglow")
	expect(app.page.get_node_or_null("CharacterEventCG") != null, "Afterglow CG renders after black")
	expect(app.game.elapsed() == ledger, "Transition did not consume time")
	if gallery:
		expect(app.game.snapshot() == before, "Gallery transition leaves live state unchanged")
	print("V3_BLACKOUT gallery=", gallery, " milliseconds=", duration)

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var han := RegEx.new()
	han.compile("[\\x{3400}-\\x{9fff}]")
	var translations: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tools/sayaka_lv5_en_text.json"))
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Content load " + locale)
		app.configure_game_content()
		app.dialogue_auto_enabled = false
		for part in ["a", "b", "c"]:
			var step: Dictionary = app.game.special_event_step_definitions["sayaka_lv5_part_" + part + "_main"]
			for node in step.nodes:
				var rendered: String = app.special_event_localized_text(step, node)
				expect(rendered == (translations[node.id] if locale == "en" else node.text), locale + " exact node " + node.id)
				if locale == "en":
					expect(han.search(app.special_event_speaker(node, app.special_event_actor(node), step.id)) == null, "English speaker " + node.id)
		start_part(app, "a")
		var ledger_before: int = app.game.elapsed()
		var workday: int = app.game.day_number()
		show_node(app, "a02_0001")
		expect(app.page.get_node("CalendarHeader").text.ends_with("22:00"), "A night header")
		# Simulate the ledger reserving tomorrow while the departure scene is today.
		app.game.pending_day_exit_workday = workday - 1
		app.game.pending_day_exit_clock = 17 * 60
		expect(int(app.game.display_schedule().day) == workday - 1, "A keeps departure date")
		app.game.pending_day_exit_workday = 0
		app.game.pending_day_exit_clock = 0
		for id in ["a04_0025", "a04_0026", "a04_0027", "a04_0028"]:
			show_node(app, id)
			expect(app.page.get_node_or_null("CharacterEventPortrait") == null and app.page.get_node_or_null("CharacterPortrait") == null, "Undressed/no-cap stage hides inappropriate portraits " + id)
		show_node(app, "a04_0029")
		expect(app.page.get_node_or_null("CharacterPortrait") != null, "Dressed portrait restored")
		expect(app.game.elapsed() == ledger_before, "Scene clocks do not change ledger")
		await test_blackout(app, false)
		var definition: Dictionary = app.game.special_event_definitions.sayaka_lv5_part_a
		app.special_event_gallery_replay = Session.new(definition, app.game.special_event_step_definitions, workday)
		await test_blackout(app, true)
		expect(app.page.get_node("CalendarHeader").text.ends_with("22:00"), "Gallery A night header")
		app.special_event_gallery_replay = null
		start_part(app, "b")
		var before_b: int = app.game.elapsed()
		var b_day: int = app.game.world_display_schedule().day
		for scene in ["b03", "b04", "b05", "b06", "b07"]:
			show_node(app, scene + "_0001")
			expect(app.page.get_node("CalendarHeader").text.ends_with("19:00"), "B night " + scene)
		show_node(app, "b08_0001")
		expect(app.page.get_node("CalendarHeader").text.ends_with("09:00") and int(app.game.display_schedule().day) == b_day + 1, "B next-morning scene/date")
		expect(app.game.elapsed() == before_b and not app.game.can_save_progress(), "B scene changes neither settle nor unlock saving")
		start_part(app, "c")
		show_node(app, "c01_0016")
		expect(app.page.get_node_or_null("CharacterPortrait") == null, "Asuka stays offscreen behind door")
		expect(app.page.get_node_or_null("SpecialEventSecondaryPortrait") != null, "Sayaka remains in corridor")
		for id in ["c02_0001", "c03_0035", "c03_0036", "c03_0037"]:
			show_node(app, id)
			expect(app.page.get_node_or_null("CharacterEventCG") == null, "No premature office CG " + id)
		show_node(app, "c03_0038")
		expect(app.page.get_node_or_null("CharacterEventCG") != null, "Office CG appears after questions")
		show_node(app, "c03_0039")
		expect(app.page.get_node_or_null("CharacterEventCG") == null, "Office CG returns to portraits")
		app.game.reset()
		app.show_map(false)
	# Flush CG-reveal timers from the last rendered page before freeing the app.
	await create_timer(1.2).timeout
	app.free()
	print("SAYAKA LV5 V3 UI: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
