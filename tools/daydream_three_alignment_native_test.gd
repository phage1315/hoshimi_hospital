extends "res://tools/miyuki_lv3_retest.gd"
## Reuses the existing native mouse driver. QA observations are not save data.
const Catalog = preload("res://godot/systems/daydream_catalog.gd")
var TARGET := ""
var target_filter := ""
var output := ""
var results: Array = []
var problems: Array = []
func check(ok: bool, message: String) -> void:
	expect(ok, message)
	if not ok: problems.append(message)
func button(name: String) -> Button:
	return app.page.find_child(name, true, false) as Button
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(output + "/" + name + ".png") == OK, "Screenshot " + name)
func enter_story() -> void:
	await click(button("OfficeDaydream"))
	check(app.screen == "daydream_catalog", "Office GUI opens catalog")
	if app.daydream_view.maximum != 2:
		await click(button("DaydreamLevel_2"))
		await click(button("DaydreamAcceptDark"))
	var entry_button := button("DaydreamEntry_" + TARGET)
	if entry_button != null:
		var ancestor = entry_button.get_parent()
		while ancestor != null and not ancestor is ScrollContainer: ancestor = ancestor.get_parent()
		if ancestor != null: ancestor.ensure_control_visible(entry_button)
		await process_frame
	await click(entry_button)
	check(app.screen == "daydream_confirm", "Per-event confirmation")
	await click(button("DaydreamBegin"))
	check(app.screen == "daydream_playback", "GUI starts story")
