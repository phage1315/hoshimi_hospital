extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func configured_game(content):
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions, content.collections.palpation_profiles)
	return game

func run() -> void:
	var content = Loader.new()
	expect(content.load_all(), "Content load failed")
	var source = configured_game(content)
	source.meet_staff("doc_emiko")
	source.relation_for("doc_emiko").familiarity = 40
	source.set_test_character_progress_counter("global", "gynecology_case_count", 15)
	var current_snapshot: Dictionary = source.snapshot()
	var current_clone = configured_game(content)
	expect(current_clone.restore(current_snapshot), "Current relationship save did not round-trip")
	expect(current_clone.character_progress_counter("global", "gynecology_case_count") == 15, "Current save lost relationship counters")
	expect(str(current_clone.relationship_rank_slot("doc_emiko", 3).content_status) == "planned", "Current content placeholder metadata was not rebuilt on load")

	var counterless_snapshot: Dictionary = current_snapshot.duplicate(true)
	counterless_snapshot.erase("character_progress_counters")
	var counterless_clone = configured_game(content)
	expect(counterless_clone.restore(counterless_snapshot), "Version 35 save without new relationship counters was rejected")
	expect(counterless_clone.character_progress_counter("global", "gynecology_case_count") == 0, "Missing relationship counters did not migrate to zero")
	expect(int(counterless_clone.relation_for("doc_emiko").familiarity) == 40, "Counter migration changed existing relationship progress")

	var unsupported_old: Dictionary = current_snapshot.duplicate(true)
	unsupported_old.version = Game.MIN_SUPPORTED_SAVE_VERSION - 1
	var old_clone = configured_game(content)
	expect(not old_clone.restore(unsupported_old) and old_clone.last_error.contains("版本不兼容"), "Unsupported pre-policy save version was accepted")
	var future_snapshot: Dictionary = current_snapshot.duplicate(true)
	future_snapshot.version = Game.SAVE_VERSION + 1
	var future_clone = configured_game(content)
	expect(not future_clone.restore(future_snapshot) and future_clone.last_error.contains("版本不兼容"), "Unknown future save version was accepted")

	print("RELATIONSHIP RELEASE COMPATIBILITY: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
