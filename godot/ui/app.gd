extends Control
const Loader = preload("res://godot/scripts/content_loader.gd")
const Session = preload("res://godot/systems/dialogue_session.gd")
const Backdrop = preload("res://godot/ui/backdrop.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const SaveStore = preload("res://godot/systems/save_store.gd")
const StaffView = preload("res://godot/ui/staff_view.gd")
const PreopView = preload("res://godot/ui/preop_view.gd")
const ClinicView = preload("res://godot/ui/clinic_view.gd")
const PlayerOfficeView = preload("res://godot/ui/player_office_view.gd")
const CharacterEvent = preload("res://godot/systems/character_event_session.gd")
const SpecialEvent = preload("res://godot/systems/special_event_session.gd")
const OperativeBackgrounds = preload("res://godot/systems/operative_backgrounds.gd")
const OperativeBackgroundBlur = preload("res://godot/ui/operative_background_blur.gdshader")
const CHANGE_SCRUBS_VIDEO := "res://assets/animations/preop/change_scrubs_take_gown_v1.ogv"
const SCRUB_HANDS_VIDEO := "res://assets/animations/preop/scrub_hands_v1.ogv"
const ENTER_OPERATING_ROOM_VIDEO := "res://assets/animations/preop/enter_operating_room_v1.ogv"
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
const PREOP_TRANSITION_VIDEOS := {
	"change_scrubs": {
		"path": CHANGE_SCRUBS_VIDEO,
		"speed": 2.0,
	},
	"scrub_hands": {
		"path": SCRUB_HANDS_VIDEO,
		"speed": 2.0,
	},
	"enter_room": {
		"path": ENTER_OPERATING_ROOM_VIDEO,
		"speed": 2.0,
	},
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
var location_staff_drawer_open := ""
var rooftop_actor_id := ""
var day_transition_next: Callable
var character_event_return_location := "lounge"
var character_event_return_preop_id := ""
var character_event_from_test := false
var gallery_replay_event: RefCounted
var gallery_replay_is_test := false
var gallery_replay_return_actor := ""
var gallery_return_location := ""
var special_event_pending_id := ""
var special_event_return_location := ""
var special_event_gallery_replay: RefCounted
var special_event_last_cg_path := ""
var special_event_replay_last_cg_path := ""
var examination_cg_next: Callable
var surgery_cg_next: Callable
var surgery_cg_last_path: Dictionary = {}
var ward_preparation_cg_next: Callable
var ward_preparation_cg_last_path: Dictionary = {}
var surgery_video_next: Callable
var incision_video_last_path: Dictionary = {}
var preop_transition_video_next: Callable
var staff_role_reward_next: Callable
var sunday_hospital_browsing := false
var active_save_slot := 0
var save_slot_mode := "load"
var dialogue_page_key := ""
var dialogue_page_index := 0
var dialogue_default_button: Button
var dialogue_auto_enabled := false
var dialogue_auto_speed_index := 1
var dialogue_auto_generation := 0
var dialogue_auto_toggle_button: Button
var dialogue_auto_speed_button: Button
var or_table_palpation_intensity := "standard"
var or_table_palpation_tool := "palpation"
var or_table_scalpel_cursor: Texture2D
var or_table_needle_cursor: Texture2D
var or_table_hand_cursor: Texture2D
var operative_field_hud_enabled := false

const OR_TABLE_SCALPEL_CURSOR_PATH := "res://assets/surgeries/palpation/scalpel_cursor_v1.png"
const OR_TABLE_NEEDLE_CURSOR_PATH := "res://assets/surgeries/palpation/needle_cursor_v1.png"
const OR_TABLE_HAND_CURSOR_PATH := "res://assets/surgeries/palpation/gloved_hand_cursor_v1.png"

const DIALOGUE_PAGE_COLUMNS := 44.0
const DIALOGUE_PAGE_LINES := 3
const VN_SINGLE_ACTION_Y := 480.0
const VN_CHOICE_LIST_Y := 350.0
const EVENT_TEST_HUB_EVENT_IDS := ["advanced_referral_tutorial_chisato"]

func tx(key: String, fallback: String, replacements: Dictionary = {}) -> String:
	return content.text(key, fallback, replacements)

func affection_tendency(value: int) -> String:
	if value < 10:
		return tx("ui.relationship.tendency.neutral", "态度普通")
	if value < 25:
		return tx("ui.relationship.tendency.favorable", "对你抱有好感")
	if value < 45:
		return tx("ui.relationship.tendency.caring", "明显在意你")
	return tx("ui.relationship.tendency.special", "将你视为特别的人")

func localized_weekday(date: Dictionary) -> String:
	return tx("ui.calendar.weekday." + str(date.weekday_id), str(date.weekday_name))

func localized_calendar_text(for_day: int = -1, compact: bool = false) -> String:
	var date: Dictionary = game.calendar_date(for_day)
	if compact:
		return tx("ui.calendar.compact", "%04d.%02d.%02d %s") % [date.year, date.month, date.date, localized_weekday(date)]
	return tx("ui.calendar.full", "%d年%d月%d日 · %s") % [date.year, date.month, date.date, localized_weekday(date)]

func localized_calendar_day_label(for_day: int = -1) -> String:
	var date: Dictionary = game.calendar_date(for_day)
	var holiday := str(date.holiday_name)
	if holiday.is_empty():
		return localized_weekday(date)
	return tx("ui.calendar.holiday." + str(date.iso).replace("-", "_"), holiday)

func protagonist_name() -> String:
	return str(content.protagonist.get("name", tx("ui.auto.46cf98dd2265", "坂口隆司")))

func protagonist_professional_name() -> String:
	return str(content.protagonist.get("professional_name", tx("ui.auto.1655bc45fa6a", "坂口医生")))

func configure_game_content() -> void:
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions, content.collections.palpation_profiles)
	if DisplayServer.get_name() != "headless":
		game.set_intraoperative_crisis_enabled(content.localizer.preferred_intraoperative_crisis_enabled())
		operative_field_hud_enabled = content.localizer.preferred_operative_field_hud_enabled()
		dialogue_auto_speed_index = content.localizer.preferred_dialogue_auto_speed()

func switch_locale() -> void:
	var next_locale: String = "en" if str(content.localizer.locale) == "zh_CN" else "zh_CN"
	var had_game_content: bool = not game.definitions.is_empty()
	var snapshot: Dictionary = game.snapshot() if had_game_content else {}
	var dialogue_id: String = str(session.current_id)
	if not content.load_all(next_locale):
		show_notice("\n".join(content.errors))
		return
	configure_game_content()
	if had_game_content and not game.restore(snapshot):
		show_notice(game.last_error)
		return
	if not dialogue_id.is_empty():
		session.start(content.dialogue)
		if session.nodes.has(dialogue_id):
			session.current_id = dialogue_id
	content.localizer.save_preference()
	title_screen()

func _ready() -> void:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["PingFang SC", "Noto Sans CJK SC", "Microsoft YaHei", "sans-serif"])
	var ui_theme := Theme.new()
	ui_theme.default_font = font
	ui_theme.default_font_size = 20
	theme = ui_theme
	# Headless regression tests assume the authored Chinese baseline. Locale
	# loading is exercised separately by localization_test.gd.
	var startup_locale: String = "zh_CN" if DisplayServer.get_name() == "headless" else str(content.localizer.preferred_locale())
	if not content.load_all(startup_locale):
		base(tx("ui.auto.ceae2ad42325", "内容读取失败"), tx("ui.auto.174df828a29f", "请检查 data 目录"))
		label_at("\n".join(content.errors), Vector2(70, 180), 22)
		return
	configure_game_content()
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
	invalidate_dialogue_action()
	if screen != "or_table_palpation":
		clear_or_table_scalpel_cursor()
	if is_instance_valid(page):
		remove_child(page)
		page.queue_free()
	page = Control.new()
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(page)
	var authored_background := background_path(background_id)
	var authored_texture: Texture2D = null
	if not authored_background.is_empty():
		authored_texture = load("res://" + authored_background) as Texture2D
	if authored_texture != null:
		var image := TextureRect.new()
		image.name = "SceneBackground"
		image.texture = authored_texture
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
	var lightly_shaded_screen := screen in ["dialogue", "encounter", "preop", "special_event", "special_gallery_replay"]
	var wash_alpha := 0.14 if authored_texture == null else (0.46 if background_id.begins_with("operating_team_") else 0.30 if lightly_shaded_screen else 0.83)
	wash.color = Color(0.025, 0.075, 0.09, wash_alpha)
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(wash)
	label_at(tx("ui.brand", "H O S H I M I   /   星见医院"), Vector2(54, 25), 16, Color("c9d5ca"))
	var calendar_header := label_at("%s  /  %s  %s" % [game.day_text(), localized_calendar_text(-1, true), game.clock_text()], Vector2(815, 25), 15, Color("c9d5ca"), 430)
	calendar_header.name = "CalendarHeader"
	var page_title := label_at(title, Vector2(56, 88), 34)
	page_title.name = "PageTitle"
	var page_subtitle := label_at(subtitle, Vector2(58, 139), 16, Color("b9cecb"))
	page_subtitle.name = "PageSubtitle"
	label_at(tx("ui.prototype_notice", "开发原型 0.5   /   本地美术占位 · 非医学教学"), Vector2(56, 758), 14, Color("b9cecb"))

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

func scrollable_text_at(text: String, pos: Vector2, dimensions: Vector2, font_size: int = 20, color: Color = Color("f4f0e6"), item_name: String = "ScrollableText") -> RichTextLabel:
	var item := RichTextLabel.new()
	item.name = item_name
	item.text = text
	item.position = pos
	item.size = dimensions
	item.bbcode_enabled = false
	item.fit_content = false
	item.scroll_active = true
	item.scroll_following = false
	item.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	item.add_theme_font_size_override("normal_font_size", font_size)
	item.add_theme_color_override("default_color", color)
	item.add_theme_color_override("font_outline_color", Color(0.015, 0.04, 0.05, 0.94))
	item.add_theme_constant_override("outline_size", 4)
	page.add_child(item)
	return item

func emphasized_font(strength: float = 0.7) -> FontVariation:
	var font := FontVariation.new()
	font.base_font = theme.default_font
	font.variation_embolden = strength
	return font

func dialogue_visual_units(text: String) -> float:
	var units := 0.0
	for character in text:
		var codepoint := character.unicode_at(0)
		units += 0.55 if codepoint < 128 else 1.0
	return units

func dialogue_estimated_lines(text: String) -> int:
	return maxi(1, ceili(dialogue_visual_units(text) / DIALOGUE_PAGE_COLUMNS))

func dialogue_sentence_chunks(text: String) -> Array[String]:
	var chunks: Array[String] = []
	var current := ""
	for character in text:
		current += character
		if character in ["。", "！", "？", "；", "!", "?", ";"]:
			chunks.append(current.strip_edges())
			current = ""
	if not current.strip_edges().is_empty():
		chunks.append(current.strip_edges())
	return chunks

func dialogue_beat_chunks(text: String) -> Array[String]:
	var chunks: Array[String] = []
	var current := ""
	var closing_quote := ""
	var quote_pairs := {"「": "」", "『": "』", "“": "”"}
	for character in text:
		if closing_quote.is_empty() and quote_pairs.has(character):
			var prefix := current.strip_edges()
			var keep_player_prefix := (prefix.begins_with("坂口") or prefix.begins_with("Sakaguchi")) and (prefix.ends_with("：") or prefix.ends_with(":")) # localization-invariant: authored speaker syntax
			if not prefix.is_empty() and not keep_player_prefix:
				chunks.append(current.strip_edges())
				current = ""
			current += character
			closing_quote = str(quote_pairs[character])
			continue
		current += character
		if not closing_quote.is_empty() and character == closing_quote:
			chunks.append(current.strip_edges())
			current = ""
			closing_quote = ""
	if not current.strip_edges().is_empty():
		chunks.append(current.strip_edges())
	return chunks

func dialogue_hard_wrap(text: String) -> Array[String]:
	var chunks: Array[String] = []
	var current := ""
	var current_units := 0.0
	var maximum_units := DIALOGUE_PAGE_COLUMNS * DIALOGUE_PAGE_LINES
	for character in text:
		var units := 0.55 if character.unicode_at(0) < 128 else 1.0
		if current_units + units > maximum_units and not current.is_empty():
			chunks.append(current.strip_edges())
			current = ""
			current_units = 0.0
		current += character
		current_units += units
	if not current.strip_edges().is_empty():
		chunks.append(current.strip_edges())
	return chunks

func dialogue_pages(text: String, allow_scroll: bool = false) -> Array[String]:
	if allow_scroll:
		return [text]
	var pages: Array[String] = []
	# Explicit line breaks are authored beats. Treating each non-empty line as a
	# click point also prevents action narration and the following line of speech
	# from being presented under one speaker label.
	var authored_lines: Array[String] = []
	for raw_line in text.replace("\r", "").split("\n"):
		var authored_line := str(raw_line).strip_edges()
		if not authored_line.is_empty():
			authored_lines.append(authored_line)
	var line_index := 0
	while line_index < authored_lines.size():
		var authored_line := authored_lines[line_index]
		var player_lead_in := (authored_line.begins_with("坂口") or authored_line.begins_with("Sakaguchi")) and (authored_line.ends_with("：") or authored_line.ends_with(":")) # localization-invariant: authored speaker syntax
		if player_lead_in and line_index + 1 < authored_lines.size():
			var following_line := authored_lines[line_index + 1]
			if following_line.begins_with("「") or following_line.begins_with("『") or following_line.begins_with("“") or following_line.begins_with("\""):
				authored_line += following_line
				line_index += 1
		for beat in dialogue_beat_chunks(authored_line):
			var line := str(beat).strip_edges()
			if line.is_empty():
				continue
			if dialogue_estimated_lines(line) <= DIALOGUE_PAGE_LINES:
				pages.append(line)
				continue
			var current := ""
			for sentence in dialogue_sentence_chunks(line):
				if dialogue_estimated_lines(sentence) > DIALOGUE_PAGE_LINES:
					if not current.is_empty():
						pages.append(current)
						current = ""
					pages.append_array(dialogue_hard_wrap(sentence))
				elif current.is_empty():
					current = sentence
				elif dialogue_estimated_lines(current + sentence) <= DIALOGUE_PAGE_LINES:
					current += sentence
				else:
					pages.append(current)
					current = sentence
			if not current.is_empty():
				pages.append(current)
		line_index += 1
	if pages.is_empty():
		pages.append(text)
	return pages

func dialogue_page(key: String, text: String, allow_scroll: bool = false) -> Dictionary:
	if dialogue_page_key != key:
		dialogue_page_key = key
		dialogue_page_index = 0
	var pages := dialogue_pages(text, allow_scroll)
	dialogue_page_index = clampi(dialogue_page_index, 0, pages.size() - 1)
	return {
		"text": pages[dialogue_page_index],
		"has_more": dialogue_page_index + 1 < pages.size(),
		"allow_scroll": allow_scroll,
	}

func vn_choice_y(choice_count: int, index: int) -> float:
	var start_y := VN_SINGLE_ACTION_Y if choice_count == 1 else VN_CHOICE_LIST_Y
	return start_y + index * 66.0

func vn_choice_label(label: String, choice_count: int) -> String:
	var common_continue := tx("ui.common.continue", "继续  ▷")
	var bare_label := label.replace("▷", "").replace("→", "").strip_edges()
	var bare_continue := common_continue.replace("▷", "").replace("→", "").strip_edges()
	if choice_count == 1 and bare_label == bare_continue:
		return common_continue
	return label

func dialogue_page_presentation(default_speaker: String, source_role: String, page_text: String, actor_speaker: String = "") -> Dictionary:
	var shown_text := page_text.strip_edges()
	var colon_index := shown_text.find("：")
	if colon_index < 0:
		colon_index = shown_text.find(":")
	if colon_index > 0 and colon_index <= 12:
		var written_speaker := shown_text.left(colon_index).strip_edges()
		var after_prefix := shown_text.substr(colon_index + 1).strip_edges()
		if not after_prefix.is_empty() and (written_speaker.contains("坂口") or written_speaker.begins_with("Sakaguchi") or written_speaker == protagonist_name()): # localization-invariant: authored speaker syntax
			return {"speaker": protagonist_name(), "text": after_prefix}
		if not after_prefix.is_empty() and not actor_speaker.is_empty() and (actor_speaker.ends_with(written_speaker) or written_speaker.ends_with(actor_speaker)):
			return {"speaker": actor_speaker, "text": after_prefix}
	for player_prefix in ["坂口：", "坂口:", protagonist_name() + "：", protagonist_name() + ":", "Sakaguchi:"]: # localization-invariant: authored speaker syntax
		if shown_text.begins_with(player_prefix):
			return {
				"speaker": protagonist_name(),
				"text": shown_text.trim_prefix(player_prefix).strip_edges(),
			}
	if source_role == "player":
		return {"speaker": protagonist_name(), "text": shown_text}
	var begins_with_quote := shown_text.begins_with("「") or shown_text.begins_with("『") or shown_text.begins_with("“") or shown_text.begins_with("\"")
	if source_role == "actor" and begins_with_quote:
		return {"speaker": default_speaker, "text": shown_text}
	if source_role == "narrator" and begins_with_quote:
		# Some authored event beats retain narrator routing while an explicit
		# `speaker_label` identifies the character speaking on quoted pages. Honor
		# that label even when the character has no staff `actor_id`.
		if not actor_speaker.is_empty():
			return {"speaker": actor_speaker, "text": shown_text}
		if default_speaker != tx("ui.auto.ed1d855fc574", "旁白"):
			return {"speaker": default_speaker, "text": shown_text}
	if source_role == "narrator":
		return {"speaker": tx("ui.auto.ed1d855fc574", "旁白"), "text": shown_text}
	return {"speaker": tx("ui.auto.ed1d855fc574", "旁白"), "text": shown_text}

func advance_dialogue_page(refresh: Callable) -> void:
	dialogue_page_index += 1
	refresh.call()

func reset_dialogue_page() -> void:
	dialogue_page_key = ""
	dialogue_page_index = 0

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

func invalidate_dialogue_action() -> void:
	dialogue_auto_generation += 1
	dialogue_default_button = null
	dialogue_auto_toggle_button = null
	dialogue_auto_speed_button = null

func dialogue_speed_name() -> String:
	var names: Array[String] = [
		tx("ui.dialogue.speed.slow", "慢速"),
		tx("ui.dialogue.speed.normal", "标准"),
		tx("ui.dialogue.speed.fast", "快速"),
		tx("ui.dialogue.speed.very_fast", "极速"),
	]
	return names[clampi(dialogue_auto_speed_index, 0, 3)]

func dialogue_auto_delay(text: String, extra_delay: float = 0.0) -> float:
	var speed_characters: Array[float] = [8.0, 14.0, 24.0, 40.0]
	var base_delays: Array[float] = [1.45, 0.95, 0.52, 0.25]
	var maximum_delays: Array[float] = [12.0, 8.0, 5.0, 3.2]
	var speed_index := clampi(dialogue_auto_speed_index, 0, 3)
	var punctuation_delay := 0.0
	for character in text:
		if character in ["。", "！", "？", "!", "?", "…"]:
			punctuation_delay += 0.16
		elif character in ["，", "、", "；", ",", ";"]:
			punctuation_delay += 0.07
	var reading_time := dialogue_visual_units(text) / speed_characters[speed_index]
	var delay := base_delays[speed_index] + reading_time + punctuation_delay + extra_delay
	if text.strip_edges().begins_with("【"):
		delay += 0.8
	return clampf(delay, 0.45, maximum_delays[speed_index] + extra_delay)

func register_dialogue_continue(button: Button, text: String, extra_delay: float = 0.0) -> void:
	dialogue_default_button = button
	dialogue_auto_generation += 1
	var expected_generation := dialogue_auto_generation
	if get_viewport().gui_get_focus_owner() == null:
		button.grab_focus()
	if dialogue_auto_enabled:
		run_dialogue_auto_timer(expected_generation, dialogue_auto_delay(text, extra_delay))

func pause_dialogue_for_choice() -> void:
	dialogue_default_button = null
	dialogue_auto_generation += 1

func run_dialogue_auto_timer(expected_generation: int, delay_seconds: float) -> void:
	await get_tree().create_timer(delay_seconds).timeout
	while dialogue_auto_enabled and expected_generation == dialogue_auto_generation:
		if dialogue_button_can_activate(dialogue_default_button) and activate_dialogue_default():
			return
		await get_tree().create_timer(0.2).timeout

func dialogue_button_can_activate(button: Button) -> bool:
	return is_instance_valid(button) and not button.disabled and button.is_visible_in_tree()

func dialogue_text_input_focused() -> bool:
	var focus_owner := get_viewport().gui_get_focus_owner()
	return focus_owner is LineEdit or focus_owner is TextEdit

