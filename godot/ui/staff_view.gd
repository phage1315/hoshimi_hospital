extends RefCounted
const StaffPatientView = preload("res://godot/ui/staff_patient_view.gd")

const SKILL_LABELS := {
	"surgery": "手术技巧", # localization-fallback-map
	"teamwork": "团队协作", # localization-fallback-map
	"calmness": "冷静", # localization-fallback-map
	"patient_care": "患者照护", # localization-fallback-map
	"instrument_handling": "器械操作", # localization-fallback-map
} # localization-fallback-map

const LABELS := {
	"afraid": "害怕", # localization-fallback-map
	"amused": "忍俊不禁", # localization-fallback-map
	"anesthetized": "麻醉沉睡", # localization-fallback-map
	"angry": "生气", # localization-fallback-map
	"annoyed": "不悦", # localization-fallback-map
	"asleep": "熟睡", # localization-fallback-map
	"awake": "清醒", # localization-fallback-map
	"blank": "放空", # localization-fallback-map
	"blurred_focus": "视线失焦", # localization-fallback-map
	"blushing_happy": "脸红欣喜", # localization-fallback-map
	"bored": "百无聊赖", # localization-fallback-map
	"brave": "强装镇定", # localization-fallback-map
	"bright": "明朗", # localization-fallback-map
	"calm": "沉着", # localization-fallback-map
	"cap_critique": "严肃点评", # localization-fallback-map
	"cap_shy": "微赧", # localization-fallback-map
	"cap_smile": "浅笑", # localization-fallback-map
	"cheerful": "开朗", # localization-fallback-map
	"closed_eye_smile": "弯眼微笑", # localization-fallback-map
	"cold": "冷淡", # localization-fallback-map
	"competitive_smile": "好胜笑意", # localization-fallback-map
	"crying": "落泪", # localization-fallback-map
	"depressed": "消沉", # localization-fallback-map
	"determined": "坚定", # localization-fallback-map
	"drowsy": "困倦", # localization-fallback-map
	"dry_smile": "苦笑", # localization-fallback-map
	"embarrassed": "难为情", # localization-fallback-map
	"excited": "兴奋", # localization-fallback-map
	"exhausted": "精疲力尽", # localization-fallback-map
	"expectant": "期待", # localization-fallback-map
	"focused": "专注", # localization-fallback-map
	"general_anesthesia": "全麻诱导", # localization-fallback-map
	"general_anesthesia_pre_induction": "麻醉前准备", # localization-fallback-map
	"gentle_smile": "温柔微笑", # localization-fallback-map
	"guarded": "戒备", # localization-fallback-map
	"hair_down_smile": "散发微笑", # localization-fallback-map
	"hair_down_wave": "散发招手", # localization-fallback-map
	"happy": "开心", # localization-fallback-map
	"hurt": "委屈", # localization-fallback-map
	"impatient": "不耐烦", # localization-fallback-map
	"joyful": "欢欣", # localization-fallback-map
	"laugh": "轻笑", # localization-fallback-map
	"masked_bright": "口罩·明朗", # localization-fallback-map
	"masked_focused": "口罩·专注", # localization-fallback-map
	"masked_hesitant": "口罩·迟疑", # localization-fallback-map
	"masked_smile": "口罩·笑意", # localization-fallback-map
	"masked_tense": "口罩·紧绷", # localization-fallback-map
	"masked_warm": "口罩·温和", # localization-fallback-map
	"nausea": "恶心不适", # localization-fallback-map
	"near_collapse": "几近虚脱", # localization-fallback-map
	"nervous": "紧张", # localization-fallback-map
	"neutral": "平静", # localization-fallback-map
	"nostalgic": "怀念", # localization-fallback-map
	"observing": "审视观察", # localization-fallback-map
	"pain": "疼痛", # localization-fallback-map
	"pale": "脸色苍白", # localization-fallback-map
	"pensive": "沉思", # localization-fallback-map
	"pharm_bright": "明快", # localization-fallback-map
	"pharm_playful": "调侃", # localization-fallback-map
	"pharm_professional": "干练", # localization-fallback-map
	"pharm_smile": "微笑", # localization-fallback-map
	"pharm_surprised": "惊讶", # localization-fallback-map
	"pharm_thoughtful": "若有所思", # localization-fallback-map
	"playful": "俏皮", # localization-fallback-map
	"pleased": "满意", # localization-fallback-map
	"pout": "鼓脸", # localization-fallback-map
	"professional": "职业神情", # localization-fallback-map
	"proud": "自豪", # localization-fallback-map
	"relief": "如释重负", # localization-fallback-map
	"relieved": "安心", # localization-fallback-map
	"reluctant_cuff": "勉强配合", # localization-fallback-map
	"sad": "难过", # localization-fallback-map
	"serious": "认真", # localization-fallback-map
	"serious_blush": "端肃微红", # localization-fallback-map
	"shocked": "震惊", # localization-fallback-map
	"shy": "害羞", # localization-fallback-map
	"shy_earnest": "羞怯认真", # localization-fallback-map
	"shy_reproach": "嗔怪", # localization-fallback-map
	"small_smile": "浅笑", # localization-fallback-map
	"smile": "微笑", # localization-fallback-map
	"soft": "柔和", # localization-fallback-map
	"soft_smile": "轻柔微笑", # localization-fallback-map
	"sparkle": "眼睛发亮", # localization-fallback-map
	"startled": "吃惊", # localization-fallback-map
	"stern": "严厉", # localization-fallback-map
	"strain": "吃力", # localization-fallback-map
	"surprised": "惊讶", # localization-fallback-map
	"talking": "交谈", # localization-fallback-map
	"tearful": "含泪", # localization-fallback-map
	"teasing": "打趣", # localization-fallback-map
	"tense": "紧绷", # localization-fallback-map
	"terrified": "惊恐", # localization-fallback-map
	"thoughtful": "思索", # localization-fallback-map
	"tired": "疲惫", # localization-fallback-map
	"touched": "触动", # localization-fallback-map
	"troubled": "困扰", # localization-fallback-map
	"warm": "眼含笑意", # localization-fallback-map
	"worried": "担忧", # localization-fallback-map
	"wry_smile": "无奈苦笑", # localization-fallback-map
} # localization-fallback-map

