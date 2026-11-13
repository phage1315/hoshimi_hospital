extends SceneTree
## Runtime regression test for Manami Iimura's Relationship Lv2 event:
## 《和弘子一起吃饭》 (manami_lv2_dinner_with_hiroko).

const ID := "manami_lv2_dinner_with_hiroko"
const NODE_COUNT := 205
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

func test_route(definition: Dictionary, locale: String, choice_idx: int, hiroko_level: int, coverage: Dictionary) -> void:
	var session = EventSession.new(definition)
	var choice_count := 0
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
		expect(not choices.is_empty(), "node has choice " + node_id)
		if choices.is_empty():
			return
		var pick := 0
		if choices.size() == 2:
			pick = choice_idx
			choice_count += 1
		expect(session.apply(str(choices[pick].get("id", "")), {"nurse_hiroko": hiroko_level}), "advance " + node_id)
	expect(session.completed and guard <= NODE_COUNT + 4, "route terminates %s/choice=%s/hiroko_lv=%s" % [locale, choice_idx, hiroko_level])
	expect(choice_count == 1, "Scene 3 RP choice reached")

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/manami_lv2_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "content loads " + locale)
		app.configure_game_content()
		var definition: Dictionary = app.game.character_event_definitions.get(ID, {})
		expect(not definition.is_empty() and definition.get("nodes", []).size() == NODE_COUNT, "registered 205-beat Manami Lv2 " + locale)
		var all_coverage := {}
		for hiroko_level in [0, 3, 4, 5]:
			for choice_idx in [0, 1]:
				test_route(definition, locale, choice_idx, hiroko_level, all_coverage)
		expect(all_coverage.size() == NODE_COUNT, "all 205 nodes covered in %s (%s/%s)" % [locale, all_coverage.size(), NODE_COUNT])

	# Verify runtime availability gates and Hiroko met prerequisite
	expect(app.game.prepare_character_event_test_save(ID), "prepare isolated Manami Lv2 fixture")
	var definition: Dictionary = app.game.character_event_definitions.get(ID, {})
	var hiroko_rel: Dictionary = app.game.relation_for("nurse_hiroko")
	hiroko_rel["met"] = false
	expect(not app.game.character_event_available(definition), "Manami Lv2 blocked when nurse_hiroko is unmet")
	hiroko_rel["met"] = true
	hiroko_rel["level"] = 0
	expect(app.game.character_event_available(definition), "Manami Lv2 available when nurse_hiroko is met at Lv0")

	var solo_dates_before: int = app.game.character_progress_counter("pharmacist_manami", "completed_sunday_dates")
	var manami_rel: Dictionary = app.game.relation_for("pharmacist_manami")
	expect(int(manami_rel.get("level", 0)) == 1, "fixture starts with Manami at Lv1")

	expect(app.game.start_character_event(ID) != null, "Manami Lv2 starts through GameState")
	expect(not app.game.can_save_progress(), "saving is locked while Manami Lv2 is in progress")

	var guard := 0
	while app.game.character_event_in_progress() and guard <= NODE_COUNT + 4:
		var node: Dictionary = app.game.character_events[ID].current()
		var choices: Array = node.get("choices", [])
		expect(not choices.is_empty(), "runtime node has choice " + str(node.get("id", "")))
		if choices.is_empty():
			break
		expect(app.game.choose_character_event(str(choices[0].get("id", ""))), "runtime route advances " + str(node.get("id", "")))
		guard += 1

	expect(not app.game.character_event_in_progress() and guard <= NODE_COUNT + 4, "production route completes")
	expect(int(app.game.relation_for("pharmacist_manami").get("level", 0)) == 2, "Manami relationship settles at Lv2")
	var solo_dates_after: int = app.game.character_progress_counter("pharmacist_manami", "completed_sunday_dates")
	expect(solo_dates_after == solo_dates_before, "trio dinner does not increment completed_sunday_dates")

	print("MANAMI LV2 TEST: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
