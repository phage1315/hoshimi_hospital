extends SceneTree
## Runtime regression test for Shiori Fujisaki's Relationship Lv1 event V1.2:
## 《藤崎医生的烦恼》 (shiori_lv1_doctors_worry).

const ID := "shiori_lv1_doctors_worry"
const INTRO_CLINIC := "intro_doc_shiori_whole_patient"
const INTRO_WARD := "intro_doc_shiori_whole_patient_ward"
const NODE_COUNT := 94
const EventSession = preload("res://godot/systems/character_event_session.gd")
const Codec = preload("res://godot/systems/boundary_save.gd")

var app
var checks := 0
var failures := 0
var han := RegEx.new()

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func inspect_clean(value: Variant, path: String = "root") -> void:
	if value is Dictionary:
		for key in value:
			expect(
				key not in [
					"node_id", "stage_id", "choices", "choice_id", "action_log",
					"last_choice", "feedback", "speaker", "opening_index", "response_index",
					"procedure_step_index", "resolved_random_choices", "surgery_rng_seed",
					"case_variant_id", "diagnosis_action_order", "active_special_event", "active_adult_intimacy"
				],
				"no inner state at " + path + "." + str(key)
			)
			inspect_clean(value[key], path + "." + str(key))
	elif value is Array:
		for item in value:
			inspect_clean(item, path)

func _initialize() -> void:
	han.compile("[㐀-鿿]")
	call_deferred("run")

func test_session_traversal(definition: Dictionary, locale: String) -> void:
	var session = EventSession.new(definition)
	var guard := 0
	var visited := {}
	var seen_exprs := {}
	while not session.completed and guard <= NODE_COUNT + 4:
		guard += 1
		var node: Dictionary = session.current()
		var node_id := str(node.get("id", ""))
		expect(not node_id.is_empty() and not visited.has(node_id), "valid acyclic node " + node_id)
		visited[node_id] = true
		seen_exprs[str(node.get("expression", ""))] = true
		var beat_idx := int(node_id.split("_")[1])
		if beat_idx == 1 or beat_idx == NODE_COUNT:
			expect(bool(node.get("hide_portrait", false)), "opening/closing beat hides portrait " + node_id)
		else:
			expect(not bool(node.get("hide_portrait", false)), "middle beat shows portrait " + node_id)
			var eps: Array = node.get("event_portraits", [])
			expect(eps.size() == 1, "single Shiori portrait on " + node_id)
			if not eps.is_empty():
				var res_path := "res://" + str(eps[0].get("path", ""))
				expect(ResourceLoader.exists(res_path), "portrait resource exists " + res_path)
		if locale == "en":
			expect(han.search(str(node.get("text", ""))) == null, "English text has no CJK " + node_id)
			expect(han.search(str(node.get("speaker_label", ""))) == null, "English speaker has no CJK " + node_id)
		var choices: Array = node.get("choices", [])
		expect(choices.size() == 1, "linear continue/finish choice on " + node_id)
		if choices.is_empty():
			return
		if locale == "en":
			expect(han.search(str(choices[0].get("label", ""))) == null, "English choice has no CJK " + node_id)
		expect(session.apply(str(choices[0].get("id", "")), {}), "advance " + node_id)
	expect(session.completed and visited.size() == NODE_COUNT, "full 94-beat traversal in " + locale)
	expect(seen_exprs.size() == 6, "all 6 white_coat expressions exercised in " + locale)

func run_intro_to_end(intro_id: String) -> void:
	expect(app.game.start_character_event(intro_id) != null, "start intro " + intro_id)
	var guard := 0
	while app.game.character_event_in_progress() and guard <= 20:
		var node: Dictionary = app.game.character_events[intro_id].current()
		var choices: Array = node.get("choices", [])
		if choices.is_empty():
			break
		expect(app.game.choose_character_event(str(choices[0].get("id", ""))), "step intro " + intro_id)
		guard += 1
	expect(app.game.character_event_done(intro_id), "completed intro " + intro_id)
	app.game.finish_character_event()
	expect(bool(app.game.relation_for("doc_shiori").get("met", false)), "Shiori met after " + intro_id)
	expect(int(app.game.relation_for("doc_shiori").get("level", -1)) == 0, "Shiori stays Lv0 right after " + intro_id)

