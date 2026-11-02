extends "res://tools/advanced_surgery_test.gd"
const Rules = preload("res://godot/systems/advanced_referral_rules.gd")
const Presentation = preload("res://godot/systems/advanced_presentation.gd")
const Dialogue = preload("res://godot/systems/advanced_operative_dialogue.gd")
const Story = preload("res://godot/systems/advanced_first_story.gd")
const IDS := ["surgery_adv_complex_abdominal_reconstruction", "surgery_adv_open_descending_thoracic_aortic_replacement"]

# Godot JSON reads integer values as floats; compare values without requiring type identity.
func same_values(a: Variant, b: Variant) -> bool:
 if a is Dictionary and b is Dictionary:
  if a.size()!=b.size(): return false
  for key in a:
   if not b.has(key) or not same_values(a[key],b[key]): return false
  return true
 if a is Array and b is Array:
  if a.size()!=b.size(): return false
  for i in range(a.size()):
   if not same_values(a[i],b[i]): return false
  return true
 if (a is float or a is int) and (b is float or b is int): return float(a)==float(b)
 return a==b

func run_case(s: RefCounted, alternative: bool) -> void:
 var plan := Model.plan(s.definition, s.team)
 var pi := 0
 for _guard in range(200):
  if s.finished: break
  if s.in_crisis(): expect(s.resolve_crisis("pause_and_stabilize"), "Existing crisis resolver")
  elif s.pending_rescue: expect(s.rescue(0), "Correction resolved")
  elif s.awaiting_ack: expect(s.acknowledge(), "Advance stage")
  else:
   var who := int(plan[pi]) if s.current().kind == "P" else 0
   if s.current().kind == "P": pi += 1
   var options: Array = s.strategy_options()
   var option := str(options[-1 if alternative else 0].id) if not options.is_empty() else ""
   expect(s.act(who, option), "Stage/strategy accepted")
 expect(s.finished, "Full physiology reaches terminal result")
 expect(s.used[0] <= 2 and s.used[1] <= 2, "Assistant caps preserved")

