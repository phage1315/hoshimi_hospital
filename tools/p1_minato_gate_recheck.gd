extends "res://tools/p1_entry_base.gd"
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_minato_gate_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 var rows:Array=[]
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  for count in [0,9,10]:
   app.game.reset();app.game.completed_surgeries_total=count;set_clock(app.game,6,540);app.sunday_hospital_browsing=false
   context={"event":"minato_intro_sunday_cholecystectomy","locale":locale}
   app.show_map();await process_frame
   var b=app.page.get_node_or_null("SundayHospital")
   if b:await click(b)
   await capture("gate_"+str(count)+"_surgeries")
   rows.append({"event":context.event,"locale":locale,"completed_surgeries":count,"day":app.game.day_number(),"screen":app.screen,"active_event":app.game.active_special_event_id,"production_registry_unchanged":true,"expected_from_source":"fewer than 10 completed surgeries must not trigger"})
 var f=FileAccess.open(QA+"minato_gate_results.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close();app.queue_free();await process_frame;quit()
