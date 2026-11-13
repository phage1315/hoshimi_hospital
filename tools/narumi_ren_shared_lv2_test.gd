extends SceneTree
## Runtime regression for the atomic Narumi/Ren shared Relationship Lv2 event.

const ID := "narumi_ren_shared_lv2_sign_here"
const ACTORS := ["doc_aoi", "nurse_haru"]
const NODE_COUNT := 294
const ENDING_CG_PATH := "assets/events/character_events/narumi_ren/narumi_ren_shared_lv2_mutual_resolve.png"
const CG_WINDOWS := {
	"assets/events/character_events/narumi_ren/narumi_ren_shared_lv2_mika_table_restraint.png": ["nr2_130", "nr2_131", "nr2_132"],
	"assets/events/character_events/narumi_ren/narumi_ren_shared_lv2_mika_preop_draping.png": ["nr2_133", "nr2_134", "nr2_135", "nr2_136", "nr2_137", "nr2_138", "nr2_139", "nr2_140", "nr2_141", "nr2_142"],
	"assets/events/character_events/narumi_ren/narumi_ren_shared_lv2_mika_scalpel_contact.png": ["nr2_146", "nr2_147", "nr2_148", "nr2_149"],
	ENDING_CG_PATH: ["nr2_287", "nr2_288", "nr2_289", "nr2_290", "nr2_291", "nr2_292", "nr2_293", "nr2_294"],
}
var app
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func no_inner(value: Variant) -> bool:
	if value is Dictionary:
		for key in value:
			if str(key) in ["node_id", "step_index", "choices", "last_choice", "action_log"]:
				return false
			if not no_inner(value[key]):
				return false
	elif value is Array:
		for item in value:
			if not no_inner(item):
				return false
	return true

func expected_cg_path(node_id: String) -> String:
	for cg_path in CG_WINDOWS:
		if node_id in CG_WINDOWS[cg_path]:
			return str(cg_path)
	return ""

func test_atomic_settlement(definition: Dictionary) -> void:
	var g = app.game
	g.reset()
	for actor_id in ACTORS:
		g.meet_staff(actor_id)
	g.relation_for("doc_aoi").level = 1
	g.relation_for("nurse_haru").level = 0
	expect(not g.complete_character_event_rank_up(definition, ID), "Malformed shared settlement rejected")
	expect(g.relationship_level("doc_aoi") == 1 and g.relationship_level("nurse_haru") == 0, "Atomic rejection mutates neither relationship")

func test_gate(definition: Dictionary) -> void:
	var g = app.game
	expect(g.prepare_character_event_test_save(ID), "Shared in-memory fixture")
	expect(g.character_event_available(definition), "Both eligible participants unlock event")
	for actor_id in ACTORS:
		expect(g.relationship_level(actor_id) == 1, actor_id + " fixture at Lv1")
		expect(int(g.relation_for(actor_id).familiarity) >= 25, actor_id + " familiarity gate prepared")
		expect(g.rank_ready(actor_id), actor_id + " reports shared rank ready")
		var ids: Array[String] = []
		for candidate in g.character_events_for(actor_id):
			ids.append(str(candidate.id))
		expect(ID in ids, actor_id + " sees the same shared event")
	g.relation_for("nurse_haru").familiarity = 24
	expect(not g.character_event_available(definition), "Either participant below familiarity blocks event")
	g.relation_for("nurse_haru").familiarity = 25
	g.relation_for("nurse_haru").level = 0
	expect(not g.character_event_available(definition), "Either participant at wrong rank blocks event")

