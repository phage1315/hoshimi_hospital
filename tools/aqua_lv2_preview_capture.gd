extends SceneTree
## Native windowed UI playthrough and 10-screen visual preview capture for
## Aqua Mizuki's Relationship Lv2 event: 《你要不要学？》 (aqua_lv2_want_to_learn).

const ID := "aqua_lv2_want_to_learn"
const OUT_DIR := "docs/qa/aqua_lv2_preview_2026-11-10"

const TARGET_CAPTURES := {
	"aqlv2_009": "preview_01_scene_a_choice1.png",
	"aqlv2_034": "preview_02_scene_b_hallway.png",
	"aqlv2_065": "preview_03_scene_c_ward_serena_neutral.png",
	"aqlv2_085": "preview_04_scene_c_ward_serena_flustered.png",
	"aqlv2_098": "preview_05_scene_d_preop_prep.png",
	"aqlv2_115": "preview_06_scene_d_or_transfer.png",
	"aqlv2_166": "preview_07_scene_e_manipulator_demo.png",
	"aqlv2_190": "preview_08_scene_e_choice2.png",
	"aqlv2_255": "preview_09_scene_f_pelvic_field_cg.png",
	"aqlv2_284": "preview_10_scene_g_postop_ward.png",
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
	app.saves.path = "/private/tmp/aqua_lv2_preview_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	expect(app.content.load_all("zh_CN"), "Load zh_CN content")
	app.configure_game_content()
	app.dialogue_auto_enabled = false

	expect(app.game.prepare_character_event_test_save(ID), "Prepare isolated Aqua Lv2 test fixture")
	var event = app.game.start_character_event(ID)
	expect(event != null, "Start aqua_lv2_want_to_learn")
	app.reset_dialogue_page()
	app.show_character_event()
	await process_frame

	var captured := {}
	var steps := 0
	while not event.completed and steps < 400:
		steps += 1
		var node: Dictionary = event.current()
		var nid := str(node.get("id", ""))
		var pages: Array = app.authored_dialogue_pages(str(node.get("text", "")))
		for page_idx in range(pages.size()):
			app.dialogue_page_index = page_idx
			app.show_character_event()
			await process_frame
			if TARGET_CAPTURES.has(nid) and page_idx == pages.size() - 1 and not captured.has(nid):
				await process_frame
				await RenderingServer.frame_post_draw
				var out_path := ProjectSettings.globalize_path("res://%s/%s" % [OUT_DIR, TARGET_CAPTURES[nid]])
				var err: int = app.get_viewport().get_texture().get_image().save_png(out_path)
				expect(err == OK, "Saved preview screenshot " + out_path)
				captured[nid] = out_path

		var choices: Array = node.get("choices", [])
		expect(not choices.is_empty(), "Choices exist at " + nid)
		var button: Button = app.page.get_node_or_null("EventChoice_" + str(choices[0].id))
		expect(button != null, "UI button exists at " + nid)
		if button == null:
			break
		button.pressed.emit()
		await process_frame

	expect(event.completed, "Event completed in UI")
	expect(captured.size() == 10, "Captured all 10 preview screens (got %s)" % captured.size())
	print("AQUA LV2 PREVIEW CAPTURE: %s/10 screens saved; %s checks; %s failure(s)" % [captured.size(), checks, failures])
	quit(1 if failures else 0)
