extends "res://tools/p1_native_base.gd"
# Targeted native screen reproduction only; direct setup is not route/entry proof.
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_repro_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 observations=FileAccess.open(QA+"reproduction_pages.jsonl",FileAccess.WRITE)
 var targets=[["sayaka_lv1_first_date","v2_623",false],["sayaka_lv1_first_date","v2_259",false],["intro_ishigami_nurse_manager","ishi0_011",false],["intro_ishigami_nurse_manager","ishi0_064",false],["sayaka_lv4_hotel_date","s08_087",false],["serika_radiology_d01","d01_03",false]]
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  for target in targets:
   for replay in [false,true]:
    var g=app.game;g.reset();app.show_map(false);app.reset_dialogue_page();app.dialogue_auto_enabled=false
    var d=(g.special_event_definitions if target[2] else g.character_event_definitions)[target[0]]
    var session
    if target[2]:
     session=Special.new(d,g.special_event_step_definitions,1);session.node_id=target[1]
     if replay:g.special_event_completion_counts[d.id]=1;app.special_event_gallery_replay=session;app.special_event_replay_last_cg_path="";app.show_special_gallery_replay()
     else:g.active_special_event=session;g.active_special_event_id=d.id;g.active_mode="special_event";app.special_event_last_cg_path="";app.show_special_event()
    else:
     session=Character.new(d);session.node_id=target[1]
     if replay:
      var completed=Character.new(d);completed.completed=true;completed.completed_day=1;completed.settled_minutes=int(d.minutes);g.character_events[d.id]=completed;g.character_event_order.append(d.id);app.gallery_replay_event=session;app.gallery_replay_is_test=false;app.show_gallery_replay()
     else:g.character_events[d.id]=session;g.character_event_order.append(d.id);g.active_character_event_id=d.id;g.active_mode="character_event";app.show_character_event()
    await process_frame
    await RenderingServer.frame_post_draw
    context={"event":target[0],"locale":locale,"node":target[1],"replay":replay,"route":"targeted_screen_reproduction"}
    for page_number in range(20):
     inspect(session.current(),d,target[2],replay)
     await capture("repro_"+target[1]+("_replay" if replay else "_main")+"_p"+str(page_number))
     var button_name=("SpecialReplayDialogueContinue" if replay else "SpecialEventDialogueContinue") if target[2] else ("ReplayDialogueContinue" if replay else "EventDialogueContinue")
     var next_page=app.page.get_node_or_null(button_name)
     if next_page==null:break
     await click(next_page)
    if replay:
     var before_time=g.elapsed();var before_rel=g.relationships.duplicate(true)
     for b in app.page.find_children("*","Button",true,false):
      if b.text==app.tx("ui.gallery.exit_replay","退出回想"):await click(b);break
     results.append({"event":d.id,"locale":locale,"exit_screen":app.screen,"time_unchanged":g.elapsed()==before_time,"relationships_unchanged":g.relationships==before_rel})
 var f=FileAccess.open(QA+"reproduction_results.json",FileAccess.WRITE);f.store_string(JSON.stringify({"results":results,"issues":issues},"  "));f.close();observations.close();app.queue_free();await process_frame;quit()
