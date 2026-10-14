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
	app.dialogue_auto_enabled = false
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Cannot load " + locale)
		app.configure_game_content()
		app.game.reset()
		var casual_count := 0
		var fallback_count := 0
		for actor in app.content.collections.staff:
			var portraits: Dictionary = actor.get("visuals", {}).get("portraits", {})
			var outfit := str(actor.get("visuals", {}).get("default_outfit", "uniform"))
			if portraits.has("after_work/neutral"):
				outfit = "after_work"
				casual_count += 1
			elif portraits.has("casual/neutral"):
				outfit = "casual"
				casual_count += 1
			else:
				fallback_count += 1
				if not portraits.has(outfit + "/neutral"):
					outfit = "uniform"
			expect(app.after_work_outfit(actor) == outfit, "Wrong departure outfit: " + str(actor.id))
			var expected_path := str(portraits.get(outfit + "/neutral", ""))
			expect(not expected_path.is_empty() and ResourceLoader.exists("res://" + expected_path), "Missing outfit resource: " + str(actor.id))
			for variant in ["normal", "night"]:
				for state in ["offer", "completed", "declined", "skipped"]:
					app.game.active_after_work_walk = {
						"workday": 1, "actor_id": actor.id, "variant": variant,
						"departure_clock": 1160 if variant == "night" else 1040,
						"phase": "offer" if state == "offer" else "result",
						"outcome": "" if state == "offer" else state, "reward": 0,
					}
					app.show_after_work_walk()
					var portrait := app.page.get_node_or_null("CharacterPortrait") as TextureRect
					var context := "%s/%s/%s/%s" % [locale, actor.id, variant, state]
					expect(portrait != null and portrait.texture != null, "Missing portrait: " + context)
					if portrait != null and portrait.texture != null:
						expect(portrait.texture.resource_path == "res://" + expected_path, "Outfit changed during walk: " + context)
					var background_id: String = app.after_work_background_id(app.game.active_after_work_walk)
					expect(background_id.begins_with("after_work_street_") == (state == "completed"), "Outfit change affected street gate: " + context)
					if state == "offer":
						expect(app.page.get_node_or_null("AfterWorkInvite") != null, "Invitation not rendered: " + context)
					await process_frame
		print("%s: %d off-duty portraits, %d work-outfit fallbacks" % [locale, casual_count, fallback_count])
		# Future dedicated after_work art must still take precedence over casual.
		var fixture := {"visuals": {"default_outfit": "uniform", "portraits": {
			"after_work/neutral": "after.png", "casual/neutral": "casual.png", "uniform/neutral": "uniform.png"}}}
		expect(app.after_work_outfit(fixture) == "after_work", "Dedicated departure art lost priority")
		fixture.visuals.portraits.erase("after_work/neutral")
		expect(app.after_work_outfit(fixture) == "casual", "Newly registered casual art needs extra routing")
		fixture.visuals.portraits.erase("casual/neutral")
		expect(app.after_work_outfit(fixture) == "uniform", "Missing casual art broke fallback")
	app.queue_free()
	await process_frame
	print("AFTER WORK OUTFIT: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures else 0)
