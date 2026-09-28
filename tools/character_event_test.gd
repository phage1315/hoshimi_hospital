extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
var content = Loader.new()
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func new_game() -> RefCounted:
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events)
	game.meet_staff("doc_aoi")
	game.meet_staff("nurse_haru")
	return game

func finish_event(game: RefCounted, id: String, first_choice: String = "") -> bool:
	var event = game.start_character_event(id)
	if event == null:
		return false
	while not event.completed:
		var choice_id: String = event.current().choices[0].id if first_choice.is_empty() or event.choices.size() > 0 else first_choice
		if not game.choose_character_event(choice_id):
			return false
	return true

func run() -> void:
	expect(content.load_all(), "Content load failed")
	expect(content.collections.character_events.size() == 21, "Expected current story, acquaintance and contextual events")
	var game = new_game()
	expect(game.next_character_event_at("or").get("id", "") != "moe_wrong_changing_room", "Preop-stage event leaked into ordinary operating-room entry")
	expect(game.next_character_event_for_preop_stage("changing").is_empty(), "Moe changing-room event appeared on day one")
	expect(game.next_character_event_for_preop_stage("ward").is_empty(), "Moe changing-room event appeared at the wrong preop stage")
	var moe_day_two = new_game()
	for i in range(24):
		expect(moe_day_two.spend_time("rooftop_pause"), "Could not advance to day two for Moe event")
	expect(moe_day_two.day_number() == 2 and moe_day_two.next_character_event_for_preop_stage("changing").get("id", "") == "moe_wrong_changing_room", "Moe changing-room event did not unlock on day two")
	expect(game.relation_for("doc_aoi").trust == 10 and game.relation_for("nurse_haru").trust == 10, "Initial relationship values wrong")
	expect(game.character_events_for("doc_aoi").map(func(event): return event.id) == ["aoi_01_cold_tea"], "Aoi opening event availability wrong")
	expect(game.character_events_for("nurse_haru").map(func(event): return event.id) == ["haru_01_half_sandwich"], "Haru opening event availability wrong")
	expect(game.next_character_event_at("lounge").is_empty(), "Lounge event appeared before its time window")
	var scheduled = new_game()
	for i in range(6):
		expect(scheduled.spend_time("rooftop_pause"), "Could not reach natural event time")
	expect(scheduled.clock_text() == "10:00" and scheduled.next_character_event_at("lounge").id == "aoi_01_cold_tea", "Natural event time/location scheduling failed")
	expect(scheduled.next_character_event_at("ward").is_empty(), "Event appeared at wrong location")
	expect(game.start_character_event("aoi_02_blank_chart") == null, "Locked chapter started")

	var aoi = game.start_character_event("aoi_01_cold_tea")
	expect(aoi != null and aoi.current().id == "opening", "Aoi event did not start")
	expect(not game.choose_character_event("missing"), "Invalid event choice accepted")
	expect(aoi.choices.is_empty() and game.relation_for("doc_aoi").trust == 10, "Invalid choice mutated state")
	expect(game.choose_character_event("replace_tea"), "Aoi first choice failed")
	expect(game.relation_for("doc_aoi").trust == 12 and game.relation_for("doc_aoi").affection == 1 and game.relation_for("doc_aoi").familiarity == 2, "Aoi relationship effect wrong")
	var mid_snapshot: Dictionary = game.snapshot()
	var clone = new_game()
	expect(clone.restore(JSON.parse_string(JSON.stringify(mid_snapshot))), "Mid-event save restore failed")
	expect(clone.snapshot() == mid_snapshot and clone.character_events.aoi_01_cold_tea.current().id == "tea_reply", "Mid-event replay differs")
	expect(clone.choose_character_event("tea_end"), "Restored event could not finish")
	expect(clone.elapsed() == 30 and clone.character_event_done("aoi_01_cold_tea"), "Completed event time/history missing")
	expect(clone.relationship_level("doc_aoi") == 1, "Aoi opening event did not establish the Lv.1 bond")
	expect(clone.relation_for("doc_aoi").event_history == ["aoi_01_cold_tea"], "Completed event not recorded on relationship")
	expect(clone.start_character_event("aoi_01_cold_tea") == null, "Completed event restarted")
	expect(clone.character_events_for("doc_aoi").map(func(event): return event.id) == ["aoi_02_blank_chart"], "Aoi second chapter did not unlock")

	expect(finish_event(clone, "aoi_02_blank_chart", "admit_gap"), "Aoi chapter two failed")
	expect(finish_event(clone, "aoi_03_no_answer", "admit_uncertain"), "Aoi chapter three failed")
	expect(not clone.character_event_available(clone.character_event_definitions.aoi_04_lit_window), "Day-two Aoi chapter unlocked early")
	for i in range(38):
		expect(clone.spend_time("rooftop_pause"), "Could not advance schedule")
	expect(clone.day_number() == 2 and clone.character_event_available(clone.character_event_definitions.aoi_04_lit_window), "Day-two chapter did not unlock")
	expect(finish_event(clone, "aoi_04_lit_window", "ask_photo"), "Aoi final chapter failed")
	expect(clone.relation_for("doc_aoi").event_history.size() == 4, "Aoi event series incomplete")
	var full_snapshot: Dictionary = clone.snapshot()
	var full_clone = new_game()
	expect(full_clone.restore(JSON.parse_string(JSON.stringify(full_snapshot))) and full_clone.snapshot() == full_snapshot, "Completed event series save replay failed")

	var haru_game = new_game()
	expect(finish_event(haru_game, "haru_01_half_sandwich", "share_food"), "Haru chapter one failed")
	expect(haru_game.relationship_level("nurse_haru") == 1, "Haru opening event did not establish the Lv.1 bond")
	var before_downplay: Dictionary = haru_game.relation_for("nurse_haru").duplicate(true)
	expect(finish_event(haru_game, "haru_02_handoff_line", "downplay"), "Haru critical branch failed")
	expect(haru_game.relation_for("nurse_haru").trust == before_downplay.trust - 1 and haru_game.relation_for("nurse_haru").respect == before_downplay.respect, "Haru critical branch effects/reply wrong")
	expect(finish_event(haru_game, "haru_03_no_problem", "return_now"), "Haru chapter three failed")
	expect(not haru_game.character_event_available(haru_game.character_event_definitions.haru_04_after_mask), "Day-two Haru chapter unlocked early")

	# UI route: profile -> event list -> event dialogue -> completion.
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.game.meet_staff("doc_aoi")
	app.show_staff("doc_aoi", "lounge")
	# Buttons are named by their default class name, so locate this one by text.
	var profile_event_button: Button
	for child in app.page.get_children():
		if child is Button and child.text == "事件测试  →":
			profile_event_button = child
	expect(profile_event_button != null, "Profile event entry missing")
	if profile_event_button != null:
		profile_event_button.pressed.emit()
	expect(app.screen == "character_events", "Event hub did not open")
	var first_button: Button = app.page.get_node_or_null("CharacterEvent_aoi_01_cold_tea")
	var second_button: Button = app.page.get_node_or_null("CharacterEvent_aoi_02_blank_chart")
	expect(first_button != null and not first_button.disabled and second_button != null and not second_button.disabled, "Event test entries should all be available")
	if first_button != null:
		first_button.pressed.emit()
	expect(app.screen == "gallery_replay" and app.page.get_node_or_null("CharacterPortrait") != null, "Event test dialogue page missing")
	var opening_portrait: TextureRect = app.page.get_node_or_null("CharacterPortrait")
	var opening_texture := opening_portrait.texture.resource_path if opening_portrait != null else ""
	var choice: Button = app.page.get_node_or_null("ReplayChoice_replace_tea")
	expect(choice != null, "Authored event choice missing")
	if choice != null:
		choice.pressed.emit()
	var reply_portrait: TextureRect = app.page.get_node_or_null("CharacterPortrait")
	expect(reply_portrait != null and reply_portrait.texture.resource_path != opening_texture, "Event node did not switch expression portrait")
	var ending: Button = app.page.get_node_or_null("ReplayChoice_tea_end")
	expect(ending != null, "Branch reply/continue choice missing")
	if ending != null:
		ending.pressed.emit()
	expect(app.screen == "character_events" and app.game.elapsed() == 0 and not app.game.character_event_done("aoi_01_cold_tea"), "Event test changed live progress")
	for i in range(6):
		app.game.spend_time("rooftop_pause")
	app.show_location("lounge")
	var natural_button: Button = app.page.get_node_or_null("NaturalEvent_aoi_01_cold_tea")
	expect(natural_button != null, "Eligible event was not integrated into its location")
	if natural_button != null:
		natural_button.pressed.emit()
	expect(app.screen == "character_event" and not app.character_event_from_test, "Natural event used test route")
	choice = app.page.get_node_or_null("EventChoice_replace_tea")
	if choice != null:
		choice.pressed.emit()
	ending = app.page.get_node_or_null("EventChoice_tea_end")
	if ending != null:
		ending.pressed.emit()
	var reward_cg: TextureRect = app.page.get_node_or_null("EventRewardCG")
	expect(app.screen == "character_event_reward" and reward_cg != null and reward_cg.texture != null and app.game.elapsed() == 90, "Natural event CG reward/time missing")
	var reward_continue: Button = app.page.get_node_or_null("EventRewardContinue")
	expect(reward_continue != null, "CG reward continue control missing")
	if reward_continue != null:
		reward_continue.pressed.emit()
	expect(app.screen == "character_event_complete", "CG reward did not continue to numeric settlement")
	app.show_event_gallery()
	var gallery_scroll := app.page.get_node_or_null("EventGalleryScroll") as ScrollContainer
	var unlocked_gallery := app.page.find_child("GalleryEvent_aoi_01_cold_tea", true, false) as Button
	var locked_gallery := app.page.find_child("GalleryEvent_aoi_02_blank_chart", true, false) as Button
	var moe_gallery := app.page.find_child("GalleryEvent_moe_wrong_changing_room", true, false) as Button
	var hiroko_gallery := app.page.find_child("GalleryEvent_hiroko_patient_escape", true, false) as Button
	expect(gallery_scroll != null and moe_gallery != null and hiroko_gallery != null, "Gallery scrolling or lower character events missing")
	expect(unlocked_gallery != null and not unlocked_gallery.disabled and locked_gallery != null and locked_gallery.disabled, "Gallery unlock state wrong")
	if unlocked_gallery != null:
		unlocked_gallery.pressed.emit()
	expect(app.screen == "gallery_entry", "Gallery detail did not open")
	var gallery_cg: TextureRect = app.page.get_node_or_null("GalleryCG")
	expect(gallery_cg != null and gallery_cg.texture != null, "Gallery CG asset did not load")
	app.replay_gallery_entry("aoi_01_cold_tea")
	var replay_choice: Button = app.page.get_node_or_null("ReplayChoice_replace_tea")
	expect(replay_choice != null, "Gallery replay did not start")
	var elapsed_before_replay: int = app.game.elapsed()
	var relation_before_replay: Dictionary = app.game.relation_for("doc_aoi").duplicate(true)
	if replay_choice != null:
		replay_choice.pressed.emit()
	var replay_end: Button = app.page.get_node_or_null("ReplayChoice_tea_end")
	if replay_end != null:
		replay_end.pressed.emit()
	expect(app.game.elapsed() == elapsed_before_replay and app.game.relation_for("doc_aoi") == relation_before_replay, "Gallery replay changed live progress")

	# Regression: event portraits must ignore their 1024×1536 source minimum
	# before applying authored display size and position.
	app.game.reset()
	expect(app.game.start_character_event("moe_wrong_changing_room") != null, "Moe changing-room event could not start for portrait regression test")
	app.show_character_event()
	var moe_portrait: TextureRect = app.page.get_node_or_null("CharacterEventPortrait")
	expect(moe_portrait != null, "Moe event portrait missing")
	if moe_portrait != null:
		expect(moe_portrait.size.distance_to(Vector2(429.33, 644.0)) < 2.0, "Moe event portrait ignored authored display size")
		expect(moe_portrait.position.distance_to(Vector2(790.67, 55.0)) < 2.0, "Moe event portrait ignored authored position")

	# Emiko remains inaccessible until the protagonist's surgical skill is high
	# enough. Her introduction schedules Lv1 for the next afternoon, while Lv2
	# requires a higher skill threshold and a full seven-day gap.
	var emiko_game = new_game()
	var emiko_intro: Dictionary = emiko_game.character_event_definitions.emiko_intro_rumored_hands
	var emiko_lv2: Dictionary = emiko_game.character_event_definitions.emiko_lv2_follow_my_lead
	expect(not emiko_game.staff_is_met("doc_emiko"), "Emiko should begin unknown")
	expect(emiko_game.character_event_available(emiko_game.character_event_definitions.emiko_office_denied), "Low-skill office refusal was unavailable")
	expect(not emiko_game.character_event_available(emiko_intro), "Emiko introduction ignored the surgical-skill gate")
	# The first refusal is delivered entirely by the nurse outside the office.
	# Completing it must not reveal Emiko's portrait before her Lv0 meeting.
	app.game.reset()
	expect(finish_event(app.game, "emiko_office_denied"), "Emiko office refusal could not complete")
	app.show_character_event_complete()
	expect(not app.game.staff_is_met("doc_emiko"), "Emiko office refusal met Emiko early")
	expect(app.page.get_node_or_null("CharacterPortrait") == null, "Emiko portrait appeared before the Lv0 meeting")
	emiko_game.archived_player_effects.skill = 6
	expect(emiko_game.character_event_available(emiko_intro), "Emiko introduction did not unlock at skill 56")
	expect(finish_event(emiko_game, "emiko_intro_rumored_hands"), "Emiko introduction could not complete")
	expect(emiko_game.staff_is_met("doc_emiko") and emiko_game.relationship_level("doc_emiko") == 0, "Emiko introduction did not establish the Lv0 acquaintance")
	emiko_game.advance_story_to_future_day(1, 780)
	expect(emiko_game.day_number() == 2 and emiko_game.clock_text() == "13:00", "Emiko Lv1 appointment did not advance to the next day at 13:00")
	expect(finish_event(emiko_game, "emiko_lv1_first_operation"), "Emiko Lv1 operation could not complete")
	expect(emiko_game.relationship_level("doc_emiko") == 1, "Emiko Lv1 operation did not establish Lv1")
	emiko_game.archived_player_effects.skill = 20
	expect(not emiko_game.character_event_available(emiko_lv2), "Emiko Lv2 ignored the seven-day delay")
	emiko_game.advance_story_to_future_day(7, 780)
	expect(emiko_game.character_event_available(emiko_lv2), "Emiko Lv2 did not unlock at skill 70 after seven days")
	print("CHARACTER EVENTS: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
