extends "res://godot/systems/preop_session.gd"
## Thin adapter: reuse the ordinary physiology and crisis rescue implementation.
## No second checkpoint roll is made in the advanced controller.
var grand_team: Dictionary = {}
var advanced_definition: Dictionary = {}

func _init(def: Dictionary, members: Array, selected: Dictionary) -> void:
	super({"id": "advanced_runtime", "patient_id": "advanced_placeholder", "surgery_id": def.id,
		"stages": [], "start": "advanced", "initial_anxiety": 0,
		"ward_role": {"id": "ward_nurse"}, "roles": []}, members, [])
	advanced_definition = def.duplicate(true)
	grand_team = selected.duplicate(true)
	team = selected.duplicate(true)
	# Legacy crisis completion uses this alias; it is not an eighth team member.
	team.assistant_surgeon = str(selected.get("first_assistant", ""))
	procedure_id = str(def.id)
	procedure_name = str(def.name)
	flags.append("anesthetized")
	anesthesia = "全身麻醉" # localization-invariant: anesthesia state ID
	procedure_state = {"stability": 100, "blood_loss": 0, "visibility": 100, "bleeding": 0, "progress": 0, "elapsed_time": 0}

func team_crisis_modifier() -> int:
	var total := 0.0
	var count := 0
	for role in ["first_assistant", "second_assistant", "primary_scrub", "secondary_scrub", "primary_circulating", "secondary_circulating"]:
		var person: Dictionary = roster.get(str(grand_team.get(role, "")), {})
		if person.is_empty(): continue
		var skills: Dictionary = person.get("skills", {})
		total += (float(skills.get("surgery", 50)) + float(skills.get("teamwork", 50)) + float(skills.get("calmness", 50))) / 3.0
		count += 1
	var average := total / count if count > 0 else 70.0
	return 10 if average >= 82 else -3 if average < 55 else 0

func clear_resolved_crisis() -> void:
	# Do not invoke the ordinary runner's next-stage controller.
	active_crisis.clear()
	awaiting_crisis_acknowledgement = false
	feedback = ""

func apply_advanced_stage(step: Dictionary, strategy: Dictionary, ordinal: int, total: int) -> void:
	# All six metrics, technical flags and conditional effects use the ordinary resolver.
	# No ordinary flow driver or second numeric/precision roll is invoked here.
	var duration := int(advanced_definition.get("duration_minutes", 480))
	var effects: Dictionary = step.get("strategic_effects", {}).duplicate(true)
	if not effects.has("elapsed_time"):
		effects.elapsed_time = floori(float(duration) * (ordinal + 1) / total) - floori(float(duration) * ordinal / total)
	effects.progress = floori(100.0 * (ordinal + 1) / total) - int(procedure_state.progress)
	apply_surgery_option_effects({"strategic_effects": effects, "conditional_effects": step.get("conditional_effects", [])})
	if not strategy.is_empty(): apply_surgery_option_effects(strategy)

func failed() -> bool:
	return surgery_aborted or surgery_condition_met(advanced_definition.get("failure_condition", {"metric": "stability", "operator": "<=", "value": 0}))

func completed() -> bool:
	return not failed() and surgery_condition_met(advanced_definition.get("success_condition", {"metric": "progress", "operator": ">=", "value": 100}))
