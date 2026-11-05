extends Node2D
# A bounded projectile simulation. Shots expire; no permanent or reflected player bullet.
const MAX_SHOTS := 160
const MAX_HOSTILE := 180
const WEAPONS := ["SÚNG TRƯỜNG","SÚNG ĐIỆN","SÚNG BĂNG","PHUN LỬA","LASER","SHOTGUN","SÚNG TRINH SÁT"]
const SKILLS := ["KHIÊN NĂNG LƯỢNG","XUNG ĐIỆN","ĐÓNG BĂNG","BÙNG CHÁY","BÃO LASER","LOẠT TÊN LỬA","LƯỚT NHANH"]
const INTERVALS := [0.38,0.18,0.52,0.12,0.85,0.8,0.26]
const DAMAGES := [1.4,0.65,1.7,0.42,3.5,1.0,0.9]
const SPEEDS := [760.0,850.0,700.0,440.0,1400.0,720.0,980.0]
const RANGES := [620.0,560.0,620.0,230.0,720.0,440.0,720.0]
const SKILL_COOLDOWNS := [10.0,9.0,10.0,9.0,12.0,10.0,6.0]
var game: Node2D
var shots: Array[Dictionary] = []
var hostile: Array[Dictionary] = []
var flashes: Array[Dictionary] = []
var fire_clock := 0.0
var shield := 0.0
var shield_hits := 0
var shots_fired := 0
var hits := 0
var criticals := 0
var skill_uses := 0

func reset() -> void:
	shots.clear()
	hostile.clear()
	flashes.clear()
	fire_clock = 0
	shield = 0
	shield_hits = 0
	shots_fired = 0
	hits = 0
	criticals = 0
	skill_uses = 0
	visible = true
	queue_redraw()

func line_clear(from: Vector2, to: Vector2) -> bool:
	for box in game.world_obstacles():
		if box.grow(5).has_point(from) or not ArenaGeometry.sweep_rect(from,to-from,box.grow(5)).is_empty(): return false
	return true

func target_from(from: Vector2, reach: float, excluded: Array = []) -> ArenaEnemy:
	var chosen: ArenaEnemy
	var best := reach*reach
	for enemy in game.enemies:
		if not is_instance_valid(enemy) or excluded.has(enemy.get_instance_id()): continue
		var distance := from.distance_squared_to(enemy.position)
		if distance <= best and line_clear(from,enemy.position):
			chosen = enemy
			best = distance
	return chosen

func interval() -> float:
	return float(INTERVALS[game.selected_robot])/(1+game.upgrades[1]*0.16)

func damage() -> float:
	return float(DAMAGES[game.selected_robot])*(1+game.upgrades[0]*0.22)

func skill_cooldown() -> float:
	return float(SKILL_COOLDOWNS[game.selected_robot])*(1-game.upgrades[7]*0.1)

func emit_shot(origin: Vector2, direction: Vector2, power: float, pierce: int, chain: int, reach: float, speed: float, style: int) -> void:
	if shots.size() >= MAX_SHOTS or direction == Vector2.ZERO: return
	shots.append({"p":origin,"v":direction.normalized()*speed,"damage":power,"ttl":reach/speed,"pierce":pierce,"chain":chain,"hit":[],"style":style,"skin":game.selected_skin})
	shots_fired += 1

func fire() -> void:
	var robot: int = game.selected_robot
	var target := target_from(game.player,RANGES[robot])
	if target == null: return
	var direction: Vector2 = (target.position-game.player).normalized()
	game.aim = direction
	var count: int = (5 if robot == 5 else 1)+game.upgrades[2]
	for i in range(count):
		var angle: float = (i-(count-1)*0.5)*(0.11 if robot == 5 else 0.13)
		if robot == 3: angle += game.rng.randf_range(-0.12,0.12)
		emit_shot(game.player,direction.rotated(angle),damage(),game.upgrades[5]+(3 if robot == 4 else 0),game.upgrades[6]+(1 if robot == 1 else 0),RANGES[robot],SPEEDS[robot],robot)
	flashes.append({"p":game.player+direction*26,"ttl":0.08,"r":13.0,"color":RobotRoster.COLORS[robot]})
	game.audio.play_event("shoot",1.2 if robot == 1 else 0.9 if robot == 5 else 1.0)

