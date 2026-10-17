extends "res://tools/surgery_temporary_condition_reconnect_test.gd"
## Test-only semantic-node contract; runtime reads patient_cues in surgeries.json.
const CONTRACT_PATH := "res://tools/fixtures/surgery_temporary_condition_targets.json"

func play_step(p) -> void:
	# Isolate cue wiring from low-cooperation/dignity intrusions, whose existing
	# precedence is intentionally unchanged. Use real options and acknowledgements.
	p.fear = 0
	p.pain = 0
	p.dignity = 100
	p.cooperation_base = 100
	var step: Dictionary = p.surgery_flow_step()
	var selected: Dictionary = step.options[0]
	for option in step.options:
		if option.get("correct", true):
			selected = option
			break
	expect(p.apply({"kind":"surgery_step", "id":selected.id}), "Catalog surgery choice accepted: " + str(step.id))
	expect(p.awaiting_flow_acknowledgement, "Team response before patient")
	expect(p.apply({"kind":"flow_acknowledge"}), "Catalog team acknowledgement")

func run() -> void:
	han.compile("[\\x{3400}-\\x{9fff}]")
	var contract: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CONTRACT_PATH))
	var routes := 0
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Catalog loads " + locale)
		expect(contract.size() == content.collections.surgeries.size(), "Every catalog procedure has a contract")
		for surgery in content.collections.surgeries:
			var surgery_id: String = surgery.id
			expect(contract.has(surgery_id), "Covered surgery: " + surgery_id)
			if not contract.has(surgery_id):
				continue
			for cue_index in range(2):
				var cue: String = ["nausea", "drowsiness"][cue_index]
				var targets: Array = surgery.stages.filter(func(step): return cue in step.get("patient_cues", []))
				expect(targets.size() == 1, "Exactly one cue: " + surgery_id + "/" + cue)
				if targets.size() == 1:
					expect(targets[0].id == contract[surgery_id][cue_index], "Authored semantic target: " + surgery_id + "/" + cue)
					expect(targets[0].get("stage_kind", "fixed") == "fixed", "Not an optional correction node")
			# Three awake test modes plus full general-anesthesia suppression.
			# Artificial-heart awake routes exercise generic wiring only; this does
			# not change the anesthesia configuration of its special-event entry.
			for mode in ["local_anesthesia", "epidural_anesthesia", "no_anesthesia_confirmed", "anesthetized"]:
				var p = fixture(surgery_id, mode)
				p.patient_regular_interaction_count = 999
				var seen := {"nausea":0, "drowsiness":0}
				var guard := 0
				var previous_minutes: int = p.minutes
				while not p.flags.has("procedure_flow_complete") and guard < 40:
					guard += 1
					var current_id: String = p.surgery_flow_step().id
					play_step(p)
					if p.awaiting_patient_choice:
						var condition_id: String = p.active_condition_id
						expect(seen.has(condition_id), "Temporary condition bypasses exhausted ordinary budget")
						if seen.has(condition_id):
							seen[condition_id] += 1
							var cue_index := 0 if condition_id == "nausea" else 1
							# Whipple deliberately registers both on key_decision;
							# its lower-priority drowsiness continues on the next node.
							var expected: String = "completion_check" if surgery_id == "surgery_open_whipple" and condition_id == "drowsiness" else contract[surgery_id][cue_index]
							expect(current_id == expected, "Actual triggering node: " + surgery_id + "/" + condition_id)
							var definition: Dictionary = content.find_record("temporary_conditions", condition_id)
							expect(p.feedback == definition.prompts["1"], "Localized severity-1 prompt")
							expect(p.active_patient_interaction.actions.size() == 4, "Original four handling options")
							if locale == "en":
								expect(han.search(p.feedback + p.temporary_condition_status_text()) == null, "English prompt and HUD")
								for action in p.active_patient_interaction.actions:
									expect(han.search(action.label + action.response) == null, "English actions and responses")
						var action: Dictionary = p.active_patient_interaction.actions[0]
						var before: int = p.minutes
						expect(p.apply({"kind":"patient_interaction_action", "id":action.id}), "Treat temporary condition")
						expect(p.minutes == before + int(action.minutes), "Treatment charges authored minutes once")
					if p.awaiting_patient_acknowledgement:
						expect(p.apply({"kind":"patient_acknowledge"}), "Continue after treatment")
					expect(p.minutes >= previous_minutes, "No backward time")
					previous_minutes = p.minutes
					if mode == "anesthetized":
						expect(p.active_temporary_conditions.is_empty(), "General anesthesia never registers conditions")
				expect(guard < 40 and p.flags.has("procedure_flow_complete") and p.flags.has("interaction_complete") and p.procedure_step_index == surgery.stages.size(), "Full catalog stage sequence completes: " + surgery_id)
				if surgery.stages[0].has("progress_delta"):
					expect(p.procedure_state.progress == 100, "V2 fixed-stage progress completes")
				else:
					# The two legacy flows signal completion via flags, not V2
					# progress_delta. Cues must not introduce strategic progress.
					expect(p.procedure_state.progress == surgery.initial_state.progress, "Legacy strategic progress unchanged")
				for cue in seen:
					expect(seen[cue] == (0 if mode == "anesthetized" else 1), "One awake occurrence / zero general: " + surgery_id + "/" + cue)
				routes += 1
			# Existing explicit opt-out must still work with the newly authored cues.
			var disabled = fixture(surgery_id, "local_anesthesia")
			disabled.temporary_conditions_enabled = false
			disabled.patient_regular_interaction_count = 999
			for index in range(surgery.stages.size()):
				if surgery.stages[index].id in contract[surgery_id]:
					disabled.procedure_step_index = index
					play_step(disabled)
					expect(disabled.active_temporary_conditions.is_empty() and disabled.active_condition_id.is_empty(), "Explicit temporary-condition opt-out honored")
	print("SURGERY TEMPORARY CONDITION CATALOG: %s routes; %s checks; %s failures" % [routes, checks, failures])
	quit(1 if failures else 0)
