extends RefCounted
## Optional staging for the shared character-event renderer. Never persisted.

static func portraits(app, node: Dictionary) -> void:
	for item in node.get("event_portraits", []):
		var texture := load("res://" + str(item.path)) as Texture2D
		if texture == null:
			continue
		var art := TextureRect.new()
		art.name = "EventPortrait_" + str(item.id)
		art.texture = texture
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.size = Vector2(float(item.get("width", 390)), float(item.get("height", 390)))
		# `bottom` describes the visible, aspect-fitted artwork rather than the
		# TextureRect container.  Landscape dialogue avatars often live in a tall
		# staging rectangle; centering them without compensating for that vertical
		# letterbox leaves shoulders floating well above the dialogue frame.
		var source_size := Vector2(float(texture.get_width()), float(texture.get_height()))
		var fit_scale := minf(art.size.x / source_size.x, art.size.y / source_size.y)
		var fitted_height := source_size.y * fit_scale
		var lower_letterbox := maxf(0.0, (art.size.y - fitted_height) / 2.0)
		art.position = Vector2(float(item.x) - art.size.x / 2.0, float(item.get("bottom", 550)) - art.size.y + lower_letterbox)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		app.page.add_child(art)

static func present(app, node: Dictionary, advance: Callable) -> bool:
	if str(node.get("presentation", "")) == "choice":
		# Authored choice markers contain no spoken text or extra click page.
		# Use the same guarded rendering path for live events and gallery replay.
		app.pause_dialogue_for_choice()
		var replay: bool = str(app.screen) == "gallery_replay"
		for i in range(node.choices.size()):
			var c: Dictionary = node.choices[i]
			var button: Button = app.button_at(app.vn_choice_label(str(c.label), node.choices.size()), Vector2(60, app.vn_choice_y(node.choices.size(), i)), Vector2(1100, 54), advance.bind(str(c.id)))
			button.name = ("ReplayChoice_" if replay else "EventChoice_") + str(c.id)
		if replay:
			var exit_action: Callable = app.show_character_events.bind(app.gallery_replay_return_actor, app.character_event_return_location) if app.gallery_replay_is_test else app.show_gallery_entry.bind(app.gallery_replay_event.definition.id)
			app.button_at(app.tx("ui.gallery.exit_test", "退出测试") if app.gallery_replay_is_test else app.tx("ui.gallery.exit_replay", "退出回想"), Vector2(60, 713), Vector2(180, 40), exit_action)
		else:
			app.button_at(app.tx("ui.auto.cdee65fb906e", "读档"), Vector2(194, 713), Vector2(120, 40), app.request_load)
		app.add_dialogue_playback_controls()
		return true
	var stage := str(node.get("presentation", "")) == "stage"
	var effect := str(node.get("stage_effect", ""))
	var key := str(app.screen) + ":" + str(node.id)
	# Dialogue pagination rebuilds the page but must not repeat a sneeze flash
	# or collision. A new authored node (or replay) can play its effect again.
	if not stage and app.last_character_stage_key == key:
		effect = ""
	app.last_character_stage_key = key
	var owner_page: Control = app.page
	if effect in ["black", "flash", "dust"]:
		var overlay := ColorRect.new()
		overlay.name = "EventStageEffect"
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		overlay.color = Color.BLACK if effect == "black" else Color(1, 1, 1, 0.8 if effect == "flash" else 0.32)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		owner_page.add_child(overlay)
		if effect != "black":
			var fade := overlay.create_tween()
			fade.tween_property(overlay, "modulate:a", 0.0, 0.45 if effect == "flash" else 1.2)
	elif effect == "shake":
		# Move the visual layer only, never the dialogue or buttons.
		for child in owner_page.get_children():
			if child is TextureRect:
				var home_position: Vector2 = child.position
				var shake := child.create_tween()
				shake.tween_property(child, "position", home_position + Vector2(5, 0), 0.05)
				shake.tween_property(child, "position", home_position - Vector2(5, 0), 0.05)
				shake.tween_property(child, "position", home_position, 0.08)
	if stage:
		# A page-owned Timer dies with its page. Reloads, replay exits and a
		# rapid redraw cannot advance a different session via a stale callback.
		var timer := Timer.new()
		timer.name = "EventStageTimer"
		timer.one_shot = true
		timer.wait_time = float(node.get("auto_seconds", 0.2))
		owner_page.add_child(timer)
		timer.timeout.connect(func():
			if is_instance_valid(app) and app.page == owner_page and owner_page.is_inside_tree():
				advance.call(str(node.choices[0].id))
		)
		timer.start()
	return stage
