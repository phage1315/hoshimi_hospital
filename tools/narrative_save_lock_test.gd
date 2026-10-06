extends SceneTree

const GameState = preload("res://godot/systems/game_state.gd")

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var game = GameState.new()
	expect(game.can_save_progress(), "Idle game unexpectedly blocked saving")
	game.active_character_event_id = "test_character_event"
	expect(not game.can_save_progress(), "Character event did not block saving")
	game.active_character_event_id = ""
	game.active_micro_event_id = "test_micro_event"
	expect(not game.can_save_progress(), "Micro event did not block saving")
	game.active_micro_event_id = ""
	game.active_special_event_id = "test_special_event"
	expect(not game.can_save_progress(), "Special event did not block saving")
	game.active_special_event_id = ""
	game.active_adult_intimacy = RefCounted.new()
	expect(not game.can_save_progress(), "Adult relationship event did not block saving")
	game.active_adult_intimacy = null
	expect(game.can_save_progress(), "Saving did not unlock after narrative sessions ended")
	print("NARRATIVE SAVE LOCK: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
