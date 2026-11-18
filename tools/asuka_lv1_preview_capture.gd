extends SceneTree
## Native windowed UI playthrough & preview screenshot capture for
## Asuka Shiromiya (`doc_asuka`) Relationship Lv1: 《院长也是外科医生》.
## Exercises pre-op sweep disable, Scene 1 (`scrub_area`), Scene 2 intra-op
## first-assistant lines (`operating_room`), Scene 3 (`or_entrance`), and Lv.1
## completion card across both `zh_CN` and `en` on a live 1280x800 viewport.

const PREOP_EVENT := "asuka_lv1_director_surgeon_preop"
const POSTOP_EVENT := "asuka_lv1_director_surgeon_postop"
const INTRO_OFFICE := "intro_doc_asuka_director_office"
const OUT_DIR := "docs/qa/asuka_lv1_2026-11-13"
const CLINIC_ROUTE := [
	"greet", "basic_history", "to_exam", "vitals", "limited_clothed_exam",
	"blood", "imaging", "to_diagnosis", "diagnose_appendix", "explain", "admit",
]

const ZH_SCENE1_SHOTS := {
	"al1a_003": "02_zh_scene1_masked_smile.png",
	"al1a_010": "03_zh_scene1_masked_bright.png",
}
const ZH_SCENE3_SHOTS := {
	"al1b_006": "06_zh_scene3_cap_smile.png",
	"al1b_010": "07_zh_scene3_cap_critique.png",
	"al1b_019": "08_zh_scene3_cap_shy.png",
	"al1b_023": "09_zh_scene3_hair_down_smile.png",
	"al1b_028": "10_zh_scene3_hair_down_wave.png",
}
const EN_SCENE1_SHOTS := {
	"al1a_010": "13_en_scene1_masked_bright.png",
}
const EN_SCENE3_SHOTS := {
	"al1b_010": "15_en_scene3_cap_critique.png",
	"al1b_019": "16_en_scene3_cap_shy.png",
	"al1b_028": "17_en_scene3_hair_down_wave.png",
}

var app
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func save_shot(filename: String) -> void:
	for child in app.page.get_children():
		if child is CanvasItem and str(child.name) != "EventStageEffect":
			child.show()
	await process_frame
	await RenderingServer.frame_post_draw
	var out_path := ProjectSettings.globalize_path("res://%s/%s" % [OUT_DIR, filename])
	var err: int = app.get_viewport().get_texture().get_image().save_png(out_path)
	expect(err == OK, "Saved screenshot " + out_path)

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

func play_character_event_and_capture(event_id: String, shot_map: Dictionary, locale: String) -> void:
	var ev = app.game.character_events.get(event_id)
	expect(ev != null, "active character event " + event_id + " in " + locale)
	if ev == null:
		return
	var guard := 0
	while not ev.completed and guard < 60:
		guard += 1
		var node: Dictionary = ev.current()
		var nid := str(node.get("id", ""))
		var pages: Array = app.authored_dialogue_pages(str(node.get("text", "")))
		for p_idx in range(maxi(1, pages.size())):
			app.dialogue_page_index = p_idx
			app.show_character_event()
			await process_frame
			var body := app.page.get_node_or_null("CharacterEventDialogue") as RichTextLabel
			if body != null:
				expect(body.get_content_height() <= body.size.y + 4, "%s zero text overflow at %s p%d (h=%s / %s)" % [locale, nid, p_idx, body.get_content_height(), body.size.y])
			if p_idx == 0 and shot_map.has(nid):
				await save_shot(str(shot_map[nid]))
		var chs: Array = node.get("choices", [])
		app.choose_character_event(str(chs[0].id))
		await process_frame

