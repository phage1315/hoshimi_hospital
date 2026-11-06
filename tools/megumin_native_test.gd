extends "res://tools/miyuki_lv3_retest.gd"
const NPC = preload("res://godot/systems/megumin.gd")
var output := ""
var captured: Dictionary = {}
func button(name: String) -> Button: return app.page.find_child(name,true,false) as Button
func at(day: int, clock: int) -> void:
	app.game.story_time_advance_minutes += (day-1)*480+clock-540-app.game.elapsed()
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	expect(root.get_texture().get_image().save_png(output+"/"+name+".png")==OK,"screenshot "+name)
func play_npc(branch: String = "choice_a") -> void:
	var pages := 0
	while app.screen == "megumin_event" and pages < 300:
		expect(not app.game.can_save_progress(),"no mid-event save")
		var node: Dictionary = app.megumin_view.session.current()
		var portrait: String = str(node.get("portrait", ""))
		var capture_key: String = str(app.content.localizer.locale)+"_"+portrait
		if portrait in ["reception_proud","reception_suspicious","school_goodbye"] and not captured.has(capture_key):
			captured[capture_key]=true
			await shot(capture_key)
		if node.choices.size() > 1:
			await click(button("MeguminChoice_"+branch))
		else:
			var body = app.page.get_node_or_null("MeguminDialogue")
			expect(body != null,"dialogue rendered")
			if body != null: expect(body.get_content_height() <= body.size.y or body.scroll_active,"dialogue fits")
			await click(button("MeguminContinue"))
		pages += 1
	expect(pages < 300 and not app.game.megumin_active,"completed through GUI")
func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output=arg.trim_prefix("--out=")
	assert(not output.is_empty())
	DirAccess.make_dir_recursive_absolute(output)
	native=DisplayServer.get_name()!="headless"
	expect(native,"native renderer")
	if not native: quit(1); return
	app=load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/private/tmp/megumin_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	app.dialogue_auto_enabled=false
	for locale in ["zh_CN","en"]:
		for branch in ["choice_a","choice_b"]:
			expect(app.content.load_all(locale),"locale loads")
			app.configure_game_content()
			app.game.reset()
			# Isolated prerequisites; other fixed event reservations are not part of this fixture.
			for d in app.game.special_event_definitions.values(): d.developer_only=true; d.auto_schedule=false
			for d in app.game.character_event_definitions.values():
				if str(d.get("trigger_mode",""))=="day_start": d.trigger_mode="location"
			app.game._complete_character_event_for_test(NPC.AQUA,1)
			app.game.meet_staff("doc_aqua")
			app.game.megumin_facts={"aqua_day":1,"aqua_clock":600,"first_due_day":7,"due_day":7}
			at(7,540)
			var elapsed: int=app.game.elapsed()
			var relations: Dictionary=app.game.relationships.duplicate(true)
			app.show_map()
			await process_frame
			expect(app.screen=="megumin_event","automatic Monday intro through map")
			if app.screen!="megumin_event": quit(1);return
			await shot(locale+"_intro_"+branch)
			await play_npc(branch)
			expect(NPC.met(app.game),"intro settled")
			expect(app.game.elapsed()==elapsed and app.game.relationships==relations,"zero rewards and time")
			app.show_location("lobby",true,false,false)
			await process_frame
			expect(button("MeguminTalk")!=null,"front desk GUI entry")
			await shot(locale+"_front_desk_"+branch)
			await click(button("MeguminTalk"))
			expect(app.megumin_view.entry.get("kind")=="ambient_bark","intro-day only bark")
			await play_npc()
			at(8,600)
			app.show_location("lobby",true,false,false)
			await process_frame
			await click(button("MeguminTalk"))
			expect(app.screen=="megumin_event","next-day daily event")
			await shot(locale+"_daily_"+branch)
			await play_npc()
			# Exercise the actual existing day-transition/departure dispatch, not a direct adapter call.
			at(8,1019)
			var departure_start: int=app.game.elapsed()
			app.game.story_time_advance_minutes += 1
			app.game.settle_overtime(departure_start,1)
			app.show_day_transition(Callable(app,"show_map"))
			expect(app.screen=="megumin_event","M07 through real departure chain")
			expect(app.megumin_view.entry.content_id=="megumin_m07","first school guaranteed")
			await shot(locale+"_school_"+branch)
			await play_npc()
			expect(int(app.game.megumin_facts.first_school_day)==8,"first school settled")
			app.game.active_after_work_walk.clear()
			app.game.active_mode="encounter"
			expect(app.game.snapshot().size()>0,"safe return save")
	app.megumin_view.open_catalog(app)
	await process_frame
	await click(button("MeguminArtEntry"))
	var profile: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/npcs/megumin/profile.json"))
	for key in profile.portraits:
		await click(button("MeguminArt_"+str(key)))
		var art: TextureRect=app.page.get_node("MeguminArtPreview")
		expect(art.size.is_equal_approx(Vector2(306.6667,460)),"preview display size "+str(key))
		expect(art.position.x+art.size.x<=1280 and art.position.y+art.size.y<=800,"preview stays inside canvas "+str(key))
		expect(art.texture != null and art.texture.get_width()==1024 and art.texture.get_height()==1536,"portrait dimensions "+str(key))
		var im: Image=art.texture.get_image()
		for corner in [Vector2i(0,0),Vector2i(1023,0),Vector2i(0,1535),Vector2i(1023,1535)]:
			expect(im.get_pixelv(corner).a < 0.005,"transparent corner "+str(key))
		await shot("art_"+str(key))
	await click(button("MeguminArtExit"))
	await click(button("MeguminCatalogExit"))
	var report={"checks":checks,"failures":failures,"native":native,"scope":"isolated map intro, both choices, front desk clicks, daily, real departure chain; 15 portrait previews; two locales; synthetic mouse"}
	var f=FileAccess.open(output+"/result.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close()
	print("MEGUMIN NATIVE: ",report)
	quit(1 if failures else 0)
