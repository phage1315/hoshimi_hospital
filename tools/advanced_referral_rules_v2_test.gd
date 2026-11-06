extends "res://tools/advanced_surgery_test.gd"
const Rules = preload("res://godot/systems/advanced_referral_rules.gd")
const Calendar = preload("res://godot/systems/fixed_calendar.gd")
const Presentation = preload("res://godot/systems/advanced_presentation.gd")

func date(iso: String) -> int: return Calendar.day_for_iso(iso)
func activated(on: String) -> Dictionary:
 var s := Facts.fresh(); s.activated_day = date(on); return s
func tick(s: Dictionary, iso: String) -> void:
 Rules.update_pool(s,date(iso),123,["patient_a","patient_b"])
func grant(g: RefCounted, day_value: int) -> void:
 g.special_event_completion_counts[Rules.Tutorial] = 1
 g.special_event_completion_days[Rules.Tutorial] = day_value
 g.set_story_flag("advanced_referral_random_cases_enabled",true)
 g.sync_advanced_referral_calendar()
func result_record(id: String, procedure: String, day_value: int, success: bool = true) -> Dictionary:
 return {"case_id":id,"procedure_id":procedure,"success":success,"day":day_value,"minutes":600,"surgery_xp":528 if success else 0,"leadership_xp":8.0 if success else 0.0,"reputation":40 if success else 0}

func calendar_pool() -> void:
 var ids: Array = Rules.manifest().map(func(row): return row.procedure_id)
 expect(ids.size()==7 and ids[0]=="surgery_open_whipple" and ids[2]=="surgery_adv_sleeve_lobectomy" and ids[6]=="surgery_adv_posttraumatic_thoracolumbar_kyphosis_correction","Stable release manifest identities")
 var s:=activated("2025-07-10")
 tick(s,"2025-07-10")
 expect(s.unlocked==ids.slice(0,3) and s.new_board==ids.slice(0,3),"T02 July 10 first three")
 tick(s,"2025-07-15");expect(s.unlocked.size()==3,"No same-month fifteenth release")
 tick(s,"2025-08-01");expect(s.unlocked==ids.slice(0,4) and s.new_board==ids.slice(0,3),"T02 rank four waits behind full board")
 tick(s,"2025-08-15");expect(s.unlocked==ids.slice(0,5),"T02 rank five time eligibility")
 tick(s,"2025-09-01");expect(s.unlocked==ids.slice(0,6) and s.new_board==ids.slice(0,3),"T05 pending FIFO never replaces visible cases")
 for _i in range(3):tick(s,"2025-09-01")
 expect(s.unlocked.size()==6 and s.new_board.size()==3,"Catch-up idempotent")
 s.procedures[ids[0]]="CLEARED";s.clear_days[ids[0]]=date("2025-09-01");tick(s,"2025-09-01")
 expect(s.new_board==[ids[1],ids[2],ids[3]],"T06 settled success refills rank four")
 s.procedures[ids[1]]="FAILED_LOCKED";tick(s,"2025-09-01")
 expect(s.new_board==[ids[2],ids[3],ids[4]] and ids[5] not in s.new_board,"T07/T21 ready rank five refills board; rank six waits for space")
 tick(s,"2025-09-15");expect(s.unlocked==ids and ids[6] not in s.new_board,"Rank seven unlocks on the next calendar boundary and waits for a board slot")
 s=activated("2025-07-31");tick(s,"2025-07-31");tick(s,"2025-08-01")
 expect(s.unlocked==ids.slice(0,4),"T03 July 31 next day unlock")
 s=activated("2025-12-31");tick(s,"2026-01-01");expect(s.unlocked.size()==4,"Year rollover")
 tick(s,"2026-02-01");expect(s.unlocked.size()==6,"Calendar January 15 and February 1 counted")
 s=activated("2026-01-31");tick(s,"2026-02-01");expect(s.unlocked.size()==4,"Actual February boundary")
 tick(s,"2026-03-01");expect(s.unlocked.size()==6,"Actual 28-day February")
 var g:=new_game()
 g.surgery_xp=g.surgery_xp_for_level(88);g.archived_player_effects.reputation=300
 expect(not g.advanced_referral_system_unlocked(),"T01 before tutorial locked")
 g.set_story_flag("advanced_referral_random_cases_enabled",true)
 expect(not g.advanced_referral_system_unlocked(),"T01 early flag cannot unlock")
 g.set_test_time(date("2025-07-10"),540);grant(g,date("2025-07-10"))
 expect(g.advanced_referral_system_unlocked(),"Final completion activates")
 g.advance_story_to_day(date("2025-08-14"),540)
 expect(g.advanced_referral_facts.unlocked.size()==4,"Date advance updates without board")
 g.advance_story_to_day(date("2025-08-16"),540)
 expect(g.advanced_referral_facts.unlocked.size()==5,"T04 crossed fifteenth without opening board")
 g.advance_story_to_day(date("2026-03-30"),540)
 var end_controller:=Referral.new(g)
 expect(end_controller.schedule().is_empty() and g.advanced_referral_facts.unlocked.size()==7,"T22 year-end blocks scheduling but retains time eligibility")
 var before:Dictionary=g.advanced_referral_facts.duplicate(true)
 g.sync_advanced_referral_calendar();expect(g.advanced_referral_facts==before,"Same-date synchronization stable")

