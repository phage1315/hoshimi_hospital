extends SceneTree
## Headless runtime, localization, branch, palpation-decoupling, and v37 BoundarySave
## verification for Miyama Kaori's Lv1 special event 《叮。》 (miyama_01_safety_pin V2.3).

const Loader = preload("res://godot/scripts/content_loader.gd")
const GameState = preload("res://godot/systems/game_state.gd")
const PreopSession = preload("res://godot/systems/preop_session.gd")
const MiyamaPalpation = preload("res://godot/ui/miyama_story_palpation.gd")
const SaveStore = preload("res://godot/systems/save_store.gd")

const EVENT_ID := "miyama_01_safety_pin"
const STEP_ID := "miyama_01_safety_pin_main"

var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func configure_game(content: Loader, game: GameState) -> void:
	game.configure(
		content.collections.encounters,
		content.collections.preops,
		content.collections.staff,
		content.collections.time_events,
		content.collections.surgeries,
		content.collections.patients,
		content.collections.relationships,
		content.collections.character_events,
		content.collections.case_templates,
		content.collections.micro_events,
		content.collections.examination_cg_pools,
		content.collections.surgery_team_dialogue_profiles,
		content.collections.patient_interactions,
		content.collections.temporary_conditions,
		content.collections.staff_role_cg_rewards,
		content.collections.special_events,
		content.collections.special_event_steps,
		content.collections.date_profiles,
		content.collections.date_locations,
		content.collections.advanced_referral_cases
	)

func complete_intro(game: GameState) -> void:
	var intro = game.start_character_event("intro_doc_rei")
	expect(intro != null, "Start intro_doc_rei")
	var guard := 0
	while intro != null and not intro.completed and guard < 100:
		var choices: Array = intro.current().get("choices", [])
		expect(not choices.is_empty() and game.choose_character_event(str(choices[0].id)), "Advance intro_doc_rei")
		guard += 1
	if intro != null and intro.completed:
		game.active_character_event_id = ""
		game.active_mode = "encounter"

func prepare_lv1_ready_game(locale: String) -> Array:
	var content := Loader.new()
	expect(content.load_all(locale), "Load content for locale " + locale)
	var game := GameState.new()
	configure_game(content, game)
	complete_intro(game)
	game.meet_staff("doc_asuka")
	game.add_familiarity("doc_rei", 10)
	game.advance_story_to_day(4, 540)
	game.set_story_flag("__test_save_target_event__" + EVENT_ID, true)
	return [content, game]

