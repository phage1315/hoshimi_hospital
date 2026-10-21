extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const Registry = preload("res://godot/systems/staff_patient_registry.gd")
var content = Loader.new()
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func new_game() -> RefCounted:
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff,
		content.collections.time_events, content.collections.surgeries, content.collections.patients,
		content.collections.relationships, content.collections.character_events, content.collections.case_templates,
		content.collections.micro_events, content.collections.examination_cg_pools,
		content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions,
		content.collections.temporary_conditions, content.collections.staff_role_cg_rewards,
		content.collections.special_events, content.collections.special_event_steps,
		content.collections.date_profiles, content.collections.date_locations,
		content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions,
		content.collections.palpation_profiles, content.collections.awake_special_barks)
	for person in content.collections.staff:
		game.meet_staff(person.id)
	return game

func unlock(game: RefCounted) -> void:
	game.set_story_flag("sayaka_lv5_part_c_complete", true)
	game.set_story_flag("staff_as_patient_program_authorized", true)

func begin(game: RefCounted, surgery: String = "surgery_breast_tumor") -> RefCounted:
	expect(game.invite_staff_patient("doc_sayaka", surgery), "Invitation failed: " + game.last_error)
	return game.open_preop(Registry.PREOP_ID)

func set_result(prep: RefCounted, surgery: String, success: bool = true) -> void:
	prep.procedure_id = surgery
	prep.procedure_name = prep.surgeries[surgery].name
	prep.procedure_minutes = prep.surgeries[surgery].duration_minutes
	prep.procedure_mismatch = surgery != str(prep.definition.agreed_procedure_id)
	prep.surgery_success = success
	prep.surgery_aborted = not success
	prep.minutes = 35
	prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin", "ward_nurse": "nurse_yui"}

func test_settlement() -> void:
	var game = new_game()
	expect(not game.staff_patient_unlocked("doc_sayaka"), "Unlocked before Part C")
	expect(not game.invite_staff_patient("doc_sayaka", "surgery_breast_tumor"), "Locked invitation accepted")
	unlock(game)
	expect(not game.invite_staff_patient("doc_sayaka", "surgery_cabg"), "Locked surgery accepted")
	var queue: Array = game.patient_queue.duplicate()
	var cases: Dictionary = game.patient_cases.duplicate(true)
	var prep = begin(game)
	if prep == null:
		expect(false, "No patient instance")
		return
	expect(prep.is_staff_patient() and prep.patient_name == game.staff_record("doc_sayaka").name, "Wrong patient identity")
	expect(game.visits.is_empty(), "Created an outpatient visit")
	expect(game.current_patient_id().is_empty() and game.unresolved_admitted_patient_exists(), "Ward occupancy not enforced")
	expect(game.open_visit(str(game.definitions.keys()[0])) == null, "Direct outpatient admission bypassed occupancy")
	expect(not game.can_invite_staff_patient("doc_sayaka"), "Duplicate admission accepted")
	expect(not prep.qualified("doc_sayaka", prep.role_definition("assistant_surgeon")), "Patient can operate on herself")
	expect(not game.known_staff_ids().has("doc_sayaka"), "Admitted staff remained available for work")
	set_result(prep, "surgery_appendix")
	prep.flags.append("no_anesthesia_confirmed")
	var xp: int = game.surgery_xp
	var reputation: int = game.player_attributes().reputation
	var elapsed: int = game.elapsed()
	expect(game.surgery_xp_award_for(prep) == 0, "Wrong procedure gained technical XP")
	expect(game.finish_active_surgery(), "Wrong-procedure settlement failed")
	expect(game.surgery_xp == xp and game.player_attributes().reputation == reputation, "Wrong/no-anesthesia surgery changed XP/reputation")
	expect(game.staff_patient_practice_count("doc_sayaka", "surgery_appendix") == 0 and game.staff_patient_practice_count("doc_sayaka", "surgery_breast_tumor") == 0, "Wrong surgery consumed either opportunity")
	expect(game.elapsed() == elapsed and game.active_staff_patient.is_empty(), "Settlement lost time or failed to release ward")
	expect(game.patient_queue == queue and game.patient_cases == cases, "Staff case rotated ordinary patients")
	expect(not game.finish_active_surgery(), "Duplicate settlement accepted")
	for index in range(3):
		prep = begin(game, "surgery_appendix")
		if prep == null:
			expect(false, "Repeat admission failed")
			return
		set_result(prep, "surgery_appendix")
		var control_definition: Dictionary = prep.definition.duplicate(true)
		control_definition.erase("staff_patient_id")
		var control = Preop.new(control_definition, game.staff, game.surgery_definitions, [game.patient_definition("doc_sayaka")])
		control.restore_state(prep.snapshot_state())
		var base_xp: int = game.surgery_xp_award_for(control)
		var expected: int = roundi(base_xp * [1.0, 0.5, 0.0][index])
		xp = game.surgery_xp
		prep.flags.append("no_anesthesia_confirmed")
		expect(game.surgery_xp_award_for(prep) == expected, "Incorrect repeat XP preview " + str(index))
		expect(game.finish_active_surgery() and game.surgery_xp - xp == expected, "Incorrect repeat settlement " + str(index))
		expect(game.player_attributes().reputation == reputation, "Staff success changed reputation")
		expect(game.staff_patient_practice_count("doc_sayaka", "surgery_appendix") == index + 1, "Repeat ledger incorrect")
	expect(game.leadership_xp > 0 and not game.staff_training_credits.is_empty(), "Leadership/team growth lost")
	prep = begin(game)
	set_result(prep, "surgery_breast_tumor", false)
	expect(game.finish_active_surgery_abort(), "Abort settlement failed")
	expect(game.staff_patient_practice_count("doc_sayaka", "surgery_breast_tumor") == 0 and game.active_staff_patient.is_empty(), "Abort consumed opportunity/blocked ward")
	var restored = new_game()
	expect(restored.restore(JSON.parse_string(JSON.stringify(game.snapshot()))), "Completed ledger restore failed: " + restored.last_error)
	expect(restored.staff_patient_practice_count("doc_sayaka", "surgery_appendix") == 3, "Restore lost practice count")
	game.reset()
	expect(game.staff_patient_practice_counts.is_empty() and game.active_staff_patient.is_empty(), "New game retained admissions/counts")

