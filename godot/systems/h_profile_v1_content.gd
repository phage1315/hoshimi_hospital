extends RefCounted
## Adapts authored schema 1.3 profiles and 1.3.2/1.3.4 flow sidecars to the shared
## V1 interaction session. This is a data adapter, not a second system.

const EXPRESSION_IDS := ["neutral", "annoyed", "pleased", "flustered", "delighted", "peak"]
const EXPRESSION_ATLAS := "res://assets/characters/h_profile_v1/doc_sayaka/expressions_v1/expression_sheet_v2.png"
const H_STAGE_IMAGE := "res://assets/characters/h_profile_v1/doc_sayaka/h_stage_v1.png"
const AFTERCARE_IMAGE := "res://assets/characters/h_profile_v1/doc_sayaka/after_cg_v1.png"

static func normalize(raw: Dictionary, flow_raw: Dictionary = {}, finish_labels_raw: Dictionary = {}, finish_actor_raw: Dictionary = {}, context_raw: Dictionary = {}) -> Dictionary:
	if str(raw.get("schema_version", "")) != "1.3" or str(raw.get("actor_id", "")).is_empty() or not bool(raw.get("adult_confirmed", false)):
		return {}
	var normalized_flow := normalize_flow(flow_raw, raw, finish_labels_raw, finish_actor_raw)
	if normalized_flow.is_empty():
		return {}
	var locations: Variant = context_raw.get("locations", {})
	var events: Variant = context_raw.get("events", {})
	var base_context: Variant = context_raw.get("base", {})
	if (not context_raw.is_empty() and (str(context_raw.get("schema_version", "")) != "1.0" or str(context_raw.get("actor_id", "")) != str(raw.get("actor_id", "")))) or not locations is Dictionary or not events is Dictionary or not base_context is Dictionary:
		return {}
	var base_assets: Variant = base_context.get("assets", {})
	var base_dialogue: Variant = base_context.get("dialogue", {})
	if not base_assets is Dictionary or not base_dialogue is Dictionary:
		return {}
	var preferences_value: Variant = raw.get("preferences", null)
	var dialogue_value: Variant = raw.get("dialogue", null)
	var assets_value: Variant = raw.get("assets", null)
	if not preferences_value is Dictionary or not dialogue_value is Dictionary or not assets_value is Dictionary:
		return {}
	var preferences: Dictionary = preferences_value
	var dialogue: Dictionary = dialogue_value
	var assets: Dictionary = assets_value
	var source_combos: Variant = preferences.get("combo_overrides", null)
	if not source_combos is Dictionary:
		return {}
	var combos := {"caress": {}, "kiss": {}, "lick": {}, "light_bite": {}}
	for raw_key in source_combos:
		var parts := str(raw_key).split(":", false, 1)
		if parts.size() != 2 or not combos.has(parts[0]):
			return {}
		var action_combos: Dictionary = combos[parts[0]]
		action_combos[parts[1]] = source_combos[raw_key]
		combos[parts[0]] = action_combos

	var source_dialogue: Dictionary = dialogue
	var reactions := {
		"tier_fallback": source_dialogue.get("tier_fallback", {}),
		"zone_tier": _normalize_keyed_pools(source_dialogue.get("zone_tier", {})),
		"action_tier": _normalize_keyed_pools(source_dialogue.get("action_tier", {})),
		"combo": _normalize_keyed_pools(source_dialogue.get("combo", {})),
	}
	if not reactions.get("tier_fallback") is Dictionary or not reactions.get("zone_tier") is Dictionary or not reactions.get("action_tier") is Dictionary or not reactions.get("combo") is Dictionary:
		return {}
	var expressions := {}
	var atlas_path := ""
	var normalized_base: Dictionary = base_context.duplicate(true)
	var normalized_base_assets: Dictionary = base_assets.duplicate(true)
	if str(raw.actor_id) == "doc_sayaka":
		atlas_path = EXPRESSION_ATLAS
		for expression_id in EXPRESSION_IDS:
			expressions[expression_id] = atlas_path
		normalized_base_assets.merge({
			"body_map": {"path": "res://assets/characters/h_profile_v1/doc_sayaka/bodymap_base_v1.png", "layout_id": "doc_sayaka_front_bodymap_v1", "width": 1024, "height": 1536},
			"h_stage": {"path": H_STAGE_IMAGE},
			"after_cg": {"path": AFTERCARE_IMAGE},
			"background": {"id": "date_hotel"},
		}, false)
	else:
		# New actors supply their own images and layout metadata; never borrow Sayaka.
		var supplied_expressions: Variant = assets.get("portrait_expressions", {})
		if not supplied_expressions is Dictionary:
			return {}
		for expression_id in EXPRESSION_IDS:
			var path := str(supplied_expressions.get(expression_id, ""))
			if path.is_empty(): return {}
			expressions[expression_id] = path
		for slot in ["body_map", "background"]:
			if not normalized_base_assets.get(slot) is Dictionary: return {}
		normalized_base_assets.merge({
			"h_stage": {"path": str(assets.get("scene_cg", ""))},
			"after_cg": {"path": str(assets.get("aftercare_cg", ""))},
		}, false)
	var body: Dictionary = normalized_base_assets.body_map
	if str(body.get("path", "")).is_empty() or str(body.get("layout_id", "")).is_empty() or int(body.get("width", 0)) <= 0 or int(body.get("height", 0)) <= 0:
		return {}
	normalized_base["assets"] = normalized_base_assets
	return {
		"schema_version": 1,
		"enabled": true,
		"default_preference": "mild",
		"zone_defaults": preferences.get("zone_defaults", {}),
		"action_defaults": preferences.get("action_overrides", {}),
		"action_zone_overrides": combos,
		"reactions": reactions,
		"expressions": expressions,
		"expression_atlas": atlas_path,
		"location_entry": source_dialogue.get("location_entry", {}),
		"scene": source_dialogue.get("scene", {}),
		"flow": normalized_flow,
		"h_stage_image": str(normalized_base_assets.h_stage.path),
		"after_cg_image": str(normalized_base_assets.after_cg.path),
		"body_map_image": str(body.path),
		"body_map_layout": {"layout_id": str(body.layout_id), "width": int(body.width), "height": int(body.height)},
		"entry_random_one": bool(context_raw.get("entry_random_one", false)),
		"context_overrides": {
			"base": normalized_base,
			"locations": locations.duplicate(true),
			"events": events.duplicate(true),
		},
		"source_asset_paths": assets,
	}

