extends SceneTree

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for staff_id in ["doc_sayaka", "doc_shiori", "doc_aqua"]:
		var reward: Dictionary = app.game.staff_role_cg_reward_for(staff_id, "assistant_surgeon")
		expect(not reward.is_empty(), staff_id + ": assistant role CG record missing")
		if reward.is_empty():
			continue
		expect(FileAccess.file_exists("res://" + str(reward.path)), staff_id + ": assistant role CG file missing")
		expect(load("res://" + str(reward.path)) is Texture2D, staff_id + ": assistant role CG could not be loaded as a texture")
		var unlocked: Dictionary = app.game.unlock_staff_role_cg(staff_id, "assistant_surgeon")
		expect(str(unlocked.get("id", "")) == str(reward.id), staff_id + ": first assignment did not unlock the configured CG")
		expect(app.game.staff_role_cg_unlocked(str(reward.id)), staff_id + ": unlocked CG was not added to the gallery state")
		expect(app.game.unlock_staff_role_cg(staff_id, "assistant_surgeon").is_empty(), staff_id + ": repeat assignment unlocked the CG twice")
	print("role_cg_asset_test: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
