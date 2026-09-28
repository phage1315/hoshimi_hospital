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
	var patient: Dictionary = app.content.find_record("patients", "patient_gigi")
	var path: String = str(patient.get("visuals", {}).get("portraits", {}).get("examination/shy", ""))
	expect(path == "assets/characters/patient_gigi_v1/patient_gigi/examination/shy.png", "Gigi examination portrait points to the wrong asset")
	var resource_path := "res://" + path
	expect(ResourceLoader.exists(resource_path), "Gigi nude portrait resource is missing")
	expect(load(resource_path) is Texture2D, "Gigi nude portrait did not load as a texture")
	app.add_portrait(patient, "shy", "examination")
	await process_frame
	var portrait: TextureRect = app.page.get_node_or_null("CharacterPortrait")
	expect(portrait != null and portrait.texture != null and portrait.texture.resource_path == resource_path, "Gigi nude portrait did not render through the shared examination state")
	print("Gigi nude portrait checks: %s, failures: %s" % [5, failures])
	quit(1 if failures > 0 else 0)
