extends Control
const Combat = preload("res://scripts/combat.gd")
var weapon := 0
var clock := 0.0
func _ready() -> void: mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
	clock += delta
	queue_redraw()
func _draw() -> void:
	var center := size*Vector2(0.38,0.5)
	var color: Color = Combat.COLORS[weapon]
	draw_arc(center,65,0,TAU,48,Color(color,0.15),2)
	if weapon == 8:
		draw_arc(center,40,-PI/2,PI/2,24,color,5)
		draw_line(center+Vector2(0,-40),center+Vector2(-12,0),Color.WHITE,2)
		draw_line(center+Vector2(0,40),center+Vector2(-12,0),Color.WHITE,2)
	elif weapon == 9:
		draw_polyline(PackedVector2Array([center+Vector2(-35,-30),center+Vector2(15,0),center+Vector2(-35,30)]),color,12,true)
	else:
		draw_rect(Rect2(center-Vector2(40,18),Vector2(75,36)),Color("173341"))
		draw_rect(Rect2(center-Vector2(40,18),Vector2(75,36)),color,false,3)
		draw_rect(Rect2(center+Vector2(25,-9),Vector2(40,18)),color)
		draw_rect(Rect2(center+Vector2(-25,14),Vector2(16,25)),Color("2b5b6b"))
		if weapon == 5:
			draw_line(center+Vector2(30,-16),center+Vector2(64,-16),color,5)
			draw_line(center+Vector2(30,16),center+Vector2(64,16),color,5)
	for i in range(3):
		var travel := fmod(clock*100+i*38,130)
		Combat.draw_round(self,weapon,center+Vector2(80+travel,sin(clock*2+i)*8),Vector2.RIGHT,0,clock+i)
