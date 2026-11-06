extends RefCounted
## Uses the shared VN pager/session; no staff/relationship registration.
const NPC = preload("res://godot/systems/megumin.gd")
const Session = preload("res://godot/systems/character_event_session.gd")
var app: Control
var session: RefCounted
var entry: Dictionary = {}
var started_day := 0
var started_clock := 540
var resume: Callable
var testing := false

func try_intro(host: Control) -> bool:
	if not NPC.intro_due(host.game): return false
	testing = false
	for e in NPC.entries():
		if e.content_id == NPC.INTRO:
			open(host, e, host.game.day_number(), Callable(host, "show_map").bind(false))
			return true
	return false

func talk(host: Control) -> void:
	if not NPC.on_shift(host.game): return
	testing = false
	var selected := NPC.choose(host.game)
	if selected.is_empty(): return
	open(host, selected, host.game.day_number(), Callable(host, "show_location").bind("lobby", true, false, false))

func try_departure(host: Control, day: int, clock: int, continuation: Callable) -> bool:
	testing = false
	var selected := NPC.choose(host.game, true, day, clock)
	if selected.is_empty(): return false
	open(host, selected, day, continuation)
	return true

func open(host: Control, selected: Dictionary, day: int, continuation: Callable) -> void:
	app = host
	entry = selected
	started_day = day
	started_clock = 1020 if selected.get("kind", "") == "afterwork_micro" or str(selected.content_id) in ["megumin_l17", "megumin_l18", "megumin_l19", "megumin_l20"] else app.game.current_absolute_clock()
	resume = continuation
	session = Session.new(NPC.definition(app.game, entry, app.content.localizer.locale))
	app.game.megumin_active = true
	app.reset_dialogue_page()
	show_scene()

func leave() -> void:
	var continuation := resume
	session = null
	entry = {}
	app.game.megumin_active = false
	app.reset_dialogue_page()
	if continuation.is_valid(): continuation.call()
	else: app.show_map(false)

func show_scene() -> void:
	if session == null: return
	if session.completed:
		if not testing: NPC.complete(app.game, entry, started_day)
		leave()
		return
	app.screen = "megumin_event"
	var node: Dictionary = session.current()
	var en: bool = app.content.localizer.locale == "en"
	# Document headings contain production annotations; none are dialogue captions.
	var background := "lobby"
	if entry.kind == "afterwork_micro":
		var month: int = int(app.game.calendar_date(started_day).month)
		var season := "winter" if month in [12,1,2] else ("spring" if month in [3,4,5] else ("summer" if month in [6,7,8] else "autumn"))
		background = "after_work_street_" + season + ("_night" if season == "winter" else "")
	app.base("Megumin" if en else "惠惠", "Reception" if en else "前台接待", false, background) # localization-invariant
	if entry.content_id == "megumin_m22":
		for i in range(36):
			var rain := Line2D.new()
			rain.points = PackedVector2Array([Vector2((i*97)%1280,(i*53)%530),Vector2((i*97)%1280-9,(i*53)%530+34)])
			rain.default_color = Color(0.7,0.8,0.9,0.3)
			rain.width = 1.5
			app.page.add_child(rain)
	var school: bool = entry.get("kind", "") == "afterwork_micro" or str(entry.content_id) in ["megumin_l17", "megumin_l18", "megumin_l19", "megumin_l20"]
	var path := "res://assets/characters/npc_megumin/" + str(node.get("portrait", "school_neutral" if school else "reception_neutral")) + ".png"
	var art := TextureRect.new()
	art.name = "MeguminPortrait"
	art.texture = load(path)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.position = Vector2(820, 170)
	art.size = Vector2(306.6667, 460)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	app.page.add_child(art)
	if str(node.get("portrait", "")).begins_with("halloween_original_mage_"):
		var sign := Label.new()
		sign.name = "MeguminReceptionSign"
		sign.text = "Reception Assistant" if en else "受付補助 / 前台接待" # localization-invariant
		sign.position = Vector2(60, 410)
		sign.add_theme_font_size_override("font_size", 20)
		sign.add_theme_color_override("font_color", Color("e8cfaa"))
		app.page.add_child(sign)
	if str(node.actor_id) not in ["npc_megumin", "player", "narrator", "visitor"]:
		var actor: Dictionary = app.content.find_record("staff", str(node.actor_id))
		if not actor.is_empty():
			var colleague: Dictionary = node.duplicate(true)
			colleague["expression"] = "neutral"
			app.add_character_event_visual(actor, colleague, "scrubs" if str(node.actor_id) == "doc_rei" else str(actor.get("visuals", {}).get("default_outfit", "uniform")))
			var other = app.page.get_node_or_null("CharacterPortrait")
			if other != null:
				other.position = Vector2(210, 165)
				other.size = Vector2(450, 500)
	if node.choices.size() > 1:
		app.pause_dialogue_for_choice()
		for i in range(node.choices.size()):
			var c: Dictionary = node.choices[i]
			app.button_at(str(c.label), Vector2(60, app.vn_choice_y(node.choices.size(), i)), Vector2(1100, 54), choose.bind(str(c.id))).name = "MeguminChoice_" + str(c.id)
	else:
		var dialogue: Dictionary = app.dialogue_page("megumin:%s:%s" % [session.definition.id, node.id], str(node.text), false, true)
		app.vn_dialogue_box(str(node.speaker_label), str(dialogue.text), "MeguminDialogue", bool(dialogue.allow_scroll))
		var callback: Callable = app.advance_dialogue_page.bind(show_scene) if bool(dialogue.has_more) else choose.bind(str(node.choices[0].id))
		var button: Button = app.button_at(app.tx("ui.common.continue", "继续  ▷"), Vector2(60, app.VN_SINGLE_ACTION_Y), Vector2(655, 54), callback)
		button.name = "MeguminContinue"
		app.register_dialogue_continue(button, str(dialogue.text))
	app.add_dialogue_playback_controls()

