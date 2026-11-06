extends "res://tools/advanced_surgery_test.gd"
const Staff = preload("res://godot/systems/advanced_staff_patient.gd")
const Assets = preload("res://godot/systems/advanced_staff_patient_assets.gd")
const Present = preload("res://godot/systems/advanced_presentation.gd")
const FreeRegistry = preload("res://godot/systems/free_h_registry.gd")

const TestSetup = preload("res://godot/systems/advanced_staff_patient_test_setup.gd")

func fixture(g, actor: String) -> void:
	TestSetup.fixture(g, actor)

func team(c) -> Dictionary:
	return TestSetup.team(c)

func locked(g, phase: String) -> void:
	expect(not g.can_save_progress(), "No save: " + phase)
	var mode: String = g.active_mode
	g.active_mode = "encounter"
	expect(g.snapshot().is_empty(), "Even forced safe UI cannot persist episode: " + phase)
	g.active_mode = mode

func walk(c) -> void:
	for i in range(180):
		if c.story_phase.is_empty(): break
		locked(c.game, c.story_phase)
		var phase: String = c.story_phase
		var row: Dictionary = c.story_content[phase].lines[c.story_index]
		expect(not str(row.text).is_empty() and not str(row.text_en).is_empty(), "Bilingual story row " + phase)
		c.advance_story()

func episode(actor: String, prior: int, skip: bool, forced_failure: bool) -> void:
	var g = new_game()
	fixture(g, actor)
	var c = Staff.new(g, actor)
	expect(c.eligible(), actor + " eligible")
	expect(c.board().is_empty(), "Uncleared procedures excluded")
	var procedure := "surgery_open_whipple"
	g.advanced_referral_facts.procedures[procedure] = "CLEARED"
	if prior >= 0: g.advanced_staff_patient_facts = {"actors": {actor: {"night_seen": true, "procedures": {procedure: {"successes": prior, "attempts": prior, "last_day": 1, "last_success": true, "last_minutes": 600}}}}}
	var offers: Array = c.board()
	expect(offers.size() == 1, "Only cleared regular procedure offered")
	if offers.is_empty(): return
	var selected := team(c)
	expect(actor not in selected.values(), "Patient excluded from all roles")
	expect(c.accept(offers[0], selected), "Accept valid episode: " + c.error + ":" + g.last_error)
	if not c.episode_active: return
	var expected_scale := 1.0 if prior < 1 else 0.5 if prior == 1 else 0.0
	expect(c.multiplier() == expected_scale, "100 / 50 / 0 actor-procedure scale")
	walk(c)
	expect(c.night_choice, "Separate watch/skip night choice")
	locked(g, "night choice")
	c.choose_night(not skip)
	if not skip:
		walk(c)
		expect(c.transition_pending, "Blackout only after dark dialogue")
		locked(g, "blackout")
		c.complete_night_transition()
		walk(c)
	expect(c.session != null, "Next day actual shared runner starts: " + c.error)
	if c.session == null: return
	locked(g, "operation")
	var d: Dictionary = c.session.definition
	# Real runner with deterministic strong team for the success branch; no player state altered.
	c.session = Session.new(d, Model.fixtures(d.id)[0], 8, [], {}, true)
	drive(c.session)
	if forced_failure: c.session.finished = true; c.session.success = false
	var success: bool = c.session.success
	var xp: int = g.surgery_xp
	var rep: int = g.player_attributes().reputation
	var ordinary: Dictionary = g.advanced_referral_facts.procedures.duplicate(true)
	expect(c.finish_operation(), "Operation hands result to Day 3")
	expect(c.story_phase == ("success" if success else "failure"), "Mutually exclusive result chapter")
	walk(c)
	expect(not c.episode_active and g.active_advanced_staff_patient.is_empty(), "Day 3 unlocks runtime patient")
	expect(g.player_attributes().reputation == rep and g.advanced_referral_facts.procedures == ordinary, "No reputation or ordinary unlock changes")
	expect((g.surgery_xp > xp) == (success and expected_scale > 0), "Rewards only successful nonzero multiplier")
	var fact: Dictionary = g.advanced_staff_patient_facts.actors[actor].procedures[procedure]
	expect(fact.successes == maxi(prior,0)+(1 if success else 0), "Success count only after success")
	var rewards: int = g.surgery_xp
	expect(not c.settle() and g.surgery_xp == rewards, "Settlement idempotent")
	g.active_mode = "encounter"
	var saved: Dictionary = g.snapshot()
	expect(not saved.is_empty(), "Save available only back at safe boundary")
	no_inner(saved.get("advanced_staff_patient_facts", {}))
	var time: int = g.elapsed()
	c.texts.clear() # Old saves must not depend on current script nodes.
	expect(g.restore(saved), "Safe-boundary restore: " + g.last_error)
	expect(g.elapsed() == time and g.surgery_xp == rewards and g.advanced_staff_patient_facts.actors[actor].procedures[procedure] == fact, "Time, rewards and facts stable after script edit")
	print("EPISODE ", actor, " prior=",prior," skip=",skip," success=",success," xp=",rewards-xp)

