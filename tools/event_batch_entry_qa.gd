extends "res://tools/event_batch_native_qa.gd"
# Entry probes retain the entire production definition registry and scheduler.
# Prerequisite completions and numeric facts are isolated synthetic fixtures.
var entries:Array=[]
func seed_done(g,id:String):
 if g.character_event_definitions.has(id):
  var d=g.character_event_definitions[id];var e=Character.new(d)
  e.completed=true;e.completed_day=1;e.settled_minutes=int(d.minutes)
  g.character_events[id]=e;g.character_event_order.append(id)
  g.meet_staff(d.actor_id)
  if id not in g.relation_for(d.actor_id).event_history:g.relation_for(d.actor_id).event_history.append(id)
 elif g.special_event_definitions.has(id):g.special_event_completion_counts[id]=1;g.special_event_completion_days[id]=1
func set_clock(g,day:int,clock:int):
 g.set_test_time(day,clock)
 var desired=(day-1)*480+clampi(clock,540,1019)-540
 g.story_time_advance_minutes+=desired-g.elapsed()
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
  requirements(g,d.get("unlock_requirements",[]));set_clock(g,maxi(10,int(d.get("timing",{}).get("trigger_day",1))),540)
 else:
  for id in d.conditions.get("required_events",[]):seed_done(g,str(id))
  rel.level=int(d.get("target_level",1))-1
  if d.category=="introduction":rel.met=false;rel.level=0
  requirements(g,d.conditions.get("special_requirements",[]))
  g.set_test_character_progress_counter("global","gynecology_case_count",5)
  var day=maxi(10,int(d.conditions.get("min_day",1)))
  if d.conditions.has("max_day"):day=mini(day,int(d.conditions.max_day))
  set_clock(g,day,int(d.get("time_start",540)))
func available(g,d,special):return g.special_event_available(d) if special else g.character_event_available(d)
func run():
 if DisplayServer.get_name()=="headless":quit(2);return
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_entry_never_written_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 var scope=JSON.parse_string(FileAccess.get_file_as_string(QA+"scope.json"))
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  for row in scope:
   var g=app.game;var special=row.type=="special_events";var d=(g.special_event_definitions if special else g.character_event_definitions)[row.id]
   fixture(g,d,special)
   context={"locale":locale,"event":row.id}
   var record={"event":row.id,"locale":locale,"fixture":"synthetic settled prerequisite facts; full production registry; no target override flags","available":available(g,d,special),"day":g.day_number(),"clock":g.current_absolute_clock(),"mode":g.special_event_trigger_mode(d) if special else g.character_event_trigger_mode(d),"candidates":[],"entry_started":false,"boundary_checks":{}}
   if not special:
    record["rank_gate"]=g.relationship_rank_gate_evaluation(d.actor_id,int(d.target_level));record["conditions"]=d.conditions;record["location"]=d.location_id;record["time_start"]=d.time_start;record["time_end"]=d.time_end;record["priority"]=d.priority
    if record.mode=="location":
     for c in g.character_events_at(d.location_id):record.candidates.append(c.id)
     var day=g.day_number()
     if int(d.time_start)>540:
      set_clock(g,day,int(d.time_start)-1);record.boundary_checks["before_open_absent"]=not g.character_events_at(d.location_id).any(func(c):return c.id==d.id)
     if int(d.time_end)<1019:
      set_clock(g,day,int(d.time_end)+1);record.boundary_checks["after_close_absent"]=not g.character_events_at(d.location_id).any(func(c):return c.id==d.id)
     else:record.boundary_checks["after_close"]="outside playable shift; not probed by clamping helper"
     fixture(g,d,false)
     app.show_location(d.location_id);await process_frame
     if g.active_character_event_id!=d.id:
      for button in app.page.find_children("*","Button",true,false):
       if button.is_visible_in_tree() and not button.disabled and (button.text.contains(str(d.teaser)) or str(button.name)=="CharacterEventStart_"+str(d.id)):
        await click(button);break
     record.entry_started=g.active_character_event_id==d.id
     record["actual_active_character"]=g.active_character_event_id;record["actual_active_special"]=g.active_special_event_id
     var preempted:Array=[]
     for retry in range(5):
      if record.entry_started or g.active_character_event_id.is_empty():break
      preempted.append(g.active_character_event_id)
      fixture(g,d,false)
      for prior in preempted:seed_done(g,prior)
      set_clock(g,day,int(d.time_start));app.show_location(d.location_id);await process_frame
      if g.active_character_event_id!=d.id:
       for button in app.page.find_children("*","Button",true,false):
        if button.is_visible_in_tree() and not button.disabled and button.text.contains(str(d.teaser)):await click(button);break
      record.entry_started=g.active_character_event_id==d.id
     record["additional_completed_fixture_facts"]=preempted
     record["final_active_character"]=g.active_character_event_id
    elif record.mode=="day_start":record["selected"]=g.next_day_start_character_event().get("id","")
    elif record.mode=="preop_stage":record["limitation"]="Requires clinical-stage fixture and real preop-return input; content test is separate"
    elif record.mode=="after_work":record["selected"]=g.next_after_work_character_event().get("id","")
   else:
    record["timing"]=g.special_event_timing_status(d);record["selected"]=g.next_auto_special_event().get("id","")
   if record.entry_started:await capture("formal_entry")
   record["screen"]=app.screen
   entries.append(record);print("ENTRY ",JSON.stringify(record))
   app.show_map(false)
   for child in app.get_children():
    if child is Window:child.hide()
 var f=FileAccess.open(QA+"entry_results.json",FileAccess.WRITE);f.store_string(JSON.stringify(entries,"  "));f.close();app.queue_free();await process_frame;quit()
