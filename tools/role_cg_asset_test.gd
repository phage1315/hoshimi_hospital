extends SceneTree

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func check_all_rewards(app) -> void:
	var source = load("res://godot/scripts/content_loader.gd").new()
	expect(source.load_all("zh_CN"), "Chinese reference content failed to load")
	var rewards: Array = source.collections.staff_role_cg_rewards
	expect(not rewards.is_empty(), "Role CG regression has no records to check")
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), locale + ": content failed to load")
		app.configure_game_content()
		expect(app.game.staff_role_cg_definitions.size() == rewards.size(), locale + ": reward IDs collapsed or disappeared")
		for person in app.content.collections.staff:
			app.game.meet_staff(person.id)
			# Honor explicit team gates without changing unrelated relationship
			# levels (some actors have no relationship ranks at all).
			if "team_unlock_requires_lv1" in person.get("flags", []):
				app.game.relation_for(str(person.id))["level"] = 1
		var visit = app.game.open_visit("visit_sora")
		expect(visit != null, locale + ": missing admission fixture")
		if visit == null:
			continue
		visit.admitted = true
		var prep = app.game.open_preop("preop_sora")
		expect(prep != null, locale + ": missing preoperative fixture")
		if prep == null:
			continue
		for original in rewards:
			var context: String = str(locale) + ": " + str(original.id)
			var reward: Dictionary = app.game.staff_role_cg_reward_for(str(original.staff_id), str(original.role_id))
			expect(not reward.is_empty(), context + ": staff/role lookup failed")
			if reward.is_empty():
				continue
			for field in original:
				if field not in ["title", "caption"]:
					expect(reward.get(field) == original[field], context + ": technical field changed: " + str(field))
			for field in ["title", "caption"]:
				var key := "collections.staff_role_cg_rewards.%s.%s" % [original.id, field]
				if locale == "en":
					expect(app.content.localizer.strings.has(key), context + ": missing English " + field)
					expect(not str(reward.get(field, "")).is_empty() and str(reward.get(field, "")) == str(app.content.localizer.strings.get(key, "")), context + ": wrong translated " + field)
				else:
					expect(reward.get(field) == original[field], context + ": Chinese source changed")
			var path := "res://" + str(original.path)
			expect(FileAccess.file_exists(path), context + ": image missing")
			var texture = load(path) if FileAccess.file_exists(path) else null
			expect(texture is Texture2D, context + ": image failed to import/load")
			# Isolate each assignment without replaying an unrelated clinic. The
			# actual UI event handler must apply it, unlock once, and display art.
			prep.stage_id = "preparation" if str(original.role_id) == "ward_nurse" else "team"
			prep.team.clear()
			app.show_preop("preop_sora")
			var assignment := {"kind": "assign", "role": str(original.role_id), "staff_id": str(original.staff_id)}
			app.preop_event(assignment)
			expect(prep.team.get(original.role_id) == original.staff_id, context + ": assignment rejected")
			expect(app.screen == "staff_role_reward", context + ": first assignment did not show CG")
			var cg: TextureRect = app.page.get_node_or_null("StaffRoleRewardCG")
			expect(cg != null and cg.texture == texture, context + ": wrong displayed texture")
			if "--capture-new" in OS.get_cmdline_user_args() and original.staff_id in ["doc_asuka", "doc_artoria", "nurse_satsuki"]:
				await process_frame
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("/tmp/%s_%s.png" % [locale, original.id])
			expect(app.game.staff_role_cg_unlocked(str(original.id)), context + ": gallery unlock missing")
			var next_button: Button = app.page.get_node_or_null("StaffRoleRewardContinue")
			expect(next_button != null, context + ": no return to preparation")
			if next_button != null:
				next_button.pressed.emit()
				expect(app.screen == "preop", context + ": continue did not resume preparation")
			prep.team.clear()
			app.preop_event(assignment)
			expect(app.screen != "staff_role_reward", context + ": repeat assignment replayed first-time CG")
			app.show_staff_role_gallery_entry(str(original.id))
			var gallery_cg: TextureRect = app.page.get_node_or_null("StaffRoleGalleryCG")
			expect(gallery_cg != null and gallery_cg.texture == texture, context + ": gallery lost the image")
			await process_frame
		# World-state saves must keep legitimate unlocks across a locale switch.
		var snapshot: Dictionary = JSON.parse_string(JSON.stringify(app.game.snapshot()))
		expect(app.content.load_all("en" if locale == "zh_CN" else "zh_CN"), "Cross-locale content failed")
		app.configure_game_content()
		var restored: bool = app.game.restore(snapshot)
		expect(restored, "Role unlock checkpoint did not restore: " + str(app.game.last_error))
		if not restored:
			continue
		for original in rewards:
			expect(app.game.staff_role_cg_unlocked(str(original.id)), str(original.id) + ": unlock lost after cross-locale restore")
			expect(app.game.unlock_staff_role_cg(str(original.staff_id), str(original.role_id)).is_empty(), str(original.id) + ": restored unlock replayed")
	# Guard against accidental future locale entries for technical fields.
	var localizer = source.localizer
	localizer.load_locale("en")
	var original: Dictionary = rewards[0]
	var prefix := "collections.staff_role_cg_rewards." + str(original.id)
	for field in ["id", "staff_id", "role_id", "path"]:
		localizer.strings[prefix + "." + field] = "invalid translated identifier"
	var localized: Dictionary = localizer.localize_tree(original, prefix)
	for field in ["id", "staff_id", "role_id", "path"]:
		expect(localized[field] == original[field], "Technical role field accepted a translation: " + field)
	localizer.strings.erase(prefix + ".title")
	expect(localizer.localize_tree(original, prefix).title == original.title, "Missing title was replaced by generic Role Memory")
	print("Checked %s role CGs in both locales, including assignment, gallery and saved unlocks" % rewards.size())

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	await check_all_rewards(app)
	expect(app.content.load_all("zh_CN"), "Chinese legacy fixture failed to load")
	app.configure_game_content()
	for staff_id in ["doc_sayaka", "doc_shiori", "doc_aqua"]:
		var reward: Dictionary = app.game.staff_role_cg_reward_for(staff_id, "assistant_surgeon")
		expect(not reward.is_empty(), staff_id + ": assistant role CG record missing")
		if reward.is_empty():
			continue
		expect(FileAccess.file_exists("res://" + str(reward.path)), staff_id + ": assistant role CG file missing")
		expect(load("res://" + str(reward.path)) is Texture2D, staff_id + ": assistant role CG could not be loaded as a texture")
		var unlocked: Dictionary = app.game.unlock_staff_role_cg(staff_id, "assistant_surgeon")
		expect(str(unlocked.get("id", "")) == str(reward.id), staff_id + ": first assignment did not unlock the configured CG")
		expect(app.game.staff_role_cg_unlocked(str(reward.id)), staff_id + ": unlocked CG was not added to the gallery state")
		expect(app.game.unlock_staff_role_cg(staff_id, "assistant_surgeon").is_empty(), staff_id + ": repeat assignment unlocked the CG twice")
	# Exercise the actual English role pickers. A disabled placeholder used to
	# make Godot preselect the first candidate, so the first click never reached
	# preop_event() and neither assistant nor nurse reward art appeared.
	expect(app.content.load_all("en"), "English content failed to load")
	app.configure_game_content()
	for person in app.content.collections.staff:
		app.game.meet_staff(person.id)
	for surgery in app.content.collections.surgeries:
		if str(surgery.get("status", "ready")) != "placeholder":
			app.game.unlock_procedure(str(surgery.id))
	var visit = app.game.open_visit("visit_sora")
	for action_id in ["greet", "basic_history", "to_exam", "vitals", "limited_clothed_exam", "blood", "imaging", "to_diagnosis", "diagnose_appendix", "explain", "admit"]:
		expect(visit != null and visit.apply(action_id), "English fixture failed during clinic action " + action_id)
	var prep = app.game.open_preop("preop_sora")
	expect(prep != null, "English fixture could not open preoperative flow")
	app.show_preop("preop_sora")
	var explain: Button = app.page.get_node_or_null("PreopAction_explain_plan")
	expect(explain != null, "English preoperative plan control is missing")
	if explain != null:
		explain.pressed.emit()
	await process_frame
	var appropriate_answer: Button = app.page.get_node_or_null("PreopAction_appropriate_answer")
	expect(appropriate_answer != null, "English vivid-explanation choice did not expose the appropriate-answer branch")
	if appropriate_answer != null:
		appropriate_answer.pressed.emit()
	await process_frame
	for role_id in ["assistant_surgeon", "scrub_nurse"]:
		var picker: OptionButton = app.page.get_node_or_null("Role_" + role_id)
		expect(picker != null and picker.selected == 0, "English " + role_id + " picker preselected staff before the first assignment")
		if picker == null:
			continue
		picker.select(1)
		picker.item_selected.emit(1)
		expect(app.screen == "staff_role_reward", "English first " + role_id + " assignment did not display its CG")
		var continue_button: Button = app.page.get_node_or_null("StaffRoleRewardContinue")
		expect(continue_button != null, "English role CG has no continue control")
		if continue_button != null:
			continue_button.pressed.emit()
		await process_frame
	print("role_cg_asset_test: %s checks, %s failures" % [checks, failures])
	app.queue_free()
	quit(1 if failures else 0)
