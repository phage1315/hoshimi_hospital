extends SceneTree
## Visible native 1280x800 Metal window synthetic-GUI playtest & screenshot capture
## for Artoria Pendragon (`doc_artoria`) Relationship Lv3:
## 《不是一个人的手术》 (`artoria_lv3_not_a_solo_operation`, V1.1).

const EVENT_ID := "artoria_lv3_not_a_solo_operation"
const ACTOR := "doc_artoria"
const ArtoriaLv3 = preload("res://godot/systems/artoria_lv3.gd")
const QA_DIR := "res://docs/qa/artoria_lv3_2026-11-16/"

const ZH_SHOTS := {
	"ar3_s1_em3b_02": "01_zh_s1_lounge_em3_default_moe_hiroko.png",
	"ar3_s1_em3a_02": "02_zh_s1_lounge_em3_cabg_recall.png",
	"ar3_s1m_02": "03_zh_s1_ange_votes_artoria.png",
	"ar3_choice_c1": "04_zh_s1_choice1_menu.png",
	"ar3_c1a_2_02": "05_zh_s1_c1a2_no_emiko_lv1.png",
	"ar3_c1a_1_02": "06_zh_s1_c1a1_with_emiko_lv1.png",
	"ar3_s2_05": "07_zh_s2_station_moe_scrub_wish.png",
	"ar3_s2_29": "08_zh_s2_station_ange_solo_report.png",
	"ar3_s3_1_02": "09_zh_s3_1_or_entrance_briefing.png",
	"ar3_s3_1_05": "10_zh_s3_1_or_irisviel_smile_greeting.png",
	"ar3_s3_1_12": "11_zh_s3_1_or_irisviel_not_solo.png",
	"ar3_s3_1_24": "12_zh_s3_1_or_epidural_test_moe.png",
	"ar3_s3_1_29": "13_zh_s3_1_or_irisviel_drowsy.png",
	"ar3_choice_c2": "14_zh_s3_2_choice2_menu.png",
	"ar3_s3_2r_10": "15_zh_s3_2_moe_pulse_pressure_alert.png",
	"ar3_s3_2r_19": "16_zh_s3_2_moe_ange_gear_handoff.png",
	"ar3_s4_03": "17_zh_s4_ward_irisviel_relieved.png",
	"ar3_s4_09": "18_zh_s4_ward_moe_ange_bow.png",
	"ar3_s5_07": "19_zh_s5_leader_serves_team.png",
	"ar3_s5_38": "20_zh_s5_moe_blocks_door_artoria_shy.png",
	"ar3_choice_c3": "21_zh_s5_choice3_menu.png",
	"ar3_s5r_10": "22_zh_s5_second_menchi_sandwich.png",
}

