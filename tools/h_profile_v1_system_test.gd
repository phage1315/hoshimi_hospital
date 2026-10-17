extends SceneTree

const HProfileSession = preload("res://godot/systems/h_profile_v1_session.gd")
const HProfileContent = preload("res://godot/systems/h_profile_v1_content.gd")

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func profile_fixture() -> Dictionary:
	return {
		"schema_version": 1,
		"enabled": true,
		"default_preference": "mild",
		"zone_defaults": {"lips": "mild", "cheeks": "mild", "neck": "mild", "breasts": "mild", "nipples": "mild", "navel": "mild", "torso_other": "mild", "genitals": "mild", "thighs": "favorite"},
		"action_defaults": {"light_bite": "mild"},
		"action_zone_overrides": {
			"caress": {"neck": "favorite"},
			"kiss": {},
			"lick": {},
			"light_bite": {"neck": "strong", "lips": "low"},
		},
		"reactions": {
			"combo": {"caress|neck": [{"line": "", "expression": "pleased"}]},
			"zone_tier": {"lips|mild": [{"line": "", "expression": "flustered"}]},
			"action_tier": {"light_bite|low": [{"line": "", "expression": "annoyed"}]},
		"tier_fallback": {"low": [], "mild": [{"line": "", "expression": "neutral"}], "strong": [], "favorite": [{"line": "", "expression": "delighted"}]},
		},
		"expressions": {"neutral": "assets/test/neutral.png", "annoyed": "assets/test/annoyed.png", "pleased": "assets/test/pleased.png", "flustered": "assets/test/flustered.png", "delighted": "assets/test/delighted.png", "peak": "assets/test/peak.png"},
		"location_entry": {"hotel": [""], "home": [""], "ward": [""], "gyne_exam": [""], "operating_room": ["", "", ""]},
		"scene": {"start": ["s1", "s2", "s3"], "middle": ["m1", "m2", "m3"], "finish": ["f1", "f2", "f3"]},
		"h_stage_image": "assets/test/h_stage.png",
		"after_cg_image": "assets/test/after.png",
	}

func bodymap_fixture() -> Dictionary:
	return {"hotspots": {
		"neck": [[[0.25, 0.1], [0.75, 0.1], [0.75, 0.5], [0.25, 0.5]]],
			"lips": [[[0.4, 0.55], [0.6, 0.55], [0.6, 0.75], [0.4, 0.75]]],
			"buttocks": [[[0.2, 0.8], [0.8, 0.8], [0.8, 1.0], [0.2, 1.0]]],
		}}

