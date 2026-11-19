extends SceneTree
## Headless integration, gate, Mon–Fri `after_work` entry, 16-path branch traversal,
## `Day T+1 09:00` atomic settlement, zero Chief-of-Surgery boolean flag pollution,
## zero reputation delta, Staff-as-Patient decoupling, bilingual zero-CJK-leak,
## and v37 BoundarySave test for Emiko Mido (`doc_emiko`) Relationship Lv5:
## 《神的双手》 (`emiko_lv5_hands_of_god`, V1.0).

const ContentLoader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const EmikoLv5 = preload("res://godot/systems/emiko_lv5.gd")
const AdvancedReferral = preload("res://godot/systems/advanced_referral.gd")
const Store = preload("res://godot/systems/save_store.gd")
const MainScene = preload("res://godot/scenes/main.tscn")

const LV4 := "emiko_lv4_emikos_secret"
const LV5 := "emiko_lv5_hands_of_god"

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

func setup_ready_for_lv5(target_day: int = 16, target_clock: int = 990) -> RefCounted:
	var g := new_game()
	EmikoLv5.prepare_test_save(g, LV5, target_day)
	set_exact_day_clock(g, target_day, target_clock)
	return g

func assert_no_inner_state(raw: Dictionary, label: String) -> void:
	var raw_json := JSON.stringify(raw)
	for forbidden in ["em5_s1_", "em5_s2_", "em5_s3_", "em5_s4_", "em5_s5_", "em5_s6_", "em5_choice_", "choice_em5_", "haruko_takase", "naomi_miyahara", "node_id", "last_choice", "dialogue_page"]:
		expect(raw_json.find(forbidden) == -1, "%s: persisted save contains forbidden token %s" % [label, forbidden])

func test_gates_and_calendar(locale: String) -> void:
	var def: Dictionary = content.find_record("character_events", LV5)
	expect(not def.is_empty(), locale + ": emiko_lv5_hands_of_god loaded")

	# Day 16 is Wednesday 2025-04-16 (3 days after Day 13 Lv4; Day 17 is Thursday)
	var g := setup_ready_for_lv5(16, 990)
	expect(g.is_routine_workday(16) and not g.is_hospital_closed_day(17), locale + " [Calendar]: Day 16 routine & Day 17 open")
	expect(g.character_event_available(def) and str(g.next_after_work_character_event().get("id", "")) == LV5, locale + " [Gate]: Ready at Day 16 16:30")

	# 1. Familiarity boundary (74 vs 75)
	g.relation_for("doc_emiko").familiarity = 74
	expect(not g.character_event_available(def), locale + " [Gate]: Familiarity 74 blocked")
	g.relation_for("doc_emiko").familiarity = 75
	expect(g.character_event_available(def), locale + " [Gate]: Familiarity 75 allowed")

	# 2. Surgery skill boundary (89 vs 90)
	g.set_test_player_attribute("skill", 89)
	expect(not g.character_event_available(def), locale + " [Gate]: Surgery 89 blocked")
	g.set_test_player_attribute("skill", 90)
	expect(g.character_event_available(def), locale + " [Gate]: Surgery 90 allowed")

	# 3. Centralized adult Lv5 staff_as_patient_program_authorized gate
	g.set_story_flag("staff_as_patient_program_authorized", false)
	expect(not g.character_event_available(def), locale + " [Gate]: staff_as_patient_program_authorized=false blocked")
	g.set_story_flag("staff_as_patient_program_authorized", true)
	expect(g.character_event_available(def), locale + " [Gate]: staff_as_patient_program_authorized=true allowed")

	# 4. After-work clock boundary (<16:00 not offered in next_after_work_character_event; >=16:00 offered)
	set_exact_day_clock(g, 16, 900)
	expect(g.next_after_work_character_event().is_empty(), locale + " [Clock]: 15:00 (900) not offered in after_work")
	set_exact_day_clock(g, 16, 960)
	expect(str(g.next_after_work_character_event().get("id", "")) == LV5, locale + " [Clock]: 16:00 (960) offered in after_work")

	# 5. Cooldown boundary (2 days after Lv4 blocked; 3 days allowed)
	g.character_events[LV4].completed_day = 14
	expect(not g.character_event_available(def), locale + " [Cooldown]: 2-day gap (Day 14 -> Day 16) blocked")
	g.character_events[LV4].completed_day = 13
	expect(g.character_event_available(def), locale + " [Cooldown]: 3-day gap (Day 13 -> Day 16) allowed")

	# 6. Weekday rules: Fri Day 18 (-> Sat Day 19 open) allowed; Sat Day 19 (-> Sun Day 20 closed) & Sun Day 20 blocked; Mon Day 21 allowed
	set_exact_day_clock(g, 18, 990)
	expect(g.character_event_available(def), locale + " [Weekday]: Friday Day 18 allowed")
	for blocked_day in [19, 20]:
		set_exact_day_clock(g, blocked_day, 990)
		expect(not g.character_event_available(def), locale + " [Weekday]: Day %d blocked" % blocked_day)
	set_exact_day_clock(g, 21, 990)
	expect(g.character_event_available(def), locale + " [Weekday]: Monday Day 21 allowed")

	# 7. Late-campaign Day 364–365 blocked (max_day == 363)
	for late_day in [364, 365]:
		set_exact_day_clock(g, late_day, 990)
		expect(not g.character_event_available(def), locale + " [LateCampaign]: Day %d blocked" % late_day)

	# 8. AdvancedReferral conflict across workday AND workday + 1
	set_exact_day_clock(g, 21, 990)
	g.advanced_referral_facts = {"appointment": {"case_id": "test_case", "operation_day": 21, "review_day": 25}}
	expect(not g.character_event_available(def) and AdvancedReferral.conflicts_event(g, def), locale + " [AdvRef]: same-day operation_day blocked")
	g.advanced_referral_facts = {"appointment": {"case_id": "test_case", "operation_day": 22, "review_day": 25}}
	expect(not g.character_event_available(def) and AdvancedReferral.conflicts_event(g, def), locale + " [AdvRef]: next-day operation_day blocked")
	g.advanced_referral_facts = {"appointment": {"case_id": "test_case", "operation_day": 23, "review_day": 26}}
	expect(g.character_event_available(def) and not AdvancedReferral.conflicts_event(g, def), locale + " [AdvRef]: Day T+2 operation_day allowed")
	g.advanced_referral_facts = {}

