extends Node2D
# A bounded projectile simulation. Shots expire; no permanent or reflected player bullet.
const ProjectileArt = preload("res://scripts/projectile_art.gd")
const MAX_SHOTS := 160
const MAX_HOSTILE := 180
const WEAPONS := ["SÚNG TRƯỜNG","SÚNG ĐIỆN","SÚNG BĂNG","PHUN LỬA","LASER","SHOTGUN","SÚNG TRINH SÁT","TÊN LỬA","CUNG XUYÊN","BOOMERANG","PHÓNG LỰU","SÚNG ĐỘC"]
const INFO := ["Cân bằng, chính xác và dễ dùng.","Bắn nhanh; đạn nảy sang một mục tiêu.","Đạn băng làm chậm kẻ địch.","Tầm ngắn, gây cháy liên tục.","Tia nhanh, xuyên thêm ba mục tiêu.","Năm viên mỗi loạt, mạnh ở gần.","Nhịp nhanh, đạn bay xa và chính xác.","Đạn tự dẫn, nổ lan khi va chạm.","Mũi tên tốc độ cao, xuyên một mục tiêu.","Lưỡi đĩa quay về, có thể trúng lần nữa.","Lựu đạn nổ rộng khi va chạm/hết tầm.","Độc trong ba giây, phối hợp được với lửa."]
const COLORS := [Color("86fff0"),Color("ffe27d"),Color("a1edff"),Color("ff9f54"),Color("dcb2ff"),Color("ffcf91"),Color("8ddaff"),Color("ffa76d"),Color("c5ff9b"),Color("7af2df"),Color("ffc262"),Color("b7ed68")]
const SKILLS := ["KHIÊN NĂNG LƯỢNG","XUNG ĐIỆN","ĐÓNG BĂNG","BÙNG CHÁY","BÃO LASER","LOẠT TÊN LỬA","LƯỚT NHANH"]
const INTERVALS := [0.38,0.18,0.52,0.12,0.85,0.8,0.26,0.95,0.7,0.65,1.05,0.42]
const DAMAGES := [1.4,0.65,1.7,0.50,3.5,0.80,0.9,3.0,2.7,1.8,3.2,1.2]
const SPEEDS := [760.0,850.0,700.0,440.0,1400.0,720.0,980.0,520.0,1150.0,570.0,390.0,650.0]
const RANGES := [620.0,560.0,620.0,230.0,720.0,440.0,720.0,700.0,780.0,520.0,520.0,620.0]
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
var drone_clock := 0.0
var orbit_clock := 0.0
var orbit_hits: Dictionary = {}
var thermal_procs := 0

func add_flash(data: Dictionary) -> void:
	if flashes.size() >= 32: flashes.pop_front()
	flashes.append(data)

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
	drone_clock = 0
	orbit_clock = 0
	orbit_hits.clear()
	thermal_procs = 0
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

func weapon_id() -> int:
	return game.selected_weapon if game.selected_weapon >= 0 else game.selected_robot

func interval() -> float:
	return float(INTERVALS[weapon_id()])/(1+game.upgrades[1]*0.16)

func damage() -> float:
	return float(DAMAGES[weapon_id()])*(1+game.upgrades[0]*0.22)*float(game.run_stats.damage)*(1+game.adventure.risk if game.mode == "campaign" else 1)

func skill_cooldown() -> float:
	return float(SKILL_COOLDOWNS[game.selected_robot])*(1-game.upgrades[7]*0.1)*float(game.run_stats.cooldown)

func emit_shot(origin: Vector2, direction: Vector2, power: float, pierce: int, chain: int, reach: float, speed: float, style: int) -> void:
	if shots.size() >= MAX_SHOTS or direction == Vector2.ZERO: return
	var lifetime := reach/speed*(2.5 if style == 9 else 1.0)
	shots.append({"p":origin,"v":direction.normalized()*speed,"damage":power,"ttl":lifetime,"age":0.0,"return_at":reach/speed,"returning":false,"pierce":pierce,"chain":chain,"hit":[],"style":style,"skin":game.selected_skin,"walls":game.upgrades[10],"blast":false})
	shots_fired += 1