func dialogue_modal_open() -> bool:
	for child in get_children():
		if child is Window and child.visible:
			return true
	return false

func activate_dialogue_default() -> bool:
	if dialogue_text_input_focused() or dialogue_modal_open() or not dialogue_button_can_activate(dialogue_default_button):
		return false
	var button := dialogue_default_button
	# Invalidate before emitting: the action normally redraws the page and may
	# register the next line immediately.
	dialogue_auto_generation += 1
	button.emit_signal("pressed")
	return true

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode not in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
		return
	if activate_dialogue_default():
		get_viewport().set_input_as_handled()

func dialogue_auto_toggle_text() -> String:
	return tx("ui.dialogue.auto_on", "自动播放：开") if dialogue_auto_enabled else tx("ui.dialogue.auto_off", "自动播放：关")

func refresh_dialogue_playback_controls() -> void:
	if is_instance_valid(dialogue_auto_toggle_button):
		dialogue_auto_toggle_button.text = dialogue_auto_toggle_text()
	if is_instance_valid(dialogue_auto_speed_button):
		dialogue_auto_speed_button.text = tx("ui.dialogue.speed", "速度：{speed}", {"speed": dialogue_speed_name()})

func toggle_dialogue_auto() -> void:
	dialogue_auto_enabled = not dialogue_auto_enabled
	dialogue_auto_generation += 1
	refresh_dialogue_playback_controls()
	if dialogue_auto_enabled and dialogue_button_can_activate(dialogue_default_button):
		run_dialogue_auto_timer(dialogue_auto_generation, dialogue_auto_delay(current_dialogue_text(), 0.25))

func cycle_dialogue_auto_speed() -> void:
	dialogue_auto_speed_index = (dialogue_auto_speed_index + 1) % 4
	content.localizer.save_dialogue_auto_speed(dialogue_auto_speed_index)
	dialogue_auto_generation += 1
	refresh_dialogue_playback_controls()
	if dialogue_auto_enabled and dialogue_button_can_activate(dialogue_default_button):
		run_dialogue_auto_timer(dialogue_auto_generation, dialogue_auto_delay(current_dialogue_text()))

func current_dialogue_text() -> String:
	for child in page.get_children():
		if child is RichTextLabel and (child.name.contains("Dialogue") or child.name == "PrologueText"):
			return child.text
	return ""

func add_dialogue_playback_controls() -> void:
	dialogue_auto_toggle_button = button_at(dialogue_auto_toggle_text(), Vector2(590, 713), Vector2(155, 40), toggle_dialogue_auto)
	dialogue_auto_toggle_button.name = "DialogueAutoToggle"
	dialogue_auto_speed_button = button_at(tx("ui.dialogue.speed", "速度：{speed}", {"speed": dialogue_speed_name()}), Vector2(755, 713), Vector2(220, 40), cycle_dialogue_auto_speed)
	dialogue_auto_speed_button.name = "DialogueAutoSpeed"

func vn_dialogue_box(speaker: String, text: String, dialogue_name: String = "EventDialogue", allow_scroll: bool = false) -> Array:
	var box := Panel.new()
	box.name = dialogue_name + "Box"
	box.position = Vector2(55, 540)
	box.size = Vector2(1170, 160)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_stylebox_override("panel", panel_style(Color(0.06, 0.15, 0.20, 0.96), Color("819593")))
	page.add_child(box)
	var speaker_label := label_at(speaker, Vector2(82, 558), 22, Color("e8cfaa"), 1100)
	var dialogue_text := scrollable_text_at(text, Vector2(82, 598), Vector2(1100, 91), 22, Color("f4f0e6"), dialogue_name)
	dialogue_text.scroll_active = allow_scroll
	return [box, speaker_label, dialogue_text]

func title_screen() -> void:
	screen = "title"
	base("", "", false, "lobby")
	label_at(tx("ui.title.chapter", "春日序章"), Vector2(80, 222), 68)
	label_at(tx("ui.title.subtitle", "星见医院的第一天"), Vector2(85, 325), 27, Color("d8d8c7"))
	label_at(tx("ui.title.description", "在病历与日常之间，认识并肩工作的人。"), Vector2(85, 385), 19, Color("b9cecb"))
	button_at(tx("ui.title.start", "开始游戏    →"), Vector2(85, 480), Vector2(330, 60), request_new_game).grab_focus()
	var resume_button := button_at(tx("ui.title.continue", "继续游戏 · 选择存档"), Vector2(85, 554), Vector2(330, 60), show_save_slots.bind("load", true))
	resume_button.disabled = not saves.any_exists()
	if OS.is_debug_build() and not game.special_event_definitions.is_empty():
		var save_builder_button := button_at(tx("ui.test_save.entry", "DEBUG：测试存档生成器"), Vector2(440, 480), Vector2(330, 60), show_test_save_generator)
		save_builder_button.name = "TestSaveGeneratorEntry"
		var event_test_button := button_at(tx("ui.event_test.entry", "DEBUG：事件测试中心"), Vector2(440, 554), Vector2(330, 60), show_event_test_hub)
		event_test_button.name = "EventTestHubEntry"
	button_at(tx("ui.title.directory", "医院导览"), Vector2(85, 628), Vector2(330, 60), show_map)
	button_at(tx("ui.title.language", "语言 / Language：简体中文"), Vector2(440, 628), Vector2(330, 60), switch_locale)
	label_at("HOSPITAL VISUAL NOVEL", Vector2(805, 536), 17, Color("cbbc9c"), 380)
	label_at(tx("ui.title.steps", "01 / 入职\n02 / 相识\n03 / 新的日常"), Vector2(805, 575), 25, Color("dae1d9"), 380)

func request_new_game() -> void:
	if not game.visits.is_empty():
		confirm_action(tx("ui.title.new_game_warning", "重新开始会清空当前未保存进度。已有存档会保留，直到你再次保存。"), start_story)
	else:
		start_story()

func begin_advanced_referral_tutorial_debug_from_title() -> void:
	begin_special_event_test_from_title("advanced_referral_tutorial_chisato")

func show_event_test_hub() -> void:
	screen = "event_test_hub"
	base(tx("ui.event_test.title", "事件测试中心"), tx("ui.event_test.subtitle", "每次从干净状态启动；不写入或覆盖正式存档"), false, "player_office")
	var definitions: Array = []
	for event_id in EVENT_TEST_HUB_EVENT_IDS:
		if game.special_event_definitions.has(event_id):
			definitions.append(game.special_event_definitions[event_id])
	definitions.sort_custom(func(a: Dictionary, b: Dictionary):
		var a_developer := bool(a.get("developer_only", false))
		var b_developer := bool(b.get("developer_only", false))
		if a_developer != b_developer:
			return not a_developer
		return str(a.get("title", a.get("id", ""))) < str(b.get("title", b.get("id", "")))
	)
	var event_scroll := ScrollContainer.new()
	event_scroll.name = "EventTestScroll"
	event_scroll.position = Vector2(45, 165)
	event_scroll.size = Vector2(1190, 500)
	event_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(event_scroll)
	var event_content := Control.new()
	event_content.name = "EventTestList"
	event_content.custom_minimum_size = Vector2(1170, max(500, definitions.size() * 86 + 20))
	event_scroll.add_child(event_content)
	for i in range(definitions.size()):
		var definition: Dictionary = definitions[i]
		var event_id := str(definition.get("id", ""))
		var category := str(definition.get("category", "special_event"))
		var duration_days := int(definition.get("duration_days", 1))
		var developer_tag := tx("ui.event_test.framework_tag", "　·　框架测试") if bool(definition.get("developer_only", false)) else ""
		var caption := tx("ui.event_test.caption", "%s\n%s · %s 天%s") % [str(definition.get("title", event_id)), category, duration_days, developer_tag]
		var event_button := button_at(caption, Vector2.ZERO, Vector2(1110, 68), begin_special_event_test_from_title.bind(event_id))
		page.remove_child(event_button)
		event_content.add_child(event_button)
		event_button.position = Vector2(20, 10 + i * 86)
		event_button.name = "EventTest_" + event_id
	button_at(tx("ui.event_test.back", "← 返回标题"), Vector2(1030, 88), Vector2(185, 44), title_screen)

func begin_special_event_test_from_title(event_id: String) -> void:
	active_save_slot = 0
	game.reset()
	reset_clinic_view()
	reset_dialogue_page()
	if game.start_special_event_for_testing(event_id) == null:
		show_notice(game.last_error)
		return
	show_special_event()

func show_test_save_generator() -> void:
	screen = "test_save_generator"
	base(tx("ui.test_save.title", "测试存档生成器"), tx("ui.test_save.subtitle", "仅写入空槽位；生成正式格式存档，可直接读取继续测试"), false, "player_office")
	label_at(tx("ui.test_save.slot", "空存档位"), Vector2(60, 180), 18, Color("e8cfaa"), 150)
	var slot_picker := OptionButton.new()
	slot_picker.name = "TestSaveSlotPicker"
	slot_picker.position = Vector2(220, 172)
	slot_picker.size = Vector2(170, 42)
	for slot in range(1, SaveStore.SLOT_COUNT + 1):
		if not saves.exists(slot):
			slot_picker.add_item(tx("ui.save.slot", "位置 %02d") % slot)
			slot_picker.set_item_metadata(slot_picker.item_count - 1, slot)
	page.add_child(slot_picker)
	label_at(tx("ui.test_save.event", "事件预设"), Vector2(60, 232), 18, Color("e8cfaa"), 150)
	var event_picker := OptionButton.new()
	event_picker.name = "TestSaveEventPicker"
	event_picker.position = Vector2(220, 224)
	event_picker.size = Vector2(760, 42)
	event_picker.add_item(tx("ui.test_save.custom", "自定义（不套用事件门槛）"))
	event_picker.set_item_metadata(0, {"type": "custom", "id": ""})
	var definitions: Array = game.special_event_definitions.values()
	definitions.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.get("title", a.get("id", ""))) < str(b.get("title", b.get("id", ""))))
	for definition in definitions:
		var event_id := str(definition.get("id", ""))
		event_picker.add_item("[%s] %s  [%s]" % [tx("ui.test_save.special_tag", "特殊"), str(definition.get("title", event_id)), event_id])
		event_picker.set_item_metadata(event_picker.item_count - 1, {"type": "special", "id": event_id})
	var character_definitions: Array = game.character_event_definitions.values()
	character_definitions.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.get("title", a.get("id", ""))) < str(b.get("title", b.get("id", ""))))
	for definition in character_definitions:
		var event_id := str(definition.get("id", ""))
		event_picker.add_item("[%s] %s  [%s]" % [tx("ui.test_save.character_tag", "人物"), str(definition.get("title", event_id)), event_id])
		event_picker.set_item_metadata(event_picker.item_count - 1, {"type": "character", "id": event_id})
	page.add_child(event_picker)
	label_at(tx("ui.test_save.trigger", "触发方式"), Vector2(60, 284), 18, Color("e8cfaa"), 150)
	var trigger_picker := OptionButton.new()
	trigger_picker.name = "TestSaveTriggerPicker"
	trigger_picker.position = Vector2(220, 276)
	trigger_picker.size = Vector2(350, 42)
	trigger_picker.add_item(tx("ui.test_save.ready_now", "读取后立即满足门槛"))
	trigger_picker.set_item_metadata(0, "ready")
	trigger_picker.add_item(tx("ui.test_save.after_surgery", "完成下一场手术后触发"))
	trigger_picker.set_item_metadata(1, "after_surgery")
	page.add_child(trigger_picker)
	label_at(tx("ui.test_save.time", "时间覆盖"), Vector2(600, 284), 18, Color("e8cfaa"), 110)
	var day_field := LineEdit.new()
	day_field.name = "TestSaveDay"
	day_field.placeholder_text = tx("ui.test_save.day_auto", "天数（自动）")
	day_field.position = Vector2(715, 276)
	day_field.size = Vector2(145, 42)
	page.add_child(day_field)
	var clock_field := LineEdit.new()
	clock_field.name = "TestSaveClock"
	clock_field.placeholder_text = tx("ui.test_save.clock_auto", "时间 HH:MM")
	clock_field.position = Vector2(875, 276)
	clock_field.size = Vector2(145, 42)
	page.add_child(clock_field)
	label_at(tx("ui.test_save.overrides", "高级覆盖（JSON；留空或 {} 表示不覆盖）"), Vector2(60, 340), 18, Color("e8cfaa"), 700)
	var editor := TextEdit.new()
	editor.name = "TestSaveOverrides"
	editor.position = Vector2(60, 375)
	editor.size = Vector2(1160, 225)
	editor.text = "{\n  \"player_attributes\": {},\n  \"relationships\": {},\n  \"story_flags\": {},\n  \"progress\": {},\n  \"special_events\": {}\n}"
	editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	page.add_child(editor)
	var help := label_at(tx("ui.test_save.help", "人物示例：\"nurse_satsuki\": {\"met\": true, \"level\": 2, \"affection\": 45, \"familiarity\": 45}　·　主角属性：skill / leadership / charm / reputation / presence"), Vector2(60, 610), 14, Color("b9cecb"), 1160)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var generate := button_at(tx("ui.test_save.generate", "生成到所选空槽位"), Vector2(60, 672), Vector2(300, 48), generate_test_save.bind(slot_picker, event_picker, trigger_picker, day_field, clock_field, editor))
	generate.name = "GenerateTestSave"
	generate.disabled = slot_picker.item_count == 0
	if slot_picker.item_count == 0:
		label_at(tx("ui.test_save.no_empty_slot", "没有空槽位；请先在存档目录中腾出一个位置。"), Vector2(390, 684), 16, Color("e59a92"), 600)
	button_at(tx("ui.event_test.back", "← 返回标题"), Vector2(1030, 88), Vector2(185, 44), title_screen)

func parse_test_save_clock(value: String, fallback: int) -> int:
	if value.strip_edges().is_empty():
		return fallback
	var parts := value.strip_edges().split(":")
	if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
		return -1
	var hour := int(parts[0])
	var minute := int(parts[1])
	if hour < 0 or hour > 23 or minute < 0 or minute > 59:
		return -1
	return hour * 60 + minute

func generate_test_save(slot_picker: OptionButton, event_picker: OptionButton, trigger_picker: OptionButton, day_field: LineEdit, clock_field: LineEdit, editor: TextEdit) -> void:
	if slot_picker.item_count == 0:
		show_notice(tx("ui.test_save.no_empty_slot", "没有空槽位；请先在存档目录中腾出一个位置。"))
		return
	var slot := int(slot_picker.get_item_metadata(slot_picker.selected))
	if saves.exists(slot):
		show_notice(tx("ui.test_save.slot_became_occupied", "所选位置已经有存档；生成器不会覆盖它，请重新选择空槽位。"))
		show_test_save_generator()
		return
	var preset: Dictionary = event_picker.get_item_metadata(event_picker.selected)
	var event_id := str(preset.get("id", ""))
	var event_type := str(preset.get("type", "custom"))
	var wait_for_surgery := str(trigger_picker.get_item_metadata(trigger_picker.selected)) == "after_surgery"
	if event_id.is_empty():
		game.reset()
	elif event_type == "special" and not game.prepare_special_event_test_save(event_id, wait_for_surgery):
		show_notice(game.last_error)
		return
	elif event_type == "character" and not game.prepare_character_event_test_save(event_id, wait_for_surgery):
		show_notice(game.last_error)
		return
	var current_clock := int(game.schedule_at(game.elapsed()).absolute_clock)
	var selected_clock := parse_test_save_clock(clock_field.text, current_clock)
	if selected_clock < 0:
		show_notice(tx("ui.test_save.invalid_clock", "时间格式应为 HH:MM。"))
		return
	var selected_day := game.day_number()
	if not day_field.text.strip_edges().is_empty():
		if not day_field.text.strip_edges().is_valid_int():
			show_notice(tx("ui.test_save.invalid_day", "天数必须是 1–365 的整数。"))
			return
		selected_day = int(day_field.text)
		if selected_day < 1 or selected_day > 365:
			show_notice(tx("ui.test_save.invalid_day", "天数必须是 1–365 的整数。"))
			return
	game.set_test_time(selected_day, selected_clock)
	var raw_overrides := editor.text.strip_edges()
	if not raw_overrides.is_empty():
		var parser := JSON.new()
		if parser.parse(raw_overrides) != OK or not parser.data is Dictionary:
			show_notice(tx("ui.test_save.invalid_json", "高级覆盖不是有效的 JSON 对象：第 %d 行 %s") % [parser.get_error_line(), parser.get_error_message()])
			return
		if not game.apply_test_save_overrides(parser.data):
			show_notice(game.last_error)
			return
	if wait_for_surgery and not event_id.is_empty():
		game.arm_test_save_one_surgery(event_id)
	var generated_snapshot := game.snapshot()
	if not game.restore(generated_snapshot):
		show_notice(tx("ui.test_save.invalid_state", "生成结果无法通过正式存档校验：%s") % game.last_error)
		return
	if not saves.write_slot(game, slot):
		show_notice(saves.last_error)
		return
	active_save_slot = slot
	show_save_slots("load", true)
	show_notice(tx("ui.test_save.success", "测试存档已生成到位置 %d，可立即读取。") % slot)

func start_story() -> void:
	active_save_slot = 0
	game.reset()
	reset_clinic_view()
	reset_dialogue_page()
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
	var dialogue := dialogue_page("prologue:%s" % str(node.get("id", "")), str(node.get("text", tx("ui.auto.f0d04021de6f", "对话节点缺失"))), bool(node.get("allow_dialogue_scroll", false)))
	var person: Dictionary = content.find_record("staff", node.get("speaker", ""))
	if not person.is_empty():
		game.meet_staff(str(person.id))
	base(tx("ui.prologue.title", "初到星见"), tx("ui.prologue.chapter", "PROLOGUE   /   01"), not person.is_empty(), node.background_id)
	if not person.is_empty():
		add_portrait(person, node.get("expression", "neutral"))
	var box := Panel.new()
	box.name = "PrologueDialogueBox"
	box.position = Vector2(55, 490)
	box.size = Vector2(1170, 240)
	box.add_theme_stylebox_override("panel", panel_style(Color(0.06, 0.15, 0.20, 0.96), Color("c6b999")))
	page.add_child(box)
	label_at(person.get("name", tx("ui.common.narrator", "旁白")), Vector2(82, 510), 22, Color("e8cfaa"))
	# Chinese prose has no spaces between words. WORD_SMART can treat a long
	# sentence as one unbreakable run, so force character-level wrapping and
	# keep a generous inset from the dialogue frame.
	var prologue_text := scrollable_text_at(str(dialogue.text), Vector2(82, 553), Vector2(1100, 110), 21, Color("f4f0e6"), "PrologueText")
	prologue_text.scroll_active = bool(dialogue.allow_scroll)
	if bool(dialogue.has_more):
		var continue_button := button_at(tx("ui.common.continue", "继续  ▷"), Vector2(1040, 676), Vector2(160, 46), advance_dialogue_page.bind(show_dialogue))
		continue_button.name = "PrologueDialogueContinue"
		register_dialogue_continue(continue_button, str(dialogue.text))
	elif node.has("choices"):
		pause_dialogue_for_choice()
		for i in range(node.choices.size()):
			button_at(node.choices[i].label, Vector2(75 + i * 365, 676), Vector2(345, 46), advance.bind(i))
	else:
		var continue_button := button_at(tx("ui.common.continue", "继续  ▷"), Vector2(1040, 676), Vector2(160, 46), advance.bind(-1))
		continue_button.name = "PrologueDialogueContinue"
		register_dialogue_continue(continue_button, str(dialogue.text), 0.5)
	add_dialogue_playback_controls()
	button_at(tx("ui.common.return_title", "返回标题"), Vector2(1070, 88), Vector2(150, 44), title_screen)

func advance(choice: int) -> void:
	var destination := session.advance(choice)
	if destination == "@map":
		show_map()
	elif destination.begins_with("@location:"):
		show_location(destination.trim_prefix("@location:"))
	else:
		show_dialogue()

