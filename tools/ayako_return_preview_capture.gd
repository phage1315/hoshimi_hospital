extends SceneTree
## Native windowed UI playthrough and 8-screen visual preview capture for
## Katagiri Ayako's 30-day return arc ("Hoshimi Hospital Story", V1.1).

const AyakoReturn = preload("res://godot/systems/ayako_return.gd")
const OUT_DIR := "docs/qa/ayako_return_preview_2026-11-11"

const EVENT_CAPTURES := [
	{
		"event_id": "ayako_return_00_opening",
		"nodes": {
			"ayr00_033": "preview_01_opening_reunion_casual.png",
			"ayr00_129": "preview_02_opening_uniform_pre_badge.png",
			"ayr00_144": "preview_03_opening_cg01_badge_reveal.png",
			"ayr00_159": "preview_04_opening_badge_uniform_trio.png",
		},
	},
	{
		"event_id": "ayako_return_01_week1_nurses",
		"nodes": {
			"ayr01_062": "preview_05_week1_ishigami_station.png",
		},
	},
	{
		"event_id": "ayako_return_02_week2_sketches",
		"nodes": {
			"ayr02_076": "preview_06_week2_emiko_artoria_clash.png",
		},
	},
	{
		"event_id": "ayako_return_03_week3_shiori",
		"nodes": {
			"ayr03_010": "preview_07_week3_shiori_courtyard.png",
		},
	},
	{
		"event_id": "ayako_return_04_week4_storyboard",
		"nodes": {
			"ayr04_019": "preview_08_week4_cg02_storyboard.png",
		},
	},
	{
		"event_id": "ayako_return_05_departure",
		"nodes": {
			"ayr05_041": "preview_09_departure_lobby_farewell.png",
		},
	},
]

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
	app.saves.path = "/private/tmp/ayako_return_preview_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	expect(app.content.load_all("zh_CN"), "Load zh_CN content")
	app.configure_game_content()
	app.dialogue_auto_enabled = false

	for actor_id in ["doc_rei", "doc_shiori", "doc_asuka", "nurse_haru", "nurse_yui", "doc_serika", "doc_minato"]:
		app.game.relation_for(actor_id).met = true
	app.game.relation_for("doc_rei").level = 4
	app.game.relation_for("doc_shiori").level = 4
	app.game.special_event_completion_counts["miyama_02_manga_artist_wrong_patient"] = 1
	app.game.special_event_completion_days["miyama_02_manga_artist_wrong_patient"] = 20
	app.game.set_story_flag("miyama_02_manga_artist_wrong_patient_completed", true)
	app.game.set_story_flag("ayako_shiori_reconnected", true)

	var total_expected := 0
	var captured := {}

	for spec in EVENT_CAPTURES:
		var ev_id := str(spec.event_id)
		var target_nodes: Dictionary = spec.nodes
		total_expected += target_nodes.size()

		var event = app.game.start_special_event_for_testing(ev_id)
		expect(event != null, "Start preview event " + ev_id)
		if event == null:
			continue
		app.special_event_last_cg_path = ""
		app.reset_dialogue_page()
		app.show_special_event()
		await process_frame

		var guard := 0
		while not event.completed and guard < 400:
			guard += 1
			var step: Dictionary = event.current_step()
			var node: Dictionary = event.current()
			var nid := str(node.get("id", ""))

			if target_nodes.has(nid) and not captured.has(nid):
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
				var out_path := ProjectSettings.globalize_path("res://%s/%s" % [OUT_DIR, str(target_nodes[nid])])
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

	expect(captured.size() == total_expected, "Captured all preview screens (%s/%s)" % [captured.size(), total_expected])
	print("AYAKO RETURN PREVIEW CAPTURE: %s/%s screens saved; %s checks; %s failure(s)" % [captured.size(), total_expected, checks, failures])
	quit(1 if failures else 0)
