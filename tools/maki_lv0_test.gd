extends SceneTree
## Runtime regression test for Maki Aizawa (`doc_maki`) Relationship Lv0
## standalone onboarding / formal acquaintance event:
## 《排班表上的名字》 (`maki_lv0_onboarding`).
##
## Verifies (`MK0-L01`..`MK0-L09` + v37 Save Boundary):
## 1. Content registration and Texture2D loading of all 14 portrait assets used.
## 2. Trigger gates: requires `asuka_lv2_right_person_right_gown` + ~1-month
##    delay (`onboarding_earliest_day`), zero extra Charm/Skill/Reputation gates,
##    `day_start` (`09:00`) on open Mon-Sat workdays, automatic deferral across
##    Sundays, public holidays (`2025-05-06`), and active clinical/preop states.
## 3. Mid-event invariants across every node: `can_save_progress() == false`,
##    `staff_is_met("doc_maki") == false`, `active_surgery_in_progress() == false`,
##    `completed_surgeries_total` unchanged (pure fixed VN surgery in Scene C),
##    and co-star `nurse_hiroko` `met` state untouched.
## 4. Choice D1 Branch A & Branch B equivalence (zero stat/flag delta).
## 5. Atomic `@end` unlock: `staff_is_met("doc_maki") == true`, routine
##    `assistant_surgeon` + advanced `first_assistant`/`second_assistant`
##    unlocked while `primary_surgeon` stays locked, `lounge` fixed presence,
##    and `sunday_date_eligible` gated on `familiarity >= 10`.
## 6. BoundarySave v37 round-trip (zero inner node/choice state, settled clock
##    and unlocks preserved, never re-triggers).
## 7. Full `zh_CN` (weekday -> next weekday) and `en` (Saturday -> Sunday menu,
##    zero CJK leaks) UI walkthroughs via `main.tscn` + Gallery Replay.

const EVENT_ID := "maki_lv0_onboarding"
const ASUKA_LV2_ID := "asuka_lv2_right_person_right_gown"

const EXPECTED_PORTRAITS := [
	"assets/characters/maki_original_style_v1/doc_maki/white_coat/neutral.png",
	"assets/characters/maki_original_style_v1/doc_maki/white_coat/focused.png",
	"assets/characters/maki_original_style_v1/doc_maki/white_coat/worried.png",
	"assets/characters/maki_original_style_v1/doc_maki/white_coat/smile.png",
	"assets/characters/maki_original_style_v1/doc_maki/sterile/neutral.png",
	"assets/characters/maki_original_style_v1/doc_maki/sterile/focused.png",
	"assets/characters/maki_original_style_v1/doc_maki/sterile/worried.png",
	"assets/characters/maki_original_style_v1/doc_maki/casual/neutral.png",
	"assets/characters/maki_original_style_v1/doc_maki/casual/focused.png",
	"assets/characters/maki_original_style_v1/doc_maki/casual/worried.png",
	"assets/characters/portrait_pack_v15/doc_asuka/white_coat/neutral.png",
	"assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/scrubs/warm.png",
	"assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/neutral.png",
	"assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/focused.png",
	"assets/characters/hiroko_cheek_revision_v1/nurse_hiroko/sterile/warm.png",
]

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const Advanced = preload("res://godot/systems/advanced_referral.gd")
const AsukaLv2 = preload("res://godot/systems/asuka_lv2.gd")
const MakiLv0 = preload("res://godot/systems/maki_lv0.gd")
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

func contains_staff(rows: Array, staff_id: String) -> bool:
	return rows.any(func(row): return str(row.get("id", "")) == staff_id)

func _initialize() -> void:
	han.compile("[㐀-鿿぀-ヿ]")
	call_deferred("run")

func set_exact_clock(game: RefCounted, day: int, clock_min: int) -> void:
	game.set_test_time(day, clock_min)
	var expected_elapsed: int = (day - 1) * int(game.SHIFT_MINUTES) + clock_min - int(game.SHIFT_START_MINUTE)
	game.story_time_advance_minutes += expected_elapsed - int(game.elapsed())

