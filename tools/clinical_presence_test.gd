extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const Encounter = preload("res://godot/systems/encounter_session.gd")
const Progression = preload("res://godot/systems/progression_config.gd")
const PreopView = preload("res://godot/ui/preop_view.gd")
const ClinicView = preload("res://godot/ui/clinic_view.gd")
const Store = preload("res://godot/systems/save_store.gd")
var checks := 0
var failures := 0
var app
var content
var han := RegEx.new()
var screenshots := 0
const QA := "res://docs/qa/clinical_presence_2026-10-27"

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func prep_fixture(surgery_id: String = "surgery_exploratory_laparotomy", variant: bool = false):
	var d: Dictionary = content.find_record("preops", "preop_sora").duplicate(true)
	d.surgery_id = surgery_id
	if variant:
		d.case_rare_variants = content.find_record("case_templates", "template_exploratory_laparotomy").rare_variants.duplicate(true)
	var p = Preop.new(d, content.collections.staff, content.collections.surgeries, content.collections.patients, [], false, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions)
	p.team = {"assistant_surgeon":"doc_aoi", "scrub_nurse":"nurse_yui", "circulating_nurse":"nurse_haru", "ward_nurse":"nurse_rin"}
	p.procedure_id = surgery_id
	p.procedure_name = str(p.current_surgery().name)
	p.initialize_procedure_state()
	return p

func act(p, id: String) -> void:
	expect(p.apply({"kind":"action", "id":id}), "Accepted " + id)

func check_badge(button: Button, delta: int, locale: String) -> void:
	expect(button != null, "Rendered button")
	if button == null:
		return
	if delta == 0:
		expect(not button.has_meta("presence_hint"), "Neutral option has no hint")
		return
	var clue: String = ("Assertive" if delta > 0 else "Gentle") if locale == "en" else ("强势" if delta > 0 else "温柔")
	clue += "+".repeat(3 if absi(delta) >= 5 else 2 if absi(delta) >= 2 else 1)
	expect(button.get_meta("presence_hint", "") == clue and button.text.contains(clue), "Visible correct strength: " + clue)
	expect(button.tooltip_text.contains("%+d" % delta) and button.tooltip_text.contains("±"), "Exact number and cap tooltip")
	var size := button.get_theme_font("font").get_multiline_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, button.get_theme_font_size("font_size"))
	var usable := button.size - button.get_theme_stylebox("normal").get_minimum_size()
	expect(size.x <= usable.x + 1 and size.y <= usable.y + 1, "Hint and text fit " + button.name)
	if locale == "en":
		expect(han.search(button.text + button.tooltip_text) == null, "English hint contains no Chinese")

func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QA))
	expect(root.get_texture().get_image().save_png(QA + "/" + name + ".png") == OK, "Screenshot " + name)
	screenshots += 1

