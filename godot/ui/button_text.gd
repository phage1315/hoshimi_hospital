extends RefCounted
## Fit display text to an authored button rectangle without enlarging hitboxes.
## The original caption is retained verbatim in metadata and in the tooltip.

static func fit(button: Button, bounds: Vector2, preferred_size: int = 22) -> void:
	var source := str(button.get_meta("caption_source", button.text))
	button.set_meta("caption_source", source)
	button.clip_text = true
	var font := button.get_theme_font("font")
	var style := button.get_theme_stylebox("normal")
	var usable := bounds - style.get_minimum_size()
	var caption := source
	var selected_size := 14
	for font_size in range(preferred_size, 13, -1):
		caption = wrap_words(source, font, font_size, usable.x)
		var measured := font.get_multiline_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		if measured.x <= usable.x and measured.y <= usable.y:
			selected_size = font_size
			break
	button.add_theme_font_size_override("font_size", selected_size)
	button.text = caption
	if button.tooltip_text.is_empty():
		button.tooltip_text = source
	button.size = bounds

static func wrap_words(source: String, font: Font, font_size: int, width: float) -> String:
	var lines: Array[String] = []
	for paragraph in source.split("\n"):
		var line := ""
		for word in paragraph.split(" ", false):
			var candidate := word if line.is_empty() else line + " " + word
			if not line.is_empty() and font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > width:
				lines.append(line)
				line = word
			else:
				line = candidate
		lines.append(line)
	return "\n".join(lines)