func test_saves_and_overrides() -> void:
	var game = new_game()
	unlock(game)
	expect(game.invite_staff_patient("doc_sayaka", "surgery_breast_tumor"), "Pending invitation failed")
	expect(game.can_save_progress(), "Pending ward admission is not saveable")
	var saved: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
	var clone = new_game()
	expect(clone.restore(saved), "Pending admission restore failed: " + clone.last_error)
	var prep = clone.open_preop(Registry.PREOP_ID)
	expect(prep != null and prep.stage_id == "ward_visit", "Restored admission cannot enter ward")
	if prep == null:
		return
	prep.patient_dialogue_overrides = {"address_context": {"surgeon_name": "TEST_SURGEON"}, "interaction_overrides": {"progress_default_01": {"prompt": "TEST_PROMPT {surgeon_name}", "responses": {"answer_progress": "TEST_ANSWER", "invented_action": "INVALID"}}}, "team_overrides": {"doc_aoi": {"confirm_team": "TEST_TEAM"}}}
	prep.patient_reactions["brief_plan"] = "TEST {procedure_name} {surgeon_name}"
	prep.patient_reaction_variants["ward_surgical_cap"] = ["TEST_VARIANT"]
	expect(prep.patient_reaction("brief_plan", "fallback").contains("TEST_SURGEON") and not prep.patient_reaction("brief_plan", "").contains("{procedure_name}"), "Explicit dialogue tokens not resolved")
	expect(prep.patient_reaction("ward_surgical_cap", "fallback") == "TEST_VARIANT", "Reaction variant override ignored")
	var interaction: Dictionary = {}
	for entry in content.collections.patient_interactions:
		if entry.id == "progress_default_01":
			interaction = entry
	var overridden: Dictionary = prep.patient_interaction_with_overrides(interaction)
	expect(overridden.prompt == "TEST_PROMPT TEST_SURGEON" and overridden.actions[0].response == "TEST_ANSWER", "Interaction-specific override failed")
	expect(overridden.actions.size() == interaction.actions.size() and overridden.actions[0].effects == interaction.actions[0].effects and interaction.prompt != overridden.prompt, "Override changed actions/effects/shared pool")
	expect(prep.staff_action_response("doc_aoi", "confirm_team", "fallback") == "TEST_TEAM", "Staff-specific dialogue override failed")
	prep.patient_dialogue_overrides.clear()
	var open_save: Dictionary = JSON.parse_string(JSON.stringify(clone.snapshot()))
	var open_clone = new_game()
	expect(open_clone.restore(open_save), "Open ward state restore failed: " + open_clone.last_error)
	expect(open_clone.open_preop(Registry.PREOP_ID) != null, "Cannot reopen restored preop")
	var invalid: Dictionary = saved.duplicate(true)
	invalid.staff_patient_practice_counts = {"doc_sayaka": {"surgery_appendix": -1}}
	var before: Dictionary = clone.snapshot()
	expect(not clone.restore(invalid) and clone.snapshot() == before, "Invalid count accepted or restore not atomic")
	invalid = saved.duplicate(true)
	invalid.active_staff_patient.procedure_id = "missing"
	expect(not clone.restore(invalid), "Invalid surgery admission accepted")
	var legacy = new_game()
	var old_save: Dictionary = legacy.snapshot()
	old_save.erase("active_staff_patient")
	old_save.erase("staff_patient_practice_counts")
	expect(legacy.restore(old_save), "Existing saves lost compatibility")
	var busy = new_game()
	unlock(busy)
	var visit = busy.open_visit(str(busy.definitions.keys()[0]))
	visit.admitted = true
	expect(not busy.invite_staff_patient("doc_sayaka", "surgery_breast_tumor"), "Existing ward patient not respected")

