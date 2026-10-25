extends SceneTree
const EVENT = "intro_hikami_saeko_six_months"
const ACTOR = "nurse_hikami_saeko"
var checks := 0
var failures := 0
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
		var g = app.game
		g.reset()
		var d: Dictionary = g.character_event_definitions[EVENT]
		g.character_event_definitions = {EVENT:d}
		for day in [1, 154, 180, 181, 183]:
			g.advance_story_to_day(day, 540)
			expect(not g.character_event_available(d), "Not before six calendar months: " + str(day))
		g.advance_story_to_day(184, 540)
		expect(g.calendar_iso() == "2025-10-01", "Exact six-month boundary")
		expect(g.character_event_available(d), "Available at six months")
		expect(g.next_character_event_at("station").get("id", "") == EVENT, "Station discovery")
		expect(g.next_character_event_at("ward").is_empty(), "Not ward")
		expect(d.time_start == 540 and d.time_end == 1020, "Uses normal shift window")
		for field in ["active_special_event_id", "active_character_event_id", "active_micro_event_id", "active_preop_id"]:
			g.set(field, "occupied")
			expect(not g.character_event_available(d), "Busy: " + field)
			expect(g.start_character_event(EVENT) == null, "No interruption")
			g.set(field, "")
		var higher: Dictionary = d.duplicate(true)
		higher.id = "higher_intro"
		higher.priority = 200
		g.character_event_definitions[higher.id] = higher
		expect(g.next_character_event_at("station").get("id", "") == higher.id, "Higher priority first")
		g.character_event_definitions.erase(higher.id)
		g.advance_story_to_day(190, 540)
		expect(g.character_event_available(d), "No expiry after postponement")
		expect(g.restore(JSON.parse_string(JSON.stringify(g.snapshot()))), "Pending save restore")
		expect(not g.staff_is_met(ACTOR), "Pending remains unmet")
		var other: Dictionary = g.relation_for("nurse_hiroko").duplicate(true)
		var attrs: Dictionary = g.player_attributes().duplicate(true)
		var before: int = g.elapsed()
		var event = g.start_character_event(EVENT)
		expect(event != null, "Starts")
		expect(not g.can_save_progress(), "Mid-event saves blocked")
		for i in range(28):
			expect(not g.staff_is_met(ACTOR), "No premature meeting")
			app.show_character_event()
			var n: Dictionary = event.current()
			if i == 3 and "--capture" in OS.get_cmdline_user_args():
				await process_frame
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("res://docs/qa/saeko_registration/intro_%s.png" % locale)
			if i == 22:expect(n.text == ("「……」" if locale == "zh_CN" else "“...”"), "Silence preserved")
			if i < 27:expect(g.choose_character_event(str(n.choices[0].id)), "Advance")
			else:app.choose_character_event(str(n.choices[0].id))
		expect(event.completed and g.active_character_event_id.is_empty(), "Direct exit to station")
		expect(g.elapsed() - before == 15, "Exactly 15 minutes")
		var r: Dictionary = g.relation_for(ACTOR)
		expect(r.met and r.level == 0 and r.affection == 0 and r.familiarity == 0, "Meet at Lv0; no rewards")
		expect(r.event_history.count(EVENT) == 1, "Single completion")
		expect(g.relation_for("nurse_hiroko") == other and g.player_attributes() == attrs, "Others and stats unchanged")
		expect(not g.rank_ready(ACTOR), "Future ranks unavailable")
		expect(g.can_save_progress(), "Saving restored")
		expect(g.restore(JSON.parse_string(JSON.stringify(g.snapshot()))), "Completed restore")
		expect(g.staff_is_met(ACTOR) and not g.character_event_available(d), "No replay after load")
	print("SAEKO INTRO: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
