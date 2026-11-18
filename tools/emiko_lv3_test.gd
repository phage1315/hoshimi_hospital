extends SceneTree
## Headless integration, gate, S/O/G branch, two-stage CABG+Lv3 settlement,
## Artoria major-liver-resection teaching lock, legacy quick-sweep preservation,
## UI bilingual, and v37 save-boundary test for Emiko Mido (`doc_emiko`) Lv3:
## 《今天我主刀》 (`emiko_lv3_today_i_lead`, V1.1).

const ContentLoader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const EmikoLv3 = preload("res://godot/systems/emiko_lv3.gd")
const Store = preload("res://godot/systems/save_store.gd")
const MainScene = preload("res://godot/scenes/main.tscn")

const LV0 := "emiko_intro_rumored_hands"
const LV1 := "emiko_lv1_first_operation"
const LV2 := "emiko_lv2_follow_my_lead"
const LV3 := "emiko_lv3_today_i_lead"

var content: RefCounted
var checks := 0
var failures: Array[String] = []
var cjk_re := RegEx.new()

func _initialize() -> void:
	cjk_re.compile("[\\x{3400}-\\x{4dbf}\\x{4e00}-\\x{9fff}\\x{3040}-\\x{30ff}\\x{f900}-\\x{faff}]")
	call_deferred("run")

func expect(cond: bool, msg: String) -> void:
	checks += 1
	if not cond:
		failures.append(msg)

func new_game() -> RefCounted:
	var g = GameState.new()
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
	return g

func finish_event(g: RefCounted, id: String, picks: Array = []) -> bool:
	var ev = g.start_character_event(id)
	if ev == null:
		return false
	var guard := 0
	while not ev.completed and guard < 600:
		guard += 1
		var choices: Array = ev.current().choices
		var chosen := str(choices[0].id)
		for want in picks:
			for c in choices:
				if str(c.id) == str(want):
					chosen = str(c.id)
					break
		if not g.choose_character_event(chosen):
			return false
	var done: bool = ev.completed
	g.finish_character_event()
	return done

func set_exact_day_clock(g: RefCounted, target_day: int, absolute_clock: int) -> void:
	g.discarded_overtime_minutes = 0
	g.story_time_advance_minutes = 0
	var base_elapsed: int = g.elapsed()
	var desired_total: int = (maxi(1, target_day) - 1) * int(g.SHIFT_MINUTES) + clampi(absolute_clock - int(g.SHIFT_START_MINUTE), 0, int(g.SHIFT_MINUTES) - 1)
	g.story_time_advance_minutes = maxi(0, desired_total - base_elapsed)

func setup_ready_for_lv3(meet_artoria: bool = true, target_day: int = 11, target_clock: int = 990) -> RefCounted:
	var g := new_game()
	set_exact_day_clock(g, 1, 600)
	g._complete_character_event_for_test("intro_doc_asuka_director_office", 1)
	g.meet_staff("doc_asuka")
	g._complete_character_event_for_test("asuka_mentions_artoria_rival", 1)
	if meet_artoria:
		g.meet_staff("doc_artoria")
		g._complete_character_event_for_test("intro_doc_artoria_deputy_office", 2)
	g.set_test_player_attribute("skill", 70)
	expect(finish_event(g, LV0), "Lv0 completes at Surgery 70")

	var lv1_day := 4
	g.advance_story_to_day(lv1_day, 600)
	g.set_test_player_attribute("skill", 75)
	expect(finish_event(g, LV1), "Lv1 completes at Surgery 75")

	var lv2_day := 8
	g.advance_story_to_day(lv2_day, 600)
	g.set_test_player_attribute("skill", 80)
	expect(finish_event(g, LV2), "Lv2 completes at Surgery 80")

	# Advance to target day/clock (default Day 11 = Friday 2025-04-11, `lv2_day + 3`, 16:30 after_work)
	set_exact_day_clock(g, target_day, target_clock)
	g.relation_for("doc_emiko").familiarity = 40
	g.set_test_player_attribute("presence", 20)
	return g

