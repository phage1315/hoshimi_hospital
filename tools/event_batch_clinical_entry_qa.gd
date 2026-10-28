extends "res://tools/event_batch_entry_qa.gd"
const Preop = preload("res://godot/systems/preop_session.gd")
var clinical:Array=[]
func click(control):
 await RenderingServer.frame_post_draw
 await super.click(control)
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_clinical_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  for id in ["moe_wrong_changing_room","asuka_scrub_sink_encounter","asuka_adjacent_operation_reveal"]:
   var g=app.game;var d=g.character_event_definitions[id];fixture(g,d,false);context={"event":id,"locale":locale}
   if id!="moe_wrong_changing_room":seed_done(g,"moe_wrong_changing_room")
   # Isolated admitted patient/current clinical stage. Not a from-new-game route.
   var definition=g.preop_definitions.values()[0];var visit=g.open_visit(definition.encounter_id);visit.admitted=true;visit.stage_id=visit.definition.completion
   var prep=Preop.new(definition,app.content.collections.staff,app.content.collections.surgeries,app.content.collections.patients)
   prep.stage_id="surgery_result" if id=="asuka_adjacent_operation_reveal" else "changing"
   prep.procedure_id=definition.surgery_id;prep.procedure_name=g.surgery_definition(prep.procedure_id).name;prep.surgery_success=id=="asuka_adjacent_operation_reveal"
   g.preops[definition.id]=prep;g.active_preop_id=definition.id;g.active_mode="preop";set_clock(g,10,600)
   app.show_preop(definition.id);await process_frame
   var action_buttons:Array=[]
   if id=="asuka_scrub_sink_encounter":
    for action in ["change_scrubs","scrub_hands"]:
     if app.screen=="preop_transition_video":
      var overlay=app.page.get_node_or_null("PreopTransitionVideoOverlay")
      if overlay:await click(overlay);await process_frame
     var b=app.page.get_node_or_null("PreopAction_"+action)
     if b:
      print("CLINICAL_INPUT ",locale," ",action," disabled=",b.disabled," flags=",prep.flags," rect=",b.get_global_rect())
      await create_timer(0.25).timeout
      action_buttons.append(b.text);await click(b);await process_frame
      print("CLINICAL_AFTER ",action," flags=",prep.flags," screen=",app.screen," selected=",g.next_character_event_for_preop_stage("changing").get("id",""))
   if app.screen=="preop_transition_video":
     var overlay=app.page.get_node_or_null("PreopTransitionVideoOverlay")
     if overlay:await click(overlay);await process_frame
   if id=="asuka_adjacent_operation_reveal":
    for i in range(40):
     if g.active_character_event_id==id:break
     var selected=null
     var growth=app.page.get_node_or_null("SurgeryGrowthSplash")
     if growth:selected=growth.get_node_or_null("SurgeryGrowthContinue")
     if selected==null:selected=app.page.get_node_or_null("SurgeryResultReturn")
     if selected==null and app.screen=="micro_event":
      selected=app.dialogue_default_button
      if selected==null:
       for b in app.page.find_children("MicroEventChoice_*","Button",true,false):
        if b.is_visible_in_tree() and not b.disabled:selected=b;break
     if selected==null:
      for b in app.page.find_children("*","Button",true,false):
       if b.is_visible_in_tree() and not b.disabled and (b.text.contains("返回医院") or b.text.contains("Return to Hospital") or b.text.contains("Return to hospital") or b.text.contains("继续") or b.text.contains("Continue")):selected=b;break
     if selected==null:break
     action_buttons.append(selected.text);await click(selected);await process_frame
   clinical.append({"event":id,"locale":locale,"entry_started":g.active_character_event_id==id,"screen":app.screen,"active_event":g.active_character_event_id,"fixture":"isolated clinical-stage setup; production registries retained; no complete clinical journey claim","gui_actions":action_buttons})
   await capture("clinical_stage_entry");app.game.reset();app.show_map(false)
 var f=FileAccess.open(QA+"clinical_entry_results.json",FileAccess.WRITE);f.store_string(JSON.stringify(clinical,"  "));f.close();app.queue_free();await process_frame;quit()
