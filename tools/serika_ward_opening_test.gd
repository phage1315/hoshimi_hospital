extends "res://tools/serika_staff_patient_test.gd"
## Entrance-only coverage of all 32 agreed procedures; no player save writes.
func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/tmp/serika-ward-unused-%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	app.dialogue_auto_enabled = false
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		var c = app.content
		var actor: Dictionary = c.find_record("staff", Flow.ACTOR)
		var d: Dictionary = Registry.dialogue(Flow.ACTOR, locale)
		var patient := Registry.patient_record(actor, locale)
		for procedure in d.invitation_by_procedure:
			var definition := Registry.preop_definition(actor, c.find_record("surgeries", procedure), locale)
			var p = Preop.new(definition, c.collections.staff, c.collections.surgeries, [patient])
			var initial := [p.minutes, p.fear, p.pain, p.dignity, p.anxiety, p.player_effects.duplicate(true)]
			for i in range(8):
				expect(p.current().prompt == d.ward_visit_opening[i].text and p.current().speaker == d.ward_visit_opening[i].speaker, procedure + " entrance line " + str(i))
				expect(p.apply({"kind":"action", "id":p.current().actions[0].id}), "Continue entrance")
				expect(p.feedback.is_empty(), "No stale response hiding entrance")
			expect(p.stage_id == "ward_visit" and p.current().prompt == d.ward_visit_opening[-1].text, "Final line with original choices")
			expect(initial == [p.minutes, p.fear, p.pain, p.dignity, p.anxiety, p.player_effects], "Entrance has no mechanical effects")
			expect(p.current().actions.size() == 2 and p.current().actions[0].id == "explain_plan" and p.current().actions[1].id == "brief_plan", "Original choices")
			expect(p.apply({"kind":"action", "id":"brief_plan"}), "Original brief action")
			expect(p.stage_id == "team" and p.feedback == d.reaction_lines.brief_plan, "Original response; no replay")
		# Real UI, reopening and keyboard input: two representative agreed procedures.
		for procedure in ["surgery_appendix", "surgery_breast_tumor"]:
			fixture(app.game)
			expect(app.game.invite_staff_patient(Flow.ACTOR, procedure), "Admit")
			app.show_preop(Registry.PREOP_ID)
			var p = app.game.preops[Registry.PREOP_ID]
			for i in range(9):
				await process_frame
				expect(app.page.get_node("PreopRecordText").text == d.ward_visit_opening[i].text, "Rendered exact " + locale + str(i))
				var speaker: String = app.protagonist_name() if d.ward_visit_opening[i].speaker == "player" else actor.name if d.ward_visit_opening[i].speaker == "patient" else app.tx("ui.common.narrator", "旁白")
				expect(app.page.get_node("PreopRecordSpeaker").text == speaker, "Correct speaker")
				expect(app.page.get_node_or_null("CharacterPortrait") != null, "Patient portrait")
				expect(not app.game.can_save_progress(), "No mid-event save")
				if i == 1:
					app.show_map(); app.show_preop(Registry.PREOP_ID)
					expect(p.stage_id == "ward_opening_1", "Reentry resumes memory; not duplicated")
				if i == 3 and DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png("/tmp/serika-ward-opening-" + locale + ".png")
				if i < 8:
					if i % 2 == 0:
						var key := InputEventKey.new()
						key.keycode = KEY_SPACE if i % 4 == 0 else KEY_ENTER
						key.pressed = true
						app._unhandled_key_input(key)
					else:
						app.page.get_node("PreopAction_continue_ward_opening_%d" % i).pressed.emit()
			app.page.get_node("PreopAction_explain_plan").pressed.emit()
			await process_frame
			expect(p.stage_id == "graphic_preop_question" and p.feedback == d.reaction_lines.explain_plan, "Authored option response unchanged")
			app.show_map(); app.show_preop(Registry.PREOP_ID)
			expect(p.stage_id == "graphic_preop_question" and app.page.get_node("PreopRecordText").text == d.reaction_lines.explain_plan, "No entrance replay after choice")
		var sayaka := Registry.preop_definition(c.find_record("staff", "doc_sayaka"), c.find_record("surgeries", "surgery_appendix"), locale)
		expect(sayaka.start == "ward_visit", "Other staff unchanged")
	print("SERIKA WARD OPENING: %d checks; %d failures" % [checks, failures])
	app.free()
	quit(1 if failures else 0)