const OUTFITS := {
	"adult_nude": "私密姿态", # localization-fallback-map
	"casual": "春夏私服", # localization-fallback-map
	"casual_winter": "秋冬私服", # localization-fallback-map
	"changing": "更衣准备", # localization-fallback-map
	"date_cardigan": "约会针织衫", # localization-fallback-map
	"director_suit": "院长正装", # localization-fallback-map
	"interview": "面谈正装", # localization-fallback-map
	"intraoperative": "术中状态", # localization-fallback-map
	"intraoperative_avatar": "术中头像", # localization-fallback-map
	"lv4_apron": "清晨围裙", # localization-fallback-map
	"lv4_home": "自宅散发", # localization-fallback-map
	"lv4_morning": "清晨居家", # localization-fallback-map
	"lv4_outing": "外出风衣", # localization-fallback-map
	"operating_patient": "手术患者服", # localization-fallback-map
	"operating_table": "手术台 · 仰卧位", # localization-fallback-map
	"operating_table_lithotomy": "手术台 · 截石位", # localization-fallback-map
	"or_cap": "手术帽着装", # localization-fallback-map
	"or_table_awake": "手术台 · 清醒", # localization-fallback-map
	"patient_gown": "住院病号服", # localization-fallback-map
	"pharmacist": "药剂师白衣", # localization-fallback-map
	"postop_patient": "术后观察服", # localization-fallback-map
	"postop_recovery": "术后恢复", # localization-fallback-map
	"preop_patient": "术前病号服", # localization-fallback-map
	"preop_patient_gown": "术前检查病号服", # localization-fallback-map
	"sample_gown": "检查服", # localization-fallback-map
	"scrubs": "刷手服 · 帽子口罩", # localization-fallback-map
	"scrubs_masked": "刷手服 · 佩戴口罩", # localization-fallback-map
	"splash": "麻醉特写", # localization-fallback-map
	"sterile": "无菌手术袍 · 手套", # localization-fallback-map
	"uniform": "护士服", # localization-fallback-map
	"vintage_cream_gown": "米白礼服裙", # localization-fallback-map
	"ward": "病房病号服", # localization-fallback-map
	"ward_preparation": "病房术前准备", # localization-fallback-map
	"white_coat": "白大褂", # localization-fallback-map
	"yukata": "浴衣", # localization-fallback-map
} # localization-fallback-map

