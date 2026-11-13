extends SceneTree
## Runtime regression for the atomic Narumi/Ren shared Relationship Lv3 event.

const ID := "narumi_ren_shared_lv3_settled_accounts"
const ACTORS := ["doc_aoi", "nurse_haru"]
const NODE_COUNT := 478
const CG_PATH := "assets/events/character_events/narumi_ren/narumi_ren_shared_lv3_strategy_alliance.png"
const CG_NODE_IDS := ["nr3_387", "nr3_388", "nr3_389", "nr3_390", "nr3_391", "nr3_392"]
const OR_CG_PATH := "assets/events/character_events/narumi_ren/narumi_ren_shared_lv3_yayoi_awake_or.png"
const OR_CG_NODE_IDS := ["nr3_184", "nr3_185", "nr3_186", "nr3_187", "nr3_188", "nr3_189"]
const PELVIC_CG_PATH := "assets/events/character_events/narumi_ren/narumi_ren_shared_lv3_yayoi_pelvic_field.png"
const PELVIC_CG_NODE_IDS := ["nr3_192", "nr3_193", "nr3_194", "nr3_195", "nr3_196", "nr3_197", "nr3_198", "nr3_199", "nr3_200", "nr3_201", "nr3_202", "nr3_203", "nr3_204", "nr3_205", "nr3_206", "nr3_207", "nr3_208"]
const PRESERVATION_CG_PATH := "assets/events/character_events/narumi_ren/narumi_ren_shared_lv3_yayoi_ovary_preserved.png"
const PRESERVATION_CG_NODE_IDS := ["nr3_209", "nr3_210", "nr3_211", "nr3_212", "nr3_213", "nr3_214", "nr3_215", "nr3_216", "nr3_217"]
var app
var checks := 0
var failures := 0
var han := RegEx.new()

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	han.compile("[㐀-鿿]")
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

func test_atomic_settlement(definition: Dictionary) -> void:
	var g = app.game
	g.reset()
	for actor_id in ACTORS:
		g.meet_staff(actor_id)
	g.relation_for("doc_aoi").level = 2
	g.relation_for("nurse_haru").level = 1
	expect(not g.complete_character_event_rank_up(definition, ID), "Malformed shared settlement rejected")
	expect(g.relationship_level("doc_aoi") == 2 and g.relationship_level("nurse_haru") == 1, "Atomic rejection mutates neither relationship")

func test_gate(definition: Dictionary) -> void:
	var g = app.game
	expect(g.prepare_character_event_test_save(ID), "Shared Lv3 in-memory fixture")
	expect(g.character_event_available(definition), "Both eligible participants unlock Lv3 event")
	for actor_id in ACTORS:
		expect(g.relationship_level(actor_id) == 2, actor_id + " fixture at Lv2")
		expect(int(g.relation_for(actor_id).familiarity) >= 40, actor_id + " familiarity gate prepared")
		expect(g.rank_ready(actor_id), actor_id + " reports shared rank ready")
		var ids: Array[String] = []
		for candidate in g.character_events_for(actor_id):
			ids.append(str(candidate.id))
		expect(ID in ids, actor_id + " sees the same shared event")
	g.relation_for("nurse_haru").familiarity = 39
	expect(not g.character_event_available(definition), "Either participant below familiarity blocks event")
	g.relation_for("nurse_haru").familiarity = 40
	g.relation_for("nurse_haru").level = 1
	expect(not g.character_event_available(definition), "Either participant at wrong rank blocks event")

