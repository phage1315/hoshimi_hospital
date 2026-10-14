extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var content = Loader.new()
	expect(content.load_all(), "Content load failed")
	var aqua: Dictionary = content.find_record("staff", "doc_aqua")
	expect(not aqua.is_empty() and aqua.rank == "妇科主任", "Aqua staff profile missing")
	var intro_event: Dictionary = content.find_record("character_events", "aqua_intro_exam_chair")
	var lv1_event: Dictionary = content.find_record("character_events", "aqua_lv1_gyne_obsession")
	expect(str(intro_event.gallery.path) == "assets/events/character_events/aqua/exam_chair_stuck.png", "Aqua intro gallery CG missing")
	expect(str(lv1_event.gallery.path) == "assets/events/character_events/aqua/five_gyne_surgeries_heart_eyes.png", "Aqua Lv1 gallery CG missing")
	for cg_path in ["assets/events/character_events/aqua/exam_chair_stuck.png", "assets/events/character_events/aqua/exam_chair_recovered.png", "assets/events/character_events/aqua/five_gyne_surgeries_heart_eyes.png"]:
		expect(load("res://" + cg_path) is Texture2D, "Aqua event CG missing or unreadable: " + cg_path)
	for skill_id in {"surgery": 95, "diagnostics": 96, "teamwork": 82, "patient_care": 87, "instrument_handling": 94, "calmness": 90}:
		expect(int(aqua.skills.get(skill_id, -1)) == int({"surgery": 95, "diagnostics": 96, "teamwork": 82, "patient_care": 87, "instrument_handling": 94, "calmness": 90}[skill_id]), "Aqua skill profile changed: " + skill_id)
	for outfit in ["white_coat", "scrubs", "sterile"]:
		for expression in ["neutral", "joyful", "troubled", "terrified", "excited", "depressed", "blank"]:
			var portrait_key: String = outfit + "/" + expression
			var expression_portrait := load("res://" + str(aqua.visuals.portraits[portrait_key])) as Texture2D
			expect(expression_portrait != null and expression_portrait.get_size() == Vector2(1024, 1536), "Aqua expression portrait is missing or has the wrong canvas: " + portrait_key)
	var prep = Preop.new(content.collections.preops[0], content.collections.staff, content.collections.surgeries, content.collections.patients)
	prep.procedure_id = "surgery_hysterectomy"
	expect(prep.assignment_response("assistant_surgeon", "doc_aqua").contains("妇科"), "Aqua did not use her gynecology assignment line")
	expect(prep.staff_action_response("doc_aqua", "confirm_assistant_role", "fallback").contains("盆腔暴露"), "Aqua gynecology role confirmation was not selected")
	expect(prep.intraoperative_response("doc_aqua", "incision", "fallback", true).contains("输尿管"), "Aqua gynecology correction did not protect pelvic anatomy")
	prep.procedure_id = "surgery_appendix"
	expect(prep.assignment_response("assistant_surgeon", "doc_aqua").contains("普通外科"), "Aqua non-gynecology assignment line was not selected")
	expect(prep.staff_action_response("doc_aqua", "confirm_assistant_role", "fallback").contains("不是妇科"), "Aqua non-gynecology role confirmation was not selected")
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events)
	expect(not game.character_event_available(game.character_event_definitions.aqua_intro_exam_chair), "Aqua introduction unlocked before gynecology experience")
	game.completed_surgeries_by_group = {"general_abdominal": 10, "female_pelvic": 1}
	expect(not game.character_event_available(game.character_event_definitions.aqua_intro_exam_chair), "Aqua introduction still used the legacy procedure-group count")
	game.increment_character_progress_counter("global", "gynecology_case_count")
	expect(game.character_event_available(game.character_event_definitions.aqua_intro_exam_chair), "Aqua introduction did not use the canonical gynecology case counter")
	var snapshot: Dictionary = game.snapshot()
	var clone = Game.new()
	clone.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events)
	expect(clone.restore(JSON.parse_string(JSON.stringify(snapshot))) and clone.completed_surgeries_by_group == game.completed_surgeries_by_group, "Per-specialty surgery progress did not survive save restore")
	expect(clone.character_progress_counter("global", "gynecology_case_count") == 1, "Aqua gynecology case counter did not survive save restore")
	for locale in ["zh_CN", "en"]:
		test_lv1_unlock(locale)
	print("AQUA CHARACTER: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

func finish_event(game: RefCounted, event_id: String) -> bool:
	var event = game.start_character_event(event_id)
	if event == null:
		return false
	var steps := 0
	while not event.completed and steps < 100:
		steps += 1
		if not game.choose_character_event(str(event.current().choices[0].id)):
			return false
	game.finish_character_event()
	return event.completed

func test_lv1_unlock(locale: String) -> void:
	var localized = Loader.new()
	expect(localized.load_all(locale), "Aqua unlock content load failed: " + locale)
	var game = Game.new()
	var data: Dictionary = localized.collections
	game.configure(data.encounters, data.preops, data.staff, data.time_events, data.surgeries, data.patients, data.relationships, data.character_events)
	var lv1: Dictionary = game.character_event_definitions.aqua_lv1_gyne_obsession
	game.set_test_character_progress_counter("global", "gynecology_case_count", 5)
	expect(not game.character_event_available(lv1), "Five cases must not bypass Aqua introduction: " + locale)
	expect(finish_event(game, "aqua_intro_exam_chair"), "Aqua introduction failed: " + locale)
	var intro_day: int = game.day_number()
	game.relation_for("doc_aqua").familiarity = 0
	game.set_test_character_progress_counter("global", "gynecology_case_count", 4)
	expect(not game.character_event_available(lv1), "Four cases must not unlock Aqua Lv1: " + locale)
	game.set_test_character_progress_counter("global", "gynecology_case_count", 5)
	expect(game.character_event_available(lv1), "Five cases must unlock Aqua Lv1 immediately at zero familiarity: " + locale)
	expect(not game.staff_can_join_surgery_team("doc_aqua"), "Team unlock must still wait for Lv1 event completion: " + locale)
	# Older saves contain relationship data; restore must use the current gates.
	var snapshot: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
	expect(game.restore(snapshot), "Aqua pre-unlock save restore failed: " + locale)
	expect(game.day_number() == intro_day and game.character_event_available(lv1), "Same-day Aqua unlock was lost on restore: " + locale)
	expect(finish_event(game, str(lv1.id)), "Aqua Lv1 event failed: " + locale)
	expect(game.relationship_level("doc_aqua") == 1 and game.staff_can_join_surgery_team("doc_aqua"), "Aqua Lv1 did not unlock team membership: " + locale)
