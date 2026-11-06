extends SceneTree
const Sweat = preload("res://godot/systems/advanced_or_sweat_break.gd")
const Dialogue = preload("res://godot/systems/advanced_operative_dialogue.gd")
const Session = preload("res://godot/systems/advanced_surgery_session.gd")
const Model = preload("res://godot/systems/advanced_surgery_model.gd")
const ID := "surgery_adv_posttraumatic_thoracolumbar_kyphosis_correction"
const ROSTER := {"first_assistant":"a", "second_assistant":"b", "primary_scrub":"c", "secondary_scrub":"d", "primary_circulating":"e", "secondary_circulating":"f", "anesthesia":"g"}
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(Sweat.PATH))
	check(data.schema_version == "advanced_or_ambient_sweat_v1", "Ambient resource loads")
	var threshold_count := 0
	var variant_count := 0
	var line_count := 0
	for role in data.thresholds_minutes:
		threshold_count += data.thresholds_minutes[role].size()
		variant_count += data.variants[role].size()
		for variant in data.variants[role]:
			line_count += variant.lines.size()
			for line in variant.lines:
				check(not str(line.text).is_empty() and not str(line.text_en).is_empty(), "Bilingual line exists")
	check(threshold_count == 16 and variant_count == 20 and line_count == 57, "Complete author content")
	var probe := Sweat.new(7, ROSTER)
	probe.on_transition(119.0, true)
	check(probe.consumed.is_empty(), "119 minutes does not cross 120")
	probe.on_transition(120.0, false)
	check(probe.consumed.has("SWB_lead_surgeon_120"), "Exact 120-minute boundary consumes 120 once")
	probe.on_transition(121.0, false)
	check(probe.consumed.size() == 1, "120 to 121 does not reroll 120")
	probe.on_transition(121.0, true)
	check(probe.consumed.size() == 1 and probe.current().is_empty(), "Redraw neither rerolls nor queues terminal dialogue")
	probe.on_transition(165.0, false)
	check(probe.consumed.has("SWB_assistant_1_150"), "Next boundary consumes assistant threshold")
	var collisions := 0
	var selected_roles: Dictionary = {}
	var hit := 0
	for seed_value in range(1000):
		var trial := Sweat.new(seed_value, ROSTER)
		trial.on_transition(120.0, true)
		if not trial.current().is_empty(): hit += 1
		var large := Sweat.new(seed_value, ROSTER)
		large.on_transition(240.0, true)
		check(large.consumed.size() == 4, "Four crossed thresholds each consumed")
		if not large.current().is_empty():
			collisions += 1
			selected_roles[str(large.selected_group).rsplit("_", true, 1)[0]] = true
			check(large.pending_lines.size() <= 3, "At most one group queued")
	check(hit > 250 and hit < 350, "Independent roll distribution near 30 percent")
	check(collisions > 0 and selected_roles.size() > 1, "Collision selection spans roles")
	var absent := ROSTER.duplicate(true)
	absent.erase("secondary_scrub")
	absent.erase("secondary_circulating")
	for seed_value in range(100):
		var trial := Sweat.new(seed_value, absent)
		trial.on_transition(690.0, true)
		for line in trial.pending_lines:
			check(line.speaker_role != "scrub_secondary" and line.speaker_role != "circulating_secondary" and line.speaker_role != "circulating_wiper", "Absent role filtered")
	var unstaffed := Sweat.new(4, {})
	unstaffed.on_transition(690.0, true)
	check(unstaffed.current().is_empty() and unstaffed.consumed.size() == 16, "No circulating nurse prevents presentation but consumes candidates")
	var no_cap := Sweat.new(9, ROSTER)
	no_cap.data.event_probability = 1.0
	var groups_seen := 0
	for minute in range(1, 691):
		no_cap.on_transition(float(minute), true)
		if not no_cap.current().is_empty():
			groups_seen += 1
			no_cap.skip_group()
	check(no_cap.consumed.size() == 16 and groups_seen == 16, "No cooldown or operation-wide cap")
	var found := false
	for seed_value in range(100):
		var ambient := Sweat.new(seed_value, ROSTER)
		ambient.on_transition(121.0, true)
		if ambient.current().is_empty(): continue
		found = true
		var definition := Model.procedure(ID)
		var team: Dictionary = Model.fixtures("surgery_open_whipple")[0].duplicate(true)
		var session := Session.new(definition, team, 87, [], {}, true)
		session.sweat_break = ambient
		session.operative_dialogue = Dialogue.new(ID)
		check(session.operative_dialogue.current(session).id == ambient.current().id, "Ambient plays before next stage V2 line")
		check(not session.act(), "Ambient prevents stage action")
		var count := ambient.pending_lines.size()
		check(session.operative_dialogue.skip_sequence(session) == count, "Skip consumes only ambient group")
		check(session.operative_dialogue.history.size() == count, "Skipped lines enter memory log once")
		check(str(session.operative_dialogue.current(session).id).ends_with("_B1"), "V2 stage line follows ambient")
		break
	check(found, "Found deterministic triggered threshold")
	# Exercise the real stage resolver and acknowledgement gate with an in-memory
	# one-minute schedule, so no elapsed-time field or production data is forged.
	var actual_def := Model.procedure(ID)
	var actual_team: Dictionary = Model.fixtures("surgery_open_whipple")[0].duplicate(true)
	var live := Session.new(actual_def, actual_team, 87, [], ROSTER, false)
	live.operative_dialogue = Dialogue.new(ID)
	live.sweat_break = Sweat.new(87, ROSTER)
	for role in live.sweat_break.data.thresholds_minutes:
		live.sweat_break.data.thresholds_minutes[role] = []
	live.sweat_break.data.thresholds_minutes.lead_surgeon = [1]
	live.sweat_break.data.event_probability = 1.0
	for _line in range(2): check(live.operative_dialogue.advance_sequence(live), "Actual before-action V2 dialogue advances")
	check(live.act(), "Actual Petra stage action settles")
	check(float(live.physiology.procedure_state.elapsed_time) > 1.0, "Real physiology resolver adds elapsed time")
	check(live.sweat_break.current().is_empty(), "No ambient interruption before after-resolution")
	for _line in range(2): check(live.operative_dialogue.advance_sequence(live), "Actual after-resolution V2 dialogue advances")
	var game_rng_state: int = live.rng.state
	var hp_before: int = live.hp
	check(live.acknowledge(), "Actual stage acknowledgement reaches safe gate")
	check(live.index == 1 and not live.sweat_break.current().is_empty(), "Safe gate starts one ambient group before next stage")
	check(live.rng.state == game_rng_state and live.hp == hp_before, "Ambient event leaves gameplay RNG and HP untouched")
	print("ADVANCED SWEAT BREAK: %d checks / %d failures; single-threshold hits=%d/1000" % [checks, failures, hit])
	quit(0 if failures == 0 else 1)
