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
	app.button_at(app.tx("ui.daydream.title", "白日梦"), Vector2(850, 405), Vector2(340, 58), app.show_daydreams).name = "OfficeDaydream"
	app.scrollable_text_at(app.tx("ui.office.note", "查看资料不消耗时间。职业行动是主动投资，不会成为每日强制作业。"), Vector2(850, 485), Vector2(340, 92), 18, Color("c2d2cc"), "OfficeUsageNote")
	var booking_label: String = app.free_h_booking_label()
	if not booking_label.is_empty():
		app.label_at(booking_label, Vector2(70, 548), 18, Color("e8cfaa"), 475).name = "FreeHBookingSummary"
		app.button_at(app.tx("ui.free_h.cancel", "取消今晚的约定"), Vector2(560, 540), Vector2(260, 42), app.cancel_free_h_booking.bind(app.show_player_office)).name = "FreeHBookingCancel"
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
	var assigned_id: String = str(app.game.personal_nurse_id)
	var current_id: String = app.game.resolve_outpatient_support_actor()
	var current: Dictionary = app.content.find_record("staff", current_id)
	var has_explicit_nurse: bool = not assigned_id.is_empty() and app.game.personal_nurse_candidates().has(assigned_id)
	var current_text: String = app.tx("ui.personal_nurse.current", "当前：%s") % current.get("name", "—") if has_explicit_nurse else app.tx("ui.personal_nurse.current_unassigned", "当前：尚未指定（暂由 %s 协助门诊）") % current.get("name", "—")
	app.label_at(current_text, Vector2(75, 190), 25, Color("e8cfaa"), 1080)
	var desc_font := 16 if app.content.localizer.locale == "en" else 18
	app.label_at(app.tx("ui.personal_nurse.description", "专属护士会陪同普通门诊、提供流程提示，并在每个完整患者周期结束时获得 1 点熟悉度。手术组队仍由你自由决定。"), Vector2(75, 232), desc_font, Color("c2d2cc"), 760)
	if not current.is_empty():
		app.add_portrait(current)
		var portrait = app.page.get_node_or_null("CharacterPortrait")
		if portrait != null:
			portrait.position = Vector2(880, 260)
			portrait.size = Vector2(305, 360)
	var candidates: Array[String] = app.game.personal_nurse_candidates()
	var list_scroll := ScrollContainer.new()
	list_scroll.name = "PersonalNurseCandidateScroll"
	list_scroll.position = Vector2(58, 304)
	list_scroll.size = Vector2(812, 344)
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	app.page.add_child(list_scroll)
	var row_stride := 60
	var row_count := ceili(float(candidates.size()) / 2.0)
	var list_canvas := Control.new()
	list_canvas.custom_minimum_size = Vector2(796, maxi(340, row_count * row_stride + 8))
	list_scroll.add_child(list_canvas)
	for i in range(candidates.size()):
		var actor_id: String = candidates[i]
		var person: Dictionary = app.content.find_record("staff", actor_id)
		var relation: Dictionary = app.game.relation_for(actor_id)
		var selected: bool = has_explicit_nurse and actor_id == assigned_id
		var fam_label: String = app.tx("ui.personal_nurse.familiarity_short", "熟悉")
		var label: String = "%s · Lv%d · %s %d · %s" % [person.name, int(relation.get("level", 0)), fam_label, int(relation.get("familiarity", 0)), app.tx("ui.personal_nurse.selected", "当前") if selected else app.tx("ui.personal_nurse.assign", "指定")]
		var row_pos := Vector2((i % 2) * 400, 4 + (i / 2) * row_stride)
		app.add_staff_chibi_slot(list_canvas, actor_id, row_pos, 48.0, true, "PersonalNurseAvatar_" + actor_id)
		var button: Button = app.button_at(label, Vector2.ZERO, Vector2(338, 48), app.choose_personal_nurse.bind(actor_id))
		app.page.remove_child(button)
		list_canvas.add_child(button)
		button.position = row_pos + Vector2(54, 0)
		button.name = "PersonalNurse_" + actor_id
		button.add_theme_font_size_override("font_size", 15 if app.content.localizer.locale == "en" else 16)
		button.clip_text = true
		button.size = Vector2(338, 48)
		app.style_action_button(button, 10)
		app.style_selected_button(button, selected)
	return_button(app)

