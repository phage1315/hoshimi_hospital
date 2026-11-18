extends Control

var scene_id: String = "ward":
	set(value):
		scene_id = value
		queue_redraw()
var anxiety: int = 50:
	set(value):
		anxiety = value
		queue_redraw()
var changed: bool = false:
	set(value):
		changed = value
		queue_redraw()

func _draw() -> void:
	# Subtle translucent clinical status card that lets the cel-shaded room
	# background breathe instead of drawing blocky prototype rectangles over it.
	var outer := Rect2(Vector2(24, 38), size - Vector2(48, 76))
	draw_rect(outer, Color(0.035, 0.105, 0.135, 0.56))
	draw_rect(outer, Color(0.73, 0.67, 0.50, 0.52), false, 1.5)
	var inner := outer.grow(-10.0)
	draw_rect(inner, Color(0.44, 0.60, 0.62, 0.24), false, 1.0)
	var center := outer.get_center() - Vector2(0, 14)
	var accent := Color("7eb696") if changed else Color("e8cfaa")
	draw_arc(center, 38.0, 0.0, TAU, 48, Color(accent.r, accent.g, accent.b, 0.72), 2.0, true)
	draw_arc(center, 29.0, 0.0, TAU, 48, Color(0.76, 0.85, 0.84, 0.28), 1.0, true)
	# Minimalist medical cross / check emblem inside the ring.
	if changed and scene_id in ["changing", "scrub_area", "or_entrance"]:
		draw_line(center + Vector2(-13, 1), center + Vector2(-3, 11), accent, 3.0, true)
		draw_line(center + Vector2(-3, 11), center + Vector2(15, -9), accent, 3.0, true)
	else:
		draw_rect(Rect2(center - Vector2(4, 15), Vector2(8, 30)), Color(accent.r, accent.g, accent.b, 0.80))
		draw_rect(Rect2(center - Vector2(15, 4), Vector2(30, 8)), Color(accent.r, accent.g, accent.b, 0.80))
	var bar_width := outer.size.x - 88.0
	var bar_pos := Vector2(outer.position.x + 44.0, outer.end.y - 44.0)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, 6.0)), Color(0.14, 0.25, 0.29, 0.75))
	var progress_ratio := 1.0 if changed else clampf(1.0 - float(anxiety) / 120.0, 0.25, 0.85)
	draw_rect(Rect2(bar_pos, Vector2(bar_width * progress_ratio, 6.0)), Color(accent.r, accent.g, accent.b, 0.78))
