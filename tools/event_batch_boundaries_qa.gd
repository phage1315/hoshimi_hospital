extends "res://tools/event_batch_native_qa.gd"
var boundary_records:Array=[]
var initial_time=0
var initial_levels:Dictionary={}
func seed_done(g,id:String):
 if g.character_event_definitions.has(id):
  var d=g.character_event_definitions[id];var e=Character.new(d)
  e.completed=true;e.completed_day=1;e.settled_minutes=int(d.minutes)
  g.character_events[id]=e;g.character_event_order.append(id)
  g.meet_staff(d.actor_id)
  if id not in g.relation_for(d.actor_id).event_history:g.relation_for(d.actor_id).event_history.append(id)
 elif g.special_event_definitions.has(id):g.special_event_completion_counts[id]=1;g.special_event_completion_days[id]=1
func requirements(g,list:Array):
 for r in list:
  match str(r.get("type","")):
   "progress_counter":g.set_test_character_progress_counter(str(r.get("actor_id","global")),str(r.counter_id),int(r.get("minimum",0)))
   "story_flag":g.set_story_flag(str(r.get("flag","")),bool(r.get("value",true)))
   "character_event":seed_done(g,str(r.get("event_id","")))
func fixture(g,d:Dictionary,special:bool):
 g.reset()
 for key in ["skill","leadership","presence","charm","reputation"]:g.set_test_player_attribute(key,100)
 g.completed_surgeries_total=20
 var actor=str(d.get("actor_id","doc_rei"));g.meet_staff(actor)
 var rel=g.relation_for(actor);rel.familiarity=100;rel.affection=100
 if special:
  for a in d.get("required_characters",[]):
   if a!="PLAYER":g.meet_staff(a)
  for id in d.get("prerequisite_events",[]):seed_done(g,str(id))
  for reward in d.get("relationship_rewards",[]):g.relation_for(str(reward.actor_id)).level=int(reward.target_level)-1
  requirements(g,d.get("unlock_requirements",[]));g.set_test_time(maxi(10,int(d.get("timing",{}).get("trigger_day",1))),540)
 else:
  for id in d.conditions.get("required_events",[]):seed_done(g,str(id))
  rel.level=int(d.get("target_level",1))-1
  if d.category=="introduction":rel.met=false;rel.level=0
  requirements(g,d.conditions.get("special_requirements",[]))
  g.set_test_character_progress_counter("global","gynecology_case_count",5)
  var day=maxi(10,int(d.conditions.get("min_day",1)))
  if d.conditions.has("max_day"):day=mini(day,int(d.conditions.max_day))
  g.set_test_time(day,int(d.get("time_start",540)))

func prepare_route(d:Dictionary,special:bool,replay:bool):
 if not replay:fixture(app.game,d,special)
 initial_time=app.game.elapsed();initial_levels={}
 for actor in app.game.relationships:initial_levels[actor]=app.game.relationships[actor].level
func inspect(n:Dictionary,d:Dictionary,special:bool,replay:bool):
 super.inspect(n,d,special,replay)
 if not replay:
  if app.game.elapsed()!=initial_time:record_issue("early_time_settlement",str(app.game.elapsed()-initial_time))
  for actor in initial_levels:
   if app.game.relationships[actor].level!=initial_levels[actor]:record_issue("early_level_settlement",actor)
  if special:
   for flag in d.get("completion_flags",[]):
    if app.game.story_flag(flag):record_issue("early_completion_flag",flag)
func finish_route(d:Dictionary,special:bool,replay:bool,session):
 var g=app.game
 var result={"event":d.id,"locale":context.locale,"replay":replay,"completed":session.completed,"cancelled":session.cancelled if special else false,"elapsed_delta":g.elapsed()-initial_time,"screen_before_return":app.screen}
 if not replay and session.completed:
  result["configured_minutes"]=int(d.get("settled_minutes",0)) if special else int(d.minutes)
  result["levels"]={}
  for actor in initial_levels:
   if g.relationships[actor].level!=initial_levels[actor]:result.levels[actor]={"before":initial_levels[actor],"after":g.relationships[actor].level}
  if special:
   result["count"]=g.special_event_completion_counts.get(d.id,0);result["completion_flags"]={}
   for flag in d.get("completion_flags",[]):result.completion_flags[flag]=g.story_flag(flag)
  else:result["history_count"]=g.relation_for(d.actor_id).event_history.count(d.id)
  var before_time=g.elapsed();var before_rel=g.relationships.duplicate(true)
  for attempt in range(4):
   if app.screen in ["location","map","sunday","special_gallery_entry","gallery_entry"]:break
   if app.screen=="character_event_reward":
    var b=app.page.get_node_or_null("EventRewardContinue")
    if b:await click(b)
   elif app.screen=="character_event_complete":
    for b in app.page.find_children("*","Button",true,false):
     if b.text==app.tx("ui.auto.b080ed2dfa2f","返回医院导览"):await click(b);break
   elif app.screen=="special_event_complete":
    for b in app.page.find_children("*","Button",true,false):
     if b.text==app.tx("ui.special_event.return_to_hospital","返回医院  →"):await click(b);break
   else:break
   await process_frame
  result["return_screen"]=app.screen;result["return_no_repeat_time"]=g.elapsed()==before_time;result["return_no_repeat_relationship"]=g.relationships==before_rel
  result["active_character_after_return"]=g.active_character_event_id;result["active_special_after_return"]=g.active_special_event_id
 boundary_records.append(result)
func run():
 observations=FileAccess.open(QA+"boundary_pages.jsonl",FileAccess.WRITE)
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_boundaries_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 var scope=JSON.parse_string(FileAccess.get_file_as_string(QA+"scope.json"))
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  for row in scope:
   context={"event":row.id,"locale":locale};var special=row.type=="special_events";var d=(app.game.special_event_definitions if special else app.game.character_event_definitions)[row.id]
   # All branch alternatives replay through GUI; default main run checks settlement.
   await run_route(d,special,[],false,0)
   var alternatives=plans(d,app.game.special_event_step_definitions,special)
   for i in range(1,alternatives.size()):await run_route(d,special,alternatives[i],true,i)
   var f=FileAccess.open(QA+"boundary_results.json",FileAccess.WRITE);f.store_string(JSON.stringify({"routes":results,"boundaries":boundary_records,"issues":issues,"inputs":inputs},"  "));f.close()
 observations.close();app.queue_free();await process_frame;quit()
