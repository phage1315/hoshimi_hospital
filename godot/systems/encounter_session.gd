extends RefCounted
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
var player_effects: Dictionary = {"skill": 0, "ethics": 0, "charisma": 0, "intimidation": 0, "reputation": 0}
var player_effect_history: Array[Dictionary] = []

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
			player_effects[metric] = int(player_effects.get(metric, 0)) + int(effects[metric])
		player_effect_history.append({"id": action.id, "label": action.label, "effects": effects.duplicate(true)})
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
