extends SceneTree
const Flow = preload("res://godot/systems/serika_lv5.gd")
const Session = preload("res://godot/systems/character_event_session.gd")
var app
var checks := 0
var failures := 0
var rendered := 0
var pages_rendered := 0
var native := false
var captures := {}
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run")
func fixture() -> void:
	var g = app.game
	g.reset()
	for d in g.special_event_definitions.values(): d.developer_only = true; d.auto_schedule = false
	for d in g.character_event_definitions.values():
		if str(d.id) != Flow.ID: d.trigger_mode = "after_work"
	g.meet_staff(Flow.ACTOR); g.meet_staff("nurse_yui")
	var r: Dictionary = g.relation_for(Flow.ACTOR)
	r.level = 4; r.familiarity = 75; r.route = "romance"
	r.unlocked_benefits.append("unlock_intimacy_events")
	r.rank_history.append("serika_lv4_stay")
	g.special_event_completion_counts["serika_lv4_stay"] = 1
	g.set_test_time(g.day_number_for_date("2025-06-06"),540)
	g.special_event_completion_days["serika_lv4_stay"] = g.day_number()-3
	g.set_story_flag("staff_as_patient_program_authorized")
	g.set_test_player_attribute("skill",75); g.set_test_player_attribute("leadership",65)
	app.character_event_from_test = false; app.character_event_return_location = "imaging"
	app.dialogue_auto_enabled = false
func available() -> bool:
	return app.game.character_event_available(app.game.character_event_definitions[Flow.ID])
func gates() -> void:
	fixture();var g=app.game
	expect(available(),"All gates at exact thresholds / normal morning entry")
	g.set_story_flag("staff_as_patient_program_authorized",false)
	g.meet_staff("doc_sayaka");g.relation_for("doc_sayaka").level=5
	expect(not available() and g.start_character_event(Flow.ID)==null,"Sayaka Part B Lv5 alone is insufficient")
	g.set_story_flag("staff_as_patient_program_authorized")
	g.special_event_completion_counts.erase("serika_lv4_stay")
	expect(not available(),"Real Lv4 completion required")
	g.special_event_completion_counts["serika_lv4_stay"]=1
	g.relation_for(Flow.ACTOR).familiarity=74;expect(not available(),"Fam 74 rejected");g.relation_for(Flow.ACTOR).familiarity=75
	for attr in ["skill","leadership"]:
		var threshold: int=75 if attr=="skill" else 65
		g.set_test_player_attribute(attr,threshold-1);expect(not available(),attr+" threshold");g.set_test_player_attribute(attr,threshold)
	g.special_event_completion_days["serika_lv4_stay"]=g.day_number()-2;expect(not available(),"Existing three-day cooldown")
	g.special_event_completion_days["serika_lv4_stay"]=g.day_number()-3
	g.set_test_time(g.day_number(),961);expect(not available(),"Less than 60 minutes before workday end")
	g.set_test_time(g.day_number(),960);expect(available(),"Exactly 60 minutes left")
	g.set_test_time(g.day_number_for_date("2025-06-08"),540);expect(not available(),"Sunday blocked")
	g.set_test_time(g.day_number_for_date("2025-06-06"),540)
	g.active_micro_event_id="busy";expect(not available(),"Exclusive micro-event");g.active_micro_event_id=""
	g.active_preop_id="busy";expect(not available(),"Exclusive preop");g.active_preop_id=""
	var mandatory:Dictionary=g.character_event_definitions[Flow.ID].duplicate(true)
	mandatory.id="qa_mandatory_day_start";mandatory.trigger_mode="day_start";mandatory.category="contextual"
	g.character_event_definitions[mandatory.id]=mandatory
	expect(not available(),"Mandatory day-start has priority");g.character_event_definitions.erase(mandatory.id)
	expect(available() and not g.staff_patient_unlocked(Flow.ACTOR),"Ready to play but patient eligibility still locked")
func assert_no_inner(v: Variant) -> void:
	if v is Dictionary:
		for k in v:
			expect(k not in ["node_id","step_index","choices","last_choice","action_log","event_portraits"],"No persistent inner state: "+str(k))
			assert_no_inner(v[k])
	elif v is Array:
		for x in v:assert_no_inner(x)
