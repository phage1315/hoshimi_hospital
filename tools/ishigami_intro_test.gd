extends SceneTree
const EVENT = "intro_ishigami_nurse_manager"
const NURSES = ["nurse_rin","nurse_yui","nurse_ange","nurse_hiroko","nurse_moe","nurse_satsuki"]
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
		expect(app.content.load_all(locale),"Load "+locale)
		app.configure_game_content()
		var game = app.game
		game.reset()
		var d: Dictionary=game.character_event_definitions[EVENT]
		game.meet_staff("doc_asuka")
		for actor in NURSES:game.meet_staff(actor)
		game.advance_story_to_day(7,540)
		expect(not game.character_event_available(d),"Day 7 blocked")
		game.advance_story_to_day(8,540)
		expect(game.character_event_available(d),"Day 8 with six Lv0 nurses and Asuka")
		expect(not game.staff_is_met("nurse_haru"),"Ren need not be met")
		game.relation_for(NURSES[5]).met=false
		game.meet_staff("visiting_maya")
		game.meet_staff("visiting_futaba")
		expect(not game.character_event_available(d),"Five nurses plus visitors do not count as six")
		game.meet_staff(NURSES[5])
		game.relation_for("doc_asuka").met=false
		game.meet_staff("nurse_iwasaki_rumi")
		expect(not game.character_event_available(d),"Seven nurses without Asuka blocked")
		game.advance_story_to_day(70,540)
		game.meet_staff("doc_asuka")
		expect(game.character_event_available(d),"Late Asuka at Lv0 unlocks; no deadline")
		game.relation_for("nurse_iwasaki_rumi").met=false
		game.relation_for(NURSES[5]).met=false
		game.meet_staff("nurse_sonoda_itsumi")
		expect(game.character_event_available(d),"Registered ordinary nurse added later counts")
		expect(game.restore(JSON.parse_string(JSON.stringify(game.snapshot()))),"Pending save restores")
		expect(game.character_event_available(d),"Pending gate persists")
		game.active_special_event_id="occupied"
		expect(not game.character_event_available(d),"Exclusive scene blocks")
		expect(game.start_character_event(EVENT)==null,"No interruption")
		game.active_special_event_id=""
		game.active_character_event_id="occupied"
		expect(not game.character_event_available(d),"Other character scene blocks")
		game.active_character_event_id=""
		var definitions: Dictionary=game.character_event_definitions.duplicate(true)
		game.character_event_definitions={EVENT:d}
		expect(game.next_day_start_character_event().get("id","")==EVENT,"Automatic safe scheduler")
		var higher: Dictionary=d.duplicate(true)
		higher.id="test_higher_intro"
		higher.priority=200
		game.character_event_definitions[higher.id]=higher
		expect(game.next_day_start_character_event().get("id","")==higher.id,"Higher priority first")
		game.character_event_definitions.erase(higher.id)
		game.consume_day_start_character_event()
		expect(game.next_day_start_character_event().is_empty(),"No duplicate day-start enqueue")
		game.advance_story_to_day(71,540)
		expect(game.next_day_start_character_event().get("id","")==EVENT,"Deferred next safe morning")
		game.character_event_definitions=definitions
		var megumi: Dictionary=game.character_event_definitions['intro_kariya_megumi_june']
		expect(not game.character_event_available(megumi),"Megumi waits for Ishigami")
		var others := {}
		for actor in ["nurse_haru","doc_asuka","nurse_hiroko"]:others[actor]=game.relation_for(actor).duplicate(true)
		var attrs: Dictionary=game.player_attributes().duplicate(true)
		var surgeries: int=game.completed_surgeries_total
		var before: int=game.elapsed()
		var event=game.start_character_event(EVENT)
		expect(event!=null,"Start")
		expect(not game.can_save_progress(),"No mid-event save")
		for i in range(64):
			expect(not game.staff_is_met("nurse_ishigami"),"No early met")
			app.show_character_event()
			var node: Dictionary=event.current()
			if str(node.id)=="ishi0_064":expect(app.page.get_node_or_null("CharacterPortrait")==null,"Portrait removed on exit")
			expect(game.choose_character_event(str(node.choices[0].id)),"Advance")
		expect(event.completed,"Complete")
		expect(game.elapsed()-before==20,"20 minutes only")
		var r: Dictionary=game.relation_for("nurse_ishigami")
		expect(r.met and r.level==0 and r.affection==0 and r.familiarity==0,"Lv0 only, no rewards")
		expect(r.event_history.count(EVENT)==1,"One completion")
		expect(r.flags.has("professional_trust_route"),"Professional trust retained")
		for actor in others:expect(game.relation_for(actor)==others[actor],"Other cast unchanged")
		expect(game.player_attributes()==attrs and game.completed_surgeries_total==surgeries,"No stat or surgery changes")
		game.finish_character_event()
		expect(game.can_save_progress(),"Save resumes")
		expect(game.character_event_available(megumi),"Ishigami completion releases Megumi gate")
		expect(not game.character_event_available(d),"No repeat")
		expect(game.restore(JSON.parse_string(JSON.stringify(game.snapshot()))),"Completed save restores")
		expect(not game.character_event_available(d),"No repeat after load")
	print("ISHIGAMI INTRO: %s checks; %s failures" % [checks,failures])
	quit(1 if failures else 0)
