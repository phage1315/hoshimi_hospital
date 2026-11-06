extends "res://tools/save_recovery_verify.gd"
const Preop = preload("res://godot/systems/preop_session.gd")
const Advanced = preload("res://godot/systems/advanced_referral.gd")

func run() -> void:
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Load " + locale)
		var game = new_game()
		for actor in ["nurse_ishigami", "nurse_haru", "nurse_rin", "nurse_yui", "doc_aoi"]:
			game.meet_staff(actor)
		game.relation_for("nurse_ishigami").level = 5
		expect(game.staff_is_met("nurse_ishigami"), "Manager still known for story and presence")
		expect(not game.staff_can_join_surgery_team("nurse_ishigami"), "Manager never enters selectable team even at Lv5")
		expect("nurse_ishigami" not in game.known_staff_ids(), "Manager absent from team whitelist")
		expect(game.staff_can_join_surgery_team("nurse_haru"), "Frontline nurse remains selectable at Lv0")
		var definition: Dictionary = content.find_record("preops", "preop_sora")
		for restricted in [true, false]:
			# Deliberately stale whitelist: qualification must enforce the flag itself.
			var known: Array[String] = ["nurse_ishigami", "nurse_haru", "nurse_rin", "nurse_yui", "doc_aoi"]
			var prep = Preop.new(definition, game.staff, content.collections.surgeries, content.collections.patients, known, restricted)
			var roles: Array = definition.roles.duplicate(true)
			roles.append(definition.ward_role)
			for role in roles:
				expect(not prep.qualified("nurse_ishigami", role), "Manager excluded from " + str(role.id))
				for person in prep.candidates(str(role.id)):
					expect(person.id != "nurse_ishigami", "Candidate list excludes manager")
			prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin", "ward_nurse": "nurse_yui"}
			expect(prep.team_ready() and prep.sweep_team_ready(), "Valid manual and sweep team accepted")
			for role in roles:
				var before: Dictionary = prep.team.duplicate()
				prep.team[role.id] = "nurse_ishigami"
				expect(not prep.sweep_team_ready(), "Injected manager cannot pass sweep validation")
				if role.id != definition.ward_role.id:
					expect(not prep.team_ready(), "Injected manager cannot pass operation validation")
				prep.team = before
		var controller = Advanced.new(game)
		for role in Advanced.ROLES:
			for person in controller.candidates(role, game.day_number()):
				expect(person.id != "nurse_ishigami", "Advanced role still excludes manager")
	print("Non-frontline teams: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
