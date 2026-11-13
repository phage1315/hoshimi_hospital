extends SceneTree
## Native windowed UI playthrough and 8-screen visual preview capture for
## Shiori Fujisaki's Relationship Lv1 event V1.2: 《藤崎医生的烦恼》 (shiori_lv1_doctors_worry).

const ID := "shiori_lv1_doctors_worry"
const OUT_DIR := "docs/qa/shiori_lv1_preview_2026-11-11"

const TARGET_CAPTURES := {
	"slv1_005": "preview_01_s1_greeting_neutral.png",
	"slv1_019": "preview_02_s1_card_autograph_wry_smile.png",
	"slv1_025": "preview_03_s1_teasing_shy_reproach.png",
	"slv1_039": "preview_04_s2_clinical_poise_professional.png",
	"slv1_046": "preview_05_s2_white_coat_pensive.png",
	"slv1_065": "preview_06_s3_himoo_yuina_gentle_smile.png",
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

func capture_viewport(filename: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var out_path := ProjectSettings.globalize_path("res://%s/%s" % [OUT_DIR, filename])
	var err: int = app.get_viewport().get_texture().get_image().save_png(out_path)
	expect(err == OK, "Saved preview screenshot " + out_path)

func run() -> void:
	var abs_out := ProjectSettings.globalize_path("res://" + OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_out)
	var tmp_save := "/private/tmp/shiori_lv1_preview_unused_%s.json" % OS.get_process_id()

	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = tmp_save
	root.add_child(app)
	await process_frame

	expect(app.content.load_all("zh_CN"), "Load zh_CN content")
	app.configure_game_content()
	app.dialogue_auto_enabled = false

	# Set up production Lv0 -> Lv1 state at Staff Lounge 15:15
	expect(app.game.prepare_character_event_test_save(ID), "Prepare isolated Shiori Lv1 fixture")
	app.game.advance_story_to_day(app.game.day_number(), 915)
	app.show_location("lounge", false, false, true)
	await capture_viewport("preview_00_lounge_entry.png")

	var event = app.game.start_character_event(ID)
	expect(event != null, "Start shiori_lv1_doctors_worry")
	app.reset_dialogue_page()
	app.show_character_event()
	await process_frame

	var captured := {}
	var steps := 0
	while not event.completed and steps < 150:
		steps += 1
		var node: Dictionary = event.current()
		var nid := str(node.get("id", ""))
		var pages: Array = app.authored_dialogue_pages(str(node.get("text", "")))
		for page_idx in range(pages.size()):
			app.dialogue_page_index = page_idx
			app.show_character_event()
			await process_frame
			if TARGET_CAPTURES.has(nid) and page_idx == pages.size() - 1 and not captured.has(nid):
				await capture_viewport(TARGET_CAPTURES[nid])
				captured[nid] = true

		var choices: Array = node.get("choices", [])
		expect(not choices.is_empty(), "Choices exist at " + nid)
		var button: Button = app.page.get_node_or_null("EventChoice_" + str(choices[0].id))
		expect(button != null, "UI button exists at " + nid)
		if button == null:
			break
		button.pressed.emit()
		await process_frame

	expect(event.completed, "Event completed in UI")
	await capture_viewport("preview_07_completion_lv1.png")

	# Also capture an English runtime frame on slv1_092 to verify live EN rendering
	expect(app.content.load_all("en"), "Load en content")
	app.configure_game_content()
	expect(app.game.prepare_character_event_test_save(ID), "Prepare EN Shiori Lv1 fixture")
	app.game.advance_story_to_day(app.game.day_number(), 915)
	var en_event = app.game.start_character_event(ID)
	expect(en_event != null, "Start EN shiori_lv1_doctors_worry")
	while not en_event.completed and str(en_event.current().get("id", "")) != "slv1_092":
		var ch: Array = en_event.current().get("choices", [])
		app.game.choose_character_event(str(ch[0].get("id", "")))
	app.reset_dialogue_page()
	app.show_character_event()
	await capture_viewport("preview_08_en_s4_farewell.png")

	if FileAccess.file_exists(tmp_save):
		DirAccess.remove_absolute(tmp_save)

	expect(captured.size() == TARGET_CAPTURES.size(), "Captured all 6 expression screens (got %s)" % captured.size())
	print("SHIORI LV1 PREVIEW CAPTURE: %s/6 expression screens + lounge + completion + EN saved; %s checks; %s failure(s)" % [captured.size(), checks, failures])
	quit(1 if failures else 0)