func show_map() -> void:
	if game.active_surgery_committed():
		show_notice(tx("ui.notice.surgery_committed", "手术团队已经确认，患者正在进入连续的术前与手术流程；必须完成本次手术后才能离开。"))
		return
	if not game.active_special_event_id.is_empty():
		show_special_event()
		return
	var auto_special_event := game.next_auto_special_event()
	if not auto_special_event.is_empty():
		confirm_special_event(str(auto_special_event.id))
		return
	var day_start_character_event := game.next_day_start_character_event()
	if not day_start_character_event.is_empty():
		start_mandatory_character_event(str(day_start_character_event.id))
		return
	if not game.is_sunday():
		sunday_hospital_browsing = false
	elif not game.sunday_activity_done() and not sunday_hospital_browsing:
		show_sunday_menu()
		return
	screen = "map"
	location_feedback = ""
	location_feedback_location = ""
	base(tx("ui.map.sunday_title", "周日医院") if sunday_hospital_browsing else tx("ui.map.title", "医院导览"), tx("ui.map.sunday_subtitle", "普通门诊与择期手术休止；可以探视、串门或找值班同事聊聊。") if sunday_hospital_browsing else tx("ui.map.subtitle", "选择地点，了解今天的医院。  /  HOSPITAL DIRECTORY"), false, "lobby")
	var map_locations: Array = content.collections.locations
	if sunday_hospital_browsing:
		var sunday_ids := ["ward", "station", "imaging", "or", "lounge", "rooftop", "player_office"]
		map_locations = content.collections.locations.filter(func(location: Dictionary): return str(location.id) in sunday_ids)
	for i in range(map_locations.size()):
		var location: Dictionary = map_locations[i]
		var pos := Vector2(40 + (i % 4) * 305, 155 + (i / 4) * 130)
		var location_button := button_at("%02d   %s
		   %s" % [i + 1, location.name, location.subtitle], pos, Vector2(285, 110), show_location.bind(location.id))
		location_button.name = "Location_" + str(location.id)
	var profile_button := button_at(tx("ui.common.doctor_profile", "医生属性"), Vector2(865, 88), Vector2(190, 44), show_player_profile)
	profile_button.name = "PlayerProfileButton"
	button_at(tx("ui.common.return_sunday", "返回周日安排") if sunday_hospital_browsing else tx("ui.common.return_title", "返回标题"), Vector2(1045 if sunday_hospital_browsing else 1070, 88), Vector2(175 if sunday_hospital_browsing else 150, 44), show_sunday_menu if sunday_hospital_browsing else title_screen)
	button_at(tx("ui.common.save_progress", "保存进度"), Vector2(40, 700), Vector2(145, 43), save_progress)
	button_at(tx("ui.common.load_game", "读取存档"), Vector2(195, 700), Vector2(145, 43), request_load)
	button_at(tx("ui.common.time_log", "时间记录"), Vector2(350, 700), Vector2(145, 43), show_time_log)
	var special_events_button := button_at(tx("ui.common.special_events", "特殊活动"), Vector2(505, 700), Vector2(145, 43), show_special_events)
	special_events_button.name = "SpecialEventsButton"
	button_at(tx("ui.common.event_gallery", "事件鉴赏"), Vector2(660, 700), Vector2(145, 43), show_event_gallery)
	if sunday_hospital_browsing:
		button_at(tx("ui.sunday.end", "结束星期日  →"), Vector2(827, 700), Vector2(389, 43), finish_sunday_activity.bind("hospital_visit", tx("ui.sunday.hospital_result", "坂口在安静的医院里转了一圈。值班人员各自守着岗位，手术室没有安排择期手术。"))).name = "SundayHospitalEnd"
	if not game.active_id.is_empty() and not sunday_hospital_browsing:
		button_at(tx("ui.map.resume_case", "继续当前病例  →"), Vector2(827, 700), Vector2(389, 43), resume_progress)

func show_sunday_menu() -> void:
	sunday_hospital_browsing = false
	screen = "sunday_menu"
	base(tx("ui.sunday.title", "星期日"), "%s / %s" % [localized_calendar_text(), tx("ui.sunday.subtitle", "医院的节奏慢了下来")], false, "player_office")
	label_at(tx("ui.sunday.no_clinic", "今天没有安排普通门诊和择期手术。"), Vector2(85, 205), 27, Color("f4f0e6"), 1060)
	label_at(tx("ui.sunday.question", "今天要怎么过？"), Vector2(85, 260), 22, Color("e8cfaa"), 700)
	var invite_button := button_at(tx("ui.sunday.invite", "邀请某人外出"), Vector2(85, 330), Vector2(500, 62), show_sunday_invites)
	invite_button.name = "SundayInvite"
	button_at(tx("ui.sunday.visit_hospital", "去医院看看"), Vector2(635, 330), Vector2(500, 62), show_sunday_hospital_map).name = "SundayHospital"
	button_at(tx("ui.sunday.visit_office", "在自己办公室待一会儿"), Vector2(85, 420), Vector2(500, 62), show_sunday_office_menu).name = "SundayOffice"
	button_at(tx("ui.sunday.rest_home", "在家休息"), Vector2(635, 420), Vector2(500, 62), finish_sunday_activity.bind("rest_home", tx("ui.sunday.rest_result", "坂口难得睡到自然醒。窗外的光线移动得很慢，医院也没有打来电话。"))).name = "SundayRest"
	label_at(tx("ui.sunday.note", "周日活动不会增加手术经验。去医院仍可自由串门和社交。"), Vector2(85, 555), 19, Color("c2d2cc"), 1000)
	button_at(tx("ui.common.save_progress", "保存进度"), Vector2(85, 650), Vector2(170, 45), save_progress)
	button_at(tx("ui.common.load_game", "读取存档"), Vector2(275, 650), Vector2(170, 45), request_load)

func show_sunday_hospital_map() -> void:
	sunday_hospital_browsing = true
	show_map()

func show_sunday_invites() -> void:
	screen = "sunday_invites"
	base(tx("ui.sunday.invite_title", "邀请某人外出"), tx("ui.sunday.invite_subtitle", "本周可联系的人选已经确定；读取存档不会改变名单或邀请结果。"), false, "lobby")
	var candidates: Array[String] = game.sunday_date_candidates()
	if candidates.is_empty():
		label_at(tx("ui.sunday.no_invites", "今天没有可邀请的对象。"), Vector2(85, 230), 28, Color("f4f0e6"), 720)
		label_at(tx("ui.sunday.no_invites_note", "角色常服与基础约会对白完成后，她们会逐步加入这里。"), Vector2(85, 290), 20, Color("c2d2cc"), 800)
	else:
		for i in range(candidates.size()):
			var actor_id: String = candidates[i]
			var person: Dictionary = content.find_record("staff", actor_id)
			var relation: Dictionary = game.relation_for(actor_id)
			var caption := tx("ui.sunday.candidate", "%s　Lv%s　熟悉 %s") % [person.name, relation.level, relation.familiarity]
			var invite := button_at(caption, Vector2(75, 215 + i * 82), Vector2(670, 62), attempt_sunday_invitation.bind(actor_id))
			invite.name = "SundayCandidate_" + actor_id
	label_at(tx("ui.sunday.decline_note", "邀请被婉拒不会扣除关系数值，也不会消耗这一天。"), Vector2(75, 570), 18, Color("e8cfaa"), 920)
	button_at(tx("ui.common.return_sunday_arrow", "← 返回周日安排"), Vector2(60, 713), Vector2(230, 40), show_sunday_menu)

func attempt_sunday_invitation(actor_id: String) -> void:
	var person: Dictionary = content.find_record("staff", actor_id)
	if not game.sunday_date_candidates().has(actor_id):
		show_sunday_invites()
		return
	var profile: Dictionary = game.date_profile_definitions.get(actor_id, {})
	var first_date_event_id := str(profile.get("first_date_event_id", ""))
	if int(game.relation_for(actor_id).get("level", 0)) == 0 and not first_date_event_id.is_empty():
		start_sunday_character_event(first_date_event_id)
		return
	if not game.sunday_invitation_will_accept(actor_id):
		show_notice(tx("ui.sunday.declined", "%s今天已经有安排了。也许下个星期日可以再问问。") % person.name)
		return
	show_sunday_date_locations(actor_id)

func start_sunday_character_event(event_id: String) -> void:
	var definition: Dictionary = game.character_event_definitions.get(event_id, {})
	reset_dialogue_page()
	if not game.is_sunday() or game.sunday_activity_done() or definition.is_empty() or not bool(definition.get("consumes_sunday", false)) or game.start_character_event(event_id) == null:
		show_notice(tx("ui.sunday.invite_unavailable", "这个邀请现在还无法进行。"))
		return
	character_event_from_test = false
	character_event_return_location = str(definition.location_id)
	character_event_return_preop_id = ""
	show_character_event()

func start_mandatory_character_event(event_id: String) -> void:
	var definition: Dictionary = game.character_event_definitions.get(event_id, {})
	reset_dialogue_page()
	if definition.is_empty() or game.start_character_event(event_id) == null:
		show_map()
		return
	character_event_from_test = false
	character_event_return_location = str(definition.location_id)
	character_event_return_preop_id = ""
	show_character_event()

func show_sunday_date_locations(actor_id: String) -> void:
	screen = "sunday_date_locations"
	var person: Dictionary = content.find_record("staff", actor_id)
	base(tx("ui.sunday.location_title", "选择外出地点"), tx("ui.sunday.location_subtitle", "%s答应了邀请。选择今天想去的地方。") % person.name, false, "lobby")
	label_at(tx("ui.sunday.location_label", "地点"), Vector2(65, 190), 22, Color("e8cfaa"), 360)
	label_at(tx("ui.sunday.preview_label", "地点 CG／背景预览"), Vector2(665, 190), 22, Color("e8cfaa"), 500)
	var locations: Array = content.collections.date_locations.filter(func(entry: Dictionary): return str(entry.id) != "hotel")
	for i in range(locations.size()):
		var location: Dictionary = locations[i]
		var row := i % 5
		var column := i / 5
		var x := 65 + column * 285
		var location_button := button_at(str(location.name), Vector2(x, 235 + row * 66), Vector2(260, 50), begin_sunday_date.bind(actor_id, str(location.id)))
		location_button.name = "SundayDateLocation_" + str(location.id)
		location_button.disabled = str(location.asset_status) != "ready"
	var preview: Array = content.collections.date_locations.filter(func(entry: Dictionary): return str(entry.id) != "hotel" and str(entry.asset_status) == "ready")
	if preview.is_empty():
		var preview_box := ColorRect.new()
		preview_box.position = Vector2(665, 235)
		preview_box.size = Vector2(500, 320)
		preview_box.color = Color(0.025, 0.09, 0.11, 0.88)
		page.add_child(preview_box)
		label_at(tx("ui.sunday.preview_pending", "CG SLOT\n地点背景准备中"), Vector2(665, 350), 26, Color("c2d2cc"), 500).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button_at(tx("ui.sunday.change_invitee", "← 更换邀请对象"), Vector2(60, 713), Vector2(230, 40), show_sunday_invites)

func begin_sunday_date(actor_id: String, location_id: String) -> void:
	var location: Dictionary = content.find_record("date_locations", location_id)
	if location.is_empty() or str(location.get("asset_status", "pending")) != "ready":
		show_notice(tx("ui.sunday.location_pending", "这个地点的背景与约会对白还在准备中。"))
		return
	finish_sunday_activity("date", tx("ui.sunday.date_result", "和%s在%s度过了星期日。") % [content.find_record("staff", actor_id).name, location.name], actor_id, location_id)

func show_sunday_office_menu() -> void:
	screen = "sunday_office"
	base(tx("ui.sunday.office_title", "星期日的办公室"), tx("ui.sunday.office_subtitle", "走廊比平日安静得多。桌上的病例和书本仍在原处。"), false, "player_office")
	label_at(tx("ui.sunday.office_question", "在这里做点什么？"), Vector2(85, 215), 25, Color("f4f0e6"), 600)
	var options := [
		[tx("ui.sunday.office_cases", "整理病例"), tx("ui.sunday.office_cases_result", "坂口重新整理了这一周的病例。没有新的手术，但有些判断在安静下来后变得更清楚。")],
		[tx("ui.sunday.office_read", "看看医学资料"), tx("ui.sunday.office_read_result", "无人打扰的办公室很适合读文献。等坂口抬起头，窗外已经暗了。")],
		[tx("ui.sunday.office_idle", "发呆"), tx("ui.sunday.office_idle_result", "坂口什么也没做，只在安静的办公室里坐了一会儿。")],
		[tx("ui.sunday.office_coffee", "喝咖啡"), tx("ui.sunday.office_coffee_result", "咖啡凉得很慢。今天不需要赶去下一台手术。")],
	]
	for i in range(options.size()):
		button_at(str(options[i][0]), Vector2(85 + (i % 2) * 550, 300 + (i / 2) * 90), Vector2(500, 60), finish_sunday_activity.bind("office_" + str(i), str(options[i][1]))).name = "SundayOfficeAction_%s" % i
	button_at(tx("ui.common.return_sunday_arrow", "← 返回周日安排"), Vector2(60, 713), Vector2(230, 40), show_sunday_menu)

func finish_sunday_activity(activity_id: String, narration: String, actor_id: String = "", location_id: String = "") -> void:
	if not game.complete_sunday_activity(activity_id, actor_id, location_id):
		show_sunday_menu()
		return
	sunday_hospital_browsing = false
	screen = "sunday_complete"
	base(tx("ui.sunday.complete_title", "星期日结束"), narration, false, "hospital_night")
	label_at(tx("ui.sunday.complete_note", "明天又是新的工作日。"), Vector2(0, 350), 30, Color("f4f0e6"), 1280).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button_at(tx("ui.sunday.enter_monday", "进入星期一  →"), Vector2(475, 465), Vector2(330, 58), show_map)

func show_player_profile(return_location: String = "") -> void:
	screen = "player_profile"
	base(tx("ui.profile.title", "医生属性"), tx("ui.profile.subtitle", "%s的选择正在塑造医院中的身份。") % protagonist_name(), false, "lobby")
	var values: Dictionary = game.player_attributes()
	var labels := {"skill": tx("ui.attribute.skill", "手术技术"), "leadership": tx("ui.attribute.leadership", "领导力"), "charm": tx("ui.attribute.charm", "魅力"), "reputation": tx("ui.attribute.reputation", "声望"), "presence": tx("ui.attribute.presence", "临床气场")}
	var colors := {"skill": Color("79a9c9"), "leadership": Color("7eb696"), "charm": Color("d6a06c"), "reputation": Color("b79ac8"), "presence": Color("d47f79")}
	var order := ["skill", "leadership", "charm", "reputation", "presence"]
	for i in range(order.size()):
		var metric_id: String = order[i]
		var y := 205 + i * 67
		var value_text := str(values[metric_id])
		if metric_id == "charm":
			value_text = "%s（%s）" % [game.charm_tier(), values.charm]
		elif metric_id == "presence":
			value_text = game.presence_tier()
		label_at("%s　%s" % [labels[metric_id], value_text], Vector2(75, y), 22, Color("f4f0e6"), 235)
		var bar := ProgressBar.new()
		bar.position = Vector2(315, y + 3)
		bar.size = Vector2(335, 24)
		bar.min_value = -999 if metric_id == "reputation" else 0
		bar.max_value = 999 if metric_id in ["reputation", "charm"] else 100
		bar.value = 50 if metric_id == "presence" else values[metric_id]
		bar.name = "PlayerMetric_" + metric_id
		bar.show_percentage = false
		bar.add_theme_stylebox_override("fill", panel_style(colors[metric_id]))
		page.add_child(bar)
		if metric_id == "skill":
			var progress: Dictionary = game.surgery_level_progress()
			var progress_text := tx("ui.profile.max_level", "已达最高等级") if int(progress.required_xp) == 0 else tx("ui.profile.surgery_xp", "本级手术经验 %s / %s") % [progress.current_xp, progress.required_xp]
			label_at(progress_text, Vector2(670, y), 17, Color("c2d2cc"), 310).name = "SurgeryXPProgress"
		elif metric_id == "leadership":
			var leadership_progress: Dictionary = game.leadership_level_progress()
			var leadership_progress_text := tx("ui.profile.max_level", "已达最高等级") if float(leadership_progress.required_xp) == 0.0 else tx("ui.profile.leadership_xp", "本级领导经验 %s / %s") % ["%.1f" % float(leadership_progress.current_xp), "%.1f" % float(leadership_progress.required_xp)]
			label_at(leadership_progress_text, Vector2(670, y), 17, Color("c2d2cc"), 310).name = "LeadershipXPProgress"
	ClinicView.panel(self, Vector2(705, 190), Vector2(510, 390))
	label_at(tx("ui.profile.history", "重要选择记录"), Vector2(740, 220), 23, Color("e8cfaa"), 430)
	var history: Array[Dictionary] = game.player_attribute_history()
	if history.is_empty():
		label_at(tx("ui.profile.no_history", "尚未发生会改变医生道路的关键选择。"), Vector2(740, 275), 19, Color("d7dfdf"), 420)
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
	var return_action: Callable = show_location.bind(return_location, true, false) if not return_location.is_empty() else show_map
	button_at(tx("ui.common.return_office", "← 返回办公室") if not return_location.is_empty() else tx("ui.common.return_map", "← 医院导览"), Vector2(1015 if not return_location.is_empty() else 1030, 88), Vector2(200 if not return_location.is_empty() else 185, 44), return_action)

func show_time_log(return_location: String = "") -> void:
	screen = "time_log"
	base(tx("ui.time_log.title", "时间记录"), tx("ui.time_log.subtitle", "自由行动 / 工作日时间线"), false, "lobby")
	label_at(tx("ui.time_log.description", "门诊与手术耗时由各自病例记录；这里列出地点交谈、休息和关系事件。"), Vector2(60, 190), 20, Color("e0d9c4"), 1100)
	var history: Array = game.time_history()
	if history.is_empty():
		label_at(tx("ui.time_log.empty", "还没有自由行动记录。"), Vector2(65, 275), 23, Color("f4f0e6"), 900)
	else:
		var first := maxi(0, history.size() - 7)
		for i in range(first, history.size()):
			var event: Dictionary = history[i]
			var entry := label_at(tx("ui.time_log.entry", "DAY %02d　%s　%s　%s　·　%s 分钟") % [event.day, localized_calendar_text(int(event.day), true), event.clock, event.label, event.minutes], Vector2(70, 255 + (i - first) * 56), 20, Color("f4f0e6"), 1080)
			entry.name = "TimeLogEntry_" + str(i)
	label_at(tx("ui.time_log.current", "当前：%s · %s · %s　今日剩余 %s 分钟") % [game.day_text(), localized_calendar_text(), game.clock_text(), game.shift_remaining()], Vector2(65, 665), 20, Color("e8cfaa"), 850)
	var return_action: Callable = show_location.bind(return_location, true, false) if not return_location.is_empty() else show_map
	button_at(tx("ui.common.return_office", "← 返回办公室") if not return_location.is_empty() else tx("ui.common.return_map", "← 医院导览"), Vector2(1015 if not return_location.is_empty() else 1030, 88), Vector2(200 if not return_location.is_empty() else 185, 44), return_action)

func show_micro_event() -> void:
	var event = game.micro_events.get(game.active_micro_event_id)
	if event == null:
		show_map()
		return
	screen = "micro_event"
	var definition: Dictionary = event.definition
	var actor: Dictionary = content.find_record("staff", definition.actor_id)
	var location: Dictionary = content.find_record("locations", definition.location_id)
	base(definition.title, tx("ui.micro_event.subtitle", "%s / %s · 日常片段") % [actor.name, location.name], true, location.background_id)
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
	var line_role := str(line.get("speaker", "actor"))
	var speaker_name: String = str({"actor": actor.name, "player": protagonist_name(), "narrator": tx("ui.auto.ed1d855fc574", "旁白")}.get(line_role, actor.name))
	var line_phase := "response:%s" % event.response_index if event.completed else "opening:%s" % event.opening_index
	var dialogue := dialogue_page("micro:%s:%s" % [str(definition.id), line_phase], str(line.get("text", "")), bool(line.get("allow_dialogue_scroll", false)))
	var presentation := dialogue_page_presentation(speaker_name, line_role, str(dialogue.text), str(actor.name))
	vn_dialogue_box(str(presentation.speaker), str(presentation.text), "MicroEventDialogue", bool(dialogue.allow_scroll))
	if bool(dialogue.has_more):
		var page_button := button_at(tx("ui.common.continue", "继续  ▷"), Vector2(60, VN_SINGLE_ACTION_Y), Vector2(655, 54), advance_dialogue_page.bind(show_micro_event))
		page_button.name = "MicroEventPageContinue"
		register_dialogue_continue(page_button, str(presentation.text))
		button_at(tx("ui.auto.fadf24dbc5a9", "保存"), Vector2(60, 713), Vector2(120, 40), save_progress)
		button_at(tx("ui.auto.cdee65fb906e", "读档"), Vector2(194, 713), Vector2(120, 40), request_load)
		add_dialogue_playback_controls()
		return
	if event.completed:
		if event.response_finished():
			var relation: Dictionary = game.relation_for(actor.id)
			label_at(tx("ui.relationship.tendency_detail", "倾向：%s　熟悉 %s") % [affection_tendency(int(relation.get("affection", 0))), relation.familiarity], Vector2(65, 420), 18, Color("cbbc9c"), 650)
		var continue_label := tx("ui.micro_event.finish", "结束片段  ▷") if event.response_finished() else tx("ui.common.continue", "继续  ▷")
		var continue_button := button_at(continue_label, Vector2(60, VN_SINGLE_ACTION_Y), Vector2(655, 54), continue_micro_event)
		continue_button.name = "MicroEventContinue"
		register_dialogue_continue(continue_button, str(presentation.text), 0.45 if event.response_finished() else 0.0)
	else:
		if event.at_choice():
			pause_dialogue_for_choice()
			for i in range(definition.choices.size()):
				var choice: Dictionary = definition.choices[i]
				var choice_button := button_at(vn_choice_label(str(choice.label), definition.choices.size()), Vector2(60, vn_choice_y(definition.choices.size(), i)), Vector2(655, 54), choose_micro_event.bind(choice.id))
				choice_button.name = "MicroEventChoice_" + str(choice.id)
		else:
			var continue_button := button_at(tx("ui.common.continue", "继续  ▷"), Vector2(60, VN_SINGLE_ACTION_Y), Vector2(655, 54), advance_micro_event_opening)
			continue_button.name = "MicroEventContinue"
			register_dialogue_continue(continue_button, str(presentation.text))
	button_at(tx("ui.auto.fadf24dbc5a9", "保存"), Vector2(60, 713), Vector2(120, 40), save_progress)
	button_at(tx("ui.auto.cdee65fb906e", "读档"), Vector2(194, 713), Vector2(120, 40), request_load)
	add_dialogue_playback_controls()

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
	if game.special_event_in_progress():
		show_special_event()
		return
	var location_special_event: Dictionary = game.next_special_event_at(id)
	if not location_special_event.is_empty():
		special_event_return_location = id
		confirm_special_event(str(location_special_event.id))
		return
	var natural_event: Dictionary = game.next_character_event_at(id)
	if not natural_event.is_empty():
		start_character_event_from_location(str(natural_event.id), id)
		return
	if id == "player_office":
		show_player_office()
		return
	screen = "location"
	var location: Dictionary = content.find_record("locations", id)
	base(location.name, location.subtitle, false, location.background_id)
	var location_description := str(location.description)
	if id == "clinic" and game.outpatient_closed():
		location_description = tx("ui.clinic.after_close", "护士：\"今天的会诊已经结束了。\"\n病房里已经接诊的患者仍可继续处理。")
	if id == "director_office":
		if game.staff_is_met("doc_asuka"):
			location_description = tx("ui.auto.3a0d43140fde", "城宮明日香的院长室。桌面同时放着医院运营资料与外科病例，她通常会在这里处理两种身份的工作。")
		elif game.character_event_done("asuka_adjacent_operation_reveal"):
			location_description = tx("ui.auto.0e322c3e908b", "手术室护士长说城宮院长请你明天再来。今天院长室的门仍然关着。")
	if id == "emiko_office" and not game.staff_is_met("doc_emiko") and game.character_event_done("emiko_office_denied"):
		location_description = [
			tx("ui.auto.ebb27b7490e4", "护士说御堂医长正在手术，今天不会回办公室。"),
			tx("ui.auto.abbd3761df20", "护士说御堂医长正在查房，没有留下回来的时间。"),
			tx("ui.auto.9d902e2a4ddb", "护士说御堂医长去讲课了，让坂口改天再来。"),
			tx("ui.auto.f66b6b9de2fb", "护士说御堂医长正在开会，无法接待没有预约的来访。"),
			tx("ui.auto.1b9147954ccf", "办公室门锁着。护士只说御堂医长今天不在。"),
		][randi() % 5]
	var uses_staff_drawer := location_uses_staff_drawer(id)
	label_at(location_description, Vector2(60, 196), 22, Color("e0d9c4"), 700 if uses_staff_drawer else 1100)
	if allow_micro_event and game.has_micro_event("location_visit", id):
		var micro_button_x := 785 if uses_staff_drawer else 875
		var micro_button := button_at(tx("ui.location.micro_event", "日常片段"), Vector2(micro_button_x, 196), Vector2(150, 44), start_location_micro_event.bind(id))
		micro_button.name = "LocationMicroEvent"
	var present_staff: Array[String] = game.staff_present_at(id)
	if id == "rooftop":
		rooftop_actor_id = "" if present_staff.is_empty() else present_staff[0]
	if id == "rooftop":
		if rooftop_actor_id.is_empty():
			label_at(tx("ui.location.rooftop_empty", "今天天台上没有其他人。"), Vector2(65, 258), 20, Color("c2d2cc"), 650)
		else:
			var rooftop_actor: Dictionary = content.find_record("staff", rooftop_actor_id)
			label_at(tx("ui.location.rooftop_met", "今天在天台遇到了%s。") % rooftop_actor.name, Vector2(65, 258), 20, Color("e8cfaa"), 650)
			add_portrait(rooftop_actor)
			var rooftop_portrait = page.get_node_or_null("CharacterPortrait")
			if rooftop_portrait != null:
					rooftop_portrait.position = Vector2(805, 210)
					rooftop_portrait.size = Vector2(390, 430)
	var row := 0
	if not uses_staff_drawer:
		for staff_id in present_staff:
			var person: Dictionary = content.find_record("staff", staff_id)
			var met: bool = game.staff_is_met(staff_id)
			# Location rows are action selectors. Keep characterization on the staff
			# profile page so long English biographies cannot overflow into Chat.
			var caption: String = tx("ui.location.staff_caption_compact", "%s   /   %s  ·  %s岁") % [person.name, person.specialty, int(person.age)] if met else tx("ui.location.staff_unknown", "？？？   /   尚未认识")
			var profile_action: Callable = show_staff.bind(staff_id, id) if met else introduce_staff_at_location.bind(staff_id, id)
			var profile_pos := Vector2(60, 315 + row * 137) if id == "rooftop" else Vector2(60, 269 + row * 77)
			var profile_size := Vector2(700, 55) if id == "rooftop" else Vector2(840, 63)
			button_at(caption, profile_pos, profile_size, profile_action)
			if met:
				for chat in game.time_events_at(id):
					if chat.actor_id == staff_id:
						var chat_pos := Vector2(60, 382 + row * 137) if id == "rooftop" else Vector2(920, 269 + row * 77)
						var chat_size := Vector2(340, 54) if id == "rooftop" else Vector2(295, 63)
						var chat_button: Button = button_at(tx("ui.location.chat", "闲谈 · %s 分钟") % chat.minutes, chat_pos, chat_size, perform_time_event.bind(chat.id, id))
						chat_button.name = "TimeEvent_" + chat.id
			row += 1
	if id == "clinic":
		if game.is_hospital_closed_day():
			label_at(tx("ui.clinic.closed", "今日为%s，普通门诊休诊。病房、急诊与值班工作仍在运行。") % localized_calendar_day_label(), Vector2(60, 420), 20, Color("e8cfaa"), 735)
		var current_patient_id := "" if game.is_hospital_closed_day() else game.current_patient_id()
		if game.outpatient_closed() and not current_patient_id.is_empty():
			var current_encounter_id := encounter_for_patient(current_patient_id)
			if current_encounter_id.is_empty() or not game.visits.has(current_encounter_id):
				current_patient_id = ""
		var patient_row := 0
		# Keep the waiting-patient controls below the last complete staff row.
		var patient_base_y: int = 390
		for patient in content.collections.patients:
			if patient.id != current_patient_id:
				continue
			var case_data: Dictionary = game.patient_case(patient.id)
			if case_data.is_empty():
				case_data = content.find_record("cases", patient.case_id)
			var encounter_id := encounter_for_patient(patient.id)
			var caption := tx("ui.clinic.waiting", "当前候诊  /  %s · %s岁   /   %s") % [patient.name, int(patient.age), case_data.title]
			if not encounter_id.is_empty() and (not game.is_hospital_closed_day() or game.visits.has(encounter_id)):
				caption += "   /   " + (tx("ui.clinic.view_handoff", "查看住院交接") if game.admitted_patient(patient.id) else tx("ui.clinic.start_continue", "接诊 / 继续"))
				button_at(caption, Vector2(60, patient_base_y + patient_row * 137), Vector2(1155, 60), show_encounter.bind(encounter_id))
			elif game.is_hospital_closed_day():
				label_at(caption + tx("ui.clinic.closed_suffix", "（普通门诊休诊）"), Vector2(65, patient_base_y + 15 + patient_row * 137), 21, Color("c2d2cc"), 1150)
			else:
				label_at(caption + tx("ui.clinic.future_suffix", "（后续开放）"), Vector2(65, patient_base_y + 15 + patient_row * 137), 21, Color("dce5e3"), 1150)
			var action_y: int = patient_base_y + patient_row * 137 + 68
			var portrait_width: int = 565 if not game.admitted_patient(patient.id) else 1155
			var portrait_button := button_at(tx("ui.clinic.patient_portrait", "人物立绘"), Vector2(60, action_y), Vector2(portrait_width, 60), show_patient.bind(patient.id))
			portrait_button.name = "PatientPortrait"
			if not game.admitted_patient(patient.id):
				var referral_button := button_at(tx("ui.clinic.refer", "转诊…"), Vector2(650, action_y), Vector2(565, 60), show_referral.bind(patient.id))
				referral_button.name = "ReferPatient"
			patient_row += 1
		if current_patient_id.is_empty():
			label_at(tx("ui.clinic.no_patients_closed", "休诊日没有普通候诊患者。") if game.is_hospital_closed_day() else tx("ui.clinic.no_patients", "当前没有可安排的候诊患者。"), Vector2(65, patient_base_y + 15), 21)
	if id == "ward":
		var row_index := 0
		for patient in content.collections.patients:
			if game.admitted_patient(patient.id):
				button_at(tx("ui.ward.patient_chart", "%s  /  病历") % patient.name, Vector2(60, 390 + row_index * 72), Vector2(360, 60), show_encounter.bind(encounter_for_patient(patient.id)))
				var preparation_id := preop_for_patient(patient.id)
				if not preparation_id.is_empty() and not game.is_hospital_closed_day():
					button_at(tx("ui.auto.563b0d61871d", "探视 / 继续术前安排 →"), Vector2(445, 390 + row_index * 72), Vector2(770, 60), show_preop.bind(preparation_id))
				row_index += 1
		if row_index == 0:
			label_at(tx("ui.auto.c256b9ad45a6", "当前没有已收住院的患者。"), Vector2(65, 405), 22)
	if id == "or":
		if game.is_hospital_closed_day():
			label_at(tx("ui.auto.e1d45975850a", "今天不安排择期手术。手术间保持待命，只接受特殊事件或未来的急诊调用。"), Vector2(65, 465), 22, Color("e8cfaa"), 1080)
		elif not game.active_preop_id.is_empty():
			button_at(tx("ui.auto.049f0daab5a2", "继续术前准备 →"), Vector2(60, 465), Vector2(1155, 60), show_preop.bind(game.active_preop_id))
		else:
			label_at(tx("ui.auto.629b897dc862", "请先到病房探视患者并安排团队。"), Vector2(65, 465), 22)
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
		var button: Button = button_at(tx("ui.auto.a8881f334f4a", "%s　·　%s 分钟") % [event.label, event.minutes], event_pos, event_size, perform_time_event.bind(event.id, id))
		button.name = "TimeEvent_" + event.id
	if location_feedback_location == id and not location_feedback.is_empty():
		feedback_at(location_feedback, Vector2(65, 650 if id == "lounge" else 450), 19 if id == "lounge" else 21, 650)
	if uses_staff_drawer:
		render_location_staff_drawer(id, present_staff)
	button_at(tx("ui.common.return_map", "← 医院导览"), Vector2(1030, 88), Vector2(185, 44), show_map)

func location_uses_staff_drawer(location_id: String) -> bool:
	return location_id in ["clinic", "ward", "or"]

func toggle_location_staff_drawer(location_id: String) -> void:
	location_staff_drawer_open = "" if location_staff_drawer_open == location_id else location_id
	show_location(location_id, true, false)

func render_location_staff_drawer(location_id: String, present_staff: Array[String]) -> void:
	var expanded := location_staff_drawer_open == location_id
	var toggle_text := tx("ui.location.staff_drawer.close", "收起医护  ·  %s  ▲") % present_staff.size() if expanded else tx("ui.location.staff_drawer.open", "在场医护  ·  %s  ▼") % present_staff.size()
	var toggle := button_at(toggle_text, Vector2(955, 196), Vector2(260, 44), toggle_location_staff_drawer.bind(location_id))
	toggle.name = "LocationStaffToggle"
	if not expanded:
		return
	var drawer := Panel.new()
	drawer.name = "LocationStaffDrawer"
	drawer.position = Vector2(710, 252)
	drawer.size = Vector2(505, 430)
	drawer.z_index = 20
	drawer.add_theme_stylebox_override("panel", panel_style(Color(0.025, 0.075, 0.09, 0.97), Color("d1c19e")))
	page.add_child(drawer)
	var heading := Label.new()
	heading.text = tx("ui.location.staff_drawer.heading", "在场医护")
	heading.position = Vector2(22, 15)
	heading.size = Vector2(440, 34)
	heading.add_theme_font_size_override("font_size", 21)
	heading.add_theme_color_override("font_color", Color("e8cfaa"))
	drawer.add_child(heading)
	var scroll := ScrollContainer.new()
	scroll.name = "LocationStaffScroll"
	scroll.position = Vector2(18, 57)
	scroll.size = Vector2(469, 353)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	drawer.add_child(scroll)
	var list := VBoxContainer.new()
	list.name = "LocationStaffList"
	list.custom_minimum_size = Vector2(450, 0)
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)
	if present_staff.is_empty():
		var empty_label := Label.new()
		empty_label.text = tx("ui.location.staff_drawer.empty", "当前没有待机医护。")
		empty_label.add_theme_font_size_override("font_size", 18)
		empty_label.add_theme_color_override("font_color", Color("c2d2cc"))
		list.add_child(empty_label)
		return
	var chats: Array = game.time_events_at(location_id)
	for staff_id in present_staff:
		var person: Dictionary = content.find_record("staff", staff_id)
		var met := game.staff_is_met(staff_id)
		var row_box := VBoxContainer.new()
		row_box.name = "LocationStaffRow_" + staff_id
		row_box.custom_minimum_size = Vector2(450, 58)
		row_box.add_theme_constant_override("separation", 5)
		list.add_child(row_box)
		var caption: String = tx("ui.location.staff_caption_compact", "%s   /   %s  ·  %s岁") % [person.name, person.specialty, int(person.age)] if met else tx("ui.location.staff_unknown", "？？？   /   尚未认识")
		var profile := Button.new()
		profile.name = "LocationStaff_" + staff_id
		profile.text = caption
		profile.alignment = HORIZONTAL_ALIGNMENT_LEFT
		profile.custom_minimum_size = Vector2(450, 58)
		profile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		profile.clip_text = true
		profile.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		profile.add_theme_color_override("font_color", Color("f4f0e6"))
		profile.add_theme_stylebox_override("normal", panel_style(Color("203e48")))
		profile.add_theme_stylebox_override("hover", panel_style(Color("365963"), Color("d1c19e")))
		profile.add_theme_stylebox_override("focus", panel_style(Color("365963"), Color("f3dbac")))
		profile.pressed.connect(show_staff.bind(staff_id, location_id) if met else introduce_staff_at_location.bind(staff_id, location_id))
		row_box.add_child(profile)
		var matching_chat: Dictionary = {}
		if met:
			for chat in chats:
				if str(chat.actor_id) == staff_id:
					matching_chat = chat
					break
		if not matching_chat.is_empty():
			var chat_button := Button.new()
			chat_button.name = "TimeEvent_" + str(matching_chat.id)
			chat_button.text = tx("ui.location.chat_compact", "闲谈  ·  %s 分钟") % int(matching_chat.minutes)
			chat_button.custom_minimum_size = Vector2(450, 42)
			chat_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
			chat_button.clip_text = true
			chat_button.add_theme_color_override("font_color", Color("f4f0e6"))
			chat_button.add_theme_stylebox_override("normal", panel_style(Color("203e48")))
			chat_button.add_theme_stylebox_override("hover", panel_style(Color("365963"), Color("d1c19e")))
			chat_button.add_theme_stylebox_override("focus", panel_style(Color("365963"), Color("f3dbac")))
			chat_button.pressed.connect(perform_time_event.bind(str(matching_chat.id), location_id))
			row_box.add_child(chat_button)

