extends SceneTree
## Visible native-window production-path E2E QA for Artoria Pendragon (`doc_artoria`) Free H (`home`).
## All preconditions are isolated in memory; GUI actions use `Window.push_input`
## and zero player or test saves are written.

const Registry = preload("res://godot/systems/free_h_registry.gd")
const Session = preload("res://godot/systems/h_profile_v1_session.gd")
const CharacterEvent = preload("res://godot/systems/character_event_session.gd")
const SceneContext = preload("res://godot/systems/scene_content_context.gd")

const UVS := {
	"lips": Vector2(0.487, 0.229),
	"cheeks": Vector2(0.415, 0.210),
	"neck": Vector2(0.488, 0.290),
	"nipples": Vector2(0.318, 0.412),
	"breasts": Vector2(0.390, 0.395),
	"navel": Vector2(0.487, 0.632),
	"torso_other": Vector2(0.480, 0.520),
	"genitals": Vector2(0.472, 0.855),
	"thighs": Vector2(0.265, 0.780),
}

var app
var checks := 0
var failures := 0
var input_events := 0
var cjk_re := RegEx.new()

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	cjk_re.compile("[\\x{4E00}-\\x{9FFF}]")
	call_deferred("run")

func permanent() -> Dictionary:
	var result := {}
	for key in ["relationships", "story_flags", "surgery_xp", "leadership_xp", "archived_player_effects", "special_event_completion_counts", "special_event_completion_days"]:
		var value: Variant = app.game.get(key)
		result[key] = value.duplicate(true) if value is Dictionary or value is Array else value
	return result

