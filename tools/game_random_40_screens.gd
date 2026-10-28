extends "res://tools/p1_native_base.gd"
# Stratified random UI sampling, isolated scenes; no saved/restorable session state.
const Preop = preload("res://godot/systems/preop_session.gd")
var rng=RandomNumberGenerator.new()
var shots:Array=[]
var used:Dictionary={}
func pick(values:Array):return values[rng.randi_range(0,values.size()-1)]
func reset_scene(locale:String):
 app.content.load_all(locale);app.configure_game_content();app.game.reset();app.reset_clinic_view();app.reset_dialogue_page();app.dialogue_auto_enabled=false
 for child in app.get_children():
  if child is Window:child.hide()
 app.show_map(false)
func shot(category:String,description:String,identity:Dictionary):
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 var number=shots.size()+1;var filename="%02d_%s_%s.png"%[number,category,app.content.localizer.locale]
 root.get_texture().get_image().save_png(QA+"screenshots/"+filename)
 var row={"number":number,"file":filename,"category":category,"description":description,"locale":app.content.localizer.locale,"screen":app.screen,"selection":identity,"mode":"isolated native scene sampling, not an end-to-end route acceptance"}
 row["resources"]=[]
 for c in app.page.find_children("*","TextureRect",true,false):
  if c.texture:row.resources.append({"widget":str(c.name),"path":c.texture.resource_path})
 shots.append(row);print("CAPTURE ",number," ",category," ",description)
func event_scene(eid:String,nid:String,special:bool):
 var g=app.game
 if special:
  var d=g.special_event_definitions[eid];var session=Special.new(d,g.special_event_step_definitions,1)
  for i in range(d.event_chain.size()):
   if g.special_event_step_definitions[d.event_chain[i]].nodes.any(func(n):return n.id==nid):session.step_index=i;break
  session.node_id=nid;g.active_special_event=session;g.active_special_event_id=eid;g.active_mode="special_event";app.show_special_event()
 else:
  var d=g.character_event_definitions[eid];var session=Character.new(d);session.node_id=nid;g.character_events[eid]=session;g.character_event_order.append(eid);g.active_character_event_id=eid;g.active_mode="character_event";app.show_character_event()
func run():
 rng.randomize();var sample_seed=rng.seed
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_40_screens_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 for category in ["clinic","surgery","cg","event","date"]:
  for i in range(8):
   var locale="zh_CN" if i%2==0 else "en";reset_scene(locale)
   var g=app.game
   if category=="clinic":
    var definitions=g.definitions.values();var d=pick(definitions)
    while used.has(d.id):d=pick(definitions)
    used[d.id]=true
    var visit=g.open_visit(d.id);var stages=["reception","history","exam","tests","diagnosis","plan"]
    var stage=stages[i%stages.size()];visit.stage_id=stage
    app.show_encounter(d.id)
    await shot(category,str(app.content.find_record("patients",d.patient_id).name)+" / "+stage,{"encounter":d.id,"stage":stage})
   elif category=="surgery":
    var d=pick(g.preop_definitions.values());var prep=Preop.new(d,app.content.collections.staff,app.content.collections.surgeries,app.content.collections.patients,[],false,app.content.collections.surgery_team_dialogue_profiles,app.content.collections.patient_interactions,app.content.collections.temporary_conditions)
    var procedure=app.content.collections.surgeries.filter(func(s):return s.get("status","ready")!="placeholder" and not s.get("stages",[]).is_empty())
    var surgery=pick(procedure);prep.procedure_id=surgery.id;prep.procedure_name=surgery.name;prep.initialize_procedure_state();prep.team={"assistant_surgeon":"doc_aoi","scrub_nurse":"nurse_haru","circulating_nurse":"nurse_rin"}
    var stages=["team","preparation","operating_room","procedure_select","surgery_start_epidural","procedure_flow","procedure_flow","surgery_result"]
    prep.stage_id=stages[i]
    if i>=4:prep.flags.assign(["patient_prepared","surgery_started","epidural"])
    if i in [5,6]:prep.procedure_step_index=rng.randi_range(0,prep.surgery_flow_steps().size()-1)
    if i==7:prep.surgery_success=true
    g.preops[d.id]=prep;g.active_preop_id=d.id;g.active_mode="preop";app.screen="preop";app.PreopView.render(app,prep)
    await shot(category,prep.patient_name+" / "+prep.procedure_name+" / "+prep.stage_id,{"preop":d.id,"procedure":surgery.id,"stage":prep.stage_id,"step":prep.procedure_step_index})
   elif category in ["cg","event"]:
    var candidates:Array=[]
    for d in g.character_event_definitions.values():
     for n in d.nodes:
      if (not str(n.get("cg_path","")).is_empty())==(category=="cg") and n.get("presentation","")!="stage" and not n.has("action"):
       var key=str(n.get("cg_path","")) if category=="cg" else str(d.id)
       if not used.has(category+key):candidates.append({"event":d.id,"node":n.id,"special":false,"key":key})
    if category=="cg":
     for d in g.special_event_definitions.values():
      for sid in d.event_chain:
       for n in g.special_event_step_definitions[sid].nodes:
        if not str(n.get("cg_path","")).is_empty() and not used.has(category+str(n.cg_path)):candidates.append({"event":d.id,"node":n.id,"special":true,"key":str(n.cg_path)})
    var selected=pick(candidates);used[category+str(selected.key)]=true;event_scene(selected.event,selected.node,selected.special)
    await shot(category,str(selected.event)+" / "+str(selected.node),selected)
   else:
    var actors:Array=[]
    for actor in g.date_profile_definitions:
     var p=g.date_profile_definitions[actor]
     if p.get("can_date",false) and not used.has("date"+actor):actors.append(actor)
    var actor=pick(actors);used["date"+actor]=true;var p=g.date_profile_definitions[actor]
    g.meet_staff(actor);g.relation_for(actor).level=5;g.relation_for(actor).familiarity=100;g.set_test_time(6,540)
    for flag in p.get("required_flags",[]):g.relation_for(actor).flags.append(flag)
    for campaign in range(1,1001):
     g.campaign_seed=campaign
     if g.sunday_invitation_will_accept(actor):break
    app.show_sunday_date_locations(actor);await process_frame
    var locations=g.sunday_date_locations();var location=pick(locations);var button=app.page.get_node_or_null("SundayDateLocation_"+str(location.id))
    if button:await click(button)
    await shot(category,str(app.content.find_record("staff",actor).name)+" / "+str(location.name),{"actor":actor,"location":location.id})
 var f=FileAccess.open(QA+"screenshots/manifest.json",FileAccess.WRITE);f.store_string(JSON.stringify({"sampling_seed":str(sample_seed),"count":shots.size(),"method":"8 per category, random cases/actors/nodes/CGs within each; 20 Chinese and 20 English; native runtime; no player slots","screenshots":shots},"  "));f.close()
 print("CAPTURE_DONE count=",shots.size()," seed=",sample_seed," pid=",OS.get_process_id())
 # Leave an isolated playable title screen open for the user.
 reset_scene("zh_CN");app.title_screen()