func fire() -> void:
	var robot: int = weapon_id()
	var target := target_from(game.player,RANGES[robot])
	if target == null: return
	var direction: Vector2 = (target.position-game.player).normalized()
	game.aim = direction
	game.player_actor.aim = direction
	game.player_actor.weapon = robot
	game.player_actor.kick(robot)
	var count: int = (5 if robot == 5 else 1)+game.upgrades[2]
	for i in range(count):
		var angle: float = (i-(count-1)*0.5)*(0.11 if robot == 5 else 0.13)
		if robot == 3: angle += game.rng.randf_range(-0.12,0.12)
		emit_shot(game.player,direction.rotated(angle),damage(),game.upgrades[5]+(3 if robot == 4 else 1 if robot == 8 else 12 if robot == 9 else 0),game.upgrades[6]+(1 if robot == 1 else 0),RANGES[robot],SPEEDS[robot],robot)
	if game.upgrades[8] > 0:
		for angle in [-0.55,0.55]: emit_shot(game.player,direction.rotated(angle),damage()*0.7,game.upgrades[5],game.upgrades[6],RANGES[robot],SPEEDS[robot],robot)
	if game.upgrades[9] > 0: emit_shot(game.player,-direction,damage()*0.8,game.upgrades[5],game.upgrades[6],RANGES[robot],SPEEDS[robot],robot)
	add_flash({"p":game.player+game.player_actor.muzzle_offset(),"ttl":0.08,"r":13.0,"color":COLORS[robot],"kind":"muzzle","style":robot,"dir":direction})
	game.audio.play_event("shoot",1.2 if robot == 1 else 0.9 if robot == 5 else 1.0)

func skill() -> void:
	if game.state != "playing" or game.cooldown > 0: return
	game.cooldown = 0.0 if game.admin_enabled and game.admin_free_skill else skill_cooldown()
	skill_uses += 1
	var robot: int = game.selected_robot
	var skill_origin: Vector2 = game.player
	var power: float = DAMAGES[game.selected_robot]*(1+game.upgrades[0]*0.22)*float(game.run_stats.damage)*(1+game.adventure.risk if game.mode == "campaign" else 1)
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
	add_flash({"p":game.player,"ttl":0.45,"r":80.0 if robot in [0,6] else 220.0,"color":RobotRoster.COLORS[robot],"kind":"skill","hero":robot,"origin":skill_origin})
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
		shot.age += delta
		if shot.style == 9 and not shot.returning and shot.age >= shot.return_at:
			shot.returning = true
			shot.hit.clear()
		if shot.style == 9 and shot.returning:
			shot.v = (game.player-shot.p).normalized()*SPEEDS[9]*1.2
			if shot.p.distance_to(game.player) < 25:
				shots.erase(shot)
				continue
		if shot.style == 7:
			var locked := target_from(shot.p,800,shot.hit)
			if locked != null:
				shot.v = shot.v.rotated(clampf(shot.v.angle_to(locked.position-shot.p),-delta*3,delta*3))
		var step: float = minf(delta,shot.ttl)
		var start: Vector2 = shot.p
		var motion: Vector2 = shot.v*step
		var wall := 1.0
		var wall_normal := Vector2.ZERO
		for box in game.world_obstacles():
			var contact := ArenaGeometry.sweep_rect(start,motion,box.grow(5))
			if not contact.is_empty() and contact.fraction <= wall:
				wall = contact.fraction
				wall_normal = contact.normal
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
			var critical: bool = game.rng.randf() < minf(0.85,game.upgrades[3]*0.08+float(game.run_stats.crit))
			if critical and not blocked: criticals += 1
			if not blocked:
				hits += 1
				if shot.style == 2 or game.upgrades[12] > 0 or game.run_stats.cold > 0: enemy.chilled = maxf(enemy.chilled,(1.4 if shot.style == 2 else 0.6)+game.upgrades[12]*0.4+float(game.run_stats.cold))
				if shot.style == 11 or game.upgrades[11] > 0:
					enemy.poisoned = 3.0
					enemy.poison_power = maxf(enemy.poison_power,(1.2 if shot.style == 11 else 0.0)+game.upgrades[11]*0.5)
				if shot.style == 3 or game.upgrades[4] > 0 or game.run_stats.burn > 0:
					enemy.burning = maxf(enemy.burning,2.0)
					enemy.burn_power = maxf(enemy.burn_power,(0.6 if shot.style == 3 else 0.0)+game.upgrades[4]*0.5+float(game.run_stats.burn))
			var shock := not blocked and enemy.chilled > 0 and enemy.burning > 0 and enemy.thermal_lock <= 0
			var shock_point: Vector2 = enemy.position
			if shock:
				enemy.thermal_lock = 1.5
				thermal_procs += 1
			add_flash({"p":shot.p,"ttl":0.24,"r":22.0,"color":COLORS[shot.style],"kind":"impact","style":shot.style,"dir":shot.v.normalized()})
			game.damage_enemy(enemy,shot.damage*(1.8 if critical else 1),true,shot.v)
			if game.state != "playing": return
			if shock:
				area_damage(shock_point,75,shot.damage*0.7)
				if game.state != "playing": return
			if shot.style in [7,10] and not shot.blast:
				shot.blast = true
				area_damage(shot.p,100 if shot.style == 10 else 65,shot.damage*(0.65+game.upgrades[13]*0.18),enemy)
			elif game.upgrades[13] > 0 and not blocked:
				area_damage(shot.p,45+game.upgrades[13]*12,shot.damage*0.18*game.upgrades[13],enemy)
			if game.state != "playing": return
			if blocked:
				consumed = true
				break
			if shot.chain > 0 and shot.style != 9:
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
		if shot.style == 9 and not shot.returning and (wall < 1 or not Balance.ARENA.has_point(shot.p)):
			shot.returning = true
			shot.hit.clear()
			shot.p = (shot.p+wall_normal*2).clamp(Balance.ARENA.position+Vector2.ONE*6,Balance.ARENA.end-Vector2.ONE*6)
			wall = 1.0
		if wall < 1 and not chained and not consumed and shot.walls > 0 and shot.style not in [7,10]:
			shot.walls -= 1
			shot.v = shot.v.bounce(wall_normal)
			shot.p += wall_normal*2
			wall = 1.0
		var expired: bool = consumed or (wall < 1 and not chained) or shot.ttl <= 0 or not Balance.ARENA.grow(10).has_point(shot.p)
		if expired:
			if wall < 1 and not chained:
				shot.p += wall_normal*2
				add_flash({"p":shot.p,"ttl":0.24,"r":22.0,"color":COLORS[shot.style],"kind":"impact","style":shot.style,"dir":shot.v.normalized()})
			if shot.style in [7,10] and not shot.blast:
				area_damage(shot.p,100 if shot.style == 10 else 65,shot.damage*(0.8+game.upgrades[13]*0.18))
			shots.erase(shot)

