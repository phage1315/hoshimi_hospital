extends SceneTree
const Flow = preload("res://godot/systems/mizuho_first_surgery.gd")
const Event = preload("res://godot/systems/character_event_session.gd")
const Lv3 = preload("res://godot/systems/serika_lv3.gd")
const Replay = preload("res://godot/systems/special_event_session.gd")
var checks := 0
var failures := 0
var app
var sources := {}
var native := false
var seen := 0
var actors := {"瑞穗":"guest_mizuho","千早":"patient_chihaya","芹香":"doc_serika","阿库娅":"doc_aqua","弘子":"nurse_hiroko","米田":"nurse_yoneda_shiori","朝仓":"nurse_yui","留美":"nurse_iwasaki_rumi"}
const QA := "res://docs/qa/mizuho_first_surgery/"

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func done(g, id: String, day: int) -> void:
	g.special_event_completion_counts[id]=1
	g.special_event_completion_days[id]=day

func setup(g, anchor: int = 98) -> void:
	g.reset()
	app.screen="map"
	app.departure_interlude_resume=Callable()
	for i in range(3):done(g,[Flow.Third.A,Flow.Third.B,Flow.Third.C][i],anchor+i)
	g.meet_staff("doc_serika")
	g.relation_for("doc_serika").level=2
	g.relation_for("doc_serika").familiarity=40
	g.relation_for("doc_serika").rank_history=[Flow.Third.B]
	# Isolate unrelated optional events; fixed reservations are tested separately.
	for d in g.special_event_definitions.values():
		if not Flow.owns(str(d.id)):d.developer_only=true
	for d in g.character_event_definitions.values():
		if g.character_event_trigger_mode(d) in ["day_start","after_work"]:d.trigger_mode="location"
	g.set_test_time(anchor+4,g.SHIFT_START_MINUTE)

func book(g) -> void:
	g.meet_staff("doc_sayaka")
	var rel: Dictionary=g.relation_for("doc_sayaka")
	rel.level=4;rel.route="romance";rel.rank_history=["sayaka_lv4_hotel_date"];rel.unlocked_benefits=["unlock_intimacy_events"]
	var e=Event.new(g.character_event_definitions.sayaka_lv4_hotel_date)
	e.completed=true;e.completed_day=6;e.settled_minutes=0
	g.character_events.sayaka_lv4_hotel_date=e
	g.character_event_order.append("sayaka_lv4_hotel_date")
	g.set_story_flag("sayaka_lv4_complete")
	g.free_h_booking={"actor_id":"doc_sayaka","workday":g.current_workday()}
	expect(g.free_h_unlocked("doc_sayaka"),"Valid pre-existing private booking")

func no_inner(value: Variant) -> void:
	if value is Dictionary:
		for key in value:
			expect(key not in ["node_id","choices","last_choice","step_index","action_log","active_special_event","departure_interlude_resume"],"No persisted inner state: "+str(key))
			no_inner(value[key])
	elif value is Array:
		for x in value:no_inner(x)

func roundtrip(g) -> void:
	var save: Dictionary=g.snapshot()
	expect(not save.is_empty(),"Boundary save available")
	no_inner(save)
	var path := "/private/tmp/mizuho_boundary_%s.json" % OS.get_process_id()
	var f=FileAccess.open(path,FileAccess.WRITE)
	f.store_string(JSON.stringify(save));f.close()
	var disk: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(path))
	var elapsed: int=g.elapsed()
	var attrs: Dictionary=g.player_attributes().duplicate(true)
	var completion: Dictionary=g.special_event_completion_counts.duplicate(true)
	# Completed text and node identities are irrelevant to a persistent save.
	var original: Dictionary=g.special_event_step_definitions.duplicate(true)
	for id in [Flow.A,Flow.S,Flow.B,Flow.C]:
		g.special_event_step_definitions[id+"_main"].nodes=[]
	expect(g.restore(disk),"Read saved facts after script nodes removed")
	expect(g.elapsed()==elapsed and g.player_attributes()==attrs and g.special_event_completion_counts==completion,"No time/reward drift after restore")
	g.special_event_step_definitions=original
	var again: Dictionary=g.snapshot()
	expect(g.restore(again) and g.elapsed()==elapsed,"Second save/read stable")

