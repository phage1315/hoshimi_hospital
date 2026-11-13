extends SceneTree
## Automated native windowed GUI playthrough and 10-screen visual preview capture for
## Shiori Fujisaki's Relationship Lv2 event V1.0: 《唱片店里的藤崎诗织》 (shiori_lv2_record_shop).

const ID := "shiori_lv2_record_shop"
const OUT_DIR := "docs/qa/shiori_lv2_preview_2026-11-12"

const TARGET_CAPTURES := {
	"slv2_003": "preview_01_s1_yuko_solo_sigh.png",
	"slv2_010": "preview_02_s1_reunion_shock_surprised.png",
	"slv2_069": "preview_03_s2_palpation_nervous_wry.png",
	"slv2_093": "preview_04_s2_relief_gentle_smile.png",
	"slv2_100": "preview_05_s2_choice1_ward_tease.png",
	"slv2_135": "preview_06_s3_hallway_invite.png",
	"slv2_163": "preview_07_s4_record_shop_chopin_enthusiastic.png",
	"slv2_198": "preview_08_s5_headband_pensive_shy.png",
	"slv2_218": "preview_09_s6_station_plaza_choice3.png",
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
	var tmp_save := "/private/tmp/shiori_lv2_preview_unused_%s.json" % OS.get_process_id()

	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = tmp_save
	root.add_child(app)
	await process_frame

	expect(app.content.load_all("zh_CN"), "Load zh_CN content")
	app.configure_game_content()
	app.dialogue_auto_enabled = false

	expect(app.game.prepare_character_event_test_save(ID), "Prepare isolated Shiori Lv2 fixture")
	app.game.advance_story_to_day(app.game.day_number(), 865) # 14:25
	app.show_location("ward", false, false, true)
	await capture_viewport("preview_00_ward_entry.png")

	var event = app.game.start_character_event(ID)
	expect(event != null, "Start shiori_lv2_record_shop")
	app.character_event_return_location = "ward"
	app.reset_dialogue_page()
	app.show_character_event()
	await process_frame

	var captured := {}
	var steps := 0
	while not event.completed and steps < 260:
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
	expect(app.screen == "day_transition", "Cross-day transition displayed")
	await capture_viewport("preview_10_day_transition.png")
	if app.screen == "day_transition":
		var dt_btn: Button = app.page.get_node_or_null("DayTransitionContinue")
		expect(dt_btn != null, "DayTransitionContinue exists")
		if dt_btn != null:
			dt_btn.pressed.emit()
			await process_frame
	var expected_safe_screen := "sunday_menu" if app.game.is_sunday() else "map"
	expect(app.screen == expected_safe_screen and int(app.game.relation_for("doc_shiori").get("level", 0)) == 2, "Next-morning safe screen settled at Lv2")
	app.show_staff("doc_shiori", "ward")
	await capture_viewport("preview_11_next_morning_staff_lv2.png")

	# Capture live English runtime screenshot on slv2_169 (Chopin second movement comparison in record shop)
	expect(app.content.load_all("en"), "Load en content")
	app.configure_game_content()
	expect(app.game.prepare_character_event_test_save(ID), "Prepare EN Shiori Lv2 fixture")
	app.game.advance_story_to_day(app.game.day_number(), 865)
	var en_event = app.game.start_character_event(ID)
	expect(en_event != null, "Start EN shiori_lv2_record_shop")
	while not en_event.completed and str(en_event.current().get("id", "")) != "slv2_169":
		var ch: Array = en_event.current().get("choices", [])
		app.game.choose_character_event(str(ch[0].get("id", "")))
	app.reset_dialogue_page()
	app.show_character_event()
	await capture_viewport("preview_12_en_record_shop_chopin.png")

	if FileAccess.file_exists(tmp_save):
		DirAccess.remove_absolute(tmp_save)

	expect(captured.size() == TARGET_CAPTURES.size(), "Captured all 9 target expression screens (got %s)" % captured.size())
	print("SHIORI LV2 PREVIEW CAPTURE: %s/9 target screens + ward + completion + EN saved; %s checks; %s failure(s)" % [captured.size(), checks, failures])
	quit(1 if failures else 0)
