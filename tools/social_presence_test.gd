extends SceneTree

const Presence = preload("res://godot/systems/presence_resolver.gd")
var checks := 0
var failures := 0
var language_draws: Dictionary = {}

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func check_resolver() -> void:
	var roster: Array = []
	var known: Array[String] = []
	for i in range(8):
		var actor_id := "actor_%s" % i
		roster.append({"id": actor_id, "presence": {"fixed_locations": ["clinic", "ward"], "random_locations": ["lounge", "or", "rooftop", "ward"]}})
		known.append(actor_id)
	var resolver = Presence.new(roster)
	var reversed_roster := roster.duplicate(true)
	reversed_roster.reverse()
	var reordered = Presence.new(reversed_roster)
	var none: Array[String] = []
	var only_last: Array[String] = [known.back()]
	var fixed_count := 0
	var random_count := 0
	var roof_count := 0
	var samples := 0
	var changes := 0
	var noon_relocations := 0
	var natural_many := false
	var selected: Dictionary = {}
	for day in range(1, 366):
		expect(resolver.staff_at("lounge", day, 720, only_last) == only_last, "Noon guarantees lone eligible colleague")
		var lunch := resolver.hourly_assignments(day, 720, known)
		expect(lunch.values().has("lounge"), "Noon at least one, no artificial maximum")
		expect(lunch == resolver.hourly_assignments(day, 779, known), "Whole noon hour fixed")
		var base_lounge := false
		var altered := 0
		for person in roster:
			var base: String = resolver.hourly_assignment(person, day, 720)
			base_lounge = base_lounge or base == "lounge"
			if lunch[person.id] != base:
				altered += 1
		expect(altered == (0 if base_lounge else 1), "Noon only relocates one when naturally empty")
		noon_relocations += altered
		for clock in [540, 600, 660, 780, 840, 900, 960]:
			var assignments := resolver.hourly_assignments(day, clock, known)
			expect(assignments == resolver.hourly_assignments(day, clock + 59, known), "Hourly assignment stable")
			expect(assignments == reordered.hourly_assignments(day, clock, known), "Roster order does not matter")
			for actor in known:
				var location: String = assignments[actor]
				expect(location in ["clinic", "ward", "lounge", "or"], "No rooftop in ordinary assignment")
				if location in ["clinic", "ward"]:
					fixed_count += 1
				else:
					random_count += 1
				var appearances := 0
				for site in ["clinic", "ward", "lounge", "or"]:
					appearances += int(actor in resolver.staff_at(site, day, clock, known))
				expect(appearances == 1, "Exactly one ordinary location per person")
			natural_many = natural_many or resolver.staff_at("lounge", day, clock, known).size() > 1
			var roof := resolver.staff_at("rooftop", day, clock, known)
			expect(roof.size() <= 1, "One rooftop encounter at most")
			expect(roof == resolver.staff_at("rooftop", day, clock + 29, known), "Half-hour stable")
			expect(roof == reordered.staff_at("rooftop", day, clock, known), "Rooftop roster order invariant")
			expect(resolver.hourly_assignments(day, clock, known) == assignments, "Rooftop never moves ordinary staff")
			if not roof.is_empty():
				roof_count += 1
				selected[roof[0]] = true
				expect(resolver.staff_at("rooftop", day, clock, only_last) == only_last, "Single eligible rooftop candidate not crowded out")
			changes += int(roof != resolver.staff_at("rooftop", day, clock + 30, known))
			samples += 1
	for site in ["clinic", "lounge", "rooftop"]:
		expect(resolver.staff_at(site, 7, 720, none).is_empty(), "No unknown fallback at " + site)
	var fixed_rate := float(fixed_count) / (fixed_count + random_count)
	var roof_rate := float(roof_count) / samples
	expect(absf(fixed_rate - 0.8) < 0.02, "Per-person 80/20 distribution")
	expect(absf(roof_rate - 0.5) < 0.035, "Independent rooftop 50% distribution")
	expect(selected.size() == known.size() and changes > 0, "All candidates reachable; half-hour refresh")
	expect(noon_relocations > 0 and natural_many, "Noon repair and multiple natural lounge residents exercised")
	print("HOURLY RATES fixed=", fixed_rate, " rooftop=", roof_rate, " noon relocations=", noon_relocations)
	var mobile := {"id":"mobile", "presence":{"fixed_locations":[], "random_locations":["or","station","lounge"], "rooftop_enabled":false}}
	var mobile_resolver = Presence.new([mobile])
	var mobile_ids: Array[String] = ["mobile"]
	var absent := 0
	var places: Dictionary = {}
	for day in range(1, 366):
		for clock in [540, 600, 660, 780, 840, 900, 960]:
			var location: String = mobile_resolver.hourly_assignments(day, clock, mobile_ids).mobile
			absent += int(location.is_empty())
			places[location] = true
			expect(mobile_resolver.staff_at("rooftop", day, clock, mobile_ids).is_empty(), "Explicit roof exclusion")
	expect(absf(float(absent) / samples - 0.8) < 0.035 and places.size() == 4, "No fixed post: 80% absent, all three random locations reachable")
	expect(mobile_resolver.staff_at("lounge", 7, 720, mobile_ids) == mobile_ids, "No fixed post still participates in noon guarantee")
	var empty_resolver = Presence.new([{"id":"empty","presence":{"fixed_locations":[],"random_locations":[]}}])
	var empty_ids: Array[String] = ["empty"]
	expect(empty_resolver.staff_at("lounge", 7, 720, empty_ids).is_empty(), "No invented lounge eligibility")
	var roof_found := false
	for clock in range(540, 1020, 30):
		roof_found = roof_found or not empty_resolver.staff_at("rooftop", 7, clock, empty_ids).is_empty()
	expect(roof_found, "Default rooftop independent of all ordinary locations")
	seed(716281)
	var untouched_random := randi()
	seed(716281)
	resolver.staff_at("rooftop", 7, 720, known)
	resolver.staff_at("lounge", 7, 720, known)
	expect(randi() == untouched_random, "No global RNG consumption")

