extends SceneTree

const EVENT := "intro_rumi_shiori_hiroko_monday_0900"
const CAST := ["nurse_iwasaki_rumi", "nurse_yoneda_shiori"]
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
		var game = app.game
		game.reset()
		var definition: Dictionary = game.character_event_definitions[EVENT]
		expect(not game.character_event_available(definition), "Hiroko must be met")
		game.advance_story_to_day(7, 540) # Monday, April 7.
		game.meet_staff("nurse_hiroko")
		expect(game.rumi_shiori_introduction_day() == 14, "Meeting Monday schedules following Monday")
		expect(not game.character_event_available(definition), "Not same Monday")
		var pending_save: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
		expect(game.restore(pending_save), "Pending save restores")
		expect(game.rumi_shiori_introduction_day() == 14, "Fallback anchor survives save")
		game.advance_story_to_day(13, 900)
		expect(not game.character_event_available(definition), "Not before Monday")
		expect(not game.rumi_shiori_introduction_due(14, 539), "08:59 too early")
		expect(game.rumi_shiori_introduction_due(14, 540), "09:00 boundary")
		game.advance_story_to_day(14, 540)
		expect(game.character_event_available(definition), "Monday 09:00 available")
		expect(game.character_event_opening_node(definition) == "rs0_0001", "Original Monday opening")
		expect(game.character_events_at("ward").all(func(d): return d.id != EVENT), "Station only")
		expect(game.character_events_at("station").any(func(d): return d.id == EVENT), "Station entry discovers event")
		var higher: Dictionary = definition.duplicate(true)
		higher.id = "test_higher_priority_intro"
		higher.priority = 200
		game.character_event_definitions[higher.id] = higher
		expect(game.next_character_event_at("station").id != EVENT, "Higher priority event wins")
		game.character_event_definitions.erase(higher.id)
		game.advance_story_to_day(15, 600)
		expect(game.character_event_available(definition), "Missed Monday stays available")
		expect(game.character_event_opening_node(definition) == "rs0_0001_morning", "Deferred morning opening")
		game.advance_story_to_day(15, 780)
		expect(game.character_event_opening_node(definition) == "rs0_0001_later", "Deferred afternoon opening")
		var before: int = game.elapsed()
		var hiroko: Dictionary = game.relation_for("nurse_hiroko").duplicate(true)
		var xp: int = game.surgery_xp
		var leader: int = game.leadership_xp
		var event = game.start_character_event(EVENT)
		expect(event != null, "Starts event")
		expect(not game.can_save_progress(), "Episode lock prevents saving")
		for i in range(35):
			expect(not game.staff_is_met(CAST[0]) and not game.staff_is_met(CAST[1]), "Neither met before final continue")
			app.show_character_event()
			var node: Dictionary = event.current()
			expect(not str(node.text).is_empty(), "Node has localized text")
			expect(game.choose_character_event(str(node.choices[0].id)), "Advance " + str(i))
		expect(event.completed, "Completes after 35 text nodes")
		expect(game.elapsed() - before == 20, "Exactly 20 minutes")
		for actor in CAST:
			var relation: Dictionary = game.relation_for(actor)
			expect(relation.met and relation.level == 0, "Met at Lv0")
			expect(relation.affection == 0 and relation.familiarity == 0, "No extra reward")
			expect(not relation.flags.has("introduction_pending"), "Pending flag removed")
			expect(relation.event_history.count(EVENT) == 1, "Shared history exactly once")
			expect(game.staff_can_join_surgery_team(actor), "Team access at Lv0")
		expect(game.relation_for("nurse_hiroko") == hiroko, "Hiroko unchanged")
		expect(game.surgery_xp == xp and game.leadership_xp == leader, "No XP bonuses")
		expect(not game.choose_character_event("continue_0035"), "No repeated settlement")
		game.finish_character_event()
		expect(game.can_save_progress(), "Save unlocked after leaving event")
		expect(not game.character_event_available(definition), "No replay")
		var saved: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
		expect(game.restore(saved), "Completed save restores")
		for actor in CAST:
			expect(game.staff_is_met(actor), "Both met after restore")
		expect(not game.character_event_available(definition), "No replay after restore")
		# Legacy save with met=true but no introduction date/counter anchors on load.
		game.reset()
		game.advance_story_to_day(8, 600)
		game.relation_for("nurse_hiroko").met = true
		var legacy: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
		expect(game.restore(legacy), "Legacy met-only save loads")
		expect(game.character_progress_counter("nurse_hiroko", "joint_intro_anchor_day") == 8, "Fallback records first observed day")
		expect(game.rumi_shiori_introduction_day() == 14, "Legacy anchor next Monday")
		# A partial old state must not hide the event behind the primary actor's met bit.
		game.reset()
		game.meet_staff("nurse_hiroko")
		game.meet_staff(CAST[0])
		game.advance_story_to_day(8, 600)
		expect(game.character_event_available(definition), "One-sided legacy met state can finish joint intro")
		# A real recorded introduction date takes precedence over fallback observation date.
		var intro = load("res://godot/systems/character_event_session.gd").new(game.character_event_definitions["intro_nurse_hiroko"])
		intro.completed = true
		intro.completed_day = 7
		game.character_events["intro_nurse_hiroko"] = intro
		expect(game.rumi_shiori_introduction_day() == 14, "Actual completed date takes precedence")
	print("Joint introduction: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
