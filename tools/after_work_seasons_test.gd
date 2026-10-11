extends SceneTree

var checks := 0
var failures := 0
const MONTH_SEASONS := ["winter", "winter", "spring", "spring", "spring", "summer", "summer", "summer", "autumn", "autumn", "autumn", "winter"]

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
		expect(app.content.load_all(locale), "Content load failed: " + locale)
		app.configure_game_content()
		app.game.reset()
		var seen_months: Dictionary = {}
		for day in range(1, 366):
			var month: int = app.game.calendar_date(day).month
			var season: String = MONTH_SEASONS[month - 1]
			# The simulation can already be in next month while the walk is not.
			app.game.set_test_time(mini(day + 1, 365), 540)
			for variant in ["normal", "night"]:
				var walk := {"workday": day, "variant": variant, "actor_id": "nurse_haru", "departure_clock": 1160 if variant == "night" else 1040, "phase": "result", "outcome": "completed"}
				var expected := "after_work_street_" + season + ("_night" if variant == "night" else "")
				expect(app.after_work_background_id(walk) == expected, "%s day %d %s wrong season" % [locale, day, variant])
				if not seen_months.has(month):
					for state in ["offer", "declined", "skipped"]:
						var pending_walk := walk.duplicate(true)
						pending_walk.phase = "offer" if state == "offer" else "result"
						pending_walk.outcome = "" if state == "offer" else state
						var hospital_id := "hospital_night" if variant == "night" else "lobby"
						expect(app.after_work_background_id(pending_walk) == hospital_id, "Street shown before mutual acceptance: " + state)
						app.game.active_after_work_walk = pending_walk
						app.show_after_work_walk()
						var pending_background: TextureRect = app.page.get_node("SceneBackground")
						expect(pending_background.texture.resource_path == "res://" + app.background_path(hospital_id), "Wrong hospital texture before acceptance")
					app.game.active_after_work_walk = walk
					app.show_after_work_walk()
					var background: TextureRect = app.page.get_node("SceneBackground")
					var filename := "street_placeholder.png" if season == "summer" else "street_%s.png" % season
					if variant == "night":
						filename = "street_%s_night.png" % season
						expect(is_zero_approx(app.page.get_node("AfterWorkShade").color.a), "Night art received a second dark overlay")
						expect(is_equal_approx(app.page.get_node("BackgroundWash").color.a, 0.12), "Night art lost light UI wash")
					expect(background.texture.resource_path.ends_with("after_work_v1/" + filename), "Wrong rendered seasonal texture")
					expect(background.texture.get_size() == Vector2(1672, 941), "Season canvas differs from reference")
			seen_months[month] = true
		expect(seen_months.size() == 12, "Did not cover all months")
		# Registered night art must take priority, without altering the day selection.
		expect(app.after_work_background_id({"workday": 245, "variant": "night", "phase": "result", "outcome": "completed"}) == "after_work_street_winter_night", "Dedicated seasonal night override ignored")
		expect(app.after_work_background_id({"workday": 245, "variant": "normal", "phase": "result", "outcome": "completed"}) == "after_work_street_winter", "Night override affected daytime")
	print("AFTER WORK SEASONS: %s checks; %s failure(s)" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
