extends SceneTree
func _initialize():call_deferred("run")
func run():
 var app=load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path="/tmp/hoshimi_export_parity/unused_save.json"
 root.add_child(app)
 await process_frame
 var paths=["assets/events/advanced_referral_tutorial_chisato/chisato_postop_v1.png","assets/events/advanced_referral_tutorial_chisato/cg_sayaka_holds_chisato_v1.png"]
 var rows=[]
 for path in paths:
  var full="res://"+path
  var node={"id":"export_probe","expression":"neutral","speaker":"narrator"}
  node["cg_path" if "cg_" in path else "portrait_path"]=path
  app.screen="special_event";app.base("Export resource reproduction","",false,"operating_room")
  app.add_special_event_visual(node)
  await process_frame;await RenderingServer.frame_post_draw
  var rendered=[]
  for c in app.page.find_children("*","TextureRect",true,false):
   if c.texture and c.texture.resource_path==full:rendered.append(str(c.name))
  rows.append({"path":path,"raw_file_exists":FileAccess.file_exists(full),"resource_exists":ResourceLoader.exists(full),"load_ok":load(full)!=null,"rendered":rendered})
  root.get_texture().get_image().save_png("/Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital/docs/qa/export_resource_parity_2026-10-31/before_"+path.get_file())
 var f=FileAccess.open("/Users/ningye/Documents/Codex/2026-09-20/wo/outputs/hoshimi-hospital/docs/qa/export_resource_parity_2026-10-31/before.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close()
 print(JSON.stringify(rows));quit()