func find_case_template(g: RefCounted, tid: String) -> Dictionary:
	return g.case_templates.get(tid, {})

func test_double_teaching_locks_and_legacy_sweep(locale: String) -> void:
	var g := new_game()
	var cabg_tpl := find_case_template(g, "template_cabg")
	var liver_tpl := find_case_template(g, "template_liver_resection")
	expect(not cabg_tpl.is_empty() and not liver_tpl.is_empty(), locale + " [Locks]: CABG & Major Liver Resection templates exist")
	expect(not g.procedure_unlocked("surgery_cabg"), locale + " [Locks]: surgery_cabg locked on new game")
	expect(not g.procedure_unlocked("surgery_open_major_liver_resection"), locale + " [Locks]: surgery_open_major_liver_resection locked on new game")
	expect(not g.case_template_available("template_cabg"), locale + " [Locks]: template_cabg excluded from ordinary case pool before Lv3")
	expect(not g.case_template_available("template_liver_resection"), locale + " [Locks]: template_liver_resection excluded from ordinary case pool before Artoria teaching")

	# Calling unlock_procedure without story teaching flag must NOT unlock either procedure:
	g.unlock_procedure("surgery_cabg")
	g.unlock_procedure("surgery_open_major_liver_resection")
	expect(not g.procedure_unlocked("surgery_cabg"), locale + " [Locks]: unlock_procedure alone cannot bypass Emiko CABG teaching flag")
	expect(not g.procedure_unlocked("surgery_open_major_liver_resection"), locale + " [Locks]: unlock_procedure alone cannot bypass Artoria liver resection teaching flag")

	# Legacy save fixture: player had already completed >=2 runs and unlocked quick-sweep
	# on BOTH procedures, and had unvisited queue patients pre-rolled with those templates,
	# plus one already-admitted patient in progress with template_cabg.
	var legacy := new_game()
	legacy.completed_surgeries_total = 4
	legacy.completed_surgeries_by_procedure["surgery_cabg"] = 2
	legacy.completed_surgeries_by_procedure["surgery_open_major_liver_resection"] = 2
	legacy.surgical_quality_records["surgery_cabg"] = {
		"best_score": 96,
		"best_grade": "S",
		"quick_surgery_unlocked": true,
	}
	legacy.surgical_quality_records["surgery_open_major_liver_resection"] = {
		"best_score": 95,
		"best_grade": "S",
		"quick_surgery_unlocked": true,
	}
	if not legacy.unlocked_procedure_ids.has("surgery_cabg"):
		legacy.unlocked_procedure_ids.append("surgery_cabg")
	if not legacy.unlocked_procedure_ids.has("surgery_open_major_liver_resection"):
		legacy.unlocked_procedure_ids.append("surgery_open_major_liver_resection")

	var in_flight_pid := str(legacy.patient_queue[0])
	var unvisited_cabg_pid := str(legacy.patient_queue[1])
	var unvisited_liver_pid := str(legacy.patient_queue[2])
	legacy.patient_cases[in_flight_pid] = "template_cabg"
	legacy.patient_cases[unvisited_cabg_pid] = "template_cabg"
	legacy.patient_cases[unvisited_liver_pid] = "template_liver_resection"
	legacy.rebuild_patient_content(legacy.patient_cases)
	var visit = legacy.open_visit("visit_" + in_flight_pid.trim_prefix("patient_"))
	if visit != null:
		visit.admitted = true
	legacy.active_id = ""

	var snap: Dictionary = legacy.snapshot()
	var restored := new_game()
	expect(restored.restore(JSON.parse_string(JSON.stringify(snap))), locale + " [LegacySweep]: legacy save with swept CABG & Liver Resection restores cleanly")
	expect(int(restored.completed_surgeries_by_procedure.get("surgery_cabg", 0)) == 2, locale + " [LegacySweep]: CABG completion count preserved")
	expect(int(restored.completed_surgeries_by_procedure.get("surgery_open_major_liver_resection", 0)) == 2, locale + " [LegacySweep]: Liver Resection completion count preserved")
	expect(bool(restored.surgical_quality_records.get("surgery_cabg", {}).get("quick_surgery_unlocked", false)), locale + " [LegacySweep]: CABG S-grade sweep record preserved")
	expect(bool(restored.surgical_quality_records.get("surgery_open_major_liver_resection", {}).get("quick_surgery_unlocked", false)), locale + " [LegacySweep]: Liver Resection S-grade sweep record preserved")
	expect(str(restored.patient_cases.get(unvisited_cabg_pid, "")) != "template_cabg", locale + " [LegacySweep]: untouched queue CABG re-rolled while story locked")
	expect(str(restored.patient_cases.get(unvisited_liver_pid, "")) != "template_liver_resection", locale + " [LegacySweep]: untouched queue Liver Resection re-rolled while story locked")
	if visit != null:
		expect(str(restored.patient_cases.get(in_flight_pid, "")) == "template_cabg", locale + " [LegacySweep]: admitted in-progress patient keeps saved case without corruption")

	# While story teaching flags are still false, neither procedure is unlocked or sweepable on new cases:
	expect(not restored.procedure_unlocked("surgery_cabg") and not restored.procedure_sweep_unlocked("surgery_cabg"), locale + " [LegacySweep]: CABG not selectable/sweepable before Emiko Lv3")
	expect(not restored.procedure_unlocked("surgery_open_major_liver_resection") and not restored.procedure_sweep_unlocked("surgery_open_major_liver_resection"), locale + " [LegacySweep]: Liver Resection not selectable/sweepable before Artoria teaching")

	# Once teaching flags unlock via story, BOTH procedure availability AND historical quick-sweep immediately return!
	restored.set_story_flag("emiko_cabg_teaching_complete", true)
	expect(restored.procedure_unlocked("surgery_cabg") and restored.case_template_available("template_cabg") and restored.procedure_sweep_unlocked("surgery_cabg"), locale + " [LegacySweep]: CABG immediately re-unlocked AND quick-sweepable after Emiko Lv3 teaching")

	restored.set_story_flag("artoria_major_liver_resection_teaching_complete", true)
	expect(restored.procedure_unlocked("surgery_open_major_liver_resection") and restored.case_template_available("template_liver_resection") and restored.procedure_sweep_unlocked("surgery_open_major_liver_resection"), locale + " [LegacySweep]: Liver Resection immediately re-unlocked AND quick-sweepable after Artoria teaching")

