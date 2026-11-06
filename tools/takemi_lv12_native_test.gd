extends SceneTree
## Visible production-renderer QA through the existing Event Test Hub.
## Preconditions are prepared by that hub in memory; no save slot is read or written.
const IDS := ["ev_doc_takemi_lv1_vivisection_frog", "ev_doc_takemi_lv2_fujino_laparotomy"]
const REVIEW := "res://docs/source/takemi_lv1_lv2/bilingual_review.json"
var app
var output := ""
var checks := 0
var failures := 0
var inputs := {"mouse": 0, "space": 0, "enter": 0}
var routes: Array = []
var captures: Array = []
var captured_portraits := {}
var coverage := {}

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func button_named(name: String) -> Button:
	return app.page.find_child(name, true, false) as Button

func click(button: Button) -> void:
	check(button != null and is_instance_valid(button) and button.is_visible_in_tree(), "Visible button")
	if button == null or not is_instance_valid(button): return
	var deadline := Time.get_ticks_msec() + 5000
	while button.disabled and Time.get_ticks_msec() < deadline:
		await create_timer(0.03).timeout
	check(not button.disabled, "Enabled button " + str(button.name))
	if button.disabled: return
	var point := button.get_global_rect().get_center()
	var move := InputEventMouseMotion.new()
	move.position = point
	move.global_position = point
	root.push_input(move, true)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		event.global_position = point
		root.push_input(event, true)
	inputs.mouse += 1
	await process_frame
	await process_frame

func key_button(button: Button, keycode: int) -> void:
	check(button != null and is_instance_valid(button), "Keyboard target")
	if button == null or not is_instance_valid(button): return
	var deadline := Time.get_ticks_msec() + 5000
	while button.disabled and Time.get_ticks_msec() < deadline:
		await create_timer(0.03).timeout
	check(not button.disabled, "Enabled keyboard target")
	if button.disabled: return
	button.grab_focus()
	await process_frame
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = keycode
		event.pressed = pressed
		root.push_input(event, true)
	inputs.space += 1 if keycode == KEY_SPACE else 0
	inputs.enter += 1 if keycode == KEY_ENTER else 0
	await process_frame
	await process_frame

func reveal(button: Button) -> void:
	if button == null: return
	var ancestor = button.get_parent()
	while ancestor != null and not ancestor is ScrollContainer:
		ancestor = ancestor.get_parent()
	if ancestor != null: ancestor.ensure_control_visible(button)
	await process_frame
	await process_frame

func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := output + "/" + name + ".png"
	check(root.get_texture().get_image().save_png(path) == OK, "Screenshot " + name)
	captures.append(path)

func open_hub() -> void:
	app.title_screen()
	await click(button_named("TitleDeveloper"))
	var modal = app.get_node_or_null("TitleDeveloperDialog")
	var entry = modal.find_child("EventTestHubEntry", true, false) as Button if modal != null else null
	check(entry != null, "Developer modal has Event Test Hub")
	if entry == null: return
	await key_button(entry, KEY_ENTER)
	check(app.screen == "event_test_hub", "Event Test Hub opened through title")

func review_rows(review: Dictionary, locale: String, id: String) -> Dictionary:
	var result := {}
	var prefix := "L1_" if "lv1" in id else "L2_"
	for row in review["en" if locale == "en" else "cn"]:
		if str(row.id).begins_with(prefix): result[str(row.id).to_lower()] = row
	return result

func approved_source_amendments(value: String) -> String:
	# Mirrors the already recorded amendments in miyuki_takemi_source_audit.py.
	return value.replace("Takashi", "Ryuji").replace("faintly蠕动ing", "faintly moving with peristalsis").replace("soft,蠕动ing loops", "soft, peristaltic loops").replace("thick脓 cavities", "thick pus-filled cavities")

func displayed_speaker() -> String:
	for label in app.page.find_children("*", "Label", true, false):
		if absf(label.position.y - 558.0) < 0.1 and label.is_visible_in_tree():
			return str(label.text)
	return ""

func map_return_button() -> Button:
	for button in app.page.find_children("*", "Button", true, false):
		if absf(button.position.x - 400.0) < 1.0 and absf(button.position.y - 475.0) < 1.0:
			return button as Button
	return null

