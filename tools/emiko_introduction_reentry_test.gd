extends SceneTree
## Optional argument: a supplied save to read only. No player-slot discovery or writes.
const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Store = preload("res://godot/systems/save_store.gd")
const INTRO := "emiko_intro_rumored_hands"
var content = Loader.new()
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func new_game():
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions, content.collections.palpation_profiles, content.collections.awake_special_barks)
	return game

func finish_event(game, id: String) -> bool:
	var event = game.start_character_event(id)
	if event == null:
		return false
	for step in range(500):
		if event.completed:
			game.finish_character_event()
			return true
		var choices: Array = event.current().get("choices", [])
		if choices.is_empty() or not game.choose_character_event(str(choices[0].id)):
			return false
	return false

func check_reentry(game, label: String) -> void:
	var intro: Dictionary = game.character_event_definitions[INTRO]
	var before: String = JSON.stringify(game.snapshot())
	var available: bool = game.character_event_available(intro)
	expect(available, label + ": incomplete formal introduction remains available despite met=true")
	expect(game.next_character_event_at("emiko_office").get("id", "") == INTRO, label + ": office scheduler offers formal introduction")
	expect(JSON.stringify(game.snapshot()) == before, label + ": eligibility checks preserve all durable facts")
	if not available:
		return
	var old_level: int = game.relationship_level("doc_emiko")
	expect(finish_event(game, INTRO), label + ": formal introduction plays to completion")
	expect(game.staff_is_met("doc_emiko") and game.relationship_level("doc_emiko") == old_level, label + ": introduction does not reset acquaintance or rank")
	expect(not game.character_event_available(intro), label + ": completed introduction cannot repeat")
	var completed: String = JSON.stringify(game.snapshot())
	expect(game.start_character_event(INTRO) == null, label + ": direct repeated start rejected")
	expect(JSON.stringify(game.snapshot()) == completed, label + ": rejected repeat gives no time or rewards")
	var restored = new_game()
	expect(restored.restore(game.snapshot()), label + ": boundary facts restore in memory")
	expect(restored.character_event_done(INTRO) and not restored.character_event_available(restored.character_event_definitions[INTRO]), label + ": reload does not reopen completed introduction")
	if old_level != 0:
		return
	expect(not game.character_event_available(game.character_event_definitions.emiko_lv1_first_operation), label + ": Lv1 three-day delay remains")
	expect(finish_event(game, "asuka_mentions_artoria_rival"), label + ": Asuka referral becomes available")
	expect(finish_event(game, "intro_doc_artoria_deputy_office"), label + ": Artoria introduction becomes available")
	game.advance_story_to_future_day(3, 780)
	expect(finish_event(game, "emiko_lv1_first_operation"), label + ": Lv1 completes after three days")
	expect(game.relationship_level("doc_emiko") == 1, label + ": Lv1 settles once")
	expect(not game.character_event_available(game.character_event_definitions.emiko_lv2_follow_my_lead), label + ": Lv2 three-day delay remains")
	game.advance_story_to_future_day(3, 780)
	expect(finish_event(game, "emiko_lv2_follow_my_lead"), label + ": Lv2 completes after three more days")
	expect(game.relationship_level("doc_emiko") == 2, label + ": Lv2 settles once")

func run() -> void:
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Load " + locale)
		for known in [false, true]:
			var game = new_game()
			game.set_test_time(10, 600)
			game.set_test_player_attribute("skill", 70)
			game.relation_for("doc_emiko").met = known
			var intro: Dictionary = game.character_event_definitions[INTRO]
			expect(not game.character_event_available(intro), "Asuka prerequisite still required, known=" + str(known))
			expect(game._complete_character_event_for_test("intro_doc_asuka_director_office", 1), "Fixture Asuka introduction")
			game.meet_staff("doc_asuka")
			game.set_test_player_attribute("skill", 69)
			expect(not game.character_event_available(intro), "Skill 69 rejected, known=" + str(known))
			game.set_test_player_attribute("skill", 70)
			expect(game.character_events_at("station").all(func(event): return str(event.id) != INTRO), "Formal introduction does not move to nurse station")
			game.meet_staff("nurse_yui")
			expect(not game.character_event_available(game.character_event_definitions.intro_nurse_yui), "Unrelated introductions retain met guard")
			check_reentry(game, locale + " known=" + str(known))
		var args := OS.get_cmdline_user_args()
		if not args.is_empty():
			var game = new_game()
			var store = Store.new()
			store.path = args[0]
			var loaded: bool = store.read_slot(game)
			expect(loaded, "Read supplied save: " + store.last_error)
			if loaded:
				check_reentry(game, locale + " supplied save")
				expect(game.special_event_available(game.special_event_definitions.satsuki_lv2_patient_transport), "Supplied save: actual introduction chain unblocks Satsuki Lv2")
	print("EMIKO INTRODUCTION REENTRY: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