func run_locale_flow(
	locale: String,
	sweep_shot: String,
	s1_shots: Dictionary,
	intraop_1_shot: String,
	intraop_3_shot: String,
	s3_shots: Dictionary,
	complete_shot: String
) -> void:
	expect(app.content.load_all(locale), "Load content " + locale)
	app.configure_game_content()
	app.dialogue_auto_enabled = false

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
	app.game.advance_story_to_day(4, 570)

	var visit = app.game.open_visit("visit_sora")
	for action in CLINIC_ROUTE:
		visit.apply(action)
	var preop_id := "preop_sora"
	var prep = app.game.open_preop(preop_id)
	var surg_id := str(prep.definition.surgery_id)
	app.game.completed_surgeries_by_procedure[surg_id] = 1
	app.game.surgical_quality_records[surg_id] = {"best_score": 95, "quick_surgery_unlocked": true}

	prep.apply({"kind": "action", "id": "brief_plan"})
	prep.apply({"kind": "assign", "role": "assistant_surgeon", "staff_id": "doc_asuka"})
	prep.apply({"kind": "assign", "role": "scrub_nurse", "staff_id": "nurse_haru"})
	prep.apply({"kind": "assign", "role": "circulating_nurse", "staff_id": "nurse_rin"})
	prep.apply({"kind": "action", "id": "confirm_team"})
	prep.apply({"kind": "assign", "role": "ward_nurse", "staff_id": "nurse_yui"})

	app.show_preop(preop_id)
	await process_frame
	await save_shot(sweep_shot)

	prep.apply({"kind": "action", "id": "perform_preparation"})
	prep.apply({"kind": "action", "id": "to_changing"})
	app.show_preop(preop_id)
	app.preop_event({"kind": "action", "id": "change_scrubs"})
	dismiss_any_overlay_screens()
	app.preop_event({"kind": "action", "id": "scrub_hands"})
	dismiss_any_overlay_screens()
	await process_frame

	expect(app.screen == "character_event" and app.game.active_character_event_id == PREOP_EVENT, locale + " Scene 1 started")
	await play_character_event_and_capture(PREOP_EVENT, s1_shots, locale)
	expect(app.screen == "preop", locale + " returned to preop after Scene 1")

	app.game.set_intraoperative_crisis_enabled(true)
	var captured_i1 := false
	var captured_i3 := false
	var guard := 0
	while not prep.surgery_success and guard < 120:
		guard += 1
		dismiss_any_overlay_screens()
		var cur: Dictionary = prep.current()
		var kind := str(cur.get("kind", ""))
		if prep.assistant_anesthesia_pending:
			app.preop_event({"kind": "assistant_anesthesia_ack"})
		elif kind == "surgery_select":
			app.preop_event({"kind": "procedure", "id": surg_id})
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
				var fb_now := str(prep.feedback)
				if not intraop_1_shot.is_empty() and not captured_i1 and (fb_now.contains("拉钩角度") or fb_now.contains("retractor angle")):
					app.show_preop(preop_id)
					await save_shot(intraop_1_shot)
					captured_i1 = true
				elif not intraop_3_shot.is_empty() and not captured_i3 and (fb_now.contains("收尾剪线") or fb_now.contains("closing sutures")):
					app.show_preop(preop_id)
					await save_shot(intraop_3_shot)
					captured_i3 = true
				app.preop_event({"kind": "flow_acknowledge"})
			else:
				var step: Dictionary = prep.surgery_flow_step()
				var picked_id := ""
				for opt in step.get("options", []):
					if bool(opt.get("correct", false)):
						picked_id = str(opt.get("id", ""))
						break
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
			if pick_action.is_empty():
				for a in actions:
					if prep.action_visible(a) and not prep.done.has(a.id) and prep.action_reason(a).is_empty():
						pick_action = str(a.get("id", ""))
						break
			app.preop_event({"kind": "action", "id": pick_action})

	dismiss_any_overlay_screens()
	expect(prep.surgery_success, locale + " routine surgery succeeded")
	app.finish_surgery_and_return()
	var growth_btn := app.page.find_child("SurgeryGrowthContinue", true, false) as Button
	if growth_btn != null:
		growth_btn.pressed.emit()
	await process_frame

	expect(app.screen == "character_event" and app.game.active_character_event_id == POSTOP_EVENT, locale + " Scene 3 started")
	await play_character_event_and_capture(POSTOP_EVENT, s3_shots, locale)
	expect(app.screen == "character_event_complete", locale + " reached character_event_complete")
	await save_shot(complete_shot)

	var post_continue := app.page.find_child("PostSurgeryEventContinue", true, false) as Button
	if post_continue != null:
		post_continue.pressed.emit()
	await process_frame

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://" + OUT_DIR))
	var tmp_save_path := "/private/tmp/asuka_lv1_preview_unused_%s.json" % OS.get_process_id()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = tmp_save_path
	root.add_child(app)
	await process_frame

	await run_locale_flow(
		"zh_CN",
		"01_zh_preop_sweep_disabled.png",
		ZH_SCENE1_SHOTS,
		"04_zh_intraop_01_exposure.png",
		"05_zh_intraop_03_closure.png",
		ZH_SCENE3_SHOTS,
		"11_zh_lv1_completion_card.png"
	)
	await run_locale_flow(
		"en",
		"12_en_preop_sweep_disabled.png",
		EN_SCENE1_SHOTS,
		"14_en_intraop_01_exposure.png",
		"",
		EN_SCENE3_SHOTS,
		"18_en_lv1_completion_card.png"
	)

	if FileAccess.file_exists(tmp_save_path):
		DirAccess.remove_absolute(tmp_save_path)
	print("ASUKA LV1 PREVIEW CAPTURE: %s checks; %s failure(s)" % [checks, failures])
	app.queue_free()
	await process_frame
	quit(1 if failures else 0)
