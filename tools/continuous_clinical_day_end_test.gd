extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func clinical_screen(app: Node, day: int, label: String) -> void:
	expect(app.screen not in ["day_transition", "after_work_walk", "sunday_menu"], label + ": clinical care was interrupted")
	expect(app.game.day_transition_deferred(), label + ": continuous clinical lock missing")
	expect(int(app.game.display_schedule().day) == day, label + ": lost overtime workday")
	expect(not app.game.pending_departure_context().is_empty(), label + ": lost pending departure")

func reset_fixture(app: Node, day: int) -> void:
	for child in app.get_children():
		if child is AcceptDialog:
			child.hide()
			child.queue_free()
	app.game.reset()
	app.game.patient_cases["patient_sora"] = "template_appendicitis"
	app.game.rebuild_patient_content(app.game.patient_cases)
	app.game.patient_queue.erase("patient_sora")
	app.game.patient_queue.push_front("patient_sora")
	app.game.micro_event_definitions.clear()
	app.game.character_event_definitions.clear()
	app.game.set_test_time(day, 959)
	app.show_encounter("visit_sora")
	app.game.set_test_time(day, 1019)

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Content loads: " + locale)
		app.configure_game_content()
		for day in [4, 5]:
			reset_fixture(app, day)
			var visit = app.game.visits.get("visit_sora")
			expect(visit != null, "Clinic fixture opens before closing")
			if visit == null:
				continue
			app.game.set_test_time(day, 1019)
			for action_id in ["greet", "basic_history", "to_exam", "vitals", "limited_clothed_exam", "blood", "imaging", "to_diagnosis", "diagnose_appendix", "explain", "admit"]:
				app.choose_clinic_action(action_id)
				if app.screen == "examination_cg":
					var button := app.page.find_child("ExaminationCGContinue", true, false) as Button
					expect(button != null, "Examination CG has continue button")
					if button != null:
						# Splash protection uses wall time, not SceneTree time.
						var deadline := Time.get_ticks_msec() + 3000
						while button.disabled and Time.get_ticks_msec() < deadline:
							await process_frame
						expect(not button.disabled, "Examination CG minimum exposure elapsed")
						button.pressed.emit()
				expect(visit.action_log.has(action_id) or action_id == "basic_history" and visit.action_log.has("background"), locale + "/%d/%s: action applied" % [day, action_id])
				clinical_screen(app, day, locale + "/" + action_id)
			expect(visit.admitted, "Admission completed")
			expect(app.page.get_node_or_null("AdmissionEndDay") != null, "Actual overtime admit callback offers explicit handoff")
			# A generic transition caller must also respect the admission gap.
			app.show_day_transition(app.show_encounter.bind("visit_sora"))
			clinical_screen(app, day, "admission boundary")
			app.show_map()
			expect(app.screen == "map", "Overtime directory must not open tomorrow's Sunday menu")
			app.show_preop("preop_sora")
			var prep = app.game.preops.get("preop_sora")
			expect(prep != null and app.screen == "preop", "Overtime admission enters preparation, including Saturday")
			if prep == null:
				continue
			clinical_screen(app, day, "before team confirmation")
			app.show_day_transition(app.show_preop.bind("preop_sora"))
			clinical_screen(app, day, "preparation transition guard")
			# Controlled result fixture: exercise the real settlement callback,
			# not a second full simulation of the separately tested surgery engine.
			prep.procedure_id = str(prep.definition.surgery_id)
			prep.procedure_name = str(app.game.surgery_definition(prep.procedure_id).name)
			prep.stage_id = "surgery_result"
			prep.surgery_success = true
			app.show_preop("preop_sora")
			clinical_screen(app, day, "result awaiting confirmation")
			app.finish_surgery_and_return()
			var growth: Control = app.page.get_node_or_null("SurgeryGrowthSplash")
			expect(growth != null, "Settlement growth panel appears before departure")
			if growth != null:
				growth.get_node("SurgeryGrowthContinue").pressed.emit()
			expect(app.screen == "day_transition", "Departure occurs only after settlement confirmation")
			expect(not app.game.day_transition_deferred(), "Settled case releases clinical lock")
			expect(not app.game.pending_encounter_day_transition and not app.game.pending_surgery_day_transition, "Settlement clears both deferred flags")
			app.continue_after_day_transition()
			expect(app.game.day_number() == day + 1 and app.game.current_absolute_clock() == 540, "Overtime ends at next morning 09:00")
			expect(app.screen == ("sunday_menu" if day == 5 else "map"), "Correct next-day destination")
		# Explicit referral releases an unfinished encounter, not a new case.
		reset_fixture(app, 4)
		app.choose_clinic_action("greet")
		app.game.meet_staff("doc_aoi")
		app.game.set_after_work_last_offer_day("doc_aoi", 4)
		app.complete_referral("patient_sora", "doc_aoi")
		expect(app.screen == "day_transition", "Referral resolves overtime departure")
		expect(not app.game.day_transition_deferred(), "Referral releases the old encounter lock")
		# Explicit surgical abort also settles before requesting departure.
		reset_fixture(app, 4)
		app.choose_clinic_action("greet")
		var visit = app.game.visits["visit_sora"]
		visit.admitted = true
		visit.stage_id = str(visit.definition.completion)
		app.show_preop("preop_sora")
		var prep = app.game.preops["preop_sora"]
		prep.surgery_aborted = true
		app.game.pending_surgery_day_transition = true
		expect(app.game.day_transition_deferred(), "Abort result remains locked until confirmation")
		app.finish_aborted_surgery_and_return()
		expect(app.screen == "day_transition", "Confirmed abort resolves overtime departure")
		expect(not app.game.day_transition_deferred(), "Abort settlement releases lock")
		expect(not app.game.pending_encounter_day_transition and not app.game.pending_surgery_day_transition, "Abort clears both deferred flags")
	print("CONTINUOUS CLINICAL DAY END: %d checks; %d failures" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
