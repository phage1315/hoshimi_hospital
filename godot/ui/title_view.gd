extends RefCounted
## Title-only presentation. Preferences never enter a gameplay save.
const BACKGROUND := "res://assets/backgrounds/title/spring_corridor.png"
const NOTICE_VERSION := 1
# localization-invariant: the author's three-language notice is always simultaneous.
const SHORT_NOTICE := "开发原型｜禁止销售及商业使用\n\nDEVELOPMENT PROTOTYPE\nNOT FOR SALE OR COMMERCIAL USE\n\n開発試作版｜販売・商用利用禁止" # localization-invariant
# localization-invariant: intentionally multilingual, including faithful EN/JA translations of the buyer warning.
const FULL_NOTICE := "中文\n本游戏为开发中的非商业测试原型，仅供免费测试及体验。禁止销售、转售、收费分发或用于任何商业用途。\n如果有人向你出售本游戏的开发原型版本，请注意：该销售行为未经开发者授权。\n\nEnglish\nThis game is a non-commercial development prototype for free testing and evaluation only. Sale, resale, paid distribution, and any other commercial use are prohibited.\nIf someone sells you this development prototype, please note: that sale has not been authorized by the developer.\n\n日本語\n本作は開発中の非商用テスト用プロトタイプです。無償でのテスト・評価のみを目的としており、販売・転売・有償配布、その他一切の商用利用を禁止します。\n本作の開発試作版を販売する者がいた場合、その販売は開発者の許可を得たものではありません。" # localization-invariant

static func text(app, value: String, pos: Vector2, font_size: int, color: Color, width: float, node_name: String = "") -> Label:
	var label: Label = app.label_at(value, pos, font_size, color, width)
	label.add_theme_constant_override("outline_size", 0)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not node_name.is_empty(): label.name = node_name
	return label

