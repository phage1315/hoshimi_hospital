extends SceneTree
const Flow = preload("res://godot/systems/miyuki_lv2.gd")
const Event = preload("res://godot/systems/character_event_session.gd")
var app
var checks := 0
var failures := 0
var native := false
var seen := 0
var rows: Array = []
const QA := "res://docs/qa/miyuki_lv2/"
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run")
func setup(g) -> void:
	g.reset();app.screen="map";app.departure_interlude_resume=Callable()
	for d in g.special_event_definitions.values():
		if not Flow.owns(str(d.id)): d.developer_only=true;d.auto_schedule=false
	for d in g.character_event_definitions.values():
		if g.character_event_trigger_mode(d) in ["day_start","after_work"]:d.trigger_mode="location"
	g.meet_staff(Flow.ACTOR)
	var rel: Dictionary=g.relation_for(Flow.ACTOR)
	rel.level=1;rel.familiarity=25;rel.rank_history=[Flow.LV1]
	var previous=Event.new(g.character_event_definitions[Flow.LV1])
	previous.completed=true;previous.completed_day=18;previous.settled_minutes=0
	g.character_events[Flow.LV1]=previous;g.character_event_order.append(Flow.LV1)
	g.set_test_time(22,960) # Tuesday, three full calendar days after milestone.
func no_inner(v: Variant) -> void:
	if v is Dictionary:
		for key in v:
			expect(key not in ["node_id","step_index","choices","last_choice","action_log","active_special_event","departure_interlude_resume"],"No inner state "+str(key));no_inner(v[key])
	elif v is Array:
		for x in v:no_inner(x)
func roundtrip(g) -> void:
	var save: Dictionary=g.snapshot();expect(not save.is_empty(),"Safe boundary snapshot")
	no_inner(save)
	var path := "/private/tmp/miyuki_lv2_%s.json" % OS.get_process_id()
	var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(save));f.close()
	var elapsed: int=g.elapsed();var level: int=g.relationship_level(Flow.ACTOR)
	var original: Dictionary=g.special_event_step_definitions.duplicate(true)
	for id in [Flow.A,Flow.B]:g.special_event_step_definitions[id+"_main"].nodes=[]
	expect(g.restore(JSON.parse_string(FileAccess.get_file_as_string(path))),"Load independent of old nodes")
	expect(g.elapsed()==elapsed and g.relationship_level(Flow.ACTOR)==level,"No replay/time/level drift")
	g.special_event_step_definitions=original
	expect(g.restore(g.snapshot()) and g.elapsed()==elapsed,"Repeated save/load stable")
func complete(g,id: String) -> void:
	expect(g.start_special_event(id)!=null,"Start "+id)
	if g.active_special_event==null:return
	for i in range(300):
		if g.active_special_event.completed:break
		g.choose_special_event("continue")
	g.finish_special_event()
func gates(g) -> void:
	setup(g);expect(Flow.evening_ready(g,22),"Valid gate")
	g.relation_for(Flow.ACTOR).familiarity=24;expect(not Flow.evening_ready(g,22),"Fam24 blocked")
	g.relation_for(Flow.ACTOR).familiarity=25
	g.character_events[Flow.LV1].completed_day=20;expect(not Flow.evening_ready(g,22),"Two-day cooldown blocked")
	g.character_events[Flow.LV1].completed_day=19;expect(Flow.evening_ready(g,22),"Three-day cooldown allowed")
	g.character_events[Flow.LV1].completed=false;expect(not Flow.evening_ready(g,22),"Actual Lv1 completion required")
	setup(g);g.set_test_time(26,960);expect(str(g.calendar_date(26).weekday_id)=="sat" and not Flow.evening_ready(g,26),"Saturday blocked")
	setup(g)
	var forced: Dictionary=g.special_event_definitions[Flow.B].duplicate(true)
	forced.id="test_tomorrow_mandatory";forced.prerequisite_events=[];forced.relationship_rewards=[];forced.timing.trigger_day=23
	g.special_event_definitions[forced.id]=forced
	var before := JSON.stringify(g.snapshot())
	expect(not Flow.evening_ready(g,22),"Tomorrow mandatory story blocks A")
	expect(JSON.stringify(g.snapshot())==before,"Projection never mutates live state")
	g.special_event_definitions.erase(forced.id)
	setup(g);g.meet_staff("doc_aqua")
	expect(not g.after_work_candidates(22).has(Flow.ACTOR) and g.after_work_candidates(22).has("doc_aqua"),"Exclude Miyuki only, preserve other walk candidates")
	complete(g,Flow.A)
	expect(g.relationship_level(Flow.ACTOR)==1 and g.current_absolute_clock()==960 and Flow.booked_day(g)==23,"A zero time, no rank, stable next-day booking")
	g.set_test_time(23,540);roundtrip(g)
	expect(Flow.booked_day(g)==23,"Booked B survives load")
	g.relation_for(Flow.ACTOR).familiarity=0;g.relation_for(Flow.ACTOR).met=false
	expect(g.special_event_available(g.special_event_definitions[Flow.B]),"Booked B ignores changed gate/presence")
	complete(g,Flow.B)
	expect(g.current_absolute_clock()==780 and g.relationship_level(Flow.ACTOR)==2 and Flow.booked_day(g)==0,"B exactly four hours and rank2")
	expect(g.start_special_event(Flow.B)==null,"No B replay/reward duplication")
	roundtrip(g)
