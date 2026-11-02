extends RefCounted
## Release QA, not an alternate runtime unlock rule. Preloaded routes may be incomplete.
const Registry = preload("res://godot/systems/staff_patient_registry.gd")
const Present = preload("res://godot/systems/advanced_presentation.gd")
const PHASES := ["consult", "night", "dark", "after", "success", "failure"]
const POSES := ["abdominal", "chest", "lateral", "prone"]

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
	for key in ["ward/neutral", "h_neutral", "intraoperative/anesthetized"]:
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
	if Registry.profile(actor).is_empty(): missing.append("staff_patient_profile")
	# Inventory existing assets even before a future patient's profile is registered.
	portraits = person.get("visuals", {}).get("portraits", {}).duplicate()
	var free_registry = preload("res://godot/systems/free_h_registry.gd")
	var h_path := str(free_registry.definition(actor).get("profile", ""))
	if not h_path.is_empty():
		var h_profile: Dictionary = free_registry.read_json(h_path)
		portraits["h_neutral"] = str(h_profile.get("assets", {}).get("portrait_expressions", {}).get("neutral", ""))
	if not person.is_empty() and not Registry.profile(actor).is_empty():
		var patient := Present.patient({"staff_patient_id": actor, "procedure_id": "surgery_open_whipple"}, game, false)
		portraits = patient.get("visuals", {}).get("portraits", {}).duplicate()
		# Table picture is validated once per explicit pose below.
		portraits.erase("team_confirmation")
	missing.append_array(validate(texts.get("actors", {}).get(actor, {}), portraits, assets.get(actor, {})))
	return {"actor": actor, "missing": missing, "ready": missing.is_empty()}
