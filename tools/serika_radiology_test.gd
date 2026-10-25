extends SceneTree
const Flow = preload("res://godot/systems/serika_radiology.gd")
const Event = preload("res://godot/systems/character_event_session.gd")
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
func milestone_fixture(g, level: int) -> void:
 # Only this isolated fixture supplies future authored milestones.
 var id := "test_serika_milestone_%s" % level
 var d: Dictionary = g.character_event_definitions.serika_lv0_d.duplicate(true)
 d.id = id
 d.category = "bond" if level == 1 else "rank_up"
 d.target_level = level
 g.character_event_definitions[id] = d
 complete_fixture(g, id)
 var slot: Dictionary = g.relationship_rank_slot(Flow.ACTOR, level)
 slot.event_id = id
 slot.content_status = "authored"
 var r: Dictionary = g.relation_for(Flow.ACTOR)
 if id not in r.rank_history:r.rank_history.append(id)
 r.level = maxi(int(r.level), level)
func run() -> void:
 var app = load("res://godot/scenes/main.tscn").instantiate()
 root.add_child(app)
 await process_frame
 var locales := ["zh_CN"] if "--cn-only" in OS.get_cmdline_user_args() else ["zh_CN", "en"]
 for locale in locales:
  expect(app.content.load_all(locale), "Load " + locale)
  app.configure_game_content()
  var g = app.game
  g.reset()
  expect(Flow.next_index(g) == 1, "New game starts D01")
  expect(not Flow.eligible(g, Flow.event_id(1)), "Unmet blocked")
  g.meet_staff(Flow.ACTOR)
  expect(not Flow.eligible(g, Flow.event_id(1)), "Met alone cannot bypass four-stage intro")
  for stage in ["a","b","c","d"]:complete_fixture(g,"serika_lv0_"+stage)
  # Old discussions are paid history, not D01-D03 completion.
  g.time_log.append({"id":"serika_imaging_discussion","start":0,"minutes":60})
  g.relation_for(Flow.ACTOR).familiarity = 3
  g.set_story_flag("serika_imaging_discussed:%s" % g.day_number())
  var old: Dictionary = g.snapshot()
  expect(g.restore(old), "Retired random discussion save remains readable")
  expect(g.elapsed() == 60 and Flow.next_index(g) == 1 and g.relation_for(Flow.ACTOR).familiarity == 3, "No historical refund or guessed progress")
  expect(not Flow.eligible(g, Flow.event_id(1)), "Old discussion still consumes today's limit")
  # A save made before today's first presence check must not reroll either.
  g.advance_story_to_day(4,540)
  var unrolled: Dictionary = g.snapshot()
  var attendance: bool = Flow.ACTOR in g.staff_present_at("imaging")
  expect(g.restore(unrolled), "Restore before first daily roll")
  expect((Flow.ACTOR in g.staff_present_at("imaging"))==attendance, "Seed stabilizes previously unrolled day")
  g.advance_story_to_day(5,1000)
  g.set_story_flag("serika_imaging_present:5",true)
  expect(g.start_character_event(Flow.event_id(1))==null and Flow.next_index(g)==1, "Insufficient time blocks new scene")
  var attrs: Dictionary = g.player_attributes().duplicate(true)
  for i in range(1,16):
   var id := Flow.event_id(i)
   g.advance_story_to_day(i+5,540)
   g.set_story_flag("serika_imaging_present:%s" % g.day_number(),false)
   var before: int = g.elapsed()
   var fam: int = g.relation_for(Flow.ACTOR).familiarity
   expect(g.start_character_event(id)==null, "Absent blocks without cost")
   g.set_story_flag("serika_imaging_present:%s" % g.day_number(),true)
   if i in [6,11]:
    g.relation_for(Flow.ACTOR).level = 5
    g.set_test_player_attribute("skill",99)
    expect(not Flow.eligible(g,id), "Displayed rank and high skill cannot replace milestone")
    g.relation_for(Flow.ACTOR).level = 0 if i==6 else 1
    g.set_test_player_attribute("skill",int(attrs.skill))
    milestone_fixture(g,1 if i==6 else 2)
   expect(g.start_character_event(Flow.event_id(i+1))==null,"Cannot skip next discussion")
   expect(not g.spend_time("serika_imaging_discussion"),"Retired reward command denied")
   expect(g.elapsed()==before and g.relation_for(Flow.ACTOR).familiarity==fam,"Rejected requests leave resources untouched")
   app.show_location("imaging",true,false)
   app.location_staff_drawer_open="imaging"
   app.show_location("imaging",true,false)
   expect(app.page.find_child("SerikaRadiologyDiscussion",true,false)!=null,"Real discussion button")
   app.start_serika_radiology(id)
   var event = g.character_events.get(id)
   if event != null and event.current().is_empty():quit(1);return
   expect(event!=null,"Starts "+id)
   if event==null:continue
   expect(not g.can_save_progress() and g.snapshot().is_empty(),"No mid-event persistent save")
   expect(g.start_character_event(id)==null,"Double start denied")
   # Interrupt once, then restart at OPEN without settlement.
   if i==1:
    g.choose_character_event(str(event.current().choices[0].id))
    g.active_character_event_id=""
    g.active_mode="encounter"
    app.start_serika_radiology(id)
    event=g.character_events[id]
    expect(event.node_id==event.definition.start and g.elapsed()==before and g.relation_for(Flow.ACTOR).familiarity==fam,"Abandoned scene restarts free")
   var final_choice := ""
   for node in event.definition.nodes:
    expect(event.current().id==node.id,"Authored node order")
    expect(g.elapsed()==before and g.relation_for(Flow.ACTOR).familiarity==fam,"No reward or cost before END")
    app.show_character_event()
    expect(app.page.get_node_or_null("CharacterPortrait")!=null,"Serika portrait loaded")
    final_choice=str(node.choices[0].id)
    if node.choices[0].next == "@end":
     app.choose_character_event(final_choice)
     expect(app.screen == "location" and g.active_character_event_id.is_empty(), "Final UI callback returns to imaging")
     expect(g.can_save_progress(), "Returned location is a save boundary")
    else:
     expect(g.choose_character_event(final_choice),"Advance")
   expect(event.completed,"Completed")
   expect(g.elapsed()==before+60 and g.relation_for(Flow.ACTOR).familiarity==fam+3,"Atomic final 60min and fixed +3")
   expect(not g.choose_character_event(final_choice),"Repeated END cannot pay again")
   g.finish_character_event()
   expect(Flow.next_index(g)==i+1,"Single monotonic next discussion")
   expect(not Flow.eligible(g,Flow.event_id(i+1)),"Daily limit")
   expect(g.start_character_event(Flow.event_id(i+1))==null,"Direct double discussion same day denied")
   expect(not g.staff_can_join_surgery_team(Flow.ACTOR) if i<11 else g.staff_can_join_surgery_team(Flow.ACTOR),"Only real Lv2 milestone grants assistant")
   var saved: Dictionary=g.snapshot()
   var serialized := JSON.stringify(saved)
   expect(not serialized.contains('"node_id"') and not serialized.contains('"choices"'),"No inner-state save")
   var definition: Dictionary=g.character_event_definitions[id]
   var nodes: Array=definition.nodes
   definition.nodes=[]
   definition.minutes=999
   expect(g.restore(JSON.parse_string(serialized)),"Restore despite removed old scene nodes")
   expect(g.elapsed()==before+60 and Flow.next_index(g)==i+1 and g.relation_for(Flow.ACTOR).familiarity==fam+3,"Historical settlement independent of script")
   definition.nodes=nodes
   definition.minutes=60
   if i>=6:milestone_fixture(g,1)
   if i>=11:milestone_fixture(g,2)
  expect(g.relation_for(Flow.ACTOR).familiarity==48,"15 discussions total +45, preserving old +3")
  expect(g.player_attributes()==attrs,"No other attribute reward")
  g.advance_story_to_day(30,540)
  g.set_story_flag("serika_imaging_present:%s" % g.day_number(),true)
  app.location_staff_drawer_open="imaging"
  app.show_location("imaging",true,false)
  expect(app.page.find_child("SerikaRadiologyDiscussion",true,false)==null,"D15 permanently removes entry")
  expect(g.start_character_event(Flow.event_id(15))==null,"Finished chain cannot replay")
  expect(g.spend_time("serika_imaging_chat"),"Free ordinary chat remains")
  expect(g.relation_for(Flow.ACTOR).familiarity==48,"Idle has no reward")
 print("SERIKA RADIOLOGY: %s checks; %s failures" % [checks, failures])
 quit(1 if failures else 0)
