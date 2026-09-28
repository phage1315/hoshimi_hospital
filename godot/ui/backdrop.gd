extends Control
## Original geometric background / silhouette, intentionally replaceable.
var portrait_color := Color("b4c8cc")
var show_portrait := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var s := size
	draw_rect(Rect2(Vector2.ZERO, s), Color("dce5e3"))
	for i in range(5):
		var x := 60.0 + i * 255.0
		draw_rect(Rect2(x, 100, 190, 360), Color("a8c9cc"))
		draw_rect(Rect2(x + 7, 108, 176, 165), Color("c6dedc"))
		draw_line(Vector2(x + 95, 100), Vector2(x + 95, 460), Color("f0eee4"), 8)
		draw_line(Vector2(x, 280), Vector2(x + 190, 280), Color("f0eee4"), 8)
	draw_rect(Rect2(0, 460, s.x, s.y - 460), Color("bac9c8"))
	for i in range(8):
		draw_line(Vector2(s.x / 2, 455), Vector2(i * 260 - 260, s.y), Color("a8bbbb"), 1)
	draw_rect(Rect2(0, 450, s.x, 12), Color("819e9f"))
	draw_rect(Rect2(60, 395, 260, 18), Color("9faaa2"))
	draw_rect(Rect2(80, 413, 14, 65), Color("849b97"))
	draw_rect(Rect2(285, 413, 14, 65), Color("849b97"))
	if show_portrait:
		var c := Vector2(s.x * 0.72, 292)
		draw_circle(c, 61, portrait_color.darkened(0.2))
		draw_circle(c + Vector2(0, 8), 47, Color("eee0d4"))
		draw_colored_polygon(PackedVector2Array([c+Vector2(-57,58),c+Vector2(57,58),c+Vector2(107,280),c+Vector2(-107,280)]),portrait_color)
		draw_colored_polygon(PackedVector2Array([c+Vector2(-45,60),c+Vector2(-5,90),c+Vector2(-22,255),c+Vector2(-85,255)]),Color("f3f1e9"))
		draw_colored_polygon(PackedVector2Array([c+Vector2(45,60),c+Vector2(5,90),c+Vector2(22,255),c+Vector2(85,255)]),Color("f3f1e9"))
