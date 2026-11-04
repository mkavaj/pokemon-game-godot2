extends Control
var font: Font = ThemeDB.fallback_font
@onready var level: Node2D = get_parent().get_parent()

func text_at(p: Vector2, value: String, size: int, color: Color = Color("e8ead9")) -> void:
	draw_string(font,p,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func panel(rect: Rect2, color: Color = Color("142723")) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color=color
	box.border_color=Color("3b5344")
	box.set_border_width_all(1)
	box.set_corner_radius_all(10)
	draw_style_box(box,rect)

func _draw() -> void:
	var p: Vector2 = level.player.position
	var current := 0 if p.x < 900 else 1 if p.x < 1630 else 2
	var titles := ["ПОЧЕТНА ЧИСТИНА", "ШУМСКИ ПРЕМИН", "СТАРО СВЕТИЛИШТЕ"]
	var count: int = level.visited.count(true)
	panel(Rect2(22,20,1108,86))
	text_at(Vector2(44,45),"POKÉMON  /  SHADOWBOUND",12,Color("94b9a0"))
	text_at(Vector2(43,78),"Шумската патека",26)
	draw_line(Vector2(340,38),Vector2(340,88),Color("3b5344"))
	text_at(Vector2(365,48),"0%d  /  %s" % [current+1,titles[current]],14,Color("d7c38a"))
	text_at(Vector2(365,78),"Истражи ги трите зони и пронајди ги ознаките." if count<3 else "Патеката е истражена. Сите три ознаки се пронајдени!",15)
	text_at(Vector2(1016,47),"ОЗНАКИ",11,Color("94b9a0"))
	text_at(Vector2(1024,79),"%d / 3" % count,23,Color("d7c38a"))
	panel(Rect2(22,690,1108,58))
	text_at(Vector2(43,725),"WASD / ↑↓←→   Движење",15)
	text_at(Vector2(300,725),"SHIFT   Трчање",15,Color("a3b8a7"))
	text_at(Vector2(490,725),"TAB   Мапа",15,Color("a3b8a7"))
	text_at(Vector2(651,725),"R   Од почеток",15,Color("a3b8a7"))
	text_at(Vector2(846,725),"M   Звук %s" % ("−" if level.muted else "+"),15,Color("a3b8a7"))
	text_at(Vector2(1002,725),"ESC   Пауза",15,Color("a3b8a7"))
	# Compact map of the same traversable rooms and connecting paths.
	var large := Input.is_action_pressed("map")
	var origin := Vector2(882,128) if not large else Vector2(300,180)
	var s := 0.095 if not large else 0.24
	panel(Rect2(origin-Vector2(12,12),Vector2(2304,1536)*s+Vector2(24,48)))
	for r in [Rect2(128,768,640,640),Rect2(768,896,192,128),Rect2(960,512,576,704),Rect2(1536,576,128,128),Rect2(1664,192,512,640)]:
		draw_rect(Rect2(origin+r.position*s,r.size*s),Color("496c53"))
	for i in 3:
		draw_circle(origin+level.MARKERS[i]*s,4,Color("91c99b") if level.visited[i] else Color("d8be79"))
	draw_circle(origin+p*s,4,Color("fff3bb"))
	draw_arc(origin+p*s,7,0,TAU,20,Color("fff3bb"),1)
	text_at(origin+Vector2(0,1536*s+24),"ШУМА  /  TAB за поголема мапа",10,Color("a3b8a7"))
	panel(Rect2(22,128,206,56),Color("1c3229"))
	text_at(Vector2(38,151),"PIKACHU",13,Color("e5c775"))
	text_at(Vector2(38,171),"Главен карактер · Ниво 01",11,Color("a3b8a7"))
	if level.paused:
		draw_rect(Rect2(0,0,1152,768),Color(0.02,0.06,0.05,0.75))
		panel(Rect2(356,283,440,180))
		text_at(Vector2(509,338),"ПАУЗА",30)
		text_at(Vector2(400,383),"ESC за продолжување на истражувањето",17)
		text_at(Vector2(432,424),"R — почни повторно од чистината",15,Color("a3b8a7"))
