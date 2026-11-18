extends SceneTree
## Runtime regression test for Asuka Shiromiya (`doc_asuka`) Relationship Lv1:
## 《院长也是外科医生》 (The Director Is Also a Surgeon)
## - Scene 1 (`asuka_lv1_director_surgeon_preop`): 12-beat pre-op VN at `scrub_area`
## - Scene 2 (Routine Surgery Runner): 100% crisis suppression + 3 custom first-assistant lines
## - Scene 3 (`asuka_lv1_director_surgeon_postop`): 28-beat post-op VN at `or_entrance` (Lv0 -> Lv1)
## - Sweep ("一键扫荡") blocking while eligible/active, abort rollback, Saturday overtime post-op,
##   bilingual `zh_CN` + `en` zero-CJK checks, and BoundarySave v37 round-trip verification.

const PREOP_EVENT := "asuka_lv1_director_surgeon_preop"
const POSTOP_EVENT := "asuka_lv1_director_surgeon_postop"
const INTRO_OFFICE := "intro_doc_asuka_director_office"
const PREOP_NODES := 12
const POSTOP_NODES := 28
const CLINIC_ROUTE := [
	"greet", "basic_history", "to_exam", "vitals", "limited_clothed_exam",
	"blood", "imaging", "to_diagnosis", "diagnose_appendix", "explain", "admit",
]
const EXPECTED_PORTRAITS := [
	"assets/characters/asuka_lv1_v1/doc_asuka/scrubs/masked_bright.png",
	"assets/characters/asuka_lv1_v1/doc_asuka/scrubs/masked_smile.png",
	"assets/characters/asuka_lv1_v1/doc_asuka/scrubs/cap_smile.png",
	"assets/characters/asuka_lv1_v1/doc_asuka/scrubs/cap_critique.png",
	"assets/characters/asuka_lv1_v1/doc_asuka/scrubs/cap_shy.png",
	"assets/characters/asuka_lv1_v1/doc_asuka/scrubs/hair_down_smile.png",
	"assets/characters/asuka_lv1_v1/doc_asuka/scrubs/hair_down_wave.png",
]

const EventSession = preload("res://godot/systems/character_event_session.gd")
const AsukaLv1 = preload("res://godot/systems/asuka_lv1.gd")
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
					"case_variant_id", "diagnosis_action_order", "active_special_event",
					"active_adult_intimacy", "asuka_lv1_active", "asuka_lv1_postop_opportunity",
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
		seen_bgs[str(node.get("background_id", definition.get("background_id", "")))] = true

		var eps: Array = node.get("event_portraits", [])
		if bool(node.get("hide_portrait", false)):
			expect(eps.is_empty(), "hidden-portrait beat has empty event_portraits on " + node_id)
		else:
			expect(eps.size() == 1, "visible beat has single event_portrait on " + node_id)
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

func dismiss_any_overlay_screens() -> void:
	var guard := 0
	while guard < 12:
		guard += 1
		if app.screen == "preop_transition_video":
			app.complete_preop_transition_video()
		elif app.screen == "surgery_video":
			app.complete_surgery_video()
		elif app.screen == "staff_role_reward":
			app.continue_staff_role_reward()
		elif app.screen == "anesthesia_splash":
			var b1: Button = app.page.find_child("AnesthesiaSplashContinue", true, false) as Button
			if b1 != null:
				b1.pressed.emit()
			else:
				app.show_preop(app.game.active_preop_id)
		elif app.screen == "ward_preparation_cg":
			var b2: Button = app.page.find_child("WardPreparationCGContinue", true, false) as Button
			if b2 != null:
				b2.pressed.emit()
			else:
				app.show_preop(app.game.active_preop_id)
		elif app.screen == "surgery_cg":
			var b3: Button = app.page.find_child("SurgeryCGContinue", true, false) as Button
			if b3 != null:
				b3.pressed.emit()
			else:
				app.show_preop(app.game.active_preop_id)
		else:
			break

