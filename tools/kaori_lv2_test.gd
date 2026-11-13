extends SceneTree
## Headless runtime, bilingual localization, timeline schedule, gate matrix,
## and v37 BoundarySave verification for Miyama Kaori's Lv2 special event
## 《取材过头了》 (miyama_02_manga_artist_wrong_patient V9.1).

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const SaveStore = preload("res://godot/systems/save_store.gd")

const LV1_ID := "miyama_01_safety_pin"
const EVENT_ID := "miyama_02_manga_artist_wrong_patient"
const STEP_ID := "miyama_02_manga_artist_wrong_patient_main"

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
		if code >= 0x3400 and code <= 0x9FFF:
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

func complete_intro_and_lv1(game: GameState) -> void:
	var intro = game.start_character_event("intro_doc_rei")
	expect(intro != null, "Start intro_doc_rei")
	while intro != null and not intro.completed:
		game.choose_character_event(str(intro.current().choices[0].id))
	game.active_character_event_id = ""
	game.active_mode = "encounter"
	game.meet_staff("doc_asuka")
	game.add_familiarity("doc_rei", 10)
	game.advance_story_to_day(4, 540)
	game.set_story_flag("__test_save_target_event__" + LV1_ID, true)
	var lv1 = game.start_special_event(LV1_ID)
	expect(lv1 != null, "Start miyama_01_safety_pin")
	while lv1 != null and not lv1.completed:
		game.choose_special_event(str(lv1.current().choices[0].id))
	game.finish_special_event()
	game.set_story_flag("__test_save_target_event__" + LV1_ID, false)

