extends SceneTree
const Flow = preload("res://godot/systems/miyuki_lv3.gd")
const Event = preload("res://godot/systems/character_event_session.gd")
var app
var checks := 0
var failures := 0
var seen := 0
var rows: Array = []
var native := false
const QA := "res://docs/qa/miyuki_lv3/"
func expect(ok: bool, message: String) -> void:
	checks+=1
	if not ok: failures+=1;push_error(message)
func _initialize() -> void: call_deferred("run")
func setup(g) -> void:
	g.reset();app.screen="map"
	for d in g.special_event_definitions.values():d.developer_only=true;d.auto_schedule=false
	for d in g.character_event_definitions.values():
		if not Flow.owns(str(d.id)) and g.character_event_trigger_mode(d) in ["day_start","after_work"]:d.trigger_mode="location"
	g.meet_staff(Flow.ACTOR);g.meet_staff("doc_serika")
	g.relation_for(Flow.ACTOR).level=2;g.relation_for(Flow.ACTOR).familiarity=40
	g.relation_for(Flow.ACTOR).rank_history=[Flow.LV2]
	g.special_event_completion_counts[Flow.LV2]=1;g.special_event_completion_days[Flow.LV2]=19
	g.set_test_character_progress_counter(Flow.ACTOR,"outpatient_forced_undress",5)
	g.set_test_time(22,960)
func no_inner(v: Variant) -> void:
	if v is Dictionary:
		for key in v:
			expect(key not in ["node_id","step_index","choices","last_choice","action_log","event_portraits"],"No persisted inner state "+str(key));no_inner(v[key])
	elif v is Array:
		for x in v:no_inner(x)
func roundtrip(g) -> void:
	var save: Dictionary=g.snapshot();expect(not save.is_empty(),"Safe boundary save")
	no_inner(save)
	var path: String="/private/tmp/miyuki_lv3_%s.json" % OS.get_process_id()
	var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(save));f.close()
	var elapsed: int=g.elapsed();var rank: int=g.relationship_level(Flow.ACTOR)
	var pending: bool=Flow.pending_date(g)
	var original: Dictionary=g.character_event_definitions.duplicate(true)
	for id in [Flow.A_KARIYA,Flow.A_SHIORI,Flow.B]:g.character_event_definitions[id].nodes=[]
	expect(g.restore(JSON.parse_string(FileAccess.get_file_as_string(path))),"Restore independent of node structure")
	expect(g.elapsed()==elapsed and g.relationship_level(Flow.ACTOR)==rank and Flow.pending_date(g)==pending,"No time/rank/pending drift")
	g.character_event_definitions=original
	expect(g.restore(g.snapshot()) and g.elapsed()==elapsed,"Repeated roundtrip stable")
func gate_tests(g) -> void:
	setup(g);expect(Flow.prelude_requirements(g),"A valid underlying gate")
	expect(Flow.next_prelude(g)==Flow.A_SHIORI,"Before internship uses Shiori")
	g.relation_for(Flow.ACTOR).level=1;expect(not Flow.prelude_requirements(g),"Lv1 blocked")
	g.relation_for(Flow.ACTOR).level=2;g.special_event_completion_counts[Flow.LV2]=0
	expect(not Flow.prelude_requirements(g),"Real Lv2 required")
	g.special_event_completion_counts[Flow.LV2]=1;g.relation_for(Flow.ACTOR).familiarity=39
	expect(not Flow.prelude_requirements(g),"Fam39 blocked")
	g.relation_for(Flow.ACTOR).familiarity=40;g.set_test_character_progress_counter(Flow.ACTOR,"outpatient_forced_undress",4)
	expect(not Flow.prelude_requirements(g),"Four interactions blocked")
	g.set_test_character_progress_counter(Flow.ACTOR,"outpatient_forced_undress",5)
	g.relation_for("doc_serika").met=false;expect(not Flow.prelude_requirements(g),"Serika not met blocked")
	g.meet_staff("doc_serika");expect(g.relationship_level("doc_serika")==0 and Flow.prelude_requirements(g),"Serika Lv0 sufficient")
	g.special_event_completion_days[Flow.LV2]=20;expect(not Flow.prelude_requirements(g),"Two day cooldown blocked")
	g.special_event_completion_days[Flow.LV2]=19
	g.active_micro_event_id="busy";expect(not Flow.prelude_requirements(g),"No exclusive interruption")
	g.active_micro_event_id=""
	for day in [22,23,24,25,26,27,28]:
		g.set_test_time(day,550);expect(Flow.prelude_requirements(g),"No additional weekday/time gate")
	setup(g)
	var e=Event.new(g.character_event_definitions[Flow.A_SHIORI]);e.completed=true;e.completed_day=27;e.settled_minutes=0
	g.character_events[Flow.A_SHIORI]=e;g.character_event_order.append(Flow.A_SHIORI)
	g.set_test_time(27,540)
	expect(not Flow.eligible(g,Flow.B),"A completed on Sunday cannot chain into B that same Sunday")
	g.set_test_time(34,540)
	expect(Flow.eligible(g,Flow.B),"Following Sunday enables B")
	g.complete_sunday_activity("rest")
	expect(Flow.pending_date(g) and g.relationship_level(Flow.ACTOR)==2,"Skipping a Sunday preserves B")
	g.set_test_time(41,540)
	expect(Flow.eligible(g,Flow.B),"A later Sunday still enables B")
	setup(g)
