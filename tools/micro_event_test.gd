extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")

var content = Loader.new()
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func new_game() -> RefCounted:
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events)
	game.meet_staff("nurse_haru")
	game.meet_staff("nurse_yui")
	return game

func run() -> void:
	expect(content.load_all(), "Content load failed")
	expect(content.collections.micro_events.size() == 20, "Expected twenty micro events")
	var game = new_game()
	var event = game.select_micro_event("after_encounter", "clinic")
	expect(event != null, "Opening consultation did not produce an eligible micro event")
	if event == null:
		print("MICRO EVENTS: %s checks; %s failure(s)" % [checks, failures])
		quit(1)
		return
	expect(event.definition.id in ["haru_micro_patient_hands", "yui_micro_notebook_question"], "Wrong opening micro event selected")
	expect(game.active_mode == "micro_event" and not game.active_micro_event_id.is_empty(), "Selected micro event was not made active")
	expect(event.opening_lines().size() >= 3 and not event.at_choice(), "Micro event opening dialogue is missing")
	event.advance_opening()
	var opening_snapshot: Dictionary = game.snapshot()
	var opening_clone = new_game()
	expect(opening_clone.restore(JSON.parse_string(JSON.stringify(opening_snapshot))), "Opening dialogue save restore failed")
	expect(opening_clone.micro_events[event.definition.id].opening_index == event.opening_index, "Opening dialogue cursor was not restored")
	while not event.at_choice():
		event.advance_opening()
	var relation_before: Dictionary = game.relation_for(event.definition.actor_id).duplicate(true)
	var choice: Dictionary = event.definition.choices[0]
	expect(game.choose_micro_event(choice.id), "Micro event choice failed")
	expect(event.completed and event.choice_id == choice.id, "Micro event did not finish")
	expect(event.response_lines().size() >= 4 and not event.response_finished(), "Micro event response dialogue is missing")
	event.advance_response()
	var relation_after: Dictionary = game.relation_for(event.definition.actor_id)
	expect(relation_after.familiarity == relation_before.familiarity + int(choice.effects.get("familiarity", 0)), "Micro event familiarity progression missing")
	if choice.memory_tag != null:
		expect(relation_after.flags.has(choice.memory_tag), "Micro event memory tag missing")
	var snapshot: Dictionary = game.snapshot()
	var clone = new_game()
	expect(clone.restore(JSON.parse_string(JSON.stringify(snapshot))), "Micro event save restore failed")
	expect(clone.active_micro_event_id == game.active_micro_event_id and clone.micro_events[event.definition.id].response_index == event.response_index, "Micro event save replay differs")
	expect(clone.relation_for(event.definition.actor_id) == relation_after, "Micro event relationship effects were not replayed")
	game.finish_micro_event()
	expect(game.active_micro_event_id.is_empty() and game.active_mode == "encounter", "Micro event did not return to gameplay")
	expect(game.select_micro_event("after_encounter", "clinic") != null, "Second staff member could not trigger on the same day")
	expect(game.select_micro_event("after_encounter", "clinic") != null, "Active micro event was not stable across redraw")

	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.game.meet_staff("nurse_haru")
	app.game.meet_staff("nurse_yui")
	var ui_event = app.game.select_micro_event("after_encounter", "clinic")
	expect(ui_event != null, "UI game did not select a micro event")
	app.show_micro_event()
	var opening_continue: Button = app.page.get_node_or_null("MicroEventContinue")
	if opening_continue == null:
		opening_continue = app.page.get_node_or_null("MicroEventPageContinue")
	expect(opening_continue != null, "Micro event opening Continue button is missing")
	if opening_continue != null:
		expect(opening_continue.text == app.tx("ui.common.continue", "继续  ▷"), "Micro event still uses the legacy Continue label")
		expect(opening_continue.position.y == app.VN_SINGLE_ACTION_Y and opening_continue.size == Vector2(655, 54), "Micro event Continue button does not use the shared VN layout")
	var ui_guard := 0
	while ui_guard < 30:
		var choices_visible := false
		for child in app.page.get_children():
			if child is Button and child.name.begins_with("MicroEventChoice_"):
				choices_visible = true
				break
		if choices_visible:
			break
		var page_continue: Button = app.page.get_node_or_null("MicroEventPageContinue")
		var line_continue: Button = app.page.get_node_or_null("MicroEventContinue")
		var active_continue: Button = page_continue if page_continue != null else line_continue
		if active_continue == null:
			break
		active_continue.pressed.emit()
		ui_guard += 1
	var choice_count := 0
	for child in app.page.get_children():
		if child is Button and child.name.begins_with("MicroEventChoice_"):
			choice_count += 1
	expect(app.screen == "micro_event" and choice_count == ui_event.definition.choices.size() and app.page.get_node_or_null("CharacterPortrait") != null, "Micro event UI is incomplete")
	var ui_choice: Button = app.page.get_node_or_null("MicroEventChoice_" + str(ui_event.definition.choices[0].id))
	if ui_choice != null:
		expect(ui_choice.position.y == app.vn_choice_y(ui_event.definition.choices.size(), 0) and ui_choice.size == Vector2(655, 54), "Micro event choices do not use the shared VN layout")
		ui_choice.pressed.emit()
	expect(app.page.get_node_or_null("MicroEventContinue") != null or app.page.get_node_or_null("MicroEventPageContinue") != null, "Micro event response page missing")
	print("MICRO EVENTS: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
