extends "res://tools/event_batch_native_qa.gd"
func run():
 if DisplayServer.get_name()=="headless":push_error("Native window required");quit(2);return
 observations=FileAccess.open(QA+"hiroko_recheck_pages.jsonl",FileAccess.WRITE)
 app=load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path="/tmp/hoshimi_batch_qa_never_written_"+str(OS.get_process_id())+".json"
 root.add_child(app);await process_frame
 var scope=JSON.parse_string(FileAccess.get_file_as_string(QA+"scope.json"))
 var filter=["hiroko_lv1_worth_it"]
 for locale in ["zh_CN","en"]:
  if not app.content.load_all(locale):print("LOAD_FAILED ",app.content.errors);continue
  app.configure_game_content()
  for row in scope:
   if not filter.is_empty() and str(row.id) not in filter:continue
   context={"event":row.id,"locale":locale}
   var special=row.type=="special_events"
   var definition:Dictionary=(app.game.special_event_definitions if special else app.game.character_event_definitions)[row.id]
   var routes=plans(definition,app.game.special_event_step_definitions,special)
   for i in range(routes.size()):await run_route(definition,special,routes[i],false,i)
   await run_route(definition,special,[],true,0)
   var f=FileAccess.open(QA+"hiroko_recheck_results.json",FileAccess.WRITE);f.store_string(JSON.stringify({"display_server":DisplayServer.get_name(),"routes":results,"issues":issues,"inputs":inputs,"pages":pages,"screenshots":shot_count,"player_slots_accessed":false},"  "));f.close()
 observations.close();app.queue_free();await process_frame;quit()