func area_damage(point: Vector2, radius: float, power: float, excluded: ArenaEnemy = null) -> void:
	add_flash({"p":point,"ttl":0.3,"r":radius,"color":Color("ffbd7e")})
	for enemy in game.enemies.duplicate():
		if game.state != "playing": return
		if enemy != excluded and point.distance_to(enemy.position) <= radius and line_clear(point,enemy.position):
			game.damage_enemy(enemy,power,true,Vector2.ZERO)

func advance_auxiliary(delta: float) -> void:
	drone_clock -= delta
	orbit_clock += delta
	for key in orbit_hits.keys():
		orbit_hits[key] -= delta
		if orbit_hits[key] <= 0: orbit_hits.erase(key)
	if game.upgrades[14] > 0 and drone_clock <= 0:
		drone_clock = 0.8
		for i in range(game.upgrades[14]):
			var origin: Vector2 = game.player+Vector2.from_angle(orbit_clock*1.5+i*PI)*45
			var target := target_from(origin,550)
			if target != null: emit_shot(origin,(target.position-origin).normalized(),damage()*0.55,0,0,550,850,0)
	if game.upgrades[15] > 0:
		for i in range(game.upgrades[15]):
			var blade: Vector2 = game.player+Vector2.from_angle(orbit_clock*3+i*TAU/game.upgrades[15])*78
			for enemy in game.enemies.duplicate():
				if game.state != "playing": return
				if not orbit_hits.has(enemy.get_instance_id()) and blade.distance_to(enemy.position) < enemy.radius+13 and line_clear(game.player,enemy.position):
					orbit_hits[enemy.get_instance_id()] = 0.45
					game.damage_enemy(enemy,damage()*0.65,true,blade-game.player)

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
	if game.mode == "campaign" and game.adventure.hard:
		if enemy.kind == 3: angles.append_array([-0.8,0.8])
		else: angles = [-0.14,0.0,0.14]
	for angle in angles:
		if hostile.size() >= MAX_HOSTILE: break
		hostile.append({"p":enemy.position+direction.rotated(angle)*(enemy.radius+10),"v":direction.rotated(angle)*((260 if game.mode == "campaign" and game.adventure.hard else 220) if enemy.kind == 3 else 200 if game.mode == "campaign" and game.adventure.hard else 180),"ttl":4.0})
	game.audio.play_event("enemy_shoot",0.8)

