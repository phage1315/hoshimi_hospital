extends SceneTree
## Headless regression suite for Emiko Mido (`doc_emiko`) Lv0 V1.2:
## 《传闻中的手》 (`emiko_intro_rumored_hands`) + Surgery 70 Gate + UI Unlock Hints.
## Uses in-memory fixtures and isolated /private/tmp files only. Never touches player save slots.

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")

const INTRO := "emiko_intro_rumored_hands"
const DENIED := "emiko_office_denied"

var content = Loader.new()
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

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
	return g

func assert_no_inner_state(value) -> void:
	if value is Dictionary:
		for k in value:
			expect(str(k) not in ["node_id", "choices", "last_choice", "dialogue_page_index", "step_index", "quote_index", "quote_actor_ids"], "BoundarySave leaked inner state key: " + str(k))
			assert_no_inner_state(value[k])
	elif value is Array:
		for item in value:
			assert_no_inner_state(item)

func last_notice_and_clear(app) -> String:
	var latest := ""
	var dialogs: Array = []
	for child in app.get_children():
		if child is AcceptDialog:
			latest = str(child.dialog_text)
			dialogs.append(child)
	for d in dialogs:
		d.hide()
		app.remove_child(d)
		d.free()
	return latest

func play_branch(g: RefCounted, branch_choice_id: String) -> Array[String]:
	var visited: Array[String] = []
	var ev = g.start_character_event(INTRO)
	if ev == null:
		return visited
	expect(not g.can_save_progress(), "Save must be locked while Emiko Lv0 V1.2 is playing")
	var guard := 0
	while not ev.completed and guard < 80:
		guard += 1
		var cur: Dictionary = ev.current()
		var nid := str(cur.id)
		visited.append(nid)
		var chosen := str(cur.choices[0].id)
		if nid == "em0_030":
			chosen = branch_choice_id
		expect(g.choose_character_event(chosen), "Choice accepted on " + nid + " -> " + chosen)
	expect(ev.completed, "Event completed on branch " + branch_choice_id)
	g.finish_character_event()
	return visited

func test_gate_branches_and_boundary_save(locale: String) -> void:
	# 1. Surgery 70 Gate + Asuka prerequisite + emiko_office_denied
	var g0 := new_game()
	g0.set_test_time(6, 600)
	var intro_def: Dictionary = g0.character_event_definitions[INTRO]
	var denied_def: Dictionary = g0.character_event_definitions[DENIED]
	expect(not intro_def.has("auto_follow_up"), locale + ": V1.2 has no auto_follow_up")
	expect(g0.character_event_available(denied_def), locale + ": emiko_office_denied available before meeting Emiko")
	expect(not g0.character_event_available(intro_def), locale + ": Lv0 unavailable before Asuka intro and Surgery 70")

	g0.set_test_player_attribute("skill", 80)
	expect(not g0.character_event_available(intro_def), locale + ": Lv0 unavailable at Surgery 80 without Asuka intro")

	expect(g0._complete_character_event_for_test("intro_doc_asuka_director_office", 2), locale + ": fixture Asuka intro")
	g0.meet_staff("doc_asuka")
	g0.set_test_player_attribute("skill", 69)
	expect(not g0.character_event_available(intro_def), locale + ": Lv0 strictly rejects Surgery 69")
	expect(g0.next_character_event_at("emiko_office").get("id", "") == DENIED, locale + ": Surgery 69 at emiko_office routes to emiko_office_denied")

	g0.set_test_player_attribute("skill", 70)
	expect(g0.character_event_available(intro_def), locale + ": Lv0 unlocks at Surgery 70 + Asuka intro")
	expect(g0.next_character_event_at("emiko_office").get("id", "") == INTRO, locale + ": Surgery 70 at emiko_office prioritizes Lv0 over refusal")

	# 2. All 3 choice branches play through expected turns, converge on em0_032..em0_040, and settle identical facts
	var expected_paths := {
		"choice_em0_face": ["em0_a_01", "em0_a_02", "em0_a_03", "em0_032"],
		"choice_em0_resume": ["em0_b_01", "em0_032"],
		"choice_em0_table": ["em0_c_01", "em0_c_02", "em0_032"],
	}
	var baseline_facts = null
	for branch_id in ["choice_em0_face", "choice_em0_resume", "choice_em0_table"]:
		var gb := new_game()
		gb.set_test_time(8, 600)
		gb._complete_character_event_for_test("intro_doc_asuka_director_office", 2)
		gb.meet_staff("doc_asuka")
		gb.set_test_player_attribute("skill", 70)
		var before_elapsed := int(gb.elapsed())
		var visited := play_branch(gb, branch_id)
		var sub: Array = expected_paths[branch_id]
		for target_nid in sub:
			expect(target_nid in visited, locale + " [" + branch_id + "]: visited " + target_nid)
		expect(visited[0] == "em0_001" and visited[visited.size() - 1] == "em0_040", locale + " [" + branch_id + "]: starts at em0_001 and ends at em0_040")
		expect(gb.staff_is_met("doc_emiko") and gb.relationship_level("doc_emiko") == 0, locale + " [" + branch_id + "]: sets met=true, level=0")
		expect(int(gb.relation_for("doc_emiko").familiarity) == 0, locale + " [" + branch_id + "]: leaves familiarity at 0")
		expect(not gb.staff_can_join_surgery_team("doc_emiko"), locale + " [" + branch_id + "]: does NOT unlock surgical team at Lv0")
		expect(gb.day_number() == 8 and int(gb.elapsed()) == before_elapsed + 25, locale + " [" + branch_id + "]: settles +25 min on same day without forced next-day surgery")
		expect(gb.relation_for("doc_emiko").flags.has("emiko_intro_complete"), locale + " [" + branch_id + "]: sets emiko_intro_complete flag")
		expect(gb.can_save_progress(), locale + " [" + branch_id + "]: save unlocked after returning to safe boundary")

		var snap: Dictionary = gb.snapshot()
		assert_no_inner_state(snap)
		var outcome := JSON.stringify({"elapsed": gb.elapsed(), "relationships": gb.relationships, "flags": gb.story_flags})
		if baseline_facts == null:
			baseline_facts = outcome
		else:
			expect(outcome == baseline_facts, locale + " [" + branch_id + "]: settled BoundarySave facts identical across all 3 branches")

	# 3. Save/load stability & legacy pre-V1.2 completion compatibility
	var g_legacy := new_game()
	g_legacy.set_test_time(12, 660)
	g_legacy._complete_character_event_for_test("intro_doc_asuka_director_office", 2)
	g_legacy.meet_staff("doc_asuka")
	g_legacy._complete_character_event_for_test(INTRO, 6)
	g_legacy.meet_staff("doc_emiko")
	var legacy_elapsed := int(g_legacy.elapsed())
	var legacy_snap: Dictionary = g_legacy.snapshot()
	var g_restored := new_game()
	expect(g_restored.restore(legacy_snap), locale + ": legacy completed Lv0 restores cleanly against refactored 45-node V1.2")
	expect(g_restored.character_event_done(INTRO) and not g_restored.character_event_available(g_restored.character_event_definitions[INTRO]), locale + ": restored legacy Lv0 does not replay")
	expect(g_restored.day_number() == 12 and int(g_restored.elapsed()) == legacy_elapsed, locale + ": restored legacy Lv0 preserves exact elapsed time")

