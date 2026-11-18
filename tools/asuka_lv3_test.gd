extends SceneTree
## Runtime regression test for Asuka Shiromiya (`doc_asuka`) Relationship Lv3:
## 《本院长不接受反驳哦》 (`asuka_lv3_no_objections`)
##
## Verifies:
## 1. Content & Texture2D loading for all 8 RGBA portraits (`date_cardigan/*`,
##    `vintage_cream_gown/*`), full-screen mirror CG, and 2 dedicated backgrounds.
## 2. Exact gate boundaries: Sunday-only (never weekday `director_office`),
##    `Familiarity 39 vs 40`, `Charm 49 vs 50`, `Lv2`, 3-day milestone cooldown,
##    zero month lock, and independence from `maki_lv0_onboarding` (works both
##    before and after Maki onboards).
## 3. Sunday Invite UI pinning (`sunday_date_candidates(5)` pins `doc_asuka` even
##    when >5 staff are eligible) + direct milestone launch bypassing rejection RNG.
## 4. Automatic Scene A opening variant selection: `A-1` (`al3_a1_001`) with zero
##    prior ordinary Sunday dates vs `A-2` (`al3_a2_001`) with prior ordinary date,
##    both converging cleanly at `al3_012`.
## 5. Save lock (`can_save_progress() == false`), hidden `CalendarHeader`, atomic
##    `@end` settlement (`Lv2 -> Lv3`, `asuka_lv3_complete`, single `"asuka_lv3_date"`
##    Sunday ledger entry, zero double generic-date Familiarity/Charm/counter reward,
##    Monday `09:00` transition), and post-Lv3 fallback to ordinary Sunday dates.
## 6. BoundarySave v37 round-trip (zero inner state, resilient to internal node ID
##    refactoring) and full `zh_CN` (A-1) + `en` (A-2) UI walkthroughs via `main.tscn`.

const EVENT_ID := "asuka_lv3_no_objections"
const LV2_EVENT := "asuka_lv2_right_person_right_gown"
const LV1_PREOP := "asuka_lv1_director_surgeon_preop"
const LV1_POSTOP := "asuka_lv1_director_surgeon_postop"
const INTRO_OFFICE := "intro_doc_asuka_director_office"
const MAKI_LV0 := "maki_lv0_onboarding"

const EXPECTED_TEXTURES := [
	"assets/characters/asuka_lv3_v1/doc_asuka/date_cardigan/smile.png",
	"assets/characters/asuka_lv3_v1/doc_asuka/date_cardigan/playful.png",
	"assets/characters/asuka_lv3_v1/doc_asuka/date_cardigan/nostalgic.png",
	"assets/characters/asuka_lv3_v1/doc_asuka/date_cardigan/laugh.png",
	"assets/characters/asuka_lv3_v1/doc_asuka/date_cardigan/shy.png",
	"assets/characters/asuka_lv3_v1/doc_asuka/vintage_cream_gown/expectant.png",
	"assets/characters/asuka_lv3_v1/doc_asuka/vintage_cream_gown/shy_earnest.png",
	"assets/characters/asuka_lv3_v1/doc_asuka/vintage_cream_gown/blushing_happy.png",
	"assets/events/asuka_lv3_v1/vintage_cream_gown_mirror.png",
	"assets/backgrounds/asuka_lv3_v1/cafe_exterior_day.png",
	"assets/backgrounds/asuka_lv3_v1/hospital_archive_room_afternoon.png",
]

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const AsukaLv3 = preload("res://godot/systems/asuka_lv3.gd")
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
					"active_adult_intimacy", "opening_variant",
				],
				"no inner state at " + path + "." + str(key)
			)
			inspect_clean(value[key], path + "." + str(key))
	elif value is Array:
		for item in value:
			inspect_clean(item, path)

func _initialize() -> void:
	han.compile("[㐀-鿿]")
	call_deferred("run")

func set_exact_clock(game: RefCounted, day: int, clock_min: int) -> void:
	game.set_test_time(day, clock_min)
	var expected_elapsed: int = (day - 1) * int(game.SHIFT_MINUTES) + clock_min - int(game.SHIFT_START_MINUTE)
	game.story_time_advance_minutes += expected_elapsed - int(game.elapsed())

