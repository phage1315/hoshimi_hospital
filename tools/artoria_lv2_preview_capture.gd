extends SceneTree
## Visible native 1280x800 Metal window synthetic-GUI playtest & screenshot capture
## for Artoria Pendragon (`doc_artoria`) Relationship Lv2:
## 《留下来的部分》 (`artoria_lv2_what_remains`, V1.0).
##
## Strictly follows `docs/skills/hoshimi-native-playtest/SKILL.md`:
## - Asserts `DisplayServer.get_name() != "headless"`
## - Isolates `saves.path` & `title_preferences_path` to `/private/tmp/` BEFORE `root.add_child(app)`
## - Drives formal `OfficeEndWorkday` button + every dialogue page + all 3 choices (A/B/C) +
##   `character_event_complete` return button via `root.push_input()` mouse events in both `zh_CN` and `en`.

const EVENT_ID := "artoria_lv2_what_remains"
const ACTOR := "doc_artoria"
const ArtoriaLv2 = preload("res://godot/systems/artoria_lv2.gd")
const QA_DIR := "res://docs/qa/artoria_lv2_2026-11-16/"

const ZH_SHOTS := {
	"ar2_s1_03": "01_zh_s1_ward_taiga_laugh.png",
	"ar2_s1_05": "02_zh_s1_ward_artoria_taiga_greeting.png",
	"ar2_s1_15": "03_zh_s1_ward_taiga_worried.png",
	"ar2_s1_22": "04_zh_s1_what_remains_core_line.png",
	"ar2_s1_31": "05_zh_s1_ward_reassured_smiles.png",
	"ar2_s2_14": "06_zh_s2_lightbox_remaining_liver.png",
	"ar2_choice_c1": "07_zh_s2_choice1_menu.png",
	"ar2_s3_06": "08_zh_s3_or_taiga_tense_ange.png",
	"ar2_s3_08": "09_zh_s3_or_artoria_scrubs_masked_epidural.png",
	"ar2_s3_13": "10_zh_s3_or_taiga_relieved_preop.png",
	"ar2_s3_17": "11_zh_s3_or_yui_ange_gowning.png",
	"ar2_s3_20": "12_zh_s3_or_incision_start.png",
	"ar2_s3_28": "13_zh_s3_or_taiga_drowsy_reply.png",
	"ar2_choice_c2": "14_zh_s4_choice2_menu.png",
	"ar2_s4r_17": "15_zh_s4_or_taiga_waking_relieved.png",
	"ar2_s5_15": "16_zh_s5_liver_resection_handout.png",
	"ar2_s5_31": "17_zh_s5_artoria_embarrassed_no_lunch.png",
	"ar2_choice_c3": "18_zh_s5_choice3_menu.png",
}

