extends "res://tools/advanced_surgery_test.gd"
const Flow = preload("res://godot/systems/miyuki_lv5.gd")
const Event = preload("res://godot/systems/character_event_session.gd")
const Registry = preload("res://godot/systems/staff_patient_registry.gd")

func prepare(g) -> void:
	g.reset()
	g.meet_staff("nurse_yui")
	g.relation_for("nurse_yui").level = 4
	g.relation_for("nurse_yui").familiarity = 75
	g.relation_for("nurse_yui").rank_history = ["miyuki_lv4_inspection"]
	var lv4 = Event.new(g.character_event_definitions["miyuki_lv4_inspection"])
	lv4.completed = true
	lv4.completed_day = 67
	g.character_events["miyuki_lv4_inspection"] = lv4
	g.character_event_order.append("miyuki_lv4_inspection")
	g.surgery_xp = g.surgery_xp_for_level(70)
	g.set_test_character_progress_counter("nurse_yui", "completed_no_anesthesia_surgeries", 1)
	g.set_story_flag("staff_as_patient_program_authorized")
	g.set_test_time(71, 540)

func play(g, event_id: String, branch_index: int = 0) -> void:
	var session = g.start_character_event(event_id)
	expect(session != null, "Start " + event_id)
	if session == null: return
	var steps := 0
	while not session.completed and steps < 200:
		var node: Dictionary = session.current()
		expect(not node.is_empty() and not str(node.get("text", "")).is_empty(), "Nonblank node " + event_id)
		expect(node.get("choices", []).size() > 0, "Choice exists " + str(node.get("id", "")))
		expect(not g.can_save_progress() and g.snapshot().is_empty(), "No in-event save")
		if node.get("choices", []).is_empty(): break
		var choice_index := mini(branch_index, node.choices.size() - 1)
		expect(g.choose_character_event(str(node.choices[choice_index].id)), "Advance " + str(node.get("id", "")))
		steps += 1
	expect(session.completed and steps < 200, "Reached end " + event_id)
	g.finish_character_event()

func verify_part_a_cgs(g) -> void:
	var expected_ranges := [
		{"start": 2, "end": 5, "path": "assets/events/character_events/miyuki/lv5_story/cg/chie_or_arrival_v1.png"},
		{"start": 34, "end": 45, "path": "assets/events/character_events/miyuki/lv5_story/cg/chie_preincision_controller_reveal_sfw_v1.png"},
		{"start": 46, "end": 46, "path": "assets/events/character_events/miyuki/lv5_story/cg/chie_controller_handoff_splash_sfw_v1.png"},
		{"start": 55, "end": 56, "path": "assets/events/character_events/miyuki/lv5_story/cg/chie_first_incision_closeup_v1.png"},
		{"start": 58, "end": 67, "path": "assets/events/character_events/miyuki/lv5_story/cg/chie_open_abdomen_endurance_sfw_v1.png"},
		{"start": 70, "end": 72, "path": "assets/events/character_events/miyuki/lv5_story/cg/chie_postop_controller_recovery_sfw_v3.png"},
	]
	var definition: Dictionary = g.character_event_definitions[Flow.A]
	var cg_nodes := 0
	for node in definition.get("nodes", []):
		var number := int(str(node.get("id", "")).trim_prefix("n").split("_")[0])
		var expected_path := ""
		for entry in expected_ranges:
			if number >= int(entry.start) and number <= int(entry.end):
				expected_path = str(entry.path)
				break
		var actual_path := str(node.get("cg_path", ""))
		expect(actual_path == expected_path, "Part A CG mapping " + str(node.get("id", "")))
		if not actual_path.is_empty():
			cg_nodes += 1
			expect(ResourceLoader.exists("res://" + actual_path), "Part A CG loads " + actual_path)
	expect(cg_nodes == 32, "All 32 Part A CG-backed runtime pages mapped")

func verify_part_b_cgs(g) -> void:
	var expected_ranges := [
		{"start": 91, "end": 95, "path": "assets/events/character_events/miyuki/lv5_story/cg/miyuki_b1_or_door_invitation_sfw_v1.png"},
		{"start": 102, "end": 108, "path": "assets/events/character_events/miyuki/lv5_story/cg/miyuki_b2_patient_view_demonstration_sfw_v1.png"},
		{"start": 109, "end": 126, "path": "assets/events/character_events/miyuki/lv5_story/cg/miyuki_b3_surgical_lamp_confession_sfw_v1.png"},
		{"start": 131, "end": 145, "path": "assets/events/character_events/miyuki/lv5_story/cg/miyuki_b5_true_surgery_request_sfw_v1.png"},
		{"start": 146, "end": 149, "path": "assets/events/character_events/miyuki/lv5_story/cg/miyuki_b6_departure_promise_sfw_v1.png"},
	]
	var definition: Dictionary = g.character_event_definitions[Flow.B]
	var cg_nodes := 0
	for node in definition.get("nodes", []):
		var number := int(str(node.get("id", "")).trim_prefix("n").split("_")[0])
		var expected_path := ""
		for entry in expected_ranges:
			if number >= int(entry.start) and number <= int(entry.end):
				expected_path = str(entry.path)
				break
		var actual_path := str(node.get("cg_path", ""))
		expect(actual_path == expected_path, "Part B CG mapping " + str(node.get("id", "")))
		if not actual_path.is_empty():
			cg_nodes += 1
			expect(ResourceLoader.exists("res://" + actual_path), "Part B CG loads " + actual_path)
	# The authored B4 fade-to-black block (127-130) intentionally has no SFW CG.
	expect(cg_nodes == 59, "All 59 Part B SFW CG-backed runtime pages mapped")

