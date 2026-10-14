extends SceneTree
const Prep = preload("res://godot/systems/preop_session.gd")
var checks := 0
var failures := 0
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		app.game.reset()
		app.game.micro_event_definitions.clear()
		app.game.character_event_definitions.clear()
		var definition: Dictionary = app.content.collections.preops[0]
		var visit = app.game.open_visit(str(definition.encounter_id))
		visit.admitted = true
		visit.stage_id = str(visit.definition.completion)
		var prep := Prep.new(definition, app.game.staff, app.content.collections.surgeries, app.content.collections.patients)
		prep.stage_id = "surgery_result"
		prep.procedure_id = "surgery_open_distal_pancreatectomy"
		prep.procedure_name = app.game.surgery_definition(prep.procedure_id).name
		prep.team = {"assistant_surgeon": "doc_shiori", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_yui"}
		prep.surgery_success = true
		prep.feedback = "A long operation record. ".repeat(12)
		app.game.preops[definition.id] = prep
		app.game.active_preop_id = str(definition.id)
		app.game.active_mode = "preop"
		app.game.surgery_xp = app.game.surgery_xp_for_level(51) - 1
		app.game.leadership_xp = app.game.leadership_xp_for_level(app.game.leadership_level() + 1) - 0.1
		var before = app.game.snapshot()
		var raw := "`{assistant_name}` / `{scrub_name}` / `{circulator_name}` / `other`"
		var formatted := prep.surgery_display_text(raw)
		expect(not formatted.contains("{assistant_name}") and formatted.contains("`other`") and formatted.count("`") == 2, "Only role markup removed")
		var source_name: String = prep.roster.doc_shiori.name
		var expected_name := source_name if locale == "en" else source_name.replace(" ", "")
		expect(formatted.begins_with(expected_name + " / "), "Role placeholder name spacing")
		expect(prep.surgery_display_text(source_name + " · note with spaces") == expected_name + " · note with spaces", "Resolved name must preserve prose spacing")
		expect(prep.surgery_display_text(source_name) == expected_name, "Speaker name spacing")
		expect(prep.roster.doc_shiori.name == source_name, "Display normalization changed profile")
		expect(prep.staff_display_name("藤崎　詩織") == ("藤崎　詩織" if locale == "en" else "藤崎詩織"), "Full-width name space")
		app.show_preop(str(definition.id))
		await process_frame
		expect(app.page.get_node_or_null("CharacterPortrait") == null and app.page.get_node_or_null("PreopStageArt") == null, "Result still displays portrait")
		for name in ["SurgeryResultSummary", "SurgeryResultMetrics", "PreopRecordText", "PatientExperienceResult", "SurgerySettlementTime"]:
			var text: Control = app.page.get_node(name)
			expect(text.get_rect().end.x <= 1225 and text.get_rect().end.y <= 700, "Result bounds " + name)
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/surgery_result_" + locale + ".png")
		app.page.get_node("SurgeryResultReturn").pressed.emit()
		var overlay: Control = app.page.get_node_or_null("SurgeryGrowthSplash")
		expect(overlay != null, "Growth missing")
		expect(app.game.completed_surgeries_total == 1, "Not settled once")
		var xp := int(app.game.surgery_xp)
		expect(xp > int(before.surgery_xp) and app.game.surgery_level() >= 51, "Surgical XP/level not awarded")
		expect(app.game.leadership_xp > before.leadership_xp, "Leadership XP not awarded")
		expect(overlay.get_node("SurgeryGrowthTeam").text.contains(str(prep.roster.doc_shiori.name)), "Team member missing")
		app.settle_surgery_return()
		expect(app.game.completed_surgeries_total == 1 and app.game.surgery_xp == xp, "Duplicate settlement")
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/surgery_growth_" + locale + ".png")
		overlay.get_node("SurgeryGrowthContinue").pressed.emit()
		expect(app.page.get_node_or_null("SurgeryGrowthSplash") == null, "Growth did not close")
		expect(app.game.completed_surgeries_total == 1, "Continuation awarded twice")
		expect(app.screen == "map" and app.game.can_save_progress(), "Postoperative directory must allow saving")
		var next_patient: String = app.game.current_patient_id()
		var next_encounter: String = app.game.encounter_id_for_patient(next_patient)
		expect(next_patient != str(definition.patient_id) and not next_encounter.is_empty(), "Patient queue did not rotate")
		expect(app.game.active_id.is_empty() and not app.game.active_encounter_in_progress(), "Settlement started the next consultation")
		app.save_progress()
		expect(app.screen == "save_slots", "Directory save button did not open slots")
		var store = load("res://godot/systems/save_store.gd").new()
		store.path = "/tmp/hoshimi_postoperative_save_regression_" + locale + ".json"
		expect(store.write_slot(app.game, 1), "Actual postoperative save failed")
		var save: Dictionary = app.game.snapshot()
		expect(app.game.restore(save) and app.game.surgery_xp == xp, "Settled rewards failed roundtrip: " + app.game.last_error)
		expect(store.read_slot(app.game, 1) and app.game.can_save_progress(), "Actual postoperative load did not restore save boundary")
		expect(app.game.current_patient_id() == next_patient and app.game.completed_surgeries_total == 1, "Load changed queue/rewards")
		expect(app.game.open_visit(next_encounter) != null and not app.game.can_save_progress(), "Explicit consultation must still lock saving")
		app.game.reset()
		var aborted := Prep.new(definition, app.game.staff, app.content.collections.surgeries)
		aborted.surgery_aborted = true
		app.game.preops[definition.id] = aborted
		app.game.active_preop_id = str(definition.id)
		app.game.active_mode = "preop"
		expect(app.game.finish_active_surgery_abort(), "Abort settlement failed")
		expect(app.game.can_save_progress() and app.game.active_id.is_empty(), "Abort settlement started a consultation")
	app.free()
	print("SURGERY RESULT GROWTH: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures else 0)
