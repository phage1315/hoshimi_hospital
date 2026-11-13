extends SceneTree
## Native windowed UI playthrough and 6-screen visual preview capture for
## Miyama Kaori's Relationship Lv2 event: 《取材过头了》 (miyama_02_manga_artist_wrong_patient V9.1).

const LV1_ID := "miyama_01_safety_pin"
const ID := "miyama_02_manga_artist_wrong_patient"
const OUT_DIR := "docs/qa/kaori_lv2_preview_2026-11-10"

const TARGET_CAPTURES := {
	"s01_016": "preview_01_scene01_safety_pin_callback.png",
	"s01_020": "preview_02_scene01_jinx_smile.png",
	"s24_006": "preview_03_scene24_conference_wristband.png",
	"s25b_003": "preview_04_scene25b_asuka_kaori_private.png",
	"s25b_014": "preview_05_scene25b_med_school_friends.png",
	"s32_016": "preview_06_scene32_or_god_foreshadowing.png",
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

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://" + OUT_DIR))
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/kaori_lv2_preview_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	expect(app.content.load_all("zh_CN"), "Load zh_CN content")
	app.configure_game_content()
	app.dialogue_auto_enabled = false

	# Set up formal prerequisites in memory without touching player saves.
	var intro = app.game.start_character_event("intro_doc_rei")
	while intro != null and not intro.completed:
		app.game.choose_character_event(str(intro.current().choices[0].id))
	app.game.active_character_event_id = ""
	app.game.active_mode = "encounter"
	app.game.meet_staff("doc_asuka")
	app.game.add_familiarity("doc_rei", 10)
	app.game.advance_story_to_day(4, 540)
	app.game.set_story_flag("__test_save_target_event__" + LV1_ID, true)
	var lv1 = app.game.start_special_event(LV1_ID)
	while lv1 != null and not lv1.completed:
		app.game.choose_special_event(str(lv1.current().choices[0].id))
	app.game.finish_special_event()
	app.game.set_story_flag("__test_save_target_event__" + LV1_ID, false)

	app.game.meet_staff("doc_shiori")
	app.game.add_familiarity("doc_rei", 15)
	app.game.advance_story_to_day(8, 540)
	app.game.set_story_flag("__test_save_target_event__" + ID, true)

	var event = app.game.start_special_event(ID)
	expect(event != null, "Start miyama_02_manga_artist_wrong_patient")
	app.special_event_last_cg_path = ""
	app.reset_dialogue_page()
	app.show_special_event()
	await process_frame

	var captured := {}
	var steps := 0
	while not event.completed and steps < 700:
		steps += 1
		var step: Dictionary = event.current_step()
		var node: Dictionary = event.current()
		var nid := str(node.get("id", ""))

		if TARGET_CAPTURES.has(nid) and not captured.has(nid):
			var loc_text: String = app.special_event_localized_text(step, node)
			var pages: Array = app.authored_dialogue_pages(loc_text)
			for page_idx in range(pages.size()):
				app.dialogue_page_index = page_idx
				app.show_special_event()
				await process_frame
			for child in app.page.get_children():
				if child is Button:
					child.show()
			await process_frame
			await RenderingServer.frame_post_draw
			var out_path := ProjectSettings.globalize_path("res://%s/%s" % [OUT_DIR, TARGET_CAPTURES[nid]])
			var err: int = app.get_viewport().get_texture().get_image().save_png(out_path)
			expect(err == OK, "Saved preview screenshot " + out_path)
			captured[nid] = out_path

		var choices: Array = node.get("choices", [])
		expect(not choices.is_empty(), "Choices exist at " + nid)
		var res: Dictionary = app.game.choose_special_event(str(choices[0].id))
		expect(bool(res.get("accepted", false)), "Choice accepted at " + nid)
		if bool(res.get("event_finished", false)):
			app.game.finish_special_event()
			break

	expect(event.completed, "Special event completed")
	expect(captured.size() == TARGET_CAPTURES.size(), "Captured all preview screens (got %s)" % captured.size())
	print("KAORI LV2 PREVIEW CAPTURE: %s/%s screens saved; %s checks; %s failure(s)" % [captured.size(), TARGET_CAPTURES.size(), checks, failures])
	quit(1 if failures else 0)
