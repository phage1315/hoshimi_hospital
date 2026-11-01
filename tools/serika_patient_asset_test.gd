extends "res://tools/preparation_asset_regression_test.gd"
## Real dispatcher/render checks, using only isolated in-memory admissions.
const Registry = preload("res://godot/systems/staff_patient_registry.gd")
const ACTOR := "doc_serika"

func fixture(app, patient_id: String, surgery_id: String = "surgery_appendix") -> RefCounted:
	var c: Dictionary = app.content.collections
	var person: Dictionary = app.content.find_record("staff", patient_id)
	var patient: Dictionary = Registry.patient_record(person, locale)
	var definition: Dictionary = Registry.preop_definition(person, app.content.find_record("surgeries", surgery_id), locale)
	var prep = Preop.new(definition, c.staff, c.surgeries, [patient], [], false, c.surgery_team_dialogue_profiles, c.patient_interactions, c.temporary_conditions)
	prep.procedure_id = surgery_id
	prep.procedure_name = str(app.content.find_record("surgeries", surgery_id).name)
	prep.refresh_operative_positioning_stage()
	prep.team = {"assistant_surgeon":"doc_aoi", "anesthesiologist":"doc_shiori", "scrub_nurse":"nurse_yui", "circulating_nurse":"nurse_haru", "ward_nurse":"nurse_haru"}
	app.game.preops.clear()
	app.game.preops[Registry.PREOP_ID] = prep
	app.game.preop_definitions[Registry.PREOP_ID] = definition
	app.game.active_staff_patient = {"staff_id":patient_id, "procedure_id":surgery_id}
	app.game.active_preop_id = Registry.PREOP_ID
	app.game.active_mode = "preop"
	return prep

func prepare_action(prep: RefCounted, action_id: String) -> bool:
	prep.definition.surgery_id = "surgery_breast_tumor" if action_id.ends_with("_unnecessary") else "surgery_appendix"
	# Registry admissions cache the ward stages at construction time.
	for stage in prep.ward_preparation_stages():
		prep.stages[stage.id] = stage
	return super.prepare_action(prep, action_id)

func run() -> void:
	for requested_locale in ["zh_CN", "en"]:
		locale = requested_locale
		var content = Loader.new()
		expect(content.load_all(locale), "Content load: " + str(content.errors))
		var app = load("res://godot/scenes/main.tscn").instantiate()
		app.saves.path = "/tmp/hoshimi-serika-asset-unused-%d.json" % OS.get_process_id()
		root.add_child(app)
		app.content = content
		app.configure_game_content()
		for person in content.collections.staff: app.game.meet_staff(person.id)
		var actor: Dictionary = content.find_record("staff", ACTOR)
		var patient: Dictionary = Registry.patient_record(actor, locale)
		var remaining: Array = JSON.parse_string(FileAccess.get_file_as_string("res://docs/qa/serika_patient_assets_2026_10_31/remaining_assets_manifest.json"))
		expect(remaining.size() == 19, "Nineteen approved patient assets")
		for entry in remaining:
			expect(patient.visuals.portraits.get(entry.key, "") == entry.target, "Patient mapping " + entry.key)
			expect(texture_valid(entry.target), "Approved asset loads " + entry.key)
			expect(FileAccess.get_sha256("res://" + entry.source) == entry.sha256 and FileAccess.get_sha256("res://" + entry.target) == entry.sha256, "Byte-identical approved asset " + entry.key)
		var portrait_path: String = patient.visuals.portraits["examination/shy"]
		expect(portrait_path == "assets/characters/relationship_patient_v1/doc_serika/ward_preparation/shy.png" and texture_valid(portrait_path), "Ward preparation alias and resource")
		expect(not actor.visuals.portraits.has("examination/shy"), "Patient alias must not alter doctor presentation")
		expect(actor.visuals.portraits["intraoperative_avatar/neutral"].contains("intraoperative_staff_avatars_v1/doc_serika"), "Doctor avatar preserved")
		var prep = fixture(app, ACTOR)
		expect(prepare_action(prep, "ward_skin_prep"), "Ward fixture action")
		prep.flags.append("manual_ward_preparation")
		PreopView.render(app, prep)
		await process_frame
		expect(texture_matches(app.page.get_node_or_null("CharacterPortrait"), [portrait_path]), "Actual ward portrait render")
		var count := 0
		for pool in content.collections.ward_preparation_cg_pools:
			if pool.get("patient_ids", []) != [ACTOR]: continue
			count += 1
			expect(pool.presentation == "fullscreen" and pool.image_fit == "contain", "Preserve supplied image aspect and full framing")
			expect(not str(pool.caption).is_empty() and (locale != "en" or str(pool.caption).begins_with("Serika Misono")), "Localized resource label")
			for path in pool.paths: expect(texture_valid(path), "CG loads: " + path)
			for action in pool.action_ids:
				expect(app.ward_preparation_cg_pool_for(action, ACTOR).id == pool.id, "Exclusive pool priority")
				expect(app.ward_preparation_cg_pool_for(action, "doc_sayaka").get("id", "") != pool.id, "No leakage into Sayaka")
				await check_event(app, ACTOR, pool, action, "general_abdominal")
			expect(not pool.action_ids.any(func(id): return str(id).begins_with("incise_")), "Before-incision art must precede incision")
		expect(count == 9, "Exactly nine supplied CG pools")
		app.queue_free()
		await process_frame
	print("SERIKA PATIENT ASSETS: %d checks; %d failure(s); %d awake dispatches; %d general-anesthesia suppressions" % [checks, failures, rendered_events, suppressed_events])
	quit(1 if failures else 0)
