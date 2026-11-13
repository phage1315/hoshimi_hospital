extends SceneTree
## Runtime regression test for Shiori Fujisaki's Relationship Lv2 event V1.0:
## 《唱片店里的藤崎诗织》 (shiori_lv2_record_shop).

const ID := "shiori_lv2_record_shop"
const LV1_ID := "shiori_lv1_doctors_worry"
const INTRO_WARD := "intro_doc_shiori_whole_patient_ward"
const NODE_COUNT := 231
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

func traverse_branch_index(definition: Dictionary, locale: String, opt_idx: int, seen_portraits: Dictionary, seen_bgs: Dictionary, seen_nodes: Dictionary) -> void:
	var session = EventSession.new(definition)
	var guard := 0
	var visited_local := {}
	var rp_count := 0
	while not session.completed and guard <= NODE_COUNT + 6:
		guard += 1
		var node: Dictionary = session.current()
		var node_id := str(node.get("id", ""))
		expect(not node_id.is_empty() and not visited_local.has(node_id), "valid acyclic node " + node_id)
		visited_local[node_id] = true
		seen_nodes[node_id] = true
		seen_bgs[str(node.get("background_id", ""))] = true

		var eps: Array = node.get("event_portraits", [])
		if bool(node.get("hide_portrait", false)):
			expect(eps.is_empty(), "hidden-portrait beat has empty event_portraits on " + node_id)
		else:
			expect(not eps.is_empty(), "visible beat has event_portraits on " + node_id)
			for ep in eps:
				var p := str(ep.get("path", ""))
				seen_portraits[p] = true
				expect(ResourceLoader.exists("res://" + p), "portrait resource exists res://" + p)

		if locale == "en":
			expect(han.search(str(node.get("text", ""))) == null, "English text has no CJK " + node_id)
			expect(han.search(str(node.get("speaker_label", ""))) == null, "English speaker has no CJK " + node_id)

		var choices: Array = node.get("choices", [])
		expect(choices.size() in [1, 2], "1 or 2 choices on " + node_id)
		if choices.is_empty():
			return
		var pick := 0
		if choices.size() == 2:
			rp_count += 1
			pick = opt_idx
		if locale == "en":
			for ch in choices:
				expect(han.search(str(ch.get("label", ""))) == null, "English choice has no CJK on " + node_id)
		expect(session.apply(str(choices[pick].get("id", "")), {}), "advance " + node_id)

	expect(session.completed, "completed traversal opt=" + str(opt_idx) + " in " + locale)
	expect(rp_count == 3, "encountered all 3 RP choices in " + locale + " opt=" + str(opt_idx))

func play_event_via_gamestate(ev_id: String) -> void:
	expect(app.game.start_character_event(ev_id) != null, "start " + ev_id)
	var guard := 0
	while app.game.character_event_in_progress() and guard <= 300:
		var node: Dictionary = app.game.character_events[ev_id].current()
		var choices: Array = node.get("choices", [])
		if choices.is_empty():
			break
		expect(app.game.choose_character_event(str(choices[0].get("id", ""))), "step " + ev_id)
		guard += 1
	app.game.finish_character_event()

