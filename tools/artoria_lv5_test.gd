extends SceneTree
## Headless integration, gate, Mon–Thu 09:00–12:00 `artoria_office` entry,
## 18-path branch traversal, `Day T+2 09:00` atomic settlement (both weekday and
## Thursday->Saturday completion), Staff-as-Patient decoupling, Chief/nurse isolation,
## bilingual UI, and v37 BoundarySave test for Artoria Pendragon (`doc_artoria`)
## Relationship Lv5: 《我的位置》 (`artoria_lv5_my_position`, V1.1).

const ContentLoader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const ArtoriaLv5 = preload("res://godot/systems/artoria_lv5.gd")
const AdvancedReferral = preload("res://godot/systems/advanced_referral.gd")
const Store = preload("res://godot/systems/save_store.gd")
const MainScene = preload("res://godot/scenes/main.tscn")

const LV4 := "artoria_lv4_just_artoria"
const LV5 := "artoria_lv5_my_position"

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

func setup_ready_for_lv5(target_day: int = 16, target_clock: int = 540) -> RefCounted:
	var g := new_game()
	ArtoriaLv5.prepare_test_save(g, LV5, target_day)
	set_exact_day_clock(g, target_day, target_clock)
	return g

func assert_no_inner_state(raw: Dictionary, label: String) -> void:
	var raw_json := JSON.stringify(raw)
	for forbidden in ["ar5_s1_", "ar5_s2_", "ar5_s3_", "ar5_s4_", "ar5_s5_", "ar5_s6_", "ar5_choice_", "choice_ar5_", "aoi_tohsaka", "node_id", "last_choice", "dialogue_page"]:
		expect(raw_json.find(forbidden) == -1, "%s: persisted save contains forbidden token %s" % [label, forbidden])

func test_gates_and_calendar(locale: String) -> void:
	var def: Dictionary = content.find_record("character_events", LV5)
	expect(not def.is_empty(), locale + ": artoria_lv5_my_position loaded")

	# Day 16 is Wednesday 2025-04-16 (3 days after Day 13 Lv4; Day 17 is Thursday)
	var g := setup_ready_for_lv5(16, 540)
	expect(g.is_routine_workday(16) and g.is_routine_workday(17), locale + " [Calendar]: Day 16 & Day 17 are routine workdays")
	expect(g.character_event_available(def), locale + " [Gate]: Ready at Day 16 09:00")

	# 1. Familiarity boundary (74 vs 75)
	g.relation_for("doc_artoria").familiarity = 74
	expect(not g.character_event_available(def), locale + " [Gate]: Familiarity 74 blocked")
	g.relation_for("doc_artoria").familiarity = 75
	expect(g.character_event_available(def), locale + " [Gate]: Familiarity 75 allowed")

	# 2. Leadership boundary (89 vs 90)
	g.set_test_player_attribute("leadership", 89)
	expect(not g.character_event_available(def), locale + " [Gate]: Leadership 89 blocked")
	g.set_test_player_attribute("leadership", 90)
	expect(g.character_event_available(def), locale + " [Gate]: Leadership 90 allowed")

	# 3. Surgery skill boundary (79 vs 80) & centralized adult Lv5 staff_as_patient_program_authorized gate
	g.set_test_player_attribute("skill", 79)
	expect(not g.character_event_available(def), locale + " [Gate]: Surgery 79 blocked")
	g.set_test_player_attribute("skill", 80)
	expect(g.character_event_available(def), locale + " [Gate]: Surgery 80 allowed")
	g.set_story_flag("staff_as_patient_program_authorized", false)
	expect(not g.character_event_available(def), locale + " [Gate]: staff_as_patient_program_authorized=false blocked")
	g.set_story_flag("staff_as_patient_program_authorized", true)
	expect(g.character_event_available(def), locale + " [Gate]: staff_as_patient_program_authorized=true allowed")

	# 4. Morning clock boundary (09:00-12:00 allowed; 12:01+ blocked)
	set_exact_day_clock(g, 16, 720)
	expect(g.character_event_available(def), locale + " [Clock]: 12:00 (720) allowed")
	set_exact_day_clock(g, 16, 721)
	expect(not g.character_event_available(def), locale + " [Clock]: 12:01 (721) blocked")
	set_exact_day_clock(g, 16, 540)

	# 5. Cooldown boundary (2 days after Lv4 blocked; 3 days allowed)
	g.character_events[LV4].completed_day = 14
	expect(not g.character_event_available(def), locale + " [Cooldown]: 2-day gap (Day 14 -> Day 16) blocked")
	g.character_events[LV4].completed_day = 13
	expect(g.character_event_available(def), locale + " [Cooldown]: 3-day gap (Day 13 -> Day 16) allowed")

	# 6. Weekday rules: Thu (Day 17) allowed; Fri (Day 18 -> Sat Day 19), Sat (Day 19), Sun (Day 20) blocked; Mon (Day 21) allowed
	set_exact_day_clock(g, 17, 540)
	expect(g.character_event_available(def), locale + " [Weekday]: Thursday Day 17 allowed")
	for blocked_day in [18, 19, 20]:
		set_exact_day_clock(g, blocked_day, 540)
		expect(not g.character_event_available(def), locale + " [Weekday]: Day %d blocked" % blocked_day)
	set_exact_day_clock(g, 21, 540)
	expect(g.character_event_available(def), locale + " [Weekday]: Monday Day 21 allowed")

	# 7. Late-campaign Anji departure window (Day 363-365 blocked; Day 362 <= max_day)
	for late_day in [363, 364, 365]:
		set_exact_day_clock(g, late_day, 540)
		expect(not g.character_event_available(def), locale + " [LateCampaign]: Day %d blocked" % late_day)

	# 8. AdvancedReferral conflict across workday AND workday + 1
	set_exact_day_clock(g, 21, 540)
	g.advanced_referral_facts = {"appointment": {"case_id": "test_case", "operation_day": 21, "review_day": 25}}
	expect(not g.character_event_available(def) and AdvancedReferral.conflicts_event(g, def), locale + " [AdvRef]: same-day operation_day blocked")
	g.advanced_referral_facts = {"appointment": {"case_id": "test_case", "operation_day": 22, "review_day": 25}}
	expect(not g.character_event_available(def) and AdvancedReferral.conflicts_event(g, def), locale + " [AdvRef]: next-day operation_day blocked")
	g.advanced_referral_facts = {"appointment": {"case_id": "test_case", "operation_day": 23, "review_day": 26}}
	expect(g.character_event_available(def) and not AdvancedReferral.conflicts_event(g, def), locale + " [AdvRef]: Day T+2 operation_day allowed")
	g.advanced_referral_facts = {}

