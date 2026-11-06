extends RefCounted
## Non-canonical catalog; never registered with narrative schedulers or H pools.
const PATH := "res://data/daydreams/index.json"
const LEVELS := ["normal", "intense", "dark"]

static func entries() -> Array:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return data.get("events", []) if data is Dictionary else []

static func localized(value: Dictionary, locale: String) -> String:
	return str(value.get(locale, ""))

static func bilingual(value: Variant) -> bool:
	if not value is Dictionary or not value.get("zh_CN") is String or not value.get("en") is String:
		return false
	if value.zh_CN.strip_edges().is_empty() or value.en.strip_edges().is_empty():
		return false
	var english: String = str(value.en)
	for index in range(english.length()):
		var code: int = english.unicode_at(index)
		if (code >= 0x3400 and code <= 0x9FFF) or (code >= 0x3040 and code <= 0x30FF):
			return false
	return true

static func valid_read_ids(value: Variant) -> bool:
	if not value is Array: return false
	var seen := {}
	for id in value:
		if not id is String or id.is_empty() or seen.has(id): return false
		seen[id] = true
	return true

static func character_is_met(actor: String, game: RefCounted) -> bool:
	# Acquaintance is independent of recruitment and romance.
	if bool(game.relationships.get(actor, {}).get("met", false)): return true
	var cameos: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/patients/cameo_patients.json"))
	if cameos is Array:
		for cameo in cameos:
			if str(cameo.get("id", "")) != actor: continue
			var flag: String = str(cameo.get("identity_reveal_flag", ""))
			return not flag.is_empty() and game.story_flag(flag)
	return false

static func valid_gate(gate: Variant) -> bool:
	# Daydreams require acquaintance only, never romance or completion of a
	# relationship event. Reject unsupported keys rather than silently ignoring.
	if not gate is Dictionary: return false
	for key in gate:
		if key not in ["met", "levels"]: return false
	if not valid_read_ids(gate.get("met", [])): return false
	var levels: Variant = gate.get("levels", {})
	if not levels is Dictionary: return false
	for actor in levels:
		if not actor is String or actor.is_empty(): return false
		var value: Variant = levels[actor]
		if not (value is int or value is float) or value != 0: return false
	return true

static func unlocked(entry: Dictionary, game: RefCounted) -> bool:
	if not valid_gate(entry.get("gate", {})): return false
	var gate: Dictionary = entry.get("gate", {})
	for actor in gate.get("met", []):
		if not character_is_met(str(actor), game): return false
	for actor in gate.get("levels", {}):
		if not character_is_met(str(actor), game): return false
	return true

static func visible(entry: Dictionary, maximum: int) -> bool:
	var level := LEVELS.find(str(entry.get("level", "")))
	return level >= 0 and level <= clampi(maximum, 0, 2)

static func valid(entry: Dictionary) -> bool:
	if str(entry.get("id", "")).is_empty() or not visible(entry, 2): return false
	if not valid_gate(entry.get("gate", {})): return false
	for field in ["title", "cast", "tags", "unlock_hint"]:
		if not bilingual(entry.get(field)): return false
	var nodes: Variant = entry.get("nodes")
	if not nodes is Array or nodes.is_empty(): return false
	var ids := {}
	for node in nodes:
		if not node is Dictionary or str(node.get("id", "")).is_empty() or ids.has(node.id): return false
		ids[node.id] = true
		if not bilingual(node.get("text")) or not bilingual(node.get("speaker_label")): return false
		if not node.get("choices") is Array or node.choices.is_empty(): return false
		var choices := {}
		for choice in node.choices:
			if not choice is Dictionary or str(choice.get("id", "")).is_empty() or choices.has(choice.id) or not bilingual(choice.get("label")): return false
			choices[choice.id] = true
			# A daydream can never carry canonical effect instructions.
			if choice.has("effects") or choice.has("next_if_choice"): return false
		if node.has("effects"): return false
	if not ids.has(entry.get("start", "")): return false
	for node in nodes:
		for choice in node.choices:
			if choice.get("next", "") != "@end" and not ids.has(choice.get("next", "")): return false
	return not entry.has("effects") and int(entry.get("minutes", 0)) == 0

static func definition(entry: Dictionary, locale: String) -> Dictionary:
	if not valid(entry): return {}
	var result := entry.duplicate(true)
	result.title = localized(entry.title, locale)
	result.minutes = 0
	for node in result.nodes:
		node.text = localized(node.text, locale)
		node.speaker_label = localized(node.speaker_label, locale)
		node["expression"] = node.get("expression", "neutral")
		for choice in node.choices:
			choice.label = localized(choice.label, locale)
	return result
