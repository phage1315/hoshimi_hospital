extends Control
const Loader = preload("res://godot/scripts/content_loader.gd")
const Session = preload("res://godot/systems/dialogue_session.gd")
const Backdrop = preload("res://godot/ui/backdrop.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const SaveStore = preload("res://godot/systems/save_store.gd")
const StaffView = preload("res://godot/ui/staff_view.gd")
const PreopView = preload("res://godot/ui/preop_view.gd")
const ClinicView = preload("res://godot/ui/clinic_view.gd")
const CharacterEvent = preload("res://godot/systems/character_event_session.gd")
const OperativeBackgrounds = preload("res://godot/systems/operative_backgrounds.gd")
const OperativeBackgroundBlur = preload("res://godot/ui/operative_background_blur.gdshader")
const ABDOMINAL_INCISION_VIDEO := "res://assets/animations/surgery/abdominal_scalpel_incision_v1.ogv"
const ABDOMINAL_INCISION_VIDEO_V2 := "res://assets/animations/surgery/abdominal_scalpel_incision_v2.ogv"
const ABDOMINAL_INCISION_VIDEO_V3 := "res://assets/animations/surgery/abdominal_scalpel_incision_v3.ogv"
const ABDOMINAL_INCISION_VIDEO_V4 := "res://assets/animations/surgery/abdominal_scalpel_incision_v4.ogv"
const ABDOMINAL_INCISION_VIDEO_V5 := "res://assets/animations/surgery/abdominal_scalpel_incision_v5.ogv"
const ABDOMINAL_INCISION_VIDEO_V6 := "res://assets/animations/surgery/abdominal_scalpel_incision_v6.ogv"
const ABDOMINAL_INCISION_VIDEO_V7 := "res://assets/animations/surgery/abdominal_scalpel_incision_v7.ogv"
const BREAST_INCISION_VIDEO := "res://assets/animations/surgery/breast_scalpel_incision_v1.ogv"
const BREAST_INCISION_VIDEO_V2 := "res://assets/animations/surgery/breast_scalpel_incision_v2.ogv"
const BREAST_INCISION_VIDEO_V3 := "res://assets/animations/surgery/breast_scalpel_incision_v3.ogv"
const BREAST_INCISION_VIDEO_V4 := "res://assets/animations/surgery/breast_scalpel_incision_v4.ogv"
const BREAST_INCISION_VIDEO_V5 := "res://assets/animations/surgery/breast_scalpel_incision_v5.ogv"
const BREAST_INCISION_VIDEO_V6 := "res://assets/animations/surgery/breast_scalpel_incision_v6.ogv"
const BREAST_INCISION_VIDEO_V7 := "res://assets/animations/surgery/breast_scalpel_incision_v7.ogv"
const BREAST_INCISION_VIDEO_V8 := "res://assets/animations/surgery/breast_scalpel_incision_v8.ogv"
const PELVIC_INCISION_VIDEO := "res://assets/animations/surgery/pelvic_scalpel_incision_v1.ogv"
const PELVIC_INCISION_VIDEO_V2 := "res://assets/animations/surgery/pelvic_scalpel_incision_v2.ogv"
const PELVIC_INCISION_VIDEO_V3 := "res://assets/animations/surgery/pelvic_scalpel_incision_v3.ogv"
const PELVIC_INCISION_VIDEO_V4 := "res://assets/animations/surgery/pelvic_scalpel_incision_v4.ogv"
const THORACIC_INCISION_VIDEO := "res://assets/animations/surgery/thoracic_scalpel_incision_v1.ogv"
const THORACIC_INCISION_VIDEO_V2 := "res://assets/animations/surgery/thoracic_scalpel_incision_v2.ogv"
const THORACIC_INCISION_VIDEO_V3 := "res://assets/animations/surgery/thoracic_scalpel_incision_v3.ogv"
const THORACIC_INCISION_VIDEO_V4 := "res://assets/animations/surgery/thoracic_scalpel_incision_v4.ogv"
const THORACIC_INCISION_VIDEO_V5 := "res://assets/animations/surgery/thoracic_scalpel_incision_v5.ogv"
const THORACIC_INCISION_VIDEO_V6 := "res://assets/animations/surgery/thoracic_scalpel_incision_v6.ogv"
const THORACIC_INCISION_VIDEO_V7 := "res://assets/animations/surgery/thoracic_scalpel_incision_v7.ogv"
const THORACIC_INCISION_VIDEO_V8 := "res://assets/animations/surgery/thoracic_scalpel_incision_v8.ogv"
const THORACIC_INCISION_VIDEO_V9 := "res://assets/animations/surgery/thoracic_scalpel_incision_v9.ogv"
const ABDOMINAL_INCISION_PROCEDURE_GROUPS := ["general_abdominal", "urologic", "vascular"]
const INCISION_VIDEO_POOLS := {
	"abdominal": [ABDOMINAL_INCISION_VIDEO, ABDOMINAL_INCISION_VIDEO_V2, ABDOMINAL_INCISION_VIDEO_V3, ABDOMINAL_INCISION_VIDEO_V4, ABDOMINAL_INCISION_VIDEO_V5, ABDOMINAL_INCISION_VIDEO_V6, ABDOMINAL_INCISION_VIDEO_V7],
	"breast": [BREAST_INCISION_VIDEO, BREAST_INCISION_VIDEO_V2, BREAST_INCISION_VIDEO_V3, BREAST_INCISION_VIDEO_V4, BREAST_INCISION_VIDEO_V5, BREAST_INCISION_VIDEO_V6, BREAST_INCISION_VIDEO_V7, BREAST_INCISION_VIDEO_V8],
	"pelvic": [PELVIC_INCISION_VIDEO, PELVIC_INCISION_VIDEO_V2, PELVIC_INCISION_VIDEO_V3, PELVIC_INCISION_VIDEO_V4],
	"thoracic": [THORACIC_INCISION_VIDEO, THORACIC_INCISION_VIDEO_V2, THORACIC_INCISION_VIDEO_V3, THORACIC_INCISION_VIDEO_V4, THORACIC_INCISION_VIDEO_V5, THORACIC_INCISION_VIDEO_V6, THORACIC_INCISION_VIDEO_V7, THORACIC_INCISION_VIDEO_V8, THORACIC_INCISION_VIDEO_V9],
}
var game = GameState.new()
var saves = SaveStore.new()
var content = Loader.new()
var session = Session.new()
var page: Control
var background: Control
var screen := "title"
var clinic_record_open := false
var clinic_record_stage := ""
var clinic_notes_seen: Dictionary = {}
var location_feedback := ""
var location_feedback_location := ""
var rooftop_actor_id := ""
var day_transition_next: Callable
var character_event_return_location := "lounge"
var character_event_return_preop_id := ""
var character_event_from_test := false
var gallery_replay_event: RefCounted
var gallery_replay_is_test := false
var gallery_replay_return_actor := ""
var examination_cg_next: Callable
var surgery_cg_next: Callable
var surgery_cg_last_path: Dictionary = {}
var ward_preparation_cg_next: Callable
var ward_preparation_cg_last_path: Dictionary = {}
var surgery_video_next: Callable
var incision_video_last_path: Dictionary = {}

func protagonist_name() -> String:
	return str(content.protagonist.get("name", "本多繁邦"))

func protagonist_professional_name() -> String:
	return str(content.protagonist.get("professional_name", "本多医生"))

func _ready() -> void:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["PingFang SC", "Noto Sans CJK SC", "Microsoft YaHei", "sans-serif"])
	var ui_theme := Theme.new()
	ui_theme.default_font = font
	ui_theme.default_font_size = 20
	theme = ui_theme
	if not content.load_all():
		base("内容读取失败", "请检查 data 目录")
		label_at("\n".join(content.errors), Vector2(70, 180), 22)
		return
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions)
	title_screen()

