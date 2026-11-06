extends SceneTree
var checks := 0
var failures := 0
var app
var output := ""
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run")
func click(button: Button) -> void:
	var point := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
	await process_frame
	await process_frame
func inspect(reward: Dictionary) -> void:
	var cg = app.page.get_node_or_null("StaffRoleGalleryCG")
	expect(cg is TextureRect, str(reward.id) + " CG exists")
	if not cg is TextureRect: return
	expect(cg.texture != null, "Texture loads")
	expect(cg.size.is_equal_approx(Vector2(635, 455)), "Actual CG size stays in preview frame: " + str(cg.size))
	expect(Rect2(560, 175, 635, 455).encloses(cg.get_rect()), "CG inside right column")
	expect(cg.expand_mode == TextureRect.EXPAND_IGNORE_SIZE, "Source size cannot expand preview")
	expect(cg.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Full image preserves aspect ratio")
	expect(cg.texture.resource_path == "res://" + str(reward.path), "Correct original artwork")
	for child in app.page.get_children():
		if child is Button:
			expect(not cg.get_rect().intersects(child.get_rect()), "CG does not cover buttons")
func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output = arg.trim_prefix("--out=")
	var native := DisplayServer.get_name() != "headless"
	if not output.is_empty():
		expect(native, "Screenshots require native window")
		DirAccess.make_dir_recursive_absolute(output)
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/tmp/hoshimi_role_gallery_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	var count := 0
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		app.game.reset()
		var target := {}
		for reward in app.game.staff_role_cg_definitions.values():
			app.game.unlock_staff_role_cg(str(reward.staff_id), str(reward.role_id))
			var before: Dictionary = app.game.snapshot()
			app.show_staff_role_gallery_entry(str(reward.id))
			await process_frame
			inspect(reward)
			expect(app.game.snapshot() == before, "Gallery does not change time, relationships or rewards")
			count += 1
			if reward.staff_id == "pharmacist_manami" and reward.role_id == "assistant_surgeon": target = reward
		expect(not target.is_empty(), "Screenshot's Manami role exists")
		if native and not target.is_empty():
			for window_size in [Vector2i(1152, 720), Vector2i(1280, 800)]:
				root.size = window_size
				app.show_event_gallery()
				await process_frame
				var entry: Button = app.page.find_child("GalleryRole_" + str(target.id), true, false)
				expect(entry != null, "Real gallery entry exists")
				if entry == null: continue
				var scroll: ScrollContainer = entry.get_parent().get_parent()
				scroll.ensure_control_visible(entry)
				await process_frame
				await click(entry)
				expect(app.screen == "staff_role_gallery_entry", "GUI click opens role memory")
				inspect(target)
				await RenderingServer.frame_post_draw
				if not output.is_empty():
					expect(root.get_texture().get_image().save_png(output + "/%s_%sx%s.png" % [locale, window_size.x, window_size.y]) == OK, "Rendered screenshot saved")
				for child in app.page.get_children():
					if child is Button and child.position.is_equal_approx(Vector2(60, 545)):
						await click(child)
						break
				expect(app.screen == "event_gallery", "GUI return remains accessible")
	app.queue_free()
	await process_frame
	print("ROLE GALLERY LAYOUT: %s checks; %s failures; %s bilingual previews; native=%s" % [checks, failures, count, native])
	quit(1 if failures else 0)
