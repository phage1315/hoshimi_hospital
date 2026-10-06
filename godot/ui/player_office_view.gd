extends RefCounted

static func panel(app: Control, position: Vector2, size: Vector2, color: Color = Color(0.035, 0.12, 0.145, 0.90)) -> ColorRect:
	var box := ColorRect.new()
	box.position = position
	box.size = size
	box.color = color
	app.page.add_child(box)
	return box

static func return_button(app: Control) -> void:
	app.button_at(app.tx("ui.common.return_office", "← 返回办公室"), Vector2(1015, 88), Vector2(200, 44), app.show_player_office)

static func render_main(app: Control) -> void:
	app.screen = "player_office"
	app.base(app.tx("ui.office.title", "主角办公室"), app.tx("ui.office.subtitle", "%s / %s · 个人据点") % [app.game.day_text(), app.game.clock_text()], false, "player_office")
	panel(app, Vector2(42, 158), Vector2(1195, 535))
	app.label_at(app.tx("ui.office.description", "医院暂时借给坂口的办公室。桌上还只有医院配发的电脑、文件夹和一只普通杯子。"), Vector2(70, 182), 21, Color("e0d9c4"), 1100)
	var menus := [
		[app.tx("ui.office.relationships", "同事关系"), app.show_office_relationships],
		[app.tx("ui.office.cases", "患者病例"), app.show_office_cases],
		[app.tx("ui.office.status", "主角状态"), app.show_player_profile.bind("player_office")],
		[app.tx("ui.office.career", "职业履历"), app.show_office_career],
		[app.tx("ui.office.gallery", "事件与 CG 鉴赏"), app.show_event_gallery.bind("player_office")],
		[app.tx("ui.common.time_log", "时间记录"), app.show_time_log.bind("player_office")],
	]
	for i in range(menus.size()):
		var column := i % 2
		var row := i / 2
		var button: Button = app.button_at(str(menus[i][0]), Vector2(70 + column * 390, 245 + row * 72), Vector2(360, 55), menus[i][1])
		button.name = "OfficeMenu_" + str(i)
	var crisis_state: String = app.tx("ui.office.crisis_on", "开启") if app.game.intraoperative_crisis_enabled else app.tx("ui.office.crisis_off", "关闭")
	var crisis_toggle: Button = app.button_at(app.tx("ui.office.crisis_toggle", "术中危机事件：%s") % crisis_state, Vector2(70, 461), Vector2(360, 55), app.toggle_intraoperative_crisis)
	crisis_toggle.name = "OfficeCrisisToggle"
	crisis_toggle.tooltip_text = app.tx("ui.office.crisis_hint", "关闭后仍保留患者互动与技术数值，但不再进行随机生理危机判定。")
	var field_ui_state: String = app.tx("ui.office.field_ui_hud", "右上角 HUD") if app.operative_field_hud_enabled else app.tx("ui.office.field_ui_fullscreen", "全屏背景")
	var field_ui_toggle: Button = app.button_at(app.tx("ui.office.field_ui_toggle", "术野 UI：%s") % field_ui_state, Vector2(460, 461), Vector2(360, 55), app.toggle_operative_field_hud)
	field_ui_toggle.name = "OfficeOperativeFieldUIToggle"
	field_ui_toggle.tooltip_text = app.tx("ui.office.field_ui_hint", "实验选项：切换切皮后至缝合前的术野显示方式。")
	var career_button: Button = app.button_at(app.tx("ui.office.actions", "处理文书 / 职业行动  →"), Vector2(850, 245), Vector2(340, 64), app.show_office_actions)
	career_button.name = "OfficeCareerActions"
	if app.game.is_sunday():
		career_button.text = app.tx("ui.office.actions_sunday", "周日不安排职业行动")
		career_button.disabled = true
	app.button_at(app.tx("ui.office.collection", "收藏与纪念物  →"), Vector2(850, 325), Vector2(340, 58), app.show_office_collection).name = "OfficeCollection"
	app.scrollable_text_at(app.tx("ui.office.note", "查看资料不消耗时间。职业行动是主动投资，不会成为每日强制作业。"), Vector2(850, 485), Vector2(340, 92), 18, Color("c2d2cc"), "OfficeUsageNote")
	var leave_button: Button = app.button_at(app.tx("ui.office.end_workday", "结束工作，今天下班  →"), Vector2(850, 590), Vector2(340, 48), app.request_end_workday)
	leave_button.name = "OfficeEndWorkday"
	leave_button.disabled = not app.game.can_end_workday()
	leave_button.tooltip_text = app.game.last_error if leave_button.disabled else app.tx("ui.office.end_workday_hint", "离院时可能遇见一名已经认识的女性同事。")
	app.label_at(app.tx("ui.office.current", "当前：完成手术 %s 台　·　今日剩余 %s 分钟") % [app.game.completed_surgeries_total, app.game.shift_remaining()], Vector2(70, 635), 19, Color("e8cfaa"), 700)
	if app.game.personal_nurse_system_unlocked:
		app.button_at(app.tx("ui.personal_nurse.title", "专属护士"), Vector2(810, 88), Vector2(190, 44), app.show_office_personal_nurse).name = "OfficePersonalNurse"
	app.button_at(app.tx("ui.common.return_map", "← 医院导览"), Vector2(1030, 88), Vector2(185, 44), app.show_map)