func casting_tests(g) -> void:
	for date in ["2025-05-31", "2025-06-01", "2025-11-30", "2025-12-01", "2026-01-01"]:
		for met in [false, true]:
			setup(g)
			g.set_test_time(g.day_number_for_date(date), 550)
			if met:g.meet_staff("nurse_kariya_megumi")
			var expected: String=Flow.A_KARIYA if met and date in ["2025-06-01", "2025-11-30"] else Flow.A_SHIORI
			expect(Flow.next_prelude(g)==expected,"Calendar/met casting boundary "+date+str(met))
			var other: String=Flow.A_SHIORI if expected==Flow.A_KARIYA else Flow.A_KARIYA
			expect(g.start_character_event(other)==null,"Reject incorrect cast entrance")
			g.active_micro_event_id="busy"
			expect(not app.begin_miyuki_lv3_prelude(),"Busy UI cannot start automatic A")
			g.active_micro_event_id=""
			if met:app.show_map(false)
			else:app.show_location("station")
			expect(g.active_character_event_id==expected,"Real map/location automatic entry "+date)
			expect(g.staff_is_met("nurse_kariya_megumi")==met and not g.staff_is_met("nurse_yoneda_shiori"),"Casting does not change staff membership")
			# The active event remains the selected cast even if eligibility changes.
			g.relation_for("nurse_kariya_megumi").met=not met
			g.set_test_time(g.day_number_for_date("2025-12-01"),550)
			app.show_map(false)
			expect(g.active_character_event_id==expected,"Active A cast remains fixed")
	setup(g)
func click(button: Button) -> void:
	expect(is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled,"Continue available")
	if not is_instance_valid(button):return
	if native:
		var point: Vector2=button.get_global_rect().get_center()
		var motion:=InputEventMouseMotion.new();motion.position=point;motion.global_position=point
		root.push_input(motion,true)
		for pressed in [true,false]:
			var event:=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=pressed
			event.position=point;event.global_position=point;root.push_input(event,true)
		# Keep press/release in one frame so native pointer motion cannot cancel the synthetic click.
		await process_frame
		await process_frame
	else:
		button.emit_signal("pressed");await process_frame
func play(id: String,locale: String,gallery: bool=false) -> void:
	var source: Array=rows.filter(func(r):return str(r.event_id)==id)
	var count:=0
	while count<300:
		var e=app.gallery_replay_event if gallery else app.game.character_events.get(app.game.active_character_event_id)
		if e==null or e.completed or str(e.definition.id)!=id:break
		var n: Dictionary=e.current();var row: Dictionary=source[count]
		expect(n.id==row.id and str(n.text)==str(row.en if locale=="en" else row.zh_CN),"Exact ordered localized node: actual="+str(n.id)+" expected="+str(row.id)+" locale="+locale+" gallery="+str(gallery))
		if not gallery:
			expect(not app.game.can_save_progress() and app.game.snapshot().is_empty(),"Every live node forbids save")
			expect(app.game.relationship_level(Flow.ACTOR)==2,"No early rank3")
		var pages: Array=app.authored_dialogue_pages(str(n.text))
		for p in range(pages.size()):
			await process_frame
			expect(app.current_dialogue_text()==str(pages[p]),"Actual dialogue page exact")
			var sprites: Array=app.page.find_children("EventPortrait_*","TextureRect",true,false)
			expect(sprites.size()==n.event_portraits.size(),"No stale or borrowed sprite")
			for item in n.event_portraits:
				var sprite=app.page.get_node_or_null("EventPortrait_"+str(item.id))
				expect(sprite!=null and sprite.texture!=null and sprite.texture.resource_path=="res://"+str(item.path),"Loaded correct sprite "+str(n.id))
			var expected_name: String=str(row.speaker_en if locale=="en" else row.speaker_zh_CN)
			var name=app.page.get_node_or_null("CharacterEventDialogueSpeaker") if not gallery else null
			var labels: Array=app.page.find_children("*","Label",true,false)
			expect(labels.any(func(l):return l.text==expected_name),"Rendered exact speaker name "+str(n.id))
			for label in app.page.find_children("*","RichTextLabel",true,false):
				if label.text==str(pages[p]):expect(label.get_content_height()<=label.size.y,"Text fits dialogue box")
			var bg=app.page.get_node_or_null("SceneBackground")
			expect(bg!=null and bg.texture!=null and bg.texture.resource_path=="res://"+app.background_path(str(n.background_id)),"Correct background loaded")
			if native and not gallery and p==0 and n.id in ["a3_003","a3_024","a3_046","a3_068","a3_076","b3_011","b3_038","b3_105","b3_158","b3_196","b3_232","b3_246"]:
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(QA+locale+"_"+id+"_"+str(n.id)+".png")
			if failures:print("STOP AT ",id," ",n.id);quit(1);return
			await click(app.dialogue_default_button)
		count+=1;seen+=1
	expect(count==source.size(),"All nodes played "+id)
