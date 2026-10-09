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

func set_gate_position(game, actor_id: String, target_level: int, familiarity: int) -> Dictionary:
	var relation: Dictionary = game.relation_for(actor_id)
	relation.met = true
	relation.level = target_level - 1
	relation.familiarity = familiarity
	relation.rank_history = []
	return relation

func run() -> void:
	var content = Loader.new()
	expect(content.load_all(), "Content load failed")
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events)

	var expected_thresholds := {
		"doc_rei": [10, 25, 40, 55, 75], "doc_emiko": [10, 25, 40, 55, 75],
		"doc_artoria": [0, 25, 40, 55, 75], "nurse_ishigami": [0, 0, 0, 0, 0],
		"doc_asuka": [10, 25, 40, 55, 75], "doc_sayaka": [0, 25, 40, 55, 70],
		"nurse_satsuki": [10, 25, 40, 55, 70], "nurse_hiroko": [10, 25, 40, 55, 75],
		"doc_aqua": [10, 25, 40, 55, 75], "nurse_rin": [10, 25, 40, 55, 75],
		"nurse_moe": [10, 25, 40, 55, 75], "doc_aoi": [10, 25, 40, 55, 75],
		"nurse_haru": [10, 25, 40, 55, 75], "doc_shiori": [10, 25, 40, 55, 75],
		"pharmacist_manami": [10, 25, 40, 55, 75], "nurse_yui": [10, 25, 40, 55, 75],
		"nurse_ange": [10, 25, 40, 55, 75],
	}
	for actor_id in expected_thresholds:
		var slots: Array = game.relation_for(actor_id).rank_slots
		expect(slots.map(func(slot): return int(slot.min_familiarity)) == expected_thresholds[actor_id], actor_id + ": familiarity gate matrix mismatch")
		expect(slots.all(func(slot): return int(slot.cooldown_days) == 3), actor_id + ": cooldown is not fixed at three days")
	expect(game.relationship_max_level("nurse_ishigami") == 5, "Ishigami's audited professional-trust route is still progression-locked")

	set_gate_position(game, "doc_emiko", 1, 9)
	game.set_test_player_attribute("skill", 100)
	expect(not game.relationship_rank_gate_met("doc_emiko", 1), "Emiko Lv1 ignored Familiarity 10")
	game.relation_for("doc_emiko").familiarity = 10
	game.set_test_player_attribute("skill", 74)
	expect(not game.relationship_rank_gate_met("doc_emiko", 1), "Emiko Lv1 accepted Surgery 74")
	game.set_test_player_attribute("skill", 75)
	expect(game.relationship_rank_gate_met("doc_emiko", 1), "Emiko Lv1 rejected the exact Surgery 75 boundary")

	set_gate_position(game, "doc_emiko", 3, 40)
	game.set_test_player_attribute("presence", 19)
	expect(not game.relationship_rank_gate_met("doc_emiko", 3), "Emiko Lv3 accepted Presence +19")
	game.set_test_player_attribute("presence", 20)
	expect(game.relationship_rank_gate_met("doc_emiko", 3), "Emiko Lv3 rejected Presence +20")

	set_gate_position(game, "nurse_satsuki", 3, 40)
	game.set_test_player_attribute("skill", 55)
	game.set_test_player_attribute("presence", -29)
	expect(not game.relationship_rank_gate_met("nurse_satsuki", 3), "Satsuki Lv3 accepted Presence -29")
	game.set_test_player_attribute("presence", -30)
	expect(game.relationship_rank_gate_met("nurse_satsuki", 3), "Satsuki Lv3 rejected Presence -30 and Surgery 55")

	set_gate_position(game, "doc_shiori", 3, 40)
	game.set_test_player_attribute("skill", 65)
	game.set_test_player_attribute("charm", 29)
	expect(not game.relationship_rank_gate_met("doc_shiori", 3), "Shiori Lv3 accepted Charm 29")
	game.set_test_player_attribute("charm", 30)
	expect(game.relationship_rank_gate_met("doc_shiori", 3), "Shiori Lv3 rejected Surgery 65 and Charm 30")

	set_gate_position(game, "pharmacist_manami", 5, 75)
	game.set_test_character_progress_counter("pharmacist_manami", "completed_no_anesthesia_surgeries_as_assistant_surgeon", 1)
	expect(not game.relationship_rank_gate_met("pharmacist_manami", 5), "Manami Lv5 ignored her own Surgery 60 gate")
	for person in game.staff:
		if str(person.id) == "pharmacist_manami":
			person.skills.surgery = 60
	expect(game.relationship_rank_gate_met("pharmacist_manami", 5), "Manami Lv5 rejected her own Surgery 60 plus no-anesthesia assistant experience")

	game.reset()
	set_gate_position(game, "nurse_ishigami", 1, 0)
	for actor_id in ["nurse_haru", "nurse_rin"]:
		game.relation_for(actor_id).level = 2
	expect(not game.relationship_rank_gate_met("nurse_ishigami", 1), "Ishigami Lv1 accepted only two Lv2 nurses")
	game.relation_for("nurse_yui").level = 2
	expect(game.relationship_rank_gate_met("nurse_ishigami", 1), "Ishigami Lv1 rejected three other Lv2 nurses")

	var emiko_relation := set_gate_position(game, "doc_emiko", 2, 25)
	emiko_relation.rank_history = ["emiko_lv1_first_operation"]
	expect(game._complete_character_event_for_test("emiko_lv1_first_operation", 10), "Could not create completed Emiko Lv1 cooldown fixture")
	game.set_test_time(12, 540)
	expect(not game.relationship_rank_gate_met("doc_emiko", 2), "Two-day milestone gap bypassed the fixed cooldown")
	game.set_test_time(13, 540)
	expect(game.relationship_rank_gate_met("doc_emiko", 2), "Exact three-day milestone gap did not unlock")

	game.reset()
	set_gate_position(game, "doc_emiko", 1, 9)
	game.set_test_player_attribute("skill", 75)
	expect(game._complete_character_event_for_test("emiko_intro_rumored_hands", 1), "Could not create completed Emiko introduction fixture")
	game.set_test_time(4, 780)
	var emiko_lv1: Dictionary = content.find_record("character_events", "emiko_lv1_first_operation")
	expect(not game.character_event_available(emiko_lv1), "Authored character event bypassed its centralized rank-slot gate")
	game.relation_for("doc_emiko").familiarity = 10
	expect(game.character_event_available(emiko_lv1), "Authored character event stayed locked after its centralized gate passed")

	game.reset()
	game.meet_staff("doc_rei")
	game.meet_staff("doc_asuka")
	expect(game._complete_character_event_for_test("intro_doc_rei", 1), "Could not create completed Miyama introduction fixture")
	game.set_test_time(4, 540)
	game.relation_for("doc_rei").familiarity = 9
	var miyama_lv1: Dictionary = content.find_record("special_events", "miyama_01_safety_pin")
	expect(not game.special_event_base_requirements_met(miyama_lv1), "Special event bypassed its centralized rank-slot Familiarity gate")
	game.relation_for("doc_rei").familiarity = 10
	expect(game.special_event_base_requirements_met(miyama_lv1), "Special event stayed locked after its centralized gate passed")

	game.reset()
	game.meet_staff("doc_aoi")
	game.set_test_time(6, 540)
	expect(game.complete_sunday_activity("date", "doc_aoi", "park"), "Sunday date fixture did not complete")
	expect(game.character_progress_counter("doc_aoi", "completed_sunday_dates") == 1, "Sunday date did not persist the per-character route counter")

	print("RELATIONSHIP GATE MATRIX: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
