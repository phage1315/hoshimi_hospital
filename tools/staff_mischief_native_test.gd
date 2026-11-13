extends SceneTree
## Native visible-window showcase & verification for all 3 Lv5 Staff-as-Patient
## heroines (doc_sayaka, doc_serika, nurse_yui) running the full awake surgical
## shame-play / mischief route via synthesized GUI clicks (root.push_input).

const Setup = preload("res://godot/systems/advanced_staff_patient_test_setup.gd")

var app: Control
var qa_dir := ProjectSettings.globalize_path("res://docs/qa/staff_mischief_2026-11-09")
var checks := 0
var failures := 0
var mouse_clicks := 0
var captured_shots: Array[String] = []
var captured_set := {}

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func capture_once(name: String) -> void:
	if captured_set.has(name):
		return
	captured_set[name] = true
	await capture(name)

func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(qa_dir)
	var path := qa_dir + "/" + name + ".png"
	var err := root.get_texture().get_image().save_png(path)
	expect(err == OK, "Saved screenshot " + name)
	if err == OK:
		captured_shots.append(path)

func visible_button(id: String) -> Button:
	if app == null or app.page == null:
		return null
	var button: Button = app.page.find_child(id, true, false)
	if button == null or not button.is_visible_in_tree() or button.disabled:
		return null
	return button

func action_button_near(pos: Vector2, tolerance: float = 16.0) -> Button:
	if app == null or app.page == null:
		return null
	for candidate in app.page.find_children("*", "Button", true, false):
		if candidate is Button and candidate.is_visible_in_tree() and not candidate.disabled and candidate.position.distance_to(pos) <= tolerance:
			return candidate
	return null

func click_native(button: Button, label_hint: String = "") -> bool:
	expect(button != null and is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled, "Native clickable button " + label_hint)
	if button == null or not is_instance_valid(button) or not button.is_visible_in_tree() or button.disabled:
		return false
	var point: Vector2 = button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, true)
	for down in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = down
		ev.position = point
		ev.global_position = point
		root.push_input(ev, true)
		await process_frame
	await process_frame
	mouse_clicks += 1
	return true

func click_point(point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, true)
	for down in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = down
		ev.position = point
		ev.global_position = point
		root.push_input(ev, true)
		await process_frame
	await process_frame
	mouse_clicks += 1

func select_role_picker(prep: RefCounted, role_id: String, preferred_ids: Array) -> bool:
	var picker: OptionButton = app.page.get_node_or_null("Role_" + role_id)
	expect(picker != null and picker.is_visible_in_tree(), "Role picker visible: " + role_id)
	if picker == null:
		return false
	var people: Array = prep.candidates(role_id)
	var wanted := -1
	for staff_id in preferred_ids:
		for i in range(people.size()):
			if str(people[i].id) == str(staff_id) and not picker.is_item_disabled(i + 1):
				wanted = i + 1
				break
		if wanted >= 0:
			break
	if wanted < 0:
		for i in range(1, picker.item_count):
			if not picker.is_item_disabled(i):
				wanted = i
				break
	expect(wanted >= 0, "Selectable staff in picker " + role_id)
	if wanted < 0:
		return false
	picker.select(wanted)
	picker.item_selected.emit(wanted)
	await process_frame
	await process_frame
	return true

func drain_overlays() -> void:
	for _i in range(20):
		await process_frame
		if app.screen == "preop_transition_video":
			await click_point(Vector2(640, 380))
			continue
		var clicked_overlay := false
		for btn_id in [
			"SurgeryVideoSkip",
			"WardPreparationCGContinue",
			"WardPreparationSplashContinue",
			"AnesthesiaSplashContinue",
			"StaffRoleRewardContinue",
			"SurgeryCGContinue",
		]:
			var overlay_btn := visible_button(btn_id)
			if overlay_btn != null:
				await click_native(overlay_btn, btn_id)
				clicked_overlay = true
				break
		if not clicked_overlay:
			break

