extends SceneTree

const EVENT := "manami_lv1_sneeze"
var failures := 0
var checks := 0

func expect(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(note)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		var game = app.game
		expect(game.prepare_character_event_test_save(EVENT), "Prepare safe-boundary fixture")
		var fixtures: Array = [game.snapshot()]
		# Optional real save is read only; never write to player slots.
		for path in OS.get_cmdline_user_args():
			var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
			expect(data is Dictionary, "Read supplied save")
			if data is Dictionary:
				fixtures.append(data)
		for snapshot in fixtures:
			expect(game.restore(snapshot), "Restore fixture")
			var before: Dictionary = game.snapshot()
			expect(game.next_character_event_at("or").get("id", "") == EVENT, "OR trigger available")
			expect(game.next_character_event_at("pharmacy").get("id", "") != EVENT, "Pharmacy is not the trigger")
			app.show_location("pharmacy")
			expect(game.active_character_event_id != EVENT, "Pharmacy UI does not start event")
			expect(game.restore(snapshot), "Restore before OR UI test")
			expect(game.snapshot() == before, "Time and persistent facts unchanged on restore")
			app.show_location("or")
			expect(game.active_character_event_id == EVENT, "OR UI starts event")
			expect(not game.can_save_progress(), "Event still blocks saving")
			game.reset()
	print("Manami Lv1 trigger: %d checks, %d failures" % [checks, failures])
	app.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
