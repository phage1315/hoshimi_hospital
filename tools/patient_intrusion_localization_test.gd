extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Preop = preload("res://godot/systems/preop_session.gd")

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
	var content = Loader.new()
	expect(content.load_all(), "Content load failed")
	if failures:
		quit(1)
		return
	var definition: Dictionary = content.collections.preops[0].duplicate(true)
	definition["_locale"] = "en"
	var prep = Preop.new(
		definition,
		content.collections.staff,
		content.collections.surgeries,
		content.collections.patients,
		[],
		false,
		content.collections.surgery_team_dialogue_profiles,
		content.collections.patient_interactions,
		content.collections.temporary_conditions
	)
	var interaction: Dictionary = prep.runtime_english({
		"prompt": "「我有点撑不住了……能不能先停一下？」",
		"actions": [
			{"label": "先稳定患者，再继续操作", "response": "「好，我会尽量保持不动。」"},
			{"label": "维持当前操作，要求患者继续", "response": "「……我知道了。」"},
		]
	})
	expect(interaction.prompt == "“I don't think I can hold on much longer... Could we stop for a moment?”", "Cooperation-disruption prompt stayed in Chinese in English mode")
	expect(interaction.actions[0].label == "Stabilize the patient first, then continue", "Cooperation-disruption stabilize option stayed in Chinese")
	expect(interaction.actions[0].response == "“All right, I will try to keep still.”", "Cooperation-disruption stabilize response stayed in Chinese")
	expect(interaction.actions[1].label == "Maintain the current maneuver and ask the patient to continue", "Cooperation-disruption continue option stayed in Chinese")
	expect(interaction.actions[1].response == "“...I understand.”", "Cooperation-disruption continue response stayed in Chinese")

	print("PATIENT INTRUSION LOCALIZATION: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
