extends "res://tools/chihaya_mizuho_staff_test.gd"
const Special = preload("res://godot/systems/special_event_session.gd")
func run() -> void:
	native=DisplayServer.get_name()!="headless"
	app=load("res://godot/scenes/main.tscn").instantiate();root.add_child(app);await process_frame
	app.dialogue_auto_enabled=false
	app.content.load_all("zh_CN");app.configure_game_content();app.game.reset()
	var g=app.game
	hire(g);g.set_test_time(144,540)
	var saved: Dictionary=g.snapshot()
	expect(not saved.is_empty(),"Hired boundary available")
	for kind in ["half","mismatched","extra","fractional","missing_completion"]:
		var invalid: Dictionary=saved.duplicate(true)
		match kind:
			"half":invalid.staff_contracts.erase("guest_mizuho")
			"mismatched":invalid.staff_contracts.guest_mizuho.end_day-=1
			"extra":invalid.staff_contracts.patient_chihaya.node_id="n06_001"
			"fractional":invalid.staff_contracts.patient_chihaya.start_day=143.5
			"missing_completion":invalid.special_event_completion_counts.erase(Flow.RETURN)
		expect(not g.restore(invalid),"Reject invalid contract "+kind)
		expect(g.snapshot()==saved,"Failed load is atomic "+kind)
	var definition: Dictionary=app.content.find_record("time_events","pair_chihaya_mizuho_station")
	expect(find_presence(g,definition),"Pair presence fixture")
	app.perform_time_event(definition.id,definition.location_id)
	await click(app.dialogue_default_button)
	var turn: int=app.staff_chat_turn
	var elapsed: int=g.elapsed()
	var memory: Dictionary=g.runtime_snapshot()
	# Same memory-only channel as language switching; do not write user preferences.
	expect(app.content.load_all("en"),"Load English during chat")
	app.configure_game_content()
	expect(g.restore_runtime_snapshot(memory),"Restore chat in memory for locale change")
	app.resume_progress();await process_frame
	var translated: Dictionary=app.content.find_record("time_events",definition.id)
	var row: Dictionary=translated.dialogue_variants[g.time_log.back().variant][turn]
	expect(g.active_mode=="staff_chat" and app.staff_chat_turn==turn and g.elapsed()==elapsed,"Language resume preserves turn and elapsed time")
	expect(app.current_dialogue_text()==app.authored_dialogue_pages(row.text)[0],"Resumed English text")
	expect(g.snapshot().is_empty(),"Language change cannot open mid-chat saves")
	g.active_mode="encounter";g.active_id="";app.staff_chat_turn=0
	var clean: Dictionary=g.snapshot()
	for record in clean.time_log:
		expect(record.keys().size()==3 and not record.has("variant"),"Persistent time facts omit selected dialogue")
	var old: Dictionary=g.time_event_definitions.duplicate(true)
	g.time_event_definitions[definition.id].dialogue_variants=[]
	expect(g.restore(clean) and g.elapsed()==elapsed,"Completed chat restores without old dialogue variants")
	g.time_event_definitions=old
	if native:
		for locale in ["zh_CN","en"]:
			app.content.load_all(locale);app.configure_game_content()
			for id in [Flow.DISCHARGE,Flow.RETURN]:
				g.time_log.clear();g.set_test_time(112 if id==Flow.DISCHARGE else 143,540)
				g.active_mode="special_event";g.active_special_event_id=id
				g.active_special_event=Special.new(g.special_event_definitions[id],g.special_event_step_definitions,143)
				var nodes: Array=["d01_002","d01_029"] if id==Flow.DISCHARGE else ["n01_007","n01_009","n02_002","n04_002","n04_058","n04_082","n04_084","n05_002","n05_005"]
				for node in nodes:
					expect(g.active_special_event.jump_to(node),"Target render node exists")
					app.reset_dialogue_page();app.show_special_event()
					await process_frame;await RenderingServer.frame_post_draw
					var current: Dictionary=g.active_special_event.current()
					var bg: Dictionary=app.content.find_record("backgrounds",current.background_id)
					expect(app.page.get_node("SceneBackground").texture.resource_path=="res://"+str(bg.path),"Actual scene background mapping "+node)
					for portrait in current.event_portraits:
						expect(app.page.get_node("EventPortrait_"+str(portrait.id)).texture.resource_path=="res://"+str(portrait.path),"Actual expression mapping "+node)
					expect(root.get_texture().get_image().save_png("res://docs/qa/chihaya_mizuho_return/"+locale+"_"+node+".png")==OK,"Save outfit screenshot")
	print("RETURN BOUNDARY / LOCALE: ",checks," checks; ",failures," failures; native=",native)
	quit(1 if failures else 0)