func show_player_office() -> void:
	PlayerOfficeView.render_main(self)

func show_office_relationships() -> void:
	PlayerOfficeView.render_relationships(self)

func show_office_personal_nurse() -> void:
	PlayerOfficeView.render_personal_nurse(self)

func choose_personal_nurse(actor_id: String) -> void:
	if not game.set_personal_nurse(actor_id):
		show_notice(tx("ui.personal_nurse.unavailable", "这名护士目前不能担任专属护士。"))
		return
	show_notice(tx("ui.personal_nurse.changed", "以后门诊就一起工作了。请多关照。"))
	show_office_personal_nurse()

func show_personal_nurse_chatter() -> void:
	var actor_id: String = game.resolve_outpatient_support_actor()
	var person: Dictionary = content.find_record("staff", actor_id)
	var line: String = tx("ui.personal_nurse.chatter_default", game.personal_nurse_dialogue("chatter"))
	show_notice("%s：\n%s" % [person.get("name", tx("ui.personal_nurse.title", "专属护士")), line])

func show_office_cases() -> void:
	PlayerOfficeView.render_cases(self)

func show_office_case(patient_id: String) -> void:
	PlayerOfficeView.render_case_detail(self, patient_id)

func show_office_career() -> void:
	PlayerOfficeView.render_career(self)

func show_office_actions() -> void:
	PlayerOfficeView.render_actions(self)

func show_office_collection() -> void:
	PlayerOfficeView.render_collection(self)

func show_office_item(item_id: String) -> void:
	PlayerOfficeView.render_item(self, item_id)

func introduce_staff_at_location(staff_id: String, location_id: String) -> void:
	for definition in game.character_events_at(location_id):
		if definition.actor_id == staff_id and definition.category == "introduction":
			character_event_from_test = false
			character_event_return_location = location_id
			reset_dialogue_page()
			if game.start_character_event(str(definition.id)) != null:
				show_character_event()
				return
	if staff_id == "doc_emiko":
		show_notice(tx("ui.unlock.emiko", "御堂江美子会在手术技术达到 56 后正式接见你。当前技术：%s。") % game.surgery_level())
		return
	if staff_id == "doc_artoria":
		if not game.character_event_done("intro_doc_asuka_director_office"):
			show_notice(tx("ui.unlock.artoria_asuka", "先推进明日香的剧情，并在院长室与她正式相识。"))
		elif not game.character_event_done("emiko_intro_rumored_hands"):
			show_notice(tx("ui.unlock.artoria_emiko", "先将手术技术提升至 56，在御堂外科医长办公室与御堂正式相识。"))
		elif not game.character_event_done("asuka_mentions_artoria_rival"):
			show_notice(tx("ui.unlock.artoria_referral", "回到院长室。明日香会向你介绍另一位外科主任候选人。"))
		else:
			show_notice(tx("ui.unlock.artoria_ready", "前往外科副部长办公室，阿尔托莉雅正在等你。"))
		return
	show_notice(tx("ui.auto.bca6db1317a3", "现在还没有合适的机会上前认识。"))

func start_location_micro_event(location_id: String) -> void:
	if game.select_micro_event("location_visit", location_id) == null:
		show_notice(tx("ui.auto.e2fef8fd4fa7", "这里现在没有可触发的日常片段。"))
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
		location_feedback = tx("ui.auto.d74916abf216", "%s\n现在是 %s · 今日还剩 %s 分钟。") % [game.last_time_event_response, game.clock_text(), game.shift_remaining()]
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