func run() -> void:
	han.compile("[\\x{3400}-\\x{9fff}]")
	app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	content = app.content
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		app.game.reset()
		# Each actual outpatient option, including neutral procedural actions.
		for stage in content.find_record("encounters", "visit_sora").stages:
			var v = Encounter.new(content.find_record("encounters", "visit_sora"), false)
			v.stage_id = stage.id
			ClinicView.render(app, v)
			for a in v.ui_actions():
				check_badge(app.page.get_node_or_null("Action_" + str(a.id)), Progression.action_presence_delta(a), locale)
			if stage.id == "exam_undress_decision":
				await capture(locale + "_clinic")
		# Every scored authored clinic action executes once; saturation uses the new cap.
		var v = Encounter.new(content.find_record("encounters", "visit_sora"), false)
		for id in ["comfort", "gentle_full_undress", "abandon_full_undress", "limited_clothed_exam"]:
			v.stage_id = "reception" if id == "comfort" else "exam" if id == "limited_clothed_exam" else "exam_undress_decision"
			if id == "limited_clothed_exam":
				expect(v.apply("vitals"), "Required baseline before limited exam")
			expect(v.apply(id), "Clinic attitude applies " + id)
		expect(v.presence_raw == -4 and v.player_effects.presence == -3, "Clinic cap -3")
		v.stage_id = "exam_undress_decision"
		expect(v.apply("threaten_full_undress") and v.player_effects.presence == -3, "Raw net below cap")
		expect(v.apply("authoritative_full_undress") == false, "Cannot take second branch after exit")
		v.stage_id = "exam_undress_decision"
		expect(not v.apply("threaten_full_undress"), "Repeated choice rejected")
		# All live patient-interaction options run through the real event handler.
		var groups: Array = content.collections.patient_interactions.duplicate()
		for condition in content.collections.temporary_conditions:
			var row: Dictionary = condition.duplicate(true)
			row.prompt = condition.prompts["1"]
			groups.append(row)
		for group in groups:
			for a in group.actions:
				var p = prep_fixture()
				p.stage_id = "procedure_flow"
				p.flags.append("local_anesthesia")
				p.active_patient_interaction = group.duplicate(true)
				p.awaiting_patient_choice = true
				p.feedback = str(group.prompt)
				p.feedback_speaker = "patient"
				PreopView.render(app, p)
				check_badge(app.page.get_node_or_null("PatientInteraction_" + str(a.id)), int(a.presence_delta), locale)
				expect(p.apply({"kind":"patient_interaction_action", "id":a.id}), "Interaction accepted " + str(a.id))
				expect(p.player_effects.presence == int(a.presence_delta), "Actual delta " + str(a.id))
				expect(not p.apply({"kind":"patient_interaction_action", "id":a.id}), "No double award " + str(a.id))
			# One representative panel with four choices for visual inspection.
			if group.id == "nausea":
				var p = prep_fixture()
				p.stage_id = "procedure_flow"; p.flags.append("local_anesthesia")
				p.active_patient_interaction = group; p.awaiting_patient_choice = true
				PreopView.render(app, p)
				await capture(locale + "_temporary_condition")
		# Scored authored and runtime preop actions: badges and actual phase routing.
		var catalog = prep_fixture()
		for st in catalog.stages.values():
			for a in st.actions:
				var delta := Progression.action_presence_delta(a)
				if delta == 0:
					continue
				var one = prep_fixture()
				one.stage_id = st.id
				for flag in a.requires + a.get("show_if_flags", []):
					if not one.flags.has(str(flag)):
						one.flags.append(str(flag))
				PreopView.render(app, one)
				check_badge(app.page.get_node_or_null("PreopAction_" + str(a.id)), delta, locale)
				var phase: String = one.presence_phase_for_stage()
				act(one, str(a.id))
				expect(one.player_effects.presence == clampi(delta, -int(Progression.PRESENCE_PHASE_CLAMPS[phase]), int(Progression.PRESENCE_PHASE_CLAMPS[phase])), "Scored preop action " + str(a.id))
		# Runtime-only reactions to loss of dignity/cooperation use the same hints.
		for kind in ["dignity_break", "cooperation_disruption", "dignity_intrusion"]:
			for index in range(2):
				var one = prep_fixture()
				one.stage_id = "procedure_flow"
				one.dignity = 5 if kind == "dignity_break" else 30 if kind == "dignity_intrusion" else 100
				one.fear = 0; one.pain = 0
				one.cooperation_base = 0 if kind == "cooperation_disruption" else 100
				one.resolved_random_choices["patient_intrusion:test:" + kind] = 0
				expect(one.resolve_patient_intrusion_for_stage({"id":"test", "patient_cues":["exposure", "traction"]}), "Runtime intrusion " + kind)
				var a: Dictionary = one.active_patient_interaction.actions[index]
				PreopView.render(app, one)
				check_badge(app.page.get_node_or_null("PatientInteraction_" + str(a.id)), int(a.presence_delta), locale)
				expect(one.apply({"kind":"patient_interaction_action", "id":a.id}) and one.player_effects.presence == int(a.presence_delta), "Intrusion scores " + str(a.id))
		# Both execution paths apply selected care once, never on toggling.
		for manual in [false, true]:
			var p = prep_fixture()
			p.stage_id = "preparation"
			for id in ["explain_again", "family_call"]:
				expect(p.apply({"kind":"toggle", "id":id}), "Toggle preparation")
			expect(p.player_effects.presence == 0, "Selecting optional care does not score")
			PreopView.render(app, p)
			for item in p.definition.preparations:
				check_badge(app.page.get_node_or_null("Preparation_" + str(item.id)), -1, locale)
			if manual:
				p.stage_id = "ward_finish"
				# Locate the actual manual completion action, independent of stage ID.
				for st in p.stages.values():
					for a in st.actions:
						if a.execute_preparation and a.id != "perform_preparation":
							p.stage_id = st.id
							for flag in a.requires:
								p.flags.append(str(flag))
							act(p, str(a.id))
			else:
				act(p, "perform_preparation")
			expect(p.player_effects.presence == -2, "Executed care respects preop cap")
		# Score no anesthesia only at final start, once; no extra award on incision.
		var p = prep_fixture()
		p.stage_id = "ready"
		act(p, "choose_none")
		expect(p.player_effects.presence == 0, "Selecting none alone scores zero")
		act(p, "reconsider_anesthesia")
		expect(p.player_effects.presence == -1, "Reconsider is gentle")
		p = prep_fixture()
		p.stage_id = "surgery_start_none_confirmed"
		p.flags.assign(["no_anesthesia_confirmed", "incision_marked"])
		PreopView.render(app, p)
		check_badge(app.page.get_node_or_null("PreopAction_start_none_surgery"), 5, locale)
		await capture(locale + "_no_anesthesia")
		act(p, "start_none_surgery")
		expect(p.presence_or_raw == 5 and p.presence_preop_raw == 0 and p.player_effects.presence == 5, "No-anesthesia +5 in OR")
		expect(not p.apply({"kind":"action", "id":"start_none_surgery"}), "Start cannot be repeated")
		p.stage_id = "incision_ready"
		act(p, "incise_none")
		expect(p.player_effects.presence == 5, "Incision does not award a second +5")
		expect(p.apply_presence_delta(2, "or") == 0 and p.player_effects.presence == 5, "OR +5 cap")
		p.apply_presence_delta(-4, "or")
		expect(p.player_effects.presence == 3, "Opposing care offsets raw total")
		p.apply_presence_delta(-99, "or")
		expect(p.player_effects.presence == -5, "OR -5 cap")
		p.apply_presence_delta(99, "preop")
		expect(p.player_effects.presence == -3, "Preop +2 independent from OR")
		await test_variant(locale)
	app.queue_free()
	await process_frame
	print("CLINICAL PRESENCE: %s checks; %s failures; %s screenshots" % [checks, failures, screenshots])
	quit(1 if failures else 0)

