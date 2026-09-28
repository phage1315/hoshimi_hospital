extends RefCounted
const StageArt = preload("res://godot/ui/preop_stage_art.gd")
const UI = preload("res://godot/ui/clinic_view.gd")

static func render(app: Control, prep: RefCounted) -> void:
	var patient: Dictionary = app.content.find_record("patients", prep.definition.patient_id)
	var stage: Dictionary = prep.current()
	var flow_step: Dictionary = prep.surgery_flow_step() if stage.kind == "surgery_flow" else {}
	var stage_title: String = str(flow_step.get("title", stage.title))
	var transition_title: String = "患者术中回应" if prep.feedback_speaker == "patient" else "术中阶段记录"
	var patient_event_visible: bool = stage.kind == "surgery_flow" and (prep.awaiting_patient_choice or prep.awaiting_patient_acknowledgement)
	var page_title: String = transition_title if patient_event_visible else "术中团队回应" if stage.kind == "surgery_flow" and prep.awaiting_flow_acknowledgement else "术中团队配合" if stage.kind == "surgery_flow" else "手术室里的回应" if stage.kind in ["interaction", "surgery_complete"] else prep.definition.title
	var operative_scene: bool = stage.scene == "operating_room" and prep.flags.has("incision_made") and not prep.operative_background_id.is_empty()
	var active_background_id: String = prep.operative_background_id if operative_scene else stage.background_id
	app.base(page_title, "%s / %s" % [patient.name, stage_title], false, active_background_id)
	var map_action: Callable = app.finish_surgery_and_return if prep.surgery_success else app.show_map
	var map_button: Button = app.button_at("← 医院导览", Vector2(1040, 88), Vector2(180, 44), map_action)
	if prep.surgery_in_progress():
		map_button.disabled = true
		map_button.tooltip_text = "手术进行中，完成本次手术后才能离开手术室。"
	var speaking_staff: Dictionary = prep.presentation_staff()
	# Operating-table art is an intentional framed inset. Ward patients and staff
	# are transparent character cutouts and sit directly over the room background.
	if not operative_scene and speaking_staff.is_empty() and stage.scene == "operating_room":
		var table_frame := UI.panel(app, Vector2(755, 180), Vector2(466, 362))
		table_frame.name = "OperatingTableFrame"
	var art: Control = null
	if not operative_scene:
		art = StageArt.new()
		art.name = "PreopStageArt"
		art.position = Vector2(760, 178)
		art.size = Vector2(450, 365)
		art.scene_id = stage.scene
		art.anxiety = prep.anxiety
		art.changed = prep.flags.has("changed")
		app.page.add_child(art)
	var show_staff_portrait: bool = not speaking_staff.is_empty() and (not operative_scene or (stage.kind == "surgery_flow" and prep.awaiting_flow_acknowledgement))
	var show_intraoperative_patient: bool = operative_scene and speaking_staff.is_empty() and (stage.kind != "surgery_flow" or prep.awaiting_patient_choice or prep.awaiting_patient_acknowledgement)
	if show_staff_portrait:
		if art != null:
			art.visible = false
		var staff_outfit := operating_room_outfit(speaking_staff) if stage.scene == "operating_room" else str(speaking_staff.visuals.default_outfit)
		var staff_expression := "focused" if stage.scene == "operating_room" else "smile"
		var staff_portraits: Dictionary = speaking_staff.get("visuals", {}).get("portraits", {})
		if prep.staff_has_low_surgery_proficiency(str(speaking_staff.id)) and staff_portraits.has(staff_outfit + "/worried"):
			staff_expression = "worried"
		app.add_portrait(speaking_staff, staff_expression, staff_outfit)
		var portrait = app.page.get_node_or_null("CharacterPortrait")
		if portrait != null:
			portrait.name = "StaffInteractionPortrait"
			portrait.position = Vector2(760, 185)
			portrait.size = Vector2(450, 310)
		app.label_at("%s · %s" % [speaking_staff.name, prep.presentation_staff_role()], Vector2(785, 508), 18, Color("f4f0e6"), 410)
	elif show_intraoperative_patient:
		var intraoperative_expression := intraoperative_patient_expression(prep)
		app.add_portrait(patient, intraoperative_expression, "intraoperative")
		var portrait = app.page.get_node_or_null("CharacterPortrait")
		if portrait != null:
			portrait.name = "IntraoperativePatientPortrait"
			portrait.position = Vector2(760, 185)
			portrait.size = Vector2(450, 310)
		app.label_at("%s · %s" % [patient.name, prep.patient_state_text()], Vector2(785, 508), 18, Color("f4f0e6"), 410)
	elif not operative_scene:
		var use_examination_portrait := manual_ward_examination_portrait(prep, stage)
		var patient_expression := "shy" if use_examination_portrait else expression_for_patient(prep, stage)
		var patient_outfit := "examination" if use_examination_portrait else "operating_table" if stage.scene == "operating_room" else "ward"
		if stage.scene in ["ward", "operating_room"] and patient.get("visuals", {}).get("portraits", {}).has(patient_outfit + "/" + patient_expression):
			art.visible = false
			app.add_portrait(patient, patient_expression, patient_outfit)
			var portrait = app.page.get_node_or_null("CharacterPortrait")
			if portrait != null:
				portrait.position = Vector2(760, 185)
				portrait.size = Vector2(450, 310)
		var state_text: String = prep.patient_state_text() if stage.scene == "operating_room" else prep.mood_text()
		app.label_at("%s · %s" % [patient.name, state_text], Vector2(785, 508), 18, Color("f4f0e6"), 410)

	var action_y := 255
	var action_spacing := 72
	match stage.kind:
		"team":
			app.label_at("主刀 / 你", Vector2(62, 190), 21, Color("e8cfaa"), 640)
			for i in range(prep.definition.roles.size()):
				role_picker(app, prep, prep.definition.roles[i], 244 + i * 75)
			app.label_at("未进团队的护士将负责病房准备。", Vector2(65, 460), 16, Color("c2d2cc"), 640)
			action_y = 492
		"preparation":
			role_picker(app, prep, prep.definition.ward_role, 190)
			app.label_at("必做：核对资料与准备状态", Vector2(65, 261), 20, Color("e8cfaa"), 650)
			for i in range(prep.definition.preparations.size()):
				var item: Dictionary = prep.definition.preparations[i]
				var check := CheckButton.new()
				check.name = "Preparation_" + item.id
				check.text = "%s  ·  %s 分钟" % [item.label, item.minutes]
				check.position = Vector2(60, 299 + i * 48)
				check.size = Vector2(650, 43)
				check.button_pressed = prep.selected_preparations.has(item.id)
				check.disabled = not check.button_pressed and prep.selected_preparations.size() >= prep.definition.max_optional_preparations
				check.toggled.connect(func(_pressed: bool): app.preop_event({"kind": "toggle", "id": item.id}))
				app.page.add_child(check)
			var instruction: String = "额外照顾 %s / %s · 选择由护士完成，或由你亲手执行" % [prep.selected_preparations.size(), prep.definition.max_optional_preparations]
			if not prep.team.has(prep.definition.ward_role.id):
				instruction = "请先在上方指派病房准备护士，才能执行准备。"
			app.label_at(instruction, Vector2(65, 451), 17, Color("e8cfaa"), 640)
			action_y = 492
		"changing":
			app.label_at("服装：%s  /  刷手：%s" % ["手术服" if prep.flags.has("changed") else "日常服装", "完成" if prep.flags.has("hands_ready") else "待完成"], Vector2(65, 195), 21, Color("e8cfaa"), 655)
		"surgery_select":
			app.label_at("术式耗时会立即计入工作日时间。", Vector2(65, 183), 19, Color("e8cfaa"), 640)
			var procedure_scroll := ScrollContainer.new()
			procedure_scroll.name = "ProcedureList"
			procedure_scroll.position = Vector2(60, 220)
			procedure_scroll.size = Vector2(655, 320)
			var procedure_list := VBoxContainer.new()
			procedure_list.custom_minimum_size.x = 625
			procedure_list.add_theme_constant_override("separation", 8)
			procedure_scroll.add_child(procedure_list)
			app.page.add_child(procedure_scroll)
			for surgery in prep.surgery_options():
				var procedure_button := Button.new()
				procedure_button.text = "%s　·　%s" % [surgery.name, prep.duration_text(int(surgery.duration_minutes))]
				procedure_button.custom_minimum_size = Vector2(625, 50)
				procedure_button.pressed.connect(app.preop_event.bind({"kind": "procedure", "id": surgery.id}))
				procedure_button.name = "Procedure_" + surgery.id
				procedure_list.add_child(procedure_button)
			action_y = 900
		"interaction":
			app.label_at("麻醉：" + prep.anesthesia, Vector2(65, 183), 19, Color("e8cfaa"), 640)
			metric(app, "恐惧", prep.fear, Vector2(65, 218), Color("d47f79"))
			metric(app, "痛苦", prep.pain, Vector2(380, 218), Color("d6a06c"))
			metric(app, "尊严", prep.dignity, Vector2(65, 258), Color("79a9c9"))
			metric(app, "配合", prep.cooperation_value(), Vector2(380, 258), Color("7eb696"))
			action_y = 305
			action_spacing = 58
		"surgery_flow":
			var choice_panel := UI.panel(app, Vector2(42, 164), Vector2(700, 370))
			choice_panel.name = "SurgeryChoicePanel"
			var flow: Array = prep.surgery_flow_steps()
			app.label_at("%s · 步骤 %s / %s" % [prep.procedure_name, prep.procedure_step_index + 1, flow.size()], Vector2(65, 183), 19, Color("e8cfaa"), 640)
			if prep.awaiting_patient_choice:
				metric(app, "恐惧", prep.fear, Vector2(65, 215), Color("d47f79"))
				metric(app, "痛苦", prep.pain, Vector2(380, 215), Color("d6a06c"))
				metric(app, "尊严", prep.dignity, Vector2(65, 250), Color("79a9c9"))
				metric(app, "配合", prep.cooperation_value(), Vector2(380, 250), Color("7eb696"))
				action_y = 288
				action_spacing = 58
				for action in prep.active_patient_interaction.get("actions", []):
					var patient_action: Button = app.button_at(action.label, Vector2(60, action_y), Vector2(655, 50), app.preop_event.bind({"kind": "patient_interaction_action", "id": action.id}))
					patient_action.name = "PatientInteraction_" + action.id
					emphasize_flow_button(app, patient_action)
					action_y += action_spacing
			elif prep.awaiting_patient_acknowledgement:
				var transition_prompt: String = "先确认患者的这次回应，再进入下一项操作。" if prep.feedback_speaker == "patient" else "确认本阶段记录，再进入下一项操作。"
				app.label_at(transition_prompt, Vector2(65, 220), 20, Color("e1e4db"), 650)
				var patient_continue: Button = app.button_at("继续下一步手术", Vector2(60, 310), Vector2(655, 54), app.preop_event.bind({"kind": "patient_acknowledge"}))
				patient_continue.name = "SurgeryPatientContinue"
				emphasize_flow_button(app, patient_continue)
			elif prep.awaiting_flow_acknowledgement:
				var flow_response_prompt := "助手指出选择有误。确认后返回本步骤重新选择。" if prep.pending_flow_retry else "团队成员已经回应。确认后再进入下一段操作。"
				app.label_at(flow_response_prompt, Vector2(65, 220), 20, Color("e1e4db"), 650)
				var flow_continue_label := "返回本步骤重新选择" if prep.pending_flow_retry else "继续手术"
				var continue_button: Button = app.button_at(flow_continue_label, Vector2(60, 310), Vector2(655, 54), app.preop_event.bind({"kind": "flow_acknowledge"}))
				continue_button.name = "SurgeryFlowContinue"
				emphasize_flow_button(app, continue_button)
			else:
				app.label_at(str(flow_step.get("prompt", "")), Vector2(65, 220), 20, Color("e1e4db"), 650)
				action_y = 310
				action_spacing = 62
				for option in flow_step.get("options", []):
					var flow_button: Button = app.button_at(option.label, Vector2(60, action_y), Vector2(655, 54), app.preop_event.bind({"kind": "surgery_step", "id": option.id}))
					flow_button.name = "SurgeryStep_" + option.id
					emphasize_flow_button(app, flow_button)
					action_y += action_spacing
			action_y = 900
		"complete":
			app.label_at("✓ 术前确认完成", Vector2(65, 235), 32, Color("e8cfaa"), 650)
			app.label_at("手术还未开始。\n可以保存，下次接着体验术中互动。", Vector2(65, 304), 23, Color("e1e4db"), 650)
			app.button_at("返回医院导览", Vector2(60, 430), Vector2(655, 54), app.show_map)
		"surgery_complete":
			app.label_at("✓ 手术成功 · 互动阶段结束", Vector2(65, 205), 30, Color("e8cfaa"), 650)
			var summary: Label = app.label_at(prep.interaction_summary(), Vector2(65, 255), 19, Color("e1e4db"), 645)
			summary.name = "SurgeryResultSummary"
			summary.size.y = 175
			var metrics: Label = app.label_at("恐惧 %s　痛苦 %s　尊严 %s　配合 %s" % [prep.fear, prep.pain, prep.dignity, prep.cooperation_value()], Vector2(65, 440), 19, Color("c2d2cc"), 645)
			metrics.name = "SurgeryResultMetrics"
			var return_button: Button = app.button_at("结算患者并返回医院导览", Vector2(60, 485), Vector2(655, 54), app.finish_surgery_and_return)
			return_button.name = "SurgeryResultReturn"
			action_y = 900
		_:
			if prep.flags.has("patient_prepared") and stage.scene == "ward":
				var lines: Array[String] = []
				for id in prep.selected_preparations:
					lines.append(prep.preparation(id).response)
				app.label_at("\n".join(lines), Vector2(65, 195), 20, Color("e8cfaa"), 645)
				app.label_at("下一步：更衣 → 刷手 → 进入手术室", Vector2(65, 280), 22, Color("e8cfaa"), 645)
				action_y = 340
	var action_index := 0
	for action in stage.actions:
		if not prep.action_visible(action):
			continue
		if prep.done.has(action.id):
			continue
		var reason: String = prep.action_reason(action)
		var action_position := Vector2(60, action_y + action_index * action_spacing)
		var action_size := Vector2(655, 50 if stage.kind == "interaction" else 54)
		if stage.kind == "preparation":
			action_position = Vector2(60 + (action_index % 2) * 332, action_y + (action_index / 2) * 62)
			action_size = Vector2(323, 54)
		var button: Button = app.button_at(action.label, action_position, action_size, app.preop_event.bind({"kind": "action", "id": action.id}))
		button.name = "PreopAction_" + action.id
		button.disabled = not reason.is_empty()
		button.tooltip_text = reason
		button.add_theme_stylebox_override("disabled", app.panel_style(Color("24343b")))
		button.add_theme_color_override("font_disabled_color", Color("a0b1b5"))
		action_index += 1
	UI.panel(app, Vector2(55, 558), Vector2(1170, 142))
	var note_name := "术中记录" if stage.kind == "surgery_flow" else "互动记录" if stage.kind in ["interaction", "surgery_complete"] else "术前记事"
	var speaker_name: String = speaking_staff.name if not speaking_staff.is_empty() else patient.name if prep.feedback_speaker == "patient" or stage.speaker == "patient" else note_name
	app.label_at(speaker_name, Vector2(82, 570), 20, Color("e8cfaa"), 1100)
	var choosing_flow_option: bool = stage.kind == "surgery_flow" and not prep.awaiting_flow_acknowledgement and not prep.awaiting_patient_choice and not prep.awaiting_patient_acknowledgement
	var default_prompt: String = str(flow_step.get("prompt", stage.prompt))
	var text: String = "" if choosing_flow_option else default_prompt if prep.feedback.is_empty() else prep.feedback
	if not speaking_staff.is_empty() and text.begins_with(speaking_staff.name + "："):
		text = text.substr((speaking_staff.name + "：").length())
	elif not prep.feedback.is_empty() and prep.feedback_speaker == "patient":
		text = "%s：%s" % [patient.name, text]
	elif not prep.feedback.is_empty() and prep.feedback_speaker == "player":
		text = app.protagonist_name() + "：" + text
	var record_font_size := 18 if text.length() > 110 else 20 if text.length() > 65 else 22
	var record_text: Label = app.label_at(text.replace("{patient}", patient.name), Vector2(82, 603), record_font_size, Color("f4f0e6"), 1100)
	record_text.name = "PreopRecordText"
	record_text.size.y = 90
	record_text.clip_text = true
	var save_button: Button = app.button_at("保存", Vector2(60, 713), Vector2(120, 40), app.save_progress)
	if not app.game.can_save_progress():
		save_button.disabled = true
		save_button.tooltip_text = app.game.save_block_reason()
	app.button_at("读档", Vector2(194, 713), Vector2(120, 40), app.request_load)
	app.label_at("场景占位 · 本段用时 %s 分钟" % prep.minutes, Vector2(795, 723), 16, Color("c2d2cc"), 420)

