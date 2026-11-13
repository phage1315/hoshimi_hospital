extends SceneTree
## Automated native windowed GUI playthrough and visual preview capture for
## Shiori Fujisaki's Relationship Lv3 two-volume arc:
## - Volume 1 (`shiori_lv3_part_a_yuko_surgery`): 《朝日奈夕子的手术》
## - Volume 2 (`shiori_lv3_part_b_dinner_walk`): 《四人晚餐与那晚的归途》

const PART_A := "shiori_lv3_part_a_yuko_surgery"
const PART_B := "shiori_lv3_part_b_dinner_walk"
const OUT_DIR := "docs/qa/shiori_lv3_preview_2026-11-12"
const ShioriLv3 = preload("res://godot/systems/shiori_lv3.gd")

const TARGET_CAPTURES_A := {
	"slv3a_015": "preview_01_a1_clinic_frown_ultrasound.png",
	"slv3a_080": "preview_02_a3_or_prep_3char_yuko_cap.png",
	"slv3a_124": "preview_02c_a4_cg1_spinal_dialogue.png",
	"slv3a_141": "preview_02e_a5_cg2_forceps_dialogue.png",
	"slv3a_153": "preview_03_a5_yuko_warm_shiori_ear_blush.png",
	"slv3a_195": "preview_06_a7_ward_rounds_postop.png",
}

const TARGET_CLEAN_CG_REVEALS_A := {
	"slv3a_108": "preview_02b_a4_cg1_spinal_clean_1s.png",
	"slv3a_132": "preview_02d_a5_cg2_forceps_clean_1s.png",
}

