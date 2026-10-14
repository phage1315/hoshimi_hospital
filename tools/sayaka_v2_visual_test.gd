extends SceneTree
## Native-window spot checks only; uses in-memory scene fixtures, never save slots.
const Event = preload("res://godot/systems/character_event_session.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		assert(app.content.load_all(locale))
		app.configure_game_content()
		app.game.meet_staff("doc_sayaka")
		app.game.advance_story_to_day(6, 540)
		for sample in [
			["sayaka_week1_phone_exchange", "v2_62"],
			["sayaka_week1_phone_exchange", "v2_110"],
			["sayaka_lv1_first_date", "v2_259"],
			["sayaka_lv1_first_date", "v2_325"],
			["sayaka_lv1_first_date", "v2_489"],
			["sayaka_lv1_first_date", "v2_497"],
			["sayaka_lv1_first_date", "v2_563"],
			["sayaka_lv1_first_date", "v2_599"],
			["sayaka_lv1_first_date", "v2_647"],
			["sayaka_lv1_monday_callback", "v2_680"],
		]:
			app.game.set_test_time(2 if sample[0] == "sayaka_week1_phone_exchange" else 7 if sample[0] == "sayaka_lv1_monday_callback" else 6, 540)
			var event = Event.new(app.game.character_event_definitions[sample[0]])
			event.node_id = sample[1]
			app.game.character_events[sample[0]] = event
			app.game.active_character_event_id = sample[0]
			app.reset_dialogue_page()
			app.show_character_event()
			await process_frame
			await RenderingServer.frame_post_draw
			var target := "/private/tmp/sayaka_v2_%s_%s.png" % [locale, sample[1]]
			var picture: Image = app.get_viewport().get_texture().get_image()
			assert(picture.save_png(target) == OK)
			print("NATIVE WINDOW: ", target)
			for index in range(1, app.authored_dialogue_pages(str(event.current().text)).size()):
				app.dialogue_page_index = index
				app.show_character_event()
				await process_frame
				await RenderingServer.frame_post_draw
				target = "/private/tmp/sayaka_v2_%s_%s_p%s.png" % [locale, sample[1], index]
				picture = app.get_viewport().get_texture().get_image()
				assert(picture.save_png(target) == OK)
				print("NATIVE WINDOW: ", target)
	app.queue_free()
	await process_frame
	quit()