const EN_SHOTS := {
	"ar2_s1_15": "19_en_s1_ward_taiga_worried.png",
	"ar2_choice_c1": "20_en_s2_choice1_menu.png",
	"ar2_s3_08": "21_en_s3_or_artoria_epidural.png",
	"ar2_choice_c2": "22_en_s4_choice2_menu.png",
	"ar2_s4r_17": "23_en_s4_or_taiga_waking_relieved.png",
	"ar2_s5_31": "24_en_s5_artoria_embarrassed_no_lunch.png",
	"ar2_choice_c3": "25_en_s5_choice3_menu.png",
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

func run_branch(locale: String, branch: String, shot_map: Dictionary, complete_shot: String) -> void:
	app.game.reset()
	var target_day := ArtoriaLv2.prepare_test_save(app.game, EVENT_ID, 8)
	set_exact_day_clock(app.game, target_day, 960)
	app.show_player_office()
	await process_frame
	var end_btn := app.page.get_node_or_null("OfficeEndWorkday") as Button
	expect(end_btn != null and not end_btn.disabled, "%s [%s]: OfficeEndWorkday enabled at 16:00" % [locale, branch])
	await click(end_btn, "%s [%s] OfficeEndWorkday" % [locale, branch])

	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, "%s [%s]: entered Artoria Lv2 via GUI OfficeEndWorkday" % [locale, branch])
	if app.game.active_character_event_id != EVENT_ID:
		return

	var ev = app.game.character_events[EVENT_ID]
	var steps := 0
	while not ev.completed and steps < 600:
		steps += 1
		var n: Dictionary = ev.current()
		var nid := str(n.id)
		expect(not app.game.can_save_progress(), "%s [%s]: save locked at %s" % [locale, branch, nid])

		if str(n.presentation) == "choice":
			var choice_id := "choice_ar2_%s_%s" % [nid.trim_prefix("ar2_choice_"), branch]
			var choice_btn := app.page.get_node_or_null("EventChoice_" + choice_id) as Button
			expect(choice_btn != null, "%s [%s]: choice button %s exists" % [locale, branch, choice_id])
			var portrait := app.page.get_node_or_null("EventPortrait_doc_artoria") as Control
			if choice_btn != null and portrait != null:
				# Choice buttons sit on the left/center; Artoria stands on the right at x=1020 -> face upper-half must never be covered
				var face_rect := Rect2(portrait.get_global_rect().position + Vector2(60, 20), Vector2(200, 160))
				expect(not choice_btn.get_global_rect().intersects(face_rect), "%s [%s]: choice button does not cover Artoria face at %s" % [locale, branch, nid])
			if branch == "a" and shot_map.has(nid) and not screenshots.has(shot_map[nid]):
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
			if sprite != null and str(art.id) == "taiga_fujimura" and str(art.path).contains("/or_cap/"):
				# Verify Taiga's 1448x1086 head-and-shoulders face is completely above the continue button
				var taiga_face := Rect2(sprite.get_global_rect().position + Vector2(80, 30), Vector2(240, 210))
				expect(not app.dialogue_default_button.get_global_rect().intersects(taiga_face), "%s [%s]: continue button does not overlap Taiga OR face at %s" % [locale, branch, nid])

		if branch == "a" and shot_map.has(nid) and not screenshots.has(shot_map[nid]):
			await save_shot(str(shot_map[nid]))

		await click(app.dialogue_default_button, "%s [%s] continue %s" % [locale, branch, nid])

	expect(ev.completed and app.screen == "character_event_complete", "%s [%s]: reached character_event_complete" % [locale, branch])
	expect(app.game.day_number() == target_day + 1 and app.game.clock_text() == "14:00", "%s [%s]: settled at next day 14:00" % [locale, branch])
	expect(app.game.relationship_level(ACTOR) == 2 and app.game.procedure_unlocked("surgery_open_major_liver_resection"), "%s [%s]: Lv2 & liver resection unlocked" % [locale, branch])
	if branch == "a" and not complete_shot.is_empty():
		await save_shot(complete_shot)

	var ret_btn := find_return_map_button()
	await click(ret_btn, "%s [%s] return map" % [locale, branch])
	expect(app.screen == "map" and app.game.can_save_progress(), "%s [%s]: returned to saveable Hospital Guide" % [locale, branch])

func run() -> void:
	expect(DisplayServer.get_name() != "headless", "Must run in visible native window (no --headless)")
	var tmp_save := "/private/tmp/artoria_lv2_native_unused_%d.json" % OS.get_process_id()
	var tmp_prefs := "/private/tmp/artoria_lv2_native_prefs_%d.cfg" % OS.get_process_id()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = tmp_save
	app.title_preferences_path = tmp_prefs
	app.title_notice_enabled = false
	root.add_child(app)
	await process_frame

	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Loaded locale " + locale)
		app.configure_game_content()
		app.dialogue_auto_enabled = false
		var smap := ZH_SHOTS if locale == "zh_CN" else EN_SHOTS
		var cshot := "26_zh_event_complete.png" if locale == "zh_CN" else "27_en_event_complete.png"
		for branch in ["a", "b", "c"]:
			await run_branch(locale, branch, smap, cshot if branch == "a" else "")
			if failures > 0:
				break
		if failures > 0:
			break

	expect(screenshots.size() == ZH_SHOTS.size() + EN_SHOTS.size() + 2, "Captured all 27 expected QA screenshots")
	print("ARTORIA LV2 NATIVE PLAYTEST: %d checks; %d failure(s); %d GUI clicks; %d screenshots" % [checks, failures, gui_clicks, screenshots.size()])
	DirAccess.remove_absolute(tmp_save)
	DirAccess.remove_absolute(tmp_prefs)
	app.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)
