extends RefCounted
## Non-clinical NPC. Only settled event/business facts are persistent.
const INTRO := "megumin_intro_front_desk"
const AQUA := "aqua_intro_exam_chair"
const HALLOWEEN := "megumin_halloween_original_mage_reveal"
const HALLOWEEN_GROUP := "halloween_costume_reveal"
const PATH := "res://data/npcs/megumin/catalog.json"
const FACT_NUMBERS := ["aqua_day", "aqua_clock", "first_due_day", "due_day", "introduced_day", "first_school_day", "daily_day", "departure_day", "last_departure_ordinal", "legacy_scheduled_day"]
const FACT_MAPS := ["seen_days", "annual_groups"]

static var cached_catalog: Dictionary = {}

static func catalog() -> Dictionary:
	if cached_catalog.is_empty(): cached_catalog = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return cached_catalog

static func entries() -> Array:
	return catalog().entries

static func integer(value: Variant, minimum: int = 0) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value)) and float(value) >= minimum

static func valid_facts(value: Variant) -> bool:
	if not value is Dictionary: return false
	for key in value:
		if key in FACT_NUMBERS:
			if not integer(value[key]): return false
		elif key in FACT_MAPS:
			if not value[key] is Dictionary: return false
			for id in value[key]:
				if not id is String or id.is_empty() or not integer(value[key][id], 1): return false
		else: return false
	return true

static func clean_facts(value: Dictionary) -> Dictionary:
	var result := {}
	for key in value:
		if key in FACT_NUMBERS: result[key] = int(value[key])
		elif key in FACT_MAPS:
			result[key] = {}
			for id in value[key]: result[key][id] = int(value[key][id])
	return result

static func workday(game, day: int) -> bool:
	return day <= 365 and game.is_routine_workday(day)

static func next_workday(game, day: int) -> int:
	var result := day + 1
	while result <= 365 and not workday(game, result): result += 1
	return result

static func monday(game, day: int, clock: int, strictly_future: bool = false) -> int:
	var result := day + (1 if strictly_future or clock >= 540 else 0)
	while result <= 365 and str(game.calendar_date(result).weekday_id) != "mon": result += 1
	return result

static func record_aqua(game) -> void:
	if game.megumin_facts.has("first_due_day"): return
	var day: int = game.day_number()
	var clock: int = game.current_absolute_clock()
	var due := monday(game, day, clock)
	game.megumin_facts.merge({"aqua_day": day, "aqua_clock": clock, "first_due_day": due, "due_day": due})

static func synchronize(game) -> void:
	var facts: Dictionary = game.megumin_facts
	if not game.character_event_done(AQUA) or int(facts.get("introduced_day", 0)) > 0: return
	if not facts.has("due_day"):
		# Explicitly approved legacy rule: next Monday after load, no invented past timestamp.
		var due := monday(game, game.day_number(), game.current_absolute_clock(), true)
		facts.merge({"first_due_day": due, "due_day": due, "legacy_scheduled_day": game.day_number()})
	var today: int = game.day_number()
	var due: int = int(facts.due_day)
	while due < today or (due == today and (game.current_absolute_clock() > 540 or not workday(game, due))):
		due = next_workday(game, due)
		if due > 365: break
	facts.due_day = due

static func postpone(game) -> void:
	synchronize(game)
	if int(game.megumin_facts.get("due_day", 0)) == game.day_number():
		game.megumin_facts.due_day = next_workday(game, game.day_number())

static func busy(game) -> bool:
	return game.megumin_active or game.daydream_active or game.advanced_runtime != null or game.active_surgery_in_progress() or game.active_surgery_committed() or game.active_encounter_in_progress() or not game.active_preop_id.is_empty() or game.special_event_in_progress() or not game.active_character_event_id.is_empty() or not game.active_micro_event_id.is_empty() or not game.active_after_work_walk.is_empty() or game.active_adult_intimacy != null or not game.active_free_h_departure.is_empty()

static func intro_due(game) -> bool:
	synchronize(game)
	return not busy(game) and int(game.megumin_facts.get("introduced_day", 0)) == 0 and int(game.megumin_facts.get("due_day", 0)) == game.day_number() and game.current_absolute_clock() == 540 and workday(game, game.day_number()) and game.character_event_done(AQUA)

