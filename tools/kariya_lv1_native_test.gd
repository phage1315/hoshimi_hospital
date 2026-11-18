extends SceneTree
const ID = "kariya_lv1_butcher_shop_girl"
const ACTOR = "nurse_kariya_megumi"
const QA = "res://docs/qa/kariya_lv1_2026-11-16/"
var app
var checks := 0
var failures := 0
var screenshots := {}
var source_rows := {}
var english := {}
func _initialize() -> void:
 call_deferred("run")
func expect(ok: bool, msg: String) -> void:
 checks += 1
 if not ok:
  failures += 1
  push_error(msg)
func click(button: Button) -> void:
 expect(is_instance_valid(button), "button exists")
 if not is_instance_valid(button):return
 var pos := button.get_global_rect().get_center()
 var motion := InputEventMouseMotion.new()
 motion.position = pos
 root.push_input(motion, true)
 for down in [true, false]:
  var event := InputEventMouseButton.new()
  event.button_index = MOUSE_BUTTON_LEFT
  event.pressed = down
  event.position = pos
  root.push_input(event, true)
 await process_frame
 await process_frame
func run() -> void:
 expect(DisplayServer.get_name() != "headless", "native renderer")
 var manifest = JSON.parse_string(FileAccess.get_file_as_string("res://research/imports/kariya_lv1_2026-11-16.json"))
 for r in manifest.rows:source_rows[r.id] = r
 for line in FileAccess.get_file_as_string("res://research/translations/kariya_lv1_en.txt").split("\n"):
  if line.contains("|"):
   var split: int = line.find("|")
   english["km1_" + line.substr(0, split)] = line.substr(split + 1)
 app = load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path = "/private/tmp/kariya_native_unused_%s.json" % OS.get_process_id()
 app.title_preferences_path = "/private/tmp/kariya_native_prefs_%s.cfg" % OS.get_process_id()
 app.title_notice_enabled = false
 root.add_child(app)
 await process_frame
 for locale in ["zh_CN", "en"]:
  expect(app.content.load_all(locale), "locale loads")
  app.configure_game_content()
  app.dialogue_auto_enabled = false
  for branch in ["a", "b", "c"]:
   app.game.reset()
   app.game.meet_staff(ACTOR)
   app.game._complete_character_event_for_test("intro_kariya_megumi_june", 62)
   app.game.relation_for(ACTOR).familiarity = 10
   app.game.advance_story_to_day(64, 540)
   expect(app.game.next_character_event_at("ward").get("id", "") == ID, "formal ward scheduler")
   app.show_map(false)
   await process_frame
   await click(app.page.get_node_or_null("Location_ward"))
   expect(app.game.active_character_event_id == ID, "map ward GUI enters authored event")
   if app.game.active_character_event_id != ID:
    print("STOP: wrong ward event ", app.game.active_character_event_id)
    quit(1)
    return
   var ev = app.game.character_events[ID]
   var steps := 0
   var previous_id := ""
   while not ev.completed and steps < 400:
    var n: Dictionary = ev.current()
    expect(not app.game.can_save_progress(), "live save locked")
    if n.id == "km1_choice":
     var b = app.page.get_node_or_null("EventChoice_km1_reply_" + branch)
     await RenderingServer.frame_post_draw
     if not screenshots.has(locale + "choice"):
      root.get_texture().get_image().save_png(QA + locale + "_choice.png")
      screenshots[locale + "choice"] = true
     await click(b)
     previous_id = str(n.id)
     steps += 1
     continue
    var expected: String = source_rows[n.id].text if locale == "zh_CN" else english[n.id]
    expect(n.text == expected, "exact localized source " + str(n.id))
    # CG reveal uses a real 2-second timer; wait until the real UI button is shown.
    var deadline: int = Time.get_ticks_msec() + 5000
    while (not is_instance_valid(app.dialogue_default_button) or not app.dialogue_default_button.is_visible_in_tree()) and Time.get_ticks_msec() < deadline:
     await process_frame
    await process_frame
    var page_text: String = app.current_dialogue_text()
    expect(expected.contains(page_text) and not page_text.is_empty(), "displayed authored page")
    for label in app.page.find_children("*", "RichTextLabel", true, false):
     if label.text == page_text:
      expect(label.get_content_height() <= label.size.y + 2, "dialogue fits " + str(n.id))
    if not n.get("cg_path", "").is_empty():
     var cg = app.page.get_node_or_null("CharacterEventCG")
     expect(cg != null and cg.texture.resource_path == "res://" + n.cg_path, "CG displayed")
    for art in n.get("event_portraits", []):
     var sprite = app.page.get_node_or_null("EventPortrait_" + art.id)
     expect(sprite != null and sprite.texture.resource_path == "res://" + art.path, "correct portrait " + art.id)
    if branch == "a" and n.id in ["km1_006", "km1_023", "km1_036", "km1_050", "km1_058", "km1_090", "km1_122", "km1_132"] and not screenshots.has(locale + n.id):
     await RenderingServer.frame_post_draw
     root.get_texture().get_image().save_png(QA + locale + "_" + n.id + ".png")
     screenshots[locale + n.id] = true
    await click(app.dialogue_default_button)
    steps += 1
    if failures:
     print("STOP: ", n.id)
     quit(1)
     return
   expect(ev.completed, "GUI branch complete " + branch)
   expect(app.game.relationship_level(ACTOR) == 1, "rank1")
   var before: int = app.game.elapsed()
   app.game.finish_character_event()
   app.show_map(false)
   expect(app.game.can_save_progress(), "back at safe map")
   app.show_gallery_entry(ID)
   await process_frame
   expect(app.page.get_node("GalleryCG").texture.resource_path == "res://assets/events/kariya_lv1_v1/butcher_misunderstanding.png", "gallery cover")
   expect(app.game.elapsed() == before, "gallery does not settle time again")
   print("NATIVE COMPLETE ", locale, " branch ", branch, " GUI steps ", steps)
 print("KARIYA LV1 NATIVE: %s checks; %s failures; %s screenshots" % [checks, failures, screenshots.size()])
 app.queue_free()
 await process_frame
 quit(1 if failures else 0)
