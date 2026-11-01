extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const C = preload("res://godot/systems/advanced_referral.gd")
const P = preload("res://godot/systems/advanced_presentation.gd")
const M = preload("res://godot/systems/advanced_surgery_model.gd")
func _initialize(): call_deferred("run")
func run():
 var app=load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path="/tmp/advanced_timeout_inventory_unused.json"
 root.add_child(app);await process_frame
 var rows=[]
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  var c=C.new(app.game,true)
  for role in c.ROLES:
   for person in c.candidates(role,1):
    var outputs={}
    for procedure in M.catalog():outputs[procedure.id]=P.line(app.game,person.id,role,"timeout",procedure.id,locale=="en")
    rows.append({"locale":locale,"id":person.id,"name":person.name,"role":role,"team_dialogue":person.get("team_dialogue",{}),"groups":person.get("procedure_group_team_dialogue",{}),"replies":person.get("team_assignment_replies",{}),"authored":person.get("authored_dialogue",{}),"outputs":outputs})
 var f=FileAccess.open("/tmp/advanced_timeout_inventory.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close()
 print("TIMEOUT INVENTORY: ",rows.size()," localized staff-slot rows")
 quit()
