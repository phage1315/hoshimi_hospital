extends "res://tools/megumin_native_test.gd"
func at(day: int, clock: int) -> void:
	app.game.settled_clock_offset += (day-1)*480+clock-540-app.game.elapsed()
func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output=arg.trim_prefix("--out=")
	assert(not output.is_empty())
	DirAccess.make_dir_recursive_absolute(output)
	native=DisplayServer.get_name()!="headless"
	expect(native,"native renderer")
	app=load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/private/tmp/megumin_halloween_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	app.dialogue_auto_enabled=false
	for locale in ["zh_CN","en"]:
		for aqua_present in [true,false]:
			expect(app.content.load_all(locale),"locale loads")
			app.configure_game_content();app.game.reset()
			for d in app.game.special_event_definitions.values(): d.developer_only=true;d.auto_schedule=false
			for d in app.game.character_event_definitions.values():
				if str(d.get("trigger_mode",""))=="day_start": d.trigger_mode="location"
			app.game._complete_character_event_for_test(NPC.AQUA,1);app.game.meet_staff("doc_aqua")
			var aqua: Dictionary=app.game.staff_record("doc_aqua")
			aqua.presence.fixed_locations=["lobby" if aqua_present else "or"]
			aqua.presence.random_locations=aqua.presence.fixed_locations.duplicate()
			app.game.presence_resolver=load("res://godot/systems/presence_resolver.gd").new(app.game.staff)
			app.game.megumin_facts={"introduced_day":7}
			at(214,600)
			var elapsed: int=app.game.elapsed()
			var relations: Dictionary=app.game.relationships.duplicate(true)
			var prefix: String=locale+("_aqua" if aqua_present else "_solo")
			app.show_location("lobby",true,false,false)
			await process_frame
			expect(button("MeguminTalk")!=null,"front desk talk available")
			await click(button("MeguminTalk"))
			expect(app.megumin_view.entry.content_id==NPC.HALLOWEEN,"first click reveal")
			var nodes: Array=app.megumin_view.session.definition.nodes
			expect(nodes.any(func(n):return n.actor_id=="doc_aqua")==aqua_present,"correct actual cast branch")
			expect(app.page.get_node_or_null("MeguminReceptionSign")!=null,"reception job sign")
			await shot(prefix+"_reveal")
			var pages := 0
			var moods := {}
			while app.screen=="megumin_event" and pages<150:
				var key: String=str(app.megumin_view.session.current().portrait)
				if not moods.has(key):
					moods[key]=true;await shot(prefix+"_"+key)
				expect(not app.game.can_save_progress(),"event cannot save")
				await click(button("MeguminContinue"));pages+=1
			expect(pages<150 and not app.game.megumin_active,"complete reveal via GUI")
			expect(app.game.elapsed()==elapsed and app.game.relationships==relations,"no time or relationship delta")
			expect(not app.game.megumin_facts.has("daily_day"),"normal quota unspent")
			await click(button("MeguminTalk"))
			expect(app.megumin_view.entry.content_id in ["megumin_s07","megumin_m26"],"second click old seasonal pool")
			expect(app.page.get_node("MeguminPortrait").texture.resource_path.contains("halloween_original_mage"),"old event costume override")
			await shot(prefix+"_original_micro")
			await play_npc()
			await click(button("MeguminTalk"))
			expect(app.megumin_view.entry.kind=="ambient_bark","third click bark")
			expect(app.page.get_node("MeguminPortrait").texture.resource_path.contains("halloween_original_mage"),"bark costume override")
			await play_npc()
			if not aqua_present:
				# Preview both legacy texts on the actual costume day without consuming business state.
				for legacy_id in ["megumin_s07","megumin_m26"]:
					for legacy in NPC.entries():
						if legacy.content_id!=legacy_id: continue
						app.megumin_view.testing=true
						app.megumin_view.open(app,legacy,214,Callable(app,"show_location").bind("lobby",true,false,false))
						expect(app.page.get_node("MeguminPortrait").texture.resource_path.contains("halloween_original_mage"),"legacy preview costume "+legacy_id)
						await shot(prefix+"_"+legacy_id)
						await play_npc()
			app.show_map(false)
			var save: Dictionary=app.game.snapshot()
			expect(not save.is_empty() and app.game.restore(JSON.parse_string(JSON.stringify(save))),"Oct31 safe restore")
			expect(NPC.halloween_costume_active(app.game) and NPC.choose(app.game).get("kind")=="ambient_bark","restore keeps outfit without repeat reveal")
			at(214,1019)
			var before_departure: int=app.game.elapsed()
			app.game.story_time_advance_minutes+=1
			app.game.settle_overtime(before_departure,1)
			app.show_day_transition(Callable(app,"show_map"))
			expect(app.screen=="megumin_event" and app.megumin_view.entry.content_id=="megumin_m07","actual 17:00 departure")
			expect(app.page.get_node("MeguminPortrait").texture.resource_path.contains("school_"),"17:00 school outfit")
			await shot(prefix+"_school_1700")
			await play_npc()
			app.game.active_after_work_walk.clear()
			expect(not NPC.halloween_costume_active(app.game),"no November costume")
	app.megumin_view.open_catalog(app)
	await process_frame
	await click(button("MeguminArtEntry"))
	for mood in ["neutral","proud","flustered","happy"]:
		var key: String="halloween_original_mage_"+mood
		await click(button("MeguminArt_"+key))
		var art: TextureRect=app.page.get_node("MeguminArtPreview")
		expect(art.size.is_equal_approx(Vector2(306.6667,460)),"preview display bounds")
		var im: Image=art.texture.get_image()
		expect(im.get_size()==Vector2i(1024,1536),"consistent source canvas")
		for point in [Vector2i.ZERO,Vector2i(1023,0),Vector2i(0,1535),Vector2i(1023,1535),Vector2i(512,20)]:
			expect(im.get_pixelv(point).a<0.005,"alpha and hat clearance "+key)
		await shot("art_"+mood)
	var report={"checks":checks,"failures":failures,"native":native,"scope":"two locales x both Aqua branches; front-desk GUI reveal/micro/bark; safe reload; actual 17:00 school transition; four costume previews"}
	var f=FileAccess.open(output+"/result.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close()
	print("MEGUMIN HALLOWEEN NATIVE: ",report)
	quit(1 if failures else 0)