func run() -> void:
	check_resolver()
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Localized content loads")
		app.configure_game_content()
		var game = app.game
		game.reset()
		game.campaign_seed = 716281
		# Isolate ordinary presence, then test authored-event priority separately.
		game.character_event_definitions.clear()
		game.special_event_definitions.clear()
		for relation in game.relationships.values():
			relation.met = false
		game.meet_staff("nurse_rin")
		game.set_test_time(7, 720)
		expect(game.staff_present_at("lounge") == ["nurse_rin"], "Real profile reproducer: Mika is no longer hidden by unknown staff")
		for person in game.staff:
			game.meet_staff(person.id)
		game.probation_complete = true
		game.personal_nurse_system_unlocked = true
		expect(game.set_personal_nurse("nurse_haru"), "Assign clinical personal nurse independently")
		var known_team: Array[String] = game.known_staff_ids()
		for day in [7, 6]:
			for clock in [540, 569, 570, 599, 719, 720, 749, 750, 779, 780, 960, 989, 990, 1019]:
				game.set_test_time(day, clock)
				for site in ["lounge", "rooftop"]:
					var before: Array[String] = game.staff_present_at(site)
					expect(game.resolve_outpatient_support_actor() == "nurse_haru", "Personal nurse always attends clinic irrespective of map roll")
					expect(game.known_staff_ids() == known_team, "Surgical team eligibility unaffected by map roll")
					if site == "rooftop":
						expect("nurse_ishigami" not in before, "Chizuru excluded from actual rooftop")
					var key := "%s:%s:%s" % [day, clock, site]
					if locale == "zh_CN":
						language_draws[key] = before.duplicate()
					else:
						expect(before == language_draws[key], "Language switch preserves draw")
					for actor in before:
						expect(game.staff_is_met(actor), "Only known staff selected")
						if day == 6:
							expect(actor in game.sunday_on_duty_staff(), "Sunday draw respects duty roster")
					var snapshot: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
					expect(game.restore(snapshot), "In-memory JSON save restores")
					expect(before == game.staff_present_at(site), "Load preserves presence including empty rolls")
		# Real UI: repeated visits, existing localized chat actions, and time cost.
		for site in ["lounge", "rooftop"]:
			game.set_test_time(7, 720)
			if site == "rooftop":
				for clock in range(540, 960, 30):
					game.set_test_time(7, clock)
					if not game.staff_present_at(site).is_empty():
						break
			var people: Array[String] = game.staff_present_at(site)
			expect(not people.is_empty(), "UI fixture has present staff")
			var elapsed_before: int = game.elapsed()
			var first_chat := ""
			var expected_chats := 0
			for event in game.time_events_at(site):
				if event.actor_id != null and str(event.actor_id) in people:
					expected_chats += 1
			for visit in range(3):
				app.show_location(site, false, false)
				if app.location_uses_staff_drawer(site) and app.page.get_node_or_null("LocationStaffDrawer") == null:
					app.page.get_node("LocationStaffToggle").pressed.emit()
				await process_frame
				expect(app.screen == "location", "Social location opens")
				expect(game.staff_present_at(site) == people, "Re-entering does not reroll")
				expect(game.elapsed() == elapsed_before, "Entry has no time cost")
				var chats := 0
				for child in app.page.find_children("*", "Button", true, false):
					if child is Button and str(child.name).begins_with("TimeEvent_"):
						var event_id := str(child.name).trim_prefix("TimeEvent_")
						if game.time_event_definitions[event_id].actor_id != null:
							chats += 1
							first_chat = event_id
							expect(("Chat" if locale == "en" else "闲谈") in child.text, "Chat UI uses selected language")
				expect(chats == expected_chats, "Every existing authored chat remains available")
				for actor in people:
					var person: Dictionary = app.content.find_record("staff", actor)
					var has_profile := false
					for child in app.page.find_children("*", "Button", true, false):
						if child is Button and str(child.text).begins_with(str(person.name)):
							has_profile = true
					expect(has_profile, "Present staff have profile access even when no idle dialogue is authored")
			expect(not first_chat.is_empty(), "UI fixture exercises an existing chat")
			if OS.get_cmdline_user_args().has("--visual"):
				await process_frame
				await RenderingServer.frame_post_draw
				var image_path := "/private/tmp/hoshimi_social_%s_%s.png" % [locale, site]
				expect(root.get_texture().get_image().save_png(image_path) == OK, "Save independent window screenshot")
				print("VISUAL ", image_path)
			if not first_chat.is_empty():
				var cost := int(game.time_event_definitions[first_chat].minutes)
				expect(game.spend_time(first_chat), "Existing chat is usable")
				expect(game.elapsed() == elapsed_before + cost, "Only chatting consumes its existing time cost")
		# A real crowded noon roll must keep every colleague/chat reachable.
		# set_test_time sets the story offset; remove earlier test chat charges.
		game.time_log.clear()
		var crowded := false
		for day in range(1, 100):
			game.set_test_time(day, 720)
			var people: Array[String] = game.staff_present_at("lounge")
			if people.size() <= 4:
				continue
			crowded = true
			expect(game.current_absolute_clock() == 720, "Crowded fixture is actually noon")
			app.location_staff_drawer_open = "lounge"
			app.show_location("lounge", false, false)
			await process_frame
			await process_frame
			var scroll: ScrollContainer = app.page.find_child("LocationStaffScroll", true, false)
			expect(scroll != null, "Crowded lounge uses scrollable roster")
			if scroll != null:
				for actor in people:
					expect(scroll.find_child("LocationStaff_" + actor, true, false) != null, "Every crowded colleague has profile access")
				var buttons := scroll.find_children("TimeEvent_*", "Button", true, false)
				expect(buttons.size() == people.size(), "Every crowded lounge colleague has their own chat")
				if not buttons.is_empty():
					scroll.ensure_control_visible(buttons[-1])
					await process_frame
					expect(buttons[-1].get_global_rect().end.y <= scroll.get_global_rect().end.y + 1, "Last chat can be scrolled into view")
			if OS.get_cmdline_user_args().has("--visual"):
				await RenderingServer.frame_post_draw
				var path := "/private/tmp/hoshimi_crowded_lounge_%s.png" % locale
				expect(root.get_texture().get_image().save_png(path) == OK, "Save crowded lounge screenshot")
				print("VISUAL ", path)
			break
		expect(crowded, "Real hourly rolls exercise more than four lounge colleagues")
		# An eligible authored scene still supersedes the ordinary presence draw.
		game.set_test_time(7, 720)
		var authored: Dictionary = app.content.collections.character_events[0].duplicate(true)
		authored.id = "test_social_priority"
		authored.actor_id = "nurse_rin"
		authored.category = "context"
		authored.trigger_mode = "location"
		authored.location_id = "rooftop"
		authored.priority = 999
		authored.time_start = 540
		authored.time_end = 1019
		authored.conditions = {"min_day": 1, "required_events": []}
		game.character_event_definitions[authored.id] = authored
		expect("nurse_rin" in game.staff_present_at("rooftop"), "Authored scene places its actor irrespective of random draw")
		app.show_location("rooftop", false, false)
		expect(game.active_character_event_id == authored.id, "Authored scene retains UI priority")
	print("SOCIAL PRESENCE: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
