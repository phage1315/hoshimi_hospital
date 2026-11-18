extends SceneTree
## Focused regression suite for Mido Emiko (`doc_emiko`) early Relationship Gates
## (Lv1 Surgery >= 75, Lv2 Surgery >= 80, zero Familiarity gates on Lv1/Lv2),
## fixed unscaled Familiarity +10 milestone rewards, Lv2 surgical team unlock
## across ordinary and advanced surgery, scripted cameo preservation, and
## BoundarySave v37 / legacy save compatibility.

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Store = preload("res://godot/systems/save_store.gd")
const Referral = preload("res://godot/systems/advanced_referral.gd")
const AdvancedModel = preload("res://godot/systems/advanced_surgery_model.gd")

const INTRO := "emiko_intro_rumored_hands"
const LV1 := "emiko_lv1_first_operation"
const LV2 := "emiko_lv2_follow_my_lead"

var checks := 0
var failures := 0
var content = Loader.new()

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func new_game() -> RefCounted:
	var g = Game.new()
	g.configure(
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
		content.collections.advanced_referral_cases,
		content.collections.first_surgery_diagnosis_reactions,
		content.collections.palpation_profiles,
		content.collections.awake_special_barks
	)
	return g

func play_event(g: RefCounted, id: String, preferred_choices: Array = []) -> bool:
	var event = g.start_character_event(id)
	if event == null:
		return false
	var guard := 0
	while not event.completed and guard < 350:
		guard += 1
		var choices: Array = event.current().choices
		var chosen := str(choices[0].id)
		for want in preferred_choices:
			for c in choices:
				if str(c.id) == str(want):
					chosen = str(c.id)
					break
		if not g.choose_character_event(chosen):
			return false
	var done: bool = event.completed
	g.finish_character_event()
	return done

func setup_post_intro_game(day: int = 10) -> RefCounted:
	var g := new_game()
	g.set_test_time(day, 600)
	g._complete_character_event_for_test("intro_doc_asuka_director_office", 1)
	g.meet_staff("doc_asuka")
	g.set_test_player_attribute("skill", 70)
	expect(play_event(g, INTRO), "Lv0 intro plays to completion at Surgery 70")
	expect(g.staff_is_met("doc_emiko") and g.relationship_level("doc_emiko") == 0, "Lv0 intro sets met=true and level=0")
	expect(int(g.relation_for("doc_emiko").familiarity) == 0, "Lv0 choice without familiarity leaves familiarity at 0")
	return g

func setup_advanced_eligible(g: RefCounted) -> RefCounted:
	g.surgery_xp = g.surgery_xp_for_level(88)
	g.archived_player_effects.reputation = 300
	g.special_event_completion_counts["advanced_referral_tutorial_chisato"] = 1
	g.special_event_completion_days["advanced_referral_tutorial_chisato"] = 1
	g.set_story_flag("advanced_referral_random_cases_enabled", true)
	for person in g.staff:
		var sid := str(person.id)
		if sid not in ["doc_emiko", "doc_serika"]:
			g.meet_staff(sid)
			if "team_unlock_requires_lv1" in person.get("flags", []):
				g.relation_for(sid).level = 1
	return Referral.new(g)

func finish_advanced_session(s: RefCounted) -> void:
	s.finished = true
	s.success = true
	s.physiology.procedure_state.elapsed_time = 480

