extends SceneTree
# Read-only production content QA. Sessions live in memory; output is observations,
# never a restorable game snapshot. All narrative advancement uses GUI input.
const QA = "res://docs/qa/remaining_complete_events_2026-10-27/branches_final/"
const Character = preload("res://godot/systems/character_event_session.gd")
const Special = preload("res://godot/systems/special_event_session.gd")
var app
var observations:FileAccess
var results:Array=[]
var inputs={"mouse":0,"space":0,"enter":0,"auto":0}
var issues:Array=[]
var context:Dictionary={}
var pages=0
var shot_count=0
var shot_keys:Dictionary={}
var covered_nodes:Dictionary={}
var already_completed:Array=[]
func _initialize():call_deferred("run")
func record_issue(kind:String,detail:String):
 var row=context.duplicate();row["kind"]=kind;row["detail"]=detail
 issues.append(row);print("QA_ISSUE ",JSON.stringify(row))
func click(control):
 if not is_instance_valid(control):return
 await RenderingServer.frame_post_draw
 if not is_instance_valid(control):return
 var point:Vector2=control.get_global_rect().get_center()
 var move=InputEventMouseMotion.new();move.position=point;move.global_position=point;root.push_input(move,true)
 for down in [true,false]:
  var event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;event.position=point;event.global_position=point
  root.push_input(event,true);await process_frame
 inputs.mouse+=1
func key(code):
 for down in [true,false]:
  var event=InputEventKey.new();event.keycode=code;event.pressed=down
  root.push_input(event,true);await process_frame
 inputs["space" if code==KEY_SPACE else "enter"]+=1
func capture(tag:String):
 var stem="variant_"+str(context.locale)+"_"+str(context.event)+"_"+tag
 if shot_keys.has(stem):return
 shot_keys[stem]=true
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(QA+stem+".png");shot_count+=1
func label_texts():
 var a:Array=[]
 for c in app.page.find_children("*","Label",true,false):
  if c.is_visible_in_tree():a.append({"text":c.text,"x":c.position.x,"y":c.position.y,"width":c.size.x,"height":c.size.y})
 return a
func inspect(node:Dictionary,definition:Dictionary,special:bool,replay:bool):
 var body=app.page.get_node_or_null(("SpecialEventReplayDialogue" if replay else "SpecialEventDialogue") if special else ("GalleryReplayDialogue" if replay else "CharacterEventDialogue"))
 if body==null:body=app.page.get_node_or_null("CharacterEventMessageText")
 if body==null:body=app.page.get_node_or_null("AdvancedReferralPrompt")
 var labels=label_texts();var names:Array=[]
 for item in labels:
  if item.y==558 or (replay and not special and item.y==205):names.append(item.text)
 var sender=app.page.get_node_or_null("CharacterEventMessageSender")
 if sender:names=[sender.text]
 var portraits:Array=[]
 for c in app.page.find_children("*","TextureRect",true,false):
  portraits.append({"atlas_path":c.texture.atlas.resource_path if c.texture is AtlasTexture else "","atlas_region":str(c.texture.region) if c.texture is AtlasTexture else "","widget":str(c.name),"path":c.texture.resource_path if c.texture else "","x":c.position.x,"y":c.position.y,"width":c.size.x,"height":c.size.y})
 var row=context.duplicate();row["page"]=app.dialogue_page_index;row["names"]=names;row["visuals"]=portraits;row["configured_role"]=node.get("speaker","");row["configured_label"]=node.get("speaker_label","");row["body"]=body.text if body else "";row["screen"]=app.screen;row["labels"]=labels
 observations.store_line(JSON.stringify(row));observations.flush()
 if body!=null:
  if body is RichTextLabel and body.get_content_height()>body.size.y+1 and not body.scroll_active:record_issue("text_overflow","height=%s area=%s"%[body.get_content_height(),body.size.y])
  if node.get("presentation","")=="authored" and node.has("speaker_label") and names!=[node.speaker_label]:record_issue("authored_name_mismatch","expected="+str(node.speaker_label)+" actual="+str(names))
 for c in app.page.find_children("*","Button",true,false):
  if c.is_visible_in_tree() and (str(c.name).contains("Choice") or str(c.name).contains("Continue")):
   if not Rect2(Vector2.ZERO,app.size).encloses(c.get_global_rect()):record_issue("button_outside_viewport",str(c.name))
 var cg=str(node.get("cg_path",""));var expected:Array=[]
 if not cg.is_empty():expected.append("res://"+cg)
 if (cg.is_empty() or node.get("cg_portrait_overlay",false)) and not node.get("hide_portrait",false):
  if node.has("event_portraits"):
   for p in node.event_portraits:expected.append("res://"+str(p.path))
  elif node.has("portrait_path"):expected.append("res://"+str(node.portrait_path))
 var actual:Array=[]
 for p in portraits:actual.append(p.path)
 for path in expected:
  if path not in actual:record_issue("missing_configured_texture",path)
 if not cg.is_empty() and not node.get("cg_portrait_overlay",false):
  for p in portraits:
   if p.widget.begins_with("EventPortrait_") or p.widget=="CharacterPortrait":record_issue("portrait_over_cg",p.widget)
 if bool(node.get("hide_portrait",false)):
  for p in portraits:
   if p.widget=="CharacterPortrait" or p.widget.begins_with("EventPortrait_"):record_issue("stale_hidden_portrait",p.widget)
 pages+=1