func run_heroine(cfg: Dictionary) -> Dictionary:
	var actor_id := str(cfg.actor_id)
	var prefix := str(cfg.prefix)
	app.game.reset()
	app.game.micro_event_definitions.clear()
	Setup.fixture(app.game, actor_id)
	app.game.unlock_procedure("surgery_breast_tumor")
	expect(app.game.staff_patient_unlocked(actor_id), "Unlocked staff patient " + actor_id)
	expect(app.game.invite_staff_patient(actor_id, "surgery_breast_tumor"), "Invited staff patient " + actor_id + ": " + app.game.last_error)

	app.show_location("ward")
	await process_frame
	await capture_once(prefix + "_01_ward_entry")

	var ward_btn := action_button_near(Vector2(700, 390), 25.0)
	expect(ward_btn != null, actor_id + " Ward entry button rendered")
	if ward_btn == null:
		return {}
	await click_native(ward_btn, actor_id + "_WardEnter")

	var prep: RefCounted = app.game.preops.get(app.game.StaffPatient.PREOP_ID)
	expect(prep != null and app.screen == "preop" and prep.is_staff_patient(), "Entered StaffPatient preop for " + actor_id)
	if prep == null:
		return {}
	prep.session_flavor_salt = int(cfg.salt)

	var mischief_preferred := [
		"explain_plan",
		"appropriate_answer",
		"confirm_team",
		"perform_preparation",
		"to_changing",
		"change_scrubs",
		"scrub_hands",
		"enter_room",
		"team_check",
		"confirm_assistant_role",
		"confirm_scrub_role",
		"confirm_circulating_role",
		"choose_local",
		"operative_positioning_unnecessary_lithotomy",
		"ack_positioning",
		"begin_manual_catheterization",
		"manual_urinary_catheterization",
		"manual_catheter_press_bladder",
		"nurse_verify_catheter_drainage",
		"ack_catheterization",
		"begin_excessive_disinfection",
		"excessive_disinfection_breasts",
		"excessive_disinfection_perineum",
		"ack_disinfection_drying",
		"skip_sterile_draping",
		"ack_skip_sterile_draping",
		"begin_slow_incision_marking",
		"slow_incision_trace",
		"incision_public_lecture",
		"ack_incision_nurse_commentary",
		"ack_marking_local",
		"start_local_surgery",
		"request_scalpel",
		"assistant_stabilize",
		"incise_local",
		"begin_postop_bare_inspection",
		"postop_bare_sponge_wipe",
		"postop_bare_full_inspection",
		"ack_postop_nurse_commentary",
		"execute_confirmed_procedure",
	]

	for _guard in range(300):
		await drain_overlays()
		if prep.surgery_success or prep.surgery_aborted:
			break

		if prep.assistant_anesthesia_pending:
			var ack_assist := action_button_near(Vector2(65, 620), 15.0)
			if ack_assist != null:
				await click_native(ack_assist, actor_id + "_AssistantAck")
				continue

		var stage := str(prep.stage_id)
		match stage:
			"operative_positioning_response":
				await capture_once(prefix + "_02_lithotomy_reaction")
			"manual_catheter_press_response":
				await capture_once(prefix + "_03_bladder_press_reaction")
			"urinary_catheterization_response":
				await capture_once(prefix + "_04_catheter_colleague_nurse")
			"excessive_disinfection_perineum":
				await capture_once(prefix + "_05_disinfect_breasts_reaction")
			"excessive_disinfection_drying":
				await capture_once(prefix + "_06_disinfect_perineum_reaction")
			"skin_disinfection_response":
				await capture_once(prefix + "_07_disinfect_colleague_scrub")
			"sterile_draping_skipped_response":
				await capture_once(prefix + "_08_skip_draping_reaction")
			"incision_public_lecture":
				await capture_once(prefix + "_09_slow_trace_reaction")
			"incision_nurse_commentary":
				await capture_once(prefix + "_10_public_lecture_reaction")
			"incision_marking_response":
				await capture_once(prefix + "_11_lecture_colleague_nurse")
			"postop_bare_inspection":
				await capture_once(prefix + "_12_postop_wipe_near_collapse")
			"postop_nurse_commentary":
				await capture_once(prefix + "_13_postop_inspect_reaction")
			"procedure_execute":
				if prep.flags.has("postop_bare_cleanup_done"):
					await capture_once(prefix + "_14_postop_colleague_sheet_cover")

		if stage == "graphic_preop_dialogue":
			var g_btn := visible_button("GraphicPreopContinue")
			if not await click_native(g_btn, "GraphicPreopContinue"):
				break
			continue

		if stage == "team":
			if not prep.team.has("assistant_surgeon"):
				await select_role_picker(prep, "assistant_surgeon", ["doc_aoi"])
				continue
			if not prep.team.has("scrub_nurse"):
				await select_role_picker(prep, "scrub_nurse", cfg.scrub)
				continue
			if not prep.team.has("circulating_nurse"):
				await select_role_picker(prep, "circulating_nurse", cfg.circ)
				continue

		if stage == "preparation":
			if not prep.team.has("ward_nurse"):
				await select_role_picker(prep, "ward_nurse", cfg.ward)
				continue

		if stage == "procedure_select":
			var proc_btn := visible_button("Procedure_surgery_breast_tumor")
			if proc_btn != null:
				var scroll: ScrollContainer = app.page.get_node_or_null("ProcedureList")
				if scroll != null:
					scroll.ensure_control_visible(proc_btn)
					await process_frame
				if not await click_native(proc_btn, "Procedure_surgery_breast_tumor"):
					break
				continue

		if prep.current().kind in ["or_table_palpation", "anesthesia_sensory_test"]:
			var finish_id := "PalpationComplete" if prep.current().kind == "or_table_palpation" else "AnesthesiaTestComplete"
			var pal_btn := visible_button(finish_id)
			if not await click_native(pal_btn, finish_id):
				break
			continue

		if prep.current().kind == "surgery_flow":
			if not prep.active_crisis.is_empty():
				if prep.awaiting_crisis_acknowledgement:
					var c_ack := visible_button("CrisisContinue")
					if not await click_native(c_ack, "CrisisContinue"):
						break
					continue
				var rescue_btn := visible_button("CrisisRescue_pause_and_stabilize")
				if not await click_native(rescue_btn, "CrisisRescue_pause_and_stabilize"):
					break
				continue
			if prep.awaiting_patient_choice:
				var chosen: Button = null
				for act_item in prep.active_patient_interaction.get("actions", []):
					chosen = visible_button("PatientInteraction_" + str(act_item.id))
					if chosen != null:
						break
				if not await click_native(chosen, "PatientInteractionChoice"):
					break
				continue
			if prep.awaiting_patient_acknowledgement:
				var p_cont := visible_button("SurgeryPatientContinue")
				if not await click_native(p_cont, "SurgeryPatientContinue"):
					break
				continue
			if prep.awaiting_flow_acknowledgement:
				var f_cont := visible_button("SurgeryFlowContinue")
				if not await click_native(f_cont, "SurgeryFlowContinue"):
					break
				continue
			var flow_step: Dictionary = prep.surgery_flow_step()
			var step_btn: Button = null
			for opt in flow_step.get("options", []):
				if str(flow_step.get("kind", "")) != "decision" or bool(opt.get("correct", false)):
					step_btn = visible_button("SurgeryStep_" + str(opt.id))
					if step_btn != null:
						break
			if not await click_native(step_btn, "SurgeryStep"):
				break
			continue

		var next_btn: Button = null
		var next_id := ""
		for candidate_id in mischief_preferred:
			next_btn = visible_button("PreopAction_" + candidate_id)
			if next_btn != null:
				next_id = candidate_id
				break
		if next_btn == null:
			for act_def in prep.current().get("actions", []):
				next_btn = visible_button("PreopAction_" + str(act_def.id))
				if next_btn != null:
					next_id = str(act_def.id)
					break
		if not await click_native(next_btn, actor_id + "_" + next_id):
			break

	await drain_overlays()
	expect(prep.surgery_success and not prep.surgery_aborted, actor_id + " surgery completed successfully")
	expect(prep.current().kind == "surgery_complete", actor_id + " reached surgery_result")
	await capture_once(prefix + "_15_surgery_result")

	for required_flag in [
		"unnecessary_lithotomy_positioned",
		"manual_bladder_pressed",
		"excessive_disinfection_full_body",
		"sterile_draping_skipped",
		"incision_public_lectured",
		"postop_bare_inspected",
	]:
		expect(prep.flags.has(required_flag), actor_id + " triggered mischief flag: " + required_flag)

	var settle_btn := visible_button("SurgeryResultReturn")
	if settle_btn != null:
		await click_native(settle_btn, actor_id + "_SurgeryResultReturn")
		await process_frame
		var growth_btn := visible_button("SurgeryGrowthContinue")
		if growth_btn != null:
			await click_native(growth_btn, actor_id + "_SurgeryGrowthContinue")
			await process_frame

	return {
		"actor_id": actor_id,
		"patient_name": prep.patient_name,
		"circulating_nurse": prep.team.get("circulating_nurse", ""),
		"scrub_nurse": prep.team.get("scrub_nurse", ""),
		"lowest_dignity_seen": prep.lowest_dignity_seen,
		"peak_fear_seen": prep.peak_fear_seen,
	}

