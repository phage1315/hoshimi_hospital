extends SceneTree
## Native visible-window full-route showcase & verification for the complete
## awake shame-play / mischief queue (Step 0 -> Step 5 + skip_sterile_draping),
## starting from the hospital Ward UI and clicking real buttons via push_input().

var app: Control
var qa_dir := ProjectSettings.globalize_path("res://docs/qa/mischief_full_run_2026-11-09")
var checks := 0
var failures := 0
var mouse_clicks := 0
var captured_shots: Array[String] = []
var captured_Set := {}

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func capture_once(name: String) -> void:
	if captured_Set.has(name):
		return
	captured_Set[name] = true
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

func action_button_near(pos: Vector2, tolerance: float = 8.0) -> Button:
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

func select_role_picker(role_id: String, staff_id: String) -> bool:
	var picker: OptionButton = app.page.get_node_or_null("Role_" + role_id)
	expect(picker != null and picker.is_visible_in_tree(), "Role picker visible: " + role_id)
	if picker == null:
		return false
	var wanted := -1
	for i in range(picker.item_count):
		if str(picker.get_item_metadata(i)) == staff_id and not picker.is_item_disabled(i):
			wanted = i
			break
	if wanted < 0:
		for i in range(1, picker.item_count):
			if not picker.is_item_disabled(i):
				wanted = i
				break
	expect(wanted >= 0, "Selectable staff in picker " + role_id + " -> " + staff_id)
	if wanted < 0:
		return false
	picker.select(wanted)
	picker.item_selected.emit(wanted)
	await process_frame
	await process_frame
	return true

