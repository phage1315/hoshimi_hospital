extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")

var checks := 0
var failures := 0
var content

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func new_prep(surgery_id: String, locale: String = "zh_CN") -> RefCounted:
	var source = Loader.new()
	expect(source.load_all(locale), "Content failed to load for " + locale)
	var definition: Dictionary = source.find_record("preops", "preop_sora").duplicate(true)
	definition.surgery_id = surgery_id
	var prep = Preop.new(definition, source.collections.staff, source.collections.surgeries, source.collections.patients)
	prep.set_graphic_preop_explainer("nurse_haru")
	return prep

func begin_graphic(prep: RefCounted) -> void:
	expect(prep.apply({"kind": "action", "id": "explain_plan"}), "Detailed explanation did not open the answer choice")
	expect(prep.stage_id == "graphic_preop_question" and prep.graphic_preop_dialogue_locked(), "Question stage did not lock the atomic dialogue")
	expect(prep.apply({"kind": "action", "id": "graphic_answer"}), "Graphic answer did not begin")
	expect(prep.stage_id == "graphic_preop_dialogue" and not prep.graphic_preop_nodes.is_empty(), "Graphic dialogue did not initialize")

func finish_graphic(prep: RefCounted) -> void:
	var guard := 0
	while prep.stage_id == "graphic_preop_dialogue" and guard < 100:
		expect(prep.apply({"kind": "graphic_preop_next"}), "Graphic dialogue could not advance")
		guard += 1
	expect(guard < 100 and prep.stage_id == "team", "Graphic dialogue did not return to team builder")
	expect(not prep.graphic_preop_dialogue_locked(), "Saving remained locked after the dialogue")

