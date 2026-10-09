extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const PreopView = preload("res://godot/ui/preop_view.gd")

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

func fixture(cg_id: String = "body_type_03", procedure_id: String = "surgery_appendix") -> RefCounted:
	var definition: Dictionary = content.find_record("preops", "preop_sora").duplicate(true)
	definition.surgery_id = procedure_id
	var prep = Preop.new(definition, content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, [], false, content.collections.palpation_profiles)
	prep.stage_id = "procedure_select"
	expect(prep.apply({"kind": "procedure", "id": procedure_id, "palpation_cg_id": cg_id}), "Procedure event rejected a valid palpation CG ID")
	return prep

func run() -> void:
	expect(content.load_all(), "Could not load content")
	expect(PreopView.OR_TABLE_PALPATION_IMAGES.size() == 4, "Palpation body-type pool does not contain four images")
	for cg_id in Preop.OR_TABLE_PALPATION_CG_IDS:
		expect(PreopView.OR_TABLE_PALPATION_IMAGES.has(cg_id), "Palpation view omitted CG ID: " + cg_id)
		expect(ResourceLoader.exists(str(PreopView.OR_TABLE_PALPATION_IMAGES[cg_id])), "Palpation CG asset is missing: " + cg_id)
		expect(PreopView.OR_TABLE_PALPATION_HOTSPOTS.has(cg_id), "Palpation CG has no dedicated hotspot map: " + cg_id)
		var layout: Dictionary = PreopView.palpation_hotspot_layout(cg_id, Rect2(330, 68, 620, 626))
		expect(layout.get("breast", []).size() == 2 and layout.get("nipple", []).size() == 2 and layout.get("chest", []).size() == 1 and layout.get("abdomen", []).size() == 1 and layout.get("genital", []).size() == 1, "Palpation CG hotspot map is incomplete: " + cg_id)
		for region in layout:
			for rect: Rect2 in layout[region]:
				expect(Rect2(330, 68, 620, 626).encloses(rect), "Palpation hotspot escapes its CG bounds: %s/%s" % [cg_id, region])
	var prototype_nipple: Rect2 = PreopView.palpation_hotspot_layout("prototype_v1", Rect2(330, 68, 620, 626)).nipple[0]
	var body_type_02_nipple: Rect2 = PreopView.palpation_hotspot_layout("body_type_02", Rect2(330, 68, 620, 626)).nipple[0]
	expect(prototype_nipple != body_type_02_nipple and body_type_02_nipple.position.y > prototype_nipple.position.y, "Body-specific hotspot calibration collapsed back to one shared map")

	var prep = fixture()
	expect(prep.stage_id == "or_table_palpation" and prep.or_table_palpation_cg_id == "body_type_03", "Procedure selection did not retain its palpation CG")
	var before := {"fear": prep.fear, "pain": prep.pain, "dignity": prep.dignity, "cooperation": prep.cooperation_base, "minutes": prep.minutes}
	expect(prep.apply({"kind": "or_table_palpation", "region": "chest", "intensity": "standard"}), "Chest hotspot event was rejected")
	expect(prep.feedback.contains("胸骨") and prep.pain == before.pain + 2 and prep.fear == before.fear and prep.dignity == before.dignity and prep.cooperation_base == before.cooperation and prep.minutes == before.minutes + 1 and prep.sensory_interaction_xp_bonus == 0, "Generic chest palpation response or effects are wrong")
	expect(prep.palpation_findings_confirmed.is_empty() and prep.last_palpation_confirmation.is_empty(), "Unrelated chest palpation created a medical finding")
	expect(prep.apply({"kind": "or_table_palpation", "region": "abdomen", "intensity": "standard"}), "Primary abdominal palpation was rejected")
	expect(prep.feedback.contains("右边") and prep.palpation_findings_confirmed == ["abdomen"] and prep.last_palpation_confirmation == "abdomen" and prep.sensory_interaction_xp_bonus == 5, "Abdominal profile did not create its first relevant finding or one-time XP bonus")
	var after_first_abdominal := {"fear": prep.fear, "pain": prep.pain, "dignity": prep.dignity, "cooperation": prep.cooperation_base}
	expect(prep.apply({"kind": "or_table_palpation", "region": "abdomen", "intensity": "standard"}), "Repeated abdominal palpation was rejected")
	expect(prep.palpation_findings_confirmed == ["abdomen"] and prep.last_palpation_confirmation.is_empty() and prep.sensory_interaction_xp_bonus == 5, "Repeated primary palpation granted a second medical confirmation or XP bonus")
	expect(prep.fear > after_first_abdominal.fear and prep.pain > after_first_abdominal.pain and prep.cooperation_base < after_first_abdominal.cooperation, "Repeated primary palpation stopped changing patient state")

	var breast = fixture("prototype_v1", "surgery_breast_tumor")
	expect(breast.or_table_palpation_profile_id() == "breast" and breast.or_table_palpation_relevance("breast") == "primary" and breast.or_table_palpation_relevance("chest") == "adjacent", "Breast profile mapping is wrong")
	expect(breast.apply({"kind": "or_table_palpation", "region": "nipple", "intensity": "light"}) and breast.feedback.contains("确认") and breast.palpation_findings_confirmed.has("nipple"), "Breast-profile nipple response fell back to unrelated dialogue")

	var pelvic = fixture("body_type_02", "surgery_hysterectomy")
	expect(pelvic.or_table_palpation_profile_id() == "gynecology_pelvic" and pelvic.or_table_palpation_relevance("abdomen") == "primary" and pelvic.or_table_palpation_relevance("genital") == "adjacent", "Gynecology profile mapping is wrong")
	expect(pelvic.apply({"kind": "or_table_palpation", "region": "genital", "intensity": "standard"}) and pelvic.feedback.contains("知道是检查") and pelvic.palpation_findings_confirmed.is_empty(), "Gynecology adjacent response or reward rule is wrong")

	var thoracic = fixture("body_type_04", "surgery_cabg")
	expect(thoracic.or_table_palpation_profile_id() == "thoracic_cardiac" and thoracic.or_table_palpation_relevance("chest") == "primary" and thoracic.or_table_palpation_relevance("breast") == "adjacent", "Thoracic/cardiac profile mapping is wrong")
	expect(thoracic.apply({"kind": "or_table_palpation", "region": "chest", "intensity": "standard"}) and thoracic.feedback.contains("胸骨") and thoracic.last_palpation_confirmation == "chest", "Thoracic/cardiac primary response was not confirmed")

	var replay = fixture()
	for event in prep.events.slice(1):
		expect(replay.apply(event), "Palpation event did not replay")
	expect(replay.or_table_palpation_cg_id == prep.or_table_palpation_cg_id and replay.or_table_palpation_counts == prep.or_table_palpation_counts and replay.palpation_findings_confirmed == prep.palpation_findings_confirmed, "Palpation CG, hotspot, or finding state changed on replay")

	var invalid = Preop.new(content.find_record("preops", "preop_sora").duplicate(true), content.collections.staff, content.collections.surgeries, content.collections.patients)
	invalid.stage_id = "procedure_select"
	expect(not invalid.apply({"kind": "procedure", "id": "surgery_appendix", "palpation_cg_id": "missing"}), "Unknown palpation CG ID was accepted")
	var legacy = Preop.new(content.find_record("preops", "preop_sora").duplicate(true), content.collections.staff, content.collections.surgeries, content.collections.patients)
	legacy.stage_id = "procedure_select"
	expect(legacy.apply({"kind": "procedure", "id": "surgery_appendix"}) and legacy.or_table_palpation_cg_id == "prototype_v1", "Legacy procedure event did not receive the original palpation CG fallback")

	var scalpel = fixture("body_type_04")
	var scalpel_fear: int = int(scalpel.fear)
	expect(scalpel.apply({"kind": "or_table_scalpel", "region": "chest"}) and scalpel.pain == 100 and scalpel.fear > scalpel_fear and scalpel.flags.has("premature_incision") and scalpel.stage_id == "or_table_scalpel_incident", "Scalpel did not trigger the complete premature-incision state")
	expect(scalpel.apply({"kind": "action", "id": "acknowledge_or_table_scalpel_incident"}) and scalpel.stage_id == "ready", "Premature incision did not force the flow into anesthesia selection")

	var needle = fixture("prototype_v1")
	var needle_before := {"fear": needle.fear, "pain": needle.pain, "dignity": needle.dignity, "cooperation": needle.cooperation_base}
	expect(needle.apply({"kind": "or_table_needle", "region": "breast"}), "Palpation needle event was rejected")
	var needle_after_first := {"fear": needle.fear, "pain": needle.pain, "dignity": needle.dignity, "cooperation": needle.cooperation_base}
	expect(needle.apply({"kind": "or_table_needle", "region": "breast"}), "Repeated palpation needle event was rejected")
	expect(needle.fear - needle_after_first.fear == needle_after_first.fear - needle_before.fear and needle.pain - needle_after_first.pain == needle_after_first.pain - needle_before.pain and needle.sensory_interaction_xp_bonus == 0, "Repeated needle use did not retain its full cumulative penalty or incorrectly granted XP")
	expect(needle.palpation_findings_confirmed.is_empty() and needle.or_table_needle_counts.get("breast", 0) == 2, "Needle misuse created a finding or failed to record repeats")

	var skipped = fixture("body_type_02")
	var skipped_state := [skipped.fear, skipped.pain, skipped.dignity, skipped.cooperation_base]
	expect(skipped.apply({"kind": "or_table_palpation_complete"}) and skipped.stage_id == "ready", "Optional palpation could not be skipped")
	expect([skipped.fear, skipped.pain, skipped.dignity, skipped.cooperation_base] == skipped_state and skipped.palpation_findings_confirmed.is_empty(), "Skipping palpation changed patient state")

	var local = fixture("body_type_03", "surgery_appendix")
	expect(local.anesthesia_target_regions() == ["abdomen"], "Abdominal local-anesthesia target is wrong")
	expect(local.apply({"kind": "or_table_palpation_complete"}) and local.apply({"kind": "action", "id": "choose_local"}) and local.stage_id == "anesthesia_sensory_test", "Local anesthesia did not enter optional sensory testing")
	expect(local.anesthesia_region_covered("abdomen") and not local.anesthesia_region_covered("breast") and local.operative_analgesia_effective(), "Local anesthesia coverage resolver is wrong")
	var local_covered_pain: int = int(local.pain)
	expect(local.apply({"kind": "anesthesia_sensory_test", "tool": "needle", "region": "abdomen"}) and local.pain == local_covered_pain, "Covered pinprick incorrectly added pain")
	expect(local.sensory_interaction_xp_bonus == 5, "Correct covered pinprick did not grant its one-time XP bonus")
	var local_uncovered_pain: int = int(local.pain)
	expect(local.apply({"kind": "anesthesia_sensory_test", "tool": "needle", "region": "breast"}) and local.pain > local_uncovered_pain, "Uncovered pinprick did not add pain")
	expect(local.sensory_interaction_xp_bonus == 5, "Uncovered pinprick incorrectly granted an XP bonus")
	var local_skip_state := [local.fear, local.pain, local.dignity, local.cooperation_base]
	expect(local.apply({"kind": "anesthesia_sensory_test_complete"}) and local.stage_id == "operative_positioning" and [local.fear, local.pain, local.dignity, local.cooperation_base] == local_skip_state, "Completing or skipping sensory testing changed state")
	var local_replay = fixture("body_type_03", "surgery_appendix")
	for event in local.events.slice(1):
		expect(local_replay.apply(event), "Sensory-test event did not replay: " + str(event))
	expect(local_replay.events == local.events and local_replay.stage_id == local.stage_id and local_replay.anesthesia_test_counts == local.anesthesia_test_counts and local_replay.sensory_interaction_xp_bonus == local.sensory_interaction_xp_bonus, "Sensory-test replay changed event or interaction state")

	var epidural_breast = fixture("body_type_04", "surgery_breast_tumor")
	expect(epidural_breast.anesthesia_target_regions() == ["breast"], "Breast local-anesthesia target is wrong")
	expect(epidural_breast.apply({"kind": "or_table_palpation_complete"}) and epidural_breast.apply({"kind": "action", "id": "choose_epidural"}) and epidural_breast.stage_id == "ineffective_epidural_warning", "Ineffective breast epidural did not show its warning")
	expect(not epidural_breast.epidural_effective_for_procedure() and epidural_breast.apply({"kind": "action", "id": "continue_ineffective_epidural"}) and epidural_breast.stage_id == "anesthesia_sensory_test", "Ineffective epidural could not be deliberately continued")
	expect(epidural_breast.anesthesia_region_covered("abdomen") and not epidural_breast.anesthesia_region_covered("breast"), "Epidural region coverage is wrong")
	expect(epidural_breast.operative_without_effective_analgesia() and epidural_breast.anesthesia_crisis_base_risk() == 2 and epidural_breast.crisis_flavor().contains("剧痛"), "Ineffective epidural did not reuse no-anesthesia crisis behavior")
	expect(epidural_breast.apply({"kind": "anesthesia_sensory_test_complete"}), "Ineffective epidural sensory test could not be skipped")
	for action_id in [
		"operative_positioning", "ack_positioning",
		"urinary_catheterization", "ack_catheterization",
		"skin_disinfection", "ack_disinfection",
		"incision_marking", "ack_marking_epidural",
		"start_epidural_surgery", "request_scalpel", "assistant_stabilize",
	]:
		expect(epidural_breast.apply({"kind": "action", "id": action_id}), "Ineffective epidural flow stopped before incision at " + action_id)
	var ineffective_before := [epidural_breast.fear, epidural_breast.pain, epidural_breast.dignity, epidural_breast.cooperation_base]
	expect(epidural_breast.apply({"kind": "action", "id": "incise_epidural"}), "Ineffective epidural incision was rejected")
	expect(epidural_breast.fear == mini(100, ineffective_before[0] + 30) and epidural_breast.pain == mini(100, ineffective_before[1] + 80) and epidural_breast.dignity == maxi(0, ineffective_before[2] - 25) and epidural_breast.cooperation_base == maxi(0, ineffective_before[3] - 30), "Ineffective epidural incision did not reuse no-anesthesia numeric effects")
	expect(epidural_breast.feedback == epidural_breast.patient_reaction("incise_none", ""), "Ineffective epidural incision did not reuse the no-anesthesia reaction")

	var epidural_pelvic = fixture("body_type_02", "surgery_hysterectomy")
	expect(epidural_pelvic.apply({"kind": "or_table_palpation_complete"}) and epidural_pelvic.apply({"kind": "action", "id": "choose_epidural"}) and epidural_pelvic.stage_id == "anesthesia_sensory_test", "Effective pelvic epidural did not enter optional sensory testing")
	expect(epidural_pelvic.epidural_effective_for_procedure() and epidural_pelvic.anesthesia_region_covered("abdomen") and epidural_pelvic.anesthesia_region_covered("genital") and not epidural_pelvic.anesthesia_region_covered("chest"), "Effective epidural coverage is wrong")

	var general = fixture("prototype_v1", "surgery_appendix")
	expect(general.apply({"kind": "or_table_palpation_complete"}) and general.apply({"kind": "action", "id": "choose_general"}) and general.stage_id != "anesthesia_sensory_test", "General anesthesia incorrectly entered sensory testing")
	var none = fixture("prototype_v1", "surgery_appendix")
	expect(none.apply({"kind": "or_table_palpation_complete"}) and none.apply({"kind": "action", "id": "choose_none"}) and none.stage_id != "anesthesia_sensory_test", "No-anesthesia route incorrectly entered sensory testing")

	var test_scalpel = fixture("body_type_03", "surgery_appendix")
	expect(test_scalpel.apply({"kind": "or_table_palpation_complete"}) and test_scalpel.apply({"kind": "action", "id": "choose_local"}), "Could not prepare covered sensory-test scalpel case")
	var test_scalpel_pain: int = int(test_scalpel.pain)
	expect(test_scalpel.apply({"kind": "anesthesia_test_scalpel", "region": "abdomen"}) and test_scalpel.pain == test_scalpel_pain + 1 and test_scalpel.stage_id == "anesthesia_test_scalpel_incident", "Covered sensory-test scalpel response is wrong")
	expect(test_scalpel.apply({"kind": "action", "id": "acknowledge_anesthesia_test_scalpel"}) and test_scalpel.stage_id == "operative_positioning", "Sensory-test scalpel incident did not continue preparation")

	var uncovered_scalpel = fixture("body_type_03", "surgery_appendix")
	expect(uncovered_scalpel.apply({"kind": "or_table_palpation_complete"}) and uncovered_scalpel.apply({"kind": "action", "id": "choose_local"}), "Could not prepare uncovered sensory-test scalpel case")
	expect(uncovered_scalpel.apply({"kind": "anesthesia_test_scalpel", "region": "breast"}) and uncovered_scalpel.pain == 100 and uncovered_scalpel.flags.has("anesthesia_sensory_test_complete") and uncovered_scalpel.stage_id == "anesthesia_test_scalpel_incident", "Uncovered sensory-test scalpel did not cause maximum pain and terminate testing")

	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	PreopView.render(app, thoracic)
	var body_image: TextureRect = app.page.get_node_or_null("PalpationBodyImage")
	expect(body_image != null and body_image.texture.resource_path == str(PreopView.OR_TABLE_PALPATION_IMAGES.body_type_04), "Palpation view displayed the wrong recorded CG")
	var chest_hotspot: Button = app.page.get_node_or_null("PalpationHotspot_chest_0")
	expect(chest_hotspot != null, "Palpation view omitted the chest hotspot")
	if chest_hotspot != null:
		var expected_chest: Rect2 = PreopView.palpation_hotspot_layout("body_type_04", Rect2(330, 68, 620, 626)).chest[0]
		expect(chest_hotspot.position == expected_chest.position and chest_hotspot.size == expected_chest.size, "Rendered hotspot does not use the selected CG's calibration")
	expect(app.page.get_node_or_null("PalpationFindingConfirmed") != null, "Palpation view omitted the one-time finding confirmation")
	expect(app.page.get_node_or_null("PalpationTool_hand") != null and app.page.get_node_or_null("PalpationTool_needle") != null and app.page.get_node_or_null("PalpationTool_scalpel") != null, "Shared body HUD omitted one or more tools")
	app.queue_free()

	print("OR TABLE PALPATION: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures > 0 else 0)
