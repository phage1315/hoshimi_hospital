extends SceneTree

const GameState = preload("res://godot/systems/game_state.gd")

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = GameState.new()
	game.configure([])
	game.surgery_xp = game.surgery_xp_for_level(79)
	game.archived_player_effects.reputation = 250
	expect(not game.advanced_referral_eligible(), "Advanced referral opened below Surgery 80")
	game.surgery_xp = game.surgery_xp_for_level(80)
	game.archived_player_effects.reputation = 249
	expect(not game.advanced_referral_eligible(), "Advanced referral opened below Reputation 250")
	game.archived_player_effects.reputation = 5000
	expect(game.player_attributes().reputation == 999, "Reputation did not clamp at 999")
	expect(game.advanced_referral_eligible(), "Surgery 80 and Reputation 250 did not unlock the tutorial gate")
	expect(game.completed_surgeries_total == 0, "Advanced referral unexpectedly depends on a completed or major-surgery count")
	expect(not game.advanced_referral_system_unlocked(), "Random advanced referrals opened before the Chisato tutorial")
	game.set_story_flag("advanced_referral_random_cases_enabled", true)
	expect(game.advanced_referral_system_unlocked(), "Tutorial completion flag did not unlock random advanced referrals")

	var referral := {
		"id": "referral_test",
		"duration_days": 3,
		"priority": 150,
		"unique_per_campaign": true,
		"unlock_requirements": [],
	}
	var sunday_span: Dictionary = game.advanced_referral_timing_status(referral, 6)
	expect(sunday_span.status == "available" and sunday_span.end_day == 8, "A multi-day referral could not span Sunday")
	var last_safe: Dictionary = game.advanced_referral_timing_status(referral, 356)
	expect(last_safe.status == "available" and last_safe.end_day == 358, "Last pre-final-week referral window was rejected")
	expect(game.advanced_referral_timing_status(referral, 357).status == "final_week_reserved", "Referral entered the reserved final week")

	game.special_event_definitions["fixed_story"] = {
		"id": "fixed_story",
		"duration_days": 2,
		"repeatable": false,
		"required_characters": [],
		"prerequisite_events": [],
		"unlock_requirements": [],
		"timing": {"trigger_day": 10, "priority": 220},
	}
	var postponed: Dictionary = game.advanced_referral_timing_status(referral, 9)
	expect(postponed.status == "postponed", "Higher-priority story conflict did not postpone referral")
	expect(postponed.start_day == 12 and postponed.end_day == 14, "Referral was not moved after the protected event")
	expect(postponed.blocked_by == ["fixed_story"], "Postponement did not identify its blocker")

	expect(game.advanced_referral_case_available(referral), "Eligible unique referral was unavailable")
	game.complete_advanced_referral_case("referral_test")
	expect(not game.advanced_referral_case_available(referral), "Completed unique referral remained available")
	var metrics: Dictionary = game.career_ending_metrics()
	expect(metrics.reputation == 999 and metrics.surgery == 80, "Ending metrics did not expose career progression")

	print("ADVANCED REFERRAL: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
