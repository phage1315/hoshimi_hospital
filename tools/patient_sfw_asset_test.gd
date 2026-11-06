extends SceneTree
## Complete SFW art contract for ordinary and staff patients. Read-only; never touches saves.
## Usage: godot --headless --path . --script res://tools/patient_sfw_asset_test.gd -- --kind staff --id nurse_yui
##        godot --headless --path . --script res://tools/patient_sfw_asset_test.gd -- --all --inventory

const GROUPS := {
	"outpatient": ["neutral"],
	"ward": ["neutral", "smile", "brave", "worried", "afraid", "crying"],
	"operating_table": ["awake", "tense", "afraid", "anesthetized"],
	"operating_table_lithotomy": ["awake", "tense", "afraid", "anesthetized"],
	"intraoperative": ["tense", "pain", "near_collapse", "anesthetized"],
	"splash": ["general_anesthesia"],
}
const ADVANCED_POSES := ["abdominal", "chest", "lateral", "prone"]
const AUTHOR_SUPPLIED := {
	"ordinary": ["examination/shy"],
	"staff": ["ward_preparation/shy", "h_neutral"],
}

func _initialize() -> void:
	call_deferred("_run")

func _read_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	return JSON.parse_string(file.get_as_text())

func _texture_issue(path: String, reference_only: bool = false) -> String:
	if path.strip_edges().is_empty():
		return "no mapping"
	var resource_path := path if path.begins_with("res://") else "res://" + path
	if not resource_path.to_lower().ends_with(".png"):
		return "not PNG"
	if reference_only:
		# Reference art is deliberately excluded from Godot imports; decode the PNG directly.
		if not FileAccess.file_exists(resource_path):
			return "reference file missing"
		var image := Image.new()
		if image.load(resource_path) != OK or image.get_width() <= 0 or image.get_height() <= 0:
			return "invalid reference PNG"
		return ""
	if not ResourceLoader.exists(resource_path):
		return "file/resource missing"
	var resource := load(resource_path)
	if not resource is Texture2D:
		return "not a Texture2D"
	if resource.get_width() <= 0 or resource.get_height() <= 0:
		return "empty texture"
	return ""

func _required_keys(kind: String) -> Array[String]:
	var keys: Array[String] = []
	for group in GROUPS:
		if kind == "staff" and group == "outpatient":
			continue
		for expression in GROUPS[group]:
			keys.append(group + "/" + expression)
	return keys

func _inspect(kind: String, actor_id: String, portraits: Dictionary, aliases: Dictionary, advanced: Dictionary) -> Dictionary:
	var missing: Array[Dictionary] = []
	var required := _required_keys(kind)
	for key in required:
		var source_key := str(aliases.get(key, key))
		var path := str(portraits.get(source_key, ""))
		var issue := _texture_issue(path)
		if not issue.is_empty():
			missing.append({"key": key, "source_key": source_key, "path": path, "issue": issue})
	if kind == "staff":
		for pose in ADVANCED_POSES:
			var entry: Dictionary = advanced.get(pose, {})
			# Existing author-edited runtime art may have a retained SFW reference.
			var reference_only := entry.has("sfw_reference")
			var path := str(entry.get("sfw_reference", entry.get("path", "")))
			var issue := _texture_issue(path, reference_only)
			if not issue.is_empty():
				missing.append({"key": "advanced/" + pose, "path": path, "issue": issue})
	return {
		"id": actor_id,
		"kind": kind,
		"required_sfw_count": required.size() + (ADVANCED_POSES.size() if kind == "staff" else 0),
		"missing_sfw": missing,
		"ready_sfw": missing.is_empty(),
		"author_supplied_outside_sfw": AUTHOR_SUPPLIED[kind],
	}

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var actor_id := ""
	var kind := ""
	var all_patients := args.has("--all")
	var inventory := args.has("--inventory")
	for i in args.size():
		if args[i] == "--id" and i + 1 < args.size():
			actor_id = args[i + 1]
		if args[i] == "--kind" and i + 1 < args.size():
			kind = args[i + 1]
	if not all_patients and (actor_id.is_empty() or kind not in ["ordinary", "staff"]):
		printerr("Use --kind ordinary|staff --id <id>, or --all [--inventory].")
		quit(2)
		return
	var patient_index = _read_json("res://data/patients/index.json")
	var staff_profiles = _read_json("res://data/staff_patient_profiles.json")
	var advanced_assets = _read_json("res://data/advanced_surgery/staff_patient/assets.json")
	if not patient_index is Array or not staff_profiles is Dictionary or not advanced_assets is Dictionary:
		printerr("Unable to read patient asset registries.")
		quit(2)
		return
	var results: Array[Dictionary] = []
	if all_patients or kind == "ordinary":
		var found := false
		for relative_path in patient_index:
			var data = _read_json("res://data/patients/" + str(relative_path))
			if not data is Dictionary:
				printerr("Unreadable patient bundle: ", relative_path)
				quit(2)
				return
			var patient: Dictionary = data.get("patient", {})
			var this_id := str(patient.get("id", ""))
			if not all_patients and this_id != actor_id:
				continue
			found = true
			results.append(_inspect("ordinary", this_id, patient.get("visuals", {}).get("portraits", {}), {}, {}))
		if not all_patients and not found:
			printerr("Ordinary patient not found: ", actor_id)
			quit(2)
			return
	if all_patients or kind == "staff":
		var staff_ids: Array = staff_profiles.keys() if all_patients else [actor_id]
		staff_ids.sort()
		for staff_id in staff_ids:
			var data = _read_json("res://data/staff/" + str(staff_id) + "/profile.json")
			if not data is Dictionary:
				printerr("Staff profile not found: ", staff_id)
				quit(2)
				return
			var aliases: Dictionary = staff_profiles.get(staff_id, {}).get("portrait_aliases", {})
			results.append(_inspect("staff", str(staff_id), data.get("visuals", {}).get("portraits", {}), aliases, advanced_assets.get(staff_id, {})))
	var failed := 0
	for result in results:
		var missing: Array = result["missing_sfw"]
		failed += missing.size()
		print("%s %s: %d SFW required, %d missing" % [result["kind"], result["id"], result["required_sfw_count"], missing.size()])
		for row in missing:
			print("  %s: %s (%s)" % [row["key"], row["issue"], row["path"]])
		print("  Author supplied outside SFW: ", ", ".join(result["author_supplied_outside_sfw"]))
	print("SUMMARY: %d patients, %d missing SFW resources" % [results.size(), failed])
	quit(0 if inventory or failed == 0 else 1)
