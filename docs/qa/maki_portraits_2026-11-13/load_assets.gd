extends SceneTree
func _initialize() -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://research/character_intake/doc_maki/ready_assets.json"))
	var count := 0
	for key in data.portraits:
		var texture = load("res://" + data.portraits[key])
		if not texture is Texture2D or texture.get_width() != 1024 or texture.get_height() != 1536:
			push_error("Invalid Maki texture: " + key)
			quit(1)
			return
		count += 1
	var cg = load("res://" + data.first_assignment_cg)
	if not cg is Texture2D or cg.get_width() != 1536 or cg.get_height() != 1024:
		quit(1)
		return
	print("PASS: ", count, " Maki sprites and 1 CG loaded; no game state/save access.")
	quit(0)
