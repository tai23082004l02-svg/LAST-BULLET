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
func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
func _process(delta: float) -> void:
	if active:
		clock += delta*(2.0+moving*6)
		lean = lerpf(lean,target_lean,1-exp(-delta*14))
		recoil = move_toward(recoil,0,delta*34)
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
	# Shooting upward places the weapon behind the body; other directions hold it in front.
	var behind := aim.y < -0.35
	if behind: draw_weapon()
	NeonArt.hero(self,robot,Vector2(0,sin(clock)*moving*1.3),58,clock*0.2,lean,flash)
	if not behind: draw_weapon()
