extends "res://tools/advanced_surgery_test.gd"
const Legendary = preload("res://godot/systems/advanced_legendary.gd")
const Rules = preload("res://godot/systems/advanced_referral_rules.gd")
const Dialogue = preload("res://godot/systems/advanced_operative_dialogue.gd")
const Physiology = preload("res://godot/systems/advanced_physiology.gd")
const Presentation = preload("res://godot/systems/advanced_presentation.gd")
const ID := "surgery_master_whipple_vascular_reconstruction"
const MIDO_ID := "surgery_master_aortic_root_ascending_replacement"

func fixture() -> RefCounted:
	var g := new_game()
	for person in g.staff: g.relation_for(person.id).met = true
	g.surgery_xp = g.surgery_xp_for_level(91)
	g.archived_player_effects.reputation = 300
	g.set_story_flag("advanced_referral_random_cases_enabled", true)
	g.special_event_completion_counts["advanced_referral_tutorial_chisato"] = 1
	g.special_event_completion_days["advanced_referral_tutorial_chisato"] = 1
	return g

func saber_team() -> Dictionary:
	var t := Presentation.DEFAULT_TEAM.duplicate(true)
	t.first_assistant = "doc_artoria"
	t.second_assistant = "doc_aoi"
	return t

func run() -> void:
	var g := fixture()
	var c := Referral.new(g, true)
	c.content_preview = true
	var definition := Model.procedure(ID)
	var record := {"id": "advanced_first_" + ID, "procedure_id": ID, "patient_id": "patient_maiya_hisau", "replay": false}
	var team := saber_team()

	# SAB-L01 & SAB-L02: Explicit category & real Lv5 gate without new Chief flags
	expect(Rules.category(ID) == "LEGENDARY_STORY", "SAB-L01: Explicit LEGENDARY_STORY classification")
	var ready := bool(Legendary.entry(ID).runtime_ready)
	expect(Rules.procedure_ready(ID) == ready and Legendary.ready(ID) == ready, "SAB-L01: Production readiness matches validated assets")
	expect(Rules.manifest().size() == 7, "SAB-L01: Monthly regular manifest unchanged at 7")
	expect(Legendary.gate(g, c.state(), ID, 4) == "legendary_clears_locked", "SAB-L02: Four distinct regular clears rejected")
	expect(Legendary.gate(g, c.state(), ID, 5) == "legendary_rank_locked", "SAB-L02: Real Artoria Lv5 required")
	g.relation_for("doc_artoria").level = 5
	expect(not Legendary.relationship_cleared(g, "doc_artoria", 5), "SAB-L02: Level number 5 alone rejected")
	var lv5_event: String = g.relationship_rank_slot("doc_artoria", 5).event_id
	expect(lv5_event == "artoria_lv5_my_position", "SAB-L02: Canonical Artoria Lv5 event ID")
	g.relation_for("doc_artoria").rank_history.append(lv5_event)
	g._complete_character_event_for_test(lv5_event, 2)
	expect(Legendary.relationship_cleared(g, "doc_artoria", 5), "SAB-L02: Real Artoria Lv5 completion accepted")
	expect(Legendary.gate(g, c.state(), ID, 5) == ("" if ready else "legendary_assets_locked"), "SAB-L02: Gate opens when assets ready")

	# SAB-L12: Dynamic patient_id resolution on board for both Mido and Saber
	var mido_lv5: String = g.relationship_rank_slot("doc_emiko", 5).event_id
	g.relation_for("doc_emiko").level = 5
	g.relation_for("doc_emiko").rank_history.append(mido_lv5)
	g.special_event_completion_counts[mido_lv5] = 1
	g.special_event_completion_days[mido_lv5] = 1
	var prod_board_game := fixture()
	prod_board_game.relation_for("doc_artoria").level = 5
	prod_board_game.relation_for("doc_artoria").rank_history.append(lv5_event)
	prod_board_game._complete_character_event_for_test(lv5_event, 2)
	prod_board_game.relation_for("doc_emiko").level = 5
	prod_board_game.relation_for("doc_emiko").rank_history.append(mido_lv5)
	prod_board_game.special_event_completion_counts[mido_lv5] = 1
	prod_board_game.special_event_completion_days[mido_lv5] = 1
	var prod_board_ctrl := Referral.new(prod_board_game)
	prod_board_ctrl.state().activated_day = 1
	for row in Rules.manifest().slice(0, 5):
		prod_board_ctrl.state().procedures[row.procedure_id] = "CLEARED"
		prod_board_ctrl.state().clear_days[row.procedure_id] = 1
	var offers := prod_board_ctrl.board()
	var saber_offer := offers.filter(func(o): return o.procedure_id == ID and not o.replay)
	var mido_offer := offers.filter(func(o): return o.procedure_id == MIDO_ID and not o.replay)
	expect(saber_offer.size() == 1 and saber_offer[0].patient_id == "patient_maiya_hisau", "SAB-L12: Saber board resolves patient_maiya_hisau")
	expect(mido_offer.size() == 1 and mido_offer[0].patient_id == "patient_murakami_ai", "SAB-L12: Mido board preserves patient_murakami_ai")

	# SAB-L03 & SAB-B01: 18 stages, F4/L3/S3/P8, 729 min / 54 HP
	expect(definition.steps.size() == 18, "SAB-L03: Exactly 18 stages")
	var kinds := {"F": 0, "L": 0, "S": 0, "P": 0}
	var hp_sum := 0
	var min_sum := 0
	var cond_sum := 0
	for step in definition.steps:
		kinds[step.kind] = int(kinds.get(step.kind, 0)) + 1
		hp_sum += int(step.hp_base)
		min_sum += int(step.strategic_effects.elapsed_time)
		cond_sum += int(step.get("conditional_effects", []).size())
	expect(kinds.F == 4 and kinds.L == 3 and kinds.S == 3 and kinds.P == 8, "SAB-L03: Exact F4/L3/S3/P8 structure")
	expect(hp_sum == 54 and min_sum == 729 and cond_sum == 7, "SAB-B01/B03: 54 HP, 729 min, 7 conditional_effects")
	expect(definition.crisis_checkpoints.map(func(x): return int(x)) == [8, 12, 17], "SAB-B06: Crisis checkpoints at [8, 12, 17]")

	# SAB-L04 & SAB-L05: Forced Saber on first challenge, free on replay
	var bad_team := team.duplicate(true)
	bad_team.first_assistant = "doc_emiko"
	bad_team.second_assistant = "doc_aoi"
	expect(not c.valid_case_team(record, bad_team, 2), "SAB-L04: Cannot replace Saber on first challenge")
	var replay_rec := record.duplicate(true)
	replay_rec.replay = true
	expect(c.valid_case_team(replay_rec, bad_team, 2), "SAB-L05: Replay frees first assistant")
	c.state().cooldowns["doc_artoria"] = 20
	expect(not c.valid_case_team(record, team, 2), "SAB-L04: Saber cooldown respected")
	c.state().cooldowns.clear()

	# SAB-L13: Day 1 / Day 2 / Day 3 VN & 4 immediate RP choices with zero persistent side effects
	var flags_before: Dictionary = g.story_flags.duplicate(true)
	var rel_before: Dictionary = g.relation_for("doc_artoria").duplicate(true)
	c.begin_story("day1", record)
	expect(c.story_phase == "day1" and c.story_content.day1.lines.size() == 139, "SAB-L13: Day1 has 139 total lines")
	for branch_idx in [0, 1, 2]:
		c.begin_story("day1", record)
		var guard := 0
		var hit_ac1 := false
		var hit_cc2 := false
		while not c.story_phase.is_empty() and guard < 200:
			var cur_line: Dictionary = c.story_content.day1.lines[c.story_index]
			var choices: Array = cur_line.get("choices", [])
			if not choices.is_empty():
				var before_idx: int = c.story_index
				c.advance_story()
				expect(c.story_index == before_idx, "SAB-L13: Choice blocks linear advance_story")
				var pick_idx := mini(branch_idx, choices.size() - 1)
				if cur_line.id == "A25": hit_ac1 = true
				if cur_line.id == "C26": hit_cc2 = true
				expect(c.choose_story_option(str(choices[pick_idx].next)), "SAB-L13: Valid choice advances")
			else:
				c.advance_story()
			guard += 1
		expect(c.story_phase.is_empty() and hit_ac1 and hit_cc2, "SAB-L13: Day1 completes through A-C1 & C-C2")
	expect(g.story_flags == flags_before and g.relation_for("doc_artoria") == rel_before, "SAB-L13: Choices leave zero persistent side effects")

	# SAB-L07 & SAB-L06: Day 2 short story -> splash -> static field window
	expect(c.accept(record, team), "Accepts valid Saber team")
	c.demo_day = 2
	expect(c.start_operation(), "Starts real runner on Day 2")
	expect(c.story_phase == "day2" and c.story_content.day2.lines.size() == 25, "SAB-L07: Day2 E-F has 25 lines")
	c.finish_story()
	expect(c.session.splash_pending, "SAB-L07: Finishing Day2 story preserves anesthesia splash")
	c.session.splash_pending = false
	c.session.patient_ready_pending = false
	c.session.team_intro_index = -1
	expect(Dialogue.field_path(c.session) == "assets/surgeries/advanced_fields_v1/whipple_incision.png", "SAB-L06: WH01 pre-ack uses incision window")
	c.session.awaiting_ack = true
	expect(Dialogue.field_path(c.session) == "assets/surgery/fields/saber_whipple_vascular.jpg", "SAB-L06: WH01 post-ack opens main Whipple field")
	for mid_idx in range(1, 17):
		c.session.index = mid_idx
		c.session.awaiting_ack = false
		expect(Dialogue.field_visible(c.session) and Dialogue.field_path(c.session) == "assets/surgery/fields/saber_whipple_vascular.jpg", "SAB-L06: Single static field on WH%02d" % (mid_idx + 1))
	c.session.index = 17
	expect(Dialogue.field_path(c.session) == "assets/surgeries/advanced_fields_v1/whipple_closure.png", "SAB-L06: WH18 uses closure window")

	# SAB-B07, SAB-B08, SAB-B09, SAB-B12: Operative dialogue variants & §4.2 ordering
	var teaching := Dialogue.new(ID, 0, true, true)
	var standard := Dialogue.new(ID, 0, true, false)
	expect(Dialogue.valid(teaching.data, definition) and Dialogue.valid(standard.data, definition), "SAB-B07/B08: Both V2 dialogue packs validate")
	for step in definition.steps:
		var t_ba: Array = teaching.data.stages[step.id].before_action
		var s_ba: Array = standard.data.stages[step.id].before_action
		if step.id in ["WH01", "WH18"]:
			expect(t_ba[1].speaker_role == "lead_surgeon" and str(t_ba[2].id).contains("_S_PRE"), "SAB-B12: %s places AS_S_PRE after PRE02" % step.id)
			expect(s_ba[1].speaker_role == "lead_surgeon" and str(s_ba[2].id).contains("_G_PRE"), "SAB-B12: %s places AS_G_PRE after PRE02" % step.id)
		else:
			expect(t_ba[0].speaker_role == "lead_surgeon" and str(t_ba[1].id).contains("_S_PRE"), "SAB-B12: %s places AS_S_PRE after PRE01" % step.id)
			expect(s_ba[0].speaker_role == "lead_surgeon" and str(s_ba[1].id).contains("_G_PRE"), "SAB-B12: %s places AS_G_PRE after PRE01" % step.id)
		var expected_post_count := 2 if step.id in ["WH06", "WH09", "WH11", "WH12", "WH14", "WH17"] else 1
		expect(teaching.data.stages[step.id].after_resolution.size() == expected_post_count, "SAB-B08: POST count on " + step.id)
		if step.kind == "P":
			expect(teaching.data.stages[step.id].precision_failed.size() == 1, "SAB-B07: Exact 1 P_FAIL on " + step.id)

	# Abdominal specialist second use for Asuka & Maki preserving real skills
	var values := c.values(team, ID)
	for actor in ["doc_asuka", "doc_maki"]:
		var t2 := team.duplicate(true)
		t2.second_assistant = actor
		var v2 := c.values(t2, ID)
		var wh06: Dictionary = definition.steps[5]
		expect(Model.can_use(v2.assistants[1], 1, wh06) and not Model.can_use(v2.assistants[1], 2, wh06), "Abdominal specialist 2nd use on WH06: " + actor)
		expect(Model.probability(v2.assistants[1].skill, wh06, v2, false) < Model.probability(v2.assistants[0].skill, wh06, v2, false), "Preserves actual lower skill: " + actor)

	# SAB-B02: S-options apply exactly once (+12/14/15 min, +1/1/1 HP)
	for option_index in [0, 1]:
		for s_stage_idx in [4, 9, 16]:
			var s_test := Session.new(definition, values, 42, g.staff, team)
			s_test.index = s_stage_idx
			s_test.definition.crisis_checkpoints = []
			var opt: Dictionary = definition.steps[s_stage_idx].options[option_index]
			expect(s_test.act(0, opt.id), "SAB-B02: Strategy acts on stage %d" % s_stage_idx)
			expect(s_test.hp == 100 - int(definition.steps[s_stage_idx].hp_base) - int(opt.hp_cost), "SAB-B02: Strategy HP once")
			expect(s_test.physiology.procedure_state.elapsed_time == int(definition.steps[s_stage_idx].strategic_effects.elapsed_time) + int(opt.strategic_effects.elapsed_time), "SAB-B02: Strategy time once")
			var hp_after := s_test.hp
			expect(not s_test.act(0, opt.id) and s_test.hp == hp_after, "SAB-B02: Cannot double-charge strategy")

	# SAB-B10 & SAB-B11: Exact 18-stage deterministic BBB and BBA trajectories (WH18 bleeding = 18 and 16 -> both >= 16)
	for combo in ["BBB", "BBA"]:
		var combo_str: String = str(combo)
		var phys := Physiology.new(definition, g.staff, team)
		var s_ptr := 0
		var wh17_state := []
		var wh18_trigs := 0
		for i in range(definition.steps.size()):
			var st: Dictionary = definition.steps[i]
			var sel_opt := {}
			if st.kind == "S":
				var letter: String = combo_str.substr(s_ptr, 1)
				s_ptr += 1
				sel_opt = st.options[0 if letter == "A" else 1]
			var eff: Dictionary = st.strategic_effects.duplicate(true)
			eff.progress = floori(100.0 * (i + 1) / 18.0) - int(phys.procedure_state.progress)
			var t_list: Array = phys.apply_surgery_option_effects({"strategic_effects": eff, "conditional_effects": st.get("conditional_effects", [])})
			if not sel_opt.is_empty():
				phys.apply_surgery_option_effects(sel_opt)
			if st.id == "WH17":
				wh17_state = [int(phys.procedure_state.stability), int(phys.procedure_state.visibility), int(phys.procedure_state.bleeding)]
			if st.id == "WH18":
				wh18_trigs = t_list.size()
		if combo_str == "BBB":
			expect(wh17_state == [10, 53, 21], "SAB-B10: BBB WH17 state == [10, 53, 21]")
			expect(wh18_trigs == 1 and int(phys.procedure_state.stability) == 7 and int(phys.procedure_state.bleeding) == 18 and int(phys.procedure_state.elapsed_time) == 729, "SAB-B11: BBB WH18 triggers bleeding>=16 -> stab=7, bleed=18, 729m")
		else:
			expect(wh17_state == [14, 53, 19], "SAB-B10: BBA WH17 state == [14, 53, 19]")
			expect(wh18_trigs == 1 and int(phys.procedure_state.stability) == 11 and int(phys.procedure_state.bleeding) == 16 and int(phys.procedure_state.elapsed_time) == 744, "SAB-B11: BBA WH18 triggers bleeding>=16 -> stab=11, bleed=16, 744m")

	# SAB-B05 & SAB-B06: Rescue POST & WH17 crisis pauses POST until resolved
	for res in [{"failed": false}, {"failed": true, "rescue_success": true}, {"failed": true, "rescue_success": false}]:
		var s_post := Session.new(definition, values, 1, g.staff, team)
		s_post.index = 11 # WH12 (has 2 POST lines)
		s_post.awaiting_ack = true
		s_post.last_result = res
		s_post.operative_dialogue = Dialogue.new(ID, 0, true, true)
		var ok_res: bool = not res.failed or res.get("rescue_success", false)
		expect(s_post.successful_resolution() == ok_res, "SAB-B05: Resolution accounts for rescue")
		if ok_res:
			expect(not s_post.acknowledge(), "SAB-B05: POST blocks ack")
			for _i in range(2): expect(s_post.operative_dialogue.advance_sequence(s_post), "SAB-B05: Advances 2 POST lines")
			expect(s_post.operative_dialogue.current(s_post).is_empty() and s_post.acknowledge(), "SAB-B05: Advances after POST")
		else:
			expect(str(s_post.operative_dialogue.current(s_post).id) == "WH12_P_FAIL" and s_post.acknowledge(), "SAB-B05: Unrescued failure shows P_FAIL and skips POST")

	var s_c3 := Session.new(definition, values, 7, g.staff, team)
	s_c3.index = 16 # WH17
	s_c3.operative_dialogue = Dialogue.new(ID, 0, true, true)
	for _i in range(3): s_c3.operative_dialogue.advance_sequence(s_c3) # consume 3 PRE lines
	s_c3.physiology.maybe_start_physiologic_crisis(0, definition.steps[16]) # force active crisis
	expect(s_c3.in_crisis() and not s_c3.acknowledge(), "SAB-B06: Active WH_C3 crisis blocks WH17 POST/ack")

	# SAB-B04: Three precision failures alone do not auto-abort
	var s_p3 := Session.new(definition, values, 2, g.staff, team)
	s_p3.precision_failures = 3
	s_p3.check_failure()
	expect(not s_p3.finished, "SAB-B04: Three precision failures alone never abort")

	# SAB-L08, SAB-L09, SAB-L10, SAB-L11: Day 3 atomic settlement, G-C3 & H-C4 choices, v37 save roundtrip, failure locking, Monday V2 pool
	g.set_test_time(17, 540)
	var prod := Referral.new(g)
	prod.state().activated_day = 1
	prod.state().appointment = {"case": record, "team": team, "intake_day": 15, "operation_day": 16, "review_day": 17, "intake_minutes": 60}
	prod.state().outcome = {"case_id": record.id, "success": true, "operation_day": 16, "minutes": 760}
	expect(prod.settle(), "SAB-L09: Real Day3 atomic settlement succeeds")
	expect(prod.state().procedures[ID] == "CLEARED" and prod.story_phase == "day3" and prod.story_content.day3.lines.size() == 102, "SAB-L09: Settled CLEARED before Day3 G-I (102 lines)")
	var xp_after: int = g.surgery_xp
	expect(not prod.settle() and g.surgery_xp == xp_after, "SAB-L09: Idempotent single reward")
	expect(g.snapshot().is_empty(), "SAB-L08: Saving locked during Day3 VN")

	# Walk all 3 branch paths of Day 3 (G-C3 & H-C4)
	for b_idx in [0, 1, 2]:
		prod.begin_story("day3", record)
		var g_guard := 0
		var hit_gc3 := false
		var hit_hc4 := false
		while not prod.story_phase.is_empty() and g_guard < 160:
			var cur_d3: Dictionary = prod.story_content.day3.lines[prod.story_index]
			var d3_choices: Array = cur_d3.get("choices", [])
			if not d3_choices.is_empty():
				if cur_d3.id == "G29": hit_gc3 = true
				if cur_d3.id == "H30": hit_hc4 = true
				expect(prod.choose_story_option(str(d3_choices[mini(b_idx, d3_choices.size() - 1)].next)), "SAB-L13: Day3 choice advances")
			else:
				prod.advance_story()
			g_guard += 1
		expect(prod.story_phase.is_empty() and hit_gc3 and hit_hc4, "SAB-L13: Day3 completes through G-C3 & H-C4")
	expect(g.surgery_xp == xp_after, "SAB-L09: Finishing Day3 VN grants zero duplicate XP")

	g.active_mode = "encounter"
	var saved: Dictionary = g.snapshot()
	expect(not saved.is_empty(), "SAB-L08: Safe boundary snapshot succeeds")
	no_inner(saved.advanced_referral_facts if saved.has("advanced_referral_facts") else prod.state())
	expect(g.restore(JSON.parse_string(JSON.stringify(saved))), "SAB-L08: BoundarySave v37 roundtrip: " + g.last_error)
	expect(g.surgery_xp == xp_after and Facts.valid(prod.state()), "SAB-L08: Restore preserves XP & clean schema")

	# SAB-L10: First failure -> FAILED_LOCKED (no G-I); Replay failure -> preserves CLEARED
	for is_replay in [false, true]:
		var fg := fixture()
		fg.set_test_time(17, 540)
		var fc := Referral.new(fg)
		var frec := record.duplicate(true)
		frec.replay = is_replay
		if is_replay: frec.id = "advanced_replay_saber_test"
		fc.state().activated_day = 1
		if is_replay:
			fc.state().procedures[ID] = "CLEARED"
			fc.state().clear_days[ID] = 3
		fc.state().appointment = {"case": frec, "team": team, "intake_day": 15, "operation_day": 16, "review_day": 17, "intake_minutes": 60}
		fc.state().outcome = {"case_id": frec.id, "success": false, "operation_day": 16, "minutes": 410}
		expect(fc.settle(), "SAB-L10: Failure settled")
		expect(fc.state().procedures[ID] == ("CLEARED" if is_replay else "FAILED_LOCKED"), "SAB-L10: Status contract on failure")
		expect(fc.story_phase.is_empty() and fc.failure_dialogue_index == 0, "SAB-L10: Unified failure template only, no G-I")

	# SAB-L11: V2 Monday 2-slot with-replacement replay pool
	if ready:
		var pool := Facts.fresh()
		pool.activated_day = 1
		pool.procedures[ID] = "CLEARED"
		pool.clear_days[ID] = 6
		Rules.update_pool(pool, 7, 29, ["patient_sora"])
		expect(pool.replays.size() == 2, "SAB-L11: Two-slot Monday V2 replay pool")
		for offer in pool.replays:
			expect(offer.procedure_id == ID and offer.replay and offer.patient_id == "patient_sora" and c.forced_assistant(offer).is_empty(), "SAB-L11: Replay uses ordinary patient & free mentor")
		pool = Facts.fresh()
		pool.activated_day = 1
		pool.procedures[ID] = "CLEARED"
		pool.clear_days[ID] = 7
		Rules.update_pool(pool, 7, 29, ["patient_sora"])
		expect(pool.replays.is_empty(), "SAB-L11: Monday settlement waits until following Monday")
		pool = Facts.fresh()
		pool.activated_day = 1
		pool.procedures[ID] = "FAILED_LOCKED"
		Rules.update_pool(pool, 14, 29, ["patient_sora"])
		expect(pool.replays.is_empty(), "SAB-L11: FAILED_LOCKED never enters replay pool")

	print("SABER LEGENDARY: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