static func render_collection(app: Control) -> void:
	app.screen = "office_collection"
	app.base(app.tx("ui.collection.title", "收藏与纪念物"), app.tx("ui.collection.subtitle", "留在办公室里的物件与这一年的痕迹"), false, "player_office")
	panel(app, Vector2(45, 165), Vector2(1190, 500))
	var flags: Array = app.content.protagonist.get("office_flags", [])
	var items: Array = app.content.protagonist.get("office_items", [])
	var row := 0
	for item in items:
		if str(item.get("flag", "")) not in flags:
			continue
		var button: Button = app.button_at(str(item.label), Vector2(75, 210 + row * 75), Vector2(1080, 58), app.show_office_item.bind(str(item.id)))
		button.name = "OfficeItem_" + str(item.id)
		row += 1
	if row == 0:
		app.label_at(app.tx("ui.collection.empty", "办公室里还没有值得特别收起的东西。"), Vector2(75, 230), 22, Color("f4f0e6"), 980)
	app.label_at(app.tx("ui.collection.note", "这些物品不会消耗时间；它们会随着职业经历和人物事件逐渐增加。"), Vector2(75, 610), 18, Color("c2d2cc"), 980)
	return_button(app)

static func render_item(app: Control, item_id: String) -> void:
	var selected: Dictionary = {}
	for item in app.content.protagonist.get("office_items", []):
		if str(item.id) == item_id and str(item.flag) in app.content.protagonist.get("office_flags", []):
			selected = item
			break
	if selected.is_empty():
		render_collection(app)
		return
	app.screen = "office_item"
	app.base(str(selected.label), app.tx("ui.collection.record_subtitle", "办公室收藏 / PERSONAL RECORD"), false, "player_office")
	panel(app, Vector2(120, 195), Vector2(1040, 390))
	app.label_at(str(selected.description), Vector2(175, 260), 25, Color("f4f0e6"), 920)
	app.label_at(app.tx("ui.collection.future_note", "更详细的回忆将在未来事件中开放。"), Vector2(175, 410), 19, Color("e8cfaa"), 800)
	app.button_at(app.tx("ui.collection.return", "← 收藏与纪念物"), Vector2(60, 713), Vector2(230, 40), app.show_office_collection)

static func shared_operations(app: Control, staff_id: String) -> int:
	return app.game.shared_surgery_count(staff_id)

static func render_personal_nurse(app: Control) -> void:
	app.screen = "office_personal_nurse"
	app.base(app.tx("ui.personal_nurse.title", "专属护士"), app.tx("ui.personal_nurse.subtitle", "选择普通门诊中的固定工作搭档"), false, "player_office")
	panel(app, Vector2(45, 165), Vector2(1190, 500))
	var current_id: String = app.game.resolve_outpatient_support_actor()
	var current: Dictionary = app.content.find_record("staff", current_id)
	app.label_at(app.tx("ui.personal_nurse.current", "当前：%s") % current.get("name", "—"), Vector2(75, 195), 27, Color("e8cfaa"), 1050)
	app.label_at(app.tx("ui.personal_nurse.description", "专属护士会陪同普通门诊、提供流程提示，并在每个完整患者周期结束时获得 1 点熟悉度。手术组队仍由你自由决定。"), Vector2(75, 240), 18, Color("c2d2cc"), 720)
	if not current.is_empty():
		app.add_portrait(current)
		var portrait = app.page.get_node_or_null("CharacterPortrait")
		if portrait != null:
			portrait.position = Vector2(850, 260)
			portrait.size = Vector2(320, 360)
	var candidates: Array[String] = app.game.personal_nurse_candidates()
	for i in range(candidates.size()):
		var actor_id: String = candidates[i]
		var person: Dictionary = app.content.find_record("staff", actor_id)
		var relation: Dictionary = app.game.relation_for(actor_id)
		var selected: bool = actor_id == current_id
		var label: String = "%s　·　Lv%s　·　%s %s　·　%s" % [person.name, relation.get("level", 0), app.tx("ui.personal_nurse.familiarity", "熟悉度"), relation.get("familiarity", 0), app.tx("ui.personal_nurse.selected", "当前") if selected else app.tx("ui.personal_nurse.assign", "指定")]
		var button: Button = app.button_at(label, Vector2(75 + (i % 2) * 380, 310 + (i / 2) * 72), Vector2(350, 54), app.choose_personal_nurse.bind(actor_id))
		button.name = "PersonalNurse_" + actor_id
		button.disabled = selected
	return_button(app)

