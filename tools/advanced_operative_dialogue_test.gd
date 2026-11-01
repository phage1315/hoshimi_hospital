extends SceneTree
const D = preload("res://godot/systems/advanced_operative_dialogue.gd")
const M = preload("res://godot/systems/advanced_surgery_model.gd")
const S = preload("res://godot/systems/advanced_surgery_session.gd")
const P = preload("res://godot/systems/advanced_presentation.gd")
var checks := 0
var failures := 0
var app
var native := false
func check(ok: bool, why: String):
 checks += 1
 if not ok: failures += 1; push_error(why)
func _initialize():call_deferred("run")
func comparable(s) -> Array:
 return [s.hp,s.index,s.used,s.precision_failures,s.rescue_attempts,s.crisis_count,s.finished,s.success,s.pending_rescue,s.awaiting_ack,s.rng.state,s.last_result,s.journal]
func advance(s):
 if s.pending_rescue:s.rescue(1 if s.eligible(1) else 0)
 elif s.awaiting_ack:s.acknowledge()
 else:s.act()
func view():return app.page.get_node("AdvancedReferralView")
func click(id):
 var b = view().body.find_child(id, true, false)
 check(b != null and not b.disabled,"UI button "+id)
 if b != null and not b.disabled:b.pressed.emit()
 while not app.advanced_controller.story_phase.is_empty():
  app.advanced_controller.advance_story();view().render()
