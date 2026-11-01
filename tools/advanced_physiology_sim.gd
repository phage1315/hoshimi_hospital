extends SceneTree
const M = preload("res://godot/systems/advanced_surgery_model.gd")
const S = preload("res://godot/systems/advanced_surgery_session.gd")
const R = preload("res://godot/systems/advanced_referral.gd")
const P = preload("res://godot/systems/advanced_presentation.gd")
const Content = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
func _initialize():call_deferred("run")
func run():
 var content=Content.new();content.load_all();var c=content.collections
 var g=Game.new()
 g.configure(c.encounters,c.preops,c.staff,c.time_events,c.surgeries,c.patients,c.relationships,c.character_events,c.case_templates,c.micro_events,c.examination_cg_pools,c.surgery_team_dialogue_profiles,c.patient_interactions,c.temporary_conditions,c.staff_role_cg_rewards,c.special_events,c.special_event_steps,c.date_profiles,c.date_locations,c.advanced_referral_cases,c.first_surgery_diagnosis_reactions,c.palpation_profiles,c.awake_special_barks)
 var r=R.new(g,true)
 var d=M.catalog()[0]
 var fixtures=M.fixtures(d.id)
 var actual=r.values(P.DEFAULT_TEAM,d.id);actual.name="实际试玩阵容（主刀88）";fixtures.append(actual)
 var report={"runs_per_cell":5000,"seed_base":883000,"policy":"planned delegation; self-correct failed player Precision; pause_and_stabilize crises", "rows":[]}
 for ti in range(fixtures.size()):
  var t=fixtures[ti];var plan=M.plan(d,t)
  var staff=[];var selected={}
  if ti==fixtures.size()-1:
   staff=g.staff;selected=P.DEFAULT_TEAM
  else:
   # Numerical fixtures carry no roster calmness/teamwork. Explicit neutral ordinary modifier = 0.
   staff=[];selected={}
  for mode in ["hp_only","full_standard","full_extended"]:
   var counts={"success":0,"hp":0,"physiology":0,"both":0};var crises=0;var total_time=0;var success_seed=-1
   for i in range(report.runs_per_cell):
    var s=S.new(d,t,report.seed_base+i,staff,selected,mode=="hp_only");var pi=0
    for guard in range(100):
     if s.finished:break
     if s.in_crisis():s.resolve_crisis("pause_and_stabilize")
     elif s.pending_rescue:s.rescue(0)
     elif s.awaiting_ack:s.acknowledge()
     else:
      var who=0
      if s.current().kind=="P":who=plan[pi];pi+=1
      s.act(who,("extended" if mode=="full_extended" else "standard") if not s.strategy_options().is_empty() else "")
    if not s.finished:push_error("Nonterminal simulation");quit(1);return
    counts["success" if s.success else s.failure_reason]+=1
    if s.success and success_seed<0:success_seed=report.seed_base+i
    crises+=s.crisis_count
    if s.physiology!=null:total_time+=int(s.physiology.procedure_state.elapsed_time)
   var row={"team":t.name,"mode":mode,"counts":counts,"crises":crises,"mean_time_all_outcomes":float(total_time)/report.runs_per_cell,"first_success_seed":success_seed,"crisis_team_modifier":0 if staff.is_empty() else S.new(d,t,0,staff,selected).physiology.team_crisis_modifier()}
   report.rows.append(row);print(JSON.stringify(row))
 var f=FileAccess.open("/tmp/advanced_physiology_sim.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close()
 quit()
