extends SceneTree
const Gate = preload("res://godot/systems/takemi_introduction.gd")
var checks := 0
var failures := 0
func expect(ok: bool, message: String) -> void:
 checks += 1
 if not ok:
  failures += 1
  push_error(message)
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 var app = load("res://godot/scenes/main.tscn").instantiate()
 root.add_child(app)
 await process_frame
 for locale in ["zh_CN", "en"]:
  expect(app.content.load_all(locale), "Load " + locale)
  app.configure_game_content()
  var g = app.game
  g.reset()
  g.successful_no_anesthesia_surgeries = 99
  g.takemi_postop_opportunity = true
  g.set_test_player_attribute("presence", 99)
  g.set_test_player_attribute("reputation", 999)
  for stage in range(2, 7):
   expect(not g.character_event_available(g.character_event_definitions["takemi_lv0_t%s" % stage]), "Cannot skip earlier segments")
  g.reset()
  var cast := {}
  for id in ["nurse_iwasaki_rumi", "nurse_yoneda_shiori", "nurse_sonoda_itsumi", "nurse_ishigami", "nurse_satsuki", "nurse_moe"]:
   cast[id] = {"met": g.staff_is_met(id), "level": g.relation_for(id).get("level", 0), "familiarity": g.relation_for(id).get("familiarity", 0)}
  for stage in range(1, 7):
   var id := "takemi_lv0_t%s" % stage
   var d: Dictionary = g.character_event_definitions[id]
   g.advance_story_to_day(stage + 10, 1000)
   g.pending_day_exit_workday = 0
   g.successful_no_anesthesia_surgeries = Gate.THRESHOLDS[stage - 1] - 1
   expect(not g.character_event_available(d), "Threshold below " + id)
   g.successful_no_anesthesia_surgeries += 1
   if stage in [3, 4]:
    g.advance_story_to_day(stage + 10, 600)
    expect(not g.character_event_available(d), "No daytime night event")
    g.pending_day_exit_workday = stage + 10
    g.pending_day_exit_clock = 1200
    g.free_h_booking = {"workday": g.current_workday()}
    expect(not g.character_event_available(d), "Preserve booked evening")
    g.free_h_booking = {}
   if stage == 6:
    g.set_test_player_attribute("presence", 60)
    g.set_test_player_attribute("reputation", 200)
    expect(not g.character_event_available(d), "Fresh success required")
    g.takemi_postop_opportunity = true
    g.set_test_player_attribute("presence", 59)
    expect(not g.character_event_available(d), "Presence gate")
    g.set_test_player_attribute("presence", 60)
    g.set_test_player_attribute("reputation", 199)
    expect(not g.character_event_available(d), "Reputation gate")
    g.set_test_player_attribute("reputation", 200)
   expect(g.character_event_available(d), "Eligible " + id)
   var before: int = g.elapsed()
   var attrs: Dictionary = g.player_attributes().duplicate(true)
   var event = g.start_character_event(id)
   expect(event != null, "Starts " + id)
   if event == null:continue
   expect(not g.can_save_progress(), "No mid-event save")
   for node in d.nodes:
    expect(not g.staff_is_met("doc_takemi"), "Not met during scene")
    expect(event.current().id == node.id, "Exact sequential node")
    app.show_character_event()
    if node.has("cg_path"):
     var cg = app.page.get_node_or_null("CharacterEventCG")
     expect(cg != null and cg.texture != null and cg.size.x == 580, "Inset CG loaded")
    if node.has("scene_caption"):
     expect(app.page.get_node("EventSceneCaption").text == node.scene_caption, "Localized scene caption")
    if locale == "en":expect(not str(event.current().text).contains("「"), "English dialogue loaded")
    expect(g.choose_character_event(str(node.choices[0].id)), "Advance " + str(node.id))
   expect(event.completed, "Completed " + id)
   expect(g.elapsed() - before == int(d.minutes), "Settled duration " + id)
   expect(g.player_attributes() == attrs, "No stat reward")
   g.finish_character_event()
   expect(not g.character_event_available(d), "No duplicate " + id)
   if stage == 4:expect(g.story_flag("takemi_research_discovered") and not g.story_flag("takemi_research_open"), "Lab discovered but locked")
   if stage < 6:
    expect(not g.staff_is_met("doc_takemi"), "No early unlock")
    g.successful_no_anesthesia_surgeries = 30
    expect(not g.character_event_available(g.character_event_definitions["takemi_lv0_t%s" % (stage + 1)]), "No same-window chain")
   var snapshot: Dictionary = g.snapshot()
   var saved_nodes: Array = d.nodes
   d.nodes = [] # Completed saves must not depend on the old dialogue structure.
   var encoded := JSON.stringify(snapshot)
   expect(not encoded.contains('"node_id"') and not encoded.contains('"choices"'), "No internal state persisted")
   expect(g.restore(JSON.parse_string(encoded)), "Roundtrip")
   expect(g.elapsed() == before + int(d.minutes), "Historical time persists")
   d.nodes = saved_nodes
  expect(g.staff_is_met("doc_takemi") and g.story_flag("takemi_research_open"), "Final unlock")
  expect(g.relation_for("doc_takemi").level == 0 and g.relation_for("doc_takemi").familiarity == 0, "Lv0 without familiarity")
  expect(g.staff_can_join_surgery_team("doc_takemi"), "Assistant invitation")
  for id in cast:
   for field in cast[id]:expect(g.relation_for(id).get(field) == cast[id][field], "Cameo unchanged " + id + field)
 # Real surgery settlement: abort/non-final anesthesia/re-entry must not count.
 for mode in ["none", "changed", "abort"]:
  var g = app.game
  g.reset()
  var prep = preload("res://godot/systems/preop_session.gd").new(app.content.collections.preops[0], app.content.collections.staff, app.content.collections.surgeries, app.content.collections.patients)
  prep.anesthesia = "未麻醉" if mode != "changed" else "全身麻醉"
  prep.flags.append("no_anesthesia_confirmed")
  prep.surgery_success = mode != "abort"
  g.preops[str(prep.definition.id)] = prep
  g.active_preop_id = str(prep.definition.id)
  expect(g.finish_active_surgery() == (mode != "abort"), "Only successful settlement")
  expect(g.successful_no_anesthesia_surgeries == (1 if mode == "none" else 0), "Final anesthesia count " + mode)
  expect(g.takemi_postop_opportunity == (mode == "none"), "Fresh opportunity " + mode)
  expect(not g.finish_active_surgery(), "No second settlement")
  expect(g.successful_no_anesthesia_surgeries == (1 if mode == "none" else 0), "No duplicate count")
 print("TAKEMI LV0: %s checks, %s failures" % [checks, failures])
 quit(1 if failures else 0)
