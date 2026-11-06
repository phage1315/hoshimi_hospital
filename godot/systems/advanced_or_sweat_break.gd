extends RefCounted
## Session-only ambient presentation. Never included in persistent case records.
const PATH := "res://data/advanced_surgery/advanced_or_ambient/sweat_break_v1.json"
const ROLE_SLOTS := {
	"assistant_1": "first_assistant", "assistant_2": "second_assistant",
	"scrub_primary": "primary_scrub", "scrub_secondary": "secondary_scrub",
	"circulating_primary": "primary_circulating", "circulating_secondary": "secondary_circulating",
}
var data: Dictionary = {}
var roster: Dictionary = {}
var presentation_rng := RandomNumberGenerator.new()
var boundary_elapsed := 0.0
var consumed: Dictionary = {}
var pending_lines: Array = []
var cursor := 0
var last_variant: Dictionary = {}
var selected_group := ""

func _init(seed_value: int = 0, actual_roster: Dictionary = {}) -> void:
	roster = actual_roster.duplicate(true)
	presentation_rng.seed = seed_value ^ 0x5A9E7B41
	if not FileAccess.file_exists(PATH): return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if parsed is Dictionary and parsed.get("schema_version") == "advanced_or_ambient_sweat_v1" and parsed.get("thresholds_minutes") is Dictionary and parsed.get("variants") is Dictionary:
		data = parsed

func _present(role: String) -> bool:
	if role == "lead_surgeon": return true
	var slot := str(ROLE_SLOTS.get(role, ""))
	return not slot.is_empty() and not str(roster.get(slot, "")).is_empty()

func _wiper() -> String:
	if _present("circulating_primary"): return "circulating_primary"
	if _present("circulating_secondary"): return "circulating_secondary"
	return ""

func _eligible_variants(role: String, wiper: String) -> Array:
	var allowed: Array = []
	for variant in data.get("variants", {}).get(role, []):
		var valid := true
		for line in variant.get("lines", []):
			var speaker := str(line.get("speaker_role", ""))
			if not _present(wiper if speaker == "circulating_wiper" else speaker):
				valid = false
				break
		if valid: allowed.append(variant)
	return allowed

func on_transition(elapsed: float, safe_to_play: bool) -> void:
	if data.is_empty() or elapsed <= boundary_elapsed: return
	var candidates: Array = []
	for role in data.thresholds_minutes:
		for threshold in data.thresholds_minutes[role]:
			var minutes := int(threshold)
			if boundary_elapsed < minutes and minutes <= elapsed:
				candidates.append({"role": str(role), "minutes": minutes, "id": "SWB_%s_%d" % [role, minutes]})
	candidates.sort_custom(func(a, b): return a.minutes < b.minutes if a.minutes != b.minutes else a.id < b.id)
	var winners: Array = []
	for candidate in candidates:
		if consumed.has(candidate.id): continue
		consumed[candidate.id] = true
		if _present(candidate.role) and presentation_rng.randf() < float(data.event_probability):
			winners.append(candidate)
	boundary_elapsed = elapsed
	if not safe_to_play or not pending_lines.is_empty() or winners.is_empty(): return
	var wiper := _wiper()
	if wiper.is_empty(): return
	var eligible: Array = []
	for candidate in winners:
		var variants := _eligible_variants(candidate.role, wiper)
		if not variants.is_empty(): eligible.append({"candidate": candidate, "variants": variants})
	if eligible.is_empty(): return
	var chosen: Dictionary = eligible[presentation_rng.randi_range(0, eligible.size() - 1)]
	var variants: Array = chosen.variants.filter(func(v): return str(v.id) != str(last_variant.get(chosen.candidate.role, "")))
	if variants.is_empty(): variants = chosen.variants
	var variant: Dictionary = variants[presentation_rng.randi_range(0, variants.size() - 1)]
	last_variant[chosen.candidate.role] = variant.id
	selected_group = str(variant.id)
	pending_lines.clear()
	cursor = 0
	for line in variant.lines:
		var resolved: Dictionary = line.duplicate(true)
		if resolved.speaker_role == "circulating_wiper": resolved.speaker_role = wiper
		pending_lines.append(resolved)

func current() -> Dictionary:
	return pending_lines[cursor] if cursor < pending_lines.size() else {}

func advance() -> bool:
	if current().is_empty(): return false
	cursor += 1
	if cursor >= pending_lines.size():
		pending_lines.clear()
		cursor = 0
	return true

func skip_group() -> int:
	var remaining := pending_lines.size() - cursor
	pending_lines.clear()
	cursor = 0
	return remaining
