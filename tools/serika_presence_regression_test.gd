extends "res://tools/serika_lv5_test.gd"
const Attendance = preload("res://godot/systems/serika_radiology.gd")

class AttendanceWorld extends RefCounted:
	var campaign_seed := 0
	var day := 1
	var story_flags := {}
	var active_staff_patient := {}
	func staff_is_met(_actor: String) -> bool: return true
	func day_number() -> int: return day
	func story_flag(key: String) -> bool: return bool(story_flags.get(key, false))
	func set_story_flag(key: String, value: bool = true) -> void: story_flags[key] = value

func distribution() -> void:
	var world := AttendanceWorld.new()
	var present := 0
	var repeated := 0
	var comparisons := 0
	# Fixed reproducible population, not a promise that a random absence streak
	# can never occur. The previous hash modulo caused strongly correlated days.
	for seed_value in range(16):
		world.campaign_seed = 1013681534 + seed_value
		world.story_flags.clear()
		var previous := false
		for day in range(1, 366):
			world.day = day
			var attending := Attendance.naturally_present(world)
			if attending: present += 1
			if day > 1:
				comparisons += 1
				if attending == previous: repeated += 1
			previous = attending
	var rate := float(present) / (16 * 365)
	var repetition := float(repeated) / comparisons
	expect(rate > 0.65 and rate < 0.75, "Attendance retains approximately 70 percent across fixed samples")
	expect(repetition > 0.50 and repetition < 0.66, "Neighboring days do not cluster from raw string hash modulo")
	print("ATTENDANCE distribution=", rate, " adjacent_equal=", repetition)

func run() -> void:
	distribution()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/serika_presence_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Content " + locale)
		app.configure_game_content()
		fixture()
		var g = app.game
		g.campaign_seed = 1013681534
		var event = g.start_character_event(Flow.ID)
		expect(event != null, "Real Lv5 event starts")
		if event == null: continue
		for step in range(400):
			if event.completed: break
			expect(g.choose_character_event(str(event.current().choices[0].id)), "Lv5 dialogue advances")
		expect(event.completed and g.relationship_level(Flow.ACTOR) == 5, "Lv5 actually settles")
		g.finish_character_event()
		expect(g.active_staff_patient.is_empty(), "Lv5 qualification does not leave an active admission")
		var found := 0
		for offset in range(30):
			if offset > 0: g.advance_story_to_future_day(1, 540)
			var before: Dictionary = g.snapshot()
			var attending: bool = Flow.ACTOR in g.staff_present_at("imaging")
			if attending: found += 1
			expect(g.restore(before), "Restore before first daily roll")
			expect((Flow.ACTOR in g.staff_present_at("imaging")) == attending, "Unrolled reload reproduces daily attendance")
			var saved: Dictionary = g.snapshot()
			for repeat in range(3):
				expect((Flow.ACTOR in g.staff_present_at("imaging")) == attending, "Reentry does not reroll")
			expect(g.restore(saved), "Restore cached daily fact")
			expect((Flow.ACTOR in g.staff_present_at("imaging")) == attending, "Cached reload keeps attendance")
			expect(g.relationship_level(Flow.ACTOR) == 5 and g.character_event_done(Flow.ID), "Presence does not change Lv5 completion")
		expect(found > 0, "Serika remains discoverable after Lv5 across subsequent days")
		var key: String = "serika_imaging_present:%s" % g.day_number()
		for value in [false, true]:
			g.set_story_flag(key, value)
			expect(g.restore(g.snapshot()), "Existing daily fact restores")
			expect(Attendance.naturally_present(g) == value, "Existing true/false facts are not overwritten by new algorithm")
		g.active_staff_patient = {"staff_id": Flow.ACTOR}
		expect(not Attendance.naturally_present(g), "Actually admitted Serika stays off duty")
		g.active_staff_patient.clear()
		g.relation_for(Flow.ACTOR).met = false
		expect(not Attendance.naturally_present(g), "Unmet Serika stays hidden")
	print("SERIKA PRESENCE: %s checks; %s failures" % [checks, failures])
	app.queue_free()
	await process_frame
	quit(1 if failures else 0)