func run() -> void:
	# Any newly registered Lv5 patient must satisfy the same release requirements.
	expect(Present.format_story("The procedure is {procedure_name}.", "Whipple") == "The procedure is Whipple.", "English procedure placeholder resolves")
	var readiness_game = new_game()
	var readiness = preload("res://tools/staff_patient_lv5_readiness.gd")
	var story_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/staff_patient/stories.json"))
	var pose_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/staff_patient/assets.json"))
	for actor in readiness.Registry.profiles():
		var result: Dictionary = readiness.inspect_actor(readiness_game, actor, story_data, pose_data)
		expect(result.ready, "Lv5 release readiness " + actor + ": " + str(result.missing))
	for actor in preload("res://godot/systems/staff_patient_registry.gd").profiles():
		for prior in [-1, 0, 1, 2]: episode(actor, prior, prior%2==0, false)
		episode(actor, -1, true, true)
	var g = new_game()
	fixture(g, "doc_serika")
	var c = Staff.new(g, "doc_serika")
	g.advanced_referral_facts.procedures["surgery_open_whipple"] = "CLEARED"
	var selected := team(c)
	c.local_facts.appointment = {"case": c.board()[0]}
	g.advanced_staff_patient_facts = {"version":1,"actors":{"doc_sayaka":{"night_seen":true,"procedures":{"surgery_open_whipple":{"successes":2,"attempts":2,"last_day":1,"last_success":true,"last_minutes":600}}}}}
	expect(c.multiplier()==1.0,"Another actor's success count never reduces this actor's XP")
	g.advanced_staff_patient_facts.actors.doc_serika = g.advanced_staff_patient_facts.actors.doc_sayaka.duplicate(true)
	c.local_facts.appointment.case.procedure_id = "surgery_pelvic_sidewall_iliac_reconstruction"
	expect(c.multiplier()==1.0,"Another procedure's successes never reduce new procedure XP")
	c.local_facts.appointment = {}
	g.advanced_staff_patient_facts = Staff.StaffFacts.fresh()
	var invalid = Staff.StaffFacts.fresh()
	invalid["story_index"] = 3
	expect(not Staff.StaffFacts.valid(invalid),"Persisted inner state rejected")
	g.free_h_booking = {"actor_id": "doc_sayaka", "workday": c.day()}
	expect(not c.accept(c.board()[0], selected) and not g.free_h_booking.is_empty(), "Other booking untouched without explicit replacement")
	c.replacement_actor = "doc_sayaka"
	expect(c.accept(c.board()[0], selected) and g.free_h_booking.is_empty(), "Confirmed replacement consumes booking")
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/staff_patient/assets.json"))
	for actor in manifest:
		for pose in manifest[actor]:
			var path: String = manifest[actor][pose].path
			expect(ResourceLoader.exists("res://"+path), "Imported pose: " + actor + ":" + pose)
	print("ADVANCED STAFF PATIENT: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
