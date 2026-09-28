extends SceneTree
var app: Control
var failures := 0

func expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	expect(app.content.errors.is_empty(), "Content load failed")
	expect(app.content.protagonist.get("name", "") == "本多繁邦", "Canonical protagonist profile was not loaded")
	expect(app.screen == "title", "Title did not open")
	expect(app.page.get_node_or_null("SceneBackground") != null, "Title lobby background missing")
	app.start_story()
	expect(app.page.get_node_or_null("SceneBackground") != null, "Prologue hallway background missing")
	var prose: Label = app.page.get_node_or_null("PrologueText")
	var dialogue_box: Panel = app.page.get_node_or_null("PrologueDialogueBox")
	expect(prose != null and dialogue_box != null, "Prologue dialogue controls missing")
	if prose != null and dialogue_box != null:
		expect(prose.autowrap_mode == TextServer.AUTOWRAP_ARBITRARY and prose.clip_text, "Chinese prologue text is not safely wrapped")
		expect(prose.position.x + prose.size.x < dialogue_box.position.x + dialogue_box.size.x, "Prologue text exceeds dialogue frame")
	for node in app.content.dialogue.nodes:
		app.session.current_id = node.id
		app.show_dialogue()
		await process_frame
		prose = app.page.get_node_or_null("PrologueText")
		expect(prose != null and prose.get_line_count() <= 3, "Prologue node does not fit dialogue box: " + str(node.id))
	app.start_story()
	expect(advance_until("aoi_question"), "Intro did not reach senior-doctor choice")
	app.advance(0)
	expect(app.session.current_id == "aoi_honest", "Honest response route broken")
	expect(advance_until("haru_invite"), "Intro did not reach nurse-station invitation")
	app.advance(-1)
	var station_nodes: Array[String] = []
	for i in range(12):
		if app.screen != "dialogue":
			break
		station_nodes.append(app.session.current_id)
		app.advance(-1)
	expect("rin_intro" in station_nodes and "yui_intro" in station_nodes, "Nurse-station route omitted fixed staff introductions")
	expect(app.screen == "location" and app.page.get_node_or_null("PatientPortrait") != null, "Nurse-station route did not arrive at clinic")
	expect(app.game.staff_is_met("doc_aoi") and app.game.staff_is_met("nurse_haru") and app.game.staff_is_met("nurse_rin") and app.game.staff_is_met("nurse_yui"), "Mandatory prologue did not register the initial surgery-team staff")
	app.start_story()
	expect(advance_until("aoi_question"), "Restarted intro did not reach doctor choice")
	app.advance(1)
	expect(app.session.current_id == "aoi_composed", "Composed response route broken")
	expect(advance_until("haru_invite"), "Restarted intro did not reach mandatory nurse-station stop")
	app.advance(-1)
	var visited_station := false
	for i in range(12):
		if app.screen != "dialogue":
			break
		visited_station = visited_station or app.session.current_id.begins_with("station_")
		app.advance(-1)
	expect(visited_station and app.screen == "location", "Prologue did not force the nurse-station introductions")
	app.show_map()
	expect(app.page.get_node_or_null("SceneBackground") != null, "Directory lobby background missing")
	expect(app.content.collections.locations.size() == 13, "Expanded hospital directory should contain thirteen locations")
	for location_id in ["pharmacy", "gynecology_exam", "emiko_office", "director_office"]:
		expect(app.page.get_node_or_null("Location_" + location_id) != null, "New map entry missing: " + location_id)
	for location in app.content.collections.locations:
		app.show_location(location.id)
		var scene_background = app.page.get_node_or_null("SceneBackground")
		expect(scene_background != null, "Location background missing: " + location.id)
		if scene_background != null:
			var authored: Dictionary = app.content.find_record("backgrounds", location.background_id)
			expect(scene_background.texture.resource_path == "res://" + authored.path, "Wrong data-driven background: " + location.id)
		for person in location.staff_ids:
			app.show_staff(person, location.id)
	app.show_staff("pharmacist_manami", "pharmacy")
	var pharmacist_portrait: TextureRect = app.page.get_node_or_null("CharacterPortrait")
	expect(pharmacist_portrait != null and pharmacist_portrait.texture.resource_path.ends_with("pharmacist_manami/pharmacist/neutral.png"), "Pharmacist portrait missing")
	app.show_staff("doc_aoi", "clinic", "smile")
	var portrait = app.page.get_node_or_null("CharacterPortrait")
	expect(portrait != null, "Doctor portrait missing")
	if portrait != null:
		expect(portrait.texture.resource_path.ends_with("c1058-smile-ai.png"), "Smile variant not selected")
	app.show_staff("doc_rei", "exam")
	var missing_art: Dictionary = app.content.find_record("staff", "doc_rei").duplicate(true)
	missing_art.visuals.portraits = {}
	app.base("Fallback", "", true)
	app.add_portrait(missing_art)
	expect(app.background.show_portrait, "Missing-asset silhouette fallback broken")
	app.title_screen()
	expect(app.screen == "title", "Return to title broken")
	await process_frame
	print("SMOKE: %s failure(s); intro branches, locations and staff pages exercised" % failures)
	quit(1 if failures else 0)

func advance_until(target_id: String, limit: int = 20) -> bool:
	for i in range(limit):
		if app.session.current_id == target_id:
			return true
		if app.screen != "dialogue":
			return false
		app.advance(-1)
	return app.session.current_id == target_id
