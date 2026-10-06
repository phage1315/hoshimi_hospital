extends RefCounted
## VN presentation: brief dialogue, contextual choices, on-demand medical record.
static func render(app: Control, visit: RefCounted) -> void:
	var patient: Dictionary = app.content.find_record("patients", visit.definition.patient_id)
	var stage: Dictionary = visit.current()
	var line: Dictionary = visit.presentation()
	var speaker_id := str(line.speaker)
	if speaker_id == "outpatient_support":
		speaker_id = app.game.resolve_outpatient_support_actor()
	app.base(visit.definition.title, app.tx("ui.clinic.patient_header", "%s · %s岁    /    %s") % [patient.name, patient.age, stage.title], false, stage.background_id)
	app.button_at(app.tx("ui.common.return_map", "← 医院导览"), Vector2(1040, 88), Vector2(180, 44), app.show_map)
	var person: Dictionary = app.content.find_record("staff", speaker_id)
	var speaker_name: String = app.protagonist_name() if speaker_id == "player" else patient.name if speaker_id == patient.id else person.get("name", app.tx("ui.common.narrator", "旁白"))
	if not person.is_empty():
		app.add_portrait(person)
		var portrait = app.page.get_node_or_null("CharacterPortrait")
		if portrait != null:
			portrait.position = Vector2(745, 165)
			portrait.size = Vector2(450, 389)
	else:
		var undressed_exam := false
		for action_id in ["authoritative_full_undress", "gentle_full_undress", "threaten_full_undress"]:
			if visit.action_log.has(action_id):
				undressed_exam = true
				break
		app.add_portrait(patient, "shy", "examination" if undressed_exam else "outpatient")
		var portrait = app.page.get_node_or_null("CharacterPortrait")
		if portrait != null:
			portrait.position = Vector2(745, 165)
			portrait.size = Vector2(450, 389)
		else:
			app.label_at(patient.name, Vector2(880, 331), 32, Color("f4f0e6"), 280)
			app.label_at(app.tx("ui.clinic.outpatient", "门诊患者"), Vector2(884, 380), 17, Color("dce5e3"), 240)
	if not line.summary.is_empty():
		panel(app, Vector2(60, 182), Vector2(655, 52))
		app.label_at(line.summary, Vector2(80, 195), 19, Color("e8cfaa"), 620)
	if visit.completed():
		app.label_at(app.tx("ui.clinic.admitted", "✓ 已收住院"), Vector2(65, 275), 32, Color("f4f0e6"), 610)
		app.label_at(app.tx("ui.clinic.summary", "用时 %s 分钟 · 判断修正 %s 次") % [visit.minutes, visit.mistakes], Vector2(65, 332), 20, Color("dce5e3"), 620)
		app.button_at(app.tx("ui.clinic.go_ward", "前往病房 →"), Vector2(60, 409), Vector2(400, 54), app.show_location.bind("ward"))
	else:
		var choices: Array = visit.ui_actions()
		for i in range(choices.size()):
			var action: Dictionary = choices[i]
			var reason: String = "" if action.has("actions") else visit.blocked_reason(action)
			var button: Button = app.button_at(action.label, Vector2(60, 250 + i * 67), Vector2(655, 54), app.choose_clinic_action.bind(action.id))
			button.name = "Action_" + action.id
			button.disabled = not reason.is_empty()
			button.tooltip_text = reason
			button.add_theme_stylebox_override("disabled", app.panel_style(Color("24343b")))
			button.add_theme_color_override("font_disabled_color", Color("a0b1b5"))
			if not reason.is_empty():
				app.label_at(app.tx("ui.clinic.missing_clues", "待补齐线索"), Vector2(555, 266 + i * 67), 16, Color("a0b1b5"), 140)
			elif action.get("minutes", 0) > 0:
				app.label_at(app.tx("ui.common.minutes", "%s 分钟") % action.minutes, Vector2(590, 266 + i * 67), 16, Color("b9cecb"), 110)
	panel(app, Vector2(55, 558), Vector2(1170, 142))
	app.label_at(speaker_name, Vector2(82, 576), 22, Color("e8cfaa"), 1100)
	app.scrollable_text_at(line.text, Vector2(82, 612), Vector2(1100, 78), 23, Color("f4f0e6"), "ClinicDialogue")
	app.button_at(app.tx("ui.common.save", "保存"), Vector2(60, 713), Vector2(120, 40), app.save_progress)
	app.button_at(app.tx("ui.common.load", "读档"), Vector2(194, 713), Vector2(120, 40), app.request_load)
	if app.game.personal_nurse_system_unlocked:
		var chat_button: Button = app.button_at(app.tx("ui.personal_nurse.clinic_chat", "和专属护士聊两句"), Vector2(330, 713), Vector2(245, 40), app.show_personal_nurse_chatter)
		chat_button.name = "PersonalNurseClinicChat"
	var unread: int = max(0, visit.notes.size() - int(app.clinic_notes_seen.get(visit.definition.id, 0)))
	var caption: String = app.tx("ui.clinic.hide_record", "收起病历") if app.clinic_record_open else (app.tx("ui.clinic.new_records", "病历 · %s 条新记录") % unread if unread > 0 else app.tx("ui.clinic.show_record", "查看病历"))
	var toggle: Button = app.button_at(caption, Vector2(943, 713), Vector2(277, 40), app.toggle_clinic_record)
	toggle.name = "ToggleRecord"
	if app.clinic_record_open:
		render_record(app, visit, patient)

static func panel(app: Control, position: Vector2, dimensions: Vector2) -> Panel:
	var box := Panel.new()
	box.position = position
	box.size = dimensions
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_stylebox_override("panel", app.panel_style(Color(0.06, 0.15, 0.20, 0.96), Color("819593")))
	app.page.add_child(box)
	return box

static func render_record(app: Control, visit: RefCounted, patient: Dictionary) -> void:
	panel(app, Vector2(755, 178), Vector2(466, 361))
	app.label_at(app.tx("ui.clinic.record_title", "病历 / %s") % patient.name, Vector2(778, 196), 23, Color("e8cfaa"), 410)
	var scroll := ScrollContainer.new()
	scroll.name = "MedicalRecord"
	scroll.position = Vector2(775, 241)
	scroll.size = Vector2(423, 278)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	app.page.add_child(scroll)
	var record := Label.new()
	record.custom_minimum_size.x = 390
	record.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	record.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	record.add_theme_font_size_override("font_size", 18)
	record.add_theme_color_override("font_color", Color("e1e4db"))
	var lines: Array[String] = []
	for entry in visit.notes.values():
		lines.append("【%s】\n%s" % [entry.section, entry.text])
	record.text = app.tx("ui.clinic.no_records", "还没有记录。") if lines.is_empty() else "\n\n".join(lines)
	scroll.add_child(record)