func skill() -> void:
	if game.state != "playing" or game.cooldown > 0: return
	game.cooldown = 0.0 if game.admin_enabled and game.admin_free_skill else skill_cooldown()
	skill_uses += 1
	var robot: int = game.selected_robot
	var power := damage()
	if robot == 0:
		shield = 3.0
		shield_hits = 3
	elif robot == 6:
		var direction: Vector2 = game.joystick.normalized() if game.joystick.length() > 0.1 else game.aim
		# Sweep in short steps so a dash cannot pass through pillars.
		for i in range(12):
			var next: Vector2 = game.player+direction*15
			next = next.clamp(Balance.ARENA.position+Vector2.ONE*18,Balance.ARENA.end-Vector2.ONE*18)
			game.player = ArenaGeometry.resolve_all(next,18,game.world_obstacles())
		game.invulnerable = maxf(game.invulnerable,0.65)
		game.player_actor.position = game.player
		game.player_actor.reset_physics_interpolation()
	elif robot in [1,2,3]:
		var reach := 240.0 if robot == 1 else 280.0 if robot == 2 else 210.0
		for enemy in game.enemies.duplicate():
			if game.player.distance_to(enemy.position) <= reach:
				if robot == 2: enemy.chilled = 3.0
				game.damage_enemy(enemy,power*(4 if robot == 3 else 2),true,enemy.position-game.player)
				if game.state != "playing": break
	else:
		var target := target_from(game.player,900)
		var direction: Vector2 = (target.position-game.player).normalized() if target != null else game.aim
		for i in range(12 if robot == 4 else 7):
			var angle := i*TAU/12 if robot == 4 else (i-3)*0.13
			emit_shot(game.player,Vector2.UP.rotated(angle) if robot == 4 else direction.rotated(angle),power*3,5 if robot == 4 else 1,0,850,1100 if robot == 4 else 520,4 if robot == 4 else 7)
	flashes.append({"p":game.player,"ttl":0.45,"r":80.0 if robot in [0,6] else 220.0,"color":RobotRoster.COLORS[robot]})
	game.audio.play_event("skill")
	game.notice(SKILLS[robot])
	game.check_missions()

func circle_hit(origin: Vector2, motion: Vector2, center: Vector2, radius: float) -> float:
	var offset := origin-center
	var c := offset.length_squared()-radius*radius
	if c <= 0: return 0
	var a := motion.length_squared()
	if a < 0.000001: return INF
	var b := offset.dot(motion)
	var discriminant := b*b-a*c
	if discriminant < 0: return INF
	var t := (-b-sqrt(discriminant))/a
	return t if t >= 0 and t <= 1 else INF

func advance_shots(delta: float) -> void:
	for shot in shots.duplicate():
		if game.state != "playing": return
		if shot.style == 7:
			var locked := target_from(shot.p,800,shot.hit)
			if locked != null:
				shot.v = shot.v.rotated(clampf(shot.v.angle_to(locked.position-shot.p),-delta*3,delta*3))
		var step: float = minf(delta,shot.ttl)
		var start: Vector2 = shot.p
		var motion: Vector2 = shot.v*step
		var wall := 1.0
		for box in game.world_obstacles():
			var contact := ArenaGeometry.sweep_rect(start,motion,box.grow(5))
			if not contact.is_empty(): wall = minf(wall,contact.fraction)
		var contacts: Array[Dictionary] = []
		for enemy in game.enemies:
			if not is_instance_valid(enemy) or shot.hit.has(enemy.get_instance_id()): continue
			var t := circle_hit(start,motion,enemy.position,enemy.radius+5)
			if t <= wall: contacts.append({"t":t,"enemy":enemy})
		contacts.sort_custom(func(a,b): return a.t < b.t)
		var consumed := false
		var chained := false
		for contact in contacts:
			var enemy: ArenaEnemy = contact.enemy
			if not is_instance_valid(enemy) or not game.enemies.has(enemy): continue
			shot.p = start+motion*float(contact.t)
			shot.hit.append(enemy.get_instance_id())
			var blocked := enemy.blocks(shot.v)
			var critical: bool = game.rng.randf() < game.upgrades[3]*0.08
			if critical and not blocked: criticals += 1
			if not blocked:
				hits += 1
				if shot.style == 2: enemy.chilled = 1.4
				if shot.style == 3 or game.upgrades[4] > 0:
					enemy.burning = maxf(enemy.burning,2.0)
					enemy.burn_power = maxf(enemy.burn_power,0.6 if shot.style == 3 else game.upgrades[4]*0.5)
			game.damage_enemy(enemy,shot.damage*(1.8 if critical else 1),true,shot.v)
			if shot.style == 7:
				flashes.append({"p":shot.p,"ttl":0.3,"r":65.0,"color":Color("ffb779")})
				for nearby in game.enemies.duplicate():
					if nearby != enemy and nearby.position.distance_to(shot.p) < 65:
						game.damage_enemy(nearby,shot.damage*0.5,true,Vector2.ZERO)
						if game.state != "playing": return
			if game.state != "playing": return
			if blocked:
				consumed = true
				break
			if shot.chain > 0:
				var next := target_from(shot.p,260,shot.hit)
				if next != null:
					shot.chain -= 1
					shot.v = (next.position-shot.p).normalized()*shot.v.length()
					chained = true
					break
			if shot.pierce > 0: shot.pierce -= 1
			else:
				consumed = true
				break
		if not chained: shot.p = start+motion*wall
		shot.ttl -= delta
		if consumed or (wall < 1 and not chained) or shot.ttl <= 0 or not Balance.ARENA.grow(10).has_point(shot.p): shots.erase(shot)

