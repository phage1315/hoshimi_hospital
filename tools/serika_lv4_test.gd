extends "res://tools/mizuho_first_surgery_test.gd"
## Native UI + headless integration test. All fixtures are in memory; no player saves.
const Stay = preload("res://godot/systems/serika_lv4.gd")
const STEP := "serika_lv4_stay_main"
var ordered: Array = []
var phase_seen := 0
const STAY_QA := "res://docs/qa/serika_lv4/"

func setup_stay(g, connect_miyuki: bool = true) -> void:
	g.reset()
	app.screen="map"
	app.departure_interlude_resume=Callable()
	for d in g.special_event_definitions.values():
		if str(d.id)!=Stay.ID:d.developer_only=true;d.auto_schedule=false
	for d in g.character_event_definitions.values():
		if g.character_event_trigger_mode(d) in ["day_start","after_work"]:d.trigger_mode="location"
	g.meet_staff("doc_serika");g.meet_staff("nurse_yui")
	var rel: Dictionary=g.relation_for("doc_serika")
	rel.level=3;rel.familiarity=55;rel.rank_history=["serika_lv3_half_beat"]
	var previous=Event.new(g.character_event_definitions.serika_lv3_half_beat)
	previous.completed=true;previous.completed_day=120;previous.settled_minutes=0
	g.character_events.serika_lv3_half_beat=previous
	g.character_event_order.append("serika_lv3_half_beat")
	g.relation_for("nurse_yui").level=3
	var slot: Dictionary=g.relationship_rank_slot("nurse_yui",3)
	slot.content_status="planned";slot.event_id=""
	if connect_miyuki:
		# Simulate a future real authored milestone locally, never deploy a stub.
		slot.content_status="authored";slot.event_id="test_miyuki_lv3_completed"
		g.relation_for("nurse_yui").rank_history=[slot.event_id]
		g.special_event_completion_counts[slot.event_id]=1
		g.special_event_completion_days[slot.event_id]=120
	g.set_test_time(130,960)

func render_audit(node: Dictionary, locale: String) -> void:
	var row: Dictionary=sources[str(node.id)]
	var cg_path := str(node.get("cg_path", ""))
	var cg: TextureRect = app.page.get_node_or_null("CharacterEventCG") as TextureRect
	if cg_path.is_empty():
		expect(cg == null, "No stale CG overlay: "+str(node.id))
	else:
		expect(cg != null and cg.texture != null and cg.texture.resource_path == "res://"+cg_path, "Actual CG texture loaded: "+str(node.id))
		expect(cg != null and cg.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "CG is contained without cropping: "+str(node.id))
	var english_names := {"旁白":"Narrator","坂口隆司":"Ryuji Sakaguchi","御園芹香":"Serika Misono","堀内奈奈美":"Nanami Horiuchi","朝仓美幸":"Miyuki Asakura","朝仓美幸（电话）":"Miyuki Asakura (phone)","利根川安琪":"Ange Tonegawa","薗田愛実":"Itsumi Sonoda","岩崎留美":"Rumi Iwasaki","米田栞":"Shiori Yoneda","折川皐月":"Satsuki Orikawa"}
	expect(str(node.speaker_label)==str(english_names[row.speaker] if locale=="en" else row.speaker),"Original speaker "+str(node.id))
	var who: String=app.special_event_speaker(node,app.special_event_actor(node),STEP)
	var labels: Array=[]
	for child in app.page.get_children():
		if child is Label and child.position==Vector2(82,558):labels.append(child)
	expect(labels.size()==1 and labels[0].text==who,"Actual nameplate "+str(node.id))
	if str(row.speaker)=="堀内奈奈美":expect(who==("Nanami Horiuchi" if locale=="en" else "堀内奈奈美") and str(node.speaker)=="actor","Nanami remains named speech, not narrator")
	var sprites: Array=app.page.find_children("EventPortrait_*","TextureRect",true,false)
	expect(sprites.size()==node.event_portraits.size(),"No stale portrait "+str(node.id))
	for portrait in node.event_portraits:
		var item=app.page.get_node_or_null("EventPortrait_"+str(portrait.id))
		expect(str(portrait.id)==str(node.actor_id),"Staged actor matches speaker")
		expect(item!=null and item.texture!=null and item.texture.resource_path=="res://"+str(portrait.path),"Actual texture matches source staging")