func viewport_point(design_point: Vector2) -> Vector2:
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
	expect(node.texture.resource_path == "res://assets/h/doc_artoria/portrait_" + expression + ".png", "Correct Artoria portrait " + expression)
	expect(node.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Portrait preserves aspect " + expression)

func click_zone(action: String, zone: String, locale: String) -> void:
	await gui_click(action_button(action, locale))
	expect(app.h_profile_test_action == action, "GUI selected action " + action)
	var body = app.page.get_node_or_null("HProfileBodyMap") as TextureRect
	expect(body != null and body.texture != null, "Body map visible for " + zone)
	if body == null or body.texture == null:
		return
	var image_rect: Rect2 = SceneContext.image_rect(body.get_global_rect(), body.texture.get_size())
	var point: Vector2 = image_rect.position + Vector2(UVS[zone]) * image_rect.size
	await gui_click_point(point)
	expect(app.h_profile_test_last_result.get("accepted", false), "GUI body click accepted for " + zone)
	expect(app.h_profile_test_last_result.get("zone") == zone, "GUI body click routes to " + zone)
	if locale == "en":
		expect(cjk_re.search(str(app.h_profile_test_last_result.get("line", ""))) == null, "en: zero CJK in reaction line for " + action + ":" + zone)

func install_completed_lv4(locale: String) -> void:
	app.game.meet_staff("doc_artoria")
	var relation: Dictionary = app.game.relation_for("doc_artoria")
	relation.level = 4
	relation.familiarity = 60
	relation.unlocked_benefits = ["unlock_intimacy_events"]
	expect(not app.game.free_h_unlocked("doc_artoria"), locale + ": level 4 without completed Lv4 event/flag stays locked")
	var definition: Dictionary = app.game.character_event_definitions["artoria_lv4_just_artoria"]
	var event = CharacterEvent.new(definition)
	event.node_id = str(definition.nodes[-1].id)
	event.completed = true
	event.completed_day = 13
	app.game.character_events["artoria_lv4_just_artoria"] = event
	app.game.character_event_order.append("artoria_lv4_just_artoria")
	expect(not app.game.free_h_unlocked("doc_artoria"), locale + ": completed event without artoria_lv4_complete flag stays locked")
	app.game.set_story_flag("artoria_lv4_complete", true)

func source_location_for_actor() -> String:
	for location in app.content.collections.locations:
		if "doc_artoria" in app.game.staff_present_at(str(location.id)):
			return str(location.id)
	return ""

func run_locale(locale: String) -> void:
	app.game.reset()
	expect(app.content.load_all(locale), "Load content " + locale)
	app.configure_game_content()
	app.show_map(false)
	install_completed_lv4(locale)
	expect(app.game.free_h_unlocked("doc_artoria"), locale + ": real Lv4 completion + artoria_lv4_complete unlocks Free H")

	var source_location := ""
	for candidate_day in range(14, 21):
		app.game.advance_story_to_day(candidate_day, 9 * 60)
		if app.game.is_hospital_closed_day():
			continue
		source_location = source_location_for_actor()
		if not source_location.is_empty() and not app.game.free_h_known_conflict():
			break
	expect(not source_location.is_empty(), locale + ": locate Artoria through production presence resolver")
	expect(not app.game.free_h_known_conflict(), locale + ": no departure conflict on booking day")
	if source_location.is_empty() or app.game.free_h_known_conflict():
		return

	var bundle := Registry.load_bundle("doc_artoria", locale)
	expect(not bundle.has("error"), "Production bundle " + locale + ": " + str(bundle.get("error", "")))
	if bundle.has("error"):
		return
	var before := permanent()

	app.show_staff("doc_artoria", source_location)
	var booking = app.page.get_node_or_null("FreeHBooking")
	expect(booking != null, locale + ": formal personnel menu has FreeHBooking button")
	if booking == null:
		return
	await gui_click(booking)
	expect(app.game.free_h_booking.get("actor_id") == "doc_artoria", locale + ": invitation books doc_artoria")
	expect(app.page.get_node_or_null("FreeHLocationPicker") == null, locale + ": fixed home skips location picker")
	expect(app.page.get_node_or_null("FreeHBookingResponse") != null, locale + ": authored booking response visible")
	expect(app._free_h_place_label("doc_artoria", "home") == ("Artoria's Apartment" if locale == "en" else "阿尔托莉雅自宅"), locale + ": booking location names Artoria's Apartment / 阿尔托莉雅自宅")
	var booking_response = app.page.get_node_or_null("FreeHBookingResponse")
	if booking_response != null:
		var want_resp := "...I have no late duties tonight. If you're free after hours, come to my place, Dr. Sakaguchi... I'll have tea waiting." if locale == "en" else "……今晚我没有排班。下班后如果方便，来我家里吧，坂口医生……我泡好红茶等你。"
		expect(str(booking_response.text) == want_resp, locale + ": booking dialogue uses authored verbatim response")
	await gui_click(app.page.get_node_or_null("FreeHBookingResponseContinue"))
	app.show_map(false)
	expect(app.game.can_save_progress(), locale + ": hospital boundary remains saveable while booked")

	app.game.advance_story_to_day(app.game.day_number(), 16 * 60)
	app.request_end_workday()
	await create_timer(1.2).timeout
	expect(app.h_profile_test_session != null and app.h_profile_run_kind == "free", locale + ": end-work production route launches Free H")
	if app.h_profile_test_session == null:
		return
	expect(app.h_profile_test_session.actor_id == "doc_artoria" and app.h_profile_test_session.location_id == "home", locale + ": Artoria home repeatable context")
	expect(app.h_profile_test_session.background_id("") == "artoria_home_bedroom_night", locale + ": artoria_home_bedroom_night background shown throughout session")
	expect(app.h_profile_test_entry_lines.size() == 1, locale + ": one random authored home entry line selected")
	if locale == "en":
		expect(cjk_re.search(str(app.h_profile_test_entry_lines[0])) == null, "en: zero CJK in home entry line")
	expect(not app.game.can_save_progress(), locale + ": save locked during entry")
	portrait("neutral")

	await gui_click(app.page.get_node_or_null("HProfileEntryAdvance"))
	portrait("neutral")
	var body_map = app.page.get_node_or_null("HProfileBodyMap")
	expect(body_map != null and body_map.texture != null and body_map.texture.resource_path == "res://assets/h/doc_artoria/body_map.png", locale + ": Artoria body_map.png rendered")
	if body_map == null:
		return

	var expression_paths := [
		["lick", "cheeks", "annoyed"],
		["kiss", "cheeks", "pleased"],
		["kiss", "breasts", "flustered"],
		["kiss", "lips", "delighted"],
	]
	for record in expression_paths:
		await click_zone(str(record[0]), str(record[1]), locale)
		portrait(str(record[2]))

	var saw_max_prompt := false
	for zone in Session.ZONES:
		await click_zone("lick", zone, locale)
		if app.h_profile_test_max_prompt_visible:
			saw_max_prompt = true
	while app.h_profile_test_session.excitement < 100:
		await click_zone("kiss", "lips", locale)
		if app.h_profile_test_max_prompt_visible:
			saw_max_prompt = true
	expect(app.h_profile_test_session.excitement == 100 and saw_max_prompt, locale + ": MAX reached and max_prompt shown through GUI clicks")
	portrait("peak")
	expect(app.page.get_node_or_null("HProfileStyleGentle") != null and app.page.get_node_or_null("HProfileStyleIntense") != null, locale + ": both style choices visible")
	expect(not app.game.can_save_progress(), locale + ": save locked during foreplay")

	var style := "gentle" if locale == "zh_CN" else "intense"
	await gui_click(app.page.get_node("HProfileStyleGentle" if style == "gentle" else "HProfileStyleIntense"))
	for line_index in range(6):
		var scene_tex: Texture2D = app.page.get_node("HProfileSceneImage").texture
		expect(scene_tex != null and scene_tex.resource_path == "res://assets/h/doc_artoria/scene_cg.png" and scene_tex.get_size() == Vector2(1536, 1024), locale + ": Artoria scene_cg.png rendered at line " + str(line_index))
		var expected_speaker := str(app.content.find_record("staff", "doc_artoria").get("name", ""))
		expect(not expected_speaker.is_empty() and app.page.get_node("HProfileDialogueSpeaker").text == expected_speaker, locale + ": correct stage speaker")
		var line_txt := str(app.page.get_node("HProfileDialogueText").text)
		expect(not line_txt.is_empty(), locale + ": nonblank stage dialogue")
		if locale == "en":
			expect(cjk_re.search(line_txt) == null, "en: zero CJK in stage line " + str(line_index))
		expect(not app.game.can_save_progress(), locale + ": save locked during stage")
		await gui_click(app.page.get_node("HProfileAdvance"))

	expect(app.h_profile_test_session.phase == "h_finish_wait", locale + ": manual finish wait reached")
	await gui_click(app.page.get_node("HProfileFinish"))
	expect(app.h_profile_test_session.phase == "h_finish_response", locale + ": finish response shown")
	var fin_txt := str(app.page.get_node("HProfileDialogueText").text)
	expect(not fin_txt.is_empty(), locale + ": finish response nonblank")
	if locale == "en":
		expect(cjk_re.search(fin_txt) == null, "en: zero CJK in finish response")
	await gui_click(app.page.get_node("HProfileAdvance"))
	await create_timer(4.8).timeout

	expect(app.h_profile_test_session != null and app.h_profile_test_session.phase == "after_cg", locale + ": transition reaches aftercare")
	if app.h_profile_test_session == null:
		return
	var after_tex: Texture2D = app.page.get_node("HProfileSceneImage").texture
	expect(after_tex != null and after_tex.resource_path == "res://assets/h/doc_artoria/aftercare_cg.png" and after_tex.get_size() == Vector2(1536, 1024), locale + ": Artoria aftercare_cg.png rendered")
	var expected_after_speaker := str(app.content.find_record("staff", "doc_artoria").get("name", ""))
	expect(not expected_after_speaker.is_empty() and app.page.get_node("HProfileDialogueSpeaker").text == expected_after_speaker, locale + ": correct aftercare speaker")
	var after1_txt := str(app.page.get_node("HProfileDialogueText").text)
	expect(not after1_txt.is_empty(), locale + ": aftercare line 1 nonblank")
	if locale == "en":
		expect(cjk_re.search(after1_txt) == null, "en: zero CJK in aftercare line 1")
	expect(not app.game.can_save_progress(), locale + ": save locked during aftercare")

	await gui_click(app.page.get_node_or_null("HProfileAftercareAdvance"))
	expect(not app.game.active_free_h_departure.is_empty(), locale + ": departure stays active before final aftercare line")
	var after2_txt := str(app.page.get_node("HProfileDialogueText").text)
	expect(not after2_txt.is_empty(), locale + ": aftercare line 2 nonblank")
	if locale == "en":
		expect(cjk_re.search(after2_txt) == null, "en: zero CJK in aftercare line 2")

	await gui_click(app.page.get_node_or_null("HProfileAftercareAdvance"))
	expect(app.h_profile_test_session == null and app.screen == "day_transition", locale + ": completion returns to day_transition")
	expect(app.game.free_h_booking.is_empty() and app.game.active_free_h_departure.is_empty(), locale + ": booking & departure cleared on completion")
	expect(permanent() == before, locale + ": repeatable Free H mutates zero permanent relationship/event facts")

	await gui_click(app.page.get_node_or_null("DayTransitionContinue"))
	expect(app.screen == "map" and app.game.can_save_progress(), locale + ": returned to safe saveable Hospital Guide boundary")
	expect(app.page.get_node("CalendarHeader").text.ends_with("09:00"), locale + ": next workday resumes at 09:00")

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.title_notice_enabled = false
	app.saves.path = "/private/tmp/hoshimi-artoria-free-h-unused-%d.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/hoshimi-artoria-free-h-prefs-%d.cfg" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	expect(DisplayServer.get_name() != "headless", "Visible native display server")
	for locale in ["zh_CN", "en"]:
		await run_locale(locale)
	expect(not FileAccess.file_exists(app.saves.path), "No player or test save written")
	expect(input_events > 100, "Native GUI input stream exercised")
	if FileAccess.file_exists(app.title_preferences_path):
		DirAccess.remove_absolute(app.title_preferences_path)
	print("ARTORIA FREE H NATIVE E2E: ", checks, " checks; ", failures, " failures; display=", DisplayServer.get_name(), "; inputs=", input_events)
	quit(1 if failures else 0)