func test_all_16_paths_save_and_isolation(locale: String) -> void:
	var combos: Array = []
	for c1 in ["a", "b"]:
		for c2 in ["a", "b"]:
			for c3 in ["a", "b"]:
				for c4 in ["a", "b"]:
					combos.append([c1, c2, c3, c4])

	for idx in range(combos.size()):
		var pick: Array = combos[idx]
		var tag := "%s_%s_%s_%s" % [pick[0], pick[1], pick[2], pick[3]]
		var start_day := 18 if idx % 2 == 1 else 21
		var g := setup_ready_for_lv5(start_day, 990)
		var rep_before := int(g.player_attributes().get("reputation", 0))
		var rei_fam_before := int(g.relation_for("doc_rei").get("familiarity", 0))
		var hiroko_fam_before := int(g.relation_for("nurse_hiroko").get("familiarity", 0))
		var sonoda_fam_before := int(g.relation_for("nurse_sonoda_itsumi").get("familiarity", 0))
		var unlocked_before: Array = g.unlocked_procedure_ids.duplicate()

		var ev = g.start_character_event(LV5)
		expect(ev != null and not g.can_save_progress() and not g.staff_patient_unlocked("doc_emiko"), "%s [%s]: started Lv5 with save locked and staff_patient still locked" % [locale, tag])

		var wants := [
			"choice_em5_c1_" + str(pick[0]),
			"choice_em5_c2_" + str(pick[1]),
			"choice_em5_c3_" + str(pick[2]),
			"choice_em5_c4_" + str(pick[3]),
		]
		var steps := 0
		var visited := {}
		while not ev.completed and steps < 400:
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
				expect(g.relationship_level("doc_emiko") == 4 and not g.story_flag("emiko_lv5_complete"), "%s [%s]: still Lv4 mid-event" % [locale, tag])

		expect(ev.completed, "%s [%s]: completed Lv5" % [locale, tag])
		expect(visited.has("em5_s1_2_15") and visited.has("em5_s2m_03") and visited.has("em5_s3_20") and visited.has("em5_s4_3_06") and visited.has("em5_s5m_18") and visited.has("em5_s6_1_33") and visited.has("em5_s6m_04"), "%s [%s]: traversed all 6 acts" % [locale, tag])

		g.advance_story_to_day(int(ev.completed_day) + 1, 540)
		g.finish_character_event()

		expect(g.day_number() == start_day + 1 and g.clock_text() == "09:00", "%s [%s]: settled at Day T+1 09:00" % [locale, tag])
		expect(g.relationship_level("doc_emiko") == 5 and g.story_flag("emiko_lv5_complete"), "%s [%s]: promoted Lv4 -> Lv5 & set emiko_lv5_complete" % [locale, tag])
		expect(g.relation_for("doc_emiko").unlocked_benefits.has("unlock_clinical_practice_patient"), "%s [%s]: granted unlock_clinical_practice_patient" % [locale, tag])
		# doc_emiko has no authored entry in data/staff_patient_profiles.json yet; must remain safely locked until authored
		expect(not g.staff_patient_unlocked("doc_emiko"), "%s [%s]: staff_patient_unlocked(doc_emiko) remains false pending authored staff_patient_profiles.json" % [locale, tag])
		expect(int(g.player_attributes().get("reputation", 0)) == rep_before, "%s [%s]: zero Reputation delta" % [locale, tag])
		expect(int(g.relation_for("doc_emiko").familiarity) == 75, "%s [%s]: Emiko familiarity unchanged by choices" % [locale, tag])
		expect(int(g.relation_for("doc_rei").get("familiarity", 0)) == rei_fam_before and int(g.relation_for("nurse_hiroko").get("familiarity", 0)) == hiroko_fam_before and int(g.relation_for("nurse_sonoda_itsumi").get("familiarity", 0)) == sonoda_fam_before, "%s [%s]: zero supporting-cast familiarity drift" % [locale, tag])
		expect(g.unlocked_procedure_ids == unlocked_before, "%s [%s]: no extra procedure unlocked in Lv5" % [locale, tag])
		for chief_flag in g.story_flags.keys():
			var fl := str(chief_flag)
			expect(fl.find("yield") == -1 and fl.find("withdraw") == -1 and fl.find("supports_sakaguchi") == -1 and fl.find("sakaguchi_chief") == -1, "%s [%s]: zero Chief competition boolean flags written (%s)" % [locale, tag, fl])

		if idx < 2:
			var tmp_save := "/private/tmp/hoshimi_emiko_lv5_test_%s_%s_%d.json" % [locale, tag, OS.get_process_id()]
			var store := Store.new()
			store.path = tmp_save
			expect(store.write_slot(g, 1), "%s [%s]: saved slot 1" % [locale, tag])
			var raw1: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(tmp_save))
			assert_no_inner_state(raw1, "%s [%s]" % [locale, tag])

			var g2 := new_game()
			var mutated_def: Dictionary = g2.character_event_definitions[LV5].duplicate(true)
			mutated_def["start"] = "em5_renamed_open_01"
			mutated_def["nodes"][0]["id"] = "em5_renamed_open_01"
			g2.character_event_definitions[LV5] = mutated_def
			expect(store.read_slot(g2, 1), "%s [%s]: restored after internal node rename" % [locale, tag])
			expect(g2.day_number() == start_day + 1 and g2.clock_text() == "09:00" and g2.relationship_level("doc_emiko") == 5 and g2.story_flag("emiko_lv5_complete"), "%s [%s]: restored Day T+1 09:00 & Lv5 intact" % [locale, tag])
			expect(not g2.character_event_available(g2.character_event_definitions[LV5]), "%s [%s]: completed Lv5 does not re-trigger" % [locale, tag])
			expect(store.write_slot(g2, 2), "%s [%s]: saved slot 2" % [locale, tag])
			var g3 := new_game()
			expect(store.read_slot(g3, 2), "%s [%s]: restored slot 2" % [locale, tag])
			expect(g3.elapsed() == g.elapsed() and g3.relationship_level("doc_emiko") == 5, "%s [%s]: second round-trip identical" % [locale, tag])
			DirAccess.remove_absolute(tmp_save)

