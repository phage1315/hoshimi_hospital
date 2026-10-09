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

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
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
	quit(1 if failures else 0)
