extends SceneTree
const Flow = preload("res://godot/systems/serika_lv3.gd")
const Radiology = preload("res://godot/systems/serika_radiology.gd")
const Event = preload("res://godot/systems/character_event_session.gd")
var checks:=0
var failures:=0
func expect(ok:bool,message:String)->void:
 checks+=1
 if not ok:
  failures+=1
  push_error(message)
func _initialize()->void:
 call_deferred("run")
func complete_fixture(g,id:String,day:int)->void:
 var event=Event.new(g.character_event_definitions[id])
 event.completed=true;event.completed_day=day;event.settled_minutes=0
 g.character_events[id]=event
 if id not in g.character_event_order:g.character_event_order.append(id)
func setup(g)->void:
 g.reset();g.set_test_time(125,540);g.meet_staff(Flow.ACTOR)
 g.relation_for(Flow.ACTOR).level=2;g.relation_for(Flow.ACTOR).familiarity=40
 g.set_test_player_attribute("skill",60)
 # Isolated future positive fixture: existing production Lv2 IDs, no registry override.
 complete_fixture(g,Radiology.LV1,70)
 for i in range(3):
  var id=["chihaya_third_surgery_a","chihaya_third_surgery_b","chihaya_third_surgery_c"][i]
  g.special_event_completion_counts[id]=1;g.special_event_completion_days[id]=98+i
 g.relation_for(Flow.ACTOR).rank_history.assign([Radiology.LV1,"chihaya_third_surgery_b"])
 # No current production event writes this future completion fact yet.
 g.set_story_flag(Flow.MIZUHO_CHAIN_FACT)
func no_inner(v:Variant)->void:
 if v is Dictionary:
  for key in v:
   expect(key not in ["node_id","choices","last_choice","step_index","action_log","rank_slots"],"No persistent inner state "+str(key))
   no_inner(v[key])
 elif v is Array:
  for x in v:no_inner(x)
func capture(locale:String,name:String)->void:
 if not OS.get_cmdline_user_args().has("--screenshots") or DisplayServer.get_name()=="headless":return
 var folder:="res://docs/qa/serika_lv3_2026-10-27/"
 if OS.get_cmdline_user_args().has("--cg-approved"):folder+="cg_approved/"
 DirAccess.make_dir_recursive_absolute(folder)
 await process_frame
 await RenderingServer.frame_post_draw
 expect(root.get_texture().get_image().save_png(folder+locale+"_"+name+".png")==OK,"Screenshot")
func expected_cg(id:String)->String:
 if id>="s04_13" and id<="s04_22":return "assets/events/serika_lv3_v1/trial_smile.png"
 if id>="s04_33" and id<="s04_36":return "assets/events/serika_lv3_v1/half_beat_pause.png"
 if id>="s05_37" and id<="s05_40":return "assets/events/serika_lv3_v1/evening_smile.png"
 return ""
