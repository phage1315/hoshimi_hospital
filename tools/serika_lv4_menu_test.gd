extends "res://tools/serika_lv4_test.gd"
func run() -> void:
	app=load("res://godot/scenes/main.tscn").instantiate();root.add_child(app)
	await process_frame
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Load "+locale);app.configure_game_content();setup_stay(app.game)
		app.show_special_events()
		var b=app.page.find_child("SpecialEvent_"+Stay.ID,true,false)
		expect(b!=null and b.text.contains("23:00") and b.text.contains("09:00"),"List shows actual continuous span")
		app.confirm_special_event(Stay.ID)
		var warnings: Array=[]
		for child in app.page.get_children():
			if child is Label and child.position==Vector2(160,225):warnings.append(child.text)
		expect(warnings.size()==1 and not str(warnings[0]).contains("不消耗") and not str(warnings[0]).contains("does not consume"),"No contradictory zero-time confirmation")
		app.game.special_event_completion_counts[Stay.ID]=1;app.game.special_event_completion_days[Stay.ID]=133
		app.show_special_gallery_entry(Stay.ID)
		var duration: Array=[]
		for child in app.page.get_children():
			if child is Label and child.position==Vector2(80,280):duration.append(child.text)
		expect(duration.size()==1 and str(duration[0]).contains("23:00") and str(duration[0]).contains("09:00"),"Gallery span accurate")
		expect(not str(duration[0]).contains("story_special_event"),"No internal category ID in gallery")
		await process_frame
		if DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(STAY_QA+locale+"_gallery.png")
	print("SERIKA LV4 MENUS: ",checks," checks; ",failures," failures")
	quit(1 if failures else 0)
