extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = "user://shooter-stress.cfg"
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	game.layout_viewport(Vector2(720,1600),Vector2(40,32))
	var combat = game.combat
	for robot in range(7):
		game.selected_robot = robot
		game.start_run("survival","reflector")
		game.upgrades.assign(Balance.UPGRADE_CAPS)
		# Ten simulated minutes total, with maxed shots/chain/skills against live mobs.
		for frame in range(2700):
			game.invulnerable = 10
			var angle := frame*0.012
			game.player = ArenaGeometry.resolve_all(Balance.ARENA.get_center()+Vector2(cos(angle)*220,sin(angle)*380),18,game.world_obstacles())
			if game.state == "upgrade": game.choose_upgrade(game.offered_upgrades[0])
			if frame%210 == 0: game.request_skill()
			game._physics_process(1.0/30)
			assert(game.combat == combat and game.state != "results")
			assert(combat.shots.size() <= 160 and combat.hostile.size() <= 180 and combat.flashes.size() <= 32)
			assert(game.enemies.size() <= Balance.MAX_ENEMIES+1)
			for shot in combat.shots: assert(shot.p.is_finite() and shot.v.is_finite() and shot.ttl > 0)
			for shot in combat.hostile: assert(shot.p.is_finite() and shot.v.is_finite() and shot.ttl > 0)
			if frame%450 == 0: await process_frame
		game.finish_run()
		assert(game.state == "results")
		game.show_menu()
		await process_frame
	game.start_run("blitz")
	for frame in range(2800):
		game.invulnerable = 10
		if game.state == "upgrade": game.choose_upgrade(game.offered_upgrades[0])
		game._physics_process(1.0/30)
		if game.state == "results": break
	assert(game.state == "results" and game.challenge_complete and game.elapsed == 90)
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute("user://shooter-stress.cfg")
	print("PASS shooter stress: seven max-upgrade robots, 630s Survival + 90s Blitz, bounded shots/FX/enemies, finite positions, retry cleanup")
	quit()
