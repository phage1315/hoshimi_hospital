extends SceneTree
## Headless integration, UI, bilingual, team-unlock, and v37 save-boundary test for
## Emiko Mido (`doc_emiko`) Relationship Lv2 V2.1: 《这一次听你的》 (`emiko_lv2_follow_my_lead`).

const ContentLoader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const Referral = preload("res://godot/systems/advanced_referral.gd")
const Store = preload("res://godot/systems/save_store.gd")
const MainScene = preload("res://godot/scenes/main.tscn")

const LV0 := "emiko_intro_rumored_hands"
const LV1 := "emiko_lv1_first_operation"
const LV2 := "emiko_lv2_follow_my_lead"

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
	while not ev.completed and guard < 400:
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

func setup_ready_for_lv2(day: int = 10) -> RefCounted:
	var g := new_game()
	g.set_test_time(day, 600)
	g._complete_character_event_for_test("intro_doc_asuka_director_office", 1)
	g.meet_staff("doc_asuka")
	g.set_test_player_attribute("skill", 70)
	expect(finish_event(g, LV0), "Lv0 V1.2 completes at Surgery 70")

	var lv1_day := day + 3
	g.advance_story_to_day(lv1_day, 600)
	while g.is_hospital_closed_day():
		lv1_day += 1
		g.advance_story_to_day(lv1_day, 600)
	g.set_test_player_attribute("skill", 75)
	expect(finish_event(g, LV1), "Lv1 V2.2 completes at Surgery 75")

	var lv2_day := lv1_day + 3
	g.advance_story_to_day(lv2_day, 600)
	while g.is_hospital_closed_day():
		lv2_day += 1
		g.advance_story_to_day(lv2_day, 600)
	g.set_test_player_attribute("skill", 80)
	return g

