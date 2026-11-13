extends SceneTree
## Headless runtime, scheduler, Sticky Queue, cameo non-pollution, conditional branches,
## Ambient Pool, bilingual localization, and v37 BoundarySave verification for
## Katagiri Ayako's 30-day return arc ("Hoshimi Hospital Story", V1.1).

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const SaveStore = preload("res://godot/systems/save_store.gd")
const AyakoReturn = preload("res://godot/systems/ayako_return.gd")
const Calendar = preload("res://godot/systems/fixed_calendar.gd")

const LV2_ID := "miyama_02_manga_artist_wrong_patient"

var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func has_cjk(value: String) -> bool:
	for i in range(value.length()):
		var code := value.unicode_at(i)
		if (code >= 0x3400 and code <= 0x9FFF) or (code >= 0x3040 and code <= 0x30FF):
			return true
	return false

func configure_game(content: Loader, game: GameState) -> void:
	game.configure(
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
		content.collections.advanced_referral_cases
	)

func advance_clinical_calendar(game: GameState, day: int, clock: int) -> void:
	game.archived_clinical_minutes = maxi(0, (day - 1) * game.SHIFT_MINUTES + (clock - game.SHIFT_START_MINUTE) - game.story_time_advance_minutes - game.discarded_overtime_minutes)
	game.active_mode = "encounter"
	game.active_id = ""

func seed_base_prereqs(game: GameState, lv2_day: int = 20, rei_lvl: int = 3, shiori_lvl: int = 3) -> void:
	game.reset()
	for actor_id in ["doc_rei", "doc_shiori", "doc_asuka", "nurse_haru", "nurse_yui"]:
		var r := game.relation_for(actor_id)
		r.met = true
	game.relation_for("doc_rei").level = rei_lvl
	game.relation_for("doc_shiori").level = shiori_lvl
	game.special_event_completion_counts[LV2_ID] = 1
	game.special_event_completion_days[LV2_ID] = lv2_day
	game.set_story_flag("miyama_02_manga_artist_wrong_patient_completed", true)
	game.set_story_flag("ayako_shiori_reconnected", true)
	game.active_mode = "encounter"
	game.active_id = ""

func play_event_to_completion(content: Loader, game: GameState, ev: RefCounted, locale: String, choice_pref: int = 0) -> Dictionary:
	var visited := {}
	var guard := 0
	var step_id := str(ev.current_step().get("id", ""))
	while not ev.completed and guard < 500:
		guard += 1
		var node: Dictionary = ev.current()
		var nid := str(node.get("id", ""))
		visited[nid] = true

		var cg := str(node.get("cg_path", ""))
		if not cg.is_empty():
			expect(ResourceLoader.exists("res://" + cg), "CG loads cleanly: " + cg)
		for p in node.get("event_portraits", []):
			var ppath := "res://" + str(p.get("path", ""))
			expect(ResourceLoader.exists(ppath), "Portrait loads cleanly: " + ppath)

		if locale == "en":
			var t_key := "collections.special_event_steps.%s.nodes.%s.text" % [step_id, nid]
			var loc_txt: String = content.text(t_key, str(node.get("text", "")))
			expect(not loc_txt.strip_edges().is_empty() and not has_cjk(loc_txt), "EN runtime text missing/CJK at %s/%s" % [step_id, nid])
			var raw_spk := str(node.get("speaker_label", ""))
			if not raw_spk.is_empty():
				var s_key := "collections.special_event_steps.%s.nodes.%s.speaker_label" % [step_id, nid]
				var loc_spk: String = content.text(s_key, raw_spk)
				expect(not has_cjk(loc_spk), "EN speaker_label has CJK at %s/%s" % [step_id, nid])

		var choices: Array = node.get("choices", [])
		expect(not choices.is_empty(), "Choices non-empty at %s/%s" % [step_id, nid])
		var pick_idx := mini(choice_pref, choices.size() - 1)
		if locale == "en":
			var c_key := "collections.special_event_steps.%s.nodes.%s.choices.%s.label" % [step_id, nid, str(choices[pick_idx].id)]
			var loc_ch: String = content.text(c_key, str(choices[pick_idx].label))
			expect(not has_cjk(loc_ch), "EN choice label has CJK at %s/%s" % [step_id, nid])
		var res: Dictionary = game.choose_special_event(str(choices[pick_idx].id))
		expect(bool(res.get("accepted", false)), "Choice accepted at %s/%s" % [step_id, nid])
	expect(ev.completed, "Completed event " + step_id)
	game.finish_special_event()
	return visited