func test_gates_and_fixed_familiarity(locale: String) -> void:
	# 1. Surgery 74 + high Familiarity (80): Lv1 CANNOT trigger.
	var g := setup_post_intro_game(10)
	g.advance_story_to_day(13, 780)
	g.relation_for("doc_emiko").familiarity = 80
	g.set_test_player_attribute("skill", 74)
	var lv1_def: Dictionary = g.character_event_definitions[LV1]
	var lv2_def: Dictionary = g.character_event_definitions[LV2]
	expect(not g.relationship_rank_gate_met("doc_emiko", 1), locale + " [1]: rank_slot Lv1 blocks Surgery 74 even with Familiarity 80")
	expect(not g.character_event_available(lv1_def), locale + " [1]: emiko_lv1_first_operation unavailable at Surgery 74 + Familiarity 80")
	expect(g.start_character_event(LV1) == null, locale + " [1]: start_character_event(Lv1) rejected at Surgery 74")

	# 2. Surgery 75 + Familiarity 0: Lv1 CAN trigger (after 3-day cooldown; 2-day gap still blocked).
	g.relation_for("doc_emiko").familiarity = 0
	g.set_test_player_attribute("skill", 75)
	var g_early := setup_post_intro_game(10)
	g_early.advance_story_to_day(12, 780)
	g_early.set_test_player_attribute("skill", 75)
	expect(not g_early.character_event_available(g_early.character_event_definitions[LV1]), locale + " [2]: Lv1 retains 3-day post-intro cooldown on day +2")
	expect(g.relationship_rank_gate_met("doc_emiko", 1), locale + " [2]: rank_slot Lv1 passes at Surgery 75 + Familiarity 0")
	expect(g.character_event_available(lv1_def), locale + " [2]: emiko_lv1_first_operation triggers at Surgery 75 + Familiarity 0")

	# 3. Lv1 completion grants fixed Familiarity +10 across ALL choice branches (unscaled by 0.5x multiplier!).
	expect(is_equal_approx(g.familiarity_gain_multiplier("doc_emiko"), 0.7), locale + " [3]: Emiko daily multiplier at Surgery 75 / Presence 0 is 0.50 + 0.20 = 0.70")
	expect(play_event(g, LV1, ["choice_em1_b1_a", "choice_em1_c1_a", "choice_em1_e1_a"]), locale + " [3]: Lv1 branch A completes")
	expect(g.relationship_level("doc_emiko") == 1, locale + " [3]: Lv1 sets relationship level = 1")
	expect(int(g.relation_for("doc_emiko").familiarity) == 10, locale + " [3]: Lv1 branch A grants exact fixed +10 Familiarity (got %d)" % int(g.relation_for("doc_emiko").familiarity))
	expect(not g.relation_for("doc_emiko").unlocked_benefits.has("unlock_emiko_surgical_team"), locale + " [3]: Lv1 does NOT grant unlock_emiko_surgical_team")

	# Verify quiet branch B of Lv1 also grants exact +10 even if player skill/presence yield 0.50x multiplier:
	var g_lv1_b := setup_post_intro_game(10)
	g_lv1_b.advance_story_to_day(13, 780)
	g_lv1_b.set_test_player_attribute("skill", 75)
	g_lv1_b.set_test_player_attribute("presence", -20)
	expect(play_event(g_lv1_b, LV1, ["choice_em1_b1_b", "choice_em1_c1_b", "choice_em1_e1_b"]), locale + " [3b]: Lv1 branch B completes")
	expect(int(g_lv1_b.relation_for("doc_emiko").familiarity) == 10, locale + " [3b]: Lv1 branch B also grants exact fixed +10 Familiarity")

	# Verify abandoning Lv1 mid-scene before @end grants 0 Familiarity:
	var g_mid := setup_post_intro_game(10)
	g_mid.advance_story_to_day(13, 780)
	g_mid.set_test_player_attribute("skill", 75)
	var mid_ev = g_mid.start_character_event(LV1)
	expect(mid_ev != null and g_mid.choose_character_event("continue_em1_001") and g_mid.choose_character_event("continue_em1_002"), locale + " [3c]: mid-event choices advance")
	expect(int(g_mid.relation_for("doc_emiko").familiarity) == 0, locale + " [3c]: mid-event choices grant 0 Familiarity before completion")

	# 4. Lv1 done + Surgery 79 (even after 3-day cooldown & high Familiarity): Lv2 CANNOT trigger.
	g.advance_story_to_day(16, 780)
	g.relation_for("doc_emiko").familiarity = 60
	g.set_test_player_attribute("skill", 79)
	expect(not g.relationship_rank_gate_met("doc_emiko", 2), locale + " [4]: rank_slot Lv2 blocks Surgery 79")
	expect(not g.character_event_available(lv2_def), locale + " [4]: emiko_lv2_follow_my_lead unavailable at Surgery 79")
	expect(g.start_character_event(LV2) == null, locale + " [4]: start_character_event(Lv2) rejected at Surgery 79")

	# 5. Lv1 done + Surgery 80 + 3-day cooldown + Familiarity < 25 (10 and 0): Lv2 CAN trigger (2-day gap blocked).
	g.relation_for("doc_emiko").familiarity = 10
	g.set_test_player_attribute("skill", 80)
	g.set_test_time(15, 780)
	expect(not g.character_event_available(lv2_def), locale + " [5]: Lv2 blocks 2-day gap (day 13 -> day 15)")
	g.set_test_time(16, 780)
	expect(g.relationship_rank_gate_met("doc_emiko", 2), locale + " [5]: rank_slot Lv2 passes at Surgery 80 + Familiarity 10")
	expect(g.character_event_available(lv2_def), locale + " [5]: Lv2 available at Surgery 80 + Familiarity 10 (< 25)")
	g.relation_for("doc_emiko").familiarity = 0
	expect(g.character_event_available(lv2_def), locale + " [5]: Lv2 also available at Familiarity 0")
	g.relation_for("doc_emiko").familiarity = 10

	# 7 (part A): Before Lv2 completes (at Lv0 and Lv1), player CANNOT actively assign Emiko in ordinary or advanced surgery.
	var visit = g.open_visit("visit_sora")
	visit.admitted = true
	var prep = g.open_preop("preop_sora")
	prep.stage_id = "team"
	expect(not g.staff_can_join_surgery_team("doc_emiko"), locale + " [7]: staff_can_join_surgery_team(doc_emiko) is false at Lv1")
	expect(prep.candidates("assistant_surgeon").all(func(p): return str(p.id) != "doc_emiko"), locale + " [7]: ordinary assistant_surgeon excludes Emiko before Lv2")
	expect(not prep.apply({"kind": "assign", "role": "assistant_surgeon", "staff_id": "doc_emiko"}), locale + " [7]: ordinary assign rejects Emiko before Lv2")
	g.active_preop_id = ""

	var g_adv_pre := setup_post_intro_game(10)
	g_adv_pre.advance_story_to_day(13, 540)
	g_adv_pre.set_test_player_attribute("skill", 75)
	expect(play_event(g_adv_pre, LV1), locale + " [7]: Lv1 completes in advanced-check fixture")
	g_adv_pre.advance_story_to_day(15, 540) # Monday 09:00
	var adv_pre := setup_advanced_eligible(g_adv_pre)
	expect(adv_pre.candidates("first_assistant", 16).all(func(p): return str(p.id) != "doc_emiko"), locale + " [7]: advanced first_assistant excludes Emiko at Lv1")
	expect(adv_pre.candidates("second_assistant", 16).all(func(p): return str(p.id) != "doc_emiko"), locale + " [7]: advanced second_assistant excludes Emiko at Lv1")
	var invalid_team := {
		"first_assistant": "doc_emiko",
		"second_assistant": "doc_aoi",
		"primary_scrub": "nurse_ange",
		"secondary_scrub": "nurse_yui",
		"primary_circulating": "nurse_hiroko",
		"secondary_circulating": "nurse_haru",
		"anesthesia": "doc_sakura_anesthesiology",
	}
	expect(not adv_pre.valid_team(invalid_team, 16), locale + " [7]: advanced valid_team rejects Emiko before Lv2")
	expect(not adv_pre.accept(adv_pre.board()[0], invalid_team) and adv_pre.error == "team", locale + " [7]: advanced accept rejects Emiko before Lv2")

	# 6. Complete Lv2 -> Familiarity +10 (10 -> 20), unlock_emiko_surgical_team granted, Emiko enters ordinary & advanced surgery candidates!
	expect(play_event(g, LV2, ["choice_em2_b1_b", "choice_em2_d2_b", "choice_em2_f3_a"]), locale + " [6]: Lv2 completes")
	expect(g.relationship_level("doc_emiko") == 2, locale + " [6]: Lv2 sets relationship level = 2")
	expect(int(g.relation_for("doc_emiko").familiarity) == 20, locale + " [6]: Lv2 grants exact fixed +10 Familiarity (10 -> 20, got %d)" % int(g.relation_for("doc_emiko").familiarity))
	expect(g.relation_for("doc_emiko").unlocked_benefits.has("unlock_emiko_surgical_team"), locale + " [6]: Lv2 grants unlock_emiko_surgical_team")
	expect(g.staff_can_join_surgery_team("doc_emiko"), locale + " [6]: staff_can_join_surgery_team(doc_emiko) is true after Lv2")

	prep.set_known_staff(g.known_staff_ids(), true)
	prep.stage_id = "team"
	expect(prep.candidates("assistant_surgeon").any(func(p): return str(p.id) == "doc_emiko"), locale + " [6]: ordinary assistant_surgeon includes Emiko after Lv2")
	expect(prep.apply({"kind": "assign", "role": "assistant_surgeon", "staff_id": "doc_emiko"}), locale + " [6]: ordinary assign accepts Emiko after Lv2")

	# Ordinary surgery cooperation reward after Lv2 remains normal (scaled by Emiko's familiarity multiplier, unchanged):
	g.set_test_player_attribute("skill", 50)
	g.set_test_player_attribute("presence", 0)
	expect(is_equal_approx(g.familiarity_gain_multiplier("doc_emiko"), 0.5), locale + " [6]: Emiko base daily Familiarity multiplier remains 0.50")
	expect(g.surgery_familiarity_reward("doc_emiko") == 3, locale + " [6]: ordinary surgery reward remains round(5 * 0.50) = 3")

	g_adv_pre.advance_story_to_day(16, 780)
	g_adv_pre.set_test_player_attribute("skill", 80)
	expect(play_event(g_adv_pre, LV2), locale + " [6]: Lv2 completes in advanced-check fixture")
	g_adv_pre.advance_story_to_day(22, 540) # Monday 09:00
	var adv_post := Referral.new(g_adv_pre)
	expect(adv_post.candidates("first_assistant", 23).any(func(p): return str(p.id) == "doc_emiko"), locale + " [6]: advanced first_assistant includes Emiko after Lv2")
	expect(adv_post.candidates("second_assistant", 23).any(func(p): return str(p.id) == "doc_emiko"), locale + " [6]: advanced second_assistant includes Emiko after Lv2")
	expect(adv_post.valid_team(invalid_team, 23), locale + " [6]: advanced valid_team accepts Emiko after Lv2")

	# 10. Lv3–Lv5 Gates remain intact (Lv3: Artoria met + Familiarity >= 40 + Clinical Presence >= +20; Lv4: 55 / +30; Lv5: 75 / Surgery >= 90).
	g.advance_story_to_day(25, 600)
	g.relation_for("doc_emiko").familiarity = 40
	g.set_test_player_attribute("presence", 20)
	expect(not g.relationship_rank_gate_met("doc_emiko", 3), locale + " [10]: Lv3 rejects when Artoria is not yet met")
	g.meet_staff("doc_artoria")
	g.relation_for("doc_emiko").familiarity = 39
	g.set_test_player_attribute("presence", 25)
	expect(not g.relationship_rank_gate_met("doc_emiko", 3), locale + " [10]: Lv3 rejects Familiarity 39")
	g.relation_for("doc_emiko").familiarity = 40
	g.set_test_player_attribute("presence", 19)
	expect(not g.relationship_rank_gate_met("doc_emiko", 3), locale + " [10]: Lv3 rejects Clinical Presence +19")
	g.set_test_player_attribute("presence", 20)
	expect(g.relationship_rank_gate_met("doc_emiko", 3), locale + " [10]: Lv3 accepts Artoria met + Familiarity 40 + Clinical Presence +20")

	var slot4: Dictionary = g.relationship_rank_slot("doc_emiko", 4)
	var slot5: Dictionary = g.relationship_rank_slot("doc_emiko", 5)
	var req4: Array = slot4.get("special_requirements", [])
	var req5: Array = slot5.get("special_requirements", [])
	expect(int(slot4.get("min_familiarity", -1)) == 55 and req4.size() == 1 and str(req4[0].get("attribute", "")) == "presence" and int(req4[0].get("minimum", 0)) == 30, locale + " [10]: Lv4 slot preserves Familiarity 55 + Presence +30")
	expect(int(slot5.get("min_familiarity", -1)) == 75 and req5.size() == 1 and str(req5[0].get("attribute", "")) == "skill" and int(req5[0].get("minimum", 0)) == 90, locale + " [10]: Lv5 slot preserves Familiarity 75 + Surgery 90")

