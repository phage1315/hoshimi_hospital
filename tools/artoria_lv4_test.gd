extends SceneTree
## Headless integration, gate, Sunday invitation entry, H Runner placeholder
## non-early-settlement, Monday 09:00 atomic settlement, Free H pending_assets
## lock, wardrobe unlock, bilingual UI, and v37 BoundarySave test for
## Artoria Pendragon (`doc_artoria`) Relationship Lv4:
## 《只是阿尔托莉雅》 (`artoria_lv4_just_artoria`, V1.1).

const ContentLoader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const ArtoriaLv4 = preload("res://godot/systems/artoria_lv4.gd")
const FreeHRegistry = preload("res://godot/systems/free_h_registry.gd")
const Store = preload("res://godot/systems/save_store.gd")
const MainScene = preload("res://godot/scenes/main.tscn")

const LV3 := "artoria_lv3_not_a_solo_operation"
const LV4 := "artoria_lv4_just_artoria"

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
		push_error(msg)

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

func set_exact_day_clock(g: RefCounted, target_day: int, absolute_clock: int) -> void:
	g.discarded_overtime_minutes = 0
	g.story_time_advance_minutes = 0
	var base_elapsed: int = g.elapsed()
	var desired_total: int = (maxi(1, target_day) - 1) * int(g.SHIFT_MINUTES) + clampi(absolute_clock - int(g.SHIFT_START_MINUTE), 0, int(g.SHIFT_MINUTES) - 1)
	g.story_time_advance_minutes = maxi(0, desired_total - base_elapsed)

func setup_ready_for_lv4(target_day: int = 13, target_clock: int = 540) -> RefCounted:
	var g := new_game()
	ArtoriaLv4.prepare_test_save(g, LV4, target_day)
	set_exact_day_clock(g, target_day, target_clock)
	return g

func assert_no_inner_state(raw: Dictionary, label: String) -> void:
	var raw_json := JSON.stringify(raw)
	for forbidden in ["ar4_s1_", "ar4_s2_", "ar4_s3_", "ar4_s4_", "ar4_s5_", "ar4_s6_", "ar4_choice_", "choice_ar4_", "node_id", "last_choice", "dialogue_page", "artoria_lv4_h_placeholder"]:
		expect(raw_json.find(forbidden) == -1, "%s: persisted save contains forbidden token %s" % [label, forbidden])

func test_gates_and_calendar(locale: String) -> void:
	var def: Dictionary = content.find_record("character_events", LV4)
	expect(not def.is_empty(), locale + ": artoria_lv4_just_artoria loaded")

	# Day 13 is Sunday 2025-04-13 (3 days after Day 10 Lv3)
	var g := setup_ready_for_lv4(13, 540)
	expect(g.is_sunday(), locale + " [Calendar]: Day 13 is Sunday")
	g.set_test_player_attribute("skill", 5)
	g.set_test_player_attribute("charm", 0)
	g.set_test_player_attribute("reputation", 0)

	# 1. Familiarity boundary (54 vs 55) & Leadership boundary (84 vs 85), zero Surgery/Charm/Reputation/date-count lock
	g.relation_for("doc_artoria").familiarity = 54
	expect(not g.character_event_available(def), locale + " [Gate]: Familiarity 54 blocked")
	g.relation_for("doc_artoria").familiarity = 55
	expect(g.character_event_available(def), locale + " [Gate]: Familiarity 55 + Leadership 85 allowed without Surgery/Charm/date-count gate")

	g.set_test_player_attribute("leadership", 84)
	expect(not g.character_event_available(def), locale + " [Gate]: Leadership 84 blocked")
	g.set_test_player_attribute("leadership", 85)
	expect(g.character_event_available(def), locale + " [Gate]: Leadership 85 allowed")

	# 2. 3-day milestone cooldown: if Lv3 finished on Day 11 (Friday), Sunday Day 13 (+2d) is blocked; next Sunday Day 20 (+9d) is allowed
	var g_cd := setup_ready_for_lv4(13, 540)
	g_cd.character_events[LV3].completed_day = 11
	expect(not g_cd.character_event_available(def), locale + " [Gate]: 2-day gap blocked by 3-day cooldown")
	set_exact_day_clock(g_cd, 20, 540)
	expect(g_cd.character_event_available(def), locale + " [Gate]: next Sunday Day 20 allowed")

	# 3. Non-Sunday weekdays/Saturdays blocked; already-spent Sunday blocked; month-neutral across winter/summer Sundays
	expect(not setup_ready_for_lv4(14, 540).character_event_available(def), locale + " [Calendar]: Monday Day 14 blocked")
	expect(not setup_ready_for_lv4(19, 540).character_event_available(def), locale + " [Calendar]: Saturday Day 19 blocked")
	expect(setup_ready_for_lv4(132, 540).character_event_available(def), locale + " [Calendar]: Summer Sunday Day 132 allowed (no month gate)")
	expect(setup_ready_for_lv4(286, 540).character_event_available(def), locale + " [Calendar]: Winter Sunday Day 286 allowed (no month gate)")
	expect(not setup_ready_for_lv4(364, 540).character_event_available(def), locale + " [Calendar]: Day 364 blocked")
	expect(not setup_ready_for_lv4(365, 540).character_event_available(def), locale + " [Calendar]: Day 365 blocked")

	var g_spent := setup_ready_for_lv4(13, 540)
	g_spent.sunday_history.append({"day": 13, "activity_id": "rest_home", "actor_id": "", "location_id": ""})
	expect(not g_spent.character_event_available(def), locale + " [Calendar]: already-spent Sunday blocked")

	# 4. Priority in Sunday candidate list
	var cands: Array[String] = g.sunday_date_candidates()
	expect(not cands.is_empty() and cands[0] == "doc_artoria", locale + " [Sunday]: Artoria prioritized first in Sunday date candidates")
	expect(str(g.sunday_character_event_for("doc_artoria").get("id", "")) == LV4, locale + " [Sunday]: sunday_character_event_for returns Lv4")

	# 5. Story guests never leak into random patient pools or queues
	for p in content.collections.patients:
		var pid := str(p.get("id", ""))
		var pname := str(p.get("name", ""))
		expect(pid.find("taiga") == -1 and pid.find("irisviel") == -1 and pname.find("大河") == -1 and pname.find("爱丽丝菲尔") == -1, locale + " [Isolation]: guest patient not in random pool")