func test_opening_gates_and_cutoff(content: Loader) -> void:
	var game := GameState.new()
	configure_game(content, game)
	var cutoff := AyakoReturn.cutoff_day()
	expect(cutoff == 307, "2026-02-01 cutoff day must be Day 307, got %s" % cutoff)

	# 1. Blocked when < 180 days after Lv2 (lv2_day=20 -> day 199 blocked, day 200 unlocked if Mon-Sat)
	seed_base_prereqs(game, 20, 3, 3)
	game.set_test_time(199, 540)
	expect(not AyakoReturn.opening_unlocked_facts(game, 199), "Opening blocked at +179 days")

	# 2. Blocked when doc_rei < 3 or doc_shiori < 3
	seed_base_prereqs(game, 20, 2, 3)
	game.set_test_time(201, 540)
	expect(not AyakoReturn.opening_unlocked_facts(game, 201), "Opening blocked when doc_rei < 3")
	seed_base_prereqs(game, 20, 3, 2)
	game.set_test_time(201, 540)
	expect(not AyakoReturn.opening_unlocked_facts(game, 201), "Opening blocked when doc_shiori < 3")

	# 3. Blocked when ayako_shiori_reconnected is false
	seed_base_prereqs(game, 20, 3, 3)
	game.set_story_flag("ayako_shiori_reconnected", false)
	game.set_test_time(201, 540)
	expect(not AyakoReturn.opening_unlocked_facts(game, 201), "Opening blocked without ayako_shiori_reconnected")

	# 4. Cutoff boundary: Day 307 (2026-02-01 is Sunday, Day 306 is Saturday 2026-01-31) vs Day 308 (2026-02-02 Monday)
	seed_base_prereqs(game, 100, 3, 3)
	game.set_test_time(306, 540)
	expect(AyakoReturn.opening_unlocked_facts(game, 306), "Opening facts unlocked on Day 306 (<= 2026-02-01)")
	expect(AyakoReturn.eligible_day_start(game, AyakoReturn.OPENING), "Opening eligible on Saturday Day 306 at 09:00")

	game.set_test_time(308, 540)
	expect(not AyakoReturn.opening_unlocked_facts(game, 308), "Opening permanently blocked after 2026-02-01 (Day 308)")
	expect(not AyakoReturn.eligible_day_start(game, AyakoReturn.OPENING), "Opening cannot start on Day 308")

