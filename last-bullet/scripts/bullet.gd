class_name PermanentBullet
extends Node2D

var velocity := Vector2(0.7, -0.7).normalized() * Balance.BULLET_SPEED
var hit_cooldowns: Dictionary = {}
var idle := 0.0
var boost := 0.0
var capture := 0.0
var perfect_boost := false
var pierce_left := 0
var bank_charge := 0
var skin := 0
var return_strike := false
var return_window := 0.0
var effects_reduced := false
var visual_clock := 0.0
var travel := 0.0
var last_check := Vector2.ZERO
var check_time := 0.0
var trail: Array[Vector2] = []

# Continuous swept circle tests against enemies and exact arena planes.
# Only the owner creates this entity; captures and recovery reuse it.
func advance(delta: float, game: Node2D) -> void:
	visual_clock += delta
	boost = maxf(0, boost - delta)
	return_window = maxf(0,return_window-delta)
	if return_window <= 0: return_strike = false
	idle += delta
	for key in hit_cooldowns.keys():
		hit_cooldowns[key] -= delta
		if hit_cooldowns[key] <= 0:
			hit_cooldowns.erase(key)
	if capture > 0:
		trail.clear()
		queue_redraw()
		capture -= delta
		if is_instance_valid(game.boss):
			position = game.boss.position
		if capture <= 0:
			velocity = (game.player - position).normalized() * game.bullet_speed()
			position += velocity.normalized() * 65
			trail.clear()
			return_window = 3.0
			if is_instance_valid(game.boss):
				game.boss.weak_timer = 3.0
			game.notice("BOSS EXPOSED • DEFLECT BACK!")
			game.audio.play_event("boss_warning")
		return
	var speed: float = game.bullet_speed() * ((1.3 if perfect_boost else 1.15) if boost > 0 else 1.0)
	if idle > 5 and not game.enemies.is_empty():
		var target: Node2D = game.nearest_enemy(position)
		if target != null:
			var angle := velocity.angle_to(target.position - position)
			velocity = velocity.rotated(clampf(angle, -delta * (0.45 + game.upgrades[2] * 0.25), delta * (0.45 + game.upgrades[2] * 0.25)))
	velocity = velocity.normalized() * speed
	var remaining := delta
	for bounce_index in range(10):
		if remaining <= 0.00001:
			break
		var motion := velocity * remaining
		var fraction := 1.0
		var normal := Vector2.ZERO
		var target: Node2D = null
		var bounds := Balance.ARENA.grow(-7)
		for axis in range(2):
			if absf(motion[axis]) < 0.0001:
				continue
			var edge: float = bounds.end[axis] if motion[axis] > 0 else bounds.position[axis]
			var t: float = (edge - position[axis]) / motion[axis]
			if t >= 0 and t <= fraction:
				fraction = t
				normal = Vector2.ZERO
				normal[axis] = -signf(motion[axis])
		if game.arena_layout == "reflector":
			var obstacle: Dictionary = ArenaGeometry.sweep_rect(position,motion,ArenaGeometry.PILLAR.grow(7))
			if not obstacle.is_empty() and obstacle.fraction <= fraction:
				fraction = obstacle.fraction
				normal = obstacle.normal
		for enemy in game.enemies:
			if not is_instance_valid(enemy) or hit_cooldowns.has(enemy.get_instance_id()):
				continue
			var offset: Vector2 = position - enemy.position
			var radius: float = enemy.radius + 7
			var a := motion.length_squared()
			var b := 2 * offset.dot(motion)
			var c := offset.length_squared() - radius * radius
			var discriminant := b * b - 4 * a * c
			if a <= 0 or discriminant < 0:
				continue
			var entry := (-b - sqrt(discriminant)) / (2 * a)
			if c > 0 and entry < 0:
				continue # The entire intersection is behind the bullet.
			if c <= 0 and offset.dot(motion) >= 0:
				continue # Already overlapping, separating: do not bounce back in.
			var t := maxf(0,entry)
			if t <= fraction:
				fraction = t
				target = enemy
				normal = (position + motion * t - enemy.position).normalized()
				if normal == Vector2.ZERO:
					normal = -velocity.normalized()
		position += motion * fraction
		if normal == Vector2.ZERO:
			break
		remaining *= 1 - fraction
		if target != null:
			hit_cooldowns[target.get_instance_id()] = Balance.HIT_COOLDOWN
			idle = 0
			if target.kind == 3 and target.capture_ready <= 0 and target.weak_timer <= 0:
				capture = 1.1
				trail.clear()
				queue_redraw()
				target.capture_ready = 9
				game.notice("BULLET EATER • RELEASE INCOMING")
				game.audio.play_event("boss_warning")
				return
			var blocked: bool = target.kind == 4 and target.blocks(velocity)
			game.damage_enemy(target, 1 + game.upgrades[0] + ((2 if perfect_boost else 1) if boost > 0 else 0) + bank_charge, true, velocity)
			bank_charge = 0
			if pierce_left > 0 and not blocked:
				pierce_left -= 1
				position += velocity.normalized()*1.5
				continue
		else:
			bank_charge = mini(game.upgrades[6],bank_charge+1)
			game.audio.play_event("bounce",1.0+bank_charge*0.08)
			game.effects.burst(position,Balance.SKIN_COLORS[skin],"hit",normal)
		velocity = velocity.bounce(normal)
		position += normal * 1.5
	if game.arena_layout == "reflector":
		position = ArenaGeometry.resolve(position,7)
	position = position.clamp(Balance.ARENA.position + Vector2(8,8), Balance.ARENA.end - Vector2(8,8))
	check_time += delta
	travel += velocity.length() * delta
	if check_time > 0.6:
		if position.distance_to(last_check) < 3 and travel > 100:
			position = Vector2(360,650)
			trail.clear()
			velocity = Vector2(0.63, -0.77) * speed
		last_check = position
		check_time = 0
		travel = 0
	trail.push_front(position)
	if trail.size() > 14:
		trail.pop_back()
	queue_redraw()

