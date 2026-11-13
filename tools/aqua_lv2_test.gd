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

func run() -> void:
	for path in [
		"assets/characters/story_guest_serena_v1/ward/neutral.png",
		"assets/characters/story_guest_serena_v1/ward/flustered.png",
		"assets/characters/story_guest_serena_v1/operating_table/tense.png",
		"assets/characters/story_guest_serena_v1/operating_table/pain.png",
		"assets/events/character_events/aqua/aqua_lv2_open_pelvic_field.png",
		"assets/events/character_events/aqua/aqua_lv2_open_pelvic_field_02.png",
	]:
		var tex := load("res://" + path) as Texture2D
		expect(tex != null, "Missing or unreadable asset: " + path)

	for locale in ["zh_CN", "en"]:
		run_locale_suite(locale, 0)
		run_locale_suite(locale, 1)

	print("AQUA LV2 TEST: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

func complete_short_event(game: RefCounted, event_id: String) -> bool:
	var ev = game.start_character_event(event_id)
	if ev == null:
		return false
	var guard := 0
	while not ev.completed and guard < 100:
		guard += 1
		if not game.choose_character_event(str(ev.current().choices[0].id)):
			return false
	game.finish_character_event()
	return ev.completed

func run_locale_suite(locale: String, option_index: int) -> void:
	var content = Loader.new()
	expect(content.load_all(locale), "Content load failed for " + locale)
	var data: Dictionary = content.collections
	var game = Game.new()
	game.configure(
		data.encounters,
		data.preops,
		data.staff,
		data.time_events,
		data.surgeries,
		data.patients,
		data.relationships,
		data.character_events
	)

	var lv2: Dictionary = game.character_event_definitions.get("aqua_lv2_want_to_learn", {})
	expect(not lv2.is_empty(), "aqua_lv2_want_to_learn missing in " + locale)
	expect(int(lv2.get("nodes", []).size()) == 314, "Expected 314 nodes in " + locale)

	# Complete intro & Lv1 on Day 1
	game.set_test_character_progress_counter("global", "gynecology_case_count", 5)
	expect(complete_short_event(game, "aqua_intro_exam_chair"), "Intro failed in " + locale)
	expect(complete_short_event(game, "aqua_lv1_gyne_obsession"), "Lv1 failed in " + locale)
	expect(game.relationship_level("doc_aqua") == 1, "Expected Lv1 after aqua_lv1_gyne_obsession")
	expect(not game.unlocked_procedure_ids.has("surgery_hysterectomy"), "surgery_hysterectomy must be locked before Lv2")

	# Verify gates: cooldown (3 days), familiarity (25), gynecology_case_count (10), skill (60)
	game.relation_for("doc_aqua").familiarity = 25
	game.set_test_character_progress_counter("global", "gynecology_case_count", 10)
	game.surgery_xp = game.surgery_xp_for_level(60)
	expect(not game.character_event_available(lv2), "Cooldown gate (3 days) should block Lv2 on same day")

	game.story_time_advance_minutes += 3 * game.SHIFT_MINUTES
	game.relation_for("doc_aqua").familiarity = 24
	expect(not game.character_event_available(lv2), "Familiarity < 25 should block Lv2")
	game.relation_for("doc_aqua").familiarity = 25

	game.set_test_character_progress_counter("global", "gynecology_case_count", 9)
	expect(not game.character_event_available(lv2), "gynecology_case_count < 10 should block Lv2")
	game.set_test_character_progress_counter("global", "gynecology_case_count", 10)

	game.surgery_xp = game.surgery_xp_for_level(59)
	expect(not game.character_event_available(lv2), "skill < 60 should block Lv2")
	game.surgery_xp = game.surgery_xp_for_level(60)

	expect(game.character_event_available(lv2), "All Lv2 gates satisfied; event should be available in " + locale)

	# Start and walk through all beats
	var session = game.start_character_event("aqua_lv2_want_to_learn")
	expect(session != null, "Failed to start aqua_lv2_want_to_learn in " + locale)
	expect(not game.can_save_progress(), "Save must be locked while aqua_lv2_want_to_learn is active")

	var steps := 0
	var choices_seen := 0
	while not session.completed and steps < 400:
		steps += 1
		var current_node: Dictionary = session.current()
		var choices: Array = current_node.get("choices", [])
		expect(not choices.is_empty(), "Empty choices at " + str(current_node.get("id", "")))
		var pick_idx := 0
		if choices.size() == 2:
			choices_seen += 1
			pick_idx = option_index
		var choice_id := str(choices[pick_idx].id)
		expect(game.choose_character_event(choice_id), "Failed choice " + choice_id)

	expect(session.completed, "Session did not complete in " + locale)
	expect(choices_seen == 3, "Expected 3 two-option choices on path, saw " + str(choices_seen))
	game.finish_character_event()

	# Verify post-completion state
	expect(game.relationship_level("doc_aqua") == 2, "Aqua should reach Lv2 after completion")
	expect(game.relation_for("doc_aqua").unlocked_benefits.has("unlock_hysterectomy_and_manipulator"), "Missing Lv2 benefit unlock_hysterectomy_and_manipulator")
	expect(game.story_flag("aqua_hysterectomy_teaching_complete"), "Missing story flag aqua_hysterectomy_teaching_complete")
	expect(game.story_flag("aqua_manipulator_teaching_complete"), "Missing story flag aqua_manipulator_teaching_complete")
	expect(game.unlocked_procedure_ids.has("surgery_hysterectomy"), "surgery_hysterectomy should unlock after Aqua Lv2")

	# Verify BoundarySave v37 persistence without inner event state
	var saved: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
	var raw_json := JSON.stringify(saved)
	expect(not raw_json.contains("aqlv2_009"), "Save must not persist internal beat IDs")
	var restored = Game.new()
	restored.configure(
		data.encounters,
		data.preops,
		data.staff,
		data.time_events,
		data.surgeries,
		data.patients,
		data.relationships,
		data.character_events
	)
	expect(restored.restore(saved), "Restore failed after Aqua Lv2")
	expect(restored.relationship_level("doc_aqua") == 2, "Restored Aqua Lv2 level mismatch")
	expect(restored.story_flag("aqua_hysterectomy_teaching_complete"), "Restored story flag aqua_hysterectomy_teaching_complete missing")
	expect(restored.story_flag("aqua_manipulator_teaching_complete"), "Restored story flag aqua_manipulator_teaching_complete missing")
	expect(restored.unlocked_procedure_ids.has("surgery_hysterectomy"), "Restored surgery_hysterectomy unlock missing")