func advance(delta: float) -> void:
	if game.state != "playing": return
	shield = maxf(0,shield-delta)
	fire_clock -= delta
	if fire_clock <= 0 and (game.shoot_while_moving or game.player_moving <= 0.1):
		fire_clock = interval()
		fire()
	advance_auxiliary(delta)
	advance_shots(delta)
	if game.state != "playing": return
	for enemy in game.enemies.duplicate():
		if not is_instance_valid(enemy): continue
		enemy.chilled = maxf(0,enemy.chilled-delta)
		enemy.thermal_lock = maxf(0,enemy.thermal_lock-delta)
		if enemy.poisoned > 0:
			enemy.poisoned -= delta
			enemy.poison_tick -= delta
			if enemy.poison_tick <= 0:
				enemy.poison_tick = 0.5
				game.damage_enemy(enemy,enemy.poison_power*0.5,true,Vector2.ZERO)
				if game.state != "playing": return
				if not game.enemies.has(enemy): continue
		if enemy.burning > 0:
			enemy.burning -= delta
			enemy.burn_tick -= delta
			if enemy.burn_tick <= 0:
				enemy.burn_tick = 0.5
				game.damage_enemy(enemy,enemy.burn_power*0.5,true,Vector2.ZERO)
				if game.state != "playing": return
				if not game.enemies.has(enemy): continue
		if enemy.kind not in [2,3,5] or game.mode == "practice": continue
		enemy.fire_clock -= delta
		if enemy.fire_clock <= 0:
			enemy.fire_clock = ((1.4 if enemy.kind == 3 else 2.8)+(0.4 if enemy.chilled > 0 else 0))*(0.8 if game.mode == "campaign" and game.adventure.hard else 1.0)
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
		draw_round(self,shot.style,shot.p,shot.v.normalized(),shot.skin,shot.age,game.low_effects)
	for i in range(game.upgrades[14]):
		var point: Vector2 = game.player+Vector2.from_angle(orbit_clock*1.5+i*PI)*45
		draw_circle(point,10,Color("143743"))
		draw_arc(point,10,0,TAU,12,Color("8ffff0"),2)
		draw_line(point-Vector2(5,0),point+Vector2(5,0),Color.WHITE,2)
	for i in range(game.upgrades[15]):
		var point: Vector2 = game.player+Vector2.from_angle(orbit_clock*3+i*TAU/game.upgrades[15])*78
		draw_round(self,9,point,Vector2.from_angle(orbit_clock*5+i),0,orbit_clock)
	for shot in hostile:
		draw_circle(shot.p,10,Color("290c15"))
		draw_circle(shot.p,7,Color("ff684a"))
		draw_arc(shot.p,8,0,TAU,12,Color("ffe0a3"),2)
	for flash in flashes:
		if flash.get("kind","") in ["muzzle","impact"]:
			ProjectileArt.flash(self,flash.kind,flash.style,flash.p,flash.dir,1-float(flash.ttl)/(0.08 if flash.kind == "muzzle" else 0.24),game.low_effects)
			continue
		var alpha: float = minf(0.7,flash.ttl*2)
		draw_arc(flash.p,flash.r*(1-flash.ttl*0.4),0,TAU,32,Color(flash.color,alpha),3)
		if flash.get("kind","") == "skill" and not game.low_effects:
			var type: int = flash.hero
			if type == 6:
				for i in range(3): draw_line(flash.origin+Vector2(0,i*8-8),flash.p+Vector2(0,i*8-8),Color(flash.color,alpha*0.6),4)
			else:
				for i in range(12 if type == 4 else 6):
					var direction := Vector2.from_angle(i*TAU/(12 if type == 4 else 6)+flash.ttl)
					var end: Vector2 = flash.p+direction*flash.r*(1-flash.ttl*0.2)
					if type == 2: NeonArt.diamond(self,end,10,Color(flash.color,alpha))
					elif type == 1:
						draw_polyline(PackedVector2Array([flash.p+direction*20,flash.p+direction*100+direction.orthogonal()*18,end]),Color(flash.color,alpha),3)
					elif type == 4: draw_line(flash.p+direction*24,end,Color(flash.color,alpha),4)
					elif type == 0: draw_line(end,end+direction.rotated(PI/3)*25,Color(flash.color,alpha),4)
					else: draw_circle(end,8,Color(flash.color,alpha*0.7))
	if shield > 0 and shield_hits > 0:
		draw_arc(game.player,38,0,TAU,32,Color("8bffe1"),3)

static func draw_round(canvas: CanvasItem, style: int, point: Vector2, direction: Vector2, skin := 0, clock := 0.0, reduced := false) -> void:
	ProjectileArt.projectile(canvas,style,point,direction,skin,clock,reduced)
