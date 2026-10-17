extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const Rules = preload("res://godot/systems/surgery_numeric_calibration.gd")
var content = Loader.new()
var english_content = Loader.new()
var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func fixture(procedure: String = "surgery_appendix", source = null) -> RefCounted:
	if source == null:
		source = content
	var definition := {
		"id": "numeric_calibration_test", "patient_id": "patient_sora", "encounter_id": "visit_sora",
		"surgery_id": procedure, "start": "surgery_flow", "_locale": "en" if source == english_content else "zh_CN",
		"initial_anxiety": 2, "initial_interaction": {"fear": 35, "pain": 0, "dignity": 100, "cooperation": 70},
		"roles": [], "ward_role": {"id": "ward_nurse"}, "preparations": [], "max_optional_preparations": 0,
		"care_reassurance_threshold": 70, "completion": "surgery_abort",
		"stages": [{"id": "surgery_flow", "title": "Numeric test", "prompt": "", "scene": "operating_room", "kind": "surgery_flow", "speaker": "narrator", "next": "surgery_flow", "actions": [], "background_id": "operating_room"}],
	}
	var prep = Preop.new(definition, source.collections.staff, source.collections.surgeries, source.collections.patients, [], false, source.collections.surgery_team_dialogue_profiles, source.collections.patient_interactions, source.collections.temporary_conditions)
	prep.procedure_id = procedure
	prep.procedure_name = procedure
	prep.initialize_procedure_state()
	prep.surgery_rng_seed = 20261014
	prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin"}
	prep.flags.append("anesthetized")
	return prep

func _initialize() -> void:
	call_deferred("run")

func score_tests() -> void:
	for pair in [[Rules.TIME_BREAKS, Rules.TIME_PENALTIES], [Rules.BLOOD_BREAKS, Rules.BLOOD_PENALTIES]]:
		for index in range(pair[0].size()):
			var threshold: float = pair[0][index]
			expect(Rules.band_penalty(threshold, pair[0], pair[1]) == pair[1][index], "Equality must stay in the lower deduction band")
			expect(Rules.band_penalty(threshold + 0.000001, pair[0], pair[1]) == pair[1][index + 1], "Above-threshold deduction band incorrect")
	var prep = fixture()
	prep.surgery_success = true
	prep.procedure_state.elapsed_time = 60
	prep.procedure_state.blood_loss = 30
	prep.minimum_stability_seen = 100
	expect(prep.surgical_quality_score() == 89 and prep.surgical_quality_grade() == "A", "Baseline ratios should deduct 7 time + 4 blood")
	for sample in [[95, 0], [94, 2], [90, 2], [89, 6], [80, 6], [79, 12], [70, 12], [69, 25]]:
		prep.minimum_stability_seen = sample[0]
		expect(prep.surgical_quality_score() == 89 - sample[1], "Historical minimum-stability deductions changed")
	prep.surgical_complications.append({"id": "test_minor", "severity": "minor"})
	prep.surgical_complications.append({"id": "test_major", "severity": "major"})
	expect(prep.surgical_quality_score() == 44 and prep.surgical_quality_grade() == "C", "Low successful score must remain C, not F")
	prep.surgery_success = false
	expect(prep.surgical_quality_score() == 0 and prep.surgical_quality_grade() == "F", "Unsuccessful surgery must remain F")

func rescue_tests() -> void:
	var prep = fixture()
	prep.roster = prep.roster.duplicate(true)
	for rating in [50, 70, 90]:
		for staff_id in prep.team.values():
			prep.roster[staff_id].skills = {"surgery": rating, "teamwork": rating, "calmness": rating}
		var modifier: int = -3 if rating == 50 else 10 if rating == 90 else 0
		for severity in ["routine", "severe"]:
			var bases: Array = [90, 75, 60] if severity == "routine" else [80, 60, 40]
			for attempt in range(1, 4):
				prep.active_crisis = {"severity": severity, "attempt": attempt}
				for option_id in ["pause_and_stabilize", "hold_field_team_rescue", "finish_critical_action"]:
					var offset: int = {"pause_and_stabilize": 0, "hold_field_team_rescue": -8, "finish_critical_action": -25}[option_id]
					var team_bonus: int = modifier * (2 if option_id == "hold_field_team_rescue" else 1)
					expect(prep.crisis_rescue_chance(option_id) == clampi(bases[attempt - 1] + offset + team_bonus, 5, 99), "Rescue curve/team/choice matrix mismatch")

