extends SceneTree
const EVENT := "manami_lv1_sneeze"
const ACTOR := "pharmacist_manami"
var checks := 0
var failures := 0

func expect(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(note)

func _initialize() -> void:
	call_deferred("run")

func no_inner_state(value: Variant) -> void:
	if value is Dictionary:
		for key in value:
			expect(key not in ["node_id", "choices", "choice_id", "last_choice", "stage_id", "action_log", "event_portraits", "presentation"], "No inner state: " + str(key))
			no_inner_state(value[key])
	elif value is Array:
		for item in value: no_inner_state(item)

func capture(app, locale: String, node_id: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args(): return
	# Portrait/UI shots only; supplied CGs are verified technically, not edited.
	if node_id not in ["im1_l060", "im1_l080", "im1_l084", "im1_l087", "im1_l125", "im1_l146", "im1_s6_a17"]: return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/qa/manami_lv1/%s_%s.png" % [locale,node_id])

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		var g = app.game
		g.reset()
		var definition: Dictionary = g.character_event_definitions[EVENT]
		var intro: Dictionary = g.character_event_definitions.intro_pharmacist_manami
		g.character_event_definitions = {EVENT:definition, "intro_pharmacist_manami":intro}
		g.relation_for(ACTOR).familiarity = 10
		expect(not g.character_event_available(definition), "Unmet blocked")
		g.meet_staff(ACTOR)
		expect(not g.character_event_available(definition), "Meeting alone cannot skip Lv0")
		var introduction = load("res://godot/systems/character_event_session.gd").new(intro)
		introduction.completed = true
		introduction.completed_day = 1
		introduction.settled_minutes = 10
		g.character_events.intro_pharmacist_manami = introduction
		g.relation_for(ACTOR).event_history.append("intro_pharmacist_manami")
		var relation: Dictionary = g.relation_for(ACTOR)
		relation.familiarity = 9
		expect(not g.character_event_available(definition), "Familiarity9 blocked")
		relation.familiarity = 10
		expect(g.character_event_available(definition), "Lv0 complete and familiarity10; no invented day gate")
		expect(g.next_character_event_at("or").get("id", "") == EVENT, "Operating room entry")
		expect(g.next_character_event_at("pharmacy").is_empty(), "Not a pharmacy-entry event")
		expect(g.next_character_event_at("ward").is_empty(), "Not a ward event")
		for field in ["active_character_event_id","active_special_event_id","active_micro_event_id","active_preop_id"]:
			g.set(field,"busy")
			expect(not g.character_event_available(definition), "Busy guard " + field)
			g.set(field,"")
		relation.level = 1
		expect(not g.character_event_available(definition), "Old Lv1 saves cannot replay")
		relation.level = 0
		g.set_test_time(1, 13*60)
		var before: int = g.elapsed()
		var attributes: Dictionary = g.player_attributes().duplicate(true)
		var queue: Array = g.patient_queue.duplicate(true)
		var others: Dictionary = g.relationships.duplicate(true)
		var event = g.start_character_event(EVENT)
		expect(event != null, "Start event")
		if event == null: continue
		app.show_character_event()
		var cg_runs: Array[String] = []
		var previous_cg := ""
		var count := 0
		while not event.completed and count < 250:
			count += 1
			var n: Dictionary = event.current()
			expect(not g.can_save_progress() and g.snapshot().is_empty(), "No save during " + str(n.id))
			expect(relation.level == 0 and g.elapsed() == before, "No early completion/time " + str(n.id))
			var cg := str(n.get("cg_path",""))
			if not cg.is_empty() and cg != previous_cg: cg_runs.append(cg)
			previous_cg = cg
			var cg_widget = app.page.get_node_or_null("CharacterEventCG")
			expect((cg_widget != null) == not cg.is_empty(), "CG layer " + str(n.id))
			if cg_widget != null:
				expect(cg_widget.texture.resource_path == "res://" + cg, "Exact CG resource")
				expect(cg_widget.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "CG not cropped")
			var art_count := 0
			for child in app.page.get_children():
				if str(child.name).begins_with("EventPortrait_"): art_count += 1
			expect(art_count == n.event_portraits.size(), "Explicit composition " + str(n.id))
			for art in n.event_portraits:
				var widget = app.page.get_node_or_null("EventPortrait_" + str(art.id))
				expect(widget != null and widget.texture.resource_path == "res://"+str(art.path), "Exact variant " + str(n.id))
			await capture(app,locale,str(n.id))
			if n.presentation == "stage":
				expect(app.page.get_node_or_null("EventStageTimer") != null, "Timed stage")
				expect(app.page.get_node_or_null("CharacterEventDialogue") == null, "No empty dialogue box")
				var old_id := str(n.id)
				if old_id == "im1_s6_a17":
					expect(app.page.get_node_or_null("EventStageEffect").color == Color.BLACK, "Final black rendered before settlement")
				await create_timer(float(n.auto_seconds)+0.08).timeout
				expect(event.completed or str(event.current().id) != old_id, "Stage automatically advanced")
			else:
				var speaker_found := false
				for child in app.page.get_children():
					if child is Label and child.text == n.speaker_label: speaker_found = true
				expect(speaker_found, "Exact authored speaker " + str(n.id))
				var rendered := ""
				for page_number in range(30):
					var part: Dictionary = app.dialogue_page("character:%s:%s" % [EVENT,n.id],str(n.text),false,true)
					rendered += str(part.text)
					if not part.has_more: break
					app.page.get_node("EventDialogueContinue").pressed.emit()
					expect(event.current().id == n.id, "Pagination not a choice")
					if n.has("stage_effect"):
						expect(app.page.get_node_or_null("EventStageEffect") == null, "Do not replay effects while paging")
				expect(rendered == str(n.text), "Exact full text " + str(n.id))
				app.choose_character_event(str(n.choices[0].id))
			await process_frame
		expect(count==243, "All 160 dialogue and 83 stage/action nodes visited: " + str(count))
		expect(cg_runs.size()==4, "Exactly four CG runs")
		expect(event.completed and g.active_character_event_id.is_empty() and app.screen=="map", "Return to safe hospital map")
		expect(g.elapsed()==before+30, "Exactly30 minutes")
		expect(relation.level==1 and relation.familiarity==10 and relation.affection==0, "Lv1 only")
		expect(g.patient_queue==queue and g.completed_surgeries_total==0 and g.player_attributes()==attributes, "No new patient/surgery/attribute reward")
		for a in others:
			if a!=ACTOR: expect(g.relationships[a]==others[a], "No other relationship changes")
		expect(relation.event_history.count(EVENT)==1 and relation.rank_history.count(EVENT)==1, "Only one completion")
		expect(g.can_save_progress() and not g.character_event_available(definition), "Safe save, no retrigger")
		var clean: Dictionary = g.snapshot()
		no_inner_state(clean)
		var store = load("res://godot/systems/save_store.gd").new()
		store.path = "/tmp/hoshimi_manami_lv1_test_%s.json" % locale
		expect(store.write_slot(g), "Write temporary test save")
		expect(store.read_slot(g), "Read temporary test save")
		expect(g.elapsed()==before+30 and g.relation_for(ACTOR).level==1, "Disk roundtrip unchanged")
		# Gallery has all staging but cannot settle time or relationship again.
		var snapshot_json := JSON.stringify(g.snapshot())
		app.replay_gallery_entry(EVENT)
		var replay = app.gallery_replay_event
		for n in definition.nodes:
			replay.node_id = str(n.id)
			app.show_gallery_replay()
			if n.presentation=="stage": expect(app.page.get_node_or_null("EventStageTimer")!=null, "Replay stage")
			else: expect(app.page.get_node_or_null("GalleryReplayDialogue")!=null, "Replay cinematic dialogue")
			await process_frame
		# Render a final black stage, then explicitly exit; its timer must die.
		app.show_gallery_entry(EVENT)
		await create_timer(1.0).timeout
		expect(not replay.completed, "Exited replay cancels stale final timer")
		expect(JSON.stringify(g.snapshot())==snapshot_json, "Replay never mutates world")
		definition.nodes = []
		definition.start = "rewritten_entry"
		definition.minutes = 999
		expect(g.restore(clean), "Save independent of internal node names")
		expect(g.elapsed()==before+30 and g.relation_for(ACTOR).level==1, "Rewritten script cannot alter paid time/rewards")
		expect(g.restore(g.snapshot()) and g.elapsed()==before+30, "Repeated save/load stable")
	print("MANAMI LV1: %d checks; %d failures" % [checks,failures])
	quit(1 if failures else 0)