func seed_post_asuka_lv2(game: RefCounted, interview_day: int = 8, current_day: int = 38, clock_min: int = 540) -> void:
	game.reset()
	AsukaLv2.prepare_test_save(game, ASUKA_LV2_ID, interview_day)
	game._complete_character_event_for_test(ASUKA_LV2_ID, interview_day)
	var asuka_rel: Dictionary = game.relation_for("doc_asuka")
	asuka_rel.met = true
	asuka_rel.level = 2
	if not asuka_rel.rank_history.has(ASUKA_LV2_ID):
		asuka_rel.rank_history.append(ASUKA_LV2_ID)
	game.set_story_flag(AsukaLv2.FLAG_COMPLETE, true)
	game.set_story_flag(AsukaLv2.FLAG_MAKI_OFFER, true)
	var maki_rel: Dictionary = game.relation_for("doc_maki")
	maki_rel.met = false
	maki_rel.level = 0
	maki_rel.familiarity = 0
	maki_rel.affection = 0
	# Explicitly zero player attributes to prove zero extra stat gates
	game.set_test_player_attribute("charm", 0)
	game.set_test_player_attribute("skill", 0)
	game.set_test_player_attribute("reputation", 0)
	set_exact_clock(game, current_day, clock_min)

func complete_lv0_in_game(game: RefCounted, d1_idx: int) -> Dictionary:
	var surgeries_before: int = int(game.completed_surgeries_total)
	var start_day: int = int(game.day_number())
	expect(game.start_character_event(EVENT_ID) != null, "start_character_event " + EVENT_ID)
	var guard := 0
	var d1_seen := false
	while not game.active_character_event_id.is_empty() and guard < 220:
		guard += 1
		var ev = game.character_events[EVENT_ID]
		if ev.completed:
			break
		var node: Dictionary = ev.current()
		var nid := str(node.get("id", ""))
		expect(not game.can_save_progress(), "save locked at " + nid)
		expect(not game.staff_is_met("doc_maki"), "doc_maki stays unmet during playback at " + nid)
		expect(not bool(game.relation_for("doc_maki").get("met", false)), "maki relation.met false at " + nid)
		expect(not game.staff_can_join_surgery_team("doc_maki"), "maki excluded from surgery team at " + nid)
		expect(not game.active_surgery_in_progress(), "no Surgery Runner active at " + nid)
		expect(game.active_preop_id.is_empty(), "no active_preop_id at " + nid)
		expect(int(game.completed_surgeries_total) == surgeries_before, "completed_surgeries_total unchanged at " + nid)
		var ch_list: Array = node.get("choices", [])
		var pick := 0
		if nid == "mk0_choice_d1":
			d1_seen = true
			pick = d1_idx
		expect(game.choose_character_event(str(ch_list[pick].id)), "choose at " + nid)
	expect(d1_seen, "Choice D1 visited")
	expect(game.character_events[EVENT_ID].completed, "Lv0 session completed")
	game.advance_story_to_day(start_day + 1, 540)
	game.finish_character_event()
	expect(game.can_save_progress(), "save unlocked at next-morning boundary")
	expect(int(game.completed_surgeries_total) == surgeries_before, "routine surgery count untouched after Lv0")
	var rel: Dictionary = game.relation_for("doc_maki")
	return {
		"met": bool(rel.met),
		"level": int(rel.level),
		"familiarity": int(rel.familiarity),
		"affection": int(rel.affection),
		"route": str(rel.route),
		"day": int(game.day_number()),
		"clock": int(game.current_absolute_clock()),
	}

