extends "res://tools/event_remaining_entry_qa.gd"
var checks=0
var failures:Array=[]
var boundary_results:Array=[]
func check(ok:bool,message:String):
 checks+=1
 if not ok:failures.append(message);print("BOUNDARY_FAIL ",message)
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_remaining_boundary_unused.json";root.add_child(app);await process_frame
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  for id in ["or_acceptance_training_01"]:
   var g=app.game;var d=g.special_event_definitions[id];fixture(g,d,true)
   if id=="probation_completion_personal_nurse":g.special_event_completion_counts["or_acceptance_training_01"]=1;g.special_event_completion_days["or_acceptance_training_01"]=7
   if id=="or_acceptance_training_01":
    set_clock(g,5,540);check(not g.special_event_base_requirements_met(d),"Five-day lower boundary")
    set_clock(g,6,540);check(g.special_event_timing_status(d).status=="sunday_deferred","Sunday deferral")
    set_clock(g,7,540)
   if id=="advanced_referral_tutorial_chisato":
    g.set_test_player_attribute("skill",79);check(not g.special_event_base_requirements_met(d),"Advanced skill79 blocks")
    g.set_test_player_attribute("skill",80);g.set_test_player_attribute("reputation",249);check(not g.special_event_base_requirements_met(d),"Advanced reputation249 blocks")
    g.set_test_player_attribute("reputation",250)
   print("FIXTURE_RESTORE_BEFORE ",locale," ",g.restore(g.snapshot())," ",g.last_error)
   var before=g.elapsed();var xp=g.surgery_xp;var started=g.start_special_event(id)
   check(started!=null,id+" starts")
   if started==null:continue
   for guard in range(1000):
    if started.completed:break
    check(not g.can_save_progress() and g.snapshot().is_empty(),id+" node denies persistence")
    check(g.surgery_xp==xp,id+" no early completion XP")
    var choices=started.current().get("choices",[]);var chosen=""
    for c in choices:
     if g.special_requirements_met(c.get("requirements",[])):chosen=str(c.id);break
    check(not chosen.is_empty(),id+" eligible continuation")
    if chosen.is_empty():break
    var outcome=g.choose_special_event(chosen);check(outcome.get("accepted",false),id+" choice accepted")
   check(started.completed,id+" completed")
   check(g.special_event_completion_counts.get(id,0)==1,id+" counted once")
   for flag in d.get("completion_flags",[]):check(g.story_flag(flag),id+" completion flag "+str(flag))
   var delta=g.elapsed()-before
   check(delta==(int(d.duration_days)*480 if d.get("consumes_full_day",true) else 0),id+" settled time")
   g.finish_special_event();app.show_map(false)
   var saved=g.snapshot();check(not saved.is_empty(),id+" safe map boundary")
   var settled_xp=g.surgery_xp;var settled_time=g.elapsed()
   var restored=g.restore(saved);check(restored,id+" restore settled facts in memory: "+g.last_error)
   check(g.surgery_xp==settled_xp and g.elapsed()==settled_time,id+" restore does not reward again")
   check(g.special_event_completion_counts.get(id,0)==1,id+" restored count")
   boundary_results.append({"event":id,"locale":locale,"completed":started.completed,"elapsed_delta":delta,"count":g.special_event_completion_counts.get(id,0),"restore_in_memory_only":true})
 var f=FileAccess.open("res://docs/qa/remaining_complete_events_2026-10-27/boundary_fixture_audit_results.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"events":boundary_results},"  "));f.close()
 print("BOUNDARY_LOGIC ",checks," failures=",failures.size());app.queue_free();await process_frame;quit()
