extends SceneTree
const Flow = preload("res://godot/systems/chihaya_second_surgery.gd")
const Event = preload("res://godot/systems/character_event_session.gd")
const Replay = preload("res://godot/systems/special_event_session.gd")
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func relation_facts(g) -> Dictionary:
	# Normalize JSON floats versus restored integer counters without losing fields.
	return JSON.parse_string(JSON.stringify(g.relationships))

func complete(g, id: String, day: int) -> void:
	var event = Event.new(g.character_event_definitions[id])
	event.completed = true
	event.completed_day = day
	event.settled_minutes = 0
	g.character_events[id] = event
	if not g.character_event_order.has(id):
		g.character_event_order.append(id)

func setup(g, aqua_day: int = 20, first_day: int = 2) -> void:
	g.reset()
	if first_day > 0: complete(g, Flow.FIRST, first_day)
	if aqua_day > 0: complete(g, Flow.AQUA, aqua_day)
	# Test only this schedule, then explicitly inject competing morning events.
	for definition in g.special_event_definitions.values():
		if not Flow.owns(str(definition.id)):
			definition.developer_only = true
	for definition in g.character_event_definitions.values():
		if g.character_event_trigger_mode(definition) == "day_start":
			definition.trigger_mode = "location"
	g.set_test_time(49, 540)

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load locale " + locale)
		app.configure_game_content()
		var g = app.game
		setup(g, 0)
		expect(g.calendar_iso() == "2025-05-19" and g.calendar_date().weekday_id == "mon", "Calendar anchor")
		expect(g.start_special_event(Flow.A) == null, "Missing Aqua Lv1 blocks")
		g.relation_for("doc_aqua").level = 5
		expect(g.start_special_event(Flow.A) == null, "Numeric rank is not milestone completion")
		setup(g, 20, 0)
		expect(g.start_special_event(Flow.A) == null, "Missing Hiroko background fact blocks")
		setup(g, 52)
		expect(Flow.target_day(g, Flow.A) == 56, "Thursday May22 completion delays whole chain to May26")
		setup(g, 49)
		expect(Flow.target_day(g, Flow.A) == 56 and g.start_special_event(Flow.B) == null, "Monday same-day completion goes to next Monday; no isolated B")
		setup(g, 20, 50)
		expect(Flow.target_day(g, Flow.A) == 56, "Delayed first surgery also defers whole chain")
		setup(g)
		g.set_test_time(49, 541)
		expect(Flow.target_day(g, Flow.A) == 56 and g.start_special_event(Flow.A) == null, "Never rewind missed morning")
		setup(g)
		var blocker: Dictionary = g.special_event_definitions.framework_single_day_test.duplicate(true)
		blocker.id = "chihaya_test_blocker"
		blocker.developer_only = false
		blocker.auto_schedule = true
		blocker.unlock_requirements = []
		blocker.timing = {"trigger_day":49,"priority":11000,"final_week_allowed":true}
		g.special_event_definitions[blocker.id] = blocker
		expect(g.start_special_event(Flow.A) == null, "Higher priority fixed event wins D0")
		g.set_test_time(49, 600)
		expect(Flow.target_day(g, Flow.A) == 56 and not g.special_event_done(Flow.A), "Conflict postpones unstarted chain without false completion")
		g.special_event_definitions.erase(blocker.id)
		setup(g)
		var before_attrs: Dictionary = g.player_attributes().duplicate(true)
		var before_relations: Dictionary = relation_facts(g)
		var original_steps: Dictionary = g.special_event_step_definitions.duplicate(true)
		for i in range(3):
			var id: String = [Flow.A, Flow.B, Flow.C][i]
			g.set_test_time(49 + i, 540)
			if i > 0:
				g.special_event_definitions[blocker.id] = blocker
				expect(g.next_auto_special_event().get("id", "") == id, "Committed B/C reservation wins even higher priority arrivals")
				g.special_event_definitions.erase(blocker.id)
			var start_minutes: int = g.elapsed()
			# Exercise actual application dispatch, not only the helper predicate.
			app.show_map()
			expect(app.screen == "special_event" and g.active_special_event_id == id, "09:00 automatic dispatch " + id)
			if g.active_special_event == null:
				quit(1)
				return
			expect(not g.can_save_progress() and g.snapshot().is_empty(), "No persistent mid-VN checkpoint")
			expect(g.start_special_event(id) == null, "Duplicate start blocked")
			var step: Dictionary = g.active_special_event.current_step()
			for node in step.nodes:
				expect(g.active_special_event.current().id == node.id, "Source order " + str(node.id))
				expect(g.elapsed() == start_minutes, "No per-line or procedure time charge")
				expect(not app.special_event_localized_text(step, node).is_empty(), "Localized body exists")
				if locale == "en":
					var regex := RegEx.new()
					regex.compile("[\\x{3400}-\\x{9fff}]")
					expect(regex.search(app.special_event_localized_text(step,node)) == null, "No Chinese in English node")
				# Render each staging transition, checking all referenced textures.
				if node.id.ends_with("001") or node.id in ["a2_005","b1_013","b4_042","c1_038","c1_117"]:
					app.show_special_event()
					for portrait in node.event_portraits:
						expect(app.page.get_node_or_null("EventPortrait_" + str(portrait.id)) != null, "Runtime portrait " + str(portrait.id))
					if OS.get_cmdline_user_args().has("--screenshots") and DisplayServer.get_name() != "headless" and node.id in ["a2_005", "b4_042", "c1_038"]:
						var output := "res://docs/qa/chihaya_second_surgery/runtime_images/"
						DirAccess.make_dir_recursive_absolute(output)
						await process_frame
						await RenderingServer.frame_post_draw
						expect(root.get_texture().get_image().save_png(output + locale + "_" + str(node.id) + ".png") == OK, "Save runtime screenshot")
				if str(node.get("actor_id", "")) == "nurse_sonoda_itsumi":
					var relation: Dictionary = g.relation_for("nurse_sonoda_itsumi")
					var old_met: bool = bool(relation.met)
					for met in [false, true]:
						relation.met = met
						expect(app.special_event_speaker(node, app.special_event_actor(node), step.id) == ("Itsumi Sonoda" if locale == "en" else "薗田爱实"), "Itsumi real name regardless of introduction unlock")
					relation.met = old_met
				var result: Dictionary = g.choose_special_event("continue")
				expect(result.accepted and not result.day_finished, "Continuous partial-day VN")
			var duration: int = [120,300,60][i]
			expect(g.elapsed() == start_minutes + duration and g.day_number() == 49+i, "Exact single duration; no skipped day")
			expect(g.special_event_completion_days[id] == 49+i, "Actual completion date")
			expect(not g.choose_special_event("continue").accepted, "Repeated final action cannot settle again")
			app.show_special_event_complete()
			g.finish_special_event()
			app.show_map(false)
			expect(g.can_save_progress(), "Between-stage map save allowed")
			expect(g.player_attributes() == before_attrs and relation_facts(g) == before_relations, "No invented rewards or staff unlocks")
			expect(g.completed_surgeries_total == 0 and not g.active_surgery_in_progress(), "No Surgery Runner or score")
			var save: Dictionary = g.snapshot()
			expect(not save.is_empty(), "Safe save exists")
			var serialized := JSON.stringify(save)
			for forbidden in ["a1_001", "b2_045", "c1_038", "node_id", "step_index", "last_choice"]:
				expect(not serialized.contains(forbidden), "No persistent inner state: " + forbidden)
			# Completed scripts can be structurally replaced without breaking saves.
			g.special_event_step_definitions[step.id].nodes = []
			g.special_event_definitions[id].settled_minutes = 999
			expect(g.restore(save), "Restore independent of old nodes and current duration")
			expect(g.elapsed() == start_minutes + duration, "Historical time remains settled")
			g.special_event_step_definitions = original_steps.duplicate(true)
			g.special_event_definitions[id].settled_minutes = duration
			var save2: Dictionary = g.snapshot()
			expect(g.restore(save2) and g.snapshot() == save2, "Stable repeated save/restore")
			if i == 0:
				expect(not g.story_flag("chihaya_second_surgery_success") and not g.story_flag("met_mizuho_story"), "A does not finish surgery or introduce Mizuho")
				expect(g.special_event_trigger_day(g.special_event_definitions[Flow.C]) == 51, "Wednesday reserved before B starts")
				blocker.duration_days = 3
				g.special_event_definitions[blocker.id] = blocker
				expect(not g.special_event_available(blocker), "Later high-priority multi-day event cannot displace committed mornings")
				g.special_event_definitions.erase(blocker.id)
				blocker.duration_days = 1
				var referral: Dictionary = g.advanced_referral_timing_status({"duration_days":3,"priority":100})
				expect(int(referral.start_day) == 52, "Referral defers beyond both reserved mornings")
			if i == 1:
				expect(Flow.third_surgery_earliest_day(g) == 92, "Six-week clock anchored to Tuesday surgery")
				expect(not g.story_flag("chihaya_second_surgery_complete"), "B does not finish entire chain")
			expect(not g.special_event_available(g.special_event_definitions[id]), "Completed stage cannot repeat")
		expect(g.story_flag("met_mizuho_story") and g.story_flag("chihaya_second_surgery_complete"), "C completes story-only introduction")
		expect(g.relation_for("guest_mizuho").is_empty(), "Mizuho remains cameo, not staff")
		var before: Dictionary = g.snapshot()
		var replay = Replay.new(g.special_event_definitions[Flow.B], g.special_event_step_definitions, 50)
		while not replay.completed: replay.apply("continue")
		expect(g.snapshot() == before, "Gallery replay changes no game state")
		# Drive the real ordinary departure / next-day UI, without set_test_time
		# between episodes. This catches map(false) skipping 09:00 dispatch.
		setup(g)
		app.show_map()
		for i in range(3):
			var id: String = [Flow.A, Flow.B, Flow.C][i]
			expect(app.screen == "special_event" and g.active_special_event_id == id, "Normal next-day UI dispatch " + id)
			if g.active_special_event == null:
				break
			while not g.active_special_event.completed:
				g.choose_special_event("continue")
			app.finish_special_event_and_return()
			expect(app.screen == "map" and g.current_absolute_clock() == [660,840,600][i], "Ordinary map and correct clock after phase")
			if i < 2:
				g.advance_story_to_day(49+i, 960)
				app.request_end_workday()
				expect(app.screen == "day_transition", "Visible ordinary day transition")
				app.continue_after_day_transition()
				expect(g.day_number() == 50+i and g.current_absolute_clock() == 540, "One calendar day only; next morning 09:00")
	print("CHIHAYA SECOND SURGERY: %s checks; %s failure(s)" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