func traverse_branch(locale: String, c1_id: String, c2_id: String) -> Array:
	var pair := prepare_lv1_ready_game(locale)
	var content: Loader = pair[0]
	var game: GameState = pair[1]

	# Verify generic OR palpation is already available BEFORE Kaori Lv1 completes.
	var dummy_preop := PreopSession.new({"surgery_id": "surgery_appendix", "patient_id": "", "initial_anxiety": 0, "stages": [{"id": "or_table_palpation", "kind": "or_table_palpation"}], "start": "or_table_palpation"}, [])
	dummy_preop.procedure_id = "surgery_appendix"
	expect(dummy_preop.or_table_palpation_available(), "Generic OR palpation must not depend on Kaori Lv1")

	# Verify nurse_iwasaki_rumi is NOT met initially and does NOT block Lv1.
	expect(not game.staff_is_met("nurse_iwasaki_rumi"), "Rumi starts unmet in isolated fixture")
	var def: Dictionary = game.special_event_definitions[EVENT_ID]
	expect(game.special_event_available(def), "Kaori Lv1 available without Rumi met")

	var ev = game.start_special_event(EVENT_ID)
	expect(ev != null, "Start miyama_01_safety_pin (" + locale + ")")
	expect(not game.save_block_reason().is_empty(), "Saving must be blocked during active special event")

	var visited := {}
	var rumi_labels_seen := []
	var guard := 0
	while not ev.completed and guard < 500:
		guard += 1
		var node: Dictionary = ev.current()
		var nid := str(node.get("id", ""))
		visited[nid] = true
		expect(not MiyamaPalpation.owns(ev), "MiyamaStoryPalpation must never intercept V2.3 node " + nid)

		if str(node.get("actor_id", "")) == "nurse_iwasaki_rumi":
			var key := "collections.special_event_steps.%s.nodes.%s.speaker_label" % [STEP_ID, nid]
			var spk: String = content.text(key, str(node.get("speaker_label", "")))
			rumi_labels_seen.append(spk)

		var choices: Array = node.get("choices", [])
		expect(not choices.is_empty(), "Choices non-empty at " + nid)
		var pick := str(choices[0].id)
		if nid == "klv1_157":
			pick = c1_id
		elif nid == "klv1_293":
			pick = c2_id
		var res: Dictionary = game.choose_special_event(pick)
		expect(bool(res.get("accepted", false)), "Accepted choice %s at %s" % [pick, nid])

	expect(ev.completed, "Event completed for branch %s/%s (%s)" % [c1_id, c2_id, locale])
	game.finish_special_event()

	var expected_rumi := "岩崎留美" if locale == "zh_CN" else "Rumi Iwasaki"
	expect(rumi_labels_seen.size() == 5, "Expected 5 Rumi spoken beats, got %s" % rumi_labels_seen.size())
	for lbl in rumi_labels_seen:
		expect(lbl == expected_rumi, "Expected direct Rumi name '%s', got '%s'" % [expected_rumi, lbl])
	expect(not game.staff_is_met("nurse_iwasaki_rumi"), "Guest appearance must not mutate Rumi met flag")

	return [content, game, visited]

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	# Verify all 7 Kita V2.3 assets load cleanly via Godot ResourceLoader.
	for path in [
		"res://assets/characters/story_guest_kita_v1/casual/smile.png",
		"res://assets/characters/story_guest_kita_v1/casual/shocked.png",
		"res://assets/characters/story_guest_kita_v1/ward/pout.png",
		"res://assets/characters/story_guest_kita_v1/ward/smile.png",
		"res://assets/characters/story_guest_kita_v1/operating_table/tense.png",
		"res://assets/characters/story_guest_kita_v1/operating_table/panic.png",
		"res://assets/characters/story_guest_kita_v1/intraoperative/tense.png",
		"res://assets/characters/story_guest_kita_v1/intraoperative/panic.png",
		"res://assets/events/character_events/rei/lv1/cg_kita_or_palpation.png",
		"res://assets/events/character_events/rei/lv1/cg_kita_shaving_prep.png",
		"res://assets/events/character_events/rei/lv1/cg_kita_skin_disinfection.png",
	]:
		expect(ResourceLoader.exists(path) and load(path) != null, "Texture loads cleanly: " + path)

	var r_aa := traverse_branch("zh_CN", "choice_1_a", "choice_2_a")
	var v_aa: Dictionary = r_aa[2]
	expect(v_aa.has("klv1_158") and v_aa.has("klv1_167") and not v_aa.has("klv1_168"), "Branch 1A routing")
	expect(v_aa.has("klv1_294") and v_aa.has("klv1_297") and not v_aa.has("klv1_298"), "Branch 2A routing")

	var r_bb := traverse_branch("en", "choice_1_b", "choice_2_b")
	var v_bb: Dictionary = r_bb[2]
	expect(v_bb.has("klv1_168") and v_bb.has("klv1_171") and not v_bb.has("klv1_158"), "Branch 1B routing")
	expect(v_bb.has("klv1_298") and v_bb.has("klv1_301") and not v_bb.has("klv1_302"), "Branch 2B routing")

	var r_bc := traverse_branch("zh_CN", "choice_1_b", "choice_2_c")
	var content: Loader = r_bc[0]
	var game: GameState = r_bc[1]
	var v_bc: Dictionary = r_bc[2]
	expect(v_bc.has("klv1_302") and v_bc.has("klv1_305") and v_bc.has("klv1_196") and v_bc.has("klv1_308"), "Branch 2C + CG + finale routing")

	expect(game.relationship_level("doc_rei") == 1, "Settled doc_rei relationship Lv1")
	expect(game.procedure_unlocked("surgery_exploratory_laparotomy"), "Unlocked surgery_exploratory_laparotomy at completion")
	expect(not game.story_flag("or_table_palpation_unlocked"), "Legacy or_table_palpation_unlocked flag not set")
	for flag in ["miyama_01_safety_pin_completed", "relationship_doc_rei_lv1", "safety_pin_patient_safe", "miyama_negative_exploration_memory"]:
		expect(game.story_flag(flag), "Completion flag set: " + flag)
	expect(game.special_event_gallery_unlocked(EVENT_ID), "Gallery replay unlocked")

	# Verify v37 BoundarySave persistence & absence of inner node state in isolated /private/tmp file.
	expect(game.save_block_reason().is_empty(), "Safe boundary save permitted after completion")
	var tmp_save := "/private/tmp/kaori_lv1_test_save_%s.json" % OS.get_process_id()
	var store := SaveStore.new()
	store.path = tmp_save
	expect(store.write_slot(game, 1), "Save slot 1 to isolated tmp store")
	var raw_json := FileAccess.get_file_as_string(tmp_save)
	expect(not raw_json.contains("klv1_"), "Saved file must never contain internal event node IDs")
	var clone := GameState.new()
	configure_game(content, clone)
	expect(store.read_slot(clone, 1), "Restore v37 boundary save")
	expect(clone.relationship_level("doc_rei") == 1 and clone.special_event_done(EVENT_ID) and clone.procedure_unlocked("surgery_exploratory_laparotomy"), "Restored Lv1, event completion, and unlocked procedure")
	DirAccess.remove_absolute(tmp_save)

	print("KAORI LV1 V2.3 TEST: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