func seed_lv2_ready_state(game: RefCounted, lv2_day: int = 8, current_day: int = 13, clock_min: int = 540, prior_date: bool = false) -> void:
	game.reset()
	game.meet_staff("doc_asuka")
	var rel: Dictionary = game.relation_for("doc_asuka")
	rel.met = true
	rel.level = 2
	rel.familiarity = 40
	game.set_test_player_attribute("charm", 50)
	game._complete_character_event_for_test("asuka_scrub_sink_encounter", 1)
	game._complete_character_event_for_test("asuka_adjacent_operation_reveal", 1)
	game._complete_character_event_for_test(INTRO_OFFICE, 2)
	game._complete_character_event_for_test(LV1_PREOP, 3)
	game._complete_character_event_for_test(LV1_POSTOP, 3)
	game._complete_character_event_for_test(LV2_EVENT, lv2_day)
	for rk in [LV1_POSTOP, LV2_EVENT]:
		if not rel.rank_history.has(rk):
			rel.rank_history.append(rk)
	game.set_story_flag("asuka_lv1_complete", true)
	game.set_story_flag("asuka_lv2_complete", true)
	game.set_story_flag("maki_aizawa_offer_accepted", true)
	if prior_date:
		game.sunday_history.append({
			"day": 6,
			"activity_id": "date",
			"actor_id": "doc_asuka",
			"location_id": "aquarium",
		})
		game.increment_character_progress_counter("doc_asuka", "completed_sunday_dates")
	set_exact_clock(game, current_day, clock_min)

