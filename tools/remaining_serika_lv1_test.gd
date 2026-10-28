extends SceneTree
const Flow = preload("res://godot/systems/serika_radiology.gd")
const Event = preload("res://godot/systems/character_event_session.gd")
const ID := Flow.LV1
var checks := 0
var failures := 0
func expect(ok: bool, message: String) -> void:
 checks += 1
 if not ok:
  failures += 1
  push_error(message)
func _initialize() -> void:
 call_deferred("run")
func complete_fixture(g, id: String) -> void:
 var e = Event.new(g.character_event_definitions[id])
 e.completed = true
 e.completed_day = 1
 e.settled_minutes = 0
 g.character_events[id] = e
 if id not in g.character_event_order:g.character_event_order.append(id)
func setup(g) -> void:
 g.reset()
 g.advance_story_to_day(8,540)
 g.meet_staff(Flow.ACTOR)
 for stage in ["a","b","c","d"]:complete_fixture(g,"serika_lv0_"+stage)
 for i in range(1,5):complete_fixture(g,Flow.event_id(i))
 g.relation_for(Flow.ACTOR).familiarity=12
 g.set_story_flag("serika_imaging_present:8",true)
func no_inner(v: Variant) -> void:
 if v is Dictionary:
  for k in v:
   expect(k not in ["node_id","choices","last_choice","step_index","response_index","action_log","rank_slots"],"Persistent field "+str(k))
   no_inner(v[k])
 elif v is Array:
  for x in v:no_inner(x)
func screenshot(app, locale: String, name: String) -> void:
 if not OS.get_cmdline_user_args().has("--screenshots") or DisplayServer.get_name()=="headless":return
 await process_frame
 await RenderingServer.frame_post_draw
 var folder := "res://docs/qa/remaining_complete_events_2026-10-27/serika_lv1_test/"
 if OS.get_cmdline_user_args().has("--cg-v2"):
  folder = "res://docs/qa/remaining_complete_events_2026-10-27/serika_lv1_test/"
 DirAccess.make_dir_recursive_absolute(folder)
 var path := folder+locale+"_"+name+".png"
 expect(root.get_texture().get_image().save_png(path)==OK,"Screenshot "+path)
