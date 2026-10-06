extends RefCounted
## Data-driven runtime for one authored-milestone or repeatable after-work intimacy scene.
## This module has no clinical-body hotspot, patient-state, or palpation dependency.

const ACTIONS := ["touch", "kiss", "lick"]
const TARGETS := ["face", "neck", "chest", "waist", "thigh", "intimate"]
const POSITIONS := ["top", "bottom", "rear", "69"]
const PREFERENCE_GAIN := {
	"weak": 10,
	"normal": 15,
	"preferred": 20,
	"strong_preference": 25,
}
const TARGET_MODIFIER := {
	"weak": -5,
	"normal": 0,
	"preferred": 5,
	"strong_preference": 10,
}

var actor_id := ""
var profile: Dictionary = {}
var location_id := ""
var outfit_id := ""
var milestone_mode := false
var milestone_cg_override: Dictionary = {}
var unlocked_special_cgs: Array[String] = []
var excitement := 0
var initiative_triggered := false
var initiative_pending := false
var position_id := ""
var resolved_cg: Dictionary = {}
var phase := "foreplay"
var history: Array[Dictionary] = []
var last_error := ""

func _init(actor: String, data: Dictionary, location: String, outfit: String, milestone: bool = false, cg_override: Dictionary = {}, unlocked_cgs: Array = []) -> void:
	actor_id = actor
	profile = data.duplicate(true)
	location_id = location
	outfit_id = outfit
	milestone_mode = milestone
	milestone_cg_override = cg_override.duplicate(true)
	unlocked_special_cgs.assign(unlocked_cgs)
	if not valid_setup():
		phase = "invalid"

func valid_setup() -> bool:
	if actor_id.is_empty() or not bool(profile.get("enabled", false)):
		last_error = "角色没有可用的成人亲密资料。"
		return false
	if not profile.get("opening_lines", {}).has(location_id):
		last_error = "角色资料不支持这个地点。"
		return false
	if not profile.get("outfit_portraits", {}).has(outfit_id):
		last_error = "角色资料不支持这套服装。"
		return false
	last_error = ""
	return true

func current_opening_line() -> String:
	return str(profile.get("opening_lines", {}).get(location_id, ""))

func initiative_style() -> String:
	var overrides: Dictionary = profile.get("initiative_overrides", {})
	if overrides.has(location_id):
		return str(overrides[location_id])
	if overrides.has(outfit_id):
		return str(overrides[outfit_id])
	return str(profile.get("initiative", "responsive"))

func reaction_for(action: String, target: String) -> Dictionary:
	var target_pool: Array = profile.get("target_reactions", {}).get(target, [])
	var action_pool: Array = profile.get("action_reactions", {}).get(action, [])
	var pool: Array = target_pool if not target_pool.is_empty() else action_pool
	if pool.is_empty():
		return {}
	var index := history.size() % pool.size()
	return pool[index].duplicate(true)

func gain_for(action: String, target: String) -> int:
	var action_tier := str(profile.get("foreplay_preferences", {}).get(action, "normal"))
	var target_tier := str(profile.get("target_preferences", {}).get(target, "normal"))
	return clampi(int(PREFERENCE_GAIN.get(action_tier, 15)) + int(TARGET_MODIFIER.get(target_tier, 0)), 10, 25)

func perform(action: String, target: String) -> Dictionary:
	var result := {"accepted": false}
	last_error = "这个互动现在不能进行。"
	if phase != "foreplay" or initiative_pending or action not in ACTIONS or target not in TARGETS:
		return result
	var gained := gain_for(action, target)
	var before := excitement
	excitement = mini(100, excitement + gained)
	var reaction := reaction_for(action, target)
	var record := {
		"kind": "foreplay",
		"action": action,
		"target": target,
		"gain": excitement - before,
		"excitement": excitement,
		"line": str(reaction.get("line", "")),
		"expression": str(reaction.get("expression", "neutral")),
		"sfx": str(reaction.get("sfx", "")),
	}
	history.append(record)
	var initiative: Dictionary = profile.get("initiative_event", {})
	if not initiative_triggered and excitement >= int(initiative.get("threshold", 60)) and excitement < 100:
		initiative_pending = true
		phase = "initiative"
	if excitement >= 100:
		initiative_pending = false
		phase = "position"
	last_error = ""
	result = record.duplicate(true)
	result["accepted"] = true
	result["phase"] = phase
	return result

func initiative_prompt() -> String:
	return str(profile.get("initiative_event", {}).get("line", "")) if initiative_pending else ""

