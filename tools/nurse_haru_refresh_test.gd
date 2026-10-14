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
		var actor: Dictionary = app.content.find_record("staff", "nurse_haru")
		expect(app.after_work_outfit(actor) == "casual", "casual selection " + locale)
		for expression in ["neutral", "smile", "serious", "worried", "surprised", "tired"]:
			app.show_map()
			app.add_portrait(actor, expression, "uniform")
			var portrait: TextureRect = app.page.get_node("CharacterPortrait")
			expect(portrait.texture.resource_path == "res://assets/characters/nurse_haru_refresh_v1/uniform/" + expression + ".png", "uniform texture " + expression)
			expect(portrait.texture.get_size() == Vector2(1024, 1536), "uniform canvas " + expression)
		for day in [1, 62, 154, 245]:
			for variant in ["normal", "night"]:
				for state in ["offer", "completed", "declined", "skipped"]:
					var walk := {"workday": day, "variant": variant, "actor_id": "nurse_haru", "departure_clock": 1160 if variant == "night" else 1040, "phase": "offer" if state == "offer" else "result", "outcome": "" if state == "offer" else state, "reward": 2}
					app.game.active_after_work_walk = walk
					app.show_after_work_walk()
					var portrait: TextureRect = app.page.get_node("CharacterPortrait")
					var expected_outfit := "casual_winter" if day in [154, 245] else "casual"
					expect(portrait.texture.resource_path == "res://assets/characters/nurse_haru_refresh_v1/" + expected_outfit + "/neutral.png", "walk texture " + locale + state)
					expect(portrait.position == Vector2(785, 150) and portrait.size == Vector2(405, 485), "walk placement")
					var background_id: String = app.after_work_background_id(walk)
					expect(background_id.begins_with("after_work_street_") if state == "completed" else background_id in ["lobby", "hospital_night"], "background gate " + state)
					if state == "offer":
						var invite: Button = app.page.get_node("AfterWorkInvite")
						expect(invite.text == app.tx("ui.after_work.invite", "要一起走去车站吗？"), "localized invite")
					if "--capture" in OS.get_cmdline_user_args() and state in ["offer", "completed"]:
						await process_frame
						await RenderingServer.frame_post_draw
						get_root().get_texture().get_image().save_png("/tmp/haru_%s_%d_%s_%s.png" % [locale, day, variant, state])
	print("HARU REFRESH: %d checks; %d failures" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
