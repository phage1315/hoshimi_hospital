extends SceneTree
const ACTOR := "doc_serika"
var checks := 0
var failures := 0
func expect(ok: bool, message: String) -> void:
 checks += 1
 if not ok:
  failures += 1
  push_error(message)
func _initialize() -> void:
 call_deferred("run")
func no_inner(value: Variant) -> void:
 if value is Dictionary:
  for k in value:
   expect(k not in ["node_id", "choices", "last_choice", "action_log", "stage_id", "response_index"], "No inner state: " + str(k))
   no_inner(value[k])
 elif value is Array:
  for v in value:no_inner(v)
func play(app: Node, id: String, place: String) -> void:
 var g = app.game
 var before: int = g.elapsed()
 var event = g.start_character_event(id)
 expect(event != null, "Start " + id)
 if event == null:return
 app.character_event_return_location = place
 app.character_event_from_test = false
 while not event.completed:
  expect(not g.staff_is_met(ACTOR), "No premature met " + id)
  expect(not g.can_save_progress(), "No mid-event save")
  expect(g.snapshot().is_empty(), "No resumable snapshot")
  app.show_character_event()
  app.choose_character_event(str(event.current().choices[0].id))
 expect(g.elapsed() == before, "Zero added time " + id)
 expect(g.active_character_event_id.is_empty(), "Direct return " + id)
 expect(g.character_event_done(id), "Completed " + id)
