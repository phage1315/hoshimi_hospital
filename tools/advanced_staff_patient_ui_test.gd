extends "res://tools/advanced_staff_patient_test.gd"
var app
var native := false
func capture(id: String) -> void:
	if not native: return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/advanced_staff_"+id+".png")
func view(): return app.page.get_node("AdvancedReferralView")
func day_card(ordinal: int, method: int) -> void:
	var c = app.advanced_controller
	view().render(); await process_frame
	expect(not c.day_transition.is_empty(), "Cross-day card queued")
	if c.day_transition.is_empty(): return
	expect(int(c.day_transition.ordinal) == ordinal, "Correct relative day")
	var panel = view().get_node("AdvancedDayTransition")
	expect(panel.get_node("DayTransitionTitle").text == view().tr_key("day_transition_second" if ordinal == 2 else "day_transition_third"), "Localized morning title")
	expect(panel.get_node("DayTransitionDate").text == str(app.game.calendar_date(c.day_transition.day).iso), "Actual calendar date")
	expect(app.page.get_node_or_null("AdvancedCast") == null and app.page.get_node_or_null("GeneralAnesthesiaSplash") == null, "Card precedes next scene")
	var index: int = c.story_index
	await capture(c.actor_id + "_day" + str(ordinal) + ("_en" if view().english else "_zh"))
	if method == 3:
		await create_timer(2.0).timeout
	else:
		var event
		if method == 2:
			event = InputEventMouseButton.new(); event.button_index = MOUSE_BUTTON_LEFT; event.position = Vector2(500,400)
		else:
			event = InputEventKey.new(); event.keycode = KEY_SPACE if method == 0 else KEY_ENTER
		event.pressed = true; root.push_input(event, true)
		event = event.duplicate(); event.pressed = false; root.push_input(event, true)
		await process_frame
	expect(c.day_transition.is_empty() and view().get_node_or_null("AdvancedDayTransition") == null, "Card closes once")
	expect(c.story_index == index, "Dismissing card does not skip dialogue")
func chapter_ui() -> void:
	var c = app.advanced_controller
	while not c.story_phase.is_empty():
		view().render()
		await process_frame
		var phase: String = c.story_phase
		var index: int = c.story_index
		var row: Dictionary = c.story_content[phase].lines[index]
		var card = app.page.get_node("AdvancedCast")
		var label = card.find_child("AdvancedStaffDialogue",true,false)
		var text: String = row.text_en if view().english else row.text
		text = text.replace("〈本次术式〉",view().title_of(Model.procedure(c.story_record.procedure_id)))
		expect(label.text == text and label.size.y > 20,"Actual localized VN text visible")
		expect(card.get_meta("actor_id") == (c.actor_id if row.speaker == "patient" else "PLAYER"),"Speaker and actor match")
		var art: TextureRect = card.get_node("AdvancedActorPortrait")
		if phase in ["night", "dark", "after"]:
			expect(app.background.texture.resource_path == "res://assets/backgrounds/ward_night_v1/ward_night.png", "Preoperative night uses night ward")
		if row.speaker == "patient":
			var expected_patient: Dictionary = Present.patient(c.story_record, app.game, view().english)
			var expected_path: String = expected_patient.visuals.portraits["ward/neutral"]
			if phase in ["dark", "after"]:
				expected_path = "assets/h/" + c.actor_id + "/portrait_neutral.png"
			if phase in ["dark", "after"] and c.actor_id == "doc_sayaka":
				expect(art.texture is AtlasTexture and art.texture.atlas.resource_path == preload("res://godot/systems/h_profile_v1_content.gd").EXPRESSION_ATLAS, "Sayaka uses production H atlas")
				if art.texture is AtlasTexture:
					expect(art.texture.region == Rect2(preload("res://godot/systems/h_profile_v1_session.gd").EXPRESSION_ATLAS_CELLS["neutral"]), "Sayaka uses neutral atlas cell")
			else:
				expect(art.texture != null and art.texture.resource_path == "res://" + expected_path, "Correct patient outfit texture loaded")
			expect(art.is_visible_in_tree() and art.size.x > 0 and art.size.y > 0, "Patient portrait visibly laid out")
			if phase in ["dark", "after"]:
				var dialogue_rect: Rect2 = card.get_node("AdvancedDialoguePanel").get_global_rect()
				var portrait_rect: Rect2 = art.get_global_rect()
				expect(art.size == Vector2(220,220), "Private portrait uses compact headshot size")
				expect(portrait_rect.end.x <= dialogue_rect.end.x and portrait_rect.position.x > dialogue_rect.get_center().x and portrait_rect.end.y < dialogue_rect.position.y, "Private portrait above dialogue top right without covering text")
			if native and index == 1: await capture(c.actor_id + "_ward_" + phase + ("_en" if view().english else "_zh"))
		locked(app.game, phase)
		var event
		if index%3==2:
			event = InputEventMouseButton.new(); event.button_index=MOUSE_BUTTON_LEFT
			event.position = card.get_node("AdvancedDialoguePanel").get_global_rect().get_center()
		else:
			event=InputEventKey.new();event.keycode=KEY_SPACE if index%3==0 else KEY_ENTER
		event.pressed=true;root.push_input(event,true)
		event=event.duplicate();event.pressed=false;root.push_input(event,true)
		await process_frame
		expect(c.story_phase != phase or c.story_index == index+1,"One input advances exactly one row")
		if c.story_phase == phase and c.story_index == index: c.advance_story()
