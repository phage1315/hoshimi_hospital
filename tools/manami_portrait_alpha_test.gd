extends SceneTree

const DIR := "res://assets/characters/portrait_pack_v10/pharmacist_manami/pharmacist/"
const NAMES := ["pharm_smile", "pharm_bright", "pharm_playful", "pharm_professional", "pharm_surprised", "pharm_thoughtful"]
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	await process_frame
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	root.size = Vector2i(1440, 600)
	var stage := Control.new()
	stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(stage)
	for i in range(NAMES.size()):
		var texture: Texture2D = load(DIR + NAMES[i] + ".png")
		check(texture != null, "Texture loads: " + NAMES[i])
		if texture == null:
			continue
		var pixels := texture.get_image()
		check(pixels.get_size() == Vector2i(1024, 1536), "Original canvas: " + NAMES[i])
		check(pixels.detect_alpha() != Image.ALPHA_NONE, "Real alpha: " + NAMES[i])
		for point in [Vector2i(0, 0), Vector2i(100, 500), Vector2i(900, 800), Vector2i(50, 1400)]:
			check(pixels.get_pixelv(point).a < 0.01, "Background transparent: %s %s" % [NAMES[i], point])
		for point in [Vector2i(500, 300), Vector2i(500, 800)]:
			check(pixels.get_pixelv(point).a > 0.98, "Character preserved: %s %s" % [NAMES[i], point])
		for side in range(2):
			var backdrop := ColorRect.new()
			backdrop.position = Vector2(i * 240 + side * 120, 0)
			backdrop.size = Vector2(120, 600)
			backdrop.color = Color("dce6e7") if side == 0 else Color("183d43")
			stage.add_child(backdrop)
		var sprite := TextureRect.new()
		sprite.position = Vector2(i * 240, 40)
		sprite.size = Vector2(240, 560)
		sprite.texture = texture
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stage.add_child(sprite)
		var label := Label.new()
		label.text = NAMES[i]
		label.position = Vector2(i * 240 + 8, 10)
		label.add_theme_color_override("font_color", Color("bf5e15"))
		stage.add_child(label)
	if DisplayServer.get_name() != "headless":
		await process_frame
		await RenderingServer.frame_post_draw
		DirAccess.make_dir_recursive_absolute("res://docs/qa/manami_alpha")
		check(root.get_texture().get_image().save_png("res://docs/qa/manami_alpha/render.png") == OK, "Save rendered alpha preview")
	print("Manami portrait alpha: six textures checked, %d failures" % failures)
	stage.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
