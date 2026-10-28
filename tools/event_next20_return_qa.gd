extends "res://tools/event_next20_variants_qa.gd"
var boundary_records:Array=[]
var changes:Array=[]
var initial_time=0
var initial_levels:Dictionary={}
var observed_world:Dictionary={}
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
 for key in ["skill","leadership","presence","charm","reputation"]:g.set_test_player_attribute(key,80 if key=="skill" else 100)
 g.completed_surgeries_total=20
 for person in app.content.collections.staff:
  if person.id!=d.get("actor_id",""):g.meet_staff(person.id)
 var actor=str(d.get("actor_id","doc_rei"));g.meet_staff(actor)
 var rel=g.relation_for(actor);rel.familiarity=100;rel.affection=100
 var needed:Array=d.get("unlock_requirements",[]) if special else d.conditions.get("special_requirements",[])
 for id in d.get("prerequisite_events",[]) if special else d.conditions.get("required_events",[]):seed_done(g,str(id))
 for r in needed:
  match str(r.get("type","")):
   "flag","story_flag":
    if r.flag!="staff_as_patient_program_authorized":g.set_story_flag(r.flag,bool(r.get("value",true)))
   "special_event_completed","days_after_special_event","days_after_character_event","character_event":seed_done(g,str(r.event_id))
   "relationship_level":g.relation_for(str(r.actor_id)).level=int(r.get("level",r.get("minimum",0)))
   "relationship_familiarity":g.relation_for(str(r.actor_id)).familiarity=int(r.minimum)
 if special:
  for reward in d.get("relationship_rewards",[]):g.relation_for(str(reward.actor_id)).level=int(reward.target_level)-1
 else:
  rel.level=int(d.get("target_level",1))-1
  if d.category=="introduction" or str(d.id).begins_with("serika_lv0_"):rel.met=false;rel.level=0
 var day=maxi(10,int(d.get("timing",{}).get("trigger_day",1))) if special else maxi(10,int(d.conditions.get("min_day",1)))
 if not special and d.conditions.has("max_day"):day=mini(day,int(d.conditions.max_day))
 var mode=g.special_event_trigger_mode(d) if special else g.character_event_trigger_mode(d)
 if mode=="sunday" or d.id=="minato_intro_sunday_cholecystectomy":day=13
 if g.is_hospital_closed_day(day) and mode!="sunday" and d.id!="minato_intro_sunday_cholecystectomy":day+=1
 if d.id=="intro_rumi_shiori_hiroko_monday_0900":seed_done(g,"intro_nurse_hiroko");day=14
 if str(d.id).begins_with("satsuki_lv"):
  g.set_test_player_attribute("presence",0)
  g.relation_for("nurse_satsuki").familiarity=100
  if d.id!="satsuki_lv1_real_patient_test":seed_done(g,"satsuki_lv1_real_patient_test")
 if d.id=="sayaka_lv4_hospital_callback":
  day=14;g.set_story_flag("sayaka_lv4_next_morning_callback_pending");g.set_story_flag("sayaka_lv4_callback_target_day:14")
 if special:
  for reward in d.get("relationship_rewards",[]):
   var a=str(reward.actor_id);var level=int(reward.target_level);g.relation_for(a).familiarity=100
   for rank in range(1,level):
    var slot=g.relationship_rank_slot(a,rank);var previous=str(slot.get("event_id",""))
    if not previous.is_empty():
     seed_done(g,previous)
     if previous not in g.relation_for(a).rank_history:g.relation_for(a).rank_history.append(previous)
 if d.id=="satsuki_lv3_wrong_patient_appendectomy":g.set_test_player_attribute("presence",-30)
 if mode=="sunday":
  g.set_story_flag("sayaka_phone_exchanged");g.set_story_flag("sayaka_sunday_invite_available")
 if d.id=="serika_lv0_c":g.relation_for("nurse_yui").level=1
 if str(d.id).begins_with("serika_radiology_d"):
  var index=int(str(d.id).right(2));g.meet_staff("doc_serika");g.relation_for("doc_serika").familiarity=0
  for j in range(1,index):seed_done(g,"serika_radiology_d%02d"%j)
  for level in range(1,3):
   if index>=6 if level==1 else index>=11:
    var slot=g.relationship_rank_slot("doc_serika",level);var event_id=str(slot.event_id)
    seed_done(g,event_id);g.relation_for("doc_serika").rank_history.append(event_id);g.relation_for("doc_serika").level=level
  # Select an actually present day through production deterministic scheduling.
  for candidate in range(20,40):
   set_clock(g,candidate,540)
   if not g.is_hospital_closed_day(candidate) and preload("res://godot/systems/serika_radiology.gd").naturally_present(g):day=candidate;break
 var hour=int(d.get("timing",{}).get("time_start",540)) if special else int(d.get("time_start",540))
 if mode=="after_work":hour=maxi(hour,960)
 set_clock(g,day,hour)

