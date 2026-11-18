extends SceneTree
## Headless runtime, scheduling, 2-day progression, choice-branch, localization,
## seasonal outfit/street, gallery-replay, and v37 BoundarySave verification for
## Miyama Kaori's Lv3 special event 《手术室之神》 (miyama_03_or_god V1.2).

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const SaveStore = preload("res://godot/systems/save_store.gd")

const LV1_ID := "miyama_01_safety_pin"
const LV2_ID := "miyama_02_manga_artist_wrong_patient"
const EVENT_ID := "miyama_03_or_god"
const STEP_DAY1_ID := "miyama_03_or_god_day1"
const STEP_MAIN_ID := "miyama_03_or_god_main"

var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

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

func run_to_lv3_ready(locale: String, target_day: int = 14) -> Array:
	var content := Loader.new()
	expect(content.load_all(locale), "Load content for locale " + locale)
	var game := GameState.new()
	configure_game(content, game)

	var intro = game.start_character_event("intro_doc_rei")
	while intro != null and not intro.completed:
		game.choose_character_event(str(intro.current().choices[0].id))
	game.active_character_event_id = ""
	game.active_mode = "encounter"

	game.meet_staff("doc_asuka")
	game.add_familiarity("doc_rei", 10)
	game.advance_story_to_day(4, 540)
	game.set_story_flag("__test_save_target_event__" + LV1_ID, true)
	var lv1 = game.start_special_event(LV1_ID)
	while lv1 != null and not lv1.completed:
		game.choose_special_event(str(lv1.current().choices[0].id))
	game.finish_special_event()
	game.set_story_flag("__test_save_target_event__" + LV1_ID, false)

	game.meet_staff("doc_shiori")
	game.add_familiarity("doc_rei", 15)
	game.advance_story_to_day(8, 540)
	game.set_story_flag("__test_save_target_event__" + LV2_ID, true)
	var lv2 = game.start_special_event(LV2_ID)
	while lv2 != null and not lv2.completed:
		game.choose_special_event(str(lv2.current().choices[0].id))
	game.finish_special_event()
	game.set_story_flag("__test_save_target_event__" + LV2_ID, false)

	# Note: nurse_hiroko and doc_sayaka are intentionally NOT met here to verify they do not hard-gate Lv3.
	game.meet_staff("nurse_moe")
	game.meet_staff("nurse_ange")
	game.add_familiarity("doc_rei", 15)
	game.advance_story_to_day(target_day, 540)
	game.set_story_flag("__test_save_target_event__" + EVENT_ID, true)
	return [content, game]

