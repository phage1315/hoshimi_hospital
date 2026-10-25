extends SceneTree
const EVENT = "intro_satsuki_new_nurse"
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
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Load "+locale)
		app.configure_game_content()
		var g=app.game
		g.reset()
		var d: Dictionary=g.character_event_definitions[EVENT]
		g.meet_staff("nurse_hiroko")
		g.meet_staff("doc_aqua")
		g.advance_story_to_day(7,540)
		expect(not g.character_event_available(d),"Week one blocked")
		g.advance_story_to_day(8,540)
		g.relation_for("doc_aqua").met=false
		expect(not g.character_event_available(d),"Aqua required")
		g.meet_staff("doc_aqua")
		g.relation_for("nurse_hiroko").met=false
		expect(not g.character_event_available(d),"Hiroko required")
		g.meet_staff("nurse_hiroko")
		expect(g.character_event_available(d),"Both at Lv0 suffice, no surgeries required")
		expect(g.completed_surgeries_total==0,"Zero surgeries")
		g.character_event_definitions={EVENT:d}
		expect(g.next_character_event_at("station").get("id","")==EVENT,"Station discovery")
		expect(g.next_character_event_at("ward").is_empty(),"Not ward")
		g.active_special_event_id="occupied"
		expect(not g.character_event_available(d),"Exclusive blocks")
		expect(g.start_character_event(EVENT)==null,"No interruption")
		g.active_special_event_id=""
		g.active_character_event_id="occupied"
		expect(not g.character_event_available(d),"Character scene blocks")
		g.active_character_event_id=""
		var higher: Dictionary=d.duplicate(true)
		higher.id="higher_intro"
		higher.priority=200
		g.character_event_definitions[higher.id]=higher
		expect(g.next_character_event_at("station").get("id","")==higher.id,"Priority respected")
		g.character_event_definitions.erase(higher.id)
		g.advance_story_to_day(15,540)
		expect(g.character_event_available(d),"No deadline")
		expect(g.restore(JSON.parse_string(JSON.stringify(g.snapshot()))),"Pending restore")
		var others := {}
		for actor in ["nurse_hiroko","doc_aqua"]:others[actor]=g.relation_for(actor).duplicate(true)
		var attrs: Dictionary=g.player_attributes().duplicate(true)
		var before: int=g.elapsed()
		var event=g.start_character_event(EVENT)
		expect(event!=null,"Starts")
		expect(not g.can_save_progress(),"No mid-event save")
		for i in range(40):
			expect(not g.staff_is_met("nurse_satsuki") and not g.story_flag("satsuki_lv0_complete"),"No premature settlement")
			app.show_character_event()
			var n: Dictionary=event.current()
			if i<39:
				expect(g.choose_character_event(str(n.choices[0].id)),"Advance")
			else:
				expect(n.expression=="surprised" and not n.hide_portrait,"Hold final shocked expression")
				app.choose_character_event(str(n.choices[0].id))
		expect(event.completed,"Completed")
		expect(g.active_character_event_id.is_empty(),"Returns directly without extra VN text")
		expect(g.elapsed()-before==20,"Exactly 20 minutes")
		var r: Dictionary=g.relation_for("nurse_satsuki")
		expect(r.met and r.level==0 and r.familiarity==0 and r.affection==0,"Lv0 without reward")
		expect(g.story_flag("satsuki_lv0_complete"),"Existing Lv1 flag written")
		expect(r.event_history.count(EVENT)==1,"One completion")
		for actor in others:expect(g.relation_for(actor)==others[actor],"Other actors unchanged")
		expect(g.player_attributes()==attrs and g.completed_surgeries_total==0,"No stats or surgery change")
		expect(g.can_save_progress(),"Save restored")
		expect(not g.character_event_available(d),"No replay")
		expect(g.restore(JSON.parse_string(JSON.stringify(g.snapshot()))),"Completed restore")
		expect(g.story_flag("satsuki_lv0_complete") and not g.character_event_available(d),"Flag persists; no replay")
		var lv1: Dictionary=g.special_event_definitions['satsuki_lv1_real_patient_test']
		expect(not g.special_event_base_requirements_met(lv1),"No instant Lv1 without familiarity")
		g.relation_for("nurse_satsuki").familiarity=10
		g.set_test_player_attribute("presence",30)
		expect(g.special_event_base_requirements_met(lv1),"Lv1 opens at original thresholds")
	print("SATSUKI INTRO: %s checks; %s failures" % [checks,failures])
	quit(1 if failures else 0)
