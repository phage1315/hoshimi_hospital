extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
var failures := 0
var checks := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var content = Loader.new()
	expect(content.load_all(), "Patient bundles failed to load")
	expect(content.collections.patients.size() == 7, "Patient index did not load all seven patients")
	expect(content.collections.encounters.size() == 7, "Shared encounter template did not generate seven encounters")
	expect(content.collections.preops.size() == 7, "Shared preop template did not generate seven preops")
	var ids: Array[String] = []
	for patient in content.collections.patients:
		ids.append(str(patient.id))
		expect(patient.visuals.portraits.size() >= 17, "Patient bundle exposes fewer than 17 required portrait slots: " + patient.id)
		expect(patient.reaction_lines.size() == 27, "Patient bundle does not expose 27 core reactions: " + patient.id)
		expect(patient.reaction_variants.size() == 13, "Patient bundle does not expose 13 reaction groups: " + patient.id)
		for portrait_path in patient.visuals.portraits.values():
			var resource_path := "res://" + str(portrait_path)
			expect(ResourceLoader.exists(resource_path), "Patient-bundle portrait is missing: " + resource_path)
			expect(load(resource_path) is Texture2D, "Patient-bundle portrait is not a texture: " + resource_path)
	ids.sort()
	expect(ids == ["patient_ann", "patient_emi", "patient_emi_higashikawa", "patient_gigi", "patient_miki", "patient_rie", "patient_sora"], "Patient bundle IDs changed")
	for patient in content.collections.patients:
		var short_id: String = str(patient.id).trim_prefix("patient_")
		var encounter: Dictionary = content.find_record("encounters", "visit_" + short_id)
		var preop: Dictionary = content.find_record("preops", "preop_" + short_id)
		expect(str(encounter.get("patient_id", "")) == patient.id, "Generated encounter belongs to the wrong patient: " + patient.id)
		expect(str(preop.get("patient_id", "")) == patient.id and str(preop.get("encounter_id", "")) == "visit_" + short_id, "Generated preop links are wrong: " + patient.id)
		expect(preop.get("stages", []).size() == 25, "Generated preop lost shared stages: " + patient.id)
		for stage in preop.get("stages", []):
			expect(not str(stage.get("prompt", "")).is_empty(), "Patient preop prompt is missing: %s/%s" % [patient.id, stage.get("id", "")])
	var sora_encounter: Dictionary = content.find_record("encounters", "visit_sora")
	var sora_undress: Dictionary = {}
	for stage in sora_encounter.stages:
		if stage.id == "exam_undress_decision":
			sora_undress = stage
	expect(str(sora_undress.get("prompt", "")).begins_with("「全部脱掉？"), "Sora's patient-owned examination dialogue was not applied")
	var miki_encounter: Dictionary = content.find_record("encounters", "visit_miki")
	var miki_visual_actions := 0
	for stage in miki_encounter.stages:
		if stage.id != "exam_undress_decision":
			continue
		for action in stage.actions:
			if action.id in ["authoritative_full_undress", "gentle_full_undress", "threaten_full_undress"] and action.get("visual_pool_id", "") == "full_undress_basic_exam_patient_miki":
				miki_visual_actions += 1
	expect(miki_visual_actions == 3, "Miki's exclusive examination CG mapping was not restored")
	var rie_encounter: Dictionary = content.find_record("encounters", "visit_rie")
	var rie_visual_actions := 0
	for stage in rie_encounter.stages:
		if stage.id != "exam_undress_decision":
			continue
		for action in stage.actions:
			if action.id in ["authoritative_full_undress", "gentle_full_undress", "threaten_full_undress"] and action.get("visual_pool_id", "") == "full_undress_basic_exam_patient_rie":
				rie_visual_actions += 1
	expect(rie_visual_actions == 3, "Rie's exclusive examination CG mapping was not restored")
	expect(not content.find_record("examination_cg_pools", "full_undress_basic_exam_patient_miki").is_empty(), "Patient-owned examination CG pool was not merged")
	expect(not content.find_record("examination_cg_pools", "full_undress_basic_exam_patient_rie").is_empty(), "Rie's patient-owned examination CG pool was not merged")
	expect(not content.find_record("ward_preparation_cg_pools", "ward_enema_patient_gigi").is_empty(), "Patient-owned ward CG pool was not merged")
	expect(not content.find_record("ward_preparation_cg_pools", "ward_enema_patient_emi").is_empty(), "Emi's patient-owned enema CG pool was not merged")
	expect(not content.find_record("ward_preparation_cg_pools", "scalpel_ready_patient_emi").is_empty(), "Emi's patient-owned scalpel-ready CG pool was not merged")
	expect(not content.find_record("ward_preparation_cg_pools", "scalpel_ready_patient_sora").is_empty(), "Sora's patient-owned scalpel-ready CG pool was not merged")
	expect(not content.find_record("ward_preparation_cg_pools", "scalpel_ready_patient_miki").is_empty(), "Miki's patient-owned scalpel-ready CG pool was not merged")
	expect(not content.find_record("ward_preparation_cg_pools", "ward_skin_prep_patient_rie").is_empty(), "Rie's patient-owned skin-prep CG pool was not merged")
	expect(not content.find_record("ward_preparation_cg_pools", "urinary_catheterization_patient_rie").is_empty(), "Rie's patient-owned catheterization CG pool was not merged")
	var rie_disinfection_pool: Dictionary = content.find_record("ward_preparation_cg_pools", "skin_disinfection_patient_rie")
	expect(not rie_disinfection_pool.is_empty(), "Rie's patient-owned disinfection CG pool was not merged")
	expect(rie_disinfection_pool.get("action_ids", []) == ["skin_disinfection"] and rie_disinfection_pool.get("patient_ids", []) == ["patient_rie"], "Rie's disinfection CG trigger or patient scope changed")
	expect(rie_disinfection_pool.get("presentation", "") == "fullscreen", "Rie's disinfection CG is not fullscreen")
	var rie_disinfection_paths: Array = rie_disinfection_pool.get("paths", [])
	expect(rie_disinfection_paths.size() == 1, "Rie's disinfection CG pool must contain one image")
	if rie_disinfection_paths.size() == 1:
		var rie_disinfection_path := "res://" + str(rie_disinfection_paths[0])
		expect(ResourceLoader.exists(rie_disinfection_path) and load(rie_disinfection_path) is Texture2D, "Rie's disinfection CG texture is missing")
	expect(not content.find_record("ward_preparation_cg_pools", "sterile_draping_patient_rie").is_empty(), "Rie's patient-owned sterile-draping CG pool was not merged")
	expect(not content.find_record("ward_preparation_cg_pools", "scalpel_ready_patient_rie").is_empty(), "Rie's patient-owned scalpel-ready CG pool was not merged")
	var emi: Dictionary = content.find_record("patients", "patient_emi")
	expect(str(emi.visuals.portraits.get("splash/epidural_anesthesia", "")).ends_with("/patient_emi/epidural.png"), "Emi's epidural-anesthesia splash was not merged into her patient bundle")
	var rie: Dictionary = content.find_record("patients", "patient_rie")
	var rie_pre_induction_path := str(rie.visuals.portraits.get("splash/general_anesthesia_pre_induction", ""))
	expect(rie_pre_induction_path.ends_with("/patient_rie/general_pre_induction.png"), "Rie's pre-induction general-anesthesia splash was not merged into her patient bundle")
	expect(ResourceLoader.exists("res://" + rie_pre_induction_path) and load("res://" + rie_pre_induction_path) is Texture2D, "Rie's pre-induction general-anesthesia splash texture is missing")
	var game = GameState.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions)
	expect(game.patient_cases.size() == content.collections.patients.size(), "Generated patients did not all receive random cases")
	for patient in content.collections.patients:
		var assigned_case: Dictionary = game.patient_case(patient.id)
		var short_id: String = str(patient.id).trim_prefix("patient_")
		expect(not assigned_case.is_empty(), "Generated patient received no random case: " + patient.id)
		expect(game.definitions["visit_" + short_id].title == assigned_case.title, "Generated encounter did not adopt its random case: " + patient.id)
		expect(game.preop_definitions["preop_" + short_id].surgery_id == assigned_case.surgery_id, "Generated preop did not adopt the case surgery: " + patient.id)
	print("Patient bundle checks: %s, failures: %s" % [checks, failures])
	quit(1 if failures else 0)
