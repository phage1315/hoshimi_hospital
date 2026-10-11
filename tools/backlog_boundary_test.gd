extends SceneTree

class CompletedEvent extends RefCounted:
	var completed := true
	var definition := {"minutes": 0}

var checks := 0
var failures := 0
var stale_page_called := false

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func old_completion_page() -> void:
	stale_page_called = true

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		app.content.localizer.load_locale(locale)
		for day in [2, 6]:
			app.game.reset()
			app.game.set_test_time(day, 540)
			app.game.character_events["backlog_completed"] = CompletedEvent.new()
			app.game.active_character_event_id = "backlog_completed"
			app.character_event_return_location = "mido_office"
			app.day_transition_next = old_completion_page
			stale_page_called = false
			app.continue_after_day_transition()
			expect(not stale_page_called, "Next day called yesterday's completion page")
			expect(app.screen == ("sunday_menu" if day == 6 else "map"), "Wrong next-day landing page: " + app.screen)
			expect(app.game.active_character_event_id.is_empty(), "Completed event kept the save boundary locked")
			expect(app.character_event_return_location.is_empty(), "Old return location survived day entry")
			expect(not app.day_transition_next.is_valid(), "Day transition retained its callable")
	app.screen = "or_table_palpation"
	app.refresh_or_table_tool_cursor()
	app.screen = "map"
	app.clear_or_table_scalpel_cursor()
	await process_frame
	expect(not is_instance_valid(app.or_table_virtual_cursor), "Stale deferred refresh restored the cursor after exit")
	expect(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "System cursor remained hidden after exit")
	expect(app.content.load_all("en"), "English content failed to load")
	app.configure_game_content()
	app.game.reset()
	var profile_text = load("res://godot/ui/player_profile_text.gd")
	var xp_record := {"id": "leadership_surgery_appendix_1", "surgery_id": "surgery_appendix", "xp": 0.5, "effects": {"leadership": 0}, "label": "开腹阑尾切除 · 领导经验 +0.5"}
	expect(profile_text.history_label(app, xp_record) == "Open Appendectomy · Leadership XP +0.5", "Saved Chinese leadership history did not resolve in English")
	expect(profile_text.tier(app, "平衡型") == "Balanced", "Clinical-presence tier was not translated")
	expect(xp_record.label == "开腹阑尾切除 · 领导经验 +0.5", "Presentation mutated the saved source label")
	expect(profile_text.history_label(app, {"id": "surgery_reputation_surgery_appendix_2", "label": "阑尾切除 · 简单术式声望 +2", "effects": {"reputation": 2}}).begins_with("Open Appendectomy"), "Legacy reputation history did not resolve its stable surgery ID")
	expect(profile_text.history_label(app, {"id": "character_choice_charm", "label": "角色事件选择 · 魅力"}) == app.tx("ui.profile.history.character_charm", ""), "Character-choice history retained Chinese")
	app.game.leadership_xp_history.append(xp_record)
	app.show_player_profile()
	await process_frame
	var xp = app.page.get_node_or_null("SurgeryXPProgress")
	expect(xp != null and xp.position.x + xp.size.x < 705, "Surgical XP overlaps the history panel")
	expect(app.page.get_node_or_null("PlayerProfileHistory") != null, "Profile history has no bounded scrolling container")
	print("BACKLOG BOUNDARIES: %s checks; %s failure(s)" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
