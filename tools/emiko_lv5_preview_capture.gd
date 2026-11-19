extends SceneTree
## Visible native 1280x800 Metal window synthetic-GUI playtest & screenshot capture
## for Emiko Mido (`doc_emiko`) Relationship Lv5:
## 《神的双手》 (`emiko_lv5_hands_of_god`, V1.0).
## Uses isolated /private/tmp save/prefs paths ONLY; never touches real player save slots.

const EVENT_ID := "emiko_lv5_hands_of_god"
const ACTOR := "doc_emiko"
const EmikoLv5 = preload("res://godot/systems/emiko_lv5.gd")
const QA_DIR := "res://docs/qa/emiko_lv5_2026-11-17/"

const ZH_SHOTS := {
	"em5_s1_1_07": "02_zh_s1_1_office_a_rh_neg_grwr_files.png",
	"em5_s1_2_02": "03_zh_s1_2_clinic_haruko_casual_smile.png",
	"em5_s1_2_09": "03b_zh_s1_2_clinic_haruko_casual_afraid.png",
	"em5_s1_2_15": "04_zh_s1_2_haruko_one_week_chance_to_save.png",
	"em5_choice_c1": "05_zh_s1_3_choice1_menu.png",
	"em5_s2_13": "06_zh_s2_or1_emiko_patient_gown_reveal.png",
	"em5_s2_32": "07_zh_s2_or1_epidural_t7_t8_placement.png",
	"em5_s2_53": "08_zh_s2_or1_first_incision_blush.png",
	"em5_choice_c2": "09_zh_s2_or1_choice2_retrocholedochal.png",
	"em5_s2m_03": "10_zh_s2m_emiko_go_ahead_trust.png",
	"em5_s2m_14": "11_zh_s2m_prep_room_dont_laugh_at_me.png",
	"em5_s3_20": "12_zh_s3_morning_idea034_preop_hook.png",
	"em5_s4_1_09": "13_zh_s4_1_corridor_naomi_smile_haruko_or_caps.png",
	"em5_s4_2_03": "14a_zh_s4_2_or1_haruko_afraid_tears.png",
	"em5_s4_2_07": "14_zh_s4_2_or1_emiko_reassures_haruko.png",
	"em5_s4_3_04": "15_zh_s4_3_or2_naomi_pre_induction_smile.png",
	"em5_s4_3_06": "16_zh_s4_3_or2_timeout_a_rh_neg_blood_plan.png",
	"em5_s4_3_14": "17_zh_s4_3_or2_asuka_masked_observer.png",
	"em5_s5_2_04": "18_zh_s5_2_scrub_bay_emiko_inner_thought.png",
	"em5_choice_c3": "19_zh_s5_2_choice3_arterial_tension.png",
	"em5_s5m_14": "20_zh_s5m_arterial_pass_golden_bile.png",
	"em5_s5m_18": "21_zh_s5m_6_0_biliary_anastomosis_closure.png",
	"em5_s6_1_04": "22_zh_s6_1_ward_haruko_pain_wince.png",
	"em5_s6_1_15": "23_zh_s6_1_ward_round_naomi_smile.png",
	"em5_s6_1_21": "23b_zh_s6_1_ward_round_haruko_shy_blush.png",
	"em5_s6_1_29": "24_zh_s6_1_ward_round_haruko_scar_care.png",
	"em5_s6_1_31": "24b_zh_s6_1_ward_round_haruko_bright_smile.png",
	"em5_s6_1_33": "25_zh_s6_1_ward_unfinished_beach_trip.png",
	"em5_s6_2_15": "26_zh_s6_2_corridor_chief_division_of_labor.png",
	"em5_choice_c4": "27_zh_s6_2_choice4_menu.png",
	"em5_s6m_02": "28_zh_s6m_corridor_lapel_epilogue.png",
}

