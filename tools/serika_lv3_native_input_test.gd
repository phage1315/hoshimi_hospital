extends "res://tools/serika_lv3_test.gd"
# Native rendered input-path QA. Only the initial session/prerequisites are
# injected in memory; advancement uses viewport mouse/key events, not callbacks.
const QA := "res://docs/qa/followup_event_fixes_2026-10-27/serika_native/"
var input_counts := {"mouse":0,"space":0,"enter":0,"auto":0}
var screenshots:=0
var pages_seen:=0
var speaker_pages_checked:=0
var source_review:Dictionary={}
func check_speaker_and_cast(app,node:Dictionary,locale:String)->void:
 var review:Dictionary=source_review[str(node.id)]
 var expected_name:=str(review.speaker_en if locale=="en" else review.speaker_zh_CN)
 var expected_role:="actor" if review.speaker_zh_CN=="御園芹香" else "player" if review.speaker_zh_CN=="坂口隆司" else "narrator"
 expect(node.speaker==expected_role and node.speaker_label==expected_name,"Localized speaker matches audited author source "+str(node.id))
 var labels:Array=[]
 for child in app.page.get_children():
  if child is Label and child.position==Vector2(82,558):labels.append(child)
 expect(labels.size()==1,"Exactly one visible speaker label")
 if labels.size()==1:expect(labels[0].text==expected_name and labels[0].is_visible_in_tree(),"Actual speaker name equals source "+str(node.id))
 var portraits:Array=app.page.find_children("EventPortrait_*","TextureRect",true,false)
 var expected_cast:Array=[] if not expected_cg(str(node.id)).is_empty() or bool(node.hide_portrait) else node.event_portraits
 expect(portraits.size()==expected_cast.size(),"Exact cast count; no stale portrait")
 for item in expected_cast:
  var portrait=app.page.get_node_or_null("EventPortrait_"+str(item.id))
  expect(item.id==Flow.ACTOR and portrait!=null,"Authored Serika cast identity")
  if portrait!=null:
   expect(portrait.texture!=null and portrait.texture.resource_path=="res://"+str(item.path),"Exact portrait texture, outfit and expression")
   expect(str(item.path).get_file().get_basename()==str(node.expression),"Portrait filename matches expression configuration")
 expect(app.page.find_child("EventPortrait_player",true,false)==null,"POV protagonist has no substitute portrait")
 speaker_pages_checked+=1
func click_control(control:Control)->void:
 var point:=control.get_global_rect().get_center()
 var move:=InputEventMouseMotion.new();move.position=point;move.global_position=point
 root.push_input(move,true)
 for pressed in [true,false]:
  var event:=InputEventMouseButton.new()
  event.button_index=MOUSE_BUTTON_LEFT;event.pressed=pressed
  event.position=point;event.global_position=point
  root.push_input(event,true)
  await process_frame
 input_counts.mouse+=1
func press_key(key:Key)->void:
 for pressed in [true,false]:
  var event:=InputEventKey.new();event.keycode=key;event.pressed=pressed
  root.push_input(event,true)
  await process_frame
 input_counts["space" if key==KEY_SPACE else "enter"]+=1
func shot(locale:String,name:String)->void:
 await process_frame
 await RenderingServer.frame_post_draw
 expect(root.get_texture().get_image().save_png(QA+locale+"_"+name+".png")==OK,"Save native screenshot")
 screenshots+=1
