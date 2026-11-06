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
	preload("res://scripts/item_art.gd").draw(self,"weapon",weapon,center,230)
	for i in range(3):
		var travel := fmod(clock*100+i*38,130)
		Combat.draw_round(self,weapon,center+Vector2(115+travel,sin(clock*2+i)*8),Vector2.RIGHT,0,clock+i)