func plans(definition:Dictionary,steps:Dictionary,special:bool):
 # Minimal independent routes cover every graph edge without serializing paths.
 var nodes:Array=definition.get("nodes",[])
 var start=str(definition.get("start",""))
 if special:
  nodes=[]
  for sid in definition.event_chain:nodes.append_array(steps[sid].nodes)
  start=str(steps[definition.event_chain[0]].start)
 var step_next:Dictionary={}
 if special:
  for si in range(definition.event_chain.size()):
   for n in steps[definition.event_chain[si]].nodes:
    step_next[str(n.id)]=str(steps[definition.event_chain[si+1]].start) if si+1<definition.event_chain.size() else ""
 var index:Dictionary={}
 for n in nodes:index[str(n.id)]=n
 var queue:Array=[{"node":start,"path":[]}];var reached:Dictionary={};var out:Array=[[]]
 while not queue.is_empty():
  var item=queue.pop_front();var nid=str(item.node)
  if reached.has(nid) or not index.has(nid):continue
  reached[nid]=true
  var n=index[nid]
  for choice in n.get("choices",[]):
   var path:Array=item.path.duplicate();path.append(str(choice.id))
   if n.get("choices",[]).size()>1:out.append(path)
   var target=str(choice.get("next",""))
   if special and target=="@day_end":target=str(step_next.get(nid,""))
   queue.append({"node":target,"path":path})
 return out
func prepare_route(_definition:Dictionary,_special:bool,_replay:bool):
 for person in app.content.collections.staff:app.game.meet_staff(person.id)