func boundary() -> void:
	var g=app.game
	g.finish_character_event()
	var saved:Dictionary=g.snapshot()
	expect(not saved.is_empty(),"Boundary save permitted")
	assert_no_inner(saved)
	var clock:int=g.elapsed();var attrs:Dictionary=g.player_attributes().duplicate(true)
	var nodes:Array=g.character_event_definitions[Flow.ID].nodes
	g.character_event_definitions[Flow.ID].nodes=[];g.character_event_definitions[Flow.ID].minutes=777
	var path:="/private/tmp/serika_lv5_boundary_%s.json" % OS.get_process_id()
	var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(saved));f.close()
	expect(g.restore(JSON.parse_string(FileAccess.get_file_as_string(path))),"Restore without old nodes: "+g.last_error)
	expect(g.elapsed()==clock and g.player_attributes()==attrs and g.character_event_done(Flow.ID) and g.staff_patient_unlocked(Flow.ACTOR),"Settled minutes and qualification survive structure changes")
	g.character_event_definitions[Flow.ID].nodes=nodes;g.character_event_definitions[Flow.ID].minutes=60
	expect(g.restore(g.snapshot()) and g.elapsed()==clock,"Repeated save/read stable")
func logic_routes() -> void:
	for route in range(8):
		fixture();var g=app.game;var before:int=g.elapsed();var attrs:Dictionary=g.player_attributes().duplicate(true)
		var flags:Dictionary=g.story_flags.duplicate(true)
		var event=g.start_character_event(Flow.ID)
		expect(event!=null,"Route start "+str(route))
		if event==null:return
		var seen:Dictionary={};var spoken:=0;var branch:=0
		while not event.completed:
			var n:Dictionary=event.current();expect(not seen.has(n.id),"No repeated row "+str(n.id));seen[n.id]=true
			expect(g.relationship_level(Flow.ACTOR)==4 and not g.staff_patient_unlocked(Flow.ACTOR),"No early settlement "+str(n.id))
			expect(not g.can_save_progress() and g.snapshot().is_empty(),"No mid-event save")
			var idx:=0
			if n.presentation=="choice":idx=(route>>branch)&1;branch+=1
			else:spoken+=1
			expect(g.choose_character_event(n.choices[idx].id),"Advance "+str(n.id))
			expect(g.active_staff_patient.is_empty() and g.staff_patient_first_completion_days.is_empty() and g.preops.is_empty(),"No surgery/admission/first-operation fact")
		expect(spoken==205 and branch==3 and seen.size()==208,"Exact selected path size")
		expect(g.relationship_level(Flow.ACTOR)==5 and g.staff_patient_unlocked(Flow.ACTOR),"Final acknowledgment grants Lv5 and eligibility")
		expect(g.elapsed()==before+60 and g.player_attributes()==attrs and g.story_flags==flags,"Exactly 60 minutes and no stat/global flag rewards")
		expect(g.relation_for(Flow.ACTOR).familiarity==75 and g.relation_for(Flow.ACTOR).route=="romance" and g.relation_for(Flow.ACTOR).unlocked_benefits.size()==2,"Prior intimacy unchanged; only patient benefit added")
		expect(not g.choose_character_event(event.current().choices[0].id) and g.elapsed()==before+60,"Double completion rejected")
		boundary()
func capture(key: String) -> void:
	if not native or captures.has(key):return
	await RenderingServer.frame_post_draw
	var path:="res://docs/qa/serika_lv5/"+key+".png"
	root.get_texture().get_image().save_png(path);captures[key]=path