func setup_admitted_asuka_preop(day: int, clock_min: int) -> String:
	app.game.reset()
	app.game.patient_cases = app.game.legacy_patient_cases()
	app.game.rebuild_patient_content(app.game.patient_cases)
	for surgery in app.content.collections.surgeries:
		if str(surgery.get("status", "ready")) != "placeholder":
			app.game.unlock_procedure(str(surgery.id))
	for person_id in ["doc_aoi", "doc_asuka", "nurse_haru", "nurse_rin", "nurse_yui", "nurse_moe"]:
		app.game.meet_staff(person_id)
	for prior_id in ["moe_wrong_changing_room", "asuka_scrub_sink_encounter", "asuka_adjacent_operation_reveal"]:
		app.game._complete_character_event_for_test(prior_id, 1)
	app.game._complete_character_event_for_test(INTRO_OFFICE, 2)
	var rel: Dictionary = app.game.relation_for("doc_asuka")
	rel.met = true
	rel.level = 0
	rel.familiarity = 10
	app.game.set_test_player_attribute("charm", 10)
	# Admit outpatient during morning clinic hours first, then advance to target surgery clock.
	var admit_clock := mini(clock_min, 555)
	app.game.advance_story_to_day(day, admit_clock)
	var visit = app.game.open_visit("visit_sora")
	expect(visit != null, "opened visit_sora")
	for action in CLINIC_ROUTE:
		expect(visit.apply(action), "clinic action " + action)
	if clock_min > app.game.current_absolute_clock():
		app.game.advance_story_to_day(day, clock_min)
	var preop_id := "preop_sora"
	var prep = app.game.open_preop(preop_id)
	expect(prep != null, "opened preop_sora")
	return preop_id

func prepare_to_preparation_stage(prep: RefCounted, assistant_id: String = "doc_asuka") -> void:
	expect(prep.apply({"kind": "action", "id": "brief_plan"}), "brief_plan")
	expect(prep.apply({"kind": "assign", "role": "assistant_surgeon", "staff_id": assistant_id}), "assign assistant " + assistant_id)
	expect(prep.apply({"kind": "assign", "role": "scrub_nurse", "staff_id": "nurse_haru"}), "assign scrub nurse_haru")
	expect(prep.apply({"kind": "assign", "role": "circulating_nurse", "staff_id": "nurse_rin"}), "assign circulating nurse_rin")
	expect(prep.apply({"kind": "action", "id": "confirm_team"}), "confirm_team")
	expect(prep.apply({"kind": "assign", "role": "ward_nurse", "staff_id": "nurse_yui"}), "assign ward_nurse nurse_yui")

func complete_ward_prep_to_changing(prep: RefCounted) -> void:
	expect(prep.apply({"kind": "action", "id": "perform_preparation"}), "perform_preparation")
	expect(prep.apply({"kind": "action", "id": "to_changing"}), "to_changing")

