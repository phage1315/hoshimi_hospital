extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const PreopView = preload("res://godot/ui/preop_view.gd")

var content = Loader.new()
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func configure_game() -> RefCounted:
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards)
	return game

func assign_distinct_team(prep: RefCounted, include_ward_nurse: bool) -> bool:
	var used: Array[String] = []
	for role in prep.definition.roles:
		var selected_id := ""
		for person in prep.candidates(str(role.id)):
			if str(person.id) not in used:
				selected_id = str(person.id)
				break
		if selected_id.is_empty():
			return false
		prep.team[str(role.id)] = selected_id
		used.append(selected_id)
	if include_ward_nurse:
		for person in prep.candidates(str(prep.definition.ward_role.id)):
			if str(person.id) not in used:
				prep.team[str(prep.definition.ward_role.id)] = str(person.id)
				return true
		return false
	return true

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var game = configure_game()
	var definition: Dictionary = game.preop_definitions.values()[0]
	var surgery_id := str(definition.surgery_id)
	var manual = Preop.new(definition, content.collections.staff, content.collections.surgeries, content.collections.patients)
	manual.stage_id = "procedure_execute"
	manual.procedure_id = surgery_id
	manual.procedure_name = str(game.surgery_definition(surgery_id).name)
	manual.procedure_minutes = int(game.surgery_definition(surgery_id).duration_minutes)
	manual.flags.append("interaction_complete")
	var manual_before_minutes: int = manual.minutes
	expect(manual.apply({"kind": "action", "id": "execute_confirmed_procedure"}), "Manual surgery could not reach settlement")
	expect(manual.surgery_success and manual.flags.has("postoperative_wrap_up_complete") and manual.minutes == manual_before_minutes + manual.procedure_minutes + 30, "Manual surgery did not include exactly one postoperative wrap-up")
	var early_game = configure_game()
	var first_prep = Preop.new(definition, content.collections.staff, content.collections.surgeries, content.collections.patients)
	expect(assign_distinct_team(first_prep, true), "Could not assemble the first surgery team")
	first_prep.procedure_id = surgery_id
	first_prep.procedure_name = str(early_game.surgery_definition(surgery_id).name)
	first_prep.procedure_minutes = int(early_game.surgery_definition(surgery_id).duration_minutes)
	first_prep.surgery_success = true
	for actor_id in first_prep.team.values():
		early_game.meet_staff(str(actor_id))
	early_game.preops[definition.id] = first_prep
	early_game.active_preop_id = str(definition.id)
	early_game.active_mode = "preop"
	var first_shared_actor := str(first_prep.team.values()[0])
	expect(early_game.finish_active_surgery(), "First completed surgery was not recorded")
	expect(int(early_game.completed_surgeries_by_procedure.get(surgery_id, 0)) == 1, "First completed procedure did not unlock its repeat sweep")
	expect(early_game.shared_surgery_count(first_shared_actor) == 1, "Shared-surgery count was not persisted on completion")
	early_game.preops.clear()
	expect(early_game.shared_surgery_count(first_shared_actor) == 1, "Shared-surgery count fell after an old case record was cleared")
	var early_prep = Preop.new(definition, content.collections.staff, content.collections.surgeries, content.collections.patients)
	early_prep.stage_id = "preparation"
	early_prep.set_procedure_unlocks([surgery_id], true)
	early_game.preops[definition.id] = early_prep
	early_game.active_preop_id = str(definition.id)
	early_game.active_mode = "preop"
	expect(assign_distinct_team(early_prep, false), "Could not assemble the core team for early sweep test")
	expect(not early_prep.sweep_team_ready(), "Early sweep became ready without a ward-preparation nurse")
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.game = early_game
	PreopView.render(app, early_prep)
	var early_sweep_button := app.page.get_node_or_null("ProcedureSweep_" + surgery_id) as Button
	expect(early_sweep_button != null and early_sweep_button.disabled, "Repeat-surgery sweep was not shown disabled while the ward nurse was missing")
	expect(early_game.sweep_active_surgery(surgery_id).is_empty(), "Early sweep bypassed the ward-preparation nurse requirement")
	expect(assign_distinct_team(early_prep, true), "Could not assign a distinct ward-preparation nurse for early sweep test")
	expect(early_prep.sweep_team_ready(), "Complete early-sweep team was not recognized")
	PreopView.render(app, early_prep)
	early_sweep_button = app.page.get_node_or_null("ProcedureSweep_" + surgery_id) as Button
	expect(early_sweep_button != null and not early_sweep_button.disabled, "Repeat-surgery sweep did not enable on the ward-preparation page")
	var early_result: Dictionary = early_game.sweep_active_surgery(surgery_id)
	expect(not early_result.is_empty() and early_prep.surgery_success, "Repeat surgery could not be swept from the ward-preparation stage")
	app.queue_free()
	var prep = Preop.new(definition, content.collections.staff, content.collections.surgeries, content.collections.patients)
	prep.stage_id = "procedure_select"
	prep.set_procedure_unlocks([surgery_id], true)
	game.unlock_procedure(surgery_id)
	game.preops[definition.id] = prep
	game.active_preop_id = str(definition.id)
	game.active_mode = "preop"
	game.meet_staff("nurse_moe")
	prep.team["scrub_nurse"] = "nurse_moe"
	expect(not game.procedure_sweep_unlocked(surgery_id), "Unperformed procedure started sweepable")
	expect(game.sweep_active_surgery(surgery_id).is_empty(), "Sweep bypassed the first-completion requirement")
	game.completed_surgeries_by_procedure[surgery_id] = 1
	game.story_time_advance_minutes = 470
	var reputation_before := int(game.player_attributes().reputation)
	var familiarity_before := int(game.relation_for("nurse_moe").familiarity)
	var expected_reputation: int = game.surgery_reputation_award_for(surgery_id, reputation_before)
	var result: Dictionary = game.sweep_active_surgery(surgery_id)
	expect(not result.is_empty(), "Completed procedure could not be swept")
	expect(prep.surgery_success and prep.stage_id == "surgery_result", "Sweep did not produce a completed operation")
	expect(int(result.get("procedure_duration_minutes", 0)) == int(game.surgery_definition(surgery_id).duration_minutes), "Sweep did not charge the full authored surgery duration")
	expect(int(result.get("postoperative_wrap_up_minutes", 0)) == 30 and int(result.get("duration_minutes", 0)) == int(game.surgery_definition(surgery_id).duration_minutes) + 30, "Sweep did not include the fixed postoperative wrap-up time")
	expect(bool(result.get("crossed_day", false)), "Postoperative wrap-up was not included in overtime settlement")
	expect(int(result.get("xp", 0)) > 0, "Sweep did not award surgery XP")
	expect(int(result.get("reputation", 0)) == expected_reputation and int(game.player_attributes().reputation) == reputation_before + expected_reputation, "Sweep did not use the surgery difficulty reputation curve")
	expect(int(game.relation_for("nurse_moe").familiarity) - familiarity_before == game.surgery_familiarity_reward("nurse_moe"), "Sweep did not award team familiarity")
	expect(int(game.completed_surgeries_by_procedure.get(surgery_id, 0)) == 2, "Sweep did not increment procedure completion count")
	# The test prepared the session by setting its stage directly rather than by
	# replaying a full admission log; remove that synthetic session before testing
	# persistence of the completed-procedure counter itself.
	game.preops.clear()
	var snapshot: Dictionary = game.snapshot()
	var clone = configure_game()
	expect(clone.restore(JSON.parse_string(JSON.stringify(snapshot))), "Sweep progress save could not restore")
	expect(clone.procedure_sweep_unlocked(surgery_id), "Sweep unlock was lost after save restore")

	# Regression: crossing the shift boundary advances exactly one calendar day.
	# Sunday should appear only when that actual next date is Sunday.
	for starting_day in range(1, 15):
		var calendar_game = configure_game()
		calendar_game.unlock_procedure(surgery_id)
		calendar_game.completed_surgeries_by_procedure[surgery_id] = 1
		calendar_game.story_time_advance_minutes = (starting_day - 1) * 480 + 470
		var calendar_prep = Preop.new(definition, content.collections.staff, content.collections.surgeries, content.collections.patients)
		calendar_prep.stage_id = "procedure_select"
		calendar_prep.set_procedure_unlocks([surgery_id], true)
		calendar_game.preops[definition.id] = calendar_prep
		calendar_game.active_preop_id = str(definition.id)
		calendar_game.active_mode = "preop"
		var calendar_result: Dictionary = calendar_game.sweep_active_surgery(surgery_id)
		expect(not calendar_result.is_empty(), "Calendar sweep failed from day %s" % starting_day)
		expect(calendar_game.day_number() == starting_day + 1, "Sweep from day %s advanced to day %s" % [starting_day, calendar_game.day_number()])
		var expected_sunday := str(calendar_game.calendar_date(starting_day + 1).weekday_id) == "sun"
		expect(calendar_game.is_sunday() == expected_sunday, "Sweep misclassified day %s as Sunday" % (starting_day + 1))
		expect(not calendar_game.pending_departure_context().is_empty(), "Cross-day sweep lost its departure transition from day %s" % starting_day)
		expect(calendar_game.active_id.is_empty(), "Cross-day sweep prematurely opened the next day's patient from day %s" % starting_day)
	print("SURGERY SWEEP: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