func test_ui_formal_after_work_entry(locale: String, start_day: int) -> void:
	var app = MainScene.instantiate()
	app.saves.path = "/private/tmp/hoshimi_emiko_lv5_ui_unused_%s_%d_%d.json" % [locale, start_day, OS.get_process_id()]
	app.title_preferences_path = "/private/tmp/hoshimi_emiko_lv5_ui_prefs_%s_%d_%d.cfg" % [locale, start_day, OS.get_process_id()]
	app.title_notice_enabled = false
	root.add_child(app)
	await process_frame
	expect(app.content.load_all(locale), locale + " [UI]: load_all")
	app.configure_game_content()
	app.game.reset()

	EmikoLv5.prepare_test_save(app.game, LV5, start_day)
	set_exact_day_clock(app.game, start_day, 990)

	app.show_map(false)
	expect(app.screen == "map" and app.game.can_save_progress(), locale + " [UI]: map saveable before after_work departure")
	app.show_location("player_office", false, false, true)
	var leave_btn := app.page.get_node_or_null("OfficeEndWorkday") as Button
	expect(leave_btn != null and not leave_btn.disabled, locale + " [UI]: OfficeEndWorkday enabled at 16:30")
	app.request_end_workday()
	expect(app.screen == "character_event" and app.game.active_character_event_id == LV5 and not app.game.can_save_progress(), locale + " [UI]: request_end_workday started Emiko Lv5 with save locked")

	var ev = app.game.character_events[LV5]
	var guard := 0
	while not ev.completed and guard < 800:
		guard += 1
		expect(not app.game.can_save_progress(), locale + " [UI]: save locked throughout Lv5")
		var cont_btn = app.page.get_node_or_null("EventDialogueContinue")
		if cont_btn != null:
			app.advance_dialogue_page(app.show_character_event)
			continue
		var cur: Dictionary = ev.current()
		app.choose_character_event(str(cur.choices[0].id))

	expect(app.screen == "character_event_reward", locale + " [UI]: reached Lv5 CG reward")
	expect(not app.game.can_save_progress(), locale + " [UI]: save remains locked on CG reward screen")
	var reward_cg := app.page.get_node_or_null("EventRewardCG") as TextureRect
	expect(reward_cg != null and reward_cg.texture != null and reward_cg.texture.resource_path == "res://assets/events/emiko_lv5_cg_v1/corridor_lapel.png", locale + " [UI]: Lv5 gallery cover CG texture loaded on reward screen")
	var reward_continue := app.page.get_node_or_null("EventRewardContinue") as Button
	expect(reward_continue != null, locale + " [UI]: EventRewardContinue button exists")
	if reward_continue != null:
		reward_continue.pressed.emit()

	expect(app.screen == "character_event_complete", locale + " [UI]: reached character_event_complete after CG reward")
	expect(not app.game.can_save_progress(), locale + " [UI]: save remains locked on character_event_complete")
	expect(app.game.day_number() == start_day + 1 and app.game.clock_text() == "09:00", locale + " [UI]: completion screen shows Day T+1 09:00")
	expect(app.game.relationship_level("doc_emiko") == 5 and app.game.story_flag("emiko_lv5_complete"), locale + " [UI]: Lv5 settled at completion")

	app.show_map(false)
	expect(app.screen == "map" and app.game.active_character_event_id.is_empty() and app.game.can_save_progress(), locale + " [UI]: returned cleanly to saveable map boundary")

	app.show_event_gallery("player_office")
	var gal_entry := app.page.find_child("GalleryEvent_" + LV5, true, false) as Button
	expect(gal_entry != null and not gal_entry.disabled, locale + " [UI]: Event Gallery entry unlocked after Lv5 completion")

	DirAccess.remove_absolute(app.saves.path)
	DirAccess.remove_absolute(app.title_preferences_path)
	app.queue_free()

func run() -> void:
	content = ContentLoader.new()
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Loaded content for " + locale)
		test_gates_and_calendar(locale)
		test_all_16_paths_save_and_isolation(locale)
		await test_ui_formal_after_work_entry(locale, 21) # Monday -> Tuesday 09:00
		await test_ui_formal_after_work_entry(locale, 18) # Friday -> Saturday 09:00

	print("EMIKO LV5 HEADLESS TEST: %d checks; %d failure(s)" % [checks, failures.size()])
	for f in failures:
		print("  FAIL: " + f)
	quit(1 if not failures.is_empty() else 0)
