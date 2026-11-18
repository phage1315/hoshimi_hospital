extends SceneTree
const ContentLoader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const ID = "kariya_lv1_butcher_shop_girl"
const ACTOR = "nurse_kariya_megumi"
var content
var checks := 0
var failures := 0
func expect(ok: bool, msg: String) -> void:
 checks += 1
 if not ok:
  failures += 1
  push_error(msg)
func _initialize() -> void:
 call_deferred("run")
func new_game() -> RefCounted:
 var g = GameState.new()
 g.configure(
  content.collections.encounters,
  content.collections.preops,
  content.collections.staff,
  content.collections.time_events,
  content.collections.surgeries,
  content.collections.patients,
  content.collections.relationships,
  content.collections.character_events,
  content.collections.case_templates,
  content.collections.micro_events,
  content.collections.examination_cg_pools,
  content.collections.surgery_team_dialogue_profiles,
  content.collections.patient_interactions,
  content.collections.temporary_conditions,
  content.collections.staff_role_cg_rewards,
  content.collections.special_events,
  content.collections.special_event_steps,
  content.collections.date_profiles,
  content.collections.date_locations,
  content.collections.advanced_referral_cases,
  content.collections.first_surgery_diagnosis_reactions,
  content.collections.palpation_profiles,
  content.collections.awake_special_barks
 )
 return g

func setup(date: String = "2025-06-03", clock: int = 540):
 var g = new_game()
 g.meet_staff(ACTOR)
 g._complete_character_event_for_test("intro_kariya_megumi_june", 62)
 g.relation_for(ACTOR).familiarity = 10
 g.advance_story_to_day(g.day_number_for_date(date), clock)
 return g
func run() -> void:
 content = ContentLoader.new()
 for locale in ["zh_CN", "en"]:
  expect(content.load_all(locale), "content loads " + locale)
  var ready = setup()
  var d: Dictionary = ready.character_event_definitions[ID]
  expect(ready.character_event_available(d), "production availability")
  expect(ready.character_events_at("ward").any(func(e):return e.id == ID), "ward discovery")
  expect(ready.relationship_progress(ACTOR).content_status == "authored", "authored slot")
  ready.relation_for(ACTOR).familiarity = 9
  expect(not ready.character_event_available(d), "familiarity 9 blocked")
  ready.relation_for(ACTOR).familiarity = 10
  ready.character_events.erase("intro_kariya_megumi_june")
  expect(not ready.character_event_available(d), "Lv0 required")
  for date in ["2025-05-30", "2025-06-01", "2025-06-07", "2025-07-21", "2025-12-01"]:
   var g = setup(date)
   expect(not g.character_event_available(g.character_event_definitions[ID]), "date blocked " + date)
  var late = setup("2025-06-03", 720)
  expect(not late.character_event_available(late.character_event_definitions[ID]), "afternoon blocked from every entry")
  var final_results: Array = []
  for branch in ["a", "b", "c"]:
   var g = setup()
   # Supporting nurse's personal route must not gate this public-duty cameo.
   g.relation_for("nurse_hiroko").level = 0
   var before_hiroko: Dictionary = g.relation_for("nurse_hiroko").duplicate(true)
   var before_skills: Dictionary = g.player_attributes().duplicate(true)
   var before_time: int = g.elapsed()
   var before_surgeries: int = g.completed_surgeries_total
   var ev = g.start_character_event(ID)
   expect(ev != null, "start " + branch)
   if ev == null:continue
   var count := 0
   while not ev.completed and count < 200:
    expect(not g.can_save_progress() and g.snapshot().is_empty(), "no mid-event save")
    expect(g.relationship_level(ACTOR) == 0, "no premature level reward")
    var n: Dictionary = ev.current()
    for portrait in n.get("event_portraits", []):
     expect(ResourceLoader.exists("res://" + portrait.path), "portrait loads")
    var choice: String = "km1_reply_" + branch if n.id == "km1_choice" else str(n.choices[0].id)
    expect(g.choose_character_event(choice), "valid transition")
    count += 1
   expect(ev.completed and count == (125 if branch == "a" else 124), "complete branch length")
   expect(g.relationship_level(ACTOR) == 1, "rank1 awarded")
   expect(g.relation_for(ACTOR).familiarity == 10 and g.relation_for(ACTOR).affection == 0, "no choice numerical rewards")
   expect(g.relation_for("nurse_hiroko") == before_hiroko, "Hiroko unchanged")
   expect(g.player_attributes() == before_skills, "no surgery/reputation rewards")
   expect(g.completed_surgeries_total == before_surgeries, "no implied surgery settlement")
   expect(g.elapsed() == before_time + 30, "30 minutes once")
   g.finish_character_event()
   expect(g.can_save_progress(), "safe boundary restored")
   var snap: Dictionary = g.snapshot()
   expect(not snap.is_empty(), "boundary facts available")
   var serialized := JSON.stringify(snap)
   expect(not serialized.contains("km1_") and not serialized.contains("node_id"), "no inner event state saved")
   var restored = new_game()
   expect(restored.restore(snap), "restore safe facts")
   expect(restored.relationship_level(ACTOR) == 1 and restored.character_event_done(ID), "restored completion and rank")
   expect(restored.elapsed() == g.elapsed(), "restore preserves time")
   expect(restored.start_character_event(ID) == null, "cannot settle completed event twice")
   final_results.append(g.relation_for(ACTOR).duplicate(true))
  expect(final_results.size() == 3 and final_results[0] == final_results[1] and final_results[1] == final_results[2], "all branch relationship results identical")
 print("KARIYA LV1 TEST: %s checks; %s failures" % [checks, failures])
 quit(1 if failures else 0)