func click(button: Button) -> void:
	expect(is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled,"Actual Continue control usable")
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

func cast(node: Dictionary, step: String, locale: String) -> void:
	var who: String=str(sources[str(node.id)].speaker).get_slice("（",0)
	var actor: String=actors.get(who,"")
	expect(str(node.get("actor_id",""))==actor,"Original speaker: "+str(node.id))
	if not actor.is_empty():expect(str(app.special_event_actor(node).get("id",""))==actor,"Canonical actor resolved")
	var shown: Array=app.page.find_children("EventPortrait_*","TextureRect",true,false)
	var cg=app.page.get_node_or_null("CharacterEventCG")
	if not str(node.get("cg_path", "")).is_empty():
		expect(shown.is_empty(),"No portrait overlay on approved CG")
		expect(cg!=null and cg.texture!=null and cg.texture.resource_path=="res://"+str(node.cg_path),"Approved CG texture loaded")
		expect(cg!=null and cg.stretch_mode==TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"CG contain, no cropping")
	else:
		expect(cg==null,"CG cleared at exit")
		expect(shown.size()==(0 if actor.is_empty() else 1),"No stale or borrowed portraits: "+str(node.id))
		for item in node.event_portraits:
			var sprite=app.page.get_node_or_null("EventPortrait_"+actor)
			expect(sprite!=null and sprite.texture!=null and sprite.texture.resource_path=="res://"+str(item.path),"Correct loaded texture: "+str(node.id))
	var labels: Array=[]
	for child in app.page.get_children():
		if child is Label and child.position==Vector2(82,558):labels.append(child)
	var nameplate: String=app.special_event_speaker(node,app.special_event_actor(node),step)
	expect(labels.size()==1 and labels[0].text==nameplate,"Actual nameplate matches actor: "+str(node.id))
	if actor in ["nurse_iwasaki_rumi","nurse_yoneda_shiori"]:
		expect(not app.game.character_event_done("intro_rumi_shiori_hiroko_monday_0900"),"No invented formal intro")
		expect(nameplate in ["手术室值班护士","巡回护士","OR Duty Nurse","Circulating Nurse"],"Existing unmet nameplate rule")
	if str(node.id)=="b02_039":expect(actor=="guest_mizuho" and nameplate.contains("thinking" if locale=="en" else "心声"),"Inner speech retains Mizuho")
	if str(node.id) in ["b07_002","b10_076"]:expect(actor.is_empty() and shown.is_empty(),"Calling Hiroko does not change speaker")
	if str(node.id)>="c02_011":expect(actor in ["","guest_mizuho","patient_chihaya"],"Departed staff cleared")

func play(id: String, locale: String, gallery: bool = false) -> void:
	var g=app.game
	var count:=0
	while count<1100:
		while app.screen=="special_event_blackout":
			await process_frame
		var event=app.special_event_gallery_replay if gallery else g.active_special_event
		if event==null or event.completed or str(event.definition.id)!=id:break
		var node: Dictionary=event.current();var step: Dictionary=event.current_step()
		if not gallery:expect(not g.can_save_progress() and g.snapshot().is_empty(),"Every VN node forbids save")
		var pages: Array=app.authored_dialogue_pages(app.special_event_localized_text(step,node))
		for p in range(pages.size()):
			await process_frame
			cast(node,str(step.id),locale)
			if failures>0:
				print("FIRST FAILURE node=",node.id," screen=",app.screen," current=",app.current_dialogue_text()," expected=",pages[p])
				quit(1)
				return
			expect(app.current_dialogue_text()==str(pages[p]),"Full localized page displayed")
			for label in app.page.find_children("*","RichTextLabel",true,false):
				if label.text==str(pages[p]):expect(label.get_content_height()<=label.size.y,"Dialogue fits: "+str(node.id))
			if native and not gallery and p==0 and str(node.id) in ["a02_012","s01_023","b01_033","b03_002","b05_025","b06_039","b07_002","b08_008","b10_065","c01_067","c02_060"]:
				await RenderingServer.frame_post_draw
				expect(root.get_texture().get_image().save_png(QA+locale+"_"+str(node.id)+".png")==OK,"Native screenshot saved")
			await click(app.dialogue_default_button)
		count+=1;seen+=1
	expect(count=={Flow.A:195,Flow.S:47,Flow.B:631,Flow.C:174}[id],"All source nodes visited in order: "+id+" "+str(count))