func after_work_outfit(actor: Dictionary) -> String:
	var portraits: Dictionary = actor.get("visuals", {}).get("portraits", {})
	if portraits.has("after_work/neutral"):
		return "after_work"
	if portraits.has("casual/neutral"):
		return "casual"
	var default_outfit := str(actor.get("visuals", {}).get("default_outfit", "uniform"))
	if portraits.has(default_outfit + "/neutral"):
		return default_outfit
	return "uniform"

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
	base(tx("ui.auto.3046323cd799", "片刻闲谈"), "%s / %s" % [actor.name, location.name], true, location.background_id)
	var outfit := chat_outfit_for_location(actor, location_id)
	var expression := chat_expression_for_outfit(actor, outfit)
	add_portrait(actor, expression, outfit)
	var portrait = page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(760, 150)
		portrait.size = Vector2(450, 380)
	var dialogue := dialogue_page("time_event:%s:%s" % [event_id, game.day_number()], game.last_time_event_response)
	vn_dialogue_box(actor.name, str(dialogue.text), "TimeEventDialogue")
	label_at(tx("ui.auto.b058dbad32f3", "耗时 %s 分钟　/　现在是 %s") % [definition.minutes, game.clock_text()], Vector2(65, 205), 19, Color("c2d2cc"), 620)
	if bool(dialogue.has_more):
		var continue_button := button_at(tx("ui.common.continue", "继续  ▷"), Vector2(1015, 713), Vector2(210, 40), advance_dialogue_page.bind(show_time_event_result.bind(event_id, location_id, crossed_day)))
		continue_button.name = "TimeEventDialogueContinue"
		register_dialogue_continue(continue_button, str(dialogue.text))
	else:
		var finish_button := button_at(tx("ui.auto.e7a9c67f35b7", "结束闲谈  →"), Vector2(1015, 713), Vector2(210, 40), finish_time_event_result.bind(location_id, crossed_day))
		finish_button.name = "TimeEventDialogueFinish"
		register_dialogue_continue(finish_button, str(dialogue.text), 0.45)
	add_dialogue_playback_controls()

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
	base(actor.name + " · 事件测试", tx("ui.auto.42d4e89d09f7", "开发入口 / 条件、分支与差分测试"), true, background_for_location(character_event_return_location))
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
		var caption := tx("ui.auto.e3296ed7fffb", "第%s章　%s　·　%s分钟　%s–%s") % [definition.chapter, definition.title, definition.minutes, clock_from_minutes(definition.time_start), clock_from_minutes(definition.time_end)]
		if completed:
			caption = tx("ui.auto.a99515594958", "✓ 已完成　") + caption
		elif not available:
			caption = tx("ui.auto.45f97055c694", "条件未满足　") + caption
		else:
			caption = tx("ui.auto.07d24edcd1c9", "当前可触发　") + caption
		var event_button := button_at(caption, Vector2(60, 215 + i * 88), Vector2(685, 66), start_test_character_event.bind(definition.id))
		event_button.name = "CharacterEvent_" + definition.id
	var relation: Dictionary = game.relation_for(actor_id)
	label_at(tx("ui.relationship.tendency_detail", "倾向：%s　熟悉 %s") % [affection_tendency(int(relation.get("affection", 0))), relation.familiarity], Vector2(65, 600), 20, Color("e8cfaa"), 680)
	button_at(tx("ui.auto.783d9146690e", "← 返回人物档案"), Vector2(1000, 88), Vector2(215, 44), show_staff.bind(actor_id, character_event_return_location))

func start_test_character_event(event_id: String) -> void:
	if not game.character_event_definitions.has(event_id):
		return
	gallery_replay_event = CharacterEvent.new(game.character_event_definitions[event_id])
	gallery_replay_is_test = true
	gallery_replay_return_actor = gallery_replay_event.definition.actor_id
	reset_dialogue_page()
	show_gallery_replay()

func start_character_event(event_id: String) -> void:
	character_event_from_test = true
	character_event_return_preop_id = ""
	reset_dialogue_page()
	if game.start_character_event(event_id) == null:
		show_notice(tx("ui.auto.2f10035545f2", "这个事件尚未解锁。"))
		return
	show_character_event()

func start_character_event_from_location(event_id: String, location_id: String) -> void:
	var definition: Dictionary = game.character_event_definitions.get(event_id, {})
	if definition.is_empty() or game.next_character_event_at(location_id).get("id", "") != event_id:
		show_notice(tx("ui.auto.9bc2eb7989fd", "这个事件当前没有发生。"))
		return
	character_event_from_test = false
	character_event_return_location = location_id
	character_event_return_preop_id = ""
	reset_dialogue_page()
	if game.start_character_event(event_id) == null:
		show_notice(tx("ui.auto.a64e720254db", "这个事件当前无法开始。"))
		return
	show_character_event()

func start_character_event_from_preop_stage(stage_id: String) -> bool:
	var definition: Dictionary = game.next_character_event_for_preop_stage(stage_id)
	if definition.is_empty():
		return false
	character_event_from_test = false
	character_event_return_location = str(definition.location_id)
	character_event_return_preop_id = game.active_preop_id
	reset_dialogue_page()
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
	var location_name := str(definition.get("location_label", location.name))
	var event_label := tx("ui.auto.2a5a8f45f76f", "第%s章") % definition.chapter
	if definition.category == "introduction":
		event_label = tx("ui.auto.c55f831ad393", "认识事件")
	elif definition.category == "contextual":
		event_label = tx("ui.auto.78f45a8745f6", "遭遇事件")
	elif definition.category == "bond":
		event_label = tx("ui.auto.eb68d92bf615", "建立羁绊 Lv.1")
	elif definition.category == "rank_up":
		event_label = tx("ui.auto.bd46ceb05a5c", "关系升级 Lv.%s") % definition.target_level
	base(definition.title, "%s / %s / %s" % [actor_name, event_label, location_name], true, definition.background_id)
	add_character_event_visual(actor, node, definition.outfit)
	var source_role := str(node.get("speaker", "actor"))
	var speaker: String = str(node.get("speaker_label", {"actor": actor_name, "player": protagonist_name(), "narrator": tx("ui.auto.ed1d855fc574", "旁白")}.get(source_role, actor_name)))
	var dialogue := dialogue_page("character:%s:%s" % [str(definition.id), str(node.id)], str(node.text), bool(node.get("allow_dialogue_scroll", false)))
	var presentation := dialogue_page_presentation(speaker, source_role, str(dialogue.text), actor_name)
	vn_dialogue_box(str(presentation.speaker), str(presentation.text), "CharacterEventDialogue", bool(dialogue.allow_scroll))
	if bool(dialogue.has_more):
		var continue_button := button_at(tx("ui.common.continue", "继续  ▷"), Vector2(60, VN_SINGLE_ACTION_Y), Vector2(655, 54), advance_dialogue_page.bind(show_character_event))
		continue_button.name = "EventDialogueContinue"
		register_dialogue_continue(continue_button, str(presentation.text))
		button_at(tx("ui.auto.fadf24dbc5a9", "保存"), Vector2(60, 713), Vector2(120, 40), save_progress)
		button_at(tx("ui.auto.cdee65fb906e", "读档"), Vector2(194, 713), Vector2(120, 40), request_load)
		add_dialogue_playback_controls()
		return
	var only_choice_button: Button
	for i in range(node.choices.size()):
		var choice: Dictionary = node.choices[i]
		var choice_button := button_at(vn_choice_label(str(choice.label), node.choices.size()), Vector2(60, vn_choice_y(node.choices.size(), i)), Vector2(655, 54), choose_character_event.bind(choice.id))
		choice_button.name = "EventChoice_" + choice.id
		only_choice_button = choice_button
	if node.choices.size() == 1:
		register_dialogue_continue(only_choice_button, str(presentation.text), 0.2)
	else:
		pause_dialogue_for_choice()
	button_at(tx("ui.auto.fadf24dbc5a9", "保存"), Vector2(60, 713), Vector2(120, 40), save_progress)
	button_at(tx("ui.auto.cdee65fb906e", "读档"), Vector2(194, 713), Vector2(120, 40), request_load)
	add_dialogue_playback_controls()

func add_character_event_visual(actor: Dictionary, node: Dictionary, outfit: String) -> void:
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
	if bool(node.get("hide_portrait", false)):
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
				reset_dialogue_page()
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
	var continue_button := button_at(tx("ui.auto.bac86b222931", "继续  →"), Vector2(1030, 690), Vector2(190, 52), show_character_event_complete)
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
	base(tx("ui.auto.9f66bcb3b7ff", "事件结束"), "%s / %s" % [actor_name, event.definition.title], true, event.definition.background_id)
	if game.staff_is_met(str(actor.id)) and not bool(event.definition.get("hide_completion_portrait", false)):
		add_portrait(actor, "smile", event.definition.outfit)
	label_at(tx("ui.auto.3092031e1556", "与%s有关的这段插曲已经结束。") % actor_name, Vector2(65, 235), 27, Color("f4f0e6"), 650)
	var level := int(relation.get("level", 0))
	var relation_note := tx("ui.auto.128daa344185", "尚未正式认识")
	if bool(relation.get("met", false)):
		relation_note = tx("ui.auto.8ab0840337da", "已经认识 · 普通同事 · 尚未建立羁绊") if level == 0 else tx("ui.auto.77f8b23d5b2f", "已经认识 · 关系 Lv.%s") % level
	if event.definition.category == "bond" and level >= int(event.definition.get("target_level", 1)):
		relation_note = tx("ui.auto.5124014a71dc", "已经建立羁绊 · 关系 Lv.1")
	elif event.definition.category == "rank_up":
		relation_note = tx("ui.auto.1f258526390d", "关系提升至 Lv.%s") % relation.get("level", 1)
	label_at(relation_note, Vector2(65, 325), 22, Color("e8cfaa"), 650)
	label_at(tx("ui.auto.b058dbad32f3", "耗时 %s 分钟　/　现在是 %s") % [event.definition.minutes, game.clock_text()], Vector2(65, 385), 19, Color("c2d2cc"), 650)
	var return_preop_id := character_event_return_preop_id
	if return_preop_id.is_empty() and not str(event.definition.get("preop_stage_id", "")).is_empty():
		return_preop_id = game.active_preop_id
	if character_event_from_test:
		button_at(tx("ui.auto.c27f998ca0c2", "返回事件测试  →"), Vector2(60, 475), Vector2(320, 54), show_character_events.bind(actor.id, character_event_return_location))
	elif bool(event.definition.get("consumes_sunday", false)):
		button_at(tx("ui.auto.05194e8cf7c4", "结束星期日  →"), Vector2(60, 475), Vector2(320, 54), finish_sunday_character_event.bind(str(actor.id), str(event.definition.get("date_location_id", ""))))
	elif not return_preop_id.is_empty():
		button_at(tx("ui.auto.68b3672e88ea", "继续术前流程  →"), Vector2(60, 475), Vector2(320, 54), return_to_preop_after_character_event.bind(return_preop_id))
	else:
		button_at(tx("ui.auto.34cf9c3fa0c4", "返回%s  →") % content.find_record("locations", character_event_return_location).name, Vector2(60, 475), Vector2(320, 54), show_location.bind(character_event_return_location))
	if not bool(event.definition.get("consumes_sunday", false)):
		button_at(tx("ui.auto.b080ed2dfa2f", "返回医院导览"), Vector2(400, 475), Vector2(315, 54), show_map)

func finish_sunday_character_event(actor_id: String, location_id: String) -> void:
	var relation: Dictionary = game.relation_for(actor_id)
	var narration := tx("ui.auto.2b070c5ffdf5", "和%s在温暖的小餐馆里度过了星期日。") % content.find_record("staff", actor_id).name
	if int(relation.get("level", 0)) >= 1:
		narration = tx("ui.auto.3d8811c9d804", "和%s吃完了第一次约会的晚餐。两个人都已经知道，这不只是一顿饭。") % content.find_record("staff", actor_id).name
	finish_sunday_activity("date", narration, actor_id, location_id)

func show_staff_role_reward(reward: Dictionary, next_action: Callable) -> void:
	var path := str(reward.get("path", ""))
	if path.is_empty() or not FileAccess.file_exists("res://" + path):
		next_action.call()
		return
	screen = "staff_role_reward"
	staff_role_reward_next = next_action
	base("", "", false)
	var cg := TextureRect.new()
	cg.name = "StaffRoleRewardCG"
	cg.texture = load("res://" + path)
	cg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(cg)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.025, 0.04, 0.62)
	shade.position = Vector2(0, 630)
	shade.size = Vector2(1280, 170)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(shade)
	var actor: Dictionary = content.find_record("staff", str(reward.staff_id))
	label_at(tx("ui.auto.386bf5c9a657", "岗位回忆解锁 · %s") % str(reward.title), Vector2(55, 655), 22, Color("e8cfaa"), 850)
	label_at("%s：%s" % [actor.name, str(reward.caption)], Vector2(55, 695), 21, Color("f4f0e6"), 900)
	var continue_button := button_at(tx("ui.auto.68b3672e88ea", "继续术前流程  →"), Vector2(1010, 690), Vector2(215, 52), continue_staff_role_reward)
	continue_button.name = "StaffRoleRewardContinue"

func continue_staff_role_reward() -> void:
	if not staff_role_reward_next.is_valid():
		show_map()
		return
	var next_action := staff_role_reward_next
	staff_role_reward_next = Callable()
	next_action.call()

func return_to_preop_after_character_event(preop_id: String) -> void:
	character_event_return_preop_id = ""
	show_preop(preop_id)

func show_special_events() -> void:
	screen = "special_events"
	base(tx("ui.auto.937f5b340132", "特殊活动"), tx("ui.auto.02e2f59614c8", "多人互动、院内活动与重要情节 / SPECIAL EVENTS"), false, "lobby")
	var events: Array = game.available_special_events()
	if events.is_empty():
		var empty_text := tx("ui.auto.133c6333cbf6", "目前没有可以参加的特殊活动。\n满足角色、关系、前置事件或日期条件后，活动会出现在这里。")
		if game.postponed_special_event_count() > 0:
			empty_text = tx("ui.auto.7945ac700354", "有特殊活动因更高优先级的院内日程而顺延。\n高优先级活动结束后，它会在下一个可用工作日重新出现。")
		label_at(empty_text, Vector2(80, 230), 24, Color("f4f0e6"), 1050)
	else:
		var event_scroll := ScrollContainer.new()
		event_scroll.name = "SpecialEventScroll"
		event_scroll.position = Vector2(45, 175)
		event_scroll.size = Vector2(1190, 475)
		event_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		page.add_child(event_scroll)
		var event_content := Control.new()
		event_content.custom_minimum_size = Vector2(1170, max(475, events.size() * 92 + 20))
		event_scroll.add_child(event_content)
		for i in range(events.size()):
			var definition: Dictionary = events[i]
			var days := int(definition.duration_days)
			var caption := tx("ui.special_event.zero_time_caption", "%s\n%s · 不消耗游戏时间") % [definition.title, str(definition.category)] if not bool(definition.get("consumes_full_day", true)) else tx("ui.auto.9337056caa0d", "%s\n%s · 连续占用 %s 天") % [definition.title, str(definition.category), days]
			var button := button_at(caption, Vector2.ZERO, Vector2(1110, 72), confirm_special_event.bind(str(definition.id)))
			page.remove_child(button)
			event_content.add_child(button)
			button.position = Vector2(20, 10 + i * 92)
			button.name = "SpecialEvent_" + str(definition.id)
	if game.postponed_special_event_count() > 0 and not events.is_empty():
		label_at(tx("ui.auto.489470c02ccb", "另有活动因更高优先级日程顺延。"), Vector2(65, 655), 17, Color("d8d8c7"), 700)
	if OS.is_debug_build() and game.special_event_definitions.has("advanced_referral_tutorial_chisato"):
		button_at(tx("ui.advanced_referral.test_entry", "开发测试：本人就在这里"), Vector2(65, 670), Vector2(330, 46), begin_advanced_referral_tutorial_test)
	button_at(tx("ui.auto.53c4c7fe6bb3", "← 医院导览"), Vector2(1030, 88), Vector2(185, 44), show_map)

func begin_advanced_referral_tutorial_test() -> void:
	reset_dialogue_page()
	if game.start_special_event_for_testing("advanced_referral_tutorial_chisato") == null:
		show_notice(game.last_error)
		return
	show_special_event()

func confirm_special_event(event_id: String) -> void:
	var definition: Dictionary = game.special_event_definitions.get(event_id, {})
	if definition.is_empty() or not game.special_event_available(definition):
		show_notice(tx("ui.auto.ca5fc768fe51", "这个特殊活动当前无法开始。"))
		return
	special_event_pending_id = event_id
	if bool(definition.get("auto_schedule", false)):
		begin_special_event()
		return
	screen = "special_event_confirm"
	base(definition.title, tx("ui.auto.7f4d0724cb43", "开始前确认"), false, "lobby")
	var days := int(definition.duration_days)
	var warning := tx("ui.auto.ce5babb10966", "该事件将占用今天剩余时间。") if days == 1 else tx("ui.auto.25a05ba9c198", "该特殊事件将连续占用 %s 天。\n期间无法进行普通活动。") % days
	if not str(definition.get("announcement", "")).is_empty():
		warning = str(definition.announcement) + "\n\n" + warning
	var warning_label := label_at(warning, Vector2(160, 225), 24, Color("f4f0e6"), 960)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warning_label.size = Vector2(960, 170)
	button_at(tx("ui.auto.b638db7ded07", "开始活动"), Vector2(330, 455), Vector2(280, 60), begin_special_event)
	button_at(tx("ui.auto.1e1b4e4cc9ed", "暂不参加"), Vector2(670, 455), Vector2(280, 60), show_special_events)

func begin_special_event() -> void:
	if game.start_special_event(special_event_pending_id) == null:
		show_notice(game.last_error)
		return
	special_event_pending_id = ""
	special_event_last_cg_path = ""
	reset_dialogue_page()
	show_special_event()

func special_event_actor(node: Dictionary) -> Dictionary:
	var actor_id := str(node.get("actor_id", ""))
	return content.find_record("staff", actor_id) if not actor_id.is_empty() else {}

func special_event_speaker(node: Dictionary, actor: Dictionary) -> String:
	if node.has("speaker_label"):
		return str(node.speaker_label)
	match str(node.get("speaker", "narrator")):
		"player": return protagonist_name()
		"actor": return str(actor.get("name", tx("ui.auto.a18544e2139e", "职员")))
		_: return tx("ui.auto.ed1d855fc574", "旁白")

func add_special_event_visual(node: Dictionary) -> void:
	if not str(node.get("cg_path", "")).is_empty() or not str(node.get("portrait_path", "")).is_empty():
		add_character_event_visual({}, node, "")
		return
	var actor := special_event_actor(node)
	if actor.is_empty():
		return
	var outfit := str(node.get("outfit", actor.get("visuals", {}).get("default_outfit", "white_coat")))
	add_character_event_visual(actor, node, outfit)

func reveal_special_event_items_after_cg(items: Array, expected_screen: String, expected_node_id: String, delay_seconds: float) -> void:
	await get_tree().create_timer(delay_seconds).timeout
	if screen != expected_screen:
		return
	if expected_screen == "special_event":
		if game.active_special_event == null or str(game.active_special_event.node_id) != expected_node_id:
			return
	elif expected_screen == "special_gallery_replay":
		if special_event_gallery_replay == null or str(special_event_gallery_replay.node_id) != expected_node_id:
			return
	for item in items:
		if is_instance_valid(item):
			item.show()

func delay_special_event_content_for_cg(node: Dictionary, definition: Dictionary, dialogue_items: Array, buttons: Array, expected_screen: String, is_new_cg: bool) -> void:
	if str(node.get("cg_path", "")).is_empty():
		return
	var dialogue_delay := float(node.get("cg_dialogue_delay_seconds", definition.get("cg_dialogue_delay_seconds", 0.0)))
	if dialogue_delay > 0.0:
		if not is_new_cg:
			return
		var content_items := dialogue_items + buttons
		for item in content_items:
			if is_instance_valid(item):
				item.hide()
		reveal_special_event_items_after_cg(content_items, expected_screen, str(node.get("id", "")), dialogue_delay)
		return
	for item in buttons:
		if is_instance_valid(item):
			item.hide()
	reveal_special_event_items_after_cg(buttons, expected_screen, str(node.get("id", "")), 1.0)