func test_variant(locale: String) -> void:
	var original: Dictionary = content.find_record("case_templates", "template_exploratory_laparotomy").rare_variants[0]
	expect(is_equal_approx(float(original.probability), 0.08), "Production probability remains 8%")
	var sampler = prep_fixture("surgery_exploratory_laparotomy", true)
	var rng := RandomNumberGenerator.new(); rng.seed = 20261027
	var expected_rng := RandomNumberGenerator.new(); expected_rng.seed = 20261027
	var hits := 0
	for trial in range(1000):
		sampler.case_review_checked = false; sampler.stage_id = sampler.definition.start
		var expected := expected_rng.randf() < 0.08
		sampler.begin_case_review(rng)
		expect(sampler.stage_id.begins_with("case_review_") == expected, "Probability threshold " + str(trial))
		hits += int(expected)
		var state := rng.state
		sampler.begin_case_review(rng)
		expect(rng.state == state, "No repeated draw")
	expect(hits > 40 and hits < 120, "Seeded sample has both rare and ordinary routes")
	for option in original.decision_options:
		if option.id not in original.runtime_options:
			continue
		var p = prep_fixture("surgery_exploratory_laparotomy", true)
		p.definition.case_rare_variants[0].probability = 1.0 # Isolated fixture; production remains 8%.
		p.begin_case_review()
		expect(p.current().prompt == original.reveal_text, "Exact reveal")
		expect(p.current().speaker == "narrator", "Reveal belongs to narrator")
		act(p, p.current().actions[0].id)
		var quote: String = p.current().prompt
		expect(p.current().speaker == "patient", "Objection belongs to patient")
		act(p, p.current().actions[0].id)
		expect((quote + p.current().prompt).replace(" ", "") == str(original.exploratory_surgery_reaction).replace(" ", ""), "Original objection and narration preserved")
		expect(p.current().actions.size() == 2, "Only two authorized choices")
		PreopView.render(app, p)
		for choice in p.current().actions:
			check_badge(app.page.get_node_or_null("PreopAction_" + str(choice.id)), int(choice.presence_delta), locale)
		if option.id == "frighten_with_worst_case":
			await capture(locale + "_rare_choice")
		var fear: int = p.fear; var dignity: int = p.dignity
		var choice_id: String = ""
		for choice in p.current().actions:
			if choice.label == option.label:
				choice_id = choice.id
		act(p, choice_id)
		expect(p.feedback == option.dialogue and p.feedback_speaker == "player", "Exact doctor response")
		expect(p.fear == mini(100, fear + int(option.effects.fear)) and p.dignity == dignity + int(option.effects.dignity), "Exact variant patient effects")
		expect(p.player_effects.presence == int(option.effects.presence), "Exact variant presence, no trust")
		PreopView.render(app, p)
		expect(app.page.get_node("PreopRecordSpeaker").text == app.protagonist_name(), "Doctor's nameplate")
		var snapshot: Dictionary = p.snapshot_state() # Memory only; never written as a save.
		var restored = prep_fixture("surgery_exploratory_laparotomy", true)
		expect(restored.restore_state(snapshot), "Memory state restoration")
		var before: int = restored.player_effects.presence
		restored.begin_case_review()
		expect(restored.stage_id == p.stage_id and restored.player_effects.presence == before, "No reroll/reward on refresh")
		var other_content = Loader.new()
		expect(other_content.load_all("en" if locale == "zh_CN" else "zh_CN"), "Other locale loads")
		var other_definition: Dictionary = other_content.find_record("preops", "preop_sora").duplicate(true)
		other_definition.case_rare_variants = other_content.find_record("case_templates", "template_exploratory_laparotomy").rare_variants
		var other = Preop.new(other_definition, other_content.collections.staff, other_content.collections.surgeries, other_content.collections.patients)
		expect(other.restore_state(snapshot), "Live language switch restores review")
		expect(other.feedback.is_empty() and other.current().prompt != p.current().prompt and other.player_effects.presence == p.player_effects.presence, "Language switch translates without changing score")
		act(p, p.current().actions[0].id)
		expect(p.current().prompt == option.outcome and p.current().speaker == "narrator", "Exact outcome")
		act(p, p.current().actions[0].id)
		expect(p.stage_id == p.definition.start, "Returns to normal preparation")
		finish_review_operation(p, option.id == "frighten_with_worst_case")
		if locale == "en":
			for st in p.stages.values():
				if st.kind == "case_review":
					expect(han.search(st.prompt + st.title) == null, "English case review")
	# Natural GameState entry, then isolated boundary facts and script-independent restore.
	var g = app.game
	g.reset()
	g.patient_cases.patient_sora = "template_exploratory_laparotomy"
	g.rebuild_patient_content(g.patient_cases)
	g.preop_definitions.preop_sora.case_rare_variants[0].probability = 1.0
	var v = g.open_visit("visit_sora")
	for id in ["comfort", "basic_history", "to_exam", "vitals", "limited_clothed_exam", "blood", "imaging", "to_diagnosis", "diagnose_appendix", "explain", "admit"]:
		expect(g.apply_clinic_action(id), "Natural clinic path " + id)
	var p = g.open_preop("preop_sora")
	expect(p != null and p.stage_id.begins_with("case_review_"), "Natural admitted case enters variant")
	expect(not g.can_save_progress() and g.snapshot().is_empty(), "No save during variant")
	# Finish authored review, then settle an isolated test operation result.
	for index in range(5):
		act(p, p.current().actions[-1].id)
	expect(p.stage_id == p.definition.start, "Natural variant route finishes")
	p.surgery_success = true; p.stage_id = p.definition.completion
	p.procedure_id = "surgery_exploratory_laparotomy"; p.minutes = 121
	g.active_preop_id = ""; g.active_id = ""; g.active_mode = "encounter"
	var before: Dictionary = g.player_attributes()
	var elapsed: int = g.elapsed()
	var facts: Dictionary = g.snapshot()
	expect(not facts.is_empty(), "Settled hospital boundary is savable")
	var serialized := JSON.stringify(facts)
	for forbidden in ["case_review_", "frighten_with_worst_case", "presence_or_raw", "case_review_checked", "stage_id", "selected_preparations"]:
		expect(not serialized.contains(forbidden), "No inner state in save: " + forbidden)
	# Remove live prose and choice definitions: already-settled facts still restore.
	g.case_templates.template_exploratory_laparotomy.rare_variants = []
	expect(g.restore(JSON.parse_string(serialized)), "Restore without variant nodes")
	expect(g.player_attributes() == before and g.elapsed() == elapsed, "No recalculation/reward/time change")
	var store = Store.new()
	store.path = "/private/tmp/hoshimi_clinical_presence_" + locale + ".json"
	expect(store.write_slot(g), "Write isolated boundary file")
	expect(store.read_slot(g), "Read isolated boundary file")
	expect(g.player_attributes() == before and g.elapsed() == elapsed, "Roundtrip preserves settled results")

