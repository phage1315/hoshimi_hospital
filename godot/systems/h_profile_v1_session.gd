extends RefCounted
## First-pass, asset-independent runtime for the H-profile interaction loop.
## This is intentionally separate from clinical palpation and the legacy
## adult-intimacy session until the new profile format is content-validated.

const ACTIONS := ["caress", "kiss", "lick", "light_bite"]
const ZONES := ["lips", "cheeks", "neck", "breasts", "nipples", "navel", "torso_other", "genitals", "thighs"]
const TIERS := ["low", "mild", "strong", "favorite"]
const TIER_GAIN := {"low": 2, "mild": 6, "strong": 12, "favorite": 18}
const EXPRESSION_IDS := ["neutral", "annoyed", "pleased", "flustered", "delighted", "peak"]
const DEFAULT_EXPRESSION_BY_TIER := {"low": "annoyed", "mild": "pleased", "strong": "flustered", "favorite": "delighted"}
const IDLE_EXPRESSION := "neutral"
const EXPRESSION_ATLAS_CELLS := {
	# The approved transparent atlas is 1529×1029, so divide at its visible
	# gutters instead of assuming mathematically identical 512px cells.
	"pleased": Rect2i(0, 0, 510, 500),
	"annoyed": Rect2i(510, 0, 509, 500),
	"neutral": Rect2i(1019, 0, 510, 500),
	"flustered": Rect2i(0, 500, 510, 500),
	"delighted": Rect2i(510, 500, 509, 500),
	"peak": Rect2i(1019, 500, 510, 500),
}
const PHASES := ["foreplay", "h_stage", "h_finish_wait", "h_finish_response", "after_cg", "completed"]
const HOTSPOT_PRIORITY := ["lips", "nipples", "genitals", "navel", "breasts", "cheeks", "neck", "thighs", "torso_other"]
const SceneContext = preload("res://godot/systems/scene_content_context.gd")

var actor_id := ""
var profile: Dictionary = {}
var excitement := 0
var phase := "foreplay"
var history: Array[Dictionary] = []
var h_scene_index := 0
var h_scene_style := ""
var selected_h_scene_lines: Array[String] = []
var h_finish_label := ""
var h_finish_response_line := ""
var h_finish_locked := false
var max_prompt_shown := false
var h_event_completed := false
var last_error := ""
var location_id := ""
var event_id := ""
var locale_id := "zh_CN"
var context_resolver

func _init(actor: String, data: Dictionary, context_location: String = "", context_event: String = "", context_locale: String = "zh_CN") -> void:
	actor_id = actor
	profile = data.duplicate(true)
	set_context(context_location, context_event, context_locale)
	if not valid_setup():
		phase = "invalid"

func set_context(context_location: String, context_event: String = "", context_locale: String = "zh_CN") -> void:
	location_id = context_location
	event_id = context_event
	locale_id = context_locale
	context_resolver = SceneContext.new(profile.get("context_overrides", {}), location_id, event_id, locale_id)

func dialogue_pool(key: String, fallback: Array) -> Array:
	if context_resolver != null:
		var result: Dictionary = context_resolver.dialogue([key])
		if not bool(result.get("ok", false)):
			last_error = str(result.get("error", "上下文对白数据无效。"))
			return []
		if bool(result.get("found", false)):
			return result.value
	return fallback.duplicate(true)

func dialogue_line(key: String, fallback: String, salt: int = -1) -> String:
	var pool := dialogue_pool(key, [])
	if pool.is_empty():
		return fallback
	var chosen_salt := history.size() if salt < 0 else salt
	var value: Variant = pool[posmod(chosen_salt, pool.size())]
	return str(value.get("line", "")) if value is Dictionary else str(value)

func location_entry_lines(fallback: Array) -> Array:
	return dialogue_pool("entry", fallback)

func max_prompt(fallback: String) -> String:
	return dialogue_line("max_prompt", fallback)

func aftercare_lines(fallback: Array) -> Array:
	return dialogue_pool("aftercare", fallback)

func _context_asset(slot: String) -> Dictionary:
	if context_resolver == null:
		return {"ok": true, "found": false}
	return context_resolver.asset(slot)

func background_id(fallback: String) -> String:
	var selected := _context_asset("background")
	if not selected.get("ok", false):
		last_error = str(selected.get("error", "场景背景配置无效。"))
		return ""
	return str(selected.value.get("id", fallback)) if selected.get("found", false) else fallback

