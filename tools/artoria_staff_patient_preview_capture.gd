extends SceneTree
## Native 1280x800 Metal window synthetic-GUI playtest & screenshot capture for
## Artoria Pendragon (`doc_artoria`) Staff-as-Patient V1.1 across BOTH ordinary
## surgery (`surgery_open_major_liver_resection`) and Advanced 3-day surgery
## (`surgery_open_whipple`, plus technical texture verification of all 4 poses
## including author-supplied `chest.png`) in `zh_CN` and `en`.

const Setup = preload("res://godot/systems/advanced_staff_patient_test_setup.gd")
const Present = preload("res://godot/systems/advanced_presentation.gd")
const Registry = preload("res://godot/systems/staff_patient_registry.gd")

const ACTOR := "doc_artoria"
const ORDINARY_SURGERY := "surgery_open_major_liver_resection"
const ADVANCED_SURGERY := "surgery_open_whipple"

var app
var qa := "docs/qa/artoria_staff_patient_2026-11-17"
var route := ""
var current_locale := ""
var checks := 0
var failures: Array[String] = []
var route_steps := {"ordinary": 0, "advanced": 0}
var route_shots: Array[String] = []
var input_counts := {"mouse": 0, "space": 0}
var cjk_re := RegEx.new()

func _initialize() -> void:
	cjk_re.compile("[\\x{3400}-\\x{4dbf}\\x{4e00}-\\x{9fff}\\x{3040}-\\x{30ff}\\x{f900}-\\x{faff}]")
	call_deferred("run")

func expect(ok: bool, msg: String) -> void:
	checks += 1
	if not ok:
		failures.append(msg)
		push_error(msg)

func shot(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var path := "%s/%s_%s_%s.png" % [qa, current_locale, route, label]
	root.get_texture().get_image().save_png(path)
	route_shots.append(path)

func visible_button(id: String) -> Button:
	if app.page == null:
		return null
	var button: Button = app.page.find_child(id, true, false)
	if button == null or not button.is_visible_in_tree() or button.disabled:
		return null
	return button

func click_native(button: Button) -> void:
	expect(button != null and is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled, "Native button available")
	if button == null or not is_instance_valid(button):
		return
	var parent: Node = button.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			(parent as ScrollContainer).ensure_control_visible(button)
			await process_frame
			await process_frame
			break
		parent = parent.get_parent()
	var point: Vector2 = button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, true)
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		ev.position = point
		ev.global_position = point
		root.push_input(ev, true)
	await process_frame
	await process_frame
	input_counts.mouse += 1

func click_id(id: String) -> bool:
	var button := visible_button(id)
	expect(button != null, "%s: visible enabled button %s at %s" % [current_locale, id, route])
	if button == null:
		return false
	await click_native(button)
	return true

func click_popup(button: Button, dialog: Window) -> void:
	var point: Vector2 = button.get_global_rect().get_center()
	var viewport: Viewport = dialog
	if dialog.is_embedded():
		viewport = app.get_viewport()
		point += Vector2(dialog.position)
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	viewport.push_input(motion, true)
	for down in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.position = point
		ev.global_position = point
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = down
		viewport.push_input(ev, true)
		await process_frame
	await process_frame
	input_counts.mouse += 1

func click_point(point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, true)
	for down in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.position = point
		ev.global_position = point
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = down
		root.push_input(ev, true)
		await process_frame
	input_counts.mouse += 1

func press_space() -> void:
	for down in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = KEY_SPACE
		ev.pressed = down
		root.push_input(ev, true)
		await process_frame
	input_counts.space += 1

func close_notice() -> void:
	for child in app.get_children():
		if child is AcceptDialog and child.visible and child.name != "StaffPatientInvitation":
			var ok: Button = child.get_ok_button()
			if ok != null and ok.is_visible_in_tree():
				await click_popup(ok, child)
			else:
				child.hide()
	await process_frame

func select_picker(picker: OptionButton, actor_id: String) -> void:
	var wanted := -1
	for i in range(picker.item_count):
		if str(picker.get_item_metadata(i)) == actor_id:
			wanted = i
			break
	expect(wanted >= 0, "Picker contains metadata: " + actor_id)
	if wanted < 0:
		return
	picker.select(wanted)
	picker.item_selected.emit(wanted)
	await process_frame

