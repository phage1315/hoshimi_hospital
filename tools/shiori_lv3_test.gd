extends SceneTree
## Runtime regression test for Shiori Fujisaki's Relationship Lv3 two-volume arc:
## - Volume 1 (`shiori_lv3_part_a_yuko_surgery`): 《朝日奈夕子的手术》 (206 beats + live `surgery_appendix` Runner)
## - Volume 2 (`shiori_lv3_part_b_dinner_walk`): 《四人晚餐与那晚的归途》 (178 beats -> Lv2 -> Lv3)

const PART_A := "shiori_lv3_part_a_yuko_surgery"
const PART_B := "shiori_lv3_part_b_dinner_walk"
const LV1 := "shiori_lv1_doctors_worry"
const LV2 := "shiori_lv2_record_shop"
const INTRO_WARD := "intro_doc_shiori_whole_patient_ward"
const INTRO_HIROKO := "intro_rumi_shiori_hiroko_monday_0900"
const PART_A_NODES := 206
const PART_B_NODES := 178

const EventSession = preload("res://godot/systems/character_event_session.gd")
const ShioriLv3 = preload("res://godot/systems/shiori_lv3.gd")
const AyakoReturn = preload("res://godot/systems/ayako_return.gd")
const Codec = preload("res://godot/systems/boundary_save.gd")

var app
var checks := 0
var failures := 0
var han := RegEx.new()

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func inspect_clean(value: Variant, path: String = "root") -> void:
	if value is Dictionary:
		for key in value:
			expect(
				key not in [
					"node_id", "stage_id", "choices", "choice_id", "action_log",
					"last_choice", "feedback", "speaker", "opening_index", "response_index",
					"procedure_step_index", "resolved_random_choices", "surgery_rng_seed",
					"case_variant_id", "diagnosis_action_order", "active_special_event", "active_adult_intimacy"
				],
				"no inner state at " + path + "." + str(key)
			)
			inspect_clean(value[key], path + "." + str(key))
	elif value is Array:
		for item in value:
			inspect_clean(item, path)

func _initialize() -> void:
	han.compile("[㐀-鿿]")
	call_deferred("run")

func traverse_branch_index(
	definition: Dictionary,
	expected_nodes: int,
	expected_rp: int,
	locale: String,
	opt_idx: int,
	seen_portraits: Dictionary,
	seen_bgs: Dictionary,
	seen_nodes: Dictionary
) -> void:
	var session = EventSession.new(definition)
	var guard := 0
	var visited_local := {}
	var rp_count := 0
	while not session.completed and guard <= expected_nodes + 6:
		guard += 1
		var node: Dictionary = session.current()
		var node_id := str(node.get("id", ""))
		expect(not node_id.is_empty() and not visited_local.has(node_id), "valid acyclic node " + node_id)
		visited_local[node_id] = true
		seen_nodes[node_id] = true
		seen_bgs[str(node.get("background_id", ""))] = true

		var eps: Array = node.get("event_portraits", [])
		var cg_p := str(node.get("cg_path", ""))
		if bool(node.get("hide_portrait", false)):
			expect(eps.is_empty() and cg_p.is_empty(), "hidden-portrait beat has empty visuals on " + node_id)
		elif not cg_p.is_empty():
			expect(eps.is_empty(), "CG beat omits event_portraits on " + node_id)
			expect(str(node.get("cg_fit", "")) == "cover" and float(node.get("cg_dialogue_delay_seconds", 0.0)) == 1.0, "CG beat has cover fit + 1.0s clean reveal on " + node_id)
			expect(ResourceLoader.exists("res://" + cg_p), "CG resource exists res://" + cg_p)
		else:
			expect(not eps.is_empty(), "visible beat has event_portraits on " + node_id)
			for ep in eps:
				var p := str(ep.get("path", ""))
				seen_portraits[p] = true
				expect(ResourceLoader.exists("res://" + p), "portrait resource exists res://" + p)

		if locale == "en":
			expect(han.search(str(node.get("text", ""))) == null, "English text has no CJK " + node_id)
			expect(han.search(str(node.get("speaker_label", ""))) == null, "English speaker has no CJK " + node_id)

		var choices: Array = node.get("choices", [])
		expect(choices.size() in [1, 2], "1 or 2 choices on " + node_id)
		if choices.is_empty():
			return
		var pick := 0
		if choices.size() == 2:
			rp_count += 1
			pick = opt_idx
		if locale == "en":
			for ch in choices:
				expect(han.search(str(ch.get("label", ""))) == null, "English choice has no CJK on " + node_id)
		expect(session.apply(str(choices[pick].get("id", "")), {}), "advance " + node_id)

	expect(session.completed, "completed traversal " + str(definition.get("id", "")) + " opt=" + str(opt_idx) + " in " + locale)
	expect(rp_count == expected_rp, "expected RP count " + str(expected_rp) + " in " + locale + " opt=" + str(opt_idx))

