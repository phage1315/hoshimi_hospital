extends SceneTree
const Flow = preload("res://godot/systems/serika_staff_surgery_callback.gd")
const Registry = preload("res://godot/systems/staff_patient_registry.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
var app
var checks := 0
var failures := 0
var rendered := 0
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run")
func fixture(g) -> void:
	g.reset()
	for d in g.special_event_definitions.values(): d.developer_only = true; d.auto_schedule = false
	for d in g.character_event_definitions.values():
		if str(d.id) != Flow.ID: d.trigger_mode = "after_work"
	g.meet_staff(Flow.ACTOR)
	g.set_story_flag("staff_as_patient_program_authorized")
	g.relation_for(Flow.ACTOR).level = 5
	# Completed milestone fact fixture, using the real authored Lv5 definition.
	var milestone_id := "serika_lv5_lay_down_burden"
	var milestone = load("res://godot/systems/character_event_session.gd").new(g.character_event_definitions[milestone_id])
	milestone.completed = true; milestone.completed_day = 1; milestone.settled_minutes = 60
	g.character_events[milestone_id] = milestone
	g.character_event_order.append(milestone_id)
	g.relation_for(Flow.ACTOR).rank_history.append(milestone_id)
	g.relation_for(Flow.ACTOR).event_history.append(milestone_id)
	g.set_test_time(g.day_number_for_date("2025-06-06"), 540)
func prepare(g):
	expect(g.invite_staff_patient(Flow.ACTOR, "surgery_breast_tumor"), "Fixture invitation")
	return g.open_preop(Registry.PREOP_ID)
func result(p, success: bool, surgery: String = "surgery_breast_tumor") -> void:
	p.procedure_id = surgery; p.procedure_name = p.surgeries[surgery].name
	p.procedure_minutes = p.surgeries[surgery].duration_minutes
	p.surgery_success = success; p.surgery_aborted = not success
	p.minutes = 35
	p.team = {"assistant_surgeon":"doc_aoi", "scrub_nurse":"nurse_haru", "circulating_nurse":"nurse_rin", "ward_nurse":"nurse_yui"}
func no_inner(v: Variant) -> void:
	if v is Dictionary:
		for k in v:
			expect(k not in ["node_id", "step_index", "last_choice", "choices", "action_log", "event_portraits"], "No persistent inner state " + str(k))
			no_inner(v[k])
	elif v is Array:
		for x in v: no_inner(x)
func roundtrip(g, completed: bool) -> void:
	var saved: Dictionary = g.snapshot()
	expect(not saved.is_empty(), "Safe-boundary save")
	no_inner(saved)
	var old_time: int = g.elapsed()
	var first: Dictionary = g.staff_patient_first_completion_days.duplicate(true)
	var nodes: Array = g.character_event_definitions[Flow.ID].nodes
	var duration: int = g.character_event_definitions[Flow.ID].minutes
	g.character_event_definitions[Flow.ID].nodes = []
	g.character_event_definitions[Flow.ID].minutes = 120
	var path := "/private/tmp/serika_staff_boundary_%s.json" % OS.get_process_id()
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(saved)); file.close()
	expect(g.restore(JSON.parse_string(FileAccess.get_file_as_string(path))), "Restore independent of nodes/duration: " + g.last_error)
	expect(g.elapsed() == old_time and g.staff_patient_first_completion_days == first and g.character_event_done(Flow.ID) == completed, "Stable time/completion/date")
	g.character_event_definitions[Flow.ID].nodes = nodes; g.character_event_definitions[Flow.ID].minutes = duration
	expect(g.restore(g.snapshot()) and g.elapsed() == old_time, "Second roundtrip stable")
	var bad: Dictionary = g.snapshot(); bad.staff_patient_first_completion_days[Flow.ACTOR] = -1
	expect(not g.restore(bad) and g.elapsed() == old_time and g.staff_patient_first_completion_days == first, "Invalid first date rejected atomically")
