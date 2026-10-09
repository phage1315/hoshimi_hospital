extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")

var content = Loader.new()
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func configure_game(game) -> void:
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations)

func advance_to_node(game, event, target: String) -> bool:
	while not event.completed and event.node_id != target:
		if not game.choose_character_event(str(event.current().choices[0].id)):
			return false
	return event.node_id == target

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var game = GameState.new()
	configure_game(game)
	game.meet_staff("doc_sayaka")
	game.advance_story_to_day(2, 540)

	expect(game.next_mandatory_character_event().get("id", "") == "sayaka_week1_phone_exchange", "Week-one phone exchange did not auto-queue on day two")
	var phone = game.start_character_event("sayaka_week1_phone_exchange")
	expect(phone != null, "Phone exchange could not start")
	if phone != null:
		while not phone.completed:
			expect(game.choose_character_event(str(phone.current().choices[0].id)), "Phone exchange choice failed")
	var relation: Dictionary = game.relation_for("doc_sayaka")
	expect(relation.level == 0, "Phone exchange incorrectly raised Sayaka to Lv1")
	for flag in ["sayaka_phone_exchanged", "sayaka_sunday_invite_available", "sayaka_private_contact_open"]:
		expect(relation.flags.has(flag), "Phone exchange did not set " + flag)
	expect(game.day_start_character_event_consumed() and game.next_mandatory_character_event().is_empty(), "A second day-start event was allowed on the same day")
	expect(not game.character_event_available(game.character_event_definitions.sayaka_lv1_first_date), "Sayaka's Sunday date became available on a weekday")
	expect(game.next_character_event_at("player_office").get("id", "") != "sayaka_lv1_first_date", "Sayaka's Sunday date appeared as a weekday office event")

	game.advance_story_to_day(6, 540)
	expect(game.is_sunday(), "First Sunday calendar date is wrong")
	expect(game.character_event_available(game.character_event_definitions.sayaka_lv1_first_date), "Sayaka's first date was unavailable on Sunday")
	expect(game.sunday_date_candidates() == ["doc_sayaka"], "Sayaka did not enter the Lv0 Sunday invitation list")
	expect(game.sunday_invitation_rejection_rate("doc_sayaka") == 0 and game.sunday_invitation_will_accept("doc_sayaka"), "Sayaka's first invitation was allowed to reject")

	var first_date = game.start_character_event("sayaka_lv1_first_date")
	expect(first_date != null and advance_to_node(game, first_date, "what_is_this"), "First date did not reach its relationship choice")
	if first_date != null and first_date.node_id == "what_is_this":
		expect(game.choose_character_event("date_only_meal"), "Just-a-meal branch could not be chosen")
		expect(game.choose_character_event("only_meal_end"), "Just-a-meal branch could not finish")
	expect(game.relationship_level("doc_sayaka") == 0, "Rejecting the date framing incorrectly raised Sayaka to Lv1")
	expect(not game.character_event_done("sayaka_lv1_first_date"), "Rejected date was marked permanently complete")
	expect(relation.flags.has("sayaka_romantic_interest_visible") and relation.flags.has("sayaka_first_date_retry_pending"), "Rejected date did not preserve Sayaka's visible interest and retry state")

	expect(game.complete_sunday_activity("date", "doc_sayaka", "restaurant_bar"), "Rejected first date did not consume its Sunday")
	game.advance_story_to_day(13, 540)
	expect(game.is_sunday(), "Retry day is not Sunday")
	var retry_date = game.start_character_event("sayaka_lv1_first_date")
	expect(retry_date != null and retry_date.choices.is_empty(), "Retry did not start a fresh date session")
	expect(retry_date != null and advance_to_node(game, retry_date, "what_is_this"), "Retry date did not reach its relationship choice")
	if retry_date != null and retry_date.node_id == "what_is_this":
		expect(game.choose_character_event("date_direct"), "Direct date confirmation failed")
		while not retry_date.completed:
			expect(game.choose_character_event(str(retry_date.current().choices[0].id)), "Confirmed date continuation failed")
	expect(game.relationship_level("doc_sayaka") == 1, "Confirmed first date did not raise Sayaka to Lv1")
	expect(game.character_event_done("sayaka_lv1_first_date"), "Confirmed first date was not recorded")
	expect(int(relation.familiarity) > 10, "Sayaka's successful first date did not preserve familiarity earned beyond the old milestone cap")
	expect(not relation.flags.has("sayaka_first_date_retry_pending"), "Successful retry left the retry flag behind")
	for flag in ["sayaka_first_date_completed", "sayaka_mutual_attraction", "sayaka_romantic_interest_confirmed", "sayaka_lv2_eligible_base"]:
		expect(relation.flags.has(flag), "Successful first date did not set " + flag)

	expect(game.complete_sunday_activity("date", "doc_sayaka", "restaurant_bar"), "Successful first date did not consume its Sunday")
	expect(game.day_number() == 14 and game.next_character_event_at("clinic").get("id", "") == "sayaka_lv1_monday_callback", "Monday callback did not unlock after the successful date")
	expect(not game.character_event_available(game.character_event_definitions.sayaka_lv2_working_hours), "Sayaka Lv2 bypassed the Monday callback")
	var callback = game.start_character_event("sayaka_lv1_monday_callback")
	expect(callback != null, "Monday callback could not start")
	var familiarity_before_callback := int(relation.familiarity)
	if callback != null:
		while not callback.completed:
			expect(game.choose_character_event(str(callback.current().choices[0].id)), "Monday callback continuation failed")
	expect(relation.flags.has("sayaka_monday_callback_complete") and int(relation.familiarity) == mini(100, familiarity_before_callback + 3), "Monday callback did not award its authored familiarity")
	if int(relation.familiarity) < 25:
		game.add_familiarity("doc_sayaka", 25 - int(relation.familiarity))
	expect(not game.character_event_available(game.character_event_definitions.sayaka_lv2_working_hours), "Sayaka Lv2 bypassed the three-day milestone cooldown")
	game.advance_story_to_day(17, 540)
	expect(game.next_mandatory_character_event().get("id", "") == "sayaka_lv2_working_hours", "Sayaka Lv2 was not selected by the day-start scheduler")
	expect(game.next_character_event_at("player_office").is_empty(), "Sayaka Lv2 leaked into the location-event scheduler")
	var working_hours = game.start_character_event("sayaka_lv2_working_hours")
	expect(working_hours != null and advance_to_node(game, working_hours, "white_coat"), "Sayaka Lv2 did not reach its appearance choice")
	if working_hours != null and working_hours.node_id == "white_coat":
		expect(game.choose_character_event("lv2_scrubs"), "Sayaka Lv2 scrubs compliment could not be selected")
		while not working_hours.completed:
			expect(game.choose_character_event(str(working_hours.current().choices[0].id)), "Sayaka Lv2 continuation failed")
	expect(game.relationship_level("doc_sayaka") == 2 and game.character_event_done("sayaka_lv2_working_hours"), "Sayaka Lv2 did not complete its rank-up")
	for flag in ["sayaka_workplace_flirt_established", "sayaka_school_nurse_background_shared", "sayaka_medicine_return_motivation_known", "sayaka_surgical_outfit_compliment_seen", "sayaka_lv3_pre_event_eligible"]:
		expect(relation.flags.has(flag), "Sayaka Lv2 did not set " + flag)
	expect(relation.unlocked_benefits.has("unlock_sayaka_lv2_workplace_flirt"), "Sayaka Lv2 benefit was not unlocked")

	var lv3_game = GameState.new()
	configure_game(lv3_game)
	lv3_game.meet_staff("doc_sayaka")
	expect(lv3_game._complete_character_event_for_test("sayaka_lv2_working_hours", 1), "Sayaka Lv3 fixture could not complete its Lv2 prerequisite")
	var lv3_relation: Dictionary = lv3_game.relation_for("doc_sayaka")
	lv3_relation.level = 2
	lv3_relation.familiarity = 40
	lv3_relation.rank_history = ["sayaka_lv2_working_hours"]
	lv3_game.set_test_player_attribute("charm", 10)
	lv3_game.advance_story_to_day(4, 1019)
	var lv3_definition: Dictionary = lv3_game.next_after_work_character_event()
	expect(lv3_definition.get("id", "") == "sayaka_lv3_relationship", "Sayaka Lv3 did not queue at the end of a qualifying workday")
	var lv3_event = lv3_game.start_character_event("sayaka_lv3_relationship")
	expect(lv3_event != null and lv3_event.node_id == "scene_01_fallback", "Sayaka Lv3 did not use its fallback opening when no observing nurse was present")
	if lv3_event != null:
		while not lv3_event.completed:
			expect(lv3_game.choose_character_event(str(lv3_event.current().choices[0].id)), "Sayaka Lv3 continuation failed")
	expect(lv3_game.relationship_level("doc_sayaka") == 3 and lv3_game.character_event_done("sayaka_lv3_relationship"), "Sayaka Lv3 did not complete its rank-up")
	expect(lv3_relation.familiarity == 40, "Sayaka Lv3 awarded an unintended familiarity reward")
	expect(lv3_relation.flags.has("sayaka_lv3_romance_confirmed") and lv3_relation.flags.has("sayaka_first_kiss_happened"), "Sayaka Lv3 did not preserve its romance and first-kiss flags")

	var snapshot: Dictionary = game.snapshot()
	var clone = GameState.new()
	configure_game(clone)
	expect(clone.restore(JSON.parse_string(JSON.stringify(snapshot))), "Sayaka event save did not restore")
	expect(clone.relationship_level("doc_sayaka") == 2 and clone.character_event_done("sayaka_lv1_first_date") and clone.character_event_done("sayaka_lv2_working_hours"), "Restoring Sayaka's route changed its Lv2 outcome")

	var background: Dictionary = content.find_record("backgrounds", "italian_trattoria")
	expect(not background.is_empty() and ResourceLoader.exists("res://" + str(background.path)), "Italian trattoria background is missing")
	print("SAYAKA LV1-LV2 EVENTS: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
