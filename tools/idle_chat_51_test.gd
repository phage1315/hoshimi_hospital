extends SceneTree

var checks := 0
var failures := 0
var app
var fixtures: Array
var saved_chinese: Dictionary = {}

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func seed_for_variant(variant: int) -> int:
	for candidate in range(100):
		seed(candidate)
		if randi_range(0, 2) == variant:
			return candidate
	return -1

func no_spaces(text: String) -> String:
	return text.replace(" ", "").replace("\n", "").replace("\r", "")

func screenshot(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--visual"):
		return
	await RenderingServer.frame_post_draw
	var path := "/private/tmp/hoshimi_idle_chat_" + label + ".png"
	expect(root.get_texture().get_image().save_png(path) == OK, "Native screenshot saved")
	print("VISUAL ", path)

func run() -> void:
	fixtures = JSON.parse_string(FileAccess.get_file_as_string("res://tools/fixtures/idle_chat_51.json"))
	app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load localized content")
		app.configure_game_content()
		var game = app.game
		game.campaign_seed = 716281
		game.character_event_definitions.clear()
		game.special_event_definitions.clear()
		for source in fixtures:
			var actor: String = source.actor_id
			var site: String = source.location_id
			var event_id: String = source.id
			var definition: Dictionary = game.time_event_definitions[event_id]
			for relation in game.relationships.values():
				relation.met = false
			game.meet_staff(actor)
			game.set_test_time(7, 720)
			if site == "rooftop":
				for clock in range(540, 960, 30):
					game.set_test_time(7, clock)
					if actor in game.staff_present_at(site):
						break
			expect(actor in game.staff_present_at(site), "Fixture has actual present actor: " + actor)
			expect(definition.actor_id == actor and definition.location_id == site and definition.responses.size() == 3, "Identity and three variants loaded")
			if locale == "zh_CN":
				expect(definition.responses == source.responses, "Exact Chinese wording and order")
			else:
				for i in range(3):
					expect(definition.responses[i] == app.content.localizer.strings["collections.time_events.%s.responses.%s" % [event_id, i]], "English variant resolves its own key")
			var checkpoint: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
			for variant in range(3):
				expect(game.restore(checkpoint), "Restore independent starting state")
				app.show_location(site, false, false)
				var button: Button = app.page.find_child("TimeEvent_" + event_id, true, false)
				expect(button != null, "Present actor has a real localized chat button")
				if button == null:
					continue
				var before: int = game.elapsed()
				var relations_before := JSON.stringify(game.relationships)
				var chosen_seed := seed_for_variant(variant)
				expect(chosen_seed >= 0, "Seed exercises requested random response")
				seed(chosen_seed)
				button.pressed.emit()
				expect(app.screen == "time_event_result", "Chat enters its result page")
				expect(game.last_time_event_response == definition.responses[variant], "Actual random selection matches expected variant")
				expect(game.elapsed() == before + 30, "One chat costs exactly 30 minutes")
				expect(JSON.stringify(game.relationships) == relations_before, "Chat adds no familiarity/affection/flags")
				var full := ""
				var page_index := 0
				while page_index < 20:
					await process_frame
					var body: RichTextLabel = app.page.get_node("TimeEventDialogue")
					full += body.text
					expect(body.get_content_height() <= body.size.y, "Dialogue fits: %s/%s/%s/page%s" % [locale, event_id, variant, page_index])
					var actor_name: String = game.staff_record(actor).name
					var correct_speaker := false
					for child in app.page.get_children():
						if child is Label and child.text == actor_name:
							correct_speaker = true
					expect(correct_speaker, "No automatic Sakaguchi speaker switch")
					if variant == 0 and actor in ["doc_asuka", "doc_sakura_anesthesiology"]:
						await screenshot("%s_%s_%s_page%s" % [locale, event_id, variant, page_index])
					var next: Button = app.page.get_node_or_null("TimeEventDialogueContinue")
					page_index += 1
					if next == null:
						break
					next.pressed.emit()
				expect(page_index < 20 and no_spaces(full) == no_spaces(definition.responses[variant]), "Every character survives pagination")
				app.page.get_node("TimeEventDialogueFinish").pressed.emit()
				expect(app.screen == "location" and game.elapsed() == before + 30, "Finish returns without duplicate charge")
				var saved: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
				expect(game.restore(saved), "Chat history restores from JSON")
				var history: Array = game.time_history()
				expect(history.back().id == event_id and history.back().response == definition.responses[variant], "Saved variant is preserved")
				if locale == "zh_CN":
					saved_chinese[event_id + ":" + str(variant)] = saved
			# Absence blocks both the visible button and direct execution.
			expect(game.restore(checkpoint), "Restore absence fixture")
			game.relationships[actor].met = false
			app.show_location(site, false, false)
			expect(app.page.find_child("TimeEvent_" + event_id, true, false) == null, "Absent actor has no chat button")
			var absent_time: int = game.elapsed()
			expect(not game.spend_time(event_id) and game.elapsed() == absent_time, "Absent actor cannot be summoned by a direct call")
		if locale == "en":
			for key in saved_chinese:
				expect(game.restore(saved_chinese[key]), "Chinese history restores in English")
				var parts: PackedStringArray = str(key).split(":")
				expect(game.time_history().back().response == game.time_event_definitions[parts[0]].responses[int(parts[1])], "History uses saved variant in selected language")
	print("IDLE CHAT 51: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
