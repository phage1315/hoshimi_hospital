extends RefCounted
## Display the authored tendency, not a promise to bypass a phase cap.
const Progression = preload("res://godot/systems/progression_config.gd")
const ButtonText = preload("res://godot/ui/button_text.gd")

static func decorate(app: Control, button: Button, action: Dictionary, phase: String) -> void:
	var delta := Progression.action_presence_delta(action)
	if delta == 0:
		return
	var direction: String = app.tx("ui.presence.assertive", "强势") if delta > 0 else app.tx("ui.presence.gentle", "温柔")
	var strength := 3 if absi(delta) >= 5 else 2 if absi(delta) >= 2 else 1
	var clue := direction + "+".repeat(strength)
	var original := str(button.get_meta("caption_source", button.text))
	button.set_meta("presence_hint", clue)
	button.set_meta("presence_delta", delta)
	button.set_meta("caption_source", original + "  ·  " + clue)
	var detail: String = app.tx("ui.presence.hint", "职业气场 %s；本阶段累计上限 ±%s。正负选择相互抵消，达到上限后可能不再变化。") % ["%+d" % delta, Progression.PRESENCE_PHASE_CLAMPS[phase]]
	button.tooltip_text = (button.tooltip_text + "\n" if not button.tooltip_text.is_empty() else "") + detail
	button.add_theme_color_override("font_color", Color("f1c28a") if delta > 0 else Color("a6d9df"))
	ButtonText.fit(button, button.size, 20)
