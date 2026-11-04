@tool
extends Node2D
const ROUTE := [Vector2(320,1180), Vector2(576,1180), Vector2(576,960), Vector2(1216,960), Vector2(1216,640), Vector2(1920,640), Vector2(1920,384)]

func _draw() -> void:
	draw_rect(Rect2(0,0,2304,1536),Color("183b30"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 251
	for y in 48:
		for x in 72:
			var c := Color("315744").lightened(rng.randf_range(-0.045,0.035))
			draw_rect(Rect2(x*32,y*32,32,32),c)
	# Soft-edged walking trail, kept below every actor and obstacle.
	for i in range(ROUTE.size()-1):
		draw_line(ROUTE[i],ROUTE[i+1],Color("5c6747"),100)
		draw_circle(ROUTE[i],50,Color("5c6747"))
		draw_circle(ROUTE[i+1],50,Color("5c6747"))
	for i in range(ROUTE.size()-1):
		draw_line(ROUTE[i],ROUTE[i+1],Color("8b865a"),80)
		draw_circle(ROUTE[i],40,Color("8b865a"))
		draw_circle(ROUTE[i+1],40,Color("8b865a"))
	for i in 4500:
		var p := Vector2(rng.randf_range(65,2240),rng.randf_range(65,1470))
		var on_trail := false
		for j in range(ROUTE.size()-1):
			if Geometry2D.get_closest_point_to_segment(p,ROUTE[j],ROUTE[j+1]).distance_to(p)<38:
				on_trail=true
		if on_trail:
			draw_rect(Rect2(p,Vector2(3,2)),Color("a39a6a"))
		else:
			draw_polyline(PackedVector2Array([p+Vector2(-2,0),p+Vector2(-3,-4),p+Vector2(0,-1),p+Vector2(2,-5)]),Color("4d7050"),1)
	for p in [Vector2(320,1180),Vector2(1216,900),Vector2(1920,384)]:
		draw_circle(p,69,Color("546b4d"))
		draw_arc(p,65,0,TAU,64,Color("b2b181"),2)
		draw_arc(p,58,0,TAU,64,Color("77845c"),1)
	for i in 130:
		var p := Vector2(rng.randf_range(150,2100),rng.randf_range(250,1350))
		var c := Color("d9bf75") if i%2==0 else Color("a7bd89")
		draw_rect(Rect2(p,Vector2(3,3)),c)
		draw_rect(Rect2(p+Vector2(3,3),Vector2(3,3)),c)
