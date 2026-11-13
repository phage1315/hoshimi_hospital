extends RefCounted
## Release QA, not an alternate runtime unlock rule. Preloaded routes may be incomplete.
const Registry = preload("res://godot/systems/staff_patient_registry.gd")
const Present = preload("res://godot/systems/advanced_presentation.gd")
const PHASES := ["consult", "night", "dark", "after", "success", "failure"]
const POSES := ["abdominal", "chest", "lateral", "prone"]

static func _placeholders(value: String, pattern: RegEx) -> Array[String]:
	var found: Array[String] = []
	for token in pattern.search_all(value):
		found.append(token.get_string())
	found.sort()
	return found

static func _compare_dialogue(source: Variant, translated: Variant, path: String, missing: Array, han: RegEx, placeholders: RegEx) -> void:
	if source is Dictionary:
		if not translated is Dictionary:
			missing.append("dialogue:en:" + path)
			return
		for key in source:
			if not translated.has(key):
				missing.append("dialogue:en:" + path + "." + str(key))
			else:
				_compare_dialogue(source[key], translated[key], path + "." + str(key), missing, han, placeholders)
		for key in translated:
			if not source.has(key):
				missing.append("dialogue:zh_CN:" + path + "." + str(key))
	elif source is Array:
		if not translated is Array or source.size() != translated.size():
			missing.append("dialogue:en:" + path + ".length")
			return
		for index in source.size():
			_compare_dialogue(source[index], translated[index], path + "." + str(index), missing, han, placeholders)
	elif source is String:
		if not translated is String or (not source.is_empty() and translated.strip_edges().is_empty()):
			missing.append("dialogue:en:" + path)
			return
		if han.search(translated) != null:
			missing.append("dialogue:en:han:" + path)
		if _placeholders(source, placeholders) != _placeholders(translated, placeholders):
			missing.append("dialogue:en:placeholder:" + path)
	elif typeof(source) != typeof(translated):
		missing.append("dialogue:en:type:" + path)

static func validate_dialogue(profile: Dictionary) -> Array:
	var missing: Array = []
	var dialogue: Dictionary = profile.get("dialogue", {})
	if not dialogue.get("zh_CN") is Dictionary or not dialogue.get("en") is Dictionary:
		return ["dialogue:zh_CN/en"]
	if not dialogue.zh_CN.get("invitation_lines") is Array or dialogue.zh_CN.invitation_lines.is_empty():
		missing.append("dialogue:invitation_lines")
	if dialogue.zh_CN.get("reaction_lines", {}).is_empty() and str(profile.get("dialogue_profile", "")).is_empty():
		missing.append("dialogue:reaction_lines_or_profile")
	var han := RegEx.new()
	han.compile("[一-鿿]")
	var placeholders := RegEx.new()
	placeholders.compile("\\{[A-Za-z_][A-Za-z0-9_]*\\}|%(?:0?\\d+)?[sdif]")
	_compare_dialogue(dialogue.zh_CN, dialogue.en, "", missing, han, placeholders)
	return missing

static func texture_ok(path: String) -> bool:
	if path.is_empty(): return false
	var resource_path := path if path.begins_with("res://") else "res://" + path
	if not ResourceLoader.exists(resource_path): return false
	var texture = load(resource_path)
	return texture is Texture2D and texture.get_width() > 0 and texture.get_height() > 0

static func validate(story: Dictionary, portraits: Dictionary, poses: Dictionary) -> Array:
	var missing: Array = []
	for title in ["title", "title_en"]:
		if str(story.get(title, "")).strip_edges().is_empty(): missing.append(title)
	for phase in PHASES:
		var lines: Array = story.get(phase, [])
		if lines.is_empty(): missing.append("story:" + phase)
		for row in lines:
			if row.get("speaker", "") not in ["player", "patient", "narrator"]: missing.append("speaker:" + phase)
			for field in ["text", "text_en"]:
				if str(row.get(field, "")).strip_edges().is_empty(): missing.append("story:" + phase + ":" + field)
	# These are the actual chapter / anesthesia display keys, not ordinary uniforms.
	for key in ["ward/neutral", "h_neutral", "intraoperative/anesthetized", "splash/general_anesthesia"]:
		if not texture_ok(str(portraits.get(key, ""))): missing.append("portrait:" + key)
	for key in portraits:
		if not texture_ok(str(portraits[key])): missing.append("unloadable:" + key)
	for pose in POSES:
		if not texture_ok(str(poses.get(pose, {}).get("path", ""))): missing.append("pose:" + pose)
	return missing

static func inspect_actor(game, actor: String, texts: Dictionary, assets: Dictionary) -> Dictionary:
	var missing: Array = []
	var portraits := {}
	var person: Dictionary = game.staff_record(actor)
	if person.is_empty(): missing.append("staff_record")
	var profile: Dictionary = Registry.profile(actor)
	if profile.is_empty():
		missing.append("staff_patient_profile")
	else:
		missing.append_array(validate_dialogue(profile))
		var mischief: Dictionary = Registry.mischief_profiles().get(actor, {})
		if not mischief.is_empty():
			var han := RegEx.new()
			han.compile("[一-鿿]")
			var placeholders := RegEx.new()
			placeholders.compile("\\{[A-Za-z_][A-Za-z0-9_]*\\}|%(?:0?\\d+)?[sdif]")
			var md: Dictionary = mischief.get("dialogue", {})
			if not md.get("zh_CN") is Dictionary or not md.get("en") is Dictionary:
				missing.append("mischief_dialogue:zh_CN/en")
			else:
				_compare_dialogue(md.zh_CN, md.en, "mischief", missing, han, placeholders)
	# Inventory existing assets even before a future patient's profile is registered.
	portraits = person.get("visuals", {}).get("portraits", {}).duplicate()
	var free_registry = preload("res://godot/systems/free_h_registry.gd")
	var h_path := str(free_registry.definition(actor).get("profile", ""))
	if not h_path.is_empty():
		var h_profile: Dictionary = free_registry.read_json(h_path)
		portraits["h_neutral"] = str(h_profile.get("assets", {}).get("portrait_expressions", {}).get("neutral", ""))
	if not person.is_empty() and not profile.is_empty():
		var patient := Present.patient({"staff_patient_id": actor, "procedure_id": "surgery_open_whipple"}, game, false)
		portraits = patient.get("visuals", {}).get("portraits", {}).duplicate()
		# Table picture is validated once per explicit pose below.
		portraits.erase("team_confirmation")
	missing.append_array(validate(texts.get("actors", {}).get(actor, {}), portraits, assets.get(actor, {})))
	return {"actor": actor, "missing": missing, "ready": missing.is_empty()}