func run() -> void:
	native=DisplayServer.get_name()!="headless";DirAccess.make_dir_recursive_absolute(QA)
	rows=JSON.parse_string(FileAccess.get_file_as_string("res://docs/source/miyuki_lv3/bilingual_review.json"))
	app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/private/tmp/miyuki_lv3_unused_%s.json" % OS.get_process_id()
	root.add_child(app);await process_frame;app.dialogue_auto_enabled=false
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Load bilingual content");app.configure_game_content()
		var g=app.game;gate_tests(g);casting_tests(g)
		if failures:quit(1);return
		for id in [Flow.A_KARIYA,Flow.A_SHIORI]:
			setup(g)
			g.set_test_time(g.day_number_for_date("2025-06-02"),960)
			if id==Flow.A_KARIYA:g.meet_staff("nurse_kariya_megumi")
			var start_time: int=g.elapsed();var attrs: Dictionary=g.player_attributes().duplicate(true)
			var next_sunday: int=g.day_number()+1
			while str(g.calendar_date(next_sunday).weekday_id)!="sun":next_sunday+=1
			app.show_map(false)
			expect(g.active_character_event_id==id,"Full run enters A through real automatic map entry")
			await play(id,locale)
			if failures:return
			expect(g.character_event_done(id) and Flow.pending_date(g) and g.relationship_level(Flow.ACTOR)==2,"A complete, B pending, no rank")
			expect(g.elapsed()==start_time and not g.staff_is_met("nurse_yoneda_shiori") and g.player_attributes()==attrs,"No A cost or cameo unlock/reward")
			expect(not Flow.eligible(g,Flow.B),"Same day not Sunday")
			roundtrip(g)
			app.replay_gallery_entry(id);await play(id,locale,true);app.gallery_replay_event=null
			g.set_test_time(next_sunday,540);app.screen="sunday_menu"
			expect(Flow.eligible(g,Flow.B),"Later Sunday B ready")
			g.relation_for("doc_serika").met=false
			var before: int=g.elapsed();app.attempt_sunday_invitation(Flow.ACTOR)
			expect(not g.sunday_activity_done() and g.elapsed()==before and Flow.pending_date(g) and not g.can_start_regular_sunday_date(Flow.ACTOR),"Unmet Serika preserves Sunday and pending")
			for dialog in app.find_children("*","AcceptDialog",true,false):
				dialog.hide();dialog.queue_free()
			g.meet_staff("doc_serika");g.relation_for(Flow.ACTOR).familiarity=0
			expect(g.character_event_available(g.character_event_definitions[Flow.B]),"B does not reapply A familiarity threshold")
			g.relation_for(Flow.ACTOR).familiarity=40
			app.show_sunday_invites();app.attempt_sunday_invitation(Flow.ACTOR)
			expect(g.active_character_event_id==Flow.B,"Existing Sunday invitation replaces regular date")
			var counters: Dictionary=g.character_progress_counters.duplicate(true)
			await play(Flow.B,locale)
			if failures:return
			expect(g.day_number()==next_sunday+1 and g.current_absolute_clock()==540 and g.relationship_level(Flow.ACTOR)==3 and not Flow.pending_date(g),"B settles once to Monday09 and Lv3")
			expect(g.familiarity_gain_multiplier(Flow.ACTOR)==0.75 and g.relation_for(Flow.ACTOR).route=="colleague","Multiplier0.75, no romance")
			expect(g.character_progress_counters==counters and g.relation_for(Flow.ACTOR).familiarity==40 and g.player_attributes()==attrs,"No generic date/counter/skill rewards")
			expect(g.completed_surgeries_total==0 and not g.active_surgery_in_progress(),"No surgery runner")
			expect(g.start_character_event(Flow.B)==null,"No repeat B")
			g.active_mode="encounter";roundtrip(g)
			before=g.elapsed();app.replay_gallery_entry(Flow.B);await play(Flow.B,locale,true);app.gallery_replay_event=null
			expect(g.elapsed()==before and g.relationship_level(Flow.ACTOR)==3,"Gallery no settlement")
			if failures:quit(1);return
	var report={"checks":checks,"failures":failures,"nodes_rendered":seen,"native":native,"languages":["zh_CN","en"],"automatic_A_entry":"verified real map/location entry; met Kariya June1-Nov30, otherwise Shiori; no global dismissal"}
	var f=FileAccess.open(QA+("native" if native else "headless")+".json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
	print("MIYUKI LV3 TEST ",JSON.stringify(report));quit(1 if failures else 0)