func drive_preop_from_changing_to_surgery_complete(preop_id: String, expect_english: bool, observed_feedback: Array[String]) -> void:
	var prep = app.game.preops.get(preop_id)
	expect(prep != null, "preop exists for OR execution")
	if prep == null:
		return
	var surgery_id := str(prep.definition.surgery_id)
	app.game.set_intraoperative_crisis_enabled(true)

	var guard := 0
	while not prep.surgery_success and guard < 120:
		guard += 1
		dismiss_any_overlay_screens()
		var fb := str(prep.feedback)
		if not fb.is_empty() and not observed_feedback.has(fb):
			observed_feedback.append(fb)
			if expect_english:
				expect(han.search(fb) == null, "English surgery feedback has no CJK: " + fb)
		expect(prep.active_crisis.is_empty(), "crisis strictly suppressed throughout Asuka Lv1 surgery")

		var cur: Dictionary = prep.current()
		var kind := str(cur.get("kind", ""))
		if prep.assistant_anesthesia_pending:
			app.preop_event({"kind": "assistant_anesthesia_ack"})
		elif kind == "surgery_select":
			app.preop_event({"kind": "procedure", "id": surgery_id})
		elif kind == "or_table_palpation":
			app.preop_event({"kind": "or_table_palpation_complete"})
		elif kind == "anesthesia_sensory_test":
			app.preop_event({"kind": "anesthesia_sensory_test_complete"})
		elif kind == "surgery_execute":
			app.preop_event({"kind": "action", "id": "execute_confirmed_procedure"})
		elif kind == "surgery_flow":
			if prep.awaiting_patient_choice:
				var p_actions: Array = prep.active_patient_interaction.get("actions", [])
				app.preop_event({"kind": "patient_interaction_action", "id": str(p_actions[0].id)})
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
				# Pass crisis_roll = 0 so crisis WOULD fire 100% if not suppressed by AsukaLv1!
				app.preop_event({"kind": "surgery_step", "id": picked_id, "crisis_roll": 0})
		else:
			var actions: Array = cur.get("actions", [])
			var pick_action := ""
			for preferred in [
				"enter_room", "team_check", "confirm_assistant_role", "confirm_scrub_role",
				"confirm_circulating_role", "choose_general", "induction_reassure",
				"operative_positioning", "ack_positioning", "urinary_catheterization",
				"ack_catheterization", "skin_disinfection", "ack_disinfection",
				"incision_marking", "ack_marking_general", "start_general_surgery",
				"request_scalpel", "assistant_stabilize", "incise_general",
			]:
				if actions.any(func(a): return str(a.get("id", "")) == preferred and prep.action_visible(a) and not prep.done.has(a.id) and prep.action_reason(a).is_empty()):
					pick_action = preferred
					break
			if pick_action.is_empty() and not actions.is_empty():
				for a in actions:
					if prep.action_visible(a) and not prep.done.has(a.id) and prep.action_reason(a).is_empty():
						pick_action = str(a.get("id", ""))
						break
			expect(not pick_action.is_empty(), "found valid action on stage " + str(prep.stage_id))
			if pick_action.is_empty():
				break
			app.preop_event({"kind": "action", "id": pick_action})

	dismiss_any_overlay_screens()
	var final_fb := str(prep.feedback)
	if not final_fb.is_empty() and not observed_feedback.has(final_fb):
		observed_feedback.append(final_fb)
	expect(prep.surgery_success and str(prep.current().get("kind", "")) == "surgery_complete", "routine surgery reached surgery_complete")

