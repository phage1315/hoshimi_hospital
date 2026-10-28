extends "res://tools/p1_native_base.gd"
const OUT="res://docs/qa/followup_event_fixes_2026-10-27/"
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_opening_unused.json";root.add_child(app);await process_frame
 var records:Array=[]
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  for replay in [false,true]:
   app.game.reset();app.reset_dialogue_page();app.dialogue_auto_enabled=false
   var d=app.game.special_event_definitions["advanced_referral_tutorial_chisato"];var event=Special.new(d,app.game.special_event_step_definitions,1)
   if replay:app.special_event_gallery_replay=event;app.show_special_gallery_replay()
   else:app.game.active_special_event=event;app.game.active_special_event_id=d.id;app.game.active_mode="special_event";app.show_special_event()
   var texts:Array=[]
   for guard in range(15):
    if event.current().id!="opening":break
    await process_frame;await RenderingServer.frame_post_draw
    texts.append(app.current_dialogue_text())
    root.get_texture().get_image().save_png(OUT+"opening_"+locale+("_replay_" if replay else "live_")+str(guard)+".png")
    var button=app.page.get_node_or_null("SpecialReplayDialogueContinue" if replay else "SpecialEventDialogueContinue")
    if button==null:button=app.page.get_node_or_null(("SpecialReplayChoice_" if replay else "SpecialEventChoice_")+"opening_next")
    if button==null:print("OPENING_MISSING_BUTTON");quit(1);return
    if guard%2==0:await click(button)
    else:await key(KEY_ENTER)
   var expected=app.special_event_localized_text(app.game.special_event_step_definitions[d.event_chain[0]],app.game.special_event_step_definitions[d.event_chain[0]].nodes[0])
   var observed="".join(texts);var regex=RegEx.new();regex.compile("\\s+")
   var matches=regex.sub(expected,"",true)==regex.sub(observed,"",true)
   records.append({"locale":locale,"replay":replay,"pages":texts,"text_complete_ignoring_layout_whitespace":matches,"next_node":event.current().id})
   if not matches:print("OPENING_TEXT_MISMATCH")
 var f=FileAccess.open(OUT+"opening_results.json",FileAccess.WRITE);f.store_string(JSON.stringify(records,"  "));f.close();print("OPENING_DONE ",JSON.stringify(records));quit()
