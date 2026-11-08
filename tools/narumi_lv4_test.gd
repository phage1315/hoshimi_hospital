extends SceneTree
## Runtime regression for Narumi Lv4, its Ren relationship conditional, and pending Free H registration.

const ID := "narumi_lv4_after_work"
const NODE_COUNT := 148
const Registry = preload("res://godot/systems/free_h_registry.gd")
const EventSession = preload("res://godot/systems/character_event_session.gd")
var app
var checks := 0
var failures := 0
var han := RegEx.new()

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	han.compile("[㐀-鿿]")
	call_deferred("run")

func test_route(definition: Dictionary, locale: String, branch_mask: int, ren_level: int, coverage: Dictionary) -> void:
	var session = EventSession.new(definition)
	var branch_number := 0
	var guard := 0
	var visited := {}
	while not session.completed and guard <= NODE_COUNT + 4:
		guard += 1
		var node: Dictionary = session.current()
		var node_id := str(node.get("id", ""))
		expect(not node_id.is_empty() and not visited.has(node_id), "valid acyclic node " + node_id)
		visited[node_id] = true
		coverage[node_id] = true
		if locale == "en":
			expect(han.search(str(node.get("text", ""))) == null, "English text loaded " + node_id)
			expect(han.search(str(node.get("speaker_label", ""))) == null, "English speaker loaded " + node_id)
		var choices: Array = node.get("choices", [])
		expect(not choices.is_empty(), "node has a choice " + node_id)
		if choices.is_empty():
			return
		var choice_index := 0
		if choices.size() == 2:
			choice_index = (branch_mask >> branch_number) & 1
			branch_number += 1
		expect(session.apply(str(choices[choice_index].get("id", "")), {"nurse_haru": ren_level}), "advance " + node_id)
	expect(session.completed and guard <= NODE_COUNT + 4, "route terminates %s/%s/%s" % [locale, branch_mask, ren_level])
	expect(branch_number == 2, "both authored choices reached")

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/narumi_lv4_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "content loads " + locale)
		app.configure_game_content()
		var definition: Dictionary = app.game.character_event_definitions.get(ID, {})
		expect(not definition.is_empty() and definition.get("nodes", []).size() == NODE_COUNT, "registered 148-page Lv4 " + locale)
		var all_coverage := {}
		for ren_level in [3, 4]:
			for branch_mask in range(4):
				test_route(definition, locale, branch_mask, ren_level, all_coverage)
		expect(all_coverage.size() == NODE_COUNT, "all pages covered %s: %s/%s" % [locale, all_coverage.size(), NODE_COUNT])
	var config := Registry.definition("doc_aoi")
	expect(not config.is_empty() and str(config.get("content_status", "")) == "pending_assets", "Narumi has explicit pending registration")
	expect(str(config.get("completion_event", "")) == ID and str(config.get("location_id", "")) == "hotel", "Narumi registration points to Lv4 and hotel")
	expect(Registry.load_bundle("doc_aoi").has("error"), "pending assets cannot load a production bundle")
	expect(app.game.prepare_character_event_test_save(ID), "isolated Lv4 fixture")
	expect(app.game.is_sunday(), "Sunday-trigger fixture starts on Sunday")
	var start_day: int = app.game.day_number()
	expect(app.game.start_character_event(ID) != null, "Lv4 starts through the production game state")
	expect(app.game.reserve_sunday_character_event(ID), "multi-day event reserves Sunday before crossing midnight")
	expect(app.game.sunday_history.size() == 1 and str(app.game.sunday_history[0].activity_id) == ID, "Sunday reservation records the correct event")
	var guard := 0
	while app.game.character_event_in_progress() and guard < NODE_COUNT + 4:
		var node: Dictionary = app.game.character_events[ID].current()
		expect(not node.get("choices", []).is_empty(), "runtime node has an authored choice " + str(node.get("id", "")))
		if node.get("choices", []).is_empty():
			break
		expect(app.game.choose_character_event(str(node.choices[0].id)), "runtime route advances " + str(node.get("id", "")))
		guard += 1
	expect(not app.game.character_event_in_progress() and guard <= NODE_COUNT + 4, "production route completes")
	expect(app.game.day_number() == start_day, "persistent clock does not move until the atomic story ends")
	var completed_event = app.game.character_events[ID]
	app.game.advance_story_to_day(int(completed_event.completed_day) + int(completed_event.definition.completion_day_offset), int(completed_event.definition.completion_absolute_clock))
	expect(app.game.day_number() == start_day + 1 and app.game.current_absolute_clock() == 13 * 60, "completion settles at Monday 13:00")
	app.finish_long_sunday_character_event()
	await process_frame
	expect(app.game.active_character_event_id.is_empty() and app.game.sunday_history.size() == 1, "returning to the hospital neither resumes nor double-consumes Sunday")
	expect(app.game.free_h_relationship_qualified("doc_aoi"), "relationship facts qualify independently")
	expect(not app.game.free_h_unlocked("doc_aoi"), "pending content cannot open the Free H route")
	print("NARUMI LV4/H: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