func test_scripted_appearances_unaffected(locale: String) -> void:
	# 8a. Artoria referral & introduction after Emiko Lv0 (before Lv2):
	var g := setup_post_intro_game(10)
	expect("doc_emiko" in g.staff_present_at("emiko_office"), locale + " [8]: Emiko remains present at emiko_office before Lv2")
	expect(play_event(g, "asuka_mentions_artoria_rival"), locale + " [8]: Asuka Artoria-referral event runs normally before Emiko Lv2")
	expect(play_event(g, "intro_doc_artoria_deputy_office"), locale + " [8]: Artoria deputy-office introduction runs normally before Emiko Lv2")
	expect(g.staff_is_met("doc_artoria"), locale + " [8]: Artoria is met without requiring Emiko Lv2")

	# 8b. Asuka Lv2 interview (`asuka_lv2_right_person_right_gown`) features Emiko normally even when Emiko is unmet or pre-Lv2:
	var g_asuka := new_game()
	g_asuka.set_test_time(8, 815)
	g_asuka.meet_staff("doc_asuka")
	g_asuka.relation_for("doc_asuka").level = 1
	g_asuka.relation_for("doc_asuka").familiarity = 25
	g_asuka.relation_for("doc_asuka").rank_history = ["asuka_lv1_director_surgeon_postop"]
	g_asuka._complete_character_event_for_test("asuka_scrub_sink_encounter", 1)
	g_asuka._complete_character_event_for_test("asuka_adjacent_operation_reveal", 1)
	g_asuka._complete_character_event_for_test("intro_doc_asuka_director_office", 2)
	g_asuka._complete_character_event_for_test("asuka_lv1_director_surgeon_preop", 3)
	g_asuka._complete_character_event_for_test("asuka_lv1_director_surgeon_postop", 3)
	g_asuka.set_story_flag("asuka_lv1_complete", true)
	g_asuka.set_test_player_attribute("charm", 40)
	var asuka_lv2_def: Dictionary = g_asuka.character_event_definitions["asuka_lv2_right_person_right_gown"]
	expect(g_asuka.character_event_available(asuka_lv2_def), locale + " [8]: Asuka Lv2 available while Emiko is pre-Lv2")
	var asuka_ev = g_asuka.start_character_event("asuka_lv2_right_person_right_gown")
	expect(asuka_ev != null, locale + " [8]: Asuka Lv2 starts cleanly")
	var saw_emiko_cast := false
	if asuka_ev != null:
		for n in asuka_ev.definition.get("nodes", []):
			if str(n.get("actor_id", "")) == "doc_emiko":
				saw_emiko_cast = true
				break
	expect(saw_emiko_cast and not g_asuka.staff_can_join_surgery_team("doc_emiko"), locale + " [8]: Emiko participates in Asuka Lv2 conference while team-gated")
	g_asuka.finish_character_event()

