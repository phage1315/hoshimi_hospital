extends SceneTree

const CharacterEvent = preload("res://godot/systems/character_event_session.gd")
const Game = preload("res://godot/systems/game_state.gd")
const PHONE := "sayaka_week1_phone_exchange"
const DATE := "sayaka_lv1_first_date"
const CALLBACK := "sayaka_lv1_monday_callback"
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

func configure(game) -> void:
	var c = app.content.collections
	game.configure(c.encounters, c.preops, c.staff, c.time_events, c.surgeries, c.patients, c.relationships, c.character_events, c.case_templates, c.micro_events, c.examination_cg_pools, c.surgery_team_dialogue_profiles, c.patient_interactions, c.temporary_conditions, c.staff_role_cg_rewards, c.special_events, c.special_event_steps, c.date_profiles, c.date_locations)

func choose_until_done(game, event, picks: Array = []) -> void:
	for _step in range(event.definition.nodes.size() + 1):
		if event.completed:
			break
		var choice: String = str(event.current().choices[0].id)
		for c in event.current().choices:
			if picks.has(c.id):
				choice = c.id
		expect(game.choose_character_event(choice), "Choose " + choice)
	expect(event.completed, "Event completes")

func prepare_phone(game) -> void:
	game.reset()
	game.meet_staff("doc_sayaka")
	game.advance_story_to_day(2, 540)

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/tmp/hoshimi_next20_unused_sayaka_v2_test_"+str(OS.get_process_id())+".json"
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		if OS.get_cmdline_user_args().has("--legacy-only"):
			check_legacy_saves(locale)
			continue
		if OS.get_cmdline_user_args().has("--render-only"):
			await check_rendering(locale)
			continue
		var game = app.game
		game.reset()
		game.advance_story_to_day(2, 540)
		expect(not game.character_event_available(game.character_event_definitions[PHONE]), "Unmet cannot start phone")
		game.meet_staff("doc_sayaka")
		expect(not game.sunday_date_eligible("doc_sayaka"), "No number, no invite")
		for branch in ["phone_tail_a", "phone_tail_b", "phone_tail_c"]:
			prepare_phone(game)
			var phone = game.start_character_event(PHONE)
			expect(phone != null, "Phone start")
			choose_until_done(game, phone, [branch])
			expect(game.relationship_level("doc_sayaka") == 0, "Phone is not a rank-up")
			for flag in ["sayaka_phone_exchanged", "sayaka_sunday_invite_available", "sayaka_private_contact_open"]:
				expect(game.relation_for("doc_sayaka").flags.has(flag), "Phone flag " + flag)
			game.finish_character_event()
			var phone_save: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
			expect(game.restore(phone_save), "Phone checkpoint restores")
			expect(game.start_character_event(PHONE) == null, "Phone cannot repeat")
		var phone_checkpoint: Dictionary = game.snapshot()
		for outfit in ["outfit_miss_coat", "outfit_pretty", "outfit_same"]:
			for answer in ["date_direct", "date_tease", "date_only_meal"]:
				expect(game.restore(phone_checkpoint.duplicate(true)), "Fresh branch checkpoint")
				game.advance_story_to_day(6, 540)
				app.start_sunday_character_event(DATE)
				var event = game.character_events.get(DATE)
				expect(event != null, "Player Sunday entry")
				if event == null:
					continue
				var affection_before: int = game.relation_for("doc_sayaka").affection
				var elapsed_before: int = game.elapsed()
				var seen: Array = []
				var previous_clock := 540
				for _step in range(event.definition.nodes.size() + 1):
					if event.completed:
						break
					seen.append(event.node_id)
					expect(game.relationship_level("doc_sayaka") == 0, "Rank remains Lv0 until farewell acknowledged")
					var clock: int = game.display_schedule().absolute_clock
					expect(game.day_number() == 6 and clock >= previous_clock, "Sunday scene time only moves forward")
					previous_clock = clock
					var choice: String = str(event.current().choices[0].id)
					for c in event.current().choices:
						if c.id in [outfit, answer]:
							choice = c.id
					# Exercise the actual UI callback for settlement and CG flow.
					app.choose_character_event(choice)
					await process_frame
				expect(event.completed, "Shared farewell completes")
				expect(seen.has("v2_589") and seen.has("v2_623") and seen.back() == "v2_655", "Every answer visits same bill/walk/farewell")
				if answer == "date_only_meal":
					for node in ["v2_545", "v2_561", "v2_563", "v2_569", "v2_571"]:
						expect(seen.has(node), "C recovery beat " + node)
				expect(game.relationship_level("doc_sayaka") == 1, "Every answer reaches Lv1")
				var clothing_gain: int = {"outfit_miss_coat": 1, "outfit_pretty": 2, "outfit_same": 0}[outfit]
				expect(game.relation_for("doc_sayaka").affection == affection_before + clothing_gain + 1 + (1 if answer == "date_only_meal" else 3) + 2, "Original numeric rewards preserved")
				expect(game.elapsed() == elapsed_before + 120, "Authored minutes charged once")
				expect(game.display_schedule().absolute_clock == 1080, "Farewell at 18:00 on Sunday")
				expect(app.screen == "character_event_reward", "CG reward for every answer")
				expect(not game.choose_character_event("date_success_end"), "No duplicate ending effects")
				expect(not game.relation_for("doc_sayaka").flags.has("sayaka_first_date_retry_pending"), "No new retry flag")
				app.show_character_event_complete()
				app.finish_sunday_character_event("doc_sayaka", "restaurant_bar")
				expect(game.day_number() == 7 and game.display_schedule().absolute_clock == 540, "Whole Sunday ends on Monday 09:00")
				expect(game.sunday_history.size() == 1, "One Sunday record")
				expect(not game.complete_sunday_activity("date", "doc_sayaka", "restaurant_bar"), "Cannot consume twice")
				var saved: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
				expect(game.restore(saved), "Completed route round-trip")
				expect(game.next_character_event_at("clinic").get("id", "") == CALLBACK, "Callback ready next workday")
				var callback = game.start_character_event(CALLBACK)
				var before_callback: int = game.relation_for("doc_sayaka").familiarity
				choose_until_done(game, callback)
				expect(game.relation_for("doc_sayaka").familiarity == before_callback + 3, "Callback keeps familiarity")
				game.finish_character_event()
				game.advance_story_to_day(13, 540)
				expect(game.start_character_event(DATE) == null, "No retry next Sunday")
				print("V2 route ", locale, "/", outfit, "/", answer, ": Lv1; AA + farewell; one Sunday; no retry")
		await check_rendering(locale)
		check_legacy_saves(locale)
	app.queue_free()
	await process_frame
	print("SAYAKA V2: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

func check_rendering(locale: String) -> void:
	var game = app.game
	prepare_phone(game)
	var visited := 0
	for id in [PHONE, DATE, CALLBACK]:
		var event = CharacterEvent.new(game.character_event_definitions[id])
		game.character_events[id] = event
		game.active_character_event_id = id
		for node in event.definition.nodes:
			expect("".join(app.authored_dialogue_pages(str(node.text))) == str(node.text), "Pagination preserves exact text " + str(node.id))
			event.node_id = node.id
			app.reset_dialogue_page()
			app.show_character_event()
			await process_frame
			var expected_speaker: String = app.protagonist_name() if node.speaker == "player" else str(app.content.find_record("staff", "doc_sayaka").name) if node.speaker == "actor" else app.tx("ui.auto.ed1d855fc574", "旁白")
			if node.presentation == "sms":
				expect(app.page.has_node("CharacterEventMessage"), "Separate message card")
				expect(str(app.page.get_node("CharacterEventMessageSender").text).ends_with(expected_speaker), "Explicit message sender")
				expect(not app.page.has_node("CharacterPortrait") and not app.page.has_node("CharacterEventDialogueBox"), "SMS not spoken by portrait")
				var body = app.page.get_node("CharacterEventMessageText")
				expect(body.get_rect().end.x <= app.page.get_node("CharacterEventMessage").get_rect().end.x, "SMS within card")
			else:
				var found := false
				for child in app.page.get_children():
					if child is Label and child.position == Vector2(82, 558):
						found = child.text == expected_speaker
				expect(found, "Correct speaker " + str(node.id))
				var body: RichTextLabel = app.page.get_node("CharacterEventDialogue")
				expect(body.get_content_height() <= body.size.y, "First page fits %s/%s: height=%s area=%s text=%s" % [locale, node.id, body.get_content_height(), body.size.y, body.text])
				var pages: Array = app.authored_dialogue_pages(str(node.text))
				for index in range(1, pages.size()):
					app.dialogue_page_index = index
					app.show_character_event()
					await process_frame
					body = app.page.get_node("CharacterEventDialogue")
					expect(body.text == str(pages[index]), "Every page reachable " + str(node.id))
					expect(body.get_content_height() <= body.size.y, "Later page fits " + str(node.id))
			if node.get("seasonal_street", false):
				expect(app.after_work_background_id({"phase":"result", "outcome":"completed", "workday":6, "variant":"night"}) == "after_work_street_spring_night", "Registered evening street")
			visited += 1
	expect(visited == 230, "All authored nodes rendered in " + locale)

func check_legacy_saves(locale: String) -> void:
	var old_events: Array = JSON.parse_string(FileAccess.get_file_as_string("res://tools/fixtures/sayaka_v1_events.json"))
	var untouched = Game.new()
	configure(untouched)
	prepare_phone(untouched)
	var ordinary: Dictionary = JSON.parse_string(JSON.stringify(untouched.snapshot()))
	expect(untouched.restore(ordinary), "Ordinary Lv0 checkpoint loads")
	expect(untouched.relationship_level("doc_sayaka") == 0 and untouched.character_events.is_empty(), "Ordinary Lv0 stays untouched")
	expect(untouched.elapsed() == 480, "Ordinary Lv0 time untouched")
	# Manufacture old saves through the original graphs. Never read/write player slots.
	for successful in [false, true]:
		var old_game = Game.new()
		configure(old_game)
		for definition in old_events:
			old_game.character_event_definitions[definition.id] = definition
		prepare_phone(old_game)
		choose_until_done(old_game, old_game.start_character_event(PHONE))
		old_game.finish_character_event()
		old_game.advance_story_to_day(6, 540)
		choose_until_done(old_game, old_game.start_character_event(DATE), ["date_direct" if successful else "date_only_meal"])
		old_game.finish_character_event()
		old_game.complete_sunday_activity("date", "doc_sayaka", "restaurant_bar")
		var snapshot: Dictionary = JSON.parse_string(JSON.stringify(old_game.snapshot()))
		var old_elapsed: int = old_game.elapsed()
		for version in [35, 36]:
			var state: Dictionary = snapshot.duplicate(true)
			if version == 35:
				state.version = 35
				state.erase("save_format")
				for i in range(state.character_events.size()):
					var rec: Dictionary = state.character_events[i]
					state.character_events[i] = {"id":rec.id, "choices":rec.state.choices, "completed_day":rec.state.completed_day}
			var restored = Game.new()
			configure(restored)
			expect(restored.restore(state), "Legacy restore " + locale + "/" + str(version))
			expect(restored.elapsed() == old_elapsed, "Retired failed date cannot refund time")
			expect(restored.relationship_level("doc_sayaka") == (1 if successful else 0), "Never auto-promote/reset rank")
			expect(restored.relation_for("doc_sayaka").affection == old_game.relation_for("doc_sayaka").affection, "Keep prior numeric rewards")
			expect(restored.character_event_done(PHONE), "Completed phone remains done")
			expect(restored.character_event_done(DATE) == successful, "Only old failure becomes untriggered")
			expect(not restored.relation_for("doc_sayaka").flags.has("sayaka_first_date_retry_pending"), "Retired retry flag cleared")
			expect(restored.restore(JSON.parse_string(JSON.stringify(restored.snapshot()))), "Migration is idempotent")
			expect(restored.elapsed() == old_elapsed, "Second load does not add time")
			restored.advance_story_to_day(13, 540)
			expect(restored.character_event_available(restored.character_event_definitions[DATE]) != successful, "Only old failure can play revised date")
			if not successful:
				var event = restored.start_character_event(DATE)
				expect(event != null and event.choices.is_empty(), "Fresh start, no partial replay")
				if event != null:
					choose_until_done(restored, event, ["date_only_meal"])
					expect(restored.relationship_level("doc_sayaka") == 1, "Migrated save can finish new C")
