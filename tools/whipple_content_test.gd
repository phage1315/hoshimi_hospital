extends SceneTree
const M=preload("res://godot/systems/advanced_surgery_model.gd")
const D=preload("res://godot/systems/advanced_operative_dialogue.gd")
const R=preload("res://godot/systems/advanced_referral.gd")
const P=preload("res://godot/systems/advanced_presentation.gd")
const F=preload("res://godot/systems/advanced_referral_facts.gd")
const S=preload("res://godot/systems/advanced_surgery_session.gd")
const Boundary=preload("res://godot/systems/boundary_save.gd")
var app
var checks=0
var failures=0
var native=false
func _initialize():call_deferred("run")
func check(ok,why):
 checks+=1
 if not ok:failures+=1;push_error(why)
func view():return app.page.get_node("AdvancedReferralView")
func click(id):
 var b=app.page.find_child(id,true,false)
 check(b is Button and not b.disabled,"Action: "+id)
 if b is Button and not b.disabled:b.pressed.emit()
func capture(name):
 if not native:return
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/tmp/whipple_content_"+name+".png")
func read_story(phase,locale):
 var c=app.advanced_controller
 check(c.story_phase==phase,"Correct chapter "+phase)
 var facts=c.state().duplicate(true)
 var chapter=c.story_content[phase]
 for i in range(chapter.lines.size()):
  var line=chapter.lines[i]
  var card=app.page.get_node("AdvancedCast")
  var actor="patient_yamauchi_sakura" if line.speaker=="patient" else "PLAYER"
  check(card.get_meta("actor_id")==actor,"Story speaker identity")
  check(card.get_meta("source_text")==line.get("text_en" if locale=="en" else "text"),"Exact story text")
  var art=card.get_node("AdvancedActorPortrait")
  check((art.texture!=null)==(actor!="PLAYER"),"No borrowed portrait for protagonist")
  if actor!="PLAYER":check(art.texture.resource_path.ends_with(chapter.portrait+".png"),"Correct story outfit")
  if i in [0,8,11]:await capture(locale+"_"+phase+"_"+str(i))
  if phase=="day3":check(not c.settle(),"Cannot settle twice during story")
  click("story_next");await process_frame
  check(c.state()==facts,"Story never changes settled facts or time")
 check(c.story_phase.is_empty(),"Chapter completes")