func test_route(locale: String, branch_mask: int, coverage: Dictionary) -> void:
	var g = app.game
	var definition: Dictionary = g.character_event_definitions.get(ID, {})
	expect(g.prepare_character_event_test_save(ID), "Prepare route %s/%s" % [locale, branch_mask])
	expect(g.character_event_available(definition), "Route eligible %s/%s" % [locale, branch_mask])
	var before_day: int = g.day_number()
	var before_surgeries: int = g.completed_surgeries_total
	var before_patient: Dictionary = g.active_staff_patient.duplicate(true)
	app.show_location("lobby")
	var event = g.character_events.get(ID)
	expect(event != null and g.active_character_event_id == ID and app.screen == "character_event", "Natural lobby entry %s/%s" % [locale, branch_mask])
	if event == null:
		return
	var branch_number := 0
	var visited := {}
	var guard := 0
	while not event.completed and guard <= NODE_COUNT + 4:
		guard += 1
		var node: Dictionary = event.current()
		var node_id := str(node.id)
		expect(not visited.has(node_id), "No route cycle " + node_id)
		visited[node_id] = true
		coverage[node_id] = true
		expect(g.relationship_level("doc_aoi") == 1 and g.relationship_level("nurse_haru") == 1, "No early dual settlement " + node_id)
		expect(not g.can_save_progress() and g.snapshot().is_empty(), "No persistent event save " + node_id)
		if locale == "en":
			expect(not str(node.text).contains("「") and not str(node.text).contains("【"), "English runtime text loaded " + node_id)
		app.show_character_event()
		var background = app.page.get_node_or_null("SceneBackground")
		expect(background != null and background.texture != null, "Background loaded " + node_id)
		var portraits: Array[Node] = app.page.find_children("EventPortrait_*", "TextureRect", true, false)
		var cg := app.page.get_node_or_null("CharacterEventCG") as TextureRect
		var expected_cg := expected_cg_path(node_id)
		if not expected_cg.is_empty():
			expect(cg != null and cg.texture != null and cg.texture.resource_path == "res://" + expected_cg, "Approved CG loaded " + node_id)
			expect(cg.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "Approved CG uses cover fit " + node_id)
			expect(portraits.is_empty(), "Approved CG suppresses portrait overlays " + node_id)
		else:
			expect(cg == null, "CG does not leak outside its authored window " + node_id)
		if not expected_cg.is_empty():
			pass
		elif bool(node.hide_portrait):
			expect(portraits.is_empty(), "Narrator has no borrowed portrait " + node_id)
		else:
			var expected_portraits: Array = node.get("event_portraits", [])
			expect(portraits.size() == expected_portraits.size(), "Authored portrait count loaded " + node_id)
			for item in expected_portraits:
				var portrait: TextureRect = app.page.get_node_or_null("EventPortrait_" + str(item.id))
				expect(portrait != null and portrait.texture != null and portrait.texture.resource_path == "res://" + str(item.path), "Authored portrait loaded " + node_id + "/" + str(item.id))
				if portrait != null and str(item.id) == "shimotsuki_mika":
					var source_size := Vector2(float(portrait.texture.get_width()), float(portrait.texture.get_height()))
					var fit_scale := minf(portrait.size.x / source_size.x, portrait.size.y / source_size.y)
					var fitted_height := source_size.y * fit_scale
					var visible_bottom := portrait.position.y + (portrait.size.y + fitted_height) / 2.0
					expect(absf(visible_bottom - 540.0) < 0.75, "Visible Mika portrait meets dialogue frame " + node_id)
		var choice_index := 0
		if node.choices.size() == 2:
			choice_index = (branch_mask >> branch_number) & 1
			branch_number += 1
		app.choose_character_event(str(node.choices[choice_index].id))
	expect(guard <= NODE_COUNT + 4 and event.completed, "Route terminates %s/%s" % [locale, branch_mask])
	expect(branch_number == 2, "Both authored choices reached %s/%s" % [locale, branch_mask])
	for actor_id in ACTORS:
		expect(g.relationship_level(actor_id) == 2, actor_id + " reaches Lv2 only at ending")
		expect(g.relation_for(actor_id).rank_history.count(ID) == 1, actor_id + " has one rank fact")
		expect(g.relation_for(actor_id).event_history.count(ID) == 1, actor_id + " has one event fact")
	expect(g.story_flag("narumi_ren_hirasaka_informed") and g.story_flag("narumi_ren_shared_lv2_complete"), "Stable completion flags set")
	expect(g.day_number() == before_day + 1 and g.current_absolute_clock() == 540, "Cross-day story settles once at next safe hospital boundary")
	expect(g.completed_surgeries_total == before_surgeries and g.active_staff_patient == before_patient, "No clinical runner/patient mutation")
	expect(app.screen == "day_transition", "Cross-day completion uses transition screen")
	app.continue_after_day_transition()
	expect(app.screen == "map", "Cross-day completion returns to hospital map")
	expect(g.can_save_progress(), "Saving returns only at hospital map")
	var save: Dictionary = g.snapshot()
	expect(not save.is_empty() and no_inner(save), "Boundary save contains no event inner state")
	var settled_elapsed: int = g.elapsed()
	expect(g.restore(JSON.parse_string(JSON.stringify(save))), "Boundary save reloads")
	expect(g.elapsed() == settled_elapsed and g.relationship_level("doc_aoi") == 2 and g.relationship_level("nurse_haru") == 2, "Reload preserves dual settled result")
	expect(g.start_character_event(ID) == null, "Completed shared event cannot replay")

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/narumi_ren_shared_lv2_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Content loads " + locale)
		app.configure_game_content()
		var definition: Dictionary = app.game.character_event_definitions.get(ID, {})
		expect(not definition.is_empty() and definition.nodes.size() == NODE_COUNT, "Registered 294-page event " + locale)
		expect(str(definition.get("gallery", {}).get("path", "")) == ENDING_CG_PATH and bool(definition.get("gallery", {}).get("show_on_complete", false)), "Approved Lv2 ending CG registered in gallery " + locale)
		for cg_path in CG_WINDOWS:
			expect(ResourceLoader.exists("res://" + str(cg_path)), "Approved Lv2 CG resource exists %s/%s" % [locale, cg_path])
		if locale == "zh_CN":
			test_atomic_settlement(definition)
			test_gate(definition)
		var coverage := {}
		for branch_mask in range(4):
			test_route(locale, branch_mask, coverage)
		expect(coverage.size() == NODE_COUNT, "All authored pages covered %s %s/%s" % [locale, coverage.size(), NODE_COUNT])
	print("NARUMI REN SHARED LV2: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