func enemy_volley(enemy: ArenaEnemy) -> void:
	if not line_clear(enemy.position,game.player): return
	var direction: Vector2 = (game.player-enemy.position).normalized()
	var angles := [0.0]
	if enemy.kind == 3:
		var phase_two := enemy.hp < enemy.max_hp*0.5
		match enemy.boss_style:
			0: angles = [-0.2,0.0,0.2]
			1: angles = [-0.4,-0.2,0.0,0.2,0.4]
			2: angles = [-0.6,-0.3,0.0,0.3,0.6]
			3: angles = [-0.5,-0.25,0.0,0.25,0.5]
			_: angles = [-0.6,-0.4,-0.2,0.0,0.2,0.4,0.6] if phase_two else [-0.3,0.0,0.3]
	for angle in angles:
		if hostile.size() >= MAX_HOSTILE: break
		hostile.append({"p":enemy.position+direction.rotated(angle)*(enemy.radius+10),"v":direction.rotated(angle)*(220 if enemy.kind == 3 else 180),"ttl":4.0})
	game.audio.play_event("enemy_shoot",0.8)

func advance(delta: float) -> void:
	if game.state != "playing": return
	shield = maxf(0,shield-delta)
	fire_clock -= delta
	if fire_clock <= 0:
		fire_clock = interval()
		fire()
	advance_shots(delta)
	if game.state != "playing": return
	for enemy in game.enemies.duplicate():
		if not is_instance_valid(enemy): continue
		enemy.chilled = maxf(0,enemy.chilled-delta)
		if enemy.burning > 0:
			enemy.burning -= delta
			enemy.burn_tick -= delta
			if enemy.burn_tick <= 0:
				enemy.burn_tick = 0.5
				game.damage_enemy(enemy,enemy.burn_power*0.5,true,Vector2.ZERO)
				if game.state != "playing": return
				if not game.enemies.has(enemy): continue
		if enemy.kind not in [2,3,5]: continue
		enemy.fire_clock -= delta
		if enemy.fire_clock <= 0:
			enemy.fire_clock = (1.4 if enemy.kind == 3 else 2.8)+(0.4 if enemy.chilled > 0 else 0)
			enemy_volley(enemy)
	for shot in hostile.duplicate():
		var motion: Vector2 = shot.v*minf(delta,shot.ttl)
		var wall := INF
		for box in game.world_obstacles():
			var contact := ArenaGeometry.sweep_rect(shot.p,motion,box.grow(7))
			if not contact.is_empty(): wall = minf(wall,contact.fraction)
		var hit := circle_hit(shot.p,motion,game.player,23)
		if hit <= 1 and hit < wall:
			game.hurt_player(shot.p)
			hostile.erase(shot)
			if game.state != "playing": return
			continue
		shot.p += motion
		shot.ttl -= delta
		if wall <= 1 or shot.ttl <= 0 or not Balance.ARENA.grow(15).has_point(shot.p): hostile.erase(shot)
	for flash in flashes.duplicate():
		flash.ttl -= delta
		if flash.ttl <= 0: flashes.erase(flash)
	if flashes.size() > 32: flashes = flashes.slice(flashes.size()-32)
	queue_redraw()

func _draw() -> void:
	if game == null or game.state not in ["playing","paused","upgrade"]: return
	for shot in shots:
		var color: Color = RobotRoster.COLORS[shot.style] if shot.style in [2,3,4] else Balance.SKIN_COLORS[shot.skin]
		var tail: Vector2 = shot.p-shot.v.normalized()*(45 if shot.style == 4 else 13)
		draw_line(tail,shot.p,Color(color,0.3),9 if shot.style in [3,4] else 6)
		draw_line(tail,shot.p,color,4 if shot.style in [3,4] else 2)
		draw_circle(shot.p,4,Color("ecffff"))
		if shot.style == 7:
			var direction: Vector2 = shot.v.normalized()
			draw_colored_polygon(PackedVector2Array([shot.p+direction*9,shot.p-direction.rotated(0.6)*10,shot.p-direction.rotated(-0.6)*10]),Color("ffbf82"))
	for shot in hostile:
		draw_circle(shot.p,10,Color("290c15"))
		draw_circle(shot.p,7,Color("ff684a"))
		draw_arc(shot.p,8,0,TAU,12,Color("ffe0a3"),2)
	for flash in flashes:
		draw_arc(flash.p,flash.r*(1-flash.ttl*0.4),0,TAU,32,Color(flash.color,minf(0.6,flash.ttl*2)),3)
	if shield > 0 and shield_hits > 0:
		draw_arc(game.player,38,0,TAU,32,Color("8bffe1"),3)