func variance_math_tests() -> void:
	var baseline := {"expected_time": 100, "expected_blood_loss": 100}
	var midpoint := [999999, 0, 500000, 500000, 500000, 500000, 500000]
	expect(Rules.effects(baseline, 10, 0.003, midpoint) == [{"elapsed_time": 0, "blood_loss": 0}], "No-hit midpoint noise must be zero")
	var shock_cases := [
		[0, {"blood_loss": 28, "bleeding": 15, "visibility": -5, "stability": -10, "elapsed_time": 4}],
		[620000, {"stability": -15, "blood_loss": 11, "elapsed_time": 7}],
		[880000, {"elapsed_time": 13, "blood_loss": 6}],
	]
	for sample in shock_cases:
		var rolls := midpoint.duplicate()
		rolls[0] = 0
		rolls[1] = sample[0]
		expect(Rules.effects(baseline, 10, 0.003, rolls)[1] == sample[1], "Shock branch arithmetic/rounding mismatch")
	for risk_class in ["F", "L", "S"]:
		var expected_rates: Array = {"F": [0.003], "L": [0.006, 0.017], "S": [0.012, 0.03, 0.115]}[risk_class]
		for index in range(expected_rates.size()):
			var probability := Rules.shock_probability(risk_class, index)
			expect(probability == expected_rates[index], "F/L/S option risk differs from the ZIP")
			var rolls := midpoint.duplicate()
			rolls[0] = roundi(probability * Rules.ROLL_SCALE)
			expect(Rules.effects(baseline, 10, probability, rolls).size() == 1, "Shock event equality should not trigger")
			rolls[0] -= 1
			expect(Rules.effects(baseline, 10, probability, rolls).size() == 2, "Shock threshold just below should trigger")
	var low := midpoint.duplicate()
	low[5] = 0
	low[6] = 0
	expect(Rules.effects(baseline, 10, 0.003, low)[0] == {"elapsed_time": -2, "blood_loss": -1}, "Negative noise arithmetic incorrect")
	low[5] = 999999
	low[6] = 999999
	expect(Rules.effects(baseline, 10, 0.003, low)[0] == {"elapsed_time": 2, "blood_loss": 1}, "Positive noise arithmetic incorrect")
	expect(Rules.valid_rolls(JSON.parse_string(JSON.stringify(midpoint))), "JSON dice should remain replayable")
	for invalid in [null, [], [1, 2, 3], [true, 0, 0, 0, 0, 0, 0], [-1, 0, 0, 0, 0, 0, 0], [1000000, 0, 0, 0, 0, 0, 0], [0.5, 0, 0, 0, 0, 0, 0], [NAN, 0, 0, 0, 0, 0, 0]]:
		expect(not Rules.valid_rolls(invalid), "Invalid dice accepted")
	seed(90210)
	var expected_global := randi()
	seed(90210)
	var deterministic := Rules.stage_rolls(1, "test", "stage")
	expect(randi() == expected_global, "Variance consumed global RNG and perturbed crisis/patient dice")
	expect(deterministic == Rules.stage_rolls(1, "test", "stage"), "Variance not deterministic for a fixed seed/stage")
	expect(deterministic != Rules.stage_rolls(2, "test", "stage") and deterministic != Rules.stage_rolls(1, "test", "other"), "Stage/case seeds must produce distinct streams")

