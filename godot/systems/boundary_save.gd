extends RefCounted
## Persistent business facts only. Never call a session's snapshot_state here.
const VERSION := 37
const FORMAT := "boundary_facts_v1"
const GLOBAL_FIELDS := [
	"patient_cases", "patient_queue", "patient_referrals", "active_staff_patient",
	"staff_patient_practice_counts", "recent_patient_ids", "completed_surgeries_total",
	"completed_surgeries_by_group", "completed_surgeries_by_procedure", "character_progress_counters",
	"surgery_xp", "leadership_xp", "staff_skill_levels", "staff_training_credits",
	"successful_no_anesthesia_surgeries", "reported_surgeries", "unlocked_procedure_ids",
	"archived_player_effects", "campaign_seed", "intraoperative_crisis_enabled",
	"discarded_overtime_minutes", "story_time_advance_minutes", "archived_clinical_minutes",
	"story_flags", "probation_complete", "personal_nurse_system_unlocked", "personal_nurse_id",
	"special_event_completion_counts", "special_event_completion_days", "adult_intimacy_unlocks", "free_h_booking"
]
const VISIT_FIELDS := ["admitted", "minutes", "mistakes", "diagnosis", "notes", "player_effects"]
const OPERATION_FIELDS := ["minutes", "surgery_success", "surgery_aborted", "procedure_id", "team", "player_effects"]
const EFFECT_FIELDS := ["id", "label", "effects", "level_after", "level_before", "surgery_id", "team_average", "team_class", "xp"]
const RELATION_FIELDS := ["met", "level", "route", "affection", "familiarity", "flags", "event_history", "rank_history", "unlocked_benefits"]
const QUALITY_FIELDS := ["best_grade", "best_score", "last_grade", "last_score", "manual_completions", "quick_surgery_unlocked", "legacy_grandfathered"]
const SUMMARY_FIELDS := ["best_blood_loss", "best_elapsed_time", "complications", "cooperation_disruption_count", "dignity_break_count", "dignity_intrusion_count", "lowest_cooperation", "lowest_dignity", "minimum_stability_seen", "patient_caused_complication_count", "peak_fear", "peak_pain", "surgical_quality_grade", "surgical_quality_score"]
var error := ""
var error_key := "ui.save.invalid_business"
var warnings: Array[String] = []

static func copy_value(value: Variant) -> Variant:
	return value.duplicate(true) if value is Dictionary or value is Array else value

static func fields(source: Variant, keys: Array) -> Dictionary:
	var result := {}
	for key in keys:
		var value: Variant = source.get(key)
		if value != null:
			result[key] = copy_value(value)
	return result

static func history(source: Array, keys: Array) -> Array:
	var result := []
	for record in source:
		if record is Dictionary:
			result.append(fields(record, keys))
	return result

static func medical_notes(source: Dictionary) -> Dictionary:
	var result := {}
	for id in source:
		var note: Variant = source[id]
		result[id] = fields(note, ["id", "section", "text"]) if note is Dictionary else str(note)
	return result

static func quality(source: Dictionary) -> Dictionary:
	var result := {}
	for id in source:
		result[id] = fields(source[id], QUALITY_FIELDS)
		if source[id].get("last_summary") is Dictionary:
			result[id].last_summary = fields(source[id].last_summary, SUMMARY_FIELDS)
	return result

