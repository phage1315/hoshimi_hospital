extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const ButtonText = preload("res://godot/ui/button_text.gd")
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func has_han(value: String) -> bool:
	for index in value.length():
		var code := value.unicode_at(index)
		if code >= 0x3400 and code <= 0x9fff:
			return true
	return false

func compare_tree(source: Variant, translated: Variant, path: String) -> void:
	if source is Dictionary:
		expect(translated is Dictionary and source.keys() == translated.keys(), "Schema changed with locale: " + path)
		for key in source:
			compare_tree(source[key], translated[key], path + "." + str(key))
	elif source is Array:
		expect(translated is Array and source.size() == translated.size(), "Array changed with locale: " + path)
		for index in source.size():
			compare_tree(source[index], translated[index], path + "." + str(index))
	elif source is String and has_han(source):
		expect(not str(translated).is_empty() and not has_han(translated), "Runtime Chinese residue: " + path)
	elif source is String and path.get_slice(".", path.get_slice_count(".") - 1) in ["title", "label", "prompt", "response", "transition_text", "operative_record", "player_hint", "name"]:
		expect(not has_han(translated), "English-authored display text became Chinese: " + path)
	else:
		expect(source == translated, "Non-text data changed with locale: " + path)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var source = Loader.new()
	expect(source.load_all("zh_CN"), "Chinese loader failed")
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	expect(app.content.load_all("en"), "English loader failed")
	app.configure_game_content()
	app.show_map(false)
	compare_tree(source.collections.surgeries, app.content.collections.surgeries, "surgeries")
	for index in source.collections.awake_special_barks.size():
		compare_tree(source.collections.awake_special_barks[index].variants, app.content.collections.awake_special_barks[index].variants, "awake_barks.%s" % index)
	for surgery in app.content.collections.surgeries:
		for stage in surgery.get("stages", []):
			for option in stage.get("options", []):
				var button: Button = app.button_at(str(option.label), Vector2.ZERO, Vector2(655, 54), app.show_map)
				ButtonText.fit(button, Vector2(655, 54), 22)
				expect(button.size.x <= 655 and button.size.y <= 54, "Option enlarged hitbox: " + str(option.id))
				var rendered := button.get_theme_font("font").get_multiline_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, button.get_theme_font_size("font_size"))
				var usable := Vector2(655, 54) - button.get_theme_stylebox("normal").get_minimum_size()
				expect(rendered.x <= usable.x and rendered.y <= usable.y, "Option text overflows: " + str(option.id))
				expect(str(button.get_meta("caption_source")) == str(option.label), "Caption fitting changed source text")
				button.free()
	print("SURGERY ENGLISH RUNTIME: %s checks; %s failure(s)" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