func test_branches_save_and_rename_resilience(locale: String) -> void:
	for branch in ["a", "b", "c"]:
		var g := setup_ready_for_lv4(13, 540)
		var unlocked_before: Array = g.unlocked_procedure_ids.duplicate()
		var ev = g.start_character_event(LV4)
		expect(ev != null, "%s [%s]: started Lv4" % [locale, branch])
		expect(g.reserve_sunday_character_event(LV4), "%s [%s]: reserved Sunday Lv4" % [locale, branch])

		var picks := ["choice_ar4_c1_" + branch, "choice_ar4_c2_" + branch, "choice_ar4_c3_" + branch]
		var visited: Array[String] = []
		while not ev.completed and visited.size() < 400:
			var cur: Dictionary = ev.current()
			var nid := str(cur.id)
			visited.append(nid)
			expect(not g.can_save_progress(), "%s [%s]: save locked at %s" % [locale, branch, nid])
			if locale == "en":
				expect(cjk_re.search(str(cur.get("text", ""))) == null, "en [%s]: CJK in text at %s" % [branch, nid])
				expect(cjk_re.search(str(cur.get("speaker_label", ""))) == null, "en [%s]: CJK in speaker_label at %s" % [branch, nid])
			var chosen := str(cur.choices[0].id)
			for want in picks:
				for ch in cur.choices:
					if str(ch.id) == want:
						chosen = want
						break
			expect(g.choose_character_event(chosen), "%s [%s]: chose %s at %s" % [locale, branch, chosen, nid])
			if not ev.completed:
				expect(g.relationship_level("doc_artoria") == 3 and not g.story_flag("artoria_lv4_complete"), "%s [%s]: still Lv3 mid-event (including across H handoff & night aftercare)" % [locale, branch])

		expect(ev.completed, "%s [%s]: completed Lv4" % [locale, branch])
		expect(visited.has("ar4_s5_1_26") and visited.has("ar4_s5_2_01") and visited.has("ar4_s6_1_07") and visited.has("ar4_s6_2m_13"), "%s [%s]: traversed 5.1 -> 5.2 -> 6.1 -> 6.2m" % [locale, branch])

		g.advance_story_to_day(int(ev.completed_day) + 1, 540)
		g.finish_character_event()

		expect(g.day_number() == 14 and g.clock_text() == "09:00", "%s [%s]: settled at Monday Day 14 09:00 without consuming Monday shift minutes" % [locale, branch])
		expect(g.relationship_level("doc_artoria") == 4, "%s [%s]: Artoria promoted Lv3 -> Lv4" % [locale, branch])
		expect(g.relation_for("doc_artoria").unlocked_benefits.has("unlock_intimacy_events"), "%s [%s]: unlock_intimacy_events granted" % [locale, branch])
		expect(int(g.relation_for("doc_artoria").familiarity) == 55, "%s [%s]: familiarity unchanged by choices" % [locale, branch])
		expect(g.story_flag("artoria_lv4_complete"), "%s [%s]: artoria_lv4_complete set" % [locale, branch])
		expect(g.unlocked_procedure_ids == unlocked_before, "%s [%s]: no extra procedure unlocked in Lv4" % [locale, branch])
		expect(g.free_h_relationship_qualified("doc_artoria") and g.free_h_unlocked("doc_artoria") and g.can_book_free_h("doc_artoria", "artoria_office"), "%s [%s]: Free H relationship-qualified & unlocked at home after Lv4" % [locale, branch])
		for chief_flag in g.story_flags.keys():
			expect(str(chief_flag).find("yield") == -1 and str(chief_flag).find("withdraw") == -1 and str(chief_flag).find("maiya") == -1, "%s [%s]: zero Chief yield or Maiya flags touched" % [locale, branch])

		# v37 BoundarySave purity + internal node rename resilience
		var tmp_save := "/private/tmp/hoshimi_artoria_lv4_test_%s_%s_%d.json" % [locale, branch, OS.get_process_id()]
		var store := Store.new()
		store.path = tmp_save
		expect(store.write_slot(g, 1), "%s [%s]: saved slot 1" % [locale, branch])
		var raw1: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(tmp_save))
		assert_no_inner_state(raw1, "%s [%s]" % [locale, branch])

		var g2 := new_game()
		# Mutate internal node IDs in g2's definition before restore to prove node-rename resilience
		var mutated_def: Dictionary = g2.character_event_definitions[LV4].duplicate(true)
		mutated_def["start"] = "ar4_renamed_open_01"
		mutated_def["nodes"][0]["id"] = "ar4_renamed_open_01"
		g2.character_event_definitions[LV4] = mutated_def
		expect(store.read_slot(g2, 1), "%s [%s]: restored after internal node rename" % [locale, branch])
		expect(g2.day_number() == 14 and g2.clock_text() == "09:00" and g2.relationship_level("doc_artoria") == 4 and g2.story_flag("artoria_lv4_complete"), "%s [%s]: restored Monday 09:00 & Lv4 intact" % [locale, branch])
		expect(not g2.character_event_available(g2.character_event_definitions[LV4]), "%s [%s]: completed Lv4 does not re-trigger" % [locale, branch])
		expect(store.write_slot(g2, 2), "%s [%s]: saved slot 2" % [locale, branch])
		var g3 := new_game()
		expect(store.read_slot(g3, 2), "%s [%s]: restored snapshot 2" % [locale, branch])
		expect(g3.elapsed() == g.elapsed() and g3.relationship_level("doc_artoria") == 4, "%s [%s]: second round-trip identical" % [locale, branch])
		DirAccess.remove_absolute(tmp_save)

