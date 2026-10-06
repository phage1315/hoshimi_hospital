extends SceneTree
const GameState = preload("res://godot/systems/game_state.gd")

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
	app.show_map()
	expect(app.content.collections.locations.size() >= 14 and app.page.get_node_or_null("Location_player_office") != null, "Hospital directory omitted the player office")
	app.show_location("player_office")
	expect(app.screen == "player_office" and app.page.get_node_or_null("SceneBackground") != null, "Player office did not use its authored background")
	expect(app.page.get_node_or_null("OfficeCareerActions") != null and app.page.get_node_or_null("OfficeMenu_0") != null, "Player-office hub menu is incomplete")
	expect(app.page.get_node_or_null("OfficeOperativeFieldUIToggle") != null, "Player office omitted the operative-field UI experiment toggle")
	var collection: Button = app.page.get_node_or_null("OfficeCollection")
	expect(collection != null, "Office collection entry is missing")
	if collection != null:
		collection.pressed.emit()
		var letter: Button = app.page.get_node_or_null("OfficeItem_mentor_recommendation_letter")
		expect(app.screen == "office_collection" and letter != null, "Mentor recommendation letter is not available in the initial office")
		if letter != null:
			letter.pressed.emit()
			expect(app.screen == "office_item", "Mentor recommendation letter detail did not open")
	app.show_player_office()
	app.page.get_node("OfficeCareerActions").pressed.emit()
	var review: Button = app.page.get_node_or_null("OfficeAction_office_review_surgery_recording")
	expect(review != null, "Surgery review action is missing")
	if review != null:
		var before_time: int = app.game.elapsed()
		var before_skill: int = int(app.game.player_attributes().skill)
		review.pressed.emit()
		expect(app.screen == "player_office" and app.game.elapsed() == before_time + 120, "Office action did not return to the hub after spending time")
		expect(int(app.game.player_attributes().skill) == before_skill, "Watching a recording directly increased hands-on surgery technique")
		expect(app.game.time_history().back().label == "复盘手术录像", "Office action did not enter the shared time log")
	var snapshot: Dictionary = app.game.snapshot()
	var clone = GameState.new()
	clone.configure(app.content.collections.encounters, app.content.collections.preops, app.content.collections.staff, app.content.collections.time_events, app.content.collections.surgeries, app.content.collections.patients, app.content.collections.relationships, app.content.collections.character_events, app.content.collections.case_templates, app.content.collections.micro_events, app.content.collections.examination_cg_pools, app.content.collections.surgery_team_dialogue_profiles, app.content.collections.patient_interactions, app.content.collections.temporary_conditions, app.content.collections.staff_role_cg_rewards)
	expect(clone.restore(JSON.parse_string(JSON.stringify(snapshot))), "Office action save could not restore")
	expect(clone.elapsed() == app.game.elapsed() and clone.player_attributes() == app.game.player_attributes(), "Office action time or rewards changed after save/load")
	app.show_office_relationships()
	expect(app.screen == "office_relationships" and app.page.get_node_or_null("OfficeRelationshipScroll") != null, "Relationship archive did not render")
	app.show_office_cases()
	expect(app.screen == "office_cases", "Case archive did not render")
	var patient_id: String = app.game.current_patient_id()
	var encounter_id: String = app.game.encounter_id_for_patient(patient_id)
	app.game.open_visit(encounter_id)
	app.show_office_cases()
	expect(app.page.get_node_or_null("OfficeCase_" + patient_id) != null, "Visited patient did not appear in the case archive")
	app.show_office_case(patient_id)
	expect(app.screen == "office_case_detail", "Case detail did not open")
	app.show_office_career()
	expect(app.screen == "office_career", "Career record did not render")
	print("PLAYER OFFICE: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
