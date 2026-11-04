@tool
extends StaticBody2D
@export_enum("Tree", "Rock", "Log", "Sign") var kind: int = 0:
	set(value):
		kind = value
		queue_redraw()
@export var variant: int = 0

func _draw() -> void:
	var ink := Color("142b29")
	match kind:
		0:
			draw_set_transform(Vector2(6, 1), 0, Vector2(1, 0.3))
			draw_circle(Vector2.ZERO, 42, Color(0.02, 0.07, 0.05, 0.32))
			draw_set_transform(Vector2.ZERO)
			draw_rect(Rect2(-9, -45, 18, 48), Color("604f3d"))
			draw_rect(Rect2(-5, -40, 5, 40), Color("8b7250"))
			for i in 3:
				var y := -22.0 - i * 26
				var w := 43.0 - i * 8
				var shade := Color("285b48").lightened(i * 0.055 + variant * 0.018)
				draw_colored_polygon(PackedVector2Array([Vector2(-w-3, y+5), Vector2(0, y-67), Vector2(w+3, y+5)]), ink)
				draw_colored_polygon(PackedVector2Array([Vector2(-w, y), Vector2(0, y-61), Vector2(w, y)]), shade)
				draw_polyline(PackedVector2Array([Vector2(-w+7, y-5), Vector2(-3, y-52), Vector2(-13,y-11)]), shade.lightened(0.11), 3)
		1:
			draw_ellipse_shadow(37)
			draw_colored_polygon(PackedVector2Array([Vector2(-34, 0), Vector2(-31,-30), Vector2(-10,-48), Vector2(19,-43), Vector2(36,-17), Vector2(30,4)]), ink)
			draw_colored_polygon(PackedVector2Array([Vector2(-29,-3), Vector2(-25,-29), Vector2(-8,-42), Vector2(16,-38), Vector2(30,-16), Vector2(25,0)]), Color("77877a"))
			draw_colored_polygon(PackedVector2Array([Vector2(-25,-29),Vector2(-8,-42),Vector2(16,-38),Vector2(8,-21),Vector2(-15,-18)]), Color("9ca68b"))
			draw_line(Vector2(8,-21),Vector2(20,-8), Color("4d655d"), 3)
		2:
			draw_ellipse_shadow(45)
			draw_style_box(log_style(), Rect2(-46,-28,92,28))
			draw_circle(Vector2(-35,-14),14,Color("c3a16e"))
			draw_arc(Vector2(-35,-14),8,0,TAU,16,Color("8a6a4c"),2)
			draw_line(Vector2(-14,-23), Vector2(37,-23),Color("a17c50"),3)
		3:
			draw_rect(Rect2(-4,-30,8,34),Color("8e704a"))
			draw_rect(Rect2(-28,-58,56,34),ink)
			draw_rect(Rect2(-25,-55,50,28),Color("c1a671"))
			draw_line(Vector2(-12,-41),Vector2(13,-41),ink,3)
			draw_line(Vector2(13,-41),Vector2(6,-47),ink,3)
			draw_line(Vector2(13,-41),Vector2(6,-35),ink,3)

func draw_ellipse_shadow(radius: float) -> void:
	draw_set_transform(Vector2(3,3),0,Vector2(1,0.3))
	draw_circle(Vector2.ZERO,radius,Color(0.02,0.07,0.05,0.3))
	draw_set_transform(Vector2.ZERO)

func log_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color("705239")
	s.corner_radius_top_left=12
	s.corner_radius_bottom_left=12
	s.corner_radius_top_right=8
	s.corner_radius_bottom_right=8
	return s
