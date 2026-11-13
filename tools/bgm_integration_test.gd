extends SceneTree
const Music = preload("res://godot/ui/music_director.gd")
var checks := 0
var failures := 0
class PrepStub extends RefCounted:
	var flags: Array = []
	var stage: Dictionary = {"scene": "ward"}
	func current() -> Dictionary:
		return stage
class OperationStub extends RefCounted:
	var finished := false
	var success := false
func expect(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	var prefix := "/private/tmp/hoshimi-bgm-%s" % Time.get_ticks_usec()
	app.saves.path = prefix + "-slot.json"
	app.title_preferences_path = prefix + "-preferences.cfg"
	app.title_notice_enabled = false
	root.add_child(app)
	await process_frame
	await process_frame
	expect(app.music.current_id == "title", "Real title screen starts title BGM")
	app.set_process(false)
	await check_opening_music(app)
	await check_triage_music(app)
	await check_location_event_music(app)
	for id in Music.TRACKS:
		var stream = Music.stream_for(id)
		expect(stream != null and stream.get_length() > 1.0, "Decoded MP3: " + id)
		expect(stream.loop == (id != "ending"), "Loop policy: " + id)
		print("BGM %s: %.2f seconds" % [id, stream.get_length()])
	for month in range(1, 13):
		var expected := "winter" if month in [1,2,12] else "spring" if month < 6 else "summer" if month < 9 else "autumn"
		expect(Music.season(month) == expected, "Season month %s" % month)
	app.music.fade_seconds = 0.05
	app.show_map(false)
	app._process(0.0)
	expect(app.music.current_id == "spring", "Production map selects calendar season")
	await create_timer(0.12).timeout
	var player: AudioStreamPlayer = app.music.players[app.music.active_index]
	player.seek(10.0)
	app.show_map(false)
	app._process(0.0)
	expect(app.music.players[app.music.active_index] == player and player.get_playback_position() >= 9.9, "Page redraw does not restart music")
	app.show_save_slots("load")
	app._process(0.0)
	expect(app.music.current_id == "spring", "Save menu preserves music")
	app.show_location("lounge", true, false, false)
	app._process(0.0)
	expect(app.screen == "location" and app.music.current_id == "lounge", "Real lounge entry uses lounge music")
	await create_timer(0.1).timeout
	var lounge_player: AudioStreamPlayer = app.music.players[app.music.active_index]
	lounge_player.seek(10.0)
	app.show_location("lounge", true, false, false)
	app._process(0.0)
	expect(app.music.players[app.music.active_index] == lounge_player and lounge_player.get_playback_position() >= 9.9, "Lounge redraw preserves playback")
	app.show_save_slots("load")
	app._process(0.0)
	expect(app.music.current_id == "lounge", "Lounge save menu keeps music")
	app.show_map(false)
	app._process(0.0)
	expect(app.music.current_id == "spring", "Leaving lounge restores seasonal map music")
	app.show_location("ward", true, false, false)
	app._process(0.0)
	expect(app.music.current_id == "spring", "Other locations do not inherit lounge music")
	app.show_location("rooftop", true, false, false)
	app._process(0.0)
	expect(app.screen == "location" and app.music.current_id == "roof", "Real rooftop entry uses roof music")
	await create_timer(0.1).timeout
	var roof_player: AudioStreamPlayer = app.music.players[app.music.active_index]
	roof_player.seek(10.0)
	app.show_location("rooftop", true, false, false)
	app._process(0.0)
	expect(app.music.players[app.music.active_index] == roof_player and roof_player.get_playback_position() >= 9.9, "Rooftop redraw preserves playback")
	app.show_save_slots("load")
	app._process(0.0)
	expect(app.music.current_id == "roof", "Rooftop save menu keeps music")
	app.show_location("lounge", true, false, false)
	app._process(0.0)
	expect(app.music.current_id == "lounge", "Rooftop to lounge switches to lounge track")
	app.show_map(false)
	app._process(0.0)
	expect(app.music.current_id == "spring", "Return to map restores seasonal music")
	app.render_day_transition(Callable())
	app._process(0.0)
	expect(app.music.current_id == "night", "Real day end uses night track")
	app.screen = "after_work_walk"
	expect(app.music.track_for(app) == "night", "Walk uses night track")
	for screen in ["character_event", "daydream_playback", "sunday_date"]:
		app.screen = screen
		expect(app.music.track_for(app) == "spring", "Unassigned scene falls back to seasonal music: " + screen)
	app.screen = "preop"
	app.game.active_preop_id = "bgm_fixture"
	var prep := PrepStub.new()
	app.game.preops["bgm_fixture"] = prep
	var template: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/patients/templates/preop.json"))
	for stage in template.stages:
		if str(stage.id) not in ["ward_visit", "team", "preparation", "prepared", "changing"]: continue
		prep.stage = stage
		expect(app.music.track_for(app) == "prep", "Real preparation stage plays prep: " + str(stage.id))
	for screen in ["ward_preparation_cg", "preop_transition_video"]:
		app.screen = screen
		expect(app.music.track_for(app) == "prep", "Preparation CG/video keeps preparation music")
	app.screen = "preop"
	for stage in template.stages:
		if str(stage.id) == "operating_room": prep.stage = stage
	expect(not prep.flags.has("incision_made"), "OR entry test is before incision")
	var selected: String = app.music.track_for(app)
	expect(selected in Music.ORDINARY_SURGERY_TRACKS, "Ordinary surgery draws from two tracks")
	var random_state: int = app.music.surgery_rng.state
	app.screen = "preop_transition_video"
	expect(app.music.track_for(app) == "prep", "Entrance video finishes before music changes to surgery")
	app.screen = "or_table_palpation"
	expect(app.music.track_for(app) == selected, "Pre-incision OR palpation keeps the same surgery selection")
	for screen in ["surgery_video", "surgery_cg", "surgery_sweep_result"]:
		app.screen = screen
		expect(app.music.track_for(app) == selected, "Surgical presentation continuity: " + screen)
		expect(app.music.surgery_rng.state == random_state, "Redraw does not reroll music")
	app.music.surgery_rng.seed = 71
	var seen := {}
	app.screen = "preop"
	for i in range(32):
		var next_prep := PrepStub.new()
		next_prep.stage = {"scene": "operating_room"}
		app.game.preops["bgm_fixture"] = next_prep
		var choice: String = app.music.track_for(app)
		seen[choice] = true
		var state: int = app.music.surgery_rng.state
		expect(app.music.track_for(app) == choice and state == app.music.surgery_rng.state, "Per-case choice is stable")
	expect(seen.has("surgery_1") and seen.has("surgery") and seen.size() == 2, "Seeded multi-case draws include exactly both ordinary tracks")
	app.screen = "advanced_referral"
	var controller = preload("res://godot/systems/advanced_referral.gd").new(app.game, true)
	app.advanced_controller = controller
	expect(app.music.track_for(app) == "advanced_hope", "Advanced Day 1 board/selection uses hopeful music")
	controller.state().appointment = {"intake_day": 1, "operation_day": 2, "review_day": 3}
	expect(app.music.track_for(app) == "advanced_hope", "Day 1 booked team uses hopeful music")
	controller.demo_day = 2
	expect(app.music.track_for(app) == "spring", "Day 2 waiting does not reuse hopeful track")
	var operation := OperationStub.new()
	controller.session = operation
	expect(app.music.track_for(app) == "advanced_surgery", "Day 2 live operation uses dedicated track")
	operation.finished = true
	expect(app.music.track_for(app) == "", "Failed operation immediately requests silence")
	operation.success = true
	expect(app.music.track_for(app) == "advanced_surgery", "Success on Day 2 does not start Day 3 music early")
	controller.session = null
	controller.state().outcome = {"success": true}
	expect(app.music.track_for(app) == "spring", "Early success fact waits until review day")
	controller.demo_day = 3
	expect(app.music.track_for(app) == "advanced_hope", "Successful Day 3 review uses hopeful music")
	controller.state().outcome.success = false
	expect(app.music.track_for(app) == "", "Failed Day 3 review is silent")
	controller.state().outcome = {}
	controller.state().appointment = {}
	controller.last_summary = {"case_id": "test", "success": false}
	expect(app.music.track_for(app) == "", "Failed settled summary is silent")
	controller.last_summary.success = true
	controller.story_phase = "day3"
	expect(app.music.track_for(app) == "advanced_hope", "Successful settled summary and first-clear story use hopeful music")
	var staff = preload("res://godot/systems/advanced_staff_patient.gd").new(app.game, "doc_sayaka", true)
	staff.local_facts.appointment = {"intake_day": 1, "operation_day": 2, "review_day": 3}
	app.advanced_controller = staff
	staff.story_phase = "consult"
	expect(app.music.track_for(app) == "advanced_hope", "Staff patient Day 1 consultation uses hopeful track")
	staff.story_phase = "night"
	expect(app.music.track_for(app) == "spring", "Staff night story does not inherit consultation track")
	staff.demo_day = 3
	staff.local_facts.outcome = {"success": true}
	staff.story_phase = "success"
	expect(app.music.track_for(app) == "advanced_hope", "Staff patient successful Day 3 uses hopeful music")
	staff.local_facts.outcome.success = false
	staff.story_phase = "failure"
	expect(app.music.track_for(app) == "", "Staff patient failure is silent")
	app.advanced_controller = null
	var tutorial_definition: Dictionary = app.content.find_record("special_events", "advanced_referral_tutorial_chisato")
	var tutorial_steps := {}
	for step in JSON.parse_string(FileAccess.get_file_as_string("res://data/events/special_event_steps/advanced_referral_chisato.json")):
		tutorial_steps[str(step.id)] = step
	var tutorial = preload("res://godot/systems/special_event_session.gd").new(tutorial_definition, tutorial_steps)
	app.game.active_special_event = tutorial
	app.special_event_gallery_replay = tutorial
	for chapter in [0, 2]:
		tutorial.step_index = chapter
		tutorial.node_id = str(tutorial.current_step().start)
		for screen in ["special_event", "special_gallery_replay"]:
			app.screen = screen
			expect(app.music.track_for(app) == "advanced_hope", "Authored tutorial Day 1/3 and replay use hopeful music")
	tutorial.step_index = 1
	tutorial.node_id = "stage1"
	expect(app.music.track_for(app) == "advanced_surgery", "Tutorial Day 2 operation retains dedicated track")
	app.game.active_special_event = null
	app.special_event_gallery_replay = null
	# Playback continuity across a real loop boundary (no multi-minute wait).
	app.music.play_track("surgery")
	await create_timer(0.1).timeout
	player = app.music.players[app.music.active_index]
	player.seek(player.stream.get_length() - 0.05)
	await create_timer(0.3).timeout
	expect(player.playing and player.get_playback_position() < 2.0, "MP3 loops through its end")
	for id in ["title", "night", "winter", "surgery", "advanced_surgery", ""]:
		app.music.play_track(id)
		await create_timer(0.01).timeout
	await create_timer(0.12).timeout
	for voice in app.music.players:
		expect(not voice.playing, "Rapid switches followed by silence leave no orphan audio")
	app.music.set_volume(0.0, true)
	expect(AudioServer.is_bus_mute(AudioServer.get_bus_index("BGM")), "Zero volume mutes BGM")
	app.music.set_volume(0.42, true)
	app.music.set_volume(0.9)
	app.music.configure_preferences(app.title_preferences_path)
	expect(is_equal_approx(app.music.volume, 0.42), "Volume persists only in preferences")
	app.game.preops.erase("bgm_fixture")
	app.game.active_preop_id = ""
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load actual localized content: " + locale)
		app.TitleView.settings(app)
		var slider = app.find_child("MusicVolumeSetting", true, false)
		expect(slider != null, "Volume setting present: " + locale)
		if slider != null:
			slider.value = 37
			expect(is_equal_approx(app.music.volume, 0.37), "Settings slider controls live music")
		app.get_node("TitleSettingsDialog").free()
	if "--native-preview" in OS.get_cmdline_user_args():
		app.title_screen()
		app._process(0.0)
		app.TitleView.settings(app)
		await create_timer(2.0).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/private/tmp/hoshimi-bgm-settings-preview.png")
	DirAccess.remove_absolute(app.title_preferences_path)
	app.queue_free()
	await process_frame
	print("BGM INTEGRATION: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

func check_opening_music(app) -> void:
	app.music.fade_seconds = 0.05
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Opening content loads: " + locale)
		app.configure_game_content()
		app.game.reset()
		app.TitleView.chapter(app)
		app._process(0.0)
		expect(app.music.current_id == "spring", "Chapter card starts spring music")
		await create_timer(0.1).timeout
		var voice: AudioStreamPlayer = app.music.players[app.music.active_index]
		voice.seek(10.0)
		app.start_story()
		app._process(0.0)
		expect(app.music.players[app.music.active_index] == voice and voice.get_playback_position() >= 9.9, "Chapter to story keeps playback")
		# Render every authored node, including both choice branches and every text page.
		for node in app.content.dialogue.nodes:
			app.session.current_id = str(node.id)
			app.reset_dialogue_page()
			app.show_dialogue()
			var pages: int = app.dialogue_pages(str(node.text)).size()
			for page_index in range(pages):
				app.dialogue_page_index = page_index
				app.show_dialogue()
				app._process(0.0)
				expect(app.music.current_id == "spring" and app.music.players[app.music.active_index] == voice and voice.get_playback_position() >= 9.9, "Opening node/page continuity: %s %s/%s" % [locale, node.id, page_index])
			for index in range(node.get("choices", []).size()):
				app.session.current_id = str(node.id)
				app.advance(index)
				app._process(0.0)
				expect(app.music.current_id == "spring" and app.music.players[app.music.active_index] == voice, "Opening choice keeps spring music")
		app.show_map(false)
		app._process(0.0)
		expect(app.music.players[app.music.active_index] == voice and voice.get_playback_position() >= 9.9, "Spring map keeps opening music position")
		app.title_screen()
		app._process(0.0)
		expect(app.music.current_id == "title", "Returning to title restores title track")
	app.content.load_all("zh_CN")
	app.configure_game_content()
	app.game.reset()

func check_triage_music(app) -> void:
	app.show_encounter("visit_sora")
	app._process(0.0)
	expect(app.screen == "encounter" and app.music.current_id == "triage", "Formal consultation entry starts triage music")
	await create_timer(0.1).timeout
	var voice: AudioStreamPlayer = app.music.players[app.music.active_index]
	voice.seek(10.0)
	var visit = app.game.visits.get("visit_sora")
	if visit != null:
		for action in ["greet", "basic_history", "to_exam", "vitals", "limited_clothed_exam", "blood", "imaging", "to_diagnosis", "diagnose_appendix", "explain", "admit"]:
			expect(visit.apply(action), "Consultation action: " + action)
			app.show_encounter("visit_sora")
			app._process(0.0)
			expect(app.music.current_id == "triage" and app.music.players[app.music.active_index] == voice and voice.get_playback_position() >= 9.9, "Consultation and admission summary do not restart music: " + action)
	for screen in ["examination_cg", "referral", "save_slots"]:
		app.screen = screen
		app.music.play_track(app.music.track_for(app))
		expect(app.music.current_id == "triage" and app.music.players[app.music.active_index] == voice, "Examination/referral/menu music continuity: " + screen)
	app.show_map(false)
	app._process(0.0)
	expect(app.music.current_id == "spring", "Leaving consultation restores seasonal map music")
	app.show_location("clinic", true, false, false)
	app._process(0.0)
	expect(app.music.current_id == "spring", "Clinic location browsing remains seasonal")
	app.game.reset()

func check_location_event_music(app) -> void:
	app.show_location("station", true, false, false)
	app._process(0.0)
	expect(app.screen == "location" and app.music.current_id == "station", "Nurses station location uses dedicated music")
	await create_timer(0.1).timeout
	var voice: AudioStreamPlayer = app.music.players[app.music.active_index]
	voice.seek(10.0)
	var definition: Dictionary = app.game.character_event_definitions["intro_nurse_yui"].duplicate(true)
	var event = preload("res://godot/systems/character_event_session.gd").new(definition)
	app.game.active_character_event_id = str(definition.id)
	app.game.character_events[definition.id] = event
	app.show_character_event()
	app._process(0.0)
	expect(app.music.current_id == "station" and app.music.players[app.music.active_index] == voice and voice.get_playback_position() >= 9.9, "Real station event inherits music without restart")
	app.music.overrides.events[definition.id] = "lounge"
	expect(app.music.track_for(app) == "lounge", "Event override beats location")
	app.music.overrides.nodes[str(definition.id) + "/" + str(event.node_id)] = ""
	expect(app.music.track_for(app) == "", "Explicit node silence beats event override and fallback")
	app.music.overrides = {"events": {}, "nodes": {}, "bgm_keys": {"test_key": "roof"}}
	var key_override: Dictionary = app.music.event_override({"bgm_key": "test_key"})
	expect(key_override.found and key_override.track == "roof", "Bound authored BGM key resolves")
	expect(not app.music.event_override({"bgm_key": "unbound"}).found, "Unbound authored key allows location fallback")
	app.music.overrides = {"events": {}, "nodes": {}, "bgm_keys": {}}
	app.music.overrides.nodes = {"same/chapter1/start": "station", "same/chapter2/start": "roof"}
	expect(app.music.event_override({"event_id": "same", "step_id": "chapter1", "node_id": "start"}).track == "station", "Step-qualified override resolves first chapter")
	expect(app.music.event_override({"event_id": "same", "step_id": "chapter2", "node_id": "start"}).track == "roof", "Repeated node IDs in different chapters remain independent")
	app.music.overrides.nodes.clear()
	# Only alter isolated runtime fixture data, never author files.
	for bg in ["staff_lounge", "rooftop", "clinic", "unknown_background"]:
		event.nodes[event.node_id]["background_id"] = bg
		app.show_character_event()
		var expected := "lounge" if bg == "staff_lounge" else "roof" if bg == "rooftop" else "spring"
		expect(app.music.track_for(app) == expected, "Event follows current scene instead of entry station: " + bg)
	for screen in ["micro_event", "special_event", "special_gallery_replay", "daydream_playback", "time_event_result", "megumin_event"]:
		app.screen = screen
		app.base("Music test", "", false, "nurses_station")
		expect(app.music.track_for(app) == "station", "Shared fallback covers event surface: " + screen)
	app.screen = "character_event"
	app.base("Music test", "", false, "unknown_background")
	for pair in [[1, "spring"], [62, "summer"], [154, "autumn"], [245, "winter"]]:
		app.game.set_test_time(int(pair[0]), 540)
		expect(app.music.track_for(app) == str(pair[1]), "Unknown event location follows calendar season")
	expect(Music.valid_overrides(app.music.overrides), "Empty override contract valid")
	expect(not Music.valid_overrides({"events": {"bad": "missing_track"}, "nodes": {}, "bgm_keys": {}}), "Unregistered override track rejected")
	app.game.reset()
	app.show_map(false)
