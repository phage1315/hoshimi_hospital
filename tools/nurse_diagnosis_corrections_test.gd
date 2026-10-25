extends SceneTree

var checks := 0
var failures := 0
var app
var saved_chinese: Dictionary = {}
var source: Dictionary
const ACTIONS := ["diagnose_gastro", "diagnose_observe"]

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func copy_json(value: Variant) -> Variant:
	return JSON.parse_string(JSON.stringify(value))

func _initialize() -> void:
	call_deferred("run")

func expected_line(actor_id: String, action_id: String, locale: String) -> String:
	if actor_id == "doc_aoi":
		var visit = app.game.visits.visit_sora
		return str(visit.find_action(action_id).response)
	if locale == "zh_CN":
		return str(source[actor_id][action_id])
	return str(app.content.localizer.strings["collections.staff.%s.personal_nurse.diagnosis_corrections.%s" % [actor_id, action_id]])

func check_page(actor_id: String, text: String) -> void:
	var dialogue: RichTextLabel = app.page.get_node_or_null("ClinicDialogue")
	expect(dialogue != null and dialogue.text == text, "Exact authored dialogue reaches rendered UI")
	var person: Dictionary = app.content.find_record("staff", actor_id)
	var speaker_visible := false
	for child in app.page.get_children():
		if child is Label and child.text == person.name:
			speaker_visible = true
	expect(speaker_visible, "Correct speaker label is rendered: " + actor_id)