func show_special_event() -> void:
	var event = game.active_special_event
	if event == null:
		show_special_events()
		return
	if event.completed:
		show_special_event_complete()
		return
	var definition: Dictionary = event.definition
	var step: Dictionary = event.current_step()
	var node: Dictionary = event.current()
	if str(node.get("presentation", "narrative")) in ["advanced_referral_summary", "advanced_surgery"]:
		show_advanced_referral_node(event, step, node)
		return
	screen = "special_event"
	base(definition.title, tx("ui.auto.437e87474468", "%s / 第 %s 天，共 %s 天") % [step.title, event.step_index + 1, definition.duration_days], true, node.get("background_id", step.background_id))
	var cg_path := str(node.get("cg_path", ""))
	var is_new_cg := not cg_path.is_empty() and cg_path != special_event_last_cg_path
	special_event_last_cg_path = cg_path
	add_special_event_visual(node)
	var actor := special_event_actor(node)
	var source_role := str(node.get("speaker", "narrator"))
	var default_speaker := special_event_speaker(node, actor)
	var dialogue := dialogue_page("special:%s:%s:%s" % [str(definition.id), str(step.id), str(node.id)], str(node.text), bool(node.get("allow_dialogue_scroll", false)))
	var presentation := dialogue_page_presentation(default_speaker, source_role, str(dialogue.text), str(actor.get("name", "")))
	var dialogue_items := vn_dialogue_box(str(presentation.speaker), str(presentation.text), "SpecialEventDialogue", bool(dialogue.allow_scroll))
	var action_buttons: Array = []
	if bool(dialogue.has_more):
		var page_button := button_at(tx("ui.common.continue", "继续  ▷"), Vector2(60, VN_SINGLE_ACTION_Y), Vector2(655, 54), advance_dialogue_page.bind(show_special_event))
		page_button.name = "SpecialEventDialogueContinue"
		action_buttons.append(page_button)
		register_dialogue_continue(page_button, str(presentation.text), 0.7 if is_new_cg else 0.0)
		var page_save_button := button_at(tx("ui.auto.fadf24dbc5a9", "保存"), Vector2(60, 713), Vector2(120, 40), save_progress)
		var page_load_button := button_at(tx("ui.auto.cdee65fb906e", "读档"), Vector2(194, 713), Vector2(120, 40), request_load)
		action_buttons.append(page_save_button)
		action_buttons.append(page_load_button)
		delay_special_event_content_for_cg(node, definition, dialogue_items, action_buttons, "special_event", is_new_cg)
		add_dialogue_playback_controls()
		return
	var visible_choices: Array = []
	for choice in node.get("choices", []):
		if not game.special_requirements_met(choice.get("requirements", [])):
			continue
		visible_choices.append(choice)
	for visible_index in range(visible_choices.size()):
		var choice: Dictionary = visible_choices[visible_index]
		var choice_button := button_at(vn_choice_label(str(choice.label), visible_choices.size()), Vector2(60, vn_choice_y(visible_choices.size(), visible_index)), Vector2(655, 54), choose_special_event.bind(str(choice.id)))
		choice_button.name = "SpecialEventChoice_" + str(choice.id)
		action_buttons.append(choice_button)
	if visible_choices.size() == 1:
		register_dialogue_continue(action_buttons[0], str(presentation.text), 0.7 if is_new_cg else 0.2)
	else:
		pause_dialogue_for_choice()
	var save_button := button_at(tx("ui.auto.fadf24dbc5a9", "保存"), Vector2(60, 713), Vector2(120, 40), save_progress)
	var load_button := button_at(tx("ui.auto.cdee65fb906e", "读档"), Vector2(194, 713), Vector2(120, 40), request_load)
	action_buttons.append(save_button)
	action_buttons.append(load_button)
	delay_special_event_content_for_cg(node, definition, dialogue_items, action_buttons, "special_event", is_new_cg)
	add_dialogue_playback_controls()

func show_advanced_referral_node(event: RefCounted, step: Dictionary, node: Dictionary) -> void:
	screen = "special_event"
	var presentation := str(node.get("presentation", "advanced_surgery"))
	var heading := tx("ui.advanced_referral.day2", "ADVANCED REFERRAL — DAY 2")
	if presentation == "advanced_surgery":
		heading = tx("ui.advanced_referral.surgery", "ADVANCED SURGERY")
	base(heading, str(step.title), true, node.get("background_id", step.background_id))
	pause_dialogue_for_choice()
	var procedure := game.surgery_definition(str(node.get("procedure_id", "")))
	var procedure_name := str(procedure.get("name", tx("ui.advanced_referral.procedure", "开胸人工心脏系统置换")))
	var procedure_label := label_at(procedure_name, Vector2(60, 176), 26, Color("f4f0e6"), 1160)
	procedure_label.name = "AdvancedReferralProcedure"
	var prompt_y := 220.0
	if presentation == "advanced_surgery":
		var stage_number := int(node.get("stage_number", 1))
		var stage_label := label_at(tx("ui.advanced_referral.stage", "SURGICAL STAGE %s / 8") % stage_number, Vector2(60, 214), 18, Color("e8cfaa"), 1160)
		stage_label.name = "AdvancedReferralStage"
		prompt_y = 248.0
	var prompt_panel := Panel.new()
	prompt_panel.name = "AdvancedReferralPromptPanel"
	prompt_panel.position = Vector2(45, prompt_y - 10.0)
	prompt_panel.size = Vector2(1190, 137)
	prompt_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt_panel.add_theme_stylebox_override("panel", panel_style(Color(0.035, 0.10, 0.14, 0.88), Color("819593")))
	page.add_child(prompt_panel)
	var prompt := scrollable_text_at(str(node.text), Vector2(60, prompt_y), Vector2(1160, 115), 25, Color("fffaf0"), "AdvancedReferralPrompt")
	prompt.add_theme_font_override("normal_font", emphasized_font(0.75))
	var visible_index := 0
	for choice in node.get("choices", []):
		if not game.special_requirements_met(choice.get("requirements", [])):
			continue
		var choice_button := button_at(str(choice.label), Vector2(60, 390 + visible_index * 68), Vector2(1160, 56), choose_special_event.bind(str(choice.id)))
		choice_button.name = "AdvancedReferralChoice_" + str(choice.id)
		choice_button.add_theme_font_override("font", emphasized_font(0.45))
		choice_button.add_theme_font_size_override("font_size", 21)
		visible_index += 1
	button_at(tx("ui.auto.fadf24dbc5a9", "保存"), Vector2(60, 713), Vector2(120, 40), save_progress)
	button_at(tx("ui.auto.cdee65fb906e", "读档"), Vector2(194, 713), Vector2(120, 40), request_load)

func choose_special_event(choice_id: String) -> void:
	var result: Dictionary = game.choose_special_event(choice_id)
	if not bool(result.accepted):
		show_notice(tx("ui.auto.5727cb5318df", "这个选项当前不可用。"))
		return
	if bool(result.day_finished):
		var next_action: Callable = show_special_event_complete if bool(result.event_finished) else show_special_event
		show_day_transition(next_action)
	else:
		show_special_event()

func show_special_event_complete() -> void:
	var event = game.active_special_event
	if event == null:
		show_special_events()
		return
	screen = "special_event_complete"
	base(tx("ui.auto.fda784039855", "特殊活动完成"), str(event.definition.title), false, event.current_step().get("background_id", "lobby"))
	label_at(tx("ui.auto.4a39afe64504", "活动的全部日程已经完成。"), Vector2(110, 260), 34, Color("f4f0e6"), 1060).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var time_summary := tx("ui.special_event.zero_time_complete", "不消耗游戏时间　/　现在是 %s %s") % [game.day_text(), game.clock_text()] if not bool(event.definition.get("consumes_full_day", true)) else tx("ui.auto.4c7e14cb5767", "耗时 %s 天　/　现在是 %s %s") % [event.definition.duration_days, game.day_text(), game.clock_text()]
	label_at(time_summary, Vector2(110, 350), 22, Color("e8cfaa"), 1060).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if bool(event.definition.gallery_unlock):
		label_at(tx("ui.auto.779b69fdeeb5", "已收录至事件鉴赏。"), Vector2(110, 410), 20, Color("c2d2cc"), 1060).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var completion_hint := str(event.definition.get("completion_hint", ""))
	if not completion_hint.is_empty():
		label_at(completion_hint, Vector2(110, 452), 19, Color("d8e6c8"), 1060).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button_at(tx("ui.special_event.return_to_hospital", "返回医院  →"), Vector2(475, 510), Vector2(330, 58), finish_special_event_and_return)

func finish_special_event_and_return() -> void:
	game.finish_special_event()
	var return_location := special_event_return_location
	special_event_return_location = ""
	if not return_location.is_empty():
		show_location(return_location, true, false)
	else:
		show_map()

func clock_from_minutes(minutes: int) -> String:
	return "%02d:%02d" % [minutes / 60, minutes % 60]

func show_event_gallery(return_location: String = "") -> void:
	screen = "event_gallery"
	gallery_return_location = return_location
	gallery_replay_event = null
	gallery_replay_is_test = false
	special_event_gallery_replay = null
	base(tx("ui.gallery.title", "事件鉴赏"), tx("ui.gallery.subtitle", "人物事件、特殊活动与首次岗位担当回忆 / EVENT MEMORIES"), false, "staff_lounge")
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
	var role_rewards: Array = game.staff_role_cg_definitions.values()
	role_rewards.sort_custom(func(a: Dictionary, b: Dictionary):
		if a.staff_id != b.staff_id:
			return a.staff_id < b.staff_id
		return a.role_id < b.role_id)
	var special_definitions: Array = game.special_event_definitions.values().filter(func(item: Dictionary): return not bool(item.get("developer_only", false)) and bool(item.get("gallery_unlock", false)))
	special_definitions.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.id) < str(b.id))
	var row_count := ceili(float(definitions.size() + special_definitions.size() + role_rewards.size()) / 2.0)
	gallery_content.custom_minimum_size = Vector2(1170, max(450, row_count * 105 + 15))
	gallery_scroll.add_child(gallery_content)
	for i in range(definitions.size()):
		var definition: Dictionary = definitions[i]
		var unlocked := game.character_event_done(definition.id)
		var actor: Dictionary = content.find_record("staff", definition.actor_id)
		var caption := "%s　%s" % [actor.name, definition.title] if unlocked else tx("ui.gallery.locked", "？？？　未解锁")
		var column := i % 2
		var row := i / 2
		var entry := button_at(caption, Vector2.ZERO, Vector2(555, 78), show_gallery_entry.bind(definition.id))
		page.remove_child(entry)
		gallery_content.add_child(entry)
		entry.position = Vector2(15 + column * 595, 15 + row * 105)
		entry.name = "GalleryEvent_" + definition.id
		entry.disabled = not unlocked
	for i in range(special_definitions.size()):
		var definition: Dictionary = special_definitions[i]
		var unlocked := game.special_event_gallery_unlocked(str(definition.id))
		var caption := tx("ui.gallery.special", "特别活动　%s") % str(definition.gallery_entry.title) if unlocked else tx("ui.gallery.locked", "？？？　未解锁")
		var entry_index := definitions.size() + i
		var column := entry_index % 2
		var row := entry_index / 2
		var entry := button_at(caption, Vector2.ZERO, Vector2(555, 78), show_special_gallery_entry.bind(str(definition.id)))
		page.remove_child(entry)
		gallery_content.add_child(entry)
		entry.position = Vector2(15 + column * 595, 15 + row * 105)
		entry.name = "GallerySpecial_" + str(definition.id)
		entry.disabled = not unlocked
	for i in range(role_rewards.size()):
		var reward: Dictionary = role_rewards[i]
		var unlocked := game.staff_role_cg_unlocked(str(reward.id))
		var actor: Dictionary = content.find_record("staff", str(reward.staff_id))
		var caption := "%s　%s" % [actor.name, reward.title] if unlocked else tx("ui.gallery.locked", "？？？　未解锁")
		var entry_index := definitions.size() + special_definitions.size() + i
		var column := entry_index % 2
		var row := entry_index / 2
		var entry := button_at(caption, Vector2.ZERO, Vector2(555, 78), show_staff_role_gallery_entry.bind(str(reward.id)))
		page.remove_child(entry)
		gallery_content.add_child(entry)
		entry.position = Vector2(15 + column * 595, 15 + row * 105)
		entry.name = "GalleryRole_" + str(reward.id)
		entry.disabled = not unlocked
	label_at(tx("ui.gallery.note", "人物事件与特殊活动在完成后收录；岗位CG在角色第一次担任对应岗位时解锁。"), Vector2(65, 650), 18, Color("d8d8c7"), 980)
	var return_action: Callable = show_location.bind(gallery_return_location, true, false) if not gallery_return_location.is_empty() else show_map
	button_at(tx("ui.common.return_office", "← 返回办公室") if not gallery_return_location.is_empty() else tx("ui.common.return_map", "← 医院导览"), Vector2(1015 if not gallery_return_location.is_empty() else 1030, 88), Vector2(200 if not gallery_return_location.is_empty() else 185, 44), return_action)

func show_staff_role_gallery_entry(reward_id: String) -> void:
	if not game.staff_role_cg_unlocked(reward_id):
		show_notice(tx("ui.gallery.role_locked", "这个岗位回忆尚未解锁。"))
		return
	var reward: Dictionary = game.staff_role_cg_definitions.get(reward_id, {})
	if reward.is_empty():
		show_event_gallery(gallery_return_location)
		return
	screen = "staff_role_gallery_entry"
	var actor: Dictionary = content.find_record("staff", str(reward.staff_id))
	base(str(reward.title), "%s / ROLE MEMORY" % actor.name, true, "operating_room")
	var path := str(reward.get("path", ""))
	if not path.is_empty() and FileAccess.file_exists("res://" + path):
		var cg := TextureRect.new()
		cg.name = "StaffRoleGalleryCG"
		cg.texture = load("res://" + path)
		cg.position = Vector2(560, 175)
		cg.size = Vector2(635, 455)
		cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		page.add_child(cg)
	label_at(tx("ui.gallery.first_role", "岗位首次担当"), Vector2(65, 235), 18, Color("cbbc9c"), 430)
	label_at(actor.name, Vector2(65, 275), 30, Color("f4f0e6"), 430)
	var caption := label_at(str(reward.caption), Vector2(65, 355), 22, Color("e8cfaa"), 430)
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.size = Vector2(430, 105)
	label_at(tx("ui.gallery.role_note", "鉴赏不会消耗时间，也不会重复触发解锁演出。"), Vector2(65, 480), 18, Color("d8d8c7"), 430)
	button_at(tx("ui.gallery.return", "← 返回鉴赏"), Vector2(60, 545), Vector2(240, 55), show_event_gallery.bind(gallery_return_location))

func show_special_gallery_entry(event_id: String) -> void:
	if not game.special_event_gallery_unlocked(event_id):
		show_notice(tx("ui.gallery.special_locked", "这个特殊活动尚未解锁。"))
		return
	var definition: Dictionary = game.special_event_definitions.get(event_id, {})
	if definition.is_empty():
		show_event_gallery(gallery_return_location)
		return
	screen = "special_gallery_entry"
	base(str(definition.gallery_entry.title), "SPECIAL EVENT MEMORY", false, "staff_lounge")
	label_at(str(definition.title), Vector2(80, 220), 32, Color("f4f0e6"), 1080)
	label_at(tx("ui.auto.df005387cfe8", "%s · %s 天") % [str(definition.category), definition.duration_days], Vector2(80, 280), 20, Color("e8cfaa"), 1080)
	label_at(tx("ui.gallery.chapters", "章节"), Vector2(80, 350), 20, Color("c2d2cc"), 150)
	for i in range(definition.gallery_entry.chapters.size()):
		label_at("%s. %s" % [i + 1, definition.gallery_entry.chapters[i]], Vector2(180, 350 + i * 42), 21, Color("f4f0e6"), 850)
	label_at(tx("ui.gallery.special_replay_note", "回想模式不会推进日期，也不会修改关系、统计、资源或故事旗标。"), Vector2(80, 560), 18, Color("d8d8c7"), 1000)
	button_at(tx("ui.gallery.full_replay", "完整回放  →"), Vector2(60, 630), Vector2(270, 55), replay_special_gallery_entry.bind(event_id))
	button_at(tx("ui.gallery.return", "← 返回鉴赏"), Vector2(350, 630), Vector2(240, 55), show_event_gallery.bind(gallery_return_location))

func replay_special_gallery_entry(event_id: String) -> void:
	if not game.special_event_gallery_unlocked(event_id):
		return
	var definition: Dictionary = game.special_event_definitions[event_id]
	var steps := {}
	for step_id in definition.event_chain:
		steps[str(step_id)] = game.special_event_step_definitions[str(step_id)]
	special_event_gallery_replay = SpecialEvent.new(definition, steps, 1)
	special_event_replay_last_cg_path = ""
	reset_dialogue_page()
	show_special_gallery_replay()

func show_special_gallery_replay() -> void:
	if special_event_gallery_replay == null:
		show_event_gallery(gallery_return_location)
		return
	if special_event_gallery_replay.completed:
		show_special_gallery_entry(str(special_event_gallery_replay.definition.id))
		return
	var event = special_event_gallery_replay
	var step: Dictionary = event.current_step()
	var node: Dictionary = event.current()
	screen = "special_gallery_replay"
	base(tx("ui.gallery.replay_prefix", "回想 · ") + str(event.definition.title), tx("ui.gallery.special_replay_subtitle", "%s / 第 %s 章 / 不影响当前进度") % [step.title, event.step_index + 1], true, step.background_id)
	var cg_path := str(node.get("cg_path", ""))
	var is_new_cg := not cg_path.is_empty() and cg_path != special_event_replay_last_cg_path
	special_event_replay_last_cg_path = cg_path
	add_special_event_visual(node)
	var actor := special_event_actor(node)
	var source_role := str(node.get("speaker", "narrator"))
	var default_speaker := special_event_speaker(node, actor)
	var dialogue := dialogue_page("special_replay:%s:%s:%s" % [str(event.definition.id), str(step.id), str(node.id)], str(node.text), bool(node.get("allow_dialogue_scroll", false)))
	var presentation := dialogue_page_presentation(default_speaker, source_role, str(dialogue.text), str(actor.get("name", "")))
	var dialogue_items := vn_dialogue_box(str(presentation.speaker), str(presentation.text), "SpecialEventReplayDialogue", bool(dialogue.allow_scroll))
	var action_buttons: Array = []
	if bool(dialogue.has_more):
		var page_button := button_at(tx("ui.common.continue", "继续  ▷"), Vector2(60, VN_SINGLE_ACTION_Y), Vector2(655, 54), advance_dialogue_page.bind(show_special_gallery_replay))
		page_button.name = "SpecialReplayDialogueContinue"
		action_buttons.append(page_button)
		register_dialogue_continue(page_button, str(presentation.text), 0.7 if is_new_cg else 0.0)
		var early_exit_button := button_at(tx("ui.gallery.exit_replay", "退出回想"), Vector2(60, 713), Vector2(180, 40), show_special_gallery_entry.bind(str(event.definition.id)))
		action_buttons.append(early_exit_button)
		delay_special_event_content_for_cg(node, event.definition, dialogue_items, action_buttons, "special_gallery_replay", is_new_cg)
		add_dialogue_playback_controls()
		return
	var only_choice_button: Button
	for i in range(node.get("choices", []).size()):
		var choice: Dictionary = node.choices[i]
		var button := button_at(vn_choice_label(str(choice.label), node.choices.size()), Vector2(60, vn_choice_y(node.choices.size(), i)), Vector2(655, 54), choose_special_gallery_replay.bind(str(choice.id)))
		button.name = "SpecialReplayChoice_" + str(choice.id)
		action_buttons.append(button)
		only_choice_button = button
	if node.get("choices", []).size() == 1:
		register_dialogue_continue(only_choice_button, str(presentation.text), 0.7 if is_new_cg else 0.2)
	else:
		pause_dialogue_for_choice()
	var exit_button := button_at(tx("ui.gallery.exit_replay", "退出回想"), Vector2(60, 713), Vector2(180, 40), show_special_gallery_entry.bind(str(event.definition.id)))
	action_buttons.append(exit_button)
	delay_special_event_content_for_cg(node, event.definition, dialogue_items, action_buttons, "special_gallery_replay", is_new_cg)
	add_dialogue_playback_controls()

func choose_special_gallery_replay(choice_id: String) -> void:
	if special_event_gallery_replay == null or not special_event_gallery_replay.apply(choice_id):
		return
	show_special_gallery_replay()

func show_gallery_entry(event_id: String) -> void:
	if not game.character_event_done(event_id):
		show_notice(tx("ui.gallery.event_locked", "这个事件尚未解锁。"))
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
		label_at(tx("ui.gallery.cg_pending", "专属CG素材待制作"), Vector2(65, 275), 30, Color("f4f0e6"), 570)
	var gallery_caption := label_at(gallery.caption, Vector2(65, 365), 23, Color("e8cfaa"), 500)
	gallery_caption.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	gallery_caption.size = Vector2(500, 58)
	var gallery_note := label_at(tx("ui.gallery.replay_note", "回想模式不会消耗时间，也不会再次改变关系数值。"), Vector2(65, 430), 18, Color("d8d8c7"), 500)
	gallery_note.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	gallery_note.size = Vector2(500, 52)
	button_at(tx("ui.gallery.replay_event", "回想事件  →"), Vector2(60, 520), Vector2(270, 55), replay_gallery_entry.bind(event_id))
	button_at(tx("ui.gallery.return", "← 返回鉴赏"), Vector2(350, 520), Vector2(240, 55), show_event_gallery.bind(gallery_return_location))

func replay_gallery_entry(event_id: String) -> void:
	if not game.character_event_done(event_id):
		return
	gallery_replay_event = CharacterEvent.new(game.character_event_definitions[event_id])
	gallery_replay_is_test = false
	reset_dialogue_page()
	show_gallery_replay()

