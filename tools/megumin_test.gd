extends SceneTree
const NPC = preload("res://godot/systems/megumin.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Loader = preload("res://godot/scripts/content_loader.gd")
const Session = preload("res://godot/systems/character_event_session.gd")
var checks := 0
var failures := 0
var content = Loader.new()
func expect(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(note)
func fixture():
	var g = Game.new()
	g.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events)
	return g
func at(g, day: int, clock: int) -> void:
	g.story_time_advance_minutes += (day - 1) * 480 + clock - 540 - g.elapsed()
func item(id: String) -> Dictionary:
	for e in NPC.entries():
		if e.content_id == id: return e
	return {}
func _initialize() -> void: call_deferred("run")
func run() -> void:
	expect(content.load_all(), "content loads")
	var g = fixture()
	expect(NPC.entries().size() == 102, "102 entries")
	expect(not g.staff_can_join_surgery_team("npc_megumin") and g.relation_for("npc_megumin").is_empty(), "not clinical or relationship roster")
	at(g, 6, 540) # Sunday April 6
	g._complete_character_event_for_test(NPC.AQUA, 6)
	NPC.record_aqua(g)
	expect(g.megumin_facts.due_day == 7, "Sunday to Monday")
	at(g, 7, 540)
	expect(NPC.intro_due(g), "Monday automatic intro")
	g.megumin_active = true
	expect(not g.can_save_progress() and g.snapshot().is_empty(), "no mid-NPC save")
	g.megumin_active = false
	NPC.postpone(g)
	expect(g.megumin_facts.due_day == 8, "conflict next Tuesday")
	at(g, 8, 600)
	NPC.synchronize(g)
	expect(g.megumin_facts.due_day == 9, "no late same-day intro")
	at(g, 9, 540)
	var before: int = g.elapsed()
	var relations: Dictionary = g.relationships.duplicate(true)
	NPC.complete(g, item(NPC.INTRO), 9)
	expect(g.elapsed() == before and g.relationships == relations, "intro zero time and relationship delta")
	expect(not NPC.eligible(g, item("megumin_m07"), 9, 1020, true), "no first-school on intro day")
	expect(NPC.choose(g, true, 10, 1020).get("content_id") == "megumin_m07", "guaranteed first school")
	expect(NPC.choose(g, true, 10, 1021).is_empty(), "no late escort")
	expect(not NPC.eligible(g, item("megumin_r25"), 10, 1020, true), "reveal gate")
	NPC.complete(g, item("megumin_m07"), 10)
	expect(NPC.choose(g, true, 10, 1020).is_empty(), "one departure per day")
	at(g, 11, 840)
	expect(NPC.eligible(g,item("megumin_l08"),11,840),"afternoon bark")
	expect(not NPC.eligible(g,item("megumin_l08"),11,600),"no morning sleepy bark")
	expect(not NPC.eligible(g,item("megumin_m06"),10,990),"Friday gate")
	expect(NPC.eligible(g,item("megumin_m06"),11,990),"Friday near departure")
	expect(not NPC.eligible(g,item("megumin_m25"),11,600),"festival dormant")
	for id in ["megumin_m09","megumin_m12","megumin_m19"]:
		expect(not NPC.eligible(g,item(id),11,600),"unmet/absent cast excluded "+id)
	NPC.complete(g, item("megumin_r01"), 11)
	expect(NPC.choose(g).get("kind") == "ambient_bark", "daily limit switches to bark")
	for locale in ["zh_CN","en"]:
		for e in NPC.entries():
			var definition := NPC.definition(g,e,locale)
			var session = Session.new(definition)
			for node in definition.nodes:
				expect(node.choices.size() > 1 or not str(node.text).is_empty(), "localized text "+str(node.id))
			var count := 0
			while not session.completed and count < 100:
				expect(session.apply(str(session.current().choices[0].id)),"connected graph "+str(e.content_id))
				count += 1
			expect(session.completed,"terminates "+str(e.content_id))
	var save: Dictionary = g.snapshot()
	expect(not save.is_empty(), "safe boundary capture")
	expect(save.megumin_facts == g.megumin_facts, "only NPC facts")
	var clone = fixture()
	expect(clone.restore(JSON.parse_string(JSON.stringify(save))), "restore NPC facts")
	expect(clone.elapsed() == g.elapsed() and clone.megumin_facts == g.megumin_facts, "time and facts stable")
	# Removing old event internal nodes cannot affect this NPC's persistence.
	clone.character_event_definitions[NPC.AQUA] = clone.character_event_definitions[NPC.AQUA].duplicate(true)
	clone.character_event_definitions[NPC.AQUA].nodes = []
	var save2: Dictionary = clone.snapshot()
	var clone2 = fixture()
	expect(clone2.restore(JSON.parse_string(JSON.stringify(save2))), "second restore stable")
	expect(clone2.megumin_facts == g.megumin_facts, "no repeated settlement")
	var bad := save.duplicate(true)
	bad.megumin_facts["node_id"] = "forbidden"
	expect(not clone2.restore(bad), "reject internal state injection")
	var legacy = fixture()
	legacy._complete_character_event_for_test(NPC.AQUA,1)
	at(legacy, 7,540)
	NPC.synchronize(legacy)
	expect(legacy.megumin_facts.due_day == 14 and not legacy.megumin_facts.has("aqua_clock"), "approved legacy next Monday without fake timestamp")
	print("MEGUMIN: %s checks; %s failures" % [checks,failures])
	quit(1 if failures else 0)
