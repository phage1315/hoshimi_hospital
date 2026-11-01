extends SceneTree
const Flow = preload("res://godot/systems/chihaya_mizuho_return.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const View = preload("res://godot/ui/preop_view.gd")
var app
var checks := 0
var failures := 0
var turns := 0
var native := false
func _initialize() -> void:call_deferred("run")
func expect(ok: bool,message: String) -> void:
	checks+=1
	if not ok:failures+=1;push_error(message)
func hire(g) -> void:
	g.special_event_completion_counts[Flow.RETURN]=1;g.special_event_completion_days[Flow.RETURN]=143
	Flow.settle(g,Flow.RETURN)
func prep():
	return Preop.new(app.content.find_record("preops","preop_sora").duplicate(true),app.game.staff.duplicate(true),app.content.collections.surgeries,app.content.collections.patients,app.game.known_staff_ids(),true)
func click(button: Button) -> void:
	expect(is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled,"Real chat Continue usable")
	button.emit_signal("pressed");await process_frame
func find_presence(g,definition: Dictionary) -> bool:
	g.time_log.clear() # Each presence case starts from an isolated calendar fixture.
	for day in range(144,250):
		for hour in range(9,15):
			g.set_test_time(day,hour*60)
			if Flow.chat_available(g,definition):return true
	return false
func run() -> void:
	native=DisplayServer.get_name()!="headless"
	app=load("res://godot/scenes/main.tscn").instantiate();root.add_child(app);await process_frame
	app.dialogue_auto_enabled=false
	for locale in ["zh_CN","en"]:
		expect(app.content.load_all(locale),"Load "+locale);app.configure_game_content();app.game.reset()
		var g=app.game
		g.character_event_definitions.clear();g.micro_event_definitions.clear()
		for d in g.special_event_definitions.values():d.developer_only=true
		for actor in Flow.ACTORS:
			g.meet_staff(actor)
			expect(not g.staff_is_met(actor) and actor not in g.known_staff_ids(),"Meeting patient cannot unlock staff")
			var p=prep();expect(not p.qualified(actor,p.role_definition("ward_nurse")),"No team hire before event")
		hire(g)
		for actor in Flow.ACTORS:
			expect(g.staff_is_met(actor) and actor in g.known_staff_ids(),"Actual team unlock")
			expect(is_equal_approx(g.familiarity_gain_multiplier(actor),1.8),"Fam multiplier1.8")
			expect(actor not in g.personal_nurse_candidates() and not g.sunday_date_eligible(actor),"No private/diagnostic/date unlock")
			var p=prep()
			for role in ["ward_nurse","circulating_nurse","scrub_nurse","assistant_surgeon","primary_surgeon"]:
				expect(p.qualified(actor,p.role_definition(role))==(role in ["ward_nurse","circulating_nurse"]),"Strict role whitelist "+role)
				for key in p.roster[actor].skills:p.roster[actor].skills[key]=100
				expect(p.qualified(actor,p.role_definition(role))==(role in ["ward_nurse","circulating_nurse"]),"Growth never expands permission")
			p=prep();p.team={"assistant_surgeon":"doc_aoi","scrub_nurse":"nurse_haru","circulating_nurse":actor,"ward_nurse":actor}
			p.stage_id="preparation";p.fear=30;p.dignity=100
			# Existing action validation requires the other assigned staff to be known.
			p.restrict_to_known_staff=false
			expect(p.apply({"kind":"action","id":"perform_preparation"}),"Real ward preparation")
			expect(p.fear==50 and p.dignity==80,"Low care +20/-20")
			expect(p.feedback.contains(p.authored_staff_line(actor,"work.WD_09")),"Authored preparation completion")
			View.render(app,p);await process_frame
			expect(app.page.get_node("PreopRecordText").text.contains(p.authored_staff_line(actor,"work.WD_09")),"Rendered ward response")
			expect(p.assignment_response("circulating_nurse",actor)==p.authored_staff_line(actor,"work.OR_01"),"Assignment work line")
			expect(p.staff_action_response(actor,"confirm_circulating_role","")==p.authored_staff_line(actor,"work.OR_02"),"OR confirmation hook")
			expect(p.intraoperative_response(actor,"check_monitoring","",false)==p.authored_staff_line(actor,"work.OR_03"),"Monitoring hook")
			expect(p.intraoperative_response(actor,"close_steady","",false)==p.authored_staff_line(actor,"work.OR_08"),"Handoff hook")
			for flavor in Preop.CRISIS_FLAVOR_IDS:
				for severity in ["routine","severe"]:
					var expected: Array=p.roster[actor].crisis_callouts[flavor][0]["severe_attempt_lines" if severity=="severe" else "attempt_lines"]
					for attempt in range(1,4):
						p.active_crisis={"flavor_id":flavor,"severity":severity,"attempt":attempt,"speaker_actor_id":p.crisis_callout_speaker_id(),"speaker_role_id":"circulating_nurse","callout_variant_id":p.select_crisis_callout_variant(actor,flavor,0)}
						p.apply_crisis_callout_presentation()
						expect(p.crisis_callout_text()==expected[attempt-1] and p.last_staff_id==actor and p.feedback_speaker=="staff","Exact crisis speaker/round/severity")
			var before: int=g.staff_skill_value(actor,"patient_care")
			for i in range(25):g.train_surgery_team({"ward_nurse":actor},"appendectomy")
			expect(g.staff_skill_value(actor,"patient_care")>before,"Normal care growth")
		# All 27 authored short scenes; selection is the real presence/time API.
		for definition in app.content.collections.time_events:
			if not definition.has("dialogue_variants"):continue
			for variant in range(definition.dialogue_variants.size()):
				g.active_mode="encounter";g.active_id="";g.active_preop_id="";g.active_character_event_id="";g.active_micro_event_id=""
				expect(find_presence(g,definition),"Natural colocated entry exists "+definition.id)
				var before: int=g.elapsed()
				app.perform_time_event(definition.id,definition.location_id)
				expect(g.active_mode=="staff_chat" and g.elapsed()==before+30,"Chat entered and charged once")
				g.time_log.back().variant=variant;app.staff_chat_turn=0;app.reset_dialogue_page();app.show_time_event_result(definition.id,definition.location_id)
				for row in definition.dialogue_variants[variant]:
					var pages: Array=app.authored_dialogue_pages(row.text)
					for page in pages:
						await process_frame
						expect(not g.can_save_progress() and g.snapshot().is_empty(),"No short VN saves")
						expect(app.current_dialogue_text()==page,"Full localized short VN text")
						expect(app.page.get_node("StaffChatDialogueSpeaker").text==row.speaker_label,"Short VN real speaker")
						var sprite=app.page.get_node_or_null("CharacterPortrait")
						if row.speaker=="actor":
							var path: String=app.content.find_record("staff",row.actor_id).visuals.portraits[str(row.outfit)+"/"+str(row.expression)]
							expect(sprite!=null and sprite.texture!=null and sprite.texture.resource_path=="res://"+path,"Own nurse outfit and expression match speaker")
							if native and variant==0 and page==pages[0] and definition.id=="pair_chihaya_mizuho_station":
								await RenderingServer.frame_post_draw
								expect(root.get_texture().get_image().save_png("res://docs/qa/chihaya_mizuho_return/"+locale+"_chat_"+str(turns)+"_"+str(row.actor_id)+"_"+str(row.expression)+".png")==OK,"Chat expression screenshot")
						else:expect(sprite==null,"No stale actor portrait on player/narration")
						await click(app.dialogue_default_button)
					turns+=1
				expect(g.active_mode=="encounter" and g.elapsed()==before+30,"Chat ends; no per-line charge %s variant=%s screen=%s mode=%s clock=%s expected=%s turn=%s" % [definition.id,variant,app.screen,g.active_mode,g.elapsed(),before+30,app.staff_chat_turn])
				if failures:quit(1);return
		var pair: Dictionary=g.time_event_definitions.pair_chihaya_mizuho_station
		expect(find_presence(g,pair),"Pair valid fixture")
		g.relation_for("guest_mizuho").met=false
		expect(not Flow.chat_available(g,pair) and not g.spend_time(str(pair.id)),"Pair cannot run without both staff present")
		print("STAFF UI COMPLETE ",locale)
	print("CHIHAYA MIZUHO STAFF: ",checks," checks; ",failures," failures; ",turns," rendered dialogue turns; native=",native)
	quit(1 if failures else 0)
