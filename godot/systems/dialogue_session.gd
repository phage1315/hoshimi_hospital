extends RefCounted
## Pure state traversal; no UI nodes or character-specific conditions.
var nodes: Dictionary = {}
var current_id: String = ""

func start(story: Dictionary) -> void:
	nodes.clear()
	for node in story.nodes:
		nodes[node.id] = node
	current_id = story.start

func current() -> Dictionary:
	return nodes.get(current_id, {})

func advance(choice_index: int = -1) -> String:
	var node := current()
	if node.has("choices"):
		if choice_index < 0 or choice_index >= node.choices.size():
			return current_id
		current_id = node.choices[choice_index].target
	else:
		current_id = node.get("next", "@map")
	return current_id
