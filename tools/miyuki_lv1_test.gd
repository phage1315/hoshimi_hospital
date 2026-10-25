extends SceneTree
const EVENT = "miyuki_lv1_not_that_kind_of_inexperienced"
var checks := 0
var failures := 0
func expect(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(note)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		var g = app.game
		g.reset()
		var d: Dictionary = g.character_event_definitions[EVENT]
		g.character_event_definitions = {EVENT:d}
		g.relation_for("nurse_yui").familiarity = 10
		expect(not g.character_event_available(d), "Unmet blocked")
		g.meet_staff("nurse_yui")
		var r: Dictionary = g.relation_for("nurse_yui")
		r.familiarity = 9
		expect(not g.character_event_available(d), "Fam9 blocked")
		r.familiarity = 10
		expect(g.character_event_available(d), "Fam10 at Lv0; no extra wait after meeting")
		expect(g.completed_surgeries_total == 0, "No surgical prerequisite")
		expect(g.next_character_event_at("station").get("id", "") == EVENT, "Station entry")
		expect(g.next_character_event_at("ward").is_empty(), "Only station")
		for field in ["active_special_event_id", "active_character_event_id", "active_micro_event_id", "active_preop_id"]:
			g.set(field, "busy")
			expect(not g.character_event_available(d), "No interruption: " + field)
			g.set(field, "")
		# Exercise the shared three-day milestone cooldown without treating Lv0 as a rank.
		var prior = load("res://godot/systems/character_event_session.gd").new(d)
		prior.completed = true
		prior.completed_day = 1
		g.character_events["test_prior_rank"] = prior
		r.rank_history.append("test_prior_rank")
		g.set_test_time(3, 540)
		expect(not g.character_event_available(d), "Two days after milestone blocked")
		g.set_test_time(4, 540)
		expect(g.character_event_available(d), "Three days after milestone permitted")
		r.rank_history.clear()
		g.character_events.erase("test_prior_rank")
		# Older saves already at Lv1 must never replay the newly registered event.
		r.level = 1
		expect(not g.character_event_available(d), "Existing Lv1 save blocked even without this event ID")
		r.level = 0
		var checkpoint: Dictionary = JSON.parse_string(JSON.stringify(g.snapshot()))
		expect(g.restore(checkpoint), "Restore pending save")
		r = g.relation_for("nurse_yui")
		var before: int = g.elapsed()
		var attrs: Dictionary = g.player_attributes().duplicate(true)
		var count: int = g.completed_surgeries_total
		var relationships: Dictionary = g.relationships.duplicate(true)
		var event = g.start_character_event(EVENT)
		expect(event != null and not g.can_save_progress(), "Event starts with save lock")
		for i in range(44):
			expect(r.level == 0, "No early upgrade")
			app.show_character_event()
			var n: Dictionary = event.current()
			var expected_label: String = str(n.speaker_label)
			var label_found := false
			for child in app.page.get_children():
				if child is Label and child.text == expected_label:label_found = true
			expect(label_found, "Authored speaker displayed: " + expected_label)
			if n.get("hide_portrait", false):
				expect(app.page.get_node_or_null("CharacterPortrait") == null, "NPC has no borrowed portrait")
			else:
				var portrait = app.page.get_node_or_null("CharacterPortrait")
				expect(portrait != null, "Uniform visible")
				if portrait != null:
					var actor: Dictionary = g.staff_record("nurse_yui")
					expect(portrait.texture.resource_path == "res://" + str(actor.visuals.portraits["uniform/" + str(n.expression)]), "Correct expression and white uniform")
			if "--capture" in OS.get_cmdline_user_args() and i in [3,9,18,32,37,43]:
				await process_frame
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("res://docs/qa/miyuki_lv1/%s_%s.png" % [locale,n.id])
			var rendered := ""
			for page_number in range(20):
				var page_data: Dictionary = app.dialogue_page("character:%s:%s" % [EVENT, n.id], str(n.text), false, true)
				rendered += str(page_data.text)
				if not page_data.has_more:break
				var next_page = app.page.get_node_or_null("EventDialogueContinue")
				expect(next_page != null, "Long dialogue has a page button")
				if next_page == null:break
				next_page.pressed.emit()
				expect(event.current().id == n.id, "Pagination retains the authored node")
			expect(rendered == str(n.text), "All dialogue pages preserve exact text")
			if i < 43:expect(g.choose_character_event(str(n.choices[0].id)), "Advance")
			else:app.choose_character_event(str(n.choices[0].id))
		expect(event.completed and g.active_character_event_id.is_empty(), "Finished and returned to station")
		expect(g.elapsed()-before == 20, "Exactly 20 minutes")
		expect(r.level == 1 and r.familiarity == 10 and r.affection == 0, "Only Lv1 awarded")
		expect(r.rank_history.count(EVENT) == 1 and r.event_history.count(EVENT) == 1, "Single rank and completion")
		expect(g.completed_surgeries_total == count and g.player_attributes() == attrs, "No surgery or attribute rewards")
		for actor_id in relationships:
			if actor_id != "nurse_yui":expect(g.relationships[actor_id] == relationships[actor_id], "Other relationships unchanged")
		expect(g.can_save_progress(), "Saving restored")
		expect(not g.character_event_available(d), "No replay")
		expect(g.restore(JSON.parse_string(JSON.stringify(g.snapshot()))), "Completed save restores")
		expect(g.relation_for("nurse_yui").level == 1 and not g.character_event_available(d), "No replay or duplicate level after load")
	print("MIYUKI LV1: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
