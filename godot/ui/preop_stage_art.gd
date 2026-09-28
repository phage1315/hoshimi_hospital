extends Control
## Native vector blocking for new locations; replaceable by final scene images.
var scene_id := "ward"
var anxiety := 2
var changed := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var pale := Color("c9dfdc")
	var dark := Color("40646c")
	if scene_id == "changing":
		for i in range(3):
			draw_style_box(box(Color("90a9a9")), Rect2(10 + i * 72, 48, 63, 280))
			draw_line(Vector2(60 + i * 72, 164), Vector2(60 + i * 72, 188), dark, 3)
		draw_rect(Rect2(256, 183, 170, 50), pale)
		draw_arc(Vector2(340, 183), 22, PI, TAU, 24, dark, 6)
		draw_rect(Rect2(282, 230, 123, 96), dark)
		if changed:
			draw_circle(Vector2(316, 70), 32, Color("ecceba"))
			draw_rect(Rect2(283, 37, 66, 17), Color("7ba99b"))
			draw_rect(Rect2(288, 69, 56, 22), pale)
			draw_colored_polygon(PackedVector2Array([Vector2(276,108),Vector2(355,108),Vector2(384,169),Vector2(345,183),Vector2(294,183),Vector2(249,165)]), Color("739f98"))
		return
	if scene_id == "operating_room":
		draw_line(Vector2(216, 0), Vector2(216, 54), pale, 5)
		draw_ellipse_placeholder(Vector2(216, 65), Vector2(80, 22), Color("e1e8d8"))
		draw_rect(Rect2(335, 85, 102, 80), Color("18363b"))
		draw_polyline(PackedVector2Array([Vector2(345,130),Vector2(361,130),Vector2(368,114),Vector2(376,145),Vector2(384,125),Vector2(426,125)]), Color("a6d6b0"), 2)
		draw_rect(Rect2(112, 145, 208, 190), Color("7b979c"))
		draw_rect(Rect2(188, 335, 56, 32), dark)
		patient(Vector2(216, 145), true)
	else:
		draw_rect(Rect2(28, 263, 394, 69), Color("90a3a2"))
		draw_rect(Rect2(45, 217, 360, 67), Color("dfe5dc"))
		draw_rect(Rect2(55, 190, 101, 35), Color("f0eee3"))
		draw_line(Vector2(33, 198), Vector2(33, 352), dark, 7)
		draw_line(Vector2(416, 198), Vector2(416, 352), dark, 7)
		patient(Vector2(216, 162), false)

func patient(head: Vector2, on_table: bool) -> void:
	draw_circle(head, 35, Color("e9cab4"))
	draw_arc(head + Vector2(0, -4), 34, PI, TAU, 30, Color("695d58"), 12)
	if on_table:
		draw_arc(head + Vector2(0, -5), 39, PI, TAU, 30, Color("a3c5bf"), 10)
	var color := Color("75aaa5") if on_table else Color("b1c6d1")
	draw_colored_polygon(PackedVector2Array([head+Vector2(-40,35),head+Vector2(40,35),head+Vector2(89,158),head+Vector2(-89,158)]), color)
	for x in [-12, 12]:
		draw_circle(head + Vector2(x, -2), 2.5, Color("5d5550"))
	var mouth := head + Vector2(0, 18)
	if anxiety >= 2:
		draw_line(mouth + Vector2(-8, 2), mouth + Vector2(0, -2), Color("8a6458"), 2)
		draw_line(mouth + Vector2(0, -2), mouth + Vector2(8, 2), Color("8a6458"), 2)
	else:
		draw_arc(mouth, 8, 0, PI, 15, Color("8a6458"), 2)

func box(color: Color) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = color
	result.set_corner_radius_all(4)
	return result

func draw_ellipse_placeholder(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(40):
		var angle := TAU * i / 40
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