func panel_style(color: Color, border: Color = Color("718f92")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 22
	style.content_margin_right = 22
	return style

func base(title: String, subtitle: String, portrait: bool = false, background_id: String = "") -> void:
	if is_instance_valid(page):
		remove_child(page)
		page.queue_free()
	page = Control.new()
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(page)
	var authored_background := background_path(background_id)
	if not authored_background.is_empty():
		var image := TextureRect.new()
		image.name = "SceneBackground"
		image.texture = load("res://" + authored_background)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if background_id.begins_with("operating_team_"):
			var blur_material := ShaderMaterial.new()
			blur_material.shader = OperativeBackgroundBlur
			image.material = blur_material
		background = image
	else:
		background = Backdrop.new()
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		background.show_portrait = portrait
	page.add_child(background)
	var wash := ColorRect.new()
	# Finished background art should remain visible. Pages without art keep the
	# stronger geometric-placeholder wash used by the original prototype.
	var wash_alpha := 0.14 if not authored_background.is_empty() else (0.46 if background_id.begins_with("operating_team_") else 0.83 if screen not in ["dialogue", "encounter", "preop"] else 0.30)
	wash.color = Color(0.025, 0.075, 0.09, wash_alpha)
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(wash)
	label_at("H O S H I M I   /   星见医院", Vector2(54, 25), 16, Color("c9d5ca"))
	label_at(game.day_text() + "     /     四月 · " + game.clock_text(), Vector2(947, 25), 16, Color("c9d5ca"))
	label_at(title, Vector2(56, 88), 34)
	label_at(subtitle, Vector2(58, 139), 16, Color("b9cecb"))
	label_at("开发原型 0.5   /   本地美术占位 · 非医学教学", Vector2(56, 758), 14, Color("b9cecb"))

func label_at(text: String, pos: Vector2, font_size: int = 20, color: Color = Color("f4f0e6"), width: float = 1100) -> Label:
	var item := Label.new()
	item.text = text
	item.position = pos
	item.size.x = minf(width, 1280.0 - pos.x - 30.0)
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", color)
	item.add_theme_color_override("font_outline_color", Color(0.015, 0.04, 0.05, 0.94))
	item.add_theme_constant_override("outline_size", 4)
	page.add_child(item)
	return item

func feedback_at(text: String, pos: Vector2, font_size: int = 21, width: float = 650) -> Label:
	# Location backgrounds vary from dark interiors to bright concrete. Keep the
	# background visible, but give transient prose a stable reading surface.
	var box := Panel.new()
	box.name = "LocationFeedbackPanel"
	box.position = pos - Vector2(16, 12)
	box.size = Vector2(width + 32, 92)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_stylebox_override("panel", panel_style(Color(0.025, 0.075, 0.09, 0.82), Color(0.54, 0.66, 0.67, 0.86)))
	page.add_child(box)
	var message := label_at(text, pos, font_size, Color("fffaf0"), width)
	message.name = "LocationFeedbackText"
	return message

func button_at(text: String, pos: Vector2, dimensions: Vector2, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = dimensions
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_color_override("font_color", Color("f4f0e6"))
	button.add_theme_stylebox_override("normal", panel_style(Color("203e48")))
	button.add_theme_stylebox_override("hover", panel_style(Color("365963"), Color("d1c19e")))
	button.add_theme_stylebox_override("focus", panel_style(Color("365963"), Color("f3dbac")))
	button.pressed.connect(action)
	page.add_child(button)
	return button

func vn_dialogue_box(speaker: String, text: String, dialogue_name: String = "EventDialogue") -> void:
	var box := Panel.new()
	box.name = dialogue_name + "Box"
	box.position = Vector2(55, 540)
	box.size = Vector2(1170, 160)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_stylebox_override("panel", panel_style(Color(0.06, 0.15, 0.20, 0.96), Color("819593")))
	page.add_child(box)
	label_at(speaker, Vector2(82, 558), 22, Color("e8cfaa"), 1100)
	var dialogue: Label = label_at(text, Vector2(82, 601), 22, Color("f4f0e6"), 1100)
	dialogue.name = dialogue_name
	dialogue.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	dialogue.size = Vector2(1100, 88)
	dialogue.clip_text = true

func title_screen() -> void:
	screen = "title"
	base("", "", false, "lobby")
	label_at("春日序章", Vector2(80, 222), 68)
	label_at("星见医院的第一天", Vector2(85, 325), 27, Color("d8d8c7"))
	label_at("在病历与日常之间，认识并肩工作的人。", Vector2(85, 385), 19, Color("b9cecb"))
	button_at("开始游戏    →", Vector2(85, 480), Vector2(330, 60), request_new_game).grab_focus()
	var resume_button := button_at("继续游戏 · 读取存档", Vector2(85, 554), Vector2(330, 60), load_progress)
	resume_button.disabled = not saves.exists()
	button_at("医院导览", Vector2(85, 628), Vector2(330, 60), show_map)
	label_at("HOSPITAL VISUAL NOVEL", Vector2(805, 536), 17, Color("cbbc9c"), 380)
	label_at("01 / 入职
02 / 相识
03 / 新的日常", Vector2(805, 575), 25, Color("dae1d9"), 380)

func request_new_game() -> void:
	if not game.visits.is_empty():
		confirm_action("重新开始会清空当前未保存进度。已有存档会保留，直到你再次保存。", start_story)
	else:
		start_story()

func start_story() -> void:
	game.reset()
	reset_clinic_view()
	session.start(content.dialogue)
	show_dialogue()

func add_portrait(person: Dictionary, expression: String = "neutral", requested_outfit: String = "") -> void:
	var outfit: String = person.visuals.get("default_outfit", person.visuals.get("state", "outpatient")) if requested_outfit.is_empty() else requested_outfit
	var portraits: Dictionary = person.visuals.portraits
	var path: String = portraits.get(outfit + "/" + expression, portraits.get(outfit + "/neutral", ""))
	if not background is TextureRect:
		background.show_portrait = path.is_empty()
		background.portrait_color = Color(person.visuals.get("color", "b4c4c4"))
		background.queue_redraw()
	if path.is_empty():
		return
	var texture := load("res://" + path) as Texture2D
	if texture == null:
		if not background is TextureRect:
			background.show_portrait = true
			background.queue_redraw()
		return
	var portrait := TextureRect.new()
	portrait.name = "CharacterPortrait"
	portrait.texture = texture
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.position = Vector2(755, 165)
	portrait.size = Vector2(410, 355 if screen == "dialogue" else 420)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(portrait)

func show_dialogue() -> void:
	screen = "dialogue"
	var node: Dictionary = session.current()
	var person: Dictionary = content.find_record("staff", node.get("speaker", ""))
	if not person.is_empty():
		game.meet_staff(str(person.id))
	base("初到星见", "PROLOGUE   /   01", not person.is_empty(), node.background_id)
	if not person.is_empty():
		add_portrait(person, node.get("expression", "neutral"))
	var box := Panel.new()
	box.name = "PrologueDialogueBox"
	box.position = Vector2(55, 490)
	box.size = Vector2(1170, 240)
	box.add_theme_stylebox_override("panel", panel_style(Color(0.06, 0.15, 0.20, 0.96), Color("c6b999")))
	page.add_child(box)
	label_at(person.get("name", "旁白"), Vector2(82, 510), 22, Color("e8cfaa"))
	# Chinese prose has no spaces between words. WORD_SMART can treat a long
	# sentence as one unbreakable run, so force character-level wrapping and
	# keep a generous inset from the dialogue frame.
	var prose: Label = label_at(node.get("text", "对话节点缺失"), Vector2(82, 553), 21, Color("f4f0e6"), 1060)
	prose.name = "PrologueText"
	prose.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	prose.clip_text = true
	# Changing wrap mode also changes Label's minimum width; reapply the full
	# rectangle afterwards so the old unwrapped minimum cannot survive.
	prose.size = Vector2(1060, 110)
	if node.has("choices"):
		for i in range(node.choices.size()):
			button_at(node.choices[i].label, Vector2(75 + i * 365, 676), Vector2(345, 46), advance.bind(i))
	else:
		button_at("继续  ▷", Vector2(1040, 676), Vector2(160, 46), advance.bind(-1)).grab_focus()
	button_at("返回标题", Vector2(1070, 88), Vector2(150, 44), title_screen)

func advance(choice: int) -> void:
	var destination := session.advance(choice)
	if destination == "@map":
		show_map()
	elif destination.begins_with("@location:"):
		show_location(destination.trim_prefix("@location:"))
	else:
		show_dialogue()

func show_map() -> void:
	if game.active_surgery_in_progress():
		show_notice("手术进行中，必须完成本次手术后才能离开手术室。")
		return
	screen = "map"
	location_feedback = ""
	location_feedback_location = ""
	base("医院导览", "选择地点，了解今天的医院。  /  HOSPITAL DIRECTORY", false, "lobby")
	for i in range(content.collections.locations.size()):
		var location: Dictionary = content.collections.locations[i]
		var pos := Vector2(40 + (i % 4) * 305, 155 + (i / 4) * 130)
		var location_button := button_at("%02d   %s
		   %s" % [i + 1, location.name, location.subtitle], pos, Vector2(285, 110), show_location.bind(location.id))
		location_button.name = "Location_" + str(location.id)
	var profile_button := button_at("医生属性", Vector2(865, 88), Vector2(190, 44), show_player_profile)
	profile_button.name = "PlayerProfileButton"
	button_at("返回标题", Vector2(1070, 88), Vector2(150, 44), title_screen)
	button_at("保存进度", Vector2(58, 700), Vector2(170, 43), save_progress)
	button_at("读取存档", Vector2(242, 700), Vector2(170, 43), request_load)
	button_at("时间记录", Vector2(426, 700), Vector2(170, 43), show_time_log)
	button_at("事件鉴赏", Vector2(610, 700), Vector2(170, 43), show_event_gallery)
	if not game.active_id.is_empty():
		button_at("继续当前病例  →", Vector2(827, 700), Vector2(389, 43), resume_progress)

func show_player_profile() -> void:
	screen = "player_profile"
	base("医生属性", "%s的选择正在塑造医院中的身份。" % protagonist_name(), false, "lobby")
	var values: Dictionary = game.player_attributes()
	var labels := {"skill": "手术技术", "ethics": "伦理", "charisma": "魅力", "intimidation": "威压", "reputation": "声望"}
	var colors := {"skill": Color("79a9c9"), "ethics": Color("7eb696"), "charisma": Color("d6a06c"), "intimidation": Color("d47f79"), "reputation": Color("b79ac8")}
	var order := ["skill", "ethics", "charisma", "intimidation", "reputation"]
	for i in range(order.size()):
		var metric_id: String = order[i]
		var y := 205 + i * 67
		label_at("%s　%3d" % [labels[metric_id], values[metric_id]], Vector2(75, y), 22, Color("f4f0e6"), 180)
		var bar := ProgressBar.new()
		bar.position = Vector2(250, y + 3)
		bar.size = Vector2(400, 24)
		bar.min_value = -100 if metric_id in ["ethics", "reputation"] else 0
		bar.max_value = 100
		bar.value = values[metric_id]
		bar.name = "PlayerMetric_" + metric_id
		bar.show_percentage = false
		bar.add_theme_stylebox_override("fill", panel_style(colors[metric_id]))
		page.add_child(bar)
	ClinicView.panel(self, Vector2(705, 190), Vector2(510, 390))
	label_at("重要选择记录", Vector2(740, 220), 23, Color("e8cfaa"), 430)
	var history: Array[Dictionary] = game.player_attribute_history()
	if history.is_empty():
		label_at("尚未发生会改变医生道路的关键选择。", Vector2(740, 275), 19, Color("d7dfdf"), 420)
	else:
		var first := maxi(0, history.size() - 5)
		for i in range(first, history.size()):
			var record: Dictionary = history[i]
			var changes: Array[String] = []
			for metric_id in order:
				var amount := int(record.effects.get(metric_id, 0))
				if amount != 0:
					changes.append("%s %s%d" % [labels[metric_id], "+" if amount > 0 else "", amount])
			label_at("%s\n%s" % [record.label, "　".join(changes)], Vector2(740, 270 + (i - first) * 58), 17, Color("f4f0e6"), 430)
	button_at("← 医院导览", Vector2(1030, 88), Vector2(185, 44), show_map)

func show_time_log() -> void:
	screen = "time_log"
	base("时间记录", "自由行动 / 工作日时间线", false, "lobby")
	label_at("门诊与手术耗时由各自病例记录；这里列出地点交谈、休息和关系事件。", Vector2(60, 190), 20, Color("e0d9c4"), 1100)
	var history: Array = game.time_history()
	if history.is_empty():
		label_at("还没有自由行动记录。", Vector2(65, 275), 23, Color("f4f0e6"), 900)
	else:
		var first := maxi(0, history.size() - 7)
		for i in range(first, history.size()):
			var event: Dictionary = history[i]
			var entry := label_at("DAY %02d　%s　%s　·　%s 分钟" % [event.day, event.clock, event.label, event.minutes], Vector2(70, 255 + (i - first) * 56), 21, Color("f4f0e6"), 1080)
			entry.name = "TimeLogEntry_" + str(i)
	label_at("当前：%s · %s　今日剩余 %s 分钟" % [game.day_text(), game.clock_text(), game.shift_remaining()], Vector2(65, 665), 20, Color("e8cfaa"), 700)
	button_at("← 医院导览", Vector2(1030, 88), Vector2(185, 44), show_map)

func show_micro_event() -> void:
	var event = game.micro_events.get(game.active_micro_event_id)
	if event == null:
		show_map()
		return
	screen = "micro_event"
	var definition: Dictionary = event.definition
	var actor: Dictionary = content.find_record("staff", definition.actor_id)
	var location: Dictionary = content.find_record("locations", definition.location_id)
	base(definition.title, "%s / %s · 日常片段" % [actor.name, location.name], true, location.background_id)
	var line: Dictionary
	if event.completed:
		var response_lines: Array = event.response_lines()
		line = response_lines[event.response_index]
	else:
		var opening_lines: Array = event.opening_lines()
		line = opening_lines[event.opening_index]
	var expression: String = str(line.get("expression", event.last_choice.get("expression", definition.expression) if event.completed else definition.expression))
	add_portrait(actor, expression, definition.outfit)
	var portrait = page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(770, 170)
		portrait.size = Vector2(430, 480)
	var speaker_name: String = str({"actor": actor.name, "player": protagonist_name(), "narrator": "旁白"}.get(line.get("speaker", "actor"), actor.name))
	vn_dialogue_box(speaker_name, str(line.get("text", "")), "MicroEventDialogue")
	if event.completed:
		if event.response_finished():
			var relation: Dictionary = game.relation_for(actor.id)
			label_at("信任 %s　好感 %s　尊重 %s　熟悉 %s" % [relation.trust, relation.affection, relation.respect, relation.familiarity], Vector2(65, 420), 18, Color("cbbc9c"), 650)
		var continue_button := button_at("结束片段  →" if event.response_finished() else "继续  →", Vector2(60, 480), Vector2(655, 56), continue_micro_event)
		continue_button.name = "MicroEventContinue"
	else:
		if event.at_choice():
			for i in range(definition.choices.size()):
				var choice: Dictionary = definition.choices[i]
				var choice_button := button_at(choice.label, Vector2(60, 350 + i * 66), Vector2(655, 54), choose_micro_event.bind(choice.id))
				choice_button.name = "MicroEventChoice_" + str(choice.id)
		else:
			var continue_button := button_at("继续  →", Vector2(60, 480), Vector2(655, 56), advance_micro_event_opening)
			continue_button.name = "MicroEventContinue"
	button_at("保存", Vector2(60, 713), Vector2(120, 40), save_progress)
	button_at("读档", Vector2(194, 713), Vector2(120, 40), request_load)

func choose_micro_event(choice_id: String) -> void:
	var event = game.micro_events.get(game.active_micro_event_id)
	if event == null:
		return
	if not game.choose_micro_event(choice_id):
		show_notice(event.last_error)
		return
	show_micro_event()

func advance_micro_event_opening() -> void:
	var event = game.micro_events.get(game.active_micro_event_id)
	if event == null or not event.advance_opening():
		return
	show_micro_event()

func continue_micro_event() -> void:
	var event = game.micro_events.get(game.active_micro_event_id)
	if event == null:
		show_map()
		return
	if event.completed and not event.response_finished():
		event.advance_response()
		show_micro_event()
		return
	var context: String = event.definition.context
	var location_id: String = event.definition.location_id
	game.finish_micro_event()
	if context == "after_encounter" and not game.active_id.is_empty():
		show_encounter(game.active_id)
	elif context == "after_surgery":
		settle_surgery_return()
	else:
		show_location(location_id, true, false)

func show_location(id: String, preserve_random: bool = false, allow_micro_event: bool = true) -> void:
	var natural_event: Dictionary = game.next_character_event_at(id)
	if not natural_event.is_empty() and bool(natural_event.get("auto_start", false)):
		start_character_event_from_location(str(natural_event.id), id)
		return
	screen = "location"
	var location: Dictionary = content.find_record("locations", id)
	base(location.name, location.subtitle, false, location.background_id)
	var location_description := str(location.description)
	if id == "emiko_office" and not game.staff_is_met("doc_emiko") and game.character_event_done("emiko_office_denied"):
		location_description = [
			"护士说御堂医长正在手术，今天不会回办公室。",
			"护士说御堂医长正在查房，没有留下回来的时间。",
			"护士说御堂医长去讲课了，让本多改天再来。",
			"护士说御堂医长正在开会，无法接待没有预约的来访。",
			"办公室门锁着。护士只说御堂医长今天不在。",
		][randi() % 5]
	label_at(location_description, Vector2(60, 196), 22, Color("e0d9c4"))
	if allow_micro_event and game.has_micro_event("location_visit", id):
		var micro_button := button_at("日常片段", Vector2(875, 196), Vector2(150, 44), start_location_micro_event.bind(id))
		micro_button.name = "LocationMicroEvent"
	var present_staff: Array[String] = game.staff_present_at(id)
	if id == "rooftop":
		rooftop_actor_id = "" if present_staff.is_empty() else present_staff[0]
	if id == "rooftop":
		if rooftop_actor_id.is_empty():
			label_at("今天天台上没有其他人。", Vector2(65, 258), 20, Color("c2d2cc"), 650)
		else:
			var rooftop_actor: Dictionary = content.find_record("staff", rooftop_actor_id)
			label_at("今天在天台遇到了%s。" % rooftop_actor.name, Vector2(65, 258), 20, Color("e8cfaa"), 650)
			add_portrait(rooftop_actor)
			var rooftop_portrait = page.get_node_or_null("CharacterPortrait")
			if rooftop_portrait != null:
					rooftop_portrait.position = Vector2(805, 210)
					rooftop_portrait.size = Vector2(390, 430)
	if not natural_event.is_empty():
		var event_pos := Vector2(810, 196) if id == "lounge" else Vector2(60, 520) if id == "station" else Vector2(60, 449) if id == "rooftop" else Vector2(60, 305)
		var event_size := Vector2(405, 55) if id == "lounge" else Vector2(700, 55) if id == "rooftop" else Vector2(655, 55)
		var event_button := button_at("◆ " + str(natural_event.teaser), event_pos, event_size, start_character_event_from_location.bind(natural_event.id, id))
		event_button.name = "NaturalEvent_" + str(natural_event.id)
	var row := 0
	for staff_id in present_staff:
		var person: Dictionary = content.find_record("staff", staff_id)
		var met: bool = game.staff_is_met(staff_id)
		var caption: String = "%s   /   %s  ·  %s岁     %s" % [person.name, person.specialty, person.age, person.personality] if met else "？？？   /   尚未认识"
		var profile_action: Callable = show_staff.bind(staff_id, id) if met else introduce_staff_at_location.bind(staff_id, id)
		var profile_pos := Vector2(60, 315 + row * 137) if id == "rooftop" else Vector2(60, 269 + row * 77)
		var profile_size := Vector2(700, 55) if id == "rooftop" else Vector2(730, 63)
		button_at(caption, profile_pos, profile_size, profile_action)
		if met:
			for chat in game.time_events_at(id):
				if chat.actor_id == staff_id:
					var chat_pos := Vector2(60, 382 + row * 137) if id == "rooftop" else Vector2(810, 269 + row * 77)
					var chat_size := Vector2(340, 54) if id == "rooftop" else Vector2(405, 63)
					var chat_button: Button = button_at("闲谈 · %s 分钟" % chat.minutes, chat_pos, chat_size, perform_time_event.bind(chat.id, id))
					chat_button.name = "TimeEvent_" + chat.id
		row += 1
	if id == "clinic":
		var current_patient_id := game.current_patient_id()
		var patient_row := 0
		for patient in content.collections.patients:
			if patient.id != current_patient_id:
				continue
			var case_data: Dictionary = game.patient_case(patient.id)
			if case_data.is_empty():
				case_data = content.find_record("cases", patient.case_id)
			var encounter_id := encounter_for_patient(patient.id)
			var caption := "当前候诊  /  %s · %s岁   /   %s" % [patient.name, patient.age, case_data.title]
			if not encounter_id.is_empty():
				caption += "   /   " + ("查看住院交接" if game.admitted_patient(patient.id) else "接诊 / 继续")
				button_at(caption, Vector2(60, 455 + patient_row * 72), Vector2(730, 60), show_encounter.bind(encounter_id))
			else:
				label_at(caption + "（后续开放）", Vector2(65, 470 + patient_row * 72), 21)
			var portrait_button := button_at("人物立绘", Vector2(805, 455 + patient_row * 72), Vector2(190, 60), show_patient.bind(patient.id))
			portrait_button.name = "PatientPortrait"
			if not game.admitted_patient(patient.id):
				var referral_button := button_at("转诊…", Vector2(1010, 455 + patient_row * 72), Vector2(205, 60), show_referral.bind(patient.id))
				referral_button.name = "ReferPatient"
			patient_row += 1
		if current_patient_id.is_empty():
			label_at("当前没有可安排的候诊患者。", Vector2(65, 470), 21)
	if id == "ward":
		var row_index := 0
		for patient in content.collections.patients:
			if game.admitted_patient(patient.id):
				button_at(patient.name + "  /  病历", Vector2(60, 390 + row_index * 72), Vector2(360, 60), show_encounter.bind(encounter_for_patient(patient.id)))
				var preparation_id := preop_for_patient(patient.id)
				if not preparation_id.is_empty():
					button_at("探视 / 继续术前安排 →", Vector2(445, 390 + row_index * 72), Vector2(770, 60), show_preop.bind(preparation_id))
				row_index += 1
		if row_index == 0:
			label_at("当前没有已收住院的患者。", Vector2(65, 405), 22)
	if id == "or":
		if not game.active_preop_id.is_empty():
			button_at("继续术前准备 →", Vector2(60, 465), Vector2(1155, 60), show_preop.bind(game.active_preop_id))
		else:
			label_at("请先到病房探视患者并安排团队。", Vector2(65, 465), 22)
	var time_events: Array = game.time_events_at(id)
	var visible_events: Array = []
	for event in time_events:
		if event.actor_id != null:
			continue
		visible_events.append(event)
	for i in range(visible_events.size()):
		var event: Dictionary = visible_events[i]
		var event_pos := Vector2(60, 516 + i * 66) if id == "rooftop" else Vector2(60, 300 + i * 66)
		var event_size := Vector2(700, 54) if id == "rooftop" else Vector2(655, 54)
		var button: Button = button_at("%s　·　%s 分钟" % [event.label, event.minutes], event_pos, event_size, perform_time_event.bind(event.id, id))
		button.name = "TimeEvent_" + event.id
	if location_feedback_location == id and not location_feedback.is_empty():
		feedback_at(location_feedback, Vector2(65, 650 if id == "lounge" else 450), 19 if id == "lounge" else 21, 650)
	button_at("← 医院导览", Vector2(1030, 88), Vector2(185, 44), show_map)

func introduce_staff_at_location(staff_id: String, location_id: String) -> void:
	for definition in game.character_events_at(location_id):
		if definition.actor_id == staff_id and definition.category == "introduction":
			character_event_from_test = false
			character_event_return_location = location_id
			if game.start_character_event(str(definition.id)) != null:
				show_character_event()
				return
	show_notice("现在还没有合适的机会上前认识。")

func start_location_micro_event(location_id: String) -> void:
	if game.select_micro_event("location_visit", location_id) == null:
		show_notice("这里现在没有可触发的日常片段。")
		return
	show_micro_event()

func perform_time_event(event_id: String, location_id: String) -> void:
	var before_elapsed := game.elapsed()
	var before_day := game.day_number()
	var definition: Dictionary = content.find_record("time_events", event_id)
	if game.spend_time(event_id):
		game.settle_overtime(before_elapsed, int(definition.minutes))
		var crossed_day := game.day_number() > before_day
		if definition.actor_id != null:
			location_feedback = ""
			location_feedback_location = ""
			show_time_event_result(event_id, location_id, crossed_day)
			return
		location_feedback = "%s\n现在是 %s · 今日还剩 %s 分钟。" % [game.last_time_event_response, game.clock_text(), game.shift_remaining()]
	else:
		location_feedback = game.last_error
	location_feedback_location = location_id
	var next_view := show_location.bind(location_id, true)
	if game.day_number() > before_day:
		show_day_transition(next_view)
	else:
		next_view.call()

func chat_outfit_for_location(actor: Dictionary, location_id: String) -> String:
	var default_outfit := str(actor.visuals.get("default_outfit", "uniform"))
	var requested := "scrubs" if location_id == "or" else default_outfit
	if actor.visuals.portraits.has(requested + "/neutral"):
		return requested
	if location_id == "or" and actor.visuals.portraits.has("sterile/neutral"):
		return "sterile"
	return default_outfit

func chat_expression_for_outfit(actor: Dictionary, outfit: String) -> String:
	for expression in (["warm", "smile", "neutral"] if outfit == "scrubs" else ["smile", "neutral"]):
		if actor.visuals.portraits.has(outfit + "/" + expression):
			return expression
	return "neutral"

func show_time_event_result(event_id: String, location_id: String, crossed_day: bool = false) -> void:
	var definition: Dictionary = content.find_record("time_events", event_id)
	var actor: Dictionary = content.find_record("staff", str(definition.get("actor_id", "")))
	if definition.is_empty() or actor.is_empty():
		show_location(location_id, true)
		return
	screen = "time_event_result"
	var location: Dictionary = content.find_record("locations", location_id)
	base("片刻闲谈", "%s / %s" % [actor.name, location.name], true, location.background_id)
	var outfit := chat_outfit_for_location(actor, location_id)
	var expression := chat_expression_for_outfit(actor, outfit)
	add_portrait(actor, expression, outfit)
	var portrait = page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(760, 150)
		portrait.size = Vector2(450, 380)
	vn_dialogue_box(actor.name, game.last_time_event_response, "TimeEventDialogue")
	label_at("耗时 %s 分钟　/　现在是 %s" % [definition.minutes, game.clock_text()], Vector2(65, 205), 19, Color("c2d2cc"), 620)
	button_at("结束闲谈  →", Vector2(1015, 713), Vector2(210, 40), finish_time_event_result.bind(location_id, crossed_day))

func finish_time_event_result(location_id: String, crossed_day: bool) -> void:
	var next_view := show_location.bind(location_id, true)
	if crossed_day:
		show_day_transition(next_view)
	else:
		next_view.call()

func show_staff(id: String, from_location: String, expression: String = "neutral", outfit: String = "") -> void:
	screen = "staff"
	StaffView.render(self, id, from_location, expression, outfit)

func show_character_events(actor_id: String, from_location: String = "") -> void:
	screen = "character_events"
	if not from_location.is_empty():
		character_event_return_location = from_location
	var actor: Dictionary = content.find_record("staff", actor_id)
	base(actor.name + " · 事件测试", "开发入口 / 条件、分支与差分测试", true, background_for_location(character_event_return_location))
	add_portrait(actor, "neutral")
	var portrait = page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(805, 190)
		portrait.size = Vector2(380, 470)
	var definitions: Array = []
	for definition in game.character_event_definitions.values():
		if definition.actor_id == actor_id:
			definitions.append(definition)
	definitions.sort_custom(func(a: Dictionary, b: Dictionary): return int(a.chapter) < int(b.chapter))
	for i in range(definitions.size()):
		var definition: Dictionary = definitions[i]
		var available := game.character_event_available(definition)
		var completed := game.character_event_done(definition.id)
		var caption := "第%s章　%s　·　%s分钟　%s–%s" % [definition.chapter, definition.title, definition.minutes, clock_from_minutes(definition.time_start), clock_from_minutes(definition.time_end)]
		if completed:
			caption = "✓ 已完成　" + caption
		elif not available:
			caption = "条件未满足　" + caption
		else:
			caption = "当前可触发　" + caption
		var event_button := button_at(caption, Vector2(60, 215 + i * 88), Vector2(685, 66), start_test_character_event.bind(definition.id))
		event_button.name = "CharacterEvent_" + definition.id
	var relation: Dictionary = game.relation_for(actor_id)
	label_at("信任 %s　好感 %s　尊重 %s　熟悉 %s" % [relation.trust, relation.affection, relation.respect, relation.familiarity], Vector2(65, 600), 20, Color("e8cfaa"), 680)
	button_at("← 返回人物档案", Vector2(1000, 88), Vector2(215, 44), show_staff.bind(actor_id, character_event_return_location))

func start_test_character_event(event_id: String) -> void:
	if not game.character_event_definitions.has(event_id):
		return
	gallery_replay_event = CharacterEvent.new(game.character_event_definitions[event_id])
	gallery_replay_is_test = true
	gallery_replay_return_actor = gallery_replay_event.definition.actor_id
	show_gallery_replay()

func start_character_event(event_id: String) -> void:
	character_event_from_test = true
	character_event_return_preop_id = ""
	if game.start_character_event(event_id) == null:
		show_notice("这个事件尚未解锁。")
		return
	show_character_event()

func start_character_event_from_location(event_id: String, location_id: String) -> void:
	var definition: Dictionary = game.character_event_definitions.get(event_id, {})
	if definition.is_empty() or game.next_character_event_at(location_id).get("id", "") != event_id:
		show_notice("这个事件当前没有发生。")
		return
	character_event_from_test = false
	character_event_return_location = location_id
	character_event_return_preop_id = ""
	if game.start_character_event(event_id) == null:
		show_notice("这个事件当前无法开始。")
		return
	show_character_event()

func start_character_event_from_preop_stage(stage_id: String) -> bool:
	var definition: Dictionary = game.next_character_event_for_preop_stage(stage_id)
	if definition.is_empty():
		return false
	character_event_from_test = false
	character_event_return_location = str(definition.location_id)
	character_event_return_preop_id = game.active_preop_id
	if game.start_character_event(str(definition.id)) == null:
		character_event_return_preop_id = ""
		return false
	show_character_event()
	return true

func show_character_event() -> void:
	var event = game.character_events.get(game.active_character_event_id)
	if event == null:
		show_map()
		return
	if event.completed:
		show_character_event_complete()
		return
	screen = "character_event"
	var definition: Dictionary = event.definition
	var node: Dictionary = event.current()
	var actor: Dictionary = content.find_record("staff", definition.actor_id)
	var actor_name := str(definition.get("actor_alias", actor.name))
	var location: Dictionary = content.find_record("locations", definition.location_id)
	var event_label := "第%s章" % definition.chapter
	if definition.category == "introduction":
		event_label = "认识事件"
	elif definition.category == "contextual":
		event_label = "遭遇事件"
	elif definition.category == "bond":
		event_label = "建立羁绊 Lv.1"
	elif definition.category == "rank_up":
		event_label = "关系升级 Lv.%s" % definition.target_level
	base(definition.title, "%s / %s / %s" % [actor_name, event_label, location.name], true, definition.background_id)
	add_character_event_visual(actor, node, definition.outfit)
	var speaker: String = str({"actor": actor_name, "player": protagonist_name(), "narrator": "旁白"}.get(node.speaker, actor_name))
	vn_dialogue_box(speaker, node.text, "CharacterEventDialogue")
	for i in range(node.choices.size()):
		var choice: Dictionary = node.choices[i]
		var choice_button := button_at(choice.label, Vector2(60, 350 + i * 66), Vector2(655, 54), choose_character_event.bind(choice.id))
		choice_button.name = "EventChoice_" + choice.id
	button_at("保存", Vector2(60, 713), Vector2(120, 40), save_progress)
	button_at("读档", Vector2(194, 713), Vector2(120, 40), request_load)

func add_character_event_visual(actor: Dictionary, node: Dictionary, outfit: String) -> void:
	if bool(node.get("hide_portrait", false)):
		return
	var cg_path := str(node.get("cg_path", ""))
	if not cg_path.is_empty() and FileAccess.file_exists("res://" + cg_path):
		var cg := TextureRect.new()
		cg.name = "CharacterEventCG"
		cg.texture = load("res://" + cg_path)
		cg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if str(node.get("cg_fit", "cover")) == "cover" else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		page.add_child(cg)
		return
	var portrait_path := str(node.get("portrait_path", ""))
	if not portrait_path.is_empty() and FileAccess.file_exists("res://" + portrait_path):
		var event_texture := load("res://" + portrait_path) as Texture2D
		if event_texture == null:
			return
		var source_size := Vector2(event_texture.get_width(), event_texture.get_height())
		var portrait_scale := minf(320.0 / source_size.x, 460.0 / source_size.y) * float(node.get("portrait_scale", 1.0))
		var display_size := source_size * portrait_scale
		var portrait_right := float(node.get("portrait_right", 1230.0))
		var portrait_y := float(node.get("portrait_y", 170.0))
		var event_portrait := TextureRect.new()
		event_portrait.name = "CharacterEventPortrait"
		event_portrait.texture = event_texture
		# TextureRect defaults to keeping the source texture as its minimum size.
		# Set IGNORE_SIZE before assigning the display rectangle; otherwise a
		# 1024×1536 event portrait silently clamps back to its native dimensions.
		event_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		event_portrait.stretch_mode = TextureRect.STRETCH_SCALE
		event_portrait.position = Vector2(portrait_right - display_size.x, portrait_y)
		event_portrait.size = display_size
		event_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		page.add_child(event_portrait)
		return
	add_portrait(actor, node.expression, outfit)
	var portrait = page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(760, 165)
		portrait.size = Vector2(450, 500)

func choose_character_event(choice_id: String) -> void:
	var event = game.character_events.get(game.active_character_event_id)
	if event == null:
		return
	var before_elapsed := game.elapsed()
	var before_day := game.day_number()
	if not game.choose_character_event(choice_id):
		show_notice(event.last_error)
		return
	if event.completed:
		game.settle_overtime(before_elapsed, int(event.definition.minutes))
		var follow_up: Dictionary = event.definition.get("auto_follow_up", {})
		if not follow_up.is_empty():
			game.advance_story_to_day(int(event.completed_day) + int(follow_up.day_offset), int(follow_up.absolute_clock))
			var follow_up_id := str(follow_up.event_id)
			var follow_definition: Dictionary = game.character_event_definitions.get(follow_up_id, {})
			if not follow_definition.is_empty() and game.start_character_event(follow_up_id) != null:
				character_event_return_location = str(follow_definition.location_id)
				show_day_transition(show_character_event)
				return
		var next_view := show_character_event_reward if character_event_reward_available(event.definition) else show_character_event_complete
		if game.day_number() > before_day:
			show_day_transition(next_view)
		else:
			next_view.call()
	else:
		show_character_event()

func character_event_reward_available(definition: Dictionary) -> bool:
	var gallery: Dictionary = definition.get("gallery", {})
	var path := str(gallery.get("path", ""))
	return bool(gallery.get("show_on_complete", true)) and not path.is_empty() and FileAccess.file_exists("res://" + path)

func show_character_event_reward() -> void:
	var event = game.character_events.get(game.active_character_event_id)
	if event == null or not character_event_reward_available(event.definition):
		show_character_event_complete()
		return
	screen = "character_event_reward"
	base("", "", false, event.definition.background_id)
	var gallery: Dictionary = event.definition.gallery
	var cg := TextureRect.new()
	cg.name = "EventRewardCG"
	cg.texture = load("res://" + str(gallery.path))
	cg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(cg)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.025, 0.04, 0.48)
	shade.position = Vector2(0, 650)
	shade.size = Vector2(1280, 150)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(shade)
	label_at(str(gallery.caption), Vector2(55, 680), 24, Color("f4f0e6"), 900)
	var continue_button := button_at("继续  →", Vector2(1030, 690), Vector2(190, 52), show_character_event_complete)
	continue_button.name = "EventRewardContinue"
	get_tree().create_timer(3.5).timeout.connect(func():
		if screen == "character_event_reward":
			show_character_event_complete())

func show_character_event_complete() -> void:
	var event = game.character_events.get(game.active_character_event_id)
	if event == null:
		show_map()
		return
	screen = "character_event_complete"
	var actor: Dictionary = content.find_record("staff", event.definition.actor_id)
	var actor_name := str(event.definition.get("actor_alias", actor.name))
	var relation: Dictionary = game.relation_for(actor.id)
	base("事件结束", "%s / %s" % [actor_name, event.definition.title], true, event.definition.background_id)
	if game.staff_is_met(str(actor.id)) and not bool(event.definition.get("hide_completion_portrait", false)):
		add_portrait(actor, "smile", event.definition.outfit)
	label_at("与%s有关的这段插曲已经结束。" % actor_name, Vector2(65, 235), 27, Color("f4f0e6"), 650)
	var level := int(relation.get("level", 0))
	var relation_note := "尚未正式认识"
	if bool(relation.get("met", false)):
		relation_note = "已经认识 · 普通同事 · 尚未建立羁绊" if level == 0 else "已经认识 · 关系 Lv.%s" % level
	if event.definition.category == "bond":
		relation_note = "已经建立羁绊 · 关系 Lv.1"
	elif event.definition.category == "rank_up":
		relation_note = "关系提升至 Lv.%s" % relation.get("level", 1)
	label_at(relation_note, Vector2(65, 325), 22, Color("e8cfaa"), 650)
	label_at("耗时 %s 分钟　/　现在是 %s" % [event.definition.minutes, game.clock_text()], Vector2(65, 385), 19, Color("c2d2cc"), 650)
	var return_preop_id := character_event_return_preop_id
	if return_preop_id.is_empty() and not str(event.definition.get("preop_stage_id", "")).is_empty():
		return_preop_id = game.active_preop_id
	if character_event_from_test:
		button_at("返回事件测试  →", Vector2(60, 475), Vector2(320, 54), show_character_events.bind(actor.id, character_event_return_location))
	elif not return_preop_id.is_empty():
		button_at("继续术前流程  →", Vector2(60, 475), Vector2(320, 54), return_to_preop_after_character_event.bind(return_preop_id))
	else:
		button_at("返回%s  →" % content.find_record("locations", character_event_return_location).name, Vector2(60, 475), Vector2(320, 54), show_location.bind(character_event_return_location))
	button_at("返回医院导览", Vector2(400, 475), Vector2(315, 54), show_map)

func return_to_preop_after_character_event(preop_id: String) -> void:
	character_event_return_preop_id = ""
	show_preop(preop_id)

func clock_from_minutes(minutes: int) -> String:
	return "%02d:%02d" % [minutes / 60, minutes % 60]

func show_event_gallery() -> void:
	screen = "event_gallery"
	gallery_replay_event = null
	gallery_replay_is_test = false
	base("事件鉴赏", "完成过的人物事件会收录于此 / EVENT MEMORIES", false, "staff_lounge")
	var definitions: Array = game.character_event_definitions.values()
	definitions.sort_custom(func(a: Dictionary, b: Dictionary):
		if a.actor_id != b.actor_id:
			return a.actor_id < b.actor_id
		return int(a.chapter) < int(b.chapter))
	var gallery_scroll := ScrollContainer.new()
	gallery_scroll.name = "EventGalleryScroll"
	gallery_scroll.position = Vector2(45, 190)
	gallery_scroll.size = Vector2(1190, 450)
	gallery_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	gallery_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	page.add_child(gallery_scroll)
	var gallery_content := Control.new()
	gallery_content.name = "EventGalleryContent"
	var row_count := ceili(float(definitions.size()) / 2.0)
	gallery_content.custom_minimum_size = Vector2(1170, max(450, row_count * 105 + 15))
	gallery_scroll.add_child(gallery_content)
	for i in range(definitions.size()):
		var definition: Dictionary = definitions[i]
		var unlocked := game.character_event_done(definition.id)
		var actor: Dictionary = content.find_record("staff", definition.actor_id)
		var caption := "%s　%s" % [actor.name, definition.title] if unlocked else "？？？　未解锁"
		var column := i % 2
		var row := i / 2
		var entry := button_at(caption, Vector2.ZERO, Vector2(555, 78), show_gallery_entry.bind(definition.id))
		page.remove_child(entry)
		gallery_content.add_child(entry)
		entry.position = Vector2(15 + column * 595, 15 + row * 105)
		entry.name = "GalleryEvent_" + definition.id
		entry.disabled = not unlocked
	label_at("专属CG将在对应事件完成后解锁；尚未配置图片的条目先显示立绘差分构图。", Vector2(65, 650), 18, Color("d8d8c7"), 920)
	button_at("← 医院导览", Vector2(1030, 88), Vector2(185, 44), show_map)

func show_gallery_entry(event_id: String) -> void:
	if not game.character_event_done(event_id):
		show_notice("这个事件尚未解锁。")
		return
	screen = "gallery_entry"
	var definition: Dictionary = game.character_event_definitions[event_id]
	var actor: Dictionary = content.find_record("staff", definition.actor_id)
	var gallery: Dictionary = definition.gallery
	base(definition.title, "%s / EVENT MEMORY" % actor.name, true, definition.background_id)
	if not str(gallery.path).is_empty() and FileAccess.file_exists("res://" + str(gallery.path)):
		var cg := TextureRect.new()
		cg.name = "GalleryCG"
		cg.texture = load("res://" + str(gallery.path))
		cg.position = Vector2(625, 175)
		cg.size = Vector2(570, 455)
		cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		page.add_child(cg)
	else:
		var opening: Dictionary = definition.nodes[0]
		add_portrait(actor, opening.expression, definition.outfit)
		var portrait = page.get_node_or_null("CharacterPortrait")
		if portrait != null:
			portrait.position = Vector2(720, 175)
			portrait.size = Vector2(475, 470)
		label_at("CG SLOT / " + str(gallery.cg_id), Vector2(65, 235), 18, Color("cbbc9c"), 570)
		label_at("专属CG素材待制作", Vector2(65, 275), 30, Color("f4f0e6"), 570)
	var gallery_caption := label_at(gallery.caption, Vector2(65, 365), 23, Color("e8cfaa"), 500)
	gallery_caption.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	gallery_caption.size = Vector2(500, 58)
	var gallery_note := label_at("回想模式不会消耗时间，也不会再次改变关系数值。", Vector2(65, 430), 18, Color("d8d8c7"), 500)
	gallery_note.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	gallery_note.size = Vector2(500, 52)
	button_at("回想事件  →", Vector2(60, 520), Vector2(270, 55), replay_gallery_entry.bind(event_id))
	button_at("← 返回鉴赏", Vector2(350, 520), Vector2(240, 55), show_event_gallery)

func replay_gallery_entry(event_id: String) -> void:
	if not game.character_event_done(event_id):
		return
	gallery_replay_event = CharacterEvent.new(game.character_event_definitions[event_id])
	gallery_replay_is_test = false
	show_gallery_replay()

func show_gallery_replay() -> void:
	if gallery_replay_event == null:
		show_event_gallery()
		return
	if gallery_replay_event.completed:
		if gallery_replay_is_test:
			show_character_events(gallery_replay_return_actor, character_event_return_location)
		else:
			show_gallery_entry(gallery_replay_event.definition.id)
		return
	screen = "gallery_replay"
	var definition: Dictionary = gallery_replay_event.definition
	var node: Dictionary = gallery_replay_event.current()
	var actor: Dictionary = content.find_record("staff", definition.actor_id)
	var actor_name := str(definition.get("actor_alias", actor.name))
	base(("测试 · " if gallery_replay_is_test else "回想 · ") + str(definition.title), "%s / 不影响当前进度" % actor_name, true, definition.background_id)
	add_character_event_visual(actor, node, definition.outfit)
	var speaker: String = str({"actor": actor_name, "player": protagonist_name(), "narrator": "旁白"}.get(node.speaker, actor_name))
	label_at(speaker, Vector2(65, 205), 22, Color("e8cfaa"), 640)
	label_at(node.text, Vector2(65, 253), 24, Color("f4f0e6"), 640)
	for i in range(node.choices.size()):
		var choice: Dictionary = node.choices[i]
		var choice_button := button_at(choice.label, Vector2(60, 445 + i * 66), Vector2(655, 54), choose_gallery_replay.bind(choice.id))
		choice_button.name = "ReplayChoice_" + choice.id
	var exit_action: Callable = show_character_events.bind(gallery_replay_return_actor, character_event_return_location) if gallery_replay_is_test else show_gallery_entry.bind(definition.id)
	button_at("退出测试" if gallery_replay_is_test else "退出回想", Vector2(60, 713), Vector2(180, 40), exit_action)

func choose_gallery_replay(choice_id: String) -> void:
	if gallery_replay_event == null or not gallery_replay_event.apply(choice_id):
		return
	show_gallery_replay()

func background_for_location(id: String) -> String:
	return content.find_record("locations", id).get("background_id", "")

func background_path(id: String) -> String:
	return content.find_record("backgrounds", id).get("path", "")

func show_patient(id: String, outfit: String = "outpatient", expression: String = "neutral") -> void:
	screen = "patient"
	var patient: Dictionary = content.find_record("patients", id)
	var case_data: Dictionary = game.patient_case(id)
	if case_data.is_empty():
		case_data = content.find_record("cases", patient.case_id)
	var outfit_name: String = {"outpatient": "门诊着装", "ward": "病房着装", "operating_table": "手术台"}.get(outfit, outfit)
	base(patient.name, "%s岁 / %s" % [patient.age, outfit_name], true, "clinic")
	add_portrait(patient, expression, outfit)
	var portrait = page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(740, 165)
		portrait.size = Vector2(470, 500)
	label_at(case_data.title, Vector2(65, 240), 28, Color("f4f0e6"), 640)
	var expression_names := {"neutral": "平静", "smile": "微笑", "brave": "强装镇定", "worried": "担忧", "afraid": "害怕", "crying": "哭泣", "awake": "清醒", "tense": "紧张", "anesthetized": "麻醉后"}
	label_at(outfit_name + " · " + expression_names.get(expression, expression), Vector2(65, 325), 22, Color("cbbc9c"), 640)
	button_at("门诊着装", Vector2(65, 400), Vector2(190, 44), show_patient.bind(id, "outpatient"))
	if patient.visuals.portraits.has("ward/neutral"):
		button_at("病房着装", Vector2(275, 400), Vector2(190, 44), show_patient.bind(id, "ward"))
	if patient.visuals.portraits.has("operating_table/awake"):
		button_at("手术台", Vector2(485, 400), Vector2(190, 44), show_patient.bind(id, "operating_table", "awake"))
	var expressions: Array[String] = []
	for key in patient.visuals.portraits:
		if key.get_slice("/", 0) == outfit:
			expressions.append(key.get_slice("/", 1))
	for i in range(expressions.size()):
		var value := expressions[i]
		var button := button_at(expression_names.get(value, value), Vector2(65 + (i % 3) * 205, 465 + (i / 3) * 50), Vector2(190, 40), show_patient.bind(id, outfit, value))
		button.name = "PatientExpression_" + value
		button.disabled = value == expression
	button_at("← 返回门诊", Vector2(1020, 88), Vector2(195, 44), show_location.bind("clinic"))

func encounter_for_patient(patient_id: String) -> String:
	for definition in content.collections.encounters:
		if definition.patient_id == patient_id:
			return definition.id
	return ""

func examination_visual_for_choice(visit: RefCounted, choice_id: String) -> String:
	var stage: Dictionary = visit.current()
	for action in stage.actions:
		if action.id == choice_id:
			return str(action.get("visual_pool_id", ""))
	for bundle in stage.get("bundles", []):
		if bundle.id != choice_id:
			continue
		for action_id in bundle.actions:
			for action in stage.actions:
				if action.id == action_id and not str(action.get("visual_pool_id", "")).is_empty():
					return str(action.visual_pool_id)
	return ""

func show_examination_cg(pool_id: String, next_action: Callable) -> void:
	var pool: Dictionary = content.find_record("examination_cg_pools", pool_id)
	if pool.is_empty() or pool.paths.is_empty():
		next_action.call()
		return
	screen = "examination_cg"
	examination_cg_next = next_action
	base("", "", false)
	var paths: Array = pool.paths
	var path: String = str(paths[randi_range(0, paths.size() - 1)])
	var cg := TextureRect.new()
	cg.name = "ExaminationCG"
	cg.texture = load("res://" + path)
	cg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(cg)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.025, 0.04, 0.58)
	shade.position = Vector2(0, 650)
	shade.size = Vector2(1280, 150)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(shade)
	label_at(str(pool.caption), Vector2(55, 680), 23, Color("f4f0e6"), 900)
	var continue_button := button_at("查看结果  →", Vector2(1020, 690), Vector2(205, 52), continue_examination_cg)
	continue_button.name = "ExaminationCGContinue"
	get_tree().create_timer(3.5).timeout.connect(func():
		if screen == "examination_cg":
			continue_examination_cg())

func continue_examination_cg() -> void:
	if not examination_cg_next.is_valid():
		show_map()
		return
	var next_action := examination_cg_next
	examination_cg_next = Callable()
	next_action.call()

func surgery_cg_pool_for(surgery_id: String, patient_id: String, stage: String = "progress") -> Dictionary:
	var selected: Dictionary = {}
	var selected_score := -1
	for pool in content.collections.get("surgery_cg_pools", []):
		if str(pool.stage) != stage or not pool.surgery_ids.has(surgery_id):
			continue
		var patient_ids: Array = pool.patient_ids
		if not patient_ids.is_empty() and not patient_ids.has(patient_id):
			continue
		var score: int = int(pool.priority) + (10000 if patient_ids.has(patient_id) else 0)
		if score > selected_score:
			selected = pool
			selected_score = score
	return selected

func surgery_cg_path(pool: Dictionary) -> String:
	var paths: Array = pool.paths
	if paths.is_empty():
		return ""
	var candidates: Array = paths.duplicate()
	var previous: String = str(surgery_cg_last_path.get(pool.id, ""))
	if candidates.size() > 1 and candidates.has(previous):
		candidates.erase(previous)
	var path: String = str(candidates[randi_range(0, candidates.size() - 1)])
	surgery_cg_last_path[pool.id] = path
	return path

func ward_preparation_cg_pool_for(action_id: String, patient_id: String) -> Dictionary:
	var selected: Dictionary = {}
	var selected_score := -1
	for pool in content.collections.get("ward_preparation_cg_pools", []):
		if not pool.action_ids.has(action_id):
			continue
		var patient_ids: Array = pool.patient_ids
		if not patient_ids.is_empty() and not patient_ids.has(patient_id):
			continue
		var score: int = int(pool.priority) + (10000 if patient_ids.has(patient_id) else 0)
		if score > selected_score:
			selected = pool
			selected_score = score
	return selected

func ward_preparation_cg_path(pool: Dictionary) -> String:
	var paths: Array = pool.get("paths", [])
	if paths.is_empty():
		return ""
	var candidates: Array = paths.duplicate()
	var previous: String = str(ward_preparation_cg_last_path.get(pool.id, ""))
	if candidates.size() > 1 and candidates.has(previous):
		candidates.erase(previous)
	var path: String = str(candidates[randi_range(0, candidates.size() - 1)])
	ward_preparation_cg_last_path[pool.id] = path
	return path

func show_preop_with_ward_preparation_cg(id: String, pool: Dictionary) -> void:
	if str(pool.get("presentation", "splash")) == "fullscreen":
		show_ward_preparation_fullscreen(pool, show_preop.bind(id))
		return
	show_preop(id)
	show_ward_preparation_splash(pool)

func show_ward_preparation_splash(pool: Dictionary) -> void:
	var path := ward_preparation_cg_path(pool)
	if path.is_empty():
		return
	var overlay := Control.new()
	overlay.name = "WardPreparationSplash"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 20
	page.add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.005, 0.018, 0.025, 0.76)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(shade)
	var frame := Panel.new()
	frame.position = Vector2(125, 48)
	frame.size = Vector2(1030, 704)
	frame.add_theme_stylebox_override("panel", panel_style(Color("0b2832f7"), Color("91aeb0")))
	overlay.add_child(frame)
	var cg := TextureRect.new()
	cg.name = "WardPreparationSplashCG"
	cg.position = Vector2(18, 18)
	cg.size = Vector2(994, 557)
	cg.texture = load("res://" + path)
	cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(cg)
	var title := Label.new()
	title.text = str(pool.get("label", "病房术前准备"))
	title.position = Vector2(28, 589)
	title.size = Vector2(500, 32)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("e8cfaa"))
	frame.add_child(title)
	var caption := Label.new()
	caption.text = str(pool.get("caption", ""))
	caption.position = Vector2(28, 628)
	caption.size = Vector2(690, 54)
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_size_override("font_size", 18)
	caption.add_theme_color_override("font_color", Color("f4f0e6"))
	frame.add_child(caption)
	var continue_button := Button.new()
	continue_button.name = "WardPreparationSplashContinue"
	continue_button.text = "继续准备  →"
	continue_button.position = Vector2(790, 617)
	continue_button.size = Vector2(210, 58)
	continue_button.add_theme_font_size_override("font_size", 18)
	continue_button.add_theme_stylebox_override("normal", panel_style(Color("173d47f7"), Color("d1b989")))
	continue_button.add_theme_stylebox_override("hover", panel_style(Color("235765ff"), Color("e8cfaa")))
	continue_button.add_theme_stylebox_override("pressed", panel_style(Color("0d2932ff"), Color("e8cfaa")))
	continue_button.pressed.connect(dismiss_ward_preparation_splash.bind(overlay))
	frame.add_child(continue_button)