static func bond_label(app: Control, familiarity: int) -> String:
	if familiarity >= 70:
		return app.tx("ui.relationship.bond_partner", "老搭档")
	if familiarity >= 45:
		return app.tx("ui.relationship.bond_synced", "默契")
	if familiarity >= 10:
		return app.tx("ui.relationship.bond_familiar", "熟悉")
	return app.tx("ui.relationship.bond_stranger", "陌生")

static func render_relationships(app: Control) -> void:
	app.screen = "office_relationships"
	app.base(app.tx("ui.relationship.title", "同事关系"), app.tx("ui.relationship.subtitle", "关系倾向、熟悉度与共同经历"), false, "player_office")
	var scroll := ScrollContainer.new()
	scroll.name = "OfficeRelationshipScroll"
	scroll.position = Vector2(45, 165)
	scroll.size = Vector2(1190, 500)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	app.page.add_child(scroll)
	var content := Control.new()
	content.custom_minimum_size = Vector2(1160, max(500, app.content.collections.staff.size() * 104 + 20))
	scroll.add_child(content)
	for i in range(app.content.collections.staff.size()):
		var person: Dictionary = app.content.collections.staff[i]
		var relation: Dictionary = app.game.relation_for(str(person.id))
		var met := bool(relation.get("met", false))
		var box := ColorRect.new()
		box.position = Vector2(10, 10 + i * 104)
		box.size = Vector2(1120, 86)
		box.color = Color(0.035, 0.12, 0.145, 0.91)
		content.add_child(box)
		var title: Label = app.label_at(str(person.name) if met else "？？？", Vector2.ZERO, 23, Color("e8cfaa"), 260)
		app.page.remove_child(title)
		content.add_child(title)
		title.position = Vector2(30, 24 + i * 104)
		if not met:
			continue
		var last_event: String = app.tx("ui.relationship.no_event", "尚无重要事件")
		var history: Array = relation.get("event_history", [])
		if not history.is_empty() and app.game.character_event_definitions.has(history.back()):
			last_event = "《%s》" % str(app.game.character_event_definitions[history.back()].title)
		var count := shared_operations(app, str(person.id))
		var familiarity := int(relation.get("familiarity", 0))
		var line: String = app.tx("ui.relationship.detail", "%s　Lv%s　倾向：%s　熟悉度 %s / %s　共同上台 %s次") % [person.specialty, relation.level, app.affection_tendency(int(relation.get("affection", 0))), familiarity, bond_label(app, familiarity), count]
		var details: Label = app.label_at(line + "\n" + app.tx("ui.relationship.recent_event", "最近事件：%s") % last_event, Vector2.ZERO, 17, Color("f4f0e6"), 800)
		app.page.remove_child(details)
		content.add_child(details)
		details.position = Vector2(300, 18 + i * 104)
	return_button(app)

static func visit_for_patient(app: Control, patient_id: String):
	for visit in app.game.visits.values():
		if str(visit.definition.patient_id) == patient_id:
			return visit
	return null

static func preparation_for_patient(app: Control, patient_id: String):
	for preparation in app.game.preops.values():
		if str(preparation.definition.patient_id) == patient_id:
			return preparation
	return null

static func case_status(app: Control, patient_id: String) -> String:
	var preparation = preparation_for_patient(app, patient_id)
	if preparation != null and preparation.surgery_aborted:
		return app.tx("ui.case.status_aborted", "手术中止 · 已稳定")
	if app.game.completed_patient(patient_id):
		return app.tx("ui.case.status_complete", "手术完成")
	if app.game.admitted_patient(patient_id):
		return app.tx("ui.case.status_admitted", "已住院")
	if not app.game.referral_doctor(patient_id).is_empty():
		return app.tx("ui.case.status_referred", "已转诊")
	return app.tx("ui.case.status_clinic", "门诊记录")

