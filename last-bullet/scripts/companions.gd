extends Node2D
const View = preload("res://scripts/collectible_view.gd")
var game: Node2D
var timer := 0.0
var clock := 0.0
var heals := 0
var barrier_timer := 0.0
var pet_position := Vector2.ZERO
func reset() -> void:
	timer = 0; clock = 0; heals = 0; barrier_timer = 0
	pet_position = game.player+Vector2(-42,-35)
func block() -> bool:
	if game.run_pet == 3 and timer <= 0:
		timer = 16; return true
	if game.run_stats.get("barrier",false) and barrier_timer <= 0 and game.hp <= ceili(game.max_hp*0.5):
		barrier_timer = 20
		if game.run_stats.get("legend_shield",false):
			for enemy in game.enemies:
				enemy.position = ArenaGeometry.resolve_all((enemy.position+(enemy.position-game.player).normalized()*55).clamp(Balance.ARENA.position+Vector2.ONE*enemy.radius,Balance.ARENA.end-Vector2.ONE*enemy.radius),enemy.radius,game.world_obstacles())
		return true
	return false
func advance(delta: float) -> void:
	if game.state != "playing": return
	clock += delta; timer -= delta; barrier_timer = maxf(0,barrier_timer-delta)
	pet_position = pet_position.lerp(game.player+Vector2(-42,-35),1-exp(-delta*8))
	if timer <= 0:
		match game.run_pet:
			0:
				var target = game.combat.target_from(pet_position,550)
				if target != null: game.combat.emit_shot(pet_position,target.position-pet_position,game.combat.damage()*0.65,0,0,550,800,0)
				timer = 1
			1:
				for i in range(game.pickups.size()): game.pickups[i] = game.player
				timer = 6
			2:
				if heals < 3 and game.hp < game.max_hp:
					game.hp += 1; heals += 1; timer = 22
			3: pass
			4:
				var target = game.combat.target_from(game.player,600)
				if target != null:
					for enemy in game.enemies:
						if enemy.position.distance_to(target.position) < 110 and game.combat.line_clear(target.position,enemy.position): enemy.chilled = maxf(enemy.chilled,2+game.run_stats.get("cold",0.0))
				timer = 8
			5:
				var target = game.combat.target_from(game.player,600)
				var most := -1
				for enemy in game.enemies:
					if not game.combat.line_clear(game.player,enemy.position): continue
					var count := 0
					for other in game.enemies:
						if other.position.distance_to(enemy.position) < 100: count += 1
					if count > most: most = count; target = enemy
				if target != null: game.combat.area_damage(target.position,100,game.combat.damage()*1.8)
				timer = 7
	queue_redraw()
func _draw() -> void:
	if game == null or game.state not in ["playing","paused","upgrade"]: return
	View.draw_pet(self,pet_position,12,game.run_pet,clock)
	if timer > 0:
		draw_arc(pet_position,17,-PI/2,-PI/2+TAU*clampf(timer/[1.0,6.0,22.0,16.0,8.0,7.0][game.run_pet],0,1),20,Color(0.6,0.9,1,0.4),1)
