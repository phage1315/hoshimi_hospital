extends SceneTree
const Catalog = preload("res://godot/systems/daydream_catalog.gd")
var checks := 0
var failures := 0
func expect(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(note)
func _initialize() -> void: call_deferred("run")
func fixture() -> Dictionary:
	return {"id": "QA_DAYDREAM", "title": {"zh_CN": "测试", "en": "Test"}, "cast": {"zh_CN": "测试角色", "en": "Test cast"},
		"tags": {"zh_CN": "功能测试", "en": "Functional test"}, "unlock_hint": {"zh_CN": "无前置", "en": "No prerequisites"}, "level": "normal", "start": "a", "gate": {}, "nodes": [
		{"id": "a", "hide_portrait": true, "text": {"zh_CN": "测试文本", "en": "Test text"}, "speaker_label": {"zh_CN": "测试", "en": "Test"}, "choices": [{"id": "next", "label": {"zh_CN": "继续", "en": "Continue"}, "next": "b"}]},
		{"id": "b", "hide_portrait": true, "text": {"zh_CN": "测试结束", "en": "End of test"}, "speaker_label": {"zh_CN": "测试", "en": "Test"}, "choices": [{"id": "end", "label": {"zh_CN": "结束", "en": "End"}, "next": "@end"}]}
		]}
func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var imported := Catalog.entries()
	expect(imported.size() == 3, "Three user Daydream scripts imported")
	var mizuho_cg_path := "assets/events/daydream_v1/mizuho_or_laparotomy_open.png"
	var mizuho_cg_node: Dictionary = {}
	var chihaya_cg_path := "assets/events/daydream_v1/chihaya_or_after_penetration.png"
	var chihaya_cg_node: Dictionary = {}
	var hiroko_forced_cg_path := "assets/events/daydream_v1/hiroko_forced_into_or.png"
	var hiroko_open_cg_path := "assets/events/daydream_v1/hiroko_or_laparotomy_open.png"
	var hiroko_forced_cg_node: Dictionary = {}
	var hiroko_open_cg_node: Dictionary = {}
	var hiroko_expression_nodes: Array = []
	for imported_entry in imported:
		expect(Catalog.valid(imported_entry), "Imported event contract: " + str(imported_entry.get("id", "")))
		expect(imported_entry.get("nodes", []).size() > 0, "Imported nodes: " + str(imported_entry.get("id", "")))
		var imported_session = preload("res://godot/systems/character_event_session.gd").new(Catalog.definition(imported_entry, "zh_CN"))
		var imported_count := 0
		while not imported_session.completed and imported_count < 200:
			var imported_node: Dictionary = imported_session.current()
			expect(not imported_node.is_empty(), "Imported node resolves")
			var imported_choices: Array = imported_node.get("choices", [])
			expect(imported_choices.size() == 1, "Mechanical Continue edge preserved")
			if imported_choices.is_empty() or not imported_session.apply(str(imported_choices[0].id)): break
			imported_count += 1
		expect(imported_session.completed and imported_count == imported_entry.nodes.size(), "Imported script reaches authored end")
		var english_definition: Dictionary = Catalog.definition(imported_entry, "en")
		expect(not english_definition.is_empty() and english_definition.title == imported_entry.title.en, "Imported English title resolves")
		if not english_definition.is_empty():
			for index in range(imported_entry.nodes.size()):
				expect(english_definition.nodes[index].text == imported_entry.nodes[index].text.en, "Imported English node text resolves: %s" % imported_entry.nodes[index].id)
				expect(english_definition.nodes[index].speaker_label == imported_entry.nodes[index].speaker_label.en, "Imported English speaker resolves: %s" % imported_entry.nodes[index].id)
		if str(imported_entry.get("id", "")) == "FANTASY_MIZUHO_OR_SOLO_01":
			for imported_node in imported_entry.nodes:
				if str(imported_node.get("id", "")) == "F03_006":
					mizuho_cg_node = imported_node
		if str(imported_entry.get("id", "")) == "FANTASY_CHIHAYA_PREOP_OR_01":
			for imported_node in imported_entry.nodes:
				if str(imported_node.get("id", "")) == "F02_032":
					chihaya_cg_node = imported_node
		if str(imported_entry.get("id", "")) == "FANTASY_HIROKO_EMIKO_OR_01":
			for imported_node in imported_entry.nodes:
				if str(imported_node.get("id", "")) == "F01_013":
					hiroko_forced_cg_node = imported_node
				if str(imported_node.get("id", "")) == "F01_042":
					hiroko_open_cg_node = imported_node
				if str(imported_node.get("actor_id", "")) == "nurse_hiroko" and str(imported_node.get("background_id", "")) == "operating_room":
					hiroko_expression_nodes.append(imported_node)
	expect(not mizuho_cg_node.is_empty(), "Mizuho Daydream CG node exists")
	expect(str(mizuho_cg_node.get("cg_key", "")) == "mizuho_or_laparotomy_open", "Mizuho authored CG key preserved")
	expect(str(mizuho_cg_node.get("cg_path", "")) == mizuho_cg_path, "Mizuho supplied CG is mapped")
	expect(str(mizuho_cg_node.get("cg_fit", "")) == "contain", "Mizuho supplied CG keeps its full frame")
	expect(ResourceLoader.exists("res://" + mizuho_cg_path), "Mizuho supplied CG resource exists")
	expect(not chihaya_cg_node.is_empty(), "Chihaya Daydream after-penetration CG node exists")
	expect(str(chihaya_cg_node.get("cg_key", "")) == "chihaya_or_after_penetration", "Chihaya supplied CG cue is placed after insertion starts")
	expect(str(chihaya_cg_node.get("cg_path", "")) == chihaya_cg_path, "Chihaya supplied CG is mapped")
	expect(str(chihaya_cg_node.get("cg_fit", "")) == "contain", "Chihaya supplied CG keeps its full frame")
	expect(ResourceLoader.exists("res://" + chihaya_cg_path), "Chihaya supplied CG resource exists")
	expect(not hiroko_forced_cg_node.is_empty(), "Hiroko forced-entry CG node exists")
	expect(str(hiroko_forced_cg_node.get("cg_key", "")) == "hiroko_forced_into_or", "Hiroko forced-entry CG cue is mapped to the authored transfer")
	expect(str(hiroko_forced_cg_node.get("cg_path", "")) == hiroko_forced_cg_path, "Hiroko forced-entry supplied CG is mapped")
	expect(ResourceLoader.exists("res://" + hiroko_forced_cg_path), "Hiroko forced-entry supplied CG resource exists")
	expect(not hiroko_open_cg_node.is_empty(), "Hiroko laparotomy-open CG node exists")
	expect(str(hiroko_open_cg_node.get("cg_key", "")) == "hiroko_or_laparotomy_open", "Hiroko laparotomy-open CG cue is mapped after the retractors open the abdomen")
	expect(str(hiroko_open_cg_node.get("cg_path", "")) == hiroko_open_cg_path, "Hiroko laparotomy-open supplied CG is mapped")
	expect(ResourceLoader.exists("res://" + hiroko_open_cg_path), "Hiroko laparotomy-open supplied CG resource exists")
	var hiroko_paths: Dictionary = {}
	for hiroko_node in hiroko_expression_nodes:
		var portrait_path := str(hiroko_node.get("portrait_path", ""))
		hiroko_paths[portrait_path] = true
		expect(ResourceLoader.exists("res://" + portrait_path), "Hiroko operating-room expression resource exists: " + str(hiroko_node.get("id", "")))
	expect(hiroko_paths.size() >= 6, "Hiroko operating-room nodes use six distinct authored expression variants")
	var entry := fixture()
	expect(Catalog.valid(entry), "Bilingual fixture valid")
	for field in ["title", "cast", "tags", "unlock_hint"]:
		var broken := entry.duplicate(true)
		broken[field].erase("en")
		expect(not Catalog.valid(broken), "Reject missing English " + field)
	var broken := entry.duplicate(true)
	broken.nodes[0].text.en = broken.nodes[0].text.zh_CN
	expect(not Catalog.valid(broken), "Reject Chinese copied into English dialogue")
	broken = entry.duplicate(true)
	broken.nodes[0].choices[0].next = "missing"
	expect(not Catalog.valid(broken), "Reject dangling node")
	broken = entry.duplicate(true)
	broken.nodes[0].choices[0].effects = {"familiarity": 10}
	expect(not Catalog.valid(broken), "Reject canonical effects")
	for level in range(3):
		for maximum in range(3):
			var ranked := entry.duplicate(true)
			ranked.level = Catalog.LEVELS[level]
			expect(Catalog.visible(ranked, maximum) == (level <= maximum), "Cumulative level filter")
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		var game = app.game
		game.reset()
		# Establish the existing boundary loader's normalized fresh-game baseline.
		expect(game.restore(game.snapshot()), "Normalize initial boundary facts")
		var before: Dictionary = game.snapshot()
		expect(not before.is_empty(), "Safe boundary before playback")
		var gated := entry.duplicate(true)
		gated.gate = {"levels": {"doc_emiko": 5}}
		expect(not Catalog.unlocked(gated, game), "Relationship gate locked")
		gated.gate = {"flags": ["qa_daydream_gate"]}
		expect(not Catalog.unlocked(gated, game), "Flag gate locked")
		gated.gate = {"events": ["not_a_completed_event"]}
		expect(not Catalog.unlocked(gated, game), "Event gate locked")
		expect(game.snapshot() == before, "Gate inspection has no effects")
		app.show_player_office()
		expect(app.page.find_child("OfficeDaydream", true, false) != null, "Office entry exists")
		var view = app.daydream_view
		var cg_fixture := fixture()
		cg_fixture.nodes[0]["cg_path"] = mizuho_cg_path
		cg_fixture.nodes[0]["cg_fit"] = "contain"
		app.show_daydreams()
		view.catalog = [cg_fixture]
		view.maximum = 0
		view.dark_confirmed = false
		view.show_catalog()
		view.confirm_entry(cg_fixture)
		view.begin()
		await process_frame
		var rendered_cg := app.page.get_node_or_null("CharacterEventCG") as TextureRect
		expect(rendered_cg != null and rendered_cg.texture != null and rendered_cg.texture.resource_path == "res://" + mizuho_cg_path, "Narration node renders supplied Daydream CG")
		view.leave()
		view.catalog = [entry]
		view.maximum = 0
		view.dark_confirmed = false
		app.show_daydreams()
		await process_frame
		expect(app.screen == "daydream_catalog" and view.session == null, "No automatic playback")
		expect(not game.can_save_progress() and game.snapshot().is_empty(), "Save locked in catalog")
		view.set_maximum(2)
		expect(app.screen == "daydream_warning" and view.maximum == 0, "First dark warning before enabling")
		view.show_catalog()
		expect(view.maximum == 0, "Cancel dark keeps original maximum")
		view.set_maximum(2)
		view.accept_dark()
		expect(view.maximum == 2 and view.dark_confirmed and view.session == null, "Dark accepted without playing")
		view.confirm_entry(entry)
		expect(app.screen == "daydream_confirm" and view.session == null, "Per-story confirmation")
		view.show_catalog()
		expect(view.pending.is_empty(), "Cancel entry drops pending selection")
		view.confirm_entry(entry)
		view.begin()
		await process_frame
		expect(app.screen == "daydream_playback", "Existing VN session starts")
		expect(view.session.current().text == entry.nodes[0].text[locale], "Exact locale text")
		expect(not game.can_save_progress(), "Save locked during playback")
		view.choose("next")
		view.leave()
		expect(app.screen == "player_office" and game.snapshot() == before, "Early exit restores office, no read or canonical effects")
		for repetition in range(2):
			app.show_daydreams()
			view.confirm_entry(entry)
			view.begin()
			view.choose("next")
			view.choose("end")
			expect(app.screen == "player_office" and not game.daydream_active, "Completion returns to office")
			expect(game.daydream_read_ids == [entry.id], "Only stable read ID, duplicate replay idempotent")
		var after: Dictionary = game.snapshot()
		var compare := after.duplicate(true)
		compare.daydream_read_ids = []
		expect(compare == before, "Time, XP, rewards, relations, history and canonical flags unchanged")
		var file_path := "/tmp/hoshimi-daydream-boundary-test.json"
		var file := FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(after))
		file.close()
		var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(file_path))
		expect(saved.daydream_read_ids == [entry.id] and not saved.has("daydream_active"), "Disk contains only read IDs, no playback state")
		# Remove/rewrite the script entirely. Loading depends only on stable facts.
		view.catalog = []
		expect(game.restore(saved), "Restore without original script nodes")
		expect(game.snapshot() == after, "Round trip preserves settled time and values")
		expect(game.restore(game.snapshot()), "Second round trip")
		expect(game.snapshot() == after, "Stable repeated save/load, no rewards replay")
		var invalid := saved.duplicate(true)
		invalid.daydream_read_ids = [{"node_id": "a"}]
		expect(not game.restore(invalid) and game.snapshot() == after, "Reject nested inner-state read records atomically")
		var old := saved.duplicate(true)
		old.erase("daydream_read_ids")
		expect(game.restore(old) and game.daydream_read_ids.is_empty(), "Old boundary saves remain readable")
		app.show_sunday_office_menu()
		var sunday_before: Dictionary = game.snapshot()
		app.show_daydreams()
		view.leave()
		expect(app.screen == "sunday_office" and game.snapshot() == sunday_before, "Sunday return consumes no activity")
		game.daydream_read_ids = [entry.id]
		game.reset()
		expect(game.daydream_read_ids.is_empty() and not game.daydream_active, "New game clears read history")
		app.show_event_test_hub()
		var test_hub_entry := app.page.find_child("DaydreamEventTestEntry", true, false) as Button
		expect(test_hub_entry != null, "Event Test Hub exposes one Daydream test entry")
		if test_hub_entry != null: test_hub_entry.pressed.emit()
		expect(app.screen == "daydream_catalog" and view.testing and view.maximum == 2, "Developer entry opens isolated three-event catalog")
		expect(not game.can_save_progress() and game.snapshot().is_empty(), "Developer catalog cannot persist an inner-state save")
		for imported_entry in imported:
			if app.screen == "event_test_hub":
				app.begin_daydream_event_test()
			var test_entry := app.page.find_child("DaydreamEntry_" + str(imported_entry.id), true, false) as Button
			expect(test_entry != null and not test_entry.disabled, "Developer catalog enables " + str(imported_entry.id))
			if test_entry != null: test_entry.pressed.emit()
			expect(app.screen == "daydream_confirm", "Developer entry confirms " + str(imported_entry.id))
			var begin_button := app.page.find_child("DaydreamBegin", true, false) as Button
			if begin_button != null: begin_button.pressed.emit()
			expect(app.screen == "daydream_playback" and view.session != null and str(view.session.definition.id) == str(imported_entry.id), "Developer entry starts " + str(imported_entry.id))
			if str(imported_entry.id) == str(imported[0].id):
				while app.screen == "daydream_playback":
					var test_node: Dictionary = view.session.current()
					view.choose(str(test_node.choices[0].id))
				expect(str(imported_entry.id) in game.daydream_read_ids, "Developer completion records only the stable read fact in memory")
			else:
				view.leave()
			expect(app.screen == "event_test_hub" and not game.daydream_active and not view.testing, "Developer exit returns to Event Test Hub")
	print("DAYDREAM MODE: %d checks; %d failures" % [checks, failures])
	app.queue_free()
	await process_frame
	quit(1 if failures else 0)
