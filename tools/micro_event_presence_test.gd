extends SceneTree

var checks := 0
var failures := 0
var app

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func clear_micro(game) -> void:
	game.finish_micro_event()
	game.micro_events.clear()
	game.micro_event_order.clear()

func capture(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--visual"):
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "/private/tmp/hoshimi_micro_presence_" + label + ".png"
	expect(root.get_texture().get_image().save_png(path) == OK, "Native screenshot saved")
	print("VISUAL ", path)

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Localized content loads")
		app.configure_game_content()
		var game = app.game
		game.campaign_seed = 716281
		# Isolate ordinary encounters from higher-priority authored story scenes.
		game.character_event_definitions.clear()
		game.special_event_definitions.clear()
		for person in game.staff:
			game.meet_staff(person.id)
			game.relationships[person.id].familiarity = 100
		var fixtures: Dictionary = {}
		for day in range(1, 15):
			for clock in range(660, 1020, 30):
				game.set_test_time(day, clock)
				for site in ["rooftop", "lounge", "station", "clinic"]:
					var present: Array[String] = game.staff_present_at(site)
					var expected: Array[String] = []
					for definition in game.micro_event_definitions.values():
						if definition.context != "location_visit" or definition.location_id != site:
							continue
						var allowed: bool = definition.actor_id in present and clock >= int(definition.time_start) and clock <= int(definition.time_end)
						expect(game.micro_event_available(definition, "location_visit", site) == allowed, "Candidate requires actual presence: %s %s %s" % [locale, site, definition.id])
						if allowed:
							expected.append(str(definition.id))
					var before: int = game.elapsed()
					expect(game.has_micro_event("location_visit", site) == not expected.is_empty(), "Button availability matches present candidates")
					expect(game.staff_present_at(site) == present and game.elapsed() == before, "Eligibility checks do not reroll presence or consume time")
					var event = game.select_micro_event("location_visit", site)
					if expected.is_empty():
						expect(event == null and game.active_micro_event_id.is_empty(), "No offscreen actor can be selected")
					else:
						expect(event != null and event.definition.id in expected and event.definition.actor_id in present, "Selection only uses present actors")
						expect(game.select_micro_event("location_visit", site) == event, "Active scene remains stable")
					clear_micro(game)
					if site == "rooftop":
						if present == ["doc_asuka"] and not fixtures.has("asuka"):
							fixtures.asuka = [day, clock]
						if present.is_empty() and not fixtures.has("empty"):
							fixtures.empty = [day, clock]
						if present == ["nurse_haru"] and not expected.is_empty() and not fixtures.has("haru"):
							fixtures.haru = [day, clock]
		for label in ["asuka", "empty", "haru"]:
			expect(fixtures.has(label), "Real roster fixture exists: " + label)
			if not fixtures.has(label):
				continue
			game.set_test_time(fixtures[label][0], fixtures[label][1])
			var checkpoint: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
			for redraw in range(2):
				app.show_location("rooftop")
				expect(app.screen == "location", "Rooftop opens normally")
				expect((app.page.get_node_or_null("LocationMicroEvent") != null) == (label == "haru"), "Rooftop micro button matches actor: " + label)
				expect(game.restore(checkpoint), "In-memory checkpoint restores")
			app.show_location("rooftop")
			await capture(locale + "_" + label)
			if label == "asuka":
				var asuka_chats := 0
				for action in game.time_event_definitions.values():
					if action.actor_id == "doc_asuka" and action.location_id == "rooftop":
						asuka_chats += 1
				expect(asuka_chats == 1, "Approved Asuka rooftop chat is registered once")
				expect(app.page.get_node_or_null("TimeEvent_rooftop_chat_doc_asuka") != null, "Asuka now has her own chat, not another actor's micro event")
			if label == "haru":
				app.page.get_node("LocationMicroEvent").pressed.emit()
				expect(app.screen == "micro_event" and game.micro_events[game.active_micro_event_id].definition.actor_id == "nurse_haru", "Real button opens the visible actor's event")
				clear_micro(game)
				app.show_location("rooftop")
				# A stale callback after the time block changes must recheck presence.
				game.set_test_time(fixtures.empty[0], fixtures.empty[1])
				app.start_location_micro_event("rooftop")
				expect(game.active_micro_event_id.is_empty() and app.screen == "location", "Stale click cannot summon an absent actor")
				for child in app.get_children():
					if child is AcceptDialog:
						child.hide()
						child.confirmed.emit()
				await process_frame
	print("MICRO EVENT PRESENCE: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
