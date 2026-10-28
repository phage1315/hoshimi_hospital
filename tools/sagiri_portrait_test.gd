extends SceneTree

var failures := 0

func expect(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var patient: Dictionary = app.content.find_record("patients", "patient_sagiri_sakurai")
	expect(not patient.is_empty(), "Sagiri is not loaded")
	if patient.is_empty():
		quit(1)
		return
	var portraits: Dictionary = patient.visuals.portraits
	expect(portraits.size() == 21, "Expected 21 Sagiri images")
	var dimensions: Dictionary = {}
	for key in portraits:
		var outfit: String = str(key).get_slice("/", 0)
		var expression: String = str(key).get_slice("/", 1)
		var path: String = "res://" + str(portraits[key])
		var texture := load(path) as Texture2D
		expect(texture != null, "Cannot load " + path)
		if texture == null:
			continue
		if dimensions.has(outfit):
			var delta: Vector2i = (dimensions[outfit] - texture.get_size()).abs()
			expect(delta.x <= 1 and delta.y <= 1, "Canvas mismatch: " + str(key))
		else:
			dimensions[outfit] = texture.get_size()
		if outfit in ["outpatient", "ward", "intraoperative"]:
			var image := texture.get_image()
			expect(image.detect_alpha() != Image.ALPHA_NONE, "Missing alpha: " + str(key))
			var edge := image.get_size() - Vector2i.ONE
			for corner in [Vector2i.ZERO, Vector2i(edge.x, 0), Vector2i(0, edge.y), edge]:
				expect(image.get_pixelv(corner).a <= 0.05, "Opaque corner: " + str(key))
		app.show_patient("patient_sagiri_sakurai", outfit, expression)
		var portrait = app.page.get_node_or_null("CharacterPortrait")
		expect(portrait != null and portrait.texture.resource_path == path, "Wrong UI texture: " + str(key))
		var selected = app.page.get_node_or_null("PatientExpression_" + expression)
		expect(selected != null and selected.disabled, "Wrong selection: " + str(key))
		await process_frame
	print("SAGIRI PORTRAITS: %s textures and UI selections checked, %s failure(s)" % [portraits.size(), failures])
	quit(1 if failures else 0)
