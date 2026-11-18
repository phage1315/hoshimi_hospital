extends SceneTree
## Runtime regression test for Asuka Shiromiya (`doc_asuka`) Relationship Lv2:
## 《合适的人，合适的手术袍》 (`asuka_lv2_right_person_right_gown`)
##
## Verifies:
## 1. Content loading, `sample_gown/*` + `doc_maki/interview/*` Texture2D loading.
## 2. Exact gate boundaries (`Lv1`, `Familiarity 24 vs 25`, `Charm 24 vs 25`,
##    3-day milestone cooldown, `720..960` afternoon window at `director_office`,
##    blocked on Sunday & public holiday, allowed on open Mon-Sat workdays).
## 3. Unmet co-starring staff compatibility (`doc_emiko`, `doc_artoria`, `doc_aoi`,
##    `nurse_hiroko` at `met == false` neither block trigger nor get flipped to `met == true`).
## 4. Full walkthroughs of all 4 combinations of Choice B1 & Choice C1 (zero RP delta,
##    atomic `Lv1 -> Lv2` promotion, `+125` settled minutes, completion story flags).
## 5. Deferred onboarding hard-lock for Maki Aizawa (`doc_maki` stays `met == false`,
##    excluded from `known_staff_ids()`, routine/advanced assistant pools, Sunday dates,
##    and map presence, while `AsukaLv2.offer_accepted`, `interview_day`, and
##    ~1-month `onboarding_earliest_day` settle cleanly).
## 6. BoundarySave v37 round-trip (zero inner state, save locked during event,
##    `interview_day`, `Lv2`, and Maki lock preserved across save/restore).
## 7. Full `zh_CN` and `en` UI walkthrough via `main.tscn` with zero CJK leaks in English.

const EVENT_ID := "asuka_lv2_right_person_right_gown"
const LV1_PREOP := "asuka_lv1_director_surgeon_preop"
const LV1_POSTOP := "asuka_lv1_director_surgeon_postop"
const INTRO_OFFICE := "intro_doc_asuka_director_office"

const EXPECTED_PORTRAITS := [
	"assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/smile.png",
	"assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/proud.png",
	"assets/characters/asuka_lv2_v1/doc_asuka/sample_gown/reluctant_cuff.png",
	"assets/characters/maki_original_style_v1/doc_maki/interview/neutral.png",
	"assets/characters/maki_original_style_v1/doc_maki/interview/focused.png",
	"assets/characters/maki_original_style_v1/doc_maki/interview/worried.png",
	"assets/characters/maki_original_style_v1/doc_maki/interview/relieved.png",
]

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const Advanced = preload("res://godot/systems/advanced_referral.gd")
const EventSession = preload("res://godot/systems/character_event_session.gd")
const AsukaLv2 = preload("res://godot/systems/asuka_lv2.gd")
const Codec = preload("res://godot/systems/boundary_save.gd")
const Calendar = preload("res://godot/systems/fixed_calendar.gd")

var app
var checks := 0
var failures := 0
var han := RegEx.new()

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func inspect_clean(value: Variant, path: String = "root") -> void:
	if value is Dictionary:
		for key in value:
			expect(
				key not in [
					"node_id", "stage_id", "choices", "choice_id", "action_log",
					"last_choice", "feedback", "speaker", "opening_index", "response_index",
					"procedure_step_index", "resolved_random_choices", "surgery_rng_seed",
					"case_variant_id", "diagnosis_action_order", "active_special_event",
					"active_adult_intimacy", "asuka_lv1_active", "asuka_lv1_postop_opportunity",
				],
				"no inner state at " + path + "." + str(key)
			)
			inspect_clean(value[key], path + "." + str(key))
	elif value is Array:
		for item in value:
			inspect_clean(item, path)

func contains_maki(rows: Array) -> bool:
	return rows.any(func(row): return str(row.get("id", "")) == "doc_maki")

func _initialize() -> void:
	han.compile("[㐀-鿿]")
	call_deferred("run")

