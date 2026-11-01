extends RefCounted
## Passive presentation only. No gameplay RNG, costs, or persistent cursors.
const Model = preload("res://godot/systems/advanced_surgery_model.gd")
const ROLE_MAP := {"assistant_1":"first_assistant", "assistant_2":"second_assistant", "scrub_primary":"primary_scrub", "scrub_secondary":"secondary_scrub", "circulating_primary":"primary_circulating", "circulating_secondary":"secondary_circulating", "anesthesia":"anesthesia"}
var data: Dictionary = {}
var ordinal := 0
var chosen: Dictionary = {} # Memory only; never part of BoundarySave.

func _init(procedure_id: String = "", completed_count: int = 0) -> void:
	ordinal = maxi(0, completed_count)
	var path := "res://data/advanced_surgery/dialogue/%s.json" % procedure_id
	if not FileAccess.file_exists(path): return
	var source: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if valid(source, Model.procedure(procedure_id)): data = source

static func valid(source: Variant, definition: Dictionary) -> bool:
	if not source is Dictionary or definition.is_empty(): return false
	if source.get("schema_version") != "advanced_day2_dialogue_v1" or source.get("procedure_id") != definition.id or not source.get("stages") is Dictionary: return false
	for key in source:
		if key not in ["schema_version", "procedure_id", "stages"]: return false
	var ids: Array = []
	for stage_id in source.stages:
		var matches: Array = definition.steps.filter(func(step): return step.id == stage_id)
		if matches.size() != 1 or not source.stages[stage_id] is Dictionary: return false
		var groups: Dictionary = source.stages[stage_id]
		if not groups.has("stage_entry"): return false
		for trigger in groups:
			if trigger not in ["stage_entry", "precision_failed"]: return false
			if trigger == "precision_failed" and matches[0].kind != "P": return false
			var rows: Variant = groups[trigger]
			if not rows is Array or rows.size() < 2 or rows.size() > 3: return false
			for row in rows:
				if not row is Dictionary or row.size() != 4: return false
				for key in ["id", "speaker_role", "text", "text_en"]:
					if not row.get(key) is String or row[key].strip_edges().is_empty(): return false
				if row.id in ids: return false
				ids.append(row.id)
				var role: String = row.speaker_role
				if not ROLE_MAP.has(role) and role not in ["lead_surgeon", "system", "acting_surgeon"]: return false
				if role == "acting_surgeon" and trigger != "precision_failed": return false
	return true

func select(stage_id: String, stage_index: int, trigger: String) -> Dictionary:
	var key := stage_id + ":" + trigger
	if chosen.has(key): return chosen[key]
	var rows: Array = data.get("stages", {}).get(stage_id, {}).get(trigger, [])
	if rows.is_empty(): return {}
	var offset := 1 if trigger == "precision_failed" else 0
	chosen[key] = rows[(ordinal + stage_index + offset) % rows.size()].duplicate(true)
	return chosen[key]

func current(session: RefCounted, quick: bool = false) -> Dictionary:
	if quick or session.finished or session.in_crisis() or session.splash_pending or session.patient_ready_pending or session.team_intro_index >= 0: return {}
	if (session.pending_rescue or session.awaiting_ack) and not session.last_result.has("rescue_actor"):
		if bool(session.last_result.get("failed", false)):
			var failure := select(str(session.current().id), session.index, "precision_failed")
			if not failure.is_empty(): return failure
	# Rescue acknowledgement retains the authored stage cue and its actual speaker.
	# It must not invent a line for an arbitrary team member or replay a failure cue.
	# Keep the selected stage line and its speaker visible through result acknowledgement.
	return select(str(session.current().id), session.index, "stage_entry")

static func bind_role(role: String, roster: Dictionary, result: Dictionary = {}) -> Dictionary:
	if role in ["acting_surgeon", "rescue_assistant"]:
		var key := "actor" if role == "acting_surgeon" else "rescue_actor"
		if not result.has(key): return {}
		var actor := int(result[key])
		if actor == 0: return {"id":"PLAYER", "role":"lead_surgeon"} if role == "acting_surgeon" else {}
		if actor not in [1, 2]: return {}
		role = "assistant_1" if actor == 1 else "assistant_2"
	if role in ["lead_surgeon", "system"]: return {"id":"PLAYER" if role == "lead_surgeon" else "", "role":role}
	var slot := str(ROLE_MAP.get(role, ""))
	var id := str(roster.get(slot, ""))
	return {} if id.is_empty() else {"id":id, "role":slot}

static func failure_lines() -> Array:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/dialogue/day3_failed.json"))

static func field_config(procedure_id: String) -> Dictionary:
	var registry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/field_windows.json"))
	return registry.get(procedure_id, {})

static func field_visible(session: RefCounted) -> bool:
	if session.finished or session.splash_pending or session.patient_ready_pending or session.team_intro_index >= 0: return false
	var config := field_config(str(session.definition.id))
	if config.is_empty(): return false
	var ids: Array = session.definition.steps.map(func(step): return str(step.id))
	var first := ids.find(str(config.after_stage))
	var last := ids.find(str(config.before_stage))
	if first >= 0 and last > first and session.index == last and not str(config.get("closure_path", "")).is_empty(): return true
	if first >= 0 and last > first and session.index == first and not str(config.get("incision_path", "")).is_empty(): return true
	return first >= 0 and last > first and session.index < last and (session.index > first or (session.index == first and session.awaiting_ack))

static func field_path(session: RefCounted) -> String:
	var config := field_config(str(session.definition.id))
	if str(session.current().get("id", "")) == str(config.get("before_stage", "")):
		return str(config.get("closure_path", config.get("path", "")))
	# Incision/entry is atomic: use the unopened field until that action settles.
	if str(session.current().get("id", "")) == str(config.get("after_stage", "")) and not session.awaiting_ack:
		return str(config.get("incision_path", config.get("path", "")))
	return str(config.get("path", ""))
