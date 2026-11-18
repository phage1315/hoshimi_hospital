extends SceneTree
## Headless integration, gate, Emiko Lv1/Lv3 cross-route continuity matrix,
## choice-branch, nurse duty isolation, UI bilingual, and v37 BoundarySave test
## for Artoria Pendragon (`doc_artoria`) Relationship Lv3:
## 《不是一个人的手术》 (`artoria_lv3_not_a_solo_operation`, V1.1).

const ContentLoader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const ArtoriaLv3 = preload("res://godot/systems/artoria_lv3.gd")
const Store = preload("res://godot/systems/save_store.gd")
const MainScene = preload("res://godot/scenes/main.tscn")

const LV2 := "artoria_lv2_what_remains"
const LV3 := "artoria_lv3_not_a_solo_operation"

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

func setup_ready_for_lv3(target_day: int = 11, target_clock: int = 960) -> RefCounted:
	var g := new_game()
	ArtoriaLv3.prepare_test_save(g, LV3, target_day)
	set_exact_day_clock(g, target_day, target_clock)
	return g

func assert_no_inner_state(raw: Dictionary, label: String) -> void:
	var raw_json := JSON.stringify(raw)
	for forbidden in ["ar3_s1_", "ar3_s2_", "ar3_s3_", "ar3_s4_", "ar3_s5_", "ar3_choice_", "choice_ar3_", "ar3_c1a_", "node_id", "last_choice", "dialogue_page"]:
		expect(raw_json.find(forbidden) == -1, "%s: persisted save contains forbidden token %s" % [label, forbidden])

func test_gates_and_calendar(locale: String) -> void:
	var def: Dictionary = content.find_record("character_events", LV3)
	expect(not def.is_empty(), locale + ": artoria_lv3_not_a_solo_operation loaded")

	# 1. Familiarity boundary (39 vs 40) & Leadership boundary (79 vs 80), zero Surgery/Emiko-Lv1/Advanced-Referral lock
	var g := setup_ready_for_lv3(11, 960) # Day 11 = Friday 2025-04-11 (3 days after Day 8 Lv2)
	g.set_test_player_attribute("skill", 5)
	expect(not ArtoriaLv3.emiko_lv1_done(g) and not ArtoriaLv3.emiko_lv3_done(g), locale + " [Gate]: Emiko Lv1/Lv3 not done by default")
	g.relation_for("doc_artoria").familiarity = 39
	expect(not g.character_event_available(def), locale + " [Gate]: Familiarity 39 blocked")
	g.relation_for("doc_artoria").familiarity = 40
	expect(g.character_event_available(def), locale + " [Gate]: Familiarity 40 + Leadership 80 allowed without Emiko Lv1 or Surgery gate")

	g.set_test_player_attribute("leadership", 79)
	expect(not g.character_event_available(def), locale + " [Gate]: Leadership 79 blocked")
	g.set_test_player_attribute("leadership", 80)
	expect(g.character_event_available(def), locale + " [Gate]: Leadership 80 allowed")

	# 2. 3-day milestone cooldown (Day 10 = +2d after Day 8 blocked; Day 11 = +3d allowed)
	var g_cd := setup_ready_for_lv3(10, 960)
	expect(not g_cd.character_event_available(def), locale + " [Gate]: 2-day gap blocked by 3-day cooldown")

	# 3. Calendar guards: Saturday (Day 12 -> Sunday closed) & day before Showa Day holiday (Day 28 -> Day 29 closed) blocked
	var g_sat := setup_ready_for_lv3(12, 960)
	expect(not g_sat.character_event_available(def), locale + " [Calendar]: Saturday blocked because next day is Sunday")
	var g_hol := setup_ready_for_lv3(28, 960)
	expect(not g_hol.character_event_available(def), locale + " [Calendar]: Day before closed holiday blocked")

	# 4. Final-two-days guard (`max_day: 363`): Day 361 allowed; Day 364 & Day 365 blocked
	expect(setup_ready_for_lv3(361, 960).character_event_available(def), locale + " [Calendar]: Day 361 allowed")
	expect(not setup_ready_for_lv3(364, 960).character_event_available(def), locale + " [Calendar]: Day 364 blocked")
	expect(not setup_ready_for_lv3(365, 960).character_event_available(def), locale + " [Calendar]: Day 365 blocked")

	# 5. Unresolved admitted inpatient & next-day Advanced Referral booking block Lv3
	var g_inp := setup_ready_for_lv3(11, 600)
	var vid := "visit_" + str(g_inp.patient_queue[0]).trim_prefix("patient_")
	var v = g_inp.open_visit(vid)
	expect(v != null, locale + " [Safety]: opened outpatient visit")
	if v != null:
		v.admitted = true
	g_inp.active_id = ""
	set_exact_day_clock(g_inp, 11, 960)
	expect(not g_inp.character_event_available(def), locale + " [Safety]: unresolved admitted patient blocks Lv3")

	var g_adv := setup_ready_for_lv3(11, 960)
	g_adv.advanced_referral_facts["appointment"] = {"intake_day": 11, "operation_day": 12, "review_day": 14}
	expect(not g_adv.character_event_available(def), locale + " [Safety]: next-day Advanced Referral operation_day blocks Lv3")

