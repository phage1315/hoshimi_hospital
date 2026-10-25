extends RefCounted
## Six authored introductions. Only completion facts and settled window time persist.
const THRESHOLDS := [3, 7, 12, 15, 17, 20]
static func owns(id: String) -> bool:
 return id.begins_with("takemi_lv0_t")
static func eligible(g: RefCounted, definition: Dictionary) -> bool:
 var stage := int(str(definition.id).trim_prefix("takemi_lv0_t"))
 if stage < 1 or stage > 6 or g.staff_is_met("doc_takemi"):
  return false
 if g.active_surgery_in_progress() or not g.active_preop_id.is_empty() or g.active_encounter_in_progress() or not g.active_special_event_id.is_empty() or not g.active_character_event_id.is_empty() or not g.active_micro_event_id.is_empty() or not g.active_free_h_departure.is_empty() or not g.active_after_work_walk.is_empty():
  return false
 if g.successful_no_anesthesia_surgeries < THRESHOLDS[stage - 1]:
  return false
 if g.story_flag("takemi_rumor_window:%s" % g.elapsed()):
  return false
 if stage in [3, 4]:
  if int(g.display_schedule().absolute_clock) < 1200:
   return false
  if not g.free_h_booking.is_empty() and int(g.free_h_booking.get("workday", 0)) == g.current_workday():
   return false
 if stage == 6:
  var attributes: Dictionary = g.player_attributes()
  if not g.takemi_postop_opportunity or int(attributes.get("presence", 0)) < 60 or int(attributes.get("reputation", 0)) < 200:
   return false
 return true
static func completed(g: RefCounted, id: String) -> void:
 # At most one segment in a settled safe window, including after reload.
 # This is a scheduling fact, independent of dialogue IDs and choices.
 for flag in g.story_flags.keys():
  if str(flag).begins_with("takemi_rumor_window:"):
   g.story_flags.erase(flag)
 g.set_story_flag("takemi_rumor_window:%s" % g.elapsed())
 if id == "takemi_lv0_t4":
  g.set_story_flag("takemi_research_discovered")
 if id == "takemi_lv0_t6":
  g.set_story_flag("takemi_research_open")
  g.takemi_postop_opportunity = false