func dialogue_tests(locale: String) -> void:
	var c = app.content
	var actor: Dictionary = c.find_record("staff", Flow.ACTOR)
	var d: Dictionary = Registry.dialogue(Flow.ACTOR, locale)
	var patient: Dictionary = Registry.patient_record(actor, locale)
	expect(patient.reaction_lines.size() == 26 and d.reaction_lines.size() == 28, "26 active / 2 reserved reactions")
	expect(patient.personality.primary == "self_possessed" and patient.personality.secondary == "analytical", "Authored personality")
	var p = Preop.new(Registry.preop_definition(actor, c.find_record("surgeries", "surgery_breast_tumor"), locale), c.collections.staff, c.collections.surgeries, [patient], [], false, [], c.collections.patient_interactions)
	for rid in d.reaction_variants:
		var seen := {}
		for i in range(80):
			p.event_count = i
			var line: String = p.patient_reaction(rid, "BAD")
			expect(d.reaction_variants[rid].has(line), "Variant source " + rid)
			seen[line] = true
		expect(seen.size() == 2, "Both variants reachable " + rid)
	for pool in c.collections.patient_interactions:
		expect(p.patient_interaction_with_overrides(pool) == pool, "Generic pool unchanged " + str(pool.id))
	p.stage_id = "ward_visit"
	expect(p.apply({"kind":"action", "id":"explain_plan"}), "Explain action")
	expect(p.feedback_speaker == "patient" and p.feedback == d.reaction_lines.explain_plan, "Explain patient speaker")
	p.stage_id = "procedure_select"
	expect(p.apply({"kind":"procedure", "id":"surgery_appendix"}), "Mismatch selection")
	expect(p.feedback_speaker == "patient" and p.feedback == d.reaction_lines.procedure_mismatch, "Mismatch source/speaker")
	p.stage_id = "incision_ready"
	expect(p.current().prompt == d.reaction_lines.incision_ready and p.current().speaker == "patient", "Awake before-incision window")
	p.flags.append("anesthetized")
	expect(p.current().prompt != d.reaction_lines.incision_ready and p.current().speaker == "narrator", "No pre-incision speech under general anesthesia")
	for action in ["operative_positioning", "urinary_catheterization", "skin_disinfection", "incision_marking"]:
		expect(p.operative_preparation_reaction_id(action).is_empty(), "Asleep suppresses " + action)
	p.flags.erase("anesthetized")
	for action in ["operative_positioning", "urinary_catheterization", "skin_disinfection", "incision_marking"]:
		expect(p.operative_preparation_reaction_id(action) == action + "_awake", "Awake hook " + action)
	p.flags.append("no_anesthesia_confirmed")
	for action in ["operative_positioning", "urinary_catheterization", "skin_disinfection", "incision_marking"]:
		expect(p.operative_preparation_reaction_id(action) == action + "_none", "No anesthesia hook " + action)
	# Exercise every core action through its real action handler. Fixtures jump
	# to the registered stage in memory; production progression is unchanged.
	var core_count := 0
	for stage in p.definition.stages:
		for action in stage.get("actions", []):
			if not d.reaction_lines.has(action.id): continue
			var q = Preop.new(Registry.preop_definition(actor, c.find_record("surgeries", "surgery_appendix"), locale), c.collections.staff, c.collections.surgeries, [patient])
			q.stage_id = "procedure_select"
			expect(q.apply({"kind":"procedure", "id":"surgery_appendix"}), "Core fixture actual procedure")
			q.stage_id = stage.id
			for flag in action.requires: q.flags.append(str(flag))
			for flag in action.get("show_if_flags", []):
				if not q.flags.has(flag): q.flags.append(str(flag))
			expect(q.apply({"kind":"action", "id":action.id}), "Core action " + str(action.id) + " " + q.last_error)
			expect(q.feedback_speaker == "patient" and q.feedback == d.reaction_lines[action.id], "Core patient text/speaker " + str(action.id))
			core_count += 1
		expect(core_count <= 21, "No invented core actions")
	expect(core_count == 21, "All 21 direct core action hooks")
	for kind in ["none", "local", "epidural", "general"]:
		var q = Preop.new(Registry.preop_definition(actor, c.find_record("surgeries", "surgery_appendix"), locale), c.collections.staff, c.collections.surgeries, [patient])
		q.stage_id = "procedure_select"; q.apply({"kind":"procedure", "id":"surgery_appendix"})
		q.stage_id = "assistant_ready"; q.flags.append("surgery_started")
		q.team = {"assistant_surgeon":"doc_aoi"}
		q.flags.append("no_anesthesia_confirmed" if kind == "none" else kind + "_anesthesia")
		if kind == "general": q.flags.append("anesthetized")
		expect(q.apply({"kind":"action", "id":"assistant_stabilize"}), "Assistant handler " + kind)
		if kind == "general":
			for k in ["none", "local", "epidural"]: expect(not d.reaction_lines["assistant_stabilize_"+k] in q.feedback, "Asleep no assistant patient bark")
		else: expect(d.reaction_lines["assistant_stabilize_"+kind] in q.feedback, "Assistant patient response " + kind)
	for surgery in d.invitation_by_procedure:
		var line: String = app.game.staff_patient_invitation_line(Flow.ACTOR, surgery)
		expect(not line.is_empty() and not "{procedure_name}" in line, "Resolved invitation " + surgery)
