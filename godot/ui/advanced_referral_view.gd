extends Control
const Presentation = preload("res://godot/systems/advanced_presentation.gd")
const Dialogue = preload("res://godot/systems/advanced_operative_dialogue.gd")
const Model = preload("res://godot/systems/advanced_surgery_model.gd")
var host: Control
var controller: RefCounted
var english := false
var body: VBoxContainer
var record: Dictionary = {}
var selected: Dictionary = {}
var strings: Dictionary = {}
var english_staff: Dictionary = {}
var estimate_cache: Dictionary = {}
var risk_label: Label
var committing := false
var editing_booking := false
var cast_panel: Control
var scroll: ScrollContainer
var operation_panel: RefCounted
var team_panel: RefCounted
var blackout_running := false
var day_transition_panel: ColorRect
var day_transition_serial := 0
var operative_auto := false
var operative_auto_ticket := 0

func setup(app: Control, service: RefCounted, en: bool) -> void:
	host = app
	operation_panel = preload("res://godot/ui/advanced_operation_panel.gd").new(self)
	controller = service
	english = en
	strings = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/ui_text.json"))
	english_staff = JSON.parse_string(FileAccess.get_file_as_string("res://data/localization/en.json")).strings
	position = Vector2(50, 175)
	size = Vector2(1180, 550)
	scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	scroll.add_child(body)
	render()

func tr_key(key: String) -> String:
	return str(strings.get(key, [key, key])[1 if english else 0])
func title_of(d: Dictionary) -> String:
	return str(d.get("name_en", d.get("name", "")) if english else d.get("name", ""))
func actor_name(id: String) -> String:
	return str(english_staff.get("collections.staff.%s.name" % id, id)) if english else str(controller.game.staff_record(id).get("name", id))

func label(text: String, large: bool = false) -> Label:
	var node := Label.new()
	node.text = text
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_size_override("font_size", 24 if large else 19)
	node.add_theme_color_override("font_color", Color("f4f0e6"))
	body.add_child(node)
	return node

func button(key: String, callback: Callable, enabled: bool = true, custom: String = "") -> Button:
	var node := Button.new()
	node.name = key
	node.text = tr_key(key) if custom.is_empty() else custom
	node.custom_minimum_size = Vector2(0, 46)
	node.add_theme_font_size_override("font_size", 20)
	node.disabled = not enabled
	if not enabled and (key.begins_with("delegate_") or key.begins_with("rescue_")): node.tooltip_text = tr_key("unavailable_action")
	node.pressed.connect(callback)
	body.add_child(node)
	return node

func operation_active() -> bool:
	return controller.session != null and not controller.session.splash_pending and controller.session.team_intro_index < 0

func refresh_operation_chrome() -> void:
	var active := operation_active()
	position = Vector2(40, 125) if active else Vector2(50, 175)
	size = Vector2(1200, 620) if active else Vector2(1180, 550)
	var heading: Label = host.page.get_node_or_null("PageTitle")
	var subtitle: Label = host.page.get_node_or_null("PageSubtitle")
	if heading != null:
		heading.text = title_of(controller.session.definition) if active else tr_key("title")
		heading.position = Vector2(40,76) if active else Vector2(56,88)
		heading.size.x = 810 if active else 1100
		var heading_font_size := 24 if active else 34
		if active:
			while heading_font_size > 13 and heading.get_theme_font("font").get_string_size(heading.text, HORIZONTAL_ALIGNMENT_LEFT, -1, heading_font_size).x > heading.size.x:
				heading_font_size -= 1
		heading.add_theme_font_size_override("font_size",heading_font_size)
		heading.autowrap_mode = TextServer.AUTOWRAP_OFF if active else TextServer.AUTOWRAP_WORD_SMART
		heading.clip_text = active
	if subtitle != null:
		subtitle.visible = not active
		subtitle.text = tr_key("dev" if controller.dev else "prod")
	var exit_button: Button = host.page.get_node_or_null("ExitAdvancedReferral")
	if exit_button != null:
		exit_button.position = Vector2(1080,77) if active else Vector2(960,88)
		exit_button.size = Vector2(160,34) if active else Vector2(270,44)
		exit_button.text = tr_key("compact_exit" if active and controller.dev else "exit" if controller.dev else "back")
		exit_button.add_theme_font_size_override("font_size",16 if active else 20)
	var header: Label = host.page.get_node_or_null("CalendarHeader")
	if header != null and staff_episode() and controller.episode_active and (controller.night_choice or controller.story_phase in ["night", "dark", "after"] or controller.transition_pending):
		header.text = tr_key("staff_after_clock" if controller.story_phase == "after" else "staff_night_clock")
	if header != null and controller.dev: header.text = tr_key("compact_dev") if active else tr_key("test_day")%controller.day()

