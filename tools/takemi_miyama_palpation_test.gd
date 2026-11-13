extends "res://tools/game_random_40_screens.gd"
const OUT = "/private/tmp/takemi_miyama_palpation_qa/"
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
 DirAccess.make_dir_recursive_absolute(OUT)
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
   d=app.game.special_event_definitions["miyama_01_safety_pin"];ev=Special.new(d,app.game.special_event_step_definitions,1);ev.node_id="klv1_125"
   if replay:app.game.special_event_completion_counts[d.id]=1;app.special_event_gallery_replay=ev;app.show_special_gallery_replay()
   else:app.game.active_special_event=ev;app.game.active_special_event_id=d.id;app.game.active_mode="special_event";app.show_special_event()
   var elapsed=app.game.elapsed();var preops=app.game.preops.size();var xp=app.game.surgery_xp;var flags=app.game.story_flags.duplicate(true)
   var expected_screen="special_gallery_replay" if replay else "special_event"
   check(app.screen==expected_screen,prefix+" V2.3 palpation stays in authored VN screen")
   for guard in range(6):
    var buttons=app.page.find_children("SpecialReplayChoice_*" if replay else "SpecialEventChoice_*","Button",true,false)
    var cont=app.page.get_node_or_null("SpecialReplayDialogueContinue" if replay else "SpecialEventDialogueContinue")
    await click(cont if cont!=null else buttons[0])
    check(app.screen==expected_screen,prefix+" V2.3 palpation never hijacks into free palpation UI")
   await capture(prefix+"_kaori_v23_palpation")
   check(app.game.elapsed()==elapsed and app.game.preops.size()==preops,prefix+" no clinical session/time")
   check(app.game.surgery_xp==xp and app.game.story_flags==flags,prefix+" no early XP or flags")

 var f=FileAccess.open(OUT+"results.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"observations":captures},"  "));f.close()
 print("PALPATION_QA checks=",checks," failures=",failures.size());quit(0 if failures.is_empty() else 1)