const EN_SHOTS := {
	"ar3_s1_em3a_02": "23_en_s1_cabg_recall.png",
	"ar3_choice_c1": "24_en_s1_choice1_menu.png",
	"ar3_s3_1_12": "25_en_s3_1_irisviel_not_solo.png",
	"ar3_choice_c2": "26_en_s3_2_choice2_menu.png",
	"ar3_s4_07": "27_en_s4_ward_irisviel_thanks.png",
	"ar3_s5_38": "28_en_s5_moe_blocks_door.png",
	"ar3_choice_c3": "29_en_s5_choice3_menu.png",
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

func run_branch(locale: String, branch: String, em1_done: bool, em3_done: bool, shot_map: Dictionary, complete_shot: String) -> void:
	app.game.reset()
	var target_day := ArtoriaLv3.prepare_test_save(app.game, EVENT_ID, 11)
	if em1_done:
		app.game._complete_character_event_for_test("emiko_lv1_first_operation", 3)
		app.game.relation_for("doc_emiko").level = 1
	if em3_done:
		app.game._complete_character_event_for_test("emiko_lv3_today_i_lead", 6)
		app.game.relation_for("doc_emiko").level = 3
	set_exact_day_clock(app.game, target_day, 960)
	app.show_player_office()
	await process_frame
	var end_btn := app.page.get_node_or_null("OfficeEndWorkday") as Button
	expect(end_btn != null and not end_btn.disabled, "%s [%s]: OfficeEndWorkday enabled" % [locale, branch])
	await click(end_btn, "%s [%s] OfficeEndWorkday" % [locale, branch])

	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, "%s [%s]: entered Artoria Lv3 via GUI OfficeEndWorkday" % [locale, branch])
	if app.game.active_character_event_id != EVENT_ID:
		return

	var ev = app.game.character_events[EVENT_ID]
	var steps := 0
	while not ev.completed and steps < 700:
		steps += 1
		var n: Dictionary = ev.current()
		var nid := str(n.id)
		expect(not app.game.can_save_progress(), "%s [%s]: save locked at %s" % [locale, branch, nid])

		if str(n.presentation) == "choice":
			var choice_id := "choice_ar3_%s_%s" % [nid.trim_prefix("ar3_choice_"), branch]
			var choice_btn := app.page.get_node_or_null("EventChoice_" + choice_id) as Button
			expect(choice_btn != null, "%s [%s]: choice button %s exists" % [locale, branch, choice_id])
			for pnode in app.page.find_children("EventPortrait_*", "TextureRect", true, false):
				var pctrl := pnode as Control
				if choice_btn != null and pctrl != null:
					var face_rect := Rect2(pctrl.get_global_rect().position + Vector2(60, 20), Vector2(200, 150))
					expect(not choice_btn.get_global_rect().intersects(face_rect), "%s [%s]: choice button does not cover portrait face at %s" % [locale, branch, nid])
			if shot_map.has(nid) and not screenshots.has(shot_map[nid]):
				await save_shot(str(shot_map[nid]))
			await click(choice_btn, "%s [%s] %s" % [locale, branch, choice_id])
			continue

		var deadline := Time.get_ticks_msec() + 3000
		while (not is_instance_valid(app.dialogue_default_button) or not app.dialogue_default_button.is_visible_in_tree()) and Time.get_ticks_msec() < deadline:
			await process_frame
		await process_frame

		var page_text: String = app.current_dialogue_text()
		expect(not page_text.is_empty() and str(n.text).contains(page_text), "%s [%s]: displayed dialogue page matches %s" % [locale, branch, nid])
		if locale == "en":
			expect(cjk_re.search(page_text) == null, "en [%s]: zero CJK on screen at %s" % [branch, nid])
		for rtl in app.page.find_children("*", "RichTextLabel", true, false):
			var label := rtl as RichTextLabel
			if label != null and label.text == page_text:
				expect(label.get_content_height() <= label.size.y + 2, "%s [%s]: dialogue fits box at %s" % [locale, branch, nid])

		var cg_path := str(n.get("cg_path", ""))
		if not cg_path.is_empty():
			var cg := app.page.get_node_or_null("CharacterEventCG") as TextureRect
			expect(cg != null and cg.texture != null and cg.texture.resource_path == "res://" + cg_path, "%s: CG loaded at %s" % [locale, nid])
		for art in ([] if not cg_path.is_empty() else n.get("event_portraits", [])):
			var sprite := app.page.get_node_or_null("EventPortrait_" + str(art.id)) as TextureRect
			expect(sprite != null and sprite.texture != null and sprite.texture.resource_path == "res://" + str(art.path), "%s [%s]: portrait %s loaded at %s" % [locale, branch, str(art.id), nid])
			if sprite != null and str(art.id) == "irisviel" and str(art.path).contains("/or_cap/"):
				var iri_face := Rect2(sprite.get_global_rect().position + Vector2(80, 30), Vector2(240, 210))
				expect(not app.dialogue_default_button.get_global_rect().intersects(iri_face), "%s [%s]: continue button does not overlap Irisviel OR face at %s" % [locale, branch, nid])

		if shot_map.has(nid) and not screenshots.has(shot_map[nid]):
			await save_shot(str(shot_map[nid]))

		await click(app.dialogue_default_button, "%s [%s] continue %s" % [locale, branch, nid])

	expect(ev.completed and app.screen == "character_event_complete", "%s [%s]: reached character_event_complete" % [locale, branch])
	expect(app.game.day_number() == target_day + 1 and app.game.clock_text() == "15:00", "%s [%s]: settled at next day 15:00" % [locale, branch])
	expect(app.game.relationship_level(ACTOR) == 3, "%s [%s]: Lv3 unlocked" % [locale, branch])
	if not complete_shot.is_empty():
		await save_shot(complete_shot)

	var ret_btn := find_return_map_button()
	await click(ret_btn, "%s [%s] return map" % [locale, branch])
	expect(app.screen == "map" and app.game.can_save_progress(), "%s [%s]: returned to saveable Hospital Guide" % [locale, branch])

func run() -> void:
	expect(DisplayServer.get_name() != "headless", "Must run in visible native window (no --headless)")
	var tmp_save := "/private/tmp/artoria_lv3_native_unused_%d.json" % OS.get_process_id()
	var tmp_prefs := "/private/tmp/artoria_lv3_native_prefs_%d.cfg" % OS.get_process_id()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = tmp_save
	app.title_preferences_path = tmp_prefs
	app.title_notice_enabled = false
	root.add_child(app)
	await process_frame

	# zh_CN: Run A without Emiko Lv1/Lv3, Run A with Emiko Lv1+Lv3, Run B, Run C (covers both continuity variants + all 3 choices!)
	expect(app.content.load_all("zh_CN"), "Loaded zh_CN")
	app.configure_game_content()
	app.dialogue_auto_enabled = false
	await run_branch("zh_CN", "a", false, false, ZH_SHOTS, "30_zh_event_complete.png")
	await run_branch("zh_CN", "a", true, true, ZH_SHOTS, "")
	await run_branch("zh_CN", "b", false, false, ZH_SHOTS, "")
	await run_branch("zh_CN", "c", false, false, ZH_SHOTS, "")

	# en: Run A with Emiko Lv1+Lv3, Run B without Emiko, Run C without Emiko
	expect(app.content.load_all("en"), "Loaded en")
	app.configure_game_content()
	app.dialogue_auto_enabled = false
	await run_branch("en", "a", true, true, EN_SHOTS, "31_en_event_complete.png")
	await run_branch("en", "b", false, false, EN_SHOTS, "")
	await run_branch("en", "c", false, false, EN_SHOTS, "")

	expect(screenshots.size() == ZH_SHOTS.size() + EN_SHOTS.size() + 2, "Captured all 31 expected QA screenshots (got %d)" % screenshots.size())
	print("ARTORIA LV3 NATIVE PLAYTEST: %d checks; %d failure(s); %d GUI clicks; %d screenshots" % [checks, failures, gui_clicks, screenshots.size()])
	DirAccess.remove_absolute(tmp_save)
	DirAccess.remove_absolute(tmp_prefs)
	app.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)
