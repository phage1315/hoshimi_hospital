extends SceneTree
const Preop = preload("res://godot/systems/preop_session.gd")
const View = preload("res://godot/ui/preop_view.gd")
var app
var checks := 0
var failures := 0
const QA := "res://docs/qa/mizuho_palpation/"
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func fixture(patient_id: String, staff_id: String = "") -> RefCounted:
	var definition: Dictionary = app.content.find_record("preops", "preop_sora").duplicate(true)
	definition.patient_id = patient_id
	if not staff_id.is_empty(): definition.staff_patient_id = staff_id
	var prep = Preop.new(definition, app.content.collections.staff, app.content.collections.surgeries, app.content.collections.patients, [], false, app.content.collections.surgery_team_dialogue_profiles, app.content.collections.patient_interactions, app.content.collections.temporary_conditions, [], false, app.content.collections.palpation_profiles)
	prep.stage_id = "procedure_select"
	return prep
func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":return
	await RenderingServer.frame_post_draw
	expect(root.get_texture().get_image().save_png(QA + name + ".png") == OK, "Screenshot saved")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA))
	app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Content loads")
		app.configure_game_content()
		app.game.set_test_time(105,540)
		# Isolated fixture only: Mizuho is not yet available through the real invitation gate.
		app.game.patient_definitions = app.game.patient_definitions.duplicate(true)
		app.game.patient_definitions.append(app.game.staff_record("guest_mizuho").duplicate(true))
		expect(not app.game.staff_patient_unlocked("guest_mizuho"), "Future staff-patient entry remains locked")
		var generic = fixture("patient_sora")
		expect(not generic.valid_palpation_cg_id("mizuho_v1") and not generic.valid_palpation_cg_id(""), "Other patients reject exclusive/empty ID")
		for cg_id in Preop.OR_TABLE_PALPATION_CG_IDS:
			var personal = fixture("guest_mizuho")
			expect(personal.apply({"kind":"procedure", "id":"surgery_appendix", "palpation_cg_id":cg_id}) and personal.or_table_palpation_cg_id == "mizuho_v1", "Exclusive art overrides generic input")
		for i in range(50):
			expect(generic.resolve_palpation_cg_id(str(Preop.OR_TABLE_PALPATION_CG_IDS.pick_random())) != "mizuho_v1", "Generic pool excludes Mizuho")
		var staff = fixture("guest_mizuho", "guest_mizuho")
		expect(staff.resolve_palpation_cg_id() == "mizuho_v1", "Staff-patient identity selects same exclusive art")
		var prep = fixture("guest_mizuho", "guest_mizuho")
		app.game.preop_definitions[prep.definition.id] = prep.definition
		app.game.preops[prep.definition.id] = prep
		app.game.active_preop_id = prep.definition.id
		app.preop_event({"kind":"procedure", "id":"surgery_appendix"})
		expect(prep.or_table_palpation_cg_id == "mizuho_v1", "Actual procedure UI selects exclusive art")
		for sensory in [false, true]:
			if sensory:
				expect(prep.apply({"kind":"or_table_palpation_complete"}), "Complete palpation")
				expect(prep.apply({"kind":"action", "id":"choose_local"}), "Enter local anesthesia test")
				app.or_table_palpation_tool = "needle"
			else:app.or_table_palpation_tool = "palpation"
			app.or_table_tool_stage_id = prep.stage_id
			View.render(app, prep)
			await process_frame
			var body: TextureRect = app.page.get_node("PalpationBodyImage")
			expect(body.texture.resource_path == View.OR_TABLE_PALPATION_IMAGES.mizuho_v1, "Both screens retain exclusive texture")
			expect(body.texture.get_size() == Vector2(2176,1660), "Original dimensions retained")
			expect(body.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "Matches calibration transform")
			expect(not app.game.can_save_progress(), "Interaction not a save boundary")
			await capture(locale + ("_sensory" if sensory else "_palpation"))
			var body_rect: Rect2 = body.get_rect()
			var layout: Dictionary = View.palpation_hotspot_layout("mizuho_v1", Rect2(330,68,620,626))
			for region in layout:
				for i in range(layout[region].size()):
					var button: Button = app.page.get_node("PalpationHotspot_%s_%s" % [region,i])
					expect(button.get_rect().is_equal_approx(layout[region][i]), "Rendered region matches calibration %s/%s/%s actual=%s expected=%s" % [locale, region, i, button.get_rect(), layout[region][i]])
					expect(body_rect.encloses(button.get_rect()), "Hotspot inside image")
					# Verify the center reaches this button rather than an overlapping later hotspot.
					var top: Control = null
					for child in app.page.get_children():
						if child is Button and str(child.name).begins_with("PalpationHotspot_") and child.get_rect().has_point(button.get_rect().get_center()):top = child
					expect(top == button, "Hotspot center is not intercepted")
					var count_key: String = "needle:" + str(region) if sensory else str(region)
					var before: int = int((prep.anesthesia_test_counts if sensory else prep.or_table_palpation_counts).get(count_key, 0))
					button.emit_signal("pressed")
					await process_frame
					var after: int = int((prep.anesthesia_test_counts if sensory else prep.or_table_palpation_counts).get(count_key, 0))
					expect(after == before + 1, "Actual button increments intended region")
			if locale == "zh_CN" and not sensory:
				for region in layout:
					for rect: Rect2 in layout[region]:
						var panel := Panel.new()
						panel.position = rect.position;panel.size = rect.size;panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
						var style := StyleBoxFlat.new();style.bg_color = Color(0,0.8,0.6,0.10);style.border_color = Color(0,1,0.5,1);style.set_border_width_all(2)
						panel.add_theme_stylebox_override("panel",style);app.page.add_child(panel)
				await capture("hotspot_overlay")
	print("MIZUHO PALPATION: ", checks, " checks; ", failures, " failures")
	app.queue_free()
	await process_frame
	quit(1 if failures else 0)
