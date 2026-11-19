extends "res://tools/mido_legendary_test.gd"
const P = preload("res://godot/systems/advanced_presentation.gd")
var app: Control
var clicks := 0
var shots := 0
var preview := false
var output := "res://docs/qa/mido_legendary_2026-11-18/native1/"

func view() -> Control: return app.page.get_node("AdvancedReferralView")
func click(id: String) -> void:
	var b: Button = app.page.find_child(id,true,false)
	expect(b != null and b.is_visible_in_tree() and not b.disabled, "GUI button available: "+id)
	if b == null or not b.is_visible_in_tree() or b.disabled: return
	var scroll := b.get_parent()
	while scroll != null:
		if scroll is ScrollContainer: scroll.ensure_control_visible(b)
		scroll = scroll.get_parent()
	await process_frame
	var point := b.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new();motion.position=point;root.push_input(motion,true)
	for pressed in [true,false]:
		var e := InputEventMouseButton.new();e.position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=pressed;root.push_input(e,true)
	clicks+=1
	await process_frame
	await process_frame

func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	expect(root.get_texture().get_image().save_png(ProjectSettings.globalize_path(output+name+".png"))==OK,"Capture "+name)
	shots+=1

func story(locale: String) -> void:
	var c: RefCounted = app.advanced_controller
	var phase: String=c.story_phase
	var count := 0
	while not c.story_phase.is_empty() and count < 40:
		var index: int=c.story_index
		var line: Dictionary=c.story_content[phase].lines[index]
		var card: Control=app.page.get_node("AdvancedCast")
		expect(card.get_meta("source_text")==line.text_en if locale=="en" else card.get_meta("source_text")==line.text,"Exact story line "+phase+str(index))
		if line.speaker=="patient": expect(card.get_meta("source_text")==line.text_en if locale=="en" else card.get_meta("source_text")==line.text,"Exact patient line")
		if line.speaker=="patient": expect(card.get_node("AdvancedActorPortrait").texture!=null,"Patient portrait loaded")
		if phase=="day2" and line.speaker=="doc_emiko":
			expect(str(card.get_meta("portrait_path")).contains("/scrubs/"),"Day2 OR door mentor wears scrubs")
		if index in [0,4,16,21] or (phase=="day3" and index in [5,11]): await capture(locale+"_"+phase+"_"+str(index))
		await click("story_next")
		expect(c.story_index==index+1 or c.story_phase.is_empty(),"One click advances one story line")
		count+=1
	expect(c.story_phase.is_empty(),"Chapter complete "+phase)

func morning(g: RefCounted, day: int) -> void:
	g.set_test_time(day,540)
	g.story_time_advance_minutes += (day-1)*g.SHIFT_MINUTES-g.elapsed()
	expect(g.day_number()==day and g.current_absolute_clock()==540,"Fixture exact booked morning")

