extends "res://tools/event_next20_native_qa.gd"
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
   if not record.entry_started and record.mode!="preop_stage":
    fixture(g,d,special)
    if record.mode=="location":app.show_location(d.get("location_id","station"))
    elif record.mode=="interaction":
     app.location_staff_drawer_open="imaging";app.show_location("imaging",true,false)
     var btn=app.page.find_child("SerikaRadiologyDiscussion",true,false)
     if btn:await click(btn)
    elif record.mode=="sunday":
     app.show_sunday_invites()
     var btn=app.page.find_child("SundayCandidate_doc_sayaka",true,false)
     if btn:await click(btn)
    else:
     app.show_map(record.mode=="day_start")
     if record.mode=="after_work":
      app.show_player_office();await process_frame
      var btn=app.page.get_node_or_null("OfficeEndWorkday")
      if btn:await click(btn)
    await process_frame
    if d.id=="minato_intro_sunday_cholecystectomy" and app.screen=="sunday_menu":
     await click(app.page.get_node("SundayHospital"));await process_frame
    if special and app.screen=="map":
     for btn in app.page.find_children("*","Button",true,false):
      if btn.text.contains(str(d.title)):await click(btn);break
    if app.screen in ["special_event_confirm","sayaka_lv4_precommit"]:
     for btn in app.page.find_children("*","Button",true,false):
      if btn.text==app.tx("ui.auto.b638db7ded07","开始活动") or btn.text==app.tx("ui.sayaka_lv4.accept","继续约会"):await click(btn);break
    record.entry_started=(g.active_special_event_id==d.id if special else g.active_character_event_id==d.id)
    record["actual_active_character"]=g.active_character_event_id;record["actual_active_special"]=g.active_special_event_id
   if record.entry_started:await capture("formal_entry")
   record["screen"]=app.screen
   entries.append(record);print("ENTRY ",JSON.stringify(record))
   app.show_map(false)
   for child in app.get_children():
    if child is Window:child.hide()
 var f=FileAccess.open(QA+"entry_results.json",FileAccess.WRITE);f.store_string(JSON.stringify(entries,"  "));f.close();app.queue_free();await process_frame;quit()