func run_for_locale(locale: String) -> void:
	content = ContentLoader.new()
	expect(content.load_all(locale), locale + ": ContentLoader.load_all")

	test_double_teaching_locks_and_legacy_sweep(locale)

	# 1. Gate boundary checks: Artoria met, Familiarity 39 vs 40, Presence +19 vs +20, Cooldown, Saturday/Sunday/Inpatient/Referral
	var g_unmet_artoria := setup_ready_for_lv3(false)
	var def_lv3: Dictionary = g_unmet_artoria.character_event_definitions[LV3]
	expect(not g_unmet_artoria.relationship_rank_gate_met("doc_emiko", 3), locale + " [Gate]: blocked when Artoria unmet")
	expect(not g_unmet_artoria.character_event_available(def_lv3), locale + " [Gate]: event unavailable when Artoria unmet")

	g_unmet_artoria.meet_staff("doc_artoria")
	expect(g_unmet_artoria.relationship_rank_gate_met("doc_emiko", 3), locale + " [Gate]: rank gate met once Artoria is met")

	g_unmet_artoria.relation_for("doc_emiko").familiarity = 39
	expect(not g_unmet_artoria.character_event_available(def_lv3), locale + " [Gate]: Familiarity 39 blocked")
	g_unmet_artoria.relation_for("doc_emiko").familiarity = 40

	g_unmet_artoria.set_test_player_attribute("presence", 19)
	expect(not g_unmet_artoria.character_event_available(def_lv3), locale + " [Gate]: Presence +19 blocked")
	g_unmet_artoria.set_test_player_attribute("presence", 20)
	expect(g_unmet_artoria.character_event_available(def_lv3), locale + " [Gate]: Familiarity 40 + Presence +20 + Artoria met unlocked on Fri after_work")

	# Cooldown check: lv2 completed on Day 8 -> Day 10 (`+2` days) blocked, Day 11 (`+3` days) allowed
	set_exact_day_clock(g_unmet_artoria, 10, 990)
	expect(not g_unmet_artoria.character_event_available(def_lv3), locale + " [Gate]: Day 10 (2 days after Lv2) blocked by 3-day cooldown")
	set_exact_day_clock(g_unmet_artoria, 11, 990)
	expect(g_unmet_artoria.character_event_available(def_lv3), locale + " [Gate]: Day 11 (3 days after Lv2) allowed")

	# Daytime before 16:00 blocked (`time_start: 960`) in after_work scheduler
	set_exact_day_clock(g_unmet_artoria, 11, 900)
	expect(g_unmet_artoria.next_after_work_character_event().is_empty(), locale + " [Gate]: 15:00 before after_work blocked")
	set_exact_day_clock(g_unmet_artoria, 11, 990)
	expect(str(g_unmet_artoria.next_after_work_character_event().get("id", "")) == LV3, locale + " [Gate]: 16:30 after_work scheduler offers Lv3")

	# Saturday (`Day 12` = 2025-04-12, since Day 13 is Sunday closed!) and Sunday (`Day 13`) blocked; Monday (`Day 14`) allowed!
	set_exact_day_clock(g_unmet_artoria, 12, 990)
	expect(str(g_unmet_artoria.calendar_date(12).weekday_id) == "sat", locale + " [Gate]: Day 12 is Saturday")
	expect(not g_unmet_artoria.character_event_available(def_lv3), locale + " [Gate]: Saturday after_work blocked so CABG never lands on Sunday")
	set_exact_day_clock(g_unmet_artoria, 13, 990)
	expect(g_unmet_artoria.is_sunday() and not g_unmet_artoria.character_event_available(def_lv3), locale + " [Gate]: Sunday blocked")
	set_exact_day_clock(g_unmet_artoria, 14, 990)
	expect(g_unmet_artoria.character_event_available(def_lv3), locale + " [Gate]: Monday Day 14 after_work allowed")

	# Next-day Advanced Referral operation/review collision blocked
	g_unmet_artoria.advanced_referral_facts = {"appointment": {"operation_day": 15, "review_day": 16}}
	expect(not g_unmet_artoria.character_event_available(def_lv3), locale + " [Gate]: blocked when next-day Advanced Referral operation_day collides")
	g_unmet_artoria.advanced_referral_facts.clear()

	# Unresolved admitted inpatient blocked (admit during clinic hours `600`, then test at `990`)
	set_exact_day_clock(g_unmet_artoria, 14, 600)
	var first_visit_id := "visit_" + str(g_unmet_artoria.patient_queue[0]).trim_prefix("patient_")
	var v_block = g_unmet_artoria.open_visit(first_visit_id)
	expect(v_block != null, locale + " [Gate]: clinic visit opened for inpatient block test")
	if v_block != null:
		v_block.admitted = true
	g_unmet_artoria.active_id = ""
	set_exact_day_clock(g_unmet_artoria, 14, 990)
	expect(not g_unmet_artoria.character_event_available(def_lv3), locale + " [Gate]: blocked when unresolved admitted patient exists")
	if v_block != null:
		v_block.admitted = false

	# 2. S / O / G read-only dynamic branch resolution + Choice 1A S vs O/G + seasonal casual outfit
	# 2a) Default G (even when Emiko herself or a nurse was assistant)
	var g_branch := setup_ready_for_lv3(true, 10, 600)
	set_exact_day_clock(g_branch, 11, 990)
	var res_g: Dictionary = EmikoLv3.resolve_assistant_branch(g_branch)
	expect(str(res_g.branch) == "G", locale + " [SOG]: default branch is G")
	var ev_g = g_branch.start_character_event(LV3)
	expect(ev_g != null, locale + " [SOG]: starts in G mode")
	var visited_g: Array[String] = []
	while not ev_g.completed and visited_g.size() < 400:
		var nid := str(ev_g.node_id)
		visited_g.append(nid)
		var chs: Array = ev_g.current().choices
		var pick := str(chs[0].id)
		if nid == "em3_choice_c1":
			pick = "choice_em3_c1_a"
		elif nid == "em3_choice_c2":
			pick = "choice_em3_c2_b"
		elif nid == "em3_choice_c3":
			pick = "choice_em3_c3_c"
		# Check two-stage settlement right before and right after Scene 3 end!
		if nid == "em3_s3r_16":
			expect(not g_branch.procedure_unlocked("surgery_cabg") and g_branch.relationship_level("doc_emiko") == 2, locale + " [TwoStage]: before Scene 3 end CABG still locked & Lv2")
		expect(not g_branch.can_save_progress(), locale + " [Lock]: saving locked during Lv3 playback at " + nid)
		expect(g_branch.choose_character_event(pick), locale + " [SOG-G]: advance " + nid)
		if nid == "em3_s3r_16":
			expect(g_branch.procedure_unlocked("surgery_cabg") and g_branch.story_flag("emiko_cabg_teaching_complete") and g_branch.relationship_level("doc_emiko") == 2, locale + " [TwoStage]: Scene 3 end unlocks surgery_cabg while keeping Emiko at Lv2")
	expect(visited_g.has("em3_g_01") and visited_g.has("em3_c1a_og_01") and not visited_g.has("em3_c1a_s_01"), locale + " [SOG-G]: traversed G probe and O/G line in Choice 1A")
	expect(g_branch.relationship_level("doc_emiko") == 3 and g_branch.story_flag("emiko_lv3_complete"), locale + " [TwoStage]: @end promotes Emiko to Lv3")
	expect(not g_branch.story_flag("emiko_withdraws_director_candidacy") and not g_branch.story_flag("emiko_supports_sakaguchi_director"), locale + " [Flags]: zero surgery-director withdrawal flags set in Lv3")
	expect(not g_branch.staff_is_met("nurse_hiroko") and not g_branch.staff_is_met("nurse_moe"), locale + " [Cast]: Hiroko & Moe stay unmet without side effects")

	# 2b) Branch O (recent completed surgery with another doctor, e.g. `doc_sayaka`)
	var g_o := setup_ready_for_lv3(true, 11, 600)
	var o_pid := str(g_o.patient_queue[0])
	var o_suffix := o_pid.trim_prefix("patient_")
	var v_sora = g_o.open_visit("visit_" + o_suffix)
	expect(v_sora != null, locale + " [SOG-O]: opened visit during clinic hours")
	if v_sora != null:
		v_sora.admitted = true
	var p_sora = g_o.open_preop("preop_" + o_suffix)
	expect(p_sora != null, locale + " [SOG-O]: opened preop during clinic hours")
	if p_sora != null:
		p_sora.team["assistant_surgeon"] = "doc_sayaka"
		p_sora.surgery_success = true
	g_o.active_preop_id = ""
	g_o.active_id = ""
	if not g_o.recent_patient_ids.has(o_pid):
		g_o.recent_patient_ids.append(o_pid)
	set_exact_day_clock(g_o, 11, 990)
	var res_o: Dictionary = EmikoLv3.resolve_assistant_branch(g_o)
	expect(str(res_o.branch) == "O" and str(res_o.doctor_id) == "doc_sayaka", locale + " [SOG-O]: resolves doc_sayaka for O branch")
	var runtime_o: Dictionary = g_o.character_event_runtime_definition(LV3)
	var o_node_text := ""
	for n in runtime_o.nodes:
		if str(n.id) == "em3_o_02":
			o_node_text = str(n.text)
	expect(not o_node_text.contains("{recent_assistant_doctor}"), locale + " [SOG-O]: placeholder substituted cleanly")
	if locale == "zh_CN":
		expect(o_node_text.contains("南条小夜香"), "zh_CN [SOG-O]: canonical Chinese doctor name substituted without spaces")
	else:
		expect(o_node_text.contains("Dr. ") and cjk_re.search(o_node_text) == null, "en [SOG-O]: English Dr. name substituted with zero CJK")

	# 2c) Branch S (Artoria has served as first assistant) + winter casual check
	var g_s := setup_ready_for_lv3(true)
	g_s.set_test_character_progress_counter("doc_artoria", "completed_surgeries_as_assistant_surgeon", 1)
	g_s.advance_story_to_day(180, 990)
	while not EmikoLv3.calendar_safe_for_workday(g_s, g_s.current_workday()):
		g_s.advance_story_to_day(g_s.day_number() + 1, 990)
	var res_s: Dictionary = EmikoLv3.resolve_assistant_branch(g_s)
	expect(str(res_s.branch) == "S", locale + " [SOG-S]: resolves S branch when Artoria assisted")
	var ev_s = g_s.start_character_event(LV3)
	expect(ev_s != null, locale + " [SOG-S]: starts in S mode")
	var visited_s: Array[String] = []
	while not ev_s.completed and visited_s.size() < 400:
		var nid_s := str(ev_s.node_id)
		visited_s.append(nid_s)
		var chs_s: Array = ev_s.current().choices
		var pick_s := "choice_em3_c1_a" if nid_s == "em3_choice_c1" else str(chs_s[0].id)
		expect(g_s.choose_character_event(pick_s), locale + " [SOG-S]: advance " + nid_s)
	expect(visited_s.has("em3_s_01") and visited_s.has("em3_c1a_s_01") and not visited_s.has("em3_c1a_og_01"), locale + " [SOG-S]: traversed S probe and S line in Choice 1A")

	# 3. Full App UI test (including Relationship Progress UI before/after Artoria + overtime evening departure + next-day 14:00 settlement + EN CJK zero-leak)
	var app := MainScene.instantiate()
	app.title_notice_enabled = false
	app.saves.path = "/private/tmp/emiko_lv3_ui_unused_%s_%d.json" % [locale, OS.get_process_id()]
	app.title_preferences_path = "/private/tmp/emiko_lv3_ui_prefs_%s_%d.cfg" % [locale, OS.get_process_id()]
	root.add_child(app)
	await process_frame
	expect(app.content.load_all(locale), locale + " [UI]: app content load_all")
	app.configure_game_content()
	app.game = setup_ready_for_lv3(false)

	# Check Relationship Progress UI requirement text before vs after meeting Artoria
	app.show_office_relationship_detail("doc_emiko", true)
	await process_frame
	var req_label_before: RichTextLabel = app.page.get_node_or_null("RelationshipRequirementsText")
	expect(req_label_before != null, locale + " [ProgressUI]: RelationshipRequirementsText rendered when Artoria unmet")
	if req_label_before != null:
		if locale == "zh_CN":
			expect(req_label_before.text.contains("相关院内经历") and not req_label_before.text.contains("阿尔托莉雅"), "zh_CN [ProgressUI]: spoiler-safe hint before meeting Artoria")
		else:
			expect(cjk_re.search(req_label_before.text) == null and not req_label_before.text.contains("Artoria"), "en [ProgressUI]: spoiler-safe English hint before meeting Artoria")
	app.game.meet_staff("doc_artoria")
	app.show_office_relationship_detail("doc_emiko", true)
	await process_frame
	var req_label_after: RichTextLabel = app.page.get_node_or_null("RelationshipRequirementsText")
	var next_hint_after: Label = app.page.get_node_or_null("RelationshipNextHint")
	expect(req_label_after != null and next_hint_after != null, locale + " [ProgressUI]: RelationshipRequirementsText rendered once Artoria met")
	if req_label_after != null and locale == "zh_CN":
		expect(req_label_after.text.contains("阿尔托莉雅"), "zh_CN [ProgressUI]: displays Artoria name once met")
	elif req_label_after != null and locale == "en":
		expect(req_label_after.text.contains("Artoria") and cjk_re.search(req_label_after.text) == null, "en [ProgressUI]: displays Artoria name in English once met")

	# Simulate overtime departure on Friday Day 11 (`18:20` -> ledger rolls to Day 12 while `pending_day_exit_workday == 11`)
	set_exact_day_clock(app.game, 11, 1000)
	var before_ot: int = app.game.elapsed()
	app.game.story_time_advance_minutes += 100
	app.game.settle_overtime(before_ot, 100)
	expect(app.game.pending_day_exit_workday == 11 and app.game.day_number() == 12, locale + " [Overtime]: pending_day_exit_workday=11 while ledger day=12")
	expect(app._start_exclusive_departure_event(), locale + " [UI]: exclusive after_work departure launches Emiko Lv3")
	expect(str(app.game.active_character_event_id) == LV3, locale + " [UI]: active event is emiko_lv3_today_i_lead")

	var ui_choices_seen := 0
	var seen_speakers := {}
	var seen_patient_nodes := {}
	var saw_s2_16_reassurance_cg := false
	var ui_steps := 0
	while str(app.screen) == "character_event" and ui_steps < 600:
		ui_steps += 1
		var cur_ev = app.game.character_events[LV3]
		var cur_node: Dictionary = cur_ev.current()
		var cur_nid := str(cur_node.id)
		if cur_nid in ["em3_s2_03", "em3_s2_25", "em3_s2_28", "em3_s2_32"]:
			if app.page.get_node_or_null("EventPortrait_story_guest_cabg_patient") != null:
				seen_patient_nodes[cur_nid] = true
		if cur_nid == "em3_s2_16":
			var cg_rect := app.page.get_node_or_null("CharacterEventCG") as TextureRect
			if cg_rect != null and cg_rect.texture != null and cg_rect.texture.resource_path == "res://assets/events/emiko_lv1_3_cg_v1/lv3_reassurance.png":
				saw_s2_16_reassurance_cg = true
		if cur_nid == "em3_s2_03" or cur_nid == "em3_s2_28":
			var age_txt := str(cur_node.get("text", ""))
			if locale == "zh_CN":
				expect(age_txt.contains("二十七岁") and not age_txt.contains("五十二岁"), "zh_CN [Age27]: " + cur_nid + " shows age 27")
			else:
				expect(age_txt.contains("twenty-seven-year-old") and not age_txt.contains("fifty-two-year-old"), "en [Age27]: " + cur_nid + " shows age 27")
		if str(cur_node.get("presentation", "")) == "choice":
			ui_choices_seen += 1
			for c in cur_node.choices:
				if locale == "en":
					expect(cjk_re.search(str(c.label)) == null, "en [UI]: zero CJK in choice " + str(c.id))
			app.choose_character_event(str(cur_node.choices[0].id))
		else:
			var dlg = app.page.get_node_or_null("CharacterEventDialogue")
			if dlg != null:
				var spk_lbl := str(cur_node.get("speaker_label", ""))
				seen_speakers[spk_lbl] = true
				if locale == "en":
					expect(cjk_re.search(spk_lbl) == null, "en [UI]: zero CJK in speaker " + str(cur_node.id))
					expect(cjk_re.search(str(cur_node.get("text", ""))) == null, "en [UI]: zero CJK in text " + str(cur_node.id))
			var cont_btn = app.page.get_node_or_null("EventDialogueContinue")
			if cont_btn != null:
				app.advance_dialogue_page(app.show_character_event)
			else:
				app.choose_character_event(str(cur_node.choices[0].id))

	expect(ui_choices_seen == 3, locale + " [UI]: encountered all 3 choices")
	expect(saw_s2_16_reassurance_cg, locale + " [UI]: rendered lv3_reassurance.png CG on em3_s2_16")
	for pat_nid in ["em3_s2_03", "em3_s2_25", "em3_s2_28", "em3_s2_32"]:
		expect(seen_patient_nodes.has(pat_nid), locale + " [UI]: rendered 27yo CABG patient portrait on " + pat_nid)
	for pat_tex_path in [
		"res://assets/characters/emiko_lv3_v1/cabg_patient/or_cap/panicked.png",
		"res://assets/characters/emiko_lv3_v1/cabg_patient/or_cap/relieved.png",
		"res://assets/characters/emiko_lv3_v1/cabg_patient/or_cap/mask_drowsy.png",
	]:
		var ptex := load(pat_tex_path) as Texture2D
		expect(ptex != null and ptex.get_width() == 1448 and ptex.get_height() == 1086, locale + " [Asset]: 1448x1086 Texture2D loaded " + pat_tex_path)
	expect(str(app.screen) == "character_event_complete", locale + " [UI]: landed on completion screen")
	expect(app.game.pending_day_exit_workday == 0, locale + " [UI]: overtime pending_day_exit_workday cleared cleanly")
	expect(app.game.day_number() == 12 and app.game.clock_text() == "14:00", locale + " [UI]: settled at Friday Day 12 14:00 (`workday + 1`)")

	if locale == "zh_CN":
		for req_spk in ["旁白", "御堂江美子", "坂口隆司", "杉村弘子", "本庄萌恵", "寿司店师傅", "患者", "麻醉医生", "灌注师"]:
			expect(seen_speakers.has(req_spk), "zh_CN [UI]: speaker rendered: " + req_spk)
	else:
		for req_spk in ["Narrator", "Emiko Mido", "Ryuji Sakaguchi", "Hiroko Sugimura", "Moe Honjo", "Sushi Chef", "Patient", "Anesthesiologist", "Perfusionist"]:
			expect(seen_speakers.has(req_spk), "en [UI]: speaker rendered: " + req_spk)

	app.game.finish_character_event()
	app.show_map(false)
	expect(app.game.can_save_progress(), locale + " [UI]: save unlocked on Hospital Guide at Friday 14:00")

	# 4. BoundarySave v37 inner-state purity & reload stability
	var tmp_save := "/private/tmp/emiko_lv3_v11_test_%s_%d.json" % [locale, OS.get_process_id()]
	var store := Store.new()
	store.path = tmp_save
	expect(store.write_slot(app.game, 1), locale + " [Save]: write_slot to /private/tmp")
	var raw_json := FileAccess.get_file_as_string(tmp_save)
	for forbidden_inner in ["em3_s1_01", "em3_o_02", "em3_choice_c1", "choice_em3_c1_a", "em3_cabg_teaching_complete", "recent_assistant_doctor"]:
		expect(not raw_json.contains(forbidden_inner), locale + " [Save]: persisted file free of inner ID " + forbidden_inner)

	var reloaded := new_game()
	expect(store.read_slot(reloaded, 1), locale + " [Save]: read_slot from /private/tmp")
	expect(reloaded.relationship_level("doc_emiko") == 3 and int(reloaded.relation_for("doc_emiko").familiarity) == 40, locale + " [Save]: reloaded preserves Lv3 and Familiarity=40")
	expect(reloaded.procedure_unlocked("surgery_cabg") and restored_clock_matches(reloaded, app.game), locale + " [Save]: reloaded preserves surgery_cabg unlock and exact Friday 14:00 clock")
	expect(not reloaded.character_event_available(reloaded.character_event_definitions[LV3]), locale + " [Save]: completed Lv3 does NOT re-trigger after reload")
	DirAccess.remove_absolute(tmp_save)

	root.remove_child(app)
	app.free()

func restored_clock_matches(a: RefCounted, b: RefCounted) -> bool:
	return a.elapsed() == b.elapsed() and a.day_number() == b.day_number() and a.clock_text() == b.clock_text()

func run() -> void:
	await run_for_locale("zh_CN")
	await run_for_locale("en")
	if failures.is_empty():
		print("EMIKO LV3 V1.1 TEST PASS: %d checks, 0 failure(s)." % checks)
		quit(0)
	else:
		for item in failures:
			push_error(item)
		print("EMIKO LV3 V1.1 TEST FAIL: %d failure(s) out of %d checks." % [failures.size(), checks])
		quit(1)