func run()->void:
 if DisplayServer.get_name()=="headless":
  push_error("This test requires a native rendered window.");quit(1);return
 DirAccess.make_dir_recursive_absolute(QA)
 for review in JSON.parse_string(FileAccess.get_file_as_string("res://docs/source/serika_lv3/lv3_bilingual_review.json")):
  source_review[str(review.source_id).to_lower().replace("-","_")]=review
 var app=load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path="/tmp/hoshimi_serika_lv3_native_unused_"+str(OS.get_process_id())+".json"
 root.add_child(app);await process_frame
 for locale in ["zh_CN","en"]:
  expect(app.content.load_all(locale),"Load "+locale);app.configure_game_content()
  var g=app.game
  setup(g)
  var definition:Dictionary=g.character_event_definitions[Flow.ID]
  expect(Flow.PREREQUISITES_CONNECTED,"Production entry configuration enabled")
  g.set_story_flag(Flow.MIZUHO_CHAIN_FACT,false)
  expect(g.start_character_event(Flow.ID)==null,"Lv2 alone cannot bypass unfinished Mizuho chain")
  app.show_sunday_menu();await process_frame
  expect(app.page.get_node_or_null("SerikaLv3WalkAlone")==null,"Actual menu hides route without Mizuho completion")
  await shot(locale,"missing_mizuho_gate")
  g.set_story_flag(Flow.MIZUHO_CHAIN_FACT)
  app.show_sunday_menu();await process_frame
  var walk=app.page.get_node_or_null("SerikaLv3WalkAlone")
  expect(walk!=null,"Simulated future full facts reveal actual Sunday button")
  await shot(locale,"future_positive_menu")
  var before:int=g.elapsed();var before_day:int=g.day_number()
  var attributes:Dictionary=g.player_attributes().duplicate(true)
  if walk==null:quit(1);return
  await click_control(walk)
  var event=g.character_events.get(Flow.ID)
  expect(event!=null and app.screen=="character_event","Actual menu callback enters event")
  if event==null:quit(1);return
  app.dialogue_auto_enabled=false
  for i in range(definition.nodes.size()):
   var node:Dictionary=definition.nodes[i]
   await process_frame
   expect(not event.completed and event.current().id==node.id,"Input reaches exact next node "+node.id)
   if event.completed or event.current().id!=node.id:break
   check_cg(app,node)
   expect(g.elapsed()==before and g.relationship_level(Flow.ACTOR)==2,"No premature time/relationship settlement")
   expect(not g.can_save_progress(),"No mid-event save")
   var pages:Array=app.authored_dialogue_pages(str(node.text))
   for page_index in range(pages.size()):
    await process_frame
    expect(app.current_dialogue_text()==pages[page_index],"Rendered page matches complete localized text")
    check_speaker_and_cast(app,node,locale)
    var button:Button=app.dialogue_default_button
    expect(is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled,"Continue visible and enabled")
    if not is_instance_valid(button):break
    expect(Rect2(Vector2.ZERO,app.size).encloses(button.get_global_rect()),"Continue remains inside viewport")
    for label in app.page.find_children("*","RichTextLabel",true,false):
     if label.text==pages[page_index]:
      expect(label.get_content_height()<=label.size.y,"All rendered dialogue lines fit: "+str(node.id))
    if page_index==0 and str(node.id) in ["s01_02","s02_36","s03_34","s04_13","s04_23","s04_33","s04_37","s05_37","s05_41"]:
     await shot(locale,str(node.id))
    # Exercise the actual Auto toggle and timer on one ordinary single-page beat.
    if str(node.id)=="s01_04" and pages.size()==1:
     await click_control(app.dialogue_auto_toggle_button)
     expect(app.dialogue_auto_enabled,"Mouse toggles auto on")
     var deadline:=Time.get_ticks_msec()+15000
     while event.current().id==node.id and Time.get_ticks_msec()<deadline:
      await create_timer(0.05).timeout
     expect(event.current().id==definition.nodes[i+1].id,"Auto advances exactly one beat before stop")
     await click_control(app.dialogue_auto_toggle_button)
     expect(not app.dialogue_auto_enabled,"Mouse toggles auto off")
     input_counts.auto+=1
    elif pages_seen%3==0:await click_control(button)
    elif pages_seen%3==1:await press_key(KEY_SPACE)
    else:await press_key(KEY_ENTER)
    pages_seen+=1
    if page_index+1<pages.size():expect(event.current().id==node.id and app.dialogue_page_index==page_index+1,"Input turns a page without skipping node")
  expect(event.completed and app.screen=="sunday_complete","Full input-driven event reaches completion")
  expect(g.relationship_level(Flow.ACTOR)==3 and g.familiarity_gain_multiplier(Flow.ACTOR)==0.8,"Final rank and multiplier")
  expect(g.sunday_date_eligible(Flow.ACTOR),"Final normal date qualification")
  expect(g.day_number()==before_day+1 and g.current_absolute_clock()==540,"One Sunday settles to Monday09:00")
  expect(g.sunday_history.size()==1 and g.player_attributes()==attributes,"One settlement, no bonus attributes")
  expect(app.page.find_child("CharacterEventCG",true,false)==null,"Final screen clears CG")
  await shot(locale,"complete")
  # Start only the replay session directly; every replay advance uses GUI input.
  app.show_map(false)
  var settled:Dictionary=g.snapshot()
  app.show_gallery_entry(Flow.ID);await process_frame
  await shot(locale,"gallery")
  var replay_button:Button
  for child in app.page.get_children():
   if child is Button and child.text.replace(" ","")==app.tx("ui.gallery.replay_event","回想事件  →").replace(" ",""):replay_button=child
  expect(replay_button!=null,"Actual replay button exists")
  if replay_button!=null:await click_control(replay_button)
  expect(app.screen=="gallery_replay","Mouse starts gallery replay")
  for node in definition.nodes:
   expect(app.gallery_replay_event.current().id==node.id,"Replay input order")
   if app.gallery_replay_event.current().id!=node.id:break
   check_cg(app,node)
   for page_text in app.authored_dialogue_pages(str(node.text)):
    expect(app.current_dialogue_text()==page_text,"Replay localized page displayed")
    check_speaker_and_cast(app,node,locale)
    await press_key(KEY_ENTER)
  expect(app.screen=="gallery_entry" and g.snapshot()==settled,"Replay returns to gallery without time/reward mutation")
  print("NATIVE INPUT completed locale ",locale)
 var results={"checks":checks,"failures":failures,"locales":["zh_CN","en"],"input_counts":input_counts,"live_dialogue_pages":pages_seen,"speaker_and_cast_pages_checked":speaker_pages_checked,"screenshots":screenshots,"display_server":DisplayServer.get_name(),"player_slots_touched":false,"production_entry_connected":true,"positive_entry_fixture":"future Mizuho completion in isolated memory only"}
 var file=FileAccess.open(QA+"results.json",FileAccess.WRITE);file.store_string(JSON.stringify(results,"  "));file.close()
 print("SERIKA LV3 NATIVE INPUT: ",JSON.stringify(results))
 app.queue_free();await process_frame
 quit(1 if failures else 0)
