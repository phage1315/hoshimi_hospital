extends SceneTree
const Flow = preload("res://godot/systems/chihaya_mizuho_return.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
var checks := 0
var failures := 0
var app
var seen := 0
var native := false
const QA := "res://docs/qa/chihaya_mizuho_return/"
var actors := {"千早":"patient_chihaya","瑞穗":"guest_mizuho","朝仓":"nurse_yui","芹香":"doc_serika","明日香":"doc_asuka"}

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void: call_deferred("run")

func done(g,id: String,day: int) -> void:
	g.special_event_completion_counts[id]=1
	g.special_event_completion_days[id]=day

func setup(g,anchor: int=98) -> void:
	g.reset();app.screen="map"
	for id in ["a","b","c"]:done(g,"chihaya_third_surgery_"+id,anchor+{"a":0,"b":1,"c":2}[id])
	for id in ["a","s","b","c"]:done(g,"mizuho_first_surgery_"+id,anchor+{"a":4,"s":5,"b":7,"c":8}[id])
	for d in g.special_event_definitions.values():
		if not Flow.owns(str(d.id)):d.developer_only=true
	for d in g.character_event_definitions.values():
		if g.character_event_trigger_mode(d) in ["day_start","after_work"]:d.trigger_mode="location"
	g.set_test_time(anchor+14,540)

func no_inner(v: Variant) -> void:
	if v is Dictionary:
		for key in v:
			expect(key not in ["node_id","choices","last_choice","step_index","action_log","active_special_event","staff_chat_turn","variant"],"No inner state: "+str(key));no_inner(v[key])
	elif v is Array:
		for x in v:no_inner(x)

func roundtrip(g) -> void:
	var save: Dictionary=g.snapshot();expect(not save.is_empty(),"Safe boundary save");no_inner(save)
	var path := "/private/tmp/hoshimi_return_boundary_%s.json" % OS.get_process_id()
	var file=FileAccess.open(path,FileAccess.WRITE);file.store_string(JSON.stringify(save));file.close()
	var original: Dictionary=g.special_event_step_definitions.duplicate(true)
	for id in [Flow.DISCHARGE,Flow.RETURN]:g.special_event_step_definitions[id+"_main"].nodes=[]
	var elapsed: int=g.elapsed();var relations: Dictionary=g.relationships.duplicate(true);var contracts: Dictionary=g.staff_contracts.duplicate(true)
	expect(g.restore(JSON.parse_string(FileAccess.get_file_as_string(path))),"Restore after internal node deletion")
	expect(g.elapsed()==elapsed,"Settled time unchanged")
	for actor in Flow.ACTORS:
		for key in ["familiarity","level","affection"]:expect(float(g.relation_for(actor)[key])==float(relations[actor][key]),"Relationship number unchanged")
		for key in ["flags","rank_history","event_history","met"]:expect(g.relation_for(actor)[key]==relations[actor][key],"Relationship fact unchanged")
		if contracts.has(actor):
			for key in ["start_day","end_day"]:expect(int(g.staff_contracts[actor][key])==int(contracts[actor][key]),"Contract unchanged")
	g.special_event_step_definitions=original
	expect(g.restore(g.snapshot()) and g.elapsed()==elapsed,"Repeated save/load stable")

func click(button: Button) -> void:
	# CG entrances briefly delay Continue; wait for the actual runtime control.
	if is_instance_valid(button) and not button.is_visible_in_tree():
		await create_timer(1.1).timeout
	expect(is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled,"Real Continue usable")
	# Invoke the actual UI control deterministically while rendering the native window.
	# OS mouse movement during a long sweep must not alter the event under test.
	button.emit_signal("pressed")
	await process_frame

func play(id: String,locale: String,gallery: bool=false) -> void:
	var count:=0
	var source: Array=JSON.parse_string(FileAccess.get_file_as_string("res://tools/fixtures/chihaya_mizuho_return/source_rows.json"))["d" if id==Flow.DISCHARGE else "n"]
	while count<900:
		var e=app.special_event_gallery_replay if gallery else app.game.active_special_event
		if e==null or e.completed or str(e.definition.id)!=id:break
		var node: Dictionary=e.current();var step: Dictionary=e.current_step()
		expect(node.id==source[count].id,"Original node order")
		var actor: String=actors.get(str(source[count].speaker).get_slice("（",0),"")
		expect(str(node.get("actor_id",""))==actor,"Canonical source speaker "+node.id)
		if not gallery:
			expect(not app.game.can_save_progress() and app.game.snapshot().is_empty(),"No VN save")
			for who in Flow.ACTORS:expect(not app.game.staff_is_met(who),"No early staff unlock")
		var pages: Array=app.authored_dialogue_pages(app.special_event_localized_text(step,node))
		for p in range(pages.size()):
			await process_frame
			expect(app.current_dialogue_text()==str(pages[p]),"Localized page exact "+node.id)
			expect(app.page.get_node_or_null("SceneBackground")!=null,"Background actually loaded "+node.id)
			var portraits: Array=app.page.find_children("EventPortrait_*","TextureRect",true,false)
			var cg=app.page.get_node_or_null("CharacterEventCG")
			var cg_path: String=str(node.get("cg_path",""))
			if not cg_path.is_empty():
				expect(portraits.is_empty(),"No sprite overlay on CG "+node.id)
				expect(cg!=null and cg.texture!=null and cg.texture.resource_path=="res://"+cg_path,"Approved CG loaded "+node.id)
				expect(cg!=null and cg.stretch_mode==TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"CG uncropped "+node.id)
			else:
				expect(cg==null,"CG clears outside mapped nodes "+node.id)
				expect(portraits.size()==node.event_portraits.size(),"No stale or borrowed actor "+node.id)
			for item in (node.event_portraits if cg_path.is_empty() else []):
				var sprite=app.page.get_node_or_null("EventPortrait_"+actor)
				expect(sprite!=null and sprite.texture!=null and sprite.texture.resource_path=="res://"+str(item.path),"Exact portrait texture "+node.id)
			var nameplate: String=app.special_event_speaker(node,app.special_event_actor(node),str(step.id))
			var labels: Array=[]
			for child in app.page.get_children():
				if child is Label and child.position==Vector2(82,558):labels.append(child)
			expect(labels.size()==1 and labels[0].text==nameplate,"Actual nameplate "+node.id)
			for label in app.page.find_children("*","RichTextLabel",true,false):
				if label.text==str(pages[p]):expect(label.get_content_height()<=label.size.y,"Page fits "+node.id)
			if native and not gallery and p==0 and node.id in ["d01_004","d02_002","d03_004","d04_021","n01_005","n02_002","n03_001","n04_082","n05_001","n06_059","d01_046","d03_058","d03_122","n02_016","n03_198","n04_059","n05_017","n05_071","n06_054"]:
				await RenderingServer.frame_post_draw
				expect(root.get_texture().get_image().save_png(QA+locale+"_"+str(node.id)+".png")==OK,"Screenshot")
			if failures:
				print("FAIL AT ",node.id," screen=",app.screen);quit(1);return
			if native and not gallery and p==0 and node.id in ["d03_134","d04_001","n05_038","n05_039","n05_043","n05_044"]:
				await RenderingServer.frame_post_draw
				expect(root.get_texture().get_image().save_png(QA+"cg_"+locale+"_"+str(node.id)+".png")==OK,"CG transition screenshot")
			await click(app.dialogue_default_button)
		count+=1;seen+=1
	expect(count==source.size(),"All source nodes rendered "+id)

func run() -> void:
	native=DisplayServer.get_name()!="headless";DirAccess.make_dir_recursive_absolute(QA)
	app=load("res://godot/scenes/main.tscn").instantiate();root.add_child(app);await process_frame
	app.saves.path="/private/tmp/hoshimi_return_cg_unused_%s.json" % OS.get_process_id()
	app.dialogue_auto_enabled=false
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Content loads "+locale);app.configure_game_content()
		var g=app.game;setup(g)
		expect(g.calendar_iso()=="2025-07-21","Holiday fixed discharge")
		g.special_event_completion_counts.erase("mizuho_first_surgery_c")
		expect(g.start_special_event(Flow.DISCHARGE)==null,"Full preceding chain required")
		setup(g);g.set_test_time(112,541);expect(g.start_special_event(Flow.DISCHARGE)==null,"No late discharge")
		setup(g);g.set_test_time(113,540);expect(g.start_special_event(Flow.DISCHARGE)==null,"No silent next-day shift")
		setup(g)
		var before: int=g.elapsed();var attrs: Dictionary=g.player_attributes().duplicate(true)
		app.show_map();expect(g.active_special_event_id==Flow.DISCHARGE,"Map autostarts holiday discharge")
		await play(Flow.DISCHARGE,locale)
		expect(g.elapsed()==before+60 and g.current_absolute_clock()==600,"Discharge exactly 60 minutes")
		expect(g.story_flag("chihaya_mizuho_discharged") and g.staff_contracts.is_empty(),"Independent discharge, no hire/debt")
		app.finish_special_event_and_return();roundtrip(g)
		var return_day: int=Flow.scheduled_day(g,Flow.RETURN)
		expect(Flow.Calendar.date_for_day(return_day).iso=="2025-08-21","Calendar month, not 30 days")
		g.set_test_time(return_day,540);before=g.elapsed()
		app.show_map();expect(g.active_special_event_id==Flow.RETURN,"Map auto return")
		await play(Flow.RETURN,locale)
		expect(g.elapsed()==before+120 and g.current_absolute_clock()==660,"Flashback no rewind;120 minutes")
		for actor in Flow.ACTORS:
			expect(g.staff_is_met(actor) and g.relationship_level(actor)==3 and g.relation_for(actor).familiarity==50,"Atomic Lv3/Fam50 hire")
			expect(g.staff_contracts[actor]=={"start_day":return_day,"end_day":Flow.add_months(return_day,3)},"Three calendar months")
		expect(g.player_attributes()==attrs and g.completed_surgeries_total==0,"No unrequested surgery/XP rewards")
		app.finish_special_event_and_return()
		g.relation_for("guest_mizuho").familiarity=77
		roundtrip(g);Flow.settle(g,Flow.RETURN)
		expect(g.relation_for("guest_mizuho").familiarity==77 and g.start_special_event(Flow.RETURN)==null,"No rehire/reset/reward replay")
		# Gallery must not apply business effects.
		if not native:
			for id in [Flow.DISCHARGE,Flow.RETURN]:
				app.replay_special_gallery_entry(id);await play(id,locale,true)
			expect(g.relation_for("guest_mizuho").familiarity==77,"Gallery has no settlement")
		print("RETURN UI COMPLETE ",locale)
	# Calendar corner cases and deadline exclusion.
	var g=app.game
	expect(Flow.add_months(Flow.Calendar.day_for_iso("2025-08-31"),1)==Flow.Calendar.day_for_iso("2025-09-30"),"Month-end clamp")
	setup(g,105);expect(Flow.discharge_day(g)==119,"Delayed D moves discharge")
	done(g,Flow.DISCHARGE,Flow.Calendar.day_for_iso("2025-12-29"));g.set_test_time(273,540)
	expect(Flow.scheduled_day(g,Flow.RETURN)==-1 and g.staff_contracts.is_empty() and not g.story_flag("mizuho_medical_balance_contract_pending"),"Cannot fit contract: no half hire or financial consequences")
	print("CHIHAYA MIZUHO RETURN: ",checks," checks; ",failures," failures; ",seen," rendered nodes; native=",native)
	quit(1 if failures else 0)
