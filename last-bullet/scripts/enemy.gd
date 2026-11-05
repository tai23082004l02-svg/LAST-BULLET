class_name ArenaEnemy
extends Node2D

var kind := 0
var hp := 1.0
var max_hp := 1.0
var radius := 19.0
var speed := 85.0
var phase := 0.0
var appearance := 0.0
var visual_lean := 0.0
var dash := Vector2.ZERO
var fire_clock := 1.8
var chilled := 0.0
var poisoned := 0.0
var poison_power := 0.0
var poison_tick := 0.0
var thermal_lock := 0.0
var burning := 0.0
var burn_power := 0.0
var burn_tick := 0.0
var flash := 0.0
var weak_timer := 0.0
var boss_style := -1
var facing := Vector2.DOWN
var hazard_point := Vector2.ZERO
var hazard_clock := 0.0
var hazard_cycle := 0.0

func setup(type: int, wave: int) -> void:
	kind = type
	radius = [19.0, 21.0, 28.0, 53.0, 25.0, 23.0][kind]
	hp = [1.0, 2.0, 5.0, 180.0, 3.0, 3.0][kind] + floorf(float(wave - 1) / 3)
	max_hp = hp
	speed = [85.0, 100.0, 48.0, 40.0, 65.0, 0.0][kind] + minf(wave * 3, 50)
	phase = randf_range(0, 2)
	if kind == 5: speed = 0

func advance(delta: float, player: Vector2) -> void:
	phase += delta
	appearance = minf(1,appearance+delta*5)
	weak_timer = maxf(0,weak_timer-delta)
	flash = maxf(0, flash - delta)
	var direction := (player - position).normalized()
	visual_lean = lerpf(visual_lean,direction.x*0.1,1-exp(-delta*10))
	if kind == 3 and boss_style >= 0:
		advance_campaign_boss(delta,player,direction)
	elif kind == 4:
		facing = facing.rotated(clampf(facing.angle_to(direction),-delta*0.7,delta*0.7))
		position += direction*speed*delta
	elif kind == 5:
		hazard_clock = maxf(0,hazard_clock-delta)
		hazard_cycle -= delta
		if hazard_cycle <= 0:
			hazard_cycle = 3.5
			hazard_clock = 1.65
			hazard_point = player
	elif kind == 1:
		var cycle := fmod(phase, 3.2)
		if cycle < 1.9:
			position += direction * speed * delta
		elif cycle < 2.5:
			dash = direction
		else:
			position += dash * 470 * delta
	else:
		if weak_timer <= 0:
			position += direction * speed * delta
	position = position.clamp(Balance.ARENA.position + Vector2.ONE * radius, Balance.ARENA.end - Vector2.ONE * radius)
	queue_redraw()

