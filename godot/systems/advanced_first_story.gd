extends RefCounted
## Authored first-case presentation. No gameplay state or save schema.
static func content(record: Dictionary) -> Dictionary:
	if record.has("staff_patient_id") or bool(record.get("replay",false)): return {}
	var path := "res://data/advanced_surgery/stories/%s.json" % str(record.get("procedure_id",""))
	if not FileAccess.file_exists(path): return {}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value if value is Dictionary else {}

static func patient(record: Dictionary, english: bool) -> Dictionary:
	var p: Dictionary = content(record).get("patient",{}).duplicate(true)
	if english and not p.is_empty(): p.name = p.name_en
	return p
