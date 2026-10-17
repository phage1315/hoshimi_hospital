extends SceneTree

const AppScene = preload("res://godot/scenes/main.tscn")
const HProfileSession = preload("res://godot/systems/h_profile_v1_session.gd")
const HProfileContent = preload("res://godot/systems/h_profile_v1_content.gd")

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("_run_ui_flow")

func _run_ui_flow() -> void:
	var app := AppScene.instantiate() as Control
	root.add_child(app)
	await process_frame
	expect(app.screen == "title", "Main scene did not initialize into the title screen")
	var event_test_entry := app.page.get_node_or_null("EventTestHubEntry") as Button
	expect(event_test_entry != null, "The debug title screen does not expose the Event Test Hub")
	var initial_elapsed: int = app.game.elapsed()
	var initial_day: int = app.game.day_number()
	if event_test_entry != null:
		event_test_entry.pressed.emit()
	expect(app.screen == "event_test_hub", "The Event Test Hub did not open from the title screen")
	var h_test_entry := app.page.get_node_or_null("HProfileTestEntry") as Button
	expect(h_test_entry != null, "The Event Test Hub does not expose the Sayaka repeatable H-profile test entry")
	if h_test_entry != null:
		h_test_entry.pressed.emit()
	expect(app.screen == "h_profile_test_entry" and app.h_profile_test_session.phase == "foreplay", "The normal H test did not begin with the authored hotel-entry lines")
	expect(app.h_profile_test_entry_lines == ["……嗯，门关好了？过来呀。", "哈……你怎么反而有点紧张啦？"], "Hotel-entry dialogue does not match the authored V1.3.2 profile")
	app._advance_sayaka_h_entry()
	app._advance_sayaka_h_entry()
	expect(app.screen == "h_profile_test" and app.h_profile_test_session.excitement == 0, "Hotel entry did not lead into a fresh foreplay session")
	var hotel_background := app.page.get_node_or_null("SceneBackground") as TextureRect
	expect(hotel_background != null and hotel_background.texture.resource_path.ends_with("hotel_room_night_v2.png"), "Foreplay screen is not using the hotel-room background")
	expect(app.page.get_node_or_null("HProfileBodyMap") != null, "Foreplay body map is not present")
	expect((app.page.get_node("HProfileBodyMap") as TextureRect).texture != null, "Foreplay body-map image failed to load")
	var idle_portrait := app.page.get_node_or_null("HProfileExpression") as TextureRect
	expect(idle_portrait != null and idle_portrait.texture is AtlasTexture, "Idle expression is not rendered from the atlas")
	if idle_portrait != null and idle_portrait.texture is AtlasTexture:
		expect((idle_portrait.texture as AtlasTexture).region == Rect2(1019, 0, 510, 500), "Idle portrait is not the approved top-right cell")

	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	var body_map := app.page.get_node("HProfileBodyMap") as TextureRect
	click.position = Vector2(body_map.size.x * 0.35, body_map.size.y * 0.455)
	var touches := 0
	app._on_sayaka_h_bodymap_input(click)
	touches += 1
	expect(app.h_profile_test_last_result.get("zone", "") == "nipples", "Body-map UV tap did not resolve the intended nipple hotspot")
	expect(not str(app.h_profile_test_last_result.get("line", "")).is_empty(), "Foreplay interaction produced no authored response dialogue")
	expect(app.h_profile_test_last_result.get("expression", "") == "flustered", "Strong-preference touch did not select the mapped expression")
	while app.h_profile_test_session.excitement < 100 and touches < 20:
		app._on_sayaka_h_bodymap_input(click)
		touches += 1
	expect(touches < 20 and app.h_profile_test_session.excitement == 100 and app.h_profile_test_session.phase == "foreplay", "MAX did not remain in phase one for an explicit entry choice")
	expect(app.h_profile_test_max_prompt_visible and app.h_profile_test_session.profile.flow.max_prompt == "啊啊……别、别再逗我了……过来呀……再近一点嘛……", "MAX prompt did not show the authored one-time line")
	expect(app.page.get_node_or_null("HProfileStyleGentle") != null and app.page.get_node_or_null("HProfileStyleIntense") != null, "MAX screen does not expose both entry-style choices")
	app._on_sayaka_h_bodymap_input(click)
	touches += 1
	expect(app.h_profile_test_session.phase == "foreplay" and not app.h_profile_test_max_prompt_visible, "Phase one could not continue after showing MAX prompt")
	var gentle_button := app.page.get_node_or_null("HProfileStyleGentle") as Button
	if gentle_button != null:
		gentle_button.pressed.emit()
	expect(app.h_profile_test_session.phase == "h_stage" and app.h_profile_test_session.h_scene_style == "gentle", "Gentle entry selection did not start phase two")
	expect(app.screen == "h_profile_test" and app.page.get_node_or_null("HProfileSceneImage") != null, "H-stage CG screen did not render")
	var phase_two_speaker := app.page.get_node_or_null("HProfileDialogueSpeaker") as Label
	expect(phase_two_speaker != null and phase_two_speaker.text == "南条小夜香", "Free H-stage dialogue is missing Sayaka's speaker name")
	hotel_background = app.page.get_node_or_null("SceneBackground") as TextureRect
	expect(hotel_background != null and hotel_background.texture.resource_path.ends_with("hotel_room_night_v2.png"), "H-stage screen did not retain the hotel-room background")
	var stage_image := app.page.get_node("HProfileSceneImage") as TextureRect
	expect(stage_image.texture != null, "H-stage CG failed to load")
	var expected_stage_lines: Array[String] = app.h_profile_test_session.h_scene_lines()
	expect(expected_stage_lines.size() == 6 and expected_stage_lines[0] == "嗯……这样、这样就好……先让我靠近一点……" and expected_stage_lines[3] == "唔……慢、慢一点……嗯，我就在这里……", "Phase-two style-specific lines are missing or misordered")
	expect(expected_stage_lines[1] != expected_stage_lines[2] and expected_stage_lines[4] != expected_stage_lines[5], "Phase-two dialogue pool repeated a line within a section")
	for expected_line in expected_stage_lines:
		expect(app.h_profile_test_session.current_h_scene_line() == expected_line, "H-stage dialogue order changed")
		app._advance_sayaka_h_stage()
	expect(app.h_profile_test_session.phase == "h_finish_wait" and not app.h_profile_test_session.h_event_completed, "H-stage did not stop at the manual finish prompt")
	var finish_button := app.page.get_node_or_null("HProfileFinish") as Button
	expect(finish_button != null and finish_button.text == app.h_profile_test_session.h_finish_label, "The stable random finish label was not shown after phase-two lines")
	if finish_button != null:
		finish_button.pressed.emit()
	expect(app.h_profile_test_session.phase == "h_finish_response" and app.h_profile_test_session.current_h_scene_line() in app.h_profile_test_session.profile.flow.finish_response_pool, "Manual finish did not show one response from its pool")
	var finish_speaker := app.page.get_node_or_null("HProfileDialogueSpeaker") as Label
	expect(finish_speaker != null and finish_speaker.text == "南条小夜香", "H-finish response is missing Sayaka's speaker name")
	var finish_response: String = app.h_profile_test_session.current_h_scene_line()
	expect(not app.h_profile_test_session.choose_h_finish() and app.h_profile_test_session.current_h_scene_line() == finish_response, "Double-clicking finish caused a second response")
	var response_continue := app.page.get_node_or_null("HProfileAdvance") as Button
	if response_continue != null:
		response_continue.pressed.emit()
	var transition_layer := app.get_node_or_null("HProfileCGTransition") as CanvasLayer
	var transition_shade := transition_layer.get_child(0) as ColorRect if transition_layer != null else null
	expect(transition_shade != null and transition_shade.material is ShaderMaterial, "The CG transition did not start with its pixelation shader")
	await create_timer(4.8).timeout
	expect(app.h_profile_test_session.phase == "after_cg" and app.h_profile_test_session.h_event_completed, "Aftercare CG did not wait for final response acknowledgement")
	expect(not app.h_profile_test_transitioning and app.get_node_or_null("HProfileCGTransition") == null, "CG fade transition did not finish and clean up its input-blocking overlay")
	var aftercare_speaker := app.page.get_node_or_null("HProfileDialogueSpeaker") as Label
	expect(aftercare_speaker != null and aftercare_speaker.text == "南条小夜香", "Free-H aftercare dialogue is missing Sayaka's speaker name")
	var after_image := app.page.get_node("HProfileSceneImage") as TextureRect
	expect(after_image.texture != null and after_image.texture.resource_path.ends_with("after_cg_v1.png"), "Aftercare CG failed to load")
	expect(not app.h_profile_test_session.profile.has("free_aftercare"), "H-profile after-CG unexpectedly plays event-layer aftercare dialogue")
	expect(app._sayaka_h_aftercare_line() == "啊……太、太舒服了……再抱我一会儿，好不好……", "Free-H external aftercare did not begin with line one")
	var en_raw_profile: Dictionary = app._read_h_profile_json("res://data/staff/doc_sayaka/h_profile_v1_3_2.json")
	var en_raw_flow: Dictionary = app._read_h_profile_json("res://data/staff/doc_sayaka/h_flow_v1_3_2.json")
	var en_finish_labels: Dictionary = app._read_h_profile_json("res://data/h_finish_button_labels_v1_3_4.json")
	var en_finish_actor: Dictionary = app._read_h_profile_json("res://data/staff/doc_sayaka/h_phase2_finish_v1_3_4.json")
	var en_context: Dictionary = app._read_h_profile_json("res://data/staff/doc_sayaka/h_context_overrides_v1.json")
	var en_profile := HProfileContent.normalize(en_raw_profile, en_raw_flow, en_finish_labels, en_finish_actor, en_context)
	var en_session = HProfileSession.new("doc_sayaka", en_profile, "hotel", "", "en")
	expect(en_session.dialogue_line("style.midpoint.intense", "fallback") == "Ah... hah... you... you really know how to wear me out...", "English intense midpoint did not use its translated line")
	app._advance_sayaka_h_aftercare()
	expect(app._sayaka_h_aftercare_line() == "别、别动……我想再这样靠着你多待一会儿……", "Free-H external aftercare line order changed")
	var completing_session: RefCounted = app.h_profile_test_session
	app._advance_sayaka_h_aftercare()
	expect(completing_session.h_event_completed, "The completed H phase did not preserve its transient completion result through aftercare")
	expect(app.screen == "event_test_hub" and app.h_profile_test_session == null, "Exiting the H-profile test did not return to the test hub")
	h_test_entry = app.page.get_node_or_null("HProfileTestEntry") as Button
	if h_test_entry != null:
		h_test_entry.pressed.emit()
	app._advance_sayaka_h_entry()
	app._advance_sayaka_h_entry()
	expect(app.screen == "h_profile_test" and app.h_profile_test_session.phase == "foreplay" and app.h_profile_test_session.excitement == 0, "The normal free-H test could not be started again as a fresh session")
	app._exit_sayaka_h_test()
	expect(app.game.elapsed() == initial_elapsed and app.game.day_number() == initial_day, "Direct H-profile test consumed game time")
	var sayaka: Dictionary = app.content.find_record("staff", "doc_sayaka")
	app.base("", "", false, "date_hotel")
	app.add_character_event_visual(sayaka, {
		"cg_path": "assets/events/character_events/sayaka/lv4_aftercare_rest_v3.png",
		"cg_portrait_overlay": true,
		"portrait_scale": 0.5,
		"expression": "smile",
	}, "h_aftercare")
	var aftercare_cg := app.page.get_node_or_null("CharacterEventCG") as TextureRect
	var aftercare_portrait := app.page.get_node_or_null("CharacterPortrait") as TextureRect
	expect(aftercare_cg != null and aftercare_cg.texture.resource_path.ends_with("lv4_aftercare_rest_v3.png"), "LV4 aftercare scene did not keep the aftercare CG behind the dialogue")
	expect(aftercare_portrait != null and aftercare_portrait.texture is AtlasTexture, "LV4 aftercare did not use Sayaka's bare-shoulder expression portrait")
	if aftercare_portrait != null:
		expect(aftercare_portrait.size.distance_to(Vector2(225, 250)) < 0.1 and is_equal_approx(aftercare_portrait.position.y + aftercare_portrait.size.y, 540.0), "LV4 aftercare portrait is not scaled and bottom-aligned above the dialogue frame")
	if aftercare_portrait != null and aftercare_portrait.texture is AtlasTexture:
		expect((aftercare_portrait.texture as AtlasTexture).region == Rect2(510, 500, 509, 500), "LV4 aftercare smile did not map to the approved delighted bare-shoulder portrait")

	print("H PROFILE V1 UI FLOW: %s checks; %s failure(s)" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
