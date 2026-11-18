extends SceneTree
## Asset geometry and real UI input routing test for Emiko Mido (`doc_emiko`) 1024x1536 body_map.png.

const Content = preload("res://godot/systems/h_profile_v1_content.gd")
const Session = preload("res://godot/systems/h_profile_v1_session.gd")
const Registry = preload("res://godot/systems/free_h_registry.gd")

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
	var config := Registry.definition("doc_emiko")
	var bodymap := Registry.read_json(config.bodymap)
	var profile := Content.normalize(
		Registry.read_json(config.profile),
		Registry.read_json(config.flow),
		Registry.read_json(config.finish_labels),
		{},
		Registry.read_json(config.context)
	)
	var samples := {
		"lips": [Vector2(531, 304)],
		"cheeks": [Vector2(476, 268), Vector2(566, 312)],
		"neck": [Vector2(528, 395)],
		"nipples": [Vector2(390, 585), Vector2(656, 588)],
		"breasts": [Vector2(448, 560), Vector2(598, 560)],
		"navel": [Vector2(519, 876)],
		"genitals": [Vector2(509, 1140)],
		"torso_other": [Vector2(516, 456), Vector2(516, 760), Vector2(516, 980)],
		"thighs": [Vector2(416, 1280), Vector2(608, 1280)],
	}
	var misses := [
		Vector2(100, 100),
		Vector2(210, 500),
		Vector2(830, 500),
		Vector2(180, 1250),
		Vector2(860, 1250),
		Vector2(980, 1500),
		Vector2(-10, 100),
		Vector2(1030, 100),
	]

	var app = load("res://godot/scenes/main.tscn").instantiate()
	app.title_notice_enabled = false
	app.saves.path = "/private/tmp/emiko_bodymap_unused_%d.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/emiko_bodymap_prefs_%d.cfg" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	expect(app.content.load_all("zh_CN"), "Content loads")
	app.configure_game_content()

	var image_size := Vector2(1024, 1536)
	var polygons := 0
	for zone in Session.ZONES:
		expect(bodymap.hotspots.has(zone), "Registered region " + zone)
		for polygon in bodymap.hotspots[zone]:
			polygons += 1
			var valid: bool = polygon.size() >= 3
			for point in polygon:
				valid = valid and point.size() == 2 and point[0] >= 0 and point[0] <= 1 and point[1] >= 0 and point[1] <= 1
			expect(valid, "Normalized valid polygon " + zone)
	expect(polygons == 14, "Fourteen calibrated polygons")

	for zone in samples:
		for pixel in samples[zone]:
			var session = Session.new("doc_emiko", profile, "operating_room", "", "zh_CN")
			app.h_profile_test_session = session
			app.h_profile_test_bodymap = bodymap
			app.h_profile_test_action = "caress"
			app.h_profile_test_last_result = {}
			app.h_profile_run_kind = "free"
			app.h_profile_event_mode = false
			app.h_profile_test_max_prompt_visible = false
			app.show_sayaka_h_profile_test()
			var body = app.page.get_node("HProfileBodyMap")
			expect(body.texture != null and body.texture.resource_path == "res://assets/h/doc_emiko/body_map.png" and body.texture.get_size() == image_size, "Own 1024x1536 body_map.png texture")
			expect(body.size == Vector2(340, 510) and body.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Uncropped 2:3 display geometry")
			expect(session.hit_test(pixel / image_size, bodymap) == zone, "Pixel geometry -> " + zone)
			var event := InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = true
			event.position = pixel / image_size * body.size
			body.gui_input.emit(event)
			expect(app.h_profile_test_last_result.get("accepted", false) and app.h_profile_test_last_result.get("zone") == zone, "Real UI input routes to " + zone)

	var miss_session = Session.new("doc_emiko", profile, "operating_room", "", "zh_CN")
	for pixel in misses:
		expect(miss_session.hit_test(pixel / image_size, bodymap).is_empty(), "Non-interactive background/pad rejected at " + str(pixel))
	expect(Session.point_to_uv(Vector2(10, 10), Rect2(70, 160, 340, 510)) == Vector2(-1, -1), "Outside image rect rejected")

	DirAccess.remove_absolute(app.saves.path)
	DirAccess.remove_absolute(app.title_preferences_path)
	app.queue_free()
	await process_frame
	print("EMIKO BODYMAP TEST: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures > 0 else 0)
