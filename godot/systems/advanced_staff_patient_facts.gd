extends RefCounted
## Only final business facts. No appointment, cursor, result buffer or session here.
static func fresh() -> Dictionary:
	return {"version": 1, "actors": {}}

static func clean(value: Variant) -> Dictionary:
	var result := fresh()
	if not value is Dictionary: return result
	if not value.get("actors", {}) is Dictionary: return result
	for actor in value.get("actors", {}):
		var source: Variant = value.actors[actor]
		if not source is Dictionary: continue
		var row := {"night_seen": bool(source.get("night_seen", false)), "procedures": {}}
		if not source.get("procedures", {}) is Dictionary: continue
		for procedure in source.get("procedures", {}):
			var p: Variant = source.procedures[procedure]
			if not p is Dictionary: continue
			row.procedures[str(procedure)] = {"successes": maxi(0, int(p.get("successes", 0))), "attempts": maxi(0, int(p.get("attempts", 0))), "last_day": maxi(0, int(p.get("last_day", 0))), "last_success": bool(p.get("last_success", false)), "last_minutes": maxi(0, int(p.get("last_minutes", 0)))}
		result.actors[str(actor)] = row
	return result

static func valid(value: Variant) -> bool:
	if not value is Dictionary: return false
	if value.is_empty(): return true # Older boundary saves.
	if value.keys().size() != 2 or value.get("version") != 1 or not value.get("actors") is Dictionary: return false
	for actor in value.actors:
		if not actor is String or actor.is_empty(): return false
		var row: Variant = value.actors[actor]
		if not row is Dictionary or row.size() != 2 or not row.get("night_seen") is bool or not row.get("procedures") is Dictionary: return false
		for procedure in row.procedures:
			if not procedure is String or procedure.is_empty(): return false
			var p: Variant = row.procedures[procedure]
			if not p is Dictionary or p.size() != 5 or not p.get("last_success") is bool: return false
			for key in ["successes", "attempts", "last_day", "last_minutes"]:
				var n: Variant = p.get(key)
				if not (n is int or n is float) or float(n) != floorf(float(n)) or n < 0: return false
			if p.successes > p.attempts: return false
	return true