func run() -> void:
	native=DisplayServer.get_name()!="headless"
	DirAccess.make_dir_recursive_absolute(QA)
	for row in JSON.parse_string(FileAccess.get_file_as_string("res://docs/source/mizuho_first_surgery/parsed_source.json")):sources[str(row.id)]=row
	app=load("res://godot/scenes/main.tscn").instantiate();root.add_child(app)
	await process_frame
	app.dialogue_auto_enabled=false
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Load "+locale);app.configure_game_content()
		var g=app.game
		setup(g)
		expect(g.calendar_iso()=="2025-07-11","Standard Friday")
		g.special_event_completion_counts.erase(Flow.Third.C)
		expect(g.start_special_event(Flow.A)==null,"Full third chain required")
		setup(g)
		g.set_test_time(102,541)
		expect(g.start_special_event(Flow.A)==null,"No afternoon rescheduling")
		g.set_test_time(109,540)
		expect(g.start_special_event(Flow.A)==null,"No weekly catch-up")
		setup(g)
		expect(g.start_special_event(Flow.B)==null and g.start_special_event(Flow.C)==null,"No early B/C")
		# Existing event exclusions protect future appointments before A plays.
		g.set_test_time(101,540)
		var blocker: Dictionary=g.special_event_definitions.framework_three_day_test.duplicate(true)
		blocker.developer_only=false;blocker.timing.priority=999
		expect(Flow.conflicts_with_reservation(g,blocker) and not g.special_event_available(blocker),"Multi-day event cannot consume reserved Friday/Saturday")
		expect(not Flow.blocking_reservation(g,101,104).is_empty(),"Referral reservation before first episode")
		# Test delayed anchor in the actual UI, both languages.
		setup(g,105)
		var attrs: Dictionary=g.player_attributes().duplicate(true)
		var before: int=g.elapsed()
		app.show_map()
		expect(app.screen=="special_event" and g.active_special_event_id==Flow.A,"Actual map auto-starts delayed Friday")
		await play(Flow.A,locale)
		expect(g.elapsed()==before+60 and g.day_number()==109 and g.current_absolute_clock()==600,"A once, Friday10:00")
		expect(not g.choose_special_event("continue").accepted,"A cannot double-settle")
		app.finish_special_event_and_return()
		expect(app.screen=="map" and g.can_save_progress(),"Normal map/save between episodes")
		roundtrip(g)
		g.set_test_time(110,960);book(g)
		var booking: Dictionary=g.free_h_booking.duplicate(true)
		before=g.elapsed()
		app.request_end_workday()
		expect(g.active_special_event_id==Flow.S and g.free_h_booking==booking and g.active_free_h_departure.is_empty(),"S precedes booking without calling H")
		await play(Flow.S,locale)
		expect(g.elapsed()==before and g.special_event_completion_days[Flow.S]==110,"S zero time, actual Saturday completion")
		expect(g.free_h_booking==booking and not g.active_free_h_departure.is_empty(),"S resumes valid original private appointment")
		while app.get_node_or_null("FreeHDepartureFade")!=null:await process_frame
		g.finish_free_h_departure()
		app.h_profile_test_session=null;app.h_profile_event_mode=false;app.h_profile_run_kind="test"
		expect(g.day_number()==111,"Private departure advances only to Sunday")
		g.set_test_time(112,540);before=g.elapsed()
		app.show_map();expect(g.active_special_event_id==Flow.B,"Monday surgery auto-entry")
		await play(Flow.B,locale)
		expect(g.elapsed()==before+g.SHIFT_MINUTES and g.special_event_completion_days[Flow.B]==112,"B occupies complete actual workday once")
		expect(not g.story_flag(Lv3.MIZUHO_CHAIN_FACT),"B is not chain completion")
		expect(app.screen in ["day_transition","after_work_walk"],"B exits through existing same-day departure")
		expect(g.completed_surgeries_total==0 and g.player_attributes()==attrs,"No surgery runner/XP/presence/reputation reward")
		# Complete any ordinary random departure and enter Tuesday normally.
		g.active_after_work_walk.clear();g.clear_pending_departure_context();g.active_mode="encounter"
		g.set_test_time(113,540);before=g.elapsed()
		app.show_map();expect(g.active_special_event_id==Flow.C,"Tuesday rounds auto-entry")
		await play(Flow.C,locale)
		expect(g.elapsed()==before+60 and g.current_absolute_clock()==600,"C ends Tuesday10:00 once")
		expect(g.story_flag(Lv3.MIZUHO_CHAIN_FACT) and g.relationship_level("doc_serika")==2,"C unlocks prerequisite, not automatic Lv3")
		expect(not g.staff_is_met("guest_mizuho") and not g.staff_is_met("patient_chihaya") and g.relationship_level("guest_mizuho")==0 and g.relationship_level("patient_chihaya")==0,"Patients do not unlock future nurse identities before return")
		app.finish_special_event_and_return();roundtrip(g)
		g.set_test_time(118,540)
		expect(Lv3.eligible(g),"Following Sunday Lv3 eligible with real Lv2 and Fam40")
		g.relation_for("doc_serika").familiarity=39
		expect(not Lv3.eligible(g),"Fam39 remains blocked")
		g.relation_for("doc_serika").familiarity=40
		expect(not g.story_flag("mizuho_chihaya_joint_discharge_complete"),"No premature joint discharge")
		# Full gallery playback exercises the same actor/nameplate rendering.
		for id in [Flow.A,Flow.S,Flow.B,Flow.C]:
			app.replay_special_gallery_entry(id)
			await play(id,locale,true)
		print("MIZUHO UI COMPLETE ",locale)
	# Standard schedule, ordinary departure with no booking, and late overtime.
	var g=app.game
	for anchor_day in [98,126]:
		setup(g,anchor_day)
		for id in [Flow.A,Flow.S,Flow.B,Flow.C]:
			var day: int=anchor_day+int(Flow.OFFSETS[id])
			g.set_test_time(day,960 if id==Flow.S else 540)
			var before: int=g.elapsed()
			expect(g.start_special_event(id)!=null,"Standard/delayed actual appointment: "+id)
			while g.special_event_in_progress():g.choose_special_event("continue")
			expect(g.special_event_completion_days[id]==day,"Stable actual completion date")
			expect(g.elapsed()==before+({Flow.A:60,Flow.S:0,Flow.B:g.SHIFT_MINUTES,Flow.C:60}[id]),"Actual stage time once")
			g.finish_special_event()
			if id==Flow.B:
				expect(g.pending_departure_context()=={"workday":day,"clock":g.SHIFT_START_MINUTE+g.SHIFT_MINUTES},"B actual evening context")
				g.clear_pending_departure_context()
			expect(g.start_special_event(id)==null,"No repeated appointment")
	for with_booking in [false,true]:
		setup(g);done(g,Flow.A,102);g.set_test_time(103,1000)
		if with_booking:book(g)
		var prior: int=g.elapsed()
		g.story_time_advance_minutes+=300
		g.settle_overtime(prior,300)
		expect(g.day_number()==104 and g.current_workday()==103 and g.display_schedule().absolute_clock==1300,"Real ledger Sunday, actual Saturday21:40")
		var overtime_before: int=g.elapsed()
		app.show_day_transition(app.show_map)
		expect(g.active_special_event_id==Flow.S,"Overtime S uses actual workday, no evening cutoff")
		while g.special_event_in_progress():app.choose_special_event("continue")
		expect(g.elapsed()==overtime_before and g.special_event_completion_days[Flow.S]==103,"Overtime S adds no time")
		if with_booking:
			expect(not g.active_free_h_departure.is_empty(),"Overtime S retains valid booking")
			while app.get_node_or_null("FreeHDepartureFade")!=null:await process_frame
			g.finish_free_h_departure()
			app.h_profile_test_session=null;app.h_profile_event_mode=false;app.h_profile_run_kind="test"
		else:
			expect(app.screen in ["day_transition","after_work_walk"],"No-booking S resumes ordinary departure")
		g.active_after_work_walk.clear();g.clear_pending_departure_context();g.active_mode="encounter"
		app.show_map(false)
		roundtrip(g)
	print("MIZUHO FIRST SURGERY: ",checks," checks; ",failures," failures; ",seen," rendered source nodes; native=",native)
	quit(1 if failures else 0)