func reset_fixture(locale: String) -> void:
	expect(app.content.load_all(locale), "Load locale " + locale)
	app.configure_game_content()
	Setup.fixture(app.game, ACTOR)
	app.game.micro_event_definitions.clear()
	app.dialogue_auto_enabled = false
	app.game.set_story_flag("artoria_major_liver_resection_teaching_complete", true)
	app.game.unlock_procedure(ORDINARY_SURGERY)
	app.game.unlock_procedure("surgery_appendix")
	if not app.game.advanced_referral_facts.has("procedures"):
		app.game.advanced_referral_facts["procedures"] = {}
	for adv_id in [
		ADVANCED_SURGERY,
		"surgery_adv_ebstein_cone_reconstruction",
		"surgery_adv_sleeve_lobectomy",
		"surgery_adv_posttraumatic_thoracolumbar_kyphosis_correction"
	]:
		app.game.advanced_referral_facts["procedures"][adv_id] = "CLEARED"
	expect(app.game.staff_patient_unlocked(ACTOR) and app.game.can_invite_staff_patient(ACTOR), locale + ": settled Lv5 facts open Artoria patient routes")

func verify_all_advanced_pose_textures() -> void:
	var pose_cases := {
		"abdominal": {"procedure_id": "surgery_open_whipple", "expected": "assets/characters/artoria_staff_patient_v1/doc_artoria/advanced/abdominal.png"},
		"chest": {"procedure_id": "surgery_adv_ebstein_cone_reconstruction", "expected": "assets/characters/artoria_staff_patient_v1/doc_artoria/advanced/chest.png"},
		"lateral": {"procedure_id": "surgery_adv_sleeve_lobectomy", "expected": "assets/characters/artoria_staff_patient_v1/doc_artoria/advanced/lateral.png"},
		"prone": {"procedure_id": "surgery_adv_posttraumatic_thoracolumbar_kyphosis_correction", "expected": "assets/characters/artoria_staff_patient_v1/doc_artoria/advanced/prone.png"},
	}
	for pose in pose_cases:
		var spec: Dictionary = pose_cases[pose]
		var dummy_case := {"staff_patient_id": ACTOR, "procedure_id": spec.procedure_id}
		var patient: Dictionary = Present.patient(dummy_case, app.game, current_locale == "en")
		var resolved := str(patient.get("visuals", {}).get("portraits", {}).get("team_confirmation", ""))
		expect(resolved == str(spec.expected), "%s: pose %s resolves %s (got %s)" % [current_locale, pose, spec.expected, resolved])
		var tex: Texture2D = load("res://" + resolved)
		expect(tex != null and tex.get_width() > 0 and tex.get_height() > 0, "%s: pose %s Texture2D loads (%s)" % [current_locale, pose, resolved])

func choose_invitation(advanced: bool) -> bool:
	app.show_staff(ACTOR, "artoria_office")
	await process_frame
	await shot("staff_profile")
	if not await click_id("StaffPatientInvite"):
		return false
	var dialog: ConfirmationDialog = app.get_node_or_null("StaffPatientInvitation")
	expect(dialog != null and dialog.visible, current_locale + ": invitation dialog opens")
	if dialog == null:
		return false
	var picker: OptionButton = dialog.find_child("StaffPatientProcedurePicker", true, false)
	expect(picker != null, current_locale + ": ordinary procedure selector exists")
	if picker != null:
		await select_picker(picker, ORDINARY_SURGERY)
	await shot("invite_dialog")
	if advanced:
		var advanced_button: Button = dialog.find_child("AdvancedStaffPatientInvitation", true, false)
		expect(advanced_button != null and not advanced_button.disabled, current_locale + ": AdvancedStaffPatientInvitation enabled")
		if advanced_button == null or advanced_button.disabled:
			return false
		await click_popup(advanced_button, dialog)
		await process_frame
		return app.screen == "advanced_referral"
	if picker == null:
		return false
	await click_popup(dialog.get_ok_button(), dialog)
	await close_notice()
	expect(app.game.admitted_patient(ACTOR), current_locale + ": Artoria admitted from visible invitation")
	if not app.game.admitted_patient(ACTOR):
		return false
	await shot("ward_record")
	return await click_id("StaffPatientWardContinue")