func test_sticky_queue_and_cameos_and_branches(content: Loader) -> void:
	var game := GameState.new()
	configure_game(content, game)
	seed_base_prereqs(game, 100, 3, 3)

	# Keep nurse_ishigami, doc_emiko, doc_artoria, doc_serika, doc_minato UNMET to verify cameo non-pollution & skipping!
	for unmet_id in ["nurse_ishigami", "doc_emiko", "doc_artoria", "doc_serika", "doc_minato"]:
		game.relation_for(unmet_id).met = false

	# Start Opening right on Day 306 (Saturday 2026-01-31) so subsequent milestones cross past Feb 1st AND past 30 days!
	advance_clinical_calendar(game, 306, 540)
	var ev_open := game.start_special_event(AyakoReturn.OPENING)
	expect(ev_open != null, "Start Opening on Day 306")
	expect(not game.save_block_reason().is_empty(), "Save blocked during Opening")
	play_event_to_completion(content, game, ev_open, "zh_CN", 0)
	expect(game.story_flag("ayako_research_residency_active"), "Residency active after Opening")
	expect(game.story_flag("ayako_ambient_pool_enabled"), "Ambient pool enabled after Opening")
	expect(game.current_absolute_clock() == 565, "Opening settled +25 minutes (540 -> 565), got %s" % game.current_absolute_clock())

	# Same-day max 1 milestone + ambient yields on milestone day
	expect(AyakoReturn.armed_milestone(game, 306) == "", "No second milestone armed on Opening day")
	expect(not AyakoReturn.ambient_pool_ready(game, 306), "Ambient pool yields on Opening day")

	# Suppose player misses Week 1's earliest arm day (311) all the way to Day 325 (residency_day = 20, past Feb 1st!):
	# Sticky Queue MUST still keep WEEK1 armed first, never skipping to WEEK3 or expiring!
	advance_clinical_calendar(game, 325, 810) # 13:30 workday
	expect(AyakoReturn.armed_milestone(game, 325) == AyakoReturn.WEEK1, "Sticky Queue retains WEEK1 on Day 325")
	expect(AyakoReturn.next_location_event(game, "station", false) == AyakoReturn.WEEK1, "Station triggers WEEK1")
	var ev_w1 := game.start_special_event(AyakoReturn.WEEK1)
	expect(ev_w1 != null, "Start WEEK1 via Sticky Queue")
	play_event_to_completion(content, game, ev_w1, "zh_CN", 1)
	expect(not game.staff_is_met("nurse_ishigami"), "nurse_ishigami cameo did NOT pollute met state")
	expect(AyakoReturn.armed_milestone(game, 325) == "", "Max 1 milestone per day enforced after WEEK1")

	# Next workday Day 326: WEEK2 immediately arms in Sticky Queue!
	# With doc_serika & doc_minato unmet, their conditional nodes must be skipped cleanly; Emiko & Artoria stay unmet!
	advance_clinical_calendar(game, 326, 1030)
	expect(AyakoReturn.next_departure_event(game, 326, 1030) == AyakoReturn.WEEK2, "Evening departure arms WEEK2")
	var ev_w2 := game.start_ayako_departure_event(AyakoReturn.WEEK2, 326)
	expect(ev_w2 != null, "Start WEEK2 departure interlude")
	var w2_unmet_visited := play_event_to_completion(content, game, ev_w2, "zh_CN", 0)
	expect(not w2_unmet_visited.has("ayr02_021"), "Unmet doc_serika snippet skipped cleanly")
	expect(not w2_unmet_visited.has("ayr02_025"), "Unmet doc_minato snippet skipped cleanly")
	expect(not game.staff_is_met("doc_emiko") and not game.staff_is_met("doc_artoria"), "Emiko & Artoria cameos did NOT pollute met state")

	# Next workday Day 327: WEEK3 with doc_shiori == 3 takes the colleague branch (ayr03_065..070, NOT ayr03_058..064)
	advance_clinical_calendar(game, 327, 1040)
	var ev_w3 := game.start_ayako_departure_event(AyakoReturn.WEEK3, 327)
	expect(ev_w3 != null, "Start WEEK3 (Shiori Lv3)")
	var w3_lv3_visited := play_event_to_completion(content, game, ev_w3, "zh_CN", 0)
	expect(w3_lv3_visited.has("ayr03_065") and not w3_lv3_visited.has("ayr03_058"), "Shiori Lv3 played colleague ending branch")

	# Advance past Day 30 of residency AND past Day 340 (residency_day = 36!): Sticky Queue still preserves WEEK4 then DEPARTURE!
	advance_clinical_calendar(game, 341, 1045)
	expect(AyakoReturn.armed_milestone(game, 341) == AyakoReturn.WEEK4, "Sticky Queue retains WEEK4 even at residency_day 36")
	var ev_w4 := game.start_ayako_departure_event(AyakoReturn.WEEK4, 341)
	expect(ev_w4 != null, "Start WEEK4")
	play_event_to_completion(content, game, ev_w4, "zh_CN", 1)

	# Next workday Day 343 (Monday, since 342 is Sunday!): DEPARTURE fires at 09:00 and settles all Character Bible flags!
	advance_clinical_calendar(game, 343, 540)
	expect(AyakoReturn.eligible_day_start(game, AyakoReturn.DEPARTURE), "DEPARTURE eligible at 09:00 on Day 343")
	var ev_dep := game.start_special_event(AyakoReturn.DEPARTURE)
	expect(ev_dep != null, "Start DEPARTURE")
	play_event_to_completion(content, game, ev_dep, "zh_CN", 0)

	expect(not game.story_flag("ayako_research_residency_active"), "Residency closed on DEPARTURE")
	expect(not game.story_flag("ayako_ambient_pool_enabled"), "Ambient pool closed on DEPARTURE")
	for done_flag in [
		"ayako_return_opening_completed",
		"ayako_return_week1_completed",
		"ayako_return_week2_completed",
		"ayako_return_week3_completed",
		"ayako_return_week4_completed",
		"ayako_return_departure_completed",
		"ayako_return_hoshimi_manga_completed",
		"ayako_research_residency_completed",
		"ayako_hospital_manga_project_started",
		"ayako_nurse_uniform_gifted",
		"ayako_research_badge_gifted",
		"ayako_finale_party_eligible",
	]:
		expect(game.story_flag(done_flag), "Expected settled story flag: " + done_flag)

	# Verify BoundarySave v37 round-trip (zero inner node state persisted)
	expect(game.save_block_reason().is_empty(), "Safe boundary save permitted on map after DEPARTURE")
	var tmp_save := "/private/tmp/ayako_return_test_save_%s.json" % OS.get_process_id()
	var store := SaveStore.new()
	store.path = tmp_save
	expect(store.write_slot(game, 1), "Write slot 1 to isolated tmp save")
	var raw_json := FileAccess.get_file_as_string(tmp_save)
	for forbidden in ["ayr00_001", "ayr02_021", "ayr03_058", "ayr05_001", "amb01_001", "node_id"]:
		expect(not raw_json.contains(forbidden), "BoundarySave leaked inner node state: " + forbidden)
	var clone := GameState.new()
	configure_game(content, clone)
	expect(store.read_slot(clone, 1), "Restore slot 1 from isolated tmp save")
	expect(clone.special_event_done(AyakoReturn.DEPARTURE) and clone.story_flag("ayako_finale_party_eligible"), "Restored Departure completion & flags")
	expect(not clone.story_flag("ayako_research_residency_active"), "Restored closed residency flag")
	DirAccess.remove_absolute(tmp_save)