func staff_episode() -> bool:
	return controller.get_script() == preload("res://godot/systems/advanced_staff_patient.gd")

func render() -> void:
	operative_auto_ticket += 1
	host.invalidate_dialogue_action()
	operation_panel.hide_dialogue_toolbar()
	team_panel = null
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	refresh_operation_chrome()
	body.add_theme_constant_override("separation",8 if operation_active() else 12)
	if is_instance_valid(cast_panel):
		cast_panel.get_parent().remove_child(cast_panel)
		cast_panel.queue_free()
		cast_panel = null
	var with_cast: bool = not (controller.dev and controller.fixture_mode) and (controller.session != null or not record.is_empty() or editing_booking or controller.failure_dialogue_index >= 0)
	scroll.offset_right = -370 if operation_active() else -440 if with_cast else 0
	var location := "operating_room" if controller.session != null else "ward" if not controller.state().outcome.is_empty() or controller.last_summary.has("case_id") else "player_office"
	if staff_episode() and controller.night_choice: location = "ward_night"
	var wash := host.page.get_node_or_null("BackgroundWash") as ColorRect
	if wash != null: wash.color.a = 0.0 if location in ["ward", "ward_night"] or not controller.story_phase.is_empty() else 0.83
	if host.background is TextureRect:
		host.background.modulate = Color.WHITE
		var path: String = host.background_path(location)
		if not path.is_empty(): host.background.texture = load("res://" + path)
	if controller.dev:
		var header: Label = host.page.get_node_or_null("CalendarHeader")
		if header != null: header.text = tr_key("compact_dev") if operation_active() else tr_key("test_day") % controller.day()
	var exit_button: Button = host.page.get_node_or_null("ExitAdvancedReferral")
	if exit_button != null: exit_button.disabled = not controller.game.active_advanced_staff_patient.is_empty() or (not controller.dev and (controller.session != null or not controller.story_phase.is_empty() or controller.due(controller.game)))
	for node in body.get_children():
		body.remove_child(node)
		node.queue_free()
	if controller.dev and controller.session == null and controller.story_phase.is_empty(): label(tr_key("mode"))
	if not controller.error.is_empty(): label(tr_key(controller.error))
	controller.refresh()
	var migration_issue: String = preload("res://godot/systems/advanced_referral_rules.gd").issue(controller.game, controller.state()) if not controller.dev and not staff_episode() else ""
	if not migration_issue.is_empty(): label(tr_key(migration_issue))
	if not controller.eligible():
		label(tr_key("gate"))
		return
	if not controller.day_transition.is_empty():
		render_day_transition()
		return
	if staff_episode() and controller.transition_pending:
		if blackout_running: return
		blackout_running = true
		var blackout := ColorRect.new()
		blackout.color = Color.BLACK
		blackout.position = -position
		blackout.size = host.size
		add_child(blackout)
		get_tree().create_timer(0.8).timeout.connect(func():
			if not is_instance_valid(self): return
			blackout.queue_free()
			blackout_running = false
			controller.complete_night_transition()
			render())
		return
	if staff_episode() and controller.night_choice:
		label(tr_key("staff_title"), true)
		button("staff_watch", func(): controller.choose_night(true); render())
		button("staff_skip", func(): controller.choose_night(false); render())
		return
	if not controller.story_phase.is_empty():
		render_first_story()
		return
	if controller.session != null:
		render_operation()
		return
	var s: Dictionary = controller.state()
	if editing_booking:
		render_team()
		return
	if not s.appointment.is_empty():
		render_booking()
		return
	if controller.last_summary.has("case_id"):
		if controller.failure_dialogue_index >= 0:
			render_failure_dialogue()
			return
		label(tr_key("done"), true)
		var summary: Dictionary = controller.last_summary
		label(tr_key("reward") % [summary.surgery_xp, summary.leadership_xp, summary.reputation])
		if not bool(summary.success): label(tr_key("failxp"))
		if staff_episode(): button("back", func(): host.exit_advanced_referral())
		else: button("new", func(): controller.last_summary.clear(); record = {}; render())
		return
	if not record.is_empty():
		render_team()
		return
	if staff_episode():
		label(tr_key("staff_title"), true)
		label(tr_key("staff_warning"))
		var available: Array = controller.board()
		if available.is_empty(): label(tr_key("empty_pool"))
		for item in available:
			button("case_" + str(item.id), func(): record = item.duplicate(true); selected.clear(); render(), true, title_of(Model.procedure(str(item.procedure_id))))
		return
	label(tr_key("status") % [s.procedures.values().count("CLEARED"), s.procedures.values().count("FAILED_LOCKED")], true)
	label(tr_key("warn"))
	var offers: Array = controller.board()
	for replay in [false, true]:
		label(tr_key("replay_pool" if replay else ("new_pool_dev" if controller.dev else "new_pool")), true)
		var matching: Array = offers.filter(func(item): return bool(item.replay) == replay)
		if matching.is_empty(): label(tr_key("empty_pool"))
		for item in matching:
			var definition := Model.procedure(str(item.procedure_id))
			var caption := "%s · %s" % [tr_key("replay" if item.replay else "first"), title_of(definition)]
			button("case_" + str(item.id), func(): record = item.duplicate(true); selected.clear(); controller.begin_story("day1",item); render(), true, caption)
	for id in s.cooldowns:
		label(tr_key("cooldown") % [actor_name(str(id)), s.cooldowns[id]])
	if controller.dev: button("next_week", func(): controller.demo_day = (int(controller.day() / 7) + 1) * 7; render())
	label(tr_key("limitations"))