func _draw() -> void:
	if kind in [2,3,5] and fire_clock < 0.5:
		draw_arc(Vector2.ZERO,radius+8,0,TAU*(1-clampf(fire_clock/0.5,0,1)),28,Color("ff8562"),3)
	if chilled > 0:
		draw_arc(Vector2.ZERO,radius+4,0,TAU,24,Color("9feaff"),2)
	if poisoned > 0:
		draw_arc(Vector2.ZERO,radius+7,0,TAU,20,Color("b8ed68"),2)
	if burning > 0:
		draw_circle(Vector2(0,radius*0.7),radius*0.6,Color(1,0.4,0.1,0.3))
	if (kind == 5 or boss_style in [2,3,4]) and hazard_clock > 0:
		var point := hazard_point-position
		var active := hazard_active()
		var amber := Color("ffc57d")
		draw_circle(point,66,Color(1,0.5,0.12,0.24 if active else 0.06))
		draw_arc(point,66,0,TAU,48,Color(amber,0.9),4 if active else 2)
		for i in range(8):
			var angle := i*TAU/8+phase*0.3
			var ray := Vector2.from_angle(angle)
			draw_line(point+ray*56,point+ray*66,Color(amber,0.6),2)
		if not active:
			draw_arc(point,66*(1.65-hazard_clock)/1.1,0,TAU,40,amber,2)
		else:
			draw_arc(point,45+sin(phase*20)*5,0,TAU,32,Color(1,0.85,0.55,0.6),3)
	if (kind == 1 and fmod(phase,3.2) >= 1.9 and fmod(phase,3.2) < 2.5) or (kind == 3 and boss_style in [0,4] and fmod(phase,5.0) >= 2.0 and fmod(phase,5.0) < 3.0):
		var along := dash*145
		draw_line(Vector2.ZERO,along,Color(1,0.5,0.2,0.2),14)
		draw_line(Vector2.ZERO,along,Color(1,0.65,0.3,0.7),2)
	var index: int = [1,2,3,6,4,5][kind]
	var width := radius*(2.65 if kind != 3 else 2.7)
	var spawn_scale := 0.7+0.3*sin(appearance*PI/2)
	if kind == 3 and boss_style >= 0:
		CampaignArt.boss(self,boss_style,width,phase,visual_lean,flash,spawn_scale)
	else:
		NeonArt.robot(self,index,Vector2.ZERO,width,phase,visual_lean,flash,spawn_scale)
	if kind == 4 or (kind == 3 and boss_style == 1 and fmod(phase,6.0) < 3.0):
		var shield := PackedVector2Array([facing*radius*0.7])
		for i in range(21):
			var angle := facing.angle()-acos(0.35)+i*acos(0.35)/10
			shield.append(Vector2.from_angle(angle)*(radius+9))
		draw_colored_polygon(shield,Color(1,0.7,0.25,0.14))
		draw_arc(Vector2.ZERO,radius+9,facing.angle()-acos(0.35),facing.angle()+acos(0.35),24,Color("ffe6a4"),4)
		draw_arc(Vector2.ZERO,radius+5,facing.angle()-acos(0.35),facing.angle()+acos(0.35),24,Color(1,0.72,0.2,0.5),2)
	if kind == 3:
		var core := Vector2(0,3)
		var color: Color = Color("ffd187") if weak_timer > 0 else CampaignData.data(boss_style).color if boss_style >= 0 else Color("59d9ef")
		NeonArt.glow(self,core,10+sin(phase*5)*2,color)
		draw_circle(core,6,Color("fff4d4") if weak_timer > 0 else Color("152a38"))
		if weak_timer > 0:
			draw_arc(Vector2.ZERO,radius+16,0,TAU*weak_timer/3.0,48,Color("ffe4a3"),4)

	if hp < max_hp:
		var y := -radius-14
		draw_line(Vector2(-radius,y),Vector2(radius,y),Color("071221"),6)
		draw_line(Vector2(-radius,y),Vector2(-radius+radius*2*hp/max_hp,y),Color("ffbf87"),3)

func blocks(incoming: Vector2) -> bool:
	return (kind == 4 or (kind == 3 and boss_style == 1 and fmod(phase,6.0) < 3)) and incoming != Vector2.ZERO and (-incoming.normalized()).dot(facing) > 0.35

func hazard_active() -> bool:
	return (kind == 5 or boss_style in [2,3,4]) and hazard_clock > 0 and hazard_clock <= 0.55

func advance_campaign_boss(delta: float, player: Vector2, direction: Vector2) -> void:
	facing = facing.rotated(clampf(facing.angle_to(direction),-delta*0.65,delta*0.65))
	hazard_clock = maxf(0,hazard_clock-delta)
	hazard_cycle -= delta
	if boss_style in [2,3,4] and hazard_cycle <= 0:
		hazard_cycle = 3.8 if boss_style != 4 else 4.5
		hazard_clock = 1.65
		hazard_point = player
	if weak_timer > 0: return
	if boss_style == 0 or (boss_style == 4 and hp < max_hp*0.5):
		var cycle := fmod(phase,5.0)
		if cycle < 2.0: position += direction*speed*delta
		elif cycle < 3.0: dash = direction
		elif cycle < 3.65: position += dash*330*delta
	else:
		position += direction*speed*0.65*delta

func status_text() -> String:
	if weak_timer > 0: return "EXPOSED"
	if boss_style == 1: return "SHIELD UP" if fmod(phase,6.0) < 3 else "SHIELD DOWN"
	if boss_style == 4 and hp < max_hp*0.5: return "PHASE 2 • OVERLOAD"
	if boss_style == 0 and fmod(phase,5.0) >= 2 and fmod(phase,5.0) < 3: return "CHARGE WARNING"
	return "HUNTING"