static func bond_label(app: Control, familiarity: int) -> String:
	if familiarity >= 70:
		return app.tx("ui.relationship.bond_partner", "老搭档")
	if familiarity >= 45:
		return app.tx("ui.relationship.bond_synced", "默契")
	if familiarity >= 10:
		return app.tx("ui.relationship.bond_familiar", "熟悉")
	return app.tx("ui.relationship.bond_stranger", "陌生")

static func relationship_impression(app: Control, level: int) -> String:
	var labels := [
		app.tx("ui.relationship.impression.lv0", "刚刚认识"),
		app.tx("ui.relationship.impression.lv1", "开始熟悉"),
		app.tx("ui.relationship.impression.lv2", "建立信任"),
		app.tx("ui.relationship.impression.lv3", "重要同事"),
		app.tx("ui.relationship.impression.lv4", "亲近搭档"),
		app.tx("ui.relationship.impression.lv5", "不可替代"),
	]
	return labels[clampi(level, 0, labels.size() - 1)]

static func relationship_next_hint(app: Control, progress: Dictionary, actor_id: String = "") -> String:
	if bool(progress.get("complete", false)):
		return app.tx("ui.relationship.progress.maximum", "关系等级已达当前上限")
	if not bool(progress.get("has_slot", false)):
		return app.tx("ui.relationship.progress.unavailable", "下一阶段尚未开放")
	var gate: Dictionary = progress.get("gate", {})
	var planned_suffix: String = "" if bool(progress.get("event_authored", false)) else app.tx("ui.relationship.progress.planned_tag", "（后续剧情尚未实装）")
	if not bool(gate.get("familiarity_met", false)):
		return app.tx("ui.relationship.progress.familiarity_compact", "熟悉度 %s / %s") % [int(gate.get("familiarity_current", 0)), int(gate.get("familiarity_required", 0))] + planned_suffix
	if not bool(gate.get("cooldown_met", false)):
		return app.tx("ui.relationship.progress.cooldown", "上一段重要经历后还需 %s 天") % int(gate.get("cooldown_remaining", 0)) + planned_suffix
	if not bool(gate.get("requirements", {}).get("met", false)):
		return app.tx("ui.relationship.progress.other_requirements", "熟悉度已达；还有其他条件未满足") + planned_suffix
	if not bool(progress.get("event_authored", false)):
		return app.tx("ui.relationship.progress.future", "条件已满足；后续事件尚未开放")
	var clue := authored_trigger_clue(app, actor_id, progress)
	if not clue.is_empty():
		return app.tx("ui.relationship.progress.ready_with_clue", "条件已满足 · %s") % clue
	return app.tx("ui.relationship.progress.ready", "条件已满足；等待合适的时间与地点")

