extends SceneTree
## Visible native-window production-path QA. All preconditions are isolated in
## memory; GUI actions use Window.push_input and no player save is written.
const Registry = preload("res://godot/systems/free_h_registry.gd")
const Session = preload("res://godot/systems/h_profile_v1_session.gd")
const CharacterEvent = preload("res://godot/systems/character_event_session.gd")
const SceneContext = preload("res://godot/systems/scene_content_context.gd")

const OUT := "res://docs/qa/miyuki_free_h_2200_native_2026_11_02"
const IMAGE_SIZE := Vector2(1024, 1520)
const PIXELS := {
	"lips": Vector2(545, 385), "cheeks": Vector2(450, 340),
	"neck": Vector2(515, 500), "breasts": Vector2(445, 625),
	"nipples": Vector2(405, 720), "navel": Vector2(545, 1025),
	"torso_other": Vector2(530, 865), "genitals": Vector2(530, 1340),
	"thighs": Vector2(350, 1390),
}

var app
var checks := 0
var failures := 0
var captures: Array[String] = []
var input_events := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func capture(tag: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var path := OUT + "/" + tag + ".png"
	expect(root.get_texture().get_image().save_png(path) == OK, "Save rendered evidence " + tag)
	captures.append(path)

func permanent() -> Dictionary:
	var result := {}
	for key in ["relationships", "story_flags", "surgery_xp", "leadership_xp", "archived_player_effects", "special_event_completion_counts", "special_event_completion_days"]:
		var value: Variant = app.game.get(key)
		result[key] = value.duplicate(true) if value is Dictionary or value is Array else value
	return result

func viewport_point(design_point: Vector2) -> Vector2:
	# The native test window is 1280×720 while the project canvas is 1280×800.
	# Godot stretches CanvasItems; push_input expects post-stretch window pixels.
	var canvas_size: Vector2 = app.size
	var viewport_size: Vector2 = root.get_visible_rect().size
	return design_point * viewport_size / canvas_size

func gui_click(control: Control) -> void:
	expect(control != null and is_instance_valid(control) and control.is_visible_in_tree(), "GUI target is visible")
	if control == null or not is_instance_valid(control):
		return
	var point := viewport_point(control.get_global_rect().get_center())
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, true)
	await process_frame
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = point
	down.global_position = point
	root.push_input(down, true)
	await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = point
	up.global_position = point
	root.push_input(up, true)
	input_events += 3
	await process_frame
	await process_frame

func gui_click_point(point: Vector2) -> void:
	point = viewport_point(point)
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, true)
	await process_frame
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = point
	down.global_position = point
	root.push_input(down, true)
	await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = point
	up.global_position = point
	root.push_input(up, true)
	input_events += 3
	await process_frame
	await process_frame

func button_with_text(fragment: String) -> Button:
	for child in app.page.get_children():
		if child is Button and fragment in str(child.text):
			return child
	return null

func action_button(action: String, locale: String) -> Button:
	var labels := {
		"caress": "Caress" if locale == "en" else "轻抚",
		"kiss": "Kiss" if locale == "en" else "亲吻",
		"lick": "Lick" if locale == "en" else "舔舐",
		"light_bite": "Light bite" if locale == "en" else "轻咬",
	}
	return button_with_text(labels[action])

