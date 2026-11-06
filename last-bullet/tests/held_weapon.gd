extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/Main.tscn").instantiate(); game.save_path = "user://held-weapon-test.cfg"
	root.add_child(game); game.set_physics_process(false); game.audio.enabled = false
	for robot in range(7):
		game.selected_robot = robot; game.selected_weapon = -1; game.start_run()
		assert(game.player_actor.weapon == robot and game.player_actor.recoil == 0)
	for style in range(12):
		game.selected_weapon = style; game.start_run(); assert(game.player_actor.weapon == style)
		for enemy in game.enemies: enemy.free()
		game.enemies.clear(); game.boss = null; game.player = Vector2(350,650)
		var enemy := ArenaEnemy.new(); enemy.setup(2,1); enemy.hp = 10000; enemy.max_hp = 10000; game.add_child(enemy); game.enemies.append(enemy)
		for i in range(8):
			var direction := Vector2.from_angle(i*TAU/8)
			enemy.position = game.player+direction*100; game.combat.reset(); game.combat.fire()
			assert(game.player_actor.aim.is_equal_approx(direction) and game.player_actor.recoil > 0)
			var muzzle: Dictionary = game.combat.flashes.filter(func(f): return f.get("kind","") == "muzzle")[0]
			assert(muzzle.p.is_equal_approx(game.player+game.player_actor.muzzle_offset()))
			assert(game.player_actor.muzzle_offset().length() < 65)
			assert(game.combat.shots[0].p == game.player) # Collision origin unchanged.
		var actor = game.player_actor
		actor.active = false; var recoil: float = actor.recoil; var clock: float = actor.clock
		actor._process(1); assert(actor.recoil == recoil and actor.clock == clock)
		actor.active = true; actor._process(1); assert(actor.recoil == 0)
	game.audio.shutdown(); game.queue_free(); await process_frame
	DirAccess.remove_absolute("user://held-weapon-test.cfg")
	print("PASS held_weapon: 7 defaults/12 equips, 8 aim directions, muzzle alignment, bounded recoil/pause/reset, unchanged collision origin")
	quit()