func integration_tests() -> void:
	var prep = fixture()
	var first: Dictionary = prep.surgery_flow_step()
	var bare := {"kind": "surgery_step", "id": first.options[0].id}
	var event: Dictionary = prep.prepare_surgery_step_event(bare)
	expect(event.has("variance_rolls") and not bare.has("variance_rolls"), "Live step should acquire dice without mutating caller input")
	expect(not event.has("crisis_roll"), "Variance must work with physiological crises disabled")
	var before: Dictionary = prep.snapshot_state()
	var malformed := event.duplicate(true)
	malformed.variance_rolls = [0]
	expect(not prep.apply(malformed) and prep.snapshot_state() == before, "Invalid dice mutated the session")
	malformed = event.duplicate(true)
	malformed.extra_key = true
	expect(not prep.apply(malformed) and prep.snapshot_state() == before, "Unknown payload key mutated the session")
	var expected = fixture()
	expected.apply_surgery_option_effects(first.options[0])
	for delta in Rules.effects(expected.surgery_quality_baseline(), expected.surgery_flow_steps().size(), expected.numeric_variance_probability(first, str(first.options[0].id)), event.variance_rolls):
		expected.apply_surgery_strategic_effects(delta)
	var experience: int = prep.patient_experience_score()
	expect(prep.apply(event), "Live step rejected")
	expect(prep.procedure_state == expected.procedure_state, "Variance order must be authored effects/conditionals, noise, shock")
	expect(prep.patient_experience_score() == experience and prep.fear == 35 and prep.pain == 0 and prep.dignity == 100 and prep.cooperation_base == 70, "Variance changed patient metrics")
	expect(prep.resolved_random_choices.has("numeric_variance_v1:" + str(first.id)), "Dice/effects missing from existing persisted random-choice log")
	before = prep.snapshot_state()
	expect(not prep.apply(event) and prep.snapshot_state() == before, "Double-click applied a second variance")
	var replay = fixture()
	expect(replay.apply(JSON.parse_string(JSON.stringify(event))) and replay.procedure_state == prep.procedure_state, "JSON event replay differs")
	var restored = fixture()
	expect(restored.restore_state(JSON.parse_string(JSON.stringify(prep.snapshot_state()))), "Snapshot restore failed")
	# JSON represents nested numeric values as floats. Compare normalized
	# serialized data, then also execute the next stage on both sessions below.
	expect(restored.procedure_state == JSON.parse_string(JSON.stringify(prep.procedure_state)) and restored.resolved_random_choices == JSON.parse_string(JSON.stringify(prep.resolved_random_choices)), "Saved dice/effects were not restored")
	var english = fixture("surgery_appendix", english_content)
	var english_event: Dictionary = english.prepare_surgery_step_event(bare)
	expect(english_event == event and english.apply(english_event) and english.procedure_state == prep.procedure_state, "English/Chinese numeric execution differs")
	expect(prep.apply({"kind": "flow_acknowledge"}) and restored.apply({"kind": "flow_acknowledge"}), "Restored stage could not advance")
	var next_step: Dictionary = prep.surgery_flow_step()
	var next_bare := {"kind": "surgery_step", "id": next_step.options[0].id}
	var next_event: Dictionary = prep.prepare_surgery_step_event(next_bare)
	expect(restored.prepare_surgery_step_event(next_bare) == next_event and prep.apply(next_event) and restored.apply(next_event), "Restored next-stage dice differ")
	expect(JSON.stringify(prep.procedure_state) == JSON.stringify(restored.procedure_state), "Restored continuation results differ")
	var legacy = fixture()
	var legacy_expected = fixture()
	legacy_expected.apply_surgery_option_effects(first.options[0])
	expect(legacy.apply(bare) and legacy.procedure_state == legacy_expected.procedure_state and not legacy.resolved_random_choices.has("numeric_variance_v1:" + str(first.id)), "Legacy event must not silently acquire variance")
	var quick := {"kind": "sweep", "id": "surgery_appendix"}
	expect(legacy.prepare_surgery_step_event(quick) == quick, "Quick surgery acquired node variance")
	var unsupported = fixture()
	unsupported.procedure_id = "not_an_ordinary_procedure"
	expect(unsupported.prepare_surgery_step_event(bare) == bare, "Non-ordinary procedure acquired variance")
	var clamped = fixture()
	clamped.procedure_state.elapsed_time = 0
	clamped.procedure_state.blood_loss = 0
	clamped.apply_numeric_variance(first, str(first.options[0].id), [999999, 0, 0, 0, 0, 0, 0])
	expect(clamped.procedure_state.elapsed_time == 0 and clamped.procedure_state.blood_loss == 0, "Negative noise crossed the zero floor")
	clamped.procedure_state.stability = 1
	clamped.procedure_state.visibility = 1
	clamped.procedure_state.bleeding = 99
	clamped.apply_numeric_variance(first, str(first.options[0].id), [0, 0, 999999, 999999, 999999, 500000, 500000])
	expect(clamped.procedure_state.stability == 0 and clamped.procedure_state.visibility == 0 and clamped.procedure_state.bleeding == 100 and clamped.minimum_stability_seen == 0, "Shock bounds/history incorrect")
	expect(not clamped.surgery_aborted and clamped.surgical_complications.is_empty() and clamped.active_crisis.is_empty(), "Numeric shock directly caused abort/complication/crisis")
	var crisis = fixture()
	var crisis_event := {"kind": "surgery_step", "id": first.options[0].id, "variance_rolls": [0, 0, 999999, 999999, 999999, 500000, 500000], "crisis_roll": 0}
	expect(crisis.apply(crisis_event) and not crisis.active_crisis.is_empty(), "Combined variance/crisis event failed")
	var pre_crisis = fixture()
	pre_crisis.apply_surgery_option_effects(first.options[0])
	pre_crisis.apply_numeric_variance(first, str(first.options[0].id), crisis_event.variance_rolls)
	pre_crisis.maybe_start_physiologic_crisis(0, first)
	expect(crisis.procedure_state == pre_crisis.procedure_state and crisis.active_crisis == pre_crisis.active_crisis, "Crisis did not run after numeric variance")
	var crisis_restored = fixture()
	expect(crisis_restored.restore_state(JSON.parse_string(JSON.stringify(crisis.snapshot_state()))), "Combined variance/crisis snapshot rejected")
	for attempt in range(3):
		var rescue_event := {"kind": "crisis_rescue", "id": "finish_critical_action", "roll": 9999}
		expect(crisis.apply(rescue_event) and crisis_restored.apply(rescue_event), "Restored rescue step rejected")
	expect(crisis.surgery_aborted and crisis_restored.surgery_aborted and crisis.procedure_state == crisis_restored.procedure_state and crisis.crisis_history == crisis_restored.crisis_history, "Restored variance/crisis continuation diverged")
	var conditional = fixture()
	conditional.surgeries = conditional.surgeries.duplicate(true)
	var conditional_step: Dictionary = conditional.surgery_flow_step()
	conditional_step.options[0].strategic_effects = {"blood_loss": 0, "elapsed_time": 4}
	conditional_step.options[0].conditional_effects = [
		{"when": {"field": "blood_loss", "op": "gt", "value": 0}, "strategic_effects": {"elapsed_time": 100}},
		{"when": {"field": "blood_loss", "op": "eq", "value": 0}, "strategic_effects": {"elapsed_time": 2}},
	]
	conditional.procedure_state.blood_loss = 0
	conditional.procedure_state.elapsed_time = 0
	var forced_rolls := [0, 0, 500000, 500000, 500000, 500000, 500000]
	var shock: Dictionary = Rules.effects(conditional.surgery_quality_baseline(), conditional.surgery_flow_steps().size(), 1.0, forced_rolls)[1]
	expect(conditional.apply({"kind": "surgery_step", "id": conditional_step.options[0].id, "variance_rolls": forced_rolls}), "Conditional-order fixture rejected")
	expect(conditional.procedure_state.elapsed_time == 6 + int(shock.elapsed_time) and conditional.procedure_state.blood_loss > 0, "Conditionals incorrectly evaluated after numeric shock")

