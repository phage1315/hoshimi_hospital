extends SceneTree

var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func close_notices(app) -> void:
	for child in app.get_children():
		if child is AcceptDialog:
			child.hide()
			child.free()

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var seasonal := ["spring_sakura_garden", "summer_beach", "autumn_maple_temple", "winter_ski_resort"]
	var han := RegEx.new()
	han.compile("[\\x{3400}-\\x{9fff}]")
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "load " + locale)
		app.configure_game_content()
		app.game.reset()
		app.game.meet_staff("doc_minato")
		app.game.relation_for("doc_minato").flags.append("minato_intro_complete")
		app.game.relation_for("doc_minato").familiarity = 10
		app.game.relation_for("doc_minato").level = 4
		var seen_months := {}
		for day in range(1, 366):
			app.game.set_test_time(day, 540)
			var month: int = app.game.month_number()
			var expected: String = seasonal[0] if month in [3, 4, 5] else (seasonal[1] if month in [6, 7, 8] else (seasonal[2] if month in [9, 10, 11] else seasonal[3]))
			var available: Array = app.game.sunday_date_locations()
			expect(available.size() == 13, "13 available locations on day %d" % day)
			expect(not app.game.date_location_available("hotel"), "Hotel excluded")
			for id in seasonal:
				expect(app.game.date_location_available(id) == (id == expected), "Season filter %s day %d" % [id, day])
			if seen_months.has(month) or not app.game.is_sunday():
				continue
			seen_months[month] = true
			app.show_sunday_date_locations("doc_minato")
			for location in available:
				var id := str(location.id)
				var button = app.page.get_node_or_null("SundayDateLocation_" + id)
				expect(button != null and not button.disabled, "Available button " + id)
				if locale == "en":
					expect(han.search(button.text) == null, "English location name " + id)
				app.preview_sunday_date_location(id)
				expect(app.page.get_node("SundayDatePreview").texture.resource_path == "res://" + str(location.preview_path), "Preview " + id)
			for id in seasonal:
				expect((app.page.get_node_or_null("SundayDateLocation_" + id) != null) == (id == expected), "Hidden out-of-season button " + id)
			expect(app.page.get_node_or_null("SundayDateLocation_hotel") == null, "Hotel button absent")
			if "--capture" in OS.get_cmdline_user_args() and month == 4:
				await process_frame
				await process_frame
				root.get_texture().get_image().save_png("/tmp/date_menu_%s.png" % locale)
			var wrong: String = seasonal[1] if expected == seasonal[0] else seasonal[0]
			app.begin_sunday_date("doc_minato", wrong)
			expect(app.screen != "sunday_date" and app.game.day_number() == day, "Direct closed location rejected")
			close_notices(app)
			app.begin_sunday_date("doc_minato", "hotel")
			expect(app.screen != "sunday_date", "Direct hotel rejected")
			close_notices(app)
			app.begin_sunday_date("doc_minato", expected)
			expect(app.screen == "sunday_date", "Seasonal scene opens")
			var loc: Dictionary = app.content.find_record("date_locations", expected)
			expect(app.page.get_node("SceneBackground").texture.resource_path == "res://" + str(loc.preview_path), "Date CG displayed")
			var actor: Dictionary = app.content.find_record("staff", "doc_minato")
			var outfit := "casual_winter" if month in [9, 10, 11, 12, 1, 2] else "casual"
			expect(app.page.get_node("CharacterPortrait").texture.resource_path == "res://" + str(actor.visuals.portraits[outfit + "/neutral"]), "Seasonal outfit")
			if "--capture" in OS.get_cmdline_user_args() and month in [4, 7, 10, 1]:
				await process_frame
				await process_frame
				root.get_texture().get_image().save_png("/tmp/date_%s_%s.png" % [locale, expected])
			app.page.get_node("SundayDateFinish").pressed.emit()
			expect(app.game.day_number() == day + 1 and app.game.sunday_activity_done(day), "Date consumes one day")
			expect(app.game.sunday_history.back().location_id == expected, "History stores location")
			var count: int = app.game.sunday_history.size()
			app.finish_sunday_date("doc_minato", expected, "test")
			expect(app.game.sunday_history.size() == count, "Duplicate finish prevented")
			close_notices(app)
		expect(seen_months.size() == 12, "All months including Jan/Feb covered")
		for location in app.content.collections.date_locations:
			expect(ResourceLoader.exists("res://" + str(location.preview_path)), "Imported CG " + str(location.id))
	print("SEASONAL DATES: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
