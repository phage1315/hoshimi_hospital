extends RefCounted
## Technical invitation UI. Character confirmation lines are optional data;
## awaiting-final-script profiles use a clearly labelled system confirmation.
static func reward_label(app: Control, actor_id: String, surgery_id: String) -> String:
	var count: int = app.game.staff_patient_practice_count(actor_id, surgery_id)
	var authored: Array = app.game.StaffPatient.dialogue(actor_id, app.game.patient_content_locale()).get("practice_labels", [])
	if authored.size() == 3:
		return str(authored[mini(2, count)])
	return app.tx("ui.staff_patient.reward_first", "首次练习 · 技术经验 100%") if count == 0 else app.tx("ui.staff_patient.reward_second", "第二次练习 · 技术经验 50%") if count == 1 else app.tx("ui.staff_patient.reward_repeat", "重复练习 · 技术经验 0%")

static func invite(app: Control, actor_id: String) -> void:
	if not app.game.can_invite_staff_patient(actor_id):
		app.show_notice(app.game.last_error)
		return
	var procedures: Array = app.game.staff_patient_available_procedures()
	if procedures.is_empty():
		app.show_notice(app.tx("ui.staff_patient.no_procedures", "当前没有已解锁术式。"))
		return
	var dialog := ConfirmationDialog.new()
	dialog.name = "StaffPatientInvitation"
	dialog.title = app.tx("ui.staff_patient.invite", "邀请手术")
	dialog.ok_button_text = app.tx("ui.staff_patient.confirm", "确认邀请并安排住院")
	dialog.cancel_button_text = app.tx("ui.common.cancel", "取消")
	# Autowrapped labels initially measure against a near-zero width. Without a
	# bounded content area that transient minimum can grow the window offscreen.
	# Keep the built-in confirmation footer outside the scrollable content.
	var viewport_size: Vector2 = app.get_viewport().get_visible_rect().size
	var popup_width := mini(760, int(viewport_size.x) - 48)
	var popup_height := mini(300, int(viewport_size.y) - 64)
	var scroll := ScrollContainer.new()
	scroll.name = "StaffPatientInvitationContent"
	scroll.custom_minimum_size = Vector2(popup_width - 32, popup_height - 80)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 12)
	var note := Label.new()
	note.text = app.tx("ui.staff_patient.pending_script", "系统确认：选择约定术式后直接入住病房。专属确认对白待定稿接入。")
	if not app.game.StaffPatient.dialogue(actor_id, app.game.patient_content_locale()).get("invitation_lines", []).is_empty():
		note.text = dialog.ok_button_text
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(note)
	var picker := OptionButton.new()
	picker.name = "StaffPatientProcedurePicker"
	picker.fit_to_longest_item = false
	picker.clip_text = true
	for procedure in procedures:
		picker.add_item("%s — %s" % [procedure.name, reward_label(app, actor_id, str(procedure.id))])
		picker.set_item_metadata(picker.item_count - 1, str(procedure.id))
		picker.get_popup().set_item_tooltip(picker.item_count - 1, picker.get_item_text(picker.item_count - 1))
	picker.tooltip_text = picker.get_item_text(picker.selected)
	picker.item_selected.connect(func(index: int): picker.tooltip_text = picker.get_item_text(index))
	box.add_child(picker)
	var rules := Label.new()
	rules.text = app.tx("ui.staff_patient.rules", "正反声望不变。非约定术式：技术经验 0，且不消耗练习次数。")
	rules.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(rules)
	scroll.add_child(box)
	dialog.add_child(scroll)
	app.add_child(dialog)
	dialog.confirmed.connect(func() -> void:
		# Release the exclusive picker before showing the authored confirmation.
		dialog.hide()
		var surgery_id := str(picker.get_item_metadata(picker.selected))
		if app.game.invite_staff_patient(actor_id, surgery_id):
			var line: String = app.game.staff_patient_invitation_line(actor_id, surgery_id)
			app.show_location("ward")
			if not line.is_empty():
				app.show_notice("%s\n%s" % [app.game.staff_record(actor_id).name, line])
		else:
			app.show_notice(app.game.last_error)
		dialog.queue_free()
	)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(popup_width, popup_height))

static func ward_row(app: Control, row: int) -> int:
	if app.game.active_staff_patient.is_empty():
		return row
	var admission: Dictionary = app.game.active_staff_patient
	var person: Dictionary = app.game.patient_definition(str(admission.staff_id))
	var surgery: Dictionary = app.game.surgery_definition(str(admission.procedure_id))
	var label := "%s · %s\n%s" % [person.name, surgery.name, reward_label(app, str(person.id), str(surgery.id))]
	app.label_at(label, Vector2(65, 393 + row * 72), 18, Color("e8cfaa"), 600).name = "StaffPatientWardRecord"
	var button: Button = app.button_at(app.tx("ui.staff_patient.continue", "探视 / 继续术前安排 →"), Vector2(700, 390 + row * 72), Vector2(515, 60), app.show_preop.bind(app.game.StaffPatient.PREOP_ID))
	button.name = "StaffPatientWardContinue"
	button.disabled = app.game.is_hospital_closed_day(int(app.game.display_schedule().day))
	return row + 1