func render_team() -> void:
	if controller.dev and controller.fixture_mode:
		render_fixture_team()
		return
	var dates: Dictionary = controller.schedule()
	if controller.dev and selected.is_empty():
		for role in controller.ROLES:
			var people: Array = controller.candidates(role,int(dates.get("operation_day",controller.day()+1)))
			var preferred := str(Presentation.DEFAULT_TEAM.get(role,""))
			for person in people:
				if person.id==preferred and person.id not in selected.values(): selected[role]=person.id; break
			if not selected.has(role):
				for person in people:
					if person.id not in selected.values(): selected[role]=person.id; break
	for child in body.get_children():
		body.remove_child(child);child.queue_free()
	scroll.offset_right=0
	scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	scroll.scroll_vertical=0
	var heading: Label=host.page.get_node("PageTitle")
	heading.text=title_of(Model.procedure(str(record.procedure_id)))
	heading.size.x=860
	heading.add_theme_font_size_override("font_size",26)
	var subtitle: Label=host.page.get_node("PageSubtitle")
	var heading_font: Font = heading.get_theme_font("font")
	var heading_size := 26
	while heading_size > 16 and heading_font.get_string_size(heading.text,HORIZONTAL_ALIGNMENT_LEFT,-1,heading_size).x > 860:
		heading_size -= 1
	heading.add_theme_font_size_override("font_size",heading_size)
	subtitle.text=tr_key("team_day1")
	subtitle.show()
	team_panel=preload("res://godot/ui/advanced_team_panel.gd").new(self)
	team_panel.draw()

func render_fixture_team() -> void:
	var definition := Model.procedure(str(record.procedure_id))
	label(title_of(definition), true)
	var patient: Dictionary = Presentation.patient(record, controller.game, english)
	var authored: bool = not controller.FirstStory.content(record).is_empty()
	label(tr_key("case") % str(patient.get("name", record.patient_id)))
	label(str(patient.diagnosis_en if english else patient.diagnosis) if authored else str(definition.patient_notice_en if english else definition.patient_notice))
	var tags: Array = []
	for step in definition.steps:
		if step.kind == "P" and step.specialty_tag not in tags: tags.append(step.specialty_tag)
	label(tr_key("tags") % ", ".join(tags))
	if not record.replay and not authored:
		label(tr_key("intro"))
		label(tr_key("line1"))
	var dates: Dictionary = controller.schedule()
	if dates.is_empty(): label(tr_key("calendar"))
	else: label(tr_key("dates") % [dates.intake_day, dates.operation_day, dates.review_day])
	if controller.dev and controller.fixture_mode:
		var picker := OptionButton.new()
		picker.name = "FixturePicker"
		picker.custom_minimum_size.y = 44
		for fixture in Model.fixtures(str(record.procedure_id)): picker.add_item(title_of(fixture))
		picker.select(controller.fixture_index)
		picker.item_selected.connect(func(index): controller.fixture_index = index; update_preview())
		body.add_child(picker)
		for role in controller.ROLES: selected[role] = "fixture_" + str(role)
	else:
		if controller.dev and selected.is_empty():
			for role in controller.ROLES:
				var people: Array = controller.candidates(role, int(dates.get("operation_day", controller.day() + 1)))
				var preferred := str(Presentation.DEFAULT_TEAM.get(role, ""))
				for person in people:
					if person.id == preferred and person.id not in selected.values(): selected[role] = person.id; break
				if not selected.has(role):
					for person in people:
						if person.id not in selected.values(): selected[role] = person.id; break
		if controller.dev: label(tr_key("real_team"))
		for role in controller.ROLES:
			label(tr_key("roles." + str(role)))
			var picker := OptionButton.new()
			picker.name = "Team_" + str(role)
			picker.custom_minimum_size.y = 44
			picker.add_item(tr_key("pick"))
			picker.set_item_metadata(0, "")
			var candidates: Array = controller.candidates(role, int(dates.get("operation_day", controller.day() + 1)))
			for person in candidates:
				var skill_id: String = controller.game.role_training_skill(role)
				var suffix := " · %s" % controller.game.staff_skill_value(person.id, skill_id) if not skill_id.is_empty() else ""
				picker.add_item(actor_name(person.id) + suffix)
				var item_idx := picker.item_count - 1
				picker.set_item_metadata(item_idx, person.id)
				var small_tex: Texture2D = host.staff_chibi_small_texture(str(person.id))
				if small_tex != null:
					picker.set_item_icon(item_idx, small_tex)
				if selected.get(role, "") == person.id: picker.select(item_idx)
			picker.item_selected.connect(func(index): selected[role] = picker.get_item_metadata(index); update_preview(); show_assignment(role))
			body.add_child(picker)
	risk_label = label(tr_key("preview_ready"))
	label(tr_key("warn"))
	if not record.replay and not authored: label(tr_key("line2"))
	button("accept", accept_case, not dates.is_empty(), tr_key("confirm_rebook") if editing_booking else "")
	button("new", func(): record = {}; editing_booking = false; render())
	update_preview()
	if not (controller.dev and controller.fixture_mode): show_patient(patient)