func dismiss_ward_preparation_splash(overlay: Control) -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()

func show_ward_preparation_fullscreen(pool: Dictionary, next_action: Callable) -> void:
	var path := ward_preparation_cg_path(pool)
	if path.is_empty():
		next_action.call()
		return
	screen = "ward_preparation_cg"
	ward_preparation_cg_next = next_action
	base("", "", false)
	var cg := TextureRect.new()
	cg.name = "WardPreparationCG"
	cg.texture = load("res://" + path)
	cg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(cg)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.025, 0.04, 0.62)
	shade.position = Vector2(0, 650)
	shade.size = Vector2(1280, 150)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(shade)
	label_at(str(pool.get("caption", "")), Vector2(55, 680), 23, Color("f4f0e6"), 900)
	var continue_button := button_at("继续准备  →", Vector2(1010, 690), Vector2(215, 52), continue_ward_preparation_cg)
	continue_button.name = "WardPreparationCGContinue"

func continue_ward_preparation_cg() -> void:
	if not ward_preparation_cg_next.is_valid():
		show_map()
		return
	var next_action := ward_preparation_cg_next
	ward_preparation_cg_next = Callable()
	next_action.call()

func show_surgery_cg(pool: Dictionary, next_action: Callable) -> void:
	var path := surgery_cg_path(pool)
	if path.is_empty():
		next_action.call()
		return
	screen = "surgery_cg"
	surgery_cg_next = next_action
	base("", "", false)
	var cg := TextureRect.new()
	cg.name = "SurgeryCG"
	cg.texture = load("res://" + path)
	cg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(cg)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.025, 0.04, 0.62)
	shade.position = Vector2(0, 650)
	shade.size = Vector2(1280, 150)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(shade)
	label_at(str(pool.caption), Vector2(55, 680), 23, Color("f4f0e6"), 900)
	var continue_button := button_at("查看手术结果  →", Vector2(985, 690), Vector2(240, 52), continue_surgery_cg)
	continue_button.name = "SurgeryCGContinue"
	get_tree().create_timer(4.5).timeout.connect(func():
		if screen == "surgery_cg":
			continue_surgery_cg())

