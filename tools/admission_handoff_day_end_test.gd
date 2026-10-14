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

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Content loads: " + locale)
		app.configure_game_content()
		for day in [4, 5]:
			for clock in [1019, 1020, 1041]:
				app.game.reset()
				app.game.micro_event_definitions.clear()
				app.game.character_event_definitions.clear()
				app.game.set_test_time(day, 600)
				app.show_encounter("visit_sora")
				var visit = app.game.visits["visit_sora"]
				for action in ["greet", "basic_history", "to_exam", "vitals", "limited_clothed_exam", "blood", "imaging", "to_diagnosis", "diagnose_appendix", "explain", "admit"]:
					expect(visit.apply(action), "Admission fixture action: " + action)
				app.game.set_test_time(day, 1019)
				app.game.story_time_advance_minutes -= visit.minutes
				if clock >= 1020:
					var before: int = app.game.elapsed()
					app.game.story_time_advance_minutes += clock - 1019
					app.game.settle_overtime(before, clock - 1019)
					app.game.remember_deferred_day_transition()
				app.show_encounter("visit_sora")
				var state: Dictionary = visit.snapshot_state()
				var queue: Array = app.game.patient_queue.duplicate()
				var total_minutes: int = app.game.elapsed()
				var dialogue: String = app.page.get_node("ClinicDialogue").text
				for refresh in range(3):
					app.show_encounter("visit_sora")
					expect(app.screen == "encounter", "Summary does not automatically leave")
					expect(app.page.get_node("ClinicDialogue").text == dialogue, "Handoff dialogue retained")
				var button: Button = app.page.get_node_or_null("AdmissionEndDay")
				if clock < 1020:
					expect(button == null and app.page.get_node_or_null("AdmissionGoWard") != null, "Before 17:00 keeps ward button")
					app.finish_admission_day("visit_sora")
					expect(app.screen == "encounter" and app.game.active_id == "visit_sora", "Early end-day request is rejected")
					continue
				expect(button != null and app.page.get_node_or_null("AdmissionGoWard") == null, "Overtime replaces ward button")
				if button == null:
					continue
				expect(button.text == ("交接患者休息，结束今日工作 →" if locale == "zh_CN" else "Hand over ward care and end today's work →"), "Bilingual handoff label")
				expect(button.position.x + button.size.x <= 735, "Handoff button remains left of portrait")
				expect(app.game.day_transition_deferred(), "Summary still requires explicit handoff")
				app.finish_admission_day("visit_emi")
				expect(app.screen == "encounter", "Stale/wrong patient callback is rejected")
				button.pressed.emit()
				expect(app.screen == "day_transition", "Click reaches departure after full summary")
				expect(app.page.get_node("CalendarHeader").text.begins_with("DAY %02d" % day), "Departure shows original workday")
				app.finish_admission_day("visit_sora")
				expect(app.game.elapsed() == total_minutes, "Repeated handoff adds no time")
				expect(visit.snapshot_state() == state and app.game.patient_queue == queue, "Handoff preserves admission, notes and queue")
				expect(app.game.active_id.is_empty() and not app.game.day_transition_deferred(), "Handoff releases active flow only")
				app.continue_after_day_transition()
				expect(app.game.day_number() == day + 1 and app.game.current_absolute_clock() == 540, "Next day starts at 09:00")
				expect(app.game.admitted_patient("patient_sora"), "Patient stays in ward overnight")
				expect(app.game.can_save_progress(), "Overnight admission reaches saveable boundary")
				var saved: Dictionary = JSON.parse_string(JSON.stringify(app.game.snapshot()))
				expect(app.game.restore(saved), "Overnight admission restores from a boundary snapshot")
				expect(app.game.admitted_patient("patient_sora") and app.game.visits["visit_sora"].notes == state.notes, "Restore retains admission and patient notes")
				if day == 4:
					app.show_preop("preop_sora")
					expect(app.screen == "preop", "Next workday can continue this patient's preparation")
				else:
					expect(app.screen == "sunday_menu", "Saturday handoff preserves Sunday rules")
					expect(app.game.open_preop("preop_sora") == null, "No Sunday elective surgery booking")
					app.game.advance_story_to_future_day(1, 540)
					app.show_preop("preop_sora")
					expect(app.screen == "preop", "Retained patient continues on Monday")
				expect(not app.game.can_end_day_after_admission("visit_sora"), "Preparation cannot use admission handoff")
	print("ADMISSION HANDOFF DAY END: %d checks; %d failures" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