static func authored_trigger_clue(app: Control, actor_id: String, progress: Dictionary) -> String:
	if actor_id.is_empty() or not bool(progress.get("event_authored", false)):
		return ""
	var target_level := int(progress.get("target_level", 0))
	if actor_id == "doc_asuka" and target_level == 1:
		return app.tx("ui.relationship.clue.asuka_lv1", "邀请她担任手术助手并亲手完成一台普通手术（勿扫荡）")
	if actor_id == "doc_serika":
		var disc_done := 0
		for idx in range(1, 16):
			if app.game.character_event_done("serika_radiology_d%02d" % idx):
				disc_done += 1
		if target_level == 1:
			return app.tx("ui.relationship.clue.serika_lv1", "工作日前往影像科进行读片讨论（已累计 %s / 5 次）") % disc_done
		if target_level == 2:
			return app.tx("ui.relationship.clue.serika_lv2", "工作日继续在影像科读片讨论（已累计 %s / 10 次）") % disc_done
		if target_level == 3:
			return app.tx("ui.relationship.clue.serika_lv3", "累计 15 次影像讨论后，在星期日选择「独自外出走走」（当前 %s / 15）") % disc_done
	if actor_id == "doc_sayaka" and target_level == 1:
		var rel: Dictionary = app.game.relation_for("doc_sayaka")
		if not ("sayaka_phone_exchanged" in rel.get("flags", [])):
			return app.tx("ui.relationship.clue.sayaka_phone", "先在工作日早晨完成院内换号事件，再于星期日邀约")
		return app.tx("ui.relationship.clue.sunday_date", "可在星期日安排中邀请外出约会")
	if actor_id == "doc_shiori" and target_level == 3:
		var lv2_ev = app.game.character_events.get("shiori_lv2_consultation_boundary")
		if lv2_ev != null and bool(lv2_ev.completed):
			var gap: int = int(app.game.day_number()) - int(lv2_ev.completed_day)
			if gap < 28:
				return app.tx("ui.relationship.clue.shiori_lv3_wait", "距上一段内科合作还需等待 %s 天") % (28 - gap)
	var slot: Dictionary = app.game.relationship_rank_slot(actor_id, target_level)
	var event_id := str(slot.get("event_id", ""))
	if event_id.is_empty():
		return ""
	if app.game.character_event_definitions.has(event_id):
		var ev: Dictionary = app.game.character_event_definitions[event_id]
		var mode: String = str(app.game.character_event_trigger_mode(ev))
		if mode == "sunday":
			return app.tx("ui.relationship.clue.sunday_date", "可在星期日安排中邀请外出约会")
		if mode == "after_work":
			return app.tx("ui.relationship.clue.after_work", "可在平日下班结算时触发（需无待术住院患者）")
		if mode == "day_start":
			return app.tx("ui.relationship.clue.day_start", "将在合适的工作日早晨触发")
		if mode == "location":
			var loc_id := str(ev.get("location_id", ""))
			var loc: Dictionary = app.content.find_record("locations", loc_id)
			if not loc.is_empty():
				return app.tx("ui.relationship.clue.visit_location", "可在工作时间前往「%s」看看") % str(loc.get("name", ""))
	if app.game.special_event_definitions.has(event_id):
		var sev: Dictionary = app.game.special_event_definitions[event_id]
		var smode: String = str(app.game.special_event_trigger_mode(sev))
		if smode == "after_work":
			return app.tx("ui.relationship.clue.after_work", "可在平日下班结算时触发（需无待术住院患者）")
		if smode == "location":
			var sloc_id := str(sev.get("timing", {}).get("location_id", ""))
			var sloc: Dictionary = app.content.find_record("locations", sloc_id)
			if not sloc.is_empty():
				return app.tx("ui.relationship.clue.visit_location", "可在工作时间前往「%s」看看") % str(sloc.get("name", ""))
		return app.tx("ui.relationship.clue.special_event", "可在医院导览底栏「特殊活动」或平日早晨推进")
	return ""

static func relationship_condition_mark(app: Control, met: bool) -> String:
	return app.tx("ui.relationship.condition.met", "✓") if met else app.tx("ui.relationship.condition.unmet", "○")

static func relationship_attribute_name(app: Control, attribute: String) -> String:
	match attribute:
		"skill":
			return app.tx("ui.attribute.skill", "手术技巧")
		"leadership":
			return app.tx("ui.attribute.leadership", "领导力")
		"charm":
			return app.tx("ui.attribute.charm", "魅力")
		"reputation":
			return app.tx("ui.attribute.reputation", "专业声望")
		"presence":
			return app.tx("ui.attribute.presence", "临床气场")
	return app.tx("ui.relationship.condition.attribute", "主角能力")

static func relationship_skill_name(app: Control, skill: String) -> String:
	match skill:
		"surgery":
			return app.tx("ui.relationship.skill.surgery", "手术技巧")
		"diagnostics":
			return app.tx("ui.relationship.skill.diagnostics", "诊断能力")
		"teamwork":
			return app.tx("ui.relationship.skill.teamwork", "团队协作")
		"patient_care":
			return app.tx("ui.relationship.skill.patient_care", "患者照护")
		"instrument_handling":
			return app.tx("ui.relationship.skill.instrument_handling", "器械操作")
		"calmness":
			return app.tx("ui.relationship.skill.calmness", "冷静")
	return app.tx("ui.relationship.condition.staff_skill", "人物能力")

static func known_staff_name(app: Control, actor_id: String) -> String:
	if actor_id.is_empty() or not app.game.staff_is_met(actor_id):
		return ""
	return str(app.content.find_record("staff", actor_id).get("name", ""))

