extends SceneTree

const Store = preload("res://godot/systems/save_store.gd")

class FakeState extends RefCounted:
	var value := 0
	var last_error := ""

	func can_save_progress() -> bool:
		return true

	func save_block_reason() -> String:
		return ""

	func snapshot() -> Dictionary:
		return {"value": value, "active_mode": "", "completed_surgeries_total": value}

	func restore(data: Variant) -> bool:
		if not data is Dictionary or not data.has("value"):
			last_error = "invalid"
			return false
		value = int(data.value)
		return true

	func day_number() -> int:
		return value + 1

	func calendar_compact_text() -> String:
		return "2025.04.%02d" % (value + 1)

	func clock_text() -> String:
		return "09:00"

	func current_patient_id() -> String:
		return "patient_test"

var failures := 0
var checks := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("Pass an isolated scratch save path after --")
		quit(1)
		return
	var store := Store.new()
	store.path = args[0]
	expect(store.slot_path(1) == args[0], "Slot 1 did not use the configured path")
	expect(store.slot_path(2).contains("_slot_2"), "Slot 2 path was not derived independently")
	var source := FakeState.new()
	source.value = 2
	expect(store.write_slot(source, 1), "Could not write slot 1")
	source.value = 7
	expect(store.write_slot(source, 2), "Could not write slot 2")
	expect(store.exists(1) and store.exists(2) and store.any_exists(), "Written slots were not discovered")
	var first_summary := store.slot_summary(1)
	var second_summary := store.slot_summary(2)
	expect(first_summary.valid and first_summary.day == 3 and first_summary.completed_surgeries == 2, "Slot 1 metadata is incorrect")
	expect(second_summary.valid and second_summary.day == 8 and second_summary.completed_surgeries == 7, "Slot 2 metadata is incorrect")
	var loaded := FakeState.new()
	expect(store.read_slot(loaded, 1) and loaded.value == 2, "Slot 1 round-trip failed")
	expect(store.read_slot(loaded, 2) and loaded.value == 7, "Slot 2 round-trip failed")
	expect(not store.exists(3) and not store.read_slot(loaded, 3), "Empty slot was readable")
	expect(not store.write_slot(source, 0) and not store.write_slot(source, 9), "Out-of-range slot was writable")
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.saves = store
	app.show_save_slots("save", false)
	for slot in range(1, Store.SLOT_COUNT + 1):
		expect(app.page.get_node_or_null("SaveSlot_%d" % slot) != null, "Save-slot UI omitted slot %d" % slot)
	app.queue_free()
	print("SAVE STORE: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures > 0 else 0)
