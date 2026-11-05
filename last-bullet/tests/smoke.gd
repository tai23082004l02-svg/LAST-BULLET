extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = "user://smoke-test.cfg"
	root.add_child(game)
	game.set_physics_process(false)
	await process_frame
	game.rng.seed = 42
	seed(42)
	game.start_run()
	var original = game.bullet
	# Simulate five minutes with damage disabled; accept every level-up.
	for frame in range(18000):
		game.invulnerable = 10
		if game.state == "upgrade":
			game.choose_upgrade(game.offered_upgrades[0])
		game._physics_process(1.0/60.0)
		assert(game.bullet == original, "Bullet identity changed")
		assert(game.bullet.position.is_finite())
		assert(game.enemies.size() <= Balance.MAX_ENEMIES + 1)
		if frame % 600 == 0:
			await process_frame
	assert(game.boss_spawned)
	assert(game.kills > 0)
	assert(game.elapsed >= 299.9)
	# Force same-entity boss capture and release in isolated geometry.
	for enemy in game.enemies:
		enemy.free()
	game.enemies.clear()
	game.boss = null
	if not is_instance_valid(game.boss):
		game.spawn_enemy(3)
	var eater = game.boss
	eater.capture_ready = 0
	eater.position = Vector2(360,400)
	game.bullet.position = eater.position + Vector2(eater.radius+8,0)
	game.bullet.velocity = Vector2.LEFT*560
	game.bullet.hit_cooldowns.clear()
	game.bullet.advance(0.02,game)
	assert(game.bullet.capture > 0)
	game.bullet.advance(1.2,game)
	assert(game.bullet == original and game.bullet.capture <= 0)
	game.finish_run()
	assert(game.state == "results")
	game.start_run()
	assert(game.hp == 5 and game.kills == 0 and game.enemies.is_empty())
	var count := 0
	for child in game.get_children():
		if child is PermanentBullet:
			count += 1
	assert(count == 1)
	print("PASS: five-minute simulation, kills/XP, cap, boss capture/release, results, clean retry")
	DirAccess.remove_absolute(game.save_path)
	game.audio.shutdown()
	OS.delay_msec(150)
	await process_frame
	game.queue_free()
	await process_frame
	await process_frame
	quit()
