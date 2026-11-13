extends RefCounted
## Day 1 presentation only; all eligibility, values and estimates come from existing services.
const Model = preload("res://godot/systems/advanced_surgery_model.gd")
const Presentation = preload("res://godot/systems/advanced_presentation.gd")
var view: Control
var root: Control
var definition: Dictionary
var dates: Dictionary
var summaries: Dictionary = {}
var pickers: Dictionary = {}
var avatar_slots: Dictionary = {}
var assessment: Label
var coverage: Label
var confirm: Button
var specialties: Dictionary

func _init(owner: Control) -> void:
	view = owner

func text(parent: Control, caption: String, rect: Rect2, font: int = 18) -> Label:
	var node := Label.new()
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.clip_text = true
	node.add_theme_font_size_override("font_size", font)
	node.add_theme_color_override("font_color", Color("f4f0e6"))
	parent.add_child(node)
	node.text = caption
	node.position = rect.position
	node.size = rect.size
	return node

func panel(parent: Control, name: String, rect: Rect2) -> Panel:
	var node := Panel.new()
	node.name = name
	node.position = rect.position
	node.size = rect.size
	node.add_theme_stylebox_override("panel", view.host.panel_style(Color("102c35ed"), Color("668f96")))
	parent.add_child(node)
	return node

func draw() -> void:
	definition = Model.procedure(str(view.record.procedure_id))
	dates = view.controller.schedule()
	specialties = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/specialties.json"))
	root = Control.new()
	root.name = "AdvancedTeamPanel"
	root.custom_minimum_size = Vector2(1180, 540)
	view.body.add_child(root)
	var roles: Array = ["lead_surgeon", "anesthesia", "first_assistant", "second_assistant", "primary_scrub", "secondary_scrub", "primary_circulating", "secondary_circulating"]
	for index in range(roles.size()):
		var role: String = roles[index]
		var card := panel(root, "TeamCard_"+role, Rect2((index%2)*330, (index/2)*116, 318, 106))
		text(card, view.tr_key("team_lead_fixed" if index==0 else "roles."+role), Rect2(12,6,294,24),16)
		if index==0:
			text(card, view.tr_key("player_speaker"), Rect2(12,28,294,36),20)
			text(card, view.tr_key("team_skill_surgery")+" · "+str(view.controller.demo_player_skill if view.controller.dev else view.controller.game.surgery_level()), Rect2(12,68,294,30),16)
			continue
		var avatar_slot: Panel = view.host.add_staff_chibi_slot(card, str(view.selected.get(role, "")), Vector2(10, 30), 36.0, not str(view.selected.get(role, "")).is_empty(), "TeamAvatarSlot_" + role)
		avatar_slots[role] = avatar_slot
		var picker := OptionButton.new()
		picker.name = "Team_"+role
		picker.position = Vector2(52,32)
		picker.size = Vector2(256,32)
		picker.fit_to_longest_item = false
		picker.add_theme_font_size_override("font_size",16)
		picker.add_item(view.tr_key("pick")); picker.set_item_metadata(0, "")
		for person in view.controller.candidates(role, int(dates.get("operation_day", view.controller.day()+1))):
			picker.add_item(view.actor_name(person.id))
			var item_idx := picker.item_count - 1
			picker.set_item_metadata(item_idx, person.id)
			var small_tex: Texture2D = view.host.staff_chibi_small_texture(str(person.id))
			if small_tex != null:
				picker.set_item_icon(item_idx, small_tex)
			if view.selected.get(role, "")==person.id: picker.select(item_idx)
		picker.icon = null
		picker.item_selected.connect(func(i): view.selected[role]=picker.get_item_metadata(i); refresh())
		card.add_child(picker)
		pickers[role]=picker
		summaries[role]=text(card,"",Rect2(12,68,294,36),12)
	var patient: Dictionary = Presentation.patient(view.record,view.controller.game,view.english)
	var patient_panel := panel(root,"TeamCase",Rect2(670,0,510,186))
	text(patient_panel,view.tr_key("team_case"),Rect2(14,8,340,24),16)
	text(patient_panel,str(patient.get("name","")),Rect2(14,32,326,36),20)
	var diagnosis: String = str(patient.get("diagnosis_en" if view.english else "diagnosis",definition.patient_notice_en if view.english else definition.patient_notice))
	if view.record.has("staff_patient_id"): diagnosis = view.tr_key("staff_pool")
	# Author diagnoses can be longer than Whipple's. Keep the full source readable
	# inside this fixed case card without scrolling the team controls or footer.
	var diagnosis_box := RichTextLabel.new()
	diagnosis_box.name = "TeamDiagnosis"
	diagnosis_box.position = Vector2(14,70); diagnosis_box.size = Vector2(326,68)
	diagnosis_box.bbcode_enabled = false
	diagnosis_box.text = diagnosis; diagnosis_box.tooltip_text = diagnosis
	diagnosis_box.add_theme_font_size_override("normal_font_size",14)
	patient_panel.add_child(diagnosis_box)
	var tags: Array[String]=[]
	for step in definition.steps:
		if step.kind=="P" and view.tr_key(step.specialty_tag) not in tags: tags.append(view.tr_key(step.specialty_tag))
	var tag_label := text(patient_panel," · ".join(tags),Rect2(14,139,326,42),12)
	tag_label.tooltip_text=" · ".join(tags)
	var art := TextureRect.new()
	art.name="TeamPatientPortrait"
	art.position=Vector2(350,8); art.size=Vector2(150,170)
	art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var portraits: Dictionary=patient.get("visuals",{}).get("portraits",{})
	var path: String=str(portraits.get("ward",portraits.get("ward/neutral",portraits.get("intraoperative/anesthetized",""))))
	if not path.is_empty(): art.texture=load("res://"+path)
	patient_panel.add_child(art)
	var estimate_panel := panel(root,"TeamAssessment",Rect2(670,196,510,258))
	text(estimate_panel,view.tr_key("team_estimate_title"),Rect2(14,6,480,32),18)
	assessment=text(estimate_panel,"",Rect2(14,37,480,52),32)
	assessment.name="TeamEstimate"
	view.risk_label=assessment
	text(estimate_panel,view.tr_key("team_estimate_note"),Rect2(14,92,480,52),14)
	coverage=text(estimate_panel,"",Rect2(14,150,480,42),17)
	coverage.name="TeamCoverage"
	text(estimate_panel,view.tr_key("calendar") if dates.is_empty() else view.tr_key("dates") % [dates.intake_day,dates.operation_day,dates.review_day],Rect2(14,208,480,42),14)
	var footer := panel(root,"TeamFooter",Rect2(0,466,1180,74))
	var back := Button.new()
	back.name="new";back.position=Vector2(10,15);back.size=Vector2(210,44);back.text=view.tr_key("team_back");back.add_theme_font_size_override("font_size",18)
	back.pressed.connect(func(): view.record = {};view.editing_booking=false;view.render())
	footer.add_child(back)
	var warning := text(footer,view.tr_key("staff_warning" if view.record.has("staff_patient_id") else "team_replay_warning" if view.record.replay else "team_first_warning"),Rect2(236,8,630,58),16)
	warning.add_theme_color_override("font_color",Color("ffd09b"))
	confirm=Button.new()
	confirm.name="accept";confirm.position=Vector2(880,15);confirm.size=Vector2(290,44)
	confirm.text=view.tr_key("team_rebook" if view.editing_booking else "team_confirm")
	confirm.add_theme_font_size_override("font_size",18)
	confirm.pressed.connect(view.accept_case)
	footer.add_child(confirm)
	refresh()

