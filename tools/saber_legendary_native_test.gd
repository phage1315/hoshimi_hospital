extends "res://tools/saber_legendary_test.gd"
var app: Control
var clicks := 0
var shots := 0
var output := "res://docs/qa/saber_legendary_2026-11-18/native_prod/"

func view() -> Control:
	return app.page.get_node("AdvancedReferralView")

func click(id: String) -> void:
	var b: Button = app.page.find_child(id, true, false)
	expect(b != null and b.is_visible_in_tree() and not b.disabled, "GUI button available: " + id)
	if b == null or not b.is_visible_in_tree() or b.disabled: return
	var scroll := b.get_parent()
	while scroll != null:
		if scroll is ScrollContainer: scroll.ensure_control_visible(b)
		scroll = scroll.get_parent()
	await process_frame
	var point := b.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.position = point
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = pressed
		root.push_input(e, true)
	clicks += 1
	await process_frame
	await process_frame

func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	expect(root.get_texture().get_image().save_png(ProjectSettings.globalize_path(output + name + ".png")) == OK, "Capture " + name)
	shots += 1

func story(locale: String, branch_pref: int) -> void:
	var c: RefCounted = app.advanced_controller
	var phase: String = c.story_phase
	var guard := 0
	var snap_ids := ["A02", "A25", "B08", "C26", "D03", "D12", "D22", "E03", "F05", "F11", "F13", "G03", "G08", "G29", "G33", "H30", "I14"]
	while not c.story_phase.is_empty() and guard < 220:
		var idx: int = c.story_index
		var line: Dictionary = c.story_content[phase].lines[idx]
		var lid := str(line.get("id", ""))
		var card: Control = app.page.get_node("AdvancedCast")
		var expected_text: String = str(line.text_en if locale == "en" else line.text)
		expect(str(card.get_meta("source_text")) == expected_text, "Exact story line %s:%s" % [phase, lid])
		if line.speaker == "patient":
			expect(card.get_node("AdvancedActorPortrait").texture != null, "Patient portrait loaded on " + lid)
		if lid == "F11":
			expect(str(card.get_meta("portrait_path")).contains("scrubs_masked"), "F11 Artoria wears cap & mask scrubs")
		if lid in snap_ids:
			await capture("%s_%s_%s" % [locale, phase, lid])
		var choices: Array = line.get("choices", [])
		if not choices.is_empty():
			var c_idx := mini(branch_pref, choices.size() - 1)
			await click("story_choice_" + str(c_idx))
			expect(c.story_index != idx, "Choice click advances to branch on " + lid)
		else:
			await click("story_next")
			expect(c.story_index != idx or c.story_phase.is_empty(), "Story next advances on " + lid)
		guard += 1
	expect(c.story_phase.is_empty(), "Chapter complete: " + phase)

