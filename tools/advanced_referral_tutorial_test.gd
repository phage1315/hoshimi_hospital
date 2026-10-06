extends SceneTree

const GameState = preload("res://godot/systems/game_state.gd")

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func configure_clone(clone, app) -> void:
	clone.configure(app.content.collections.encounters, app.content.collections.preops, app.content.collections.staff, app.content.collections.time_events, app.content.collections.surgeries, app.content.collections.patients, app.content.collections.relationships, app.content.collections.character_events, app.content.collections.case_templates, app.content.collections.micro_events, app.content.collections.examination_cg_pools, app.content.collections.surgery_team_dialogue_profiles, app.content.collections.patient_interactions, app.content.collections.temporary_conditions, app.content.collections.staff_role_cg_rewards, app.content.collections.special_events, app.content.collections.special_event_steps, app.content.collections.date_profiles, app.content.collections.date_locations, app.content.collections.advanced_referral_cases, app.content.collections.first_surgery_diagnosis_reactions, app.content.collections.palpation_profiles)

func choose_first(game) -> Dictionary:
	var node: Dictionary = game.active_special_event.current()
	for candidate in node.get("choices", []):
		if game.special_requirements_met(candidate.get("requirements", [])):
			return game.choose_special_event(str(candidate.id))
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var game = app.game
	var event_id := "advanced_referral_tutorial_chisato"
	expect(game.special_event_definitions.has(event_id), "Advanced-referral tutorial definition is missing")
	var tutorial_definition: Dictionary = game.special_event_definitions[event_id]
	expect(not tutorial_definition.required_characters.has("doc_artoria"), "Chisato event incorrectly treats Artoria as a met-character gate")
	expect(not tutorial_definition.get("unlock_requirements", []).any(func(requirement: Dictionary): return str(requirement.get("actor_id", "")) == "doc_artoria"), "Chisato event incorrectly requires the player to know Artoria")
	expect(not tutorial_definition.get("prerequisite_events", []).has("artoria_lv1_right_position"), "Chisato event incorrectly depends on Artoria's personal route")
	expect(float(game.special_event_definitions[event_id].get("cg_dialogue_delay_seconds", 0.0)) == 2.0, "Chisato tutorial CG dialogue delay must be two seconds")
	expect(not game.surgery_definition("surgery_adv_artificial_heart_exchange").is_empty(), "Tutorial procedure is missing")
	expect(game.advanced_referral_definitions.any(func(item: Dictionary): return str(item.id) == "advanced_referral_tutorial_chisato_case"), "Tutorial referral case is missing")
	expect(game.special_event_step_definitions["advanced_referral_tutorial_chisato_day1"].nodes.size() == 158, "Day 1 conference or dry-run dialogue is incomplete")
	expect(game.special_event_step_definitions["advanced_referral_tutorial_chisato_day2"].nodes.size() == 130, "Day 2 Grand OR dialogue is incomplete")
	expect(game.special_event_step_definitions["advanced_referral_tutorial_chisato_day3"].nodes.size() == 72, "Day 3 round or debrief dialogue is incomplete")
	var restored_nodes := [
		"artoria_sets_scope", "artoria_requires_full_dry_run",
		"player_nurse_joke", "ange_surprised", "chisato_should_attend",
		"sakura_head_side", "hiroko_adjusts_arm", "miyuki_checks_route",
		"ange_route", "chisato_table_narrow", "chisato_not_knowing",
		"chisato_patient_late", "stage2_miyuki", "stage4a_hiroko",
		"stage6_returned", "stage8_ange", "artoria_room_ready",
		"artoria_holds_reserve", "observer_artoria",
		"observer_aqua", "observer_shiori", "chisato_five_stars",
		"leave_choice", "artoria_debrief_team", "miyuki_just_right", "ange_no", "mido_noisy",
		"asuka_positive",
	]
	var all_restored := true
	for restored_id in restored_nodes:
		var found := false
		for step_id in ["advanced_referral_tutorial_chisato_day1", "advanced_referral_tutorial_chisato_day2", "advanced_referral_tutorial_chisato_day3"]:
			for item in game.special_event_step_definitions[step_id].nodes:
				if str(item.id) == restored_id:
					found = true
					break
		all_restored = all_restored and found
	expect(all_restored, "One or more restored Chisato story beats are missing")
	var day1_nodes: Array = game.special_event_step_definitions["advanced_referral_tutorial_chisato_day1"].nodes
	var reached_grand_or := false
	var conference_nurse_count := 0
	var conference_doctor_count := 0
	for item in day1_nodes:
		if str(item.id) == "dry_run_entry":
			reached_grand_or = true
		if reached_grand_or:
			continue
		if str(item.get("actor_id", "")).begins_with("nurse_"):
			conference_nurse_count += 1
			expect(str(item.get("outfit", "")) == "uniform", "Preoperative conference nurse %s is not in a regular uniform" % str(item.id))
		elif str(item.get("actor_id", "")).begins_with("doc_"):
			conference_doctor_count += 1
			expect(str(item.get("outfit", "")) == "white_coat", "Preoperative conference doctor %s is not in regular work attire" % str(item.id))
	expect(conference_nurse_count > 0, "Day 1 preoperative conference has no nurse portrait checks")
	expect(conference_doctor_count > 0, "Day 1 preoperative conference has no doctor portrait checks")
	var sakura: Dictionary = app.content.find_record("staff", "doc_sakura_anesthesiology")
	expect(str(sakura.visuals.portraits.get("scrubs/neutral", "")).ends_with("scrubs/neutral_v2.png"), "Sakura Grand OR portrait is not the plain-scrubs revision")
	expect(FileAccess.file_exists("res://assets/events/advanced_referral_tutorial_chisato/chisato_conference_v1.png") and FileAccess.file_exists("res://assets/events/advanced_referral_tutorial_chisato/chisato_or_standing_open_v1.png") and FileAccess.file_exists("res://assets/events/advanced_referral_tutorial_chisato/chisato_or_standing_smile_v1.png") and FileAccess.file_exists("res://assets/events/advanced_referral_tutorial_chisato/chisato_operating_table_preanesthesia_v1.png") and FileAccess.file_exists("res://assets/events/advanced_referral_tutorial_chisato/chisato_postop_v1.png"), "Chisato tutorial portrait set is incomplete")
	var bare_table_path := "assets/events/advanced_referral_tutorial_chisato/chisato_operating_table_preanesthesia_v1.png"
	var standing_portraits := {
		"chisato_gown_question": "assets/events/advanced_referral_tutorial_chisato/chisato_or_standing_open_v1.png",
		"dry_run_refusal": "assets/events/advanced_referral_tutorial_chisato/chisato_or_standing_smile_v1.png",
		"chisato_consent_reason": "assets/events/advanced_referral_tutorial_chisato/chisato_or_standing_open_v1.png",
		"chisato_final_confirmation": "assets/events/advanced_referral_tutorial_chisato/chisato_or_standing_smile_v1.png",
	}
	var chisato_is_on_table := false
	for item in day1_nodes:
		var node_id := str(item.id)
		if standing_portraits.has(node_id):
			expect(str(item.get("portrait_path", "")) == str(standing_portraits[node_id]), "Day 1 standing Chisato node %s uses the wrong half-body portrait" % node_id)
			expect(float(item.get("portrait_scale", 0.0)) == 1.25 and float(item.get("portrait_y", 0.0)) == 112.0, "Day 1 standing Chisato portrait %s is not aligned with the dialogue box" % node_id)
		if node_id == "dry_run_prepared":
			chisato_is_on_table = true
			expect(str(item.get("cg_path", "")).ends_with("/cg_dry_run_light_v1.png"), "Chisato getting onto the table does not begin with the surgical-light side CG")
			expect(float(item.get("cg_dialogue_delay_seconds", 0.0)) == 2.0, "The initial surgical-light CG has no two-second reveal")
		if node_id == "dry_run_choice":
			expect(str(item.get("cg_path", "")).ends_with("/cg_dry_run_team_v1.png"), "The overhead dry-run CG is not placed after the positioning dialogue")
			expect(float(item.get("cg_dialogue_delay_seconds", 0.0)) == 2.0, "The overhead dry-run closing CG has no two-second reveal")
		if node_id == "chisato_light_reaction":
			expect(str(item.get("cg_path", "")).ends_with("/cg_dry_run_light_v1.png"), "The surgical-light CG does not persist through Chisato's reaction")
		elif chisato_is_on_table and str(item.get("speaker_label", "")) == "锦木千束":
			expect(str(item.get("portrait_path", "")) == bare_table_path, "Day 1 Grand OR Chisato node %s does not use the bare-shoulder portrait" % str(item.id))
			expect(float(item.get("portrait_scale", 0.0)) == 1.35 and float(item.get("portrait_y", 0.0)) == 205.0, "Day 1 Grand OR Chisato portrait %s is not aligned with the dialogue box" % str(item.id))
	var labeled_quote: Dictionary = app.dialogue_page_presentation("Chisato Nishikigi", "narrator", "“That was not here yesterday!”", "")
	expect(str(labeled_quote.speaker) == "Chisato Nishikigi", "An explicit Chisato speaker label was replaced by Narrator")
	var day2_nodes: Array = game.special_event_step_definitions["advanced_referral_tutorial_chisato_day2"].nodes
	var day3_nodes: Array = game.special_event_step_definitions["advanced_referral_tutorial_chisato_day3"].nodes
	for day_nodes in [day1_nodes, day2_nodes, day3_nodes]:
		var artoria_nodes: Array = day_nodes.filter(func(item: Dictionary): return str(item.get("actor_id", "")) == "doc_artoria")
		expect(not artoria_nodes.is_empty(), "One Chisato-event day has no Artoria participation")
		for item in artoria_nodes:
			expect(item.get("requirements", []).is_empty(), "Artoria node %s can disappear behind a relationship check" % str(item.id))
	var day3_nurse_count := 0
	for item in day3_nodes:
		if str(item.get("actor_id", "")).begins_with("nurse_"):
			day3_nurse_count += 1
			expect(str(item.get("outfit", "")) == "uniform", "Day 3 postoperative nurse %s is not back in a regular uniform" % str(item.id))
	expect(day3_nurse_count > 0, "Day 3 postoperative sequence has no nurse outfit checks")
	var sayaka_promise_node: Dictionary = {}
	var handhold_cg_node: Dictionary = {}
	for item in day2_nodes:
		if str(item.id) == "sayaka_promise":
			sayaka_promise_node = item
		elif str(item.id) == "sayaka_holds_chisato_cg":
			handhold_cg_node = item
		expect(not str(item.get("portrait_path", "")).ends_with("/chisato_induction_v1.png"), "The rejected Chisato induction portrait is still used by %s" % str(item.id))
		if str(item.get("portrait_path", "")) == bare_table_path:
			expect(float(item.get("portrait_scale", 0.0)) == 1.35 and float(item.get("portrait_y", 0.0)) == 205.0, "Day 2 operating-table portrait %s is not aligned with the dialogue box" % str(item.id))
	expect(not sayaka_promise_node.is_empty() and str(sayaka_promise_node.choices[0].next) == "sayaka_holds_chisato_cg", "Sayaka's handhold does not lead into its CG")
	expect(str(handhold_cg_node.get("cg_path", "")).ends_with("/cg_sayaka_holds_chisato_v1.png") and float(handhold_cg_node.get("cg_dialogue_delay_seconds", 0.0)) == 2.0, "Sayaka's handhold CG is missing or has no two-second reveal")
	expect(game.start_special_event_for_testing(event_id) != null, "Developer entry could not start tutorial")
	expect(game.active_special_event.current_step().id == "advanced_referral_tutorial_chisato_day1", "Tutorial did not begin on Day 1")
	expect(game.active_special_event.jump_to("dry_run_prepared"), "Could not reach the initial surgical-light CG node")
	app.special_event_last_cg_path = ""
	app.show_special_event()
	await process_frame
	var initial_side_cg := app.page.get_node_or_null("CharacterEventCG") as TextureRect
	var initial_dialogue: Node = app.page.get_node_or_null("SpecialEventDialogueBox")
	var initial_choice: Node = app.page.get_node_or_null("SpecialEventChoice_dry_run_prepared_next")
	expect(initial_side_cg != null and initial_side_cg.texture != null and initial_side_cg.texture.resource_path.ends_with("/cg_dry_run_light_v1.png"), "Chisato getting onto the table did not render the surgical-light side CG")
	expect(initial_dialogue != null and not initial_dialogue.visible and initial_choice != null and not initial_choice.visible, "Initial surgical-light CG did not receive its clean reveal")
	await create_timer(2.1).timeout
	expect(initial_dialogue.visible and initial_choice.visible, "Initial surgical-light CG dialogue did not appear after two seconds")
	expect(game.active_special_event.jump_to("dry_run_immersive"), "Could not reach the surgical-light continuation node")
	app.show_special_event()
	await process_frame
	var continuing_side_cg := app.page.get_node_or_null("CharacterEventCG") as TextureRect
	expect(continuing_side_cg != null and continuing_side_cg.texture != null and continuing_side_cg.texture.resource_path.ends_with("/cg_dry_run_light_v1.png"), "The surgical-light side CG does not persist through its immediate follow-up")
	expect(game.active_special_event.jump_to("dry_run_choice"), "Could not reach the post-positioning overhead CG node")
	app.show_special_event()
	await process_frame
	var overhead_cg := app.page.get_node_or_null("CharacterEventCG") as TextureRect
	var delayed_dialogue: Node = app.page.get_node_or_null("SpecialEventDialogueBox")
	var delayed_choice: Node = app.page.get_node_or_null("SpecialEventChoice_dry_fun")
	expect(overhead_cg != null and overhead_cg.texture != null and overhead_cg.texture.resource_path.ends_with("/cg_dry_run_team_v1.png"), "The overhead dry-run CG did not render after the positioning dialogue")
	expect(delayed_dialogue != null and not delayed_dialogue.visible, "Overhead dry-run CG dialogue was not hidden during the two-second reveal")
	expect(delayed_choice != null and not delayed_choice.visible, "Overhead dry-run CG choices were not hidden during the two-second reveal")
	await create_timer(2.1).timeout
	expect(delayed_dialogue.visible and delayed_choice.visible, "Overhead dry-run question and choices did not appear after two seconds")
	expect(game.active_special_event.jump_to("opening"), "Could not reset tutorial after checking the CG delay")
	app.special_event_last_cg_path = ""
	expect(game.active_special_event.jump_to("chisato_notices_sayaka"), "Could not reach Chisato's Day 1 Sayaka introduction")
	expect(str(game.active_special_event.current().get("speaker_label", "")) == "锦木千束", "Chisato did not address Sayaka before the dry run")
	choose_first(game)
	expect(str(game.active_special_event.current().get("actor_id", "")) == "doc_sayaka", "Sayaka did not answer Chisato during the conference")
	expect(game.active_special_event.jump_to("dry_run_sayaka_tease"), "Could not reach Sayaka's Grand OR dry-run exchange")
	expect(str(game.active_special_event.current().get("actor_id", "")) == "doc_sayaka", "Sayaka's dry-run dialogue is missing")
	choose_first(game)
	expect(str(game.active_special_event.current().get("speaker_label", "")) == "锦木千束", "The dry-run exchange did not return to Chisato")
	expect(game.active_special_event.jump_to("opening"), "Could not reset Day 1 after checking Sayaka continuity")

	# Reach Day 2, then verify an in-progress save restores at the exact authored node.
	# Start a clean session after the direct-jump probes above.
	game.active_special_event = null
	game.active_special_event_id = ""
	game.active_mode = "encounter"
	expect(game.start_special_event_for_testing(event_id) != null, "Could not restart tutorial after the Day 1 probes")
	var guard := 0
	while game.special_event_in_progress() and game.active_special_event.step_index == 0 and guard < 240:
		choose_first(game)
		guard += 1
	expect(game.active_special_event.step_index == 1, "Day 1 did not advance into the Grand OR day")
	expect(game.active_special_event.jump_to("needle_dialogue"), "Could not reach Chisato's injection exchange")
	app.show_special_event()
	await process_frame
	var chisato_table_portrait := app.page.get_node_or_null("CharacterEventPortrait") as TextureRect
	expect(str(game.active_special_event.current().get("speaker_label", "")) == "锦木千束" and chisato_table_portrait != null and chisato_table_portrait.texture.resource_path.ends_with("/chisato_operating_table_preanesthesia_v1.png"), "Chisato's injection line did not use her operating-table portrait")
	choose_first(game)
	expect(str(game.active_special_event.current().id) == "needle_hiroko_tease" and str(game.active_special_event.current().get("actor_id", "")) == "nurse_hiroko", "Injection exchange did not switch from Chisato to Hiroko")
	choose_first(game)
	expect(str(game.active_special_event.current().id) == "needle_chisato_retort" and str(game.active_special_event.current().get("speaker_label", "")) == "锦木千束", "Injection exchange did not switch back to Chisato")
	choose_first(game)
	expect(str(game.active_special_event.current().id) == "hiroko_stops_teasing" and str(game.active_special_event.current().get("actor_id", "")) == "nurse_hiroko", "Injection exchange did not return to Hiroko")
	expect(game.active_special_event.jump_to("chisato_sayaka_greeting"), "Could not reach Chisato's Day 2 Sayaka greeting")
	expect(str(game.active_special_event.current().get("speaker_label", "")) == "锦木千束", "Chisato's Day 2 Sayaka greeting has the wrong speaker")
	choose_first(game)
	expect(str(game.active_special_event.current().get("actor_id", "")) == "doc_sayaka" and str(game.active_special_event.current().get("outfit", "")) == "sterile", "Sayaka did not answer in second-assistant attire")
	expect(game.active_special_event.jump_to("sayaka_promise"), "Could not reach Sayaka's pre-induction reassurance")
	expect(str(game.active_special_event.current().get("actor_id", "")) == "doc_sayaka" and str(game.active_special_event.current().get("outfit", "")) == "sterile", "Sayaka's pre-induction reassurance is missing")
	expect(game.active_special_event.jump_to("summary"), "Could not reset Day 2 after checking the injection exchange")
	app.show_special_event()
	await process_frame
	var page_title := app.page.get_node_or_null("PageTitle") as Control
	var procedure_label := app.page.get_node_or_null("AdvancedReferralProcedure") as Control
	expect(page_title != null and procedure_label != null, "Day 2 summary title labels are missing")
	if page_title != null and procedure_label != null:
		expect(not page_title.get_rect().intersects(procedure_label.get_rect()), "Day 2 procedure name overlaps the page title")
	# The Day 2 portrait probes also use direct jumps. Restart once more before
	# the save/restore assertion so its recorded choices form a natural path.
	game.active_special_event = null
	game.active_special_event_id = ""
	game.active_mode = "encounter"
	expect(game.start_special_event_for_testing(event_id) != null, "Could not restart tutorial for the natural-path save test")
	guard = 0
	while str(game.active_special_event.current().id) != "stage3" and guard < 420:
		choose_first(game)
		guard += 1
	expect(str(game.active_special_event.current().get("presentation", "")) == "advanced_surgery", "Day 2 did not enter advanced-surgery presentation")
	app.show_special_event()
	await process_frame
	var prompt_panel := app.page.get_node_or_null("AdvancedReferralPromptPanel") as Panel
	var prompt := app.page.get_node_or_null("AdvancedReferralPrompt") as RichTextLabel
	var first_stage_choice := app.page.get_node_or_null("AdvancedReferralChoice_" + str(game.active_special_event.current().choices[0].id)) as Button
	expect(prompt_panel != null, "Advanced-surgery question has no contrast panel")
	expect(prompt != null and prompt.get_theme_font_size("normal_font_size") == 25, "Advanced-surgery question does not use the enlarged prompt style")
	if prompt != null:
		var prompt_font := prompt.get_theme_font("normal_font") as FontVariation
		expect(prompt_font != null and prompt_font.variation_embolden >= 0.75, "Advanced-surgery question is not bold enough")
	expect(first_stage_choice != null and first_stage_choice.get_theme_font_size("font_size") == 21, "Advanced-surgery choice text does not use the emphasized option style")
	var saved: Dictionary = game.snapshot()
	var clone = GameState.new()
	configure_clone(clone, app)
	var restored := clone.restore(JSON.parse_string(JSON.stringify(saved)))
	expect(restored, "Tutorial mid-surgery save could not restore: %s" % clone.last_error)
	if not restored:
		print("ADVANCED REFERRAL TUTORIAL: %s checks; %s failure(s)" % [checks, failures])
		quit(1)
		return
	expect(clone.active_special_event.step_index == 1 and str(clone.active_special_event.current().id) == "stage3", "Restore lost the advanced surgery stage")

	guard = 0
	while clone.special_event_in_progress() and guard < 320:
		var result := choose_first(clone)
		expect(bool(result.get("accepted", false)), "Tutorial reached a node with no accepted safe choice")
		guard += 1
	expect(clone.active_special_event.completed and guard < 320, "Tutorial did not reach its Day 3 ending")
	expect(clone.story_flag("advanced_referral_tutorial_complete"), "Tutorial completion flag is missing")
	expect(clone.story_flag("advanced_referral_random_cases_enabled") and clone.story_flag("grand_or_team_builder_enabled"), "Advanced system unlock flags are missing")
	expect(clone.story_flag("tutorial_surgery_success") and clone.story_flag("advanced_tutorial_day2_complete"), "Day 2 success flags are missing")
	expect(clone.staff_is_met("doc_sakura_anesthesiology") and clone.story_flag("met_sakura"), "Sakura introduction did not persist")
	expect(clone.procedure_unlocked("surgery_adv_artificial_heart_exchange"), "Advanced procedure did not unlock")
	expect(clone.story_flag("advanced_referral_completed_advanced_referral_tutorial_chisato_case"), "Referral completion record is missing")
	expect(clone.completed_surgeries_total == 1 and int(clone.completed_surgeries_by_group.get("cardiac", 0)) == 1, "Tutorial surgery was not recorded")
	expect(clone.surgery_xp == 360 and int(clone.player_attributes().reputation) == 30, "Tutorial XP or reputation reward is wrong")
	expect(not clone.active_special_event.dominant_tutorial_style().is_empty(), "Tutorial style was not reconstructed from saved choices")

	print("ADVANCED REFERRAL TUTORIAL: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