func traverse_branch(locale: String, c1: String, c2: String, c3: String, c4: String, start_day: int = 14) -> Array:
	var pair := run_to_lv3_ready(locale, start_day)
	var content: Loader = pair[0]
	var game: GameState = pair[1]
	var def: Dictionary = game.special_event_definitions[EVENT_ID]
	expect(game.special_event_available(def), "Lv3 available on day %s (%s)" % [start_day, locale])

	var ev = game.start_special_event(EVENT_ID)
	expect(ev != null, "Start miyama_03_or_god (" + locale + ")")
	expect(not game.save_block_reason().is_empty(), "Saving blocked during active special event")

	var visited := {}
	var day_transitions := 0
	var cjk := RegEx.new()
	cjk.compile("[\\x{3400}-\\x{9fff}]")

	# Check Day 1 rooftop schedule presentation (Day 14 @ 17:40 = 1060)
	var d1_sched: Dictionary = game.display_schedule()
	expect(int(d1_sched.day) == start_day and int(d1_sched.absolute_clock) == 1060, "Day 1 rooftop presentation schedule mismatch: " + JSON.stringify(d1_sched))

	var guard := 0
	while not ev.completed and guard < 600:
		guard += 1
		var step: Dictionary = ev.current_step()
		var node: Dictionary = ev.current()
		var nid := str(node.get("id", ""))
		visited[nid] = true

		expect(game.relationship_level("doc_rei") == 2, "Relationship Lv3 must not settle mid-event at " + nid)

		if nid == "s03_001":
			var d2_sched: Dictionary = game.display_schedule()
			expect(int(d2_sched.day) == start_day + 1 and int(d2_sched.absolute_clock) == 630, "Day 2 morning nurses_station schedule mismatch: " + JSON.stringify(d2_sched))
		elif nid == "s12_001":
			var s12_sched: Dictionary = game.display_schedule()
			expect(int(s12_sched.day) == start_day + 1 and int(s12_sched.absolute_clock) == 1210, "Day 2 night walk schedule mismatch: " + JSON.stringify(s12_sched))

		if locale == "en":
			var sid := str(step.get("id", ""))
			var txt := content.text("collections.special_event_steps.%s.nodes.%s.text" % [sid, nid], "")
			var spk := content.text("collections.special_event_steps.%s.nodes.%s.speaker_label" % [sid, nid], "")
			expect(not txt.is_empty() and cjk.search(txt) == null, "EN text missing or CJK at " + nid)
			expect(not spk.is_empty() and cjk.search(spk) == null, "EN speaker missing or CJK at " + nid)

		var choices: Array = node.get("choices", [])
		expect(not choices.is_empty(), "Choices non-empty at " + nid)
		var pick := str(choices[0].id)
		match nid:
			"s08_013": pick = c1
			"s10c_002": pick = c2
			"s10e_003": pick = c3
			"s12_016": pick = c4

		var res: Dictionary = game.choose_special_event(pick)
		expect(bool(res.get("accepted", false)), "Accepted choice %s at %s" % [pick, nid])
		if bool(res.get("day_finished", false)) and not bool(res.get("event_finished", false)):
			day_transitions += 1

	expect(day_transitions == 1, "Expected 1 intermediate day transition across 2-day chain, got %s" % day_transitions)
	expect(ev.completed, "Event completed for %s/%s/%s/%s (%s)" % [c1, c2, c3, c4, locale])
	game.finish_special_event()
	expect(game.day_number() == start_day + 2, "2-day event must advance calendar by 2 days (got %s)" % game.day_number())
	return [content, game, visited]

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	# 1. Verify all 12 new RGBA sprites + 3 runtime Lv3 assets load cleanly via Godot ResourceLoader.
	for path in [
		"res://assets/characters/intraoperative_portraits_v1/doc_rei/tense.png",
		"res://assets/characters/intraoperative_portraits_v1/doc_rei/pain.png",
		"res://assets/characters/intraoperative_portraits_v1/doc_rei/near_collapse.png",
		"res://assets/characters/intraoperative_portraits_v1/doc_rei/anesthetized.png",
		"res://assets/characters/intraoperative_portraits_v1/doc_rei/embarrassed.png",
		"res://assets/characters/intraoperative_portraits_v1/doc_rei/relieved.png",
		"res://assets/characters/miyama_lv3_v1/doc_rei/or_cap/asleep.png",
		"res://assets/characters/miyama_lv3_v1/doc_rei/or_cap/drowsy.png",
		"res://assets/characters/miyama_lv3_v1/doc_rei/or_cap/masked_hesitant.png",
		"res://assets/characters/miyama_lv3_v1/doc_rei/or_cap/masked_focused.png",
		"res://assets/characters/spring_summer_casual_v1/doc_rei/small_smile.png",
		"res://assets/characters/winter_casual_v1/doc_rei/small_smile.png",
		"res://assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/or_cap/tense.png",
		"res://assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/or_cap/shocked_feverish.png",
		"res://assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/or_cap/mask_drowsy.png",
		"res://assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/or_cap/anesthetized.png",
		"res://assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/ward/neutral.png",
		"res://assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/ward/drowsy_relieved.png",
		"res://assets/characters/kasumi_asou_patient_v1/guest_kasumi_asou/ward/confused.png",
		"res://assets/events/character_events/rei/lv3/nude_guarded.png",
		"res://assets/events/character_events/rei/lv3/emergency_command_nude.png",
		"res://assets/events/character_events/rei/lv3/or_god_surgery_rear.png",
		"res://assets/backgrounds/pacu_recovery_v1/pacu_recovery.png",
	]:
		expect(ResourceLoader.exists(path) and load(path) != null, "Texture loads cleanly: " + path)

	# 2. Verify 5-day post-Lv2 cooldown AND Saturday avoid_sunday_span deferral to Monday.
	var gate_pair := run_to_lv3_ready("zh_CN", 12)
	var gate_game: GameState = gate_pair[1]
	var lv3_def: Dictionary = gate_game.special_event_definitions[EVENT_ID]
	# Lv2 completed on day 9 -> day 12 is +3 (< 5): blocked.
	expect(not gate_game.special_event_available(lv3_def), "Day 12 (+3 post-Lv2) must be gated by 5-day requirement")
	# Day 19 (2025-04-19) is Saturday; a 2-day event would spill onto Sunday (Day 20), so avoid_sunday_span defers to Monday (Day 21).
	gate_game.set_story_flag("__test_save_target_event__" + EVENT_ID, false)
	gate_game.advance_story_to_day(19, 540)
	expect(str(gate_game.calendar_date(19).weekday_id) == "sat", "Day 19 is Saturday")
	var sat_timing: Dictionary = gate_game.special_event_timing_status(lv3_def)
	expect(str(sat_timing.get("status", "")) == "sunday_deferred" and int(sat_timing.get("effective_day", 0)) == 21, "Saturday start must defer 2-day Lv3 to Monday day 21: " + JSON.stringify(sat_timing))
	expect(not gate_game.special_event_available(lv3_def), "Lv3 must not start on Saturday when spanning into Sunday")
	gate_game.advance_story_to_day(21, 540)
	gate_game.set_story_flag("__test_save_target_event__" + EVENT_ID, true)
	expect(gate_game.special_event_available(lv3_def), "Lv3 unlocks cleanly on Monday day 21")

	# 3. Traverse all 10 option branches across 3 runs (zh_CN + en).
	var r1 := traverse_branch("zh_CN", "choice_1_a", "choice_2_a", "choice_3_a", "choice_4_a", 14)
	var v1: Dictionary = r1[2]
	expect(v1.has("s08_015") and not v1.has("s08_019") and not v1.has("s08_023"), "Branch 1A routing")
	expect(v1.has("s10c_004") and not v1.has("s10c_008"), "Branch 2A routing")
	expect(v1.has("s10e_005") and not v1.has("s10e_008"), "Branch 3A routing")
	expect(v1.has("s12_017") and not v1.has("s12_020") and not v1.has("s12_023"), "Branch 4A routing")

	var r2 := traverse_branch("en", "choice_1_b", "choice_2_b", "choice_3_b", "choice_4_b", 14)
	var v2: Dictionary = r2[2]
	expect(v2.has("s08_019") and not v2.has("s08_015") and not v2.has("s08_023"), "Branch 1B routing")
	expect(v2.has("s10c_008") and not v2.has("s10c_004"), "Branch 2B routing")
	expect(v2.has("s10e_008") and not v2.has("s10e_005"), "Branch 3B routing")
	expect(v2.has("s12_020") and not v2.has("s12_017") and not v2.has("s12_023"), "Branch 4B routing")

	var r3 := traverse_branch("zh_CN", "choice_1_c", "choice_2_a", "choice_3_b", "choice_4_c", 14)
	var content: Loader = r3[0]
	var game: GameState = r3[1]
	var v3: Dictionary = r3[2]
	expect(v3.has("s08_023") and v3.has("s12_023") and v3.has("s12_037") and v3.has("s12_044"), "Branch 1C/4C + 1st-year med school foreshadowing + finale")

	# 4. Verify atomic settlement rewards & flags.
	expect(game.relationship_level("doc_rei") == 3, "Settled doc_rei Relationship Lv3")
	for flag in [
		"miyama_03_or_god_completed",
		"relationship_doc_rei_lv3",
		"miyama_primary_surgeon_confidence_restored",
		"miyama_or_god_gag_known_by_inner_circle",
	]:
		expect(game.story_flag(flag), "Completion flag set: " + flag)
	expect(int(game.completed_surgeries_by_procedure.get("surgery_open_cholecystectomy", 0)) >= 1, "Recorded surgery_open_cholecystectomy completion")
	expect(game.special_event_gallery_unlocked(EVENT_ID), "Gallery 2-chapter replay unlocked")

	# 5. Verify v37 BoundarySave persistence & zero inner-state leakage in isolated /private/tmp file.
	expect(game.save_block_reason().is_empty(), "Safe boundary save permitted after completion")
	var settled_elapsed := game.elapsed()
	var tmp_save := "/private/tmp/kaori_lv3_test_save_%s.json" % OS.get_process_id()
	var store := SaveStore.new()
	store.path = tmp_save
	expect(store.write_slot(game, 1), "Write slot 1 to isolated /private/tmp store")
	var raw_json := FileAccess.get_file_as_string(tmp_save)
	for forbidden in ["s02_001", "s08_013", "s12_044", "choice_1_c", "node_id", "step_index", "dialogue_page_index"]:
		expect(not raw_json.contains(forbidden), "Saved file leaked inner state token: " + forbidden)
	var clone := GameState.new()
	configure_game(content, clone)
	expect(store.read_slot(clone, 1), "Restore v37 boundary save")
	expect(clone.elapsed() == settled_elapsed and clone.relationship_level("doc_rei") == 3 and clone.special_event_done(EVENT_ID), "Restored exact elapsed time, Lv3, and event completion")
	DirAccess.remove_absolute(tmp_save)

	print("KAORI LV3 V1.2 TEST: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
