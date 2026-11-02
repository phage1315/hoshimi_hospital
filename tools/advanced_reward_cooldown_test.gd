extends "res://tools/advanced_surgery_test.gd"
## Focused production settlement and actual localized cooldown UI regression.
## Synthetic completed outcomes exercise settlement only; no player saves touched.

func settlement_probe(rep: int, expected: int, success: bool, replay: bool, sandbox: bool) -> void:
	var g := new_game()
	g.surgery_xp = g.surgery_xp_for_level(88)
	g.archived_player_effects.reputation = rep
	g.set_test_time(17, 540)
	var c := Referral.new(g, sandbox)
	if sandbox: c.demo_day = 17
	var selected := {}
	for person in g.staff: g.relation_for(person.id).met = true
	for role in Referral.ROLES:
		for person in c.candidates(role, 16):
			if person.id not in selected.values():
				selected[role] = person.id
				break
	var d: Dictionary = Model.catalog()[0]
	var s := c.state()
	if replay: s.procedures[d.id] = "CLEARED"
	s.appointment = {"case": {"id": "reward_probe", "procedure_id": d.id, "patient_id": "patient_yamauchi_sakura", "replay": replay}, "team": selected, "intake_day": 15, "operation_day": 16, "review_day": 17, "intake_minutes": 60}
	s.outcome = {"case_id": "reward_probe", "success": success, "operation_day": 16, "minutes": 480}
	var xp: int = g.surgery_xp
	var leadership: float = g.leadership_xp
	var training: Dictionary = g.staff_training_credits.duplicate(true)
	var count: int = g.completed_surgeries_total
	expect(c.settle(), "Completed outcome settles")
	var r: Dictionary = c.last_summary
	expect(int(r.reputation) == expected and int(g.player_attributes().reputation) == rep + expected, "Reputation base / soft / hard cap")
	var rewarded := success and not sandbox
	expect((g.surgery_xp > xp) == rewarded and int(r.surgery_xp) == g.surgery_xp - xp, "Actual Surgery XP equals ledger")
	expect((g.leadership_xp > leadership) == rewarded and is_equal_approx(float(r.leadership_xp), g.leadership_xp - leadership), "Actual Leadership XP equals ledger")
	expect(g.completed_surgeries_total == count + (1 if rewarded else 0), "Completed surgery count once")
	expect((g.staff_training_credits != training) == rewarded, "Actual staff training only for production success")
	if replay: expect(s.procedures[d.id] == "CLEARED", "Replay failure preserves first clearance")
	var after := [g.surgery_xp, g.leadership_xp, g.player_attributes(), g.staff_training_credits.duplicate(true), g.completed_surgeries_total, s.duplicate(true)]
	expect(not c.settle(), "Duplicate settlement rejected")
	expect(after == [g.surgery_xp, g.leadership_xp, g.player_attributes(), g.staff_training_credits, g.completed_surgeries_total, s], "Duplicate settlement has no rewards or state mutation")
	if not sandbox:
		g.active_mode = "encounter"
		var saved: Dictionary = g.snapshot()
		expect(not saved.is_empty() and g.restore(saved), "Settled rewards survive safe-boundary save/load")
		expect(g.surgery_xp == after[0] and g.leadership_xp == after[1] and g.player_attributes() == after[2], "Load never reapplies rewards")
	print("REWARD_PROBE ", JSON.stringify({"reputation_before": rep, "success": success, "replay": replay, "sandbox": sandbox, "awards": {"surgery_xp": r.surgery_xp, "leadership_xp": r.leadership_xp, "reputation": r.reputation}}))

func run() -> void:
	for pair in [[300, 40], [480, 20], [590, 10], [600, 0]]:
		settlement_probe(pair[0], pair[1], true, false, false)
	settlement_probe(300, 40, true, true, false)
	settlement_probe(300, 0, false, true, false)
	settlement_probe(300, 0, false, false, false)
	settlement_probe(300, 0, true, false, true)
	var app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/tmp/advanced_reward_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		app.content.load_all(locale)
		app.configure_game_content()
		app.advanced_controller = null
		app.show_advanced_referral(true)
		var c = app.advanced_controller
		c.state().cooldowns = {"doc_emiko": 16, "doc_artoria": 16}
		var view = app.page.get_node("AdvancedReferralView")
		view.render()
		await process_frame
		for id in c.state().cooldowns:
			var expected_text: String = view.tr_key("cooldown") % [view.actor_name(id), 16]
			var found := false
			for child in view.body.get_children():
				if child is Label and child.text == expected_text: found = true
			expect(found and id not in expected_text, "Cooldown displays localized name in sandbox: " + locale + ":" + id)
	app.queue_free()
	await process_frame
	print("ADVANCED REWARD / COOLDOWN: %s checks; %s failures" % [checks, failures])
	quit(1 if failures else 0)