func _initialize() -> void:
	var authored_file := FileAccess.open("res://data/staff/doc_sayaka/h_profile_v1_3_2.json", FileAccess.READ)
	var flow_file := FileAccess.open("res://data/staff/doc_sayaka/h_flow_v1_3_2.json", FileAccess.READ)
	var authored_source: Dictionary = JSON.parse_string(authored_file.get_as_text()) if authored_file != null else {}
	var authored_flow: Dictionary = JSON.parse_string(flow_file.get_as_text()) if flow_file != null else {}
	var labels_file := FileAccess.open("res://data/h_finish_button_labels_v1_3_4.json", FileAccess.READ)
	var actor_finish_file := FileAccess.open("res://data/staff/doc_sayaka/h_phase2_finish_v1_3_4.json", FileAccess.READ)
	var finish_labels: Dictionary = JSON.parse_string(labels_file.get_as_text()) if labels_file != null else {}
	var actor_finish: Dictionary = JSON.parse_string(actor_finish_file.get_as_text()) if actor_finish_file != null else {}
	var authored_profile := HProfileContent.normalize(authored_source, authored_flow, finish_labels, actor_finish)
	var authored_session = HProfileSession.new("doc_sayaka", authored_profile)
	expect(not authored_profile.is_empty() and authored_session.phase == "foreplay", "Authored V1.3.2 profile and flow did not adapt to the shared session")
	expect(authored_profile.expression_atlas.ends_with("expression_sheet_v2.png"), "Runtime did not select the approved transparent expression atlas")
	for image_path in [authored_profile.expression_atlas, authored_profile.body_map_image, authored_profile.h_stage_image, authored_profile.after_cg_image]:
		expect(FileAccess.file_exists(image_path), "Imported H profile image is missing: %s" % image_path)
	var atlas_rects: Array[Rect2i] = []
	for expression_id in HProfileSession.EXPRESSION_IDS:
		var region: Rect2i = authored_session.expression_atlas_region(expression_id)
		expect(region.position.x >= 0 and region.position.y >= 0 and region.end.x <= 1529 and region.end.y <= 1029, "Expression crop lies outside approved atlas: %s" % expression_id)
		atlas_rects.append(region)
	expect(atlas_rects.size() == 6, "Expected all six expression cells to be mapped")
	var authored_touch: Dictionary = authored_session.perform("caress", "cheeks")
	expect(authored_touch.line == "嗯……你、你这样看我……反而、反而让我害羞啦。" and authored_touch.expression == "delighted", "Authored combo line or preference was not preserved")
	var caress_lips: Dictionary = authored_session.perform("caress", "lips")
	var lick_lips: Dictionary = authored_session.perform("lick", "lips")
	var aligned_lips_lines := ["唔……嗯……嘴、嘴唇……再、再来一下嘛……", "唔……你、你就这么喜欢逗我的嘴唇呀……"]
	expect(caress_lips.tier == "favorite" and caress_lips.line in aligned_lips_lines and lick_lips.tier == "favorite" and lick_lips.line in aligned_lips_lines, "Lip caress/lick did not resolve to the aligned favorite dialogue pool")
	expect(authored_profile.scene.start.size() == 3 and not authored_profile.has("free_aftercare"), "Authored scene or event-layer aftercare boundary was not preserved")
	var authored_dialogue: Dictionary = authored_source.get("dialogue", {})
	var dialogue_line_count := 0
	for section in ["tier_fallback", "zone_tier", "action_tier", "combo"]:
		var pools: Dictionary = authored_dialogue.get(section, {})
		for pool in pools.values():
			dialogue_line_count += pool.size()
	for pool in authored_dialogue.get("location_entry", {}).values():
		dialogue_line_count += pool.size()
	for pool in authored_dialogue.get("scene", {}).values():
		dialogue_line_count += pool.size()
	expect(dialogue_line_count == 74, "The imported authored Sayaka profile should contain all 74 supplied H-profile lines")

	var profile := profile_fixture()
	profile["flow"] = authored_profile.flow
	var session = HProfileSession.new("doc_sayaka", profile)
	var bodymap := bodymap_fixture()
	expect(session.phase == "foreplay" and session.excitement == 0, "New V1 session did not start at foreplay")
	expect(session.idle_expression() == "neutral", "Idle expression should use the selected top-right portrait")
	expect(session.expression_atlas_region("neutral") == Rect2i(1019, 0, 510, 500), "Idle expression should resolve to the top-right transparent portrait")
	expect(session.expression_atlas_region("annoyed") == Rect2i(510, 0, 509, 500), "Disliked-touch expression should resolve to the top-middle transparent portrait")
	expect(session.expression_atlas_region("peak") == Rect2i(1019, 500, 510, 500), "Peak expression should resolve to the bottom-right transparent portrait")
	expect(session.gain_for("caress", "neck") == 18, "Favorite override gain should be 18")
	expect(session.gain_for("kiss", "neck") == 6, "Unspecified combinations should default to mild gain 6")
	expect(session.gain_for("kiss", "thighs") == 18, "Zone default should apply when the action has no action-wide default")
	expect(session.gain_for("light_bite", "thighs") == 6, "Action-wide default should take precedence over the zone default")
	expect(session.gain_for("light_bite", "lips") == 2, "Low override gain should be 2")
	expect(session.gain_for("bad_action", "neck") == 0, "Invalid action should have no gain")
	expect(session.hit_test(Vector2(0.5, 0.3), bodymap) == "neck", "Normalized polygon hotspot did not resolve")
	expect(session.hit_test(Vector2(0.5, 0.9), bodymap).is_empty(), "Excluded buttocks hotspot incorrectly resolved")
	expect(session.gain_for("caress", "buttocks") == 0, "Buttocks must not be an interactive zone")
	var first: Dictionary = session.perform("caress", "neck")
	expect(first.accepted and first.gain == 18 and first.expression == "pleased", "Combo reaction or preference did not resolve")
	var second: Dictionary = session.perform("kiss", "lips")
	expect(second.accepted and second.gain == 6 and second.expression == "flustered", "Zone-tier reaction did not resolve")
	var third: Dictionary = session.perform("light_bite", "lips")
	expect(third.accepted and third.gain == 2 and third.expression == "annoyed", "Action-tier reaction did not resolve")
	var fallback: Dictionary = session.perform("kiss", "cheeks")
	expect(fallback.accepted and fallback.expression == "neutral", "Tier fallback reaction did not resolve")
	var no_reaction_profile := profile.duplicate(true)
	no_reaction_profile["reactions"] = {}
	var tier_expression_session = HProfileSession.new("doc_sayaka", no_reaction_profile)
	expect(tier_expression_session.perform("light_bite", "lips").expression == "annoyed", "Low-tier touch should fall back to annoyed")
	expect(tier_expression_session.perform("kiss", "lips").expression == "pleased", "Mild-tier touch should fall back to pleased")
	expect(tier_expression_session.perform("light_bite", "neck").expression == "flustered", "Strong-tier touch should fall back to flustered")
	expect(tier_expression_session.perform("caress", "neck").expression == "delighted", "Favorite-tier touch should fall back to delighted")
	var max_prompt_count := 0
	while session.excitement < 100:
		var final_touch: Dictionary = session.perform("caress", "neck")
		if final_touch.get("show_max_prompt", false):
			max_prompt_count += 1
			expect(final_touch.expression == "peak", "Threshold touch should use the peak expression")
	expect(session.excitement == 100 and session.phase == "foreplay" and max_prompt_count == 1, "MAX should show once without advancing out of foreplay")
	var continued_touch: Dictionary = session.perform("kiss", "lips")
	expect(continued_touch.accepted and not continued_touch.get("show_max_prompt", false) and session.phase == "foreplay", "Phase-one interaction did not remain available after MAX")
	expect(not session.begin_h_stage("unknown") and session.phase == "foreplay", "An invalid entry style unexpectedly started phase two")
	expect(session.begin_h_stage("gentle") and session.phase == "h_stage", "Selecting an entry style did not start phase two")
	expect(session.h_stage_image() == "assets/test/h_stage.png", "H-stage image reference missing")
	expect(session.current_h_scene_line() == authored_profile.flow.openings.gentle, "Gentle style opening line was not routed")
	var ordered_lines: Array[String] = []
	while session.phase == "h_stage":
		ordered_lines.append(session.current_h_scene_line())
		session.advance_h_stage()
	expect(ordered_lines.size() == 6 and ordered_lines[0] == authored_profile.flow.openings.gentle and ordered_lines[3] == authored_profile.flow.midpoints.gentle, "H scene did not route style lines at opening and midpoint")
	expect(ordered_lines[1] != ordered_lines[2] and ordered_lines[4] != ordered_lines[5], "Phase-two pool draws repeated a line within a section")
	expect(ordered_lines[1] in ["s1", "s2", "s3"] and ordered_lines[2] in ["s1", "s2", "s3"] and ordered_lines[4] in ["m1", "m2", "m3"] and ordered_lines[5] in ["m1", "m2", "m3"], "Scene pools were not sampled in start/middle order")
	expect(session.phase == "h_finish_wait" and session.after_cg_image() == "assets/test/after.png", "H stage did not wait for manual finish")
	var intense_session = HProfileSession.new("doc_sayaka", authored_profile)
	while intense_session.excitement < 100:
		intense_session.perform("caress", "neck")
	expect(intense_session.begin_h_stage("intense"), "Intense entry selection did not begin H stage")
	var intense_lines: Array[String] = intense_session.h_scene_lines()
	expect(intense_lines.size() == 6 and intense_lines[0] == authored_profile.flow.openings.intense and intense_lines[3] == authored_profile.flow.midpoints.intense, "Intense style did not affect exactly its two authored scene lines")
	expect(intense_lines[0] != ordered_lines[0] and intense_lines[3] != ordered_lines[3] and intense_lines[1] in authored_profile.scene.start and intense_lines[2] in authored_profile.scene.start and intense_lines[4] in authored_profile.scene.middle and intense_lines[5] in authored_profile.scene.middle, "Entry style changed more than the two style-specific lines or played legacy finish lines")
	expect(session.h_finish_label in authored_profile.flow.finish_button_labels, "Phase-two finish label was not drawn from the global label pool")
	expect(session.phase == "h_finish_wait" and not session.h_event_completed, "Phase two did not wait for explicit player finish after authored lines")
	expect(not session.advance_h_stage(), "Phase two advanced without the explicit h_finish action")
	expect(session.choose_h_finish() and session.phase == "h_finish_response" and session.h_finish_response_line in authored_profile.flow.finish_response_pool, "h_finish did not choose exactly one authored response")
	var selected_response: String = session.h_finish_response_line
	expect(not session.choose_h_finish() and session.h_finish_response_line == selected_response, "Repeated h_finish input changed or duplicated the response")
	expect(not session.h_event_completed and session.advance_h_stage() and session.phase == "after_cg" and session.h_event_completed, "Completion did not wait for the final response to be advanced")
	var saved := session.snapshot()
	var restored = HProfileSession.new("doc_sayaka", profile)
	expect(restored.restore(saved) and restored.phase == "after_cg", "Session snapshot did not restore")
	expect(session.finish() and session.phase == "completed" and session.h_event_completed, "Session did not complete and set the H event completion result after after-CG")

	print("H PROFILE V1 SYSTEM: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