func world_observation():
 var levels={}
 for actor in app.game.relationships:levels[actor]=app.game.relationships[actor].level
 return {"elapsed":app.game.elapsed(),"levels":levels,"flags":app.game.story_flags.duplicate(true),"skill_xp":app.game.surgery_xp,"leadership_xp":app.game.leadership_xp}
func prepare_route(d:Dictionary,special:bool,replay:bool):
 fixture(app.game,d,special)
 initial_time=app.game.elapsed();initial_levels={}
 for actor in app.game.relationships:initial_levels[actor]=app.game.relationships[actor].level
 observed_world=world_observation()
func inspect(n:Dictionary,d:Dictionary,special:bool,replay:bool):
 super.inspect(n,d,special,replay)
 var now=world_observation()
 if now!=observed_world:
  var delta=context.duplicate();delta["observed_at_node"]=n.id;delta["changed_fields"]=[]
  for field in now:
   if now[field]!=observed_world[field]:delta.changed_fields.append(field)
  delta["elapsed_delta"]=now.elapsed-observed_world.elapsed
  changes.append(delta)
 observed_world=now
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
  result["completion_labels"]=label_texts()
  var before_time=g.elapsed();var before_rel=g.relationships.duplicate(true)
  for attempt in range(8):
   if app.screen in ["location","map","sunday","special_gallery_entry","gallery_entry"]:break
   if app.screen=="character_event_reward":
    var b=app.page.get_node_or_null("EventRewardContinue")
    if b:await click(b)
   elif app.screen=="character_event_complete":
    for b in app.page.find_children("*","Button",true,false):
     if b.is_visible_in_tree() and not b.disabled and b.position.y==475:await click(b);break
   elif app.screen=="special_event_complete":
    for b in app.page.find_children("*","Button",true,false):
     if b.text==app.tx("ui.special_event.return_to_hospital","返回医院  →"):await click(b);break
   elif app.screen in ["day_transition","sunday_complete"]:
    for b in app.page.find_children("*","Button",true,false):
     if b.is_visible_in_tree() and not b.disabled and b.position.y==465:await click(b);break
   else:break
   await process_frame
  result["return_time_delta"]=g.elapsed()-before_time;result["return_screen"]=app.screen;result["return_no_repeat_time"]=g.elapsed()==before_time;result["return_no_repeat_relationship"]=g.relationships==before_rel
  result["active_character_after_return"]=g.active_character_event_id;result["active_special_after_return"]=g.active_special_event_id
 result["can_save_after_return"]=g.can_save_progress()
 result["return_labels"]=label_texts()
 boundary_records.append(result)

func run():
 observations=FileAccess.open(QA+"return_pages.jsonl",FileAccess.WRITE)
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_next_boundaries_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 var scope=JSON.parse_string(FileAccess.get_file_as_string(QA+"scope.json"))
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  for row in scope:
   if row.id not in ["sayaka_lv1_first_date","sayaka_lv3_relationship","sayaka_lv5_part_a","sayaka_lv5_part_b","minato_intro_sunday_cholecystectomy"]:continue
   context={"event":row.id,"locale":locale};var special=row.type=="special_events";var d=(app.game.special_event_definitions if special else app.game.character_event_definitions)[row.id]
   await run_route(d,special,[],false,999)
   var f=FileAccess.open(QA+"return_results.json",FileAccess.WRITE);f.store_string(JSON.stringify({"routes":results,"boundaries":boundary_records,"world_change_observations":changes,"issues":issues,"inputs":inputs},"  "));f.close()
 observations.close();app.queue_free();await process_frame;quit()
