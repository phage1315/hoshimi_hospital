extends "res://tools/game_random_40_screens.gd"
const OUT="res://docs/qa/followup_event_fixes_2026-10-27/"
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_followup_unused.json";root.add_child(app);await process_frame
 var records:Array=[]
 for locale in ["zh_CN","en"]:
  for item in [["takemi_lv0_t6","t6_14",false],["takemi_lv0_t6","t6_15",false],["takemi_lv0_t6","t6_60",false],["advanced_referral_tutorial_chisato","opening",true],["advanced_referral_tutorial_chisato","artoria_sets_scope",true],["advanced_referral_tutorial_chisato","artoria_room_ready",true],["advanced_referral_tutorial_chisato","artoria_debrief_team",true]]:
   reset_scene(locale);event_scene(item[0],item[1],item[2]);await process_frame;await RenderingServer.frame_post_draw
   var filename=locale+"_"+str(item[0])+"_"+str(item[1])+".png"
   root.get_texture().get_image().save_png(OUT+filename)
   var row={"locale":locale,"event":item[0],"node":item[1],"screenshot":filename,"textures":[],"labels":label_texts()}
   for c in app.page.find_children("*","TextureRect",true,false):
    if c.texture:row.textures.append({"widget":str(c.name),"path":c.texture.resource_path,"position":str(c.position),"size":str(c.size)})
   records.append(row)
 var f=FileAccess.open(OUT+"display_observations.json",FileAccess.WRITE);f.store_string(JSON.stringify(records,"  "));f.close()
 print("FOLLOWUP DISPLAY 14 screenshots");quit()