func play(locale: String, id: String, review: Dictionary, branch_index: int) -> void:
	var rows := review_rows(review, locale, id)
	var route_tag := "primary" if branch_index == 0 else "alternate"
	var entry := button_named("CharacterEventTest_" + id)
	check(entry != null, "Hub entry " + id)
	if entry == null: return
	await reveal(entry)
	await shot(locale + "_" + id + "_" + route_tag + "_hub")
	await click(entry)
	check(app.screen == "character_event" and app.game.active_character_event_id == id, "Real event starts " + id)
	if app.screen != "character_event": return
	var event = app.game.character_events[id]
	var definition: Dictionary = app.game.character_event_definitions[id]
	var before: int = app.game.elapsed()
	var start_clock: int = app.game.current_absolute_clock()
	print("TAKEMI START clock=", start_clock, " target=", int(definition.time_start), " elapsed=", before, " story=", app.game.story_time_advance_minutes, " offset=", app.game.settled_clock_offset)
	check(start_clock == int(definition.time_start), "Test hub starts at authored clock " + id)
	if failures: return
	var visited := {}
	var page_count := 0
	for guard in range(500):
		if event.completed: break
		check(app.screen == "character_event", "Event remains visible")
		if app.screen != "character_event": break
		var node: Dictionary = event.current()
		var nid := str(node.id)
		check(rows.has(nid), "Source row " + nid)
		if not rows.has(nid): break
		var source: Dictionary = rows[nid]
		check(str(node.text) == approved_source_amendments(str(source.text)), "Original text with recorded amendments " + nid)
		check(str(node.get("speaker_label", "")) == approved_source_amendments(str(source.speaker)), "Original speaker with recorded amendments " + nid)
		check(displayed_speaker() == approved_source_amendments(str(source.speaker)), "Displayed speaker " + nid)
		var body = app.page.get_node_or_null("CharacterEventDialogue")
		check(body != null and not str(body.text).is_empty(), "Visible dialogue " + nid)
		if body == null: break
		check(str(body.text) == app.current_dialogue_text(), "Displayed current page " + nid)
		check(body.get_content_height() <= body.size.y + 1 or body.scroll_active, "Dialogue fits " + nid)
		check(not app.game.can_save_progress(), "No save inside event " + nid)
		var bg = app.page.get_node_or_null("SceneBackground")
		var background_id := str(node.get("background_id", definition.background_id))
		check(bg != null and bg.texture != null and bg.texture.resource_path == "res://" + app.background_path(background_id), "Background " + nid)
		var portrait_path := str(node.get("portrait_path", ""))
		if not portrait_path.is_empty():
			var portrait = app.page.get_node_or_null("CharacterEventPortrait")
			check(portrait != null and portrait.texture != null and portrait.texture.resource_path == "res://" + portrait_path, "Patient portrait " + nid)
			var art_key := locale + ":" + portrait_path
			if not captured_portraits.has(art_key):
				captured_portraits[art_key] = true
				await shot(locale + "_" + id + "_" + route_tag + "_" + nid)
		elif not visited.has(nid) and visited.is_empty():
			await shot(locale + "_" + id + "_" + route_tag + "_start")
		visited[nid] = true
		page_count += 1
		var more = button_named("EventDialogueContinue")
		var choice: Button = null
		var branching := false
		if more != null:
			choice = more
		else:
			var choices: Array = node.get("choices", [])
			check(not choices.is_empty(), "Choice exists " + nid)
			if choices.is_empty(): break
			choice = button_named("EventChoice_" + str(choices[branch_index if choices.size() > 1 else 0].id))
			branching = choices.size() > 1
			if branching: await shot(locale + "_" + id + "_" + route_tag + "_branch_" + nid)
		var old_page: int = app.dialogue_page_index
		if branching:
			await click(choice)
		elif page_count % 3 == 0:
			await click(choice)
		elif page_count % 3 == 1:
			await key_button(choice, KEY_SPACE)
		else:
			await key_button(choice, KEY_ENTER)
		check(event.completed or str(event.current().id) != nid or app.dialogue_page_index != old_page, "One input advances " + nid)
		if failures > 0: break
	check(event.completed, "Event completed " + id)
	if not event.completed: return
	check(int(event.settled_minutes) == int(definition.minutes), "Actual event duration recorded " + id)
	if app.screen == "day_transition":
		check(int(app.day_transition_display_schedule.absolute_clock) == start_clock + int(definition.minutes), "Overtime transition shows full duration " + id)
		await shot(locale + "_" + id + "_" + route_tag + "_day_transition")
		await click(button_named("DayTransitionContinue"))
		check(app.screen == "map", "Overtime event returns to next-day hospital map " + id)
	else:
		check(app.game.elapsed() - before == int(definition.minutes), "Workday ledger duration " + id)
		check(app.screen == "character_event_complete", "Completion screen " + id)
		await shot(locale + "_" + id + "_" + route_tag + "_complete")
		await click(map_return_button())
	check(app.screen == "map" and app.game.can_save_progress(), "Return to safe hospital map " + id)
	check(app.game.active_character_event_id.is_empty(), "Session closed " + id)
	await shot(locale + "_" + id + "_" + route_tag + "_return")
	var coverage_key := locale + ":" + id
	if not coverage.has(coverage_key): coverage[coverage_key] = {}
	for visited_id in visited: coverage[coverage_key][visited_id] = true
	routes.append({"locale": locale, "event": id, "branch": route_tag, "nodes_seen": visited.size(), "pages": page_count, "completed": event.completed, "return_screen": app.screen})
	print("TAKEMI NATIVE ", locale, " ", id, " ", route_tag, " nodes=", visited.size(), " pages=", page_count, " completed=", event.completed)

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output = arg.trim_prefix("--out=")
	assert(not output.is_empty())
	DirAccess.make_dir_recursive_absolute(output)
	check(DisplayServer.get_name() != "headless", "Visible native display")
	if failures: quit(1); return
	var review = JSON.parse_string(FileAccess.get_file_as_string(REVIEW))
	check(review is Dictionary, "Independent bilingual source review")
	if failures: quit(1); return
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/hoshimi_takemi_native_unused_%d.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		check(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		for id in IDS:
			for branch_index in [0, 1]:
				await open_hub()
				if failures: break
				await play(locale, id, review, branch_index)
				if failures: break
			if failures: break
		if failures: break
	for locale in ["zh_CN", "en"]:
		for id in IDS:
			var coverage_key: String = locale + ":" + id
			if coverage.has(coverage_key):
				check(coverage[coverage_key].size() == app.game.character_event_definitions[id].nodes.size(), "Both native routes cover every node " + coverage_key)
	check(not FileAccess.file_exists(app.saves.path), "No test or player save written")
	var coverage_counts := {}
	for key in coverage: coverage_counts[key] = coverage[key].size()
	var report := {"display_server": DisplayServer.get_name(), "checks": checks, "failures": failures, "routes": routes, "coverage": coverage_counts, "inputs": inputs, "captures": captures, "player_saves_written": false, "branches": "primary selects first option; alternate selects second option at every branch"}
	var file := FileAccess.open(output + "/results.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print("TAKEMI LV1/LV2 NATIVE: ", checks, " checks; ", failures, " failures; routes=", routes.size())
	quit(1 if failures else 0)
