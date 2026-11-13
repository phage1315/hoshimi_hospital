extends "res://tools/narumi_ren_shared_lv2_native_test.gd"
## Five production events, reusing the existing native input/screenshot helpers.
## Fixtures are memory-only; observations are QA evidence, never resume files.
const EVENTS := ["narumi_lv1_beyond_the_resume", "ren_lv1_night_ward_1", "narumi_ren_shared_lv2_sign_here", "narumi_ren_shared_lv3_settled_accounts", "narumi_lv4_after_work"]
var route_results: Array = []
var coverage: Dictionary = {}
var han := RegEx.new()

func button_for_method(method: String) -> Button:
	for b in app.page.find_children("*", "Button", true, false):
		if not b.is_visible_in_tree() or b.disabled: continue
		for connection in b.get_signal_connection_list("pressed"):
			if str(connection.callable.get_method()) == method: return b
	return null

func observe(node: Dictionary, definition: Dictionary, locale: String) -> Array:
	var body = app.page.get_node_or_null("CharacterEventDialogue")
	expect(body != null and body.text == app.current_dialogue_text(), "Actual dialogue widget " + str(node.id))
	if body != null:
		expect(body.get_content_height() <= body.size.y + 1 or body.scroll_active, "Text fits " + str(node.id))
	expect(rendered_speaker(str(node.speaker_label)), "Speaker matches " + str(node.id))
	if locale == "en":
		for label in app.page.find_children("*", "Label", true, false) + app.page.find_children("*", "RichTextLabel", true, false) + app.page.find_children("*", "Button", true, false):
			if label.is_visible_in_tree(): expect(han.search(label.text) == null, "No Chinese fallback " + str(node.id) + "/" + str(label.name))
	var actual: Array = []
	var actual_portraits: Array = []
	for tex in app.page.find_children("*", "TextureRect", true, false):
		if not tex.is_visible_in_tree(): continue
		actual.append({"widget":str(tex.name), "path":tex.texture.resource_path if tex.texture else "", "rect":[tex.position.x,tex.position.y,tex.size.x,tex.size.y]})
		if str(tex.name).begins_with("EventPortrait_") or str(tex.name) == "CharacterPortrait": actual_portraits.append(tex)
	var cg = app.page.get_node_or_null("CharacterEventCG")
	var cg_path := str(node.get("cg_path", ""))
	if not cg_path.is_empty():
		expect(cg != null and cg.texture != null and cg.texture.resource_path == "res://" + cg_path, "CG loaded " + str(node.id))
		if cg != null:
			var mode := TextureRect.STRETCH_KEEP_ASPECT_COVERED if str(node.get("cg_fit", "cover")) == "cover" else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			expect(cg.stretch_mode == mode, "CG fit mode " + str(node.id))
	else: expect(cg == null, "CG cleared " + str(node.id))
	if (not cg_path.is_empty() and not node.get("cg_portrait_overlay", false)) or node.get("hide_portrait", false):
		expect(actual_portraits.is_empty(), "No stale portrait over CG/narration " + str(node.id))
	elif node.has("event_portraits"):
		expect(actual_portraits.size() == node.event_portraits.size(), "Exact portrait count " + str(node.id))
		for item in node.event_portraits:
			var tex = app.page.get_node_or_null("EventPortrait_" + str(item.id))
			expect(tex != null and tex.texture != null and tex.texture.resource_path == "res://" + str(item.path), "Exact portrait " + str(node.id) + "/" + str(item.id))
			if tex != null and str(item.id) in ["shimotsuki_mika", "kunizuka_yayoi"]:
				var source := Vector2(tex.texture.get_width(), tex.texture.get_height())
				var height := source.y * minf(tex.size.x / source.x, tex.size.y / source.y)
				expect(absf(tex.position.y + (tex.size.y + height) / 2.0 - 540.0) < 0.75, "Patient portrait bottom meets dialogue " + str(node.id))
	else:
		var actor_id := str(node.get("actor_id", definition.actor_id))
		var profile: Dictionary = app.content.find_record("staff", actor_id)
		var path := str(profile.get("visuals", {}).get("portraits", {}).get(str(node.outfit) + "/" + str(node.expression), ""))
		var portrait = app.page.get_node_or_null("CharacterPortrait")
		expect(not path.is_empty() and portrait != null and portrait.texture.resource_path == "res://" + path, "Exact costume/expression " + str(node.id))
	var bg = app.page.get_node_or_null("SceneBackground")
	expect(bg != null and bg.texture.resource_path == "res://" + app.background_path(str(node.background_id)), "Background " + str(node.id))
	if definition.get("hide_calendar_header", false): expect(not app.page.get_node("CalendarHeader").visible, "Narrative calendar hidden")
	for b in app.page.find_children("*", "Button", true, false):
		if b.is_visible_in_tree(): expect(Rect2(Vector2.ZERO, app.size).encloses(b.get_global_rect()), "Button within viewport " + str(b.name))
	return actual

