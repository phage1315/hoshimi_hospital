extends SceneTree
## Memory-only UI/regression fixture. No player save slots or settings touched.
const Game = preload("res://godot/systems/game_state.gd")
const Presence = preload("res://godot/systems/presence_resolver.gd")
const ID := "sayaka_lv3_relationship"
const PREVIOUS := "sayaka_lv2_working_hours"
const FLAGS := ["sayaka_lv3_romance_confirmed", "sayaka_first_kiss_happened"]
var app
var checks := 0
var failures := 0

class FixedPresence extends Presence:
	var names: Array[String] = []
	func staff_at(_location: String, _day: int, _clock: int, eligible: Array[String]) -> Array[String]:
		var result: Array[String] = []
		for actor in names:
			if actor in eligible:
				result.append(actor)
		return result

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func configure(game) -> void:
	var c = app.content.collections
	game.configure(c.encounters, c.preops, c.staff, c.time_events, c.surgeries, c.patients, c.relationships, c.character_events, c.case_templates, c.micro_events, c.examination_cg_pools, c.surgery_team_dialogue_profiles, c.patient_interactions, c.temporary_conditions, c.staff_role_cg_rewards, c.special_events, c.special_event_steps, c.date_profiles, c.date_locations)

func prepare(game, nurse: String = "fallback", day: int = 4, clock: int = 1019) -> void:
	game.reset()
	game.meet_staff("doc_sayaka")
	expect(game._complete_character_event_for_test(PREVIOUS, 1), "Lv2 prerequisite fixture")
	var relation: Dictionary = game.relation_for("doc_sayaka")
	relation.level = 2
	relation.familiarity = 40
	relation.affection = 20
	relation.rank_history = [PREVIOUS]
	game.set_test_player_attribute("charm", 10)
	game.set_test_time(day, clock)
	# Account for the completed prerequisite fixture, not just free-time ledger.
	game.story_time_advance_minutes -= game.elapsed() - ((day - 1) * 480 + clock - 540)
	var presence := FixedPresence.new()
	if nurse != "fallback":
		game.meet_staff("nurse_" + nurse)
		presence.names.append("nurse_" + nurse)
	game.presence_resolver = presence
	game.active_id = ""
	game.active_mode = "encounter"
	app.dialogue_auto_enabled = false

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/tmp/hoshimi_next20_unused_sayaka_lv3_pacing_test_"+str(OS.get_process_id())+".json"
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		check_gates()
		check_presence()
		for nurse in ["haru", "hiroko", "fallback"]:
			for answer in ["answer_a", "answer_b"]:
				await check_route(locale, nurse, answer)
		check_old_completed_saves()
	check_clock_boundaries()
	app.queue_free()
	await process_frame
	print("SAYAKA LV3 PACING: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

func check_route(locale: String, nurse: String, answer: String) -> void:
	var game = app.game
	prepare(game, nurse)
	var before: int = game.elapsed()
	var attributes: Dictionary = game.player_attributes().duplicate(true)
	var cases: Dictionary = game.snapshot()
	var event = game.start_character_event(ID)
	expect(event != null, "Start " + nurse)
	if event == null:
		return
	expect(event.node_id == "scene_01_" + nurse, "Actual opening resolver " + nurse)
	app.reset_dialogue_page()
	app.show_character_event()
	var visited: Array[String] = []
	var decisions := 0
	for _step in range(130):
		if event.completed:
			break
		var node: Dictionary = event.current()
		visited.append(str(node.id))
		expect(game.relationship_level("doc_sayaka") == 2, "No premature Lv3")
		for flag in FLAGS:
			expect(not game.relation_for("doc_sayaka").flags.has(flag), "No premature completion flag")
		expect(not game.can_save_progress(), "No save during event")
		expect(game.elapsed() == before, "No per-line time charge")
		await check_render(node, locale, nurse, answer)
		var choice: Dictionary = node.choices[0]
		if node.choices.size() > 1:
			decisions += 1
			expect(node.id == "scene_05" and node.choices.size() == 2, "Only original two-way choice")
			for candidate in node.choices:
				if candidate.id == answer:
					choice = candidate
		var button: Button = app.page.get_node_or_null("EventChoice_" + str(choice.id))
		expect(button != null, "Real UI button " + choice.id)
		if button == null:
			break
		button.pressed.emit()
		await process_frame
	expect(event.completed and decisions == 1, "Complete with one decision")
	expect(visited.size() == (98 if nurse == "haru" else 92), "Exact route length")
	expect(visited.has("lv3_v2_166") == (nurse == "haru"), "Ren-only extra")
	expect(visited.has("lv3_v2_296") == (answer == "answer_a"), "Only chosen answer A")
	expect(visited.has("lv3_v2_310") == (answer == "answer_b"), "Only chosen answer B")
	expect(visited.count("lv3_v2_138") == 1 and visited.count("lv3_v2_347") == 1 and visited.back() == "scene_12", "One shared core, kiss, farewell")
	var relation: Dictionary = game.relation_for("doc_sayaka")
	expect(relation.level == 3 and relation.familiarity == 40 and relation.affection == 20, "Lv3; no numeric rewards")
	for flag in FLAGS:
		expect(relation.flags.count(flag) == 1, "Flag once")
	expect(relation.event_history.count(ID) == 1 and relation.rank_history.count(ID) == 1, "Completion once")
	expect(game.player_attributes() == attributes, "No attribute gains")
	for key in ["progress", "preops", "patient_cases", "completed_surgeries_total", "surgery_xp", "leadership_xp", "adult_intimacy_unlocks", "sunday_history"]:
		expect(cases.has(key) and game.snapshot()[key] == cases[key], "No extra clinical/date/intimacy effects: " + key)
	expect(event.definition.minutes == 60 and event.completed_day == 4, "Original 60 minutes, actual Friday completion")
	expect(game.day_number() == 5 and game.clock_text() == "09:00" and game.elapsed() == 1920, "Friday 16:59 -> Saturday 09:00, NOT Sunday")
	expect(app.screen == "day_transition" and game.active_after_work_walk.is_empty(), "No ordinary after-work overlay/reward")
	var elapsed: int = game.elapsed()
	var final_relation: Dictionary = relation.duplicate(true)
	expect(not game.choose_character_event("finish_lv3"), "No double completion")
	expect(game.elapsed() == elapsed and relation == final_relation, "No duplicate time/rewards")
	app.continue_after_day_transition()
	await process_frame
	expect(app.screen == "map" and game.active_character_event_id.is_empty(), "Existing next-day boundary returns to hospital map")
	expect(game.day_number() == 5 and game.clock_text() == "09:00", "Continue button does not add another day")
	game.finish_character_event()
	expect(game.can_save_progress(), "Save unlocked outside event")
	expect(game.restore(JSON.parse_string(JSON.stringify(game.snapshot()))), "Completed checkpoint restores")
	expect(game.elapsed() == elapsed and game.relation_for("doc_sayaka") == final_relation, "Checkpoint preserves time/rank")
	expect(game.start_character_event(ID) == null, "No repeat event")
	print("LV3 ROUTE ", locale, "/", nurse, "/", answer, ": ", visited.size(), " turns; Friday -> Saturday; Lv3")

func check_render(node: Dictionary, locale: String, nurse: String, answer: String) -> void:
	var pages: Array = app.authored_dialogue_pages(str(node.text))
	expect("".join(pages) == str(node.text), "Exact pagination " + node.id)
	for page_index in range(pages.size()):
		app.dialogue_page_index = page_index
		app.show_character_event()
		await process_frame
		var body: RichTextLabel = app.page.get_node("CharacterEventDialogue")
		expect(body.text == str(pages[page_index]), "Exact rendered text " + node.id)
		expect(body.get_content_height() <= body.size.y, "Text fits " + locale + "/" + node.id)
		var default_name: String = app.protagonist_name() if node.speaker == "player" else str(app.content.find_record("staff", "doc_sayaka").name) if node.speaker == "actor" else app.tx("ui.auto.ed1d855fc574", "旁白")
		var speaker_ok := false
		for child in app.page.get_children():
			if child is Label and child.position == Vector2(82, 558):
				speaker_ok = child.text == str(node.get("speaker_label", default_name))
			if child is Button:
				expect(child.text != app.tx("ui.auto.fadf24dbc5a9", "保存"), "No unusable save button")
		expect(speaker_ok, "Authored speaker " + node.id)
		var portrait: TextureRect = app.page.get_node_or_null("CharacterPortrait")
		if node.get("hide_portrait", false):
			expect(portrait == null, "Generic nurse does not impersonate a named nurse")
		else:
			var actor: Dictionary = app.content.find_record("staff", str(node.get("actor_id", "doc_sayaka")))
			expect(portrait != null and portrait.texture.resource_path == "res://" + str(actor.visuals.portraits[str(node.outfit) + "/" + str(node.expression)]), "Correct registered portrait/outfit " + node.id)
		if locale == "en":
			var han := RegEx.new()
			han.compile("[\\x{3400}-\\x{9fff}]")
			expect(han.search(body.text) == null, "No Chinese in English runtime")
		if OS.get_cmdline_user_args().has("--visual") and page_index == 0 and answer == "answer_b" and node.id in ["lv3_v2_68", "lv3_v2_72", "lv3_v2_76", "lv3_v2_193", "lv3_v2_224", "scene_05", "lv3_v2_347", "scene_12"] and (nurse == "haru" or node.id in ["lv3_v2_72", "lv3_v2_76"]):
			await RenderingServer.frame_post_draw
			expect(app.get_viewport().get_texture().get_image().save_png("/private/tmp/hoshimi_lv3_%s_%s_%s.png" % [locale, nurse, node.id]) == OK, "Native capture")

func check_gates() -> void:
	var game = app.game
	prepare(game)
	var definition: Dictionary = game.character_event_definitions[ID]
	expect(game.next_after_work_character_event().get("id", "") == ID, "Original after-work entry")
	game.relation_for("doc_sayaka").familiarity = 39
	expect(not game.character_event_available(definition), "Fam39 blocked")
	game.relation_for("doc_sayaka").familiarity = 40
	game.set_test_player_attribute("charm", 9)
	expect(not game.character_event_available(definition), "Charm9 blocked")
	game.set_test_player_attribute("charm", 10)
	expect(game.character_event_available(definition), "Fam40 Charm10 eligible")
	game.character_events[PREVIOUS].completed_day = 2
	expect(not game.character_event_available(definition), "Lv2 +2 blocked")
	game.character_events[PREVIOUS].completed_day = 1
	game.relation_for("doc_sayaka").level = 1
	expect(not game.character_event_available(definition), "Lv1 blocked")
	prepare(game)
	game.character_events.erase(PREVIOUS)
	expect(not game.character_event_available(definition), "Missing Lv2 blocked")
	prepare(game, "fallback", 4, 959)
	expect(game.next_after_work_character_event().get("id", "") != ID, "Before 16:00 not queued")
	prepare(game, "fallback", 4, 960)
	expect(game.next_after_work_character_event().get("id", "") == ID, "16:00 inclusive")

func check_presence() -> void:
	var game = app.game
	prepare(game, "haru")
	game.meet_staff("nurse_hiroko")
	game.presence_resolver.names.append("nurse_hiroko")
	expect(game.character_event_opening_node(game.character_event_definitions[ID]) == "scene_01_haru", "Ren wins over Hiroko when both present")
	game.relation_for("nurse_haru").met = false
	expect(game.character_event_opening_node(game.character_event_definitions[ID]) == "scene_01_hiroko", "Unmet Ren excluded; Hiroko selected")
	game.relation_for("nurse_hiroko").met = false
	expect(game.character_event_opening_node(game.character_event_definitions[ID]) == "scene_01_fallback", "Neither known -> generic")
	# Also exercise the real hourly presence draw, without forcing a start node.
	var found: Dictionary = {}
	for day in range(4, 80):
		prepare(game, "fallback", day)
		for actor in ["nurse_haru", "nurse_hiroko"]:
			game.meet_staff(actor)
		game.presence_resolver = Presence.new(app.content.collections.staff)
		var present: Array[String] = game.staff_present_at("lounge")
		var expected := "scene_01_haru" if "nurse_haru" in present else "scene_01_hiroko" if "nurse_hiroko" in present else "scene_01_fallback"
		expect(game.character_event_opening_node(game.character_event_definitions[ID]) == expected, "Real calendar roster selects actual observer")
		found[expected] = true
	# The approved hourly-location update gives Hiroko lounge eligibility too.
	expect(found.has("scene_01_haru") and found.has("scene_01_fallback") and found.has("scene_01_hiroko"), "Real hourly roster makes all three openings reachable")

func check_clock_boundaries() -> void:
	for pair in [[4, 960], [4, 1019], [5, 1019]]:
		var game = app.game
		prepare(game, "fallback", pair[0], pair[1])
		var event = game.start_character_event(ID)
		for _step in range(130):
			if event.completed:
				break
			app.choose_character_event(str(event.current().choices[0].id))
		expect(event.completed and event.completed_day == pair[0], "Completed workday preserved")
		expect(game.day_number() == pair[0] + 1 and game.clock_text() == "09:00", "Only next day at clock boundary")
		expect(game.elapsed() >= (pair[0] - 1) * 480 + pair[1] - 540, "Clock never reverses")
		expect(game.active_after_work_walk.is_empty(), "No second departure")
		app.continue_after_day_transition()
		expect(game.day_number() == pair[0] + 1 and game.clock_text() == "09:00", "No second transition")
	# Without the UI's night-to-morning transition, the definition charges 60 once.
	prepare(app.game)
	var event = app.game.start_character_event(ID)
	var before: int = app.game.elapsed()
	for _step in range(130):
		if event.completed:
			break
		expect(app.game.choose_character_event(str(event.current().choices[0].id)), "Raw session advances")
	expect(app.game.elapsed() == before + 60, "Exactly 60 event minutes before overtime/day UI settlement")

func check_old_completed_saves() -> void:
	var old: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tools/fixtures/sayaka_lv3_v1_event.json"))
	for nurse in ["haru", "hiroko", "fallback"]:
		for answer in ["answer_a", "answer_b"]:
			var game = Game.new()
			configure(game)
			prepare(game, nurse)
			game.character_event_definitions[ID] = old
			var event = game.start_character_event(ID)
			for _step in range(30):
				if event.completed:
					break
				var choice_id: String = event.current().choices[0].id
				for choice in event.current().choices:
					if choice.id == answer:
						choice_id = answer
				expect(game.choose_character_event(choice_id), "Old graph choice")
			expect(event.completed, "Old route completed fixture")
			game.finish_character_event()
			var original: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
			var elapsed: int = game.elapsed()
			var relation: Dictionary = game.relation_for("doc_sayaka").duplicate(true)
			for version in [35, 36]:
				var snapshot: Dictionary = original.duplicate(true)
				if version == 35:
					snapshot.version = 35
					snapshot.erase("save_format")
					for i in range(snapshot.character_events.size()):
						var record: Dictionary = snapshot.character_events[i]
						snapshot.character_events[i] = {"id":record.id, "choices":record.state.choices, "completed_day":record.state.completed_day}
				var restored = Game.new()
				configure(restored)
				expect(restored.restore(snapshot), "Old completed Lv3 restores v" + str(version))
				expect(restored.character_event_done(ID) and restored.relationship_level("doc_sayaka") == 3, "Old Lv3 preserved")
				expect(restored.elapsed() == elapsed and restored.relation_for("doc_sayaka") == relation, "No historical time/reward rewrite")
				expect(restored.active_character_event_id.is_empty() and restored.start_character_event(ID) == null, "Boundary only, no replay")
				expect(restored.restore(JSON.parse_string(JSON.stringify(restored.snapshot()))), "Migration idempotent")
				expect(restored.elapsed() == elapsed and restored.relation_for("doc_sayaka") == relation, "Second load unchanged")