func weekly() -> void:
 var id:String=Rules.manifest()[0].procedure_id
 var second:String=Rules.manifest()[1].procedure_id
 var s:=activated("2025-04-03")
 Rules.update_pool(s,7,42,["a","b"]);expect(s.replays.is_empty(),"T10 no cleared procedure no patients")
 s.procedures[id]="CLEARED";s.clear_days[id]=8
 Rules.update_pool(s,9,42,["a","b"]);expect(s.replays.is_empty(),"No midweek clear refill")
 Rules.update_pool(s,14,42,["a","b"])
 expect(s.replays.size()==2 and s.replays[0].procedure_id==id and s.replays[1].procedure_id==id and s.replays[0].id!=s.replays[1].id,"T11 with replacement distinct instances")
 var frozen:Array=s.replays.duplicate(true)
 s.procedures[second]="CLEARED";s.clear_days[second]=15
 Rules.update_pool(s,20,42,["a","b"]);expect(s.replays==frozen,"T13 whole week stable despite new clear")
 s.appointment={"case":frozen[0].duplicate(true)}
 Rules.update_pool(s,21,42,["a","b"])
 expect(s.replays.size()==2 and s.appointment.case==frozen[0] and s.replays[0].id!=frozen[0].id,"T14 active old-week booking survives new batch")
 s.appointment={}
 var repeated:=false;var distinct:=false;var hits:Dictionary={id:0,second:0}
 for seed_value in range(120):
  s.week=-1;Rules.update_pool(s,21,seed_value,["a","b"])
  expect(s.replays.size()==2,"T12 exactly two draws")
  for record in s.replays:hits[record.procedure_id]+=1
  repeated=repeated or s.replays[0].procedure_id==s.replays[1].procedure_id
  distinct=distinct or s.replays[0].procedure_id!=s.replays[1].procedure_id
 expect(repeated and distinct and hits[id]>70 and hits[second]>70,"Independent uniform choices permit duplicates and distinct cases")
 var monday:=activated("2025-04-03");monday.procedures[id]="CLEARED";monday.clear_days[id]=14
 Rules.update_pool(monday,16,42,["a"]);expect(monday.replays.is_empty(),"Monday completion cannot enter earlier Monday draw on lazy catch-up")
 s.procedures[second]="FAILED_LOCKED";s.week=-1;Rules.update_pool(s,28,42,["a"])
 expect(s.replays.all(func(r):return r.procedure_id==id),"Failed first attempts never replay")
 # Independent same-procedure failure through real production settlement.
 var g:=new_game();g.set_test_time(28,540);grant(g,3)
 var c:=Referral.new(g);g.advanced_referral_facts=s
 var team:=Presentation.DEFAULT_TEAM.duplicate(true)
 s.appointment={"case":s.replays[0].duplicate(true),"team":team,"intake_day":25,"operation_day":26,"review_day":28,"intake_minutes":60}
 s.outcome={"case_id":s.replays[0].id,"success":false,"operation_day":26,"minutes":480}
 expect(c.settle(),"T15 failed replay settles")
 expect(s.procedures[id]=="CLEARED" and c.board().any(func(r):return r.id==s.replays[1].id) and not c.board().any(func(r):return r.id==s.replays[0].id),"T15 only one instance consumed, clearance retained")
 var after:Dictionary=s.duplicate(true);expect(not c.settle() and s==after,"T09 duplicate settlement no refill or mutation")

