extends "res://tools/megumin_test.gd"
func at(g, day: int, clock: int) -> void:
	# Isolated settled-clock fixture, not 100,000+ minutes of fictional story actions.
	g.settled_clock_offset += (day-1)*480+clock-540-g.elapsed()
# Calendar/workday variations are confined to this fixture; production remains the existing fixed year.
class CalendarFixture:
	extends "res://godot/systems/game_state.gd"
	var off_days: Array = []
	var year_offset := 0
	func is_routine_workday(day: int = -1) -> bool:
		if day in off_days: return false
		return super.is_routine_workday(day)
	func calendar_date(day: int = -1) -> Dictionary:
		var date: Dictionary = super.calendar_date(day).duplicate()
		date.year += year_offset
		return date
func run() -> void:
	expect(content.load_all(),"content loads")
	var g=fixture()
	at(g,214,540)
	expect(NPC.halloween_costume_workday(g,2025)==214,"real 2025 Friday Oct31")
	expect(not NPC.halloween_costume_active(g),"unmet no costume")
	g.megumin_facts={"introduced_day":214}
	expect(not NPC.halloween_costume_active(g) and NPC.choose(g).get("content_id")!=NPC.HALLOWEEN,"intro-day no costume/reveal")
	g.megumin_facts={"introduced_day":7,"first_school_day":8}
	var before: Dictionary=g.snapshot()
	var picked: Dictionary=NPC.choose(g)
	expect(picked.get("content_id")==NPC.HALLOWEEN,"first talk priority")
	expect(not g.megumin_facts.has("annual_groups"),"choosing does not mark completion")
	expect(NPC.halloween_costume_active(g),"costume without reveal completion")
	var year_key: String="2025:"+NPC.HALLOWEEN_GROUP
	g.megumin_active=true
	expect(g.snapshot().is_empty(),"no in-event save")
	g.megumin_active=false
	NPC.complete(g,picked,214)
	expect(g.megumin_facts.annual_groups.has(year_key) and not g.megumin_facts.annual_groups.has("2025:halloween"),"separate annual group")
	expect(not g.megumin_facts.has("daily_day"),"reveal does not consume micro quota")
	var after: Dictionary=g.snapshot()
	before.erase("megumin_facts");after.erase("megumin_facts")
	expect(before==after,"all other persistent values unchanged")
	var ordinary: Dictionary=NPC.choose(g)
	expect(ordinary.get("content_id") in ["megumin_s07","megumin_m26"],"second talk original seasonal micro")
	for b in NPC.definition(g,ordinary,"en").nodes:
		expect(str(b.portrait).begins_with("halloween_original_mage_"),"ordinary micro wears costume")
	NPC.complete(g,ordinary,214)
	expect(NPC.choose(g).get("kind")=="ambient_bark","third talk bark")
	expect(NPC.display_portrait(g,"reception_neutral") == "halloween_original_mage_neutral","bark override")
	expect(NPC.display_portrait(g,"reception_neutral",NPC.INTRO)=="reception_neutral","intro never rewritten")
	var restored=fixture()
	expect(restored.restore(JSON.parse_string(JSON.stringify(g.snapshot()))),"safe save roundtrip: "+restored.last_error)
	expect(NPC.halloween_costume_active(restored) and NPC.choose(restored).get("kind")=="ambient_bark","restored costume and completed annual flags")
	var stable_save: Dictionary=restored.snapshot()
	var saved_beats: Array=item(NPC.HALLOWEEN).beats.duplicate(true)
	item(NPC.HALLOWEEN).beats=[]
	expect(restored.restore(JSON.parse_string(JSON.stringify(stable_save))),"save independent of reveal nodes")
	expect(restored.snapshot()==stable_save,"repeat save preserves time/results without rewards")
	item(NPC.HALLOWEEN).beats=saved_beats
	for clock in [539,1020,1021]:
		expect(not NPC.halloween_costume_active(g,214,clock),"out of shift "+str(clock))
	expect(NPC.halloween_costume_active(g,214,1019),"last minute on shift")
	at(g,214,1020)
	expect(NPC.display_portrait(g,"school_neutral")=="school_neutral","departure school unchanged")
	at(g,215,540)
	expect(not NPC.halloween_costume_active(g) and NPC.choose(g).get("content_id")!=NPC.HALLOWEEN,"no November catchup")
	g.megumin_facts={"introduced_day":7,"daily_day":214,"annual_groups":{"2025:halloween":210}}
	at(g,214,600)
	expect(NPC.choose(g).get("content_id")==NPC.HALLOWEEN,"prior seasonal/daily use does not suppress reveal")
	NPC.complete(g,item(NPC.HALLOWEEN),214)
	expect(NPC.choose(g).get("kind")=="ambient_bark","prior daily quota remains spent")
	g.megumin_active=true
	expect(NPC.choose(g).is_empty(),"busy no forced interruption")
	g.megumin_active=false
	var calendar=CalendarFixture.new()
	calendar.megumin_facts={"introduced_day":7}
	calendar.off_days=[214]
	expect(NPC.halloween_costume_workday(calendar,2025)==213,"absent target rolls back to Thursday")
	calendar.off_days=[214,213]
	expect(NPC.halloween_costume_workday(calendar,2025)==212,"two unavailable days roll back")
	calendar.off_days=range(208,215)
	expect(NPC.halloween_costume_workday(calendar,2025)==0,"no workday in window skips year")
	calendar.off_days=[];calendar.year_offset=1
	calendar.megumin_facts.annual_groups={year_key:214}
	expect(NPC.eligible(calendar,item(NPC.HALLOWEEN),214,600),"previous year marker does not suppress next year fixture")
	# Branch A requires a real settled intro and actual lobby presence, not just a met flag.
	g._complete_character_event_for_test(NPC.AQUA,1);g.meet_staff("doc_aqua")
	var aqua: Dictionary=g.staff_record("doc_aqua")
	var original: Dictionary=aqua.presence.duplicate(true)
	aqua.presence.fixed_locations=["lobby"];aqua.presence.random_locations=["lobby"]
	g.presence_resolver=load("res://godot/systems/presence_resolver.gd").new(g.staff)
	for locale in ["zh_CN","en"]:
		var a: Dictionary=NPC.definition(g,item(NPC.HALLOWEEN),locale)
		expect(a.nodes.any(func(n):return n.actor_id=="doc_aqua"),"Aqua present branch "+locale)
		g.active_staff_patient={"staff_id":"doc_aqua"}
		var b: Dictionary=NPC.definition(g,item(NPC.HALLOWEEN),locale)
		expect(not b.nodes.any(func(n):return n.actor_id=="doc_aqua"),"unavailable Aqua branch "+locale)
		expect(b.nodes.any(func(n):return str(n.id).ends_with("_023")),"authored absent action")
		g.active_staff_patient.clear()
	aqua.presence=original
	print("MEGUMIN HALLOWEEN: ",checks," checks; ",failures," failures")
	quit(1 if failures else 0)