func test_emiko_continuity_and_branches(locale: String) -> void:
	# Test all 3 Emiko cross-route states (none, Lv1 only, Lv3 done) + Choice B/C
	var cases := [
		{"name": "em0_a", "em1": false, "em3": false, "branch": "a", "want_s1": "ar3_s1_em3b_01", "forbid_s1": "ar3_s1_em3a_01", "want_c1": "ar3_c1a_2_01", "forbid_c1": "ar3_c1a_1_01"},
		{"name": "em1_a", "em1": true, "em3": false, "branch": "a", "want_s1": "ar3_s1_em3b_01", "forbid_s1": "ar3_s1_em3a_01", "want_c1": "ar3_c1a_1_01", "forbid_c1": "ar3_c1a_2_01"},
		{"name": "em3_a", "em1": true, "em3": true, "branch": "a", "want_s1": "ar3_s1_em3a_01", "forbid_s1": "ar3_s1_em3b_01", "want_c1": "ar3_c1a_1_01", "forbid_c1": "ar3_c1a_2_01"},
		{"name": "em0_b", "em1": false, "em3": false, "branch": "b", "want_s1": "ar3_s1_em3b_01", "forbid_s1": "ar3_s1_em3a_01", "want_c1": "ar3_c1b_01", "forbid_c1": "ar3_c1a_1_01"},
		{"name": "em3_c", "em1": true, "em3": true, "branch": "c", "want_s1": "ar3_s1_em3a_01", "forbid_s1": "ar3_s1_em3b_01", "want_c1": "ar3_c1c_01", "forbid_c1": "ar3_c1a_1_01"},
	]

	for c in cases:
		var g := setup_ready_for_lv3(11, 990)
		if bool(c.em1):
			g._complete_character_event_for_test("emiko_lv1_first_operation", 3)
			g.relation_for("doc_emiko").level = 1
		if bool(c.em3):
			g._complete_character_event_for_test("emiko_lv3_today_i_lead", 6)
			g.relation_for("doc_emiko").level = 3
		set_exact_day_clock(g, 11, 990)

		g.relation_for("nurse_hiroko").met = false
		g.relation_for("nurse_hiroko").familiarity = 2
		g.relation_for("nurse_moe").met = false
		g.relation_for("nurse_moe").familiarity = 5
		g.relation_for("nurse_ange").met = false
		g.relation_for("nurse_ange").familiarity = 7
		var unlocked_before: Array = g.unlocked_procedure_ids.duplicate()

		var ev = g.start_character_event(LV3)
		expect(ev != null, "%s [%s]: started Lv3" % [locale, c.name])
		var visited: Array[String] = []
		var branch := str(c.branch)
		var picks := ["choice_ar3_c1_" + branch, "choice_ar3_c2_" + branch, "choice_ar3_c3_" + branch]

		while not ev.completed and visited.size() < 450:
			var cur: Dictionary = ev.current()
			var nid := str(cur.id)
			visited.append(nid)
			if locale == "en":
				expect(cjk_re.search(str(cur.get("text", ""))) == null, "en [%s]: CJK in text at %s" % [c.name, nid])
				expect(cjk_re.search(str(cur.get("speaker_label", ""))) == null, "en [%s]: CJK in speaker_label at %s" % [c.name, nid])
			var chosen := str(cur.choices[0].id)
			for want in picks:
				for ch in cur.choices:
					if str(ch.id) == want:
						chosen = want
						break
			expect(g.choose_character_event(chosen), "%s [%s]: chose %s at %s" % [locale, c.name, chosen, nid])
			if not ev.completed:
				expect(g.relationship_level("doc_artoria") == 2, "%s [%s]: still Lv2 mid-event" % [locale, c.name])

		expect(ev.completed, "%s [%s]: completed Lv3" % [locale, c.name])
		expect(visited.has(str(c.want_s1)) and not visited.has(str(c.forbid_s1)), "%s [%s]: Scene 1 Emiko Lv3 continuity routed accurately" % [locale, c.name])
		expect(visited.has(str(c.want_c1)) and not visited.has(str(c.forbid_c1)), "%s [%s]: Choice 1 Emiko Lv1 continuity routed accurately" % [locale, c.name])

		g.advance_story_to_day(int(ev.completed_day) + 1, 900)
		g.finish_character_event()

		expect(g.day_number() == 12 and g.clock_text() == "15:00", "%s [%s]: settled at Day 12 15:00" % [locale, c.name])
		expect(g.relationship_level("doc_artoria") == 3, "%s [%s]: Artoria promoted Lv2 -> Lv3" % [locale, c.name])
		expect(int(g.relation_for("doc_artoria").familiarity) == 40, "%s [%s]: familiarity unchanged" % [locale, c.name])
		expect(g.story_flag("artoria_lv3_complete"), "%s [%s]: artoria_lv3_complete set" % [locale, c.name])
		expect(g.unlocked_procedure_ids == unlocked_before, "%s [%s]: no extra procedure unlocked in Lv3" % [locale, c.name])

		# Duty nurses untouched
		expect(not g.staff_is_met("nurse_hiroko") and int(g.relation_for("nurse_hiroko").familiarity) == 2 and not g.relation_for("nurse_hiroko").event_history.has(LV3), "%s [%s]: nurse_hiroko untouched" % [locale, c.name])
		expect(not g.staff_is_met("nurse_moe") and int(g.relation_for("nurse_moe").familiarity) == 5 and not g.relation_for("nurse_moe").event_history.has(LV3), "%s [%s]: nurse_moe untouched" % [locale, c.name])
		expect(not g.staff_is_met("nurse_ange") and int(g.relation_for("nurse_ange").familiarity) == 7 and not g.relation_for("nurse_ange").event_history.has(LV3), "%s [%s]: nurse_ange untouched" % [locale, c.name])

		# v37 BoundarySave purity & round-trip reload stability
		var tmp_save := "/private/tmp/hoshimi_artoria_lv3_test_%s_%s_%d.json" % [locale, c.name, OS.get_process_id()]
		var store := Store.new()
		store.path = tmp_save
		expect(store.write_slot(g, 1), "%s [%s]: saved slot 1" % [locale, c.name])
		var raw1: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(tmp_save))
		assert_no_inner_state(raw1, "%s [%s]" % [locale, c.name])

		var g2 := new_game()
		expect(store.read_slot(g2, 1), "%s [%s]: restored snapshot 1" % [locale, c.name])
		expect(g2.day_number() == 12 and g2.clock_text() == "15:00" and g2.relationship_level("doc_artoria") == 3, "%s [%s]: restored Day 12 15:00 & Lv3" % [locale, c.name])
		expect(not g2.character_event_available(content.find_record("character_events", LV3)), "%s [%s]: completed Lv3 does not re-trigger" % [locale, c.name])
		expect(store.write_slot(g2, 2), "%s [%s]: saved slot 2" % [locale, c.name])
		var g3 := new_game()
		expect(store.read_slot(g3, 2), "%s [%s]: restored snapshot 2" % [locale, c.name])
		expect(g3.elapsed() == g.elapsed() and g3.relationship_level("doc_artoria") == 3, "%s [%s]: second round-trip identical" % [locale, c.name])
		DirAccess.remove_absolute(tmp_save)