func drive_story_surgery_to_completion(expect_english: bool, observed_feedback: Array[String]) -> void:
	var guard := 0
	var prep = app.game.preops.get(ShioriLv3.STORY_PREOP_ID)
	expect(prep != null, "story surgery preop session exists")
	if prep == null:
		return
	app.game.set_intraoperative_crisis_enabled(false)
	while not prep.surgery_success and guard < 80:
		guard += 1
		var fb := str(prep.feedback)
		if not fb.is_empty() and not observed_feedback.has(fb):
			observed_feedback.append(fb)
			if expect_english:
				expect(han.search(fb) == null, "English surgery feedback has no CJK: " + fb)
		if str(prep.current().get("kind", "")) == "surgery_execute":
			app.preop_event({"kind": "action", "id": "execute_confirmed_procedure"})
		elif prep.awaiting_patient_choice:
			var actions: Array = prep.active_patient_interaction.get("actions", [])
			expect(not actions.is_empty(), "patient choice has action")
			app.preop_event({"kind": "patient_interaction_action", "id": str(actions[0].id)})
		elif prep.awaiting_patient_acknowledgement:
			app.preop_event({"kind": "patient_acknowledge"})
		elif prep.awaiting_flow_acknowledgement:
			app.preop_event({"kind": "flow_acknowledge"})
		else:
			var step: Dictionary = prep.surgery_flow_step()
			var picked_id := ""
			for opt in step.get("options", []):
				if bool(opt.get("correct", false)):
					picked_id = str(opt.get("id", ""))
					break
			expect(not picked_id.is_empty(), "found correct option for " + str(step.get("id", "")))
			app.preop_event({"kind": "surgery_step", "id": picked_id})
	var final_fb := str(prep.feedback)
	if not final_fb.is_empty() and not observed_feedback.has(final_fb):
		observed_feedback.append(final_fb)
	expect(prep.surgery_success and str(prep.current().get("kind", "")) == "surgery_complete", "story surgery reached surgery_complete")
	expect(prep.pain == 0, "spinal anesthesia kept intraoperative pain at 0")