func click(button: Button) -> void:
	# CG-backed nodes intentionally delay dialogue and controls; wait for their reveal.
	var frames := 0
	while is_instance_valid(button) and (not button.is_visible_in_tree() or button.disabled) and frames < 120:
		await process_frame
		frames += 1
	expect(is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled,"Actual Continue control usable after reveal")
	if not is_instance_valid(button):return
	if native:
		var point := button.get_global_rect().get_center()
		for pressed in [true,false]:
			var input:=InputEventMouseButton.new()
			input.button_index=MOUSE_BUTTON_LEFT;input.pressed=pressed;input.position=point;input.global_position=point
			root.push_input(input,true)
			await process_frame
	else:
		button.emit_signal("pressed")
		await process_frame

func play_stay(locale: String, gallery: bool = false) -> void:
	var g=app.game
	var count:=0
	while count<548:
		while app.screen=="special_event_blackout":await process_frame
		var event=app.special_event_gallery_replay if gallery else g.active_special_event
		if event==null or event.completed:break
		var node: Dictionary=event.current()
		expect(str(node.id)==str(ordered[count].id),"No skipped/reordered nodes")
		if not gallery:
			expect(not g.can_save_progress() and g.snapshot().is_empty(),"Every node denies save")
			expect(g.relationship_level("doc_serika")==3 and g.relation_for("doc_serika").route=="colleague" and not g.special_event_done(Stay.ID),"No early Lv4/romance")
			expect(is_equal_approx(g.familiarity_gain_multiplier("doc_serika"),0.8),"Multiplier stays .8 until final node")
			var cue: Dictionary=event.current_step().scene_schedule[node.id]
			expect(g.display_schedule().day==130+int(cue.day_offset) and g.display_schedule().absolute_clock==int(cue.clock),"Scene day/clock exact including midnight")
			expect(g.elapsed()==(130-1)*g.SHIFT_MINUTES+420,"No intermediate ledger advancement")
		var pages: Array=app.authored_dialogue_pages(app.special_event_localized_text(event.current_step(),node))
		for p in range(pages.size()):
			await process_frame
			render_audit(node,locale)
			expect(app.current_dialogue_text()==str(pages[p]),"Full localized page rendered")
			for label in app.page.find_children("*","RichTextLabel",true,false):
				if label.text==str(pages[p]):expect(label.get_content_height()<=label.size.y,"Text fits "+str(node.id))
			if native and not gallery and p==0 and str(node.id) in ["s01_004","s02_030","s03_022","s03_033","s04_016","s05_009","s05_042","s05_098","s06_066","s06_h31","s06_104","s07_046"]:
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(STAY_QA+locale+"_"+str(node.id)+".png")
			if failures>0:
				print("FAIL AT ",node.id," ",app.screen);quit(1);return
			await click(app.dialogue_default_button)
		count+=1;seen+=1
	expect(count==547,"All 547 nodes rendered")

func boundary_stay(g) -> void:
	var saved: Dictionary=g.snapshot()
	expect(not saved.is_empty(),"Safe boundary snapshot available")
	no_inner(saved)
	var before: int=g.elapsed();var rel: Dictionary=g.relation_for("doc_serika").duplicate(true)
	var original: Array=g.special_event_step_definitions[STEP].nodes
	g.special_event_step_definitions[STEP].nodes=[]
	expect(g.restore(saved),"Restore after deleting all old script nodes")
	expect(g.elapsed()==before,"Time stable across boundary restore")
	for key in preload("res://godot/systems/boundary_save.gd").RELATION_FIELDS:
		expect(g.relation_for("doc_serika").get(key)==rel.get(key),"Settled relationship field stable: "+key)
	g.special_event_step_definitions[STEP].nodes=original
	expect(g.restore(g.snapshot()) and g.elapsed()==before,"Repeat save/read stable")