func test_ui_app_flow(locale: String) -> void:
	var app = MainScene.instantiate()
	app.saves.path = "/private/tmp/hoshimi_artoria_lv3_ui_unused_%s_%d.json" % [locale, OS.get_process_id()]
	app.title_preferences_path = "/private/tmp/hoshimi_artoria_lv3_ui_prefs_%s_%d.cfg" % [locale, OS.get_process_id()]
	app.title_notice_enabled = false
	root.add_child(app)
	expect(app.content.load_all(locale), locale + " [UI]: load_all")
	app.configure_game_content()
	app.game.reset()
	var target_day := ArtoriaLv3.prepare_test_save(app.game, LV3, 11)
	set_exact_day_clock(app.game, target_day, 960)
	app.show_player_office()
	app.request_end_workday()
	expect(app.screen == "character_event" and app.game.active_character_event_id == LV3, locale + " [UI]: request_end_workday launched Artoria Lv3")

	var ev = app.game.character_events[LV3]
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
	expect(app.game.day_number() == target_day + 1 and app.game.clock_text() == "15:00", locale + " [UI]: completion screen shows next day 15:00")
	expect(app.game.relationship_level("doc_artoria") == 3, locale + " [UI]: Lv3 reached on completion screen")
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
		test_emiko_continuity_and_branches(locale)
		test_ui_app_flow(locale)

	print("ARTORIA LV3 HEADLESS TEST: %d checks; %d failure(s)" % [checks, failures.size()])
	for f in failures:
		print("  FAIL: " + f)
	quit(1 if not failures.is_empty() else 0)
