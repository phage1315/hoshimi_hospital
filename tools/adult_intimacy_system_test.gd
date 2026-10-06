extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const AdultIntimacySession = preload("res://godot/systems/adult_intimacy_session.gd")

var content = Loader.new()
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func test_profile() -> Dictionary:
	return {
		"enabled": true,
		"initiative": "proactive",
		"initiative_overrides": {"operating_room": "responsive"},
		"fallback_h_cg": {"id": "cg_test_fallback", "path": "assets/test/fallback.png"},
		"base_locations": ["hotel"],
		"base_outfits": ["nude"],
		"outfit_portraits": {"nude": "adult_nude", "mask_gloves": "adult_mask_gloves"},
		"opening_lines": {"hotel": "下班后，她来到约好的房间。", "operating_room": "夜班交接以后，手术室已经安静下来。"},
		"foreplay_preferences": {"touch": "normal", "kiss": "preferred", "lick": "normal"},
		"target_preferences": {"neck": "preferred", "intimate": "strong_preference"},
		"action_reactions": {
			"touch": [{"line": "再靠近一点。", "expression": "embarrassed"}],
			"kiss": [{"line": "她回应了这个吻。", "expression": "excited"}],
			"lick": [{"line": "她的呼吸乱了一拍。", "expression": "excited", "sfx": "……"}],
		},
		"target_reactions": {"neck": [{"line": "颈侧让她轻轻缩了一下。", "expression": "embarrassed"}]},
		"initiative_event": {
			"threshold": 60,
			"line": "等一下，这次让我来。",
			"follow_label": "顺着她",
			"lead_label": "继续由我来",
			"follow_response": "她接过了主动。",
			"lead_response": "她笑着把主动权留给你。",
			"expression": "excited",
		},
		"position_lines": {"top": "她俯身靠近。", "bottom": "她在身下抬起眼。", "rear": "她回头看了一眼。", "69": "她明白了你的意思。"},
		"after_lines": ["房间重新安静下来。", "她说明天医院见。"],
		"special_cgs": [
			{"id": "cg_test_or", "path": "assets/test/or.png", "location": "operating_room"},
			{"id": "cg_test_mask", "path": "assets/test/mask.png", "outfit": "mask_gloves"},
			{"id": "cg_test_or_mask", "path": "assets/test/or_mask.png", "location": "operating_room", "outfit": "mask_gloves"},
		],
	}

func staff_with_test_profile() -> Array:
	var result: Array = content.collections.staff.duplicate(true)
	for person in result:
		if str(person.get("id", "")) == "doc_sayaka":
			person["h_profile"] = test_profile()
	return result