func run():
 native="--native" in OS.get_cmdline_user_args()
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/whipple_content_unused_%s.json"%OS.get_process_id();root.add_child(app);await process_frame
 var definition=M.catalog()[0]
 var data=D.new(definition.id,0).data
 check(data.stages.size()==13,"13 entry stages")
 var entries=0;var failed=0
 for stage in data.stages.values():entries+=stage.stage_entry.size();failed+=stage.get("precision_failed",[]).size()
 check(entries==30 and failed==12,"Complete 42-line pool")
 for idx in range(13):
  var step=definition.steps[idx]
  for ordinal in range(3):
   var adapter=D.new(definition.id,ordinal)
   check(not adapter.select(step.id,idx,"stage_entry").is_empty(),"All entry variants available")
   if step.kind!="P":continue
   for who in range(3):
    var observed=false
    for seed_value in range(100):
     var probe=S.new(definition,M.fixtures(definition.id)[0],seed_value,[],{},true)
     probe.index=idx;probe.operative_dialogue=adapter
     probe.act(who)
     if probe.last_result.failed:
      var row=adapter.current(probe)
      check(not row.is_empty() and row.speaker_role=="acting_surgeon","Real failure emits acting surgeon line at "+step.id)
      var bound=D.bind_role(row.speaker_role,P.DEFAULT_TEAM,probe.last_result)
      check(bound.id==("PLAYER" if who==0 else P.DEFAULT_TEAM.first_assistant if who==1 else P.DEFAULT_TEAM.second_assistant),"Actual failed actor mapping")
      observed=true;break
    check(observed,"Failure branch exercised")
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  var original=app.game.snapshot()
  app.advanced_controller=null;app.show_advanced_referral(true)
  click("case_advanced_first_surgery_open_whipple")
  await read_story("day1",locale)
  var c=app.advanced_controller
  check(view().record.patient_id=="patient_yamauchi_sakura","Real first patient business identity")
  click("accept")
  check(F.valid(c.state()),"Accepted facts valid")
  # Safe-boundary reload retains business booking, no text cursor; no repeated intake.
  var restored=R.new(app.game,true);restored.local_facts=JSON.parse_string(JSON.stringify(c.state()))
  check(restored.story_phase.is_empty() and F.valid(restored.state()) and restored.state().appointment.case==c.state().appointment.case and restored.state().appointment.team==c.state().appointment.team,"Booking reload has no narrative internals")
  for key in ["intake_day","operation_day","review_day","intake_minutes"]:
   check(restored.state().appointment[key]==c.state().appointment[key],"Reload preserves "+key)
  click("jump");click("start")
  var s=c.session;s.rng.seed=883000;s.variant=s.rng.randf()<.25
  var overlay=app.page.get_node("GeneralAnesthesiaSplash")
  check(overlay.find_child("GeneralAnesthesiaSplashCG",true,false).texture.resource_path.ends_with("advanced_whipple_sakura_v1/anesthesia.png"),"Sakura induction image")
  await capture(locale+"_induction")
  overlay.find_child("AnesthesiaSplashContinue",true,false).pressed.emit();await process_frame
  check(s.patient_ready_pending and not s.act(),"Readiness page blocks incision")
  var ready=app.page.get_node("AdvancedCast")
  var ready_patient=P.patient(c.state().appointment.case,app.game,locale=="en")
  check(ready.get_meta("actor_id")=="patient_yamauchi_sakura","Ready page shows actual patient")
  check(str(ready.get_meta("portrait_path")).ends_with("anesthesia.png"),"Ready page uses anesthetized head portrait")
  var ready_text=("%s已经全身麻醉，固定在手术台上，准备好可以开刀了。" if locale=="zh_CN" else "%s is under general anaesthesia and secured on the operating table, ready for the incision.") % ready_patient.name
  check(ready.get_meta("source_text")==ready_text,"Exact requested readiness narration and English")
  check(ready.get_node("AdvancedDialoguePanel").find_child("AdvancedSpeakerName",true,false).text.begins_with(view().tr_key("narration")),"Readiness is narration, not unconscious patient speech")
  check(view().body.has_node("AdvancedTeamPatientTable"),"Prepared table visible before time-out")
  await capture(locale+"_patient_ready")
  click("begin_timeout")
  check(not s.patient_ready_pending and s.team_intro_index==0 and s.hp==100 and s.index==0,"Readiness advances only presentation")
  for i in range(7):
   await process_frame
   var table=view().body.get_node("AdvancedTeamPatientTable")
   var confirm=view().body.get_node("confirm_member")
   var cast=app.page.get_node("AdvancedCast")
   check(table.texture.resource_path.ends_with("advanced_whipple_sakura_v1/team_confirmation.png"),"Approved patient table on every role")
   check(table.stretch_mode==TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"Patient table not cropped")
   check(table.global_position.y>=confirm.global_position.y+confirm.size.y,"Table below confirmation button")
   check(table.global_position.x+table.size.x<=cast.global_position.x,"Table does not overlap staff")
   check(table.global_position.y+table.size.y<=view().scroll.global_position.y+view().scroll.size.y,"Table fits confirmation area")
   if i in [0,6]:await capture(locale+"_team_"+str(i))
   click("confirm_member")
  check(view().body.find_child("AdvancedTeamPatientTable",true,false)==null,"Table removed when surgery starts")
  var plan=M.plan(s.definition,s.team);var pi=0;var seen=[]
  for guard in range(150):
   if s.finished:break
   if s.in_crisis():click("pause_and_stabilize")
   elif s.pending_rescue:click("correct")
   elif s.awaiting_ack:
    var retained=s.operative_dialogue.current(s)
    var retained_card=app.page.get_node("AdvancedCast")
    check(not retained.is_empty(),"Result page retains authored line")
    var retained_speaker=D.bind_role(retained.speaker_role,c.state().appointment.team,s.last_result)
    check(retained_card.get_meta("actor_id")==retained_speaker.id,"Result line keeps original speaker")
    check(retained_card.get_meta("source_text")==retained.get("text_en" if locale=="en" else "text"),"Result text exact")
    if s.index==0:await capture(locale+"_W01_result")
    click("continue")
   else:
    seen.append(s.current().id)
    var line=s.operative_dialogue.current(s)
    check(not line.is_empty(),"Every entry has a line: "+s.current().id)
    var card=app.page.get_node("AdvancedCast")
    var bound=D.bind_role(line.speaker_role,c.state().appointment.team,s.last_result)
    check(card.get_meta("actor_id")==bound.id and bound.id!="patient_yamauchi_sakura","Real roster speaker; no anesthetized patient speech")
    check(card.get_meta("source_text")==line.get("text_en" if locale=="en" else "text"),"Exact operative line")
    var field=view().body.find_child("AdvancedOperativeField",true,false)
    var expected="whipple_incision.png" if s.index==0 else ("whipple_closure.png" if s.index==12 else "whipple.png")
    check(field!=null and str(field.get_meta("asset_path")).ends_with(expected),"Correct field for operative stage")
    check(field.get_child(0).texture!=null and field.get_child(0).stretch_mode==TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"Field loads without crop")
    if s.index in [0,2,5,10,12]:await capture(locale+"_"+s.current().id)
    if s.current().kind=="P":
     var who=plan[pi];pi+=1;click("operate" if who==0 else "delegate_%s"%who)
    else:click("strategy_standard" if s.current().kind=="S" else "continue")
   await process_frame
  check(s.finished and s.success and seen.size()==13,"Full Whipple path succeeds")
  var elapsed=s.physiology.procedure_state.elapsed_time
  click("finish");click("settle")
  check(c.state().procedures.surgery_open_whipple=="CLEARED" and c.state().completed.size()==1,"Settlement precedes Day3 story")
  check(c.state().completed[0].minutes==elapsed+120,"Story adds no duplicate time")
  await read_story("day3",locale)
  check(not c.settle(),"No repeated reward after story")
  var facts=JSON.parse_string(JSON.stringify(c.state()))
  check(F.valid(facts) and not JSON.stringify(facts).contains("story_index"),"No internal narrative state in persistence")
  restored=R.new(app.game,true);restored.local_facts=facts
  check(restored.story_phase.is_empty() and restored.completed("advanced_first_surgery_open_whipple"),"Clear reload never replays story")
  c.begin_story("day3",{"procedure_id":definition.id,"replay":false});view().render()
  var settled=c.state().duplicate(true);click("story_skip")
  check(c.story_phase.is_empty() and c.state()==settled,"Skip cannot alter settled reward/time")
  # Full replay and failure use the same settled path without first-patient story.
  c.demo_day=22;c.refresh()
  var replay=c.board().filter(func(r):return r.replay)[0]
  c.begin_story("day1",replay);check(c.story_phase.is_empty(),"Replay skips named intake")
  check(P.patient_id(replay) in P.PATIENTS,"Replay uses random-pool patient")
  check(c.accept(replay,P.DEFAULT_TEAM),"Accept replay")
  c.demo_day=c.state().appointment.review_day
  c.state().outcome={"case_id":replay.id,"success":true,"operation_day":c.state().appointment.operation_day,"minutes":480}
  check(c.settle() and c.story_phase.is_empty(),"Replay success skips first clear story")
  # Isolated failed first case: four actual-roster lines, no abandoned patient branch.
  app.advanced_controller=null;app.show_advanced_referral(true);c=app.advanced_controller
  var first=c.board()[0];check(c.accept(first,P.DEFAULT_TEAM),"Failure fixture accepted")
  c.demo_day=c.state().appointment.review_day
  c.state().outcome={"case_id":first.id,"success":false,"operation_day":c.state().appointment.operation_day,"minutes":240}
  check(c.settle() and c.story_phase.is_empty() and c.failure_dialogue_index==0,"Failure has only global dialogue")
  view().render()
  for row in D.failure_lines():
   var card=app.page.get_node("AdvancedCast");var bound=D.bind_role(row.speaker_role,P.DEFAULT_TEAM)
   check(card.get_meta("actor_id")==bound.id,"Failure roster identity")
   click("failure_next")
  check(c.state().procedures.surgery_open_whipple=="FAILED_LOCKED","First failure lock")
  check(app.game.snapshot()==original,"No campaign save/state modifications")
 # Production presentation lock, independent of numerical dev fixtures.
 var original_facts=app.game.advanced_referral_facts.duplicate(true)
 var production=R.new(app.game,false)
 production.begin_story("day1",{"procedure_id":definition.id,"replay":false})
 check(not app.game.can_save_progress() and Boundary.new().capture(app.game).is_empty(),"No saving during first-case narrative")
 production.finish_story()
 check(app.game.active_mode=="advanced_board" and Boundary.new().capture(app.game).is_empty(),"Narrative returns to referral UI, never a save boundary")
 production.begin_story("day3",{"procedure_id":definition.id,"replay":false})
 production.finish_story()
 check(not app.game.can_save_progress() and Boundary.new().capture(app.game).is_empty(),"Completed review story also waits for map exit before saving")
 app.game.advanced_referral_facts=original_facts
 print("WHIPPLE CONTENT: ",checks," checks; ",failures," failures")
 quit(1 if failures else 0)
