extends "res://tools/miyuki_lv3_test.gd"
## Supplementary isolated checkpoints, not a substitute for full GUI playback.
var output := ""
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	expect(root.get_texture().get_image().save_png(output+"/"+name+".png")==OK,"Screenshot saved")
func button_text(value: String) -> Button:
	for b in app.page.find_children("*","Button",true,false):
		if str(b.get_meta("caption_source",b.text))==value:return b
	return null
func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):output=arg.trim_prefix("--out=")
	assert(not output.is_empty());DirAccess.make_dir_recursive_absolute(output)
	native=DisplayServer.get_name()!="headless"
	app=load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/private/tmp/miyuki_returns_unused_%s.json"%OS.get_process_id()
	root.add_child(app);await process_frame;app.dialogue_auto_enabled=false
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Load locale");app.configure_game_content()
		var g=app.game
		setup(g)
		var boundary: Dictionary=g.snapshot()
		expect(not boundary.is_empty(),"Pre-event safe boundary available")
		app.show_map(false);await process_frame
		await click(app.dialogue_default_button)
		expect(g.snapshot().is_empty(),"Interrupted A cannot save")
		expect(g.restore(boundary),"Restore prior safe boundary in memory")
		app.show_map(false);await process_frame
		expect(g.active_character_event_id==Flow.A_SHIORI and g.character_events[Flow.A_SHIORI].current().id=="a3_001","A restarts from safe entry, not internal cursor")
		await shot(locale+"_restart_A")
		for id in [Flow.A_KARIYA,Flow.A_SHIORI,Flow.B]:
			setup(g)
			var e=Event.new(g.character_event_definitions[id]);e.completed=true;e.completed_day=22;e.settled_minutes=0
			g.character_events[id]=e;g.character_event_order.append(id)
			var elapsed: int=g.elapsed()
			app.replay_gallery_entry(id);await process_frame
			await click(app.dialogue_default_button)
			await click(button_text(app.tx("ui.gallery.exit_replay","退出回想")))
			expect(app.screen=="gallery_entry" and g.elapsed()==elapsed and g.relationship_level(Flow.ACTOR)==2,"Replay exit returns gallery without settlement")
			await shot(locale+"_exit_"+id)
		setup(g)
		var a=Event.new(g.character_event_definitions[Flow.A_SHIORI]);a.completed=true;a.completed_day=22;a.settled_minutes=0
		g.character_events[Flow.A_SHIORI]=a;g.character_event_order.append(Flow.A_SHIORI)
		g.set_test_time(27,540);app.show_sunday_invites();app.attempt_sunday_invitation(Flow.ACTOR)
		expect(g.active_character_event_id==Flow.B,"B through Sunday invite")
		# Isolated terminal checkpoint; full node order is covered by retest.gd.
		g.character_events[Flow.B].node_id="b3_246";app.reset_dialogue_page();app.show_character_event();await process_frame
		while app.screen=="character_event":await click(app.dialogue_default_button)
		expect(app.screen=="sunday_complete" and g.relationship_level(Flow.ACTOR)==3,"B completion page and final reward")
		await shot(locale+"_completion")
		await click(button_text(app.tx("ui.sunday.enter_monday","进入星期一  →")))
		expect(app.screen=="map" and g.current_absolute_clock()==540,"Completion returns Monday map")
		await shot(locale+"_Monday")
	var result={"checks":checks,"failures":failures,"native":native,"scope":"isolated interruption restore, replay exit, terminal completion and Monday return; zh_CN/en"}
	var f=FileAccess.open(output+"/returns.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"\t"));f.close()
	print(JSON.stringify(result));quit(1 if failures else 0)