func restored_rework_tests() -> void:
	var midpoint := [999999, 0, 500000, 500000, 500000, 500000, 500000]
	for sample in [
		["surgery_open_left_hemicolectomy", "lhc_rework", "lhc_rework_b", "lhc_closure"],
		["surgery_open_low_anterior_resection", "lar_rework", "lar_rework_b", "lar_diversion_plan_review"],
	]:
		for source in [content, english_content]:
			for incoming in [31, 32, 38, 39, 40]:
				var prep = fixture(sample[0], source)
				var rework_index := -1
				for index in range(prep.surgery_flow_steps().size()):
					if prep.surgery_flow_steps()[index].id == sample[1]:
						rework_index = index
				expect(rework_index >= 0, "Restored rework stage missing")
				prep.procedure_step_index = rework_index
				var step: Dictionary = prep.surgery_flow_step()
				var option: Dictionary = step.options[1]
				expect(option.id == sample[2] and option.correct and step.once_per_episode, "Rework B identity/correct/once semantics changed")
				# Content JSON numbers are floats; normalize the expected nested dictionary too.
				var expected_condition: Dictionary = JSON.parse_string(JSON.stringify({"when": {"field": "bleeding", "op": "gte", "value": 32}, "strategic_effects": {"blood_loss": 10, "stability": -5, "add_complications": [{"id": "closure_rework", "severity": "minor"}]}}))
				expect(option.conditional_effects.size() == 1 and option.conditional_effects[0] == expected_condition, "Restored condition must occur exactly once, unscaled")
				prep.procedure_state.bleeding = incoming
				prep.procedure_state.blood_loss = 0
				prep.procedure_state.stability = 100
				prep.procedure_state.elapsed_time = 0
				prep.surgical_technical_flags.append("anastomosis_recheck_required")
				prep.conditional_stage_resolution[sample[1]] = "entered"
				var event := {"kind": "surgery_step", "id": sample[2], "variance_rolls": midpoint}
				expect(prep.apply(event), "Restored B rejected")
				var penalty: bool = incoming >= 39
				expect(prep.procedure_state.bleeding == incoming - 7, "B must apply main bleeding -7 before condition")
				expect(prep.procedure_state.blood_loss == option.strategic_effects.blood_loss + (10 if penalty else 0) and prep.procedure_state.stability == (95 if penalty else 100), "B condition input boundary must be 39, not 32")
				expect(prep.procedure_state.elapsed_time == option.strategic_effects.elapsed_time, "Restored condition changed main elapsed time")
				expect(prep.surgical_complications == ([{"id": "closure_rework", "severity": "minor"}] if penalty else []), "Minor complication missing/duplicated")
				expect(not prep.surgical_technical_flags.has("anastomosis_recheck_required") and not prep.pending_flow_retry and not prep.surgery_aborted and prep.active_crisis.is_empty(), "Penalty retried, aborted, or retained recheck flag")
				var snapshot: Dictionary = prep.snapshot_state()
				expect(not prep.apply(event) and prep.snapshot_state() == snapshot, "Duplicate B click applied another penalty")
				expect(prep.apply({"kind": "flow_acknowledge"}) and prep.surgery_flow_step().id == sample[3] and prep.conditional_stage_resolution[sample[1]] == "completed", "B did not continue to the authored next stage")
				expect(not prep.apply(event), "Stale B event accepted on later stage")
				var guard := 0
				while not prep.flags.has("procedure_flow_complete") and guard < 6:
					guard += 1
					var next_step: Dictionary = prep.surgery_flow_step()
					expect(prep.apply({"kind": "surgery_step", "id": next_step.options[0].id, "variance_rolls": midpoint}) and prep.apply({"kind": "flow_acknowledge"}), "Post-rework continuation failed")
				expect(prep.flags.has("procedure_flow_complete") and not prep.surgery_aborted and prep.procedure_corrections == 0, "Minor penalty must not force surgical failure or repeat correction")
				expect(prep.procedure_step_history.filter(func(entry): return entry.option_id == sample[2]).size() == 1, "Rework must be executed once per episode")
				# Even if traversal revisits the predecessor, a completed correction is skipped.
				prep.procedure_step_index = rework_index - 1
				prep.complete_surgery_flow_stage()
				expect(prep.procedure_step_index == rework_index + 1, "Completed conditional correction re-entered")
			var shocked = fixture(sample[0], source)
			for index in range(shocked.surgery_flow_steps().size()):
				if shocked.surgery_flow_steps()[index].id == sample[1]:
					shocked.procedure_step_index = index
					break
			shocked.procedure_state.bleeding = 38
			expect(shocked.apply({"kind": "surgery_step", "id": sample[2], "variance_rolls": [0, 0, 999999, 500000, 500000, 500000, 500000]}), "Forced post-condition shock rejected")
			expect(shocked.procedure_state.bleeding >= 32 and shocked.surgical_complications.is_empty(), "Numeric shock must not retroactively trigger the B conditional")

