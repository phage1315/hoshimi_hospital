extends "res://tools/mizuho_first_surgery_test.gd"
var approved: Dictionary = {}
var expected: Dictionary = {}
var seen_cgs: Dictionary = {}
func play_cgs(id: String, locale: String, gallery: bool) -> void:
	var count := 0
	while count < 1100:
		while app.screen == "special_event_blackout":await process_frame
		var event = app.special_event_gallery_replay if gallery else app.game.active_special_event
		if event == null or event.completed or str(event.definition.id) != id:break
		var node: Dictionary = event.current()
		var step: Dictionary = event.current_step()
		var path: String = str(node.get("cg_path", ""))
		expect(path == str(expected.get(node.id, "")), "Approved CG range including exits")
		for page in app.authored_dialogue_pages(app.special_event_localized_text(step,node)):
			await process_frame
			cast(node,str(step.id),locale)
			expect(app.current_dialogue_text() == page, "Exact localized text")
			if not gallery:expect(not app.game.can_save_progress(), "No mid-event save")
			if not path.is_empty():
				var cg: TextureRect = app.page.get_node("CharacterEventCG")
				if approved[path].get("cg_fit", "contain") == "inset":
					expect(cg.get_rect() == Rect2(350,175,580,326), "Photo inset geometry")
					expect(not cg.get_rect().intersects(app.page.get_node("SpecialEventReplayDialogueBox" if gallery else "SpecialEventDialogueBox").get_rect()), "Photo does not overlap dialogue")
				var key := locale + ("_gallery_" if gallery else "_main_") + path.get_file().get_basename()
				if not seen_cgs.has(key):
					seen_cgs[key] = true
					if native:
						await RenderingServer.frame_post_draw
						expect(root.get_texture().get_image().save_png(QA + "final_" + key + ".png") == OK, "CG screenshot")
			app.dialogue_default_button.emit_signal("pressed")
			await process_frame
		count += 1;seen += 1
	expect(count == {Flow.A:195,Flow.B:631,Flow.C:174}[id], "Complete episode flow %s %s gallery=%s count=%s" % [id,locale,gallery,count])
func run() -> void:
	native = DisplayServer.get_name() != "headless"
	for filename in DirAccess.get_files_at("res://research/imports"):
		if filename.begins_with("mizuho_first_surgery_cg") and filename.contains("_approved_") and filename.ends_with(".json"):
			var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://research/imports/"+filename))
			approved[manifest.destination] = manifest
			for id in manifest.nodes:expected[id] = manifest.destination
	for row in JSON.parse_string(FileAccess.get_file_as_string("res://docs/source/mizuho_first_surgery/parsed_source.json")):sources[str(row.id)] = row
	app = load("res://godot/scenes/main.tscn").instantiate();root.add_child(app);await process_frame
	app.dialogue_auto_enabled = false
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale), "Localized content loads");app.configure_game_content()
		for gallery in [false,true]:
			for id in [Flow.A, Flow.B, Flow.C]:
				setup(app.game)
				if id != Flow.A:
					done(app.game,Flow.A,102);done(app.game,Flow.S,103)
					app.game.set_test_time(105,540)
				if id == Flow.C:
					done(app.game,Flow.B,105);app.game.set_test_time(106,540)
				if gallery:
					done(app.game,id,app.game.day_number());app.replay_special_gallery_entry(id)
				else:app.show_map()
				await play_cgs(id,locale,gallery)
		expect(failures == 0, "All flow checks pass")
	expect(seen_cgs.size() == approved.size()*4, "Every approved CG seen in both languages and modes")
	print("MIZUHO FINAL CG: ",checks," checks; ",failures," failures; ",seen," nodes; ",approved.size()," CGs")
	quit(1 if failures else 0)