static func on_shift(game) -> bool:
	return workday(game, game.day_number()) and game.current_absolute_clock() >= 540 and game.current_absolute_clock() < 1020

static func halloween_costume_workday(game, year: int) -> int:
	# Use the existing campaign calendar and workday contract; no parallel calendar.
	var last := 0
	for day in range(1, 366):
		var date: Dictionary = game.calendar_date(day)
		if int(date.year) == year and int(date.month) == 10 and int(date.date) >= 25 and int(date.date) <= 31 and workday(game, day):
			last = day
	return last

static func halloween_costume_active(game, day: int = -1, clock: int = -1) -> bool:
	if day < 0: day = game.day_number()
	if clock < 0: clock = game.current_absolute_clock()
	if not met(game) or int(game.megumin_facts.introduced_day) >= day or clock < 540 or clock >= 1020 or not workday(game, day): return false
	var date: Dictionary = game.calendar_date(day)
	if int(date.month) != 10 or int(date.date) < 25 or int(date.date) > 31: return false
	return day == halloween_costume_workday(game, int(date.year))

static func display_portrait(game, key: String, content_id: String = "") -> String:
	if content_id == INTRO or not key.begins_with("reception_") or not halloween_costume_active(game): return key
	var mood := "neutral"
	if key == "reception_proud": mood = "proud"
	elif key == "reception_flustered": mood = "flustered"
	elif key == "reception_welcoming": mood = "happy"
	return "halloween_original_mage_" + mood

static func met(game) -> bool:
	return int(game.megumin_facts.get("introduced_day", 0)) > 0

static func formal_met(game, actor: String) -> bool:
	if not game.staff_is_met(actor): return false
	if actor == "doc_aqua": return game.character_event_done(AQUA)
	var found := false
	for e in game.character_event_definitions.values():
		if str(e.get("category", "")) == "introduction" and (str(e.get("actor_id", "")) == actor or actor in e.get("introduction_actor_ids", [])):
			found = true
			if game.character_event_done(str(e.id)): return true
	var unlock: String = str(game.staff_record(actor).get("staff_unlock_event", ""))
	if not unlock.is_empty(): return game.special_event_done(unlock)
	return not found # Existing staff_is_met is the settled introduction fact for legacy/special introductions.

static func present(game, actor: String, day: int = -1, clock: int = -1) -> bool:
	if not formal_met(game, actor): return false
	if actor == str(game.active_staff_patient.get("staff_id", "")) or actor == game.active_advanced_staff_patient: return false
	if day < 0 or day == game.day_number(): return actor in game.staff_present_at("lobby")
	var known: Array[String] = []
	for person in game.staff:
		if formal_met(game, str(person.id)): known.append(str(person.id))
	return game.presence_resolver != null and actor in game.presence_resolver.staff_at("lobby", day, clock, known)

static func gate(game, name: String) -> bool:
	if name.begins_with("!"): return not gate(game, name.substr(1))
	match name:
		"": return true
		"aqua_present": return present(game, "doc_aqua")
		"ren_present": return present(game, "nurse_haru")
		"takemi_public": return formal_met(game, "doc_takemi") and game.story_flag("takemi_research_open")
		"cameo_seen": return game.story_flag("megumin_cameo_seen")
	return false

static func ordinal(game, day: int) -> int:
	var result := 0
	for d in range(1, mini(day, 365) + 1):
		if workday(game, d): result += 1
	return result

