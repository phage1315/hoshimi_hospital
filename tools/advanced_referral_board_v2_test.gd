extends "res://tools/advanced_referral_rules_v2_test.gd"
## Native formal board smoke test; only isolated in-memory world and /tmp captures.
func run() -> void:
 var app=load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path="/tmp/advanced_board_v2_unused_%s.json"%OS.get_process_id()
 root.add_child(app)
 await process_frame
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  var g=app.game
  g.surgery_xp=g.surgery_xp_for_level(88);g.archived_player_effects.reputation=300
  g.set_test_time(date("2025-07-10"),540);grant(g,date("2025-07-10"))
  app.advanced_controller=null;app.show_advanced_referral(false)
  var c=app.advanced_controller
  var v=app.page.get_node("AdvancedReferralView")
  expect(not c.dev and c.board().size()==3,"Formal board has first three only")
  var ids: Array=Rules.manifest().map(func(row):return row.procedure_id)
  expect(c.board().map(func(row):return row.procedure_id)==ids.slice(0,3),"Formal release order")
  g.advance_story_to_day(date("2025-08-04"),540)
  c.state().procedures[ids[0]]="CLEARED";c.state().clear_days[ids[0]]=date("2025-08-01")
  c.state().week=-1
  c.state().cooldowns={"doc_emiko":130,"doc_artoria":130}
  v.render();await process_frame;await process_frame
  expect(c.board().size()==5,"Formal three new plus two replay offers")
  var lines=[]
  for node in v.body.get_children():
   if node is Label or node is Button:lines.append(node.text)
  expect(v.tr_key("new_pool") in lines and v.tr_key("replay_pool") in lines,"Separated localized sections")
  for id in c.state().cooldowns:
   expect(v.tr_key("cooldown")%[v.actor_name(id),130] in lines,"Localized cooldown name")
  expect(not str(lines).contains("doc_emiko") and not str(lines).contains("doc_artoria"),"No internal IDs")
  if DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("/tmp/advanced_board_v2_%s.png"%locale)
 app.queue_free();await process_frame
 print("ADVANCED FORMAL BOARD V2: %s checks; %s failures"%[checks,failures])
 quit(1 if failures else 0)