func test_all_18_paths_save_and_isolation(locale: String) -> void:
	var combos: Array = []
	for c1 in ["a", "b", "c"]:
		for c2 in ["a", "b"]:
			for c3 in ["a", "b", "c"]:
				combos.append([c1, c2, c3])

	for idx in range(combos.size()):
		var pick: Array = combos[idx]
		var tag := "%s_%s_%s" % [pick[0], pick[1], pick[2]]
		# Alternate starting on Monday (Day 21 -> settles Wed Day 23) and Thursday (Day 17 -> settles Sat Day 19)
		var start_day := 17 if idx % 2 == 1 else 21
		var g := setup_ready_for_lv5(start_day, 600)
		var hiroko_fam_before := int(g.relation_for("nurse_hiroko").get("familiarity", 0))
		var moe_fam_before := int(g.relation_for("nurse_moe").get("familiarity", 0))
		var ange_fam_before := int(g.relation_for("nurse_ange").get("familiarity", 0))
		var unlocked_before: Array = g.unlocked_procedure_ids.duplicate()

		var ev = g.start_character_event(LV5)
		expect(ev != null and not g.can_save_progress() and not g.staff_patient_unlocked("doc_artoria"), "%s [%s]: started Lv5 with save locked and staff_patient still locked" % [locale, tag])

		var wants := [
			"choice_ar5_c1_" + str(pick[0]),
			"choice_ar5_c2_" + str(pick[1]),
			"choice_ar5_c3_" + str(pick[2]),
		]
		var steps := 0
		var visited := {}
		while not ev.completed and steps < 300:
			steps += 1
			var cur: Dictionary = ev.current()
			var nid := str(cur.id)
			visited[nid] = true
			if locale == "en":
				expect(cjk_re.search(str(cur.get("text", ""))) == null, "en [%s]: CJK in %s" % [tag, nid])
				expect(cjk_re.search(str(cur.get("speaker_label", ""))) == null, "en [%s]: CJK speaker in %s" % [tag, nid])
			var chosen := str(cur.choices[0].id)
			for w in wants:
				for ch in cur.choices:
					if str(ch.id) == w:
						chosen = w
						break
			expect(g.choose_character_event(chosen), "%s [%s]: chose %s at %s" % [locale, tag, chosen, nid])
			if not ev.completed:
				expect(g.relationship_level("doc_artoria") == 4 and not g.story_flag("artoria_lv5_complete"), "%s [%s]: still Lv4 mid-event" % [locale, tag])

		expect(ev.completed, "%s [%s]: completed Lv5" % [locale, tag])
		expect(visited.has("ar5_s3_1_02") and visited.has("ar5_s4m_11") and visited.has("ar5_s5_1_17") and visited.has("ar5_s6_08") and visited.has("ar5_s6m_02"), "%s [%s]: traversed all 6 acts" % [locale, tag])

		g.advance_story_to_day(int(ev.completed_day) + 2, 540)
		g.finish_character_event()

		expect(g.day_number() == start_day + 2 and g.clock_text() == "09:00", "%s [%s]: settled at Day T+2 09:00" % [locale, tag])
		expect(g.relationship_level("doc_artoria") == 5 and g.story_flag("artoria_lv5_complete"), "%s [%s]: promoted Lv4 -> Lv5 & set artoria_lv5_complete" % [locale, tag])
		expect(g.relation_for("doc_artoria").unlocked_benefits.has("unlock_clinical_practice_patient"), "%s [%s]: granted unlock_clinical_practice_patient" % [locale, tag])
		expect(g.staff_patient_unlocked("doc_artoria") and g.can_invite_staff_patient("doc_artoria"), "%s [%s]: completing Lv5 unlocks staff_patient_unlocked(doc_artoria)" % [locale, tag])
		expect(int(g.relation_for("doc_artoria").familiarity) == 75, "%s [%s]: Artoria familiarity unchanged by choices" % [locale, tag])
		expect(int(g.relation_for("nurse_hiroko").get("familiarity", 0)) == hiroko_fam_before and int(g.relation_for("nurse_moe").get("familiarity", 0)) == moe_fam_before and int(g.relation_for("nurse_ange").get("familiarity", 0)) == ange_fam_before, "%s [%s]: zero nurse familiarity drift" % [locale, tag])
		expect(g.unlocked_procedure_ids == unlocked_before, "%s [%s]: no extra procedure unlocked in Lv5" % [locale, tag])
		for chief_flag in g.story_flags.keys():
			expect(str(chief_flag).find("yield") == -1 and str(chief_flag).find("withdraw") == -1 and str(chief_flag).find("maiya") == -1 and str(chief_flag).find("sakaguchi_chief") == -1, "%s [%s]: zero Chief competition / Maiya flags touched" % [locale, tag])

		if idx < 2:
			var tmp_save := "/private/tmp/hoshimi_artoria_lv5_test_%s_%s_%d.json" % [locale, tag, OS.get_process_id()]
			var store := Store.new()
			store.path = tmp_save
			expect(store.write_slot(g, 1), "%s [%s]: saved slot 1" % [locale, tag])
			var raw1: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(tmp_save))
			assert_no_inner_state(raw1, "%s [%s]" % [locale, tag])

			var g2 := new_game()
			var mutated_def: Dictionary = g2.character_event_definitions[LV5].duplicate(true)
			mutated_def["start"] = "ar5_renamed_open_01"
			mutated_def["nodes"][0]["id"] = "ar5_renamed_open_01"
			g2.character_event_definitions[LV5] = mutated_def
			expect(store.read_slot(g2, 1), "%s [%s]: restored after internal node rename" % [locale, tag])
			expect(g2.day_number() == start_day + 2 and g2.clock_text() == "09:00" and g2.relationship_level("doc_artoria") == 5 and g2.story_flag("artoria_lv5_complete"), "%s [%s]: restored Day T+2 09:00 & Lv5 intact" % [locale, tag])
			expect(not g2.character_event_available(g2.character_event_definitions[LV5]), "%s [%s]: completed Lv5 does not re-trigger" % [locale, tag])
			expect(store.write_slot(g2, 2), "%s [%s]: saved slot 2" % [locale, tag])
			var g3 := new_game()
			expect(store.read_slot(g3, 2), "%s [%s]: restored slot 2" % [locale, tag])
			expect(g3.elapsed() == g.elapsed() and g3.relationship_level("doc_artoria") == 5, "%s [%s]: second round-trip identical" % [locale, tag])
			DirAccess.remove_absolute(tmp_save)