func verify_maki_unlocked(game: RefCounted, c: Dictionary, label_prefix: String) -> void:
	expect(game.character_event_done(EVENT_ID), label_prefix + ": maki_lv0_onboarding marked done")
	expect(game.story_flag(MakiLv0.FLAG_COMPLETE), label_prefix + ": maki_lv0_complete flag set")
	expect(game.story_flag(MakiLv0.FLAG_ONBOARDED), label_prefix + ": maki_aizawa_onboarded flag set")
	expect(bool(game.relation_for("doc_maki").get("met", false)), label_prefix + ": relation.met == true")
	expect(game.staff_is_met("doc_maki"), label_prefix + ": staff_is_met(doc_maki) == true")
	expect("doc_maki" in game.known_staff_ids(), label_prefix + ": doc_maki in known_staff_ids")
	expect(game.staff_can_join_surgery_team("doc_maki"), label_prefix + ": doc_maki can join surgery team")
	expect("doc_maki" in game.staff_present_at("lounge"), label_prefix + ": doc_maki present at lounge")

	var prep = Preop.new(c.preops[0], c.staff, c.surgeries, c.patients, game.known_staff_ids(), true)
	expect(contains_staff(prep.candidates("assistant_surgeon"), "doc_maki"), label_prefix + ": doc_maki in routine assistant_surgeon pool")
	expect(not contains_staff(prep.candidates("primary_surgeon"), "doc_maki"), label_prefix + ": doc_maki excluded from primary_surgeon pool")
	var primary_role := {"id": "primary_surgeon"}
	expect(not prep.qualified("doc_maki", primary_role), label_prefix + ": doc_maki not qualified as primary_surgeon")

	var adv = Advanced.new(game)
	expect(contains_staff(adv.candidates("first_assistant", 1), "doc_maki"), label_prefix + ": doc_maki in advanced 1st assistant pool")
	expect(contains_staff(adv.candidates("second_assistant", 1), "doc_maki"), label_prefix + ": doc_maki in advanced 2nd assistant pool")

	var saved_fam := int(game.relation_for("doc_maki").get("familiarity", 0))
	game.relation_for("doc_maki").familiarity = 9
	expect(not game.sunday_date_eligible("doc_maki"), label_prefix + ": Sunday date locked at familiarity 9")
	game.relation_for("doc_maki").familiarity = 10
	expect(game.sunday_date_eligible("doc_maki"), label_prefix + ": Sunday date unlocked at familiarity 10")
	game.relation_for("doc_maki").familiarity = saved_fam