func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output = arg.trim_prefix("--out=")
		if arg.begins_with("--target="): target_filter = arg.trim_prefix("--target=")
	assert(not output.is_empty())
	DirAccess.make_dir_recursive_absolute(output)
	native = DisplayServer.get_name() != "headless"
	check(native, "Native renderer required")
	if not native: quit(1); return
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/chihaya_native_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	app.dialogue_auto_enabled = false
	for locale in ["zh_CN", "en"]:
		for target_entry in Catalog.entries():
			TARGET=str(target_entry.id)
			if not target_filter.is_empty() and TARGET != target_filter:
				continue
			check(app.content.load_all(locale), "Load " + locale)
			app.configure_game_content()
			app.game.reset()
			var entry: Dictionary = {}
			for candidate in Catalog.entries():
				if candidate.id == TARGET: entry = candidate
			check(not Catalog.unlocked(entry, app.game), "Fresh state gate locked")
			for actor in entry.gate.met:
				app.game.meet_staff(actor)
			check(Catalog.unlocked(entry, app.game), "Acquaintance at Lv0 meets real gate")
			var before_time: int = app.game.elapsed()
			var before_relations: Dictionary = app.game.relationships.duplicate(true)
			app.show_player_office()
			await process_frame
			await enter_story()
			var visited := 0
			var rendered_pages := 0
			while app.screen == "daydream_playback" and rendered_pages < 400:
				var session = app.daydream_view.session
				var node: Dictionary = session.current()
				var source: Dictionary = entry.nodes[visited]
				check(node.id == source.id, "Ordered node " + str(node.id))
				var pages: Array = app.authored_dialogue_pages(str(node.text))
				for page_index in range(pages.size()):
					await process_frame
					var body = app.page.get_node_or_null("DaydreamDialogue")
					var speaker = null
					for label in app.page.find_children("*", "Label", true, false):
						if label.position == Vector2(82, 558): speaker = label
					check(body != null and body.text == str(pages[page_index]), "Displayed page " + str(node.id))
					check(body != null and not str(body.text).contains("### "), "No Markdown act heading in dialogue " + str(node.id))
					check(speaker != null and speaker.text == str(node.speaker_label), "Displayed speaker " + str(node.id))
					check(not app.game.can_save_progress(), "Playback save blocked")
					if body != null: check(body.get_content_height() <= body.size.y or body.scroll_active, "Text fits " + str(node.id))
					var visuals: Array = []
					for texture in app.page.find_children("*", "TextureRect", true, false):
						visuals.append({"name": str(texture.name), "path": texture.texture.resource_path if texture.texture else "", "rect": str(texture.get_global_rect())})
					var has_cg := not str(node.get("cg_path", "")).is_empty()
					if has_cg:
						var displayed_cg := app.page.get_node_or_null("CharacterEventCG") as TextureRect
						check(displayed_cg != null and displayed_cg.texture != null and displayed_cg.texture.resource_path == "res://" + str(node.cg_path), "Explicit CG loaded " + str(node.id))
					if not has_cg and node.has("portrait_path") and node.actor_id not in ["narrator", "player"]:
						var portrait = app.page.get_node_or_null("CharacterEventPortrait")
						check(portrait != null and portrait.texture.resource_path == "res://" + str(node.portrait_path), "Explicit portrait loaded " + str(node.id))
					if not has_cg and node.actor_id not in ["narrator", "player"]:
						var actor: Dictionary = app.content.find_record("staff", str(node.actor_id))
						var resolved_path := str(node.get("portrait_path", ""))
						if resolved_path.is_empty() and not actor.is_empty():
							var outfit := str(node.get("outfit", actor.get("visuals", {}).get("default_outfit", "")))
							var portraits: Dictionary = actor.get("visuals", {}).get("portraits", {})
							resolved_path = str(portraits.get(outfit + "/" + str(node.expression), portraits.get(outfit + "/neutral", "")))
						var displayed: TextureRect = app.page.get_node_or_null("CharacterEventPortrait")
						if displayed == null: displayed = app.page.get_node_or_null("CharacterPortrait")
						check(displayed != null and displayed.texture != null and displayed.texture.resource_path == "res://" + resolved_path, "Speaking character has own loaded portrait " + str(node.id))
						check("patient_chihaya_second_surgery_v1/" not in resolved_path or node.actor_id == "patient_chihaya", "Chihaya art never assigned to another actor " + str(node.id))
					if node.actor_id in ["narrator", "player"]:
						check(app.page.get_node_or_null("CharacterEventPortrait") == null and app.page.get_node_or_null("CharacterPortrait") == null, "No borrowed portrait " + str(node.id))
					await shot(locale + "_" + TARGET + "_" + str(node.id) + "_" + str(page_index))
					results.append({"event":TARGET,"locale": locale, "actor":node.actor_id,"expression":node.get("expression","neutral"),"requested_sprite":node.get("sprite_key",""),"requested_cg":node.get("cg_key",""), "node": node.id, "page": page_index, "speaker": speaker.text if speaker else "", "visuals": visuals, "english_source_fallback": locale == "en" and source.text.en == source.text.zh_CN})
					await process_frame
					if rendered_pages == 0:
						var old_text: String=app.current_dialogue_text()
						await click(app.dialogue_auto_toggle_button)
						var deadline: int=Time.get_ticks_msec()+15000
						while app.current_dialogue_text()==old_text and Time.get_ticks_msec()<deadline:await process_frame
						check(app.current_dialogue_text()!=old_text,"Auto advances")
						await click(app.dialogue_auto_toggle_button)
						input_counts.auto+=1
					elif rendered_pages % 3 == 0:
						await click(app.dialogue_default_button)
						input_counts.mouse += 1
					else:
						app.dialogue_default_button.grab_focus()
						var code := KEY_SPACE if rendered_pages % 3 == 1 else KEY_ENTER
						for down in [true, false]:
							var event := InputEventKey.new()
							event.keycode = code; event.pressed = down
							root.push_input(event, true)
						await process_frame
						await process_frame
						input_counts["space" if code == KEY_SPACE else "enter"] += 1
					rendered_pages += 1
					if page_index + 1 < pages.size():
						check(app.daydream_view.session != null and app.daydream_view.session.current().id == node.id and app.current_dialogue_text() == str(pages[page_index + 1]), "Single page advance")
					elif visited + 1 < entry.nodes.size():
						check(app.daydream_view.session != null and app.daydream_view.session.current().id == entry.nodes[visited + 1].id, "Single node advance")
					if failures: break
				visited += 1
				if failures: break
			check(visited == entry.nodes.size(), "All authored nodes played " + locale)
			check(app.screen == "player_office", "Completion returns office")
			check(app.game.daydream_read_ids == [TARGET], "Stable read fact only")
			check(app.game.elapsed() == before_time and app.game.relationships == before_relations, "No time or relationship change")
			await shot(locale + "_return")
			if failures: break
			await enter_story()
			await click(button("DaydreamExit"))
			check(app.screen == "player_office" and app.game.daydream_read_ids == [TARGET], "Repeat entry and early exit")
	var scope := "Three stories" if target_filter.is_empty() else "Target story " + target_filter
	var report := {"native": native, "checks": checks, "failures": failures, "problems": problems, "inputs": input_counts, "pages": results.size(), "scope": scope + "; isolated real gates; office GUI full playback; English source fallback; independent source audit separate", "observations": results}
	var file := FileAccess.open(output + "/native.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t")); file.close()
	print("THREE DAYDREAMS checks=", checks, " failures=", failures, " pages=", results.size())
	quit(1 if failures else 0)