func assistant(id: String) -> Dictionary:
	return {"id":id,"skill":view.controller.game.staff_skill_value(id,"surgery"),"specialties":specialties.get(id,{}).get("tags",[]),"universal_expert":specialties.get(id,{}).get("universal_expert",false)}

func refresh() -> void:
	var nodes: Array=definition.steps.filter(func(step):return step.kind=="P")
	for role in pickers:
		var picker: OptionButton=pickers[role]
		for i in range(1,picker.item_count):
			var id: String=str(picker.get_item_metadata(i))
			var occupied: bool=id in view.selected.values() and view.selected.get(role,"")!=id
			picker.set_item_disabled(i,occupied)
		var id: String=str(view.selected.get(role,""))
		picker.icon = null
		if avatar_slots.has(role) and is_instance_valid(avatar_slots[role]):
			var old_slot: Panel = avatar_slots[role]
			var card_parent: Control = old_slot.get_parent() as Control
			old_slot.queue_free()
			if card_parent != null:
				avatar_slots[role] = view.host.add_staff_chibi_slot(card_parent, id, Vector2(10, 30), 36.0, not id.is_empty(), "TeamAvatarSlot_" + role)
		var label: Label=summaries[role]
		if id.is_empty(): label.text=view.tr_key("pick"); continue
		var skill: String=view.controller.game.role_training_skill(role)
		if role=="anesthesia": skill="calmness"
		var skill_value: int=view.controller.game.staff_skill_value(id,skill)
		label.text=view.tr_key("team_skill_"+skill)+" · "+str(skill_value)
		if role in ["first_assistant","second_assistant"]:
			var a := assistant(id)
			var uses := 1
			var tags: Array[String]=[]
			for tag in a.specialties: tags.append(view.tr_key(tag))
			for step in nodes: uses=maxi(uses,Model.remaining_uses(a,0,step))
			label.text+=" · "+view.tr_key("team_uses")%uses
			label.text+="\n"+view.tr_key("universal" if a.universal_expert else "team_specialist" if uses==2 else "team_standard")
			label.tooltip_text=" · ".join(tags)+"\n"+view.tr_key("help_uses")
			label.set_meta("max_uses",uses)
		label.set_meta("skill",skill_value)
	var valid: bool=not dates.is_empty() and view.controller.valid_team(view.selected,int(dates.operation_day))
	confirm.disabled=not valid
	if not valid:
		assessment.text=view.tr_key("team_incomplete")
		assessment.add_theme_font_size_override("font_size",23)
		coverage.text=view.tr_key("team_pick_hint")
		coverage.tooltip_text=""
		root.set_meta("estimate_key","")
		return
	var team: Dictionary=view.controller.values(view.selected,str(view.record.procedure_id))
	var key: String=str(view.record.procedure_id)+JSON.stringify(team)
	if not view.estimate_cache.has(key): view.estimate_cache[key]=Model.estimate(definition,team)
	var estimate: Dictionary=view.estimate_cache[key]
	assessment.add_theme_font_size_override("font_size",32)
	assessment.text=view.tr_key("team_percent")%estimate.rounded_percent
	assessment.set_meta("percent",estimate.rounded_percent)
	root.set_meta("estimate_key",key)
	var covered := 0
	var details: Array[String]=[]
	for step in nodes:
		var names: Array[String]=[]
		for a in team.assistants:
			if a.universal_expert or step.specialty_tag in a.specialties: names.append(view.actor_name(a.id))
		if not names.is_empty(): covered+=1
		details.append(view.title_of(step)+": "+(view.tr_key("none") if names.is_empty() else ", ".join(names)))
	coverage.text=view.tr_key("team_coverage")%[covered,nodes.size()]
	coverage.tooltip_text="\n".join(details)+"\n"+view.tr_key("team_coverage_note")
	coverage.set_meta("covered",covered)
