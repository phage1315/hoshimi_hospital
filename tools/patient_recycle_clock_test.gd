extends SceneTree

const Preop = preload("res://godot/systems/preop_session.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func stamp(app, label: String) -> void:
	print(label, " elapsed=", app.game.elapsed(), " ledger=", app.game.schedule_at(app.game.elapsed()), " visible=", app.game.display_schedule(), " pending=", app.game.pending_departure_context())

func force_next_candidate(game, patient_id: String) -> void:
	var recent: Array = game.recent_patient_ids.duplicate()
	var current: String = game.current_patient_id()
	recent.erase(current)
	recent.append(current)
	while recent.size() > 2:
		recent.pop_front()
	var candidates: Array = []
	for patient in game.patient_definitions:
		if not recent.has(patient.id):
			candidates.append(patient.id)
	check(candidates.has(patient_id), "Controlled next patient is eligible")
	for rng_seed in range(1, 10000):
		seed(rng_seed)
		if candidates[randi_range(0, candidates.size() - 1)] == patient_id:
			seed(rng_seed)
			return
	check(false, "Could not seed next patient")

func test_case_lifecycle(app) -> void:
	var game = app.game
	game.reset()
	var visit = game.open_visit("visit_sora")
	visit.minutes = 92
	visit.player_effects.reputation = 3
	visit.player_effect_history.append({"id": "test_visit", "label": "test", "effects": {"reputation": 3}})
	var prep = Preop.new(game.preop_definitions.preop_sora, app.content.collections.staff, app.content.collections.surgeries, app.content.collections.patients)
	prep.minutes = 257
	prep.player_effects.presence = 2
	prep.player_effect_history.append({"id": "test_preop", "label": "test", "effects": {"presence": 2}})
	game.preops.preop_sora = prep
	game.active_id = ""
	game.discarded_overtime_minutes = 29
	game.surgery_xp = 123
	game.completed_surgeries_total = 2
	game.completed_surgeries_by_procedure.surgery_appendix = 2
	var before: int = game.elapsed()
	var attributes: Dictionary = game.player_attributes()
	var history: Array = game.player_attribute_history()
	var original_pool: Dictionary = game.case_templates.duplicate(true)
	# Full-pool seeded selection must match weighted_case_pick, including the previous disease.
	var pool: Array = game.case_templates.keys().filter(func(id): return game.case_template_available(str(id)))
	seed(1234)
	var expected: String = game.weighted_case_pick(pool)
	game.patient_cases.patient_sora = expected
	seed(1234)
	game.archive_and_reset_patient("patient_sora")
	check(game.patient_cases.patient_sora == expected, "The previous disease remains eligible in a multi-disease pool")
	check(game.elapsed() == before and game.archived_clinical_minutes == 349, "Archive raw minutes once, retaining overtime subtraction")
	check(game.player_attributes() == attributes and game.player_attribute_history() == history, "Archive preserves rewards and history without duplication")
	check(game.surgery_xp == 123 and game.completed_surgeries_total == 2 and game.completed_surgeries_by_procedure.surgery_appendix == 2, "Recycle preserves player XP and procedure progression")
	game.archive_and_reset_patient("patient_sora")
	check(game.elapsed() == before and game.archived_clinical_minutes == 349, "Repeated reset does not double-count archived time")
	check(game.player_attribute_history() == history and game.player_attributes() == attributes, "Repeated reset does not duplicate rewards")
	game.case_templates = {expected: original_pool[expected]}
	game.archive_and_reset_patient("patient_sora")
	check(game.patient_cases.patient_sora == expected, "Single disease pool does not become empty")
	game.case_templates = original_pool
	var saved: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
	check(game.restore(saved), "Archived minutes restore from JSON")
	check(game.elapsed() == before and game.archived_clinical_minutes == 349, "Restored clock retains archived clinical time and overtime")
	check(game.player_attributes() == attributes, "Restored archive preserves attributes: " + str(game.player_attributes()) + " expected " + str(attributes))
	check(game.player_attribute_history() == JSON.parse_string(JSON.stringify(history)), "Restored archive preserves history across JSON numeric types")
	check(game.surgery_xp == 123, "Restored archive preserves XP")
	for invalid in [-1, 1.5, "349", null, true, INF, NAN, 2147483648]:
		var bad: Dictionary = saved.duplicate(true)
		bad.archived_clinical_minutes = invalid
		check(not game.restore(bad), "Invalid archived minute value must be rejected: " + str(invalid))
		check(game.elapsed() == before, "Failed restore must not mutate time")
	game.reset()
	check(game.archived_clinical_minutes == 0, "New game clears archived time")
	game.advance_story_to_day(7, 600)
	var old_save: Dictionary = game.snapshot()
	old_save.erase("archived_clinical_minutes")
	before = game.elapsed()
	check(game.restore(old_save) and game.elapsed() == before and game.archived_clinical_minutes == 0, "Existing v36 saves without archive field remain compatible")
	old_save.version = 35
	old_save.erase("save_format")
	check(not game.restore(old_save) and game.elapsed() == before, "Unverifiable legacy log format is rejected without replay or time mutation")
	game.reset()
	game.patient_cases.patient_sora = "template_breast_tumor"
	game.rebuild_patient_content(game.patient_cases)
	visit = game.open_visit("visit_sora")
	for action in ["greet", "pain", "associated", "background", "to_exam", "vitals", "request_full_undress", "authoritative_full_undress", "blood", "imaging", "to_diagnosis", "diagnose_appendix"]:
		check(visit.apply(action), "Prepare first diagnosis: " + action)
	check(game.apply_clinic_action("explain"), "First case plays diagnosis reaction")
	var first_text: String = visit.presentation().text
	check(not game.apply_clinic_action("explain"), "Same-case reaction cannot be repeated")
	before = game.elapsed()
	check(game.snapshot().is_empty(), "Diagnosis dialogue cannot enter a persistent save")
	check(game.restore_runtime_snapshot(game.runtime_snapshot()), "Current diagnosis response survives memory-only locale change")
	check(game.visits.visit_sora.presentation().text == first_text, "Same-case reload preserves exact dialogue")
	game.meet_staff("doc_asuka")
	game.patient_queue.erase("patient_sora")
	game.patient_queue.push_front("patient_sora")
	force_next_candidate(game, "patient_gigi")
	check(game.refer_current_patient("doc_asuka"), "Referral after diagnosis succeeds")
	game.archive_and_reset_patient("patient_sora")
	check(game.elapsed() == before and not game.first_surgery_diagnosis_shock_state.has("patient_sora"), "Fresh case resets diagnosis flag without losing time")
	game.patient_cases.patient_sora = "template_breast_tumor"
	game.rebuild_patient_content(game.patient_cases)
	visit = game.open_visit("visit_sora")
	check(visit.minutes == 0 and visit.notes.is_empty() and visit.action_log.is_empty(), "Fresh case inherits no clinical progress")
	for action in ["greet", "pain", "associated", "background", "to_exam", "vitals", "request_full_undress", "authoritative_full_undress", "blood", "imaging", "to_diagnosis", "diagnose_appendix"]:
		check(visit.apply(action), "Prepare repeated-template diagnosis: " + action)
	check(game.apply_clinic_action("explain") and visit.presentation().text == first_text, "Fresh case of the same disease plays authored reaction again")
	var repeated_minutes: int = visit.minutes
	game.active_id = ""
	game.archive_and_reset_patient("patient_sora")
	check(game.archived_clinical_minutes == before + repeated_minutes and game.elapsed() == before + repeated_minutes, "Successive cases accumulate minutes exactly once")
	# An admitted patient spanning days is the SAME unfinished case, not a recycled template.
	game.reset()
	visit = game.open_visit("visit_sora")
	visit.admitted = true
	visit.stage_id = str(visit.definition.completion)
	visit.minutes = 92
	visit.notes["test_case_note"] = "same admission"
	var variant: String = str(visit.definition.get("first_surgery_diagnosis_shock_variant_id", "diagnosis_generic_real_01"))
	game.first_surgery_diagnosis_shock_state.patient_sora = {"first_surgery_diagnosis_shock_seen": true, "first_surgery_diagnosis_shock_variant_id": variant}
	prep = Preop.new(game.preop_definitions.preop_sora, app.content.collections.staff, app.content.collections.surgeries, app.content.collections.patients)
	prep.minutes = 17
	game.preops.preop_sora = prep
	game.active_id = ""
	var case_id: String = game.patient_cases.patient_sora
	game.advance_story_to_day(7, 540)
	game.meet_staff("doc_asuka")
	game.patient_queue.erase("patient_emi")
	game.patient_queue.push_front("patient_emi")
	force_next_candidate(game, "patient_sora")
	before = game.elapsed()
	check(game.refer_current_patient("doc_asuka"), "Another patient's referral succeeds")
	check(game.current_patient_id() == "patient_sora", "Controlled selection returns unfinished inpatient")
	check(game.visits.visit_sora == visit and game.preops.preop_sora == prep and game.patient_cases.patient_sora == case_id, "Selection keeps unfinished visit, preparation and disease")
	check(game.elapsed() == before and game.archived_clinical_minutes == 0, "Unfinished case must not be archived")
	check(game.first_surgery_diagnosis_shock_state.has("patient_sora"), "Same unfinished case keeps its diagnosis seen flag")
	check(game.restore(JSON.parse_string(JSON.stringify(game.snapshot()))), "Overnight admission restores")
	check(game.admitted_patient("patient_sora") and game.visits.visit_sora.notes.get("test_case_note") == "same admission", "Overnight admission retains notes")
	check(game.preops.preop_sora.minutes == 17 and game.patient_cases.patient_sora == case_id and game.elapsed() == before, "Overnight preparation and time remain intact")
	check(not game.first_surgery_diagnosis_shock_state.has("patient_sora") and game.visits.visit_sora.completed(), "Overnight admission resumes after diagnosis without retaining its performance state")
	check(not game.refer_current_patient("doc_asuka"), "Admitted case cannot be referred via outpatient exit")
	game.reset()
	for id in game.case_templates:
		var flag: String = game.procedure_unlock_requirement_flag(str(game.case_templates[id].surgery_id))
		if not flag.is_empty():
			check(not game.case_template_available(id), "Teaching-gated disease remains locked")
			game.set_story_flag(flag, true)
			check(game.case_template_available(id), "Existing teaching unlock still opens disease")
			game.set_story_flag(flag, false)
	game.reset()
	game.meet_staff("doc_asuka")
	seed(617)
	var appearances: Array[String] = []
	var recycled := false
	for index in range(game.patient_definitions.size() + 1):
		var patient_id: String = game.current_patient_id()
		check(not patient_id.is_empty(), "Repeated referrals must not exhaust the patient pool")
		if appearances.size() >= 2:
			check(patient_id != appearances[-1] and patient_id != appearances[-2], "Recent-two-template anti-repeat is unchanged")
		if appearances.has(patient_id):
			recycled = true
			check(game.case_template_available(str(game.patient_cases[patient_id])) and not game.patient_referrals.has(patient_id), "Recycled case uses available disease and clears referral")
		appearances.append(patient_id)
		check(game.refer_current_patient("doc_asuka"), "Continuous referral accepts next case")
	check(recycled, "Continuous referrals exercise template recycling")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		check(app.content.load_all(locale), "Content loads")
		app.configure_game_content()
		test_case_lifecycle(app)
		for old_minutes in [0, 349]:
			app.game.reset()
			app.game.meet_staff("doc_sayaka")
			app.game.meet_staff("doc_asuka")
			app.game.advance_story_to_day(2, 540)
			var phone = app.game.start_character_event("sayaka_week1_phone_exchange")
			check(phone != null, "Phone prerequisite starts")
			if phone == null:
				continue
			while not phone.completed:
				check(app.game.choose_character_event(str(phone.current().choices[0].id)), "Phone choice accepted")
			app.game.finish_character_event()
			# A completed old patient is an explicit fixture, not the user's save.
			var old_visit = app.game.open_visit("visit_sora")
			old_visit.admitted = true
			old_visit.stage_id = str(old_visit.definition.completion)
			old_visit.minutes = mini(92, old_minutes)
			var definition: Dictionary = app.game.preop_definitions["preop_sora"]
			var old_prep = Preop.new(definition, app.content.collections.staff, app.content.collections.surgeries, app.content.collections.patients)
			old_prep.surgery_success = true
			old_prep.minutes = old_minutes - old_visit.minutes
			app.game.preops["preop_sora"] = old_prep
			app.game.active_id = ""
			app.game.advance_story_to_day(6, 540)
			stamp(app, locale + "/old=" + str(old_minutes) + "/Sunday before date")
			app.start_sunday_character_event("sayaka_lv1_first_date")
			var event = app.game.character_events.get("sayaka_lv1_first_date")
			check(event != null, "First date starts via UI")
			if event == null:
				continue
			for step in range(event.definition.nodes.size() + 1):
				if event.completed:
					break
				var choice: String = "date_direct" if event.node_id == "v2_497" else str(event.current().choices[0].id)
				app.choose_character_event(choice)
			check(event.completed, "Date completed")
			check(app.game.day_number() == 6 and app.game.current_absolute_clock() == 660, "Date itself charges 120 minutes on Sunday")
			app.finish_sunday_character_event("doc_sayaka", "restaurant_bar")
			check(app.game.day_number() == 7 and app.game.current_absolute_clock() == 540, "Sunday completion advances to Monday 09:00")
			check(app.game.sunday_history.size() == 1 and int(app.game.sunday_history[0].day) == 6, "Sunday consumption recorded once")
			stamp(app, "After Sunday completion")
			app.show_map(false)
			app.game.patient_queue.erase("patient_emi")
			app.game.patient_queue.push_front("patient_emi")
			force_next_candidate(app.game, "patient_gigi")
			app.complete_referral("patient_emi", "doc_asuka")
			check(app.game.current_patient_id() == "patient_gigi", "First referral picked fresh patient")
			check(app.game.day_number() == 7, "Fresh-patient referral kept Monday")
			stamp(app, "After first referral")
			for child in app.get_children():
				if child is AcceptDialog:
					child.hide()
					child.queue_free()
			var before: int = app.game.elapsed()
			force_next_candidate(app.game, "patient_sora")
			app.complete_referral("patient_gigi", "doc_asuka")
			check(app.game.current_patient_id() == "patient_sora", "Second referral reselected archived patient")
			check(app.game.elapsed() == before, "Recycling must preserve all elapsed clinical minutes")
			check(not app.game.visits.has("visit_sora") and not app.game.preops.has("preop_sora"), "Old clinical sessions removed")
			check(app.game.day_number() == 7 and app.game.current_absolute_clock() == 540, "Second referral must remain Monday 09:00")
			check(str(app.page.get_node("CalendarHeader").text).contains("2025.04.07"), "Visible calendar must remain Monday")
			stamp(app, "After second referral")
			print("VISIBLE HEADER: ", app.page.get_node("CalendarHeader").text)
			# Clinic entry can start the Monday callback. It must finish before a
			# persistent save; the clock assertions above still cover both referrals.
			if app.game.character_event_in_progress():
				check(app.game.snapshot().is_empty(), "Pending callback blocks persistent save")
				var callback = app.game.character_events[app.game.active_character_event_id]
				for step in range(callback.definition.nodes.size() + 1):
					if callback.completed:
						break
					check(app.game.choose_character_event(str(callback.current().choices[0].id)), "Finish pending callback before saving")
			app.game.finish_character_event()
			before = app.game.elapsed()
			var checkpoint: Dictionary = app.game.snapshot()
			check(app.game.restore(JSON.parse_string(JSON.stringify(checkpoint))), "Date and recycled cases restore: " + app.game.save_block_reason() + " / " + app.game.last_error)
			check(app.game.elapsed() == before and app.game.day_number() == 7, "Reload after referrals must remain Monday")
			for child in app.get_children():
				if child is AcceptDialog:
					child.hide()
					child.queue_free()
	print("PATIENT RECYCLE CLOCK TEST: %d checks; %d failures" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
