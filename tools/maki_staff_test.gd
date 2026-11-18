extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const Event = preload("res://godot/systems/character_event_session.gd")
const Advanced = preload("res://godot/systems/advanced_referral.gd")
var checks := 0
var failures := 0
func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func contains(rows: Array) -> bool:
	return rows.any(func(row): return row.id == "doc_maki")
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	for locale in ["zh_CN", "en"]:
		var content = Loader.new()
		expect(content.load_all(locale), "load " + locale)
		var c = content.collections
		var game = Game.new()
		game.configure(c.encounters,c.preops,c.staff,c.time_events,c.surgeries,c.patients,c.relationships,c.character_events,c.case_templates,c.micro_events,[],[],[],[],c.staff_role_cg_rewards,c.special_events,c.special_event_steps,c.date_profiles,c.date_locations)
		var actor = game.staff_record("doc_maki")
		expect(actor.age == 21 and actor.skills.surgery == 48, "profile values")
		expect(not game.staff_can_join_surgery_team("doc_maki"), "locked initially")
		game.meet_staff("doc_maki")
		expect(not game.staff_can_join_surgery_team("doc_maki"), "meeting alone must not unlock")
		game.relation_for("doc_maki").familiarity = 10
		expect(not game.sunday_date_eligible("doc_maki"), "date locked before onboarding despite met")
		var advanced = Advanced.new(game)
		expect(not contains(advanced.candidates("first_assistant", 1)), "advanced locked")
		# In-memory completion fixture only; no production event or player save.
		var event = Event.new({"id":"maki_lv0_onboarding","actor_id":"doc_maki","nodes":[],"start":""})
		event.completed = true
		game.character_events["maki_lv0_onboarding"] = event
		expect(game.staff_can_join_surgery_team("doc_maki"), "completed onboarding opens roster")
		expect(contains(advanced.candidates("first_assistant", 1)), "advanced first assistant available")
		expect(contains(advanced.candidates("second_assistant", 1)), "advanced second assistant available")
		game.relation_for("doc_maki").familiarity = 9
		expect(not game.sunday_date_eligible("doc_maki"), "date requires familiarity 10")
		game.relation_for("doc_maki").familiarity = 10
		expect(game.sunday_date_eligible("doc_maki"), "date eligible after onboarding")
		for pair in [[0,60],[1,60],[2,80],[3,92],[4,100],[5,100]]:
			game.relation_for("doc_maki").level = pair[0]
			expect(100-game.sunday_invitation_rejection_rate("doc_maki") == pair[1], "acceptance curve")
		game.relation_for("doc_maki").level = 0
		var date = game.date_profile_definitions["doc_maki"]
		expect(game.sunday_date_response("doc_maki","bookstore") == date.dialogue.favorites[0].text, "bookstore dialogue")
		expect(game.sunday_date_response("doc_maki","botanical_garden") == date.dialogue.favorites[1].text, "garden dialogue")
		expect(game.sunday_date_response("doc_maki","park") == date.dialogue.satisfied.text, "ordinary date dialogue")
		var prep = Preop.new(c.preops[0],c.staff,c.surgeries,c.patients,game.known_staff_ids(),true)
		expect(contains(prep.candidates("assistant_surgeon")), "ordinary assistant available")
		expect(not prep.qualified("doc_maki", {"id":"primary_surgeon","profession":"doctor"}), "no primary surgeon role")
		expect(prep.assignment_response("assistant_surgeon","doc_maki") == actor.team_dialogue.assignment, "authored assignment " + locale)
		expect(prep.intraoperative_response("doc_maki", "test", "", true) == actor.team_dialogue.intraoperative_correction, "authored correction " + locale)
		var reward = game.unlock_staff_role_cg("doc_maki","assistant_surgeon")
		expect(not reward.is_empty(), "first-assignment CG reward")
		expect(game.unlock_staff_role_cg("doc_maki","assistant_surgeon").is_empty(), "no duplicate reward")
		for path in actor.visuals.portraits.values():
			expect(load("res://" + path) is Texture2D, "portrait load " + path)
		expect(load("res://assets/events/staff_surgery_v1/doc_maki/assistant_confirmation.png") is Texture2D, "CG load")
	print("MAKI STAFF: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
