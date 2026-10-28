extends SceneTree
const Flow = preload("res://godot/systems/chihaya_third_surgery.gd")
const Event = preload("res://godot/systems/character_event_session.gd")
const Replay = preload("res://godot/systems/special_event_session.gd")
const INTRO := "intro_rumi_shiori_hiroko_monday_0900"
const QA := "res://docs/qa/chihaya_third_surgery/cg_approved/"
var checks := 0
var failures := 0
var pages_seen := 0
var sources := {}
var approved_cgs := {}
var actors := {"千早":"patient_chihaya","瑞穗":"guest_mizuho","芹香":"doc_serika","阿库娅":"doc_aqua","明日香":"doc_asuka","七濑恋":"nurse_haru","留美":"nurse_iwasaki_rumi","安琪":"nurse_ange","弘子":"nurse_hiroko"}
var native := false

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func complete(g, id: String, day: int) -> void:
	var event = Event.new(g.character_event_definitions[id])
	event.completed = true
	event.completed_day = day
	event.settled_minutes = 0
	g.character_events[id] = event
	if not g.character_event_order.has(id): g.character_event_order.append(id)

func setup(g, second_surgery_day: int = 57, day: int = 98) -> void:
	g.reset()
	g.meet_staff(Flow.ACTOR)
	g.relation_for(Flow.ACTOR).level = 1
	g.relation_for(Flow.ACTOR).familiarity = 25
	complete(g, Flow.Radiology.LV1, 70)
	g.relation_for(Flow.ACTOR).rank_history.append(Flow.Radiology.LV1)
	g.set_test_player_attribute("skill",60)
	for i in range(3):
		var id: String = [Flow.Second.A, Flow.Second.B, Flow.Second.C][i]
		g.special_event_completion_counts[id] = 1
		g.special_event_completion_days[id] = second_surgery_day + i - 1
	for definition in g.special_event_definitions.values():
		if not Flow.owns(str(definition.id)): definition.developer_only = true
	for definition in g.character_event_definitions.values():
		if g.character_event_trigger_mode(definition) == "day_start": definition.trigger_mode = "location"
	g.set_test_time(day,540)

func no_inner(v: Variant) -> void:
	if v is Dictionary:
		for key in v:
			expect(key not in ["node_id","choices","last_choice","step_index","action_log","rank_slots","active_special_event"],"No persistent event internals: "+str(key))
			no_inner(v[key])
	elif v is Array:
		for x in v: no_inner(x)

func activate(button: Button) -> void:
	# Existing CG presentation holds Continue for one second. Exercise it as-is.
	if is_instance_valid(button) and not button.is_visible_in_tree():
		await create_timer(1.05).timeout
	expect(is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled,"Real continue control usable")
	if not is_instance_valid(button): return
	if native:
		var point := button.get_global_rect().get_center()
		var move := InputEventMouseMotion.new()
		move.position = point; move.global_position = point
		root.push_input(move,true)
		for pressed in [true,false]:
			var input := InputEventMouseButton.new()
			input.button_index = MOUSE_BUTTON_LEFT; input.pressed = pressed
			input.position = point; input.global_position = point
			root.push_input(input,true)
			await process_frame
	else:
		button.emit_signal("pressed")
		await process_frame