func finish_route(_definition:Dictionary,_special:bool,_replay:bool,_session):pass
func run_route(definition:Dictionary,special:bool,plan:Array,replay:bool,route_index:int):
 var done_key=str(definition.id)+"|"+str(context.locale)+"|"+str(replay)+"|"+str(route_index)
 if done_key in already_completed:return
 var branch_start="";var branch_step=0
 if special and route_index>0 and not plan.is_empty():
  for si in range(definition.event_chain.size()):
   for node in app.game.special_event_step_definitions[definition.event_chain[si]].nodes:
    if node.get("choices",[]).size()>1 and node.choices.any(func(c):return str(c.id)==str(plan[-1])):branch_start=str(node.id);branch_step=si
 var g=app.game;g.reset();prepare_route(definition,special,replay);app.show_map(false)
 for child in app.get_children():
  if child is Window:child.hide()
 app.sayaka_lv4_h_handoff_complete=false;app.h_profile_test_session=null;app.dialogue_auto_enabled=false;app.reset_dialogue_page();app.character_event_return_location=str(definition.get("location_id","exam"));app.character_event_from_test=false
 var session
 if special:
  session=Special.new(definition,g.special_event_step_definitions,1)
  if not branch_start.is_empty():session.step_index=branch_step;session.node_id=branch_start
  if replay:g.special_event_completion_counts[definition.id]=1;app.special_event_gallery_replay=session;app.special_event_replay_last_cg_path="";app.show_special_gallery_replay()
  else:g.active_special_event=session;g.active_special_event_id=definition.id;g.active_mode="special_event";app.special_event_last_cg_path="";app.show_special_event()
 else:
  session=Character.new(definition)
  if replay:
   var completed_record=Character.new(definition);completed_record.completed=true;completed_record.completed_day=1;completed_record.settled_minutes=int(definition.minutes)
   g.character_events[definition.id]=completed_record;g.character_event_order.append(str(definition.id))
   app.gallery_replay_event=session;app.gallery_replay_is_test=false;app.show_gallery_replay()
  else:g.character_events[definition.id]=session;g.character_event_order.append(str(definition.id));g.active_character_event_id=definition.id;g.active_mode="character_event";app.show_character_event()
 var starting_time=g.elapsed();var before_rewards=g.relationships.duplicate(true)
 var advances=0;var visited:Dictionary={};var route_pages=0;var auto_done=false;var outcome="guard_limit"
 for guard in range(4000):
  await process_frame
  while app.h_profile_test_transitioning:await process_frame
  if session.completed or (special and session.cancelled):outcome="cancelled" if special and session.cancelled else "completed";break
  if app.screen not in ["character_event","gallery_replay","special_event","special_gallery_replay"]:
   if app.screen in ["day_transition","special_event_blackout"]:
    var b=app.dialogue_default_button
    if is_instance_valid(b):await click(b)
    else:
     var found=false
     for c in app.page.find_children("*","Button",true,false):
      if c.is_visible_in_tree() and not c.disabled:await click(c);found=true;break
     if not found:await create_timer(0.1).timeout
    continue
   record_issue("unexpected_screen",app.screen);outcome="unexpected_screen";break
  var node:Dictionary=session.current();var nid=str(node.get("id",""));context["node"]=nid;context["replay"]=replay;context["route"]=route_index
  if special:context["step_id"]=session.current_step().id
  if node.is_empty():record_issue("empty_node",nid);outcome="empty_node";break
  var coverage_key=str(definition.id)+"|"+str(context.locale)+"|"+str(replay)+"|"+nid
  if not branch_start.is_empty() and route_pages>0 and not visited.has(nid) and covered_nodes.has(coverage_key):outcome="branch_rejoined_verified_path";break
  covered_nodes[coverage_key]=true
  visited[nid]=true
  inspect(node,definition,special,replay);route_pages+=1
  if route_index==0 and (route_pages==1 or node.get("choices",[]).size()>1):await capture(("replay_" if replay else "live_")+nid)
  if node.get("presentation","")=="stage":
   var end=Time.get_ticks_msec()+int((float(node.get("auto_seconds",1))+2)*1000)
   while not session.completed and str(session.current().get("id",""))==nid and Time.get_ticks_msec()<end:await create_timer(0.03).timeout
   if not session.completed and str(session.current().get("id",""))==nid:record_issue("stage_stall",nid);outcome="stage_stall";break
   advances+=1;continue
  var prefix=("SpecialReplayChoice_" if replay else "SpecialEventChoice_") if special else ("ReplayChoice_" if replay else "EventChoice_")
  var page_name=("SpecialReplayDialogueContinue" if replay else "SpecialEventDialogueContinue") if special else ("ReplayDialogueContinue" if replay else "EventDialogueContinue")
  var button=app.page.get_node_or_null(page_name);var paging=button!=null
  var choice_id=""
  if button==null:
   var choices:Array=node.get("choices",[])
   if choices.is_empty():record_issue("no_choice",nid);outcome="no_choice";break
   if not replay and node.get("presentation","") in ["advanced_referral_summary","advanced_surgery"]:prefix="AdvancedReferralChoice_"
   var visible_choices:Array=[]
   for option in choices:
    if app.page.get_node_or_null(prefix+str(option.id))!=null:visible_choices.append(str(option.id))
   choice_id=visible_choices[0] if not visible_choices.is_empty() else str(choices[0].id)
   for preferred in plan:
    if str(preferred) in visible_choices:choice_id=str(preferred);break
   button=app.page.get_node_or_null(prefix+choice_id)
  if button==null:record_issue("missing_button",prefix+choice_id);outcome="missing_button";break
  var wait_end=Time.get_ticks_msec()+12000
  while is_instance_valid(button) and (not button.is_visible_in_tree() or button.disabled) and Time.get_ticks_msec()<wait_end:await create_timer(0.03).timeout
  if not is_instance_valid(button):continue
  if not button.is_visible_in_tree() or button.disabled:record_issue("button_inaccessible",str(button.name));outcome="button_inaccessible";break
  var old_page=app.dialogue_page_index
  if route_index==0 and not auto_done and is_instance_valid(app.dialogue_default_button) and is_instance_valid(app.dialogue_auto_toggle_button):
   await click(app.dialogue_auto_toggle_button);var deadline=Time.get_ticks_msec()+15000
   while not session.completed and str(session.current().get("id",""))==nid and app.dialogue_page_index==old_page and Time.get_ticks_msec()<deadline:await create_timer(0.02).timeout
   if is_instance_valid(app.dialogue_auto_toggle_button):await click(app.dialogue_auto_toggle_button)
   app.dialogue_auto_enabled=false;auto_done=true;inputs.auto+=1
  elif node.choices.size()>1 or pages%3==0 or node.get("presentation","") in ["advanced_referral_summary","advanced_surgery"]:await click(button)
  elif pages%3==1:await key(KEY_SPACE)
  else:await key(KEY_ENTER)
  if app.screen=="h_profile_test":await drive_handoff()
  if special and session.cancelled:outcome="cancelled";break
  if not session.completed and str(session.current().get("id",""))==nid and app.dialogue_page_index==old_page:
   record_issue("input_stall",str(button.name) if is_instance_valid(button) else "freed_button");await capture("stall_"+nid);outcome="input_stall";break
  if paging and not session.completed and str(session.current().get("id",""))!=nid:record_issue("pagination_skipped_node",nid)
  if not paging:advances+=1
  if replay and (g.elapsed()!=starting_time or g.relationships!=before_rewards):record_issue("replay_mutated_world",nid)
 await finish_route(definition,special,replay,session)
 if route_index==0:await capture(("replay_" if replay else "live_")+"end")
 results.append({"event":definition.id,"locale":context.locale,"replay":replay,"route":route_index,"outcome":outcome,"nodes_observed":visited.keys(),"pages":route_pages,"return_screen":app.screen,"entry":"isolated_branch_from_"+branch_start if not branch_start.is_empty() else "isolated_memory_content_only"})
 print("QA_ROUTE ",definition.id," ",context.locale," replay=",replay," route=",route_index," ",outcome," pages=",route_pages)
 app.dialogue_auto_enabled=false;app.show_map(false);await process_frame

