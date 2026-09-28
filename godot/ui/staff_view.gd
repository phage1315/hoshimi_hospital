extends RefCounted
const LABELS = {"neutral":"平静", "smile":"微笑", "serious":"认真", "worried":"担忧", "surprised":"惊讶", "tired":"疲惫", "focused":"专注", "warm":"眼含笑意"}
const OUTFITS = {
	"white_coat":"白大褂",
	"uniform":"护士服",
	"pharmacist":"药剂师白衣",
	"scrubs":"刷手服 · 帽子口罩",
	"sterile":"无菌手术袍 · 手套"
}

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
	app.base(person.name, "%s / %s岁" % [person.specialty, person.age], true, app.background_for_location(from_location))
	app.add_portrait(person, expression, outfit)
	var portrait = app.page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(740, 165)
		portrait.size = Vector2(470, 500)
	app.label_at(person.personality, Vector2(65, 215), 27, Color("f4f0e6"), 640)
	app.label_at("团队协作 %s   /   沉着 %s\n患者照护 %s   /   器械配合 %s" % [person.skills.teamwork, person.skills.calmness, person.skills.patient_care, person.skills.instrument_handling], Vector2(65, 280), 22, Color("d3dfd9"), 640)
	var relation: Dictionary = app.game.relation_for(id)
	if not relation.is_empty():
		var level := int(relation.get("level", 0))
		var relation_text := "尚未认识"
		if bool(relation.get("met", false)) and level == 0:
			relation_text = "已经认识 · 普通同事 · 尚未建立羁绊"
		elif bool(relation.get("met", false)):
			var stage_labels := {1: "开始有好感", 2: "相互信任", 3: "暧昧", 4: "亲密关系", 5: "深层羁绊"}
			var stage_label: String = stage_labels.get(level, "关系加深")
			if level >= 4 and str(relation.get("route", "colleague")) == "romance":
				stage_label = "恋人" if level == 4 else "恋人 · 深层羁绊"
			var rank_note: String = " · 关系可以进一步加深" if app.game.rank_ready(id) else ""
			relation_text = "关系 Lv.%s · %s%s" % [level, stage_label, rank_note]
		app.label_at(relation_text, Vector2(65, 379), 20, Color("cbbc9c"), 640)
	app.label_at("服装", Vector2(65, 445), 18, Color("cbbc9c"), 640)
	for i in range(outfits.size()):
		var value: String = outfits[i]
		var button: Button = app.button_at(OUTFITS.get(value, value), Vector2(65 + i * 325, 478), Vector2(310, 48), app.show_staff.bind(id, from_location, "neutral", value))
		button.name = "Outfit_" + value
		button.disabled = value == outfit
	app.label_at("表情", Vector2(65, 549), 18, Color("cbbc9c"), 640)
	for i in range(variants.size()):
		var variant: String = variants[i]
		var button: Button = app.button_at(LABELS.get(variant, variant), Vector2(65 + (i % 3) * 218, 582 + (i / 3) * 58), Vector2(204, 46), app.show_staff.bind(id, from_location, variant, outfit))
		button.name = "Expression_" + variant
		button.disabled = variant == expression
	app.label_at("%s / %s" % [OUTFITS.get(outfit, outfit), LABELS.get(expression, expression)], Vector2(795, 687), 18, Color("cbbc9c"), 420)
	if id in ["doc_aoi", "nurse_haru"]:
		app.button_at("事件测试  →", Vector2(840, 88), Vector2(195, 44), app.show_character_events.bind(id, from_location))
	app.button_at("← 返回", Vector2(1055, 88), Vector2(160, 44), app.show_location.bind(from_location))