const EN_SHOTS := {
	"em5_s1_1_07": "31_en_s1_1_office_a_rh_neg_grwr.png",
	"em5_s2_53": "32_en_s2_or1_first_incision_blush.png",
	"em5_s4_1_06": "33_en_s4_1_corridor_naomi_haruko_or_caps.png",
	"em5_s5m_18": "34_en_s5m_biliary_anastomosis_closure.png",
	"em5_s6_1_29": "35_en_s6_1_ward_round_haruko_scar_care.png",
	"em5_s6_2_15": "36_en_s6_2_corridor_chief_division_of_labor.png",
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

func run_branch(locale: String, c1: String, c2: String, c3: String, c4: String, start_day: int, shot_map: Dictionary, office_shot: String, complete_shot: String) -> void:
	var tag := "%s_%s_%s_%s" % [c1, c2, c3, c4]
	app.game.reset()
	EmikoLv5.prepare_test_save(app.game, EVENT_ID, start_day)
	set_exact_day_clock(app.game, start_day, 990)
	app.show_map(false)
	await process_frame

	var office_btn := app.page.get_node_or_null("Location_player_office") as Button
	expect(office_btn != null and not office_btn.disabled, "%s [%s]: Location_player_office button present on Hospital Map" % [locale, tag])
	await click(office_btn, "%s [%s] Location_player_office" % [locale, tag])

	var end_btn := app.page.get_node_or_null("OfficeEndWorkday") as Button
	expect(end_btn != null and not end_btn.disabled, "%s [%s]: OfficeEndWorkday button enabled at 16:30" % [locale, tag])
	if not office_shot.is_empty() and not screenshots.has(office_shot):
		await save_shot(office_shot)
	await click(end_btn, "%s [%s] OfficeEndWorkday" % [locale, tag])

	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, "%s [%s]: entered Emiko Lv5 via GUI click on OfficeEndWorkday" % [locale, tag])
	if app.game.active_character_event_id != EVENT_ID:
		return

	var ev = app.game.character_events[EVENT_ID]
	var steps := 0
	var pick_map := {"c1": c1, "c2": c2, "c3": c3, "c4": c4}
	while not ev.completed and steps < 900:
		steps += 1
		expect(not app.game.can_save_progress(), "%s [%s]: save locked at step %d" % [locale, tag, steps])
		var n: Dictionary = ev.current()
		var nid := str(n.id)

		if str(n.presentation) == "choice":
			var key := nid.trim_prefix("em5_choice_")
			var choice_id := "choice_em5_%s_%s" % [key, str(pick_map[key])]
			var choice_btn := app.page.get_node_or_null("EventChoice_" + choice_id) as Button
			expect(choice_btn != null, "%s [%s]: choice button %s exists" % [locale, tag, choice_id])
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
	expect(app.game.day_number() == start_day + 1 and app.game.clock_text() == "09:00", "%s [%s]: settled Day T+1 09:00" % [locale, tag])
	expect(app.game.relationship_level(ACTOR) == 5, "%s [%s]: promoted to Lv5" % [locale, tag])

	if not complete_shot.is_empty() and not screenshots.has(complete_shot):
		await save_shot(complete_shot)

	var ret_btn := find_return_map_button()
	expect(ret_btn != null, "%s [%s]: return-to-map button exists" % [locale, tag])
	if ret_btn != null:
		await click(ret_btn, "%s [%s] ReturnMap" % [locale, tag])
	expect(app.screen == "map" and app.game.can_save_progress(), "%s [%s]: returned to saveable Day T+1 09:00 map" % [locale, tag])

func run() -> void:
	expect(DisplayServer.get_name() != "headless", "Must run in a real visible native window (no --headless)")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA_DIR))
	var gdignore := FileAccess.open(ProjectSettings.globalize_path(QA_DIR + ".gdignore"), FileAccess.WRITE)
	if gdignore != null:
		gdignore.close()

	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/hoshimi_emiko_lv5_native_unused_%d.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/hoshimi_emiko_lv5_native_prefs_%d.cfg" % OS.get_process_id()
	app.title_notice_enabled = false
	root.add_child(app)
	await process_frame
	await process_frame

	expect(app.content.load_all("zh_CN"), "Loaded zh_CN content")
	app.configure_game_content()
	await run_branch("zh_CN", "a", "a", "a", "a", 21, ZH_SHOTS, "01_zh_player_office_end_workday.png", "29_zh_event_complete_day_plus_1_0900.png")
	await run_branch("zh_CN", "b", "b", "b", "b", 18, {}, "", "")

	expect(app.content.load_all("en"), "Loaded en content")
	app.configure_game_content()
	await run_branch("en", "a", "a", "a", "a", 21, EN_SHOTS, "30_en_player_office_end_workday.png", "37_en_event_complete_day_plus_1_0900.png")
	await run_branch("en", "b", "b", "b", "b", 18, {}, "", "")

	for expected_shot in ZH_SHOTS.values():
		expect(screenshots.has(expected_shot), "Captured ZH screenshot " + str(expected_shot))
	for expected_shot in EN_SHOTS.values():
		expect(screenshots.has(expected_shot), "Captured EN screenshot " + str(expected_shot))

	DirAccess.remove_absolute(app.saves.path)
	DirAccess.remove_absolute(app.title_preferences_path)
	app.queue_free()
	await process_frame
	print("EMIKO LV5 NATIVE PREVIEW: %d checks; %d failure(s); %d GUI clicks; %d screenshots" % [checks, failures, gui_clicks, screenshots.size()])
	quit(1 if failures > 0 else 0)