func run() -> void:
 var g := new_game()
 var controller := Referral.new(g, true)
 var before: Dictionary = g.snapshot()
 for id in IDS:
  expect(Rules.procedure_ready(id), "Unique field artwork completes release")
  expect(controller.board().any(func(r): return r.procedure_id == id), "Public DEV entry available")
  var formal := Referral.new(new_game(), false)
  expect(not formal.board().any(func(r): return r.procedure_id == id), "New campaign still requires normal unlocks")
  var record := {"id":"qa_"+id,"procedure_id":id,"patient_id":Story.patient({"procedure_id":id},false).id,"replay":false}
  var released := Referral.new(g, true)
  released.local_facts.appointment = {"case":record,"intake_day":released.day()-1,"operation_day":released.day(),"team":Presentation.DEFAULT_TEAM}
  expect(released.start_operation(), "Released procedure starts with real team")
  var field_session = released.session
  var config := Dialogue.field_config(id)
  expect(not Dialogue.field_visible(field_session),"Field stays hidden during anesthesia and team confirmation")
  field_session.splash_pending = false
  field_session.patient_ready_pending = false
  field_session.team_intro_index = -1
  expect(Dialogue.field_visible(field_session) and Dialogue.field_path(field_session)==config.incision_path,"First stage uses approved incision")
  field_session.index = 1
  expect(Dialogue.field_visible(field_session) and Dialogue.field_path(field_session)==config.path,"Open stage uses supplied unique field")
  var texture = load("res://" + Dialogue.field_path(field_session))
  expect(texture is Texture2D and texture.get_size()==Vector2(1280,1024),"Unique field imports at original resolution")
  field_session.index = field_session.definition.steps.size()-1
  expect(Dialogue.field_visible(field_session) and Dialogue.field_path(field_session)==config.closure_path,"Final stage uses approved closure")
  var def := Model.procedure(id)
  var dialogue := Dialogue.new(id)
  expect(not dialogue.data.is_empty(), "Day2 schema accepted by runtime")
  for stage in dialogue.data.get("stages", {}):
   for trigger in dialogue.data.stages[stage]:
    for row in dialogue.data.stages[stage][trigger]:
     var actor := Dialogue.bind_role(row.speaker_role,Presentation.DEFAULT_TEAM,{"actor":1})
     expect(not actor.is_empty() and not row.text.is_empty() and not row.text_en.is_empty(), "All authored Day2 variants bind a speaker and bilingual text")
  var values := controller.values(Presentation.DEFAULT_TEAM, id)
  var successes := 0
  var failed := 0
  for seed_value in range(8):
   var session := Session.new(def,values,seed_value,g.staff,Presentation.DEFAULT_TEAM)
   run_case(session,seed_value % 2 == 1)
   if session.success: successes += 1
   else: failed += 1
  print(id, " smoke outcomes (not balance estimate): ",successes," success / ",failed," failed")
  var exhausted := Session.new(def,values,0,g.staff,Presentation.DEFAULT_TEAM)
  exhausted.hp = 0; exhausted.check_failure()
  expect(exhausted.finished and not exhausted.success,"HP failure terminates")
  var replay := record.duplicate(true); replay.replay = true; replay.patient_id = Presentation.random_patient_ids(g)[0]
  if id == IDS[1]:
   expect(not Rules.replay_compatible(replay),"Misa unspecified subtype rejected")
   replay.case_subtype = Rules.replay_profile(id).case_subtype
  expect(Rules.replay_compatible(replay),"Approved subtype accepted")
  expect(Story.content(replay).is_empty(),"Replay does not borrow authored first-patient story")
  var patient := Presentation.patient(replay,g,false)
  expect(patient.diagnosis == Rules.replay_profile(id).diagnosis,"Replay uses applicable clinical diagnosis")
 # Released cases must also obey calendar and board capacity in the formal pool.
 var pool := Facts.fresh(); pool.activated_day = 3
 for row in Rules.manifest():
  if int(row.release_order)<=4: pool.procedures[row.procedure_id] = "FAILED_LOCKED"
 Rules.update_pool(pool,62,123,["patient_sora"])
 for id in IDS: expect(id in pool.new_board,"Normal release cadence can issue newly ready procedure")
 # Isolate the Misa weekly draw to verify its required clinical subtype.
 var rows: Array = Rules.manifest().filter(func(r): return r.procedure_id == IDS[1])
 rows[0].runtime_ready = true
 var facts := Facts.fresh(); facts.activated_day = 3
 facts.procedures[IDS[1]] = "CLEARED"; facts.clear_days[IDS[1]] = 8
 Rules.update_pool(facts,14,123,["patient_sora"],rows)
 expect(facts.replays.size()==2,"Eligible weekly replay generated")
 for r in facts.replays:
  expect(Facts.case_valid(r) and Rules.replay_compatible(r),"Generated case has applicable stable subtype")
 expect(Facts.valid(facts),"Subtype accepted by persistent business-fact whitelist")
 var restored: Dictionary = JSON.parse_string(JSON.stringify(facts))
 expect(Facts.valid(restored) and same_values(restored,facts),"Stable subtype JSON roundtrip")
 var persistence_game := new_game()
 persistence_game.advance_story_to_day(14,540)
 persistence_game.advanced_referral_facts = facts.duplicate(true)
 var snapshot: Dictionary = persistence_game.snapshot()
 expect(not snapshot.is_empty(),"Safe-boundary snapshot available")
 expect(same_values(snapshot.advanced_referral_facts.replays,facts.replays),"Safe-boundary capture preserves generated subtype cases")
 expect(persistence_game.restore(JSON.parse_string(JSON.stringify(snapshot))),"Clinical subtype restores through full game save contract")
 expect(same_values(persistence_game.advanced_referral_facts,snapshot.advanced_referral_facts),"Full restore retains exact settled clinical facts")
 var second: Dictionary = persistence_game.snapshot()
 expect(persistence_game.restore(JSON.parse_string(JSON.stringify(second))),"Repeated restore succeeds")
 expect(same_values(persistence_game.snapshot(),second),"Repeated restore preserves clock, stats, rewards and clinical facts")
 no_inner(facts)
 var invalid: Dictionary = facts.replays[0].duplicate(true);invalid.stage_id="M08"
 expect(not Facts.case_valid(invalid),"Event node cannot be persisted as clinical subtype data")
 expect(g.snapshot()==before,"Internal tests leave campaign state unchanged")
 await story_ui()
 print("IZUMI/MISA INTERNAL QA: ",checks," checks / ",failures," failures")
 quit(0 if failures==0 else 1)

func story_ui() -> void:
 var app = load("res://godot/scenes/main.tscn").instantiate()
 app.saves.path = "/tmp/izumi_misa_unused_%s.json" % OS.get_process_id()
 root.add_child(app)
 await process_frame
 for locale in ["zh_CN","en"]:
  expect(app.content.load_all(locale),"Bilingual content loads")
  app.configure_game_content()
  app.advanced_controller = null
  app.show_advanced_referral(true)
  var saved: Dictionary = app.game.snapshot()
  var view = app.page.get_node("AdvancedReferralView")
  for id in IDS:
   var record := {"procedure_id":id,"replay":false}
   var content := Story.content(record)
   for phase in ["day1","day3"]:
    app.advanced_controller.begin_story(phase,record)
    for i in range(content[phase].lines.size()):
     app.advanced_controller.story_index = i
     view.render()
     await process_frame
     var line: Dictionary = content[phase].lines[i]
     var cast = app.page.get_node("AdvancedCast")
     expect(cast.get_meta("source_text")==line.text_en if locale=="en" else cast.get_meta("source_text")==line.text,"UI displays exact localized source")
     expect(cast.get_meta("actor_id")==content.patient.id if line.speaker=="patient" else cast.get_meta("actor_id")=="PLAYER","Speaker identity matches")
     var art: TextureRect = cast.get_node("AdvancedActorPortrait")
     expect((art.texture!=null)==(line.speaker=="patient"),"Only actual patient speaker has patient portrait")
     if line.speaker=="patient":
      expect(cast.get_meta("portrait_path")==content.patient.visuals.portraits[content[phase].portrait],"Correct ward/postop asset")
  expect(app.game.snapshot()==saved,"Bilingual presentation leaves persistent values unchanged")
 app.queue_free()
 await process_frame
