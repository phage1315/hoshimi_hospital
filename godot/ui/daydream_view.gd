extends RefCounted
## Presentation adapter for the existing fixed VN session, without GameState effects.
const Catalog = preload("res://godot/systems/daydream_catalog.gd")
const Session = preload("res://godot/systems/character_event_session.gd")
var app: Control
var maximum := 0
var dark_confirmed := false
var return_screen := "player_office"
var testing := false
var session: RefCounted
var pending: Dictionary = {}
var catalog: Array = Catalog.entries()

func open(host: Control) -> void:
	if host.screen not in ["player_office", "sunday_office"] or not host.game.can_save_progress(): return
	app = host
	testing = false
	catalog = Catalog.entries()
	return_screen = app.screen
	app.game.daydream_active = true
	show_catalog()

func open_test(host: Control) -> void:
	if not OS.is_debug_build(): return
	app = host
	testing = true
	catalog = Catalog.entries()
	maximum = 2
	dark_confirmed = true
	return_screen = "event_test_hub"
	app.game.daydream_active = true
	show_catalog()

func leave() -> void:
	var destination := return_screen
	session = null
	pending = {}
	app.game.daydream_active = false
	testing = false
	if destination == "event_test_hub": app.show_event_test_hub()
	elif destination == "sunday_office": app.show_sunday_office_menu()
	else: app.show_player_office()

func heading(screen: String) -> void:
	app.screen = screen
	var title: String = app.tx("ui.daydream.test_title", "白日梦事件测试") if testing else app.tx("ui.daydream.title", "白日梦")
	var subtitle: String = app.tx("ui.daydream.test_subtitle", "开发者隔离入口 · 三个事件 · 不检查正式解锁条件 · 不写入存档") if testing else app.tx("ui.daydream.subtitle", "非正史幻想 · 不消耗时间 · 不改变关系或能力")
	var exit_label: String = app.tx("ui.daydream.return_test_hub", "← 返回事件测试中心") if testing else app.tx("ui.common.return_office", "← 返回办公室")
	app.base(title, subtitle, false, "player_office")
	app.button_at(exit_label, Vector2(985, 88), Vector2(230, 44), leave).name = "DaydreamExit"

func level_label(index: int) -> String:
	return [app.tx("ui.daydream.normal", "普通"), app.tx("ui.daydream.intense", "重度"), app.tx("ui.daydream.dark", "暗黑")][index]

func show_catalog() -> void:
	pending = {}
	heading("daydream_catalog")
	if not testing:
		app.label_at(app.tx("ui.daydream.maximum", "最高显示等级"), Vector2(60, 175), 22, Color.WHITE, 260)
		for i in range(3):
			var button: Button = app.button_at(level_label(i), Vector2(340 + i * 200, 165), Vector2(180, 46), set_maximum.bind(i))
			button.name = "DaydreamLevel_%s" % i
			button.disabled = maximum == i
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(60, 175 if testing else 245)
	scroll.size = Vector2(1160, 500 if testing else 430)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	app.page.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 12)
	scroll.add_child(rows)
	for entry in catalog:
		if not Catalog.visible(entry, maximum): continue
		var unlocked := testing or Catalog.unlocked(entry, app.game)
		var ready := Catalog.valid(entry)
		var state: String = app.tx("ui.daydream.test_state", "测试") if testing else (app.tx("ui.daydream.read", "已阅") if entry.get("id", "") in app.game.daydream_read_ids else app.tx("ui.daydream.unread", "未阅"))
		if not ready: state = app.tx("ui.daydream.unavailable", "尚未开放")
		elif not unlocked: state = app.tx("ui.daydream.locked", "未解锁")
		var button := Button.new()
		button.name = "DaydreamEntry_" + str(entry.get("id", ""))
		button.custom_minimum_size = Vector2(1100, 112)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.text = "%s · %s · %s\n%s\n%s" % [Catalog.localized(entry.get("title", {}), app.content.localizer.locale), level_label(Catalog.LEVELS.find(entry.level)), state, Catalog.localized(entry.get("cast", {}), app.content.localizer.locale), Catalog.localized(entry.get("tags", {}), app.content.localizer.locale)]
		button.tooltip_text = Catalog.localized(entry.get("unlock_hint", {}), app.content.localizer.locale)
		button.disabled = not unlocked or not ready
		button.pressed.connect(confirm_entry.bind(entry))
		rows.add_child(button)
	if rows.get_child_count() == 0:
		app.label_at(app.tx("ui.daydream.empty", "当前等级下暂无可播放的白日梦。"), Vector2(80, 300), 24, Color.WHITE, 1050)

