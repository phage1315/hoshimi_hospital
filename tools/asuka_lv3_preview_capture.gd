extends SceneTree
## Native windowed 1280x800 UI playthrough & screenshot capture for
## Asuka Shiromiya (`doc_asuka`) Relationship Lv3: 《本院长不接受反驳哦》
## (`asuka_lv3_no_objections`).
##
## Captures 20 live-rendered 1280x800 screenshots across `zh_CN` (A-1) and `en` (A-2):
## - Sunday Invite screen with `doc_asuka` pinned to top + story badge
## - Scene A-1 (`zh_CN`) and Scene A-2 (`en`) outside `cafe_exterior_day`
## - Scene B inside `date_cafe` + return-to-hospital laugh outside `cafe_exterior_day`
## - Scene C–E inside `hospital_archive_room_afternoon` (`smile`, `nostalgic`, `playful`, `shy`)
## - Scene F full-screen `CharacterEventCG` (`vintage_cream_gown_mirror.png`) +
##   standing `vintage_cream_gown/{shy_earnest,blushing_happy}`
## - Scene G `hospital_courtyard_evening` dusk farewell
## - `sunday_complete` Relationship Lv3 screen (`zh_CN` & `en`) + unlocked `GalleryCG`

const EVENT_ID := "asuka_lv3_no_objections"
const OUT_DIR := "docs/qa/asuka_lv3_2026-11-14"

const ZH_SHOTS := {
	"al3_a1_005": "02_zh_scene_a1_cafe_exterior_playful.png",
	"al3_016": "03_zh_scene_a_merge_shy.png",
	"al3_020": "04_zh_scene_b_cafe_dessert_nostalgic.png",
	"al3_035": "05_zh_scene_b_cafe_hobby_secret.png",
	"al3_048": "06_zh_scene_b_return_to_hospital_laugh.png",
	"al3_052": "07_zh_scene_c_archive_room_smile.png",
	"al3_071": "08_zh_scene_c_scrub_dress_nostalgic.png",
	"al3_091": "09_zh_scene_e_no_objections_playful.png",
	"al3_107": "10_zh_scene_e_first_gown_hot_shy.png",
	"al3_136": "11_zh_scene_f_mirror_cg_reveal.png",
	"al3_145": "12_zh_scene_f_gown_shy_earnest.png",
	"al3_153": "13_zh_scene_f_gown_blushing_happy.png",
	"al3_162": "14_zh_scene_g_dusk_courtyard.png",
}