func cast_check(app, node: Dictionary, locale: String, step_id: String) -> void:
	var source: Dictionary = sources[str(node.id)]
	var who := str(source.speaker).get_slice("（",0)
	var actor := str(actors.get(who,""))
	expect(str(node.get("actor_id",""))==actor,"Canonical actor from original signature: "+str(node.id))
	if not actor.is_empty():
		expect(app.special_event_actor(node).get("id","")==actor,"Resolved actor object, including cameo")
	var portraits: Array = app.page.find_children("EventPortrait_*","TextureRect",true,false)
	var expected_cg: Dictionary = approved_cgs.get(str(node.id),{})
	var has_cg := not expected_cg.is_empty()
	var cg = app.page.get_node_or_null("CharacterEventCG")
	expect((cg!=null)==has_cg,"CG entry/exit in live and gallery: "+str(node.id))
	if has_cg and cg!=null:
		expect(cg.is_visible_in_tree() and cg.texture!=null and cg.texture.resource_path=="res://"+str(expected_cg.cg_path),"Exact approved CG texture loaded")
		expect(cg.stretch_mode==TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"CG kept whole, not cropped")
		expect(portraits.is_empty(),"No portrait overlays on CG")
	expect(portraits.size()==(0 if actor.is_empty() or has_cg else 1),"One matching portrait or POV; no stale cast: "+str(node.id))
	for item in ([] if has_cg else node.event_portraits):
		var shown = app.page.get_node_or_null("EventPortrait_"+actor)
		expect(shown!=null and shown.is_visible_in_tree(),"Speaker portrait visible: "+actor)
		if shown!=null:
			expect(shown.texture!=null and shown.texture.resource_path=="res://"+str(item.path),"Exact texture/outfit/expression loaded")
			expect(str(item.id)==actor,"Staged identity matches source")
	var expected: String = app.special_event_speaker(node,app.special_event_actor(node),step_id)
	var labels: Array = []
	for child in app.page.get_children():
		if child is Label and child.position==Vector2(82,558): labels.append(child)
	expect(labels.size()==1 and labels[0].text==expected,"Actual nameplate agrees with source actor: "+str(node.id))
	if actor=="nurse_iwasaki_rumi" and not app.game.character_event_done(INTRO):
		expect(expected.begins_with("OR Duty Nurse" if locale=="en" else "手术室值班护士"),"Formal intro, not numeric met, controls anonymity")
	if actor=="doc_serika": expect(node.outfit==("white_coat" if str(node.id).begins_with("a02") else "scrubs"),"Serika never sterile")
	if actor=="doc_serika" and str(node.id).begins_with("b"):
		expect(str(node.expression) in ["masked_focused","masked_warm","masked_hesitant","masked_tense"],"All OR/after-OR dialogue uses approved masked expressions")
		var art = app.page.get_node_or_null("EventPortrait_doc_serika")
		if not has_cg: expect(art!=null and art.texture.resource_path.contains("/scrubs_masked_v1/"),"Actual masked sprite loaded in live/replay")
		var beats := {"b03_004":"masked_focused","b05_011":"masked_hesitant","b05_066":"masked_warm","b05_077":"masked_tense","b05_079":"masked_tense","b05_086":"masked_tense","b06_025":"masked_warm"}
		if beats.has(str(node.id)): expect(str(node.expression)==str(beats[str(node.id)]),"Expression matches authored emotional beat")
	if actor=="nurse_haru": expect(node.outfit==("scrubs" if str(node.id)<"b02_035" else "sterile"),"Ren changes after epidural assistance")
	if actor=="nurse_iwasaki_rumi": expect(node.outfit=="scrubs","Rumi always circulating")
	if str(node.id).begins_with("c"): expect(actor!="doc_serika","Reported visit is not a new Serika entrance")
	if str(node.id)=="b05_084": expect(who=="坂口" and portraits.is_empty(),"Next instrument is Sakaguchi POV, not Ren")
	if str(node.id)>="b06_020" and str(node.id)<="b06_026": expect(actor in ["","doc_serika"],"Postoperative corridor clears patient/team; POV has no sterile gown")

func shot(app, locale: String, id: String) -> void:
	if not native or not OS.get_cmdline_user_args().has("--screenshots"): return
	if id not in ["a02_002","a02_013","b01_024","b01_039","b05_012","b05_018","b05_063","b05_073","b05_082","b05_085","a03_018","b02_015","b02_046","b03_004","b04_045","b05_011","b05_066","b05_079","b05_084","b05_086","b06_022","c01_020","c01_038"]:return
	await process_frame
	await RenderingServer.frame_post_draw
	expect(root.get_texture().get_image().save_png(QA+locale+"_"+id+".png")==OK,"Save native QA screenshot")

