extends SceneTree
var game: Node2D
const PROFILE := "user://shooting-test.cfg"
func _initialize() -> void: call_deferred("run")
func enemy_at(point: Vector2, kind := 2, health := 100.0) -> ArenaEnemy:
	var enemy := ArenaEnemy.new()
	enemy.setup(kind,1)
	enemy.position = point
	enemy.hp = health
	enemy.max_hp = health
	game.add_child(enemy)
	game.enemies.append(enemy)
	return enemy
func clear_enemies() -> void:
	for enemy in game.enemies: enemy.free()
	game.enemies.clear()
	game.boss = null
func run() -> void:
	DirAccess.remove_absolute(PROFILE)
	# A real legacy profile retains currency, inventory, progression and unknown/old records.
	var config := ConfigFile.new()
	config.set_value("profile","coins",123)
	config.set_value("profile","robots",[0,2,4])
	config.set_value("profile","robot",2)
	config.set_value("profile","skins",[0,1])
	config.set_value("record","score",9876)
	config.set_value("campaign","unlocked",3)
	config.set_value("campaign","stars",[3,2,0,0,0])
	config.set_value("summon","tickets",8)
	config.set_value("summon","shards",42)
	config.set_value("summon","epic_pity",7)
	config.save(PROFILE)
	game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = PROFILE
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	game.layout_viewport(Vector2(720,1280))
	assert(game.coins == 123 and game.selected_robot == 2 and game.campaign_unlocked == 3)
	assert(game.best_score == 0 and game.owned_skins.has(1))
	assert(game.summon.tickets == 8 and game.summon.shards == 42 and game.summon.epic_pity == 7)
	game.save_profile()
	config.load(PROFILE)
	assert(config.get_value("record","score") == 9876)
	assert(config.get_value("profile","combat_version") == 2)
	game.selected_robot = 0
	game.start_run()
	game.player = Vector2(200,500)
	game.spawn_timer = 100
	var combat = game.combat
	var enemy := enemy_at(Vector2(450,500))
	combat.fire()
	assert(combat.shots.size() == 1)
	combat.advance_shots(0.4)
	assert(enemy.hp < 100 and combat.shots.is_empty())
	# Friendlies cannot hurt the player. Finite range and life leave no permanent projectile.
	var health: int = game.hp
	combat.emit_shot(game.player,Vector2.RIGHT,1,0,0,100,760,0)
	combat.advance_shots(2)
	assert(game.hp == health and combat.shots.is_empty())
	# Swept collision catches thin targets at long steps; pierce and chain each hit distinct enemies.
	clear_enemies()
	var first := enemy_at(Vector2(300,500))
	var second := enemy_at(Vector2(400,500))
	combat.emit_shot(game.player,Vector2.RIGHT,2,1,0,600,1000,0)
	combat.advance_shots(0.3)
	assert(first.hp == 98 and second.hp == 98 and combat.shots.is_empty())
	combat.emit_shot(game.player,Vector2.RIGHT,2,0,1,600,1000,1)
	combat.advance_shots(0.15)
	combat.advance_shots(0.2)
	assert(first.hp == 96 and second.hp == 96)
	# Critical hits and burning are real damage, Frost slows, blocked armor consumes a shot.
	game.upgrades[3] = 5
	game.upgrades[4] = 2
	game.rng.seed = 3
	combat.emit_shot(game.player,Vector2.RIGHT,2,0,0,600,1000,2)
	combat.advance_shots(0.15)
	assert(first.chilled > 0 and first.burning > 0)
	combat.fire_clock = 100
	var before: float = first.hp
	combat.advance(0.6)
	assert(first.hp < before)
	clear_enemies()
	game.upgrades.fill(0)
	var guard := enemy_at(Vector2(350,500),4)
	guard.facing = Vector2.LEFT
	combat.emit_shot(game.player,Vector2.RIGHT,10,3,0,600,1000,0)
	combat.advance_shots(0.3)
	assert(guard.hp == 100 and combat.shots.is_empty())
	guard.facing = Vector2.RIGHT
	combat.emit_shot(game.player,Vector2.RIGHT,10,0,0,600,1000,0)
	combat.advance_shots(0.3)
	assert(guard.hp == 90)
	# Targeting cannot shoot through a pillar or exceed weapon range.
	clear_enemies()
	game.arena_layout = "reflector"
	var pillar: Rect2 = game.world_obstacles()[0]
	game.player = Vector2(pillar.position.x-100,pillar.get_center().y)
	var hidden := enemy_at(Vector2(pillar.end.x+100,pillar.get_center().y))
	assert(combat.target_from(game.player,700) == null)
	var visible := enemy_at(game.player+Vector2(0,150))
	assert(combat.target_from(game.player,700) == visible)
	combat.emit_shot(game.player,Vector2.RIGHT,10,5,0,700,1500,4)
	combat.advance_shots(0.5)
	assert(hidden.hp == 100 and combat.shots.is_empty())
	# A hostile crossing the pillar is removed before reaching the player.
	combat.hostile.append({"p":Vector2(pillar.end.x+80,pillar.get_center().y),"v":Vector2(-1200,0),"ttl":2.0})
	combat.fire_clock = 100
	combat.advance(0.5)
	assert(game.hp == health and combat.hostile.is_empty())
	# Swept enemy bullets hit once; shield absorbs, invulnerability prevents repeated damage.
	game.arena_layout = "open"
	clear_enemies()
	game.player = Vector2(300,500)
	combat.reset()
	combat.fire_clock = 100
	combat.hostile.append({"p":Vector2(100,500),"v":Vector2(1000,0),"ttl":2.0})
	combat.advance(0.4)
	assert(game.hp == health-1 and combat.hostile.is_empty())
	game.invulnerable = 0
	game.selected_robot = 0
	game.cooldown = 0
	game.request_skill()
	assert(combat.shield_hits == 3 and game.cooldown == 10)
	game.hurt_player(game.player+Vector2(30,0))
	assert(game.hp == health-1 and combat.shield_hits == 2)
	var count: int = combat.skill_uses
	game.request_skill()
	assert(combat.skill_uses == count)
	# Every robot's weapon and skill are usable and distinct; skills cannot run while paused/upgrading/results.
	for robot in range(7):
		game.selected_robot = robot
		game.start_run()
		game.player = Balance.ARENA.get_center()
		clear_enemies()
		var target := enemy_at(game.player+Vector2(150,0))
		combat.fire()
		assert(combat.shots.size() == (5 if robot == 5 else 1))
		game.request_skill()
		assert(combat.skill_uses == 1 and game.cooldown > 0)
		if robot == 2: assert(target.chilled == 3)
		if robot == 6: assert(game.invulnerable > 0)
		if robot in [1,2,3]: assert(target.hp < 100)
		for state in ["paused","upgrade","results"]:
			game.state = state
			game.cooldown = 0
			game.request_skill()
			assert(combat.skill_uses == 1)
		game.state = "playing"
	# Guided Cobalt rockets really hit and splash; crit upgrades produce extra damage.
	game.selected_robot = 5
	game.start_run()
	game.player = Vector2(200,500)
	clear_enemies()
	var rocket_target := enemy_at(Vector2(400,500),2,1000)
	var splash_target := enemy_at(Vector2(425,520),2,1000)
	game.request_skill()
	assert(combat.shots.size() == 7 and combat.shots[0].style == 7)
	for i in range(60): combat.advance_shots(1.0/60)
	assert(rocket_target.hp < 1000 and splash_target.hp < 1000)
	combat.reset()
	game.upgrades[3] = 5
	game.rng.seed = 804
	var hp_before: float = rocket_target.hp
	for i in range(40): combat.emit_shot(game.player,Vector2.RIGHT,1,0,0,600,1000,0)
	combat.advance_shots(0.3)
	assert(combat.criticals > 0 and rocket_target.hp < hp_before-40)
	# Upgrade, pause and results freeze projectiles and reset does not leak a previous run.
	game.show_upgrades()
	var shot_positions: Array = combat.shots.map(func(s): return s.p)
	game._physics_process(1)
	assert(combat.shots.map(func(s): return s.p) == shot_positions)
	game.choose_upgrade(game.offered_upgrades[0])
	assert(game.state == "playing" and not game.upgrade_shade.visible)
	game.kills = 15
	combat.skill_uses = 3
	game.best_combo = 10
	var coins: int = game.coins
	game.check_missions()
	assert(game.coins == coins+45)
	game.check_missions()
	assert(game.coins == coins+45)
	game.finish_run()
	coins = game.coins
	var reward: int = game.run_coins
	game.claim_double_gold()
	game.claim_double_gold()
	assert(game.coins == coins+reward)
	game.start_run()
	assert(combat.shots.is_empty() and combat.hostile.is_empty() and combat.skill_uses == 0)
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(PROFILE)
	print("PASS shooting: legacy save, swept hits, expiry, pierce/chain, LOS/walls, shields, enemy bullets, seven weapons/skills, pause, missions and x2")
	quit()
