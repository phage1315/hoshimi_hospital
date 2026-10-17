extends SceneTree
## Exercise the real authored V2 nodes through surgery_step/flow_acknowledge.
const Loader = preload("res://godot/scripts/content_loader.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const TARGETS := {
	"surgery_open_cholecystectomy": ["chole_07_liver_bed", "nausea"],
	"surgery_open_abdominal_myomectomy": ["myomectomy_08_repair", "drowsiness"],
}
var content = Loader.new()
var checks := 0
var failures := 0
var han := RegEx.new()

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func fixture(surgery_id: String, mode: String):
	var definition: Dictionary = content.collections.preops[0].duplicate(true)
	var p = Preop.new(definition, content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions)
	p.procedure_id = surgery_id
	p.procedure_name = str(p.current_surgery().name)
	p.initialize_procedure_state()
	p.stage_id = "procedure_flow"
	p.flags.clear()
	p.flags.append(mode)
	p.fear = 0
	p.pain = 0
	p.dignity = 100
	p.cooperation_base = 100
	p.team = {"assistant_surgeon":"doc_aoi", "circulating_nurse":"nurse_haru", "scrub_nurse":"nurse_yui"}
	return p

func play_step(p) -> void:
	var step: Dictionary = p.surgery_flow_step()
	expect(p.apply({"kind":"surgery_step", "id":step.options[0].id}), "Real surgery choice accepted: " + str(step.id))
	expect(p.awaiting_flow_acknowledgement, "Team response shown before patient")
	expect(p.apply({"kind":"flow_acknowledge"}), "Acknowledge team response")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	han.compile("[\\x{3400}-\\x{9fff}]")
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Content loads " + locale)
		for surgery_id in TARGETS:
			var target: String = TARGETS[surgery_id][0]
			var condition_id: String = TARGETS[surgery_id][1]
			var surgery: Dictionary = content.find_record("surgeries", surgery_id)
			var condition: Dictionary = content.find_record("temporary_conditions", condition_id)
			var index := -1
			var occurrences := 0
			for i in range(surgery.stages.size()):
				if condition_id in surgery.stages[i].get("patient_cues", []):
					occurrences += 1
					index = i
			expect(occurrences == 1 and index >= 0, "One authored cue per repaired procedure")
			if index < 0:
				continue
			expect(surgery.stages[index].id == target and surgery.stages[index].stage_kind == "fixed", "Cue is on intended fixed node, not correction")
			for severity in [1, 2, 3]:
				if locale == "en":
					var key := "collections.temporary_conditions.%s.prompts.%s" % [condition_id, severity]
					expect(content.localizer.strings.has(key) and condition.prompts[str(severity)] == content.localizer.strings.get(key), "Explicit English severity prompt")
					expect(han.search(condition.prompts[str(severity)]) == null, "No Chinese in English prompt")
			# Each handling route runs after an actual completed V2 step. Setting
			# the ordinary budget high proves special conditions bypass that cap.
			for action in condition.actions:
				var p = fixture(surgery_id, "local_anesthesia")
				p.procedure_step_index = index
				p.patient_regular_interaction_count = 999
				play_step(p)
				expect(p.active_condition_id == condition_id and p.awaiting_patient_choice, "Condition triggers after team acknowledgement despite ordinary cap")
				expect(p.feedback == condition.prompts["1"], "Displayed patient prompt uses localized authored text")
				expect(p.active_patient_interaction.actions.size() == 4, "All original handling choices preserved")
				if locale == "en":
					expect(han.search(p.temporary_condition_status_text()) == null, "Condition HUD is English")
					for displayed_action in p.active_patient_interaction.actions:
						expect(han.search(displayed_action.label + displayed_action.response) == null, "English choice and response")
				var before: int = p.minutes
				expect(p.apply({"kind":"patient_interaction_action", "id":action.id}), "Existing handling action accepted")
				expect(p.minutes == before + int(action.minutes), "Only authored handling minutes charged")
				var delegate: String = action.get("delegate_role", "")
				if not delegate.is_empty():
					expect(p.last_staff_id == p.team[delegate] and p.feedback_speaker == "staff", "Assigned team member handles condition")
				var ignored: bool = str(action.id).begins_with("ignore_")
				expect(p.active_temporary_conditions.has(condition_id) == ignored, "Treat clears / ignore preserves condition")
				expect(p.apply({"kind":"patient_acknowledge"}), "Continue after patient/staff response")
				expect(p.procedure_step_index > index and p.minutes == before + int(action.minutes), "Stage advances once without duplicate charge")
				if ignored:
					expect(p.active_temporary_conditions[condition_id].severity == 2 and p.active_temporary_conditions[condition_id].remaining_steps == 2, "Ignore escalates and duration ticks once")
					play_step(p)
					expect(p.active_condition_id == condition_id and p.feedback == condition.prompts["2"], "Persistent condition returns on following executed stage")
					expect(p.apply({"kind":"patient_interaction_action", "id":condition.actions[0].id}) and p.apply({"kind":"patient_acknowledge"}), "Persistent condition can be treated")
					expect(p.active_temporary_conditions.is_empty(), "Persistent condition clears")
			# Walk complete authored procedures without injecting/replacing cues.
			for mode in ["local_anesthesia", "epidural_anesthesia", "no_anesthesia_confirmed", "anesthetized"]:
				var p = fixture(surgery_id, mode)
				var triggered := 0
				var guard := 0
				while not p.flags.has("procedure_flow_complete") and guard < 40:
					guard += 1
					var current_id: String = p.surgery_flow_step().id
					play_step(p)
					if p.awaiting_patient_choice:
						if p.active_condition_id == condition_id:
							triggered += 1
							expect(current_id == target, "Full run triggers on authored semantic node")
						expect(p.apply({"kind":"patient_interaction_action", "id":p.active_patient_interaction.actions[0].id}), "Full run handles patient interaction")
					if p.awaiting_patient_acknowledgement:
						expect(p.apply({"kind":"patient_acknowledge"}), "Full run acknowledges patient")
				expect(guard < 40 and p.procedure_state.progress == 100, "Full procedure finishes")
				expect(triggered == (0 if mode == "anesthetized" else 1), "Awake modes trigger once / general anesthesia suppresses")
				print("CONDITION FLOW ", locale, " ", surgery_id, " ", mode, " count=", triggered)
	print("SURGERY TEMPORARY CONDITION RECONNECT: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