func run() -> void:
	DirAccess.make_dir_recursive_absolute(qa_dir)
	expect(DisplayServer.get_name() != "headless", "Must run in native visible window (not --headless)")

	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/staff_mischief_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	await process_frame

	expect(app.content.load_all("zh_CN"), "Load zh_CN content")
	app.configure_game_content()
	app.dialogue_auto_enabled = false

	var configs := [
		{
			"actor_id": "doc_sayaka",
			"prefix": "sayaka",
			"scrub": ["nurse_haru"],
			"circ": ["nurse_rin"],
			"ward": ["nurse_yui"],
			"salt": 11,
		},
		{
			"actor_id": "doc_serika",
			"prefix": "serika",
			"scrub": ["nurse_yui"],
			"circ": ["nurse_ange"],
			"ward": ["nurse_hiroko"],
			"salt": 23,
		},
		{
			"actor_id": "nurse_yui",
			"prefix": "miyuki",
			"scrub": ["nurse_rin"],
			"circ": ["nurse_satsuki", "nurse_hiroko"],
			"ward": ["nurse_haru"],
			"salt": 37,
		},
	]

	var results: Array = []
	for cfg in configs:
		var summary := await run_heroine(cfg)
		results.append(summary)
		if failures > 0:
			break

	var report := {
		"display_driver": DisplayServer.get_name(),
		"checks": checks,
		"failures": failures,
		"mouse_clicks": mouse_clicks,
		"heroines": results,
		"screenshots_count": captured_shots.size(),
		"screenshots": captured_shots,
	}
	var report_file := FileAccess.open(qa_dir + "/report.json", FileAccess.WRITE)
	if report_file != null:
		report_file.store_string(JSON.stringify(report, "\t"))
		report_file.close()
	print("STAFF MISCHIEF NATIVE RUN: checks=%d failures=%d clicks=%d shots=%d" % [checks, failures, mouse_clicks, captured_shots.size()])
	quit(1 if failures else 0)
