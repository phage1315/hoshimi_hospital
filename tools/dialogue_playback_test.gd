extends SceneTree

class IsolatedLocalization extends "res://godot/systems/localization.gd":
	var test_path := "/tmp/hoshimi_speed_%s_%s.cfg" % [OS.get_process_id(), Time.get_ticks_usec()]
	func save_dialogue_auto_speed(index: int, _path: String = SETTINGS_PATH) -> bool:
		return super.save_dialogue_auto_speed(index, test_path)
	func preferred_dialogue_auto_speed(_path: String = SETTINGS_PATH) -> int:
		return super.preferred_dialogue_auto_speed(test_path)

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
	var localizer := IsolatedLocalization.new()
	app.content.localizer = localizer
	expect(localizer.preferred_dialogue_auto_speed() == 1, "Missing preference keeps Normal default")
	for locale in ["zh_CN", "en"]:
		expect(localizer.load_locale(locale), "Load " + locale)
		var caption := "光速" if locale == "zh_CN" else "Light Speed"
		for text in ["", "短句。", "Wait, really?!", "【场景转换】", "A long passage. ".repeat(100), "很长的对白，带有停顿！".repeat(100)]:
			for extra in [0.0, 0.25, 2.0]:
				app.dialogue_auto_speed_index = 3
				var very_fast: float = app.dialogue_auto_delay(text, extra)
				app.dialogue_auto_speed_index = 4
				expect(is_equal_approx(app.dialogue_auto_delay(text, extra) * 4.0, very_fast), "Light Speed is exactly four times Very Fast, including pause/clamp")
		app.base("Speed", "Speed")
		app.add_dialogue_playback_controls()
		expect(app.dialogue_auto_speed_button.text.contains(caption), "Localized playback button")
		app.dialogue_auto_speed_index = 3
		app.cycle_dialogue_auto_speed()
		expect(app.dialogue_auto_speed_index == 4 and localizer.preferred_dialogue_auto_speed() == 4, "Very Fast cycles to saved Light Speed")
		preload("res://godot/ui/title_view.gd").settings(app)
		var dialog = app.get_node("TitleSettingsDialog")
		var setting = dialog.find_child("DialogueSpeedSetting", true, false)
		expect(setting.item_count == 5 and setting.selected == 4 and setting.get_item_text(4) == caption, "Settings shows five speeds and restores Light Speed")
		setting.select(2)
		setting.item_selected.emit(2)
		expect(app.dialogue_auto_speed_index == 2 and localizer.preferred_dialogue_auto_speed() == 2, "Settings selection persists")
		setting.select(4)
		setting.item_selected.emit(4)
		expect(app.dialogue_auto_speed_index == 4 and localizer.preferred_dialogue_auto_speed() == 4, "Settings can select Light Speed")
		dialog.queue_free()
		await process_frame
		app.cycle_dialogue_auto_speed()
		expect(app.dialogue_auto_speed_index == 0 and localizer.preferred_dialogue_auto_speed() == 0, "Light Speed wraps to Slow")
	for index in range(5):
		expect(localizer.save_dialogue_auto_speed(index) and localizer.preferred_dialogue_auto_speed() == index, "All old and new preference indices roundtrip")

	var delay_by_speed: Array[float] = []
	for speed_index in range(5):
		app.dialogue_auto_speed_index = speed_index
		delay_by_speed.append(app.dialogue_auto_delay("这是一句包含停顿、并以问号结束的测试对白？"))
	expect(delay_by_speed[0] > delay_by_speed[1], "Slow auto-play was not slower than normal")
	expect(delay_by_speed[1] > delay_by_speed[2], "Normal auto-play was not slower than fast")
	expect(delay_by_speed[2] > delay_by_speed[3], "Fast auto-play was not slower than very fast")
	expect(delay_by_speed[3] > delay_by_speed[4], "Very Fast remains slower than Light Speed")
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

	app.dialogue_auto_speed_index = 4
	app.base("Choice", "Choice")
	var choice_button: Button = app.button_at("Choice", Vector2(20, 20), Vector2(160, 40), func(): trigger_counter.value += 1)
	app.register_dialogue_continue(choice_button, "Choice")
	app.pause_dialogue_for_choice()
	app._unhandled_key_input(key_event(KEY_ENTER))
	expect(int(trigger_counter.value) == 1, "Enter selected a choice while dialogue was paused")
	app.dialogue_auto_speed_index = 4
	app.base("Light Speed", "Light Speed")
	var light_button: Button = app.button_at("Continue", Vector2(20, 20), Vector2(160, 40), func(): trigger_counter.value += 1)
	app.register_dialogue_continue(light_button, "")
	await create_timer(0.3).timeout
	expect(int(trigger_counter.value) == 2, "Light Speed actual timer advances exactly once")
	app.register_dialogue_continue(light_button, "")
	app.pause_dialogue_for_choice()
	await create_timer(0.3).timeout
	expect(int(trigger_counter.value) == 2, "Light Speed timer still stops for choices")
	app.dialogue_auto_enabled = false
	DirAccess.remove_absolute(localizer.test_path)
	app.queue_free()
	await process_frame

	print("dialogue_playback_test: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