static func normalize_flow(raw: Dictionary, profile: Dictionary, finish_labels_raw: Dictionary = {}, finish_actor_raw: Dictionary = {}) -> Dictionary:
	var manual_flow := str(raw.get("patch_version", "")) == "1.3.4"
	if str(raw.get("patch_version", "")) not in ["1.3.2", "1.3.4"] or str(raw.get("actor_id", "")) != str(profile.get("actor_id", "")):
		return {}
	var max_config: Variant = raw.get("excitement_max", null)
	var style_config: Variant = raw.get("entry_style", null)
	var phase_config: Variant = raw.get("phase2", null)
	var aftercare_config: Variant = raw.get("external_vn_aftercare", null)
	if not max_config is Dictionary or not style_config is Dictionary or not phase_config is Dictionary or not aftercare_config is Dictionary:
		return {}
	var trigger: Dictionary = max_config.get("trigger", {})
	var choices_value: Variant = max_config.get("choices", null)
	var openings_value: Variant = style_config.get("openings", null)
	var midpoints_value: Variant = style_config.get("midpoints", null)
	var playback_value: Variant = phase_config.get("playback", null)
	var free_h: Variant = aftercare_config.get("free_h", null)
	if int(trigger.get("excitement_gte", -1)) != 100 or not choices_value is Array or not openings_value is Dictionary or not midpoints_value is Dictionary or not playback_value is Array or not free_h is Dictionary:
		return {}
	var choice_map := {}
	for choice_value in choices_value:
		if not choice_value is Dictionary:
			return {}
		var choice: Dictionary = choice_value
		var choice_id := str(choice.get("id", ""))
		if choice_id not in ["gentle", "intense"] or str(choice.get("label", "")).is_empty():
			return {}
		choice_map[choice_id] = str(choice.get("label", ""))
	if choice_map.size() != 2:
		return {}
	var scene: Dictionary = profile.get("dialogue", {}).get("scene", {})
	var expected_sections := ["start", "middle", "finish"]
	if playback_value.size() != 5:
		return {}
	var expected_kinds := ["style_line", "profile_scene_pool", "style_line", "profile_scene_pool", "profile_scene_pool"]
	var expected_refs := ["entry_style.openings", "dialogue.scene.start", "entry_style.midpoints", "dialogue.scene.middle", "dialogue.scene.finish"]
	if manual_flow:
		expected_kinds[4] = "wait_for_player_finish"
		expected_refs[4] = ""
	var draw_plan: Array[Dictionary] = []
	for index in range(playback_value.size()):
		var item_value: Variant = playback_value[index]
		if not item_value is Dictionary:
			return {}
		var item: Dictionary = item_value
		if str(item.get("kind", "")) != expected_kinds[index] or str(item.get("ref", "")) != expected_refs[index]:
			return {}
		if manual_flow and index == 4:
			if str(item.get("action_id", "")) != "h_finish" or not bool(item.get("do_not_auto_complete", false)): return {}
			continue
		if expected_kinds[index] == "style_line":
			var style_field := "openings" if index == 0 else "midpoints"
			for style_id in ["gentle", "intense"]:
				if str(style_config.get(style_field, {}).get(style_id, "")).is_empty():
					return {}
			draw_plan.append({"kind": "style_line", "field": style_field})
		else:
			var section := str(item.get("ref", "")).trim_prefix("dialogue.scene.")
			var scene_pool: Variant = scene.get(section, null)
			if section not in expected_sections or int(item.get("draw", -1)) != 2 or not bool(item.get("without_replacement", false)) or not scene_pool is Array or scene_pool.size() != 3:
				return {}
			# Keep legacy scene.finish authored data intact, but replace its
			# automatic playback with the explicit V1.3.4 finish action.
			if section != "finish":
				draw_plan.append({"kind": "scene_pool", "section": section, "draw": 2})
	if manual_flow:
		var manual: Dictionary = phase_config.get("manual_finish", {})
		var on_click: Dictionary = manual.get("on_click", {})
		var completion: Dictionary = phase_config.get("completion", {})
		if str(manual.get("button_action_id", "")) != "h_finish" or str(manual.get("button_label_selection", "")) != "uniform_random_1_of_5_at_phase2_enter" or not bool(manual.get("button_label_stable_for_session", false)) or not bool(manual.get("button_shown_only_after_initial_playback", false)) or not bool(manual.get("button_shown_until_clicked", false)):
			return {}
		for flag in ["one_shot", "disable_button_immediately", "prevent_other_phase2_lines_after_click", "choose_one_response_uniformly", "selection_independent_of_button_label", "play_selected_response_once", "wait_until_response_advanced"]:
			if not bool(on_click.get(flag, false)): return {}
		if str(on_click.get("then", "")) != "phase2.completion" or str(completion.get("trigger", "")) != "after_h_finish_reaction_acknowledged" or str(completion.get("set_result", "")) != "h_event_completed" or not bool(completion.get("value", false)) or not bool(completion.get("one_shot", false)) or not bool(completion.get("no_other_exit_from_normal_phase2_playback", false)):
			return {}
		finish_actor_raw = {
			"spec_version": "1.3.4", "actor_id": str(profile.actor_id), "action_id": "h_finish",
			"response_pool": on_click.get("response_pool", []),
			"selection": {"method": "uniform_random", "draw_count": 1, "independent_of_button_label": true, "play_once": true, "wait_until_response_advanced": true},
		}
	var label_variants: Variant = finish_labels_raw.get("label_variants", null)
	var label_selection: Dictionary = finish_labels_raw.get("selection", {})
	var response_pool: Variant = finish_actor_raw.get("response_pool", null)
	var response_selection: Dictionary = finish_actor_raw.get("selection", {})
	if str(finish_labels_raw.get("spec_version", "")) != "1.3.4" or str(finish_labels_raw.get("action_id", "")) != "h_finish" or not label_variants is Array or label_variants.size() != 5 or str(label_selection.get("method", "")) != "uniform_random" or str(label_selection.get("draw_once", "")) != "on_phase2_enter" or not bool(label_selection.get("persist_label_until_h_finish_click", false)) or not bool(label_selection.get("independent_of_actor_reaction", false)) or str(finish_actor_raw.get("spec_version", "")) != "1.3.4" or str(finish_actor_raw.get("actor_id", "")) != str(profile.get("actor_id", "")) or str(finish_actor_raw.get("action_id", "")) != "h_finish" or not response_pool is Array or response_pool.size() != 4 or str(response_selection.get("method", "")) != "uniform_random" or int(response_selection.get("draw_count", 0)) != 1 or not bool(response_selection.get("independent_of_button_label", false)) or not bool(response_selection.get("play_once", false)) or not bool(response_selection.get("wait_until_response_advanced", false)):
		return {}
	for label in label_variants:
		if str(label).is_empty():
			return {}
	for line in response_pool:
		if str(line).is_empty():
			return {}
	var free_lines: Variant = free_h.get("on_entry_line_sequence", null)
	var milestone: Dictionary = aftercare_config.get("relationship_milestone", {})
	if not free_lines is Array or free_lines.size() != 2:
		return {}
	for line in free_lines:
		if str(line).is_empty():
			return {}
	if str(max_config.get("line", "")).is_empty() or not bool(style_config.get("both_choices_require_mutual_consent", false)) or not bool(max_config.get("show_only_once_per_h_session", false)) or not bool(max_config.get("can_continue_phase1_interactions", false)) or not bool(max_config.get("no_auto_advance", false)) or bool(phase_config.get("no_dialogue_choices_inside_phase2", false)) != true or bool(phase_config.get("no_position_selector", false)) != true or bool(phase_config.get("no_new_meter", false)) != true or bool(phase_config.get("no_failure_or_rating", false)) != true or str(phase_config.get("fixed_cg_asset_ref", "")) != "assets.scene_cg" or str(phase_config.get("completion", {}).get("handoff", "")) != "external_vn_aftercare" or str(aftercare_config.get("owner", "")) != "normal_vn_event_flow" or bool(milestone.get("no_auto_injection_of_generic_free_h_lines", false)) != true or bool(milestone.get("do_not_modify_lv4_event_script", false)) != true:
		return {}
	return {
		"max_prompt": str(max_config.get("line", "")),
		"max_prompt_once": true,
		"choices": choice_map,
		"openings": openings_value.duplicate(true),
		"midpoints": midpoints_value.duplicate(true),
		"draw_plan": draw_plan,
		"finish_button_labels": label_variants.duplicate(),
		"finish_response_pool": response_pool.duplicate(),
		"free_aftercare_lines": free_lines.duplicate(true),
	}

static func _normalize_keyed_pools(value: Variant) -> Dictionary:
	if not value is Dictionary:
		return {}
	var result := {}
	for raw_key in value:
		var key := str(raw_key).replace(":", "|")
		result[key] = value[raw_key]
	return result
