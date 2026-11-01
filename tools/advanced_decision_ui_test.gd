extends SceneTree
const M=preload("res://godot/systems/advanced_surgery_model.gd")
const S=preload("res://godot/systems/advanced_surgery_session.gd")
var app
var checks=0
var failures=0
var native=false
func _initialize():call_deferred("run")
func check(ok,why):
 checks+=1
 if not ok:failures+=1;push_error(why)
func view():return app.page.get_node("AdvancedReferralView")
func control(id):return view().body.find_child(id,true,false)
func click(id):
 var b=control(id);check(b!=null and not b.disabled,"Button "+id)
 if b!=null and not b.disabled:b.pressed.emit()
 while not app.advanced_controller.story_phase.is_empty():
  app.advanced_controller.advance_story();view().render()
func capture(name):
 if not native:return
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/tmp/advanced_decision_"+name+".png")
func bounded():
 var row=control("AdvancedActionCards")
 check(row.get_global_rect().end.y<=745,"Actions visible without scrolling: "+str(view().controller.session.current().id)+" "+str(row.get_global_rect()))
 check(view().body.size.x<=830,"No overlap with cast")
 for b in row.get_children():
  check(b.get_global_rect().end.x<=875,"Card inside decision region")
  var content=b.get_child(0).get_child(0)
  check(content.get_combined_minimum_size().y<=b.size.y-12,"Every card line fits: "+str(b.name)+" "+str(content.get_combined_minimum_size().y))
 for key in ["hp","stability","visibility","bleeding","blood_loss","elapsed_time"]:
  var value=control("MetricValue_"+key)
  check(value.get_line_count()==1,"Single-line vital "+key)
func stamp(s):return [s.hp,s.used.duplicate(),s.index,s.rng.state,s.physiology.procedure_state.duplicate(true),s.journal.duplicate(true)]
func run():
 native="--native" in OS.get_cmdline_user_args()
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/advanced_decision_unused_%s.json"%OS.get_process_id();root.add_child(app);await process_frame
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  var original=app.game.snapshot()
  app.advanced_controller=null;app.show_advanced_referral(true)
  click("case_advanced_first_surgery_open_whipple");click("accept");click("jump");click("start")
  var c=app.advanced_controller;var s=c.session
  app.page.get_node("GeneralAnesthesiaSplash").find_child("AnesthesiaSplashContinue",true,false).pressed.emit()
  click("begin_timeout")
  for i in range(7):click("confirm_member")
  check(s.team.assistants[0].skill==94 and s.team.assistants[1].skill==91,"Canonical skills unchanged")
  check(s.team.assistants[0].universal_expert,"Mido registered as universal expert")
  for tag in ["adhesion","vascular","microdissection","reconstruction"]:
   check(M.remaining_uses(s.team.assistants[1],0,{"specialty_tag":tag})==2,"Artoria abdominal specialty: "+tag)
  check(M.remaining_uses(s.team.assistants[1],1,{"specialty_tag":"airway"})==0,"No invented airway specialty")
  check(M.unavailable_reason(s.team.assistants[1],1,{"specialty_tag":"airway"})=="specialty_required","Specific disabled reason")
  var low=s.team.assistants[1].duplicate(true);low.skill=89
  check(M.remaining_uses(low,1,{"specialty_tag":"vascular"})==0,"90 threshold retained")
  for stage_index in range(s.definition.steps.size()):
   s.index=stage_index
   view().render();await process_frame;await process_frame
   bounded()
   if stage_index==2:await capture(locale+"_precision_initial")
  s.index=4;s.used=[1,1]
  var before=stamp(s)
  view().render();await process_frame;await process_frame
  bounded()
  for who in range(3):
   var b=control("operate" if who==0 else "delegate_%s"%who)
   var skill=s.team.player if who==0 else s.team.assistants[who-1].skill
   check(b.get_meta("probability")==roundi(M.probability(skill,s.current(),s.team,s.variant)*100),"Resolver probability for each card")
   check(not b.disabled,"Second matching intervention available")
   if who>0:check(b.get_meta("remaining")==1,"One second intervention left")
  check(stamp(s)==before,"Rendering never changes RNG or runner")
  check(control("AdvancedStageProgress").get_child_count()==13,"Generic progress count")
  await capture(locale+"_precision_second_use")
  click("delegate_1")
  check(s.used==[2,1],"Only chosen assistant charged once")
  check(not s.act(1),"Duplicate action rejected")
  # Isolated UI fixture for disabled cards, without changing any actual character.
  s.used=[2,2];s.awaiting_ack=false;s.pending_rescue=false;s.physiology.active_crisis.clear();view().render();await process_frame;await process_frame
  check(control("delegate_1").disabled and control("delegate_2").disabled,"Both quotas visibly exhausted")
  check(not s.act(1) and not s.act(2),"No third intervention")
  await capture(locale+"_quota_spent")
  s.physiology.maybe_start_physiologic_crisis(0,{"id":"ui_fixture","physio_stress":"high"});view().render();await process_frame;await process_frame
  bounded();check(control("AdvancedActionCards").get_child_count()==3,"Three crisis actions")
  await capture(locale+"_crisis")
  # Fresh view-state fixture tests transient deltas and redraw idempotency.
  s=S.new(M.catalog()[0],c.values(c.state().appointment.team,"surgery_open_whipple"),12,app.game.staff,c.state().appointment.team)
  c.session=s;view().render();s.act();view().render();await process_frame;await process_frame
  check(control("MetricDelta_hp").text.strip_edges()=="-2","Actual HP delta")
  check(control("MetricDelta_blood_loss").text.strip_edges()=="+3","Actual blood loss delta")
  var unchanged=stamp(s);view().render();check(stamp(s)==unchanged,"Delta redraw no effects")
  await capture(locale+"_delta")
  await create_timer(2.4).timeout
  check(control("MetricDelta_hp").modulate.a<.05,"Delta fades without an additional action")
  check(app.game.snapshot()==original,"Player campaign untouched")
 print("ADVANCED DECISION UI: ",checks," checks; ",failures," failures")
 quit(1 if failures else 0)
