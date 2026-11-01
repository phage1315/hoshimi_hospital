extends SceneTree
# Run this SAME external script against the project and --main-pack from an
# isolated directory. Never load/save player slots or construct restorable files.
var app
var out := ""
var packed := false
var checks := 0
var failures: Array = []
var resources: Dictionary = {}
var renders: Array = []
var gui: Array = []
var refs: Dictionary = {}
func _initialize():
 for arg in OS.get_cmdline_user_args():
  if arg=="--packed":packed=true
  if arg.begins_with("--out="):out=arg.trim_prefix("--out=")
 if out.is_empty():push_error("--out=<absolute directory> required");quit(2);return
 DirAccess.make_dir_recursive_absolute(out)
 call_deferred("run")
func check(ok: bool, detail: String):
 checks+=1
 if not ok:failures.append(detail);print("PARITY_FAIL ",detail)
func collect(value):
 if value is Dictionary:
  for k in value:collect(value[k])
 elif value is Array:
  for v in value:collect(v)
 elif value is String:
  var p=str(value).trim_prefix("res://")
  if p.begins_with("assets/") and p.get_extension().to_lower() in ["png","jpg","jpeg","webp","svg","ogg","wav","mp3","ogv","ttf","otf"]:refs[p]=true
func media():
 var result=[]
 for c in app.page.find_children("*","TextureRect",true,false):
  if c.texture:result.append({"name":str(c.name),"path":c.texture.resource_path,"size":[c.size.x,c.size.y],"position":[c.position.x,c.position.y]})
 return result
func has_texture(path:String)->bool:
 for row in media():
  if row.path=="res://"+path:return true
 return false
func click(button):
 await RenderingServer.frame_post_draw
 var point:Vector2=button.get_global_rect().get_center()
 var motion=InputEventMouseMotion.new();motion.position=point;root.push_input(motion,true)
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
func key(code):
 for down in [true,false]:
  var e=InputEventKey.new();e.keycode=code;e.pressed=down;root.push_input(e,true);await process_frame