func portrait(expression: String) -> void:
	var node = app.page.get_node_or_null("HProfileExpression")
	expect(node != null and node.texture != null, "Visible portrait " + expression)
	if node == null or node.texture == null:
		return
	expect(node.texture.resource_path == "res://assets/h/nurse_yui/portrait_" + expression + ".png", "Correct portrait " + expression)
	expect(node.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Portrait preserves aspect " + expression)

func click_zone(action: String, zone: String, locale: String) -> void:
	await gui_click(action_button(action, locale))
	expect(app.h_profile_test_action == action, "GUI selected action " + action)
	var body = app.page.get_node_or_null("HProfileBodyMap") as TextureRect
	expect(body != null and body.texture != null, "Body map visible for " + zone)
	if body == null or body.texture == null:
		return
	var image_rect: Rect2 = SceneContext.image_rect(body.get_global_rect(), body.texture.get_size())
	var point: Vector2 = image_rect.position + Vector2(PIXELS[zone]) / IMAGE_SIZE * image_rect.size
	await gui_click_point(point)
	expect(app.h_profile_test_last_result.get("accepted", false), "GUI body click accepted")
	expect(app.h_profile_test_last_result.get("zone") == zone, "GUI body click routes to " + zone)

func install_completed_lv4() -> void:
	app.game.meet_staff("nurse_yui")
	var relation: Dictionary = app.game.relation_for("nurse_yui")
	relation.level = 4
	relation.route = "romance"
	relation.unlocked_benefits = ["unlock_intimacy_events"]
	var definition: Dictionary = app.game.character_event_definitions["miyuki_lv4_inspection"]
	var event = CharacterEvent.new(definition)
	event.node_id = str(definition.nodes[-1].id)
	event.completed = true
	event.completed_day = 7
	app.game.character_events["miyuki_lv4_inspection"] = event
	app.game.character_event_order.append("miyuki_lv4_inspection")

func source_location_for_actor() -> String:
	for location in app.content.collections.locations:
		if "nurse_yui" in app.game.staff_present_at(str(location.id)):
			return str(location.id)
	return ""

func run_locale(locale: String) -> void:
	app.game.reset()
	expect(app.content.load_all(locale), "Load content " + locale)
	app.configure_game_content()
	app.show_map(false)
	install_completed_lv4()
	expect(app.game.free_h_unlocked("nurse_yui"), "Real Lv4 completion fact unlocks route")
	var source_location := ""
	for candidate_day in range(8, 13):
		app.game.advance_story_to_day(candidate_day, 9 * 60)
		if app.game.is_hospital_closed_day():
			continue
		source_location = source_location_for_actor()
		if not source_location.is_empty() and not app.game.free_h_known_conflict():
			break
	expect(not source_location.is_empty(), "Locate Miyuki through production presence resolver")
	expect(not app.game.free_h_known_conflict(), "No unrelated departure story blocks fixture")
	if source_location.is_empty() or app.game.free_h_known_conflict():
		return
	var bundle := Registry.load_bundle("nurse_yui", locale)
	expect(not bundle.has("error"), "Production bundle " + locale + ": " + str(bundle.get("error", "")))
	if bundle.has("error"):
		return
	var before := permanent()

	app.show_staff("nurse_yui", source_location)
	var booking = app.page.get_node_or_null("FreeHBooking")
	expect(booking != null, "Formal personnel menu has Free H invitation")
	await capture(locale + "_01_personnel_invitation")
	if booking == null:
		return
	await gui_click(booking)
	expect(app.game.free_h_booking.get("actor_id") == "nurse_yui", "Invitation books Miyuki")
	expect(app.page.get_node_or_null("FreeHLocationPicker") == null, "Fixed private clinic skips location picker")
	expect(app.page.get_node_or_null("FreeHBookingResponse") != null, "Authored booking response visible")
	expect(app._free_h_place_label("nurse_yui", "clinic") == ("Hoshimi Hospital Consultation Room" if locale == "en" else "星见医院诊疗室"), "Booking location names hospital room")
	var booking_response = app.page.get_node_or_null("FreeHBookingResponse")
	if booking_response != null:
		expect(str(booking_response.text) == ("Tonight, how about your consultation room? I want to play your patient ❤️" if locale == "en" else "今晚呀，不如就去你的诊疗室嘛，想当一下你的患者 ❤️"), "Booking dialogue uses authored bilingual response")
	await capture(locale + "_02_booking_response")
	await gui_click(app.page.get_node_or_null("FreeHBookingResponseContinue"))
	app.show_map(false)
	expect(app.game.can_save_progress(), "Hospital boundary remains saveable")
	app.game.advance_story_to_day(app.game.day_number(), 16 * 60)
	app.request_end_workday()
	await create_timer(1.2).timeout
	expect(app.h_profile_test_session != null and app.h_profile_run_kind == "free", "End-work production route launches Free H")
	if app.h_profile_test_session == null:
		return
	expect(app.h_profile_test_session.actor_id == "nurse_yui" and app.h_profile_test_session.location_id == "clinic", "Miyuki hospital consultation-room repeatable context")
	expect(app.h_profile_test_session.background_id("") == "miyuki_hospital_clinic_night", "Hospital night consultation room shown throughout session")
	expect(app.page.get_node("CalendarHeader").text.ends_with("22:00"), "Miyuki night scene displays 22:00")
	expect(app.game.current_absolute_clock() == 16 * 60, "Presentation clock does not change settled workday time")
	expect(app.h_profile_test_entry_lines.size() == 1, "One authored entry selected")
	expect(not app.game.can_save_progress(), "No save during entry")
	portrait("neutral")
	await capture(locale + "_03_entry_neutral")
	await gui_click(app.page.get_node_or_null("HProfileEntryAdvance"))
	portrait("neutral")
	var body_map = app.page.get_node_or_null("HProfileBodyMap")
	expect(body_map != null and body_map.texture.resource_path == "res://assets/h/nurse_yui/body_map.png", "Own body map rendered")
	if body_map == null:
		return
	await capture(locale + "_04_bodymap_neutral")

	var expression_paths := [
		["lick", "cheeks", "annoyed"],
		["light_bite", "breasts", "pleased"],
		["kiss", "breasts", "flustered"],
		["caress", "cheeks", "delighted"],
	]
	for record in expression_paths:
		await click_zone(str(record[0]), str(record[1]), locale)
		portrait(str(record[2]))
		await capture(locale + "_05_" + str(record[2]))
	for zone in Session.ZONES:
		await click_zone("light_bite", zone, locale)
	while app.h_profile_test_session.excitement < 100:
		await click_zone("caress", "cheeks", locale)
	expect(app.h_profile_test_session.excitement == 100 and app.h_profile_test_max_prompt_visible, "MAX reached once through GUI clicks")
	portrait("peak")
	expect(app.page.get_node_or_null("HProfileStyleGentle") != null and app.page.get_node_or_null("HProfileStyleIntense") != null, "Both style choices visible")
	expect(not app.game.can_save_progress(), "No save during interaction")
	await capture(locale + "_06_peak_max")

	var style := "gentle" if locale == "zh_CN" else "intense"
	await gui_click(app.page.get_node("HProfileStyleGentle" if style == "gentle" else "HProfileStyleIntense"))
	for line_index in range(6):
		expect(app.page.get_node("HProfileSceneImage").texture.resource_path == "res://assets/h/nurse_yui/scene_cg.png", "Own stage CG line " + str(line_index))
		var expected_speaker := str(app.content.find_record("staff", "nurse_yui").get("name", ""))
		expect(not expected_speaker.is_empty() and app.page.get_node("HProfileDialogueSpeaker").text == expected_speaker, "Correct stage speaker")
		expect(not str(app.page.get_node("HProfileDialogueText").text).is_empty(), "Nonblank stage dialogue")
		expect(not app.game.can_save_progress(), "No save during stage")
		if line_index == 0:
			await capture(locale + "_07_stage_" + style)
		await gui_click(app.page.get_node("HProfileAdvance"))
	expect(app.h_profile_test_session.phase == "h_finish_wait", "Manual finish wait reached")
	await capture(locale + "_08_manual_finish")
	await gui_click(app.page.get_node("HProfileFinish"))
	expect(app.h_profile_test_session.phase == "h_finish_response", "One final response shown")
	expect(not str(app.page.get_node("HProfileDialogueText").text).is_empty(), "Finish response is nonblank")
	await capture(locale + "_09_finish_response")
	await gui_click(app.page.get_node("HProfileAdvance"))
	await create_timer(4.8).timeout
	expect(app.h_profile_test_session != null and app.h_profile_test_session.phase == "after_cg", "Transition reaches aftercare")
	if app.h_profile_test_session == null:
		return
	expect(app.page.get_node("HProfileSceneImage").texture.resource_path == "res://assets/h/nurse_yui/aftercare_cg.png", "Own aftercare CG")
	expect(app.page.get_node("CalendarHeader").text.ends_with("22:00"), "Night scene clock remains 22:00 through aftercare")
	var expected_aftercare_speaker := str(app.content.find_record("staff", "nurse_yui").get("name", ""))
	expect(not expected_aftercare_speaker.is_empty() and app.page.get_node("HProfileDialogueSpeaker").text == expected_aftercare_speaker, "Correct aftercare speaker")
	expect(not app.game.can_save_progress(), "No save during aftercare")
	await capture(locale + "_10_aftercare_1")
	await gui_click(app.page.get_node_or_null("HProfileAftercareAdvance"))
	expect(not app.game.active_free_h_departure.is_empty(), "Departure remains active before final aftercare line")
	await capture(locale + "_11_aftercare_2")
	await gui_click(app.page.get_node_or_null("HProfileAftercareAdvance"))
	expect(app.h_profile_test_session == null and app.screen == "day_transition", "Completion returns to day transition")
	expect(app.game.free_h_booking.is_empty() and app.game.active_free_h_departure.is_empty(), "Booking cleared only after completion")
	expect(permanent() == before, "Repeatable route changes no permanent relationship or event facts")
	await capture(locale + "_12_day_transition")
	await gui_click(app.page.get_node_or_null("DayTransitionContinue"))
	expect(app.screen == "map" and app.game.can_save_progress(), "Return to safe hospital boundary")
	expect(app.page.get_node("CalendarHeader").text.ends_with("09:00"), "Next day resumes at 09:00")
	await capture(locale + "_13_return_safe_boundary")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/hoshimi-miyuki-free-h-unused-%d.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	expect(DisplayServer.get_name() != "headless", "Visible native display server")
	for locale in ["zh_CN", "en"]:
		await run_locale(locale)
	expect(not FileAccess.file_exists(app.saves.path), "No player or test save written")
	expect(input_events > 100, "Native GUI input stream exercised")
	var report := {
		"checks": checks, "failures": failures, "display_server": DisplayServer.get_name(),
		"captures": captures, "input_events": input_events, "player_saves_written": false,
		"locales": ["zh_CN", "en"], "styles": ["gentle", "intense"],
		"fixture": "in-memory completed miyuki_lv4_inspection plus authored intimacy qualification",
		"input_method": "Window.push_input mouse motion and button events",
	}
	var file := FileAccess.open(OUT + "/results.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("MIYUKI FREE H NATIVE E2E: ", checks, " checks; ", failures, " failures; display=", DisplayServer.get_name(), "; inputs=", input_events)
	quit(1 if failures else 0)
