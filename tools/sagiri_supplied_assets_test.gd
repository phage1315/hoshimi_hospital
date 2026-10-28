extends "res://tools/preparation_asset_regression_test.gd"
## Target-only supplied asset dispatch test; uses shared real-session fixtures.
const SAGIRI := "patient_sagiri_sakurai"

func prepare_action(prep: RefCounted, action_id: String) -> bool:
	# Rebuild ward stages for the selected required/unnecessary branch.
	prep.definition.surgery_id = "surgery_breast_tumor" if action_id.ends_with("_unnecessary") else "surgery_appendix"
	for stage in prep.ward_preparation_stages():
		prep.stages[stage.id] = stage
	prep.team[prep.definition.ward_role.id] = "nurse_rin"
	return super.prepare_action(prep, action_id)

func run() -> void:
	for requested_locale in ["zh_CN", "en"]:
		locale = requested_locale
		var content = Loader.new()
		expect(content.load_all(locale), "Content load failed")
		var app = load("res://godot/scenes/main.tscn").instantiate()
		app.saves.path = "/tmp/hoshimi-sagiri-unused-%d.json" % OS.get_process_id()
		root.add_child(app)
		app.content = content
		app.configure_game_content()
		for person in content.collections.staff:
			app.game.meet_staff(person.id)
		var bundle = JSON.parse_string(FileAccess.get_file_as_string("res://data/patients/%s/patient.json" % SAGIRI))
		var pools: Array = bundle.exclusive_cg_pools.ward_preparation
		expect(pools.size() == 9, "Expected nine supplied CGs")
		for source in pools:
			var pool: Dictionary = content.find_record("ward_preparation_cg_pools", source.id)
			expect(pool.get("paths") == source.paths, "Locale altered asset mapping")
			expect(pool.get("patient_ids") == [SAGIRI], "Wrong patient scope")
			if locale == "en":
				expect(str(pool.label).begins_with("Sagiri Sakurai"), "Missing English label")
				expect(str(pool.caption).begins_with("Sagiri Sakurai"), "Missing English caption")
			for action in pool.action_ids:
				for group in ["general_abdominal", "female_pelvic"]:
					expect(app.ward_preparation_cg_pool_for(action, SAGIRI, group).get("id") == pool.id, "Wrong selected pool")
					for other in content.collections.patients:
						if other.id != SAGIRI:
							expect(app.ward_preparation_cg_pool_for(action, other.id, group).get("id") != pool.id, "Cross-patient leak")
					await check_event(app, SAGIRI, pool, action, group)
		for action in ["skip_ward_enema", "skip_required_ward_enema", "skip_ward_skin_prep", "incise_local", "incise_epidural", "incise_none", "incise_general"]:
			expect(not str(app.ward_preparation_cg_pool_for(action, SAGIRI, "general_abdominal").get("id", "")).ends_with(SAGIRI), "Performed CG on skip/incision action")
		app.show_patient(SAGIRI, "examination", "shy")
		expect(texture_matches(app.page.get_node_or_null("CharacterPortrait"), [bundle.patient.visuals.portraits["examination/shy"]]), "Examination portrait UI mapping")
		app.queue_free()
		await process_frame
	print("SAGIRI SUPPLIED ASSETS: %d checks; %d failures; %d action dispatches; %d general-anesthesia suppression checks" % [checks, failures, rendered_events, suppressed_events])
	quit(1 if failures else 0)