func run_ui_walkthrough(locale: String, prior_date: bool) -> void:
	app.content.load_all(locale)
	app.configure_game_content()
	seed_lv2_ready_state(app.game, 8, 13, 540, prior_date) # 2025-04-13 Sunday 09:00

	# Populate >5 other date-eligible staff to verify Sunday candidate pinning
	var extra_staff := ["doc_aoi", "doc_sayaka", "doc_emiko", "doc_rei", "nurse_haru", "nurse_hiroko", "nurse_shiori"]
	for sid in extra_staff:
		if app.game.relationships.has(sid):
			app.game.meet_staff(sid)
			var srel: Dictionary = app.game.relation_for(sid)
			srel.met = true
			srel.level = 2
			srel.familiarity = 50

	var cands: Array[String] = app.game.sunday_date_candidates(5)
	expect(cands.has("doc_asuka"), locale + ": doc_asuka pinned into Sunday top-5 candidates despite >5 eligible staff")

	app.show_sunday_menu()
	await process_frame
	expect(app.screen == "sunday_menu", locale + ": rendered sunday_menu")
	expect(app.game.can_save_progress(), locale + ": Sunday menu is a saveable safe boundary")

	app.show_sunday_invites()
	await process_frame
	expect(app.screen == "sunday_invites", locale + ": rendered sunday_invites")
	var invite_btn := app.page.get_node_or_null("SundayCandidate_doc_asuka") as Button
	expect(invite_btn != null, locale + ": SundayCandidate_doc_asuka button rendered")
	if invite_btn != null:
		expect(invite_btn.get_child_count() > 0, locale + ": story badge attached to SundayCandidate_doc_asuka")

	var fam_before := int(app.game.relation_for("doc_asuka").familiarity)
	var charm_before := int(app.game.player_attributes().get("charm", 0))
	var dates_before := int(app.game.character_progress_counter("doc_asuka", "completed_sunday_dates"))

	app.attempt_sunday_invitation("doc_asuka")
	await process_frame
	expect(app.game.active_character_event_id == EVENT_ID, locale + ": inviting doc_asuka launches Lv3 milestone directly")
	var ev = app.game.character_events[EVENT_ID]
	var expected_open := "al3_a2_001" if prior_date else "al3_a1_001"
	expect(str(ev.current().get("id", "")) == expected_open, locale + ": started at expected opening node " + expected_open)
	expect(not app.game.can_save_progress(), locale + ": save locked immediately upon starting Lv3")
	var cal_hdr := app.page.get_node_or_null("CalendarHeader") as CanvasItem
	expect(cal_hdr == null or not cal_hdr.visible, locale + ": CalendarHeader hidden during Lv3")

	var guard := 0
	var seen_merge := false
	var seen_cg := false
	var seen_vintage_sprite := false
	var seen_cardigan_sprite := false

	while app.game.active_character_event_id == EVENT_ID and guard < 400:
		guard += 1
		if ev.completed:
			break
		expect(not app.game.can_save_progress(), locale + ": save remains locked throughout playback")
		expect(app.game.relationship_level("doc_asuka") == 2, locale + ": level remains 2 before @end")
		expect(not app.game.sunday_activity_done(13), locale + ": Sunday not consumed before @end")

		if app.page.get_node_or_null("EventDialogueContinue") != null:
			if locale == "en":
				var cont_btn := app.page.get_node_or_null("EventDialogueContinue") as Button
				if cont_btn != null:
					expect(han.search(cont_btn.text) == null, "en continue page button zero CJK")
			app.advance_dialogue_page(app.show_character_event)
			await process_frame
			continue

		var node: Dictionary = ev.current()
		var nid := str(node.get("id", ""))
		if nid == "al3_012":
			seen_merge = true
		if app.page.get_node_or_null("CharacterEventCG") != null:
			seen_cg = true
		if app.page.get_node_or_null("EventPortrait_doc_asuka") != null:
			for p in node.get("event_portraits", []):
				var ppath := str(p.get("path", ""))
				if "vintage_cream_gown/" in ppath:
					seen_vintage_sprite = true
				elif "date_cardigan/" in ppath:
					seen_cardigan_sprite = true

		if locale == "en":
			var dlg: Node = app.page.get_node_or_null("CharacterEventDialogue")
			if dlg != null:
				for child in dlg.get_children():
					if child is Label:
						expect(han.search(child.text) == null, "en dialogue zero CJK at " + nid + ": " + child.text)

		var cid := str(node.choices[0].id)
		var btn := app.page.get_node_or_null("EventChoice_" + cid) as Button
		expect(btn != null, locale + ": choice button exists for " + cid)
		if locale == "en" and btn != null:
			expect(han.search(btn.text) == null, "en choice button zero CJK at " + nid)
		app.choose_character_event(cid)
		await process_frame

	expect(seen_merge, locale + ": reached merge node al3_012")
	expect(seen_cardigan_sprite, locale + ": rendered date_cardigan standing sprites")
	expect(seen_cg, locale + ": rendered full-screen CharacterEventCG in Scene F")
	expect(seen_vintage_sprite, locale + ": rendered vintage_cream_gown standing sprites in Scene F")
	expect(app.screen == "sunday_complete", locale + ": transitioned to sunday_complete screen")
	if locale == "en":
		for child in app.page.get_children():
			if child is Label:
				expect(han.search(child.text) == null, "en sunday_complete label zero CJK: " + child.text)
			elif child is Button:
				expect(han.search(child.text) == null, "en sunday_complete button zero CJK: " + child.text)

	expect(app.game.character_event_done(EVENT_ID), locale + ": Lv3 marked completed")
	expect(app.game.relationship_level("doc_asuka") == 3, locale + ": Asuka promoted to Lv3")
	expect(app.game.story_flag("asuka_lv3_complete"), locale + ": story_flag asuka_lv3_complete set")
	expect(app.game.sunday_activity_done(13), locale + ": Day 13 Sunday consumed")
	expect(int(app.game.relation_for("doc_asuka").familiarity) == fam_before, locale + ": zero double Familiarity reward")
	expect(int(app.game.player_attributes().get("charm", 0)) == charm_before, locale + ": zero double Charm +1 reward")
	expect(int(app.game.character_progress_counter("doc_asuka", "completed_sunday_dates")) == dates_before, locale + ": completed_sunday_dates not incremented by milestone")
	expect(app.game.day_number() == 14 and int(app.game.display_schedule().absolute_clock) == 540, locale + ": settled cleanly at Monday 09:00 (Day 14)")

	app.show_map(false)
	await process_frame
	expect(app.screen == "map" and app.game.can_save_progress(), locale + ": Monday 09:00 hospital map is saveable boundary")

