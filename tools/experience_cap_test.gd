extends "res://tools/event_batch_entry_qa.gd"
const PreopCap = preload("res://godot/systems/preop_session.gd")
var checks=0
var failures=0
func expect(ok:bool,message:String):
 checks+=1
 if not ok:failures+=1;push_error(message)
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_xp_cap_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 var g=app.game;var d=g.special_event_definitions.miyama_03_or_god;var cap=g.surgery_xp_for_level(100)
 for headroom in [0,5,100]:
  fixture(g,d,true);g.surgery_xp=cap-headroom
  var before=g.surgery_xp;var history_before=g.surgery_xp_history.size()
  expect(g.start_special_event(d.id)!=null,"Event could not start")
  for guard in range(100):
   if not g.special_event_in_progress():break
   expect(g.choose_special_event(g.active_special_event.current().choices[0].id).accepted,"Event choice rejected")
  g.finish_special_event();app.show_map(false)
  expect(g.surgery_xp==before+mini(headroom,12),"Event award not capped exactly")
  expect(g.surgery_level()<=100,"Level exceeded 100")
  if headroom>0:expect(g.surgery_xp_history[-1].xp==mini(headroom,12),"History did not record actual award")
  else:expect(g.surgery_xp_history.size()==history_before,"Full-cap award added a false XP record")
  var facts=g.snapshot();var elapsed=g.elapsed();var count=g.special_event_completion_counts.get(d.id)
  expect(not facts.is_empty() and g.restore(facts),"Completed capped event failed restore")
  expect(g.elapsed()==elapsed and g.special_event_completion_counts.get(d.id)==count,"Restore repeated settlement")
  expect(g.restore(g.snapshot()) and g.surgery_xp==before+mini(headroom,12),"Repeated restore drifted")
 # Real ordinary-surgery award path, near cap and already capped.
 var prep=PreopCap.new(app.content.collections.preops[0],app.content.collections.staff,app.content.collections.surgeries,app.content.collections.patients)
 prep.procedure_id="surgery_open_whipple";prep.procedure_name="Whipple"
 for headroom in [0,1,100]:
  g.reset();g.surgery_xp=cap-headroom
  var before=g.surgery_xp;var awarded=g.award_surgery_xp(prep)
  expect(g.surgery_xp<=cap and g.surgery_xp-before==awarded,"Ordinary surgery overflow or inaccurate award")
  if headroom>0:expect(awarded>0,"Ordinary award fixture did not award XP")
  if awarded>0:expect(g.surgery_xp_history[-1].xp==awarded,"Ordinary history award mismatch")
 # Old excessive values normalize in memory; no save files are created.
 g.reset();app.show_map(false);var baseline=g.snapshot()
 for raw in [cap-1,cap,cap+12,1e30]:
  var facts=baseline.duplicate(true);facts.surgery_xp=raw;facts.leadership_xp=g.leadership_xp_for_level(100)+12.5
  expect(g.restore(facts),"Overflow facts rejected")
  expect(g.surgery_xp==int(minf(float(raw),cap)),"Restored surgery XP not capped")
  expect(g.leadership_xp==g.leadership_xp_for_level(100),"Restored leadership XP not capped")
  var normalized=g.snapshot();expect(g.restore(normalized) and g.snapshot()==normalized,"Normalized facts not stable on repeated restore")
 for raw in [-1,1.5,"120022",INF,NAN]:
  var facts=baseline.duplicate(true);facts.surgery_xp=raw
  expect(not g.restore(facts),"Invalid surgery XP accepted")
 for raw in [-1,"12",INF,NAN]:
  var facts=baseline.duplicate(true);facts.leadership_xp=raw
  expect(not g.restore(facts),"Invalid leadership XP accepted")
 print("EXPERIENCE CAP ",checks," checks; ",failures," failures; no save files written")
 app.queue_free();await process_frame;quit(1 if failures else 0)
