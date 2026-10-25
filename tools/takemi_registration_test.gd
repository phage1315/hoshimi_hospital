extends SceneTree
const Preop = preload("res://godot/systems/preop_session.gd")
const ACTOR = "doc_takemi"
var checks := 0
var failures := 0
func expect(ok: bool, message: String) -> void:
 checks += 1
 if not ok:
  failures += 1
  push_error(message)
func _initialize() -> void:
 call_deferred("run")
func make_prep(app: Node, with_dialogue: bool = true) -> RefCounted:
 var people: Array = app.content.collections.staff.duplicate(true)
 if not with_dialogue:
  for person in people:
   if person.id == ACTOR:person.erase("authored_dialogue")
 var prep = Preop.new(app.content.collections.preops[0], people, app.content.collections.surgeries, app.content.collections.patients)
 prep.stage_id = "ready"
 prep.team["assistant_surgeon"] = ACTOR
 return prep
func run() -> void:
 var app = load("res://godot/scenes/main.tscn").instantiate()
 root.add_child(app)
 await process_frame
 for locale in ["zh_CN", "en"]:
  expect(app.content.load_all(locale), "Load " + locale)
  app.configure_game_content()
  var g = app.game
  g.reset()
  var actor: Dictionary = app.content.find_record("staff", ACTOR)
  expect(actor.age == null and actor.adult and actor.public_age_label == "??", "Unknown adult age")
  expect(actor.skills.surgery == 94 and actor.skills.teamwork == 73, "Confirmed stats")
  expect(not g.staff_is_met(ACTOR) and not g.staff_can_join_surgery_team(ACTOR), "Initially unavailable")
  for loc in app.content.collections.locations:
   expect(ACTOR not in g.staff_present_at(str(loc.id)), "Unmet map exclusion " + str(loc.id))
  for event in app.content.collections.character_events:
   expect(event.actor_id != ACTOR or str(event.id).begins_with("takemi_lv0_t"), "Only authored Lv0 events")
  var count := 0
  for pool in actor.authored_dialogue.values():
   for line in pool:
    expect(line is String and not line.is_empty(), "Localized inline dialogue")
    count += 1
  expect(count == 60, "All 60 pairs loaded")
  g.meet_staff(ACTOR) # Isolated test fixture, never a production unlock.
  expect(g.staff_can_join_surgery_team(ACTOR), "Future introduction grants assistant eligibility")
  expect(actor.surgical_roles == ["assistant_surgeon"], "Assistant only")
  expect(not make_prep(app).qualified(ACTOR, {"id":"primary_surgeon","profession":"doctor"}), "Primary role forbidden")
  for action in ["choose_general", "choose_local", "choose_epidural", "choose_none"]:
   var prep = make_prep(app)
   var control = make_prep(app, false)
   expect(prep.apply({"kind":"action", "id":action}), "Choose " + action + ": " + prep.last_error)
   expect(control.apply({"kind":"action", "id":action}), "Control choose")
   if action == "choose_none":
    expect(not prep.assistant_anesthesia_reacted, "Provisional choice does not react")
    expect(prep.apply({"kind":"action", "id":"insist_without_anesthesia"}), "Confirm none")
    expect(control.apply({"kind":"action", "id":"insist_without_anesthesia"}), "Control confirm")
   expect(prep.assistant_anesthesia_reacted, "Actual choice reacts")
   expect(prep.assistant_presentation_expression() == ("pleased" if action == "choose_none" else "bored"), "Correct expression")
   var branch := "none" if action == "choose_none" else "with_anesthesia"
   var matched := false
   for line in actor.authored_dialogue["surgical_assistant_dialogue.anesthesia_selected." + branch]:
    if prep.feedback.contains(line):matched = true
   expect(matched, "Exact authored reaction")
   g.preops[str(prep.definition.id)] = prep
   g.active_preop_id = str(prep.definition.id)
   expect(not g.can_save_progress() and g.snapshot().is_empty(), "No saving during reaction")
   g.active_preop_id = ""
   var durable: String = JSON.stringify(g.snapshot())
   expect(not durable.contains("assistant_anesthesia") and not durable.contains("assistant_attitude"), "Reaction internals absent from durable save")
   g.preops.clear()
   for field in ["minutes","fear","pain","dignity","cooperation_base","player_effects","flags","procedure_state","player_effect_history"]:
    expect(prep.get(field) == control.get(field), "No mechanics changed " + field)
   var text: String = prep.feedback
   prep.present_assistant_anesthesia_reaction("choose_local")
   expect(text == prep.feedback, "Once per surgery")
   preload("res://godot/ui/preop_view.gd").render(app, prep)
   expect(app.page.get_node_or_null("AssistantAnesthesiaReaction") != null, "Reaction actually displayed before sensory testing")
   var portrait = app.page.get_node_or_null("CharacterPortrait")
   expect(portrait != null and portrait.texture.resource_path.ends_with("/" + prep.assistant_presentation_expression() + ".png"), "Correct expression texture rendered")
   var elapsed_before: int = prep.minutes
   expect(prep.apply({"kind":"assistant_anesthesia_ack"}), "Acknowledge reaction")
   expect(not prep.assistant_anesthesia_pending and prep.minutes == elapsed_before, "Presentation costs no time")
   expect(prep.assistant_presentation_expression() == "neutral", "Expression expires")
   expect(not prep.assistant_completion_line(true).is_empty(), "Success pool")
   expect(not prep.assistant_completion_line(false).is_empty(), "Failure pool")
  var absent = make_prep(app)
  absent.team.erase("assistant_surgeon")
  absent.present_assistant_anesthesia_reaction("choose_general")
  expect(not absent.assistant_anesthesia_reacted, "Not assigned cannot speak")
  for key in actor.visuals.portraits:
   var texture = load("res://" + str(actor.visuals.portraits[key]))
   expect(texture is Texture2D, "Texture " + key)
   var img: Image = texture.get_image() if texture is Texture2D else null
   expect(img != null and img.get_pixel(0,0).a == 0.0, "Alpha " + key)
 print("TAKEMI REGISTRATION: %s checks, %s failures" % [checks, failures])
 quit(1 if failures else 0)