func set_exact_clock(game: RefCounted, day: int, clock_min: int) -> void:
	game.set_test_time(day, clock_min)
	var expected_elapsed: int = (day - 1) * int(game.SHIFT_MINUTES) + clock_min - int(game.SHIFT_START_MINUTE)
	game.story_time_advance_minutes += expected_elapsed - int(game.elapsed())

func seed_lv1_ready_state(game: RefCounted, lv1_day: int = 3, current_day: int = 8, clock_min: int = 815) -> void:
	game.reset()
	game.meet_staff("doc_asuka")
	var rel: Dictionary = game.relation_for("doc_asuka")
	rel.met = true
	rel.level = 1
	rel.familiarity = 25
	game.set_test_player_attribute("charm", 25)
	game._complete_character_event_for_test("asuka_scrub_sink_encounter", 1)
	game._complete_character_event_for_test("asuka_adjacent_operation_reveal", 1)
	game._complete_character_event_for_test(INTRO_OFFICE, 2)
	game._complete_character_event_for_test(LV1_PREOP, lv1_day)
	game._complete_character_event_for_test(LV1_POSTOP, lv1_day)
	if not rel.rank_history.has(LV1_POSTOP):
		rel.rank_history.append(LV1_POSTOP)
	game.set_story_flag("asuka_lv1_complete", true)
	set_exact_clock(game, current_day, clock_min)

func complete_lv2_in_game(game: RefCounted, b1_idx: int, c1_idx: int) -> Dictionary:
	var before_elapsed: int = game.elapsed()
	expect(game.start_character_event(EVENT_ID) != null, "start_character_event " + EVENT_ID)
	expect(not game.can_save_progress(), "save locked upon starting Lv2")
	var guard := 0
	var b1_seen := false
	var c1_seen := false
	while not game.active_character_event_id.is_empty() and guard < 300:
		guard += 1
		var ev = game.character_events[EVENT_ID]
		if ev.completed:
			break
		var node: Dictionary = ev.current()
		var nid := str(node.get("id", ""))
		expect(not game.can_save_progress(), "save locked at node " + nid)
		var ch_list: Array = node.get("choices", [])
		expect(not ch_list.is_empty(), "non-empty choices at " + nid)
		var pick := 0
		if nid == "al2_choice_b1":
			b1_seen = true
			pick = b1_idx
		elif nid == "al2_choice_c1":
			c1_seen = true
			pick = c1_idx
		expect(game.choose_character_event(str(ch_list[pick].id)), "choose at " + nid)
	expect(b1_seen and c1_seen, "both RP choices visited")
	expect(game.character_events[EVENT_ID].completed, "Lv2 session completed")
	game.finish_character_event()
	expect(game.can_save_progress(), "save unlocked after finish_character_event")
	expect(game.elapsed() - before_elapsed == 125, "settled 125 minutes")
	var rel: Dictionary = game.relation_for("doc_asuka")
	return {
		"level": int(rel.level),
		"familiarity": int(rel.familiarity),
		"affection": int(rel.affection),
		"route": str(rel.route),
		"charm": int(game.player_attributes().get("charm", 0)),
	}

func verify_maki_still_locked(game: RefCounted, c: Dictionary, label_prefix: String) -> void:
	expect(not bool(game.relation_for("doc_maki").get("met", false)), label_prefix + ": maki relation.met stays false")
	expect(not game.staff_is_met("doc_maki"), label_prefix + ": staff_is_met(doc_maki) stays false")
	expect("doc_maki" not in game.known_staff_ids(), label_prefix + ": doc_maki excluded from known_staff_ids")
	expect(not game.staff_can_join_surgery_team("doc_maki"), label_prefix + ": doc_maki cannot join surgery team")
	expect(not game.sunday_date_eligible("doc_maki"), label_prefix + ": doc_maki Sunday date stays locked")
	expect("doc_maki" not in game.staff_present_at("lounge"), label_prefix + ": doc_maki not present at lounge")
	var prep = Preop.new(c.preops[0], c.staff, c.surgeries, c.patients, game.known_staff_ids(), true)
	expect(not contains_maki(prep.candidates("assistant_surgeon")), label_prefix + ": doc_maki excluded from routine assistant pool")
	var adv = Advanced.new(game)
	expect(not contains_maki(adv.candidates("first_assistant", 1)), label_prefix + ": doc_maki excluded from advanced 1st assistant")
	expect(not contains_maki(adv.candidates("second_assistant", 1)), label_prefix + ": doc_maki excluded from advanced 2nd assistant")

