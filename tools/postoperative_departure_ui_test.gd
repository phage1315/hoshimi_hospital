extends SceneTree

const Preop = preload("res://godot/systems/preop_session.gd")
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func header(app: Node, day: int, clock: String) -> void:
	var text: String = app.page.get_node("CalendarHeader").text
	expect(text.begins_with("DAY %02d" % day) and text.ends_with(clock), "Wrong visible calendar: " + text)

func no_overlap(app: Node, names: Array) -> void:
	var box: Control = app.page.get_node("AfterWorkDialogueBox")
	for node_name in names:
		var control: Control = app.page.get_node(node_name)
		expect(not control.get_rect().intersects(box.get_rect()), "Dialogue overlaps " + node_name)

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Content failed: " + locale)
		app.configure_game_content()
		app.game.reset()
		app.game.set_test_time(2, 600)
		app.show_map(false)
		header(app, 2, "10:00")
		var original_page: Control = app.page
		app.game.story_time_advance_minutes += 7
		await process_frame
		await process_frame
		expect(app.page == original_page, "Clock refresh rebuilt the page")
		header(app, 2, "10:07")

		# The ledger reserves tomorrow; all later actions remain this evening.
		app.game.set_test_time(2, 1019)
		var before: int = app.game.elapsed()
		app.game.story_time_advance_minutes += 30
		expect(app.game.settle_overtime(before, 30), "Failed to cross end of shift")
		app.refresh_calendar_header()
		header(app, 2, "17:29")
		before = app.game.elapsed()
		app.game.story_time_advance_minutes += 2
		app.game.settle_overtime(before, 2)
		app.refresh_calendar_header()
		header(app, 2, "17:31")
		expect(app.game.day_number() == 3 and app.game.current_absolute_clock() == 540, "Epilogue leaked into tomorrow's clock")
		app.game.pending_day_exit_clock = 1505
		app.refresh_calendar_header()
		header(app, 3, "01:05")

		# Manual early departure advances only when the walk is finished.
		app.game.reset()
		app.game.set_test_time(2, 960)
		app.game.meet_staff("nurse_haru")
		for seed in range(1, 200):
			app.game.campaign_seed = seed
			if app.game.begin_after_work_departure(2, 960, true):
				break
		app.show_after_work_walk()
		header(app, 2, "16:00")
		app.choose_after_work_walk(false)
		app.complete_after_work_walk()
		header(app, 2, "16:00")
		expect(app.game.day_number() == 3, "Manual departure did not reserve tomorrow")
		app.continue_after_day_transition()
		header(app, 3, "09:00")
		app.game.reset()
		app.game.set_test_time(2, 1019)
		before = app.game.elapsed()
		app.game.story_time_advance_minutes += 10
		app.game.settle_overtime(before, 10)
		# No eligible staff means no walk, but the night page still uses departure time.
		for relation in app.game.relationships.values():
			relation.met = false
		app.show_day_transition(app.show_map)
		expect(app.screen == "day_transition", "No-offer path did not reach night page")
		header(app, 2, "17:09")
		app.continue_after_day_transition()
		header(app, 3, "09:00")

		# Actual offer/accept/finish UI, including the Saturday -> Sunday boundary.
		for day in [2, 5]:
			for variant in ["normal", "night"]:
				app.game.reset()
				app.game.set_test_time(day + 1, 540)
				app.game.meet_staff("nurse_haru")
				var departure := 1040 if variant == "normal" else 1160
				for seed in range(1, 200):
					app.game.campaign_seed = seed
					if app.game.begin_after_work_departure(day, departure, false):
						break
				expect(not app.game.active_after_work_walk.is_empty(), "No walk fixture")
				app.show_after_work_walk()
				header(app, day, "17:20" if variant == "normal" else "19:20")
				no_overlap(app, ["AfterWorkInvite", "AfterWorkSkip"])
				var street_id := "after_work_street_spring_night" if variant == "night" else "after_work_street_spring"
				var hospital_id := "hospital_night" if variant == "night" else "lobby"
				expect(app.after_work_background_id(app.game.active_after_work_walk) == hospital_id, "Offer must stay at hospital")
				var texture: Texture2D = app.page.get_child(0).texture
				expect(texture != null and texture.resource_path == "res://" + app.background_path(hospital_id), "Offer did not render hospital")
				app.choose_after_work_walk(true)
				var expected_id: String = street_id if app.game.active_after_work_walk.outcome == "completed" else hospital_id
				expect(app.after_work_background_id(app.game.active_after_work_walk) == expected_id, "Invitation result selected wrong background")
				texture = app.page.get_node("SceneBackground").texture
				expect(texture.resource_path == "res://" + app.background_path(expected_id), "Invitation result did not render expected background")
				no_overlap(app, ["AfterWorkFinish"])
				if "--capture-walk" in OS.get_cmdline_user_args() and locale == "en" and day == 2 and variant == "normal":
					await process_frame
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png("/tmp/hoshimi-after-work-ui.png")
				app.complete_after_work_walk()
				header(app, day, "17:20" if variant == "normal" else "19:20")
				app.continue_after_day_transition()
				expect(app.screen == ("sunday_menu" if day == 5 else "map"), "Wrong next-day page")
				header(app, day + 1, "09:00")

		# Settlement button -> ordinary micro-event -> Asuka reveal -> directory.
		for overtime in [false, true]:
			app.game.reset()
			app.game.completed_surgeries_total = 2
			expect(app.game._complete_character_event_for_test("asuka_scrub_sink_encounter", 1), "Missing scrub prerequisite")
			app.game.finish_character_event()
			app.game.advance_story_to_day(2, 600)
			var definition: Dictionary = app.game.preop_definitions.values()[0]
			var visit = app.game.open_visit(str(definition.encounter_id))
			expect(visit != null, "Missing surgical admission fixture")
			visit.admitted = true
			visit.stage_id = str(visit.definition.completion)
			var prep = Preop.new(definition, app.content.collections.staff, app.content.collections.surgeries, app.content.collections.patients)
			prep.stage_id = "surgery_result"
			prep.procedure_id = str(definition.surgery_id)
			prep.procedure_name = str(app.game.surgery_definition(prep.procedure_id).name)
			prep.surgery_success = true
			app.game.preops[definition.id] = prep
			app.game.active_preop_id = str(definition.id)
			app.game.active_mode = "preop"
			# Use an existing authored micro-event, not a fabricated story node.
			var selected: Dictionary = {}
			for item in app.game.micro_event_definitions.values():
				if item.context == "after_surgery":
					selected = item
					break
			expect(not selected.is_empty(), "No authored postoperative micro-event")
			app.game.meet_staff(str(selected.actor_id))
			app.game.relation_for(str(selected.actor_id)).familiarity = 100
			prep.team.assistant = str(selected.actor_id)
			app.game.micro_event_definitions = {selected.id: selected}
			if overtime:
				before = app.game.elapsed()
				var minutes: int = 480 - int(app.game.schedule_at(before).shift_minute) + 30
				prep.minutes += minutes
				app.game.settle_overtime(before, minutes)
				app.game.pending_surgery_day_transition = true
			app.show_preop(str(definition.id))
			expect(app.screen == "preop", "Results page failed to open")
			expect(app.game.active_character_event_id.is_empty(), "Reveal interrupted results page")
			app.finish_surgery_and_return()
			expect(not app.game.active_micro_event_id.is_empty(), "Postoperative micro-event was skipped")
			expect(app.game.active_character_event_id.is_empty(), "Reveal interrupted micro-event")
			var micro = app.game.micro_events.get(app.game.active_micro_event_id)
			if micro == null:
				continue
			while not micro.at_choice():
				micro.advance_opening()
			app.choose_micro_event(str(micro.definition.choices[0].id))
			while not micro.response_finished():
				micro.advance_response()
			app.continue_micro_event()
			expect(app.game.completed_surgeries_total == 3 and app.game.active_preop_id.is_empty(), "Surgery not settled before reveal")
			expect(app.game.active_character_event_id == "asuka_adjacent_operation_reveal", "Reveal missing at return boundary")
			var event = app.game.character_events.get(app.game.active_character_event_id)
			if event == null:
				continue
			for step in range(30):
				if event.completed:
					break
				app.choose_character_event(str(event.current().choices[0].id))
			expect(event.completed and event.completed_day == 2, "Reveal completion uses wrong day")
			expect(app.page.get_node_or_null("PostSurgeryEventContinue") != null, "Missing postoperative return action")
			if overtime:
				header(app, 2, "17:32")
			app.finish_post_surgery_character_event()
			expect(app.game.completed_surgeries_total == 3, "Surgery was settled twice")
			if overtime:
				expect(app.screen in ["day_transition", "after_work_walk"], "Lost deferred departure")
			else:
				expect(app.screen == "map", "Reveal did not return to directory")
	print("POSTOPERATIVE DEPARTURE UI: %s checks; %s failure(s)" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
