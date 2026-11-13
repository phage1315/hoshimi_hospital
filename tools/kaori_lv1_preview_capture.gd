extends SceneTree
## Native windowed UI playthrough and 10-screen visual preview capture for
## Miyama Kaori's Relationship Lv1 event: 《叮。》 (miyama_01_safety_pin V2.3).

const ID := "miyama_01_safety_pin"
const OUT_DIR := "docs/qa/kaori_lv1_preview_2026-11-10"

const TARGET_CAPTURES := {
	"klv1_003": "preview_01_scene1_exam_kita_smile.png",
	"klv1_017": "preview_02_scene1_xray_pin_shock.png",
	"klv1_044": "preview_03_scene2_gurney_rumi.png",
	"klv1_068": "preview_04_scene3_or_pin_found.png",
	"klv1_145": "preview_05_scene4_palpation_round3.png",
	"klv1_157": "preview_06_scene5_choice1.png",
	"klv1_188": "preview_06b_scene5_shaving_cg.png",
	"klv1_201": "preview_07_scene5_disinfection_cg.png",
	"klv1_236": "preview_08a_scene6_surgical_team.png",
	"klv1_242": "preview_08_scene6_negative_laparotomy.png",
	"klv1_266": "preview_09_scene7_postop_ward.png",
	"klv1_293": "preview_10_scene7_choice2_corridor.png",
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
	app.saves.path = "/private/tmp/kaori_lv1_preview_unused_%s.json" % OS.get_process_id()
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
	app.game.set_story_flag("__test_save_target_event__" + ID, true)

	var event = app.game.start_special_event(ID)
	expect(event != null, "Start miyama_01_safety_pin")
	app.special_event_last_cg_path = ""
	app.reset_dialogue_page()
	app.show_special_event()
	await process_frame

	var captured := {}
	var steps := 0
	while not event.completed and steps < 400:
		steps += 1
		var step: Dictionary = event.current_step()
		var node: Dictionary = event.current()
		var nid := str(node.get("id", ""))
		var loc_text: String = app.special_event_localized_text(step, node)
		var pages: Array = app.authored_dialogue_pages(loc_text)
		for page_idx in range(pages.size()):
			app.dialogue_page_index = page_idx
			app.show_special_event()
			await process_frame
			if TARGET_CAPTURES.has(nid) and page_idx == pages.size() - 1 and not captured.has(nid):
				# Ensure CG delayed buttons are visible for clean UI inspection if desired
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
		var button: Button = app.page.get_node_or_null("SpecialEventChoice_" + str(choices[0].id))
		expect(button != null, "UI button exists at " + nid)
		if button == null:
			break
		button.pressed.emit()
		await process_frame

	expect(event.completed, "Special event completed in UI")
	expect(captured.size() == TARGET_CAPTURES.size(), "Captured all preview screens (got %s)" % captured.size())
	print("KAORI LV1 PREVIEW CAPTURE: %s/%s screens saved; %s checks; %s failure(s)" % [captured.size(), TARGET_CAPTURES.size(), checks, failures])
	quit(1 if failures else 0)