const EN_SHOTS := {
	"al3_a2_008": "17_en_scene_a2_prior_date_opening.png",
	"al3_091": "18_en_scene_e_no_objections.png",
	"al3_136": "19_en_scene_f_mirror_cg.png",
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
	for child in app.page.get_children():
		if child is CanvasItem and str(child.name) not in ["EventStageEffect", "CalendarHeader"]:
			child.show()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var out_path := ProjectSettings.globalize_path("res://%s/%s" % [OUT_DIR, filename])
	var img: Image = app.get_viewport().get_texture().get_image()
	expect(img != null and img.get_width() > 0 and img.get_height() > 0, "Viewport image valid for " + filename)
	var err := img.save_png(out_path)
	expect(err == OK, "Saved screenshot " + out_path)

func check_dialogue_bounds(nid: String, locale: String) -> void:
	var dlg: Node = app.page.get_node_or_null("CharacterEventDialogue")
	if dlg != null:
		for child in dlg.get_children():
			if child is Label:
				var lbl := child as Label
				expect(lbl.position.x + lbl.size.x <= 1280.0 and lbl.position.y + lbl.size.y <= 800.0, "%s %s label in viewport" % [locale, nid])

func play_and_capture(
	locale: String,
	prior_date: bool,
	shot_map: Dictionary,
	invite_shot: String,
	complete_shot: String,
	gallery_shot: String
) -> void:
	expect(app.content.load_all(locale), "load_all " + locale)
	app.configure_game_content()
	expect(app.game.prepare_character_event_test_save(EVENT_ID), locale + ": prepare_character_event_test_save")
	app.game.clear_test_save_target()
	app.character_event_from_test = false

	# Seed realistic known colleagues so Sunday invite screen looks natural
	for sid in ["doc_aoi", "doc_sayaka", "doc_emiko", "nurse_hiroko"]:
		if app.game.relationships.has(sid):
			app.game.meet_staff(sid)
			var srel: Dictionary = app.game.relation_for(sid)
			srel.met = true
			srel.level = 1
			srel.familiarity = 30

	if prior_date:
		app.game.sunday_history.append({
			"day": 6,
			"activity_id": "date",
			"actor_id": "doc_asuka",
			"location_id": "aquarium",
		})
		app.game.increment_character_progress_counter("doc_asuka", "completed_sunday_dates")

	app.show_sunday_invites()
	await process_frame
	expect(app.screen == "sunday_invites", locale + ": rendered sunday_invites")
	if not invite_shot.is_empty():
		await save_shot(invite_shot)

	app.attempt_sunday_invitation("doc_asuka")
	await process_frame
	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, locale + ": launched Asuka Lv3")

	var captured := {}
	var guard := 0
	while app.game.active_character_event_id == EVENT_ID and guard < 420:
		guard += 1
		var ev = app.game.character_events[EVENT_ID]
		if ev.completed:
			break
		var node: Dictionary = ev.current()
		var nid := str(node.get("id", ""))
		check_dialogue_bounds(nid, locale)
		if shot_map.has(nid) and not captured.has(nid):
			captured[nid] = true
			await save_shot(str(shot_map[nid]))
		var page_btn := app.page.get_node_or_null("EventDialogueContinue") as Button
		if page_btn != null:
			app.advance_dialogue_page(app.show_character_event)
			await process_frame
			continue
		var ch_list: Array = node.get("choices", [])
		app.choose_character_event(str(ch_list[0].id))
		await process_frame

	for k in shot_map.keys():
		expect(captured.has(k), locale + ": captured node " + str(k))
	expect(app.screen == "sunday_complete", locale + ": reached sunday_complete")
	await save_shot(complete_shot)

	app.show_map(false)
	await process_frame
	if not gallery_shot.is_empty():
		app.show_gallery_entry(EVENT_ID)
		await process_frame
		expect(app.screen == "gallery_entry" and app.page.get_node_or_null("GalleryCG") != null, locale + ": GalleryCG rendered")
		await save_shot(gallery_shot)
		app.show_map(false)
		await process_frame

func run() -> void:
	var pid := OS.get_process_id()
	var tmp_save_path := "/private/tmp/asuka_lv3_preview_unused_%s.json" % pid
	var tmp_prefs_path := "/private/tmp/asuka_lv3_preview_prefs_%s.cfg" % pid
	var packed: PackedScene = load("res://godot/scenes/main.tscn")
	app = packed.instantiate()
	app.title_notice_enabled = false
	app.title_preferences_path = tmp_prefs_path
	app.saves.path = tmp_save_path
	root.add_child(app)
	await process_frame
	await process_frame
	if app.page.get_node_or_null("StartupContentNotice") != null:
		var ok_btn: Button = app.page.find_child("StartupNoticeConfirm", true, false) as Button
		if ok_btn != null:
			ok_btn.pressed.emit()
			await process_frame

	await play_and_capture(
		"zh_CN",
		false,
		ZH_SHOTS,
		"01_zh_sunday_invites_story_badge.png",
		"15_zh_sunday_complete_lv3.png",
		"16_zh_gallery_cg_unlocked.png"
	)
	await play_and_capture(
		"en",
		true,
		EN_SHOTS,
		"",
		"20_en_sunday_complete_lv3.png",
		""
	)

	for p in [tmp_save_path, tmp_prefs_path]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

	print("ASUKA LV3 PREVIEW CAPTURE: %d checks, %d failure(s)." % [checks, failures])
	quit(1 if failures > 0 else 0)
