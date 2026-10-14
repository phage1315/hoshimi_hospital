extends RefCounted
## Read actual loaded content, not directory names: old/unregistered art is excluded.

static func add_path(paths: Dictionary, value: Variant) -> void:
	if value is String and value.begins_with("assets/") and value.ends_with(".png"):
		paths[value] = true

static func scan_story(value: Variant, paths: Dictionary, protected: Dictionary) -> void:
	if value is Dictionary:
		add_path(paths, value.get("cg_path", ""))
		add_path(protected, value.get("portrait_path", ""))
		var gallery: Variant = value.get("gallery", {})
		if gallery is Dictionary:
			add_path(paths, gallery.get("path", ""))
		for key in value:
			scan_story(value[key], paths, protected)
	elif value is Array:
		for item in value:
			scan_story(item, paths, protected)

static func collect(content: RefCounted) -> Dictionary:
	var groups := {"backgrounds": {}, "story_cg": {}, "role_cg": {}, "anesthesia_cg": {}}
	var protected: Dictionary = {}
	for row in content.collections.backgrounds:
		add_path(groups.backgrounds, row.get("path", ""))
	for row in content.collections.staff_role_cg_rewards:
		add_path(groups.role_cg, row.get("path", ""))
	for collection in ["staff", "patients", "cameo_patients"]:
		for actor in content.collections.get(collection, []):
			var portraits: Dictionary = actor.get("visuals", {}).get("portraits", {})
			for key in portraits:
				if key in ["splash/general_anesthesia", "splash/epidural_anesthesia", "splash/general_anesthesia_pre_induction"]:
					add_path(groups.anesthesia_cg, portraits[key])
				else:
					add_path(protected, portraits[key])
	scan_story(content.collections, groups.story_cg, protected)
	scan_story(content.dialogue, groups.story_cg, protected)
	var result := {"groups": {}, "protected": protected.keys()}
	for key in groups:
		result.groups[key] = groups[key].keys()
	return result