func run() -> void:
	content = Loader.new()
	expect(content.load_all("zh_CN"), "Chinese content failed to load")
	var eligible_nurses: Array[String] = []
	for person in content.collections.staff:
		if str(person.get("profession", "")) == "nurse" and bool(person.get("personal_nurse", {}).get("eligible", false)):
			eligible_nurses.append(str(person.id))
	eligible_nurses.sort()
	expect(not eligible_nurses.is_empty(), "No eligible personal nurses were discovered from staff data")
	for actor_id in eligible_nurses:
		var person: Dictionary = content.find_record("staff", actor_id)
		var actor_wrapper: Dictionary = person.get("preop_graphic_wrapper", {})
		expect(bool(person.get("personal_nurse", {}).get("eligible", false)), actor_id + " is missing personal-nurse eligibility")
		expect(actor_wrapper.keys().all(func(slot): return slot in ["open", "insert_a", "insert_b", "close"]) and actor_wrapper.size() == 4, actor_id + " does not have a complete graphic pre-op wrapper")
		expect(actor_wrapper.values().all(func(line): return not str(line).is_empty()), actor_id + " has an empty graphic pre-op wrapper line")
		var actor_prep = new_prep("surgery_appendix")
		actor_prep.set_graphic_preop_explainer(actor_id)
		begin_graphic(actor_prep)
		expect(actor_prep.graphic_preop_nodes[1].text == str(actor_wrapper.open), actor_id + " did not inject its own wrapper at runtime")
	var english_content = Loader.new()
	expect(english_content.load_all("en"), "English content failed to load for wrapper audit")
	for actor_id in eligible_nurses:
		var chinese_wrapper: Dictionary = content.find_record("staff", actor_id).get("preop_graphic_wrapper", {})
		var english_wrapper: Dictionary = english_content.find_record("staff", actor_id).get("preop_graphic_wrapper", {})
		for slot in ["open", "insert_a", "insert_b", "close"]:
			expect(not str(english_wrapper.get(slot, "")).is_empty() and english_wrapper.get(slot) != chinese_wrapper.get(slot), actor_id + " lacks English wrapper localization for " + slot)
	var ishigami: Dictionary = content.find_record("staff", "nurse_ishigami")
	expect(not bool(ishigami.get("personal_nurse", {}).get("eligible", true)), "The chief nurse entered the personal-nurse candidate pool")
	expect(not eligible_nurses.has("nurse_ishigami"), "The chief nurse was dynamically enumerated as a personal nurse")
	expect(ishigami.get("preop_graphic_wrapper", {}).is_empty(), "The chief nurse received an unreachable personal-nurse wrapper")
	expect(content.find_record("staff", "doc_aoi").get("preop_graphic_wrapper", {}).is_empty(), "Jinguji retained an unreachable personal-nurse wrapper")
	var representatives := {
		"surgery_appendix": ["abdominal", 20, -5],
		"surgery_breast_tumor": ["breast", 20, -10],
		"surgery_hysterectomy": ["gynecology_pelvic", 20, -15],
		"surgery_cabg": ["thoracic_cardiac", 25, -5],
	}
	for surgery_id in representatives:
		var expected: Array = representatives[surgery_id]
		var prep = new_prep(surgery_id)
		var fear_before: int = prep.fear
		var dignity_before: int = prep.dignity
		begin_graphic(prep)
		expect(prep.graphic_preop_family() == expected[0], "Wrong graphic family for " + surgery_id)
		expect(prep.fear == mini(100, fear_before + int(expected[1])), "Wrong Fear effect for " + surgery_id)
		expect(prep.dignity == maxi(0, dignity_before + int(expected[2])), "Wrong Dignity effect for " + surgery_id)
		expect(prep.graphic_preop_nodes.size() >= 15 and prep.graphic_preop_nodes.all(func(node: Dictionary): return not str(node.get("text", "")).is_empty()), "Graphic dialogue nodes are incomplete for " + surgery_id)
		finish_graphic(prep)
		var replay = new_prep(surgery_id)
		for event in prep.events:
			expect(replay.apply(event), "Could not replay graphic event for " + surgery_id)
		expect(replay.stage_id == prep.stage_id and replay.fear == prep.fear and replay.dignity == prep.dignity, "Graphic dialogue changed after event replay for " + surgery_id)

	var appropriate = new_prep("surgery_appendix")
	var appropriate_fear: int = appropriate.fear
	expect(appropriate.apply({"kind": "action", "id": "explain_plan"}), "Appropriate branch setup failed")
	expect(appropriate.apply({"kind": "action", "id": "appropriate_answer"}), "Appropriate answer failed")
	expect(appropriate.stage_id == "team" and appropriate.fear == maxi(0, appropriate_fear - 5), "Appropriate answer did not calm and return to team builder")

	var wrapper = new_prep("surgery_appendix")
	wrapper.set_graphic_preop_explainer("nurse_haru")
	begin_graphic(wrapper)
	expect(wrapper.graphic_preop_nodes[1].text.contains("听到一半觉得够了"), "Nanase wrapper was not injected")

	var english = new_prep("surgery_cabg", "en")
	begin_graphic(english)
	expect(english.graphic_preop_nodes[0].text.begins_with("“What does opening the chest"), "English family dialogue was not localized")
	expect(english.graphic_preop_nodes[1].text.begins_with("“Tell me to stop"), "English explainer wrapper was not localized")
	var chinese = new_prep("surgery_cabg", "zh_CN")
	begin_graphic(chinese)
	expect(english.graphic_preop_nodes.size() == chinese.graphic_preop_nodes.size(), "English localization changed the dialogue graph")
	for index in range(english.graphic_preop_nodes.size()):
		expect(str(english.graphic_preop_nodes[index].text) != str(chinese.graphic_preop_nodes[index].text), "Graphic node lacks English localization at index %s" % index)

	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, [], content.collections.surgeries, content.collections.patients, content.collections.relationships)
	game.meet_staff("nurse_haru")
	game.personal_nurse_system_unlocked = true
	game.personal_nurse_id = "nurse_haru"
	expect(game.resolve_preop_explainer() == "nurse_haru", "Unlocked personal nurse was not selected as the pre-op explainer")
	game.personal_nurse_system_unlocked = false
	expect(game.resolve_preop_explainer() == "nurse_haru", "Nanase was not selected as the pre-assignment pre-op explainer")
	game.meet_staff("nurse_rin")
	game.personal_nurse_system_unlocked = true
	game.personal_nurse_id = "nurse_rin"
	expect(game.resolve_preop_explainer() == "nurse_rin", "The formally assigned personal nurse did not replace Nanase as pre-op explainer")
	var locked = new_prep("surgery_appendix")
	game.preops["atomic_test"] = locked
	game.active_preop_id = "atomic_test"
	expect(game.can_save_progress(), "Ordinary pre-op stage unexpectedly blocked saving")
	expect(locked.apply({"kind": "action", "id": "explain_plan"}), "Could not enter atomic pre-op explanation")
	expect(not game.can_save_progress() and game.save_block_reason().contains("术前说明"), "Atomic pre-op explanation did not block saving")
	expect(locked.apply({"kind": "action", "id": "appropriate_answer"}), "Could not finish atomic appropriate answer")
	expect(game.can_save_progress(), "Saving did not reopen after the pre-op answer")

	print("GRAPHIC PREOP EXPLANATION: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)
