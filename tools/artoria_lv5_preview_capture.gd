extends SceneTree
## Visible native 1280x800 Metal window synthetic-GUI playtest & screenshot capture
## for Artoria Pendragon (`doc_artoria`) Relationship Lv5:
## 《我的位置》 (`artoria_lv5_my_position`, V1.1).

const EVENT_ID := "artoria_lv5_my_position"
const ACTOR := "doc_artoria"
const ArtoriaLv5 = preload("res://godot/systems/artoria_lv5.gd")
const QA_DIR := "res://docs/qa/artoria_lv5_2026-11-17/"

const ZH_SHOTS := {
	"ar5_s1_03": "02_zh_s1_shared_office_moe_ange_notes.png",
	"ar5_s1_10": "03_zh_s1_hiroko_one_slot_rule.png",
	"ar5_s2_02": "04_zh_s2_deputy_office_sakaguchi_kun.png",
	"ar5_s2_19": "05_zh_s2_co_signing_moe_selection.png",
	"ar5_choice_c1": "06_zh_s2_choice1_menu.png",
	"ar5_s2_2_04": "07_zh_s2_2_nurses_station_moe_selected.png",
	"ar5_s2_2_13": "08_zh_s2_2_ange_composure.png",
	"ar5_s3_1_02": "09_zh_s3_1_ward_aoi_tohsaka_neutral.png",
	"ar5_s3_1_09": "10_zh_s3_1_ward_aoi_tohsaka_smile.png",
	"ar5_s3_2_02": "11_zh_s3_2_or_epidural_aoi_calm.png",
	"ar5_s3_2_08": "12_zh_s3_2_or_timeout_priorities.png",
	"ar5_s4_05": "13_zh_s4_or_aoi_awake_reassured.png",
	"ar5_choice_c2": "14_zh_s4_choice2_menu.png",
	"ar5_s4m_09": "15_zh_s4_hepp_couinaud_6_0_anastomosis.png",
	"ar5_s4m_18": "16_zh_s4_aoi_post_anastomosis_gratitude.png",
	"ar5_s5_1_11": "17_zh_s5_1_holding_ange_honest_question.png",
	"ar5_s5_1_22": "18_zh_s5_1_ange_coordinator_resolve.png",
	"ar5_s5_2_13": "19_zh_s5_2_office_tea_my_position.png",
	"ar5_s6_03": "20_zh_s6_evening_corridor_observation_window.png",
	"ar5_s6_08": "21_zh_s6_lying_on_the_table_next_time.png",
	"ar5_choice_c3": "22_zh_s6_choice3_menu.png",
}

const EN_SHOTS := {
	"ar5_s3_1_09": "25_en_s3_1_ward_aoi_tohsaka_smile.png",
	"ar5_choice_c2": "26_en_s4_choice2_menu.png",
	"ar5_s6_08": "27_en_s6_evening_corridor_epilogue.png",
}

var app
var checks := 0
var failures := 0
var gui_clicks := 0
var screenshots := {}
var cjk_re := RegEx.new()

func _initialize() -> void:
	cjk_re.compile("[\\x{3400}-\\x{4dbf}\\x{4e00}-\\x{9fff}\\x{3040}-\\x{30ff}\\x{f900}-\\x{faff}]")
	call_deferred("run")

