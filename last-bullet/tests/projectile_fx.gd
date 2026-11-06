extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/Main.tscn").instantiate()
	game.save_path = "user://projectile-fx-test.cfg"
	root.add_child(game); game.set_physics_process(false); game.audio.enabled = false
	for style in range(12):
		game.start_run(); game.selected_weapon = style
		for enemy in game.enemies: enemy.free()
		game.enemies.clear(); game.boss = null
		game.player = Vector2(200,500)
		var enemy := ArenaEnemy.new(); enemy.setup(2,1); enemy.position = Vector2(280,500); enemy.hp = 10000; enemy.max_hp = 10000
		game.add_child(enemy); game.enemies.append(enemy)
		game.combat.fire()
		assert(game.combat.flashes.any(func(f): return f.get("kind","") == "muzzle" and f.style == style))
		for i in range(15): game.combat.advance_shots(1.0/60)
		assert(game.combat.flashes.any(func(f): return f.get("kind","") == "impact" and f.style == style))
		game.state = "paused"
		var before: Array = game.combat.flashes.duplicate(true)
		game.combat.advance(1); assert(game.combat.flashes == before)
		game.state = "playing"
		for i in range(100): game.combat.add_flash({"p":Vector2.ZERO,"ttl":0.1,"r":5,"color":Color.WHITE})
		assert(game.combat.flashes.size() == 32)
		game.combat.reset(); assert(game.combat.flashes.is_empty())
	game.audio.shutdown(); game.queue_free(); await process_frame
	DirAccess.remove_absolute("user://projectile-fx-test.cfg")
	print("PASS projectile_fx: all12 real muzzle/impact styles, pause freeze, bounded flashes and reset")
	quit()
