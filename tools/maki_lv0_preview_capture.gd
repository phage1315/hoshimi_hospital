extends SceneTree
## Native windowed 16:10 UI playthrough & screenshot capture for
## Maki Aizawa (`doc_maki`) Relationship Lv0 standalone onboarding event:
## 《排班表上的名字》 (`maki_lv0_onboarding`).
##
## Captures 18 live-rendered 16:10 screenshots across `zh_CN` and `en`:
## - Scene A (`shared_doctors_office`): Maki anxious arrival, Asuka & Maki OR whiteboard
## - Scene B (`or_entrance` & `scrub_area`): preop retract-strength check, Hiroko #6.5 glove welcome
## - Scene C (`operating_room`): Ryuji + Hiroko + Maki sterile time-out, Maki oblique hernia-sac observation
## - Scene D (`staff_lounge`): grid operative notebook, Choice D1, Option A & B responses
## - Scene E (`hallway`): sunset alumna conversation, tomorrow's 1st-assistant roster
## - Day-end transition (`17:50`), Lv0 colleague completion card, and post-onboarding Lounge presence
## - English (`en`) parity screenshots (Scene C, Choice D1, Scene E, Lv0 completion card)
## Also checks Choice D1 button text metrics against usable button bounds in both languages.

const EVENT_ID := "maki_lv0_onboarding"
const OUT_DIR := "docs/qa/maki_lv0_2026-11-13"

const ZH_SHOTS := {
	"mk0_005": "01_zh_scene_a_maki_arrival.png",
	"mk0_018": "02_zh_scene_a_asuka_and_maki_roster.png",
	"mk0_033": "03_zh_scene_b_preop_focused.png",
	"mk0_046": "04_zh_scene_b_hiroko_gloves_welcome.png",
	"mk0_054": "05_zh_scene_c_or_sterile_timeout.png",
	"mk0_080": "06_zh_scene_c_maki_oblique_view.png",
	"mk0_095": "07_zh_scene_d_grid_notebook.png",
	"mk0_choice_d1": "08_zh_scene_d_choice_d1.png",
	"mk0_115": "09_zh_scene_d_option_a_feedback.png",
	"mk0_135": "10_zh_scene_e_alumna_focused.png",
	"mk0_155": "11_zh_scene_e_tomorrow_roster.png",
}

const EN_SHOTS := {
	"mk0_018": "15_en_scene_a_asuka_and_maki_roster.png",
	"mk0_080": "16_en_scene_c_maki_oblique_view.png",
	"mk0_choice_d1": "17_en_scene_d_choice_d1.png",
	"mk0_120": "18_en_scene_d_option_b_smile.png",
	"mk0_135": "19_en_scene_e_alumna_focused.png",
}

var app
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func set_exact_clock(game: RefCounted, day: int, clock_min: int) -> void:
	game.set_test_time(day, clock_min)
	var expected_elapsed: int = (day - 1) * int(game.SHIFT_MINUTES) + clock_min - int(game.SHIFT_START_MINUTE)
	game.story_time_advance_minutes += expected_elapsed - int(game.elapsed())

func save_shot(filename: String) -> void:
	for child in app.page.get_children():
		if child is Button:
			child.show()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var out_path := ProjectSettings.globalize_path("res://%s/%s" % [OUT_DIR, filename])
	var img: Image = app.get_viewport().get_texture().get_image()
	expect(img != null and img.get_width() >= 1024 and absf(float(img.get_width()) / float(img.get_height()) - 1.6) < 0.02, "16:10 viewport captured for " + filename)
	var err: int = img.save_png(out_path)
	expect(err == OK, "Saved screenshot " + out_path)

func check_choice_buttons_fit(nid: String, locale: String) -> void:
	for child in app.page.get_children():
		if child is Button and str(child.name).begins_with("EventChoice_choice_"):
			var btn := child as Button
			var font := btn.get_theme_font("font")
			var fsize := btn.get_theme_font_size("font_size")
			var style := btn.get_theme_stylebox("normal")
			var usable: Vector2 = btn.size - style.get_minimum_size()
			var measured: Vector2 = font.get_multiline_string_size(btn.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize)
			expect(measured.x <= usable.x + 2.0 and measured.y <= usable.y + 2.0, "%s %s button '%s' fits (%s <= %s)" % [locale, nid, btn.name, str(measured), str(usable)])