func run() -> void:
	preview = "--pending-art" in OS.get_cmdline_user_args()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output=arg.trim_prefix("--out=").trim_suffix("/")+"/"
	expect(DisplayServer.get_name()!="headless","Native display")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	app=load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/private/tmp/mido-native-unused-%s.json"%OS.get_process_id()
	root.add_child(app);await process_frame
	for locale in ["zh_CN","en"]:
		app.content.load_all(locale)
		var g:=fixture();app.game=g
		g.set_test_time(15,540)
		g.surgery_xp=g.surgery_xp_for_level(100)
		var event: String=g.relationship_rank_slot("doc_emiko",5).event_id
		g.relation_for("doc_emiko").level=5;g.relation_for("doc_emiko").rank_history.append(event)
		g.special_event_completion_counts[event]=1;g.special_event_completion_days[event]=1
		g.advanced_referral_facts=Facts.fresh();g.advanced_referral_facts.activated_day=1
		for row in Rules.manifest().slice(0,5):
			g.advanced_referral_facts.procedures[row.procedure_id]="CLEARED"
			g.advanced_referral_facts.clear_days[row.procedure_id]=1
		app.advanced_controller=null;app.show_advanced_referral(preview)
		if preview:
			app.advanced_controller.content_preview=true;app.advanced_controller.demo_player_skill=100;view().render()
		await process_frame
		if not preview: expect(Legendary.ready(ID),"Production resources ready")
		await capture(locale+"_board")
		await click("case_advanced_first_"+ID)
		var c: RefCounted=app.advanced_controller
		if c.story_phase.is_empty(): break
		await story(locale)
		# Memory roster selection fixture; booking and remaining actions use actual GUI input.
		view().selected=P.DEFAULT_TEAM.duplicate(true);view().selected.second_assistant="doc_rei";view().render();await process_frame
		expect(view().selected.first_assistant=="doc_emiko","Forced mentor")
		await capture(locale+"_team")
		await click("accept")
		expect(not c.state().appointment.is_empty(),"Production booking")
		# Calendar boundary fixture: begin the booked day without touching player files.
		morning(g,int(c.state().appointment.operation_day))
		if preview: c.demo_day=int(c.state().appointment.operation_day)
		view().render();await process_frame
		await click("start")
		expect(c.session!=null,"Production session started")
		if c.session==null: quit(1);return
		await create_timer(2.0).timeout
		await story(locale)
		await capture(locale+"_anesthesia")
		if not preview: await click("AnesthesiaSplashContinue")
		await capture(locale+"_patient_ready")
		await click("begin_timeout")
		await capture(locale+"_team_confirm")
		for i in range(7): await click("confirm_member")
		var session: RefCounted=c.session
		# Fixed QA seed, actual stats and production effects; input performs every action.
		session.rng.seed=11000
		var plan:=Model.plan(session.definition,session.team)
		var precision:=0;var captured: Dictionary={};var teaching_captured: Dictionary={}
		var exit_btn := app.page.get_node_or_null("ExitAdvancedReferral") as Button
		expect(exit_btn!=null and exit_btn.get_theme_font("font").get_string_size(exit_btn.text,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x + 20 <= exit_btn.size.x,"Operative exit button fits full label without clipping: "+locale)
		for guard in range(350):
			if session.finished: break
			var step: Dictionary=session.current()
			if not captured.has(step.id):
				if step.id in ["MR01","MR03","MR05","MR10","MR17"]: await capture(locale+"_"+step.id)
				captured[step.id]=true
			var cur_dlg: Dictionary = session.operative_dialogue.current(session) if session.operative_dialogue!=null else {}
			if str(cur_dlg.get("id","")).contains("TEACHING") and str(cur_dlg.get("speaker_role",""))=="assistant_1" and not teaching_captured.has(step.id):
				if step.id in ["MR04","MR10"]: await capture(locale+"_"+step.id+"_mido_teaching")
				teaching_captured[step.id]=true
			var next: Button=app.page.find_child("dialogue_next",true,false)
			if next!=null and next.is_visible_in_tree() and not next.disabled: await click("dialogue_next")
			elif session.in_crisis(): await click("pause_and_stabilize")
			elif session.pending_rescue: await click("correct")
			elif session.awaiting_ack: await click("continue")
			elif step.kind=="P":
				var who: int=plan[precision];precision+=1
				await click("operate" if who==0 else "delegate_%s"%who)
			elif step.kind=="S": await click("strategy_"+str(step.options[1].id))
			else: await click("continue")
		expect(session.finished,"GUI runner finishes")
		await capture(locale+"_terminal")
		await click("finish")
		morning(g,int(c.state().appointment.review_day))
		if preview: c.demo_day=int(c.state().appointment.review_day)
		view().render()
		await click("settle")
		await create_timer(2.0).timeout
		expect(c.state().procedures.has(ID),"Settled before VN")
		if not c.story_phase.is_empty(): await story(locale)
		else:
			for i in range(4): await click("failure_next")
		expect(app.page.get_node("BackgroundWash").color.a >= 0.8,"Settlement text has dark backing")
		await capture(locale+"_settled")
		expect(c.state().completed.filter(func(r):return r.procedure_id==ID).size()==1,"Exactly one settlement")
	print("MIDO NATIVE: %s checks; %s failures; %s GUI clicks; %s screenshots"%[checks,failures,clicks,shots])
	quit(1 if failures else 0)