func click_point(point:Vector2):
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;e.position=point;e.global_position=point;root.push_input(e,true);await process_frame
 inputs.mouse+=1
func drive_handoff():
 for guard in range(220):
  await process_frame
  if app.screen!="h_profile_test":return
  var stage=app.h_profile_test_session.phase
  var row=context.duplicate();row["phase"]=stage;row["labels"]=label_texts();row["screen"]=app.screen
  var textures:Array=[]
  for c in app.page.find_children("*","TextureRect",true,false):textures.append({"widget":str(c.name),"path":c.texture.resource_path if c.texture else "","atlas_path":c.texture.atlas.resource_path if c.texture is AtlasTexture else "","region":str(c.texture.region) if c.texture is AtlasTexture else ""})
  row["visuals"]=textures
  var file=FileAccess.open(QA+"handoff_pages.jsonl",FileAccess.READ_WRITE) if FileAccess.file_exists(QA+"handoff_pages.jsonl") else FileAccess.open(QA+"handoff_pages.jsonl",FileAccess.WRITE)
  file.seek_end();file.store_line(JSON.stringify(row));file.close()
  await capture("handoff_"+str(stage)+"_"+str(app.h_profile_test_session.h_scene_index))
  var button=app.page.get_node_or_null("HProfileAdvance")
  if button==null:button=app.page.get_node_or_null("HProfileFinish")
  if button==null:button=app.page.get_node_or_null("HProfileStyleGentle" if int(context.route)%2==0 else "HProfileStyleIntense")
  if button:await click(button);continue
  var body=app.page.get_node_or_null("HProfileBodyMap")
  if body:
   var hotspots:Dictionary=app.h_profile_test_bodymap.hotspots
   var zones=["lips","cheeks","neck"];var polygon:Array=hotspots[zones[guard%3]][0];var uv=Vector2.ZERO
   for point in polygon:uv+=Vector2(point[0],point[1])
   uv/=polygon.size()
   var rect=preload("res://godot/systems/scene_content_context.gd").image_rect(body.get_global_rect(),body.texture.get_size())
   await click_point(rect.position+rect.size*uv)
  else:record_issue("handoff_missing_control",str(stage));return
 record_issue("handoff_guard_limit","GUI path did not return")
