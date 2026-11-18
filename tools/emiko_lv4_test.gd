extends SceneTree
## Headless integration, gate, 9-path graph, H Runner placeholder round-trip,
## Scene 6.2 atomic Lv4 settlement, Free H pending-assets UI, Nurse Ange fallback,
## bilingual zero-CJK-leak, and v37 save-boundary test for Emiko Mido (`doc_emiko`) Lv4:
## 《御堂江美子的秘密》 (`emiko_lv4_emikos_secret`, V1.1).

const ContentLoader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const EmikoLv4 = preload("res://godot/systems/emiko_lv4.gd")
const FreeHRegistry = preload("res://godot/systems/free_h_registry.gd")
const Store = preload("res://godot/systems/save_store.gd")
const MainScene = preload("res://godot/scenes/main.tscn")

const LV0 := "emiko_intro_rumored_hands"
const LV1 := "emiko_lv1_first_operation"
const LV2 := "emiko_lv2_follow_my_lead"
const LV3 := "emiko_lv3_today_i_lead"
const LV4 := "emiko_lv4_emikos_secret"

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

func setup_ready_for_lv4(target_day: int = 15, target_clock: int = 990) -> RefCounted:
	var g := new_game()
	set_exact_day_clock(g, 1, 600)
	g._complete_character_event_for_test("intro_doc_asuka_director_office", 1)
	g.meet_staff("doc_asuka")
	g._complete_character_event_for_test("asuka_mentions_artoria_rival", 1)
	g.meet_staff("doc_artoria")
	g._complete_character_event_for_test("intro_doc_artoria_deputy_office", 2)

	g.set_test_player_attribute("skill", 70)
	expect(finish_event(g, LV0), "Lv0 completes at Surgery 70")

	g.advance_story_to_day(4, 600)
	g.set_test_player_attribute("skill", 75)
	expect(finish_event(g, LV1), "Lv1 completes at Surgery 75")

	g.advance_story_to_day(8, 600)
	g.set_test_player_attribute("skill", 80)
	expect(finish_event(g, LV2), "Lv2 completes at Surgery 80")

	set_exact_day_clock(g, 11, 990)
	g.relation_for("doc_emiko").familiarity = 40
	g.set_test_player_attribute("presence", 20)
	expect(finish_event(g, LV3), "Lv3 completes on Day 11 (Friday 2025-04-11)")

	# Day 15 = Tuesday 2025-04-15 (>= Day 11 + 3, routine workday with open Wednesday Day 16)
	set_exact_day_clock(g, target_day, target_clock)
	g.relation_for("doc_emiko").familiarity = 55
	g.set_test_player_attribute("presence", 30)
	return g

func restored_clock_matches(a: RefCounted, b: RefCounted) -> bool:
	return a.elapsed() == b.elapsed() and a.day_number() == b.day_number() and a.clock_text() == b.clock_text()

