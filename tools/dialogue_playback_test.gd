extends SceneTree

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func key_event(keycode: Key, echo: bool = false) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	event.echo = echo
	return event

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame

	var delay_by_speed: Array[float] = []
	for speed_index in range(4):
		app.dialogue_auto_speed_index = speed_index
		delay_by_speed.append(app.dialogue_auto_delay("这是一句包含停顿、并以问号结束的测试对白？"))
	expect(delay_by_speed[0] > delay_by_speed[1], "Slow auto-play was not slower than normal")
	expect(delay_by_speed[1] > delay_by_speed[2], "Normal auto-play was not slower than fast")
	expect(delay_by_speed[2] > delay_by_speed[3], "Fast auto-play was not slower than very fast")
	app.dialogue_auto_speed_index = 1
	expect(app.dialogue_auto_delay("较长的对白需要更多阅读时间。") > app.dialogue_auto_delay("短句。"), "Text length did not affect auto-play delay")
	expect(app.dialogue_auto_delay("【场景转换】") > app.dialogue_auto_delay("普通短句。"), "Scene heading did not receive an extra pause")

	app.start_story()
	await process_frame
	expect(app.page.get_node_or_null("DialogueAutoToggle") != null, "Prologue did not render the auto-play toggle")
	expect(app.page.get_node_or_null("DialogueAutoSpeed") != null, "Prologue did not render the speed control")
	var first_key := str(app.dialogue_page_key)
	var first_index := int(app.dialogue_page_index)
	app._unhandled_key_input(key_event(KEY_SPACE, true))
	expect(str(app.dialogue_page_key) == first_key and int(app.dialogue_page_index) == first_index, "Echoed key advanced dialogue")
	app._unhandled_key_input(key_event(KEY_SPACE))
	await process_frame
	expect(str(app.dialogue_page_key) != first_key or int(app.dialogue_page_index) != first_index, "Space did not activate the registered continuation")

	var trigger_counter := {"value": 0}
	app.base("Test", "Test")
	var test_button: Button = app.button_at("Continue", Vector2(20, 20), Vector2(160, 40), func(): trigger_counter.value += 1)
	app.register_dialogue_continue(test_button, "Test")
	app.dialogue_auto_enabled = true
	app.run_dialogue_auto_timer(app.dialogue_auto_generation, 0.01)
	await create_timer(0.05).timeout
	expect(int(trigger_counter.value) == 1, "Auto-play timer did not activate the registered continuation exactly once")

	app.base("Choice", "Choice")
	var choice_button: Button = app.button_at("Choice", Vector2(20, 20), Vector2(160, 40), func(): trigger_counter.value += 1)
	app.register_dialogue_continue(choice_button, "Choice")
	app.pause_dialogue_for_choice()
	app._unhandled_key_input(key_event(KEY_ENTER))
	expect(int(trigger_counter.value) == 1, "Enter selected a choice while dialogue was paused")

	print("dialogue_playback_test: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