func run() -> void:
	native = DisplayServer.get_name()!="headless"
	DirAccess.make_dir_recursive_absolute(QA)
	approved_cgs=JSON.parse_string(FileAccess.get_file_as_string("res://tools/fixtures/chihaya_third_surgery_cgs.json"))
	for row in JSON.parse_string(FileAccess.get_file_as_string("res://docs/source/chihaya_third_surgery/parsed_source.json")):sources[str(row.id)]=row
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Load locale "+locale)
		app.configure_game_content()
		var g = app.game
		setup(g)
		expect(g.calendar_iso()=="2025-07-07" and Flow.target_day(g)==98,"Standard Monday, exact 42-day interval to Tuesday")
		g.special_event_completion_counts.erase(Flow.Second.C)
		expect(g.start_special_event(Flow.A)==null,"Full second chain required")
		setup(g)
		g.relation_for(Flow.ACTOR).rank_history.clear()
		expect(g.start_special_event(Flow.A)==null,"Numeric Lv1 is not completed milestone")
		setup(g)
		g.set_test_player_attribute("skill",59)
		expect(g.start_special_event(Flow.A)==null,"Surgery59 blocked")
		g.set_test_player_attribute("skill",60); g.relation_for(Flow.ACTOR).familiarity=24
		expect(g.start_special_event(Flow.A)==null,"Fam24 blocked")
		setup(g,58)
		expect(Flow.target_day(g)==105,"41-day interval rejects July7, defers whole chain")
		setup(g,64)
		expect(Flow.target_day(g)==105,"June3 actual second surgery implies July14 admission")
		setup(g)
		g.set_test_time(98,541)
		expect(Flow.target_day(g)==105 and g.start_special_event(Flow.A)==null,"No afternoon entry or calendar rewind")
		setup(g)
		g.character_events[Flow.Radiology.LV1].completed_day=98
		expect(g.start_special_event(Flow.A)==null,"Same-day Lv1 completion cannot backdate entrance")
		g.set_test_time(105,540)
		expect(Flow.target_day(g)==105,"Next Monday after late milestone")
		setup(g)
		var blocker: Dictionary = g.special_event_definitions.framework_single_day_test.duplicate(true)
		blocker.id="third_surgery_blocker";blocker.developer_only=false;blocker.unlock_requirements=[]
		blocker.timing={"trigger_day":99,"priority":11000,"final_week_allowed":true}
		g.special_event_definitions[blocker.id]=blocker
		expect(g.start_special_event(Flow.A)==null,"Tuesday higher-priority conflict postpones entire three-day block")
		g.special_event_definitions.erase(blocker.id)
		setup(g,64,105)
		var anchor := 105
		var before: int = g.elapsed()
		var before_attrs: Dictionary = g.player_attributes().duplicate(true)
		expect(g.start_special_event(Flow.B)==null and g.start_special_event(Flow.C)==null,"No standalone B/C entry")
		app.show_map()
		expect(app.screen=="special_event" and g.active_special_event_id==Flow.A,"Real map automatically starts Monday event")
		if g.active_special_event==null:quit(1);return
		var visited := 0
		var old_phase := ""
		while g.active_special_event!=null and not g.active_special_event.completed and visited<500:
			expect(not g.can_save_progress() and g.snapshot().is_empty(),"Each individual node forbids persistence")
			var phase: String = g.active_special_event_id
			var step: Dictionary = g.active_special_event.current_step()
			var node: Dictionary = g.active_special_event.current()
			if phase!=old_phase:
				print("CHIHAYA THIRD ",locale," ",phase," ",g.calendar_iso()," ",g.clock_text())
				old_phase=phase
				expect(g.day_number()==anchor+[Flow.A,Flow.B,Flow.C].find(phase) and g.current_absolute_clock()==540,"Continuous actual dates, 09:00")
				if phase==Flow.B:
					expect(g.relationship_level(Flow.ACTOR)==1 and not Flow.Radiology.milestone_complete(g,2),"No early Lv2 in A")
					g.set_test_player_attribute("skill",59);g.relation_for(Flow.ACTOR).familiarity=24
				if phase==Flow.C:
					expect(g.relationship_level(Flow.ACTOR)==2 and Flow.Radiology.milestone_complete(g,2),"B immediately grants real Lv2 despite changed entry stats")
					expect(g.staff_can_join_surgery_team(Flow.ACTOR),"Assistant eligibility already active before C")
					expect(g.special_event_completion_days[Flow.B]==anchor+1,"Actual surgery and rank date is Tuesday")
				expect(not g.can_save_progress() and g.snapshot().is_empty(),"Every VN node forbids persistent save")
				expect(not g.active_surgery_in_progress() and g.completed_surgeries_total==0,"No Surgery Runner/count/XP reward")
				# Reset a deliberately lowered gate after proving B→C does not recheck it.
				if phase==Flow.C:g.set_test_player_attribute("skill",60);g.relation_for(Flow.ACTOR).familiarity=25
			if node.has("unmet_variant"):
				# A met flag alone is insufficient; formal event completion is decisive.
				g.relation_for("nurse_iwasaki_rumi").met=true
				for known in [true,false]:
					if known:complete(g,INTRO,20)
					else:g.character_events.erase(INTRO);g.character_event_order.erase(INTRO)
					app.reset_dialogue_page();app.show_special_event()
					cast_check(app,node,locale,str(step.id))
					var shown: String = app.special_event_localized_text(step,node)
					if str(node.id)=="a03_018":
						expect(shown.contains("Rumi" if locale=="en" else "留美")==known,"Only approved mutually exclusive Chihaya sentence")
				g.relation_for("nurse_iwasaki_rumi").met=false
			app.reset_dialogue_page();app.show_special_event()
			var text: String = app.special_event_localized_text(step,node)
			var pages: Array = app.authored_dialogue_pages(text)
			for p in range(pages.size()):
				await process_frame
				cast_check(app,node,locale,str(step.id))
				expect(app.current_dialogue_text()==str(pages[p]),"Full localized visible page: "+str(node.id))
				for label in app.page.find_children("*","RichTextLabel",true,false):
					if label.text==str(pages[p]):expect(label.get_content_height()<=label.size.y,"No dialogue overflow: "+str(node.id))
				if p==0:await shot(app,locale,str(node.id))
				await activate(app.dialogue_default_button)
				pages_seen+=1
			visited+=1
			if app.screen=="day_transition":
				expect(not g.can_save_progress() and g.snapshot().is_empty(),"Transition also forbids saving")
				expect(g.active_special_event_id in [Flow.B,Flow.C],"Transition retains active chain")
				var buttons: Array = app.page.find_children("*","Button",true,false)
				var next_button: Button
				for button in buttons:
					if button.position==Vector2(475,465):next_button=button
				await activate(next_button)
				expect(app.screen=="special_event","Day transition proceeds directly to next episode, no management")
		expect(visited==486,"Exactly 486 source-ordered nodes")
		expect(app.screen=="special_event_complete","Final completion UI")
		expect(g.day_number()==anchor+2 and g.current_absolute_clock()==600,"Actual Wednesday10:00; never rewinds to standard week")
		expect(g.elapsed()==before+2*g.SHIFT_MINUTES+60,"Occupied two workdays plus Wednesday hour, settled once")
		expect(g.player_attributes()==before_attrs,"No invented skill/reputation rewards")
		expect(g.relation_for(Flow.ACTOR).rank_history.count(Flow.B)==1,"Lv2 granted exactly once, C no duplicate")
		expect(g.staff_record(Flow.ACTOR).get("surgical_roles",[])==["assistant_surgeon"],"No new lead-surgeon role")
		expect(g.relation_for("guest_mizuho").is_empty() and g.relation_for("patient_chihaya").is_empty(),"Cameos not turned into staff")
		expect(not g.character_event_done(INTRO) and not g.staff_is_met("nurse_iwasaki_rumi"),"No automatic nurse introduction")
		var booking: Dictionary = Flow.booking(g)
		expect(booking.admission_day==anchor+4 and booking.surgery_day==anchor+7 and booking.rounds_day==anchor+8 and booking.joint_discharge_day==anchor+14,"Future business dates use actual Monday anchor")
		expect(booking.deposit_percent_of_revised_quote==50 and not g.story_flag("mizuho_first_surgery_chain_complete"),"Revised quote half prepaid; no invented future completion")
		expect(not g.choose_special_event("continue").accepted,"Final action cannot double settle")
		app.finish_special_event_and_return()
		expect(app.screen=="map" and g.can_save_progress(),"Only final map restores save boundary")
		var save: Dictionary = g.snapshot()
		no_inner(save)
		var save_path := "/private/tmp/chihaya_third_boundary_%s_%s.json" % [OS.get_process_id(),locale]
		var save_file := FileAccess.open(save_path,FileAccess.WRITE)
		save_file.store_string(JSON.stringify(save));save_file.close()
		var disk_save: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(save_path))
		no_inner(disk_save)
		var settled: int = g.elapsed()
		var originals: Dictionary = g.special_event_step_definitions.duplicate(true)
		for id in [Flow.A,Flow.B,Flow.C]:
			g.special_event_step_definitions[id+"_main"].nodes=[]
			g.special_event_definitions[id].settled_minutes=999
		expect(g.restore(disk_save),"Boundary restore independent of old nodes/current script timing")
		expect(g.elapsed()==settled and g.player_attributes()==before_attrs and Flow.booking(g)==booking,"Settled time/attributes/booking survive")
		expect(Flow.Radiology.milestone_complete(g,2) and g.relation_for(Flow.ACTOR).rank_history.count(Flow.B)==1,"No reward replay on restore")
		g.special_event_step_definitions=originals
		for i in range(3):g.special_event_definitions[[Flow.A,Flow.B,Flow.C][i]].settled_minutes=[120,360,60][i]
		var stable: Dictionary = g.snapshot()
		expect(g.restore(stable) and g.snapshot()==stable,"Repeated boundary roundtrip stable")
		for id in [Flow.A,Flow.B,Flow.C]:
			expect(g.special_event_gallery_unlocked(id),"Completed episode unlocks gallery")
			app.show_special_gallery_entry(id)
			expect(app.screen=="special_gallery_entry","Real gallery entry available")
			app.replay_special_gallery_entry(id)
			var replay=app.special_event_gallery_replay
			expect(replay!=null,"Real gallery replay launch")
			app.special_event_gallery_replay=replay
			while not replay.completed:
				app.show_special_gallery_replay()
				cast_check(app,replay.current(),locale,str(replay.current_step().id))
				replay.apply("continue")
			expect(g.snapshot()==stable,"Gallery never mutates time, milestone, bookings")
		app.special_event_gallery_replay=null
		print("CHIHAYA THIRD completed ",locale," nodes=",visited)
		# Standard-week path uses the exact same runtime settlement, without UI
		# injection between episodes. The full rendered pass above tests delay.
		setup(g)
		expect(g.start_special_event(Flow.A)!=null,"Standard July7 production entry")
		var standard_before: int = g.elapsed()
		var count := 0
		while g.active_special_event!=null and not g.active_special_event.completed and count<500:
			g.choose_special_event("continue")
			count+=1
		expect(count==486 and g.calendar_iso()=="2025-07-09" and g.clock_text()=="10:00","Standard July7→July9 at10, exact source count")
		expect(g.special_event_completion_days[Flow.B]==99 and g.elapsed()==standard_before+1020,"Standard Tuesday milestone, fixed occupied time")
		expect(g.story_flag("chihaya_third_surgery_success") and g.story_flag("mizuho_revised_no_anesthesia_quote_half_prepaid"),"Semantic outcomes retained")
		g.finish_special_event()

	var report := {"checks":checks,"failures":failures,"pages":pages_seen,"native":native,"render_driver":RenderingServer.get_current_rendering_method()}
	var f=FileAccess.open(QA+("native_results.json" if native else "headless_results.json"),FileAccess.WRITE)
	f.store_string(JSON.stringify(report,"  ")+"\n");f.close()
	print("CHIHAYA THIRD: ",checks," checks; ",failures," failures; ",pages_seen," pages")
	# Rapid gallery traversal leaves the normal CG reveal timers outstanding.
	# Let them finish before destroying the test app, as live playback does.
	await create_timer(1.1).timeout
	app.queue_free();await process_frame
	quit(0 if failures==0 else 1)
