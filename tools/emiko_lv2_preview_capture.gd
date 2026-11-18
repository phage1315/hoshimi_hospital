extends SceneTree
## Native windowed 1280x800 UI playthrough & screenshot verification for
## Emiko Mido (`doc_emiko`) Lv2 V2.1: 《这一次听你的》 (`emiko_lv2_follow_my_lead`).
## Uses isolated /private/tmp paths only; never touches real player save slots.

const LV0 := "emiko_intro_rumored_hands"
const LV1 := "emiko_lv1_first_operation"
const EVENT_ID := "emiko_lv2_follow_my_lead"
const OUT_DIR := "docs/qa/emiko_lv2_2026-11-14"

const ZH_SHOTS := {
	"em2_004": "02_zh_scene_a_hiroko_moe_gowning.png",
	"em2_010": "03_zh_scene_a_primary_is_you.png",
	"em2_017": "04_zh_scene_a_worth_following.png",
	"em2_020": "05_zh_scene_a_moe_timeout.png",
	"em2_022": "06_zh_scene_a_awake_patient.png",
	"em2_039": "07_zh_scene_b_early_mesenteric_flip.png",
	"em2_choice_b1": "08_zh_scene_b_choice_b1_wide.png",
	"em2_083": "09_zh_scene_c_hiroko_warm_banter.png",
	"em2_101": "10_zh_scene_d_pre_anastomotic_divergence.png",
	"em2_choice_d2": "11_zh_scene_d_choice_d2_wide.png",
	"em2_136": "12_zh_scene_d_v21_bevel_suggestion.png",
	"em2_150": "13_zh_scene_d_enough_anastomosis.png",
	"em2_164": "14_zh_scene_e_not_arguing.png",
	"em2_181": "15_zh_scene_e_steadying_morale.png",
	"em2_185": "16_zh_scene_f_preclosure_dual_count.png",
	"em2_198": "17_zh_scene_f_eighty_eight_points.png",
	"em2_choice_f3": "18_zh_scene_f_choice_f3_wide.png",
	"em2_208": "19_zh_scene_f_v21_minus_twelve_reason.png",
	"em2_235": "20_zh_scene_g_corridor_white_coat.png",
	"em2_240": "21_zh_scene_g_when_is_next_one.png",
	"em2_251": "22_zh_scene_g_today_your_limit.png",
}

const EN_SHOTS := {
	"em2_017": "24_en_scene_a_worth_following.png",
	"em2_choice_d2": "25_en_scene_d_choice_d2_wide.png",
	"em2_198": "26_en_scene_f_eighty_eight_points.png",
	"em2_240": "27_en_scene_g_when_is_next_one.png",
}

const CHOICE_PICKS := {
	"em2_choice_b1": "choice_em2_b1_a",
	"em2_choice_d2": "choice_em2_d2_a",
	"em2_choice_f3": "choice_em2_f3_a",
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
	while ev != null and not ev.completed and guard < 350:
		guard += 1
		app.game.choose_character_event(str(ev.current().choices[0].id))
	app.game.finish_character_event()

func play_locale(locale: String, shot_map: Dictionary, map_shot: String, complete_shot: String) -> void:
	expect(app.content.load_all(locale), "load_all " + locale)
	app.configure_game_content()
	app.game.reset()
	app.game.set_test_time(10, 600)
	app.game._complete_character_event_for_test("intro_doc_asuka_director_office", 1)
	app.game.meet_staff("doc_asuka")
	app.game.set_test_player_attribute("skill", 70)
	finish_fast(LV0)

	var lv1_day := 13
	app.game.advance_story_to_day(lv1_day, 600)
	while app.game.is_hospital_closed_day():
		lv1_day += 1
		app.game.advance_story_to_day(lv1_day, 600)
	app.game.set_test_player_attribute("skill", 75)
	finish_fast(LV1)

	var play_day := lv1_day + 3
	app.game.advance_story_to_day(play_day, 600)
	while app.game.is_hospital_closed_day():
		play_day += 1
		app.game.advance_story_to_day(play_day, 600)
	app.game.set_test_player_attribute("skill", 80)
	app.game.relation_for("nurse_hiroko").met = false
	app.game.relation_for("nurse_moe").met = false

	app.show_map(false)
	if not map_shot.is_empty():
		await save_shot(map_shot)

	app.show_location("or")
	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, locale + ": Lv2 started at OR")

	var captured := {}
	var guard := 0
	while app.screen == "character_event" and app.game.character_events.has(EVENT_ID) and not app.game.character_events[EVENT_ID].completed and guard < 450:
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
	await save_shot(complete_shot)
	app.game.finish_character_event()
	app.show_map(false)

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://" + OUT_DIR))
	var gdignore := FileAccess.open(ProjectSettings.globalize_path("res://%s/.gdignore" % OUT_DIR), FileAccess.WRITE)
	if gdignore != null:
		gdignore.close()
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.title_notice_enabled = false
	app.saves.path = "/private/tmp/emiko_lv2_preview_unused_%s.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/emiko_lv2_preview_prefs_%s.cfg" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	await play_locale("zh_CN", ZH_SHOTS, "01_zh_map_or_story_badge.png", "23_zh_complete_screen.png")
	await play_locale("en", EN_SHOTS, "", "28_en_complete_screen.png")

	app.queue_free()
	await process_frame
	print("EMIKO LV2 NATIVE PREVIEW: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures > 0 else 0)