func run_locale_playthrough(locale: String) -> Array:
	var content := Loader.new()
	expect(content.load_all(locale), "Load content for " + locale)
	var game := GameState.new()
	configure_game(content, game)
	complete_intro_and_lv1(game)

	var lv2_def: Dictionary = game.special_event_definitions[EVENT_ID]
	game.meet_staff("doc_shiori")

	# Gate checks: cooldown < 3 days or familiarity < 25 must block Lv2
	game.add_familiarity("doc_rei", 14) # total 24 (< 25)
	game.advance_story_to_day(7, 540) # only 2 days after day-5 settlement
	expect(not game.special_event_available(lv2_def), "Lv2 must stay gated at familiarity 24 and day 7")

	game.add_familiarity("doc_rei", 1) # total 25, still day 7 (< 3-day cooldown)
	expect(not game.special_event_available(lv2_def), "Lv2 must honor 3-day milestone cooldown")

	# Re-verify familiarity < 25 on day 8 also blocks
	game.add_familiarity("doc_rei", -1) # back to 24
	game.advance_story_to_day(8, 540)
	expect(not game.special_event_available(lv2_def), "Lv2 must stay gated at familiarity 24 on day 8")

	game.add_familiarity("doc_rei", 1) # total 25 on day 8
	game.set_story_flag("__test_save_target_event__" + EVENT_ID, true)
	expect(game.special_event_available(lv2_def), "Lv2 unlocks at Lv1 + familiarity 25 + 3-day cooldown")

	var ev = game.start_special_event(EVENT_ID)
	expect(ev != null, "Start miyama_02_manga_artist_wrong_patient (" + locale + ")")
	expect(not game.save_block_reason().is_empty(), "Saving blocked during active Lv2 special event")

	var expected_clocks := {
		"s01_001": 540,
		"s09_001": 675,
		"s12_001": 690,
		"s24_006": 960,
		"s25b_003": 1005,
		"s26_001": 1050,
		"s28_001": 1080,
		"s31_001": 1140,
		"s32_016": 1150,
	}

	var visited := {}
	var guard := 0
	while not ev.completed and guard < 800:
		guard += 1
		var node: Dictionary = ev.current()
		var nid := str(node.get("id", ""))
		visited[nid] = true

		if expected_clocks.has(nid):
			var disp: Dictionary = game.display_schedule()
			expect(int(disp.get("absolute_clock", -1)) == expected_clocks[nid], "Clock mismatch at %s: got %s, expected %s" % [nid, disp.get("absolute_clock", -1), expected_clocks[nid]])

		if locale == "en":
			var t_key := "collections.special_event_steps.%s.nodes.%s.text" % [STEP_ID, nid]
			var loc_txt: String = content.text(t_key, str(node.get("text", "")))
			expect(not loc_txt.strip_edges().is_empty() and not has_cjk(loc_txt), "EN runtime text missing or has CJK at " + nid)
			var raw_spk := str(node.get("speaker_label", ""))
			if not raw_spk.is_empty():
				var s_key := "collections.special_event_steps.%s.nodes.%s.speaker_label" % [STEP_ID, nid]
				var loc_spk: String = content.text(s_key, raw_spk)
				expect(not has_cjk(loc_spk), "EN speaker_label has CJK at " + nid)

		var choices: Array = node.get("choices", [])
		expect(not choices.is_empty(), "Choices non-empty at " + nid)
		var res: Dictionary = game.choose_special_event(str(choices[0].id))
		expect(bool(res.get("accepted", false)), "Choice accepted at " + nid)

	expect(ev.completed, "Completed Lv2 playthrough (" + locale + ")")
	expect(visited.size() == 563, "Expected 563 visited nodes, got %s" % visited.size())
	game.finish_special_event()
	return [content, game, visited]

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for path in [
		"res://assets/events/character_events/rei/ayako/cg_01_lucky.png",
		"res://assets/events/character_events/rei/ayako/cg_02_patient_disguise.png",
		"res://assets/events/character_events/rei/ayako/cg_03_or_table.png",
		"res://assets/events/character_events/rei/ayako/cg_03a_first_incision_pre.png",
		"res://assets/events/character_events/rei/ayako/cg_03b_first_incision_after.png",
		"res://assets/events/character_events/rei/ayako/cg_04_lesion_missing.png",
		"res://assets/events/character_events/rei/ayako/cg_05_firsthand_notes.png",
		"res://assets/characters/portrait_pack_v15/doc_asuka/director_suit/neutral.png",
		"res://assets/characters/portrait_pack_v20/doc_rei/white_coat/tired.png",
		"res://assets/characters/portrait_pack_v20/doc_rei/white_coat/smile.png",
		"res://assets/backgrounds/v10/preop_conference_room.png",
	]:
		expect(ResourceLoader.exists(path) and load(path) != null, "Asset loads cleanly: " + path)

	var zh_res := run_locale_playthrough("zh_CN")
	var en_res := run_locale_playthrough("en")

	var content: Loader = zh_res[0]
	var game: GameState = zh_res[1]
	var visited: Dictionary = zh_res[2]

	for req_node in ["s01_014", "s01_020", "s01_023", "s08_023", "s09_001", "s24_006", "s25_015", "s25b_003", "s25b_010", "s25b_014", "s25b_020", "s32_001", "s32_013", "s32_016", "s32_019", "s34_001"]:
		expect(visited.has(req_node), "Visited V9.1 key node: " + req_node)

	expect(game.relationship_level("doc_rei") == 2, "Settled doc_rei relationship Lv2")
	for flag in [
		"miyama_02_manga_artist_wrong_patient_completed",
		"relationship_doc_rei_lv2",
		"guest_ayako_met",
		"ayako_wrong_surgery_survived",
		"ayako_appendectomy_completed",
		"ayako_surgical_field_photo_owned",
		"true_gastric_patient_fled_or",
		"true_gastric_patient_found_safe",
		"true_gastric_patient_surgery_rescheduled",
		"patient_id_protocol_reviewed",
		"origin_of_patient_disguise_unresolved",
		"shared_crisis_memory",
		"shiori_knows_ayako_incident",
		"ayako_shiori_reconnected",
	]:
		expect(game.story_flag(flag), "Completion flag set: " + flag)
	expect(game.special_event_gallery_unlocked(EVENT_ID), "Lv2 gallery replay unlocked")

	# Verify v37 BoundarySave safety & zero inner-node leakage in isolated /private/tmp file
	expect(game.save_block_reason().is_empty(), "Safe boundary save permitted after completion")
	var tmp_save := "/private/tmp/kaori_lv2_test_save_%s.json" % OS.get_process_id()
	var store := SaveStore.new()
	store.path = tmp_save
	expect(store.write_slot(game, 1), "Write slot 1 to isolated tmp save")
	var raw_json := FileAccess.get_file_as_string(tmp_save)
	for forbidden in ["s01_001", "s25b_003", "s32_016", "s34_001", "node_id"]:
		expect(not raw_json.contains(forbidden), "Boundary save leaked internal node state: " + forbidden)

	var clone := GameState.new()
	configure_game(content, clone)
	expect(store.read_slot(clone, 1), "Restore slot 1 from isolated tmp save")
	expect(clone.relationship_level("doc_rei") == 2 and clone.special_event_done(EVENT_ID) and clone.story_flag("shared_crisis_memory"), "Restored Lv2 rank, completion, and settled flags")
	DirAccess.remove_absolute(tmp_save)

	var en_game: GameState = en_res[1]
	expect(en_game.relationship_level("doc_rei") == 2 and en_game.special_event_done(EVENT_ID), "EN playthrough settled Lv2")

	print("KAORI LV2 V9.1 TEST: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
