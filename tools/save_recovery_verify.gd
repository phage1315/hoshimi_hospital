extends SceneTree
## Read-only source/recovered-slot checks; optional third path is an isolated
## round-trip output. Never writes to the supplied source or recovered file.
const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Store = preload("res://godot/systems/save_store.gd")
var content = Loader.new()
var checks := 0
var failures := 0

func same_json(a: Variant, b: Variant) -> bool:
	# JSON.parse represents numbers as floats; restore casts counters to ints.
	# Compare values recursively without treating that representation as progress loss.
	if (a is int or a is float) and (b is int or b is float):
		return float(a) == float(b)
	if a is Dictionary and b is Dictionary:
		if a.size() != b.size():
			return false
		for key in a:
			if not b.has(key) or not same_json(a[key], b[key]):
				return false
		return true
	if a is Array and b is Array:
		if a.size() != b.size():
			return false
		for i in range(a.size()):
			if not same_json(a[i], b[i]):
				return false
		return true
	return a == b

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func new_game():
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps, content.collections.date_profiles, content.collections.date_locations, content.collections.advanced_referral_cases, content.collections.first_surgery_diagnosis_reactions, content.collections.palpation_profiles, content.collections.awake_special_barks)
	return game

func verify_progress(game, original: Dictionary) -> void:
	var snapshot: Dictionary = game.snapshot()
	expect(game.day_number() == original._slot_metadata.day, "Original day retained")
	expect(game.clock_text() == original._slot_metadata.clock, "Original clock retained")
	for key in ["completed_surgeries_total", "completed_surgeries_by_procedure", "completed_surgeries_by_group", "surgery_xp", "leadership_xp", "archived_clinical_minutes", "story_time_advance_minutes", "discarded_overtime_minutes", "personal_nurse_id", "staff_skill_levels", "staff_training_credits"]:
		expect(same_json(snapshot[key], original[key]), "Preserve " + key)
	for actor_id in original.relationship_state:
		for key in ["met", "level", "route", "affection", "familiarity", "flags", "event_history", "rank_history", "unlocked_benefits"]:
			expect(snapshot.relationship_state[actor_id][key] == original.relationship_state[actor_id][key], "Preserve relationship " + actor_id + "/" + key)
	for record in original.character_events:
		var restored = game.character_events[record.id]
		expect(restored.completed == record.state.completed and restored.completed_day == record.state.completed_day, "Preserve event completion " + record.id)
		expect(restored.choices.is_empty(), "Historical choice paths discarded " + record.id)
	for key in ["progress", "preops"]:
		var fact_key := "clinical_visits" if key == "progress" else "surgery_outcomes"
		expect(snapshot[fact_key].size() == original[key].size(), "No lost clinical facts " + key)
		for id in original[key]:
			expect(snapshot[fact_key][id].minutes == original[key][id].minutes, "Clinical minutes retained " + id)
	print("VERIFIED STATE: ", game.calendar_iso(), " ", game.clock_text(), " day=", game.day_number(), " surgeries=", game.completed_surgeries_total)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var args = OS.get_cmdline_user_args()
	if args.size() != 3 or args[0] == args[1] or FileAccess.file_exists(args[2]):
		push_error("Usage: -- original.json recovered.json unused-scratch-roundtrip.json")
		quit(1)
		return
	var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	var recovered: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(args[1]))
	# Exact scope audit: no changes except two completed endpoint mappings and
	# four historical timestamp repairs, including no version bump or rewards.
	var expected: Dictionary = original.duplicate(true)
	var endpoints := {"intro_pharmacist_manami":"im0_0040", "intro_doc_rei":"m0_0056"}
	for record in expected.character_events:
		if endpoints.has(record.id):
			expect(record.state.completed and record.state.node_id == "reply_0", "Known completed legacy endpoint")
			record.state.node_id = endpoints[record.id]
	for i in range(4):
		expect(expected.time_log[i + 2].id == "exam_chat_doc_rei" and expected.time_log[i + 2].start == 7680, "Known overlapping historical timestamp")
		expected.time_log[i + 2].start = 7800 + 30 * i
	expect(same_json(recovered, expected), "Exactly six scalar changes; all other save data identical")
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Content loads " + locale)
		var game = new_game()
		var store = Store.new()
		store.path = args[0]
		expect(store.read_slot(game), "Original now imports without manual node/time repairs")
		store.path = args[1]
		var loaded: bool = store.read_slot(game)
		expect(loaded, "Recovered slot loads: " + store.last_error)
		if not loaded:
			continue
		verify_progress(game, original)
		var clone = new_game()
		expect(clone.restore(JSON.parse_string(JSON.stringify(game.snapshot()))), "Current snapshot restores " + locale)
		verify_progress(clone, original)
		if locale == "zh_CN":
			store.path = args[2]
			expect(store.write_slot(game), "Current SaveStore resaves: " + store.last_error)
			var disk_clone = new_game()
			expect(store.read_slot(disk_clone), "Resaved disk slot loads: " + store.last_error)
			verify_progress(disk_clone, original)
	print("SAVE RECOVERY: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
