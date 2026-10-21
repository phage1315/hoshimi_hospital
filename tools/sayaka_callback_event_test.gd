extends SceneTree
## Date/scheduling regression test for the three post-Lv5 callback events.
## Run with: godot --headless --path . --script res://tools/sayaka_callback_event_test.gd

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")

const EVENT_B := "sayaka_lv5_part_b"
const EVENT_C := "sayaka_lv5_part_c"
const EVENT_1 := "sayaka_staff_patient_callback_01"
const EVENT_2 := "sayaka_staff_patient_callback_02"
const EVENT_3 := "sayaka_staff_patient_callback_03"
const SHIFT_START := 9 * 60

var checks := 0
var failures := 0
var content = Loader.new()

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func configure_game(game: GameState) -> void:
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
		content.collections.micro_events,
		content.collections.examination_cg_pools,
		content.collections.surgery_team_dialogue_profiles,
		content.collections.patient_interactions,
		content.collections.temporary_conditions,
		content.collections.staff_role_cg_rewards,
		content.collections.special_events,
		content.collections.special_event_steps,
		content.collections.date_profiles,
		content.collections.date_locations,
		content.collections.advanced_referral_cases,
		content.collections.first_surgery_diagnosis_reactions,
		content.collections.palpation_profiles
	)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content loader failed: " + str(content.errors))
	if failures > 0:
		finish()
		return
	var game := GameState.new()
	configure_game(game)
	var definitions := game.special_event_definitions
	var steps := game.special_event_step_definitions
	for event_id in [EVENT_1, EVENT_2, EVENT_3]:
		expect(definitions.has(event_id), "Missing callback definition: " + event_id)
	var expected_counts := {"sayaka_staff_patient_callback_01_main": 25, "sayaka_staff_patient_callback_02_main": 41, "sayaka_staff_patient_callback_03_main": 32}
	for step_id in expected_counts:
		var step: Dictionary = steps.get(step_id, {})
		expect(not step.is_empty(), "Missing callback step: " + step_id)
		expect(step.get("nodes", []).size() == int(expected_counts[step_id]), "Wrong authored node count in " + step_id)
	var first_step: Dictionary = steps.get("sayaka_staff_patient_callback_01_main", {})
	var first_player_focus := {}
	for node in first_step.get("nodes", []):
		if str(node.get("id", "")) == "sap01_0023":
			first_player_focus = node
	expect(bool(first_player_focus.get("hide_portrait", false)), "Sakaguchi first-person focus should not invent a portrait")
	expect(str(first_player_focus.get("background_id", "")) == "hallway", "Callback 01 should use the hallway")

	# Model Part B's night operation on day S; the full-day event's completion
	# stamp is S+1. The first eligible date S+7 must therefore be six days after
	# the stored completion date, never five.
	var surgery_day := 8
	var callback_day := surgery_day + 7
	while callback_day < 300 and str(game.day_type(callback_day)) != "saturday":
		surgery_day += 1
		callback_day = surgery_day + 7
	game.special_event_completion_counts[EVENT_B] = 1
	game.special_event_completion_days[EVENT_B] = surgery_day + 1
	game.special_event_completion_counts[EVENT_C] = 1
	game.special_event_completion_days[EVENT_C] = surgery_day + 4
	game.set_test_time(callback_day - 1, SHIFT_START)
	var first_definition: Dictionary = definitions.get(EVENT_1, {})
	expect(not game.special_event_available(first_definition), "Callback 01 unlocked before seven calendar days after surgery")
	game.set_test_time(callback_day, SHIFT_START + 1)
	expect(not game.special_event_available(first_definition), "Callback 01 triggered after the exact 09:00 slot was missed")
	game.set_test_time(callback_day, SHIFT_START)
	expect(game.special_event_available(first_definition), "Callback 01 failed to unlock at 09:00 on the first eligible workday")
	game.special_event_completion_counts[EVENT_1] = 1
	game.special_event_completion_days[EVENT_1] = callback_day
	game.set_test_time(callback_day + 1, SHIFT_START)
	var second_definition: Dictionary = definitions.get(EVENT_2, {})
	expect(str(game.day_type(callback_day + 1)) == "sunday", "Date fixture should put Callback 02 on the Sunday immediately after Callback 01")
	expect(bool(second_definition.get("timing", {}).get("sunday_start_allowed", false)), "Callback 02 does not permit an immediate Sunday follow-up")
	expect(game.special_event_base_requirements_met(second_definition), "Callback 02 did not unlock on the day after Callback 01")
	game.special_event_completion_counts[EVENT_2] = 1
	game.special_event_completion_days[EVENT_2] = callback_day + 1
	var third_definition: Dictionary = definitions.get(EVENT_3, {})
	game.set_test_time(callback_day + 1, SHIFT_START)
	expect(not game.special_event_base_requirements_met(third_definition), "Callback 03 must not run on the same day as Callback 02 or on Sunday")
	var next_workday := callback_day + 2
	while next_workday < 365 and str(game.day_type(next_workday)) not in ["weekday", "saturday"]:
		next_workday += 1
	game.set_test_time(next_workday, SHIFT_START)
	expect(game.special_event_base_requirements_met(third_definition), "Callback 03 failed to unlock on the next eligible workday")
	expect(bool(third_definition.get("completion_flags", []).has("sayaka_staff_patient_callback_complete")), "Callback 03 does not persist the chain completion flag")

	print("Sayaka callback scheduling: %s checks, %s failure(s)" % [checks, failures])
	finish(1 if failures > 0 else 0)