func live_ui_tests() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Live UI locale failed to load")
		app.configure_game_content()
		for crisis_enabled in [false, true]:
			app.game.reset()
			app.game.intraoperative_crisis_enabled = crisis_enabled
			var definition: Dictionary = app.content.collections.preops[0]
			var visit = app.game.open_visit(str(definition.encounter_id))
			visit.admitted = true
			visit.stage_id = str(visit.definition.completion)
			var prep = Preop.new(definition, app.game.staff, app.content.collections.surgeries, app.content.collections.patients)
			prep.stage_id = "procedure_flow"
			prep.procedure_id = "surgery_appendix"
			prep.initialize_procedure_state()
			prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin"}
			prep.flags.append("anesthetized")
			app.game.preops[definition.id] = prep
			app.game.active_preop_id = str(definition.id)
			app.game.active_mode = "preop"
			var step: Dictionary = prep.surgery_flow_step()
			var event := {"kind": "surgery_step", "id": step.options[0].id}
			if crisis_enabled:
				event.crisis_roll = 9999
			app.preop_event(event)
			expect(app.screen == "preop", "Live test did not return to the operative UI")
			expect(prep.events.size() == 1 and prep.events[0].has("variance_rolls"), "Actual UI did not submit node variance")
			expect(prep.events[0].has("crisis_roll") == crisis_enabled, "UI lost or added physiological-crisis dice")
			expect(prep.resolved_random_choices.has("numeric_variance_v1:" + str(step.id)) and prep.awaiting_flow_acknowledgement, "UI step did not apply/persist variance")
	app.free()

