extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")

var content = Loader.new()
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func configure_game(game) -> void:
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions, content.collections.palpation_profiles)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var definition: Dictionary = content.find_record("special_events", "satsuki_lv1_real_patient_test")
	var game = GameState.new()
	configure_game(game)
	expect(game.prepare_special_event_test_save(definition.id, false), "Ready-now test save could not be prepared")
	expect(game.special_event_base_requirements_met(definition), "Ready-now preset did not satisfy authored gates")
	expect(game.special_event_available(definition), "Ready-now preset was not immediately available")
	expect(game.next_auto_special_event().is_empty(), "Location-triggered Satsuki Lv1 incorrectly auto-started from the hospital map")
	expect(game.next_special_event_at("station").is_empty(), "Satsuki Lv1 appeared at the wrong hospital location")
	expect(game.next_special_event_at("gynecology_exam").get("id", "") == definition.id, "Satsuki Lv1 did not wait at the gynecology examination room")
	expect(game.can_save_progress(), "Prepared test state is not saveable")

	var delayed = GameState.new()
	configure_game(delayed)
	expect(delayed.prepare_special_event_test_save(definition.id, true), "One-surgery test save could not be prepared")
	expect(delayed.special_event_base_requirements_met(definition), "One-surgery preset lost authored gates")
	expect(not delayed.special_event_available(definition), "One-surgery preset triggered before a surgery")
	delayed.completed_surgeries_total += 1
	expect(delayed.special_event_available(definition), "One-surgery preset did not unlock after one surgery")

	var character_definition: Dictionary = content.find_record("character_events", "intro_doc_asuka_director_office")
	var character_game = GameState.new()
	configure_game(character_game)
	expect(not character_definition.is_empty(), "Character-event fixture is missing")
	expect(character_game.prepare_character_event_test_save(character_definition.id, false), "Character-event test save could not be prepared")
	expect(character_game.character_event_available(character_definition), "Character-event preset did not satisfy its authored gates")
	var delayed_character = GameState.new()
	configure_game(delayed_character)
	expect(delayed_character.prepare_character_event_test_save(character_definition.id, true), "Delayed character-event test save could not be prepared")
	expect(not delayed_character.character_event_available(character_definition), "Delayed character event triggered before a surgery")
	delayed_character.completed_surgeries_total += 1
	expect(delayed_character.character_event_available(character_definition), "Delayed character event did not unlock after one surgery")

	var overrides := {
		"player_attributes": {"skill": 63, "leadership": 61, "presence": -25, "reputation": 120, "charm": 33},
		"relationships": {"nurse_satsuki": {"met": true, "level": 2, "affection": 41, "familiarity": 48, "route": "colleague"}},
		"story_flags": {"test_custom_flag": true},
		"progress": {"completed_surgeries_total": 12},
		"special_events": {},
	}
	expect(delayed.apply_test_save_overrides(overrides), "Advanced overrides were rejected")
	for attribute in overrides.player_attributes:
		expect(int(delayed.player_attributes()[attribute]) == int(overrides.player_attributes[attribute]), "Player attribute override failed: " + str(attribute))
	expect(int(delayed.relation_for("nurse_satsuki").familiarity) == 48, "Relationship override failed")
	expect(delayed.story_flag("test_custom_flag"), "Global flag override failed")
	expect(delayed.completed_surgeries_total == 12, "Progress override failed")

	var restored = GameState.new()
	configure_game(restored)
	expect(restored.restore(delayed.snapshot()), "Generated state did not survive an official save-format round trip")
	expect(restored.story_flag("test_custom_flag") and restored.completed_surgeries_total == 12, "Generated state changed during round trip")

	print("TEST SAVE GENERATOR: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures else 0)
