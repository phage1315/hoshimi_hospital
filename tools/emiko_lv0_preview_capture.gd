extends SceneTree
## Native windowed 1280x800 UI playthrough & screenshot verification for
## Emiko Mido (`doc_emiko`) Lv0 V1.2: 《传闻中的手》 (`emiko_intro_rumored_hands`).
## Uses isolated /private/tmp paths only; never touches real player save slots.

const EVENT_ID := "emiko_intro_rumored_hands"
const OUT_DIR := "docs/qa/emiko_lv0_2026-11-14"

const ZH_SHOTS := {
	"em0_001": "02_zh_opening_summons.png",
	"em0_003": "03_zh_office_sit.png",
	"em0_017": "04_zh_operative_note_question.png",
	"em0_020": "05_zh_sakaguchi_plane_answer.png",
	"em0_030": "06_zh_three_choices.png",
	"em0_a_03": "07_zh_face_branch_smile.png",
	"em0_040": "08_zh_rumored_hands_finale.png",
}

const EN_SHOTS := {
	"em0_017": "11_en_operative_note_question.png",
	"em0_030": "12_en_three_choices.png",
	"em0_a_03": "13_en_face_branch_smile.png",
	"em0_040": "14_en_rumored_hands_finale.png",
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

func clear_dialogs() -> void:
	var list: Array = []
	for child in app.get_children():
		if child is AcceptDialog:
			list.append(child)
	for d in list:
		d.hide()
		app.remove_child(d)
		d.free()

func play_locale(locale: String, shot_map: Dictionary, hint_shot: String, complete_shot: String) -> void:
	expect(app.content.load_all(locale), "load_all " + locale)
	app.configure_game_content()
	app.game.reset()
	app.game.set_test_time(6, 600)
	app.game._complete_character_event_for_test("intro_doc_asuka_director_office", 2)
	app.game.meet_staff("doc_asuka")
	app.game.set_test_player_attribute("skill", 64)
	app.show_location("emiko_office")
	app.introduce_staff_at_location("doc_emiko", "emiko_office")
	await save_shot(hint_shot)
	clear_dialogs()

	app.game.set_test_player_attribute("skill", 70)
	app.introduce_staff_at_location("doc_emiko", "emiko_office")
	expect(app.screen == "character_event" and app.game.active_character_event_id == EVENT_ID, locale + ": event started")

	var captured := {}
	var guard := 0
	while app.screen == "character_event" and app.game.character_events.has(EVENT_ID) and not app.game.character_events[EVENT_ID].completed and guard < 120:
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
		if nid == "em0_030":
			app.choose_character_event("choice_em0_face")
		else:
			app.choose_character_event(str(cur.choices[0].id))
	expect(app.game.character_events[EVENT_ID].completed, locale + ": event completed")
	app.show_character_event_complete()
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
	app.saves.path = "/private/tmp/emiko_lv0_preview_unused_%s.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/emiko_lv0_preview_prefs_%s.cfg" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	await play_locale("zh_CN", ZH_SHOTS, "01_zh_unlock_hint_70.png", "09_zh_complete_screen.png")
	await play_locale("en", EN_SHOTS, "10_en_unlock_hint_70.png", "15_en_complete_screen.png")

	app.queue_free()
	await process_frame
	print("EMIKO LV0 NATIVE PREVIEW: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures > 0 else 0)