func run() -> void:
 var app = load("res://godot/scenes/main.tscn").instantiate()
 root.add_child(app)
 await process_frame
 for locale in ["zh_CN", "en"]:
  expect(app.content.load_all(locale), "Load " + locale)
  app.configure_game_content()
  var g = app.game
  g.reset()
  var defs := {}
  for id in ["serika_lv0_a", "serika_lv0_b", "serika_lv0_c", "serika_lv0_d"]:defs[id] = g.character_event_definitions[id]
  g.character_event_definitions = defs
  g.set_test_player_attribute("reputation",49)
  expect(g.next_hospital_corridor_event().is_empty(), "Rep49")
  g.set_test_player_attribute("reputation",50)
  expect(g.next_hospital_corridor_event().get("id","") == "serika_lv0_a", "Rep50")
  for id in ["serika_lv0_b","serika_lv0_c","serika_lv0_d"]:expect(not g.character_event_available(defs[id]), "No skipping")
  expect(ACTOR not in g.staff_present_at("imaging"), "No early presence")
  app.show_location("ward")
  expect(g.active_character_event_id == "serika_lv0_a", "Real corridor navigation hook")
  play(app,"serika_lv0_a","ward")
  var snap: Dictionary = g.snapshot()
  no_inner(snap)
  expect(g.restore(JSON.parse_string(JSON.stringify(snap))), "Save after A")
  expect(not g.staff_is_met(ACTOR), "A not met")
  g.set_test_player_attribute("reputation",99)
  expect(not g.character_event_available(defs.serika_lv0_b), "Rep99")
  g.set_test_player_attribute("reputation",100)
  expect(g.character_event_available(defs.serika_lv0_b), "Rep100")
  play(app,"serika_lv0_b","lounge")
  expect(not g.character_event_available(defs.serika_lv0_c), "Miyuki0")
  g.relation_for("nurse_yui").met = true
  g.relation_for("nurse_yui").level = 1
  expect(g.character_event_available(defs.serika_lv0_c), "Miyuki1")
  play(app,"serika_lv0_c","station")
  expect(g.character_event_available(defs.serika_lv0_d), "D same day")
  # Restructure all completed scene internals before restoring facts.
  snap = g.snapshot()
  var test_slot := "/private/tmp/hoshimi_serika_boundary_%s.json" % OS.get_process_id()
  var file := FileAccess.open(test_slot, FileAccess.WRITE)
  expect(file != null, "Open isolated test slot")
  file.store_string(JSON.stringify(snap))
  file.close()
  snap = JSON.parse_string(FileAccess.get_file_as_string(test_slot))
  no_inner(snap)
  DirAccess.remove_absolute(ProjectSettings.globalize_path(test_slot))
  var old_time: int = g.elapsed()
  for id in ["serika_lv0_a","serika_lv0_b","serika_lv0_c"]:
   defs[id] = defs[id].duplicate(true)
   defs[id].start = "replacement"
   defs[id].nodes = [{"id":"replacement","text":"replacement","choices":[]}]
   defs[id].minutes = 99
   g.character_event_definitions[id] = defs[id]
  expect(g.restore(JSON.parse_string(JSON.stringify(snap))), "Restore without original nodes")
  expect(g.elapsed() == old_time, "Historical zero duration preserved")
  g.advance_story_to_day(2,540)
  expect(g.character_event_available(defs.serika_lv0_d), "Cross-day D")
  play(app,"serika_lv0_d","rooftop")
  expect(g.staff_is_met(ACTOR) and g.relationship_level(ACTOR)==0, "D meets at Lv0")
  expect(g.relation_for(ACTOR).familiarity==0, "No introduction reward")
  expect(not g.staff_can_join_surgery_team(ACTOR), "No early assistant")
  expect(not g.sunday_date_eligible(ACTOR), "No early date")
  expect(ACTOR not in g.after_work_candidates(2), "No unapproved walk")
  expect(not g.rank_ready(ACTOR), "No unwritten rank upgrade")
  for id in defs:expect(not g.character_event_available(defs[id]), "No replay")
  var found := false
  for day in range(3,30):
   g.advance_story_to_day(day,540)
   var present: bool = ACTOR in g.staff_present_at("imaging")
   for repeat in range(4):expect((ACTOR in g.staff_present_at("imaging")) == present,"Stable daily presence")
   snap = g.snapshot()
   expect(g.restore(JSON.parse_string(JSON.stringify(snap))), "Daily presence reload")
   expect((ACTOR in g.staff_present_at("imaging")) == present,"Reload no reroll")
   expect(ACTOR not in g.staff_present_at("or") and ACTOR not in g.staff_present_at("rooftop"),"Only imaging")
   if present:
    found = true
    old_time = g.elapsed()
    expect(g.spend_time("serika_imaging_chat"), "Idle")
    expect(g.elapsed()==old_time and g.relation_for(ACTOR).familiarity==0,"Idle no time/reward")
    expect(not g.spend_time("serika_imaging_discussion"),"Retired random reward entry denied")
    expect(g.elapsed()==old_time and g.relation_for(ACTOR).familiarity==0,"Retired entry cannot pay")
    app.show_location("imaging",true)
    app.location_staff_drawer_open="imaging"
    app.show_location("imaging",true)
    expect(app.page.find_child("TimeEvent_serika_imaging_chat",true,false)!=null,"Idle UI")
    expect(app.page.find_child("SerikaRadiologyDiscussion",true,false)!=null,"Discussion UI")
    break
  expect(found,"Found present day")
  for level in [0,1,2,3,4]:
   g.relation_for(ACTOR).level=level
   expect(is_equal_approx(g.familiarity_gain_multiplier(ACTOR),0.5),"Numeric rank cannot replace completed milestone")
   expect(not g.staff_can_join_surgery_team(ACTOR),"Numeric rank never replaces actual milestone")
  expect(g.staff_record(ACTOR).surgical_roles==["assistant_surgeon"],"Never ordinary primary")
  var multiplier_fixture_ids:Array[String]=[]
  for level in [3,4]:
   var id:String="test_serika_growth_%s"%level
   var definition:Dictionary=defs.serika_lv0_d.duplicate(true)
   definition.id=id
   g.character_event_definitions[id]=definition
   var completed=preload("res://godot/systems/character_event_session.gd").new(definition)
   completed.completed=true;completed.completed_day=1;completed.settled_minutes=0
   g.character_events[id]=completed
   g.relationship_rank_slot(ACTOR,level).event_id=id
   g.relationship_rank_slot(ACTOR,level).content_status="authored"
   g.relation_for(ACTOR).rank_history.append(id)
   multiplier_fixture_ids.append(id)
   expect(is_equal_approx(g.familiarity_gain_multiplier(ACTOR),0.8 if level==3 else 1.0),"Completed milestone controls growth")
  expect(g.surgery_familiarity_reward(ACTOR,"routine")==5,"Lv4 surgery")
  for id in multiplier_fixture_ids:
   g.character_events.erase(id)
   g.relation_for(ACTOR).rank_history.erase(id)
  g.relation_for(ACTOR).level=2
  expect(g.surgery_familiarity_reward(ACTOR,"routine")==4,"Surgery floor4")
  g.award_surgery_team_familiarity({"assistant_surgeon":ACTOR})
  expect(g.relation_for(ACTOR).familiarity==4,"Surgery reward remains independent")
  g.advance_story_to_day(40,1000)
  g.set_story_flag("serika_imaging_present:40",true)
  old_time=g.elapsed()
  expect(not g.spend_time("serika_imaging_discussion") and g.elapsed()==old_time,"Insufficient time no cost")
 print("SERIKA: %s checks; %s failures" % [checks,failures])
 quit(1 if failures else 0)
