extends "res://tools/game_random_40_screens.gd"
const OUT = "res://docs/qa/takemi_miyama_palpation_2026-10-27/"
var checks := 0
var captures:Array = []
var failures:Array = []
func check(ok:bool, message:String):
 checks += 1
 if not ok: failures.append(message);print("FAIL ",message)
func capture(name:String):
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OUT+name+".png")
 var row={"shot":name,"labels":label_texts(),"textures":[]}
 for c in app.page.find_children("*","TextureRect",true,false):
  if c.texture:row.textures.append({"name":str(c.name),"path":c.texture.resource_path,"size":str(c.size),"position":str(c.position)})
 captures.append(row)
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_palpation_unused.json";root.add_child(app);await process_frame
 for locale in ["zh_CN","en"]:
  for replay in [false,true]:
   var prefix=locale+("_replay" if replay else "_main")
   reset_scene(locale)
   var d=app.game.character_event_definitions["takemi_lv0_t6"];var ev=Character.new(d)
   for nid in ["t6_14","t6_15","t6_60"]:
    ev.node_id=nid
    if replay:app.gallery_replay_event=ev;app.show_gallery_replay()
    else:app.game.character_events[d.id]=ev;app.game.active_character_event_id=d.id;app.game.active_mode="character_event";app.show_character_event()
    var portrait=app.page.get_node_or_null("EventCast_doc_takemi")
    if nid=="t6_15":check(portrait==null,prefix+" CG hides portrait")
    else:check(portrait!=null and portrait.size==Vector2(450,500),prefix+" "+nid+" normal portrait")
    await capture(prefix+"_"+nid)
   reset_scene(locale)
   d=app.game.special_event_definitions["miyama_01_safety_pin"];ev=Special.new(d,app.game.special_event_step_definitions,1);ev.node_id="recheck"
   if replay:app.game.special_event_completion_counts[d.id]=1;app.special_event_gallery_replay=ev;app.show_special_gallery_replay()
   else:app.game.active_special_event=ev;app.game.active_special_event_id=d.id;app.game.active_mode="special_event";app.show_special_event()
   var elapsed=app.game.elapsed();var preops=app.game.preops.size();var xp=app.game.surgery_xp;var flags=app.game.story_flags.duplicate(true)
   for guard in range(12):
    if ev.current().id!="recheck":break
    var buttons=app.page.find_children("SpecialReplayChoice_*" if replay else "SpecialEventChoice_*","Button",true,false)
    var cont=app.page.get_node_or_null("SpecialReplayDialogueContinue" if replay else "SpecialEventDialogueContinue")
    await click(cont if cont!=null else buttons[0])
   check(ev.current().id=="palpation_placeholder" and app.screen=="or_table_palpation",prefix+" GUI enters palpation")
   for tool in ["needle","scalpel"]:
    var button=app.page.get_node_or_null("PalpationTool_"+tool)
    check(button!=null and button.disabled,prefix+" disabled "+tool)
    await click(button)
    check(app.or_table_palpation_tool=="palpation",prefix+" tool remains hand")
   var controller=app.page.get_meta("story_palpation_controller")
   controller.select_tool("scalpel");check(app.or_table_palpation_tool=="palpation",prefix+" handler rejects scalpel")
   for strength in ["light","standard","deep"]:
    await click(app.page.get_node("PalpationStrength_"+strength))
    await click(app.page.get_node("PalpationHotspot_abdomen_0"))
    check(str(app.page.get_node("PalpationFeedbackText").text)==app.tx("ui.miyama_palpation.inconclusive","患者紧绷，疼痛定位和腹壁反应无法可靠解释。"),prefix+" fixed abdomen "+strength)
   await capture(prefix+"_abdomen")
   for region in ["breast","genital"]:
    await click(app.page.get_node("PalpationHotspot_"+region+"_0"))
    var first=str(app.page.get_node("PalpationFeedbackText").text)
    await click(app.page.get_node("PalpationHotspot_"+region+"_0"))
    check(first==str(app.page.get_node("PalpationFeedbackText").text),prefix+" fixed shame response "+region)
    await capture(prefix+"_"+region)
   check(app.game.elapsed()==elapsed and app.game.preops.size()==preops,prefix+" no clinical session/time")
   check(app.game.surgery_xp==xp and app.game.story_flags==flags,prefix+" no early XP or flags")
   var complete=app.page.get_node("PalpationComplete")
   if replay:complete.grab_focus();await key(KEY_ENTER)
   else:await click(complete)
   check(ev.current().id=="decision",prefix+" returns to original decision")
   await capture(prefix+"_decision")
   controller.finish();check(ev.current().id=="decision",prefix+" stale finish ignored")
   ev.node_id="palpation_placeholder"
   if replay:app.show_special_gallery_replay()
   else:app.show_special_event()
   await click(app.page.get_node("PalpationComplete"))
   check(ev.current().id=="decision",prefix+" skip without touching")
   if replay:
    ev.node_id="palpation_placeholder";app.show_special_gallery_replay()
    for b in app.page.find_children("*","Button",true,false):
     if b.text==app.tx("ui.gallery.exit_replay","退出回想"):
      await click(b);break
    check(app.screen!="or_table_palpation",prefix+" exit replay")

 var f=FileAccess.open(OUT+"results.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"observations":captures},"  "));f.close()
 print("PALPATION_QA checks=",checks," failures=",failures.size());quit(0 if failures.is_empty() else 1)
