extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = "user://arsenal-stress.cfg"
	root.add_child(game)
	game.set_physics_process(false)
	game.audio.enabled = false
	game.layout_viewport(Vector2(720,1600),Vector2(40,32))
	for weapon in range(12):
		game.selected_weapon = weapon
		game.selected_robot = weapon%7
		game.start_run("survival","reflector")
		game.upgrades.assign(Balance.UPGRADE_CAPS)
		for frame in range(1350):
			game.invulnerable = 10
			game.joystick = Vector2.from_angle(frame*0.02) if frame%120 < 60 else Vector2.ZERO
			game.shoot_while_moving = frame >= 675
			if frame%150 == 0: game.request_skill()
			if game.state == "upgrade": game.choose_upgrade(game.offered_upgrades[0])
			game._physics_process(1.0/30)
			assert(game.state == "playing")
			assert(game.combat.shots.size() <= 160 and game.combat.hostile.size() <= 180 and game.combat.flashes.size() <= 32)
			assert(game.enemies.size() <= 49 and game.combat.orbit_hits.size() < 100)
			for shot in game.combat.shots: assert(shot.p.is_finite() and shot.v.is_finite() and shot.ttl > 0)
			if frame%225 == 0: await process_frame
		game.finish_run()
		game.show_menu()
		await process_frame
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute("user://arsenal-stress.cfg")
	print("PASS arsenal stress: 12 weapons x45s, 16 max upgrades, both movement modes, skills, pillars, bounded projectiles/FX/status/auxiliaries")
	quit()