func update_preview() -> void:
	if team_panel != null:
		team_panel.refresh()
		return
	if not is_instance_valid(risk_label): return
	var dates: Dictionary = controller.schedule()
	if dates.is_empty() or not controller.valid_team(selected, int(dates.operation_day)):
		risk_label.text = tr_key("team")
		return
	var team: Dictionary = controller.values(selected, str(record.procedure_id))
	var key := str(record.procedure_id) + JSON.stringify(team)
	if not estimate_cache.has(key): estimate_cache[key] = Model.estimate(Model.procedure(str(record.procedure_id)), team)
	var estimate: Dictionary = estimate_cache[key]
	risk_label.text = tr_key("teaminfo") % [int(team.player), int(team.assistants[0].skill), int(team.assistants[1].skill), int(team.primary_scrub), int(team.secondary_scrub), int(team.primary_circ), int(team.secondary_circ)]
	risk_label.text += "\n" + tr_key("estimate") % estimate.rounded_percent
	risk_label.text += "\n" + tr_key("plan") % str(estimate.plan)
	for assistant in team.assistants:
		var name_text := title_of(assistant) if controller.dev and controller.fixture_mode else actor_name(str(assistant.id))
		var tags := ", ".join(assistant.specialties) if not assistant.specialties.is_empty() else tr_key("none")
		var second := "no_second"
		if int(assistant.skill) >= 90:
			if assistant.get("universal_expert", false): second = "universal"
			elif not assistant.specialties.is_empty(): second = "matching"
		risk_label.text += "\n" + tr_key("assistant_preview") % [name_text, tags, tr_key(second)]

func accept_case() -> void:
	if committing: return
	if staff_episode():
		var conflict: String = controller.booking_conflict()
		if not conflict.is_empty() and conflict != controller.replacement_actor:
			var dialog := ConfirmationDialog.new()
			dialog.dialog_text = tr_key("staff_booking_conflict") + "\n" + actor_name(conflict)
			dialog.ok_button_text = tr_key("staff_replace")
			dialog.cancel_button_text = tr_key("back")
			host.page.add_child(dialog)
			dialog.confirmed.connect(func(): controller.replacement_actor = conflict; dialog.queue_free(); accept_case())
			dialog.canceled.connect(func(): dialog.queue_free())
			dialog.popup_centered(Vector2i(600,220))
			return
	committing = true
	if editing_booking:
		if controller.rebook(selected): editing_booking = false
	else: controller.accept(record, selected)
	committing = false
	render()

