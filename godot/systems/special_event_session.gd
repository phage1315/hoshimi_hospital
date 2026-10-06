extends RefCounted
## Runtime for one full-day or multi-day special event.
## Only authored choice IDs are persisted; world-state rewards live in GameState.

var definition: Dictionary
var steps: Dictionary = {}
var step_index := 0
var node_id := ""
var choices: Array[String] = []
var locals: Dictionary = {}
var last_choice: Dictionary = {}
var started_day := 1
var completed := false
var last_day_finished := false
var last_error := ""

func _init(data: Dictionary, step_data: Dictionary, day: int = 1) -> void:
	definition = data
	steps = step_data
	started_day = day
	_reset_to_step(0)

func _reset_to_step(index: int) -> void:
	step_index = index
	var step := current_step()
	node_id = str(step.get("start", ""))

func current_step() -> Dictionary:
	var chain: Array = definition.get("event_chain", [])
	if step_index < 0 or step_index >= chain.size():
		return {}
	return steps.get(str(chain[step_index]), {})

func current() -> Dictionary:
	for node in current_step().get("nodes", []):
		if str(node.get("id", "")) == node_id:
			return node
	return {}

func jump_to(destination: String) -> bool:
	if destination.is_empty() or destination == "@day_end":
		return false
	for node in current_step().get("nodes", []):
		if str(node.get("id", "")) == destination:
			node_id = destination
			return true
	return false

func apply(choice_id: String) -> bool:
	last_day_finished = false
	last_error = "这个选项当前不可用。"
	if completed or current().is_empty():
		return false
	var selected: Dictionary = {}
	for choice in current().get("choices", []):
		if str(choice.get("id", "")) == choice_id:
			selected = choice
			break
	if selected.is_empty():
		return false
	last_choice = selected.duplicate(true)
	choices.append(choice_id)
	_apply_local_effects(selected.get("effects", {}))
	var destination := str(selected.get("next", ""))
	if destination == "@day_end":
		last_day_finished = true
		if step_index + 1 >= definition.get("event_chain", []).size():
			completed = true
		else:
			_reset_to_step(step_index + 1)
	else:
		node_id = destination
	last_error = ""
	return true

func _apply_local_effects(effects: Variant) -> void:
	if not effects is Dictionary:
		return
	var style := str(effects.get("tutorial_style", ""))
	if not style.is_empty():
		var counts: Dictionary = locals.get("tutorial_style_counts", {})
		counts[style] = int(counts.get(style, 0)) + 1
		locals["tutorial_style_counts"] = counts
	var tone := str(effects.get("tutorial_tone", ""))
	if not tone.is_empty():
		locals["tutorial_tone"] = tone
	var local_updates: Dictionary = effects.get("set_local", {})
	for key in local_updates:
		locals[str(key)] = local_updates[key]

func dominant_tutorial_style() -> String:
	var counts: Dictionary = locals.get("tutorial_style_counts", {})
	var best := "steady"
	var best_count := -1
	for style in ["cautious", "steady", "team_oriented"]:
		var count := int(counts.get(style, 0))
		if count > best_count:
			best = style
			best_count = count
	return best