func body_map_image(fallback: String = "") -> String:
	var layout: Dictionary = profile.get("body_map_layout", {})
	var selected: Dictionary = context_resolver.asset("body_map", layout) if context_resolver != null else {"ok": true, "found": false}
	if not selected.get("ok", false):
		last_error = str(selected.get("error", "身体图配置无效。"))
		return ""
	return str(selected.value.get("path", fallback)) if selected.get("found", false) else (fallback if not fallback.is_empty() else str(profile.get("body_map_image", "")))

func valid_setup() -> bool:
	if actor_id.is_empty() or not bool(profile.get("enabled", false)):
		last_error = "角色没有可用的 H profile。"
		return false
	if int(profile.get("schema_version", 0)) != 1:
		last_error = "H profile 版本不是 V1。"
		return false
	for field in ["zone_defaults", "action_defaults", "action_zone_overrides", "reactions", "expressions", "location_entry", "scene"]:
		if not profile.get(field, {}) is Dictionary:
			last_error = "H profile 字段格式错误：%s" % field
			return false
	var zone_defaults: Dictionary = profile.zone_defaults
	var action_defaults: Dictionary = profile.action_defaults
	var action_overrides: Dictionary = profile.action_zone_overrides
	var expressions: Dictionary = profile.expressions
	for zone in ZONES:
		if str(zone_defaults.get(zone, "")) not in TIERS:
			last_error = "H profile 缺少有效部位默认档位：%s" % zone
			return false
	for action in ACTIONS:
		var action_tier := str(action_defaults.get(action, ""))
		if (not action_tier.is_empty() and action_tier not in TIERS) or not action_overrides.get(action, {}) is Dictionary:
			last_error = "H profile 动作默认档位或覆盖表无效：%s" % action
			return false
	for expression_id in EXPRESSION_IDS:
		if str(expressions.get(expression_id, "")).is_empty():
			last_error = "H profile 缺少表情资源：%s" % expression_id
			return false
	for section in ["start", "middle", "finish"]:
		var lines: Variant = profile.scene.get(section, null)
		if not lines is Array or lines.size() != 3:
			last_error = "H profile 的 %s 场景文本必须恰为三句。" % section
			return false
	for image_field in ["h_stage_image", "after_cg_image"]:
		if str(profile.get(image_field, "")).is_empty():
			last_error = "H profile 缺少资源路径：%s" % image_field
			return false
	last_error = ""
	return true

func preference_for(action: String, zone: String) -> String:
	if action not in ACTIONS or zone not in ZONES:
		return ""
	var combo_map: Dictionary = profile.get("action_zone_overrides", {})
	var action_overrides: Dictionary = combo_map.get(action, {})
	var action_defaults: Dictionary = profile.get("action_defaults", {})
	var zone_defaults: Dictionary = profile.get("zone_defaults", {})
	var tier := str(action_overrides.get(zone, action_defaults.get(action, zone_defaults.get(zone, profile.get("default_preference", "mild")))))
	return tier if tier in TIERS else "mild"

func gain_for(action: String, zone: String) -> int:
	return int(TIER_GAIN.get(preference_for(action, zone), 0))

func _select_line(pool: Variant, salt: int) -> Dictionary:
	if not pool is Array or pool.is_empty():
		return {}
	var item: Variant = pool[posmod(salt, pool.size())]
	return item.duplicate(true) if item is Dictionary else {"line": str(item)}

func reaction_for(action: String, zone: String, tier: String) -> Dictionary:
	var reactions: Dictionary = profile.get("reactions", {})
	var combo: Dictionary = reactions.get("combo", {})
	var zone_tier: Dictionary = reactions.get("zone_tier", {})
	var action_tier: Dictionary = reactions.get("action_tier", {})
	var tier_fallback: Dictionary = reactions.get("tier_fallback", {})
	var context_keys := [
		"reaction.combo:%s|%s" % [action, zone],
		"reaction.zone_tier:%s|%s" % [zone, tier],
		"reaction.action_tier:%s|%s" % [action, tier],
		"reaction.tier_fallback:%s" % tier,
	]
	var base_keys := [
		"%s|%s" % [action, zone],
		"%s|%s" % [zone, tier],
		"%s|%s" % [action, tier],
		tier,
	]
	var contextual: Dictionary = context_resolver.dialogue(context_keys) if context_resolver != null else {"ok": true, "found": false}
	if not contextual.get("ok", false):
		last_error = str(contextual.get("error", "上下文反应对白无效。"))
		return {}
	if contextual.get("ok", false) and contextual.get("found", false):
		var selected_context := _select_line(contextual.value, history.size())
		if not selected_context.is_empty():
			return selected_context
	var pools: Array = [combo, zone_tier, action_tier, tier_fallback]
	for index in range(pools.size()):
		var pool_map: Dictionary = pools[index]
		var selected := _select_line(pool_map.get(base_keys[index], []), history.size())
		if not selected.is_empty():
			return selected
	return {}

