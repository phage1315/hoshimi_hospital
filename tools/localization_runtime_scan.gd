extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const PreopSession = preload("res://godot/systems/preop_session.gd")

var failures: Array[String] = []
var han := RegEx.new()

func _initialize() -> void:
	han.compile("[一-鿿]")
	var content = Loader.new()
	if not content.load_all("en"):
		failures.append_array(content.errors)
		finish()
		return
	var game = GameState.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases)
	# Case-template history arrays are source material consumed by GameState. The
	# generated encounters below are what players actually see.
	for collection_name in ["staff", "patients", "encounters", "preops", "surgeries", "locations", "backgrounds", "time_events"]:
		scan(content.collections.get(collection_name, []), "content." + collection_name)
	scan(game.definitions, "game.encounters")
	scan(game.preop_definitions, "game.preops")
	for preop_id in game.preop_definitions:
		var session = PreopSession.new(game.preop_definitions[preop_id], content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, [], false)
		scan(session.stages, "runtime_preop." + str(preop_id))
	finish()

func scan(value: Variant, path: String) -> void:
	if failures.size() >= 250:
		return
	if value is Dictionary:
		for key in value:
			if str(key) in ["visuals", "personality", "appearance", "dialogue_style", "characterization"]:
				continue
			scan(value[key], path + "." + str(key))
	elif value is Array:
		for index in range(value.size()):
			scan(value[index], path + "." + str(index))
	elif value is String and han.search(value) != null:
		failures.append(path + " = " + str(value).replace("\n", " ").left(140))

func finish() -> void:
	print("RUNTIME ENGLISH SCAN: %s Chinese leak(s)" % failures.size())
	for item in failures:
		print(item)
	quit(1 if not failures.is_empty() else 0)
