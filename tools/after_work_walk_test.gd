extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")

var content = Loader.new()
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func new_game() -> RefCounted:
	var game = Game.new()
	game.configure(
		content.collections.encounters,
		content.collections.preops,
		content.collections.staff,
		content.collections.time_events,
		content.collections.surgeries,
		content.collections.patients,
		content.collections.relationships,
		content.collections.character_events,
		content.collections.case_templates,
		content.collections.micro_events
	)
	return game

func find_completed_walk(variant: String) -> RefCounted:
	for seed in range(1, 2000):
		var game = new_game()
		game.meet_staff("nurse_haru")
		game.campaign_seed = seed
		var departure_clock := 19 * 60 if variant == "night" else 16 * 60
		if not game.begin_after_work_departure(1, departure_clock, false):
			continue
		var result: Dictionary = game.choose_after_work_walk(true)
		if str(result.get("outcome", "")) == "completed":
			return game
	return null

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var clinic_game = new_game()
	clinic_game.advance_story_to_day(1, 15 * 60 + 59)
	expect(not clinic_game.outpatient_closed(), "Outpatient intake closed before 16:00")
	clinic_game.advance_story_to_day(1, 16 * 60)
	expect(clinic_game.outpatient_closed(), "Outpatient intake remained open at 16:00")
	expect(clinic_game.open_visit("visit_sora") == null, "A new ordinary visit started after outpatient close")
	expect(clinic_game.last_error == "今天的会诊已经结束了。", "Outpatient close did not use the requested nurse message")
	expect(clinic_game.can_end_workday(), "A free player could not end work at 16:00")

	var normal_game = find_completed_walk("normal")
	expect(normal_game != null, "Could not produce a deterministic accepted normal walk")
	if normal_game != null:
		expect(not normal_game.can_save_progress(), "Saving was allowed during an after-work walk")
		expect(int(normal_game.relation_for("nurse_haru").familiarity) == 2, "Normal walk did not grant fixed +2 familiarity")
		var completed: Dictionary = normal_game.finish_after_work_walk()
		expect(not completed.is_empty(), "Normal walk could not be finalized")
		expect(normal_game.after_work_candidates(2).is_empty(), "The offered actor ignored the two-workday cooldown on D+1")
		expect(normal_game.after_work_candidates(3).has("nurse_haru"), "The offered actor did not return on D+2")
		normal_game.advance_story_to_day(8, 9 * 60)
		expect(int(normal_game.relation_for("nurse_haru").familiarity) == 2, "Familiarity fell after one in-game week")
		var snapshot: Dictionary = normal_game.snapshot()
		var restored = new_game()
		expect(restored.restore(JSON.parse_string(JSON.stringify(snapshot))), "After-work cooldown save did not restore")
		expect(int(restored.relation_for("nurse_haru").familiarity) == 2, "Familiarity fell after save restore")
		expect(restored.after_work_last_offer_day("nurse_haru") == 1, "Cooldown marker was lost after save restore")

	var night_game = find_completed_walk("night")
	expect(night_game != null, "Could not produce a deterministic accepted night walk")
	if night_game != null:
		expect(str(night_game.active_after_work_walk.variant) == "night", "19:00 did not select night presentation")
		expect(int(night_game.relation_for("nurse_haru").familiarity) == 4, "Night walk did not grant fixed +4 familiarity")

	var roll_game = new_game()
	var normal_no_offer := 0
	var night_no_offer := 0
	for seed in range(1, 1001):
		roll_game.campaign_seed = seed
		if roll_game.after_work_roll(12, "normal", "trigger") < 20:
			normal_no_offer += 1
		if roll_game.after_work_roll(12, "night", "trigger") < 40:
			night_no_offer += 1
	expect(normal_no_offer > 150 and normal_no_offer < 250, "Normal no-offer roll is not approximately 20 percent")
	expect(night_no_offer > 350 and night_no_offer < 450, "Night no-offer roll is not approximately 40 percent")

	print("AFTER WORK WALK: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