func test_ui_formal_location_entry(locale: String, start_day: int) -> void:
	var app = MainScene.instantiate()
	app.saves.path = "/private/tmp/hoshimi_artoria_lv5_ui_unused_%s_%d_%d.json" % [locale, start_day, OS.get_process_id()]
	app.title_preferences_path = "/private/tmp/hoshimi_artoria_lv5_ui_prefs_%s_%d_%d.cfg" % [locale, start_day, OS.get_process_id()]
	app.title_notice_enabled = false
	root.add_child(app)
	await process_frame
	expect(app.content.load_all(locale), locale + " [UI]: load_all")
	app.configure_game_content()
	app.game.reset()

	ArtoriaLv5.prepare_test_save(app.game, LV5, start_day)
	set_exact_day_clock(app.game, start_day, 540)

	# Enter via formal Hospital Map -> artoria_office location entry
	app.show_map(false)
	expect(app.screen == "map" and app.game.can_save_progress(), locale + " [UI]: map saveable before entering Lv5")
	var avail: Array = app.game.character_events_at("artoria_office")
	var found_lv5 := false
	for item in avail:
		if str(item.get("id", "")) == LV5:
			found_lv5 = true
	expect(found_lv5, locale + " [UI]: artoria_lv5_my_position offered in artoria_office morning")

	app.show_location("artoria_office", false, false, true)
	expect(app.screen == "character_event" and app.game.active_character_event_id == LV5 and not app.game.can_save_progress(), locale + " [UI]: entering artoria_office started Lv5 with save locked")

	var ev = app.game.character_events[LV5]
	var guard := 0
	while not ev.completed and guard < 600:
		guard += 1
		expect(not app.game.can_save_progress(), locale + " [UI]: save locked throughout Lv5")
		var cont_btn = app.page.get_node_or_null("EventDialogueContinue")
		if cont_btn != null:
			app.advance_dialogue_page(app.show_character_event)
			continue
		var cur: Dictionary = ev.current()
		app.choose_character_event(str(cur.choices[0].id))

	expect(app.screen == "character_event_reward", locale + " [UI]: reached Lv5 CG reward")
	var reward_cg = app.page.get_node_or_null("EventRewardCG") as TextureRect
	expect(reward_cg != null and reward_cg.texture != null, locale + " [UI]: Lv5 gallery texture loaded")
	var reward_continue = app.page.get_node_or_null("EventRewardContinue") as Button
	expect(reward_continue != null, locale + " [UI]: CG reward continue button exists")
	if reward_continue != null:
		reward_continue.pressed.emit()
	expect(app.screen == "character_event_complete", locale + " [UI]: reached character_event_complete after CG reward")
	expect(app.game.day_number() == start_day + 2 and app.game.clock_text() == "09:00", locale + " [UI]: completion screen shows Day T+2 09:00")
	expect(app.game.relationship_level("doc_artoria") == 5 and app.game.story_flag("artoria_lv5_complete"), locale + " [UI]: Lv5 settled at completion")

	app.show_map(false)
	expect(app.screen == "map" and app.game.active_character_event_id.is_empty() and app.game.can_save_progress(), locale + " [UI]: returned cleanly to saveable map boundary")

	DirAccess.remove_absolute(app.saves.path)
	DirAccess.remove_absolute(app.title_preferences_path)
	app.queue_free()

func run() -> void:
	content = ContentLoader.new()
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Loaded content for " + locale)
		test_gates_and_calendar(locale)
		test_all_18_paths_save_and_isolation(locale)
		await test_ui_formal_location_entry(locale, 21) # Monday -> Wednesday 09:00
		await test_ui_formal_location_entry(locale, 17) # Thursday -> Saturday 09:00

	print("ARTORIA LV5 HEADLESS TEST: %d checks; %d failure(s)" % [checks, failures.size()])
	for f in failures:
		print("  FAIL: " + f)
	quit(1 if not failures.is_empty() else 0)
