extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const Store = preload("res://godot/systems/save_store.gd")
var failures := 0
var checks := 0
const HISTORY = ["pain", "associated", "background", "to_exam"]
const EXAM = ["vitals", "request_full_undress", "authoritative_full_undress"]
const TESTS = ["blood", "imaging", "to_diagnosis"]

func patient_queue_with_sora_first(content: RefCounted) -> Array[String]:
	var result: Array[String] = ["patient_sora"]
	for patient in content.collections.patients:
		if str(patient.id) != "patient_sora":
			result.append(str(patient.id))
	return result

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func apply_all(visit: RefCounted, actions: Array) -> void:
	for action in actions:
		expect(visit.apply(action), "Could not apply " + action)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var content = Loader.new()
	expect(content.load_all(), "Content load failed")
	var randomized = GameState.new()
	randomized.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools)
	expect(randomized.patient_cases.size() == content.collections.patients.size(), "Random cases were not assigned to every patient")
	expect(randomized.examination_cg_by_test.get("cbc", "") == "blood_draw", "Blood test CG pool was not indexed")
	expect(randomized.examination_cg_by_test.get("abdominal_ct", "") == "ct_scan", "CT CG pool was not indexed")
	expect(randomized.examination_cg_by_surgery.get("surgery_hysterectomy", "") == "gynecology_preparation", "Surgery CG pool was not indexed")
	var miki_undress_pool: Dictionary = content.find_record("examination_cg_pools", "full_undress_basic_exam_patient_miki")
	expect(not miki_undress_pool.is_empty() and miki_undress_pool.paths.size() == 1, "Miki-specific full-undress examination CG pool was not loaded")
	var miki_encounter: Dictionary = content.find_record("encounters", "visit_miki")
	var mapped_miki_undress_actions := 0
	for stage in miki_encounter.get("stages", []):
		if stage.id != "exam_undress_decision":
			continue
		for action in stage.actions:
			if action.id in ["authoritative_full_undress", "gentle_full_undress", "threaten_full_undress"]:
				expect(action.get("visual_pool_id", "") == "full_undress_basic_exam_patient_miki", "Miki full-undress branch did not use the patient-specific CG pool: " + action.id)
				mapped_miki_undress_actions += 1
	expect(mapped_miki_undress_actions == 3, "Miki-specific full-undress CG was not mapped to all three completion branches")
	var expected_patient_ids: Array[String] = []
	for patient in content.collections.patients:
		expected_patient_ids.append(patient.id)
	var sorted_queue: Array[String] = randomized.patient_queue.duplicate()
	sorted_queue.sort()
	expected_patient_ids.sort()
	expect(sorted_queue == expected_patient_ids, "Random patient queue is not a complete permutation")
	expect(randomized.patient_cases.patient_sora != randomized.patient_cases.patient_emi, "Patients received the same case in one rotation")
	for patient in content.collections.patients:
		var assigned_case: Dictionary = randomized.patient_case(patient.id)
		var encounter_id := randomized.encounter_id_for_patient(patient.id)
		var preop_id := ""
		for candidate in content.collections.preops:
			if candidate.patient_id == patient.id:
				preop_id = candidate.id
				break
		expect(not preop_id.is_empty(), "Patient has no preop definition: " + patient.id)
		expect(not assigned_case.is_empty() and assigned_case.symptoms.size() >= 1 and assigned_case.symptoms.size() <= 5, "Assigned case has invalid symptoms")
		expect(randomized.definitions[encounter_id].title == assigned_case.title, "Encounter did not adopt random case title")
		expect(randomized.preop_definitions[preop_id].surgery_id == assigned_case.surgery_id, "Preop did not adopt random target surgery")
		var generated_stages := {}
		for stage in randomized.definitions[encounter_id].stages:
			generated_stages[stage.id] = stage
		expect(generated_stages.plan.prompt == patient.reaction_lines.hospitalization_question, "Hospitalization question ignored personality for " + patient.id)
		var hospitalization_response := ""
		for action in generated_stages.plan.actions:
			if action.id == "explain":
				hospitalization_response = action.response
		expect(hospitalization_response == patient.reaction_lines.hospitalization_response, "Hospitalization response ignored personality for " + patient.id)
	var voiced_assignments: Dictionary = randomized.patient_cases.duplicate(true)
	voiced_assignments.patient_miki = "template_nephrectomy"
	var voiced_visit: Dictionary = randomized.encounter_definitions_for(voiced_assignments).visit_miki
	var voiced_stages := {}
	for stage in voiced_visit.stages:
		voiced_stages[stage.id] = stage
	expect(voiced_stages.reception.prompt.contains("肾上长了个东西") and not voiced_stages.reception.prompt.contains("肾脏占位"), "Patient complaint still uses clinical record language")
	expect(voiced_stages.reception.prompt.begins_with("「不好意思，"), "Patient voice style was not applied")
	var associated_response := ""
	for action in voiced_stages.history.actions:
		if action.id == "associated":
			associated_response = action.response
	expect(associated_response.contains("我没有明显发烧") and not associated_response.contains("肉眼血尿"), "Associated symptom response still reads clinical symptom labels")
	var randomized_snapshot: Dictionary = randomized.snapshot()
	var randomized_clone = GameState.new()
	randomized_clone.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates)
	expect(randomized_clone.restore(JSON.parse_string(JSON.stringify(randomized_snapshot))), "Random case save could not restore")
	expect(randomized_clone.patient_cases == randomized.patient_cases and randomized_clone.patient_queue == randomized.patient_queue, "Random patient data changed after save/load")
	var invalid_cases: Dictionary = randomized_snapshot.duplicate(true)
	invalid_cases.patient_cases.patient_sora = "missing_template"
	expect(not randomized_clone.restore(invalid_cases) and randomized_clone.patient_cases == randomized.patient_cases, "Invalid random case assignment mutated progress")
	var invalid_queue: Dictionary = randomized_snapshot.duplicate(true)
	invalid_queue.patient_queue[1] = invalid_queue.patient_queue[0]
	expect(not randomized_clone.restore(invalid_queue) and randomized_clone.patient_queue == randomized.patient_queue, "Invalid patient queue mutated progress")
	var referral_game = GameState.new()
	referral_game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates)
	referral_game.patient_queue.assign(patient_queue_with_sora_first(content))
	referral_game.open_visit("visit_sora").apply("greet")
	expect(not referral_game.refer_current_patient("nurse_haru"), "Nurse accepted as referral doctor")
	expect(not referral_game.refer_current_patient("doc_rei"), "Unknown doctor accepted a referral")
	referral_game.meet_staff("doc_rei")
	expect(referral_game.refer_current_patient("doc_rei"), "Valid referral failed")
	expect(referral_game.referral_doctor("patient_sora") == "doc_rei" and referral_game.current_patient_id() != "patient_sora" and referral_game.recent_patient_ids == ["patient_sora"], "Referral did not randomly advance the patient queue")
	expect(referral_game.open_visit("visit_sora") == null, "Referred patient could be reopened")
	var referral_clone = GameState.new()
	referral_clone.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates)
	expect(referral_clone.restore(referral_game.snapshot()) and referral_clone.patient_referrals == referral_game.patient_referrals and referral_clone.recent_patient_ids == referral_game.recent_patient_ids, "Referral rotation did not survive save/load")
	var cycling = GameState.new()
	cycling.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates)
	cycling.patient_queue.assign(patient_queue_with_sora_first(content))
	cycling.meet_staff("doc_rei")
	var appearance_history: Array[String] = []
	var first_cases: Dictionary = cycling.patient_cases.duplicate(true)
	var repeated_patient := ""
	for i in range(content.collections.patients.size() + 1):
		var patient_id := cycling.current_patient_id()
		expect(not patient_id.is_empty(), "Continuous patient rotation ran dry")
		if appearance_history.size() >= 2:
			expect(patient_id != appearance_history[-1] and patient_id != appearance_history[-2], "Patient repeated within the previous two appearances")
		if appearance_history.has(patient_id) and repeated_patient.is_empty():
			repeated_patient = patient_id
			expect(cycling.patient_cases[patient_id] != first_cases[patient_id], "Returning patient kept the previous case")
		appearance_history.append(patient_id)
		expect(cycling.refer_current_patient("doc_rei"), "Continuous patient rotation could not advance")
	expect(not repeated_patient.is_empty() and cycling.recent_patient_ids.size() == 2, "Patient rotation did not recycle the limited cast")
	var cycling_clone = GameState.new()
	cycling_clone.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates)
	expect(cycling_clone.restore(cycling.snapshot()) and cycling_clone.current_patient_id() == cycling.current_patient_id() and cycling_clone.recent_patient_ids == cycling.recent_patient_ids, "Continuous patient rotation changed after save/load")
	var game = GameState.new()
	game.configure(content.collections.encounters)
	var end_of_day: Dictionary = game.schedule_at(479)
	var next_day: Dictionary = game.schedule_at(480)
	expect(end_of_day.day == 1 and end_of_day.absolute_clock == 16 * 60 + 59 and end_of_day.remaining == 1, "End-of-shift schedule wrong")
	expect(next_day.day == 2 and next_day.absolute_clock == 9 * 60 and next_day.remaining == 480, "Eight-hour rollover wrong")
	var timeline = GameState.new()
	timeline.configure(content.collections.encounters, [], [], content.collections.time_events)
	expect(not timeline.spend_time("missing"), "Unknown time event accepted")
	expect(timeline.spend_time("director_office_check"), "One-time location event failed")
	expect(not timeline.spend_time("director_office_check"), "One-time location event repeated")
	expect(timeline.spend_time("rooftop_pause") and timeline.spend_time("rooftop_pause"), "Repeatable location event failed")
	expect(timeline.elapsed() == 25 and timeline.clock_text() == "09:25", "Location time did not reach schedule")
	var history: Array = timeline.time_history()
	expect(history.size() == 3 and history[0].clock == "09:00" and history[1].clock == "09:05" and history[2].clock == "09:15" and not history[0].response.is_empty(), "Time-event history timestamps or dialogue wrong")
	var timeline_clone = GameState.new()
	timeline_clone.configure(content.collections.encounters, [], [], content.collections.time_events)
	expect(timeline_clone.restore(timeline.snapshot()) and timeline_clone.time_history() == history, "Time-event save replay failed")
	var legacy_v2: Dictionary = timeline.snapshot()
	legacy_v2.version = 2
	legacy_v2.erase("time_log")
	expect(not timeline_clone.restore(legacy_v2), "Retired v2 save was accepted")
	var invalid_timeline: Dictionary = timeline.snapshot()
	invalid_timeline.time_log[1].start = 999
	expect(not timeline_clone.restore(invalid_timeline), "Impossible time-event timestamp accepted")
	var chat_timeline = GameState.new()
	chat_timeline.configure(content.collections.encounters, [], content.collections.staff, content.collections.time_events, [], [], content.collections.relationships, content.collections.character_events)
	for staff_id in ["doc_aoi", "doc_rei", "nurse_haru", "nurse_rin", "nurse_yui"]:
		chat_timeline.meet_staff(staff_id)
	var available_staff_chat := ""
	for location_id in ["clinic", "exam", "station", "ward", "or", "lounge", "rooftop"]:
		for event_definition in chat_timeline.time_events_at(location_id):
			if event_definition.get("actor_id") != null:
				available_staff_chat = str(event_definition.id)
				break
		if not available_staff_chat.is_empty():
			break
	expect(not available_staff_chat.is_empty(), "No known staff chat was scheduled at shift start")
	expect(not available_staff_chat.is_empty() and chat_timeline.spend_time(available_staff_chat) and chat_timeline.elapsed() == 30, "Known staff chat did not spend 30 minutes")
	expect(not chat_timeline.last_time_event_response.is_empty(), "Random chat response missing")
	var overtime = GameState.new()
	overtime.configure(content.collections.encounters, [], content.collections.staff, content.collections.time_events, [], [], content.collections.relationships, content.collections.character_events)
	overtime.meet_staff("doc_aoi")
	for i in range(15):
		overtime.spend_time("rooftop_pause")
	var surgery_start := overtime.elapsed()
	for i in range(48):
		overtime.spend_time("rooftop_pause")
	expect(overtime.settle_overtime(surgery_start, 480), "Overtime surgery did not end the day")
	expect(overtime.elapsed() == 480 and overtime.day_number() == 2 and overtime.clock_text() == "09:00", "Surgery overtime consumed the next day")
	var overtime_clone = GameState.new()
	overtime_clone.configure(content.collections.encounters, [], content.collections.staff, content.collections.time_events, [], [], content.collections.relationships, content.collections.character_events)
	expect(overtime_clone.restore(overtime.snapshot()) and overtime_clone.elapsed() == 480, "Overtime adjustment did not survive save replay")
	var visit = game.open_visit("visit_sora")
	expect(not visit.apply("admit"), "Admission allowed before intake")
	expect(visit.notes.is_empty(), "Uncollected findings leaked")
	apply_all(visit, ["greet"])
	expect(not visit.apply("to_exam"), "History gate bypassed")
	apply_all(visit, ["pain"])
	var time: int = visit.minutes
	expect(not visit.apply("pain") and visit.minutes == time, "Duplicate action changed time")
	expect(visit.notes.size() == 1, "Duplicate action duplicated record")
	apply_all(visit, ["associated", "background", "to_exam"])
	expect(not visit.apply("authoritative_full_undress"), "Undress response was available before the patient protested")
	apply_all(visit, EXAM)
	expect(visit.player_effects == {"charm": 0, "presence": 0, "reputation": 0} and visit.notes.has("exam_authoritative"), "Authoritative persuasion changed a canonical attribute without an authored effect")
	expect(not visit.apply("to_diagnosis"), "Tests gate bypassed")
	apply_all(visit, ["blood"])
	var snapshot: Dictionary = game.snapshot()
	var clone = GameState.new()
	clone.configure(content.collections.encounters)
	expect(clone.restore(snapshot), "Mid-case snapshot did not restore")
	var restored = clone.visits["visit_sora"]
	expect(restored.stage_id == "tests" and restored.notes.has("blood") and not restored.notes.has("imaging"), "Wrong mid-case evidence")
	expect(restored.minutes == visit.minutes and restored.feedback == visit.feedback, "Mid-case feedback/time lost")
	var legacy_exam: Dictionary = snapshot.duplicate(true)
	legacy_exam.version = 16
	legacy_exam.progress.visit_sora = ["greet", "pain", "associated", "background", "to_exam", "vitals", "abdomen", "to_tests", "blood"]
	expect(not clone.restore(legacy_exam), "Retired v16 save was accepted")
	expect(clone.restore(snapshot), "Current mid-case snapshot could not be restored after migration check")
	var invalid: Dictionary = snapshot.duplicate(true)
	invalid.version = 999
	expect(not clone.restore(invalid), "Future save version accepted")
	expect(clone.snapshot() == snapshot, "Failed load mutated progress")
	invalid = snapshot.duplicate(true)
	invalid.progress.visit_sora.append("admit")
	expect(not clone.restore(invalid), "Out-of-order action accepted")
	expect(clone.snapshot() == snapshot, "Partial replay mutated live state")
	invalid = snapshot.duplicate(true)
	invalid.progress.visit_sora.append("blood")
	expect(not clone.restore(invalid), "Duplicate saved event accepted")
	invalid = snapshot.duplicate(true)
	invalid.active_id = "missing"
	expect(not clone.restore(invalid), "Unknown active case accepted")
	apply_all(visit, ["imaging", "to_diagnosis", "diagnose_gastro"])
	expect(visit.stage_id == "diagnosis" and visit.mistakes == 1 and visit.diagnosis.is_empty(), "Wrong diagnosis progressed case")
	apply_all(visit, ["diagnose_appendix"])
	expect(not visit.apply("admit"), "Admission allowed before explanation")
	apply_all(visit, ["explain", "admit"])
	expect(visit.completed() and visit.admitted, "Case did not complete admission")
	expect(game.admitted_patient("patient_sora"), "Ward status not updated")
	expect(not game.admitted_patient("patient_emi"), "Other patient admitted by mistake")
	expect(not visit.apply("admit"), "Duplicate admission accepted")
	expect(clone.restore(game.snapshot()) and clone.visits.visit_sora.admitted, "Completed admission did not restore")
	var refusal_game = GameState.new()
	refusal_game.configure(content.collections.encounters)
	var refusal = refusal_game.open_visit("visit_emi")
	apply_all(refusal, ["greet"] + HISTORY + ["vitals", "request_full_undress", "abandon_full_undress"])
	expect(refusal.stage_id == "tests" and refusal.notes.exam_abandoned.text.contains("未完成"), "Respecting refusal did not preserve a usable incomplete-exam record")
	expect(refusal.player_effects == {"charm": 0, "presence": 0, "reputation": 0}, "Respecting refusal changed a retired attribute")
	var limited_game = GameState.new()
	limited_game.configure(content.collections.encounters)
	var limited = limited_game.open_visit("visit_emi")
	apply_all(limited, ["greet"] + HISTORY + ["vitals", "limited_clothed_exam"])
	expect(limited.stage_id == "tests" and limited.notes.exam_limited.text.contains("未取得针对性查体发现"), "Limited clothed exam did not preserve the no-undress medical result")
	expect(not limited.action_log.has("request_full_undress") and not limited.action_log.has("authoritative_full_undress") and limited.player_effects == {"charm": 0, "presence": 0, "reputation": 0}, "Limited clothed exam triggered a full-undress branch or player effect")
	var coercion_game = GameState.new()
	coercion_game.configure(content.collections.encounters)
	var coerced = coercion_game.open_visit("visit_ann")
	apply_all(coerced, ["greet"] + HISTORY + ["vitals", "request_full_undress", "threaten_full_undress"])
	expect(coerced.player_effects.presence == 1, "Threat branch did not record its phase-bounded presence effect")
	expect(coercion_game.player_attributes().presence == 1, "Clinic presence effect was omitted from player attributes")
	var baseline = GameState.new()
	baseline.configure(content.collections.encounters)
	var quick = baseline.open_visit("visit_sora")
	apply_all(quick, ["greet"] + HISTORY + EXAM + TESTS + ["diagnose_appendix", "explain", "admit"])
	expect(quick.minutes == 76 and baseline.day_text() == "DAY 01" and baseline.clock_text() == "10:16" and baseline.shift_remaining() == 404, "Baseline timeline incorrect: minutes=%s clock=%s remaining=%s" % [quick.minutes, baseline.clock_text(), baseline.shift_remaining()])
	var optional = GameState.new()
	optional.configure(content.collections.encounters)
	var slow = optional.open_visit("visit_sora")
	apply_all(slow, ["comfort"] + HISTORY + EXAM + ["extra"] + TESTS + ["diagnose_observe", "diagnose_appendix", "explain", "admit"])
	expect(slow.minutes == 94 and slow.notes.has("concern") and slow.notes.has("extra"), "Optional path effects lost: minutes=%s concern=%s extra=%s" % [slow.minutes, slow.notes.has("concern"), slow.notes.has("extra")])
	# Old partial v1 saves continue through bundled controls without double-counting.
	var legacy = GameState.new()
	legacy.configure(content.collections.encounters)
	var partial = legacy.open_visit("visit_sora")
	apply_all(partial, ["greet", "pain"])
	expect(clone.restore(legacy.snapshot()), "Old partial history snapshot rejected")
	var merged = clone.visits.visit_sora
	expect(merged.apply("basic_history"), "Partial history bundle failed")
	expect(merged.minutes == 11 and merged.notes.size() == 3, "Bundle duplicated time or notes")
	expect(not merged.apply("basic_history"), "Repeated bundle accepted")
	expect(not merged.apply("basic_exam"), "Cross-stage bundle accepted")
	var displayed: Dictionary = merged.presentation()
	expect(legacy.restore(clone.snapshot()), "Bundled save round-trip failed")
	expect(legacy.visits.visit_sora.presentation() == displayed, "Bundle dialogue changed on load")
	expect(legacy.visits.visit_sora.action_log == ["greet", "pain", "associated", "background"], "Save format changed")
	var args := OS.get_cmdline_user_args()
	if args.size() == 1:
		var store = Store.new()
		store.path = args[0]
		expect(store.write_slot(game), "First save failed")
		expect(store.write_slot(optional), "Atomic replacement failed")
		expect(store.read_slot(clone) and clone.elapsed() == 94, "File round-trip failed")
		var before: Dictionary = clone.snapshot()
		var broken := FileAccess.open(store.path, FileAccess.WRITE)
		broken.store_string("{broken JSON")
		broken.close()
		expect(not store.read_slot(clone) and clone.snapshot() == before, "Corrupt save mutated game")
		store.path += ".missing"
		expect(not store.read_slot(clone), "Missing file accepted")
		store.path += "/slot.json"
		expect(not store.write_slot(clone), "Invalid save directory accepted")
	else:
		push_error("Pass an isolated scratch save path after -- to test file I/O")
		failures += 1
	# UI uses the same state engine: exercise actual button signal callbacks.
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.game.patient_queue.assign(patient_queue_with_sora_first(content))
	app.game.meet_staff("doc_rei")
	app.show_location("clinic")
	var staff_toggle: Button = app.page.get_node_or_null("LocationStaffToggle")
	expect(staff_toggle != null and app.page.get_node_or_null("LocationStaffDrawer") == null, "Clinic staff drawer should start collapsed")
	var patient_portrait_before: Button = app.page.get_node_or_null("PatientPortrait")
	var patient_y_before := patient_portrait_before.position.y if patient_portrait_before != null else -1.0
	if staff_toggle != null:
		staff_toggle.pressed.emit()
		var drawer: Panel = app.page.get_node_or_null("LocationStaffDrawer")
		expect(drawer != null and drawer.get_node_or_null("LocationStaffScroll/LocationStaffList") != null, "Clinic staff drawer did not open as a scrollable list")
		var expanded_patient_portrait: Button = app.page.get_node_or_null("PatientPortrait")
		expect(expanded_patient_portrait != null and expanded_patient_portrait.position.y == patient_y_before, "Opening the staff drawer displaced patient controls")
		app.page.get_node("LocationStaffToggle").pressed.emit()
		expect(app.page.get_node_or_null("LocationStaffDrawer") == null and app.page.get_node_or_null("PatientPortrait") != null, "Clinic staff drawer did not collapse cleanly")
	var refer_button = app.page.get_node_or_null("ReferPatient")
	expect(refer_button != null, "Clinic referral button missing")
	if refer_button != null:
		refer_button.pressed.emit()
		var referral_picker := app.page.get_node_or_null("ReferralDoctorPicker") as OptionButton
		var referral_confirm := app.page.get_node_or_null("ReferralConfirm") as Button
		expect(app.screen == "referral" and referral_picker != null and referral_confirm != null, "Referral doctor dropdown did not open")
		if referral_picker != null and referral_confirm != null:
			expect(referral_picker.item_count == 2 and str(referral_picker.get_item_metadata(1)) == "doc_rei", "Referral dropdown included an unknown doctor or omitted the known doctor")
			expect(referral_confirm.disabled, "Referral confirmation started enabled without a doctor selection")
			referral_picker.select(1)
			referral_picker.item_selected.emit(1)
			expect(not referral_confirm.disabled, "Referral confirmation did not enable after selecting a doctor")
			referral_confirm.pressed.emit()
		expect(app.game.referral_doctor("patient_sora") == "doc_rei" and app.game.current_patient_id() != "patient_sora" and app.game.recent_patient_ids == ["patient_sora"], "Referral UI did not advance to an eligible patient")
	app.game.reset()
	app.game.patient_queue.assign(patient_queue_with_sora_first(content))
	app.show_encounter("visit_sora")
	expect(app.page.get_node_or_null("MedicalRecord") == null, "Record should start collapsed")
	for id in ["greet", "basic_history", "to_exam", "vitals", "request_full_undress", "gentle_full_undress"] + TESTS + ["diagnose_appendix", "explain", "admit"]:
		var clicked := false
		for node in app.page.get_children():
			if node is Button and node.name == "Action_" + id:
				expect(not node.disabled, "UI incorrectly disabled " + id)
				node.pressed.emit()
				clicked = true
				break
		expect(clicked, "Action button missing: " + id)
		await process_frame
		if app.screen == "examination_cg":
			var cg_continue: Button = app.page.get_node_or_null("ExaminationCGContinue")
			expect(cg_continue != null, "Triggered examination CG has no continue button")
			if cg_continue != null:
				cg_continue.pressed.emit()
				await process_frame
		if id == "to_diagnosis":
			expect(app.page.get_node_or_null("MedicalRecord") != null, "Diagnosis should auto-open record")
		if id == "basic_history":
			expect(app.page.get_node_or_null("MedicalRecord") == null, "History record should remain collapsed")
			expect(app.page.get_node("ToggleRecord").text.contains("3"), "Unread record count missing")
			app.page.get_node("ToggleRecord").pressed.emit()
			expect(app.page.get_node_or_null("MedicalRecord") != null, "Record did not open")
			app.page.get_node("ToggleRecord").pressed.emit()
			expect(app.page.get_node_or_null("MedicalRecord") == null, "Record did not close")
			expect(app.page.get_node("ToggleRecord").text == "查看病历", "Seen count not cleared")
		if id == "gentle_full_undress":
			var exam_portrait: TextureRect = app.page.get_node_or_null("CharacterPortrait")
			expect(exam_portrait != null and exam_portrait.texture.resource_path.contains("examination_portraits_v1/patient_sora/shy.png"), "Completed undressed exam did not switch to the shy examination portrait")
		if id == "diagnose_appendix":
			expect(app.page.get_node_or_null("MedicalRecord") == null, "Record did not collapse after diagnosis")
	expect(app.game.admitted_patient("patient_sora"), "UI flow did not admit patient")
	app.show_location("ward")
	var has_patient := false
	for node in app.page.get_children():
		if node is Button and node.text.contains(content.find_record("patients", "patient_sora").name):
			has_patient = true
	expect(has_patient, "Ward UI omitted admitted patient")
	app.show_location("rooftop")
	var rooftop_event = app.page.get_node_or_null("TimeEvent_rooftop_pause")
	expect(rooftop_event != null, "Rooftop time action missing")
	if rooftop_event != null:
		var before_time: int = app.game.elapsed()
		rooftop_event.pressed.emit()
		expect(app.game.elapsed() == before_time + 10 and app.game.time_log.size() == 1, "Rooftop action did not log time")
		expect(app.page.get_node_or_null("TimeEvent_rooftop_pause") != null, "Repeatable rooftop action disappeared")
	app.show_location("surgery_director_office")
	var office_event = app.page.get_node_or_null("TimeEvent_director_office_check")
	expect(office_event != null, "Office time action missing")
	if office_event != null:
		office_event.pressed.emit()
		expect(app.page.get_node_or_null("TimeEvent_director_office_check") == null, "One-time office action remained available")
	app.show_time_log()
	expect(app.page.get_node_or_null("TimeLogEntry_0") != null and app.page.get_node_or_null("TimeLogEntry_1") != null, "Visible time history omitted location actions")
	for staff_id in ["doc_aoi", "doc_rei", "nurse_haru", "nurse_rin", "nurse_yui"]:
		app.game.meet_staff(staff_id)
	for staff_id in ["doc_aoi", "doc_rei", "nurse_haru", "nurse_rin", "nurse_yui"]:
		expect(app.game.time_event_definitions.has("lounge_chat_" + staff_id), "Isolated lounge chat definition missing for " + staff_id)
	app.show_day_transition(app.show_map)
	expect(app.screen == "day_transition" and app.page.get_node_or_null("SceneBackground") != null, "Day transition did not show night background")
	var continue_button: Button = null
	for node in app.page.get_children():
		if node is Button and node.text.contains("进入下一天"):
			continue_button = node
	expect(continue_button != null, "Day transition continue button missing")
	if continue_button != null:
		continue_button.pressed.emit()
		expect(app.screen == "map", "Day transition did not continue")
	app.show_examination_cg("blood_draw", app.show_map)
	expect(app.screen == "examination_cg", "Examination CG screen did not open")
	var examination_cg: TextureRect = app.page.get_node_or_null("ExaminationCG")
	expect(examination_cg != null and examination_cg.texture != null, "Examination CG texture did not load")
	var examination_continue: Button = app.page.get_node_or_null("ExaminationCGContinue")
	expect(examination_continue != null, "Examination CG continue button missing")
	if examination_continue != null:
		examination_continue.pressed.emit()
		expect(app.screen == "map", "Examination CG did not continue to its destination")
	app.game.reset()
	expect(app.game.elapsed() == 0 and app.game.time_log.is_empty() and not app.game.admitted_patient("patient_sora"), "New-game reset incomplete")
	await process_frame
	print("CLINIC: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
