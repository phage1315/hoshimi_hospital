extends SceneTree
const Presence = preload("res://godot/systems/presence_resolver.gd")
const OFFICE := "shared_doctors_office"
const MEMBERS := ["doc_shiori", "doc_sayaka", "doc_rei", "doc_minato", "visiting_futaba", "visiting_maya"]
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
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Content loads")
		app.configure_game_content()
		var g = app.game
		g.reset()
		for event in g.character_event_definitions.values():
			event.developer_only = true
		var known: Array[String] = []
		for actor in MEMBERS:
			known.append(actor)
			g.relation_for(actor).met = true
		var resolver = Presence.new(g.staff)
		var seen := {}
		var visit_day := 0
		for day in range(1, 101):
			var found: Array[String] = resolver.staff_at(OFFICE, day, 600, known)
			expect(found == resolver.staff_at(OFFICE, day, 659, known), "No within-hour reroll")
			if not found.is_empty(): visit_day = day
			for actor in found:
				expect(actor in MEMBERS, "Only configured members")
				seen[actor] = true
		for actor in MEMBERS:
			expect(seen.has(actor), "Each member can appear: " + actor)
		for person in g.staff:
			expect((OFFICE in person.get("presence", {}).get("random_locations", [])) == (str(person.id) in MEMBERS), "Roster exclusions")
		g.set_test_time(visit_day, 600)
		g.set_story_flag("takemi_research_discovered")
		app.show_map(false)
		expect(app.page.get_node_or_null("Location_" + OFFICE) != null, "Map entry")
		for child in app.page.get_children():
			if str(child.name).begins_with("Location_"):
				expect(child.position.y + child.size.y < 700, "Cards stay above footer")
		await capture(app, locale + "_map")
		app.show_location(OFFICE, false)
		expect(app.screen == "location", "Office opens")
		var bg = app.page.get_node_or_null("SceneBackground")
		expect(bg != null and bg.texture != null and bg.texture.resource_path.ends_with("shared_doctors_office.png"), "Office background loaded")
		app.save_progress()
		expect(app.screen == "location", "Location cannot open save slots")
		for child in app.get_children():
			if child is AcceptDialog:
				child.hide()
				child.queue_free()
		await process_frame
		await capture(app, locale + "_office")
		var narumi: Dictionary = app.content.find_record("staff", "doc_aoi")
		expect("narumi_office" in narumi.presence.fixed_locations, "Narumi office fixed post")
		var narumi_seen := false
		for day in range(1, 101):
			if resolver.hourly_assignment(narumi, day, 600) == "narumi_office": narumi_seen = true
		expect(narumi_seen, "Narumi can appear in own office")
		g.relation_for("doc_aoi").met = true
		app.show_location("narumi_office", false)
		var narumi_bg = app.page.get_node_or_null("SceneBackground")
		expect(narumi_bg != null and narumi_bg.texture.resource_path.ends_with("narumi_office.png"), "Narumi background loads")
		app.save_progress()
		expect(app.screen == "location", "Private office also blocks save slots")
		for child in app.get_children():
			if child is AcceptDialog:
				child.hide()
				child.queue_free()
		await process_frame
		await capture(app, locale + "_narumi_office")
		g.set_test_time(7, 600)
		app.sunday_hospital_browsing = true
		app.show_map(false)
		expect(app.page.get_node_or_null("Location_" + OFFICE) != null, "Sunday visit entry")
	print("SHARED DOCTORS OFFICE: %s checks; %s failure(s)" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
func capture(app, label: String) -> void:
	if OS.get_cmdline_user_args().has("--screenshots") and DisplayServer.get_name() != "headless":
		var folder := "res://docs/qa/shared_doctors_office_2026-10-26/"
		DirAccess.make_dir_recursive_absolute(folder)
		await process_frame
		await RenderingServer.frame_post_draw
		expect(root.get_texture().get_image().save_png(folder + label + ".png") == OK, "Screenshot")
