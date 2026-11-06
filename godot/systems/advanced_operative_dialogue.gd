extends RefCounted
## Passive presentation only. No gameplay RNG, costs, or persistent cursors.
const Model = preload("res://godot/systems/advanced_surgery_model.gd")
const ROLE_MAP := {"assistant_1":"first_assistant", "assistant_2":"second_assistant", "scrub_primary":"primary_scrub", "scrub_secondary":"secondary_scrub", "circulating_primary":"primary_circulating", "circulating_secondary":"secondary_circulating", "anesthesia":"anesthesia"}
var data: Dictionary = {}
var ordinal := 0
var chosen: Dictionary = {} # Memory only; never part of BoundarySave.
var sequence_cursor: Dictionary = {} # V2 presentation cursor, memory only.
var history: Array = [] # Seen V2 lines; memory only, never persisted.

func _init(procedure_id: String = "", completed_count: int = 0, prefer_v2: bool = true) -> void:
	ordinal = maxi(0, completed_count)
	var path := "res://data/advanced_surgery/dialogue/%s.json" % procedure_id
	var definition := Model.procedure(procedure_id)
	var source: Variant = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else {}
	var legacy_valid := valid(source, definition)
	var overlay_path := "res://data/advanced_surgery/dialogue_v2/%s.json" % procedure_id
	if prefer_v2 and FileAccess.file_exists(overlay_path):
		var overlay: Variant = JSON.parse_string(FileAccess.get_file_as_string(overlay_path))
		if valid(overlay, definition):
			data = overlay.duplicate(true)
			if legacy_valid:
				for stage_id in data.stages:
					var legacy_stage: Dictionary = source.stages.get(stage_id, {})
					if legacy_stage.has("precision_failed"):
						data.stages[stage_id]["precision_failed"] = legacy_stage.precision_failed.duplicate(true)
			if valid(data, definition): return
			data = {}
	if legacy_valid: data = source

static func valid(source: Variant, definition: Dictionary) -> bool:
	if not source is Dictionary or definition.is_empty(): return false
	var version := str(source.get("schema_version", ""))
	if version not in ["advanced_day2_dialogue_v1", "advanced_day2_dialogue_v2"] or source.get("procedure_id") != definition.id or not source.get("stages") is Dictionary: return false
	if version == "advanced_day2_dialogue_v2" and source.stages.size() != definition.steps.size(): return false
	for key in source:
		if key not in ["schema_version", "procedure_id", "stages"]: return false
	var ids: Array = []
	for stage_id in source.stages:
		var matches: Array = definition.steps.filter(func(step): return step.id == stage_id)
		if matches.size() != 1 or not source.stages[stage_id] is Dictionary: return false
		var groups: Dictionary = source.stages[stage_id]
		if version == "advanced_day2_dialogue_v1" and not groups.has("stage_entry"): return false
		if version == "advanced_day2_dialogue_v2" and (not groups.has("before_action") or not groups.has("after_resolution")): return false
		if version == "advanced_day2_dialogue_v2":
			var before: Variant = groups.before_action
			var after: Variant = groups.after_resolution
			if not before is Array or not after is Array: return false
			if before.size() < 2 or before.size() > 3 or after.size() < 1 or after.size() > 2 or before.size() + after.size() < 3 or before.size() + after.size() > 5: return false
		for trigger in groups:
			if trigger not in (["stage_entry", "precision_failed"] if version == "advanced_day2_dialogue_v1" else ["before_action", "after_resolution", "precision_failed", "crisis"]): return false
			if trigger == "precision_failed" and matches[0].kind != "P": return false
			if trigger == "crisis" and Model.checkpoint_index(definition, definition.steps.find(matches[0]) + 1) < 0: return false
			var rows: Variant = groups[trigger]
			if not rows is Array or rows.size() < (1 if version == "advanced_day2_dialogue_v2" and trigger == "after_resolution" else 2) or rows.size() > 3: return false
			if version == "advanced_day2_dialogue_v2" and ((trigger == "crisis" and rows.size() != 3) or (trigger == "after_resolution" and rows.size() > 2)): return false
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
	if quick or session.finished or session.splash_pending or session.patient_ready_pending or session.team_intro_index >= 0: return {}
	if session.sweat_break != null:
		var ambient: Dictionary = session.sweat_break.current()
		if not ambient.is_empty(): return ambient
	if data.get("schema_version") == "advanced_day2_dialogue_v2":
		var stage_id := str(session.current().get("id", ""))
		if session.in_crisis():
			var crisis_rows: Array = data.get("stages", {}).get(stage_id, {}).get("crisis", [])
			var crisis_cursor := int(sequence_cursor.get(stage_id + ":crisis", 0))
			return crisis_rows[crisis_cursor] if crisis_cursor < crisis_rows.size() else {}
		if session.pending_rescue or (session.awaiting_ack and bool(session.last_result.get("failed", false))):
			return select(stage_id, session.index, "precision_failed")
		var phase := "after_resolution" if session.awaiting_ack else "before_action"
		var rows: Array = data.get("stages", {}).get(stage_id, {}).get(phase, [])
		var cursor := int(sequence_cursor.get(stage_id + ":" + phase, 0))
		return rows[cursor] if cursor < rows.size() else {}
	if session.in_crisis(): return {}
	if (session.pending_rescue or session.awaiting_ack) and not session.last_result.has("rescue_actor"):
		if bool(session.last_result.get("failed", false)):
			var failure := select(str(session.current().id), session.index, "precision_failed")
			if not failure.is_empty(): return failure
	# Rescue acknowledgement retains the authored stage cue and its actual speaker.
	# It must not invent a line for an arbitrary team member or replay a failure cue.
	# Keep the selected stage line and its speaker visible through result acknowledgement.
	return select(str(session.current().id), session.index, "stage_entry")

func advance_sequence(session: RefCounted) -> bool:
	var line := current(session)
	if data.get("schema_version") != "advanced_day2_dialogue_v2" or line.is_empty(): return false
	if session.sweat_break != null and not session.sweat_break.current().is_empty():
		history.append({"stage": str(session.current().get("id", "")), "phase": "sweat_break", "line": line.duplicate(true)})
		return session.sweat_break.advance()
	if not session.in_crisis() and (session.pending_rescue or (session.awaiting_ack and bool(session.last_result.get("failed", false)))): return false
	var phase := "crisis" if session.in_crisis() else "after_resolution" if session.awaiting_ack else "before_action"
	var key := str(session.current().id) + ":" + phase
	history.append({"stage": str(session.current().id), "phase": phase, "line": line.duplicate(true)})
	sequence_cursor[key] = int(sequence_cursor.get(key, 0)) + 1
	return true

func skip_sequence(session: RefCounted) -> int:
	if session.sweat_break != null and not session.sweat_break.current().is_empty():
		var skipped := 0
		while not session.sweat_break.current().is_empty():
			if not advance_sequence(session): break
			skipped += 1
		return skipped
	var skipped := 0
	while skipped < 3 and advance_sequence(session): skipped += 1
	return skipped

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
