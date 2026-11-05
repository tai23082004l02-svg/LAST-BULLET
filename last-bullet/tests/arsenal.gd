extends SceneTree
var game: Node2D
const PROFILE := "user://arsenal-test.cfg"
func _initialize() -> void: call_deferred("run")
func cleanup() -> void:
	for p in [PROFILE,"user://arsenal-test-admin.cfg","user://arsenal-test-mode.cfg"]: DirAccess.remove_absolute(p)
func clear_enemies() -> void:
	for enemy in game.enemies: enemy.free()
	game.enemies.clear()
	game.boss = null
func target(point: Vector2) -> ArenaEnemy:
	var enemy := ArenaEnemy.new()
	enemy.setup(2,1)
	enemy.hp = 1000
	enemy.max_hp = 1000
	enemy.fire_clock = 100
	enemy.position = point
	game.add_child(enemy)
	game.enemies.append(enemy)
	return enemy
func run() -> void:
	cleanup()
	game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = PROFILE
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	game.layout_viewport(Vector2(720,1280))
	assert(game.selected_weapon == -1 and not game.shoot_while_moving)
	assert(game.Shooter.WEAPONS.size() == 12 and Balance.UPGRADE_CAPS.size() == 16)
	# Equip is free, saved, profile-isolated, guarded during a run.
	var gold: int = game.coins
	var tickets: int = game.summon.tickets
	game.show_armory(11)
	assert(game.home_shell.active_page == 2 and game.home_shell.nav_buttons.size() == 5)
	game.equip_weapon(11)
	assert(game.selected_weapon == 11 and game.coins == gold and game.summon.tickets == tickets)
	game.selected_weapon = -1
	game.load_profile()
	assert(game.selected_weapon == 11)
	game.shoot_while_moving = true
	game.save_profile()
	game.show_admin()
	game.switch_admin(true)
	assert(game.selected_weapon == -1 and not game.shoot_while_moving)
	game.selected_weapon = 8
	game.show_admin()
	game.switch_admin(false)
	assert(game.selected_weapon == 11 and game.shoot_while_moving)
	var combat = game.combat
	for weapon in range(12):
		game.selected_weapon = weapon
		game.start_run()
		game.equip_weapon((weapon+1)%12)
		assert(game.selected_weapon == weapon)
		game.player = Vector2(200,500)
		clear_enemies()
		var enemy := target(Vector2(350,500))
		combat.fire()
		assert(combat.shots.size() == (5 if weapon == 5 else 1))
		assert(combat.shots[0].style == weapon)
		combat.fire_clock = 100
		for frame in range(30): combat.advance(1.0/60)
		assert(enemy.hp < 1000)
		if weapon == 11: assert(enemy.poisoned > 0)
	# Native elemental weapons receive their upgrade bonuses, not just cosmetic text.
	for pair in [[2,12],[3,4],[11,11]]:
		game.selected_weapon = pair[0]
		game.start_run()
		game.player = Vector2(200,500)
		clear_enemies()
		var elemental := target(Vector2(350,500))
		game.upgrades[pair[1]] = 2
		combat.fire()
		combat.advance_shots(0.5)
		if pair[0] == 2: assert(is_equal_approx(elemental.chilled,2.2))
		if pair[0] == 3: assert(is_equal_approx(elemental.burn_power,1.6))
		if pair[0] == 11: assert(is_equal_approx(elemental.poison_power,2.2))
	# Classic release-to-fire and optional moving fire; skills remain independent.
	game.selected_weapon = 0
	game.start_run()
	game.player = Vector2(200,500)
	clear_enemies()
	target(Vector2(350,500))
	game.shoot_while_moving = false
	game.player_moving = 1
	combat.advance(0.02)
	assert(combat.shots_fired == 0)
	game.player_moving = 0
	combat.fire_clock = 0
	combat.advance(0.02)
	assert(combat.shots_fired == 1)
	game.player_moving = 1
	game.shoot_while_moving = true
	combat.fire_clock = 0
	combat.advance(0.02)
	assert(combat.shots_fired == 2)
	# Diagonal and back-shot upgrades add directions, not just damage numbers.
	combat.reset()
	game.upgrades[8] = 1
	game.upgrades[9] = 1
	combat.fire()
	assert(combat.shots.size() == 4)
	assert(combat.shots[-1].v.x < 0)
	# Wall ricochet stays finite. Splash cannot go through a pillar.
	game.start_run("survival","reflector")
	var pillar: Rect2 = game.world_obstacles()[0]
	game.player = Vector2(pillar.position.x-90,pillar.get_center().y)
	game.upgrades[10] = 1
	combat.emit_shot(game.player,Vector2.RIGHT,2,0,0,650,1000,0)
	combat.advance_shots(0.12)
	assert(combat.shots.size() == 1 and combat.shots[0].v.x < 0 and combat.shots[0].walls == 0)
	var behind := target(Vector2(pillar.end.x+30,pillar.get_center().y))
	combat.area_damage(game.player,400,10)
	assert(behind.hp == 1000)
	var front := target(Vector2(pillar.position.x-45,pillar.get_center().y+45))
	combat.emit_shot(game.player,Vector2.RIGHT,2,0,0,650,1000,10)
	combat.advance_shots(0.12)
	assert(front.hp < 1000) # Wall explosion can damage the visible side.
	# Boomerang returns and can hit the same enemy exactly once on each leg.
	game.start_run()
	game.player = Vector2(200,500)
	clear_enemies()
	var enemy := target(Vector2(350,500))
	combat.emit_shot(game.player,Vector2.RIGHT,2,12,0,520,570,9)
	for frame in range(150): combat.advance_shots(1.0/60)
	assert(enemy.hp == 996 and combat.shots.is_empty())
	# Burn + chill triggers a real thermal burst; poison is an independent damage-over-time.
	combat.reset()
	game.upgrades[4] = 1
	game.upgrades[11] = 1
	game.upgrades[12] = 1
	combat.emit_shot(game.player,Vector2.RIGHT,2,0,0,600,1000,0)
	combat.advance_shots(0.2)
	assert(enemy.poisoned > 0 and enemy.burning > 0 and enemy.chilled > 0)
	assert(combat.thermal_procs == 1 and enemy.hp < 994)
	var hp_before: float = enemy.hp
	combat.fire_clock = 100
	combat.advance(0.5)
	assert(enemy.hp < hp_before)
	# Auxiliary drone fires on the move and blades damage nearby enemies with cooldowns.
	game.start_run()
	game.player = Vector2(300,500)
	clear_enemies()
	enemy = target(game.player+Vector2(78,0))
	game.upgrades[14] = 2
	game.upgrades[15] = 3
	game.player_moving = 1
	combat.advance_auxiliary(0)
	assert(combat.shots.size() == 2 and enemy.hp < 1000)
	hp_before = enemy.hp
	combat.advance_auxiliary(0)
	assert(enemy.hp == hp_before)
	game.show_upgrades()
	var clock: float = combat.orbit_clock
	combat.advance(2)
	assert(combat.orbit_clock == clock)
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	cleanup()
	print("PASS arsenal: 12 damaging weapons, free persisted/profile-safe loadout, stationary/moving fire, directions/ricochet, return hits, poison/thermal combo, drones/blades, paused effects")
	quit()
