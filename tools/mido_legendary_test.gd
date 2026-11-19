extends "res://tools/advanced_surgery_test.gd"
const Legendary = preload("res://godot/systems/advanced_legendary.gd")
const Rules = preload("res://godot/systems/advanced_referral_rules.gd")
const Dialogue = preload("res://godot/systems/advanced_operative_dialogue.gd")
const ID := Legendary.ID

func fixture() -> RefCounted:
	var g := new_game()
	for person in g.staff: g.relation_for(person.id).met = true
	g.relation_for("doc_emiko").rank_history.append("emiko_lv2_follow_my_lead")
	g.surgery_xp = g.surgery_xp_for_level(90)
	g.archived_player_effects.reputation = 300
	g.set_story_flag("advanced_referral_random_cases_enabled", true)
	g.special_event_completion_counts["advanced_referral_tutorial_chisato"]=1
	g.special_event_completion_days["advanced_referral_tutorial_chisato"]=1
	return g

func run() -> void:
	var g := fixture()
	var c := Referral.new(g, true)
	c.content_preview = true
	var definition := Model.procedure(ID)
	var record := {"id":"advanced_first_"+ID,"procedure_id":ID,"patient_id":"patient_murakami_ai","replay":false}
	var team := preload("res://godot/systems/advanced_presentation.gd").DEFAULT_TEAM.duplicate(true)
	expect(Rules.category(ID)=="LEGENDARY_STORY", "Explicit master ID classification")
	var ready := bool(Legendary.entry(ID).runtime_ready)
	expect(Rules.procedure_ready(ID)==ready, "Production readiness matches validated resources")
	expect(Rules.manifest().size()==7, "No monthly/FIFO entry added")
	expect(definition.steps.size()==17, "17 stages")
	expect(Legendary.gate(g,c.state(),ID,4)=="legendary_clears_locked", "Four distinct clears rejected")
	expect(Legendary.gate(g,c.state(),ID,5)=="legendary_rank_locked", "Real Lv5 required")
	g.relation_for("doc_emiko").level=5
	expect(not Legendary.relationship_cleared(g,"doc_emiko",5), "Level number alone insufficient")
	var event: String = g.relationship_rank_slot("doc_emiko",5).event_id
	g.relation_for("doc_emiko").rank_history.append(event)
	g.special_event_completion_counts[event]=1
	g.special_event_completion_days[event]=1
	expect(Legendary.relationship_cleared(g,"doc_emiko",5), "Actual rank completion accepted")
	expect(Legendary.gate(g,c.state(),ID,5)==("" if ready else "legendary_assets_locked"), "All story gates respect resource readiness")
	var bad := team.duplicate(true); bad.first_assistant="doc_rei"
	expect(not c.valid_case_team(record,bad,2), "Cannot replace mentor on first challenge")
	var replay := record.duplicate(true);replay.replay=true
	expect(c.valid_case_team(replay,bad,2), "Replay mentor free choice")
	c.state().cooldowns["doc_emiko"]=20
	expect(not c.valid_case_team(record,team,2), "Mentor cooldown enforced")
	c.state().cooldowns.clear()
	expect(c.accept(record,team), "Isolated DEV preview accepts real team")
	c.demo_day=2
	expect(c.start_operation(),"Starts real runner")
	expect(c.story_phase=="day2" and c.story_content.day2.lines.size()==5,"Day2 preanesthesia story before splash")
	c.finish_story()
	expect(c.session.splash_pending,"Finishing story preserves anesthesia splash")
	var teaching := Dialogue.new(ID,0,true,true)
	var standard := Dialogue.new(ID,0,true,false)
	for step in definition.steps:
		expect(Dialogue.valid(teaching.data,definition) and Dialogue.valid(standard.data,definition),"Both V2 variants validate")
		expect(teaching.data.stages[step.id].before_action[1].id.ends_with("TEACHING"),"First episode teaching")
		expect(standard.data.stages[step.id].before_action[1].id.ends_with("STANDARD"),"Replay standard including Emiko")
		if step.kind=="P": expect(teaching.data.stages[step.id].precision_failed.size()==1,"Single exact authored failure")
	var values := c.values(team,ID)
	for actor in ["doc_rei","doc_asuka","doc_maki"]:
		var t := team.duplicate(true);t.second_assistant=actor
		var v := c.values(t,ID if actor=="doc_rei" else "surgery_open_whipple")
		var step: Dictionary = definition.steps[3] if actor=="doc_rei" else Model.procedure("surgery_open_whipple").steps[4]
		expect(Model.can_use(v.assistants[1],1,step),"Specialist second use below 90: "+actor)
		expect(not Model.can_use(v.assistants[1],2,step),"Never third use")
		expect(Model.probability(v.assistants[1].skill,step,v,false)<Model.probability(v.assistants[0].skill,step,v,false),"Real skill yields lower probability: "+actor)
		var outside: Dictionary = Model.procedure("surgery_adv_posttraumatic_thoracolumbar_kyphosis_correction").steps[2]
		expect(not Model.can_use(v.assistants[1],1,outside),"No spine specialization inherited from generic reconstruction")
	for option_index in [0,1]:
		for index in [4,10,14]:
			var s := Session.new(definition,values,42,g.staff,team)
			s.index=index;s.physiology.procedure_state.stability=70;s.physiology.procedure_state.visibility=70
			# Isolate effects; zero checkpoints does not alter production data.
			s.definition.crisis_checkpoints=[]
			var option: Dictionary = definition.steps[index].options[option_index]
			expect(s.act(0,option.id),"Strategy acts")
			expect(s.hp==100-int(definition.steps[index].hp_base)-int(option.hp_cost),"Strategy HP once")
			expect(s.physiology.procedure_state.elapsed_time==int(definition.steps[index].strategic_effects.elapsed_time)+int(option.strategic_effects.elapsed_time),"Strategy time once")
			var after := s.hp
			expect(not s.act(0,option.id) and s.hp==after,"Repeated callback no duplicate fee")
	for result in [{"failed":false},{"failed":true,"rescue_success":true},{"failed":true,"rescue_success":false}]:
		var s := Session.new(definition,values,1,g.staff,team)
		s.index=9;s.awaiting_ack=true;s.last_result=result
		s.operative_dialogue=Dialogue.new(ID,0,true,true)
		var resolved: bool = not result.failed or result.get("rescue_success",false)
		expect(s.successful_resolution()==resolved,"Resolution accounts for rescue")
		if resolved:
			expect(not s.acknowledge(),"POST gates acknowledgement")
			for i in range(2): expect(s.operative_dialogue.advance_sequence(s),"Exactly two POST lines")
			expect(s.operative_dialogue.current(s).is_empty(),"POST exhausted")
		else: expect(s.operative_dialogue.current(s).id.contains("FAILED"),"Failure retains failure cue, no POST")
		expect(s.acknowledge(),"Can advance after resolution")
	var s := Session.new(definition,values,2,g.staff,team)
	s.precision_failures=3;s.check_failure()
	expect(not s.finished,"Three failures alone never terminate")
	# Production settlement and stable-fact JSON roundtrip. No player files.
	g.set_test_time(17,540)
	var prod := Referral.new(g)
	prod.state().activated_day=1
	prod.state().appointment={"case":record,"team":team,"intake_day":15,"operation_day":16,"review_day":17,"intake_minutes":60}
	prod.state().outcome={"case_id":record.id,"success":true,"operation_day":16,"minutes":689}
	expect(prod.settle(),"Real Day3 settlement")
	expect(prod.state().procedures[ID]=="CLEARED" and prod.story_phase=="day3","Settled before VN")
	var xp: int=g.surgery_xp
	expect(not prod.settle() and g.surgery_xp==xp,"No double rewards")
	expect(g.snapshot().is_empty(),"No save during Day3 VN")
	prod.finish_story();g.active_mode="encounter"
	var saved: Dictionary=g.snapshot()
	expect(not saved.is_empty(),"Safe boundary saves")
	no_inner(saved.advanced_referral_facts if saved.has("advanced_referral_facts") else prod.state())
	expect(g.restore(JSON.parse_string(JSON.stringify(saved))),"Boundary roundtrip: "+g.last_error)
	expect(g.surgery_xp==xp,"Restore does not replay rewards")
	expect(Facts.valid(prod.state()),"No schema extension for legendary facts")

	# First-failure settlement locks once; replay failure preserves an existing clear.
	for is_replay in [false,true]:
		var failed_game := fixture();failed_game.set_test_time(17,540)
		var failed_controller := Referral.new(failed_game)
		var failed_record := record.duplicate(true);failed_record.replay=is_replay
		if is_replay: failed_record.id="advanced_replay_mido_test"
		failed_controller.state().activated_day=1
		if is_replay:
			failed_controller.state().procedures[ID]="CLEARED"
			failed_controller.state().clear_days[ID]=3
		failed_controller.state().appointment={"case":failed_record,"team":team,"intake_day":15,"operation_day":16,"review_day":17,"intake_minutes":60}
		failed_controller.state().outcome={"case_id":failed_record.id,"success":false,"operation_day":16,"minutes":321}
		expect(failed_controller.settle(),"Failure settled")
		expect(failed_controller.state().procedures[ID]==("CLEARED" if is_replay else "FAILED_LOCKED"),"Failure first/replay status contract")
		expect(failed_controller.story_phase.is_empty() and failed_controller.failure_dialogue_index==0,"Unified failure dialogue only")
		expect(failed_controller.state().completed[-1].minutes==441,"Actual elapsed minutes retained")
		expect(not failed_controller.settle(),"Failure cannot settle twice")
	# The legend participates in the existing two-slot Monday draw only after settlement.
	if ready:
		var pool := Facts.fresh();pool.activated_day=1;pool.procedures[ID]="CLEARED";pool.clear_days[ID]=6
		Rules.update_pool(pool,7,17,["patient_sora"])
		expect(pool.replays.size()==2,"Same two-slot Monday pool")
		for offer in pool.replays:
			expect(offer.procedure_id==ID and offer.replay and offer.patient_id=="patient_sora","With-replacement legendary draw with ordinary patients")
			expect(c.forced_assistant(offer).is_empty(),"No forced mentor on replay")
		pool=Facts.fresh();pool.activated_day=1;pool.procedures[ID]="CLEARED";pool.clear_days[ID]=7
		Rules.update_pool(pool,7,17,["patient_sora"])
		expect(pool.replays.is_empty(),"Monday settlement enters following Monday only")
		pool=Facts.fresh();pool.activated_day=1;pool.procedures[ID]="FAILED_LOCKED"
		Rules.update_pool(pool,14,17,["patient_sora"])
		expect(pool.replays.is_empty(),"Failed first challenge never enters replay pool")
	print("MIDO LEGENDARY: %s checks; %s failures"%[checks,failures])
	quit(1 if failures else 0)
