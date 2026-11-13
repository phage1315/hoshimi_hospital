extends SceneTree
## Native rendering checkpoints only: direct session traversal, not a GUI playthrough.
const ID := "shiori_lv2_record_shop"
const OUT := "res://docs/qa/shiori_lv2_cg_2026-11-12/"
const TARGETS := [161, 162, 171, 172, 187, 188, 198, 206, 207, 208, 209]
var app
var checks := 0
var failures := 0
func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func _initialize() -> void:
	call_deferred("run")
func capture(filename: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	expect(root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + filename)) == OK, "save " + filename)
func run() -> void:
	expect(DisplayServer.get_name() != "headless", "native display")
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/shiori_cg_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "load " + locale)
		app.configure_game_content()
		expect(app.game.prepare_character_event_test_save(ID), "isolated fixture")
		app.game.advance_story_to_day(app.game.day_number(), 865)
		var event = app.game.start_character_event(ID)
		expect(event != null, "start")
		if event == null:
			quit(1)
			return
		while not event.completed:
			var node: Dictionary = event.current()
			var beat := int(str(node.id).get_slice("_", 1))
			if beat in TARGETS:
				app.reset_dialogue_page()
				app.show_character_event()
				await process_frame
				var cg = app.page.get_node_or_null("CharacterEventCG")
				var expected := ""
				if beat >= 162 and beat <= 171:
					expected = "record_sharing"
				elif beat >= 188 and beat <= 206:
					expected = "headband_pensive"
				elif beat >= 207 and beat <= 208:
					expected = "headband_relieved"
				expect((cg != null) == (expected != ""), "CG enter/exit " + str(beat))
				if cg != null:
					expect(cg.texture.resource_path.ends_with(expected + ".png"), "correct texture")
					expect(cg.size == app.page.size, "full canvas bounds")
				await capture(locale + "_" + str(beat) + ".png")
				if beat in [162, 198, 207]:
					app.gallery_replay_event = event
					app.show_gallery_replay()
					await process_frame
					var replay_cg = app.page.get_node_or_null("CharacterEventCG")
					expect(replay_cg != null, "replay CG loads")
					if replay_cg != null:
						expect(replay_cg.texture.resource_path.ends_with(expected + ".png"), "replay texture")
					await capture(locale + "_replay_" + str(beat) + ".png")
			var choices: Array = node.choices
			expect(app.game.choose_character_event(str(choices[0].id)), "advance")
		app.game.finish_character_event()
		app.show_gallery_entry(ID)
		await process_frame
		var cover = app.page.get_node_or_null("GalleryCG")
		expect(cover != null, "gallery cover")
		if cover != null:
			expect(cover.texture.resource_path.ends_with("record_sharing.png"), "gallery image")
			expect(cover.size == Vector2(570, 455), "gallery bounded")
		var caption: Label = app.page.get_node("GalleryCaption")
		var note: Label = app.page.get_node("GalleryReplayNote")
		expect(caption.get_global_rect().end.y <= note.global_position.y, "gallery text blocks do not overlap")
		expect(caption.get_line_count() * caption.get_line_height() <= caption.size.y, "gallery caption fits")
		await capture(locale + "_gallery.png")
	print("SHIORI LV2 CG NATIVE CHECKPOINTS: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