func check_cg(app,node:Dictionary)->void:
 var path:=expected_cg(str(node.id))
 expect(str(node.get("cg_path",""))==path,"Approved CG range "+str(node.id))
 var cg=app.page.find_child("CharacterEventCG",true,false)
 expect((cg!=null)==not path.is_empty(),"CG enters/exits at authored boundary")
 if cg!=null:
  expect(cg.texture!=null and cg.texture.resource_path=="res://"+path,"Approved texture loads")
  expect(cg.size==app.page.size and cg.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Full scene CG does not block dialogue input")
 var portrait=app.page.get_node_or_null("EventPortrait_doc_serika")
 expect((portrait!=null)==(path.is_empty() and not bool(node.hide_portrait)),"CG replaces sprite; authored sprite restored afterwards")
func run()->void:
 var app=load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path="/tmp/hoshimi_serika_lv3_test_unused_"+str(OS.get_process_id())+".json"
 root.add_child(app)
 await process_frame
 for locale in ["zh_CN","en"]:
  expect(app.content.load_all(locale),"Load "+locale);app.configure_game_content()
  var g=app.game
  g.reset();g.set_test_time(20,540)
  var definition:Dictionary=g.character_event_definitions[Flow.ID]
  expect(Flow.PREREQUISITES_CONNECTED,"Entry configuration enabled")
  expect(g.start_character_event(Flow.ID)==null,"No current-world start")
  g.meet_staff(Flow.ACTOR);g.relation_for(Flow.ACTOR).level=3;g.relation_for(Flow.ACTOR).familiarity=100
  expect(not g.sunday_date_eligible(Flow.ACTOR),"Numeric Lv3 does not unlock dates")
  expect(g.familiarity_gain_multiplier(Flow.ACTOR)==0.5,"Numeric Lv3 cannot change growth multiplier")
  setup(g)
  expect(Flow.prerequisite_facts_met(g) and Flow.eligible(g,true),"Future integration facts satisfy isolated logical gate")
  expect(g.character_event_available(definition),"Future complete prerequisite facts enable production eligibility")
  app.show_sunday_menu()
  expect(app.page.get_node_or_null("SerikaLv3WalkAlone")!=null,"Positive future fixture shows real Sunday entry")
  # Independently render the future menu choice without bypassing its callback.
  for child in app.page.get_children():
   if child is Label and child.position==Vector2(85,555):child.position.y=595
  var walk=app.page.get_node_or_null("SerikaLv3WalkAlone")
  expect(walk!=null and walk.text==("Go for a walk alone" if locale=="en" else "独自去走走"),"Exact source option, no meeting spoiler")
  await capture(locale,"menu_layout_preview")
  g.set_story_flag(Flow.MIZUHO_CHAIN_FACT,false)
  expect(not Flow.eligible(g,true),"Mizuho full-chain completion required")
  g.set_story_flag(Flow.MIZUHO_CHAIN_FACT)
  g.relation_for(Flow.ACTOR).familiarity=39
  expect(not Flow.eligible(g,true),"Fam39 blocked")
  g.relation_for(Flow.ACTOR).familiarity=40;g.set_test_player_attribute("skill",59)
  expect(Flow.eligible(g,true),"Latest revision removes Lv3 Surgery gate")
  g.set_test_player_attribute("skill",60)
  g.special_event_completion_days["chihaya_third_surgery_b"]=124
  expect(not Flow.eligible(g,true),"Shared three-day cooldown")
  g.special_event_completion_days["chihaya_third_surgery_b"]=99
  g.active_micro_event_id="busy"
  expect(not Flow.eligible(g,true),"Busy cannot interrupt")
  g.active_micro_event_id=""
  g.relationship_rank_slot(Flow.ACTOR,2).content_status="planned"
  expect(not Flow.eligible(g,true),"Displayed rank cannot replace real authored Lv2")
  g.relationship_rank_slot(Flow.ACTOR,2).content_status="authored"
  var before:int=g.elapsed();var before_day:int=g.day_number()
  var attributes:Dictionary=g.player_attributes().duplicate(true)
  var counters:Dictionary=g.character_progress_counters.duplicate(true)
  expect(g.familiarity_gain_multiplier(Flow.ACTOR)==0.5 and not g.sunday_date_eligible(Flow.ACTOR),"Before final node multiplier/date lock")
  var before_event:Dictionary=g.snapshot()
  var interrupted=Event.new(definition)
  g.character_events[Flow.ID]=interrupted;g.character_event_order.append(Flow.ID)
  g.active_character_event_id=Flow.ID;g.active_mode="character_event"
  expect(g.choose_character_event(str(interrupted.current().choices[0].id)),"In-memory interrupted opening")
  expect(g.restore(before_event),"Load safe boundary instead of resuming scene")
  expect(not g.character_event_done(Flow.ID) and g.relationship_level(Flow.ACTOR)==2 and g.elapsed()==before,"Interrupted scene grants no progress or time reward")
  # Render and settle the authored content through actual app callbacks, in a
  # test-only memory session. Production availability is asserted above using future completion facts.
  var event=Event.new(definition)
  g.character_events[Flow.ID]=event;g.character_event_order.append(Flow.ID)
  g.active_character_event_id=Flow.ID;g.active_mode="character_event"
  app.character_event_from_test=false
  for node in definition.nodes:
   expect(event.current().id==node.id,"Exact source order "+node.id)
   expect(g.elapsed()==before and not g.sunday_activity_done(),"No early Sunday settlement")
   expect(g.relationship_level(Flow.ACTOR)==2 and g.familiarity_gain_multiplier(Flow.ACTOR)==0.5,"No early level or multiplier")
   expect(not g.can_save_progress() and g.snapshot().is_empty(),"No mid-scene save")
   app.show_character_event()
   var scene_bg=app.page.get_node_or_null("SceneBackground")
   expect(scene_bg!=null and scene_bg.texture!=null,"Scene background loaded")
   var portrait=app.page.get_node_or_null("EventPortrait_doc_serika")
   check_cg(app,node)
   if portrait!=null:expect(portrait.texture.resource_path.contains("casual_winter"),"Private dark coat only")
   var pages:Array=app.authored_dialogue_pages(str(node.text))
   expect("".join(pages)==str(node.text),"Full text preserved across pages")
   for i in range(pages.size()):
    expect(app.current_dialogue_text()==pages[i],"Actual locale body displayed")
    if i+1<pages.size():app.advance_dialogue_page(app.show_character_event)
   expect(not node.has("sound_path") and not node.has("action"),"Silent-readable narrative; no H or audio runner")
   if str(node.id) in ["s01_02","s01_23","s02_36","s03_34","s04_16","s04_23","s04_35","s04_37","s04_42","s05_31","s05_37","s05_41","s05_48"]:await capture(locale,str(node.id))
   app.choose_character_event(str(node.choices[0].id))
  expect(event.completed and event.completed_day==before_day,"Final node commits event once")
  expect(g.relationship_level(Flow.ACTOR)==3 and Radiology.milestone_complete(g,3),"Real Lv3 completion fact")
  expect(g.familiarity_gain_multiplier(Flow.ACTOR)==0.8 and g.sunday_date_eligible(Flow.ACTOR),"Multiplier and normal date qualification unlocked")
  expect(g.day_number()==before_day+1 and g.current_absolute_clock()==540,"Sunday ends at normal Monday boundary")
  expect(g.sunday_history.size()==1 and g.sunday_history[0].activity_id=="serika_lv3_outing","Not counted as a date")
  expect(g.player_attributes()==attributes and g.relation_for(Flow.ACTOR).familiarity==40 and g.character_progress_counters==counters,"No Charm, familiarity, counters or skill rewards")
  expect(app.screen=="sunday_complete" and g.active_character_event_id.is_empty(),"Normal Sunday-complete UI; cast removed")
  expect(app.page.find_child("CharacterEventCG",true,false)==null,"Completion removes scene CG")
  await capture(locale,"complete")
  var settled:int=g.elapsed()
  expect(not g.choose_character_event("continue_s05_48") and g.elapsed()==settled,"Duplicate callback cannot settle twice")
  # Existing normal Sunday-date UI remains usable without authoring new Serika
  # date dialogue; it falls back to existing system location narration.
  g.set_test_time(before_day+7,540)
  var accepted_day:int=g.day_number()
  while not g.sunday_invitation_will_accept(Flow.ACTOR) and accepted_day<100:
   accepted_day+=7;g.set_test_time(accepted_day,540)
  expect(g.can_start_regular_sunday_date(Flow.ACTOR),"Subsequent ordinary Sunday outing is usable")
  app.show_sunday_date_acceptance(Flow.ACTOR)
  expect(app.page.get_node_or_null("SundayDateChooseLocation")!=null,"No missing-dialogue crash")
  app.begin_sunday_date(Flow.ACTOR,"cafe")
  expect(app.page.get_node_or_null("SundayDateFinish")!=null,"Existing generic date UI")
  # Return to map before persistent serialization; no real player slot touched.
  app.show_map(false)
  var saved:Dictionary=g.snapshot();no_inner(saved)
  var saved_elapsed:int=g.elapsed()
  var path:="/private/tmp/serika_lv3_boundary_%s_%s.json"%[OS.get_process_id(),locale]
  var file=FileAccess.open(path,FileAccess.WRITE);file.store_string(JSON.stringify(saved));file.close()
  var nodes:Array=definition.nodes;definition.nodes=[];definition.start="removed";definition.minutes=999
  expect(g.restore(JSON.parse_string(FileAccess.get_file_as_string(path))),"Restore despite removed scene structure")
  expect(g.relationship_level(Flow.ACTOR)==3 and g.familiarity_gain_multiplier(Flow.ACTOR)==0.8,"Rank and multiplier remain settled")
  expect(g.elapsed()==saved_elapsed and g.player_attributes()==attributes,"Historical time and attributes independent of script duration")
  expect(g.restore(g.snapshot()),"Second roundtrip stable")
  definition.nodes=nodes;definition.start="s01_02";definition.minutes=0
  DirAccess.remove_absolute(path)
  var replay_before:Dictionary=g.snapshot()
  app.replay_gallery_entry(Flow.ID)
  for node in definition.nodes:
   expect(app.gallery_replay_event.current().id==node.id,"Replay source order")
   check_cg(app,node)
   if str(node.id) in ["s04_16","s04_35","s05_37"]:await capture(locale,"replay_"+str(node.id))
   app.choose_gallery_replay(str(node.choices[0].id))
  expect(g.snapshot()==replay_before,"Replay does not consume another Sunday or reward")
  app.show_gallery_entry(Flow.ID)
  var gallery_cg=app.page.find_child("GalleryCG",true,false)
  expect(gallery_cg!=null,"Gallery has approved trial cover")
  if gallery_cg!=null:
   expect(gallery_cg.texture.resource_path=="res://"+expected_cg("s04_16"),"Gallery cover uses approved smile version")
   expect(gallery_cg.size==Vector2(570,455),"Gallery cover fits existing preview")
  await capture(locale,"gallery_cg")
 print("SERIKA LV3: %s checks; %s failures"%[checks,failures])
 app.queue_free();await process_frame
 quit(1 if failures else 0)
