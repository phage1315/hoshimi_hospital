extends "res://tools/event_next20_entry_qa.gd"
var records:Array=[]
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_gallery_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 var scope=JSON.parse_string(FileAccess.get_file_as_string(QA+"scope.json"))
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  for row in scope:
   app.game.reset();context={"locale":locale,"event":row.id};seed_done(app.game,row.id)
   var special=row.type=="special_events"
   if special and not app.game.special_event_definitions[row.id].get("gallery_unlock",false):
    records.append({"event":row.id,"locale":locale,"replay_started_via_gui":false,"gallery_availability":"disabled by authored event definition"});continue
   if str(row.id).begins_with("serika_radiology_"):
    records.append({"event":row.id,"locale":locale,"replay_started_via_gui":false,"gallery_availability":"excluded by production radiology design"});continue
   if special:app.show_special_gallery_entry(row.id)
   else:app.show_gallery_entry(row.id)
   await RenderingServer.frame_post_draw
   var record={"event":row.id,"locale":locale,"gallery_screen":app.screen,"gallery_labels":label_texts(),"replay_started_via_gui":false}
   var before_time=app.game.elapsed();var before_rel=app.game.relationships.duplicate(true)
   for btn in app.page.find_children("*","Button",true,false):
    if btn.position.x==60 and btn.position.y==(630 if special else 520):await click(btn);break
   record.replay_started_via_gui=app.screen in ["gallery_replay","special_gallery_replay"]
   if record.replay_started_via_gui:
    for btn in app.page.find_children("*","Button",true,false):
     if btn.text==app.tx("ui.gallery.exit_replay","退出回想"):await click(btn);break
   record["exit_screen"]=app.screen;record["time_unchanged"]=app.game.elapsed()==before_time;record["relationships_unchanged"]=app.game.relationships==before_rel
   if str(row.id).begins_with("serika_radiology_"):record["gallery_availability"]="Production gallery explicitly excludes radiology; direct entry page is a diagnostic probe only."
   record["overlays"]=[]
   for child in app.get_children():
    if child is CanvasLayer:record.overlays.append(str(child.name))
   records.append(record)
   await create_timer(1.0).timeout
 var f=FileAccess.open(QA+"gallery_results.json",FileAccess.WRITE);f.store_string(JSON.stringify(records,"  "));f.close();app.queue_free();await process_frame;quit()
