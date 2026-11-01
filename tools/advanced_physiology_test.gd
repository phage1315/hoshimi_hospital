extends SceneTree
const M = preload("res://godot/systems/advanced_surgery_model.gd")
const S = preload("res://godot/systems/advanced_surgery_session.gd")
var checks := 0
var failures := 0
func _initialize(): call_deferred("run")
func check(ok: bool, why: String):
 checks += 1
 if not ok: failures += 1; push_error(why)
func stamp(s) -> Array:
 return [s.hp,s.rng.state,s.crisis_count,s.physiology.procedure_state.duplicate(true),s.journal.duplicate(true)]
func run():
 var d=M.catalog()[0]
 var t=M.fixtures(d.id)[2]
 var base=S.new(d,t,42)
 check(base.physiology!=null and not base.hp_only,"Real physiology default")
 check(base.act(),"Incision")
 check(base.physiology.procedure_state.elapsed_time==15 and base.physiology.procedure_state.blood_loss==3,"Authored incision effects, no default time added")
 var before=stamp(base)
 check(not base.act(),"Duplicate click blocked")
 base.finish_action()
 check(before==stamp(base),"Duplicate completion does not charge effects, time or RNG")
 # Strategy is explicit, deterministic, and processed once by the ordinary resolver.
 for index in [3,10]:
  var outcomes=[]
  for option in ["standard","extended"]:
   var s=S.new(d,t,42);s.index=index
   s.physiology.procedure_state.merge({"stability":70,"visibility":60,"bleeding":20},true)
   var rng_before=s.rng.state
   check(not s.act(0,"bad") and not s.act(),"Invalid/missing choice leaves stage uncommitted")
   check(s.act(0,option),"Valid strategy")
   check(s.rng.state==rng_before,"Strategy has no random check")
   var now=stamp(s);s.finish_action()
   check(stamp(s)==now and not s.act(0,option),"Strategy cannot resolve twice")
   outcomes.append(s.physiology.procedure_state.duplicate(true))
  check(outcomes[1].elapsed_time==outcomes[0].elapsed_time+10,"Ten-minute strategy trade-off")
  check(outcomes[1].visibility>outcomes[0].visibility and outcomes[1].bleeding<outcomes[0].bleeding,"Distinct deterministic physiological outcomes")
 # Failed P and successful P have identical physiology; no double penalty.
 var success_state={};var failure_state={}
 for seed_value in range(100):
  var s=S.new(d,t,seed_value);s.index=2
  s.act()
  if s.pending_rescue:s.rescue(0)
  if s.last_result.failed:failure_state=s.physiology.procedure_state.duplicate(true)
  else:success_state=s.physiology.procedure_state.duplicate(true)
  if not success_state.is_empty() and not failure_state.is_empty():break
 check(success_state==failure_state and not success_state.is_empty(),"Precision failure does not change physiological effects")
 # HP and physiological exits are independent and terminal.
 for reason in ["hp","physiology","both"]:
  var s=S.new(d,t,1)
  if reason in ["hp","both"]:s.hp=0
  if reason in ["physiology","both"]:s.physiology.procedure_state.stability=0
  check(not s.act() and s.finished and not s.success and s.failure_reason==reason,"Independent immediate failure: "+reason)
  check(not s.acknowledge() and not s.rescue(1),"Failure stops every continuation")
 # Exercise a real checkpoint; old independent test roll cannot also occur.
 var saw_crisis=false
 for seed_value in range(200):
  var s=S.new(d,t,seed_value);s.index=4
  s.act()
  if s.pending_rescue:s.rescue(0)
  if not s.in_crisis():continue
  saw_crisis=true
  var now=stamp(s);s.finish_action()
  check(s.crisis_count==1 and stamp(s)==now and not s.act() and not s.acknowledge(),"One real crisis blocks stage; one HP cost")
  var cost=s.last_result.crisis_cost;var hp=s.hp
  # Force resolver failures to verify ordinary abort independent of Advanced HP.
  for i in range(3):s.physiology.apply_crisis_rescue("pause_and_stabilize",9999)
  s.check_failure()
  check(s.finished and s.failure_reason=="physiology" and s.hp==hp and hp>0,"Ordinary three-attempt abort ends advanced surgery without another HP charge")
  check(s.last_result.crisis_cost==cost and not s.resolve_crisis("pause_and_stabilize"),"No duplicate crisis settlement")
  break
 check(saw_crisis,"Real checkpoint exercised")
 # Normal shared conditional resolver (same delta as ordinary surgery).
 var s=S.new(d,t,7);s.index=4;s.physiology.procedure_state.bleeding=20
 s.act()
 if s.pending_rescue:s.rescue(0)
 check(s.physiology.procedure_state.blood_loss==16 and s.physiology.procedure_state.stability==95,"Existing conditional effects applied once")
 print("ADVANCED PHYSIOLOGY: ",checks," checks; ",failures," failures")
 quit(1 if failures else 0)