func run() -> void:
	var tmp_save_path := "/private/tmp/shiori_lv3_unused_%s.json" % OS.get_process_id()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = tmp_save_path
	root.add_child(app)
	await process_frame

	# 1) Static & runtime bilingual node/portrait/background verification across zh_CN & en
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "content loads " + locale)
		app.configure_game_content()
		var def_a: Dictionary = app.game.character_event_definitions.get(PART_A, {})
		var def_b: Dictionary = app.game.character_event_definitions.get(PART_B, {})
		expect(not def_a.is_empty() and def_a.get("nodes", []).size() == PART_A_NODES, "registered 206-beat Part A in " + locale)
		expect(not def_b.is_empty() and def_b.get("nodes", []).size() == PART_B_NODES, "registered 178-beat Part B in " + locale)

		var seen_portraits := {}
		var seen_bgs := {}
		var seen_nodes_a := {}
		var seen_nodes_b := {}
		traverse_branch_index(def_a, PART_A_NODES, 1, locale, 0, seen_portraits, seen_bgs, seen_nodes_a)
		traverse_branch_index(def_a, PART_A_NODES, 1, locale, 1, seen_portraits, seen_bgs, seen_nodes_a)
		traverse_branch_index(def_b, PART_B_NODES, 3, locale, 0, seen_portraits, seen_bgs, seen_nodes_b)
		traverse_branch_index(def_b, PART_B_NODES, 3, locale, 1, seen_portraits, seen_bgs, seen_nodes_b)
		expect(seen_nodes_a.size() == PART_A_NODES, "Part A A/B union covers all 206 nodes in " + locale)
		expect(seen_nodes_b.size() == PART_B_NODES, "Part B A/B union covers all 178 nodes in " + locale)
		expect(seen_portraits.size() == 41, "all 41 remaining distinct portraits exercised across Part A + Part B in " + locale)

		for bg_id in ["clinic", "ward", "operating_room", "shiori_lv3_trattoria_exterior_evening", "italian_trattoria", "after_work_street_autumn_night", "shiori_lv3_apartment_entrance_night"]:
			expect(seen_bgs.has(bg_id), "background exercised " + bg_id + " in " + locale)
			var bg_rec: Dictionary = app.content.find_record("backgrounds", bg_id)
			expect(not bg_rec.is_empty() and ResourceLoader.exists("res://" + str(bg_rec.get("path", ""))), "background loads for " + bg_id)
			if locale == "en":
				expect(han.search(str(bg_rec.get("label", ""))) == null, "EN background label has no CJK for " + bg_id)
		var has_seasonal_flag: bool = def_b.get("nodes", []).any(func(n): return bool(n.get("seasonal_street", false)))
		expect(has_seasonal_flag, "seasonal_street flag authored on Scene B5 nodes in " + locale)

	# 2) Verify English runtime surgery runner + Section 4 lines have zero CJK residue
	expect(app.content.load_all("en"), "load en for runtime surgery test")
	app.configure_game_content()
	app.game.prepare_character_event_test_save(PART_A)
	var en_prep = ShioriLv3.start_or_reset_story_surgery(app.game)
	app.show_preop(str(en_prep.definition.id))
	expect(app.screen == "preop", "English story surgery opens on preop screen")
	var en_feedback: Array[String] = []
	drive_story_surgery_to_completion(true, en_feedback)
	expect(en_feedback.size() >= 11, "English story surgery emitted custom Section 4 feedback lines")
	var en_crisis_line := ShioriLv3.crisis_resolution_append_line(en_prep)
	expect(not en_crisis_line.is_empty() and han.search(en_crisis_line) == null, "English crisis comfort line #13 has no CJK")

	# 3) Reload zh_CN for unified Lv3 gate, Part A live surgery + abort retry + settlement, Part B Lv3 rank-up, Gallery Replay, and BoundarySave v37
	expect(app.content.load_all("zh_CN"), "reload zh_CN")
	app.configure_game_content()
	var def_a_zh: Dictionary = app.game.character_event_definitions[PART_A]
	var def_b_zh: Dictionary = app.game.character_event_definitions[PART_B]

	app.game.reset()
	expect(not app.game.character_event_available(def_a_zh), "Part A locked on fresh save")
	expect(not app.game.character_event_available(def_b_zh), "Part B locked on fresh save")

	# Prepare exact Part A test save and verify every gate condition individually
	expect(app.game.prepare_character_event_test_save(PART_A), "prepare_character_event_test_save(PART_A)")
	app.game.clear_test_save_target()
	# Ensure nurse_yoneda_shiori starts unmet to verify temporary circulating-nurse non-pollution
	app.game.relation_for("nurse_yoneda_shiori").met = false
	expect(not app.game.staff_is_met("nurse_yoneda_shiori"), "nurse_yoneda_shiori starts unmet")

	var start_day_a: int = app.game.day_number()
	app.game.advance_story_to_day(start_day_a, 975) # 16:15 inside 15:00..17:00 window
	var rel_shiori: Dictionary = app.game.relation_for("doc_shiori")
	expect(app.game.character_event_available(def_a_zh), "Part A available when all Lv3 gates met")

	# Gate boundary checks: familiarity, skill, charm, 28-day gap, morning window
	rel_shiori.familiarity = 39
	expect(not app.game.character_event_available(def_a_zh), "Part A blocked at familiarity=39")
	rel_shiori.familiarity = 40

	app.game.set_test_player_attribute("skill", 64)
	expect(not app.game.character_event_available(def_a_zh), "Part A blocked at skill=64")
	app.game.set_test_player_attribute("skill", 65)

	app.game.set_test_player_attribute("charm", 29)
	expect(not app.game.character_event_available(def_a_zh), "Part A blocked at charm=29")
	app.game.set_test_player_attribute("charm", 30)

	var orig_lv2_day: int = int(app.game.character_events[LV2].completed_day)
	app.game.character_events[LV2].completed_day = start_day_a - 27
	expect(not app.game.character_event_available(def_a_zh), "Part A blocked when Lv2 gap is 27 days (< 28)")
	app.game.character_events[LV2].completed_day = start_day_a - 2
	expect(not app.game.character_event_available(def_a_zh), "Part A blocked by 3-day milestone cooldown")
	app.game.character_events[LV2].completed_day = orig_lv2_day
	expect(app.game.character_event_available(def_a_zh), "Part A restored to eligible")

	# Offered at clinic at 16:15, not offered at 14:30 (before 15:00 window)
	app.game.story_time_advance_minutes -= 105 # 975 -> 870 (14:30)
	expect(app.game.current_absolute_clock() == 870, "clock set to 14:30 (870)")
	var clinic_early: Array = app.game.character_events_at("clinic")
	expect(not clinic_early.any(func(d): return str(d.get("id", "")) == PART_A), "Part A not offered at clinic at 14:30")
	app.game.advance_story_to_day(start_day_a, 975) # 16:15
	var clinic_due: Array = app.game.character_events_at("clinic")
	expect(clinic_due.any(func(d): return str(d.get("id", "")) == PART_A), "Part A offered at clinic at 16:15")

	# 4) Play Part A via app.choose_character_event -> handoff at slv3a_174 -> abort retry -> complete surgery -> resume slv3a_175..206
	var session_a = app.game.start_character_event(PART_A)
	expect(session_a != null, "start Part A")
	app.character_event_return_location = "clinic"
	app.reset_dialogue_page()
	app.show_character_event()
	expect(not app.game.can_save_progress(), "saving locked during Part A")

	var guard_a := 0
	var verified_cg1_reveal := false
	var verified_cg2_reveal := false
	while app.screen == "character_event" and guard_a < 220:
		guard_a += 1
		var cur_a: Dictionary = session_a.current()
		var cur_id_a := str(cur_a.get("id", ""))
		if cur_id_a == "slv3a_108":
			var cg_node_1 := app.page.get_node_or_null("CharacterEventCG") as TextureRect
			var dlg_box_1 := app.page.get_node_or_null("CharacterEventDialogueBox") as Control
			expect(cg_node_1 != null and cg_node_1.texture != null and cg_node_1.texture.get_width() == 1536 and cg_node_1.texture.get_height() == 1024, "Scene A4 CG1 loaded at 1536x1024")
			expect(dlg_box_1 != null and not dlg_box_1.visible, "Scene A4 CG1 hides dialogue box for initial 1s reveal")
			await create_timer(1.08).timeout
			expect(dlg_box_1 != null and dlg_box_1.visible, "Scene A4 CG1 reveals dialogue box after 1s")
			verified_cg1_reveal = true
		elif cur_id_a == "slv3a_109":
			var dlg_box_1_cont := app.page.get_node_or_null("CharacterEventDialogueBox") as Control
			expect(dlg_box_1_cont != null and dlg_box_1_cont.visible, "Scene A4 CG1 continuation beat does not re-hide dialogue")
		elif cur_id_a == "slv3a_132":
			var cg_node_2 := app.page.get_node_or_null("CharacterEventCG") as TextureRect
			var dlg_box_2 := app.page.get_node_or_null("CharacterEventDialogueBox") as Control
			expect(cg_node_2 != null and cg_node_2.texture != null and cg_node_2.texture.get_width() == 1536 and cg_node_2.texture.get_height() == 1024, "Scene A5 CG2 loaded at 1536x1024")
			expect(dlg_box_2 != null and not dlg_box_2.visible, "Scene A5 CG2 hides dialogue box for initial 1s reveal")
			await create_timer(1.08).timeout
			expect(dlg_box_2 != null and dlg_box_2.visible, "Scene A5 CG2 reveals dialogue box after 1s")
			verified_cg2_reveal = true
		elif cur_id_a == "slv3a_133":
			var dlg_box_2_cont := app.page.get_node_or_null("CharacterEventDialogueBox") as Control
			expect(dlg_box_2_cont != null and dlg_box_2_cont.visible, "Scene A5 CG2 continuation beat does not re-hide dialogue")
		var chs_a: Array = cur_a.get("choices", [])
		app.choose_character_event(str(chs_a[0].get("id", "")))
	expect(verified_cg1_reveal and verified_cg2_reveal, "verified both 1536x1024 OR CG 1s reveals during Part A")

	expect(app.screen == "preop" and app.game.active_preop_id == ShioriLv3.STORY_PREOP_ID, "slv3a_174 launched live surgery_appendix Runner")
	expect(str(session_a.current().get("id", "")) == "slv3a_174", "Part A paused cleanly at slv3a_174 during surgery")
	expect(not app.game.can_save_progress(), "saving remains strictly locked during Yuko's story surgery")
	expect(app.game.sweep_active_surgery("surgery_appendix").is_empty(), "Quick Surgery (sweep) blocked during Yuko's story surgery")

	var prep_zh = app.game.preops.get(ShioriLv3.STORY_PREOP_ID)
	expect(str(prep_zh.team.get("assistant_surgeon", "")) == "doc_shiori", "assistant locked to doc_shiori")
	expect(str(prep_zh.team.get("scrub_nurse", "")) == "nurse_hiroko", "scrub nurse locked to nurse_hiroko")
	expect(str(prep_zh.team.get("circulating_nurse", "")) == "nurse_yoneda_shiori", "circulating nurse locked to nurse_yoneda_shiori")
	expect(str(prep_zh.anesthesia) == "腰麻" and prep_zh.flags.has("spinal_anesthesia"), "locked to spinal anesthesia")

	# Verify abort -> story retry recovery without losing Part A or polluting world state
	prep_zh.stage_id = "surgery_abort"
	prep_zh.surgery_aborted = true
	app.show_preop(ShioriLv3.STORY_PREOP_ID)
	var retry_btn: Button = app.page.get_node_or_null("SurgeryAbortReturn")
	expect(retry_btn != null and retry_btn.text.contains("重新进行本台手术"), "abort screen renders story retry button")
	if retry_btn != null:
		retry_btn.pressed.emit()
	prep_zh = app.game.preops.get(ShioriLv3.STORY_PREOP_ID)
	expect(prep_zh != null and not prep_zh.surgery_aborted and prep_zh.procedure_step_index == 0, "story retry cleanly reset Yuko's appendectomy to step 0")

	# Drive all 9 steps of Yuko's appendectomy and verify all Section 4 lines
	var zh_feedback: Array[String] = []
	drive_story_surgery_to_completion(false, zh_feedback)
	var joined_fb := "\n".join(zh_feedback)
	for must_contain in [
		"已经划开了吗？真的完全不疼诶",
		"皮下小出血点我已经用纱布按住显露清楚了",
		"腹外斜肌腱膜已经顺纤维分开了",
		"刚才肚子里面是不是被什么东西往两边撑了一下",
		"朝日奈小姐别紧张，那是拉钩牵开组织时的正常牵拉感",
		"顺着结肠带往下看——找到了",
		"比看恐怖片还要超现实啊",
		"弯血管钳和丝线递到您手上了",
		"系膜血管结扎得很牢，没有渗血",
		"那颗害我疼了好几次的坏石头，是不是已经被拿走啦",
		"关腹前清点：纱布、缝针、器械数目核对一致",
		"夕子酱，再坚持最后两分钟，马上就缝完表皮了",
		"别怕，夕子酱，心率稍微快了一点而已",
	]:
		expect(joined_fb.contains(must_contain), "Section 4 verbatim line fired: " + must_contain)

	var completed_before_settle: int = app.game.completed_surgeries_total
	var leadership_before_settle: float = app.game.leadership_xp
	var rep_before_settle: int = int(app.game.player_attributes().get("reputation", 0))
	var settle_btn: Button = app.page.get_node_or_null("SurgeryResultReturn")
	expect(settle_btn != null, "SurgeryResultReturn button rendered")
	if settle_btn != null:
		settle_btn.pressed.emit()
	var growth_btn: Button = app.page.get_node_or_null("SurgeryGrowthSplash/SurgeryGrowthContinue")
	if growth_btn == null:
		growth_btn = app.page.find_child("SurgeryGrowthContinue", true, false) as Button
	expect(growth_btn != null, "SurgeryGrowthContinue splash rendered")
	if growth_btn != null:
		growth_btn.pressed.emit()

	expect(app.game.completed_surgeries_total == completed_before_settle + 1 and int(app.game.completed_surgeries_by_procedure.get("surgery_appendix", 0)) >= 1, "completed surgery count settled from Yuko's appendectomy")
	expect(app.game.leadership_xp > leadership_before_settle and int(app.game.player_attributes().get("reputation", 0)) > rep_before_settle, "leadership XP and reputation settled from Yuko's appendectomy")
	expect(not app.game.preops.has(ShioriLv3.STORY_PREOP_ID), "transient story preop erased upon settlement")
	expect(not app.game.staff_is_met("nurse_yoneda_shiori"), "unmet nurse_yoneda_shiori remained unmet after temporary circulating duty")
	expect(app.screen == "character_event" and str(session_a.current().get("id", "")) == "slv3a_175", "resumed seamlessly onto slv3a_175 (Scene A6 post-op)")

	# Finish remaining Part A beats (slv3a_175..206)
	guard_a = 0
	while not session_a.completed and guard_a < 60:
		guard_a += 1
		var cur_post: Dictionary = session_a.current()
		app.choose_character_event(str(cur_post.get("choices", [])[0].get("id", "")))

	expect(session_a.completed, "Part A completed")
	expect(app.game.day_number() == start_day_a + 1 and app.game.current_absolute_clock() == 960, "Part A settled to Day+1 16:00 (960)")
	expect(app.screen == "day_transition", "Part A displayed day_transition")
	var dt_a: Button = app.page.get_node_or_null("DayTransitionContinue")
	expect(dt_a != null, "Part A DayTransitionContinue button present")
	if dt_a != null:
		dt_a.pressed.emit()
	var done_btn_a: Button = app.page.find_child("*医院导览*", true, false) as Button
	if app.screen == "character_event_complete":
		app.game.finish_character_event()
		app.show_map()
	expect(app.game.can_save_progress(), "safe boundary restored after Part A")
	expect(app.game.story_flag("shiori_lv3_part_a_completed"), "shiori_lv3_part_a_completed flag set")
	expect(int(app.game.relation_for("doc_shiori").get("level", 0)) == 2, "Shiori stays at Relationship Lv2 after Part A")

	# 5) Part B gate & full UI walkthrough -> atomic Lv2 -> Lv3 promotion
	var part_a_done_day: int = int(app.game.character_events[PART_A].completed_day)
	app.game.advance_story_to_day(part_a_done_day + 5, 975)
	expect(not app.game.character_event_available(def_b_zh), "Part B blocked 5 days after Part A (< 6 days)")

	var start_day_b: int = part_a_done_day + 6
	while app.game.is_hospital_closed_day(start_day_b) or app.game.is_hospital_closed_day(start_day_b + 2):
		start_day_b += 1
	app.game.advance_story_to_day(start_day_b, 930) # 15:30 before 16:00 Part B window
	expect(not app.game.character_events_at("clinic").any(func(d): return str(d.get("id", "")) == PART_B), "Part B not offered at clinic at 15:30")
	app.game.advance_story_to_day(start_day_b, 975) # 16:15 inside 16:00..17:00 window
	expect(app.game.character_event_available(def_b_zh), "Part B eligible on post-op suture-removal day")
	expect(app.game.character_events_at("clinic").any(func(d): return str(d.get("id", "")) == PART_B), "Part B offered at clinic at 16:15")

	var session_b = app.game.start_character_event(PART_B)
	expect(session_b != null, "start Part B")
	app.character_event_return_location = "clinic"
	app.reset_dialogue_page()
	app.show_character_event()
	expect(not app.game.can_save_progress(), "saving locked during Part B")

	var saw_resolved_street := false
	var guard_b := 0
	while not session_b.completed and guard_b <= PART_B_NODES + 6:
		guard_b += 1
		var cur_b: Dictionary = session_b.current()
		if bool(cur_b.get("seasonal_street", false)):
			saw_resolved_street = app.screen == "character_event"
		var chs_b: Array = cur_b.get("choices", [])
		app.choose_character_event(str(chs_b[0].get("id", "")))

	expect(saw_resolved_street, "Scene B5 seasonal_street rendered cleanly in CharacterStage")
	expect(session_b.completed, "Part B completed")
	expect(app.game.day_number() == start_day_b + 3 and app.game.current_absolute_clock() == 540, "Part B settled to Day+3 09:00 (540)")
	expect(app.screen == "day_transition", "Part B displayed day_transition")
	var dt_b: Button = app.page.get_node_or_null("DayTransitionContinue")
	if dt_b != null:
		dt_b.pressed.emit()
	if app.screen == "character_event_complete":
		app.game.finish_character_event()
		app.show_map()

	expect(app.game.can_save_progress(), "saving unlocked at safe boundary after Part B")
	expect(int(app.game.relation_for("doc_shiori").get("level", 0)) == 3, "Shiori promoted atomically to Relationship Lv3 at Part B completion")
	expect(app.game.relation_for("doc_shiori").get("rank_history", []).has(PART_B), "rank_history records shiori_lv3_part_b_dinner_walk")
	expect(app.game.story_flag("shiori_lv3_complete") and app.game.story_flag("shiori_lv3_dinner_walk_completed"), "Part B completion flags set")
	expect(app.game.relationship_level("doc_shiori") >= 3, "satisfies ayako_return.gd Shiori Lv3 prerequisite")

	# 6) Gallery Entry & Replay check for Part A (slv3a_174 -> slv3a_175 without launching surgery) & Part B
	app.show_gallery_entry(PART_A)
	var gal_cg := app.page.get_node_or_null("GalleryCG") as TextureRect
	expect(gal_cg != null and gal_cg.texture != null and gal_cg.texture.resource_path.ends_with("yuko_spinal_lateral.png"), "Part A Gallery Entry displays yuko_spinal_lateral.png")
	app.replay_gallery_entry(PART_A)
	expect(app.screen == "gallery_replay" and app.gallery_replay_event != null, "Gallery Replay starts for Part A")
	var guard_gal := 0
	while app.gallery_replay_event != null and not app.gallery_replay_event.completed and guard_gal <= PART_A_NODES + 6:
		guard_gal += 1
		var gnode: Dictionary = app.gallery_replay_event.current()
		app.choose_gallery_replay(str(gnode.get("choices", [])[0].get("id", "")))
	expect(app.screen != "preop" and app.game.active_preop_id.is_empty(), "Part A Gallery Replay stepped across slv3a_174 without forcing surgery")

	app.replay_gallery_entry(PART_B)
	expect(app.screen == "gallery_replay" and app.gallery_replay_event != null, "Gallery Replay starts for Part B")
	app.show_map()
	expect(app.game.can_save_progress(), "back on safe map boundary after Gallery Replay")

	# 7) BoundarySave v37 round-trip verification
	var snap: Dictionary = app.game.snapshot()
	expect(snap.get("save_format") == Codec.FORMAT and int(snap.get("version", 0)) == Codec.VERSION, "BoundarySave v37 format")
	inspect_clean(snap)
	var snap_json := JSON.stringify(snap)
	expect(not snap_json.contains("slv3a_") and not snap_json.contains("slv3b_"), "zero slv3a_/slv3b_ internal node IDs in BoundarySave payload")
	expect(not snap_json.contains(ShioriLv3.STORY_PREOP_ID), "zero transient story preop IDs in BoundarySave payload")

	var settled_elapsed: int = app.game.elapsed()
	var settled_xp: int = app.game.surgery_xp
	var settled_aff: int = int(app.game.relation_for("doc_shiori").get("affection", 0))
	var settled_fam: int = int(app.game.relation_for("doc_shiori").get("familiarity", 0))

	app.game.reset()
	expect(int(app.game.relation_for("doc_shiori").get("level", -1)) == 0, "reset cleared in-memory Shiori level")
	expect(app.game.restore(snap), "BoundarySave v37 restore succeeds: " + app.game.last_error)
	expect(app.game.elapsed() == settled_elapsed and app.game.day_number() == start_day_b + 3 and app.game.current_absolute_clock() == 540, "settled Day+3 09:00 preserved across restore")
	expect(app.game.surgery_xp == settled_xp, "surgery XP preserved without duplicate grant")
	expect(int(app.game.relation_for("doc_shiori").get("level", 0)) == 3, "Shiori Lv3 preserved across restore")
	expect(int(app.game.relation_for("doc_shiori").get("affection", 0)) == settled_aff, "affection preserved without duplicate grant")
	expect(int(app.game.relation_for("doc_shiori").get("familiarity", 0)) == settled_fam, "familiarity preserved without duplicate grant")
	expect(app.game.character_event_done(PART_A) and app.game.character_event_done(PART_B), "completed facts for Part A and Part B preserved")
	expect(not app.game.character_event_available(def_a_zh) and not app.game.character_event_available(def_b_zh), "neither Part A nor Part B re-triggers after restore")

	if FileAccess.file_exists(tmp_save_path):
		DirAccess.remove_absolute(tmp_save_path)

	print("SHIORI LV3 TEST: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
