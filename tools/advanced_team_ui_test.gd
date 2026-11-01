extends SceneTree
const M=preload("res://godot/systems/advanced_surgery_model.gd")
var app
var checks=0
var failures=0
var native=false
func _initialize():call_deferred("run")
func check(ok,why):
 checks+=1
 if not ok:failures+=1;push_error(why)
func view():return app.page.get_node("AdvancedReferralView")
func find(id):return view().body.find_child(id,true,false)
func click(id):
 var b=find(id);check(b!=null and not b.disabled,"Button "+id)
 if b!=null and not b.disabled:b.pressed.emit()
 while not app.advanced_controller.story_phase.is_empty():app.advanced_controller.advance_story();view().render()
func pick(role,id):
 var p=find("Team_"+role)
 for i in range(p.item_count):
  if str(p.get_item_metadata(i))==id:
   check(not p.is_item_disabled(i),"Candidate available "+id)
   p.select(i);p.item_selected.emit(i);return
 check(false,"Candidate exists "+id)
func capture(name):
 if not native:return
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/tmp/advanced_team_"+name+".png")
func bounds():
 await process_frame;await process_frame
 var panel=find("AdvancedTeamPanel")
 check(panel.get_global_rect().end.y<=view().scroll.get_global_rect().end.y,"Full panel inside viewport")
 check(panel.get_global_rect().end.x<=view().scroll.get_global_rect().end.x,"Panel width fits viewport")
 check(view().scroll.vertical_scroll_mode==ScrollContainer.SCROLL_MODE_DISABLED,"Team page has no scroll")
 check(app.page.get_node_or_null("AdvancedCast")==null,"No VN cast box during composition")
 for role in ["lead_surgeon"]+app.advanced_controller.ROLES:
  var card=find("TeamCard_"+role)
  check(card!=null and card.get_global_rect().end.y<find("TeamFooter").global_position.y,"Card above fixed footer")
  for label in card.get_children():
   if label is Label:
    check(label.get_minimum_size().y<=label.size.y,"Card label fits "+role+": "+label.text)
    check(label.get_line_count()<=label.get_visible_line_count(),"No hidden card text: "+label.text)
 for id in ["new","accept"]:
  check(find(id).get_global_rect().end.y<=745,"Footer button always visible")
 check(find("TeamPatientPortrait").texture!=null,"Patient portrait retained")
 for id in ["TeamCase","TeamAssessment"]:
  for label in find(id).get_children():
   if label is Label:check(label.get_line_count()<=label.get_visible_line_count(),"No hidden assessment text: "+label.text)
func run():
 native="--native" in OS.get_cmdline_user_args()
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/advanced_team_unused_%s.json"%OS.get_process_id();root.add_child(app);await process_frame
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  var original=app.game.snapshot()
  app.advanced_controller=null;app.show_advanced_referral(true)
  click("case_advanced_first_surgery_open_whipple")
  var c=app.advanced_controller;var v=view()
  await bounds()
  var initial_key=find("AdvancedTeamPanel").get_meta("estimate_key")
  check(not find("accept").disabled,"Default team valid")
  check(find("TeamCoverage").get_meta("covered")==6,"Real specialists cover six Whipple nodes")
  var expected=M.estimate(M.procedure(v.record.procedure_id),c.values(v.selected,v.record.procedure_id))
  check(find("TeamEstimate").get_meta("percent")==expected.rounded_percent,"Estimate comes from existing HP model")
  for role in ["first_assistant","second_assistant"]:check(v.team_panel.summaries[role].get_meta("max_uses")==2,"Specialist up to two uses")
  check(v.team_panel.summaries.primary_scrub.text.contains("Instrument" if locale=="en" else "器械"),"Scrub skill uses instrument handling")
  check(v.team_panel.summaries.primary_circulating.text.contains("Teamwork" if locale=="en" else "团队"),"Circulating skill uses teamwork")
  await capture(locale+"_default")
  var p=find("Team_first_assistant")
  var alternate=""
  for i in range(1,p.item_count):
   var id=str(p.get_item_metadata(i))
   if id not in v.selected.values():alternate=id;break
  check(not alternate.is_empty(),"Alternate real assistant")
  pick("first_assistant",alternate)
  check(find("AdvancedTeamPanel").get_meta("estimate_key")!=initial_key,"Choosing staff refreshes team estimate immediately")
  expected=M.estimate(M.procedure(v.record.procedure_id),c.values(v.selected,v.record.procedure_id))
  check(find("TeamEstimate").get_meta("percent")==expected.rounded_percent,"Changed estimate matches resolver")
  await bounds();await capture(locale+"_changed")
  var p2=find("Team_second_assistant")
  for i in range(1,p2.item_count):
   if p2.get_item_metadata(i)==alternate:check(p2.is_item_disabled(i),"Same person disabled for another role")
  pick("first_assistant","")
  check(find("accept").disabled and find("AdvancedTeamPanel").get_meta("estimate_key")=="","Missing slot disables schedule and clears estimate")
  await capture(locale+"_incomplete")
  pick("first_assistant","doc_emiko")
  click("accept")
  check(not c.state().appointment.is_empty(),"Fixed confirm submits real booking")
  click("rebook");await bounds()
  check(not find("accept").disabled,"Rebook retains valid roster")
  var before=c.state().appointment.duplicate(true)
  click("accept")
  check(c.state().appointment==before,"Same-date rebook no duplicate time or changed facts")
  check(app.game.snapshot()==original,"No player save or campaign mutation")
 print("ADVANCED TEAM UI: ",checks," checks; ",failures," failures")
 quit(0 if failures==0 else 1)
