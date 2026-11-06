extends Node2D
const Items = preload("res://scripts/item_art.gd")
var clock := 0.0
var robot := 0
var lean := 0.0
var target_lean := 0.0
var moving := 0.0
var flash := 0.0
var weapon := 0
var aim := Vector2.UP
var active := true
var recoil := 0.0
var finish := 0
var trail: Array[Dictionary] = []
var trail_clock := 0.0
var reduced := false
func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
func _process(delta: float) -> void:
	if active:
		clock += delta*(2.0+moving*6)
		lean = lerpf(lean,target_lean,1-exp(-delta*14))
		recoil = move_toward(recoil,0,delta*34)
		trail_clock -= delta
		for i in range(trail.size()-1,-1,-1):
			trail[i].age += delta
			if trail[i].age >= 0.5: trail.remove_at(i)
		if finish > 0 and moving > 0.1 and not reduced and trail_clock <= 0:
			trail_clock = 0.09
			if trail.size() >= 12: trail.pop_front()
			trail.append({"p":position,"age":0.0})
	if reduced or finish == 0: trail.clear()
	queue_redraw()
func kick(style: int) -> void:
	recoil = 5.0 if style in [5,7,10] else 3.0 if style in [0,4,6,8] else 1.8
func weapon_width() -> float:
	return 72.0 if weapon in [2,5,7,10] else 56.0 if weapon == 9 else 66.0
func carry_transform() -> Transform2D:
	var direction := aim.normalized() if aim != Vector2.ZERO else Vector2.UP
	return Transform2D(direction.angle(),Vector2(1,-1 if direction.x < -0.05 else 1),0,Vector2.ZERO)
func muzzle_offset() -> Vector2:
	return carry_transform()*Vector2(23-recoil+weapon_width()*0.43,6+sin(clock)*moving*0.8)
func draw_weapon() -> void:
	var pose := carry_transform()
	draw_set_transform_matrix(pose)
	var center := Vector2(23-recoil,6+sin(clock)*moving*0.8)
	# A short arm behind the grip and gloves over the grip attach the gun to the robot.
	draw_line(Vector2(1,7),center+Vector2(-10,7),Color("152c3d"),9,true)
	Items.draw(self,"weapon",weapon,center,weapon_width())
	for grip in [center+Vector2(-12,8),center+Vector2(3,8)]:
		draw_circle(grip,4,Color("122939"))
		draw_arc(grip,3,0.2,PI,8,Color("98c6c8"),1.5,true)
	draw_set_transform(Vector2.ZERO)
func _draw() -> void:
	var tint: Color = preload("res://scripts/shop.gd").THEME_COLORS[clampi(finish,0,3)]
	self_modulate = Color.WHITE if finish == 0 else Color.WHITE.lerp(tint,0.22)
	if finish > 0:
		for mark in trail:
			draw_arc(mark.p-position+Vector2(0,18),9,0,TAU,12,Color(tint,(1-float(mark.age)/0.5)*0.28),2,true)
		if not reduced: draw_arc(Vector2(0,20),25,0,TAU,32,Color(tint,0.45),2,true)
	# Shooting upward places the weapon behind the body; other directions hold it in front.
	var behind := aim.y < -0.35
	if behind: draw_weapon()
	NeonArt.hero(self,robot,Vector2(0,sin(clock)*moving*1.3),58,clock*0.2,lean,flash)
	if not behind: draw_weapon()