func expect(ok: bool, msg: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(msg)

func set_exact_day_clock(g: RefCounted, target_day: int, absolute_clock: int) -> void:
	g.discarded_overtime_minutes = 0
	g.story_time_advance_minutes = 0
	var base_elapsed: int = g.elapsed()
	var desired_total: int = (maxi(1, target_day) - 1) * int(g.SHIFT_MINUTES) + clampi(absolute_clock - int(g.SHIFT_START_MINUTE), 0, int(g.SHIFT_MINUTES) - 1)
	g.story_time_advance_minutes = maxi(0, desired_total - base_elapsed)

func click(button: Button, context: String) -> void:
	expect(is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled, "Clickable button for " + context)
	if not is_instance_valid(button):
		return
	var pos := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = pos
	root.push_input(motion, true)
	for down in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = down
		ev.position = pos
		root.push_input(ev, true)
	gui_clicks += 1
	await process_frame
	await process_frame

func save_shot(filename: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var abs_path := ProjectSettings.globalize_path(QA_DIR + filename)
	var img: Image = root.get_texture().get_image()
	expect(img != null and img.get_width() > 0 and img.get_height() > 0, "Valid viewport capture " + filename)
	if img != null:
		var err := img.save_png(abs_path)
		expect(err == OK, "Saved PNG " + filename)
		screenshots[filename] = true

func find_return_map_button() -> Button:
	for btn in app.page.find_children("*", "Button", true, false):
		var b := btn as Button
		if b != null and b.is_visible_in_tree() and (b.text.contains("医院导览") or b.text.contains("Hospital")):
			return b
	return null

func run_branch(locale: String, c1: String, c2: String, c3: String, start_day: int, shot_map: Dictionary, map_shot: String, complete_shot: String) -> void:
	var tag := "%s_%s_%s" % [c1, c2, c3]
	app.game.reset()
	ArtoriaLv5.prepare_test_save(app.game, EVENT_ID, start_day)
	set_exact_day_clock(app.game, start_day, 540)
	app.show_map(false)
	await process_frame

	var loc_btn := app.page.get_node_or_null("Location_artoria_office") as Button
	expect(loc_btn != null and not loc_btn.disabled, "%s [%s]: Location_artoria_office button present on Hospital Map" % [locale, tag])
	if not map_shot.is_empty() and not screenshots.has(map_shot):
		await save_shot(map_shot)
	await click(loc_btn, "%s [%s] Location_artoria_office" % [locale, tag])

	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, "%s [%s]: entered Artoria Lv5 via GUI click on Location_artoria_office" % [locale, tag])
	if app.game.active_character_event_id != EVENT_ID:
		return

	var ev = app.game.character_events[EVENT_ID]
	var steps := 0
	var pick_map := {"c1": c1, "c2": c2, "c3": c3}
	while not ev.completed and steps < 600:
		steps += 1
		expect(not app.game.can_save_progress(), "%s [%s]: save locked at step %d" % [locale, tag, steps])
		var n: Dictionary = ev.current()
		var nid := str(n.id)

		if str(n.presentation) == "choice":
			var key := nid.trim_prefix("ar5_choice_")
			var choice_id := "choice_ar5_%s_%s" % [key, str(pick_map[key])]
			var choice_btn := app.page.get_node_or_null("EventChoice_" + choice_id) as Button
			expect(choice_btn != null, "%s [%s]: choice button %s exists" % [locale, tag, choice_id])
			for pnode in app.page.find_children("EventPortrait_*", "TextureRect", true, false):
				var pctrl := pnode as Control
				if choice_btn != null and pctrl != null:
					var face_rect := Rect2(pctrl.get_global_rect().position + Vector2(60, 20), Vector2(200, 150))
					expect(not choice_btn.get_global_rect().intersects(face_rect), "%s [%s]: choice button does not cover portrait face at %s" % [locale, tag, nid])
			if shot_map.has(nid) and not screenshots.has(shot_map[nid]):
				await save_shot(str(shot_map[nid]))
			await click(choice_btn, "%s [%s] %s" % [locale, tag, choice_id])
			continue

		var deadline := Time.get_ticks_msec() + 3000
		while (not is_instance_valid(app.dialogue_default_button) or not app.dialogue_default_button.is_visible_in_tree()) and Time.get_ticks_msec() < deadline:
			await process_frame
		await process_frame

		var page_text: String = app.current_dialogue_text()
		expect(not page_text.is_empty() and str(n.text).contains(page_text), "%s [%s]: displayed dialogue page matches %s" % [locale, tag, nid])
		if locale == "en":
			expect(cjk_re.search(page_text) == null, "en [%s]: zero CJK in visible text at %s" % [tag, nid])
			var spk_lbl := app.page.get_node_or_null("EventDialogueSpeakerLabel") as Label
			if spk_lbl != null:
				expect(cjk_re.search(spk_lbl.text) == null, "en [%s]: zero CJK in speaker label at %s" % [tag, nid])

		if not n.has("cg_path") and n.has("event_portraits"):
			for pspec in n.event_portraits:
				var pnode := app.page.get_node_or_null("EventPortrait_" + str(pspec.id)) as TextureRect
				expect(pnode != null and pnode.texture != null, "%s [%s]: portrait %s rendered at %s" % [locale, tag, str(pspec.id), nid])

		if shot_map.has(nid) and not screenshots.has(shot_map[nid]):
			await save_shot(str(shot_map[nid]))

		var btn := app.dialogue_default_button as Button
		await click(btn, "%s [%s] %s" % [locale, tag, nid])

	expect(ev.completed, "%s [%s]: event completed via GUI clicks" % [locale, tag])
	if app.screen == "character_event_reward":
		var rew_btn := app.page.get_node_or_null("EventRewardContinue") as Button
		if rew_btn != null:
			await click(rew_btn, "%s [%s] EventRewardContinue" % [locale, tag])
	expect(app.screen == "character_event_complete", "%s [%s]: landed on character_event_complete" % [locale, tag])
	expect(app.game.day_number() == start_day + 2 and app.game.clock_text() == "09:00", "%s [%s]: settled Day T+2 09:00" % [locale, tag])
	expect(app.game.relationship_level(ACTOR) == 5, "%s [%s]: promoted to Lv5" % [locale, tag])

	if not complete_shot.is_empty() and not screenshots.has(complete_shot):
		await save_shot(complete_shot)

	var ret_btn := find_return_map_button()
	expect(ret_btn != null, "%s [%s]: return-to-map button exists" % [locale, tag])
	if ret_btn != null:
		await click(ret_btn, "%s [%s] ReturnMap" % [locale, tag])
	expect(app.screen == "map" and app.game.can_save_progress(), "%s [%s]: returned to saveable Day T+2 09:00 map" % [locale, tag])

func run() -> void:
	expect(DisplayServer.get_name() != "headless", "Must run in a real visible native window (no --headless)")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA_DIR))

	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/hoshimi_artoria_lv5_native_unused_%d.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/hoshimi_artoria_lv5_native_prefs_%d.cfg" % OS.get_process_id()
	app.title_notice_enabled = false
	root.add_child(app)
	await process_frame
	await process_frame

	expect(app.content.load_all("zh_CN"), "Loaded zh_CN content")
	app.configure_game_content()
	await run_branch("zh_CN", "a", "a", "a", 21, ZH_SHOTS, "01_zh_map_artoria_office_badge.png", "23_zh_event_complete_day_plus_2_0900.png")
	await run_branch("zh_CN", "b", "b", "b", 17, {}, "", "")
	await run_branch("zh_CN", "c", "a", "c", 21, {}, "", "")

	expect(app.content.load_all("en"), "Loaded en content")
	app.configure_game_content()
	await run_branch("en", "a", "a", "a", 21, EN_SHOTS, "24_en_map_artoria_office_badge.png", "28_en_event_complete_day_plus_2_0900.png")
	await run_branch("en", "b", "b", "c", 17, {}, "", "")

	DirAccess.remove_absolute(app.saves.path)
	DirAccess.remove_absolute(app.title_preferences_path)
	app.queue_free()
	await process_frame

	print("ARTORIA LV5 NATIVE PLAYTEST: %d checks; %d failure(s); %d GUI clicks; %d screenshots" % [checks, failures, gui_clicks, screenshots.size()])
	quit(1 if failures > 0 else 0)
