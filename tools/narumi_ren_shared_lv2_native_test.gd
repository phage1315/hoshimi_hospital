extends "res://tools/miyuki_lv3_retest.gd"
## Visible-window, synthetic-GUI-input acceptance test for Narumi/Ren shared Lv2.

const ID := "narumi_ren_shared_lv2_sign_here"
const NODE_COUNT := 294
const ACTORS := ["doc_aoi", "nurse_haru"]

var output := ""
var pages_seen := 0
var nodes_seen := 0
var captured: Dictionary = {}


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


func gui_advance(button: Button, force_mouse: bool = false) -> void:
	var mode := pages_seen % 3
	if force_mouse or mode == 0 or button != app.dialogue_default_button:
		await click(button)
		input_counts.mouse += 1
	elif mode == 1:
		await key_advance(KEY_SPACE)
		input_counts.space += 1
	else:
		await key_advance(KEY_ENTER)
		input_counts.enter += 1
	pages_seen += 1


func rendered_speaker(expected: String) -> bool:
	var labels: Array = app.page.find_children("*", "Label", true, false)
	return labels.any(func(label): return label.text == expected)


func play_route(locale: String, branch_choice: int) -> void:
	var g = app.game
	expect(g.prepare_character_event_test_save(ID), "Isolated shared Lv2 fixture " + locale)
	var definition: Dictionary = g.character_event_definitions.get(ID, {})
	expect(not definition.is_empty() and definition.nodes.size() == NODE_COUNT, "Registered 294-node shared event " + locale)
	expect(g.character_event_available(definition), "Shared Lv2 gate ready " + locale)
	for actor_id in ACTORS:
		expect(g.relationship_level(actor_id) == 1, actor_id + " starts at Lv1")
	app.show_location("lobby")
	expect(app.screen == "character_event" and g.active_character_event_id == ID, "Real lobby scheduler entry " + locale)
	if failures:
		return
	var session = g.character_events.get(ID)
	var visited := {}
	var branch_count := 0
	var previous_background := ""
	var auto_tested := false
	var guard := 0
	while session != null and not session.completed and guard <= NODE_COUNT + 4:
		guard += 1
		var node: Dictionary = session.current()
		var node_id := str(node.id)
		expect(not visited.has(node_id), "No GUI route cycle " + locale + ":" + node_id)
		visited[node_id] = true
		expect(not g.can_save_progress() and g.snapshot().is_empty(), "No event-inner save " + node_id)
		for actor_id in ACTORS:
			expect(g.relationship_level(actor_id) == 1, "No early shared rank settlement " + actor_id + ":" + node_id)
		var page_texts: Array = app.authored_dialogue_pages(str(node.text))
		for page_index in range(page_texts.size()):
			await process_frame
			var body = app.page.get_node_or_null("CharacterEventDialogue")
			expect(body != null and body.text == str(page_texts[page_index]), "Rendered exact text " + locale + ":" + node_id)
			if body != null:
				expect(body.get_content_height() <= body.size.y or body.scroll_active, "Dialogue fits or scrolls " + node_id)
			expect(rendered_speaker(str(node.speaker_label)), "Rendered exact speaker " + locale + ":" + node_id)
			var portraits: Array[Node] = app.page.find_children("EventPortrait_*", "TextureRect", true, false)
			var expected_portraits: Array = node.get("event_portraits", [])
			if bool(node.hide_portrait):
				expect(portraits.is_empty(), "Narrator has no borrowed portrait " + node_id)
			else:
				expect(portraits.size() == expected_portraits.size(), "Exact portrait count " + node_id)
				for item in expected_portraits:
					var portrait: TextureRect = app.page.get_node_or_null("EventPortrait_" + str(item.id))
					expect(portrait != null and portrait.texture != null and portrait.texture.resource_path == "res://" + str(item.path), "Exact portrait asset " + node_id + "/" + str(item.id))
					if portrait != null and str(item.id) == "shimotsuki_mika":
						var source_size := Vector2(float(portrait.texture.get_width()), float(portrait.texture.get_height()))
						var fit_scale := minf(portrait.size.x / source_size.x, portrait.size.y / source_size.y)
						var fitted_height := source_size.y * fit_scale
						var visible_bottom := portrait.position.y + (portrait.size.y + fitted_height) / 2.0
						expect(absf(visible_bottom - 540.0) < 0.75, "Visible Mika portrait meets dialogue frame " + node_id)
			var background = app.page.get_node_or_null("SceneBackground")
			expect(background != null and background.texture != null and background.texture.resource_path == "res://" + app.background_path(str(node.background_id)), "Exact background " + node_id)
			var calendar = app.page.get_node_or_null("CalendarHeader")
			expect(calendar != null and not calendar.visible, "Authored cross-day scene hides compressed clock " + node_id)

			var shot_key := ""
			if str(node.actor_id) == "shimotsuki_mika" and not bool(node.hide_portrait):
				shot_key = locale + "_mika_" + str(node.expression)
			elif str(node.background_id) != previous_background:
				shot_key = locale + "_background_" + str(node.background_id)
			elif node.choices.size() == 2:
				shot_key = locale + "_choice_" + node_id
			if not shot_key.is_empty() and not captured.has(shot_key) and page_index == 0:
				captured[shot_key] = true
				await shot(shot_key)
			previous_background = str(node.background_id)
			observations.append({
				"locale": locale, "node": node_id, "page": page_index,
				"speaker": str(node.speaker_label), "text": str(page_texts[page_index]),
				"background": background.texture.resource_path if background != null and background.texture != null else "",
				"expression": str(node.expression),
				"portraits": expected_portraits,
			})
			if failures:
				return

			var choice_index := 0
			var final_page := page_index + 1 == page_texts.size()
			if final_page and node.choices.size() == 2:
				choice_index = branch_choice
				branch_count += 1
			var selected: Dictionary = node.choices[choice_index]
			var button: Button = app.dialogue_default_button
			if final_page and node.choices.size() == 2:
				button = app.page.get_node_or_null("EventChoice_" + str(selected.id))

			if not auto_tested and not final_page and button == app.dialogue_default_button:
				var old_text: String = app.current_dialogue_text()
				await click(app.dialogue_auto_toggle_button)
				var deadline := Time.get_ticks_msec() + 15000
				while app.current_dialogue_text() == old_text and Time.get_ticks_msec() < deadline:
					await process_frame
				expect(app.current_dialogue_text() != old_text, "Auto-play advances exactly from visible dialogue " + locale)
				await click(app.dialogue_auto_toggle_button)
				input_counts.auto += 1
				auto_tested = true
				pages_seen += 1
			else:
				await gui_advance(button, final_page and node.choices.size() == 2)

			if page_index + 1 < page_texts.size():
				expect(session.current().id == node.id and app.current_dialogue_text() == str(page_texts[page_index + 1]), "One page per GUI input " + node_id)
			elif str(selected.next) == "@end":
				expect(session.completed, "Final GUI choice settles " + locale)
			else:
				expect(str(session.current().id) == str(selected.next), "Authored GUI branch target " + node_id)
			if failures:
				return
		nodes_seen += 1
	expect(session != null and session.completed and guard <= NODE_COUNT + 4, "Complete visible GUI playback " + locale)
	expect(branch_count == 2, "Both authored choices displayed " + locale)
	for actor_id in ACTORS:
		expect(g.relationship_level(actor_id) == 2, actor_id + " reaches Lv2 only at ending")
	expect(app.screen == "day_transition", "Cross-day ending reaches visible transition " + locale)
	await shot(locale + "_day_transition")
	var transition: Button = app.page.get_node_or_null("DayTransitionContinue")
	await gui_advance(transition, true)
	expect(app.screen == "map" and g.can_save_progress(), "Visible return to safe hospital map " + locale)
	expect(not g.character_event_available(definition), "Completed shared event cannot repeat " + locale)
	await shot(locale + "_safe_return")


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
	app.saves.path = "/private/tmp/narumi_ren_shared_lv2_native_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	app.dialogue_auto_enabled = false
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		await play_route(locale, 0 if locale == "zh_CN" else 1)
		if failures:
			break
	var report := {
		"native": native, "checks": checks, "failures": failures,
		"nodes": nodes_seen, "pages": pages_seen, "inputs": input_counts,
		"languages": ["zh_CN", "en"], "routes": {"zh_CN": "A/A", "en": "B/B"},
		"scope": "isolated in-memory prerequisites; real lobby scheduler entry; visible native renderer; synthetic mouse/space/enter/auto GUI input; cross-day transition; safe return",
	}
	var obs := FileAccess.open(output + "/observations.json", FileAccess.WRITE)
	obs.store_string(JSON.stringify(observations, "\t"))
	obs.close()
	var file := FileAccess.open(output + "/native.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("NARUMI REN SHARED LV2 NATIVE ", JSON.stringify(report))
	quit(1 if failures else 0)