static func render(app) -> void:
	app.base("", "", false, "lobby")
	for child in app.page.get_children():
		if child != app.background:
			app.page.remove_child(child)
			child.queue_free()
	app.background.texture = load(BACKGROUND)
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.43, 1.0])
	gradient.colors = PackedColorArray([Color(0.025,0.075,0.09,0.96), Color(0.025,0.075,0.09,0.86), Color(0.025,0.075,0.09,0.10)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2.ZERO
	texture.fill_to = Vector2.RIGHT
	var wash := TextureRect.new()
	wash.texture = texture
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wash.name = "TitleGradient"
	app.page.add_child(wash)
	text(app, "H O S H I M I   H O S P I T A L", Vector2(72,65), 18, Color("b6d2cf"), 600)
	text(app, app.tx("ui.title.main", "星见医院"), Vector2(68,98), 64, Color("fffaf0"), 950, "TitleName")
	text(app, app.tx("ui.title.tagline", "手术室里决定命运，走廊里改变关系。"), Vector2(74,191), 20, Color("d2e0dc"), 700)
	text(app, "PROTOTYPE v0.5", Vector2(1010,54), 17, Color("18383f"), 230)
	var slot := latest_slot(app)
	var captions := [app.tx("ui.title.resume", "继续游戏"), app.tx("ui.title.new", "开始新游戏"), app.tx("ui.title.load", "读取存档"), app.tx("ui.title.directory", "医院导览")]
	var actions := [func(): resume_latest(app), app.request_new_game, app.show_save_slots.bind("load", true), app.show_map]
	var names := ["TitleContinue", "TitleNewGame", "TitleLoad", "TitleDirectory"]
	for i in range(4):
		var button: Button = app.button_at(captions[i] + "    →", Vector2(74,282+i*78), Vector2(450,64), actions[i])
		button.name = names[i]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 24)
		button.add_theme_stylebox_override("normal", app.panel_style(Color(0.08,0.20,0.24,0.85),Color(0.5,0.7,0.7,0.35)))
		button.add_theme_stylebox_override("focus", app.panel_style(Color(0.25,0.42,0.44,0.9),Color("bbdbd4")))
		if i == 0: button.disabled = slot == 0
		if i == (0 if slot > 0 else 1): button.grab_focus()
	var panel := Panel.new()
	panel.position = Vector2(700,430)
	panel.size = Vector2(510,246)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", app.panel_style(Color(0.045,0.12,0.15,0.86),Color("b49559")))
	app.page.add_child(panel)
	text(app, "NOT FOR SALE", Vector2(724,449), 22, Color("efca82"), 450)
	text(app, SHORT_NOTICE, Vector2(724,493), 18, Color("f1ead9"), 465, "TitleTrilingualNotice")
	app.button_at(app.tx("ui.title.language_short", "语言 / Language"), Vector2(74,616), Vector2(180,40), app.switch_locale).name = "TitleLanguage"
	app.button_at(app.tx("ui.title.settings", "设置"), Vector2(268,616), Vector2(120,40), func(): settings(app)).name = "TitleSettings"
	app.button_at(app.tx("ui.title.exit", "退出"), Vector2(402,616), Vector2(122,40), func(): app.get_tree().quit()).name = "TitleExit"
	for name in ["TitleLanguage", "TitleSettings", "TitleExit"]:
		app.page.get_node(name).add_theme_font_size_override("font_size", 18)
	app.button_at(app.tx("ui.title.notice_link", "使用声明"), Vector2(1030,686), Vector2(180,36), func(): notice(app, false)).name = "TitleNotice"
	text(app, app.tx("ui.title.footer", "开发版本 0.5 · 非医学教学用途"), Vector2(74,748), 14, Color("bdd0cb"), 700)
	if OS.is_debug_build():
		app.button_at(app.tx("ui.title.developer", "开发者工具 · F10"), Vector2(980,739), Vector2(230,36), func(): developer(app)).name = "TitleDeveloper"

static func latest_slot(app) -> int:
	var selected := 0
	var newest := ""
	for slot in range(1, app.saves.SLOT_COUNT + 1):
		var summary: Dictionary = app.saves.slot_summary(slot)
		if not summary.get("valid", false): continue
		var stamp := str(summary.get("saved_at", ""))
		if stamp.length() < 4 or not stamp.left(4).is_valid_int():
			stamp = Time.get_datetime_string_from_unix_time(FileAccess.get_modified_time(app.saves.slot_path(slot)))
		if selected == 0 or stamp > newest:
			selected = slot
			newest = stamp
	return selected

static func resume_latest(app) -> void:
	var slot := latest_slot(app)
	if slot == 0: return
	if not app.game.visits.is_empty():
		app.confirm_action(app.tx("ui.load.confirm", "读取位置 %d 将替换当前未保存的进度。") % slot, app.load_progress.bind(slot))
	else:
		app.load_progress(slot)

static func modal(app, title: String, dimensions: Vector2i) -> AcceptDialog:
	var dialog := AcceptDialog.new()
	dialog.title = title
	dialog.ok_button_text = app.tx("ui.title.close", "关闭")
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	app.add_child(dialog)
	dialog.popup_centered(dimensions)
	return dialog

static func developer(app) -> void:
	if not OS.is_debug_build() or app.dialogue_modal_open(): return
	var dialog := modal(app, app.tx("ui.title.developer", "开发者工具 · F10"), Vector2i(520,240))
	dialog.name = "TitleDeveloperDialog"
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 18)
	dialog.add_child(list)
	var captions := [app.tx("ui.test_save.entry", "DEBUG：测试存档生成器"), app.tx("ui.event_test.entry", "DEBUG：事件测试中心")]
	var actions := [app.show_test_save_generator, app.show_event_test_hub]
	for i in range(2):
		var button := Button.new()
		button.name = "TestSaveGeneratorEntry" if i == 0 else "EventTestHubEntry"
		button.text = captions[i]
		button.custom_minimum_size.y = 60
		button.pressed.connect(func(): dialog.hide(); dialog.queue_free(); actions[i].call())
		list.add_child(button)

