extends RefCounted
const StaffPatientView = preload("res://godot/ui/staff_patient_view.gd")
const LABELS = {"neutral":"平静", "smile":"微笑", "serious":"认真", "worried":"担忧", "surprised":"惊讶", "tired":"疲惫", "focused":"专注", "warm":"眼含笑意"} # localization-fallback-map
const OUTFITS = {"white_coat":"白大褂", "casual":"私服", "uniform":"护士服", "pharmacist":"药剂师白衣", "scrubs":"刷手服 · 帽子口罩", "sterile":"无菌手术袍 · 手套"} # localization-fallback-map

static func expression_label(app: Control, id: String) -> String:
	return app.tx("ui.staff.expression." + id, str(LABELS.get(id, id)))

static func outfit_label(app: Control, id: String) -> String:
	return app.tx("ui.staff.outfit." + id, str(OUTFITS.get(id, id)))

static func skills_summary(app: Control, person: Dictionary) -> String:
	var skills: Dictionary = person.get("skills", {})
	var entries: Array[String] = []
	var keys := ["surgery", "teamwork", "calmness", "patient_care", "instrument_handling"]
	for skill_id in keys:
		if str(person.get("profession", "")) == "doctor" and skill_id in ["patient_care", "instrument_handling"]:
			continue
		var label_key: String = "ui.staff.skill." + str(skill_id)
		entries.append("%s %s" % [app.tx(label_key, skill_id), str(skills.get(skill_id, 0))])
	var lines: Array[String] = []
	for index in range(entries.size()):
		if index % 3 == 0:
			lines.append("")
		elif not lines.back().is_empty():
			lines[lines.size() - 1] += "   /   "
		lines[lines.size() - 1] += entries[index]
	return "\n".join(lines)

