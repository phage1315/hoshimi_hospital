extends SceneTree
## Focused regression for user-supplied Miyuki preparation CGs.
## Read-only: loads both locales, selects real pools, renders each texture, and never saves.
const Loader = preload("res://godot/scripts/content_loader.gd")
const PATIENT_ID := "nurse_yui"
const EXPECTED := {
	"scalpel_ready_nurse_yui": {"actions": ["request_scalpel"], "path": "assets/events/ward_preparation_v1/nurse_yui/scalpel_ready.png"},
	"sterile_draping_nurse_yui": {"actions": ["ack_disinfection"], "path": "assets/events/ward_preparation_v1/nurse_yui/sterile_draping.png"},
	"urinary_catheterization_nurse_yui": {"actions": ["urinary_catheterization"], "path": "assets/events/ward_preparation_v1/nurse_yui/urinary_catheterization.png"},
	"skin_disinfection_nurse_yui": {"actions": ["skin_disinfection"], "path": "assets/events/ward_preparation_v1/nurse_yui/skin_disinfection.png"},
	"ward_surgical_cap_nurse_yui": {"actions": ["ward_surgical_cap"], "path": "assets/events/ward_preparation_v1/nurse_yui/surgical_cap.png"},
	"stretcher_transfer_nurse_yui": {"actions": ["complete_manual_ward_preparation"], "path": "assets/events/ward_preparation_v1/nurse_yui/stretcher_transfer.png"},
	"operative_positioning_nurse_yui": {"actions": ["operative_positioning"], "path": "assets/events/ward_preparation_v1/nurse_yui/operative_positioning.png"},
	"ward_skin_prep_nurse_yui": {"actions": ["ward_skin_prep", "ward_skin_prep_unnecessary"], "path": "assets/events/ward_preparation_v1/nurse_yui/skin_prep.png"},
	"ward_enema_nurse_yui": {"actions": ["ward_enema", "ward_enema_unnecessary"], "path": "assets/events/ward_preparation_v1/nurse_yui/enema.png"},
}
var checks := 0
var failures := 0
var reference_mapping: Dictionary = {}

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func texture_valid(path: String) -> bool:
	var resource_path := "res://" + path
	if not FileAccess.file_exists(resource_path) or not ResourceLoader.exists(resource_path):
		return false
	var texture = load(resource_path)
	return texture is Texture2D and texture.get_width() == 1536 and texture.get_height() == 1024

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for locale in ["zh_CN", "en"]:
		var content = Loader.new()
		expect(content.load_all(locale), "Content load failed for " + locale + ": " + str(content.errors))
		if not content.errors.is_empty():
			continue
		var app = load("res://godot/scenes/main.tscn").instantiate()
		app.saves.path = "/tmp/hoshimi-miyuki-preparation-unused-%d.json" % OS.get_process_id()
		root.add_child(app)
		app.content = content
		app.configure_game_content()
		for pool_id in EXPECTED:
			var spec: Dictionary = EXPECTED[pool_id]
			var pool: Dictionary = content.find_record("ward_preparation_cg_pools", pool_id)
			expect(not pool.is_empty(), "%s: missing pool %s" % [locale, pool_id])
			if pool.is_empty():
				continue
			expect(pool.get("patient_ids", []) == [PATIENT_ID], "%s: wrong patient scope %s" % [locale, pool_id])
			expect(pool.get("action_ids", []) == spec.actions, "%s: wrong actions %s" % [locale, pool_id])
			expect(pool.get("paths", []) == [spec.path], "%s: wrong path %s" % [locale, pool_id])
			expect(pool.get("presentation", "") == "fullscreen" and pool.get("image_fit", "") == "contain", "%s: wrong presentation %s" % [locale, pool_id])
			expect(not str(pool.get("label", "")).is_empty() and not str(pool.get("caption", "")).is_empty(), "%s: missing localized label/caption %s" % [locale, pool_id])
			expect(texture_valid(spec.path), "%s: texture unavailable or wrong dimensions %s" % [locale, spec.path])
			for action_id in spec.actions:
				expect(app.ward_preparation_cg_pool_for(action_id, PATIENT_ID, "general_abdominal").get("id", "") == pool_id, "%s: pool is unreachable %s/%s" % [locale, pool_id, action_id])
				for other_id in ["doc_sayaka", "doc_serika", "patient_comoli_harcourt"]:
					expect(app.ward_preparation_cg_pool_for(action_id, other_id, "general_abdominal").get("id", "") != pool_id, "%s: pool leaked to %s" % [locale, other_id])
			var mapping := {"action_ids": pool.action_ids, "patient_ids": pool.patient_ids, "paths": pool.paths, "presentation": pool.presentation, "image_fit": pool.image_fit}
			if locale == "zh_CN":
				reference_mapping[pool_id] = mapping
			else:
				expect(mapping == reference_mapping.get(pool_id, {}), "Locale changed technical mapping: " + pool_id)
			app.base("", "", false)
			app.show_ward_preparation_fullscreen(pool, Callable())
			await process_frame
			var node = app.page.get_node_or_null("WardPreparationCG")
			expect(node is TextureRect and node.texture != null and node.texture.resource_path.trim_prefix("res://") == spec.path, "%s: fullscreen render failed %s" % [locale, pool_id])
			expect(app.page.get_node_or_null("WardPreparationCGContinue") is Button, "%s: fullscreen continue missing %s" % [locale, pool_id])
		app.queue_free()
		await process_frame
	print("MIYUKI PREPARATION ASSETS: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures else 0)