func run_ui_walkthrough(locale: String, start_day: int, d1_idx: int, expect_sunday_landing: bool, via_day_transition_map: bool) -> void:
	app.content.load_all(locale)
	app.configure_game_content()
	expect(app.game.prepare_character_event_test_save(EVENT_ID), locale + ": prepare_character_event_test_save")
	set_exact_clock(app.game, start_day, 540)
	# Explicitly zero player attributes to confirm UI flow needs zero extra gates
	app.game.set_test_player_attribute("charm", 0)
	app.game.set_test_player_attribute("skill", 0)
	app.game.set_test_player_attribute("reputation", 0)
	app.show_map(not via_day_transition_map)
	await process_frame
	expect(app.game.active_character_event_id == EVENT_ID, locale + ": auto-started maki_lv0_onboarding on show_map")
	expect(app.screen == "character_event", locale + ": entered character_event screen")
	var header: Control = app.page.get_node_or_null("CalendarHeader")
	expect(header != null and not header.visible, locale + ": CalendarHeader hidden during full-day narrative")

	var guard := 0
	var seen_or_sterile := false
	var seen_casual_dusk := false
	while app.game.active_character_event_id == EVENT_ID and guard < 360:
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
		expect(not app.game.staff_is_met("doc_maki"), locale + ": maki unmet mid-UI at " + nid)
		for ep in node.get("event_portraits", []):
			var p := str(ep.get("path", ""))
			if "doc_maki/sterile/" in p:
				seen_or_sterile = true
			elif "doc_maki/casual/" in p:
				seen_casual_dusk = true
		if locale == "en":
			var dlg: Node = app.page.get_node_or_null("CharacterEventDialogue")
			if dlg != null:
				for child in dlg.get_children():
					if child is Label:
						expect(han.search(child.text) == null, "en dialogue zero CJK at " + nid + ": " + child.text)
		var ch_list: Array = node.get("choices", [])
		var pick := d1_idx if nid == "mk0_choice_d1" else 0
		var cid := str(ch_list[pick].id)
		var btn: Button = app.page.get_node_or_null("EventChoice_" + cid)
		expect(btn != null, locale + ": choice button exists for " + cid + " at " + nid)
		if locale == "en" and btn != null:
			expect(han.search(btn.text) == null, "en choice button zero CJK at " + nid)
		app.choose_character_event(cid)
		await process_frame

	expect(seen_or_sterile, locale + ": rendered Maki sterile portrait in Scene C")
	expect(seen_casual_dusk, locale + ": rendered Maki casual portrait in Scene E")
	expect(app.screen == "day_transition", locale + ": showed day_transition after dusk finale")
	expect(app.game.staff_is_met("doc_maki"), locale + ": doc_maki met atomically upon reaching @end")
	expect(int(app.game.day_number()) == start_day + 1 and int(app.game.current_absolute_clock()) == 540, locale + ": settled to Day+1 09:00")

	# Verify show_character_event_complete card renders Maki smile & localized Lv0 summary cleanly
	app.show_character_event_complete()
	await process_frame
	expect(app.screen == "character_event_complete", locale + ": show_character_event_complete renders cleanly")
	expect(app.page.get_node_or_null("CharacterPortrait") != null, locale + ": Maki white_coat/smile portrait shown on completion card")
	if locale == "en":
		for child in app.page.get_children():
			if child is Label:
				expect(han.search(child.text) == null, "en completion card zero CJK: " + child.text)
			elif child is Button:
				expect(han.search(child.text) == null, "en completion button zero CJK: " + child.text)

	# Re-open day_transition and verify standard DayTransitionContinue routing
	app.render_day_transition(app.show_character_event_complete, {"workday": start_day + 1, "clock": 1070})
	await process_frame
	var dt_btn: Button = app.page.get_node_or_null("DayTransitionContinue")
	expect(dt_btn != null, locale + ": DayTransitionContinue button present")
	if locale == "en":
		for child in app.page.get_children():
			if child is Label:
				expect(han.search(child.text) == null, "en day_transition zero CJK: " + child.text)
	if dt_btn != null:
		dt_btn.pressed.emit()
		await process_frame

	if expect_sunday_landing:
		expect(app.screen == "sunday_menu", locale + ": Saturday onboarding cleanly routes to sunday_menu on Sunday morning")
	else:
		expect(app.screen == "map", locale + ": weekday onboarding returns to hospital map on next morning")
	expect(app.game.can_save_progress(), locale + ": safe save boundary restored")

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
	expect(game.character_event_definitions.has(EVENT_ID), "maki_lv0_onboarding registered")

	# 1. Prerequisite & calendar delay checks
	game.reset()
	set_exact_clock(game, 45, 540)
	expect(game.next_day_start_character_event().get("id", "") != EVENT_ID, "blocked before Asuka Lv2 completed")

	# Holiday deferral check: interview_day = 6 (2025-04-06) -> +1 month is Day 36 (2025-05-06 Greenery Day holiday)
	seed_post_asuka_lv2(game, 6, 36, 540)
	expect(game.is_hospital_closed_day(36), "2025-05-06 (day 36) is public holiday")
	expect(game.next_day_start_character_event().get("id", "") != EVENT_ID, "deferred on 2025-05-06 public holiday")
	expect(AsukaLv2.onboarding_ready_workday(game) == 37, "ready workday skips holiday to day 37 (2025-05-07)")
	set_exact_clock(game, 37, 540)
	expect(game.next_day_start_character_event().get("id", "") == EVENT_ID, "triggers on next open workday 2025-05-07 09:00")

	# Standard 1-month delay check: interview_day = 8 (2025-04-08) -> Day 38 (2025-05-08 Thursday)
	seed_post_asuka_lv2(game, 8, 8, 540)
	expect(game.next_day_start_character_event().get("id", "") != EVENT_ID, "blocked on interview day")
	set_exact_clock(game, 37, 540)
	expect(game.next_day_start_character_event().get("id", "") != EVENT_ID, "blocked at interview_day + 29 (day 37)")
	set_exact_clock(game, 38, 540)
	expect(game.next_day_start_character_event().get("id", "") == EVENT_ID, "triggers at 09:00 on day 38 with zero extra stats")

	# Saturday open workday allowed; Sunday blocked
	set_exact_clock(game, 40, 540) # 2025-05-10 Saturday
	expect(not game.is_hospital_closed_day(40), "Saturday day 40 is open")
	expect(game.next_day_start_character_event().get("id", "") == EVENT_ID, "allowed on Saturday morning")
	set_exact_clock(game, 41, 540) # 2025-05-11 Sunday
	expect(game.next_day_start_character_event().get("id", "") != EVENT_ID, "blocked on Sunday")

	# Active clinical / preop deferral check
	seed_post_asuka_lv2(game, 8, 38, 540)
	game.active_preop_id = str(c.preops[0].id)
	expect(game.next_day_start_character_event().get("id", "") != EVENT_ID, "deferred while active_preop_id is non-empty")
	game.active_preop_id = ""
	game.active_id = str(c.encounters[0].id)
	expect(game.next_day_start_character_event().get("id", "") != EVENT_ID, "deferred while outpatient active_id is non-empty")
	game.active_id = ""
	expect(game.next_day_start_character_event().get("id", "") == EVENT_ID, "resumes immediately once clinical/preop state clears")

	# 2. Both Choice D1 branches equivalence + mid-event invariants + atomic unlock
	var outcomes: Array[Dictionary] = []
	for d1 in [0, 1]:
		seed_post_asuka_lv2(game, 8, 38, 540)
		game.relation_for("nurse_hiroko").met = false
		var res := complete_lv0_in_game(game, d1)
		outcomes.append(res)
		expect(not bool(game.relation_for("nurse_hiroko").get("met", false)), "nurse_hiroko met unchanged on branch " + str(d1))
		verify_maki_unlocked(game, c, "branch_" + str(d1))
	expect(outcomes[0] == outcomes[1], "Choice D1 Option A and Option B yield identical settled state")

	# 3. BoundarySave v37 round-trip verification (in-memory only, zero player slots touched)
	var saved_payload: Dictionary = game.snapshot()
	expect(saved_payload.get("save_format") == Codec.FORMAT and int(saved_payload.get("version", 0)) == Codec.VERSION, "BoundarySave v37 format")
	inspect_clean(saved_payload)
	var snap_json := JSON.stringify(saved_payload)
	expect(not snap_json.contains("mk0_0") and not snap_json.contains("mk0_1") and not snap_json.contains("mk0_choice"), "zero internal node IDs in BoundarySave payload")
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
	expect(restored.day_number() == 39 and restored.current_absolute_clock() == 540, "restored settled Day 39 09:00")
	expect(restored.elapsed() == game.elapsed(), "restored settled elapsed minutes unchanged")
	verify_maki_unlocked(restored, c, "after_v37_restore")
	expect(restored.next_day_start_character_event().get("id", "") != EVENT_ID, "completed Lv0 never re-triggers after restore")

	# Verify prepare_character_event_test_save hook
	expect(game.prepare_character_event_test_save(EVENT_ID), "prepare_character_event_test_save succeeds")
	expect(game.next_day_start_character_event().get("id", "") == EVENT_ID, "test save ready for day_start onboarding")

	# 4. Full UI walkthroughs (`zh_CN` weekday + `en` Saturday->Sunday) via main.tscn
	var tmp_save_path := "/private/tmp/maki_lv0_unused_%s.json" % OS.get_process_id()
	var tmp_prefs_path := "/private/tmp/maki_lv0_prefs_%s.cfg" % OS.get_process_id()
	var packed: PackedScene = load("res://godot/scenes/main.tscn")
	app = packed.instantiate()
	app.title_notice_enabled = false
	app.title_preferences_path = tmp_prefs_path
	app.saves.path = tmp_save_path
	root.add_child(app)
	await process_frame
	await process_frame

	await run_ui_walkthrough("zh_CN", 38, 0, false, true)
	await run_ui_walkthrough("en", 40, 1, true, false)

	# Gallery replay check
	app.replay_gallery_entry(EVENT_ID)
	expect(app.screen == "gallery_replay" and app.gallery_replay_event != null, "Gallery Replay starts for Maki Lv0")
	app.show_map(false)
	expect(app.game.can_save_progress(), "safe boundary after Gallery Replay")

	for p in [tmp_save_path, tmp_prefs_path]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

	print("MAKI LV0 TEST: %d checks, %d failure(s)." % [checks, failures])
	quit(1 if failures > 0 else 0)
