extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Progression = preload("res://godot/systems/progression_config.gd")

# Supply settlement inputs without coupling this balance test to OR choices.
class Settlement extends RefCounted:
	var procedure_mismatch := false
	var surgery_success := true
	var flags: Array[String] = []
	var grade := "S"
	func pilot_surgery() -> bool:
		return true
	func surgical_quality_grade() -> String:
		return grade

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
	var previous := 2
	for difficulty in range(0, 101):
		var award := Progression.ordinary_surgery_reputation(difficulty)
		expect(award >= previous and award >= 2 and award <= 15, "Non-monotonic or unbounded ordinary reputation at %s" % difficulty)
		previous = award
	for locale in ["zh_CN", "en"]:
		var content = Loader.new()
		expect(content.load_all(locale), "Content load failed: " + locale)
		var game = Game.new()
		game.configure([])
		game.surgery_definitions = content.collections.surgeries
		var ordinary_count := 0
		for surgery in game.surgery_definitions:
			if str(surgery.get("case_pool", "")) == "advanced_referral" or str(surgery.get("catalog_visibility", "")) == "advanced_referral":
				continue
			ordinary_count += 1
			var id := str(surgery.id)
			var profile: Dictionary = game.surgery_reputation_profile(id)
			var base: int = game.surgery_reputation_award_for(id, 0)
			expect(base >= 2 and base <= 15, "Ordinary case received referral rewards: " + id)
			expect(game.surgery_reputation_award_for(id, int(profile.cap)) == 0, "Cumulative cap failed: " + id)
			expect(game.surgery_reputation_award_for(id, int(profile.soft_cap)) == ceili(base * 0.5), "Soft cap failed: " + id)
			for grade in ["S", "A", "B", "C", "F"]:
				var prep = Settlement.new()
				prep.grade = grade
				game.archived_player_effects.reputation = 0
				var awarded: int = game.award_surgery_reputation(id, str(surgery.name), prep)
				expect(awarded >= 0 and awarded <= 15 and int(game.player_attributes().reputation) == awarded, "Quality settlement exceeded per-case cap: " + id + "/" + grade)
				game.archived_player_effects.reputation = int(profile.cap) - 1
				game.award_surgery_reputation(id, str(surgery.name), prep)
				expect(int(game.player_attributes().reputation) <= int(profile.cap), "Quality bonus bypassed cumulative cap: " + id)
			var sweep = Settlement.new()
			sweep.flags.append("quick_surgery")
			game.archived_player_effects.reputation = 0
			expect(game.award_surgery_reputation(id, str(surgery.name), sweep) == base, "Sweep did not use ordinary base: " + id)
			expect(game.surgery_reputation_award_for(id, 0) == base, "Settlement mutated base reward: " + id)
		expect(ordinary_count == 31, "Unexpected ordinary catalog size")
		expect(game.surgery_reputation_award_for("surgery_appendix", 0) == 2, "Appendectomy must remain +2")
		expect(game.surgery_reputation_award_for("surgery_open_partial_nephrectomy", 0) == 12, "Partial nephrectomy expected +12")
		expect(game.surgery_reputation_award_for("surgery_open_whipple", 0) == 15, "Highest ordinary difficulty must reach +15")
		expect(game.surgery_reputation_award_for("surgery_adv_artificial_heart_exchange", 0) == 75, "Referral reward changed")
		game.surgery_definitions.append({"id": "placeholder_test", "status": "placeholder", "base_difficulty": 95})
		expect(game.surgery_reputation_award_for("placeholder_test", 0) == 0 and game.surgery_reputation_award_for("missing", 0) == 0, "Placeholder or missing procedure gained reputation")
		var wrong = Settlement.new()
		wrong.procedure_mismatch = true
		game.archived_player_effects.reputation = 0
		expect(game.award_surgery_reputation("surgery_open_whipple", "", wrong) == -75, "Wrong-procedure penalty changed")
		var awake = Settlement.new()
		awake.flags.append("no_anesthesia_confirmed")
		game.archived_player_effects.reputation = 0
		expect(game.award_surgery_reputation("surgery_appendix", "", awake) == -8, "No-anesthesia penalty changed")
	print("ORDINARY REPUTATION: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
