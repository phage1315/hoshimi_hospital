extends "res://tools/event_batch_entry_qa.gd"
# Diagnostic facts only; no save files or restorable snapshots are written.
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_max_skill_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 var g=app.game;var d=g.special_event_definitions.miyama_03_or_god;var current=g.special_event_step_definitions.miyama_03_or_god_main
 var originals=JSON.parse_string(FileAccess.get_file_as_string("res://docs/qa/event_rendering_fixes_2026-10-27/special_event_steps.json.before"))
 var original:Dictionary={}
 for s in originals:
  if s.id=="miyama_03_or_god_main":original=s
 for variant in [original,current]:
  g.special_event_step_definitions.miyama_03_or_god_main=variant;fixture(g,d,true)
  var before=g.surgery_xp;g.start_special_event(d.id)
  for guard in range(100):
   if not g.special_event_in_progress():break
   g.choose_special_event(g.active_special_event.current().choices[0].id)
  g.finish_special_event();app.show_map(false)
  var after=g.surgery_xp;var safe=g.can_save_progress();var facts=g.snapshot();var restored=g.restore(facts)
  print("MAX_SKILL_REPRO nodes=",variant.nodes.size()," before_xp=",before," after_xp=",after," restore_cap=",g.surgery_xp_for_level(100)," safe_boundary=",safe," restored=",restored," error=",g.last_error)
 app.queue_free();await process_frame;quit()