static func settings(app) -> void:
	var dialog := modal(app, app.tx("ui.title.settings", "设置"), Vector2i(570,420))
	dialog.name = "TitleSettingsDialog"
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 20)
	dialog.add_child(list)
	var fullscreen := CheckButton.new()
	fullscreen.text = app.tx("ui.title.fullscreen", "全屏显示")
	fullscreen.button_pressed = DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	fullscreen.toggled.connect(func(enabled: bool):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)
		var config := ConfigFile.new()
		config.load(app.title_preferences_path)
		config.set_value("display", "fullscreen", enabled)
		config.save(app.title_preferences_path))
	list.add_child(fullscreen)
	var label := Label.new()
	label.text = app.tx("ui.title.auto_speed", "对白自动播放速度")
	list.add_child(label)
	var speed := OptionButton.new()
	speed.name = "DialogueSpeedSetting"
	for caption in [app.tx("ui.title.slow", "慢"), app.tx("ui.title.normal", "标准"), app.tx("ui.title.fast", "快"), app.tx("ui.title.faster", "很快"), app.tx("ui.dialogue.speed.light_speed", "光速")]: speed.add_item(caption)
	speed.select(app.dialogue_auto_speed_index)
	speed.item_selected.connect(func(index: int): app.dialogue_auto_speed_index = index; app.content.localizer.save_dialogue_auto_speed(index))
	list.add_child(speed)
	var music_label := Label.new()
	music_label.text = "BGM volume" if app.content.localizer.locale == "en" else "背景音乐音量" # localization-invariant
	list.add_child(music_label)
	var music_volume := HSlider.new()
	music_volume.name = "MusicVolumeSetting"
	music_volume.min_value = 0
	music_volume.max_value = 100
	music_volume.step = 1
	music_volume.value = app.music.volume * 100.0
	music_volume.custom_minimum_size = Vector2(480, 32)
	music_volume.value_changed.connect(func(value: float): app.music.set_volume(value / 100.0, true))
	list.add_child(music_volume)

static func startup(app) -> void:
	if not app.title_notice_enabled: return
	var config := ConfigFile.new()
	config.load(app.title_preferences_path)
	if bool(config.get_value("display", "fullscreen", false)):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if int(config.get_value("notice", "acknowledged_version", 0)) < NOTICE_VERSION:
		notice(app, true)

static func notice(app, first_run: bool) -> void:
	var dialog := modal(app, app.tx("ui.title.notice_heading", "开发原型使用声明"), Vector2i(960,650))
	dialog.name = "TitleUsageNotice"
	dialog.ok_button_text = app.tx("ui.title.acknowledge", "我已阅读，继续") if first_run else app.tx("ui.title.close", "关闭")
	var prose := RichTextLabel.new()
	prose.custom_minimum_size = Vector2(920,550)
	prose.text = FULL_NOTICE
	prose.add_theme_font_size_override("normal_font_size", 19)
	prose.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog.add_child(prose)
	if first_run:
		dialog.exclusive = true
		dialog.confirmed.connect(func():
			var config := ConfigFile.new()
			config.load(app.title_preferences_path)
			config.set_value("notice", "acknowledged_version", NOTICE_VERSION)
			if config.save(app.title_preferences_path) != OK:
				app.show_notice(app.tx("ui.title.preference_error", "无法保存界面偏好；下次启动将再次显示声明。")))

static func chapter(app) -> void:
	app.screen = "opening_chapter"
	app.base("", "", false, "lobby")
	app.page.get_node("CalendarHeader").hide()
	text(app, app.tx("ui.title.chapter", "春日序章"), Vector2(180,300), 64, Color("fffaf0"), 900)
	var button: Button = app.button_at(app.tx("ui.title.begin", "开始    →"), Vector2(180,440), Vector2(330,60), app.start_story)
	button.name = "OpeningChapterContinue"
	app.register_dialogue_continue(button, "")
	button.grab_focus()
