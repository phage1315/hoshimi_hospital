extends RefCounted
## Shared 2026-10-14 candidate rules; does not contain procedure patches.
const ROLL_SCALE := 1000000
const TIME_BREAKS := [0.85, 0.92, 1.0, 1.12, 1.25, 1.40]
const TIME_PENALTIES := [0, 3, 7, 11, 18, 24, 30]
const BLOOD_BREAKS := [0.75, 0.95, 1.10, 1.40, 1.70, 2.10]
const BLOOD_PENALTIES := [0, 2, 4, 7, 11, 16, 24]
const ROUTINE_RESCUE := [90, 75, 60]
const SEVERE_RESCUE := [80, 60, 40]

static func band_penalty(ratio: float, thresholds: Array, penalties: Array) -> int:
	# ZIP searchsorted(side="left"): equality belongs to the lower band.
	for index in range(thresholds.size()):
		if ratio <= float(thresholds[index]):
			return int(penalties[index])
	return int(penalties.back())

static func shock_probability(risk_class: String, option_index: int) -> float:
	# Authored risk class is independent of choice count (17 S stages have A/B only).
	var risks: Dictionary = {"F": [0.003], "L": [0.006, 0.017], "S": [0.012, 0.03, 0.115]}
	if not risks.has(risk_class) or option_index < 0 or option_index >= risks[risk_class].size():
		return -1.0
	return float(risks[risk_class][option_index])

static func valid_rolls(value: Variant) -> bool:
	if not value is Array or value.size() != 7:
		return false
	for roll in value:
		# JSON event logs decode integers as floats; accept only integral values.
		if not (roll is int or roll is float):
			return false
		if not is_finite(float(roll)) or float(roll) < 0 or float(roll) >= ROLL_SCALE or float(roll) != floorf(float(roll)):
			return false
	return true

static func stage_rolls(surgery_seed: int, procedure_id: String, stage_id: String) -> Array:
	# Independent stream: no extra global RNG draws and no option-dependent seed.
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("numeric_variance_v1:%s:%s:%s" % [surgery_seed, procedure_id, stage_id])
	var rolls: Array = []
	for index in range(7):
		rolls.append(rng.randi_range(0, ROLL_SCALE - 1))
	return rolls

static func effects(baseline: Dictionary, stage_count: int, probability: float, rolls: Array) -> Array:
	if stage_count <= 0 or probability < 0 or not valid_rolls(rolls):
		return []
	var et := float(baseline.expected_time)
	var eb := float(baseline.expected_blood_loss)
	var small_t := float(rolls[5]) / ROLL_SCALE
	var small_b := float(rolls[6]) / ROLL_SCALE
	# Runtime state is integer-valued. Round each delta, not the total state.
	var noise := {
		"elapsed_time": roundi((2.0 * small_t - 1.0) * 0.23 * et / stage_count),
		"blood_loss": roundi((2.0 * small_b - 1.0) * 0.14 * eb / stage_count),
	}
	var result: Array = [noise]
	if float(rolls[0]) / ROLL_SCALE >= probability:
		return result
	var kind := float(rolls[1]) / ROLL_SCALE
	var u := float(rolls[2]) / ROLL_SCALE
	var v := float(rolls[3]) / ROLL_SCALE
	var w := float(rolls[4]) / ROLL_SCALE
	var shock: Dictionary
	if kind < 0.62:
		shock = {
			"blood_loss": roundi(eb * 0.72 * (0.20 + 0.38 * u)),
			"bleeding": roundi(0.72 * (12.0 + 18.0 * v)),
			"visibility": -roundi(0.72 * (2.0 + 10.0 * u)),
			"stability": -roundi(0.72 * (7.0 + 15.0 * w)),
			"elapsed_time": roundi(et * 0.72 * (0.025 + 0.055 * v)),
		}
	elif kind < 0.88:
		shock = {
			"stability": -roundi(0.72 * (13.0 + 16.0 * u)),
			"blood_loss": roundi(eb * 0.72 * (0.08 + 0.15 * v)),
			"elapsed_time": roundi(et * 0.72 * (0.05 + 0.09 * w)),
		}
	else:
		shock = {
			"elapsed_time": roundi(et * 0.72 * (0.11 + 0.13 * u)),
			"blood_loss": roundi(eb * 0.72 * (0.04 + 0.10 * v)),
		}
	result.append(shock)
	return result
