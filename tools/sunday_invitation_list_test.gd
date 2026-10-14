extends SceneTree

var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Locale load")
		app.configure_game_content()
		var game = app.game
		game.reset()
		game.set_test_time(6, 540)
		expect(game.sunday_other_known_staff().is_empty(), "Unknown characters hidden")
		for actor in ["doc_minato", "nurse_satsuki", "nurse_ange", "visiting_maya", "visiting_futaba", "nurse_ishigami", "doc_sakura_anesthesiology"]:
			game.meet_staff(actor)
		game.relation_for("doc_minato").familiarity = 10
		game.relation_for("doc_minato").flags.append("minato_intro_complete")
		expect(game.sunday_date_candidates() == ["doc_minato"], "Only Minato meets the fixture gates")
		expect(game.sunday_other_known_staff().size() == 6, "Known locked characters listed")
		app.show_sunday_invites()
		expect(app.page.get_node_or_null("SundayOtherScroll") == null, "Starts collapsed")
		app.page.get_node("SundayOtherToggle").pressed.emit()
		expect(app.page.get_node_or_null("SundayOtherScroll") != null, "Toggle expands")
		var snapshot: String = JSON.stringify(game.snapshot())
		for actor in game.sunday_other_known_staff():
			app.contact_sunday_other_staff(actor)
			var found := false
			for child in app.get_children():
				if child is AcceptDialog:
					found = true
					var expected: String = app.content.find_record("staff", actor).name + "\n" + game.date_profile_definitions[actor].invite_rejection.text
					expect(child.dialog_text == expected, "Exact localized refusal and speaker")
					child.hide()
					child.free()
			expect(found, "Refusal displayed")
			expect(JSON.stringify(game.snapshot()) == snapshot, "No action, reward, flags or history mutation")
		# Six eligible fixture actors test selection capacity without enabling real routes.
		for actor in ["doc_asuka", "doc_aoi", "doc_rei", "doc_emiko", "doc_artoria"]:
			game.meet_staff(actor)
			game.relation_for(actor).level = 2
			game.relation_for(actor).familiarity = 10
		var candidates: Array[String] = game.sunday_date_candidates()
		expect(candidates.size() == 5, "Five eligible candidates selected")
		expect(game.restore(JSON.parse_string(JSON.stringify(game.snapshot()))), "Snapshot restores")
		expect(game.sunday_date_candidates() == candidates, "Selection stable across save load")
		for actor in ["doc_asuka", "doc_aoi", "doc_rei", "doc_emiko", "doc_artoria", "doc_minato"]:
			expect(not game.sunday_other_known_staff().has(actor), "Eligible overflow not mislabeled as locked")
		app.show_sunday_invites(true)
		for actor in candidates:
			var btn = app.page.get_node_or_null("SundayCandidate_" + actor)
			expect(btn != null and btn.position.y + btn.size.y < 570, "Five rows fit before footer")
		if "--capture" in OS.get_cmdline_user_args():
			await process_frame
			await process_frame
			root.get_texture().get_image().save_png("/tmp/sunday_five_" + locale + ".png")
		# Reaching only the level is insufficient without the existing story flag.
		game.relation_for("nurse_satsuki").level = 2
		expect(not game.sunday_date_eligible("nurse_satsuki"), "Story gate enforced")
		game.relation_for("nurse_satsuki").flags.append("satsuki_lv2_patient_transport_complete")
		expect(game.sunday_date_eligible("nurse_satsuki"), "Completed gate allows eligibility")
		expect(not game.sunday_other_known_staff().has("nurse_satsuki"), "Newly eligible leaves foldout")
		game.complete_sunday_activity("rest_home")
		expect(game.sunday_date_candidates().is_empty() and game.sunday_other_known_staff().is_empty(), "Completed day rejects stale list actions")
	print("SUNDAY INVITATION LIST: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