func test_ui_hints_and_dialogue_rendering(app, locale: String) -> void:
	# 1. Verify UI unlock hints for doc_emiko and doc_artoria (70, never 56, plus Asuka prerequisite)
	app.game.reset()
	app.game.set_test_time(5, 600)
	app.game.set_test_player_attribute("skill", 72)
	app.introduce_staff_at_location("doc_emiko", "emiko_office")
	var msg_no_asuka := last_notice_and_clear(app)
	if locale == "zh_CN":
		expect(msg_no_asuka.contains("明日香") and not msg_no_asuka.contains("56"), locale + ": Emiko notice before Asuka intro prompts Asuka first (" + msg_no_asuka + ")")
	else:
		expect(msg_no_asuka.contains("Asuka") and not msg_no_asuka.contains("56"), locale + ": Emiko notice before Asuka intro prompts Asuka first (" + msg_no_asuka + ")")

	app.game._complete_character_event_for_test("intro_doc_asuka_director_office", 2)
	app.game.meet_staff("doc_asuka")
	app.game.set_test_player_attribute("skill", 64)
	# Also mark emiko_office_denied done (note: category contextual vs introduction; introduce_staff_at_location only starts category=="introduction")
	app.introduce_staff_at_location("doc_emiko", "emiko_office")
	var msg_emiko_low := last_notice_and_clear(app)
	expect(msg_emiko_low.contains("70") and msg_emiko_low.contains("64") and not msg_emiko_low.contains("56"), locale + ": ui.unlock.emiko displays 70 and current skill 64 (" + msg_emiko_low + ")")

	app.introduce_staff_at_location("doc_artoria", "artoria_office")
	var msg_artoria_emiko := last_notice_and_clear(app)
	expect(msg_artoria_emiko.contains("70") and not msg_artoria_emiko.contains("56"), locale + ": ui.unlock.artoria_emiko displays 70 (" + msg_artoria_emiko + ")")

	# 2. Step through full V1.2 UI playback including multi-page Beat 01 and 3-choice Beat 30
	app.game.set_test_player_attribute("skill", 70)
	app.introduce_staff_at_location("doc_emiko", "emiko_office")
	expect(app.screen == "character_event" and app.game.active_character_event_id == INTRO, locale + ": introduce_staff_at_location launches Emiko Lv0 at Surgery 70")
	var guard := 0
	var saw_three_choices := false
	while app.screen == "character_event" and app.game.character_events.has(INTRO) and not app.game.character_events[INTRO].completed and guard < 120:
		guard += 1
		var cont_btn = app.page.get_node_or_null("EventDialogueContinue")
		if cont_btn != null:
			app.advance_dialogue_page(app.show_character_event)
			continue
		var c_face = app.page.get_node_or_null("EventChoice_choice_em0_face")
		var c_res = app.page.get_node_or_null("EventChoice_choice_em0_resume")
		var c_tab = app.page.get_node_or_null("EventChoice_choice_em0_table")
		if c_face != null and c_res != null and c_tab != null:
			saw_three_choices = true
			app.choose_character_event("choice_em0_face")
			continue
		var cur_node: Dictionary = app.game.character_events[INTRO].current()
		app.choose_character_event(str(cur_node.choices[0].id))
	expect(saw_three_choices, locale + ": UI rendered all 3 choice buttons on Beat 30")
	expect(app.game.character_events[INTRO].completed, locale + ": UI playback reached completion")
	app.game.finish_character_event()
	app.show_map(false)
	expect(app.game.staff_is_met("doc_emiko") and app.game.day_number() == 5, locale + ": UI completion returns to same day without forced follow-up")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	app.title_notice_enabled = false
	app.saves.path = "/private/tmp/emiko_lv0_unused_%s.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/emiko_lv0_prefs_%s.cfg" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Load content " + locale)
		expect(app.content.load_all(locale), "Load app content " + locale)
		app.configure_game_content()
		test_gate_branches_and_boundary_save(locale)
		test_ui_hints_and_dialogue_rendering(app, locale)
	app.queue_free()
	await process_frame
	print("EMIKO LV0 V1.2 TEST: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures > 0 else 0)
