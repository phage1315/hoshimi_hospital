extends SceneTree

const Preop = preload("res://godot/systems/preop_session.gd")
const PreopView = preload("res://godot/ui/preop_view.gd")

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
	var ready_avatar_count := 0
	for staff_member in app.content.collections.staff:
		var avatar: Dictionary = staff_member.get("visuals", {}).get("intraoperative_avatar", {})
		if avatar.get("status") == "ready":
			ready_avatar_count += 1
			var avatar_path: String = staff_member.get("visuals", {}).get("portraits", {}).get("intraoperative_avatar/neutral", "")
			expect(avatar_path == avatar.get("target_path", ""), "%s did not register the ready HUD avatar" % staff_member.get("id", "unknown"))
			expect(ResourceLoader.exists("res://" + avatar_path), "%s HUD avatar resource is missing" % staff_member.get("id", "unknown"))
	expect(ready_avatar_count == 20, "Expected 20 ready staff HUD avatars")
	var definition: Dictionary = app.content.collections.preops[0].duplicate(true)
	var prep = Preop.new(
		definition,
		app.content.collections.staff,
		app.content.collections.surgeries,
		app.content.collections.patients,
		[],
		false,
		app.content.collections.surgery_team_dialogue_profiles,
		app.content.collections.patient_interactions,
		app.content.collections.temporary_conditions,
		[],
		false,
		app.content.collections.palpation_profiles
	)
	prep.procedure_id = "surgery_hysterectomy"
	prep.procedure_name = "开腹子宫全切除"
	prep.stage_id = "procedure_flow"
	prep.procedure_step_index = 0
	prep.operative_background_id = "operating_team_01"
	prep.flags.append("incision_made")

	app.operative_field_hud_enabled = true
	PreopView.render(app, prep)
	var hud := app.page.get_node_or_null("OperativeFieldHUD") as TextureRect
	var frame := app.page.get_node_or_null("OperativeFieldHUDFrame") as Control
	var team_background := app.page.get_node_or_null("SceneBackground") as TextureRect
	expect(hud != null and frame != null, "HUD mode did not render the operative-field inset")
	expect(app.page.get_node_or_null("OperativeFieldOverlay") == null, "HUD mode also rendered the full-screen overlay")
	expect(frame != null and frame.position.x >= 850 and frame.position.y < 200, "HUD was not placed in the upper-right rail")
	expect(team_background != null and team_background.texture.resource_path.contains("operating_team_01"), "HUD mode did not preserve the operating-team background")

	app.operative_field_hud_enabled = false
	PreopView.render(app, prep)
	expect(app.page.get_node_or_null("OperativeFieldHUD") == null and app.page.get_node_or_null("OperativeFieldOverlay") != null, "Full-screen mode did not restore the operative-field overlay")

	app.operative_field_hud_enabled = true
	prep.procedure_step_index = prep.surgery_flow_steps().size() - 1
	PreopView.render(app, prep)
	expect(app.page.get_node_or_null("OperativeFieldHUD") == null, "HUD remained visible during closure")

	print("OPERATIVE FIELD HUD: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
