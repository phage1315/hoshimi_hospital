extends SceneTree
const M=preload("res://godot/systems/advanced_surgery_model.gd")
const S=preload("res://godot/systems/advanced_surgery_session.gd")
const Bridge=preload("res://godot/systems/advanced_physiology.gd")
var checks=0
var failures=0
func _initialize():call_deferred("run")
func check(ok,why):
 checks+=1
 if not ok:failures+=1;push_error(why)
func stamp(s):return [s.hp,s.rng.state,s.crisis_count,s.physiology.procedure_state.duplicate(true),s.journal.duplicate(true)]
func run():
 var additions=JSON.parse_string(FileAccess.get_file_as_string("res://docs/source/advanced_three_cases_content_v1/procedures_additions.json"))
 for d in additions:
  var t=M.fixtures(d.id)[2]
  var no_crisis=d.duplicate(true);no_crisis.crisis_checkpoints=[];no_crisis.crisis_chances=[]
  for i in range(d.steps.size()):
   var step=d.steps[i]
   var outcomes=[]
   for option in (["standard","extended"] if step.kind=="S" else [""]):
    var s=S.new(no_crisis,t,42);s.index=i;s.variant=false
    s.physiology.procedure_state.merge({"stability":70,"visibility":60,"bleeding":20},true)
    var expected=Bridge.new(no_crisis,[],{})
    expected.procedure_state=s.physiology.procedure_state.duplicate(true)
    var strategy={}
    if step.kind=="S":strategy=step.options.filter(func(o):return o.id==option)[0]
    var effects=step.strategic_effects.duplicate(true);effects.progress=floori(100.0*(i+1)/d.steps.size())
    expected.apply_surgery_option_effects({"strategic_effects":effects,"conditional_effects":step.get("conditional_effects",[])})
    if not strategy.is_empty():expected.apply_surgery_option_effects(strategy)
    var rng_before=s.rng.state
    check(s.act(0,option),"Authored step accepted "+step.id)
    if s.pending_rescue:s.rescue(0)
    check(s.physiology.procedure_state==expected.procedure_state,"Ordinary resolver matches exactly "+step.id)
    check(s.physiology.procedure_state.elapsed_time==step.strategic_effects.elapsed_time+(10 if option=="extended" else 0),"No duplicate base/option time")
    if step.kind=="S":check(s.rng.state==rng_before,"Strategy deterministic")
    var before=stamp(s);s.finish_action()
    check(stamp(s)==before and not s.act(0,option),"Stage effects and HP once")
    outcomes.append(s.physiology.procedure_state.duplicate(true))
   if step.kind=="S":check(outcomes[1].elapsed_time-outcomes[0].elapsed_time==10 and outcomes[1].visibility>outcomes[0].visibility and outcomes[1].bleeding<outcomes[0].bleeding,"Meaningful Strategy trade-off")
   if step.kind!="P":continue
   var win={};var lose={}
   for seed_value in range(200):
    var s=S.new(no_crisis,t,seed_value);s.index=i;s.act()
    if s.pending_rescue:s.rescue(0)
    if s.last_result.failed:lose=s.physiology.procedure_state.duplicate(true)
    else:win=s.physiology.procedure_state.duplicate(true)
    if not win.is_empty() and not lose.is_empty():break
   check(not win.is_empty() and win==lose,"No extra physiological P failure penalty "+step.id)
  for checkpoint in d.crisis_checkpoints:
   var saw=false
   for seed_value in range(300):
    var s=S.new(d,t,seed_value);s.index=int(checkpoint)-1;s.act(0,"standard" if s.current().kind=="S" else "")
    if s.pending_rescue:s.rescue(0)
    if not s.in_crisis():continue
    saw=true
    var before=stamp(s);s.finish_action()
    check(s.crisis_count==1 and stamp(s)==before and not s.acknowledge(),"One real crisis and one HP charge")
    var hp=s.hp
    for attempt in range(3):s.physiology.apply_crisis_rescue("pause_and_stabilize",9999)
    s.check_failure()
    check(s.finished and s.failure_reason=="physiology" and hp==s.hp and hp>0,"Ordinary crisis failure terminates with HP remaining")
    break
   check(saw,"Real checkpoint exercised "+str(checkpoint))
  for reason in ["hp","physiology","both"]:
   var s=S.new(d,t,1)
   if reason in ["hp","both"]:s.hp=0
   if reason in ["physiology","both"]:s.physiology.procedure_state.stability=0
   check(not s.act() and s.finished and s.failure_reason==reason,"Independent failure "+reason)
 print("ADVANCED THREE PHYSIOLOGY: ",checks," checks; ",failures," failures")
 quit(1 if failures else 0)
