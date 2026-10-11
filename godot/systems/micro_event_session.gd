extends RefCounted

var definition: Dictionary
var trigger_day := 1
var choice_id := ""
var last_choice: Dictionary = {}
var completed := false
var opening_index := 0
var response_index := 0
var last_error := ""

func snapshot_state() -> Dictionary:
	return {
		"trigger_day": trigger_day,
		"choice_id": choice_id,
		"last_choice": last_choice.duplicate(true),
		"completed": completed,
		"opening_index": opening_index,
		"response_index": response_index,
	}

func restore_state(state: Dictionary) -> bool:
	var raw_day: Variant = state.get("trigger_day", 0)
	if not (raw_day is int or raw_day is float) or int(raw_day) < 1:
		return false
	trigger_day = int(raw_day)
	choice_id = str(state.get("choice_id", ""))
	last_choice = state.get("last_choice", {}).duplicate(true) if state.get("last_choice", {}) is Dictionary else {}
	completed = bool(state.get("completed", false))
	opening_index = maxi(0, int(state.get("opening_index", 0)))
	response_index = maxi(0, int(state.get("response_index", 0)))
	last_error = ""
	return true

func _init(data: Dictionary, day: int = 1) -> void:
	definition = data
	trigger_day = day

func opening_lines() -> Array:
	var lines: Variant = definition.get("opening_lines", [])
	if lines is Array and not lines.is_empty():
		return lines
	return [{"speaker": "actor", "text": str(definition.get("prompt", ""))}]

func at_choice() -> bool:
	return opening_index >= opening_lines().size() - 1

func advance_opening() -> bool:
	if completed or at_choice():
		return false
	opening_index += 1
	return true

func response_lines() -> Array:
	if not completed or last_choice.is_empty():
		return []
	var lines: Array = [{
		"speaker": "player",
		"text": str(last_choice.get("label", "")),
	}, {
		"speaker": "actor",
		"text": str(last_choice.get("response", "")),
		"expression": str(last_choice.get("expression", definition.get("expression", "neutral"))),
	}]
	var closing: Variant = definition.get("closing_lines", [])
	if closing is Array:
		lines.append_array(closing)
	return lines

func response_finished() -> bool:
	return completed and response_index >= response_lines().size() - 1

func advance_response() -> bool:
	if not completed or response_finished():
		return false
	response_index += 1
	return true

func apply(id: String) -> bool:
	last_error = "这个日常片段已经结束。"
	if completed:
		return false
	for choice in definition.choices:
		if choice.id == id:
			choice_id = id
			last_choice = choice
			completed = true
			response_index = 0
			last_error = ""
			return true
	last_error = "这个选项不存在。"
	return false