func continue_surgery_cg() -> void:
	if not surgery_cg_next.is_valid():
		show_map()
		return
	var next_action := surgery_cg_next
	surgery_cg_next = Callable()
	next_action.call()

func show_preop_with_anesthesia_splash(id: String) -> void:
	show_preop(id)
	var preparation = game.preops.get(id)
	if preparation != null:
		show_anesthesia_splash(preparation)

func show_anesthesia_splash(preparation: RefCounted) -> void:
	var patient: Dictionary = content.find_record("patients", preparation.definition.patient_id)
	var path: String = str(patient.get("visuals", {}).get("portraits", {}).get("splash/general_anesthesia", ""))
	if path.is_empty():
		return
	var overlay := Control.new()
	overlay.name = "GeneralAnesthesiaSplash"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 20
	page.add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.005, 0.018, 0.025, 0.72)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(shade)
	var frame := Panel.new()
	frame.position = Vector2(195, 62)
	frame.size = Vector2(890, 666)
	frame.add_theme_stylebox_override("panel", panel_style(Color("0b2832f5"), Color("91aeb0")))
	overlay.add_child(frame)
	var cg := TextureRect.new()
	cg.name = "GeneralAnesthesiaSplashCG"
	cg.position = Vector2(22, 22)
	cg.size = Vector2(846, 476)
	cg.texture = load("res://" + path)
	cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(cg)
	var title := Label.new()
	title.text = "%s · 全身麻醉诱导完成" % patient.name
	title.position = Vector2(30, 516)
	title.size = Vector2(560, 34)
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", Color("e8cfaa"))
	frame.add_child(title)
	var caption := Label.new()
	caption.text = "麻醉面罩覆住她的口鼻。她闭上眼睛，呼吸逐渐变得平稳。"
	caption.position = Vector2(30, 557)
	caption.size = Vector2(590, 60)
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_size_override("font_size", 19)
	caption.add_theme_color_override("font_color", Color("f4f0e6"))
	frame.add_child(caption)
	var continue_button := Button.new()
	continue_button.name = "AnesthesiaSplashContinue"
	continue_button.text = "确认监护，开始手术  →"
	continue_button.position = Vector2(626, 555)
	continue_button.size = Vector2(235, 58)
	continue_button.add_theme_font_size_override("font_size", 18)
	continue_button.add_theme_stylebox_override("normal", panel_style(Color("173d47f7"), Color("d1b989")))
	continue_button.add_theme_stylebox_override("hover", panel_style(Color("235765ff"), Color("e8cfaa")))
	continue_button.add_theme_stylebox_override("pressed", panel_style(Color("0d2932ff"), Color("e8cfaa")))
	continue_button.pressed.connect(dismiss_anesthesia_splash.bind(overlay))
	frame.add_child(continue_button)