func capture(game: RefCounted) -> Dictionary:
	if not game.can_save_progress():
		return {}
	var result := fields(game, GLOBAL_FIELDS)
	result.merge({"version": VERSION, "content_version": 1, "save_format": FORMAT,
		"elapsed_minutes": game.elapsed(), "clinical_visits": {}, "surgery_outcomes": {},
		"character_completions": [], "micro_completions": []})
	result.relationship_state = {}
	for id in game.relationships:
		result.relationship_state[id] = fields(game.relationships[id], RELATION_FIELDS)
	for key in ["surgery_xp_history", "leadership_xp_history", "archived_player_effect_history"]:
		result[key] = history(game.get(key), EFFECT_FIELDS)
	result.surgical_quality_records = quality(game.surgical_quality_records)
	result.sunday_history = history(game.sunday_history, ["day", "activity_id", "actor_id", "location_id"])
	result.time_log = []
	for record in game.time_log:
		result.time_log.append({"id": record.id, "start": record.start, "minutes": record.get("minutes")})
	for id in game.visits:
		var visit: RefCounted = game.visits[id]
		result.clinical_visits[id] = fields(visit, VISIT_FIELDS)
		result.clinical_visits[id].notes = medical_notes(visit.notes)
		result.clinical_visits[id].player_effect_history = history(visit.player_effect_history, EFFECT_FIELDS)
	for id in game.preops:
		var prep: RefCounted = game.preops[id]
		result.surgery_outcomes[id] = fields(prep, OPERATION_FIELDS)
		result.surgery_outcomes[id].player_effect_history = history(prep.player_effect_history, EFFECT_FIELDS)
		if not prep.surgery_success and not prep.surgery_aborted:
			result.surgery_outcomes[id].procedure_id = ""
			result.surgery_outcomes[id].team = {}
	for id in game.character_event_order:
		var event: RefCounted = game.character_events[id]
		if event.completed:
			result.character_completions.append({"id": id, "completed_day": event.completed_day,
				"minutes": event.settled_minutes, "actor_id": event.definition.get("actor_id", "")})
	for id in game.micro_event_order:
		var event: RefCounted = game.micro_events[id]
		if event.completed:
			result.micro_completions.append({"id": id, "trigger_day": event.trigger_day,
				"actor_id": event.definition.get("actor_id", "")})
	return result

static func integer(value: Variant, minimum: int = 0) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value)) and float(value) >= minimum

