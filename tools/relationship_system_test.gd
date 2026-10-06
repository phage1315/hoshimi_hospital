extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")

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

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events)
	expect(game.known_staff_ids().is_empty(), "A new game should not know optional staff before the prologue")
	game.meet_staff("doc_aoi")
	game.meet_staff("nurse_haru")
	game.meet_staff("doc_sayaka")
	game.meet_staff("doc_emiko")
	expect(game.staff_is_met("doc_aoi") and game.relationship_level("doc_aoi") == 0, "Acquaintance should not establish a bond level")
	expect(not game.relation_for("doc_aoi").has("trust") and not game.relation_for("doc_aoi").has("respect") and game.relation_for("doc_aoi").has("affection"), "Relationship state still exposes trust or respect")
	expect(game.surgery_familiarity_reward("doc_aoi") == 5 and game.surgery_familiarity_reward("doc_sayaka") == 9, "Per-character surgery familiarity multiplier is incorrect")
	expect(game.date_familiarity_reward("doc_aoi") == 10 and game.date_familiarity_reward("doc_sayaka") == 18, "Per-character date familiarity multiplier is incorrect")
	expect(game.surgery_familiarity_reward("doc_emiko") == 3 and game.date_familiarity_reward("doc_emiko") == 5, "Emiko's 0.5x familiarity multiplier is incorrect")
	game.award_surgery_team_familiarity({"assistant_surgeon": "doc_sayaka", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_haru"})
	expect(game.relation_for("doc_sayaka").familiarity == 9, "Sayaka did not receive her 1.8x shared-surgery familiarity")
	expect(game.relation_for("nurse_haru").familiarity == 5, "Duplicate team-role entries awarded familiarity more than once")
	game.award_surgery_team_familiarity({"assistant_surgeon": "doc_sayaka", "scrub_nurse": "nurse_haru"})
	expect(game.relation_for("doc_sayaka").familiarity == 18 and game.relation_for("nurse_haru").familiarity == 10, "Repeated surgery did not award the fixed per-case familiarity gain")
	expect(game.relation_for("doc_aoi").rank_slots.size() == 5 and game.next_rank_slot("doc_aoi").target_level == 1, "Five bond/rank event slots were not initialized")
	game.add_familiarity("doc_aoi", 99)
	expect(game.relation_for("doc_aoi").familiarity == 99 and not game.rank_ready("doc_aoi"), "Familiarity should grow independently of authored relationship milestones")
	expect(game.next_rank_slot("doc_aoi").get("event_id", "").is_empty(), "Aoi's retired Lv.1 event slot should remain empty until its replacement is authored")
	expect(game.character_events_for("doc_aoi").is_empty(), "Aoi's retired Lv.1 event chain is still discoverable")
	game.complete_rank_up("doc_aoi", "test_rank_01", 1)
	expect(game.relationship_level("doc_aoi") == 1, "A direct test rank-up did not establish Lv.1")
	game.complete_rank_up("doc_aoi", "test_rank_02", 2)
	game.complete_rank_up("doc_aoi", "test_rank_03", 3)
	game.complete_rank_up("doc_aoi", "test_rank_04", 4, "unlock_intimacy_events")
	game.complete_rank_up("doc_aoi", "test_rank_05", 5, "unlock_clinical_practice_patient")
	expect(game.relationship_level("doc_aoi") == 5 and not game.rank_ready("doc_aoi"), "Relationship should stop at Lv.5")
	expect(game.relation_for("doc_aoi").unlocked_benefits.has("unlock_intimacy_events") and game.relation_for("doc_aoi").unlocked_benefits.has("unlock_clinical_practice_patient"), "Lv.4 and Lv.5 relationship benefits were not retained")
	var manami_intro = game.start_character_event("intro_pharmacist_manami")
	expect(manami_intro != null, "Manami acquaintance event did not unlock")
	if manami_intro != null:
		while not manami_intro.completed:
			game.choose_character_event(manami_intro.current().choices[0].id)
	expect(game.staff_is_met("pharmacist_manami"), "Completing an acquaintance event did not mark staff as met")
	expect(game.relationship_level("pharmacist_manami") == 0, "Acquaintance event incorrectly granted a bond level")
	var prep_definition: Dictionary = content.collections.preops[0]
	var prep = Preop.new(prep_definition, content.collections.staff, content.collections.surgeries, content.collections.patients, ["doc_aoi", "nurse_haru", "pharmacist_manami"], true)
	var doctors: Array = prep.candidates("assistant_surgeon")
	expect(doctors.any(func(person: Dictionary): return person.id == "pharmacist_manami"), "Known pharmacist was not treated as a doctor-category team candidate")
	expect(not doctors.any(func(person: Dictionary): return person.id == "doc_rei"), "Unknown doctor appeared in team candidates")
	var manami: Dictionary = content.find_record("staff", "pharmacist_manami")
	expect(manami.visuals.portraits.has("pharmacist/worried") and manami.visuals.portraits.has("sterile/worried"), "Manami worried portrait variants are missing")
	expect(prep.assignment_response("assistant_surgeon", "pharmacist_manami").contains("我只是配药的"), "Manami assignment inner monologue is missing")
	expect(prep.staff_action_response("pharmacist_manami", "assistant_stabilize", "fallback").contains("解剖课"), "Manami advice-seeking inner monologue is missing")
	expect(prep.intraoperative_response("pharmacist_manami", "check_instruments", "fallback", false).contains("屏幕上的组织"), "Manami intraoperative inner monologue is missing")
	expect(prep.intraoperative_response("pharmacist_manami", "confirm_anatomy", "fallback", true).contains("问错总比"), "Manami correction inner monologue is missing")
	var legacy_snapshot: Dictionary = game.snapshot()
	legacy_snapshot.version = 29
	for actor_id in legacy_snapshot.relationship_state:
		legacy_snapshot.relationship_state[actor_id].trust = 37
		legacy_snapshot.relationship_state[actor_id].respect = 42
	var migrated = Game.new()
	migrated.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events)
	expect(not migrated.restore(JSON.parse_string(JSON.stringify(legacy_snapshot))), "Retired save version was accepted despite the deliberate save reset")
	print("RELATIONSHIP SYSTEM: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