func action_button_at(position: Vector2) -> Button:
	for candidate in app.page.find_children("*", "Button", true, false):
		if candidate.is_visible_in_tree() and not candidate.disabled and candidate.position.distance_to(position) < 4:
			return candidate
	return null

func drain_overlays() -> void:
	for _i in range(16):
		await process_frame
		if app.screen == "preop_transition_video":
			await click_point(Vector2(640, 380))
			continue
		var found := false
		for id in ["StaffRoleRewardContinue", "WardPreparationCGContinue", "WardPreparationSplashContinue", "AnesthesiaSplashContinue", "SurgeryCGContinue", "SurgeryVideoSkip", "SurgeryGrowthContinue"]:
			if visible_button(id) != null:
				if id == "AnesthesiaSplashContinue":
					await shot("general_anesthesia_splash")
				await click_id(id)
				found = true
				break
		if not found:
			return

func regular_action(prep: RefCounted, branch: String) -> Button:
	var preferred := [
		"continue_ward_opening_0", "continue_ward_opening_1", "continue_ward_opening_2",
		"brief_plan", "confirm_team",
		"begin_manual_ward_preparation", "ward_enema", "ack_ward_enema", "ward_skin_prep", "ack_ward_skin_prep", "ward_surgical_cap", "complete_manual_ward_preparation",
		"to_changing", "change_scrubs", "scrub_hands", "enter_room", "team_check",
		"confirm_assistant_role", "confirm_scrub_role", "confirm_circulating_role",
		"choose_" + branch, "induction_reassure", "start_" + branch + "_surgery",
		"request_scalpel", "assistant_stabilize", "incise_" + branch, "execute_confirmed_procedure"
	]
	for id in preferred:
		var candidate := visible_button("PreopAction_" + id)
		if candidate != null:
			return candidate
	for action in prep.current().get("actions", []):
		var candidate := visible_button("PreopAction_" + str(action.id))
		if candidate != null:
			return candidate
	return null

func regular_route(branch: String) -> void:
	route = "ordinary"
	if not await choose_invitation(false):
		return
	expect(app.screen == "preop", current_locale + ": ward continues to regular preop")
	var prep: RefCounted = app.game.preops.get(Registry.PREOP_ID)
	if prep == null:
		return
	await shot("ward_opening_0")
	var seen := {}
	var shot_patient_choice := false
	for _step in range(380):
		await drain_overlays()
		if prep.surgery_success or prep.surgery_aborted:
			break
		var stage := str(prep.stage_id)
		if not seen.has(stage):
			seen[stage] = true
			if stage in ["ward_opening_1", "ward_visit", "ward_preparation", "procedure_select", "anesthesia", "incision_ready", "surgery_flow"]:
				await shot(stage)
		expect(not app.game.can_save_progress(), "%s: save locked in regular route %s" % [current_locale, stage])
		var button: Button = null
		if stage == "procedure_select":
			button = visible_button("Procedure_" + ORDINARY_SURGERY)
		elif stage in ["team", "preparation"]:
			var assigned := false
			for role in ["assistant_surgeon", "scrub_nurse", "circulating_nurse", "ward_nurse"]:
				if (role == "ward_nurse") != (stage == "preparation") or prep.team.has(role):
					continue
				var picker: OptionButton = app.page.get_node_or_null("Role_" + role)
				if picker != null:
					for i in range(1, picker.item_count):
						if not picker.is_item_disabled(i):
							picker.select(i)
							picker.item_selected.emit(i)
							await process_frame
							assigned = true
							break
					break
			if assigned:
				continue
		if button == null and prep.current().kind == "or_table_palpation":
			button = visible_button("PalpationComplete")
		elif button == null and prep.current().kind == "anesthesia_sensory_test" and not prep.flags.has("anesthesia_sensory_test_complete"):
			button = visible_button("AnesthesiaTestComplete")
		if button == null and prep.current().kind == "surgery_flow":
			if not prep.active_crisis.is_empty():
				if prep.awaiting_crisis_acknowledgement:
					button = visible_button("CrisisContinue")
				else:
					var best := ""
					var chance := -1
					for option in prep.crisis_rescue_options():
						if prep.crisis_rescue_chance(str(option.id)) > chance:
							best = str(option.id)
							chance = prep.crisis_rescue_chance(best)
					button = visible_button("CrisisRescue_" + best)
			elif prep.awaiting_flow_acknowledgement:
				button = visible_button("SurgeryFlowContinue")
			elif prep.awaiting_patient_acknowledgement:
				button = visible_button("SurgeryPatientContinue")
			elif prep.awaiting_patient_choice:
				if not shot_patient_choice:
					shot_patient_choice = true
					await shot("intraop_patient_interaction")
				var first_act_id := str(prep.active_patient_interaction.actions[0].id)
				button = visible_button("PatientInteraction_" + first_act_id)
			else:
				var flow_step: Dictionary = prep.surgery_flow_step()
				for option in flow_step.get("options", []):
					if flow_step.kind != "decision" or bool(option.get("correct", false)):
						button = visible_button("SurgeryStep_" + str(option.id))
						break
		if button == null and stage != "procedure_select":
			button = regular_action(prep, branch)
		expect(button != null, "%s: clickable button at %s (%s)" % [current_locale, stage, str(prep.last_error)])
		if button == null:
			break
		await click_native(button)
		route_steps.ordinary += 1
		if not prep.last_error.is_empty():
			expect(false, "%s: rejected regular action at %s: %s" % [current_locale, stage, prep.last_error])
			break
	expect(prep.surgery_success and not prep.surgery_aborted, current_locale + ": regular surgery reached success screen")
	if prep.surgery_success:
		await shot("result")
		if await click_id("SurgeryResultReturn"):
			await drain_overlays()
			expect(not app.game.admitted_patient(ACTOR), current_locale + ": regular surgery discharged Artoria")
			await shot("returned")

