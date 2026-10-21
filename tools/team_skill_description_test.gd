extends SceneTree

const View = preload("res://godot/ui/preop_view.gd")
const StaffView = preload("res://godot/ui/staff_view.gd")
const Prep = preload("res://godot/systems/preop_session.gd")
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func picker_text(app: Control, actor_id: String, role_id: String) -> String:
	var prep = Prep.new(app.content.collections.preops[0], app.game.staff)
	var role: Dictionary = prep.role_definition(role_id)
	View.role_picker(app, prep, role, 0)
	var picker := app.page.get_node("Role_" + role_id) as OptionButton
	var people: Array = prep.candidates(role_id)
	var result := ""
	for i in range(people.size()):
		if str(people[i].id) == actor_id:
			result = picker.get_item_text(i + 1)
	picker.free()
	return result

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		app.game.reset()
		var limited: String = app.tx("ui.team.skill_limited", "　⚠ 经验有限")
		var trained: String = app.tx("ui.team.skill_trained", "　熟练")
		var experienced: String = app.tx("ui.team.skill_experienced", "　经验丰富")
		expect(not limited.is_empty() and not trained.is_empty() and not experienced.is_empty(), "Localized labels")
		var nurse_summary := StaffView.skills_summary(app, {"profession": "nurse", "skills": {"surgery": 70, "teamwork": 71, "calmness": 72, "patient_care": 73, "instrument_handling": 74}})
		var doctor_summary := StaffView.skills_summary(app, {"profession": "doctor", "skills": {"surgery": 70, "teamwork": 71, "calmness": 72, "patient_care": 73, "instrument_handling": 74}})
		expect(nurse_summary.count("\n") == 1 and nurse_summary.contains("74") and nurse_summary.contains("70"), "Nurse profile does not show all five competencies in two rows")
		expect(doctor_summary.contains("70") and doctor_summary.contains("71") and doctor_summary.contains("72") and not doctor_summary.contains("73") and not doctor_summary.contains("74"), "Doctor profile did not hide patient care and instrument handling")
		for value in [0, 59, 60, 79, 80, 90, 100]:
			var expected: String = limited if value < 60 else trained if value < 80 else experienced
			for background in ["novice", "limited", "trained", "expert"]:
				var person := {"skills": {"surgery": value, "teamwork": 90}, "surgery_proficiency": background}
				expect(View.role_skill_description(app, person, {"skill": "surgery"}) == expected, "Current surgery boundary %s/%s" % [value, background])
				expect(View.role_skill_description(app, person, {"skill": "teamwork"}) == experienced, "Role skill must be independent")
		# Real training, actual picker and save/restore: Shiori begins at 54.
		for target in [59, 60, 79, 80, 90]:
			while app.game.staff_skill_value("doc_shiori", "surgery") < target:
				app.game.train_surgery_team({"assistant_surgeon": "doc_shiori"}, "surgery_appendectomy")
			var text := picker_text(app, "doc_shiori", "assistant_surgeon")
			var expected: String = limited if target < 60 else trained if target < 80 else experienced
			expect(text.contains(str(target)) and text.ends_with(expected), "Trained picker " + str(target))
			expect(not text.contains(str(target) + ".0"), "Integer display")
		var save: Dictionary = app.game.snapshot()
		app.game.reset()
		expect(picker_text(app, "doc_shiori", "assistant_surgeon").ends_with(limited), "New game restores initial label")
		expect(app.game.restore(save), "Restore trained save")
		expect(picker_text(app, "doc_shiori", "assistant_surgeon").ends_with(experienced), "Loaded skill drives label")
		var restored := Prep.new(app.content.collections.preops[0], app.game.staff)
		expect(restored.roster.doc_shiori.surgery_proficiency == "limited", "Authored background preserved")
	app.free()
	print("TEAM SKILL DESCRIPTION: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures else 0)
