extends SceneTree
## Headless full-contract integration test for Artoria Pendragon (`doc_artoria`)
## Staff-as-Patient V1.1 (ordinary surgery runner, 4-beat ward opening, 28 reactions,
## 13x2 prep variants, 50 intraoperative interaction pools, 9x2 mischief variants +
## 3x4 nurse team overrides, 100/50/0 XP ledger, and BoundarySave v37 purity).

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const Registry = preload("res://godot/systems/staff_patient_registry.gd")
const ArtoriaLv5 = preload("res://godot/systems/artoria_lv5.gd")
const Store = preload("res://godot/systems/save_store.gd")

const ACTOR := "doc_artoria"
const LV5 := "artoria_lv5_my_position"

var content = Loader.new()
var checks := 0
var failures: Array[String] = []
var cjk_re := RegEx.new()

func _initialize() -> void:
	cjk_re.compile("[\\x{3400}-\\x{4dbf}\\x{4e00}-\\x{9fff}\\x{3040}-\\x{30ff}\\x{f900}-\\x{faff}]")
	call_deferred("run")

func expect(ok: bool, msg: String) -> void:
	checks += 1
	if not ok:
		failures.append(msg)
		push_error(msg)

func new_game() -> RefCounted:
	var g = Game.new()
	g.configure(
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
		content.collections.palpation_profiles,
		content.collections.awake_special_barks
	)
	for person in content.collections.staff:
		g.meet_staff(person.id)
	return g

func unlock_artoria_patient(g: RefCounted) -> void:
	var target_day := ArtoriaLv5.prepare_test_save(g, LV5, 21)
	g._complete_character_event_for_test(LV5, target_day)
	var rel: Dictionary = g.relation_for(ACTOR)
	rel.level = 5
	if not rel.rank_history.has(LV5):
		rel.rank_history.append(LV5)
	if not rel.unlocked_benefits.has("unlock_clinical_practice_patient"):
		rel.unlocked_benefits.append("unlock_clinical_practice_patient")
	g.set_story_flag("artoria_lv5_complete", true)
	g.set_story_flag("staff_as_patient_program_authorized", true)
	g.set_test_time(target_day + 2, 540)

func run_operation(prep: RefCounted, selected_procedure: String, branch: String, manual_ward: bool) -> bool:
	var preferred := [
		"brief_plan", "confirm_team", "perform_preparation", "to_changing",
		"change_scrubs", "scrub_hands", "enter_room", "team_check",
		"confirm_assistant_role", "confirm_scrub_role", "confirm_circulating_role",
		"acknowledge_procedure_mismatch", "choose_" + branch, "insist_without_anesthesia",
		"induction_reassure", "start_" + branch + "_surgery", "request_scalpel",
		"assistant_stabilize", "incise_" + branch, "execute_confirmed_procedure"
	]
	if manual_ward:
		preferred[2] = "begin_manual_ward_preparation"
		preferred.append_array(["ward_enema", "ack_ward_enema", "ward_skin_prep", "ack_ward_skin_prep", "ward_surgical_cap", "complete_manual_ward_preparation"])
	var team_map := {
		"assistant_surgeon": "doc_aoi",
		"scrub_nurse": "nurse_hiroko",
		"circulating_nurse": "nurse_moe",
		"ward_nurse": "nurse_ange",
	}
	for _iter in range(300):
		if prep.surgery_success:
			return true
		if prep.stage_id in ["team", "preparation"]:
			for role in team_map:
				if not prep.team.has(role):
					prep.apply({"kind": "assign", "role": role, "staff_id": team_map[role]})
		var ev := {}
		if prep.stage_id == "procedure_select":
			ev = {"kind": "procedure", "id": selected_procedure}
		elif prep.current().kind == "or_table_palpation":
			ev = {"kind": "or_table_palpation_complete"}
		elif prep.current().kind == "anesthesia_sensory_test" and not prep.flags.has("anesthesia_sensory_test_complete"):
			ev = {"kind": "anesthesia_sensory_test_complete"}
		elif prep.current().kind == "surgery_flow":
			if prep.awaiting_flow_acknowledgement:
				ev = {"kind": "flow_acknowledge"}
			elif prep.awaiting_patient_acknowledgement:
				ev = {"kind": "patient_acknowledge"}
			elif prep.awaiting_patient_choice:
				var pid := str(prep.active_patient_interaction.id)
				if prep.procedure_mismatch and prep.definition.get("agreement_required_interaction_ids", []).has(pid):
					push_error("Mismatch selected agreement-only pool: " + pid)
					return false
				ev = {"kind": "patient_interaction_action", "id": prep.active_patient_interaction.actions[0].id}
			else:
				var step: Dictionary = prep.surgery_flow_step()
				for option in step.get("options", []):
					if step.kind != "decision" or bool(option.get("correct", false)):
						ev = {"kind": "surgery_step", "id": option.id}
						break
		else:
			for id in preferred:
				for action in prep.current().get("actions", []):
					if str(action.id) == id and not prep.done.has(id) and prep.action_visible(action) and prep.action_reason(action).is_empty():
						ev = {"kind": "action", "id": id}
						break
				if not ev.is_empty():
					break
			if ev.is_empty():
				for action in prep.current().get("actions", []):
					if prep.action_visible(action) and prep.action_reason(action).is_empty():
						ev = {"kind": "action", "id": action.id}
						break
		if ev.is_empty() or not prep.apply(ev):
			push_error("Flow stopped at %s: %s / %s" % [prep.stage_id, ev, prep.last_error])
			return false
	return false