func decode(source: Variant) -> Dictionary:
	error = "存档业务数据无效，当前进度未改变。"
	warnings.clear()
	if not source is Dictionary:
		return {}
	var legacy: bool = source.get("version") == 36 and source.get("save_format") == "state_dictionary_v1"
	if not legacy and (source.get("version") != VERSION or source.get("save_format") != FORMAT):
		error_key = "ui.save.unverifiable_legacy"
		error = "此旧档缺少可直接恢复的已结算事实，不能通过重放剧情猜测进度；请保留原档并单独转换。"
		return {}
	if source.get("content_version") != 1:
		return {}
	var result: Dictionary = source.duplicate(true)
	if legacy:
		# Only the slot clock is authoritative in v36. Old per-action durations were
		# never stored; current scripts must not be used to invent historical costs.
		var meta: Variant = source.get("_slot_metadata")
		if not meta is Dictionary or not integer(meta.get("day"), 1) or not meta.get("clock") is String:
			error_key = "ui.save.missing_legacy_clock"
			error = "旧档没有可靠的槽位日期／时钟，无法确定已结算总时间；请保留原档并确认日期，不能用当前剧本倒推。"
			return {}
		var clock_parts: PackedStringArray = str(meta.clock).split(":")
		if clock_parts.size() != 2 or not clock_parts[0].is_valid_int() or not clock_parts[1].is_valid_int():
			return {}
		var hour := int(clock_parts[0])
		var minute := int(clock_parts[1])
		if hour < 9 or hour > 16 or minute < 0 or minute > 59:
			error_key = "ui.save.ambiguous_legacy_clock"
			error = "旧档时钟不在可确认的安全边界内，需要人工核对日期／加班结算。"
			return {}
		result.elapsed_minutes = (int(meta.day) - 1) * 480 + hour * 60 + minute - 540
		for key in ["progress", "preops"]:
			if not source.get(key) is Dictionary:
				return {}
			var facts := {}
			for id in source[key]:
				var record: Variant = source[key][id]
				if not record is Dictionary:
					return {}
				facts[id] = fields(record, VISIT_FIELDS if key == "progress" else OPERATION_FIELDS)
				if not record.get("player_effect_history", []) is Array:
					return {}
				facts[id].player_effect_history = history(record.get("player_effect_history", []), EFFECT_FIELDS)
			result["clinical_visits" if key == "progress" else "surgery_outcomes"] = facts
		for key in ["character_events", "micro_events"]:
			if not source.get(key) is Array:
				return {}
			var facts := []
			for record in source[key]:
				if not record is Dictionary or not record.get("state") is Dictionary:
					return {}
				if record.state.get("completed", false):
					var fact := fields(record.state, ["completed_day"] if key == "character_events" else ["trigger_day"])
					fact.id = record.get("id")
					# null explicitly means unknown breakdown, not zero paid time.
					if key == "character_events":
						fact.minutes = null
					facts.append(fact)
			result["character_completions" if key == "character_events" else "micro_completions"] = facts
		if not source.get("time_log") is Array:
			return {}
		result.time_log = history(source.time_log, ["id", "start"])
		for record in result.time_log:
			record.minutes = null
		warnings.append("旧档已迁移为安全边界事实；忽略节点、选项路径和临时演出，保留已结算数值及槽位时钟。未记录的历史单项耗时标为未知。")
		# Approved retirement of the old unsuccessful date: use its semantic flag,
		# not an endpoint alias or the old choice path. The clock stays untouched.
		var relations: Variant = result.get("relationship_state")
		if relations is Dictionary and relations.get("doc_sayaka") is Dictionary:
			var sayaka: Dictionary = relations.doc_sayaka
			if sayaka.get("level") == 0 and sayaka.get("flags") is Array and "sayaka_first_date_retry_pending" in sayaka.flags and sayaka.get("event_history") is Array:
				result.character_completions = result.character_completions.filter(func(record: Dictionary): return record.id != "sayaka_lv1_first_date")
				sayaka.flags.erase("sayaka_first_date_retry_pending")
				sayaka.event_history.erase("sayaka_lv1_first_date")
				warnings.append("旧版小夜香未成功约会恢复为未触发；已结算时间与数值保留，不重放旧分支。")
	if not integer(result.get("elapsed_minutes")) or int(result.elapsed_minutes) > 100000000:
		return {}
	if not result.get("relationship_state") is Dictionary:
		return {}
	for relation in result.relationship_state.values():
		if not relation is Dictionary:
			return {}
		for key in ["flags", "event_history", "rank_history", "unlocked_benefits"]:
			if not relation.get(key) is Array:
				return {}
			for id in relation[key]:
				if not id is String:
					return {}
	for pair in [["clinical_visits", VISIT_FIELDS], ["surgery_outcomes", OPERATION_FIELDS]]:
		if not result.get(pair[0]) is Dictionary:
			return {}
		for record in result[pair[0]].values():
			if not record is Dictionary or not integer(record.get("minutes")) or not record.get("player_effects") is Dictionary or not record.get("player_effect_history") is Array:
				return {}
			for metric in record.player_effects:
				if metric not in ["charm", "presence", "reputation"] or not (record.player_effects[metric] is int or record.player_effects[metric] is float) or not is_finite(float(record.player_effects[metric])):
					return {}
			for entry in record.player_effect_history:
				if not entry is Dictionary:
					return {}
	for pair in [["character_completions", "completed_day"], ["micro_completions", "trigger_day"]]:
		if not result.get(pair[0]) is Array:
			return {}
		for record in result[pair[0]]:
			if not record is Dictionary or not record.get("id") is String or not integer(record.get(pair[1]), 1):
				return {}
			if int(record[pair[1]]) > 1 + int(result.elapsed_minutes) / 480:
				return {}
			if record.get("minutes") != null and not integer(record.minutes):
				return {}
	if not result.get("time_log") is Array or not result.get("surgical_quality_records") is Dictionary:
		return {}
	for record in result.surgical_quality_records.values():
		if not record is Dictionary:
			return {}
	for record in result.time_log:
		if not record is Dictionary or not record.get("id") is String or not integer(record.get("start")) or (record.get("minutes") != null and not integer(record.minutes)):
			return {}
		if int(record.start) > int(result.elapsed_minutes):
			return {}
	result.surgical_quality_records = quality(result.surgical_quality_records)
	# Adapter names below are internal only; no persistent session snapshots.
	result.progress = result.clinical_visits
	result.preops = result.surgery_outcomes
	result.character_events = result.character_completions
	result.micro_events = result.micro_completions
	result.version = 36
	result.save_format = "state_dictionary_v1"
	result._boundary_facts = true
	for key in ["active_id", "active_preop_id", "active_character_event_id", "active_micro_event_id"]:
		result[key] = ""
	result.active_mode = "encounter"
	for key in ["active_special_event", "active_adult_intimacy"]:
		result[key] = null
	for key in ["pending_encounter_day_transition", "pending_surgery_day_transition"]:
		result[key] = false
	# Diagnosis reactions are presentation state of the previous visit, not a
	# patient-template flag. Admissions restore completed; new visits roll afresh.
	result.first_surgery_diagnosis_shock_state = {}
	result.diagnosis_shock_visit_variants = {}
	return result
