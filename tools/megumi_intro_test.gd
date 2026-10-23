extends SceneTree
const EVENT = "intro_kariya_megumi_june"
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
		var d: Dictionary = game.character_event_definitions[EVENT]
		game.advance_story_to_day(61, 540)
		game.meet_staff("nurse_ishigami")
		expect(not game.character_event_available(d), "Not before June 1")
		game.advance_story_to_day(62, 540)
		expect(game.calendar_iso()=="2025-06-01", "Calendar boundary")
		expect(game.character_event_available(d), "June 1 due")
		expect(game.next_day_start_character_event().is_empty(), "Sunday safely deferred")
		game.relation_for("nurse_ishigami").met=false
		game.advance_story_to_day(70, 540)
		expect(not game.character_event_available(d), "Wait for Ishigami even after due date")
		game.meet_staff("nurse_ishigami")
		expect(game.character_event_available(d), "Late unlock remains eligible")
		var saved: Dictionary=JSON.parse_string(JSON.stringify(game.snapshot()))
		expect(game.restore(saved), "Pending save restores")
		expect(game.character_event_available(d), "Pending event survives restore")
		game.active_special_event_id="exclusive_test"
		expect(not game.character_event_available(d), "Exclusive event blocks")
		expect(game.start_character_event(EVENT)==null, "Does not interrupt exclusive event")
		game.active_special_event_id=""
		game.active_character_event_id="other_test"
		expect(not game.character_event_available(d), "Other character scene blocks")
		game.active_character_event_id=""
		var definitions: Dictionary=game.character_event_definitions.duplicate(true)
		game.character_event_definitions={EVENT:d}
		expect(game.next_day_start_character_event().get("id","")==EVENT,"Safe day scheduler selects introduction")
		var higher: Dictionary=d.duplicate(true)
		higher.id="test_priority_intro"
		higher.priority=200
		game.character_event_definitions[higher.id]=higher
		expect(game.next_day_start_character_event().get("id","")==higher.id,"Higher priority scene first")
		game.character_event_definitions.erase(higher.id)
		game.consume_day_start_character_event()
		expect(game.next_day_start_character_event().is_empty(),"One day-start scene per day")
		game.advance_story_to_day(71,540)
		expect(game.next_day_start_character_event().get("id","")==EVENT,"Queued scene resumes next safe day")
		game.character_event_definitions=definitions
		var others := {}
		for actor in ["nurse_ishigami","nurse_hiroko","nurse_ange"]:
			others[actor]=game.relation_for(actor).duplicate(true)
		var attributes: Dictionary=game.player_attributes().duplicate(true)
		var before: int=game.elapsed()
		var event=game.start_character_event(EVENT)
		expect(event!=null,"Starts")
		expect(not game.can_save_progress(),"No mid-event save")
		for i in range(111):
			expect(not game.staff_is_met("nurse_kariya_megumi"),"No early settlement")
			app.show_character_event()
			var node: Dictionary=event.current()
			if i>=103:
				expect(app.page.get_node_or_null("CharacterPortrait")==null,"Offscreen voices have no portrait")
			expect(game.choose_character_event(str(node.choices[0].id)),"Advance")
		expect(event.completed,"Complete")
		expect(game.elapsed()-before==30,"Exactly 30 minutes")
		var r: Dictionary=game.relation_for("nurse_kariya_megumi")
		expect(r.met and r.level==0 and r.affection==0 and r.familiarity==0,"Only Lv0 introduction")
		expect(r.event_history.count(EVENT)==1,"Settled once")
		for actor in others:expect(game.relation_for(actor)==others[actor],"Other cast unchanged")
		expect(game.player_attributes()==attributes,"Player stats unchanged")
		game.finish_character_event()
		expect(game.can_save_progress(),"Save resumes")
		expect(not game.character_event_available(d),"No repeat")
		expect(game.restore(JSON.parse_string(JSON.stringify(game.snapshot()))),"Completed save restores")
		expect(not game.character_event_available(d),"No repeat after load")
	print("MEGUMI INTRO: %s checks; %s failures" % [checks,failures])
	quit(1 if failures else 0)