func all_plans(d:Dictionary):
 var index:Dictionary={}
 for n in d.nodes:index[n.id]=n
 var pending:Array=[{"node":d.start,"path":[]}];var out:Array=[]
 while not pending.is_empty():
  var item=pending.pop_front()
  if str(item.node).begins_with("@"):
   out.append(item.path);continue
  if item.path.size()>400:continue
  for choice in index[item.node].choices:
   var target=str(choice.next);var conditional=choice.get("next_if_choice",{})
   if item.path.has(conditional.get("choice_id","")):target=str(conditional.next)
   var path:Array=item.path.duplicate();path.append(choice.id);pending.append({"node":target,"path":path})
 return out
func run():
 observations=FileAccess.open(QA+"pages.jsonl",FileAccess.WRITE)
 for folder in ["native_recheck","content_final"]:
  var p=FileAccess.open("res://docs/qa/remaining_complete_events_2026-10-27/"+folder+"/pages.jsonl",FileAccess.READ)
  while not p.eof_reached():
   var line=p.get_line()
   if line.strip_edges().is_empty():continue
   var row=JSON.parse_string(line)
   if row is Dictionary and int(row.get("route",-1))==0:covered_nodes[str(row.event)+"|"+str(row.locale)+"|"+str(row.replay)+"|"+str(row.node)]=true
  p.close()
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_branch_unused.json";root.add_child(app);await process_frame
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  for id in ["or_acceptance_training_01","advanced_referral_tutorial_chisato"]:
   var d=app.game.special_event_definitions[id];context={"event":id,"locale":locale};var idx=200
   for sid in d.event_chain:
    for node in app.game.special_event_step_definitions[sid].nodes:
     if node.get("choices",[]).size()<2:continue
     for choice in node.choices:
      for replay in [false,true]:await run_route(d,true,[str(choice.id)],replay,idx)
      idx+=1
 var f=FileAccess.open(QA+"runtime_results.json",FileAccess.WRITE);f.store_string(JSON.stringify({"routes":results,"issues":issues,"inputs":inputs,"pages":pages},"  "));f.close()
 observations.close();app.queue_free();await process_frame;quit()
