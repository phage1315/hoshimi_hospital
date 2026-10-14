extends RefCounted
const UI = preload("res://godot/ui/clinic_view.gd")

static func render(app: Control, prep: RefCounted) -> void:
	UI.panel(app, Vector2(55, 195), Vector2(560, 290))
	UI.panel(app, Vector2(635, 195), Vector2(590, 290))
	app.scrollable_text_at(app.tx("ui.result.success", "✓ 手术成功"), Vector2(75, 211), Vector2(520, 45), 25, Color("e8cfaa"), "SurgeryResultTitle")
	app.scrollable_text_at(prep.interaction_summary(), Vector2(75, 270), Vector2(520, 115), 19, Color("e1e4db"), "SurgeryResultSummary")
	if prep.pilot_surgery():
		app.scrollable_text_at(app.tx("ui.surgery.quality_score", "手术质量 Surgical Quality：%s（%s分）") % [prep.surgical_quality_grade(), prep.surgical_quality_score()], Vector2(75, 399), Vector2(520, 65), 22, Color("e8cfaa"), "SurgicalQualityResult")
	var experience: String = app.tx("ui.surgery.patient_experience", "患者体验评级：%s") % prep.patient_experience_grade_label()
	app.scrollable_text_at(experience + "\n" + prep.patient_experience_result_text(), Vector2(655, 215), Vector2(550, 90), 19, Color("e8cfaa"), "PatientExperienceResult")
	var times: String = app.tx("ui.result.times", "手术耗时  %s\n术后交接与整理  %s\n本次合计  %s") % [prep.duration_text(prep.procedure_total_minutes()), prep.duration_text(prep.POSTOPERATIVE_WRAP_UP_MINUTES), prep.duration_text(prep.surgery_settlement_total_minutes())]
	app.scrollable_text_at(times, Vector2(655, 318), Vector2(550, 100), 18, Color("d3dfd9"), "SurgerySettlementTime")
	app.scrollable_text_at(app.tx("ui.auto.21715e65478b", "恐惧 %s　痛苦 %s　尊严 %s　配合 %s") % [prep.fear, prep.pain, prep.dignity, prep.cooperation_value()], Vector2(655, 438), Vector2(550, 32), 17, Color("c2d2cc"), "SurgeryResultMetrics")
	app.button_at(app.tx("ui.result.settle", "结算并查看成长  →"), Vector2(55, 500), Vector2(1170, 48), app.finish_surgery_and_return).name = "SurgeryResultReturn"
	UI.panel(app, Vector2(55, 562), Vector2(1170, 138))
	app.label_at(app.tx("ui.auto.77a3ebc10ddf", "互动记录"), Vector2(75, 573), 19, Color("e8cfaa"), 1120).name = "PreopRecordSpeaker"
	var record: String = prep.surgery_display_text(str(prep.feedback)).replace("{patient}", prep.patient_name)
	if not prep.surgery_state_summary().is_empty():
		record += "\n" + prep.surgery_state_summary()
	app.scrollable_text_at(record, Vector2(75, 608), Vector2(1120, 78), 18, Color("f4f0e6"), "PreopRecordText")
	app.button_at(app.tx("ui.auto.cdee65fb906e", "读档"), Vector2(55, 715), Vector2(120, 40), app.request_load)

static func capture(game: RefCounted, team: Dictionary) -> Dictionary:
	var result := {"surgery_xp": game.surgery_xp, "surgery_level": game.surgery_level(), "leadership_xp": game.leadership_xp, "leadership_level": game.leadership_level(), "members": []}
	var seen := {}
	for role in team:
		var id := str(team[role])
		var skill: String = game.role_training_skill(str(role))
		var key := id + ":" + skill
		if id.is_empty() or skill.is_empty() or seen.has(key):
			continue
		seen[key] = true
		result.members.append({"id": id, "skill": skill, "level": game.staff_skill_value(id, skill), "credits": int(game.staff_training_credits.get(id, {}).get(skill, 0))})
	return result

static func show_growth(app: Control, before: Dictionary, next_action: Callable) -> void:
	if app.page.get_node_or_null("SurgeryGrowthSplash") != null:
		return
	var overlay := Control.new()
	overlay.name = "SurgeryGrowthSplash"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 30
	app.page.add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.025, 0.04, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var frame: Panel = UI.panel(app, Vector2(135, 145), Vector2(1010, 510))
	frame.reparent(overlay, false)
	var title: Label = app.label_at(app.tx("ui.result.growth", "本次手术 · 成长结算"), Vector2(165, 170), 28, Color("e8cfaa"), 940)
	title.reparent(overlay, false)
	var xp_text: String = app.tx("ui.result.player_growth", "手术经验 +%s\nLv.%s → Lv.%s（+%s）\n\n领导力经验 +%s\nLv.%s → Lv.%s（+%s）") % [app.game.surgery_xp - before.surgery_xp, before.surgery_level, app.game.surgery_level(), app.game.surgery_level() - before.surgery_level, "%.1f" % (app.game.leadership_xp - before.leadership_xp), before.leadership_level, app.game.leadership_level(), app.game.leadership_level() - before.leadership_level]
	var player: RichTextLabel = app.scrollable_text_at(xp_text, Vector2(165, 235), Vector2(400, 290), 23, Color("f4f0e6"), "SurgeryGrowthPlayer")
	player.reparent(overlay, false)
	var lines: Array[String] = [app.tx("ui.result.team_growth", "团队成长")]
	for member in before.members:
		var after: int = app.game.staff_skill_value(member.id, member.skill)
		var remaining := int(app.game.staff_training_credits.get(member.id, {}).get(member.skill, 0))
		var earned: int = remaining - int(member.credits)
		for level in range(int(member.level), after):
			earned += app.game.staff_training_credit_cost(level)
		var person: Dictionary = app.content.find_record("staff", member.id)
		var skill_name: String = app.tx("ui.result.skill_surgery", "手术") if member.skill == "surgery" else app.tx("ui.result.skill_instruments", "器械配合") if member.skill == "instrument_handling" else app.tx("ui.result.skill_teamwork", "团队协作")
		var member_text: String = app.tx("ui.result.member_growth", "%s · %s\n训练点 +%s　技能 %s → %s（+%s）") % [person.get("name", member.id), skill_name, earned, member.level, after, after - int(member.level)]
		member_text += "\n" + (app.tx("ui.result.cap", "已达培养上限") if after >= 90 else app.tx("ui.result.credit_progress", "下一级进度 %s / %s") % [remaining, app.game.staff_training_credit_cost(after)])
		lines.append(member_text)
	var team: RichTextLabel = app.scrollable_text_at("\n\n".join(lines), Vector2(605, 235), Vector2(510, 325), 17, Color("d3dfd9"), "SurgeryGrowthTeam")
	team.reparent(overlay, false)
	var button: Button = app.button_at(app.tx("ui.result.growth_continue", "确认成长，继续  →"), Vector2(165, 575), Vector2(950, 52), func():
		if not is_instance_valid(overlay) or not overlay.is_inside_tree():
			return
		overlay.get_parent().remove_child(overlay)
		overlay.queue_free()
		next_action.call())
	button.name = "SurgeryGrowthContinue"
	button.reparent(overlay, false)
	button.grab_focus()