func play_ui(locale: String) -> void:
	fixture();var g=app.game
	g.set_story_flag("serika_imaging_present:%s" % g.day_number(),false)
	app.show_location("imaging")
	expect(g.active_character_event_id==Flow.ID,"Natural imaging entry independent of random presence")
	if g.active_character_event_id!=Flow.ID:return
	var e=g.character_events[Flow.ID];var before:int=g.elapsed()
	while not e.completed:
		var n:Dictionary=e.current()
		await process_frame
		if n.presentation=="choice":
			expect(app.page.get_node_or_null("CharacterEventDialogue")==null,"No choice marker dialogue")
			expect(app.dialogue_default_button==null,"Autoplay stops at choice")
			for c in n.choices:
				var button=app.page.get_node_or_null("EventChoice_"+str(c.id))
				expect(button!=null and str(button.get_meta("caption_source",button.text))==app.vn_choice_label(str(c.label),2),"Exact option text")
				if button:
					var bounds:Vector2=button.size-button.get_theme_stylebox("normal").get_minimum_size()
					var text_size:Vector2=button.get_theme_font("font").get_multiline_string_size(button.text,HORIZONTAL_ALIGNMENT_LEFT,-1,button.get_theme_font_size("font_size"))
					expect(text_size.x<=bounds.x and text_size.y<=bounds.y,"Choice text fits without clipping")

			await capture(locale+"_"+str(n.id))
			app.page.get_node("EventChoice_"+str(n.choices[0 if locale=="zh_CN" else 1].id)).pressed.emit()
			continue
		var pages:Array=app.authored_dialogue_pages(str(n.text))
		expect("".join(pages)==n.text,"Lossless page split "+str(n.id))
		for i in range(pages.size()):
			expect(app.current_dialogue_text()==str(pages[i]),"Rendered prose "+locale+str(n.id))
			var labels:Array=app.page.find_children("*","Label",true,false)
			expect(labels.any(func(l):return l.text==n.speaker_label),"Rendered exact speaker "+str(n.id))
			if n.has("event_portraits"):
				for art in n.event_portraits:
					var texture=app.page.get_node_or_null("EventPortrait_"+str(art.id))
					expect(texture!=null and texture.texture.resource_path=="res://"+str(art.path),"Cafe cast costume/expression")
			else:
				var texture=app.page.get_node_or_null("CharacterPortrait")
				var path:String=app.content.find_record("staff",Flow.ACTOR).visuals.portraits[str(n.outfit)+"/"+str(n.expression)]
				expect(texture!=null and texture.texture.resource_path=="res://"+path,"Serika exact costume/expression "+str(n.id))
			if n.id in ["s01_003","s01_025","s02_018","s03_030","s04_033","s04_072"]:await capture(locale+"_"+str(n.id))
			var button:Button=app.dialogue_default_button
			expect(button!=null,"Continue available")
			if button:button.pressed.emit()
			await process_frame
			pages_rendered+=1
		rendered+=1
	expect(g.elapsed()==before+60 and g.staff_patient_unlocked(Flow.ACTOR),"UI full event settles")
	expect(app.screen=="character_event_complete","Normal result screen")
	await capture(locale+"_complete")
	app.show_map(false);await process_frame
	expect(g.can_save_progress() and not available(),"Return to safe map, event cannot repeat")
	var snapshot:Dictionary=g.snapshot()
	app.gallery_replay_event=Session.new(g.character_event_definitions[Flow.ID]);app.gallery_replay_is_test=false
	# Replay the whole opposite path, exercising every choice-only UI without
	# touching GameState. Regular dialogue pages were verified in the live pass.
	var r=app.gallery_replay_event
	while not r.completed:
		var n:Dictionary=r.current()
		if n.presentation=="choice":
			app.show_gallery_replay();await process_frame
			expect(app.page.get_node_or_null("GalleryReplayDialogue")==null,"Replay choice has no fake text")
			app.page.get_node("ReplayChoice_"+str(n.choices[1].id)).pressed.emit()
		else:r.apply(n.choices[0].id)
	expect(g.snapshot()==snapshot,"Gallery replay has no persistent effects")
	app.gallery_replay_event=null
func run() -> void:
	native=OS.get_cmdline_user_args().has("--native")
	DirAccess.make_dir_recursive_absolute("res://docs/qa/serika_lv5")
	app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/private/tmp/serika_lv5_unused_%s.json" % OS.get_process_id()
	root.add_child(app);await process_frame
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Load "+locale);app.configure_game_content()
		gates();logic_routes()
		if failures:print("SERIKA LV5 STOP ",checks," / ",failures);quit(1);return
		await play_ui(locale)
		if failures:print("SERIKA LV5 STOP ",checks," / ",failures);quit(1);return
	expect(rendered==410 and pages_rendered>=410,"Both complete localized UI runs")
	var report={"checks":checks,"failures":failures,"rendered_prose":rendered,"rendered_pages":pages_rendered,"languages":["zh_CN","en"],"routes_per_language":8,"native":native,"captures":captures}
	var f=FileAccess.open("res://docs/qa/serika_lv5/"+("native" if native else "headless")+".json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
	print("SERIKA LV5 ",JSON.stringify(report));quit(1 if failures else 0)