func morning(g: RefCounted, day: int) -> void:
	g.set_test_time(day, 540)
	g.story_time_advance_minutes += (day - 1) * g.SHIFT_MINUTES - g.elapsed()
	expect(g.day_number() == day and g.current_absolute_clock() == 540, "Exact booked morning")

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output = arg.trim_prefix("--out=").trim_suffix("/") + "/"
	expect(DisplayServer.get_name() != "headless", "Native Metal display required")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/saber-native-unused-%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	for locale_idx in range(2):
		var locale: String = ["zh_CN", "en"][locale_idx]
		var branch_pref: int = 0 if locale == "zh_CN" else 2
		app.content.load_all(locale)
		var g := fixture()
		app.game = g
		g.set_test_time(15, 540)
		g.surgery_xp = g.surgery_xp_for_level(100)
		var lv5_ev: String = g.relationship_rank_slot("doc_artoria", 5).event_id
		g.relation_for("doc_artoria").level = 5
		g.relation_for("doc_artoria").rank_history.append(lv5_ev)
		g._complete_character_event_for_test(lv5_ev, 2)
		g.advanced_referral_facts = Facts.fresh()
		g.advanced_referral_facts.activated_day = 1
		for row in Rules.manifest().slice(0, 5):
			g.advanced_referral_facts.procedures[row.procedure_id] = "CLEARED"
			g.advanced_referral_facts.clear_days[row.procedure_id] = 1
		app.advanced_controller = null
		app.show_advanced_referral(false)
		await process_frame
		expect(Legendary.ready(ID), "Production Saber legendary resources ready")
		await capture(locale + "_board")
		await click("case_advanced_first_" + ID)
		var c: RefCounted = app.advanced_controller
		await story(locale, branch_pref)

		view().selected = saber_team()
		view().render()
		await process_frame
		expect(view().selected.first_assistant == "doc_artoria", "Saber forced as first assistant")
		await capture(locale + "_team")
		await click("accept")
		expect(not c.state().appointment.is_empty(), "Production booking accepted")

		morning(g, int(c.state().appointment.operation_day))
		view().render()
		await process_frame
		await click("start")
		expect(c.session != null, "Production Day 2 session started")
		if c.session == null:
			quit(1)
			return
		# Dismiss day transition overlay cleanly
		if not c.day_transition.is_empty():
			view().finish_day_transition()
			await process_frame
		await story(locale, branch_pref)
		await capture(locale + "_anesthesia_splash")
		await click("AnesthesiaSplashContinue")
		await capture(locale + "_patient_ready")
		await click("begin_timeout")
		await capture(locale + "_team_confirm")
		for _i in range(7):
			await click("confirm_member")

		var session: RefCounted = c.session
		session.rng.seed = 20261118
		var captured: Dictionary = {}
		var saber_line_captured: Dictionary = {}
		for _guard in range(420):
			if session.finished: break
			var step: Dictionary = session.current()
			if not captured.has(step.id):
				if step.id in ["WH01", "WH02", "WH05", "WH12", "WH17", "WH18"]:
					await capture(locale + "_" + str(step.id))
				captured[step.id] = true
			var cur_dlg: Dictionary = session.operative_dialogue.current(session) if session.operative_dialogue != null else {}
			if str(cur_dlg.get("id", "")).contains("_S_PRE") and not saber_line_captured.has(step.id):
				if step.id in ["WH01", "WH11"]:
					await capture(locale + "_" + str(step.id) + "_saber_pre")
				saber_line_captured[step.id] = true
			var next_btn: Button = app.page.find_child("dialogue_next", true, false)
			if next_btn != null and next_btn.is_visible_in_tree() and not next_btn.disabled:
				await click("dialogue_next")
			elif session.in_crisis():
				await click("pause_and_stabilize")
			elif session.pending_rescue:
				if session.eligible(1): await click("rescue_1")
				elif session.eligible(2): await click("rescue_2")
				else: await click("correct")
			elif session.awaiting_ack:
				await click("continue")
			elif step.kind == "P":
				await click("operate")
			elif step.kind == "S":
				var opt_pick := 0 if step.id in ["WH05", "WH10"] else 1
				await click("strategy_" + str(step.options[opt_pick].id))
			else:
				await click("continue")

		expect(session.finished and session.success, "GUI 18-stage operation succeeds")
		await capture(locale + "_terminal")
		await click("finish")

		morning(g, int(c.state().appointment.review_day))
		view().render()
		await process_frame
		await click("settle")
		if not c.day_transition.is_empty():
			view().finish_day_transition()
			await process_frame
		expect(c.state().procedures.get(ID, "") == "CLEARED" and c.story_phase == "day3", "Settled CLEARED before Day 3 VN")
		await story(locale, branch_pref)
		await capture(locale + "_settled")
		expect(c.state().completed.filter(func(r): return r.procedure_id == ID).size() == 1, "Idempotent single settlement")

	print("SABER NATIVE: %s checks; %s failures; %s GUI clicks; %s screenshots" % [checks, failures, clicks, shots])
	quit(1 if failures else 0)
