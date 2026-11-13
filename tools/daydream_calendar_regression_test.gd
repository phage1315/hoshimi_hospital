extends SceneTree
## Read-only source-slot audit. All playback state remains in memory.
const Catalog = preload("res://godot/systems/daydream_catalog.gd")
var checks := 0
var failures := 0

func expect(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(note)

func _initialize() -> void: call_deferred("run")

func check_clock(app, expected: Dictionary, header: String, note: String) -> void:
	app.refresh_calendar_header()
	expect(app.game.display_schedule() == expected, note + ": presentation clock unchanged")
	expect(app.page.get_node("CalendarHeader").text == header, note + ": visible header unchanged")
	expect(app.game.pending_departure_context().is_empty(), note + ": no pending overtime")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	var app = load("res://godot/scenes/main.tscn").instantiate()
	app.title_preferences_path = "/private/tmp/daydream_calendar_prefs_%s.cfg" % OS.get_process_id()
	app.saves.path = "/private/tmp/daydream_calendar_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	var store = load("res://godot/systems/save_store.gd").new()
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load locale " + locale)
		app.configure_game_content()
		if args.is_empty():
			app.game.reset()
			app.game.archived_clinical_minutes = 229 * app.game.SHIFT_MINUTES
			for person in app.game.staff: app.game.relation_for(person.id).met = true
		else:
			store.path = args[0]
			var loaded: bool = store.read_slot(app.game)
			expect(loaded, "Read source without writing: " + store.last_error)
			if not loaded: break
		var saved: Dictionary = app.game.snapshot()
		var expected: Dictionary = app.game.display_schedule().duplicate(true)
		app.resume_progress()
		expect(app.screen == "sunday_menu", "Sunday save resumes in Sunday menu")
		var header: String = app.page.get_node("CalendarHeader").text
		expect(app.game.day_number() == 230 and app.game.current_absolute_clock() == 540, "Source Sunday November 16 09:00")
		expect(app.game.is_hospital_closed_day() and not app.game.is_hospital_closed_day(231), "Sunday closed; Monday November 17 open")
		for entry in Catalog.entries():
			if not Catalog.unlocked(entry, app.game):
				print("LOCKED (not played): ", locale, " ", entry.id)
				continue
			for complete in [false, true]:
				app.show_sunday_office_menu()
				app.show_daydreams()
				var view = app.daydream_view
				view.maximum = 2
				view.dark_confirmed = true
				view.confirm_entry(entry)
				view.begin()
				expect(view.session != null, "Production entry begins: " + entry.id)
				var steps := 0
				while view.session != null and steps < 500:
					check_clock(app, expected, header, entry.id)
					var node: Dictionary = view.session.current()
					view.choose(str(node.choices[0].id))
					steps += 1
					if not complete:
						view.leave()
						break
				expect(view.session == null and app.screen == "sunday_office", "Playback exits to Sunday office")
				check_clock(app, expected, header, "After playback")
				var after: Dictionary = app.game.snapshot()
				after.daydream_read_ids = saved.daydream_read_ids.duplicate()
				expect(after == saved, "Only allowed read IDs can change; time and all business facts unchanged")
				app.show_location("clinic", true, false, false)
				check_clock(app, expected, header, "Clinic after playback")
				expect(app.game.is_hospital_closed_day(), "Clinic remains closed on Sunday")
				print("PLAYED ", locale, " ", entry.id, " complete=", complete, " steps=", steps, " header=", header)
		app.finish_sunday_activity("rest_home", "")
		expect(app.game.day_number() == 231 and app.game.current_absolute_clock() == 540, "End Sunday advances to Monday 09:00")
		app.show_location("clinic", true, false, false)
		expect(not app.game.is_hospital_closed_day() and not app.game.current_patient_id().is_empty(), "Monday clinic has a waiting patient")
		print("MONDAY ", locale, " ", app.page.get_node("CalendarHeader").text)
	app.queue_free()
	await process_frame
	print("DAYDREAM CALENDAR: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