const TARGET_CAPTURES_B := {
	"slv3b_044": "preview_07_b2_trattoria_exterior_4meetup.png",
	"slv3b_080": "preview_08_b3_dinner_table_choice_b3.png",
	"slv3b_105": "preview_09_b4_wink_signal_megumi_nod.png",
	"slv3b_147": "preview_10_b5_night_walk_choice_b5.png",
	"slv3b_170": "preview_11_b6_porch_hesitant_gaze_up.png",
	"slv3b_176": "preview_12_b6_porch_soft_goodnight.png",
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

func capture_viewport(filename: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var out_path := ProjectSettings.globalize_path("res://%s/%s" % [OUT_DIR, filename])
	var err: int = app.get_viewport().get_texture().get_image().save_png(out_path)
	expect(err == OK, "Saved preview screenshot " + out_path)

func run() -> void:
	var abs_out := ProjectSettings.globalize_path("res://" + OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_out)
	var tmp_save := "/private/tmp/shiori_lv3_preview_unused_%s.json" % OS.get_process_id()

	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = tmp_save
	root.add_child(app)
	await process_frame

	expect(app.content.load_all("zh_CN"), "Load zh_CN content")
	app.configure_game_content()
	app.dialogue_auto_enabled = false

	# --- Part A native windowed playthrough ---
	expect(app.game.prepare_character_event_test_save(PART_A), "Prepare isolated Shiori Lv3 Part A fixture")
	app.game.advance_story_to_day(app.game.day_number(), 975)
	app.show_location("clinic", false, false, false)
	await capture_viewport("preview_00_clinic_entry_part_a.png")

	var event_a = app.game.start_character_event(PART_A)
	expect(event_a != null, "Start shiori_lv3_part_a_yuko_surgery")
	if event_a == null:
		quit(1)
		return
	app.character_event_return_location = "clinic"
	app.reset_dialogue_page()
	app.show_character_event()
	await process_frame

	var captured_a := {}
	var guard_a := 0
	while app.screen == "character_event" and guard_a < 230:
		guard_a += 1
		var node: Dictionary = event_a.current()
		var nid := str(node.get("id", ""))
		if TARGET_CLEAN_CG_REVEALS_A.has(nid):
			var dlg_hidden: Control = app.page.get_node_or_null("CharacterEventDialogueBox")
			expect(dlg_hidden != null and not dlg_hidden.visible, "Clean 1s CG reveal active on " + nid)
			await capture_viewport(TARGET_CLEAN_CG_REVEALS_A[nid])
			await create_timer(1.08).timeout
			expect(dlg_hidden != null and dlg_hidden.visible, "Dialogue appeared after 1s on " + nid)
		var pages: Array = app.authored_dialogue_pages(str(node.get("text", "")))
		for page_idx in range(pages.size()):
			if page_idx > 0 or not TARGET_CLEAN_CG_REVEALS_A.has(nid):
				app.dialogue_page_index = page_idx
				app.show_character_event()
				await process_frame
			if TARGET_CAPTURES_A.has(nid) and page_idx == pages.size() - 1 and not captured_a.has(nid):
				await capture_viewport(TARGET_CAPTURES_A[nid])
				captured_a[nid] = true
		var choices: Array = node.get("choices", [])
		var btn: Button = app.page.get_node_or_null("EventChoice_" + str(choices[0].id))
		expect(btn != null, "UI button exists at " + nid)
		if btn == null:
			break
		btn.pressed.emit()
		await process_frame

	# Live surgery_appendix Runner handoff at slv3a_174
	expect(app.screen == "preop", "Entered live surgery_appendix Runner")
	await capture_viewport("preview_04_a6_surgery_runner_yuko_bark.png")

	var prep = app.game.preops.get(ShioriLv3.STORY_PREOP_ID)
	app.game.set_intraoperative_crisis_enabled(false)
	var captured_shiori_or := false
	var guard_s := 0
	while prep != null and not prep.surgery_success and guard_s < 80:
		guard_s += 1
		if str(prep.current().get("kind", "")) == "surgery_execute":
			app.preop_event({"kind": "action", "id": "execute_confirmed_procedure"})
		elif prep.awaiting_patient_choice:
			var acts: Array = prep.active_patient_interaction.get("actions", [])
			app.preop_event({"kind": "patient_interaction_action", "id": str(acts[0].id)})
		elif prep.awaiting_patient_acknowledgement:
			app.preop_event({"kind": "patient_acknowledge"})
		elif prep.awaiting_flow_acknowledgement:
			if not captured_shiori_or:
				await capture_viewport("preview_05_a6_surgery_runner_shiori_response.png")
				captured_shiori_or = true
			app.preop_event({"kind": "flow_acknowledge"})
		else:
			var step: Dictionary = prep.surgery_flow_step()
			for opt in step.get("options", []):
				if bool(opt.get("correct", false)):
					app.preop_event({"kind": "surgery_step", "id": str(opt.id)})
					break
		await process_frame

	var settle_btn: Button = app.page.get_node_or_null("SurgeryResultReturn")
	expect(settle_btn != null, "SurgeryResultReturn present")
	if settle_btn != null:
		settle_btn.pressed.emit()
		await process_frame
	var growth_btn: Button = app.page.find_child("SurgeryGrowthContinue", true, false) as Button
	expect(growth_btn != null, "SurgeryGrowthContinue present")
	if growth_btn != null:
		growth_btn.pressed.emit()
		await process_frame

	expect(app.screen == "character_event" and str(event_a.current().get("id", "")) == "slv3a_175", "Resumed slv3a_175 post-surgery")
	guard_a = 0
	while not event_a.completed and guard_a < 60:
		guard_a += 1
		var node_post: Dictionary = event_a.current()
		var nid_post := str(node_post.get("id", ""))
		var pages_post: Array = app.authored_dialogue_pages(str(node_post.get("text", "")))
		for page_idx in range(pages_post.size()):
			app.dialogue_page_index = page_idx
			app.show_character_event()
			await process_frame
			if TARGET_CAPTURES_A.has(nid_post) and page_idx == pages_post.size() - 1 and not captured_a.has(nid_post):
				await capture_viewport(TARGET_CAPTURES_A[nid_post])
				captured_a[nid_post] = true
		var chs_post: Array = node_post.get("choices", [])
		var btn_post: Button = app.page.get_node_or_null("EventChoice_" + str(chs_post[0].id))
		expect(btn_post != null, "Post-op UI button exists at " + nid_post)
		if btn_post == null:
			break
		btn_post.pressed.emit()
		await process_frame

	var dt_a: Button = app.page.get_node_or_null("DayTransitionContinue")
	if dt_a != null:
		dt_a.pressed.emit()
		await process_frame
	if app.screen == "character_event_complete":
		app.game.finish_character_event()
		app.show_map()
		await process_frame

	# --- Part B native windowed playthrough ---
	var part_a_done_day: int = int(app.game.character_events[PART_A].completed_day)
	var start_day_b: int = part_a_done_day + 6
	while app.game.is_hospital_closed_day(start_day_b) or app.game.is_hospital_closed_day(start_day_b + 2):
		start_day_b += 1
	app.game.advance_story_to_day(start_day_b, 975)

	var event_b = app.game.start_character_event(PART_B)
	expect(event_b != null, "Start shiori_lv3_part_b_dinner_walk")
	if event_b == null:
		quit(1)
		return
	app.character_event_return_location = "clinic"
	app.reset_dialogue_page()
	app.show_character_event()
	await process_frame

	var captured_b := {}
	var guard_b := 0
	while not event_b.completed and guard_b < 200:
		guard_b += 1
		var node_b: Dictionary = event_b.current()
		var nid_b := str(node_b.get("id", ""))
		var pages_b: Array = app.authored_dialogue_pages(str(node_b.get("text", "")))
		for page_idx in range(pages_b.size()):
			app.dialogue_page_index = page_idx
			app.show_character_event()
			await process_frame
			if TARGET_CAPTURES_B.has(nid_b) and page_idx == pages_b.size() - 1 and not captured_b.has(nid_b):
				await capture_viewport(TARGET_CAPTURES_B[nid_b])
				captured_b[nid_b] = true
		var chs_b: Array = node_b.get("choices", [])
		var btn_b: Button = app.page.get_node_or_null("EventChoice_" + str(chs_b[0].id))
		expect(btn_b != null, "Part B UI button exists at " + nid_b)
		if btn_b == null:
			break
		btn_b.pressed.emit()
		await process_frame

	var dt_b: Button = app.page.get_node_or_null("DayTransitionContinue")
	if dt_b != null:
		dt_b.pressed.emit()
		await process_frame
	if app.screen == "character_event_complete":
		await capture_viewport("preview_13_part_b_lv3_complete_screen.png")
		app.game.finish_character_event()
		app.show_map()
		await process_frame

	app.show_staff("doc_shiori", "clinic")
	await capture_viewport("preview_14_staff_profile_lv3.png")

	# --- English runtime screenshots on Part B dinner & apartment porch ---
	expect(app.content.load_all("en"), "Load en content")
	app.configure_game_content()
	expect(app.game.prepare_character_event_test_save(PART_B), "Prepare EN Part B fixture")
	app.game.advance_story_to_day(app.game.day_number(), 975)
	var en_b = app.game.start_character_event(PART_B)
	expect(en_b != null, "Start EN Part B")
	if en_b == null:
		quit(1)
		return
	while not en_b.completed and str(en_b.current().get("id", "")) != "slv3b_080":
		app.game.choose_character_event(str(en_b.current().get("choices", [])[0].id))
	app.reset_dialogue_page()
	app.show_character_event()
	await capture_viewport("preview_15_en_b3_dinner_choice.png")
	while not en_b.completed and str(en_b.current().get("id", "")) != "slv3b_176":
		app.game.choose_character_event(str(en_b.current().get("choices", [])[0].id))
	app.reset_dialogue_page()
	app.show_character_event()
	await capture_viewport("preview_16_en_b6_porch_goodnight.png")

	if FileAccess.file_exists(tmp_save):
		DirAccess.remove_absolute(tmp_save)

	expect(captured_a.size() == TARGET_CAPTURES_A.size(), "Captured all Part A target screens")
	expect(captured_b.size() == TARGET_CAPTURES_B.size(), "Captured all Part B target screens")
	print("SHIORI LV3 PREVIEW CAPTURE: %s Part A + %s Part B + surgery + EN screens saved; %s checks; %s failure(s)" % [captured_a.size(), captured_b.size(), checks, failures])
	quit(1 if failures else 0)