func drain_overlays(last_action_id: String) -> void:
	for _i in range(20):
		await process_frame
		if app.screen == "preop_transition_video":
			await click_point(Vector2(640, 380))
			continue
		var skip_video := visible_button("SurgeryVideoSkip")
		if skip_video != null:
			await click_native(skip_video, "SurgeryVideoSkip")
			continue
		var ward_cg_continue := visible_button("WardPreparationCGContinue")
		if ward_cg_continue != null:
			await capture_once("cg_" + last_action_id)
			await click_native(ward_cg_continue, "WardPreparationCGContinue")
			continue
		var ward_splash_continue := visible_button("WardPreparationSplashContinue")
		if ward_splash_continue != null:
			await capture_once("splash_" + last_action_id)
			await click_native(ward_splash_continue, "WardPreparationSplashContinue")
			continue
		var anesth_continue := visible_button("AnesthesiaSplashContinue")
		if anesth_continue != null:
			await click_native(anesth_continue, "AnesthesiaSplashContinue")
			continue
		var role_continue := visible_button("StaffRoleRewardContinue")
		if role_continue != null:
			await click_native(role_continue, "StaffRoleRewardContinue")
			continue
		var surg_cg_continue := visible_button("SurgeryCGContinue")
		if surg_cg_continue != null:
			await capture_once("cg_surgery_complete")
			await click_native(surg_cg_continue, "SurgeryCGContinue")
			continue
		break

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			qa_dir = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(qa_dir)
	expect(DisplayServer.get_name() != "headless", "Must run in native visible window (not --headless)")

	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/mischief_full_run_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	await process_frame

	expect(app.content.load_all("zh_CN"), "Load zh_CN content")
	app.configure_game_content()
	app.dialogue_auto_enabled = false
	app.game.micro_event_definitions.clear()

	# Pin patient_mouri_ran to template_breast_tumor (supine breast surgery) so
	# BOTH unnecessary ward enema/shaving AND unnecessary forced lithotomy trigger!
	var cases: Dictionary = app.game.legacy_patient_cases()
	cases["patient_mouri_ran"] = "template_breast_tumor"
	app.game.patient_cases = cases
	app.game.rebuild_patient_content(cases)
	app.game.unlock_procedure("surgery_breast_tumor")
	for person in app.content.collections.staff:
		app.game.meet_staff(str(person.id))

	var visit = app.game.open_visit("visit_mouri_ran")
	visit.admitted = true

	# Enter from the real hospital Ward location UI.
	app.show_location("ward")
	await process_frame
	await capture_once("00_ward_location_entry")
	var ward_enter_btn := action_button_near(Vector2(445, 390), 20.0)
	expect(ward_enter_btn != null, "Real Ward patient preparation button rendered")
	if ward_enter_btn == null:
		quit(1)
		return
	await click_native(ward_enter_btn, "WardEnterPreop")

	var prep: RefCounted = app.game.preops.get("preop_mouri_ran")
	expect(prep != null and app.screen == "preop", "Entered preop_mouri_ran from Ward UI")
	if prep == null:
		quit(1)
		return
	prep.session_flavor_salt = 7

	# Preferred mischief-first action order across the entire preop + OR + postop flow.
	var mischief_preferred := [
		"explain_plan",
		"graphic_answer",
		"confirm_team",
		"begin_manual_ward_preparation",
		"ward_enema_unnecessary",
		"ack_ward_enema",
		"ward_skin_prep_unnecessary",
		"ack_ward_skin_prep",
		"ward_surgical_cap",
		"complete_manual_ward_preparation",
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
		"contact_command",
		"ongoing_eye_contact",
		"closure_silent",
		"begin_postop_bare_inspection",
		"postop_bare_sponge_wipe",
		"postop_bare_full_inspection",
		"ack_postop_nurse_commentary",
		"execute_confirmed_procedure",
	]

	var last_action_id := "ward_enter"
	for _guard in range(280):
		await drain_overlays(last_action_id)
		if prep.surgery_success or prep.surgery_aborted:
			break

		if prep.assistant_anesthesia_pending:
			var ack_assist := action_button_near(Vector2(65, 620), 15.0)
			if ack_assist != null:
				await click_native(ack_assist, "AssistantAnesthesiaAck")
				continue

		var stage := str(prep.stage_id)

		# Capture targeted UI showcase frames BEFORE clicking each milestone!
		match stage:
			"graphic_preop_question":
				await capture_once("01_ward_graphic_choice")
			"ward_enema":
				await capture_once("03_ward_unnecessary_enema_choice")
			"ward_enema_response":
				await capture_once("04_ward_unnecessary_enema_reaction")
			"ward_skin_prep":
				await capture_once("05_ward_unnecessary_skin_prep_choice")
			"ward_skin_prep_response":
				await capture_once("06_ward_unnecessary_skin_prep_reaction")
			"operative_positioning":
				await capture_once("07_or_step1_lithotomy_choice")
			"operative_positioning_response":
				await capture_once("08_or_step1_lithotomy_switched")
			"urinary_catheterization":
				await capture_once("09_or_step2_manual_catheter_entry")
			"manual_catheter_insertion":
				await capture_once("10_or_step2_nurse_tray_handoff")
			"manual_catheter_bladder_press":
				await capture_once("11_or_step2_bladder_press_choice")
			"manual_catheter_press_response":
				await capture_once("12_or_step2_bladder_press_reaction")
			"urinary_catheterization_response":
				await capture_once("13_or_step2_nurse_ange_comeback")
			"skin_disinfection":
				await capture_once("14_or_step3_disinfection_entry")
			"excessive_disinfection_breasts":
				await capture_once("15_or_step3_disinfection_breasts_choice")
			"excessive_disinfection_perineum":
				await capture_once("16_or_step3_disinfection_breasts_reaction")
			"excessive_disinfection_drying":
				await capture_once("17_or_step3_disinfection_perineum_reaction")
			"skin_disinfection_response":
				await capture_once("18_or_step3_drying_and_skip_drape_choice")
			"sterile_draping_skipped_response":
				await capture_once("19_or_skip_draping_reaction")
			"incision_marking":
				await capture_once("20_or_step4_incision_entry")
			"slow_incision_tracing":
				await capture_once("21_or_step4_slow_trace_choice")
			"incision_public_lecture":
				await capture_once("22_or_step4_public_lecture_choice")
			"incision_nurse_commentary":
				await capture_once("23_or_step4_public_lecture_reaction")
			"incision_marking_response":
				await capture_once("24_or_step4_nurse_pool_commentary")
			"procedure_execute":
				if prep.flags.has("postop_bare_cleanup_done"):
					await capture_once("29_or_step5_nurse_sheet_cover_handoff")
				else:
					await capture_once("26_or_step5_postop_entry")
			"postop_bare_wipe":
				await capture_once("27_or_step5_postop_wipe_near_collapse")
			"postop_bare_inspection":
				await capture_once("28_or_step5_postop_inspect_choice")
			"postop_nurse_commentary":
				await capture_once("28b_or_step5_postop_inspect_reaction")

		if stage == "graphic_preop_dialogue":
			await capture_once("01b_ward_graphic_dialogue")
			var g_btn := visible_button("GraphicPreopContinue")
			if not await click_native(g_btn, "GraphicPreopContinue"):
				break
			continue

		if stage == "team":
			if not prep.team.has("assistant_surgeon"):
				await select_role_picker("assistant_surgeon", "doc_aoi")
				continue
			if not prep.team.has("scrub_nurse"):
				await select_role_picker("scrub_nurse", "nurse_rin")
				continue
			if not prep.team.has("circulating_nurse"):
				await select_role_picker("circulating_nurse", "nurse_ange")
				continue

		if stage == "preparation":
			if not prep.team.has("ward_nurse"):
				await select_role_picker("ward_nurse", "nurse_haru")
				continue
			await capture_once("02_ward_manual_prep_entry")

		if stage == "procedure_select":
			var proc_btn := visible_button("Procedure_surgery_breast_tumor")
			if proc_btn != null:
				var scroll: ScrollContainer = app.page.get_node_or_null("ProcedureList")
				if scroll != null:
					scroll.ensure_control_visible(proc_btn)
					await process_frame
				last_action_id = "select_breast_tumor"
				if not await click_native(proc_btn, "Procedure_surgery_breast_tumor"):
					break
				continue

		if prep.current().kind in ["or_table_palpation", "anesthesia_sensory_test"]:
			var finish_id := "PalpationComplete" if prep.current().kind == "or_table_palpation" else "AnesthesiaTestComplete"
			var pal_btn := visible_button(finish_id)
			last_action_id = finish_id
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
				await capture_once("25_intraop_awake_interaction")
				var chosen: Button = null
				for pref_int in ["intrusion_dignity_dismiss", "intrusion_break_continue", "intrusion_cooperation_continue"]:
					chosen = visible_button("PatientInteraction_" + pref_int)
					if chosen != null:
						break
				if chosen == null:
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
			await capture_once("25_intraop_awake_flow")
			var flow_step: Dictionary = prep.surgery_flow_step()
			var step_btn: Button = null
			for opt in flow_step.get("options", []):
				if str(flow_step.get("kind", "")) != "decision" or bool(opt.get("correct", false)):
					step_btn = visible_button("SurgeryStep_" + str(opt.id))
					if step_btn != null:
						last_action_id = str(opt.id)
						break
			if not await click_native(step_btn, "SurgeryStep"):
				break
			continue

		# Standard / mischief PreopAction buttons
		var next_btn: Button = null
		for candidate_id in mischief_preferred:
			next_btn = visible_button("PreopAction_" + candidate_id)
			if next_btn != null:
				last_action_id = candidate_id
				break
		if next_btn == null:
			for act_def in prep.current().get("actions", []):
				next_btn = visible_button("PreopAction_" + str(act_def.id))
				if next_btn != null:
					last_action_id = str(act_def.id)
					break
		if not await click_native(next_btn, "PreopAction_" + last_action_id):
			break

	await drain_overlays(last_action_id)
	expect(prep.surgery_success and not prep.surgery_aborted, "Full mischief surgery completed successfully")
	expect(prep.current().kind == "surgery_complete", "Reached surgery_result screen")
	await capture_once("30_surgery_result_summary")

	# Verify all 6 mischief milestone flags fired during this single continuous native run!
	for required_flag in [
		"manual_ward_preparation",
		"unnecessary_lithotomy_positioned",
		"manual_bladder_pressed",
		"excessive_disinfection_full_body",
		"sterile_draping_skipped",
		"incision_public_lectured",
		"postop_bare_inspected",
	]:
		expect(prep.flags.has(required_flag), "Full native run triggered mischief flag: " + required_flag)

	expect(prep.lowest_dignity_seen == 0, "Cumulative shame drove patient lowest_dignity_seen all the way to 0 (got %s)" % prep.lowest_dignity_seen)

	var settle_btn := visible_button("SurgeryResultReturn")
	if settle_btn != null:
		await click_native(settle_btn, "SurgeryResultReturn")
		await process_frame
		var growth_btn := visible_button("SurgeryGrowthContinue")
		if growth_btn != null:
			await capture_once("31_surgery_growth_splash")
			await click_native(growth_btn, "SurgeryGrowthContinue")
			await process_frame

	var report := {
		"patient_id": "patient_mouri_ran",
		"procedure_id": "surgery_breast_tumor",
		"display_driver": DisplayServer.get_name(),
		"checks": checks,
		"failures": failures,
		"mouse_clicks": mouse_clicks,
		"final_dignity": prep.dignity,
		"lowest_dignity_seen": prep.lowest_dignity_seen,
		"peak_fear_seen": prep.peak_fear_seen,
		"presence_delta_total": prep.player_effects.get("presence", 0),
		"screenshots": captured_shots,
	}
	var report_file := FileAccess.open(qa_dir + "/report.json", FileAccess.WRITE)
	if report_file != null:
		report_file.store_string(JSON.stringify(report, "\t"))
		report_file.close()
	print("MISCHIEF FULL NATIVE RUN: checks=%d failures=%d clicks=%d shots=%d lowest_dignity=%d" % [checks, failures, mouse_clicks, captured_shots.size(), prep.lowest_dignity_seen])
	quit(1 if failures else 0)