func run_for_locale(locale: String) -> void:
	content = ContentLoader.new()
	expect(content.load_all(locale), locale + ": ContentLoader.load_all")

	# 1. Prerequisite check: `level=1` WITHOUT `emiko_lv1_first_operation` completed MUST NOT unlock Lv2!
	var g_fake := new_game()
	g_fake.set_test_time(20, 600)
	g_fake.meet_staff("doc_emiko")
	g_fake.relation_for("doc_emiko").level = 1
	g_fake.set_test_player_attribute("skill", 90)
	expect(not g_fake.character_event_available(g_fake.character_event_definitions[LV2]), locale + ": level=1 without Lv1 completion does NOT unlock Lv2")

	# 2. Gate check: Surgery 79 blocked even at high Familiarity; Surgery 80 + Familiarity 0 + 0 ordinary co-surgeries unlocked on open workday OR window, blocked on Sunday.
	var g := setup_ready_for_lv2(10)
	expect(int(g.completed_surgeries_total) == 0, locale + ": zero ordinary co-surgeries required before Lv2")
	g.relation_for("doc_emiko").familiarity = 90
	g.set_test_player_attribute("skill", 79)
	expect(not g.character_event_available(g.character_event_definitions[LV2]), locale + ": Surgery 79 + Familiarity 90 blocked")
	expect(str(g.next_character_event_at("or").get("id", "")) != LV2, locale + ": OR scheduler does NOT offer Lv2 at Surgery 79")

	g.relation_for("doc_emiko").familiarity = 0
	g.set_test_player_attribute("skill", 80)
	expect(g.character_event_available(g.character_event_definitions[LV2]), locale + ": Surgery 80 + Familiarity 0 available")
	expect(str(g.next_character_event_at("or").get("id", "")) == LV2, locale + ": OR scheduler offers emiko_lv2_follow_my_lead on open workday")

	# Closed Sunday check:
	var saved_day: int = int(g.day_number())
	var sun_day: int = saved_day
	while not g.is_sunday():
		sun_day += 1
		g.set_test_time(sun_day, 600)
	expect(g.next_character_event_at("or").is_empty(), locale + ": OR scheduler blocks Lv2 on closed Sunday")
	g.set_test_time(saved_day, 600)

	# Mid-event check: Surgical team eligibility MUST NOT unlock at event start or mid-event before Scene G @end!
	var g_mid := setup_ready_for_lv2(10)
	var mid_ev = g_mid.start_character_event(LV2)
	expect(mid_ev != null and g_mid.choose_character_event("continue_em2_001"), locale + ": mid-event step advances")
	expect(not g_mid.staff_can_join_surgery_team("doc_emiko") and g_mid.relationship_level("doc_emiko") == 1 and int(g_mid.relation_for("doc_emiko").familiarity) == 10, locale + ": team eligibility, rank, and +10 bonus do NOT settle before Scene G @end")

	# 3. Supporting cast (`nurse_hiroko`, `nurse_moe`) unmet boundary + 0 ordinary surgeries added + 3 branch parity!
	var branch_triples := [
		["choice_em2_b1_a", "choice_em2_d2_a", "choice_em2_f3_a"],
		["choice_em2_b1_b", "choice_em2_d2_b", "choice_em2_f3_b"],
		["choice_em2_b1_c", "choice_em2_d2_c", "choice_em2_f3_c"],
	]
	var baseline_facts := ""
	for idx in range(branch_triples.size()):
		var gb := setup_ready_for_lv2(10)
		gb.relation_for("nurse_hiroko").met = false
		gb.relation_for("nurse_moe").met = false
		gb.set_test_player_attribute("presence", -20 if idx == 0 else (0 if idx == 1 else 60))
		var start_elapsed: int = int(gb.elapsed())
		var start_surgeries := int(gb.completed_surgeries_total)
		expect(finish_event(gb, LV2, branch_triples[idx]), "%s: branch %d completes cleanly" % [locale, idx])
		expect(gb.relationship_level("doc_emiko") == 2, "%s: branch %d sets doc_emiko level == 2" % [locale, idx])
		expect(int(gb.relation_for("doc_emiko").familiarity) == 20, "%s: branch %d grants exact fixed +10 Familiarity (10 -> 20)" % [locale, idx])
		expect(gb.elapsed() - start_elapsed == 100, "%s: branch %d settles +100 minutes" % [locale, idx])
		expect(int(gb.completed_surgeries_total) == start_surgeries, "%s: branch %d pure VN does NOT increment completed_surgeries_total" % [locale, idx])
		expect(not gb.staff_is_met("nurse_hiroko") and gb.relationship_level("nurse_hiroko") == 0, "%s: branch %d does NOT mutate nurse_hiroko met/level" % [locale, idx])
		expect(not gb.staff_is_met("nurse_moe") and gb.relationship_level("nurse_moe") == 0, "%s: branch %d does NOT mutate nurse_moe met/level" % [locale, idx])
		expect(gb.staff_can_join_surgery_team("doc_emiko") and gb.relation_for("doc_emiko").unlocked_benefits.has("unlock_emiko_surgical_team"), "%s: branch %d unlocks doc_emiko surgical team eligibility at @end" % [locale, idx])
		expect(gb.story_flag("emiko_lv2_complete") and gb.story_flag("emiko_reliable_surgical_partner"), "%s: branch %d sets completion_story_flags" % [locale, idx])
		gb.set_test_player_attribute("presence", 0)
		var settled := JSON.stringify({
			"elapsed": gb.elapsed(),
			"emiko_rel": gb.relation_for("doc_emiko"),
			"flags": gb.story_flags,
		})
		if idx == 0:
			baseline_facts = settled
		else:
			expect(settled == baseline_facts, "%s: branch %d produces identical settled facts to branch 0" % [locale, idx])

	# 4. Full UI walkthrough via Hospital Guide -> `show_location("or")`:
	var app := MainScene.instantiate()
	app.title_notice_enabled = false
	app.saves.path = "/private/tmp/emiko_lv2_ui_unused_%s_%d.json" % [locale, OS.get_process_id()]
	app.title_preferences_path = "/private/tmp/emiko_lv2_ui_prefs_%s_%d.cfg" % [locale, OS.get_process_id()]
	root.add_child(app)
	expect(app.content.load_all(locale), locale + " [UI]: app.content.load_all")
	app.configure_game_content()
	app.game.reset()
	app.game._complete_character_event_for_test("intro_doc_asuka_director_office", 1)
	app.game.meet_staff("doc_asuka")
	app.game.set_test_time(10, 600)
	app.game.set_test_player_attribute("skill", 70)
	expect(finish_event(app.game, LV0), locale + " [UI]: complete Lv0")

	var lv1_day := 13
	app.game.advance_story_to_day(lv1_day, 600)
	while app.game.is_hospital_closed_day():
		lv1_day += 1
		app.game.advance_story_to_day(lv1_day, 600)
	app.game.set_test_player_attribute("skill", 75)
	expect(finish_event(app.game, LV1), locale + " [UI]: complete Lv1")

	var play_day := lv1_day + 3
	app.game.advance_story_to_day(play_day, 600)
	while app.game.is_hospital_closed_day():
		play_day += 1
		app.game.advance_story_to_day(play_day, 600)
	app.game.set_test_player_attribute("skill", 80)
	app.game.relation_for("nurse_hiroko").met = false
	app.game.relation_for("nurse_moe").met = false

	app.show_location("or")
	expect(str(app.screen) == "character_event" and str(app.game.active_character_event_id) == LV2, locale + " [UI]: show_location('or') auto-launches emiko_lv2_follow_my_lead")

	var seen_speakers := {}
	var seen_choices := 0
	var seen_corridor_white_coat := false
	var ui_steps := 0
	while app.game.character_events.has(LV2) and not app.game.character_events[LV2].completed and ui_steps < 420:
		ui_steps += 1
		expect(not app.game.can_save_progress(), "%s [UI]: save locked on step %d" % [locale, ui_steps])
		var cur_node: Dictionary = app.game.character_events[LV2].current()
		var nid := str(cur_node.id)
		if nid == "em2_235":
			seen_corridor_white_coat = (str(cur_node.get("background_id", "")) == "or_entrance" and str(cur_node.get("outfit", "")) == "white_coat")
		if str(cur_node.get("presentation", "")) == "choice":
			seen_choices += 1
			var pick_id := str(cur_node.choices[seen_choices - 1].id)
			var btn := app.page.get_node_or_null("EventChoice_" + pick_id) as Button
			expect(btn != null and btn.size.x >= 1000.0, "%s [UI]: full-width choice button rendered on %s" % [locale, nid])
			if locale == "en" and btn != null:
				expect(cjk_re.search(btn.text) == null, "en [UI]: zero CJK in choice button " + pick_id)
			app.choose_character_event(pick_id)
		else:
			var dlg: Node = app.page.get_node_or_null("CharacterEventDialogue")
			expect(dlg != null, "%s [UI]: dialogue box rendered on %s" % [locale, nid])
			var spk := str(cur_node.get("speaker_label", ""))
			seen_speakers[spk] = true
			if locale == "en":
				expect(cjk_re.search(spk) == null, "en [UI]: zero CJK in speaker_label on " + nid)
				expect(cjk_re.search(str(cur_node.text)) == null, "en [UI]: zero CJK in node text on " + nid)
			var cont_btn := app.page.get_node_or_null("EventDialogueContinue") as Button
			if cont_btn != null:
				app.advance_dialogue_page(app.show_character_event)
			else:
				app.choose_character_event(str(cur_node.choices[0].id))

	expect(seen_choices == 3, locale + " [UI]: encountered all 3 interactive surgical choices (B1, D2, F3)")
	expect(seen_corridor_white_coat, locale + " [UI]: Scene G transitioned to corridor + everyday white_coat")
	if locale == "zh_CN":
		for req_spk in ["旁白", "御堂江美子", "坂口隆司", "杉村弘子", "本庄萌恵", "患者"]:
			expect(seen_speakers.has(req_spk), "zh_CN [UI]: speaker rendered: " + req_spk)
	else:
		for req_spk in ["Narrator", "Emiko Mido", "Ryuji Sakaguchi", "Hiroko Sugimura", "Moe Honjo", "Patient"]:
			expect(seen_speakers.has(req_spk), "en [UI]: speaker rendered: " + req_spk)

	expect(str(app.screen) == "character_event_complete", locale + " [UI]: landed on completion card")
	app.game.finish_character_event()
	app.show_map(false)
	expect(app.game.can_save_progress(), locale + " [UI]: save unlocked at safe Hospital Guide boundary after completion")
	expect(app.game.relationship_level("doc_emiko") == 2 and int(app.game.relation_for("doc_emiko").familiarity) == 20 and app.game.staff_can_join_surgery_team("doc_emiko"), locale + " [UI]: settled Lv2 +10 Familiarity + surgical team unlocked")

	# 5. BoundarySave v37 inner-state purity & reload stability:
	var tmp_save := "/private/tmp/emiko_lv2_v21_test_%s_%d.json" % [locale, OS.get_process_id()]
	var store := Store.new()
	store.path = tmp_save
	expect(store.write_slot(app.game, 1), locale + " [Save]: write_slot to /private/tmp")
	var raw_json := FileAccess.get_file_as_string(tmp_save)
	for forbidden_inner in ["em2_001", "em2_101", "em2_choice_d2", "choice_em2_d2_a", "continue_em2_254"]:
		expect(not raw_json.contains(forbidden_inner), locale + " [Save]: persisted file free of inner ID " + forbidden_inner)

	var reloaded := new_game()
	expect(store.read_slot(reloaded, 1), locale + " [Save]: read_slot from /private/tmp")
	expect(reloaded.relationship_level("doc_emiko") == 2 and int(reloaded.relation_for("doc_emiko").familiarity) == 20, locale + " [Save]: reloaded preserves Lv2 and Familiarity=20 without duplicate bonus")
	expect(reloaded.elapsed() == app.game.elapsed(), locale + " [Save]: reloaded preserves exact settled elapsed time")
	expect(not reloaded.character_event_available(reloaded.character_event_definitions[LV2]), locale + " [Save]: completed Lv2 does NOT re-trigger after reload")
	expect(reloaded.staff_can_join_surgery_team("doc_emiko"), locale + " [Save]: surgical team stays unlocked after reload at Lv2")
	DirAccess.remove_absolute(tmp_save)

	# Ordinary surgical team assignment now includes Emiko (checked after reload too!):
	var visit = reloaded.open_visit("visit_sora")
	visit.admitted = true
	var prep = reloaded.open_preop("preop_sora")
	prep.stage_id = "team"
	expect(prep.candidates("assistant_surgeon").any(func(p): return str(p.id) == "doc_emiko"), locale + " [Team]: Emiko available in ordinary assistant_surgeon roster")

	# 6. Pre-V2.1 legacy save compatibility (old 14-node Lv2 completed save with legacy branch flags):
	var legacy_src := setup_ready_for_lv2(10)
	legacy_src._complete_character_event_for_test(LV2, 16)
	legacy_src.relation_for("doc_emiko").level = 2
	legacy_src.relation_for("doc_emiko").familiarity = 20
	legacy_src.relation_for("doc_emiko").rank_history = [LV1, LV2]
	legacy_src.relation_for("doc_emiko").flags = ["emiko_intro_complete", "emiko_lv1_complete", "emiko_postop_excitement_hint", "emiko_lv2_requested_reason", "emiko_lv2_followed", "emiko_lv2_only_hands", "emiko_lv2_complete", "emiko_reliable_surgical_partner"]
	var legacy_snap: Dictionary = legacy_src.snapshot()
	var legacy_loaded := new_game()
	expect(legacy_loaded.restore(legacy_snap), locale + " [LegacySave]: pre-V2.1 completed Lv2 save restores cleanly")
	expect(legacy_loaded.relationship_level("doc_emiko") == 2 and int(legacy_loaded.relation_for("doc_emiko").familiarity) == 20, locale + " [LegacySave]: preserves Lv2 and Familiarity=20 without re-grant")
	expect(legacy_loaded.elapsed() == legacy_src.elapsed(), locale + " [LegacySave]: settled elapsed time unchanged")
	expect(not legacy_loaded.character_event_available(legacy_loaded.character_event_definitions[LV2]), locale + " [LegacySave]: does NOT re-trigger Lv2")
	expect(legacy_loaded.staff_can_join_surgery_team("doc_emiko"), locale + " [LegacySave]: preserves surgical team eligibility")

	root.remove_child(app)
	app.free()

func run() -> void:
	run_for_locale("zh_CN")
	run_for_locale("en")
	if failures.is_empty():
		print("EMIKO LV2 V2.1 TEST PASS: %d checks, 0 failure(s)." % checks)
		quit(0)
	else:
		for item in failures:
			push_error(item)
		print("EMIKO LV2 V2.1 TEST FAIL: %d failure(s) out of %d checks." % [failures.size(), checks])
		quit(1)
