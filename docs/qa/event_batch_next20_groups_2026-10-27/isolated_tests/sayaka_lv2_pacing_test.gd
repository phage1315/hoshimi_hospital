extends SceneTree
## In-memory fixtures only. Never reads or writes player save slots/settings.
const Event = preload("res://godot/systems/character_event_session.gd")
const Game = preload("res://godot/systems/game_state.gd")
const ID := "sayaka_lv2_working_hours"
const DATE := "sayaka_lv1_first_date"
const CALLBACK := "sayaka_lv1_monday_callback"
var app
var checks := 0
var failures := 0

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

func prepare(game, day: int = 10, familiarity: int = 25) -> void:
	game.reset()
	game.meet_staff("doc_sayaka")
	for pair in [["sayaka_week1_phone_exchange", 2], [DATE, 6], [CALLBACK, 7]]:
		expect(game._complete_character_event_for_test(pair[0], pair[1]), "Prerequisite fixture " + pair[0])
	var relation: Dictionary = game.relation_for("doc_sayaka")
	relation.level = 1
	relation.affection = 20
	relation.familiarity = familiarity
	relation.event_history = ["sayaka_week1_phone_exchange", DATE, CALLBACK]
	relation.rank_history = [DATE]
	game.set_test_time(day, 540)
	# set_test_time sets only the free-time ledger; prerequisite fixtures also
	# contribute completed-event minutes. Normalize this fixture to exactly 09:00.
	game.story_time_advance_minutes -= game.elapsed() - (day - 1) * 480
	game.active_id = ""
	game.active_mode = "encounter"

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/tmp/hoshimi_next20_unused_sayaka_lv2_pacing_test_"+str(OS.get_process_id())+".json"
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		app.dialogue_auto_enabled = false
		var game = app.game
		check_gates(game)
		for branch in ["lv2_coat", "lv2_sexy", "lv2_scrubs"]:
			prepare(game)
			# Stale relationship flavor flags must NOT choose this run's callback.
			game.relation_for("doc_sayaka").flags.append("sayaka_lv2_flavor_scrubs")
			var before: int = game.elapsed()
			var event = game.start_character_event(ID)
			expect(event != null, "Start Lv2 " + branch)
			if event == null:
				continue
			app.reset_dialogue_page()
			app.show_character_event()
			var seen: Array = []
			var decisions := 0
			for _step in range(180):
				if event.completed:
					break
				var node: Dictionary = event.current()
				seen.append(str(node.id))
				expect(game.relationship_level("doc_sayaka") == 1, "No early rank-up " + node.id)
				expect(not game.can_save_progress(), "No event save " + node.id)
				expect(game.elapsed() == before, "No per-line clock charge")
				await check_render(node, locale, branch)
				var choice: Dictionary = node.choices[0]
				if node.choices.size() > 1:
					decisions += 1
					expect(node.id == "white_coat" and node.choices.size() == 3, "Only one three-way appearance choice")
					for candidate in node.choices:
						if candidate.id == branch:
							choice = candidate
				var button: Button = app.page.get_node_or_null("EventChoice_" + str(choice.id))
				expect(button != null, "Real UI choice " + choice.id)
				if button == null:
					break
				button.pressed.emit()
				await process_frame
			expect(event.completed and decisions == 1, "Full route completes with one decision")
			expect(seen.has("lv2_v2_429") == (branch == "lv2_scrubs"), "10A only for current scrubs choice")
			expect(seen.has("lv2_v2_441") == (branch != "lv2_scrubs"), "10B only for coat/sexy")
			expect(seen.count("lv2_v2_457") == 1 and seen.back() == "ending", "Single common farewell")
			expect(seen.count("lv2_v2_213") + seen.count("lv2_v2_445") == 1, "Mask exchange exactly once")
			var relation: Dictionary = game.relation_for("doc_sayaka")
			expect(relation.level == 2 and relation.affection == (25 if branch == "lv2_sexy" else 24) and relation.familiarity == 34, "Original numeric rewards " + branch)
			for flag in ["sayaka_workplace_flirt_established", "sayaka_school_nurse_background_shared", "sayaka_medicine_return_motivation_known", "sayaka_surgical_outfit_compliment_seen", "sayaka_lv3_pre_event_eligible"]:
				expect(relation.flags.count(flag) == 1, "Completion flag once " + flag)
			expect(relation.event_history.count(ID) == 1 and relation.rank_history.count(ID) == 1 and relation.unlocked_benefits.count("unlock_sayaka_lv2_workplace_flirt") == 1, "One event/rank/benefit")
			expect(game.elapsed() == before + 35 and game.clock_text() == "09:35", "Exactly 35 minutes once")
			expect(app.screen == "character_event_reward" and app.character_event_reward_available(event.definition), "Original CG reward shown")
			var final_relation: Dictionary = relation.duplicate(true)
			expect(not game.choose_character_event("lv2_complete"), "No double completion")
			expect(relation == final_relation and game.elapsed() == before + 35, "No repeated rewards/time")
			game.finish_character_event()
			expect(game.can_save_progress(), "Boundary save unlocked")
			var snapshot: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
			expect(game.restore(snapshot), "Completed new checkpoint round-trip")
			expect(game.relation_for("doc_sayaka") == final_relation and game.elapsed() == before + 35, "New checkpoint preserves values/time")
			expect(game.start_character_event(ID) == null, "No replay after completion")
			print("LV2 ROUTE ", locale, "/", branch, ": ", seen.size(), " turns; 35 min; Lv2")
		check_old_completed_saves()
	check_conditional_runtime()
	app.queue_free()
	await process_frame
	print("SAYAKA LV2 PACING: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

func check_gates(game) -> void:
	prepare(game, 10, 24)
	var definition: Dictionary = game.character_event_definitions[ID]
	expect(not game.character_event_available(definition), "Fam24 blocked")
	game.add_familiarity("doc_sayaka", 1)
	expect(game.character_event_available(definition), "Fam25 eligible")
	expect(game.next_day_start_character_event().get("id", "") == ID, "Original day-start entry")
	prepare(game, 9)
	expect(not game.character_event_available(definition), "Callback+2 days blocked despite Lv1+3")
	prepare(game)
	game.character_events.erase(CALLBACK)
	expect(not game.character_event_available(definition), "Missing Monday callback blocked")
	prepare(game)
	game.relation_for("doc_sayaka").level = 0
	expect(not game.character_event_available(definition), "Lv0 blocked")
	prepare(game)
	game.relation_for("doc_sayaka").met = false
	expect(not game.character_event_available(definition), "Unmet blocked")
	prepare(game)
	game.character_events[DATE].completed_day = 9
	expect(not game.character_event_available(definition), "Rank cooldown independently enforced")

func check_render(node: Dictionary, locale: String, branch: String) -> void:
	var pages: Array = app.authored_dialogue_pages(str(node.text))
	expect("".join(pages) == str(node.text), "Exact pagination " + node.id)
	for page_index in range(pages.size()):
		app.dialogue_page_index = page_index
		app.show_character_event()
		await process_frame
		var body: RichTextLabel = app.page.get_node("CharacterEventDialogue")
		expect(body.text == str(pages[page_index]), "Rendered exact page " + node.id)
		expect(body.get_content_height() <= body.size.y, "Text fits " + locale + "/" + node.id)
		var expected: String = app.protagonist_name() if node.speaker == "player" else str(app.content.find_record("staff", "doc_sayaka").name) if node.speaker == "actor" else app.tx("ui.auto.ed1d855fc574", "旁白")
		var speaker_ok := false
		for child in app.page.get_children():
			if child is Label and child.position == Vector2(82, 558):
				speaker_ok = child.text == expected
		expect(speaker_ok, "Explicit speaker " + node.id)
		var portrait: TextureRect = app.page.get_node_or_null("CharacterPortrait")
		var actor: Dictionary = app.content.find_record("staff", "doc_sayaka")
		expect(portrait != null and portrait.texture.resource_path == "res://" + str(actor.visuals.portraits["white_coat/" + str(node.expression)]), "Registered white-coat portrait/expression")
		if locale == "en":
			var han := RegEx.new()
			han.compile("[\\x{3400}-\\x{9fff}]")
			expect(han.search(body.text) == null, "No Chinese in English runtime")
		if OS.get_cmdline_user_args().has("--visual") and page_index == 0 and node.id in ["lv2_v2_65", "white_coat", "lv2_v2_246", "lv2_v2_435", "lv2_v2_445", "ending"]:
			await RenderingServer.frame_post_draw
			var path := "/private/tmp/hoshimi_lv2_%s_%s_%s.png" % [locale, branch, node.id]
			expect(app.get_viewport().get_texture().get_image().save_png(path) == OK, "Native capture")

func check_old_completed_saves() -> void:
	var old: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tools/fixtures/sayaka_lv2_v1_event.json"))
	for branch in ["lv2_coat", "lv2_sexy", "lv2_scrubs"]:
		var game = Game.new()
		configure(game)
		prepare(game)
		game.character_event_definitions[ID] = old
		var event = game.start_character_event(ID)
		expect(event != null, "Old graph start")
		if event == null:
			continue
		for _step in range(30):
			if event.completed:
				break
			var choice_id: String = event.current().choices[0].id
			for choice in event.current().choices:
				if choice.id == branch:
					choice_id = branch
			expect(game.choose_character_event(choice_id), "Old choice")
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
			expect(restored.restore(snapshot), "Old completed Lv2 loads v" + str(version))
			expect(restored.character_event_done(ID) and restored.relationship_level("doc_sayaka") == 2, "Old completion retained")
			expect(restored.elapsed() == elapsed and restored.relation_for("doc_sayaka") == relation, "Old time/rewards unchanged")
			expect(restored.active_character_event_id.is_empty() and restored.start_character_event(ID) == null, "Safe boundary, no replay")
			expect(restored.restore(JSON.parse_string(JSON.stringify(restored.snapshot()))), "Migration idempotent")
			expect(restored.elapsed() == elapsed and restored.relation_for("doc_sayaka") == relation, "Second load unchanged")

func check_conditional_runtime() -> void:
	var definition: Dictionary = app.game.character_event_definitions[ID]
	var event = Event.new(definition)
	event.node_id = "lv2_v2_416"
	expect(event.apply("walk_to_door") and event.node_id == "lv2_v2_441", "No prior choice uses default")
	event = Event.new(definition)
	event.choices.append("lv2_scrubs")
	event.node_id = "lv2_v2_416"
	expect(event.apply("walk_to_door") and event.node_id == "lv2_v2_429", "Prior choice selects callback")
	var malformed: Dictionary = definition.duplicate(true)
	for node in malformed.nodes:
		if node.id == "lv2_v2_416":
			node.choices[0].next_if_choice.next = "missing_node"
	event = Event.new(malformed)
	event.choices.append("lv2_scrubs")
	event.node_id = "lv2_v2_416"
	var before: Dictionary = event.snapshot_state()
	expect(not event.apply("walk_to_door") and event.snapshot_state() == before, "Invalid target rejected before state mutation")