func show_gallery_replay() -> void:
	if gallery_replay_event == null:
		show_event_gallery(gallery_return_location)
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
	base((tx("ui.gallery.test_prefix", "测试 · ") if gallery_replay_is_test else tx("ui.gallery.replay_prefix", "回想 · ")) + str(definition.title), tx("ui.gallery.replay_subtitle", "%s / 不影响当前进度") % actor_name, true, definition.background_id)
	add_character_event_visual(actor, node, definition.outfit)
	var source_role := str(node.get("speaker", "actor"))
	var speaker: String = str(node.get("speaker_label", {"actor": actor_name, "player": protagonist_name(), "narrator": tx("ui.common.narrator", "旁白")}.get(source_role, actor_name)))
	var dialogue := dialogue_page("character_replay:%s:%s" % [str(definition.id), str(node.id)], str(node.text), bool(node.get("allow_dialogue_scroll", false)))
	var presentation := dialogue_page_presentation(speaker, source_role, str(dialogue.text), actor_name)
	label_at(str(presentation.speaker), Vector2(65, 205), 22, Color("e8cfaa"), 640)
	var replay_text := scrollable_text_at(str(presentation.text), Vector2(65, 253), Vector2(655, 170), 24, Color("f4f0e6"), "GalleryReplayDialogue")
	replay_text.scroll_active = bool(dialogue.allow_scroll)
	var exit_action: Callable = show_character_events.bind(gallery_replay_return_actor, character_event_return_location) if gallery_replay_is_test else show_gallery_entry.bind(definition.id)
	if bool(dialogue.has_more):
		var continue_button := button_at(tx("ui.common.continue", "继续  ▷"), Vector2(60, 445), Vector2(655, 54), advance_dialogue_page.bind(show_gallery_replay))
		continue_button.name = "ReplayDialogueContinue"
		register_dialogue_continue(continue_button, str(presentation.text))
		button_at(tx("ui.gallery.exit_test", "退出测试") if gallery_replay_is_test else tx("ui.gallery.exit_replay", "退出回想"), Vector2(60, 713), Vector2(180, 40), exit_action)
		add_dialogue_playback_controls()
		return
	var only_choice_button: Button
	for i in range(node.choices.size()):
		var choice: Dictionary = node.choices[i]
		var choice_button := button_at(choice.label, Vector2(60, 445 + i * 66), Vector2(655, 54), choose_gallery_replay.bind(choice.id))
		choice_button.name = "ReplayChoice_" + choice.id
		only_choice_button = choice_button
	if node.choices.size() == 1:
		register_dialogue_continue(only_choice_button, str(presentation.text), 0.2)
	else:
		pause_dialogue_for_choice()
	button_at(tx("ui.gallery.exit_test", "退出测试") if gallery_replay_is_test else tx("ui.gallery.exit_replay", "退出回想"), Vector2(60, 713), Vector2(180, 40), exit_action)
	add_dialogue_playback_controls()

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
	var outfit_name: String = {"outpatient": tx("ui.auto.0fd7b6d4d8e1", "门诊着装"), "ward": tx("ui.auto.6b811b46c8fe", "病房着装"), "operating_table": tx("ui.auto.2cdcb32aefa5", "手术台 · 仰卧位"), "operating_table_lithotomy": tx("ui.auto.f2ac62080844", "手术台 · 截石位")}.get(outfit, outfit)
	base(patient.name, tx("ui.auto.e66b8af542b3", "%s岁 / %s") % [patient.age, outfit_name], true, "clinic")
	add_portrait(patient, expression, outfit)
	var portrait = page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(740, 165)
		portrait.size = Vector2(470, 500)
	label_at(case_data.title, Vector2(65, 240), 28, Color("f4f0e6"), 640)
	var expression_names := {"neutral": tx("ui.auto.85dc6e7aed2b", "平静"), "smile": tx("ui.auto.cdd57ddef6ed", "微笑"), "brave": tx("ui.auto.884cde808c5b", "强装镇定"), "worried": tx("ui.auto.6c2f71e6fc38", "担忧"), "afraid": tx("ui.auto.8f9a55ccb3c6", "害怕"), "crying": tx("ui.auto.488ba5bc44d8", "哭泣"), "awake": tx("ui.auto.607f49da6ad3", "清醒"), "tense": tx("ui.auto.168469b0bac9", "紧张"), "anesthetized": tx("ui.auto.40153582e226", "麻醉后")}
	label_at(outfit_name + " · " + expression_names.get(expression, expression), Vector2(65, 325), 22, Color("cbbc9c"), 640)
	button_at(tx("ui.auto.0fd7b6d4d8e1", "门诊着装"), Vector2(65, 400), Vector2(190, 44), show_patient.bind(id, "outpatient"))
	if patient.visuals.portraits.has("ward/neutral"):
		button_at(tx("ui.auto.6b811b46c8fe", "病房着装"), Vector2(275, 400), Vector2(190, 44), show_patient.bind(id, "ward"))
	if patient.visuals.portraits.has("operating_table/awake"):
		button_at(tx("ui.auto.e123d23bbc11", "手术台"), Vector2(485, 400), Vector2(190, 44), show_patient.bind(id, "operating_table", "awake"))
	if patient.visuals.portraits.has("operating_table_lithotomy/awake"):
		button_at(tx("ui.auto.89d6df9f4cbc", "截石位"), Vector2(695, 400), Vector2(190, 44), show_patient.bind(id, "operating_table_lithotomy", "awake"))
	var expressions: Array[String] = []
	for key in patient.visuals.portraits:
		if key.get_slice("/", 0) == outfit:
			expressions.append(key.get_slice("/", 1))
	for i in range(expressions.size()):
		var value := expressions[i]
		var button := button_at(expression_names.get(value, value), Vector2(65 + (i % 3) * 205, 465 + (i / 3) * 50), Vector2(190, 40), show_patient.bind(id, outfit, value))
		button.name = "PatientExpression_" + value
		button.disabled = value == expression
	button_at(tx("ui.auto.ee72d027cb68", "← 返回门诊"), Vector2(1020, 88), Vector2(195, 44), show_location.bind("clinic"))

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
	var continue_button := button_at(tx("ui.auto.dbc7e5ecc8d6", "查看结果  →"), Vector2(1020, 690), Vector2(205, 52), continue_examination_cg)
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

func ward_preparation_cg_pool_for(action_id: String, patient_id: String, procedure_group: String = "") -> Dictionary:
	var selected: Dictionary = {}
	var selected_score := -1
	for pool in content.collections.get("ward_preparation_cg_pools", []):
		if not pool.action_ids.has(action_id):
			continue
		var patient_ids: Array = pool.patient_ids
		if not patient_ids.is_empty() and not patient_ids.has(patient_id):
			continue
		var procedure_groups: Array = pool.get("procedure_groups", [])
		if not procedure_groups.is_empty() and not procedure_groups.has(procedure_group):
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
	title.text = str(pool.get("label", tx("ui.auto.879c173632b0", "病房术前准备")))
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
	continue_button.text = tx("ui.auto.78bfd29b9e5f", "继续准备  →")
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
	var continue_button := button_at(tx("ui.auto.78bfd29b9e5f", "继续准备  →"), Vector2(1010, 690), Vector2(215, 52), continue_ward_preparation_cg)
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
	var continue_button := button_at(tx("ui.auto.45095cef1d7e", "查看手术结果  →"), Vector2(985, 690), Vector2(240, 52), continue_surgery_cg)
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

func show_preop_with_anesthesia_splash(id: String, anesthesia_kind: String = "general") -> void:
	show_preop(id)
	var preparation = game.preops.get(id)
	if preparation != null:
		show_anesthesia_splash(preparation, anesthesia_kind)

func anesthesia_splash_kind_for_action(action_id: String) -> String:
	if action_id == "choose_general":
		return "general_pre_induction"
	if action_id in ["induction_reassure", "induction_brief"]:
		return "general"
	if action_id == "choose_epidural":
		return "epidural"
	return ""

func show_anesthesia_splash(preparation: RefCounted, anesthesia_kind: String = "general") -> void:
	var patient: Dictionary = content.find_record("patients", preparation.definition.patient_id)
	var is_epidural := anesthesia_kind == "epidural"
	var is_pre_induction := anesthesia_kind == "general_pre_induction"
	var portrait_key := "splash/epidural_anesthesia" if is_epidural else "splash/general_anesthesia_pre_induction" if is_pre_induction else "splash/general_anesthesia"
	var path: String = str(patient.get("visuals", {}).get("portraits", {}).get(portrait_key, ""))
	if path.is_empty():
		return
	var overlay := Control.new()
	overlay.name = "EpiduralAnesthesiaSplash" if is_epidural else "GeneralAnesthesiaPreInductionSplash" if is_pre_induction else "GeneralAnesthesiaSplash"
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
	cg.name = "EpiduralAnesthesiaSplashCG" if is_epidural else "GeneralAnesthesiaPreInductionSplashCG" if is_pre_induction else "GeneralAnesthesiaSplashCG"
	cg.position = Vector2(22, 22)
	cg.size = Vector2(846, 476)
	cg.texture = load("res://" + path)
	cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(cg)
	var title := Label.new()
	var phase_title := tx("ui.auto.e397774165ab", "硬膜外麻醉完成") if is_epidural else tx("ui.auto.755381afd6e2", "全身麻醉诱导开始") if is_pre_induction else tx("ui.auto.bf8b096fee17", "全身麻醉诱导完成")
	title.text = "%s · %s" % [patient.name, phase_title]
	title.position = Vector2(30, 516)
	title.size = Vector2(560, 34)
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", Color("e8cfaa"))
	frame.add_child(title)
	var caption := Label.new()
	caption.text = tx("ui.auto.1f68aaa68a78", "她保持侧卧并蜷起身体。硬膜外麻醉完成后，她仍然清醒，等待团队继续术前准备。") if is_epidural else tx("ui.auto.4679a12cc360", "麻醉面罩刚刚覆上她的口鼻。她仍睁着眼，把意识交给药物以前等待坂口最后一句回应。") if is_pre_induction else tx("ui.auto.659bf690305a", "麻醉面罩覆住她的口鼻。她闭上眼睛，呼吸逐渐变得平稳。")
	caption.position = Vector2(30, 557)
	caption.size = Vector2(590, 60)
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_size_override("font_size", 19)
	caption.add_theme_color_override("font_color", Color("f4f0e6"))
	frame.add_child(caption)
	var continue_button := Button.new()
	continue_button.name = "AnesthesiaSplashContinue"
	continue_button.text = tx("ui.auto.a24257548c6a", "确认麻醉效果，继续准备  →") if is_epidural else tx("ui.auto.c3273eb181b8", "继续诱导  →") if is_pre_induction else tx("ui.auto.5b0b3e4f2315", "确认监护，开始手术  →")
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
		show_notice(tx("ui.auto.0845c83b385c", "未找到病例内容。"))
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
		var was_completed: bool = visit.completed()
		var visual_pool_id := examination_visual_for_choice(visit, id)
		if game.apply_clinic_action(id):
			var crossed_day := game.settle_overtime(before_elapsed, visit.minutes - before_minutes)
			if crossed_day:
				game.pending_encounter_day_transition = true
			var next_view := show_encounter.bind(game.active_id)
			var destination: Callable = next_view
			if visit.completed() and game.pending_encounter_day_transition:
				game.pending_encounter_day_transition = false
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
	show_save_slots("save", false)

func request_load() -> void:
	if not saves.any_exists():
		show_notice(tx("ui.save.none", "还没有存档，请先保存进度。"))
		return
	show_save_slots("load", false)

func show_save_slots(mode: String, from_title: bool = false) -> void:
	save_slot_mode = mode
	screen = "save_slots"
	base(tx("ui.save.title", "保存进度") if mode == "save" else tx("ui.load.title", "读取存档"), tx("ui.save.subtitle", "8 个独立存档位置 / 旧版单存档自动保留在位置 1"), false, "player_office")
	for index in range(SaveStore.SLOT_COUNT):
		var slot := index + 1
		var column := index % 2
		var row := index / 2
		var pos := Vector2(60 + column * 610, 188 + row * 122)
		var summary := saves.slot_summary(slot)
		var occupied: bool = bool(summary.get("exists", false))
		var valid: bool = bool(summary.get("valid", false))
		var title := tx("ui.save.slot", "位置 %02d") % slot
		if slot == active_save_slot:
			title += tx("ui.save.current", "　● 当前")
		label_at(title, pos, 22, Color("e8cfaa"), 210)
		var detail := tx("ui.save.empty", "空存档")
		if occupied and not valid:
			detail = tx("ui.save.invalid", "存档损坏或无法读取")
		elif occupied:
			var patient_name := ""
			var patient_id := str(summary.get("patient_id", ""))
			if not patient_id.is_empty():
				patient_name = str(content.find_record("patients", patient_id).get("name", ""))
			var saved_day := int(summary.get("day", 0))
			var saved_calendar := localized_calendar_text(saved_day, true) if saved_day > 0 else str(summary.get("calendar", tx("ui.save.legacy", "旧版存档")))
			var progress_line := "%s  %s" % [saved_calendar, summary.get("clock", "")]
			if not patient_name.is_empty():
				progress_line += tx("ui.save.current_patient", "  /  当前候诊：%s") % patient_name
			detail = tx("ui.save.detail", "%s\n已完成手术 %d  /  保存于 %s") % [progress_line, int(summary.get("completed_surgeries", 0)), summary.get("saved_at", "")]
		var detail_label := label_at(detail, pos + Vector2(0, 34), 16, Color("c2d2cc") if valid or not occupied else Color("e59a92"), 430)
		detail_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		detail_label.size = Vector2(430, 65)
		var action_text := tx("ui.save.overwrite", "覆盖保存") if mode == "save" and occupied else tx("ui.common.save", "保存") if mode == "save" else tx("ui.common.load", "读取")
		var action := button_at(action_text, pos + Vector2(445, 18), Vector2(120, 58), choose_save_slot.bind(slot))
		action.name = "SaveSlot_%d" % slot
		action.disabled = mode == "load" and (not occupied or not valid)
	button_at(tx("ui.common.return_title_arrow", "← 返回标题") if from_title else tx("ui.common.return_game", "← 返回游戏"), Vector2(60, 700), Vector2(200, 43), title_screen if from_title else resume_progress)

func choose_save_slot(slot: int) -> void:
	if save_slot_mode == "save":
		if saves.exists(slot):
			confirm_action(tx("ui.save.overwrite_confirm", "位置 %d 已有存档。要用当前进度覆盖吗？") % slot, write_save_slot.bind(slot))
		else:
			write_save_slot(slot)
		return
	confirm_action(tx("ui.load.confirm", "读取位置 %d 将替换当前未保存的进度。") % slot, load_progress.bind(slot))

func write_save_slot(slot: int) -> void:
	if saves.write_slot(game, slot):
		active_save_slot = slot
		show_save_slots("save", false)
		show_notice(tx("ui.save.success", "已保存到位置 %d。") % slot)
	else:
		show_notice(saves.last_error)

func load_progress(slot: int = 1) -> void:
	if not saves.read_slot(game, slot):
		show_notice(saves.last_error)
		return
	active_save_slot = slot
	reset_clinic_view()
	resume_progress()

