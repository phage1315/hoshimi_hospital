extends SceneTree
const M=preload("res://godot/systems/advanced_surgery_model.gd")
const S=preload("res://godot/systems/advanced_surgery_session.gd")
const D=preload("res://godot/systems/advanced_operative_dialogue.gd")
const P=preload("res://godot/systems/advanced_presentation.gd")
const R=preload("res://godot/systems/advanced_referral.gd")
const F=preload("res://godot/systems/advanced_referral_facts.gd")
const Bridge=preload("res://godot/systems/advanced_physiology.gd")
var app
var checks=0
var failures=0
var native=false
var metrics=[]
func _initialize():call_deferred("run")
func check(ok,why):
 checks+=1
 if not ok:failures+=1;push_error(why)
func view():return app.page.get_node("AdvancedReferralView")
func click(id):
 var b=app.page.find_child(id,true,false)
 check(b is Button and not b.disabled,"Available button "+id)
 if b is Button and not b.disabled:b.pressed.emit()
func capture(name):
 if not native:return
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/tmp/advanced_three_"+name+".png")
func chapter(phase,locale):
 var c=app.advanced_controller
 check(c.story_phase==phase,"Authored chapter "+phase)
 if c.story_phase!=phase:return
 var rows=c.story_content[phase].lines
 var before=c.state().duplicate(true)
 for i in range(rows.size()):
  var card=app.page.get_node("AdvancedCast")
  var actor=c.story_content.patient.id if rows[i].speaker=="patient" else "PLAYER"
  check(card.get_meta("actor_id")==actor,"Authored speaker "+str(i))
  check(card.get_meta("source_text")==rows[i].get("text_en" if locale=="en" else "text"),"Exact source text")
  var art=card.get_node("AdvancedActorPortrait")
  check((art.texture!=null)==(actor!="PLAYER"),"Patient placeholder / no player portrait")
  if actor!="PLAYER":check(art.texture.resource_path=="res://"+str(c.story_content.patient.visuals.portraits["ward" if phase=="day1" else "postop"]),"Exact authored patient artwork")
  if i==0:await capture(locale+"_"+str(c.story_record.procedure_id)+"_"+phase)
  click("story_next");await process_frame
  check(c.state()==before,"Dialogue cannot change persistent facts/time")
 check(c.story_phase.is_empty(),"Chapter completed")
func drive(s,plan,strategy):
 var pi=0
 for guard in range(200):
  if s.finished:return
  if s.in_crisis():s.resolve_crisis("pause_and_stabilize")
  elif s.pending_rescue:s.rescue(0)
  elif s.awaiting_ack:s.acknowledge()
  elif s.current().kind=="P":s.act(plan[pi]);pi+=1
  else:s.act(0,strategy if s.current().kind=="S" else "")
func successful_seed(def,team,roster,strategy):
 var plan=M.plan(def,team)
 for seed_value in range(1,500):
  var probe=S.new(def,team,seed_value,app.game.staff,roster)
  drive(probe,plan,strategy)
  if probe.success:return seed_value
 return -1
