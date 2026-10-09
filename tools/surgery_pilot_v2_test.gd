extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Preop = preload("res://godot/systems/preop_session.gd")

var content = Loader.new()
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func fixture() -> RefCounted:
	var definition := {
		"id": "surgery_pilot_v2_test", "patient_id": "patient_sora", "encounter_id": "visit_sora", "surgery_id": "surgery_appendix", "start": "surgery_flow",
		"_locale": "zh_CN", "initial_anxiety": 2, "initial_interaction": {"fear": 35, "pain": 0, "dignity": 100, "cooperation": 70},
		"roles": [], "ward_role": {"id": "ward_nurse"}, "preparations": [], "max_optional_preparations": 0,
		"care_reassurance_threshold": 70, "completion": "surgery_complete",
		"stages": [{"id": "surgery_flow", "title": "Pilot", "scene": "operating_room", "kind": "surgery_flow", "speaker": "narrator", "next": "surgery_flow", "actions": [], "background_id": "operating_room"}],
	}
	var prep = Preop.new(definition, content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions)
	prep.procedure_id = "surgery_appendix"
	prep.procedure_name = "开腹阑尾切除"
	prep.initialize_procedure_state()
	prep.stage_id = "surgery_flow"
	prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin"}
	prep.flags.append("anesthetized")
	return prep

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	expect(content.load_all(), "Content load failed")
	var expected := {"surgery_appendix": [9, 11], "surgery_open_cholecystectomy": [10, 12], "surgery_open_inguinal_hernia": [9, 11]}
	for surgery_id in expected:
		var surgery: Dictionary = content.find_record("surgeries", surgery_id)
		var fixed := 0
		var correction_count := 0
		var fixed_progress_total := 0
		for stage in surgery.stages:
			if str(stage.get("stage_kind", "fixed")) == "conditional_correction":
				correction_count += 1
				expect(int(stage.get("progress_delta", -1)) == 0 and stage.get("once_per_episode", false), "%s correction stage metadata is incomplete" % surgery_id)
			else:
				fixed += 1
				fixed_progress_total += int(stage.get("progress_delta", 0))
		expect(surgery.stages.size() == expected[surgery_id][0] + 1, "%s raw stage count is incorrect" % surgery_id)
		expect(fixed == expected[surgery_id][0] and correction_count == 1, "%s fixed/correction stage split is incorrect" % surgery_id)
		expect(surgery.fixed_stage_progress.size() == fixed and fixed_progress_total == 100, "%s fixed progress does not total 100" % surgery_id)
		expect(surgery.case_variants.size() == 2 and surgery.initial_state.bleeding == 0, "%s pilot state/variant data is incomplete" % surgery_id)
		for stage in surgery.stages:
			if str(stage.get("stage_kind", "fixed")) == "conditional_correction":
				continue
			var option_count := stage.options.size()
			expect(option_count == 1 if stage.kind == "confirm" else option_count in [2, 3], "%s stage option density is invalid" % stage.id)
		var prep = fixture()
		prep.procedure_id = surgery_id
		prep.procedure_name = str(surgery.name)
		prep.initialize_procedure_state()
		var guard := 0
		while not prep.flags.has("procedure_flow_complete") and guard < 20:
			guard += 1
			var current: Dictionary = prep.surgery_flow_step()
			expect(not current.is_empty(), "%s flow ended without a stage" % surgery_id)
			if current.is_empty():
				break
			var chosen: Dictionary = current.options[0]
			expect(prep.apply({"kind": "surgery_step", "id": chosen.id}), "%s rejected its first valid option at %s" % [surgery_id, current.id])
			if prep.awaiting_flow_acknowledgement:
				expect(prep.apply({"kind": "flow_acknowledge"}), "%s could not acknowledge %s" % [surgery_id, current.id])
		expect(guard < 20 and prep.procedure_state.progress == 100, "%s did not finish at exactly 100 progress" % surgery_id)
		print("SURGERY PILOT V2: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
