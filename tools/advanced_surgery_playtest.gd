extends SceneTree
## Isolated manual test entry. Never reads or writes the player's save file.
func _initialize() -> void:
	call_deferred("open_board")

func open_board() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/tmp/hoshimi_advanced_manual_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	if "--en" in OS.get_cmdline_user_args():
		app.content.load_all("en")
		app.configure_game_content()
	app.show_advanced_referral(true)
