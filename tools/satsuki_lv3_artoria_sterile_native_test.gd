extends SceneTree

const SpecialEventSession = preload("res://godot/systems/special_event_session.gd")
const EVENT_ID := "satsuki_lv3_wrong_patient_appendectomy"
const TARGET_NODES := ["s08_008", "s08_011", "s08_013", "s08_015", "s08_017", "s08_019"]

var app
var output := ""
var checks := 0
var failures := 0
var observations: Array = []

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := output.path_join(name + ".png")
	expect(root.get_texture().get_image().save_png(path) == OK, "Could not save " + path)

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			output = arg.trim_prefix("--out=")
	assert(not output.is_empty())
	DirAccess.make_dir_recursive_absolute(output)
	expect(DisplayServer.get_name() != "headless", "Visible native renderer is required")
	if failures:
		quit(1)
		return

	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/satsuki_lv3_artoria_sterile_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	app.dialogue_auto_enabled = false

	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Could not load " + locale)
		app.configure_game_content()
		var game = app.game
		game.reset()
		var definition: Dictionary = game.special_event_definitions.get(EVENT_ID, {})
		expect(not definition.is_empty(), "Missing Satsuki Lv3 definition")
		for node_id in TARGET_NODES:
			var session = SpecialEventSession.new(definition, game.special_event_step_definitions, 1)
			session.node_id = node_id
			game.active_special_event = session
			game.active_special_event_id = EVENT_ID
			game.active_mode = "special_event"
			app.special_event_last_cg_path = ""
			app.reset_dialogue_page()
			app.show_special_event()
			await process_frame

			var node: Dictionary = session.current()
			expect(str(node.get("id", "")) == node_id, "Could not reach " + node_id)
			expect(str(node.get("actor_id", "")) == "doc_artoria", "Wrong actor at " + node_id)
			expect(str(node.get("outfit", "")) == "sterile", "Wrong outfit at " + node_id)
			var portrait := app.page.get_node_or_null("CharacterEventPortrait") as TextureRect
			if portrait == null:
				portrait = app.page.get_node_or_null("CharacterPortrait") as TextureRect
			var loaded_path := ""
			if portrait != null and portrait.texture != null:
				loaded_path = portrait.texture.resource_path
			expect(not loaded_path.is_empty(), "No Artoria portrait rendered at " + node_id)
			expect("/doc_artoria/sterile/" in loaded_path, "Non-sterile portrait rendered at " + node_id + ": " + loaded_path)
			expect("/doc_artoria/white_coat/" not in loaded_path, "White coat still rendered at " + node_id)
			observations.append({
				"locale": locale,
				"node": node_id,
				"outfit": node.get("outfit", ""),
				"portrait": loaded_path,
				"screen": app.screen,
				"save_allowed": game.can_save_progress(),
			})
			expect(not game.can_save_progress(), "Save must remain blocked during " + node_id)
			await capture(locale + "_" + node_id + "_artoria_sterile")

	var report := {
		"native": DisplayServer.get_name() != "headless",
		"scope": "Targeted visible rendering checkpoints for all Artoria OR dialogue nodes; not a full entry-path replay",
		"checks": checks,
		"failures": failures,
		"observations": observations,
	}
	var file := FileAccess.open(output.path_join("native.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("SATSUKI LV3 ARTORIA STERILE NATIVE: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
