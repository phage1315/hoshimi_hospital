extends SceneTree
## Generates an isolated scheduling fixture, never overwriting player slots.
const App = preload("res://godot/scenes/main.tscn")
const Store = preload("res://godot/systems/save_store.gd")
const OUTPUT = "res://test_saves/sayaka_post_lv4_booking_2025-04-08_1600.json"

func _initialize() -> void:
	call_deferred("run")

func require_ok(value: bool, message: String) -> void:
	if not value:
		push_error(message)
		quit(1)
		assert(value, message)

func run() -> void:
	var app: Control = App.instantiate()
	root.add_child(app)
	await process_frame
	require_ok(app.game.prepare_sayaka_lv4_event_test(), "Cannot prepare prerequisites")
	require_ok(app.game._complete_character_event_for_test("sayaka_lv4_hotel_date", 6), "Cannot record completed Lv4")
	require_ok(app.game.settle_sayaka_lv4_hotel_event(), "Cannot settle Lv4 unlock")
	require_ok(app.game._complete_character_event_for_test("sayaka_lv4_hospital_callback", 7), "Cannot record completed callback")
	app.game.settle_sayaka_lv4_callback()
	app.game.advance_story_to_day(8, 16 * 60)
	require_ok(app.game.free_h_unlocked("doc_sayaka"), "Unlock gate failed")
	require_ok(app.game.can_book_free_h("doc_sayaka", "clinic"), "Invitation unavailable at clinic")
	require_ok(app.game.can_end_workday(), "Departure blocked")
	require_ok(app.game.free_h_booking.is_empty(), "Fixture already booked")
	var store := Store.new()
	store.path = OUTPUT
	require_ok(not store.exists(), "Refusing to overwrite existing test fixture")
	require_ok(store.write_slot(app.game), store.last_error)
	app.game.reset()
	require_ok(store.read_slot(app.game), store.last_error)
	require_ok(app.game.free_h_unlocked("doc_sayaka"), "Unlock lost on reload")
	require_ok(app.game.can_book_free_h("doc_sayaka", "clinic"), "Invitation lost on reload")
	require_ok(app.game.can_end_workday(), "Departure blocked after reload")
	require_ok(not app.game.story_flag("sayaka_lv4_next_morning_callback_pending"), "Callback still pending")
	print("SAVE_VERIFIED: ", ProjectSettings.globalize_path(OUTPUT))
	print("USER_DATA: ", OS.get_user_data_dir())
	print("STATE: ", app.game.calendar_iso(), " ", app.game.clock_text(), " / Lv", app.game.relation_for("doc_sayaka").level)
	app.queue_free()
	await process_frame
	quit(0)
