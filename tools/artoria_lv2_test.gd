extends SceneTree
## Headless integration, gate, choice-branch, Open Hepatic Lobectomy teaching unlock,
## nurse duty isolation, UI bilingual, and v37 BoundarySave test for Artoria Pendragon
## (`doc_artoria`) Relationship Lv2: 《留下来的部分》 (`artoria_lv2_what_remains`, V1.0).

const ContentLoader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const ArtoriaLv2 = preload("res://godot/systems/artoria_lv2.gd")
const Store = preload("res://godot/systems/save_store.gd")
const MainScene = preload("res://godot/scenes/main.tscn")

const ASUKA_INTRO := "intro_doc_asuka_director_office"
const EMIKO_INTRO := "emiko_intro_rumored_hands"
const RIVAL_EVENT := "asuka_mentions_artoria_rival"
const LV0 := "intro_doc_artoria_deputy_office"
const LV1 := "artoria_lv1_right_position"
const LV2 := "artoria_lv2_what_remains"

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

func setup_ready_for_lv2(target_day: int = 8, target_clock: int = 960) -> RefCounted:
	var g := new_game()
	set_exact_day_clock(g, 1, 600)
	g.meet_staff("doc_asuka")
	g.meet_staff("doc_emiko")
	g._complete_character_event_for_test(ASUKA_INTRO, 1)
	g._complete_character_event_for_test(EMIKO_INTRO, 1)
	g._complete_character_event_for_test(RIVAL_EVENT, 2)
	g.advance_story_to_day(2, 600)
	expect(finish_event(g, LV0), "Artoria Lv0 completes")
	g.advance_story_to_day(5, 600)
	expect(finish_event(g, LV1), "Artoria Lv1 completes")
	set_exact_day_clock(g, target_day, target_clock)
	g.relation_for("doc_artoria").familiarity = 25
	g.set_test_player_attribute("leadership", 70)
	return g

func assert_no_inner_state(raw: Dictionary, label: String) -> void:
	var raw_json := JSON.stringify(raw)
	for forbidden in ["ar2_s1_", "ar2_s2_", "ar2_s3_", "ar2_s4_", "ar2_s5_", "ar2_choice_", "choice_ar2_", "node_id", "last_choice", "dialogue_page"]:
		expect(raw_json.find(forbidden) == -1, "%s: persisted save contains forbidden token %s" % [label, forbidden])

func test_gates_and_calendar(locale: String) -> void:
	var def: Dictionary = content.find_record("character_events", LV2)
	expect(not def.is_empty(), locale + ": artoria_lv2_what_remains loaded")

	# 1. Familiarity boundary (24 vs 25)
	var g := setup_ready_for_lv2(8, 960) # Day 8 = Tuesday 2025-04-08 (3 days after Day 5)
	g.relation_for("doc_artoria").familiarity = 24
	expect(not g.character_event_available(def), locale + " [Gate]: Familiarity 24 blocked")
	g.relation_for("doc_artoria").familiarity = 25
	expect(g.character_event_available(def), locale + " [Gate]: Familiarity 25 + Leadership 70 allowed")

	# 2. Leadership boundary (69 vs 70), no extra Surgery gate required
	g.set_test_player_attribute("skill", 10)
	g.set_test_player_attribute("leadership", 69)
	expect(not g.character_event_available(def), locale + " [Gate]: Leadership 69 blocked")
	g.set_test_player_attribute("leadership", 70)
	expect(g.character_event_available(def), locale + " [Gate]: Leadership 70 allowed even at low Surgery")

	# 3. 3-day milestone cooldown (Day 7 = +2d blocked; Day 8 = +3d allowed)
	var g_cd := setup_ready_for_lv2(7, 960)
	expect(not g_cd.character_event_available(def), locale + " [Gate]: 2-day gap blocked by 3-day cooldown")

	# 4. Calendar guards: Saturday (Day 5 / Day 12) blocked, day before Showa Day holiday (2025-04-28 -> Day 29 closed) blocked
	var g_sat := setup_ready_for_lv2(12, 960) # Day 12 = Saturday 2025-04-12
	expect(not g_sat.character_event_available(def), locale + " [Calendar]: Saturday blocked because next day is Sunday")
	var g_hol := setup_ready_for_lv2(28, 960) # Day 28 = Mon 2025-04-28; Day 29 = Showa Day closed holiday
	expect(g_hol.is_hospital_closed_day(29), locale + " [Calendar]: Day 29 is closed holiday")
	expect(not g_hol.character_event_available(def), locale + " [Calendar]: Day before closed holiday blocked")

	# 5. Final-two-days guard (`max_day: 363`): Day 361 (Thu 2026-03-26) allowed; Day 364 & Day 365 blocked
	var g_361 := setup_ready_for_lv2(361, 960)
	expect(g_361.character_event_available(def), locale + " [Calendar]: Day 361 routine weekday allowed")
	var g_364 := setup_ready_for_lv2(364, 960)
	expect(not g_364.character_event_available(def), locale + " [Calendar]: Day 364 blocked by final-two-days guard")
	var g_365 := setup_ready_for_lv2(365, 960)
	expect(not g_365.character_event_available(def), locale + " [Calendar]: Day 365 blocked by final-two-days guard")

	# 6. Unresolved admitted inpatient blocks Lv2
	var g_inp := setup_ready_for_lv2(8, 600)
	var pid := str(g_inp.patient_queue[0])
	var vid := "visit_" + pid.trim_prefix("patient_")
	var v = g_inp.open_visit(vid)
	expect(v != null, locale + " [Safety]: opened clinic visit during outpatient hours")
	if v != null:
		v.admitted = true
	g_inp.active_id = ""
	set_exact_day_clock(g_inp, 8, 960)
	expect(not g_inp.character_event_available(def), locale + " [Safety]: unresolved admitted patient blocks Lv2")

	# 7. Next-day Advanced Referral operation_day / review_day blocks Lv2 via both ArtoriaLv2 & AdvancedReferral.conflicts_event
	var g_adv := setup_ready_for_lv2(8, 960)
	g_adv.advanced_referral_facts["appointment"] = {"intake_day": 8, "operation_day": 9, "review_day": 10}
	expect(not g_adv.character_event_available(def), locale + " [Safety]: next-day Advanced Referral operation_day blocks Lv2")
	g_adv.advanced_referral_facts["appointment"] = {"intake_day": 7, "operation_day": 8, "review_day": 9}
	expect(not g_adv.character_event_available(def), locale + " [Safety]: next-day Advanced Referral review_day blocks Lv2")

