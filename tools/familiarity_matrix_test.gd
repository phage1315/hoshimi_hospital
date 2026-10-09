extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")

var checks := 0
var failures := 0
var content = Loader.new()
var game

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func expect_multiplier(actor_id: String, expected: float, context: String) -> void:
	expect(is_equal_approx(game.familiarity_gain_multiplier(actor_id), expected), "%s: expected %.2f for %s, got %.2f" % [actor_id, expected, context, game.familiarity_gain_multiplier(actor_id)])

func set_attribute(attribute: String, value: int) -> void:
	expect(game.set_test_player_attribute(attribute, value), "Could not set test attribute " + attribute)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all("zh_CN"), "Content load failed")
	game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events)

	for person in content.collections.staff:
		var actor_id := str(person.get("id", ""))
		if not person.has("familiarity_rules"):
			expect_multiplier(actor_id, 1.0, "default familiarity curve")
		else:
			expect(person.get("familiarity_rules", {}).has("base"), actor_id + " has incomplete familiarity_rules")
		expect(not person.has("familiarity_gain_multiplier"), actor_id + " still uses the retired familiarity field")

	var fixed_curves := {
		"doc_aoi": 0.8,
		"doc_asuka": 1.0,
		"doc_sakura_anesthesiology": 1.0,
		"doc_sayaka": 1.8,
		"doc_shiori": 0.85,
		"nurse_ange": 1.0,
		"nurse_haru": 0.9,
		"nurse_ishigami": 1.0,
		"pharmacist_manami": 1.3,
		"visiting_futaba": 1.0,
		"visiting_maya": 1.0,
	}
	for actor_id in fixed_curves:
		expect_multiplier(actor_id, float(fixed_curves[actor_id]), "fixed curve")

	for row in [
		[-100, 1.0], [59, 1.0], [60, 1.05], [69, 1.05], [70, 1.10],
		[79, 1.10], [80, 1.15], [89, 1.15], [90, 1.20], [100, 1.20],
	]:
		set_attribute("skill", int(row[0]))
		expect_multiplier("doc_rei", float(row[1]), "Surgery %s" % row[0])

	for row in [
		[0, 0.75], [59, 0.75], [60, 0.80], [69, 0.80], [70, 0.90],
		[79, 0.90], [80, 1.00], [89, 1.00], [90, 1.10], [100, 1.10],
	]:
		set_attribute("leadership", int(row[0]))
		expect_multiplier("doc_artoria", float(row[1]), "Leadership %s" % row[0])

	for row in [
		[-200, 1.30], [-170, 1.30], [-169, 1.20], [-120, 1.20], [-119, 1.05],
		[-60, 1.05], [-59, 0.90], [-30, 0.90], [-29, 0.75], [29, 0.75],
		[30, 0.60], [59, 0.60], [60, 0.50], [200, 0.50],
	]:
		set_attribute("presence", int(row[0]))
		expect_multiplier("nurse_satsuki", float(row[1]), "Presence %s" % row[0])

	var level_curves := {
		"doc_minato": [1.20, 1.20, 0.90, 1.10, 1.25, 1.25],
		"nurse_hiroko": [1.0, 0.8, 0.65, 0.5, 1.25, 1.25],
		"nurse_rin": [1.0, 0.9, 0.75, 0.6, 0.6, 0.6],
		"nurse_moe": [0.6, 0.8, 1.0, 1.25, 1.5, 1.5],
		"nurse_yui": [1.0, 1.0, 1.0, 0.75, 0.75, 0.75],
	}
	for actor_id in level_curves:
		for level in range(6):
			game.relation_for(actor_id).level = level
			expect_multiplier(actor_id, float(level_curves[actor_id][level]), "completed relationship Lv%s" % level)

	for row in [
		[0, 0.50], [5, 0.50], [6, 0.70], [9, 0.70], [10, 0.90], [14, 0.90],
		[15, 1.05], [19, 1.05], [20, 1.20], [29, 1.20], [30, 1.35], [100, 1.35],
	]:
		expect(game.set_test_character_progress_counter("", "gynecology_case_count", int(row[0])), "Could not set gynecology case count")
		expect_multiplier("doc_aqua", float(row[1]), "%s gynecology cases" % row[0])

	var surgery_bonuses := [[59, 0.0], [60, 0.1], [69, 0.1], [70, 0.2], [79, 0.2], [80, 0.3], [89, 0.3], [90, 0.4], [100, 0.4]]
	var presence_bonuses := [[-100, 0.0], [0, 0.0], [1, 0.1], [19, 0.1], [20, 0.15], [29, 0.15], [30, 0.2], [59, 0.2], [60, 0.3], [100, 0.3]]
	for surgery_row in surgery_bonuses:
		for presence_row in presence_bonuses:
			set_attribute("skill", int(surgery_row[0]))
			set_attribute("presence", int(presence_row[0]))
			var expected := clampf(0.5 + float(surgery_row[1]) + float(presence_row[1]), 0.5, 1.2)
			expect_multiplier("doc_emiko", expected, "Surgery %s / Presence %s" % [surgery_row[0], presence_row[0]])

	set_attribute("skill", 50)
	set_attribute("leadership", 50)
	set_attribute("presence", 0)
	expect(game.surgery_familiarity_reward("doc_sayaka") == 9, "Sayaka routine-surgery reward did not round 5 × 1.80 to 9")
	expect(game.date_familiarity_reward("doc_shiori") == 9, "Shiori date reward did not round 10 × 0.85 to 9")
	expect(game.surgery_familiarity_reward("doc_emiko") == 3, "Emiko baseline routine-surgery reward did not round 5 × 0.50 to 3")
	expect(game.date_familiarity_reward("nurse_haru") == 9, "Nanase date reward did not apply the fixed 0.90 curve")

	print("FAMILIARITY MATRIX: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
