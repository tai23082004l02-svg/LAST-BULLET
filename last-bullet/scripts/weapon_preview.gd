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
	var muzzle := center+Vector2(98,0)
	var phase := fmod(clock,1.2)
	if phase < 0.12: Combat.ProjectileArt.flash(self,"muzzle",weapon,muzzle,Vector2.RIGHT,phase/0.12)
	for i in range(3):
		var travel := fmod(clock*130+i*46,150)
		Combat.draw_round(self,weapon,muzzle+Vector2(14+travel,sin(clock*2+i)*4),Vector2.RIGHT,0,clock+i)
	if phase > 0.85: Combat.ProjectileArt.flash(self,"impact",weapon,muzzle+Vector2(174,0),Vector2.RIGHT,(phase-0.85)/0.35)
