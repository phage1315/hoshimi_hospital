extends SceneTree

var checks := 0
var failures := 0
var continuations := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func continued() -> void:
	continuations += 1

func wait_real(seconds: float) -> void:
	var until := Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < until:
		await process_frame
	await process_frame

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Content load: " + locale)
		app.configure_game_content()
		app.game.reset()
		for pool_id in ["blood_draw", "abdominal_ultrasound", "ct_scan", "mri_scan", "endoscopy_preparation", "gynecology_preparation"]:
			app.show_encounter("visit_sora")
			var original_page: Control = app.page
			var before_elapsed: int = app.game.elapsed()
			var before_count := continuations
			app.show_examination_cg(pool_id, continued)
			var overlay: Control = app.page.get_node_or_null("ExaminationSplash")
			expect(overlay != null and app.page == original_page, locale + "/" + pool_id + ": retained clinic missing")
			if overlay == null:
				continue
			expect(overlay.mouse_filter == Control.MOUSE_FILTER_STOP, "Splash must block underlying mouse input")
			var cg := overlay.find_child("ExaminationCG", true, false) as TextureRect
			var frame := overlay.find_child("ExaminationSplashFrame", true, false) as Panel
			var button := overlay.find_child("ExaminationCGContinue", true, false) as Button
			expect(cg != null and cg.texture != null and cg.size == Vector2(800, 450), "Non-fullscreen texture missing")
			expect(frame.position.x > 0 and frame.position.y > 0 and frame.position + frame.size == Vector2(1060, 705), "Panel margins changed")
			expect(button.text == app.tx("ui.auto.dbc7e5ecc8d6", "查看结果  →"), "Localized continue label missing")
			expect(button.disabled, "Close enabled before minimum exposure")
			button.pressed.emit()
			app.choose_clinic_action("greet")
			expect(continuations == before_count and app.game.elapsed() == before_elapsed, "Early click advanced flow")
			var wait_started := Time.get_ticks_msec()
			await wait_real(0.25)
			expect((button.disabled or Time.get_ticks_msec() - wait_started >= 500) and continuations == before_count, "Closed before half a second")
			await wait_real(0.35)
			expect(not button.disabled and continuations == before_count and overlay.is_inside_tree(), "Unlock should not auto-dismiss")
			if pool_id == "blood_draw":
				await wait_real(1.6)
				expect(overlay.is_inside_tree() and continuations == before_count, "Old two-second auto-dismiss is still active")
			button.pressed.emit()
			button.pressed.emit()
			expect(continuations == before_count + 1 and app.screen == "encounter", "Continuation must run exactly once")
			expect(app.page.get_node_or_null("ExaminationSplash") == null, "Overlay not detached")
			expect(app.game.elapsed() == before_elapsed, "Splash must not consume game time")
			await process_frame
		app.show_examination_cg("blood_draw", continued)
		var keyboard_before := continuations
		var enter := InputEventKey.new()
		enter.keycode = KEY_ENTER
		enter.pressed = true
		app._input(enter)
		expect(continuations == keyboard_before, "Keyboard bypassed half-second lock")
		await wait_real(0.65)
		app._input(enter)
		expect(continuations == keyboard_before + 1 and app.page.get_node_or_null("ExaminationSplash") == null, "Keyboard continuation failed")
		# A page replacement must cancel the old overlay without delayed navigation.
		app.show_examination_cg("blood_draw", continued)
		app.show_map()
		var count_before_cancel := continuations
		await wait_real(0.65)
		expect(app.screen == "map" and continuations == count_before_cancel, "Stale overlay callback navigated")
		# Patient-authored CG still uses the original fullscreen presentation.
		app.show_examination_cg("full_undress_basic_exam_patient_miki", continued)
		expect(app.page.get_node_or_null("ExaminationSplash") == null, "Patient CG was changed to splash")
		var authored_cg := app.page.get_node_or_null("ExaminationCG") as TextureRect
		var authored_button := app.page.get_node_or_null("ExaminationCGContinue") as Button
		expect(authored_cg != null and authored_cg.anchor_right == 1.0 and authored_cg.anchor_bottom == 1.0, "Patient CG no longer fullscreen")
		expect(authored_button != null and not authored_button.disabled, "Patient CG inherited the new delay")
		if authored_button != null:
			authored_button.pressed.emit()
		app.show_encounter("visit_sora")
		app.show_examination_cg("blood_draw", continued)
		var count_before_old_timer := continuations
		await wait_real(2.1)
		expect(app.page.get_node_or_null("ExaminationSplash") != null and continuations == count_before_old_timer, "Old fullscreen timer dismissed a newer splash")
		app.show_map()
		# Execute real clinic actions through their callback chain, not just UI mocks.
		app.game.reset()
		app.show_encounter("visit_sora")
		for action_id in ["greet", "basic_history", "to_exam", "vitals", "request_full_undress", "gentle_full_undress", "blood", "imaging", "to_diagnosis", "diagnose_appendix", "explain", "admit"]:
			var action_button := app.page.get_node_or_null("Action_" + action_id) as Button
			expect(action_button != null and not action_button.disabled, locale + ": clinic action missing " + action_id)
			if action_button == null:
				break
			action_button.pressed.emit()
			if app.screen == "examination_cg":
				var button := app.page.find_child("ExaminationCGContinue", true, false) as Button
				expect(button != null, "Clinic action CG continuation missing")
				if button != null:
					if button.disabled:
						await wait_real(0.65)
					button.pressed.emit()
			expect(app.screen != "examination_cg", "Clinic continuation stuck at " + action_id)
			await process_frame
		expect(app.game.admitted_patient("patient_sora"), "Clinic flow failed to admit patient")
	await process_frame
	app.queue_free()
	await process_frame
	print("EXAMINATION SPLASH: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures else 0)
