extends SceneTree
## Narumi H Profile production asset, body-map geometry, and registry regression.
## This fixture is read-only and never writes a player save.

const Content = preload("res://godot/systems/h_profile_v1_content.gd")
const Session = preload("res://godot/systems/h_profile_v1_session.gd")
const Registry = preload("res://godot/systems/free_h_registry.gd")

const IMAGE_SIZE := Vector2(1024, 1536)
const CG_SIZE := Vector2(1536, 1024)
const PORTRAIT_SIZE := Vector2(1331, 1181)
const EXPECTED_SHA256 := "037fa827d4c1b464a9b569ddd57f5fb507204820d6e3ec4d40f8aa69ff311c35"
const EXPECTED_SCENE_SHA256 := "d28afeb474fee83bd08e800618ad3b33bf8ce786502d3d80120cb0703825c27a"
const EXPECTED_AFTERCARE_SHA256 := "c963c3cc7d1427d1676a832071386d7cb728fd6c6697b63580742d5ba17ca650"
const SAMPLES := {
	"lips": [Vector2(515, 335)],
	"cheeks": [Vector2(390, 320), Vector2(645, 320)],
	"neck": [Vector2(520, 490)],
	"breasts": [Vector2(360, 650), Vector2(660, 650)],
	"nipples": [Vector2(302, 640), Vector2(730, 640)],
	"navel": [Vector2(512, 1025)],
	"torso_other": [Vector2(500, 580), Vector2(510, 850)],
	"genitals": [Vector2(515, 1375)],
	"thighs": [Vector2(200, 1150), Vector2(825, 1150)],
}
const MISSES := [
	Vector2(40, 40), Vector2(980, 80), Vector2(500, 100),
	Vector2(120, 300), Vector2(900, 300), Vector2(80, 420), Vector2(930, 550),
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
	var config := Registry.definition("doc_aoi")
	var bodymap := Registry.read_json(config.bodymap)
	var context := Registry.read_json(config.context)
	var profile := Content.normalize(
		Registry.read_json(config.profile), Registry.read_json(config.flow),
		Registry.read_json(config.finish_labels), {}, context
	)

	expect(FileAccess.file_exists("res://assets/h/doc_aoi/body_map.png"), "Narumi body-map source exists")
	var file := FileAccess.open("res://assets/h/doc_aoi/body_map.png", FileAccess.READ)
	expect(file != null, "Narumi body-map source is readable")
	if file != null:
		expect(FileAccess.get_sha256("res://assets/h/doc_aoi/body_map.png") == EXPECTED_SHA256, "Imported body map is byte-identical to the approved source")
	var texture: Texture2D = load("res://assets/h/doc_aoi/body_map.png")
	expect(texture != null and texture.get_size() == IMAGE_SIZE, "Godot imports the original 1024x1536 texture")
	var scene_texture: Texture2D = load("res://assets/h/doc_aoi/scene_cg.png")
	var aftercare_texture: Texture2D = load("res://assets/h/doc_aoi/aftercare_cg.png")
	expect(scene_texture != null and scene_texture.get_size() == CG_SIZE, "Godot imports Narumi's own second-stage CG")
	expect(aftercare_texture != null and aftercare_texture.get_size() == CG_SIZE, "Godot imports Narumi's own aftercare CG")
	expect(FileAccess.get_sha256("res://assets/h/doc_aoi/scene_cg.png") == EXPECTED_SCENE_SHA256, "Second-stage CG is byte-identical to the approved source")
	expect(FileAccess.get_sha256("res://assets/h/doc_aoi/aftercare_cg.png") == EXPECTED_AFTERCARE_SHA256, "Aftercare CG is byte-identical to the approved source")
	expect(str(profile.get("body_map_image", "")) == "res://assets/h/doc_aoi/body_map.png", "Profile uses Narumi's own body map")
	expect(str(profile.get("h_stage_image", "")) == "res://assets/h/doc_aoi/scene_cg.png", "Profile maps Narumi's own second-stage CG")
	expect(str(profile.get("after_cg_image", "")) == "res://assets/h/doc_aoi/aftercare_cg.png", "Profile maps Narumi's own aftercare CG")
	for expression in Session.EXPRESSION_IDS:
		var portrait_path := str(profile.get("expressions", {}).get(expression, ""))
		expect(portrait_path == "res://assets/h/doc_aoi/portrait_%s.png" % expression, "Profile maps Narumi's %s portrait" % expression)
		var portrait: Texture2D = load(portrait_path)
		expect(portrait != null and portrait.get_size() == PORTRAIT_SIZE, "Godot imports Narumi's %s portrait with the shared crop" % expression)
	expect(str(context.get("layout_status", "")) == "final_hotspots_calibrated", "Context records final hotspot calibration")
	expect(bodymap.get("status") == "final", "Body map is final")
	expect(bodymap.get("image_width") == 1024 and bodymap.get("image_height") == 1536, "Body-map dimensions match the approved image")

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

	var session = Session.new("doc_aoi", profile, "hotel", "", "zh_CN")
	for zone in SAMPLES:
		for pixel in SAMPLES[zone]:
			expect(session.hit_test(pixel / IMAGE_SIZE, bodymap) == zone, "Representative pixel " + zone + " " + str(pixel))
	for pixel in MISSES:
		expect(session.hit_test(pixel / IMAGE_SIZE, bodymap).is_empty(), "Background misses " + str(pixel))
	expect(session.hit_test(Vector2(302, 640) / IMAGE_SIZE, bodymap) == "nipples", "Nipple wins over breast")
	expect(session.hit_test(Vector2(512, 1025) / IMAGE_SIZE, bodymap) == "navel", "Navel wins over torso")
	expect(session.hit_test(Vector2(515, 1375) / IMAGE_SIZE, bodymap) == "genitals", "Genitals win over adjacent thighs")

	var bundle := Registry.load_bundle("doc_aoi")
	var english_bundle := Registry.load_bundle("doc_aoi", "en")
	expect(str(config.get("content_status", "")) == "ready", "Production registration is ready after the complete asset set")
	expect(not bundle.has("error"), "Chinese production bundle validates: " + str(bundle.get("error", "")))
	expect(not english_bundle.has("error"), "English production bundle validates: " + str(english_bundle.get("error", "")))
	print("NARUMI FREE H ASSETS: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)
