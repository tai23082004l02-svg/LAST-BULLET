extends SceneTree

var game: Node2D

func _initialize() -> void:
	call_deferred("run")

func clear_enemies() -> void:
	for enemy in game.enemies:
		enemy.free()
	game.enemies.clear()
	game.boss = null
	game.bullet.hit_cooldowns.clear()

func run() -> void:
	game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = "user://expansion-test.cfg"
	DirAccess.remove_absolute(game.save_path)
	root.add_child(game)
	game.set_physics_process(false)
	await process_frame
	game.start_run("survival","reflector")
	var bullet: PermanentBullet = game.bullet
	# Swept reflector hit changes direction, charges Bank Shot, never duplicates.
	game.upgrades[6] = 1
	bullet.position = Vector2(260,510)
	bullet.velocity = Vector2.RIGHT*560
	bullet.advance(0.1,game)
	assert(bullet.velocity.x < 0 and bullet.bank_charge == 1)
	assert(not ArenaGeometry.PILLAR.grow(7).has_point(bullet.position))
	# Player and enemies resolve outside pillar; navigation takes them around it.
	game.player = Vector2(350,450)
	game._physics_process(0.01)
	assert(not ArenaGeometry.PILLAR.grow(18).has_point(game.player))
	var walker := ArenaEnemy.new()
	walker.setup(0,1)
	walker.position = Vector2(360,380)
	game.add_child(walker)
	game.enemies.append(walker)
	for i in range(420):
		var target := ArenaGeometry.navigation_target(walker.position,Vector2(360,680),walker.radius)
		walker.advance(1.0/60,target)
		walker.position = ArenaGeometry.resolve(walker.position,walker.radius)
		assert(not ArenaGeometry.PILLAR.grow(walker.radius).has_point(walker.position))
	assert(walker.position.y > 600)
	clear_enemies()
	# Perfect streak gains points, normal and missed catches reset streak only.
	game.player = Vector2(360,700)
	game.score = 0
	for i in range(3):
		game.cooldown = 0
		bullet.position = game.player+Vector2(35,0)
		bullet.velocity = Vector2.LEFT*560
		game.request_deflect()
	assert(game.perfect_chain == 3 and game.best_perfect_chain == 3)
	assert(game.score == 150 and game.attempts == 3 and game.deflect_rate() == 100)
	game.cooldown = 0
	bullet.position = game.player+Vector2(80,0)
	game.request_deflect()
	assert(game.perfect_chain == 0 and game.best_perfect_chain == 3)
	game.cooldown = 0
	bullet.position = Vector2(80,210)
	game.request_deflect()
	game.spawn_timer = 99
	var hp: int = game.hp
	game._physics_process(0.23)
	assert(game.perfect_chain == 0 and game.hp == hp and game.deflect_rate() == 80)
	# Boss releases SAME bullet, exposes, and only a returned deflect gets x4.
	game.arena_layout = "open"
	game.spawn_enemy(3)
	var boss: ArenaEnemy = game.boss
	boss.position = Vector2(360,350)
	boss.capture_ready = 0
	bullet.position = boss.position+Vector2(62,0)
	bullet.velocity = Vector2.LEFT*560
	bullet.advance(0.03,game)
	assert(bullet.capture > 0)
	bullet.advance(1.2,game)
	assert(bullet.capture <= 0 and boss.weak_timer == 3)
	assert(bullet.return_window == 3 and game.bullet == bullet)
	bullet.position = game.player+Vector2(70,0)
	game.cooldown = 0
	game.request_deflect()
	assert(bullet.return_strike)
	var health := boss.hp
	game.damage_enemy(boss,2,true,Vector2.UP)
	assert(boss.hp == health-8 and not bullet.return_strike)
	game.damage_enemy(boss,2,true,Vector2.UP)
	assert(boss.hp == health-10)
	clear_enemies()
	# X2 is immediate, includes mission + base gold, and is idempotent.
	game.kills = 15
	game.check_missions()
	game.elapsed = 60
	game.finish_run()
	var base: int = game.run_coins
	var wallet: int = game.coins
	assert(base > 0)
	game.claim_double_gold()
	assert(game.double_claimed and game.coins == wallet+base)
	game.claim_double_gold()
	assert(game.coins == wallet+base)
	assert(game.state == "results")
	game.coins = 0
	game.load_profile()
	assert(game.coins == wallet+base)
	# No bonus before results; no previous run's amount survives retry.
	game.start_run("blitz","open")
	assert(not game.double_claimed and game.run_coins == 0)
	wallet = game.coins
	game.claim_double_gold()
	assert(game.coins == wallet)
	# Blitz deterministic spawn sequence, stops at exactly 90 active seconds.
	var sequence: Array[int] = []
	for i in range(5401):
		game.invulnerable = 10
		if game.state == "upgrade": game.choose_upgrade(game.offered_upgrades[0])
		if game.state == "results": break
		game._physics_process(1.0/60)
		assert(game.enemies.size() <= Balance.MAX_ENEMIES)
		for enemy in game.enemies:
			if not sequence.has(enemy.kind): sequence.append(enemy.kind)
		if i%300 == 0: await process_frame
	assert(game.challenge_complete and game.elapsed == 90 and game.state == "results")
	assert(not game.boss_spawned)
	assert(sequence.has(0) and sequence.has(1) and sequence.has(2) and sequence.has(4) and sequence.has(5))
	assert(game.medal(600) == "BRONZE" and game.medal(1500) == "SILVER" and game.medal(3000) == "GOLD")
	assert(game.blitz_best > 0)
	# Small/zero result cannot create arbitrary coins from x2.
	game.start_run()
	game.finish_run()
	wallet = game.coins
	game.claim_double_gold()
	assert(game.coins == wallet)
	assert(game.bullet.z_index == 20)
	game.low_effects = true
	game.start_run()
	game._physics_process(0.01)
	assert(game.bullet.effects_reduced)
	game.save_profile()
	game.low_effects = false
	game.load_profile()
	assert(game.low_effects)
	print("PASS: reflector sweep/navigation, Perfect streak/rate, boss return strike, instant x2 once, save/retry, 90s Blitz/medals, low effects")
	DirAccess.remove_absolute(game.save_path)
	game.audio.shutdown()
	OS.delay_msec(150)
	await process_frame
	game.queue_free()
	await process_frame
	quit()