func run() -> void:
	var tmp_save_path := "/private/tmp/shiori_lv1_unused_%s.json" % OS.get_process_id()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = tmp_save_path
	root.add_child(app)
	await process_frame

	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "content loads " + locale)
		app.configure_game_content()
		var def: Dictionary = app.game.character_event_definitions.get(ID, {})
		expect(not def.is_empty() and def.get("nodes", []).size() == NODE_COUNT, "registered 94-beat Shiori Lv1 in " + locale)
		test_session_traversal(def, locale)

	# Reload canonical zh_CN for GameState gate + progression + save-boundary tests
	expect(app.content.load_all("zh_CN"), "reload zh_CN")
	app.configure_game_content()
	var definition: Dictionary = app.game.character_event_definitions.get(ID, {})

	# Check all white_coat portrait textures load cleanly via profile mapping
	var shiori_staff := {}
	for entry in app.content.collections.get("staff", []):
		if str(entry.get("id", "")) == "doc_shiori":
			shiori_staff = entry
			break
	var pmap: Dictionary = shiori_staff.get("visuals", {}).get("portraits", {})
	for expr in ["neutral", "smile", "serious", "worried", "gentle_smile", "professional", "wry_smile", "shy_reproach", "pensive"]:
		var key: String = "white_coat/" + str(expr)
		var p := "res://" + str(pmap.get(key, ""))
		expect(ResourceLoader.exists(p), "profile portrait exists for " + key)

	# 1) Verify WARD Lv0 intro path unlocks Shiori Lv1 once familiarity >= 10
	app.game.reset()
	app.game.completed_surgeries_total = 3
	expect(not app.game.character_event_available(definition), "not available before meeting Shiori")
	run_intro_to_end(INTRO_WARD)
	var rel_ward: Dictionary = app.game.relation_for("doc_shiori")
	rel_ward["familiarity"] = 9
	expect(not app.game.character_event_available(definition), "gated at familiarity 9 after ward intro")
	rel_ward["familiarity"] = 10
	expect(app.game.character_event_available(definition), "unlocked at familiarity 10 after ward intro")

	# 2) Verify CLINIC Lv0 intro path unlocks Shiori Lv1 at lounge (09:00-17:00) and run full production settlement
	app.game.reset()
	app.game.completed_surgeries_total = 3
	run_intro_to_end(INTRO_CLINIC)
	var rel: Dictionary = app.game.relation_for("doc_shiori")
	rel["familiarity"] = 10

	app.game.advance_story_to_day(1, 915) # 15:15
	expect(app.game.current_absolute_clock() == 915, "clock set to 15:15 (915)")
	var lounge_events: Array = app.game.character_events_at("lounge")
	var found_in_lounge := false
	for ev in lounge_events:
		if str(ev.get("id", "")) == ID:
			found_in_lounge = true
	expect(found_in_lounge, "shiori_lv1_doctors_worry offered at lounge at 15:15")

	var before_elapsed: int = app.game.elapsed()
	expect(app.game.start_character_event(ID) != null, "start Shiori Lv1 via GameState")
	expect(not app.game.can_save_progress(), "saving is locked during Shiori Lv1")

	var guard := 0
	while app.game.character_event_in_progress() and guard <= NODE_COUNT + 4:
		var node: Dictionary = app.game.character_events[ID].current()
		var choices: Array = node.get("choices", [])
		expect(not choices.is_empty(), "runtime node has choice " + str(node.get("id", "")))
		if choices.is_empty():
			break
		expect(app.game.choose_character_event(str(choices[0].get("id", ""))), "runtime step " + str(node.get("id", "")))
		guard += 1

	expect(not app.game.character_event_in_progress() and guard == NODE_COUNT, "production event finished cleanly in 94 steps")
	expect(app.game.elapsed() - before_elapsed == 15, "elapsed time increased by 15 minutes")
	expect(app.game.character_event_done(ID), "shiori_lv1_doctors_worry marked done")
	expect(int(app.game.relation_for("doc_shiori").get("level", 0)) == 1, "Shiori relationship promoted to Lv1")
	expect(app.game.relation_for("doc_shiori").get("rank_history", []).has(ID), "rank_history records shiori_lv1_doctors_worry")
	expect(app.game.relation_for("doc_shiori").get("flags", []).has("shiori_lv1_himoo_mentioned"), "stable semantic flag settled")
	expect(not app.game.can_save_progress(), "saving stays locked on result screen before leaving event")
	app.game.finish_character_event()
	expect(app.game.can_save_progress(), "saving unlocked again at safe lounge boundary")

	# 3) Verify BoundarySave v37 round-trip with zero inner state persisted
	var snap: Dictionary = app.game.snapshot()
	expect(snap.get("save_format") == Codec.FORMAT and int(snap.get("version", 0)) == Codec.VERSION, "BoundarySave v37 format")
	inspect_clean(snap)
	var snap_json := JSON.stringify(snap)
	expect(not snap_json.contains("slv1_"), "zero internal node IDs in BoundarySave payload")

	var settled_elapsed: int = app.game.elapsed()
	var settled_aff: int = int(app.game.relation_for("doc_shiori").get("affection", 0))
	var settled_fam: int = int(app.game.relation_for("doc_shiori").get("familiarity", 0))

	app.game.reset()
	expect(int(app.game.relation_for("doc_shiori").get("level", -1)) == 0, "reset cleared in-memory level")
	expect(app.game.restore(snap), "BoundarySave v37 restore succeeds: " + app.game.last_error)
	expect(app.game.elapsed() == settled_elapsed, "settled time preserved across restore")
	expect(int(app.game.relation_for("doc_shiori").get("level", 0)) == 1, "Lv1 preserved across restore")
	expect(int(app.game.relation_for("doc_shiori").get("affection", 0)) == settled_aff, "affection preserved without duplicate grant")
	expect(int(app.game.relation_for("doc_shiori").get("familiarity", 0)) == settled_fam, "familiarity preserved without duplicate grant")
	expect(app.game.character_event_done(ID), "completed event fact preserved across restore")
	expect(not app.game.character_event_available(definition), "completed event does not re-trigger after restore")

	if FileAccess.file_exists(tmp_save_path):
		DirAccess.remove_absolute(tmp_save_path)

	print("SHIORI LV1 TEST: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
