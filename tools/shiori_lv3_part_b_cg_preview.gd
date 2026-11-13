extends SceneTree
# Isolated visual checkpoints, NOT a full narrative playthrough.
# Advances the CG windows via synthesized GUI mouse clicks, in both languages.
const EVENT := "shiori_lv3_part_b_dinner_walk"
const OUT := "res://docs/qa/shiori_lv3_part_b_cg_2026-11-12/run2"
var app
var failures := 0
var checks := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	expect(app.get_viewport().get_texture().get_image().save_png(OUT + "/" + name + ".png") == OK, "capture " + name)

func click(button: Button) -> void:
	var pos := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = pos
	motion.global_position = pos
	root.push_input(motion, true)
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.position = pos
		ev.global_position = pos
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		root.push_input(ev, true)
	await process_frame
	await process_frame

func run() -> void:
	expect(DisplayServer.get_name() != "headless", "native renderer")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/shiori_b_cg_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	app.dialogue_auto_enabled = false
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "locale " + locale)
		app.configure_game_content()
		app.game.reset()
		expect(app.game.prepare_character_event_test_save(EVENT), "isolated fixture")
		var session = app.game.start_character_event(EVENT)
		expect(session != null, "event available in fixture")
		if session == null:
			continue
		for span in [[60, 62], [169, 178]]:
			session.node_id = "slv3b_%03d" % span[0]
			app.character_event_last_cg_path = ""
			app.reset_dialogue_page()
			app.show_character_event()
			await process_frame
			var seen := {}
			var guard := 0
			while int(str(session.node_id).get_slice("_", 1)) < span[1] and guard < 80:
				guard += 1
				var id := str(session.node_id)
				var cg := app.page.get_node_or_null("CharacterEventCG") as TextureRect
				expect(cg != null and cg.texture != null, "CG present " + id)
				expect(not app.game.can_save_progress(), "save locked " + id)
				if id in ["slv3b_060", "slv3b_169", "slv3b_173"] and not seen.has(id):
					seen[id] = true
					var box := app.page.get_node_or_null("CharacterEventDialogueBox") as Control
					expect(box != null and not box.visible, "initial clean reveal " + id)
					await capture(locale + "_" + id + "_clean")
					await create_timer(1.1).timeout
					expect(is_instance_valid(box) and box.visible, "dialogue restored " + id)
					await capture(locale + "_" + id + "_dialogue")
				var btn := app.page.get_node_or_null("EventDialogueContinue") as Button
				if btn == null:
					btn = app.page.get_node_or_null("EventChoice_" + str(session.current().choices[0].id)) as Button
				expect(btn != null and btn.is_visible_in_tree(), "clickable continue " + id)
				if btn == null or not btn.is_visible_in_tree():
					break
				await click(btn)
			expect(session.node_id == "slv3b_%03d" % span[1], "GUI traversed CG window")
			expect(app.page.get_node_or_null("CharacterEventCG") == null, "CG removed at window exit")
			await capture(locale + "_" + str(session.node_id) + "_exit")
	app.queue_free()
	await process_frame
	print("SHIORI PART B CG PREVIEW: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