func test_ambient_pool_and_full_en_traversal(en_content: Loader) -> void:
	var game := GameState.new()
	configure_game(en_content, game)
	seed_base_prereqs(game, 20, 4, 4)

	advance_clinical_calendar(game, 200, 540) # Day 200 is Friday
	var ev0 := game.start_special_event(AyakoReturn.OPENING)
	expect(ev0 != null, "EN Opening start")
	play_event_to_completion(en_content, game, ev0, "en", 1)

	# Meet everyone after Opening so Serika/Minato conditional snippets, Shiori Lv4 branch, and all 10 ambients can play in EN!
	for staff_entry in en_content.collections.staff:
		var r := game.relation_for(str(staff_entry.get("id", "")))
		if not r.is_empty():
			r.met = true

	# Day 202 (Sunday is 202? Check: Day 196=Mon? Wait: Day 1=Tue, Day 6=Sun, 6+28*7=202 -> 202 is Sunday! Use Day 203 Monday!):
	advance_clinical_calendar(game, 203, 840)
	expect(AyakoReturn.ambient_pool_ready(game, 203), "Ambient pool ready on residency day 4 (Monday)")
	game.relation_for("doc_aqua").met = false
	expect(not AyakoReturn.base_requirements_met(game, AyakoReturn.AMB_02), "AMB_02 blocked when doc_aqua unmet")
	game.relation_for("doc_aqua").met = true
	expect(AyakoReturn.base_requirements_met(game, AyakoReturn.AMB_02), "AMB_02 unlocked when doc_aqua met")

	# Play AMB_01 on Day 203 and verify 2-day cooldown blocks Day 203 & Day 204, re-opens Day 206 (after Week 1 on Day 205)!
	game.set_story_flag("__test_save_target_event__" + AyakoReturn.AMB_01, true)
	var amb1 := game.start_special_event(AyakoReturn.AMB_01)
	expect(amb1 != null, "EN AMB_01 start")
	play_event_to_completion(en_content, game, amb1, "en", 0)
	game.set_story_flag("__test_save_target_event__" + AyakoReturn.AMB_01, false)
	expect(not AyakoReturn.ambient_pool_ready(game, 203), "Max 1 ambient per day enforced")
	expect(not AyakoReturn.ambient_pool_ready(game, 204), "2-day ambient cooldown blocks next day (Day 204)")

	# Play remaining 9 ambients + Week 1..4 (with Serika/Minato met & Shiori Lv4!) + Departure in EN
	for amb_id in [
		AyakoReturn.AMB_02,
		AyakoReturn.AMB_03,
		AyakoReturn.AMB_04,
		AyakoReturn.AMB_05,
		AyakoReturn.AMB_06,
		AyakoReturn.AMB_07,
		AyakoReturn.AMB_08,
		AyakoReturn.AMB_09,
		AyakoReturn.AMB_10,
	]:
		var ev_amb := game.start_special_event_for_testing(amb_id)
		expect(ev_amb != null, "EN start " + amb_id)
		play_event_to_completion(en_content, game, ev_amb, "en", 0)

	advance_clinical_calendar(game, 205, 810)
	var w1 := game.start_special_event(AyakoReturn.WEEK1)
	expect(w1 != null, "EN WEEK1 start")
	play_event_to_completion(en_content, game, w1, "en", 0)

	advance_clinical_calendar(game, 212, 1030)
	var w2 := game.start_ayako_departure_event(AyakoReturn.WEEK2, 212)
	expect(w2 != null, "EN WEEK2 start")
	var w2_met_visited := play_event_to_completion(en_content, game, w2, "en", 1)
	expect(w2_met_visited.has("ayr02_021") and w2_met_visited.has("ayr02_025"), "Met Serika & Minato snippets both played in EN")

	advance_clinical_calendar(game, 219, 1040)
	var w3 := game.start_ayako_departure_event(AyakoReturn.WEEK3, 219)
	expect(w3 != null, "EN WEEK3 start (Shiori Lv4)")
	var w3_lv4_visited := play_event_to_completion(en_content, game, w3, "en", 1)
	expect(w3_lv4_visited.has("ayr03_058") and not w3_lv4_visited.has("ayr03_065"), "Shiori Lv4 played high-intimacy ending branch in EN")

	advance_clinical_calendar(game, 226, 1050)
	var w4 := game.start_ayako_departure_event(AyakoReturn.WEEK4, 226)
	expect(w4 != null, "EN WEEK4 start")
	play_event_to_completion(en_content, game, w4, "en", 0)

	# Day 229 is Saturday (since 230 = 6 + 32*7 is Sunday!), so test Day 231 Monday!
	advance_clinical_calendar(game, 231, 540)
	# Clear any newly met character's day-start queue check by testing start_special_event via eligible_day_start or test target:
	for staff_entry in en_content.collections.staff:
		var sid := str(staff_entry.get("id", ""))
		if sid not in ["doc_rei", "doc_shiori", "doc_asuka", "nurse_haru", "nurse_yui"]:
			var rel := game.relation_for(sid)
			if not rel.is_empty():
				rel.met = false
	expect(AyakoReturn.eligible_day_start(game, AyakoReturn.DEPARTURE), "EN DEPARTURE eligible at 09:00 on Day 231")
	var dep := game.start_special_event(AyakoReturn.DEPARTURE)
	expect(dep != null, "EN DEPARTURE start")
	play_event_to_completion(en_content, game, dep, "en", 0)
	expect(game.special_event_done(AyakoReturn.DEPARTURE), "All 16 events completed cleanly in EN")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var zh_content := Loader.new()
	expect(zh_content.load_all("zh_CN"), "Load zh_CN content")
	var en_content := Loader.new()
	expect(en_content.load_all("en"), "Load en content")

	test_opening_gates_and_cutoff(zh_content)
	test_sticky_queue_and_cameos_and_branches(zh_content)
	test_ambient_pool_and_full_en_traversal(en_content)

	print("AYAKO RETURN V1.1 TEST: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