func set_maximum(value: int) -> void:
	if value == 2 and not dark_confirmed:
		heading("daydream_warning")
		app.scrollable_text_at(app.tx("ui.daydream.dark_warning", "暗黑级别可能包含令人不安的主题。开启后只显示列表，不会自动播放；每篇开始前仍会显示具体内容提示。"), Vector2(80, 240), Vector2(1090, 200), 24, Color.WHITE, "DaydreamWarning")
		app.button_at(app.tx("ui.daydream.enable_dark", "开启暗黑级别"), Vector2(80, 490), Vector2(450, 54), accept_dark).name = "DaydreamAcceptDark"
		app.button_at(app.tx("ui.daydream.back", "返回列表"), Vector2(570, 490), Vector2(450, 54), show_catalog).name = "DaydreamCancelDark"
		return
	maximum = clampi(value, 0, 2)
	show_catalog()

func accept_dark() -> void:
	dark_confirmed = true
	maximum = 2
	show_catalog()

func confirm_entry(entry: Dictionary) -> void:
	if not Catalog.visible(entry, maximum) or (not testing and not Catalog.unlocked(entry, app.game)) or not Catalog.valid(entry): return
	pending = entry
	heading("daydream_confirm")
	app.label_at(Catalog.localized(entry.title, app.content.localizer.locale), Vector2(80, 200), 25, Color.WHITE, 1080)
	app.scrollable_text_at(Catalog.localized(entry.tags, app.content.localizer.locale), Vector2(80, 270), Vector2(1080, 180), 24, Color.WHITE, "DaydreamTags")
	app.button_at(app.tx("ui.daydream.play", "开始白日梦"), Vector2(80, 510), Vector2(450, 54), begin).name = "DaydreamBegin"
	app.button_at(app.tx("ui.daydream.back", "返回列表"), Vector2(570, 510), Vector2(450, 54), show_catalog).name = "DaydreamCancel"

func begin() -> void:
	if pending.is_empty() or not Catalog.visible(pending, maximum) or (not testing and not Catalog.unlocked(pending, app.game)): return
	var definition := Catalog.definition(pending, app.content.localizer.locale)
	if definition.is_empty(): return
	session = Session.new(definition)
	show_scene()

func show_scene() -> void:
	if session == null: return
	if session.completed:
		var id := str(session.definition.id)
		if id not in app.game.daydream_read_ids: app.game.daydream_read_ids.append(id)
		leave()
		return
	app.screen = "daydream_playback"
	var node: Dictionary = session.current()
	app.base(str(session.definition.title), app.tx("ui.daydream.subtitle", "非正史幻想 · 不消耗时间 · 不改变关系或能力"), false, str(node.get("background_id", "player_office")))
	var speaker_id := str(node.get("actor_id", session.definition.get("actor_id", "")))
	var actor: Dictionary = {}
	if speaker_id not in ["player", "narrator"]:
		actor = app.content.find_record("staff", speaker_id)
	# CG cues belong to the scene, not to the current speaker. Narration nodes
	# therefore use the same fixed-VN CG renderer as character dialogue nodes.
	if not str(node.get("cg_path", "")).is_empty():
		app.add_character_event_visual(actor, node, str(node.get("outfit", actor.get("visuals", {}).get("default_outfit", ""))))
	elif not actor.is_empty():
		app.add_character_event_visual(actor, node, str(node.get("outfit", actor.get("visuals", {}).get("default_outfit", ""))))
	var dialogue: Dictionary = app.dialogue_page("daydream:%s:%s" % [session.definition.id, node.id], str(node.text), bool(node.get("allow_dialogue_scroll", false)), true)
	app.vn_dialogue_box(str(node.speaker_label), str(dialogue.text), "DaydreamDialogue", bool(dialogue.allow_scroll))
	if bool(dialogue.has_more):
		var button: Button = app.button_at(app.tx("ui.common.continue", "继续  ▷"), Vector2(60, app.VN_SINGLE_ACTION_Y), Vector2(655, 54), app.advance_dialogue_page.bind(show_scene))
		app.register_dialogue_continue(button, str(dialogue.text))
	else:
		for i in range(node.choices.size()):
			var choice: Dictionary = node.choices[i]
			var button: Button = app.button_at(str(choice.label), Vector2(60, app.vn_choice_y(node.choices.size(), i)), Vector2(655, 54), choose.bind(str(choice.id)))
			button.name = "DaydreamChoice_" + str(choice.id)
			if node.choices.size() == 1: app.register_dialogue_continue(button, str(dialogue.text))
		if node.choices.size() > 1: app.pause_dialogue_for_choice()
	app.add_dialogue_playback_controls()
	var exit_label: String = app.tx("ui.daydream.return_test_hub", "← 返回事件测试中心") if testing else app.tx("ui.common.return_office", "← 返回办公室")
	app.button_at(exit_label, Vector2(985, 88), Vector2(230, 44), leave).name = "DaydreamExit"

func choose(id: String) -> void:
	if session != null and session.apply(id): show_scene()
