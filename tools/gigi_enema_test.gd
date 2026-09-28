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
	var pool: Dictionary = app.ward_preparation_cg_pool_for("ward_enema", "patient_gigi")
	expect(pool.get("id", "") == "ward_enema_patient_gigi", "Gigi did not select her enema CG pool")
	expect(pool.get("presentation", "") == "fullscreen", "Gigi enema CG is not fullscreen")
	expect(pool.get("paths", []).size() == 1, "Gigi enema CG pool has the wrong number of images")
	expect(app.ward_preparation_cg_pool_for("ward_enema_unnecessary", "patient_gigi").get("id", "") == "ward_enema_patient_gigi", "Gigi's unnecessary enema did not select her CG")
	expect(app.ward_preparation_cg_pool_for("ward_enema", "patient_sora").get("id", "") == "ward_enema_generic", "Gigi's CG leaked to another patient")
	var resource_path := "res://" + String(pool.get("paths", [""])[0])
	expect(ResourceLoader.exists(resource_path), "Gigi enema CG resource is missing")
	expect(load(resource_path) is Texture2D, "Gigi enema CG did not load as a texture")
	app.show_ward_preparation_fullscreen(pool, app.show_map)
	await process_frame
	var cg: TextureRect = app.page.get_node_or_null("WardPreparationCG")
	expect(app.screen == "ward_preparation_cg" and cg != null and cg.texture != null, "Gigi enema fullscreen did not render")
	var continue_button: Button = app.page.get_node_or_null("WardPreparationCGContinue")
	expect(continue_button != null, "Gigi enema fullscreen has no continue button")
	if continue_button != null:
		continue_button.pressed.emit()
	await process_frame
	expect(app.screen == "map", "Gigi enema fullscreen did not continue")
	print("Gigi enema CG checks: %s, failures: %s" % [11, failures])
	quit(1 if failures > 0 else 0)
