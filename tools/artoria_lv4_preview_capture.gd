extends SceneTree
## Visible native 1280x800 Metal window synthetic-GUI playtest & screenshot capture
## for Artoria Pendragon (`doc_artoria`) Relationship Lv4:
## 《只是阿尔托莉雅》 (`artoria_lv4_just_artoria`, V1.1).

const EVENT_ID := "artoria_lv4_just_artoria"
const ACTOR := "doc_artoria"
const ArtoriaLv4 = preload("res://godot/systems/artoria_lv4.gd")
const QA_DIR := "res://docs/qa/artoria_lv4_2026-11-16/"

const ZH_SHOTS := {
	"ar4_s1_05": "02_zh_s1_station_clock_greeting.png",
	"ar4_s1_09": "03_zh_s1_station_trench_shy.png",
	"ar4_s1_15": "04_zh_s1_not_ward_rounds.png",
	"ar4_s2_03": "05_zh_s2_dojo_taiga_welcome.png",
	"ar4_s2_16": "06_zh_s2_takeyatei_artoria_sparkle.png",
	"ar4_s2_21": "07_zh_s2_taiga_teases_food_show.png",
	"ar4_choice_c1": "08_zh_s2_choice1_menu.png",
	"ar4_c1a_04": "09_zh_s2_c1a_extra_croquette.png",
	"ar4_s2m_04": "10_zh_s2_taiga_grateful_bow.png",
	"ar4_s3_03": "11_zh_s3_teahouse_irisviel_welcome.png",
	"ar4_s3_17": "12_zh_s3_irisviel_warm_observation.png",
	"ar4_s3_26": "13_zh_s3_artoria_dependable_blush.png",
	"ar4_s4_19": "14_zh_s4_riverside_wish.png",
	"ar4_choice_c2": "15_zh_s4_choice2_menu.png",
	"ar4_s4m_06": "16_zh_s4_home_invitation.png",
	"ar4_s5_1_06": "17_zh_s5_1_living_room_hair_down.png",
	"ar4_s5_1_16": "18_zh_s5_1_just_artoria_sakaguchi_kun.png",
	"ar4_s5_1_23": "19_zh_s5_1_confession_blush.png",
	"ar4_s5_2_09": "21_zh_s5_2_bedroom_moonlight_aftercare.png",
	"ar4_s6_1_13": "22_zh_s6_1_kitchen_apron_smoke_safe.png",
	"ar4_s6_1_17": "23_zh_s6_1_kitchen_apron_embarrassed.png",
	"ar4_s6_1_29": "24_zh_s6_1_breakfast_sparkle.png",
	"ar4_s6_2_10": "25_zh_s6_2_leadership_dilemma.png",
	"ar4_choice_c3": "26_zh_s6_2_choice3_menu.png",
	"ar4_s6_2m_11": "27_zh_s6_2_next_morning_together.png",
}

