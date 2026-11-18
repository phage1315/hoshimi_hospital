extends SceneTree
const Registry = preload("res://godot/systems/free_h_registry.gd")
const Session = preload("res://godot/systems/h_profile_v1_session.gd")
var checks := 0
var failures := 0
var cjk := RegEx.new()

func expect(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(note)

func _initialize() -> void: call_deferred("run")

func english(text: String, note: String) -> void:
	expect(not text.is_empty() and cjk.search(text) == null, note)

func pools(profile: Dictionary) -> Dictionary:
	var result := {"max_prompt":[profile.flow.max_prompt], "finish.labels":profile.flow.finish_button_labels, "finish.responses":profile.flow.finish_response_pool, "aftercare":profile.flow.free_aftercare_lines}
	for style in ["gentle","intense"]:
		result["style.opening."+style] = [profile.flow.openings[style]]
		result["style.midpoint."+style] = [profile.flow.midpoints[style]]
	for section in ["start","middle","finish"]: result["scene."+section] = profile.scene[section]
	return result

func run() -> void:
	cjk.compile("[\\x{3400}-\\x{9fff}]")
	var app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/sayaka_phase2_unused_%s.json" % OS.get_process_id()
	app.title_preferences_path = "/private/tmp/sayaka_phase2_prefs_%s.cfg" % OS.get_process_id()
	app.title_notice_enabled = false
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale), "Load locale " + locale)
		app.configure_game_content()
		var bundle: Dictionary = Registry.load_bundle("doc_sayaka",locale)
		expect(not bundle.has("error"), "Load production bundle " + locale)
		if bundle.has("error"): continue
		var defaults := pools(bundle.profile)
		# All supported context layers, including reserve pools not drawn today.
		for location in ["hotel","ward","operating_room","gyne_exam","clinic","home"]:
			for event in ["","sayaka_lv4_first_h"]:
				var session = Session.new("doc_sayaka",bundle.profile,location,event,locale)
				for key in defaults:
					var actual: Array = session.dialogue_pool(key,defaults[key])
					expect(actual.size() == defaults[key].size(), "Pool length/order contract " + key)
					if locale == "zh_CN": expect(actual == defaults[key], "Chinese source preserved " + key)
					else:
						for line in actual: english(str(line), "English pool " + key)
		# Actual UI route for ordinary repeats, direct previews and Lv4 handoff.
		for mode in ["free","test","milestone"]:
			for style in ["gentle","intense"]:
				app.h_profile_run_kind = mode
				var event: String = "sayaka_lv4_first_h" if mode == "milestone" else ""
				var fresh: Dictionary = Registry.load_bundle("doc_sayaka",locale) if mode == "free" else {}
				expect(app._begin_h_profile_session("hotel",event,fresh), "Start " + mode)
				var session = app.h_profile_test_session
				session.excitement = 100
				app._choose_sayaka_h_entry_style(style)
				expect(session.phase == "h_stage", "Enter second stage " + style)
				var count := 0
				while session.phase == "h_stage" and count < 12:
					var label: Label = app.page.get_node("HProfileDialogueText")
					expect(label.text == session.current_h_scene_line(), "UI displays resolved text")
					if locale == "en": english(label.text,"English phase2 UI " + mode + "/" + style)
					app._advance_sayaka_h_stage()
					count += 1
				await process_frame
				expect(count == (9 if mode == "milestone" else 6) and session.phase == "h_finish_wait", "Original line count and manual completion retained")
				var button: Button = app.page.get_node("HProfileFinish")
				if locale == "en": english(button.text,"English finish button")
				app._choose_sayaka_h_finish()
				expect(session.phase == "h_finish_response" and not session.h_event_completed, "Response requires acknowledgement")
				if locale == "en": english(app.page.get_node("HProfileDialogueText").text,"English finish response")
				# Advance the session directly to avoid testing the unrelated CG tween.
				expect(session.advance_h_stage(), "Acknowledge response")
				if mode == "milestone": continue # Authored event aftercare belongs to its separate event test.
				app.h_profile_test_aftercare_index = 0
				app.show_sayaka_h_profile_test()
				if locale == "en": english(app.page.get_node("HProfileDialogueText").text,"English aftercare UI")
	app.queue_free()
	await process_frame
	print("SAYAKA PHASE2 LOCALIZATION: %d checks; %d failures" % [checks,failures])
	quit(1 if failures else 0)
