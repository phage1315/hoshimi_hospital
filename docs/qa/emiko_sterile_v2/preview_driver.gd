extends SceneTree
func _initialize():
 call_deferred("run")
func run():
 var app=load("res://godot/scenes/main.tscn").instantiate()
 app.title_notice_enabled=false
 app.saves.path="/private/tmp/emiko_sterile_unused_%s.json" % OS.get_process_id()
 app.title_preferences_path="/private/tmp/emiko_sterile_prefs_%s.cfg" % OS.get_process_id()
 root.add_child(app)
 await process_frame
 var actor=app.content.find_record("staff","doc_emiko")
 for expression in ["neutral","focused","worried","warm"]:
  app.base("Emiko / "+expression,"Portrait rendering checkpoint",true,"operating_room")
  app.add_portrait(actor,expression,"sterile")
  await create_timer(0.5).timeout
  var portrait=app.page.get_node("CharacterPortrait")
  assert(portrait.texture.resource_path=="res://assets/characters/portrait_pack_v14/doc_emiko/sterile/%s.png" % expression)
  assert(portrait.texture.get_size()==Vector2(1024,1536))
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://docs/qa/emiko_sterile_v2/native_%s.png" % expression)
 print("EMIKO STERILE: 4 native portrait checkpoints passed")
 app.queue_free()
 await process_frame
 quit()
