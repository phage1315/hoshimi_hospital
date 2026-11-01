extends "res://tools/serika_staff_patient_test.gd"
## Native rendered end-to-end regression. Test eligibility and date advance are in memory.
## Clinical results are produced by the real runner, never assigned by the fixture.
var overlay_counts := {}
func drain_overlays() -> void:
	for i in range(12):
		await process_frame
		var found := false
		for name in ["WardPreparationCGContinue", "WardPreparationSplashContinue", "AnesthesiaSplashContinue", "SurgeryCGContinue", "SurgeryVideoSkip"]:
			var button = app.page.find_child(name, true, false)
			if button != null and button.is_visible_in_tree():
				overlay_counts[name] = int(overlay_counts.get(name,0)) + 1
				button.pressed.emit(); found = true; break
		if not found: return
func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/serika-e2e-"+label+".png")
func run_operation(prep: RefCounted, selected_procedure: String = "surgery_breast_tumor", branch: String = "general", manual_ward: bool = false) -> bool:
	var preferred := ["brief_plan", "confirm_team", "perform_preparation", "to_changing", "change_scrubs", "scrub_hands", "enter_room", "team_check", "confirm_assistant_role", "confirm_scrub_role", "confirm_circulating_role", "acknowledge_procedure_mismatch", "choose_" + branch, "insist_without_anesthesia", "induction_reassure", "start_" + branch + "_surgery", "request_scalpel", "assistant_stabilize", "incise_" + branch, "execute_confirmed_procedure"]
	if manual_ward:
		preferred[2] = "begin_manual_ward_preparation"
		preferred.append_array(["ward_enema", "ack_ward_enema", "ward_skin_prep", "ack_ward_skin_prep", "ward_surgical_cap", "complete_manual_ward_preparation"])
	for iteration in range(250):
		await drain_overlays()
		if prep.surgery_success:
			return true
		if prep.stage_id in ["team", "preparation"]:
			for role in {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin", "ward_nurse": "nurse_yui"}:
				if not prep.team.has(role) and ((role == "ward_nurse") == (prep.stage_id == "preparation")):
					app.preop_event({"kind": "assign", "role": role, "staff_id": {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin", "ward_nurse": "nurse_yui"}[role]})
		var event := {}
		if prep.stage_id == "procedure_select":
			event = {"kind": "procedure", "id": selected_procedure}
		elif prep.current().kind == "or_table_palpation":
			event = {"kind": "or_table_palpation_complete"}
		elif prep.current().kind == "surgery_flow":
			if not prep.active_crisis.is_empty():
				if prep.awaiting_crisis_acknowledgement:
					event = {"kind":"crisis_acknowledge"}
				else:
					var best := ""
					var chance := -1
					for option in prep.crisis_rescue_options():
						if prep.crisis_rescue_chance(str(option.id)) > chance:
							best = str(option.id); chance = prep.crisis_rescue_chance(best)
					event = {"kind":"crisis_rescue","id":best}
			elif prep.awaiting_flow_acknowledgement:
				event = {"kind": "flow_acknowledge"}
			elif prep.awaiting_patient_acknowledgement:
				event = {"kind": "patient_acknowledge"}
			elif prep.awaiting_patient_choice:
				if prep.procedure_mismatch and prep.definition.get("agreement_required_interaction_ids", []).has(prep.active_patient_interaction.id):
					push_error("Mismatch selected agreement-only pool: " + str(prep.active_patient_interaction.id))
					return false
				event = {"kind": "patient_interaction_action", "id": prep.active_patient_interaction.actions[0].id}
			else:
				var step: Dictionary = prep.surgery_flow_step()
				for option in step.get("options", []):
					if step.kind != "decision" or bool(option.get("correct", false)):
						event = {"kind": "surgery_step", "id": option.id}
						break
		else:
			for id in preferred:
				for action in prep.current().get("actions", []):
					if str(action.id) == id and not prep.done.has(id) and prep.action_visible(action) and prep.action_reason(action).is_empty():
						event = {"kind": "action", "id": id}
						break
				if not event.is_empty():
					break
			if event.is_empty():
				for action in prep.current().get("actions", []):
					if prep.action_visible(action) and prep.action_reason(action).is_empty():
						event = {"kind": "action", "id": action.id}
						break
		if event.is_empty():
			push_error("Flow stopped at %s: %s / %s" % [prep.stage_id, event, prep.last_error])
			return false
		print("OP_STEP ", prep.stage_id, " ", event)
		app.preop_event(event)
		if not prep.last_error.is_empty():
			push_error("Rejected event " + str(event) + ": " + prep.last_error)
			return false
		await process_frame
		expect(not prep.surgery_aborted, "No abort: " + prep.last_error)
	return false

func run() -> void:
	seed(10931)
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/tmp/serika-e2e-unused-%s.json" % OS.get_process_id()
	root.add_child(app); await process_frame
	app.dialogue_auto_enabled = false
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale); app.configure_game_content()
		fixture(app.game)
		for person in app.content.collections.staff: app.game.meet_staff(person.id)
		# Suppress unrelated ambient events in this isolated regression fixture.
		app.game.micro_event_definitions.clear()
		app.show_staff("doc_serika", "lounge")
		var button: Button = app.page.get_node_or_null("StaffPatientInvite")
		expect(button != null, "Unlocked invitation button missing")
		if button == null:
			continue
		button.pressed.emit()
		await process_frame
		var dialog: ConfirmationDialog = app.get_node_or_null("StaffPatientInvitation")
		expect(dialog != null, "Invitation picker missing")
		if dialog == null:
			continue
		var picker: OptionButton = dialog.find_child("StaffPatientProcedurePicker", true, false)
		expect(picker != null and picker.item_count == app.game.staff_patient_available_procedures().size(), "Wrong selectable procedure list")
		for index in picker.item_count:
			expect(app.game.procedure_unlocked(str(picker.get_item_metadata(index))), "Picker exposed locked procedure")
		var longest_index := 0
		for index in picker.item_count:
			if str(picker.get_item_metadata(index)) == "surgery_appendix":
				longest_index = index
		picker.select(longest_index)
		picker.item_selected.emit(longest_index)
		# Let containers finish sorting before checking the actual clickable footer.
		for frame in range(5):
			await process_frame
		var ok_button: Button = dialog.get_ok_button()
		var cancel_button: Button = dialog.get_cancel_button()
		var dialog_bounds := Rect2(Vector2.ZERO, Vector2(dialog.size))
		var parent_bounds: Rect2 = app.get_viewport().get_visible_rect()
		expect(dialog.size.y <= parent_bounds.size.y - 40, "Invitation exceeds viewport height: " + str(dialog.size))
		expect(dialog.size.x <= parent_bounds.size.x - 40, "Invitation exceeds viewport width: " + str(dialog.size))
		if dialog.is_embedded():
			expect(parent_bounds.encloses(Rect2(Vector2(dialog.position), Vector2(dialog.size))), "Invitation extends outside game viewport")
		expect(ok_button.is_visible_in_tree() and dialog_bounds.encloses(ok_button.get_global_rect()), "Confirm button outside dialog")
		expect(cancel_button.is_visible_in_tree() and dialog_bounds.encloses(cancel_button.get_global_rect()), "Cancel button outside dialog")
		var content_area: ScrollContainer = dialog.get_node("StaffPatientInvitationContent")
		expect(content_area.get_global_rect().end.y <= ok_button.get_global_rect().position.y, "Content covers confirmation footer")
		expect(picker.tooltip_text == picker.get_item_text(longest_index), "Full selected procedure text is not accessible")
		print("INVITE_LAYOUT ", locale, " window=", dialog.size, " confirm=", ok_button.get_global_rect())
		if OS.get_cmdline_user_args().has("--capture"):
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/private/tmp/sap-invite-" + locale + ".png")
		# Route a real mouse click through the dialog's viewport, not confirmed.emit().
		var click_position := ok_button.get_global_rect().get_center()
		var input_viewport: Viewport = dialog
		if dialog.is_embedded():
			input_viewport = app.get_viewport()
			click_position += Vector2(dialog.position)
		var motion := InputEventMouseMotion.new()
		motion.position = click_position
		motion.global_position = click_position
		input_viewport.push_input(motion, true)
		await process_frame
		for down in [true, false]:
			var click := InputEventMouseButton.new()
			click.position = click_position
			click.global_position = click_position
			click.button_index = MOUSE_BUTTON_LEFT
			click.pressed = down
			input_viewport.push_input(click, true)
			await process_frame
		await process_frame
		expect(app.game.admitted_patient("doc_serika"), "Physical confirm click did not admit patient")
		if not app.game.admitted_patient("doc_serika"):
			app.free()
			quit(1)
			return
		var saw_confirmation := false
		for child in app.get_children():
			if child is AcceptDialog and child.visible:
				saw_confirmation = true
				expect(child.dialog_text.contains(app.game.staff_record("doc_serika").name), "Confirmation has patient speaker")
				child.hide()
				child.confirmed.emit()
		expect(saw_confirmation, "Authored invitation confirmation missing")
		await process_frame
		expect(app.game.admitted_patient("doc_serika") and app.page.get_node_or_null("StaffPatientWardRecord") != null, "Invitation did not show ward record")
		app.page.get_node("StaffPatientWardContinue").pressed.emit()
		await process_frame
		expect(app.game.active_preop_id == Registry.PREOP_ID and app.screen == "preop", "Ward button did not open standard runner")
		expect(app.page.get_node_or_null("CharacterPortrait") != null, "Staff patient portrait not resolved")
		var prep = app.game.preops[Registry.PREOP_ID]

		await capture(locale+"-ward")
		expect(await run_operation(prep, "surgery_appendix", "general", true), "Actual surgery completes " + locale)
		if failures: quit(1); return
		await drain_overlays()
		await capture(locale+"-result")
		var settle = app.page.find_child("SurgeryResultReturn", true, false)
		expect(settle != null, "Actual result settlement button")
		if settle == null: quit(1); return
		settle.pressed.emit(); await process_frame
		var growth = app.page.find_child("SurgeryGrowthContinue", true, false)
		if growth: growth.pressed.emit()
		await process_frame
		expect(not app.game.admitted_patient(Flow.ACTOR), "Patient discharged after surgery")
		expect(app.game.staff_patient_first_completion_days.has(Flow.ACTOR), "First surgery fact recorded")
		expect(not Flow.eligible(app.game), "No callback on surgery day")
		app.game.set_test_time(app.game.day_number_for_date("2025-06-09"),540)
		expect(Flow.eligible(app.game), "Next working day callback eligible")
		await play_callback(locale)
		for child in app.get_children():
			if child is AcceptDialog and child.visible:
				expect(false, "Unexpected notice: " + child.dialog_text)
				child.hide()
				child.confirmed.emit()
		await process_frame
		await capture(locale+"-callback-complete")
		if failures: quit(1); return
	var report = {"checks":checks,"failures":failures,"callback_nodes":rendered,"native":DisplayServer.get_name() != "headless","procedure":"surgery_appendix","anesthesia":"general","manual_ward":true,"overlays":overlay_counts,"languages":["zh_CN","en"]}
	var path = "res://docs/qa/serika_patient_assets_2026_10_31/e2e_"+("headless" if DisplayServer.get_name() == "headless" else "native")+".json"
	var file = FileAccess.open(path, FileAccess.WRITE); file.store_string(JSON.stringify(report,"\t"));file.close()
	print("SERIKA E2E ",JSON.stringify(report));quit(1 if failures else 0)
