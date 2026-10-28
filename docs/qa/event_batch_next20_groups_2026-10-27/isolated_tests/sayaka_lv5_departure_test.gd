extends SceneTree
## In-memory completion/departure regression; never touches save slots.
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func force_offer(game, day: int, clock: int) -> void:
	var variant := "night" if clock >= game.AFTER_WORK_NIGHT_MINUTE else "normal"
	for seed in range(1, 1000):
		game.campaign_seed = seed
		if game.after_work_roll(day, variant, "trigger") >= 40:
			return
	expect(false, "Could not force a deterministic walk offer")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/tmp/hoshimi_next20_unused_sayaka_lv5_departure_test_"+str(OS.get_process_id())+".json"
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		for part in ["a", "b"]:
			for deferred in [false, true]:
				var id: String = "sayaka_lv5_part_" + part
				expect(app.game.prepare_special_event_test_save(id, false), "Prepare " + id)
				app.game.set_test_time(app.game.day_number(), 16 * 60)
				app.game.meet_staff("nurse_haru")
				var departure_day: int = app.game.day_number()
				force_offer(app.game, departure_day, 17 * 60)
				if deferred:
					app.game.set_test_time(departure_day + 1, 9 * 60)
					app.game.pending_day_exit_workday = departure_day
					app.game.pending_day_exit_clock = 17 * 60
				expect(not app.game.after_work_candidates(departure_day).is_empty(), "Offer fixture has eligible staff")
				var event = app.game.start_special_event(id)
				expect(event != null, "Start " + id)
				if event == null:
					continue
				if id == "sayaka_lv5_part_a":
					expect(int(event.started_day) == departure_day, "Part A evening session is anchored to its workday")
				var last: Dictionary = event.current_step().nodes.back()
				expect(event.jump_to(last.id), "Jump to authored ending")
				app.show_special_event()
				var relations: Dictionary = app.game.relationships.duplicate(true)
				app.choose_special_event(last.choices[0].id)
				expect(app.game.special_event_done(id), "Event completed")
				expect(app.screen == "day_transition", "No walk screen after " + id + " deferred=" + str(deferred))
				expect(app.game.active_after_work_walk.is_empty(), "No active walk after " + id)
				expect(app.game.pending_departure_context().is_empty(), "No stale departure after " + id)
				if id == "sayaka_lv5_part_a":
					expect(int(app.game.day_number()) == departure_day + 1, "Part A advances Friday evening to Saturday, not Sunday")
					expect(int(app.game.special_event_completion_days.get(id, 0)) == departure_day, "Part A completion is recorded on its authored evening")
					expect(int(app.day_transition_display_schedule.get("day", 0)) == departure_day, "Part A transition displays its event date")
					expect(int(app.day_transition_display_schedule.get("absolute_clock", 0)) == 22 * 60, "Part A transition displays 22:00")
				# A/B relationship rewards may change Sayaka, but offers must not
				# consume any colleague's cooldown or affect unrelated relationships.
				for actor_id in relations:
					if actor_id != "doc_sayaka":
						expect(app.game.relationships[actor_id] == relations[actor_id], "No collateral relationship/cooldown: " + actor_id)
				if app.screen == "day_transition":
					app.continue_after_day_transition()
					expect(app.game.active_special_event == null and app.game.active_after_work_walk.is_empty(), "Completion dismissal does not restart walk")
		# Part B has an authored morning-after scene inside the same event. The
		# calendar transition must appear between the operating-room and morning
		# scenes, and continuing it must resume at b08_0001.
		expect(app.game.prepare_special_event_test_save("sayaka_lv5_part_b", false), "Prepare Part B scene-boundary check")
		app.game.set_test_time(app.game.day_number(), 16 * 60)
		var part_b_event = app.game.start_special_event("sayaka_lv5_part_b")
		expect(part_b_event != null and part_b_event.jump_to("b07_0041"), "Reach Part B's authored overnight boundary")
		if part_b_event != null and part_b_event.node_id == "b07_0041":
			app.show_special_event()
			app.choose_special_event("b07_0041_next")
			expect(app.screen == "day_transition", "Part B skipped the day-transition screen before its morning scene")
			expect(int(app.day_transition_display_schedule.get("day", 0)) == int(part_b_event.started_day), "Part B transition displays the surgery evening")
			expect(int(app.day_transition_display_schedule.get("absolute_clock", 0)) == 19 * 60, "Part B transition displays 19:00")
			expect(app.game.special_event_in_progress() and app.game.active_special_event.node_id == "b08_0001", "Part B event did not pause at its morning scene")
			app.continue_after_day_transition()
			expect(app.screen == "special_event" and app.game.active_special_event.current().id == "b08_0001", "Continuing day transition did not resume Part B's morning dialogue")
		# Refusing the invitation does NOT consume or suppress the ordinary walk.
		expect(app.game.prepare_special_event_test_save("sayaka_lv5_part_a", false), "Prepare decline")
		app.game.set_test_time(app.game.day_number(), 16 * 60)
		app.game.meet_staff("nurse_haru")
		var day: int = app.game.day_number()
		var event = app.game.start_special_event("sayaka_lv5_part_a")
		expect(event != null and event.jump_to("a01_0014"), "Reach invitation")
		app.game.choose_special_event("decline")
		app.game.choose_special_event("a01_decline_sakaguchi_next")
		app.game.choose_special_event("a01_decline_sayaka_next")
		force_offer(app.game, day, 16 * 60)
		expect(app.game.begin_after_work_departure(day, 16 * 60, true), "Decline retains normal walk")
		# An unrelated normal overtime departure still reaches the same UI.
		app.game.reset()
		app.game.meet_staff("nurse_haru")
		app.game.set_test_time(3, 9 * 60)
		app.game.pending_day_exit_workday = 2
		app.game.pending_day_exit_clock = 17 * 60
		force_offer(app.game, 2, 17 * 60)
		app.show_day_transition(app.show_map)
		expect(app.screen == "after_work_walk", "Ordinary overtime walk unchanged")
	app.free()
	print("SAYAKA LV5 DEPARTURE: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