const INTERNAL_NON_WARDROBE_OUTFITS := [
	"intraoperative_avatar",
	"splash",
	"chibi_icon",
]

const PATIENT_STAGE_OUTFITS := [
	"ward",
	"ward_preparation",
	"patient_gown",
	"preop_patient",
	"preop_patient_gown",
	"sample_gown",
	"operating_patient",
	"operating_table",
	"operating_table_lithotomy",
	"or_table_awake",
	"intraoperative",
	"postop_patient",
	"postop_recovery",
]

static func expression_label(app: Control, id: String) -> String:
	return app.tx("ui.staff.expression." + id, str(LABELS.get(id, id)))

static func outfit_label(app: Control, id: String) -> String:
	return app.tx("ui.staff.outfit." + id, str(OUTFITS.get(id, id)))

static func outfit_allowed_in_profile(app: Control, actor_id: String, candidate: String, explicit_outfit: String) -> bool:
	if not explicit_outfit.is_empty() and candidate == explicit_outfit:
		return true
	if candidate in INTERNAL_NON_WARDROBE_OUTFITS:
		return false
	if candidate == "adult_nude":
		return app.game.free_h_relationship_qualified(actor_id)
	if actor_id == "doc_artoria" and candidate in ["lv4_outing", "lv4_home", "lv4_apron", "lv4_morning"]:
		return app.game.story_flag("artoria_lv4_complete") or app.game.character_event_done("artoria_lv4_just_artoria")
	if candidate in PATIENT_STAGE_OUTFITS:
		return app.game.staff_patient_unlocked(actor_id)
	return true

static func format_age_value(person: Dictionary) -> String:
	if person.has("public_age_label"):
		return str(person.public_age_label)
	var raw_age: Variant = person.get("age", "")
	if raw_age is int or raw_age is float:
		return str(int(raw_age))
	return str(raw_age)