func run():
 app=load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path=out.path_join("UNUSED_PLAYER_SLOT.json")
 root.add_child(app);await process_frame
 if packed:
  check(not FileAccess.file_exists("res://assets/events/advanced_referral_tutorial_chisato/chisato_postop_v1.png"),"PCK test must not fall back to loose source PNG")
 check(app.content.errors.is_empty(),"content loader: "+str(app.content.errors))
 collect(app.content.collections)
 var paths=refs.keys();paths.sort()
 for i in range(paths.size()):
  var p:String=paths[i];var full="res://"+p
  var exists=ResourceLoader.exists(full)
  check(exists,"resource missing "+p)
  if exists:
   var r=ResourceLoader.load(full,"",ResourceLoader.CACHE_MODE_IGNORE)
   check(r!=null,"resource failed to load "+p)
   var record={"type":r.get_class() if r else "null"}
   if r is Texture2D:record["dimensions"]=[r.get_width(),r.get_height()]
   resources[p]=record
  if i%200==0:print("RESOURCE_SCAN ",i,"/",paths.size())
  if i%24==0:await process_frame
 # Every distinct explicit event-media configuration, not only Chisato.
 var specs=[];var seen={}
 var fields=["cg_path","cg_fit","cg_portrait_overlay","portrait_path","portrait_scale","portrait_right","portrait_y","hide_portrait","secondary_portrait_path","secondary_portrait_scale","secondary_portrait_right","secondary_portrait_y","secondary_actor_id","secondary_outfit","secondary_expression","sound_path","actor_id","outfit","expression","event_portraits","cast_actor_ids"]
 var affected_nodes=0
 for collection in ["character_events","special_event_steps"]:
  for definition in app.content.collections[collection]:
   for node in definition.get("nodes",[]):
    if not ["cg_path","portrait_path","secondary_portrait_path","secondary_actor_id","sound_path"].any(func(k):return not str(node.get(k,"")).is_empty()):continue
    affected_nodes+=1
    var compact={"id":"export_parity","expression":"neutral"}
    for field in fields:
     if node.has(field):compact[field]=node[field]
    var actor_id=str(node.get("actor_id",definition.get("actor_id","")))
    var signature=collection+actor_id+JSON.stringify(compact)
    if seen.has(signature):continue
    seen[signature]=true;specs.append({"collection":collection,"node":compact,"actor":actor_id,"source":str(definition.id)+":"+str(node.id)})
 for locale in ["zh_CN","en"]:
  check(app.content.load_all(locale),"locale load "+locale);app.configure_game_content();app.game.reset();app.dialogue_auto_enabled=false
  for replay in [false,true]:
   for spec in specs:
    var n:Dictionary=spec.node
    app.screen=("special_gallery_replay" if replay else "special_event") if spec.collection=="special_event_steps" else ("gallery_replay" if replay else "character_event")
    app.last_character_sound_key=""
    app.base("Resource parity","",false,"operating_room")
    if spec.collection=="special_event_steps":app.add_special_event_visual(n)
    else:
     var actor=app.content.find_record("staff",spec.actor)
     app.add_character_event_visual(actor,n,str(n.get("outfit",actor.get("visuals",{}).get("default_outfit","white_coat"))))
    var expected=str(n.get("cg_path",""))
    if expected.is_empty() and not n.get("hide_portrait",false):expected=str(n.get("portrait_path",""))
    if not expected.is_empty():check(has_texture(expected),locale+" "+str(replay)+" "+spec.source+" render "+expected)
    if expected.is_empty() and not str(n.get("secondary_portrait_path","")).is_empty():check(has_texture(n.secondary_portrait_path),"secondary "+spec.source)
    if expected.is_empty() and n.has("secondary_actor_id"):
     var second=app.content.find_record("staff",str(n.secondary_actor_id))
     if not second.is_empty():
      var outfit=str(n.get("secondary_outfit",second.visuals.get("default_outfit","white_coat")))
      var portrait=str(second.visuals.portraits.get(outfit+"/"+str(n.get("secondary_expression","neutral")),second.visuals.portraits.get(outfit+"/neutral","")))
      if not portrait.is_empty():check(has_texture(portrait),"secondary actor "+spec.source)
    if not str(n.get("sound_path","")).is_empty():check(not app.page.find_children("*","AudioStreamPlayer",true,false).is_empty(),"audio "+spec.source)
    renders.append({"locale":locale,"replay":replay,"source":spec.source,"media":media()})
    await process_frame
   # Real story screens and GUI pagination for all ten distinct Chisato images.
   var definition=app.game.special_event_definitions["advanced_referral_tutorial_chisato"]
   var session=load("res://godot/systems/special_event_session.gd").new(definition,app.game.special_event_step_definitions,1)
   var images={}
   for step_index in range(definition.event_chain.size()):
    var step=app.game.special_event_step_definitions[definition.event_chain[step_index]]
    for node in step.nodes:
     var path=str(node.get("cg_path",node.get("portrait_path","")))
     if path.is_empty() or images.has(path):continue
     images[path]=true;session.step_index=step_index;session.node_id=node.id;app.reset_dialogue_page()
     if replay:app.special_event_gallery_replay=session;app.show_special_gallery_replay()
     else:app.game.active_special_event=session;app.game.active_special_event_id=definition.id;app.game.active_mode="special_event";app.show_special_event()
     await process_frame;await RenderingServer.frame_post_draw
     # CG intro can deliberately delay the controls; wait on its real guard.
     var deadline=Time.get_ticks_msec()+10000
     while Time.get_ticks_msec()<deadline:
      var buttons=app.page.find_children("SpecialReplayChoice_*" if replay else "SpecialEventChoice_*","Button",true,false)
      var ready=buttons.any(func(b):return b.visible and not b.disabled)
      var cont=app.page.get_node_or_null("SpecialReplayDialogueContinue" if replay else "SpecialEventDialogueContinue")
      if ready or (cont!=null and cont.visible and not cont.disabled):break
      await process_frame
     check(has_texture(path),"Chisato actual screen "+locale+" "+str(replay)+" "+node.id)
     var shot=locale+("_replay_" if replay else "_main_")+str(node.id)+".png"
     await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(out.path_join(shot))
     var row={"locale":locale,"replay":replay,"node":node.id,"media":media(),"text":app.current_dialogue_text(),"labels":[]}
     for label in app.page.find_children("*","Label",true,false):
      if label.visible:row.labels.append(label.text)
     var before_node=session.node_id;var before_text=app.current_dialogue_text()
     var cont=app.page.get_node_or_null("SpecialReplayDialogueContinue" if replay else "SpecialEventDialogueContinue")
     var buttons=app.page.find_children("SpecialReplayChoice_*" if replay else "SpecialEventChoice_*","Button",true,false)
     var target=cont if cont!=null else (buttons[0] if not buttons.is_empty() else null)
     if target!=null:
      if images.size()==1 and app.dialogue_default_button!=null:
       app.dialogue_auto_speed_index=3
       await click(app.page.get_node("DialogueAutoToggle"))
       var auto_deadline=Time.get_ticks_msec()+8000
       while session.node_id==before_node and app.current_dialogue_text()==before_text and Time.get_ticks_msec()<auto_deadline:await process_frame
       if app.page.get_node_or_null("DialogueAutoToggle")!=null:await click(app.page.get_node("DialogueAutoToggle"))
       check(not app.dialogue_auto_enabled,"auto playback toggled off")
      elif images.size()%3==0:target.grab_focus();await key(KEY_ENTER)
      elif images.size()%3==1:await click(target)
      else:target.grab_focus();await key(KEY_SPACE)
      check(session.node_id!=before_node or app.current_dialogue_text()!=before_text,"GUI advances "+locale+" "+str(replay)+" "+node.id)
     else:check(false,"Missing GUI continuation "+str(node.id))
     row["next_node"]=session.node_id;row["next_text"]=app.current_dialogue_text();row["next_media"]=media();gui.append(row)
   # Reward and gallery-specific gates share the media issue.
   for d in app.game.character_event_definitions.values():
    var path=str(d.get("gallery",{}).get("path",""))
    if path.is_empty():continue
    check(app.character_event_reward_available(d)==bool(d.gallery.get("show_on_complete",true)),"reward gate "+str(d.id))
    var completed=load("res://godot/systems/character_event_session.gd").new(d);completed.completed=true
    app.game.character_events[d.id]=completed
    app.show_gallery_entry(str(d.id));check(has_texture(path),"character gallery "+str(d.id))
    await process_frame
   for reward in app.game.staff_role_cg_definitions.values():
    if str(reward.get("path","")).is_empty():continue
    app.show_staff_role_reward(reward,func():pass)
    check(has_texture(str(reward.path)),"role reward "+str(reward.id))
    await process_frame
    app.game.unlock_staff_role_cg(str(reward.staff_id),str(reward.role_id))
    app.show_staff_role_gallery_entry(str(reward.id));check(has_texture(str(reward.path)),"role gallery "+str(reward.id))
    await process_frame
 var result={"checks":checks,"failures":failures,"resource_count":refs.size(),"affected_node_count":affected_nodes,"distinct_visual_configs":specs.size(),"resources":resources,"renders":renders,"gui":gui}
 var f=FileAccess.open(out.path_join("results.json"),FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));f.close()
 print("EXPORT PARITY checks=",checks," failures=",failures.size()," resources=",refs.size()," visual_configs=",specs.size());quit(0 if failures.is_empty() else 1)