func expected_target(choice: Dictionary, selected: Array) -> String:
	var target := str(choice.next)
	var prior: Dictionary = choice.get("next_if_choice", {})
	if not prior.is_empty() and selected.has(str(prior.choice_id)): target = str(prior.next)
	var relation: Dictionary = choice.get("next_if_relationship_level", {})
	if not relation.is_empty() and app.game.relationship_level(str(relation.actor_id)) >= int(relation.minimum): target = str(relation.next)
	return target

func finish_gui(tag: String) -> void:
	for i in range(8):
		await process_frame
		await shot(tag + "_end_" + str(i) + "_" + app.screen)
		if app.screen == "map": break
		var b: Button
		match app.screen:
			"day_transition": b = app.page.get_node_or_null("DayTransitionContinue")
			"character_event_reward": b = button_for_method("show_character_event_complete")
			"character_event_complete":
				b = button_for_method("finish_long_sunday_character_event")
				if b == null: b = button_for_method("show_map")
		expect(b != null, "Accessible actual ending/return button " + app.screen)
		if b == null: return
		await gui_advance(b, true)
	expect(app.screen == "map" and app.game.can_save_progress(), "Return to save-safe hospital map")

func replay_entry_exit(id: String, tag: String) -> void:
	var g = app.game
	var elapsed: int = g.elapsed()
	var relations: Dictionary = g.relationships.duplicate(true)
	app.show_gallery_entry(id)
	await process_frame
	expect(app.screen == "gallery_entry", "Completed event gallery unlocked")
	await shot(tag + "_gallery")
	await gui_advance(button_for_method("replay_gallery_entry"), true)
	expect(app.screen == "gallery_replay", "Replay starts through visible button")
	for i in range(3):
		expect(is_instance_valid(app.dialogue_default_button), "Replay continue available")
		if failures: return
		await gui_advance(app.dialogue_default_button)
	await shot(tag + "_replay")
	await gui_advance(button_for_method("show_gallery_entry"), true)
	expect(app.screen == "gallery_entry" and g.elapsed() == elapsed and g.relationships == relations, "Replay early exit preserves time and relationships")