func run() -> void:
	for p in EXPECTED_TEXTURES:
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
	expect(game.character_event_definitions.has(EVENT_ID), "Lv3 definition registered")

	# 1. Gate checks
	seed_lv2_ready_state(game, 8, 13, 540, false) # 2025-04-13 Sunday
	expect(game.is_sunday(), "Day 13 (2025-04-13) is Sunday")
	expect(game.sunday_character_event_for("doc_asuka").get("id", "") == EVENT_ID, "Sunday milestone ready on Day 13")
	expect(game.next_character_event_at("director_office").get("id", "") != EVENT_ID, "Never offered as location event at director_office on Sunday")

	# Weekday check: never offered on weekdays
	set_exact_clock(game, 14, 815) # Monday 13:35
	expect(not game.is_sunday(), "Day 14 is Monday")
	expect(game.sunday_character_event_for("doc_asuka").is_empty(), "Not offered via Sunday invite on Monday")
	expect(game.next_character_event_at("director_office").get("id", "") != EVENT_ID, "Never offered at weekday director_office")

	# Familiarity & Charm boundaries
	seed_lv2_ready_state(game, 8, 13, 540, false)
	game.relation_for("doc_asuka").familiarity = 39
	expect(game.sunday_character_event_for("doc_asuka").is_empty(), "Blocked at Familiarity 39")
	game.relation_for("doc_asuka").familiarity = 40
	game.set_test_player_attribute("charm", 49)
	expect(game.sunday_character_event_for("doc_asuka").is_empty(), "Blocked at Charm 49")
	game.set_test_player_attribute("charm", 50)
	expect(game.sunday_character_event_for("doc_asuka").get("id", "") == EVENT_ID, "Allowed at Familiarity 40 & Charm 50")

	# 3-day milestone cooldown check (Lv2 on Friday Day 11 -> Sunday Day 13 is +2 days -> blocked; Sunday Day 20 is +9 days -> allowed)
	seed_lv2_ready_state(game, 11, 13, 540, false)
	expect(game.sunday_character_event_for("doc_asuka").is_empty(), "Blocked at +2 days cooldown after Lv2")
	set_exact_clock(game, 20, 540) # Next Sunday (2025-04-20)
	expect(game.sunday_character_event_for("doc_asuka").get("id", "") == EVENT_ID, "Allowed on next Sunday once >=3 days cooldown met")

	# Zero month lock (April, August, December Sundays)
	for iso in ["2025-04-20", "2025-08-17", "2025-12-14"]:
		var sday := Calendar.day_for_iso(iso)
		set_exact_clock(game, sday, 540)
		expect(game.is_sunday() and game.sunday_character_event_for("doc_asuka").get("id", "") == EVENT_ID, "Zero month lock on " + iso)

	# Independence from maki_lv0_onboarding (both unmet before onboarding and met after onboarding)
	seed_lv2_ready_state(game, 8, 13, 540, false)
	expect(not game.staff_is_met("doc_maki") and not game.character_event_done(MAKI_LV0), "Maki not yet onboarded on Day 13")
	expect(game.sunday_character_event_for("doc_asuka").get("id", "") == EVENT_ID, "Asuka Lv3 allowed BEFORE Maki onboarding")
	game._complete_character_event_for_test(MAKI_LV0, 38)
	game.set_story_flag("maki_lv0_complete", true)
	game.set_story_flag("maki_aizawa_onboarded", true)
	game.meet_staff("doc_maki")
	var aug_sun := Calendar.day_for_iso("2025-05-11")
	set_exact_clock(game, aug_sun, 540)
	expect(game.staff_is_met("doc_maki"), "Maki onboarded by 2025-05-11")
	expect(game.sunday_character_event_for("doc_asuka").get("id", "") == EVENT_ID, "Asuka Lv3 allowed AFTER Maki onboarding")

	# prepare_character_event_test_save check
	expect(game.prepare_character_event_test_save(EVENT_ID), "prepare_character_event_test_save succeeds")
	expect(game.is_sunday() and game.sunday_character_event_for("doc_asuka").get("id", "") == EVENT_ID, "prepare_character_event_test_save lands on eligible Sunday")

	# 2. Full UI walkthroughs (`zh_CN` A-1 first Sunday date + `en` A-2 prior Sunday date)
	var pid := OS.get_process_id()
	var tmp_save_path := "/private/tmp/asuka_lv3_unused_%s.json" % pid
	var packed: PackedScene = load("res://godot/scenes/main.tscn")
	app = packed.instantiate()
	app.saves.path = tmp_save_path
	root.add_child(app)
	await process_frame
	await process_frame

	await run_ui_walkthrough("zh_CN", false) # Exercises A-1 (`al3_a1_001`)

	# 3. Post-Lv3 subsequent Sunday fallback to ordinary date + BoundarySave v37 check
	var saved_payload: Dictionary = app.game.snapshot()
	expect(saved_payload.get("save_format") == Codec.FORMAT and int(saved_payload.get("version", 0)) == Codec.VERSION, "BoundarySave v37 format")
	inspect_clean(saved_payload)
	var snap_json := JSON.stringify(saved_payload)
	expect(not snap_json.contains("al3_a1") and not snap_json.contains("al3_a2") and not snap_json.contains("al3_0") and not snap_json.contains("al3_1"), "Zero internal node IDs in BoundarySave payload")

	# Verify refactor resilience: even if internal node IDs in character_event_definitions change, restore succeeds
	var restored = Game.new()
	restored.configure(
		c.encounters, c.preops, c.staff, c.time_events, c.surgeries, c.patients,
		c.relationships, c.character_events, c.case_templates, c.micro_events,
		c.examination_cg_pools, c.surgery_team_dialogue_profiles, c.patient_interactions,
		c.temporary_conditions, c.staff_role_cg_rewards, c.special_events,
		c.special_event_steps, c.date_profiles, c.date_locations, c.advanced_referral_cases,
		c.first_surgery_diagnosis_reactions, c.palpation_profiles, c.awake_special_barks
	)
	restored.character_event_definitions[EVENT_ID].start = "al3_refactored_start"
	expect(restored.restore(saved_payload), "BoundarySave v37 restores cleanly even after internal start node refactor")
	expect(restored.relationship_level("doc_asuka") == 3, "Restored Asuka Lv3")
	expect(restored.character_event_done(EVENT_ID), "Restored character_event_done(asuka_lv3_no_objections)")
	expect(restored.story_flag("asuka_lv3_complete"), "Restored story_flag asuka_lv3_complete")
	expect(restored.elapsed() == app.game.elapsed(), "Restored settled elapsed minutes unchanged")
	expect(int(restored.relation_for("doc_asuka").familiarity) == 40, "Restored Familiarity 40 unchanged")

	# Check subsequent Sunday ordinary date fallback on app.game
	set_exact_clock(app.game, 20, 540) # Next Sunday 2025-04-20
	expect(app.game.sunday_character_event_for("doc_asuka").is_empty(), "No duplicate Lv3 milestone on subsequent Sunday")
	app.game.date_profile_definitions["doc_asuka"].always_accept = true
	app.attempt_sunday_invitation("doc_asuka")
	await process_frame
	expect(app.screen == "sunday_date", "Subsequent Sunday invite falls back cleanly to ordinary Sunday date acceptance")

	# Gallery replay check before switching to English
	app.show_map(false)
	await process_frame
	app.replay_gallery_entry(EVENT_ID)
	await process_frame
	expect(app.screen == "gallery_replay" and app.gallery_replay_event != null, "Gallery replay starts cleanly for Asuka Lv3")
	app.show_map(false)
	await process_frame

	# Run full English UI walkthrough via A-2 (`al3_a2_001`)
	await run_ui_walkthrough("en", true)

	if FileAccess.file_exists(tmp_save_path):
		DirAccess.remove_absolute(tmp_save_path)

	print("ASUKA LV3 TEST: %d checks, %d failure(s)." % [checks, failures])
	quit(1 if failures > 0 else 0)
