extends "res://tools/mido_legendary_test.gd"
## Actual full-physiology sessions, fixed seeds, no saves or authored dialogue replay.
func run() -> void:
	var g := fixture()
	var c := Referral.new(g,true)
	var team := preload("res://godot/systems/advanced_presentation.gd").DEFAULT_TEAM.duplicate(true)
	team.second_assistant="doc_rei"
	var definition := Model.procedure(ID)
	var report := {"procedure_id":ID,"model":"full_physiology","seeds":128,"samples":[],"baseline_hp":54,"baseline_minutes":645,"base_difficulty":definition.base_difficulty,"training_ceiling":definition.training_ceiling,"reward_tier":definition.reward_tier,"base_physiology":[]}
	for step in definition.steps: report.base_physiology.append({"id":step.id,"effects":step.strategic_effects,"stress":step.physio_stress})
	for skill in [80,90,100]:
		c.demo_player_skill=skill
		var values := c.values(team,ID)
		var chances := []
		for step in definition.steps:
			if step.kind=="P": chances.append({"stage":step.id,"player":Model.probability(skill,step,values,false),"emiko":Model.probability(values.assistants[0].skill,step,values,false),"rei":Model.probability(values.assistants[1].skill,step,values,false)})
		for strategy in [0,1]:
			var wins:=0;var hp_sum:=0;var minute_sum:=0;var crises:=0;var failures_sum:=0
			var planned := Model.plan(definition,values)
			for seed_value in range(128):
				var s := Session.new(definition,values,seed_value+11000,g.staff,team)
				var p := 0
				for guard in range(200):
					if s.finished: break
					if s.in_crisis(): s.resolve_crisis("pause_and_stabilize")
					elif s.pending_rescue: s.rescue(0)
					elif s.awaiting_ack: s.acknowledge()
					else:
						var options: Array=s.strategy_options()
						var who:=0
						if s.current().kind=="P": who=int(planned[p]);p+=1
						s.act(who,str(options[strategy].id) if not options.is_empty() else "")
				expect(s.finished,"Simulation terminates")
				wins+=int(s.success);hp_sum+=s.hp;minute_sum+=int(s.physiology.procedure_state.elapsed_time);crises+=s.crisis_count;failures_sum+=s.precision_failures
			report.samples.append({"skill":skill,"strategy":"A" if strategy==0 else "B","successes":wins,"runs":128,"terminal_hp_mean":hp_sum/128.0,"actual_minutes_mean":minute_sum/128.0,"crises_mean":crises/128.0,"precision_failures_mean":failures_sum/128.0,"precision_probabilities_no_variant":chances,"team":values,"planned_actors":planned})
	var file := FileAccess.open("res://docs/qa/mido_legendary_2026-11-18/balance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("MIDO BALANCE: ",checks," checks; ",failures," failures")
	quit(1 if failures else 0)