static func eligible(game, entry: Dictionary, day: int, clock: int, departing: bool = false) -> bool:
	if not met(game) or not workday(game, day): return false
	var id: String = entry.content_id
	if id == INTRO: return false
	if id == HALLOWEEN:
		return not departing and halloween_costume_active(game, day, clock) and not game.megumin_facts.get("annual_groups", {}).has("%s:%s" % [game.calendar_date(day).year, HALLOWEEN_GROUP])
	var facts: Dictionary = game.megumin_facts
	var first_school: bool = int(facts.get("first_school_day", 0)) > 0
	var kind: String = entry.kind
	var school_bark := id in ["megumin_l17", "megumin_l18", "megumin_l19", "megumin_l20"]
	if departing != (kind == "afterwork_micro" or school_bark): return false
	if departing and (clock != 1020 or day <= int(facts.get("introduced_day", 0))): return false
	if not departing and clock >= 1020: return false
	if entry.get("requires_first_school_uniform_reveal", false) and not first_school: return false
	if id == "megumin_m07" and first_school: return false
	if kind != "ambient_bark" and day == int(facts.get("introduced_day", 0)): return false
	var cast: Dictionary = catalog().cast
	for name in entry.get("required_cast_canonical_names", []):
		var actor: String = str(cast.get(name, ""))
		if not formal_met(game, actor): return false
		# M23 only refers to Aqua's existing wish; she has no on-stage speech.
		if id != "megumin_m23" and not present(game, actor, day, clock): return false
	if id in ["megumin_r14", "megumin_r22"] and not gate(game, "takemi_public"): return false
	if id == "megumin_m06" and (str(game.calendar_date(day).weekday_id) != "fri" or clock < 960): return false
	if id == "megumin_m12" and clock >= 720: return false
	if id == "megumin_m17" and clock < 720: return false
	if id == "megumin_l08" and (clock < 840 or clock >= 900): return false
	if id == "megumin_l25" and (clock < 900 or clock >= 960): return false
	if id == "megumin_l14" and clock < 780: return false
	if id == "megumin_l28" and clock < 960: return false
	var date: Dictionary = game.calendar_date(day)
	var window: Dictionary = entry.get("window", {})
	if window.has("months") and int(date.month) not in window.months: return false
	var mmdd := "%02d-%02d" % [date.month, date.date]
	if window.has("start_mmdd") and (mmdd < str(window.start_mmdd) or mmdd > str(window.end_mmdd)): return false
	if id == "megumin_l27" and int(date.date) > 15: return false
	if id == "megumin_l28" and int(date.month) == 12 and int(date.date) < 20: return false
	# No festival is invented: dormant until actual business flags exist.
	var semantic: String = str(window.get("semantic", ""))
	if semantic in ["hospital_festival_preparation", "hospital_festival_active"] and not game.story_flag(semantic): return false
	var group: String = str(entry.get("annual_group", ""))
	if not group.is_empty() and facts.get("annual_groups", {}).has("%s:%s" % [date.year, group]): return false
	if id == "megumin_s12":
		var main_day: int = int(facts.get("seen_days", {}).get("megumin_m30", 0))
		if main_day == 0 or ordinal(game, day) <= ordinal(game, main_day) or day >= 365: return false
	return true

static func choose(game, departing: bool = false, day: int = -1, clock: int = -1) -> Dictionary:
	if busy(game): return {}
	if day < 0: day = game.day_number()
	if clock < 0: clock = game.current_absolute_clock()
	var facts: Dictionary = game.megumin_facts
	if departing and int(facts.get("departure_day", 0)) == day: return {}
	var candidates: Array = []
	for entry in entries():
		if eligible(game, entry, day, clock, departing): candidates.append(entry)
	for e in candidates:
		if e.content_id == HALLOWEEN: return e
	if departing and int(facts.get("first_school_day", 0)) == 0:
		for e in candidates:
			if e.content_id == "megumin_m07": return e
		return {}
	var longs: Array = candidates.filter(func(e): return e.kind != "ambient_bark")
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("megumin:%s:%s:%s:%s" % [game.campaign_seed, day, departing, game.megumin_recent_barks.size()])
	if departing:
		if ordinal(game, day) - int(facts.get("last_departure_ordinal", -100)) < 8 or rng.randf() >= 0.3: longs.clear()
	elif int(facts.get("daily_day", 0)) == day: longs.clear()
	if not longs.is_empty():
		var deadline: Array = longs.filter(func(e): return e.get("window", {}).has("end_mmdd"))
		if not deadline.is_empty():
			deadline.sort_custom(func(a, b): return str(a.window.end_mmdd) < str(b.window.end_mmdd))
			return deadline[0]
		var seen: Dictionary = facts.get("seen_days", {})
		var unseen: Array = longs.filter(func(e): return not seen.has(e.content_id))
		if not unseen.is_empty(): longs = unseen
		else:
			var cooled: Array = longs.filter(func(e): return ordinal(game, day) - ordinal(game, int(seen.get(e.content_id, 0))) >= 7)
			if not cooled.is_empty(): longs = cooled
			else:
				var not_yesterday: Array = longs.filter(func(e): return ordinal(game, day) - ordinal(game, int(seen.get(e.content_id, 0))) > 1)
				if not not_yesterday.is_empty(): longs = not_yesterday
		var groups := {}
		for e in longs:
			var theme: String = str(e.get("selection_group", "default"))
			if not groups.has(theme): groups[theme] = []
			groups[theme].append(e)
		var tickets: Array = []
		for theme in groups:
			var weight := 1 if theme in game.megumin_recent_themes else 3
			if groups[theme][0].get("window", {}).has("months"): weight *= 2
			for i in range(weight): tickets.append(theme)
		var group: Array = groups[tickets[rng.randi_range(0, tickets.size()-1)]]
		return group[rng.randi_range(0, group.size()-1)]
	var barks: Array = candidates.filter(func(e): return e.kind == "ambient_bark" and e.content_id not in game.megumin_recent_barks)
	if barks.is_empty(): barks = candidates.filter(func(e): return e.kind == "ambient_bark")
	if barks.is_empty(): return {}
	var tickets: Array = barks.duplicate()
	for e in barks:
		if e.get("window", {}).has("months"): tickets.append(e)
	return tickets[rng.randi_range(0, tickets.size()-1)]

