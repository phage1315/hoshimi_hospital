extends SceneTree

var checks := 0
var failures := 0
const CLOSED = ["nurse_ange", "doc_sakura_anesthesiology", "nurse_ishigami", "visiting_futaba", "visiting_maya"]
const RATES = {
	"doc_asuka": {0:65, 2:80, 4:100}, "doc_aoi": {0:70, 2:85, 3:95},
	"doc_rei": {0:80, 2:90, 4:100}, "doc_emiko": {2:55, 3:80, 4:98},
	"doc_artoria": {1:55, 2:75, 3:90, 4:100}, "doc_shiori": {0:50, 2:70, 3:85, 4:98},
	"doc_aqua": {0:80, 2:90, 3:98}, "doc_sayaka": {0:100},
	"doc_minato": {0:85, 2:85, 3:95, 4:100}, "nurse_haru": {0:65, 2:80, 3:95, 4:100},
	"nurse_rin": {0:75, 2:85, 4:98}, "nurse_yui": {0:75, 2:85, 3:95, 4:100},
	"nurse_hiroko": {0:75, 2:85, 4:100}, "nurse_moe": {0:55, 2:75, 3:90, 4:98},
	"nurse_satsuki": {2:35, 3:80, 4:98}, "pharmacist_manami": {0:90, 2:95, 3:100}
}

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func prepare(game, actor: String) -> void:
	game.reset()
	game.set_test_time(6, 540)
	game.meet_staff(actor)
	var profile: Dictionary = game.date_profile_definitions[actor]
	game.relation_for(actor).level = maxi(1 if actor == "doc_sayaka" else 0, int(profile.minimum_level))
	game.relation_for(actor).familiarity = int(profile.get("minimum_familiarity", 0))
	for flag in profile.get("required_flags", []):
		game.relation_for(actor).flags.append(flag)

