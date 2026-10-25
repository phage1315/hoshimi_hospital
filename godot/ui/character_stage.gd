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
		art.position = Vector2(float(item.x), float(item.get("bottom", 550))) - Vector2(art.size.x / 2.0, art.size.y)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		app.page.add_child(art)

static func present(app, node: Dictionary, advance: Callable) -> bool:
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