func perform(action: String, zone: String) -> Dictionary:
	last_error = "当前阶段不能进行触碰互动。"
	if phase != "foreplay" or action not in ACTIONS or zone not in ZONES:
		return {"accepted": false}
	var tier := preference_for(action, zone)
	var before := excitement
	excitement = mini(100, excitement + int(TIER_GAIN[tier]))
	var reaction := reaction_for(action, zone, tier)
	var expression := str(reaction.get("expression", DEFAULT_EXPRESSION_BY_TIER.get(tier, IDLE_EXPRESSION)))
	if expression not in EXPRESSION_IDS:
		expression = str(DEFAULT_EXPRESSION_BY_TIER.get(tier, IDLE_EXPRESSION))
	if excitement >= 100:
		expression = "peak"
	var show_max_prompt := excitement >= 100 and not max_prompt_shown
	if show_max_prompt:
		max_prompt_shown = true
	var record := {
		"kind": "foreplay",
		"action": action,
		"zone": zone,
		"tier": tier,
		"gain": excitement - before,
		"excitement": excitement,
		"line": str(reaction.get("line", "")),
		"expression": expression,
		"show_max_prompt": show_max_prompt,
	}
	history.append(record)
	last_error = ""
	var result := record.duplicate(true)
	result["accepted"] = true
	result["phase"] = phase
	return result

static func point_to_uv(point: Vector2, displayed_image_rect: Rect2) -> Vector2:
	if displayed_image_rect.size.x <= 0.0 or displayed_image_rect.size.y <= 0.0 or not displayed_image_rect.has_point(point):
		return Vector2(-1.0, -1.0)
	return (point - displayed_image_rect.position) / displayed_image_rect.size

func hit_test(point_uv: Vector2, bodymap: Dictionary) -> String:
	if phase != "foreplay":
		return ""
	var hotspots: Dictionary = bodymap.get("hotspots", {})
	# Specific areas win over broad overlapping body regions.
	for zone in HOTSPOT_PRIORITY:
		var polygons: Variant = hotspots.get(zone, [])
		if not polygons is Array:
			continue
		for raw_polygon in polygons:
			if not raw_polygon is Array or raw_polygon.size() < 3:
				continue
			var polygon := PackedVector2Array()
			var valid := true
			for raw_point in raw_polygon:
				if not raw_point is Array or raw_point.size() != 2:
					valid = false
					break
				polygon.append(Vector2(float(raw_point[0]), float(raw_point[1])))
			if valid and Geometry2D.is_point_in_polygon(point_uv, polygon):
				return zone
	return ""

func h_stage_image() -> String:
	var selected := _context_asset("h_stage")
	if not selected.get("ok", false):
		last_error = str(selected.get("error", "阶段图片配置无效。"))
		return ""
	return str(selected.value.get("path", profile.get("h_stage_image", ""))) if selected.get("found", false) else str(profile.get("h_stage_image", ""))

func idle_expression() -> String:
	return IDLE_EXPRESSION

func expression_atlas_region(expression_id: String) -> Rect2i:
	return EXPRESSION_ATLAS_CELLS.get(expression_id, EXPRESSION_ATLAS_CELLS[IDLE_EXPRESSION])

func h_scene_lines() -> Array[String]:
	if not selected_h_scene_lines.is_empty():
		return selected_h_scene_lines.duplicate()
	var result: Array[String] = []
	var scene: Dictionary = profile.get("scene", {})
	for section in ["start", "middle", "finish"]:
		for line in dialogue_pool("scene." + section, scene.get(section, [])):
			result.append(str(line))
	return result

func begin_h_stage(style_id: String) -> bool:
	if phase != "foreplay" or excitement < 100:
		return false
	var flow: Dictionary = profile.get("flow", {})
	var choices: Dictionary = flow.get("choices", {})
	if not choices.has(style_id):
		return false
	var scene: Dictionary = profile.get("scene", {})
	var draw_plan: Array = flow.get("draw_plan", [])
	var openings: Dictionary = flow.get("openings", {})
	var midpoints: Dictionary = flow.get("midpoints", {})
	var selected: Array[String] = []
	for plan_value in draw_plan:
		if not plan_value is Dictionary:
			return false
		var plan: Dictionary = plan_value
		if str(plan.get("kind", "")) == "style_line":
			var style_lines: Dictionary = openings if str(plan.get("field", "")) == "openings" else midpoints
			var field := str(plan.get("field", ""))
			var fallback_style_line := str(style_lines.get(style_id, ""))
			var style_line := dialogue_line("style." + field.trim_suffix("s") + "." + style_id, fallback_style_line)
			if style_line.is_empty():
				return false
			selected.append(style_line)
		elif str(plan.get("kind", "")) == "scene_pool":
			var section := str(plan.get("section", ""))
			var pool: Variant = dialogue_pool("scene." + section, scene.get(section, []))
			if not pool is Array or pool.size() < int(plan.get("draw", 0)):
				return false
			var shuffled: Array = pool.duplicate()
			shuffled.shuffle()
			for line_index in range(int(plan.get("draw", 0))):
				selected.append(str(shuffled[line_index]))
		else:
			return false
	if selected.is_empty():
		return false
	h_scene_style = style_id
	selected_h_scene_lines = selected
	h_scene_index = 0
	var finish_labels: Array = dialogue_pool("finish.labels", profile.get("flow", {}).get("finish_button_labels", []))
	if finish_labels.size() != 5:
		return false
	h_finish_label = str(finish_labels.pick_random())
	h_finish_response_line = ""
	h_finish_locked = false
	phase = "h_stage"
	last_error = ""
	return true

