extends RefCounted
static func procedure_pose(id: String) -> String:
	var mapping: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/staff_patient/procedure_poses.json"))
	return str(mapping.get(id, ""))