func gates_and_migration() -> void:
 var rows:=Rules.manifest();var s:=Facts.fresh()
 for i in range(4):s.procedures[rows[i].procedure_id]="CLEARED"
 s.procedures["surgery_adv_artificial_heart_exchange"]="CLEARED"
 s.procedures["surgery_legendary_thoracoabdominal_multivisceral_tumor_resection"]="CLEARED"
 expect(Rules.counts(s)=={"regular":4,"ray":4} and not Rules.kaori_available(s,Rules.KAORI[0],60),"T17/T20 tutorial legendary and repeats excluded")
 s.procedures[rows[4].procedure_id]="CLEARED"
 expect(Rules.kaori_available(s,Rules.KAORI[0],60),"T18 fifth distinct regular clear enables first quest interface")
 s.procedures[Rules.KAORI[0]]="CLEARED";s.successful_operation_days[Rules.KAORI[0]]=50
 expect(not Rules.kaori_available(s,Rules.KAORI[1],79) and Rules.kaori_available(s,Rules.KAORI[1],80),"T19 next intake exactly actual operation +30")
 s.procedures[Rules.KAORI[0]]="FAILED_LOCKED"
 expect(not Rules.kaori_available(s,Rules.KAORI[1],90),"Quest failure does not advance")
 s.procedures[Rules.KAORI[0]]="CLEARED";s.procedures[Rules.KAORI[1]]="CLEARED";s.successful_operation_days[Rules.KAORI[1]]=82
 expect(not Rules.kaori_available(s,Rules.KAORI[2],111) and Rules.kaori_available(s,Rules.KAORI[2],112),"Third quest same actual-date gate")
 expect(Rules.counts(s)=={"regular":5,"ray":7},"Ray includes distinct successful Kaori quests")
 var g:=new_game();g.set_test_time(20,540);grant(g,3)
 var old:=Facts.fresh()
 for key in ["activated_day","unlocked","new_board","clear_days","successful_operation_days"]:old.erase(key)
 old.version=1;old.week=2;old.procedures={rows[0].procedure_id:"CLEARED",rows[1].procedure_id:"FAILED_LOCKED"}
 old.completed=[result_record("old_clear",rows[0].procedure_id,10),result_record("old_fail",rows[1].procedure_id,12,false)]
 old.replays=[{"id":"legacy_weekly","procedure_id":rows[0].procedure_id,"patient_id":"patient_a","replay":true}]
 old.appointment={"case":{"id":"old_fourth","procedure_id":rows[3].procedure_id,"patient_id":"patient_akiba_rika_adult","replay":false},"team":Presentation.DEFAULT_TEAM.duplicate(true),"intake_day":19,"operation_day":21,"review_day":22,"intake_minutes":60}
 old.cooldowns={"doc_emiko":18}
 expect(Facts.valid(old),"Legacy facts accepted")
 g.advanced_referral_facts=old;var xp:int=g.surgery_xp;var clock:int=g.elapsed()
 g.sync_advanced_referral_calendar();s=g.advanced_referral_facts
 expect(s.version==2 and s.activated_day==3 and s.clear_days[rows[0].procedure_id]==10,"T23 reliable historical dates migrated")
 expect(s.appointment==old.appointment and s.completed==old.completed and s.replays==old.replays and s.cooldowns==old.cooldowns,"T23 bookings outcomes rewards and drawn cases preserved")
 expect(rows[3].procedure_id in s.new_board and s.new_board.size()<=3,"Old fourth booking grandfathered")
 g.sync_advanced_referral_calendar();expect(g.surgery_xp==xp and g.elapsed()==clock,"Migration never replays reward or time")
 var saved:Dictionary=g.snapshot();var restored:bool=g.restore(JSON.parse_string(JSON.stringify(saved)))
 expect(not saved.is_empty() and restored,"V2 boundary save/load: "+g.last_restore_error_key)
 expect(g.advanced_referral_facts==JSON.parse_string(JSON.stringify(saved.advanced_referral_facts)),"Migration facts stable through JSON load")
 expect(g.surgery_xp==xp and g.elapsed()==clock,"Migration preserves settled XP and clock")
 var normalized:Dictionary=g.snapshot()
 expect(g.restore(JSON.parse_string(JSON.stringify(normalized))) and JSON.parse_string(JSON.stringify(g.snapshot()))==JSON.parse_string(JSON.stringify(normalized)),"Second full boundary round-trip stable")
 no_inner(saved.advanced_referral_facts)
 var bad:Dictionary=saved.duplicate(true);bad.advanced_referral_facts.appointment["node_id"]="obsolete_node"
 expect(not g.restore(bad) and g.elapsed()==clock,"Reject node continuation without corrupting world")
 g.special_event_completion_days.erase(Rules.Tutorial);g.advanced_referral_facts=old.duplicate(true);g.sync_advanced_referral_calendar()
 expect(g.advanced_referral_facts.activated_day==0 and Rules.issue(g,g.advanced_referral_facts)=="activation_date_missing" and g.advanced_referral_facts.appointment==old.appointment,"Missing legacy activation explicitly deferred, progress retained")
 for row in rows:
  g.completed_surgeries_by_procedure[row.procedure_id]=2
  expect(not g.procedure_sweep_unlocked(row.procedure_id),"T16 advanced Quick blocked at public service")
 g.completed_surgeries_by_procedure["surgery_appendix"]=1
 g.surgical_quality_records["surgery_appendix"]={"quick_surgery_unlocked":true}
 expect(g.procedure_sweep_unlocked("surgery_appendix"),"Ordinary Quick unchanged")

func run() -> void:
 calendar_pool()
 weekly()
 gates_and_migration()
 integration()
 edge_cases()
 print("ADVANCED V2 RULES: %s checks; %s failures"%[checks,failures])
 quit(1 if failures else 0)