func test_branches_settlement_and_save(locale: String) -> void:
	for branch in ["a", "b", "c"]:
		var g := setup_ready_for_lv2(8, 990)
		g.relation_for("nurse_yui").met = false
		g.relation_for("nurse_yui").familiarity = 3
		g.relation_for("nurse_ange").met = false
		g.relation_for("nurse_ange").familiarity = 4

		expect(not g.procedure_unlocked("surgery_open_major_liver_resection"), "%s [%s]: liver resection locked before Lv2" % [locale, branch])
		expect(not g.case_template_available("template_liver_resection"), "%s [%s]: template_liver_resection unavailable before Lv2" % [locale, branch])
		expect(str(g.next_after_work_character_event().get("id", "")) == LV2, "%s [%s]: scheduled as next_after_work_character_event" % [locale, branch])

		var ev = g.start_character_event(LV2)
		expect(ev != null, "%s [%s]: started Lv2" % [locale, branch])
		expect(not g.can_save_progress(), "%s [%s]: save locked during Lv2" % [locale, branch])

		var picks := ["choice_ar2_c1_" + branch, "choice_ar2_c2_" + branch, "choice_ar2_c3_" + branch]
		var step_guard := 0
		while not ev.completed and step_guard < 400:
			step_guard += 1
			var cur: Dictionary = ev.current()
			if locale == "en":
				expect(cjk_re.search(str(cur.get("text", ""))) == null, "en [%s]: CJK in text at %s" % [branch, str(cur.id)])
				expect(cjk_re.search(str(cur.get("speaker_label", ""))) == null, "en [%s]: CJK in speaker_label at %s" % [branch, str(cur.id)])
			var choices: Array = cur.choices
			var chosen := str(choices[0].id)
			for want in picks:
				for ch in choices:
					if str(ch.id) == want:
						chosen = want
						break
			expect(g.choose_character_event(chosen), "%s [%s]: chose %s at %s" % [locale, branch, chosen, str(cur.id)])
			if not ev.completed:
				# Procedure and rank must NOT settle prematurely before @end
				expect(g.relationship_level("doc_artoria") == 1, "%s [%s]: still Lv1 mid-event" % [locale, branch])
				expect(not g.procedure_unlocked("surgery_open_major_liver_resection"), "%s [%s]: liver resection still locked mid-event" % [locale, branch])

		expect(ev.completed, "%s [%s]: Lv2 completed" % [locale, branch])
		g.advance_story_to_day(int(ev.completed_day) + 1, 840)
		g.finish_character_event()

		expect(g.can_save_progress(), "%s [%s]: save unlocked on safe map boundary" % [locale, branch])
		expect(g.day_number() == 9 and g.clock_text() == "14:00", "%s [%s]: settled at Day 9 14:00" % [locale, branch])
		expect(g.relationship_level("doc_artoria") == 2, "%s [%s]: Artoria promoted Lv1 -> Lv2" % [locale, branch])
		expect(int(g.relation_for("doc_artoria").familiarity) == 25, "%s [%s]: familiarity unchanged by zero-delta choices" % [locale, branch])
		expect(g.story_flag("artoria_lv2_complete"), "%s [%s]: artoria_lv2_complete set" % [locale, branch])
		expect(g.story_flag("artoria_major_liver_resection_teaching_complete"), "%s [%s]: teaching flag set" % [locale, branch])
		expect(g.procedure_unlocked("surgery_open_major_liver_resection"), "%s [%s]: surgery_open_major_liver_resection unlocked" % [locale, branch])
		expect(g.case_template_available("template_liver_resection"), "%s [%s]: template_liver_resection available in ordinary pool" % [locale, branch])

		# Duty nurses untouched & zero Chief-of-Surgery yield flags touched
		expect(not g.staff_is_met("nurse_yui") and int(g.relation_for("nurse_yui").familiarity) == 3 and not g.relation_for("nurse_yui").event_history.has(LV2), "%s [%s]: nurse_yui state untouched" % [locale, branch])
		expect(not g.staff_is_met("nurse_ange") and int(g.relation_for("nurse_ange").familiarity) == 4 and not g.relation_for("nurse_ange").event_history.has(LV2), "%s [%s]: nurse_ange state untouched" % [locale, branch])

		# BoundarySave v37 purity & round-trip stability in /private/tmp
		var tmp_save := "/private/tmp/hoshimi_artoria_lv2_test_%s_%s_%s.json" % [locale, branch, OS.get_process_id()]
		var store := Store.new()
		store.path = tmp_save
		expect(store.write_slot(g, 1), "%s [%s]: saved slot 1" % [locale, branch])
		var raw1: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(tmp_save))
		assert_no_inner_state(raw1, "%s [%s] save1" % [locale, branch])

		var g2 := new_game()
		expect(store.read_slot(g2, 1), "%s [%s]: restored snapshot 1" % [locale, branch])
		expect(g2.day_number() == 9 and g2.clock_text() == "14:00", "%s [%s]: restored Day 9 14:00" % [locale, branch])
		expect(g2.relationship_level("doc_artoria") == 2, "%s [%s]: restored Lv2" % [locale, branch])
		expect(g2.procedure_unlocked("surgery_open_major_liver_resection") and g2.case_template_available("template_liver_resection"), "%s [%s]: restored liver resection unlock" % [locale, branch])
		expect(not g2.character_event_available(content.find_record("character_events", LV2)), "%s [%s]: completed Lv2 does not re-trigger" % [locale, branch])

		# Second save/load cycle stability
		expect(store.write_slot(g2, 2), "%s [%s]: saved slot 2" % [locale, branch])
		var g3 := new_game()
		expect(store.read_slot(g3, 2), "%s [%s]: restored snapshot 2" % [locale, branch])
		expect(g3.elapsed() == g.elapsed() and g3.relationship_level("doc_artoria") == 2 and g3.procedure_unlocked("surgery_open_major_liver_resection"), "%s [%s]: second round-trip identical" % [locale, branch])
		DirAccess.remove_absolute(tmp_save)