func departure_edges(g) -> void:
	# Exercise the real UI resume callback with another character's walk.
	setup(g);g.meet_staff("doc_aqua")
	for seed in range(1,200):
		g.campaign_seed=seed
		if g.after_work_roll(22,"normal","trigger")>=20:break
	app.request_end_workday()
	expect(g.active_special_event_id==Flow.A,"A precedes a real other-character walk")
	for i in range(197):app.choose_special_event("continue")
	expect(app.screen=="after_work_walk" and str(g.active_after_work_walk.get("actor_id",""))=="doc_aqua","Other-character walk survives A")
	app.choose_after_work_walk(false);app.complete_after_work_walk()
	expect(app.screen=="day_transition" and g.day_number()==23,"Walk returns to normal splash exactly once")
	app.continue_after_day_transition()
	expect(g.active_special_event_id==Flow.B,"B follows preserved walk")
	# Overtime has already moved the ledger to tomorrow; the scene still
	# belongs to yesterday, so A must reserve that next morning, not +2 days.
	setup(g);g.set_test_time(23,540);g.pending_day_exit_workday=22;g.pending_day_exit_clock=1080
	app.show_day_transition(app.show_map)
	expect(g.active_special_event_id==Flow.A and g.active_special_event.started_day==22,"Deferred overtime A belongs to departure day")
	for i in range(197):app.choose_special_event("continue")
	expect(g.day_number()==23 and Flow.booked_day(g)==23 and app.screen=="day_transition","Overtime A does not skip a second day")
	app.continue_after_day_transition()
	expect(g.active_special_event_id==Flow.B and g.current_absolute_clock()==540,"Overtime B auto-starts at09")
	setup(g);g.character_events[Flow.LV1].completed_day=20
	g.set_test_time(23,540);g.pending_day_exit_workday=22;g.pending_day_exit_clock=1080
	expect(not Flow.evening_ready(g,22),"Overtime cannot borrow tomorrow's third cooldown day")

func click(button: Button) -> void:
	expect(is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled,"Continue available")
	if not is_instance_valid(button):return
	button.emit_signal("pressed");await process_frame