func run() -> void:
	var tmp_save_path := "/private/tmp/shiori_lv2_unused_%s.json" % OS.get_process_id()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = tmp_save_path
	root.add_child(app)
	await process_frame

	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "content loads " + locale)
		app.configure_game_content()
		var def: Dictionary = app.game.character_event_definitions.get(ID, {})
		expect(not def.is_empty() and def.get("nodes", []).size() == NODE_COUNT, "registered 231-beat Shiori Lv2 in " + locale)
		var seen_portraits := {}
		var seen_bgs := {}
		var seen_nodes := {}
		traverse_branch_index(def, locale, 0, seen_portraits, seen_bgs, seen_nodes)
		traverse_branch_index(def, locale, 1, seen_portraits, seen_bgs, seen_nodes)
		expect(seen_nodes.size() == NODE_COUNT, "union of A/B traversals covers all 231 nodes in " + locale)
		expect(seen_portraits.size() == 14, "all 14 Shiori + Yuko sprites exercised in " + locale)
		for bg_id in ["ward", "hallway", "hospital_courtyard_evening", "serika_lv3_street_evening", "shiori_lv2_classical_record_shop", "shiori_lv2_station_plaza_night"]:
			expect(seen_bgs.has(bg_id), "background exercised " + bg_id + " in " + locale)
			var bg_rec: Dictionary = app.content.find_record("backgrounds", bg_id)
			expect(not bg_rec.is_empty() and ResourceLoader.exists("res://" + str(bg_rec.get("path", ""))), "background resource loads for " + bg_id)
			if locale == "en":
				expect(han.search(str(bg_rec.get("label", ""))) == null, "EN background label has no CJK for " + bg_id)

	# Reload zh_CN for production gate, cooldown, UI settlement, and BoundarySave v37 checks
	expect(app.content.load_all("zh_CN"), "reload zh_CN")
	app.configure_game_content()
	var definition: Dictionary = app.game.character_event_definitions.get(ID, {})

	# 1) Gate & 3-day cooldown checks
	app.game.reset()
	app.game.completed_surgeries_total = 3
	expect(not app.game.character_event_available(definition), "locked before meeting Shiori")

	play_event_via_gamestate(INTRO_WARD)
	var rel: Dictionary = app.game.relation_for("doc_shiori")
	rel["familiarity"] = 25
	expect(not app.game.character_event_available(definition), "locked before Lv1 completed even with familiarity=25")

	app.game.advance_story_to_day(2, 600)
	play_event_via_gamestate(LV1_ID)
	expect(int(rel.get("level", 0)) == 1, "Shiori promoted to Lv1 on Day 2")
	rel["familiarity"] = 25

	app.game.advance_story_to_day(4, 865) # Day 4 (only +2 days after Day 2) -> blocked by 3-day cooldown
	expect(not app.game.character_event_available(definition), "blocked on Day 4 by 3-day cooldown after Day 2 Lv1")

	app.game.advance_story_to_day(5, 660) # Day 5 11:00 (cooldown met, familiarity check + morning time window check)
	rel["familiarity"] = 24
	expect(not app.game.character_event_available(definition), "blocked at familiarity=24 on Day 5")
	rel["familiarity"] = 25
	expect(app.game.character_event_available(definition), "eligible at familiarity=25 on Day 5 after 3-day cooldown")

	# Morning 11:00 should not offer afternoon ward event (time_start=720)
	var ward_morning: Array = app.game.character_events_at("ward")
	var found_morning := false
	for ev in ward_morning:
		if str(ev.get("id", "")) == ID:
			found_morning = true
	expect(not found_morning, "not offered at ward at 11:00 before 12:00 window")

	# Advance to 14:25 (865) on Day 5 -> offered at ward!
	app.game.advance_story_to_day(5, 865)
	var ward_afternoon: Array = app.game.character_events_at("ward")
	var found_afternoon := false
	for ev in ward_afternoon:
		if str(ev.get("id", "")) == ID:
			found_afternoon = true
	expect(found_afternoon, "shiori_lv2_record_shop offered at ward at 14:25 on Day 5")

	# 2) Drive full UI completion via app.choose_character_event to verify cross-day 09:00 settlement + save lock
	var ev_session = app.game.start_character_event(ID)
	expect(ev_session != null, "start Shiori Lv2 on Day 5")
	app.character_event_return_location = "ward"
	app.reset_dialogue_page()
	app.show_character_event()
	expect(not app.game.can_save_progress(), "saving strictly locked during Shiori Lv2 playback")

	var step_guard := 0
	while not ev_session.completed and step_guard <= NODE_COUNT + 6:
		step_guard += 1
		var cur: Dictionary = ev_session.current()
		var chs: Array = cur.get("choices", [])
		expect(not chs.is_empty(), "choices present at " + str(cur.get("id", "")))
		app.choose_character_event(str(chs[0].get("id", "")))

	expect(ev_session.completed, "Shiori Lv2 session completed")
	expect(app.game.day_number() == 6 and app.game.current_absolute_clock() == 540, "settled to next workday Day 6 09:00 (540)")
	expect(app.screen == "day_transition", "day_transition screen displayed after evening station farewell")
	expect(not app.game.can_save_progress(), "saving stays locked on day_transition screen")

	var dt_btn: Button = app.page.get_node_or_null("DayTransitionContinue")
	expect(dt_btn != null, "DayTransitionContinue button present")
	if dt_btn != null:
		dt_btn.pressed.emit()
	var expected_safe_screen := "sunday_menu" if app.game.is_sunday() else "map"
	expect(app.screen == expected_safe_screen, "DayTransitionContinue returns directly to next-day safe boundary (" + expected_safe_screen + ")")
	expect(app.game.active_character_event_id.is_empty(), "active_character_event_id cleared after DayTransitionContinue")
	expect(app.game.can_save_progress(), "saving unlocked again at safe boundary on Day 6 09:00")

	expect(int(app.game.relation_for("doc_shiori").get("level", 0)) == 2, "Shiori relationship promoted to Lv2")
	expect(app.game.relation_for("doc_shiori").get("rank_history", []).has(ID), "rank_history records shiori_lv2_record_shop")
	for flag_name in ["shiori_lv2_complete", "shiori_asahina_yuko_consulted", "shiori_classical_records_shared"]:
		expect(app.game.story_flag(flag_name), "completion story flag set: " + flag_name)

	# 3) Verify BoundarySave v37 round-trip with zero inner state persisted
	var snap: Dictionary = app.game.snapshot()
	expect(snap.get("save_format") == Codec.FORMAT and int(snap.get("version", 0)) == Codec.VERSION, "BoundarySave v37 format")
	inspect_clean(snap)
	var snap_json := JSON.stringify(snap)
	expect(not snap_json.contains("slv2_"), "zero slv2_ internal node IDs in BoundarySave payload")

	var settled_elapsed: int = app.game.elapsed()
	var settled_aff: int = int(app.game.relation_for("doc_shiori").get("affection", 0))
	var settled_fam: int = int(app.game.relation_for("doc_shiori").get("familiarity", 0))

	app.game.reset()
	expect(int(app.game.relation_for("doc_shiori").get("level", -1)) == 0, "reset cleared in-memory level")
	expect(app.game.restore(snap), "BoundarySave v37 restore succeeds: " + app.game.last_error)
	expect(app.game.elapsed() == settled_elapsed and app.game.day_number() == 6 and app.game.current_absolute_clock() == 540, "Day 6 09:00 preserved across restore")
	expect(int(app.game.relation_for("doc_shiori").get("level", 0)) == 2, "Lv2 preserved across restore")
	expect(int(app.game.relation_for("doc_shiori").get("affection", 0)) == settled_aff, "affection preserved without duplicate grant")
	expect(int(app.game.relation_for("doc_shiori").get("familiarity", 0)) == settled_fam, "familiarity preserved without duplicate grant")
	expect(app.game.character_event_done(ID), "completed event fact preserved across restore")
	expect(not app.game.character_event_available(definition), "completed event does not re-trigger after restore")

	if FileAccess.file_exists(tmp_save_path):
		DirAccess.remove_absolute(tmp_save_path)

	print("SHIORI LV2 TEST: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
