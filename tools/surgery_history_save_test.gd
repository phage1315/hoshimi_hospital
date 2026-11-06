extends "res://tools/boundary_save_test.gd"
## Optional -- <player-save.json>. The supplied file is read-only; file-I/O
## roundtrips use uniquely named /tmp slots, never user://.
const AdvancedModel = preload("res://godot/systems/advanced_surgery_model.gd")
const Settlement = preload("res://godot/systems/advanced_settlement.gd")

func roundtrip(game, label: String) -> void:
	var clean: Dictionary = game.snapshot()
	expect(not clean.is_empty(), label + " safe snapshot")
	inspect_clean(clean)
	var store = Store.new()
	store.path = "/tmp/hoshimi_surgery_history_%s_%s.json" % [OS.get_process_id(), Time.get_ticks_usec()]
	expect(store.write_slot(game), label + " write isolated slot")
	var clone = new_game()
	expect(store.read_slot(clone), label + " read isolated slot: " + store.last_error)
	expect(same_json(clone.snapshot(), clean), label + " all facts stable")
	expect(clone.player_attributes() == game.player_attributes(), label + " no repeated rewards")
	expect(clone.elapsed() == game.elapsed(), label + " time stable")
	expect(clone.restore(clone.snapshot()), label + " second restore")
	expect(same_json(clone.snapshot(), clean), label + " second restore stable")

func catalog_independence() -> void:
	var game = new_game()
	# Normalize existing roster/default migrations before testing history changes.
	expect(game.restore(game.snapshot()), "Fresh boundary normalization")
	var baseline: Dictionary = game.snapshot()
	var fixture: Dictionary = baseline.duplicate(true)
	# Unknown IDs model retired definitions and additions from a newer content
	# build. Historical identity is not permission to run that operation.
	var ids := ["surgery_retired_ordinary", "surgery_adv_retired_advanced"]
	for definition in AdvancedModel.catalog(): ids.append(str(definition.id))
	for id in ids:
		fixture.surgery_xp_history.append({"id": "paid_" + id, "label": "Settled award", "effects": {}, "surgery_id": id, "xp": 10})
		fixture.completed_surgeries_by_procedure[id] = 1
		fixture.surgical_quality_records[id] = {"best_score": 90, "quick_surgery_unlocked": true}
	fixture.unlocked_procedure_ids.append("surgery_retired_ordinary")
	fixture.completed_surgeries_by_group["retired_group"] = 2
	fixture.staff_patient_practice_counts["nurse_yui"] = {"surgery_retired_ordinary": 1}
	var loaded: bool = game.restore(fixture)
	expect(loaded, "History accepts both catalogs and retired IDs: " + game.last_error)
	if not loaded: return
	for field in ["surgery_xp_history", "completed_surgeries_by_procedure", "surgical_quality_records", "completed_surgeries_by_group", "staff_patient_practice_counts"]:
		expect(same_json(game.snapshot()[field], fixture[field]), "Preserve " + field)
	expect(game.unlocked_procedure_ids.has("surgery_retired_ordinary"), "Preserve historical unlock")
	expect(not game.procedure_unlocked("surgery_retired_ordinary"), "Retired unlock cannot execute")
	expect(not game.procedure_sweep_unlocked("surgery_retired_ordinary"), "Retired quality cannot enable quick surgery")
	roundtrip(game, "catalog independent")
	# Actually remove a current ordinary definition, including its old unlock.
	var removed_id: String = str(baseline.unlocked_procedure_ids[0])
	var before: Dictionary = game.snapshot()
	game.surgery_definitions = game.surgery_definitions.filter(func(row): return str(row.id) != removed_id)
	expect(game.restore(before), "Removing ordinary definition cannot reject a save")
	expect(not game.procedure_unlocked(removed_id), "Removed ordinary procedure is unavailable")
	expect(same_json(game.snapshot(), before), "Removed catalog entry does not erase facts")
	# Adding a definition must not alter historical results or pay rewards.
	game.surgery_definitions.append({"id": "surgery_retired_ordinary", "status": "placeholder"})
	expect(game.restore(before), "Adding a placeholder definition cannot reject history")
	expect(not game.procedure_unlocked("surgery_retired_ordinary"), "Placeholder unlock remains unavailable")
	expect(same_json(game.snapshot(), before), "Catalog addition does not rewrite history")
	# Keep rejecting malformed data, independently of catalog membership.
	for field in ["surgery_xp_history", "unlocked_procedure_ids", "completed_surgeries_by_procedure", "surgical_quality_records", "completed_surgeries_by_group", "staff_patient_practice_counts"]:
		var bad: Dictionary = JSON.parse_string(JSON.stringify(before))
		match field:
			"surgery_xp_history": bad[field][0].surgery_id = ""
			"unlocked_procedure_ids": bad[field].append(17)
			"completed_surgeries_by_procedure": bad[field]["surgery_retired_ordinary"] = -1
			"surgical_quality_records": bad[field][""] = {}
			"completed_surgeries_by_group": bad[field]["retired_group"] = 0.5
			"staff_patient_practice_counts": bad[field].nurse_yui[""] = 1
		expect(not game.restore(bad), "Reject malformed " + field)
		expect(same_json(game.snapshot(), before), "Rejected " + field + " leaves world unchanged")

