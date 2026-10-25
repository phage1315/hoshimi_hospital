extends "res://tools/save_recovery_verify.gd"
const Codec = preload("res://godot/systems/boundary_save.gd")

func inspect_clean(value: Variant, path: String = "root") -> void:
	if value is Dictionary:
		for key in value:
			expect(key not in ["node_id", "stage_id", "choices", "choice_id", "action_log", "last_choice", "feedback", "speaker", "opening_index", "response_index", "procedure_step_index", "resolved_random_choices", "surgery_rng_seed", "case_variant_id", "diagnosis_action_order", "active_special_event", "active_adult_intimacy"], "No inner state at " + path + "." + key)
			inspect_clean(value[key], path + "." + key)
	elif value is Array:
		for item in value:
			inspect_clean(item, path)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Load content " + locale)
		var game = new_game()
		var fresh: Dictionary = game.snapshot()
		expect(fresh.get("save_format") == Codec.FORMAT, "New boundary format")
		expect(game.restore(fresh), "Fresh roundtrip: " + game.last_error)
		var legacy: Dictionary = game.runtime_snapshot()
		legacy.save_format = "state_dictionary_v1"
		legacy._slot_metadata = {"day": 1, "clock": "09:00"}
		if args.size() > 0:
			legacy = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
		var loaded: bool = game.restore(legacy)
		expect(loaded, "Legacy import: " + game.last_error)
		if not loaded:
			continue
		var clean: Dictionary = game.snapshot()
		inspect_clean(clean)
		var broken_nodes: Dictionary = legacy.duplicate(true)
		for record in broken_nodes.character_events:
			record.state.node_id = "deleted_old_node"
			record.state.choices = ["deleted_old_choice"]
		for record in broken_nodes.progress.values():
			record.stage_id = "deleted_old_clinic_step"
			record.action_log = ["deleted_old_action"]
		for record in broken_nodes.preops.values():
			record.stage_id = "deleted_old_surgery_step"
		var migrated = new_game()
		expect(migrated.restore(broken_nodes), "Old internal names cannot reject a legacy save")
		expect(same_json(migrated.snapshot(), clean), "Ignoring inner state preserves exactly the same facts")
		var retired_retry: Dictionary = legacy.duplicate(true)
		retired_retry.relationship_state.doc_sayaka.level = 0
		retired_retry.relationship_state.doc_sayaka.flags.append("sayaka_first_date_retry_pending")
		expect(migrated.restore(retired_retry), "Retired failed date imports using its stable semantic flag")
		expect(not migrated.character_event_done("sayaka_lv1_first_date"), "Old failed date is untriggered without endpoint aliases")
		expect(migrated.elapsed() == game.elapsed(), "Retiring a failed date cannot refund its time")
		expect(game.day_number() == int(legacy._slot_metadata.day), "Legacy day")
		expect(game.clock_text() == legacy._slot_metadata.clock, "Legacy clock")
		for key in Codec.GLOBAL_FIELDS:
			if key in ["patient_queue", "patient_cases", "staff_skill_levels", "unlocked_procedure_ids"]:
				continue # Current content adds default roster/cases/unlocks.
			if legacy.has(key):
				expect(same_json(clean.get(key), legacy.get(key)), "Preserve " + key)
		for actor in legacy.relationship_state:
			expect(same_json(clean.relationship_state[actor], Codec.fields(legacy.relationship_state[actor], Codec.RELATION_FIELDS)), "Relationships not replayed " + actor)
		for record in legacy.character_events:
			if record.state.completed:
				expect(game.character_event_done(record.id), "Completed event retained " + record.id)
				expect(game.character_events[record.id].choices.is_empty(), "Old choices discarded " + record.id)
		var before_attributes: Dictionary = game.player_attributes()
		var before_time: int = game.elapsed()
		for record in clean.surgery_outcomes:
			expect(game.open_preop(record) == null, "Completed surgery cannot be opened and rewarded again")
		expect(not game.finish_active_surgery(), "No duplicate settlement after import")
		var continuing = new_game()
		expect(continuing.restore(clean), "Continue from migrated boundary")
		continuing.meet_staff("doc_asuka")
		for i in range(2):
			expect(continuing.refer_current_patient("doc_asuka"), "Post-load referral " + str(i))
			expect(continuing.elapsed() == before_time, "Referral cannot subtract historical time")
		expect(continuing.spend_time("rooftop_pause"), "Post-load time action")
		expect(continuing.elapsed() == before_time + 10, "New time charged exactly once")
		continuing.time_event_definitions.rooftop_pause.minutes = 987
		expect(continuing.elapsed() == before_time + 10, "Already-paid action does not follow definition changes")
		expect(continuing.restore(continuing.snapshot()) and continuing.elapsed() == before_time + 10, "Resave retains paid action duration")
		var admitted = new_game()
		var visit = admitted.open_visit("visit_sora")
		visit.admitted = true
		visit.stage_id = str(visit.definition.completion)
		visit.minutes = 92
		admitted.active_id = ""
		var admission: Dictionary = admitted.snapshot()
		expect(admitted.restore(admission) and admitted.admitted_patient("patient_sora"), "Admission survives safe-boundary save")
		var prep = admitted.open_preop("preop_sora")
		expect(prep != null and prep.stage_id == str(prep.definition.start), "Admitted patient starts preparation at current entry")
		expect(admitted.elapsed() == 92, "Opening preparation neither recharges nor erases time")
		var memory: Dictionary = game.runtime_snapshot()
		var memory_clone = new_game()
		expect(memory_clone.restore_runtime_snapshot(memory), "Memory-only locale roundtrip: " + memory_clone.last_error)
		expect(memory_clone.elapsed() == before_time, "Memory clock stable")
		expect(not memory_clone.restore(memory), "Disk import refuses full runtime snapshots")
		var clone = new_game()
		expect(clone.restore(JSON.parse_string(JSON.stringify(clean))), "Boundary roundtrip: " + clone.last_error)
		expect(same_json(clone.snapshot(), clean), "Stable repeated save/load")
		expect(clone.player_attributes() == before_attributes, "Attributes stable")
		for definition in clone.character_event_definitions.values():
			definition.nodes = []
			definition.start = "rewritten_entry"
			definition.minutes = 999
		for definition in clone.time_event_definitions.values():
			definition.minutes = 999
			definition.responses = []
		expect(clone.restore(clean), "Authored nodes/pages/responses can be removed")
		expect(clone.elapsed() == before_time, "Script changes cannot rewrite time")
		expect(clone.player_attributes() == before_attributes, "No rewards on load")
		clone.character_event_definitions.clear()
		clone.micro_event_definitions.clear()
		expect(clone.restore(clean), "Retired event definitions do not destroy historical completion facts")
		expect(clone.snapshot().character_completions == clean.character_completions, "Retired events retain ID/date/actor/duration facts")
		var bad: Dictionary = clean.duplicate(true)
		bad.elapsed_minutes = -1
		expect(not clone.restore(bad), "Reject corrupt clock")
		expect(clone.elapsed() == before_time, "Failed load atomic")
		bad = legacy.duplicate(true)
		bad.erase("_slot_metadata")
		expect(not clone.restore(bad), "Do not guess old clock")
		bad = clean.duplicate(true)
		bad.time_log.append({"id": "rooftop_pause", "start": before_time + 1000, "minutes": 10})
		expect(not clone.restore(bad) and clone.elapsed() == before_time, "Reject future history without changing live time")
		game.active_mode = "character_event"
		expect(game.snapshot().is_empty(), "No mid-event persistent snapshot")
		game.active_mode = "encounter"
		var store = Store.new()
		store.path = "/tmp/hoshimi_boundary_save_test_%s.json" % locale
		expect(store.write_slot(game), "Write clean slot: " + store.last_error)
		var disk = new_game()
		expect(store.read_slot(disk), "Read clean slot: " + store.last_error)
		expect(same_json(disk.snapshot(), clean), "Disk roundtrip stable")
		print("STATE ", locale, " ", game.calendar_iso(), " ", game.clock_text(), " surgeries=", game.completed_surgeries_total, " bytes=", JSON.stringify(clean).length())
	print("BOUNDARY SAVE: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
