extends "res://tools/preparation_asset_regression_test.gd"
## Focused runtime integration test for Artoria's eight user-supplied
## preparation CGs. Fixtures are in memory and never write player saves.
const Registry = preload("res://godot/systems/staff_patient_registry.gd")
const ACTOR := "doc_artoria"
const EXPECTED := {
	"skin_disinfection_doc_artoria": {"actions": ["skin_disinfection"], "path": "assets/events/ward_preparation_v1/doc_artoria/skin_disinfection.png"},
	"sterile_draping_doc_artoria": {"actions": ["ack_disinfection"], "path": "assets/events/ward_preparation_v1/doc_artoria/sterile_draping.png"},
	"scalpel_ready_doc_artoria": {"actions": ["request_scalpel"], "path": "assets/events/ward_preparation_v1/doc_artoria/scalpel_ready.png"},
	"ward_surgical_cap_doc_artoria": {"actions": ["ward_surgical_cap"], "path": "assets/events/ward_preparation_v1/doc_artoria/surgical_cap.png"},
	"stretcher_transfer_doc_artoria": {"actions": ["complete_manual_ward_preparation"], "path": "assets/events/ward_preparation_v1/doc_artoria/stretcher_transfer.png"},
	"urinary_catheterization_doc_artoria": {"actions": ["urinary_catheterization"], "path": "assets/events/ward_preparation_v1/doc_artoria/urinary_catheterization.png"},
	"ward_skin_prep_doc_artoria": {"actions": ["ward_skin_prep", "ward_skin_prep_unnecessary"], "path": "assets/events/ward_preparation_v1/doc_artoria/skin_prep.png"},
	"ward_enema_doc_artoria": {"actions": ["ward_enema", "ward_enema_unnecessary"], "path": "assets/events/ward_preparation_v1/doc_artoria/enema.png"},
}

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
	for stage in prep.ward_preparation_stages():
		prep.stages[stage.id] = stage
	return super.prepare_action(prep, action_id)

func run() -> void:
	var technical_reference: Dictionary = {}
	for requested_locale in ["zh_CN", "en"]:
		locale = requested_locale
		var content = Loader.new()
		expect(content.load_all(locale), "Content load failed: " + str(content.errors))
		var app = load("res://godot/scenes/main.tscn").instantiate()
		app.saves.path = "/tmp/hoshimi-artoria-preparation-unused-%d.json" % OS.get_process_id()
		root.add_child(app)
		app.content = content
		app.configure_game_content()
		for person in content.collections.staff:
			app.game.meet_staff(person.id)
		for pool_id in EXPECTED:
			var spec: Dictionary = EXPECTED[pool_id]
			var pool: Dictionary = content.find_record("ward_preparation_cg_pools", pool_id)
			expect(not pool.is_empty(), "%s: missing pool %s" % [locale, pool_id])
			if pool.is_empty():
				continue
			expect(pool.get("patient_ids", []) == [ACTOR], "%s: wrong patient scope %s" % [locale, pool_id])
			expect(pool.get("action_ids", []) == spec.actions, "%s: wrong actions %s" % [locale, pool_id])
			expect(pool.get("paths", []) == [spec.path], "%s: wrong path %s" % [locale, pool_id])
			expect(pool.get("presentation", "") == "fullscreen" and pool.get("image_fit", "") == "contain", "%s: wrong presentation %s" % [locale, pool_id])
			expect(not str(pool.get("label", "")).is_empty() and not str(pool.get("caption", "")).is_empty(), "%s: missing localized label/caption %s" % [locale, pool_id])
			expect(texture_valid(spec.path), "%s: texture unavailable %s" % [locale, spec.path])
			var technical := {"action_ids":pool.action_ids, "patient_ids":pool.patient_ids, "paths":pool.paths, "presentation":pool.presentation, "image_fit":pool.image_fit}
			if locale == "zh_CN":
				technical_reference[pool_id] = technical
			else:
				expect(technical == technical_reference.get(pool_id, {}), "Locale changed technical mapping: " + pool_id)
			for action_id in spec.actions:
				expect(app.ward_preparation_cg_pool_for(action_id, ACTOR, "general_abdominal").get("id", "") == pool_id, "%s: unreachable pool %s/%s" % [locale, pool_id, action_id])
				for other_id in ["doc_sayaka", "doc_serika", "nurse_yui", "patient_comoli_harcourt"]:
					expect(app.ward_preparation_cg_pool_for(action_id, other_id, "general_abdominal").get("id", "") != pool_id, "%s: pool leaked to %s" % [locale, other_id])
				await check_event(app, ACTOR, pool, action_id, "general_abdominal")
		var prep_ui := fixture(app, ACTOR, "surgery_appendix")
		expect(prepare_action(prep_ui, "ward_enema"), "%s: prepare_action ward_enema" % locale)
		app.show_preop(Registry.PREOP_ID)
		await process_frame
		var portrait := app.page.get_node_or_null("CharacterPortrait") as TextureRect
		var expected_nude := "res://assets/characters/artoria_staff_patient_v1/doc_artoria/ward_preparation/shy.png"
		expect(portrait != null and portrait.texture != null and str(portrait.texture.resource_path) == expected_nude and portrait.texture.get_size() == Vector2(1024, 1536), "%s: manual ward prep renders ward_preparation/shy (1024x1536)" % locale)
		app.queue_free()
		await process_frame
	print("ARTORIA PREPARATION ASSETS: %d checks; %d failure(s); %d awake dispatches; %d general-anesthesia suppressions" % [checks, failures, rendered_events, suppressed_events])
	quit(1 if failures else 0)
