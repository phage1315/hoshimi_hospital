extends RefCounted
## Read-only decision HUD. All actions/probabilities/effects remain in the runner.
const Model = preload("res://godot/systems/advanced_surgery_model.gd")
const Dialogue = preload("res://godot/systems/advanced_operative_dialogue.gd")
var view: Control
var last_session := 0
var previous: Dictionary = {}
var changes: Dictionary = {}
var changed_at := 0
const INK = Color("f0f4ef")
const MUTED = Color("a3bcb9")
const GOOD = Color("92dec2")
const WARN = Color("f5c685")
const DANGER = Color("ef9696")

func _init(owner: Control): view = owner
func side_id(side: String) -> int:
	return {"left":SIDE_LEFT,"right":SIDE_RIGHT,"top":SIDE_TOP,"bottom":SIDE_BOTTOM}[side]
func tx(key: String) -> String: return view.tr_key(key)
func text(parent: Node, value: String, font: int = 18, color: Color = INK) -> Label:
	var l := Label.new()
	l.text = value
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", font)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l
func box(parent: Node, width: float = 0) -> VBoxContainer:
	var b := VBoxContainer.new()
	b.custom_minimum_size.x = width
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_constant_override("separation", 8)
	parent.add_child(b)
	return b
func values(s: RefCounted) -> Dictionary:
	var result: Dictionary = s.physiology.procedure_state.duplicate(true) if s.physiology != null else {}
	result.hp = s.hp
	return result
func observe(s: RefCounted) -> void:
	var now := values(s)
	if last_session != s.get_instance_id():
		last_session = s.get_instance_id(); previous = now; changes.clear()
	elif now != previous:
		changes.clear()
		for key in now:
			var delta := int(now[key]) - int(previous.get(key, now[key]))
			if delta != 0: changes[key] = delta
		changed_at = Time.get_ticks_msec()
		previous = now

func draw(s: RefCounted) -> void:
	observe(s)
	progress(s)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	view.body.add_child(row)
	var field := box(row, 450)
	field.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var step: Dictionary = s.definition.steps[mini(s.index, s.definition.steps.size()-1)]
	text(field, "%02d / %02d  ·  %s · %s" % [mini(s.index+1,s.definition.steps.size()),s.definition.steps.size(),step.kind,tx("operation_"+str(step.kind))], 16, MUTED)
	var heading := text(field, view.title_of(step), 19 if view.title_of(step).length()>38 else 23)
	heading.custom_minimum_size.y = 30
	if Dialogue.field_visible(s): view.add_field_window(field, s)
	else:
		var empty := PanelContainer.new()
		empty.custom_minimum_size = Vector2(450,337.5)
		empty.add_theme_stylebox_override("panel",view.host.panel_style(Color("10252ca8"),Color("385b64")))
		field.add_child(empty)
		var note := text(empty,tx("field_closed" if s.finished or s.index>0 else "field_not_open"),18,MUTED)
		note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;note.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	text(field,tx("current_action") % (tx(str(step.specialty_tag)) if step.kind=="P" else tx("operation_"+str(step.kind))),16,MUTED)
	monitor(row,s)
	actions(s)

func progress(s: RefCounted) -> void:
	var row := HBoxContainer.new()
	row.name = "AdvancedStageProgress"
	row.add_theme_constant_override("separation", 5)
	row.tooltip_text = tx("progress_help")
	view.body.add_child(row)
	for i in range(s.definition.steps.size()):
		var p := PanelContainer.new()
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		p.custom_minimum_size.y = 25
		var precision: bool = s.definition.steps[i].kind == "P"
		var fill := Color("254c60") if precision else Color("203a40")
		if i < s.index or s.finished: fill = Color("3e6963")
		var edge := Color("c1e7db") if i==s.index and not s.finished else Color("517685") if precision else Color("39565b")
		var style:StyleBoxFlat=view.host.panel_style(fill,edge)
		for side in ["left","right","top","bottom"]:style.set_content_margin(side_id(side),0)
		p.add_theme_stylebox_override("panel",style)
		p.set_meta("stage_kind",s.definition.steps[i].kind)
		row.add_child(p)
		var l := text(p,"%02d"%(i+1),14)
		l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode=TextServer.AUTOWRAP_OFF