func run_operation(prep: RefCounted, selected_procedure: String = "surgery_breast_tumor", branch: String = "general", manual_ward: bool = false) -> bool:
	var preferred := ["brief_plan", "confirm_team", "perform_preparation", "to_changing", "change_scrubs", "scrub_hands", "enter_room", "team_check", "confirm_assistant_role", "confirm_scrub_role", "confirm_circulating_role", "acknowledge_procedure_mismatch", "choose_" + branch, "insist_without_anesthesia", "induction_reassure", "start_" + branch + "_surgery", "request_scalpel", "assistant_stabilize", "incise_" + branch, "execute_confirmed_procedure"]
	if manual_ward:
		preferred[2] = "begin_manual_ward_preparation"
		preferred.append_array(["ward_enema", "ack_ward_enema", "ward_skin_prep", "ack_ward_skin_prep", "ward_surgical_cap", "complete_manual_ward_preparation"])
	for iteration in range(250):
		if prep.surgery_success:
			return true
		if prep.stage_id in ["team", "preparation"]:
			for role in {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin", "ward_nurse": "nurse_yui"}:
				if not prep.team.has(role):
					prep.apply({"kind": "assign", "role": role, "staff_id": {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin", "ward_nurse": "nurse_yui"}[role]})
		var event := {}
		if prep.stage_id == "procedure_select":
			event = {"kind": "procedure", "id": selected_procedure}
		elif prep.current().kind == "or_table_palpation":
			event = {"kind": "or_table_palpation_complete"}
		elif prep.current().kind == "surgery_flow":
			if prep.awaiting_flow_acknowledgement:
				event = {"kind": "flow_acknowledge"}
			elif prep.awaiting_patient_acknowledgement:
				event = {"kind": "patient_acknowledge"}
			elif prep.awaiting_patient_choice:
				if prep.procedure_mismatch and prep.definition.get("agreement_required_interaction_ids", []).has(prep.active_patient_interaction.id):
					push_error("Mismatch selected agreement-only pool: " + str(prep.active_patient_interaction.id))
					return false
				event = {"kind": "patient_interaction_action", "id": prep.active_patient_interaction.actions[0].id}
			else:
				var step: Dictionary = prep.surgery_flow_step()
				for option in step.get("options", []):
					if step.kind != "decision" or bool(option.get("correct", false)):
						event = {"kind": "surgery_step", "id": option.id}
						break
		else:
			for id in preferred:
				for action in prep.current().get("actions", []):
					if str(action.id) == id and not prep.done.has(id) and prep.action_visible(action) and prep.action_reason(action).is_empty():
						event = {"kind": "action", "id": id}
						break
				if not event.is_empty():
					break
			if event.is_empty():
				for action in prep.current().get("actions", []):
					if prep.action_visible(action) and prep.action_reason(action).is_empty():
						event = {"kind": "action", "id": action.id}
						break
		if event.is_empty() or not prep.apply(event):
			push_error("Flow stopped at %s: %s / %s" % [prep.stage_id, event, prep.last_error])
			return false
	return false

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Content load " + locale)
		test_settlement()
		test_saves_and_overrides()
		var game = new_game()
		unlock(game)
		var prep = begin(game)
		if prep != null:
			expect(run_operation(prep), "End-to-end ward/surgery failed " + locale)
			expect(prep.minutes > 0 and game.finish_active_surgery(), "End-to-end settlement failed " + locale)
		var wrong_game = new_game()
		unlock(wrong_game)
		var wrong_prep = begin(wrong_game)
		if wrong_prep != null:
			expect(run_operation(wrong_prep, "surgery_open_ovarian_cystectomy", "none"), "End-to-end wrong/no-anesthesia flow failed " + locale)
			expect(wrong_game.finish_active_surgery(), "End-to-end wrong/no-anesthesia settlement failed " + locale)
			expect(wrong_game.surgery_xp == 0 and wrong_game.player_attributes().reputation == 0 and wrong_game.staff_patient_practice_counts.is_empty(), "Wrong/no-anesthesia end-to-end changed XP, reputation or counts")
		var hyst_game = new_game()
		unlock(hyst_game)
		expect(hyst_game.unlock_procedure("surgery_hysterectomy"), "Unlock test's actual hysterectomy")
		var hyst_prep = begin(hyst_game)
		if hyst_prep != null:
			expect(run_operation(hyst_prep, "surgery_hysterectomy", "none", true), "Breast -> hysterectomy manual-ward route failed " + locale)
			expect(hyst_prep.flags.has("manual_ward_preparation_complete") and hyst_prep.patient_event_count > 0, "Manual ward/patient interactions were not exercised")
			expect(hyst_game.finish_active_surgery(), "Breast -> hysterectomy settlement failed")
			expect(hyst_game.surgery_xp == 0 and hyst_game.player_attributes().reputation == 0 and hyst_game.staff_patient_practice_counts.is_empty(), "Breast -> hysterectomy consumed XP/reputation/opportunities")
	print("STAFF PATIENT: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
