extends RefCounted
## Runtime for one authored character event. Choice IDs are the save format.
var definition: Dictionary
var nodes: Dictionary = {}
var node_id := ""
var choices: Array[String] = []
var completed := false
var completed_day := 0
var last_choice: Dictionary = {}
var last_error := ""

func snapshot_state() -> Dictionary:
	return {
		"node_id": node_id,
		"choices": choices.duplicate(),
		"completed": completed,
		"completed_day": completed_day,
		"last_choice": last_choice.duplicate(true),
	}

func restore_state(state: Dictionary) -> bool:
	var saved_node := str(state.get("node_id", ""))
	if saved_node.is_empty() or not nodes.has(saved_node) or not state.get("choices", []) is Array:
		return false
	node_id = saved_node
	choices.clear()
	for choice_id in state.get("choices", []):
		if not choice_id is String:
			return false
		choices.append(choice_id)
	completed = bool(state.get("completed", false))
	completed_day = int(state.get("completed_day", 0))
	last_choice = state.get("last_choice", {}).duplicate(true) if state.get("last_choice", {}) is Dictionary else {}
	last_error = ""
	return true

func _init(data: Dictionary) -> void:
	definition = data
	for node in data.nodes:
		nodes[node.id] = node
	node_id = data.start

func current() -> Dictionary:
	return nodes.get(node_id, {})

func apply(choice_id: String) -> bool:
	last_error = "这个选项当前不可用。"
	if completed or current().is_empty():
		return false
	var selected: Dictionary = {}
	for choice in current().choices:
		if choice.id == choice_id:
			selected = choice
	if selected.is_empty():
		return false
	choices.append(choice_id)
	last_choice = selected
	if selected.next == "@end":
		completed = true
	else:
		node_id = selected.next
	last_error = ""
	return true