func select_roll(game, actor: String, accept: bool) -> void:
	for seed in range(1, 1001):
		game.campaign_seed = seed
		if game.sunday_invitation_will_accept(actor) == accept:
			return
	expect(false, "Cannot find fixture roll for " + actor)

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var han := RegEx.new()
	han.compile("[\\x{3400}-\\x{9fff}]")
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		var game = app.game
		for actor in RATES:
			prepare(game, actor)
			var profile: Dictionary = game.date_profile_definitions[actor]
			expect(game.sunday_date_eligible(actor), "Minimum gate opens " + actor)
			game.relation_for(actor).met = false
			expect(not game.sunday_date_eligible(actor), "Unknown actor excluded")
			game.relation_for(actor).met = true
			for flag in profile.get("required_flags", []):
				game.relation_for(actor).flags.erase(flag)
				expect(not game.sunday_date_eligible(actor), "Required introduction/story flag " + str(flag))
				game.relation_for(actor).flags.append(flag)
			for level in range(6):
				for fam in [0, 9, 10, 24, 25, 54, 55, 100]:
					game.relation_for(actor).level = level
					game.relation_for(actor).familiarity = fam
					var eligible: bool = level >= int(profile.minimum_level) and fam >= int(profile.minimum_familiarity)
					var expected := 0
					for threshold in RATES[actor]:
						if level >= threshold:
							expected = RATES[actor][threshold]
					if eligible:
						expected = mini(100, expected + (5 if fam >= 25 else 0) + (5 if fam >= 55 else 0))
						if actor == "nurse_satsuki" and level == 2:
							expected = mini(49, expected)
					else:
						expected = 0
					expect(100 - game.sunday_invitation_rejection_rate(actor) == expected, "%s Lv%d Fam%d probability" % [actor, level, fam])
			prepare(game, actor)
			if actor != "doc_sayaka":
				select_roll(game, actor, false)
				app.show_sunday_invites()
				var before: String = JSON.stringify(game.snapshot())
				app.attempt_sunday_invitation(actor)
				expect(game.day_number() == 6 and JSON.stringify(game.snapshot()) == before, "Refusal consumes nothing")
				var found := false
				for child in app.get_children():
					if child is AcceptDialog:
						found = true
						expect(child.dialog_text.ends_with(str(profile.invite_rejection.text)), "Localized refusal")
						child.free()
				expect(found, "Refusal shown")
				expect(game.restore(JSON.parse_string(before)), "Restore pre-invitation save")
				expect(not game.sunday_invitation_will_accept(actor), "Reload cannot reroll refusal")
				expect(not game.complete_sunday_activity("date", actor, "cafe"), "Cannot bypass rejection at settlement")
			for location in ["planetarium"] + Array(profile.preferred_locations):
				prepare(game, actor)
				for day in range(1, 366):
					if game.calendar_date(day).weekday_id == "sun" and game.date_location_available(location, day):
						game.set_test_time(day, 540)
						break
				select_roll(game, actor, true)
				app.show_sunday_invites()
				app.page.get_node("SundayCandidate_" + actor).pressed.emit()
				var accepted = app.page.get_node_or_null("SundayAcceptedDialogue")
				expect(accepted != null, "Accepted screen " + actor)
				if accepted == null:
					continue
				expect(accepted.text == profile.dialogue.accepted.text, "Exact accepted dialogue")
				if locale == "en":
					expect(han.search(accepted.text) == null, "English accepted dialogue")
				app.page.get_node("SundayDateChooseLocation").pressed.emit()
				app.page.get_node("SundayDateLocation_" + location).pressed.emit()
				var response = app.page.get_node("SundaySatisfiedDialogue")
				var expected_line: String = profile.dialogue.satisfied.text
				for favorite in profile.dialogue.favorites:
					if favorite.id == location:
						expected_line = favorite.text
				expect(response.text == expected_line, "Exact location response " + actor + "/" + location)
				if locale == "en":
					expect(han.search(response.text) == null, "English satisfied dialogue")
				if "--capture" in OS.get_cmdline_user_args() and actor == "doc_asuka" and location == "aquarium":
					await process_frame
					await process_frame
					root.get_texture().get_image().save_png("/tmp/sunday_flow_" + locale + ".png")
				var day: int = game.day_number()
				var fam: int = game.relation_for(actor).familiarity
				var reward: int = game.date_familiarity_reward(actor, location)
				var charm: int = game.player_attributes().charm
				app.page.get_node("SundayDateFinish").pressed.emit()
				expect(game.day_number() == day + 1 and game.sunday_history.size() == 1, "One Sunday spent")
				expect(game.relation_for(actor).familiarity == mini(100, fam + reward), "Correct favorite reward")
				expect(game.player_attributes().charm == mini(100, charm + 1), "Charm awarded once")
				expect(not game.complete_sunday_activity("date", actor, location), "No duplicate settlement")
		for actor in CLOSED:
			prepare(game, actor)
			game.relation_for(actor).level = 5
			game.relation_for(actor).familiarity = 100
			expect(not game.sunday_date_eligible(actor) and not game.sunday_invitation_will_accept(actor), "Closed even at maximum stats")
			expect(game.sunday_other_known_staff().has(actor), "Closed known actor in fold")
			expect(not game.complete_sunday_activity("date", actor, "cafe"), "Closed actor cannot settle")
		# Exercise the actual first-date dispatch and both authored outcomes through UI settlement.
		for romantic in [false, true]:
			game.reset()
			game.meet_staff("doc_sayaka")
			game.set_test_time(2, 540)
			var phone = game.start_character_event("sayaka_week1_phone_exchange")
			while not phone.completed:
				expect(game.choose_character_event(str(phone.current().choices[0].id)), "Phone exchange prerequisite")
			game.finish_character_event()
			game.set_test_time(6, 540)
			game.relation_for("doc_sayaka").level = 0
			game.relation_for("doc_sayaka").familiarity = 0
			app.attempt_sunday_invitation("doc_sayaka")
			expect(game.active_character_event_id == "sayaka_lv1_first_date", "First date uses authored event without Fam10")
			var first = game.character_events.get(game.active_character_event_id)
			expect(first != null, "First date session exists")
			if first == null:
				continue
			while not first.completed:
				var choice: String = str(first.current().choices[0].id)
				if first.node_id == "v2_497":
					choice = "date_direct" if romantic else "date_only_meal"
				expect(game.choose_character_event(choice), "First date authored choice")
			expect(not game.can_start_regular_sunday_date("doc_sayaka"), "Completed milestone cannot also start ordinary date")
			app.finish_sunday_character_event("doc_sayaka", "restaurant_bar")
			expect(game.day_number() == 7 and game.sunday_history.size() == 1, "First date settles exactly once")
			expect(game.relationship_level("doc_sayaka") == 1, "All revised first-date answers reach Lv1")
			expect(not game.complete_sunday_activity("date", "doc_sayaka", "restaurant_bar"), "No repeat milestone settlement")
		# A ready authored Sunday milestone must win over a failed ordinary roll.
		prepare(game, "doc_asuka")
		var event: Dictionary = game.character_event_definitions["sayaka_lv1_first_date"].duplicate(true)
		event.id = "test_sunday_priority"
		event.actor_id = "doc_asuka"
		event.category = "contextual"
		event.conditions = {"min_day":1, "required_events":[], "special_requirements":[]}
		game.character_event_definitions[event.id] = event
		select_roll(game, "doc_asuka", false)
		expect(game.sunday_character_event_for("doc_asuka").get("id", "") == event.id, "Ready milestone detected despite refusal")
		expect(not game.can_start_regular_sunday_date("doc_asuka"), "Ready milestone blocks ordinary settlement")
		game.character_event_definitions.erase(event.id)
	print("SUNDAY DATE FLOW: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
