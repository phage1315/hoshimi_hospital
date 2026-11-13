extends RefCounted
## Display the authored tendency and optional mischief cue, not a promise to bypass a phase cap.
const Progression = preload("res://godot/systems/progression_config.gd")
const ButtonText = preload("res://godot/ui/button_text.gd")

static func decorate(app: Control, button: Button, action: Dictionary, phase: String) -> void:
	var delta := Progression.action_presence_delta(action)
	var mischief := bool(action.get("mischief", false))
	if delta == 0 and not mischief:
		return
	var caption := str(button.get_meta("caption_source", button.text))
	if mischief:
		button.set_meta("mischief_hint", true)
		if not caption.begins_with("😈"):
			caption = "😈 " + caption
		var mischief_detail: String = app.tx("ui.mischief.hint", "😈 非必要恶趣味操作：并非本次医疗必需步骤，将额外刺激患者的羞耻反应。")
		button.tooltip_text = (button.tooltip_text + "\n" if not button.tooltip_text.is_empty() else "") + mischief_detail
		button.add_theme_stylebox_override("normal", app.panel_style(Color("341f2eed"), Color("b96f95")))
		button.add_theme_stylebox_override("hover", app.panel_style(Color("46283efa"), Color("e295bc")))
		button.add_theme_stylebox_override("pressed", app.panel_style(Color("281623ff"), Color("f0b3d1")))
		button.add_theme_stylebox_override("focus", app.panel_style(Color("3d2336f7"), Color("e295bc")))
		button.add_theme_color_override("font_color", Color("f6c2da"))
		button.add_theme_color_override("font_hover_color", Color("ffe0ee"))
	if delta != 0:
		var direction: String = app.tx("ui.presence.assertive", "强势") if delta > 0 else app.tx("ui.presence.gentle", "温柔")
		var strength := 3 if absi(delta) >= 5 else 2 if absi(delta) >= 2 else 1
		var clue := direction + "+".repeat(strength)
		button.set_meta("presence_hint", clue)
		button.set_meta("presence_delta", delta)
		caption = caption + "  ·  " + clue
		var detail: String = app.tx("ui.presence.hint", "职业气场 %s；本阶段累计上限 ±%s。正负选择相互抵消，达到上限后可能不再变化。") % ["%+d" % delta, Progression.PRESENCE_PHASE_CLAMPS[phase]]
		button.tooltip_text = (button.tooltip_text + "\n" if not button.tooltip_text.is_empty() else "") + detail
		if not mischief:
			button.add_theme_color_override("font_color", Color("f1c28a") if delta > 0 else Color("a6d9df"))
	button.set_meta("caption_source", caption)
	var preferred_font := mini(20, button.get_theme_font_size("font_size")) if button.has_theme_font_size_override("font_size") else 20
	ButtonText.fit(button, button.size, preferred_font)