static func relationship_counter_name(app: Control, counter_id: String) -> String:
	match counter_id:
		"completed_sunday_dates":
			return app.tx("ui.relationship.counter.sunday_dates", "共同完成周日约会")
		"gynecology_case_count":
			return app.tx("ui.relationship.counter.gynecology_cases", "完成妇科病例")
		"outpatient_forced_undress":
			return app.tx("ui.relationship.counter.outpatient_preparations", "共同完成指定门诊准备")
		"assisted_player_ward_preparation":
			return app.tx("ui.relationship.counter.ward_preparations", "共同完成病房术前准备")
		"completed_no_anesthesia_surgeries", "completed_no_anesthesia_surgeries_as_assistant_surgeon":
			return app.tx("ui.relationship.counter.no_anesthesia_surgeries", "完成无麻醉手术经历")
	return app.tx("ui.relationship.counter.shared_experience", "积累指定共同经历")

static func relationship_requirement_text(app: Control, evaluation: Dictionary) -> String:
	var requirement: Dictionary = evaluation.get("requirement", {})
	var kind := str(evaluation.get("type", ""))
	var mark := relationship_condition_mark(app, bool(evaluation.get("met", false)))
	if not bool(evaluation.get("visible", true)):
		return app.tx("ui.relationship.condition.related_experience", "%s 推进相关院内经历") % mark
	var current = evaluation.get("current", 0)
	var minimum = evaluation.get("minimum", 0)
	var current_int := int(current) if (current is int or current is float) else 0
	var minimum_int := int(minimum) if (minimum is int or minimum is float) else 0
	match kind:
		"player_attribute":
			var attribute_caption: String = mark + " " + relationship_attribute_name(app, str(requirement.get("attribute", "")))
			if requirement.has("maximum") and int(requirement.get("minimum", -999)) <= -999:
				return app.tx("ui.relationship.condition.maximum", "%s %s / ≤ %s") % [attribute_caption, current_int, int(evaluation.get("maximum", 0))]
			if requirement.has("maximum"):
				return app.tx("ui.relationship.condition.range", "%s %s / %s–%s") % [attribute_caption, current_int, minimum_int, int(evaluation.get("maximum", 0))]
			return app.tx("ui.relationship.condition.value", "%s %s / %s") % [attribute_caption, current_int, minimum_int]
		"staff_skill":
			var name := known_staff_name(app, str(evaluation.get("actor_id", "")))
			if name.is_empty():
				return app.tx("ui.relationship.condition.related_experience", "%s 推进相关院内经历") % mark
			return app.tx("ui.relationship.condition.value", "%s %s / %s") % [mark + " " + name + " · " + relationship_skill_name(app, str(requirement.get("skill", ""))), current_int, minimum_int]
		"staff_relationship_count":
			var category: String = app.tx("ui.relationship.category.nurse", "护士") if str(requirement.get("team_category", "")) == "nurse" else app.tx("ui.relationship.category.staff", "同事")
			var caption: String = app.tx("ui.relationship.condition.staff_count", "%s中达到 Lv%s 的人数") % [category, int(requirement.get("minimum_level", 0))]
			return app.tx("ui.relationship.condition.value", "%s %s / %s") % [mark + " " + caption, current_int, minimum_int]
		"progress_counter":
			return app.tx("ui.relationship.condition.value", "%s %s / %s") % [mark + " " + relationship_counter_name(app, str(evaluation.get("counter_id", ""))), current_int, minimum_int]
		"completed_surgeries":
			return app.tx("ui.relationship.condition.value", "%s %s / %s") % [mark + " " + app.tx("ui.relationship.condition.completed_surgeries", "完成手术"), current_int, minimum_int]
		"completed_surgeries_in_group":
			return app.tx("ui.relationship.condition.value", "%s %s / %s") % [mark + " " + app.tx("ui.relationship.condition.procedure_group", "完成指定术式"), current_int, minimum_int]
		"relationship_level", "relationship_familiarity", "staff_unlocked":
			var name := known_staff_name(app, str(evaluation.get("actor_id", "")))
			if name.is_empty():
				return app.tx("ui.relationship.condition.related_experience", "%s 推进相关院内经历") % mark
			if kind == "staff_unlocked":
				return app.tx("ui.relationship.condition.know_staff", "%s 认识 %s") % [mark, name]
			var metric: String = app.tx("ui.relationship.condition.level", "关系等级") if kind == "relationship_level" else app.tx("ui.personal_nurse.familiarity", "熟悉度")
			return app.tx("ui.relationship.condition.value", "%s %s / %s") % [mark + " " + name + " · " + metric, current_int, minimum_int]
		"flag", "story_flag", "character_event_completed", "special_event_completed", "days_after_character_event", "days_after_special_event":
			return app.tx("ui.relationship.condition.related_experience", "%s 推进相关院内经历") % mark
		"career_progress_any":
			var values: Dictionary = current if current is Dictionary else {}
			var alternatives: Array[String] = []
			if requirement.has("minimum_completed_surgeries"):
				alternatives.append(app.tx("ui.relationship.condition.career_surgeries", "手术 %s/%s") % [int(values.get("completed_surgeries", 0)), int(requirement.minimum_completed_surgeries)])
			if requirement.has("minimum_reputation"):
				alternatives.append(app.tx("ui.relationship.condition.career_reputation", "声望 %s/%s") % [int(values.get("reputation", 0)), int(requirement.minimum_reputation)])
			if requirement.has("minimum_day"):
				alternatives.append(app.tx("ui.relationship.condition.career_day", "天数 %s/%s") % [int(values.get("day", 0)), int(requirement.minimum_day)])
			return app.tx("ui.relationship.condition.career_progress_detail", "%s 职业进度（任一）：%s") % [mark, app.tx("ui.relationship.condition.or_separator", " / ").join(alternatives)]
		_:
			return app.tx("ui.relationship.condition.other", "%s 完成其他关系条件") % mark