func run_for_locale(locale: String) -> void:
	content = ContentLoader.new()
	expect(content.load_all(locale), locale + ": ContentLoader.load_all succeeds")

	# 1. Gate, cooldown, calendar, inpatient, and referral-conflict tests
	var g_gate := setup_ready_for_lv4(15, 990)
	var def_lv4: Dictionary = g_gate.character_event_definitions[LV4]
	expect(g_gate.character_event_available(def_lv4), locale + " [Gate]: Lv4 available at Lv3 + Fam 55 + Presence +30 + Day 15 16:30")

	# Familiarity 54 blocked, 55 allowed
	g_gate.relation_for("doc_emiko").familiarity = 54
	expect(not g_gate.character_event_available(def_lv4), locale + " [Gate]: blocked at Familiarity 54")
	g_gate.relation_for("doc_emiko").familiarity = 55

	# Presence +29 blocked, +30 allowed
	g_gate.set_test_player_attribute("presence", 29)
	expect(not g_gate.character_event_available(def_lv4), locale + " [Gate]: blocked at Presence +29")
	g_gate.set_test_player_attribute("presence", 30)

	# No extra Surgery >= 90 or Charm gate (Surgery 90 belongs strictly to Lv5)
	g_gate.set_test_player_attribute("skill", 0)
	g_gate.set_test_player_attribute("charm", -20)
	expect(g_gate.character_event_available(def_lv4), locale + " [Gate]: Lv4 does NOT require extra Surgery 90 or Charm")
	g_gate.set_test_player_attribute("skill", 80)
	g_gate.set_test_player_attribute("charm", 0)

	# Cooldown: Lv3 completed on Day 11 -> Day 13 (2-day gap) blocked even if weekday; test with Lv3 on Day 11 vs Day 12
	var g_cd := setup_ready_for_lv4(15, 990)
	g_cd.character_events[LV3].completed_day = 13
	expect(not g_cd.character_event_available(def_lv4), locale + " [Cooldown]: blocked on 2-day gap (Day 15 after Day 13)")
	g_cd.character_events[LV3].completed_day = 12
	expect(g_cd.character_event_available(def_lv4), locale + " [Cooldown]: unlocked on exact 3-day gap (Day 15 after Day 12)")

	# Daytime clinic clock (10:00 = 600): excluded from daytime location triggers (`character_events_at("or")`), while flagged as tonight's `free_h_known_conflict()`
	set_exact_day_clock(g_gate, 15, 600)
	var daytime_or_ids: Array[String] = []
	for d in g_gate.character_events_at("or"):
		daytime_or_ids.append(str(d.get("id", "")))
	expect(not daytime_or_ids.has(LV4), locale + " [Clock]: after_work Lv4 never triggers as a daytime OR location event at 10:00")
	expect(g_gate.free_h_known_conflict(), locale + " [Clock]: due after_work Lv4 registers free_h_known_conflict during daytime")
	set_exact_day_clock(g_gate, 15, 990)
	expect(str(g_gate.next_after_work_character_event().get("id", "")) == LV4, locale + " [Clock]: selected by next_after_work_character_event at 16:30")

	# Saturday (Day 19 = Saturday 2025-04-19, next day Sunday Day 20 closed) blocked
	set_exact_day_clock(g_gate, 19, 990)
	expect(not g_gate.character_event_available(def_lv4), locale + " [Calendar]: blocked on Saturday when next day is closed Sunday")
	# Monday Day 28 (2025-04-28) precedes Showa Day Tuesday 2025-04-29 (closed holiday Day 29) -> blocked
	set_exact_day_clock(g_gate, 28, 990)
	if g_gate.is_hospital_closed_day(29):
		expect(not g_gate.character_event_available(def_lv4), locale + " [Calendar]: blocked on workday preceding closed holiday")
	set_exact_day_clock(g_gate, 15, 990)

	# Next-day Advanced Referral operation/review conflict blocked
	g_gate.advanced_referral_facts["appointment"] = {"operation_day": 16, "review_day": 18}
	expect(not g_gate.character_event_available(def_lv4), locale + " [Referral]: blocked when Advanced Referral operation is on next day")
	g_gate.advanced_referral_facts.erase("appointment")
	expect(g_gate.character_event_available(def_lv4), locale + " [Referral]: available again once referral conflict cleared")

	# Admitted inpatient awaiting surgery blocks Lv4
	var q_pid := str(g_gate.patient_queue[0])
	var q_suffix := q_pid.trim_prefix("patient_")
	set_exact_day_clock(g_gate, 15, 600)
	var v_in = g_gate.open_visit("visit_" + q_suffix)
	if v_in != null:
		v_in.admitted = true
	g_gate.active_id = ""
	set_exact_day_clock(g_gate, 15, 990)
	expect(not g_gate.character_event_available(def_lv4), locale + " [Inpatient]: blocked while admitted patient awaits surgery")

	# 2. All 9 interactive paths (`3 x 3`), zero choice stat/flag delta, atomic settlement only after 6.2
	for c1 in ["choice_em4_c1_a", "choice_em4_c1_b", "choice_em4_c1_c"]:
		for c2 in ["choice_em4_c2_a", "choice_em4_c2_b", "choice_em4_c2_c"]:
			var gp := setup_ready_for_lv4(15, 990)
			var fam_before := int(gp.relation_for("doc_emiko").familiarity)
			var attrs_before: Dictionary = gp.player_attributes().duplicate(true)
			var ev = gp.start_character_event(LV4)
			expect(ev != null, locale + " [9Path]: start " + c1 + "+" + c2)
			var saw_h_node := false
			var guard := 0
			while not ev.completed and guard < 400:
				guard += 1
				var nid := str(ev.node_id)
				if nid == "em4_s6_1_24":
					saw_h_node = true
					expect(gp.relationship_level("doc_emiko") == 3 and not gp.story_flag("emiko_lv4_complete"), locale + " [Atomic]: still Lv3 at Scene 6.1 H handoff")
				var chs: Array = ev.current().choices
				var pick := str(chs[0].id)
				if nid == "em4_choice_c1":
					pick = c1
				elif nid == "em4_choice_c2":
					pick = c2
				expect(gp.choose_character_event(pick), locale + " [9Path]: advance " + nid)
			expect(ev.completed and saw_h_node, locale + " [9Path]: completed " + c1 + "+" + c2)
			expect(gp.relationship_level("doc_emiko") == 4 and gp.story_flag("emiko_lv4_complete"), locale + " [9Path]: promoted to Lv4 after 6.2")
			expect(int(gp.relation_for("doc_emiko").familiarity) == fam_before and gp.player_attributes() == attrs_before, locale + " [9Path]: zero stat/familiarity mutation from choices")
			expect(gp.relation_for("doc_emiko").unlocked_benefits.has("unlock_intimacy_events") and gp.relation_for("doc_emiko").unlocked_benefits.has("unlock_emiko_surgical_team"), locale + " [9Path]: intimacy & surgical team benefits active")
			expect(not gp.story_flag("emiko_withdraws_director_candidacy") and not gp.story_flag("emiko_supports_sakaguchi_director"), locale + " [9Path]: zero Chief-of-Surgery yield flags")
			gp.finish_character_event()

	# 3. Final two campaign days (`Day 364` & `Day 365`, 2026-03-30..31) blocked; `Day 361` (Friday 2026-03-27) allowed with Anji Tonegawa directly on cast
	var g_end := setup_ready_for_lv4(361, 990)
	expect(g_end.character_event_available(def_lv4), locale + " [FinalDays]: Friday Day 361 (before final two days) is eligible")
	set_exact_day_clock(g_end, 364, 990)
	expect(not g_end.character_event_available(def_lv4), locale + " [FinalDays]: Day 364 (penultimate day / Anji departure window) is strictly blocked")
	set_exact_day_clock(g_end, 365, 990)
	expect(not g_end.character_event_available(def_lv4), locale + " [FinalDays]: Day 365 (final day) is strictly blocked")

	# 4. Full App UI Playthrough (`zh_CN` & `en`), H Runner Placeholder screen, Save Lock, Free H Pending-Assets Staff UI, and v37 Save Round-Trip
	var app := MainScene.instantiate()
	app.title_notice_enabled = false
	app.saves.path = "/private/tmp/emiko_lv4_ui_unused_%s_%d.json" % [locale, OS.get_process_id()]
	app.title_preferences_path = "/private/tmp/emiko_lv4_ui_prefs_%s_%d.cfg" % [locale, OS.get_process_id()]
	root.add_child(app)
	await process_frame
	expect(app.content.load_all(locale), locale + " [UI]: app content load_all")
	app.configure_game_content()
	app.game = setup_ready_for_lv4(15, 990)

	# Verify Overtime evening departure launches Emiko Lv4
	set_exact_day_clock(app.game, 15, 1000)
	var before_ot: int = app.game.elapsed()
	app.game.story_time_advance_minutes += 100
	app.game.settle_overtime(before_ot, 100)
	expect(app.game.pending_day_exit_workday == 15 and app.game.day_number() == 16, locale + " [Overtime]: pending_day_exit_workday=15 while ledger day=16")
	expect(app._start_exclusive_departure_event(), locale + " [UI]: exclusive after_work departure launches Emiko Lv4")
	expect(str(app.game.active_character_event_id) == LV4, locale + " [UI]: active event is emiko_lv4_emikos_secret")

	var ui_choices_seen := 0
	var saw_milestone_h_runner := false
	var saw_scene1_cg_immersed := false
	var saw_scene1_cg_startled := false
	var saw_sakurai_portrait := false
	var saw_ange_portrait := false
	var seen_speakers := {}
	var ui_steps := 0
	while str(app.screen) in ["character_event", "h_profile_test"] and ui_steps < 650:
		ui_steps += 1
		if str(app.screen) == "h_profile_test":
			saw_milestone_h_runner = true
			expect(app.h_profile_event_mode and str(app.h_profile_run_kind) == "milestone", locale + " [MilestoneH]: launches real H Runner in milestone mode")
			expect(app.h_profile_test_entry_lines.is_empty(), locale + " [MilestoneH]: skips generic Free H entry line")
			expect(not app.game.can_save_progress(), locale + " [MilestoneH]: save remains locked during milestone H Runner")
			expect(app.game.relationship_level("doc_emiko") == 3, locale + " [MilestoneH]: Emiko still Lv3 during milestone H Runner")
			expect(app.h_profile_test_session != null and str(app.h_profile_test_session.actor_id) == "doc_emiko", locale + " [MilestoneH]: session bound to doc_emiko")
			expect(str(app.h_profile_test_session.background_id("")) == "operating_room", locale + " [MilestoneH]: background locked to operating_room")
			var body_node := app.page.get_node_or_null("HProfileBodyMap") as TextureRect
			expect(body_node != null and body_node.texture != null and body_node.texture.resource_path == "res://assets/h/doc_emiko/body_map.png", locale + " [MilestoneH]: renders Emiko body_map.png")
			while app.h_profile_test_session.excitement < 100:
				app.h_profile_test_last_result = app.h_profile_test_session.perform("kiss", "lips")
			app.show_sayaka_h_profile_test()
			expect(app.page.get_node_or_null("HProfileStyleGentle") != null and app.page.get_node_or_null("HProfileStyleIntense") != null, locale + " [MilestoneH]: renders gentle and intense entry choices")
			var style_id := "gentle" if locale == "zh_CN" else "intense"
			app._choose_sayaka_h_entry_style(style_id)
			expect(app.h_profile_test_session.selected_h_scene_lines.size() == 6, locale + " [MilestoneH]: Phase 2 uses pure 6-line Emiko sequence without Sayaka overlay")
			for stage_idx in range(6):
				var stage_img := app.page.get_node_or_null("HProfileSceneImage") as TextureRect
				expect(stage_img != null and stage_img.texture != null and stage_img.texture.resource_path == "res://assets/h/doc_emiko/scene_cg.png", locale + " [MilestoneH]: renders Emiko scene_cg.png at step " + str(stage_idx))
				var stage_txt := app.page.get_node_or_null("HProfileDialogueText") as Label
				expect(stage_txt != null and not stage_txt.text.is_empty(), locale + " [MilestoneH]: non-empty stage text at step " + str(stage_idx))
				if locale == "en" and stage_txt != null:
					expect(cjk_re.search(stage_txt.text) == null, "en [MilestoneH]: zero CJK in stage text at step " + str(stage_idx))
				app._advance_sayaka_h_stage()
			expect(str(app.h_profile_test_session.phase) == "h_finish_wait", locale + " [MilestoneH]: reaches manual finish wait")
			app._choose_sayaka_h_finish()
			expect(str(app.h_profile_test_session.phase) == "h_finish_response", locale + " [MilestoneH]: reaches finish response")
			app._advance_sayaka_h_stage()
			await create_timer(4.8).timeout
			expect(app.h_profile_test_session == null and not app.h_profile_event_mode, locale + " [MilestoneH]: clears H Runner session cleanly")
			expect(str(app.screen) == "character_event" and str(app.game.character_events[LV4].node_id) == "em4_s6_2_01", locale + " [MilestoneH]: skips generic Free H aftercare and returns to em4_s6_2_01")
			continue

		var cur_ev = app.game.character_events[LV4]
		var cur_node: Dictionary = cur_ev.current()
		var cur_nid := str(cur_node.id)
		var cg_node := app.page.get_node_or_null("CharacterEventCG") as TextureRect
		if cg_node != null and cg_node.texture != null:
			if cg_node.texture.resource_path == "res://assets/events/emiko_lv4_cg_v1/lv4_or_secret_immersed.png":
				saw_scene1_cg_immersed = true
			elif cg_node.texture.resource_path == "res://assets/events/emiko_lv4_cg_v1/lv4_or_secret_startled.png":
				saw_scene1_cg_startled = true
		if app.page.get_node_or_null("EventPortrait_patient_sakurai_mayumi") != null:
			saw_sakurai_portrait = true
		if app.page.get_node_or_null("EventPortrait_nurse_ange") != null:
			saw_ange_portrait = true

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
					expect(cjk_re.search(spk_lbl) == null, "en [UI]: zero CJK in speaker " + cur_nid)
					expect(cjk_re.search(str(cur_node.get("text", ""))) == null, "en [UI]: zero CJK in text " + cur_nid)
			var cont_btn = app.page.get_node_or_null("EventDialogueContinue")
			if cont_btn != null:
				app.advance_dialogue_page(app.show_character_event)
			else:
				app.choose_character_event(str(cur_node.choices[0].id))

	expect(ui_choices_seen == 2, locale + " [UI]: encountered both interactive choices")
	expect(saw_scene1_cg_immersed and saw_scene1_cg_startled, locale + " [UI]: rendered both Scene 1 secret CG variants (immersed + startled)")
	expect(saw_milestone_h_runner, locale + " [UI]: traversed real milestone H Runner")
	expect(saw_sakurai_portrait, locale + " [UI]: rendered Mayumi Sakurai intraoperative portrait in Scene 5")
	expect(saw_ange_portrait, locale + " [UI]: rendered Anji Tonegawa portrait in Scene 5")
	expect(str(app.screen) == "character_event_complete", locale + " [UI]: landed on completion screen after Scene 6.2")
	expect(app.game.pending_day_exit_workday == 0, locale + " [UI]: overtime pending_day_exit_workday cleared cleanly")
	expect(app.game.day_number() == 16 and app.game.clock_text() == "09:00", locale + " [UI]: settled at Wednesday Day 16 09:00 (`workday + 1`)")

	if locale == "zh_CN":
		for req_spk in ["旁白", "御堂江美子", "坂口隆司", "杉村弘子", "利根川安琪", "樱井真弓"]:
			expect(seen_speakers.has(req_spk), "zh_CN [UI]: speaker rendered: " + req_spk)
	else:
		for req_spk in ["Narrator", "Emiko Mido", "Ryuji Sakaguchi", "Hiroko Sugimura", "Anji Tonegawa", "Mayumi Sakurai"]:
			expect(seen_speakers.has(req_spk), "en [UI]: speaker rendered: " + req_spk)

	app.game.finish_character_event()
	app.show_map(false)
	expect(app.game.can_save_progress(), locale + " [UI]: save unlocked on Hospital Guide at Wednesday 09:00")

	# Verify Free H Unlocked Booking UI on Emiko's Staff View
	expect(app.game.free_h_relationship_qualified("doc_emiko") and app.game.free_h_unlocked("doc_emiko"), locale + " [FreeH]: Free H unlocked after Lv4 with ready content_status")
	var present_loc := ""
	for loc_def in app.content.collections.locations:
		if "doc_emiko" in app.game.staff_present_at(str(loc_def.id)):
			present_loc = str(loc_def.id)
			break
	expect(not present_loc.is_empty() and app.game.can_book_free_h("doc_emiko", present_loc), locale + " [FreeH]: can_book_free_h active at " + present_loc)
	app.show_staff("doc_emiko", present_loc)
	await process_frame
	var book_btn: Button = app.page.get_node_or_null("FreeHBooking")
	expect(book_btn != null and not book_btn.disabled, locale + " [FreeH]: StaffView renders enabled FreeHBooking button")
	expect(app.page.get_node_or_null("FreeHBookingPendingAssets") == null, locale + " [FreeH]: pending-assets button no longer shown")
	if locale == "en" and book_btn != null:
		expect(cjk_re.search(book_btn.text) == null, "en [FreeH]: zero CJK in FreeHBooking label")

	app.show_map(false)

	# 5. BoundarySave v37 inner-state purity & reload stability
	var tmp_save := "/private/tmp/emiko_lv4_v11_test_%s_%d.json" % [locale, OS.get_process_id()]
	var store := Store.new()
	store.path = tmp_save
	expect(store.write_slot(app.game, 1), locale + " [Save]: write_slot to /private/tmp")
	var raw_json := FileAccess.get_file_as_string(tmp_save)
	for forbidden_inner in ["em4_s1_01", "em4_s6_1_24", "em4_s6_2_01", "em4_choice_c1", "choice_em4_c1_a", "launch_emiko_lv4_h", "emiko_lv4_h_placeholder", "emiko_lv4_first_h"]:
		expect(not raw_json.contains(forbidden_inner), locale + " [Save]: persisted file free of inner ID " + forbidden_inner)

	var reloaded := new_game()
	expect(store.read_slot(reloaded, 1), locale + " [Save]: read_slot from /private/tmp")
	expect(reloaded.relationship_level("doc_emiko") == 4 and int(reloaded.relation_for("doc_emiko").familiarity) == 55, locale + " [Save]: reloaded preserves Lv4 and Familiarity=55")
	expect(reloaded.story_flag("emiko_lv4_complete") and reloaded.free_h_unlocked("doc_emiko"), locale + " [Save]: reloaded preserves emiko_lv4_complete and unlocked Free H")
	expect(restored_clock_matches(reloaded, app.game), locale + " [Save]: reloaded preserves exact Wednesday Day 16 09:00 clock")
	expect(not reloaded.character_event_available(reloaded.character_event_definitions[LV4]), locale + " [Save]: completed Lv4 does NOT re-trigger after reload")
	DirAccess.remove_absolute(tmp_save)
	DirAccess.remove_absolute(app.saves.path)
	DirAccess.remove_absolute(app.title_preferences_path)

	root.remove_child(app)
	app.free()

func run() -> void:
	await run_for_locale("zh_CN")
	await run_for_locale("en")
	if failures.is_empty():
		print("EMIKO LV4 V1.1 TEST PASS: %d checks, 0 failure(s)." % checks)
		quit(0)
	else:
		for item in failures:
			push_error(item)
		print("EMIKO LV4 V1.1 TEST FAIL: %d failure(s) out of %d checks." % [failures.size(), checks])
		quit(1)