func run_ui_walkthrough(locale: String, b1_idx: int, c1_idx: int) -> void:
	app.content.load_all(locale)
	app.configure_game_content()
	seed_lv1_ready_state(app.game, 3, 8, 815)
	app.screen = "hospital"
	app.show_location("director_office")
	await process_frame
	expect(app.game.active_character_event_id == EVENT_ID, locale + ": auto-started Lv2 upon entering director_office at 13:35")
	var guard := 0
	var seen_sample_gown := false
	var seen_maki_portrait := false
	while app.game.active_character_event_id == EVENT_ID and guard < 400:
		guard += 1
		var ev = app.game.character_events[EVENT_ID]
		if ev.completed:
			break
		if app.page.get_node_or_null("EventDialogueContinue") != null:
			app.advance_dialogue_page(app.show_character_event)
			await process_frame
			continue
		var node: Dictionary = ev.current()
		var nid := str(node.get("id", ""))
		if app.page.get_node_or_null("EventPortrait_doc_maki") != null:
			seen_maki_portrait = true
		for p in node.get("event_portraits", []):
			if "sample_gown/" in str(p.get("path", "")):
				seen_sample_gown = true
		if locale == "en":
			var dlg: Node = app.page.get_node_or_null("CharacterEventDialogue")
			if dlg != null:
				for child in dlg.get_children():
					if child is Label:
						expect(han.search(child.text) == null, "en dialogue zero CJK at " + nid + ": " + child.text)
		var ch_list: Array = node.get("choices", [])
		var pick := 0
		if nid == "al2_choice_b1":
			pick = b1_idx
		elif nid == "al2_choice_c1":
			pick = c1_idx
		var cid := str(ch_list[pick].id)
		var btn: Button = app.page.get_node_or_null("EventChoice_" + cid)
		expect(btn != null, locale + ": button exists for " + cid + " at " + nid)
		if locale == "en" and btn != null:
			expect(han.search(btn.text) == null, "en choice button zero CJK at " + nid)
		app.choose_character_event(cid)
		await process_frame
	expect(seen_maki_portrait, locale + ": rendered EventPortrait_doc_maki during Scene B")
	expect(seen_sample_gown, locale + ": staged Asuka sample_gown portraits during Scene C")
	expect(app.screen == "character_event_complete" and app.game.character_event_done(EVENT_ID), locale + ": UI walkthrough completed Lv2")
	app.show_map(false)
	await process_frame
	expect(app.game.can_save_progress(), locale + ": safe boundary restored after show_map")
	expect(app.game.relationship_level("doc_asuka") == 2, locale + ": Asuka promoted to Lv2 after UI walkthrough")

