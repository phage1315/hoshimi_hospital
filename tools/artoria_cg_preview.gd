extends "res://tools/artoria_lv3_preview_capture.gd"

func run() -> void:
 var output = "res://docs/qa/artoria_cg_2026-11-16/"
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
 var save_path = "/private/tmp/artoria_cg_unused_%d.json" % OS.get_process_id()
 app = load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path = save_path
 app.title_preferences_path = "/private/tmp/artoria_cg_prefs_%d.cfg" % OS.get_process_id()
 app.title_notice_enabled = false
 root.add_child(app)
 await process_frame
 var mapping = JSON.parse_string(FileAccess.get_file_as_string("res://data/staff/doc_artoria/cg_mapping.json"))
 for locale in ["zh_CN", "en"]:
  expect(app.content.load_all(locale), "locale loads")
  app.configure_game_content()
  app.dialogue_auto_enabled = false
  for eid in mapping:
   app.game.reset()
   var helper = load("res://godot/systems/artoria_lv2.gd") if str(eid).contains("lv2") else load("res://godot/systems/artoria_lv3.gd")
   var day = helper.prepare_test_save(app.game, eid, 11)
   set_exact_day_clock(app.game, day, 960)
   app.show_player_office()
   await process_frame
   await click(app.page.get_node("OfficeEndWorkday"), "formal event entry")
   expect(app.game.active_character_event_id == eid, "formal entry " + eid)
   var ev = app.game.character_events[eid]
   for scene in mapping[eid].scenes:
    # In-memory rendering checkpoints only; never serialized as saves.
    ev.node_id = scene.nodes[0]
    app.reset_dialogue_page()
    app.character_event_last_cg_path = ""
    app.show_character_event()
    await process_frame
    var cg = app.page.get_node_or_null("CharacterEventCG")
    expect(cg != null and cg.texture.resource_path == "res://" + scene.path, "CG texture " + scene.path)
    expect(app.page.find_children("EventPortrait_*", "TextureRect", true, false).is_empty(), "no portrait overlay")
    expect(not app.game.can_save_progress(), "event save locked")
    await create_timer(2.2).timeout
    await process_frame
    expect(is_instance_valid(app.dialogue_default_button) and app.dialogue_default_button.is_visible_in_tree(), "dialogue returns after reveal")
    await RenderingServer.frame_post_draw
    var filename = locale + "_" + str(scene.path).get_file()
    root.get_texture().get_image().save_png(ProjectSettings.globalize_path(output + filename))
    await click(app.dialogue_default_button, "CG dialogue continue")
    # Jump to the last CG node, then its narrative successor to verify exit.
    ev.node_id = scene.nodes[-1]
    var next_id = str(ev.current().choices[0].next)
    ev.node_id = next_id
    app.reset_dialogue_page()
    app.show_character_event()
    await process_frame
    expect(app.page.get_node_or_null("CharacterEventCG") == null, "CG clears after scene")
   expect(ResourceLoader.exists("res://" + mapping[eid].cover), "gallery texture exists")
 print("ARTORIA CG NATIVE CHECKPOINTS: %d checks; %d failures; %d GUI clicks; 16 screenshots" % [checks, failures, gui_clicks])
 app.queue_free()
 await process_frame
 quit(1 if failures else 0)