static func operating_room_outfit(staff: Dictionary) -> String:
	# Sterile gown art is a separate outfit. Scrubs remain available for a future
	# circulating-nurse distinction and as a safe fallback for older save data.
	var portraits: Dictionary = staff.get("visuals", {}).get("portraits", {})
	return "sterile" if portraits.has("sterile/focused") else "scrubs"

static func intraoperative_patient_expression(prep: RefCounted) -> String:
	if prep.flags.has("anesthetized"):
		return "anesthetized"
	if prep.flags.has("no_anesthesia_confirmed") or prep.anesthesia == "未麻醉":
		var flow: Array = prep.surgery_flow_steps()
		var collapse_from_step := maxi(1, flow.size() - 2)
		if not flow.is_empty() and prep.procedure_step_index >= collapse_from_step:
			return "near_collapse"
		return "pain"
	return "tense"

static func manual_ward_examination_portrait(prep: RefCounted, stage: Dictionary) -> bool:
	return stage.get("scene", "") == "ward" and prep.flags.has("manual_ward_preparation") and not prep.flags.has("manual_ward_preparation_complete")

static func emphasize_flow_button(app: Control, button: Button) -> void:
	button.add_theme_stylebox_override("normal", app.panel_style(Color("12323bed"), Color("87a9ab")))
	button.add_theme_stylebox_override("hover", app.panel_style(Color("1d4a55fa"), Color("d1b989")))
	button.add_theme_stylebox_override("pressed", app.panel_style(Color("0d2932ff"), Color("e8cfaa")))
	button.add_theme_stylebox_override("focus", app.panel_style(Color("173d47f7"), Color("e8cfaa")))
	button.add_theme_color_override("font_color", Color("f7f6ef"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_font_size_override("font_size", 22)

static func expression_for_patient(prep: RefCounted, stage: Dictionary) -> String:
	if stage.scene == "operating_room":
		if prep.flags.has("anesthetized"):
			return "anesthetized"
		if stage.id == "procedure_mismatch":
			return "afraid"
		if stage.kind in ["interaction", "surgery_flow", "surgery_complete"]:
			# Expressive patients show fear sooner; reserved patients keep a tense
			# face longer. This is visual characterization and changes no mechanics.
			var expression_threshold: int = clampi(70 - int((prep.patient_trait("expressiveness") - 50) * 0.3), 55, 85)
			if prep.fear >= expression_threshold or prep.pain >= expression_threshold or prep.cooperation_value() <= 30:
				return "afraid"
			return "tense" if prep.fear >= 40 else "awake"
		if prep.flags.has("reassured") or prep.anxiety == 0:
			return "awake"
		return "afraid" if prep.anxiety >= 2 else "tense"
	if prep.anxiety >= 3:
		return "crying"
	if prep.anxiety == 2:
		return "worried"
	if prep.anxiety == 1:
		return "brave"
	return "smile"

static func metric(app: Control, label: String, value: int, position: Vector2, color: Color) -> void:
	app.label_at("%s %3d" % [label, value], position, 16, Color("dce5df"), 92)
	var bar := ProgressBar.new()
	bar.position = position + Vector2(92, 2)
	bar.size = Vector2(195, 20)
	bar.min_value = 0
	bar.max_value = 100
	bar.value = value
	bar.show_percentage = false
	var background := StyleBoxFlat.new()
	background.bg_color = Color("263b40")
	background.set_corner_radius_all(3)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	app.page.add_child(bar)

static func role_picker(app: Control, prep: RefCounted, role: Dictionary, y: int) -> void:
	app.label_at(role.label, Vector2(65, y + 10), 20, Color("e8cfaa"), 190)
	var picker := OptionButton.new()
	picker.name = "Role_" + role.id
	picker.position = Vector2(250, y)
	picker.size = Vector2(464, 50)
	picker.add_item("请选择（尚未指派）")
	picker.set_item_disabled(0, true)
	var people: Array = prep.candidates(role.id)
	var selected_index := 0
	for i in range(people.size()):
		var person: Dictionary = people[i]
		var proficiency := str(person.get("surgery_proficiency", "trained"))
		var warning: String = "　⚠ 手术经验有限" if proficiency in ["novice", "limited"] else ""
		picker.add_item("%s · %s %s%s" % [person.name, person.specialty, person.skills[role.skill], warning])
		var selected: bool = prep.team.get(role.id) == person.id
		if selected:
			selected_index = i + 1
		elif prep.team.values().has(person.id):
			picker.set_item_disabled(i + 1, true)
	# Adding an enabled item auto-selects it in Godot, even with a disabled placeholder.
	# Restore the actual assignment only after the whole list has been populated.
	picker.select(selected_index)
	picker.item_selected.connect(func(index: int):
		if index > 0:
			app.preop_event({"kind": "assign", "role": role.id, "staff_id": people[index - 1].id}))
	app.page.add_child(picker)
