extends RefCounted
## Map presence only. Clinical teams and personal-nurse attendance do not use it.
var roster: Array = []

func _init(staff_data: Array = []) -> void:
	roster = staff_data

func staff_at(location_id: String, day: int, absolute_clock: int, eligible_actor_ids: Array[String]) -> Array[String]:
	if location_id == "rooftop":
		return rooftop_staff_at(day, absolute_clock, eligible_actor_ids)
	var assignments := hourly_assignments(day, absolute_clock, eligible_actor_ids)
	var result: Array[String] = []
	for actor_id in assignments:
		if assignments[actor_id] == location_id:
			result.append(str(actor_id))
	return result

func ordinary_locations(raw: Array, excluded: Array[String] = []) -> Array[String]:
	var result: Array[String] = []
	for value in raw:
		var location := str(value)
		# Legacy profiles may still list rooftop; it is never an ordinary slot.
		if not location.is_empty() and location != "rooftop" and location not in excluded and location not in result:
			result.append(location)
	result.sort()
	return result

func hourly_assignment(person: Dictionary, day: int, absolute_clock: int) -> String:
	var presence: Dictionary = person.get("presence", {})
	var fixed := ordinary_locations(presence.get("fixed_locations", []))
	var random_places := ordinary_locations(presence.get("random_locations", []), fixed)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("hourly_presence_v2:%s:%s:%s" % [day, floori(float(absolute_clock) / 60), person.id])
	var choices: Array[String] = fixed if rng.randi_range(0, 99) < 80 else random_places
	# A character with no fixed post is absent in the 80% branch.
	return "" if choices.is_empty() else choices[rng.randi_range(0, choices.size() - 1)]

func eligible_staff(eligible_actor_ids: Array[String]) -> Array:
	var people: Array = []
	for person in roster:
		if str(person.id) in eligible_actor_ids:
			people.append(person)
	people.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.id) < str(b.id))
	return people

func hourly_assignments(day: int, absolute_clock: int, eligible_actor_ids: Array[String]) -> Dictionary:
	var assignments: Dictionary = {}
	var lounge_candidates: Array[String] = []
	for person in eligible_staff(eligible_actor_ids):
		var actor_id := str(person.id)
		assignments[actor_id] = hourly_assignment(person, day, absolute_clock)
		var presence: Dictionary = person.get("presence", {})
		if "lounge" in presence.get("fixed_locations", []) or "lounge" in presence.get("random_locations", []):
			lounge_candidates.append(actor_id)
	# Noon is an explicit exception to 80/20, not a second presence roll:
	# relocate exactly one eligible colleague only if the lounge is empty.
	if absolute_clock >= 720 and absolute_clock < 780 and not lounge_candidates.is_empty() and not assignments.values().has("lounge"):
		var rng := RandomNumberGenerator.new()
		rng.seed = hash("lounge_noon_v2:%s" % day)
		assignments[lounge_candidates[rng.randi_range(0, lounge_candidates.size() - 1)]] = "lounge"
	return assignments

func rooftop_staff_at(day: int, absolute_clock: int, eligible_actor_ids: Array[String]) -> Array[String]:
	var candidates: Array[String] = []
	for person in eligible_staff(eligible_actor_ids):
		if bool(person.get("presence", {}).get("rooftop_enabled", true)):
			candidates.append(str(person.id))
	var result: Array[String] = []
	if candidates.is_empty():
		return result
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("rooftop_presence_v2:%s:%s" % [day, floori(float(absolute_clock) / 30)])
	if rng.randi_range(0, 99) < 50:
		result.append(candidates[rng.randi_range(0, candidates.size() - 1)])
	return result
