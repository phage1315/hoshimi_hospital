extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")

var content = Loader.new()
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func configure_game(game: RefCounted) -> void:
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards)

func training_prep(surgery_id: String, mismatch: bool = false) -> RefCounted:
	var prep = Preop.new(content.collections.preops[0], content.collections.staff, content.collections.surgeries, content.collections.patients)
	var surgery: Dictionary = content.find_record("surgeries", surgery_id)
	prep.procedure_id = surgery_id
	prep.procedure_name = str(surgery.name)
	prep.procedure_mismatch = mismatch
	prep.procedure_corrections = 0
	return prep

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var game = Game.new()
	configure_game(game)
	expect(game.unlocked_procedure_ids.size() == 9, "New game did not start with exactly nine procedures")
	expect(game.procedure_unlocked("surgery_appendix") and not game.procedure_unlocked("surgery_cabg"), "Starting procedure locks are incorrect")
	expect(not game.unlock_procedure("surgery_vaginal_hysterectomy"), "Placeholder procedure was unlockable")
	expect(game.procedure_catalog().size() == 26, "Procedure catalog did not include all 25 operations plus the placeholder")
	# A normal case can introduce a procedure the player has not performed yet.
	# Admission plus entry into that patient's preoperative workflow unlocks it
	# for the current operation; completion is no longer a circular prerequisite.
	var case_game = Game.new()
	configure_game(case_game)
	var case_preop_id: String = str(case_game.preop_definitions.keys()[0])
	var case_preop_definition: Dictionary = case_game.preop_definitions[case_preop_id]
	case_preop_definition.surgery_id = "surgery_open_lung_lobectomy"
	var case_visit = case_game.open_visit(str(case_preop_definition.encounter_id))
	case_visit.admitted = true
	expect(not case_game.procedure_unlocked("surgery_open_lung_lobectomy"), "Lung lobectomy unexpectedly started unlocked")
	var case_preparation = case_game.open_preop(case_preop_id)
	expect(case_preparation != null and case_game.procedure_unlocked("surgery_open_lung_lobectomy") and case_preparation.procedure_unlocked("surgery_open_lung_lobectomy"), "Admitted localized-lung-cancer case did not unlock lobectomy for its own preoperative workflow")
	var starting_cases := 0
	for template_id in game.patient_cases.values():
		if game.unlocked_procedure_ids.has(str(game.case_templates[template_id].surgery_id)):
			starting_cases += 1
	expect(starting_cases >= mini(2, content.collections.patients.size()), "Initial patient roster did not guarantee accessible surgery cases")
	var first_case: Dictionary = game.patient_case(game.current_patient_id())
	expect(game.unlocked_procedure_ids.has(str(first_case.surgery_id)), "The first waiting patient required a locked procedure")

	var appendix = training_prep("surgery_appendix")
	var cabg = training_prep("surgery_cabg")
	var wrong_cabg = training_prep("surgery_cabg", true)
	expect(game.surgery_xp_to_next_level(50) == 50, "Initial surgery level still required too many operations")
	expect(game.surgery_xp_to_next_level(70) > game.surgery_xp_to_next_level(60) * 3, "Surgery XP requirements did not accelerate toward higher levels")
	expect(game.surgery_xp_to_next_level(90) > game.surgery_xp_to_next_level(80) * 3, "Late surgery mastery curve was not substantially slower")
	expect(game.surgery_xp_award_for(appendix) == 30, "Appendectomy XP did not use duration and learning efficiency")
	expect(game.surgery_xp_award_for(cabg) == 72, "Severely over-level CABG incorrectly became a power-leveling shortcut")
	expect(game.surgery_xp_award_for(wrong_cabg) == 14, "Wrong-indication surgery did not apply the 20 percent XP multiplier")
	expect(game.surgery_reputation_profile("surgery_appendix").tier == "simple" and game.surgery_reputation_award_for("surgery_appendix", 0) == 2, "Simple surgery reputation profile is incorrect")
	expect(game.surgery_reputation_award_for("surgery_appendix", 80) == 1 and game.surgery_reputation_award_for("surgery_appendix", 100) == 0, "Simple surgery reputation soft or hard cap is incorrect")
	expect(game.surgery_reputation_profile("surgery_open_abdominal_myomectomy").tier == "standard" and game.surgery_reputation_award_for("surgery_open_abdominal_myomectomy", 0) == 2 and game.surgery_reputation_award_for("surgery_open_abdominal_myomectomy", 300) == 0, "Standard surgery reputation profile is incorrect")
	expect(game.surgery_reputation_profile("surgery_open_lung_lobectomy").tier == "advanced" and game.surgery_reputation_award_for("surgery_open_lung_lobectomy", 0) == 40 and game.surgery_reputation_award_for("surgery_open_lung_lobectomy", 600) == 0, "Advanced surgery reputation profile is incorrect")
	expect(game.surgery_reputation_profile("surgery_cabg").tier == "extreme" and game.surgery_reputation_award_for("surgery_cabg", 0) == 75 and game.surgery_reputation_award_for("surgery_cabg", 999) == 0, "Extreme surgery reputation profile is incorrect")
	var penalty_game = Game.new()
	configure_game(penalty_game)
	appendix.flags.append("no_anesthesia_confirmed")
	expect(penalty_game.award_surgery_reputation("surgery_appendix", "阑尾切除", appendix) == -8 and penalty_game.player_attributes().reputation == -8 and penalty_game.successful_no_anesthesia_surgeries == 1, "Successful no-anesthesia surgery did not receive normal reputation plus the fixed penalty")
	expect(penalty_game.award_surgery_reputation("surgery_cabg", "搭桥", wrong_cabg) == -75 and penalty_game.player_attributes().reputation == -83, "Knowingly wrong procedure gained positive reputation or missed its penalty")
	var office_game = Game.new()
	configure_game(office_game)
	office_game.completed_surgeries_total = 1
	expect(office_game.spend_time("office_write_surgery_report") and office_game.player_attributes().reputation == 1 and not office_game.spend_time("office_write_surgery_report"), "A completed surgery report could grant reputation more than once")
	expect(office_game.spend_time("office_organize_case_notes") and office_game.player_attributes().reputation == 1, "Organizing case notes incorrectly granted reputation")
	expect(is_equal_approx(game.leadership_xp_to_next_level(50), 8.0) and game.leadership_xp_to_next_level(80) > game.leadership_xp_to_next_level(60), "Leadership XP curve is incorrect")
	appendix.team = {"assistant_surgeon": "pharmacist_manami"}
	expect(is_equal_approx(game.team_relevant_skill_average(appendix.team), 5.0), "Team average did not use the assistant's surgery skill")
	game.record_completed_surgery_progress(appendix, "surgery_appendix")
	expect(game.character_progress_counter("pharmacist_manami", "completed_surgeries_as_assistant_surgeon") == 1 and game.character_progress_counter("pharmacist_manami", "completed_no_anesthesia_surgeries") == 1, "Completed no-anesthesia assistant participation was not recorded")
	var gynecology_prep = training_prep("surgery_open_abdominal_myomectomy")
	gynecology_prep.team = {"assistant_surgeon": "doc_aqua"}
	game.record_completed_surgery_progress(gynecology_prep, "surgery_open_abdominal_myomectomy")
	expect(game.character_progress_counter("", "gynecology_case_count") == 1 and game.character_progress_counter("doc_aqua", "completed_surgeries_in_group_female_pelvic") == 1, "Gynecology case or participating-staff progress was not recorded")
	expect(is_equal_approx(game.award_leadership_xp(appendix), 1.5), "Developing team did not grant the leadership learning multiplier")
	var staff_training := game.train_surgery_team(appendix.team, "surgery_appendix")
	expect(staff_training.size() == 1 and game.staff_skill_value("pharmacist_manami", "surgery") == 6, "Routine case did not train the role-relevant staff skill")
	game.surgery_xp = game.surgery_xp_for_level(60)
	expect(game.surgery_level() == 60 and game.surgery_xp_award_for(appendix) == 0, "Appendectomy exceeded its training ceiling")
	expect(game.unlock_procedure("surgery_cabg") and game.procedure_unlocked("surgery_cabg"), "Clinical unlock API did not unlock CABG")

	var snapshot: Dictionary = game.snapshot()
	var clone = Game.new()
	configure_game(clone)
	expect(clone.restore(JSON.parse_string(JSON.stringify(snapshot))), "Surgery progression save could not restore")
	expect(clone.surgery_xp == game.surgery_xp and is_equal_approx(clone.leadership_xp, game.leadership_xp) and clone.staff_skill_value("pharmacist_manami", "surgery") == 6 and clone.unlocked_procedure_ids == game.unlocked_procedure_ids, "Five-dimension or staff progression changed after restore")
	expect(clone.character_progress_counter("pharmacist_manami", "completed_no_anesthesia_surgeries") == 1 and clone.character_progress_counter("", "gynecology_case_count") == 1, "Character progress counters changed after surgery-progression restore")
	print("SURGERY PROGRESSION: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