func test_locale(locale: String) -> void:
	var g := new_game()

	# 1. Strict unlock gates
	expect(not g.staff_patient_unlocked(ACTOR), locale + ": locked initially")
	g.relation_for(ACTOR).level = 5
	g.set_story_flag("staff_as_patient_program_authorized", true)
	expect(not g.staff_patient_unlocked(ACTOR), locale + ": numeric Lv5 without completed milestone stays locked")

	unlock_artoria_patient(g)
	expect(g.staff_patient_unlocked(ACTOR) and g.can_invite_staff_patient(ACTOR), locale + ": unlocked after authored Lv5 + program authorization")
	g.set_story_flag("staff_as_patient_program_authorized", false)
	expect(not g.staff_patient_unlocked(ACTOR), locale + ": program flag required")
	g.set_story_flag("staff_as_patient_program_authorized", true)

	# 2. Category invitation lines & placeholder resolution
	for sid in ["surgery_appendix", "surgery_open_major_liver_resection", "surgery_hysterectomy", "surgery_total_mastectomy", "surgery_open_total_gastrectomy"]:
		var inv_line: String = g.staff_patient_invitation_line(ACTOR, sid)
		expect(not inv_line.is_empty() and not inv_line.contains("{procedure_name}"), "%s: invitation line resolved for %s" % [locale, sid])
		if locale == "en":
			expect(cjk_re.search(inv_line) == null, "en: zero CJK in invitation line for " + sid)

	# 3. Patient record merges all 26 active reactions, 13+9 variants, 50 pools, and 3 nurse mischief overrides
	var rec: Dictionary = Registry.patient_record(g.staff_record(ACTOR), locale)
	expect(not rec.is_empty(), locale + ": patient_record built")
	expect(not rec.reaction_lines.has("hospitalization_question") and not rec.reaction_lines.has("hospitalization_response"), locale + ": reserved outpatient admission reactions stripped")
	expect(rec.reaction_lines.size() == 26, locale + ": 26 active reaction_lines present")
	expect(rec.reaction_variants.size() == 22, locale + ": 13 standard + 9 mischief reaction_variants merged (22 groups)")
	var spd: Dictionary = rec.staff_patient_dialogue
	expect(spd.get("interaction_overrides", {}).size() == 50, locale + ": all 50 interaction_overrides pools loaded")
	for nurse_id in ["nurse_hiroko", "nurse_ange", "nurse_moe"]:
		expect(spd.get("team_overrides", {}).get(nurse_id, {}).size() == 4, "%s: 4 mischief team_overrides loaded for %s" % [locale, nurse_id])
	var expected_nude := "assets/characters/artoria_staff_patient_v1/doc_artoria/ward_preparation/shy.png"
	var rec_portraits: Dictionary = rec.get("visuals", {}).get("portraits", {})
	expect(str(rec_portraits.get("ward_preparation/shy", "")) == expected_nude, locale + ": ward_preparation/shy registered")
	expect(str(rec_portraits.get("examination/shy", "")) == expected_nude, locale + ": examination/shy aliased to ward_preparation/shy")
	var nude_tex := load("res://" + expected_nude) as Texture2D
	expect(nude_tex != null and nude_tex.get_width() == 1024 and nude_tex.get_height() == 1536, locale + ": ward_preparation/shy Texture2D loads 1024x1536")

	# 4. 4-beat ward_visit_opening + graphic_preop_question + self-exclusion from surgical roles
	g.unlock_procedure("surgery_open_major_liver_resection")
	expect(g.invite_staff_patient(ACTOR, "surgery_open_major_liver_resection"), locale + ": invited for major liver resection")
	expect(g.can_save_progress(), locale + ": pending admission before entering ward is saveable")

	# BoundarySave v37 round-trip with pending admission
	var tmp_save := "/private/tmp/hoshimi_artoria_sp_%s_%d.json" % [locale, OS.get_process_id()]
	var store := Store.new()
	store.path = tmp_save
	expect(store.write_slot(g, 1), locale + ": wrote pending admission save")
	var raw_pending := FileAccess.get_file_as_string(tmp_save)
	expect(raw_pending.find("ward_opening_") == -1 and raw_pending.find("stage_id") == -1, locale + ": zero preop inner state in pending save")
	var g_restored := new_game()
	expect(store.read_slot(g_restored, 1), locale + ": restored pending admission save")
	var prep = g_restored.open_preop(Registry.PREOP_ID)
	expect(prep != null and prep.is_staff_patient(), locale + ": opened restored preop")
	expect(not g_restored.can_save_progress(), locale + ": save locked once inside preop")
	expect(not prep.qualified(ACTOR, prep.role_definition("assistant_surgeon")), locale + ": Artoria excluded from operating on herself")

	# Walk 4-beat ward opening (`ward_opening_0` -> `1` -> `2` -> `ward_visit`)
	expect(prep.stage_id == "ward_opening_0" and prep.current().speaker == "narrator", locale + ": ward_opening_0 narrator")
	expect(prep.apply({"kind": "action", "id": "continue_ward_opening_0"}) and prep.stage_id == "ward_opening_1" and prep.current().speaker == "patient", locale + ": ward_opening_1 patient")
	expect(prep.apply({"kind": "action", "id": "continue_ward_opening_1"}) and prep.stage_id == "ward_opening_2" and prep.current().speaker == "player", locale + ": ward_opening_2 player")
	expect(prep.apply({"kind": "action", "id": "continue_ward_opening_2"}) and prep.stage_id == "ward_visit" and prep.current().speaker == "patient", locale + ": ward_visit final opening beat")

	# Verify all 50 pools resolve Artoria's custom prompt & responses inside PreopSession
	for entry in content.collections.patient_interactions:
		var ov: Dictionary = prep.patient_interaction_with_overrides(entry)
		expect(ov.prompt != entry.prompt, "%s: pool %s uses Artoria custom prompt" % [locale, str(entry.id)])
		if locale == "en":
			expect(cjk_re.search(ov.prompt) == null, "en: zero CJK in pool prompt " + str(entry.id))
		for i in range(ov.actions.size()):
			expect(ov.actions[i].response != entry.actions[i].response, "%s: pool %s action %s uses Artoria custom response" % [locale, str(entry.id), str(ov.actions[i].id)])
			if locale == "en":
				expect(cjk_re.search(str(ov.actions[i].response)) == null, "en: zero CJK in pool response %s.%s" % [str(entry.id), str(ov.actions[i].id)])

	# Complete general-anesthesia liver resection -> 100% XP -> 50% XP -> 0% XP
	var xp0: int = g_restored.surgery_xp
	var rep0: int = g_restored.player_attributes().reputation
	expect(run_operation(prep, "surgery_open_major_liver_resection", "general", false), locale + ": completed general-anesthesia liver resection")
	var award1: int = g_restored.surgery_xp_award_for(prep)
	expect(award1 > 0 and g_restored.finish_active_surgery(), locale + ": settled 1st practice (100% XP)")
	expect(g_restored.surgery_xp - xp0 == award1 and g_restored.staff_patient_practice_count(ACTOR, "surgery_open_major_liver_resection") == 1, locale + ": practice count == 1")
	expect(g_restored.player_attributes().reputation == rep0, locale + ": reputation unchanged")

	# 2nd run (epidural + manual ward prep) -> 50% XP (advance to next routine workday morning)
	g_restored.advance_story_to_day(g_restored.day_number() + 1, 540)
	while not g_restored.is_routine_workday():
		g_restored.advance_story_to_day(g_restored.day_number() + 1, 540)
	expect(g_restored.invite_staff_patient(ACTOR, "surgery_open_major_liver_resection"), locale + ": 2nd invitation")
	var prep2 = g_restored.open_preop(Registry.PREOP_ID)
	var xp1: int = g_restored.surgery_xp
	expect(run_operation(prep2, "surgery_open_major_liver_resection", "epidural", true), locale + ": completed epidural + manual ward liver resection")
	expect(prep2.flags.has("manual_ward_preparation_complete") and prep2.patient_event_count > 0, locale + ": exercised manual ward prep & awake intraoperative interactions")
	expect(g_restored.finish_active_surgery() and g_restored.surgery_xp - xp1 > 0 and g_restored.staff_patient_practice_count(ACTOR, "surgery_open_major_liver_resection") == 2, locale + ": settled 2nd practice (50% XP)")

	# 3rd run -> 0% XP
	g_restored.advance_story_to_day(g_restored.day_number() + 1, 540)
	while not g_restored.is_routine_workday():
		g_restored.advance_story_to_day(g_restored.day_number() + 1, 540)
	expect(g_restored.invite_staff_patient(ACTOR, "surgery_open_major_liver_resection"), locale + ": 3rd invitation")
	var prep3 = g_restored.open_preop(Registry.PREOP_ID)
	var xp2: int = g_restored.surgery_xp
	expect(run_operation(prep3, "surgery_open_major_liver_resection", "general", false), locale + ": completed 3rd liver resection")
	expect(g_restored.surgery_xp_award_for(prep3) == 0 and g_restored.finish_active_surgery() and g_restored.surgery_xp == xp2 and g_restored.staff_patient_practice_count(ACTOR, "surgery_open_major_liver_resection") == 3, locale + ": settled 3rd practice (0% XP)")

	# Wrong-procedure + no-anesthesia test (`surgery_breast_tumor` -> `surgery_hysterectomy`)
	g_restored.advance_story_to_day(g_restored.day_number() + 1, 540)
	while not g_restored.is_routine_workday():
		g_restored.advance_story_to_day(g_restored.day_number() + 1, 540)
	g_restored.unlock_procedure("surgery_breast_tumor")
	g_restored.set_story_flag("aqua_hysterectomy_teaching_complete", true)
	g_restored.unlock_procedure("surgery_hysterectomy")
	expect(g_restored.invite_staff_patient(ACTOR, "surgery_breast_tumor"), locale + ": invited for breast tumor")
	var prep_mis = g_restored.open_preop(Registry.PREOP_ID)
	var xp3: int = g_restored.surgery_xp
	expect(run_operation(prep_mis, "surgery_hysterectomy", "none", true), locale + ": completed mismatch + no-anesthesia hysterectomy")
	expect(g_restored.surgery_xp_award_for(prep_mis) == 0 and g_restored.finish_active_surgery(), locale + ": settled mismatch + no-anesthesia")
	expect(g_restored.surgery_xp == xp3 and g_restored.staff_patient_practice_count(ACTOR, "surgery_breast_tumor") == 0 and g_restored.staff_patient_practice_count(ACTOR, "surgery_hysterectomy") == 0, locale + ": mismatch consumed zero XP or practice count")

	# Final BoundarySave round-trip with settled practice counts
	expect(store.write_slot(g_restored, 2), locale + ": saved settled practice ledger")
	var g_final := new_game()
	expect(store.read_slot(g_final, 2), locale + ": restored settled practice ledger")
	expect(g_final.staff_patient_practice_count(ACTOR, "surgery_open_major_liver_resection") == 3, locale + ": restored practice count == 3")
	DirAccess.remove_absolute(tmp_save)

func run() -> void:
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Loaded " + locale)
		test_locale(locale)

	print("ARTORIA STAFF PATIENT HEADLESS TEST: %d checks; %d failure(s)" % [checks, failures.size()])
	for f in failures:
		print("  FAIL: " + f)
	quit(1 if not failures.is_empty() else 0)