static func relationship_conditions_text(app: Control, progress: Dictionary, actor_id: String = "") -> String:
	if bool(progress.get("complete", false)):
		return app.tx("ui.relationship.progress.maximum", "关系等级已达当前上限")
	if not bool(progress.get("has_slot", false)):
		return app.tx("ui.relationship.progress.unavailable", "下一阶段尚未开放")
	var gate: Dictionary = progress.get("gate", {})
	var lines: Array[String] = []
	if not bool(progress.get("event_authored", false)):
		lines.append(app.tx("ui.relationship.progress.planned_banner", "※ 本阶段剧情尚未在当前版本实装，无需急于刷取条件。"))
	lines.append(app.tx("ui.relationship.condition.familiarity", "%s 熟悉度 %s / %s") % [relationship_condition_mark(app, bool(gate.get("familiarity_met", false))), int(gate.get("familiarity_current", 0)), int(gate.get("familiarity_required", 0))])
	if int(gate.get("cooldown_required", 0)) > 0:
		lines.append(app.tx("ui.relationship.condition.cooldown", "%s 重要经历间隔 %s / %s 天") % [relationship_condition_mark(app, bool(gate.get("cooldown_met", false))), int(gate.get("cooldown_current", 0)), int(gate.get("cooldown_required", 0))])
	var related_story_added := false
	for evaluation in gate.get("requirements", {}).get("results", []):
		var text := relationship_requirement_text(app, evaluation)
		var story_like := not bool(evaluation.get("visible", true)) or str(evaluation.get("type", "")) in ["flag", "story_flag", "character_event_completed", "special_event_completed", "days_after_character_event", "days_after_special_event"] or (str(evaluation.get("type", "")) in ["relationship_level", "relationship_familiarity", "staff_unlocked", "staff_skill"] and known_staff_name(app, str(evaluation.get("actor_id", ""))).is_empty())
		if story_like and related_story_added:
			continue
		lines.append(text)
		if story_like:
			related_story_added = true
	var clue := authored_trigger_clue(app, actor_id, progress)
	if not clue.is_empty():
		lines.append(app.tx("ui.relationship.clue.prefix", "提示：%s") % clue)
	return "\n".join(lines)

