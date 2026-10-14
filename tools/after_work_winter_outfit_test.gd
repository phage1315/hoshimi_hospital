extends SceneTree

var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "load " + locale)
		app.configure_game_content()
		app.game.reset()
		for actor_id in ["nurse_haru", "doc_asuka", "doc_artoria", "doc_aoi", "nurse_hiroko", "doc_shiori", "doc_sayaka", "doc_minato", "doc_rei", "doc_emiko", "doc_aqua", "doc_sakura_anesthesiology", "nurse_yui", "nurse_rin", "nurse_ange", "nurse_moe", "nurse_satsuki", "pharmacist_manami", "nurse_ishigami", "visiting_futaba", "visiting_maya"]:
			var actor: Dictionary = app.content.find_record("staff", actor_id)
			var months := {}
			var boundaries := []
			for day in range(1, 366):
				var month: int = app.game.calendar_date(day).month
				months[month] = true
				var expected := "casual_winter" if month in [9, 10, 11, 12, 1, 2] else "casual"
				app.game.set_test_time(day + 1, 540)
				expect(app.after_work_outfit(actor, {"workday": day}) == expected, "departure date %s %d" % [locale, day])
				if month != int(app.game.calendar_date(day + 1).month):
					boundaries.append(day)
					boundaries.append(day + 1)
				# Actors lacking winter art retain their established fallback.
				for other in app.content.collections.staff:
					if other.visuals.portraits.has("casual_winter/neutral"):
						continue
					var portraits: Dictionary = other.visuals.portraits
					var fallback := "after_work" if portraits.has("after_work/neutral") else "casual" if portraits.has("casual/neutral") else str(other.visuals.default_outfit)
					expect(app.after_work_outfit(other, {"workday": day}) == fallback, "other actor changed " + str(other.id))
			expect(months.size() == 12, "all months covered")
			for day in boundaries:
				var month: int = app.game.calendar_date(day).month
				var expected := "casual_winter" if month in [9, 10, 11, 12, 1, 2] else "casual"
				for variant in ["normal", "night"]:
					for state in ["offer", "completed", "declined", "skipped"]:
						app.game.active_after_work_walk = {"workday": day, "variant": variant, "actor_id": actor_id, "departure_clock": 1160 if variant == "night" else 1040, "phase": "offer" if state == "offer" else "result", "outcome": state, "reward": 2}
						app.show_after_work_walk()
						var portrait: TextureRect = app.page.get_node("CharacterPortrait")
						expect(portrait.texture.resource_path == "res://" + str(actor.visuals.portraits[expected + "/neutral"]), "displayed outfit %s %d %s" % [locale, day, state])
						expect(portrait.texture.get_size() == Vector2(1024, 1536), "canvas")
						if "--capture" in OS.get_cmdline_user_args() and day == 245 and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/winter_%s_%s_%s_%s.png" % [actor_id, locale, variant, state])
						if "--capture-asuka-summer" in OS.get_cmdline_user_args() and actor_id == "doc_asuka" and day == 62 and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/summer_doc_asuka_%s_%s_%s.png" % [locale, variant, state])
						if "--capture-aoi" in OS.get_cmdline_user_args() and actor_id == "doc_aoi" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/aoi_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-hiroko-shiori" in OS.get_cmdline_user_args() and actor_id in ["nurse_hiroko", "doc_shiori"] and day == 245 and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/winter_batch_%s_%s_%s_%s.png" % [actor_id, locale, variant, state])
						if "--capture-sayaka-minato" in OS.get_cmdline_user_args() and actor_id in ["doc_sayaka", "doc_minato"] and day == 245 and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/winter_final_%s_%s_%s_%s.png" % [actor_id, locale, variant, state])
						if "--capture-rei" in OS.get_cmdline_user_args() and actor_id == "doc_rei" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/rei_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-emiko" in OS.get_cmdline_user_args() and actor_id == "doc_emiko" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/emiko_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-aqua" in OS.get_cmdline_user_args() and actor_id == "doc_aqua" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/aqua_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-sakura" in OS.get_cmdline_user_args() and actor_id == "doc_sakura_anesthesiology" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/sakura_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-yui" in OS.get_cmdline_user_args() and actor_id == "nurse_yui" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/yui_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-rin" in OS.get_cmdline_user_args() and actor_id == "nurse_rin" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/rin_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-ange" in OS.get_cmdline_user_args() and actor_id == "nurse_ange" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/ange_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-moe" in OS.get_cmdline_user_args() and actor_id == "nurse_moe" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/moe_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-satsuki" in OS.get_cmdline_user_args() and actor_id == "nurse_satsuki" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/satsuki_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-futaba" in OS.get_cmdline_user_args() and actor_id == "visiting_futaba" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/futaba_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-maya" in OS.get_cmdline_user_args() and actor_id == "visiting_maya" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/maya_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-manami-ishigami" in OS.get_cmdline_user_args() and actor_id == "pharmacist_manami" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/manami_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
						if "--capture-manami-ishigami" in OS.get_cmdline_user_args() and actor_id == "nurse_ishigami" and day in [62, 245] and state in ["offer", "completed"]:
							await process_frame
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/ishigami_casual_%s_%d_%s_%s.png" % [locale, day, variant, state])
			var fallback_actor: Dictionary = actor.duplicate(true)
			fallback_actor.visuals.portraits.erase("casual_winter/neutral")
			expect(app.after_work_outfit(fallback_actor, {"workday": 245}) == "casual", "missing winter mapping fallback")
	print("WINTER OUTFIT: %d checks; %d failures" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
