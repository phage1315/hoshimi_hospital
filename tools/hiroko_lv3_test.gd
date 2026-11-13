extends SceneTree
## Runtime regression test for Hiroko Sugimura's V1.2 events:
## 1. Relationship Lv3 Rank-Up Event: 《另一家医院的灯光》 (hiroko_lv3_another_hospital_lights)
## 2. Independent Summer Bonus Event: 《夏夜的烟花》 (hiroko_summer_fireworks, Lv3 & Lv4+ tracks)

const LV3_ID := "hiroko_lv3_another_hospital_lights"
const LV3_NODE_COUNT := 118
const SUMMER_ID := "hiroko_summer_fireworks"
const SUMMER_NODE_COUNT := 166
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

func walk_session(definition: Dictionary, start_node: String, locale: String, choice_idx: int, coverage: Dictionary, max_steps: int) -> void:
	var session = EventSession.new(definition, start_node)
	var guard := 0
	var visited := {}
	while not session.completed and guard <= max_steps + 4:
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
		expect(session.apply(str(choices[pick].get("id", "")), {}), "advance " + node_id)
	expect(session.completed and guard <= max_steps + 4, "route terminates %s/%s/choice=%s" % [locale, start_node, choice_idx])

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/hiroko_lv3_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "content loads " + locale)
		app.configure_game_content()

		var lv3_def: Dictionary = app.game.character_event_definitions.get(LV3_ID, {})
		expect(not lv3_def.is_empty() and lv3_def.get("nodes", []).size() == LV3_NODE_COUNT, "registered 118-beat Hiroko Lv3 " + locale)
		var lv3_cov := {}
		for choice_idx in [0, 1]:
			walk_session(lv3_def, str(lv3_def.get("start", "")), locale, choice_idx, lv3_cov, LV3_NODE_COUNT)
		expect(lv3_cov.size() == LV3_NODE_COUNT, "all 118 Lv3 nodes covered in %s (%s/%s)" % [locale, lv3_cov.size(), LV3_NODE_COUNT])

		var summer_def: Dictionary = app.game.character_event_definitions.get(SUMMER_ID, {})
		expect(not summer_def.is_empty() and summer_def.get("nodes", []).size() == SUMMER_NODE_COUNT, "registered 166-beat Hiroko Summer Fireworks " + locale)
		var summer_cov := {}
		for choice_idx in [0, 1]:
			walk_session(summer_def, "hsf_lv3_001", locale, choice_idx, summer_cov, 82)
			walk_session(summer_def, "hsf_lv4_001", locale, choice_idx, summer_cov, 84)
		expect(summer_cov.size() == SUMMER_NODE_COUNT, "all 166 Summer Fireworks nodes covered in %s (%s/%s)" % [locale, summer_cov.size(), SUMMER_NODE_COUNT])

	# Verify runtime availability & presence <= -30 gate on Hiroko Lv3
	expect(app.game.prepare_character_event_test_save(LV3_ID), "prepare isolated Hiroko Lv3 fixture")
	var lv3_def: Dictionary = app.game.character_event_definitions.get(LV3_ID, {})
	app.game.player["presence"] = -10
	expect(not app.game.character_event_available(lv3_def), "Hiroko Lv3 requires gentle presence <= -30")
	app.game.player["presence"] = -30
	expect(app.game.character_event_available(lv3_def), "Hiroko Lv3 unlocks when presence <= -30")

	expect(app.game.start_character_event(LV3_ID) != null, "Hiroko Lv3 starts through GameState")
	expect(not app.game.can_save_progress(), "saving is locked while Hiroko Lv3 is in progress")
	var guard := 0
	while app.game.character_event_in_progress() and guard <= LV3_NODE_COUNT + 4:
		var node: Dictionary = app.game.character_events[LV3_ID].current()
		var choices: Array = node.get("choices", [])
		expect(app.game.choose_character_event(str(choices[0].get("id", ""))), "runtime route advances " + str(node.get("id", "")))
		guard += 1

	expect(not app.game.character_event_in_progress(), "Hiroko Lv3 production route completes")
	expect(int(app.game.relation_for("nurse_hiroko").get("level", 0)) == 3, "Hiroko relationship settles at Lv3")
	expect(app.game.story_flag("hiroko_lv3_complete"), "hiroko_lv3_complete flag settled")
	expect(app.game.story_flag("hiroko_boundary_trust_established"), "hiroko_boundary_trust_established flag settled for Lv4 prerequisite")

	# Verify Summer Fireworks Sunday Date upgrade & opening_variants routing (Lv3 vs Lv4)
	var summer_def: Dictionary = app.game.character_event_definitions.get(SUMMER_ID, {})
	app.game.day = 104 # July 13, 2025 (Sunday in Summer month 7)
	app.game.minute_of_day = 540
	app.game.sunday_activity_done = false
	expect(app.game.is_sunday(), "Day 104 is a Sunday")
	expect(app.game.calendar_month_number() == 7, "Day 104 is in July (month 7)")
	expect(app.game.sunday_character_event_for("nurse_hiroko") == SUMMER_ID, "Sunday invitation in summer upgrades to hiroko_summer_fireworks")
	expect(app.game.character_event_opening_node(summer_def) == "hsf_lv3_001", "At Lv3, opening_variants selects hsf_lv3_001")

	app.game.relation_for("nurse_hiroko")["level"] = 4
	expect(app.game.character_event_opening_node(summer_def) == "hsf_lv4_001", "At Lv4+, opening_variants selects hsf_lv4_001")

	print("HIROKO LV3 & SUMMER FIREWORKS TEST: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
