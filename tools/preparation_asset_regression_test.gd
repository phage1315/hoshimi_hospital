extends SceneTree
## BUG-006: fullscreen preparation art is distinct from table portraits and
## anesthesia splashes. Uses real loader, selector, event dispatcher and UI.
## Fixtures only change in-memory session state; never save or switch preferences.
const Loader = preload("res://godot/scripts/content_loader.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const PreopView = preload("res://godot/ui/preop_view.gd")
const COMOLI := "patient_comoli_harcourt"
const OR_ACTIONS := ["operative_positioning", "urinary_catheterization", "skin_disinfection", "ack_disinfection", "request_scalpel"]
const PREPARATION_CG_ACTIONS := ["ward_enema", "ward_enema_unnecessary", "ward_skin_prep", "ward_skin_prep_unnecessary", "ward_surgical_cap", "complete_manual_ward_preparation", "urinary_catheterization", "skin_disinfection", "ack_disinfection", "request_scalpel"]
# Minimum inventory prevents a deleted bundle/pool from silently reducing coverage.
const EXPECTED_OR_POOLS := {
	"patient_aerith": ["sterile_draping", "incision"],
	"patient_tifa": ["urinary_catheterization", "skin_disinfection", "scalpel_ready"],
	"patient_emi_koda": ["incision_ready"],
	"patient_amate_yuzuriha": ["operative_positioning", "operative_positioning_female_pelvic", "incision"],
	"patient_nyaan": ["operative_positioning_female_pelvic", "incision"],
	"patient_sepha": ["urinary_catheterization", "incision_ready"],
	"patient_kocho_shinobu": ["sterile_draping", "urinary_catheterization", "incision"],
	"patient_makimura_kaori": ["incision", "urinary_catheterization", "operative_positioning_female_pelvic"],
	"patient_nogami_saeko": ["skin_disinfection", "urinary_catheterization", "sterile_draping", "incision"],
	"patient_iwai_yoshimi": ["operative_positioning", "urinary_catheterization", "incision_ready"],
	"patient_shimizu_iraiza": ["ward_skin_prep", "ward_enema", "stretcher_transfer", "urinary_catheterization", "sterile_draping", "incision_ready"],
	"patient_yuko_asou": ["ward_skin_prep", "ward_enema", "ward_surgical_cap", "stretcher_transfer", "urinary_catheterization", "skin_disinfection", "sterile_draping", "incision_ready"],
}
var checks := 0
var failures := 0
var rendered_events := 0
var suppressed_events := 0
var locale := ""
var reference_pools: Dictionary = {}
var reference_portraits: Dictionary = {}

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("[%s] %s" % [locale, message])

func _initialize() -> void:
	call_deferred("run")

func texture_valid(path: String) -> bool:
	if path.is_empty() or not FileAccess.file_exists("res://" + path):
		return false
	if not ResourceLoader.exists("res://" + path):
		print("[%s] UNLOADABLE RESOURCE: %s; source exists=true, import sidecar=%s" % [locale, path, FileAccess.file_exists("res://" + path + ".import")])
		return false
	var texture = load("res://" + path)
	return texture is Texture2D and texture.get_width() > 0 and texture.get_height() > 0

func texture_matches(node: Node, paths: Array) -> bool:
	return node is TextureRect and node.texture != null and paths.has(node.texture.resource_path.trim_prefix("res://"))

func fixture(app, patient_id: String, surgery_id: String = "surgery_appendix") -> RefCounted:
	var short_id := patient_id.trim_prefix("patient_")
	var id := "preop_" + short_id
	var definition: Dictionary = app.content.find_record("preops", id).duplicate(true)
	if definition.is_empty():
		expect(false, "Missing preop fixture: " + id)
		return null
	# Use the loaded authored definition rather than a randomized case assignment.
	app.game.preop_definitions[id] = definition
	var visit = app.game.open_visit("visit_" + short_id)
	if visit == null:
		expect(false, "Could not admit fixture: " + patient_id)
		return null
	visit.admitted = true
	var c: Dictionary = app.content.collections
	var prep = Preop.new(definition, c.staff, c.surgeries, c.patients, [], false, c.surgery_team_dialogue_profiles, c.patient_interactions, c.temporary_conditions)
	expect(prep.english_mode() == (locale == "en"), "Session locale differs from loader: " + patient_id)
	prep.procedure_id = surgery_id
	prep.procedure_name = str(app.content.find_record("surgeries", surgery_id).get("name", ""))
	prep.refresh_operative_positioning_stage()
	prep.team = {"assistant_surgeon": "doc_aoi", "anesthesiologist": "doc_shiori", "scrub_nurse": "nurse_yui", "circulating_nurse": "nurse_haru"}
	app.game.preops.clear()
	app.game.preops[id] = prep
	app.game.active_preop_id = id
	app.game.active_id = "visit_" + short_id
	app.game.active_mode = "preop"
	return prep

func prepare_action(prep: RefCounted, action_id: String) -> bool:
	# Bounded search of actual session stages, including runtime-added OR stages.
	prep.definition.surgery_id = "surgery_breast_tumor" if action_id.ends_with("_unnecessary") else "surgery_appendix"
	for stage in prep.stages.values() + prep.ward_preparation_stages():
		for action in stage.get("actions", []):
			if str(action.get("id", "")) != action_id:
				continue
			prep.stage_id = str(stage.id)
			prep.flags.assign(["anesthesia_chosen", "local_anesthesia"])
			prep.anesthesia = "局部麻醉" # Authored invariant, including in English.
			if action_id == "incise_epidural":
				prep.flags.assign(["anesthesia_chosen", "epidural_anesthesia"])
				prep.anesthesia = "硬膜外麻醉"
			elif action_id == "incise_none":
				prep.flags.assign(["anesthesia_chosen", "no_anesthesia_confirmed"])
				prep.anesthesia = "未麻醉"
			for flag in action.get("requires", []) + action.get("show_if_flags", []):
				if not prep.flags.has(flag):
					prep.flags.append(flag)
			return true
	return false

func surgery_for_group(app, group: String) -> String:
	for surgery in app.content.collections.surgeries:
		if str(surgery.get("procedure_group", "")) == group and str(surgery.get("status", "ready")) != "placeholder":
			return str(surgery.id)
	return ""

func session_has_action(prep: RefCounted, action_id: String) -> bool:
	# Optional ward actions are generated for non-abdominal procedures only.
	prep.definition.surgery_id = "surgery_breast_tumor" if action_id.ends_with("_unnecessary") else "surgery_appendix"
	for stage in prep.stages.values() + prep.ward_preparation_stages():
		for action in stage.get("actions", []):
			if action.get("id", "") == action_id:
				return true
	return false

func check_event(app, patient_id: String, pool: Dictionary, action_id: String, group: String) -> void:
	var surgery_id := surgery_for_group(app, group)
	expect(not surgery_id.is_empty(), "No surgery for pool group: " + group)
	if surgery_id.is_empty():
		return
	var prep = fixture(app, patient_id, surgery_id)
	if prep == null:
		return
	var mapped := prepare_action(prep, action_id)
	var context := "%s/%s/%s" % [pool.id, action_id, group]
	expect(mapped, "Unknown action_id: " + context)
	if not mapped:
		return
	var before: int = prep.events.size()
	app.preop_event({"kind": "action", "id": action_id})
	await process_frame
	expect(prep.events.size() == before + 1, "Action rejected: %s (%s)" % [context, prep.last_error])
	expect(app.screen == "ward_preparation_cg" and texture_matches(app.page.get_node_or_null("WardPreparationCG"), pool.paths), "Fullscreen dispatch/texture failed: " + context)
	var cg = app.page.get_node_or_null("WardPreparationCG")
	if cg is TextureRect:
		expect(cg.anchor_right == 1.0 and cg.anchor_bottom == 1.0 and cg.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "CG is not fullscreen: " + context)
	var next_button = app.page.get_node_or_null("WardPreparationCGContinue")
	expect(next_button is Button, "Missing fullscreen continuation: " + context)
	if next_button is Button:
		var next_stage: String = prep.stage_id
		next_button.pressed.emit()
		await process_frame
		expect(app.screen == "preop" and prep.stage_id == next_stage and app.page.get_node_or_null("WardPreparationCG") == null, "CG continuation lost session/stage: " + context)
	rendered_events += 1
	# The same legal preparation action after general anesthesia must stay hidden.
	# Awake incision IDs are not a general-anesthesia route, so exclude them here.
	if action_id not in OR_ACTIONS:
		return
	prep = fixture(app, patient_id, surgery_id)
	if prep == null or not prepare_action(prep, action_id):
		return
	prep.flags.erase("local_anesthesia")
	prep.flags.append("general_anesthesia")
	prep.flags.append("anesthetized")
	prep.anesthesia = "全身麻醉"
	before = prep.events.size()
	app.preop_event({"kind": "action", "id": action_id})
	await process_frame
	expect(prep.events.size() == before + 1, "Suppression fixture action rejected: " + context)
	expect(app.screen == "preop" and app.page.get_node_or_null("WardPreparationCG") == null and app.page.get_node_or_null("WardPreparationSplash") == null, "Authored general-anesthesia suppression changed: " + context)
	suppressed_events += 1

func check_pools(app) -> void:
	var pool_count := 0
	var or_pool_count := 0
	for pool in app.content.collections.get("ward_preparation_cg_pools", []):
		for action_id in pool.get("action_ids", []):
			expect(not str(action_id).begins_with("incise_"), "Pre-incision CG is incorrectly bound after incision: %s/%s" % [pool.id, action_id])
	for patient_id in EXPECTED_OR_POOLS:
		var bundle = JSON.parse_string(FileAccess.get_file_as_string("res://data/patients/%s/patient.json" % patient_id))
		expect(bundle is Dictionary, "Missing source bundle: " + patient_id)
		if not bundle is Dictionary:
			continue
		var source_pools: Array = bundle.get("exclusive_cg_pools", {}).get("ward_preparation", [])
		var mapping_prep = fixture(app, patient_id)
		if mapping_prep == null:
			continue
		for prefix in EXPECTED_OR_POOLS[patient_id]:
			var expected_id: String = prefix + "_" + patient_id
			expect(source_pools.any(func(p): return p.get("id", "") == expected_id), "Registered OR pool disappeared: " + expected_id)
		for source in source_pools:
			pool_count += 1
			var pool: Dictionary = app.content.find_record("ward_preparation_cg_pools", str(source.id))
			expect(not pool.is_empty(), "Loader omitted pool: " + str(source.id))
			if pool.is_empty():
				continue
			if str(pool.get("id", "")).contains("incision"):
				expect(pool.get("action_ids", []) == ["request_scalpel"], "Incision CG must be bound only to request_scalpel: " + str(pool.id))
			for key in ["id", "action_ids", "patient_ids", "paths", "procedure_groups", "presentation", "priority"]:
				expect(pool.get(key) == source.get(key), "Loader/locale changed %s/%s" % [source.id, key])
			if locale == "zh_CN":
				reference_pools[pool.id] = pool.duplicate(true)
			else:
				for key in ["action_ids", "patient_ids", "paths", "procedure_groups", "presentation"]:
					expect(pool.get(key) == reference_pools.get(pool.id, {}).get(key), "Locale-dependent CG mapping: %s/%s" % [pool.id, key])
			expect(pool.get("patient_ids", []) == [patient_id] and pool.get("presentation", "") == "fullscreen", "Wrong patient scope/presentation: " + str(pool.id))
			expect(not pool.get("paths", []).is_empty() and not pool.get("action_ids", []).is_empty(), "Empty pool: " + str(pool.id))
			for path in pool.get("paths", []):
				expect(str(path).contains("/" + patient_id + "/") and texture_valid(str(path)), "Missing or wrong-patient texture: " + str(path))
			var groups: Array = pool.get("procedure_groups", []).duplicate()
			if groups.is_empty():
				groups = ["general_abdominal"]
			var is_or := false
			for action_id in pool.get("action_ids", []):
				expect(session_has_action(mapping_prep, action_id), "Pool action absent from actual session: %s/%s" % [pool.id, action_id])
				for group in groups:
					var selected: Dictionary = app.ward_preparation_cg_pool_for(action_id, patient_id, group)
					expect(selected.get("id", "") == pool.id, "Unreachable/overridden pool: %s/%s/%s" % [pool.id, action_id, group])
					# Compare every registered patient, not merely an unknown ID.
					for other in app.content.collections.patients:
						if other.id != patient_id:
							expect(app.ward_preparation_cg_pool_for(action_id, other.id, group).get("id", "") != pool.id, "Patient CG leaked: %s -> %s" % [pool.id, other.id])
					if action_id in PREPARATION_CG_ACTIONS:
						is_or = true
						await check_event(app, patient_id, pool, action_id, group)
				if not pool.get("procedure_groups", []).is_empty():
					for excluded in ["", "general_abdominal", "female_pelvic", "breast", "urologic", "thoracic", "cardiac", "vascular"]:
						if not groups.has(excluded):
							expect(app.ward_preparation_cg_pool_for(action_id, patient_id, excluded).get("id", "") != pool.id, "Procedure-group CG leaked: %s/%s" % [pool.id, excluded])
			if is_or:
				or_pool_count += 1
			# Exercise actual path selection without probabilistic coverage assertions.
			var selected_path: String = app.ward_preparation_cg_path(pool)
			expect(pool.paths.has(selected_path), "Path selector escaped pool: " + str(pool.id))
			var next_path: String = app.ward_preparation_cg_path(pool)
			expect(pool.paths.has(next_path) and (pool.paths.size() == 1 or selected_path != next_path), "Path selection/repeat guard failed: " + str(pool.id))
		print("[%s] checked %s (%d preparation pools)" % [locale, patient_id, source_pools.size()])
	print("[%s] registered preparation pools=%d, OR pools=%d" % [locale, pool_count, or_pool_count])

func check_comoli(app) -> void:
	var patient: Dictionary = app.content.find_record("patients", COMOLI)
	expect(not patient.is_empty(), "Comoli did not load")
	if patient.is_empty():
		return
	var portraits: Dictionary = patient.get("visuals", {}).get("portraits", {})
	if locale == "zh_CN":
		reference_portraits = portraits.duplicate(true)
	else:
		expect(portraits == reference_portraits, "Comoli portrait paths/keys depend on locale")
	var table_count := 0
	for key in portraits:
		if not str(key).begins_with("operating_table") and key != "splash/general_anesthesia":
			continue
		var path := str(portraits[key])
		expect(path.contains("comoli_harcourt") and texture_valid(path), "Comoli texture unavailable: " + str(key))
		if str(key).begins_with("operating_table"):
			table_count += 1
			app.base("", "", false)
			app.add_portrait(patient, str(key).get_slice("/", 1), str(key).get_slice("/", 0))
			expect(texture_matches(app.page.get_node_or_null("CharacterPortrait"), [path]), "Comoli table portrait failed to render: " + str(key))
	expect(table_count >= 6 and portraits.has("splash/general_anesthesia"), "Comoli baseline table/splash slots missing")
	var prep = fixture(app, COMOLI)
	if prep == null:
		return
	prep.stage_id = "ready"
	app.preop_event({"kind": "action", "id": "choose_general"})
	await process_frame
	expect(prep.stage_id == "general_induction", "Comoli general-anesthesia choice rejected")
	app.preop_event({"kind": "action", "id": "induction_reassure"})
	await process_frame
	expect(prep.flags.has("anesthetized"), "Comoli induction did not take effect")
	expect(texture_matches(app.page.find_child("GeneralAnesthesiaSplashCG", true, false), [portraits.get("splash/general_anesthesia", "")]), "Comoli induction splash dispatch/texture failed")
	var close_button = app.page.find_child("AnesthesiaSplashContinue", true, false)
	expect(close_button is Button, "Comoli splash continue missing")
	if close_button is Button:
		close_button.pressed.emit()
		await process_frame
		expect(app.page.get_node_or_null("GeneralAnesthesiaSplash") == null, "Comoli splash did not dismiss")
	# Exercise portrait resolution through PreopView, including lithotomy fallback.
	for surgery_id in ["surgery_appendix", "surgery_hysterectomy"]:
		prep.procedure_id = surgery_id
		prep.stage_id = "operative_positioning"
		for expression in ["awake", "tense", "afraid", "anesthetized"]:
			prep.flags.assign(["anesthesia_chosen"])
			prep.fear = {"awake": 0, "tense": 45, "afraid": 100, "anesthetized": 0}[expression]
			prep.pain = 0
			prep.cooperation_base = 100
			if expression == "anesthetized":
				prep.flags.append("anesthetized")
			var outfit := PreopView.operating_table_outfit(prep, patient, expression)
			var expected_outfit := "operating_table_lithotomy" if surgery_id == "surgery_hysterectomy" and expression in ["awake", "tense"] else "operating_table"
			expect(outfit == expected_outfit, "Comoli lithotomy fallback changed: " + expression)
			PreopView.render(app, prep)
			expect(texture_matches(app.page.get_node_or_null("CharacterPortrait"), [portraits.get(expected_outfit + "/" + expression, "")]), "Comoli actual OR portrait resolution failed: %s/%s" % [surgery_id, expression])
	# Known content gap, not a request to invent a CG or disable suppression.
	var exclusive_count := 0
	for pool in app.content.collections.ward_preparation_cg_pools:
		if pool.get("patient_ids", []).has(COMOLI):
			exclusive_count += 1
	for action_id in OR_ACTIONS:
		for group in ["general_abdominal", "female_pelvic"]:
			expect(app.ward_preparation_cg_pool_for(action_id, COMOLI, group).is_empty(), "Comoli baseline OR gap changed; review new mapping: " + action_id)
	expect(exclusive_count == 0, "Comoli gained exclusive preparation CGs; update known-gap assertions")
	print("[%s] COMOLI CONTENT GAP: no exclusive fullscreen OR preparation pool; %d table portraits and general-anesthesia splash load/render successfully (subject to assertions)." % [locale, table_count])

func run() -> void:
	for requested_locale in ["zh_CN", "en"]:
		locale = requested_locale
		var content = Loader.new()
		var loaded: bool = content.load_all(locale)
		expect(loaded, "Content load failed: " + str(content.errors))
		if not loaded:
			continue
		var app = load("res://godot/scenes/main.tscn").instantiate()
		# Startup only checks save existence. Redirect that check to an unused
		# temporary path; no fixture calls save APIs or preference-writing APIs.
		app.saves.path = "/tmp/hoshimi-preparation-assets-unused-%d.json" % OS.get_process_id()
		root.add_child(app)
		app.content = content
		app.configure_game_content()
		for person in content.collections.staff:
			app.game.meet_staff(person.id)
		await check_pools(app)
		await check_comoli(app)
		app.queue_free()
		await process_frame
	print("PREPARATION ASSETS: %d checks; %d failure(s); %d awake OR dispatches; %d suppressed general-anesthesia dispatches" % [checks, failures, rendered_events, suppressed_events])
	quit(1 if failures else 0)
