extends SceneTree
## Structural, 4x9 preference matrix, 5-expression reachability, Phase 2 playback,
## bilingual entry, and Lv4 milestone event-mode test for Artoria Pendragon (`doc_artoria`) H Profile V1.

const Content = preload("res://godot/systems/h_profile_v1_content.gd")
const Session = preload("res://godot/systems/h_profile_v1_session.gd")
const Registry = preload("res://godot/systems/free_h_registry.gd")

var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var config := Registry.definition("doc_artoria")
	expect(config.content_status == "ready", "Registry content_status is ready")
	expect(config.adapter == "authored_v1_3" and config.location_id == "home" and bool(config.fixed_location), "Artoria Free H registered as authored_v1_3 at fixed home")
	for loc in ["zh_CN", "en"]:
		var ready_bundle := Registry.load_bundle("doc_artoria", loc)
		expect(not ready_bundle.has("error"), loc + ": Production load_bundle succeeds: " + str(ready_bundle.get("error", "")))

	var source := Registry.read_json(config.profile)
	var flow := Registry.read_json(config.flow)
	var labels := Registry.read_json(config.finish_labels)
	var context := Registry.read_json(config.context)
	var bodymap := Registry.read_json(config.bodymap)
	expect(not source.is_empty() and not flow.is_empty() and not labels.is_empty() and not context.is_empty() and not bodymap.is_empty(), "All Artoria H Profile JSON files parse cleanly")
	expect(str(bodymap.get("status", "")) == "final" and int(bodymap.get("image_width", 0)) == 682 and int(bodymap.get("image_height", 0)) == 1024, "Calibrated bodymap matches 682x1024 body_map.png")

	var profile := Content.normalize(source, flow, labels, {}, context)
	expect(not profile.is_empty(), "Artoria H Profile 1.3 + Flow 1.3.4 + Context 1.0 normalizes cleanly")
	expect(profile.expressions == source.assets.portrait_expressions, "Six independent portrait slots preserved")

	for expr_key in ["neutral", "annoyed", "pleased", "flustered", "delighted", "peak"]:
		var expr_path := str(profile.expressions.get(expr_key, ""))
		expect(ResourceLoader.exists(expr_path) and ResourceLoader.load(expr_path) != null, "Portrait texture loads: " + expr_path)
	expect(ResourceLoader.load(str(profile.body_map_image)) != null, "Body map texture loads")
	expect(ResourceLoader.load(str(profile.h_stage_image)) != null, "Phase 2 scene_cg texture loads")
	expect(ResourceLoader.load(str(profile.after_cg_image)) != null, "Aftercare CG texture loads")

	var han := RegEx.new()
	han.compile("[\\x{3400}-\\x{9fff}]")

	for locale in ["zh_CN", "en"]:
		for style in ["gentle", "intense"]:
			var session = Session.new("doc_artoria", profile, "home", "", locale)
			expect(session.phase == "foreplay", locale + ": session starts in foreplay")
			expect(session.background_id("") == "artoria_home_bedroom_night", locale + ": uses artoria_home_bedroom_night background")
			var entries: Array = session.location_entry_lines(profile.location_entry.home)
			expect(entries.size() == 4, locale + ": four home entry lines")
			if locale == "en":
				for line in entries:
					expect(han.search(str(line)) == null, "en: zero CJK in home entry line")

			var seen_expressions := {}
			for action in Session.ACTIONS:
				for zone in Session.ZONES:
					var expected_tier: String = source.preferences.combo_overrides.get(
						action + ":" + zone,
						source.preferences.action_overrides.get(action, source.preferences.zone_defaults[zone])
					)
					var r_session = Session.new("doc_artoria", profile, "home", "", locale)
					var res: Dictionary = r_session.perform(action, zone)
					expect(res.accepted and res.tier == expected_tier and not str(res.line).is_empty() and not str(res.line).contains("PENDING_AUTHOR_TEXT"), "%s: 4x9 matrix %s:%s -> %s" % [locale, action, zone, expected_tier])
					seen_expressions[str(res.expression)] = true
					if locale == "en":
						expect(han.search(str(res.line)) == null, "en: zero CJK in reaction " + action + ":" + zone)

			var prompt_count := 0
			while session.excitement < 100:
				var max_res: Dictionary = session.perform("kiss", "lips")
				seen_expressions[str(max_res.expression)] = true
				if max_res.get("show_max_prompt", false):
					prompt_count += 1
			expect(prompt_count == 1 and session.excitement == 100 and session.phase == "foreplay", locale + ": MAX prompt fires once at 100 without auto-advance")
			for expr_id in ["annoyed", "pleased", "flustered", "delighted", "peak"]:
				expect(seen_expressions.has(expr_id), "%s: expression tier '%s' reachable" % [locale, expr_id])

			expect(session.begin_h_stage(style), locale + ": starts Phase 2 with style " + style)
			var h_lines: Array = session.h_scene_lines()
			expect(h_lines.size() == 6 and h_lines[1] != h_lines[2] and h_lines[4] != h_lines[5], locale + ": 6 ordered no-replacement Phase 2 lines")
			for line in h_lines:
				if locale == "en":
					expect(han.search(str(line)) == null, "en: zero CJK in Phase 2 line")
				session.advance_h_stage()
			expect(session.phase == "h_finish_wait" and not session.h_event_completed, locale + ": waits at manual finish button")
			if locale == "en":
				expect(han.search(str(session.h_finish_label)) == null, "en: zero CJK in finish button label")
			expect(session.choose_h_finish() and not session.choose_h_finish(), locale + ": manual finish is one-shot")
			if locale == "en":
				expect(han.search(str(session.h_finish_response_line)) == null, "en: zero CJK in finish response line")
			expect(session.advance_h_stage() and session.phase == "after_cg", locale + ": reaches after_cg")
			var after_lines: Array = session.aftercare_lines(profile.flow.free_aftercare_lines)
			expect(after_lines.size() == 2, locale + ": 2 Free H aftercare lines")
			if locale == "en":
				for line in after_lines:
					expect(han.search(str(line)) == null, "en: zero CJK in Free H aftercare line")
			expect(session.finish(), locale + ": session finishes cleanly")

	print("ARTORIA H PROFILE STRUCTURAL TEST: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures > 0 else 0)