func test_ui_app_flow(locale: String) -> void:
	var app = MainScene.instantiate()
	app.saves.path = "/private/tmp/hoshimi_artoria_lv2_ui_unused_%s_%s.json" % [locale, OS.get_process_id()]
	app.title_preferences_path = "/private/tmp/hoshimi_artoria_lv2_ui_prefs_%s_%s.cfg" % [locale, OS.get_process_id()]
	app.title_notice_enabled = false
	root.add_child(app)
	expect(app.content.load_all(locale), locale + " [UI]: load_all")
	app.configure_game_content()
	app.game.reset()
	var target_day := ArtoriaLv2.prepare_test_save(app.game, LV2, 8)
	set_exact_day_clock(app.game, target_day, 960)
	app.show_player_office()
	expect(app.game.can_end_workday(), locale + " [UI]: can_end_workday at 16:00")
	app.request_end_workday()
	expect(app.screen == "character_event" and app.game.active_character_event_id == LV2, locale + " [UI]: request_end_workday launched Artoria Lv2")

	var ev = app.game.character_events[LV2]
	var guard := 0
	while app.screen == "character_event" and not ev.completed and guard < 600:
		guard += 1
		var cont_btn = app.page.get_node_or_null("EventDialogueContinue")
		if cont_btn != null:
			app.advance_dialogue_page(app.show_character_event)
			continue
		var cur: Dictionary = ev.current()
		app.choose_character_event(str(cur.choices[0].id))

	expect(app.screen == "character_event_complete", locale + " [UI]: landed directly on character_event_complete")
	expect(app.game.day_number() == target_day + 1 and app.game.clock_text() == "14:00", locale + " [UI]: completion screen shows next day 14:00")
	expect(app.game.relationship_level("doc_artoria") == 2 and app.game.procedure_unlocked("surgery_open_major_liver_resection"), locale + " [UI]: Lv2 and liver resection unlocked on completion screen")
	app.game.finish_character_event()
	app.show_map(false)
	expect(app.game.can_save_progress(), locale + " [UI]: safe map saveable after return")
	DirAccess.remove_absolute(app.saves.path)
	DirAccess.remove_absolute(app.title_preferences_path)
	app.queue_free()

func run() -> void:
	content = ContentLoader.new()
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Loaded content for " + locale)
		test_gates_and_calendar(locale)
		test_branches_settlement_and_save(locale)
		test_ui_app_flow(locale)

	print("ARTORIA LV2 HEADLESS TEST: %d checks; %d failure(s)" % [checks, failures.size()])
	for f in failures:
		print("  FAIL: " + f)
	quit(1 if not failures.is_empty() else 0)