func current_h_scene_line() -> String:
	if phase == "h_finish_response":
		return h_finish_response_line
	var lines := h_scene_lines()
	return lines[h_scene_index] if h_scene_index >= 0 and h_scene_index < lines.size() else ""

func advance_h_stage() -> bool:
	if phase == "h_stage":
		h_scene_index += 1
		if h_scene_index >= h_scene_lines().size():
			phase = "h_finish_wait"
		return true
	if phase == "h_finish_response":
		phase = "after_cg"
		h_event_completed = true
		return true
	return false

func choose_h_finish() -> bool:
	if phase != "h_finish_wait" or h_finish_locked:
		return false
	h_finish_locked = true
	var response_pool: Array = dialogue_pool("finish.responses", profile.get("flow", {}).get("finish_response_pool", []))
	if response_pool.size() != 4:
		h_finish_locked = false
		return false
	h_finish_response_line = str(response_pool.pick_random())
	phase = "h_finish_response"
	return not h_finish_response_line.is_empty()

func after_cg_image() -> String:
	var selected := _context_asset("after_cg")
	if not selected.get("ok", false):
		last_error = str(selected.get("error", "完成图片配置无效。"))
		return ""
	return str(selected.value.get("path", profile.get("after_cg_image", ""))) if selected.get("found", false) else str(profile.get("after_cg_image", ""))

func finish() -> bool:
	if phase != "after_cg":
		return false
	phase = "completed"
	h_event_completed = true
	return true

func snapshot() -> Dictionary:
	return {"actor_id": actor_id, "excitement": excitement, "phase": phase, "history": history.duplicate(true), "h_scene_index": h_scene_index, "h_scene_style": h_scene_style, "selected_h_scene_lines": selected_h_scene_lines.duplicate(), "h_finish_label": h_finish_label, "h_finish_response_line": h_finish_response_line, "h_finish_locked": h_finish_locked, "max_prompt_shown": max_prompt_shown, "h_event_completed": h_event_completed}

func restore(state: Dictionary) -> bool:
	if str(state.get("actor_id", "")) != actor_id:
		return false
	var restored_phase := str(state.get("phase", ""))
	var restored_excitement := int(state.get("excitement", -1))
	var restored_scene_index := int(state.get("h_scene_index", 0))
	if restored_phase not in PHASES.slice(0, PHASES.size() - 1) or restored_excitement < 0 or restored_excitement > 100 or not state.get("history") is Array or restored_scene_index < 0:
		return false
	var restored_lines: Array[String] = []
	for raw_line in state.get("selected_h_scene_lines", []):
		restored_lines.append(str(raw_line))
	if restored_phase == "h_stage" and (restored_lines.is_empty() or restored_scene_index >= restored_lines.size()):
		return false
	if restored_phase == "h_finish_response" and (not bool(state.get("h_finish_locked", false)) or str(state.get("h_finish_response_line", "")).is_empty()):
		return false
	var restored_history: Array[Dictionary] = []
	for item in state.history:
		if not item is Dictionary:
			return false
		restored_history.append(item.duplicate(true))
	excitement = restored_excitement
	phase = restored_phase
	h_scene_index = restored_scene_index
	h_scene_style = str(state.get("h_scene_style", ""))
	selected_h_scene_lines = restored_lines
	h_finish_label = str(state.get("h_finish_label", ""))
	h_finish_response_line = str(state.get("h_finish_response_line", ""))
	h_finish_locked = bool(state.get("h_finish_locked", false))
	max_prompt_shown = bool(state.get("max_prompt_shown", excitement >= 100))
	h_event_completed = bool(state.get("h_event_completed", false))
	history = restored_history
	return true