static func skills_summary(app: Control, person: Dictionary) -> String:
	var skills: Dictionary = person.get("skills", {})
	var entries: Array[String] = []
	var keys := ["surgery", "teamwork", "calmness", "patient_care", "instrument_handling"]
	for skill_id in keys:
		if str(person.get("profession", "")) == "doctor" and skill_id in ["patient_care", "instrument_handling"]:
			continue
		var label_key: String = "ui.staff.skill." + str(skill_id)
		var fallback_name: String = str(SKILL_LABELS.get(skill_id, skill_id))
		var numeric_value := int(round(float(skills.get(skill_id, 0))))
		entries.append("%s %d" % [app.tx(label_key, fallback_name), numeric_value])
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
	var outfit: String = str(person.visuals.default_outfit) if requested_outfit.is_empty() else requested_outfit
	var variants: Array[String] = []
	var outfits: Array[String] = []
	for key in person.visuals.portraits:
		var candidate: String = str(key).get_slice("/", 0)
		if not outfit_allowed_in_profile(app, id, candidate, requested_outfit):
			continue
		if not outfits.has(candidate):
			outfits.append(candidate)
	if not outfits.has(outfit) and not outfits.is_empty():
		outfit = outfits[0]
	for key in person.visuals.portraits:
		var candidate: String = str(key).get_slice("/", 0)
		if candidate == outfit and str(key).contains("/"):
			var expr_id: String = str(key).get_slice("/", 1)
			if not variants.has(expr_id):
				variants.append(expr_id)
	if not variants.has(expression):
		expression = "neutral" if variants.has("neutral") or variants.is_empty() else variants[0]
	app.base(person.name, app.tx("ui.staff.header", "%s / %s岁") % [person.specialty, format_age_value(person)], true, app.background_for_location(from_location))
	app.page.set_meta("voice_staff_id", id)
	app.page.set_meta("voice_staff_outfit", outfit)
	app.page.set_meta("voice_staff_expression", expression)
	app.add_portrait(person, expression, outfit)
	if app.game.can_book_free_h(id, from_location):
		var booked: bool = str(app.game.free_h_booking.get("actor_id", "")) == id
		var caption: String = app.tx("ui.free_h.cancel", "取消今晚的约定") if booked else app.tx("ui.free_h.invite", "约今晚下班后一起过夜")
		var action: Callable = app.cancel_free_h_booking.bind(app.show_staff.bind(id, from_location)) if booked else app.request_free_h_booking.bind(id, from_location)
		app.button_at(caption, Vector2(65, 160), Vector2(440 if app.game.staff_patient_unlocked(id) else 640, 42), action).name = "FreeHBooking"
	elif app.game.free_h_relationship_qualified(id) and not app.game.free_h_unlocked(id):
		var pending = app.button_at(app.tx("ui.free_h.pending_assets", "亲密事件已解锁 · 素材待补"), Vector2(65, 160), Vector2(440 if app.game.staff_patient_unlocked(id) else 640, 42), func(): pass)
		pending.name = "FreeHBookingPendingAssets"
		pending.disabled = true
	if app.game.staff_patient_unlocked(id):
		app.button_at(app.tx("ui.staff_patient.invite", "邀请手术"), Vector2(515, 160), Vector2(190, 42), StaffPatientView.invite.bind(app, id)).name = "StaffPatientInvite"
	var portrait = app.page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(740, 165)
		portrait.size = Vector2(470, 500)
	var personality_label: Label = app.label_at(person.personality, Vector2(65, 215), 19, Color("f4f0e6"), 640)
	personality_label.name = "StaffPersonality"
	for font_size in [19, 18, 17, 16, 15]:
		personality_label.add_theme_font_size_override("font_size", font_size)
		if personality_label.get_minimum_size().y <= 90:
			break
	personality_label.size.y = 90
	var skills_label: Label = app.label_at(skills_summary(app, person), Vector2(65, 315), 17, Color("d3dfd9"), 640)
	skills_label.name = "StaffSkills"
	skills_label.size.y = 56
	var relation: Dictionary = app.game.relation_for(id)
	if not relation.is_empty():
		var level := int(relation.get("level", 0))
		var relation_text: String = app.tx("ui.staff.not_met", "尚未认识")
		var rank_note: String = app.tx("ui.staff.rank_ready", " · 关系可以进一步加深") if app.game.rank_ready(id) else ""
		if bool(relation.get("met", false)) and level == 0:
			if "relationship_progression_locked" in person.get("flags", []):
				relation_text = app.tx("ui.staff.met_locked", "已经认识 · 访问研究同事 · 当前无关系路线")
			else:
				relation_text = app.tx("ui.staff.met_colleague", "已经认识 · 普通同事 · 尚未建立羁绊") + rank_note
		elif bool(relation.get("met", false)):
			var stage_labels := {1: app.tx("ui.staff.rank.1", "开始有好感"), 2: app.tx("ui.staff.rank.2", "相互信任"), 3: app.tx("ui.staff.rank.3", "暧昧"), 4: app.tx("ui.staff.rank.4", "亲密关系"), 5: app.tx("ui.staff.rank.5", "深层羁绊")}
			if "professional_friendship_only" in person.get("flags", []):
				stage_labels = {1: app.tx("ui.staff.professional_rank.1", "建立专业信任"), 2: app.tx("ui.staff.professional_rank.2", "可靠合作伙伴"), 3: app.tx("ui.staff.professional_rank.3", "专业友谊")}
			var stage_label: String = stage_labels.get(level, app.tx("ui.staff.rank_deeper", "关系加深"))
			if level >= 4 and str(relation.get("route", "colleague")) == "romance":
				stage_label = app.tx("ui.staff.lover", "恋人") if level == 4 else app.tx("ui.staff.lover_deep", "恋人 · 深层羁绊")
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
	outfit_picker.fit_to_longest_item = false
	outfit_picker.clip_text = true
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
	expression_picker.fit_to_longest_item = false
	expression_picker.clip_text = true
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
	if OS.is_debug_build() and id in ["doc_aoi", "nurse_haru"]:
		app.button_at(app.tx("ui.staff.event_test", "事件测试  →"), Vector2(840, 88), Vector2(195, 44), app.show_character_events.bind(id, from_location))
	app.button_at(app.tx("ui.common.return", "← 返回"), Vector2(1055, 88), Vector2(160, 44), app.show_location.bind(from_location))
