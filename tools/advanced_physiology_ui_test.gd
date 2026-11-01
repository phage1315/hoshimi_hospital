extends SceneTree
const M = preload("res://godot/systems/advanced_surgery_model.gd")
const S = preload("res://godot/systems/advanced_surgery_session.gd")
const Facts = preload("res://godot/systems/advanced_referral_facts.gd")
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
 var b=view().body.find_child(id, true, false)
 check(b is Button and not b.disabled,"Enabled control: "+id)
 if b is Button and not b.disabled:b.pressed.emit()
 while not app.advanced_controller.story_phase.is_empty():
  app.advanced_controller.advance_story();view().render()
func capture(name):
 if not native:return
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/tmp/advanced_physiology_"+name+".png")
func run():
 native="--native" in OS.get_cmdline_user_args()
 app=load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path="/tmp/advanced_physiology_ui_%s.json"%OS.get_process_id()
 root.add_child(app);await process_frame
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  var original=app.game.snapshot()
  for option in ["standard","extended"]:
   app.advanced_controller=null;app.show_advanced_referral(true)
   click("case_advanced_first_surgery_open_whipple");click("accept");click("jump");click("start")
   var c=app.advanced_controller;var s=c.session
   check(s.physiology!=null and not s.hp_only,"Isolated real-staff test runs full physiology")
   # Reproducible episode seed from the separate simulation; campaign files untouched.
   s.rng.seed=883000;s.variant=s.rng.randf()<.25
   app.page.get_node("GeneralAnesthesiaSplash").find_child("AnesthesiaSplashContinue",true,false).pressed.emit()
   click("begin_timeout")
   for i in range(7):click("confirm_member")
   var plan=M.plan(s.definition,s.team);var pi=0;var seen=[]
   for guard in range(150):
    if s.finished:break
    if s.in_crisis():click("pause_and_stabilize")
    elif s.pending_rescue:click("correct")
    elif s.awaiting_ack:click("continue")
    elif s.current().kind=="S":
     seen.append(s.current().id)
     check(view().body.find_child("strategy_standard",true,false)!=null and view().body.find_child("strategy_extended",true,false)!=null,"Both strategy controls shown")
     var field=view().body.find_child("AdvancedOperativeField",true,false)
     check(field!=null,"Field remains during strategy")
     await capture(locale+"_"+s.current().id+"_"+option)
     view().scroll.scroll_vertical=1000;await capture(locale+"_"+s.current().id+"_options_"+option)
     click("strategy_"+option);view().scroll.scroll_vertical=0
    elif s.current().kind=="P":
     var who=plan[pi];pi+=1;click("operate" if who==0 else "delegate_%s"%who)
    else:click("continue")
    await process_frame
    check(view().body.size.x<=830,"No horizontal overflow")
   check(s.finished and s.success and seen==["W04","W11"],"All thirteen stages finish with both strategies")
   var elapsed=s.physiology.procedure_state.elapsed_time
   check(elapsed>=480+(20 if option=="extended" else 0),"Clinical minutes include strategy and rescue once")
   await capture(locale+"_finished_"+option)
   click("finish")
   check(c.state().outcome.minutes==elapsed,"Settled fact preserves actual elapsed minutes")
   var facts=c.state().duplicate(true)
   check(Facts.valid(facts),"Only existing stable facts saved, no physiology inner state")
   click("settle")
   check(not c.settle(),"Settlement is atomic")
   check(app.game.snapshot()==original,"Isolated demo leaves player campaign unchanged")
 print("ADVANCED PHYSIOLOGY UI: ",checks," checks; ",failures," failures")
 quit(1 if failures else 0)
