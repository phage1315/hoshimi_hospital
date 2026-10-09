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
	var self_level_gate: Dictionary = game.requirement_evaluation({"type": "relationship_level", "level": 0}, {"actor_id": "doc_aoi"})
	expect(self_level_gate.valid and self_level_gate.met and self_level_gate.current == 0, "Legacy self relationship gate did not use the character-event actor context")
	var cross_level_gate: Dictionary = game.requirement_evaluation({"type": "relationship_level", "actor_id": "doc_sayaka", "minimum": 1})
	expect(cross_level_gate.valid and not cross_level_gate.met and cross_level_gate.actor_id == "doc_sayaka", "Cross-character relationship gate did not report its unmet target")
	game.relation_for("doc_sayaka").level = 1
	cross_level_gate = game.requirement_evaluation({"type": "relationship_level", "actor_id": "doc_sayaka", "minimum": 1, "maximum": 2})
	expect(cross_level_gate.met and cross_level_gate.current == 1, "Cross-character relationship range did not unlock at its lower boundary")
	game.relation_for("doc_sayaka").level = 0
	var attribute_gate: Dictionary = game.requirement_evaluation({"type": "player_attribute", "attribute": "presence", "minimum": -10, "maximum": 10})
	expect(attribute_gate.met and attribute_gate.current == 0 and attribute_gate.minimum == -10 and attribute_gate.maximum == 10, "Player-attribute min/max evaluation is incorrect")
	game.set_story_flag("requirement_evaluator_test", true)
	expect(game.requirement_evaluation({"type": "story_flag", "flag": "requirement_evaluator_test", "value": true}).met, "Character-event story_flag alias was not evaluated")
	expect(game.requirement_evaluation({"type": "flag", "flag": "requirement_evaluator_test", "value": true}).met, "Special-event flag form was not evaluated")
	var gate_report: Dictionary = game.requirements_evaluation([
		{"type": "relationship_level", "actor_id": "doc_aoi", "minimum": 0},
		{"type": "completed_surgeries", "minimum": 1},
	])
	expect(not gate_report.met and gate_report.results.size() == 2 and gate_report.unmet.size() == 1 and gate_report.unmet[0].type == "completed_surgeries", "Requirement report did not expose the single unmet condition")
	var unknown_gate: Dictionary = game.requirement_evaluation({"type": "not_implemented"})
	expect(not unknown_gate.valid and not unknown_gate.met and unknown_gate.reason == "unknown_requirement_type", "Unknown requirement type did not fail closed with diagnostics")
	expect(not game.relation_for("doc_aoi").has("trust") and not game.relation_for("doc_aoi").has("respect") and game.relation_for("doc_aoi").has("affection"), "Relationship state still exposes trust or respect")
	expect(game.surgery_familiarity_reward("doc_aoi") == 4 and game.surgery_familiarity_reward("doc_sayaka") == 9, "Fixed per-character surgery familiarity multiplier is incorrect")
	expect(game.date_familiarity_reward("doc_aoi") == 8 and game.date_familiarity_reward("doc_sayaka") == 18, "Fixed per-character date familiarity multiplier is incorrect")
	expect(game.surgery_familiarity_reward("doc_emiko") == 3 and game.date_familiarity_reward("doc_emiko") == 5, "Emiko's 0.5x familiarity multiplier is incorrect")
	game.set_test_player_attribute("skill", 59)
	expect(is_equal_approx(game.familiarity_gain_multiplier("doc_rei"), 1.0), "Miyama's sub-60 Surgery familiarity band is incorrect")
	game.set_test_player_attribute("skill", 60)
	expect(is_equal_approx(game.familiarity_gain_multiplier("doc_rei"), 1.05), "Miyama's 60 Surgery familiarity boundary is incorrect")
	game.set_test_player_attribute("skill", 90)
	expect(is_equal_approx(game.familiarity_gain_multiplier("doc_rei"), 1.2), "Miyama's 90 Surgery familiarity boundary is incorrect")
	game.set_test_player_attribute("skill", 70)
	game.set_test_player_attribute("presence", 20)
	expect(is_equal_approx(game.familiarity_gain_multiplier("doc_emiko"), 0.85), "Emiko's additive Surgery and Presence bonuses are incorrect")
	game.set_test_player_attribute("presence", 0)
	for boundary in [
		{"skill": 59, "expected": 0.5},
		{"skill": 60, "expected": 0.6},
		{"skill": 70, "expected": 0.7},
		{"skill": 80, "expected": 0.8},
		{"skill": 90, "expected": 0.9},
	]:
		game.set_test_player_attribute("skill", int(boundary.skill))
		expect(is_equal_approx(game.familiarity_gain_multiplier("doc_emiko"), float(boundary.expected)), "Emiko's Surgery affinity boundary is incorrect at %s" % boundary.skill)
	game.set_test_player_attribute("skill", 59)
	for boundary in [
		{"presence": 0, "expected": 0.5},
		{"presence": 1, "expected": 0.6},
		{"presence": 20, "expected": 0.65},
		{"presence": 30, "expected": 0.7},
		{"presence": 60, "expected": 0.8},
	]:
		game.set_test_player_attribute("presence", int(boundary.presence))
		expect(is_equal_approx(game.familiarity_gain_multiplier("doc_emiko"), float(boundary.expected)), "Emiko's Presence affinity boundary is incorrect at %s" % boundary.presence)
	game.set_test_player_attribute("skill", 90)
	game.set_test_player_attribute("presence", 60)
	expect(is_equal_approx(game.familiarity_gain_multiplier("doc_emiko"), 1.2), "Emiko's maximum 1.20 familiarity multiplier is incorrect")
	expect(is_equal_approx(game.familiarity_gain_multiplier("doc_sayaka"), 1.8), "Sayaka's fixed familiarity multiplier changed")
	expect(is_equal_approx(game.familiarity_gain_multiplier("doc_shiori"), 0.85), "Shiori's fixed familiarity multiplier changed")
	expect(is_equal_approx(game.familiarity_gain_multiplier("pharmacist_manami"), 1.3), "Manami's fixed familiarity multiplier changed")
	game.set_test_player_attribute("leadership", 60)
	expect(is_equal_approx(game.familiarity_gain_multiplier("doc_artoria"), 0.8), "Artoria's Leadership 60 boundary is incorrect")
	game.set_test_player_attribute("leadership", 90)
	expect(is_equal_approx(game.familiarity_gain_multiplier("doc_artoria"), 1.1), "Artoria's Leadership 90 boundary is incorrect")
	game.set_test_player_attribute("presence", 60)
	expect(is_equal_approx(game.familiarity_gain_multiplier("nurse_satsuki"), 0.5), "Satsuki's high-Presence familiarity band is incorrect")
	game.set_test_player_attribute("presence", -170)
	expect(is_equal_approx(game.familiarity_gain_multiplier("nurse_satsuki"), 1.3), "Satsuki's -170 Presence familiarity boundary is incorrect")
	game.relation_for("nurse_hiroko").level = 3
	expect(is_equal_approx(game.familiarity_gain_multiplier("nurse_hiroko"), 0.5), "Hiroko's Lv3 familiarity slowdown is incorrect")
	game.relation_for("nurse_hiroko").level = 4
	expect(is_equal_approx(game.familiarity_gain_multiplier("nurse_hiroko"), 1.25), "Hiroko's Lv4 familiarity recovery is incorrect")
	game.relation_for("nurse_moe").level = 0
	expect(is_equal_approx(game.familiarity_gain_multiplier("nurse_moe"), 0.6), "Moe's Lv0 familiarity multiplier is incorrect")
	game.relation_for("nurse_moe").level = 4
	expect(is_equal_approx(game.familiarity_gain_multiplier("nurse_moe"), 1.5), "Moe's Lv4 familiarity multiplier is incorrect")
	game.staff.append({"id": "test_familiarity_overrides", "familiarity_rules": {"base": 0.5, "source_overrides": {"surgery": {"minimum_reward": 4}, "imaging_discussion": {"fixed_reward": 3}}}})
	expect(game.familiarity_reward("test_familiarity_overrides", 5, "surgery") == 4, "Source-specific surgery reward minimum was not applied")
	expect(game.familiarity_reward("test_familiarity_overrides", 99, "imaging_discussion") == 3, "Source-specific fixed familiarity reward was multiplied")
	game.set_test_player_attribute("skill", 50)
	game.set_test_player_attribute("leadership", 50)
	game.set_test_player_attribute("presence", 0)
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
	expect(game.increment_character_progress_counter("nurse_yui", "outpatient_forced_undress") == 1, "Character progress counter did not increment")
	expect(game.increment_character_progress_counter("nurse_yui", "outpatient_forced_undress") == 2, "Character progress counter did not accumulate")
	var counter_gate: Dictionary = game.requirement_evaluation({"type": "progress_counter", "actor_id": "nurse_yui", "counter_id": "outpatient_forced_undress", "minimum": 2})
	expect(counter_gate.valid and counter_gate.met and counter_gate.current == 2, "Progress-counter requirement did not read the persisted character counter")
	game.set_test_character_progress_counter("", "gynecology_case_count", 6)
	expect(is_equal_approx(game.familiarity_gain_multiplier("doc_aqua"), 0.7), "Aqua's six-case familiarity boundary is incorrect")
	game.set_test_character_progress_counter("", "gynecology_case_count", 30)
	expect(is_equal_approx(game.familiarity_gain_multiplier("doc_aqua"), 1.35), "Aqua's thirty-case familiarity boundary is incorrect")
	var counter_snapshot: Dictionary = game.snapshot()
	var counter_restored = Game.new()
	counter_restored.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events)
	expect(counter_restored.restore(JSON.parse_string(JSON.stringify(counter_snapshot))), "A current save with character progress counters did not restore")
	expect(counter_restored.character_progress_counter("nurse_yui", "outpatient_forced_undress") == 2 and counter_restored.character_progress_counter("", "gynecology_case_count") == 30, "Character progress counters changed across save and restore")
	var pre_counter_snapshot: Dictionary = JSON.parse_string(JSON.stringify(counter_snapshot))
	pre_counter_snapshot.erase("character_progress_counters")
	var pre_counter_restored = Game.new()
	pre_counter_restored.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events)
	expect(pre_counter_restored.restore(pre_counter_snapshot), "A same-version save created before character counters were added did not restore")
	expect(pre_counter_restored.character_progress_counters.is_empty(), "A save without character counters did not use the empty compatibility default")
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