func render_day_transition() -> void:
	if is_instance_valid(day_transition_panel): return
	day_transition_serial += 1
	var serial := day_transition_serial
	day_transition_panel = ColorRect.new()
	day_transition_panel.name = "AdvancedDayTransition"
	day_transition_panel.color = Color("101b22")
	day_transition_panel.position = -position
	day_transition_panel.size = host.size
	day_transition_panel.z_index = 100
	add_child(day_transition_panel)
	var title := Label.new()
	title.name = "DayTransitionTitle"
	var ordinal: int = controller.day_transition.ordinal
	title.text = tr_key("day_transition_second" if ordinal == 2 else "day_transition_third") if ordinal in [2,3] else tr_key("day_transition_later") % ordinal
	title.position = Vector2(0, host.size.y * 0.40)
	title.size = Vector2(host.size.x, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	day_transition_panel.add_child(title)
	var date := Label.new()
	date.name = "DayTransitionDate"
	date.text = str(controller.game.calendar_date(int(controller.day_transition.day)).iso)
	date.position = Vector2(0, host.size.y * 0.40 + 70)
	date.size.x = host.size.x
	date.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_transition_panel.add_child(date)
	var hint := Label.new()
	hint.text = tr_key("day_transition_continue")
	hint.position = Vector2(0, host.size.y * 0.75)
	hint.size.x = host.size.x
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	day_transition_panel.add_child(hint)
	get_tree().create_timer(1.8).timeout.connect(func():
		if is_instance_valid(self) and serial == day_transition_serial:
			finish_day_transition())

func finish_day_transition() -> void:
	if controller.day_transition.is_empty(): return
	day_transition_serial += 1
	controller.dismiss_day_transition()
	if is_instance_valid(day_transition_panel):
		day_transition_panel.get_parent().remove_child(day_transition_panel)
		day_transition_panel.queue_free()
	day_transition_panel = null
	render()

func render_booking() -> void:
	var a: Dictionary = controller.state().appointment
	label(title_of(Model.procedure(str(a.case.procedure_id))), true)
	label(tr_key("dates") % [a.intake_day, a.operation_day, a.review_day])
	if controller.state().outcome.is_empty():
		label(tr_key("booked"))
		button("rebook", func(): editing_booking = true; record = a.case.duplicate(true); selected = a.team.duplicate(true); render())
		if controller.dev and controller.day() < int(a.operation_day):
			button("jump", func(): controller.demo_day = int(a.operation_day); render())
		button("start", func(): controller.error = ""; controller.start_operation(); render(), controller.day() == int(a.operation_day))
	else:
		if controller.day() >= int(a.review_day): label(tr_key("review"), true)
		label(tr_key("success" if controller.state().outcome.success else "aborted"))
		show_summary()
		button("settle", func(): controller.settle(); render(), controller.day() >= int(a.review_day))
	if controller.day() < int(a.operation_day if controller.state().outcome.is_empty() else a.review_day): label(tr_key("waiting"))

func show_summary() -> void:
	var s: Dictionary = controller.last_summary
	if s.has("hp"): label(tr_key("summary") % [s.hp, s.precision_failures, s.rescue_attempts, s.crises])

func render_operation() -> void:
	var session: RefCounted = controller.session
	if session.physiology != null: session.physiology.definition["_locale"] = "en" if english else "zh_CN"
	var roster: Dictionary = controller.state().appointment.team
	if session.splash_pending:
		var patient := Presentation.patient(controller.state().appointment.case, controller.game, english)
		var splash_path := str(patient.get("visuals", {}).get("portraits", {}).get("splash/general_anesthesia", ""))
		if splash_path.is_empty() or not ResourceLoader.exists("res://" + splash_path):
			session.splash_pending = false
			render()
			return
		label(tr_key("induction"), true)
		var proxy := Presentation.new()
		proxy.definition = {"patient_id":Presentation.patient_id(controller.state().appointment.case, controller.game)}
		if host.page.get_node_or_null("GeneralAnesthesiaSplash") == null:
			host.show_anesthesia_splash(proxy, "general", Presentation.patient(controller.state().appointment.case, controller.game, english))
			var overlay: Control = host.page.get_node_or_null("GeneralAnesthesiaSplash")
			if overlay != null:
				overlay.find_child("AnesthesiaSplashContinue", true, false).pressed.connect(func(): session.splash_pending = false; render())
		return
	if session.patient_ready_pending:
		var patient := Presentation.patient(controller.state().appointment.case, controller.game, english)
		label(tr_key("patient_ready_title"), true)
		var path := str(patient.get("visuals", {}).get("portraits", {}).get("intraoperative/anesthetized", ""))
		make_cast(patient, path, str(patient.get("name", "")), tr_key("patient_ready_text") % str(patient.get("name", "")), false)
		button("begin_timeout", func(): session.patient_ready_pending = false; render())
		add_team_patient_table()
		return
	if session.team_intro_index >= 0:
		var role: String = controller.ROLES[session.team_intro_index]
		label(tr_key("team_confirmation"), true)
		label(tr_key("roles." + role), true)
		show_staff(str(roster[role]), role, Presentation.line(controller.game, str(roster[role]), role, "timeout", str(session.definition.id), english))
		button("confirm_member", func(): session.team_intro_index += 1; session.team_intro_index = -1 if session.team_intro_index >= 7 else session.team_intro_index; render())
		add_team_patient_table()
		return
	if not (controller.dev and controller.fixture_mode):
		if session.finished:
			var actor := str(roster.get("anesthesia", ""))
			var terminal := Presentation.confirmation(actor, "anesthesia_outcome", "terminal_success" if session.success else "terminal_failure", str(session.definition.id), english)
			if not terminal.is_empty():
				show_staff(actor, "anesthesia", terminal)
			else:
				make_cast({}, "", tr_key("narration"), tr_key("success" if session.success else "aborted"), true)
		elif session.in_crisis():
			var crisis_line: Dictionary = session.operative_dialogue.current(session) if session.operative_dialogue != null else {}
			if crisis_line.is_empty(): show_staff(str(roster.primary_circulating), "primary_circulating", session.physiology.crisis_callout_text())
			else: show_operative_line(crisis_line, roster, session.last_result)
		elif session.operative_dialogue != null:
			var line: Dictionary = session.operative_dialogue.current(session)
			if not line.is_empty(): show_operative_line(line, roster, session.last_result)
	operation_panel.draw(session)
	var next: Button = find_child("dialogue_next", true, false)
	if next != null and next.visible and not next.disabled and is_instance_valid(cast_panel): register_story_continue(next)
	queue_operative_auto(session)

func queue_operative_auto(session: RefCounted) -> void:
	if not operative_auto or session.operative_dialogue == null: return
	var line: Dictionary = session.operative_dialogue.current(session, session.suppress_operative_dialogue)
	var next: Button = find_child("dialogue_next", true, false)
	if line.is_empty() or next == null or not next.visible or next.disabled: return
	var ticket := operative_auto_ticket
	var expected := str(line.id)
	get_tree().create_timer(1.35).timeout.connect(func():
		if not is_instance_valid(self) or not operative_auto or operative_auto_ticket != ticket or controller.session != session: return
		if str(session.operative_dialogue.current(session).get("id", "")) != expected: return
		if session.operative_dialogue.advance_sequence(session): render())

func show_operative_log(session: RefCounted) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = tr_key("operative_log")
	var entries := PackedStringArray()
	var roster: Dictionary = controller.state().appointment.team
	for item in session.operative_dialogue.history:
		var row: Dictionary = item.line
		var bound: Dictionary = Dialogue.bind_role(str(row.speaker_role), roster)
		var speaker_name := tr_key("player_speaker") if bound.get("id", "") == "PLAYER" else actor_name(str(bound.id)) if bound.has("id") and not str(bound.id).is_empty() else tr_key("narration")
		entries.append("%s · %s\n%s" % [item.stage, speaker_name, str(row.text_en if english else row.text)])
	dialog.dialog_text = "\n\n".join(entries)
	dialog.size = Vector2i(820, 500)
	host.page.add_child(dialog)
	dialog.visibility_changed.connect(func():
		if not dialog.visible: dialog.queue_free())
	dialog.popup_centered()

func add_team_patient_table() -> void:
	var patient := Presentation.patient(controller.state().appointment.case, controller.game, english)
	var table_path := str(patient.get("visuals", {}).get("portraits", {}).get("team_confirmation", ""))
	if not table_path.is_empty() and ResourceLoader.exists("res://" + table_path):
		var table := TextureRect.new()
		table.name = "AdvancedTeamPatientTable"
		table.custom_minimum_size = Vector2(0, 360)
		table.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		table.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		table.mouse_filter = Control.MOUSE_FILTER_IGNORE
		table.texture = load("res://" + table_path)
		body.add_child(table)

func make_cast(person: Dictionary, path: String, title: String, text: String, spoken: bool, role: String = "") -> void:
	if is_instance_valid(cast_panel):
		cast_panel.get_parent().remove_child(cast_panel)
		cast_panel.queue_free()
		cast_panel = null
	cast_panel = Control.new()
	cast_panel.name = "AdvancedCast"
	var compact := operation_active()
	cast_panel.position = Vector2(890, 170) if compact else Vector2(810, 165)
	cast_panel.size = Vector2(350, 490) if compact else Vector2(420, 570)
	cast_panel.set_meta("actor_id", str(person.get("id", "")))
	cast_panel.set_meta("portrait_path", path)
	cast_panel.set_meta("source_text", text)
	host.page.add_child(cast_panel)
	var art := TextureRect.new()
	art.name = "AdvancedActorPortrait"
	art.position = Vector2(10, 0)
	art.size = Vector2(330, 340) if compact else Vector2(400, 360)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not path.is_empty(): art.texture = load("res://" + path)
	cast_panel.add_child(art)
	var panel := Panel.new()
	panel.position = Vector2(0, 345) if compact else Vector2(0, 365)
	panel.size = Vector2(350, 125) if compact else Vector2(420, 195)
	panel.name = "AdvancedDialoguePanel"
	panel.add_theme_stylebox_override("panel", host.panel_style(Color("0b2832f5"), Color("91aeb0")))
	cast_panel.add_child(panel)
	var box := VBoxContainer.new()
	box.position = Vector2(12, 8); box.size = Vector2(326, 109) if compact else Vector2(392, 175)
	panel.add_child(box)
	var name_label := Label.new()
	name_label.name = "AdvancedSpeakerName"
	name_label.text = title if spoken or text.is_empty() else tr_key("narration") + " · " + title
	if not compact and not role.is_empty(): name_label.text += " · " + tr_key("roles."+role)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 16 if compact else 20)
	box.add_child(name_label)
	if compact and not role.is_empty():
		var role_tag := Label.new()
		role_tag.text = tr_key("roles."+role)
		role_tag.add_theme_font_size_override("font_size",13)
		role_tag.add_theme_color_override("font_color",Color("92dec2"))
		box.add_child(role_tag)
	var dialogue := RichTextLabel.new()
	dialogue.name = "AdvancedStaffDialogue"
	dialogue.bbcode_enabled = false
	dialogue.text = text
	dialogue.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue.add_theme_font_size_override("normal_font_size", 17 if compact else 19)
	box.add_child(dialogue)
	if compact and not text.is_empty():
		art.modulate = Color(1.05,1.05,1.05,1)

