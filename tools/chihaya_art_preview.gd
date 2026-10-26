extends SceneTree

const PACK := "res://assets/characters/patient_chihaya_second_surgery_v1/"
const OUTPUT := "res://docs/qa/chihaya_second_surgery/"
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PACK + "manifest.json"))
	var assets: Array = manifest.get("assets", [])
	if assets.size() != 29:
		push_error("Expected 29 Chihaya VN assets")
		failures += 1
	for asset: Dictionary in assets:
		var texture := load("res://" + str(asset.path)) as Texture2D
		if texture == null:
			failures += 1
			push_error("Failed texture load: " + str(asset.key))
			continue
		var expected: Array = asset.size
		if texture.get_size() != Vector2(float(expected[0]), float(expected[1])):
			failures += 1
			push_error("Canvas mismatch: " + str(asset.key))
		if bool(asset.transparent) and texture.get_image().detect_alpha() == Image.ALPHA_NONE:
			failures += 1
			push_error("No alpha: " + str(asset.key))
	if DisplayServer.get_name() != "headless":
		root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
		root.content_scale_size = Vector2i.ZERO
		DirAccess.make_dir_recursive_absolute(OUTPUT)
		for group in ["ward", "postop", "intraoperative", "operating_table"]:
			var items: Array = assets.filter(func(a: Dictionary) -> bool: return str(a.key).begins_with(group + "/"))
			var cols: int = 4 if group == "ward" else 3
			var cell: Vector2i = Vector2i(360, 540) if group in ["ward", "postop"] else Vector2i(510, 375)
			var rows := ceili(float(items.size()) / cols)
			root.size = Vector2i(cols * cell.x, rows * cell.y)
			await process_frame
			var stage := Control.new()
			root.add_child(stage)
			for i in range(items.size()):
				var origin := Vector2((i % cols) * cell.x, (i / cols) * cell.y)
				for side in range(2):
					var bg := ColorRect.new()
					bg.position = origin + Vector2(side * cell.x / 2.0, 0)
					bg.size = Vector2(cell.x / 2.0, cell.y)
					bg.color = Color("dce6e7") if side == 0 else Color("183d43")
					stage.add_child(bg)
				var sprite := TextureRect.new()
				sprite.position = origin + Vector2(8, 35)
				sprite.size = Vector2(cell.x - 16, cell.y - 43)
				sprite.texture = load("res://" + str(items[i].path))
				sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				stage.add_child(sprite)
				var label := Label.new()
				label.text = str(items[i].key)
				label.position = origin + Vector2(10, 5)
				label.add_theme_color_override("font_color", Color("a04410"))
				stage.add_child(label)
			await process_frame
			await RenderingServer.frame_post_draw
			if root.get_texture().get_image().save_png(OUTPUT + group + ".png") != OK:
				failures += 1
			stage.queue_free()
			await process_frame
	print("Chihaya VN art: %d textures, %d failures" % [assets.size(), failures])
	quit(0 if failures == 0 else 1)