func run() -> void:
	for p in EXPECTED_PORTRAITS:
		var tex := load("res://" + p)
		expect(tex is Texture2D, "Texture2D loaded: " + p)

	var content = Loader.new()
	expect(content.load_all("zh_CN"), "load_all zh_CN")
	var c = content.collections
	var game = Game.new()
	game.configure(
		c.encounters, c.preops, c.staff, c.time_events, c.surgeries, c.patients,
		c.relationships, c.character_events, c.case_templates, c.micro_events,
		c.examination_cg_pools, c.surgery_team_dialogue_profiles, c.patient_interactions,
		c.temporary_conditions, c.staff_role_cg_rewards, c.special_events,
		c.special_event_steps, c.date_profiles, c.date_locations, c.advanced_referral_cases,
		c.first_surgery_diagnosis_reactions, c.palpation_profiles, c.awake_special_barks
	)
	expect(game.character_event_definitions.has(EVENT_ID), "Lv2 definition registered")

	# 1. Gate checks
	seed_lv1_ready_state(game, 3, 8, 815) # 2025-04-08 Tue 13:35
	expect(game.next_character_event_at("director_office").get("id", "") == EVENT_ID, "available at director_office 13:35")
	expect(game.next_character_event_at("or").get("id", "") != EVENT_ID, "not triggered at OR")

	# Time window boundaries (720..960)
	set_exact_clock(game, 8, 719)
	expect(game.next_character_event_at("director_office").get("id", "") != EVENT_ID, "blocked at 11:59 (719)")
	set_exact_clock(game, 8, 720)
	expect(game.next_character_event_at("director_office").get("id", "") == EVENT_ID, "allowed at 12:00 (720)")
	set_exact_clock(game, 8, 960)
	expect(game.next_character_event_at("director_office").get("id", "") == EVENT_ID, "allowed at 16:00 (960)")
	set_exact_clock(game, 8, 961)
	expect(game.next_character_event_at("director_office").get("id", "") != EVENT_ID, "blocked at 16:01 (961)")

	# Saturday limited workday allowed, Sunday & public holiday blocked
	set_exact_clock(game, 12, 815) # 2025-04-12 Saturday
	expect(not game.is_hospital_closed_day(12), "Saturday day 12 is open")
	expect(game.next_character_event_at("director_office").get("id", "") == EVENT_ID, "allowed on Saturday afternoon")
	set_exact_clock(game, 13, 815) # 2025-04-13 Sunday
	expect(game.next_character_event_at("director_office").get("id", "") != EVENT_ID, "blocked on Sunday")
	var showa_day := Calendar.day_for_iso("2025-04-29")
	set_exact_clock(game, showa_day, 815)
	expect(game.is_hospital_closed_day(showa_day), "2025-04-29 is public holiday")
	expect(game.next_character_event_at("director_office").get("id", "") != EVENT_ID, "blocked on public holiday")

	# Familiarity, Charm, Level, and 3-day cooldown gates
	seed_lv1_ready_state(game, 3, 8, 815)
	game.relation_for("doc_asuka").familiarity = 24
	expect(game.next_character_event_at("director_office").get("id", "") != EVENT_ID, "blocked at familiarity 24")
	game.relation_for("doc_asuka").familiarity = 25
	game.set_test_player_attribute("charm", 24)
	expect(game.next_character_event_at("director_office").get("id", "") != EVENT_ID, "blocked at charm 24")
	game.set_test_player_attribute("charm", 25)
	game.relation_for("doc_asuka").level = 0
	expect(game.next_character_event_at("director_office").get("id", "") != EVENT_ID, "blocked at Lv0")
	game.relation_for("doc_asuka").level = 1
	set_exact_clock(game, 5, 815) # lv1_day=3 -> day 5 is +2 days (<3 cooldown)
	expect(game.next_character_event_at("director_office").get("id", "") != EVENT_ID, "blocked at +2 days cooldown")
	set_exact_clock(game, 7, 815) # 2025-04-07 Monday (+4 days >= 3)
	expect(game.next_character_event_at("director_office").get("id", "") == EVENT_ID, "allowed once >=3 days cooldown met")

	# 2. Unmet co-star compatibility + all 4 choice combinations equivalence
	var outcomes: Array[Dictionary] = []
	for b1 in [0, 1]:
		for c1 in [0, 1]:
			seed_lv1_ready_state(game, 3, 8, 815)
			for co_id in ["doc_emiko", "doc_artoria", "doc_aoi", "nurse_hiroko"]:
				game.relation_for(co_id).met = false
			var res := complete_lv2_in_game(game, b1, c1)
			outcomes.append(res)
			for co_id in ["doc_emiko", "doc_artoria", "doc_aoi", "nurse_hiroko"]:
				expect(not bool(game.relation_for(co_id).get("met", false)), "co-star met unchanged for " + co_id)
			expect(res.level == 2, "promoted to Lv2")
			expect(game.story_flag("asuka_lv2_complete"), "story flag asuka_lv2_complete set")
			expect(game.story_flag("maki_aizawa_offer_accepted"), "story flag maki_aizawa_offer_accepted set")
			expect(AsukaLv2.offer_accepted(game), "AsukaLv2.offer_accepted true")
			expect(AsukaLv2.interview_day(game) == 8, "AsukaLv2.interview_day recorded as day 8")
			var earliest := AsukaLv2.onboarding_earliest_day(game)
			expect(earliest == 38, "2025-04-08 + 1 month == day 38 (2025-05-08)")
			expect(not AsukaLv2.ready_for_onboarding_event(game, 8), "not ready for onboarding on interview day")
			expect(not AsukaLv2.ready_for_onboarding_event(game, 37), "not ready 1 day before 1-month mark")
			expect(AsukaLv2.ready_for_onboarding_event(game, 38), "ready for onboarding on 2025-05-08 (day 38)")
			verify_maki_still_locked(game, c, "combo(%d,%d)" % [b1, c1])

	for i in range(1, outcomes.size()):
		expect(outcomes[i] == outcomes[0], "RP choice branch %d produces identical settled stats to branch 0" % i)

	# 3. BoundarySave v37 round-trip verification (memory only, zero player slots touched)
	var saved_payload: Dictionary = game.snapshot()
	expect(saved_payload.get("save_format") == Codec.FORMAT and int(saved_payload.get("version", 0)) == Codec.VERSION, "BoundarySave v37 format")
	inspect_clean(saved_payload)
	var snap_json := JSON.stringify(saved_payload)
	expect(not snap_json.contains("al2_0") and not snap_json.contains("al2_1") and not snap_json.contains("al2_choice"), "zero internal node IDs in BoundarySave payload")
	var restored = Game.new()
	restored.configure(
		c.encounters, c.preops, c.staff, c.time_events, c.surgeries, c.patients,
		c.relationships, c.character_events, c.case_templates, c.micro_events,
		c.examination_cg_pools, c.surgery_team_dialogue_profiles, c.patient_interactions,
		c.temporary_conditions, c.staff_role_cg_rewards, c.special_events,
		c.special_event_steps, c.date_profiles, c.date_locations, c.advanced_referral_cases,
		c.first_surgery_diagnosis_reactions, c.palpation_profiles, c.awake_special_barks
	)
	expect(restored.restore(saved_payload), "GameState.restore ok: " + restored.last_error)
	expect(restored.relationship_level("doc_asuka") == 2, "restored Asuka Lv2")
	expect(restored.elapsed() == game.elapsed(), "restored settled elapsed minutes unchanged")
	expect(AsukaLv2.offer_accepted(restored), "restored offer_accepted")
	expect(AsukaLv2.interview_day(restored) == 8, "restored interview_day == 8")
	expect(AsukaLv2.onboarding_earliest_day(restored) == 38, "restored onboarding_earliest_day == 38")
	verify_maki_still_locked(restored, c, "after_v37_restore")

	# Also verify prepare_character_event_test_save works cleanly
	expect(game.prepare_character_event_test_save(EVENT_ID), "prepare_character_event_test_save succeeds")
	expect(game.next_character_event_at("director_office").get("id", "") == EVENT_ID, "test save lands ready at director_office")

	# 4. Full UI walkthroughs (`zh_CN` + `en`) via main.tscn
	var tmp_save_path := "/private/tmp/asuka_lv2_unused_%s.json" % OS.get_process_id()
	var packed: PackedScene = load("res://godot/scenes/main.tscn")
	app = packed.instantiate()
	app.saves.path = tmp_save_path
	root.add_child(app)
	await process_frame
	await process_frame

	await run_ui_walkthrough("zh_CN", 0, 0)
	await run_ui_walkthrough("en", 1, 1)

	# Gallery replay check
	app.replay_gallery_entry(EVENT_ID)
	expect(app.screen == "gallery_replay" and app.gallery_replay_event != null, "Gallery Replay starts for Asuka Lv2")
	app.show_map(false)
	expect(app.game.can_save_progress(), "safe boundary after Gallery Replay")

	if FileAccess.file_exists(tmp_save_path):
		DirAccess.remove_absolute(tmp_save_path)

	print("ASUKA LV2 TEST: %d checks, %d failure(s)." % [checks, failures])
	quit(1 if failures > 0 else 0)
