extends SceneTree
## Native windowed 1280x800 UI playthrough & screenshot verification for
## Emiko Mido (`doc_emiko`) Lv3 V1.1: 《今天我主刀》 (`emiko_lv3_today_i_lead`).
## Uses isolated /private/tmp paths only; never touches real player save slots.

const LV0 := "emiko_intro_rumored_hands"
const LV1 := "emiko_lv1_first_operation"
const LV2 := "emiko_lv2_follow_my_lead"
const EVENT_ID := "emiko_lv3_today_i_lead"
const OUT_DIR := "docs/qa/emiko_lv3_2026-11-15"

const ZH_SHOTS := {
	"em3_s1_05": "03_zh_scene1_sushi_bar_opening.png",
	"em3_s1_17": "04_zh_scene1_yanagiba_clean.png",
	"em3_s1_34": "05_zh_scene1_surgeons_chef.png",
	"em3_s1_44": "06_zh_scene1_director_ambition.png",
	"em3_g_06": "07_zh_scene1_probe_g_roster.png",
	"em3_choice_c1": "08_zh_scene1_choice1_wide.png",
	"em3_s1r_10": "09_zh_scene1_cabg_invitation.png",
	"em3_s2_03": "10a_zh_scene2_patient_27yo_intro.png",
	"em3_s2_06": "10_zh_scene2_moe_preinduction.png",
	"em3_s2_08": "10b_zh_scene2_patient_panicked_plea.png",
	"em3_s2_16": "11_zh_scene2_today_i_lead.png",
	"em3_s2_25": "11b_zh_scene2_patient_relieved_trust.png",
	"em3_s2_28": "11c_zh_scene2_moe_27yo_timeout.png",
	"em3_s2_30": "12_zh_scene2_hiroko_timeout.png",
	"em3_s2_32": "12b_zh_scene2_patient_mask_induction.png",
	"em3_s3_05": "13_zh_scene3_lima_harvest.png",
	"em3_choice_c2": "14_zh_scene3_choice2_wide.png",
	"em3_c2a_04": "15_zh_scene3_unspoken_sync.png",
	"em3_s4_11": "16_zh_scene4_postop_dismissal.png",
	"em3_s4_19": "17_zh_scene4_closed_or_door.png",
	"em3_s5_18": "18_zh_scene5_rv_geometry.png",
	"em3_s6_06": "19_zh_scene6_no_score_today.png",
	"em3_s6_11": "20_zh_scene6_blue_cabg_notebook.png",
	"em3_choice_c3": "21_zh_scene6_choice3_wide.png",
	"em3_s6r_02": "22_zh_scene6_dont_expect_me_to_yield.png",
}

const EN_SHOTS := {
	"em3_s_06": "25_en_scene1_probe_s_artoria.png",
	"em3_s2_16": "26_en_scene2_today_i_lead.png",
	"em3_s2_28": "26b_en_scene2_27yo_timeout.png",
	"em3_s2_32": "26c_en_scene2_mask_induction.png",
	"em3_choice_c2": "27_en_scene3_choice2_wide.png",
	"em3_s6_11": "28_en_scene6_blue_cabg_notebook.png",
}

const CHOICE_PICKS := {
	"em3_choice_c1": "choice_em3_c1_a",
	"em3_choice_c2": "choice_em3_c2_a",
	"em3_choice_c3": "choice_em3_c3_a",
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
	while ev != null and not ev.completed and guard < 400:
		guard += 1
		app.game.choose_character_event(str(ev.current().choices[0].id))
	app.game.finish_character_event()

func setup_base(locale: String, meet_artoria: bool, target_day: int, target_clock: int) -> void:
	expect(app.content.load_all(locale), "load_all " + locale)
	app.configure_game_content()
	app.game.reset()
	set_exact_day_clock(app.game, 1, 600)
	app.game._complete_character_event_for_test("intro_doc_asuka_director_office", 1)
	app.game.meet_staff("doc_asuka")
	app.game._complete_character_event_for_test("asuka_mentions_artoria_rival", 1)
	if meet_artoria:
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

	set_exact_day_clock(app.game, target_day, target_clock)
	app.game.relation_for("doc_emiko").familiarity = 40
	app.game.set_test_player_attribute("presence", 20)
	app.game.relation_for("nurse_hiroko").met = false
	app.game.relation_for("nurse_moe").met = false

func play_full_run(locale: String, shot_map: Dictionary, complete_shot: String) -> void:
	expect(app._start_exclusive_departure_event(), locale + ": _start_exclusive_departure_event launched Lv3")
	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, locale + ": Lv3 active on character_event screen")

	var captured := {}
	var guard := 0
	while app.screen == "character_event" and app.game.character_events.has(EVENT_ID) and not app.game.character_events[EVENT_ID].completed and guard < 600:
		guard += 1
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

	expect(app.game.character_events[EVENT_ID].completed, locale + ": event completed")
	for want_nid in shot_map.keys():
		expect(captured.has(want_nid), "%s: captured node %s" % [locale, want_nid])
	expect(app.screen == "character_event_complete", locale + ": completion screen visible")
	expect(app.game.clock_text() == "14:00" and app.game.procedure_unlocked("surgery_cabg") and app.game.relationship_level("doc_emiko") == 3, locale + ": settled at 14:00 with CABG unlocked and Lv3")
	await save_shot(complete_shot)
	app.game.finish_character_event()
	app.show_map(false)