func configure_game(game) -> void:
	game.configure(content.collections.encounters, content.collections.preops, staff_with_test_profile(), content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions, content.collections.palpation_profiles)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var profile := test_profile()
	var session = AdultIntimacySession.new("doc_sayaka", profile, "hotel", "nude", false, {}, ["cg_test_or_mask"])
	expect(session.phase == "foreplay" and session.excitement == 0, "The intimacy session did not initialize")
	var first: Dictionary = session.perform("kiss", "neck")
	expect(first.accepted and first.gain == 25 and first.line == "颈侧让她轻轻缩了一下。", "Action and target preferences did not resolve data-driven gain/reaction")
	expect(not session.perform("invalid", "neck").accepted, "An unknown foreplay action was accepted")
	expect(session.perform("kiss", "face").accepted and session.excitement == 45, "Second foreplay action did not accumulate excitement")
	expect(session.perform("kiss", "neck").accepted and session.phase == "initiative", "Initiative did not trigger at its authored threshold")
	expect(session.initiative_prompt() == "等一下，这次让我来。", "Initiative prompt is missing")
	var initiative_result: Dictionary = session.resolve_initiative(false)
	expect(initiative_result.accepted and initiative_result.initiative_style == "proactive" and session.phase == "foreplay", "Player could not retain control after an initiative suggestion")
	expect(session.perform("kiss", "intimate").accepted and session.excitement == 95, "Strong preference did not apply its configured gain")
	expect(session.perform("touch", "face").accepted and session.excitement == 100 and session.phase == "position", "Excitement MAX did not open position choice")
	var position: Dictionary = session.choose_position("rear")
	expect(position.accepted and position.cg_id == "cg_test_fallback", "Locked special CG did not fall back to the character CG")
	expect(session.continue_from_cg() and session.after_lines().size() == 2 and session.finish() and session.completed(), "CG and after-scene phases did not complete")

	var special = AdultIntimacySession.new("doc_sayaka", profile, "operating_room", "mask_gloves", false, {}, ["cg_test_or", "cg_test_mask", "cg_test_or_mask"])
	expect(special.initiative_style() == "responsive", "Location-specific initiative override did not apply")
	special.excitement = 100
	special.phase = "position"
	var special_choice: Dictionary = special.choose_position("top")
	expect(special_choice.cg_id == "cg_test_or_mask", "Location plus outfit CG did not outrank single-condition CGs")
	var same_cg = AdultIntimacySession.new("doc_sayaka", profile, "operating_room", "mask_gloves", false, {}, ["cg_test_or", "cg_test_mask", "cg_test_or_mask"])
	same_cg.excitement = 100
	same_cg.phase = "position"
	expect(same_cg.choose_position("69").cg_id == special_choice.cg_id, "Position incorrectly changed the CG key")
	var milestone = AdultIntimacySession.new("doc_sayaka", profile, "hotel", "nude", true, {"id": "cg_milestone", "path": "assets/test/milestone.png"}, [])
	milestone.excitement = 100
	milestone.phase = "position"
	expect(milestone.choose_position("bottom").cg_id == "cg_milestone", "Authored milestone CG did not override fallback resolution")

	var game = GameState.new()
	configure_game(game)
	game.meet_staff("doc_sayaka")
	expect(not game.repeatable_adult_intimacy_available("doc_sayaka"), "Repeatable intimacy unlocked before its milestone")
	expect(game.unlock_repeatable_adult_intimacy("doc_sayaka"), "Milestone could not unlock repeatable intimacy")
	expect(game.adult_intimacy_location_options("doc_sayaka") == ["hotel"] and game.adult_intimacy_outfit_options("doc_sayaka") == ["nude"], "Base location/outfit unlocks are incorrect")
	expect(game.unlock_adult_intimacy_location("doc_sayaka", "operating_room") and game.unlock_adult_intimacy_outfit("doc_sayaka", "mask_gloves") and game.unlock_adult_intimacy_cg("doc_sayaka", "cg_test_or_mask"), "Special content unlocks failed")
	var started_day := game.day_number()
	var active = game.start_repeatable_adult_intimacy("doc_sayaka", "hotel", "nude")
	expect(active != null and game.active_mode == "adult_intimacy", "After-work repeatable session could not start")
	active.perform("kiss", "neck")
	var saved: Dictionary = game.snapshot()
	var clone = GameState.new()
	configure_game(clone)
	expect(clone.restore(JSON.parse_string(JSON.stringify(saved))), "In-progress intimacy session did not restore")
	expect(clone.active_mode == "adult_intimacy" and clone.active_adult_intimacy.excitement == 25, "Restored intimacy state lost progress")
	clone.active_adult_intimacy.perform("kiss", "face")
	clone.active_adult_intimacy.perform("kiss", "neck")
	clone.active_adult_intimacy.resolve_initiative(true)
	clone.active_adult_intimacy.perform("kiss", "intimate")
	clone.active_adult_intimacy.perform("touch", "face")
	clone.active_adult_intimacy.choose_position("top")
	clone.active_adult_intimacy.continue_from_cg()
	clone.active_adult_intimacy.finish()
	expect(clone.finish_adult_intimacy(), "Completed intimacy session did not close")
	expect(clone.day_number() == started_day + 1 and clone.active_mode == "encounter", "After-work intimacy did not consume the remainder of the day")
	clone.advance_story_to_day(6, 540)
	expect(clone.is_sunday() and not clone.repeatable_adult_intimacy_available("doc_sayaka"), "The after-work entry appeared on a hospital-closed Sunday")

	print("ADULT INTIMACY SYSTEM: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
