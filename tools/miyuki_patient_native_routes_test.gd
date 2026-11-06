extends "res://tools/miyuki_lv5_native_test.gd"
## Visible-window route check. Only settled Lv5/clearance facts and team picks are
## prepared in memory; all route transitions and operation actions use UI input.
const Setup = preload("res://godot/systems/advanced_staff_patient_test_setup.gd")
const Present = preload("res://godot/systems/advanced_presentation.gd")
var route := ""
var current_locale := ""
var route_steps := {"ordinary": 0, "advanced": 0}
var route_shots := []

func shot(label: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	var path := qa + "/" + current_locale + "_" + route + "_" + label + ".png"
	root.get_texture().get_image().save_png(path)
	route_shots.append(path)

func visible_button(id: String) -> Button:
	var button: Button = app.page.find_child(id, true, false)
	if button == null or not button.is_visible_in_tree() or button.disabled: return null
	return button

func click_id(id: String) -> bool:
	var button := visible_button(id)
	expect(button != null, "Visible enabled button: " + id + " at " + route)
	if button == null: return false
	await click_native(button)
	return true

func click_popup(button: Button, dialog: Window) -> void:
	var point: Vector2 = button.get_global_rect().get_center()
	var viewport: Viewport = dialog
	if dialog.is_embedded():
		viewport = app.get_viewport()
		point += Vector2(dialog.position)
	var motion := InputEventMouseMotion.new()
	motion.position = point; motion.global_position = point
	viewport.push_input(motion, true)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point; event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT; event.pressed = down
		viewport.push_input(event, true)
		await process_frame
	await process_frame
	input_counts.mouse += 1

func click_point(point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point; motion.global_position = point
	root.push_input(motion, true)
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point; event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT; event.pressed = down
		root.push_input(event, true)
		await process_frame
	input_counts.mouse += 1

func press_space() -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_SPACE; event.pressed = down
		root.push_input(event, true)
		await process_frame
	input_counts.space += 1

func close_notice() -> void:
	for child in app.get_children():
		if child is AcceptDialog and child.visible and child.name != "StaffPatientInvitation":
			var ok: Button = child.get_ok_button()
			if ok != null and ok.is_visible_in_tree(): await click_popup(ok, child)
			else: child.hide()
	await process_frame

func reset_fixture(locale: String) -> void:
	expect(app.content.load_all(locale), "Load locale " + locale)
	app.configure_game_content()
	Setup.fixture(app.game, "nurse_yui")
	app.game.micro_event_definitions.clear()
	app.dialogue_auto_enabled = false
	app.game.unlock_procedure("surgery_appendix")
	if not app.game.advanced_referral_facts.has("procedures"):
		app.game.advanced_referral_facts["procedures"] = {}
	app.game.advanced_referral_facts["procedures"]["surgery_adv_ebstein_cone_reconstruction"] = "CLEARED"
	expect(app.game.staff_patient_unlocked("nurse_yui") and app.game.can_invite_staff_patient("nurse_yui"), "Settled Lv5 facts open Miyuki patient routes")

func select_picker(picker: OptionButton, actor_id: String) -> void:
	var wanted := -1
	for i in range(picker.item_count):
		if str(picker.get_item_metadata(i)) == actor_id: wanted = i; break
	expect(wanted >= 0, "Candidate in team picker: " + actor_id)
	if wanted < 0: return
	# Team selection is a fixture setup through the real picker signal. The route
	# under test begins at confirmation; no save or production unlock is changed.
	picker.select(wanted)
	picker.item_selected.emit(wanted)
	await process_frame

func choose_invitation(advanced: bool) -> bool:
	app.show_staff("nurse_yui", "station")
	await process_frame
	if not await click_id("StaffPatientInvite"): return false
	var dialog: ConfirmationDialog = app.get_node_or_null("StaffPatientInvitation")
	expect(dialog != null and dialog.visible, "Invitation dialog opens")
	if dialog == null: return false
	await shot("invite")
	if advanced:
		var advanced_button: Button = dialog.find_child("AdvancedStaffPatientInvitation", true, false)
		expect(advanced_button != null and not advanced_button.disabled, "Advanced invitation is eligible")
		if advanced_button == null or advanced_button.disabled: return false
		await click_popup(advanced_button, dialog)
		await process_frame
		return app.screen == "advanced_referral"
	var picker: OptionButton = dialog.find_child("StaffPatientProcedurePicker", true, false)
	expect(picker != null, "Ordinary procedure selector exists")
	if picker == null: return false
	await select_picker(picker, "surgery_appendix")
	await click_popup(dialog.get_ok_button(), dialog)
	await close_notice()
	expect(app.game.admitted_patient("nurse_yui"), "Miyuki admitted from visible invitation")
	if not app.game.admitted_patient("nurse_yui"): return false
	await shot("ward_record")
	return await click_id("StaffPatientWardContinue")

func action_button_at(position: Vector2) -> Button:
	for candidate in app.page.find_children("*", "Button", true, false):
		if candidate.is_visible_in_tree() and not candidate.disabled and candidate.position.distance_to(position) < 3:
			return candidate
	return null

func drain_overlays() -> void:
	for i in range(16):
		await process_frame
		if app.screen == "preop_transition_video":
			await click_point(Vector2(640, 380))
			continue
		var found := false
		for id in ["StaffRoleRewardContinue", "WardPreparationCGContinue", "WardPreparationSplashContinue", "AnesthesiaSplashContinue", "SurgeryCGContinue", "SurgeryVideoSkip", "SurgeryGrowthContinue"]:
			if visible_button(id) != null:
				await click_id(id)
				found = true
				break
		if not found: return

func regular_action(prep: RefCounted) -> Button:
	var preferred := ["brief_plan", "confirm_team", "begin_manual_ward_preparation", "ward_enema", "ack_ward_enema", "ward_skin_prep", "ack_ward_skin_prep", "ward_surgical_cap", "complete_manual_ward_preparation", "to_changing", "change_scrubs", "scrub_hands", "enter_room", "team_check", "confirm_assistant_role", "confirm_scrub_role", "confirm_circulating_role", "choose_general", "induction_reassure", "start_general_surgery", "request_scalpel", "assistant_stabilize", "incise_general", "execute_confirmed_procedure"]
	for id in preferred:
		var candidate := visible_button("PreopAction_" + id)
		if candidate != null: return candidate
	for action in prep.current().get("actions", []):
		var candidate := visible_button("PreopAction_" + str(action.id))
		if candidate != null: return candidate
	return null

func regular_route() -> void:
	route = "ordinary"
	if not await choose_invitation(false): return
	expect(app.screen == "preop", "Ward continues to regular preop")
	var prep: RefCounted = app.game.preops.get(Registry.PREOP_ID)
	if prep == null: return
	await shot("preop_start")
	var seen := {}
	for step in range(340):
		await drain_overlays()
		if prep.surgery_success or prep.surgery_aborted: break
		var stage := str(prep.stage_id)
		if not seen.has(stage):
			seen[stage] = true
			if stage in ["ward_visit", "ward_preparation", "procedure_select", "anesthesia", "incision_ready", "surgery_flow"]:
				await shot(stage)
		expect(not app.game.can_save_progress(), "No save in regular route " + stage)
		var button: Button = null
		if stage == "procedure_select":
			button = visible_button("Procedure_surgery_appendix")
		elif stage in ["team", "preparation"]:
			var assigned := false
			for role in ["assistant_surgeon", "scrub_nurse", "circulating_nurse", "ward_nurse"]:
				if (role == "ward_nurse") != (stage == "preparation") or prep.team.has(role): continue
				var picker: OptionButton = app.page.get_node_or_null("Role_" + role)
				if picker != null:
					for i in range(1, picker.item_count):
						if not picker.is_item_disabled(i):
								picker.select(i); picker.item_selected.emit(i); await process_frame; assigned = true; break
					break
			if assigned: continue
		if button == null and prep.current().kind in ["or_table_palpation", "anesthesia_sensory_test"]:
			button = visible_button("PalpationComplete") if prep.current().kind == "or_table_palpation" else visible_button("AnesthesiaTestComplete")
		if button == null and prep.current().kind == "surgery_flow":
			if not prep.active_crisis.is_empty():
				if prep.awaiting_crisis_acknowledgement: button = action_button_at(Vector2(60,325))
				else:
					var best := ""; var chance := -1
					for option in prep.crisis_rescue_options():
						if prep.crisis_rescue_chance(str(option.id)) > chance:
							best = str(option.id); chance = prep.crisis_rescue_chance(best)
					button = visible_button("CrisisRescue_" + best)
			elif prep.awaiting_flow_acknowledgement: button = visible_button("SurgeryFlowContinue")
			elif prep.awaiting_patient_acknowledgement: button = action_button_at(Vector2(60,325))
			elif prep.awaiting_patient_choice:
				button = action_button_at(Vector2(60,305))
			else:
				var flow_step: Dictionary = prep.surgery_flow_step()
				for option in flow_step.get("options", []):
					if flow_step.kind != "decision" or bool(option.get("correct", false)):
						button = visible_button("SurgeryStep_" + str(option.id)); break
		if button == null and stage != "procedure_select": button = regular_action(prep)
		if button == null:
			var listing := []
			for node in app.page.find_children("*", "Button", true, false):
				if node.is_visible_in_tree(): listing.append(str(node.name) + "=" + str(node.disabled))
			print("REGULAR STALL ", stage, " team=", prep.team, " actions=", prep.current().get("actions", []), " buttons=", listing)
		expect(button != null, "Regular action clickable at " + stage + ": " + str(prep.last_error))
		if button == null: break
		await click_native(button)
		route_steps.ordinary += 1
		if not prep.last_error.is_empty():
			expect(false, "Rejected regular action at " + stage + ": " + prep.last_error)
			break
	expect(prep.surgery_success and not prep.surgery_aborted, "Regular surgery reached success screen")
	if prep.surgery_success:
		await shot("result")
		if await click_id("SurgeryResultReturn"):
			await drain_overlays()
			expect(not app.game.admitted_patient("nurse_yui"), "Regular surgery discharged Miyuki")
			await shot("returned")

func advanced_route() -> void:
	route = "advanced"
	if not await choose_invitation(true): return
	expect(app.screen == "advanced_referral", "Advanced board opened from invitation")
	var c = app.advanced_controller
	var v: Control = app.page.get_node("AdvancedReferralView")
	var case_id := "case_advanced_staff_nurse_yui_surgery_adv_ebstein_cone_reconstruction"
	if not await click_id(case_id): return
	expect(str(v.record.procedure_id) == "surgery_adv_ebstein_cone_reconstruction", "Chest case selected")
	await shot("team_picker")
	var selected := {}
	for role in c.ROLES:
		var picker: OptionButton = v.find_child("Team_" + str(role), true, false)
		if picker == null: continue
		for i in range(1, picker.item_count):
			var id := str(picker.get_item_metadata(i))
			if id != "nurse_yui" and id not in selected.values() and not picker.is_item_disabled(i):
				picker.select(i); picker.item_selected.emit(i); selected[role] = id; await process_frame; break
	expect(c.valid_team(v.selected, int(c.schedule().operation_day)), "Real team picker accepts selected roster")
	if not await click_id("accept"): return
	expect(c.story_phase == "consult", "Consultation starts")
	await shot("consult")
	for i in range(220):
		if c.story_phase.is_empty(): break
		if not await click_id("story_next"): break
		route_steps.advanced += 1
	expect(c.night_choice, "Consult reaches night choice")
	if not await click_id("staff_skip"): return
	for i in range(5):
		if c.day_transition.is_empty(): break
		await press_space()
	if not c.day_transition.is_empty():
		var e := InputEventKey.new(); e.keycode = KEY_SPACE; e.pressed = true; root.push_input(e, true)
		e.pressed = false; root.push_input(e, true)
		await process_frame
	expect(c.session != null, "Advanced chest runner started")
	if c.session == null: return
	await shot("anesthesia_splash")
	if visible_button("AnesthesiaSplashContinue") != null: await click_id("AnesthesiaSplashContinue")
	await process_frame
	var patient: Dictionary = Present.patient(c.state().appointment.case, app.game, false)
	var expected := "res://assets/characters/advanced_staff_patient_v1/nurse_yui/chest.png"
	expect(str(patient.visuals.portraits.team_confirmation) == expected.trim_prefix("res://"), "Chest procedure resolves authored runtime image")
	var table: TextureRect = v.find_child("AdvancedTeamPatientTable", true, false)
	expect(table != null and table.texture != null and str(table.texture.resource_path) == expected, "Rendered chest table uses authored image")
	await shot("chest_table")
	if not await click_id("begin_timeout"): return
	for i in range(7):
		if not await click_id("confirm_member"): return
	var session: RefCounted = c.session
	for i in range(700):
		if session == null or session.finished: break
		var target: Button = null
		if session.in_crisis():
			var best := ""
			var chance := -1
			for option in session.physiology.crisis_rescue_options():
				var candidate: Button = visible_button(str(option.id))
				if candidate == null: continue
				var score := int(option.get("success_chance", 0))
				if score > chance: best = str(option.id); chance = score
			if not best.is_empty(): target = visible_button(best)
		for id in ["dialogue_next", "continue", "correct", "operate", "standard"]:
			if target != null: break
			target = visible_button(id)
			if target != null: break
		if target == null:
			for option in session.strategy_options():
				target = visible_button("strategy_" + str(option.id))
				if target != null: break
		if target == null:
			for node in v.find_children("*", "Button", true, false):
				if node.is_visible_in_tree() and not node.disabled and (str(node.name).begins_with("crisis_") or str(node.name).begins_with("rescue_")):
					target = node; break
		if target == null:
			var listing := []
			for node in app.page.find_children("*", "Button", true, false):
				if node.is_visible_in_tree(): listing.append(str(node.name) + "=" + str(node.disabled))
			print("ADVANCED STALL ", session.index, " kind=", session.current().kind, " pending=", session.pending_rescue, " crisis=", session.in_crisis(), " ack=", session.awaiting_ack, " buttons=", listing)
		expect(target != null, "Advanced action visible at stage " + str(session.index))
		if target == null: break
		if v.scroll.is_ancestor_of(target):
			v.scroll.ensure_control_visible(target)
			await process_frame
			await process_frame
		var before := str(session.index) + ":" + str(session.awaiting_ack) + ":" + str(session.pending_rescue) + ":" + str(session.in_crisis()) + ":" + str(session.operative_dialogue.current(session).get("id", ""))
		var button_name := str(target.name)
		await click_native(target)
		route_steps.advanced += 1
		if i % 100 == 99: print("ADVANCED PROGRESS ", current_locale, " ", i, " ", before, " -> ", session.index, " button=", button_name)
		if i == 0 or session.index in [1, 5, 10] and i % 12 == 0: await shot("step_%02d" % session.index)
	print("ADVANCED END ", current_locale, " index=", session.index, " finished=", session.finished, " ack=", session.awaiting_ack, " crisis=", session.in_crisis(), " dialogue=", session.operative_dialogue.current(session))
	expect(session.finished, "Chest operation reaches terminal result")
	if session.finished:
		await shot("operation_result")
		var finish: Button = visible_button("finish")
		if finish != null: await click_native(finish)
		expect(c.story_phase in ["success", "failure"], "Day 3 result chapter entered")
		if not c.day_transition.is_empty():
			var key := InputEventKey.new(); key.keycode = KEY_SPACE; key.pressed = true; root.push_input(key, true)
			key.pressed = false; root.push_input(key, true); await process_frame
		for i in range(220):
			if c.story_phase.is_empty(): break
			if not await click_id("story_next"): break
		expect(not c.episode_active, "Advanced episode settled and returned to board")
		await shot("returned")

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): qa = arg.trim_prefix("--out=")
	assert(not qa.is_empty())
	DirAccess.make_dir_recursive_absolute(qa)
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/miyuki_patient_native_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		current_locale = locale
		if not OS.get_cmdline_user_args().has("--advanced-only"):
			reset_fixture(locale)
			await regular_route()
			if failures: break
		reset_fixture(locale)
		await advanced_route()
		if failures: break
	var report := {"checks": checks, "failures": failures, "native": DisplayServer.get_name() != "headless", "steps": route_steps, "screenshots": route_shots, "mouse_inputs": input_counts.mouse, "languages": ["zh_CN", "en"]}
	var f := FileAccess.open(qa + "/report.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "\t")); f.close()
	print("MIYUKI PATIENT NATIVE: ", JSON.stringify(report))
	quit(1 if failures else 0)