func play_and_capture(locale: String, shot_map: Dictionary, d1_idx: int, transition_shot: String, complete_shot: String, lounge_shot: String) -> void:
	expect(app.content.load_all(locale), "load_all " + locale)
	app.configure_game_content()
	expect(app.game.prepare_character_event_test_save(EVENT_ID), locale + ": prepare_character_event_test_save")
	set_exact_clock(app.game, 38, 540) # 2025-05-08 Thu 09:00

	app.show_map(true)
	await process_frame
	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, locale + ": auto-launched maki_lv0_onboarding")

	var captured := {}
	var guard := 0
	while app.game.active_character_event_id == EVENT_ID and guard < 420:
		guard += 1
		var ev = app.game.character_events[EVENT_ID]
		if ev.completed:
			break
		var node: Dictionary = ev.current()
		var nid := str(node.get("id", ""))
		if nid == "mk0_choice_d1":
			check_choice_buttons_fit(nid, locale)
		if shot_map.has(nid) and not captured.has(nid):
			captured[nid] = true
			await save_shot(str(shot_map[nid]))
		var page_btn: Button = app.page.get_node_or_null("EventDialogueContinue")
		if page_btn != null:
			app.advance_dialogue_page(app.show_character_event)
			await process_frame
			continue
		var ch_list: Array = node.get("choices", [])
		var pick := d1_idx if nid == "mk0_choice_d1" else 0
		app.choose_character_event(str(ch_list[pick].id))
		await process_frame

	for k in shot_map.keys():
		expect(captured.has(k), locale + ": captured node " + str(k))
	expect(app.screen == "day_transition", locale + ": reached day_transition")
	if not transition_shot.is_empty():
		await save_shot(transition_shot)

	app.show_character_event_complete()
	await process_frame
	expect(app.screen == "character_event_complete", locale + ": rendered character_event_complete")
	await save_shot(complete_shot)

	app.game.finish_character_event()
	app.show_map(false)
	await process_frame
	if not lounge_shot.is_empty():
		app.location_staff_drawer_open = "lounge"
		app.show_location("lounge", false, false)
		await process_frame
		expect("doc_maki" in app.game.staff_present_at("lounge"), locale + ": doc_maki unlocked in Lounge")
		await save_shot(lounge_shot)

func run() -> void:
	var tmp_save_path := "/private/tmp/maki_lv0_preview_unused_%s.json" % OS.get_process_id()
	var tmp_prefs_path := "/private/tmp/maki_lv0_preview_prefs_%s.cfg" % OS.get_process_id()
	var packed: PackedScene = load("res://godot/scenes/main.tscn")
	app = packed.instantiate()
	app.title_notice_enabled = false
	app.title_preferences_path = tmp_prefs_path
	app.saves.path = tmp_save_path
	root.add_child(app)
	await process_frame
	await process_frame
	if app.page.get_node_or_null("StartupContentNotice") != null:
		var ok_btn: Button = app.page.find_child("StartupNoticeConfirm", true, false) as Button
		if ok_btn != null:
			ok_btn.pressed.emit()
			await process_frame

	await play_and_capture(
		"zh_CN",
		ZH_SHOTS,
		0,
		"12_zh_day_end_transition.png",
		"13_zh_lv0_completion_card.png",
		"14_zh_post_onboarding_lounge.png"
	)
	await play_and_capture(
		"en",
		EN_SHOTS,
		1,
		"",
		"20_en_lv0_completion_card.png",
		""
	)

	for p in [tmp_save_path, tmp_prefs_path]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

	print("MAKI LV0 PREVIEW CAPTURE: %d checks, %d failure(s)." % [checks, failures])
	quit(1 if failures > 0 else 0)
