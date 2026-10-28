extends "res://tools/game_random_40_screens.gd"
const OUT="res://docs/qa/preop_anesthesia_intraop_10_2026-10-27/"
func shot(category:String,description:String,identity:Dictionary):
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 var filename="%02d_%s_zh_CN.png"%[shots.size()+1,category]
 root.get_texture().get_image().save_png(OUT+filename)
 shots.append({"file":filename,"category":category,"description":description,"locale":"zh_CN","screen":app.screen,"selection":identity})
 print("CAPTURE ",shots.size()," ",description)
func run():
 rng.randomize()
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_extra10_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 for i in range(10):
  reset_scene("zh_CN")
  var g=app.game;var d=pick(g.preop_definitions.values())
  var prep=Preop.new(d,app.content.collections.staff,app.content.collections.surgeries,app.content.collections.patients,[],false,app.content.collections.surgery_team_dialogue_profiles,app.content.collections.patient_interactions,app.content.collections.temporary_conditions,[],false,app.content.collections.palpation_profiles,app.content.collections.awake_special_barks)
  var surgeries=app.content.collections.surgeries.filter(func(s):return s.get("status","ready")!="placeholder" and not s.get("stages",[]).is_empty())
  var surgery=pick(surgeries);prep.procedure_id=surgery.id;prep.procedure_name=surgery.name;prep.initialize_procedure_state()
  prep.team={"assistant_surgeon":"doc_aoi","scrub_nurse":"nurse_haru","circulating_nurse":"nurse_rin"}
  var category="palpation" if i<3 else "anesthesia" if i<6 else "intraop"
  if i<3:prep.stage_id="or_table_palpation"
  elif i==3:prep.stage_id="general_induction";prep.flags.append("general_anesthesia");prep.anesthesia="全身麻醉"
  elif i<6:prep.stage_id="anesthesia_sensory_test";prep.flags.append("epidural_anesthesia" if i==4 else "local_anesthesia");prep.anesthesia="硬膜外麻醉" if i==4 else "局部麻醉"
  else:
   prep.stage_id="procedure_flow";prep.flags.assign(["patient_prepared","surgery_started","general_anesthesia","incision_made"]);prep.anesthesia="全身麻醉"
   prep.operative_background_id="operating_team_%02d"%(i-5)
   prep.procedure_step_index=mini(i-6,prep.surgery_flow_steps().size()-1)
  g.preops[d.id]=prep;g.active_preop_id=d.id;g.active_mode="preop";app.screen="preop";app.PreopView.render(app,prep);await process_frame
  if i in [1,2,4,5]:
   if i==5:await click(app.page.get_node_or_null("PalpationTool_needle"))
   await click(app.page.get_node_or_null("PalpationHotspot_abdomen_0"))
  await shot(category,prep.patient_name+" / "+prep.procedure_name+" / "+prep.stage_id,{"preop":d.id,"procedure":surgery.id,"stage":prep.stage_id,"step":prep.procedure_step_index})
 var f=FileAccess.open(OUT+"manifest.json",FileAccess.WRITE);f.store_string(JSON.stringify({"count":shots.size(),"method":"Chinese native isolated scene sampling; no player slots; not full route acceptance","screenshots":shots},"  "));f.close()
 print("CAPTURE_DONE 10")
 quit()