func show_patient(patient: Dictionary) -> void:
	var portraits: Dictionary = patient.get("visuals", {}).get("portraits", {})
	var path := str(portraits.get("ward", portraits.get("ward/neutral", portraits.get("intraoperative/anesthetized", ""))))
	make_cast(patient, path, str(patient.get("name", "")), tr_key("patient_cast"), true)

func render_first_story() -> void:
	var chapter: Dictionary = controller.story_content[controller.story_phase]
	var path: String = host.background_path(str(chapter.background))
	if not path.is_empty(): host.background.texture = load("res://"+path)
	var heading: Label = host.page.get_node("PageTitle")
	heading.text = str(chapter.title_en if english else chapter.title)
	heading.add_theme_font_size_override("font_size",26)
	host.page.get_node("PageSubtitle").hide()
	var line: Dictionary = chapter.lines[controller.story_index]
	var patient: Dictionary = Presentation.patient(controller.story_record, controller.game, english)
	var spoken: String = Presentation.format_story(str(line.text_en if english else line.text), title_of(Model.procedure(str(controller.story_record.procedure_id))))
	if line.speaker == "patient":
		var portraits: Dictionary = patient.get("visuals", {}).get("portraits", {})
		var portrait_path := str(portraits.get(chapter.portrait, ""))
		if portrait_path.is_empty() and chapter.portrait == "ward":
			portrait_path = str(portraits.get("ward/neutral", ""))
		make_cast(patient,portrait_path,str(patient.name),spoken,true)
	else:
		make_cast({"id":"PLAYER"},"",tr_key("narration" if line.speaker == "narrator" else "player_speaker"),spoken,true)
	cast_panel.set_meta("story_phase",controller.story_phase)
	cast_panel.set_meta("story_index",controller.story_index)
	cast_panel.position = Vector2(40,125)
	cast_panel.size = Vector2(1200,630)
	var art: TextureRect = cast_panel.get_node("AdvancedActorPortrait")
	art.position = Vector2(440,-10);art.size = Vector2(400,450)
	if line.speaker == "patient" and patient.get("visuals", {}).get("portrait_regions", {}).has(chapter.portrait) and art.texture != null:
		var portrait := AtlasTexture.new()
		portrait.atlas = art.texture
		portrait.region = patient.visuals.portrait_regions[chapter.portrait]
		art.texture = portrait
	if chapter.get("dark", false): host.background.modulate = Color(0.02,0.02,0.02)
	var panel: Panel = cast_panel.get_node("AdvancedDialoguePanel")
	panel.position = Vector2(0,435);panel.size = Vector2(1200,135)
	if chapter.portrait == "h_neutral":
		art.size = Vector2(220,220)
		art.position = Vector2(panel.size.x - art.size.x - 12, panel.position.y - art.size.y - 12)
	var box: VBoxContainer = panel.get_child(0)
	box.size = Vector2(1176,119)
	cast_panel.find_child("AdvancedStaffDialogue",true,false).add_theme_font_size_override("normal_font_size",22)
	var next := button("story_next",func(): controller.advance_story(); render(),true,tr_key("continue"))
	var skip := button("story_skip",func(): controller.finish_story(); render(),true,tr_key("failure_skip"))
	for control in [next,skip]:
		body.remove_child(control);cast_panel.add_child(control)
		control.position = Vector2(990 if control==next else 770,580)
		control.size = Vector2(210,46)

	register_story_continue(next)

