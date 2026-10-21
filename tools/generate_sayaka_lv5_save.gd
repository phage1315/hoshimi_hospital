extends SceneTree
## Generate and read back an isolated Part A entry save; never touch player slots.
const App = preload("res://godot/scenes/main.tscn")
const Store = preload("res://godot/systems/save_store.gd")
const OUTPUT := "res://test_saves/sayaka_lv5_part_a_ready.json"
const EVENT := "sayaka_lv5_part_a"

func _initialize() -> void:
	call_deferred("run")

func require_ok(value: bool, message: String) -> void:
	if not value:
		push_error(message)
		quit(1)
		assert(value, message)

func verify_entry(game: RefCounted) -> void:
	require_ok(game.can_save_progress(), "Entry must remain saveable")
	require_ok(game.can_end_workday(), "End-of-work entry is blocked")
	require_ok(str(game.next_after_work_special_event().get("id", "")) == EVENT, "Part A is not the next after-work event")
	require_ok(not game.special_event_in_progress(), "Do not save inside the event")
	require_ok(not game.special_event_done(EVENT), "Part A already completed")
	require_ok(not game.staff_patient_unlocked("doc_sayaka"), "Patient invitation unlocked before Part C")
	require_ok(not game.unresolved_admitted_patient_exists(), "Test entry contains an admitted patient")

func run() -> void:
	var app: Control = App.instantiate()
	root.add_child(app)
	await process_frame
	require_ok(app.content.load_all("zh_CN"), "Content load failed")
	app.configure_game_content()
	require_ok(app.game.prepare_special_event_test_save(EVENT, false), "Cannot prepare Lv5 prerequisites")
	app.game.set_test_time(app.game.day_number(), 16 * 60)
	verify_entry(app.game)
	var store := Store.new()
	store.path = OUTPUT
	require_ok(not store.exists(), "Fixture exists; refusing silent overwrite")
	require_ok(store.write_slot(app.game), store.last_error)
	app.game.reset()
	require_ok(store.read_slot(app.game), store.last_error)
	verify_entry(app.game)
	require_ok(app.game.start_special_event(EVENT) != null, "Part A cannot start after loading")
	print("SAVE_VERIFIED: ", ProjectSettings.globalize_path(OUTPUT))
	print("STATE: ", app.game.calendar_iso(), " ", app.game.clock_text(), " / Lv", app.game.relation_for("doc_sayaka").level)
	print("USER_DATA: ", OS.get_user_data_dir())
	app.queue_free()
	await process_frame
	quit(0)