func condition_warning(s: RefCounted, metric: String) -> bool:
	if s.physiology==null:return false
	# Only thresholds already authored in this procedure; no invented vital cutoffs.
	for step in s.definition.steps:
		for effect in step.get("conditional_effects",[]):
			var c: Dictionary = effect.get("when",{})
			if str(c.get("field",c.get("metric","")))==metric and s.physiology.surgery_condition_met(c):return true
	return false
func metric(parent: Node, s: RefCounted, key: String) -> void:
	var panel := PanelContainer.new()
	panel.name="Metric_"+key
	panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size.y=70
	var warning := condition_warning(s,key)
	var critical: bool = not s.finished and s.in_crisis() and key=="stability"
	var style:StyleBoxFlat=view.host.panel_style(Color("102e36e8"), DANGER if critical else WARN if warning else Color("42636a"))
	style.content_margin_left=10;style.content_margin_right=10;style.content_margin_top=5;style.content_margin_bottom=5
	panel.add_theme_stylebox_override("panel",style)
	if warning:panel.tooltip_text=tx("condition_active")
	parent.add_child(panel)
	var b:=box(panel)
	b.add_theme_constant_override("separation",2)
	text(b,tx("metric."+key),15,MUTED)
	var line:=HBoxContainer.new();b.add_child(line)
	var n: Variant=values(s).get(key)
	var value: String="—" if n==null else tx("minutes_short")%n if key=="elapsed_time" else "%s / 100"%n if key=="hp" else str(n)
	var value_label:=text(line,value,27,DANGER if critical else WARN if warning else INK)
	value_label.name="MetricValue_"+key
	value_label.autowrap_mode=TextServer.AUTOWRAP_OFF
	var delta:=text(line,"",19)
	delta.name="MetricDelta_"+key
	delta.autowrap_mode=TextServer.AUTOWRAP_OFF
	var remaining:=2200-(Time.get_ticks_msec()-changed_at)
	if changes.has(key) and remaining>0:
		var amount:=int(changes[key]);delta.text="  %+d"%amount
		var improving: bool=amount>0 if key in ["hp","stability","visibility"] else amount<0
		delta.add_theme_color_override("font_color",MUTED if key=="elapsed_time" else GOOD if improving else WARN)
		delta.tooltip_text=tx("change_hint")
		var tween:=delta.create_tween()
		tween.tween_interval(maxf(0,float(remaining)/1000.0-.5))
		tween.tween_property(delta,"modulate:a",0.0,.5)
func monitor(parent: Node, s: RefCounted) -> void:
	var b:=box(parent)
	text(b,tx("crisis_panel" if not s.finished and s.in_crisis() else "monitor"),18,DANGER if not s.finished and s.in_crisis() else MUTED)
	metric(b,s,"hp")
	var grid:=GridContainer.new();grid.columns=2
	grid.add_theme_constant_override("h_separation",8);grid.add_theme_constant_override("v_separation",8)
	b.add_child(grid)
	for key in ["stability","visibility","bleeding","blood_loss"]:metric(grid,s,key)
	metric(b,s,"elapsed_time")
	for who in [1,2]:
		var a:Dictionary=s.team.assistants[who-1]
		var left:=Model.remaining_uses(a,int(s.used[who-1]),s.definition.steps[mini(s.index,s.definition.steps.size()-1)])
		var is_precision: bool=not s.finished and s.current().kind=="P"
		if not is_precision:
			left=0
			for candidate in s.definition.steps:
				if candidate.kind=="P":left=maxi(left,Model.remaining_uses(a,int(s.used[who-1]),candidate))
		var l:=text(b,tx("roles.first_assistant" if who==1 else "roles.second_assistant")+" · "+tx("remaining" if is_precision else "remaining_max")%left,15,MUTED)
		l.mouse_filter=Control.MOUSE_FILTER_PASS;l.tooltip_text=tx("help_uses")