func test_route(locale: String, branch_mask: int, coverage: Dictionary, render_assets: bool) -> void:
	var g = app.game
	var definition: Dictionary = g.character_event_definitions.get(ID, {})
	expect(g.prepare_character_event_test_save(ID), "Prepare route %s/%s" % [locale, branch_mask])
	expect(g.character_event_available(definition), "Route eligible %s/%s" % [locale, branch_mask])
	var before_day: int = g.day_number()
	var before_surgeries: int = g.completed_surgeries_total
	var before_patient: Dictionary = g.active_staff_patient.duplicate(true)
	app.show_location(str(definition.location_id))
	var event = g.character_events.get(ID)
	expect(event != null and g.active_character_event_id == ID and app.screen == "character_event", "Natural exam-room entry %s/%s" % [locale, branch_mask])
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
		expect(g.relationship_level("doc_aoi") == 2 and g.relationship_level("nurse_haru") == 2, "No early dual settlement " + node_id)
		expect(not g.can_save_progress() and g.snapshot().is_empty(), "No persistent event save " + node_id)
		if locale == "en":
			expect(han.search(str(node.text)) == null, "English runtime text loaded " + node_id)
		if render_assets:
			app.show_character_event()
			var background = app.page.get_node_or_null("SceneBackground")
			expect(background != null and background.texture != null, "Background loaded " + node_id)
			var portraits: Array[Node] = app.page.find_children("EventPortrait_*", "TextureRect", true, false)
			var cg := app.page.get_node_or_null("CharacterEventCG") as TextureRect
			if node_id in CG_NODE_IDS:
				expect(cg != null and cg.texture != null and cg.texture.resource_path == "res://" + CG_PATH, "Approved strategy CG loaded " + node_id)
				expect(cg.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "Approved strategy CG uses cover fit " + node_id)
				expect(portraits.is_empty(), "Approved strategy CG suppresses portrait overlays " + node_id)
			elif node_id in OR_CG_NODE_IDS:
				expect(cg != null and cg.texture != null and cg.texture.resource_path == "res://" + OR_CG_PATH, "Approved awake OR CG loaded " + node_id)
				expect(cg.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "Approved awake OR CG uses cover fit " + node_id)
				expect(portraits.is_empty(), "Approved awake OR CG suppresses portrait overlays " + node_id)
			elif node_id in PELVIC_CG_NODE_IDS:
				expect(cg != null and cg.texture != null and cg.texture.resource_path == "res://" + PELVIC_CG_PATH, "Supplied pelvic-field CG loaded " + node_id)
				expect(cg != null and cg.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Supplied pelvic-field CG preserves the full frame " + node_id)
				expect(portraits.is_empty(), "Supplied pelvic-field CG suppresses portrait overlays " + node_id)
			elif node_id in PRESERVATION_CG_NODE_IDS:
				expect(cg != null and cg.texture != null and cg.texture.resource_path == "res://" + PRESERVATION_CG_PATH, "Approved ovary-preservation CG loaded " + node_id)
				expect(cg.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "Approved ovary-preservation CG uses cover fit " + node_id)
				expect(portraits.is_empty(), "Approved ovary-preservation CG suppresses portrait overlays " + node_id)
			else:
				expect(cg == null, "Authored CG does not leak before or after its window " + node_id)
			if node_id in CG_NODE_IDS or node_id in OR_CG_NODE_IDS or node_id in PELVIC_CG_NODE_IDS or node_id in PRESERVATION_CG_NODE_IDS:
				pass
			elif bool(node.hide_portrait):
				expect(portraits.is_empty(), "Narrator has no borrowed portrait " + node_id)
			else:
				var expected_portraits: Array = node.get("event_portraits", [])
				expect(portraits.size() == expected_portraits.size(), "Authored portrait count loaded " + node_id)
				for item in expected_portraits:
					var portrait: TextureRect = app.page.get_node_or_null("EventPortrait_" + str(item.id))
					expect(portrait != null and portrait.texture != null and portrait.texture.resource_path == "res://" + str(item.path), "Authored portrait loaded " + node_id + "/" + str(item.id))
					if portrait != null:
						var source_size := Vector2(float(portrait.texture.get_width()), float(portrait.texture.get_height()))
						var fit_scale := minf(portrait.size.x / source_size.x, portrait.size.y / source_size.y)
						var fitted_height := source_size.y * fit_scale
						var visible_bottom := portrait.position.y + (portrait.size.y + fitted_height) / 2.0
						expect(absf(visible_bottom - 540.0) < 0.75, "Visible portrait meets dialogue frame " + node_id)
		var choice_index := 0
		if node.choices.size() == 2:
			choice_index = (branch_mask >> branch_number) & 1
			branch_number += 1
		app.choose_character_event(str(node.choices[choice_index].id))
	expect(guard <= NODE_COUNT + 4 and event.completed, "Route terminates %s/%s" % [locale, branch_mask])
	expect(branch_number == 3, "All three authored choices reached %s/%s" % [locale, branch_mask])
	for actor_id in ACTORS:
		expect(g.relationship_level(actor_id) == 3, actor_id + " reaches Lv3 only at ending")
		expect(g.relation_for(actor_id).rank_history.count(ID) == 1, actor_id + " has one rank fact")
		expect(g.relation_for(actor_id).event_history.count(ID) == 1, actor_id + " has one event fact")
	expect(g.story_flag("narumi_ren_shared_lv3_complete") and g.story_flag("hirasaka_investigation_ended"), "Stable completion flags set")
	var settled_day: int = int(g.day_number())
	var settled_clock: int = int(g.current_absolute_clock())
	expect(settled_day == before_day + 7 and settled_clock == 1019, "Seven-day story settles once inside the persistent 16:59 work-ledger boundary (got day %s from %s, clock %s)" % [settled_day, before_day, settled_clock])
	expect(g.completed_surgeries_total == before_surgeries and g.active_staff_patient == before_patient, "No clinical runner/patient mutation")
	expect(app.screen == "day_transition", "Cross-day completion uses transition screen")
	expect(int(app.day_transition_display_schedule.get("day", -1)) == settled_day and int(app.day_transition_display_schedule.get("absolute_clock", -1)) == 1080, "Scene 15 closing transition presents authored 18:00 without persisting event inner state")
	app.continue_after_day_transition()
	expect(app.screen == "map", "Cross-day completion returns to hospital map")
	expect(g.can_save_progress(), "Saving returns only at hospital map")
	var save: Dictionary = g.snapshot()
	expect(not save.is_empty() and no_inner(save), "Boundary save contains no event inner state")
	var settled_elapsed: int = g.elapsed()
	expect(g.restore(JSON.parse_string(JSON.stringify(save))), "Boundary save reloads")
	expect(g.elapsed() == settled_elapsed and g.relationship_level("doc_aoi") == 3 and g.relationship_level("nurse_haru") == 3, "Reload preserves dual settled result")
	expect(g.start_character_event(ID) == null, "Completed shared event cannot replay")

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/narumi_ren_shared_lv3_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Content loads " + locale)
		app.configure_game_content()
		var definition: Dictionary = app.game.character_event_definitions.get(ID, {})
		expect(not definition.is_empty() and definition.nodes.size() == NODE_COUNT, "Registered 478-page event " + locale)
		expect(str(definition.get("gallery", {}).get("path", "")) == CG_PATH and bool(definition.get("gallery", {}).get("show_on_complete", false)), "Approved Lv3 strategy CG registered in gallery " + locale)
		expect(ResourceLoader.exists("res://" + CG_PATH), "Approved Lv3 strategy CG resource exists " + locale)
		expect(ResourceLoader.exists("res://" + OR_CG_PATH), "Approved Lv3 awake OR CG resource exists " + locale)
		expect(ResourceLoader.exists("res://" + PELVIC_CG_PATH), "Supplied Lv3 pelvic-field CG resource exists " + locale)
		expect(ResourceLoader.exists("res://" + PRESERVATION_CG_PATH), "Approved Lv3 ovary-preservation CG resource exists " + locale)
		if locale == "zh_CN":
			test_atomic_settlement(definition)
			test_gate(definition)
		var coverage := {}
		for branch_mask in range(8):
			test_route(locale, branch_mask, coverage, branch_mask == 0)
		expect(coverage.size() == NODE_COUNT, "All authored pages covered %s %s/%s" % [locale, coverage.size(), NODE_COUNT])
	print("NARUMI REN SHARED LV3: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