static func render_cases(app: Control) -> void:
	app.screen = "office_cases"
	app.base(app.tx("ui.case.title", "患者病例"), app.tx("ui.case.subtitle", "只收录已经发生的诊疗记录"), false, "player_office")
	panel(app, Vector2(45, 165), Vector2(1190, 500))
	var row := 0
	for patient in app.content.collections.patients:
		var patient_id := str(patient.id)
		if visit_for_patient(app, patient_id) == null and app.game.referral_doctor(patient_id).is_empty() and preparation_for_patient(app, patient_id) == null:
			continue
		var case_data: Dictionary = app.game.patient_case(patient_id)
		var caption := "%s　/　%s　/　%s" % [patient.name, str(case_data.get("title", app.tx("ui.case.undetermined", "未定病例"))), case_status(app, patient_id)]
		var button: Button = app.button_at(caption, Vector2(75, 205 + row * 70), Vector2(1080, 55), app.show_office_case.bind(patient_id))
		button.name = "OfficeCase_" + patient_id
		row += 1
	if row == 0:
		app.label_at(app.tx("ui.case.empty", "还没有可以归档的患者记录。完成接诊后，病例会自动出现在这里。"), Vector2(75, 230), 22, Color("f4f0e6"), 1000)
	return_button(app)

static func patient_grade(app: Control, preparation) -> String:
	if preparation == null:
		return app.tx("ui.case.grade_pending", "尚未形成评价")
	if preparation.fear <= 45 and preparation.pain <= 35 and preparation.dignity >= 70:
		return app.tx("ui.case.grade_a", "A · 安心")
	if preparation.fear <= 70 and preparation.pain <= 65 and preparation.dignity >= 40:
		return app.tx("ui.case.grade_b", "B · 紧张但稳定")
	return app.tx("ui.case.grade_c", "C · 经历压力明显")

static func render_case_detail(app: Control, patient_id: String) -> void:
	var patient: Dictionary = app.content.find_record("patients", patient_id)
	if patient.is_empty():
		render_cases(app)
		return
	app.screen = "office_case_detail"
	app.base(str(patient.name) + app.tx("ui.case.file_suffix", " · 病例档案"), app.tx("ui.case.age_status", "%s岁 / %s") % [patient.age, case_status(app, patient_id)], false, "player_office")
	panel(app, Vector2(45, 165), Vector2(1190, 500))
	var case_data: Dictionary = app.game.patient_case(patient_id)
	var preparation = preparation_for_patient(app, patient_id)
	var procedure: String = app.tx("ui.case.procedure_pending", "尚未实施")
	var anesthesia: String = app.tx("ui.case.anesthesia_pending", "尚未选择")
	var team_text: String = app.tx("ui.case.team_pending", "尚未编组")
	var experience: String = app.tx("ui.case.experience_pending", "尚未进入手术阶段")
	var outcome: String = app.tx("ui.case.follow_up", "继续随访")
	if preparation != null:
		procedure = preparation.procedure_name if not preparation.procedure_name.is_empty() else str(case_data.get("procedure", case_data.get("surgery_name", app.tx("ui.case.unconfirmed", "尚未确认"))))
		anesthesia = preparation.anesthesia
		experience = app.tx("ui.case.experience", "%s　恐惧 %s / 痛苦 %s / 尊严 %s") % [patient_grade(app, preparation), preparation.fear, preparation.pain, preparation.dignity]
		var team_names: Array[String] = []
		for staff_id in preparation.team.values():
			var person: Dictionary = app.content.find_record("staff", str(staff_id))
			if not person.is_empty() and not team_names.has(str(person.name)):
				team_names.append(str(person.name))
		team_text = app.tx("ui.common.list_separator", "、").join(team_names) if not team_names.is_empty() else app.tx("ui.case.team_pending", "尚未编组")
		outcome = app.tx("ui.case.outcome_success", "手术顺利完成") if preparation.surgery_success else app.tx("ui.case.outcome_aborted", "手术中止 · 患者已稳定") if preparation.surgery_aborted else app.tx("ui.case.outcome_active", "术前／术中流程进行中")
	var lines := [
		app.tx("ui.case.diagnosis", "诊断：%s") % str(case_data.get("diagnosis", case_data.get("title", app.tx("ui.case.unclear", "尚未明确")))),
		app.tx("ui.case.procedure", "计划／术式：%s") % procedure,
		app.tx("ui.case.anesthesia", "麻醉：%s") % anesthesia,
		app.tx("ui.case.team", "手术团队：%s") % team_text,
		app.tx("ui.case.patient_experience", "患者体验：%s") % experience,
		app.tx("ui.case.outcome", "当前结局：%s") % outcome,
	]
	for i in range(lines.size()):
		app.label_at(lines[i], Vector2(75, 210 + i * 58), 21, Color("f4f0e6"), 1080)
	app.label_at(app.tx("ui.case.note", "病例档案直接读取真实诊疗状态；未来复诊、论文和学会事件可继续使用这份记录。"), Vector2(75, 585), 18, Color("c2d2cc"), 1040)
	app.button_at(app.tx("ui.case.return", "← 病例列表"), Vector2(60, 713), Vector2(190, 40), app.show_office_cases)

