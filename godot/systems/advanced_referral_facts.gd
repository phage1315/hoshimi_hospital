extends RefCounted
## Exact persistence whitelist. This schema contains no runner or presentation state.
static func fresh() -> Dictionary:
	return {"version": 2, "activated_day": 0, "unlocked": [], "new_board": [], "clear_days": {}, "successful_operation_days": {}, "procedures": {}, "cooldowns": {}, "week": -1, "replays": [], "appointment": {}, "outcome": {}, "completed": []}

static func keys_only(d: Variant, keys: Array) -> bool:
	if not d is Dictionary: return false
	for key in d:
		if key not in keys: return false
	return true

static func number(v: Variant, minimum: int = 0) -> bool:
	return (v is int or v is float) and is_finite(float(v)) and float(v) == floorf(float(v)) and float(v) >= minimum

static func case_valid(v: Variant) -> bool:
	if not keys_only(v, ["id", "procedure_id", "patient_id", "replay", "case_seed", "case_subtype"]): return false
	if v.has("case_subtype") and (not v.case_subtype is String or v.case_subtype.is_empty()): return false
	for key in ["id", "procedure_id", "patient_id"]:
		if not v.get(key) is String or str(v[key]).is_empty(): return false
	return v.get("replay") is bool and (not v.has("case_seed") or number(v.case_seed))

static func valid(v: Variant) -> bool:
	if not keys_only(v, ["version", "procedures", "cooldowns", "week", "replays", "appointment", "outcome", "completed", "activated_day", "unlocked", "new_board", "clear_days", "successful_operation_days"]): return false
	if v.is_empty(): return true # Older safe-boundary saves.
	if not number(v.get("version"), 1) or int(v.version) not in [1, 2] or not number(v.get("week"), -1): return false
	if v.version == 2:
		if not number(v.get("activated_day")): return false
		for key in ["unlocked", "new_board"]:
			if not v.get(key) is Array: return false
			var seen := []
			for id in v[key]:
				if not id is String or id.is_empty() or id in seen: return false
				seen.append(id)
		if v.new_board.size() > 3: return false
		for key in ["clear_days", "successful_operation_days"]:
			if not v.get(key) is Dictionary: return false
			for id in v[key]:
				if not id is String or id.is_empty() or not number(v[key][id], 1): return false
	for key in ["procedures", "cooldowns", "appointment", "outcome"]:
		if not v.get(key) is Dictionary: return false
	for status in v.procedures.values():
		if status not in ["CLEARED", "FAILED_LOCKED"]: return false
	for day in v.cooldowns.values():
		if not number(day, 1): return false
	if not v.get("replays") is Array or not v.get("completed") is Array: return false
	for record in v.replays:
		if not case_valid(record): return false
	var a: Dictionary = v.appointment
	if not a.is_empty():
		if not keys_only(a, ["case", "team", "intake_day", "operation_day", "review_day", "intake_minutes"]): return false
		if not case_valid(a.get("case")) or not a.get("team") is Dictionary: return false
		var roles := ["first_assistant", "second_assistant", "primary_scrub", "secondary_scrub", "primary_circulating", "secondary_circulating", "anesthesia"]
		if not keys_only(a.team, roles) or a.team.size() != 7: return false
		var ids := []
		for id in a.team.values():
			if not id is String or id.is_empty() or id in ids: return false
			ids.append(id)
		for key in ["intake_day", "operation_day", "review_day", "intake_minutes"]:
			if not number(a.get(key), 1): return false
		if a.operation_day <= a.intake_day or a.review_day <= a.operation_day: return false
	var o: Dictionary = v.outcome
	if not o.is_empty():
		if a.is_empty() or not keys_only(o, ["case_id", "success", "operation_day", "minutes"]): return false
		if o.get("case_id") != a.case.id or not o.get("success") is bool or o.get("operation_day") != a.operation_day or not number(o.get("minutes"), 1): return false
	var completed_ids := []
	for record in v.completed:
		if not keys_only(record, ["case_id", "procedure_id", "success", "day", "minutes", "surgery_xp", "leadership_xp", "reputation"]): return false
		if not record.get("case_id") is String or record.case_id in completed_ids or not record.get("procedure_id") is String or not record.get("success") is bool: return false
		for key in ["day", "minutes", "surgery_xp", "reputation"]:
			if not number(record.get(key)): return false
		if not (record.get("leadership_xp") is float or record.get("leadership_xp") is int) or not is_finite(float(record.leadership_xp)) or float(record.leadership_xp) < 0: return false
		completed_ids.append(record.case_id)
	if not a.is_empty() and a.case.id in completed_ids: return false
	return true