static func render(app: Control, id: String, from_location: String, expression: String, requested_outfit: String) -> void:
	var person: Dictionary = app.content.find_record("staff", id)
	var outfit: String = person.visuals.default_outfit if requested_outfit.is_empty() else requested_outfit
	var variants: Array[String] = []
	var outfits: Array[String] = []
	for key in person.visuals.portraits:
		var candidate: String = key.get_slice("/", 0)
		if not outfits.has(candidate):
			outfits.append(candidate)
		if candidate == outfit:
			variants.append(key.get_slice("/", 1))
	if not variants.has(expression):
		expression = "neutral"
	app.base(person.name, app.tx("ui.staff.header", "%s / %s岁") % [person.specialty, person.age], true, app.background_for_location(from_location))
	app.add_portrait(person, expression, outfit)
	if app.game.can_book_free_h(id, from_location):
		var booked: bool = str(app.game.free_h_booking.get("actor_id", "")) == id
		var caption: String = app.tx("ui.free_h.cancel", "取消今晚的约定") if booked else app.tx("ui.free_h.invite", "约今晚下班后一起过夜")
		var action: Callable = app.cancel_free_h_booking.bind(app.show_staff.bind(id, from_location)) if booked else app.request_free_h_booking.bind(id, from_location)
		app.button_at(caption, Vector2(65, 160), Vector2(440 if app.game.staff_patient_unlocked(id) else 640, 42), action).name = "FreeHBooking"
	if app.game.staff_patient_unlocked(id):
		app.button_at(app.tx("ui.staff_patient.invite", "邀请手术"), Vector2(515, 160), Vector2(190, 42), StaffPatientView.invite.bind(app, id)).name = "StaffPatientInvite"
	var portrait = app.page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(740, 165)
		portrait.size = Vector2(470, 500)
	var personality_label: Label = app.label_at(person.personality, Vector2(65, 215), 19, Color("f4f0e6"), 640)
	personality_label.size.y = 64
	var skills_label: Label = app.label_at(skills_summary(app, person), Vector2(65, 290), 17, Color("d3dfd9"), 640)
	skills_label.size.y = 56
	var relation: Dictionary = app.game.relation_for(id)
	if not relation.is_empty():
		var level := int(relation.get("level", 0))
		var relation_text: String = app.tx("ui.staff.not_met", "尚未认识")
		if bool(relation.get("met", false)) and level == 0:
			relation_text = app.tx("ui.staff.met_locked", "已经认识 · 访问研究同事 · 当前无关系路线") if "relationship_progression_locked" in person.get("flags", []) else app.tx("ui.staff.met_colleague", "已经认识 · 普通同事 · 尚未建立羁绊")
		elif bool(relation.get("met", false)):
			var stage_labels := {1: app.tx("ui.staff.rank.1", "开始有好感"), 2: app.tx("ui.staff.rank.2", "相互信任"), 3: app.tx("ui.staff.rank.3", "暧昧"), 4: app.tx("ui.staff.rank.4", "亲密关系"), 5: app.tx("ui.staff.rank.5", "深层羁绊")}
			if "professional_friendship_only" in person.get("flags", []):
				stage_labels = {1: app.tx("ui.staff.professional_rank.1", "建立专业信任"), 2: app.tx("ui.staff.professional_rank.2", "可靠合作伙伴"), 3: app.tx("ui.staff.professional_rank.3", "专业友谊")}
			var stage_label: String = stage_labels.get(level, app.tx("ui.staff.rank_deeper", "关系加深"))
			if level >= 4 and str(relation.get("route", "colleague")) == "romance":
				stage_label = app.tx("ui.staff.lover", "恋人") if level == 4 else app.tx("ui.staff.lover_deep", "恋人 · 深层羁绊")
			var rank_note: String = app.tx("ui.staff.rank_ready", " · 关系可以进一步加深") if app.game.rank_ready(id) else ""
			relation_text = app.tx("ui.staff.relationship", "关系 Lv.%s · %s%s") % [level, stage_label, rank_note]
		if bool(relation.get("met", false)):
			relation_text += app.tx("ui.staff.affection_tendency", " · 倾向：%s") % app.affection_tendency(int(relation.get("affection", 0)))
		var relation_label: Label = app.label_at(relation_text, Vector2(65, 379), 19, Color("cbbc9c"), 640)
		relation_label.size.y = 54
	app.label_at(app.tx("ui.staff.outfit", "服装"), Vector2(65, 445), 18, Color("cbbc9c"), 640)
	var outfit_picker := OptionButton.new()
	outfit_picker.name = "StaffOutfitPicker"
	outfit_picker.position = Vector2(65, 478)
	outfit_picker.size = Vector2(640, 46)
	for index in range(outfits.size()):
		var value: String = outfits[index]
		outfit_picker.add_item(outfit_label(app, value))
		outfit_picker.set_item_metadata(index, value)
		if value == outfit:
			outfit_picker.select(index)
	outfit_picker.add_theme_color_override("font_color", Color("f4f0e6"))
	outfit_picker.add_theme_stylebox_override("normal", app.panel_style(Color("203e48")))
	outfit_picker.add_theme_stylebox_override("hover", app.panel_style(Color("365963"), Color("d1c19e")))
	outfit_picker.add_theme_stylebox_override("focus", app.panel_style(Color("365963"), Color("f3dbac")))
	if app.content.localizer.locale == "en":
		preload("res://godot/ui/button_text.gd").fit(outfit_picker, outfit_picker.size, outfit_picker.get_theme_font_size("font_size"))
	outfit_picker.item_selected.connect(func(index: int) -> void:
		app.show_staff(id, from_location, "neutral", str(outfit_picker.get_item_metadata(index)))
	)
	app.page.add_child(outfit_picker)
	app.label_at(app.tx("ui.staff.expression", "表情"), Vector2(65, 549), 18, Color("cbbc9c"), 640)
	var expression_picker := OptionButton.new()
	expression_picker.name = "StaffExpressionPicker"
	expression_picker.position = Vector2(65, 582)
	expression_picker.size = Vector2(640, 46)
	for index in range(variants.size()):
		var variant: String = variants[index]
		expression_picker.add_item(expression_label(app, variant))
		expression_picker.set_item_metadata(index, variant)
		if variant == expression:
			expression_picker.select(index)
	expression_picker.add_theme_color_override("font_color", Color("f4f0e6"))
	expression_picker.add_theme_stylebox_override("normal", app.panel_style(Color("203e48")))
	expression_picker.add_theme_stylebox_override("hover", app.panel_style(Color("365963"), Color("d1c19e")))
	expression_picker.add_theme_stylebox_override("focus", app.panel_style(Color("365963"), Color("f3dbac")))
	if app.content.localizer.locale == "en":
		preload("res://godot/ui/button_text.gd").fit(expression_picker, expression_picker.size, expression_picker.get_theme_font_size("font_size"))
	expression_picker.item_selected.connect(func(index: int) -> void:
		app.show_staff(id, from_location, str(expression_picker.get_item_metadata(index)), outfit)
	)
	app.page.add_child(expression_picker)
	app.label_at("%s / %s" % [outfit_label(app, outfit), expression_label(app, expression)], Vector2(795, 687), 18, Color("cbbc9c"), 420)
	if id in ["doc_aoi", "nurse_haru"]:
		app.button_at(app.tx("ui.staff.event_test", "事件测试  →"), Vector2(840, 88), Vector2(195, 44), app.show_character_events.bind(id, from_location))
	app.button_at(app.tx("ui.common.return", "← 返回"), Vector2(1055, 88), Vector2(160, 44), app.show_location.bind(from_location))
