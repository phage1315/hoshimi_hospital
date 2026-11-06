extends SceneTree
var checks := 0
var failures := 0
func expect(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(note)
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var ids := ["miyuki_lv4_inspection", "ev_doc_takemi_lv1_vivisection_frog", "ev_doc_takemi_lv2_fujino_laparotomy"]
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		var g = app.game
		for id in ids:
			for branch in range(4):
				expect(g.prepare_character_event_test_save(id), "Fixture " + id)
				var d: Dictionary = g.character_event_definitions[id]
				if id.begins_with("ev_doc_takemi_"):
					expect(g.current_absolute_clock() == int(d.time_start), "Fixture begins at authored event clock " + id)
				var before: int = g.elapsed()
				var surgical_count: int = g.completed_surgeries_total
				var event = g.start_character_event(id)
				expect(event != null, "Start " + id + " " + g.last_error)
				if event == null:continue
				var count := 0
				var choice_index := 0
				while not event.completed and count < 150:
					var n: Dictionary = event.current()
					expect(not str(n.get("text", "")).is_empty(), "Text " + str(n.id))
					expect(not g.can_save_progress(), "Save locked " + str(n.id))
					if branch == 0:
						app.show_character_event()
						var portrait = app.page.get_node_or_null("CharacterEventPortrait")
						if portrait == null: portrait = app.page.get_node_or_null("CharacterPortrait")
						if not n.get("hide_portrait", false):
							expect(portrait != null and portrait.texture != null, "Portrait " + str(n.id))
						await process_frame
						if DisplayServer.get_name() != "headless" and locale == "zh_CN" and str(n.id) in ["n004", "l1_001", "l2_001"]:
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("/tmp/hoshimi_" + str(n.id) + ".png")
					var choices: Array = n.get("choices", [])
					expect(not choices.is_empty(), "Continuation " + str(n.id))
					if choices.is_empty():break
					var selected := 0
					if choices.size() > 1:
						selected = (branch >> choice_index) & 1
						choice_index += 1
					expect(g.choose_character_event(str(choices[selected].id)), "Advance " + str(n.id))
					count += 1
				expect(event.completed, "Complete " + id)
				expect(g.elapsed() - before == int(d.minutes), "Duration " + id + ": " + str(g.elapsed() - before))
				expect(int(g.relation_for(str(d.actor_id)).level) == int(d.target_level), "Rank " + id)
				expect(g.completed_surgeries_total == surgical_count, "Pure story, no surgery settlement")
				if id == "miyuki_lv4_inspection":
					expect(g.free_h_relationship_qualified("nurse_yui"), "Lv4 grants formal intimacy qualification")
					expect(g.free_h_unlocked("nurse_yui"), "Completed Lv4 and formal intimacy qualification unlock ready Free H content")
				g.finish_character_event()
				expect(not g.character_event_available(d), "No replay " + id)
		app.show_event_test_hub()
		for id in ids:expect(app.page.find_child("CharacterEventTest_" + id, true, false) != null, "Hub entry " + id)
	print("Current events: %d checks, %d failures" % [checks, failures])
	app.queue_free()
	await process_frame
	quit(1 if failures else 0)
