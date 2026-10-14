extends SceneTree

const Encounter = preload("res://godot/systems/encounter_session.gd")
var checks := 0
var failures := 0
var app

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func ids(actions: Array) -> Array[String]:
	var result: Array[String] = []
	for action in actions:
		result.append(str(action.id))
	return result

func json_copy(value: Variant) -> Variant:
	return JSON.parse_string(JSON.stringify(value))

func _initialize() -> void:
	call_deferred("run")

func prepare(visit) -> void:
	for action in ["greet", "pain", "associated", "background", "to_exam", "vitals", "request_full_undress", "authoritative_full_undress", "blood", "imaging", "to_diagnosis"]:
		expect(visit.apply(action), "Clinical path reaches diagnosis: " + action)
	expect(visit.stage_id == "diagnosis", "At diagnosis")

func ui_ids() -> Array[String]:
	var buttons: Array = []
	for child in app.page.get_children():
		if child is Button and str(child.name).begins_with("Action_"):
			buttons.append(child)
	buttons.sort_custom(func(a, b): return a.position.y < b.position.y)
	var result: Array[String] = []
	for button in buttons:
		result.append(str(button.name).trim_prefix("Action_"))
	return result

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load locale")
		app.configure_game_content()
		var game = app.game
		var definition: Dictionary = game.definitions.visit_sora
		var original := JSON.stringify(definition)
		var positions := [0, 0, 0]
		var permutations: Dictionary = {}
		for i in range(300):
			var visit = Encounter.new(definition)
			visit.stage_id = "diagnosis"
			var order := ids(visit.ui_actions())
			positions[order.find("diagnose_appendix")] += 1
			permutations["|".join(order)] = true
			expect(order.size() == 3, "Three unique choices remain")
			expect(order == visit.diagnosis_action_order and order == ids(visit.ui_actions()), "Repeated reads retain order")
			var clone = Encounter.new(definition, false)
			expect(clone.restore_state(json_copy(visit.snapshot_state())), "Session JSON restore")
			expect(ids(clone.ui_actions()) == order, "Session restore retains order")
		expect(permutations.size() == 6, "All six permutations occur across new visits")
		for count in positions:
			expect(count > 0, "Correct answer can occupy each position")
		print("DIAGNOSIS POSITIONS ", locale, " ", positions)
		expect(JSON.stringify(definition) == original, "Source text, IDs, speaker and action definitions remain untouched")
		seed(81712)
		var untouched_rng := randi()
		seed(81712)
		Encounter.new(definition)
		expect(randi() == untouched_rng, "Choice randomization does not consume global RNG")
		var visit = game.open_visit("visit_sora")
		var history_order := ids(visit.ui_actions())
		expect(history_order == ids(Encounter.new(definition, false).ui_actions()), "Non-diagnosis choices retain authored order")
		prepare(visit)
		var order: Array[String] = visit.diagnosis_action_order.duplicate()
		var snapshot: Dictionary = json_copy(game.snapshot())
		for redraw in range(3):
			app.show_encounter("visit_sora")
			expect(ui_ids() == order, "Actual UI uses saved order")
			app.toggle_clinic_record()
			expect(ui_ids() == order, "Record toggle does not reshuffle")
			expect(game.open_visit("visit_sora") == visit, "Re-entering keeps same visit")
		expect(game.restore(snapshot), "Game JSON restore")
		expect(game.open_visit("visit_sora").diagnosis_action_order == order, "Game restore and re-entry retain order")
		# Exercise actual UI callbacks for all six placements, with both existing
		# support contexts. Only order is forced; text and clinical data stay real.
		var canonical: Array[String] = visit.authored_diagnosis_action_ids()
		var captured_positions: Dictionary = {}
		for first in canonical:
			for second in canonical:
				if second == first:
					continue
				var forced: Array[String] = [first, second]
				for last in canonical:
					if last not in forced:
						forced.append(last)
				for personal_nurse in [false, true]:
					expect(game.restore(snapshot), "Restore branch fixture")
					game.personal_nurse_system_unlocked = personal_nurse
					game.probation_complete = personal_nurse
					game.meet_staff("nurse_haru")
					game.personal_nurse_id = "nurse_haru" if personal_nurse else ""
					var support_id := "nurse_haru" if personal_nurse else "doc_aoi"
					expect(game.resolve_outpatient_support_actor() == support_id, "Doctor and personal-nurse contexts are both exercised")
					visit = game.open_visit("visit_sora")
					visit.diagnosis_action_order = forced.duplicate()
					app.show_encounter("visit_sora")
					expect(ui_ids() == forced, "All permutations map to matching UI buttons")
					var correct_position := forced.find("diagnose_appendix")
					if OS.get_cmdline_user_args().has("--visual") and not captured_positions.has(correct_position):
						await process_frame
						await RenderingServer.frame_post_draw
						var path := "/private/tmp/hoshimi_diagnosis_%s_%s.png" % [locale, correct_position + 1]
						expect(root.get_texture().get_image().save_png(path) == OK, "Save diagnosis window screenshot")
						captured_positions[correct_position] = true
						print("VISUAL ", path)
					var wrong := "diagnose_gastro"
					var action: Dictionary = visit.find_action(wrong).duplicate(true)
					var before := int(game.elapsed())
					app.page.get_node("Action_" + wrong).pressed.emit()
					expect(visit.stage_id == "diagnosis" and visit.mistakes == 1, "Wrong answer retains correction flow")
					expect(visit.feedback == action.response and visit.speaker == action.speaker, "Correction wording and speaker context unchanged")
					var support_name: String = app.content.find_record("staff", support_id).name
					var speaker_visible := false
					for child in app.page.get_children():
						if child is Label and child.text == support_name:
							speaker_visible = true
					expect(speaker_visible, "Correction UI displays the correct support speaker")
					expect(game.elapsed() == before + int(action.minutes), "Wrong-answer time cost unchanged")
					var remaining := forced.duplicate()
					remaining.erase(wrong)
					expect(ui_ids() == remaining, "Wrong answer removal preserves relative order")
					var partial: Dictionary = json_copy(game.snapshot())
					expect(game.restore(partial), "Save after wrong answer restores")
					app.show_encounter("visit_sora")
					visit = game.visits.visit_sora
					expect(ui_ids() == remaining, "Partial choice list stable after load")
					var correct: Dictionary = visit.find_action("diagnose_appendix").duplicate(true)
					app.page.get_node("Action_diagnose_appendix").pressed.emit()
					expect(visit.stage_id == "plan" and visit.diagnosis == correct.diagnosis, "Correct answer uses ID, not button position")
					expect(visit.feedback == correct.response, "Correct-answer response unchanged")
		# Old saves have no order; repeated loading keeps the old authored order.
		var legacy: Dictionary = snapshot.duplicate(true)
		legacy.progress.visit_sora.erase("diagnosis_action_order")
		for _attempt in range(2):
			expect(game.restore(legacy), "Legacy state save without order accepted")
			expect(game.visits.visit_sora.diagnosis_action_order == canonical, "Legacy visit keeps original positions")
		var legacy_log: Dictionary = snapshot.duplicate(true)
		legacy_log.version = 35
		legacy_log.erase("save_format")
		legacy_log.progress.visit_sora = snapshot.progress.visit_sora.action_log.duplicate()
		expect(game.restore(legacy_log), "Legacy v35 action-log save accepted")
		expect(game.visits.visit_sora.diagnosis_action_order == canonical, "Legacy action-log order remains stable")
		for bad in [null, "bad", [], [canonical[0], canonical[0], canonical[2]], [canonical[0], canonical[1], "unknown"], [1, canonical[1], canonical[2]]]:
			var invalid: Dictionary = snapshot.duplicate(true)
			invalid.progress.visit_sora.diagnosis_action_order = bad
			var before := JSON.stringify(game.snapshot())
			expect(not game.restore(invalid), "Invalid permutation rejected")
			expect(JSON.stringify(game.snapshot()) == before, "Invalid save leaves live state intact")
		# Localized definitions can restore the same saved technical IDs.
		var other_locale := "en" if locale == "zh_CN" else "zh_CN"
		expect(app.content.load_all(other_locale), "Load other language")
		app.configure_game_content()
		expect(app.game.restore(snapshot), "Restore into translated content")
		app.show_encounter("visit_sora")
		expect(ui_ids() == order, "Language switch preserves displayed order")
		# Same patient template starts a fresh order when recycled, not a profile binding.
		game = app.game
		var recycled_orders: Dictionary = {}
		for _attempt in range(40):
			game.archive_and_reset_patient("patient_sora")
			var next_visit = game.open_visit("visit_sora")
			expect(next_visit != null, "Recycled patient can start a fresh visit")
			if next_visit != null:
				recycled_orders["|".join(next_visit.diagnosis_action_order)] = true
		expect(recycled_orders.size() > 1, "Recycled template does not inherit the previous order")
	print("DIAGNOSIS ORDER: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