func _draw() -> void:
	var color: Color = Balance.SKIN_COLORS[skin]
	var count := mini(trail.size(),7 if effects_reduced else 14)
	for i in range(1,count):
		var alpha := 1.0-float(i)/maxi(count,1)
		var end := trail[i]-position
		var start := trail[i-1]-position
		if start.distance_squared_to(end) < 0.01: continue
		var sideways := (start-end).normalized().orthogonal()
		var width := (6 if skin == 1 else 4)*alpha
		if skin == 2:
			end += sideways*sin(i*2.7+visual_clock*12)*3
		var tint := Color(color,alpha*0.65)
		draw_colored_polygon(PackedVector2Array([start+sideways*(width+1),start-sideways*(width+1),end-sideways*width,end+sideways*width]),tint)
		if not effects_reduced:
			draw_line(start,end,Color(color,alpha*0.12),width*3+1)
		if skin == 3 and i%4 == 0:
			draw_line(end-Vector2(0,2),end+Vector2(0,2),Color(color,alpha),1)
	draw_core(self,Vector2.ZERO,skin,visual_clock,boost>0 and perfect_boost)

static func draw_core(canvas: CanvasItem, point: Vector2, index: int, clock: float, powered := false) -> void:
	var color: Color = Balance.SKIN_COLORS[index]
	canvas.draw_circle(point,13,Color(0.01,0.04,0.07,0.8))
	NeonArt.glow(canvas,point,7,color)
	if index == 3:
		var star := PackedVector2Array()
		for i in range(10):
			star.append(point+Vector2.from_angle(-PI/2+i*PI/5+clock*0.5)*(10 if i%2 == 0 else 4))
		canvas.draw_colored_polygon(star,color)
	elif index == 2:
		canvas.draw_colored_polygon(PackedVector2Array([point+Vector2(0,-10),point+Vector2(8,0),point+Vector2(0,10),point+Vector2(-8,0)]),color)
	else:
		canvas.draw_circle(point,8,color)
	canvas.draw_circle(point,5,Color("f4ffff"))
	canvas.draw_circle(point-Vector2(1,1),2,Color.WHITE)
	if powered:
		canvas.draw_arc(point,14,clock*2,clock*2+PI*1.4,24,Color("fff0ad"),2)

static func draw_skin_preview(canvas: Control, index: int, clock := 0.0) -> void:
	var color: Color = Balance.SKIN_COLORS[index]
	var center := Vector2(canvas.size.x*0.5+40,12)
	for i in range(20):
		var point := center-Vector2(i*5,sin(float(i)*0.3+clock*2)*4)
		if index == 2: point.y += sin(i*2.0+clock*8)*3
		canvas.draw_circle(point,maxf(1,5.0-float(i)*0.23),Color(color,(1-float(i)/20)*0.7))
	draw_core(canvas,center,index,clock)