static func render_relationships(app: Control) -> void:
	app.screen = "office_relationships"
	app.base(app.tx("ui.relationship.title", "同事关系"), app.tx("ui.relationship.subtitle", "关系倾向、熟悉度与共同经历"), false, "player_office")
	var scroll := ScrollContainer.new()
	scroll.name = "OfficeRelationshipScroll"
	scroll.position = Vector2(45, 165)
	scroll.size = Vector2(1190, 482)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	app.page.add_child(scroll)
	var content := Control.new()
	content.custom_minimum_size = Vector2(1160, max(482, app.content.collections.staff.size() * 120 + 20))
	scroll.add_child(content)
	for i in range(app.content.collections.staff.size()):
		var person: Dictionary = app.content.collections.staff[i]
		var relation: Dictionary = app.game.relation_for(str(person.id))
		var met := bool(relation.get("met", false))
		var box := ColorRect.new()
		box.position = Vector2(10, 10 + i * 120)
		box.size = Vector2(1120, 102)
		box.color = Color(0.035, 0.12, 0.145, 0.91)
		content.add_child(box)
		app.add_staff_chibi_slot(content, str(person.id), Vector2(24, 27 + i * 120), 68.0, met, "OfficeRelationshipAvatar_" + str(person.id))
		var title: Label = app.label_at(str(person.name) if met else "？？？", Vector2.ZERO, 22, Color("e8cfaa"), 155)
		app.page.remove_child(title)
		content.add_child(title)
		title.position = Vector2(104, 43 + i * 120)
		if not met:
			continue
		var last_event: String = app.tx("ui.relationship.no_event", "尚无重要事件")
		var history: Array = relation.get("event_history", [])
		if not history.is_empty() and app.game.character_event_definitions.has(history.back()):
			last_event = app.tx("ui.relationship.event_quote", "《%s》") % str(app.game.character_event_definitions[history.back()].title)
		var count := shared_operations(app, str(person.id))
		var familiarity := int(relation.get("familiarity", 0))
		var line: String = app.tx("ui.relationship.detail", "%s　Lv%s　倾向：%s　熟悉度 %s / %s　共同上台 %s次") % [person.specialty, int(relation.level), app.affection_tendency(int(relation.get("affection", 0))), familiarity, bond_label(app, familiarity), count]
		var progress: Dictionary = app.game.relationship_progress(str(person.id))
		var details: Label = app.label_at(line + "\n" + app.tx("ui.relationship.recent_event", "最近事件：%s") % last_event + "\n" + relationship_next_hint(app, progress, str(person.id)), Vector2.ZERO, 16, Color("f4f0e6"), 680)
		app.page.remove_child(details)
		content.add_child(details)
		details.position = Vector2(265, 14 + i * 120)
		var progress_button: Button = app.button_at(app.tx("ui.relationship.view_progress", "查看进度  →"), Vector2.ZERO, Vector2(175, 48), app.show_office_relationship_detail.bind(str(person.id), false))
		progress_button.name = "OfficeRelationshipDetail_" + str(person.id)
		app.page.remove_child(progress_button)
		content.add_child(progress_button)
		progress_button.position = Vector2(925, 36 + i * 120)
	return_button(app)