func test_save_load_replay_and_legacy_compatibility(app) -> void:
	var locale := str(app.content.localizer.locale)
	# UI V1.2 check: Lv0 no longer force-schedules Lv1 via auto_follow_up at Surgery 70 OR Surgery 75;
	# Lv1 unlocks cleanly at OR after the 3-day cooldown + Surgery >= 75.
	app.game.reset()
	app.game.set_test_time(10, 600)
	app.game._complete_character_event_for_test("intro_doc_asuka_director_office", 1)
	app.game.meet_staff("doc_asuka")
	app.game.set_test_player_attribute("skill", 70)
	var intro_ev = app.game.start_character_event(INTRO)
	expect(intro_ev != null, locale + " [UI]: start Lv0 at Surgery 70")
	app.show_character_event()
	var step_guard := 0
	while app.game.character_events.has(app.game.active_character_event_id) and not app.game.character_events[app.game.active_character_event_id].completed and step_guard < 80:
		step_guard += 1
		if bool(app.dialogue_page("character:%s:%s" % [INTRO, str(app.game.character_events[app.game.active_character_event_id].current().id)], str(app.game.character_events[app.game.active_character_event_id].current().text), false, true).has_more):
			app.advance_dialogue_page(app.show_character_event)
		else:
			app.choose_character_event(str(app.game.character_events[app.game.active_character_event_id].current().choices[0].id))
	app.game.finish_character_event()
	expect(app.game.day_number() == 10 and app.game.active_character_event_id == "", locale + " [UI]: completing Lv0 V1.2 at Surgery 70 stays on Day 10 without auto_follow_up")

	app.game.reset()
	app.game.set_test_time(10, 600)
	app.game._complete_character_event_for_test("intro_doc_asuka_director_office", 1)
	app.game.meet_staff("doc_asuka")
	app.game.set_test_player_attribute("skill", 75)
	expect(play_event(app.game, INTRO), locale + " [UI]: Lv0 V1.2 completes at Surgery 75 without forced day jump")
	expect(app.game.day_number() == 10, locale + " [UI]: Lv0 V1.2 at Surgery 75 does not force-advance to next day")
	app.game.advance_story_to_day(13, 780)
	expect(app.game.start_character_event(LV1) != null, locale + " [UI]: start Lv1 on day +3 at Surgery 75")
	app.show_character_event()
	var lv1_guard := 0
	while app.game.character_events.has(app.game.active_character_event_id) and not app.game.character_events[app.game.active_character_event_id].completed and lv1_guard < 350:
		lv1_guard += 1
		var cur_lv1: Dictionary = app.game.character_events[app.game.active_character_event_id].current()
		if str(cur_lv1.get("presentation", "")) != "choice" and bool(app.dialogue_page("character:%s:%s" % [LV1, str(cur_lv1.id)], str(cur_lv1.text), false, true).has_more):
			app.advance_dialogue_page(app.show_character_event)
		else:
			app.choose_character_event(str(cur_lv1.choices[0].id))
	app.game.finish_character_event()
	expect(int(app.game.relation_for("doc_emiko").familiarity) == 10, locale + " [UI]: UI Lv1 completion grants exact +10 Familiarity")

	# 9. BoundarySave save/load, repeated availability/start checks, and Gallery replay NEVER duplicate Familiarity +10:
	app.game.advance_story_to_day(16, 780)
	app.game.set_test_player_attribute("skill", 80)
	expect(play_event(app.game, LV2), locale + " [9]: Lv2 completes on app.game")
	expect(int(app.game.relation_for("doc_emiko").familiarity) == 20, locale + " [9]: Familiarity is 20 after Lv1 + Lv2")

	# Gallery replay of Lv1 and Lv2:
	for replay_id in [LV1, LV2]:
		app.replay_gallery_entry(replay_id)
		var guard := 0
		while app.gallery_replay_event != null and not app.gallery_replay_event.completed and guard < 350:
			guard += 1
			var c := str(app.gallery_replay_event.current().choices[0].id)
			app.choose_gallery_replay(c)
	expect(int(app.game.relation_for("doc_emiko").familiarity) == 20, locale + " [9]: Gallery replay of Lv1/Lv2 does NOT re-grant Familiarity")
	expect(app.game.start_character_event(LV1) == null and app.game.start_character_event(LV2) == null, locale + " [9]: repeated start_character_event rejected")
	expect(int(app.game.relation_for("doc_emiko").familiarity) == 20, locale + " [9]: rejected re-entry does NOT re-grant Familiarity")

	# SaveStore temporary file round-trip (BoundarySave v37):
	var tmp_path := "/private/tmp/emiko_early_gate_test_%s_%s.json" % [locale, OS.get_process_id()]
	var store := Store.new()
	store.path = tmp_path
	app.show_map(false)
	expect(store.write_slot(app.game, 1), locale + " [9]: write_slot to /private/tmp succeeds")
	var reloaded := new_game()
	expect(store.read_slot(reloaded, 1), locale + " [9]: read_slot from /private/tmp succeeds")
	expect(int(reloaded.relation_for("doc_emiko").familiarity) == 20 and reloaded.staff_can_join_surgery_team("doc_emiko"), locale + " [9]: BoundarySave round-trip keeps Familiarity=20 and team eligibility")
	DirAccess.remove_absolute(tmp_path)

	# 5a. Legacy save with Lv2 completed (where old Lv2 granted unlock_emiko_partner_dialogue instead of unlock_emiko_surgical_team):
	var legacy_lv2_snap: Dictionary = reloaded.snapshot()
	legacy_lv2_snap.relationship_state["doc_emiko"].unlocked_benefits = ["unlock_emiko_partner_dialogue"]
	var from_legacy_lv2 := new_game()
	expect(from_legacy_lv2.restore(legacy_lv2_snap), locale + " [5a]: legacy Lv2 save restores cleanly")
	expect(from_legacy_lv2.staff_can_join_surgery_team("doc_emiko"), locale + " [5a]: legacy Lv2 save immediately unlocks Emiko surgical team without re-triggering Lv2")
	expect(from_legacy_lv2.relation_for("doc_emiko").unlocked_benefits.has("unlock_emiko_surgical_team"), locale + " [5a]: legacy Lv2 save normalizes unlock_emiko_surgical_team benefit")
	expect(int(from_legacy_lv2.relation_for("doc_emiko").familiarity) == 20, locale + " [5a]: legacy Lv2 save does NOT re-grant Familiarity +10 on load")

	# 5b. Legacy save with ONLY Lv1 completed (where old Lv1 had put unlock_emiko_surgical_team into unlocked_benefits):
	var g_lv1_only := setup_post_intro_game(10)
	g_lv1_only.advance_story_to_day(13, 780)
	g_lv1_only.surgery_xp = g_lv1_only.surgery_xp_for_level(79)
	expect(play_event(g_lv1_only, LV1), locale + " [5b]: setup Lv1-only game")
	var legacy_lv1_snap: Dictionary = g_lv1_only.snapshot()
	legacy_lv1_snap.relationship_state["doc_emiko"].unlocked_benefits = ["unlock_emiko_surgical_team"]
	var from_legacy_lv1 := new_game()
	expect(from_legacy_lv1.restore(legacy_lv1_snap), locale + " [5b]: legacy Lv1-only save restores cleanly")
	expect(int(from_legacy_lv1.relation_for("doc_emiko").familiarity) == 10, locale + " [5b]: legacy Lv1-only save does NOT duplicate Familiarity +10")
	expect(not from_legacy_lv1.staff_can_join_surgery_team("doc_emiko"), locale + " [5b]: legacy Lv1-only save obeys new Lv2 team-unlock gate")
	from_legacy_lv1.advance_story_to_day(16, 780)
	expect(not from_legacy_lv1.character_event_available(from_legacy_lv1.character_event_definitions[LV2]), locale + " [5b]: legacy Lv1-only save requires Surgery >= 80 for Lv2 (blocked at 79)")
	from_legacy_lv1.surgery_xp = from_legacy_lv1.surgery_xp_for_level(80)
	expect(from_legacy_lv1.character_event_available(from_legacy_lv1.character_event_definitions[LV2]), locale + " [5b]: legacy Lv1-only save unlocks Lv2 once Surgery reaches 80")

	# 5c. Legacy save BEFORE Lv2 where Emiko was already booked in an advanced surgical team (or preset ordinary preop team):
	var g_booked := setup_post_intro_game(10)
	var adv_booked := setup_advanced_eligible(g_booked)
	g_booked.advance_story_to_day(15, 540) # Monday
	var preset_team := {
		"first_assistant": "doc_emiko",
		"second_assistant": "doc_aoi",
		"primary_scrub": "nurse_ange",
		"secondary_scrub": "nurse_yui",
		"primary_circulating": "nurse_hiroko",
		"secondary_circulating": "nurse_haru",
		"anesthesia": "doc_sakura_anesthesiology",
	}
	var case_offer: Dictionary = adv_booked.board()[0]
	adv_booked.state().appointment = {
		"intake_day": 15,
		"operation_day": 16,
		"review_day": 17,
		"case": case_offer.duplicate(true),
		"team": preset_team.duplicate(true),
		"intake_minutes": 60,
	}
	var booked_snap: Dictionary = g_booked.snapshot()
	var restored_booked := new_game()
	expect(restored_booked.restore(booked_snap), locale + " [5c]: legacy save with pre-booked Emiko advanced team loads without error")
	expect(not restored_booked.staff_can_join_surgery_team("doc_emiko"), locale + " [5c]: Emiko is not eligible for new active selection before Lv2")
	var adv_restored := Referral.new(restored_booked)
	expect(not adv_restored.rebook(preset_team), locale + " [5c]: active rebook obeys new Gate and rejects Emiko before Lv2")
	restored_booked.advance_story_to_day(16, 540) # Operation Day 09:00
	expect(adv_restored.start_operation(), locale + " [5c]: already-booked advanced surgery with Emiko starts cleanly on Day 2 without breaking")
	if adv_restored.session != null:
		adv_restored.session.rng.seed = 42
		finish_advanced_session(adv_restored.session)
		expect(adv_restored.finish_operation(), locale + " [5c]: already-booked advanced surgery finishes cleanly")
		expect(adv_restored.settle(), locale + " [5c]: already-booked advanced surgery settles cleanly on Day 3")
	restored_booked.advance_story_to_day(22, 540)
	expect(adv_restored.candidates("first_assistant", 23).all(func(p): return str(p.id) != "doc_emiko"), locale + " [5c]: next active team booking strictly enforces Lv2 Gate")

	# Also verify preset in-memory ordinary PreopSession team with Emiko remains ready while active re-assign rejects Emiko:
	var visit_preset = restored_booked.open_visit("visit_sora")
	visit_preset.admitted = true
	var prep_preset = restored_booked.open_preop("preop_sora")
	prep_preset.stage_id = "team"
	prep_preset.team = {
		"assistant_surgeon": "doc_emiko",
		"scrub_nurse": "nurse_ange",
		"circulating_nurse": "nurse_hiroko",
		"ward_nurse": "nurse_haru",
	}
	expect(prep_preset.team_ready() and prep_preset.sweep_team_ready(), locale + " [5c]: preset ordinary preop team with Emiko does not break ongoing surgery readiness")
	prep_preset.team.erase("assistant_surgeon")
	expect(not prep_preset.apply({"kind": "assign", "role": "assistant_surgeon", "staff_id": "doc_emiko"}), locale + " [5c]: next active ordinary assign obeys Lv2 Gate")

	# 5d. Corrupted/incomplete save with level >= 2 but missing reliable Lv2 completion record emits warning and does NOT guess from familiarity:
	var incomplete_snap: Dictionary = g_lv1_only.snapshot()
	incomplete_snap.relationship_state["doc_emiko"].level = 2
	incomplete_snap.relationship_state["doc_emiko"].familiarity = 65
	var from_incomplete := new_game()
	expect(from_incomplete.restore(incomplete_snap), locale + " [5d]: save with missing Lv2 event record loads without crashing")
	expect(not from_incomplete.staff_can_join_surgery_team("doc_emiko"), locale + " [5d]: missing Lv2 event record does NOT unlock team by guessing from familiarity/level")
	expect(from_incomplete.restore_warnings.size() > 0, locale + " [5d]: restore_warnings reports missing reliable Lv2 event completion record")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	app.title_notice_enabled = false
	app.saves.path = "/private/tmp/emiko_early_gate_unused_%s.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/emiko_early_gate_prefs_%s.cfg" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Load content " + locale)
		expect(app.content.load_all(locale), "Load app content " + locale)
		app.configure_game_content()
		test_gates_and_fixed_familiarity(locale)
		test_scripted_appearances_unaffected(locale)
		test_save_load_replay_and_legacy_compatibility(app)
	app.queue_free()
	await process_frame
	print("EMIKO EARLY GATE TEST: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures > 0 else 0)