func run() -> void:
	var g = new_game()
	prepare(g)
	verify_part_a_cgs(g)
	verify_part_b_cgs(g)
	expect(g.character_event_available(g.character_event_definitions[Flow.A]), "Full Lv5 gate admits A")
	expect(not g.character_event_available(g.character_event_definitions[Flow.B]), "B waits for A")
	expect(not g.staff_patient_unlocked("nurse_yui"), "Lv4 cannot invite Miyuki")
	var xp: int = g.surgery_xp
	var operations: int = g.completed_surgeries_total
	play(g, Flow.A)
	expect(g.story_flag("asakura_chie_no_anesthesia_special_complete") and g.story_flag("asakura_lv5_part_b_pending"), "A queues B")
	expect(g.character_progress_counter("nurse_yui", "completed_no_anesthesia_surgeries") == 2, "A credits one no-anesthesia team case")
	expect(g.surgery_xp == xp and g.completed_surgeries_total == operations and g.relationship_level("nurse_yui") == 4, "No ordinary surgery reward or premature rank")
	expect(g.current_absolute_clock() == 840, "A settles at 14:00")
	# set_test_time adjusts the story clock; the completed A adds its own 300-minute ledger fact.
	g.set_test_time(72, 720)
	g.pending_day_exit_workday = 72
	g.pending_day_exit_clock = 1020
	expect(g.character_event_available(g.character_event_definitions[Flow.B]), "B next workday, without rechecking Lv5 numbers")
	g.relation_for("nurse_yui").familiarity = 0
	g.surgery_xp = 0
	expect(g.character_event_available(g.character_event_definitions[Flow.B]), "B ignores later numeric drift")
	play(g, Flow.B)
	expect(g.relationship_level("nurse_yui") == 5 and g.staff_patient_unlocked("nurse_yui"), "B unlocks real Staff-as-Patient entry")
	expect(not g.story_flag("asakura_lv5_part_b_pending") and g.story_flag("asakura_lv5_epilogue_pending"), "B queues C")
	g.set_test_time(73, 540)
	g.pending_day_exit_workday = 0
	g.pending_day_exit_clock = 0
	expect(g.character_event_available(g.character_event_definitions[Flow.C]), "C next workday")
	play(g, Flow.C)
	expect(g.story_flag("asakura_lv5_epilogue_complete") and not g.story_flag("asakura_lv5_epilogue_pending"), "C clears queue")
	expect(g.relationship_level("nurse_yui") == 5, "C awards no duplicate rank")
	expect(g.can_invite_staff_patient("nurse_yui"), "Actual invitation entry available at Lv5")
	var available_procedures: Array = g.staff_patient_available_procedures()
	expect(not available_procedures.is_empty(), "At least one procedure available for invitation")
	if not available_procedures.is_empty():
		var procedure_id: String = str(available_procedures[0].get("id", ""))
		expect(g.invite_staff_patient("nurse_yui", procedure_id), "Actual invitation opens shared preop")
		expect(str(g.active_staff_patient.get("staff_id", "")) == "nurse_yui", "Admission identifies Miyuki")
	var profile: Dictionary = Registry.profile("nurse_yui")
	expect(profile.get("required_completed_rank", 0) == 5, "Profile requires Lv5")
	var patient_record: Dictionary = Registry.patient_record(g.staff_record("nurse_yui"), "zh_CN")
	var portraits: Dictionary = patient_record.get("visuals", {}).get("portraits", {})
	var ward_prep_path := "assets/characters/relationship_patient_v1/nurse_yui/ward_preparation/shy.png"
	expect(str(portraits.get("ward_preparation/shy", "")) == ward_prep_path and str(portraits.get("examination/shy", "")) == ward_prep_path, "Author ward preparation portrait and shared alias")
	expect(ResourceLoader.load("res://" + ward_prep_path) != null, "Author ward preparation PNG loads in Godot")
	expect(ResourceLoader.load("res://assets/characters/advanced_staff_patient_v1/nurse_yui/chest.png") != null, "Author chest operating table PNG loads in Godot")
	for locale in ["zh_CN", "en"]:
		var dialogue: Dictionary = Registry.dialogue("nurse_yui", locale)
		expect(dialogue.get("reaction_lines", {}).size() == 28, "28 reactions " + locale)
		expect(dialogue.get("reaction_variants", {}).size() == 13, "13 variant groups " + locale)
		expect(dialogue.get("interaction_overrides", {}).size() == 50, "50 connected pools " + locale)
		var traction: Dictionary = dialogue.get("interaction_overrides", {}).get("strain_pain_traction_02", {})
		expect(not str(traction.get("prompt", "")).is_empty() and traction.get("responses", {}).size() == 2, "Second traction pool and both actions " + locale)
		expect(not g.staff_patient_preop_definition({"staff_id": "nurse_yui", "procedure_id": "surgery_appendix"}).is_empty(), "Real preop adapter " + locale)
	var alternative = new_game()
	prepare(alternative)
	play(alternative, Flow.A, 1)
	alternative.set_test_time(72, 720)
	alternative.pending_day_exit_workday = 72
	alternative.pending_day_exit_clock = 1020
	play(alternative, Flow.B, 1)
	expect(alternative.staff_patient_unlocked("nurse_yui"), "Alternative choices preserve Lv5 unlock")
	alternative.set_test_time(73, 540)
	alternative.pending_day_exit_workday = 0
	alternative.pending_day_exit_clock = 0
	play(alternative, Flow.C, 1)
	expect(alternative.story_flag("asakura_lv5_epilogue_complete"), "Alternative choices reach epilogue")
	print("MIYUKI LV5: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