func actual_settlement() -> void:
	for id in ["surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction", "surgery_adv_sleeve_lobectomy"]:
		var game = new_game()
		expect(game.restore(game.snapshot()), "Normalize fresh settlement fixture")
		Settlement.new().settle(game, AdvancedModel.procedure(id), {})
		expect(game.completed_surgeries_by_procedure.get(id) == 1, "Actual advanced settlement " + id)
		var saved: Dictionary = game.snapshot()
		expect(game.restore(saved), "Fresh advanced settlement reads back: " + game.last_error)
		expect(same_json(game.snapshot(), saved), "Settlement rewards not repeated")

func player_file(path: String) -> void:
	var hash_before := FileAccess.get_sha256(path)
	var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var store = Store.new()
	store.path = path
	var game = new_game()
	var loaded: bool = store.read_slot(game)
	expect(loaded, "Player original reads unchanged: " + store.last_error)
	if loaded:
		var clean: Dictionary = game.snapshot()
		for field in ["elapsed_minutes", "completed_surgeries_total", "surgery_xp", "leadership_xp", "surgery_xp_history", "leadership_xp_history", "completed_surgeries_by_procedure", "completed_surgeries_by_group", "surgical_quality_records", "character_completions", "clinical_visits", "surgery_outcomes"]:
			expect(same_json(clean[field], original[field]), "Player retains " + field)
		var expected_flags: Dictionary = original.story_flags.duplicate(true)
		# Existing advanced-referral V2 migration adds these two false gates.
		for flag in ["kaori_advanced_prerequisite_met", "ray_legendary_prerequisite_met"]:
			if not expected_flags.has(flag): expected_flags[flag] = false
		expect(same_json(clean.story_flags, expected_flags), "All original flags retained; only existing V2 defaults added")
		for actor in original.relationship_state:
			expect(same_json(clean.relationship_state[actor], original.relationship_state[actor]), "Player relationship " + actor)
		roundtrip(game, "player file")
		var retired = new_game()
		retired.surgery_definitions = [] # No current ordinary catalog, including old groups/unlocks.
		expect(retired.restore(original), "Player history survives removal of every ordinary definition")
		expect(same_json(retired.snapshot(), clean), "Retiring ordinary catalog preserves player facts")
		for id in clean.unlocked_procedure_ids:
			expect(not retired.procedure_unlocked(id), "No execution through retired unlock " + id)
		print("PLAYER ", game.calendar_iso(), " ", game.clock_text(), " elapsed=", game.elapsed(), " surgeries=", game.completed_surgeries_total)
	expect(FileAccess.get_sha256(path) == hash_before, "Source file untouched")

func run() -> void:
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Load " + locale)
		catalog_independence()
		actual_settlement()
		var args := OS.get_cmdline_user_args()
		if not args.is_empty(): player_file(args[0])
	print("SURGERY HISTORY SAVE: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
