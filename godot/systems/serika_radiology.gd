extends RefCounted
## Finite independent events. Persistent progress is derived only from completed
## event facts; no dialogue cursor or in-progress session enters a save.
const ACTOR := "doc_serika"
const PREFIX := "serika_radiology_d"
const LV1 := "serika_lv1_cross_out_my_name"
static func naturally_present(g: RefCounted) -> bool:
 if not g.staff_is_met(ACTOR) or str(g.active_staff_patient.get("staff_id", "")) == ACTOR:
  return false
 var key := "serika_imaging_present:%s" % g.day_number()
 if not g.story_flags.has(key):
  g.set_story_flag(key, absi(hash("%s:serika_imaging:%s" % [g.campaign_seed, g.day_number()])) % 100 < 70)
 return g.story_flag(key)
static func lv1_entry_allowed(g: RefCounted) -> bool:
 # Remaining rank/intro requirements use the shared character-event gate.
 # Do not ask staff_present_at here: personal events themselves place actors.
 if g.active_surgery_in_progress() or not g.active_character_event_id.is_empty() or not g.active_special_event_id.is_empty() or not g.active_micro_event_id.is_empty() or not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty():
  return false
 if g.shift_remaining() < 30 or g.current_absolute_clock() < 540 or g.current_absolute_clock() + 30 > 1020:
  return false
 return naturally_present(g)
static func owns(id: String) -> bool:
 return id.begins_with(PREFIX)
static func event_id(index: int) -> String:
 return PREFIX + "%02d" % index
static func next_index(g: RefCounted) -> int:
 for i in range(1, 16):
  if not g.character_event_done(event_id(i)):
   return i
 return 16
static func milestone_complete(g: RefCounted, level: int) -> bool:
 var slot: Dictionary = g.relationship_rank_slot(ACTOR, level)
 var id := str(slot.get("event_id", ""))
 if id.is_empty() or str(slot.get("content_status", "")) != "authored":
  return false
 if not g.relation_for(ACTOR).get("rank_history", []).has(id):
  return false
 return g.character_event_done(id) or int(g.special_event_completion_counts.get(id, 0)) > 0
static func eligible(g: RefCounted, id: String) -> bool:
 var i := next_index(g)
 if i > 15 or id != event_id(i) or not g.staff_is_met(ACTOR):
  return false
 for segment in ["a", "b", "c", "d"]:
  if not g.character_event_done("serika_lv0_" + segment):
   return false
 if not g.active_character_event_id.is_empty() or not g.active_special_event_id.is_empty() or not g.active_micro_event_id.is_empty() or not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty():
  return false
 if i >= 6 and not milestone_complete(g, 1):
  return false
 if i >= 11 and not milestone_complete(g, 2):
  return false
 if g.story_flag("serika_imaging_discussed:%s" % g.day_number()) or g.shift_remaining() < 60 or g.current_absolute_clock() < 540 or g.current_absolute_clock() + 60 > 1020:
  return false
 return ACTOR in g.staff_present_at("imaging")
static func completed(g: RefCounted, day: int) -> void:
 # The caller applies this once, alongside the final node's fixed +3 and
 # CharacterEventSession's settled 60 minutes, before returning to the map.
 g.set_story_flag("serika_imaging_discussed:%s" % day)
