extends RefCounted
## Explicit legendary registration; no episode cursors or parallel completion flags.
const ID := "surgery_master_aortic_root_ascending_replacement"
const Model = preload("res://godot/systems/advanced_surgery_model.gd")

static func entries() -> Array:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/legendary_registry.json"))

static func entry(id: String) -> Dictionary:
	for row in entries():
		if row.procedure_id == id: return row
	return {}

static func ready(id: String) -> bool:
	var row := entry(id)
	if row.is_empty() or not bool(row.get("runtime_ready", false)) or Model.procedure(id).is_empty(): return false
	var story: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/stories/%s.json" % id))
	var portraits: Dictionary = story.get("patient", {}).get("visuals", {}).get("portraits", {})
	for key in row.required_portraits:
		var path := str(portraits.get(key, ""))
		if path.is_empty() or not ResourceLoader.exists("res://" + path): return false
	var fields: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/field_windows.json"))
	for key in ["path", "incision_path", "closure_path"]:
		var path := str(fields.get(id, {}).get(key, ""))
		if path.is_empty() or not ResourceLoader.exists("res://" + path): return false
	return true

static func relationship_cleared(g: RefCounted, actor: String, rank: int) -> bool:
	var slot: Dictionary = g.relationship_rank_slot(actor, rank)
	var event := str(slot.get("event_id", ""))
	return g.relationship_level(actor) >= rank and slot.get("content_status") == "authored" and not event.is_empty() and event in g.relation_for(actor).get("rank_history", []) and (g.character_event_done(event) or int(g.special_event_completion_counts.get(event, 0)) > 0)

static func gate(g: RefCounted, state: Dictionary, id: String, regular_clears: int, preview: bool = false) -> String:
	var row := entry(id)
	if row.is_empty() or state.procedures.has(id): return "unavailable"
	if not preview:
		if not g.advanced_referral_system_unlocked(): return "legendary_system_locked"
		if regular_clears < int(row.required_regular_clears): return "legendary_clears_locked"
		if not relationship_cleared(g, str(row.mentor), int(row.required_rank)): return "legendary_rank_locked"
		if not ready(id): return "legendary_assets_locked"
	return ""

static func forced_assistant(record: Dictionary) -> String:
	if bool(record.get("replay", false)): return ""
	return str(entry(str(record.get("procedure_id", ""))).get("mentor", ""))