func run() -> void:
	native = "--native" in OS.get_cmdline_user_args()
	app=load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/tmp/advanced_staff_unused_%s.json"%OS.get_process_id()
	root.add_child(app);await process_frame
	for locale in ["zh_CN","en"]:
		for actor in ["doc_sayaka","doc_serika"]:
			app.content.load_all(locale);app.configure_game_content()
			var original_game = app.game
			var original_slot: int = app.active_save_slot
			app.show_event_test_hub()
			var entry = app.page.find_child("AdvancedStaffPatientTest_" + actor, true, false)
			expect(entry != null, "Event test hub has actor entry")
			entry.pressed.emit()
			var c = app.advanced_controller
			expect(app.game != original_game and app.active_save_slot == 0, "Test uses independent game and no save slot")
			expect(c.story_phase == "consult", "Hub click starts consultation")
			view().render();await capture(actor+"_"+locale+"_consult")
			await chapter_ui()
			c.choose_night(true);await chapter_ui()
			view().render();await create_timer(1.0).timeout
			expect(c.story_phase=="after","Blackout timer reaches after chapter")
			await chapter_ui()
			expect(c.session != null,"UI reaches shared operation")
			await day_card(2, 0 if actor == "doc_sayaka" else 1)
			var patient = Present.patient(c.state().appointment.case,app.game,locale=="en")
			for key in ["splash/general_anesthesia","intraoperative/anesthetized","team_confirmation"]:
				var path: String = patient.visuals.portraits.get(key,"")
				expect(not path.is_empty() and ResourceLoader.exists("res://"+path),"Real staff patient asset "+actor+":"+key)
			view().render();await process_frame
			var splash = app.page.get_node_or_null("GeneralAnesthesiaSplash")
			expect(splash != null,"Actual anesthesia splash opens")
			if splash != null: splash.find_child("AnesthesiaSplashContinue",true,false).pressed.emit()
			await process_frame
			expect(not c.session.splash_pending,"Actual splash confirmation advances")
			view().render();await capture(actor+"_"+locale+"_table")
			var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/staff_patient/procedure_poses.json"))
			for procedure in poses:
				var probe: Dictionary = c.state().appointment.case.duplicate(true)
				probe.procedure_id=procedure
				var mapped: Dictionary=Present.patient(probe,app.game,locale=="en")
				expect(mapped.visuals.portraits.team_confirmation.ends_with("/"+poses[procedure]+".png"),"Procedure maps to correct patient pose")
			c.session=Session.new(c.session.definition,Model.fixtures(c.session.definition.id)[0],8,[],{},true)
			drive(c.session)
			if actor=="doc_serika": c.session.success=false
			expect(c.finish_operation(),"UI result branch")
			await day_card(3, 2 if actor == "doc_sayaka" else 3)
			await chapter_ui()
			expect(not c.episode_active,"UI Day3 settlement complete")
			app.exit_advanced_referral()
			expect(app.screen == "event_test_hub" and app.game == original_game and app.active_save_slot == original_slot,"Returns to hub and restores original game/slot")
			expect(not FileAccess.file_exists(app.saves.path), "Hub test never writes a save")
	app.queue_free();await process_frame
	print("ADVANCED STAFF UI: %s checks; %s failures"%[checks,failures])
	quit(1 if failures else 0)