func run() -> void:
 var app=load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path="/tmp/hoshimi_remaining_serika_lv1_test_unused.json"
 root.add_child(app)
 await process_frame
 for locale in ["zh_CN","en"]:
  expect(app.content.load_all(locale),"Load "+locale)
  app.configure_game_content()
  var g=app.game
  setup(g)
  var definition:Dictionary=g.character_event_definitions[ID]
  expect(g.relationship_rank_slot(Flow.ACTOR,1).event_id==ID,"Authored rank slot")
  expect(g.character_event_available(definition),"D04/Fam12 eligible")
  g.relation_for(Flow.ACTOR).familiarity=9
  expect(g.start_character_event(ID)==null,"Fam9 blocked")
  g.relation_for(Flow.ACTOR).familiarity=12
  g.character_events.erase("serika_lv0_d")
  expect(g.start_character_event(ID)==null,"Missing intro D blocked")
  complete_fixture(g,"serika_lv0_d")
  g.relation_for(Flow.ACTOR).met=false
  expect(g.start_character_event(ID)==null,"Unmet blocked")
  g.relation_for(Flow.ACTOR).met=true
  g.set_story_flag("serika_imaging_present:8",false)
  for repeat in range(3):
   expect(g.start_character_event(ID)==null,"Absent cannot start")
   expect(Flow.ACTOR not in g.staff_present_at("imaging"),"Event cannot force attendance")
  g.set_story_flag("serika_imaging_present:8",true)
  # Existing milestone cooldown: a synthetic previous milestone fact only.
  var prior=g.character_events["serika_lv0_a"]
  prior.completed_day=7
  g.relation_for(Flow.ACTOR).rank_history.append("serika_lv0_a")
  expect(g.start_character_event(ID)==null,"Shared cooldown honored")
  g.relation_for(Flow.ACTOR).rank_history.clear()
  for field in ["active_character_event_id","active_special_event_id","active_micro_event_id","active_preop_id"]:
   g.set(field,"fixture_busy")
   expect(g.start_character_event(ID)==null,"Busy blocked "+field)
   g.set(field,"")
  g.active_after_work_walk={"phase":"walk"}
  expect(g.start_character_event(ID)==null,"Walk blocked")
  g.active_after_work_walk={}
  g.active_free_h_departure={"phase":"departure"}
  expect(g.start_character_event(ID)==null,"Departure blocked")
  g.active_free_h_departure={}
  g.advance_story_to_day(8,1000)
  expect(g.start_character_event(ID)==null,"Last 20 minutes insufficient")
  setup(g)
  var saved_before:Dictionary=g.snapshot()
  var before:int=g.elapsed()
  var attrs:Dictionary=g.player_attributes().duplicate(true)
  var others:Dictionary={}
  expect(g.next_character_event_at("imaging").get("id","")==ID,"Normal priority entry")
  app.start_character_event_from_location(ID,"imaging")
  var event=g.character_events.get(ID)
  expect(event!=null,"Real location start")
  if event==null:quit(1);return
  expect(g.start_character_event(ID)==null,"Double start denied")
  g.choose_character_event(event.current().choices[0].id)
  g.active_character_event_id=""
  g.active_mode="encounter"
  expect(g.restore(saved_before),"Load safe pre-event save")
  expect(g.relationship_level(Flow.ACTOR)==0 and not g.character_event_done(ID),"Interrupted scene no reward")
  for actor in ["doc_sayaka","doc_emiko","doc_artoria"]:others[actor]=g.relation_for(actor).duplicate(true)
  app.start_character_event_from_location(ID,"imaging")
  event=g.character_events[ID]
  expect(event.node_id=="s01_01","Restart at scene one")
  var seen:Array[String]=[]
  for node in definition.nodes:
   expect(event.current().id==node.id,"Source order "+node.id)
   expect(not g.can_save_progress() and g.snapshot().is_empty(),"No mid-event save "+node.id)
   expect(g.relationship_level(Flow.ACTOR)==0 and not Flow.milestone_complete(g,1),"No early rank "+node.id)
   expect(g.elapsed()==before and g.relation_for(Flow.ACTOR).familiarity==12,"No early costs/rewards")
   app.show_character_event()
   var cg=app.page.find_child("CharacterEventCG",true,false)
   var uses_cg:bool=str(node.id) in ["s01_17","s01_18","s01_19","s01_20"]
   expect((cg!=null)==uses_cg,"CG only at approved scene-one segment")
   expect((app.page.find_child("EventPortrait_doc_serika",true,false)!=null)==not uses_cg,"CG replaces sprite; sprite restored afterwards")
   if uses_cg:expect(cg.texture!=null and cg.texture.resource_path.ends_with("serika_lv1_v1/cross_out_my_name.png"),"Approved CG texture loaded")
   expect((app.page.find_child("EventPortrait_doc_sayaka",true,false)!=null)==str(node.id).begins_with("s02"),"Sayaka only scene two")
   expect(app.page.find_child("EventPortrait_player",true,false)==null,"Player no portrait")
   var pages:Array=app.authored_dialogue_pages(str(node.text))
   expect("".join(pages)==str(node.text),"Pagination preserves complete source text")
   for page_index in range(pages.size()):
    expect(app.current_dialogue_text()==str(pages[page_index]),"Visible page matches loaded locale")
    if page_index+1<pages.size():app.advance_dialogue_page(app.show_character_event)
   seen.append(str(node.id))
   if str(node.id) in ["s01_06","s01_17","s01_18","s01_20","s02_01","s02_05","s02_20","s02_25","s03_20","s03_36"]:
    await screenshot(app,locale,str(node.id))
   # Exercise the actual UI callback; the UI paginates without merging nodes.
   app.choose_character_event(str(event.current().choices[0].id))
  expect(seen.size()==85 and event.completed,"All 85 nodes completed")
  expect(app.screen=="location" and g.active_character_event_id.is_empty(),"Returns to imaging UI")
  expect(app.page.find_child("EventPortrait_doc_sayaka",true,false)==null,"Scene cast removed")
  expect(g.elapsed()==before+30 and g.relation_for(Flow.ACTOR).familiarity==12,"Exactly 30min; no discussion reward")
  expect(g.relationship_level(Flow.ACTOR)==1 and Flow.milestone_complete(g,1),"One complete Lv1")
  expect(not g.choose_character_event("continue_s03_36") and g.start_character_event(ID)==null,"Repeated callbacks/reentry denied")
  expect(Flow.next_index(g)==5 and not g.character_event_done(Flow.event_id(5)),"D05 retained")
  expect(not g.story_flag("serika_imaging_discussed:8"),"Personal event leaves daily discussion available")
  for actor in others:expect(g.relation_for(actor)==others[actor],"Supporting/mentioned staff unaffected "+actor)
  expect(g.player_attributes()==attrs,"No extra attributes")
  expect(not g.staff_can_join_surgery_team(Flow.ACTOR) and not g.sunday_date_eligible(Flow.ACTOR),"No assistant/date unlock")
  expect(g.relationship_rank_slot(Flow.ACTOR,2).content_status=="authored","Lv2 authored via Chihaya third surgery")
  var before_replay:Dictionary=g.snapshot()
  app.replay_gallery_entry(ID)
  expect(app.gallery_replay_event!=null,"Gallery replay starts")
  for node in definition.nodes:
   expect(app.gallery_replay_event.current().id==node.id,"Replay follows all source nodes")
   var replay_uses_cg:bool=str(node.id) in ["s01_17","s01_18","s01_19","s01_20"]
   expect((app.page.find_child("CharacterEventCG",true,false)!=null)==replay_uses_cg,"Replay CG segment matches story")
   app.choose_gallery_replay(str(node.choices[0].id))
  expect(g.snapshot()==before_replay,"Replay cannot charge time or repeat rank reward")
  app.show_gallery_entry(ID)
  var gallery_cg=app.page.find_child("GalleryCG",true,false)
  expect(gallery_cg!=null,"Gallery shows approved CG")
  if gallery_cg!=null:
   expect(gallery_cg.size==Vector2(570,455),"Gallery respects preview dimensions")
   expect(gallery_cg.position.x+gallery_cg.size.x<=1280 and gallery_cg.position.y+gallery_cg.size.y<=800,"Gallery CG fits screen")
  await screenshot(app,locale,"gallery_cg")
  # Actual persistent file roundtrip from the map only, without player slots.
  app.show_map(false)
  var saved:Dictionary=g.snapshot()
  no_inner(saved)
  var path:="/private/tmp/serika_lv1_boundary_%s_%s.json"%[OS.get_process_id(),locale]
  var file=FileAccess.open(path,FileAccess.WRITE)
  file.store_string(JSON.stringify(saved));file.close()
  var old_nodes:Array=definition.nodes
  definition.nodes=[];definition.start="removed";definition.minutes=999
  expect(g.restore(JSON.parse_string(FileAccess.get_file_as_string(path))),"Restore despite removed script internals")
  expect(g.elapsed()==before+30 and g.relationship_level(Flow.ACTOR)==1 and Flow.next_index(g)==5,"Saved results stable")
  expect(g.restore(g.snapshot()),"Second save/read stable")
  expect(g.elapsed()==before+30 and g.relation_for(Flow.ACTOR).familiarity==12,"No duplicate settlement")
  definition.nodes=old_nodes;definition.start="s01_01";definition.minutes=30
  DirAccess.remove_absolute(path)
  # The still-unread D05 and then D06 use their original daily 60min/+3 flow.
  for index in [5,6]:
   if index==6:
    g.advance_story_to_day(9,540)
    g.set_story_flag("serika_imaging_present:9",true)
   var start:int=g.elapsed()
   var fam:int=g.relation_for(Flow.ACTOR).familiarity
   var discussion=g.start_character_event(Flow.event_id(index))
   expect(discussion!=null,"D%02d available"%index)
   if discussion!=null:
    while not discussion.completed:g.choose_character_event(str(discussion.current().choices[0].id))
    g.finish_character_event()
   expect(g.elapsed()==start+60 and g.relation_for(Flow.ACTOR).familiarity==fam+3,"Daily cost/reward unchanged")
   expect(not Flow.eligible(g,Flow.event_id(index+1)),"No same-day extra discussion")
 print("SERIKA LV1: %s checks; %s failures"%[checks,failures])
 quit(1 if failures else 0)
