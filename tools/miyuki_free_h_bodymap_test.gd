extends SceneTree
## Geometry, priority, registered assets, and real TextureRect input routing.
## The fixture is entirely in memory and never writes a player save.
const Content = preload("res://godot/systems/h_profile_v1_content.gd")
const Session = preload("res://godot/systems/h_profile_v1_session.gd")
const Registry = preload("res://godot/systems/free_h_registry.gd")

const IMAGE_SIZE := Vector2(1024, 1520)
const SAMPLES := {
	"lips": [Vector2(545, 385)],
	"cheeks": [Vector2(450, 340), Vector2(610, 335)],
	"neck": [Vector2(515, 500)],
	"breasts": [Vector2(445, 625), Vector2(620, 625)],
	"nipples": [Vector2(405, 720), Vector2(700, 720)],
	"navel": [Vector2(545, 1025)],
	"torso_other": [Vector2(530, 865), Vector2(505, 590)],
	"genitals": [Vector2(530, 1340)],
	"thighs": [Vector2(350, 1390), Vector2(700, 1390)],
}
const MISSES := [
	Vector2(50, 50), Vector2(150, 300), Vector2(880, 350),
	Vector2(120, 900), Vector2(900, 1000), Vector2(520, 110),
	Vector2(-10, 100), Vector2(1030, 100),
]

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
	var config := Registry.definition("nurse_yui")
	var bodymap := Registry.read_json(config.bodymap)
	var profile := Content.normalize(
		Registry.read_json(config.profile), Registry.read_json(config.flow),
		Registry.read_json(config.finish_labels), {}, Registry.read_json(config.context)
	)
	expect(bodymap.get("status") == "final", "Body map is final")
	expect(bodymap.get("image_width") == 1024 and bodymap.get("image_height") == 1520, "Body map dimensions match author image")
	var polygon_count := 0
	for zone in Session.ZONES:
		expect(bodymap.hotspots.has(zone), "Registered zone " + zone)
		for polygon in bodymap.hotspots.get(zone, []):
			polygon_count += 1
			var valid: bool = polygon.size() >= 3
			for point in polygon:
				valid = valid and point is Array and point.size() == 2
				valid = valid and float(point[0]) >= 0.0 and float(point[0]) <= 1.0
				valid = valid and float(point[1]) >= 0.0 and float(point[1]) <= 1.0
			expect(valid, "Normalized polygon " + zone)
	expect(polygon_count == 14, "Nine zones use fourteen calibrated polygons")

	var session = Session.new("nurse_yui", profile, "clinic", "", "zh_CN")
	for zone in SAMPLES:
		for pixel in SAMPLES[zone]:
			expect(session.hit_test(pixel / IMAGE_SIZE, bodymap) == zone, "Representative pixel " + zone + " " + str(pixel))
	for pixel in MISSES:
		expect(session.hit_test(pixel / IMAGE_SIZE, bodymap).is_empty(), "Background misses " + str(pixel))
	# Priority regression: small regions must win where their broader parent overlaps.
	expect(session.hit_test(Vector2(405, 720) / IMAGE_SIZE, bodymap) == "nipples", "Nipple wins over breast")
	expect(session.hit_test(Vector2(545, 1025) / IMAGE_SIZE, bodymap) == "navel", "Navel wins over torso")
	expect(session.hit_test(Vector2(530, 1340) / IMAGE_SIZE, bodymap) == "genitals", "Genitals win over adjacent thighs")

	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	expect(app.content.load_all("zh_CN"), "Content loads")
	app.configure_game_content()
	for zone in SAMPLES:
		var pixel: Vector2 = SAMPLES[zone][0]
		var ui_session = Session.new("nurse_yui", profile, "clinic", "", "zh_CN")
		app.h_profile_test_session = ui_session
		app.h_profile_test_bodymap = bodymap
		app.h_profile_test_action = "caress"
		app.h_profile_test_last_result = {}
		app.h_profile_run_kind = "free"
		app.h_profile_event_mode = false
		app.h_profile_test_max_prompt_visible = false
		app.show_sayaka_h_profile_test()
		var body = app.page.get_node("HProfileBodyMap")
		var portrait = app.page.get_node("HProfileExpression")
		expect(body.texture.resource_path == "res://assets/h/nurse_yui/body_map.png" and body.texture.get_size() == IMAGE_SIZE, "Own author body map")
		expect(body.size == Vector2(340, 510) and body.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Uncropped display geometry")
		expect(portrait.texture != null and portrait.texture.resource_path == "res://assets/h/nurse_yui/portrait_neutral.png", "Own neutral portrait")
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = true
		event.position = pixel / IMAGE_SIZE * body.size
		body.gui_input.emit(event)
		expect(app.h_profile_test_last_result.get("accepted", false) and app.h_profile_test_last_result.get("zone") == zone, "TextureRect input routes to " + zone)

	app.h_profile_test_session = null
	app.show_map(false)
	var bundle := Registry.load_bundle("nurse_yui")
	expect(not bundle.has("error"), "Ready production bundle loads: " + str(bundle.get("error", "")))
	print("MIYUKI BODYMAP: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)