func run():
 native="--native" in OS.get_cmdline_user_args()
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/advanced_three_unused_%s.json"%OS.get_process_id();root.add_child(app);await process_frame
 var additions=JSON.parse_string(FileAccess.get_file_as_string("res://docs/source/advanced_three_cases_content_v1/procedures_additions.json"))
 var selection=[]
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--procedure="):selection.append(arg.trim_prefix("--procedure="))
 if not selection.is_empty():additions=additions.filter(func(d):return d.id in selection)
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  var campaign=app.game.snapshot()
  for authored in additions:
   var def=M.procedure(authored.id)
   check(def==authored,"Exact authored procedure")
   var dialogue=D.new(def.id)
   check(not dialogue.data.is_empty(),"Runtime validator accepts all dialogue")
   for ordinal in range(3):
    var adapter=D.new(def.id,ordinal)
    for i in range(def.steps.size()):
     var row=adapter.select(def.steps[i].id,i,"stage_entry")
     check(not row.is_empty() and not D.bind_role(row.speaker_role,P.DEFAULT_TEAM).is_empty(),"All variants bind to real roles")
     if def.steps[i].kind=="P":
      row=adapter.select(def.steps[i].id,i,"precision_failed")
      for who in range(3):check(not D.bind_role(row.speaker_role,P.DEFAULT_TEAM,{"actor":who}).is_empty(),"Failed operator binding")
   app.advanced_controller=null;app.show_advanced_referral(true)
   click("case_advanced_first_"+str(def.id))
   var has_story=not app.advanced_controller.story_phase.is_empty()
   if has_story:await chapter("day1",locale)
   else:check(not P.pending_patient(view().record,locale=="en").is_empty(),"Unapproved first patient explicitly held")
   var c=app.advanced_controller
   var team=c.values(view().selected,def.id)
   var roster=view().selected.duplicate(true)
   var portraits=c.story_content.patient.visuals.portraits
   check(view().body.find_child("TeamPatientPortrait",true,false).texture.resource_path=="res://"+str(portraits.ward),"Team uses correct patient")
   check(view().scroll.vertical_scroll_mode==ScrollContainer.SCROLL_MODE_DISABLED,"Team controls stay on one screen")
   var title=app.page.get_node("PageTitle")
   check(title.get_theme_font("font").get_string_size(title.text,HORIZONTAL_ALIGNMENT_LEFT,-1,title.get_theme_font_size("font_size")).x<=title.size.x,"Long procedure title fits")
   await capture(locale+"_"+def.id+"_formation")
   var strategy="standard" if locale=="zh_CN" else "extended"
   var seed_value=successful_seed(def,team,roster,strategy)
   check(seed_value>0,"Reachable success with actual staff")
   click("accept");check(F.valid(c.state()),"Stable appointment facts")
   click("jump");click("start")
   var s=c.session
   s.rng.seed=seed_value;s.variant=s.rng.randf()<.25
   var splash=app.page.get_node("GeneralAnesthesiaSplash")
   check(splash.find_child("GeneralAnesthesiaSplashCG",true,false).texture.resource_path=="res://"+str(portraits["splash/general_anesthesia"]),"Correct patient induction")
   splash.find_child("AnesthesiaSplashContinue",true,false).pressed.emit();await process_frame
   check(s.patient_ready_pending and not s.act(),"Ready page blocks action")
   check(app.page.get_node("AdvancedCast").get_meta("actor_id")==P.patient(c.state().appointment.case,app.game,locale=="en").id,"Ready identity")
   click("begin_timeout")
   for i in range(7):
    var table=view().body.get_node("AdvancedTeamPatientTable")
    check(table.texture.resource_path=="res://"+str(portraits.team_confirmation),"Correct patient table")
    check(app.page.get_node("AdvancedCast").get_meta("actor_id")==roster[P.ROLES[i]],"Time-out actual staff")
    click("confirm_member")
   var plan=M.plan(def,team);var pi=0;var seen=[]
   for guard in range(180):
    if s.finished:break
    if s.in_crisis():click("pause_and_stabilize")
    elif s.pending_rescue:click("correct")
    elif s.awaiting_ack:click("continue")
    else:
     seen.append(s.current().id)
     var line=s.operative_dialogue.current(s)
     var card=app.page.get_node("AdvancedCast")
     var bound=D.bind_role(line.speaker_role,roster,s.last_result)
     check(card.get_meta("actor_id")==bound.id,"Operative speaker matches actual roster")
     check(card.get_meta("source_text")==line.get("text_en" if locale=="en" else "text"),"Exact operative text")
     check((card.get_node("AdvancedActorPortrait").texture!=null)==(bound.role not in ["system","lead_surgeon"]),"Speaker portrait alignment")
     var field=view().body.find_child("AdvancedOperativeField",true,false)
     var slot="incision" if s.index==0 else "closure" if s.index==def.steps.size()-1 else "operative_field"
     check(field!=null and str(field.get_meta("asset_path")).ends_with(slot+".png"),"Stage placeholder mapping")
     check(field.get_child(0).texture!=null,"Placeholder loaded")
     if s.current().kind=="S" or s.index==0 or s.index==def.steps.size()-1:await capture(locale+"_"+def.id+"_"+s.current().id)
     if s.current().kind=="P":
      var who=plan[pi];pi+=1;click("operate" if who==0 else "delegate_%s"%who)
     else:click("strategy_"+strategy if s.current().kind=="S" else "continue")
    await process_frame
   check(s.success and seen.size()==def.steps.size(),"Complete all stages with actual staff")
   var elapsed=s.physiology.procedure_state.elapsed_time
   check(elapsed>=def.duration_minutes+(20 if strategy=="extended" else 0),"Stage time present")
   metrics.append({"id":def.id,"locale":locale,"strategy":strategy,"seed":seed_value,"hp":s.hp,"physiology":s.physiology.procedure_state.duplicate(true),"crises":s.crisis_count})
   click("finish");click("settle")
   check(c.state().procedures[def.id]=="CLEARED" and c.state().completed[0].minutes==elapsed+120,"Only one time/result settlement")
   if has_story:await chapter("day3",locale)
   else:check(c.story_phase.is_empty(),"No unapproved success story")
   check(not c.settle() and F.valid(c.state()),"No duplicate rewards; facts valid")
   var restored=R.new(app.game,true);restored.local_facts=JSON.parse_string(JSON.stringify(c.state()))
   check(restored.story_phase.is_empty() and restored.completed("advanced_first_"+str(def.id)),"Reload only settled facts")
   c.demo_day=22;c.refresh()
   var replay=c.board().filter(func(row):return row.replay)[0]
   c.begin_story("day1",replay);check(c.story_phase.is_empty(),"Replay skips named story")
   check(P.patient_id(replay,app.game) in P.random_patient_ids(app.game),"Replay uses random pool")
   check(c.accept(replay,P.DEFAULT_TEAM),"Replay accepts")
   c.demo_day=c.state().appointment.review_day;c.state().outcome={"case_id":replay.id,"success":true,"operation_day":c.state().appointment.operation_day,"minutes":def.duration_minutes}
   check(c.settle() and c.story_phase.is_empty(),"Replay skips first success story")
   app.advanced_controller=null;app.show_advanced_referral(true);c=app.advanced_controller
   var first=c.board().filter(func(row):return row.procedure_id==def.id)[0]
   check(c.accept(first,P.DEFAULT_TEAM),"Failed first fixture accepts")
   c.demo_day=c.state().appointment.review_day;c.state().outcome={"case_id":first.id,"success":false,"operation_day":c.state().appointment.operation_day,"minutes":def.duration_minutes}
   check(c.settle() and c.story_phase.is_empty() and c.failure_dialogue_index==0,"Failure uses shared four lines")
   view().render()
   for row in D.failure_lines():
    var card=app.page.get_node("AdvancedCast")
    check(card.get_meta("actor_id")==D.bind_role(row.speaker_role,P.DEFAULT_TEAM).id,"Failure speaker")
    click("failure_next")
   check(c.state().procedures[def.id]=="FAILED_LOCKED","First failure permanently locks procedure")
   check(app.game.snapshot()==campaign,"No campaign data or player save changed")
 var out=FileAccess.open("/tmp/advanced_three_metrics.json",FileAccess.WRITE);out.store_string(JSON.stringify(metrics,"  "));out.close()
 print("ADVANCED THREE CONTENT: ",checks," checks; ",failures," failures")
 quit(1 if failures else 0)