static func render_career(app: Control) -> void:
	app.screen = "office_career"
	app.base(app.tx("ui.career.title", "职业履历"), app.tx("ui.career.subtitle", "这一年里，坂口正在成为怎样的医生"), false, "player_office")
	panel(app, Vector2(45, 165), Vector2(1190, 500))
	var visited: int = app.game.visits.size()
	var referrals: int = app.game.patient_referrals.size()
	var procedures: Dictionary = {}
	var corrections := 0
	for preparation in app.game.preops.values():
		if preparation.surgery_success:
			procedures[preparation.procedure_id] = true
		corrections += int(preparation.procedure_corrections)
	var stats := [
		[app.tx("ui.career.visits", "门诊接诊记录"), visited],
		[app.tx("ui.career.surgeries", "完成手术"), app.game.completed_surgeries_total],
		[app.tx("ui.career.procedures", "不同术式完成"), procedures.size()],
		[app.tx("ui.career.referrals", "已转诊病例"), referrals],
		[app.tx("ui.career.corrections", "助手纠正关键判断"), corrections],
		[app.tx("ui.career.colleagues", "已认识同事"), app.game.relationships.values().filter(func(relation): return relation.met).size()],
	]
	for i in range(stats.size()):
		var column := i % 2
		var row := i / 2
		app.label_at("%s\n%s" % [stats[i][0], stats[i][1]], Vector2(90 + column * 540, 220 + row * 115), 24, Color("f4f0e6"), 430)
	app.label_at(app.tx("ui.career.note", "论文、学会与长期头衔将在对应系统开放后加入，不会在这里建立重复进度。"), Vector2(75, 590), 18, Color("c2d2cc"), 1050)
	return_button(app)

static func effect_text(app: Control, effects: Dictionary) -> String:
	var labels := {"skill": app.tx("ui.attribute.skill", "手术技术"), "leadership": app.tx("ui.attribute.leadership", "领导力"), "charm": app.tx("ui.attribute.charm", "魅力"), "reputation": app.tx("ui.attribute.reputation", "声望"), "presence": app.tx("ui.attribute.presence", "临床气场")}
	var parts: Array[String] = []
	for metric in labels:
		var amount := int(effects.get(metric, 0))
		if amount != 0:
			parts.append("%s +%s" % [labels[metric], amount])
	return app.tx("ui.action.no_effect", "无属性变化") if parts.is_empty() else " / ".join(parts)

static func render_actions(app: Control) -> void:
	app.screen = "office_actions"
	app.base(app.tx("ui.action.title", "职业行动"), app.tx("ui.action.subtitle", "主动投入时间，整理经验或稍作休息"), false, "player_office")
	panel(app, Vector2(45, 165), Vector2(1190, 500))
	var actions: Array = app.game.time_events_at("player_office")
	for i in range(actions.size()):
		var action: Dictionary = actions[i]
		var button: Button = app.button_at(app.tx("ui.action.detail", "%s　·　%s分钟\n%s") % [action.label, action.minutes, effect_text(app, action.get("effects", {}))], Vector2(70 + (i % 2) * 575, 205 + (i / 2) * 115), Vector2(540, 88), app.perform_time_event.bind(str(action.id), "player_office"))
		button.name = "OfficeAction_" + str(action.id)
	app.label_at(app.tx("ui.action.note", "行动可能跨过下班时间；完成后按现有时间系统进入下一天。"), Vector2(75, 610), 18, Color("c2d2cc"), 980)
	return_button(app)