func dismiss_anesthesia_splash(overlay: Control) -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()

func show_encounter(id: String) -> void:
	var visit = game.open_visit(id)
	if visit == null:
		show_notice("未找到病例内容。")
		return
	var stage_key: String = id + "/" + visit.stage_id
	if clinic_record_stage != stage_key:
		clinic_record_stage = stage_key
		clinic_record_open = visit.current().get("auto_record", false)
	if clinic_record_open:
		clinic_notes_seen[id] = visit.notes.size()
	screen = "encounter"
	ClinicView.render(self, visit)

func choose_clinic_action(id: String) -> void:
	var visit = game.visits.get(game.active_id)
	if visit != null:
		var before_elapsed := game.elapsed()
		var before_minutes: int = visit.minutes
		var before_day := game.day_number()
		var was_completed: bool = visit.completed()
		var visual_pool_id := examination_visual_for_choice(visit, id)
		if visit.apply(id):
			game.settle_overtime(before_elapsed, visit.minutes - before_minutes)
			var next_view := show_encounter.bind(game.active_id)
			var destination: Callable = next_view
			if game.day_number() > before_day:
				destination = show_day_transition.bind(next_view)
			elif not was_completed and visit.completed() and game.select_micro_event("after_encounter", "clinic") != null:
				destination = show_micro_event
			if not visual_pool_id.is_empty():
				show_examination_cg(visual_pool_id, destination)
			else:
				destination.call()