func lifecycle_tests(g) -> void:
	fixture(g)
	expect(g.staff_patient_unlocked(Flow.ACTOR) and not Flow.eligible(g), "Unlock alone does not trigger")
	var p = prepare(g)
	expect(not Flow.eligible(g) and g.staff_patient_first_completion_days.is_empty(), "Invitation not a completed surgery")
	result(p, false)
	expect(g.finish_active_surgery_abort() and g.staff_patient_first_completion_days.is_empty(), "Abort not completion")
	p = prepare(g); result(p, true, "surgery_appendix")
	var actual_day: int = g.day_number()
	expect(g.finish_active_surgery(), "Actual wrong-procedure completion")
	expect(g.staff_patient_first_completion_days[Flow.ACTOR] == actual_day and g.staff_patient_practice_count(Flow.ACTOR,"surgery_appendix") == 0, "First completion independent of XP practice count")
	expect(not Flow.eligible(g), "No same-day callback")
	for date in ["2025-06-07", "2025-06-08"]:
		g.set_test_time(g.day_number_for_date(date), 540); expect(not Flow.eligible(g), "Weekend skipped " + date)
	g.set_test_time(g.day_number_for_date("2025-06-09"), 540)
	expect(Flow.eligible(g), "Next Monday ready")
	g.set_test_time(g.day_number_for_date("2025-06-11"), 540)
	expect(Flow.eligible(g), "Missed Monday retains callback")
	g.set_test_time(g.day_number_for_date("2025-07-21"), 540)
	expect(not Flow.eligible(g), "Public holiday skipped")
	g.set_test_time(g.day_number_for_date("2025-07-22"), 540)
	g.active_micro_event_id = "busy"; expect(not Flow.eligible(g), "Conflicts defer");g.active_micro_event_id = ""
	var mandatory: Dictionary = g.character_event_definitions[Flow.ID].duplicate(true)
	mandatory.id = "qa_mandatory_day_start"; mandatory.trigger_mode = "day_start"
	g.character_event_definitions[mandatory.id] = mandatory
	expect(not Flow.eligible(g) and g.start_character_event(Flow.ID) == null, "Mandatory day-start event defers callback")
	g.character_event_definitions.erase(mandatory.id)
	p = prepare(g); expect(not Flow.eligible(g), "Cannot appear at work while admitted");result(p,true)
	expect(g.finish_active_surgery() and g.staff_patient_first_completion_days[Flow.ACTOR] == actual_day, "Later surgery does not reset first date")
	roundtrip(g,false)
func play_callback(locale: String) -> void:
	var g = app.game
	var before: int = g.elapsed();var attrs: Dictionary = g.player_attributes().duplicate(true)
	var counts: Dictionary = g.staff_patient_practice_counts.duplicate(true)
	var familiarity: int = g.relation_for(Flow.ACTOR).familiarity
	g.set_story_flag("serika_imaging_present:%s" % g.day_number(),false)
	app.show_location("imaging")
	expect(g.active_character_event_id == Flow.ID, "Location entry independent of random presence")
	for i in range(1,40):
		var e = g.character_events[Flow.ID]
		var n: Dictionary = e.current()
		expect(n.id == "cb_%03d" % i, "Exact node order")
		expect(not g.can_save_progress() and g.snapshot().is_empty(), "No save during callback")
		var pages: Array = app.authored_dialogue_pages(n.text)
		expect("".join(pages) == str(n.text), "Pagination loses no text")
		for page in pages:
			await process_frame
			expect(app.current_dialogue_text() == str(page), "Actual localized page")
			var labels: Array = app.page.find_children("*","Label",true,false)
			expect(labels.any(func(l): return l.text == n.speaker_label), "Rendered speaker " + str(n.id))
			var art = app.page.get_node_or_null("CharacterPortrait")
			var expected_path: String = app.content.find_record("staff",Flow.ACTOR).visuals.portraits["white_coat/"+str(n.expression)]
			expect(art != null and art.texture != null and art.texture.resource_path == "res://"+expected_path, "Loaded exact Serika expression " + str(n.id))
			var button: Button = app.dialogue_default_button
			expect(button != null,"Continue button")
			if button: button.pressed.emit()
			await process_frame
		rendered += 1
	# cb040 is a control-only node and automatically returns to the location.
	await create_timer(0.2).timeout
	expect(g.character_event_done(Flow.ID) and g.active_character_event_id.is_empty(), "Control 040 settles and exits")
	expect(app.screen == "location", "Return to imaging room UI")
	expect(g.elapsed() == before + 15 and g.player_attributes() == attrs and g.relation_for(Flow.ACTOR).familiarity == familiarity and g.staff_patient_practice_counts == counts, "15 minutes; no stat/training rewards")
	expect(not Flow.eligible(g) and g.start_character_event(Flow.ID) == null, "One-time callback")
	roundtrip(g,true)
func run() -> void:
	app=load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/private/tmp/serika_staff_unused_%s.json" % OS.get_process_id()
	root.add_child(app);await process_frame;app.dialogue_auto_enabled=false
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Load " + locale);app.configure_game_content()
		var g=app.game
		g.meet_staff(Flow.ACTOR);g.relation_for(Flow.ACTOR).level=5;g.set_story_flag("staff_as_patient_program_authorized")
		expect(not g.staff_patient_unlocked(Flow.ACTOR),"Level alone without completed Lv5 milestone remains locked")
		dialogue_tests(locale);lifecycle_tests(g)
		if failures: print("SERIKA TEST STOP ",checks," checks / ",failures," failures");quit(1);return
		await play_callback(locale)
		if failures: print("SERIKA TEST STOP ",checks," checks / ",failures," failures");quit(1);return
	var report={"checks":checks,"failures":failures,"rendered_dialogue_nodes":rendered,"languages":["zh_CN","en"],"native":false}
	DirAccess.make_dir_recursive_absolute("res://docs/qa/serika_staff_patient")
	var f=FileAccess.open("res://docs/qa/serika_staff_patient/headless.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
	print("SERIKA STAFF PATIENT TEST ",JSON.stringify(report));quit(1 if failures else 0)
