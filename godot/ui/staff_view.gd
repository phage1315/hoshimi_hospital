extends RefCounted
const LABELS = {"neutral":"平静", "smile":"微笑", "serious":"认真", "worried":"担忧", "surprised":"惊讶", "tired":"疲惫", "focused":"专注", "warm":"眼含笑意"} # localization-fallback-map
const OUTFITS = {"white_coat":"白大褂", "casual":"私服", "uniform":"护士服", "pharmacist":"药剂师白衣", "scrubs":"刷手服 · 帽子口罩", "sterile":"无菌手术袍 · 手套"} # localization-fallback-map

static func expression_label(app: Control, id: String) -> String:
	return app.tx("ui.staff.expression." + id, str(LABELS.get(id, id)))

static func outfit_label(app: Control, id: String) -> String:
	return app.tx("ui.staff.outfit." + id, str(OUTFITS.get(id, id)))

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
	var portrait = app.page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(740, 165)
		portrait.size = Vector2(470, 500)
	app.label_at(person.personality, Vector2(65, 215), 27, Color("f4f0e6"), 640)
	app.label_at(app.tx("ui.staff.skills", "团队协作 %s   /   沉着 %s\n患者照护 %s   /   器械配合 %s") % [person.skills.teamwork, person.skills.calmness, person.skills.patient_care, person.skills.instrument_handling], Vector2(65, 280), 22, Color("d3dfd9"), 640)
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
		app.label_at(relation_text, Vector2(65, 379), 20, Color("cbbc9c"), 640)
	app.label_at(app.tx("ui.staff.outfit", "服装"), Vector2(65, 445), 18, Color("cbbc9c"), 640)
	for i in range(outfits.size()):
		var value: String = outfits[i]
		var button: Button = app.button_at(outfit_label(app, value), Vector2(65 + i * 325, 478), Vector2(310, 48), app.show_staff.bind(id, from_location, "neutral", value))
		button.name = "Outfit_" + value
		button.disabled = value == outfit
	app.label_at(app.tx("ui.staff.expression", "表情"), Vector2(65, 549), 18, Color("cbbc9c"), 640)
	for i in range(variants.size()):
		var variant: String = variants[i]
		var button: Button = app.button_at(expression_label(app, variant), Vector2(65 + (i % 3) * 218, 582 + (i / 3) * 58), Vector2(204, 46), app.show_staff.bind(id, from_location, variant, outfit))
		button.name = "Expression_" + variant
		button.disabled = variant == expression
	app.label_at("%s / %s" % [outfit_label(app, outfit), expression_label(app, expression)], Vector2(795, 687), 18, Color("cbbc9c"), 420)
	if id in ["doc_aoi", "nurse_haru"]:
		app.button_at(app.tx("ui.staff.event_test", "事件测试  →"), Vector2(840, 88), Vector2(195, 44), app.show_character_events.bind(id, from_location))
	app.button_at(app.tx("ui.common.return", "← 返回"), Vector2(1055, 88), Vector2(160, 44), app.show_location.bind(from_location))
