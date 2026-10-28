extends SceneTree
const IDS := ["itsumi_lv0_c_corridor", "itsumi_lv0_d_instrument_tray", "itsumi_lv0_e_hiroko_invitation", "intro_itsumi_lv0_f_station"]
const ACTOR := "nurse_sonoda_itsumi"
var checks := 0
var failures := 0
func expect(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(note)
func _initialize() -> void:
	call_deferred("run")
func play(app, id: String, count: int, minutes: int) -> void:
	var game = app.game
	var before: int = game.elapsed()
	var event = game.start_character_event(id)
	expect(event != null, "Start " + id)
	if event == null:
		return
	for i in range(count):
		expect(not game.staff_is_met(ACTOR), "Unmet before last node " + id)
		expect(not game.can_save_progress(), "Save locked during event")
		app.show_character_event()
		var node: Dictionary = event.current()
		expect(not str(node.text).is_empty(), "Localized node")
		if id == IDS[3]:
			expect(node.outfit == "uniform", "F never flashes masked outfit")
		expect(game.choose_character_event(node.choices[0].id), "Advance node")
	expect(event.completed, "Complete " + id)
	expect(game.elapsed() - before == minutes, "Exact duration " + id)
	game.finish_character_event()
	expect(game.can_save_progress(), "Saving restored on exit")
func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/tmp/hoshimi_next20_unused_itsumi_intro_test_"+str(OS.get_process_id())+".json"
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Locale " + locale)
		app.configure_game_content()
		var game = app.game
		game.reset()
		game.probation_complete = true
		var defs: Array = IDS.map(func(id): return game.character_event_definitions[id])
		game.completed_surgeries_total = 4
		expect(not game.character_event_available(defs[0]), "C threshold")
		game.completed_surgeries_total = 5
		expect(game.character_event_available(defs[0]), "C available at 5")
		expect(not game.character_event_available(defs[1]), "D requires C and 10")
		# A high-count legacy save must still play the stages in order.
		game.completed_surgeries_total = 15
		var higher: Dictionary = defs[0].duplicate(true)
		higher.id = "test_higher_postop"
		higher.priority = 999
		game.character_event_definitions[higher.id] = higher
		expect(game.next_character_event_for_preop_stage("post_surgery_return").id == higher.id, "Existing higher priority wins")
		game.character_event_definitions.erase(higher.id)
		expect(game.character_events_at("or").all(func(d): return d.id not in IDS), "No corridor event from ordinary location visit")
		var checkpoint: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
		var interrupted = game.start_character_event(IDS[0])
		game.choose_character_event(interrupted.current().choices[0].id)
		expect(not game.staff_is_met(ACTOR), "Interrupted C does not meet")
		expect(game.restore(checkpoint), "Reload before event")
		expect(game.character_event_available(defs[0]), "Interrupted C can retry")
		play(app, IDS[0], 13, 2)
		expect(not game.character_event_available(defs[1]), "No D after same operation")
		var saved: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
		expect(game.restore(saved), "C saved state restores")
		expect(not game.character_event_available(defs[1]), "Same-operation guard survives reload")
		app.show_event_gallery()
		var entry = app.page.find_child("GalleryEvent_" + IDS[0], true, false)
		expect(entry != null, "Gallery entry exists")
		if entry != null:
			expect(not str(entry.text).contains("愛実") and not str(entry.text).contains("Itsumi"), "Gallery hides real name")
		game.completed_surgeries_total = 16
		play(app, IDS[1], 23, 5)
		game.completed_surgeries_total = 17
		expect(not game.character_event_available(defs[2]), "E waits for Hiroko")
		game.meet_staff("nurse_hiroko")
		expect(game.relationship_level("nurse_hiroko") == 0, "Hiroko Lv0 enough")
		expect(game.character_event_available(defs[2]), "No additional count required after meeting Hiroko")
		var hiroko: Dictionary = game.relation_for("nurse_hiroko").duplicate(true)
		play(app, IDS[2], 16, 3)
		expect(not game.staff_is_met(ACTOR), "E invitation not meeting")
		expect(game.character_events_at("station").any(func(d): return d.id == IDS[3]), "F available on station visit same day")
		expect(game.character_events_at("ward").all(func(d): return d.id != IDS[3]), "F station only")
		expect(game.next_character_event_for_preop_stage("post_surgery_return").get("id", "") not in IDS, "F not an automatic post-op stage")
		checkpoint = JSON.parse_string(JSON.stringify(game.snapshot()))
		var f = game.start_character_event(IDS[3])
		for i in range(8):
			game.choose_character_event(f.current().choices[0].id)
		expect(not game.staff_is_met(ACTOR), "Name reveal is not met flag")
		expect(game.restore(checkpoint), "Interrupted F reload")
		play(app, IDS[3], 35, 10)
		var relation: Dictionary = game.relation_for(ACTOR)
		expect(relation.met and relation.level == 0, "F registers Lv0")
		expect(relation.affection == 0 and relation.familiarity == 0, "No bonus")
		expect(game.relation_for("nurse_hiroko") == hiroko, "Hiroko unchanged")
		expect(game.staff_can_join_surgery_team(ACTOR), "Nurse can join team")
		expect(not game.character_event_available(defs[3]), "F one time")
		saved = JSON.parse_string(JSON.stringify(game.snapshot()))
		expect(game.restore(saved) and game.staff_is_met(ACTOR), "Completed state persists")
	print("Itsumi introduction: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
