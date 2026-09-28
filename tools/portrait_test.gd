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
	var count := 0
	for id in ["doc_aoi", "nurse_haru", "doc_rei", "doc_emiko", "nurse_rin", "nurse_yui", "nurse_ange", "nurse_hiroko", "nurse_moe"]:
		var person: Dictionary = app.content.find_record("staff", id)
		var dimensions: Dictionary = {}
		for key in person.visuals.portraits:
			var outfit: String = key.get_slice("/", 0)
			var expression: String = key.get_slice("/", 1)
			var path: String = "res://" + person.visuals.portraits[key]
			var source := (load(path) as Texture2D).get_image()
			expect(source != null and not source.is_empty(), "Cannot load " + path)
			if source == null or source.is_empty():
				continue
			expect(source.detect_alpha() != Image.ALPHA_NONE, "No transparency: " + path)
			if dimensions.has(outfit):
				# Native image edits can round a canvas edge by one pixel; larger drift is an error.
				var delta: Vector2i = (dimensions[outfit] - source.get_size()).abs()
				expect(delta.x <= 1 and delta.y <= 1, "Canvas differs within outfit: " + path)
			else:
				dimensions[outfit] = source.get_size()
			app.show_staff(id, "clinic", expression, outfit)
			var portrait = app.page.get_node_or_null("CharacterPortrait")
			expect(portrait != null and portrait.texture.resource_path == path, "Wrong portrait: " + key)
			expect(app.page.get_node("Expression_" + expression).disabled, "Selection indicator wrong: " + key)
			count += 1
			await process_frame
		app.show_staff(id, "clinic")
		app.page.get_node("Outfit_scrubs").pressed.emit()
		expect(app.page.get_node("Outfit_scrubs").disabled, "Outfit button failed")
		if person.visuals.portraits.has("scrubs/worried"):
			app.page.get_node("Expression_worried").pressed.emit()
			expect(app.page.get_node("CharacterPortrait").texture.resource_path.ends_with("scrubs/worried.png"), "Expression button failed")
	for id in ["doc_rei", "doc_emiko", "nurse_rin", "nurse_yui", "nurse_ange", "nurse_hiroko", "nurse_moe"]:
		app.show_staff(id, "clinic")
		expect(app.page.get_node_or_null("CharacterPortrait") != null, "New staff portrait missing: " + id)
	var patient_count := 0
	var expected_patient_count := 0
	for patient in app.content.collections.patients:
		expected_patient_count += patient.visuals.portraits.size()
		var id: String = patient.id
		var dimensions: Dictionary = {}
		for key in patient.visuals.portraits:
			var outfit: String = key.get_slice("/", 0)
			var expression: String = key.get_slice("/", 1)
			var path: String = "res://" + patient.visuals.portraits[key]
			var texture := load(path) as Texture2D
			expect(texture != null, "Cannot load patient image: " + path)
			if texture == null:
				continue
			var source := texture.get_image()
			if outfit == "ward":
				expect(source.detect_alpha() != Image.ALPHA_NONE, "Ward patient is not transparent: " + path)
				var last := source.get_size() - Vector2i.ONE
				for corner in [Vector2i.ZERO, Vector2i(last.x, 0), Vector2i(0, last.y), last]:
					expect(source.get_pixelv(corner).a <= 0.05, "Ward patient has an opaque canvas corner: " + path)
			if dimensions.has(outfit):
				var delta: Vector2i = (dimensions[outfit] - texture.get_size()).abs()
				expect(delta.x <= 1 and delta.y <= 1, "Patient canvas differs within state: " + path)
			else:
				dimensions[outfit] = texture.get_size()
			app.show_patient(id, outfit, expression)
			var portrait = app.page.get_node_or_null("CharacterPortrait")
			expect(portrait != null and portrait.texture.resource_path == path, "Wrong patient image: " + key)
			expect(app.page.get_node("PatientExpression_" + expression).disabled, "Patient selection indicator wrong: " + key)
			patient_count += 1
			await process_frame
	expect(count == 132, "Expected 132 staff portraits, found %s" % count)
	expect(patient_count == expected_patient_count, "Expected %s patient images, found %s" % [expected_patient_count, patient_count])
	print("PORTRAITS: %s staff + %s patient images checked, %s failure(s)" % [count, patient_count, failures])
	quit(1 if failures else 0)