func play_event(id: String, locale: String, alternate: int) -> void:
	var g = app.game
	app.dialogue_auto_enabled = false
	app.character_event_from_test = false
	app.character_event_return_preop_id = ""
	expect(g.prepare_character_event_test_save(id), "Existing isolated fixture " + id)
	var definition: Dictionary = g.character_event_definitions[id]
	if id == "narumi_lv4_after_work": g.relation_for("nurse_haru").level = 3 + alternate
	expect(g.character_event_available(definition), "Real prerequisite gate " + id)
	var start_day: int = g.day_number()
	var before_surgeries: int = g.completed_surgeries_total
	var actors: Array = g.character_event_relationship_actor_ids(definition)
	var ranks := {}
	for actor in actors: ranks[actor] = g.relationship_level(actor)
	if id == "ren_lv1_night_ward_1":
		app.show_player_office()
		await process_frame
		await gui_advance(button_for_method("request_end_workday"), true)
	elif id == "narumi_lv4_after_work":
		app.show_sunday_invites()
		await process_frame
		await shot(locale + "_lv4_invitation_" + str(alternate))
		await gui_advance(app.page.get_node_or_null("SundayCandidate_doc_aoi"), true)
	else: app.show_location(str(definition.location_id))
	expect(app.screen == "character_event" and g.active_character_event_id == id, "Production entry " + id)
	if failures: return
	var session = g.character_events[id]
	var visited := {}
	var selected_ids: Array = []
	var branch_count := 0
	var route_pages := 0
	var last_cg := ""
	var auto_done := alternate != 0
	var tag := locale + "_" + id + "_" + str(alternate)
	var coverage_key := locale + ":" + id
	if not coverage.has(coverage_key): coverage[coverage_key] = {}
	while not session.completed and visited.size() <= definition.nodes.size():
		var node: Dictionary = session.current()
		var nid := str(node.id)
		expect(not visited.has(nid), "No loop " + nid)
		visited[nid] = true
		coverage[coverage_key][nid] = true
		expect(not g.can_save_progress() and g.snapshot().is_empty(), "Event save locked " + nid)
		for actor in actors: expect(g.relationship_level(actor) == ranks[actor], "No early relationship settlement " + nid)
		var page_texts: Array = app.authored_dialogue_pages(str(node.text))
		for p in range(page_texts.size()):
			await process_frame
			expect(app.current_dialogue_text() == str(page_texts[p]), "Exact visible text/page " + nid)
			var visuals := observe(node, definition, locale)
			observations.append({"event":id, "locale":locale, "route":alternate, "node":nid, "page":p, "text":app.current_dialogue_text(), "speaker":str(node.speaker_label), "visuals":visuals})
			var cg := str(node.get("cg_path", ""))
			var key := ""
			if p == 0:
				if cg != last_cg: key = "cg_" + nid
				elif node.choices.size() > 1: key = "choice_" + nid
				elif visited.size() == 1: key = "start"
				elif str(node.actor_id) in ["shimotsuki_mika", "kunizuka_yayoi"] and cg.is_empty() and not node.hide_portrait: key = "patient_" + str(node.actor_id) + "_" + str(node.outfit) + "_" + str(node.expression)
				elif not node.hide_portrait and cg.is_empty(): key = "costume_" + str(node.actor_id) + "_" + str(node.outfit)
				var unique := locale + "_" + id + "_" + key
				if not key.is_empty() and not captured.has(unique): captured[unique] = true; await shot(unique)
			last_cg = cg
			if failures: await shot(tag + "_failure_" + nid); return
			var final_page := p + 1 == page_texts.size()
			var choice: Dictionary = node.choices[alternate if node.choices.size() > 1 else 0]
			if final_page and node.choices.size() > 1: branch_count += 1
			var target := expected_target(choice, selected_ids)
			var b: Button = app.dialogue_default_button
			if final_page and node.choices.size() > 1: b = app.page.get_node_or_null("EventChoice_" + str(choice.id))
			if not auto_done and node.choices.size() == 1:
				await click(app.dialogue_auto_toggle_button)
				var deadline := Time.get_ticks_msec() + 15000
				while not session.completed and str(session.current().id) == nid and app.dialogue_page_index == p and Time.get_ticks_msec() < deadline: await process_frame
				await click(app.dialogue_auto_toggle_button)
				input_counts.auto += 1; pages_seen += 1; auto_done = true
			else: await gui_advance(b, final_page and node.choices.size() > 1)
			route_pages += 1
			if not final_page: expect(str(session.current().id) == nid and app.current_dialogue_text() == str(page_texts[p+1]), "Exactly one page per input " + nid)
			elif target == "@end": expect(session.completed, "GUI ending settles " + id)
			else: expect(str(session.current().id) == target, "Exactly one node per input " + nid + " -> " + target)
			if final_page: selected_ids.append(str(choice.id))
			if failures: await shot(tag + "_input_failure_" + nid); return
		nodes_seen += 1
	expect(session.completed, "Entire native route completed " + tag)
	for actor in actors: expect(g.relationship_level(actor) == int(definition.target_level), "Final rank " + str(actor))
	expect(g.completed_surgeries_total == before_surgeries, "Fixed narrative does not run a clinical case")
	if definition.has("completion_day_offset"):
		expect(g.day_number() == start_day + int(definition.completion_day_offset) and g.current_absolute_clock() == int(definition.completion_absolute_clock), "Settled calendar/time " + id)
	await finish_gui(tag)
	expect(not g.character_event_available(definition), "Completed event cannot trigger twice " + id)
	if id == "narumi_lv4_after_work": expect(g.free_h_unlocked("doc_aoi") and g.sunday_history.size() == 1, "Lv4 unlock and single Sunday consumption")
	if alternate == 0: await replay_entry_exit(id, tag)
	route_results.append({"event":id,"locale":locale,"alternate":alternate,"nodes":visited.size(),"pages":route_pages,"choices":branch_count,"completed":session.completed,"ren_level":3+alternate if id == "narumi_lv4_after_work" else null})
	print("NATIVE_ROUTE ", JSON.stringify(route_results.back()))
	write_report()

func write_report() -> void:
	var counts := {}
	for key in coverage: counts[key] = coverage[key].size()
	var f := FileAccess.open(output + "/native.json", FileAccess.WRITE)
	f.store_string(JSON.stringify({"display_server":DisplayServer.get_name(),"checks":checks,"failures":failures,"routes":route_results,"coverage":counts,"inputs":input_counts,"nodes":nodes_seen,"pages":pages_seen,"player_slots_accessed":false,"scope":"visible native window; synthetic GUI mouse/space/enter/auto; memory fixture; production location/departure/Sunday entry; live endings and gallery entry/early exit"}, "\t")); f.close()

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output = arg.trim_prefix("--out=")
	assert(not output.is_empty())
	DirAccess.make_dir_recursive_absolute(output)
	native = DisplayServer.get_name() != "headless"
	if not native: push_error("Visible native renderer required"); quit(2); return
	han.compile("[㐀-鿿]")
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/narumi_ren_native_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load language " + locale)
		app.configure_game_content()
		for id in EVENTS:
			for alternate in [0,1]:
				await play_event(id, locale, alternate)
				if failures: break
			if not failures:
				expect(coverage[locale + ":" + id].size() == app.game.character_event_definitions[id].nodes.size(), "Both native routes cover every authored node " + locale + ":" + id)
			if failures: break
		if failures: break
	expect(not FileAccess.file_exists(app.saves.path), "No test save file written")
	write_report()
	var f := FileAccess.open(output + "/observations.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(observations)); f.close()
	print("NARUMI_REN_NATIVE_DONE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
