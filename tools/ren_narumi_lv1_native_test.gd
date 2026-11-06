extends "res://tools/miyuki_lv3_retest.gd"
## Reuses the native mouse driver; all story advances use actual GUI input.

const IDS := ["ren_lv1_night_ward_1", "narumi_lv1_beyond_the_resume"]
const ACTORS := ["nurse_haru", "doc_aoi"]
const COUNTS := [243, 202]
var output := ""
var pages_seen := 0
var story_nodes_seen := 0

func key_advance(code: int) -> void:
	app.dialogue_default_button.grab_focus()
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.pressed = pressed
		root.push_input(event, true)
	await process_frame
	await process_frame

func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	expect(root.get_texture().get_image().save_png(output + "/" + name + ".png") == OK, "Saved screenshot " + name)

func play_one(index: int, locale: String) -> void:
	var id: String = IDS[index]
	var actor: String = ACTORS[index]
	var g = app.game
	expect(g.prepare_character_event_test_save(id), "Isolated fixture " + id)
	if index == 0:
		app.request_end_workday()
	else:
		app.show_location("shared_doctors_office")
	expect(app.screen == "character_event" and g.active_character_event_id == id, "Real map/departure entry " + id)
	if failures:
		return
	var session = g.character_events[id]
	var definition: Dictionary = g.character_event_definitions[id]
	var before_surgeries: int = g.completed_surgeries_total
	var previous_background := ""
	var actor_shot_backgrounds: Array[String] = []
	for i in range(COUNTS[index]):
		if session.completed or app.screen != "character_event":
			break
		var node: Dictionary = session.current()
		var expected: Dictionary = definition.nodes[i]
		expect(node.id == expected.id, "Ordered node " + id + ":" + str(i))
		expect(g.relationship_level(actor) == 0 and not g.can_save_progress(), "No mid-event settlement/save " + str(node.id))
		var page_texts: Array = app.authored_dialogue_pages(str(node.text))
		for page_index in range(page_texts.size()):
			await process_frame
			var body = app.page.get_node_or_null("CharacterEventDialogue")
			expect(body != null and body.text == str(page_texts[page_index]), "Rendered text " + str(node.id))
			if body != null:
				expect(body.get_content_height() <= body.size.y or body.scroll_active, "Dialogue fits or scrolls " + str(node.id))
			var names: Array = app.page.find_children("*", "Label", true, false)
			expect(names.any(func(label): return label.text == str(node.speaker_label)), "Rendered speaker " + str(node.id))
			var portrait = app.page.get_node_or_null("CharacterPortrait")
			if bool(node.hide_portrait):
				expect(portrait == null, "No borrowed portrait " + str(node.id))
			else:
				expect(portrait != null and portrait.texture != null, "Actor portrait present " + str(node.id))
				if portrait != null and portrait.texture != null:
					var profile: Dictionary = app.content.find_record("staff", actor)
					var portrait_path := str(profile.visuals.portraits.get(str(node.outfit) + "/" + str(node.expression), ""))
					expect(portrait.texture.resource_path == "res://" + portrait_path, "Exact actor costume portrait " + str(node.id))
			var background = app.page.get_node_or_null("SceneBackground")
			expect(background != null and background.texture != null and background.texture.resource_path == "res://" + app.background_path(str(node.background_id)), "Loaded scene background " + str(node.id))
			if index == 0:
				expect(not app.page.get_node("CalendarHeader").visible, "Night scene uses manuscript time")
			if (i == 0 or (str(node.background_id) != previous_background) or i in ([80, 160, 242] if index == 0 else [65, 130, 201])) and page_index == 0:
				await shot(locale + "_" + str(node.id))
			if not bool(node.hide_portrait) and str(node.background_id) not in actor_shot_backgrounds and page_index == 0:
				actor_shot_backgrounds.append(str(node.background_id))
				await shot(locale + "_actor_" + str(node.id))
			previous_background = str(node.background_id)
			if failures:
				return
			var mode := pages_seen % 3
			if mode == 0:
				await click(app.dialogue_default_button)
				input_counts.mouse += 1
			elif mode == 1:
				await key_advance(KEY_SPACE)
				input_counts.space += 1
			else:
				await key_advance(KEY_ENTER)
				input_counts.enter += 1
			pages_seen += 1
			if page_index + 1 < page_texts.size():
				expect(session.current().id == node.id and app.current_dialogue_text() == str(page_texts[page_index + 1]), "One page per input " + str(node.id))
			elif i + 1 < COUNTS[index]:
				expect(session.current().id == definition.nodes[i + 1].id, "One node per input " + str(node.id))
			if failures:
				return
		story_nodes_seen += 1
	expect(session.completed and story_nodes_seen >= COUNTS[index], "Complete GUI playback " + id)
	expect(g.relationship_level(actor) == 1 and session.settled_minutes == int(definition.minutes), "Only final rank/time settlement " + id)
	expect(g.completed_surgeries_total == before_surgeries and not g.active_surgery_in_progress(), "No Surgery Runner case " + id)
	if index == 0:
		expect(app.screen == "day_transition", "Night transition")
		await click(app.page.get_node("DayTransitionContinue"))
		expect(app.screen == "map", "Next-day map")
	else:
		expect(app.screen == "character_event_complete", "Office event completion")
		app.show_map()
	expect(g.can_save_progress() and not g.character_event_available(definition), "Safe return and replay blocked " + id)
	await shot(locale + "_" + id + "_return")

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			output = arg.trim_prefix("--out=")
	assert(not output.is_empty())
	DirAccess.make_dir_recursive_absolute(output)
	native = DisplayServer.get_name() != "headless"
	expect(native, "Visible native renderer required")
	if not native:
		quit(1)
		return
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/ren_narumi_native_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	app.dialogue_auto_enabled = false
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		for index in range(IDS.size()):
			await play_one(index, locale)
			if failures:
				break
		if failures:
			break
	var report := {"native": native, "checks": checks, "failures": failures, "nodes": story_nodes_seen, "pages": pages_seen, "inputs": input_counts, "languages": ["zh_CN", "en"], "scope": "isolated in-memory prerequisites; natural departure/location entry; full real-GUI playback and safe return"}
	var file := FileAccess.open(output + "/native.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("REN NARUMI NATIVE ", JSON.stringify(report))
	quit(1 if failures else 0)
