extends RefCounted
## Stable event-level facts only. The scene node and chosen nurse cast live in memory.
const A := "miyuki_lv5_chie_operation"
const B := "miyuki_lv5_my_turn_on_the_table"
const C := "miyuki_lv5_capable_do_more"

static func owns(event_id: String) -> bool:
	return event_id in [A, B, C]

static func cast_definition(game, source: Dictionary) -> Dictionary:
	var definition: Dictionary = source.duplicate(true)
	var cast_id := "nurse_yoneda_shiori"
	if game.staff_is_met("nurse_kariya_megumi") and not game.staff_record("nurse_kariya_megumi").is_empty():
		cast_id = "nurse_kariya_megumi"
	elif game.staff_record(cast_id).is_empty():
		cast_id = "nurse_moe"
	var english: bool = game.patient_content_locale() == "en"
	var labels := {
		"nurse_kariya_megumi": ["狩谷惠", "Megumi Kariya"],
		"nurse_yoneda_shiori": ["米田栞", "Shiori Yoneda"],
		"nurse_moe": ["本庄萌惠", "Moe Honjo"],
	}
	for node in definition.nodes:
		if bool(node.get("young_nurse_cast", false)):
			node.actor_id = cast_id
			node.speaker_label = labels.get(cast_id, ["年轻护士", "Young Nurse"])[1 if english else 0]
	return definition

static func completed(game, event_id: String) -> void:
	match event_id:
		A:
			game.increment_character_progress_counter("nurse_yui", "completed_no_anesthesia_surgeries")
			game.set_story_flag("asakura_chie_no_anesthesia_special_complete")
			game.set_story_flag("asakura_lv5_part_b_pending")
		B:
			game.set_story_flag("asakura_lv5_part_b_pending", false)
			game.set_story_flag("asakura_lv5_epilogue_pending")
		C:
			game.set_story_flag("asakura_lv5_epilogue_pending", false)
			game.set_story_flag("asakura_lv5_epilogue_complete")
