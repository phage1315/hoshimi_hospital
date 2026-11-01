extends RefCounted
const Model = preload("res://godot/systems/advanced_surgery_model.gd")
const Physiology = preload("res://godot/systems/advanced_physiology.gd")
var definition: Dictionary
var team: Dictionary
var hp := 100
var index := 0
var used := [0, 0]
var precision_failures := 0
var rescue_attempts := 0
var crisis_count := 0
var failure_reason := "" # Runtime classification only.
var finished := false
var success := false
var pending_rescue := false
var awaiting_ack := false
var variant := false
var hp_only := false
var splash_pending := false
var patient_ready_pending := false # Presentation only; never saved.
var team_intro_index := -1 # Presentation only; never saved.
var operative_dialogue: RefCounted
var rng := RandomNumberGenerator.new()
var physiology: RefCounted
var last_result: Dictionary = {}
var resolved_stages: Dictionary = {} # Runtime idempotency, never persisted.
var selected_strategy: Dictionary = {}
var journal: Array = [] # Runtime diagnostics only; never serialized.

func _init(def: Dictionary, values: Dictionary, seed_value: int, members: Array = [], roster: Dictionary = {}, simulation_only: bool = false) -> void:
	definition = def.duplicate(true)
	team = values.duplicate(true)
	rng.seed = seed_value
	variant = rng.randf() < .25
	hp_only = simulation_only
	if not hp_only: physiology = Physiology.new(definition, members, roster)

func current() -> Dictionary:
	return {} if finished or index >= definition.steps.size() else definition.steps[index]

func eligible(who: int) -> bool:
	return who == 0 or (who in [1, 2] and Model.can_use(team.assistants[who - 1], int(used[who - 1]), current()))

func in_crisis() -> bool:
	return physiology != null and not physiology.active_crisis.is_empty()

func strategy_options() -> Array:
	return current().get("options", []) if not hp_only and current().get("kind", "") == "S" else []

func act(who: int = 0, option_id: String = "") -> bool:
	if finished or awaiting_ack or pending_rescue or in_crisis() or splash_pending or patient_ready_pending or team_intro_index >= 0: return false
	check_failure()
	if finished: return false
	var step := current()
	selected_strategy = {}
	var options := strategy_options() if not hp_only else []
	if not options.is_empty():
		for option in options:
			if str(option.id) == option_id: selected_strategy = option
		if selected_strategy.is_empty(): return false
	elif not option_id.is_empty(): return false
	if step.kind != "P" and who != 0: return false
	if not eligible(who): return false
	var before := hp
	last_result = {"stage": step.id, "actor": who, "failed": false}
	if step.kind == "P":
		var skill := int(team.player) if who == 0 else int(team.assistants[who - 1].skill)
		if who > 0: used[who - 1] += 1
		hp -= Model.base_cost(skill, step)
		var failed := rng.randf() >= Model.probability(skill, step, team, variant)
		last_result.failed = failed
		if failed:
			precision_failures += 1
			if who == 0 and hp > 0:
				pending_rescue = true
				last_result.cost = before - hp
				return true
			hp -= int(step.hp_failed_extra)
	else: hp -= int(step.hp_base)
	last_result.cost = before - hp
	finish_action()
	return true

func rescue(who: int) -> bool:
	if finished or not pending_rescue or not eligible(who): return false
	var step := current()
	pending_rescue = false
	var cost := int(step.hp_failed_extra)
	if who > 0:
		used[who - 1] += 1
		rescue_attempts += 1
		var won := rng.randf() < Model.probability(int(team.assistants[who - 1].skill), step, team, variant)
		cost = ceili(float(step.hp_failed_extra) * .42) + 2 if won else int(step.hp_failed_extra) + 3
		last_result.rescue_success = won
	last_result.rescue_actor = who
	hp -= cost
	last_result.cost = int(last_result.cost) + cost
	finish_action()
	return true

func finish_action() -> void:
	# A stage owns one effects application, one checkpoint roll and one HP charge.
	if resolved_stages.has(index) or finished: return
	resolved_stages[index] = true
	if variant and index == 1:
		hp -= 4
		last_result.variant_cost = 4
	if physiology != null:
		physiology.procedure_step_index = index
		physiology.apply_advanced_stage(current(), selected_strategy, index, definition.steps.size())
	check_failure()
	var checkpoint: int = Model.checkpoint_index(definition, index + 1)
	if not finished and checkpoint >= 0:
		var triggered := false
		if hp_only:
			# Explicit numerical fixtures only. Never run beside the real resolver.
			triggered = rng.randf() < float(definition.crisis_chances[checkpoint])
		else:
			triggered = physiology.maybe_start_physiologic_crisis(rng.randi_range(0, 9999), current())
		if triggered:
			crisis_count += 1
			var cost := Model.crisis_cost(team, rng)
			hp -= cost
			last_result.crisis_cost = cost
	awaiting_ack = true
	journal.append(last_result.duplicate(true))
	check_failure()

func resolve_crisis(option_id: String) -> bool:
	if finished or not in_crisis(): return false
	if not physiology.apply_crisis_rescue(option_id, rng.randi_range(0, 9999)): return false
	if physiology.surgery_aborted:
		finished = true
		success = false
	elif bool(physiology.active_crisis.get("resolved", false)):
		physiology.clear_resolved_crisis()
	check_failure()
	return true

func check_failure() -> void:
	if hp <= 0 or (physiology != null and (physiology.failed())):
		failure_reason = "both" if hp <= 0 and physiology != null and physiology.failed() else "hp" if hp <= 0 else "physiology"
		hp = maxi(0, hp)
		finished = true
		success = false

func acknowledge() -> bool:
	if finished or not awaiting_ack or pending_rescue or in_crisis(): return false
	check_failure()
	if finished: return false
	awaiting_ack = false
	index += 1
	if index >= definition.steps.size():
		finished = true
		success = hp > 0 and (physiology == null or physiology.completed())
	return true
