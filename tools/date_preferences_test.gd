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
	var approved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://research/imports/date_preferences_2026-10-12.json")).approved_mapping
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		var game = app.game
		game.reset()
		expect(game.date_profile_definitions.size() == 21, "21 profiles")
		for actor_id in approved:
			var profile: Dictionary = game.date_profile_definitions[actor_id]
			expect(profile.preferred_locations == approved[actor_id], "Approved mapping " + actor_id)
			expect(bool(profile.can_date) == (actor_id not in ["nurse_ange", "nurse_ishigami", "doc_sakura_anesthesiology", "visiting_futaba", "visiting_maya"]), "Approved invitation availability " + actor_id)
			var normal: int = game.date_familiarity_reward(actor_id)
			for location in app.content.collections.date_locations:
				var id := str(location.id)
				var liked: bool = id in approved[actor_id]
				expect(is_equal_approx(game.date_location_familiarity_multiplier(actor_id, id), 1.2 if liked else 1.0), "Multiplier " + actor_id + "/" + id)
				expect(game.date_familiarity_reward(actor_id, id) == (roundi(normal * 1.2) if liked else normal), "Reward " + actor_id + "/" + id)
			for id in approved[actor_id]:
				var sunday := 0
				for day in range(1, 366):
					if game.calendar_date(day).weekday_id == "sun" and game.date_location_available(id, day):
						sunday = day
						break
				game.reset()
				game.meet_staff(actor_id)
				# Use a normal early-game save fixture, then advance to the seasonal date.
				game.set_test_time(6, 540)
				game.relation_for(actor_id).familiarity = 0
				# Isolated reward fixture; production gates are covered by sunday_date_flow_test.
				game.date_profile_definitions[actor_id] = {"can_date": true, "minimum_level": 0, "always_accept": true, "dialogue": {"satisfied": {"text": "fixture"}}, "preferred_locations": approved[actor_id].duplicate()}
				var reward: int = game.date_familiarity_reward(actor_id, id)
				var snapshot: Dictionary = game.snapshot()
				expect(game.restore(JSON.parse_string(JSON.stringify(snapshot))), "Existing snapshot restores " + actor_id + "/" + str(id) + " error=" + game.last_error)
				expect(game.date_familiarity_reward(actor_id, id) == reward, "Reward stable after reload")
				game.set_test_time(sunday, 540)
				expect(game.complete_sunday_activity("date", actor_id, id), "Date settlement")
				expect(game.relation_for(actor_id).familiarity == mini(100, reward), "Actual familiarity award")
				expect(not game.complete_sunday_activity("date", actor_id, id), "No duplicate award")
		game.reset()
		expect(game.date_familiarity_reward("doc_aoi", "cafe") == 10, "8 points rounds to 10")
		expect(game.date_familiarity_reward("doc_sayaka", "restaurant_bar") == 22, "18 points rounds to 22")
		expect(game.date_familiarity_reward("doc_emiko", "jazz_bar") == 6, "5 points becomes 6")
		game.date_profile_definitions.doc_minato.disliked_locations = ["aquarium"]
		expect(game.date_familiarity_reward("doc_minato", "aquarium") == game.date_familiarity_reward("doc_minato"), "Legacy dislike has no penalty")
		game.date_profile_definitions.doc_minato.preferred_locations.append("hotel")
		expect(game.date_location_familiarity_multiplier("doc_minato", "hotel") == 1.0, "Hotel never gets preference bonus")
		expect(game.date_location_familiarity_multiplier("unknown", "cafe") == 1.0, "Missing profile fallback")
		expect(game.date_location_familiarity_multiplier("doc_minato", "unknown") == 1.0, "Missing location fallback")
		game.meet_staff("doc_minato")
		game.set_test_time(6, 540)
		game.relation_for("doc_minato").familiarity = 99
		game.relation_for("doc_minato").level = 4
		game.relation_for("doc_minato").flags.append("minato_intro_complete")
		game.complete_sunday_activity("date", "doc_minato", "cafe")
		expect(game.relation_for("doc_minato").familiarity == 100, "Existing cap preserved")
	print("DATE PREFERENCES: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
