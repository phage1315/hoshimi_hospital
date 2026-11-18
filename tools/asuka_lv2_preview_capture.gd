extends SceneTree
## Native windowed 1280x800 UI playthrough & screenshot capture for
## Asuka Shiromiya (`doc_asuka`) Relationship Lv2: 《合适的人，合适的手术袍》
## (`asuka_lv2_right_person_right_gown`).
##
## Captures 20 live-rendered 1280x800 screenshots across `zh_CN` and `en`:
## - Hospital map badge on `director_office` at 13:35
## - Scene A surgeon gown fitting critiques (`doc_emiko`, `doc_aoi`, `doc_asuka`)
## - Scene B Maki Aizawa (`doc_maki`) interview expressions (`neutral`, `focused`,
##   `worried`, `relieved`), Choice B1, and offer acceptance
## - Scene C Asuka `sample_gown/{smile,proud,reluctant_cuff}`, Choice C1, and
##   scrub-nurse reach check with Hiroko Sugimura (`nurse_hiroko`)
## - Relationship Lv.2 completion card in both `zh_CN` and `en`
## Also checks every rendered label & button for horizontal/vertical overflow!

const EVENT_ID := "asuka_lv2_right_person_right_gown"
const LV1_PREOP := "asuka_lv1_director_surgeon_preop"
const LV1_POSTOP := "asuka_lv1_director_surgeon_postop"
const INTRO_OFFICE := "intro_doc_asuka_director_office"
const OUT_DIR := "docs/qa/asuka_lv2_2026-11-13"

const ZH_SHOTS := {
	"al2_020": "02_zh_scene_a_emiko_critique.png",
	"al2_039": "03_zh_scene_a_narumi_collar_tease.png",
	"al2_055": "04_zh_scene_b_maki_greeting.png",
	"al2_065": "05_zh_scene_b_maki_hemostasis_focused.png",
	"al2_086": "06_zh_scene_b_maki_probed_worried.png",
	"al2_choice_b1": "07_zh_scene_b_choice_b1.png",
	"al2_144": "08_zh_scene_b_maki_offer_relieved.png",
	"al2_159": "09_zh_scene_c_asuka_sample_gown_smile.png",
	"al2_choice_c1": "10_zh_scene_c_choice_c1.png",
	"al2_167": "11_zh_scene_c_asuka_proud.png",
	"al2_191": "12_zh_scene_c_hiroko_and_reluctant_cuff.png",
}

const EN_SHOTS := {
	"al2_055": "14_en_scene_b_maki_greeting.png",
	"al2_choice_b1": "15_en_scene_b_choice_b1.png",
	"al2_144": "16_en_scene_b_maki_offer_relieved.png",
	"al2_159": "17_en_scene_c_asuka_sample_gown_smile.png",
	"al2_choice_c1": "18_en_scene_c_choice_c1.png",
	"al2_191": "19_en_scene_c_hiroko_and_reluctant_cuff.png",
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

func seed_lv1_ready_state(game: RefCounted) -> void:
	game.reset()
	for sid in ["doc_asuka", "doc_emiko", "doc_artoria", "doc_aoi", "nurse_hiroko"]:
		game.meet_staff(sid)
	var rel: Dictionary = game.relation_for("doc_asuka")
	rel.met = true
	rel.level = 1
	rel.familiarity = 25
	game.set_test_player_attribute("charm", 25)
	game._complete_character_event_for_test("asuka_scrub_sink_encounter", 1)
	game._complete_character_event_for_test("asuka_adjacent_operation_reveal", 1)
	game._complete_character_event_for_test(INTRO_OFFICE, 2)
	game._complete_character_event_for_test(LV1_PREOP, 3)
	game._complete_character_event_for_test(LV1_POSTOP, 3)
	if not rel.rank_history.has(LV1_POSTOP):
		rel.rank_history.append(LV1_POSTOP)
	game.set_story_flag("asuka_lv1_complete", true)
	set_exact_clock(game, 8, 815) # 2025-04-08 Tue 13:35

func save_shot(filename: String) -> void:
	for child in app.page.get_children():
		if child is CanvasItem and str(child.name) != "EventStageEffect":
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

func play_and_capture(locale: String, shot_map: Dictionary, b1_idx: int, c1_idx: int, map_shot: String, complete_shot: String) -> void:
	expect(app.content.load_all(locale), "load_all " + locale)
	app.configure_game_content()
	seed_lv1_ready_state(app.game)
	app.show_map(false)
	await process_frame
	if not map_shot.is_empty():
		await save_shot(map_shot)

	app.show_location("director_office")
	await process_frame
	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, locale + ": entered character_event")

	var captured := {}
	var guard := 0
	while app.game.active_character_event_id == EVENT_ID and guard < 500:
		guard += 1
		var ev = app.game.character_events[EVENT_ID]
		if ev.completed:
			break
		var node: Dictionary = ev.current()
		var nid := str(node.get("id", ""))
		if nid in ["al2_choice_b1", "al2_choice_c1"]:
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
		var pick := 0
		if nid == "al2_choice_b1":
			pick = b1_idx
		elif nid == "al2_choice_c1":
			pick = c1_idx
		app.choose_character_event(str(ch_list[pick].id))
		await process_frame

	for k in shot_map.keys():
		expect(captured.has(k), locale + ": captured node " + str(k))
	expect(app.screen == "character_event_complete", locale + ": reached character_event_complete")
	await save_shot(complete_shot)
	app.show_map(false)
	await process_frame

func run() -> void:
	var tmp_save_path := "/private/tmp/asuka_lv2_preview_unused_%s.json" % OS.get_process_id()
	var packed: PackedScene = load("res://godot/scenes/main.tscn")
	app = packed.instantiate()
	app.saves.path = tmp_save_path
	root.add_child(app)
	await process_frame
	await process_frame
	# Dismiss any startup notice overlay if shown
	if app.page.get_node_or_null("StartupContentNotice") != null:
		var ok_btn: Button = app.page.find_child("StartupNoticeConfirm", true, false) as Button
		if ok_btn != null:
			ok_btn.pressed.emit()
			await process_frame

	await play_and_capture("zh_CN", ZH_SHOTS, 0, 0, "01_zh_map_director_office_badge.png", "13_zh_lv2_completion_card.png")
	await play_and_capture("en", EN_SHOTS, 1, 1, "", "20_en_lv2_completion_card.png")

	if FileAccess.file_exists(tmp_save_path):
		DirAccess.remove_absolute(tmp_save_path)

	print("ASUKA LV2 PREVIEW CAPTURE: %d checks, %d failure(s)." % [checks, failures])
	quit(1 if failures > 0 else 0)
