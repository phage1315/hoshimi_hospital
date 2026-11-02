extends RefCounted
## Business dates and case identities only. Never persist an operation's RNG or cursors.
const Facts = preload("res://godot/systems/advanced_referral_facts.gd")
const Model = preload("res://godot/systems/advanced_surgery_model.gd")
const Calendar = preload("res://godot/systems/fixed_calendar.gd")
const Tutorial := "advanced_referral_tutorial_chisato"
const KAORI := ["surgery_adv_thoracic_intraspinal_tumor_resection", "surgery_adv_posterior_mediastinal_neurogenic_tumor_resection", "surgery_adv_thoracic_spinal_stabilization_reconstruction"]

static func manifest() -> Array:
	var rows: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/release_manifest.json"))
	rows.sort_custom(func(a, b): return a.release_order < b.release_order)
	return rows

static func category(id: String) -> String:
	for row in manifest():
		if row.procedure_id == id: return str(row.category)
	if id in KAORI: return "ADVANCED_QUEST_KAORI"
	if id == "surgery_adv_artificial_heart_exchange": return "ADVANCED_TUTORIAL"
	if id.begins_with("surgery_legendary_"): return "LEGENDARY_STORY"
	return ""

static func is_advanced(id: String) -> bool:
	return not category(id).is_empty() or id.begins_with("surgery_adv_") or not Model.procedure(id).is_empty()

static func ready(row: Dictionary) -> bool:
	return bool(row.get("runtime_ready", false)) and not Model.procedure(str(row.procedure_id)).is_empty()

static func procedure_ready(id: String) -> bool:
	for row in manifest():
		if row.procedure_id == id: return ready(row)
	return false

static func replay_profile(id: String) -> Dictionary:
	var profiles: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/replay_case_profiles.json"))
	return profiles.get(id, {})

static func replay_compatible(record: Dictionary) -> bool:
	if not bool(record.get("replay", false)): return true
	var required := str(replay_profile(str(record.get("procedure_id", ""))).get("case_subtype", ""))
	return required.is_empty() or record.get("case_subtype", "") == required

static func migrate(old: Dictionary) -> Dictionary:
	if old.get("version", 0) == 2: return old
	var s := Facts.fresh()
	for key in old: s[key] = old[key].duplicate(true) if old[key] is Array or old[key] is Dictionary else old[key]
	s.version = 2
	# A settled completion date is reliable evidence. Never infer dates from current time.
	for record in s.completed:
		if record.success and int(record.day) > 0:
			var id := str(record.procedure_id)
			s.clear_days[id] = mini(int(s.clear_days.get(id, record.day)), int(record.day))
	return s

static func tutorial_settled(g: RefCounted) -> bool:
	return int(g.special_event_completion_counts.get(Tutorial, 0)) > 0 and g.story_flag("advanced_referral_random_cases_enabled")

static func sync(g: RefCounted, today: int) -> void:
	if g.advanced_referral_facts.is_empty() and not tutorial_settled(g): return
	g.advanced_referral_facts = migrate(g.advanced_referral_facts)
	var s: Dictionary = g.advanced_referral_facts
	if int(s.activated_day) == 0 and tutorial_settled(g):
		var recorded := int(g.special_event_completion_days.get(Tutorial, 0))
		if recorded > 0 and recorded <= today: s.activated_day = recorded
	if int(s.activated_day) <= 0: return
	update_pool(s, today, g.campaign_seed, preload("res://godot/systems/advanced_presentation.gd").random_patient_ids(g))
	update_gates(g, s)

static func issue(g: RefCounted, s: Dictionary) -> String:
	if int(s.get("activated_day", 0)) == 0 and g.story_flag("advanced_referral_random_cases_enabled"):
		return "activation_date_missing" if tutorial_settled(g) else "tutorial_settlement_missing"
	for id in s.get("procedures", {}):
		if s.procedures[id] == "CLEARED" and not s.get("clear_days", {}).has(id): return "clear_date_missing"
	return ""

