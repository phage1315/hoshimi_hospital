extends "res://tools/event_batch_native_qa.gd"
var failures=0
var checks=0
func expect(ok:bool,message:String):
 checks+=1
 if not ok:failures+=1;push_error(message)
func run():
 app=load("res://godot/scenes/main.tscn").instantiate();app.saves.path="/tmp/hoshimi_render_regression_unused_"+str(OS.get_process_id())+".json";root.add_child(app);await process_frame
 for locale in ["zh_CN","en"]:
  app.content.load_all(locale);app.configure_game_content()
  var text="Sayaka accompanies the patient into the operating room first, completes the preoperative verification, and temporarily takes the first-assistant position. Kaori scrubs, caps, masks, and enters the operating room to put on a sterile gown. She did not return to the changing room."
  var split=app.dialogue_hard_wrap(text)
  expect("".join(split)==text,"Hard wrap changed text")
  for i in range(split.size()-1):expect(split[i].ends_with(" ") or split[i+1].begins_with(" "),"Split English word between pages")
  var quoted:Array[String]=["Before:","“A long quoted", " utterance.”", "After:","“Second.”"]
  for i in range(quoted.size()):expect(app.dialogue_quote_index(quoted,i)==[-1,0,0,-1,1][i],"Quote owner lost across pages")
  var narrator=app.tx("ui.auto.ed1d855fc574","旁白")
  expect(app.event_dialogue_presentation({"speaker":"narrator","speaker_label":"NPC"},{"text":"unquoted inner thought","quote_index":-1},"NPC","Actor").speaker=="NPC","Explicit inner-speech label overwritten")
  expect(app.event_dialogue_presentation({"speaker":"narrator","speaker_label":"NPC"},{"text":"“Speech”","quote_index":0},"NPC","Actor").speaker=="NPC","NPC replaced by event principal")
  expect(app.event_dialogue_presentation({"speaker":"narrator"},{"text":"Narration","quote_index":-1},narrator,"Actor").speaker==narrator,"Narration changed to actor")
  var counter={"value":0}
  app.base("Input regression","Isolated UI fixture");app.screen="character_event"
  var b=app.button_at("Continue",Vector2(60,480),Vector2(655,54),func():counter.value+=1)
  app.register_dialogue_continue(b,"Long enough to keep the auto timer pending.");app.add_dialogue_playback_controls();await process_frame
  await click(app.dialogue_auto_toggle_button);await click(app.dialogue_auto_toggle_button)
  var before=counter.value
  print("INPUT_FOCUS ",locale," ",root.gui_get_focus_owner())
  await key(KEY_SPACE)
  expect(counter.value==before+1,"Space after Auto clicks failed to continue exactly once")
  app.dialogue_auto_enabled=false
  before=counter.value;await key(KEY_ENTER)
  expect(counter.value==before+1,"Enter after Auto clicks failed to continue exactly once")
  app.base("Choice","Choice input fixture");app.pause_dialogue_for_choice();app.add_dialogue_playback_controls();await process_frame
  await key(KEY_SPACE);expect(counter.value==before+1,"Space selected a branch without selection")
 print("EVENT RENDERING REGRESSION ",checks," checks; ",failures," failures")
 app.queue_free();await process_frame;quit(1 if failures else 0)
