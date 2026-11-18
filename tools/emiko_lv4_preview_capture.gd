extends SceneTree
## Native windowed 1280x800 UI playthrough & screenshot verification for
## Emiko Mido (`doc_emiko`) Lv4 V1.1: 《御堂江美子的秘密》 (`emiko_lv4_emikos_secret`).
## Uses isolated /private/tmp paths only; never touches real player save slots.

const LV0 := "emiko_intro_rumored_hands"
const LV1 := "emiko_lv1_first_operation"
const LV2 := "emiko_lv2_follow_my_lead"
const LV3 := "emiko_lv3_today_i_lead"
const EVENT_ID := "emiko_lv4_emikos_secret"
const OUT_DIR := "docs/qa/emiko_lv4_2026-11-15"

const ZH_SHOTS := {
	"em4_s1_05": "02_zh_scene1_or_door_outside.png",
	"em4_s1_11": "03_zh_scene1_or_secret_cg_immersed.png",
	"em4_s1_16": "03b_zh_scene1_or_secret_cg_startled.png",
	"em4_s1_20": "04_zh_scene1_get_out.png",
	"em4_s2_05": "05_zh_scene2_hallway_distance.png",
	"em4_s2_13": "06_zh_scene2_whiteboard_excuse.png",
	"em4_s3_17": "07_zh_scene3_confrontation_v11.png",
	"em4_choice_c1": "08_zh_scene3_choice1_wide.png",
	"em4_s3r_06": "09_zh_scene3_are_you_an_idiot.png",
	"em4_s3r_15": "10_zh_scene3_whispered_thanks.png",
	"em4_s4_15": "11_zh_scene4_candid_question.png",
	"em4_choice_c2": "12_zh_scene4_choice2_wide.png",
	"em4_s4r_11": "13_zh_scene4_cholecystectomy_invite.png",
	"em4_s5_07": "14_zh_scene5_sakurai_mayumi_27yo.png",
	"em4_s5_13": "15_zh_scene5_ange_circulating.png",
	"em4_s5_30": "16_zh_scene5_dont_leave_first.png",
	"em4_s5_48": "17_zh_scene5_ange_doorway_debrief.png",
	"em4_s6_1_12": "18_zh_scene6_1_table_is_narrow.png",
	"em4_s6_1_22": "19_zh_scene6_1_care_to_try.png",
	"em4_s6_2_14": "21_zh_scene6_2_sharing_secret.png",
	"em4_s6_2_26": "22_zh_scene6_2_never_yield_chief.png",
	"em4_s6_2_32": "23_zh_scene6_2_breathtaking_smile.png",
}

const EN_SHOTS := {
	"em4_s3_17": "26_en_scene3_confrontation_v11.png",
	"em4_choice_c1": "27_en_scene3_choice1_wide.png",
	"em4_s5_07": "28_en_scene5_sakurai_mayumi_27yo.png",
	"em4_s5_48": "29_en_scene5_ange_doorway_debrief.png",
	"em4_s6_1_12": "30_en_scene6_1_table_is_narrow.png",
	"em4_s6_2_26": "32_en_scene6_2_never_yield_chief.png",
}

