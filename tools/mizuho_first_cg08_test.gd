extends "res://tools/mizuho_first_surgery_test.gd"

func node_sequence() -> Array[String]:
	var ids: Array[String]=[]
	for i in range(1,28):ids.append("b01_%03d" % i)
	return ids

func inspect_frame(_node: Dictionary, _locale: String, _gallery: bool, _first_page: bool) -> void:
	pass

func run() -> void:
	native=DisplayServer.get_name()!="headless"
	var approved: Dictionary={}
	for number in ["02","03","08","09"]:
		var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://research/imports/mizuho_first_surgery_cg%s_approved_2026-10-28.json" % number))
		for id in manifest.nodes:approved[id]=manifest.destination
	for row in JSON.parse_string(FileAccess.get_file_as_string("res://docs/source/mizuho_first_surgery/parsed_source.json")):sources[str(row.id)]=row
	app=load("res://godot/scenes/main.tscn").instantiate();root.add_child(app);await process_frame
	app.dialogue_auto_enabled=false
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Localized content loads");app.configure_game_content()
		for gallery in [false,true]:
			setup(app.game);done(app.game,Flow.A,102);done(app.game,Flow.S,103)
			app.game.set_test_time(105,540)
			if gallery:
				done(app.game,Flow.B,105);app.replay_special_gallery_entry(Flow.B)
			else:app.show_map()
			var before: int=app.game.elapsed()
			for expected_id in node_sequence():
				var event=app.special_event_gallery_replay if gallery else app.game.active_special_event
				expect(event!=null,"Actual event entry exists")
				if event==null:quit(1);return
				var node: Dictionary=event.current();var step: Dictionary=event.current_step()
				expect(node.id==expected_id,"Entry and exit follow authored order")
				expect(str(node.get("cg_path",""))==str(approved.get(expected_id,"")),"CG matches approved file and range")
				var pages: Array=app.authored_dialogue_pages(app.special_event_localized_text(step,node))
				for page in pages:
					await process_frame
					cast(node,str(step.id),locale)
					expect(app.current_dialogue_text()==page,"Localized dialogue exact")
					if not gallery:expect(not app.game.can_save_progress() and app.game.snapshot().is_empty(),"No event save")
					await inspect_frame(node,locale,gallery,page==pages[0])
					# Exercise actual Continue controls, without changing player preferences or saves.
					expect(is_instance_valid(app.dialogue_default_button) and not app.dialogue_default_button.disabled,"Continue enabled")
					app.dialogue_default_button.emit_signal("pressed");await process_frame
				seen+=1
				expect(app.game.elapsed()==before,"CG does not change elapsed time")
				if failures:quit(1);return
	print("MIZUHO CG RANGE: ",checks," checks; ",failures," failures; ",seen," CN/EN main/gallery nodes; native=",native)
	quit(1 if failures else 0)
