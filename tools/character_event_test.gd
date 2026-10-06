extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
var content = Loader.new()
var checks := 0
var failures := 0

class FakePreparation:
	extends RefCounted
	var flags: Array = []
	var minutes := 0
	var player_effects: Dictionary = {}
	var player_effect_history: Array = []
	var anesthesia := "未麻醉"
	var team: Dictionary = {}
	var last_staff_id := ""
	var last_staff_role := ""
	var feedback_speaker := "narrator"
	var feedback := ""
	func surgery_in_progress() -> bool:
		return false

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
	expect(content.collections.character_events.size() == 40, "Expected retired Aoi/Haru Lv.1 chains to stay removed while new authored events remain loaded")
	var game = new_game()
	expect(game.next_character_event_at("or").get("id", "") != "moe_wrong_changing_room", "Preop-stage event leaked into ordinary operating-room entry")
	expect(game.next_character_event_for_preop_stage("changing").is_empty(), "Moe changing-room event appeared on day one")
	expect(game.next_character_event_for_preop_stage("ward").is_empty(), "Moe changing-room event appeared at the wrong preop stage")
	var moe_day_two = new_game()
	moe_day_two.advance_story_to_future_day(1, 540)
	expect(moe_day_two.day_number() == 2 and moe_day_two.next_character_event_for_preop_stage("changing").get("id", "") == "moe_wrong_changing_room", "Moe changing-room event did not unlock on day two")
	expect(not game.relation_for("doc_aoi").has("trust") and not game.relation_for("doc_aoi").has("respect") and game.relation_for("doc_aoi").has("affection") and game.relation_for("doc_aoi").has("familiarity"), "Retired relationship metrics were not removed")
	var retired_event_ids := [
		"aoi_01_cold_tea", "aoi_02_blank_chart", "aoi_03_no_answer", "aoi_04_lit_window",
		"haru_01_half_sandwich", "haru_02_handoff_line", "haru_03_no_problem", "haru_04_after_mask",
	]
	for event_id in retired_event_ids:
		expect(not game.character_event_definitions.has(event_id), "Retired character event is still loaded: %s" % event_id)
	expect(game.character_events_for("doc_aoi").is_empty(), "Aoi's retired Lv.1 event chain is still discoverable")
	expect(game.character_events_for("nurse_haru").is_empty(), "Haru's retired Lv.1 event chain is still discoverable")
	expect(game.next_rank_slot("doc_aoi").get("event_id", "").is_empty(), "Aoi's Lv.1 slot still references the retired event")
	expect(game.next_rank_slot("nurse_haru").get("event_id", "").is_empty(), "Haru's Lv.1 slot still references the retired event")

	# Miyuki is experienced in nursing and only new to Hoshimi's local workflow.
	var yui_game = new_game()
	var yui_intro = yui_game.start_character_event("intro_nurse_yui")
	expect(yui_intro != null and yui_intro.current().text.contains("护理工作并不是第一天"), "Miyuki's introduction still presents her as a novice nurse")
	if yui_intro != null:
		expect(yui_game.choose_character_event("work"), "Miyuki work-focused introduction branch failed")
		expect(yui_intro.current().text.contains("基础护理和患者转运不用担心"), "Miyuki's introduction did not establish her existing competence")
		expect(yui_game.choose_character_event("end_1"), "Miyuki introduction could not finish")
	expect(yui_game.staff_is_met("nurse_yui"), "Miyuki introduction did not mark her as met")

	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame

	# Regression: event portraits must ignore their 1024×1536 source minimum
	# before applying authored display size and position.
	app.game.reset()
	app.game.advance_story_to_future_day(1, 540)
	expect(app.game.start_character_event("moe_wrong_changing_room") != null, "Moe changing-room event could not start for portrait regression test")
	app.show_character_event()
	app.choose_character_event("continue_enter")
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
	emiko_game.surgery_xp = emiko_game.surgery_xp_for_level(56)
	expect(emiko_game.character_event_available(emiko_intro), "Emiko introduction did not unlock at skill 56")
	expect(finish_event(emiko_game, "emiko_intro_rumored_hands"), "Emiko introduction could not complete")
	expect(emiko_game.staff_is_met("doc_emiko") and emiko_game.relationship_level("doc_emiko") == 0, "Emiko introduction did not establish the Lv0 acquaintance")
	emiko_game.advance_story_to_future_day(1, 780)
	expect(emiko_game.day_number() == 2 and emiko_game.clock_text() == "13:00", "Emiko Lv1 appointment did not advance to the next day at 13:00")
	expect(finish_event(emiko_game, "emiko_lv1_first_operation"), "Emiko Lv1 operation could not complete")
	expect(emiko_game.relationship_level("doc_emiko") == 1, "Emiko Lv1 operation did not establish Lv1")
	emiko_game.surgery_xp = emiko_game.surgery_xp_for_level(70)
	expect(not emiko_game.character_event_available(emiko_lv2), "Emiko Lv2 ignored the seven-day delay")
	emiko_game.advance_story_to_future_day(7, 780)
	expect(emiko_game.character_event_available(emiko_lv2), "Emiko Lv2 did not unlock at skill 70 after seven days")

	# Asuka's identity stays hidden through the scrub-sink encounter and the
	# postoperative hint. The encounter requires career progress and the actual
	# hand-scrub action; her office introduction waits until the following day.
	var asuka_game = new_game()
	var fake_preparation = FakePreparation.new()
	fake_preparation.flags = ["hands_ready"]
	asuka_game.active_preop_id = "test_preop"
	asuka_game.preops["test_preop"] = fake_preparation
	expect(not asuka_game.staff_is_met("doc_asuka"), "Asuka should begin unknown")
	expect(asuka_game.next_character_event_for_preop_stage("changing").is_empty(), "Asuka encounter ignored its career gate")
	asuka_game.completed_surgeries_total = 2
	fake_preparation.flags = []
	expect(asuka_game.next_character_event_for_preop_stage("changing").is_empty(), "Asuka encounter appeared before hand scrubbing")
	fake_preparation.flags = ["hands_ready"]
	expect(asuka_game.next_character_event_for_preop_stage("changing").get("id", "") == "asuka_scrub_sink_encounter", "Asuka scrub-sink encounter did not unlock")
	expect(asuka_game.character_event_definitions.asuka_scrub_sink_encounter.background_id == "scrub_area", "Asuka scrub-sink encounter did not use the dedicated scrub-area background")
	expect(not content.find_record("backgrounds", "scrub_area").is_empty(), "Dedicated scrub-area background was not loaded")
	expect(finish_event(asuka_game, "asuka_scrub_sink_encounter"), "Asuka scrub-sink encounter could not complete")
	expect(not asuka_game.staff_is_met("doc_asuka") and asuka_game.relation_for("doc_asuka").flags.has("asuka_identity_unknown"), "Asuka identity was revealed during the first encounter")
	expect(asuka_game.next_character_event_for_preop_stage("surgery_result").get("id", "") == "asuka_adjacent_operation_reveal", "Asuka postoperative identity hint did not unlock")
	expect(finish_event(asuka_game, "asuka_adjacent_operation_reveal"), "Asuka postoperative identity hint could not complete")
	expect(not asuka_game.character_event_available(asuka_game.character_event_definitions.intro_doc_asuka_director_office), "Asuka office reveal ignored the next-day delay")
	asuka_game.advance_story_to_future_day(1, 540)
	expect(asuka_game.next_character_event_at("director_office").get("id", "") == "intro_doc_asuka_director_office", "Asuka office reveal did not unlock the next day")
	var asuka_office_definition: Dictionary = asuka_game.character_event_definitions.intro_doc_asuka_director_office
	expect(asuka_office_definition.outfit == "white_coat", "Asuka office reveal did not use her established physician outfit")
	expect(asuka_office_definition.gallery.path == "assets/events/character_events/asuka/director_office_reveal.png", "Asuka office reveal did not register its gallery CG")
	expect(asuka_office_definition.nodes[0].cg_path == asuka_office_definition.gallery.path, "Asuka office reveal opening did not use its fullscreen CG")
	expect(ResourceLoader.exists("res://" + str(asuka_office_definition.gallery.path)), "Asuka office reveal CG resource is missing")
	expect(finish_event(asuka_game, "intro_doc_asuka_director_office"), "Asuka office reveal could not complete")
	var asuka_relation: Dictionary = asuka_game.relation_for("doc_asuka")
	expect(asuka_game.staff_is_met("doc_asuka") and asuka_relation.flags.has("asuka_identity_known") and not asuka_relation.flags.has("asuka_identity_unknown"), "Asuka identity flags did not settle after the reveal")
	asuka_game.preops.erase("test_preop")
	asuka_game.active_preop_id = ""
	var asuka_snapshot: Dictionary = asuka_game.snapshot()
	var asuka_clone = new_game()
	expect(asuka_clone.restore(JSON.parse_string(JSON.stringify(asuka_snapshot))) and asuka_clone.relation_for("doc_asuka").flags == asuka_relation.flags, "Asuka reveal state did not survive save/load")
	var legacy_asuka_game = new_game()
	var legacy_before_asuka: Dictionary = legacy_asuka_game.snapshot()
	legacy_before_asuka.version = 22
	legacy_before_asuka.erase("completed_surgeries_total")
	legacy_before_asuka.relationship_state.erase("doc_asuka")
	var migrated_asuka_game = new_game()
	expect(not migrated_asuka_game.restore(JSON.parse_string(JSON.stringify(legacy_before_asuka))), "Retired pre-Asuka save was accepted")

	# Artoria remains hidden until both Asuka and Emiko have been formally met.
	# Asuka then names Emiko's other director rival in a separate office scene.
	# Only that referral unlocks Artoria's own office introduction.
	var artoria_game = asuka_game
	expect(not artoria_game.staff_is_met("doc_artoria"), "Artoria should begin unknown")
	var artoria_intro: Dictionary = artoria_game.character_event_definitions.intro_doc_artoria_deputy_office
	var artoria_lv1: Dictionary = artoria_game.character_event_definitions.artoria_lv1_right_position
	var artoria_referral: Dictionary = artoria_game.character_event_definitions.asuka_mentions_artoria_rival
	var artoria_profile: Dictionary = content.find_record("staff", "doc_artoria")
	for portrait_key in ["white_coat/neutral", "casual/neutral", "scrubs/neutral", "sterile/neutral"]:
		var portrait_path: String = "res://" + str(artoria_profile.visuals.portraits[portrait_key])
		var portrait_texture := load(portrait_path) as Texture2D
		expect(portrait_texture != null and portrait_texture.get_size() == Vector2(1024, 1536), "Artoria half-body portrait is missing or has the wrong canvas: " + portrait_key)
	expect(not content.find_record("locations", "artoria_office").is_empty() and artoria_profile.presence.fixed_locations.has("artoria_office"), "Artoria's dedicated office is missing")
	expect(content.find_record("locations", "artoria_office").name == "副部长办公室", "Artoria's map label is too long")
	expect(not artoria_game.character_event_available(artoria_referral) and not artoria_game.character_event_available(artoria_intro), "Artoria referral unlocked before Emiko was met")
	artoria_game.surgery_xp = artoria_game.surgery_xp_for_level(56)
	expect(finish_event(artoria_game, "emiko_intro_rumored_hands"), "Could not meet Emiko before Artoria's referral")
	expect(artoria_game.next_character_event_at("director_office").get("id", "") == "asuka_mentions_artoria_rival", "Asuka did not mention Emiko's other rival after both meetings")
	expect(not artoria_game.character_event_available(artoria_intro), "Artoria office unlocked before Asuka named her")
	expect(finish_event(artoria_game, "asuka_mentions_artoria_rival"), "Asuka's Artoria referral could not complete")
	expect(artoria_game.relation_for("doc_asuka").flags.has("asuka_introduced_artoria_rival"), "Asuka referral flag was not recorded")
	expect(artoria_game.next_character_event_at("artoria_office").get("id", "") == "intro_doc_artoria_deputy_office", "Artoria introduction did not occupy her own office")
	expect(finish_event(artoria_game, "intro_doc_artoria_deputy_office"), "Artoria office introduction could not complete")
	var artoria_relation: Dictionary = artoria_game.relation_for("doc_artoria")
	expect(artoria_game.staff_is_met("doc_artoria") and artoria_game.relationship_level("doc_artoria") == 0, "Artoria introduction did not establish the Lv0 acquaintance")
	expect("doc_artoria" not in artoria_game.known_staff_ids(), "Artoria became selectable before her Lv1 team unlock")
	expect(artoria_game.next_character_event_at("artoria_office").get("id", "") == "artoria_lv1_right_position", "Artoria Lv1 allocation event did not unlock after the introduction")
	expect(artoria_lv1.gallery.path == "assets/events/character_events/artoria/right_position.png" and artoria_lv1.gallery.show_on_complete, "Artoria Lv1 reward CG is not configured")
	expect(ResourceLoader.exists("res://" + str(artoria_lv1.gallery.path)), "Artoria Lv1 reward CG resource is missing")
	var artoria_event = artoria_game.start_character_event("artoria_lv1_right_position")
	while artoria_event != null and not artoria_event.completed:
		var artoria_choice := "fit_each_stage" if artoria_event.current().id == "leadership_question" else str(artoria_event.current().choices[0].id)
		expect(artoria_game.choose_character_event(artoria_choice), "Artoria Lv1 choice failed: " + artoria_choice)
	expect(artoria_game.relationship_level("doc_artoria") == 1 and artoria_relation.flags.has("artoria_lv1_complete"), "Artoria allocation event did not establish Lv1")
	expect(artoria_relation.flags.has("artoria_director_rival_established") and artoria_relation.flags.has("artoria_noticed_leadership_thinking"), "Artoria Lv1 choices did not record the rivalry and leadership evaluation")
	expect(artoria_relation.unlocked_benefits.has("unlock_artoria_surgical_team") and "doc_artoria" in artoria_game.known_staff_ids(), "Artoria Lv1 did not unlock surgical-team eligibility")

	# Shiori begins unknown, becomes available as a limited assistant after her
	# clinic introduction, and keeps the authored internal-medicine profile.
	var shiori_game = new_game()
	var shiori_profile: Dictionary = content.find_record("staff", "doc_shiori")
	expect(not shiori_game.staff_is_met("doc_shiori") and "doc_shiori" not in shiori_game.known_staff_ids(), "Shiori should begin unknown and unavailable")
	expect(shiori_profile.surgical_roles == ["assistant_surgeon"] and shiori_profile.surgery_proficiency == "limited", "Shiori escaped her limited assistant role")
	expect(shiori_profile.presence.fixed_locations == ["clinic", "ward"] and shiori_profile.presence.random_locations == ["lounge", "rooftop"], "Shiori presence schedule is wrong")
	for portrait_key in ["white_coat/neutral", "casual/neutral", "scrubs/neutral", "sterile/neutral"]:
		var shiori_portrait := load("res://" + str(shiori_profile.visuals.portraits[portrait_key])) as Texture2D
		expect(shiori_portrait != null and shiori_portrait.get_size() == Vector2(1024, 1536), "Shiori half-body portrait is missing or has the wrong canvas: " + portrait_key)
	expect(not shiori_game.character_event_available(shiori_game.character_event_definitions.intro_doc_shiori_whole_patient), "Shiori appeared before the player completed any surgery")
	shiori_game.completed_surgeries_total = 2
	expect(not shiori_game.character_event_available(shiori_game.character_event_definitions.intro_doc_shiori_whole_patient), "Shiori appeared after only two completed surgeries")
	shiori_game.completed_surgeries_total = 3
	expect(shiori_game.next_character_event_at("clinic").get("id", "") == "intro_doc_shiori_whole_patient", "Shiori clinic introduction did not unlock after three surgeries")
	expect(shiori_game.next_character_event_at("ward").get("id", "") == "intro_doc_shiori_whole_patient_ward", "Shiori ward introduction did not unlock after three surgeries")
	expect(finish_event(shiori_game, "intro_doc_shiori_whole_patient"), "Shiori clinic introduction could not complete")
	expect(shiori_game.staff_is_met("doc_shiori") and "doc_shiori" in shiori_game.known_staff_ids(), "Shiori did not unlock for the surgical team after meeting")
	expect(not shiori_game.character_event_available(shiori_game.character_event_definitions.intro_doc_shiori_whole_patient_ward), "Shiori alternate introduction remained available after meeting")
	expect(shiori_game.relation_for("doc_shiori").flags.has("met_doc_shiori") and shiori_game.relation_for("doc_shiori").flags.has("shiori_past_known"), "Shiori introduction or former-goddess reveal flag was not recorded")
	var shiori_ward_game = new_game()
	shiori_ward_game.completed_surgeries_total = 3
	expect(finish_event(shiori_ward_game, "intro_doc_shiori_whole_patient_ward") and shiori_ward_game.staff_is_met("doc_shiori"), "Shiori ward introduction could not establish the acquaintance")

	# Aqua remains hidden until the player has completed a gynecology operation.
	# Her acquaintance still leaves the expert director locked until the fifth
	# female-pelvic operation and the authored Lv1 bond event.
	var aqua_game = new_game()
	var aqua_profile: Dictionary = content.find_record("staff", "doc_aqua")
	expect(not aqua_game.staff_is_met("doc_aqua") and "doc_aqua" not in aqua_game.known_staff_ids(), "Aqua should begin unknown and unavailable")
	expect(aqua_profile.surgical_roles == ["primary_surgeon", "assistant_surgeon"] and aqua_profile.surgery_proficiency == "expert", "Aqua's gynecology-director surgical profile is wrong")
	for portrait_key in ["white_coat/neutral", "scrubs/neutral", "sterile/neutral"]:
		var aqua_portrait := load("res://" + str(aqua_profile.visuals.portraits[portrait_key])) as Texture2D
		expect(aqua_portrait != null and aqua_portrait.get_size() == Vector2(1024, 1536), "Aqua half-body portrait is missing or has the wrong canvas: " + portrait_key)
	expect(not aqua_game.character_event_available(aqua_game.character_event_definitions.aqua_intro_exam_chair), "Aqua introduction ignored the gynecology-surgery gate")
	aqua_game.completed_surgeries_total = 4
	aqua_game.completed_surgeries_by_group = {"general_abdominal": 4}
	expect(not aqua_game.character_event_available(aqua_game.character_event_definitions.aqua_intro_exam_chair), "Non-gynecology operations unlocked Aqua")
	aqua_game.completed_surgeries_by_group["female_pelvic"] = 1
	expect(aqua_game.next_character_event_at("gynecology_exam").get("id", "") == "aqua_intro_exam_chair", "Aqua introduction did not unlock after one gynecology operation")
	expect(finish_event(aqua_game, "aqua_intro_exam_chair"), "Aqua examination-chair introduction could not complete")
	expect(aqua_game.staff_is_met("doc_aqua") and "doc_aqua" not in aqua_game.known_staff_ids(), "Aqua became selectable before Lv1")
	expect(not aqua_game.character_event_available(aqua_game.character_event_definitions.aqua_lv1_gyne_obsession), "Aqua Lv1 ignored the five-operation gate")
	aqua_game.completed_surgeries_total = 8
	aqua_game.completed_surgeries_by_group["female_pelvic"] = 5
	expect(aqua_game.character_event_available(aqua_game.character_event_definitions.aqua_lv1_gyne_obsession), "Aqua Lv1 did not unlock after five gynecology operations")
	expect(finish_event(aqua_game, "aqua_lv1_gyne_obsession"), "Aqua Lv1 gynecology event could not complete")
	expect(aqua_game.relationship_level("doc_aqua") == 1 and "doc_aqua" in aqua_game.known_staff_ids(), "Aqua Lv1 did not unlock her surgical-team role")
	expect(aqua_game.relation_for("doc_aqua").unlocked_benefits.has("unlock_aqua_surgical_team"), "Aqua team-unlock benefit was not recorded")
	var aqua_snapshot: Dictionary = aqua_game.snapshot()
	var aqua_clone = new_game()
	expect(aqua_clone.restore(JSON.parse_string(JSON.stringify(aqua_snapshot))) and aqua_clone.completed_surgeries_by_group.get("female_pelvic", 0) == 5, "Aqua specialty progress did not survive save restore")

	# Hiroko's Lv1 chain requires both nurses to be known and at least one
	# completed operation. Part A changes Moe as well as Hiroko; Part B waits a
	# full day, establishes Lv1 and unlocks the persistent OR callback.
	var hiroko_game = new_game()
	hiroko_game.advance_story_to_future_day(1, 780)
	expect(finish_event(hiroko_game, "hiroko_patient_escape"), "Hiroko acquaintance incident could not complete")
	expect(finish_event(hiroko_game, "moe_wrong_changing_room"), "Moe changing-room encounter could not complete")
	hiroko_game.advance_story_to_future_day(1, 780)
	expect(finish_event(hiroko_game, "intro_nurse_hiroko"), "Hiroko introduction could not complete")
	expect(finish_event(hiroko_game, "intro_nurse_moe"), "Moe introduction could not complete")
	hiroko_game.completed_surgeries_total = 1
	var part_a_definition: Dictionary = hiroko_game.character_event_definitions.hiroko_lv1_or_instrument_panic
	expect(part_a_definition.gallery.path == "assets/events/character_events/hiroko/lv1_instrument_lesson.png" and part_a_definition.gallery.show_on_complete, "Hiroko Lv1 part A reward CG is not configured")
	expect(ResourceLoader.exists("res://" + str(part_a_definition.gallery.path)), "Hiroko Lv1 part A reward CG resource is missing")
	expect(hiroko_game.character_event_available(part_a_definition), "Hiroko Lv1 part A did not unlock after both introductions and one surgery")
	var part_a = hiroko_game.start_character_event("hiroko_lv1_or_instrument_panic")
	while part_a != null and not part_a.completed:
		var part_a_choice := "encourage_moe" if part_a.current().id == "moe_understands" else str(part_a.current().choices[0].id)
		expect(hiroko_game.choose_character_event(part_a_choice), "Hiroko Lv1 part A choice failed: " + part_a_choice)
	var hiroko_relation: Dictionary = hiroko_game.relation_for("nurse_hiroko")
	var moe_relation: Dictionary = hiroko_game.relation_for("nurse_moe")
	expect(hiroko_game.relationship_level("nurse_hiroko") == 0 and hiroko_relation.flags.has("hiroko_lv1_part1_complete"), "Hiroko Lv1 part A upgraded the relationship early or omitted its completion flag")
	expect(not moe_relation.has("trust") and not moe_relation.has("respect"), "Supporting-character effects recreated retired relationship metrics")
	var part_b_definition: Dictionary = hiroko_game.character_event_definitions.hiroko_lv1_worth_it
	expect(part_b_definition.gallery.path == "assets/events/character_events/hiroko/lv1_worth_it.png" and part_b_definition.gallery.show_on_complete, "Hiroko Lv1 part B reward CG is not configured")
	expect(ResourceLoader.exists("res://" + str(part_b_definition.gallery.path)), "Hiroko Lv1 part B reward CG resource is missing")
	expect(not hiroko_game.character_event_available(part_b_definition), "Hiroko Lv1 part B ignored the next-day delay")
	hiroko_game.advance_story_to_future_day(1, 600)
	expect(hiroko_game.next_character_event_at("station").get("id", "") == "hiroko_lv1_worth_it", "Hiroko Lv1 part B did not become the nurse-station event on the next day")
	var part_b = hiroko_game.start_character_event("hiroko_lv1_worth_it")
	while part_b != null and not part_b.completed:
		var part_b_choice := "someone_should_care_for_you" if part_b.current().id == "one_patient" else str(part_b.current().choices[0].id)
		expect(hiroko_game.choose_character_event(part_b_choice), "Hiroko Lv1 part B choice failed: " + part_b_choice)
	expect(hiroko_game.relationship_level("nurse_hiroko") == 1 and hiroko_relation.flags.has("hiroko_lv1_complete"), "Hiroko Lv1 part B did not establish the bond")
	for unlock_flag in ["hiroko_or_interactions_tier1", "hiroko_mentor_micro_events", "moe_training_callbacks", "hiroko_team_invite"]:
		expect(hiroko_relation.flags.has(unlock_flag), "Hiroko Lv1 omitted unlock flag: " + unlock_flag)
	expect(hiroko_relation.unlocked_benefits.has("hiroko_team_invite"), "Hiroko Lv1 did not record its team-invite benefit")

	app.game.reset()
	app.game.relation_for("nurse_hiroko").flags.append("moe_training_callbacks")
	var callback_preparation = FakePreparation.new()
	callback_preparation.team = {"scrub_nurse": "nurse_moe"}
	app.apply_moe_training_callback(callback_preparation, "request_scalpel")
	expect(callback_preparation.last_staff_id == "nurse_moe" and callback_preparation.feedback.contains("移到患者视线之外"), "Moe did not remember Hiroko's instrument-table lesson during a later awake operation")
	print("CHARACTER EVENTS: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