func run() -> void:
	native=DisplayServer.get_name()!="headless"
	DirAccess.make_dir_recursive_absolute(STAY_QA)
	ordered=JSON.parse_string(FileAccess.get_file_as_string("res://docs/source/serika_lv4/parsed_source.json"))
	for row in ordered:sources[str(row.id)]=row
	app=load("res://godot/scenes/main.tscn").instantiate();root.add_child(app)
	await process_frame
	app.dialogue_auto_enabled=false
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Load content "+locale);app.configure_game_content()
		var g=app.game
		setup_stay(g,false)
		expect(not g.special_event_available(g.special_event_definitions[Stay.ID]),"Real production Miyuki Lv3 remains locked")
		setup_stay(g)
		expect(g.special_event_available(g.special_event_definitions[Stay.ID]),"55 gate after valid milestones")
		g.relation_for("doc_serika").familiarity=54
		expect(not g.special_event_available(g.special_event_definitions[Stay.ID]),"54 gate blocked")
		g.relation_for("doc_serika").familiarity=55
		g.free_h_booking={"actor_id":"doc_sayaka","workday":130}
		expect(not g.special_event_available(g.special_event_definitions[Stay.ID]),"Accepted private booking preserved")
		g.free_h_booking.clear()
		g.set_test_time(130,959)
		expect(not g.special_event_available(g.special_event_definitions[Stay.ID]),"Before departure blocked")
		g.set_test_time(130,960)
		g.pending_day_exit_workday=130;g.pending_day_exit_clock=1380
		expect(not g.special_event_available(g.special_event_definitions[Stay.ID]),"23:00 excluded")
		g.character_events.serika_lv3_half_beat.completed_day=128
		g.pending_day_exit_clock=1379
		expect(not g.special_event_available(g.special_event_definitions[Stay.ID]),"Overtime cannot shorten actual-workday cooldown")
		g.character_events.serika_lv3_half_beat.completed_day=120
		g.pending_day_exit_clock=1379
		expect(g.special_event_available(g.special_event_definitions[Stay.ID]),"22:59 allowed")
		g.clear_pending_departure_context()
		# Reserve the coming operation; the new event must defer all three days.
		g.special_event_completion_counts[Flow.Third.A]=1;g.special_event_completion_days[Flow.Third.A]=125
		expect(not g.special_event_available(g.special_event_definitions[Stay.ID]),"Future Mizuho appointment blocks continuous span")
		g.special_event_completion_counts.erase(Flow.Third.A);g.special_event_completion_days.erase(Flow.Third.A)
		var attrs: Dictionary=g.player_attributes().duplicate(true)
		var nurses: Dictionary={}
		for actor in ["nurse_sonoda_itsumi","nurse_iwasaki_rumi","nurse_yoneda_shiori","nurse_satsuki","nurse_ange"]:nurses[actor]=g.relation_for(actor).duplicate(true)
		app.request_end_workday()
		expect(g.active_special_event_id==Stay.ID and app.screen=="special_event","Actual after-work UI entry")
		await play_stay(locale)
		if failures: return
		expect(g.relationship_level("doc_serika")==4 and g.relation_for("doc_serika").route=="romance","Final node alone settles romance Lv4")
		expect(is_equal_approx(g.familiarity_gain_multiplier("doc_serika"),1.0) and g.relation_for("doc_serika").unlocked_benefits.has("unlock_intimacy_events"),"Milestone multiplier + future intimacy eligibility")
		expect(g.day_number()==133 and g.current_absolute_clock()==540 and g.special_event_completion_days[Stay.ID]==133,"D3 actual morning and completion date")
		expect(g.completed_surgeries_total==0 and g.player_attributes()==attrs and g.relation_for("doc_serika").familiarity==55,"No additional clinical/date rewards")
		for actor in nurses:expect(g.relation_for(actor)==nurses[actor],"Professional appearance never meets/unlocks nurse")
		expect(g.active_adult_intimacy==null and g.free_h_booking.is_empty() and g.active_free_h_departure.is_empty(),"Fixed scene never calls H runner or booking")
		expect(g.free_h_unlocked("doc_serika"),"Existing authored Free H becomes eligible after real Lv4 settlement")
		expect(not g.choose_special_event("continue").accepted,"No duplicate settlement")
		app.finish_special_event_and_return()
		expect(app.screen=="map" and g.can_save_progress(),"D3 hospital safe boundary")
		boundary_stay(g)
		var before: Dictionary=g.snapshot()
		app.replay_special_gallery_entry(Stay.ID)
		await play_stay(locale,true)
		app.show_map(false)
		expect(g.snapshot()==before,"Full replay changes no persistent facts/time/rewards")
		print("SERIKA LV4 UI COMPLETE ",locale)
	# Overtime starts on the departing workday even when the ledger is tomorrow.
	var g=app.game
	setup_stay(g);var before: int=g.elapsed()
	g.story_time_advance_minutes+=300;g.settle_overtime(before,300)
	expect(g.current_workday()==130 and g.day_number()==131,"Overtime fixture")
	app.show_day_transition(app.show_map)
	expect(g.active_special_event_id==Stay.ID and app.screen=="special_event","Actual overtime departure UI entry")
	expect(g.display_schedule().day==130,"Presentation anchored to D0, not tomorrow's ledger")
	while g.special_event_in_progress():g.choose_special_event("continue")
	expect(g.day_number()==133 and g.current_absolute_clock()==540 and g.pending_departure_context().is_empty(),"Overtime settles only to D3 and clears old departure")
	print("SERIKA LV4: ",checks," checks; ",failures," failures; ",seen," rendered nodes; native=",native)
	quit(1 if failures else 0)
