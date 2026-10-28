extends "res://tools/event_batch_entry_qa.gd"
var extra:Array=[]
func ui_record(tag:String):
 var labels:Array=[]
 for c in app.page.find_children("*","Label",true,false):
  if c.is_visible_in_tree():labels.append(c.text)
 var buttons:Array=[]
 for c in app.page.find_children("*","Button",true,false):
  if c.is_visible_in_tree():buttons.append(c.text)
 extra.append({"event":context.event,"locale":context.locale,"kind":tag,"screen":app.screen,"labels":labels,"buttons":buttons,"active_character":app.game.active_character_event_id,"active_special":app.game.active_special_event_id})
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_extra_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 var scope=JSON.parse_string(FileAccess.get_file_as_string(QA+"scope.json"))
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  for row in scope:
   context={"event":row.id,"locale":locale};var g=app.game;var special=row.type=="special_events";var d=(g.special_event_definitions if special else g.character_event_definitions)[row.id]
   fixture(g,d,special);app.dialogue_auto_enabled=false;app.reset_dialogue_page()
   if special:
    app.show_map();await process_frame;ui_record("real_day_start_offer");await capture("day_start_offer")
    if app.screen=="special_event_confirm":
     for b in app.page.find_children("*","Button",true,false):
      if b.text==app.tx("ui.auto.b638db7ded07","开始活动"):await click(b);break
    ui_record("real_day_start_entered");await capture("day_start_entered")
   if row.id=="hiroko_lv1_or_instrument_panic":
    g.relation_for("nurse_moe").familiarity=9;extra.append({"event":row.id,"locale":locale,"kind":"moe_familiarity_9","available":g.character_event_available(d)})
    g.relation_for("nurse_moe").familiarity=10;extra.append({"event":row.id,"locale":locale,"kind":"moe_familiarity_10","available":g.character_event_available(d)})
    seed_done(g,"hiroko_patient_escape");set_clock(g,10,780);app.show_location("or");await process_frame;ui_record("hiroko_valid_entry");await capture("valid_entry")
   # UI localization and replay interruption: completed facts, never session restore.
   g.reset();seed_done(g,row.id);app.show_map(false)
   for child in app.get_children():
    if child is Window:child.hide()
   if special:app.show_special_gallery_entry(row.id)
   else:app.show_gallery_entry(row.id)
   await process_frame;ui_record("gallery_entry")
   if special:app.special_event_gallery_replay=Special.new(d,g.special_event_step_definitions,1);app.special_event_replay_last_cg_path="";app.show_special_gallery_replay()
   else:app.gallery_replay_event=Character.new(d);app.gallery_replay_is_test=false;app.show_gallery_replay()
   await process_frame;ui_record("replay_open")
   var before_time=g.elapsed();var before_rel=g.relationships.duplicate(true)
   for b in app.page.find_children("*","Button",true,false):
    if b.text==app.tx("ui.gallery.exit_replay","退出回想"):await click(b);break
   ui_record("replay_interrupted")
   extra.append({"event":row.id,"locale":locale,"kind":"replay_exit_integrity","time_unchanged":g.elapsed()==before_time,"relationships_unchanged":g.relationships==before_rel})
   g.reset();app.show_map(false)
 var f=FileAccess.open(QA+"extra_results.json",FileAccess.WRITE);f.store_string(JSON.stringify(extra,"  "));f.close();app.queue_free();await process_frame;quit()