func show_staff(id: String, role: String, text: String) -> void:
	var person: Dictionary = controller.game.staff_record(id)
	var key := Presentation.portrait_key(person, role)
	var path := str(person.get("visuals", {}).get("portraits", {}).get(key, ""))
	make_cast(person, path, actor_name(id), text, Presentation.is_spoken(text), role)

func show_assignment(role: String) -> void:
	var id := str(selected.get(role, ""))
	if id.is_empty(): return
	show_staff(id, role, Presentation.line(controller.game, id, role, "assignment", str(record.procedure_id), english))

func show_operative_line(line: Dictionary, roster: Dictionary, result: Dictionary = {}, ward: bool = false) -> void:
	var speaker := Dialogue.bind_role(str(line.speaker_role), roster, result)
	if speaker.is_empty(): return
	var text := str(line.text_en if english else line.text)
	if speaker.role in ["system", "lead_surgeon"]:
		make_cast({"id":speaker.id}, "", tr_key("narration" if speaker.role == "system" else "player_speaker"), text, true)
	else:
		var person: Dictionary = controller.game.staff_record(speaker.id)
		var path := str(person.get("visuals", {}).get("portraits", {}).get(Presentation.ward_portrait_key(person) if ward else Presentation.portrait_key(person, speaker.role), ""))
		make_cast(person, path, actor_name(speaker.id), text, true, str(speaker.role))
	cast_panel.set_meta("dialogue_id", str(line.id))