const CHOICE_PICKS := {
	"em4_choice_c1": "choice_em4_c1_a",
	"em4_choice_c2": "choice_em4_c2_a",
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

func set_exact_day_clock(g: RefCounted, target_day: int, absolute_clock: int) -> void:
	g.discarded_overtime_minutes = 0
	g.story_time_advance_minutes = 0
	var base_elapsed: int = g.elapsed()
	var desired_total: int = (maxi(1, target_day) - 1) * int(g.SHIFT_MINUTES) + clampi(absolute_clock - int(g.SHIFT_START_MINUTE), 0, int(g.SHIFT_MINUTES) - 1)
	g.story_time_advance_minutes = maxi(0, desired_total - base_elapsed)

func save_shot(filename: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var out_path := ProjectSettings.globalize_path("res://%s/%s" % [OUT_DIR, filename])
	var img: Image = app.get_viewport().get_texture().get_image()
	expect(img != null and img.get_width() > 0 and img.get_height() > 0, "Viewport image valid for " + filename)
	var err := img.save_png(out_path)
	expect(err == OK, "Saved screenshot " + out_path)

func finish_fast(id: String) -> void:
	var ev = app.game.start_character_event(id)
	expect(ev != null, "Started fast setup " + id)
	var guard := 0
	while ev != null and not ev.completed and guard < 450:
		guard += 1
		app.game.choose_character_event(str(ev.current().choices[0].id))
	app.game.finish_character_event()

func setup_base(locale: String, target_day: int, target_clock: int) -> void:
	expect(app.content.load_all(locale), "load_all " + locale)
	app.configure_game_content()
	app.game.reset()
	set_exact_day_clock(app.game, 1, 600)
	app.game._complete_character_event_for_test("intro_doc_asuka_director_office", 1)
	app.game.meet_staff("doc_asuka")
	app.game._complete_character_event_for_test("asuka_mentions_artoria_rival", 1)
	app.game.meet_staff("doc_artoria")
	app.game._complete_character_event_for_test("intro_doc_artoria_deputy_office", 2)
	app.game.set_test_player_attribute("skill", 70)
	finish_fast(LV0)

	app.game.advance_story_to_day(4, 600)
	app.game.set_test_player_attribute("skill", 75)
	finish_fast(LV1)

	app.game.advance_story_to_day(8, 600)
	app.game.set_test_player_attribute("skill", 80)
	finish_fast(LV2)

	set_exact_day_clock(app.game, 11, 990)
	app.game.relation_for("doc_emiko").familiarity = 40
	app.game.set_test_player_attribute("presence", 20)
	finish_fast(LV3)

	set_exact_day_clock(app.game, target_day, target_clock)
	app.game.relation_for("doc_emiko").familiarity = 55
	app.game.set_test_player_attribute("presence", 30)

func play_full_run(locale: String, shot_map: Dictionary, h_runner_shot: String, complete_shot: String, staff_booking_shot: String) -> void:
	expect(app._start_exclusive_departure_event(), locale + ": _start_exclusive_departure_event launched Lv4")
	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, locale + ": Lv4 active on character_event screen")

	var captured := {}
	var captured_h_runner := false
	var guard := 0
	while app.screen in ["character_event", "h_profile_test"] and app.game.character_events.has(EVENT_ID) and not app.game.character_events[EVENT_ID].completed and guard < 650:
		guard += 1
		if app.screen == "h_profile_test":
			captured_h_runner = true
			await save_shot(h_runner_shot)
			while app.h_profile_test_session.excitement < 100:
				app.h_profile_test_last_result = app.h_profile_test_session.perform("kiss", "lips")
			app.show_sayaka_h_profile_test()
			app._choose_sayaka_h_entry_style("gentle" if locale == "zh_CN" else "intense")
			for _i in range(6):
				app._advance_sayaka_h_stage()
			app._choose_sayaka_h_finish()
			app._advance_sayaka_h_stage()
			await create_timer(4.8).timeout
			continue
		var cur: Dictionary = app.game.character_events[EVENT_ID].current()
		var nid := str(cur.id)
		if shot_map.has(nid) and not captured.has(nid):
			captured[nid] = true
			await save_shot(str(shot_map[nid]))
		var cont_btn = app.page.get_node_or_null("EventDialogueContinue")
		if cont_btn != null:
			app.advance_dialogue_page(app.show_character_event)
			continue
		if CHOICE_PICKS.has(nid):
			app.choose_character_event(str(CHOICE_PICKS[nid]))
		else:
			app.choose_character_event(str(cur.choices[0].id))

	expect(captured_h_runner, locale + ": captured real milestone H Runner screen")
	expect(app.game.character_events[EVENT_ID].completed, locale + ": event completed")
	for want_nid in shot_map.keys():
		expect(captured.has(want_nid), "%s: captured node %s" % [locale, want_nid])
	expect(app.screen == "character_event_complete", locale + ": completion screen visible")
	expect(app.game.clock_text() == "09:00" and app.game.relationship_level("doc_emiko") == 4, locale + ": settled at 09:00 with Lv4")
	await save_shot(complete_shot)
	app.game.finish_character_event()
	var present_loc := "or"
	for loc_def in app.content.collections.locations:
		if "doc_emiko" in app.game.staff_present_at(str(loc_def.id)):
			present_loc = str(loc_def.id)
			break
	app.show_staff("doc_emiko", present_loc)
	await save_shot(staff_booking_shot)
	app.show_map(false)

func run() -> void:
	expect(DisplayServer.get_name() != "headless", "Must run in native non-headless window")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://" + OUT_DIR))
	var gdignore := FileAccess.open(ProjectSettings.globalize_path("res://%s/.gdignore" % OUT_DIR), FileAccess.WRITE)
	if gdignore != null:
		gdignore.close()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.title_notice_enabled = false
	app.saves.path = "/private/tmp/emiko_lv4_preview_unused_%s.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/emiko_lv4_preview_prefs_%s.cfg" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	# 1. Chinese Relationship Progress UI before Lv4 + full playthrough + H Runner Placeholder + Staff Pending Assets
	setup_base("zh_CN", 15, 990)
	app.show_office_relationship_detail("doc_emiko", true)
	await save_shot("01_zh_progress_ui_lv4_ready.png")
	await play_full_run(
		"zh_CN",
		ZH_SHOTS,
		"20_zh_scene6_h_runner_placeholder.png",
		"24_zh_complete_screen_0900.png",
		"25_zh_staff_free_h_pending_assets.png"
	)

	# 2. English full playthrough + H Runner Placeholder + Staff Pending Assets
	setup_base("en", 15, 990)
	await play_full_run(
		"en",
		EN_SHOTS,
		"31_en_scene6_h_runner_placeholder.png",
		"33_en_complete_screen_0900.png",
		"34_en_staff_free_h_pending_assets.png"
	)

	DirAccess.remove_absolute(app.saves.path)
	DirAccess.remove_absolute(app.title_preferences_path)
	app.queue_free()
	await process_frame
	print("EMIKO LV4 NATIVE PREVIEW: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures > 0 else 0)
