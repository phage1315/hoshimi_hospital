extends RefCounted

var roster: Array = []

func _init(staff_data: Array = []) -> void:
	roster = staff_data

func staff_at(location_id: String, day: int, absolute_clock: int) -> Array[String]:
	var result: Array[String] = []
	var lunch := absolute_clock >= 720 and absolute_clock < 780
	for person in roster:
		var presence: Dictionary = person.get("presence", {})
		var random_location := random_assignment(person, day, absolute_clock, lunch)
		if random_location == location_id or (random_location.is_empty() and location_id in presence.get("fixed_locations", [])):
			result.append(str(person.id))
	if location_id not in ["lounge", "rooftop"]:
		return result
	var capacity: int = 2 if location_id == "lounge" else 1
	if result.size() > capacity:
		result.resize(capacity)
	return result

func random_assignment(person: Dictionary, day: int, absolute_clock: int, lunch: bool) -> String:
	var locations: Array = person.get("presence", {}).get("random_locations", [])
	if locations.is_empty():
		return ""
	var block := absolute_clock / 60
	var score := absi(hash("%s:%s:%s" % [day, block, person.id]))
	# Fixed posts are guaranteed during work blocks. The lunch block distributes
	# staff deterministically between the lounge and rooftop for that day.
	if not lunch:
		return ""
	return str(locations[score % locations.size()])
