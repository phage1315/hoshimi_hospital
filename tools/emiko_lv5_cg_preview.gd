extends "res://tools/emiko_lv5_preview_capture.gd"

func run() -> void:
 expect(DisplayServer.get_name() != "headless", "native display")
 var output = "res://docs/qa/emiko_lv5_cg_2026-11-18/pass2/"
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
 var save_path = "/private/tmp/emiko_cg_unused_%d.json" % OS.get_process_id()
 app = load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path = save_path
 app.title_preferences_path = "/private/tmp/emiko_cg_prefs_%d.cfg" % OS.get_process_id()
 app.title_notice_enabled = false
 root.add_child(app)
 await process_frame
 var mapping = JSON.parse_string(FileAccess.get_file_as_string("res://data/staff/doc_emiko/cg_mapping.json"))
 for locale in ["zh_CN", "en"]:
  expect(app.content.load_all(locale), "locale loads")
  app.configure_game_content()
  app.dialogue_auto_enabled = false
  for eid in ["emiko_lv5_hands_of_god"]:
   app.game.reset()
   var helper = load("res://godot/systems/emiko_lv5.gd")
   helper.prepare_test_save(app.game, eid, 21)
   set_exact_day_clock(app.game, 21, 990)
   app.show_map(false)
   await process_frame
   await click(app.page.get_node("Location_player_office"), "office entry")
   await click(app.page.get_node("OfficeEndWorkday"), "end workday entry")
   await process_frame
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
    if ev.current().get("choices", []).is_empty():
     continue
    var next_id = str(ev.current().choices[0].get("next", ""))
    if next_id.is_empty() or next_id == "@end":
     continue
    ev.node_id = next_id
    app.reset_dialogue_page()
    app.show_character_event()
    await process_frame
    expect(app.page.get_node_or_null("CharacterEventCG") == null, "CG clears after scene")
   expect(ResourceLoader.exists("res://" + mapping[eid].cover), "gallery texture exists")
   ev.node_id = "em5_s6m_04"
   app.reset_dialogue_page()
   app.character_event_last_cg_path = "assets/events/emiko_lv5_cg_v1/corridor_lapel.png"
   app.show_character_event()
   await process_frame
   var end_cg = app.page.get_node_or_null("CharacterEventCG")
   expect(end_cg != null and end_cg.texture.resource_path == "res://" + mapping[eid].cover, locale + " em5_s6m_04 renders corridor_lapel CG")
   var guard := 0
   while not ev.completed and guard < 10:
    guard += 1
    await process_frame
    await click(app.dialogue_default_button, locale + " final node em5_s6m_04 continue")
   expect(app.screen == "character_event_reward", locale + " reached character_event_reward")
   var rew_cg = app.page.get_node_or_null("EventRewardCG")
   expect(rew_cg != null and rew_cg.texture != null and rew_cg.texture.resource_path == "res://" + mapping[eid].cover, locale + " EventRewardCG texture")
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(ProjectSettings.globalize_path(output + locale + "_event_reward_card.png"))
   var rew_btn := app.page.get_node_or_null("EventRewardContinue") as Button
   expect(rew_btn != null, locale + " EventRewardContinue button")
   if rew_btn != null:
    await click(rew_btn, locale + " EventRewardContinue")
   expect(app.screen == "character_event_complete", locale + " reached character_event_complete")
   var ret_btn := find_return_map_button()
   expect(ret_btn != null, locale + " ReturnMap button")
   if ret_btn != null:
    await click(ret_btn, locale + " ReturnMap")
   expect(app.screen == "map" and app.game.can_save_progress(), locale + " returned to saveable map")
 print("EMIKO LV5 CG NATIVE CHECKPOINTS: %d checks; %d failures; %d GUI clicks; 16 screenshots" % [checks, failures, gui_clicks])
 DirAccess.remove_absolute(save_path)
 DirAccess.remove_absolute(app.title_preferences_path)
 app.queue_free()
 await process_frame
 quit(1 if failures else 0)