func capture(name):
 if native:
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/tmp/advanced_dialogue_"+name+".png")
func run():
 native = "--native" in OS.get_cmdline_user_args()
 var def = M.procedure("surgery_open_whipple")
 var values = M.fixtures(def.id)[0]
 var adapter = D.new(def.id,0)
 check(D.valid(adapter.data,def),"Author sample accepted")
 var invalid = adapter.data.duplicate(true)
 invalid.stages.W03.stage_entry[0].hp_delta = 5
 check(not D.valid(invalid,def),"Reject effects")
 invalid=adapter.data.duplicate(true);invalid.stages.W03.stage_entry[0].speaker_role="acting_surgeon"
 check(not D.valid(invalid,def),"No premature acting surgeon")
 invalid=adapter.data.duplicate(true);invalid.stages.W01=invalid.stages.W03;invalid.stages.erase("W03")
 check(not D.valid(invalid,def),"No precision failure on fixed stage")
 for ordinal in range(3):
  var a = D.new(def.id,ordinal)
  for idx in [2,4,7]:
   for trigger in ["stage_entry","precision_failed"]:
    var line = a.select(def.steps[idx].id,idx,trigger)
    check(line==a.select(def.steps[idx].id,idx,trigger),"Stable selection")
    check(line.id!=D.new(def.id,ordinal+1).select(def.steps[idx].id,idx,trigger).id,"Next completed case rotates")
 for seed_value in range(80):
  var a=S.new(def,values,seed_value,[],{},true)
  var b=S.new(def,values,seed_value,[],{},true)
  a.operative_dialogue=D.new(def.id,seed_value%3)
  for guard in range(100):
   if a.finished:break
   for redraw in range(3):a.operative_dialogue.current(a)
   check(comparable(a)==comparable(b),"Dialogue never changes RNG, costs, opportunities or results")
   check(a.operative_dialogue.current(a,true).is_empty(),"Quick bypass contract")
   advance(a);advance(b)
  check(a.finished and comparable(a)==comparable(b),"Identical final results")
  check(a.operative_dialogue.current(a).is_empty() and not D.field_visible(a),"No queued line/field after termination")
 app=load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path="/tmp/advanced_dialogue_unused.json"
 root.add_child(app);await process_frame
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  var original:Dictionary=app.game.snapshot()
  for swap in [false,true]:
   app.advanced_controller=null;app.show_advanced_referral(true)
   click("case_advanced_first_surgery_open_whipple")
   if swap:
    var roster:Dictionary=view().selected
    var first=roster.first_assistant;roster.first_assistant=roster.second_assistant;roster.second_assistant=first
    first=roster.primary_scrub;roster.primary_scrub=roster.secondary_scrub;roster.secondary_scrub=first
   click("accept");click("jump");click("start")
   var c=app.advanced_controller
   var s=c.session
   app.page.get_node("GeneralAnesthesiaSplash").find_child("AnesthesiaSplashContinue",true,false).pressed.emit()
   click("begin_timeout")
   for i in range(7):click("confirm_member")
   check(D.field_visible(s) and D.field_path(s).ends_with("whipple_incision.png"),"Incision image before abdominal entry")
   s.act();view().render()
   check(D.field_visible(s) and D.field_path(s).ends_with("whipple.png"),"Open field after incision/entry settles")
   s.acknowledge();s.act();s.acknowledge();view().render()
   check(s.index==2,"Reached W03")
   var line:Dictionary=s.operative_dialogue.current(s)
   var card=app.page.get_node("AdvancedCast")
   check(card.get_meta("actor_id")==c.state().appointment.team.second_assistant,"W03 variant maps actual second assistant")
   check(card.get_meta("source_text")==str(line.text_en if locale=="en" else line.text),"Exact localized dialogue")
   var field=view().body.find_child("AdvancedOperativeField",true,false)
   check(field!=null,"Field window exists")
   await capture(locale+"_w03"+("_swapped" if swap else ""))
   await process_frame
   check(is_equal_approx(field.size.x/field.size.y,4.0/3.0),"4:3 field remains fixed across locales")
   for groups in adapter.data.stages.values():
    for rows in groups.values():
     for sample in rows:
      var result={"actor":1}
      view().show_operative_line(sample,c.state().appointment.team,result)
      var bound=D.bind_role(sample.speaker_role,c.state().appointment.team,result)
      var sample_card=app.page.get_node("AdvancedCast")
      check(sample_card.get_meta("actor_id")==bound.id,"Every authored line binds actual roster")
      check(sample_card.get_meta("source_text")==str(sample.text_en if locale=="en" else sample.text),"Every sample preserves source text")
      if bound.id!="PLAYER":
       var person=app.game.staff_record(bound.id)
       check(sample_card.get_meta("portrait_path") in person.visuals.portraits.values(),"Every authored portrait matches speaker")
   view().render()
   for i in range(5):view().render()
   check(s.operative_dialogue.current(s)==line,"Refresh no extra advance or variant change")
   # Deterministic QA forcing failure, without touching production difficulty or RNG logic.
   s.team.player=0
   var probe=RandomNumberGenerator.new()
   for candidate in range(100):
    probe.seed=candidate
    if probe.randf()>=M.probability(0,s.current(),s.team,s.variant):
     s.rng.seed=candidate
     break
   click("operate")
   check(s.pending_rescue,"First P failure before correction")
   card=app.page.get_node("AdvancedCast")
   check(card.get_meta("actor_id")=="PLAYER","Failed actor is player")
   check(card.get_node("AdvancedActorPortrait").texture==null,"Player does not borrow doctor portrait")
   await capture(locale+"_failure")
   click("rescue_1")
   check(s.operative_dialogue.current(s)==line,"Rescue retains stage cue, not failed-operator speech")
   await capture(locale+"_rescue_ack")
   check(app.page.get_node("AdvancedCast").get_meta("actor_id")==D.bind_role(line.speaker_role,c.state().appointment.team).id,"Rescue cue keeps its authored speaker")
   s.index=12;s.awaiting_ack=false;s.pending_rescue=false;view().render()
   check(D.field_visible(s) and D.field_path(s).ends_with("whipple_closure.png"),"Closure image replaces open field")
   # Terminate and validate Day3 atomic settlement before four lines, including skip.
   s.hp=0;s.check_failure();view().render()
   check(s.operative_dialogue.current(s).is_empty(),"Immediate terminal suppression")
   click("finish");click("settle")
   check(c.state().procedures[def.id]=="FAILED_LOCKED" and c.state().completed.size()==1,"Settlement precedes failure dialogue")
   var settled=c.state().duplicate(true)
   for i in range(4):
    check(c.failure_dialogue_index==i,"Failure line order")
    var expected=D.bind_role(D.failure_lines()[i].speaker_role,c.review_roster)
    check(app.page.get_node("AdvancedCast").get_meta("actor_id")==expected.id,"Failure actual speaker")
    if i==1:await capture(locale+"_day3")
    click("failure_next")
   check(c.state()==settled and c.failure_dialogue_index==-1,"Dialogue never settles again")
   check(not c.settle(),"Repeated settlement denied")
   c.failure_dialogue_index=0;view().render();click("failure_skip")
   check(c.state()==settled and c.failure_dialogue_index==-1,"Skip cannot alter settlement")
   check(app.game.snapshot()==original,"Dev leaves persistent state unchanged")
 var f=FileAccess.open("/tmp/advanced_dialogue_report.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"checks":checks,"failures":failures}));f.close()
 print("ADVANCED OPERATIVE DIALOGUE: ",checks," checks; ",failures," failures")
 quit(1 if failures else 0)
