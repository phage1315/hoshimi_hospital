extends SceneTree
const View = preload("res://godot/ui/staff_patient_view.gd")
const Registry = preload("res://godot/systems/staff_patient_registry.gd")
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		app.game.reset()
		app.game.meet_staff("doc_sayaka")
		app.show_staff("doc_sayaka", "lounge")
		expect(app.page.get_node_or_null("StaffPatientInvite") == null, "Locked button visible")
		app.game.set_story_flag("sayaka_lv5_part_c_complete", true)
		app.game.set_story_flag("staff_as_patient_program_authorized", true)
		app.show_staff("doc_sayaka", "lounge")
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
			if picker.get_item_text(index).length() > picker.get_item_text(longest_index).length():
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
		expect(app.game.admitted_patient("doc_sayaka"), "Physical confirm click did not admit patient")
		if not app.game.admitted_patient("doc_sayaka"):
			app.free()
			quit(1)
			return
		var saw_confirmation := false
		for child in app.get_children():
			if child is AcceptDialog and child.visible:
				saw_confirmation = true
				expect(child.dialog_text.contains(app.game.staff_record("doc_sayaka").name), "Confirmation has patient speaker")
				child.hide()
				child.confirmed.emit()
		expect(saw_confirmation, "Authored invitation confirmation missing")
		await process_frame
		expect(app.game.admitted_patient("doc_sayaka") and app.page.get_node_or_null("StaffPatientWardRecord") != null, "Invitation did not show ward record")
		app.page.get_node("StaffPatientWardContinue").pressed.emit()
		await process_frame
		expect(app.game.active_preop_id == Registry.PREOP_ID and app.screen == "preop", "Ward button did not open standard runner")
		expect(app.page.get_node_or_null("CharacterPortrait") != null, "Staff patient portrait not resolved")
		var prep = app.game.preops[Registry.PREOP_ID]
		if locale == "en":
			expect(str(prep.patient_name).is_valid_identifier() == false and not str(prep.definition.title).contains("小夜香"), "English patient/title not localized")
		var rewards: Array = Registry.dialogue("doc_sayaka", locale).practice_labels
		expect(View.reward_label(app, "doc_sayaka", "surgery_appendix") == rewards[0], "First reward label wrong")
		app.game.staff_patient_practice_counts = {"doc_sayaka": {"surgery_appendix": 1}}
		expect(View.reward_label(app, "doc_sayaka", "surgery_appendix") == rewards[1], "Second reward label wrong")
		app.game.staff_patient_practice_counts.doc_sayaka.surgery_appendix = 3
		expect(View.reward_label(app, "doc_sayaka", "surgery_appendix") == rewards[2], "Repeat reward label wrong")
		app.game.reset()
		# Real UI render of every new explanation node, with a separate invitation.
		app.game.meet_staff("doc_sayaka")
		app.game.set_story_flag("sayaka_lv5_part_c_complete", true)
		app.game.set_story_flag("staff_as_patient_program_authorized", true)
		app.game.set_story_flag("aqua_vaginal_hysterectomy_teaching_complete", true)
		var admitted: bool = app.game.invite_staff_patient("doc_sayaka", "surgery_vaginal_hysterectomy")
		expect(admitted, "VH UI admission: " + app.game.last_error)
		if not admitted:
			continue
		app.show_preop(Registry.PREOP_ID)
		var vh = app.game.preops[Registry.PREOP_ID]
		app.preop_event({"kind": "action", "id": "explain_plan"})
		await process_frame
		var record: RichTextLabel = app.page.get_node_or_null("PreopRecordText")
		expect(record != null and record.text == vh.feedback and record.scroll_active, "Question visible and scrollable")
		app.preop_event({"kind": "action", "id": "graphic_answer"})
		var nodes: Dictionary = Registry.dialogue("doc_sayaka", locale).graphic_preop_by_procedure.surgery_vaginal_hysterectomy
		while vh.stage_id == "graphic_preop_dialogue":
			await process_frame
			var node: Dictionary = vh.graphic_preop_nodes[vh.graphic_preop_node_index]
			if nodes.has(node.id):
				var text: RichTextLabel = app.page.get_node_or_null("GraphicPreopDialogueText")
				expect(text != null and text.text == node.text and text.scroll_active, "UI exact node " + node.id)
				if OS.get_cmdline_user_args().has("--capture") and node.id in ["field", "bladder"]:
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png("/private/tmp/sap-v16-" + locale + "-" + str(node.id) + ".png")
			app.preop_event({"kind": "graphic_preop_next"})
		app.game.reset()
	app.free()
	print("STAFF PATIENT UI: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
