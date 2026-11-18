extends SceneTree
const Event = preload("res://godot/systems/character_event_session.gd")
var app
var checks := 0
var failures := 0
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func click(button: Button) -> void:
	var pos := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = pos
	root.push_input(motion, true)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = pos
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
	await process_frame
	await process_frame
func run() -> void:
	expect(DisplayServer.get_name() != "headless", "native renderer")
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.title_notice_enabled = false
	app.saves.path = "/private/tmp/cg_preview_unused_%s.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/cg_preview_prefs_%s.cfg" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	var mapping = JSON.parse_string(FileAccess.get_file_as_string("res://research/imports/asuka_maki_supplement_cg_mapping.json"))
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "locale loads")
		app.configure_game_content()
		app.game.reset()
		for row in mapping.entries:
			var definition = app.game.character_event_definitions[row.event_id]
			var ev = Event.new(definition)
			# Rendering checkpoints only; not a full-event playthrough.
			ev.node_id = row.prefix + str(int(row.start)).pad_zeros(3)
			app.game.character_events[row.event_id] = ev
			app.game.active_character_event_id = row.event_id
			app.game.active_mode = "character_event"
			app.show_character_event()
			await create_timer(0.5).timeout
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://docs/qa/asuka_maki_cg_2026-11-14/%s_%s_reveal.png" % [locale, str(row.path).get_file().get_basename()])
			await create_timer(1.8).timeout
			var cg = app.page.get_node_or_null("CharacterEventCG")
			expect(cg != null and cg.texture.resource_path == "res://" + row.path, "correct scene CG")
			expect(app.page.get_node_or_null("CharacterPortrait") == null, "no sprite over CG")
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://docs/qa/asuka_maki_cg_2026-11-14/%s_%s.png" % [locale, str(row.path).get_file().get_basename()])
			ev.completed = true
			app.show_gallery_entry(row.event_id)
			await process_frame
			var paths = app.character_gallery_paths(definition)
			expect(row.path in paths, "CG discoverable in gallery")
			for i in range(paths.size()):
				expect(app.page.get_node("GalleryCG").texture.resource_path == "res://" + paths[i], "gallery page texture")
				if paths.size() > 1:
					await click(app.page.get_node("GalleryCGNext"))
			expect(app.page.get_node("GalleryCG").texture.resource_path == "res://" + paths[0], "gallery wraps")
	print("SUPPLEMENT CG NATIVE CHECKPOINTS: %s checks, %s failures" % [checks, failures])
	app.queue_free()
	await process_frame
	quit(1 if failures else 0)
