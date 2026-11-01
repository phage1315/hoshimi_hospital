extends "res://tools/advanced_three_content_test.gd"
var timeout_fallbacks := {}
func cast_check(locale: String) -> void:
 var c=app.advanced_controller
 var s=c.session
 var card=app.page.get_node_or_null("AdvancedCast")
 check(card!=null,"Every operative state has a presentation")
 if card==null:return
 var text=str(card.get_meta("source_text",""))
 check(not text.strip_edges().is_empty(),"No blank dialogue at index %s, result %s"%[s.index,s.last_result])
 await process_frame
 var label=card.find_child("AdvancedStaffDialogue",true,false)
 check(label.text==text and label.size.y>20,"Dialogue has text and visible height")
 if s.finished:
  check(card.get_meta("actor_id")=="doc_sakura_anesthesiology","Authored terminal speaker Sakura")
  check(text==P.confirmation("doc_sakura_anesthesiology","anesthesia_outcome","terminal_success" if s.success else "terminal_failure",s.definition.id,locale=="en"),"Localized authored terminal outcome")
 elif not s.in_crisis():
  var row=s.operative_dialogue.current(s)
  check(text==row.get("text_en" if locale=="en" else "text"),"Displayed original text")
  check(card.get_meta("actor_id")==D.bind_role(row.speaker_role,c.state().appointment.team,s.last_result).id,"Actual speaker preserved through rescue")
func input_chapter(phase: String, locale: String) -> void:
 var c=app.advanced_controller
 check(c.story_phase==phase,"Expected chapter "+phase)
 var count=0
 while not c.story_phase.is_empty():
  var before=c.story_index
  check(app.page.get_node("BackgroundWash").color.a==0.0,"Ward background undimmed")
  await process_frame
  if count%3==2:
   var panel=app.page.get_node("AdvancedCast/AdvancedDialoguePanel")
   var event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true;event.position=panel.get_global_rect().get_center()
   root.push_input(event,true)
   event=event.duplicate();event.pressed=false;root.push_input(event,true)
  else:
   var event=InputEventKey.new();event.keycode=KEY_SPACE if count%3==0 else KEY_ENTER;event.pressed=true
   root.push_input(event,true)
   event=event.duplicate();event.pressed=false;root.push_input(event,true)
  await process_frame
  check(c.story_phase.is_empty() or c.story_index==before+1,"Each keyboard/mouse confirm advances exactly one line")
  if c.story_index==before and not c.story_phase.is_empty():c.advance_story();view().render()
  count+=1
 check(app.dialogue_default_button==null,"No story shortcut leaks into team/summary")