static func update_pool(s: Dictionary, today: int, campaign_seed: int, patients: Array, rows: Array = []) -> void:
	if rows.is_empty(): rows = manifest()
	var activated := int(s.activated_day)
	if activated <= 0: return
	var month: Dictionary = Calendar.date_for_day(activated)
	var quota := 3
	# Real calendar boundaries, including year rollover and short February.
	for d in range(activated + 1, mini(today, Calendar.GAME_DAYS) + 1):
		var date := Calendar.date_for_day(d)
		if date.year == month.year and date.month == month.month: continue
		if int(date.date) in [1, 15]: quota += 1
	for row in rows:
		if int(row.release_order) <= quota and row.procedure_id not in s.unlocked: s.unlocked.append(row.procedure_id)
	# Keep existing slots stable; only a settled first attempt frees a slot.
	s.new_board = s.new_board.filter(func(id): return not s.procedures.has(id))
	var active: Dictionary = s.appointment.get("case", {})
	if not active.is_empty() and not active.replay and not s.procedures.has(active.procedure_id) and active.procedure_id not in s.new_board:
		# Grandfather a pre-V2 booking without discarding it or adding a fourth slot.
		s.new_board.push_front(active.procedure_id)
		if s.new_board.size() > 3: s.new_board.resize(3)
	for row in rows:
		var id := str(row.procedure_id)
		if id not in s.unlocked: break
		if s.procedures.has(id) or id in s.new_board: continue
		if s.new_board.size() >= 3 or not ready(row): break
		s.new_board.append(id)
	var week := int(today / 7) # April 1 is Tuesday; day 7 is Monday.
	if int(s.week) == week: return
	s.week = week
	s.replays = []
	var monday := week * 7
	if monday < activated or patients.is_empty(): return
	var cleared := []
	for row in rows:
		var id := str(row.procedure_id)
		# A Monday settlement occurs after that morning's draw, so eligibility is strict.
		if ready(row) and s.procedures.get(id) == "CLEARED" and int(s.clear_days.get(id, 0)) > 0 and int(s.clear_days[id]) < monday: cleared.append(id)
	if cleared.is_empty(): return
	var random := RandomNumberGenerator.new()
	random.seed = hash("advanced-board-v2:%s:%s" % [campaign_seed, week])
	for i in range(2):
		var id := str(cleared[random.randi_range(0, cleared.size() - 1)])
		var patient := str(patients[random.randi_range(0, patients.size() - 1)])
		var record := {"id": "advanced_replay_%s_%s" % [week, i + 1], "procedure_id": id, "patient_id": patient, "replay": true, "case_seed": int(random.randi())}
		var subtype := str(replay_profile(id).get("case_subtype", ""))
		if not subtype.is_empty(): record.case_subtype = subtype
		s.replays.append(record)

static func counts(s: Dictionary) -> Dictionary:
	var regular := 0
	var advanced := 0
	for id in s.get("procedures", {}):
		if s.procedures[id] != "CLEARED": continue
		var kind := category(str(id))
		if kind == "ADVANCED_REGULAR": regular += 1
		if kind in ["ADVANCED_REGULAR", "ADVANCED_QUEST_KAORI"]: advanced += 1
	return {"regular": regular, "ray": advanced}

static func update_gates(g: RefCounted, s: Dictionary) -> void:
	var tally := counts(s)
	g.set_story_flag("kaori_advanced_prerequisite_met", tally.regular >= 5)
	g.set_story_flag("ray_legendary_prerequisite_met", tally.ray >= 10)

static func kaori_available(s: Dictionary, id: String, intake_day: int) -> bool:
	var index := KAORI.find(id)
	if index < 0 or counts(s).regular < 5 or s.get("procedures", {}).has(id) or not s.get("appointment", {}).is_empty(): return false
	if index == 0: return true
	var previous: String = KAORI[index - 1]
	var operation := int(s.get("successful_operation_days", {}).get(previous, 0))
	return s.procedures.get(previous) == "CLEARED" and operation > 0 and intake_day >= operation + 30