func run() -> void:
	source = JSON.parse_string(FileAccess.get_file_as_string("res://tools/fixtures/nurse_diagnosis_corrections_zh.json"))
	expect(source.size() == 8 and source.has("nurse_hikami_saeko"), "Approved source includes Saeko and the seven original nurses")
	app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Localized content loads")
		app.configure_game_content()
		var game = app.game
		game.probation_complete = true
		game.personal_nurse_system_unlocked = true
		for actor_id in source:
			game.meet_staff(actor_id)
			expect(game.personal_nurse_candidates().has(actor_id), "Approved nurse is eligible")
			var person: Dictionary = app.content.find_record("staff", actor_id)
			for action_id in ACTIONS:
				expect(person.personal_nurse.diagnosis_corrections[action_id] == expected_line(actor_id, action_id, locale), "Source/translation exactly matches profile: " + actor_id + "/" + action_id)
		var visit = game.open_visit("visit_sora")
		for action_id in ["greet", "pain", "associated", "background", "to_exam", "vitals", "request_full_undress", "authoritative_full_undress", "blood", "imaging", "to_diagnosis"]:
			expect(game.apply_clinic_action(action_id), "Reach diagnosis through real clinical actions")
		var baseline: Dictionary = copy_json(game.snapshot())
		var actors: Array = source.keys() + ["doc_aoi"]
		for actor_id in actors:
			for action_id in ACTIONS:
				expect(game.restore(baseline), "Restore clean diagnosis checkpoint")
				if actor_id == "doc_aoi":
					game.probation_complete = false
				else:
					expect(game.set_personal_nurse(actor_id), "Assign authored nurse")
				app.show_encounter("visit_sora")
				visit = game.visits.visit_sora
				var definition_before := JSON.stringify(visit.definition)
				var order: Array[String] = visit.diagnosis_action_order.duplicate()
				var before: int = game.elapsed()
				var action: Dictionary = visit.find_action(action_id).duplicate(true)
				app.page.get_node("Action_" + action_id).pressed.emit()
				var expected := expected_line(actor_id, action_id, locale)
				var line: Dictionary = game.clinic_presentation(visit)
				expect(line.text == expected and line.speaker == actor_id, "A/B maps to correct nurse text and speaker")
				expect(visit.stage_id == "diagnosis" and visit.mistakes == 1, "Mistake rule unchanged")
				expect(game.elapsed() == before + int(action.minutes), "Clinical time cost unchanged")
				expect(visit.diagnosis_action_order == order, "Correction does not reshuffle choices")
				expect(JSON.stringify(visit.definition) == definition_before, "Runtime does not overwrite shared narrative definitions")
				expect(visit.diagnosis_feedback_actor_id == actor_id, "Correction speaker is captured at action time")
				check_page(actor_id, expected)
				await process_frame
				var body: RichTextLabel = app.page.get_node("ClinicDialogue")
				expect(body.get_content_height() <= body.size.y, "Authored correction fits the dialogue area: " + actor_id + "/" + locale)
				if OS.get_cmdline_user_args().has("--visual"):
					await RenderingServer.frame_post_draw
					var path := "/private/tmp/hoshimi_nurse_correction_%s_%s_%s.png" % [locale, actor_id, action_id]
					expect(root.get_texture().get_image().save_png(path) == OK, "Save native screenshot")
					print("VISUAL ", path)
				var checkpoint: Dictionary = copy_json(game.snapshot())
				if locale == "zh_CN":
					saved_chinese[actor_id + "/" + action_id] = checkpoint
				for _redraw in range(2):
					app.toggle_clinic_record()
					check_page(actor_id, expected)
				# A new assignment must not rewrite a correction already delivered.
				game.probation_complete = true
				var other_actor := "nurse_rin" if actor_id == "nurse_haru" else "nurse_haru"
				expect(game.set_personal_nurse(other_actor), "Change current nurse after correction")
				app.show_encounter("visit_sora")
				check_page(actor_id, expected)
				var changed_assignment: Dictionary = copy_json(game.snapshot())
				expect(game.restore(changed_assignment), "Save with changed assignment restores")
				app.show_encounter("visit_sora")
				visit = game.visits.visit_sora
				check_page(actor_id, expected)
				expect(not game.apply_clinic_action(action_id), "Completed wrong choice cannot be repeated")
				expect(visit.diagnosis_feedback_actor_id == actor_id, "Rejected action does not change saved speaker")
				# Correct choice clears the presentation override and proceeds normally.
				var correct_response := str(visit.find_action("diagnose_appendix").response)
				expect(game.apply_clinic_action("diagnose_appendix"), "Correct answer still advances")
				expect(visit.stage_id == "plan" and visit.diagnosis_feedback_actor_id.is_empty(), "Correct answer clears correction context")
				expect(game.clinic_presentation(visit).text == correct_response, "Success line remains original")
				# A profile without a line must fall back instead of producing blank text.
				if actor_id != "doc_aoi":
					expect(game.restore(checkpoint), "Restore correction for fallback test")
					var person: Dictionary = game.staff_record(actor_id)
					var authored: Dictionary = person.personal_nurse.diagnosis_corrections.duplicate(true)
					person.personal_nurse.diagnosis_corrections.erase(action_id)
					expect(game.clinic_presentation(game.visits.visit_sora).text == action.response, "Missing authored line uses unchanged base correction")
					person.personal_nurse.diagnosis_corrections = authored
				var legacy: Dictionary = checkpoint.duplicate(true)
				legacy.progress.visit_sora.erase("diagnosis_feedback_actor_id")
				expect(game.restore(legacy), "Old save without speaker field loads")
				app.show_encounter("visit_sora")
				check_page(actor_id, expected)
				for invalid_actor in [null, 10, "missing_staff_id"]:
					var invalid: Dictionary = checkpoint.duplicate(true)
					invalid.progress.visit_sora.diagnosis_feedback_actor_id = invalid_actor
					var prior := JSON.stringify(game.snapshot())
					expect(not game.restore(invalid), "Malformed correction context rejected")
					expect(JSON.stringify(game.snapshot()) == prior, "Bad save preserves live state")
		if locale == "en":
			for key in saved_chinese:
				expect(game.restore(saved_chinese[key]), "Chinese checkpoint restores with English definitions")
				app.show_encounter("visit_sora")
				var parts: PackedStringArray = str(key).split("/")
				check_page(parts[0], expected_line(parts[0], parts[1], "en"))
	print("NURSE DIAGNOSIS CORRECTIONS: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