func save_progress() -> void:
	if not game.can_save_progress():
		show_notice(game.save_block_reason())
		return
	if saves.write_slot(game):
		show_notice("已保存当前病例与术前进度。")
	else:
		show_notice(saves.last_error)

func request_load() -> void:
	if not saves.exists():
		show_notice("还没有存档，请先保存进度。")
		return
	confirm_action("读取存档将替换当前未保存的进度。", load_progress)

func load_progress() -> void:
	if not saves.read_slot(game):
		show_notice(saves.last_error)
		return
	reset_clinic_view()
	resume_progress()

func show_notice(message: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "星见医院"
	dialog.dialog_text = message
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered(Vector2i(580, 170))

func confirm_action(message: String, action: Callable) -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "确认操作"
	dialog.dialog_text = message
	dialog.ok_button_text = "确认"
	dialog.cancel_button_text = "取消"
	dialog.confirmed.connect(func():
		dialog.queue_free()
		action.call())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered(Vector2i(600, 180))

func toggle_clinic_record() -> void:
	clinic_record_open = not clinic_record_open
	show_encounter(game.active_id)

func reset_clinic_view() -> void:
	clinic_record_open = false
	clinic_record_stage = ""
	clinic_notes_seen.clear()

func preop_for_patient(patient_id: String) -> String:
	for definition in content.collections.preops:
		if definition.patient_id == patient_id:
			return definition.id
	return ""

func show_referral(patient_id: String) -> void:
	if patient_id != game.current_patient_id() or game.admitted_patient(patient_id):
		show_notice("这名患者当前不能转诊。")
		return
	var patient: Dictionary = content.find_record("patients", patient_id)
	var case_data: Dictionary = game.patient_case(patient_id)
	screen = "referral"
	base("安排转诊", "%s · %s岁　/　%s" % [patient.name, patient.age, case_data.get("title", "当前病例")], false, "clinic")
	label_at("选择一名医生接手这名患者。已完成的门诊记录会一并交接。", Vector2(60, 205), 23, Color("f4f0e6"), 650)
	add_portrait(patient, "neutral", "outpatient")
	var portrait = page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(790, 190)
		portrait.size = Vector2(390, 430)
	var row := 0
	for doctor in content.collections.staff:
		if doctor.profession != "doctor":
			continue
		var caption := "%s　/　%s　·　%s" % [doctor.name, doctor.specialty, doctor.personality]
		var doctor_button := button_at(caption, Vector2(60, 285 + row * 82), Vector2(665, 64), complete_referral.bind(patient_id, doctor.id))
		doctor_button.name = "ReferralDoctor_" + doctor.id
		row += 1
	button_at("← 返回门诊", Vector2(1030, 88), Vector2(185, 44), show_location.bind("clinic", true))

func complete_referral(patient_id: String, doctor_id: String) -> void:
	var patient: Dictionary = content.find_record("patients", patient_id)
	var doctor: Dictionary = content.find_record("staff", doctor_id)
	if not game.refer_current_patient(doctor_id):
		show_notice(game.last_error)
		return
	reset_clinic_view()
	show_location("clinic", true)
	show_notice("已将%s转诊给%s。候诊列表已切换到下一名患者。" % [patient.name, doctor.name])

func show_preop(id: String) -> void:
	var preparation = game.open_preop(id)
	if preparation == null:
		show_notice("请先完成接诊并收住院。")
		return
	if start_character_event_from_preop_stage(str(preparation.stage_id)):
		return
	screen = "preop"
	PreopView.render(self, preparation)

func incision_video_path(action_id: String, procedure_group: String, _anesthetized: bool) -> String:
	if not action_id.begins_with("incise_"):
		return ""
	var pool_id := "abdominal" if procedure_group in ABDOMINAL_INCISION_PROCEDURE_GROUPS else "pelvic" if procedure_group == "female_pelvic" else "breast" if procedure_group == "breast" else "thoracic" if procedure_group in ["thoracic", "cardiac"] else ""
	return random_incision_video_from_pool(pool_id) if not pool_id.is_empty() else ""

func random_incision_video_from_pool(pool_id: String) -> String:
	var available: Array[String] = []
	for path in INCISION_VIDEO_POOLS.get(pool_id, []):
		if ResourceLoader.exists(str(path)):
			available.append(str(path))
	if available.is_empty():
		return ""
	var previous: String = str(incision_video_last_path.get(pool_id, ""))
	var eligible: Array[String] = []
	for path in available:
		if available.size() == 1 or path != previous:
			eligible.append(path)
	var selected: String = eligible.pick_random()
	incision_video_last_path[pool_id] = selected
	return selected

func show_surgery_video(video_path: String, next_action: Callable, muted: bool = false) -> void:
	var stream := load(video_path) as VideoStream
	if stream == null:
		next_action.call()
		return
	screen = "surgery_video"
	surgery_video_next = next_action
	var shade := ColorRect.new()
	shade.name = "SurgeryVideoOverlay"
	shade.color = Color(0.005, 0.015, 0.02, 0.94)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	page.add_child(shade)
	var frame := Panel.new()
	frame.name = "SurgeryVideoFrame"
	frame.position = Vector2(224, 82)
	frame.size = Vector2(832, 584)
	frame.add_theme_stylebox_override("panel", panel_style(Color("102c35"), Color("b9a779")))
	page.add_child(frame)
	label_at("切口建立", Vector2(264, 108), 27, Color("e8cfaa"), 752)
	var video := VideoStreamPlayer.new()
	video.name = "SurgeryVideoPlayer"
	video.position = Vector2(264, 158)
	video.size = Vector2(752, 416)
	video.expand = true
	video.stream = stream
	video.speed_scale = 2.5
	video.volume_db = -80.0 if muted else 0.0
	video.finished.connect(complete_surgery_video)
	page.add_child(video)
	var audio_note := "静音播放 · 患者已接受麻醉" if muted else "保留现场声音 · 未麻醉"
	label_at(audio_note, Vector2(264, 598), 16, Color("c2d2cc"), 520)
	var skip_button := button_at("跳过动画", Vector2(856, 594), Vector2(160, 44), complete_surgery_video)
	skip_button.name = "SurgeryVideoSkip"
	video.play()

func complete_surgery_video() -> void:
	if not surgery_video_next.is_valid():
		return
	var next_action := surgery_video_next
	surgery_video_next = Callable()
	next_action.call()

func finish_surgery_and_return() -> void:
	if game.select_micro_event("after_surgery", "or") != null:
		show_micro_event()
		return
	settle_surgery_return()

func settle_surgery_return() -> void:
	if game.pending_surgery_day_transition:
		show_day_transition(complete_surgery_return)
	else:
		complete_surgery_return()

func complete_surgery_return() -> void:
	game.finish_active_surgery()
	show_map()

func preop_event(event: Dictionary) -> void:
	var preparation = game.preops.get(game.active_preop_id)
	if preparation == null:
		return
	var submitted_event := event
	if event.get("kind") == "action" and str(event.get("id", "")).begins_with("incise_") and not event.has("operative_background_id"):
		submitted_event = event.duplicate(true)
		submitted_event["operative_background_id"] = OperativeBackgrounds.random_id()
	var before_elapsed := game.elapsed()
	var before_minutes: int = preparation.minutes
	var before_day := game.day_number()
	var action_id := str(submitted_event.get("id", ""))
	var surgery: Dictionary = preparation.current_surgery()
	var incision_video := incision_video_path(action_id, str(surgery.get("procedure_group", "")), preparation.flags.has("anesthetized"))
	var incision_video_muted: bool = preparation.anesthesia != "未麻醉"
	var show_general_anesthesia_splash: bool = submitted_event.get("kind") == "action" and str(submitted_event.get("id", "")) in ["induction_reassure", "induction_brief"]
	var ward_preparation_pool: Dictionary = {}
	# Once general anesthesia has taken effect, intimate preparation/action CGs
	# (catheterization, disinfection and scalpel-ready art) stay hidden. The
	# dedicated induction CG has already represented the patient's transition
	# into unconsciousness; the remaining steps use the normal OR presentation.
	if submitted_event.get("kind") == "action" and not preparation.flags.has("anesthetized"):
		ward_preparation_pool = ward_preparation_cg_pool_for(str(submitted_event.get("id", "")), str(preparation.definition.patient_id))
	if preparation.apply(submitted_event):
		var crossed_day := game.settle_overtime(before_elapsed, preparation.minutes - before_minutes)
		var next_view: Callable = show_preop.bind(game.active_preop_id)
		if show_general_anesthesia_splash:
			next_view = show_preop_with_anesthesia_splash.bind(game.active_preop_id)
		elif not ward_preparation_pool.is_empty():
			next_view = show_preop_with_ward_preparation_cg.bind(game.active_preop_id, ward_preparation_pool)
		elif not incision_video.is_empty():
			next_view = show_surgery_video.bind(incision_video, show_preop.bind(game.active_preop_id), incision_video_muted)
		var surgery_finished: bool = preparation.surgery_success and preparation.current().kind == "surgery_complete"
		if surgery_finished:
			if crossed_day:
				game.pending_surgery_day_transition = true
			var pool := surgery_cg_pool_for(preparation.procedure_id, preparation.definition.patient_id)
			if not pool.is_empty():
				show_surgery_cg(pool, next_view)
			else:
				next_view.call()
		elif game.day_number() > before_day:
			show_day_transition(next_view)
		else:
			next_view.call()
	else:
		show_notice(preparation.last_error)

func show_day_transition(next_action: Callable) -> void:
	screen = "day_transition"
	day_transition_next = next_action
	base("", "", false, "hospital_night")
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.025, 0.08, 0.34)
	shade.position = Vector2(0, 0)
	shade.size = Vector2(1280, 800)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(shade)
	label_at("一天结束了……", Vector2(0, 285), 46, Color("f4f0e6"), 1280).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_at("夜色笼罩医院。新的工作日将从 09:00 开始。", Vector2(0, 365), 22, Color("d7dfdf"), 1280).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button_at("进入下一天  →", Vector2(475, 465), Vector2(330, 58), continue_after_day_transition)

func continue_after_day_transition() -> void:
	if day_transition_next.is_valid():
		var next_action := day_transition_next
		day_transition_next = Callable()
		next_action.call()

func resume_progress() -> void:
	if game.active_mode == "micro_event" and not game.active_micro_event_id.is_empty():
		show_micro_event()
	elif game.active_mode == "character_event" and not game.active_character_event_id.is_empty():
		show_character_event()
	elif game.active_mode == "preop" and not game.active_preop_id.is_empty():
		show_preop(game.active_preop_id)
	elif not game.active_id.is_empty():
		show_encounter(game.active_id)
	else:
		show_map()