func finish_review_operation(p, assertive: bool) -> void:
	# Continue both review branches through the actual preparation and operation.
	p.procedure_id = ""
	act(p, "brief_plan" if assertive else "explain_plan")
	if not assertive:
		act(p, "appropriate_answer")
	for id in ["confirm_team", "perform_preparation", "to_changing", "change_scrubs", "scrub_hands", "enter_room", "team_check", "confirm_assistant_role", "confirm_scrub_role", "confirm_circulating_role"]:
		act(p, id)
	expect(p.apply({"kind":"procedure", "id":"surgery_exploratory_laparotomy"}), "Select actual exploratory operation")
	expect(p.apply({"kind":"or_table_palpation_complete"}), "Complete pre-anesthesia examination")
	act(p, "choose_none" if assertive else "choose_local")
	if assertive:
		act(p, "insist_without_anesthesia")
	else:
		expect(p.apply({"kind":"anesthesia_sensory_test_complete"}), "Complete sensory check")
	for id in ["operative_positioning", "ack_positioning", "urinary_catheterization", "ack_catheterization", "skin_disinfection", "ack_disinfection", "incision_marking", "ack_marking_none" if assertive else "ack_marking_local", "start_none_surgery" if assertive else "start_local_surgery", "request_scalpel", "assistant_stabilize", "incise_none" if assertive else "incise_local"]:
		act(p, id)
	var guard := 0
	while p.current().kind == "surgery_flow" and guard < 200:
		guard += 1
		if p.awaiting_patient_choice:
			var actions: Array = p.active_patient_interaction.actions.duplicate()
			actions.sort_custom(func(a, b): return Progression.action_presence_delta(a) > Progression.action_presence_delta(b) if assertive else Progression.action_presence_delta(a) < Progression.action_presence_delta(b))
			expect(p.apply({"kind":"patient_interaction_action", "id":actions[0].id}), "Actual OR patient choice")
		elif p.awaiting_patient_acknowledgement:
			expect(p.apply({"kind":"patient_acknowledge"}), "Actual patient acknowledgement")
		elif p.awaiting_flow_acknowledgement:
			expect(p.apply({"kind":"flow_acknowledge"}), "Actual team acknowledgement")
		else:
			var step: Dictionary = p.surgery_flow_step()
			var choices: Array = step.options.filter(func(a): return bool(a.get("correct", true)))
			expect(not choices.is_empty(), "Correct technical choice available")
			if choices.is_empty():
				break
			expect(p.apply({"kind":"surgery_step", "id":choices[0].id}), "Actual technical step")
	expect(guard < 200 and p.current().kind == "surgery_execute", "Variant continues through complete operation")
	act(p, "execute_confirmed_procedure")
	expect(p.surgery_success, "Review branch reaches surgical result")
	if assertive:
		expect(p.player_effects.presence == 7, "Strong review/preop +2 and unanaesthetized OR +5")
	else:
		expect(p.presence_or_raw <= 0 and p.player_effects.presence >= -7, "Caring operation respects cumulative limits")
