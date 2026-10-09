extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func configured_game(content):
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events, content.collections.case_templates, content.collections.micro_events, content.collections.examination_cg_pools, content.collections.surgery_team_dialogue_profiles, content.collections.patient_interactions, content.collections.temporary_conditions, content.collections.staff_role_cg_rewards, content.collections.special_events, content.collections.special_event_steps)
	return game

func run() -> void:
	var content = Loader.new()
	expect(content.load_all(), "Content load failed")
	var game = configured_game(content)

	var unknown: Dictionary = game.relationship_progress("doc_emiko")
	expect(not bool(unknown.known) and unknown.gate.is_empty(), "Unknown staff exposed relationship-gate details")
	game.meet_staff("doc_emiko")
	var relation: Dictionary = game.relation_for("doc_emiko")
	relation.familiarity = 9
	var progress: Dictionary = game.relationship_progress("doc_emiko")
	expect(progress.target_level == 1 and progress.has_slot and progress.event_authored, "Emiko Lv1 progress metadata is incomplete")
	expect(progress.gate.familiarity_current == 9 and progress.gate.familiarity_required == 10 and not progress.gate.familiarity_met, "Familiarity progress was not exposed accurately")
	relation.familiarity = 10
	game.set_test_player_attribute("skill", 74)
	progress = game.relationship_progress("doc_emiko")
	expect(progress.gate.familiarity_met and not progress.gate.requirements.met, "Non-familiarity requirements were not separated from familiarity")
	game.set_test_player_attribute("skill", 75)
	progress = game.relationship_progress("doc_emiko")
	expect(progress.gate.met, "Exact centralized gate boundary did not appear ready in progress metadata")

	relation.level = 2
	relation.familiarity = 40
	relation.rank_history = ["emiko_lv2_follow_my_lead"]
	expect(game._complete_character_event_for_test("emiko_lv2_follow_my_lead", 10), "Could not create cooldown fixture")
	game.set_test_time(12, 540)
	progress = game.relationship_progress("doc_emiko")
	expect(not progress.gate.cooldown_met and progress.gate.cooldown_current == 2 and progress.gate.cooldown_remaining == 1, "Cooldown progress did not report two of three days and one day remaining")
	game.set_test_time(13, 540)
	progress = game.relationship_progress("doc_emiko")
	expect(progress.gate.cooldown_met and progress.gate.cooldown_remaining == 0, "Cooldown progress did not unlock on the third day")

	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.game.meet_staff("doc_aoi")
	var aoi_relation: Dictionary = app.game.relation_for("doc_aoi")
	aoi_relation.level = 3
	aoi_relation.familiarity = 55
	app.show_office_relationships()
	await process_frame
	var known_button: Button = app.page.find_child("OfficeRelationshipDetail_doc_aoi", true, false)
	var unknown_button: Button = app.page.find_child("OfficeRelationshipDetail_doc_rei", true, false)
	expect(known_button != null, "Known colleague did not receive a relationship-progress entry")
	expect(unknown_button == null, "Unknown colleague received a relationship-progress entry")
	if known_button != null:
		known_button.pressed.emit()
		await process_frame
		expect(app.screen == "office_relationship_detail", "Relationship detail screen did not open")
		var current_impression: Label = app.page.get_node_or_null("RelationshipCurrentImpression")
		var next_hint: Label = app.page.get_node_or_null("RelationshipNextHint")
		expect(current_impression != null and current_impression.text.contains("Lv3"), "Current relationship impression omitted the established level")
		expect(next_hint != null and next_hint.text.contains("其他条件"), "Compact next-level hint did not distinguish an unmet non-familiarity gate")
		var toggle: Button = app.page.get_node_or_null("RelationshipRequirementsToggle")
		expect(toggle != null, "Detailed-requirements toggle is missing")
		if toggle != null:
			toggle.pressed.emit()
			await process_frame
			var requirements: RichTextLabel = app.page.get_node_or_null("RelationshipRequirementsText")
			expect(requirements != null and requirements.text.contains("熟悉度 55 / 55") and requirements.text.contains("手术技巧"), "Expanded requirements omitted familiarity or player-attribute progress")

	app.game.meet_staff("nurse_moe")
	var moe_relation: Dictionary = app.game.relation_for("nurse_moe")
	moe_relation.familiarity = 10
	app.show_office_relationship_detail("nurse_moe", true)
	await process_frame
	var moe_requirements: RichTextLabel = app.page.get_node_or_null("RelationshipRequirementsText")
	var hiroko_name := str(app.content.find_record("staff", "nurse_hiroko").get("name", ""))
	expect(moe_requirements != null and moe_requirements.text.contains("相关院内经历"), "Hidden cross-character gates did not receive a non-spoiler hint")
	expect(moe_requirements != null and (hiroko_name.is_empty() or not moe_requirements.text.contains(hiroko_name)), "Unknown related character leaked through detailed requirements")

	app.game.meet_staff("doc_aqua")
	var aqua_relation: Dictionary = app.game.relation_for("doc_aqua")
	aqua_relation.level = 1
	aqua_relation.familiarity = 25
	app.show_office_relationship_detail("doc_aqua", true)
	await process_frame
	var aqua_requirements: RichTextLabel = app.page.get_node_or_null("RelationshipRequirementsText")
	expect(aqua_requirements != null and not aqua_requirements.text.contains("aqua_hysterectomy_teaching_complete"), "Raw future-story flag leaked into relationship progress")

	var ui_snapshot: Dictionary = app.game.snapshot()
	expect(app.content.load_all("en"), "English content failed to load for relationship-progress UI")
	app.configure_game_content()
	expect(app.game.restore(ui_snapshot), "Relationship-progress fixture changed while loading English content")
	app.show_office_relationship_detail("doc_aoi", true)
	await process_frame
	var english_hint: Label = app.page.get_node_or_null("RelationshipNextHint")
	var english_requirements: RichTextLabel = app.page.get_node_or_null("RelationshipRequirementsText")
	expect(english_hint != null and english_hint.text.contains("Next Level"), "English relationship-progress summary was not localized")
	expect(english_requirements != null and english_requirements.text.contains("Familiarity"), "English detailed requirements were not localized")

	print("RELATIONSHIP PROGRESS UI: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
