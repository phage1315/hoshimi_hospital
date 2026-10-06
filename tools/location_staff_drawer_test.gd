extends SceneTree

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for location_id in ["clinic", "ward", "or"]:
		app.location_staff_drawer_open = ""
		app.show_location(location_id)
		var toggle: Button = app.page.get_node_or_null("LocationStaffToggle")
		expect(toggle != null, "%s omitted the collapsed staff control" % location_id)
		expect(app.page.get_node_or_null("LocationStaffDrawer") == null, "%s staff drawer did not start collapsed" % location_id)
		var patient_button: Button = app.page.get_node_or_null("PatientPortrait")
		var patient_y := patient_button.position.y if patient_button != null else -1.0
		if toggle != null:
			toggle.pressed.emit()
			await process_frame
			var drawer: Panel = app.page.get_node_or_null("LocationStaffDrawer")
			expect(drawer != null, "%s staff drawer did not open" % location_id)
			expect(drawer != null and drawer.get_node_or_null("LocationStaffScroll/LocationStaffList") != null, "%s staff drawer is not scrollable" % location_id)
			if drawer != null:
				for control in drawer.find_children("*", "Button", true, false):
					var button := control as Button
					expect(button.get_global_rect().end.x <= drawer.get_global_rect().end.x + 0.5, "%s contains a staff action outside the drawer: %s" % [location_id, button.name])
			if patient_button != null:
				var rerendered_patient: Button = app.page.get_node_or_null("PatientPortrait")
				expect(rerendered_patient != null and rerendered_patient.position.y == patient_y, "%s staff drawer displaced patient controls" % location_id)
			app.page.get_node("LocationStaffToggle").pressed.emit()
			expect(app.page.get_node_or_null("LocationStaffDrawer") == null, "%s staff drawer did not collapse" % location_id)
	# Force a populated clinic drawer so long Chinese labels and adjacent chat
	# actions are measured even when the default test-day schedule is empty.
	for staff_id in ["doc_sayaka", "nurse_hiroko", "nurse_moe"]:
		app.game.meet_staff(staff_id)
	app.base("Drawer layout test", "", false, "clinic")
	app.location_staff_drawer_open = "clinic"
	var populated_staff: Array[String] = ["doc_sayaka", "nurse_hiroko", "nurse_moe"]
	app.render_location_staff_drawer("clinic", populated_staff)
	await process_frame
	var populated_drawer: Panel = app.page.get_node_or_null("LocationStaffDrawer")
	var measured_buttons := 0
	if populated_drawer != null:
		for control in populated_drawer.find_children("*", "Button", true, false):
			var button := control as Button
			measured_buttons += 1
			expect(button.get_global_rect().end.x <= populated_drawer.get_global_rect().end.x + 0.5, "Populated clinic action escaped the drawer: %s" % button.name)
	expect(measured_buttons >= 3, "Populated drawer layout test did not create staff actions")
	print("LOCATION STAFF DRAWER: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
