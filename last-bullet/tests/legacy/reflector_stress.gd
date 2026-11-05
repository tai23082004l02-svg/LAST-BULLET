extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = "user://reflector-stress.cfg"
	root.add_child(game)
	game.set_physics_process(false)
	game.start_run("survival","reflector")
	game.rng.seed = 43
	for j in range(8): game.upgrades[j] = Balance.UPGRADE_CAPS[j]
	var bullet = game.bullet
	for i in range(18000):
		game.invulnerable = 10
		game._physics_process(1.0/60)
		assert(game.bullet == bullet and bullet.position.is_finite())
		assert(Balance.ARENA.has_point(bullet.position))
		assert(not ArenaGeometry.PILLAR.grow(7).has_point(bullet.position))
		if i%600 == 0: await process_frame
	assert(game.elapsed > 299 and game.boss_spawned)
	print("PASS: Reflector five-minute high-speed/upgrade stress; same bullet, bounds, pillar")
	DirAccess.remove_absolute(game.save_path)
	game.audio.shutdown()
	OS.delay_msec(150)
	await process_frame
	game.queue_free()
	await process_frame
	quit()
