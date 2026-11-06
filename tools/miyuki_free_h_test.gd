extends SceneTree
## Authored content, bilingual pool, expression, phase-two, and unlock regression.
const Content = preload("res://godot/systems/h_profile_v1_content.gd")
const Session = preload("res://godot/systems/h_profile_v1_session.gd")
const Registry = preload("res://godot/systems/free_h_registry.gd")
const CharacterEvent = preload("res://godot/systems/character_event_session.gd")

var checks := 0
var failures := 0
var app

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var config := Registry.definition("nurse_yui")
	var source := Registry.read_json(config.profile)
	var flow := Registry.read_json(config.flow)
	var labels := Registry.read_json(config.finish_labels)
	var context := Registry.read_json(config.context)
	var profile := Content.normalize(source, flow, labels, {}, context)
	expect(not profile.is_empty(), "Miyuki profile normalizes")
	expect(config.content_status == "ready" and context.content_status == "ready", "Registry and context are ready")
	expect(context.layout_status == "final_hotspots_calibrated", "Layout status is calibrated")
	expect(profile.expressions == source.assets.portrait_expressions, "Six own portrait paths preserved")
	for expression in Session.EXPRESSION_IDS:
		expect(ResourceLoader.exists(str(profile.expressions.get(expression, ""))), "Portrait exists: " + expression)
	var bundle := Registry.load_bundle("nurse_yui")
	expect(not bundle.has("error"), "Production bundle validates: " + str(bundle.get("error", "")))
	if bundle.has("error"):
		quit(1)
		return

	app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var han := RegEx.new()
	han.compile("[\\x{3400}-\\x{9fff}]")
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		for style in ["gentle", "intense"]:
			var session = Session.new("nurse_yui", profile, "clinic", "", locale)
			expect(session.phase == "foreplay" and session.event_id.is_empty(), "Repeatable clinic session")
			expect(session.background_id("") == "miyuki_hospital_clinic_night", "Hoshimi Hospital night consultation-room background")
			var entries: Array = session.location_entry_lines(profile.location_entry.clinic)
			expect(entries.size() == 4, "Four clinic entry candidates")
			if locale == "en":
				for line in entries:
					expect(han.search(str(line)) == null, "English entry has no Han text")
			var seen_expressions := {}
			for action in Session.ACTIONS:
				for zone in Session.ZONES:
					var tier: String = source.preferences.combo_overrides.get(action + ":" + zone, source.preferences.action_overrides.get(action, source.preferences.zone_defaults[zone]))
					var reaction_session = Session.new("nurse_yui", profile, "clinic", "", locale)
					var result: Dictionary = reaction_session.perform(action, zone)
					expect(result.accepted and result.tier == tier and not str(result.line).is_empty(), "Reaction " + action + ":" + zone)
					seen_expressions[str(result.expression)] = true
					if locale == "en":
						expect(han.search(str(result.line)) == null, "English reaction has no Han text")
			var prompt_count := 0
			while session.excitement < 100:
				var max_result: Dictionary = session.perform("caress", "cheeks")
				seen_expressions[str(max_result.expression)] = true
				if max_result.get("show_max_prompt", false):
					prompt_count += 1
			expect(prompt_count == 1 and session.excitement == 100 and session.phase == "foreplay", "MAX prompt once without auto-advance")
			expect(seen_expressions.has("annoyed") and seen_expressions.has("pleased") and seen_expressions.has("flustered") and seen_expressions.has("delighted") and seen_expressions.has("peak"), "All reactive expressions reachable")
			if locale == "en":
				expect(han.search(session.max_prompt(profile.flow.max_prompt)) == null, "English MAX prompt")
			expect(session.begin_h_stage(style), "Explicit style starts phase two")
			var lines: Array = session.h_scene_lines()
			expect(lines.size() == 6 and lines[1] != lines[2] and lines[4] != lines[5], "Six ordered no-replacement phase-two lines")
			for line in lines:
				if locale == "en":
					expect(han.search(str(line)) == null, "English phase-two line")
				session.advance_h_stage()
			expect(session.phase == "h_finish_wait" and not session.h_event_completed, "Manual finish boundary")
			expect(session.choose_h_finish() and not session.choose_h_finish(), "Finish response is one-shot")
			expect(session.advance_h_stage() and session.phase == "after_cg", "Acknowledged response reaches aftercare")
			var aftercare: Array = session.aftercare_lines(profile.flow.free_aftercare_lines)
			expect(aftercare.size() == 2, "Exactly two aftercare lines")
			for line in aftercare:
				if locale == "en":
					expect(han.search(str(line)) == null, "English aftercare line")
			expect(session.finish(), "Session finishes")

	app.game.reset()
	app.game.meet_staff("nurse_yui")
	var relation: Dictionary = app.game.relation_for("nurse_yui")
	relation.level = 4
	relation.route = "romance"
	relation.unlocked_benefits = ["unlock_intimacy_events"]
	expect(not app.game.free_h_unlocked("nurse_yui"), "Level and benefit alone do not bypass completed event")
	var definition: Dictionary = app.game.character_event_definitions["miyuki_lv4_inspection"]
	var completed_event = CharacterEvent.new(definition)
	completed_event.node_id = str(definition.nodes[-1].id)
	completed_event.completed = true
	completed_event.completed_day = 8
	app.game.character_events["miyuki_lv4_inspection"] = completed_event
	app.game.character_event_order.append("miyuki_lv4_inspection")
	expect(app.game.free_h_unlocked("nurse_yui"), "Completed Miyuki Lv4 unlocks ready Free H")
	print("MIYUKI FREE H: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)
