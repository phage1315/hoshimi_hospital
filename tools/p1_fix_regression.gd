extends "res://tools/p1_native_base.gd"
var checks=0
var failures:Array=[]
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures.append(label);push_error(label)
func run():
 observations=FileAccess.open(QA+"regression_pages.jsonl",FileAccess.WRITE)
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_p1_regression_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  var d=app.game.character_event_definitions["intro_ishigami_nurse_manager"]
  var samples:Array=["First paragraph.\n\nSecond paragraph with several words.\n\nThird paragraph.","第一段。\n\n第二段，保留原稿空行。\n\n第三段。", "Word ".repeat(120),"全文标点和顺序保持不变。".repeat(40)]
  for n in d.nodes:samples.append(n.text)
  for text_value in samples:
   var pages_=app.authored_dialogue_pages(text_value)
   check("".join(pages_)==text_value,"Exact text retained "+locale)
   for page_ in pages_:check(app.authored_dialogue_fits(page_),"Page fits both layouts "+locale)
  context={"locale":locale,"event":d.id};await run_route(d,false,[],false,0);await run_route(d,false,[],true,0)
  var target=app.game.special_event_definitions["minato_intro_sunday_cholecystectomy"]
  for day in [5,6,7,13]:
   for count in [0,9,10,11]:
    app.game.reset();app.game.set_test_time(day,540);app.game.completed_surgeries_total=count
    check(app.game.special_event_base_requirements_met(target)==(count>=10 and day in [6,13]),"Minato threshold/day "+str([day,count,locale]))
 var f=FileAccess.open(QA+"regression_results.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"routes":results,"issues":issues,"inputs":inputs},"  "));f.close();observations.close();app.queue_free();await process_frame;quit(1 if failures.size()+issues.size()>0 else 0)
