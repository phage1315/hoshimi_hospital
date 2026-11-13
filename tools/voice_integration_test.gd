extends SceneTree
var failures := 0
var checks := 0

class AdvSessionStub extends RefCounted:
	var team_intro_index := -1
	var crisis := false
	func in_crisis() -> bool:
		return crisis

func expect(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	var prefix := "/private/tmp/hoshimi-voice-%s" % Time.get_ticks_usec()
	app.saves.path = prefix + "-slot.json"
	app.title_preferences_path = prefix + "-preferences.cfg"
	app.title_notice_enabled = false
	root.add_child(app)
	await process_frame
	app.set_process(false)

	expect(AudioServer.get_bus_index("Voice") >= 0, "Dedicated Voice bus created")
	expect(app.voice.player.bus == "Voice", "Voice player uses dedicated Voice bus")
	expect(app.voice.VOICE_ACTORS.size() == 31, "All 31 voiced characters registered")
	expect(app.voice.SURGICAL_ACTORS.size() == 27, "All 27 surgical voiced characters registered")
	expect(app.voice.CLIPS.size() == 376, "All 376 voice clips registered (329 base + 20 Sayaka audit/story cues + 27 Sayaka H Runner full-scream cues)")
	expect(app.voice.valid_cue_manifest(app.voice.VOICE_CUE_MANIFEST, app.voice.CLIPS), "event_voice_cues.json manifest structure and clip references valid")
	for clip_id in app.voice.CLIPS.keys():
		var stream = load(app.voice.CLIPS[clip_id]) as AudioStreamWAV
		expect(stream != null and stream.get_length() > 0.5, "Voice resource loads: " + str(clip_id))
	var sayaka_neutral_stream := load(app.voice.CLIPS["doc_sayaka_neutral"]) as AudioStreamWAV
	expect(sayaka_neutral_stream != null and sayaka_neutral_stream.get_length() < 2.8, "Sayaka neutral.wav trailing noise defect fixed (<2.8s)")

	# 1. Opening greeting (zh_CN & en)
	for locale in ["zh_CN", "en"]:
		app.content.load_all(locale)
		app.configure_game_content()
		app.session.start(app.content.dialogue)
		app.screen = "dialogue"
		app.voice.sync(app)
		var before: int = app.voice.play_count
		app.session.current_id = "aoi_welcome"
		app.voice.sync(app)
		expect(app.voice.play_count == before + 1 and app.voice.last_played_clip == "doc_aoi_greeting", "Opening greeting " + locale)
		expect(app.voice.player.playing, "Greeting player started")
		app.voice.sync(app)
		expect(app.voice.play_count == before + 1, "Redraw does not repeat")
		app.session.current_id = "aoi_advice"
		app.voice.sync(app)
		expect(not app.voice.player.playing, "Next node stops speech")

	app.content.load_all("zh_CN")
	app.configure_game_content()
	for staff_id in ["doc_aoi", "doc_rei", "doc_shiori", "nurse_hiroko", "pharmacist_manami"]:
		app.game.relation_for(staff_id)["met"] = true

	# 2. Staff profile view: morning greeting, afternoon greeting, outfit silence, expression mapping across doctors/nurses/pharmacist
	var count_before: int = app.voice.play_count
	app.show_staff("doc_aoi", "clinic", "neutral", "white_coat")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_aoi_greeting", "Morning staff profile greeting (<11:00)")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1, "Staff profile redraw does not repeat")

	# Outfit switch stays silent
	count_before = app.voice.play_count
	app.show_staff("doc_aoi", "clinic", "neutral", "scrubs")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before, "Outfit switch does not trigger voice")
	app.show_staff("doc_aoi", "clinic", "focused", "scrubs")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_aoi_serious", "Scrubs focused expression -> serious clip")
	app.show_staff("doc_aoi", "clinic", "warm", "scrubs")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == "doc_aoi_smile", "Scrubs warm expression -> smile clip")

	app.show_staff("doc_aoi", "clinic", "neutral", "white_coat")
	app.voice.sync(app)
	var expected_expr_map := {
		"smile": "doc_aoi_smile",
		"serious": "doc_aoi_serious",
		"worried": "doc_aoi_worried",
		"tired": "doc_aoi_tired",
		"surprised": "doc_aoi_surprised",
		"neutral": "doc_aoi_neutral",
	}
	for expr in ["smile", "serious", "worried", "tired", "surprised", "neutral"]:
		var prev_c: int = app.voice.play_count
		app.show_staff("doc_aoi", "clinic", expr, "white_coat")
		app.voice.sync(app)
		expect(app.voice.play_count == prev_c + 1 and app.voice.last_played_clip == expected_expr_map[expr], "White coat expression voice: " + expr)

	# Other voiced staff also trigger their own morning greeting & expression clips
	count_before = app.voice.play_count
	app.show_staff("doc_rei", "clinic", "neutral", "white_coat")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_rei_greeting", "Miyama morning greeting")
	app.show_staff("doc_rei", "clinic", "smile", "white_coat")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == "doc_rei_smile", "Miyama smile expression clip")

	# Afternoon re-entry -> otsukaresama across Narumi, Hiroko, and Manami
	app.game.advance_story_to_day(app.game.day_number(), 13 * 60) # 09:00 -> 13:00
	count_before = app.voice.play_count
	app.show_staff("doc_aoi", "lounge", "neutral", "white_coat")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_aoi_otsukaresama", "Afternoon staff profile greeting (>=11:00)")

	count_before = app.voice.play_count
	app.show_staff("nurse_hiroko", "ward", "neutral", "uniform")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "nurse_hiroko_otsukaresama", "Hiroko afternoon greeting")
	app.show_staff("nurse_hiroko", "ward", "closed_eye_smile", "uniform")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == "nurse_hiroko_smile", "Hiroko closed_eye_smile -> smile clip")

	count_before = app.voice.play_count
	app.show_staff("pharmacist_manami", "pharmacy", "neutral", "pharmacist")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "pharmacist_manami_otsukaresama", "Manami afternoon greeting")
	app.show_staff("pharmacist_manami", "pharmacy", "pharm_bright", "pharmacist")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == "pharmacist_manami_smile", "Manami pharm_bright -> smile clip")
	app.show_staff("pharmacist_manami", "pharmacy", "pharm_surprised", "pharmacist")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 3 and app.voice.last_played_clip == "pharmacist_manami_surprised", "Manami pharm_surprised -> surprised clip")

	app.show_map(false)
	app.voice.sync(app)
	expect(not app.voice.player.playing, "Leaving staff profile stops voice")

	# 3. Time event chat (Narumi & another staff member)
	for target_actor in ["doc_aoi", "doc_rei"]:
		var chat_id := ""
		var chat_loc := ""
		for hour in [9, 10, 11, 12, 13, 14, 15]:
			app.game.advance_story_to_day(app.game.day_number(), hour * 60)
			for candidate_loc in ["clinic", "lounge", "rooftop", "ward"]:
				for te in app.game.time_events_at(candidate_loc):
					if str(te.get("actor_id", "")) == target_actor and target_actor in app.game.staff_present_at(candidate_loc):
						chat_id = str(te.id)
						chat_loc = candidate_loc
						break
				if not chat_id.is_empty():
					break
			if not chat_id.is_empty():
				break
		expect(not chat_id.is_empty(), "Located active time-event chat for " + target_actor)
		count_before = app.voice.play_count
		expect(app.game.spend_time(chat_id), "Perform chat with %s: %s" % [target_actor, app.game.last_error])
		app.show_time_event_result(chat_id, chat_loc, false)
		app.voice.sync(app)
		expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip in [target_actor + "_smile", target_actor + "_neutral"], "Time-event chat triggers voice for " + target_actor)
		app.voice.sync(app)
		expect(app.voice.play_count == count_before + 1, "Chat redraw does not repeat for " + target_actor)
		app.game.advance_story_to_future_day(1, 9 * 60)

	# 4. After-work walk offer & acceptance across characters
	for walk_actor in ["doc_aoi", "nurse_hiroko"]:
		app.game.active_after_work_walk = {"actor_id": walk_actor, "workday": app.game.day_number(), "departure_clock": 1080, "variant": "normal", "phase": "offer"}
		count_before = app.voice.play_count
		app.show_after_work_walk()
		app.voice.sync(app)
		expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == walk_actor + "_otsukaresama", "After-work walk offer triggers otsukaresama for " + walk_actor)
		app.game.active_after_work_walk = {"actor_id": walk_actor, "workday": app.game.day_number(), "departure_clock": 1080, "variant": "normal", "phase": "result", "outcome": "completed", "reward": 2}
		app.show_after_work_walk()
		app.voice.sync(app)
		expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == walk_actor + "_smile", "After-work walk acceptance triggers smile for " + walk_actor)
		app.game.active_after_work_walk = {}

	# 5. Sunday date acceptance & satisfaction across characters
	while not app.game.is_sunday():
		app.game.advance_story_to_future_day(1, 9 * 60)
	for date_actor in ["doc_aoi", "doc_shiori"]:
		var rel: Dictionary = app.game.relation_for(date_actor)
		rel["level"] = 1
		rel["familiarity"] = 20
		rel["affection"] = 20
		for _try in range(15):
			if app.game.can_start_regular_sunday_date(date_actor):
				break
			app.game.advance_story_to_future_day(7, 9 * 60)
		count_before = app.voice.play_count
		app.show_sunday_date_acceptance(date_actor)
		app.voice.sync(app)
		expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == date_actor + "_neutral", "Sunday date acceptance triggers neutral for " + date_actor)
		app.begin_sunday_date(date_actor, "cafe")
		app.voice.sync(app)
		expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == date_actor + "_smile", "Sunday date completion triggers smile for " + date_actor)
		if date_actor == "doc_aoi":
			app.game.advance_story_to_future_day(7, 9 * 60)

	# 6. Ordinary Preop & Operating Room (team confirm, full 3-role timeout chain, intraoperative caution/clear, crisis alert/clear, abort)
	var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/patients/templates/preop.json"))
	for staff_id in ["doc_rei", "doc_aoi"]:
		var prep = preload("res://godot/systems/preop_session.gd").new(definition.duplicate(true), app.content.collections.staff)
		prep.stage_id = "team"
		prep.team = {"assistant_surgeon": staff_id, "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_yui"}
		app.game.preops["voice_fixture"] = prep
		app.game.active_preop_id = "voice_fixture"
		app.screen = "preop"
		var before_team: int = app.voice.play_count
		app.voice.sync(app)
		expect(app.voice.play_count == before_team, "No voice merely for team selection")
		expect(prep.apply({"kind": "action", "id": "confirm_team"}), "Confirm team applies: " + prep.last_error)
		app.voice.sync(app)
		expect(app.voice.play_count == before_team + 1 and app.voice.last_played_clip == staff_id + "_serious", "Team confirm speaks serious clip for " + staff_id)

		prep.stage_id = "team_confirmations"
		prep.flags.assign(["team_checked"])
		var before_to: int = app.voice.play_count
		app.voice.sync(app)
		expect(app.voice.play_count == before_to, "No voice merely for entering team_confirmations")

		expect(prep.apply({"kind": "action", "id": "confirm_assistant_role"}), "Assistant timeout applies: " + prep.last_error)
		app.voice.sync(app)
		expect(app.voice.play_count == before_to + 1 and app.voice.last_played_clip == staff_id + "_timeout", "Assistant speaks timeout clip: " + staff_id)
		app.voice.sync(app)
		expect(app.voice.play_count == before_to + 1, "No replay after refresh")

		expect(prep.apply({"kind": "action", "id": "confirm_scrub_role"}), "Scrub nurse timeout applies: " + prep.last_error)
		app.voice.sync(app)
		expect(app.voice.play_count == before_to + 2 and app.voice.last_played_clip == "nurse_haru_timeout", "Scrub nurse speaks timeout clip")

		expect(prep.apply({"kind": "action", "id": "confirm_circulating_role"}), "Circulating nurse timeout applies: " + prep.last_error)
		app.voice.sync(app)
		expect(app.voice.play_count == before_to + 3 and app.voice.last_played_clip == "nurse_yui_timeout", "Circulating nurse speaks timeout clip on transition to procedure_select")

		app.screen = "map"
		app.voice.sync(app)
		expect(not app.voice.player.playing, "Leaving scene stops voice")

	# Intraoperative flow caution, clear across roles, crisis alert, crisis resolution, and abort
	var or_prep = preload("res://godot/systems/preop_session.gd").new(definition.duplicate(true), app.content.collections.staff)
	or_prep.team = {"assistant_surgeon": "doc_rei", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_yui"}
	or_prep.stage_id = "procedure_flow"
	or_prep.feedback_speaker = "staff"
	or_prep.last_staff_id = "doc_rei"
	or_prep.last_staff_role = "assistant_surgeon"
	or_prep.awaiting_flow_acknowledgement = true
	or_prep.pending_flow_retry = true
	or_prep.procedure_corrections = 1
	or_prep.event_count = 10
	app.game.preops["or_voice_fixture"] = or_prep
	app.game.active_preop_id = "or_voice_fixture"
	app.screen = "preop"
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_rei_or_caution", "Intraoperative assistant correction -> doc_rei_or_caution")

	or_prep.pending_flow_retry = false
	or_prep.event_count = 11
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == "doc_rei_or_clear", "Intraoperative assistant step clear -> doc_rei_or_clear")

	or_prep.last_staff_id = "nurse_haru"
	or_prep.last_staff_role = "scrub_nurse"
	or_prep.event_count = 12
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 3 and app.voice.last_played_clip == "nurse_haru_or_clear", "Intraoperative scrub step clear -> nurse_haru_or_clear")

	or_prep.awaiting_flow_acknowledgement = false
	or_prep.last_staff_id = "nurse_yui"
	or_prep.last_staff_role = "circulating_nurse"
	or_prep.active_crisis = {"severity": "routine", "attempt": 1, "speaker_actor_id": "nurse_yui"}
	or_prep.awaiting_crisis_acknowledgement = false
	or_prep.event_count = 13
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 4 and app.voice.last_played_clip == "nurse_yui_or_caution", "Intraoperative circulating crisis alert -> nurse_yui_or_caution")

	or_prep.last_staff_id = "doc_rei"
	or_prep.awaiting_crisis_acknowledgement = true
	or_prep.event_count = 14
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 5 and app.voice.last_played_clip == "doc_rei_or_clear", "Intraoperative crisis stabilized -> doc_rei_or_clear")

	or_prep.active_crisis.clear()
	or_prep.awaiting_crisis_acknowledgement = false
	or_prep.surgery_aborted = true
	or_prep.stage_id = "surgery_abort"
	or_prep.event_count = 15
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 6 and app.voice.last_played_clip == "doc_rei_tired", "Aborted surgery -> doc_rei_tired sigh")
	app.game.preops.erase("or_voice_fixture")
	app.game.preops.erase("voice_fixture")
	app.game.active_preop_id = ""

	# 7. Advanced surgery full 7-role timeout roll-call & crisis alert
	var adv_controller = preload("res://godot/systems/advanced_referral.gd").new(app.game, true)
	var adv_session := AdvSessionStub.new()
	var adv_team := {
		"first_assistant": "doc_aoi",
		"second_assistant": "doc_rei",
		"primary_scrub": "nurse_haru",
		"secondary_scrub": "nurse_hiroko",
		"primary_circulating": "nurse_yui",
		"secondary_circulating": "nurse_rin",
		"anesthesia": "doc_sakura_anesthesiology",
	}
	adv_controller.state().appointment = {"team": adv_team}
	adv_controller.session = adv_session
	app.advanced_controller = adv_controller
	app.screen = "advanced_referral"
	for role_idx in range(adv_controller.ROLES.size()):
		var role_name := str(adv_controller.ROLES[role_idx])
		var expected_member := str(adv_team[role_name])
		count_before = app.voice.play_count
		adv_session.team_intro_index = role_idx
		app.voice.sync(app)
		expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == expected_member + "_timeout", "Advanced role intro %s -> %s_timeout" % [role_name, expected_member])

	adv_session.team_intro_index = -1
	adv_session.crisis = true
	count_before = app.voice.play_count
	var cast_stub := Control.new()
	cast_stub.name = "AdvancedCast"
	cast_stub.set_meta("actor_id", "doc_sakura_anesthesiology")
	cast_stub.set_meta("source_text", "Anesthesia crisis line 1")
	app.page.add_child(cast_stub)
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sakura_anesthesiology_or_caution", "Advanced crisis spoken by Sakura triggers doc_sakura_anesthesiology_or_caution")
	app.advanced_controller = null

	# 8. Smooth BGM ducking (attack / anti-pumping hold / release / immediate exit) & quiet-voice loudness trim
	app.voice.set_process(false)
	var voice_bus := AudioServer.get_bus_index("Voice")
	expect(voice_bus >= 0 and app.voice.voice_limiter != null and is_equal_approx(app.voice.voice_limiter.ceiling_db, app.voice.VOICE_LIMITER_CEILING_DB), "Voice bus has dedicated -0.5 dBFS AudioEffectHardLimiter peak protection")
	var bgm_bus := AudioServer.get_bus_index("BGM")
	expect(bgm_bus >= 0 and app.voice.bgm_ducker != null, "BGM bus has dedicated voice_bgm_ducker AudioEffectAmplify")
	app.music.set_volume(0.8)
	var user_bgm_bus_db := AudioServer.get_bus_volume_db(bgm_bus)
	expect(is_equal_approx(user_bgm_bus_db, linear_to_db(0.8) + app.music.BGM_MASTER_TRIM_DB), "BGM bus applies -4.5 dB master headroom trim while keeping slider ratio intact")
	app.voice.player.stop()
	app.voice.bgm_duck_db = 0.0
	app.voice.duck_hold_remaining = 0.0
	app.voice.step_ducking(0.0)
	expect(is_equal_approx(app.voice.bgm_ducker.volume_db, 0.0), "BGM ducker rests at 0.0 dB when idle")

	app.game.relation_for("nurse_yoneda_shiori")["met"] = true
	app.game.relation_for("doc_emiko")["met"] = true
	app.game.advance_story_to_day(app.game.day_number(), 9 * 60)
	app.show_staff("nurse_yoneda_shiori", "ward", "neutral", "uniform")
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "nurse_yoneda_shiori_greeting" and app.voice.player.playing, "Yoneda Shiori morning greeting starts playing")
	expect(app.voice.player.volume_db > 12.0 and app.voice.player.volume_db <= app.voice.MAX_VOICE_BOOST_DB, "Soft-spoken Yoneda clip receives strong active-RMS gain boost: %s dB" % app.voice.player.volume_db)

	app.voice.step_ducking(0.04)
	expect(app.voice.bgm_ducker.volume_db < -3.0 and app.voice.bgm_ducker.volume_db > app.voice.BGM_DUCK_DB, "Attack halfway at 0.04s dips smoothly")
	app.voice.step_ducking(0.05)
	expect(is_equal_approx(app.voice.bgm_ducker.volume_db, app.voice.BGM_DUCK_DB), "Attack reaches full -9.5 dB at 0.08s")
	expect(is_equal_approx(AudioServer.get_bus_volume_db(bgm_bus), user_bgm_bus_db), "User BGM volume slider bus dB untouched by ducking")

	# Natural finish -> 0.28s hold keeps BGM steady (prevents pumping across consecutive barks), then 0.50s smooth release
	app.voice.player.stop()
	app.voice.step_ducking(0.18)
	expect(is_equal_approx(app.voice.bgm_ducker.volume_db, app.voice.BGM_DUCK_DB), "Hold window (0.18s < 0.28s) keeps BGM steady without pumping")
	app.voice.step_ducking(0.10) # finishes remaining 0.10s hold
	app.voice.step_ducking(0.25) # halfway through 0.50s release
	expect(app.voice.bgm_ducker.volume_db > app.voice.BGM_DUCK_DB and app.voice.bgm_ducker.volume_db < -1.0, "Release halfway at 0.25s restores smoothly")
	app.voice.step_ducking(0.30)
	expect(is_equal_approx(app.voice.bgm_ducker.volume_db, 0.0), "Release completes cleanly back to 0.0 dB")

	# High-peak clip controlled RMS leveling & immediate release when leaving scene mid-speech
	app.show_staff("doc_emiko", "clinic", "neutral", "white_coat")
	app.voice.sync(app)
	app.show_staff("doc_emiko", "clinic", "smile", "white_coat")
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_emiko_smile" and app.voice.player.volume_db > 0.0 and app.voice.player.volume_db < 4.0, "High-peak Emiko clip receives controlled modest RMS gain (< 4.0 dB, limiter-protected): %s dB" % app.voice.player.volume_db)
	app.voice.step_ducking(0.10)
	expect(is_equal_approx(app.voice.bgm_ducker.volume_db, app.voice.BGM_DUCK_DB), "Ducked during Emiko speech")
	app.show_map(false)
	app.voice.sync(app)
	expect(app.voice.duck_hold_remaining == 0.0, "Leaving page cancels hold immediately")
	app.voice.step_ducking(0.15)
	expect(app.voice.bgm_ducker.volume_db > app.voice.BGM_DUCK_DB, "Immediate smooth release begins right after leaving page")
	app.voice.step_ducking(0.40)
	expect(is_equal_approx(app.voice.bgm_ducker.volume_db, 0.0), "Returned to 0.0 dB after scene exit")
	expect(is_equal_approx(AudioServer.get_bus_volume_db(bgm_bus), user_bgm_bus_db), "User BGM volume slider bus dB still identical after full cycle")

	# 9. Sayaka voice audit: persona shy/teasing overrides, Free H booking response, favorite date spots, and Story Key-Line Cues
	app.game.relation_for("doc_sayaka")["met"] = true
	app.show_staff("doc_sayaka", "clinic", "neutral", "white_coat")
	app.voice.sync(app)
	count_before = app.voice.play_count
	app.show_staff("doc_sayaka", "clinic", "shy", "white_coat")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_shy" and app.voice.player.volume_db > 7.0, "Sayaka shy expression -> dedicated doc_sayaka_shy with >7 dB (>2.2x) loudness boost")
	app.show_staff("doc_sayaka", "clinic", "teasing", "white_coat")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == "doc_sayaka_teasing", "Sayaka teasing expression -> dedicated doc_sayaka_teasing")

	# Free H booking acceptance screen (dedicated Sayaka clip + generic smile fallback for other voiced actors)
	app.game.free_h_booking = {"actor_id": "doc_sayaka", "day": app.game.day_number(), "source_location": "clinic"}
	app.show_free_h_booking_response("doc_sayaka", "hotel", "clinic")
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_free_h_accept", "Sayaka Free H booking response -> doc_sayaka_free_h_accept")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1, "Free H booking response redraw does not repeat")

	app.game.free_h_booking = {"actor_id": "doc_aoi", "day": app.game.day_number(), "source_location": "clinic"}
	app.show_free_h_booking_response("doc_aoi", "hotel", "clinic")
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_aoi_smile", "Voiced actor without dedicated free_h_accept falls back to _smile")
	app.game.free_h_booking = {}

	# Favorite Sunday date spots for Sayaka (seaside promenade & Italian trattoria vs non-favorite fallback)
	var sayaka_rel: Dictionary = app.game.relation_for("doc_sayaka")
	sayaka_rel["level"] = 1
	sayaka_rel["familiarity"] = 20
	sayaka_rel["flags"] = ["sayaka_phone_exchanged", "sayaka_sunday_invite_available"]
	app.game.advance_story_to_future_day(7, 9 * 60)
	while not app.game.is_sunday():
		app.game.advance_story_to_future_day(1, 9 * 60)
	for _try in range(15):
		if app.game.can_start_regular_sunday_date("doc_sayaka"):
			break
		app.game.advance_story_to_future_day(7, 9 * 60)
	app.show_sunday_date_acceptance("doc_sayaka")
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_neutral", "Sayaka Sunday date accepted -> doc_sayaka_neutral")
	count_before = app.voice.play_count
	app.begin_sunday_date("doc_sayaka", "seaside_promenade")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_date_seaside", "Sayaka seaside date -> doc_sayaka_date_seaside")
	count_before = app.voice.play_count
	app.begin_sunday_date("doc_sayaka", "restaurant_bar")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_date_trattoria", "Sayaka Italian trattoria date -> doc_sayaka_date_trattoria")
	count_before = app.voice.play_count
	app.begin_sunday_date("doc_sayaka", "cafe")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_smile", "Sayaka non-favorite date venue -> doc_sayaka_smile fallback")

	# Validate every mapped node in event_voice_cues.json exists in authored character_events or special_events
	for cue_key in app.voice.EVENT_NODE_CUES.keys():
		var parts := str(cue_key).split("/")
		var node_exists := false
		if parts.size() == 2:
			var ev_def: Dictionary = app.game.character_event_definitions.get(parts[0], {})
			for n in ev_def.get("nodes", []):
				if str(n.get("id", "")) == parts[1]:
					node_exists = true
					break
		elif parts.size() == 3:
			var sp_def: Dictionary = app.game.special_event_definitions.get(parts[0], {})
			var chain: Array = sp_def.get("event_chain", [])
			if chain.has(parts[1]):
				var st_def: Dictionary = app.game.special_event_step_definitions.get(parts[1], {})
				for n in st_def.get("nodes", []):
					if str(n.get("id", "")) == parts[2]:
						node_exists = true
						break
		expect(node_exists, "Authored event node exists for voice cue: " + str(cue_key))

	# Live character_event playback + multi-page continuity + node advance cutoff + Gallery Replay
	var CharEvent = preload("res://godot/systems/character_event_session.gd")
	var lv3_session = CharEvent.new(app.game.character_event_definitions["sayaka_lv3_relationship"].duplicate(true))
	app.game.character_events["sayaka_lv3_relationship"] = lv3_session
	app.game.active_character_event_id = "sayaka_lv3_relationship"
	app.screen = "character_event"
	app.dialogue_page_index = 0
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before, "Unbound character_event opening node stays silent")

	lv3_session.node_id = "lv3_v2_316"
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_ev_lv3_approved" and app.voice.player.playing, "Lv3 confession approval node triggers doc_sayaka_ev_lv3_approved")
	app.dialogue_page_index = 1
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.player.playing, "Advancing to page 2 of same node keeps voice playing without re-triggering")
	app.dialogue_page_index = 0
	lv3_session.node_id = "lv3_v2_317"
	app.voice.sync(app)
	expect(not app.voice.player.playing, "Advancing to next unbound node stops speech cleanly")

	lv3_session.node_id = "lv3_v2_351"
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_ev_lv3_kiss_forgot", "Lv3 post-kiss node triggers doc_sayaka_ev_lv3_kiss_forgot")
	lv3_session.node_id = "lv3_v2_359"
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == "doc_sayaka_ev_lv3_boyfriend_walk", "Lv3 boyfriend walk-home node triggers doc_sayaka_ev_lv3_boyfriend_walk")

	# Lv4 script-normalized event & Gallery Replay
	var lv4_session = CharEvent.new(app.game.character_event_definitions["sayaka_lv4_hotel_date"].duplicate(true))
	lv4_session.node_id = "s10_103"
	app.game.character_events["sayaka_lv4_hotel_date"] = lv4_session
	app.game.active_character_event_id = "sayaka_lv4_hotel_date"
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_ev_lv4_morning_love", "Lv4 morning-after node s10_103 triggers doc_sayaka_ev_lv4_morning_love")

	app.game.character_events.erase("sayaka_lv3_relationship")
	app.game.character_events.erase("sayaka_lv4_hotel_date")
	app.game.active_character_event_id = ""
	app.gallery_replay_event = CharEvent.new(app.game.character_event_definitions["sayaka_lv1_first_date"].duplicate(true))
	app.gallery_replay_event.node_id = "v2_591"
	app.screen = "gallery_replay"
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_ev_lv1_split_bill", "Gallery Replay triggers Lv1 CG split-bill cue")
	app.gallery_replay_event.node_id = "v2_611"
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == "doc_sayaka_ev_lv1_other_things", "Gallery Replay triggers Lv1 punchline cue")
	app.gallery_replay_event = null

	# SpecialEventSession (Lv5 Part A live & Lv5 Part B special_gallery_replay)
	var SpecEvent = preload("res://godot/systems/special_event_session.gd")
	var lv5a = SpecEvent.new(app.game.special_event_definitions["sayaka_lv5_part_a"].duplicate(true), app.game.special_event_step_definitions, 1)
	expect(lv5a.jump_to("a01_0004"), "Jump to Sayaka Lv5 Part A title line a01_0004")
	app.game.active_special_event = lv5a
	app.screen = "special_event"
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_ev_lv5_nobody_here", "Special event Lv5 Part A a01_0004 triggers doc_sayaka_ev_lv5_nobody_here")
	app.game.active_special_event = null

	var lv5b = SpecEvent.new(app.game.special_event_definitions["sayaka_lv5_part_b"].duplicate(true), app.game.special_event_step_definitions, 1)
	expect(lv5b.jump_to("b01_0007"), "Jump to Sayaka Lv5 Part B consent line b01_0007")
	app.special_event_gallery_replay = lv5b
	app.screen = "special_gallery_replay"
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_ev_lv5_consent_signed", "Special gallery replay Lv5 Part B b01_0007 triggers doc_sayaka_ev_lv5_consent_signed")
	expect(lv5b.jump_to("b08_0047"), "Jump to Sayaka Lv5 Part B climax gratitude line b08_0047")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == "doc_sayaka_ev_lv5_thank_you_surgery", "Special gallery replay Lv5 Part B b08_0047 triggers doc_sayaka_ev_lv5_thank_you_surgery")
	app.special_event_gallery_replay = null

	# 10. Sayaka H Runner POC full lifecycle (Free H / Test flow + Lv4 Milestone handoff flow)
	app.game.active_free_h_departure.clear()
	app.begin_sayaka_h_profile_test("hotel", "")
	expect(app.screen == "h_profile_test_entry" and app.h_profile_test_session != null, "Sayaka H Runner starts at hotel entry")
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip in ["doc_sayaka_h_entry_1", "doc_sayaka_h_entry_2"], "Hotel entry 0 plays matching entry whisper")
	while app.screen == "h_profile_test_entry":
		var prev_count: int = app.voice.play_count
		app._advance_sayaka_h_entry()
		app.voice.sync(app)
		if app.screen == "h_profile_test_entry":
			expect(app.voice.play_count == prev_count + 1 and app.voice.last_played_clip == "doc_sayaka_h_entry_2", "Hotel entry 1 plays second entry line")
	expect(app.screen == "h_profile_test" and app.h_profile_test_session.phase == "foreplay", "Entered foreplay phase")
	expect(not app.voice.player.playing, "Entry speech stopped cleanly upon entering foreplay idle")

	# Foreplay tiers: low, mild, strong, favorite + alternating _1/_2 + action button switch non-interruption
	app.h_profile_test_last_result = app.h_profile_test_session.perform("lick", "cheeks") # low
	app.show_sayaka_h_profile_test()
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_h_tier_low_1" and app.voice.player.playing, "Foreplay low hit #1 -> doc_sayaka_h_tier_low_1")
	app._select_sayaka_h_action("kiss")
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.player.playing, "Switching action button does not cut off or replay foreplay voice")

	app.h_profile_test_last_result = app.h_profile_test_session.perform("lick", "cheeks") # low #2
	app.show_sayaka_h_profile_test()
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == "doc_sayaka_h_tier_low_2", "Foreplay low hit #2 alternates -> doc_sayaka_h_tier_low_2")

	app.h_profile_test_last_result = app.h_profile_test_session.perform("caress", "navel") # mild #1
	app.show_sayaka_h_profile_test()
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_tier_mild_1", "Foreplay mild hit #1 -> doc_sayaka_h_tier_mild_1")

	app.h_profile_test_last_result = app.h_profile_test_session.perform("caress", "breasts") # strong #1
	app.show_sayaka_h_profile_test()
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_tier_strong_1", "Foreplay strong hit #1 -> doc_sayaka_h_tier_strong_1")

	app.h_profile_test_last_result = app.h_profile_test_session.perform("kiss", "lips") # favorite #1
	app.show_sayaka_h_profile_test()
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_tier_favorite_1", "Foreplay favorite hit #1 -> doc_sayaka_h_tier_favorite_1")

	app.h_profile_test_last_result = app.h_profile_test_session.perform("kiss", "neck") # favorite #2
	app.show_sayaka_h_profile_test()
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_tier_favorite_2", "Foreplay favorite hit #2 alternates -> doc_sayaka_h_tier_favorite_2")

	# Excitement reaching 100 triggers h_max_prompt
	app.h_profile_test_session.excitement = 90
	app.h_profile_test_last_result = app.h_profile_test_session.perform("kiss", "lips") # hits 100 -> show_max_prompt = true
	app.h_profile_test_max_prompt_visible = bool(app.h_profile_test_last_result.get("show_max_prompt", false))
	app.show_sayaka_h_profile_test()
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_max_prompt", "Excitement 100 triggers doc_sayaka_h_max_prompt")

	# Gentle opening + 100% 6/6 escalating h_stage beats + finish wait/4-way scream response + aftercare transition guard & 2 aftercare lines
	app._choose_sayaka_h_entry_style("gentle")
	app.voice.sync(app)
	var gentle_open_db: float = app.voice.player.volume_db
	expect(app.voice.last_played_clip == "doc_sayaka_h_open_gentle", "Gentle style opening -> doc_sayaka_h_open_gentle")
	app._advance_sayaka_h_stage() # index 1
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_stage_start_1" and app.voice.player.playing, "H stage index 1 -> doc_sayaka_h_stage_start_1")
	app._advance_sayaka_h_stage() # index 2
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_stage_start_2" and app.voice.player.playing, "H stage index 2 -> doc_sayaka_h_stage_start_2")
	app._advance_sayaka_h_stage() # index 3 (gentle midpoint)
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_stage_mid_1", "Gentle midpoint (index 3) -> doc_sayaka_h_stage_mid_1")
	app._advance_sayaka_h_stage() # index 4 (escalating build scream)
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_stage_build_1", "Escalating build (index 4) -> doc_sayaka_h_stage_build_1")
	app._advance_sayaka_h_stage() # index 5 (final pre-climax scream)
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_stage_near_1", "Pre-finish scream (index 5) -> doc_sayaka_h_stage_near_1")
	app._advance_sayaka_h_stage() # enters h_finish_wait
	app.voice.sync(app)
	expect(app.h_profile_test_session.phase == "h_finish_wait" and not app.voice.player.playing, "Finish button wait stops previous voice cleanly")
	app._choose_sayaka_h_finish()
	app.voice.sync(app)
	expect(app.h_profile_test_session.phase == "h_finish_response" and app.voice.last_played_clip in ["doc_sayaka_h_finish_1", "doc_sayaka_h_finish_2", "doc_sayaka_h_finish_3", "doc_sayaka_h_finish_4"] and app.voice.player.playing, "Climax finish response plays full-throated high-pitched scream")
	expect(gentle_open_db != 0.0 or app.voice.player.volume_db != 0.0, "Dynamic RMS tiering active across whisper and scream clips")

	# Simulate transition guard (session.phase == after_cg BEFORE HProfileAftercareAdvance is rendered)
	app.h_profile_test_session.advance_h_stage()
	expect(app.h_profile_test_session.phase == "after_cg", "Session entered after_cg before page rebuild")
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before and not app.voice.player.playing, "White-flash transition waits until aftercare UI is mounted")
	app.h_profile_test_aftercare_index = 0
	app.show_sayaka_h_profile_test()
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_h_aftercare_1", "Aftercare line 0 -> doc_sayaka_h_aftercare_1")
	app._advance_sayaka_h_aftercare()
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 2 and app.voice.last_played_clip == "doc_sayaka_h_aftercare_2", "Aftercare line 1 -> doc_sayaka_h_aftercare_2")
	app._advance_sayaka_h_aftercare()
	app.voice.sync(app)
	expect(app.h_profile_test_session == null and not app.voice.player.playing, "Completing H Runner stops aftercare voice cleanly")

	# Lv4 Milestone Handoff mode: intense opening scream + lv4_ready on index 1 + protagonist silence on index 2 + doctor line on index 3 + intense midpoint scream on index 6
	app.begin_sayaka_h_profile_test("hotel", "sayaka_lv4_first_h")
	expect(app.h_profile_event_mode and app.h_profile_test_session != null, "Lv4 milestone H Runner started")
	app.h_profile_test_session.excitement = 100
	app._choose_sayaka_h_entry_style("intense")
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_open_intense", "Intense style opening -> doc_sayaka_h_open_intense scream")
	app._advance_sayaka_h_stage() # index 1 (Sayaka overlay 0 -> lv4_ready!)
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_lv4_ready" and app.voice.player.playing, "Lv4 overlay index 1 -> doc_sayaka_h_lv4_ready")
	app._advance_sayaka_h_stage() # index 2 (Protagonist overlay 1!)
	count_before = app.voice.play_count
	app.voice.sync(app)
	expect(app.voice.play_count == count_before and not app.voice.player.playing, "Protagonist line (index 2 in Lv4 event mode) stays strictly silent")
	app._advance_sayaka_h_stage() # index 3 (Sayaka doctor line!)
	app.voice.sync(app)
	expect(app.voice.play_count == count_before + 1 and app.voice.last_played_clip == "doc_sayaka_h_lv4_doctor_ok", "Lv4 overlay index 3 triggers doc_sayaka_h_lv4_doctor_ok")
	app._advance_sayaka_h_stage() # index 4
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_stage_start_1", "Lv4 shifted start 1 (index 4) -> doc_sayaka_h_stage_start_1")
	app._advance_sayaka_h_stage() # index 5
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_stage_start_2", "Lv4 shifted start 2 (index 5) -> doc_sayaka_h_stage_start_2")
	app._advance_sayaka_h_stage() # index 6 (shifted intense midpoint scream!)
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_mid_intense", "Lv4 shifted intense midpoint (index 6) -> doc_sayaka_h_mid_intense scream")
	app._advance_sayaka_h_stage() # index 7
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_stage_build_1", "Lv4 shifted build (index 7) -> doc_sayaka_h_stage_build_1")
	app._advance_sayaka_h_stage() # index 8 (shifted pre-finish)
	app.voice.sync(app)
	expect(app.voice.last_played_clip == "doc_sayaka_h_stage_near_1", "Lv4 shifted pre-finish (index 8) -> doc_sayaka_h_stage_near_1")
	app._exit_sayaka_h_test()
	app.voice.sync(app)

	# 11. Save boundary purity check (no voice playback, cue, H-runner, or ducking state in BoundarySave v37)
	app.show_sunday_menu()
	var saved_json := JSON.stringify(app.game.snapshot())
	expect(not saved_json.contains("_otsukaresama") and not saved_json.contains("voice_staff") and not saved_json.contains("last_played_clip") and not saved_json.contains("bgm_duck") and not saved_json.contains("event_cue") and not saved_json.contains("ev_lv") and not saved_json.contains("h_tier_") and not saved_json.contains("h_finish"), "Boundary save snapshot contains zero voice, cue, H-runner, or ducking state")

	app.queue_free()
	await process_frame
	print("Voice integration: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)