func run():
 native="--native" in OS.get_cmdline_user_args()
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/advanced_review_unused_%s.json"%OS.get_process_id();root.add_child(app);await process_frame
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  var original=app.game.snapshot()
  for def in M.catalog():
   if D.new(def.id).data.is_empty():continue
   app.advanced_controller=null;app.show_advanced_referral(true)
   click("case_advanced_first_"+str(def.id))
   if def.id=="surgery_open_whipple":await capture(locale+"_ward_day1")
   await input_chapter("day1",locale)
   var c=app.advanced_controller
   for role in c.ROLES:
    for person in c.candidates(role,c.day()+1):
     var portrait_key=P.portrait_key(person,role)
     var portraits=person.get("visuals",{}).get("portraits",{})
     for body_key in ["scrubs/focused","scrubs/neutral","sterile/focused","sterile/neutral"]:
      if portraits.has(body_key):check(not portrait_key.begins_with("intraoperative_avatar/"),"OR standing portrait must precede HUD avatar: "+person.id+":"+role)
     if person.id=="nurse_moe":
      var expected_key="scrubs/neutral" if role in ["primary_circulating","secondary_circulating"] else "sterile/focused"
      check(portrait_key==expected_key,"Moe uses role-specific standing portrait: "+role)
      var without_scrubs=person.duplicate(true)
      without_scrubs.visuals.portraits.erase("scrubs/neutral")
      check(P.portrait_key(without_scrubs,role).begins_with("sterile/"),"Missing scrubs must fall back to standing sterile art, not HUD avatar")
     var text=P.line(app.game,person.id,role,"timeout",def.id,locale=="en")
     check(not text.strip_edges().is_empty(),"Time-out line exists: "+person.id)
     var supplied=P.confirmation(person.id,P.role_category(role),"timeout",def.id,locale=="en")
     if not supplied.is_empty():
      check(text==supplied,"Supplied role confirmation selected: "+person.id+":"+role)
      check(P.line(app.game,person.id,role,"assignment",def.id,locale=="en")!=supplied,"Time-out never replaces Day 1 assignment")
      check(P.confirmation(person.id,P.role_category(role),"timeout","surgery_appendix",locale=="en").is_empty(),"No ordinary surgery override")
      view().show_staff(person.id,role,text)
      await process_frame
      var cast=app.page.get_node("AdvancedCast")
      check(cast.get_meta("actor_id")==person.id,"Time-out actor identity")
      check(cast.find_child("AdvancedStaffDialogue",true,false).text==supplied,"Actual displayed Time-out text")
      check(cast.get_node("AdvancedActorPortrait").texture.resource_path=="res://"+str(person.visuals.portraits[P.portrait_key(person,role)]),"Time-out portrait matches actor and role")
      check(not cast.find_child("AdvancedSpeakerName",true,false).text.begins_with(view().tr_key("narration")),"Authored confirmation is spoken, not narration")
     if locale=="en":
      var han=RegEx.new();han.compile("[\u4e00-\u9fff]")
      check(han.search(text)==null,"No Chinese fallback in English Time-out: "+person.id)
     var groups=person.get("procedure_group_team_dialogue",{})
     var group=groups.get(P.GROUPS.get(def.id,""),groups.get("default",{}))
     var confirmation=str(group.get("role_confirmation",person.get("team_dialogue",{}).get("role_confirmation",""))) if role in ["first_assistant","second_assistant"] else ""
     if confirmation.is_empty() and supplied.is_empty():timeout_fallbacks[person.id+":"+role]=text
     if person.id=="doc_artoria" and role in ["first_assistant","second_assistant"]:
      check(text==person.team_dialogue.role_confirmation,"Artoria Time-out uses authored spoken confirmation, not assignment narration")
     if person.id=="doc_minato" and role in ["first_assistant","second_assistant"]:
      check(text==P.confirmation(person.id,"assistant","timeout",def.id,locale=="en"),"Minato uses new authored assistant confirmation")
     if (person.id=="nurse_rin" and role in ["primary_circulating","secondary_circulating"]) or role=="anesthesia":
      check(text==person.team_dialogue.role_confirmation,"Existing role-specific confirmation is used")
     if person.id in ["patient_chihaya","guest_mizuho"]:
      check(text==person.authored_dialogue["work.OR_02"][0],"Existing circulating preparation confirmation is used")
   if def.id=="surgery_open_whipple":view().selected.primary_circulating="nurse_moe"
   var seed_value=successful_seed(def,c.values(view().selected,def.id),view().selected,"standard")
   click("accept");click("jump");click("start")
   var s=c.session
   s.rng.seed=seed_value;s.variant=s.rng.randf()<.25
   app.page.get_node("GeneralAnesthesiaSplash").find_child("AnesthesiaSplashContinue",true,false).pressed.emit()
   click("begin_timeout")
   for i in range(7):
    check(not str(app.page.get_node("AdvancedCast").get_meta("source_text")).is_empty(),"Timeout text visible")
    if app.page.get_node("AdvancedCast").get_meta("actor_id")=="nurse_moe":
     check(app.page.get_node("AdvancedCast").get_meta("portrait_path")=="assets/characters/moe_circulating_v1/neutral.png","Actual Time-out uses new circulating sprite")
     await capture(locale+"_moe_circulating")
    click("confirm_member")
   var plan=M.plan(def,s.team);var pi=0
   for guard in range(180):
    await cast_check(locale)
    if s.finished:break
    if s.in_crisis():s.resolve_crisis("pause_and_stabilize")
    elif s.pending_rescue:s.rescue(0)
    elif s.awaiting_ack:s.acknowledge()
    elif s.current().kind=="P":s.act(plan[pi]);pi+=1
    else:s.act(0,"standard" if s.current().kind=="S" else "")
    view().render()
   check(s.finished and s.success,"Whole surgery succeeds")
   if def.id=="surgery_open_whipple":await capture(locale+"_terminal")
   click("finish");click("settle")
   await input_chapter("day3",locale)
   click("new")
   # Use actual board buttons and all completion/return callbacks. Previous tests
   # only called settle(), missing the record.clear() alias corruption.
   for success in [true,false]:
    c.demo_day+=28;c.refresh();view().render()
    var replay=c.board().filter(func(r):return r.replay and r.procedure_id==def.id)[0]
    var replay_id=str(replay.id)
    click("case_"+replay_id);click("new")
    check(c.state().replays.all(func(r):return r.has("id")),"Cancel team does not erase replay record")
    click("case_"+replay_id);click("accept");click("jump");click("start")
    s=c.session
    app.page.get_node("GeneralAnesthesiaSplash").find_child("AnesthesiaSplashContinue",true,false).pressed.emit()
    s.patient_ready_pending=false;s.team_intro_index=-1
    s.finished=true;s.success=success;s.hp=25 if success else 0;view().render()
    await cast_check(locale)
    click("finish");click("settle")
    if not success:
     for i in range(4):
      var card=app.page.get_node("AdvancedCast")
      check(app.page.get_node("BackgroundWash").color.a==0,"Failure review undimmed")
      if card.get_meta("actor_id")!="PLAYER":
       var person=app.game.staff_record(card.get_meta("actor_id"))
       check(card.get_meta("portrait_path")==person.visuals.portraits[P.ward_portrait_key(person)],"Day3 normal uniform")
       check(card.get_node("AdvancedActorPortrait").texture!=null,"Normal uniform loaded")
       if i==1 and def.id=="surgery_open_whipple":await capture(locale+"_ward_failure")
      check(app.activate_dialogue_default(),"Failure review confirm registered")
    click("new")
    check(c.completed(replay_id) and c.board().all(func(r):return r.id!=replay_id),"Completed replay filtered safely")
    check(F.valid(c.state()),"Replay facts valid after return to board")
   check(app.game.snapshot()==original,"Campaign untouched")
 var f=FileAccess.open("/tmp/advanced_review_regression_report.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"checks":checks,"failures":failures,"timeout_reuse":timeout_fallbacks},"  "));f.close()
 print("ADVANCED REVIEW REGRESSION: ",checks," checks; ",failures," failures")
 quit(1 if failures else 0)
