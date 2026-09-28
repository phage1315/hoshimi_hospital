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
