extends SceneTree

const EVENT := "intro_doc_rei"
const Session = preload("res://godot/systems/character_event_session.gd")
var checks := 0
var failures := 0

func expect(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(note)

func _initialize() -> void:
	call_deferred("run")

func check_turn(app, node: Dictionary, replay: bool, locale: String) -> void:
	var body_name := "GalleryReplayDialogue" if replay else "CharacterEventDialogue"
	var next_name := "ReplayDialogueContinue" if replay else "EventDialogueContinue"
	var names := {"actor": str(app.game.staff_record("doc_rei").name), "player": str(app.protagonist_name()), "narrator": "旁白" if locale == "zh_CN" else "Narrator"}
	var expected := str(node.get("speaker_label", names[str(node.speaker)]))
	var rendered := ""
	var page_count := 0
	for i in range(20):
		page_count += 1
		var found := false
		for child in app.page.get_children():
			if child is Label and child.text == expected:
				found = true
		expect(found, "%s %s speaker %s (replay=%s)" % [locale, node.id, expected, replay])
		var body = app.page.get_node_or_null(body_name)
		expect(body != null, "Dialogue body exists")
		if body != null:
			rendered += str(body.text)
		var next_page = app.page.get_node_or_null(next_name)
		if next_page == null:
			break
		next_page.pressed.emit()
	expect(rendered == str(node.text), "Rendered pages preserve exact text: " + str(node.id))
	if locale == "zh_CN":
		expect(page_count == 1, "Short authored Chinese turn is not split at quoted terms: " + str(node.id))
	if str(node.id) in ["m0_0055", "m0_0056"]:
		expect(app.page.get_node_or_null("CharacterPortrait") == null, "Departed Kaori no longer pictured in examination room")
	if str(node.id) in ["m0_0043", "m0_0046", "m0_0048"]:
		var portrait = app.page.get_node_or_null("CharacterPortrait")
		expect(portrait != null, "Existing nurse portrait retained")
		if portrait != null:
			var nurse: Dictionary = app.game.staff_record("nurse_sonoda_itsumi")
			expect(portrait.texture.resource_path == "res://" + str(nurse.visuals.portraits["scrubs/" + str(node.expression)]), "Correct nurse visual")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		var g = app.game
		var definition: Dictionary = g.character_event_definitions[EVENT]
		g.character_event_definitions = {EVENT: definition}
		for branch in ["answer_with_work", "remark_on_standards"]:
			g.reset()
			g.set_test_time(1, 540)
			expect("doc_rei" in g.staff_present_at("exam"), "Before introduction Kaori is at examination room")
			var event = g.start_character_event(EVENT)
			expect(event != null, "Start natural introduction")
			if event == null:
				continue
			for step in range(60):
				if event.completed:
					break
				app.show_character_event()
				var n: Dictionary = event.current()
				check_turn(app, n, false, locale)
				expect(g.choose_character_event(branch if n.id == "m0_0039" else str(n.choices[0].id)), "Advance natural branch")
			expect(event.completed, "Both branches finish")
			app.show_character_event_complete()
			expect(app.page.get_node_or_null("CharacterPortrait") == null, "Completion does not return Kaori to exam visually")
			g.finish_character_event()
			expect(g.relation_for("doc_rei").level == 0, "Introduction keeps Lv0")
			for clock in [600, 720, 960]:
				g.set_test_time(1, clock)
				expect("doc_rei" in g.staff_present_at("or"), "Same-day departure to operating room")
				for location in ["exam", "lounge", "rooftop"]:
					expect("doc_rei" not in g.staff_present_at(location), "No duplicate presence: " + location)
			expect(g.restore(JSON.parse_string(JSON.stringify(g.snapshot()))), "Completed save restores")
			expect("doc_rei" in g.staff_present_at("or") and "doc_rei" not in g.staff_present_at("exam"), "Departure survives save/load")
			g.active_staff_patient = {"staff_id": "doc_rei"}
			expect("doc_rei" not in g.staff_present_at("or"), "Patient cannot simultaneously be working in OR")
			g.active_staff_patient.clear()
			g.set_test_time(2, 600)
			var known: Array[String] = g.known_staff_ids()
			for location in ["exam", "or", "lounge", "rooftop"]:
				expect(("doc_rei" in g.staff_present_at(location)) == ("doc_rei" in g.presence_resolver.staff_at(location, 2, 600, known)), "Next day restores normal schedule: " + location)
		# Gallery and event-test share the replay screen, but neither may move staff.
		var before: String = JSON.stringify(g.snapshot())
		for test_mode in [false, true]:
			app.gallery_replay_event = Session.new(definition)
			app.gallery_replay_is_test = test_mode
			for n in definition.nodes:
				app.gallery_replay_event.node_id = str(n.id)
				app.reset_dialogue_page()
				app.show_gallery_replay()
				check_turn(app, n, true, locale)
			expect(JSON.stringify(g.snapshot()) == before, "Replay/test does not change world state")
	print("KAORI INTRO PRESENTATION: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