func play(id: String,locale: String,gallery: bool=false) -> void:
	var count:=0
	var source: Array=rows.filter(func(r): return str(r.id).begins_with("a" if id==Flow.A else "b"))
	while count<300:
		while app.screen=="special_event_blackout":await process_frame
		var e=app.special_event_gallery_replay if gallery else app.game.active_special_event
		if e==null or e.completed or str(e.definition.id)!=id:break
		var n: Dictionary=e.current();var row: Dictionary=source[count]
		expect(n.id==row.id,"Source node order "+str(n.id))
		expect(str(n.get("actor_id",""))==str(row.actor_id),"Canonical source actor "+str(n.id))
		expect(str(n.text)==str(row.en if locale=="en" else row.text),"Complete localized source text "+str(n.id))
		if not gallery:
			expect(not app.game.can_save_progress() and app.game.snapshot().is_empty(),"Every node forbids save")
			expect(app.game.relationship_level(Flow.ACTOR)==1,"No early rank settlement")
			if id==Flow.B:expect(app.game.current_absolute_clock()==540,"Montage does not rewind clock")
		var pages: Array=app.authored_dialogue_pages(app.special_event_localized_text(e.current_step(),n))
		for p in range(pages.size()):
			await process_frame
			expect(app.current_dialogue_text()==str(pages[p]),"Actual dialogue page exact")
			expect(app.page.get_node_or_null("SceneBackground")!=null,"Loaded background")
			var sprites: Array=app.page.find_children("EventPortrait_*","TextureRect",true,false)
			expect(sprites.size()==n.event_portraits.size(),"No stale/borrowed portrait")
			for item in n.event_portraits:
				var sprite=app.page.get_node_or_null("EventPortrait_"+str(item.id))
				expect(sprite!=null and sprite.texture!=null and sprite.texture.resource_path=="res://"+str(item.path),"Correct loaded sprite "+str(n.id))
			var names: Array=[]
			for child in app.page.get_children():
				if child is Label and child.position==Vector2(82,558):names.append(child)
			expect(names.size()==1 and names[0].text==app.special_event_speaker(n,app.special_event_actor(n),str(e.current_step().id)),"Actual speaker nameplate")
			for label in app.page.find_children("*","RichTextLabel",true,false):
				if label.text==str(pages[p]):expect(label.get_content_height()<=label.size.y,"Text not clipped")
			if native and not gallery and p==0 and n.id in ["a2_002","a2_003","a2_020","a2_099","a2_154","b2_005","b2_022","b2_026","b2_045","b2_063","b2_067","b2_068","b2_072","b2_074","b2_076"]:
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(QA+locale+"_"+str(n.id)+".png")
			if failures:print("STOP AT ",n.id);quit(1);return
			await click(app.dialogue_default_button)
		count+=1;seen+=1
	expect(count==source.size(),"Every source node played "+id)
func run() -> void:
	native=DisplayServer.get_name()!="headless";DirAccess.make_dir_recursive_absolute(QA)
	rows=JSON.parse_string(FileAccess.get_file_as_string("res://docs/source/miyuki_lv2/bilingual_review.json"))
	app=load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/private/tmp/miyuki_lv2_unused_%s.json" % OS.get_process_id()
	root.add_child(app);await process_frame;app.dialogue_auto_enabled=false
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Content loaded "+locale);app.configure_game_content()
		var g=app.game;gates(g);departure_edges(g)
		if failures:quit(1);return
		setup(g);var attrs: Dictionary=g.player_attributes().duplicate(true)
		app.request_end_workday();expect(g.active_special_event_id==Flow.A,"Manual end-workday starts A before splash")
		await play(Flow.A,locale)
		expect(g.relationship_level(Flow.ACTOR)==1 and not g.special_event_done(Flow.B),"A ends independently")
		expect(app.screen=="day_transition" and g.day_number()==23,"Normal day-end splash after A")
		app.continue_after_day_transition();expect(g.active_special_event_id==Flow.B and g.current_absolute_clock()==540,"Morning UI automatically starts B")
		await play(Flow.B,locale)
		while app.screen=="special_event_blackout":await process_frame
		expect(app.screen=="map" and g.current_absolute_clock()==780 and g.relationship_level(Flow.ACTOR)==2,"13:00 map and Lv2")
		expect(g.player_attributes()==attrs and g.completed_surgeries_total==0 and g.active_preop_id.is_empty() and not g.active_surgery_in_progress(),"No clinical runner/XP/case rewards")
		roundtrip(g)
		var before: int=g.elapsed()
		for id in [Flow.A,Flow.B]:
			app.replay_special_gallery_entry(id);await play(id,locale,true)
			expect(g.elapsed()==before and g.relationship_level(Flow.ACTOR)==2 and int(g.special_event_completion_counts[id])==1,"Gallery leaves settled facts unchanged")
		app.special_event_gallery_replay=null
	var report: Dictionary={"checks":checks,"failures":failures,"nodes_rendered":seen,"native":native,"languages":["zh_CN","en"]}
	var f=FileAccess.open(QA+("native" if native else "headless")+".json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
	print("MIYUKI LV2 TEST ",JSON.stringify(report));quit(1 if failures else 0)
