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
var travel := 0.0
var last_check := Vector2.ZERO
var check_time := 0.0
var trail: Array[Vector2] = []

# Continuous swept circle tests against enemies and exact arena planes.
# Only the owner creates this entity; captures and recovery reuse it.
func advance(delta: float, game: Node2D) -> void:
	boost = maxf(0, boost - delta)
	idle += delta
	for key in hit_cooldowns.keys():
		hit_cooldowns[key] -= delta
		if hit_cooldowns[key] <= 0:
			hit_cooldowns.erase(key)
	if capture > 0:
		capture -= delta
		if is_instance_valid(game.boss):
			position = game.boss.position
		if capture <= 0:
			velocity = (game.player - position).normalized() * game.bullet_speed()
			position += velocity.normalized() * 65
			trail.clear()
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
			if target.kind == 3 and target.capture_ready <= 0:
				capture = 1.1
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
		velocity = velocity.bounce(normal)
		position += normal * 1.5
	position = position.clamp(Balance.ARENA.position + Vector2(8,8), Balance.ARENA.end - Vector2(8,8))
	check_time += delta
	travel += velocity.length() * delta
	if check_time > 0.6:
		if position.distance_to(last_check) < 3 and travel > 100:
			position = Balance.ARENA.get_center()
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
	for i in range(1, trail.size()):
		var tint := color
		tint.a = 0.65*(1.0-float(i)/14)
		var point := trail[i]-position
		if skin == 2:
			point += Vector2(0,4 if i%2 == 0 else -4)
		draw_line(trail[i-1]-position,point,tint,6 if skin == 1 else 3)
		if skin == 3 and i%3 == 0:
			draw_circle(point,2,tint)
	draw_circle(Vector2.ZERO,16,Color(color,0.15))
	if boost > 0 and perfect_boost:
		draw_arc(Vector2.ZERO,12,0,TAU,20,Color.WHITE,2)
	if skin == 3:
		var star := PackedVector2Array()
		for i in range(10):
			star.append(Vector2.from_angle(-PI/2+i*PI/5)*(10 if i%2 == 0 else 4))
		draw_colored_polygon(star,color)
	elif skin == 2:
		draw_colored_polygon(PackedVector2Array([Vector2(0,-10),Vector2(8,0),Vector2(0,10),Vector2(-8,0)]),color)
	else:
		draw_circle(Vector2.ZERO,7,color)
	draw_circle(Vector2.ZERO,3,Color.WHITE)

static func draw_skin_preview(canvas: Control, index: int) -> void:
	var color: Color = Balance.SKIN_COLORS[index]
	for i in range(12):
		var point := Vector2(190+i*10,15)
		if index == 2: point.y += 4 if i%2 == 0 else -4
		canvas.draw_circle(point,2+i*0.3,Color(color,float(i+1)/12))
	canvas.draw_circle(Vector2(320,15),8,color)
	if index == 3:
		canvas.draw_line(Vector2(320,2),Vector2(320,28),color,2)
		canvas.draw_line(Vector2(307,15),Vector2(333,15),color,2)
