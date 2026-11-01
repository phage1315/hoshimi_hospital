extends RefCounted
## HP-only numerical model. Preview RNG never belongs to an actual operation.
static func catalog() -> Array:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/procedures.json"))

static func procedure(id: String) -> Dictionary:
	for row in catalog():
		if row.id == id: return row
	return {}

static func fixtures(id: String) -> Array:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/test_fixtures.json")).get(id, [])

static func nurse_bonus(team: Dictionary, tag: String) -> float:
	var main := minf(.035, maxf(0, float(team.primary_scrub) - 65) * .0013)
	var secondary := minf(.015, maxf(0, float(team.secondary_scrub) - 70) * .0007)
	if tag in ["adhesion", "pelvic", "neural"]: secondary *= .6
	return minf(.05, main + secondary)

static func probability(skill: int, step: Dictionary, team: Dictionary, variant: bool) -> float:
	var difficulty := int(step.difficulty) + (3 if variant and int(step.difficulty) >= 95 else 0)
	return clampf(.78 + .028 * (skill - difficulty) + nurse_bonus(team, str(step.specialty_tag)), .08, .985)

static func base_cost(skill: int, step: Dictionary) -> int:
	return int(step.hp_base) + mini(3, ceili(maxf(0, float(step.difficulty) - skill) / 12.0))

static func can_use(assistant: Dictionary, used: int, step: Dictionary) -> bool:
	return used == 0 or (used == 1 and int(assistant.skill) >= 90 and (assistant.get("universal_expert", false) or str(step.specialty_tag) in assistant.get("specialties", [])))

static func remaining_uses(assistant: Dictionary, used: int, step: Dictionary) -> int:
	var remaining := 0
	for count in range(used, 2):
		if can_use(assistant, count, step): remaining += 1
	return remaining

static func unavailable_reason(assistant: Dictionary, used: int, step: Dictionary) -> String:
	if can_use(assistant, used, step): return ""
	if used >= 2: return "quota_spent"
	if int(assistant.skill) < 90: return "skill_required"
	return "specialty_required"

static func expected_loss(skill: int, step: Dictionary, team: Dictionary) -> float:
	return base_cost(skill, step) + (1.0 - probability(skill, step, team, false)) * int(step.hp_failed_extra)

static func plan(definition: Dictionary, team: Dictionary) -> Array:
	var challenges: Array = definition.steps.filter(func(s): return s.kind == "P")
	return solve(challenges, team, 0, 0, 0, {}).choices

static func solve(nodes: Array, team: Dictionary, index: int, first: int, second: int, memo: Dictionary) -> Dictionary:
	if index == nodes.size(): return {"cost": 0.0, "choices": []}
	var key := "%s:%s:%s" % [index, first, second]
	if memo.has(key): return memo[key]
	var step: Dictionary = nodes[index]
	var best := {"cost": INF, "choices": []}
	for who in range(3):
		var skill := int(team.player)
		if who > 0:
			var assistant: Dictionary = team.assistants[who - 1]
			if not can_use(assistant, first if who == 1 else second, step): continue
			skill = int(assistant.skill)
		var rest := solve(nodes, team, index + 1, first + (1 if who == 1 else 0), second + (1 if who == 2 else 0), memo)
		var cost := expected_loss(skill, step, team) + float(rest.cost)
		if cost < float(best.cost):
			var choices: Array = [who]
			choices.append_array(rest.choices)
			best = {"cost": cost, "choices": choices}
	memo[key] = best
	return best

static func crisis_cost(team: Dictionary, rng: RandomNumberGenerator) -> int:
	var reduction := mini(4, floori(maxf(0, float(team.primary_circ) - 65) / 12) + floori(maxf(0, float(team.secondary_circ) - 70) / 25))
	return maxi(3, rng.randi_range(8, 13) - reduction)

static func checkpoint_index(definition: Dictionary, stage_number: int) -> int:
	for i in range(definition.crisis_checkpoints.size()):
		if int(definition.crisis_checkpoints[i]) == stage_number: return i
	return -1

static func simulate(definition: Dictionary, team: Dictionary, choices: Array, rng: RandomNumberGenerator) -> bool:
	var hp := 100
	var variant := rng.randf() < .25
	var p_index := 0
	for i in range(definition.steps.size()):
		var step: Dictionary = definition.steps[i]
		if step.kind == "P":
			var who := int(choices[p_index])
			p_index += 1
			var skill := int(team.player) if who == 0 else int(team.assistants[who - 1].skill)
			hp -= base_cost(skill, step)
			if rng.randf() >= probability(skill, step, team, variant): hp -= int(step.hp_failed_extra)
		else: hp -= int(step.hp_base)
		if variant and i == 1: hp -= 4
		var checkpoint: int = checkpoint_index(definition, i + 1)
		if checkpoint >= 0 and rng.randf() < float(definition.crisis_chances[checkpoint]): hp -= crisis_cost(team, rng)
		if hp <= 0: return false
	return true

static func estimate(definition: Dictionary, team: Dictionary, runs: int = 1024, seed_value: int = 20261030) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var choices := plan(definition, team)
	var successes := 0
	for _i in range(runs):
		if simulate(definition, team, choices, rng): successes += 1
	var rate := float(successes) / runs
	return {"runs": runs, "rate": rate, "rounded_percent": roundi(rate * 20.0) * 5, "plan": choices}