func run() -> void:
	var tmp_save_path := "/private/tmp/asuka_lv1_unused_%s.json" % OS.get_process_id()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = tmp_save_path
	root.add_child(app)
	await process_frame

	# 1) Verify all 7 RGBA portrait textures + bilingual traversal of Scene 1 (12 beats) & Scene 3 (28 beats)
	for p in EXPECTED_PORTRAITS:
		var tex := load("res://" + p) as Texture2D
		expect(tex != null, "loaded texture res://" + p)
		if tex != null:
			var img := tex.get_image()
			expect(tex.get_width() == 1024 and tex.get_height() == 1536, "1024x1536 dimensions for " + p)
			expect(img != null and img.detect_alpha() != Image.ALPHA_NONE, "transparent alpha channel present on " + p)

	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "content loads " + locale)
		app.configure_game_content()
		var def_pre: Dictionary = app.game.character_event_definitions.get(PREOP_EVENT, {})
		var def_post: Dictionary = app.game.character_event_definitions.get(POSTOP_EVENT, {})
		expect(not def_pre.is_empty() and def_pre.get("nodes", []).size() == PREOP_NODES, "registered 12-beat preop event in " + locale)
		expect(not def_post.is_empty() and def_post.get("nodes", []).size() == POSTOP_NODES, "registered 28-beat postop event in " + locale)

		var seen_portraits := {}
		var seen_bgs := {}
		var seen_pre := {}
		var seen_post := {}
		traverse_branch_index(def_pre, PREOP_NODES, 0, locale, 0, seen_portraits, seen_bgs, seen_pre)
		traverse_branch_index(def_post, POSTOP_NODES, 0, locale, 0, seen_portraits, seen_bgs, seen_post)
		expect(seen_pre.size() == PREOP_NODES, "Scene 1 covers all 12 nodes in " + locale)
		expect(seen_post.size() == POSTOP_NODES, "Scene 3 covers all 28 nodes in " + locale)
		expect(seen_portraits.size() == 7, "all 7 new scrubs portraits exercised across Scene 1 + Scene 3 in " + locale)
		for p in EXPECTED_PORTRAITS:
			expect(seen_portraits.has(p), "exercised portrait " + p + " in " + locale)

		for bg_id in ["scrub_area", "or_entrance"]:
			expect(seen_bgs.has(bg_id), "exercised background " + bg_id + " in " + locale)
			var bg_rec: Dictionary = app.content.find_record("backgrounds", bg_id)
			expect(not bg_rec.is_empty() and ResourceLoader.exists("res://" + str(bg_rec.get("path", ""))), "background loads for " + bg_id)
			if locale == "en":
				expect(han.search(str(bg_rec.get("label", ""))) == null, "EN background label has no CJK for " + bg_id)
				expect(han.search(str(def_pre.get("title", ""))) == null and han.search(str(def_pre.get("teaser", ""))) == null, "EN preop title/teaser has no CJK")
				expect(han.search(str(def_post.get("title", ""))) == null and han.search(str(def_post.get("teaser", ""))) == null, "EN postop title/teaser has no CJK")

	expect(han.search(AsukaLv1.sweep_block_tooltip(true)) == null, "English sweep tooltip has no CJK")
	for k in AsukaLv1.INTRAOP_LINES:
		expect(han.search(str(AsukaLv1.INTRAOP_LINES[k]["en"])) == null, "English intraop line has no CJK: " + str(k))

	# 2) Verify English runtime sweep block + English intraop custom lines + crisis suppression
	expect(app.content.load_all("en"), "load en for runtime sweep & intraop check")
	app.configure_game_content()
	var en_preop_id := setup_admitted_asuka_preop(4, 570) # Day 4 Morning 09:30
	var en_prep = app.game.preops[en_preop_id]
	var en_surg_id := str(en_prep.definition.surgery_id)
	app.game.completed_surgeries_by_procedure[en_surg_id] = 1
	app.game.surgical_quality_records[en_surg_id] = {"best_score": 95, "quick_surgery_unlocked": true}
	expect(app.game.procedure_sweep_unlocked(en_surg_id), "quick surgery unlocked for " + en_surg_id)

	prepare_to_preparation_stage(en_prep, "doc_asuka")
	app.show_preop(en_preop_id)
	var en_early_sweep := app.page.find_child("ProcedureSweep_" + en_surg_id, true, false) as Button
	expect(en_early_sweep != null and en_early_sweep.disabled, "EN early sweep button disabled when Asuka is first assistant")
	if en_early_sweep != null:
		expect(en_early_sweep.tooltip_text == AsukaLv1.sweep_block_tooltip(true) and han.search(en_early_sweep.tooltip_text) == null, "EN early sweep tooltip localized cleanly")
	expect(app.game.sweep_active_surgery(en_surg_id).is_empty(), "sweep_active_surgery rejected at state layer when Asuka Lv1 will trigger")

	complete_ward_prep_to_changing(en_prep)
	app.show_preop(en_preop_id)
	app.preop_event({"kind": "action", "id": "change_scrubs"})
	dismiss_any_overlay_screens()
	app.preop_event({"kind": "action", "id": "scrub_hands"})
	dismiss_any_overlay_screens()
	expect(app.screen == "character_event" and app.game.active_character_event_id == PREOP_EVENT, "EN Scene 1 auto-started after scrub_hands")
	var en_s1 = app.game.character_events[PREOP_EVENT]
	while not en_s1.completed:
		app.choose_character_event(str(en_s1.current().choices[0].id))
	expect(app.screen == "preop" and AsukaLv1.is_active_on_preop(en_prep), "EN Scene 1 returned seamlessly to preop with active flag")

	var en_feedback: Array[String] = []
	drive_preop_from_changing_to_surgery_complete(en_preop_id, true, en_feedback)
	var en_joined := "\n".join(en_feedback)
	for snippet in [
		"hold the retractor angle steady right here",
		"pressed this oozing point with gauze",
		"incision edges are coming together beautifully",
	]:
		expect(en_joined.contains(snippet), "EN intraop line emitted: " + snippet)

	# 3) Reload zh_CN: Gate matrix, morning vs afternoon eligibility, sweep toggle, test-save generator, abort rollback
	expect(app.content.load_all("zh_CN"), "reload zh_CN")
	app.configure_game_content()
	var def_pre_zh: Dictionary = app.game.character_event_definitions[PREOP_EVENT]
	var def_post_zh: Dictionary = app.game.character_event_definitions[POSTOP_EVENT]

	expect(app.game.prepare_character_event_test_save(PREOP_EVENT), "prepare_character_event_test_save(PREOP_EVENT)")
	expect(app.game.character_event_available(def_pre_zh), "test-save PREOP_EVENT immediately available")
	expect(app.game.prepare_character_event_test_save(POSTOP_EVENT), "prepare_character_event_test_save(POSTOP_EVENT)")
	expect(app.game.character_event_available(def_post_zh), "test-save POSTOP_EVENT immediately available")

	var zh_preop_id := setup_admitted_asuka_preop(4, 570) # Morning 09:30
	var zh_prep = app.game.preops[zh_preop_id]
	var zh_surg_id := str(zh_prep.definition.surgery_id)
	app.game.completed_surgeries_by_procedure[zh_surg_id] = 1
	app.game.surgical_quality_records[zh_surg_id] = {"best_score": 95, "quick_surgery_unlocked": true}
	prepare_to_preparation_stage(zh_prep, "doc_asuka")

	var rel_asuka: Dictionary = app.game.relation_for("doc_asuka")
	expect(app.game.rank_ready("doc_asuka"), "rank_ready('doc_asuka') true when Lv1 gates met")
	expect(app.game.character_event_available(def_pre_zh), "PREOP_EVENT eligible in morning (09:30)")

	app.game.advance_story_to_day(4, 930) # Afternoon 15:30
	expect(app.game.character_event_available(def_pre_zh), "PREOP_EVENT eligible in afternoon (15:30)")

	# Gate checks: familiarity=9, charm=9, intro missing, different assistant_surgeon
	rel_asuka.familiarity = 9
	expect(not app.game.character_event_available(def_pre_zh) and not app.game.rank_ready("doc_asuka"), "blocked at familiarity=9")
	rel_asuka.familiarity = 10

	app.game.set_test_player_attribute("charm", 9)
	expect(not app.game.character_event_available(def_pre_zh) and not app.game.rank_ready("doc_asuka"), "blocked at charm=9")
	app.game.set_test_player_attribute("charm", 10)

	app.game.character_events.erase(INTRO_OFFICE)
	expect(not app.game.character_event_available(def_pre_zh), "blocked before intro_doc_asuka_director_office")
	app.game._complete_character_event_for_test(INTRO_OFFICE, 2)
	expect(app.game.character_event_available(def_pre_zh), "restored after intro_doc_asuka_director_office")

	# Verify ZH preparation-stage sweep button is disabled with localized tooltip when Asuka is assistant
	app.show_preop(zh_preop_id)
	var asuka_sweep_btn := app.page.find_child("ProcedureSweep_" + zh_surg_id, true, false) as Button
	expect(asuka_sweep_btn != null and asuka_sweep_btn.disabled and asuka_sweep_btn.tooltip_text == AsukaLv1.sweep_block_tooltip(false), "ZH preparation sweep button disabled with tooltip")

	# Also verify with a separate doc_aoi team that sweep IS enabled when Asuka is NOT assistant
	zh_prep.team["assistant_surgeon"] = "doc_aoi"
	expect(not app.game.character_event_available(def_pre_zh), "PREOP_EVENT blocked when assistant is doc_aoi")
	expect(not AsukaLv1.blocks_sweep(app.game, zh_prep), "sweep NOT blocked when assistant is doc_aoi")
	app.show_preop(zh_preop_id)
	var aoi_sweep_btn := app.page.find_child("ProcedureSweep_" + zh_surg_id, true, false) as Button
	expect(aoi_sweep_btn != null and not aoi_sweep_btn.disabled, "sweep button enabled when assistant is doc_aoi")
	zh_prep.team["assistant_surgeon"] = "doc_asuka"

	# Advance to changing -> trigger Scene 1 -> enter OR to procedure_select -> verify sweep button there -> abort surgery!
	complete_ward_prep_to_changing(zh_prep)
	app.show_preop(zh_preop_id)
	app.preop_event({"kind": "action", "id": "change_scrubs"})
	dismiss_any_overlay_screens()
	app.preop_event({"kind": "action", "id": "scrub_hands"})
	dismiss_any_overlay_screens()
	expect(app.screen == "character_event" and app.game.active_character_event_id == PREOP_EVENT, "Scene 1 triggered before abort test")
	expect(not app.game.can_save_progress(), "saving locked during Scene 1")
	var abort_s1 = app.game.character_events[PREOP_EVENT]
	while not abort_s1.completed:
		app.choose_character_event(str(abort_s1.current().choices[0].id))
	expect(app.game.character_event_done(PREOP_EVENT) and app.game.relationship_level("doc_asuka") == 0, "Scene 1 done, still Lv0 during surgery")

	for act_id in ["enter_room", "team_check", "confirm_assistant_role", "confirm_scrub_role", "confirm_circulating_role"]:
		app.preop_event({"kind": "action", "id": act_id})
		dismiss_any_overlay_screens()
	expect(str(zh_prep.stage_id) == "procedure_select", "reached procedure_select stage")
	app.show_preop(zh_preop_id)
	var proc_sweep_btn := app.page.find_child("ProcedureSweep_" + zh_surg_id, true, false) as Button
	expect(proc_sweep_btn != null and proc_sweep_btn.disabled and proc_sweep_btn.tooltip_text == AsukaLv1.sweep_block_tooltip(false), "ZH procedure_select sweep button disabled with tooltip")

	# Force surgery abort and return
	zh_prep.stage_id = "surgery_abort"
	zh_prep.surgery_aborted = true
	app.complete_aborted_surgery_return()
	expect(app.screen == "map" and app.game.can_save_progress(), "abort returned to safe map boundary")
	expect(app.game.relationship_level("doc_asuka") == 0, "still Lv0 after aborted surgery")
	expect(not app.game.character_event_done(PREOP_EVENT), "Scene 1 completion rolled back on surgery abort")
	expect(not app.game.character_event_done(POSTOP_EVENT), "Scene 3 did not fire on surgery abort")
	expect(not app.game.asuka_lv1_postop_opportunity, "postop opportunity cleared on surgery abort")

	# Also verify sanitize_after_restore rolls back an orphan PREOP_EVENT on boundary load
	app.game._complete_character_event_for_test(PREOP_EVENT, 4)
	var orphan_snap: Dictionary = app.game.snapshot()
	expect(app.game.restore(orphan_snap), "restore orphan preop boundary snapshot")
	expect(not app.game.character_event_done(PREOP_EVENT), "sanitize_after_restore rolled back orphan PREOP_EVENT")

	# 5) Full end-to-end completion on Saturday afternoon (crossing 17:00 into overtime!) -> Scene 1 + Scene 2 + Scene 3 -> Lv0 -> Lv1
	var sat_day := 6
	while str(app.game.calendar_date(sat_day).weekday_id) != "sat":
		sat_day += 1
	var e2e_preop_id := setup_admitted_asuka_preop(sat_day, 975) # Saturday 16:15
	var e2e_prep = app.game.preops[e2e_preop_id]
	var e2e_surg_id := str(e2e_prep.definition.surgery_id)
	app.game.completed_surgeries_by_procedure[e2e_surg_id] = 1
	app.game.surgical_quality_records[e2e_surg_id] = {"best_score": 95, "quick_surgery_unlocked": true}
	prepare_to_preparation_stage(e2e_prep, "doc_asuka")
	complete_ward_prep_to_changing(e2e_prep)
	app.show_preop(e2e_preop_id)
	app.preop_event({"kind": "action", "id": "change_scrubs"})
	dismiss_any_overlay_screens()
	app.preop_event({"kind": "action", "id": "scrub_hands"})
	dismiss_any_overlay_screens()
	expect(app.screen == "character_event" and app.game.active_character_event_id == PREOP_EVENT, "Saturday afternoon Scene 1 auto-started")

	var s1_session = app.game.character_events[PREOP_EVENT]
	var s1_count := 0
	while not s1_session.completed and s1_count < 20:
		s1_count += 1
		app.choose_character_event(str(s1_session.current().choices[0].id))
	expect(s1_count == PREOP_NODES and app.screen == "preop", "Scene 1 played 12 beats and returned directly to preop")
	expect(not app.game.can_save_progress(), "saving remains locked in preop after Scene 1")

	var zh_feedback: Array[String] = []
	drive_preop_from_changing_to_surgery_complete(e2e_preop_id, false, zh_feedback)
	var zh_joined := "\n".join(zh_feedback)
	for must_have in [
		"拉钩角度我帮你稳在这里，深面的解剖间隙很清楚，放心往下走吧。",
		"这边的渗血点我先用纱布帮你压住了。需要电凝还是结扎，随时开口。",
		"切口对合得很漂亮呢。收尾剪线交给我，今天配合得很顺手哦。",
	]:
		expect(zh_joined.contains(must_have), "ZH verbatim intraop line emitted: " + must_have)

	# Settle routine surgery -> Growth splash -> Scene 3 auto-starts on post_surgery_return (even after crossing 17:00 Saturday!)
	app.finish_surgery_and_return()
	var growth_btn: Button = app.page.find_child("SurgeryGrowthContinue", true, false) as Button
	expect(growth_btn != null, "SurgeryGrowthContinue splash rendered")
	if growth_btn != null:
		growth_btn.pressed.emit()

	expect(app.screen == "character_event" and app.game.active_character_event_id == POSTOP_EVENT, "Scene 3 auto-started on post_surgery_return after Saturday overtime surgery")
	expect(not app.game.can_save_progress(), "saving locked during Scene 3")

	var s3_session = app.game.character_events[POSTOP_EVENT]
	var s3_count := 0
	while not s3_session.completed and s3_count < 40:
		s3_count += 1
		var cur_s3: Dictionary = s3_session.current()
		var chs_s3: Array = cur_s3.get("choices", [])
		app.choose_character_event(str(chs_s3[0].id))
	expect(s3_count == POSTOP_NODES, "Scene 3 traversed all 28 beats to completion")
	expect(app.screen == "character_event_complete", "Scene 3 reached character_event_complete screen")

	var post_continue := app.page.find_child("PostSurgeryEventContinue", true, false) as Button
	expect(post_continue != null, "PostSurgeryEventContinue button rendered")
	if post_continue != null:
		post_continue.pressed.emit()
	if app.screen == "after_work_walk":
		app.game.choose_after_work_walk(false)
		app.complete_after_work_walk()
	if app.screen == "day_transition":
		var dt_btn := app.page.find_child("DayTransitionContinue", true, false) as Button
		if dt_btn != null:
			dt_btn.pressed.emit()

	expect(app.screen in ["map", "sunday_menu"] and app.game.can_save_progress(), "returned to safe map/Sunday boundary after Scene 3")
	expect(app.game.relationship_level("doc_asuka") == 1, "doc_asuka atomically promoted to Relationship Lv1")
	expect(app.game.relation_for("doc_asuka").get("rank_history", []).has(POSTOP_EVENT), "rank_history records asuka_lv1_director_surgeon_postop")
	expect(app.game.relation_for("doc_asuka").get("flags", []).has("asuka_lv1_complete"), "asuka_lv1_complete flag set on relation")
	expect(not app.game.rank_ready("doc_asuka"), "rank_ready('doc_asuka') cleared after Lv1 promotion")

	# Verify sweep is RE-ENABLED on future surgeries with doc_asuka once Lv1 is completed!
	app.game.advance_story_to_day(sat_day + 2, 570) # Monday 09:30
	app.show_map(false)
	var fresh_prep_check = preload("res://godot/systems/preop_session.gd").new(
		app.content.find_record("preops", "preop_sora").duplicate(true),
		app.content.collections.staff,
		app.content.collections.surgeries,
		app.content.collections.patients
	)
	fresh_prep_check.team["assistant_surgeon"] = "doc_asuka"
	expect(not AsukaLv1.blocks_sweep(app.game, fresh_prep_check), "sweep re-enabled on subsequent surgeries after Lv1 completion")

	# 6) Gallery replay check
	app.replay_gallery_entry(PREOP_EVENT)
	expect(app.screen == "gallery_replay" and app.gallery_replay_event != null, "Gallery Replay starts for Scene 1")
	app.replay_gallery_entry(POSTOP_EVENT)
	expect(app.screen == "gallery_replay" and app.gallery_replay_event != null, "Gallery Replay starts for Scene 3")
	app.show_map(false)
	expect(app.game.can_save_progress(), "safe boundary after Gallery Replay")

	# 7) BoundarySave v37 round-trip verification
	var snap: Dictionary = app.game.snapshot()
	expect(snap.get("save_format") == Codec.FORMAT and int(snap.get("version", 0)) == Codec.VERSION, "BoundarySave v37 format")
	inspect_clean(snap)
	var snap_json := JSON.stringify(snap)
	expect(not snap_json.contains("al1a_") and not snap_json.contains("al1b_"), "zero al1a_/al1b_ internal node IDs in BoundarySave payload")
	expect(not snap_json.contains("asuka_lv1_active") and not snap_json.contains("asuka_lv1_postop_opportunity"), "zero transient session flags in BoundarySave payload")

	var settled_elapsed: int = app.game.elapsed()
	var settled_xp: int = app.game.surgery_xp
	var settled_fam: int = int(app.game.relation_for("doc_asuka").get("familiarity", 0))
	var settled_aff: int = int(app.game.relation_for("doc_asuka").get("affection", 0))

	app.game.reset()
	expect(app.game.relationship_level("doc_asuka") == 0, "reset cleared in-memory Asuka level")
	expect(app.game.restore(snap), "BoundarySave v37 restore succeeds: " + app.game.last_error)
	expect(app.game.elapsed() == settled_elapsed, "elapsed minutes preserved across restore")
	expect(app.game.surgery_xp == settled_xp, "surgery XP preserved without duplicate grant")
	expect(app.game.relationship_level("doc_asuka") == 1, "doc_asuka Lv1 preserved across restore")
	expect(int(app.game.relation_for("doc_asuka").get("familiarity", 0)) == settled_fam, "familiarity preserved without duplicate grant")
	expect(int(app.game.relation_for("doc_asuka").get("affection", 0)) == settled_aff, "affection preserved without duplicate grant")
	expect(app.game.character_event_done(PREOP_EVENT) and app.game.character_event_done(POSTOP_EVENT), "completed facts for Scene 1 and Scene 3 preserved")
	expect(not app.game.character_event_available(def_pre_zh) and not app.game.character_event_available(def_post_zh), "neither Scene 1 nor Scene 3 re-triggers after restore")

	if FileAccess.file_exists(tmp_save_path):
		DirAccess.remove_absolute(tmp_save_path)

	print("ASUKA LV1 TEST: %s checks, %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