func card(parent: Node, id: String, title: String, main: String, detail: String, callback: Callable, enabled: bool=true) -> Button:
	var button:=Button.new()
	button.name=id
	button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	button.custom_minimum_size=Vector2(0,135)
	button.disabled=not enabled
	button.add_theme_stylebox_override("normal",view.host.panel_style(Color("153b44f5"),Color("678c91")))
	button.add_theme_stylebox_override("hover",view.host.panel_style(Color("24515bf5"),Color("abe0cf")))
	button.add_theme_stylebox_override("focus",view.host.panel_style(Color("24515b60"),Color("c4f2de")))
	button.add_theme_stylebox_override("disabled",view.host.panel_style(Color("16282bd9"),Color("344b50")))
	parent.add_child(button)
	var margin:=MarginContainer.new();margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right","top","bottom"]:margin.add_theme_constant_override("margin_"+side,8)
	margin.add_theme_constant_override("margin_top",6);margin.add_theme_constant_override("margin_bottom",6)
	margin.mouse_filter=Control.MOUSE_FILTER_IGNORE;button.add_child(margin)
	var b:=box(margin);b.mouse_filter=Control.MOUSE_FILTER_IGNORE;b.add_theme_constant_override("separation",2)
	text(b,title,16,MUTED if not enabled else GOOD)
	text(b,main,17 if main.length()>36 else 20,MUTED if not enabled else INK)
	text(b,detail,14 if detail.length()>60 else 15,MUTED)
	button.tooltip_text=title+"\n"+main+"\n"+detail
	button.pressed.connect(callback)
	return button
func effects_text(e: Dictionary) -> String:
	var parts:=PackedStringArray()
	for key in ["elapsed_time","visibility","bleeding","blood_loss","stability"]:
		if int(e.get(key,0))!=0:parts.append(tx("metric."+key)+" %+d"%int(e[key]))
	return " · ".join(parts)
func actions(s: RefCounted) -> void:
	var row:=HBoxContainer.new();row.name="AdvancedActionCards"
	row.add_theme_constant_override("separation",10)
	view.body.add_child(row)
	if s.finished:
		card(row,"finish",tx("stage_result"),tx("success" if s.success else "aborted"),"",func():view.controller.finish_operation();view.render())
		return
	var step:Dictionary=s.current()
	if s.in_crisis():
		for choice in s.physiology.crisis_rescue_options():
			var chance:int=s.physiology.crisis_rescue_chance(str(choice.id))
			card(row,str(choice.id),tx("chance")%chance,str(choice.label),tx("minutes_short")%choice.minutes,func():s.resolve_crisis(str(choice.id));view.render())
		return
	if s.awaiting_ack and not s.pending_rescue:
		card(row,"continue",tx("stage_result"),tx("result")%[s.last_result.cost,tx("fail" if s.last_result.failed else "pass")],tx("continue"),func():s.acknowledge();view.render())
		return
	if s.pending_rescue or step.kind=="P":
		for who in range(3):
			var a:Dictionary={} if who==0 else s.team.assistants[who-1]
			var name:String=tx("player_speaker") if who==0 else view.title_of(a) if view.controller.fixture_mode else view.actor_name(str(a.id))
			var role:String=tx("lead_surgeon" if who==0 else "roles.first_assistant" if who==1 else "roles.second_assistant")
			var skill:int=int(s.team.player) if who==0 else int(a.skill)
			var probability:=roundi(Model.probability(skill,step,s.team,s.variant)*100)
			var detail:=tx("no_quota") if who==0 else tx("remaining")%Model.remaining_uses(a,int(s.used[who-1]),step)+" · "+tx("consume_one")
			var eligible:bool=s.eligible(who)
			if not eligible:detail=tx(Model.unavailable_reason(a,int(s.used[who-1]),step))
			var id:String=("correct" if who==0 else "rescue_%s"%who) if s.pending_rescue else ("operate" if who==0 else "delegate_%s"%who)
			var action:String=tx("self_correct") if who==0 and s.pending_rescue else tx("chance")%probability
			var b:=card(row,id,role+" · "+name,action,detail,func():
				if s.pending_rescue:s.rescue(who)
				else:s.act(who)
				view.render(),eligible)
			b.set_meta("probability",probability);b.set_meta("remaining",-1 if who==0 else Model.remaining_uses(a,int(s.used[who-1]),step))
			b.tooltip_text+="\n"+tx("help_uses")
	elif step.kind=="S" and not s.strategy_options().is_empty():
		for choice in s.strategy_options():
			var title:String=str(choice.label_en if view.english else choice.label)
			var b:=card(row,"strategy_"+str(choice.id),tx("operation_S"),title,effects_text(choice.get("strategic_effects",{})),func():s.act(0,str(choice.id));view.render())
			b.tooltip_text+= "\n"+str(choice.get("description_en" if view.english else "description",""))
	else:
		card(row,"standard" if step.kind=="S" else "continue",tx("operation_"+str(step.kind)),tx("complete_step"),"",func():s.act();view.render())