func walk_story_chapter(c: RefCounted, v: Control) -> void:
	var seen_phases := {}
	for _guard in range(360):
		if c.transition_pending or v.blackout_running:
			await create_timer(0.95).timeout
			await process_frame
			continue
		if c.story_phase.is_empty():
			break
		var phase := str(c.story_phase)
		if not seen_phases.has(phase) and c.story_index == 0:
			seen_phases[phase] = true
			if phase in ["consult", "night", "dark", "after", "success", "failure"]:
				await shot("story_" + phase)
		if current_locale == "en":
			var dlg: RichTextLabel = app.page.find_child("AdvancedStaffDialogue", true, false)
			if dlg != null:
				expect(cjk_re.search(dlg.text) == null, "en: zero CJK in advanced story phase " + phase)
		if visible_button("story_next") == null:
			await create_timer(0.95).timeout
			await process_frame
			if visible_button("story_next") == null:
				break
		if not await click_id("story_next"):
			break
		route_steps.advanced += 1

func advanced_route(watch_night: bool) -> void:
	route = "advanced"
	verify_all_advanced_pose_textures()
	if not await choose_invitation(true):
		return
	expect(app.screen == "advanced_referral", current_locale + ": advanced board opened from invitation")
	var c = app.advanced_controller
	var v: Control = app.page.get_node("AdvancedReferralView")
	var case_id := "case_advanced_staff_%s_%s" % [ACTOR, ADVANCED_SURGERY]
	if not await click_id(case_id):
		return
	expect(str(v.record.procedure_id) == ADVANCED_SURGERY, current_locale + ": Whipple case selected")
	await shot("team_picker")
	var selected := {}
	for role in c.ROLES:
		var picker: OptionButton = v.find_child("Team_" + str(role), true, false)
		if picker == null:
			continue
		for i in range(1, picker.item_count):
			var id := str(picker.get_item_metadata(i))
			if id != ACTOR and id not in selected.values() and not picker.is_item_disabled(i):
				picker.select(i)
				picker.item_selected.emit(i)
				selected[role] = id
				await process_frame
				break
	expect(c.valid_team(v.selected, int(c.schedule().operation_day)), current_locale + ": real team picker accepts selected roster (Artoria self-excluded)")
	if not await click_id("accept"):
		return
	expect(c.story_phase == "consult", current_locale + ": consultation starts")
	await walk_story_chapter(c, v)
	expect(c.night_choice, current_locale + ": consult reaches night choice")
	await shot("night_choice")
	if watch_night:
		if not await click_id("staff_watch"):
			return
		await walk_story_chapter(c, v)
	else:
		if not await click_id("staff_skip"):
			return
	for _i in range(6):
		if c.day_transition.is_empty():
			break
		await shot("day2_card")
		await press_space()
	expect(c.session != null, current_locale + ": advanced Whipple runner started")
	if c.session == null:
		return
	await shot("anesthesia_splash")
	if visible_button("AnesthesiaSplashContinue") != null:
		await click_id("AnesthesiaSplashContinue")
	await process_frame
	var expected := "res://assets/characters/artoria_staff_patient_v1/doc_artoria/advanced/abdominal.png"
	var table: TextureRect = v.find_child("AdvancedTeamPatientTable", true, false)
	expect(table != null and table.texture != null and str(table.texture.resource_path) == expected, current_locale + ": rendered abdominal OR table uses Artoria authored image")
	await shot("abdominal_table")
	if not await click_id("begin_timeout"):
		return
	for _i in range(7):
		if not await click_id("confirm_member"):
			return
	var session: RefCounted = c.session
	for i in range(700):
		if session == null or session.finished:
			break
		var target: Button = null
		if session.in_crisis():
			var best := ""
			var chance := -1
			for option in session.physiology.crisis_rescue_options():
				var candidate: Button = visible_button(str(option.id))
				if candidate == null:
					continue
				var score := int(option.get("success_chance", 0))
				if score > chance:
					best = str(option.id)
					chance = score
			if not best.is_empty():
				target = visible_button(best)
		for id in ["dialogue_next", "continue", "correct", "operate", "standard"]:
			if target != null:
				break
			target = visible_button(id)
			if target != null:
				break
		if target == null:
			for option in session.strategy_options():
				target = visible_button("strategy_" + str(option.id))
				if target != null:
					break
		if target == null:
			for node in v.find_children("*", "Button", true, false):
				if node.is_visible_in_tree() and not node.disabled and (str(node.name).begins_with("crisis_") or str(node.name).begins_with("rescue_")):
					target = node
					break
		expect(target != null, "%s: advanced action visible at stage %d" % [current_locale, session.index])
		if target == null:
			break
		if v.scroll.is_ancestor_of(target):
			v.scroll.ensure_control_visible(target)
			await process_frame
			await process_frame
		await click_native(target)
		route_steps.advanced += 1
		if i == 0 or (session.index in [2, 6] and i % 10 == 0):
			await shot("step_%02d" % session.index)
	expect(session.finished, current_locale + ": Whipple operation reaches terminal result")
	if session.finished:
		await shot("operation_result")
		var finish: Button = visible_button("finish")
		if finish != null:
			await click_native(finish)
		expect(c.story_phase in ["success", "failure"], current_locale + ": Day 3 result chapter entered")
		for _i in range(4):
			if c.day_transition.is_empty():
				break
			await shot("day3_card")
			await press_space()
		await walk_story_chapter(c, v)
		expect(not c.episode_active, current_locale + ": advanced episode settled")
		if visible_button("back") != null:
			await click_id("back")
		await shot("returned")

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			qa = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(qa)
	expect(DisplayServer.get_name() != "headless", "Native window driver active")
	DisplayServer.window_set_size(Vector2i(1280, 800))
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/artoria_staff_patient_native_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	await process_frame

	current_locale = "zh_CN"
	reset_fixture("zh_CN")
	await regular_route("general")
	if failures.is_empty():
		reset_fixture("zh_CN")
		await advanced_route(true)

	if failures.is_empty():
		current_locale = "en"
		reset_fixture("en")
		await regular_route("epidural")
	if failures.is_empty():
		reset_fixture("en")
		await advanced_route(false)

	var report := {
		"actor_id": ACTOR,
		"checks": checks,
		"failures": failures,
		"native_driver": DisplayServer.get_name(),
		"window_size": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y],
		"steps": route_steps,
		"mouse_inputs": input_counts.mouse,
		"space_inputs": input_counts.space,
		"screenshots_count": route_shots.size(),
		"screenshots": route_shots,
		"languages": ["zh_CN", "en"],
	}
	var f := FileAccess.open(qa + "/report.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "\t") + "\n")
	f.close()
	print("ARTORIA STAFF PATIENT NATIVE PLAYTEST: %d checks; %d failure(s); %d shots" % [checks, failures.size(), route_shots.size()])
	quit(1 if not failures.is_empty() else 0)