func resolve_initiative(follow_suggestion: bool) -> Dictionary:
	var result := {"accepted": false}
	last_error = "当前没有等待回应的主动事件。"
	if phase != "initiative" or not initiative_pending:
		return result
	var initiative: Dictionary = profile.get("initiative_event", {})
	initiative_triggered = true
	initiative_pending = false
	phase = "foreplay"
	var record := {
		"kind": "initiative",
		"initiative_style": initiative_style(),
		"followed": follow_suggestion,
		"line": str(initiative.get("follow_response" if follow_suggestion else "lead_response", "")),
		"expression": str(initiative.get("expression", "excited")),
	}
	history.append(record)
	last_error = ""
	result = record.duplicate(true)
	result["accepted"] = true
	result["phase"] = phase
	return result

func choose_position(value: String) -> Dictionary:
	var result := {"accepted": false}
	last_error = "现在还不能选择姿势。"
	if phase != "position" or value not in POSITIONS:
		return result
	position_id = value
	resolved_cg = resolve_cg()
	phase = "cg"
	var record := {
		"kind": "position",
		"position": value,
		"line": str(profile.get("position_lines", {}).get(value, "")),
		"cg_id": str(resolved_cg.get("id", "")),
		"cg_path": str(resolved_cg.get("path", "")),
	}
	history.append(record)
	last_error = ""
	result = record.duplicate(true)
	result["accepted"] = true
	result["phase"] = phase
	return result

func resolve_cg() -> Dictionary:
	if milestone_mode and not milestone_cg_override.is_empty():
		return milestone_cg_override.duplicate(true)
	var best: Dictionary = {}
	var best_score := -1
	for candidate in profile.get("special_cgs", []):
		var candidate_id := str(candidate.get("id", ""))
		if not unlocked_special_cgs.has(candidate_id):
			continue
		var required_location := str(candidate.get("location", ""))
		var required_outfit := str(candidate.get("outfit", ""))
		if not required_location.is_empty() and required_location != location_id:
			continue
		if not required_outfit.is_empty() and required_outfit != outfit_id:
			continue
		var score := int(not required_location.is_empty()) + int(not required_outfit.is_empty())
		if score > best_score:
			best = candidate.duplicate(true)
			best_score = score
	return best if not best.is_empty() else profile.get("fallback_h_cg", {}).duplicate(true)

func continue_from_cg() -> bool:
	if phase != "cg":
		return false
	phase = "after"
	return true

func after_lines() -> Array:
	return profile.get("after_lines", []).duplicate()

func finish() -> bool:
	if phase != "after":
		return false
	phase = "completed"
	return true

func completed() -> bool:
	return phase == "completed"

func snapshot() -> Dictionary:
	return {
		"actor_id": actor_id,
		"location_id": location_id,
		"outfit_id": outfit_id,
		"milestone_mode": milestone_mode,
		"milestone_cg_override": milestone_cg_override.duplicate(true),
		"unlocked_special_cgs": unlocked_special_cgs.duplicate(),
		"excitement": excitement,
		"initiative_triggered": initiative_triggered,
		"initiative_pending": initiative_pending,
		"position_id": position_id,
		"resolved_cg": resolved_cg.duplicate(true),
		"phase": phase,
		"history": history.duplicate(true),
	}

func restore(state: Dictionary) -> bool:
	if str(state.get("actor_id", "")) != actor_id or str(state.get("location_id", "")) != location_id or str(state.get("outfit_id", "")) != outfit_id:
		return false
	var restored_phase := str(state.get("phase", ""))
	var restored_excitement := int(state.get("excitement", -1))
	if restored_phase not in ["foreplay", "initiative", "position", "cg", "after"] or restored_excitement < 0 or restored_excitement > 100 or not state.get("history") is Array:
		return false
	milestone_mode = bool(state.get("milestone_mode", false))
	milestone_cg_override = state.get("milestone_cg_override", {}).duplicate(true)
	unlocked_special_cgs.clear()
	for cg_id in state.get("unlocked_special_cgs", []):
		if not cg_id is String:
			return false
		unlocked_special_cgs.append(cg_id)
	excitement = restored_excitement
	initiative_triggered = bool(state.get("initiative_triggered", false))
	initiative_pending = bool(state.get("initiative_pending", false))
	position_id = str(state.get("position_id", ""))
	resolved_cg = state.get("resolved_cg", {}).duplicate(true)
	phase = restored_phase
	history.clear()
	for record in state.history:
		if not record is Dictionary:
			return false
		history.append(record.duplicate(true))
	return true
