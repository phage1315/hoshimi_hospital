extends SceneTree
## Runtime regression test for Hiroko Sugimura's Relationship Lv2 event:
## 《难得准时下班》 (hiroko_lv2_on_time_off_work).

const ID := "hiroko_lv2_on_time_off_work"
const NODE_COUNT := 169
const CG_SMILE := "assets/events/character_events/hiroko/hiroko_lv2_fukubiki_keychain_smile.png"
const CG_POUT := "assets/events/character_events/hiroko/hiroko_lv2_fukubiki_keychain_pout.png"
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

func test_route(definition: Dictionary, locale: String, choice_idx: int, coverage: Dictionary) -> void:
	var session = EventSession.new(definition)
	var choice_count := 0
	var guard := 0
	var visited := {}
	while not session.completed and guard <= NODE_COUNT + 4:
		guard += 1
		var node: Dictionary = session.current()
		var node_id := str(node.get("id", ""))
		expect(not node_id.is_empty() and not visited.has(node_id), "valid acyclic node " + node_id)
		var beat_num := int(node_id.split("_")[1])
		if beat_num >= 131 and beat_num <= 135:
			expect(str(node.get("cg_path", "")) == CG_SMILE and str(node.get("cg_fit", "")) == "cover" and not bool(node.get("hide_portrait", false)), "smile CG window " + node_id)
		elif beat_num >= 136 and beat_num <= 140:
			expect(str(node.get("cg_path", "")) == CG_POUT and str(node.get("cg_fit", "")) == "cover" and not bool(node.get("hide_portrait", false)), "pout CG window " + node_id)
		else:
			expect(str(node.get("cg_path", "")).is_empty(), "non-CG node " + node_id)
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
		expect(session.apply(str(choices[pick].get("id", "")), {}), "advance " + node_id)
	expect(session.completed and guard <= NODE_COUNT + 4, "route terminates %s/choice=%s" % [locale, choice_idx])
	expect(choice_count == 1, "Scene 3 RP choice reached")

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/hiroko_lv2_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "content loads " + locale)
		app.configure_game_content()
		var definition: Dictionary = app.game.character_event_definitions.get(ID, {})
		expect(not definition.is_empty() and definition.get("nodes", []).size() == NODE_COUNT, "registered 169-beat Hiroko Lv2 " + locale)
		var all_coverage := {}
		for choice_idx in [0, 1]:
			test_route(definition, locale, choice_idx, all_coverage)
		expect(all_coverage.size() == NODE_COUNT, "all 169 nodes covered in %s (%s/%s)" % [locale, all_coverage.size(), NODE_COUNT])

	# Verify runtime availability gates (independent of Manami Lv2)
	expect(app.game.prepare_character_event_test_save(ID), "prepare isolated Hiroko Lv2 fixture")
	var definition: Dictionary = app.game.character_event_definitions.get(ID, {})
	var manami_rel: Dictionary = app.game.relation_for("pharmacist_manami")
	manami_rel["met"] = false
	manami_rel["level"] = 0
	expect(app.game.character_event_available(definition), "Hiroko Lv2 does not depend on Manami")

	var hiroko_rel: Dictionary = app.game.relation_for("nurse_hiroko")
	expect(int(hiroko_rel.get("level", 0)) == 1, "fixture starts with Hiroko at Lv1")

	expect(app.game.start_character_event(ID) != null, "Hiroko Lv2 starts through GameState")
	expect(not app.game.can_save_progress(), "saving is locked while Hiroko Lv2 is in progress")

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
	expect(int(app.game.relation_for("nurse_hiroko").get("level", 0)) == 2, "Hiroko relationship settles at Lv2")
	expect(app.game.story_flag("hiroko_lv2_complete"), "hiroko_lv2_complete flag settled")

	print("HIROKO LV2 TEST: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
