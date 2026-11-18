extends SceneTree
## Native windowed 1280x800 UI playthrough & screenshot verification for
## Emiko Mido (`doc_emiko`) Lv1 V2.2: 《她的手术》 (`emiko_lv1_first_operation`).
## Uses isolated /private/tmp paths only; never touches real player save slots.

const LV0 := "emiko_intro_rumored_hands"
const EVENT_ID := "emiko_lv1_first_operation"
const OUT_DIR := "docs/qa/emiko_lv1_2026-11-14"

const ZH_SHOTS := {
	"em1_007": "02_zh_scene_a_thirty_seconds_late.png",
	"em1_008": "03_zh_scene_a_hiroko_moe_gowning.png",
	"em1_014": "04_zh_scene_a_patient_reassurance.png",
	"em1_027": "05_zh_scene_a_do_surgery_well.png",
	"em1_choice_b1": "06_zh_scene_b_choice_b1_wide.png",
	"em1_062": "07_zh_scene_b_hiroko_warm_glance.png",
	"em1_068": "08_zh_scene_c_stop_my_hand.png",
	"em1_choice_c1": "09_zh_scene_c_choice_c1_wide.png",
	"em1_099": "10_zh_scene_c_v22_fix4_dual_check.png",
	"em1_134": "11_zh_scene_d_interesting_laugh.png",
	"em1_144": "12_zh_scene_d_very_much.png",
	"em1_choice_e1": "13_zh_scene_e_choice_e1_wide.png",
	"em1_156": "14_zh_scene_e_v22_fix2_sterile_hands.png",
	"em1_170": "15_zh_scene_e_v22_fix3_closing_count.png",
	"em1_174": "16_zh_scene_e_eighty_five_points.png",
	"em1_191": "17_zh_scene_f_pre_unmask_hidden_portrait.png",
	"em1_194": "18_zh_scene_f_unmasked_bright_eyes.png",
	"em1_208": "19_zh_scene_f_or_entrance_lingering.png",
}

const EN_SHOTS := {
	"em1_007": "21_en_scene_a_thirty_seconds_late.png",
	"em1_choice_c1": "22_en_scene_c_choice_c1_wide.png",
	"em1_144": "23_en_scene_d_very_much.png",
	"em1_194": "24_en_scene_f_unmasked_bright_eyes.png",
}

const CHOICE_PICKS := {
	"em1_choice_b1": "choice_em1_b1_a",
	"em1_choice_c1": "choice_em1_c1_a",
	"em1_choice_e1": "choice_em1_e1_a",
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

func finish_lv0_fast() -> void:
	var ev = app.game.start_character_event(LV0)
	expect(ev != null, "Started Lv0 fast setup")
	var guard := 0
	while ev != null and not ev.completed and guard < 120:
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
	finish_lv0_fast()

	var play_day := 13
	app.game.advance_story_to_day(play_day, 600)
	while app.game.is_hospital_closed_day():
		play_day += 1
		app.game.advance_story_to_day(play_day, 600)
	app.game.set_test_player_attribute("skill", 75)
	app.game.relation_for("nurse_hiroko").met = false
	app.game.relation_for("nurse_moe").met = false

	app.show_map(false)
	if not map_shot.is_empty():
		await save_shot(map_shot)

	app.show_location("or")
	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, locale + ": Lv1 started at OR")

	var captured := {}
	var guard := 0
	while app.screen == "character_event" and app.game.character_events.has(EVENT_ID) and not app.game.character_events[EVENT_ID].completed and guard < 400:
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
	app.saves.path = "/private/tmp/emiko_lv1_preview_unused_%s.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/emiko_lv1_preview_prefs_%s.cfg" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	await play_locale("zh_CN", ZH_SHOTS, "01_zh_map_or_story_badge.png", "20_zh_complete_screen.png")
	await play_locale("en", EN_SHOTS, "", "25_en_complete_screen.png")

	app.queue_free()
	await process_frame
	print("EMIKO LV1 NATIVE PREVIEW: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures > 0 else 0)