func full_pool_tests() -> void:
	var count := 0
	var stages := 0
	var options := 0
	for surgery in content.collections.surgeries:
		var prep = fixture(str(surgery.id))
		if not prep.pilot_surgery():
			continue
		count += 1
		for step in prep.surgery_flow_steps():
			stages += 1
			for option in step.options:
				options += 1
				expect(prep.numeric_variance_probability(step, str(option.id)) >= 0, "Unmapped live ordinary option: %s/%s/%s" % [surgery.id, step.id, option.id])
		for policy in range(3):
			prep = fixture(str(surgery.id))
			prep.surgery_rng_seed += policy
			var guard := 0
			while not prep.flags.has("procedure_flow_complete") and guard < 30:
				guard += 1
				var step: Dictionary = prep.surgery_flow_step()
				if step.is_empty():
					break
				var choice: Dictionary = step.options[mini(policy, step.options.size() - 1)]
				var event: Dictionary = prep.prepare_surgery_step_event({"kind": "surgery_step", "id": choice.id})
				expect(event.has("variance_rolls") and prep.apply(event), "Full-pool candidate step failed: %s/%s" % [surgery.id, step.id])
				expect(prep.apply({"kind": "flow_acknowledge"}), "Full-pool acknowledgement failed")
				if failures > 20:
					return
			expect(guard < 30 and prep.flags.has("procedure_flow_complete") and prep.procedure_state.progress == 100 and not prep.surgery_aborted, "Full-pool numeric-only flow failed: %s policy %s" % [surgery.id, policy])
	expect(count == 30, "Expected exactly 30 ordinary procedures")
	print("FULL POOL: %s procedures / %s authored stages / %s options / %s routes" % [count, stages, options, count * 3])

func authored_class_tests() -> void:
	var audit: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/qa/calibration_20261014_v2_identity.json"))
	var counts := {"F": 0, "L": 0, "S": 0}
	var double_s := 0
	for row in audit.stages:
		for source in [content, english_content]:
			var prep = fixture(str(row.canonical_procedure_id), source)
			var candidates: Array = prep.surgery_flow_steps().filter(func(s): return s.id == row.runtime_stage_id)
			expect(candidates.size() == 1, "Missing mapped runtime stage")
			if candidates.size() != 1:
				continue
			var step: Dictionary = candidates[0]
			expect(step.get("risk_class", "") == row.risk_class, "Authored risk class changed with locale or loading")
			var rates: Array = {"F": [0.003], "L": [0.006, 0.017], "S": [0.012, 0.03, 0.115]}[row.risk_class]
			for index in range(step.options.size()):
				expect(step.options[index].id == row.runtime_option_ids[index], "Authored option identity/order changed")
				expect(prep.numeric_variance_probability(step, str(step.options[index].id)) == rates[index], "Actual runtime risk differs from authored class")
			var missing_class := step.duplicate(true)
			missing_class.erase("risk_class")
			expect(prep.numeric_variance_probability(missing_class, str(step.options[0].id)) == -1.0, "Missing class inferred from option count")
			missing_class.risk_class = "invalid"
			expect(prep.numeric_variance_probability(missing_class, str(step.options[0].id)) == -1.0, "Invalid class accepted")
		counts[row.risk_class] += 1
		if row.risk_class == "S" and row.runtime_option_ids.size() == 2:
			double_s += 1
	expect(counts == {"F": 86, "L": 111, "S": 161} and double_s == 17, "Incomplete authored classification coverage")
	expect(Rules.shock_probability("F", 1) == -1.0 and Rules.shock_probability("L", 2) == -1.0 and Rules.shock_probability("S", -1) == -1.0, "Invalid class/option combination accepted")

func run() -> void:
	expect(content.load_all(), "Chinese content failed to load")
	expect(english_content.load_all("en"), "English content failed to load")
	score_tests()
	rescue_tests()
	variance_math_tests()
	integration_tests()
	restored_rework_tests()
	await live_ui_tests()
	full_pool_tests()
	authored_class_tests()
	print("SURGERY NUMERIC CALIBRATION: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