func render_failure_dialogue() -> void:
	label(tr_key("aborted"), true)
	var lines := Dialogue.failure_lines()
	show_operative_line(lines[controller.failure_dialogue_index], controller.review_roster, {}, true)
	var next := button("failure_next", func(): controller.failure_dialogue_index += 1; controller.failure_dialogue_index = -1 if controller.failure_dialogue_index >= lines.size() else controller.failure_dialogue_index; render())
	button("failure_skip", func(): controller.failure_dialogue_index = -1; render())
	register_story_continue(next)

func add_field_window(row: Container, session: RefCounted) -> void:
	var panel := PanelContainer.new()
	panel.name = "AdvancedOperativeField"
	panel.custom_minimum_size = Vector2(450, 337.5)
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	panel.add_theme_stylebox_override("panel", host.panel_style(Color("10252cf5"), Color("91aeb0")))
	row.add_child(panel)
	var path := Dialogue.field_path(session)
	panel.set_meta("asset_path", path)
	if not path.is_empty() and ResourceLoader.exists("res://" + path):
		var art := TextureRect.new()
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.texture = load("res://" + path)
		panel.add_child(art)
	else:
		var note := Label.new()
		note.text = tr_key("field_pending")
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		note.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		note.add_theme_font_size_override("font_size", 18)
		panel.add_child(note)

# Only linear story/review pages receive dialogue shortcuts; choices and surgery
# actions never inherit a stale default button from the preceding page.
func register_story_continue(next: Button) -> void:
	host.register_dialogue_continue(next, str(cast_panel.get_meta("source_text", "")))
	var panel := cast_panel.get_node("AdvancedDialoguePanel") as Control
	ignore_dialogue_children(panel)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			panel.accept_event()
			host.activate_dialogue_default())

func ignore_dialogue_children(node: Node) -> void:
	for child in node.get_children():
		if child is Control: child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ignore_dialogue_children(child)

func _input(event: InputEvent) -> void:
	if controller != null and not controller.day_transition.is_empty():
		var confirm: bool = (event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
		if confirm:
			get_viewport().set_input_as_handled()
			finish_day_transition()
		return
	if controller == null or (controller.story_phase.is_empty() and controller.failure_dialogue_index < 0 and body.find_child("dialogue_next", true, false) == null): return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
		if host.activate_dialogue_default(): get_viewport().set_input_as_handled()