func capture_zh_o_branch() -> void:
	setup_base("zh_CN", true, 11, 600)
	var o_pid := str(app.game.patient_queue[0])
	var o_suffix := o_pid.trim_prefix("patient_")
	var v = app.game.open_visit("visit_" + o_suffix)
	if v != null:
		v.admitted = true
	var p = app.game.open_preop("preop_" + o_suffix)
	if p != null:
		p.team["assistant_surgeon"] = "doc_sayaka"
		p.surgery_success = true
	app.game.active_preop_id = ""
	app.game.active_id = ""
	if not app.game.recent_patient_ids.has(o_pid):
		app.game.recent_patient_ids.append(o_pid)
	# Jump to December routine weekday (`2025-12-04` = Day 248, Thursday) at 16:30 to verify winter casual too!
	set_exact_day_clock(app.game, 248, 990)
	expect(app._start_exclusive_departure_event(), "zh_CN [O]: launched Lv3 in winter O mode")
	var guard := 0
	var got_o := false
	while app.screen == "character_event" and guard < 150:
		guard += 1
		var cur: Dictionary = app.game.character_events[EVENT_ID].current()
		var nid := str(cur.id)
		if nid == "em3_o_02":
			expect(str(cur.get("outfit", "")) == "casual_winter" and str(cur.get("text", "")).contains("南条小夜香"), "zh_CN [O]: winter casual_winter + 南条小夜香 substituted")
			await save_shot("24_zh_scene1_probe_o_sayaka_winter.png")
			got_o = true
			break
		var cont_btn = app.page.get_node_or_null("EventDialogueContinue")
		if cont_btn != null:
			app.advance_dialogue_page(app.show_character_event)
		else:
			app.choose_character_event(str(cur.choices[0].id))
	expect(got_o, "zh_CN [O]: captured em3_o_02")

func run() -> void:
	expect(DisplayServer.get_name() != "headless", "Must run in native non-headless window")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://" + OUT_DIR))
	var gdignore := FileAccess.open(ProjectSettings.globalize_path("res://%s/.gdignore" % OUT_DIR), FileAccess.WRITE)
	if gdignore != null:
		gdignore.close()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.title_notice_enabled = false
	app.saves.path = "/private/tmp/emiko_lv3_preview_unused_%s.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/emiko_lv3_preview_prefs_%s.cfg" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	# 1. Chinese Relationship Progress UI before/after meeting Artoria + full G-branch playthrough
	setup_base("zh_CN", false, 11, 990)
	app.show_office_relationship_detail("doc_emiko", true)
	await save_shot("01_zh_progress_ui_artoria_unmet.png")
	app.game.meet_staff("doc_artoria")
	app.game._complete_character_event_for_test("intro_doc_artoria_deputy_office", 2)
	app.show_office_relationship_detail("doc_emiko", true)
	await save_shot("02_zh_progress_ui_artoria_met.png")
	await play_full_run("zh_CN", ZH_SHOTS, "23_zh_complete_screen_1400.png")

	# 2. Chinese O-branch + winter casual check
	await capture_zh_o_branch()

	# 3. English S-branch + winter casual + full playthrough
	setup_base("en", true, 248, 990)
	app.game.set_test_character_progress_counter("doc_artoria", "completed_surgeries_as_assistant_surgeon", 1)
	await play_full_run("en", EN_SHOTS, "29_en_complete_screen_1400.png")

	app.queue_free()
	await process_frame
	print("EMIKO LV3 NATIVE PREVIEW: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures > 0 else 0)