const EN_SHOTS := {
	"ar4_s1_05": "30_en_s1_station_greeting.png",
	"ar4_s2_21": "31_en_s2_takeyatei_taiga_artoria.png",
	"ar4_s3_22": "32_en_s3_teahouse_irisviel.png",
	"ar4_choice_c2": "33_en_s4_choice2_menu.png",
	"ar4_s5_1_16": "34_en_s5_1_sakaguchi_kun.png",
	"ar4_s6_1_13": "35_en_s6_1_kitchen_apron.png",
	"ar4_choice_c3": "36_en_s6_2_choice3_menu.png",
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

func run_branch(locale: String, branch: String, shot_map: Dictionary, sunday_shot: String, h_shot: String, complete_shot: String, profile_shot: String) -> void:
	app.game.reset()
	var target_day := ArtoriaLv4.prepare_test_save(app.game, EVENT_ID, 13)
	set_exact_day_clock(app.game, target_day, 540)
	app.show_sunday_menu()
	await process_frame

	var invite_menu_btn := app.page.get_node_or_null("SundayInvite") as Button
	expect(invite_menu_btn != null and not invite_menu_btn.disabled, "%s [%s]: SundayInvite button present" % [locale, branch])
	await click(invite_menu_btn, "%s [%s] SundayInvite" % [locale, branch])

	var cand_btn := app.page.get_node_or_null("SundayCandidate_" + ACTOR) as Button
	expect(cand_btn != null and not cand_btn.disabled, "%s [%s]: SundayCandidate_doc_artoria present" % [locale, branch])
	if not sunday_shot.is_empty() and not screenshots.has(sunday_shot):
		await save_shot(sunday_shot)
	await click(cand_btn, "%s [%s] SundayCandidate_doc_artoria" % [locale, branch])

	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, "%s [%s]: entered Artoria Lv4 via GUI Sunday invitation" % [locale, branch])
	if app.game.active_character_event_id != EVENT_ID:
		return

	var ev = app.game.character_events[EVENT_ID]
	var steps := 0
	var saw_h := false
	while not ev.completed and steps < 600:
		steps += 1
		expect(not app.game.can_save_progress(), "%s [%s]: save locked at step %d" % [locale, branch, steps])

		if app.screen == "h_profile_test":
			saw_h = true
			expect(app.game.relationship_level(ACTOR) == 3, "%s [%s]: Lv4 not settled prematurely at Milestone H Runner" % [locale, branch])
			while app.h_profile_test_session.excitement < 100:
				app.h_profile_test_last_result = app.h_profile_test_session.perform("kiss", "lips")
			app.show_sayaka_h_profile_test()
			await process_frame
			var style_btn := app.page.get_node_or_null("HProfileStyleGentle") as Button
			await click(style_btn, "%s [%s] HProfileStyleGentle" % [locale, branch])
			for _stage_i in range(6):
				var adv_btn := app.page.get_node_or_null("HProfileAdvance") as Button
				await click(adv_btn, "%s [%s] HProfileAdvance" % [locale, branch])
			var fin_btn := app.page.get_node_or_null("HProfileFinish") as Button
			await click(fin_btn, "%s [%s] HProfileFinish" % [locale, branch])
			var fin_adv := app.page.get_node_or_null("HProfileAdvance") as Button
			await click(fin_adv, "%s [%s] HProfileFinishAdvance" % [locale, branch])
			await create_timer(4.8).timeout
			expect(app.screen == "character_event" and str(ev.current().id) == "ar4_s5_2_01", "%s [%s]: resumed at ar4_s5_2_01" % [locale, branch])
			continue

		var n: Dictionary = ev.current()
		var nid := str(n.id)

		if str(n.presentation) == "choice":
			var choice_id := "choice_ar4_%s_%s" % [nid.trim_prefix("ar4_choice_"), branch]
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
			expect(cjk_re.search(page_text) == null, "en [%s]: zero CJK in visible text at %s" % [branch, nid])
			var spk_lbl := app.page.get_node_or_null("EventDialogueSpeakerLabel") as Label
			if spk_lbl != null:
				expect(cjk_re.search(spk_lbl.text) == null, "en [%s]: zero CJK in speaker label at %s" % [branch, nid])

		if not n.has("cg_image") and n.has("event_portraits"):
			for pspec in n.event_portraits:
				var pnode := app.page.get_node_or_null("EventPortrait_" + str(pspec.id)) as TextureRect
				expect(pnode != null and pnode.texture != null, "%s [%s]: portrait %s rendered at %s" % [locale, branch, str(pspec.id), nid])

		if shot_map.has(nid) and not screenshots.has(shot_map[nid]):
			await save_shot(str(shot_map[nid]))

		var btn := app.dialogue_default_button as Button
		await click(btn, "%s [%s] %s" % [locale, branch, nid])

	expect(saw_h and ev.completed, "%s [%s]: event completed via GUI clicks after Milestone H Runner" % [locale, branch])
	if app.screen == "character_event_reward":
		var rew_btn := app.page.get_node_or_null("EventRewardContinue") as Button
		expect(rew_btn != null, "%s [%s]: EventRewardContinue exists" % [locale, branch])
		if rew_btn != null:
			await click(rew_btn, "%s [%s] EventRewardContinue" % [locale, branch])
	expect(app.screen == "character_event_complete", "%s [%s]: landed on character_event_complete" % [locale, branch])
	expect(app.game.day_number() == target_day + 1 and app.game.clock_text() == "09:00", "%s [%s]: settled Monday Day 14 09:00" % [locale, branch])
	expect(app.game.relationship_level(ACTOR) == 4, "%s [%s]: promoted to Lv4" % [locale, branch])

	if not complete_shot.is_empty() and not screenshots.has(complete_shot):
		await save_shot(complete_shot)

	var ret_btn := find_return_map_button()
	expect(ret_btn != null, "%s [%s]: return-to-map button exists" % [locale, branch])
	if ret_btn != null:
		await click(ret_btn, "%s [%s] ReturnMap" % [locale, branch])
	expect(app.screen == "map" and app.game.can_save_progress(), "%s [%s]: returned to saveable Monday 09:00 map" % [locale, branch])

	if not profile_shot.is_empty() and not screenshots.has(profile_shot):
		app.show_staff(ACTOR, "artoria_office")
		await process_frame
		var book_btn := app.page.get_node_or_null("FreeHBooking") as Button
		expect(book_btn != null and not book_btn.disabled, "%s [%s]: FreeHBooking visible and enabled" % [locale, branch])
		await save_shot(profile_shot)

func run() -> void:
	expect(DisplayServer.get_name() != "headless", "Must run in a real visible native window (no --headless)")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA_DIR))

	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/hoshimi_artoria_lv4_native_unused_%d.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/hoshimi_artoria_lv4_native_prefs_%d.cfg" % OS.get_process_id()
	app.title_notice_enabled = false
	root.add_child(app)
	await process_frame
	await process_frame

	expect(app.content.load_all("zh_CN"), "Loaded zh_CN content")
	app.configure_game_content()
	await run_branch("zh_CN", "a", ZH_SHOTS, "01_zh_sunday_invite_artoria_badge.png", "20_zh_s5_h_runner_placeholder.png", "28_zh_event_complete_monday_0900.png", "29_zh_staff_profile_pending_free_h.png")
	await run_branch("zh_CN", "b", {}, "", "", "", "")
	await run_branch("zh_CN", "c", {}, "", "", "", "")

	expect(app.content.load_all("en"), "Loaded en content")
	app.configure_game_content()
	await run_branch("en", "a", EN_SHOTS, "37_en_sunday_invite_artoria_badge.png", "38_en_s5_h_runner_placeholder.png", "39_en_event_complete_monday_0900.png", "40_en_staff_profile_pending_free_h.png")
	await run_branch("en", "b", {}, "", "", "", "")

	DirAccess.remove_absolute(app.saves.path)
	DirAccess.remove_absolute(app.title_preferences_path)
	app.queue_free()
	await process_frame

	print("ARTORIA LV4 NATIVE PLAYTEST: %d checks; %d failure(s); %d GUI clicks; %d screenshots" % [checks, failures, gui_clicks, screenshots.size()])
	quit(1 if failures > 0 else 0)