func choose(id: String) -> void:
	if session != null and session.apply(id): show_scene()

func open_catalog(host: Control) -> void:
	if not OS.is_debug_build(): return
	app = host
	testing = true
	app.game.megumin_active = true
	session = null
	app.screen = "megumin_catalog"
	var en: bool = app.content.localizer.locale == "en"
	app.base("Megumin · Content Preview" if en else "惠惠 · 内容预览", "Preview only · No progress or rewards" if en else "仅预览 · 不写入进度或奖励", false, "lobby") # localization-invariant
	app.button_at("Back" if en else "返回", Vector2(1040,88),Vector2(160,44),close_catalog).name="MeguminCatalogExit" # localization-invariant
	app.button_at("Portraits" if en else "立绘",Vector2(60,165),Vector2(250,44),preview_art.bind("casual_neutral")).name="MeguminArtEntry" # localization-invariant
	var scroll := ScrollContainer.new()
	scroll.position=Vector2(60,225)
	scroll.size=Vector2(1140,460)
	app.page.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scroll.add_child(rows)
	for e in NPC.entries():
		var b := Button.new()
		b.text = str(e.title.get(app.content.localizer.locale,""))
		b.custom_minimum_size=Vector2(1100,48)
		b.name="MeguminPreview_"+str(e.content_id)
		b.pressed.connect(open.bind(app,e,app.game.day_number(),open_catalog.bind(app)))
		rows.add_child(b)

func close_catalog() -> void:
	session=null
	testing=false
	app.game.megumin_active=false
	app.show_event_test_hub()

func preview_art(key: String) -> void:
	app.screen="megumin_art"
	var profile: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/npcs/megumin/profile.json"))
	app.base("Megumin",key,false,"lobby")
	var art := TextureRect.new()
	art.name="MeguminArtPreview"
	art.texture=load("res://"+str(profile.portraits[key]))
	# Disable the texture minimum before assigning size; otherwise it clamps to 1024x1536.
	art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.position=Vector2(820,170)
	art.size=Vector2(306.6667,460)
	app.page.add_child(art)
	var i := 0
	for id in profile.portraits:
		app.button_at(str(id),Vector2(60,160+i*28),Vector2(470,26),preview_art.bind(str(id))).name="MeguminArt_"+str(id)
		i+=1
	app.button_at("Back" if app.content.localizer.locale=="en" else "返回",Vector2(1040,88),Vector2(160,44),open_catalog.bind(app)).name="MeguminArtExit" # localization-invariant