static func render_relationship_detail(app: Control, actor_id: String, expanded: bool = false) -> void:
	var person: Dictionary = app.content.find_record("staff", actor_id)
	var relation: Dictionary = app.game.relation_for(actor_id)
	if person.is_empty() or not bool(relation.get("met", false)):
		render_relationships(app)
		return
	app.screen = "office_relationship_detail"
	app.base(str(person.name), app.tx("ui.relationship.detail_subtitle", "关系档案 / 下一阶段进度"), false, "player_office")
	panel(app, Vector2(45, 165), Vector2(1190, 500))
	var level := int(relation.get("level", 0))
	var familiarity := int(relation.get("familiarity", 0))
	var progress: Dictionary = app.game.relationship_progress(actor_id)
	var impression: String = app.tx("ui.relationship.current_impression", "当前印象：Lv%s · %s") % [level, relationship_impression(app, level)]
	app.label_at(impression, Vector2(75, 205), 28, Color("e8cfaa"), 1060).name = "RelationshipCurrentImpression"
	app.label_at(app.tx("ui.relationship.detail_metrics", "倾向：%s　·　熟悉度 %s（%s）　·　共同上台 %s 次") % [app.affection_tendency(int(relation.get("affection", 0))), familiarity, bond_label(app, familiarity), shared_operations(app, actor_id)], Vector2(75, 255), 19, Color("f4f0e6"), 1060)
	app.label_at(app.tx("ui.relationship.next_level", "下一等级 Lv%s：%s") % [int(progress.get("target_level", level)), relationship_next_hint(app, progress, actor_id)], Vector2(75, 305), 21, Color("c2d2cc"), 1050).name = "RelationshipNextHint"
	var toggle_caption: String = app.tx("ui.relationship.collapse_conditions", "收起具体条件  ↑") if expanded else app.tx("ui.relationship.expand_conditions", "展开具体条件  ↓")
	var toggle: Button = app.button_at(toggle_caption, Vector2(75, 360), Vector2(260, 46), app.show_office_relationship_detail.bind(actor_id, not expanded))
	toggle.name = "RelationshipRequirementsToggle"
	if expanded:
		app.scrollable_text_at(relationship_conditions_text(app, progress, actor_id), Vector2(75, 425), Vector2(1080, 185), 19, Color("f4f0e6"), "RelationshipRequirementsText")
	else:
		app.label_at(app.tx("ui.relationship.conditions_hint", "具体条件只显示你已经能够理解的进度；未知人物和未来剧情不会提前公开。"), Vector2(75, 435), 18, Color("b9cecb"), 1040)
	app.button_at(app.tx("ui.relationship.return", "← 同事关系列表"), Vector2(60, 713), Vector2(220, 40), app.show_office_relationships)

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
	var recorded_patients: Array[Dictionary] = []
	for patient in app.content.collections.patients:
		var patient_id := str(patient.id)
		if visit_for_patient(app, patient_id) == null and app.game.referral_doctor(patient_id).is_empty() and preparation_for_patient(app, patient_id) == null:
			continue
		recorded_patients.append(patient)
	if recorded_patients.is_empty():
		app.label_at(app.tx("ui.case.empty", "还没有可以归档的患者记录。完成接诊后，病例会自动出现在这里。"), Vector2(75, 230), 22, Color("f4f0e6"), 1000)
	elif recorded_patients.size() <= 6:
		for row in range(recorded_patients.size()):
			var patient: Dictionary = recorded_patients[row]
			var patient_id := str(patient.id)
			var case_data: Dictionary = app.game.patient_case(patient_id)
			var caption := "%s　/　%s　/　%s" % [patient.name, str(case_data.get("title", app.tx("ui.case.undetermined", "未定病例"))), case_status(app, patient_id)]
			var button: Button = app.button_at(caption, Vector2(75, 205 + row * 70), Vector2(1080, 55), app.show_office_case.bind(patient_id))
			button.name = "OfficeCase_" + patient_id
	else:
		var scroll := ScrollContainer.new()
		scroll.name = "OfficeCaseScroll"
		scroll.position = Vector2(55, 185)
		scroll.size = Vector2(1170, 460)
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		app.page.add_child(scroll)
		var content := Control.new()
		content.custom_minimum_size = Vector2(1140, max(460, recorded_patients.size() * 72 + 12))
		scroll.add_child(content)
		for row in range(recorded_patients.size()):
			var patient: Dictionary = recorded_patients[row]
			var patient_id := str(patient.id)
			var case_data: Dictionary = app.game.patient_case(patient_id)
			var caption := "%s　/　%s　/　%s" % [patient.name, str(case_data.get("title", app.tx("ui.case.undetermined", "未定病例"))), case_status(app, patient_id)]
			var button: Button = app.button_at(caption, Vector2.ZERO, Vector2(1080, 56), app.show_office_case.bind(patient_id))
			button.name = "OfficeCase_" + patient_id
			app.page.remove_child(button)
			content.add_child(button)
			button.position = Vector2(20, 10 + row * 72)
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
	app.base(str(patient.name) + app.tx("ui.case.file_suffix", " · 病例档案"), app.tx("ui.case.age_status", "%s岁 / %s") % [int(patient.age), case_status(app, patient_id)], false, "player_office")
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
		var button: Button = app.button_at(app.tx("ui.action.detail", "%s　·　%s分钟\n%s") % [action.label, int(action.minutes), effect_text(app, action.get("effects", {}))], Vector2(70 + (i % 2) * 575, 205 + (i / 2) * 115), Vector2(540, 88), app.perform_time_event.bind(str(action.id), "player_office"))
		button.name = "OfficeAction_" + str(action.id)
	app.label_at(app.tx("ui.action.note", "行动可能跨过下班时间；完成后按现有时间系统进入下一天。"), Vector2(75, 610), 18, Color("c2d2cc"), 980)
	return_button(app)