func test_ui_sunday_and_milestone_h_flow(locale: String) -> void:
	var app = MainScene.instantiate()
	app.saves.path = "/private/tmp/hoshimi_artoria_lv4_ui_unused_%s_%d.json" % [locale, OS.get_process_id()]
	app.title_preferences_path = "/private/tmp/hoshimi_artoria_lv4_ui_prefs_%s_%d.cfg" % [locale, OS.get_process_id()]
	app.title_notice_enabled = false
	root.add_child(app)
	await process_frame
	expect(app.content.load_all(locale), locale + " [UI]: load_all")
	app.configure_game_content()
	app.game.reset()

	var target_day := ArtoriaLv4.prepare_test_save(app.game, LV4, 13)
	set_exact_day_clock(app.game, target_day, 540)

	# Verify Lv4 outfits & Free H are hidden in Staff Profile BEFORE Lv4 completion
	app.show_staff("doc_artoria", "artoria_office")
	expect(app.page.get_node_or_null("FreeHBookingPendingAssets") == null and app.page.get_node_or_null("FreeHBooking") == null, locale + " [UI]: no Free H button before Lv4")

	# Enter via formal Sunday Invitation flow
	app.show_sunday_menu()
	expect(app.screen == "sunday_menu", locale + " [UI]: Sunday menu opened")
	app.show_sunday_invites()
	app.attempt_sunday_invitation("doc_artoria")
	expect(app.screen == "character_event" and app.game.active_character_event_id == LV4, locale + " [UI]: Sunday invitation launched Artoria Lv4")

	var ev = app.game.character_events[LV4]
	var saw_milestone_h := false
	var guard := 0
	while not ev.completed and guard < 600:
		guard += 1
		expect(not app.game.can_save_progress(), locale + " [UI]: save locked during UI flow")
		if app.screen == "h_profile_test":
			saw_milestone_h = true
			expect(app.h_profile_event_mode and str(app.h_profile_run_kind) == "milestone", locale + " [MilestoneH]: launches real H Runner in milestone mode")
			expect(app.h_profile_test_entry_lines.is_empty(), locale + " [MilestoneH]: skips generic Free H entry line")
			expect(app.game.relationship_level("doc_artoria") == 3 and not app.game.story_flag("artoria_lv4_complete"), locale + " [MilestoneH]: Lv4 NOT settled prematurely during H Runner")
			expect(app.h_profile_test_session != null and str(app.h_profile_test_session.actor_id) == "doc_artoria", locale + " [MilestoneH]: session bound to doc_artoria")
			expect(str(app.h_profile_test_session.background_id("")) == "artoria_home_bedroom_night", locale + " [MilestoneH]: background locked to artoria_home_bedroom_night")
			var body_node := app.page.get_node_or_null("HProfileBodyMap") as TextureRect
			expect(body_node != null and body_node.texture != null and body_node.texture.resource_path == "res://assets/h/doc_artoria/body_map.png", locale + " [MilestoneH]: renders Artoria body_map.png")
			while app.h_profile_test_session.excitement < 100:
				app.h_profile_test_last_result = app.h_profile_test_session.perform("kiss", "lips")
			app.show_sayaka_h_profile_test()
			expect(app.page.get_node_or_null("HProfileStyleGentle") != null and app.page.get_node_or_null("HProfileStyleIntense") != null, locale + " [MilestoneH]: renders gentle and intense entry choices")
			var style_id := "gentle" if locale == "zh_CN" else "intense"
			app._choose_sayaka_h_entry_style(style_id)
			expect(app.h_profile_test_session.selected_h_scene_lines.size() == 6, locale + " [MilestoneH]: Phase 2 uses pure 6-line Artoria sequence")
			for stage_idx in range(6):
				var stage_img := app.page.get_node_or_null("HProfileSceneImage") as TextureRect
				expect(stage_img != null and stage_img.texture != null and stage_img.texture.resource_path == "res://assets/h/doc_artoria/scene_cg.png", locale + " [MilestoneH]: renders Artoria scene_cg.png at step " + str(stage_idx))
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
			expect(app.screen == "character_event" and str(ev.current().id) == "ar4_s5_2_01", locale + " [MilestoneH]: H Runner resumed seamlessly at Scene 5.2 (ar4_s5_2_01)")
			continue
		var cont_btn = app.page.get_node_or_null("EventDialogueContinue")
		if cont_btn != null:
			app.advance_dialogue_page(app.show_character_event)
			continue
		var cur: Dictionary = ev.current()
		app.choose_character_event(str(cur.choices[0].id))

	expect(saw_milestone_h, locale + " [UI]: traversed real Milestone H Runner at Scene 5.1 end")
	expect(app.screen == "character_event_reward", locale + " [UI]: approved Lv4 CG reward displayed")
	var reward_cg = app.page.get_node_or_null("EventRewardCG") as TextureRect
	expect(reward_cg != null and reward_cg.texture != null, locale + " [UI]: Lv4 gallery texture loaded")
	var reward_continue = app.page.get_node_or_null("EventRewardContinue") as Button
	if reward_continue != null:
		reward_continue.pressed.emit()
	expect(app.screen == "character_event_complete", locale + " [UI]: reward continues to character_event_complete")
	expect(app.game.day_number() == target_day + 1 and app.game.clock_text() == "09:00", locale + " [UI]: completion screen shows Monday 09:00")
	expect(app.game.relationship_level("doc_artoria") == 4 and app.game.story_flag("artoria_lv4_complete"), locale + " [UI]: Lv4 settled after Scene 6.2")

	app.finish_long_sunday_character_event()
	expect(app.screen == "map" and app.game.can_save_progress(), locale + " [UI]: Monday 09:00 hospital map saveable")

	# Verify active production Free H booking button on Staff Profile after Lv4
	app.show_staff("doc_artoria", "artoria_office")
	var book_btn := app.page.get_node_or_null("FreeHBooking") as Button
	expect(book_btn != null and not book_btn.disabled and app.page.get_node_or_null("FreeHBookingPendingAssets") == null, locale + " [UI]: active FreeHBooking shown on Staff Profile")
	book_btn.pressed.emit()
	expect(app.game.free_h_booking.get("actor_id", "") == "doc_artoria" and app.screen == "free_h_response" and app.page.get_node_or_null("FreeHBookingResponse") != null, locale + " [UI]: booked Artoria Free H at home & displayed response")

	DirAccess.remove_absolute(app.saves.path)
	DirAccess.remove_absolute(app.title_preferences_path)
	app.queue_free()

func run() -> void:
	content = ContentLoader.new()
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Loaded content for " + locale)
		test_gates_and_calendar(locale)
		test_branches_save_and_rename_resilience(locale)
		await test_ui_sunday_and_milestone_h_flow(locale)

	print("ARTORIA LV4 HEADLESS TEST: %d checks; %d failure(s)" % [checks, failures.size()])
	for f in failures:
		print("  FAIL: " + f)
	quit(1 if not failures.is_empty() else 0)
