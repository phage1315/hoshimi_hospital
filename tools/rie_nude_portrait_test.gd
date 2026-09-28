extends SceneTree

const App = preload("res://godot/ui/app.gd")
var failures := 0

func expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app := App.new()
	root.add_child(app)
	await process_frame
	expect(app.content.errors.is_empty(), "Content failed to load")
	var patient: Dictionary = app.content.find_record("patients", "patient_rie")
	var path: String = str(patient.get("visuals", {}).get("portraits", {}).get("examination/shy", ""))
	var resource_path := "res://" + path
	expect(ResourceLoader.exists(resource_path), "Rie nude portrait resource is missing")
	var texture := load(resource_path) as Texture2D
	expect(texture != null, "Rie nude portrait did not load as a texture")
	if texture != null:
		var source := texture.get_image()
		expect(source.get_size() == Vector2i(1024, 1536), "Rie nude portrait does not use the normalized 2:3 canvas")
		expect(source.detect_alpha() != Image.ALPHA_NONE, "Rie nude portrait lost transparency")
		var last := source.get_size() - Vector2i.ONE
		for corner in [Vector2i.ZERO, Vector2i(last.x, 0), Vector2i(0, last.y), last]:
			expect(source.get_pixelv(corner).a <= 0.05, "Rie nude portrait has an opaque canvas corner")
	app.add_portrait(patient, "shy", "examination")
	await process_frame
	var portrait: TextureRect = app.page.get_node_or_null("CharacterPortrait")
	expect(portrait != null and portrait.texture != null and portrait.texture.resource_path == resource_path, "Rie nude portrait did not render through the examination state")
	print("Rie nude portrait checks: failures: %s" % failures)
	quit(1 if failures > 0 else 0)