func show_notice(message: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = tx("ui.dialog.title", "星见医院")
	dialog.dialog_text = message
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered(Vector2i(580, 170))

func confirm_action(message: String, action: Callable) -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = tx("ui.dialog.confirm_title", "确认操作")
	dialog.dialog_text = message
	dialog.ok_button_text = tx("ui.dialog.confirm", "确认")
	dialog.cancel_button_text = tx("ui.dialog.cancel", "取消")
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
		show_notice(tx("ui.auto.213523852b56", "这名患者当前不能转诊。"))
		return
	var patient: Dictionary = content.find_record("patients", patient_id)
	var case_data: Dictionary = game.patient_case(patient_id)
	screen = "referral"
	base(tx("ui.auto.9d787e12e280", "安排转诊"), "%s · %s岁　/　%s" % [patient.name, patient.age, case_data.get("title", tx("ui.auto.7b6344d0158d", "当前病例"))], false, "clinic")
	label_at(tx("ui.auto.24f6d87be6cb", "选择一名医生接手这名患者。已完成的门诊记录会一并交接。"), Vector2(60, 205), 23, Color("f4f0e6"), 650)
	add_portrait(patient, "neutral", "outpatient")
	var portrait = page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(790, 190)
		portrait.size = Vector2(390, 430)
	var doctor_picker := OptionButton.new()
	doctor_picker.name = "ReferralDoctorPicker"
	doctor_picker.position = Vector2(60, 285)
	doctor_picker.size = Vector2(665, 64)
	doctor_picker.add_item(tx("ui.referral.choose_doctor", "请选择接诊医生"))
	doctor_picker.set_item_disabled(0, true)
	doctor_picker.set_item_metadata(0, "")
	var known_doctor_count := 0
	for doctor in content.collections.staff:
		if doctor.profession != "doctor" or not game.staff_is_met(str(doctor.id)):
			continue
		var caption := tx("ui.referral.doctor_compact", "%s　/　%s") % [doctor.name, doctor.specialty]
		doctor_picker.add_item(caption)
		known_doctor_count += 1
		doctor_picker.set_item_metadata(known_doctor_count, str(doctor.id))
	doctor_picker.select(0)
	page.add_child(doctor_picker)
	var confirm_button := button_at(tx("ui.referral.confirm", "确认转诊"), Vector2(60, 375), Vector2(320, 58), complete_referral_from_picker.bind(patient_id, doctor_picker))
	confirm_button.name = "ReferralConfirm"
	confirm_button.disabled = true
	doctor_picker.item_selected.connect(func(index: int): confirm_button.disabled = index <= 0)
	if known_doctor_count == 0:
		label_at(tx("ui.referral.no_known_doctors", "目前还没有可接收转诊的相识医生。"), Vector2(60, 455), 20, Color("e8cfaa"), 665)
	button_at(tx("ui.auto.ee72d027cb68", "← 返回门诊"), Vector2(1030, 88), Vector2(185, 44), show_location.bind("clinic", true))

func complete_referral_from_picker(patient_id: String, doctor_picker: OptionButton) -> void:
	if not is_instance_valid(doctor_picker) or doctor_picker.selected <= 0:
		show_notice(tx("ui.referral.choose_doctor_notice", "请先选择一名已经认识的医生。"))
		return
	var doctor_id := str(doctor_picker.get_item_metadata(doctor_picker.selected))
	complete_referral(patient_id, doctor_id)

func complete_referral(patient_id: String, doctor_id: String) -> void:
	var patient: Dictionary = content.find_record("patients", patient_id)
	var doctor: Dictionary = content.find_record("staff", doctor_id)
	if not game.refer_current_patient(doctor_id):
		show_notice(game.last_error)
		return
	reset_clinic_view()
	var return_to_clinic := show_location.bind("clinic", true)
	if game.pending_encounter_day_transition:
		game.pending_encounter_day_transition = false
		show_day_transition(return_to_clinic)
	else:
		return_to_clinic.call()
	show_notice(tx("ui.auto.eeb678bd832d", "已将%s转诊给%s。候诊列表已切换到下一名患者。") % [patient.name, doctor.name])

func show_preop(id: String) -> void:
	var preparation = game.open_preop(id)
	if preparation == null:
		show_notice(tx("ui.auto.24be0fc34e5f", "请先完成接诊并收住院。"))
		return
	if start_character_event_from_preop_stage(str(preparation.stage_id)):
		return
	if str(preparation.current().get("kind", "")) not in ["or_table_palpation", "anesthesia_sensory_test"]:
		clear_or_table_scalpel_cursor()
	screen = "preop"
	PreopView.render(self, preparation)

func set_or_table_palpation_intensity(intensity: String) -> void:
	if intensity not in ["light", "standard", "deep"]:
		return
	or_table_palpation_intensity = intensity
	or_table_palpation_tool = "palpation"
	clear_or_table_scalpel_cursor(false)
	show_preop(game.active_preop_id)

func set_or_table_palpation_tool(tool: String) -> void:
	if tool not in ["palpation", "needle", "scalpel"]:
		return
	or_table_palpation_tool = tool
	clear_or_table_scalpel_cursor(false)
	show_preop(game.active_preop_id)

func apply_or_table_scalpel_cursor() -> void:
	apply_or_table_tool_cursor("scalpel")

func cursor_texture(path: String, size: int) -> Texture2D:
	var source: Texture2D = load(path)
	if source == null:
		return null
	var cursor_image: Image = source.get_image()
	cursor_image.resize(size, size, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(cursor_image)

func apply_or_table_tool_cursor(tool: String = "") -> void:
	var selected := or_table_palpation_tool if tool.is_empty() else tool
	match selected:
		"scalpel":
			if or_table_scalpel_cursor == null:
				or_table_scalpel_cursor = cursor_texture(OR_TABLE_SCALPEL_CURSOR_PATH, 72)
			if or_table_scalpel_cursor != null:
				Input.set_custom_mouse_cursor(or_table_scalpel_cursor, Input.CURSOR_ARROW, Vector2(8, 60))
		"needle":
			if or_table_needle_cursor == null:
				or_table_needle_cursor = cursor_texture(OR_TABLE_NEEDLE_CURSOR_PATH, 88)
			if or_table_needle_cursor != null:
				# The transparent source points down-left; use that fine point as the click hotspot.
				Input.set_custom_mouse_cursor(or_table_needle_cursor, Input.CURSOR_ARROW, Vector2(18, 76))
		_:
			if or_table_hand_cursor == null:
				or_table_hand_cursor = cursor_texture(OR_TABLE_HAND_CURSOR_PATH, 64)
			if or_table_hand_cursor != null:
				Input.set_custom_mouse_cursor(or_table_hand_cursor, Input.CURSOR_ARROW, Vector2(30, 2))

func clear_or_table_scalpel_cursor(reset_tool: bool = true) -> void:
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	if reset_tool:
		or_table_palpation_tool = "palpation"

func or_table_palpation_click(region: String) -> void:
	var preparation = game.preops.get(game.active_preop_id)
	var sensory_test := preparation != null and str(preparation.current().get("kind", "")) == "anesthesia_sensory_test"
	if or_table_palpation_tool == "scalpel":
		preop_event({"kind": "anesthesia_test_scalpel" if sensory_test else "or_table_scalpel", "region": region})
	elif sensory_test:
		preop_event({"kind": "anesthesia_sensory_test", "tool": "needle" if or_table_palpation_tool == "needle" else "hand", "region": region})
	elif or_table_palpation_tool == "needle":
		preop_event({"kind": "or_table_needle", "region": region})
	else:
		preop_event({
			"kind": "or_table_palpation",
			"region": region,
			"intensity": or_table_palpation_intensity,
		})

func sweep_surgery(procedure_id: String) -> void:
	var result := game.sweep_active_surgery(procedure_id)
	if result.is_empty():
		show_notice(game.last_error)
		return
	show_surgery_sweep_result(result)

func show_surgery_sweep_result(result: Dictionary) -> void:
	screen = "surgery_sweep_result"
	base(tx("ui.surgery.sweep_complete", "手术扫荡完成"), str(result.get("procedure_name", "")), false, "operating_room")
	var duration_minutes := int(result.get("duration_minutes", 0))
	var procedure_duration_minutes := int(result.get("procedure_duration_minutes", duration_minutes))
	var postoperative_wrap_up_minutes := int(result.get("postoperative_wrap_up_minutes", 0))
	var duration_label := tx("ui.surgery.minutes", "%s 分钟") % duration_minutes
	var procedure_duration_label := tx("ui.surgery.minutes", "%s 分钟") % procedure_duration_minutes
	if procedure_duration_minutes >= 60:
		procedure_duration_label = tx("ui.surgery.hours_minutes", "%s 小时%s 分钟") % [floori(float(procedure_duration_minutes) / 60.0), procedure_duration_minutes % 60]
	if duration_minutes >= 60:
		duration_label = tx("ui.surgery.hours_minutes", "%s 小时%s 分钟") % [floori(float(duration_minutes) / 60.0), duration_minutes % 60]
	var postoperative_label := tx("ui.surgery.minutes", "%s 分钟") % postoperative_wrap_up_minutes
	label_at(tx("ui.surgery.sweep_time_breakdown", "标准手术耗时：%s\n术后交接与整理：%s\n游戏内总耗时：%s") % [procedure_duration_label, postoperative_label, duration_label], Vector2(65, 195), 21, Color("e8cfaa"), 650)
	var xp := int(result.get("xp", 0))
	var before_level := int(result.get("level_before", 0))
	var after_level := int(result.get("level_after", before_level))
	var xp_text := tx("ui.surgery.sweep_xp", "手术经验 +%s") % xp
	if after_level > before_level:
		xp_text += tx("ui.surgery.sweep_level", "　·　技术 %s → %s") % [before_level, after_level]
	label_at(xp_text, Vector2(65, 305), 24, Color("79a9c9"), 720)
	var leadership_text := tx("ui.surgery.sweep_leadership", "领导经验 +%.1f") % float(result.get("leadership_xp", 0.0))
	if int(result.get("leadership_after", 0)) > int(result.get("leadership_before", 0)):
		leadership_text += "　·　%s → %s" % [result.leadership_before, result.leadership_after]
	label_at(leadership_text, Vector2(65, 345), 21, Color("7eb696"), 720)
	label_at(tx("ui.surgery.sweep_reputation", "专业声望 +%s") % int(result.get("reputation", 0)), Vector2(65, 385), 22, Color("b79ac8"), 720)
	var team_rewards: Array = result.get("team_rewards", [])
	label_at(tx("ui.surgery.sweep_team", "团队熟悉度"), Vector2(65, 435), 20, Color("e8cfaa"), 720)
	if team_rewards.is_empty():
		label_at(tx("ui.surgery.sweep_team_none", "本次没有可获得熟悉度的已结识成员。"), Vector2(65, 475), 19, Color("c2d2cc"), 720)
	else:
		var lines: Array[String] = []
		for reward in team_rewards:
			lines.append("%s  +%s" % [str(reward.get("name", "")), int(reward.get("familiarity", 0))])
		label_at("\n".join(lines), Vector2(65, 475), 20, Color("dce5e3"), 720)
	var return_action: Callable = show_map
	if bool(result.get("crossed_day", false)):
		return_action = show_day_transition.bind(show_map)
	var return_button := button_at(tx("ui.surgery.sweep_return", "返回医院导览 →"), Vector2(60, 650), Vector2(1155, 60), return_action)
	return_button.name = "SurgerySweepReturn"

func incision_video_path(action_id: String, procedure_group: String, _anesthetized: bool) -> String:
	if not action_id.begins_with("incise_"):
		return ""
	var pool_id := "abdominal" if procedure_group in ABDOMINAL_INCISION_PROCEDURE_GROUPS else "pelvic" if procedure_group == "female_pelvic" else "breast" if procedure_group == "breast" else "thoracic" if procedure_group in ["thoracic", "cardiac"] else ""
	return random_incision_video_from_pool(pool_id) if not pool_id.is_empty() else ""

func incision_video_should_mute(preparation: Variant) -> bool:
	# Runtime logic must use the clinical state flag. `anesthesia` is authored
	# display text and can change with localization or content edits.
	return preparation != null and preparation.flags.has("anesthetized")

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

func preop_transition_video_for(action_id: String) -> Dictionary:
	var definition: Dictionary = PREOP_TRANSITION_VIDEOS.get(action_id, {})
	if definition.is_empty() or not ResourceLoader.exists(str(definition.get("path", ""))):
		return {}
	return definition

func show_preop_transition_video(definition: Dictionary, next_action: Callable) -> void:
	var stream := load(str(definition.get("path", ""))) as VideoStream
	if stream == null:
		next_action.call()
		return
	screen = "preop_transition_video"
	preop_transition_video_next = next_action
	var shade := ColorRect.new()
	shade.name = "PreopTransitionVideoOverlay"
	shade.color = Color(0.005, 0.015, 0.02, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	page.add_child(shade)
	var video := VideoStreamPlayer.new()
	video.name = "PreopTransitionVideoPlayer"
	video.position = Vector2(264, 192)
	video.size = Vector2(752, 416)
	video.expand = true
	video.stream = stream
	video.speed_scale = float(definition.get("speed", 1.0))
	video.volume_db = -80.0
	video.finished.connect(complete_preop_transition_video)
	page.add_child(video)
	video.play()

func complete_preop_transition_video() -> void:
	if not preop_transition_video_next.is_valid():
		return
	var next_action := preop_transition_video_next
	preop_transition_video_next = Callable()
	next_action.call()

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
	label_at(tx("ui.auto.9fdae4603e33", "切口建立"), Vector2(264, 108), 27, Color("e8cfaa"), 752)
	var video := VideoStreamPlayer.new()
	video.name = "SurgeryVideoPlayer"
	video.position = Vector2(264, 158)
	video.size = Vector2(752, 416)
	video.expand = true
	video.stream = stream
	video.speed_scale = 1.25
	video.volume_db = -80.0 if muted else 0.0
	video.finished.connect(complete_surgery_video)
	page.add_child(video)
	var audio_note := tx("ui.auto.963ed772fae7", "静音播放 · 患者已接受麻醉") if muted else tx("ui.auto.b01099715a35", "保留现场声音 · 未麻醉")
	label_at(audio_note, Vector2(264, 598), 16, Color("c2d2cc"), 520)
	var skip_button := button_at(tx("ui.auto.c22ce40a5c6a", "跳过动画"), Vector2(856, 594), Vector2(160, 44), complete_surgery_video)
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

func finish_aborted_surgery_and_return() -> void:
	if game.pending_surgery_day_transition:
		show_day_transition(complete_aborted_surgery_return)
	else:
		complete_aborted_surgery_return()

func complete_aborted_surgery_return() -> void:
	game.finish_active_surgery_abort()
	show_map()

func toggle_intraoperative_crisis() -> void:
	game.set_intraoperative_crisis_enabled(not game.intraoperative_crisis_enabled)
	content.localizer.save_intraoperative_crisis_preference(game.intraoperative_crisis_enabled)
	show_player_office()

func toggle_operative_field_hud() -> void:
	operative_field_hud_enabled = not operative_field_hud_enabled
	content.localizer.save_operative_field_hud_preference(operative_field_hud_enabled)
	show_player_office()

func apply_moe_training_callback(preparation: RefCounted, action_id: String) -> void:
	if action_id != "request_scalpel" or preparation.anesthesia == "全身麻醉": # localization-invariant: authored state ID
		return
	if str(preparation.team.get("scrub_nurse", "")) != "nurse_moe":
		return
	if not game.relation_for("nurse_hiroko").get("flags", []).has("moe_training_callbacks"):
		return
	preparation.last_staff_id = "nurse_moe"
	preparation.last_staff_role = "scrub_nurse"
	preparation.feedback_speaker = "staff"
	preparation.feedback = tx("ui.preop.moe_training_callback", "本庄推着器械台走了两步，忽然像想起了什么。她停下来绕了个方向，把整排器械移到患者视线之外。\n「这个位置应该看不到了……嗯，这样比较好。」她确认患者不再盯着器械，才将手术刀稳稳递进你的掌心。")

func preop_event(event: Dictionary) -> void:
	var preparation = game.preops.get(game.active_preop_id)
	if preparation == null:
		return
	var submitted_event := event
	if event.get("kind") == "procedure" and not event.has("palpation_cg_id"):
		submitted_event = event.duplicate(true)
		submitted_event["palpation_cg_id"] = PreopView.OR_TABLE_PALPATION_IMAGES.keys().pick_random()
	elif event.get("kind") == "surgery_step" and game.intraoperative_crisis_enabled and not event.has("crisis_roll"):
		submitted_event = event.duplicate(true)
		submitted_event["crisis_roll"] = randi_range(0, 9999)
	elif event.get("kind") == "crisis_rescue" and not event.has("roll"):
		submitted_event = event.duplicate(true)
		submitted_event["roll"] = randi_range(0, 9999)
	if event.get("kind") == "action" and str(event.get("id", "")).begins_with("incise_") and not event.has("operative_background_id"):
		submitted_event = event.duplicate(true)
		submitted_event["operative_background_id"] = OperativeBackgrounds.random_id()
	var before_elapsed := game.elapsed()
	var before_minutes: int = preparation.minutes
	var action_id := str(submitted_event.get("id", ""))
	var surgery: Dictionary = preparation.current_surgery()
	var preop_transition_video: Dictionary = preop_transition_video_for(action_id)
	var incision_video := incision_video_path(action_id, str(surgery.get("procedure_group", "")), preparation.flags.has("anesthetized"))
	var incision_video_muted: bool = incision_video_should_mute(preparation)
	var anesthesia_splash_kind := anesthesia_splash_kind_for_action(action_id) if submitted_event.get("kind") == "action" else ""
	var ward_preparation_pool: Dictionary = {}
	# Once general anesthesia has taken effect, intimate preparation/action CGs
	# (catheterization, disinfection and scalpel-ready art) stay hidden. The
	# dedicated induction CG has already represented the patient's transition
	# into unconsciousness; the remaining steps use the normal OR presentation.
	if submitted_event.get("kind") == "action" and not preparation.flags.has("anesthetized"):
		ward_preparation_pool = ward_preparation_cg_pool_for(str(submitted_event.get("id", "")), str(preparation.definition.patient_id), str(surgery.get("procedure_group", "")))
	if preparation.apply(submitted_event):
		apply_moe_training_callback(preparation, action_id)
		var role_reward: Dictionary = {}
		if submitted_event.get("kind") == "assign":
			role_reward = game.unlock_staff_role_cg(str(submitted_event.get("staff_id", "")), str(submitted_event.get("role", "")))
		var crossed_day := game.settle_overtime(before_elapsed, preparation.minutes - before_minutes)
		if crossed_day:
			game.pending_surgery_day_transition = true
		var next_view: Callable = show_preop.bind(game.active_preop_id)
		if not anesthesia_splash_kind.is_empty():
			next_view = show_preop_with_anesthesia_splash.bind(game.active_preop_id, anesthesia_splash_kind)
		elif not ward_preparation_pool.is_empty():
			next_view = show_preop_with_ward_preparation_cg.bind(game.active_preop_id, ward_preparation_pool)
		elif not incision_video.is_empty():
			next_view = show_surgery_video.bind(incision_video, show_preop.bind(game.active_preop_id), incision_video_muted)
		elif not preop_transition_video.is_empty():
			next_view = show_preop_transition_video.bind(preop_transition_video, show_preop.bind(game.active_preop_id))
		var surgery_finished: bool = preparation.surgery_success and preparation.current().kind == "surgery_complete"
		if not role_reward.is_empty():
			show_staff_role_reward(role_reward, next_view)
		elif surgery_finished:
			var pool := surgery_cg_pool_for(preparation.procedure_id, preparation.definition.patient_id)
			if not pool.is_empty():
				show_surgery_cg(pool, next_view)
			else:
				next_view.call()
		elif preparation.surgery_in_progress():
			# Time spent handling intraoperative events belongs to the current
			# operation. Crossing the shift boundary must be settled only after
			# the patient reaches the surgery result and leaves the table.
			next_view.call()
		else:
			next_view.call()
	else:
		show_notice(preparation.last_error)

func show_day_transition(next_action: Callable) -> void:
	if game.day_transition_deferred():
		# Overtime has already been settled and remembered by the active clinical
		# flow.  Keep the current case continuous; its completion path will show
		# the deferred transition exactly once.
		game.remember_deferred_day_transition()
		next_action.call()
		return
	var departure := game.pending_departure_context()
	if not departure.is_empty():
		game.clear_pending_departure_context()
		if game.begin_after_work_departure(int(departure.workday), int(departure.clock), false):
			day_transition_next = next_action
			show_after_work_walk()
			return
	render_day_transition(next_action)

func render_day_transition(next_action: Callable) -> void:
	screen = "day_transition"
	day_transition_next = next_action
	base("", "", false, "hospital_night")
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.025, 0.08, 0.34)
	shade.position = Vector2(0, 0)
	shade.size = Vector2(1280, 800)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(shade)
	label_at(tx("ui.auto.76205aa9b369", "一天结束了……"), Vector2(0, 285), 46, Color("f4f0e6"), 1280).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var next_day_line := tx("ui.auto.9aad20de509f", "夜色笼罩医院。明天是星期日，可以暂时离开平日的工作节奏。") if game.is_sunday() else tx("ui.auto.c0ea84cbb5ba", "夜色笼罩医院。新的工作日将从 09:00 开始。")
	label_at(next_day_line, Vector2(0, 365), 22, Color("d7dfdf"), 1280).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button_at(tx("ui.auto.5405675b4324", "进入下一天  →"), Vector2(475, 465), Vector2(330, 58), continue_after_day_transition)

func request_end_workday() -> void:
	if not game.can_end_workday():
		show_notice(game.last_error)
		return
	var workday := game.day_number()
	var departure_clock := game.current_absolute_clock()
	if game.begin_after_work_departure(workday, departure_clock, true):
		day_transition_next = show_map
		show_after_work_walk()
		return
	game.advance_story_to_future_day(1, 9 * 60)
	render_day_transition(show_map)

func show_after_work_walk() -> void:
	var walk: Dictionary = game.active_after_work_walk
	if walk.is_empty():
		render_day_transition(day_transition_next if day_transition_next.is_valid() else show_map)
		return
	var actor: Dictionary = content.find_record("staff", str(walk.actor_id))
	if actor.is_empty():
		game.choose_after_work_walk(false)
		complete_after_work_walk()
		return
	var is_night := str(walk.variant) == "night"
	screen = "after_work_walk"
	base(
		tx("ui.after_work.night_title", "深夜下班") if is_night else tx("ui.after_work.normal_title", "下班时刻"),
		tx("ui.after_work.subtitle", "%s / 从医院走向车站") % actor.name,
		false,
		"hospital_night" if is_night else "lobby"
	)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.025, 0.08, 0.24 if is_night else 0.12)
	shade.position = Vector2.ZERO
	shade.size = Vector2(1280, 800)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(shade)
	add_portrait(actor, "neutral", after_work_outfit(actor))
	var portrait = page.get_node_or_null("CharacterPortrait")
	if portrait != null:
		portrait.position = Vector2(785, 150)
		portrait.size = Vector2(405, 485)
	var phase := str(walk.get("phase", "offer"))
	if phase == "offer":
		var encounter_text := tx("ui.after_work.night_encounter", "医院已经安静下来。%s也刚刚结束工作，独自走向出口。") % actor.name if is_night else tx("ui.after_work.normal_encounter", "离开医院时，%s也正准备下班。") % actor.name
		vn_dialogue_box(tx("ui.common.narrator", "旁白"), encounter_text, "AfterWorkDialogue")
		var invite := button_at(tx("ui.after_work.invite", "要一起走去车站吗？"), Vector2(60, 470), Vector2(655, 54), choose_after_work_walk.bind(true))
		invite.name = "AfterWorkInvite"
		var skip := button_at(tx("ui.after_work.skip", "打个招呼，各自回去"), Vector2(60, 537), Vector2(655, 54), choose_after_work_walk.bind(false))
		skip.name = "AfterWorkSkip"
		pause_dialogue_for_choice()
	else:
		var outcome := str(walk.get("outcome", "skipped"))
		var text_value := ""
		if outcome == "completed":
			text_value = tx("ui.after_work.night_accept", "\"好。这个时间有人一起走，确实安心一点。\"") if is_night else tx("ui.after_work.normal_accept", "\"可以。我正好也往车站走。\"")
		elif outcome == "declined":
			text_value = tx("ui.after_work.night_decline", "\"谢谢，不过我已经约好车了。你也早点回去。\"") if is_night else tx("ui.after_work.normal_decline", "\"今天还有一点私事。下次吧。\"")
		else:
			text_value = tx("ui.after_work.skipped", "你们在医院门口互相道别，各自踏上回程。")
		vn_dialogue_box(str(actor.name) if outcome != "skipped" else tx("ui.common.narrator", "旁白"), text_value, "AfterWorkDialogue")
		var reward := int(walk.get("reward", 0))
		if outcome == "completed":
			label_at(tx("ui.after_work.reward", "同行结束 · %s熟悉度 +%s") % [actor.name, reward], Vector2(65, 430), 20, Color("9ee2c8"), 650)
		var finish := button_at(tx("ui.after_work.finish", "结束同行，回家  →"), Vector2(60, 520), Vector2(655, 56), complete_after_work_walk)
		finish.name = "AfterWorkFinish"
		register_dialogue_continue(finish, text_value, 0.5)
	add_dialogue_playback_controls()

func choose_after_work_walk(invite: bool) -> void:
	if game.choose_after_work_walk(invite).is_empty():
		return
	show_after_work_walk()

func complete_after_work_walk() -> void:
	var completed := game.finish_after_work_walk()
	if completed.is_empty():
		return
	if bool(completed.get("advance_day_on_finish", false)):
		game.advance_story_to_future_day(1, 9 * 60)
	var next_action := day_transition_next if day_transition_next.is_valid() else show_map
	render_day_transition(next_action)

func continue_after_day_transition() -> void:
	if game.is_sunday() and not game.special_event_in_progress() and not game.active_surgery_in_progress():
		day_transition_next = Callable()
		show_sunday_menu()
		return
	if day_transition_next.is_valid():
		var next_action := day_transition_next
		day_transition_next = Callable()
		next_action.call()

func resume_progress() -> void:
	if game.active_mode == "special_event" and not game.active_special_event_id.is_empty():
		show_special_event()
	elif game.active_mode == "micro_event" and not game.active_micro_event_id.is_empty():
		show_micro_event()
	elif game.active_mode == "character_event" and not game.active_character_event_id.is_empty():
		show_character_event()
	elif game.active_mode == "preop" and not game.active_preop_id.is_empty():
		show_preop(game.active_preop_id)
	elif not game.active_id.is_empty():
		show_encounter(game.active_id)
	else:
		show_map()