static func complete(game, entry: Dictionary, day: int) -> void:
	var f: Dictionary = game.megumin_facts
	var id: String = entry.content_id
	if id == HALLOWEEN:
		if not f.has("annual_groups"): f.annual_groups = {}
		f.annual_groups["%s:%s" % [game.calendar_date(day).year, HALLOWEEN_GROUP]] = day
		if not f.has("seen_days"): f.seen_days = {}
		f.seen_days[id] = day
		return # No normal micro quota, theme history, rewards or elapsed time.
	if entry.kind == "ambient_bark":
		game.megumin_recent_barks.append(id)
		while game.megumin_recent_barks.size() > 5: game.megumin_recent_barks.pop_front()
		if id in ["megumin_l17", "megumin_l18", "megumin_l19", "megumin_l20"]: f.departure_day = day
		return
	f.daily_day = day
	if not f.has("seen_days"): f.seen_days = {}
	f.seen_days[id] = day
	if id == INTRO:
		f.introduced_day = day
		f.erase("due_day")
	if id == "megumin_m07": f.first_school_day = day
	if entry.kind == "afterwork_micro":
		f.departure_day = day
		f.last_departure_ordinal = ordinal(game, day)
	var group: String = str(entry.get("annual_group", ""))
	if not group.is_empty():
		if not f.has("annual_groups"): f.annual_groups = {}
		f.annual_groups["%s:%s" % [game.calendar_date(day).year, group]] = day
	game.megumin_recent_themes.append(str(entry.get("selection_group", "")))
	while game.megumin_recent_themes.size() > 2: game.megumin_recent_themes.pop_front()

static func definition(game, entry: Dictionary, locale: String) -> Dictionary:
	var beats: Array = []
	for b in entry.beats:
		if str(b.gate) in ["choice_a", "choice_b"] or gate(game, str(b.gate)): beats.append(b)
	var nodes: Array = []
	var merge := "@end"
	for i in range(beats.size()):
		var b: Dictionary = beats[i]
		if i > 0 and str(beats[i-1].gate) == "choice_b" and str(b.gate) == "": merge = str(b.id)
	for i in range(beats.size()):
		var b: Dictionary = beats[i]
		var target: String = str(beats[i+1].id) if i+1 < beats.size() else "@end"
		if str(b.gate) == "choice_a" and i+1 < beats.size() and str(beats[i+1].gate) == "choice_b": target = merge
		var node := {"id": b.id, "text": str(b.text.get(locale, "")), "speaker_label": str(b.speaker_label.get(locale, "")), "actor_id": b.actor_id, "portrait": display_portrait(game, str(b.get("portrait", "reception_neutral")), str(entry.content_id)),
			"choices": [{"id": "continue", "label": "Continue" if locale == "en" else "继续", "next": target}]}
		if b.has("choice_labels"):
			node.choices = []
			for branch in ["choice_a", "choice_b"]:
				for dest in beats:
					if dest.gate == branch:
						node.choices.append({"id": branch, "label": str(b.choice_labels[node.choices.size()].get(locale, "")), "next": dest.id})
						break
		nodes.append(node)
	return {"id": entry.content_id, "title": str(entry.title.get(locale, "")), "minutes": 0, "nodes": nodes, "start": nodes[0].id}
