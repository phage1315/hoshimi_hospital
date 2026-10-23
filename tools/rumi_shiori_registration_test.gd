extends SceneTree

const Preop = preload("res://godot/systems/preop_session.gd")
const IDS = ["nurse_iwasaki_rumi", "nurse_yoneda_shiori"]
const SOURCE = "res://research/character_references/rumi_shiori_2026-10-21/data_audit_v2/"
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
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		app.game.reset()
		var game = app.game
		game.probation_complete = true
		game.personal_nurse_system_unlocked = true
		for actor_id in IDS:
			expect(not game.staff_is_met(actor_id), "No automatic introduction")
			expect(not game.personal_nurse_candidates().has(actor_id), "Unmet nurse is not selectable")
			expect(not game.staff_present_at("station").has(actor_id), "Unmet nurse remains hidden")
			for event in game.time_events_at("lounge") + game.time_events_at("rooftop"):
				expect(event.actor_id != actor_id, "No idle chat before meeting")
			game.meet_staff(actor_id) # Test-only introduction; production initial state stays unmet.
			expect(game.set_personal_nurse(actor_id), "Met nurse selectable at Lv0")
			var actor: Dictionary = app.content.find_record("staff", actor_id)
			var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SOURCE + "source/data/staff/" + actor_id + "/dialogue_authoring.json"))
			var prep = Preop.new(app.content.collections.preops[0], app.content.collections.staff, app.content.collections.surgeries, app.content.collections.patients, [actor_id], true)
			for role in ["scrub_nurse", "circulating_nurse", "ward_nurse"]:
				expect(prep.qualified(actor_id, {"profession":"nurse"}), "All manual nurse roles available")
				expect(prep.assignment_response(role, actor_id) == source.team_assignment_replies[role][locale], "Exact assignment " + role)
				var reward: Dictionary = game.staff_role_cg_reward_for(actor_id, role)
				expect(not reward.is_empty(), "Role CG registered " + role)
				if not reward.is_empty():
					expect(FileAccess.file_exists("res://" + reward.path), "Role CG exists")
			prep.set_graphic_preop_explainer(actor_id)
			var wrappers: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SOURCE + ("preop_graphic_wrapper_en.json" if locale == "en" else "preop_graphic_wrapper_user_source.json")))
			for slot in ["open", "insert_a", "insert_b", "close"]:
				expect(prep.graphic_preop_wrapper(slot) == wrappers[actor_id][slot], "Exact wrapper " + slot)
			for flavor in Preop.CRISIS_FLAVOR_IDS:
				for severity in ["routine", "severe"]:
					for attempt in range(1, 4):
						prep.active_crisis = {"speaker_actor_id":actor_id,"flavor_id":flavor,"severity":severity,"attempt":attempt,"callout_variant_id":"standard"}
						var expected: String = source.crisis_attempt_callout[flavor]["normal" if severity == "routine" else "severe"][str(attempt)][locale]
						expect(prep.crisis_callout_text() == expected, "Exact crisis " + actor_id + "/" + flavor + "/" + severity + "/" + str(attempt))
			for key in actor.visuals.portraits:
				var img := Image.load_from_file("res://" + str(actor.visuals.portraits[key]))
				expect(img != null and not img.is_empty(), "Portrait loads " + key)
				expect(load("res://" + str(actor.visuals.portraits[key])) is Texture2D, "Imported texture loads " + key)
				if img != null and not img.is_empty():
					expect(img.get_pixel(0, 0).a == 0.0, "Transparent corner " + key)
			for day in [1, 62, 154, 245, 335]:
				var month: int = game.calendar_date(day).month
				var outfit := "casual_winter" if month in [9,10,11,12,1,2] else "casual"
				game.active_after_work_walk = {"workday":day,"variant":"normal","actor_id":actor_id,"departure_clock":1040,"phase":"offer","outcome":"","reward":2}
				expect(app.after_work_outfit(actor, game.active_after_work_walk) == outfit, "Seasonal outfit")
				app.show_after_work_walk()
				expect(app.page.get_node("AfterWorkDialogue").text == source.after_work_companion_dialogue.invitation[0][locale], "Invitation shown verbatim")
				game.active_after_work_walk.phase = "result"
				for outcome in ["completed", "declined", "skipped"]:
					game.active_after_work_walk.outcome = outcome
					app.show_after_work_walk()
					var kind := "acceptance" if outcome == "completed" else "unavailable" if outcome == "declined" else "farewell"
					expect(actor.after_work_companion_dialogue[kind].has(app.page.get_node("AfterWorkDialogue").text), "Localized result dialogue")
				if "--capture" in OS.get_cmdline_user_args() and day in [62,245]:
					game.active_after_work_walk.outcome = "completed"
					app.show_after_work_walk()
					await process_frame
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png("res://docs/qa/rumi_shiori_registration/%s_%s_%s.png" % [actor_id, locale, outfit])
				app.show_after_work_authored_chat()
				expect(actor.after_work_short_chat.has(app.page.get_node("AfterWorkDialogue").text), "Narration chat remains intact")
				app.show_after_work_authored_chat(true)
				expect(actor.after_work_companion_dialogue.farewell.has(app.page.get_node("AfterWorkDialogue").text), "Farewell shown")
			game.active_after_work_walk.clear()
		# Real clinical action sequence tests both wrong and correct diagnosis feedback.
		var visit = game.open_visit("visit_sora")
		for action in ["greet", "pain", "associated", "background", "to_exam", "vitals", "request_full_undress", "authoritative_full_undress", "blood", "imaging", "to_diagnosis"]:
			expect(game.apply_clinic_action(action), "Reach diagnosis " + action)
		var checkpoint: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
		for actor_id in IDS:
			for action in ["diagnose_gastro", "diagnose_observe", "diagnose_appendix"]:
				expect(game.restore(checkpoint), "Restore diagnosis checkpoint")
				game.set_personal_nurse(actor_id)
				app.show_encounter("visit_sora")
				expect(game.apply_clinic_action(action), "Submit diagnosis " + action)
				visit = game.visits.visit_sora
				var line: Dictionary = game.clinic_presentation(visit)
				var profile: Dictionary = game.staff_record(actor_id).personal_nurse
				expect(line.speaker == actor_id, "Feedback speaker")
				expect(profile.dialogue.diagnosis_correct_reply.has(line.text) if action == "diagnose_appendix" else line.text == profile.diagnosis_corrections[action], "Authored diagnosis feedback")
		game.reset()
		var old_save: Dictionary = JSON.parse_string(JSON.stringify(game.snapshot()))
		for actor_id in IDS:
			old_save.relationship_state.erase(actor_id)
		expect(game.restore(old_save), "Older save without new nurses restores")
		for actor_id in IDS:
			expect(not game.staff_is_met(actor_id), "Test introduction never changes initial data")
	print("RUMI SHIORI REGISTRATION: %s checks; %s failure(s)" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
