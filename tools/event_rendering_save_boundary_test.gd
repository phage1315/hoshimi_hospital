extends "res://tools/event_batch_entry_qa.gd"
var failures=0
var checks=0
func expect(ok:bool,message:String):
 checks+=1
 if not ok:failures+=1;push_error(message)
func no_inner(value):
 if value is Dictionary:
  for k in value:
   expect(str(k) not in ["node_id","choices","last_choice","dialogue_page_index","step_index","quote_index","quote_actor_ids"],"Persistent contract contains inner state: "+str(k))
   no_inner(value[k])
 elif value is Array:
  for item in value:no_inner(item)
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_fact_boundary_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 var g=app.game;var d=g.special_event_definitions.miyama_03_or_god;var current_step=g.special_event_step_definitions.miyama_03_or_god_main
 var original_step:Dictionary={}
 var previous_steps=JSON.parse_string(FileAccess.get_file_as_string("res://docs/qa/event_rendering_fixes_2026-10-27/special_event_steps.json.before"))
 for step in previous_steps:
  if step.id=="miyama_03_or_god_main":
   original_step=step;g.special_event_step_definitions[step.id]=step
 fixture(g,d,true)
 # Leave headroom for Lv3 skill XP; max-level synthetic fixtures exceed restore caps after rewards.
 g.set_test_player_attribute("skill",80)
 expect(g.start_special_event(d.id)!=null,"Old event fixture failed ordinary eligibility")
 expect(not g.can_save_progress(),"Saving allowed inside event")
 for i in range(100):
  if not g.special_event_in_progress():break
  var result=g.choose_special_event(g.active_special_event.current().choices[0].id)
  expect(result.accepted,"Old definition could not finish")
 expect(g.special_event_completion_counts.get(d.id,0)==1,"Completion count incorrect")
 expect(g.relationship_level("doc_rei")==3,"Lv3 did not settle")
 g.finish_special_event();app.show_map(false)
 expect(g.can_save_progress(),"Completed event did not reach save boundary")
 var before_time=g.elapsed();var before_relation=g.relationships.duplicate(true);var before_flags=g.story_flags.duplicate(true);var before_surgeries=g.completed_surgeries_total
 # Only in-memory persistence-contract dictionaries; never saved to any file.
 var facts=g.snapshot();no_inner(facts)
 g.special_event_step_definitions.miyama_03_or_god_main=current_step
 g.reset();expect(g.restore(facts),"Old completion facts failed with split nodes: "+g.last_error)
 expect(g.elapsed()==before_time,"Restore changed settled time")
 expect(JSON.parse_string(JSON.stringify(g.relationships))==JSON.parse_string(JSON.stringify(before_relation)),"Restore changed relationship rewards")
 expect(g.story_flags==before_flags,"Restore changed stable flags")
 expect(g.completed_surgeries_total==before_surgeries,"Restore repeated surgery reward")
 expect(g.special_event_completion_counts.get(d.id,0)==1,"Restore repeated event completion")
 var again=g.snapshot();no_inner(again);expect(g.restore(again),"Second restore failed")
 expect(g.elapsed()==before_time and JSON.parse_string(JSON.stringify(g.relationships))==JSON.parse_string(JSON.stringify(before_relation)) and g.completed_surgeries_total==before_surgeries,"Repeated restore changed settled results")
 # Compare completion facts across every branch-covering route in old/new definitions.
 var old_outcomes:Array=[]
 for variant in [original_step,current_step]:
  g.special_event_step_definitions.miyama_03_or_god_main=variant
  var routes=plans(d,g.special_event_step_definitions,true)
  for route_index in range(routes.size()):
   fixture(g,d,true);g.set_test_player_attribute("skill",80)
   expect(g.start_special_event(d.id)!=null,"Branch fixture could not start")
   var plan:Array=routes[route_index];var advance=0
   for guard in range(100):
    if not g.special_event_in_progress():break
    expect(g.relationship_level("doc_rei")==2,"Reward settled before event completion")
    var choice_id=str(plan[advance]) if advance<plan.size() else str(g.active_special_event.current().choices[0].id)
    expect(g.choose_special_event(choice_id).accepted,"Branch choice rejected")
    advance+=1
   var outcome=JSON.parse_string(JSON.stringify({"elapsed":g.elapsed(),"relationships":g.relationships,"flags":g.story_flags,"surgeries":g.completed_surgeries_total,"counts":g.special_event_completion_counts,"xp":g.surgery_xp}))
   if variant==original_step:old_outcomes.append(outcome)
   else:expect(outcome==old_outcomes[route_index],"Split nodes changed branch settlement")
 print("EVENT RENDERING SAVE BOUNDARY ",checks," checks; ",failures," failures; no files written")
 app.queue_free();await process_frame;quit(1 if failures else 0)
