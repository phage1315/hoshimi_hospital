extends SceneTree
## Visual-only in-memory checkpoints after the complete flow regression.
const Event = preload("res://godot/systems/character_event_session.gd")
const QA := "res://docs/qa/miyuki_lv3/"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var app=load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/private/tmp/miyuki_lv3_visual_unused.json"
	root.add_child(app)
	await process_frame
	var checks:=0
	for locale in ["zh_CN","en"]:
		assert(app.content.load_all(locale));app.configure_game_content()
		for suffix in ["locker_room_kariya","locker_room_shiori","afternoon_good_morning"]:
			var id="miyuki_lv3_"+suffix
			var e=Event.new(app.game.character_event_definitions[id])
			app.game.character_events[id]=e;app.game.active_character_event_id=id
			var nodes=["a3_003","a3_024","a3_038","a3_047","a3_068","a3_076"] if suffix.begins_with("locker") else ["b3_038","b3_105","b3_196","b3_232"]
			for nid in nodes:
				e.node_id=nid;app.reset_dialogue_page();app.show_character_event()
				await process_frame
				var sprite=app.page.get_node("EventPortrait_nurse_yui")
				assert(sprite.texture!=null)
				assert(sprite.size.x>=350 and sprite.size.y>=500)
				assert(sprite.position.y>=90 and sprite.position.y<150)
				if nid in ["a3_038","a3_047"]:
					assert(sprite.texture.resource_path.ends_with("miyuki_uncapped_focused_hair_v2.png"))
				await RenderingServer.frame_post_draw
				assert(root.get_texture().get_image().save_png(QA+locale+"_"+id+"_"+nid+".png")==OK)
				checks+=1
	var result={"visual_checkpoints":checks,"languages":["zh_CN","en"],"failures":0,"native":DisplayServer.get_name()!="headless"}
	var f=FileAccess.open(QA+"visual.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"\t"));f.close()
	print("MIYUKI VISUAL ",JSON.stringify(result));quit()
