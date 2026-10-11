extends RefCounted
const Progression = preload("res://godot/systems/progression_config.gd")
## Deterministic, data-driven visit state. No UI or medical rules live here.
var definition: Dictionary
var stages: Dictionary = {}
var stage_id: String
var action_log: Array[String] = []
var notes: Dictionary = {}
var minutes := 0
var mistakes := 0
var diagnosis := ""
var admitted := false
var feedback := ""
var speaker := ""
var player_effects: Dictionary = {"charm": 0, "presence": 0, "reputation": 0}
var player_effect_history: Array[Dictionary] = []
var presence_raw := 0

func snapshot_state() -> Dictionary:
	# Save the current visit state directly. The action log is retained as data
	# for UI/history purposes only; restore_state() never replays it.
	return {
		"stage_id": stage_id,
		"action_log": action_log.duplicate(),
		"notes": notes.duplicate(true),
		"minutes": minutes,
		"mistakes": mistakes,
		"diagnosis": diagnosis,
		"admitted": admitted,
		"feedback": feedback,
		"speaker": speaker,
		"player_effects": player_effects.duplicate(true),
		"player_effect_history": player_effect_history.duplicate(true),
		"presence_raw": presence_raw,
	}

func restore_state(state: Dictionary) -> bool:
	var saved_stage := str(state.get("stage_id", ""))
	if saved_stage.is_empty() or not stages.has(saved_stage):
		return false
	if not state.get("action_log", []) is Array or not state.get("notes", {}) is Dictionary:
		return false
	var restored_player_effect_history: Array[Dictionary] = []
	var raw_player_effect_history: Variant = state.get("player_effect_history", [])
	if not raw_player_effect_history is Array:
		return false
	for record in raw_player_effect_history:
		if not record is Dictionary:
			return false
		restored_player_effect_history.append(record.duplicate(true))
	stage_id = saved_stage
	action_log.clear()
	for action_id in state.get("action_log", []):
		if not action_id is String:
			return false
		action_log.append(action_id)
	notes = state.get("notes", {}).duplicate(true)
	minutes = int(state.get("minutes", 0))
	mistakes = int(state.get("mistakes", 0))
	diagnosis = str(state.get("diagnosis", ""))
	admitted = bool(state.get("admitted", false))
	feedback = str(state.get("feedback", ""))
	speaker = str(state.get("speaker", ""))
	if state.get("player_effects", {}) is Dictionary:
		player_effects = state.player_effects.duplicate(true)
	player_effect_history = restored_player_effect_history
	presence_raw = int(state.get("presence_raw", 0))
	return true

func _init(data: Dictionary) -> void:
	definition = data
	for item in data.stages:
		stages[item.id] = item
	stage_id = data.start

func current() -> Dictionary:
	return stages[stage_id]

func completed() -> bool:
	return stage_id == definition.completion

func find_action(id: String) -> Dictionary:
	for action in current().actions:
		if action.id == id:
			return action
	return {}

func blocked_reason(action: Dictionary) -> String:
	if action_log.has(action.id):
		return "已完成"
	for required in action.requires:
		if not notes.has(required):
			return "请先完成本阶段的信息收集"
	return ""

func apply(id: String) -> bool:
	for bundle in current().get("bundles", []):
		if bundle.id == id:
			return apply_bundle(bundle)
	return apply_single(id)

func apply_single(id: String) -> bool:
	var action := find_action(id)
	if action.is_empty() or not blocked_reason(action).is_empty():
		return false
	action_log.append(id)
	minutes += int(action.minutes)
	if action.mistake:
		mistakes += 1
	for entry in action.notes:
		notes[entry.id] = entry.duplicate(true)
	var effects: Dictionary = action.get("player_effects", {})
	if not effects.is_empty():
		for metric in effects:
			if metric == "presence":
				continue
			player_effects[metric] = int(player_effects.get(metric, 0)) + int(effects[metric])
		var recorded_effects := effects.duplicate(true)
		recorded_effects.erase("presence")
		if not recorded_effects.is_empty():
			player_effect_history.append({"id": action.id, "label": action.label, "effects": recorded_effects})
	var presence_delta := int(effects.get("presence", 0)) + int(action.get("presence_delta", 0))
	if presence_delta != 0:
		var before := clampi(presence_raw, -int(Progression.PRESENCE_PHASE_CLAMPS.encounter), int(Progression.PRESENCE_PHASE_CLAMPS.encounter))
		presence_raw += presence_delta
		var after := clampi(presence_raw, -int(Progression.PRESENCE_PHASE_CLAMPS.encounter), int(Progression.PRESENCE_PHASE_CLAMPS.encounter))
		var applied := after - before
		player_effects.presence = int(player_effects.get("presence", 0)) + applied
		if applied != 0:
			player_effect_history.append({"id": action.id, "label": action.label, "effects": {"presence": applied}})
	if not action.diagnosis.is_empty():
		diagnosis = action.diagnosis
	admitted = admitted or action.admit
	feedback = action.response
	speaker = action.speaker
	if action.next != null:
		stage_id = action.next
	return true

func apply_bundle(bundle: Dictionary) -> bool:
	# Validate the whole batch first. Store original action IDs to preserve v1 saves.
	var pending: Array[String] = []
	var available := notes.duplicate()
	for id in bundle.actions:
		if action_log.has(id):
			continue
		var action := find_action(id)
		if action.is_empty() or action.next != null:
			return false
		for required in action.requires:
			if not available.has(required):
				return false
		for entry in action.notes:
			available[entry.id] = entry
		pending.append(id)
	for id in pending:
		apply_single(id)
	return not pending.is_empty()

func ui_actions() -> Array:
	var result: Array = []
	var grouped := {}
	for bundle in current().get("bundles", []):
		var remaining := 0
		for id in bundle.actions:
			grouped[id] = true
			if not action_log.has(id):
				remaining += 1
		if remaining > 0:
			result.append(bundle)
	for action in current().actions:
		if not grouped.has(action.id) and not action_log.has(action.id):
			result.append(action)
	return result

func presentation() -> Dictionary:
	if action_log.is_empty():
		return {"text": current().prompt, "speaker": current().speaker, "summary": ""}
	var last: String = action_log.back()
	for stage in stages.values():
		for bundle in stage.get("bundles", []):
			if bundle.actions.back() == last:
				var all_done := true
				for id in bundle.actions:
					all_done = all_done and action_log.has(id)
				if all_done:
					return {"text": bundle.response, "speaker": bundle.speaker, "summary": bundle.summary}
		for action in stage.actions:
			if action.id == last:
				return {"text": action.response, "speaker": action.speaker, "summary": action.get("summary", "")}
	return {"text": current().prompt, "speaker": current().speaker, "summary": ""}
